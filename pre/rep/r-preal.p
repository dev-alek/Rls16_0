block-level on error undo, throw.
define input parameter parparentproc      as widget-handle no-undo .
define input parameter parobj-type        like ub.trn-doc.obj-type no-undo.
define input parameter parobj-code        like ub.trn-doc.obj-code no-undo.
define input parameter porog-zn as INTEGER    no-undo .
define input parameter type-pos as character   no-undo .
define input parameter t-shift  as logical    no-undo .
def var vss-revision    as character no-undo init "$Revision: 9c0a3724b62e, 3232, rls $":U .
def var vss-author      as character no-undo init "$Author: EShklyar $":U .
def var vss-date        as character no-undo init "$Date: 2022/12/27 12:54:29 $":U .
def var vss-workfile    as character no-undo init "$Workfile: r-preal.p $":U .
def var vss-archive     as character no-undo init "$Archive: rep/r-preal.p $":U .
def var vss-description as character no-undo init "Отчет по анализу длительности пересменка (Простой реализации до первого чека)".
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
define new shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define new shared variable RepPathName        as character no-undo .
define new shared variable PrintRubl          as logical   no-undo .
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE LastDate:
    def input parameter in-date as date no-undo.
    def output parameter LastDate as date no-undo.
    LastDate = ((DATE(MONTH(in-date),28,YEAR(in-date)) + 4) - DAY(DATE(MONTH(in-date),28,YEAR(in-date)) + 4)).
END PROCEDURE.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure sys-time_get-sys :
  define output parameter p-year         as integer   no-undo .
  define output parameter p-month        as integer   no-undo .
  define output parameter p-day          as integer   no-undo .
  define output parameter p-hour         as integer   no-undo .
  define output parameter p-minute       as integer   no-undo .
  define output parameter p-second       as integer   no-undo .
  define output parameter p-milliseconds as integer   no-undo .
  define variable v-system-time-structure as memptr    no-undo.
  do
  on error undo, return error return-value
  :
    assign
      set-size(v-system-time-structure) = 16
    .
    run GetSystemTime
      (input  get-pointer-value(v-system-time-structure)
      ) .
    assign
      p-year         = get-short(v-system-time-structure,  1)
      p-month        = get-short(v-system-time-structure,  3)
      p-day          = get-short(v-system-time-structure,  7)
      p-hour         = get-short(v-system-time-structure,  9)
      p-minute       = get-short(v-system-time-structure, 11)
      p-second       = get-short(v-system-time-structure, 13)
      p-milliseconds = get-short(v-system-time-structure, 15)
    .
    assign
      set-size(v-system-time-structure) = 0
    .
  end.
end procedure.
procedure sys-time_get-comp-user-name :
  define output parameter p-computer-name as character no-undo .
  define output parameter p-user-name     as character no-undo .
  define output parameter p-process-pid   as integer   no-undo .
  define variable v-return-value  as integer   no-undo .
  define variable v-buffer-length as integer   no-undo .
  define variable v-buffer-memptr as memptr    no-undo .
  do
  on error undo, return error return-value
  :
    assign
      v-buffer-length = 1024
      set-size(v-buffer-memptr) = v-buffer-length + 4
    .
    assign
      put-long(v-buffer-memptr, 1) = v-buffer-length
    .
    run GetComputerNameA
      (input  get-pointer-value(v-buffer-memptr) + 4
      ,input  get-pointer-value(v-buffer-memptr)
      ,output v-return-value
      ) .
    if v-return-value <> 0
    then do:
      assign
        p-computer-name = get-string(v-buffer-memptr, 5)
      .
    end.
    assign
      put-long(v-buffer-memptr, 1) = v-buffer-length
    .
    run GetUserNameA
      (input  get-pointer-value(v-buffer-memptr) + 4
      ,input  get-pointer-value(v-buffer-memptr)
      ,output v-return-value
      ) .
    if v-return-value <> 0
    then do:
      assign
        p-user-name = get-string(v-buffer-memptr, 5)
      .
    end.
    run GetCurrentProcessId
      (output p-process-pid
      ) .
    assign
      set-size(v-buffer-memptr) = 0
    .
  end.
end procedure.
procedure sys-time_get-http :
  define output parameter p-http-time as character no-undo .
  define variable v-year         as integer   no-undo .
  define variable v-month        as integer   no-undo .
  define variable v-day-of-week  as integer   no-undo .
  define variable v-day          as integer   no-undo .
  define variable v-hour         as integer   no-undo .
  define variable v-minute       as integer   no-undo .
  define variable v-second       as integer   no-undo .
  define variable v-milliseconds as integer   no-undo .
  do
  on error undo, return error return-value
  :
    run sys-time_get-sys in this-procedure
      (output v-year
      ,output v-month
      ,output v-day
      ,output v-hour
      ,output v-minute
      ,output v-second
      ,output v-milliseconds
      ) .
    assign
      v-day-of-week = weekday(date(v-month, v-day, v-year))
      p-http-time = entry(v-day-of-week, 'Sun,Mon,Tue,Wed,Thu,Fri,Sat')
                  + ', ':u
                  + string(v-day, '99':u)
                  + ' ':u
                  + entry(v-month, 'Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec':u)
                  + ' ':u
                  + string(v-year, '9999':u)
                  + ' ':u
                  + string(v-hour, '99':u)
                  + ':':u
                  + string(v-minute, '99':u)
                  + ':':u
                  + string(v-second, '99':u)
                  + ' ':u
                  + 'GMT':u
    .
  end.
end procedure.
procedure sys-time_set-sys :
  define input  parameter p-year         as integer   no-undo .
  define input  parameter p-month        as integer   no-undo .
  define input  parameter p-day          as integer   no-undo .
  define input  parameter p-hour         as integer   no-undo .
  define input  parameter p-minute       as integer   no-undo .
  define input  parameter p-second       as integer   no-undo .
  define input  parameter p-milliseconds as integer   no-undo .
  define variable v-system-time-structure as memptr    no-undo.
  define variable v-return-value as integer   no-undo .
  define variable v-day-of-week  as integer   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      v-day-of-week = weekday(date(p-month, p-day, p-year))
    .
    assign
      set-size(v-system-time-structure) = 16
    .
    assign
      put-short(v-system-time-structure,  1) = p-year
      put-short(v-system-time-structure,  3) = p-month
      put-short(v-system-time-structure,  5) = v-day-of-week
      put-short(v-system-time-structure,  7) = p-day
      put-short(v-system-time-structure,  9) = p-hour
      put-short(v-system-time-structure, 11) = p-minute
      put-short(v-system-time-structure, 13) = p-second
      put-short(v-system-time-structure, 15) = p-milliseconds
    .
    run SetSystemTime
      (input  get-pointer-value(v-system-time-structure)
      ,output v-return-value
      ) .
    assign
      set-size(v-system-time-structure) = 0
    .
    if v-return-value = 0
    then do:
      undo, return error "sys-time_set-sys: Ошибка при установке даты" .
    end.
  end.
