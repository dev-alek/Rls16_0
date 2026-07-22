block-level on error undo, throw.
define input parameter parparentproc      as widget-handle no-undo .
define input parameter parobj-type        like ub.trn-doc.obj-type no-undo.
define input parameter parobj-code        like ub.trn-doc.obj-code no-undo.
define input parameter p-tog-with-tot-day as logical            no-undo .
def var vss-revision    as character no-undo init "$Revision: 20e2b075d76d, 1062, rls $":U .
def var vss-author      as character no-undo init "$Author: EShklyar $":U .
def var vss-date        as character no-undo init "$Date: Fri Oct 06 18:34:13 2017 +0300 $":U .
def var vss-workfile    as character no-undo init "$Workfile: r-ptrlopbal.p $":U .
def var vss-archive     as character no-undo init "$Archive: rep/r-ptrlopbal.p $":U .
def var vss-description as character no-undo init "Контрольно-накопительная ведомость учета излишек и недостач НП".
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
define buffer previous-rvs-doc    for ub.rvs-doc.
define buffer buf_rvs-doc         for ub.rvs-doc .
define buffer bef-rvs-line        for ub.rvs-line.
define buffer buf_rvs-line        for ub.rvs-line .
define buffer start-date-rvs-doc  for ub.rvs-doc.
define buffer end-date-rvs-doc    for ub.rvs-doc.
define buffer start-date-rvs-line for ub.rvs-line.
define buffer end-date-rvs-line   for ub.rvs-line.
define buffer bef-doc-rvs-doc     for ub.rvs-doc.
define buffer aft-doc-rvs-doc     for ub.rvs-doc.
define buffer bef-doc-rvs-line    for ub.rvs-line.
define buffer aft-doc-rvs-line    for ub.rvs-line.
define buffer buf_doc-pl          for ub.doc-pl .
define buffer buf_goods           for ub.goods .
define buffer buf_clients         for ub.clients .
define buffer previous-shift-obj  for ub.shift-obj.
define buffer buf_icnt-doc for ub.icnt-doc .
define buffer buf_icnt-line for ub.icnt-line .
define variable v-file-name-rep-htm as character no-undo.
define variable var-report-num as int no-undo.
define variable varhost-code  like ub.trn-doc.host-code     no-undo.
define variable v-host-name   as character               no-undo.
define variable v-obj-name    as character               no-undo.
define variable v-header-name as character               no-undo.
define variable v-print-time  as character               no-undo.
define variable v-count       as   integer               no-undo .
define variable var-prev-shift-date like ub.shift-obj.shift-date no-undo.
define variable var-prev-shift-num like ub.shift-obj.shift-num   no-undo.
define variable var-shift-staff   like ub.shift-staff.name       no-undo.
define variable v-fill-path-RepView as character no-undo.
define stream OutStr-html.
DEFINE TEMP-TABLE tt-rep NO-UNDO
    FIELD shift-date            like ub.trn-doc.shift-date
    FIELD shift-num             like ub.trn-doc.shift-num
    FIELD time-start            like ub.shift-obj.open-time
    FIELD time-end              like ub.shift-obj.close-time
    FIELD date-end              like ub.shift-obj.close-date
    FIELD gds-code              like ub.goods.gds-code
    FIELD pl-code               LIKE ub.doc-pl.pl-code
    FIELD goods-name            LIKE ub.goods.gds-name
    FIELD rest_start_measure-kg LIKE ub.rvs-line.state-measure-qnty
    FIELD rest_start_book-kg    LIKE ub.rvs-line.system-qnty
    FIELD rest_start_measure-l  LIKE ub.rvs-line.state-measure-qnty
    FIELD rest_start_book-l     LIKE ub.rvs-line.system-qnty
    FIELD wayb_fact-kg          LIKE ub.trn-doc.cli-qnty
    FIELD wayb_fact-l           LIKE ub.trn-doc.fact-qnty
    FIELD exp-kg                LIKE ub.trn-doc.cli-qnty
    FIELD exp-l                 LIKE ub.trn-doc.fact-qnty
    FIELD rest_end_measure-kg   LIKE ub.rvs-line.state-measure-cli-qnty
    FIELD rest_end_book-kg      LIKE ub.rvs-line.system-qnty
    FIELD rest_end_measure-l    LIKE ub.rvs-line.state-measure-qnty
    FIELD rest_end_book-l       LIKE ub.rvs-line.system-qnty
    FIELD rest_end_balans-kg    LIKE ub.rvs-line.state-measure-cli-qnty
    FIELD rest_end_balans-l     LIKE ub.rvs-line.system-qnty
    field state-el-cnt          like icnt-line.state-el-cnt
    field state-mh-cnt          like icnt-line.state-mh-cnt
    FIELD err-kg                LIKE ub.rvs-line.state-measure-qnty
    FIELD err-l                 LIKE ub.rvs-line.system-qnty
    FIELD staff                 like ub.shift-staff.name
    FIELD place_loc1            like ub.place.loc1
    field density               like ub.rvs-line.density
    INDEX pi AS UNIQUE PRIMARY gds-code pl-code shift-date shift-num
 .
