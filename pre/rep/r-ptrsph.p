block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-obj-type    as character     no-undo .
define input parameter p-obj-code    as integer       no-undo .
define variable vss-revision    as character no-undo initial "$Revision: c7170b2137c1, 2069, rls $":U .
define variable vss-author      as character no-undo initial "$Author: EShklyar $":U .
define variable vss-date        as character no-undo initial "$Date: Fri Oct 18 13:05:47 2019 +0300 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: r-ptrsph.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: rep/r-ptrsph.p $":U .
define variable vss-description as character no-undo initial "Почасовая статистика продаж ТРК с детализацией по пистолетам":U .
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
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
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
define  shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define  shared variable RepPathName        as character no-undo .
define  shared variable PrintRubl          as logical   no-undo .
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
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure findtank:
  define input  parameter p-obj-type     as character no-undo.
  define input  parameter p-obj-code     as integer   no-undo.
  define input  parameter p-pump-code    as integer   no-undo.
  define input  parameter p-nozzle-code  as integer   no-undo .
  define input  parameter p-from-pl-code as integer   no-undo .
  define input  parameter p-gds-code     as integer   no-undo.
  define output parameter p-pl-code      as integer   no-undo .
  define variable v-pl-code            like ub.place.pl-code no-undo .
  define variable v-dopstr             as character no-undo .
  define buffer buf_place for ub.place.
  define buffer buf_pl-gds-pump for ub.pl-gds-pump.
  define buffer buf_pl-pump-nozzle for ub.pl-pump-nozzle.
  define buffer buf_pl-gds for ub.pl-gds.
  do
  on error undo, return error return-value
  :
    assign
      v-pl-code = 0
      p-pl-code = ?
    .
    if p-from-pl-code <> ?
      and p-from-pl-code <> 0
    then do:
      find first buf_pl-gds no-lock
        where buf_pl-gds.obj-type  = p-obj-type
          and buf_pl-gds.obj-code  = p-obj-code
          and buf_pl-gds.pl-code   = p-from-pl-code
          and buf_pl-gds.gds-code  = p-gds-code
        no-error.
      if available buf_pl-gds then do:
        assign
          v-pl-code = buf_pl-gds.pl-code
        .
      end.
    end.
    if v-pl-code <> 0
      and p-nozzle-code <> ?
      and p-nozzle-code <> 0
    then do:
      find first buf_pl-pump-nozzle no-lock
        where buf_pl-pump-nozzle.obj-type    = p-obj-type
          and buf_pl-pump-nozzle.obj-code    = p-obj-code
          and buf_pl-pump-nozzle.pl-code     = v-pl-code
          and buf_pl-pump-nozzle.pump-code   = p-pump-code
          and buf_pl-pump-nozzle.nozzle-code = p-nozzle-code
        no-error .
      if not available buf_pl-pump-nozzle then do:
        return.
      end.
    end.
    if v-pl-code = 0 then do:
      if p-nozzle-code = 0 then do:
        find first buf_pl-gds-pump no-lock
          where buf_pl-gds-pump.obj-type  = p-obj-type
            and buf_pl-gds-pump.obj-code  = p-obj-code
            and buf_pl-gds-pump.pump-code = p-pump-code
            and buf_pl-gds-pump.gds-code  = p-gds-code
            and buf_pl-gds-pump.status_   = 'тек':U
          no-error.
        if available buf_pl-gds-pump then do:
          assign
            v-pl-code = buf_pl-gds-pump.pl-code
          .
        end.
      end.
      else do:
        _ppnz:
        for each buf_pl-pump-nozzle no-lock
          where buf_pl-pump-nozzle.obj-type = p-obj-type
            and buf_pl-pump-nozzle.obj-code = p-obj-code
            and buf_pl-pump-nozzle.pump-code = p-pump-code
            and buf_pl-pump-nozzle.nozzle-code = p-nozzle-code
          ,first buf_pl-gds-pump no-lock
          where buf_pl-gds-pump.obj-type  = p-obj-type
            and buf_pl-gds-pump.obj-code  = p-obj-code
            and buf_pl-gds-pump.pump-code = p-pump-code
            and buf_pl-gds-pump.gds-code  = p-gds-code
            and buf_pl-gds-pump.status_   = 'тек':U
            and buf_pl-gds-pump.pl-code   = buf_pl-pump-nozzle.pl-code
        on error undo, return error return-value
        :
          assign
            v-pl-code = buf_pl-pump-nozzle.pl-code
          .
          leave _ppnz.
        end.
      end.
    end.
    if v-pl-code <> 0 then do:
      assign
        p-pl-code = v-pl-code
      .
    end.
  end.
end procedure.
procedure find-nzl:
define input  parameter p-obj-type   as character no-undo.
define input  parameter p-obj-code   as integer   no-undo.
define input  parameter p-pump-code  as integer   no-undo.
define input  parameter p-gds-code   as integer   no-undo.
define input  parameter p-pl-code    as integer no-undo .
define output parameter p-nozzle-code    as integer   no-undo.
define variable v-nozzle-code        like ub.nozzle.nozzle-code no-undo .
define variable v-pl-code            like ub.place.pl-code no-undo .
define variable v-pump-code          like ub.pump.pump-code no-undo .
define variable v-loc1-code          like ub.place.loc1 no-undo .
define variable v-dopstr             as character no-undo .
define buffer buf_place for ub.place.
define buffer buf_pl-gds-pump for ub.pl-gds-pump.
define buffer buf_pl-pump-nozzle for ub.pl-pump-nozzle.
define buffer buf_pl-gds for ub.pl-gds.
do on error undo, return error return-value :
  v-pump-code = p-pump-code.
  find first buf_pl-pump-nozzle no-lock where
                buf_pl-pump-nozzle.obj-type = p-obj-type
            and buf_pl-pump-nozzle.obj-code = p-obj-code
            and buf_pl-pump-nozzle.pump-code = p-pump-code
            and buf_pl-pump-nozzle.pl-code = p-pl-code no-error.
  if not available buf_pl-pump-nozzle then do:
    assign
    p-nozzle-code = ?.
    return .
  end.
  assign
  p-nozzle-code = buf_pl-pump-nozzle.nozzle-code.
  return.
  .
end.
end procedure.
procedure find-nzl-without-pl:
define input  parameter p-obj-type   as character no-undo.
define input  parameter p-obj-code   as integer   no-undo.
define input  parameter p-pump-code  as integer   no-undo.
define input  parameter p-gds-code   as integer   no-undo.
define output parameter p-nozzle-code    as integer   no-undo.
define buffer buf_pl-gds-pump for ub.pl-gds-pump.
define buffer buf_pl-gds for ub.pl-gds.
define buffer buf_pl-pump-nozzle for ub.pl-pump-nozzle.
do on error undo, return error return-value :
  for each buf_pl-gds-pump no-lock where
            buf_pl-gds-pump.obj-type  = p-obj-type
        and buf_pl-gds-pump.obj-code  = p-obj-code
        and buf_pl-gds-pump.pump-code = p-pump-code
        and buf_pl-gds-pump.gds-code  = p-gds-code
        and buf_pl-gds-pump.status_   = 'тек':U,
      first buf_pl-gds no-lock where
                buf_pl-gds.obj-type = p-obj-type
            AND buf_pl-gds.obj-code = p-obj-code
            AND buf_pl-gds.pl-code = buf_pl-gds-pump.pl-code
            AND buf_pl-gds.gds-code = p-gds-code
            AND buf_pl-gds.status_ = 'тек':U,
     first buf_pl-pump-nozzle no-lock where
              buf_pl-pump-nozzle.obj-type = p-obj-type
          and buf_pl-pump-nozzle.obj-code = p-obj-code
          and buf_pl-pump-nozzle.pl-code = buf_pl-gds.pl-code
          and buf_pl-pump-nozzle.pump-code = p-pump-code:
    assign
    p-nozzle-code = buf_pl-pump-nozzle.nozzle-code.
    return .
  end.
  assign
  p-nozzle-code = ?.
  return.
  .
end.
end procedure.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-chk-gds no-undo
field doc-code like ub.chk-doc.doc-code
FIELD b-code like ub.chk-gds.b-code
FIELD src-code like ub.chk-gds.src-code
field sum as decimal
field sum-change as decimal
field qnty like ub.chk-gds.doc-qnty
field qnty2 like ub.chk-gds.doc-qnty
field price-base as decimal
field rec-type as integer
field gds-type as integer
field line-num as integer
field pump as integer
field nozzle-code as integer
field jj_ as integer
field jjp_ as integer
field jjo_ as integer
index pi iS unique primary
doc-code
rec-type
b-code
pump
nozzle-code
index ijj is unique
jj_
index ijjp
jjp_
index ijjo
jjo_
.
define temp-table temp-chk-pay no-undo like ub.chk-pay
field pet-good as integer
field obj-name like ub.cash-pay.obj-name
field is-cash  like ub.cash-pay.is-cash
field register like ub.cash-pay.register
index pi is primary unique line-num
index isort
pet-good  descending
line-num
.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE NEW SHARED TEMP-TABLE treal-2 no-undo
FIELD gds-code as integer
FIELD cpay-code as integer
FIELD curr-code as integer
FIELD qnty1 as decimal
FIELD qnty2 as decimal
FIELD netto as decimal
FIELD out-name as character format "X(18)"
FIELD is-pay as logical
FIELD ii as integer
FIELD pay-desk as integer
FIELD pump as integer
FIELD nozzle-code as integer
FIELD prefix as character
FIELD netto-rubl as decimal
INDEX pi IS
  unique
  primary
      gds-code
      pay-desk
      pump
      nozzle-code
      cpay-code
      curr-code
      prefix
      is-pay DESCENDING
INDEX vi
      gds-code
      ii
.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE NEW SHARED TEMP-TABLE treal-4 no-undo
FIELD gds-code as integer
FIELD cpay-code as integer
FIELD curr-code as integer
FIELD qnty1 as decimal
FIELD netto as decimal
FIELD out-name as character format "X(20)"
FIELD is-pay as logical
FIELD ii as integer
FIELD pay-desk as integer
FIELD prefix as character
FIELD netto-rubl as decimal
INDEX pi IS UNIQUE PRIMARY
      gds-code
      pay-desk
      cpay-code
      curr-code
      prefix
      is-pay DESCENDING
INDEX vi
      gds-code
      ii
.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE NEW SHARED TEMP-TABLE treal-8 no-undo
FIELD gds-code as integer
FIELD cpay-code as integer
FIELD curr-code as integer
FIELD qnty1 as decimal
FIELD netto as decimal
FIELD netto-rubl as decimal
FIELD cli-type as character
FIELD cli-code as integer
INDEX pi IS  unique  primary
gds-code
cpay-code
curr-code
cli-type
cli-code
index  ipay cpay-code curr-code
index icli cli-type cli-code
.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE NEW SHARED TEMP-TABLE treal-3 no-undo
FIELD gds-code like ub.goods.gds-code
FIELD cpay-code as integer
FIELD curr-code as integer
FIELD qnty1 as decimal
FIELD netto as decimal
FIELD out-name as character format "X(20)"
FIELD is-pay as logical
FIELD ii as integer
FIELD pay-desk as integer
FIELD prefix as character
FIELD netto-rubl as decimal
INDEX pi IS UNIQUE PRIMARY
        gds-code
        pay-desk
        cpay-code
        curr-code
        prefix
        is-pay DESCENDING
INDEX vi
      gds-code
      ii
.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE create-treal-2.
DEFINE INPUT PARAMETER pgds-code like ub.goods.gds-code no-undo.
DEFINE INPUT PARAMETER pcpay-code like ub.cash-pay.cdpay-code no-undo.
DEFINE INPUT PARAMETER pcurr-code like ub.cash-pay.curr-code no-undo.
DEFINE INPUT PARAMETER pqnty1 as decimal no-undo.
DEFINE INPUT PARAMETER pqnty2 as decimal no-undo.
DEFINE INPUT PARAMETER pnetto as decimal no-undo.
DEFINE INPUT PARAMETER pout-name as character no-undo.
DEFINE INPUT PARAMETER pis-pay as logical no-undo.
DEFINE INPUT PARAMETER pii as integer no-undo.
DEFINE INPUT PARAMETER p-pay-desk as integer no-undo.
define input parameter p-prefix   as character no-undo .
define input parameter p-pump as integer no-undo .
define input parameter p-nozzle-code as integer no-undo .
_main:
DO ON ERROR UNDO _main, return error:
    create treal-2.
    assign
    treal-2.gds-code = pgds-code
    treal-2.cpay-code = pcpay-code
    treal-2.curr-code = pcurr-code
    treal-2.qnty1  =  pqnty1
    treal-2.qnty2  = pqnty2
    treal-2.netto = pnetto
    treal-2.out-name = pout-name
    treal-2.is-pay = pis-pay
    treal-2.ii = pii
    treal-2.pay-desk = p-pay-desk
    treal-2.prefix   = p-prefix
    treal-2.pump   = p-pump
    treal-2.nozzle-code   = p-nozzle-code
    no-error
    .
    if error-status:error then undo _main, return error.