end procedure.
procedure sys-time_sys-to-mjd :
  define input  parameter p-year         as integer   no-undo .
  define input  parameter p-month        as integer   no-undo .
  define input  parameter p-day          as integer   no-undo .
  define input  parameter p-hour         as integer   no-undo .
  define input  parameter p-minute       as integer   no-undo .
  define input  parameter p-second       as integer   no-undo .
  define input  parameter p-milliseconds as integer   no-undo .
  define output parameter p-mjd          as decimal   no-undo .
  define variable v-year-correction as decimal   no-undo .
  define variable v-shift-year as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      v-year-correction = truncate((decimal(p-month) - 14.0) / 12, 0)
      v-shift-year      = decimal(p-year) + v-year-correction
      p-mjd = truncate( (1461.0 * (v-shift-year + 4800.0 ) ) / 4, 0)
            + truncate( (367.0 * (decimal(p-month) - 2.0 - v-year-correction * 12) ) / 12, 0)
            - truncate( (3 * truncate((v-shift-year + 4900 ) / 100,0) ) / 4, 0)
            + decimal(p-day) - 2432076.0
            + p-hour / 24.0
            + p-minute / 1440.0
            + p-second / 86400.0
            + p-milliseconds / 86400000.0
    .
  end.
end procedure.
procedure sys-time_sys-to-loc :
  define input  parameter p-sys-year         as integer   no-undo .
  define input  parameter p-sys-month        as integer   no-undo .
  define input  parameter p-sys-day          as integer   no-undo .
  define input  parameter p-sys-hour         as integer   no-undo .
  define input  parameter p-sys-minute       as integer   no-undo .
  define input  parameter p-sys-second       as integer   no-undo .
  define input  parameter p-sys-milliseconds as integer   no-undo .
  define output parameter p-loc-year         as integer   no-undo .
  define output parameter p-loc-month        as integer   no-undo .
  define output parameter p-loc-day          as integer   no-undo .
  define output parameter p-loc-hour         as integer   no-undo .
  define output parameter p-loc-minute       as integer   no-undo .
  define output parameter p-loc-second       as integer   no-undo .
  define output parameter p-loc-milliseconds as integer   no-undo .
  define variable v-system-time-structure as memptr    no-undo.
  define variable v-return-value          as integer   no-undo .
  define variable v-sys-day-of-week       as integer   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      v-sys-day-of-week = weekday(date(p-sys-month, p-sys-day, p-sys-year))
    .
    assign
      set-size(v-system-time-structure) = 32
    .
    assign
      put-short(v-system-time-structure,  1) = p-sys-year
      put-short(v-system-time-structure,  3) = p-sys-month
      put-short(v-system-time-structure,  5) = v-sys-day-of-week
      put-short(v-system-time-structure,  7) = p-sys-day
      put-short(v-system-time-structure,  9) = p-sys-hour
      put-short(v-system-time-structure, 11) = p-sys-minute
      put-short(v-system-time-structure, 13) = p-sys-second
      put-short(v-system-time-structure, 15) = p-sys-milliseconds
    .
    run SystemTimeToTzSpecificLocalTime
      (input  0
      ,input  get-pointer-value(v-system-time-structure)
      ,input  get-pointer-value(v-system-time-structure) + 16
      ,output v-return-value
      ) .
    assign
      p-loc-year         = get-short(v-system-time-structure,  1 + 16)
      p-loc-month        = get-short(v-system-time-structure,  3 + 16)
      p-loc-day          = get-short(v-system-time-structure,  7 + 16)
      p-loc-hour         = get-short(v-system-time-structure,  9 + 16)
      p-loc-minute       = get-short(v-system-time-structure, 11 + 16)
      p-loc-second       = get-short(v-system-time-structure, 13 + 16)
      p-loc-milliseconds = get-short(v-system-time-structure, 15 + 16)
    .
    assign
      set-size(v-system-time-structure) = 0
    .
    if v-return-value = 0
    then do:
      undo, return error "sys-time_set-sys: Ошибка при установке даты" .
    end.
  end.
end procedure.
procedure sys-time_mjd-to-sys :
  define input  parameter p-mjd          as decimal   no-undo .
  define output parameter p-year         as integer   no-undo .
  define output parameter p-month        as integer   no-undo .
  define output parameter p-day          as integer   no-undo .
  define output parameter p-hour         as integer   no-undo .
  define output parameter p-minute       as integer   no-undo .
  define output parameter p-second       as integer   no-undo .
  define output parameter p-milliseconds as integer   no-undo .
  define variable v-year-correction as decimal   no-undo .
  define variable v-shift-year      as decimal   no-undo .
  define variable v-conv-date     as date      no-undo .
  define variable v-int-part      as integer   no-undo .
  define variable v-fraction-part as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      v-int-part      = integer(truncate(p-mjd, 0))
      v-fraction-part = p-mjd - v-int-part
      v-conv-date     = date(11, 17, 1858) + v-int-part
      p-year          = year(v-conv-date)
      p-month         = month(v-conv-date)
      p-day           = day(v-conv-date)
      v-fraction-part = v-fraction-part * 24.0
      p-hour          = integer(truncate(v-fraction-part, 0))
      v-fraction-part = (v-fraction-part - p-hour) * 60.0
      p-minute        = integer(truncate(v-fraction-part, 0))
      v-fraction-part = (v-fraction-part - p-minute) * 60.0
      p-second        = integer(truncate(v-fraction-part, 0))
      v-fraction-part = (v-fraction-part - p-second) * 1000.0
      p-milliseconds  = integer(v-fraction-part)
    .
  end.
end procedure.
procedure sys-time_mjd-to-loc :
  define input  parameter p-mjd              as decimal   no-undo .
  define output parameter p-loc-year         as integer   no-undo .
  define output parameter p-loc-month        as integer   no-undo .
  define output parameter p-loc-day          as integer   no-undo .
  define output parameter p-loc-hour         as integer   no-undo .
  define output parameter p-loc-minute       as integer   no-undo .
  define output parameter p-loc-second       as integer   no-undo .
  define output parameter p-loc-milliseconds as integer   no-undo .
  define variable v-sys-year         as integer   no-undo .
  define variable v-sys-month        as integer   no-undo .
  define variable v-sys-day          as integer   no-undo .
  define variable v-sys-hour         as integer   no-undo .
  define variable v-sys-minute       as integer   no-undo .
  define variable v-sys-second       as integer   no-undo .
  define variable v-sys-milliseconds as integer   no-undo .
  do
  on error undo, return error return-value
  :
    run sys-time_mjd-to-sys
      (input  p-mjd
      ,output v-sys-year
      ,output v-sys-month
      ,output v-sys-day
      ,output v-sys-hour
      ,output v-sys-minute
      ,output v-sys-second
      ,output v-sys-milliseconds
      ) .
    run sys-time_sys-to-loc
      (input  v-sys-year
      ,input  v-sys-month
      ,input  v-sys-day
      ,input  v-sys-hour
      ,input  v-sys-minute
      ,input  v-sys-second
      ,input  v-sys-milliseconds
      ,output p-loc-year
      ,output p-loc-month
      ,output p-loc-day
      ,output p-loc-hour
      ,output p-loc-minute
      ,output p-loc-second
      ,output p-loc-milliseconds
      ) .
  end.
