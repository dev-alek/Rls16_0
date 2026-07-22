block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: ":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Вт авг 04 12:57:17 2020 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-srcheck.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-srcheck.p $":U .
define variable vss-description as character no-undo init "Средний чек".
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
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-tog-raz        as logical no-undo.
define input parameter p-tog-uchet      as logical no-undo.
define input parameter p-tog-prod      as logical no-undo.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable var-report-r-b as character no-undo .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output var-report-r-b
  )  .
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define new shared variable RepPathName        as character no-undo .
define new shared variable PrintRubl          as logical   no-undo .
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
define variable g#report-num as integer no-undo .
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define temp-table temp-chk no-undo
    field gds-code like goods.gds-code
    field gds-name like goods.gds-name
    field unit like goods.unit-base
    field qnty as decimal
    field sum-base as decimal
    field sum-unbase as decimal
    field doc-qnty as integer
    field pok-qnty as integer
    field srchk-kol-tov as decimal
    field srchk-sum as decimal
    field srchk-uch as decimal
    field srchk-base-sum as decimal
    field srchk-base-uch as decimal
    field srchk-kol-tov-pokup as decimal
    field srchk-kol-tov-uch as decimal
    field grp-code like ub.goods.grp-code init 0
    field grp-lvl as integer
    field upper-code like gds-grp.upper-code
    field obj-code as integer
    field obj-type as char
    field obj-name as char
  fields note_ as char
  fields sales-man-psn as integer
    INDEX tt is primary gds-code  obj-code obj-type
    index tt-grp  grp-lvl  obj-type obj-code grp-code sales-man-psn
    index i-gds gds-code obj-code obj-type grp-code
.
define temp-table help-chk no-undo
    field doc-code as char
    field group-chk as integer
    field obj-code as integer
    field obj-type as char
    index pi is primary unique  doc-code group-chk
    index i-grp group-chk
    .
define buffer prod-temp-chk for temp-chk.
define buffer obj-temp-chk for temp-chk.
define variable v-full-path-RepView as character no-undo.
define variable v-file-name-rep-htm as character no-undo.
define variable v-report-name as character no-undo.
define variable v-choice-gds as character no-undo.
define variable v-choice-obj as character no-undo.
define variable v-cntxt-host-name-obj as character no-undo .
define variable tog-uchet-html as char.
define variable tog-raz-html as char.
define stream OutStr-html.
function fnc-DD-MM-YYYY returns character
(input p-dat-date as date) forward.
function fnc-convert-dot-to-colon returns character
(input p-data as decimal, input p-accur as character) forward.
function ChkGdsPromo returns logical
    (input iDocCode as character)
    :
    define buffer buf_chk-gds for ub.chk-gds.
    define buffer buf_chk-gds-attr for ub.chk-gds-attr.
    define variable vPromo as logical no-undo.
    vPromo = no.
    cspr:
    for each buf_chk-gds no-lock where
                 buf_chk-gds.doc-code = iDocCode,
           first buf_chk-gds-attr no-lock where
                 buf_chk-gds-attr.doc-code = buf_chk-gds.doc-code
             and buf_chk-gds-attr.line-num  = buf_chk-gds.line-num
             and buf_chk-gds-attr.attr-code = "CSPromo"
             and buf_chk-gds-attr.attr-value <> "0":
       vPromo = yes.
       leave cspr.
    end.
    return vPromo.
end.
function ChkPromoLine returns logical
    (input iDocCode as character,
    input iLineNum as integer)
    :
    define buffer buf_chk-gds for ub.chk-gds.
    define buffer buf_chk-gds-attr for ub.chk-gds-attr.
    define variable vPromo as logical no-undo.
    vPromo = no.
    find first buf_chk-gds-attr no-lock where
                 buf_chk-gds-attr.doc-code = iDocCode
             and buf_chk-gds-attr.line-num  = iLineNum
             and buf_chk-gds-attr.attr-code = "CSPromo"
             and buf_chk-gds-attr.attr-value <> "0"
    no-error.
    if avail buf_chk-gds-attr then vPromo = yes.
    return vPromo.
end.
function ChkPromoSum returns decimal
    (input iDocCode as character,
     input iLineNum as integer)
    :
   define buffer buf_chk-gds-attr for ub.chk-gds-attr.
   define variable vSumPromo as decimal no-undo.
   find first buf_chk-gds-attr no-lock where
              buf_chk-gds-attr.doc-code = iDocCode
          and buf_chk-gds-attr.line-num  = iLineNum
          and buf_chk-gds-attr.attr-code = "CSPromoSum"
      no-error.
   if avail buf_chk-gds-attr then
      vSumPromo = DEC(buf_chk-gds-attr.attr-value) no-error.
   return vSumPromo.
end function.
function ChkPromoPrice returns logical
    (input iDocCode as character,
     input iLineNum as integer)
    :
   define buffer buf_chk-gds-attr for ub.chk-gds-attr.
   define variable v-is-promo as logical no-undo.
   v-is-promo = no.
   find first buf_chk-gds-attr no-lock where
              buf_chk-gds-attr.doc-code = iDocCode
          and buf_chk-gds-attr.line-num  = iLineNum
          and buf_chk-gds-attr.attr-code = "CSPromo"
      no-error.
   if avail buf_chk-gds-attr
     and can-do("2,4,5,7", buf_chk-gds-attr.attr-value)
   then v-is-promo = yes.
   return v-is-promo.
end function.
function ChkDopLitr returns logical
    (input iDocCode as character,
     input iLineNum as integer)
    :
   define buffer buf_chk-gds-attr for ub.chk-gds-attr.
   define variable v-is-promo as logical no-undo.
   v-is-promo = no.
   find first buf_chk-gds-attr no-lock where
              buf_chk-gds-attr.doc-code = iDocCode
          and buf_chk-gds-attr.line-num  = iLineNum
          and buf_chk-gds-attr.attr-code = "CSPromo"
      no-error.
   if avail buf_chk-gds-attr and
     buf_chk-gds-attr.attr-value = "3"
   then v-is-promo = yes.
   return v-is-promo.
end function.
function RoundUp return decimal
    (input iQnty as decimal,
     input iPrice as decimal):
    def var vSum  as decimal no-undo.
    def var vSumR as decimal no-undo.
    vSum = ABSOLUTE(iQnty) * iPrice.
    vSumR = Round(vSum,2).
    if vSumR < vSum then vSumR = vSumR + 0.01.
    if iQnty < 0 then vSumR = - vSumR.
    return vSumR.
end function.
function GetPromoSum returns decimal
    (input iDocCode as character)
    :
    define buffer buf_chk-doc for ub.chk-doc.
    define buffer buf2_chk-doc for ub.chk-doc.
    define buffer buf_chk-gds for ub.chk-gds.
    define buffer buf_chk-gds-attr for ub.chk-gds-attr.
    define buffer buf2_chk-gds for ub.chk-gds.
    define buffer buf2_chk-gds-attr for ub.chk-gds-attr.
    define variable v-price-base as decimal no-undo.
    define variable v-doc-qnty as decimal no-undo.
    define variable v-sum-base as decimal no-undo.
    define variable v-sum-all as decimal no-undo.
    define variable v-sum-promo as decimal no-undo.
    define variable v-sum-chk as decimal no-undo.
    assign
       v-price-base = 0
       v-doc-qnty = 0
       v-sum-all = 0
       v-sum-chk = 0
       v-sum-promo = 0
       .
    for each buf_chk-gds no-lock where
             buf_chk-gds.doc-code = iDocCode,
       first buf_chk-gds-attr no-lock where
             buf_chk-gds-attr.doc-code = buf_chk-gds.doc-code
         and buf_chk-gds-attr.line-num  = buf_chk-gds.line-num
         and buf_chk-gds-attr.attr-code = "CSPromoSum"
       :
       v-sum-promo = Dec(buf_chk-gds-attr.attr-value).
    end.
    if v-sum-promo = 0 then do:
        for each buf_chk-gds no-lock where
                 buf_chk-gds.doc-code = iDocCode,
           first buf_chk-gds-attr no-lock where
                 buf_chk-gds-attr.doc-code = buf_chk-gds.doc-code
             and buf_chk-gds-attr.line-num  = buf_chk-gds.line-num
             and buf_chk-gds-attr.attr-code = "CSPromo"
             and can-do("1,6", buf_chk-gds-attr.attr-value)
           :
           assign
             v-price-base = buf_chk-gds.price-base
             v-doc-qnty   = if buf_chk-gds.doc-qnty = ? then buf_chk-gds.src-qnty else buf_chk-gds.doc-qnty
             v-sum-base = if buf_chk-gds.sum-base = ? then round(v-doc-qnty * v-price-base, 2) else buf_chk-gds.sum-base
             .
        end.
        for each buf_chk-gds no-lock where
                 buf_chk-gds.doc-code = iDocCode,
           first buf_chk-gds-attr no-lock where
                 buf_chk-gds-attr.doc-code = buf_chk-gds.doc-code
             and buf_chk-gds-attr.line-num  = buf_chk-gds.line-num
             and buf_chk-gds-attr.attr-code = "CSPromo"
             and can-do("2,4,5,7", buf_chk-gds-attr.attr-value)
           :
           if v-price-base = 0 then do:
              find first buf_chk-doc no-lock where
                         buf_chk-doc.doc-code = iDocCode
                  no-error.
              if avail buf_chk-doc and
                 buf_chk-doc.chk-type = int('6':U) and
                 buf_chk-doc.doc-num2 > ""  and
                 num-entries(buf_chk-doc.doc-num2,":") = 2
              then
              for first buf2_chk-doc no-lock where
                        buf2_chk-doc.obj-code = buf_chk-doc.obj-code
                    and buf2_chk-doc.obj-type = buf_chk-doc.obj-type
                    and buf2_chk-doc.chk-type = int('1':U)
                    and buf2_chk-doc.chk-num = int(entry(1,buf_chk-doc.doc-num2,":"))
                    and buf2_chk-doc.z-number = int(entry(2, buf_chk-doc.doc-num2,":"))
                    :
                for each buf2_chk-gds no-lock where
                         buf2_chk-gds.doc-code = buf2_chk-doc.doc-code,
                   first buf2_chk-gds-attr no-lock where
                         buf2_chk-gds-attr.doc-code = buf2_chk-gds.doc-code
                     and buf2_chk-gds-attr.line-num  = buf2_chk-gds.line-num
                     and buf2_chk-gds-attr.attr-code = "CSPromo"
                     and can-do("1,6", buf2_chk-gds-attr.attr-value)
                   :
                    v-price-base = buf2_chk-gds.price-base.
                end.
              end.
           end.
           if buf_chk-gds.sum-base = ? or buf_chk-gds.src-qnty = 0 then do:
               assign
                  v-sum-all = (buf_chk-gds.src-qnty + v-doc-qnty) * v-price-base
                  v-sum-chk = v-sum-base + RoundUp(buf_chk-gds.src-qnty, buf_chk-gds.src-price)
                  .
           end.
           else do:
              assign
              v-sum-all = (buf_chk-gds.doc-qnty + v-doc-qnty ) * v-price-base
              v-sum-chk = v-sum-base + buf_chk-gds.sum-base
              .
           end.
        end.
        v-sum-promo = Round(v-sum-all, 2) - Round(v-sum-chk, 2).
    end.
    return v-sum-promo.
