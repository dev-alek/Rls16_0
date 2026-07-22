block-level on error undo, throw.
define var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define var vss-author      as character no-undo init "$Author: expertek $":U .
define var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define var vss-workfile    as character no-undo init "$Workfile: r-zap-p4.p $":U .
define var vss-archive     as character no-undo init "$Archive: rep/r-zap-p4.p $":U .
define var vss-description as character no-undo init "ОТЧЕТ О СОСТОЯНИИ ЗАПАСА И ПРОДАЖАХ".
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
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-cntxt-host-code-obj
  ,output base-code
  )  .
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info17 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define input parameter classify     as character no-undo.
define input parameter ShowPrice    as integer no-undo .
define input parameter ShowZero1    as logical no-undo .
define input parameter ShowZero2    as logical no-undo .
define buffer buf_clients   for clients .
define buffer buf_ot-line   for ot-line .
define buffer buf_gds-obj   for gds-obj .
define buffer buf_goods     for goods   .
define buffer buf_stk-line  for stk-line .
define var f-end-cost  as decimal no-undo.
define var f-beg-qnty  as decimal no-undo.
define var f-sale-qnty as decimal no-undo.
define var f-end-qnty  as decimal no-undo.
define var f-end-sum   as decimal no-undo.
define var n-nm        as integer init 0 no-undo .
define var Ostat       as   logical no-undo.
define var Oborot      as   logical no-undo.
define var var-client   as character no-undo .
define var    v-fact-order-start     as decimal   no-undo .
define var    v-fact-order-end       as decimal   no-undo .
define temp-table temp-goods no-undo
  field gds-code  like goods.gds-code
  field artic     like goods.artic
  field cli       like clients.obj-name
  field grp-name  like goods.grp-name
  field prod-code like goods.prod-code
  field prod-type like goods.prod-type
  field prt-root  like goods.prt-root
  field gds-name  like goods.gds-name
  field full-id   as character
  INDEX pi  IS PRIMARY full-id
  INDEX pi1  prod-type prod-code artic
  INDEX pi2  grp-name
  INDEX pi3  cli
  INDEX pi4  artic
  INDEX pi5  gds-code
.
define temp-table Temp-b no-undo
  field grp          as character
  field obj-code     like obj-list.obj-code
  field obj-TYPE     like obj-list.obj-TYPE
  field b-beg-qnty   as decimal
  field b-sale-qnty  as decimal
  field b-end-qnty   as decimal
  field b-end-sum    as decimal
  index PI IS PRIMARY grp obj-code  obj-type
.
define temp-table Temp-i no-undo
  field obj-code     like obj-list.obj-code
  field obj-type     like obj-list.obj-type
  field i-beg-qnty   as decimal
  field i-sale-qnty  as decimal
  field i-end-qnty   as decimal
  field i-end-sum    as decimal
  index PI IS PRIMARY obj-code  obj-type
.
define temp-table Temp-line no-undo
  field obj-code     like obj-list.obj-code
  field obj-type     like obj-list.obj-type
  field l-end-cost   as decimal
  field l-beg-qnty   as decimal
  field l-sale-qnty  as decimal
  field l-end-qnty   as decimal
  field l-end-sum    as decimal
  index PI is primary obj-code  obj-type
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
Run report-execute in this-procedure.
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
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
PROCEDURE report-execute :
assign v-account = ( if integer( 10 ) = 0 then 100 else integer( 10 ) ).
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
  run day-begin-fact-order in this-procedure ( input x-date-start, output v-fact-order-start ).
  run day-begin-fact-order in this-procedure ( input ( x-date-end + 1 ),   output v-fact-order-end ).
  run rep/extitle.p (1) .
  run prep-file    in this-procedure.
  case classify:
    when "no-classify":u    then do:
      run foreach1 in this-procedure.
    end.
    when "prod":u then do:
      Run Foreach2 in this-procedure.
    end.
    when "grp-goods":u then do:
      Run Foreach3 in this-procedure.
    end.
 end case.
 if Make-Excel then output stream ForExcel close.