end procedure.
function sys-time_get-mjd-func returns decimal
:
  define variable v-year         as integer   no-undo .
  define variable v-month        as integer   no-undo .
  define variable v-day          as integer   no-undo .
  define variable v-hour         as integer   no-undo .
  define variable v-minute       as integer   no-undo .
  define variable v-second       as integer   no-undo .
  define variable v-milliseconds as integer   no-undo .
  define variable v-mjd          as decimal   no-undo .
  run sys-time_get-sys in this-procedure
    (output v-year
    ,output v-month
    ,output v-day
    ,output v-hour
    ,output v-minute
    ,output v-second
    ,output v-milliseconds
    ) .
  run sys-time_sys-to-mjd in this-procedure
    (input  v-year
    ,input  v-month
    ,input  v-day
    ,input  v-hour
    ,input  v-minute
    ,input  v-second
    ,input  v-milliseconds
    ,output v-mjd
    ) .
  return v-mjd .
end function .
function sys-time_get-sys-str-func returns character
:
  define variable v-utc-time as character no-undo .
  define variable v-year         as integer   no-undo .
  define variable v-month        as integer   no-undo .
  define variable v-day          as integer   no-undo .
  define variable v-hour         as integer   no-undo .
  define variable v-minute       as integer   no-undo .
  define variable v-second       as integer   no-undo .
  define variable v-milliseconds as integer   no-undo .
  run sys-time_get-sys in this-procedure
    (output v-year
    ,output v-month
    ,output v-day
    ,output v-hour
    ,output v-minute
    ,output v-second
    ,output v-milliseconds
    ) .
  assign
    v-utc-time  = 'UTC ':u
                + string(v-year,         '9999':u)
                + '/':u
                + string(v-month,        '99':u)
                + '/':u
                + string(v-day,          '99':u)
                + ' ':u
                + string(v-hour,         '99':u)
                + ':':u
                + string(v-minute,       '99':u)
                + ':':u
                + string(v-second,       '99':u)
                + ' ':u
                + string(v-milliseconds, '999':u)
  .
  return v-utc-time.
end function .
function sys-time_mjd-to-loc-str-func returns character
  (v-sys-mjd as decimal)
:
  define variable v-loc-str          as character no-undo .
  define variable v-loc-year         as integer   no-undo .
  define variable v-loc-month        as integer   no-undo .
  define variable v-loc-day          as integer   no-undo .
  define variable v-loc-hour         as integer   no-undo .
  define variable v-loc-minute       as integer   no-undo .
  define variable v-loc-second       as integer   no-undo .
  define variable v-loc-milliseconds as integer   no-undo .
  run sys-time_mjd-to-loc in this-procedure
    (input  v-sys-mjd
    ,output v-loc-year
    ,output v-loc-month
    ,output v-loc-day
    ,output v-loc-hour
    ,output v-loc-minute
    ,output v-loc-second
    ,output v-loc-milliseconds
    ) .
  assign
    v-loc-str = substitute('&1/&2/&3 &4:&5'
                          ,string(v-loc-day,    '99':U)
                          ,string(v-loc-month,  '99':U)
                          ,string(v-loc-year,   '9999':U)
                          ,string(v-loc-hour,   '99':U)
                          ,string(v-loc-minute, '99':U)
                          )
  .
  return v-loc-str .
end function .
PROCEDURE GetSystemTime EXTERNAL "kernel32.dll"
:
  DEFINE INPUT  PARAMETER lpSystemTime AS LONG .
END PROCEDURE.
PROCEDURE SetSystemTime EXTERNAL "kernel32.dll"
:
  DEFINE INPUT  PARAMETER lpSystemTime AS LONG .
  DEFINE RETURN PARAMETER ReturnValue  AS LONG .
END PROCEDURE.
PROCEDURE GetTimeZoneInformation EXTERNAL "kernel32.dll"
:
  DEFINE INPUT  PARAMETER lpTimeZoneInformation AS LONG .
  DEFINE RETURN PARAMETER ReturnValue           AS LONG .
END PROCEDURE.
PROCEDURE SystemTimeToTzSpecificLocalTime EXTERNAL "kernel32.dll"
:
  DEFINE INPUT  PARAMETER lpTimeZone      AS LONG .
  DEFINE INPUT  PARAMETER lpUniversalTime AS LONG .
  DEFINE INPUT  PARAMETER lpLocalTime     AS LONG .
  DEFINE RETURN PARAMETER ReturnValue     AS LONG .
END PROCEDURE.
PROCEDURE GetUserNameA EXTERNAL "advapi32.dll"
:
  DEFINE INPUT  PARAMETER lpBuffer    AS LONG .
  DEFINE INPUT  PARAMETER lpnSize     AS LONG .
  DEFINE RETURN PARAMETER ReturnValue AS LONG .
END PROCEDURE.
PROCEDURE GetComputerNameA EXTERNAL "kernel32.dll"
:
  DEFINE INPUT  PARAMETER lpBuffer    AS LONG .
  DEFINE INPUT  PARAMETER lpnSize     AS LONG .
  DEFINE RETURN PARAMETER ReturnValue AS LONG .
END PROCEDURE.
PROCEDURE GetCurrentProcessId EXTERNAL "kernel32.dll"
:
  DEFINE RETURN PARAMETER RetVal          AS LONG.
END PROCEDURE.
define buffer buf_clients         for ub.clients .
define variable v-file-name-rep-htm as character no-undo.
define variable var-report-num as int no-undo.
define variable time-chk-chr as character no-undo.
define variable kassir-chr as character no-undo.
define variable varhost-code  like ub.trn-doc.host-code  no-undo.
define variable v-host-name   as character               no-undo.
define variable v-obj-name    as character               no-undo.
define variable var-prev-shift-date like ub.shift-obj.shift-date no-undo.
define variable var-prev-shift-num like ub.shift-obj.shift-num   no-undo.
define variable var-shift-staff   like ub.shift-staff.name       no-undo.
define stream OutStr-html.
FUNCTION format-etime RETURNS CHARACTER
   (INPUT p-etime AS INT64)
   :
   define variable v-datetime as character no-undo .
   define variable v-col-date as integer   no-undo .
   if p-etime = ?
      then
   do:
      return " " .
   end.
   if p-etime >= 86400 then
   do:
      v-col-date = int(p-etime / 86400) .
      if p-etime - (v-col-date * 86400) < 0 then
      do:
         if (v-col-date - 1) > 0 then
            v-datetime = string((v-col-date - 1),">>>>>>>>>9") + "дн." + string( 86400 + p-etime - ((v-col-date - 1) * 86400), 'HH:MM:SS') .
      end.
      else
         v-datetime = string((v-col-date),">>>>>>>>>9") + "дн." + string(( p-etime - (v-col-date) * 86400), 'HH:MM:SS') .
   end.
   else
   do:
      v-datetime = string( p-etime, 'HH:MM:SS') .
   end.
   return v-datetime .
