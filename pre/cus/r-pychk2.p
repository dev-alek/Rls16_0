block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-group as logical no-undo .
define input parameter p-rv    as logical no-undo .
define variable vss-revision    as character no-undo init "$Revision: cc275b2610da, 3580, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: 2023/12/14 13:36:13 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-pychk2.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/r-pychk2.p $":U .
define variable vss-description as character no-undo init "Суммы продаж с разбивкой по типам кассовых платежей и НДС - печать".
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
define new shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define new shared variable RepPathName        as character no-undo .
define new shared variable PrintRubl          as logical   no-undo .
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
define variable var-report-r-b as character no-undo .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output var-report-r-b
  )  .
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
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE NEW SHARED TEMP-TABLE treal-3 no-undo
FIELD gds-code like ub.goods.gds-code
FIELD cpay-code as integer
FIELD curr-code as integer
FIELD qnty1 as decimal
FIELD netto as decimal
FIELD out-name as character format "X(20)"
FIELD is-pay as logical
FIELD ii as integer
FIELD netto-rubl as decimal
FIELD rv    as integer
FIELD VAT-pc like ub.doc-line.vat-pc
FIELD netto-inkas as decimal
FIELD netto-rubl-inkas as decimal
FIELD inkas-code like ub.chk-doc.out-code
INDEX pi IS UNIQUE PRIMARY
        gds-code
        cpay-code
        curr-code
        rv
        is-pay DESCENDING
INDEX vi
IS UNIQUE
      gds-code
      ii
INDEX ivat vat-pc
.
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
define SHARED temp-table treal-vat no-undo
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
define SHARED temp-table tt-cash-group no-undo
FIELD obj-name like ub.cash-pay.obj-name
FIELD grp-code as character
index pi is UNIQUE primary
grp-code
.
define SHARED temp-table tt-cash-pay no-undo
FIELD cdpay-code like ub.cash-pay.cdpay-code
FIELD curr-code like ub.cash-pay.curr-code
FIELD grp-code as character
FIELD obj-name like ub.cash-pay.obj-name
index pi is unique primary
cdpay-code curr-code
index igrp grp-code
.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE SHARED VARIABLE cas-shft as logical no-undo init no.
DEFINE VARIABLE cas-num as integer no-undo.
DEFINE VARIABLE found as logical init yes no-undo.
define variable ii-excel as integer no-undo .
define variable ii-page as integer no-undo init 1.
define variable v-curr-code like ub.currency.curr-code no-undo init ?.
define variable v-one-curr-code as logical no-undo .
define variable inkas-uslugi1 as character no-undo .
define variable inkas-uslugi2 as character no-undo .
define buffer buf_inkas for ub.inkas.
define buffer buf_cash-pay for ub.cash-pay.
define buffer buf1_sheetf for sheetf.
define buffer buf_sheetf for sheetf.
define buffer buf_goods for ub.goods.
define buffer buf_clients for ub.clients.
define buffer buf_doc-line for ub.doc-line.
run waitfram-show in this-procedure ("Ждите...").
for each treal-3:
  delete treal-3.
end.
for each treal-vat:
  delete treal-vat.
end.
_realize-filter--Date-and-Shift:
FOR EACH obj-list No-LOCK:
    if x-tog-shift = no then do:
   for each  buf_Inkas no-lock where
            buf_inkas.fact-date     >= x-date-start
        AND buf_inkas.fact-date     <= x-date-end
        AND buf_inkas.obj-type   = obj-list.obj-type
        AND buf_inkas.obj-code   = obj-list.obj-code
        AND buf_inkas.status_     = 'факт':U:
            run process-inkas in this-procedure (buffer buf_inkas).
        end.
    end.
    else do:
        for each buf_Inkas no-lock where
                buf_inkas.shift-date   >= x-date-start
            AND buf_inkas.shift-date   <= x-date-end
            AND buf_inkas.obj-type      = obj-list.obj-type
            AND buf_inkas.obj-code      = obj-list.obj-code
            AND buf_inkas.status_       = 'факт':U:
                if buf_inkas.shift-date = x-date-start and buf_inkas.shift-num < x-shift-start then next.
                if buf_inkas.shift-date = x-date-end and buf_inkas.shift-num > x-shift-end then next.
                run process-inkas in this-procedure (buffer buf_inkas).
        end.
    end.