end function.
function GetUnBaseSum returns decimal
    (input iDocCode as character,
     input iLineNum as integer,
     input iQnty as decimal,
     input iPrice as decimal):
   define buffer buf_chk-gds-attr for ub.chk-gds-attr.
   define variable vBaseSum as decimal no-undo.
   define variable vDiscSum as decimal no-undo.
   vDiscSum = 0.
   find first buf_chk-gds-attr no-lock where
                     buf_chk-gds-attr.doc-code = iDocCode
                 and buf_chk-gds-attr.line-num  = iLineNum
                 and buf_chk-gds-attr.attr-code = "CSPromoSum"
          no-error.
   if avail buf_chk-gds-attr then
      vDiscSum = dec(buf_chk-gds-attr.attr-value) no-error.
   vBaseSum = iQnty * iPrice + vDiscSum.
   if vDiscSum = 0 and ChkPromoPrice(iDocCode, iLineNum) then
      vBaseSum = RoundUp(iQnty, iPrice).
   return vBaseSum.
end function.
function GetRoundSum returns decimal
    (input iDocCode as character,
     input iLineNum as integer,
     input iQnty as decimal,
     input iPrice as decimal):
   define buffer buf_chk-gds-attr for ub.chk-gds-attr.
   define variable vBaseSum as decimal no-undo.
   if ChkPromoPrice(iDocCode, iLineNum) then
      vBaseSum = RoundUp(iQnty, iPrice).
   else vBaseSum = iQnty * iPrice.
   return vBaseSum.
end function.
function GetRoundSumChkDel returns decimal
    (input iDocCode as character,
     input iLineNum as integer,
     input iChipNum as integer,
     input iQnty as decimal,
     input iPrice as decimal):
   define buffer  buf_c-chk-doc-attr for ub.c-chk-doc-attr.
   define variable vBaseSum as decimal no-undo.
   define variable vIsPromo as logical no-undo.
   for each buf_c-chk-doc-attr no-lock where
            buf_c-chk-doc-attr.doc-code = iDocCode
        and buf_c-chk-doc-attr.chip-num = iChipNum
       :
       if num-entries(buf_c-chk-doc-attr.attr-code, chr(4)) > 1
       then do :
         if entry(1, buf_c-chk-doc-attr.attr-code, chr(4)) begins "gds="
         and entry(2, buf_c-chk-doc-attr.attr-code, chr(4)) = "CSPromo"
         and entry(2, entry(1, buf_c-chk-doc-attr.attr-code, chr(4)), "=") = String(iLineNum)
         and can-do("2,4,5,7", buf_c-chk-doc-attr.attr-value)
         then vIsPromo = yes.
       end.
   end.
   if ChkPromoPrice(iDocCode, iLineNum) then
      vBaseSum = RoundUp(iQnty, iPrice).
   else vBaseSum = iQnty * iPrice.
   return vBaseSum.
end function.
function GetSaleRetDisc returns decimal
    (input iDocCode as character,
     input iSaleCode as character):
   define buffer buf_chk-gds-attr for ub.chk-gds-attr.
   define buffer buf_chk-gds for ub.chk-gds.
   define variable vQntyPromoRet as decimal no-undo.
   define variable vQntyPromoSel as decimal no-undo.
   define variable vDiscSumRet   as decimal no-undo.
   define variable vDiscSumSale  as decimal no-undo.
   vDiscSumRet = 0.
   cspr:
   for each  buf_chk-gds no-lock where
             buf_chk-gds.doc-code = iDocCode,
       first buf_chk-gds-attr no-lock where
             buf_chk-gds-attr.doc-code  = buf_chk-gds.doc-code
         and buf_chk-gds-attr.line-num  = buf_chk-gds.line-num
         and buf_chk-gds-attr.attr-code = "CSPromo"
         and can-do("2,4,5,7", buf_chk-gds-attr.attr-value)
       :
       vQntyPromoRet = buf_chk-gds.src-qnty.
       leave cspr.
   end.
   if vQntyPromoRet <> 0 then
   for each  buf_chk-gds no-lock where
             buf_chk-gds.doc-code = iSaleCode:
       find first buf_chk-gds-attr no-lock where
                  buf_chk-gds-attr.doc-code  = buf_chk-gds.doc-code
              and buf_chk-gds-attr.line-num  = buf_chk-gds.line-num
              and buf_chk-gds-attr.attr-code = "CSPromo"
       no-error.
       if avail buf_chk-gds-attr
            and can-do("2,4,5,7", buf_chk-gds-attr.attr-value)
       then
         vQntyPromoSel = buf_chk-gds.src-qnty.
       find first buf_chk-gds-attr no-lock where
                 buf_chk-gds-attr.doc-code  = buf_chk-gds.doc-code
             and buf_chk-gds-attr.line-num  = buf_chk-gds.line-num
             and buf_chk-gds-attr.attr-code = "CSPromoSum"
       no-error.
       if avail buf_chk-gds-attr then
          vDiscSumSale = dec(buf_chk-gds-attr.attr-value) no-error.
   end.
   if vQntyPromoRet <> 0 and
      vQntyPromoSel = -1 * vQntyPromoRet
   then vDiscSumRet = -1 * vDiscSumSale.
   return vDiscSumRet.