END FUNCTION.
FUNCTION qnty-dif-int RETURNS INTEGER
   (input p-date-End as date,
   input p-time-end as integer,
   INPUT p-date-Start AS date,
   input p-time-Start as integer) :
   define variable v-datetime as integer no-undo .
   define variable v-col-date as integer no-undo .
   if (p-time-end - p-time-Start) < 0 then
   do:
      v-datetime = integer(p-date-end - p-date-start - 1) * 86400  + ( 86400 + p-time-end - p-time-Start) .
   end.
   else
   do:
      v-datetime = (p-date-end - p-date-start) * 86400 + (p-time-end - p-time-Start) .
   end.
   if v-datetime < 0 then v-datetime = 0 .
   return v-datetime .
END FUNCTION.
FUNCTION qnty-dif RETURNS CHARACTER
   (input p-date-End as date,
   input p-time-end as integer,
   INPUT p-date-Start AS date,
   input p-time-Start as integer) :
   define variable v-datetime as character no-undo .
   define variable v-col-date as integer   no-undo .
   if (p-time-end - p-time-Start) < 0 then
   do:
      v-datetime = string(p-date-end - p-date-start - 1) + " " +
         string((86400 + (p-time-end - p-time-Start)),"HH:MM:SS") .
   end.
   else
   do:
      v-datetime = string(p-date-end - p-date-start) + " " +
         string((p-time-end - p-time-Start),"HH:MM:SS") .
   end.
   return v-datetime .
END FUNCTION.
FUNCTION Type-kassa RETURNS CHARACTER
   (INPUT p-kassa AS character)
   :
   if p-kassa = ""
      then
   do:
      return " " .
   end.
   case p-kassa:
      when "Все" then
         return "Все" .
      when "IBM-XML" then
         return "ППО UniFO-L" .
      when "Autotank" then
         return "АСУ Заправщик" .
   end case .
END FUNCTION.
find first buf_clients no-lock
   where buf_clients.obj-type = parobj-type
   and buf_clients.obj-code = parobj-code
   .
assign
   v-obj-name = buf_clients.obj-name
   .
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  parobj-type
  ,input  parobj-code
  ,output varhost-code
  )  .
find first buf_clients no-lock
   where buf_clients.obj-type = 'орг':U
   and buf_clients.obj-code = varhost-code
   .
assign
   v-host-name = buf_clients.obj-name
   .
run get-report-num in parParentProc (
   output var-report-num
   ).
v-file-name-rep-htm = session:temp-directory + "rpt" + string(var-report-num) + ".html".
output to value(v-file-name-rep-htm).
output close.
def var v-first-time as int       no-undo.
def var v-first-date as date      no-undo.
def var v-last-date  as date      no-undo.
def var v-last-time  as int       no-undo.
def var filtr        as character no-undo.
FOR EACH obj-list  NO-LOCK:
   filtr = filtr + " " + obj-list.obj-name.
END.
output stream OutStr-html to value(v-file-name-rep-htm) convert target 'UTF-8' .
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
.
put stream OutStr-html unformatted
   '<body orientation="landscape" name = "Отчет по пересменкам" fit_to_page="true">' skip
   '<table>' skip
   '<thead>' skip
   '<tr class="set_columns">' skip
   '<td style="width:200px"></td>' skip
   '<td style="width:200px"></td>' skip
   '<td style="width:250px"></td>' skip
   '<td style="width:250px"></td>' skip
   '<td style="width:250px"></td>' skip
   '<td style="width:200px"></td>' skip
   '<td style="width:200px"></td>' skip
   '</tr>' skip
   '<tr>' skip
   '<td colspan="7"></td>' skip
   '</tr>' skip
   '<tr style="height:30px;">' skip
   '<td colspan="1"> </td>' skip
   '<td colspan="6" style="font-weight:bold;"><b> Анализ длительности пересменки ( Простой реализации до первого чека ) </b></td>' skip
   '</tr>' skip
   '<tr>' skip
   '<td colspan="1"></td>' skip
   '<td colspan="6"></td>' skip
   '</tr>' skip
   '<tr>' skip
   '<td colspan="1"> Фирма: </td>' skip
   '<td colspan="6">' + string(v-host-name) + '</td>' skip
   '</tr>' skip
   '<tr>' skip
   '<td colspan="1" > Период: </td>' skip
   '<td colspan="6" > ' + string(x-Date-Start, "99.99.9999") + ' - ' + string(X-date-End, "99.99.9999") + '</td>' skip
   '</tr>' skip
   '<tr>' skip
   '<td colspan="1" > Фильтры: </td>' skip
   '<td colspan="6" >' + string(filtr) + '</td>' skip
   '</tr>' skip
   '<tr>' skip
   '<td colspan="1" > Порог: </td>' skip
   '<td colspan="6" >' + format-etime(porog-zn * 60) + '</td>' skip
   '</tr>' skip
   '<tr>' skip
   '<td colspan="1" > Типы касс: </td>' skip
   '<td colspan="6" >' + Type-kassa(type-pos) + '</td>' skip
   '</tr>' skip
   '<tr>' skip
   '<td colspan="7"></td>' skip
   '</tr>' skip
   '</thead>' skip
   '<tbody>' skip
   '<tr bgcolor="#C6E0B4">' skip
   '<th bgcolor="#C6E0B4" rowspan="2" style="text-align: center;">Наименование объекта</th>' skip
   '<th bgcolor="#C6E0B4" rowspan="2" style="text-align: center;">Дата/Номер смены</th>' skip
   '<th bgcolor="#C6E0B4" rowspan="2" colspan="5"  style="text-align: center;">Простой реализации на АЗК/АЗС</th>' skip
   '</tr>' skip
   '<tr>' skip
   '</tr>' skip
   '<tr bgcolor="#C6E0B4">' skip
   '<th bgcolor="#C6E0B4" style="text-align: center;">Номер кассы</th>' skip
   '<th bgcolor="#C6E0B4" style="text-align: center;">Тип кассы</th>' skip
   '<th bgcolor="#C6E0B4" style="text-align: center;">Старший смены</th>' skip
   '<th bgcolor="#C6E0B4" style="text-align: center;">Дата/время последнего чека продажи</th>' skip
   '<th bgcolor="#C6E0B4" style="text-align: center;">Дата/время первого чека продажи</th>' skip
   '<th bgcolor="#C6E0B4" style="text-align: center;">Время простоя реализации</th>' skip
   '<th bgcolor="#C6E0B4" style="text-align: center;">Время превышения установленного порога простоя реализации</th>' skip
   '</tr>' skip
   .
DEFINE TEMP-TABLE tt-peresmen NO-UNDO
   FIELD ob-type      LIKE chk-doc.obj-type
   FIELD kod-azs      like chk-doc.obj-code
   FIELD name-azs     as character
   FIELD kassa        LIKE chk-doc.pay-desk
   FIELD kassir       like chk-doc.cashier
   FIELD kassir2      like chk-doc.cashier-psn-code
   FIELD shift-num    like chk-doc.shift-num
   FIELD shift-date   like chk-doc.shift-date
   FIELD chk-date-beg like chk-doc.shift-date
   FIELD chk-date-end like chk-doc.shift-date
   FIELD chk-time-beg like chk-doc.chk-time
   FIELD chk-time-end like chk-doc.chk-time
   FIELD peresm-date  as date
   FIELD peresm-num   as integer
   FIELD time-p       AS INT
   FIELD npp          AS INT
   FIELD shift-name   like chk-doc.shift-name
   FIELD flg          AS INT
   field more         as character
   field chk-num-beg  like chk-doc.doc-code
   field chk-num-end  like chk-doc.doc-code
   INDEX pi AS UNIQUE PRIMARY kod-azs kassa peresm-date npp
   .