END.
END PROCEDURE.
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer g-treal-3 for treal-3.
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE create-g-treal-3.
DEFINE INPUT PARAMETER pgds-code like ub.goods.gds-code no-undo.
DEFINE INPUT PARAMETER pcpay-code like ub.cash-pay.cdpay-code no-undo.
DEFINE INPUT PARAMETER pcurr-code like ub.cash-pay.curr-code no-undo.
DEFINE INPUT PARAMETER pqnty1 as decimal no-undo.
DEFINE INPUT PARAMETER pnetto as decimal no-undo.
DEFINE INPUT PARAMETER pout-name as character no-undo.
DEFINE INPUT PARAMETER pis-pay as logical no-undo.
DEFINE INPUT PARAMETER pii as integer no-undo.
DEFINE INPUT PARAMETER p-pay-desk as integer no-undo.
define input parameter p-prefix   as character no-undo .
_main:
DO ON ERROR UNDO _main, return error:
    create treal-3.
    assign
    treal-3.gds-code = pgds-code
    treal-3.cpay-code = pcpay-code
    treal-3.curr-code = pcurr-code
    treal-3.qnty1  =  pqnty1
    treal-3.netto = pnetto
    treal-3.out-name = pout-name
    treal-3.is-pay = pis-pay
    treal-3.ii = pii
    treal-3.pay-desk = p-pay-desk
    treal-3.prefix   = p-prefix
    no-error
    .
    if error-status:error then undo _main, return error.
END.
END PROCEDURE.
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE create-g-g-treal-3.
DEFINE INPUT PARAMETER pgds-code like ub.goods.gds-code no-undo.
DEFINE INPUT PARAMETER pcpay-code like ub.cash-pay.cdpay-code no-undo.
DEFINE INPUT PARAMETER pcurr-code like ub.cash-pay.curr-code no-undo.
DEFINE INPUT PARAMETER pqnty1 as decimal no-undo.
DEFINE INPUT PARAMETER pnetto as decimal no-undo.
DEFINE INPUT PARAMETER pout-name as character no-undo.
DEFINE INPUT PARAMETER pis-pay as logical no-undo.
DEFINE INPUT PARAMETER pii as integer no-undo.
DEFINE INPUT PARAMETER p-pay-desk as integer no-undo.
define input parameter p-prefix   as character no-undo .
_main:
DO ON ERROR UNDO _main, return error:
    create g-treal-3.
    assign
    g-treal-3.gds-code = pgds-code
    g-treal-3.cpay-code = pcpay-code
    g-treal-3.curr-code = pcurr-code
    g-treal-3.qnty1  =  pqnty1
    g-treal-3.netto = pnetto
    g-treal-3.out-name = pout-name
    g-treal-3.is-pay = pis-pay
    g-treal-3.ii = pii
    g-treal-3.pay-desk = p-pay-desk
    g-treal-3.prefix   = p-prefix
    no-error
    .
    if error-status:error then undo _main, return error.
END.
END PROCEDURE.
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE create-treal-4.
DEFINE INPUT PARAMETER pgds-code like ub.goods.gds-code no-undo.
DEFINE INPUT PARAMETER pcpay-code like ub.cash-pay.cdpay-code no-undo.
DEFINE INPUT PARAMETER pcurr-code like ub.cash-pay.curr-code no-undo.
DEFINE INPUT PARAMETER pqnty1 as decimal no-undo.
DEFINE INPUT PARAMETER pnetto as decimal no-undo.
DEFINE INPUT PARAMETER pout-name as character no-undo.
DEFINE INPUT PARAMETER pis-pay as logical no-undo.
DEFINE INPUT PARAMETER pii as integer no-undo.
DEFINE INPUT PARAMETER p-pay-desk as integer no-undo.
define input parameter p-prefix   as character no-undo .
_main:
DO ON ERROR UNDO _main, return error:
    create treal-4.
    assign
    treal-4.gds-code = pgds-code
    treal-4.cpay-code = pcpay-code
    treal-4.curr-code = pcurr-code
    treal-4.qnty1  =  pqnty1
    treal-4.netto = pnetto
    treal-4.out-name = pout-name
    treal-4.is-pay = pis-pay
    treal-4.ii = pii
    treal-4.pay-desk = p-pay-desk
    treal-4.prefix   = p-prefix
    no-error
    .
    if error-status:error then undo _main, return error.
END.
END PROCEDURE.
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define NEW SHARED temp-table treal-vat no-undo
FIELD vat-pc like ub.doc-line.vat-pc
FIELD inkas-code like ub.inkas.inkas-code
FIELD doc-date    like ub.inkas.doc-date
FIELD netto as decimal
FIELD netto-rubl as decimal
FIELD fact-order like ub.trn-doc.fact-order
FIELD grp-code as character
FIELD rv as integer
index pi is unique primary
inkas-code grp-code rv vat-pc
index ifactorder fact-order
index igrp grp-code
.
define NEW SHARED temp-table tt-cash-group no-undo
FIELD obj-name like ub.cash-pay.obj-name
FIELD grp-code as character
index pi is UNIQUE primary
grp-code
.
define NEW SHARED temp-table tt-cash-pay no-undo
FIELD cdpay-code like ub.cash-pay.cdpay-code
FIELD curr-code like ub.cash-pay.curr-code
FIELD grp-code as character
FIELD obj-name like ub.cash-pay.obj-name
index pi is unique primary
cdpay-code curr-code
index igrp grp-code
.
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE NEW SHARED TEMP-TABLE t-3 no-undo
FIELD grp-code-sheet like ub.goods.grp-code
FIELD grp-name like ub.gds-grp.node-name format "X(32)"
FIELD serv-name as char
FIELD qnty1-before as decimal FORMAT "->>>>9.99"
FIELD netto-before as decimal FORMAT "->>>>9.99"
FIELD qnty1-after as decimal FORMAT "->>>>9.99"
FIELD netto-after as decimal FORMAT "->>>>9.99"
FIELD lines as integer
INDEX pi IS UNIQUE primary
grp-code-sheet
INDEX gname
grp-name
INDEX sname
serv-name
.
DEFINE NEW SHARED TEMP-TABLE tincome-3 no-undo
FIELD grp-code-sheet as integer
FIELD doc-code  like ub.trn-doc.doc-code
FIELD supp-name like ub.clients.obj-name FORMAT "X(20)"
FIELD supp-type like ub.clients.obj-type
FIELD supp-code like ub.clients.obj-code FORMAT ">>>>>>>>9"
FIELD qnty1-in as decimal FORMAT "->>>>9.99"
FIELD netto-in as decimal FORMAT "->>>>>>>9.99"
FIELD is-fact as logical
FIELD ii as integer
INDEX pi IS UNIQUE PRIMARY
      grp-code-sheet
      doc-code
INDEX vi IS UNIQUE
      grp-code-sheet
      ii
.
  function valid-density returns logical ( input p-density as decimal, input p-unit-base-cli-eq as logical ) :
    define variable v-answ as logical no-undo .
    if ( p-unit-base-cli-eq = true
         and p-density = 1.0
       )
      or ( p-unit-base-cli-eq = false
           and p-density <> ?
           and p-density > 0.0
           and p-density < 1.0
         )
    then do:
      assign
        v-answ = true
      .
    end.
    else do:
      assign
        v-answ = false
      .
    end.
    return v-answ.
  end function.
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  temp-table temp-cpa-pcep no-undo
field cdpay-code like ub.cash-pay.cdpay-code
field curr-code like ub.cash-pay.cdpay-code
field prefix as character
index pi is primary
cdpay-code
curr-code
.
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable pychk_kk as integer no-undo .
define variable pychk_jj as integer no-undo .
define variable pychk_jjp as integer no-undo .
define variable pychk_jjo as integer no-undo .
define variable pychk_pay-sum as decimal no-undo .
DEFINE VARIABLE pychk_No-EXCH as logical no-undo.
DEFINE VARIABLE pychk_No-EXCH-rubl as logical no-undo.
DEFINE VARIABLE pychk_dop-sump as decimal No-UNDO.
DEFINE VARIABLE pychk_dop-sumg as decimal No-UNDO.
DEFINE VARIABLE pychk_dop-sumk as decimal No-UNDO.
DEFINE VARIABLE pychk_exch as decimal No-UNDO.
DEFINE VARIABLE pychk_exch-rubl as decimal No-UNDO.
define variable pychk_pay-desk like ub.chk-doc.pay-desk no-undo init 0.
DEFINE VARIABLE pychk_classify as logical no-undo  init no.
DEFINE VARIABLE pychk_selectgood as logical no-undo init no.
define variable pychk_rv as integer no-undo .
DEFINE VARIABLE pychk_density AS DECIMAL NO-UNDO.
DEFINE VARIABLE pychk_SHEET2 as logical no-undo.
DEFINE VARIABLE pychk_SHEET3 as logical no-undo.
DEFINE VARIABLE pychk_SHEET4 as logical no-undo.
DEFINE VARIABLE pychk_SHEET8 as logical no-undo.
define variable pychk_doc-code-r as character no-undo .
define variable pychk_doc-code-v as character no-undo .
define variable pychk_doc-code as character no-undo .
define buffer pychk_ret-doc for ub.trn-doc .
define buffer pychk_ras-doc for ub.trn-doc .
define variable pychk_pay-card like ub.chk-pay.pay-card no-undo .
DEFINE BUFFER b-treal-2 for treal-2.
DEFINE BUFFER b-treal-3 for treal-3.
DEFINE BUFFER b-treal-4 for treal-4.
DEFINE BUFFER b2-treal-2 for treal-2.
DEFINE BUFFER b2-treal-3 for treal-3.
DEFINE BUFFER b2-treal-4 for treal-4.
DEFINE BUFFER b3-treal-2 for treal-2.
DEFINE BUFFER b3-treal-3 for treal-3.
DEFINE BUFFER b3-treal-4 for treal-4.
define buffer buf_temp-cpa-pcep for temp-cpa-pcep.
define variable v-host-code as integer no-undo .
define variable v-base-code like ub.sysconf.base-code no-undo .
define variable g#report-num  as integer no-undo .
define variable g#quest-print as logical no-undo initial yes .
define variable g#host-code   as integer no-undo .
define variable fact-order-from as decimal   no-undo .
define variable fact-order-till as decimal   no-undo .
define variable is-petrol       as logical   no-undo .
define variable is-pieces       as logical   no-undo .
define variable j_pl-code       as integer   no-undo .
define variable j_pump-code     as integer   no-undo .
define variable j_nozzle-code   as integer   no-undo .
define variable j_order         as integer   no-undo .
define variable j_chk-count     as integer   no-undo .
define variable j_hour-from     as integer   no-undo .
define variable j_hour-till     as integer   no-undo .
define variable j_tmp-hour-from as integer   no-undo .
define variable j_tmp-hour-till as integer   no-undo .
define variable t_tmp-date      as date      no-undo .
define variable v_chk-code-list as character no-undo .
define variable t_today         as date      no-undo .
define variable j_time          as integer   no-undo .
define variable r_temp-rec-id   as recid     no-undo .
define variable Under_Line      as character no-undo .
define variable j_text-length   as integer   no-undo .
define variable j_column-no     as integer   no-undo .
define variable j_total-length  as integer   no-undo .
define variable v_label-line1   as character no-undo .
define variable v_label-line2   as character no-undo .
define variable v_label-line3   as character no-undo .
define variable v_label-line4   as character no-undo .
define variable v_label-line5   as character no-undo .
define variable v_print-line    as character no-undo .
define variable v_excel-line    as character no-undo .
define variable d_sum-sale      as decimal   no-undo .
define variable d_base-qnty     as decimal   no-undo .
define variable j_indent        as integer   no-undo .
define variable v_text-indent   as character no-undo .
define variable v_excel-indent  as character no-undo .
define variable XL-delim        as character no-undo .
define variable v-del-0         as character no-undo .
define variable v-del-1         as character no-undo .
define variable v-del-2         as character no-undo .
define variable v-short-date    as character no-undo .
define variable XLS-page-num    as integer   no-undo initial 0 .
define variable v_temp-param    as character no-undo .
define variable v_param-type    as character no-undo .
define variable j_row-counter   as integer   no-undo .
define variable v_total-lines   as character no-undo .
define variable j_total-lines   as integer   no-undo .
define variable v-column-list   as character no-undo .
define variable varpump-code    as integer   no-undo.
define variable varnozzle-code  as integer   no-undo.
define variable pay-sum as decimal no-undo.
define variable v-density as decimal no-undo.
define variable v-curr-r-b as character no-undo .
define variable v-line-num as integer no-undo .
define variable v-rv as integer no-undo .
define variable vari as integer no-undo.
define variable v-user-action as character no-undo .
define variable v-printed as logical   no-undo .
define variable p-by-pay-card-prefix as logical no-undo init no.
define buffer buf_inkas for ub.inkas.
assign
x-SelectGood  = 1
pychk_SHEET2  = yes
.
define temp-table tt_line no-undo
  field artic       like ub.goods.artic
  field prod-type   like ub.goods.prod-type
  field prod-code   like ub.goods.prod-code
  field gds-code    like ub.goods.gds-code
  field gds-name    like ub.goods.gds-name
  field pump-code   like ub.pump.pump-code
  field nozzle-code like ub.nozzle.nozzle-code
  field chk-count   as   integer
  field base-qnty   like ub.doc-line.fact-qnty
  field cli-qnty    like ub.doc-line.fact-qnty
  field sum-sale    like ub.trn-doc.tot-calc
  field pay-code    like ub.cash-pay.cdpay-code
  field pay-name    like ub.cash-pay.obj-name
  field curr-code   like ub.cash-pay.curr-code
  field order       as   integer
  field chk-date    like ub.chk-doc.chk-date
  field chk-time    like ub.chk-doc.chk-time
  field chk-code    like ub.chk-doc.doc-code
  field chk-num     as character
  field pass-gds    as character
  field doc-num2    like ub.chk-doc.doc-num2
  index upi         is   unique primary order
  index ui1         is   unique gds-code pump-code nozzle-code pay-code curr-code chk-date chk-time
  index uic         chk-code gds-code    pay-code curr-code
  index i1          chk-date chk-time