define variable var-gds-rest_start_measure-kg  LIKE ub.rvs-line.state-measure-qnty  no-undo.
define variable var-gds-rest_start_book-kg     LIKE ub.rvs-line.system-qnty no-undo.
define variable var-gds-rest_start_measure-l   LIKE ub.rvs-line.state-measure-qnty no-undo.
define variable var-gds-rest_start_book-l      LIKE ub.rvs-line.system-qnty no-undo.
define variable var-gds-wayb_fact-kg           LIKE ub.trn-doc.cli-qnty no-undo.
define variable var-gds-wayb_fact-l            LIKE ub.trn-doc.fact-qnty no-undo.
define variable var-gds-exp-kg                 LIKE ub.trn-doc.cli-qnty no-undo.
define variable var-gds-exp-l                  LIKE ub.trn-doc.fact-qnty no-undo.
define variable var-gds-rest_end_measure-kg   LIKE ub.rvs-line.state-measure-cli-qnty no-undo.
define variable var-gds-rest_end_book-kg      LIKE ub.rvs-line.system-qnty no-undo.
define variable var-gds-rest_end_measure-l    LIKE ub.rvs-line.state-measure-qnty no-undo.
define variable var-gds-rest_end_book-l       LIKE ub.rvs-line.system-qnty no-undo.
define variable var-gds-rest_end_balans-kg    LIKE ub.rvs-line.state-measure-cli-qnty no-undo.
define variable var-gds-rest_end_balans-l     LIKE ub.rvs-line.system-qnty no-undo.
define variable var-pl-rest_start_measure-kg  LIKE ub.rvs-line.state-measure-qnty  no-undo.
define variable var-pl-rest_start_book-kg     LIKE ub.rvs-line.system-qnty no-undo.
define variable var-pl-rest_start_measure-l   LIKE ub.rvs-line.state-measure-qnty no-undo.
define variable var-pl-rest_start_book-l      LIKE ub.rvs-line.system-qnty no-undo.
define variable var-pl-wayb_fact-kg           LIKE ub.trn-doc.cli-qnty no-undo.
define variable var-pl-wayb_fact-l            LIKE ub.trn-doc.fact-qnty no-undo.
define variable var-pl-exp-kg                 LIKE ub.trn-doc.cli-qnty no-undo.
define variable var-pl-exp-l                  LIKE ub.trn-doc.fact-qnty no-undo.
if not can-find(first gds-list) then do:
  message
    "Не заданы товары для формирования опреративного баланса."
    view-as alert-box error.
  return.
end.
find first buf_clients no-lock
  where buf_clients.obj-type = parobj-type
    and buf_clients.obj-code = parobj-code
  .
assign
  v-obj-name = buf_clients.obj-name