DEFINE TEMP-TABLE tt-period NO-UNDO
   FIELD obj-type       LIKE chk-doc.obj-type
   FIELD obj-code       like chk-doc.obj-code
   FIELD obj-name       as character
   FIELD shift-num-beg  like chk-doc.shift-num
   FIELD shift-date-beg like chk-doc.shift-date
   FIELD shift-num-end  like chk-doc.shift-num
   FIELD shift-date-end like chk-doc.shift-date
   FIELD npp            AS INT
   FIELD flg            AS INT
   FIELD shift-date     as date
   FIELD shift-num      as integer
   INDEX pi AS UNIQUE PRIMARY npp obj-type obj-code
   .
DEFINE TEMP-TABLE tt-tr NO-UNDO
   FIELD npp       AS INT
   FIELD td_1      as character
   FIELD td_2      as character
   FIELD td_3      as character
   FIELD td_4_date as date
   FIELD td_5_date as date
   FIELD td_4_time as integer
   FIELD td_5_time as integer
   FIELD td_6      as integer
   FIELD td_7      as integer
   field td_8_date as date
   field td_8_num  as integer
   field td_9      as character
   INDEX pi AS UNIQUE PRIMARY npp
   .
define variable smena_old         as CHARACTER no-undo.
define variable kassa_old         as INTEGER   no-undo.
define variable kod-azs_old       as INTEGER   no-undo.
define variable shift-date_old    as DATE      no-undo.
DEFINE VARIABLE nom_p             as int       init 0 NO-UNDO.
DEFINE VARIABLE time-p-all        AS INT       NO-UNDO.
DEFINE VARIABLE time-kas          AS INT       NO-UNDO init 0.
DEFINE VARIABLE time-azs          AS INT       NO-UNDO init 0.
DEFINE VARIABLE time-azs-all      AS INT       NO-UNDO init 0.
DEFINE VARIABLE kassir1           AS int       NO-UNDO init 0.
DEFINE VARIABLE kod-azs2          AS int       NO-UNDO init 0.
DEFINE VARIABLE name-azs2         AS CHARACTER NO-UNDO.
DEFINE VARIABLE manager           AS CHARACTER NO-UNDO.
DEFINE VARIABLE date_it           AS DATE      NO-UNDO.
DEFINE VARIABLE ch-1              AS int       NO-UNDO init 1.
DEFINE VARIABLE ch-2              AS int       NO-UNDO init 0.
DEFINE VARIABLE kol-prev          AS int       NO-UNDO init 0.
DEFINE VARIABLE kol-prev-all      AS int       NO-UNDO init 0.
DEFINE VARIABLE kol-prev-kassa    AS int       NO-UNDO init 0.
DEFINE VARIABLE kol-prev-azs      AS int       NO-UNDO init 0.
DEFINE VARIABLE kol-prev-azs-all  AS int       NO-UNDO init 0.
DEFINE VARIABLE kol-per           AS int       NO-UNDO init 0.
DEFINE VARIABLE kol-per-kassa     AS int       NO-UNDO init 0.
DEFINE VARIABLE kol-per-azs       AS int       NO-UNDO init 0.
DEFINE VARIABLE kol-per-azs-all   AS int       NO-UNDO init 0.
DEFINE VARIABLE time-prev-kassa   AS int       NO-UNDO init 0.
DEFINE VARIABLE time-prev-azs     AS int       NO-UNDO init 0.
DEFINE VARIABLE time-prev-azs-all AS int       NO-UNDO init 0.
DEFINE VARIABLE time-prev         AS int       NO-UNDO init 0.
DEFINE VARIABLE time-pr-sv        AS int       NO-UNDO init 0.
DEFINE VARIABLE time-pr-sv-all    AS int       NO-UNDO init 0.
DEFINE VARIABLE prm-1             AS int       NO-UNDO .
DEFINE VARIABLE prm-1-all         AS int       NO-UNDO .
DEFINE VARIABLE prm-2             AS int       NO-UNDO .
DEFINE VARIABLE prm-3             AS int       NO-UNDO .
DEFINE VARIABLE prm-4             AS int       NO-UNDO .
DEFINE VARIABLE prm-4-all         AS int       NO-UNDO .
define variable v-date            as date      no-undo .
define variable shift-date-start  as date      no-undo .
define variable shift-num-start   as integer   no-undo .
define variable v-date-obj        as date      no-undo .
define buffer buf_shift-obj   for ub.shift-obj .
define buffer bf_shift-obj    for ub.shift-obj .
define buffer buf_tt-tr       for tt-tr .
define buffer buf_tt-peresmen for tt-peresmen .
FOR EACH obj-list  NO-LOCK:
   if x-tog-shift then
   do:
      for last ub.shift-obj no-lock where ub.shift-obj.obj-code = obj-list.obj-code and
         ub.shift-obj.obj-type = obj-list.obj-type and
         (ub.shift-obj.shift-date < x-Date-Start or
         (ub.shift-obj.shift-date = x-Date-Start and ub.shift-obj.shift-num < x-Shift-Start)):
         create tt-period .
         assign
            tt-period.obj-code       = ub.shift-obj.obj-code
            tt-period.obj-type       = ub.shift-obj.obj-type
            tt-period.obj-name       = obj-list.obj-name
            tt-period.shift-date-beg = ub.shift-obj.shift-date
            tt-period.shift-num-beg  = ub.shift-obj.shift-num
            .
      end.
      if not available (tt-period) then
      do:
         create tt-period .
         assign
            tt-period.obj-code = obj-list.obj-code
            tt-period.obj-type = obj-list.obj-type
            tt-period.obj-name = obj-list.obj-name
            .
      end.
      for each ub.shift-obj no-lock where ub.shift-obj.obj-code = tt-period.obj-code and
         ub.shift-obj.obj-type = tt-period.obj-type and
         ub.shift-obj.shift-date >= tt-period.shift-date-beg and
         ub.shift-obj.shift-date <= x-Date-End:
         if ub.shift-obj.shift-date = tt-period.shift-date-beg and ub.shift-obj.shift-num <= tt-period.shift-num-beg then next .
         if ub.shift-obj.shift-date = x-date-End   and ub.shift-obj.shift-num > x-Shift-End then next .
         nom_p = nom_p + 1 .
         assign
            tt-period.shift-date-end = ub.shift-obj.shift-date
            tt-period.shift-num-end  = ub.shift-obj.shift-num
            tt-period.shift-num      = tt-period.shift-num-end
            tt-period.shift-date     = tt-period.shift-date-end
            tt-period.npp            = nom_p
            tt-period.flg            = 1
            .
         create tt-period .
         assign
            tt-period.obj-code       = ub.shift-obj.obj-code
            tt-period.obj-type       = ub.shift-obj.obj-type
            tt-period.obj-name       = obj-list.obj-name
            tt-period.shift-date-beg = ub.shift-obj.shift-date
            tt-period.shift-num-beg  = ub.shift-obj.shift-num
            .
      end.
   end.
   else
   do:
      for first buf_shift-obj no-lock where buf_shift-obj.obj-code = obj-list.obj-code and
         buf_shift-obj.obj-type = obj-list.obj-type and
         buf_shift-obj.shift-date >= x-Date-Start:
         for last ub.shift-obj no-lock where ub.shift-obj.obj-code = buf_shift-obj.obj-code and
            ub.shift-obj.obj-type = buf_shift-obj.obj-type and
            (ub.shift-obj.shift-date < buf_shift-obj.shift-date or
            (ub.shift-obj.shift-date = buf_shift-obj.shift-date and ub.shift-obj.shift-num < buf_shift-obj.shift-num)):
            create tt-period .
            assign
               tt-period.obj-code       = ub.shift-obj.obj-code
               tt-period.obj-type       = ub.shift-obj.obj-type
               tt-period.obj-name       = obj-list.obj-name
               tt-period.shift-date-beg = ub.shift-obj.shift-date
               tt-period.shift-num-beg  = ub.shift-obj.shift-num
               .
         end.
      end.
      if not available (tt-period) then
      do:
         create tt-period .
         assign
            tt-period.obj-code = obj-list.obj-code
            tt-period.obj-type = obj-list.obj-type
            tt-period.obj-name = obj-list.obj-name
            .
      end.
      for each ub.shift-obj no-lock where ub.shift-obj.obj-code = tt-period.obj-code and
         ub.shift-obj.obj-type = tt-period.obj-type and
         ub.shift-obj.shift-date >= tt-period.shift-date-beg and
         ub.shift-obj.shift-date <= x-Date-End:
         if ub.shift-obj.shift-date = tt-period.shift-date-beg and ub.shift-obj.shift-num <= tt-period.shift-num-beg then next .
         nom_p = nom_p + 1 .
         assign
            tt-period.shift-date-end = ub.shift-obj.shift-date
            tt-period.shift-num-end  = ub.shift-obj.shift-num
            tt-period.shift-num      = tt-period.shift-num-end
            tt-period.shift-date     = tt-period.shift-date-end
            tt-period.npp            = nom_p
            tt-period.flg            = 1
            .
         create tt-period .
         assign
            tt-period.obj-code       = ub.shift-obj.obj-code
            tt-period.obj-type       = ub.shift-obj.obj-type
            tt-period.obj-name       = obj-list.obj-name
            tt-period.shift-date-beg = ub.shift-obj.shift-date
            tt-period.shift-num-beg  = ub.shift-obj.shift-num
            .
      end.
   end.
