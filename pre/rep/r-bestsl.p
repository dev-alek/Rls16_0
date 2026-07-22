block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: 426f27c156a2, 853, rls $":U .
define variable vss-author      as character no-undo init "$Author: SShalanin $":U .
define variable vss-date        as character no-undo init "$Date: Wed Oct 19 12:26:34 2016 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-bestsl.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-bestsl.p $":U .
define variable vss-description as character no-undo init "Бестселлеры".
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
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-cntxt-host-code-obj
  ,output base-code
  )  .
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable div# as char no-undo.
define variable fr as logical no-undo .
define variable fr0 as logical no-undo .
define variable tmp#stroka as character no-undo .
define variable tmp#stroka0 as character no-undo .
define variable v-bar-code    like ub.bar-code.b-code no-undo  .
define variable s-bar-code   as character format "x(9)" no-undo .
define temp-table tmp-gds no-undo
  field id as integer
  field name      as character  format "x(256)"
  field f-name    as character  format "x(256)"
  field node-code as integer
  field lvl       as integer
 index pi id
.
define variable NEW-vat        like ub.doc-line.vat-pc    no-undo.
define variable LAST-vat       like ub.doc-line.vat-pc    no-undo.
define variable  var-vat-pc    like ub.doc-line.vat-pc    no-undo.
define variable g-ll as integer no-undo .
define variable id as integer no-undo .
define temp-table temp-gds-list no-undo
  field gds-code  like ub.goods.gds-code
  field prod-code like ub.goods.prod-code
  field grp-name  like ub.goods.grp-name
  field gds-name  like ub.goods.gds-name
  field artic     like ub.goods.artic
  field vat-pc    as decimal
   index pi is primary unique gds-code ascending
   index i1 artic     ascending
   index i2 prod-code ascending
   index i3 grp-name  ascending
   index i33 gds-name  ascending
   index i4 vat-pc    ascending
   index i5 prod-code grp-name   ascending
   index i6 grp-name  prod-code   ascending
   .
define variable sum_1     as   decimal  format "->>>>>>>>>>>9.<<<" no-undo.
define variable sum_2     as   decimal  format "->>>>>>>>>>>9.<<<" no-undo.
define variable b1-sum_1  as   decimal  format "->>>>>>>>>>>9.<<<" no-undo.
define variable b1-sum_2  as   decimal  format "->>>>>>>>>>>9.<<<" no-undo.
define variable b2-sum_1  as   decimal  format "->>>>>>>>>>>9.<<<" no-undo.
define variable b2-sum_2  as   decimal  format "->>>>>>>>>>>9.<<<" no-undo.
define variable bi-sum_1  as   decimal  format "->>>>>>>>>>>9.<<<" no-undo.
define variable bi-sum_2  as   decimal  format "->>>>>>>>>>>9.<<<" no-undo.
define variable bo-sum_1  as   decimal  format "->>>>>>>>>>>9.<<<" no-undo.
define variable bo-sum_2  as   decimal  format "->>>>>>>>>>>9.<<<" no-undo.
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
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
        Quantity = Quantity + buff-stk-line.fact-qnty
        Coast_R  = Coast_R  + buff-stk-line.sum-rubl
        Coast_V  = Coast_V  + buff-stk-line.sum-base
        VAT_R    = VAT_R    + buff-stk-line.VAT-rubl
        VAT_V    = VAT_V    + buff-stk-line.VAT-base
        SLT_R    = SLT_R    + buff-stk-line.SLT-rubl
        SLT_V    = SLT_V    + buff-stk-line.SLT-base
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
        Quantity = Quantity + buff-stk-line.fact-qnty
        Coast_R  = Coast_R  + buff-stk-line.sum-rubl
        Coast_V  = Coast_V  + buff-stk-line.sum-base
        VAT_R    = VAT_R    + buff-stk-line.VAT-rubl
        VAT_V    = VAT_V    + buff-stk-line.VAT-base
        SLT_R    = SLT_R    + buff-stk-line.SLT-rubl
        SLT_V    = SLT_V    + buff-stk-line.SLT-base
        other_R  = other_R  + buff-stk-line.other-rubl
        other_V  = other_V  + buff-stk-line.other-base
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
define input parameter x-store-code like ub.clients.obj-code   no-undo.
define input parameter x-store-type like ub.clients.obj-type   no-undo.
define input parameter x-base-type  like ub.currency.curr-abbr no-undo.
define input parameter x-base-code  like ub.currency.curr-code no-undo.
define input parameter xcrit        as int no-undo.
define input parameter xsort        as int no-undo.
define input parameter xbsamount    as int no-undo.
define input parameter xsc_name     as int no-undo.
define input parameter x-upper-code as int no-undo.
define input parameter tog-scale    as log no-undo.
define variable g#log as logical   no-undo .
define variable xclassify  as char no-undo.
define variable xsorttype  as char no-undo.
define variable xsumsonly  as log  no-undo.
define variable xshowzero  as log  no-undo.
define variable xtog-obj   as log  no-undo.
define variable xshowcost  as log  no-undo.
define variable xshowsale  as log  no-undo.
define variable xtog-lavel as log  no-undo.
define variable xvar-lavel as int  no-undo.
define variable  tprintrubl as log no-undo.
define stream  outstream.
define variable v-group as character no-undo.
define variable ostatok_end as decimal no-undo.
define variable ostatok_start as decimal no-undo.
define variable    objname           as   char     no-undo.
define variable    select-good       as   integer  no-undo.
define variable    chosedtype        as   integer  no-undo.
define variable    paytype           as   integer  no-undo.
define variable    retclassify       as   char     no-undo.
define variable    retsorttype       as   char     no-undo.
define variable    show-negativ      as   logical  no-undo.
define variable    sums-only         as   logical  no-undo.
define variable    valtype           as   integer  no-undo.
define variable    line              as   char        no-undo.
define variable    firstline         as   logical     no-undo.
define variable v#prev as decimal no-undo.
define variable tot_tqnty as decimal  no-undo.
define variable break_group as logical no-undo init true.
define variable break_group1 as logical no-undo init true.
define variable v#income as decimal  no-undo.
define variable stat     as log no-undo .
define variable inperror as log no-undo .
define variable i        as integer no-undo .
define variable p        as integer no-undo init 0 .
define variable kk        as integer no-undo init 0 .
define variable old-page as integer no-undo .
define variable new-page as integer no-undo .
define variable rid-list as character no-undo .
define variable v#abc-do as decimal no-undo.
define variable ostatok_end_day as decimal  format "->>>>>>>>>9.99<" no-undo.
define variable ostatok_start_day as decimal  format "->>>>>>>>>9.99<" no-undo.
define variable gds-zap-unit-base     like ub.goods.unit-base     no-undo.
define variable gds-zap-prt-root      like ub.goods.prt-root     no-undo .
define variable gds-zap-gds-name      like ub.goods.gds-name     no-undo .
define variable gds-zap-prod-type     like ub.goods.prod-type    no-undo .
define variable gds-zap-prod-code     like ub.goods.prod-code   no-undo .
define variable gds-zap-artic         like ub.goods.artic        no-undo .
define variable gds-zap-b-code        like ub.bar-code.b-code    no-undo .
define variable gds-type              as char no-undo.
define variable gds-zap-type          like ub.goods.gds-type     no-undo .
define variable gds-zap-grp-name      like ub.goods.grp-name     no-undo .
define variable gds-zap-prod-name     like ub.clients.obj-name   no-undo .
define variable gds-zap-price-base    like ub.stk-tot.sum-base no-undo.
define variable gds-zap-stoim-base    like ub.stk-tot.sum-base no-undo.
define variable gds-zap-qnty          like ub.stk-tot.fact-qnty  no-undo.
define variable gds-zap-nds           like ub.stk-tot.sum-base no-undo.
define variable gds-zap-np            like ub.stk-tot.sum-base no-undo.
define variable f-ostatok-start    as   char  no-undo.
define variable f-ostatok-end      as   char  no-undo.
define variable ext-doc-type as char extent 6 no-undo.
define variable ostatok-start      as   decimal extent 6 format "->>>>>>>>>9.99<" no-undo.
define variable ostatok-end        as   decimal extent 6 format "->>>>>>>>>9.99<" no-undo.
define variable b1-ostatok-start   as   decimal extent 6 format "->>>>>>>>>9.99<" no-undo.
define variable b1-ostatok-end     as   decimal extent 6 format "->>>>>>>>>9.99<" no-undo.
define variable b2-ostatok-start   as   decimal extent 6 format "->>>>>>>>>9.99<" no-undo.
define variable b2-ostatok-end     as   decimal extent 6 format "->>>>>>>>>9.99<" no-undo.
define variable bi-ostatok-start   as   decimal extent 6 format "->>>>>>>>>9.99<" no-undo.
define variable bi-ostatok-end     as   decimal extent 6 format "->>>>>>>>>9.99<" no-undo.
define variable f-qnty             as   char  no-undo.
define variable f-sumcost          as   char label "Сумма в учетных ценах" no-undo.
define variable f-sumsale          as   char label "Сумма в ценах док-та" no-undo.
define variable f-kassaqnty          as   char  no-undo.
define variable f-kassasale          as   char  no-undo.
define variable f-kassacost         as   char  no-undo.
define variable f-effect          as   char  no-undo.
define variable f-percent          as  decimal format "->>9.99"  no-undo.
define variable f-qnty_vn     as char no-undo.
define variable f-sumcost_vn  as char no-undo.
define variable f-sumsale_vn  as char no-undo.
define variable f-part_income as char no-undo.
define variable f-rest_end    as char no-undo.
define variable f-rest_start  as char no-undo.
define variable f-midcost     as char no-undo.
define variable f-midsale     as char no-undo.
define variable f-rub_nac     as char no-undo.
define variable f-proc_nac    as char no-undo.
define variable f-turnday     as char no-undo.
define variable f-period_rel  as char no-undo.
define variable frmt as character no-undo .
  assign frmt = "X(" + string(ReportPageWidth) + ')' .
define variable f-prih             as   char  no-undo.
define variable f-rash             as   char  no-undo.
define variable f-kassa            as   char  no-undo.
define variable f-inv              as   char  no-undo.
define variable f-overturn         as   char  no-undo.
define variable prih             as   decimal extent 6 format "->>>>>>>>>9.99<" no-undo.
define variable rash             as   decimal extent 6 format "->>>>>>>>>9.99<" no-undo.
define variable kassa            as   decimal extent 6 format "->>>>>>>>>9.99<" no-undo.
define variable srash             as   decimal extent 6 format "->>>>>>>>>9.99<" no-undo.
define variable skassa            as   decimal extent 6 format "->>>>>>>>>9.99<" no-undo.
define variable inv              as   decimal extent 6 format "->>>>>>>>>9.99<" no-undo.
define variable overturn         as   decimal extent 6 format "->>>>>>>>>9.99<" no-undo.
define variable b1-prih             as   decimal extent 6 format "->>>>>>>>>9.99<" no-undo.
define variable b1-rash             as   decimal extent 6 format "->>>>>>>>>9.99<" no-undo.
define variable b1-kassa            as   decimal extent 6 format "->>>>>>>>>9.99<" no-undo.
define variable b1-inv              as   decimal extent 6 format "->>>>>>>>>9.99<" no-undo.
define variable b1-overturn         as   decimal extent 6 format "->>>>>>>>>9.99<" no-undo.
define variable b2-prih             as   decimal extent 6 format "->>>>>>>>>9.99<" no-undo.
define variable b2-rash             as   decimal extent 6 format "->>>>>>>>>9.99<" no-undo.
define variable b2-kassa            as   decimal extent 6 format "->>>>>>>>>9.99<" no-undo.
define variable b2-inv              as   decimal extent 6 format "->>>>>>>>>9.99<" no-undo.
define variable b2-overturn         as   decimal extent 6 format "->>>>>>>>>9.99<" no-undo.
define variable bi-prih             as   decimal extent 6 format "->>>>>>>>>9.99<" no-undo.
define variable bi-rash             as   decimal extent 6 format "->>>>>>>>>9.99<" no-undo.
define variable bi-kassa            as   decimal extent 6 format "->>>>>>>>>9.99<" no-undo.
define variable bi-inv              as   decimal extent 6 format "->>>>>>>>>9.99<" no-undo.
define variable bi-overturn         as   decimal extent 6 format "->>>>>>>>>9.99<" no-undo.
define variable bi-sprih             as   decimal extent 6 format "->>>>>>>>>9.99<" no-undo.
define variable bi-srash             as   decimal extent 6 format "->>>>>>>>>9.99<" no-undo.
define variable bi-skassa            as   decimal extent 6 format "->>>>>>>>>9.99<" no-undo.
define variable bi-sinv              as   decimal extent 6 format "->>>>>>>>>9.99<" no-undo.
define variable bi-soverturn         as   decimal extent 6 format "->>>>>>>>>9.99<" no-undo.
define variable  fact-order-1   like ub.stk-tot.fact-order no-undo.
define variable  quantity1      like ub.stk-tot.fact-qnty  no-undo.
define variable  coast_r1       like ub.stk-tot.sum-rubl   no-undo.
define variable  coast_v1       like ub.stk-tot.sum-rubl   no-undo.
define variable  vat_r1         like ub.stk-tot.sum-rubl   no-undo.
define variable  vat_v1         like ub.stk-tot.sum-rubl   no-undo.
define variable  fact-order-2   like ub.stk-tot.fact-order no-undo.
define variable  quantity2      like ub.stk-tot.fact-qnty  no-undo.
define variable  coast2         like ub.stk-tot.sum-rubl   no-undo.
define variable  coast_r2       like ub.stk-tot.sum-rubl   no-undo.
define variable  coast_v2       like ub.stk-tot.sum-rubl   no-undo.
define variable  vat_r2         like ub.stk-tot.sum-rubl   no-undo.
define variable  vat_v2         like ub.stk-tot.sum-rubl   no-undo.
define variable  quantity    like ub.stk-tot.fact-qnty  no-undo.
define variable  coast       like ub.stk-tot.sum-rubl   no-undo.
define variable  coast_r     like ub.stk-tot.sum-rubl   no-undo.
define variable  coast_v     like ub.stk-tot.sum-rubl   no-undo.
define variable  vat_r       like ub.stk-tot.sum-rubl   no-undo.
define variable  vat_v       like ub.stk-tot.sum-rubl   no-undo.
define variable  slt_r       like ub.stk-tot.sum-rubl   no-undo.
define variable  slt_v       like ub.stk-tot.sum-rubl   no-undo.
define variable  coast3       like ub.stk-tot.sum-rubl   no-undo.
define variable  coast4       like ub.stk-tot.sum-rubl   no-undo.
define variable  temp-str as char no-undo.
define variable str as char format "x(60)" no-undo.
define variable i#i as int no-undo.
define variable gi as int no-undo.
define variable xlavel as int  no-undo.
define variable list-field as char no-undo.
define variable str10 as char no-undo.
define temp-table tmp#bs no-undo
    field qnty      like ub.ot-line.fact-qnty
    field sumcost   like ub.ot-line.sum-rubl
    field sumsale   like ub.ot-line.sum-rubl
    field kassaqnty like ub.ot-line.sum-rubl
    field kassasale like ub.ot-line.sum-rubl
    field kassacost like ub.ot-line.sum-rubl
    field effect    like ub.ot-line.sum-rubl
    field b-code    like ub.bar-code.b-code
    field artic     like ub.goods.artic
    field prod-type like ub.goods.prod-type
    field prod-code like ub.goods.prod-code
    field prt-root  like ub.goods.prt-root
    field gds-name  like ub.goods.gds-name
    field unit-base like ub.goods.unit-base
    field ext-doc-type as char
    field qnty_vn like ub.ot-line.fact-qnty
    field sumcost_vn like ub.ot-line.sum-rubl
    field sumsale_vn like ub.ot-line.sum-rubl
    field part_income as decimal
    field rest_end as decimal
    field rest_start as decimal
    field midcost as decimal
    field midsale as decimal
    field rub_nac as decimal
    field proc_nac as decimal
    field turnday as decimal
    field period_rel as decimal
    field abc as decimal
    index byqnty       qnty      ascending
    index bysumcost    sumcost   ascending
    index bysumsale    sumsale   ascending
    index byeffect     effect    ascending
    index bykassaqnty  kassaqnty ascending
    index bykassasale  kassasale ascending
    .
    define variable v-obj-code as integer no-undo.
    define variable v-obj-type as char no-undo.
    define variable v#abc as decimal no-undo.
    define variable v#qnty_vn like ub.ot-line.fact-qnty no-undo.
    define variable v#sumcost_vn like ub.ot-line.sum-rubl no-undo.
    define variable v#sumsale_vn like ub.ot-line.sum-rubl no-undo.
    define variable v#turnday as decimal no-undo.
    define variable v#period_rel as decimal no-undo.
    define variable v#rub_nac as decimal no-undo.
    define variable v#proc_nac as decimal no-undo.
    define variable v#effect-all as decimal no-undo.
    define variable v#midcost as decimal no-undo.
    define variable v#midsale as decimal no-undo.
    define variable v#part_income as decimal no-undo.