.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
            find last previous-shift-obj share-lock
            where previous-shift-obj.obj-type = parobj-type
            and previous-shift-obj.obj-code = parobj-code
            and (( previous-shift-obj.shift-date = X-date-Start
                   and previous-shift-obj.shift-num < X-Shift-Start
                 )
                 or previous-shift-obj.shift-date < X-date-Start
                )
            use-index pi no-error.
            if available previous-shift-obj then do:
                var-prev-shift-num = previous-shift-obj.shift-num.
                var-prev-shift-date = previous-shift-obj.shift-date.
            end.
    for each ub.shift-obj  no-lock
    where ub.shift-obj.obj-code   =  parobj-code
      and ub.shift-obj.obj-type   =  parobj-type
      and ub.shift-obj.shift-date >= X-date-Start
      and ub.shift-obj.shift-date <= X-date-End
        :
        if ub.shift-obj.shift-date = X-date-Start and ub.shift-obj.shift-num < X-Shift-Start then next .
        if ub.shift-obj.shift-date = X-date-End   and ub.shift-obj.shift-num > X-Shift-End then next .
        var-shift-staff  = ''.
        for first ub.shift-staff where
         ub.shift-staff.shift-num = ub.shift-obj.shift-num
         and ub.shift-staff.shift-date = ub.shift-obj.shift-date
         and ub.shift-staff.obj-type = ub.shift-obj.obj-type
         and ub.shift-staff.obj-code = ub.shift-obj.obj-code
         and ub.shift-staff.staff-role = yes no-lock:
             var-shift-staff = ub.shift-staff.name.
        end.
        find first buf_rvs-doc no-lock
          where buf_rvs-doc.obj-type   = parobj-type
          and buf_rvs-doc.obj-code   = parobj-code
          and buf_rvs-doc.shift-date = ub.shift-obj.shift-date
          and buf_rvs-doc.shift-num  = ub.shift-obj.shift-num
          and buf_rvs-doc.status_    = 'факт':U
          and buf_rvs-doc.rvs-type   = 'смена':U
          no-error.
        if not available buf_rvs-doc then next.
          for each buf_rvs-line where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code no-lock, first gds-list where gds-list.gds-code = buf_rvs-line.gds-code no-lock,
          first ub.goods no-lock where ub.goods.gds-code = buf_rvs-line.gds-code  :
              create tt-rep.
              assign
              tt-rep.shift-date   = ub.shift-obj.shift-date
              tt-rep.shift-num    = ub.shift-obj.shift-num
              tt-rep.gds-code    = buf_rvs-line.gds-code
              tt-rep.goods-name    = goods.gds-name
              tt-rep.pl-code     = buf_rvs-line.pl-code
              tt-rep.place_loc1  = string(buf_rvs-line.pl-code)
              tt-rep.rest_end_measure-kg  =  buf_rvs-line.state-measure-cli-qnty + buf_rvs-line.state-add-qnty * buf_rvs-line.state-density
              tt-rep.rest_end_book-kg    = buf_rvs-line.system-cli-qnty
              tt-rep.rest_end_measure-l  =  buf_rvs-line.state-measure-qnty + buf_rvs-line.state-add-qnty
              tt-rep.rest_end_book-l     = buf_rvs-line.system-qnty
              tt-rep.rest_end_balans-kg  = tt-rep.rest_end_measure-kg - tt-rep.rest_end_book-kg
              tt-rep.rest_end_balans-l   = tt-rep.rest_end_measure-l - tt-rep.rest_end_book-l
              tt-rep.staff               = var-shift-staff
              tt-rep.time-start          = ub.shift-obj.open-time
              tt-rep.time-end            = ub.shift-obj.close-time
              tt-rep.date-end            = ub.shift-obj.close-date
              .
              for first ub.place no-lock
                where ub.place.obj-code = parobj-code
                  and ub.place.obj-type = parobj-type
                  and ub.place.pl-code  = tt-rep.pl-code
                 :
                 if ub.place.loc1 > ''  then assign
                 tt-rep.place_loc1 = ub.place.loc1
                .
              end.
          end.
          for each ub.trn-doc no-lock
              where ub.trn-doc.obj-type   = ub.shift-obj.obj-type
                and ub.trn-doc.obj-code   = ub.shift-obj.obj-code
                and ub.trn-doc.shift-date = ub.shift-obj.shift-date
                and ub.trn-doc.shift-num  = ub.shift-obj.shift-num
                and ub.trn-doc.status_    = 'факт':U
                and ub.trn-doc.doc-type   = 'при':U
            on error undo, return error return-value
            :
              for each ub.doc-pl no-lock
                where ub.doc-pl.out-code = ub.trn-doc.doc-code,
                  first tt-rep where tt-rep.shift-date   = ub.shift-obj.shift-date
                  and tt-rep.shift-num    = ub.shift-obj.shift-num
                  and tt-rep.gds-code    = ub.doc-pl.gds-code
                  and tt-rep.pl-code     = ub.doc-pl.pl-code
              on error undo, return error return-value
              :
                assign
                  tt-rep.wayb_fact-l = tt-rep.wayb_fact-l + ub.doc-pl.fact-qnty
                  tt-rep.wayb_fact-kg = tt-rep.wayb_fact-kg + ub.doc-pl.cli-fact-qnty
                  tt-rep.density = tt-rep.wayb_fact-kg / tt-rep.wayb_fact-l
                .
              end.
            end.
            for each ub.trn-doc no-lock
              where ub.trn-doc.obj-type   = ub.shift-obj.obj-type
                and ub.trn-doc.obj-code   = ub.shift-obj.obj-code
                and ub.trn-doc.shift-date = ub.shift-obj.shift-date
                and ub.trn-doc.shift-num  = ub.shift-obj.shift-num
                and ub.trn-doc.status_    = 'факт':U
                and ub.trn-doc.doc-type   = 'рас':U
            on error undo, return error return-value
            :
              for each ub.doc-pl no-lock
                where ub.doc-pl.out-code = ub.trn-doc.doc-code,
                  first tt-rep where tt-rep.shift-date   = ub.shift-obj.shift-date
                  and tt-rep.shift-num    = ub.shift-obj.shift-num
                  and tt-rep.gds-code    = ub.doc-pl.gds-code
                  and tt-rep.pl-code     = ub.doc-pl.pl-code
              on error undo, return error return-value
              :
                assign
                  tt-rep.exp-l = tt-rep.exp-l + ub.doc-pl.fact-qnty
                  tt-rep.exp-kg = tt-rep.exp-kg + ub.doc-pl.cli-fact-qnty
                .
              end.
            end.
                        for each ub.trn-doc no-lock
              where ub.trn-doc.obj-type   = ub.shift-obj.obj-type
                and ub.trn-doc.obj-code   = ub.shift-obj.obj-code
                and ub.trn-doc.shift-date = ub.shift-obj.shift-date
                and ub.trn-doc.shift-num  = ub.shift-obj.shift-num
                and ub.trn-doc.status_    = 'факт':U
                and ub.trn-doc.doc-type   = 'возврат':U
            on error undo, return error return-value
            :
              for each ub.doc-pl no-lock
                where ub.doc-pl.out-code = ub.trn-doc.doc-code,
                  first tt-rep where tt-rep.shift-date   = ub.shift-obj.shift-date
                  and tt-rep.shift-num    = ub.shift-obj.shift-num
                  and tt-rep.gds-code    = ub.doc-pl.gds-code
                  and tt-rep.pl-code     = ub.doc-pl.pl-code
              on error undo, return error return-value
              :
                assign
                  tt-rep.exp-l = tt-rep.exp-l - ub.doc-pl.fact-qnty
                  tt-rep.exp-kg = tt-rep.exp-kg - ub.doc-pl.cli-fact-qnty
                .
              end.
            end.
                        for each ub.trn-doc no-lock
              where ub.trn-doc.obj-type   = ub.shift-obj.obj-type
                and ub.trn-doc.obj-code   = ub.shift-obj.obj-code
                and ub.trn-doc.shift-date = ub.shift-obj.shift-date
                and ub.trn-doc.shift-num  = ub.shift-obj.shift-num
                and ub.trn-doc.status_    = 'факт':U
                and ub.trn-doc.doc-type   = 'спи':U
            on error undo, return error return-value
            :
              for each ub.doc-pl no-lock
                where ub.doc-pl.out-code = ub.trn-doc.doc-code,
                  first tt-rep where tt-rep.shift-date   = ub.shift-obj.shift-date
                  and tt-rep.shift-num    = ub.shift-obj.shift-num
                  and tt-rep.gds-code    = ub.doc-pl.gds-code
                  and tt-rep.pl-code     = ub.doc-pl.pl-code
              on error undo, return error return-value
              :
                assign
                  tt-rep.exp-l = tt-rep.exp-l + ub.doc-pl.fact-qnty
                  tt-rep.exp-kg = tt-rep.exp-kg + ub.doc-pl.cli-fact-qnty
                .
              end.
            end.
            for first previous-rvs-doc no-lock
                  where previous-rvs-doc.obj-type = parobj-type
                  and previous-rvs-doc.obj-code   = parobj-code
                  and previous-rvs-doc.shift-date = var-prev-shift-date
                  and previous-rvs-doc.shift-num  = var-prev-shift-num
                  and previous-rvs-doc.status_    = 'факт':U
                  and previous-rvs-doc.rvs-type   = 'смена':U,
                  each buf_rvs-line where buf_rvs-line.rvs-code = previous-rvs-doc.rvs-code no-lock,
                  first tt-rep where tt-rep.shift-date   = ub.shift-obj.shift-date
                              and tt-rep.shift-num    = ub.shift-obj.shift-num
                              and tt-rep.gds-code    = buf_rvs-line.gds-code
                              and tt-rep.pl-code     = buf_rvs-line.pl-code
                  :
                  assign
                     tt-rep.rest_start_book-kg       = buf_rvs-line.system-cli-qnty
                     tt-rep.rest_start_book-l       = buf_rvs-line.system-qnty
                     .
             end.
             for each buf_icnt-doc no-lock
              where buf_icnt-doc.obj-type     = parobj-type
                and buf_icnt-doc.obj-code     = parobj-code
                and buf_icnt-doc.doc-type     = 'сч-трк-погр':U
                and buf_icnt-doc.ext-doc-type = 'em':U
                and buf_icnt-doc.status_      = 'факт':U
                and buf_icnt-doc.shift-num = ub.shift-obj.shift-num
                and buf_icnt-doc.shift-date = ub.shift-obj.shift-date
            on error undo, return error return-value
            :
              for each buf_icnt-line no-lock
                where buf_icnt-line.doc-code = buf_icnt-doc.doc-code
                  and buf_icnt-line.obj-code = buf_icnt-doc.obj-code
                  and buf_icnt-line.obj-type = buf_icnt-doc.obj-type:
                  find first ub.pl-gds-pump where ub.pl-gds-pump.obj-code = buf_icnt-line.obj-code
                                            and ub.pl-gds-pump.obj-type = buf_icnt-line.obj-type
                                            and ub.pl-gds-pump.pump-code = buf_icnt-line.pump-code
                                            and ub.pl-gds-pump.status_ <> 'блок':U
                                            and ub.pl-gds-pump.gds-code = buf_icnt-line.gds-code no-error .
                    if not AVAILABLE ub.pl-gds-pump then do:
                       find first ub.pl-gds-pump where ub.pl-gds-pump.obj-code = buf_icnt-line.obj-code
                                            and ub.pl-gds-pump.obj-type = buf_icnt-line.obj-type
                                            and ub.pl-gds-pump.pump-code = buf_icnt-line.pump-code
                                            and ub.pl-gds-pump.gds-code = buf_icnt-line.gds-code no-error .
                    end.
               find first tt-rep where tt-rep.shift-date   = ub.shift-obj.shift-date
                              and tt-rep.shift-num    = ub.shift-obj.shift-num
                              and tt-rep.gds-code    = buf_icnt-line.gds-code
                              and tt-rep.pl-code     = ub.pl-gds-pump.pl-code
              no-error .
                if AVAILABLE tt-rep then do:
                 assign
                     tt-rep.state-el-cnt       = buf_icnt-line.state-el-cnt
                     tt-rep.state-mh-cnt       = buf_icnt-line.state-mh-cnt
                     tt-rep.err-l = tt-rep.err-l + (tt-rep.state-el-cnt - tt-rep.state-mh-cnt)
                     tt-rep.err-kg = tt-rep.err-l * tt-rep.density
                     .
                 end.
              end.
            end.
            var-prev-shift-num = ub.shift-obj.shift-num.
            var-prev-shift-date = ub.shift-obj.shift-date.
    end.
    run get-report-num in parParentProc (
    output var-report-num
        ).
        v-file-name-rep-htm = session:temp-directory + "rpt" + string(var-report-num) + ".html".
            output to value(v-file-name-rep-htm).
            output close.
        if search("exe\ReportViewer\reportviewer.exe") <> ? then
            do:
                v-fill-path-RepView = search("exe\ReportViewer\reportviewer.exe").
            end.
        else
            do:
                message "Не найдена программа просмотра отчёта!" view-as alert-box error.
            end.
 def var v-first-time as int no-undo.
 def var v-first-date as date no-undo.
 def var v-last-date as date no-undo.
 def var v-last-time as int no-undo.
      for first tt-rep by tt-rep.shift-date by tt-rep.shift-num :
          v-first-date = tt-rep.shift-date.
          v-first-time = tt-rep.time-start.
      end.
     for last tt-rep by tt-rep.shift-date by tt-rep.shift-num :
          v-last-date = tt-rep.date-end.
          v-last-time = tt-rep.time-end.
      end.
      output stream OutStr-html to value(v-file-name-rep-htm) convert target 'UTF-8' .
      put stream OutStr-html unformatted
        substitute ('
        <!DOCTYPE HTML>
              <html>
                <head>
                <meta charset="UTF-8">
                    <!-- Стили документа -->
                <style>
                     table ~{
                         border-collapse: collapse; 
                     ~}
                     tbody td, th ~{
                         border: 1px solid black;
                         border-collapse: collapse;
                   height: 14px;
                     ~}
            
                </style>
                </head>
                  <body>
                    <table orientation="landscape" name="Контр.накопит. ведомость" fit_to_page="true">  <!-- таблица, в которой содержится весь отчет -->
                      <thead>  <!-- Шапка отчета -->
                      <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                        <tr class="set_columns">
                          <td style="width:50px"></td>
                          <td style="width:85px"></td>
                          <td style="width:85px"></td>
                          <td style="width:50px"></td>
                          <td style="width:50px"></td>
                          <td style="width:50px"></td>
                          <td style="width:50px"></td>
                          <td style="width:50px"></td>
                          <td style="width:50px"></td>
                          <td style="width:50px"></td>
                          <td style="width:50px"></td>
                          <td style="width:50px"></td>
                          <td style="width:50px"></td>
                          <td style="width:50px"></td>
                          <td style="width:50px"></td>
                          <td style="width:50px"></td>
                          <td style="width:50px"></td>
                          <td style="width:50px"></td>
                          <td style="width:60px"></td>
                          <td style="width:136px"></td>
                        </tr>
                      <tr>
                        <td colspan="20"></td>
                      </tr>
                      <tr style="height:30px;">  
                        <td colspan="5" style="border-bottom: 1px solid black; text-align: center;">&1</td>
                        <td colspan="15"></td>
                      </tr>
                      <tr>
                        <td colspan="5" style="font-size:10px; text-align: center;">наименование организации</td>
                        <td colspan="15"></td>
                      </tr>
                      <tr>
                        <td colspan="20" style="font-size:16px;font-weight:bold; text-align: center;">Контрольно-накопительная ведомость учета излишек и недостач нефтепродуктов по  &2</td>
                      </tr>
                      <tr>
                        <td colspan="20" style="text-align:center;"> за период с &3 по &4</td>
                      </tr>
                      <tr>
                        <td colspan="20"></td>
                      </tr>          
                    </thead>
            
                
              <tbody> <!-- Здесь начинается таблица отчета -->
                    <tr> <!-- Первые строки – шапка таблицы с тэгами tr -->
                    <th rowspan="3" style="text-align: center;">Номер сменного отчета</th>
                    <th rowspan="2" colspan="2" style="text-align: center;">Дата, время (дд.мм.гг чч:мм)</th>
                    <th rowspan="3" style="text-align: center;">Номер резервуара</th>
                    <th rowspan="2" colspan="2" style="text-align: center;">Расчетный остаток на начало смены</th>
                    <th rowspan="2" colspan="2" style="text-align: center;">Поступило за смену</th>
                    <th rowspan="2" colspan="2" style="text-align: center;">Расход за смену</th>
                    <th rowspan="2" colspan="2" style="text-align: center;">Фактический остаток на конец смены</th>
                    <th rowspan="2" colspan="2" style="text-align: center;">Расчетный остаток на конец смены</th>
                    <th rowspan="2" colspan="2" style="text-align: center;">Результат ("+" - излишки, "-" - недостача)</th>
                    <th rowspan="2" colspan="2" style="text-align: center;">Погрешность ТРК по резервуару за смену</th>
                    <th rowspan="3" style="text-align: center;">Подпись</th>
                    <th rowspan="3" style="text-align: center;">Инициалы, Фамилия</th>
                </tr>
                <tr>
                </tr>
                <tr>
                    <th style="text-align: center;">начала смены</th>
                    <th style="text-align: center;">окончания смены</th>
                    <th style="text-align: center;">л</th>
                    <th style="text-align: center;">кг</th>
                    <th style="text-align: center;">л</th>
                    <th style="text-align: center;">кг</th>
                    <th style="text-align: center;">л</th>
                    <th style="text-align: center;">кг</th>
                    <th style="text-align: center;">л</th>
                    <th style="text-align: center;">кг</th>
                    <th style="text-align: center;">л</th>
                    <th style="text-align: center;">кг</th>
                    <th style="text-align: center;">л</th>
                    <th style="text-align: center;">кг</th>
                    <th style="text-align: center;">л</th>
                    <th style="text-align: center;">кг</th>
                </tr>
                <tr>
                    <th style="text-align: center;">1</th>
                    <th style="text-align: center;">2</th>
                    <th style="text-align: center;">3</th>
                    <th style="text-align: center;">4</th>
                    <th style="text-align: center;">5</th>
                    <th style="text-align: center;">6</th>
                    <th style="text-align: center;">7</th>
                    <th style="text-align: center;">8</th>
                    <th style="text-align: center;">9</th>
                    <th style="text-align: center;">10</th>
                    <th style="text-align: center;">11</th>
                    <th style="text-align: center;">12</th>
                    <th style="text-align: center;">13</th>
                    <th style="text-align: center;">14</th>
                    <th style="text-align: center;">15</th>
                    <th style="text-align: center;">16</th>
                    <th style="text-align: center;">17</th>
                    <th style="text-align: center;">18</th>
                    <th style="text-align: center;">19</th>
                    <th style="text-align: center;">20</th>
                </tr>'
                ,
                string(v-host-name),
                string(v-obj-name),
                string(v-first-date, "99.99.9999") + ' ' + string(v-first-time,"HH:MM") ,
                string(v-last-date, "99.99.9999") + ' ' + string(v-last-time,"HH:MM")
        ).
        for each tt-rep break by tt-rep.gds-code by tt-rep.pl-code on error undo, return error return-value:
            if first-of(tt-rep.gds-code) then do:
                ASSIGN
                var-gds-rest_start_measure-kg  = 0
                var-gds-rest_start_book-kg     = 0
                var-gds-rest_start_measure-l   = 0
                var-gds-rest_start_book-l      = 0
                var-gds-wayb_fact-kg           = 0
                var-gds-wayb_fact-l            = 0
                var-gds-exp-kg                 = 0
                var-gds-exp-l                  = 0
                var-gds-rest_end_measure-kg   = 0
                var-gds-rest_end_book-kg      = 0
                var-gds-rest_end_measure-l    = 0
                var-gds-rest_end_book-l       = 0
                var-gds-rest_end_balans-kg    = 0
                var-gds-rest_end_balans-l     = 0
                .
              put stream OutStr-html unformatted
                substitute ('
                        <tr> <!-- Затем идёт наполнение таблицы -->
                            <th colspan="3" style="text-align:right;">Вид, марка нефтепродукта:</th>
                            <th colspan="17" style="text-align:left;">&1</th>
                        </tr>'
                ,
                tt-rep.goods-name
                ).
       end.
            if first-of(tt-rep.pl-code) then do:
                ASSIGN
                var-pl-rest_start_book-kg  = tt-rep.rest_start_book-kg
                var-pl-rest_start_book-l      = tt-rep.rest_start_book-l
                var-pl-wayb_fact-kg           = 0
                var-pl-wayb_fact-l            = 0
                var-pl-exp-kg                 = 0
                var-pl-exp-l                  = 0
                .
                put stream OutStr-html unformatted
                substitute ('
                        <tr>
                            <th colspan="3" style="text-align:right;">Резервуар:</th>
                            <th colspan="17" style="text-align:left;">&1</th>
                        </tr>'
                ,
                tt-rep.place_loc1
                ).
            end.
            assign
            var-pl-wayb_fact-kg = var-pl-wayb_fact-kg + tt-rep.wayb_fact-kg
            var-pl-wayb_fact-l = var-pl-wayb_fact-l + tt-rep.wayb_fact-l
            var-pl-exp-kg = var-pl-exp-kg + tt-rep.exp-kg
            var-pl-exp-l = var-pl-exp-l + tt-rep.exp-l
            .
                put stream OutStr-html unformatted
                substitute ('
                        <tr> 
                        <td style="text-align:center;"></td>
                        <td style="text-align:center;">&1</td>
                        <td style="text-align:center;">&2</td>
                        <td style="text-align:center;">&3</td>
                        <td style="text-align:right;">&4</td>
                        <td style="text-align:right;">&5</td>
                        <td style="text-align:right;">&6</td>
                        <td style="text-align:right;">&7</td>'
                ,
                string(tt-rep.shift-date, "99.99.9999") + ' ' + string (tt-rep.time-start,"hh:mm"),
                string(tt-rep.date-end, "99.99.9999") + ' ' + string (tt-rep.time-end,"hh:mm"),
                tt-rep.place_loc1,
                string(tt-rep.rest_start_book-l,"->>>>>>>>>>>9.99"),
                string(tt-rep.rest_start_book-kg,"->>>>>>>>>>>9.99"),
                string(tt-rep.wayb_fact-l,"->>>>>>>>>>>9.99"),
                string(tt-rep.wayb_fact-kg,"->>>>>>>>>>>9.99")
                ).
                put stream OutStr-html unformatted
                substitute ('
                        <td style="text-align:right;">&1</td>
                        <td style="text-align:right;">&2</td>
                        <td style="text-align:right;">&3</td>
                        <td style="text-align:right;">&4</td>
                        <td style="text-align:right;">&5</td>
                        <td style="text-align:right;">&6</td>
                        <td style="text-align:right;">&7</td>
                        <td style="text-align:right;">&8</td>
                        <td style="text-align:right;">&9</td>
                '
                ,
                string(tt-rep.exp-l,"->>>>>>>>>>>9.99"),
                string(tt-rep.exp-kg,"->>>>>>>>>>>9.99"),
                if tt-rep.rest_end_measure-l <> ? then string(tt-rep.rest_end_measure-l,"->>>>>>>>>>>9.99") else '',
                if tt-rep.rest_end_measure-kg <> ? then string(tt-rep.rest_end_measure-kg,"->>>>>>>>>>>9.99") else '',
                string(tt-rep.rest_end_book-l,"->>>>>>>>>>>9.99"),
                string(tt-rep.rest_end_book-kg,"->>>>>>>>>>>9.99"),
                if tt-rep.rest_end_balans-l <> ? then string(tt-rep.rest_end_balans-l,"->>>>>>>>>>>9.99") else '',
                if tt-rep.rest_end_balans-kg <> ? then string(tt-rep.rest_end_balans-kg,"->>>>>>>>>>>9.99") else '',
                string(tt-rep.err-l,"->>>>>>>>>>>9.99")
                ).
               put stream OutStr-html unformatted
                substitute ('
                        <td style="text-align:right;">&1</td>
                        <td style="text-align:center;"></td>
                        <td style="text-align:left;">&2</td>
                        </tr>
                        '
                ,
                string(tt-rep.err-kg,"->>>>>>>>>>>9.99"),
                tt-rep.staff
                ).
            if last-of(tt-rep.pl-code) then do:
               ASSIGN
                var-gds-rest_start_book-kg     = var-gds-rest_start_book-kg + var-pl-rest_start_book-kg
                var-gds-rest_start_book-l      = var-gds-rest_start_book-l + var-pl-rest_start_book-l
                var-gds-wayb_fact-kg           = var-gds-wayb_fact-kg + var-pl-wayb_fact-kg
                var-gds-wayb_fact-l           = var-gds-wayb_fact-l + var-pl-wayb_fact-l
                var-gds-exp-kg           = var-gds-exp-kg + var-pl-exp-kg
                var-gds-exp-l           = var-gds-exp-l + var-pl-exp-l
                var-gds-rest_end_measure-kg   = var-gds-rest_end_measure-kg + tt-rep.rest_end_measure-kg
                var-gds-rest_end_book-kg      =  var-gds-rest_end_book-kg + tt-rep.rest_end_book-kg
                var-gds-rest_end_measure-l    =  var-gds-rest_end_measure-l + tt-rep.rest_end_measure-l
                var-gds-rest_end_book-l       = var-gds-rest_end_book-l + tt-rep.rest_end_book-l
                var-gds-rest_end_balans-kg    = var-gds-rest_end_balans-kg + tt-rep.rest_end_balans-kg
                var-gds-rest_end_balans-l     = var-gds-rest_end_balans-l + tt-rep.rest_end_balans-l
                .
      put stream OutStr-html unformatted
        substitute ('
                <tr> 
                <th colspan="3" style="text-align:center">Итого по резервуару номер:</th>
                <th style="text-align:center;">&1</th>
                <th style="text-align:right;">&2</th>
                <th style="text-align:right;">&3</th>
                <th style="text-align:right;">&4</th>
                <th style="text-align:right;">&5</th>
                <th style="text-align:right;">&6</th>
                <th style="text-align:right;">&7</th>
               '
        ,
        tt-rep.place_loc1,
        string(var-pl-rest_start_book-l,"->>>>>>>>>>>9.99"),
        string(var-pl-rest_start_book-kg,"->>>>>>>>>>>9.99"),
        string(var-pl-wayb_fact-l,"->>>>>>>>>>>9.99"),
        string(var-pl-wayb_fact-kg,"->>>>>>>>>>>9.99"),
        string(var-pl-exp-l,"->>>>>>>>>>>9.99"),
        string(var-pl-exp-kg,"->>>>>>>>>>>9.99")
        ).
                put stream OutStr-html unformatted
                substitute ('
                        <th style="text-align:right;">&1</th>
                        <th style="text-align:right;">&2</th>
                        <th style="text-align:right;">&3</th>
                        <th style="text-align:right;">&4</th>
                        <th style="text-align:right;">&5</th>
                        <th style="text-align:right;">&6</th>
                        <th style="text-align:right;">&7</th>
                        <th style="text-align:right;">&8</th>
                        <th colspan="2" style="text-align:center;"></th>
                        </tr>
                        '
                ,
                if tt-rep.rest_end_measure-l <> ? then string(tt-rep.rest_end_measure-l,"->>>>>>>>>>>9.99") else '',
                if tt-rep.rest_end_measure-kg <> ? then string(tt-rep.rest_end_measure-kg,"->>>>>>>>>>>9.99") else '',
                string(tt-rep.rest_end_book-l,"->>>>>>>>>>>9.99"),
                string(tt-rep.rest_end_book-kg,"->>>>>>>>>>>9.99"),
                if tt-rep.rest_end_balans-l <> ? then string(tt-rep.rest_end_balans-l,"->>>>>>>>>>>9.99") else '',
                if tt-rep.rest_end_balans-kg <> ? then string(tt-rep.rest_end_balans-kg,"->>>>>>>>>>>9.99") else '',
                string(tt-rep.err-l,"->>>>>>>>>>>9.99"),
                string(tt-rep.err-kg,"->>>>>>>>>>>9.99")
                ).
            end.
            if LAST-of(tt-rep.gds-code) then do:
      put stream OutStr-html unformatted
        substitute ('
                <tr> 
                <th colspan="3" style="text-align:center;">Итого по виду, марке нефтепродукта:</th>
                <th style="text-align:center;">&1</th>
                <th style="text-align:right;">&2</th>
                <th style="text-align:right;">&3</th>
                <th style="text-align:right;">&4</th>
                <th style="text-align:right;">&5</th>
                <th style="text-align:right;">&6</th>
                <th style="text-align:right;">&7</th>
                <th style="text-align:right;">&8</th>
                <th style="text-align:right;">&9</th>
                '
        ,
        '',
        string(var-gds-rest_start_book-l,"->>>>>>>>>>>9.99"),
        string(var-gds-rest_start_book-kg,"->>>>>>>>>>>9.99"),
        string(var-gds-wayb_fact-l,"->>>>>>>>>>>9.99"),
        string(var-gds-wayb_fact-kg,"->>>>>>>>>>>9.99"),
        string(var-gds-exp-l,"->>>>>>>>>>>9.99"),
        string(var-gds-exp-kg,"->>>>>>>>>>>9.99"),
        if var-gds-rest_end_measure-l <> ? then string(var-gds-rest_end_measure-l,"->>>>>>>>>>>9.99") else '',
        if var-gds-rest_end_measure-kg <> ? then string(var-gds-rest_end_measure-kg,"->>>>>>>>>>>9.99") else ''
        ).
      put stream OutStr-html unformatted
        substitute ('
                <th style="text-align:right;">&1</th>
                <th style="text-align:right;">&2</th>
                <th style="text-align:right;">&3</th>
                <th style="text-align:right;">&4</th>
                <th style="text-align:right;">&5</th>
                <th style="text-align:right;">&6</th>
                <th colspan="2" style="text-align:center;"></th>
                </tr>
          '
        ,
        string(var-gds-rest_end_book-l,"->>>>>>>>>>>9.99"),
        string(var-gds-rest_end_book-kg,"->>>>>>>>>>>9.99"),
        if var-gds-rest_end_balans-l <> ? then string(var-gds-rest_end_balans-l,"->>>>>>>>>>>9.99") else '',
        if var-gds-rest_end_balans-kg <> ? then string(var-gds-rest_end_balans-kg,"->>>>>>>>>>>9.99") else '',
        string(tt-rep.err-l,"->>>>>>>>>>>9.99"),
        string(tt-rep.err-kg,"->>>>>>>>>>>9.99")
        ).
            end.
        end.
   put stream OutStr-html unformatted
        substitute ('
            
             
            </table>
            </body>
            </html>
            '
            ).
  output stream OutStr-html close.
  run prn-lib-reportviewer-report-name in this-procedure (
                                                          input parParentProc
                                                          ,input v-file-name-rep-htm
                                                          ).