end.
if type-pos = "Все" then
do:
   type-pos = "IBM-XML,Autotank" .
end.
nom_p = 0 .
FOR EACH tt-period where tt-period.flg = 1 BREAK BY tt-period.obj-code BY tt-period.npp:
   for each ub.cash-desk no-lock where ub.cash-desk.obj-code = tt-period.obj-code:
      if lookup (string(cash-desk.pos-type),type-pos,",") = 0 then next .
      FIND LAST chk-doc WHERE  chk-doc.chk-type = 1
         and chk-doc.obj-code = tt-period.obj-code
         AND chk-doc.shift-date = tt-period.shift-date-beg
         and chk-doc.shift-num = tt-period.shift-num-beg
         AND chk-doc.pay-desk = ub.cash-desk.cash-num no-lock no-error.
      IF AVAILABLE chk-doc THEN
      do:
         CREATE tt-peresmen.
         ASSIGN
            tt-peresmen.kod-azs      = chk-doc.obj-code
            tt-peresmen.kassa        = chk-doc.pay-desk
            tt-peresmen.chk-time-beg = chk-doc.chk-time
            tt-peresmen.chk-date-beg = chk-doc.chk-date
            tt-peresmen.shift-num    = chk-doc.shift-num
            tt-peresmen.shift-date   = chk-doc.shift-date
            tt-peresmen.chk-num-beg  = chk-doc.doc-code
            tt-peresmen.peresm-date  = chk-doc.shift-date
            tt-peresmen.peresm-num   = chk-doc.shift-num
            .
      END.
      else
      do:
         FIND LAST chk-doc WHERE  chk-doc.chk-type = 1
            and chk-doc.obj-code = tt-period.obj-code
            AND chk-doc.pay-desk = ub.cash-desk.cash-num
            AND ((chk-doc.shift-date = tt-period.shift-date-beg
            and chk-doc.shift-num < tt-period.shift-num-beg) or
            (chk-doc.shift-date < tt-period.shift-date-beg and
            chk-doc.shift-date > tt-period.shift-date-beg - 30))
            no-lock no-error.
         IF AVAILABLE chk-doc THEN
         do:
            CREATE tt-peresmen.
            ASSIGN
               tt-peresmen.kod-azs      = chk-doc.obj-code
               tt-peresmen.kassa        = chk-doc.pay-desk
               tt-peresmen.chk-time-beg = chk-doc.chk-time
               tt-peresmen.chk-date-beg = chk-doc.chk-date
               tt-peresmen.shift-num    = chk-doc.shift-num
               tt-peresmen.shift-date   = chk-doc.shift-date
               tt-peresmen.chk-num-beg  = chk-doc.doc-code
               tt-peresmen.peresm-date  = chk-doc.shift-date
               tt-peresmen.peresm-num   = chk-doc.shift-num
               .
         end.
         else
         do:
            CREATE tt-peresmen.
            ASSIGN
               tt-peresmen.kod-azs     = tt-period.obj-code
               tt-peresmen.kassa       = ub.cash-desk.cash-num
               tt-peresmen.peresm-date = tt-period.shift-date-beg
               tt-peresmen.peresm-num  = tt-period.shift-num-beg
               .
         end.
      end.
      FIND FIRST chk-doc WHERE  chk-doc.chk-type = 1
         AND chk-doc.obj-code = tt-period.obj-code
         AND chk-doc.shift-date = tt-period.shift-date-end
         AND chk-doc.pay-desk = ub.cash-desk.cash-num
         AND chk-doc.shift-num = tt-period.shift-num-end
         no-lock no-error.
      IF AVAILABLE chk-doc THEN
      do:
         nom_p = nom_p + 1.
         ASSIGN
            tt-peresmen.chk-time-end = chk-doc.chk-time
            tt-peresmen.chk-date-end = chk-doc.chk-date
            tt-peresmen.shift-num    = chk-doc.shift-num
            tt-peresmen.npp          = nom_p
            tt-peresmen.name-azs     = tt-period.obj-name
            tt-peresmen.kassir       = chk-doc.cashier
            tt-peresmen.kassir2      = chk-doc.cashier-psn-code
            tt-peresmen.shift-date   = chk-doc.shift-date
            tt-peresmen.chk-num-end  = chk-doc.doc-code
            tt-peresmen.flg          = 1
            .
         if tt-peresmen.kod-azs = 0 then
            ASSIGN
               tt-peresmen.kod-azs = chk-doc.obj-code
               tt-peresmen.kassa   = chk-doc.pay-desk
               .
         tt-peresmen.time-p = qnty-dif-int(tt-peresmen.chk-date-end, tt-peresmen.chk-time-end, tt-peresmen.chk-date-beg, tt-peresmen.chk-time-beg).
      END.
      else delete tt-peresmen .
   end.