define variable v-group_qnty      as decimal no-undo.
define variable v-group_sumcost   as decimal no-undo.
define variable v-group_sumsale   as decimal no-undo.
define variable v-group_kassaqnty as decimal no-undo.
define variable v-group_kassasale as decimal no-undo.
define variable v-group_kasscost  as decimal no-undo.
define variable v-effect          as decimal no-undo.
define variable v-ostatok-end     as decimal no-undo.
define variable v-ostatok-start   as decimal no-undo.
define variable v-sumcost         as decimal no-undo.
define variable v-sumsale         as decimal no-undo.
define variable v-qnty_vn         as decimal no-undo.
define variable v-midcost         as decimal no-undo.
define variable v-midsale         as decimal no-undo.
define variable v-rub_nac         as decimal no-undo.
define variable v-proc_nac        as decimal no-undo.
define variable v-period_rel      as decimal no-undo.
define variable v-turnday         as decimal no-undo.
define variable v#ext-doc like ot-line.ext-doc-type no-undo.
define variable  v#qnty         like ub.ot-line.fact-qnty       no-undo.
define variable  v#sumcost      like ub.ot-line.sum-rubl        no-undo.
define variable  v#sumsale      like ub.ot-line.sum-rubl        no-undo.
define variable  v#kassaqnty    like ub.ot-line.sum-rubl        no-undo.
define variable  v#kassasale    like ub.ot-line.sum-rubl        no-undo.
define variable  v#kassacost    like ub.ot-line.sum-rubl        no-undo.
define variable  v#effect       like ub.ot-line.sum-rubl        no-undo.
define variable  v#b-code       like ub.bar-code.b-code      no-undo.
define variable  v#artic        like ub.goods.artic          no-undo.
define variable  v#prod-code    like ub.goods.prod-code      no-undo.
define variable  v#prod-type    like ub.goods.prod-type      no-undo.
define variable  v#prt-root     like ub.goods.prt-root       no-undo.
define variable  v#gds-name     like ub.goods.gds-name       no-undo.
define variable  v#unit-base    like ub.goods.unit-base      no-undo.
define variable  percent#1      like ub.ot-line.sum-rubl   format "->>9.99"            no-undo.
define variable  percent#all    like ub.ot-line.sum-rubl   format "->>>>>>>>>>>>9.99"  no-undo.
define variable  prtroot        like ub.gds-prt.node-code no-undo.
define variable cc as logical no-undo .
define frame zapas
        sym1 column-label ":!:!:" format "x(1)" space(0)
        gds-zap-b-code column-label  "Код! ! ":c10  space(0)
        sym2 column-label ":!:!:" format "x(1)"       space(0)
        gds-zap-artic column-label "Артикул! ! ":c16 format "x(16)" space(0)
        sym3 column-label ":!:!:" format "x(1)"                         space(0)
        gds-zap-gds-name column-label "Название товара! ! ":c38 format "x(38)" space(0)
        sym4 column-label ":!:!:" format "x(1)"                                     space(0)
        gds-zap-unit-base column-label "Ед.!изм! " format "x(3)"                  space(0)
        sym5 column-label ":!:!:" format "x(1)"                                     space(0)
        f-qnty   column-label "Количество! ! ":c15 format "x(15)"           space(0)
        sym6 column-label ":!:!:" format "x(1)" space(0)
        f-kassaqnty   column-label "в т.ч. Касса! ! ":c15  format "x(15)"   space(0)
        sym7 column-label ":!:!:" format "x(1)" space(0)
        f-sumcost     column-label "Сумма в!учетных!ценах":c15  format "x(15)"           space(0)
        sym8 column-label ":!:!:" format "x(1)" space(0)
        f-kassacost    column-label "в т.ч. Касса!в учетных!ценах":c15  format "x(15)"   space(0)
        sym13 column-label ":!:!:" format "x(1)" space(0)
        f-sumsale    column-label "Сумма в!ценах!док-та":c15 format "x(15)"           space(0)
        sym9 column-label ":!:!:" format "x(1)" space(0)
        f-kassasale    column-label "в т.ч. Касса!в ценах!док-та":c15  format "x(15)"   space(0)
        sym10 column-label ":!:!:" format "x(1)" space(0)
        f-effect              column-label "Эффективность! ! ":c15  format "x(15)"   space(0)
        sym11 column-label ":!:!:" format "x(1)" space(0)
        f-percent           column-label "%! ! ":c7  format "->>9.99"   space(0)
        sym12 column-label ":!:!:" format "x(1)" space(0)
    header
        string( "Дата печати : " + string(today,"99.99.9999") +  " , " + string(time, "hh:mm") ) at 5 format "x(35)"
        "Цены указаны в" (if tprintrubl then "РУБ" else x-base-type )
        string( "Страница " + string( page-number( outstream ), ">>>>9") ) at 147 format "x(53)" skip
        line format "x(192)" at 1
   with width 235 down stream-io use-text no-box.
        find first gds-prt where gds-prt.node-name = '_Пустая шкала':U no-lock no-error.
        if available  gds-prt then   prtroot =    gds-prt.node-code.
                              else   prtroot = 0.
     assign
        i=0
        xlavel = xvar-lavel
        select-good   = x-selectgood
        paytype       = x-set_pay_type
        retclassify   = xclassify
        retsorttype   = xsorttype
        sums-only     = xsumsonly
        show-negativ  = xshowzero
        firstline     = false.
        line          = fill("-", 235).
        valtype       = if (paytype = 1) then 0  else x-set_val_type.
        for each tmp#bs share-lock:
            delete tmp#bs .
        end.
define variable vss-include-info15 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_reports_lookup-cost':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output g#log
    )  .
end.
        cc = g#log.
define variable v-r-b-curr-code as integer no-undo .
define variable v-r-b-scale as integer no-undo .
define variable v-r-b-rate  as decimal no-undo .
define variable v-r-b-abbr as character no-undo .
define variable v-cur-base as decimal no-undo .
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run r-b-curr in g#library
  (input  v-cntxt-host-code-obj
  ,output v-r-b-curr-code
  )  .
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  v-r-b-curr-code
  ,input  today
  ,output v-r-b-rate
  ,output v-r-b-scale
  ,output v-r-b-abbr
  )  .
        run report-execute .
procedure report-execute :
  if (valtype=0 and x-base-code=0)  or valtype=1
                                then   assign tprintrubl = yes .
                                else   assign tprintrubl = no .
  run waitfram-show ( 'Подождите ...' ) .
output stream outstream to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size  value(ReportPageHeight) .
   if xtog-obj  then do:
            for each obj-list no-lock:
                x-store-type = obj-list.obj-type.
                x-store-code = obj-list.obj-code.
                run report-exec1 .
            end.
                                               end.
  else
    run report-exec1.
  hide   stream outstream frame zapas .
  output stream outstream close.
  if Make-Excel then output stream ForExcel close.
  run waitfram-hide .
  define variable v-user-action as character no-undo .
  define variable v-printed as logical   no-undo .
  define variable disabledoptions as integer   no-undo .
define variable v-orient-page as character no-undo .
run How-name in this-procedure (
    input ReportPageHeight,
    input ReportPageWidth,
    output v-orient-page )
    .
