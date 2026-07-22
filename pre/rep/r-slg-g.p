block-level on error undo, throw.
define input parameter p_provid     as integer   no-undo .
define input parameter p_cli-list   as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-slg-g.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-slg-g.p $":U .
define variable vss-description as character no-undo init "Отчет по продажам ниже учетной цены".
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
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-cntxt-host-code-obj
  ,output base-code
  )  .
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
do
on error undo, return error
:
define Stream OutStream.
define variable  v-fact-order-start     as decimal   no-undo .
define variable  v-fact-order-end       as decimal   no-undo .
define variable  Counter1               as integer   no-undo .
define variable  CurrGrpName            as character no-undo .
define variable  Line                   as character no-undo .
define variable beg-qnty     as decimal   no-undo .
define variable end-qnty     as decimal   no-undo .
define variable sale-qnty    as decimal   no-undo .
define variable in-qnty      as decimal   no-undo .
define variable titul           as logical   no-undo .
define variable v-level         as integer   no-undo .
define variable ind             as integer   no-undo .
define variable ret as logical   no-undo .
define variable v-old-level as integer initial 0  no-undo .
define variable ii as integer initial 0  no-undo .
define buffer buf_goods    for goods.
define buffer buf_clients  for clients.
define buffer buf_gds-obj  for gds-obj.
define buffer buf_gds-grp  for gds-grp.
define buffer buf_stk-line for stk-line.
define buffer buf_stk-supp-line for stk-supp-line.
DEFINE temp-table temp-GrSales1 no-undo
    field   sale-qnty        as decimal
    field   in-qnty          as decimal
    field   obj-type         as  char
    field   obj-code         as  integer
    field   grp-name         as  char
    field   grp-code         as  integer
    field   full-grp-name    as  char
    INDEX pi  IS PRIMARY   obj-type obj-code grp-code
    INDEX pi2              full-grp-name
  .
  DEFINE temp-table temp-grp-sum no-undo
    field  sale-qnty        as decimal
    field  in-qnty          as decimal
    field  grp              as character
    field  full_grp         as character
    field  num              as integer
    INDEX pi  IS PRIMARY unique num
    INDEX pi1 is unique full_grp
  .
  define variable v-NameString  as character no-undo .
  define variable v-in-qnty     as decimal   no-undo .
  define variable v-sale-qnty   as decimal   no-undo .
  define variable v-proc        as decimal   no-undo .
  define variable  all-in-qnty     as decimal initial 0  no-undo .
  define variable  all-sale-qnty   as decimal initial 0  no-undo .
  run day-begin-fact-order in this-procedure ( input x-date-start, output v-fact-order-start ).
  run day-begin-fact-order in this-procedure ( input ( x-date-end + 1 ),   output v-fact-order-end ).
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
  for each temp-GrSales1 exclusive-lock :
    delete temp-GrSales1 .
  end.
  if x-SelectGood = 1 then do:
    for each buf_goods no-lock :
      for each obj-list :
        find first buf_gds-obj no-lock
          where buf_gds-obj.obj-type  = obj-list.obj-type
            and buf_gds-obj.obj-code  = obj-list.obj-code
            and buf_gds-obj.artic     = buf_goods.artic
            and buf_gds-obj.prod-type = buf_goods.prod-type
            and buf_gds-obj.prod-code = buf_goods.prod-code
        no-error .
        if not available buf_gds-obj then next .
        if p_provid = 1 then do:
define variable vss-include-info19 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
  if buf_gds-obj.last-doc = ? then next .
  if buf_gds-obj.last-doc < x-date-start and buf_gds-obj.fact-qnty = 0 and buf_gds-obj.avrg-qnty = 0 and buf_gds-obj.fact-sale =0 and buf_gds-obj.fact-base = 0 then next .
  assign
    Counter1  = Counter1 + 1
    beg-qnty  = 0
    end-qnty  = 0
    sale-qnty = 0
    in-qnty   = 0
  .
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
  find last buf_stk-line no-lock
    where buf_stk-line.obj-type  = buf_gds-obj.obj-type
      and buf_stk-line.obj-code  = buf_gds-obj.obj-code
      and buf_stk-line.artic     = buf_goods.artic
      and buf_stk-line.prod-type = buf_gds-obj.prod-type
      and buf_stk-line.prod-code = buf_gds-obj.prod-code
      and buf_stk-line.sum-type  = 'crsa':U
      and buf_stk-line.cat-id    = '##,##'
      and buf_stk-line.fact-order  <= v-fact-order-start
    use-index category no-error .
  if available buf_stk-line then do:
    assign
      in-qnty  = buf_stk-line.fact-qnty
    .
  end .
  find last buf_stk-line no-lock
    where buf_stk-line.obj-type  = buf_gds-obj.obj-type
      and buf_stk-line.obj-code  = buf_gds-obj.obj-code
      and buf_stk-line.artic     = buf_goods.artic
      and buf_stk-line.prod-type = buf_gds-obj.prod-type
      and buf_stk-line.prod-code = buf_gds-obj.prod-code
      and buf_stk-line.sum-type  = 'csdt':U + 'ie':U
      and buf_stk-line.cat-id    = '##,##'
      and buf_stk-line.fact-order < v-fact-order-end
    use-index category no-error .
  if available buf_stk-line then do:
    assign
      end-qnty = buf_stk-line.fact-qnty
    .
  end.
  find last buf_stk-line no-lock
    where buf_stk-line.obj-type  = buf_gds-obj.obj-type
      and buf_stk-line.obj-code  = buf_gds-obj.obj-code
      and buf_stk-line.artic     = buf_goods.artic
      and buf_stk-line.prod-type = buf_gds-obj.prod-type
      and buf_stk-line.prod-code = buf_gds-obj.prod-code
      and buf_stk-line.sum-type  = 'csdt':U + 'ie':U
      and buf_stk-line.cat-id    = '##,##'
      and buf_stk-line.fact-order <= v-fact-order-start
    use-index category no-error .
  if available buf_stk-line then do:
    assign
      beg-qnty = buf_stk-line.fact-qnty
    .
  end.
  assign
    in-qnty = in-qnty + end-qnty - beg-qnty
  .
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
  if available buf_stk-line then do:
    assign
      sale-qnty = buf_stk-line.fact-qnty
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
  if available buf_stk-line then do:
    assign
      sale-qnty = sale-qnty - buf_stk-line.fact-qnty
    .
  end.
  if sale-qnty <> 0 or in-qnty <> 0 then do:
    find first temp-GrSales1
      where temp-GrSales1.obj-type   = buf_gds-obj.obj-type
        and temp-GrSales1.obj-code   = buf_gds-obj.obj-code
        and temp-GrSales1.grp-code   = buf_goods.grp-code
    no-error .
    if not available temp-GrSales1 then do:
      create temp-GrSales1 .
      run grplib-get-full-name in this-procedure ( input buf_goods.grp-code,output temp-GrSales1.full-grp-name) .
      assign
        temp-GrSales1.obj-type  = buf_gds-obj.obj-type
        temp-GrSales1.obj-code  = buf_gds-obj.obj-code
        temp-GrSales1.grp-name  = entry ( num-entries( right-trim(buf_goods.grp-name, chr(47)), chr(47) ), buf_goods.grp-name, chr(47) )
        temp-GrSales1.grp-code  = buf_goods.grp-code
        temp-GrSales1.in-qnty   = 0
        temp-GrSales1.sale-qnty = 0
      .
    end.
    if in-qnty <> 0   then assign temp-GrSales1.sale-qnty = temp-GrSales1.sale-qnty + 1 .
    if sale-qnty <> 0 then assign temp-GrSales1.in-qnty   = temp-GrSales1.in-qnty   + 1 .
  end.
  end.
        else                 do:
define variable vss-include-info20 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
  if buf_gds-obj.last-doc = ? then next .
  if buf_gds-obj.last-doc < x-date-start and buf_gds-obj.fact-qnty = 0 and buf_gds-obj.avrg-qnty = 0 and buf_gds-obj.fact-sale =0 and buf_gds-obj.fact-base = 0 then next .
  assign  Counter1  = Counter1 + 1 .
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
   DO ii = 1 TO num-entries( p_cli-list ) :
     find first buf_clients where recid(buf_clients) = integer(entry(ii, p_cli-list)) no-error.
     if not avail buf_clients then next .
    assign
      beg-qnty  = 0
      end-qnty  = 0
      sale-qnty = 0
      in-qnty   = 0
    .
    find last buf_stk-supp-line no-lock
      where buf_stk-supp-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-supp-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-supp-line.cli-type  = buf_clients.obj-type
        and buf_stk-supp-line.cli-code  = buf_clients.obj-code
        and buf_stk-supp-line.artic     = buf_goods.artic
        and buf_stk-supp-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-supp-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-supp-line.fact-order  <= v-fact-order-start
        and buf_stk-supp-line.sum-type  = 'cost':U
      no-error .
    if available buf_stk-supp-line then do:
      assign
        in-qnty = buf_stk-supp-line.fact-qnty
      .
    end .
    find last buf_stk-supp-line no-lock
      where buf_stk-supp-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-supp-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-supp-line.cli-type  = buf_clients.obj-type
        and buf_stk-supp-line.cli-code  = buf_clients.obj-code
        and buf_stk-supp-line.artic     = buf_goods.artic
        and buf_stk-supp-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-supp-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-supp-line.fact-order < v-fact-order-end
        and buf_stk-supp-line.sum-type  = 'sadt':U + 'ie':U
      no-error .
    if available buf_stk-supp-line then do:
      assign
        end-qnty = buf_stk-supp-line.fact-qnty
      .
    end.
    find last buf_stk-supp-line no-lock
      where buf_stk-supp-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-supp-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-supp-line.cli-type  = buf_clients.obj-type
        and buf_stk-supp-line.cli-code  = buf_clients.obj-code
        and buf_stk-supp-line.artic     = buf_goods.artic
        and buf_stk-supp-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-supp-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-supp-line.fact-order <= v-fact-order-start
        and buf_stk-supp-line.sum-type  = 'sadt':U + 'ie':U
      no-error .
    if available buf_stk-supp-line then do:
      assign
        beg-qnty = buf_stk-supp-line.fact-qnty
      .
    end.
    assign
      in-qnty = in-qnty + end-qnty - beg-qnty
    .
    find last buf_stk-supp-line no-lock
      where buf_stk-supp-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-supp-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-supp-line.cli-type  = buf_clients.obj-type
        and buf_stk-supp-line.cli-code  = buf_clients.obj-code
        and buf_stk-supp-line.artic     = buf_goods.artic
        and buf_stk-supp-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-supp-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-supp-line.fact-order < v-fact-order-end
        and buf_stk-supp-line.sum-type  = 'sadt':U + 'es':U
      no-error .
    if available buf_stk-supp-line then do:
      assign
        sale-qnty = buf_stk-supp-line.fact-qnty
      .
    end.
    find last buf_stk-supp-line no-lock
      where buf_stk-supp-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-supp-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-supp-line.cli-type  = buf_clients.obj-type
        and buf_stk-supp-line.cli-code  = buf_clients.obj-code
        and buf_stk-supp-line.artic     = buf_goods.artic
        and buf_stk-supp-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-supp-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-supp-line.fact-order <= v-fact-order-start
        and buf_stk-supp-line.sum-type  = 'sadt':U + 'es':U
      no-error .
    if available buf_stk-supp-line then do:
      assign
        sale-qnty = sale-qnty - buf_stk-supp-line.fact-qnty
      .
    end.
    if sale-qnty <> 0 or in-qnty <> 0 then do:
      find first temp-GrSales1
        where temp-GrSales1.obj-type   = buf_gds-obj.obj-type
          and temp-GrSales1.obj-code   = buf_gds-obj.obj-code
          and temp-GrSales1.grp-code   = buf_goods.grp-code
      no-error .
      if not available temp-GrSales1 then do:
        create temp-GrSales1 .
        run grplib-get-full-name in this-procedure ( input buf_goods.grp-code,output temp-GrSales1.full-grp-name) .
        assign
          temp-GrSales1.obj-type  = buf_gds-obj.obj-type
          temp-GrSales1.obj-code  = buf_gds-obj.obj-code
          temp-GrSales1.grp-name  = entry ( num-entries( right-trim(buf_goods.grp-name, chr(47)), chr(47) ) , buf_goods.grp-name, chr(47) )
          temp-GrSales1.grp-code  = buf_goods.grp-code
          temp-GrSales1.in-qnty   = 0
          temp-GrSales1.sale-qnty = 0
        .
      end.
      if in-qnty <> 0   then assign temp-GrSales1.sale-qnty = temp-GrSales1.sale-qnty + 1 .
      if sale-qnty <> 0 then assign temp-GrSales1.in-qnty   = temp-GrSales1.in-qnty   + 1 .
    end.
  end.
  end.
      end.
    end.
  end.
  else do:
    for each obj-list :
      case x-SelectGood :
        when 1 then do:
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
            if p_provid = 1 then do:
define variable vss-include-info21 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
  if buf_gds-obj.last-doc = ? then next .
  if buf_gds-obj.last-doc < x-date-start and buf_gds-obj.fact-qnty = 0 and buf_gds-obj.avrg-qnty = 0 and buf_gds-obj.fact-sale =0 and buf_gds-obj.fact-base = 0 then next .
  assign
    Counter1  = Counter1 + 1
    beg-qnty  = 0
    end-qnty  = 0
    sale-qnty = 0
    in-qnty   = 0
  .
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
  find last buf_stk-line no-lock
    where buf_stk-line.obj-type  = buf_gds-obj.obj-type
      and buf_stk-line.obj-code  = buf_gds-obj.obj-code
      and buf_stk-line.artic     = buf_goods.artic
      and buf_stk-line.prod-type = buf_gds-obj.prod-type
      and buf_stk-line.prod-code = buf_gds-obj.prod-code
      and buf_stk-line.sum-type  = 'crsa':U
      and buf_stk-line.cat-id    = '##,##'
      and buf_stk-line.fact-order  <= v-fact-order-start
    use-index category no-error .
  if available buf_stk-line then do:
    assign
      in-qnty  = buf_stk-line.fact-qnty
    .
  end .
  find last buf_stk-line no-lock
    where buf_stk-line.obj-type  = buf_gds-obj.obj-type
      and buf_stk-line.obj-code  = buf_gds-obj.obj-code
      and buf_stk-line.artic     = buf_goods.artic
      and buf_stk-line.prod-type = buf_gds-obj.prod-type
      and buf_stk-line.prod-code = buf_gds-obj.prod-code
      and buf_stk-line.sum-type  = 'csdt':U + 'ie':U
      and buf_stk-line.cat-id    = '##,##'
      and buf_stk-line.fact-order < v-fact-order-end
    use-index category no-error .
  if available buf_stk-line then do:
    assign
      end-qnty = buf_stk-line.fact-qnty
    .
  end.
  find last buf_stk-line no-lock
    where buf_stk-line.obj-type  = buf_gds-obj.obj-type
      and buf_stk-line.obj-code  = buf_gds-obj.obj-code
      and buf_stk-line.artic     = buf_goods.artic
      and buf_stk-line.prod-type = buf_gds-obj.prod-type
      and buf_stk-line.prod-code = buf_gds-obj.prod-code
      and buf_stk-line.sum-type  = 'csdt':U + 'ie':U
      and buf_stk-line.cat-id    = '##,##'
      and buf_stk-line.fact-order <= v-fact-order-start
    use-index category no-error .
  if available buf_stk-line then do:
    assign
      beg-qnty = buf_stk-line.fact-qnty
    .
  end.
  assign
    in-qnty = in-qnty + end-qnty - beg-qnty
  .
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
  if available buf_stk-line then do:
    assign
      sale-qnty = buf_stk-line.fact-qnty
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
  if available buf_stk-line then do:
    assign
      sale-qnty = sale-qnty - buf_stk-line.fact-qnty
    .
  end.
  if sale-qnty <> 0 or in-qnty <> 0 then do:
    find first temp-GrSales1
      where temp-GrSales1.obj-type   = buf_gds-obj.obj-type
        and temp-GrSales1.obj-code   = buf_gds-obj.obj-code
        and temp-GrSales1.grp-code   = buf_goods.grp-code
    no-error .
    if not available temp-GrSales1 then do:
      create temp-GrSales1 .
      run grplib-get-full-name in this-procedure ( input buf_goods.grp-code,output temp-GrSales1.full-grp-name) .
      assign
        temp-GrSales1.obj-type  = buf_gds-obj.obj-type
        temp-GrSales1.obj-code  = buf_gds-obj.obj-code
        temp-GrSales1.grp-name  = entry ( num-entries( right-trim(buf_goods.grp-name, chr(47)), chr(47) ), buf_goods.grp-name, chr(47) )
        temp-GrSales1.grp-code  = buf_goods.grp-code
        temp-GrSales1.in-qnty   = 0
        temp-GrSales1.sale-qnty = 0
      .
    end.
    if in-qnty <> 0   then assign temp-GrSales1.sale-qnty = temp-GrSales1.sale-qnty + 1 .
    if sale-qnty <> 0 then assign temp-GrSales1.in-qnty   = temp-GrSales1.in-qnty   + 1 .
  end.
  end.
            else                 do:
define variable vss-include-info22 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
  if buf_gds-obj.last-doc = ? then next .
  if buf_gds-obj.last-doc < x-date-start and buf_gds-obj.fact-qnty = 0 and buf_gds-obj.avrg-qnty = 0 and buf_gds-obj.fact-sale =0 and buf_gds-obj.fact-base = 0 then next .
  assign  Counter1  = Counter1 + 1 .
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
   DO ii = 1 TO num-entries( p_cli-list ) :
     find first buf_clients where recid(buf_clients) = integer(entry(ii, p_cli-list)) no-error.
     if not avail buf_clients then next .
    assign
      beg-qnty  = 0
      end-qnty  = 0
      sale-qnty = 0
      in-qnty   = 0
    .
    find last buf_stk-supp-line no-lock
      where buf_stk-supp-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-supp-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-supp-line.cli-type  = buf_clients.obj-type
        and buf_stk-supp-line.cli-code  = buf_clients.obj-code
        and buf_stk-supp-line.artic     = buf_goods.artic
        and buf_stk-supp-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-supp-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-supp-line.fact-order  <= v-fact-order-start
        and buf_stk-supp-line.sum-type  = 'cost':U
      no-error .
    if available buf_stk-supp-line then do:
      assign
        in-qnty = buf_stk-supp-line.fact-qnty
      .
    end .
    find last buf_stk-supp-line no-lock
      where buf_stk-supp-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-supp-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-supp-line.cli-type  = buf_clients.obj-type
        and buf_stk-supp-line.cli-code  = buf_clients.obj-code
        and buf_stk-supp-line.artic     = buf_goods.artic
        and buf_stk-supp-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-supp-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-supp-line.fact-order < v-fact-order-end
        and buf_stk-supp-line.sum-type  = 'sadt':U + 'ie':U
      no-error .
    if available buf_stk-supp-line then do:
      assign
        end-qnty = buf_stk-supp-line.fact-qnty
      .
    end.
    find last buf_stk-supp-line no-lock
      where buf_stk-supp-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-supp-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-supp-line.cli-type  = buf_clients.obj-type
        and buf_stk-supp-line.cli-code  = buf_clients.obj-code
        and buf_stk-supp-line.artic     = buf_goods.artic
        and buf_stk-supp-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-supp-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-supp-line.fact-order <= v-fact-order-start
        and buf_stk-supp-line.sum-type  = 'sadt':U + 'ie':U
      no-error .
    if available buf_stk-supp-line then do:
      assign
        beg-qnty = buf_stk-supp-line.fact-qnty
      .
    end.
    assign
      in-qnty = in-qnty + end-qnty - beg-qnty
    .
    find last buf_stk-supp-line no-lock
      where buf_stk-supp-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-supp-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-supp-line.cli-type  = buf_clients.obj-type
        and buf_stk-supp-line.cli-code  = buf_clients.obj-code
        and buf_stk-supp-line.artic     = buf_goods.artic
        and buf_stk-supp-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-supp-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-supp-line.fact-order < v-fact-order-end
        and buf_stk-supp-line.sum-type  = 'sadt':U + 'es':U
      no-error .
    if available buf_stk-supp-line then do:
      assign
        sale-qnty = buf_stk-supp-line.fact-qnty
      .
    end.
    find last buf_stk-supp-line no-lock
      where buf_stk-supp-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-supp-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-supp-line.cli-type  = buf_clients.obj-type
        and buf_stk-supp-line.cli-code  = buf_clients.obj-code
        and buf_stk-supp-line.artic     = buf_goods.artic
        and buf_stk-supp-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-supp-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-supp-line.fact-order <= v-fact-order-start
        and buf_stk-supp-line.sum-type  = 'sadt':U + 'es':U
      no-error .
    if available buf_stk-supp-line then do:
      assign
        sale-qnty = sale-qnty - buf_stk-supp-line.fact-qnty
      .
    end.
    if sale-qnty <> 0 or in-qnty <> 0 then do:
      find first temp-GrSales1
        where temp-GrSales1.obj-type   = buf_gds-obj.obj-type
          and temp-GrSales1.obj-code   = buf_gds-obj.obj-code
          and temp-GrSales1.grp-code   = buf_goods.grp-code
      no-error .
      if not available temp-GrSales1 then do:
        create temp-GrSales1 .
        run grplib-get-full-name in this-procedure ( input buf_goods.grp-code,output temp-GrSales1.full-grp-name) .
        assign
          temp-GrSales1.obj-type  = buf_gds-obj.obj-type
          temp-GrSales1.obj-code  = buf_gds-obj.obj-code
          temp-GrSales1.grp-name  = entry ( num-entries( right-trim(buf_goods.grp-name, chr(47)), chr(47) ) , buf_goods.grp-name, chr(47) )
          temp-GrSales1.grp-code  = buf_goods.grp-code
          temp-GrSales1.in-qnty   = 0
          temp-GrSales1.sale-qnty = 0
        .
      end.
      if in-qnty <> 0   then assign temp-GrSales1.sale-qnty = temp-GrSales1.sale-qnty + 1 .
      if sale-qnty <> 0 then assign temp-GrSales1.in-qnty   = temp-GrSales1.in-qnty   + 1 .
    end.
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
              if p_provid = 1 then do:
define variable vss-include-info23 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
  if buf_gds-obj.last-doc = ? then next .
  if buf_gds-obj.last-doc < x-date-start and buf_gds-obj.fact-qnty = 0 and buf_gds-obj.avrg-qnty = 0 and buf_gds-obj.fact-sale =0 and buf_gds-obj.fact-base = 0 then next .
  assign
    Counter1  = Counter1 + 1
    beg-qnty  = 0
    end-qnty  = 0
    sale-qnty = 0
    in-qnty   = 0
  .
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
  find last buf_stk-line no-lock
    where buf_stk-line.obj-type  = buf_gds-obj.obj-type
      and buf_stk-line.obj-code  = buf_gds-obj.obj-code
      and buf_stk-line.artic     = buf_goods.artic
      and buf_stk-line.prod-type = buf_gds-obj.prod-type
      and buf_stk-line.prod-code = buf_gds-obj.prod-code
      and buf_stk-line.sum-type  = 'crsa':U
      and buf_stk-line.cat-id    = '##,##'
      and buf_stk-line.fact-order  <= v-fact-order-start
    use-index category no-error .
  if available buf_stk-line then do:
    assign
      in-qnty  = buf_stk-line.fact-qnty
    .
  end .
  find last buf_stk-line no-lock
    where buf_stk-line.obj-type  = buf_gds-obj.obj-type
      and buf_stk-line.obj-code  = buf_gds-obj.obj-code
      and buf_stk-line.artic     = buf_goods.artic
      and buf_stk-line.prod-type = buf_gds-obj.prod-type
      and buf_stk-line.prod-code = buf_gds-obj.prod-code
      and buf_stk-line.sum-type  = 'csdt':U + 'ie':U
      and buf_stk-line.cat-id    = '##,##'
      and buf_stk-line.fact-order < v-fact-order-end
    use-index category no-error .
  if available buf_stk-line then do:
    assign
      end-qnty = buf_stk-line.fact-qnty
    .
  end.
  find last buf_stk-line no-lock
    where buf_stk-line.obj-type  = buf_gds-obj.obj-type
      and buf_stk-line.obj-code  = buf_gds-obj.obj-code
      and buf_stk-line.artic     = buf_goods.artic
      and buf_stk-line.prod-type = buf_gds-obj.prod-type
      and buf_stk-line.prod-code = buf_gds-obj.prod-code
      and buf_stk-line.sum-type  = 'csdt':U + 'ie':U
      and buf_stk-line.cat-id    = '##,##'
      and buf_stk-line.fact-order <= v-fact-order-start
    use-index category no-error .
  if available buf_stk-line then do:
    assign
      beg-qnty = buf_stk-line.fact-qnty
    .
  end.
  assign
    in-qnty = in-qnty + end-qnty - beg-qnty
  .
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
  if available buf_stk-line then do:
    assign
      sale-qnty = buf_stk-line.fact-qnty
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
  if available buf_stk-line then do:
    assign
      sale-qnty = sale-qnty - buf_stk-line.fact-qnty
    .
  end.
  if sale-qnty <> 0 or in-qnty <> 0 then do:
    find first temp-GrSales1
      where temp-GrSales1.obj-type   = buf_gds-obj.obj-type
        and temp-GrSales1.obj-code   = buf_gds-obj.obj-code
        and temp-GrSales1.grp-code   = buf_goods.grp-code
    no-error .
    if not available temp-GrSales1 then do:
      create temp-GrSales1 .
      run grplib-get-full-name in this-procedure ( input buf_goods.grp-code,output temp-GrSales1.full-grp-name) .
      assign
        temp-GrSales1.obj-type  = buf_gds-obj.obj-type
        temp-GrSales1.obj-code  = buf_gds-obj.obj-code
        temp-GrSales1.grp-name  = entry ( num-entries( right-trim(buf_goods.grp-name, chr(47)), chr(47) ), buf_goods.grp-name, chr(47) )
        temp-GrSales1.grp-code  = buf_goods.grp-code
        temp-GrSales1.in-qnty   = 0
        temp-GrSales1.sale-qnty = 0
      .
    end.
    if in-qnty <> 0   then assign temp-GrSales1.sale-qnty = temp-GrSales1.sale-qnty + 1 .
    if sale-qnty <> 0 then assign temp-GrSales1.in-qnty   = temp-GrSales1.in-qnty   + 1 .
  end.
  end.
              else                 do:
define variable vss-include-info24 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
  if buf_gds-obj.last-doc = ? then next .
  if buf_gds-obj.last-doc < x-date-start and buf_gds-obj.fact-qnty = 0 and buf_gds-obj.avrg-qnty = 0 and buf_gds-obj.fact-sale =0 and buf_gds-obj.fact-base = 0 then next .
  assign  Counter1  = Counter1 + 1 .
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
   DO ii = 1 TO num-entries( p_cli-list ) :
     find first buf_clients where recid(buf_clients) = integer(entry(ii, p_cli-list)) no-error.
     if not avail buf_clients then next .
    assign
      beg-qnty  = 0
      end-qnty  = 0
      sale-qnty = 0
      in-qnty   = 0
    .
    find last buf_stk-supp-line no-lock
      where buf_stk-supp-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-supp-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-supp-line.cli-type  = buf_clients.obj-type
        and buf_stk-supp-line.cli-code  = buf_clients.obj-code
        and buf_stk-supp-line.artic     = buf_goods.artic
        and buf_stk-supp-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-supp-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-supp-line.fact-order  <= v-fact-order-start
        and buf_stk-supp-line.sum-type  = 'cost':U
      no-error .
    if available buf_stk-supp-line then do:
      assign
        in-qnty = buf_stk-supp-line.fact-qnty
      .
    end .
    find last buf_stk-supp-line no-lock
      where buf_stk-supp-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-supp-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-supp-line.cli-type  = buf_clients.obj-type
        and buf_stk-supp-line.cli-code  = buf_clients.obj-code
        and buf_stk-supp-line.artic     = buf_goods.artic
        and buf_stk-supp-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-supp-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-supp-line.fact-order < v-fact-order-end
        and buf_stk-supp-line.sum-type  = 'sadt':U + 'ie':U
      no-error .
    if available buf_stk-supp-line then do:
      assign
        end-qnty = buf_stk-supp-line.fact-qnty
      .
    end.
    find last buf_stk-supp-line no-lock
      where buf_stk-supp-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-supp-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-supp-line.cli-type  = buf_clients.obj-type
        and buf_stk-supp-line.cli-code  = buf_clients.obj-code
        and buf_stk-supp-line.artic     = buf_goods.artic
        and buf_stk-supp-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-supp-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-supp-line.fact-order <= v-fact-order-start
        and buf_stk-supp-line.sum-type  = 'sadt':U + 'ie':U
      no-error .
    if available buf_stk-supp-line then do:
      assign
        beg-qnty = buf_stk-supp-line.fact-qnty
      .
    end.
    assign
      in-qnty = in-qnty + end-qnty - beg-qnty
    .
    find last buf_stk-supp-line no-lock
      where buf_stk-supp-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-supp-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-supp-line.cli-type  = buf_clients.obj-type
        and buf_stk-supp-line.cli-code  = buf_clients.obj-code
        and buf_stk-supp-line.artic     = buf_goods.artic
        and buf_stk-supp-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-supp-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-supp-line.fact-order < v-fact-order-end
        and buf_stk-supp-line.sum-type  = 'sadt':U + 'es':U
      no-error .
    if available buf_stk-supp-line then do:
      assign
        sale-qnty = buf_stk-supp-line.fact-qnty
      .
    end.
    find last buf_stk-supp-line no-lock
      where buf_stk-supp-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-supp-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-supp-line.cli-type  = buf_clients.obj-type
        and buf_stk-supp-line.cli-code  = buf_clients.obj-code
        and buf_stk-supp-line.artic     = buf_goods.artic
        and buf_stk-supp-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-supp-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-supp-line.fact-order <= v-fact-order-start
        and buf_stk-supp-line.sum-type  = 'sadt':U + 'es':U
      no-error .
    if available buf_stk-supp-line then do:
      assign
        sale-qnty = sale-qnty - buf_stk-supp-line.fact-qnty
      .
    end.
    if sale-qnty <> 0 or in-qnty <> 0 then do:
      find first temp-GrSales1
        where temp-GrSales1.obj-type   = buf_gds-obj.obj-type
          and temp-GrSales1.obj-code   = buf_gds-obj.obj-code
          and temp-GrSales1.grp-code   = buf_goods.grp-code
      no-error .
      if not available temp-GrSales1 then do:
        create temp-GrSales1 .
        run grplib-get-full-name in this-procedure ( input buf_goods.grp-code,output temp-GrSales1.full-grp-name) .
        assign
          temp-GrSales1.obj-type  = buf_gds-obj.obj-type
          temp-GrSales1.obj-code  = buf_gds-obj.obj-code
          temp-GrSales1.grp-name  = entry ( num-entries( right-trim(buf_goods.grp-name, chr(47)), chr(47) ) , buf_goods.grp-name, chr(47) )
          temp-GrSales1.grp-code  = buf_goods.grp-code
          temp-GrSales1.in-qnty   = 0
          temp-GrSales1.sale-qnty = 0
        .
      end.
      if in-qnty <> 0   then assign temp-GrSales1.sale-qnty = temp-GrSales1.sale-qnty + 1 .
      if sale-qnty <> 0 then assign temp-GrSales1.in-qnty   = temp-GrSales1.in-qnty   + 1 .
    end.
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
            if p_provid = 1 then do:
define variable vss-include-info25 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
  if buf_gds-obj.last-doc = ? then next .
  if buf_gds-obj.last-doc < x-date-start and buf_gds-obj.fact-qnty = 0 and buf_gds-obj.avrg-qnty = 0 and buf_gds-obj.fact-sale =0 and buf_gds-obj.fact-base = 0 then next .
  assign
    Counter1  = Counter1 + 1
    beg-qnty  = 0
    end-qnty  = 0
    sale-qnty = 0
    in-qnty   = 0
  .
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
  find last buf_stk-line no-lock
    where buf_stk-line.obj-type  = buf_gds-obj.obj-type
      and buf_stk-line.obj-code  = buf_gds-obj.obj-code
      and buf_stk-line.artic     = buf_goods.artic
      and buf_stk-line.prod-type = buf_gds-obj.prod-type
      and buf_stk-line.prod-code = buf_gds-obj.prod-code
      and buf_stk-line.sum-type  = 'crsa':U
      and buf_stk-line.cat-id    = '##,##'
      and buf_stk-line.fact-order  <= v-fact-order-start
    use-index category no-error .
  if available buf_stk-line then do:
    assign
      in-qnty  = buf_stk-line.fact-qnty
    .
  end .
  find last buf_stk-line no-lock
    where buf_stk-line.obj-type  = buf_gds-obj.obj-type
      and buf_stk-line.obj-code  = buf_gds-obj.obj-code
      and buf_stk-line.artic     = buf_goods.artic
      and buf_stk-line.prod-type = buf_gds-obj.prod-type
      and buf_stk-line.prod-code = buf_gds-obj.prod-code
      and buf_stk-line.sum-type  = 'csdt':U + 'ie':U
      and buf_stk-line.cat-id    = '##,##'
      and buf_stk-line.fact-order < v-fact-order-end
    use-index category no-error .
  if available buf_stk-line then do:
    assign
      end-qnty = buf_stk-line.fact-qnty
    .
  end.
  find last buf_stk-line no-lock
    where buf_stk-line.obj-type  = buf_gds-obj.obj-type
      and buf_stk-line.obj-code  = buf_gds-obj.obj-code
      and buf_stk-line.artic     = buf_goods.artic
      and buf_stk-line.prod-type = buf_gds-obj.prod-type
      and buf_stk-line.prod-code = buf_gds-obj.prod-code
      and buf_stk-line.sum-type  = 'csdt':U + 'ie':U
      and buf_stk-line.cat-id    = '##,##'
      and buf_stk-line.fact-order <= v-fact-order-start
    use-index category no-error .
  if available buf_stk-line then do:
    assign
      beg-qnty = buf_stk-line.fact-qnty
    .
  end.
  assign
    in-qnty = in-qnty + end-qnty - beg-qnty
  .
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
  if available buf_stk-line then do:
    assign
      sale-qnty = buf_stk-line.fact-qnty
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
  if available buf_stk-line then do:
    assign
      sale-qnty = sale-qnty - buf_stk-line.fact-qnty
    .
  end.
  if sale-qnty <> 0 or in-qnty <> 0 then do:
    find first temp-GrSales1
      where temp-GrSales1.obj-type   = buf_gds-obj.obj-type
        and temp-GrSales1.obj-code   = buf_gds-obj.obj-code
        and temp-GrSales1.grp-code   = buf_goods.grp-code
    no-error .
    if not available temp-GrSales1 then do:
      create temp-GrSales1 .
      run grplib-get-full-name in this-procedure ( input buf_goods.grp-code,output temp-GrSales1.full-grp-name) .
      assign
        temp-GrSales1.obj-type  = buf_gds-obj.obj-type
        temp-GrSales1.obj-code  = buf_gds-obj.obj-code
        temp-GrSales1.grp-name  = entry ( num-entries( right-trim(buf_goods.grp-name, chr(47)), chr(47) ), buf_goods.grp-name, chr(47) )
        temp-GrSales1.grp-code  = buf_goods.grp-code
        temp-GrSales1.in-qnty   = 0
        temp-GrSales1.sale-qnty = 0
      .
    end.
    if in-qnty <> 0   then assign temp-GrSales1.sale-qnty = temp-GrSales1.sale-qnty + 1 .
    if sale-qnty <> 0 then assign temp-GrSales1.in-qnty   = temp-GrSales1.in-qnty   + 1 .
  end.
  end.
            else                 do:
define variable vss-include-info26 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
  if buf_gds-obj.last-doc = ? then next .
  if buf_gds-obj.last-doc < x-date-start and buf_gds-obj.fact-qnty = 0 and buf_gds-obj.avrg-qnty = 0 and buf_gds-obj.fact-sale =0 and buf_gds-obj.fact-base = 0 then next .
  assign  Counter1  = Counter1 + 1 .
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
   DO ii = 1 TO num-entries( p_cli-list ) :
     find first buf_clients where recid(buf_clients) = integer(entry(ii, p_cli-list)) no-error.
     if not avail buf_clients then next .
    assign
      beg-qnty  = 0
      end-qnty  = 0
      sale-qnty = 0
      in-qnty   = 0
    .
    find last buf_stk-supp-line no-lock
      where buf_stk-supp-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-supp-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-supp-line.cli-type  = buf_clients.obj-type
        and buf_stk-supp-line.cli-code  = buf_clients.obj-code
        and buf_stk-supp-line.artic     = buf_goods.artic
        and buf_stk-supp-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-supp-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-supp-line.fact-order  <= v-fact-order-start
        and buf_stk-supp-line.sum-type  = 'cost':U
      no-error .
    if available buf_stk-supp-line then do:
      assign
        in-qnty = buf_stk-supp-line.fact-qnty
      .
    end .
    find last buf_stk-supp-line no-lock
      where buf_stk-supp-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-supp-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-supp-line.cli-type  = buf_clients.obj-type
        and buf_stk-supp-line.cli-code  = buf_clients.obj-code
        and buf_stk-supp-line.artic     = buf_goods.artic
        and buf_stk-supp-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-supp-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-supp-line.fact-order < v-fact-order-end
        and buf_stk-supp-line.sum-type  = 'sadt':U + 'ie':U
      no-error .
    if available buf_stk-supp-line then do:
      assign
        end-qnty = buf_stk-supp-line.fact-qnty
      .
    end.
    find last buf_stk-supp-line no-lock
      where buf_stk-supp-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-supp-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-supp-line.cli-type  = buf_clients.obj-type
        and buf_stk-supp-line.cli-code  = buf_clients.obj-code
        and buf_stk-supp-line.artic     = buf_goods.artic
        and buf_stk-supp-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-supp-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-supp-line.fact-order <= v-fact-order-start
        and buf_stk-supp-line.sum-type  = 'sadt':U + 'ie':U
      no-error .
    if available buf_stk-supp-line then do:
      assign
        beg-qnty = buf_stk-supp-line.fact-qnty
      .
    end.
    assign
      in-qnty = in-qnty + end-qnty - beg-qnty
    .
    find last buf_stk-supp-line no-lock
      where buf_stk-supp-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-supp-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-supp-line.cli-type  = buf_clients.obj-type
        and buf_stk-supp-line.cli-code  = buf_clients.obj-code
        and buf_stk-supp-line.artic     = buf_goods.artic
        and buf_stk-supp-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-supp-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-supp-line.fact-order < v-fact-order-end
        and buf_stk-supp-line.sum-type  = 'sadt':U + 'es':U
      no-error .
    if available buf_stk-supp-line then do:
      assign
        sale-qnty = buf_stk-supp-line.fact-qnty
      .
    end.
    find last buf_stk-supp-line no-lock
      where buf_stk-supp-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-supp-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-supp-line.cli-type  = buf_clients.obj-type
        and buf_stk-supp-line.cli-code  = buf_clients.obj-code
        and buf_stk-supp-line.artic     = buf_goods.artic
        and buf_stk-supp-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-supp-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-supp-line.fact-order <= v-fact-order-start
        and buf_stk-supp-line.sum-type  = 'sadt':U + 'es':U
      no-error .
    if available buf_stk-supp-line then do:
      assign
        sale-qnty = sale-qnty - buf_stk-supp-line.fact-qnty
      .
    end.
    if sale-qnty <> 0 or in-qnty <> 0 then do:
      find first temp-GrSales1
        where temp-GrSales1.obj-type   = buf_gds-obj.obj-type
          and temp-GrSales1.obj-code   = buf_gds-obj.obj-code
          and temp-GrSales1.grp-code   = buf_goods.grp-code
      no-error .
      if not available temp-GrSales1 then do:
        create temp-GrSales1 .
        run grplib-get-full-name in this-procedure ( input buf_goods.grp-code,output temp-GrSales1.full-grp-name) .
        assign
          temp-GrSales1.obj-type  = buf_gds-obj.obj-type
          temp-GrSales1.obj-code  = buf_gds-obj.obj-code
          temp-GrSales1.grp-name  = entry ( num-entries( right-trim(buf_goods.grp-name, chr(47)), chr(47) ) , buf_goods.grp-name, chr(47) )
          temp-GrSales1.grp-code  = buf_goods.grp-code
          temp-GrSales1.in-qnty   = 0
          temp-GrSales1.sale-qnty = 0
        .
      end.
      if in-qnty <> 0   then assign temp-GrSales1.sale-qnty = temp-GrSales1.sale-qnty + 1 .
      if sale-qnty <> 0 then assign temp-GrSales1.in-qnty   = temp-GrSales1.in-qnty   + 1 .
    end.
  end.
  end.
          end.
        end.
      end case.
    end.
  end.
if session :set-wait-state( "compiler" ) then.
  Line = fill("-", 102).
  DEFINE frame f-doc
      sym1  v-NameString column-label " Отдел/Группа/Подгруппа " format "X(50)"              space(0)
      sym2  v-in-qnty    column-label "Продано за!период  "      format "->>>,>>>,>>9"   space(0)
      sym3  v-sale-qnty  column-label "  Было за !период  "      format "->>>,>>>,>>9"   space(0)
      sym4  v-proc       column-label " % прода- !ваемости"      format  "->>>,>>9.99"       space(0)
      sym5
  HEADER
      string( "Дата печати : " + string(TODAY , "99.99.9999") + " , " + string(TIME, "HH:MM") ) AT 5 format "X(70)"
      string( "Страница " + string( PAGE-NUMBER( OutStream )  , ">>9") ) AT 80 format "X(15)" SKIP
      Line format "X(102)" AT 1
  with width 160 down stream-io.