end.
define variable v-obj as logical no-undo .
for each obj-list:
   v-obj = false .
for each tt-period NO-LOCK where tt-period.flg = 1 and tt-period.obj-code = obj-list.obj-code and
      tt-period.obj-type = obj-list.obj-type BREAK BY tt-period.obj-code BY tt-period.npp:
   for each tt-peresmen where tt-peresmen.shift-date = tt-period.shift-date and
      tt-peresmen.shift-num = tt-period.shift-num and
      tt-peresmen.kod-azs = tt-period.obj-code and
      tt-peresmen.flg = 1:
      FIND FIRST shift-staff WHERE tt-peresmen.kod-azs = shift-staff.obj-code
         AND shift-staff.staff-role = yes
         AND shift-staff.shift-date = tt-peresmen.shift-date
         and shift-staff.shift-num = tt-peresmen.shift-num
         no-lock no-error.
      IF AVAILABLE shift-staff THEN manager = shift-staff.name.
      else
      do:
         FIND FIRST shift-staff WHERE tt-peresmen.kod-azs = shift-staff.obj-code
            AND shift-staff.shift-date = tt-peresmen.shift-date
            and shift-staff.shift-num = tt-peresmen.shift-num
            no-lock no-error.
         IF AVAILABLE shift-staff THEN manager = shift-staff.name.
      end.
      FIND FIRST cash-desk WHERE cash-desk.obj-code =  tt-peresmen.kod-azs
         AND cash-desk.cash-num = tt-peresmen.kassa no-lock no-error.
      time-p-all = time-p-all + tt-peresmen.time-p.
      time-kas = time-kas + tt-peresmen.time-p.
      ch-1 = ch-1 + 1.
      if qnty-dif-int(tt-peresmen.chk-date-end, tt-peresmen.chk-time-end, tt-peresmen.chk-date-beg, tt-peresmen.chk-time-beg) > porog-zn * 60  then
      do:
            kol-prev-kassa = kol-prev-kassa + 1 .
            kol-prev-azs = kol-prev-azs + 1 .
            time-prev = time-prev + qnty-dif-int(tt-peresmen.chk-date-end, tt-peresmen.chk-time-end, tt-peresmen.chk-date-beg, tt-peresmen.chk-time-beg) - porog-zn * 60 .
         end.
         if tt-peresmen.chk-date-beg <> ? then kol-prev = kol-prev + 1.
         def var td7 as int.
         if (qnty-dif-int(tt-peresmen.chk-date-end, tt-peresmen.chk-time-end, tt-peresmen.chk-date-beg, tt-peresmen.chk-time-beg))  <=  porog-zn * 60   then  td7 = 0.
         else  td7 = (qnty-dif-int(tt-peresmen.chk-date-end, tt-peresmen.chk-time-end, tt-peresmen.chk-date-beg, tt-peresmen.chk-time-beg)) - porog-zn * 60 .
         CREATE tt-tr.
         ASSIGN
            tt-tr.td_1      = STRING(tt-peresmen.kassa)
            tt-tr.td_2      = Type-kassa(cash-desk.pos-type)
            tt-tr.td_3      = manager
            tt-tr.td_4_date = tt-peresmen.chk-date-beg
            tt-tr.td_5_date = tt-peresmen.chk-date-end
            tt-tr.td_4_time = tt-peresmen.chk-time-beg
            tt-tr.td_5_time = tt-peresmen.chk-time-end
            tt-tr.td_6      = qnty-dif-int(tt-peresmen.chk-date-end, tt-peresmen.chk-time-end, tt-peresmen.chk-date-beg, tt-peresmen.chk-time-beg)
            tt-tr.td_7      = td7
            tt-tr.td_8_date = tt-period.shift-date
            tt-tr.td_8_num  = tt-period.shift-num
            tt-tr.npp       = ch-1
            .
         kassir1 = tt-peresmen.kassir.
         kod-azs2 = tt-peresmen.kod-azs.
         name-azs2 = tt-peresmen.name-azs.
         manager = ''.
      end.
      find FIRST tt-tr where tt-tr.npp >= 0 and tt-tr.td_8_date = tt-period.shift-date and
         tt-tr.td_8_num = tt-period.shift-num no-error.
      if AVAILABLE tt-tr then
      do:
         v-obj = true .
         RUN itog_date.
      end.
   END.
   if v-obj then
      RUN itog_azs .
end.
output close .
RUN itog_azs-all.
put stream OutStr-html unformatted
   '</table>'skip
   .
put stream OutStr-html unformatted
   '</body></html> 'skip.