.
define buffer bf_shift-obj_from for ub.shift-obj      .
define buffer bf_shift-obj_till for ub.shift-obj      .
define buffer bf_shift-obj      for ub.shift-obj      .
define buffer bf_chk-gds        for ub.chk-gds        .
define buffer bf_chk-pay        for ub.chk-pay        .
define buffer bf_bar-code       for ub.bar-code       .
define buffer bf_goods          for ub.goods          .
define buffer bf_pl-gds-pump    for ub.pl-gds-pump    .
define buffer bf_pl-pump-nozzle for ub.pl-pump-nozzle .
define buffer bf_place          for ub.place          .
define buffer bf_cash-pay       for ub.cash-pay       .
define buffer bf_line           for tt_line           .
define buffer buf_bar-code      for ub.bar-code       .
define buffer buf_cash-pay      for ub.cash-pay       .
define stream text_out .
FUNCTION Centering RETURNS CHARACTER ( INPUT i-string AS CHARACTER, INPUT i-length AS INTEGER ) :
  DEFINE VARIABLE v-outstring AS CHARACTER NO-UNDO.
  RUN get-centre-string IN THIS-PROCEDURE ( INPUT i-string, INPUT i-length, OUTPUT v-outstring ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN i-string ELSE v-outstring ).
END FUNCTION.
PROCEDURE get-centre-string :
  DEFINE  INPUT PARAMETER p-instring  AS CHARACTER NO-UNDO.
  DEFINE  INPUT PARAMETER p-length    AS INTEGER   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-outstring AS CHARACTER NO-UNDO INITIAL "":U.
  DEFINE VARIABLE j-format AS INTEGER NO-UNDO.
  DEFINE VARIABLE j-left   AS INTEGER NO-UNDO.
  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN p-instring = TRIM(   p-instring )
           j-format   = LENGTH( p-instring ).
    IF           j-format > p-length THEN DO:
      ASSIGN p-outstring = SUBSTRING( p-instring, 1, p-length ).
    END. ELSE IF j-format < p-length THEN DO:
      ASSIGN j-left      = INTEGER( ( p-length - ( j-format + 1 ) ) * 0.5 )
             p-outstring = FILL( " ":U, j-left ) + p-instring + FILL( " ":U, p-length - ( j-left + j-format ) ).
    END.                             ELSE DO:
      ASSIGN p-outstring = p-instring.
    END.
  END.
END PROCEDURE.
FUNCTION ShiftRight RETURNS CHARACTER ( INPUT i-string AS CHARACTER, INPUT i-length AS INTEGER ) :
  DEFINE VARIABLE v-outstring AS CHARACTER NO-UNDO.
  RUN get-right-string IN THIS-PROCEDURE ( INPUT i-string, INPUT i-length, OUTPUT v-outstring ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN i-string ELSE v-outstring ).
END FUNCTION.
PROCEDURE get-right-string :
  DEFINE  INPUT PARAMETER p-instring  AS CHARACTER NO-UNDO.
  DEFINE  INPUT PARAMETER p-length    AS INTEGER   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-outstring AS CHARACTER NO-UNDO INITIAL "":U.
  DEFINE VARIABLE j-format AS INTEGER NO-UNDO.
  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN p-instring = TRIM(   p-instring )
           j-format   = LENGTH( p-instring ).
    IF           j-format > p-length THEN DO:
      ASSIGN p-outstring = SUBSTRING( p-instring, 1, p-length ).
    END. ELSE IF j-format < p-length THEN DO:
      ASSIGN p-outstring = FILL( " ":U, p-length - j-format ) + p-instring.
    END.                             ELSE DO:
      ASSIGN p-outstring = p-instring.
    END.
  END.
END PROCEDURE.
FUNCTION Sparse RETURNS CHARACTER ( INPUT p-instring AS CHARACTER ) :
  DEFINE VARIABLE v-outstring AS CHARACTER NO-UNDO.
  RUN get-sparsed-string IN THIS-PROCEDURE ( INPUT p-instring, OUTPUT v-outstring ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN p-instring ELSE v-outstring ).
END FUNCTION.
PROCEDURE get-sparsed-string :
  DEFINE  INPUT PARAMETER p-instring  AS CHARACTER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-outstring AS CHARACTER NO-UNDO INITIAL "":U.
  DEFINE VARIABLE jj AS INTEGER NO-UNDO.
  DO ON ERROR UNDO, RETURN ERROR :
    DO jj = 1 TO LENGTH( p-instring ) :
      ASSIGN p-outstring = p-outstring + ( IF p-outstring = "":U THEN "":U ELSE " ":U ) + SUBSTRING( p-instring, jj, 1 ).
    END.
    ASSIGN p-outstring = CAPS( TRIM( p-outstring ) ).
  END.
END PROCEDURE.
form header
  Centering( Sparse( "Почасовая статистика продаж ТРК с детализацией по пистолетам" )
                          , j_total-length ) format "x(198)":U at 1 skip( 1 )
  ShiftRight( substitute( "Дата печати: &1, время: &2.   Страница: &3."
                        , string( t_today,                 "99.99.9999":U )
                        , string( j_time,                  "HH:MM:SS":U   )
                        , string( page-number( text_out ), ">>>9":U        )
                        ) , j_total-length ) format "x(198)":U at 1 skip( 0 )
  v_label-line1                              format "x(198)":U at 1 skip( 0 )
  v_label-line2                              format "x(198)":U at 1 skip( 0 )
  v_label-line3                              format "x(198)":U at 1 skip( 0 )
  v_label-line4                              format "x(198)":U at 1 skip( 0 )
  v_label-line5                              format "x(198)":U at 1 skip( 0 )
with frame Top_Page width 198 page-top no-labels no-box use-text stream-io no-underline .
form header                                 skip( 1 )
  Under_Line format "x(198)":U   at  1 skip( 0 )
  "Продолжение на следующей странице" at 30 skip( 0 )