output stream OutStream to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size 62 .
  FORM HEADER
      Line format "X(102)" AT 1 SKIP
      "Продолжение - на следующей странице" AT 30 SKIP
      with FRAME BottomFrame width 160 PAGE-BOTTOM NO-LABELS NO-BOX .
  VIEW stream OutStream FRAME BottomFrame .
  FORM with FRAME f-doc .
  PUT stream OutStream SPACE(20) "Отчет по количеству наименований с: " x-date-start format "99/99/9999" "г. по: " x-date-end format "99/99/9999" "г." SKIP .
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
  if p_provid = 1 then assign  v-NameString = "Выбор поставщика: все" .
  else                 assign  v-NameString = "Выбор поставщика: выборочно" .
  PUT stream OutStream v-NameString format "X(100)" SKIP .
  for each obj-list no-lock :
    assign
      ind = 0
      titul = yes
      v-old-level = 0
      v-level = 0
    .
    for each temp-GrSales1
      where temp-GrSales1.obj-type = obj-list.obj-type
        and temp-GrSales1.obj-code = obj-list.obj-code
      break by temp-GrSales1.full-grp-name :
      if titul = yes then do:
        assign
          titul = no
          all-in-qnty   = 0
          all-sale-qnty = 0
          v-NameString  = "Объект: " + obj-list.obj-name + " (" + obj-list.obj-type + '#' + string(obj-list.obj-code) + ")"
        .
        display stream outstream sym1 v-NameString sym2 sym3 sym4 sym5 with frame f-doc.
        down stream outstream with frame f-doc .
      end.
      run GrpSumTree in this-procedure .
      assign
        v-NameString  = temp-GrSales1.grp-name
        v-in-qnty     = temp-GrSales1.in-qnty
        v-sale-qnty   = temp-GrSales1.sale-qnty
        v-proc        = 100 - ( ( temp-GrSales1.sale-qnty - temp-GrSales1.in-qnty ) * 100 / temp-GrSales1.sale-qnty )
        all-in-qnty   = all-in-qnty + temp-GrSales1.in-qnty
        all-sale-qnty = all-sale-qnty + temp-GrSales1.sale-qnty
      .
      if v-proc = ? then v-proc = 0 .
      display stream outstream
        sym1  v-NameString
        sym2  v-in-qnty
        sym3  v-sale-qnty
        sym4  v-proc
        sym5
      with frame f-doc.
      down stream outstream with frame f-doc .
      do ii = 1 to v-level :
        run CalculSum in this-procedure (ii) .
      end.
    End.
    do ii = v-old-level to ind by -1 :
      find first temp-grp-sum
        where temp-grp-sum.num = ii no-error .
      if available temp-grp-sum then do:
        assign
          v-NameString = "Итого по группе " + temp-grp-sum.grp + ":"
          v-in-qnty    = temp-grp-sum.in-qnty
          v-sale-qnty  = temp-grp-sum.sale-qnty
          v-proc       = 100 - ( ( temp-grp-sum.sale-qnty - temp-grp-sum.in-qnty ) * 100 / temp-grp-sum.sale-qnty )
        .
        if v-proc = ? then v-proc = 0 .
        display stream outstream sym1 v-NameString sym2 v-in-qnty sym3 v-sale-qnty sym4 v-proc sym5 with frame f-doc.
        down stream outstream with frame f-doc .
      end.
    end.
    for each temp-grp-sum :
      delete temp-grp-sum .
    end.
    if titul = no then do:
      assign
        v-NameString = "Итого по объекту " + obj-list.obj-name + " (" + obj-list.obj-type + '#' + string(obj-list.obj-code) + ") :"
        v-in-qnty    = all-in-qnty
        v-sale-qnty  = all-sale-qnty
        v-proc       = 100 - ( ( all-sale-qnty - all-in-qnty ) * 100 / all-sale-qnty )
      .
      if v-proc = ? then v-proc = 0 .
      display stream outstream sym1 v-NameString sym2 v-in-qnty sym3 v-sale-qnty sym4 v-proc sym5 with frame f-doc.
      down stream outstream with frame f-doc .
      display stream outstream sym1 sym2 sym3 sym4 sym5 with frame f-doc.
      down stream outstream with frame f-doc .
    end.
  End.
  PUT STREAM OutStream Line format "X(102)".
  HIDE stream OutStream FRAME BottomFrame .
  OUTPUT stream OutStream CLOSE.
if mFrameView
then do:
   HIDE FRAME InfoFrame.
end.
if session :set-wait-state( "" ) then.
  define variable v-user-action as character no-undo .
  define variable v-printed as logical   no-undo .
  run gbl/prnfilen.w
    (input  ""
    ,input  0
    ,input  string(session :temp-directory) + "rpt" + string( g#report-num )
    ,input 7
    ,output v-user-action
    ,output v-printed
    ) .
end.
procedure GrpSumTree :
  v-level      = num-entries( right-trim(temp-GrSales1.full-grp-name, chr(47)), chr(47) ) - 1 .
  assign CurrGrpName = "" .
  do ind = 1 to v-level :
    assign CurrGrpName = CurrGrpName + entry ( ind, temp-GrSales1.full-grp-name, chr(47) )  + chr(47).
    find first temp-grp-sum
      where temp-grp-sum.full_grp = CurrGrpName
    no-error .
    if not available temp-grp-sum then LEAVE.
  end.
  do ii = v-old-level to ind by -1 :
    find first temp-grp-sum
      where temp-grp-sum.num = ii .
    assign
      v-NameString = "Итого по группе " + temp-grp-sum.grp + ":"
      v-in-qnty    = temp-grp-sum.in-qnty
      v-sale-qnty  = temp-grp-sum.sale-qnty
      v-proc       = 100 - ( ( temp-grp-sum.sale-qnty - temp-grp-sum.in-qnty ) * 100 / temp-grp-sum.sale-qnty )
    .
    if v-proc = ? then v-proc = 0 .
    display stream outstream sym1 v-NameString sym2 v-in-qnty sym3 v-sale-qnty sym4 v-proc sym5 with frame f-doc.
    down stream outstream with frame f-doc .
    delete temp-grp-sum .
  end.
  assign
     v-old-level = v-level
  .
  do ii = ind to v-level :
    create temp-grp-sum .
    if ii > ind then do:
      assign CurrGrpName = CurrGrpName + entry ( ii, temp-GrSales1.full-grp-name, chr(47) )  + chr(47).
    end.
    assign
      temp-grp-sum.num = ii
      temp-grp-sum.full_grp = CurrGrpName
      temp-grp-sum.grp = entry ( ii, temp-GrSales1.full-grp-name, chr(47) )
      v-NameString = "Группа " + temp-grp-sum.grp
      temp-grp-sum.in-qnty    = 0
      temp-grp-sum.sale-qnty  = 0
    .
    display stream outstream sym1 v-NameString sym2 sym3 sym4 sym5 with frame f-doc.
    down stream outstream with frame f-doc .
  end.
end procedure.
procedure CalculSum :
  define input  parameter p-num as integer   no-undo .
  define buffer buf_temp-grp-sum for temp-grp-sum .
  find first buf_temp-grp-sum where buf_temp-grp-sum.num = p-num no-error .
  assign
    buf_temp-grp-sum.in-qnty   = buf_temp-grp-sum.in-qnty     + v-in-qnty
    buf_temp-grp-sum.sale-qnty = buf_temp-grp-sum.sale-qnty + v-sale-qnty
  .
end procedure.