PROCEDURE itog_date:
   CREATE tt-tr.
   ASSIGN
      tt-tr.npp       = 0
      tt-tr.td_1      = name-azs2
      tt-tr.td_9      = string(tt-period.shift-date-end,"99.99.9999") + "/" + string(tt-period.shift-num-end)
      tt-tr.td_8_date = tt-period.shift-date-end
      tt-tr.td_8_num  = tt-period.shift-num-end
      .
   for each buf_tt-tr where buf_tt-tr.td_8_date = tt-tr.td_8_date and
      buf_tt-tr.td_8_num = tt-tr.td_8_num and buf_tt-tr.npp <> 0 by buf_tt-tr.npp:
      if datetime(tt-tr.td_4_date, tt-tr.td_4_time) < datetime(buf_tt-tr.td_4_date, buf_tt-tr.td_4_time) or
         tt-tr.td_4_date = ? then
         assign
            tt-tr.td_4_date = buf_tt-tr.td_4_date
            tt-tr.td_4_time = buf_tt-tr.td_4_time
            .
      if datetime(tt-tr.td_5_date, tt-tr.td_5_time) > datetime(buf_tt-tr.td_5_date, buf_tt-tr.td_5_time) or
         tt-tr.td_5_date = ? then
         assign
            tt-tr.td_5_date = buf_tt-tr.td_5_date
            tt-tr.td_5_time = buf_tt-tr.td_5_time
            .
   end.
   assign
      tt-tr.td_6 = qnty-dif-int(tt-tr.td_5_date, tt-tr.td_5_time, tt-tr.td_4_date, tt-tr.td_4_time).
   if tt-tr.td_6 > porog-zn * 60 then
      tt-tr.td_7 = tt-tr.td_6 - porog-zn * 60 .
      .
  if tt-tr.td_6 <> ? then
  do:
    kol-per-azs = kol-per-azs + 1.
    time-azs = time-azs + tt-tr.td_6.
    time-prev-azs = time-prev-azs  + tt-tr.td_7 .
  end.
   find first tt-tr where tt-tr.npp <> 0 and tt-tr.td_7 <> 0 and tt-tr.td_7 <> ? no-error .
   if available (tt-tr) or not t-shift then do:
   FOR EACH tt-tr no-lock:
      if tt-tr.npp = 0 then
      do:
         put stream OutStr-html unformatted
            '<tr bgcolor="#F8CBAD">' skip
            '<td bgcolor="#F8CBAD" style="text-align:center;">' tt-tr.td_1 '</td>' SKIP
            '<td bgcolor="#F8CBAD" style="text-align:right;">' string(tt-tr.td_9) '</td>' skip
            '<td bgcolor="#F8CBAD" style="text-align:center;">' tt-tr.td_3 '</td>' skip
            '<td bgcolor="#F8CBAD" style="text-align:right;">' (if tt-tr.td_4_date <> ? then string(tt-tr.td_4_date, "99.99.9999") + " " + format-etime(tt-tr.td_4_time) else "") '</td>' skip
            '<td bgcolor="#F8CBAD" style="text-align:right;">' (if tt-tr.td_5_date <> ? then string(tt-tr.td_5_date, "99.99.9999") + " " + format-etime(tt-tr.td_5_time) else "") '</td>' skip
            '<td bgcolor="#F8CBAD" style="text-align:right;">' format-etime(tt-tr.td_6) '</td>' skip
            '<td bgcolor="#F8CBAD" style="text-align:right;">' format-etime(tt-tr.td_7) '</td>' skip
            '</tr>' skip
            .
      end.
      else if tt-tr.npp <> 0 and ((tt-tr.td_7 <> 0 and tt-tr.td_7 <> ?) or not t-shift) then
         do:
            put stream OutStr-html unformatted
               '<tr 'if tt-tr.td_7 <> 0 and tt-tr.td_7 <> ? then 'bgcolor="#FF2400">' else 'bgcolor="#FFFFFF">' skip
               '<td style="text-align:center;">' tt-tr.td_1 '</td>' SKIP
               '<td style="text-align:left;">' tt-tr.td_2 '</td>' skip
               '<td style="text-align:center;">' tt-tr.td_3 '</td>' skip
               '<td style="text-align:right;">' (if tt-tr.td_4_date <> ? then string(tt-tr.td_4_date, "99.99.9999") + " " + format-etime(tt-tr.td_4_time) else "") '</td>' skip
               '<td style="text-align:right;">' (if tt-tr.td_5_date <> ? then string(tt-tr.td_5_date, "99.99.9999") + " " + format-etime(tt-tr.td_5_time) else "") '</td>' skip
               '<td style="text-align:right;">' format-etime(tt-tr.td_6) '</td>' skip
               '<td style="text-align:right;">' format-etime(tt-tr.td_7) '</td>' skip
               '</tr>' skip
               .
         end.
   end.
   end.
   EMPTY TEMP-TABLE tt-tr.
END PROCEDURE.
PROCEDURE itog_azs:
   if time-prev-azs > 0 then time-pr-sv = time-prev-azs / kol-prev-azs.
   if kol-per-azs <> 0 then prm-1 = time-azs / kol-per-azs .
   if kol-prev > 0 then prm-4 = kol-prev-azs / kol-prev * 100 .
   put stream OutStr-html unformatted
      '<tr>' skip
      '<th style="text-align:center;" rowspan="2">' 'Итого по: ' '</th>' SKIP
      '<th bgcolor="#F8CBAD" style="text-align:center;" rowspan="2" >' name-azs2 '</th>' skip
      '<th bgcolor="#C6E0B4" style="text-align:center;">' 'Средняя длительность простоя' '</th>' skip
      '<th bgcolor="#C6E0B4" style="text-align:center;">' 'Количество случаев с превышением порога простоя' '</th>' skip
      '<th bgcolor="#C6E0B4" style="text-align:center;">' 'Общая длительность превышения порога простоя' '</th>' skip
      '<th bgcolor="#C6E0B4" style="text-align:center;">' 'Средняя  длительность превышения порога простоя' '</th>' skip
      '<th bgcolor="#C6E0B4" style="text-align:center;">' 'Процент случаев простоя с превышением порогового значения от общего  кол-ва простоев' '</th>' skip
      '</tr>' skip
      '<tr >' skip
      '<td style="text-align:center;">' format-etime(prm-1) '</td>' skip
      '<td style="text-align:center;">' kol-prev-azs '</td>' skip
      '<td style="text-align:center;">' format-etime(if time-prev-azs > 0 then time-prev-azs else 0) '</td>' skip
      '<td style="text-align:center;">' format-etime(time-pr-sv) '</td>' skip
      '<td style="text-align:center;">' + string(prm-4) + "%" + '</td>' skip
      '</tr>' skip
      .
   assign
      time-prev-azs-all = time-prev-azs-all + time-prev-azs
      kol-per-azs-all   = kol-per-azs-all + kol-per-azs
      time-azs-all      = time-azs-all + time-azs
      kol-prev-azs-all  = kol-prev-azs-all + kol-prev-azs
      kol-prev-all      = kol-prev-all + kol-prev
      .
   assign
      kol-prev-azs  = 0
      kol-per-azs   = 0
      time-azs      = 0
      kol-prev      = 0
      time-prev-azs = 0
      time-pr-sv    = 0
      prm-1         = 0
      prm-4         = 0
      .
END PROCEDURE.
PROCEDURE itog_azs-all:
   if time-prev-azs-all > 0 then time-pr-sv-all = time-prev-azs-all / kol-prev-azs-all.
   if kol-per-azs-all <> 0 then prm-1-all = time-azs-all / kol-per-azs-all .
   if kol-prev-all > 0 then prm-4-all = kol-prev-azs-all / kol-prev-all * 100 .
   put stream OutStr-html unformatted
      '<tr>' skip
      '<th style="text-align:center;" rowspan="2">' 'Итого по: ' '</th>' SKIP
      '<th bgcolor="#F8CBAD" style="text-align:center;" rowspan="2" > Все объекты </th>' skip
      '<th bgcolor="#C6E0B4" style="text-align:center;">' 'Средняя длительность простоя' '</th>' skip
      '<th bgcolor="#C6E0B4" style="text-align:center;">' 'Количество случаев с превышением порога простоя' '</th>' skip
      '<th bgcolor="#C6E0B4" style="text-align:center;">' 'Общая длительность превышения порога простоя' '</th>' skip
      '<th bgcolor="#C6E0B4" style="text-align:center;">' 'Средняя  длительность превышения порога простоя' '</th>' skip
      '<th bgcolor="#C6E0B4" style="text-align:center;">' 'Процент случаев простоя с превышением порогового значения от общего  кол-ва простоев' '</th>' skip
      '</tr>' skip
      '<tr >' skip
      '<td style="text-align:center;">' format-etime(prm-1-all) '</td>' skip
      '<td style="text-align:center;">' kol-prev-azs-all '</td>' skip
      '<td style="text-align:center;">' format-etime(if time-prev-azs-all > 0 then time-prev-azs-all else 0) '</td>' skip
      '<td style="text-align:center;">' format-etime(time-pr-sv-all) '</td>' skip
      '<td style="text-align:center;">' + string(prm-4-all) + "%" + '</td>' skip
      '</tr>' skip
      .
END PROCEDURE.
output stream OutStr-html close.
run prn-lib-reportviewer in this-procedure (
   input parparentproc
   ,input v-file-name-rep-htm
   ,input ""
   ) no-error.
if error-status:error then
do:
   message return-value view-as alert-box.
   return .
end.