end function.
function SetPromoDisc return logical
 (input iDocCode as character,
     input iLineNum as integer
     )
    :
   define buffer buf_chk-doc for ub.chk-doc.
   define buffer buf2_chk-doc for ub.chk-doc.
   define buffer buf_chk-gds for ub.chk-gds.
   define buffer buf2_chk-gds for ub.chk-gds.
   define buffer buf_chk-gds-attr for ub.chk-gds-attr.
   define buffer buf2_chk-gds-attr for ub.chk-gds-attr.
   define buffer buf_chk-discnt for ub.chk-discnt.
   define buffer buf2_chk-discnt for ub.chk-discnt.
   define buffer buf_chk-discnt-attr for ub.chk-discnt-attr.
   define buffer buf2_chk-discnt-attr for ub.chk-discnt-attr.
   define variable v-promo-sum as decimal no-undo.
   define variable v-disc-promo-id as character no-undo.
   define variable var-discnt-id as integer no-undo.
   define variable v-chk-sale as character no-undo.
   find first buf_chk-gds-attr no-lock where
              buf_chk-gds-attr.doc-code = iDocCode
          and buf_chk-gds-attr.line-num  = iLineNum
          and buf_chk-gds-attr.attr-code = "CSPromo"
      no-error.
   if avail buf_chk-gds-attr
     then do:
     find first buf_chk-discnt no-lock where
                buf_chk-discnt.doc-code = buf_chk-gds-attr.doc-code
            and buf_chk-discnt.line-num = buf_chk-gds-attr.line-num
            and buf_chk-discnt.record-type = 0
            and buf_chk-discnt.promo-id > ""
            no-error.
     if not avail buf_chk-discnt then do:
        find first buf_chk-doc no-lock where
                   buf_chk-doc.doc-code = iDocCode
           no-error.
        find first buf_chk-gds no-lock where
                   buf_chk-gds.doc-code = iDocCode
              and  buf_chk-gds.line-num = iLineNum
           no-error.
       for first buf2_chk-doc no-lock where
                 buf2_chk-doc.obj-code = buf_chk-doc.obj-code
             and buf2_chk-doc.obj-type = buf_chk-doc.obj-type
             and buf2_chk-doc.pay-desk = buf_chk-doc.pay-desk
             and buf2_chk-doc.chk-type = int('1':U)
             and buf2_chk-doc.chk-num  = int(entry(1,buf_chk-doc.doc-num2,":"))
             and buf2_chk-doc.z-number = int(entry(2, buf_chk-doc.doc-num2,":"))
           :
           find first buf2_chk-gds no-lock where
                      buf2_chk-gds.doc-code = buf2_chk-doc.doc-code
                 and  buf2_chk-gds.b-code   = buf_chk-gds.b-code
           no-error.
           if not avail buf2_chk-gds then return no.
           v-chk-sale = buf2_chk-doc.doc-code.
           find first buf_chk-discnt no-lock where
                      buf_chk-discnt.doc-code =  buf2_chk-doc.doc-code and
                      buf_chk-discnt.record-type = 1 and
                      buf_chk-discnt.object-line-num = buf2_chk-gds.line-num and
                      buf_chk-discnt.promo-id > ""
           no-error .
           if avail buf_chk-discnt
           then do:
              v-disc-promo-id = buf_chk-discnt.promo-id.
              find first buf2_chk-discnt no-lock where
                buf2_chk-discnt.doc-code = iDocCode and
                buf2_chk-discnt.record-type = 5 and
                buf2_chk-discnt.line-num = 0 and
                buf2_chk-discnt.promo-id =  v-disc-promo-id
              no-error.
              find first buf2_chk-discnt-attr no-lock where
                         buf2_chk-discnt-attr.doc-code = iDocCode and
                         buf2_chk-discnt-attr.record-type = 5 and
                         buf2_chk-discnt-attr.line-num = 0 and
                         buf2_chk-discnt-attr.attr-code = "promo-id" and
                         buf2_chk-discnt-attr.attr-value = v-disc-promo-id
                    no-error .
              if not avail buf2_chk-discnt
              then do:
                  for each buf_chk-discnt no-lock where
                           buf_chk-discnt.doc-code = buf_chk-gds-attr.doc-code
                       and buf_chk-discnt.record-type = 5:
                       var-discnt-id  = var-discnt-id + 1.
                  end.
                  create buf2_chk-discnt.
                  assign
                    buf2_chk-discnt.doc-code = iDocCode
                    buf2_chk-discnt.record-type = 5
                    buf2_chk-discnt.line-num = 0
                    buf2_chk-discnt.promo-id = v-disc-promo-id
                    buf2_chk-discnt.object-sum = 0
                    buf2_chk-discnt.discnt-id = if avail buf2_chk-discnt-attr
                                                   then buf2_chk-discnt-attr.discnt-id
                                                   else (var-discnt-id + 1)
                    var-discnt-id = 0
                    buf2_chk-discnt.object-line-num = 0
                    buf2_chk-discnt.pay-desk = buf_chk-doc.pay-desk
                    buf2_chk-discnt.obj-code = buf_chk-doc.obj-code
                    buf2_chk-discnt.obj-type = buf_chk-doc.obj-type
                    buf2_chk-discnt.chk-date = buf_chk-doc.chk-date
                    buf2_chk-discnt.shift-date = buf_chk-doc.shift-date
                    buf2_chk-discnt.shift-num = buf_chk-doc.shift-num
                    buf2_chk-discnt.chk-time = buf_chk-doc.chk-time
                    .
              end.
              if avail buf2_chk-discnt and
                 not avail buf2_chk-discnt-attr
              then do:
                 create buf2_chk-discnt-attr.
                 assign
                    buf2_chk-discnt-attr.doc-code = iDocCode
                    buf2_chk-discnt-attr.discnt-id = buf2_chk-discnt.discnt-id
                    buf2_chk-discnt-attr.record-type     = 5
                    buf2_chk-discnt-attr.line-num        = 0
                    buf2_chk-discnt-attr.object-line-num = 0
                    buf2_chk-discnt-attr.attr-code       = "promo-id"
                    buf2_chk-discnt-attr.attr-value      = v-disc-promo-id
                    .
              end.
           end.
       end.
        v-promo-sum = 0.
        if can-do("1,6,7", buf_chk-gds-attr.attr-value)
        then do:
           if v-chk-sale <> ? and v-chk-sale <> "" then
              v-promo-sum = GetSaleRetDisc(iDocCode,v-chk-sale).
           v-promo-sum = if v-promo-sum = 0 then GetPromoSum(iDocCode) else v-promo-sum.
           if v-promo-sum <> 0 then do:
               find first buf2_chk-gds-attr no-lock where
                          buf2_chk-gds-attr.doc-code = iDocCode
                      and buf2_chk-gds-attr.line-num  = iLineNum
                      and buf2_chk-gds-attr.attr-code = "CSPromoSum"
                  no-error.
               if not avail buf2_chk-gds-attr then do:
                   create buf2_chk-gds-attr.
                   assign
                      buf2_chk-gds-attr.doc-code = iDocCode
                      buf2_chk-gds-attr.line-num  = iLineNum
                      buf2_chk-gds-attr.attr-code = "CSPromoSum"
                      buf2_chk-gds-attr.attr-value = string(Round(v-promo-sum,2))
                      .
               end.
           end.
        end.
        for each buf_chk-discnt no-lock where
                buf_chk-discnt.doc-code = buf_chk-gds-attr.doc-code
            and buf_chk-discnt.record-type = 0:
           var-discnt-id  = var-discnt-id + 1.
        end.
        create buf_chk-discnt.
        assign
            buf_chk-discnt.doc-code = iDocCode
            buf_chk-discnt.line-num = iLineNum
            buf_chk-discnt.record-type = 0
            buf_chk-discnt.discnt-id = (var-discnt-id + 1)
            buf_chk-discnt.time-oper = buf_chk-gds.time-oper
            buf_chk-discnt.line-type = integer('1':U)
            buf_chk-discnt.line-sign = no
            buf_chk-discnt.pass-discnt = integer('0':U)
            buf_chk-discnt.value-type = integer('2':U)
            buf_chk-discnt.src-d-card = buf_chk-gds.src-d-card
            buf_chk-discnt.d-card = buf_chk-gds.d-card
            buf_chk-discnt.discnt-value-abs = 0
            buf_chk-discnt.discnt-value-pcnt = 0
            buf_chk-discnt.object-line-num = iLineNum
            buf_chk-discnt.pay-desk = buf_chk-doc.pay-desk
            buf_chk-discnt.obj-code = buf_chk-doc.obj-code
            buf_chk-discnt.obj-type = buf_chk-doc.obj-type
            buf_chk-discnt.chk-date = buf_chk-doc.chk-date
            buf_chk-discnt.chk-time = buf_chk-doc.chk-time
            buf_chk-discnt.shift-date = buf_chk-doc.shift-date
            buf_chk-discnt.shift-num = buf_chk-doc.shift-num
            buf_chk-discnt.object-qnty = buf_chk-gds.src-qnty
            buf_chk-discnt.object-sum = buf_chk-gds.src-sum
            var-discnt-id = var-discnt-id + 1
            buf_chk-discnt.promo-id = v-disc-promo-id
            buf_chk-discnt.discnt-type = integer('7':U)
            .
        find first buf_chk-discnt-attr no-lock where
                   buf_chk-discnt-attr.attr-code = "promo-id"
               and buf_chk-discnt-attr.discnt-id = buf_chk-discnt.discnt-id
               and buf_chk-discnt-attr.doc-code = buf_chk-discnt.doc-code
               and buf_chk-discnt-attr.line-num = buf_chk-discnt.line-num
               no-error.
        if not avail buf_chk-discnt-attr then
        do:
            create buf_chk-discnt-attr .
            assign
                buf_chk-discnt-attr.attr-code = "promo-id"
                buf_chk-discnt-attr.attr-value = buf_chk-discnt.promo-id
                buf_chk-discnt-attr.discnt-id = buf_chk-discnt.discnt-id
                buf_chk-discnt-attr.doc-code = buf_chk-discnt.doc-code
                buf_chk-discnt-attr.line-num = buf_chk-discnt.line-num
                buf_chk-discnt-attr.object-line-num = buf_chk-discnt.object-line-num
                buf_chk-discnt-attr.record-type = buf_chk-discnt.record-type
                .
         end.
     end.
   end.
   return yes.
end function.
function GetPromoPriceSum returns decimal
    (input iDocCode as character)
    :
    define buffer buf_chk-gds for ub.chk-gds.
    define buffer buf_chk-gds-attr for ub.chk-gds-attr.
    define variable vPromoSum as decimal no-undo.
    vPromoSum = 0.
    cspr:
    for each buf_chk-gds no-lock where
                 buf_chk-gds.doc-code = iDocCode,
           first buf_chk-gds-attr no-lock where
                 buf_chk-gds-attr.doc-code = buf_chk-gds.doc-code
             and buf_chk-gds-attr.line-num  = buf_chk-gds.line-num
             and buf_chk-gds-attr.attr-code = "CSPromo"
             and can-do("2,4,5,7", buf_chk-gds-attr.attr-value):
       vPromoSum = RoundUp(buf_chk-gds.src-qnty, buf_chk-gds.src-price).
       leave cspr.
    end.
    return vPromoSum.
end.
function GetPromoPriceLine returns integer
    (input iDocCode as character)
    :
    define buffer buf_chk-gds for ub.chk-gds.
    define buffer buf_chk-gds-attr for ub.chk-gds-attr.
    define variable vPromoLine as integer no-undo.
    vPromoLine = 0.
    cspr:
    for each buf_chk-gds no-lock where
                 buf_chk-gds.doc-code = iDocCode,
           first buf_chk-gds-attr no-lock where
                 buf_chk-gds-attr.doc-code = buf_chk-gds.doc-code
             and buf_chk-gds-attr.line-num  = buf_chk-gds.line-num
             and buf_chk-gds-attr.attr-code = "CSPromo"
             and can-do("2,4,5,7", buf_chk-gds-attr.attr-value):
       vPromoLine = buf_chk-gds-attr.line-num.
       leave cspr.
    end.
    return vPromoLine.
end.
  v-report-name = ibs.th.gbl.gbl-inipar:prn-lib-get-report-name("rpt") .
  assign
    v-file-name-rep-htm = v-report-name + ".html"
  .
  output to value(v-file-name-rep-htm).
  output close.
run create-fill-tt-chk.
  v-report-name = "Отчет по среднему чеку".
  str1 = substitute(
    (if X-TOG-Shift then "С &1, смена №&2 по &3, смена №&4" else "За период с &1 по &3")
    , fnc-DD-MM-YYYY(X-Date-Start)
    , X-Shift-Start
    , fnc-DD-MM-YYYY(X-Date-End)
    , X-Shift-End
  ) .
  if X-selectGood = 4 or
     X-selectGood = 6   or
     X-selectGood = 5 then do:
    v-choice-gds = "По списку товаров: " + x-Goods-Editor.
    if length(v-choice-gds) > 115 then
      v-choice-gds = substring(v-choice-gds, 1, 115) + "..." .
  end.
  v-choice-gds = if length(str2) > 115 then ( substring(str2, 1, 115) + "..." ) else str2.
  str4 = replace(str4, chr(10), " ").
  str4 = replace(str4, chr(13), " ").
  str4 = replace(str4, chr(9),  " ").
  str4 = trim(str4, " ").
  str4 = replace(str4, "  ",  " ").
  v-choice-obj = if length(str4) > 115 then ( substring(str4, 1, 115) + "..." ) else str4.
  tog-uchet-html = if p-tog-uchet then "Нет" else "Да"  .
  tog-raz-html   = if p-tog-raz   then "Да"  else "Нет" .
 run proc-create-HTML(       input v-file-name-rep-htm
                            ,input v-report-name
                            ,input str1
                            ,input v-choice-gds
                            ,input v-choice-obj
                            ,input tog-uchet-html
                            ,input tog-raz-html
                        ).
      run prn-lib-reportviewer-report-name in this-procedure (
        input THIS-PROCEDURE
        ,input v-file-name-rep-htm
        ).