END.
run waitfram-hide in this-procedure .
run printproc in this-procedure.
procedure process-inkas :
define parameter buffer buf_inkas for ub.inkas.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable pychk_rv as integer no-undo .
DEFINE BUFFER b-treal-3 for treal-3.
DEFINE VARIABLE v-line-num as integer no-undo .
define variable v-curr-r-b as character no-undo .
define variable v-base-code like ub.sysconf.base-code no-undo .
define variable p-by-pay-desk as logical no-undo .
define buffer buf_bar-code for ub.bar-code.
define buffer buf_cash-pay for ub.cash-pay.
define buffer buf_trn-doc for ub.trn-doc.
define buffer buf_ret-doc for ub.trn-doc.
define buffer buf_goods   for ub.goods.
define buffer pay_treal-vat for treal-vat.
define buffer pay0_treal-vat for treal-vat.
define buffer gen_treal-vat for treal-vat.
define buffer gen0_treal-vat for treal-vat.
define buffer buf_doc-line for ub.doc-line.
define variable v-ret-doc-code like ub.trn-doc.doc-code no-undo .
define variable v-grp-code as character no-undo .
define buffer buf_tt-cash-pay  for tt-cash-pay.
define buffer buf_tt-cash-group for tt-cash-group.
define buffer buf_chk-gds-pay for ub.chk-gds-pay.
do
on error undo, return error
:
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  buf_inkas.host-code
  ,output v-base-code
  )  .
  assign
  v-curr-code = (if v-curr-code = ? then v-base-code else v-curr-code)
  v-one-curr-code = (if v-base-code = v-curr-code then yes else no)
  .
  find first buf_trn-doc no-lock where
            buf_trn-doc.doc-code = buf_inkas.inkas-code no-error.
  find first buf_ret-doc no-lock where
            buf_ret-doc.doc-code = buf_trn-doc.out-code no-error .
  if available buf_ret-doc then
  assign
  v-ret-doc-code = buf_ret-doc.doc-code
  .
  run rep/rpychk0.p ( input "r-pychk2"
                      ,input buf_inkas.obj-type
                      ,input buf_inkas.obj-code
                      ,input ?
                      ,input ?
                      ,input ?
                      ,input ?
                      ,input ?
                      ,input ?
                      ,input buf_inkas.inkas-code
                      ).
  _chk-doc:
  FOR EACH ub.chk-doc No-LOCK WHERE
          ub.chk-doc.obj-type = buf_inkas.obj-type AND
          ub.chk-doc.obj-code = buf_inkas.obj-code AND
          ub.chk-doc.out-code = buf_inkas.inkas-code:
    if lookup(string(ub.chk-doc.chk-type), '14,15,16,36,17,8,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) > 0 then next _chk-doc.
    pychk_rv = (if p-rv
            then (if ub.chk-doc.netto >= 0 then 1 else - 1)
            else 0).
    for each buf_chk-gds-pay no-lock where
            buf_chk-gds-pay.doc-code = ub.chk-doc.doc-code
        and buf_chk-gds-pay.algo-num = "1.8",
        first buf_bar-code no-lock where
            buf_bar-code.b-code = buf_chk-gds-pay.b-code,
        first buf_cash-pay no-lock where
            buf_cash-pay.cdpay-code = buf_chk-gds-pay.pay-code
        and buf_cash-pay.curr-code = buf_chk-gds-pay.curr-code:
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if x-SelectGood  = 4 then do:
  find first gds-list no-lock where
          gds-list.gds-code = buf_bar-code.gds-code no-error .
end.
if x-SelectGood  = 1
or available gds-list then do:
    FIND FIRST treal-3 No-LOCK WHERE
              treal-3.gds-code = buf_bar-code.gds-code
          AND treal-3.cpay-code = buf_chk-gds-pay.pay-code
          AND treal-3.curr-code = buf_chk-gds-pay.curr-code
          AND treal-3.rv = pychk_rv  No-ERROR.
    IF NOT AVAIL treal-3 then do:
      FIND last b-treal-3 No-LOCK WHERE
                b-treal-3.gds-code = buf_bar-code.gds-code use-index vi No-ERROR.
      create treal-3.
      assign
      treal-3.gds-code = buf_bar-code.gds-code
      treal-3.rv = pychk_rv
      treal-3.cpay-code = buf_chk-gds-pay.pay-code
      treal-3.curr-code = buf_chk-gds-pay.curr-code
      treal-3.qnty1  =  0
      treal-3.netto = 0
      treal-3.out-name = buf_cash-pay.obj-name
      treal-3.is-pay = yes
      treal-3.ii =  (if avail b-treal-3
                    then b-treal-3.ii + 1
                    else 1)
      .
    END.
    assign
    treal-3.netto = treal-3.netto + (if v-curr-r-b = 'base':U
                                      or v-base-code = 0
                                      then buf_chk-gds-pay.tot-r-b
                                      else (buf_chk-gds-pay.tot-r-b / buf_chk-gds-pay.eff-base-rate))
    treal-3.qnty1 = treal-3.qnty1 + buf_chk-gds-pay.eff-doc-qnty
    treal-3.netto-rubl = treal-3.netto-rubl + (if v-curr-r-b = 'rubl':U
                                              or v-base-code = 0
                                              then buf_chk-gds-pay.tot-r-b
                                              else (buf_chk-gds-pay.tot-r-b * buf_chk-gds-pay.eff-base-rate))
    treal-3.netto-inkas = (if treal-3.inkas-code <> buf_inkas.inkas-code
                          then 0
                          else treal-3.netto-inkas)
    treal-3.netto-rubl-inkas = (if treal-3.inkas-code <> buf_inkas.inkas-code
                                then 0
                                else treal-3.netto-rubl-inkas)
    treal-3.vat-pc      = if treal-3.inkas-code <> buf_inkas.inkas-code
                          then -1
                          else treal-3.vat-pc
    treal-3.inkas-code        = if treal-3.inkas-code <> buf_inkas.inkas-code
                                then buf_inkas.inkas-code
                                else treal-3.inkas-code
    treal-3.netto-inkas = treal-3.netto-inkas + (if v-curr-r-b = 'base':U
                                                  or v-base-code = 0
                                                  then buf_chk-gds-pay.tot-r-b
                                                  else (buf_chk-gds-pay.tot-r-b / buf_chk-gds-pay.eff-base-rate))
    treal-3.netto-rubl-inkas = treal-3.netto-rubl-inkas + (if v-curr-r-b = 'rubl':U
                                                            or v-base-code = 0
                                                            then buf_chk-gds-pay.tot-r-b
                                                            else (buf_chk-gds-pay.tot-r-b * buf_chk-gds-pay.eff-base-rate))
    .
end.
    end.
  END.
  inkas-uslugi1 = entry(1,buf_inkas.inkas-code,"-") + "у-" + entry(2,buf_inkas.inkas-code,"-") .
  inkas-uslugi2 = entry(1,buf_inkas.inkas-code,"-") + "у=" + entry(2,buf_inkas.inkas-code,"-") .
  _doc-line:
  FOR EACH treal-3 where
          treal-3.vat-pc = - 1,
      FIRST buf_goods no-lock where
            buf_goods.gds-code = treal-3.gds-code:
    if not p-rv or treal-3.rv = 1 then do:
      FIND FIRST buf_doc-line no-lock WHERE
                buf_doc-line.doc-code = buf_inkas.inkas-code AND
                buf_doc-line.artic     = buf_goods.artic AND
                buf_doc-line.prod-type = buf_goods.prod-type AND
                buf_doc-line.prod-code = buf_goods.prod-code  no-error .
      if available buf_doc-line then do:
        assign
        treal-3.vat-pc = buf_doc-line.vat-pc.
        if p-group then do:                                      find first buf_tt-cash-pay no-lock where                                               buf_tt-cash-pay.cdpay-code = treal-3.cpay-code                           AND buf_tt-cash-pay.curr-code = treal-3.curr-code no-error.            if buf_tt-cash-pay.grp-code = chr(4) + "0":U then do:                  assign                                                                       v-grp-code = string(treal-3.cpay-code) + chr(4) +                                 string(treal-3.curr-code)                                       .                                                                          end.                                                                         else do:                                                                       assign                                                                       v-grp-code = buf_tt-cash-pay.grp-code                                        .                                                                          end.                                                                       end.                                                                         else do:                                                                       assign                                                                       v-grp-code = string(treal-3.cpay-code) + chr(4) +                                 string(treal-3.curr-code)                                       .                                                                          end.                                                                                              find first treal-vat where                                      treal-vat.inkas-code = buf_Inkas.inkas-code                              AND treal-vat.vat-pc = treal-3.vat-pc                                        AND treal-vat.grp-code = v-grp-code                                          AND treal-vat.rv   = treal-3.rv  no-error .                                                   find first pay_treal-vat where                                  pay_treal-vat.inkas-code = "":U                                          AND pay_treal-vat.vat-pc = treal-3.vat-pc                                    AND pay_treal-vat.grp-code = v-grp-code                                      AND pay_treal-vat.rv = treal-3.rv                no-error .                  if p-rv then do:                                                                              find first pay0_treal-vat where                                 pay0_treal-vat.inkas-code = "":U                                         AND pay0_treal-vat.vat-pc = treal-3.vat-pc                                   AND pay0_treal-vat.grp-code = v-grp-code                                     AND pay0_treal-vat.rv = 0                         no-error .                 end.                                                                                          find first gen_treal-vat where                                  gen_treal-vat.inkas-code = "":U                                          AND gen_treal-vat.vat-pc = treal-3.vat-pc                                    AND gen_treal-vat.grp-code  = "":U                                           AND gen_treal-vat.rv = treal-3.rv  no-error .                                if p-rv then do:                                                                              find first gen0_treal-vat where                                 gen0_treal-vat.inkas-code = "":U                                         AND gen0_treal-vat.vat-pc = treal-3.vat-pc                                   AND gen0_treal-vat.grp-code  = "":U                                          AND gen0_treal-vat.rv = 0  no-error .                                        end .                                                                  if not available treal-vat then do:                                            create treal-vat.                                                            assign                                                                       treal-vat.inkas-code = buf_inkas.inkas-code                                  treal-vat.doc-date   = buf_inkas.fact-date                                   treal-vat.fact-order = buf_trn-doc.fact-order                                treal-vat.grp-code   = v-grp-code                                            treal-vat.vat-pc     = treal-3.vat-pc                                        treal-vat.rv         = treal-3.rv                                            .                                                                          end.                                                                         if not available pay_treal-vat then do:                                        create pay_treal-vat.                                                        assign                                                                       pay_treal-vat.inkas-code = "":U                                              pay_treal-vat.fact-order = 0                                                 pay_treal-vat.grp-code = v-grp-code                                          pay_treal-vat.vat-pc     = treal-3.vat-pc                                    pay_treal-vat.rv         = treal-3.rv                                        .                                                                          end.                                                                         if P-RV AND not available pay0_treal-vat then do:                              create pay0_treal-vat.                                                       assign                                                                       pay0_treal-vat.inkas-code = "":U                                             pay0_treal-vat.fact-order = 0                                                pay0_treal-vat.grp-code = v-grp-code                                         pay0_treal-vat.vat-pc     = treal-3.vat-pc                                   pay0_treal-vat.rv         = 0                                                .                                                                          end.                                                                         if not available gen_treal-vat then do:                                        create gen_treal-vat.                                                        assign                                                                       gen_treal-vat.inkas-code = "":U                                              gen_treal-vat.grp-code   = "":U                                              gen_treal-vat.vat-pc     = treal-3.vat-pc                                    gen_treal-vat.rv         = treal-3.rv                                        .                                                                          end.                                                                         if P-RV AND not available gen0_treal-vat then do:                              create gen0_treal-vat.                                                       assign                                                                       gen0_treal-vat.inkas-code = "":U                                             gen0_treal-vat.grp-code   = "":U                                             gen0_treal-vat.vat-pc     = treal-3.vat-pc                                   gen0_treal-vat.rv         = 0                                                .                                                                          end.
        assign                                                                       treal-vat.netto = treal-vat.netto + treal-3.netto-inkas                      treal-vat.netto-rubl = treal-vat.netto-rubl + treal-3.netto-rubl-inkas       pay_treal-vat.netto = pay_treal-vat.netto + treal-3.netto-inkas              pay_treal-vat.netto-rubl = pay_treal-vat.netto-rubl + treal-3.netto-rubl-inkas gen_treal-vat.netto = gen_treal-vat.netto + treal-3.netto-inkas              gen_treal-vat.netto-rubl = gen_treal-vat.netto-rubl + treal-3.netto-rubl-inkas .                                                                              if p-rv then do:                                                                 assign                                                                         pay0_treal-vat.netto = pay0_treal-vat.netto + treal-3.netto-inkas                pay0_treal-vat.netto-rubl = pay0_treal-vat.netto-rubl + treal-3.netto-rubl-inkas   gen0_treal-vat.netto = gen0_treal-vat.netto + treal-3.netto-inkas                gen0_treal-vat.netto-rubl = gen0_treal-vat.netto-rubl + treal-3.netto-rubl-inkas   .                                                                               end.
        NEXT _doc-line.
      end.
    end.
    if (not p-rv and  not available buf_doc-line)
    or treal-3.rv = - 1 then do:
      FIND FIRST buf_doc-line no-lock WHERE
                buf_doc-line.doc-code = v-ret-doc-code AND
                buf_doc-line.artic     = buf_goods.artic AND
                buf_doc-line.prod-type = buf_goods.prod-type AND
                buf_doc-line.prod-code = buf_goods.prod-code  no-error .
      if available buf_doc-line then do:
        assign
        treal-3.vat-pc = buf_doc-line.vat-pc.
        if p-group then do:                                      find first buf_tt-cash-pay no-lock where                                               buf_tt-cash-pay.cdpay-code = treal-3.cpay-code                           AND buf_tt-cash-pay.curr-code = treal-3.curr-code no-error.            if buf_tt-cash-pay.grp-code = chr(4) + "0":U then do:                  assign                                                                       v-grp-code = string(treal-3.cpay-code) + chr(4) +                                 string(treal-3.curr-code)                                       .                                                                          end.                                                                         else do:                                                                       assign                                                                       v-grp-code = buf_tt-cash-pay.grp-code                                        .                                                                          end.                                                                       end.                                                                         else do:                                                                       assign                                                                       v-grp-code = string(treal-3.cpay-code) + chr(4) +                                 string(treal-3.curr-code)                                       .                                                                          end.                                                                                              find first treal-vat where                                      treal-vat.inkas-code = buf_Inkas.inkas-code                              AND treal-vat.vat-pc = treal-3.vat-pc                                        AND treal-vat.grp-code = v-grp-code                                          AND treal-vat.rv   = treal-3.rv  no-error .                                                   find first pay_treal-vat where                                  pay_treal-vat.inkas-code = "":U                                          AND pay_treal-vat.vat-pc = treal-3.vat-pc                                    AND pay_treal-vat.grp-code = v-grp-code                                      AND pay_treal-vat.rv = treal-3.rv                no-error .                  if p-rv then do:                                                                              find first pay0_treal-vat where                                 pay0_treal-vat.inkas-code = "":U                                         AND pay0_treal-vat.vat-pc = treal-3.vat-pc                                   AND pay0_treal-vat.grp-code = v-grp-code                                     AND pay0_treal-vat.rv = 0                         no-error .                 end.                                                                                          find first gen_treal-vat where                                  gen_treal-vat.inkas-code = "":U                                          AND gen_treal-vat.vat-pc = treal-3.vat-pc                                    AND gen_treal-vat.grp-code  = "":U                                           AND gen_treal-vat.rv = treal-3.rv  no-error .                                if p-rv then do:                                                                              find first gen0_treal-vat where                                 gen0_treal-vat.inkas-code = "":U                                         AND gen0_treal-vat.vat-pc = treal-3.vat-pc                                   AND gen0_treal-vat.grp-code  = "":U                                          AND gen0_treal-vat.rv = 0  no-error .                                        end .                                                                  if not available treal-vat then do:                                            create treal-vat.                                                            assign                                                                       treal-vat.inkas-code = buf_inkas.inkas-code                                  treal-vat.doc-date   = buf_inkas.fact-date                                   treal-vat.fact-order = buf_trn-doc.fact-order                                treal-vat.grp-code   = v-grp-code                                            treal-vat.vat-pc     = treal-3.vat-pc                                        treal-vat.rv         = treal-3.rv                                            .                                                                          end.                                                                         if not available pay_treal-vat then do:                                        create pay_treal-vat.                                                        assign                                                                       pay_treal-vat.inkas-code = "":U                                              pay_treal-vat.fact-order = 0                                                 pay_treal-vat.grp-code = v-grp-code                                          pay_treal-vat.vat-pc     = treal-3.vat-pc                                    pay_treal-vat.rv         = treal-3.rv                                        .                                                                          end.                                                                         if P-RV AND not available pay0_treal-vat then do:                              create pay0_treal-vat.                                                       assign                                                                       pay0_treal-vat.inkas-code = "":U                                             pay0_treal-vat.fact-order = 0                                                pay0_treal-vat.grp-code = v-grp-code                                         pay0_treal-vat.vat-pc     = treal-3.vat-pc                                   pay0_treal-vat.rv         = 0                                                .                                                                          end.                                                                         if not available gen_treal-vat then do:                                        create gen_treal-vat.                                                        assign                                                                       gen_treal-vat.inkas-code = "":U                                              gen_treal-vat.grp-code   = "":U                                              gen_treal-vat.vat-pc     = treal-3.vat-pc                                    gen_treal-vat.rv         = treal-3.rv                                        .                                                                          end.                                                                         if P-RV AND not available gen0_treal-vat then do:                              create gen0_treal-vat.                                                       assign                                                                       gen0_treal-vat.inkas-code = "":U                                             gen0_treal-vat.grp-code   = "":U                                             gen0_treal-vat.vat-pc     = treal-3.vat-pc                                   gen0_treal-vat.rv         = 0                                                .                                                                          end.
        assign                                                                       treal-vat.netto = treal-vat.netto + treal-3.netto-inkas                      treal-vat.netto-rubl = treal-vat.netto-rubl + treal-3.netto-rubl-inkas       pay_treal-vat.netto = pay_treal-vat.netto + treal-3.netto-inkas              pay_treal-vat.netto-rubl = pay_treal-vat.netto-rubl + treal-3.netto-rubl-inkas gen_treal-vat.netto = gen_treal-vat.netto + treal-3.netto-inkas              gen_treal-vat.netto-rubl = gen_treal-vat.netto-rubl + treal-3.netto-rubl-inkas .                                                                              if p-rv then do:                                                                 assign                                                                         pay0_treal-vat.netto = pay0_treal-vat.netto + treal-3.netto-inkas                pay0_treal-vat.netto-rubl = pay0_treal-vat.netto-rubl + treal-3.netto-rubl-inkas   gen0_treal-vat.netto = gen0_treal-vat.netto + treal-3.netto-inkas                gen0_treal-vat.netto-rubl = gen0_treal-vat.netto-rubl + treal-3.netto-rubl-inkas   .                                                                               end.
        NEXT _doc-line.
      end.
    end.
     if not p-rv or treal-3.rv = 1 then do:
      FIND FIRST buf_doc-line no-lock WHERE
                buf_doc-line.doc-code = inkas-uslugi1 AND
                buf_doc-line.artic     = buf_goods.artic AND
                buf_doc-line.prod-type = buf_goods.prod-type AND
                buf_doc-line.prod-code = buf_goods.prod-code  no-error .
      if available buf_doc-line then do:
        assign
        treal-3.vat-pc = buf_doc-line.vat-pc.
        if p-group then do:                                      find first buf_tt-cash-pay no-lock where                                               buf_tt-cash-pay.cdpay-code = treal-3.cpay-code                           AND buf_tt-cash-pay.curr-code = treal-3.curr-code no-error.            if buf_tt-cash-pay.grp-code = chr(4) + "0":U then do:                  assign                                                                       v-grp-code = string(treal-3.cpay-code) + chr(4) +                                 string(treal-3.curr-code)                                       .                                                                          end.                                                                         else do:                                                                       assign                                                                       v-grp-code = buf_tt-cash-pay.grp-code                                        .                                                                          end.                                                                       end.                                                                         else do:                                                                       assign                                                                       v-grp-code = string(treal-3.cpay-code) + chr(4) +                                 string(treal-3.curr-code)                                       .                                                                          end.                                                                                              find first treal-vat where                                      treal-vat.inkas-code = buf_Inkas.inkas-code                              AND treal-vat.vat-pc = treal-3.vat-pc                                        AND treal-vat.grp-code = v-grp-code                                          AND treal-vat.rv   = treal-3.rv  no-error .                                                   find first pay_treal-vat where                                  pay_treal-vat.inkas-code = "":U                                          AND pay_treal-vat.vat-pc = treal-3.vat-pc                                    AND pay_treal-vat.grp-code = v-grp-code                                      AND pay_treal-vat.rv = treal-3.rv                no-error .                  if p-rv then do:                                                                              find first pay0_treal-vat where                                 pay0_treal-vat.inkas-code = "":U                                         AND pay0_treal-vat.vat-pc = treal-3.vat-pc                                   AND pay0_treal-vat.grp-code = v-grp-code                                     AND pay0_treal-vat.rv = 0                         no-error .                 end.                                                                                          find first gen_treal-vat where                                  gen_treal-vat.inkas-code = "":U                                          AND gen_treal-vat.vat-pc = treal-3.vat-pc                                    AND gen_treal-vat.grp-code  = "":U                                           AND gen_treal-vat.rv = treal-3.rv  no-error .                                if p-rv then do:                                                                              find first gen0_treal-vat where                                 gen0_treal-vat.inkas-code = "":U                                         AND gen0_treal-vat.vat-pc = treal-3.vat-pc                                   AND gen0_treal-vat.grp-code  = "":U                                          AND gen0_treal-vat.rv = 0  no-error .                                        end .                                                                  if not available treal-vat then do:                                            create treal-vat.                                                            assign                                                                       treal-vat.inkas-code = buf_inkas.inkas-code                                  treal-vat.doc-date   = buf_inkas.fact-date                                   treal-vat.fact-order = buf_trn-doc.fact-order                                treal-vat.grp-code   = v-grp-code                                            treal-vat.vat-pc     = treal-3.vat-pc                                        treal-vat.rv         = treal-3.rv                                            .                                                                          end.                                                                         if not available pay_treal-vat then do:                                        create pay_treal-vat.                                                        assign                                                                       pay_treal-vat.inkas-code = "":U                                              pay_treal-vat.fact-order = 0                                                 pay_treal-vat.grp-code = v-grp-code                                          pay_treal-vat.vat-pc     = treal-3.vat-pc                                    pay_treal-vat.rv         = treal-3.rv                                        .                                                                          end.                                                                         if P-RV AND not available pay0_treal-vat then do:                              create pay0_treal-vat.                                                       assign                                                                       pay0_treal-vat.inkas-code = "":U                                             pay0_treal-vat.fact-order = 0                                                pay0_treal-vat.grp-code = v-grp-code                                         pay0_treal-vat.vat-pc     = treal-3.vat-pc                                   pay0_treal-vat.rv         = 0                                                .                                                                          end.                                                                         if not available gen_treal-vat then do:                                        create gen_treal-vat.                                                        assign                                                                       gen_treal-vat.inkas-code = "":U                                              gen_treal-vat.grp-code   = "":U                                              gen_treal-vat.vat-pc     = treal-3.vat-pc                                    gen_treal-vat.rv         = treal-3.rv                                        .                                                                          end.                                                                         if P-RV AND not available gen0_treal-vat then do:                              create gen0_treal-vat.                                                       assign                                                                       gen0_treal-vat.inkas-code = "":U                                             gen0_treal-vat.grp-code   = "":U                                             gen0_treal-vat.vat-pc     = treal-3.vat-pc                                   gen0_treal-vat.rv         = 0                                                .                                                                          end.
        assign                                                                       treal-vat.netto = treal-vat.netto + treal-3.netto-inkas                      treal-vat.netto-rubl = treal-vat.netto-rubl + treal-3.netto-rubl-inkas       pay_treal-vat.netto = pay_treal-vat.netto + treal-3.netto-inkas              pay_treal-vat.netto-rubl = pay_treal-vat.netto-rubl + treal-3.netto-rubl-inkas gen_treal-vat.netto = gen_treal-vat.netto + treal-3.netto-inkas              gen_treal-vat.netto-rubl = gen_treal-vat.netto-rubl + treal-3.netto-rubl-inkas .                                                                              if p-rv then do:                                                                 assign                                                                         pay0_treal-vat.netto = pay0_treal-vat.netto + treal-3.netto-inkas                pay0_treal-vat.netto-rubl = pay0_treal-vat.netto-rubl + treal-3.netto-rubl-inkas   gen0_treal-vat.netto = gen0_treal-vat.netto + treal-3.netto-inkas                gen0_treal-vat.netto-rubl = gen0_treal-vat.netto-rubl + treal-3.netto-rubl-inkas   .                                                                               end.
        NEXT _doc-line.
      end.
      FIND FIRST buf_doc-line no-lock WHERE
                buf_doc-line.doc-code begins inkas-uslugi2 AND
                buf_doc-line.artic     = buf_goods.artic AND
                buf_doc-line.prod-type = buf_goods.prod-type AND
                buf_doc-line.prod-code = buf_goods.prod-code  no-error .
      if available buf_doc-line then do:
        assign
        treal-3.vat-pc = buf_doc-line.vat-pc.
        if p-group then do:                                      find first buf_tt-cash-pay no-lock where                                               buf_tt-cash-pay.cdpay-code = treal-3.cpay-code                           AND buf_tt-cash-pay.curr-code = treal-3.curr-code no-error.            if buf_tt-cash-pay.grp-code = chr(4) + "0":U then do:                  assign                                                                       v-grp-code = string(treal-3.cpay-code) + chr(4) +                                 string(treal-3.curr-code)                                       .                                                                          end.                                                                         else do:                                                                       assign                                                                       v-grp-code = buf_tt-cash-pay.grp-code                                        .                                                                          end.                                                                       end.                                                                         else do:                                                                       assign                                                                       v-grp-code = string(treal-3.cpay-code) + chr(4) +                                 string(treal-3.curr-code)                                       .                                                                          end.                                                                                              find first treal-vat where                                      treal-vat.inkas-code = buf_Inkas.inkas-code                              AND treal-vat.vat-pc = treal-3.vat-pc                                        AND treal-vat.grp-code = v-grp-code                                          AND treal-vat.rv   = treal-3.rv  no-error .                                                   find first pay_treal-vat where                                  pay_treal-vat.inkas-code = "":U                                          AND pay_treal-vat.vat-pc = treal-3.vat-pc                                    AND pay_treal-vat.grp-code = v-grp-code                                      AND pay_treal-vat.rv = treal-3.rv                no-error .                  if p-rv then do:                                                                              find first pay0_treal-vat where                                 pay0_treal-vat.inkas-code = "":U                                         AND pay0_treal-vat.vat-pc = treal-3.vat-pc                                   AND pay0_treal-vat.grp-code = v-grp-code                                     AND pay0_treal-vat.rv = 0                         no-error .                 end.                                                                                          find first gen_treal-vat where                                  gen_treal-vat.inkas-code = "":U                                          AND gen_treal-vat.vat-pc = treal-3.vat-pc                                    AND gen_treal-vat.grp-code  = "":U                                           AND gen_treal-vat.rv = treal-3.rv  no-error .                                if p-rv then do:                                                                              find first gen0_treal-vat where                                 gen0_treal-vat.inkas-code = "":U                                         AND gen0_treal-vat.vat-pc = treal-3.vat-pc                                   AND gen0_treal-vat.grp-code  = "":U                                          AND gen0_treal-vat.rv = 0  no-error .                                        end .                                                                  if not available treal-vat then do:                                            create treal-vat.                                                            assign                                                                       treal-vat.inkas-code = buf_inkas.inkas-code                                  treal-vat.doc-date   = buf_inkas.fact-date                                   treal-vat.fact-order = buf_trn-doc.fact-order                                treal-vat.grp-code   = v-grp-code                                            treal-vat.vat-pc     = treal-3.vat-pc                                        treal-vat.rv         = treal-3.rv                                            .                                                                          end.                                                                         if not available pay_treal-vat then do:                                        create pay_treal-vat.                                                        assign                                                                       pay_treal-vat.inkas-code = "":U                                              pay_treal-vat.fact-order = 0                                                 pay_treal-vat.grp-code = v-grp-code                                          pay_treal-vat.vat-pc     = treal-3.vat-pc                                    pay_treal-vat.rv         = treal-3.rv                                        .                                                                          end.                                                                         if P-RV AND not available pay0_treal-vat then do:                              create pay0_treal-vat.                                                       assign                                                                       pay0_treal-vat.inkas-code = "":U                                             pay0_treal-vat.fact-order = 0                                                pay0_treal-vat.grp-code = v-grp-code                                         pay0_treal-vat.vat-pc     = treal-3.vat-pc                                   pay0_treal-vat.rv         = 0                                                .                                                                          end.                                                                         if not available gen_treal-vat then do:                                        create gen_treal-vat.                                                        assign                                                                       gen_treal-vat.inkas-code = "":U                                              gen_treal-vat.grp-code   = "":U                                              gen_treal-vat.vat-pc     = treal-3.vat-pc                                    gen_treal-vat.rv         = treal-3.rv                                        .                                                                          end.                                                                         if P-RV AND not available gen0_treal-vat then do:                              create gen0_treal-vat.                                                       assign                                                                       gen0_treal-vat.inkas-code = "":U                                             gen0_treal-vat.grp-code   = "":U                                             gen0_treal-vat.vat-pc     = treal-3.vat-pc                                   gen0_treal-vat.rv         = 0                                                .                                                                          end.
        assign                                                                       treal-vat.netto = treal-vat.netto + treal-3.netto-inkas                      treal-vat.netto-rubl = treal-vat.netto-rubl + treal-3.netto-rubl-inkas       pay_treal-vat.netto = pay_treal-vat.netto + treal-3.netto-inkas              pay_treal-vat.netto-rubl = pay_treal-vat.netto-rubl + treal-3.netto-rubl-inkas gen_treal-vat.netto = gen_treal-vat.netto + treal-3.netto-inkas              gen_treal-vat.netto-rubl = gen_treal-vat.netto-rubl + treal-3.netto-rubl-inkas .                                                                              if p-rv then do:                                                                 assign                                                                         pay0_treal-vat.netto = pay0_treal-vat.netto + treal-3.netto-inkas                pay0_treal-vat.netto-rubl = pay0_treal-vat.netto-rubl + treal-3.netto-rubl-inkas   gen0_treal-vat.netto = gen0_treal-vat.netto + treal-3.netto-inkas                gen0_treal-vat.netto-rubl = gen0_treal-vat.netto-rubl + treal-3.netto-rubl-inkas   .                                                                               end.
        NEXT _doc-line.
      end.
    end.
  end.
end.
end procedure.
procedure printproc :
define variable v-only-excel as logical no-undo .
define variable f-cash-pay-name like ub.cash-pay.obj-name no-undo .
define variable f-inkas-code like ub.inkas.inkas-code no-undo .
define variable f-sum-rubl-3 as decimal no-undo .
define variable f-sum-base-4 as decimal no-undo .
define variable f-sum-rubl-4 as decimal no-undo .
define variable f-sum-base as decimal no-undo .
DEFINE VARIABLE fill18 as character no-undo.
DEFINE VARIABLE fill30 as character no-undo.
define variable ii as integer no-undo .
DEFINE VARIABLE Line                as      char    no-undo.
DEFINE VARIABLE date_string     as      char    no-undo.
define variable accum-netto as decimal no-undo extent 3.
define variable accum-netto-rubl as decimal no-undo extent 3.
define variable glog as logical no-undo .
define variable col-ii as integer no-undo .
define variable col-jj as integer no-undo .
define variable v-page-num as integer no-undo init -1.
define variable v-header as character no-undo .
define variable v-r-b as logical no-undo .
define variable v-rubl as logical no-undo .
define variable v-curr-r-b as character no-undo .
define variable v-header-curr as character no-undo .
define variable v-curr-abbr as character no-undo .
define variable irv as integer no-undo .
define variable irv-start as integer no-undo .
define variable irv-end as integer no-undo .
define variable col-trail as integer no-undo .
define variable col-fix as integer no-undo .
define variable num-vats as integer no-undo .
define variable iext as integer no-undo .
define variable irv2 as integer no-undo .
define variable v-first-found-vat as logical no-undo .
define variable v-first-found-rv as logical no-undo .
define variable jj as integer no-undo .
define buffer buf_cash-pay for ub.cash-pay.
define buffer gen_treal-vat for treal-vat.
define buffer gen0_treal-vat for treal-vat.
define buffer pay_treal-vat for treal-vat.
define buffer buf_tt-cash-group for tt-cash-group.
define buffer buf_currency for ub.currency.
define buffer buf_treal-vat for treal-vat.
  do
  on error undo, return error
  :
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
    assign
    sheetf.Excel-Column-Lable =  "Продажа,Дата док.,Тип кассового платежа" +
                                 (if p-rv then ",Рас/Взв" else '':U)
    sheetf.colformat = "2=dd/mm/yyyy"
    sheetf.sizes = "16,10,30" +  (if p-rv then ",7" else '':U)
    v-header = string("Продажа", "X(16)") + chr(32) +
               string("Дата док.", "X(10)") + chr(32) +
               string("Тип кассового платежа", "X(30)")  + chr(32)  +
               (if p-rv then (string("Рас/Взвр", "X(7)")  + chr(32))
                else '':U)
    v-r-b = (if v-curr-r-b = 'rubl':U or v-one-curr-code then yes else no)
    v-rubl =(if not v-r-b or (v-r-b = yes and v-curr-r-b = 'rubl':U)
            then yes
            else no)
    .
    if v-rubl = yes then do:
      assign
      v-header-curr = string( "(Все суммы в рублях)" )
      .
    end.
    else do:
      find first buf_currency no-lock where
                buf_currency.curr-code = v-curr-code no-error .
      assign
      v-header-curr = string( "(Все суммы в " +
                             (if available buf_currency
                             then buf_currency.curr-abbr
                             else string(v-curr-code)) + ")"
                            )
      .
    end.
    if p-rv then do:
      assign
      irv-start = 1
      irv-end = - 1
      col-fix  = 59
      col-trail = 67
      .
    end.
    else do:
      assign
      col-fix  = 59
      col-trail = 59
      irv-start = 0
      irv-end = 0
      .
    end.
    for each gen0_treal-vat no-lock where
            gen0_treal-vat.inkas-code = "":U
        AND gen0_treal-vat.grp-code   = ""
        AND gen0_treal-vat.rv   = 0
    break
    by gen0_treal-vat.vat-pc:
      if first-of(gen0_treal-vat.vat-pc) then do:
        assign
        num-vats = num-vats + 1
        sheetf.Excel-Column-Lable =  sheetf.Excel-Column-Lable + chr(44) + "Товар с НДС" + chr(32) + string(gen0_treal-vat.vat-pc, ">9.99")
        sheetf.sizes = sheetf.sizes + chr(44) +  "20"
        v-header   = v-header + string("Товар с НДС" + chr(32) + string(gen0_treal-vat.vat-pc, ">9.99"), "X(20)")
        .
      end.
    end.
    assign
    sheetf.Excel-Column-Lable =  sheetf.Excel-Column-Lable + chr(44) + "Итого по всем НДС"
    sheetf.sizes = sheetf.sizes + chr(44) +  "20"
    v-header = v-header + string("Итого по всем НДС", "X(20)")
    .
    if num-vats >= (if p-rv then 5 else 6) then do:
      assign
      v-only-excel = yes
      .
      message
      "Общая ширина интересующих Вас колонок больше 198" skip
      "отчет не уместится на бумаге формата А4 (ориентация альбомная)"
      "Выводить только в Excel?"
      view-as alert-box QUESTION buttons yes-no update glog.
      if not glog then do:
        run waitfram-hide in this-procedure .
        return.
      end.
    end.
    DEFINE FRAME OutFrame
    HEADER
    cur-time-print() AT 5 format "X(35)"
    string( "Страница " + string( PAGE-NUMBER( PrnLibStream ), ">>>>>9" ) ) AT 70 format "X(23)" SKIP
    Line format "X(195)" AT 1 skip
    v-header format "X(195)" AT 1
    with width 232 down stream-io.
    FORM HEADER
    Line format "X(195)" AT 1 SKIP
    "Продолжение - на следующей странице" AT 60 SKIP
    with FRAME BottomFrame width 232
    PAGE-BOTTOM no-labels no-box.
    run waitfram-show in this-procedure ("Ждите..." ).
    run prn-lib-open-stream  in this-procedure (
                                                input parParentProc
                                                ,input 43
                                                ,input yes
                                                ,input no
                                                ).
    assign
    str3 = v-header-curr.
    run rep/extitle.p (1).
    run waitfram-show in this-procedure ("Ждите..." ).
    find first buf1_sheetf no-lock where
              buf1_sheetf.sheet-num = 1 or buf1_sheetf.sheet-num = 0.
    PUT stream PrnLibStream UNFORMATTED
    "Суммы продаж с разбивкой по типам кассовых платежей и НДС"
    format "x(50)" SKIP(1).
    if p-rv then do:
      PUT stream PrnLibStream UNFORMATTED
      "Раздельно по чекам продажи и возврата"
      format "x(50)" SKIP(1).
    end.
    PUT stream PrnLibStream UNFORMATTED
    str1 skip
    str2 skip
    str4 skip
    v-header-curr skip
    .
    PUT stream PrnLibStream UNFORMATTED
    reportheader SKIP(0).
    FORM with FRAME OutFrame.
    VIEW STREAM PrnLibStream FRAME BottomFrame .
    VIEW STREAM PrnLibStream FRAME OutFrame .
    for each treal-vat no-lock where treal-vat.fact-order > 0
    break
    by treal-vat.fact-order
    by treal-vat.inkas-code
    by treal-vat.grp-code
    :
      if first-of(treal-vat.inkas-code) then do:
        if not v-only-excel then do:
           Put stream PrnLibStream unformatted
           treal-vat.inkas-code format "X(16)" chr(32)
           string(treal-vat.doc-date, "99/99/9999")
           .
        end.
        if ii-excel > 32000 then do:                                                               if   Make-Excel Then  do:   Output stream ForExcel close.   assign   number-list = number-list + 1   .   os-delete value( v-excel-file + ".":U + string(number-list)).   Output Stream ForExcel to value( v-excel-file + ".":U + string(number-list ) ) . end.                                                                          find first buf_sheetf where                                                                     buf_sheetf.sheet-num = ii-page + 1 no-error.                                if not available buf_sheetf then do:                                                    create buf_sheetf.                                                                  end.                                                                                  buffer-copy buf1_sheetf except sheet-num                                              to buf_sheetf                                                                         assign                                                                                buf_sheetf.sheet-num = ii-page + 1                                                    .                                                                                     run rep/extitle.p (ii-page) .                                                              assign                                                                                ii-page = ii-page + 1                                                                 ii-excel = 0                                                                          .                                                                                   end .
        if Make-Excel then  put   stream ForExcel unformatted
        treal-vat.inkas-code CHR(9)
        treal-vat.doc-date   CHR(9)
        .
      end.
      if first-of(treal-vat.grp-code) then do:
        do iext = 1 to 3:
          assign
          accum-netto[iext] = 0
          accum-netto-rubl[iext] = 0
          v-first-found-vat = yes
          .
        end.
            if p-group and treal-vat.grp-code      begins chr(4) then do:              find first buf_tt-cash-group no-lock where                                                                       buf_tt-cash-group.grp-code = treal-vat.grp-code no-error .                                        if available buf_tt-cash-group then do:                                                                  assign                                                                                                 f-cash-pay-name  = "Группа: " + buf_tt-cash-group.obj-name                                             .                                                                                                    end.                                                                                                   else do:                                                                                                 assign                                                                                                 f-cash-pay-name  = "Неизвестная группа касс.платежа"                                                   .                                                                                                    end.                                                                                                 end.                                                                                                   else do:                                                                                                 find first buf_cash-pay no-lock where                                                                            buf_cash-pay.cdpay-code = integer(entry(1, treal-vat.grp-code, chr(4)))                           AND buf_cash-pay.curr-code = integer(entry(2, treal-vat.grp-code, chr(4))) no-error .           if available buf_cash-pay then do:                                                                       assign                                                                                                 f-cash-pay-name = buf_cash-pay.obj-name                                                                .                                                                                                    end.                                                                                                   else do:                                                                                                 assign                                                                                                 f-cash-pay-name  = "Неизвестный тип. касс.платежа"                                                     .                                                                                                    end.                                                                                                 end.
        if first-of(treal-vat.grp-code)
        and (not p-rv  or v-first-found-vat  = yes)
        then do:
          if not v-only-excel then do:
            put stream PrnLibStream unformatted
            f-cash-pay-name at 29.
          end.
          if Make-Excel then  put   stream ForExcel unformatted
          (if first-of(treal-vat.inkas-code ) then '':U else fill(CHR(9), 2))
          f-cash-pay-name CHR(9)
          .
        end.
        v-first-found-rv = yes.
        do irv = irv-start to irv-end by -2:
          assign
          ii = 0
          v-first-found-vat = yes
          .
          for each gen0_treal-vat no-lock where
                  gen0_treal-vat.inkas-code = "":U
              AND gen0_treal-vat.grp-code = "":U
              AND gen0_treal-vat.rv = 0
              :
            assign
            ii = ii + 1
            col-ii = col-trail + 20 * (ii - 1 )
            .
            find first buf_treal-vat no-lock where
                  buf_treal-vat.inkas-code = treal-vat.inkas-code
              AND buf_treal-vat.grp-code   = treal-vat.grp-code
              AND buf_treal-vat.vat-pc     = gen0_treal-vat.vat-pc
              AND buf_treal-vat.rv         = irv
              no-error.
            if available buf_treal-vat then do:
              if p-rv and v-first-found-vat then do:
                                if not v-only-excel then do:
                  put stream PrnLibStream unformatted
                  entry(lookup(string(irv), "1,-1,0"), " Расход,Возврат,Рас+Взвр") at col-fix.
                  do jj = 1 to (ii - 1) :
                    col-jj = col-trail + 20 * (jj - 1).
                    put stream PrnLibStream unformatted
                    string(0, "->>,>>>,>>>,>>9.99") at col-jj.
                  end.
                end.
                if Make-Excel then  put   stream ForExcel unformatted
                (if v-first-found-rv
                 then '':U
                 else fill(CHR(9), 3)
                 )
                entry(lookup(string(irv), "1,-1,0"), " Расход,Возврат,Рас+Взвр")
                CHR(9).
                do jj = 1 to (ii - 1) :
                  if Make-Excel then  put   stream ForExcel unformatted
                  0
                  CHR(9)
                  .
                end.
              end.
              assign
              v-first-found-vat = no
              accum-netto[2] = accum-netto[2] + buf_treal-vat.netto
              accum-netto-rubl[2] = accum-netto-rubl[2] + buf_treal-vat.netto-rubl
              .
              if buf_treal-vat.rv <> 0 then do:
                assign
                accum-netto[irv + 2] = accum-netto[irv + 2] + buf_treal-vat.netto
                accum-netto-rubl[irv + 2] = accum-netto-rubl[irv + 2] + buf_treal-vat.netto-rubl
                .
              end.
              if not v-only-excel then do:
                put stream PrnLibStream unformatted
                string(if v-rubl
                      then buf_treal-vat.netto-rubl
                      else buf_treal-vat.netto , "->>,>>>,>>>,>>9.99") at col-ii.
              end.
              if Make-Excel then  put   stream ForExcel unformatted
              (if v-rubl
              then buf_treal-vat.netto-rubl
              else buf_treal-vat.netto) CHR(9)
              .
              v-first-found-rv = no.
            end.
            else do:
              if not p-rv
              or v-first-found-vat = no  then do:
                if not v-only-excel then do:
                  put stream PrnLibStream unformatted
                  string(0, "->>,>>>,>>>,>>9.99") at col-ii.
                end.
                if Make-Excel then  put   stream ForExcel unformatted
                0
                CHR(9)
                .
              end.
            end.
          end.
          assign
          ii = ii + 1
          col-ii = col-trail + 20 * (ii - 1)
          .
          if (not p-rv) or (v-first-found-vat = no) then do:
            if not v-only-excel then do:
              put stream PrnLibStream unformatted
              string(if v-rubl
                      then accum-netto-rubl[irv + 2]
                      else accum-netto[irv + 2], "->>,>>>,>>>,>>9.99") at col-ii skip.
            end.
            if Make-Excel then  put   stream ForExcel unformatted
            (if v-rubl
            then accum-netto-rubl[irv + 2]
            else accum-netto[irv + 2])
            SKIP.
            assign
            ii-excel = ii-excel + 1
            .
          end.
        end.
      end.
      if last-of(treal-vat.inkas-code) then do:
        DOWN STREAM PrnLibStream
        1 with FRAME OutFrame .
        if ii-excel > 32000 then do:                                                               if   Make-Excel Then  do:   Output stream ForExcel close.   assign   number-list = number-list + 1   .   os-delete value( v-excel-file + ".":U + string(number-list)).   Output Stream ForExcel to value( v-excel-file + ".":U + string(number-list ) ) . end.                                                                          find first buf_sheetf where                                                                     buf_sheetf.sheet-num = ii-page + 1 no-error.                                if not available buf_sheetf then do:                                                    create buf_sheetf.                                                                  end.                                                                                  buffer-copy buf1_sheetf except sheet-num                                              to buf_sheetf                                                                         assign                                                                                buf_sheetf.sheet-num = ii-page + 1                                                    .                                                                                     run rep/extitle.p (ii-page) .                                                              assign                                                                                ii-page = ii-page + 1                                                                 ii-excel = 0                                                                          .                                                                                   end .
        if Make-Excel then  put   stream ForExcel unformatted skip.
      end.
    end.
    if not v-only-excel then do:
      DOWN STREAM PrnLibStream
      1 with FRAME OutFrame .
      Put stream PrnLibStream unformatted "Итого ПО ПРОДАЖАМ" .
    end.
    if ii-excel > 32000 then do:                                                               if   Make-Excel Then  do:   Output stream ForExcel close.   assign   number-list = number-list + 1   .   os-delete value( v-excel-file + ".":U + string(number-list)).   Output Stream ForExcel to value( v-excel-file + ".":U + string(number-list ) ) . end.                                                                          find first buf_sheetf where                                                                     buf_sheetf.sheet-num = ii-page + 1 no-error.                                if not available buf_sheetf then do:                                                    create buf_sheetf.                                                                  end.                                                                                  buffer-copy buf1_sheetf except sheet-num                                              to buf_sheetf                                                                         assign                                                                                buf_sheetf.sheet-num = ii-page + 1                                                    .                                                                                     run rep/extitle.p (ii-page) .                                                              assign                                                                                ii-page = ii-page + 1                                                                 ii-excel = 0                                                                          .                                                                                   end .
    if Make-Excel then  put   stream ForExcel unformatted
    "Итого ПО ПРОДАЖАМ"
    skip
    CHR(9)
    CHR(9)
    .
    for each pay_treal-vat no-lock where
            pay_treal-vat.inkas-code = "":U
        AND pay_treal-vat.grp-code <> "":U
    break
    by pay_treal-vat.fact-order
    by pay_treal-vat.inkas-code
    by pay_treal-vat.grp-code
    by pay_treal-vat.rv :
      if first-of(pay_treal-vat.grp-code) then do:
        do iext = 1 to 3:
          assign
          accum-netto[iext] = 0
          accum-netto-rubl[iext] = 0
          .
        end.
        if p-group and pay_treal-vat.grp-code      begins chr(4) then do:              find first buf_tt-cash-group no-lock where                                                                       buf_tt-cash-group.grp-code = pay_treal-vat.grp-code no-error .                                        if available buf_tt-cash-group then do:                                                                  assign                                                                                                 f-cash-pay-name  = "Группа: " + buf_tt-cash-group.obj-name                                             .                                                                                                    end.                                                                                                   else do:                                                                                                 assign                                                                                                 f-cash-pay-name  = "Неизвестная группа касс.платежа"                                                   .                                                                                                    end.                                                                                                 end.                                                                                                   else do:                                                                                                 find first buf_cash-pay no-lock where                                                                            buf_cash-pay.cdpay-code = integer(entry(1, pay_treal-vat.grp-code, chr(4)))                           AND buf_cash-pay.curr-code = integer(entry(2, pay_treal-vat.grp-code, chr(4))) no-error .           if available buf_cash-pay then do:                                                                       assign                                                                                                 f-cash-pay-name = buf_cash-pay.obj-name                                                                .                                                                                                    end.                                                                                                   else do:                                                                                                 assign                                                                                                 f-cash-pay-name  = "Неизвестный тип. касс.платежа"                                                     .                                                                                                    end.                                                                                                 end.
        do irv2 = 1 to num-entries(if p-rv then "1,-1,0" else "0"):
          if not first-of(pay_treal-vat.inkas-code)
          or irv2 > 1
          then do:
            if ii-excel > 32000 then do:                                                               if   Make-Excel Then  do:   Output stream ForExcel close.   assign   number-list = number-list + 1   .   os-delete value( v-excel-file + ".":U + string(number-list)).   Output Stream ForExcel to value( v-excel-file + ".":U + string(number-list ) ) . end.                                                                          find first buf_sheetf where                                                                     buf_sheetf.sheet-num = ii-page + 1 no-error.                                if not available buf_sheetf then do:                                                    create buf_sheetf.                                                                  end.                                                                                  buffer-copy buf1_sheetf except sheet-num                                              to buf_sheetf                                                                         assign                                                                                buf_sheetf.sheet-num = ii-page + 1                                                    .                                                                                     run rep/extitle.p (ii-page) .                                                              assign                                                                                ii-page = ii-page + 1                                                                 ii-excel = 0                                                                          .                                                                                   end .
            if Make-Excel then  put   stream ForExcel unformatted
            CHR(9)
            CHR(9)
            .
          end.
          if not v-only-excel then do:
            put stream PrnLibStream unformatted
            f-cash-pay-name at 29.
          end.
          if Make-Excel then  put   stream ForExcel unformatted
          f-cash-pay-name CHR(9)
          .
          assign
          irv = integer(entry(irv2, (if p-rv then "1,-1,0" else "0"))).
          assign
          ii = 0
          .
          if p-rv then do:
                        if not v-only-excel then do:
              put stream PrnLibStream unformatted
              entry(lookup(string(irv), "1,-1,0"), " Расход,Возврат,Рас+Взвр") at col-fix.
            end.
            if Make-Excel then  put   stream ForExcel unformatted
            entry(lookup(string(irv), "1,-1,0"), " Расход,Возврат,Рас+Взвр")
            CHR(9)
            .
          end.
          for each gen0_treal-vat no-lock where
                gen0_treal-vat.inkas-code = "":U
            AND gen0_treal-vat.grp-code = "":U
            AND gen0_treal-vat.rv = 0:
            find first buf_treal-vat no-lock where
                  buf_treal-vat.inkas-code = "":U
              AND buf_treal-vat.grp-code   = pay_treal-vat.grp-code
              AND buf_treal-vat.vat-pc     = gen0_treal-vat.vat-pc
              AND buf_treal-vat.rv         = irv  no-error.
            assign
            ii = ii + 1
            col-ii = col-trail + 20 * (ii - 1)
            .
            if available buf_treal-vat then do:
                assign
                accum-netto[irv + 2] = accum-netto[irv + 2] + buf_treal-vat.netto
                accum-netto-rubl[irv + 2] = accum-netto-rubl[irv + 2] + buf_treal-vat.netto-rubl
                .
              if not v-only-excel then do:
                put stream PrnLibStream unformatted
                string(if v-rubl
                      then buf_treal-vat.netto-rubl
                      else buf_treal-vat.netto, "->>,>>>,>>>,>>9.99") at col-ii.
              end.
              if Make-Excel then  put   stream ForExcel unformatted
              (if v-rubl
              then buf_treal-vat.netto-rubl
              else buf_treal-vat.netto)  CHR(9)
              .
            end.
            else do:
              if not v-only-excel then do:
                put stream PrnLibStream unformatted
                string(0, "->>,>>>,>>>,>>9.99") at col-ii.
              end.
                            if Make-Excel then  put   stream ForExcel unformatted
              0  CHR(9)
              .
            end.
          end.
          assign
          ii = ii + 1
          col-ii = col-trail + 20 * (ii - 1)
          .
          if not v-only-excel then do:
            put stream PrnLibStream unformatted
            string(if v-rubl
                  then accum-netto-rubl[irv + 2]
                  else accum-netto[irv + 2], "->>,>>>,>>>,>>9.99") at col-ii skip.
          end.
          if Make-Excel then  put   stream ForExcel unformatted
          (if v-rubl
          then accum-netto-rubl[irv + 2]
          else accum-netto[irv + 2])
          SKIP.
          assign
          ii-excel = ii-excel + 1
          .
        end.
        if p-rv then do:
          if not v-only-excel then do:
            DOWN STREAM PrnLibStream
            1 with FRAME OutFrame .
          end.
          if Make-Excel then  put   stream ForExcel unformatted
          CHR(9)
          SKIP.
          assign
          ii-excel = ii-excel + 1
          .
        end.
      end.
    end.
    if not v-only-excel then do:
      DOWN STREAM PrnLibStream
      1 with FRAME OutFrame .
      Put stream PrnLibStream unformatted "ИТОГО ПО ВСЕМ ПРОДАЖАМ И ТИПАМ ПЛАТЕЖЕЙ" .
    end.
    if ii-excel > 32000 then do:                                                               if   Make-Excel Then  do:   Output stream ForExcel close.   assign   number-list = number-list + 1   .   os-delete value( v-excel-file + ".":U + string(number-list)).   Output Stream ForExcel to value( v-excel-file + ".":U + string(number-list ) ) . end.                                                                          find first buf_sheetf where                                                                     buf_sheetf.sheet-num = ii-page + 1 no-error.                                if not available buf_sheetf then do:                                                    create buf_sheetf.                                                                  end.                                                                                  buffer-copy buf1_sheetf except sheet-num                                              to buf_sheetf                                                                         assign                                                                                buf_sheetf.sheet-num = ii-page + 1                                                    .                                                                                     run rep/extitle.p (ii-page) .                                                              assign                                                                                ii-page = ii-page + 1                                                                 ii-excel = 0                                                                          .                                                                                   end .
    if Make-Excel then  put   stream ForExcel unformatted
    "ИТОГО ПО ВСЕМ" CHR(9)
    "ПРОДАЖАМ" CHR(9)
    "И ТИПАМ ПЛАТЕЖЕЙ"  CHR(9)
    .
    do iext = 1 to 3:
      assign
      accum-netto[iext] = 0
      accum-netto-rubl[iext] = 0
      .
    end.
    do irv2 = 1 to num-entries(if p-rv then "1,-1,0" else '0'):
      ii = 0.
      irv = integer(entry(irv2, if p-rv then "1,-1,0" else '0')).
      if p-rv then do:
        if not v-only-excel then do:
                    put stream PrnLibStream unformatted
          entry(lookup(string(irv), "1,-1,0"), " Расход,Возврат,Рас+Взвр") at col-fix
          .
        end.
        if Make-Excel then  put   stream ForExcel unformatted
        (if irv2 > 1
         then fill(CHR(9), 3)
         else '':U)
         entry(lookup(string(irv), "1,-1,0"), " Расход,Возврат,Рас+Взвр") CHR(9).
      end.
      for each gen0_treal-vat no-lock where
              gen0_treal-vat.inkas-code = "":U
          AND gen0_treal-vat.grp-code   = "":U
          AND gen0_treal-vat.rv   = 0 :
        find first gen_treal-vat no-lock where
                  gen_treal-vat.inkas-code = ""
              AND gen_treal-vat.grp-code = ""
              AND gen_treal-vat.vat-pc = gen0_treal-vat.vat-pc
              AND gen_treal-vat.rv = irv no-error.
        assign
        ii = ii + 1
        col-ii = col-trail + 20 * (ii - 1)
        .
        if available gen_treal-vat then do:
          if not v-only-excel then do:
            put stream PrnLibStream unformatted
            string(if v-rubl
                  then gen_treal-vat.netto-rubl
                  else gen_treal-vat.netto, "->>,>>>,>>>,>>9.99") at col-ii.
          end.
          if Make-Excel then  put   stream ForExcel unformatted
          (if v-rubl
          then gen_treal-vat.netto-rubl
          else gen_treal-vat.netto) CHR(9)
          .
          assign
          accum-netto[irv + 2] = accum-netto[irv + 2] + gen_treal-vat.netto
          accum-netto-rubl[irv + 2] = accum-netto-rubl[irv + 2] + gen_treal-vat.netto-rubl
          .
        end.
        else do:
          if not v-only-excel then do:
            put stream PrnLibStream unformatted
            string(0, "->>,>>>,>>>,>>9.99") at col-ii.
          end.
                    if Make-Excel then  put   stream ForExcel unformatted
          0  CHR(9)
          .
        end.
      end.
      assign
      ii  = ii + 1
      col-ii = col-trail + 20 * (ii - 1)
      .
      if not v-only-excel then do:
        put stream PrnLibStream unformatted
        string(if v-rubl
              then accum-netto-rubl[irv + 2]
              else accum-netto[irv + 2], "->>,>>>,>>>,>>9.99") at col-ii.
        if irv = 0 then do:
          DOWN STREAM PrnLibStream
          1 with FRAME OutFrame .
        end.
        else do:
          put stream PrnLibStream unformatted skip.
        end.
      end.
      if Make-Excel then  put   stream ForExcel unformatted
      (if v-rubl
      then accum-netto-rubl[irv + 2]
      else accum-netto[irv + 2])
      skip.
    end.
    HIDE STREAM PrnLibStream FRAME BottomFrame .
    OUTPUT STREAM PrnLibStream CLOSE.
    if Make-Excel then output stream ForExcel close.
    run waitfram-hide in this-procedure .
    if not v-only-excel then do:
      run prn-lib-prn-file in this-procedure (
                                                input parParentProc
                                                ,input 8
                                                ).
    end.
    else do:
      define variable v-report-name as character no-undo .
      run prn-lib-get-report-name  in this-procedure(
                                                     input parParentProc
                                                    ,output v-report-name ) .
      run rep/runexcel.p (v-report-name + ".txt").
    end.
  end.
end procedure.
procedure printproc-gds :
define variable v-gds-code like ub.goods.gds-code no-undo .
define variable f-artic like ub.goods.artic no-undo .
define variable f-gds-name like ub.goods.gds-name no-undo .
define variable f-prod-name like ub.clients.obj-name no-undo .
define variable f-cash-pay-name like ub.cash-pay.obj-name no-undo .
define variable f-grp-name like ub.goods.grp-name no-undo .
define variable f-sum-rubl as decimal no-undo .
define variable f-sum-base as decimal no-undo .
DEFINE VARIABLE Line                as      char    no-undo.
DEFINE VARIABLE date_string     as      char    no-undo.
  do
  on error undo, return error
  :
DEFINE FRAME OutFrame
v-gds-code COLUMN-LABEL "Код товара"
f-artic  COLUMN-LABEL "Артикул"
f-gds-name COLUMn-LABEL "Название товара"  format "X(40)"
f-prod-name COLUMn-LABEL "Производитель" format "X(30)"
f-cash-pay-name COLUMn-LABEL "Тип касс.платежа" format "X(30)"
f-grp-name  COLUMn-LABEL "Группа" format "X(50)"
f-sum-rubl      COLUMn-LABEL "Сумма в руб." format "->>>,>>>,>>9.99"
f-sum-base      COLUMn-LABEL "Сумма в б.в." format "->>>,>>>,>>9.99"
HEADER
cur-time-print() AT 5 format "X(35)"
string( "Страница " + string( PAGE-NUMBER( PrnLibStream ), ">>>>>9" ) ) AT 170 format "X(13)" SKIP
Line format "X(195)" AT 1
with width 232 down stream-io.
FORM HEADER
Line format "X(195)" AT 1 SKIP
"Продолжение - на следующей странице" AT 60 SKIP
with FRAME BottomFrame width 232
PAGE-BOTTOM no-labels no-box.
run waitfram-show in this-procedure ("Ждите..." ).
run prn-lib-open-stream  in this-procedure (
                                            input parParentProc
                                            ,input 43
                                            ,input yes
                                            ,input no
                                            ).
run rep/extitle.p (1).
find first buf1_sheetf no-lock where buf1_sheetf.sheet-num = 1 or buf1_sheetf.sheet-num = 0.
PUT stream PrnLibStream UNFORMATTED
("Разбивка товаров в чеке по типам кассовых платежей" +
string( x-date-start, "99/99/9999" ) + " по " + string(x-date-end, "99/99/9999") + ".")
format "x(110)" SKIP(1).
PUT stream PrnLibStream UNFORMATTED
str1 skip
str2 skip
str4 skip.
PUT stream PrnLibStream UNFORMATTED
reportheader SKIP(0).
VIEW STREAM PrnLibStream FRAME BottomFrame .
FORM with FRAME OutFrame.
for each treal-3 no-lock
break
by treal-3.gds-code
by treal-3.cpay-code
by treal-3.curr-code
by treal-3.is-pay
:
  if ii-excel > 32000 then do:                                                               if   Make-Excel Then  do:   Output stream ForExcel close.   assign   number-list = number-list + 1   .   os-delete value( v-excel-file + ".":U + string(number-list)).   Output Stream ForExcel to value( v-excel-file + ".":U + string(number-list ) ) . end.                                                                          find first buf_sheetf where                                                                     buf_sheetf.sheet-num = ii-page + 1 no-error.                                if not available buf_sheetf then do:                                                    create buf_sheetf.                                                                  end.                                                                                  buffer-copy buf1_sheetf except sheet-num                                              to buf_sheetf                                                                         assign                                                                                buf_sheetf.sheet-num = ii-page + 1                                                    .                                                                                     run rep/extitle.p (ii-page) .                                                              assign                                                                                ii-page = ii-page + 1                                                                 ii-excel = 0                                                                          .                                                                                   end .
  if first-of(treal-3.is-pay) then do:
    find first buf_goods no-lock where
              buf_goods.gds-code = treal-3.gds-code.
    find first buf_clients no-lock where
              buf_Clients.obj-type = buf_goods.prod-type
          AND buf_Clients.obj-code = buf_goods.prod-code no-error .
    assign
    f-prod-name = buf_clients.obj-name
    f-gds-name = buf_goods.gds-name
    f-grp-name = buf_goods.grp-name
    f-artic = buf_goods.artic
    .
    display stream PrnLibStream
    treal-3.gds-code @ v-gds-code
    f-artic
    f-gds-name
    f-prod-name
    f-grp-name
    treal-3.out-name @ f-cash-pay-name
    treal-3.netto-rubl @ f-sum-rubl
    treal-3.netto @ f-sum-base
    with frame OutFrame.
    DOWN STREAM PrnLibStream
    1 with FRAME OutFrame .
  end.
  else do:
    display stream PrnLibStream
    treal-3.out-name @ f-cash-pay-name
    treal-3.netto-rubl @ f-sum-rubl
    treal-3.netto @ f-sum-base
    with frame OutFrame.
    DOWN STREAM PrnLibStream
    1 with FRAME OutFrame .
  end.
  if Make-Excel then  put   stream ForExcel unformatted
  treal-3.gds-code          CHR(9)
  f-artic                   CHR(9)
  f-gds-name                CHR(9)
  f-prod-name               CHR(9)
  f-grp-name                CHR(9)
  treal-3.out-name          CHR(9)
  treal-3.netto-rubl        CHR(9)
  treal-3.netto             CHR(9)
  skip.
  assign
  ii-excel = ii-excel + 1
  .
end.
HIDE STREAM PrnLibStream FRAME BottomFrame .
OUTPUT STREAM PrnLibStream CLOSE.
if Make-Excel then output stream ForExcel close.
run waitfram-hide in this-procedure .
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 8
                                          ).
  end.
end procedure.