with frame Bottom_Page width 198 page-bottom no-labels no-box use-text stream-io no-underline .
do
on error undo, return error return-value
:
  run WaitFram-Show   in this-procedure
    (
      input 'Подождите ...'
    ) .
  run get-report-num  in parparentproc
    (
      output g#report-num
    ) .
  run get-quest-print in parparentproc
    (
      output g#quest-print
    ) .
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input v-cntxt-obj-type
  ,input v-cntxt-obj-code
  ,input 'report-firm':U
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
      if thbjattr_thbj-attr.prop-code = 'XL-delim'  then v_temp-param   = thbjattr_thbj-attr.property-value-character.
  end.
  IF v_temp-param = "" then XL-delim = ";".
  else XL-delim = v_temp-param.
  run gbl/getlocal.p
    ( output v-del-0
    , output v-del-1
    , output v-del-2
    , output v-short-date
    ) no-error .
  if error-status :error
  then do:
    assign
      v-del-1 = " ":U
    .
  end.
  assign
    XLS-page-num = XLS-page-num + 1
  .
  for each SheetF where
           SheetF.Sheet-Num > XLS-page-num
  :
    delete SheetF .
  end.
  find first SheetF where
             SheetF.Sheet-Num = XLS-page-num no-error .
  if not available SheetF
  then do:
    create SheetF .
    assign
      SheetF.Sheet-Num = XLS-page-num
    .
  end.
  assign
    SheetF.MergeCellsH        = "":U
    SheetF.MergeCellsV        = "":U
    SheetF.Excel-Column-Lable = "":U
    SheetF.ColFormat          = "":U
    SheetF.Sizes              = "":U
    Sheetf.Bas-File           = "ptrlhour.bas"
    Sheetf.Bas-Param-Add      = yes
  .
  run get-fo-range in this-procedure
    (
       input p-obj-type
    ,  input p-obj-code
    ,  input x-Date-Start
    ,  input x-Date-End
    ,  input x-Shift-Start
    ,  input x-Shift-End
    ,  input x-TOG-Shift
    , output fact-order-from
    , output fact-order-till
    ) no-error .
  if error-status :error
  then do:
    message return-value skip( 0 )
            error-status :get-message( 1 ) skip( 0 )
            error-status :get-message( 2 ) skip( 0 )
    view-as alert-box error .
    return error .
  end.
  if x-TOG-Shift = yes
  then do:
    find first bf_shift-obj_from no-lock where
               bf_shift-obj_from.obj-type    = p-obj-type     and
               bf_shift-obj_from.obj-code    = p-obj-code     and
             ( bf_shift-obj_from.shift-date  = x-Date-Start   and
               bf_shift-obj_from.shift-num  >= x-Shift-Start  or
               bf_shift-obj_from.shift-date >  x-Date-Start ) no-error .
    if not available bf_shift-obj_from
    then do:
      message "Не найдена смена начала отчета." skip( 0 )
              "Дата:"    string( x-Date-Start, "99/99/9999":U ) skip( 0 )
              "Порядок:" x-Shift-Start skip( 1 )
      view-as alert-box error .
      return error .
    end.
    find last bf_shift-obj_till no-lock where
              bf_shift-obj_till.obj-type    = p-obj-type   and
              bf_shift-obj_till.obj-code    = p-obj-code   and
            ( bf_shift-obj_till.shift-date  = x-Date-End   and
              bf_shift-obj_till.shift-num  <= x-Shift-End  or
              bf_shift-obj_till.shift-date <  x-Date-End ) no-error .
    if not available bf_shift-obj_from
    then do:
      message "Не найдена смена окончания отчета." skip( 0 )
              "Дата:"    string( x-Date-End, "99/99/9999":U ) skip( 0 )
              "Порядок:" x-Shift-Start skip( 1 )
      view-as alert-box error .
      return error .
    end.
  end.
  else do:
    find first bf_shift-obj_from no-lock where
               bf_shift-obj_from.obj-type    = p-obj-type   and
               bf_shift-obj_from.obj-code    = p-obj-code   and
               bf_shift-obj_from.shift-date >= x-Date-Start no-error .
    if not available bf_shift-obj_from
    then do:
      message "Не найдена смена начала отчета." skip( 0 )
              "Дата:" string( x-Date-Start, "99/99/9999":U ) skip( 1 )
      view-as alert-box error .
      return error .
    end.
    find last bf_shift-obj_till no-lock where
              bf_shift-obj_till.obj-type    = p-obj-type and
              bf_shift-obj_till.obj-code    = p-obj-code and
              bf_shift-obj_till.shift-date <= x-Date-End no-error .
    if not available bf_shift-obj_from
    then do:
      message "Не найдена смена окончания отчета." skip( 0 )
              "Дата:" string( x-Date-End, "99/99/9999":U ) skip( 1 )
      view-as alert-box error .
      return error .
    end.
  end.
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
define variable vss-include-info39 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-host-code
  ,output v-base-code
  )  .
  if v-curr-r-b = 'base':U or
  v-base-code = 0 then pychk_NO-exch = yes.
  else pychk_No-exch = no.
  if v-curr-r-b = 'rubl':U or
  v-base-code = 0 then pychk_NO-exch-rubl = yes.
  else pychk_No-exch-rubl = no.
  for each bf_shift-obj no-lock where
           bf_shift-obj.obj-type    = p-obj-type                   and
           bf_shift-obj.obj-code    = p-obj-code                   and
           bf_shift-obj.shift-date >= bf_shift-obj_from.shift-date and
           bf_shift-obj.shift-date <= bf_shift-obj_till.shift-date
  :
    if bf_shift-obj.shift-date = bf_shift-obj_from.shift-date and
       bf_shift-obj.shift-num  < bf_shift-obj_from.shift-num  or
       bf_shift-obj.shift-date = bf_shift-obj_till.shift-date and
       bf_shift-obj.shift-num  > bf_shift-obj_till.shift-num
    then do:
      next .
    end.
    _chk-doc:
    for each chk-doc no-lock where
             chk-doc.obj-type    = bf_shift-obj.obj-type   and
             chk-doc.obj-code    = bf_shift-obj.obj-code   and
             chk-doc.shift-date  = bf_shift-obj.shift-date and
             chk-doc.shift-num   = bf_shift-obj.shift-num  and
             chk-doc.out-code   <> ? :
      find first buf_inkas where buf_inkas.inkas-code = chk-doc.out-code no-lock no-error.
      if not available buf_inkas then do:
        next.
      end.
      if lookup( string( chk-doc.chk-type ), '14,15,16,36,8,101,106,108,11,12,13,40,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U ) > 0
      then do:
        next _chk-doc .
      end.
      for each treal-2 :
        delete treal-2.
      end.
      for each treal-vat :
        delete treal-vat.
      end.
      for each chk-pay no-lock where
               chk-pay.doc-code = chk-doc.doc-code
        BREAK
        BY CHK-pay.DOC-CODE
        BY CHK-pay.LINE-NUM:
define variable vss-include-info40 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if first-of(CHK-pay.DOC-CODE) THEN Do:
  assign
  pychk_kk = 0
  pychk_jj = 1
  pychk_jjp = 0
  pychk_jjo = 0
  pychk_pay-sum = chk-doc.netto
  pychk_dop-sumg = 0
  .
  if p-by-pay-card-prefix  then do:
    find first buf_temp-cpa-pcep no-lock where
              buf_temp-cpa-pcep.cdpay-code = ub.chk-pay.pay-code
          AND buf_temp-cpa-pcep.curr-code = ub.chk-pay.curr-code
          AND ub.chk-pay.pay-card begins buf_temp-cpa-pcep.prefix no-error .
    if available buf_temp-cpa-pcep then
    assign
    pychk_pay-card = buf_temp-cpa-pcep.prefix
    .
    else
    assign
    pychk_pay-card = 'other':U
    .
  end.
  else do:
    assign
    pychk_pay-card = '':U
    .
  end.
 if ub.chk-doc.netto < 0 then do:
        if pychk_doc-code-r <> ub.chk-doc.out-code
        then do:
          find first pychk_ras-doc no-lock
            where pychk_ras-doc.doc-code = ub.chk-doc.out-code
            no-error .
          if not available pychk_ras-doc then do:
            message
              substitute("Отсутствует документ расхода по чеку &1"
                        , ub.chk-doc.doc-code
                        )   skip
              "ЭКСПОРТ НЕ МОЖЕТ БЫТЬ ОСУЩЕСТВЛЕН" SKIP
              view-as alert-box error .
            return error .
          end.
          pychk_doc-code-r = pychk_ras-doc.doc-code.
          find first pychk_ret-doc no-lock
            where pychk_ret-doc.doc-code = pychk_ras-doc.out-code
            no-error .
          if not available pychk_ret-doc then do:
            message
              substitute("Отсутствует документ возврата по чеку &1"
                        , ub.chk-doc.doc-code
                        )   skip
              "ЭКСПОРТ НЕ МОЖЕТ БЫТЬ ОСУЩЕСТВЛЕН" SKIP
              view-as alert-box error .
            return error .
          end.
          pychk_doc-code-v = pychk_ret-doc.doc-code.
        end.
        assign
          pychk_doc-code = pychk_doc-code-v
        .
      end.
      else do:
        assign
          pychk_doc-code = ub.chk-doc.out-code
        .
      end.
  FOR EACH ub.chk-gds No-LOCK WHERE
           ub.chk-gds.doc-code = ub.chk-pay.doc-code
  BY ub.chk-gds.line-num:
  pychk_density = 0.
  if ub.chk-gds.write-off-code <> ?
  and ub.chk-gds.write-off-code > 0 then NEXT.
    if chk-gds.pump <> 0 then do:
      find first ub.bar-code no-lock where ub.bar-code.b-code = ub.chk-gds.b-code    no-error.
      find first ub.goods    no-lock where ub.goods.gds-code  = ub.bar-code.gds-code no-error.
      find first ub.doc-line no-lock where
                ub.doc-line.doc-code  = pychk_doc-code and
                ub.doc-line.artic     = ub.goods.artic      and
                ub.doc-line.prod-type = ub.goods.prod-type  and
                ub.doc-line.prod-code = ub.goods.prod-code  no-error.
      assign pychk_density = ( if available ub.doc-line then ub.doc-line.fact-density else 0 ).
      find first temp-chk-gds where
                temp-chk-gds.b-code = chk-gds.b-code
           AND  temp-chk-gds.doc-code = chk-gds.doc-code
           and temp-chk-gds.pump = chk-gds.pump
           and temp-chk-gds.nozzle-code = (if chk-gds.nozzle-code = ? then 0 else chk-gds.nozzle-code)
           and temp-chk-gds.rec-type = 1 no-error.
      if available temp-chk-gds then do:
        assign
        temp-chk-gds.qnty = temp-chk-gds.qnty  + chk-gds.doc-qnty
        temp-chk-gds.sum  = temp-chk-gds.sum  + chk-gds.doc-qnty * (chk-gds.price-base - chk-gds.discnt + chk-gds.price-service)
        temp-chk-gds.sum-change = temp-chk-gds.sum
        temp-chk-gds.qnty2 = temp-chk-gds.qnty2 + ub.chk-gds.doc-qnty * pychk_density
        .
      end.
      else do:
        find first temp-chk-gds use-index ijj where temp-chk-gds.jj_ = pychk_jj no-error.
        if not available temp-chk-gds then do:
          create temp-chk-gds.
          assign
          temp-chk-gds.jj_ = pychk_jj
          pychk_jj = pychk_jj + 1
          temp-chk-gds.qnty2 = 0
          temp-chk-gds.qnty = 0
          temp-chk-gds.sum = 0
          temp-chk-gds.sum-change = temp-chk-gds.sum
          .
        end.
        else do:
          assign
          temp-chk-gds.qnty2 = 0
          temp-chk-gds.qnty = 0
          temp-chk-gds.sum = 0
          temp-chk-gds.sum-change = temp-chk-gds.sum
          pychk_jj = pychk_jj + 1
          .
        end.
        ASSIGN
        temp-chk-gds.doc-code = chk-gds.doc-code
        temp-chk-gds.b-code = chk-gds.b-code
        temp-chk-gds.rec-type = 1
        temp-chk-gds.gds-type = 1
        temp-chk-gds.pump = chk-gds.pump
        temp-chk-gds.nozzle-code = (if chk-gds.nozzle-code = ? then 0 else chk-gds.nozzle-code)
        temp-chk-gds.qnty = temp-chk-gds.qnty  + chk-gds.doc-qnty
        temp-chk-gds.sum  = temp-chk-gds.sum  + chk-gds.doc-qnty * (chk-gds.price-base - chk-gds.discnt + chk-gds.price-service)
        temp-chk-gds.sum-change = temp-chk-gds.sum
        temp-chk-gds.qnty2 = temp-chk-gds.qnty2 + ub.chk-gds.doc-qnty * pychk_density
        pychk_jjp = pychk_jjp + 1
        temp-chk-gds.jjp_  = pychk_jjp
        temp-chk-gds.jjo_  = 0
        .
      end.
    end.
    else do:
      find first temp-chk-gds where
                temp-chk-gds.b-code = chk-gds.b-code
           AND  temp-chk-gds.doc-code = chk-gds.doc-code
           and temp-chk-gds.pump = chk-gds.pump
           and temp-chk-gds.nozzle-code = (if chk-gds.nozzle-code = ? then 0 else chk-gds.nozzle-code)
           and temp-chk-gds.rec-type = 0  no-error.
      IF AVAILABLE TEMP-CHK-GDS THEN DO:
        assign
        temp-chk-gds.qnty = temp-chk-gds.qnty  + chk-gds.DOC-qnty
        temp-chk-gds.sum  = temp-chk-gds.sum  + chk-gds.doc-qnty * (chk-gds.price-base - chk-gds.discnt + chk-gds.price-service)
        temp-chk-gds.qnty2 = temp-chk-gds.qnty2 + chk-gds.doc-qnty * pychk_density
        temp-chk-gds.sum-change = temp-chk-gds.sum
        .
      end.
      else do:
        find first temp-chk-gds where temp-chk-gds.jj_ = pychk_jj use-index ijj no-error.
        if not available temp-chk-gds then do:
          create temp-chk-gds.
          assign
          temp-chk-gds.jj_ = pychk_jj
          temp-chk-gds.qnty2 = 0
          temp-chk-gds.qnty = 0
          temp-chk-gds.sum = 0
          temp-chk-gds.sum-change = temp-chk-gds.sum
          pychk_jj = pychk_jj + 1
          .
        end.
        else do:
          assign
          pychk_jj = pychk_jj + 1
          temp-chk-gds.qnty2 = 0
          temp-chk-gds.qnty = 0
          temp-chk-gds.sum = 0
          temp-chk-gds.sum-change = temp-chk-gds.sum
          .
        end.
        ASSIGN
        temp-chk-gds.doc-code = chk-gds.doc-code
        temp-chk-gds.b-code = chk-gds.b-code
        temp-chk-gds.qnty = temp-chk-gds.qnty  + chk-gds.DOC-qnty
        temp-chk-gds.sum  = temp-chk-gds.sum  + chk-gds.doc-qnty * (chk-gds.price-base - chk-gds.discnt + chk-gds.price-service)
        temp-chk-gds.qnty2 = temp-chk-gds.qnty2 + chk-gds.doc-qnty * pychk_density
        temp-chk-gds.sum-change = temp-chk-gds.sum
        temp-chk-gds.rec-type = 0
        temp-chk-gds.pump = 0
        temp-chk-gds.nozzle-code = 0
        temp-chk-gds.gds-type =
                                  (if chk-doc.office = 'у':U then 3 else 2)
        pychk_jjo = pychk_jjo + 1
        temp-chk-gds.jjp_  = 0
        temp-chk-gds.jjo_  = pychk_jjo
        .
      end.
    end.
  END.
end.
FIND FIRST ub.cash-pay No-LOCK WHERE
          ub.cash-pay.cdpay-code = ub.chk-pay.pay-code AND
          ub.cash-pay.curr-code = ub.chk-pay.curr-code No-ERROR.
if available ub.cash-pay then do:
  find first temp-chk-pay where
          temp-chk-pay.line-num = chk-pay.line-num
      AND  temp-chk-pay.doc-code = chk-pay.doc-code  no-error.
  find first temp-chk-pay use-index pi where
          temp-chk-pay.line-num = chk-pay.line-num no-error.
  if not available temp-chk-pay then do:
    create temp-chk-pay.
  end.
  buffer-copy chk-pay to temp-chk-pay
  assign
  temp-chk-pay.pet-good = integer(cash-pay.atr64) * 2 + integer(cash-pay.is-cash)
  temp-chk-pay.obj-name = cash-pay.obj-name
  temp-chk-pay.is-cash  = cash-pay.is-cash
  temp-chk-pay.register = cash-pay.register
  .
end.
if last-of(chk-pay.doc-code) then do:
  for each temp-chk-pay where
          temp-chk-pay.doc-code = chk-pay.doc-code
  by temp-chk-pay.pet-good descending
  by temp-chk-pay.line-num:
    assign
    pychk_dop-sump = (if v-curr-r-b = 'rubl':U then temp-chk-pay.tot-rubl else temp-chk-pay.tot-base)
    pychk_exch = if pychk_No-exch then 1 else temp-chk-pay.tot-rubl / temp-chk-pay.tot-base
    pychk_exch-rubl = if pychk_No-exch-rubl then 1 else temp-chk-pay.tot-rubl / temp-chk-pay.tot-base
    .
    _repeat:
    REPEAT WHILE  abs(pychk_dop-sump) > 0 :
      if pychk_dop-sumg = 0 then do:
        assign
        pychk_kk = pychk_kk + 1
        .
        if pychk_kk >= pychk_jj then LEAVE _repeat.
        if pychk_kk <= pychk_jjp then
        find first temp-chk-gds where
                  temp-chk-gds.doc-code = chk-doc.doc-code
            AND  temp-chk-gds.jjp_ = pychk_kk no-error .
        else
        find first temp-chk-gds where
                  temp-chk-gds.doc-code = chk-doc.doc-code
            AND  temp-chk-gds.jjo_ = pychk_kk - pychk_jjp no-error .
        if not available temp-chk-gds or temp-chk-gds.sum = 0 then do:
          NEXT _repeat.
        end.
        assign
        pychk_dop-sumg = temp-chk-gds.sum
        .
      end.
      assign
      pychk_dop-sumk = min(abs(pychk_dop-sumg), abs(pychk_dop-sump))  * (if pychk_dop-sump > 0 then 1 else -1 )
      pychk_pay-sum = pychk_pay-sum - pychk_dop-sumk
      pychk_dop-sump = pychk_dop-sump - pychk_dop-sumk
      pychk_dop-sumg = pychk_dop-sumg - pychk_dop-sumk
      .
      FIND FIRST ub.bar-code No-LOCK WHERE
                ub.bar-code.b-code =  temp-chk-gds.b-code No-ERROR.
      IF NOT AVAIL ub.bar-code then NEXT _repeat.
      CASE temp-chk-gds.gds-type:
        WHEN 1   then do:
          if pychk_sheet2 then do:
            if p-by-pay-card-prefix
            and pychk_pay-card <> "other"
            then do:
              FIND FIRST b2-treal-2 No-LOCK WHERE
                        b2-treal-2.gds-code = ub.bar-code.gds-code AND
                        b2-treal-2.cpay-code = temp-chk-pay.pay-code AND
                        b2-treal-2.curr-code = temp-chk-pay.curr-code AND
                        b2-treal-2.is-pay = yes
                        AND b2-treal-2.pay-desk = pychk_pay-desk
                        AND b2-treal-2.prefix = pychk_pay-card
                   AND b2-treal-2.pump = temp-chk-gds.pump
                   AND b2-treal-2.nozzle-code = temp-chk-gds.nozzle-code
                        No-ERROR.
              IF NOT AVAIL  b2-treal-2 then do:
                FIND last b3-treal-2 No-LOCK WHERE
                          b3-treal-2.gds-code = ub.bar-code.gds-code use-index vi No-ERROR.
                run create-b2-treal-2 in this-procedure (
                                INPUT ub.bar-code.gds-code,
                                INPUT temp-chk-pay.pay-code,
                                INPUT temp-chk-pay.curr-code,
                                INPUT 0,
                                INPUT 0,
                                INPUT 0,
                                INPUT temp-chk-pay.obj-name,
                                INPUT yes,
                                INPUT (if avail b3-treal-2
                                      then b3-treal-2.ii + 1
                                      else 1)
                                ,INPUT  pychk_pay-desk
                                ,INPUT pychk_pay-card
                                ,input temp-chk-gds.pump
                                ,input temp-chk-gds.nozzle-code
                                ) no-error.
              END.
              assign
              b2-treal-2.netto = b2-treal-2.netto + pychk_dop-sumk / pychk_exch
              b2-treal-2.qnty1 = b2-treal-2.qnty1 + temp-chk-gds.qnty * (pychk_dop-sumk / temp-chk-gds.sum)
              b2-treal-2.qnty2 = b2-treal-2.qnty2 + temp-chk-gds.qnty2 * ( pychk_dop-sumk / temp-chk-gds.sum )
              b2-treal-2.netto-rubl = b2-treal-2.netto-rubl + pychk_dop-sumk * pychk_exch-rubl
              .
            end.
            FIND FIRST treal-2 No-LOCK WHERE
                      treal-2.gds-code = ub.bar-code.gds-code AND
                      treal-2.cpay-code = temp-chk-pay.pay-code AND
                      treal-2.curr-code = temp-chk-pay.curr-code AND
                      treal-2.is-pay = yes
                      AND treal-2.pay-desk = pychk_pay-desk
                      AND treal-2.prefix = ''
                      AND treal-2.pump = temp-chk-gds.pump
                      AND treal-2.nozzle-code = temp-chk-gds.nozzle-code
                      No-ERROR.
            IF NOT AVAIL treal-2 then do:
              FIND last b-treal-2 No-LOCK WHERE
                        b-treal-2.gds-code = ub.bar-code.gds-code use-index vi No-ERROR.
              run create-treal-2 in this-procedure (
                              INPUT ub.bar-code.gds-code,
                              INPUT temp-chk-pay.pay-code,
                              INPUT temp-chk-pay.curr-code,
                              INPUT 0,
                              INPUT 0,
                              INPUT 0,
                              INPUT temp-chk-pay.obj-name,
                              INPUT yes,
                              INPUT (if avail b-treal-2
                                    then b-treal-2.ii + 1
                                    else 1)
                              , INPUT  pychk_pay-desk
                              ,INPUT '':U
                              ,input temp-chk-gds.pump
                              ,input temp-chk-gds.nozzle-code
                              ) no-error.
            END.
            assign
            treal-2.netto = treal-2.netto + pychk_dop-sumk / pychk_exch
            treal-2.qnty1 = treal-2.qnty1 + temp-chk-gds.qnty * (pychk_dop-sumk / temp-chk-gds.sum)
            treal-2.qnty2 = treal-2.qnty2 + temp-chk-gds.qnty2 * ( pychk_dop-sumk / temp-chk-gds.sum )
            treal-2.netto-rubl = treal-2.netto-rubl + pychk_dop-sumk * pychk_exch-rubl
            .
          end.
        END.
        WHEN 2   then do:
                if pychk_sheet3 then do:
            FIND FIRST ub.goods No-LOCK WHERE
                        ub.goods.gds-code = ub.bar-code.gds-code No-ERROR.
            IF NOT AVAIL ub.goods then NEXT _repeat.
            if p-by-pay-card-prefix
            and pychk_pay-card <> "other"
            then do:
              FIND FIRST b2-treal-3 No-LOCK WHERE
                        b2-treal-3.gds-code = ub.goods.gds-code AND
                        b2-treal-3.cpay-code = temp-chk-pay.pay-code AND
                        b2-treal-3.curr-code = temp-chk-pay.curr-code
                        AND b2-treal-3.pay-desk = pychk_pay-desk
                        AND b2-treal-3.prefix = pychk_pay-card
                        No-ERROR.
              IF NOT AVAIL b2-treal-3 then do:
                FIND last b3-treal-3 No-LOCK WHERE
                          b3-treal-3.gds-code = ub.goods.gds-code use-index vi No-ERROR.
                run create-g-b2-treal-3 in this-procedure (
                              INPUT ub.goods.gds-code,
                              INPUT temp-chk-pay.pay-code,
                              INPUT temp-chk-pay.curr-code,
                              INPUT 0,
                              INPUT 0,
                              INPUT temp-chk-pay.obj-name,
                              INPUT yes,
                              INPUT (if avail b-treal-3
                                      then b3-treal-3.ii + 1
                                      else 1)
                            , INPUT  pychk_pay-desk
                            , INPUT  pychk_pay-card
                                    ) no-error.
              END.
              assign
              b2-treal-3.netto = b2-treal-3.netto + pychk_dop-sumk / pychk_exch
              b2-treal-3.qnty1 = b2-treal-3.qnty1 + temp-chk-gds.qnty * (pychk_dop-sumk / temp-chk-gds.sum)
              b2-treal-3.netto-rubl = b2-treal-3.netto-rubl + pychk_dop-sumk * pychk_exch-rubl
              .
            end.
            FIND FIRST treal-3 No-LOCK WHERE
                      treal-3.gds-code = ub.goods.gds-code AND
                      treal-3.cpay-code = temp-chk-pay.pay-code AND
                      treal-3.curr-code = temp-chk-pay.curr-code
                      AND treal-3.pay-desk = pychk_pay-desk
                      AND treal-3.prefix = '':U
                      No-ERROR.
            IF NOT AVAIL treal-3 then do:
              FIND last b-treal-3 No-LOCK WHERE
                        b-treal-3.gds-code = ub.goods.gds-code use-index vi No-ERROR.
              run create-g-treal-3  in this-procedure (
                            INPUT ub.goods.gds-code,
                            INPUT temp-chk-pay.pay-code,
                            INPUT temp-chk-pay.curr-code,
                            INPUT 0,
                            INPUT 0,
                            INPUT temp-chk-pay.obj-name,
                            INPUT yes,
                            INPUT (if avail b-treal-3
                                    then b-treal-3.ii + 1
                                    else 1)
                          , INPUT  pychk_pay-desk
                          , INPUT  '':U
                                  ) no-error.
            END.
            assign
            treal-3.netto = treal-3.netto + pychk_dop-sumk / pychk_exch
            treal-3.qnty1 = treal-3.qnty1 + temp-chk-gds.qnty * (pychk_dop-sumk / temp-chk-gds.sum)
            treal-3.netto-rubl = treal-3.netto-rubl + pychk_dop-sumk * pychk_exch-rubl
            .
          END.
        END.
        WHEN 3  then do:
          if pychk_sheet4 then do:
            if p-by-pay-card-prefix
            and pychk_pay-card <> "other"
            then do:
              FIND FIRST b2-treal-4 No-LOCK WHERE
                        b2-treal-4.gds-code = ub.bar-code.gds-code AND
                        b2-treal-4.cpay-code = temp-chk-pay.pay-code AND
                        b2-treal-4.curr-code = temp-chk-pay.curr-code AND
                        b2-treal-4.is-pay = yes
                        AND b2-treal-4.pay-desk = pychk_pay-desk
                        AND b2-treal-4.prefix = pychk_pay-card
                        No-ERROR.
              IF NOT AVAIL b2-treal-4 then do:
                FIND last b3-treal-4 No-LOCK WHERE
                          b3-treal-4.gds-code = ub.bar-code.gds-code use-index vi No-ERROR.
                run create-b2-treal-4 in this-procedure (
                                INPUT ub.bar-code.gds-code,
                                INPUT temp-chk-pay.pay-code,
                                INPUT temp-chk-pay.curr-code,
                                INPUT 0,
                                INPUT 0,
                                INPUT temp-chk-pay.obj-name,
                                INPUT yes,
                                INPUT (if avail b3-treal-4
                                      then b3-treal-4.ii + 1
                                      else 1)
                                , INPUT  pychk_pay-desk
                                , INPUT pychk_pay-card
                                ) no-error.
              END.
              assign
              b2-treal-4.netto = b2-treal-4.netto + pychk_dop-sumk / pychk_exch
              b2-treal-4.qnty1 = b2-treal-4.qnty1 + temp-chk-gds.qnty * (pychk_dop-sumk / temp-chk-gds.sum)
              b2-treal-4.netto-rubl = b2-treal-4.netto-rubl + pychk_dop-sumk * pychk_exch-rubl
              .
            end.
            FIND FIRST treal-4 No-LOCK WHERE
                      treal-4.gds-code = ub.bar-code.gds-code AND
                      treal-4.cpay-code = temp-chk-pay.pay-code AND
                      treal-4.curr-code = temp-chk-pay.curr-code AND
                      treal-4.is-pay = yes
                      AND treal-4.pay-desk = pychk_pay-desk
                      AND treal-4.prefix = '':U
                      No-ERROR.
            IF NOT AVAIL treal-4 then do:
              FIND last b-treal-4 No-LOCK WHERE
                        b-treal-4.gds-code = ub.bar-code.gds-code use-index vi No-ERROR.
              run create-treal-4  in this-procedure (
                              INPUT ub.bar-code.gds-code,
                              INPUT temp-chk-pay.pay-code,
                              INPUT temp-chk-pay.curr-code,
                              INPUT 0,
                              INPUT 0,
                              INPUT temp-chk-pay.obj-name,
                              INPUT yes,
                              INPUT (if avail b-treal-4
                                    then b-treal-4.ii + 1
                                    else 1)
                              , INPUT  pychk_pay-desk
                              , INPUT '':U
                              ) no-error.
            END.
            assign
            treal-4.netto = treal-4.netto + pychk_dop-sumk / pychk_exch
            treal-4.qnty1 = treal-4.qnty1 + temp-chk-gds.qnty * (pychk_dop-sumk / temp-chk-gds.sum)
            treal-4.netto-rubl = treal-4.netto-rubl + pychk_dop-sumk * pychk_exch-rubl
            .
            END.
        END.
      END CASE.
      if pychk_dop-sumg <= 0 then do:
        assign
        pychk_kk = pychk_kk + 1.
        if pychk_kk >= pychk_jj then LEAVE _repeat.
        if pychk_kk <= pychk_jjp then do:
          find first temp-chk-gds where
                    temp-chk-gds.doc-code = chk-doc.doc-code
              AND  temp-chk-gds.jjp_ = pychk_kk no-error .
        end.
        else do:
          find first temp-chk-gds where
                    temp-chk-gds.doc-code = chk-doc.doc-code
              AND  temp-chk-gds.jjo_ = pychk_kk - pychk_jjp no-error .
          if not available temp-chk-gds then do:
            LEAVE _repeat.
          end.
        end.
        pychk_dop-sumg = temp-chk-gds.sum.
        pychk_dop-sumg = temp-chk-gds.sum.
      end.
    END.
  end.
output close.
end.
      end.
      for each treal-2 :
        find first bf_goods no-lock where
                   bf_goods.gds-code = treal-2.gds-code .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input bf_goods.artic
  ,  input bf_goods.prod-type
  ,  input bf_goods.prod-code
  , output is-petrol
  , output is-pieces
  ) no-error.
        if error-status :error or
           is-petrol <> yes    or
           is-pieces <> no
        then do:
          next .
        end.
        assign
          j_pump-code = treal-2.pump
        no-error .
        if j_pump-code  = ?    or
           j_pump-code  = 0
        then do:
          message substitute( 'r-ptrsph.p: не удалось найти ТРК (из чека &4), '
                            + 'из которого продано топливо &1 &2&3 (&5) смена за &6.'
                            , bf_goods.artic
                            , bf_goods.prod-type
                            , bf_goods.prod-code
                            , chk-doc.doc-code
                            , treal-2.pump
                            , string(chk-doc.shift-date, "99/99/9999")
                            )
          view-as alert-box error .
          return error .
        end.
        assign
        varnozzle-code = treal-2.nozzle-code
        no-error .
        if varnozzle-code = 0
        or varnozzle-code = ?
        then do:
          varnozzle-code = 0.
          run find-nzl-without-pl in this-procedure (
                                           input  chk-doc.obj-type
                                          ,input  chk-doc.obj-code
                                          ,input  j_pump-code
                                          ,input  bf_goods.gds-code
                                          ,output varnozzle-code    ) no-error .
          if error-status :error or
            varnozzle-code  = ?    or
            varnozzle-code  = 0
          then do:
            message substitute( 'r-ptrsph.p (find-nzl): не удалось найти пистолет (из чека &4), '
                              + 'из которого продано топливо &1 &2&3 (&5) смена за &6.'
                              , bf_goods.artic
                              , bf_goods.prod-type
                              , bf_goods.prod-code
                              , chk-doc.doc-code
                              , treal-2.pump
                              , string(chk-doc.shift-date, "99/99/9999")
                              )
            view-as alert-box error .
            return error .
          end.
        end.
        find first tt_line where
                    tt_line.pump-code   = j_pump-code
                and tt_line.nozzle-code = varnozzle-code
                and tt_line.pay-code    = treal-2.cpay-code
                and tt_line.curr-code   = treal-2.curr-code
                and tt_line.chk-date    = chk-doc.chk-date
                and tt_line.chk-time    = chk-doc.chk-time
                and tt_line.gds-code    = treal-2.gds-code
                no-error .
        if not available tt_line
        then do:
          find first bf_cash-pay no-lock where
                      bf_cash-pay.cdpay-code = treal-2.cpay-code and
                      bf_cash-pay.curr-code  = treal-2.curr-code .
          assign
            j_order = j_order + 1
          .
          for first ub.bar-code no-lock where ub.bar-code.gds-code = treal-2.gds-code,
          first ub.chk-gds no-lock where ub.chk-gds.b-code = ub.bar-code.b-code
          and ub.chk-gds.doc-code = chk-doc.doc-code:
          create tt_line .
          assign
            tt_line.artic       = bf_goods.artic
            tt_line.prod-type   = bf_goods.prod-type
            tt_line.prod-code   = bf_goods.prod-code
            tt_line.gds-code    = bf_goods.gds-code
            tt_line.gds-name    = bf_goods.gds-name
            tt_line.pump-code   = j_pump-code
            tt_line.nozzle-code = varnozzle-code
            tt_line.chk-count   = 0
            tt_line.base-qnty   = 0.00
            tt_line.cli-qnty    = 0.00
            tt_line.sum-sale    = 0.00
            tt_line.pay-code    = bf_cash-pay.cdpay-code
            tt_line.pay-name    = bf_cash-pay.obj-name
            tt_line.curr-code   = bf_cash-pay.curr-code
            tt_line.order       = j_order
            tt_line.chk-date    = chk-doc.chk-date
            tt_line.chk-time    = chk-doc.chk-time
            tt_line.chk-code    = chk-doc.doc-code
            tt_line.chk-num     = chk-doc.doc-num + ":" + STRING (chk-doc.z-number)
            tt_line.pass-gds    = if chk-gds.pass-gds = 1 then "+" else "-"
            tt_line.doc-num2    = chk-doc.doc-num2
          .
          end.
        end.
        assign
        tt_line.sum-sale = tt_line.sum-sale   + treal-2.netto-rubl
        tt_line.base-qnty = tt_line.base-qnty + treal-2.qnty1
        .
      end.
    end.
  end.
  assign
    j_chk-count     = 0
    j_row-counter   = 0
    j_total-lines   = 0
    v_total-lines   = "":U
    v_chk-code-list = "":U
  .
  for each tt_line no-lock
  break by tt_line.chk-date
        by tt_line.chk-time
  :
    if first-of( tt_line.chk-date )
    then do:
      assign
        t_tmp-date      = tt_line.chk-date
        v_chk-code-list = "":U
      .
      run get-hour-range in this-procedure
        (
           input tt_line.chk-time
        , output j_hour-from
        , output j_hour-till
        ) .
      do vari = 0 to 23 :
        assign
          j_chk-count = 0.
        for each bf_line where
                 bf_line.chk-date  = t_tmp-date  and
                 bf_line.chk-time >= vari * 3600 and
                 bf_line.chk-time <= vari * 3600 + 3599
        by bf_line.chk-date by bf_line.chk-time
        :
          assign
            j_chk-count = j_chk-count + 1
          .
          assign
          bf_line.chk-count = j_chk-count.
        end.
      end.
      if not first( tt_line.chk-date )
      then do:
        assign
          j_row-counter = j_row-counter + 1
          j_total-lines = j_total-lines + 1
          v_total-lines = v_total-lines
                        + ( if v_total-lines = "":U then "":U else chr(44) )
                        + string( j_row-counter )
        .
      end.
    end.
    run get-hour-range in this-procedure
      (
         input tt_line.chk-time
      , output j_tmp-hour-from
      , output j_tmp-hour-till
      ) .
    if j_tmp-hour-from = j_hour-from and
       j_tmp-hour-till = j_hour-till and
       t_tmp-date      = tt_line.chk-date
    then do:
      if lookup( tt_line.chk-code, v_chk-code-list ) = 0
      then do:
        assign
          v_chk-code-list = v_chk-code-list + ( if v_chk-code-list = "":U then "":U else chr(44) )
                                            + tt_line.chk-code
        .
      end.
    end.
    else do:
      assign
        j_hour-from     = j_tmp-hour-from
        j_hour-till     = j_tmp-hour-till
        t_tmp-date      = tt_line.chk-date
        v_chk-code-list = tt_line.chk-code
      .
      assign
        j_row-counter = j_row-counter + 1
        j_total-lines = j_total-lines + 1
        v_total-lines = v_total-lines
                      + ( if v_total-lines = "":U then "":U else chr(44) )
                      + string( j_row-counter )
      .
    end.
    assign
      j_row-counter = j_row-counter + 1
    .
  end.
  assign
    j_row-counter = j_row-counter + 1
    j_total-lines = j_total-lines + 1
    v_total-lines = v_total-lines
                  + ( if v_total-lines = "":U then "":U else chr(44) )
                  + string( j_row-counter )
  .
  assign
    t_tmp-date      = ?
    j_hour-from     = 0
    j_hour-till     = 0
    v_chk-code-list = "":U
  .
  run get-label-lines in this-procedure
    (
      output v_label-line1
    , output v_label-line2
    , output v_label-line3
    , output v_label-line4
    , output v_label-line5
    , output j_text-length
    , output j_column-no
    , output j_total-length
    ) no-error .
  if error-status :error
  then do:
    message return-value skip( 0 )
            error-status :get-message( 1 ) skip( 1 )
    view-as alert-box.
    return error .
  end.
  find first SheetF where
             SheetF.Sheet-Num = XLS-page-num .
  assign
    Sheetf.Bas-Params = string( j_row-counter ) + chr(4)
                      + string( j_column-no   ) + chr(4)
                      + string( j_total-lines ) + "#"
                      +         v_total-lines   + chr(4)
                      +         v-column-list
  .
  assign
    Under_Line = fill( '-', j_total-length )
  .
  run cur-time in this-procedure
    ( output t_today
    , output j_time
    ) .
  if j_total-length > 136
  then do:
output stream text_out to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size  value(43) .
  end.
  else do:
output stream text_out to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size  value(62) .
  end.
  if XLS-page-num > 1
  then do:
    if   Make-Excel Then  do:   Output stream ForExcel close.   assign   number-list = number-list + 1   .   os-delete value( v-excel-file + ".":U + string(number-list)).   Output Stream ForExcel to value( v-excel-file + ".":U + string(number-list ) ) . end.
  end.
  assign
    ReportName   = "Почасовая статистика продаж ТРК с детализацией по пистолетам"
    ReportHeader = substitute( "Дата печати: &1, время: &2."
                             , string( t_today, "99.99.9999":U )
                             , string( j_time,  "hh:mm:ss":U   )
                             )
  .
  run rep/extitle.p
    ( input XLS-page-num
    ) no-error .
  view stream text_out frame    Top_Page .
  view stream text_out frame Bottom_Page .
  assign
    t_tmp-date  = ?
    d_sum-sale  = 0.00
    d_base-qnty = 0.00
  .
  for each tt_line no-lock
  break by tt_line.chk-date
        by tt_line.chk-time
  :
    if first-of( tt_line.chk-date )
    then do:
      assign
        t_tmp-date = tt_line.chk-date
      .
      run get-hour-range in this-procedure
        (
           input tt_line.chk-time
        , output j_hour-from
        , output j_hour-till
        ) .
    end.
    run get-hour-range in this-procedure
      (
         input tt_line.chk-time
      , output j_tmp-hour-from
      , output j_tmp-hour-till
      ) .
    if j_tmp-hour-from = j_hour-from and
       j_tmp-hour-till = j_hour-till and
       t_tmp-date      = tt_line.chk-date
    then do:
      if use-column[  9 ] = yes
      then do:
        assign
          d_base-qnty = d_base-qnty + tt_line.base-qnty
        .
      end.
      if use-column[ 10 ] = yes
      then do:
        assign
          d_sum-sale  = d_sum-sale  + tt_line.sum-sale
        .
      end.
    end.
    else do:
      if use-column[  9 ] = yes or
         use-column[ 10 ] = yes
      then do:
        if use-column[  9 ] = yes
        then do:
          run get-indent in this-procedure
            (
               input 9
            , output j_indent
            , output v_text-indent
            , output v_excel-indent
            ) .
          put stream text_out unformatted
            v_text-indent
            fill( "-", 13 )
          .
        end.
        if use-column[ 10 ] = yes
        then do:
          if use-column[  9 ] <> yes
          then do:
            run get-indent in this-procedure
              (
                 input 10
              , output j_indent
              , output v_text-indent
              , output v_excel-indent
              ) .
            put stream text_out unformatted
              v_text-indent
            .
          end.
          else do:
            put stream text_out unformatted
              " ":U
            .
          end.
          put stream text_out unformatted
            fill( "-", 21 )
          .
        end.
        put stream text_out unformatted
          skip
        .
      end.
      if use-column[  9 ] = yes or
         use-column[ 10 ] = yes
      then do:
        if use-column[  9 ] = yes
        then do:
          run get-indent in this-procedure
            (
               input 9
            , output j_indent
            , output v_text-indent
            , output v_excel-indent
            ) .
          put stream text_out unformatted
            v_text-indent
            string( d_base-qnty, "->>>>,>>9.999":U )
          .
          if Make-Excel then  put   stream ForExcel unformatted
            v_excel-indent
            string( d_base-qnty, "->>>>>>>9.999":U )
          .
        end.
        if use-column[ 10 ] = yes
        then do:
          if use-column[  9 ] <> yes
          then do:
            run get-indent in this-procedure
              (
                 input 10
              , output j_indent
              , output v_text-indent
              , output v_excel-indent
              ) .
            put stream text_out unformatted
              v_text-indent
            .
            if Make-Excel then  put   stream ForExcel unformatted
              v_excel-indent
            .
          end.
          else do:
            put stream text_out unformatted
              " ":U
            .
          end.
          put stream text_out unformatted
            string( d_sum-sale, "->,>>>,>>>,>>>,>>9.99":U )
          .
          if Make-Excel then  put   stream ForExcel unformatted
            CHR(9)
            string( d_sum-sale, "->>>>>>>>>>>>>>>>9.99":U )
          .
        end.
        put stream text_out unformatted
          skip Under_Line skip
        .
        if Make-Excel then  put   stream ForExcel unformatted
          skip
        .
      end.
      assign
        j_hour-from = j_tmp-hour-from
        j_hour-till = j_tmp-hour-till
        t_tmp-date  = tt_line.chk-date
        d_sum-sale  = tt_line.sum-sale
        d_base-qnty = tt_line.base-qnty
      .
    end.
    run get-print-line in this-procedure
      (
         input recid( tt_line )
      , output v_print-line
      , output v_excel-line
      ) no-error .
    if error-status :error or
       v_print-line = ?    or
       v_print-line = "":U
    then do:
      return error substitute( 'Ошибка печати строки отчета.&1 ТРК &2, Пистолет &3, &4.&1'
                             + 'Чек &5, Оплата &6, Код валюты &7.'
                             , chr(10)
                             , tt_line.pump-code
                             , tt_line.nozzle-code
                             , substitute( 'Топливо &1 &2&3 "&4"'
                                         , tt_line.artic
                                         , tt_line.prod-type
                                         , tt_line.prod-code
                                         , tt_line.gds-code
                                         )
                             , tt_line.chk-code
                             , tt_line.pay-code
                             , tt_line.curr-code
                             ) .
    end.
    put stream text_out unformatted
      v_print-line skip
    .
    if Make-Excel then  put   stream ForExcel unformatted
      v_excel-line skip
    .
    if last-of( tt_line.chk-date )
    then do:
      if use-column[  9 ] = yes or
         use-column[ 10 ] = yes
      then do:
        if use-column[  9 ] = yes
        then do:
          run get-indent in this-procedure
            (
               input 9
            , output j_indent
            , output v_text-indent
            , output v_excel-indent
            ) .
          put stream text_out unformatted
            v_text-indent
            fill( "-", 13 )
          .
        end.
        if use-column[ 10 ] = yes
        then do:
          if use-column[  9 ] <> yes
          then do:
            run get-indent in this-procedure
              (
                 input 10
              , output j_indent
              , output v_text-indent
              , output v_excel-indent
              ) .
            put stream text_out unformatted
              v_text-indent
            .
          end.
          else do:
            put stream text_out unformatted
              " ":U
            .
          end.
          put stream text_out unformatted
            fill( "-", 21 )
          .
        end.
        put stream text_out unformatted
          skip
        .
      end.
      if use-column[  9 ] = yes or
         use-column[ 10 ] = yes
      then do:
        if use-column[  9 ] = yes
        then do:
          run get-indent in this-procedure
            (
               input 9
            , output j_indent
            , output v_text-indent
            , output v_excel-indent
            ) .
          put stream text_out unformatted
            v_text-indent
            string( d_base-qnty, "->>>>,>>9.999":U )
          .
          if Make-Excel then  put   stream ForExcel unformatted
            v_excel-indent
            string( d_base-qnty, "->>>>>>>9.999":U )
          .
        end.
        if use-column[ 10 ] = yes
        then do:
          if use-column[  9 ] <> yes
          then do:
            run get-indent in this-procedure
              (
                 input 10
              , output j_indent
              , output v_text-indent
              , output v_excel-indent
              ) .
            put stream text_out unformatted
              v_text-indent
            .
            if Make-Excel then  put   stream ForExcel unformatted
              v_excel-indent
            .
          end.
          else do:
            put stream text_out unformatted
              " ":U
            .
          end.
          put stream text_out unformatted
            string( d_sum-sale, "->,>>>,>>>,>>>,>>9.99":U )
          .
          if Make-Excel then  put   stream ForExcel unformatted
            CHR(9)
            string( d_sum-sale, "->>>>>>>>>>>>>>>>9.99":U )
          .
        end.
        put stream text_out unformatted
          skip Under_Line skip
        .
        if Make-Excel then  put   stream ForExcel unformatted
          skip
        .
      end.
      assign
        d_sum-sale  = 0.00
        d_base-qnty = 0.00
      .
      if last-of( tt_line.chk-date )
      then do:
        hide stream text_out frame Bottom_Page no-pause .
      end.
    end.
  end.
  hide stream text_out frame Bottom_Page no-pause .
  output stream text_out close .
  if Make-Excel then output stream ForExcel close.
  run WaitFram-Hide in this-procedure .
  if j_total-length > 136
  then do:
    run gbl/prnfilen.w
      (
          input  ""
         ,input  8
         ,input  string(session :temp-directory) + "rpt" + string( g#report-num )
         ,input  7
         ,output v-user-action
         ,output v-printed
      ) .
  end.
  else do:
    run gbl/prnfilen.w
      (
          input  ""
         ,input  0
         ,input  string(session :temp-directory) + "rpt" + string( g#report-num )
         ,input  7
         ,output v-user-action
         ,output v-printed
      ) .
  end.
end.
procedure get-fo-range :
  define  input parameter p-obj-type   as character no-undo .
  define  input parameter p-obj-code   as integer   no-undo .
  define  input parameter p-date-from  as date      no-undo .
  define  input parameter p-date-till  as date      no-undo .
  define  input parameter p-shift-from as integer   no-undo .
  define  input parameter p-shift-till as integer   no-undo .
  define  input parameter p-is-shift   as logical   no-undo .
  define output parameter p-fo-from    as decimal   no-undo initial 0.00 .
  define output parameter p-fo-till    as decimal   no-undo initial 0.00 .
  define variable v-shift-end-fact-order as decimal no-undo .
  define variable v-day-end-fact-order   as decimal no-undo .
  define variable v-fact-order           as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-is-shift = yes
    then do:
      run factord in this-procedure
        (
           input p-date-from
        ,  input 1
        ,  input 1
        ,  input p-date-from
        ,  input p-shift-from
        ,  input p-is-shift
        , output p-fo-from
        , output v-shift-end-fact-order
        , output v-day-end-fact-order
        ) no-error .
      if error-status :error
      then do:
        message vss-workfile skip( 0 ) vss-date skip( 0 ) vss-revision skip( 1 ) vss-description skip( 1 )
                "Ошибка при вызове процедуры factord" skip( 0 )
                error-status :get-message( 1 ) skip( 0 )
                return-value skip( 1 )
        view-as alert-box error .
        undo, return error return-value .
      end.
      run factord in this-procedure
        (
           input p-date-till
        ,  input 1
        ,  input 1
        ,  input p-date-till
        ,  input p-shift-till
        ,  input p-is-shift
        , output v-fact-order
        , output p-fo-till
        , output v-day-end-fact-order
        ) no-error .
      if error-status :error
      then do:
        message vss-workfile skip( 0 ) vss-date skip( 0 ) vss-revision skip( 1 ) vss-description skip( 1 )
                "Ошибка при вызове процедуры factord" skip( 0 )
                error-status :get-message( 1 ) skip( 0 )
                return-value skip( 1 )
        view-as alert-box error .
        undo, return error return-value .
      end.
    end.
    else do:
      run day-begin-fact-order in this-procedure
        (
           input p-date-from
        , output p-fo-from
        ) no-error .
      if error-status :error or
         p-fo-from = ?
      then do:
        assign
          p-fo-from = 0.00
        .
      end.
      run factord-end-day in this-procedure
        (
           input p-date-till
        , output p-fo-till
        ) no-error .
      if error-status :error or
         p-fo-till = ?
      then do:
        assign
          p-fo-till = truncate( p-fo-from, 0 ) + 0.99
        .
      end.
    end.
    if p-fo-till < p-fo-from
    then do:
      assign
        p-fo-till = p-fo-from
      .
    end.
  end.
end procedure.
procedure get-hour-range :
  define  input parameter p-time as integer no-undo .
  define output parameter p-from as integer no-undo .
  define output parameter p-till as integer no-undo .
  define variable j-hour as integer no-undo .
  do
  on error undo, return error return-value
  :
    assign
      j-hour = integer( substring( string( p-time, "hh:mm:ss":U ), 1, 2 ) )
      p-from = j-hour * 3600
      p-till = p-from + 3599
    .
  end.
end procedure.
procedure get-label-lines :
  define output parameter p-label-line-1 as character no-undo initial "":U .
  define output parameter p-label-line-2 as character no-undo initial "":U .
  define output parameter p-label-line-3 as character no-undo initial "":U .
  define output parameter p-label-line-4 as character no-undo initial "":U .
  define output parameter p-label-line-5 as character no-undo initial "":U .
  define output parameter p-text-length  as integer   no-undo initial 0    .
  define output parameter p-columns-no   as integer   no-undo initial 0    .
  define output parameter p-total-length as integer   no-undo initial 0    .
  define variable v_list-length as character no-undo initial "":U .
  define variable v_list-label  as character no-undo initial "":U .
  define variable v_list-types  as character no-undo initial "":U .
  define variable jj            as integer   no-undo initial 0    .
  define variable j_length      as integer   no-undo initial 0    .
  define variable v_length      as character no-undo initial "":U .
  define variable v_label       as character no-undo initial "":U .
  define variable v_data-type   as character no-undo initial "":U .
  do
  on error undo, return error return-value
  :
    assign
      p-label-line-1 = "-":U
      p-label-line-2 = ":":U
      p-label-line-3 = ":":U
      p-label-line-4 = ":":U
      p-label-line-5 = ":":U
      p-text-length  = 0
      p-columns-no   = 0
    .
    run get-lbl-data in this-procedure
      (
        output v_list-label
      , output v_list-length
      , output v_list-types
      ) .
    find first SheetF where
               SheetF.Sheet-Num = XLS-page-num .
    do jj = 1 to num-entries( v_list-label )
    :
      if use-column[ jj ] <> yes
      then do:
        next .
      end.
      assign
        v_label     = trim( entry( jj, v_list-label  ) )
        v_length    = trim( entry( jj, v_list-length ) )
        v_data-type = trim( entry( jj, v_list-types  ) )
      .
      assign
        j_length = integer( v_length )
      no-error .
      assign
        p-text-length  = p-text-length  + j_length
        p-columns-no   = p-columns-no   + 1
        p-label-line-1 = p-label-line-1 + fill( "-", j_length ) + "-"
        p-label-line-2 = p-label-line-2 + substring( Centering( v_label, j_length ) + fill( " ":U, j_length )
                                                   , 1
                                                   , j_length
                                                   ) + ":"
        p-label-line-3 = p-label-line-3 + fill( "-", j_length ) + ":"
        p-label-line-4 = p-label-line-4 + substring( Centering( string( p-columns-no ), j_length ) +
                                                     fill( " ":U, j_length )
                                                   , 1
                                                   , j_length
                                                   ) + ":"
        p-label-line-5 = p-label-line-5 + fill( "-", j_length ) + ":"
      .
      assign
        SheetF.Excel-Column-Lable = SheetF.Excel-Column-Lable
                                  + ( if SheetF.Excel-Column-Lable = "":U then "":U else chr(44) )
                                  + v_label
        SheetF.Sizes              = SheetF.Sizes
                                  + ( if SheetF.Sizes = "":U then "":U else chr(44) )
                                  + v_length
      .
      case v_data-type :
        when "D":U
        then do:
          assign
            SheetF.ColFormat = SheetF.ColFormat
                             + ( if SheetF.ColFormat = "":U then "":U else ";":U )
                             + string( p-columns-no ) + "=":U + "@":U
          .
          assign
            v-column-list = v-column-list
                          + ( if v-column-list = "":U then "":U else ";" )
                          + "@":U
          .
        end.
        when "T":U
        then do:
          assign
            SheetF.ColFormat = SheetF.ColFormat
                             + ( if SheetF.ColFormat = "":U then "":U else ";":U )
                             + string( p-columns-no ) + "=":U + "@":U
          .
          assign
            v-column-list = v-column-list
                          + ( if v-column-list = "":U then "":U else ";" )
                          + "@":U
          .
        end.
        when "Z":U
        then do:
          assign
            SheetF.ColFormat = SheetF.ColFormat
                             + ( if SheetF.ColFormat = "":U then "":U else ";":U )
                             + string( p-columns-no ) + "=":U + "#":U + v-del-1 + "##":U + "0":U
          .
          assign
            v-column-list = v-column-list
                          + ( if v-column-list = "":U then "":U else ";" )
                          + "#":U + v-del-1 + "##":U + "0":U
          .
        end.
        when "C":U
        then do:
          assign
            SheetF.ColFormat = SheetF.ColFormat
                             + ( if SheetF.ColFormat = "":U then "":U else ";":U )
                             + string( p-columns-no ) + "=":U + "@":U
          .
          assign
            v-column-list = v-column-list
                          + ( if v-column-list = "":U then "":U else ";" )
                          + "@":U
          .
        end.
        when "I":U
        then do:
          assign
            SheetF.ColFormat = SheetF.ColFormat
                             + ( if SheetF.ColFormat = "":U then "":U else ";":U )
                             + string( p-columns-no ) + "=":U + "0":U
          .
          assign
            v-column-list = v-column-list
                          + ( if v-column-list = "":U then "":U else ";" )
                          + "0":U
          .
        end.
        when "Q":U
        then do:
          assign
            SheetF.ColFormat = SheetF.ColFormat
                             + ( if SheetF.ColFormat = "":U then "":U else ";":U )
                             + string( p-columns-no ) + "=":U + "#":U + v-del-1 + "##":U + "0":U + v-delim + "000":U
          .
          assign
            v-column-list = v-column-list
                          + ( if v-column-list = "":U then "":U else ";" )
                          + "#":U + v-del-1 + "##":U + "0":U + v-delim + "000":U
          .
        end.
        when "S":U
        then do:
          assign
            SheetF.ColFormat = SheetF.ColFormat
                             + ( if SheetF.ColFormat = "":U then "":U else ";":U )
                             + string( p-columns-no ) + "=":U + "#":U + v-del-1 + "##":U + "0":U + v-delim + "00":U
          .
          assign
            v-column-list = v-column-list
                          + ( if v-column-list = "":U then "":U else ";" )
                          + "#":U + v-del-1 + "##":U + "0":U + v-delim + "00":U
          .
        end.
      end case.
    end.
    assign
      SheetF.ColFormat = SheetF.ColFormat
                       + chr(4)
                       + chr(4)
                       + trim( string( XLS-page-num, ">>>>>>>>>9":U ) ) + "-й Лист"
    .
    assign
      p-total-length = p-text-length + p-columns-no + 1
    .
  end.
end procedure.
procedure get-print-line :
  define  input parameter p-temp-rec-id as recid     no-undo .
  define output parameter p-print-line  as character no-undo initial "":U .
  define output parameter p-excel-line  as character no-undo initial "":U .
  define variable v_list-label  as character no-undo initial "":U .
  define variable v_list-types  as character no-undo initial "":U .
  define variable v_list-length as character no-undo initial "":U .
  define variable v_data-type   as character no-undo initial "":U .
  define variable v_length      as character no-undo initial "":U .
  define variable j_length      as integer   no-undo initial 0    .
  define variable jj            as integer   no-undo initial 0    .
  define variable j_time-top    as integer   no-undo .
  define variable j_time-bottom as integer   no-undo .
  define buffer bf_print-line for tt_line .
  do
  on error undo, return error return-value
  :
    find first bf_print-line no-lock where
        recid( bf_print-line ) = p-temp-rec-id .
    run get-lbl-data in this-procedure
      (
        output v_list-label
      , output v_list-length
      , output v_list-types
      ) .
    assign
      p-print-line = ":":U
      p-excel-line = "":U
    .
    do jj = 1 to num-entries( v_list-length )
    :
      if use-column[ jj ] <> yes
      then do:
        next .
      end.
      assign
        v_length    = trim( entry( jj, v_list-length ) )
        v_data-type = trim( entry( jj, v_list-types  ) )
      .
      assign
        j_length = integer( v_length )
      no-error .
      case v_data-type :
        when "D":U
        then do:
          assign
            p-print-line = p-print-line + string( bf_print-line.chk-date, "99/99/9999":U ) + ":":U
            p-excel-line = p-excel-line + string( bf_print-line.chk-date, "99/99/9999":U ) + CHR(9)
          .
        end.
        when "T":U
        then do:
          assign
            p-print-line = p-print-line + string( bf_print-line.chk-time, "hh:mm:ss":U ) + ":":U
            p-excel-line = p-excel-line + string( bf_print-line.chk-time, "hh:mm:ss":U ) + CHR(9)
          .
        end.
        when "Z":U
        then do:
          case j_length :
            when 10
            then do:
              assign
                p-print-line = p-print-line + " ":U + string( bf_print-line.gds-code, "999999999":U ) + ":":U
                p-excel-line = p-excel-line         + string( bf_print-line.gds-code, "999999999":U ) + CHR(9)
              .
            end.
          end case.
        end.
        when "C":U
        then do:
          case j_length :
            when 10
            then do:
              assign
                p-print-line = p-print-line + string( bf_print-line.artic, "x(10)":U ) + ":":U
                p-excel-line = p-excel-line + string( bf_print-line.artic, "x(10)":U ) + CHR(9)
              .
            end.
            when 15
            then
              do:
                case jj :
                  when 12
                  then
                    do:
                      assign
                        p-print-line = p-print-line + string( bf_print-line.chk-num, "x(15)":U ) + ":":U
                        p-excel-line = p-excel-line + string( bf_print-line.chk-num, "x(15)":U ) + CHR(9)
                        .
                    end.
                  when 13
                  then
                    do:
                      assign
                        p-print-line = p-print-line + string( bf_print-line.pass-gds, "x(15)":U ) + ":":U
                        p-excel-line = p-excel-line + string( bf_print-line.pass-gds, "x(15)":U ) + CHR(9)
                        .
                    end.
                  when 14
                  then
                    do:
                      assign
                        p-print-line = p-print-line + "  ":U + string( bf_print-line.doc-num2, "x(12)":U ) + " ":U + ":":U
                        p-excel-line = p-excel-line          + string( bf_print-line.doc-num2, "x(12)":U ) + CHR(9)
                        .
                    end.
                end case.
              end.
            when 17
            then do:
              case jj :
                when 2
                then do:
                  run get-hour-range in this-procedure
                    (
                       input bf_print-line.chk-time
                    , output j_time-top
                    , output j_time-bottom
                    ) .
                  assign
                    p-print-line = p-print-line + string( j_time-top,    "hh:mm:ss":U ) + "-":U
                                                + string( j_time-bottom, "hh:mm:ss":U ) + ":":U
                    p-excel-line = p-excel-line + string( j_time-top,    "hh:mm:ss":U ) + "-":U
                                                + string( j_time-bottom, "hh:mm:ss":U ) + CHR(9)
                  .
                end.
              end case.
            end.
            when 24
            then do:
              case jj :
                when 5
                then do:
                  assign
                    p-print-line = p-print-line + string( bf_print-line.gds-name, "x(24)":U ) + ":":U
                    p-excel-line = p-excel-line + string( bf_print-line.gds-name, "x(24)":U ) + CHR(9)
                  .
                end.
                when 11
                then do:
                  assign
                    p-print-line = p-print-line + string( bf_print-line.pay-name, "x(24)":U ) + ":":U
                    p-excel-line = p-excel-line + string( bf_print-line.pay-name, "x(24)":U ) + CHR(9)
                  .
                end.
              end case.
            end.
          end case.
        end.
        when "I":U
        then do:
          case jj :
            when 6
            then do:
              assign
                p-print-line = p-print-line + "  ":U + string( bf_print-line.pump-code, ">9":U ) + " ":U + ":":U
                p-excel-line = p-excel-line          + string( bf_print-line.pump-code, ">9":U ) + CHR(9)
              .
            end.
            when 7
            then do:
              assign
                p-print-line = p-print-line + "   ":U + string( bf_print-line.nozzle-code, ">9":U ) + "   ":U + ":":U
                p-excel-line = p-excel-line           + string( bf_print-line.nozzle-code, ">9":U ) + CHR(9)
              .
            end.
            when 8
            then do:
              assign
                p-print-line = p-print-line + string( bf_print-line.chk-count, ">>>>9":U ) + ":":U
                p-excel-line = p-excel-line + string( bf_print-line.chk-count, ">>>>9":U ) + CHR(9)
              .
            end.
          end case.
        end.
        when "Q":U
        then do:
          assign
            p-print-line = p-print-line + string( bf_print-line.base-qnty, "->>>>,>>9.999":U ) + ":":U
            p-excel-line = p-excel-line + string( bf_print-line.base-qnty, "->>>>>>>9.999":U ) + CHR(9)
          .
        end.
        when "S":U
        then do:
          assign
            p-print-line = p-print-line + string( bf_print-line.sum-sale, "->,>>>,>>>,>>>,>>9.99":U ) + ":":U
            p-excel-line = p-excel-line + string( bf_print-line.sum-sale, "->>>>>>>>>>>>>>>>9.99":U ) + CHR(9)
          .
        end.
      end case.
    end.
  end.
end procedure.
procedure get-lbl-data :
  define output parameter p-list-label  as character no-undo .
  define output parameter p-list-length as character no-undo .
  define output parameter p-list-types  as character no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-list-length = "10,8,10,10,24,5,8,5,13,21,24,15,15,15":U
      p-list-label  = "Дата,Время,Код товара,Артикул,Наименование товара,№ ТРК,Пистолет,Чеков,Количество,":U +
                      "Сумма продаж,Вид оплаты,Номер чека,Сухой чек,№ заказа":U
      p-list-types  = "D,T,Z,C,C,I,I,I,Q,S,C,C,C,C":U
    .
    if num-entries( p-list-length ) <> num-entries( p-list-label ) or
       num-entries( p-list-length ) <> num-entries( p-list-types )
    then do:
      message "Заголовки:"   p-list-label  num-entries( p-list-label  ) skip( 0 )
              "Длины полей:" p-list-length num-entries( p-list-length ) skip( 0 )
              "Типы данных:" p-list-types  num-entries( p-list-types  ) skip( 1 )
      view-as alert-box .
      undo, return error "Размерности массивов: заголовков, длин полей и типов данных  НЕ СОВПАДАЮТ." .
    end.
  end.
end procedure.
procedure get-indent :
  define  input parameter p-for-column-no as integer   no-undo .
  define output parameter p-indent-length as integer   no-undo initial 0 .
  define output parameter p-text-indent   as character no-undo initial "":U .
  define output parameter p-excel-indent  as character no-undo initial "":U .
  define variable v_list-label  as character no-undo initial "":U .
  define variable v_list-types  as character no-undo initial "":U .
  define variable v_list-length as character no-undo initial "":U .
  define variable v_length      as character no-undo initial "":U .
  define variable j_length      as integer   no-undo initial 0    .
  define variable jj            as integer   no-undo initial 0    .
  do
  on error undo, return error return-value
  :
    run get-lbl-data in this-procedure
      (
        output v_list-label
      , output v_list-length
      , output v_list-types
      ) .
    do jj = 1 to min( num-entries( v_list-length ), p-for-column-no - 1 )
    :
      if use-column[ jj ] <> yes
      then do:
        next .
      end.
      assign
        v_length = trim( entry( jj, v_list-length ) )
      .
      assign
        j_length = integer( v_length )
      no-error .
      assign
        p-indent-length = p-indent-length + j_length + 1
        p-excel-indent  = p-excel-indent  + CHR(9)
      .
    end.
    assign
      p-indent-length = p-indent-length + 1
    .
    assign
      p-text-indent = fill( " ":U, p-indent-length )
    .
  end.
end procedure.
define variable vss-include-info41 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE create-b2-treal-2.
DEFINE INPUT PARAMETER pgds-code like ub.goods.gds-code no-undo.
DEFINE INPUT PARAMETER pcpay-code like ub.cash-pay.cdpay-code no-undo.
DEFINE INPUT PARAMETER pcurr-code like ub.cash-pay.curr-code no-undo.
DEFINE INPUT PARAMETER pqnty1 as decimal no-undo.
DEFINE INPUT PARAMETER pqnty2 as decimal no-undo.
DEFINE INPUT PARAMETER pnetto as decimal no-undo.
DEFINE INPUT PARAMETER pout-name as character no-undo.
DEFINE INPUT PARAMETER pis-pay as logical no-undo.
DEFINE INPUT PARAMETER pii as integer no-undo.
DEFINE INPUT PARAMETER p-pay-desk as integer no-undo.
define input parameter p-prefix   as character no-undo .
define input parameter p-pump as integer no-undo .
define input parameter p-nozzle-code as integer no-undo .
_main:
DO ON ERROR UNDO _main, return error:
    create b2-treal-2.
    assign
    b2-treal-2.gds-code = pgds-code
    b2-treal-2.cpay-code = pcpay-code
    b2-treal-2.curr-code = pcurr-code
    b2-treal-2.qnty1  =  pqnty1
    b2-treal-2.qnty2  = pqnty2
    b2-treal-2.netto = pnetto
    b2-treal-2.out-name = pout-name
    b2-treal-2.is-pay = pis-pay
    b2-treal-2.ii = pii
    b2-treal-2.pay-desk = p-pay-desk
    b2-treal-2.prefix   = p-prefix
    b2-treal-2.pump   = p-pump
    b2-treal-2.nozzle-code   = p-nozzle-code
    no-error
    .
    if error-status:error then undo _main, return error.
END.
END PROCEDURE.
define variable vss-include-info42 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE create-g-b2-treal-3.
DEFINE INPUT PARAMETER pgds-code like ub.goods.gds-code no-undo.
DEFINE INPUT PARAMETER pcpay-code like ub.cash-pay.cdpay-code no-undo.
DEFINE INPUT PARAMETER pcurr-code like ub.cash-pay.curr-code no-undo.
DEFINE INPUT PARAMETER pqnty1 as decimal no-undo.
DEFINE INPUT PARAMETER pnetto as decimal no-undo.
DEFINE INPUT PARAMETER pout-name as character no-undo.
DEFINE INPUT PARAMETER pis-pay as logical no-undo.
DEFINE INPUT PARAMETER pii as integer no-undo.
DEFINE INPUT PARAMETER p-pay-desk as integer no-undo.
define input parameter p-prefix   as character no-undo .
_main:
DO ON ERROR UNDO _main, return error:
    create b2-treal-3.
    assign
    b2-treal-3.gds-code = pgds-code
    b2-treal-3.cpay-code = pcpay-code
    b2-treal-3.curr-code = pcurr-code
    b2-treal-3.qnty1  =  pqnty1
    b2-treal-3.netto = pnetto
    b2-treal-3.out-name = pout-name
    b2-treal-3.is-pay = pis-pay
    b2-treal-3.ii = pii
    b2-treal-3.pay-desk = p-pay-desk
    b2-treal-3.prefix   = p-prefix
    no-error
    .
    if error-status:error then undo _main, return error.
END.
END PROCEDURE.
define variable vss-include-info43 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE create-b2-treal-4.
DEFINE INPUT PARAMETER pgds-code like ub.goods.gds-code no-undo.
DEFINE INPUT PARAMETER pcpay-code like ub.cash-pay.cdpay-code no-undo.
DEFINE INPUT PARAMETER pcurr-code like ub.cash-pay.curr-code no-undo.
DEFINE INPUT PARAMETER pqnty1 as decimal no-undo.
DEFINE INPUT PARAMETER pnetto as decimal no-undo.
DEFINE INPUT PARAMETER pout-name as character no-undo.
DEFINE INPUT PARAMETER pis-pay as logical no-undo.
DEFINE INPUT PARAMETER pii as integer no-undo.
DEFINE INPUT PARAMETER p-pay-desk as integer no-undo.
define input parameter p-prefix   as character no-undo .
_main:
DO ON ERROR UNDO _main, return error:
    create b2-treal-4.
    assign
    b2-treal-4.gds-code = pgds-code
    b2-treal-4.cpay-code = pcpay-code
    b2-treal-4.curr-code = pcurr-code
    b2-treal-4.qnty1  =  pqnty1
    b2-treal-4.netto = pnetto
    b2-treal-4.out-name = pout-name
    b2-treal-4.is-pay = pis-pay
    b2-treal-4.ii = pii
    b2-treal-4.pay-desk = p-pay-desk
    b2-treal-4.prefix   = p-prefix
    no-error
    .
    if error-status:error then undo _main, return error.
END.
END PROCEDURE.