procedure chk-calc:
define input parameter p-obj-code as integer no-undo.
define input parameter p-obj-type as character no-undo.
define input parameter p-doc-code as character no-undo.
define input parameter p-sales-man as integer no-undo.
define input parameter p-salesman-psn-code as integer no-undo.
define input parameter p-chk-type as integer no-undo.
define variable v-prod as logical no-undo .
define variable v-gds-code as integer no-undo .
define variable v-grp-code as integer no-undo .
define variable v-grp-name like ub.goods.grp-name no-undo.
define variable v-found as logical no-undo.
define variable v-use-line as logical no-undo.
define variable ii-grp as integer no-undo.
define variable v-name         as char      no-undo.
define variable vSumUnBase as decimal no-undo.
define buffer buf_chk-gds-pay for ub.chk-gds-pay .
define buffer buf_bar-code for ub.bar-code .
define buffer buf_goods    for ub.goods .
define buffer buf_person   for ub.person .
define buffer buf-qnty-temp-chk for temp-chk .
  if p-tog-prod = yes then do:
    find first buf-qnty-temp-chk
         where buf-qnty-temp-chk.gds-code = 0
           and buf-qnty-temp-chk.obj-code = p-obj-code
           and buf-qnty-temp-chk.obj-type = p-obj-type
// 23/VIII-2018
//           and buf-qnty-temp-chk.grp-code = p-sales-man
//           and buf-qnty-temp-chk.sales-man-psn = p-salesman-psn-code
           and buf-qnty-temp-chk.grp-code = p-salesman-psn-code
    use-index tt no-error .
    if not available buf-qnty-temp-chk then do:
      if p-sales-man <> 0 then do:
        run rep/get-psn.p (input p-salesman-psn-code, output v-name ).
        for first buf_person no-lock where buf_person.psn-code = p-salesman-psn-code :
          v-name = v-name + '  ' + buf_person.name1 + ' ':U + buf_person.name2.
        end.
      end.
      else v-name = "Продавец не указан".
      create buf-qnty-temp-chk.
      assign
        buf-qnty-temp-chk.gds-code  = 0
        buf-qnty-temp-chk.obj-code  = p-obj-code
        buf-qnty-temp-chk.obj-type  = p-obj-type