if v-orient-page = "A4-lans":U then DisabledOptions = 8 .
                               else DisabledOptions = 0 .
  run gbl/prnfilen.w
    (input  ""
    ,input  disabledoptions
    ,input  string(session :temp-directory) + "rpt" + string( g#report-num )
    ,input ReportFontNum
    ,output v-user-action
    ,output v-printed
    ) .
end procedure.
procedure foreach :
 gi = gi + 1.
If Integer(50) = 0 Then Temp1  = 100  .
                      Else Temp1 = Integer(50) .
     IF ( gi modulo Temp1 = 0 ) AND ( gi >= Temp1 ) then
         RUN waitfram-show( "Обработано строк : " + string( gi )) .
  run clear-item .
   run ob-line (
      input   x-store-code   ,
      input   x-store-type   ,
      input   gds-zap-artic       ,
      input   gds-zap-prod-code   ,
      input   gds-zap-prod-type   ,
      input   fact-order-1,
      input   fact-order-2,
      input   'cost':U    ,
      input   '##,##':U,
      input   ""      ,
      input   xtog-obj ).
end procedure.
procedure display-line :
 end procedure.
procedure print-header :
if not firstline then  run display-title .
    firstline = true .
    if xtog-obj and   x-selectobject <> "currency":u   then  do:
          PUT stream  OutStream  UNFORMATTED  "ПО ОБЪЕКТУ : " + caps(objname)  at 30 format "x(170)" skip.
          end.
     form with FRAME ZAPAS .  DOWN stream   OutStream 1 with FRAME ZAPAS .
   end procedure.
procedure print-footer :
       run u-line.
       end procedure.
procedure u-line :
underline stream outstream  sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12
    gds-zap-b-code
    gds-zap-artic
    gds-zap-gds-name
    gds-zap-unit-base
    f-qnty
    f-sumcost
    f-kassaqnty
    f-sumsale
    f-kassacost
    f-kassasale
    f-effect
    f-percent
        with FRAME ZAPAS .
        DOWN stream   OutStream 1 with FRAME ZAPAS.
        end procedure.
procedure calcitog :
    run ostatok (
        input x-store-code  ,
        input x-store-type  ,x-tog-shift,
        input x-date-start - 1 ,
        input date('')      ,  x-shift-start,x-shift-end,
        input 'cost':U   ,
        input '##,##':U,
        input xtog-obj ,
        output  quantity1  ,
        output  coast_r1   ,
        output  coast_v1   ,
        output  vat_r1     ,
        output  vat_v1     ,
        output  fact-order-1 ).
    run ostatok (
        input x-store-code  ,
        input x-store-type  ,x-tog-shift,
        input x-date-start  ,
        input x-date-end    ,  x-shift-start,x-shift-end,
        input 'cost':U   ,
        input '##,##':U,
        input xtog-obj ,
        output  quantity2  ,
        output  coast_r2   ,
        output  coast_v1   ,
        output  vat_r1     ,
        output  vat_v1     ,
        output  fact-order-2 ).
end procedure.
procedure display-bi  :
end procedure.
procedure display-b1  :
end procedure.
procedure display-b2  :
end procedure.
procedure clear-b1  :
 end procedure.
procedure clear-b2  :
end procedure.
procedure clear-bi  :
end procedure.
procedure display-title :
   PUT stream  OutStream  UNFORMATTED  string(v-cntxt-host-name-obj +  " , " + x-store-type  +  " " + objname) at 50 format "x(85)" skip(2)
          reportname  at 35 format "x(170)" skip
          trim(str1)  at 35 format "x(75)" skip.
     repeat i = 1 to num-entries(str2,chr(10)) :
      PUT stream  OutStream  UNFORMATTED  entry(i,str2,chr(10))  at 1 format "x(170)" skip.
     end.
    i=0.
     repeat i = 1 to num-entries(str3,chr(10)) :
      PUT stream  OutStream  UNFORMATTED  entry(i,str3,chr(10))  at 1 format "x(170)" skip.
     end.
    i=0.
     repeat i = 1 to num-entries(str4,chr(10)) :
      PUT stream  OutStream  UNFORMATTED  entry(i,str4,chr(10))  at 1 format "x(170)" skip.
     end.
    i=0.
     repeat i = 1 to num-entries(reportheader,chr(10)) :
      PUT stream  OutStream  UNFORMATTED  entry(i,reportheader,chr(10))  at 1 format "x(170)" skip.
     end.
    i=0.
      run ColumnTitle in this-procedure .
   run rep/extitle.p (1) .
end procedure.
procedure ob-line  :
define input  parameter x-store-code   like ub.clients.obj-code     no-undo.
define input  parameter x-store-type   like ub.clients.obj-type     no-undo.
define input  parameter x-artic        like ub.ot-line.artic        no-undo.
define input  parameter x-prod-code    like ub.ot-line.prod-code    no-undo.
define input  parameter x-prod-type    like ub.ot-line.prod-type    no-undo.
define input  parameter x-fact-order-1   like ub.ot-line.fact-order   no-undo.
define input  parameter x-fact-order-2   like ub.ot-line.fact-order   no-undo.
define input  parameter x-sum-type       like ub.ot-line.sum-type     no-undo.
define input  parameter x-cat-id         like ub.ot-line.cat-id       no-undo.
define input  parameter x-ext-doc-type   like ub.ot-line.ext-doc-type no-undo.
define input  parameter xtog-obj           as log no-undo.
define variable v-ostatok_start as decimal no-undo.
define variable v-ostatok_end as decimal no-undo.
define variable  tt#          as   int                 no-undo.
ostatok_start_day = 0.
 ostatok_end_day  = 0.
v#period_rel = 0.
v#turnday = 0 .
  for each obj-list no-lock:
           run ost-line (
                     input   obj-list.obj-code
                    ,input   obj-list.obj-type
                    ,input   gds-zap-artic
                    ,input   gds-zap-prod-code
                    ,input   gds-zap-prod-type
                    ,input   x-tog-shift
                    ,input   fact-order-1
                    ,input   'cost':U
                    ,input   '##,##':U
                    ,input   true
                    ,output  v-ostatok_start
                    ,output  coast_r
                    ,output  coast_v
                    ,output  vat_r
                    ,output  vat_v
                    ,output  slt_r
                    ,output  slt_v
                    ).
                  run ost-line (
                     input   obj-list.obj-code
                    ,input   obj-list.obj-type
                    ,input   gds-zap-artic
                    ,input   gds-zap-prod-code
                    ,input   gds-zap-prod-type
                    ,input   x-tog-shift
                    ,input   fact-order-2
                    ,input   'cost':U
                    ,input   '##,##':U
                    ,input   true
                    ,output  v-ostatok_end
                    ,output  coast_r2
                    ,output  coast_v2
                    ,output  vat_r
                    ,output  vat_v
                    ,output  slt_r
                    ,output  slt_v
                    ).
       v-obj-code = obj-list.obj-code .
       v-obj-type = obj-list.obj-type.
      ostatok_start_day =  ostatok_start_day + v-ostatok_start.
      ostatok_end_day =  ostatok_end_day + v-ostatok_end.
   if  xtog-obj then
       if   not(    x-store-type     = obj-list.obj-type
            and    x-store-code      = obj-list.obj-code ) then next.
     for each ot-line where
                        ot-line.artic         = x-artic
                  and   ot-line.fact-order   <= x-fact-order-2
                  and   ot-line.fact-order   >= x-fact-order-1
                  and   ot-line.obj-code     = obj-list.obj-code
                  and   ot-line.obj-type     = obj-list.obj-type
                  and   ot-line.prod-code    = x-prod-code
                  and   ot-line.prod-type    = x-prod-type
                  and   (ot-line.sum-type    = 'cost':U or ot-line.sum-type = 'sale':U or
                         ot-line.sum-type    = 'cssr':U or ot-line.sum-type = 'sasr':U  )
                  no-lock :
 if ot-line.sum-type = 'cost':U or
    ot-line.sum-type = 'cssr':U then tt# = 0.
                                           else tt# = 3 .
        case ot-line.ext-doc-type:
            when       'ee':U    or
            when       're':U  or
            when       'em':U       or
            when       'wm':U
            then
                do:
                    assign
                        rash[1 + tt#] = rash[1 + tt#]   +  ot-line.fact-qnty
                        rash[2 + tt#] = rash[2 + tt#]   + ( if tprintrubl then ot-line.sum-rubl else ot-line.sum-base )
                        .
                    if ot-line.ext-doc-type <> 'ee':U  then
                    do:
                        assign
                        bi-rash[1 + tt#] = bi-rash[1 + tt#]   +  ot-line.fact-qnty
                        bi-rash[2 + tt#] = bi-rash[2 + tt#]   + ( if tprintrubl then ot-line.sum-rubl else ot-line.sum-base )
                            .
                    end.
                end.
            when    'es':U or
            when       'rs':U then
                do:
                    assign
                        kassa[1 + tt#] = kassa[1 + tt#]   +  ot-line.fact-qnty
                        kassa[2 + tt#] = kassa[2 + tt#]   +  ( if tprintrubl then ot-line.sum-rubl else ot-line.sum-base ).
                    if ot-line.ext-doc-type <> 'es':U  then
                    do:
                        assign
                            bi-kassa[1 + tt#] = bi-kassa[1 + tt#]   +  ot-line.fact-qnty
                            bi-kassa[2 + tt#] = bi-kassa[2 + tt#]   +  ( if tprintrubl then ot-line.sum-rubl else ot-line.sum-base )
                            .
                    end.
                end.
        end case.
   end.
  end.
end procedure.
PROCEDURE ostatok :
def input parameter x-store-code  like ub.clients.obj-code    no-undo.
def input parameter x-store-type  like ub.clients.obj-type    no-undo.
def input parameter x-tog-shift   as   logical             no-undo.
def input parameter x-date-start  like ub.stk-tot.Fact-date   no-undo.
def input parameter x-date-end    like ub.stk-tot.Fact-date   no-undo.
def input parameter x-shift-start as integer               no-undo.
def input parameter x-shift-end   as integer               no-undo.
def input parameter x-sum-type    like ub.stk-tot.sum-type    no-undo.
def input parameter x-cat-id      like ub.stk-tot.cat-id      no-undo.
def input parameter xTog-obj   as log no-undo.
def output parameter Quantity    like ub.stk-tot.fact-qnty   no-undo.
def output parameter Coast_R     like ub.stk-tot.sum-rubl    no-undo.
def output parameter Coast_V     like ub.stk-tot.sum-rubl    no-undo.
def output parameter VAT_R       like ub.stk-tot.sum-rubl    no-undo.
def output parameter VAT_V       like ub.stk-tot.sum-rubl    no-undo.
def output parameter Fact-order  like ub.stk-tot.Fact-order  no-undo.
def var              Fact-order#   like ub.stk-tot.Fact-order  no-undo.
def var              Fact-orderS   as char  no-undo.
def var x-date-start-t  like ub.stk-tot.shift-date   no-undo.
   Assign
      Fact-order   = 0
      Quantity     = 0
      Coast_R      = 0
      Coast_V      = 0
      VAT_R        = 0
      VAT_V        = 0 .
 x-date-start-t  = x-date-start + 1 .
IF x-date-end = date('') then DO:
   Fact-order = 0 .
   for each obj-list
       where  ( not xtog-obj or
              ( x-store-type = obj-list.obj-type and x-store-code = obj-list.obj-code ))
              no-lock :
      if  x-tog-shift = false then do:
                       find last ub.stk-tot where ub.stk-tot.obj-type = obj-list.obj-type and                             ub.stk-tot.obj-code = obj-list.obj-code and                             ub.stk-tot.sum-type = x-sum-type and                             ub.stk-tot.cat-id   = x-cat-id   and
                            ub.stk-tot.Fact-date <=  x-date-start
                            and ub.stk-tot.shift-num = 0
                            USE-INDEX fact-date no-lock no-error .
           if Available ub.stk-tot THEN  Assign                           Quantity     = Quantity   + ub.stk-tot.fact-qnty                           Coast_R      = Coast_R    + ub.stk-tot.sum-rubl                           Coast_V      = Coast_V    + ub.stk-tot.sum-base                           VAT_R        = VAT_R      + ub.stk-tot.VAT-rubl                           VAT_V        = VAT_V      + ub.stk-tot.VAT-base                           Fact-order#  = ub.stk-tot.Fact-order.
      End.
      Else  DO :
          find last ub.stk-tot where ub.stk-tot.obj-type = obj-list.obj-type and                             ub.stk-tot.obj-code = obj-list.obj-code and                             ub.stk-tot.sum-type = x-sum-type and                             ub.stk-tot.cat-id   = x-cat-id   and
           (ub.stk-tot.shift-date  = x-date-start-t and
            ub.stk-tot.shift-num  < x-shift-start or
            ub.stk-tot.shift-date  < x-date-start-t  )
            and ub.stk-tot.shift-num  > 0
            USE-INDEX Shift-num no-lock no-error .
         If Available ub.stk-tot then  Assign                           Quantity     = Quantity   + ub.stk-tot.fact-qnty                           Coast_R      = Coast_R    + ub.stk-tot.sum-rubl                           Coast_V      = Coast_V    + ub.stk-tot.sum-base                           VAT_R        = VAT_R      + ub.stk-tot.VAT-rubl                           VAT_V        = VAT_V      + ub.stk-tot.VAT-base                           Fact-order#  = ub.stk-tot.Fact-order.
        END.
    If Fact-order < Fact-order#  and Fact-order# <> 0  THEN  Fact-order = Fact-order# .
  End.
End.
Else DO:
  For each obj-list  WHERE
     (NOT xTog-obj OR (x-store-type = obj-list.obj-type AND x-store-code = obj-list.obj-code))
      no-lock :
   IF  x-TOG-Shift = False Then DO:
       find last ub.stk-tot where ub.stk-tot.obj-type = obj-list.obj-type and                             ub.stk-tot.obj-code = obj-list.obj-code and                             ub.stk-tot.sum-type = x-sum-type and                             ub.stk-tot.cat-id   = x-cat-id   and
            ub.stk-tot.Fact-date <= x-date-end
            and ub.stk-tot.shift-num = 0
            USE-INDEX fact-date no-lock no-error.
       if available ub.stk-tot then  Assign                           Quantity     = Quantity   + ub.stk-tot.fact-qnty                           Coast_R      = Coast_R    + ub.stk-tot.sum-rubl                           Coast_V      = Coast_V    + ub.stk-tot.sum-base                           VAT_R        = VAT_R      + ub.stk-tot.VAT-rubl                           VAT_V        = VAT_V      + ub.stk-tot.VAT-base                           Fact-order#  = ub.stk-tot.Fact-order.
   END.
   Else DO:
        find last ub.stk-tot where ub.stk-tot.obj-type = obj-list.obj-type and                             ub.stk-tot.obj-code = obj-list.obj-code and                             ub.stk-tot.sum-type = x-sum-type and                             ub.stk-tot.cat-id   = x-cat-id   and
            (ub.stk-tot.shift-date  = x-date-end and
            ub.stk-tot.shift-num  <= x-shift-end or
            ub.stk-tot.shift-date  < x-date-end       ) and
            ub.stk-tot.shift-num   > 0      use-index shift-num no-lock no-error.
            if Available ub.stk-tot THEN Assign                           Quantity     = Quantity   + ub.stk-tot.fact-qnty                           Coast_R      = Coast_R    + ub.stk-tot.sum-rubl                           Coast_V      = Coast_V    + ub.stk-tot.sum-base                           VAT_R        = VAT_R      + ub.stk-tot.VAT-rubl                           VAT_V        = VAT_V      + ub.stk-tot.VAT-base                           Fact-order#  = ub.stk-tot.Fact-order.
    End.
    if Fact-order < Fact-order#  THEN  Fact-order = Fact-order#.
  End.
End.
END PROCEDURE.
procedure report-exec1  :
   find first clients where x-store-type = clients.obj-type and
                            x-store-code = clients.obj-code no-lock no-error.
           if available clients then  objname = clients.obj-name.
                                         else  objname="объект не определен".
  run waitfram-show (objname) .
  form with frame zapas .
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
form header
  line format "x(220)" at 1 skip
  "Продолжение - на следующей странице" at 30 skip
  with frame bottomframe width 235 page-bottom no-labels no-box .
view stream outstream frame bottomframe .
  run calcitog .
  run print-header .
      i = 0.
      case select-good :
        when 1      then do:
  if x-selectobject = "currency":u  or  xtog-obj then do:
        for each gds-obj where
                              gds-obj.obj-type = x-store-type    and
                              gds-obj.obj-code = x-store-code
                              and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
                              and
            can-find(first ub.ot-line where
                  ub.ot-line.obj-code     = gds-obj.obj-code
            and   ub.ot-line.obj-type     = gds-obj.obj-type
            and   ub.ot-line.artic        = gds-obj.artic
            and   ub.ot-line.prod-code    = gds-obj.prod-code
            and   ub.ot-line.prod-type    = gds-obj.prod-type
            and   ub.ot-line.fact-order   <= fact-order-2
            and   ub.ot-line.fact-order   >= fact-order-1
            and   ub.ot-line.sum-type      = 'cost':U
            and   (ub.ot-line.ext-doc-type = 'ev':U      or
                  ub.ot-line.ext-doc-type = 'ee':U       or
                  ub.ot-line.ext-doc-type = 're':U   or
                  ub.ot-line.ext-doc-type = 'em':U        or
                  ub.ot-line.ext-doc-type = 'wm':U        or
                  ub.ot-line.ext-doc-type = 'es':U  or
                  ub.ot-line.ext-doc-type = 'rs':U)
                  no-lock ) = true
                                    no-lock,
                        first goods  where
                              gds-obj.prod-code  = goods.prod-code and
                              gds-obj.prod-type  = goods.prod-type and
                              gds-obj.artic      = goods.artic       no-lock
                    :
                    run item-goods ( "1" , "goods" ) .
      end.
  end.
  else do:
  for each goods where
      can-find(first gds-obj where gds-obj.prod-code   =  goods.prod-code  and
                  gds-obj.prod-type  = goods.prod-type    and
                  gds-obj.artic      = goods.artic        and
                  lookup (gds-obj.obj-type +  '#' +  string( gds-obj.obj-code) , str-obj )  > 0
                  and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
                    and
                can-find(first ub.ot-line where
                        ub.ot-line.obj-code     = gds-obj.obj-code
                  and   ub.ot-line.obj-type     = gds-obj.obj-type
                  and   ub.ot-line.artic        = gds-obj.artic
                  and   ub.ot-line.prod-code    = gds-obj.prod-code
                  and   ub.ot-line.prod-type    = gds-obj.prod-type
                  and   ub.ot-line.fact-order   <= fact-order-2
                  and   ub.ot-line.fact-order   >= fact-order-1
                  and   ub.ot-line.sum-type      = 'cost':U
                  and   (ub.ot-line.ext-doc-type = 'ev':U      or
                        ub.ot-line.ext-doc-type = 'ee':U       or
                        ub.ot-line.ext-doc-type = 're':U       or
                        ub.ot-line.ext-doc-type = 'em':U        or
                        ub.ot-line.ext-doc-type = 'wm':U        or
                        ub.ot-line.ext-doc-type = 'es':U  or
                        ub.ot-line.ext-doc-type = 'rs':U)
                        no-lock ) = true ) = true
                    no-lock
                    :
                    run item-goods ("1" , "goods" ) .
     end.
  end.
  end.
        when 2      then do:
  IF x-SelectObject = "currency":U  OR  xTog-obj THEN DO:
      For  EACH gds-obj
                  where gds-obj.obj-code   = x-store-code
                  AND  gds-obj.obj-type   = x-store-type
                       and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
                       and
                 can-find(First ub.ot-line where
                        ub.ot-line.obj-code     = gds-obj.obj-code
                  AND   ub.ot-line.obj-type     = gds-obj.obj-type
                  AND   ub.ot-line.artic        = gds-obj.artic
                  AND   ub.ot-line.prod-code    = gds-obj.prod-code
                  AND   ub.ot-line.prod-type    = gds-obj.prod-type
                  AND   ub.ot-line.fact-order   <= Fact-order-2
                  AND   ub.ot-line.fact-order   >= Fact-order-1
                  AND   ub.ot-line.sum-type      = 'cost':U
                  AND   (ub.ot-line.ext-doc-type = 'ev':U      OR
                        ub.ot-line.ext-doc-type = 'ee':U       OR
                        ub.ot-line.ext-doc-type = 're':U   OR
                        ub.ot-line.ext-doc-type = 'em':U        OR
                        ub.ot-line.ext-doc-type = 'wm':U        OR
                        ub.ot-line.ext-doc-type = 'es':U  OR
                        ub.ot-line.ext-doc-type = 'rs':U)
                        no-lock use-index art-ot) = true
                                          no-lock,
            First  tmp#grp
                  WHERE  gds-obj.grp-name   begins tmp#grp.grp-name
                      no-lock ,
              First Goods
                 where gds-obj.prod-code  = Goods.prod-code and
                       gds-obj.prod-type  = Goods.prod-type and
                       gds-obj.artic      = Goods.artic no-lock  Use-index pi
                  :
                  Run Item-Goods ( "1" , "goods" ) .
      End.
  End.
  Else DO:
  For EACH goods  where
        can-find(First  tmp#grp  WHERE  goods.grp-name   begins tmp#grp.grp-name  no-lock ) = true
        AND
        CAN-find(first gds-obj where gds-obj.prod-code   = goods.prod-code     and
                            gds-obj.prod-type  = goods.prod-type    and
                            gds-obj.artic      = goods.artic        and
                            lookup (gds-obj.obj-type +  '#' +  string( gds-obj.obj-code) , STR-obj )  > 0
                            and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
                             And
                          can-find (First ub.ot-line where
                                  ub.ot-line.obj-code     = gds-obj.obj-code
                            AND   ub.ot-line.obj-type     = gds-obj.obj-type
                            AND   ub.ot-line.artic        = gds-obj.artic
                            AND   ub.ot-line.prod-code    = gds-obj.prod-code
                            AND   ub.ot-line.prod-type    = gds-obj.prod-type
                            AND   ub.ot-line.fact-order   <= Fact-order-2
                            AND   ub.ot-line.fact-order   >= Fact-order-1
                            AND   ub.ot-line.sum-type      = 'cost':U
                            AND   (ub.ot-line.ext-doc-type = 'ev':U      OR
                                  ub.ot-line.ext-doc-type = 'ee':U       OR
                                  ub.ot-line.ext-doc-type = 're':U       OR
                                  ub.ot-line.ext-doc-type = 'em':U        OR
                                  ub.ot-line.ext-doc-type = 'wm':U        OR
                                  ub.ot-line.ext-doc-type = 'es':U  OR
                                  ub.ot-line.ext-doc-type = 'rs':U)
                                  no-lock use-index art-ot) = true no-lock) = true
                              :
         Run Item-Goods ( "1" , "goods" ) .
     End.
  End.
  end.
        when 3     then do:
  IF x-SelectObject = "currency":U  OR  xTog-obj THEN DO:
   For  EACH gds-obj
                WHERE  gds-obj.obj-code   = x-store-code
                  AND  gds-obj.obj-type   = x-store-type
                  and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
                  And
                 can-find(First ub.ot-line where
                        ub.ot-line.obj-code     = gds-obj.obj-code
                  AND   ub.ot-line.obj-type     = gds-obj.obj-type
                  AND   ub.ot-line.artic        = gds-obj.artic
                  AND   ub.ot-line.prod-code    = gds-obj.prod-code
                  AND   ub.ot-line.prod-type    = gds-obj.prod-type
                  AND   ub.ot-line.fact-order   <= Fact-order-2
                  AND   ub.ot-line.fact-order   >= Fact-order-1
                  AND   ub.ot-line.sum-type      = 'cost':U
                  AND   (ub.ot-line.ext-doc-type = 'ev':U      OR
                        ub.ot-line.ext-doc-type = 'ee':U       OR
                        ub.ot-line.ext-doc-type = 're':U       OR
                        ub.ot-line.ext-doc-type = 'em':U        OR
                        ub.ot-line.ext-doc-type = 'wm':U        OR
                        ub.ot-line.ext-doc-type = 'es':U  OR
                        ub.ot-line.ext-doc-type = 'rs':U)
                        no-lock use-index art-ot) = true
                 AND
                CAN-Find ( First G#cli
                          Where gds-obj.prod-code  = g#cli.obj-code
                          AND   gds-obj.prod-type  = g#cli.obj-type
                          no-lock ) = true
                  no-lock,
            First Goods
                 where gds-obj.prod-code  = Goods.prod-code and
                       gds-obj.prod-type  = Goods.prod-type and
                       gds-obj.artic      = Goods.artic no-lock  Use-index pi :
                  Run Item-Goods ( "1" , "goods" ) .
        End.
   End.
   Else DO:
  For EACH goods  where
         CAN-Find ( First G#cli
                  Where goods.prod-code  = g#cli.obj-code
                  AND   goods.prod-type  = g#cli.obj-type
                  no-lock ) = true
          AND
               can-find(first gds-obj where gds-obj.prod-code   =  goods.prod-code  and
                            gds-obj.prod-type  = goods.prod-type    and
                            gds-obj.artic      = goods.artic        and
                            lookup (gds-obj.obj-type +  '#' +  string( gds-obj.obj-code) , STR-obj )  > 0
                            and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
                             And
                          can-find(First ub.ot-line where
                                  ub.ot-line.obj-code     = gds-obj.obj-code
                            AND   ub.ot-line.obj-type     = gds-obj.obj-type
                            AND   ub.ot-line.artic        = gds-obj.artic
                            AND   ub.ot-line.prod-code    = gds-obj.prod-code
                            AND   ub.ot-line.prod-type    = gds-obj.prod-type
                            AND   ub.ot-line.fact-order   <= Fact-order-2
                            AND   ub.ot-line.fact-order   >= Fact-order-1
                            AND   ub.ot-line.sum-type      = 'cost':U
                            AND   (ub.ot-line.ext-doc-type = 'ev':U      OR
                                  ub.ot-line.ext-doc-type = 'ee':U       OR
                                  ub.ot-line.ext-doc-type = 're':U   OR
                                  ub.ot-line.ext-doc-type = 'em':U        OR
                                  ub.ot-line.ext-doc-type = 'wm':U        OR
                                  ub.ot-line.ext-doc-type = 'es':U  OR
                                  ub.ot-line.ext-doc-type = 'rs':U)
                                  no-lock use-index art-ot) = true ) = TRUE
                             no-lock
                             :
         Run Item-Goods ( "1" , "goods" ) .
     End.
  End.
  end.
        when 4   then do:
  if x-selectobject = "currency":u  or  xtog-obj then do:
        for each gds-obj where
                              gds-obj.obj-type = x-store-type    and
                              gds-obj.obj-code = x-store-code
                              and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
                              and
            can-find(first ub.ot-line where
                  ub.ot-line.obj-code     = gds-obj.obj-code
            and   ub.ot-line.obj-type     = gds-obj.obj-type
            and   ub.ot-line.artic        = gds-obj.artic
            and   ub.ot-line.prod-code    = gds-obj.prod-code
            and   ub.ot-line.prod-type    = gds-obj.prod-type
            and   ub.ot-line.fact-order   <= fact-order-2
            and   ub.ot-line.fact-order   >= fact-order-1
            and   ub.ot-line.sum-type      = 'cost':U
            and   (ub.ot-line.ext-doc-type = 'ev':U      or
                  ub.ot-line.ext-doc-type = 'ee':U       or
                  ub.ot-line.ext-doc-type = 're':U   or
                  ub.ot-line.ext-doc-type = 'em':U        or
                  ub.ot-line.ext-doc-type = 'wm':U        or
                  ub.ot-line.ext-doc-type = 'es':U  or
                  ub.ot-line.ext-doc-type = 'rs':U)
                  no-lock ) = true
                                    no-lock,
                        first gds-list  where
                              gds-obj.prod-code  = gds-list.prod-code and
                              gds-obj.prod-type  = gds-list.prod-type and
                              gds-obj.artic      = gds-list.artic       no-lock
                    :
                    run item-goods ( "1" , "gds-list" ) .
      end.
  end.
  else do:
  for each gds-list where
      can-find(first gds-obj where gds-obj.prod-code   =  gds-list.prod-code  and
                  gds-obj.prod-type  = gds-list.prod-type    and
                  gds-obj.artic      = gds-list.artic        and
                  lookup (gds-obj.obj-type +  '#' +  string( gds-obj.obj-code) , str-obj )  > 0
                  and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
                    and
                can-find(first ub.ot-line where
                        ub.ot-line.obj-code     = gds-obj.obj-code
                  and   ub.ot-line.obj-type     = gds-obj.obj-type
                  and   ub.ot-line.artic        = gds-obj.artic
                  and   ub.ot-line.prod-code    = gds-obj.prod-code
                  and   ub.ot-line.prod-type    = gds-obj.prod-type
                  and   ub.ot-line.fact-order   <= fact-order-2
                  and   ub.ot-line.fact-order   >= fact-order-1
                  and   ub.ot-line.sum-type      = 'cost':U
                  and   (ub.ot-line.ext-doc-type = 'ev':U      or
                        ub.ot-line.ext-doc-type = 'ee':U       or
                        ub.ot-line.ext-doc-type = 're':U       or
                        ub.ot-line.ext-doc-type = 'em':U        or
                        ub.ot-line.ext-doc-type = 'wm':U        or
                        ub.ot-line.ext-doc-type = 'es':U  or
                        ub.ot-line.ext-doc-type = 'rs':U)
                        no-lock ) = true ) = true
                    no-lock
                    :
                    run item-goods ("1" , "gds-list" ) .
     end.
  end.
  end.
        when 5      then do:
  if x-selectobject = "currency":u  or  xtog-obj then do:
        for each gds-obj where
                              gds-obj.obj-type = x-store-type    and
                              gds-obj.obj-code = x-store-code
                              and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
                              and
            can-find(first ub.ot-line where
                  ub.ot-line.obj-code     = gds-obj.obj-code
            and   ub.ot-line.obj-type     = gds-obj.obj-type
            and   ub.ot-line.artic        = gds-obj.artic
            and   ub.ot-line.prod-code    = gds-obj.prod-code
            and   ub.ot-line.prod-type    = gds-obj.prod-type
            and   ub.ot-line.fact-order   <= fact-order-2
            and   ub.ot-line.fact-order   >= fact-order-1
            and   ub.ot-line.sum-type      = 'cost':U
            and   (ub.ot-line.ext-doc-type = 'ev':U      or
                  ub.ot-line.ext-doc-type = 'ee':U       or
                  ub.ot-line.ext-doc-type = 're':U   or
                  ub.ot-line.ext-doc-type = 'em':U        or
                  ub.ot-line.ext-doc-type = 'wm':U        or
                  ub.ot-line.ext-doc-type = 'es':U  or
                  ub.ot-line.ext-doc-type = 'rs':U)
                  no-lock ) = true
                                    no-lock,
                        first gds-list  where
                              gds-obj.prod-code  = gds-list.prod-code and
                              gds-obj.prod-type  = gds-list.prod-type and
                              gds-obj.artic      = gds-list.artic       no-lock
                    :
                    run item-goods ( "1" , "gds-list" ) .
      end.
  end.
  else do:
  for each gds-list where
      can-find(first gds-obj where gds-obj.prod-code   =  gds-list.prod-code  and
                  gds-obj.prod-type  = gds-list.prod-type    and
                  gds-obj.artic      = gds-list.artic        and
                  lookup (gds-obj.obj-type +  '#' +  string( gds-obj.obj-code) , str-obj )  > 0
                  and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
                    and
                can-find(first ub.ot-line where
                        ub.ot-line.obj-code     = gds-obj.obj-code
                  and   ub.ot-line.obj-type     = gds-obj.obj-type
                  and   ub.ot-line.artic        = gds-obj.artic
                  and   ub.ot-line.prod-code    = gds-obj.prod-code
                  and   ub.ot-line.prod-type    = gds-obj.prod-type
                  and   ub.ot-line.fact-order   <= fact-order-2
                  and   ub.ot-line.fact-order   >= fact-order-1
                  and   ub.ot-line.sum-type      = 'cost':U
                  and   (ub.ot-line.ext-doc-type = 'ev':U      or
                        ub.ot-line.ext-doc-type = 'ee':U       or
                        ub.ot-line.ext-doc-type = 're':U       or
                        ub.ot-line.ext-doc-type = 'em':U        or
                        ub.ot-line.ext-doc-type = 'wm':U        or
                        ub.ot-line.ext-doc-type = 'es':U  or
                        ub.ot-line.ext-doc-type = 'rs':U)
                        no-lock ) = true ) = true
                    no-lock
                    :
                    run item-goods ("1" , "gds-list" ) .
     end.
  end.
  end.
        when 6     then do:
  if x-selectobject = "currency":u  or  xtog-obj then do:
        for each gds-obj where
                              gds-obj.obj-type = x-store-type    and
                              gds-obj.obj-code = x-store-code
                              and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
                              and
            can-find(first ub.ot-line where
                  ub.ot-line.obj-code     = gds-obj.obj-code
            and   ub.ot-line.obj-type     = gds-obj.obj-type
            and   ub.ot-line.artic        = gds-obj.artic
            and   ub.ot-line.prod-code    = gds-obj.prod-code
            and   ub.ot-line.prod-type    = gds-obj.prod-type
            and   ub.ot-line.fact-order   <= fact-order-2
            and   ub.ot-line.fact-order   >= fact-order-1
            and   ub.ot-line.sum-type      = 'cost':U
            and   (ub.ot-line.ext-doc-type = 'ev':U      or
                  ub.ot-line.ext-doc-type = 'ee':U       or
                  ub.ot-line.ext-doc-type = 're':U   or
                  ub.ot-line.ext-doc-type = 'em':U        or
                  ub.ot-line.ext-doc-type = 'wm':U        or
                  ub.ot-line.ext-doc-type = 'es':U  or
                  ub.ot-line.ext-doc-type = 'rs':U)
                  no-lock ) = true
                                    no-lock,
                        first gds-list  where
                              gds-obj.prod-code  = gds-list.prod-code and
                              gds-obj.prod-type  = gds-list.prod-type and
                              gds-obj.artic      = gds-list.artic       no-lock
                    :
                    run item-goods ( "1" , "gds-list" ) .
      end.
  end.
  else do:
  for each gds-list where
      can-find(first gds-obj where gds-obj.prod-code   =  gds-list.prod-code  and
                  gds-obj.prod-type  = gds-list.prod-type    and
                  gds-obj.artic      = gds-list.artic        and
                  lookup (gds-obj.obj-type +  '#' +  string( gds-obj.obj-code) , str-obj )  > 0
                  and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
                    and
                can-find(first ub.ot-line where
                        ub.ot-line.obj-code     = gds-obj.obj-code
                  and   ub.ot-line.obj-type     = gds-obj.obj-type
                  and   ub.ot-line.artic        = gds-obj.artic
                  and   ub.ot-line.prod-code    = gds-obj.prod-code
                  and   ub.ot-line.prod-type    = gds-obj.prod-type
                  and   ub.ot-line.fact-order   <= fact-order-2
                  and   ub.ot-line.fact-order   >= fact-order-1
                  and   ub.ot-line.sum-type      = 'cost':U
                  and   (ub.ot-line.ext-doc-type = 'ev':U      or
                        ub.ot-line.ext-doc-type = 'ee':U       or
                        ub.ot-line.ext-doc-type = 're':U       or
                        ub.ot-line.ext-doc-type = 'em':U        or
                        ub.ot-line.ext-doc-type = 'wm':U        or
                        ub.ot-line.ext-doc-type = 'es':U  or
                        ub.ot-line.ext-doc-type = 'rs':U)
                        no-lock ) = true ) = true
                    no-lock
                    :
                    run item-goods ("1" , "gds-list" ) .
     end.
  end.
  end.
        when 7 then do:
  if x-selectobject = "currency":u  or  xtog-obj then do:
        for each gds-obj where
                              gds-obj.obj-type = x-store-type    and
                              gds-obj.obj-code = x-store-code
                              and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
                              and
            can-find(first ub.ot-line where
                  ub.ot-line.obj-code     = gds-obj.obj-code
            and   ub.ot-line.obj-type     = gds-obj.obj-type
            and   ub.ot-line.artic        = gds-obj.artic
            and   ub.ot-line.prod-code    = gds-obj.prod-code
            and   ub.ot-line.prod-type    = gds-obj.prod-type
            and   ub.ot-line.fact-order   <= fact-order-2
            and   ub.ot-line.fact-order   >= fact-order-1
            and   ub.ot-line.sum-type      = 'cost':U
            and   (ub.ot-line.ext-doc-type = 'ev':U      or
                  ub.ot-line.ext-doc-type = 'ee':U       or
                  ub.ot-line.ext-doc-type = 're':U   or
                  ub.ot-line.ext-doc-type = 'em':U        or
                  ub.ot-line.ext-doc-type = 'wm':U        or
                  ub.ot-line.ext-doc-type = 'es':U  or
                  ub.ot-line.ext-doc-type = 'rs':U)
                  no-lock ) = true
                                    no-lock,
                        first gds-list  where
                              gds-obj.prod-code  = gds-list.prod-code and
                              gds-obj.prod-type  = gds-list.prod-type and
                              gds-obj.artic      = gds-list.artic       no-lock
                    :
                    run item-goods ( "1" , "gds-list" ) .
      end.
  end.
  else do:
  for each gds-list where
      can-find(first gds-obj where gds-obj.prod-code   =  gds-list.prod-code  and
                  gds-obj.prod-type  = gds-list.prod-type    and
                  gds-obj.artic      = gds-list.artic        and
                  lookup (gds-obj.obj-type +  '#' +  string( gds-obj.obj-code) , str-obj )  > 0
                  and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
                    and
                can-find(first ub.ot-line where
                        ub.ot-line.obj-code     = gds-obj.obj-code
                  and   ub.ot-line.obj-type     = gds-obj.obj-type
                  and   ub.ot-line.artic        = gds-obj.artic
                  and   ub.ot-line.prod-code    = gds-obj.prod-code
                  and   ub.ot-line.prod-type    = gds-obj.prod-type
                  and   ub.ot-line.fact-order   <= fact-order-2
                  and   ub.ot-line.fact-order   >= fact-order-1
                  and   ub.ot-line.sum-type      = 'cost':U
                  and   (ub.ot-line.ext-doc-type = 'ev':U      or
                        ub.ot-line.ext-doc-type = 'ee':U       or
                        ub.ot-line.ext-doc-type = 're':U       or
                        ub.ot-line.ext-doc-type = 'em':U        or
                        ub.ot-line.ext-doc-type = 'wm':U        or
                        ub.ot-line.ext-doc-type = 'es':U  or
                        ub.ot-line.ext-doc-type = 'rs':U)
                        no-lock ) = true ) = true
                    no-lock
                    :
                    run item-goods ("1" , "gds-list" ) .
     end.
  end.
  end.
       end case.
  run printtemptable .
  hide stream outstream frame bottomframe .
  run print-footer .
  end procedure.
procedure clear-item :
define variable kk as int no-undo.
 repeat kk = 1 to 6:
 assign
    rash                [kk]    = 0
    kassa               [kk]    = 0
    bi-rash             [kk]    = 0
    bi-kassa            [kk]    = 0
    .
       end.
 end procedure.
procedure item-goods :
 define input parameter  par-3 as char no-undo.
 define input parameter  par-4 as char no-undo.
     if par-4 = "goods":u  then do:
                                assign
                                    gds-zap-unit-base  = goods.unit-base
                                    gds-zap-prt-root   = goods.prt-root
                                    gds-zap-prod-type  = goods.prod-type
                                    gds-zap-prod-code  = goods.prod-code
                                    gds-zap-artic      = goods.artic
                                    gds-zap-grp-name   = goods.grp-name
                                    gds-zap-b-code     = goods.gds-code  .
                                if g#gds-engl then
                                    assign gds-zap-gds-name = goods.engl-name.
                                else
                                    assign gds-zap-gds-name = goods.gds-name.
                            end.
     if par-4 = "gds-list":u  then do:
                                assign
                                    gds-zap-unit-base  = gds-list.unit-base
                                    gds-zap-prt-root   = gds-list.prt-root
                                    gds-zap-prod-type  = gds-list.prod-type
                                    gds-zap-prod-code  = gds-list.prod-code
                                    gds-zap-artic      = gds-list.artic
                                    gds-zap-grp-name   = gds-list.grp-name
                                    gds-zap-b-code     = gds-list.gds-code  .
                                if g#gds-engl then
                                    assign gds-zap-gds-name = gds-list.engl-name.
                                else
                                    assign gds-zap-gds-name = gds-list.gds-name.
                            end.
    run foreach .
    run maketemptable .
end procedure.
procedure di :
define input parameter p1 as char no-undo.
define input parameter p2 as int no-undo.
define input parameter p3 as char no-undo.
define input parameter p4 as char no-undo.
define input parameter p5 as char no-undo.
define input parameter p6 as char no-undo.
define input parameter p7 as char no-undo.
end procedure.
procedure maketemptable :
   assign
    v#qnty    =   ( -1 ) * (bi-rash[1] + kassa[1])
    v#sumcost =   ( -1 ) * (bi-rash[2] + kassa[2])
    v#sumsale =   ( -1 ) * (bi-rash[5] + kassa[5])
    v#kassaqnty = ( -1 ) * (kassa[1])
    v#kassasale = ( -1 ) * (kassa[5] )
    v#kassacost = ( -1 ) * (kassa[2] )
    v#effect    = ( -1 ) * ( kassa[5]) - ( -1 ) * ( kassa[2])
    v#b-code    =  gds-zap-b-code
    v#artic     =  gds-zap-artic
    v#prod-type =  gds-zap-prod-type
    v#prod-code =  gds-zap-prod-code
    v#prt-root  =  gds-zap-prt-root
    v#gds-name  =  gds-zap-gds-name
    v#unit-base =  gds-zap-unit-base
    v#qnty_vn =  (-1 ) * (rash[1] + kassa[1])
    v#sumcost_vn =   ( -1 ) * (rash[2] + kassa[2])
    v#sumsale_vn =   ( -1 ) * (rash[5] + kassa[5])
   v#midcost = v#sumcost_vn  / v#qnty_vn
   v#midsale  = v#sumsale_vn / v#qnty_vn
   v#rub_nac = v#midsale -  v#midcost
   v#proc_nac =  v#rub_nac /  v#midcost * 100.
    if x-tog-shift = no then
    do:
        assign
            v#period_rel = ostatok_end_day / (v#qnty / (x-date-end - x-date-start + 1 ) )
            v#turnday    = ((ostatok_start_day + ostatok_end_day) / 2) / (  v#qnty / (x-date-end - x-date-start + 1) ).
    end.
    else
    do:
        find last  shift-obj where shift-obj.obj-code = v-obj-code and   shift-obj.obj-type = v-obj-type  and shift-obj.shift-date = x-Date-Start and shift-obj.shift-num   >= x-Shift-Start no-lock no-error .
        if shift-obj.close-date = ?  then shift-obj.close-date = today.
        assign
        v#period_rel = ostatok_end_day / ( v#qnty / ( shift-obj.close-date - x-date-start + 1 )  )
        v#turnday    = ((ostatok_start_day + ostatok_end_day) / 2) / ( v#qnty / ( shift-obj.close-date - x-date-start + 1) ).
    end.
 if gi <= xbsamount then do:
   create tmp#bs.
   run eqq .
   end.
 else do:
     case xcrit:
        when 1 then do:
           find first tmp#bs  use-index byqnty.
           if available tmp#bs and v#qnty > tmp#bs.qnty then run eqq .
           end.
        when 2 then do:
           find first tmp#bs  use-index bysumcost.
           if available tmp#bs and v#sumcost > tmp#bs.sumcost then run eqq .
           end.
        when 3 then do:
           find first tmp#bs  use-index bysumsale.
           if available tmp#bs and v#sumsale > tmp#bs.sumsale then run eqq .
           end.
        when 4 then do:
           find first tmp#bs  use-index byeffect.
           if available tmp#bs and v#effect > tmp#bs.effect then run eqq .
           end.
        when 5 then do:
           find first tmp#bs  use-index bykassaqnty.
           if available tmp#bs and v#kassaqnty > tmp#bs.kassaqnty then run eqq .
           end.
        when 6 then do:
           find first tmp#bs  use-index bykassasale.
           if available tmp#bs and v#kassasale > tmp#bs.kassasale then run eqq .
           end.
    end case.
 end.
end procedure.
procedure eqq :
   assign
    tmp#bs.qnty      = v#qnty
    tmp#bs.sumcost   = v#sumcost
    tmp#bs.sumsale   = v#sumsale
    tmp#bs.kassaqnty = v#kassaqnty
    tmp#bs.kassasale = v#kassasale
    tmp#bs.kassacost = v#kassacost
    tmp#bs.effect    = v#effect
    tmp#bs.b-code    = v#b-code
    tmp#bs.artic     = v#artic
    tmp#bs.prod-code = v#prod-code
    tmp#bs.prod-type = v#prod-type
    tmp#bs.prt-root  = v#prt-root
    tmp#bs.gds-name  = v#gds-name
    tmp#bs.unit-base = v#unit-base
    tmp#bs.ext-doc-type   = v#ext-doc
    tmp#bs.midcost = v#midcost
    tmp#bs.midsale = v#midsale
    tmp#bs.proc_nac = v#proc_nac
    tmp#bs.rub_nac = v#rub_nac
    tmp#bs.period_rel =  v#period_rel
    tmp#bs.qnty_vn = v#qnty_vn
    tmp#bs.sumcost_vn = v#sumcost_vn
    tmp#bs.sumsale_vn = v#sumsale_vn
    tmp#bs.turnday = v#turnday
    tmp#bs.rest_end = ostatok_end_day
    tmp#bs.rest_start = ostatok_start_day
    .
end procedure.
procedure printtemptable :
      define variable i as  integer init 2 no-undo.
    case xsort:
        when 1 then
            do:
                percent#all = 0.
                for each tmp#bs no-lock:
                    v#effect-all = v#effect-all + tmp#bs.effect.
                    percent#all = percent#all + tmp#bs.qnty.
                end.
                for each tmp#bs no-lock break  by tmp#bs.qnty   descending  :
                    if percent#all <> 0 then
                        percent#1 = tmp#bs.qnty * 100 / percent#all .
                    else percent#1 = 0.
                    v#prev = v#abc.
                    v#abc      = v#abc      + tmp#bs.qnty * 100 / percent#all .
                              assign
                        v-group_qnty      = v-group_qnty +  tmp#bs.qnty
                        v-group_sumcost   = v-group_sumcost +  tmp#bs.sumcost
                        v-group_sumsale   = v-group_sumsale +  tmp#bs.sumsale
                        v-group_kassaqnty = v-group_kassaqnty +  tmp#bs.kassaqnty
                        v-group_kassasale = v-group_kassasale +  tmp#bs.kassasale
                        v-group_kasscost  = v-group_kasscost +  tmp#bs.kassacost
                        v-effect = v-group_kassasale  -  v-group_kasscost
                        v-ostatok-end = v-ostatok-end + tmp#bs.rest_end
                        v-ostatok-start = v-ostatok-start + tmp#bs.rest_start
                         v-sumcost = v-sumcost + tmp#bs.sumcost_vn
                        v-sumsale = v-sumsale + tmp#bs.sumsale_vn
v-qnty_vn = v-qnty_vn + tmp#bs.qnty_vn
v-midcost = v-sumcost / v-qnty_vn
v-midsale = v-sumsale / v-qnty_vn
v-rub_nac = v-midsale - v-midcost
v-proc_nac = v-rub_nac / v-midcost * 100
.
                 if x-tog-shift = no then
    do:
        assign
           v-period_rel = v-ostatok-end / (v-group_qnty / (x-date-end - x-date-start + 1 ) )
            v-turnday    = ((v-ostatok-start + v-ostatok-end) / 2) / (  v-group_qnty / (x-date-end - x-date-start + 1) ).
    end.
    else
    do:
        find last  shift-obj where shift-obj.obj-code = v-obj-code and   shift-obj.obj-type = v-obj-type  and shift-obj.shift-date = x-Date-Start and shift-obj.shift-num   >= x-Shift-Start no-lock no-error .
        if shift-obj.close-date = ?  then shift-obj.close-date = today.
        assign
        v-period_rel = v-ostatok-end / ( v-group_qnty / ( shift-obj.close-date - x-date-start + 1 )  )
  v-turnday   = ((v-ostatok-start + v-ostatok-end) / 2) / ( v-group_qnty / ( shift-obj.close-date - x-date-start + 1) ).
    end.
                        .
            if v#abc > 80  and xcrit = xsort  then
                do:
                    if v#prev   < 80 then
                      do:
                          v-group = "А".
                       run display-abc ( input 0, input v#prev , input v-group  ) .
                    v#abc-do = v#prev .
                    v#income = 0 .
                    end.
                     end.
          if v#abc > 95 and  xcrit = xsort then
                do:
                    if v#prev   < 95 then
                     do:
                         v-group = "Б".
                        run display-abc ( input v#abc-do , input v#prev, input v-group  ).
                v#abc-do = v#prev .
               v#income = 0.
                    end.
                end.
                    run display-str .
                    v#income = v#income + v#part_income.
                    i = i + 1.
                end.
                if   xcrit = xsort then
                do:
                    v-group = "C".
                    run display-abc ( input v#abc-do , input  v#abc , input v-group  ).
                    v#abc-do = 0 .
                    v#income = 0.
                end.
                run group_itog .
            end.
        when 2 then
            do:
                percent#all = 0.
                for each tmp#bs no-lock:
                    v#effect-all = v#effect-all + tmp#bs.effect.
                    percent#all = percent#all + tmp#bs.sumcost.
                end.
                for each tmp#bs no-lock   by tmp#bs.sumcost  descending :
                    if percent#all <> 0 then
                        percent#1 = tmp#bs.sumcost * 100 / percent#all .
                    else percent#1 = 0.
                    v#prev = v#abc.
                    v#abc      = v#abc      + tmp#bs.sumcost * 100 / percent#all .
                              assign
                        v-group_qnty      = v-group_qnty +  tmp#bs.qnty
                        v-group_sumcost   = v-group_sumcost +  tmp#bs.sumcost
                        v-group_sumsale   = v-group_sumsale +  tmp#bs.sumsale
                        v-group_kassaqnty = v-group_kassaqnty +  tmp#bs.kassaqnty
                        v-group_kassasale = v-group_kassasale +  tmp#bs.kassasale
                        v-group_kasscost  = v-group_kasscost +  tmp#bs.kassacost
                        v-effect = v-group_kassasale  -  v-group_kasscost
                        v-ostatok-end = v-ostatok-end + tmp#bs.rest_end
                        v-ostatok-start = v-ostatok-start + tmp#bs.rest_start
                         v-sumcost = v-sumcost + tmp#bs.sumcost_vn
                        v-sumsale = v-sumsale + tmp#bs.sumsale_vn
v-qnty_vn = v-qnty_vn + tmp#bs.qnty_vn
v-midcost = v-sumcost / v-qnty_vn
v-midsale = v-sumsale / v-qnty_vn
v-rub_nac = v-midsale - v-midcost
v-proc_nac = v-rub_nac / v-midcost * 100
.
                 if x-tog-shift = no then
    do:
        assign
           v-period_rel = v-ostatok-end / (v-group_qnty / (x-date-end - x-date-start + 1 ) )
            v-turnday    = ((v-ostatok-start + v-ostatok-end) / 2) / (  v-group_qnty / (x-date-end - x-date-start + 1) ).
    end.
    else
    do:
        find last  shift-obj where shift-obj.obj-code = v-obj-code and   shift-obj.obj-type = v-obj-type  and shift-obj.shift-date = x-Date-Start and shift-obj.shift-num   >= x-Shift-Start no-lock no-error .
        if shift-obj.close-date = ?  then shift-obj.close-date = today.
        assign
        v-period_rel = v-ostatok-end / ( v-group_qnty / ( shift-obj.close-date - x-date-start + 1 )  )
  v-turnday   = ((v-ostatok-start + v-ostatok-end) / 2) / ( v-group_qnty / ( shift-obj.close-date - x-date-start + 1) ).
    end.
                        .
            if v#abc > 80  and xcrit = xsort  then
                do:
                    if v#prev   < 80 then
                      do:
                          v-group = "А".
                       run display-abc ( input 0, input v#prev , input v-group  ) .
                    v#abc-do = v#prev .
                    v#income = 0 .
                    end.
                     end.
          if v#abc > 95 and  xcrit = xsort then
                do:
                    if v#prev   < 95 then
                     do:
                         v-group = "Б".
                        run display-abc ( input v#abc-do , input v#prev, input v-group  ).
                v#abc-do = v#prev .
               v#income = 0.
                    end.
                end.
                    run display-str .
                    v#income = v#income + v#part_income.
                end.
                if   xcrit = xsort then
                do:
                    v-group = "C".
                    run display-abc ( input v#abc-do , input  v#abc, input v-group  ).
                    v#abc-do = 0 .
                    v#income = 0.
                end.
                run group_itog .
            end.
        when 3 then
            do:
                percent#all = 0.
                for each tmp#bs no-lock:
                    v#effect-all = v#effect-all + tmp#bs.effect.
                    percent#all = percent#all + tmp#bs.sumsale .
                end.
                for each tmp#bs no-lock   by tmp#bs.sumsale  descending :
                    if percent#all <> 0 then
                        percent#1 = tmp#bs.sumsale  * 100 / percent#all .
                    else percent#1 = 0.
                    v#prev = v#abc.
                    v#abc      = v#abc      +  tmp#bs.sumsale  * 100 / percent#all .
                              assign
                        v-group_qnty      = v-group_qnty +  tmp#bs.qnty
                        v-group_sumcost   = v-group_sumcost +  tmp#bs.sumcost
                        v-group_sumsale   = v-group_sumsale +  tmp#bs.sumsale
                        v-group_kassaqnty = v-group_kassaqnty +  tmp#bs.kassaqnty
                        v-group_kassasale = v-group_kassasale +  tmp#bs.kassasale
                        v-group_kasscost  = v-group_kasscost +  tmp#bs.kassacost
                        v-effect = v-group_kassasale  -  v-group_kasscost
                        v-ostatok-end = v-ostatok-end + tmp#bs.rest_end
                        v-ostatok-start = v-ostatok-start + tmp#bs.rest_start
                         v-sumcost = v-sumcost + tmp#bs.sumcost_vn
                        v-sumsale = v-sumsale + tmp#bs.sumsale_vn
v-qnty_vn = v-qnty_vn + tmp#bs.qnty_vn
v-midcost = v-sumcost / v-qnty_vn
v-midsale = v-sumsale / v-qnty_vn
v-rub_nac = v-midsale - v-midcost
v-proc_nac = v-rub_nac / v-midcost * 100
.
                 if x-tog-shift = no then
    do:
        assign
           v-period_rel = v-ostatok-end / (v-group_qnty / (x-date-end - x-date-start + 1 ) )
            v-turnday    = ((v-ostatok-start + v-ostatok-end) / 2) / (  v-group_qnty / (x-date-end - x-date-start + 1) ).
    end.
    else
    do:
        find last  shift-obj where shift-obj.obj-code = v-obj-code and   shift-obj.obj-type = v-obj-type  and shift-obj.shift-date = x-Date-Start and shift-obj.shift-num   >= x-Shift-Start no-lock no-error .
        if shift-obj.close-date = ?  then shift-obj.close-date = today.
        assign
        v-period_rel = v-ostatok-end / ( v-group_qnty / ( shift-obj.close-date - x-date-start + 1 )  )
  v-turnday   = ((v-ostatok-start + v-ostatok-end) / 2) / ( v-group_qnty / ( shift-obj.close-date - x-date-start + 1) ).
    end.
                        .
            if v#abc > 80  and xcrit = xsort  then
                do:
                    if v#prev   < 80 then
                      do:
                          v-group = "А".
                       run display-abc ( input 0, input v#prev , input v-group  ) .
                    v#abc-do = v#prev .
                    v#income = 0 .
                    end.
                     end.
          if v#abc > 95 and  xcrit = xsort then
                do:
                    if v#prev   < 95 then
                     do:
                         v-group = "Б".
                        run display-abc ( input v#abc-do , input v#prev, input v-group  ).
                v#abc-do = v#prev .
               v#income = 0.
                    end.
                end.
                    run display-str .
                    v#income = v#income + v#part_income.
                end.
                if   xcrit = xsort then
                do:
                    v-group = "C".
                    run display-abc ( input v#abc-do , input  v#abc, input v-group  ).
                    v#abc-do = 0 .
                    v#income = 0.
                end.
                run group_itog .
            end.
        when 4 then
            do:
                percent#all = 0.
                for each tmp#bs no-lock:
                    v#effect-all = v#effect-all + tmp#bs.effect.
                    percent#all = percent#all + tmp#bs.effect   .
                end.
                for each tmp#bs no-lock   by tmp#bs.effect  descending :
                    if percent#all <> 0 then
                        percent#1 =  tmp#bs.effect * 100 /  percent#all .
                    else percent#1 = 0.
                    v#prev = v#abc.
                    v#abc      = v#abc      +  tmp#bs.effect * 100 /  percent#all .
                              assign
                        v-group_qnty      = v-group_qnty +  tmp#bs.qnty
                        v-group_sumcost   = v-group_sumcost +  tmp#bs.sumcost
                        v-group_sumsale   = v-group_sumsale +  tmp#bs.sumsale
                        v-group_kassaqnty = v-group_kassaqnty +  tmp#bs.kassaqnty
                        v-group_kassasale = v-group_kassasale +  tmp#bs.kassasale
                        v-group_kasscost  = v-group_kasscost +  tmp#bs.kassacost
                        v-effect = v-group_kassasale  -  v-group_kasscost
                        v-ostatok-end = v-ostatok-end + tmp#bs.rest_end
                        v-ostatok-start = v-ostatok-start + tmp#bs.rest_start
                         v-sumcost = v-sumcost + tmp#bs.sumcost_vn
                        v-sumsale = v-sumsale + tmp#bs.sumsale_vn
v-qnty_vn = v-qnty_vn + tmp#bs.qnty_vn
v-midcost = v-sumcost / v-qnty_vn
v-midsale = v-sumsale / v-qnty_vn
v-rub_nac = v-midsale - v-midcost
v-proc_nac = v-rub_nac / v-midcost * 100
.
                 if x-tog-shift = no then
    do:
        assign
           v-period_rel = v-ostatok-end / (v-group_qnty / (x-date-end - x-date-start + 1 ) )
            v-turnday    = ((v-ostatok-start + v-ostatok-end) / 2) / (  v-group_qnty / (x-date-end - x-date-start + 1) ).
    end.
    else
    do:
        find last  shift-obj where shift-obj.obj-code = v-obj-code and   shift-obj.obj-type = v-obj-type  and shift-obj.shift-date = x-Date-Start and shift-obj.shift-num   >= x-Shift-Start no-lock no-error .
        if shift-obj.close-date = ?  then shift-obj.close-date = today.
        assign
        v-period_rel = v-ostatok-end / ( v-group_qnty / ( shift-obj.close-date - x-date-start + 1 )  )
  v-turnday   = ((v-ostatok-start + v-ostatok-end) / 2) / ( v-group_qnty / ( shift-obj.close-date - x-date-start + 1) ).
    end.
                        .
            if v#abc > 80  and xcrit = xsort  then
                do:
                    if v#prev   < 80 then
                      do:
                          v-group = "А".
                       run display-abc ( input 0, input v#prev , input v-group  ) .
                    v#abc-do = v#prev .
                    v#income = 0 .
                    end.
                     end.
          if v#abc > 95 and  xcrit = xsort then
                do:
                    if v#prev   < 95 then
                     do:
                         v-group = "Б".
                        run display-abc ( input v#abc-do , input v#prev, input v-group  ).
                v#abc-do = v#prev .
               v#income = 0.
                    end.
                end.
                    run display-str .
                    v#income = v#income + v#part_income.
                end.
                if   xcrit = xsort then
                do:
                    v-group = "C".
                    run display-abc ( input v#abc-do , input  v#abc, input v-group  ).
                    v#abc-do = 0 .
                    v#income = 0.
                end.
                run group_itog .
            end.
        when 5 then
            do:
                percent#all = 0.
                for each tmp#bs no-lock:
                    v#effect-all = v#effect-all + tmp#bs.effect.
                    percent#all = percent#all + tmp#bs.kassaqnty.
                end.
                for each tmp#bs no-lock   by tmp#bs.kassaqnty descending  :
                    if percent#all <> 0 then
                        percent#1 = tmp#bs.kassaqnty * 100 / percent#all .
                    else percent#1 = 0.
                    v#prev = v#abc.
                    v#abc      = v#abc      +  tmp#bs.kassaqnty * 100 / percent#all .
                              assign
                        v-group_qnty      = v-group_qnty +  tmp#bs.qnty
                        v-group_sumcost   = v-group_sumcost +  tmp#bs.sumcost
                        v-group_sumsale   = v-group_sumsale +  tmp#bs.sumsale
                        v-group_kassaqnty = v-group_kassaqnty +  tmp#bs.kassaqnty
                        v-group_kassasale = v-group_kassasale +  tmp#bs.kassasale
                        v-group_kasscost  = v-group_kasscost +  tmp#bs.kassacost
                        v-effect = v-group_kassasale  -  v-group_kasscost
                        v-ostatok-end = v-ostatok-end + tmp#bs.rest_end
                        v-ostatok-start = v-ostatok-start + tmp#bs.rest_start
                         v-sumcost = v-sumcost + tmp#bs.sumcost_vn
                        v-sumsale = v-sumsale + tmp#bs.sumsale_vn
v-qnty_vn = v-qnty_vn + tmp#bs.qnty_vn
v-midcost = v-sumcost / v-qnty_vn
v-midsale = v-sumsale / v-qnty_vn
v-rub_nac = v-midsale - v-midcost
v-proc_nac = v-rub_nac / v-midcost * 100
.
                 if x-tog-shift = no then
    do:
        assign
           v-period_rel = v-ostatok-end / (v-group_qnty / (x-date-end - x-date-start + 1 ) )
            v-turnday    = ((v-ostatok-start + v-ostatok-end) / 2) / (  v-group_qnty / (x-date-end - x-date-start + 1) ).
    end.
    else
    do:
        find last  shift-obj where shift-obj.obj-code = v-obj-code and   shift-obj.obj-type = v-obj-type  and shift-obj.shift-date = x-Date-Start and shift-obj.shift-num   >= x-Shift-Start no-lock no-error .
        if shift-obj.close-date = ?  then shift-obj.close-date = today.
        assign
        v-period_rel = v-ostatok-end / ( v-group_qnty / ( shift-obj.close-date - x-date-start + 1 )  )
  v-turnday   = ((v-ostatok-start + v-ostatok-end) / 2) / ( v-group_qnty / ( shift-obj.close-date - x-date-start + 1) ).
    end.
                        .
            if v#abc > 80  and xcrit = xsort  then
                do:
                    if v#prev   < 80 then
                      do:
                          v-group = "А".
                       run display-abc ( input 0, input v#prev , input v-group  ) .
                    v#abc-do = v#prev .
                    v#income = 0 .
                    end.
                     end.
          if v#abc > 95 and  xcrit = xsort then
                do:
                    if v#prev   < 95 then
                     do:
                         v-group = "Б".
                        run display-abc ( input v#abc-do , input v#prev, input v-group  ).
                v#abc-do = v#prev .
               v#income = 0.
                    end.
                end.
                    run display-str .
                    v#income = v#income + v#part_income.
                end.
                if   xcrit = xsort then
                do:
                    v-group = "C".
                    run display-abc ( input v#abc-do , input  v#abc, input v-group  ).
                    v#abc-do = 0 .
                    v#income = 0.
                end.
                run group_itog .
            end.
        when 6 then
            do:
                percent#all = 0.
                for each tmp#bs no-lock:
                    v#effect-all = v#effect-all + tmp#bs.effect.
                    percent#all = percent#all + tmp#bs.kassasale .
                end.
                for each tmp#bs no-lock   by tmp#bs.kassasale   descending   :
                    if percent#all <> 0 then
                        assign
                            percent#1 = tmp#bs.kassasale  * 100 / percent#all
                            .
                    else percent#1 = 0.
                    assign
                        v#prev = v#abc.
                    v#abc      = v#abc      +  tmp#bs.kassasale  * 100 / percent#all .
                              assign
                        v-group_qnty      = v-group_qnty +  tmp#bs.qnty
                        v-group_sumcost   = v-group_sumcost +  tmp#bs.sumcost
                        v-group_sumsale   = v-group_sumsale +  tmp#bs.sumsale
                        v-group_kassaqnty = v-group_kassaqnty +  tmp#bs.kassaqnty
                        v-group_kassasale = v-group_kassasale +  tmp#bs.kassasale
                        v-group_kasscost  = v-group_kasscost +  tmp#bs.kassacost
                        v-effect = v-group_kassasale  -  v-group_kasscost
                        v-ostatok-end = v-ostatok-end + tmp#bs.rest_end
                        v-ostatok-start = v-ostatok-start + tmp#bs.rest_start
                         v-sumcost = v-sumcost + tmp#bs.sumcost_vn
                        v-sumsale = v-sumsale + tmp#bs.sumsale_vn
v-qnty_vn = v-qnty_vn + tmp#bs.qnty_vn
v-midcost = v-sumcost / v-qnty_vn
v-midsale = v-sumsale / v-qnty_vn
v-rub_nac = v-midsale - v-midcost
v-proc_nac = v-rub_nac / v-midcost * 100
.
                 if x-tog-shift = no then
    do:
        assign
           v-period_rel = v-ostatok-end / (v-group_qnty / (x-date-end - x-date-start + 1 ) )
            v-turnday    = ((v-ostatok-start + v-ostatok-end) / 2) / (  v-group_qnty / (x-date-end - x-date-start + 1) ).
    end.
    else
    do:
        find last  shift-obj where shift-obj.obj-code = v-obj-code and   shift-obj.obj-type = v-obj-type  and shift-obj.shift-date = x-Date-Start and shift-obj.shift-num   >= x-Shift-Start no-lock no-error .
        if shift-obj.close-date = ?  then shift-obj.close-date = today.
        assign
        v-period_rel = v-ostatok-end / ( v-group_qnty / ( shift-obj.close-date - x-date-start + 1 )  )
  v-turnday   = ((v-ostatok-start + v-ostatok-end) / 2) / ( v-group_qnty / ( shift-obj.close-date - x-date-start + 1) ).
    end.
                        .
            if v#abc > 80  and xcrit = xsort  then
                do:
                    if v#prev   < 80 then
                      do:
                          v-group = "А".
                       run display-abc ( input 0, input v#prev , input v-group  ) .
                    v#abc-do = v#prev .
                    v#income = 0 .
                    end.
                     end.
          if v#abc > 95 and  xcrit = xsort then
                do:
                    if v#prev   < 95 then
                     do:
                         v-group = "Б".
                        run display-abc ( input v#abc-do , input v#prev, input v-group  ).
                v#abc-do = v#prev .
               v#income = 0.
                    end.
                end.
                    run display-str .
                    v#income = v#income + v#part_income.
                end.
                if   xcrit = xsort then
                do:
                    v-group = "C".
                    run display-abc ( input v#abc-do , input  v#abc, input v-group ).
                    v#abc-do = 0 .
                    v#income = 0.
                end.
                run group_itog .
            end.
    end case.
end procedure.
procedure  group_itog :
  if Make-Excel then  put   stream ForExcel unformatted
   CHR(9)
    CHR(9) "Все по группе "
    CHR(9)
    CHR(9).
    if use-column[5]  = yes then    if Make-Excel then  put   stream ForExcel unformatted  excel-sum(  v-group_qnty ) CHR(9).
    if use-column[6]  = yes then  if Make-Excel then  put   stream ForExcel unformatted excel-sum(   v-group_kassaqnty )   CHR(9).
    if use-column[7]  = yes then  if Make-Excel then  put   stream ForExcel unformatted excel-sum(   v-group_sumcost ) CHR(9).
    if use-column[8]  = yes then  if Make-Excel then  put   stream ForExcel unformatted excel-sum(   v-group_kasscost ) CHR(9).
    if use-column[9]  = yes then  if Make-Excel then  put   stream ForExcel unformatted excel-sum(   v-group_sumsale) CHR(9).
    if use-column[10]  = yes then  if Make-Excel then  put   stream ForExcel unformatted excel-sum(   v-group_kassasale)  CHR(9).
    if use-column[11]  = yes then  if Make-Excel then  put   stream ForExcel unformatted excel-sum(  v-effect  ) CHR(9).
    if use-column[12]  = yes then  if Make-Excel then  put   stream ForExcel unformatted  CHR(9) .
    if use-column[13]  = yes then  if Make-Excel then  put   stream ForExcel unformatted excel-sum(  v-qnty_vn ) CHR(9) .
    if use-column[14]  = yes then    if Make-Excel then  put   stream ForExcel unformatted excel-sum( v-sumcost )  CHR(9) .
    if use-column[15]  = yes then   if Make-Excel then  put   stream ForExcel unformatted excel-sum(  v-sumsale  )   CHR(9) .
    if use-column[16]  = yes then  if Make-Excel then  put   stream ForExcel unformatted  CHR(9) .
    if use-column[17]  = yes then  if Make-Excel then  put   stream ForExcel unformatted  excel-sum( v-ostatok-start  )   CHR(9) .
    if use-column[18]  = yes then  if Make-Excel then  put   stream ForExcel unformatted  excel-sum(  v-ostatok-end )   CHR(9) .
    if use-column[19]  = yes then   if Make-Excel then  put   stream ForExcel unformatted  excel-sum( v-midcost  )    CHR(9) .
    if use-column[20]  = yes then    if Make-Excel then  put   stream ForExcel unformatted  excel-sum(  v-midsale  )    CHR(9) .
    if use-column[21]  = yes then   if Make-Excel then  put   stream ForExcel unformatted  excel-sum(  v-rub_nac  )  CHR(9) .
    if use-column[22]  = yes then   if Make-Excel then  put   stream ForExcel unformatted  excel-sum(  v-proc_nac  )  CHR(9) .
    if use-column[23]  = yes then   if Make-Excel then  put   stream ForExcel unformatted excel-sum(  v-turnday  )  CHR(9) .
    if use-column[24]  = yes then    if Make-Excel then  put   stream ForExcel unformatted excel-sum(  v-period_rel  )  CHR(9).
   if Make-Excel then  put   stream ForExcel unformatted   skip.
    end.
procedure display-abc :
    define input parameter p-abc as decimal no-undo.
    define input parameter p-abc-2 as decimal no-undo.
       define input paramet p-group as character no-undo.
    define variable proc as decimal no-undo.
    proc = p-abc-2 - p-abc.
    if Make-Excel then  put   stream ForExcel unformatted
    CHR(9)
    CHR(9) "Граница группы " p-group
    CHR(9)
    CHR(9).
    if use-column[5]  = yes then    if Make-Excel then  put   stream ForExcel unformatted  CHR(9).
    if use-column[6]  = yes then  if Make-Excel then  put   stream ForExcel unformatted CHR(9).
    if use-column[7]  = yes then  if Make-Excel then  put   stream ForExcel unformatted CHR(9).
    if use-column[8]  = yes then  if Make-Excel then  put   stream ForExcel unformatted CHR(9).
    if use-column[9]  = yes then  if Make-Excel then  put   stream ForExcel unformatted CHR(9).
    if use-column[10]  = yes then  if Make-Excel then  put   stream ForExcel unformatted CHR(9).
    if use-column[11]  = yes then  if Make-Excel then  put   stream ForExcel unformatted CHR(9).
    if use-column[12]  = yes then if Make-Excel then  put   stream ForExcel unformatted excel-sum( proc ) CHR(9) .
    if use-column[13]  = yes then  if Make-Excel then  put   stream ForExcel unformatted CHR(9) .
    if use-column[14]  = yes then    if Make-Excel then  put   stream ForExcel unformatted  CHR(9) .
    if use-column[15]  = yes then   if Make-Excel then  put   stream ForExcel unformatted   CHR(9) .
    if use-column[16]  = yes then   if Make-Excel then  put   stream ForExcel unformatted excel-sum( v#income) CHR(9) .
    if use-column[17]  = yes then  if Make-Excel then  put   stream ForExcel unformatted    CHR(9) .
    if use-column[18]  = yes then  if Make-Excel then  put   stream ForExcel unformatted    CHR(9) .
    if use-column[19]  = yes then   if Make-Excel then  put   stream ForExcel unformatted     CHR(9) .
    if use-column[20]  = yes then    if Make-Excel then  put   stream ForExcel unformatted     CHR(9) .
    if use-column[21]  = yes then   if Make-Excel then  put   stream ForExcel unformatted   CHR(9) .
    if use-column[22]  = yes then   if Make-Excel then  put   stream ForExcel unformatted   CHR(9) .
    if use-column[23]  = yes then   if Make-Excel then  put   stream ForExcel unformatted  CHR(9) .
    if use-column[24]  = yes then    if Make-Excel then  put   stream ForExcel unformatted  CHR(9).
   if Make-Excel then  put   stream ForExcel unformatted   skip.
end procedure.
procedure display-str  :
        v#part_income = (tmp#bs.effect / v#effect-all) * 100.
  display stream  outstream sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12
  tmp#bs.b-code    @ gds-zap-b-code
  tmp#bs.artic     @ gds-zap-artic
  tmp#bs.gds-name  @ gds-zap-gds-name
  tmp#bs.unit-base @ gds-zap-unit-base
  tmp#bs.qnty      @ f-qnty
  tmp#bs.sumcost
  when (cc = true )     @ f-sumcost
  tmp#bs.sumsale                        @ f-sumsale
  tmp#bs.kassaqnty                      @ f-kassaqnty
  tmp#bs.kassasale                      @ f-kassasale
  tmp#bs.kassacost
  when ( cc = true )  @ f-kassacost
  tmp#bs.effect
  when ( cc = true )  @ f-effect
  percent#1
  when (cc = true )   @ f-percent
    with FRAME ZAPAS . DOWN stream   OutStream 1 with FRAME ZAPAS.
    if Make-Excel then  put   stream ForExcel unformatted
        tmp#bs.b-code     CHR(9)
        tmp#bs.artic      CHR(9)
        tmp#bs.gds-name   CHR(9)
        tmp#bs.unit-base  CHR(9) .
    if use-column[5]  = yes  then     if Make-Excel then  put   stream ForExcel unformatted  excel-qnty(tmp#bs.qnty)  CHR(9) .
    if use-column[6]  = yes  then  if Make-Excel then  put   stream ForExcel unformatted  excel-qnty(tmp#bs.kassaqnty) CHR(9) .
    if use-column[7]  = yes and  (cc = true )    then if Make-Excel then  put   stream ForExcel unformatted excel-sum( tmp#bs.sumcost   )   CHR(9) .
    if use-column[8]  = yes  and (cc = true ) then   if Make-Excel then  put   stream ForExcel unformatted  excel-sum( tmp#bs.kassacost )   CHR(9) .
    if use-column[9]  = yes then    if Make-Excel then  put   stream ForExcel unformatted excel-sum(tmp#bs.sumsale)  CHR(9).
    if use-column[10]  = yes then  if Make-Excel then  put   stream ForExcel unformatted excel-sum(tmp#bs.kassasale)  CHR(9).
    if use-column[11]  = yes and  (cc = true ) then     if Make-Excel then  put   stream ForExcel unformatted  excel-sum( tmp#bs.effect ) CHR(9).
    if use-column[12]  = yes and  (cc = true )  then     if Make-Excel then  put   stream ForExcel unformatted excel-sum(percent#1 )  CHR(9).
    if use-column[13]  = yes  then  if Make-Excel then  put   stream ForExcel unformatted  excel-sum (tmp#bs.qnty_vn) CHR(9) .
    if use-column[14]  = yes  then    if Make-Excel then  put   stream ForExcel unformatted excel-sum (tmp#bs.sumcost_vn) CHR(9) .
    if use-column[15]  = yes   then   if Make-Excel then  put   stream ForExcel unformatted excel-sum  (tmp#bs.sumsale_vn) CHR(9) .
    if use-column[16]  = yes then  if Make-Excel then  put   stream ForExcel unformatted  excel-sum( v#part_income )  CHR(9) .
    if use-column[17]  = yes then  if Make-Excel then  put   stream ForExcel unformatted  excel-sum( tmp#bs.rest_start  )   CHR(9) .
    if use-column[18]  = yes then  if Make-Excel then  put   stream ForExcel unformatted  excel-sum(  tmp#bs.rest_end  )  CHR(9) .
    if use-column[19]  = yes then  if Make-Excel then  put   stream ForExcel unformatted  excel-sum(tmp#bs.midcost)   CHR(9) .
    if use-column[20]  = yes then    if Make-Excel then  put   stream ForExcel unformatted  excel-sum(tmp#bs.midsale)   CHR(9) .
    if use-column[21]  = yes then   if Make-Excel then  put   stream ForExcel unformatted  excel-sum(tmp#bs.rub_nac)   CHR(9) .
    if use-column[22]  = yes then   if Make-Excel then  put   stream ForExcel unformatted excel-sum(tmp#bs.proc_nac)  CHR(9) .
    if use-column[23]  = yes then   if Make-Excel then  put   stream ForExcel unformatted excel-sum(tmp#bs.turnday) CHR(9) .
    if use-column[24]  = yes then    if Make-Excel then  put   stream ForExcel unformatted   excel-sum(tmp#bs.period_rel).
     if Make-Excel then  put   stream ForExcel unformatted   skip.
    if  tog-scale and tmp#bs.prt-root <> prtroot and tmp#bs.prt-root <> 0 then
         if xsc_name = 0 then do:
                             if tmp#bs.qnty = 0 then
                             run print_scala ( 0 ) .
                             else
                             run print_scala ( tmp#bs.sumcost / tmp#bs.qnty ).
                         end.
                         else do:
                             if tmp#bs.prt-root = x-upper-code then do:
                                if tmp#bs.qnty = 0 then
                                run print_scala ( 0 ).
                                else
                                run print_scala ( tmp#bs.sumcost / tmp#bs.qnty ).
                             end.
                          end.
end procedure.
procedure print_scala  :
define input parameter p-price-cost as decimal no-undo .
define variable  tt#          as   int                 no-undo.
run clear-item .
for each obj-list ,
    each gds-dtl where  gds-dtl.obj-code     = obj-list.obj-code
                  and   gds-dtl.obj-type     = obj-list.obj-type
                  and   gds-dtl.artic        = tmp#bs.artic
                  and   gds-dtl.prod-code    = tmp#bs.prod-code
                  and   gds-dtl.prod-type    = tmp#bs.prod-type
                  no-lock
                  break by gds-dtl.prt-code :
      if var-report-r-b = "rubl" then do:
        if tprintrubl then v-cur-base = gds-dtl.cur-base .
                      else v-cur-base = gds-dtl.cur-base * ( v-r-b-scale / v-r-b-rate ).
      end.
      else do:
        if not tprintrubl then v-cur-base = gds-dtl.cur-base .
                          else v-cur-base = gds-dtl.cur-base /  v-r-b-scale * v-r-b-rate .
      end.
      for each ot-line no-lock where
                              ot-line.obj-code     = obj-list.obj-code
                        and   ot-line.obj-type     = obj-list.obj-type
                        and   ot-line.artic        = tmp#bs.artic
                        and   ot-line.prod-code    = tmp#bs.prod-code
                        and   ot-line.prod-type    = tmp#bs.prod-type
                        and   ot-line.fact-order   <= fact-order-2
                        and   ot-line.fact-order   >= fact-order-1
                        and   ot-line.sum-type      = 'cost':U
                        and   (
                              ot-line.ext-doc-type = 'ee':U       or
                              ot-line.ext-doc-type = 're':U   or
                              ot-line.ext-doc-type = 'em':U        or
                              ot-line.ext-doc-type = 'wm':U        or
                              ot-line.ext-doc-type = 'es':U  or
                              ot-line.ext-doc-type = 'rs':U)
                              :
                  if ot-line.sum-type = 'cost':U then tt# = 0.
                                                    else tt# = 3 .
                  case ot-line.ext-doc-type:
                      when       'ev':U      then
                              if x-selectobject = "currency":u then do:
                              assign srash[1 + tt#]   = srash[1 + tt#]   +  gds-dtl.fact-qnty
                                     srash[2 + tt#]   = srash[2 + tt#]   +  (gds-dtl.fact-qnty * p-price-cost )
                                     srash[5 + tt#]   = srash[5 + tt#]   +  (gds-dtl.fact-qnty * v-cur-base).
                                    end.
                      when       'ee':U      or
                      when       're':U      or
                      when       'em':U       or
                      when       'wm':U then
                          do:
                              assign
                                  bi-srash[1 + tt#] = bi-srash[1 + tt#]   +  ot-line.fact-qnty
                                  bi-srash[2 + tt#] = bi-srash[2 + tt#]   + ( if tprintrubl then ot-line.sum-rubl else ot-line.sum-base )
                                  .
                              if ot-line.ext-doc-type <> 'ee':U then
                              do :
                                  assign
                                      srash[1 + tt#] = srash[1 + tt#]   +  gds-dtl.fact-qnty
                                      srash[2 + tt#] = srash[2 + tt#]   +   (gds-dtl.fact-qnty * p-price-cost )
                                      srash[5 + tt#] = srash[5 + tt#]   +  (gds-dtl.fact-qnty * v-cur-base).
                              end.
                          end.
                      when       'es':U  or
                      when       'rs':U then
                          do:
                    assign skassa[1 + tt#]   = skassa[1 + tt#]   +  gds-dtl.fact-qnty
                           skassa[2 + tt#]   = skassa[2 + tt#]   +  (gds-dtl.fact-qnty * p-price-cost )
                           skassa[5 + tt#]   = skassa[5 + tt#]   +  (gds-dtl.fact-qnty * v-cur-base).
                          end.
                    end case.
      end.
  if last-of(gds-dtl.prt-code) then do:
      find first gds-prt  where gds-prt.node-code = gds-dtl.prt-code no-lock no-error .
      find first bar-code where bar-code.gds-code = tmp#bs.b-code and
                                              bar-code.unit-cli = tmp#bs.unit-base and
                                              bar-code.node-code = gds-prt.node-code and
                                              bar-code.part-code = "" and
                                              bar-code.in-code = ""
                                              no-lock no-error .
      if  bar-code.b-code   <> tmp#bs.b-code then
      do:
      display stream  outstream sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12
        bar-code.b-code                                                 @ gds-zap-b-code
        ""                                                              @ gds-zap-artic
        gds-prt.f-name                                                  @ gds-zap-gds-name
        tmp#bs.unit-base                                                @ gds-zap-unit-base
         (srash[1] + skassa[1]) format "->>>>>>>>>9.999"                @ f-qnty
         (skassa[1])                                                    @ f-kassaqnty
         (srash[2] + skassa[2])                   when ( cc = true )    @ f-sumcost
         (srash[5] + skassa[5])                                         @ f-sumsale
         (skassa[2])                              when ( cc = true )    @ f-kassacost
         (skassa[5])                                                    @ f-kassasale
         ((srash[5] + skassa[5]) - (srash[2] + skassa[2])) when ( cc = true )    @ f-effect
        ""                                                                       @ f-percent
       with FRAME ZAPAS . DOWN stream   OutStream 1 with FRAME ZAPAS.
        if Make-Excel then  put   stream ForExcel unformatted
            bar-code.b-code                                              CHR(9)
            ""                                                           CHR(9)
            gds-prt.f-name                                               CHR(9)
            tmp#bs.unit-base                                             CHR(9)
            excel-qnty (srash[1] + skassa[1])                           CHR(9)
            excel-qnty (skassa[1] )                                     CHR(9)
            if (cc = true ) then  excel-sum((srash[2] + skassa[2]) ) else " " CHR(9)
            if (cc = true ) then  excel-sum((skassa[2]) ) else " "            CHR(9)
            excel-sum(srash[5] + skassa[5])                                   CHR(9)
            excel-sum( (skassa[5]) )                                          CHR(9)
            if (cc = true ) then  excel-sum( ((srash[5] + skassa[5]) - (srash[2] + skassa[2])) ) else " "
            CHR(9)
            skip.
        assign   srash[1]  = 0  srash[2]  = 0  srash[5]  = 0
                 skassa[1] = 0  skassa[2] = 0  skassa[5] = 0.
                end.
            end.
    end.
end procedure.
procedure ColumnTitle :
  do on error undo, return error return-value :
    put stream outstream   Line format frmt skip .
          if use-column[1]  = yes then  PUT stream OutStream  "|"  "  Код"              format "X(10)" .
          if use-column[2]  = yes then  PUT stream OutStream  "|"  "  Артикул"          format "X(16)" .
          if use-column[3]  = yes then  PUT stream OutStream  "|"  "  Название товара"  format "X(40)" .
          if use-column[4]  = yes then  PUT stream OutStream  "|"  "Ед.изм "                format "X(3)"  .
          if use-column[5]  = yes then  PUT stream OutStream  "|"   "Количество"       format "X(14)" .
          if use-column[6]  = yes then  PUT stream OutStream  "|"   "в т.ч. Касса "         format "X(14)" .
          if use-column[7]  = yes then  PUT stream OutStream  "|"   "Сумма в учетных ценах"           format "X(15)" .
          if use-column[8]  = yes then  PUT stream OutStream  "|"   "в т.ч. Касса в учетных ценах"         format "X(15)" .
          if use-column[9] = yes then  PUT stream OutStream  "|"   "Сумма в ценах док-та"     format "X(15)" .
          if use-column[10] = yes then  PUT stream OutStream  "|"   "в т.ч. Касса в ценах док-та"             format "X(15)" .
          if use-column[11] = yes then  PUT stream OutStream  "|"   "Эффективность"           format "X(9)"  .
          if use-column[12] = yes then  PUT stream OutStream  "|"   "%"         format "X(13)" .
      if use-column[13]  = yes then PUT stream OutStream  "|" "Количество (с учетом внеш.расходов),"         format "X(14)" .
      if use-column[14]  = yes then PUT stream OutStream  "|"  "Сумма продажи в уч.ценах (с учетом внеш.расходов),"          format "X(14)" .
      if use-column[15]  = yes then PUT stream OutStream  "|"  "Сумма продажи в ценах документа (с учетом внеш.расходов),"           format "X(14)" .
      if use-column[16]  = yes then PUT stream OutStream  "|"   "Доля в доходах,"          format "X(14)" .
      if use-column[17]  = yes then PUT stream OutStream  "|"   "Остаток на начало,"          format "X(14)" .
      if use-column[18]  = yes then PUT stream OutStream  "|"   "Остаток на конец,"           format "X(14)".
      if use-column[19]  = yes then PUT stream OutStream  "|"  "Средняя учетная цена,"          format "X(14)" .
      if use-column[20]  = yes then PUT stream OutStream  "|"  "Средняя цена продажи,"          format "X(14)" .
      if use-column[21]  = yes then PUT stream OutStream  "|"   "Наценка в руб.,"          format "X(14)".
      if use-column[22]  = yes then PUT stream OutStream  "|"   "Наценка в %.,"          format "X(14)".
      if use-column[23]  = yes then PUT stream OutStream  "|"   "Оборачиваемость в днях,"         format "X(14)".
      if use-column[24]  = yes then PUT stream OutStream  "|"   "Срок реализации остатка,"          format "X(14)".
      PUT stream OutStream "|"   skip .
  end.
end procedure.