if mFrameView
then do:
   HIDE FRAME InfoFrame.
end.
 run rep/runexcel.p (string( session:temp-directory) + "rpt" + string( g#report-num ) + ".txt").
END PROCEDURE.
PROCEDURE foreach1 :
  for each temp-goods  no-lock
    break by temp-goods.full-id
          by temp-goods.prod-type By temp-goods.prod-code by temp-goods.artic
         with FRAME Zapas :
    if last-of(temp-goods.artic) then do:
      n-nm = n-nm + 1.
IF ( n-nm modulo v-account = 0 )  then DO:
          if  log-manager:logfile-name ne ?
          then DO:
              log-manager:write-message("DISP mFrameView=" + string(mFrameView), "frameRepError").
          end.
           if mFrameView
           then do:
            DISPLAY
              n-nm @ RecordsDone
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
        Ostat       = no
        Oborot      = no
      .
      for each obj-list no-lock :
define variable vss-include-info19 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
Assign
  f-end-cost  = 0
  f-beg-qnty  = 0
  f-sale-qnty = 0
  f-end-qnty  = 0
  f-end-sum   = 0
.
 find last  buf_stk-line no-lock
   where buf_stk-line.obj-type  = obj-list.obj-type
     and buf_stk-line.obj-code  = obj-list.obj-code
     and buf_stk-line.artic     = temp-goods.artic
     and buf_stk-line.prod-type = temp-goods.prod-type
     and buf_stk-line.prod-code = temp-goods.prod-code
     and buf_stk-line.sum-type  = ( if ShowPrice = 1 then 'crsa':U else 'cost':U )
     and buf_stk-line.cat-id    = '##,##'
     and buf_stk-line.fact-order < v-fact-order-end
     use-index category no-error .
    if available buf_stk-line then
    do:
      if buf_stk-line.fact-qnty <> 0 then
      do:
        assign
          f-end-cost  = buf_stk-line.sum-base / buf_stk-line.fact-qnty
        .
      end.
      assign
        f-end-qnty  = buf_stk-line.fact-qnty
        f-end-sum   = buf_stk-line.sum-base
      .
    end.
 for each buf_ot-line no-lock
   where buf_ot-line.obj-type  = obj-list.obj-type
     and buf_ot-line.obj-code  = obj-list.obj-code
     and buf_ot-line.artic     = temp-goods.artic
     and buf_ot-line.prod-type = temp-goods.prod-type
     and buf_ot-line.prod-code = temp-goods.prod-code
     and buf_ot-line.fact-order >= v-fact-order-start
     and buf_ot-line.fact-order < v-fact-order-end
     and buf_ot-line.sum-type  = 'cost':U
     and buf_ot-line.cat-id    = '##,##'
     break by buf_ot-line.fact-order descending
   :
    case buf_ot-line.ext-doc-type :
      when 'ee':U       then do:
        assign
          f-sale-qnty = f-sale-qnty + buf_ot-line.fact-qnty
        .
      End.
      when 'es':U       then do:
        assign
          f-sale-qnty = f-sale-qnty + buf_ot-line.fact-qnty
        .
      End.
      when 're':U       then do:
        assign
          f-sale-qnty = f-sale-qnty + buf_ot-line.fact-qnty
        .
      End.
      when 'rs':U       then do:
        assign
          f-sale-qnty = f-sale-qnty + buf_ot-line.fact-qnty
        .
      End.
    End case.
  end.
 find last buf_stk-line no-lock
   where buf_stk-line.obj-type  = obj-list.obj-type
     and buf_stk-line.obj-code  = obj-list.obj-code
     and buf_stk-line.artic     = temp-goods.artic
     and buf_stk-line.prod-type = temp-goods.prod-type
     and buf_stk-line.prod-code = temp-goods.prod-code
     and buf_stk-line.sum-type  = ( if ShowPrice = 1 then 'crsa':U else 'cost':U )
     and buf_stk-line.cat-id    = '##,##'
     and buf_stk-line.fact-order <= v-fact-order-start
     use-index category no-error .
    if available buf_stk-line then do:
      assign
        f-beg-qnty  = buf_stk-line.fact-qnty
      .
    end.
  if f-sale-qnty <> 0 then do:
    assign
      Oborot = yes
    .
  end.
  if f-beg-qnty <> 0 or f-end-qnty <> 0 then do:
    assign
      Ostat = yes
    .
  end.
find first Temp-line share-lock
  where Temp-line.obj-type  = obj-list.obj-type
    and Temp-line.obj-code  = obj-list.obj-code  no-error .
if not available Temp-line Then  create Temp-line no-error .
assign
  Temp-line.obj-type    = obj-list.obj-type
  Temp-line.obj-code    = obj-list.obj-code
  Temp-line.l-end-cost  = f-end-cost
  Temp-line.l-beg-qnty  = f-beg-qnty
  Temp-line.l-sale-qnty = f-sale-qnty
  Temp-line.l-end-qnty  = f-end-qnty
  Temp-line.l-end-sum   = f-end-sum
.
find first Temp-i  share-lock
  where Temp-i.obj-type  = obj-list.obj-type
    and Temp-i.obj-code  = obj-list.obj-code no-error .
if not available Temp-i then do:
  create Temp-i no-error .
  assign
    Temp-i.obj-code     = obj-list.obj-code
    Temp-i.obj-type     = obj-list.obj-type
    Temp-i.i-beg-qnty   = f-beg-qnty
    Temp-i.i-sale-qnty  = f-sale-qnty
    Temp-i.i-end-qnty   = f-end-qnty
    Temp-i.i-end-sum    = f-end-sum
  .
end.
else do:
  assign
    Temp-i.i-beg-qnty   = Temp-i.i-beg-qnty   + f-beg-qnty
    Temp-i.i-sale-qnty  = Temp-i.i-sale-qnty  + f-sale-qnty
    Temp-i.i-end-qnty   = Temp-i.i-end-qnty   + f-end-qnty
    Temp-i.i-end-sum    = Temp-i.i-end-sum    + f-end-sum
  .
end.
      end.
      Run PrintLine in this-procedure.
    End.
  End.
  Run PrintItogAll in this-procedure.
END PROCEDURE.
PROCEDURE foreach2 :
  for each temp-goods  no-lock
     break by temp-goods.cli
           by temp-goods.full-id
           by temp-goods.artic
         with FRAME Zapas :
    if first-of(temp-goods.cli) then do:
      assign
        var-client = temp-goods.cli
      .
      if Make-Excel then  put   stream ForExcel unformatted var-client chr(10) .
    End.
    if last-of(temp-goods.artic) then do:
      n-nm = n-nm + 1.
IF ( n-nm modulo v-account = 0 )  then DO:
          if  log-manager:logfile-name ne ?
          then DO:
              log-manager:write-message("DISP mFrameView=" + string(mFrameView), "frameRepError").
          end.
           if mFrameView
           then do:
            DISPLAY
              n-nm @ RecordsDone
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
        Ostat       = no
        Oborot      = no
      .
      for each obj-list no-lock :
define variable vss-include-info20 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
Assign
  f-end-cost  = 0
  f-beg-qnty  = 0
  f-sale-qnty = 0
  f-end-qnty  = 0
  f-end-sum   = 0
.
 find last  buf_stk-line no-lock
   where buf_stk-line.obj-type  = obj-list.obj-type
     and buf_stk-line.obj-code  = obj-list.obj-code
     and buf_stk-line.artic     = temp-goods.artic
     and buf_stk-line.prod-type = temp-goods.prod-type
     and buf_stk-line.prod-code = temp-goods.prod-code
     and buf_stk-line.sum-type  = ( if ShowPrice = 1 then 'crsa':U else 'cost':U )
     and buf_stk-line.cat-id    = '##,##'
     and buf_stk-line.fact-order < v-fact-order-end
     use-index category no-error .
    if available buf_stk-line then
    do:
      if buf_stk-line.fact-qnty <> 0 then
      do:
        assign
          f-end-cost  = buf_stk-line.sum-base / buf_stk-line.fact-qnty
        .
      end.
      assign
        f-end-qnty  = buf_stk-line.fact-qnty
        f-end-sum   = buf_stk-line.sum-base
      .
    end.
 for each buf_ot-line no-lock
   where buf_ot-line.obj-type  = obj-list.obj-type
     and buf_ot-line.obj-code  = obj-list.obj-code
     and buf_ot-line.artic     = temp-goods.artic
     and buf_ot-line.prod-type = temp-goods.prod-type
     and buf_ot-line.prod-code = temp-goods.prod-code
     and buf_ot-line.fact-order >= v-fact-order-start
     and buf_ot-line.fact-order < v-fact-order-end
     and buf_ot-line.sum-type  = 'cost':U
     and buf_ot-line.cat-id    = '##,##'
     break by buf_ot-line.fact-order descending
   :
    case buf_ot-line.ext-doc-type :
      when 'ee':U       then do:
        assign
          f-sale-qnty = f-sale-qnty + buf_ot-line.fact-qnty
        .
      End.
      when 'es':U       then do:
        assign
          f-sale-qnty = f-sale-qnty + buf_ot-line.fact-qnty
        .
      End.
      when 're':U       then do:
        assign
          f-sale-qnty = f-sale-qnty + buf_ot-line.fact-qnty
        .
      End.
      when 'rs':U       then do:
        assign
          f-sale-qnty = f-sale-qnty + buf_ot-line.fact-qnty
        .
      End.
    End case.
  end.
 find last buf_stk-line no-lock
   where buf_stk-line.obj-type  = obj-list.obj-type
     and buf_stk-line.obj-code  = obj-list.obj-code
     and buf_stk-line.artic     = temp-goods.artic
     and buf_stk-line.prod-type = temp-goods.prod-type
     and buf_stk-line.prod-code = temp-goods.prod-code
     and buf_stk-line.sum-type  = ( if ShowPrice = 1 then 'crsa':U else 'cost':U )
     and buf_stk-line.cat-id    = '##,##'
     and buf_stk-line.fact-order <= v-fact-order-start
     use-index category no-error .
    if available buf_stk-line then do:
      assign
        f-beg-qnty  = buf_stk-line.fact-qnty
      .
    end.
  if f-sale-qnty <> 0 then do:
    assign
      Oborot = yes
    .
  end.
  if f-beg-qnty <> 0 or f-end-qnty <> 0 then do:
    assign
      Ostat = yes
    .
  end.
find first Temp-line share-lock
  where Temp-line.obj-type  = obj-list.obj-type
    and Temp-line.obj-code  = obj-list.obj-code  no-error .
if not available Temp-line Then  create Temp-line no-error .
assign
  Temp-line.obj-type    = obj-list.obj-type
  Temp-line.obj-code    = obj-list.obj-code
  Temp-line.l-end-cost  = f-end-cost
  Temp-line.l-beg-qnty  = f-beg-qnty
  Temp-line.l-sale-qnty = f-sale-qnty
  Temp-line.l-end-qnty  = f-end-qnty
  Temp-line.l-end-sum   = f-end-sum
.
find first Temp-i  share-lock
  where Temp-i.obj-type  = obj-list.obj-type
    and Temp-i.obj-code  = obj-list.obj-code no-error .
if not available Temp-i then do:
  create Temp-i no-error .
  assign
    Temp-i.obj-code     = obj-list.obj-code
    Temp-i.obj-type     = obj-list.obj-type
    Temp-i.i-beg-qnty   = f-beg-qnty
    Temp-i.i-sale-qnty  = f-sale-qnty
    Temp-i.i-end-qnty   = f-end-qnty
    Temp-i.i-end-sum    = f-end-sum
  .
end.
else do:
  assign
    Temp-i.i-beg-qnty   = Temp-i.i-beg-qnty   + f-beg-qnty
    Temp-i.i-sale-qnty  = Temp-i.i-sale-qnty  + f-sale-qnty
    Temp-i.i-end-qnty   = Temp-i.i-end-qnty   + f-end-qnty
    Temp-i.i-end-sum    = Temp-i.i-end-sum    + f-end-sum
  .
end.
        find first Temp-b share-lock
          where Temp-b.obj-code  = obj-list.obj-code
            and Temp-b.obj-type  = obj-list.obj-type  no-error .
        if not avail Temp-b Then  create Temp-b no-error .
        assign
          Temp-b.grp          = STRING(temp-goods.cli)
          Temp-b.obj-code     = obj-list.obj-code
          Temp-b.obj-type     = obj-list.obj-type
          Temp-b.b-beg-qnty   = Temp-b.b-beg-qnty   + f-beg-qnty
          Temp-b.b-sale-qnty  = Temp-b.b-sale-qnty  + f-sale-qnty
          Temp-b.b-end-qnty   = Temp-b.b-end-qnty   + f-end-qnty
          Temp-b.b-end-sum    = Temp-b.b-end-sum    + f-end-sum
        .
      end.
      Run PrintLine in this-procedure.
    End.
    if last-of(temp-goods.cli)  then do :
      if Make-Excel then  put   stream ForExcel unformatted
        "Итого"                 CHR(9)
        "по произв. "
        var-client              CHR(9)
      .
      for each obj-list no-lock :
        find first Temp-b no-lock
             where Temp-b.obj-code  = obj-list.obj-code
               and Temp-b.obj-type  = obj-list.obj-type
               and Temp-b.grp = STRING(temp-goods.cli) no-error .
        if avail  Temp-b then do:
          if Make-Excel then  put   stream ForExcel unformatted                          CHR(9)
            excel-qnty ( Temp-b.b-beg-qnty  )  CHR(9)
            excel-qnty ( Temp-b.b-sale-qnty )  CHR(9)
            excel-qnty ( Temp-b.b-end-qnty  )  CHR(9)
            excel-sum  ( Temp-b.b-end-sum   )  CHR(9)
          .
        end.
        else do:
          if Make-Excel then  put   stream ForExcel unformatted  CHR(9)
            0          CHR(9)
            0          CHR(9)
            0          CHR(9)
            0          CHR(9)
          .
        end.
        find current  Temp-b share-lock.
          assign
            Temp-b.b-beg-qnty  = 0
            Temp-b.b-sale-qnty = 0
            Temp-b.b-end-qnty  = 0
            Temp-b.b-end-sum   = 0
          .
          find current  Temp-b no-lock.
      End.
      if Make-Excel then  put   stream ForExcel unformatted chr(10) .
    End.
  End.
  Run PrintItogAll in this-procedure.
END PROCEDURE.
PROCEDURE foreach3 :
  for each temp-goods  no-lock
    break by temp-goods.grp-name
          by temp-goods.full-id
          by temp-goods.artic
    with FRAME Zapas :
    if first-of(temp-goods.grp-name) then do:
      assign
        var-client = temp-goods.grp-name
      .
      if Make-Excel then  put   stream ForExcel unformatted var-client chr(10) .
    End.
    if last-of(temp-goods.artic) then do:
      n-nm = n-nm + 1.
IF ( n-nm modulo v-account = 0 )  then DO:
          if  log-manager:logfile-name ne ?
          then DO:
              log-manager:write-message("DISP mFrameView=" + string(mFrameView), "frameRepError").
          end.
           if mFrameView
           then do:
            DISPLAY
              n-nm @ RecordsDone
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
        Ostat       = no
        Oborot      = no
      .
      for each obj-list no-lock :
define variable vss-include-info21 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
Assign
  f-end-cost  = 0
  f-beg-qnty  = 0
  f-sale-qnty = 0
  f-end-qnty  = 0
  f-end-sum   = 0
.
 find last  buf_stk-line no-lock
   where buf_stk-line.obj-type  = obj-list.obj-type
     and buf_stk-line.obj-code  = obj-list.obj-code
     and buf_stk-line.artic     = temp-goods.artic
     and buf_stk-line.prod-type = temp-goods.prod-type
     and buf_stk-line.prod-code = temp-goods.prod-code
     and buf_stk-line.sum-type  = ( if ShowPrice = 1 then 'crsa':U else 'cost':U )
     and buf_stk-line.cat-id    = '##,##'
     and buf_stk-line.fact-order < v-fact-order-end
     use-index category no-error .
    if available buf_stk-line then
    do:
      if buf_stk-line.fact-qnty <> 0 then
      do:
        assign
          f-end-cost  = buf_stk-line.sum-base / buf_stk-line.fact-qnty
        .
      end.
      assign
        f-end-qnty  = buf_stk-line.fact-qnty
        f-end-sum   = buf_stk-line.sum-base
      .
    end.
 for each buf_ot-line no-lock
   where buf_ot-line.obj-type  = obj-list.obj-type
     and buf_ot-line.obj-code  = obj-list.obj-code
     and buf_ot-line.artic     = temp-goods.artic
     and buf_ot-line.prod-type = temp-goods.prod-type
     and buf_ot-line.prod-code = temp-goods.prod-code
     and buf_ot-line.fact-order >= v-fact-order-start
     and buf_ot-line.fact-order < v-fact-order-end
     and buf_ot-line.sum-type  = 'cost':U
     and buf_ot-line.cat-id    = '##,##'
     break by buf_ot-line.fact-order descending
   :
    case buf_ot-line.ext-doc-type :
      when 'ee':U       then do:
        assign
          f-sale-qnty = f-sale-qnty + buf_ot-line.fact-qnty
        .
      End.
      when 'es':U       then do:
        assign
          f-sale-qnty = f-sale-qnty + buf_ot-line.fact-qnty
        .
      End.
      when 're':U       then do:
        assign
          f-sale-qnty = f-sale-qnty + buf_ot-line.fact-qnty
        .
      End.
      when 'rs':U       then do:
        assign
          f-sale-qnty = f-sale-qnty + buf_ot-line.fact-qnty
        .
      End.
    End case.
  end.
 find last buf_stk-line no-lock
   where buf_stk-line.obj-type  = obj-list.obj-type
     and buf_stk-line.obj-code  = obj-list.obj-code
     and buf_stk-line.artic     = temp-goods.artic
     and buf_stk-line.prod-type = temp-goods.prod-type
     and buf_stk-line.prod-code = temp-goods.prod-code
     and buf_stk-line.sum-type  = ( if ShowPrice = 1 then 'crsa':U else 'cost':U )
     and buf_stk-line.cat-id    = '##,##'
     and buf_stk-line.fact-order <= v-fact-order-start
     use-index category no-error .
    if available buf_stk-line then do:
      assign
        f-beg-qnty  = buf_stk-line.fact-qnty
      .
    end.
  if f-sale-qnty <> 0 then do:
    assign
      Oborot = yes
    .
  end.
  if f-beg-qnty <> 0 or f-end-qnty <> 0 then do:
    assign
      Ostat = yes
    .
  end.
find first Temp-line share-lock
  where Temp-line.obj-type  = obj-list.obj-type
    and Temp-line.obj-code  = obj-list.obj-code  no-error .
if not available Temp-line Then  create Temp-line no-error .
assign
  Temp-line.obj-type    = obj-list.obj-type
  Temp-line.obj-code    = obj-list.obj-code
  Temp-line.l-end-cost  = f-end-cost
  Temp-line.l-beg-qnty  = f-beg-qnty
  Temp-line.l-sale-qnty = f-sale-qnty
  Temp-line.l-end-qnty  = f-end-qnty
  Temp-line.l-end-sum   = f-end-sum
.
find first Temp-i  share-lock
  where Temp-i.obj-type  = obj-list.obj-type
    and Temp-i.obj-code  = obj-list.obj-code no-error .
if not available Temp-i then do:
  create Temp-i no-error .
  assign
    Temp-i.obj-code     = obj-list.obj-code
    Temp-i.obj-type     = obj-list.obj-type
    Temp-i.i-beg-qnty   = f-beg-qnty
    Temp-i.i-sale-qnty  = f-sale-qnty
    Temp-i.i-end-qnty   = f-end-qnty
    Temp-i.i-end-sum    = f-end-sum
  .
end.
else do:
  assign
    Temp-i.i-beg-qnty   = Temp-i.i-beg-qnty   + f-beg-qnty
    Temp-i.i-sale-qnty  = Temp-i.i-sale-qnty  + f-sale-qnty
    Temp-i.i-end-qnty   = Temp-i.i-end-qnty   + f-end-qnty
    Temp-i.i-end-sum    = Temp-i.i-end-sum    + f-end-sum
  .
end.
        find first Temp-b share-lock
          where Temp-b.obj-code  = obj-list.obj-code
            and Temp-b.obj-type  = obj-list.obj-type  no-error .
        if not avail Temp-b Then  create Temp-b no-error .
        assign
          Temp-b.grp          = STRING(temp-goods.grp-name)
          Temp-b.obj-code     = obj-list.obj-code
          Temp-b.obj-type     = obj-list.obj-type
          Temp-b.b-beg-qnty   = Temp-b.b-beg-qnty   + f-beg-qnty
          Temp-b.b-sale-qnty  = Temp-b.b-sale-qnty  + f-sale-qnty
          Temp-b.b-end-qnty   = Temp-b.b-end-qnty   + f-end-qnty
          Temp-b.b-end-sum    = Temp-b.b-end-sum    + f-end-sum
        .
      end.
      Run PrintLine in this-procedure.
    End.
    if last-of(temp-goods.grp-name)  then do :
      if Make-Excel then  put   stream ForExcel unformatted
        "Итого"                 CHR(9)
        "по группе "
        var-client              CHR(9)
      .
      for each obj-list no-lock :
        find first Temp-b no-lock
             where Temp-b.obj-code  = obj-list.obj-code
               and Temp-b.obj-type  = obj-list.obj-type
               and Temp-b.grp = STRING(temp-goods.grp-name) no-error .
        if avail  Temp-b then do:
          if Make-Excel then  put   stream ForExcel unformatted                          CHR(9)
            excel-qnty ( Temp-b.b-beg-qnty  )  CHR(9)
            excel-qnty ( Temp-b.b-sale-qnty )  CHR(9)
            excel-qnty ( Temp-b.b-end-qnty  )  CHR(9)
            excel-sum  ( Temp-b.b-end-sum   )  CHR(9)
          .
        end.
        else do:
          if Make-Excel then  put   stream ForExcel unformatted  CHR(9)
            0          CHR(9)
            0          CHR(9)
            0          CHR(9)
            0          CHR(9)
          .
        end.
        find current  Temp-b share-lock.
          assign
            Temp-b.b-beg-qnty  = 0
            Temp-b.b-sale-qnty = 0
            Temp-b.b-end-qnty  = 0
            Temp-b.b-end-sum   = 0
          .
          find current  Temp-b no-lock.
      End.
      if Make-Excel then  put   stream ForExcel unformatted chr(10) .
    End.
  End.
  Run PrintItogAll in this-procedure.
END PROCEDURE.
PROCEDURE PrintLine :
  if ShowZero1 = yes or Ostat = yes or Oborot = yes
  then do:
    if ShowZero2 = yes or Oborot = yes
    then do:
      if Make-Excel then  put   stream ForExcel unformatted
        format-excel-text(temp-goods.artic)    CHR(9)
        temp-goods.gds-name                    CHR(9)
      .
      for each obj-list no-lock :
        find first Temp-line no-lock
             where Temp-line.obj-code  = obj-list.obj-code
               and Temp-line.obj-type  = obj-list.obj-type   no-error .
          if Make-Excel then  put   stream ForExcel unformatted
            excel-sum  ( Temp-line.l-end-cost )  CHR(9)
            excel-qnty ( Temp-line.l-beg-qnty )  CHR(9)
            excel-qnty ( Temp-line.l-sale-qnty ) CHR(9)
            excel-qnty ( Temp-line.l-end-qnty )  CHR(9)
            excel-sum  ( Temp-line.l-end-sum )   CHR(9)
          .
        End.
        if Make-Excel then  put   stream ForExcel unformatted  chr(10) .
    End.
  End.
END PROCEDURE.
PROCEDURE PrintItogAll :
  if Make-Excel then  put   stream ForExcel unformatted
    "ИТОГО"                            CHR(9)
    "по объектам"                      CHR(9)
  .
  for each obj-list no-lock :
    find first Temp-i no-lock
         where Temp-i.obj-code  = obj-list.obj-code
           and Temp-i.obj-type  = obj-list.obj-type   no-error .
    if available Temp-i then do:
      if Make-Excel then  put   stream ForExcel unformatted                         CHR(9)
       excel-qnty ( Temp-i.i-beg-qnty  )  CHR(9)
       excel-qnty ( Temp-i.i-sale-qnty )  CHR(9)
       excel-qnty ( Temp-i.i-end-qnty  )  CHR(9)
       excel-sum  ( Temp-i.i-end-sum   )  CHR(9)
      .
    end.
    else do:
      if Make-Excel then  put   stream ForExcel unformatted  CHR(9)
        0          CHR(9)
        0          CHR(9)
        0          CHR(9)
        0          CHR(9)
      .
    end.
  End.
  if Make-Excel then  put   stream ForExcel unformatted chr(10) .
END PROCEDURE.
PROCEDURE prep-file :
  for each obj-list no-lock :
    for each buf_gds-obj
       where buf_gds-obj.obj-code  = obj-list.obj-code
         and buf_gds-obj.obj-type  = obj-list.obj-type
      no-lock
        , first gds-list where  buf_gds-obj.prod-type = gds-list.prod-type and
                                buf_gds-obj.prod-code = gds-list.prod-code and
                                buf_gds-obj.artic     = gds-list.artic no-lock
      :
        if buf_gds-obj.last-doc = ? then next .
        if buf_gds-obj.first-doc > x-date-end then next .
        find first buf_goods
             where buf_goods.gds-code = buf_gds-obj.gds-code no-lock no-error .
        find first buf_clients
             where buf_clients.obj-code = buf_gds-obj.prod-code
               and buf_clients.obj-type = buf_gds-obj.prod-type no-lock no-error .
        if avail buf_goods and
           avail buf_clients and
           not can-find (temp-goods where temp-goods.gds-code = buf_gds-obj.gds-code no-lock )
        then do:
          create temp-goods.
          assign
            temp-goods.gds-code  = buf_goods.gds-code
            temp-goods.artic     = buf_goods.artic
            temp-goods.cli       = buf_clients.obj-name
            temp-goods.grp-name  = buf_goods.grp-name
            temp-goods.prod-code = buf_goods.prod-code
            temp-goods.prod-type = buf_goods.prod-type
            temp-goods.prt-root  = buf_goods.prt-root
            temp-goods.gds-name  = buf_goods.gds-name
            temp-goods.full-id   = buf_goods.artic + buf_goods.prod-type + string ( buf_goods.prod-code )
          .
        End.
     End.
  End.
END PROCEDURE.