// 23/VIII-2018
//        buf-qnty-temp-chk.grp-code  = p-sales-man
//        buf-qnty-temp-chk.sales-man-psn = p-salesman-psn-code
        buf-qnty-temp-chk.grp-code  = p-salesman-psn-code
        buf-qnty-temp-chk.grp-lvl     = 1  // по продавцам - где используется ?
        buf-qnty-temp-chk.upper-code  = -2 // по продавцам - где используется ?
        buf-qnty-temp-chk.gds-name    = v-name
        buf-qnty-temp-chk.doc-qnty    = 0
      .
    end.
  end .
  v-prod = no.
  _chk:
  for each buf_chk-gds-pay no-lock
     where buf_chk-gds-pay.doc-code = p-doc-code
       and buf_chk-gds-pay.algo-num = "1.8"
  break by buf_chk-gds-pay.b-code
        by buf_chk-gds-pay.line-num :
    if first-of (buf_chk-gds-pay.b-code) then do :
      v-use-line = false .
      find first buf_bar-code no-lock
           where buf_bar-code.b-code = buf_chk-gds-pay.b-code no-error .
      if available buf_bar-code then do :
        v-gds-code = buf_bar-code.gds-code .
        find first buf_goods no-lock where buf_goods.gds-code = v-gds-code no-error .
        if available buf_goods then do:
          v-grp-code = buf_goods.grp-code .
        end .
        else v-grp-code = ? .
      end .
      else assign
        v-gds-code = ?
        v-grp-code = ?
      .
      if v-grp-code = ? then next .
      case x-SelectGood:
        when 4 or
        when 6 or
        when 5 then do:
          find first gds-list
               where gds-list.artic     = buf_goods.artic
                 and gds-list.prod-type = buf_goods.prod-type
                 and gds-list.prod-code = buf_goods.prod-code no-error .
          if not available gds-list then next.
        end.
        when 1 then .
        when 2 then do :
          assign
            v-grp-name = ""
            v-found = no
          .
          _ii-grp:
          do ii-grp = 1 to num-entries(buf_goods.grp-name, chr(47)) - 1 :
            v-grp-name = v-grp-name + entry(ii-grp, buf_goods.grp-name, chr(47)) + chr(47) .
            if can-find(first tmp#grp where tmp#grp.grp-name = v-grp-name) then do:
              v-found = yes.
              leave _ii-grp.
            end.
          end.
          if not v-found then next _chk.
        end.
        otherwise next .
      end case.
      v-use-line = true .
      if (p-chk-type = 1) then do :
      if not can-find (first help-chk where help-chk.doc-code  = buf_chk-gds-pay.doc-code
                                        and help-chk.group-chk = v-grp-code
                                        and help-chk.obj-code  = p-obj-code
                                        and help-chk.obj-type  = p-obj-type) then do:
        create help-chk.
        assign
          help-chk.doc-code  = buf_chk-gds-pay.doc-code
          help-chk.group-chk = v-grp-code
          help-chk.obj-code  = p-obj-code
          help-chk.obj-type  = p-obj-type
        .
      end.
      end .
      if p-tog-prod = yes then do:
        if not v-prod then assign
          buf-qnty-temp-chk.doc-qnty = buf-qnty-temp-chk.doc-qnty + 1 when (p-chk-type = 1)
          v-prod = yes
        .
        find first temp-chk
             where temp-chk.gds-code = v-gds-code
               and temp-chk.obj-code = p-obj-code
               and temp-chk.obj-type = p-obj-type
// 23/VIII-2018
//               and temp-chk.grp-code = p-sales-man
//               and temp-chk.sales-man-psn = p-salesman-psn-code
               and temp-chk.grp-code = p-salesman-psn-code
        use-index tt no-error .
        if not available temp-chk then do:
          create temp-chk.
          assign
            temp-chk.gds-code = v-gds-code
            temp-chk.obj-code = p-obj-code
            temp-chk.obj-type = p-obj-type
// 23/VIII-2018
//            temp-chk.grp-code = p-sales-man
//            temp-chk.sales-man-psn = p-salesman-psn-code
            temp-chk.grp-code = p-salesman-psn-code
            temp-chk.gds-name    = buf_goods.gds-name
            temp-chk.unit        = buf_goods.unit-base
            temp-chk.doc-qnty    = 0
          .
        end.
      end.
      else do:
        if not v-prod then assign
          obj-temp-chk.doc-qnty = obj-temp-chk.doc-qnty + 1 when (p-chk-type = 1)
          v-prod = yes
        .
        find first temp-chk
             where temp-chk.gds-code = v-gds-code
               and temp-chk.obj-code = p-obj-code
               and temp-chk.obj-type = p-obj-type
        use-index tt no-error .
        if not available temp-chk then do:
          create temp-chk.
          assign
            temp-chk.gds-code = v-gds-code
            temp-chk.obj-code = p-obj-code
            temp-chk.obj-type = p-obj-type
            temp-chk.gds-name = buf_goods.gds-name
            temp-chk.unit     = buf_goods.unit-base
            temp-chk.grp-code = buf_goods.grp-code
            temp-chk.doc-qnty = 0
          .
        end.
      end.
      if p-chk-type = 1 then assign
        temp-chk.doc-qnty = temp-chk.doc-qnty + 1
      .
    end .
    if not v-use-line then next .
    if p-chk-type = 1 then do:
      if first-of(buf_chk-gds-pay.line-num) then assign
        temp-chk.pok-qnty     = temp-chk.pok-qnty     + 1
        obj-temp-chk.pok-qnty = obj-temp-chk.pok-qnty + 1
      .
    end .
    assign
      vSumUnBase = GetUnBaseSum(buf_chk-gds-pay.doc-code, buf_chk-gds-pay.line-num, buf_chk-gds-pay.eff-doc-qnty, buf_chk-gds-pay.price-base)
      temp-chk.qnty       = temp-chk.qnty       + buf_chk-gds-pay.eff-doc-qnty
      temp-chk.sum-unbase = temp-chk.sum-unbase + vSumUnBase
      temp-chk.sum-base   = temp-chk.sum-base   + buf_chk-gds-pay.tot-r-b
      obj-temp-chk.qnty       = obj-temp-chk.qnty       + buf_chk-gds-pay.eff-doc-qnty
      obj-temp-chk.sum-unbase = obj-temp-chk.sum-unbase + vSumUnBase
      obj-temp-chk.sum-base   = obj-temp-chk.sum-base   + buf_chk-gds-pay.tot-r-b
    .
    assign
      temp-chk.srchk-kol-tov       = temp-chk.qnty       / temp-chk.doc-qnty
      temp-chk.srchk-sum           = temp-chk.sum-unbase / temp-chk.doc-qnty
      temp-chk.srchk-base-sum      = temp-chk.sum-base   / temp-chk.doc-qnty
      temp-chk.srchk-kol-tov-pokup = temp-chk.pok-qnty   / temp-chk.doc-qnty
    .
  end.
end procedure.
procedure create-fill-tt-chk:
define variable v-chk-type-list as character no-undo .
define variable v-obj-type as character no-undo .
define variable v-obj-code as integer no-undo .
define buffer buf_chk-doc for ub.chk-doc .
  if not p-tog-raz then do:
    create obj-temp-chk.
    assign
      obj-temp-chk.obj-code = 0
      obj-temp-chk.obj-type = ''
      obj-temp-chk.gds-name = 'Итого по всем объектам'
      obj-temp-chk.upper-code = -1
      obj-temp-chk.grp-code   = 0
      v-obj-type = ''
      v-obj-code = 0
    .
  end.
  v-chk-type-list = '1':U .
  if p-tog-uchet = no then v-chk-type-list = v-chk-type-list + "," + '6':U .
  for each obj-list :
    do:
      run rep/rpychk0.p (input "r-shftc2"
                        ,input obj-list.obj-type
                        ,input obj-list.obj-code
                        ,input ?
                        ,input ?
                        ,input X-date-start
                        ,input X-date-end
                        ,input 0
                        ,input 99
                        ,input ?
      ) no-error.
      if error-status:error then do:
          message
            substitute( "*** Ошибка вызова rpychk0 по объекту &1 &2. &3. &4. &5."
                    , obj-list.obj-type
                    , obj-list.obj-code
                    , return-value
                    , error-status:get-message(1)
                    , error-status:get-message(2)
                    )
            view-as alert-box .
      end.
    end.
    if p-tog-raz then do:
      create obj-temp-chk.
      assign
        obj-temp-chk.obj-code = obj-list.obj-code
        obj-temp-chk.obj-type = obj-list.obj-type
        obj-temp-chk.gds-name = obj-list.obj-name
        obj-temp-chk.upper-code = -1
        obj-temp-chk.grp-code   = 0
        v-obj-type = obj-list.obj-type
        v-obj-code = obj-list.obj-code
      .
    end.
    if x-TOG-Shift = yes then do:
      for each buf_chk-doc no-lock
         where buf_chk-doc.obj-type = obj-list.obj-type
           and buf_chk-doc.obj-code = obj-list.obj-code
           and buf_chk-doc.shift-date >= X-date-Start
           and buf_chk-doc.shift-date <= X-date-End
           and buf_chk-doc.out-code <> ?
           and can-do(v-chk-type-list, string(buf_chk-doc.chk-type))
      :
        if (buf_chk-doc.shift-date = X-date-Start)
       and (buf_chk-doc.shift-num < x-Shift-Start) then next.
        if (buf_chk-doc.shift-date = X-date-End)
       and (buf_chk-doc.shift-num > x-Shift-End) then next.
        run chk-calc in this-procedure
        ( input v-obj-code
        , input v-obj-type
        , input buf_chk-doc.doc-code
        , input buf_chk-doc.sales-man
        , input buf_chk-doc.salesman-psn-code
        , input buf_chk-doc.chk-type
        ) .
      end .
    end.
    else do:
      for each buf_chk-doc no-lock
         where buf_chk-doc.obj-type = obj-list.obj-type
           and buf_chk-doc.obj-code = obj-list.obj-code
           and buf_chk-doc.chk-date >= X-date-Start
           and buf_chk-doc.chk-date <= X-date-End
           and buf_chk-doc.out-code <> ?
           and can-do(v-chk-type-list, string(buf_chk-doc.chk-type))
      :
        run chk-calc in this-procedure
        ( input v-obj-code
        , input v-obj-type
        , input buf_chk-doc.doc-code
        , input buf_chk-doc.sales-man
        , input buf_chk-doc.salesman-psn-code
        , input buf_chk-doc.chk-type
        ) .
      end .
    end.
    if p-tog-raz = yes then do:
      if p-tog-prod = yes then run prod-level         ( input obj-list.obj-code, input obj-list.obj-type).
                          else run transform-tt-level ( input obj-list.obj-code, input obj-list.obj-type).
      assign
        obj-temp-chk.srchk-uch         = 100
        obj-temp-chk.srchk-base-uch    = 100
        obj-temp-chk.srchk-kol-tov-uch = 100
        obj-temp-chk.srchk-kol-tov       = obj-temp-chk.qnty       / obj-temp-chk.doc-qnty
        obj-temp-chk.srchk-sum           = obj-temp-chk.sum-unbase / obj-temp-chk.doc-qnty
        obj-temp-chk.srchk-base-sum      = obj-temp-chk.sum-base   / obj-temp-chk.doc-qnty
        obj-temp-chk.srchk-kol-tov-pokup = obj-temp-chk.pok-qnty   / obj-temp-chk.doc-qnty
      .
    end .
  end.
  if p-tog-raz = no then do:
    if p-tog-prod = yes then run prod-level        ( input 0, input '').
                        else run transform-tt-level( input 0, input '').
    assign
      obj-temp-chk.srchk-uch         = 100
      obj-temp-chk.srchk-base-uch    = 100
      obj-temp-chk.srchk-kol-tov-uch = 100
      obj-temp-chk.srchk-kol-tov       = obj-temp-chk.qnty       / obj-temp-chk.doc-qnty
      obj-temp-chk.srchk-sum           = obj-temp-chk.sum-unbase / obj-temp-chk.doc-qnty
      obj-temp-chk.srchk-base-sum      = obj-temp-chk.sum-base   / obj-temp-chk.doc-qnty
      obj-temp-chk.srchk-kol-tov-pokup = obj-temp-chk.pok-qnty   / obj-temp-chk.doc-qnty
    .
  end .
end procedure.
procedure proc-create-HTML:
define input parameter p-file-name-rep-htm as character no-undo.
define input parameter p-report-name as character no-undo.
define input parameter p-period-date as char no-undo.
define input parameter v-choice-gds as char no-undo.
define input parameter v-choice-obj as char no-undo.
define input parameter tog-uchet-html as char no-undo.
define input parameter tog-raz-html as char no-undo.
    define buffer buf-html-temp-chk for temp-chk.
  for first obj-list :
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostname in g#library
  (input  obj-list.obj-type
  ,input  obj-list.obj-code
  ,output v-cntxt-host-code-obj
  ,output v-cntxt-host-name-obj
  )  .
  end .
  output stream OutStr-html to value(p-file-name-rep-htm) append convert target 'UTF-8'.
  do:
    put stream OutStr-html unformatted
    "<!DOCTYPE HTML>" skip
    ' <html>' skip
    '  <head>' skip
    '   <meta charset="utf-8">' skip
    '    <style type="text/css">' skip
    '      table ' + chr(123) + ' border-collapse: collapse; font-size: 9pt; table-layout: fixed; width: 1157px; padding: 14px; ' + chr(125) skip
                '      td ' + chr(123) ' border: 1px black ridge; word-wrap:break-word; ' + chr(125) skip
                '      htm' skip
                '      .rotate ' + chr(123) skip
                '        -webkit-transform: rotate(-90deg);' skip
                '        -moz-transform: rotate(-90deg);' skip
                '        -ms-transform: rotate(-90deg);' skip
                '        -o-transform: rotate(-90deg);' skip
                '        transform: rotate(-90deg);' skip
                '        -webkit-transform-origin: 50% 50%;' skip
                '        -moz-transform-origin: 50% 50%;' skip
                '        -ms-transform-origin: 50% 50%;' skip
                '        -o-transform-origin: 50% 50%;' skip
                '        transform-origin: 50% 50%;' skip
                '        filter: progid:DXImageTransform.Microsoft.BasicImage(rotation=3);' skip
                '          ' + chr(125) skip
                '            th' + ' ' + chr(123) skip
                '            border: 1px black solid;' skip
                '            word-wrap: break-word;' skip
                '          ' + chr(125) skip
                '   </style>' skip
                '  </head>' skip
            .
    end.
 do:
     put stream OutStr-html unformatted
         ' <body>' skip
         '   <table name="Лист1" fit_to_page="true" orientation="landscape" outline_below="false">' skip
         '     <thead>' skip
         '       <tr class="set_columns">' skip
         '         <td style="width: 60px; border: none;"></td>' skip
         '         <td style="width: 200px; border: none;"></td>' skip
         '         <td style="width: 78px; border: none;"></td>' skip
         '         <td style="width: 78px; border: none;"></td>' skip
         '         <td style="width: 78px; border: none;"></td>' skip
         '         <td style="width: 78px; border: none;"></td>' skip
         '         <td style="width: 78px; border: none;"></td>' skip
         '         <td style="width: 78px; border: none;"></td>' skip
         '         <td style="width: 78px; border: none;"></td>' skip
         '         <td style="width: 68px; border: none;"></td>' skip
         '         <td style="width: 68px; border: none;"></td>' skip
         '         <td style="width: 68px; border: none;"></td>' skip
         '         <td style="width: 68px; border: none;"></td>' skip
         '         <td style="width: 78px; border: none;"></td>' skip
         '         <td style="width: 68px; border: none;"></td>' skip
         '       </tr>' skip
         .
            end.
    do:
            put stream OutStr-html unformatted
            '       <tr>' skip
            '         <td colspan="15" style="border: none; height: 14px; font-size: 14pt; font-weight: bold">Отчет по среднему чеку </td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '       </tr>' skip
            '       <tr>' skip
            '         <td colspan="15" style="border: none; height: 14px">По фирме:  ' +    v-cntxt-host-name-obj    + '</td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '       </tr>' skip
            '       <tr>' skip
            '         <td colspan="15" style="border: none; height: 14px">' + v-choice-obj + '</td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '       </tr>' skip
            '       <tr>' skip
            '         <td colspan="15" style="border: none; height: 14px">' + p-period-date + '</td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '       </tr>' skip
            '       <tr>' skip
            '         <td colspan="15" style="border: none; height: 14px">' + v-choice-gds + '</td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '       </tr>' skip
            '       <tr>' skip
            '         <td colspan="15" style="border: none; height: 14px">Возвраты:  ' +  tog-uchet-html  + '</td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '       </tr>' skip
            '       <tr>' skip
            '         <td colspan="15" style="border: none; height: 14px">Раздельно по объектам:    '   + tog-raz-html '  </td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '       </tr>' skip
                '     </thead>' skip
            .
    end.
             do:
            put stream OutStr-html unformatted
            '     <tbody>' skip
             '       <tr style="height: 60px;">' skip
            '         <th  rowspan="2" style="background-color:#ffffcc; text-align: center;">Код</th>' skip
            '         <th  rowspan="2"   style="background-color:#ffffcc; text-align: center;">Наименование товара</th>' skip
            '         <th rowspan="2" style="background-color:#ffffcc; text-align: center;">Единица измерения</th>' skip
            '         <th rowspan="2" style="background-color:#ffffcc; text-align: center;">Количество</th>' skip
            '         <th rowspan="2" style="background-color:#ffffcc; text-align: center;">Сумма без скидок</th>' skip
            '         <th rowspan="2" style="background-color:#ffffcc; text-align: center;">Сумма со скидкой</th>' skip
            '         <th rowspan="2" style="background-color:#ffffcc; text-align: center;">Количество чеков</th>' skip
            '         <th rowspan="2" style="background-color:#ffffcc; text-align: center;">Количество покупок</th>' skip
            '         <th rowspan="2"  style="background-color:#ffffcc; text-align: center;">Средний чек по количеству товаров</th>' skip
            '         <th  colspan="2" style="background-color:#ffffcc; text-align: center;">Средний чек по сумме без скидок</th>' skip
            '         <th  colspan="2" style="background-color:#ffffcc; text-align: center;">Средний чек по сумме со скидками</th>' skip
            '         <th  colspan="2" style="background-color:#ffffcc; text-align: center;">Средний чек по кол-ву покупок товара </th>' skip
            '</tr>'   skip
               '       <tr style="height: 45px;">' skip
            '        <th style="background-color:#ffffcc; text-align: center;">Сумма</th>' skip
            '         <th style="background-color:#ffffcc; text-align: center;">Участие (%)</th>' skip
            '         <th style="background-color:#ffffcc; text-align: center;">Сумма</th>' skip
            '         <th style="background-color:#ffffcc; text-align: center;">Участие (%)</th>' skip
            '         <th style="background-color:#ffffcc; text-align: center;">Количество покупок</th>' skip
            '         <th style="background-color:#ffffcc; text-align: center;">Участие (%)</th>' skip
            '</tr>'skip
                     '       <tr>' skip
                     '         <th num="" style="background-color:#ffffcc; text-align: center">1</th>' skip
                     '         <th num="" style="background-color:#ffffcc; text-align: center">2</th>' skip
                     '         <th num="" style="background-color:#ffffcc; text-align: center">3</th>' skip
                     '         <th num="" style="background-color:#ffffcc; text-align: center">4</th>' skip
                     '         <th num="" style="background-color:#ffffcc; text-align: center">5</th>' skip
                     '         <th num="" style="background-color:#ffffcc; text-align: center">6</th>' skip
                     '         <th num="" style="background-color:#ffffcc; text-align: center">7</th>' skip
                     '         <th num="" style="background-color:#ffffcc; text-align: center">8</th>' skip
                     '         <th num="" style="background-color:#ffffcc; text-align: center">9</th>' skip
                     '         <th num="" style="background-color:#ffffcc; text-align: center">10</th>' skip
                     '         <th num="" style="background-color:#ffffcc; text-align: center">11</th>' skip
                     '         <th num="" style="background-color:#ffffcc; text-align: center">12</th>' skip
                     '         <th num="" style="background-color:#ffffcc; text-align: center">13</th>' skip
                     '         <th num="" style="background-color:#ffffcc; text-align: center">14</th>' skip
                     '         <th num="" style="background-color:#ffffcc; text-align: center">15</th>' skip
                     '       </tr>' skip.
             output stream OutStr-html close.
    end.
    do:
        output stream OutStr-html to value(p-file-name-rep-htm) append convert target 'UTF-8'.
        find first buf-html-temp-chk no-lock no-error.
        if not error-status:error and available buf-html-temp-chk then
        do:
            for each buf-html-temp-chk where
                buf-html-temp-chk.grp-code = 0 and buf-html-temp-chk.upper-code = -1 and buf-html-temp-chk.gds-code = 0 no-lock
                by buf-html-temp-chk.obj-type by buf-html-temp-chk.obj-code
                :
                put stream OutStr-html unformatted
                    '       <tr level="1">' skip
                    '         <td colspan="3" style="display: yes; text-align: left; font-weight: bold">' +  buf-html-temp-chk.gds-name + '</td>' skip
                    '         <td style="display: yes; text-align:  right; font-weight: bold">'  + if buf-html-temp-chk.qnty <> ?  then fnc-convert-dot-to-colon( buf-html-temp-chk.qnty, "->>>>>>>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                    '         <td style="display: yes; text-align:  right; font-weight: bold">'   + if buf-html-temp-chk.sum-unbase <> ? then fnc-convert-dot-to-colon( buf-html-temp-chk.sum-unbase, "->>>>>>>>>>>>9.99")   + '</td>' else "?" + '</td>' skip
                    '         <td style="display: yes; text-align:  right; font-weight: bold">'   + if buf-html-temp-chk.sum-base <> ? then fnc-convert-dot-to-colon( buf-html-temp-chk.sum-base, "->>>>>>>>>>>>>9.99")  + '</td>' else "?" + '</td>' skip
                    '         <td style="display: yes; text-align:  right; font-weight: bold">'   + if buf-html-temp-chk.doc-qnty <> ? then fnc-convert-dot-to-colon( buf-html-temp-chk.doc-qnty, "->>>>>>>>>>>>>>9") + '</td>' else "?" + '</td>' skip
                    '         <td style="display: yes; text-align:  right; font-weight: bold">'   + if buf-html-temp-chk.pok-qnty <> ? then fnc-convert-dot-to-colon( buf-html-temp-chk.pok-qnty, "->>>>>>>>>>>>>9") + '</td>' else "?" + '</td>' skip
                    '         <td style="display: yes; text-align:  right; font-weight: bold">'   + if buf-html-temp-chk.srchk-kol-tov <> ?  then fnc-convert-dot-to-colon( buf-html-temp-chk.srchk-kol-tov, "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                    '         <td style="display: yes; text-align:  right; font-weight: bold">'   + if buf-html-temp-chk.srchk-sum <> ?  then fnc-convert-dot-to-colon( buf-html-temp-chk.srchk-sum, "->>>>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                    '         <td style="display: yes; text-align:  right; font-weight: bold">'   + if buf-html-temp-chk.srchk-uch <> ? then  fnc-convert-dot-to-colon( buf-html-temp-chk.srchk-uch , "->>>>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                    '         <td style="display: yes; text-align:  right; font-weight: bold">'   + if buf-html-temp-chk.srchk-base-sum <> ?  then fnc-convert-dot-to-colon( buf-html-temp-chk.srchk-base-sum, "->>>>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                    '         <td style="display: yes; text-align:  right; font-weight: bold">'   + if  buf-html-temp-chk.srchk-base-uch <> ?  then fnc-convert-dot-to-colon(  buf-html-temp-chk.srchk-base-uch, "->>>>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                    '         <td style="display: yes; text-align:  right; font-weight: bold">'   + if  buf-html-temp-chk.srchk-kol-tov-pokup <> ?  then fnc-convert-dot-to-colon(  buf-html-temp-chk.srchk-kol-tov-pokup, "->>>>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                    '         <td style="display: yes; text-align:  right; font-weight: bold">'   + if  buf-html-temp-chk.srchk-kol-tov-uch   <> ?  then fnc-convert-dot-to-colon( buf-html-temp-chk.srchk-kol-tov-uch, "->>>>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                    '       </tr>' skip
                    .
                if p-tog-prod = yes then run tt-print-line (input buf-html-temp-chk.obj-type, input buf-html-temp-chk.obj-code, input -2 , input 2).
                if p-tog-prod = no then run tt-print-line (input buf-html-temp-chk.obj-type, input buf-html-temp-chk.obj-code, input 1 , input 2).
            end.
        end.
        else
        do:
            put stream OutStr-html unformatted
                '       <tr>' skip
                '         <td style="display: yes; text-align: center; font-weight: bold">'    '</td>' skip
                '         <td style="display: yes; text-align: center; font-weight: bold">'    '</td>' skip
                '         <td style="display: yes; text-align:  right; font-weight: bold">'    '</td>' skip
                '         <td style="display: yes; text-align:  right; font-weight: bold">'    '</td>' skip
                '         <td style="display: yes; text-align:  right; font-weight: bold">'    '</td>' skip
                '         <td style="display: yes; text-align:  right; font-weight: bold">'    '</td>' skip
                '         <td style="display: yes; text-align:  right; font-weight: bold">'    '</td>' skip
                '         <td style="display: yes; text-align:  right; font-weight: bold">'    '</td>' skip
                '         <td style="display: yes; text-align:  right; font-weight: bold">'    '</td>' skip
                '         <td style="display: yes; text-align:  right; font-weight: bold">'    '</td>' skip
                '         <td style="display: yes; text-align:  right; font-weight: bold">'    '</td>' skip
                '         <td style="display: yes; text-align:  right; font-weight: bold">'    '</td>' skip
                '         <td style="display: yes; text-align:  right; font-weight: bold">'    '</td>' skip
                '         <td style="display: yes; text-align:  right; font-weight: bold">'    '</td>' skip
                '         <td style="display: yes; text-align:  right; font-weight: bold">'    '</td>' skip
                '       </tr>' skip
                .
        end.
    end.
        do:
                put stream OutStr-html unformatted
                '     </tbody>' skip
                '   </table>' skip
                '  </body>' skip
                ' </html>' skip
                .
        output stream OutStr-html close.
    end.
end procedure.
procedure transform-tt-level  :
define input parameter v-obj-code as integer no-undo.
define input parameter v-obj-type as character no-undo.
define variable v-eff-doc-qnty as decimal   no-undo.
define variable v-object-sum   as decimal   no-undo.
define variable v-tot-r-b      as decimal   no-undo.
define variable v-pok-qnty     as integer   no-undo.
define variable v-gds-name     as character no-undo.
define variable v-cur-lvl      as integer   no-undo.
define variable v-upper-code   as integer   initial ? no-undo.
define variable v-find-grp-lvl  as integer no-undo.
define buffer buf_gds-grp     for ub.gds-grp .
define buffer buftt_temp-chk  for temp-chk .
define buffer buf2_help-chk   for help-chk .
define buffer buftt2_temp-chk for temp-chk .
  do while v-upper-code <> 0:
    v-upper-code = 0.
    for each temp-chk
       where temp-chk.grp-lvl  = v-cur-lvl
         and temp-chk.obj-type = v-obj-type
         and temp-chk.obj-code = v-obj-code
         and temp-chk.upper-code <> -1
    use-index tt-grp
    break by temp-chk.grp-code :
      if first-of (temp-chk.grp-code) then do:
        assign
          v-eff-doc-qnty = 0
          v-object-sum   = 0
          v-tot-r-b      = 0
          v-pok-qnty     = 0
        .
        find first buf_gds-grp no-lock where buf_gds-grp.node-code = temp-chk.grp-code no-error.
        if available buf_gds-grp then assign
          v-upper-code = buf_gds-grp.upper-code
          v-gds-name   = buf_gds-grp.node-name
        .
        else v-gds-name = ''.
      end.
      assign
        v-eff-doc-qnty = v-eff-doc-qnty + temp-chk.qnty
        v-object-sum   = v-object-sum   + temp-chk.sum-unbase
        v-tot-r-b      = v-tot-r-b      + temp-chk.sum-base
        v-pok-qnty     = v-pok-qnty     + temp-chk.pok-qnty
      .
      assign
        temp-chk.srchk-kol-tov-uch = temp-chk.pok-qnty   * 100 / obj-temp-chk.pok-qnty
        temp-chk.srchk-base-uch    = temp-chk.sum-base   * 100 / obj-temp-chk.sum-base
        temp-chk.srchk-uch         = temp-chk.sum-unbase * 100 / obj-temp-chk.sum-unbase
      .
      if temp-chk.grp-lvl = 0 then assign
        temp-chk.upper-code = temp-chk.grp-code
      .
      else assign
        temp-chk.upper-code = v-upper-code
        temp-chk.gds-name   = v-gds-name
      .
      if last-of (temp-chk.grp-code) and v-upper-code <> 0 then do :
        v-find-grp-lvl = temp-chk.grp-lvl + 1 .
        find first buftt_temp-chk
             where buftt_temp-chk.grp-lvl  = v-find-grp-lvl
               and buftt_temp-chk.obj-type = v-obj-type
               and buftt_temp-chk.obj-code = v-obj-code
               and buftt_temp-chk.grp-code = temp-chk.upper-code no-error.
        if not available buftt_temp-chk then do:
          create buftt_temp-chk .
          assign
            buftt_temp-chk.grp-lvl  = v-find-grp-lvl
            buftt_temp-chk.obj-type = v-obj-type
            buftt_temp-chk.obj-code = v-obj-code
            buftt_temp-chk.grp-code = temp-chk.upper-code
            buftt_temp-chk.gds-name = v-gds-name
          .
        end.
        assign
          buftt_temp-chk.qnty       = buftt_temp-chk.qnty       + v-eff-doc-qnty
          buftt_temp-chk.sum-unbase = buftt_temp-chk.sum-unbase + v-object-sum
          buftt_temp-chk.sum-base   = buftt_temp-chk.sum-base   + v-tot-r-b
          buftt_temp-chk.pok-qnty   = buftt_temp-chk.pok-qnty   + v-pok-qnty
        .
        for each help-chk where help-chk.group-chk = temp-chk.grp-code
                            and help-chk.obj-code  = v-obj-code
                            and help-chk.obj-type  = v-obj-type:
          if not can-find (first buf2_help-chk where buf2_help-chk.doc-code  = help-chk.doc-code
                                                 and buf2_help-chk.group-chk = temp-chk.upper-code
                                                 and buf2_help-chk.obj-code  = v-obj-code
                                                 and buf2_help-chk.obj-type  = v-obj-type) then do:
            create buf2_help-chk.
            assign
              buf2_help-chk.doc-code  = help-chk.doc-code
              buf2_help-chk.group-chk = temp-chk.upper-code
              buf2_help-chk.obj-code  = v-obj-code
              buf2_help-chk.obj-type  = v-obj-type
            .
          end.
        end.
        buftt_temp-chk.doc-qnty = 0 .
        for each buf2_help-chk where buf2_help-chk.group-chk = temp-chk.upper-code
                                 and buf2_help-chk.obj-code  = v-obj-code
                                 and buf2_help-chk.obj-type  = v-obj-type :
          buftt_temp-chk.doc-qnty = buftt_temp-chk.doc-qnty + 1 .
        end .
        assign
          buftt_temp-chk.srchk-kol-tov       = buftt_temp-chk.qnty       / buftt_temp-chk.doc-qnty
          buftt_temp-chk.srchk-sum           = buftt_temp-chk.sum-unbase / buftt_temp-chk.doc-qnty
          buftt_temp-chk.srchk-base-sum      = buftt_temp-chk.sum-base   / buftt_temp-chk.doc-qnty
          buftt_temp-chk.srchk-kol-tov-pokup = buftt_temp-chk.pok-qnty   / buftt_temp-chk.doc-qnty
        .
      end.
    end.
    v-cur-lvl = v-cur-lvl + 1.
  end.
  for each buftt2_temp-chk
     where buftt2_temp-chk.gds-code = 0
       and buftt2_temp-chk.obj-code = v-obj-code
       and buftt2_temp-chk.obj-type = v-obj-type
       and buftt2_temp-chk.grp-code <> 0
       and buftt2_temp-chk.grp-lvl  > 1 :
    if can-find (first buftt_temp-chk
                 where buftt_temp-chk.gds-code = 0
                   and buftt_temp-chk.obj-code = buftt2_temp-chk.obj-code
                   and buftt_temp-chk.obj-type = buftt2_temp-chk.obj-type
                   and buftt_temp-chk.grp-code = buftt2_temp-chk.grp-code
                   and buftt_temp-chk.grp-lvl  > 0
                   and buftt_temp-chk.grp-lvl <> buftt2_temp-chk.grp-lvl) then do :
      for each buftt_temp-chk
         where buftt_temp-chk.gds-code = 0
           and buftt_temp-chk.obj-code = buftt2_temp-chk.obj-code
           and buftt_temp-chk.obj-type = buftt2_temp-chk.obj-type
           and buftt_temp-chk.grp-code = buftt2_temp-chk.grp-code
           and buftt_temp-chk.grp-lvl  > 0
           and buftt_temp-chk.grp-lvl <> buftt2_temp-chk.grp-lvl :
        assign
          buftt2_temp-chk.qnty       = buftt_temp-chk.qnty       + buftt2_temp-chk.qnty
          buftt2_temp-chk.sum-unbase = buftt_temp-chk.sum-unbase + buftt2_temp-chk.sum-unbase
          buftt2_temp-chk.sum-base   = buftt_temp-chk.sum-base   + buftt2_temp-chk.sum-base
          buftt2_temp-chk.pok-qnty   = buftt_temp-chk.pok-qnty   + buftt2_temp-chk.pok-qnty
        .
        delete buftt_temp-chk.
      end .
      buftt2_temp-chk.doc-qnty = 0 .
      for each help-chk where help-chk.group-chk = buftt2_temp-chk.grp-code
                          and help-chk.obj-code  = buftt2_temp-chk.obj-code
                          and help-chk.obj-type  = buftt2_temp-chk.obj-type:
        buftt2_temp-chk.doc-qnty = buftt2_temp-chk.doc-qnty + 1.
      end.
    end .
  end.
end procedure.
procedure tt-print-line:
    define input parameter v-obj-type as character no-undo.
    define input parameter v-obj-code as integer no-undo.
    define input parameter v-upper-code like ub.gds-grp.upper-code no-undo.
    define input parameter v-print-lvl as integer no-undo.
define variable v-display as character no-undo.
    define buffer buf-grp_temp-chk for temp-chk.
    for each buf-grp_temp-chk where
        buf-grp_temp-chk.upper-code = v-upper-code and
        buf-grp_temp-chk.obj-type = v-obj-type and
        buf-grp_temp-chk.obj-code = v-obj-code
        no-lock:
          if v-print-lvl < 3 then
        do:
            v-display = "yes".
        end.
        else
        do:
            v-display = "none".
        end.
        do:
            if buf-grp_temp-chk.grp-lvl <> 0 then
            do:
                put stream OutStr-html unformatted
                    '       <tr level="' + string(v-print-lvl) + '">' skip
                    '         <td colspan = "3" style="display: yes; text-align: left; font-weight: bold ; padding-left:  '
                    + string((v-print-lvl - 1) * 10) + 'px">'
                    + string(fill(" ", ((v-print-lvl - 2) * 4)))
                    + buf-grp_temp-chk.gds-name       + '</td>' skip
                    '         <td style="display: yes; text-align: right; font-weight: bold">'  + if buf-grp_temp-chk.qnty <> ?  then fnc-convert-dot-to-colon(buf-grp_temp-chk.qnty, "->>>>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                    '         <td style="display: yes; text-align: right; font-weight: bold" >'  + if buf-grp_temp-chk.sum-unbase <> ? then fnc-convert-dot-to-colon(buf-grp_temp-chk.sum-unbase, "->>>>>>>>>>>9.99")   + '</td>' else "?" + '</td>' skip
                    '         <td style="display: yes; text-align: right; font-weight: bold" >'   + if buf-grp_temp-chk.sum-base <> ? then fnc-convert-dot-to-colon(buf-grp_temp-chk.sum-base, "->>>>>>>>>>>9.99")  + '</td>' else "?" + '</td>' skip
                    '         <td style="display: yes; text-align: right; font-weight: bold" >'    + if buf-grp_temp-chk.doc-qnty <> ? then fnc-convert-dot-to-colon( buf-grp_temp-chk.doc-qnty, "->>>>>>>>>>>9") + '</td>' else "?" + '</td>' skip
                    '         <td style="display: yes; text-align: right; font-weight: bold" >' + if buf-grp_temp-chk.pok-qnty <> ? then fnc-convert-dot-to-colon( buf-grp_temp-chk.pok-qnty, "->>>>>>>>>>>9") + '</td>' else "?" + '</td>' skip
                    '         <td style="display: yes; text-align: right; font-weight: bold" >' + if buf-grp_temp-chk.srchk-kol-tov <> ?  then fnc-convert-dot-to-colon( buf-grp_temp-chk.srchk-kol-tov, "->>>>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                    '         <td style="display: yes; text-align: right; font-weight: bold" >' + if buf-grp_temp-chk.srchk-sum <> ?  then fnc-convert-dot-to-colon( buf-grp_temp-chk.srchk-sum, "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                    '         <td style="display: yes; text-align: right; font-weight: bold" >'    +  if buf-grp_temp-chk.srchk-uch  <> ?  then fnc-convert-dot-to-colon(buf-grp_temp-chk.srchk-uch, "->>>>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                    '         <td style="display: yes; text-align: right; font-weight: bold" >'     + if buf-grp_temp-chk.srchk-base-sum <> ?  then fnc-convert-dot-to-colon( buf-grp_temp-chk.srchk-base-sum, "->>>>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                    '         <td style="display: yes; text-align: right; font-weight: bold" >'        + if  buf-grp_temp-chk.srchk-base-uch <>?   then fnc-convert-dot-to-colon( buf-grp_temp-chk.srchk-base-uch , "->>>>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                    '         <td style="display: yes; text-align: right; font-weight: bold" >'    + if  buf-grp_temp-chk.srchk-kol-tov-pokup <> ?  then fnc-convert-dot-to-colon(  buf-grp_temp-chk.srchk-kol-tov-pokup, "->>>>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                    '          <td style="display: yes; text-align:  right; font-weight: bold"  >'     +  if   buf-grp_temp-chk.srchk-kol-tov-uch   <> ?  then fnc-convert-dot-to-colon(buf-grp_temp-chk.srchk-kol-tov-uch, "->>>>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                    '       </tr>' skip
                    .
            end.
            else
            do:
                put stream OutStr-html unformatted
                    '       <tr level="' + string(v-print-lvl) + '">' skip
                    '         <td style="display: yes ;text-align: right">' +  fnc-convert-dot-to-colon(buf-grp_temp-chk.gds-code, "->>>>>>>>>999999") + '</td>' skip
                    '         <td num="0.00" style="display: yes;text-align: left;   padding-left: ' + string((v-print-lvl - 1) * 10) + 'px">'
                    + string(fill(" ", ((v-print-lvl - 2) * 4))) + buf-grp_temp-chk.gds-name
                    + '</td>' skip
                    '         <td  num="0.00" style="display: yes ;text-align: right">'  + buf-grp_temp-chk.unit +      '</td>'  skip
                    '         <td num="0.00" style="display: yes ;text-align: right" >' + if buf-grp_temp-chk.qnty <> ?  then fnc-convert-dot-to-colon( buf-grp_temp-chk.qnty, "->>>>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                    '         <td num="0.00" style="display: yes ;text-align: right">'  + if buf-grp_temp-chk.sum-unbase <> ? then fnc-convert-dot-to-colon( buf-grp_temp-chk.sum-unbase, "->>>>>>>>>9.99")   + '</td>' else "?" + '</td>' skip
                    '         <td num="0.00" style="display: yes ;text-align: right">'   + if buf-grp_temp-chk.sum-base <> ? then fnc-convert-dot-to-colon( buf-grp_temp-chk.sum-base, "->>>>>>>>>9.99")  + '</td>' else "?" + '</td>' skip
                    '         <td  style="display: yes ;text-align: right" >'    + if buf-grp_temp-chk.doc-qnty <> ? then fnc-convert-dot-to-colon( buf-grp_temp-chk.doc-qnty, "->>>>>>>>>9") + '</td>' else "?" + '</td>' skip
                    '         <td  style="display: yes ;text-align: right" >' + if buf-grp_temp-chk.pok-qnty <> ? then fnc-convert-dot-to-colon( buf-grp_temp-chk.pok-qnty, "->>>>>>>>>9") + '</td>' else "?" + '</td>' skip
                    '         <td num="0.00" style="display: yes ;text-align: right" >' + if buf-grp_temp-chk.srchk-kol-tov <> ?  then fnc-convert-dot-to-colon( buf-grp_temp-chk.srchk-kol-tov, "->>>>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                    '         <td num="0.00" style="display: yes ;text-align: right" >' + if buf-grp_temp-chk.srchk-sum <> ?  then fnc-convert-dot-to-colon( buf-grp_temp-chk.srchk-sum, "->>>>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                    '         <td num="0.00" style="display: yes ;text-align: right" >'  +  if buf-grp_temp-chk.srchk-uch  <> ?     then fnc-convert-dot-to-colon( buf-grp_temp-chk.srchk-uch,  "->>>>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                    '         <td num="0.00" style="display: yes ;text-align: right">'     + if buf-grp_temp-chk.srchk-base-sum <> ?  then fnc-convert-dot-to-colon(buf-grp_temp-chk.srchk-base-sum, "->>>>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                    '         <td num="0.00" style="display: yes ;text-align: right" >'      +  if buf-grp_temp-chk.srchk-base-uch  <> ?  then fnc-convert-dot-to-colon( buf-grp_temp-chk.srchk-base-uch, "->>>>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                    '         <td num="0.00" style="display: yes ;text-align: right" >'     + if  buf-grp_temp-chk.srchk-kol-tov-pokup <> ?  then fnc-convert-dot-to-colon(buf-grp_temp-chk.srchk-kol-tov-pokup, "->>>>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                    '         <td num="0.00" style="display: yes ;text-align: right" >'  +  if buf-grp_temp-chk.srchk-kol-tov-uch  <> ?  then fnc-convert-dot-to-colon(buf-grp_temp-chk.srchk-kol-tov-uch, "->>>>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                    '       </tr>' skip
                    .
            end.
        end.
        if buf-grp_temp-chk.grp-lvl <> 0 then run tt-print-line (input v-obj-type, input v-obj-code, input buf-grp_temp-chk.grp-code, input v-print-lvl + 1 ).
    end.
end procedure.
procedure prod-level:
define input parameter v-obj-code as integer no-undo.
define input parameter v-obj-type as character no-undo.
    define variable v-eff-doc-qnty as decimal   no-undo.
    define variable v-object-sum   as decimal   no-undo.
    define variable v-tot-r-b      as decimal   no-undo.
    define variable v-pok-qnty     as integer   no-undo.
  for each temp-chk
     where temp-chk.obj-type = v-obj-type
       and temp-chk.obj-code = v-obj-code
       and temp-chk.gds-code > 0
  break by temp-chk.grp-code :
    if first-of (temp-chk.grp-code) then do:
      assign
        v-eff-doc-qnty = 0
        v-object-sum   = 0
        v-tot-r-b      = 0
        v-pok-qnty     = 0
      .
    end.
    assign
      v-eff-doc-qnty = v-eff-doc-qnty + temp-chk.qnty
      v-object-sum   = v-object-sum   + temp-chk.sum-unbase
      v-tot-r-b      = v-tot-r-b      + temp-chk.sum-base
      v-pok-qnty     = v-pok-qnty     + temp-chk.pok-qnty
    .
    assign
      temp-chk.srchk-kol-tov-uch = temp-chk.pok-qnty   * 100 / obj-temp-chk.pok-qnty
      temp-chk.srchk-base-uch    = temp-chk.sum-base   * 100 / obj-temp-chk.sum-base
      temp-chk.srchk-uch         = temp-chk.sum-unbase * 100 / obj-temp-chk.sum-unbase
      temp-chk.upper-code        = temp-chk.grp-code
    .
    if last-of (temp-chk.grp-code) then do:
      find first prod-temp-chk
           where prod-temp-chk.gds-code = 0
             and prod-temp-chk.obj-code = temp-chk.obj-code
             and prod-temp-chk.obj-type = temp-chk.obj-type
             and prod-temp-chk.grp-code = temp-chk.grp-code
             and prod-temp-chk.grp-lvl  = 1
      use-index tt no-error .
      if available prod-temp-chk then do:
        assign
          prod-temp-chk.qnty       = v-eff-doc-qnty
          prod-temp-chk.sum-unbase = v-object-sum
          prod-temp-chk.sum-base   = v-tot-r-b
          prod-temp-chk.pok-qnty   = v-pok-qnty
        .
        assign
          prod-temp-chk.srchk-kol-tov       = prod-temp-chk.qnty       / prod-temp-chk.doc-qnty
          prod-temp-chk.srchk-sum           = prod-temp-chk.sum-unbase / prod-temp-chk.doc-qnty
          prod-temp-chk.srchk-base-sum      = prod-temp-chk.sum-base   / prod-temp-chk.doc-qnty
          prod-temp-chk.srchk-kol-tov-pokup = prod-temp-chk.pok-qnty   / prod-temp-chk.doc-qnty
        .
        assign
          prod-temp-chk.srchk-base-uch    = prod-temp-chk.sum-base   * 100 / obj-temp-chk.sum-base
          prod-temp-chk.srchk-kol-tov-uch = prod-temp-chk.pok-qnty   * 100 / obj-temp-chk.pok-qnty
          prod-temp-chk.srchk-uch         = prod-temp-chk.sum-unbase * 100 / obj-temp-chk.sum-unbase
        .
        obj-temp-chk.doc-qnty = obj-temp-chk.doc-qnty + prod-temp-chk.doc-qnty.
      end.
    end.
  end.
end procedure.
function fnc-DD-MM-YYYY returns character
(input p-dat-date as date):
    define variable result as character no-undo.
    define variable p-str-date as character no-undo.
    p-str-date = replace(string(p-dat-date,'99.99.9999'), "/", ".").
        return p-str-date.
end function.
function fnc-convert-dot-to-colon returns character
(input p-data as decimal, input p-accur as character):
    define variable result as character no-undo.
    define variable v-str-result as character no-undo.
    p-data = round(p-data, 2).
    v-str-result = trim(replace(string(p-data, p-accur), ".", ",")).
    return v-str-result.
end function.
