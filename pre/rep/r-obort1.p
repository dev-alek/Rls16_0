block-level on error undo, throw.
define input parameter ShowZero          as logical   no-undo .
define input parameter ShowZero-2        as logical   no-undo .
define input parameter RADIO-Nomenkl     as integer   no-undo .
define input parameter Tog-obj           as logical   no-undo .
define input parameter Classify          as character no-undo .
define input parameter RADIO-AltObj      as integer   no-undo .
define input parameter AltObj-list       as character no-undo .
define input parameter SortType          as character no-undo .
define input parameter prod-zen          as logical   no-undo .
define input parameter print-o           as character no-undo .
define input parameter SumsOnly          as logical   no-undo .
define input parameter tog-lavel         as logical   no-undo .
define input parameter var-lavel         as integer   no-undo .
define input parameter tog-tree          as logical   no-undo .
define input parameter name-tov          as integer   no-undo .
define input parameter no-nds            as logical   no-undo .
define input parameter ExportZUM         as logical   no-undo .
define input parameter sz-qnty           as integer   no-undo .
define input parameter sys-key           as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: 3a62839ff969, 963, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Thu Feb 16 15:20:37 2017 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-obort1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-obort1.p $":U .
define variable vss-description as character no-undo init "Старая оборотная ведомость".
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
define variable vss-include-info7 as character format "X(65)" no-undo
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
define variable vss-include-info8 as character format "X(65)" no-undo
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define  shared variable RepPathName        as character no-undo .
define  shared variable PrintRubl          as logical   no-undo .
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
def var vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
DEFINE temp-table gds-prop no-undo
    field   StartWay-Qnty    as  decimal
    field   StartWay-CostSum as  decimal
    field   StartWay-SaleSum as  decimal
    field   EndWay-Qnty      as  decimal
    field   EndWay-CostSum   as  decimal
    field   EndWay-SaleSum   as  decimal
    field   Free-Qnty      as  decimal
    field   Free-CostSum   as  decimal
    field   Free-SaleSum   as  decimal
    field   Res-Qnty       as  decimal
    field   Res-CostSum    as  decimal
    field   Res-DocSum     as  decimal
    field   Res-SaleSum    as  decimal
    field   Res-DiscntSum  as  decimal
    field   InExt-Qnty       as  decimal
    field   InExt-CostSum    as  decimal
    field   RetPost-Qnty     as  decimal
    field   RetPost-CostSum  as  decimal
    field   OutExt-Qnty      as  decimal
    field   OutExt-CostSum   as  decimal
    field   OutExt-DocSum   as  decimal
    field   OutExt-SaleSum   as  decimal
    field   OutExt-DiscntSum as  decimal
    field   RetOut-Qnty      as  decimal
    field   RetOut-CostSum   as  decimal
    field   RetOut-DocSum   as  decimal
    field   RetOut-SaleSum   as  decimal
    field   RetOut-DiscntSum as  decimal
    field   OutExtKass-Qnty      as  decimal
    field   OutExtKass-CostSum   as  decimal
    field   OutExtKass-SaleSum   as  decimal
    field   OutExtKass-DocSum   as  decimal
    field   OutExtKass-DiscntSum as  decimal
    field   RetOutKass-Qnty      as  decimal
    field   RetOutKass-CostSum   as  decimal
    field   RetOutKass-DocSum   as  decimal
    field   RetOutKass-SaleSum   as  decimal
    field   RetOutKass-DiscntSum as  decimal
    field   InInt-Qnty       as  decimal
    field   InInt-CostSum    as  decimal
    field   InInt-SaleSum    as  decimal
    field   OutInt-Qnty      as  decimal
    field   OutInt-CostSum   as  decimal
    field   OutInt-SaleSum   as  decimal
    field   RetInt-Qnty      as  decimal
    field   RetInt-CostSum   as  decimal
    field   RetInt-SaleSum   as  decimal
    field   Inv-Qnty         as  decimal
    field   Inv-CostSum      as  decimal
    field   Inv-SaleSum      as  decimal
    field   Spi-Qnty         as  decimal
    field   Spi-CostSum      as  decimal
    field   Spi-SaleSum      as  decimal
    field   InProiz-Qnty       as  decimal
    field   InProiz-CostSum    as  decimal
    field   InProiz-SaleSum    as  decimal
    field   OutProiz-Qnty      as  decimal
    field   OutProiz-CostSum   as  decimal
    field   OutProiz-SaleSum   as  decimal
    field   Per-SaleSum      as  decimal
    field   Avrg-Sale-Price  as decimal
    field   Last-Sale-Price  as decimal
    field   Cost-Price       as  decimal
    field   Up-Plan          as  decimal
    field   Effect-Value     as  decimal
    field   Up-Fact          as  decimal
    field   LastPer-Date     as  date
    field   LastPer-Num      as  char
    field   Alt-RestEnd-Qnty as  decimal
    field   obj-type         as  char
    field   obj-code         as  integer
    field   obj-name         as  char
    field   prod-type        as  char
    field   prod-code        as  integer
    field   prod-name        as  char
    field   artic            as  char
    field   gds-name         as  char
    field   gds-name1        as  char
    field   grp-name         as  char
    field   unit-base        as  char
    field   b-code           as  integer
    field   grp-code         as  integer
    field   vat-pc           as  decimal
    INDEX pi  IS PRIMARY   obj-type obj-code artic  prod-type prod-code
    INDEX pi1              obj-type obj-code b-code prod-type prod-code
    INDEX pi2              artic  prod-type prod-code
    INDEX pi3              prod-name
    INDEX pi4              grp-code
    INDEX pi5              vat-pc
.
DEFINE temp-table gds-sum no-undo
field  StartWay-Qnty        as  decimal
field  StartWay-CostSum     as  decimal
field  StartWay-SaleSum     as  decimal
field  EndWay-Qnty          as  decimal
field  EndWay-CostSum       as  decimal
field  EndWay-SaleSum       as  decimal
field   Free-Qnty      as  decimal
field   Free-CostSum   as  decimal
field   Free-SaleSum   as  decimal
field   Res-Qnty       as  decimal
field   Res-CostSum    as  decimal
field   Res-DocSum     as  decimal
field   Res-SaleSum    as  decimal
field   Res-DiscntSum  as  decimal
field  InExt-Qnty           as  decimal
field  InExt-CostSum        as  decimal
field  RetPost-Qnty         as  decimal
field  RetPost-CostSum      as  decimal
field  OutExt-Qnty          as  decimal
field  OutExt-CostSum       as  decimal
field  OutExt-SaleSum       as  decimal
field  OutExt-DiscntSum     as  decimal
field  RetOut-Qnty          as  decimal
field  RetOut-CostSum       as  decimal
field  RetOut-SaleSum       as  decimal
field  RetOut-DiscntSum     as  decimal
field  OutExtKass-Qnty      as  decimal
field  OutExtKass-CostSum   as  decimal
field  OutExtKass-SaleSum   as  decimal
field  OutExtKass-DiscntSum as  decimal
field  RetOutKass-Qnty      as  decimal
field  RetOutKass-CostSum   as  decimal
field  RetOutKass-SaleSum   as  decimal
field  RetOutKass-DiscntSum as  decimal
field  InInt-Qnty           as  decimal
field  InInt-CostSum        as  decimal
field  InInt-SaleSum        as  decimal
field  OutInt-Qnty          as  decimal
field  OutInt-CostSum       as  decimal
field  OutInt-SaleSum       as  decimal
field  RetInt-Qnty          as  decimal
field  RetInt-CostSum       as  decimal
field  RetInt-SaleSum       as  decimal
field  Inv-Qnty             as  decimal
field  Inv-CostSum          as  decimal
field  Inv-SaleSum          as  decimal
field  Spi-Qnty             as  decimal
field  Spi-CostSum          as  decimal
field  Spi-SaleSum          as  decimal
field  InProiz-Qnty         as  decimal
field  InProiz-CostSum      as  decimal
field  InProiz-SaleSum      as  decimal
field  OutProiz-Qnty        as  decimal
field  OutProiz-CostSum     as  decimal
field  OutProiz-SaleSum     as  decimal
field  Per-SaleSum          as  decimal
field   Effect-Value        as  decimal
field   Alt-RestEnd-Qnty    as  decimal
field  num                  as integer
INDEX pi  IS PRIMARY unique num
.
DEFINE temp-table line-frm no-undo
  field  num          as  integer
  field  beg          as  integer
  field  titul        as character
  field  titul1       as character
  field  titul2       as character
  field  frmt         as character
  field  frm          as character
  field  sum          as decimal
  INDEX pi  IS PRIMARY unique num
.
DEFINE temp-table tt-grp-tree no-undo
  field  num          as  integer
  field  full         as character
  field  name         as character
  INDEX pi  IS PRIMARY unique full
  INDEX pi1 num
.
define temp-table o_temp-parts no-undo like ub.parts
field Pri_Vnesh          as decimal init 0
field Ras_Vnesh          as decimal init 0
field Ras_Vnesh_VP       as decimal init 0
field Ras_Vnesh_Kass     as decimal init 0
field Vozvrat_Vnesh      as decimal init 0
field Vozvrat_Vnesh_Kass as decimal init 0
field Spi_Vnesh          as decimal init 0
field Pri_Perem          as decimal init 0
field Ras_Perem          as decimal init 0
field Vozvrat_Perem      as decimal init 0
field Ras_Prvo           as decimal init 0
field Pri_Prvo           as decimal init 0
field Inv                as decimal init 0
field rPri_Vnesh          as decimal init 0
field rRas_Vnesh          as decimal init 0
field rRas_Vnesh_VP       as decimal init 0
field rRas_Vnesh_Kass     as decimal init 0
field rVozvrat_Vnesh      as decimal init 0
field rVozvrat_Vnesh_Kass as decimal init 0
field rSpi_Vnesh          as decimal init 0
field rPri_Perem          as decimal init 0
field rRas_Perem          as decimal init 0
field rVozvrat_Perem      as decimal init 0
field rRas_Prvo           as decimal init 0
field rPri_Prvo           as decimal init 0
field rInv                as decimal init 0
field bPri_Vnesh          as decimal init 0
field bRas_Vnesh          as decimal init 0
field bRas_Vnesh_VP       as decimal init 0
field bRas_Vnesh_Kass     as decimal init 0
field bVozvrat_Vnesh      as decimal init 0
field bVozvrat_Vnesh_Kass as decimal init 0
field bSpi_Vnesh          as decimal init 0
field bPri_Perem          as decimal init 0
field bRas_Perem          as decimal init 0
field bVozvrat_Perem      as decimal init 0
field bRas_Prvo           as decimal init 0
field bPri_Prvo           as decimal init 0
field bInv                as decimal init 0
field Ovr                 as decimal init 0
field ostatok-start       as decimal init 0
field ostatok-end         as decimal init 0
field   obj-name         as  char
field   prod-name        as  char
field   gds-name         as  char
field   gds-name1        as  char
field   grp-name         as  char
field   unit-base        as  char
field   b-code           as  integer
field   grp-code         as  integer
field  StartWay-Qnty        as  decimal    init 0
field  StartWay-CostSum     as  decimal    init 0
field  StartWay-SaleSum     as  decimal    init 0
field  EndWay-Qnty          as  decimal    init 0
field  EndWay-CostSum       as  decimal    init 0
field  EndWay-SaleSum       as  decimal    init 0
field   Free-Qnty      as  decimal         init 0
field   Free-CostSum   as  decimal         init 0
field   Free-SaleSum   as  decimal         init 0
field   Res-Qnty       as  decimal         init 0
field   Res-CostSum    as  decimal         init 0
field   Res-DocSum     as  decimal         init 0
field   Res-SaleSum    as  decimal         init 0
field   Res-DiscntSum  as  decimal         init 0
field  InExt-Qnty           as  decimal    init 0
field  InExt-CostSum        as  decimal    init 0
field  RetPost-Qnty         as  decimal    init 0
field  RetPost-CostSum      as  decimal    init 0
field  OutExt-Qnty          as  decimal    init 0
field  OutExt-CostSum       as  decimal    init 0
field  OutExt-SaleSum       as  decimal    init 0
field  OutExt-DiscntSum     as  decimal    init 0
field  RetOut-Qnty          as  decimal    init 0
field  RetOut-CostSum       as  decimal    init 0
field  RetOut-SaleSum       as  decimal    init 0
field  RetOut-DiscntSum     as  decimal    init 0
field  OutExtKass-Qnty      as  decimal    init 0
field  OutExtKass-CostSum   as  decimal    init 0
field  OutExtKass-SaleSum   as  decimal    init 0
field  OutExtKass-DiscntSum as  decimal    init 0
field  RetOutKass-Qnty      as  decimal    init 0
field  RetOutKass-CostSum   as  decimal    init 0
field  RetOutKass-SaleSum   as  decimal    init 0
field  RetOutKass-DiscntSum as  decimal    init 0
field  InInt-Qnty           as  decimal    init 0
field  InInt-CostSum        as  decimal    init 0
field  InInt-SaleSum        as  decimal    init 0
field  OutInt-Qnty          as  decimal    init 0
field  OutInt-CostSum       as  decimal    init 0
field  OutInt-SaleSum       as  decimal    init 0
field  RetInt-Qnty          as  decimal    init 0
field  RetInt-CostSum       as  decimal    init 0
field  RetInt-SaleSum       as  decimal    init 0
field  Inv-Qnty             as  decimal    init 0
field  Inv-CostSum          as  decimal    init 0
field  Inv-SaleSum          as  decimal    init 0
field  Spi-Qnty             as  decimal    init 0
field  Spi-CostSum          as  decimal    init 0
field  Spi-SaleSum          as  decimal    init 0
field  InProiz-Qnty         as  decimal    init 0
field  InProiz-CostSum      as  decimal    init 0
field  InProiz-SaleSum      as  decimal    init 0
field  OutProiz-Qnty        as  decimal    init 0
field  OutProiz-CostSum     as  decimal    init 0
field  OutProiz-SaleSum     as  decimal    init 0
field  Per-SaleSum          as  decimal    init 0
field  Effect-Value         as  decimal    init 0
field  Alt-RestEnd-Qnty     as  decimal    init 0
field  Avrg-Sale-Price      as  decimal    init 0
field  Last-Sale-Price      as  decimal    init 0
field  Cost-Price           as  decimal    init 0
field  Up-Plan              as  decimal    init 0
field  Up-Fact              as  decimal    init 0
field  LastPer-Date         as  date
field  LastPer-Num          as  character
field   price-prodwithvat    as  decimal    init 0
field   prod-vat             as  decimal    init 0
field   prod-vat-prc         as  decimal    init 0
field   price-supp           as  decimal    init 0
field   price-suppvat        as  decimal    init 0
field   suppvat              as  decimal    init 0
field   suppvat-prc          as  decimal    init 0
field   dis-1                as  decimal    init 0
field   dis-1-prc            as  decimal    init 0
field   prod-crsa            as  decimal    init 0
field   prod-crsavat         as  decimal    init 0
field   vat-crsa             as  decimal    init 0
field   vat-crsa-prc         as  decimal    init 0
field   dis-2                as  decimal    init 0
field   dis-2-prc            as  decimal    init 0
field   dis-3                as  decimal    init 0
field   dis-3-prc            as  decimal    init 0
field   dis-2vat             as  decimal    init 0
field   dis-2-prcvat         as  decimal    init 0
field   dis-3vat             as  decimal    init 0
field   dis-3-prcvat         as  decimal    init 0
field   prc_supp            as  decimal    init 0
index pii
  artic
  prod-type
  prod-code
  obj-type
  obj-code
.
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
def var vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define temp-table tt-allsum-line      no-undo
field sum-type           as   character
field fact-qnty          like ub.doc-line.fact-qnty
field cli-qnty           like ub.doc-line.cli-qnty
field sum-dsc-base-doc   like ub.doc-line.price-base
field sum-dsc-rubl-doc   like ub.doc-line.price-base
field dsc-base-doc       like ub.doc-line.price-base
field dsc-rubl-doc       like ub.doc-line.price-base
field vat-base-doc       like ub.doc-line.price-base
field vat-rubl-doc       like ub.doc-line.price-base
field vat-base-buyer-doc like ub.doc-line.price-base
field vat-rubl-buyer-doc like ub.doc-line.price-base
field slt-base-doc       like ub.doc-line.price-base
field slt-rubl-doc       like ub.doc-line.price-base
field road-tax-base-doc  like ub.doc-line.price-base
field road-tax-rubl-doc  like ub.doc-line.price-base
field excise-base-doc    like ub.doc-line.price-base
field excise-rubl-doc    like ub.doc-line.price-base
field sum-dsc-base-acc   like ub.doc-line.price-base
field sum-dsc-rubl-acc   like ub.doc-line.price-base
field sum-dsc-cli-acc    like ub.doc-line.price-cli
field dsc-base-acc       like ub.doc-line.price-base
field dsc-rubl-acc       like ub.doc-line.price-base
field dsc-cli-acc        like ub.doc-line.price-cli
field vat-base-acc       like ub.doc-line.price-base
field vat-rubl-acc       like ub.doc-line.price-base
field vat-cli-acc        like ub.doc-line.price-cli
field slt-base-acc       like ub.doc-line.price-base
field slt-rubl-acc       like ub.doc-line.price-base
field slt-cli-acc        like ub.doc-line.price-cli
field road-tax-base-acc  like ub.doc-line.price-base
field road-tax-rubl-acc  like ub.doc-line.price-base
field road-tax-cli-acc   like ub.doc-line.price-cli
field excise-base-acc    like ub.doc-line.price-base
field excise-rubl-acc    like ub.doc-line.price-base
field excise-cli-acc     like ub.doc-line.price-cli
field transport-base-acc like ub.doc-line.price-base
field transport-rubl-acc like ub.doc-line.price-base
field transport-cli-acc  like ub.doc-line.price-cli
field other-base-acc     like ub.doc-line.price-base
field other-rubl-acc     like ub.doc-line.price-base
field other-cli-acc      like ub.doc-line.price-cli
field sum-dsc-base-cur   like ub.doc-line.price-base
field sum-dsc-rubl-cur   like ub.doc-line.price-base
field dsc-base-cur       like ub.doc-line.price-base
field dsc-rubl-cur       like ub.doc-line.price-base
field vat-base-cur       like ub.doc-line.price-base
field vat-rubl-cur       like ub.doc-line.price-base
field vat-base-buyer-cur like ub.doc-line.price-base
field vat-rubl-buyer-cur like ub.doc-line.price-base
field slt-base-cur       like ub.doc-line.price-base
field slt-rubl-cur       like ub.doc-line.price-base
field road-tax-base-cur  like ub.doc-line.price-base
field road-tax-rubl-cur  like ub.doc-line.price-base
field excise-base-cur    like ub.doc-line.price-base
field excise-rubl-cur    like ub.doc-line.price-base
index sum-type is primary unique sum-type.
.
define temp-table tt-allsum no-undo
field sum-type           as   character
field fact-qnty             as decimal
field cli-qnty              as decimal
field sum-dsc-base-doc      as decimal
field sum-dsc-rubl-doc      as decimal
field dsc-base-doc          as decimal
field dsc-rubl-doc          as decimal
field vat-base-doc          as decimal
field vat-rubl-doc          as decimal
field vat-base-buyer-doc    as decimal
field vat-rubl-buyer-doc    as decimal
field slt-base-doc          as decimal
field slt-rubl-doc          as decimal
field road-tax-base-doc     as decimal
field road-tax-rubl-doc     as decimal
field excise-base-doc       as decimal
field excise-rubl-doc       as decimal
field sum-dsc-base-acc      as decimal
field sum-dsc-rubl-acc      as decimal
field sum-dsc-cli-acc       as decimal
field dsc-base-acc          as decimal
field dsc-rubl-acc          as decimal
field dsc-cli-acc           as decimal
field vat-base-acc          as decimal
field vat-rubl-acc          as decimal
field vat-cli-acc           as decimal
field slt-base-acc          as decimal
field slt-rubl-acc          as decimal
field slt-cli-acc           as decimal
field road-tax-base-acc     as decimal
field road-tax-rubl-acc     as decimal
field road-tax-cli-acc      as decimal
field excise-base-acc       as decimal
field excise-rubl-acc       as decimal
field excise-cli-acc        as decimal
field transport-base-acc    as decimal
field transport-rubl-acc    as decimal
field transport-cli-acc     as decimal
field other-base-acc        as decimal
field other-rubl-acc        as decimal
field other-cli-acc         as decimal
field sum-dsc-base-cur      as decimal
field sum-dsc-rubl-cur      as decimal
field dsc-base-cur          as decimal
field dsc-rubl-cur          as decimal
field vat-base-cur          as decimal
field vat-rubl-cur          as decimal
field vat-base-buyer-cur    as decimal
field vat-rubl-buyer-cur    as decimal
field slt-base-cur          as decimal
field slt-rubl-cur          as decimal
field road-tax-base-cur     as decimal
field road-tax-rubl-cur     as decimal
field excise-base-cur       as decimal
field excise-rubl-cur       as decimal
index sum-type is primary unique sum-type.
define temp-table tt-clcparts no-undo like ub.parts
field part-cur-base like ub.gds-dtl.price-base
field part-cur-road-tax like ub.gds-dtl.price-base
field part-cur-excise like ub.gds-dtl.price-base
.
define variable v-calcbypart as log no-undo.
procedure clcprtsl_calc-parts :
define input parameter parrec-parts        as   recid                   no-undo.
define input parameter paris-doc           as   logical                 no-undo.
define input parameter paris-cur           as   logical                 no-undo.
define input parameter parroad-tax         like ub.doc-line.road-tax    no-undo.
define input parameter parexcise           like ub.doc-line.excise      no-undo.
define input parameter parvat-pc           like ub.doc-line.vat-pc      no-undo.
define input parameter parcons-vat-pc      like ub.doc-line.cons-vat-pc no-undo.
define input parameter parslt-pc           like ub.doc-line.slt-pc      no-undo.
define input parameter parbase-rate        like ub.trn-doc.base-rate    no-undo.
define input parameter parbase-scale       like ub.trn-doc.base-scale   no-undo.
define input parameter parr-b              as   character               no-undo.
define input parameter parcur-base         like ub.gds-dtl.cur-base     no-undo.
define input parameter parcurroad-tax      like ub.doc-line.road-tax    no-undo.
define input parameter parcurexcise        like ub.doc-line.excise      no-undo.
define input parameter parcurvat-pc        like ub.doc-line.vat-pc      no-undo.
define input parameter parcurcons-vat-pc   like ub.doc-line.cons-vat-pc no-undo.
define input parameter parcurslt-pc        like ub.doc-line.slt-pc      no-undo.
define variable parartic        like ub.parts.artic         no-undo.
define variable parprod-type    like ub.parts.prod-type     no-undo.
define variable parprod-code    like ub.parts.prod-code     no-undo.
define variable pardoc-type     like ub.parts.doc-type      no-undo.
define variable pardoc-code     like ub.parts.out-code      no-undo.
define variable parobj-type     like ub.parts.obj-type      no-undo.
define variable parobj-code     like ub.parts.obj-code      no-undo.
define variable parprice-base   like ub.gds-dtl.price-base  no-undo.
define variable parprice-rubl   like ub.gds-dtl.price-rubl  no-undo.
define variable pardiscnt-base  like ub.gds-dtl.discnt-base no-undo.
define variable pardiscnt-rubl  like ub.gds-dtl.discnt-rubl no-undo.
define variable parfact-qnty    like ub.parts.fact-qnty     no-undo.
define variable parcli-qnty     like ub.parts.cli-qnty      no-undo.
define variable pardoc-qnty     like ub.parts.qnty          no-undo.
define variable parext-doc-type like ub.trn-doc.ext-doc-type no-undo.
define variable parcurartic        like ub.parts.artic         no-undo.
define variable parcurprod-type    like ub.parts.prod-type     no-undo.
define variable parcurprod-code    like ub.parts.prod-code     no-undo.
define variable parcurdoc-type     like ub.parts.doc-type      no-undo.
define variable parcurdoc-code     like ub.parts.out-code      no-undo.
define variable parcurobj-type     like ub.parts.obj-type      no-undo.
define variable parcurobj-code     like ub.parts.obj-code      no-undo.
define variable parcurprice-base   like ub.gds-dtl.price-base  no-undo.
define variable parcurprice-rubl   like ub.gds-dtl.price-rubl  no-undo.
define variable parcurdiscnt-base  like ub.gds-dtl.discnt-base no-undo.
define variable parcurdiscnt-rubl  like ub.gds-dtl.discnt-rubl no-undo.
define variable parcurfact-qnty    like ub.parts.fact-qnty     no-undo.
define variable parcurcli-qnty     like ub.parts.cli-qnty      no-undo.
define variable parcurdoc-qnty     like ub.parts.qnty          no-undo.
define variable parcurbase-rate    like ub.trn-doc.base-rate   no-undo.
define variable parcurbase-scale   like ub.trn-doc.base-scale  no-undo.
define variable parcurext-doc-type like ub.trn-doc.ext-doc-type no-undo.
define buffer bf_tt-allsum     for tt-allsum.
define buffer bfs_tt-allsum    for tt-allsum.
define buffer bfpc_tt-allsum   for tt-allsum.
define buffer bfspc_tt-allsum  for tt-allsum.
define buffer bfacc_tt-allsum  for tt-allsum.
define buffer bfsacc_tt-allsum for tt-allsum.
define buffer cl_tt-clcparts   for tt-clcparts.
define buffer bf_trn-doc       for ub.trn-doc.
define buffer bf_sysconf       for ub.sysconf.
    define buffer   in-vatp-trn-doccl  for ub.trn-doc .
    define buffer   in-vatp-partscl    for ub.parts   .
    define buffer   in-vatp-doccl      for ub.trn-doc .
    define buffer   in-vatp-goodscl    for ub.goods   .
    define buffer   in-vatp-sysconfcl  for ub.sysconf .
    define buffer   in-vatp_doc-attrcl for ub.doc-attr.
    define variable in-vatp-have-vat-sltcl       as   logical initial yes    no-undo.
    define variable vat-pc-loccl                 like ub.doc-line.vat-pc     no-undo.
    define variable varinvprbcl                  as   character              no-undo.
    define variable slt-pc-loccl                 like ub.doc-line.slt-pc     no-undo.
    define variable cli-base-ratecl              as   decimal                no-undo.
    define variable price-rubl-with-tax-loccl    like ub.doc-line.price-rubl no-undo.
    define variable price-base-with-tax-loccl    like ub.doc-line.price-base no-undo.
    define variable price-cli-with-tax-loccl     like ub.doc-line.price-cli  no-undo.
    define variable price-rubl-without-tax-loccl like ub.doc-line.price-rubl no-undo.
    define variable price-base-without-tax-loccl like ub.doc-line.price-base no-undo.
    define variable price-cli-without-tax-loccl  like ub.doc-line.price-base no-undo.
    define variable vat-base-loccl               like ub.doc-line.price-base no-undo.
    define variable vat-rubl-loccl               like ub.doc-line.price-rubl no-undo.
    define variable vat-cli-loccl                like ub.doc-line.price-rubl no-undo.
    define variable slt-base-loccl               like ub.doc-line.price-base no-undo.
    define variable slt-rubl-loccl               like ub.doc-line.price-rubl no-undo.
    define variable slt-cli-loccl                like ub.doc-line.price-rubl no-undo.
    define variable road-tax-base-loccl          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-rubl-loccl          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-cli-loccl           like ub.doc-line.road-tax   no-undo.
    define variable transport-base-loccl         like ub.doc-line.price-base no-undo.
    define variable transport-rubl-loccl         like ub.doc-line.price-rubl no-undo.
    define variable transport-cli-loccl          like ub.doc-line.price-rubl no-undo.
    define variable other-base-loccl             like ub.doc-line.price-base no-undo.
    define variable other-rubl-loccl             like ub.doc-line.price-rubl no-undo.
    define variable other-cli-loccl              like ub.doc-line.price-rubl no-undo.
    define variable exch-rate-cli-loccl          like ub.trn-doc.exch-rate   no-undo.
    define variable varinvatp-envdcl             as   character              no-undo.
    define variable varinvatp-typecl             as   character              no-undo.
    define  variable price-rubl-with-tax-salecl    like ub.doc-line.price-rubl no-undo.
    define  variable price-base-with-tax-salecl    like ub.doc-line.price-base no-undo.
    define  variable price-rubl-without-tax-salecl like ub.doc-line.price-rubl no-undo.
    define  variable price-base-without-tax-salecl like ub.doc-line.price-base no-undo.
    define  variable vat-base-salecl               like ub.doc-line.price-base no-undo.
    define  variable vat-rubl-salecl               like ub.doc-line.price-rubl no-undo.
    define  variable vat-base-buyercl              like ub.doc-line.price-base no-undo.
    define  variable vat-rubl-buyercl              like ub.doc-line.price-rubl no-undo.
    define  variable slt-base-salecl               like ub.doc-line.price-base no-undo.
    define  variable slt-rubl-salecl               like ub.doc-line.price-rubl no-undo.
    define  variable road-tax-base-salecl          like ub.doc-line.road-tax   no-undo.
    define  variable road-tax-rubl-salecl          like ub.doc-line.road-tax   no-undo.
    define  variable excise-base-salecl            like ub.doc-line.price-base no-undo.
    define  variable excise-rubl-salecl            like ub.doc-line.price-rubl no-undo.
    define  variable discnt-base-salecl            like ub.gds-dtl.discnt-base no-undo.
    define  variable discnt-rubl-salecl            like ub.gds-dtl.discnt-rubl no-undo.
    define buffer out-vatp_gds-dtlcl     for ub.gds-dtl.
    define buffer buf_out-vatp_gds-dtlcl for ub.gds-dtl.
    define buffer out-vatp_partscl       for ub.parts.
    define buffer out-vatp_sysconfcl     for ub.sysconf.
    define buffer out-vatp_doc-linecl    for ub.doc-line.
    define buffer out-vatp_goodscl       for ub.goods.
    define buffer out-vatp_trn-doccl     for ub.trn-doc.
    define buffer out-vatp_doc-attrcl    for ub.doc-attr.
    define variable varprice-base-conscl      like ub.doc-line.price-base initial 0.00 no-undo.
    define variable varprice-rubl-conscl      like ub.doc-line.price-rubl initial 0.00 no-undo.
    define variable varfrm-cnsv-typecl         as   character                           no-undo.
    define variable varfrm-cnsvcl              as   character                           no-undo.
    define variable varroot-nodecl             as   integer                             no-undo.
    define variable varempty-scalecl           as   logical                             no-undo.
    define variable varis-cons-parts-havecl    as   logical                             no-undo.
    define variable varsum-base-factovpcl      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-factovpcl      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-factovpcl      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-factovpcl  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-factovpcl      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-base-docovpcl       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-docovpcl       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-docovpcl       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-docovpcl   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-docovpcl       like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-factovpcl      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-factovpcl      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-factovpcl      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-factovpcl  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-factovpcl      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-docovpcl       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-docovpcl       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-docovpcl       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-docovpcl   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-docovpcl       like ub.gds-dtl.price-base               no-undo.
    define variable varfact-qntycl             like ub.parts.fact-qnty                  no-undo.
    define variable varcons-qntycl             like ub.parts.fact-qnty                  no-undo.
    define variable varis-one-gds-dtlcl        as   logical                             no-undo.
    define variable varcurclprice-base         like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurclprice-rubl         like ub.gds-dtl.price-base               no-undo.
    define variable varcurcldiscnt-base        like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurcldiscnt-rubl        like ub.gds-dtl.price-base               no-undo.
    define variable varoutvprbcl               as   character                           no-undo.
    define variable out-vatp-have-vat-sltcl    as   logical initial yes                 no-undo.
    define buffer   in-vatp-trn-dococl  for ub.trn-doc .
    define buffer   in-vatp-partsocl    for ub.parts   .
    define buffer   in-vatp-dococl      for ub.trn-doc .
    define buffer   in-vatp-goodsocl    for ub.goods   .
    define buffer   in-vatp-sysconfocl  for ub.sysconf .
    define buffer   in-vatp_doc-attrocl for ub.doc-attr.
    define variable in-vatp-have-vat-sltocl       as   logical initial yes    no-undo.
    define variable vat-pc-lococl                 like ub.doc-line.vat-pc     no-undo.
    define variable varinvprbocl                  as   character              no-undo.
    define variable slt-pc-lococl                 like ub.doc-line.slt-pc     no-undo.
    define variable cli-base-rateocl              as   decimal                no-undo.
    define variable price-rubl-with-tax-lococl    like ub.doc-line.price-rubl no-undo.
    define variable price-base-with-tax-lococl    like ub.doc-line.price-base no-undo.
    define variable price-cli-with-tax-lococl     like ub.doc-line.price-cli  no-undo.
    define variable price-rubl-without-tax-lococl like ub.doc-line.price-rubl no-undo.
    define variable price-base-without-tax-lococl like ub.doc-line.price-base no-undo.
    define variable price-cli-without-tax-lococl  like ub.doc-line.price-base no-undo.
    define variable vat-base-lococl               like ub.doc-line.price-base no-undo.
    define variable vat-rubl-lococl               like ub.doc-line.price-rubl no-undo.
    define variable vat-cli-lococl                like ub.doc-line.price-rubl no-undo.
    define variable slt-base-lococl               like ub.doc-line.price-base no-undo.
    define variable slt-rubl-lococl               like ub.doc-line.price-rubl no-undo.
    define variable slt-cli-lococl                like ub.doc-line.price-rubl no-undo.
    define variable road-tax-base-lococl          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-rubl-lococl          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-cli-lococl           like ub.doc-line.road-tax   no-undo.
    define variable transport-base-lococl         like ub.doc-line.price-base no-undo.
    define variable transport-rubl-lococl         like ub.doc-line.price-rubl no-undo.
    define variable transport-cli-lococl          like ub.doc-line.price-rubl no-undo.
    define variable other-base-lococl             like ub.doc-line.price-base no-undo.
    define variable other-rubl-lococl             like ub.doc-line.price-rubl no-undo.
    define variable other-cli-lococl              like ub.doc-line.price-rubl no-undo.
    define variable exch-rate-cli-lococl          like ub.trn-doc.exch-rate   no-undo.
    define variable varinvatp-envdocl             as   character              no-undo.
    define variable varinvatp-typeocl             as   character              no-undo.
    define  variable price-rubl-with-tax-salecur    like ub.doc-line.price-rubl no-undo.
    define  variable price-base-with-tax-salecur    like ub.doc-line.price-base no-undo.
    define  variable price-rubl-without-tax-salecur like ub.doc-line.price-rubl no-undo.
    define  variable price-base-without-tax-salecur like ub.doc-line.price-base no-undo.
    define  variable vat-base-salecur               like ub.doc-line.price-base no-undo.
    define  variable vat-rubl-salecur               like ub.doc-line.price-rubl no-undo.
    define  variable vat-base-buyercur              like ub.doc-line.price-base no-undo.
    define  variable vat-rubl-buyercur              like ub.doc-line.price-rubl no-undo.
    define  variable slt-base-salecur               like ub.doc-line.price-base no-undo.
    define  variable slt-rubl-salecur               like ub.doc-line.price-rubl no-undo.
    define  variable road-tax-base-salecur          like ub.doc-line.road-tax   no-undo.
    define  variable road-tax-rubl-salecur          like ub.doc-line.road-tax   no-undo.
    define  variable excise-base-salecur            like ub.doc-line.price-base no-undo.
    define  variable excise-rubl-salecur            like ub.doc-line.price-rubl no-undo.
    define  variable discnt-base-salecur            like ub.gds-dtl.discnt-base no-undo.
    define  variable discnt-rubl-salecur            like ub.gds-dtl.discnt-rubl no-undo.
    define buffer out-vatp_gds-dtlcur     for ub.gds-dtl.
    define buffer buf_out-vatp_gds-dtlcur for ub.gds-dtl.
    define buffer out-vatp_partscur       for ub.parts.
    define buffer out-vatp_sysconfcur     for ub.sysconf.
    define buffer out-vatp_doc-linecur    for ub.doc-line.
    define buffer out-vatp_goodscur       for ub.goods.
    define buffer out-vatp_trn-doccur     for ub.trn-doc.
    define buffer out-vatp_doc-attrcur    for ub.doc-attr.
    define variable varprice-base-conscur      like ub.doc-line.price-base initial 0.00 no-undo.
    define variable varprice-rubl-conscur      like ub.doc-line.price-rubl initial 0.00 no-undo.
    define variable varfrm-cnsv-typecur         as   character                           no-undo.
    define variable varfrm-cnsvcur              as   character                           no-undo.
    define variable varroot-nodecur             as   integer                             no-undo.
    define variable varempty-scalecur           as   logical                             no-undo.
    define variable varis-cons-parts-havecur    as   logical                             no-undo.
    define variable varsum-base-factovpcur      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-factovpcur      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-factovpcur      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-factovpcur  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-factovpcur      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-base-docovpcur       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-docovpcur       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-docovpcur       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-docovpcur   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-docovpcur       like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-factovpcur      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-factovpcur      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-factovpcur      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-factovpcur  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-factovpcur      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-docovpcur       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-docovpcur       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-docovpcur       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-docovpcur   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-docovpcur       like ub.gds-dtl.price-base               no-undo.
    define variable varfact-qntycur             like ub.parts.fact-qnty                  no-undo.
    define variable varcons-qntycur             like ub.parts.fact-qnty                  no-undo.
    define variable varis-one-gds-dtlcur        as   logical                             no-undo.
    define variable varcurcurprice-base         like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurcurprice-rubl         like ub.gds-dtl.price-base               no-undo.
    define variable varcurcurdiscnt-base        like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurcurdiscnt-rubl        like ub.gds-dtl.price-base               no-undo.
    define variable varoutvprbcur               as   character                           no-undo.
    define variable out-vatp-have-vat-sltcur    as   logical initial yes                 no-undo.
    define buffer   in-vatp-trn-dococur  for ub.trn-doc .
    define buffer   in-vatp-partsocur    for ub.parts   .
    define buffer   in-vatp-dococur      for ub.trn-doc .
    define buffer   in-vatp-goodsocur    for ub.goods   .
    define buffer   in-vatp-sysconfocur  for ub.sysconf .
    define buffer   in-vatp_doc-attrocur for ub.doc-attr.
    define variable in-vatp-have-vat-sltocur       as   logical initial yes    no-undo.
    define variable vat-pc-lococur                 like ub.doc-line.vat-pc     no-undo.
    define variable varinvprbocur                  as   character              no-undo.
    define variable slt-pc-lococur                 like ub.doc-line.slt-pc     no-undo.
    define variable cli-base-rateocur              as   decimal                no-undo.
    define variable price-rubl-with-tax-lococur    like ub.doc-line.price-rubl no-undo.
    define variable price-base-with-tax-lococur    like ub.doc-line.price-base no-undo.
    define variable price-cli-with-tax-lococur     like ub.doc-line.price-cli  no-undo.
    define variable price-rubl-without-tax-lococur like ub.doc-line.price-rubl no-undo.
    define variable price-base-without-tax-lococur like ub.doc-line.price-base no-undo.
    define variable price-cli-without-tax-lococur  like ub.doc-line.price-base no-undo.
    define variable vat-base-lococur               like ub.doc-line.price-base no-undo.
    define variable vat-rubl-lococur               like ub.doc-line.price-rubl no-undo.
    define variable vat-cli-lococur                like ub.doc-line.price-rubl no-undo.
    define variable slt-base-lococur               like ub.doc-line.price-base no-undo.
    define variable slt-rubl-lococur               like ub.doc-line.price-rubl no-undo.
    define variable slt-cli-lococur                like ub.doc-line.price-rubl no-undo.
    define variable road-tax-base-lococur          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-rubl-lococur          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-cli-lococur           like ub.doc-line.road-tax   no-undo.
    define variable transport-base-lococur         like ub.doc-line.price-base no-undo.
    define variable transport-rubl-lococur         like ub.doc-line.price-rubl no-undo.
    define variable transport-cli-lococur          like ub.doc-line.price-rubl no-undo.
    define variable other-base-lococur             like ub.doc-line.price-base no-undo.
    define variable other-rubl-lococur             like ub.doc-line.price-rubl no-undo.
    define variable other-cli-lococur              like ub.doc-line.price-rubl no-undo.
    define variable exch-rate-cli-lococur          like ub.trn-doc.exch-rate   no-undo.
    define variable varinvatp-envdocur             as   character              no-undo.
    define variable varinvatp-typeocur             as   character              no-undo.
do on error undo, return error return-value :
find first cl_tt-clcparts where recid(cl_tt-clcparts) = parrec-parts no-lock.
for each bf_tt-allsum on error undo, return error return-value :
  delete bf_tt-allsum.
end.
assign
  price-rubl-with-tax-loccl = cl_tt-clcparts.price-rubl
  price-base-with-tax-loccl = cl_tt-clcparts.price-base
.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprbcl
  )  .
  if cl_tt-clcparts.out-code = 'free-zone':U     or
     cl_tt-clcparts.out-code = 'out-zone':U   or
     cl_tt-clcparts.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-sltcl = yes.
  end.
  else do:
    find first in-vatp_doc-attrcl no-lock
      where in-vatp_doc-attrcl.doc-code  = cl_tt-clcparts.out-code
        and in-vatp_doc-attrcl.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attrcl then do:
      assign
        in-vatp-have-vat-sltcl = yes.
    end.
    else do:
         in-vatp-have-vat-sltcl = no.
    end.
  end.
  assign
   price-cli-with-tax-loccl = cl_tt-clcparts.price-cli
   cli-base-ratecl          = cl_tt-clcparts.cli-base-rate.
  ASSIGN   road-tax-base-loccl  = (if cl_tt-clcparts.road-tax-base  = ? then 0 else cl_tt-clcparts.road-tax-base)
           road-tax-rubl-loccl  = (if cl_tt-clcparts.road-tax-rubl  = ? then 0 else cl_tt-clcparts.road-tax-rubl).
  ASSIGN  transport-base-loccl = (if cl_tt-clcparts.transport-base = ? then 0 else cl_tt-clcparts.transport-base)
          transport-rubl-loccl = (if cl_tt-clcparts.transport-rubl = ? then 0 else cl_tt-clcparts.transport-rubl)
          other-base-loccl     = (if cl_tt-clcparts.other-base     = ? then 0 else cl_tt-clcparts.other-base)
          other-rubl-loccl     = (if cl_tt-clcparts.other-rubl     = ? then 0 else cl_tt-clcparts.other-rubl)
          vat-pc-loccl         = (if cl_tt-clcparts.vat-pc         = ? then 0 else cl_tt-clcparts.vat-pc)
          slt-pc-loccl         = (if cl_tt-clcparts.slt-pc         = ? then 0 else cl_tt-clcparts.slt-pc).
          ASSIGN   slt-base-loccl    = (if in-vatp-have-vat-sltcl = no then 0 else (price-base-with-tax-loccl - ((if road-tax-base-loccl  = ? then 0 else road-tax-base-loccl) + (if transport-base-loccl = ? then 0 else transport-base-loccl) + (if other-base-loccl = ? then 0 else other-base-loccl)))                           * slt-pc-loccl / (100 + slt-pc-loccl))                        vat-base-loccl    = (if in-vatp-have-vat-sltcl = no then 0 else (price-base-with-tax-loccl - ((if road-tax-base-loccl  = ? then 0 else road-tax-base-loccl) + (if transport-base-loccl = ? then 0 else transport-base-loccl) + (if other-base-loccl = ? then 0 else other-base-loccl))) * (1 - slt-pc-loccl / (100 + slt-pc-loccl)) * vat-pc-loccl / (100 + vat-pc-loccl)).
    ASSIGN   slt-rubl-loccl    = (if in-vatp-have-vat-sltcl = no then 0 else (price-rubl-with-tax-loccl - ((if road-tax-rubl-loccl  = ? then 0 else road-tax-rubl-loccl) + (if transport-rubl-loccl = ? then 0 else transport-rubl-loccl) + (if other-rubl-loccl = ? then 0 else other-rubl-loccl)))                           * slt-pc-loccl / (100 + slt-pc-loccl))                        vat-rubl-loccl    = (if in-vatp-have-vat-sltcl = no then 0 else (price-rubl-with-tax-loccl - ((if road-tax-rubl-loccl  = ? then 0 else road-tax-rubl-loccl) + (if transport-rubl-loccl = ? then 0 else transport-rubl-loccl) + (if other-rubl-loccl = ? then 0 else other-rubl-loccl))) * (1 - slt-pc-loccl / (100 + slt-pc-loccl)) * vat-pc-loccl / (100 + vat-pc-loccl)).
  assign
    exch-rate-cli-loccl = (cl_tt-clcparts.price-rubl - transport-rubl-loccl - other-rubl-loccl - road-tax-rubl-loccl - (if cl_tt-clcparts.vat-type <> 'в т. ч.':U then vat-rubl-loccl else 0) - (if cl_tt-clcparts.slt-type <> 'в т. ч.':U then slt-rubl-loccl else 0)) / cl_tt-clcparts.price-cli .
  assign
    slt-cli-loccl        = slt-rubl-loccl       / exch-rate-cli-loccl
    vat-cli-loccl        = vat-rubl-loccl       / exch-rate-cli-loccl
    road-tax-cli-loccl   = road-tax-rubl-loccl  / exch-rate-cli-loccl
    transport-cli-loccl  = 0
    other-cli-loccl      = 0
  .
ASSIGN
          price-base-without-tax-loccl = price-base-with-tax-loccl - vat-base-loccl - slt-base-loccl - ((if road-tax-base-loccl  = ? then 0 else road-tax-base-loccl) + (if transport-base-loccl = ? then 0 else transport-base-loccl) + (if other-base-loccl = ? then 0 else other-base-loccl))
    price-rubl-without-tax-loccl = price-rubl-with-tax-loccl - vat-rubl-loccl - slt-rubl-loccl - ((if road-tax-rubl-loccl  = ? then 0 else road-tax-rubl-loccl) + (if transport-rubl-loccl = ? then 0 else transport-rubl-loccl) + (if other-rubl-loccl = ? then 0 else other-rubl-loccl))
.
if paris-doc then do:
  assign
    parartic     = cl_tt-clcparts.artic
    parprod-type = cl_tt-clcparts.prod-type
    parprod-code = cl_tt-clcparts.prod-code
    pardoc-type  = cl_tt-clcparts.doc-type
    pardoc-code  = cl_tt-clcparts.out-code
    parobj-type  = cl_tt-clcparts.obj-type
    parobj-code  = cl_tt-clcparts.obj-code.
if parext-doc-type = 'ot':U or
   parext-doc-type = ?                 then do:
  assign
   out-vatp-have-vat-sltcl = yes.
end.
else do:
  find first out-vatp_doc-attrcl no-lock
    where out-vatp_doc-attrcl.doc-code  = pardoc-code
      and out-vatp_doc-attrcl.attr-code = 'envd':U
      no-error .
  if not available out-vatp_doc-attrcl then do:
    assign
      out-vatp-have-vat-sltcl = yes.
  end.
  else do:
     out-vatp-have-vat-sltcl = no.
  end.
end.
find first out-vatp_goodscl where out-vatp_goodscl.artic     = parartic     and
                                   out-vatp_goodscl.prod-type = parprod-type and
                                   out-vatp_goodscl.prod-code = parprod-code no-lock.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  parartic
  ,input  parprod-type
  ,input  parprod-code
  ,output varroot-nodecl
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении корневого признака товара" skip
    "Артикул" parartic parprod-type parprod-code skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtat in g#library
  (input  varroot-nodecl
  ,input  'empty-scale=request'
  ,output varempty-scalecl
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении атрибута признака" skip
    "Артикул" parartic parprod-type parprod-code skip
    "Признак" varroot-nodecl skip
    "Запрашивался атрибут" "empty-scale=request" skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varoutvprbcl
  )  .
if varoutvprbcl = "base":u then do:
  assign
        road-tax-base-salecl    =  (if parroad-tax = ? then 0 else parroad-tax * 1)
    excise-base-salecl      =  (if parexcise   = ? then 0 else parexcise   * 1)
  .
end.
else do:
  assign
        road-tax-base-salecl    =  (if parroad-tax = ? then 0 else parroad-tax / parbase-rate * parbase-scale)
    excise-base-salecl      =  (if parexcise   = ? then 0 else parexcise   / parbase-rate * parbase-scale)
  .
end.
if varoutvprbcl = "rubl":u then do:
  assign
        road-tax-rubl-salecl    = (if parroad-tax = ? then 0 else parroad-tax * 1)
    excise-rubl-salecl      = (if parexcise   = ? then 0 else parexcise   * 1) .
end.
else do:
  assign
        road-tax-rubl-salecl    = (if parroad-tax = ? then 0 else parroad-tax * parbase-rate / parbase-scale)
    excise-rubl-salecl      = (if parexcise   = ? then 0 else parexcise   * parbase-rate / parbase-scale) .
end.
assign
  varis-cons-parts-havecl =  no.
assign
  varfact-qntycl       = 0
  varcons-qntycl       = 0
  varprice-base-conscl = 0
  varprice-rubl-conscl = 0.
find first out-vatp_doc-linecl where
           out-vatp_doc-linecl.doc-code   = pardoc-code
       and out-vatp_doc-linecl.artic      = parartic
       and out-vatp_doc-linecl.prod-type  = parprod-type
       and out-vatp_doc-linecl.prod-code  = parprod-code no-lock no-error.
if available out-vatp_doc-linecl           and
  (out-vatp_doc-linecl.status_ = 'запрос':U or out-vatp_goodscl.gds-type = 'у':U) then do:
  assign
    varfact-qntycl = out-vatp_doc-linecl.fact-qnty.
end.
else do:
  for each out-vatp_partscl where out-vatp_partscl.out-code   = pardoc-code
                               and out-vatp_partscl.obj-type   = parobj-type
                               and out-vatp_partscl.obj-code   = parobj-code
                               and out-vatp_partscl.artic      = parartic
                               and out-vatp_partscl.prod-type  = parprod-type
                               and out-vatp_partscl.prod-code  = parprod-code no-lock :
    if out-vatp_partscl.purch-code = 2 then do:
assign
  price-rubl-with-tax-lococl = out-vatp_partscl.price-rubl
  price-base-with-tax-lococl = out-vatp_partscl.price-base
.
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprbocl
  )  .
  if out-vatp_partscl.out-code = 'free-zone':U     or
     out-vatp_partscl.out-code = 'out-zone':U   or
     out-vatp_partscl.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-sltocl = yes.
  end.
  else do:
    find first in-vatp_doc-attrocl no-lock
      where in-vatp_doc-attrocl.doc-code  = out-vatp_partscl.out-code
        and in-vatp_doc-attrocl.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attrocl then do:
      assign
        in-vatp-have-vat-sltocl = yes.
    end.
    else do:
         in-vatp-have-vat-sltocl = no.
    end.
  end.
  assign
   price-cli-with-tax-lococl = out-vatp_partscl.price-cli
   cli-base-rateocl          = out-vatp_partscl.cli-base-rate.
  ASSIGN   road-tax-base-lococl  = (if out-vatp_partscl.road-tax-base  = ? then 0 else out-vatp_partscl.road-tax-base)
           road-tax-rubl-lococl  = (if out-vatp_partscl.road-tax-rubl  = ? then 0 else out-vatp_partscl.road-tax-rubl).
  ASSIGN  transport-base-lococl = (if out-vatp_partscl.transport-base = ? then 0 else out-vatp_partscl.transport-base)
          transport-rubl-lococl = (if out-vatp_partscl.transport-rubl = ? then 0 else out-vatp_partscl.transport-rubl)
          other-base-lococl     = (if out-vatp_partscl.other-base     = ? then 0 else out-vatp_partscl.other-base)
          other-rubl-lococl     = (if out-vatp_partscl.other-rubl     = ? then 0 else out-vatp_partscl.other-rubl)
          vat-pc-lococl         = (if out-vatp_partscl.vat-pc         = ? then 0 else out-vatp_partscl.vat-pc)
          slt-pc-lococl         = (if out-vatp_partscl.slt-pc         = ? then 0 else out-vatp_partscl.slt-pc).
          ASSIGN   slt-base-lococl    = (if in-vatp-have-vat-sltocl = no then 0 else (price-base-with-tax-lococl - ((if road-tax-base-lococl  = ? then 0 else road-tax-base-lococl) + (if transport-base-lococl = ? then 0 else transport-base-lococl) + (if other-base-lococl = ? then 0 else other-base-lococl)))                           * slt-pc-lococl / (100 + slt-pc-lococl))                        vat-base-lococl    = (if in-vatp-have-vat-sltocl = no then 0 else (price-base-with-tax-lococl - ((if road-tax-base-lococl  = ? then 0 else road-tax-base-lococl) + (if transport-base-lococl = ? then 0 else transport-base-lococl) + (if other-base-lococl = ? then 0 else other-base-lococl))) * (1 - slt-pc-lococl / (100 + slt-pc-lococl)) * vat-pc-lococl / (100 + vat-pc-lococl)).
    ASSIGN   slt-rubl-lococl    = (if in-vatp-have-vat-sltocl = no then 0 else (price-rubl-with-tax-lococl - ((if road-tax-rubl-lococl  = ? then 0 else road-tax-rubl-lococl) + (if transport-rubl-lococl = ? then 0 else transport-rubl-lococl) + (if other-rubl-lococl = ? then 0 else other-rubl-lococl)))                           * slt-pc-lococl / (100 + slt-pc-lococl))                        vat-rubl-lococl    = (if in-vatp-have-vat-sltocl = no then 0 else (price-rubl-with-tax-lococl - ((if road-tax-rubl-lococl  = ? then 0 else road-tax-rubl-lococl) + (if transport-rubl-lococl = ? then 0 else transport-rubl-lococl) + (if other-rubl-lococl = ? then 0 else other-rubl-lococl))) * (1 - slt-pc-lococl / (100 + slt-pc-lococl)) * vat-pc-lococl / (100 + vat-pc-lococl)).
  assign
    exch-rate-cli-lococl = (out-vatp_partscl.price-rubl - transport-rubl-lococl - other-rubl-lococl - road-tax-rubl-lococl - (if out-vatp_partscl.vat-type <> 'в т. ч.':U then vat-rubl-lococl else 0) - (if out-vatp_partscl.slt-type <> 'в т. ч.':U then slt-rubl-lococl else 0)) / out-vatp_partscl.price-cli .
  assign
    slt-cli-lococl        = slt-rubl-lococl       / exch-rate-cli-lococl
    vat-cli-lococl        = vat-rubl-lococl       / exch-rate-cli-lococl
    road-tax-cli-lococl   = road-tax-rubl-lococl  / exch-rate-cli-lococl
    transport-cli-lococl  = 0
    other-cli-lococl      = 0
  .
ASSIGN
          price-base-without-tax-lococl = price-base-with-tax-lococl - vat-base-lococl - slt-base-lococl - ((if road-tax-base-lococl  = ? then 0 else road-tax-base-lococl) + (if transport-base-lococl = ? then 0 else transport-base-lococl) + (if other-base-lococl = ? then 0 else other-base-lococl))
    price-rubl-without-tax-lococl = price-rubl-with-tax-lococl - vat-rubl-lococl - slt-rubl-lococl - ((if road-tax-rubl-lococl  = ? then 0 else road-tax-rubl-lococl) + (if transport-rubl-lococl = ? then 0 else transport-rubl-lococl) + (if other-rubl-lococl = ? then 0 else other-rubl-lococl))
.
      assign
        varprice-base-conscl = varprice-base-conscl + (price-base-with-tax-lococl - (if road-tax-base-lococl = ? then 0 else road-tax-base-lococl))* out-vatp_partscl.fact-qnty
        varprice-rubl-conscl = varprice-rubl-conscl + (price-rubl-with-tax-lococl - (if road-tax-rubl-lococl = ? then 0 else road-tax-rubl-lococl))* out-vatp_partscl.fact-qnty.
      assign
        varis-cons-parts-havecl = yes
        varcons-qntycl          = varcons-qntycl + out-vatp_partscl.fact-qnty.
    end.
    assign
      varfact-qntycl = varfact-qntycl + out-vatp_partscl.fact-qnty.
  end.
end.
assign
  varprice-base-conscl = varprice-base-conscl / varcons-qntycl
  varprice-rubl-conscl = varprice-rubl-conscl / varcons-qntycl.
if varprice-base-conscl = ? then do:
  assign
    varprice-base-conscl = 0.
end.
if varprice-rubl-conscl = ? then do:
  assign
    varprice-rubl-conscl = 0.
end.
assign
  varsum-base-factovpcl     = 0
  varslt-base-factovpcl     = 0
  varvat-base-factovpcl     = 0
  varvatcons-base-factovpcl = 0
  vardsc-base-factovpcl     = 0
  varsum-base-docovpcl      = 0
  varslt-base-docovpcl      = 0
  varvat-base-docovpcl      = 0
  varvatcons-base-docovpcl  = 0
  vardsc-base-docovpcl      = 0
  varsum-rubl-factovpcl     = 0
  varslt-rubl-factovpcl     = 0
  varvat-rubl-factovpcl     = 0
  varvatcons-rubl-factovpcl = 0
  vardsc-rubl-factovpcl     = 0
  varsum-rubl-docovpcl      = 0
  varslt-rubl-docovpcl      = 0
  varvat-rubl-docovpcl      = 0
  varvatcons-rubl-docovpcl  = 0
  vardsc-rubl-docovpcl      = 0.
assign
  varis-one-gds-dtlcl = no.
find first out-vatp_gds-dtlcl where out-vatp_gds-dtlcl.doc-code  = pardoc-code  and
                                     out-vatp_gds-dtlcl.artic     = parartic     and
                                     out-vatp_gds-dtlcl.prod-type = parprod-type and
                                     out-vatp_gds-dtlcl.prod-code = parprod-code no-lock no-error.
if available out-vatp_gds-dtlcl then do:
  find first buf_out-vatp_gds-dtlcl where buf_out-vatp_gds-dtlcl.doc-code  =  pardoc-code                and
                                           buf_out-vatp_gds-dtlcl.artic     =  parartic                   and
                                           buf_out-vatp_gds-dtlcl.prod-type =  parprod-type               and
                                           buf_out-vatp_gds-dtlcl.prod-code =  parprod-code               and
                                           recid(buf_out-vatp_gds-dtlcl)    <> recid(out-vatp_gds-dtlcl) no-lock no-error.
  if not available buf_out-vatp_gds-dtlcl then do:
    assign
      varis-one-gds-dtlcl = yes.
  end.
  if varoutvprbcl = "base":u then do:
    assign
      varcurclprice-base = out-vatp_gds-dtlcl.cur-base
      varcurclprice-rubl = out-vatp_gds-dtlcl.cur-base * ((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) / (out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base)).
  end.
  else do:
    assign
      varcurclprice-base = out-vatp_gds-dtlcl.cur-base / ((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) / (out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base))
      varcurclprice-rubl = out-vatp_gds-dtlcl.cur-base.
  end.
  if varempty-scalecl    = yes or
     varis-one-gds-dtlcl = yes   then do:
    assign
                price-base-with-tax-salecl    = (out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base)
        slt-base-salecl               = (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc)
        vat-base-buyercl              = (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl) * parvat-pc / (100 + parvat-pc)
        discnt-base-salecl            = out-vatp_gds-dtlcl.discnt-base
                price-rubl-with-tax-salecl    = (out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl)
        slt-rubl-salecl               = (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc)
        vat-rubl-buyercl              = (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl) * parvat-pc / (100 + parvat-pc)
        discnt-rubl-salecl            = out-vatp_gds-dtlcl.discnt-rubl
        .
    if pardoc-type = 'инв':U then do:
      ASSIGN
                vat-base-salecl               = (if out-vatp-have-vat-sltcl = no then 0 else (((out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl - varprice-base-conscl) * parcons-vat-pc / (100 + parcons-vat-pc) * out-vatp_gds-dtlcl.doc-qnty * varcons-qntycl / varfact-qntycl + ((out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl) * parvat-pc / (100 + parvat-pc) * out-vatp_gds-dtlcl.doc-qnty * (varfact-qntycl - varcons-qntycl) / varfact-qntycl) / varfact-qntycl)
                vat-rubl-salecl               = (if out-vatp-have-vat-sltcl = no then 0 else (((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl - varprice-rubl-conscl) * parcons-vat-pc / (100 + parcons-vat-pc) * out-vatp_gds-dtlcl.doc-qnty * varcons-qntycl / varfact-qntycl + ((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl) * parvat-pc / (100 + parvat-pc) * out-vatp_gds-dtlcl.doc-qnty * (varfact-qntycl - varcons-qntycl) / varfact-qntycl) / varfact-qntycl)
        .
    end.
    else do:
      ASSIGN
                vat-base-salecl               = (if out-vatp-have-vat-sltcl = no then 0 else (((out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl - varprice-base-conscl) * parcons-vat-pc / (100 + parcons-vat-pc) * out-vatp_gds-dtlcl.fact-qnty * varcons-qntycl / varfact-qntycl + ((out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl ) * parvat-pc / (100 + parvat-pc) * out-vatp_gds-dtlcl.fact-qnty * (varfact-qntycl - varcons-qntycl) / varfact-qntycl) / varfact-qntycl)
                vat-rubl-salecl               = (if out-vatp-have-vat-sltcl = no then 0 else (((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl - varprice-rubl-conscl) * parcons-vat-pc / (100 + parcons-vat-pc) * out-vatp_gds-dtlcl.fact-qnty * varcons-qntycl / varfact-qntycl + ((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl) * parvat-pc / (100 + parvat-pc) * out-vatp_gds-dtlcl.fact-qnty * (varfact-qntycl - varcons-qntycl) / varfact-qntycl) / varfact-qntycl)
        .
    end.
  end.
  else do:
    for each out-vatp_gds-dtlcl where out-vatp_gds-dtlcl.doc-code  = pardoc-code  and
                                       out-vatp_gds-dtlcl.artic     = parartic     and
                                       out-vatp_gds-dtlcl.prod-type = parprod-type and
                                       out-vatp_gds-dtlcl.prod-code = parprod-code no-lock :
      if varoutvprbcl = "base":u then do:
        assign
          varcurclprice-base = out-vatp_gds-dtlcl.cur-base
          varcurclprice-rubl = out-vatp_gds-dtlcl.cur-base * ((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) / (out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base)).
      end.
      else do:
        assign
          varcurclprice-base = out-vatp_gds-dtlcl.cur-base / ((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) / (out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base))
          varcurclprice-rubl = out-vatp_gds-dtlcl.cur-base.
      end.
      assign
             varsum-base-factovpcl = varsum-base-factovpcl + (out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base)                 * out-vatp_gds-dtlcl.fact-qnty
       varslt-base-factovpcl = varslt-base-factovpcl + (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc)                   * out-vatp_gds-dtlcl.fact-qnty
       varvat-base-factovpcl = varvat-base-factovpcl + (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl) * parvat-pc / (100 + parvat-pc)                   * out-vatp_gds-dtlcl.fact-qnty
       varvatcons-base-factovpcl = varvatcons-base-factovpcl + (((out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl - varprice-base-conscl) * parcons-vat-pc / (100 + parcons-vat-pc) * out-vatp_gds-dtlcl.fact-qnty * varcons-qntycl / varfact-qntycl + ((out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl) * parvat-pc / (100 + parvat-pc) * out-vatp_gds-dtlcl.fact-qnty * (varfact-qntycl - varcons-qntycl) / varfact-qntycl)
       vardsc-base-factovpcl = vardsc-base-factovpcl + out-vatp_gds-dtlcl.discnt-base * out-vatp_gds-dtlcl.fact-qnty
       varsum-base-docovpcl  = varsum-base-docovpcl  + (out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base)                 * out-vatp_gds-dtlcl.doc-qnty
       varslt-base-docovpcl  = varslt-base-docovpcl  + (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc)                   * out-vatp_gds-dtlcl.doc-qnty
       varvat-base-docovpcl  = varvat-base-docovpcl  + (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl) * parvat-pc / (100 + parvat-pc)                   * out-vatp_gds-dtlcl.doc-qnty
       varvatcons-base-docovpcl  = varvatcons-base-docovpcl  + (((out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl - varprice-base-conscl) * parcons-vat-pc / (100 + parcons-vat-pc) * out-vatp_gds-dtlcl.doc-qnty * varcons-qntycl / varfact-qntycl + ((out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl) * parvat-pc / (100 + parvat-pc) * out-vatp_gds-dtlcl.doc-qnty * (varfact-qntycl - varcons-qntycl) / varfact-qntycl)
       vardsc-base-docovpcl  = vardsc-base-docovpcl  + out-vatp_gds-dtlcl.discnt-base * out-vatp_gds-dtlcl.doc-qnty
      .
      assign
             varsum-rubl-factovpcl = varsum-rubl-factovpcl + (out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl)                 * out-vatp_gds-dtlcl.fact-qnty
       varslt-rubl-factovpcl = varslt-rubl-factovpcl + (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc)                   * out-vatp_gds-dtlcl.fact-qnty
       varvat-rubl-factovpcl = varvat-rubl-factovpcl + (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl) * parvat-pc / (100 + parvat-pc)                   * out-vatp_gds-dtlcl.fact-qnty
       varvatcons-rubl-factovpcl = varvatcons-rubl-factovpcl + (((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl - varprice-rubl-conscl) * parcons-vat-pc / (100 + parcons-vat-pc) * out-vatp_gds-dtlcl.fact-qnty * varcons-qntycl / varfact-qntycl + ((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl) * parvat-pc / (100 + parvat-pc) * out-vatp_gds-dtlcl.fact-qnty * (varfact-qntycl - varcons-qntycl) / varfact-qntycl)
       vardsc-rubl-factovpcl = vardsc-rubl-factovpcl + out-vatp_gds-dtlcl.discnt-rubl * out-vatp_gds-dtlcl.fact-qnty
       varsum-rubl-docovpcl  = varsum-rubl-docovpcl  + (out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl)                 * out-vatp_gds-dtlcl.doc-qnty
       varslt-rubl-docovpcl  = varslt-rubl-docovpcl  + (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc)                   * out-vatp_gds-dtlcl.doc-qnty
       varvat-rubl-docovpcl  = varvat-rubl-docovpcl  + (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl) * parvat-pc / (100 + parvat-pc)                   * out-vatp_gds-dtlcl.doc-qnty
       varvatcons-rubl-docovpcl  = varvatcons-rubl-docovpcl  + (((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl - varprice-rubl-conscl) * parcons-vat-pc / (100 + parcons-vat-pc) * out-vatp_gds-dtlcl.doc-qnty * varcons-qntycl / varfact-qntycl + ((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl) * parvat-pc / (100 + parvat-pc) * out-vatp_gds-dtlcl.doc-qnty * (varfact-qntycl - varcons-qntycl) / varfact-qntycl)
       vardsc-rubl-docovpcl  = vardsc-rubl-docovpcl  + out-vatp_gds-dtlcl.discnt-rubl * out-vatp_gds-dtlcl.doc-qnty   .
    end.
    if pardoc-type = 'инв':U then do:
      ASSIGN
                price-base-with-tax-salecl    = varsum-base-docovpcl / varfact-qntycl
        slt-base-salecl               = varslt-base-docovpcl / varfact-qntycl
        vat-base-buyercl              = varvat-base-docovpcl / varfact-qntycl
        discnt-base-salecl            = vardsc-base-docovpcl / varfact-qntycl
        vat-base-salecl               = varvatcons-base-docovpcl / varfact-qntycl
                price-rubl-with-tax-salecl    = varsum-rubl-docovpcl / varfact-qntycl
        slt-rubl-salecl               = varslt-rubl-docovpcl / varfact-qntycl
        vat-rubl-buyercl              = varvat-rubl-docovpcl / varfact-qntycl
        discnt-rubl-salecl            = vardsc-rubl-docovpcl / varfact-qntycl
        vat-rubl-salecl               = varvatcons-rubl-docovpcl / varfact-qntycl.
    end.
    else do:
      ASSIGN
                price-base-with-tax-salecl    = varsum-base-factovpcl / varfact-qntycl
        slt-base-salecl               = varslt-base-factovpcl / varfact-qntycl
        vat-base-buyercl              = varvat-base-factovpcl / varfact-qntycl
        discnt-base-salecl            = vardsc-base-factovpcl / varfact-qntycl
        vat-base-salecl               = varvatcons-base-factovpcl / varfact-qntycl
                price-rubl-with-tax-salecl    = varsum-rubl-factovpcl / varfact-qntycl
        slt-rubl-salecl               = varslt-rubl-factovpcl / varfact-qntycl
        vat-rubl-buyercl              = varvat-rubl-factovpcl / varfact-qntycl
        discnt-rubl-salecl            = vardsc-rubl-factovpcl / varfact-qntycl
        vat-rubl-salecl               = varvatcons-rubl-factovpcl / varfact-qntycl.
    end.
  end.
end.
assign
  price-base-without-tax-salecl = price-base-with-tax-salecl - vat-base-salecl - slt-base-salecl - road-tax-base-salecl
  price-rubl-without-tax-salecl = price-rubl-with-tax-salecl - vat-rubl-salecl - slt-rubl-salecl - road-tax-rubl-salecl.
end.
if paris-cur then do:
  assign
    parcurartic      = cl_tt-clcparts.artic
    parcurprod-type  = cl_tt-clcparts.prod-type
    parcurprod-code  = cl_tt-clcparts.prod-code
    parcurdoc-type   = cl_tt-clcparts.doc-type
    parcurdoc-code   = cl_tt-clcparts.out-code
    parcurobj-type   = cl_tt-clcparts.obj-type
    parcurobj-code   = cl_tt-clcparts.obj-code.
  if parr-b = "base" then do:
    assign
      parcurprice-base = parcur-base
      parcurprice-rubl = parcur-base * parbase-rate / parbase-scale.
  end.
  else do:
    assign
      parcurprice-base = parcur-base / parbase-rate * parbase-scale
      parcurprice-rubl = parcur-base.
  end.
  assign
    parcurbase-rate   = parbase-rate
    parcurbase-scale  = parbase-scale
    parcurdiscnt-base = 0
    parcurdiscnt-rubl = 0
    parcurfact-qnty   = cl_tt-clcparts.fact-qnty
    parcurcli-qnty    = cl_tt-clcparts.cli-qnty
    parcurdoc-qnty    = cl_tt-clcparts.qnty.
if parcurext-doc-type = 'ot':U or
   parcurext-doc-type = ?                 then do:
  assign
   out-vatp-have-vat-sltcur = yes.
end.
else do:
  find first out-vatp_doc-attrcur no-lock
    where out-vatp_doc-attrcur.doc-code  = parcurdoc-code
      and out-vatp_doc-attrcur.attr-code = 'envd':U
      no-error .
  if not available out-vatp_doc-attrcur then do:
    assign
      out-vatp-have-vat-sltcur = yes.
  end.
  else do:
     out-vatp-have-vat-sltcur = no.
  end.
end.
find first out-vatp_goodscur where out-vatp_goodscur.artic     = parcurartic     and
                                   out-vatp_goodscur.prod-type = parcurprod-type and
                                   out-vatp_goodscur.prod-code = parcurprod-code no-lock.
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  parcurartic
  ,input  parcurprod-type
  ,input  parcurprod-code
  ,output varroot-nodecur
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении корневого признака товара" skip
    "Артикул" parcurartic parcurprod-type parcurprod-code skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtat in g#library
  (input  varroot-nodecur
  ,input  'empty-scale=request'
  ,output varempty-scalecur
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении атрибута признака" skip
    "Артикул" parcurartic parcurprod-type parcurprod-code skip
    "Признак" varroot-nodecur skip
    "Запрашивался атрибут" "empty-scale=request" skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varoutvprbcur
  )  .
if varoutvprbcur = "base":u then do:
  assign
        road-tax-base-salecur    =  (if parcurroad-tax = ? then 0 else parcurroad-tax * 1)
    excise-base-salecur      =  (if parcurexcise   = ? then 0 else parcurexcise   * 1)
  .
end.
else do:
  assign
        road-tax-base-salecur    =  (if parcurroad-tax = ? then 0 else parcurroad-tax / parcurbase-rate * parcurbase-scale)
    excise-base-salecur      =  (if parcurexcise   = ? then 0 else parcurexcise   / parcurbase-rate * parcurbase-scale)
  .
end.
if varoutvprbcur = "rubl":u then do:
  assign
        road-tax-rubl-salecur    = (if parcurroad-tax = ? then 0 else parcurroad-tax * 1)
    excise-rubl-salecur      = (if parcurexcise   = ? then 0 else parcurexcise   * 1) .
end.
else do:
  assign
        road-tax-rubl-salecur    = (if parcurroad-tax = ? then 0 else parcurroad-tax * parcurbase-rate / parcurbase-scale)
    excise-rubl-salecur      = (if parcurexcise   = ? then 0 else parcurexcise   * parcurbase-rate / parcurbase-scale) .
end.
assign
  varis-cons-parts-havecur =  no.
assign
  varfact-qntycur       = 0
  varcons-qntycur       = 0
  varprice-base-conscur = 0
  varprice-rubl-conscur = 0.
if cl_tt-clcparts.purch-code = 2 then do:
assign
  price-rubl-with-tax-lococur = cl_tt-clcparts.price-rubl
  price-base-with-tax-lococur = cl_tt-clcparts.price-base
.
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprbocur
  )  .
  if cl_tt-clcparts.out-code = 'free-zone':U     or
     cl_tt-clcparts.out-code = 'out-zone':U   or
     cl_tt-clcparts.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-sltocur = yes.
  end.
  else do:
    find first in-vatp_doc-attrocur no-lock
      where in-vatp_doc-attrocur.doc-code  = cl_tt-clcparts.out-code
        and in-vatp_doc-attrocur.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attrocur then do:
      assign
        in-vatp-have-vat-sltocur = yes.
    end.
    else do:
         in-vatp-have-vat-sltocur = no.
    end.
  end.
  assign
   price-cli-with-tax-lococur = cl_tt-clcparts.price-cli
   cli-base-rateocur          = cl_tt-clcparts.cli-base-rate.
  ASSIGN   road-tax-base-lococur  = (if cl_tt-clcparts.road-tax-base  = ? then 0 else cl_tt-clcparts.road-tax-base)
           road-tax-rubl-lococur  = (if cl_tt-clcparts.road-tax-rubl  = ? then 0 else cl_tt-clcparts.road-tax-rubl).
  ASSIGN  transport-base-lococur = (if cl_tt-clcparts.transport-base = ? then 0 else cl_tt-clcparts.transport-base)
          transport-rubl-lococur = (if cl_tt-clcparts.transport-rubl = ? then 0 else cl_tt-clcparts.transport-rubl)
          other-base-lococur     = (if cl_tt-clcparts.other-base     = ? then 0 else cl_tt-clcparts.other-base)
          other-rubl-lococur     = (if cl_tt-clcparts.other-rubl     = ? then 0 else cl_tt-clcparts.other-rubl)
          vat-pc-lococur         = (if cl_tt-clcparts.vat-pc         = ? then 0 else cl_tt-clcparts.vat-pc)
          slt-pc-lococur         = (if cl_tt-clcparts.slt-pc         = ? then 0 else cl_tt-clcparts.slt-pc).
          ASSIGN   slt-base-lococur    = (if in-vatp-have-vat-sltocur = no then 0 else (price-base-with-tax-lococur - ((if road-tax-base-lococur  = ? then 0 else road-tax-base-lococur) + (if transport-base-lococur = ? then 0 else transport-base-lococur) + (if other-base-lococur = ? then 0 else other-base-lococur)))                           * slt-pc-lococur / (100 + slt-pc-lococur))                        vat-base-lococur    = (if in-vatp-have-vat-sltocur = no then 0 else (price-base-with-tax-lococur - ((if road-tax-base-lococur  = ? then 0 else road-tax-base-lococur) + (if transport-base-lococur = ? then 0 else transport-base-lococur) + (if other-base-lococur = ? then 0 else other-base-lococur))) * (1 - slt-pc-lococur / (100 + slt-pc-lococur)) * vat-pc-lococur / (100 + vat-pc-lococur)).
    ASSIGN   slt-rubl-lococur    = (if in-vatp-have-vat-sltocur = no then 0 else (price-rubl-with-tax-lococur - ((if road-tax-rubl-lococur  = ? then 0 else road-tax-rubl-lococur) + (if transport-rubl-lococur = ? then 0 else transport-rubl-lococur) + (if other-rubl-lococur = ? then 0 else other-rubl-lococur)))                           * slt-pc-lococur / (100 + slt-pc-lococur))                        vat-rubl-lococur    = (if in-vatp-have-vat-sltocur = no then 0 else (price-rubl-with-tax-lococur - ((if road-tax-rubl-lococur  = ? then 0 else road-tax-rubl-lococur) + (if transport-rubl-lococur = ? then 0 else transport-rubl-lococur) + (if other-rubl-lococur = ? then 0 else other-rubl-lococur))) * (1 - slt-pc-lococur / (100 + slt-pc-lococur)) * vat-pc-lococur / (100 + vat-pc-lococur)).
  assign
    exch-rate-cli-lococur = (cl_tt-clcparts.price-rubl - transport-rubl-lococur - other-rubl-lococur - road-tax-rubl-lococur - (if cl_tt-clcparts.vat-type <> 'в т. ч.':U then vat-rubl-lococur else 0) - (if cl_tt-clcparts.slt-type <> 'в т. ч.':U then slt-rubl-lococur else 0)) / cl_tt-clcparts.price-cli .
  assign
    slt-cli-lococur        = slt-rubl-lococur       / exch-rate-cli-lococur
    vat-cli-lococur        = vat-rubl-lococur       / exch-rate-cli-lococur
    road-tax-cli-lococur   = road-tax-rubl-lococur  / exch-rate-cli-lococur
    transport-cli-lococur  = 0
    other-cli-lococur      = 0
  .
ASSIGN
          price-base-without-tax-lococur = price-base-with-tax-lococur - vat-base-lococur - slt-base-lococur - ((if road-tax-base-lococur  = ? then 0 else road-tax-base-lococur) + (if transport-base-lococur = ? then 0 else transport-base-lococur) + (if other-base-lococur = ? then 0 else other-base-lococur))
    price-rubl-without-tax-lococur = price-rubl-with-tax-lococur - vat-rubl-lococur - slt-rubl-lococur - ((if road-tax-rubl-lococur  = ? then 0 else road-tax-rubl-lococur) + (if transport-rubl-lococur = ? then 0 else transport-rubl-lococur) + (if other-rubl-lococur = ? then 0 else other-rubl-lococur))
.
  assign
    varprice-base-conscur    = varprice-base-conscur + (price-base-with-tax-lococur - (if road-tax-base-lococur = ? then 0 else road-tax-base-lococur))* cl_tt-clcparts.fact-qnty
    varprice-rubl-conscur    = varprice-rubl-conscur + (price-rubl-with-tax-lococur - (if road-tax-rubl-lococur = ? then 0 else road-tax-rubl-lococur))* cl_tt-clcparts.fact-qnty
    varis-cons-parts-havecur = yes
    varcons-qntycur          = varcons-qntycur + cl_tt-clcparts.fact-qnty.
end.
assign
  varfact-qntycur = cl_tt-clcparts.fact-qnty.
assign
  varprice-base-conscur = varprice-base-conscur / varcons-qntycur
  varprice-rubl-conscur = varprice-rubl-conscur / varcons-qntycur.
if varprice-base-conscur = ? then do:
  assign
    varprice-base-conscur = 0.
end.
if varprice-rubl-conscur = ? then do:
  assign
    varprice-rubl-conscur = 0.
end.
assign
    slt-base-salecur               = (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-base - parcurdiscnt-base                - road-tax-base-salecur) * parcurSLT-pc / (100 + parcurSLT-pc)
  vat-base-buyercur              = (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-base - parcurdiscnt-base - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-base - parcurdiscnt-base                - road-tax-base-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-base-salecur) * parcurvat-pc / (100 + parcurvat-pc)
  discnt-base-salecur            = parcurdiscnt-base
  price-base-with-tax-salecur    = (parcurprice-base - parcurdiscnt-base)
    slt-rubl-salecur               = (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-rubl - parcurdiscnt-rubl                - road-tax-rubl-salecur) * parcurSLT-pc / (100 + parcurSLT-pc)
  vat-rubl-buyercur              = (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-rubl - parcurdiscnt-rubl - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-rubl - parcurdiscnt-rubl                - road-tax-rubl-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-rubl-salecur) * parcurvat-pc / (100 + parcurvat-pc)
  discnt-rubl-salecur            = parcurdiscnt-rubl
  price-rubl-with-tax-salecur    = (parcurprice-rubl - parcurdiscnt-rubl)
  .
if parcurdoc-type = 'инв':U then do:
  assign
    varfact-qntycur = parcurdoc-qnty.
end.
else do:
  assign
    varfact-qntycur = parcurfact-qnty.
end.
if varis-cons-parts-havecur = no then do:
  assign
        vat-base-salecur               = (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-base - parcurdiscnt-base - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-base - parcurdiscnt-base                - road-tax-base-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-base-salecur) * parcurvat-pc / (100 + parcurvat-pc)
        vat-rubl-salecur               = (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-rubl - parcurdiscnt-rubl - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-rubl - parcurdiscnt-rubl                - road-tax-rubl-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-rubl-salecur) * parcurvat-pc / (100 + parcurvat-pc).
end.
else do:
  if parcurdoc-type = 'инв':U then do:
    assign
            vat-base-salecur               = (if out-vatp-have-vat-sltcur = no then 0 else (((parcurprice-base - parcurdiscnt-base) - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-base - parcurdiscnt-base                - road-tax-base-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-base-salecur - varprice-base-conscur) * parcurcons-vat-pc / (100 + parcurcons-vat-pc) * parcurdoc-qnty * varcons-qntycur / varfact-qntycur + ((parcurprice-base - parcurdiscnt-base) - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-base - parcurdiscnt-base                - road-tax-base-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-base-salecur) * parcurvat-pc / (100 + parcurvat-pc) * parcurdoc-qnty * (varfact-qntycur - varcons-qntycur) / varfact-qntycur) / varfact-qntycur)
            vat-rubl-salecur               = (if out-vatp-have-vat-sltcur = no then 0 else (((parcurprice-rubl - parcurdiscnt-rubl) - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-rubl - parcurdiscnt-rubl                - road-tax-rubl-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-rubl-salecur - varprice-rubl-conscur) * parcurcons-vat-pc / (100 + parcurcons-vat-pc) * parcurdoc-qnty * varcons-qntycur / varfact-qntycur + ((parcurprice-rubl - parcurdiscnt-rubl) - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-rubl - parcurdiscnt-rubl                - road-tax-rubl-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-rubl-salecur) * parcurvat-pc / (100 + parcurvat-pc) * parcurdoc-qnty * (varfact-qntycur - varcons-qntycur) / varfact-qntycur) / varfact-qntycur)
     .
  end.
  else do:
    assign
            vat-base-salecur               = (if out-vatp-have-vat-sltcur = no then 0 else (((parcurprice-base - parcurdiscnt-base) - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-base - parcurdiscnt-base                - road-tax-base-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-base-salecur - varprice-base-conscur) * parcurcons-vat-pc / (100 + parcurcons-vat-pc) * parcurfact-qnty * varcons-qntycur / varfact-qntycur + ((parcurprice-base - parcurdiscnt-base) - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-base - parcurdiscnt-base                - road-tax-base-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - varprice-base-conscur) * parcurvat-pc / (100 + parcurvat-pc) * parcurfact-qnty * (varfact-qntycur - varcons-qntycur) / varfact-qntycur) / varfact-qntycur)
            vat-rubl-salecur               = (if out-vatp-have-vat-sltcur = no then 0 else (((parcurprice-rubl - parcurdiscnt-rubl) - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-rubl - parcurdiscnt-rubl                - road-tax-rubl-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-rubl-salecur - varprice-rubl-conscur) * parcurcons-vat-pc / (100 + parcurcons-vat-pc) * parcurfact-qnty * varcons-qntycur / varfact-qntycur + ((parcurprice-rubl - parcurdiscnt-rubl) - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-rubl - parcurdiscnt-rubl                - road-tax-rubl-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - varprice-rubl-conscur) * parcurvat-pc / (100 + parcurvat-pc) * parcurfact-qnty * (varfact-qntycur - varcons-qntycur) / varfact-qntycur) / varfact-qntycur)
     .
  end.
end.
assign
price-base-without-tax-salecur = price-base-with-tax-salecur - vat-base-salecur - slt-base-salecur - road-tax-base-salecur
price-rubl-without-tax-salecur = price-rubl-with-tax-salecur - vat-rubl-salecur - slt-rubl-salecur - road-tax-rubl-salecur.
end.
create bf_tt-allsum.
assign
  bf_tt-allsum.sum-type = 'основная_сумма':U.
assign
  bf_tt-allsum.fact-qnty          =  cl_tt-clcparts.fact-qnty
  bf_tt-allsum.cli-qnty           =  cl_tt-clcparts.cli-qnty
  bf_tt-allsum.sum-dsc-base-doc   =  (if price-base-with-tax-salecl  = ? then 0 else price-base-with-tax-salecl  * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.sum-dsc-rubl-doc   =  (if price-rubl-with-tax-salecl  = ? then 0 else price-rubl-with-tax-salecl  * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.dsc-base-doc       =  (if discnt-base-salecl          = ? then 0 else discnt-base-salecl          * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.dsc-rubl-doc       =  (if discnt-rubl-salecl          = ? then 0 else discnt-rubl-salecl          * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.slt-base-doc       =  (if slt-base-salecl             = ? then 0 else slt-base-salecl             * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.slt-rubl-doc       =  (if slt-rubl-salecl             = ? then 0 else slt-rubl-salecl             * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.vat-base-buyer-doc =  (if vat-base-buyercl            = ? then 0 else vat-base-buyercl            * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.vat-rubl-buyer-doc =  (if vat-rubl-buyercl            = ? then 0 else vat-rubl-buyercl            * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.road-tax-base-doc  =  (if road-tax-base-salecl        = ? then 0 else road-tax-base-salecl        * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.road-tax-rubl-doc  =  (if road-tax-rubl-salecl        = ? then 0 else road-tax-rubl-salecl        * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.excise-base-doc    =  (if excise-base-salecl          = ? then 0 else excise-base-salecl          * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.excise-rubl-doc    =  (if excise-rubl-salecl          = ? then 0 else excise-rubl-salecl          * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.sum-dsc-base-cur   =  (if price-base-with-tax-salecur = ? then 0 else price-base-with-tax-salecur * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.sum-dsc-rubl-cur   =  (if price-rubl-with-tax-salecur = ? then 0 else price-rubl-with-tax-salecur * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.dsc-base-cur       =  (if discnt-base-salecur         = ? then 0 else discnt-base-salecur         * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.dsc-rubl-cur       =  (if discnt-rubl-salecur         = ? then 0 else discnt-rubl-salecur         * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.slt-base-cur       =  (if slt-base-salecur            = ? then 0 else slt-base-salecur            * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.slt-rubl-cur       =  (if slt-rubl-salecur            = ? then 0 else slt-rubl-salecur            * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.vat-base-buyer-cur =  (if vat-base-buyercur           = ? then 0 else vat-base-buyercur           * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.vat-rubl-buyer-cur =  (if vat-rubl-buyercur           = ? then 0 else vat-rubl-buyercur           * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.road-tax-base-cur  =  (if road-tax-base-salecur       = ? then 0 else road-tax-base-salecur       * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.road-tax-rubl-cur  =  (if road-tax-rubl-salecur       = ? then 0 else road-tax-rubl-salecur       * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.excise-base-cur    =  (if excise-base-salecur         = ? then 0 else excise-base-salecur         * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.excise-rubl-cur    =  (if excise-rubl-salecur         = ? then 0 else excise-rubl-salecur         * cl_tt-clcparts.fact-qnty)
  .
if cl_tt-clcparts.purch-code = integer('2':U) then do:
  assign
    bf_tt-allsum.vat-base-doc = (if out-vatp-have-vat-sltcur <> yes then 0 else (price-base-with-tax-salecl  - road-tax-base-salecl  - slt-base-salecl  - (cl_tt-clcparts.price-base - cl_tt-clcparts.road-tax-base)) * parcons-vat-pc / (100 + parcons-vat-pc) * cl_tt-clcparts.fact-qnty)
    bf_tt-allsum.vat-rubl-doc = (if out-vatp-have-vat-sltcur <> yes then 0 else (price-rubl-with-tax-salecl  - road-tax-rubl-salecl  - slt-rubl-salecl  - (cl_tt-clcparts.price-rubl - cl_tt-clcparts.road-tax-rubl)) * parcons-vat-pc / (100 + parcons-vat-pc) * cl_tt-clcparts.fact-qnty)
    bf_tt-allsum.vat-base-cur = (if out-vatp-have-vat-sltcur <> yes then 0 else (price-base-with-tax-salecur - road-tax-base-salecur - slt-base-salecur - (cl_tt-clcparts.price-base - cl_tt-clcparts.road-tax-base)) * parcurcons-vat-pc / (100 + parcurcons-vat-pc) * cl_tt-clcparts.fact-qnty)
    bf_tt-allsum.vat-rubl-cur = (if out-vatp-have-vat-sltcur <> yes then 0 else (price-rubl-with-tax-salecur - road-tax-rubl-salecur - slt-rubl-salecur - (cl_tt-clcparts.price-rubl - cl_tt-clcparts.road-tax-rubl)) * parcurcons-vat-pc / (100 + parcurcons-vat-pc) * cl_tt-clcparts.fact-qnty)
    .
end.
else do:
  assign
    bf_tt-allsum.vat-base-doc = (if out-vatp-have-vat-sltcur <> yes then 0 else (price-base-with-tax-salecl  - road-tax-base-salecl  - slt-base-salecl ) * parvat-pc / (100 + parvat-pc) * cl_tt-clcparts.fact-qnty)
    bf_tt-allsum.vat-rubl-doc = (if out-vatp-have-vat-sltcur <> yes then 0 else (price-rubl-with-tax-salecl  - road-tax-rubl-salecl  - slt-rubl-salecl ) * parvat-pc / (100 + parvat-pc) * cl_tt-clcparts.fact-qnty)
    bf_tt-allsum.vat-base-cur = (if out-vatp-have-vat-sltcur <> yes then 0 else (price-base-with-tax-salecur - road-tax-base-salecur - slt-base-salecur) * parcurvat-pc / (100 + parcurvat-pc) * cl_tt-clcparts.fact-qnty)
    bf_tt-allsum.vat-rubl-cur = (if out-vatp-have-vat-sltcur <> yes then 0 else (price-rubl-with-tax-salecur - road-tax-rubl-salecur - slt-rubl-salecur) * parcurvat-pc / (100 + parcurvat-pc) * cl_tt-clcparts.fact-qnty)
    .
end.
if bf_tt-allsum.vat-base-doc = ? then bf_tt-allsum.vat-base-doc = 0.
if bf_tt-allsum.vat-rubl-doc = ? then bf_tt-allsum.vat-rubl-doc = 0.
assign
  bf_tt-allsum.sum-dsc-base-acc     = (if price-base-with-tax-loccl    = ? then 0 else price-base-with-tax-loccl    * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.sum-dsc-rubl-acc     = (if price-rubl-with-tax-loccl    = ? then 0 else price-rubl-with-tax-loccl    * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.sum-dsc-cli-acc      = (if (price-cli-with-tax-loccl +
                                           road-tax-cli-loccl       +
                                           (if cl_tt-clcparts.vat-type <> 'в т. ч.':U then vat-cli-loccl else 0) +
                                           (if cl_tt-clcparts.slt-type <> 'в т. ч.':U then slt-cli-loccl else 0)
                                           ) / cli-base-ratecl = ? then 0
                                        else
                                          (price-cli-with-tax-loccl +
                                           road-tax-cli-loccl       +
                                           (if cl_tt-clcparts.vat-type <> 'в т. ч.':U then vat-cli-loccl else 0) +
                                           (if cl_tt-clcparts.slt-type <> 'в т. ч.':U then slt-cli-loccl else 0)
                                           ) / cli-base-ratecl * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.dsc-base-acc         = 0
  bf_tt-allsum.dsc-rubl-acc         = 0
  bf_tt-allsum.dsc-cli-acc          = 0
  bf_tt-allsum.vat-base-acc         = (if vat-base-loccl      = ? then 0 else vat-base-loccl      * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.vat-rubl-acc         = (if vat-rubl-loccl      = ? then 0 else vat-rubl-loccl      * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.vat-cli-acc          = (if vat-cli-loccl / cli-base-ratecl      = ? then 0 else vat-cli-loccl / cli-base-ratecl      * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.slt-base-acc         = (if slt-base-loccl      = ? then 0 else slt-base-loccl      * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.slt-rubl-acc         = (if slt-rubl-loccl      = ? then 0 else slt-rubl-loccl      * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.slt-cli-acc          = (if slt-cli-loccl / cli-base-ratecl      = ? then 0 else slt-cli-loccl / cli-base-ratecl      * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.road-tax-base-acc    = (if road-tax-base-loccl = ? then 0 else road-tax-base-loccl * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.road-tax-rubl-acc    = (if road-tax-rubl-loccl = ? then 0 else road-tax-rubl-loccl * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.road-tax-cli-acc     = (if road-tax-cli-loccl / cli-base-ratecl = ? then 0 else road-tax-cli-loccl / cli-base-ratecl * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.excise-base-acc      = 0
  bf_tt-allsum.excise-rubl-acc      = 0
  bf_tt-allsum.excise-cli-acc       = 0
  bf_tt-allsum.transport-base-acc   = (if transport-base-loccl   = ? then 0 else transport-base-loccl  * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.transport-rubl-acc   = (if transport-rubl-loccl   = ? then 0 else transport-rubl-loccl  * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.transport-cli-acc    = (if transport-cli-loccl / cli-base-ratecl   = ? then 0 else transport-cli-loccl / cli-base-ratecl  * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.other-base-acc       = (if other-base-loccl       = ? then 0 else other-base-loccl      * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.other-rubl-acc       = (if other-rubl-loccl       = ? then 0 else other-rubl-loccl      * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.other-cli-acc        = (if other-cli-loccl / cli-base-ratecl       = ? then 0 else other-cli-loccl     / cli-base-ratecl  * cl_tt-clcparts.fact-qnty).
create bfs_tt-allsum.
assign
  bfs_tt-allsum.sum-type = 'основная_сумма_со_знаком':U.
if pardoc-type = 'инв':U or
   pardoc-type = 'при':U    or
   pardoc-type = 'возврат':U    then do:
   buffer-copy bf_tt-allsum except bf_tt-allsum.sum-type to bfs_tt-allsum.
end.
else do:
  assign
    bfs_tt-allsum.fact-qnty           =  - bf_tt-allsum.fact-qnty
    bfs_tt-allsum.cli-qnty            =  - bf_tt-allsum.cli-qnty
    bfs_tt-allsum.sum-dsc-base-doc    =  - bf_tt-allsum.sum-dsc-base-doc
    bfs_tt-allsum.sum-dsc-rubl-doc    =  - bf_tt-allsum.sum-dsc-rubl-doc
    bfs_tt-allsum.dsc-base-doc        =  - bf_tt-allsum.dsc-base-doc
    bfs_tt-allsum.dsc-rubl-doc        =  - bf_tt-allsum.dsc-rubl-doc
    bfs_tt-allsum.vat-base-doc        =  - bf_tt-allsum.vat-base-doc
    bfs_tt-allsum.vat-rubl-doc        =  - bf_tt-allsum.vat-rubl-doc
    bfs_tt-allsum.vat-base-buyer-doc  =  - bf_tt-allsum.vat-base-buyer-doc
    bfs_tt-allsum.vat-rubl-buyer-doc  =  - bf_tt-allsum.vat-rubl-buyer-doc
    bfs_tt-allsum.slt-base-doc        =  - bf_tt-allsum.slt-base-doc
    bfs_tt-allsum.slt-rubl-doc        =  - bf_tt-allsum.slt-rubl-doc
    bfs_tt-allsum.road-tax-base-doc   =  - bf_tt-allsum.road-tax-base-doc
    bfs_tt-allsum.road-tax-rubl-doc   =  - bf_tt-allsum.road-tax-rubl-doc
    bfs_tt-allsum.excise-base-doc     =  - bf_tt-allsum.excise-base-doc
    bfs_tt-allsum.excise-rubl-doc     =  - bf_tt-allsum.excise-rubl-doc
    bfs_tt-allsum.sum-dsc-base-cur    =  - bf_tt-allsum.sum-dsc-base-cur
    bfs_tt-allsum.sum-dsc-rubl-cur    =  - bf_tt-allsum.sum-dsc-rubl-cur
    bfs_tt-allsum.dsc-base-cur        =  - bf_tt-allsum.dsc-base-cur
    bfs_tt-allsum.dsc-rubl-cur        =  - bf_tt-allsum.dsc-rubl-cur
    bfs_tt-allsum.vat-base-cur        =  - bf_tt-allsum.vat-base-cur
    bfs_tt-allsum.vat-rubl-cur        =  - bf_tt-allsum.vat-rubl-cur
    bfs_tt-allsum.vat-base-buyer-cur  =  - bf_tt-allsum.vat-base-buyer-cur
    bfs_tt-allsum.vat-rubl-buyer-cur  =  - bf_tt-allsum.vat-rubl-buyer-cur
    bfs_tt-allsum.slt-base-cur        =  - bf_tt-allsum.slt-base-cur
    bfs_tt-allsum.slt-rubl-cur        =  - bf_tt-allsum.slt-rubl-cur
    bfs_tt-allsum.road-tax-base-cur   =  - bf_tt-allsum.road-tax-base-cur
    bfs_tt-allsum.road-tax-rubl-cur   =  - bf_tt-allsum.road-tax-rubl-cur
    bfs_tt-allsum.excise-base-cur     =  - bf_tt-allsum.excise-base-cur
    bfs_tt-allsum.excise-rubl-cur     =  - bf_tt-allsum.excise-rubl-cur
    bfs_tt-allsum.sum-dsc-base-acc    =  - bf_tt-allsum.sum-dsc-base-acc
    bfs_tt-allsum.sum-dsc-rubl-acc    =  - bf_tt-allsum.sum-dsc-rubl-acc
    bfs_tt-allsum.sum-dsc-cli-acc     =  - bf_tt-allsum.sum-dsc-cli-acc
    bfs_tt-allsum.dsc-base-acc        =  - bf_tt-allsum.dsc-base-acc
    bfs_tt-allsum.dsc-rubl-acc        =  - bf_tt-allsum.dsc-rubl-acc
    bfs_tt-allsum.dsc-cli-acc         =  - bf_tt-allsum.dsc-cli-acc
    bfs_tt-allsum.vat-base-acc        =  - bf_tt-allsum.vat-base-acc
    bfs_tt-allsum.vat-rubl-acc        =  - bf_tt-allsum.vat-rubl-acc
    bfs_tt-allsum.vat-cli-acc         =  - bf_tt-allsum.vat-cli-acc
    bfs_tt-allsum.slt-base-acc        =  - bf_tt-allsum.slt-base-acc
    bfs_tt-allsum.slt-rubl-acc        =  - bf_tt-allsum.slt-rubl-acc
    bfs_tt-allsum.slt-cli-acc         =  - bf_tt-allsum.slt-cli-acc
    bfs_tt-allsum.road-tax-base-acc   =  - bf_tt-allsum.road-tax-base-acc
    bfs_tt-allsum.road-tax-rubl-acc   =  - bf_tt-allsum.road-tax-rubl-acc
    bfs_tt-allsum.road-tax-cli-acc    =  - bf_tt-allsum.road-tax-cli-acc
    bfs_tt-allsum.excise-base-acc     =  - bf_tt-allsum.excise-base-acc
    bfs_tt-allsum.excise-rubl-acc     =  - bf_tt-allsum.excise-rubl-acc
    bfs_tt-allsum.excise-cli-acc      =  - bf_tt-allsum.excise-cli-acc
    bfs_tt-allsum.transport-base-acc  =  - bf_tt-allsum.transport-base-acc
    bfs_tt-allsum.transport-rubl-acc  =  - bf_tt-allsum.transport-rubl-acc
    bfs_tt-allsum.transport-cli-acc   =  - bf_tt-allsum.transport-cli-acc
    bfs_tt-allsum.other-base-acc      =  - bf_tt-allsum.other-base-acc
    bfs_tt-allsum.other-rubl-acc      =  - bf_tt-allsum.other-rubl-acc
    bfs_tt-allsum.other-cli-acc       =  - bf_tt-allsum.other-cli-acc.
end.
create bfpc_tt-allsum.
create bfspc_tt-allsum.
case cl_tt-clcparts.purch-code :
when 1           then do:
  assign
    bfpc_tt-allsum.sum-type  = 'сумма_по_выкупу':U
    bfspc_tt-allsum.sum-type = 'сумма_по_выкупу_со_знаком':U.
  buffer-copy bf_tt-allsum  except bf_tt-allsum.sum-type  to bfpc_tt-allsum.
  buffer-copy bfs_tt-allsum except bfs_tt-allsum.sum-type to bfspc_tt-allsum.
end.
when 4    then do:
  assign
    bfpc_tt-allsum.sum-type  = 'сумма_по_старой_консигнации':U
    bfspc_tt-allsum.sum-type = 'сумма_по_старой_консигнации_со_знаком':U.
  buffer-copy bf_tt-allsum  except bf_tt-allsum.sum-type  to bfpc_tt-allsum.
  buffer-copy bfs_tt-allsum except bfs_tt-allsum.sum-type to bfspc_tt-allsum.
end.
when 3 then do:
  assign
    bfpc_tt-allsum.sum-type  = 'сумма_по_ответственному_хранению':U
    bfspc_tt-allsum.sum-type = 'сумма_по_ответственному_хранению_со_знаком':U.
  buffer-copy bf_tt-allsum  except bf_tt-allsum.sum-type  to bfpc_tt-allsum.
  buffer-copy bfs_tt-allsum except bfs_tt-allsum.sum-type to bfspc_tt-allsum.
end.
when 2 then do:
  assign
    bfpc_tt-allsum.sum-type  = 'сумма_по_консигнации_выгода':U
    bfspc_tt-allsum.sum-type = 'сумма_по_консигнации_выгода_со_знаком':U.
  assign
    bfpc_tt-allsum.fact-qnty           = bf_tt-allsum.fact-qnty
    bfpc_tt-allsum.cli-qnty            = bf_tt-allsum.cli-qnty
    bfpc_tt-allsum.sum-dsc-base-doc    = bf_tt-allsum.sum-dsc-base-doc    - bf_tt-allsum.sum-dsc-base-acc
    bfpc_tt-allsum.sum-dsc-rubl-doc    = bf_tt-allsum.sum-dsc-rubl-doc    - bf_tt-allsum.sum-dsc-rubl-acc
    bfpc_tt-allsum.dsc-base-doc        = bf_tt-allsum.dsc-base-doc        - bf_tt-allsum.dsc-base-acc
    bfpc_tt-allsum.dsc-rubl-doc        = bf_tt-allsum.dsc-rubl-doc        - bf_tt-allsum.dsc-rubl-acc
    bfpc_tt-allsum.vat-base-doc        = bf_tt-allsum.vat-base-doc
    bfpc_tt-allsum.vat-rubl-doc        = bf_tt-allsum.vat-rubl-doc
    bfpc_tt-allsum.vat-base-buyer-doc  = bf_tt-allsum.vat-base-buyer-doc  - bf_tt-allsum.vat-base-acc
    bfpc_tt-allsum.vat-rubl-buyer-doc  = bf_tt-allsum.vat-rubl-buyer-doc  - bf_tt-allsum.vat-rubl-acc
    bfpc_tt-allsum.slt-base-doc        = bf_tt-allsum.slt-base-doc        - bf_tt-allsum.slt-base-acc
    bfpc_tt-allsum.slt-rubl-doc        = bf_tt-allsum.slt-rubl-doc        - bf_tt-allsum.slt-rubl-acc
    bfpc_tt-allsum.road-tax-base-doc   = bf_tt-allsum.road-tax-base-doc   - bf_tt-allsum.road-tax-base-acc
    bfpc_tt-allsum.road-tax-rubl-doc   = bf_tt-allsum.road-tax-rubl-doc   - bf_tt-allsum.road-tax-rubl-acc
    bfpc_tt-allsum.excise-base-doc     = bf_tt-allsum.excise-base-doc
    bfpc_tt-allsum.excise-rubl-doc     = bf_tt-allsum.excise-rubl-doc
    bfpc_tt-allsum.sum-dsc-base-cur    = bf_tt-allsum.sum-dsc-base-cur    - bf_tt-allsum.sum-dsc-base-acc
    bfpc_tt-allsum.sum-dsc-rubl-cur    = bf_tt-allsum.sum-dsc-rubl-cur    - bf_tt-allsum.sum-dsc-rubl-acc
    bfpc_tt-allsum.dsc-base-cur        = bf_tt-allsum.dsc-base-cur        - bf_tt-allsum.dsc-base-acc
    bfpc_tt-allsum.dsc-rubl-cur        = bf_tt-allsum.dsc-rubl-cur        - bf_tt-allsum.dsc-rubl-acc
    bfpc_tt-allsum.vat-base-cur        = bf_tt-allsum.vat-base-cur
    bfpc_tt-allsum.vat-rubl-cur        = bf_tt-allsum.vat-rubl-cur
    bfpc_tt-allsum.vat-base-buyer-cur  = bf_tt-allsum.vat-base-buyer-cur  - bf_tt-allsum.vat-base-acc
    bfpc_tt-allsum.vat-rubl-buyer-cur  = bf_tt-allsum.vat-rubl-buyer-cur  - bf_tt-allsum.vat-rubl-acc
    bfpc_tt-allsum.slt-base-cur        = bf_tt-allsum.slt-base-cur        - bf_tt-allsum.slt-base-acc
    bfpc_tt-allsum.slt-rubl-cur        = bf_tt-allsum.slt-rubl-cur        - bf_tt-allsum.slt-rubl-acc
    bfpc_tt-allsum.road-tax-base-cur   = bf_tt-allsum.road-tax-base-cur   - bf_tt-allsum.road-tax-base-acc
    bfpc_tt-allsum.road-tax-rubl-cur   = bf_tt-allsum.road-tax-rubl-cur   - bf_tt-allsum.road-tax-rubl-acc
    bfpc_tt-allsum.excise-base-cur     = bf_tt-allsum.excise-base-cur
    bfpc_tt-allsum.excise-rubl-cur     = bf_tt-allsum.excise-rubl-cur
    bfpc_tt-allsum.sum-dsc-base-acc    = 0
    bfpc_tt-allsum.sum-dsc-rubl-acc    = 0
    bfpc_tt-allsum.sum-dsc-cli-acc     = 0
    bfpc_tt-allsum.dsc-base-acc        = 0
    bfpc_tt-allsum.dsc-rubl-acc        = 0
    bfpc_tt-allsum.dsc-cli-acc         = 0
    bfpc_tt-allsum.vat-base-acc        = 0
    bfpc_tt-allsum.vat-rubl-acc        = 0
    bfpc_tt-allsum.vat-cli-acc         = 0
    bfpc_tt-allsum.slt-base-acc        = 0
    bfpc_tt-allsum.slt-rubl-acc        = 0
    bfpc_tt-allsum.slt-cli-acc         = 0
    bfpc_tt-allsum.road-tax-base-acc   = 0
    bfpc_tt-allsum.road-tax-rubl-acc   = 0
    bfpc_tt-allsum.road-tax-cli-acc    = 0
    bfpc_tt-allsum.excise-base-acc     = 0
    bfpc_tt-allsum.excise-rubl-acc     = 0
    bfpc_tt-allsum.excise-cli-acc      = 0
    bfpc_tt-allsum.transport-base-acc  = 0
    bfpc_tt-allsum.transport-rubl-acc  = 0
    bfpc_tt-allsum.transport-cli-acc   = 0
    bfpc_tt-allsum.other-base-acc      = 0
    bfpc_tt-allsum.other-rubl-acc      = 0
    bfpc_tt-allsum.other-cli-acc       = 0
    .
  assign
    bfspc_tt-allsum.fact-qnty           = bfs_tt-allsum.fact-qnty
    bfspc_tt-allsum.cli-qnty            = bfs_tt-allsum.cli-qnty
    bfspc_tt-allsum.sum-dsc-base-doc    = bfs_tt-allsum.sum-dsc-base-doc    - bfs_tt-allsum.sum-dsc-base-acc
    bfspc_tt-allsum.sum-dsc-rubl-doc    = bfs_tt-allsum.sum-dsc-rubl-doc    - bfs_tt-allsum.sum-dsc-rubl-acc
    bfspc_tt-allsum.dsc-base-doc        = bfs_tt-allsum.dsc-base-doc        - bfs_tt-allsum.dsc-base-acc
    bfspc_tt-allsum.dsc-rubl-doc        = bfs_tt-allsum.dsc-rubl-doc        - bfs_tt-allsum.dsc-rubl-acc
    bfspc_tt-allsum.vat-base-doc        = bfs_tt-allsum.vat-base-doc
    bfspc_tt-allsum.vat-rubl-doc        = bfs_tt-allsum.vat-rubl-doc
    bfspc_tt-allsum.vat-base-buyer-doc  = bfs_tt-allsum.vat-base-buyer-doc  - bfs_tt-allsum.vat-base-acc
    bfspc_tt-allsum.vat-rubl-buyer-doc  = bfs_tt-allsum.vat-rubl-buyer-doc  - bfs_tt-allsum.vat-rubl-acc
    bfspc_tt-allsum.slt-base-doc        = bfs_tt-allsum.slt-base-doc        - bfs_tt-allsum.slt-base-acc
    bfspc_tt-allsum.slt-rubl-doc        = bfs_tt-allsum.slt-rubl-doc        - bfs_tt-allsum.slt-rubl-acc
    bfspc_tt-allsum.road-tax-base-doc   = bfs_tt-allsum.road-tax-base-doc   - bfs_tt-allsum.road-tax-base-acc
    bfspc_tt-allsum.road-tax-rubl-doc   = bfs_tt-allsum.road-tax-rubl-doc   - bfs_tt-allsum.road-tax-rubl-acc
    bfspc_tt-allsum.excise-base-doc     = bfs_tt-allsum.excise-base-doc
    bfspc_tt-allsum.excise-rubl-doc     = bfs_tt-allsum.excise-rubl-doc
    bfspc_tt-allsum.sum-dsc-base-cur    = bfs_tt-allsum.sum-dsc-base-cur    - bfs_tt-allsum.sum-dsc-base-acc
    bfspc_tt-allsum.sum-dsc-rubl-cur    = bfs_tt-allsum.sum-dsc-rubl-cur    - bfs_tt-allsum.sum-dsc-rubl-acc
    bfspc_tt-allsum.dsc-base-cur        = bfs_tt-allsum.dsc-base-cur        - bfs_tt-allsum.dsc-base-acc
    bfspc_tt-allsum.dsc-rubl-cur        = bfs_tt-allsum.dsc-rubl-cur        - bfs_tt-allsum.dsc-rubl-acc
    bfspc_tt-allsum.vat-base-cur        = bfs_tt-allsum.vat-base-cur
    bfspc_tt-allsum.vat-rubl-cur        = bfs_tt-allsum.vat-rubl-cur
    bfspc_tt-allsum.vat-base-buyer-cur  = bfs_tt-allsum.vat-base-buyer-cur  - bfs_tt-allsum.vat-base-acc
    bfspc_tt-allsum.vat-rubl-buyer-cur  = bfs_tt-allsum.vat-rubl-buyer-cur  - bfs_tt-allsum.vat-rubl-acc
    bfspc_tt-allsum.slt-base-cur        = bfs_tt-allsum.slt-base-cur        - bfs_tt-allsum.slt-base-acc
    bfspc_tt-allsum.slt-rubl-cur        = bfs_tt-allsum.slt-rubl-cur        - bfs_tt-allsum.slt-rubl-acc
    bfspc_tt-allsum.road-tax-base-cur   = bfs_tt-allsum.road-tax-base-cur   - bfs_tt-allsum.road-tax-base-acc
    bfspc_tt-allsum.road-tax-rubl-cur   = bfs_tt-allsum.road-tax-rubl-cur   - bfs_tt-allsum.road-tax-rubl-acc
    bfspc_tt-allsum.excise-base-cur     = bfs_tt-allsum.excise-base-cur
    bfspc_tt-allsum.excise-rubl-cur     = bfs_tt-allsum.excise-rubl-cur
    bfspc_tt-allsum.sum-dsc-base-acc    = 0
    bfspc_tt-allsum.sum-dsc-rubl-acc    = 0
    bfspc_tt-allsum.sum-dsc-cli-acc     = 0
    bfspc_tt-allsum.dsc-base-acc        = 0
    bfspc_tt-allsum.dsc-rubl-acc        = 0
    bfspc_tt-allsum.dsc-cli-acc         = 0
    bfspc_tt-allsum.vat-base-acc        = 0
    bfspc_tt-allsum.vat-rubl-acc        = 0
    bfspc_tt-allsum.vat-cli-acc         = 0
    bfspc_tt-allsum.slt-base-acc        = 0
    bfspc_tt-allsum.slt-rubl-acc        = 0
    bfspc_tt-allsum.slt-cli-acc         = 0
    bfspc_tt-allsum.road-tax-base-acc   = 0
    bfspc_tt-allsum.road-tax-rubl-acc   = 0
    bfspc_tt-allsum.road-tax-cli-acc    = 0
    bfspc_tt-allsum.excise-base-acc     = 0
    bfspc_tt-allsum.excise-rubl-acc     = 0
    bfspc_tt-allsum.excise-cli-acc      = 0
    bfspc_tt-allsum.transport-base-acc  = 0
    bfspc_tt-allsum.transport-rubl-acc  = 0
    bfspc_tt-allsum.transport-cli-acc   = 0
    bfspc_tt-allsum.other-base-acc      = 0
    bfspc_tt-allsum.other-rubl-acc      = 0
    bfspc_tt-allsum.other-cli-acc       = 0
    .
  create bfacc_tt-allsum.
  assign
    bfacc_tt-allsum.sum-type = 'сумма_по_консигнации_закупка':U.
  create bfsacc_tt-allsum.
  assign
    bfsacc_tt-allsum.sum-type = 'сумма_по_консигнации_закупка_со_знаком':U.
  assign
    bfacc_tt-allsum.fact-qnty           = bf_tt-allsum.fact-qnty
    bfacc_tt-allsum.cli-qnty            = bf_tt-allsum.cli-qnty
    bfacc_tt-allsum.sum-dsc-base-doc    = bf_tt-allsum.sum-dsc-base-acc
    bfacc_tt-allsum.sum-dsc-rubl-doc    = bf_tt-allsum.sum-dsc-rubl-acc
    bfacc_tt-allsum.dsc-base-doc        = bf_tt-allsum.dsc-base-acc
    bfacc_tt-allsum.dsc-rubl-doc        = bf_tt-allsum.dsc-rubl-acc
    bfacc_tt-allsum.vat-base-doc        = 0
    bfacc_tt-allsum.vat-rubl-doc        = 0
    bfacc_tt-allsum.vat-base-buyer-doc  = bf_tt-allsum.vat-base-acc
    bfacc_tt-allsum.vat-rubl-buyer-doc  = bf_tt-allsum.vat-rubl-acc
    bfacc_tt-allsum.slt-base-doc        = bf_tt-allsum.slt-base-acc
    bfacc_tt-allsum.slt-rubl-doc        = bf_tt-allsum.slt-rubl-acc
    bfacc_tt-allsum.road-tax-base-doc   = bf_tt-allsum.road-tax-base-acc
    bfacc_tt-allsum.road-tax-rubl-doc   = bf_tt-allsum.road-tax-rubl-acc
    bfacc_tt-allsum.excise-base-doc     = bf_tt-allsum.excise-base-acc
    bfacc_tt-allsum.excise-rubl-doc     = bf_tt-allsum.excise-rubl-acc
    bfacc_tt-allsum.sum-dsc-base-cur    = bf_tt-allsum.sum-dsc-base-acc
    bfacc_tt-allsum.sum-dsc-rubl-cur    = bf_tt-allsum.sum-dsc-rubl-acc
    bfacc_tt-allsum.dsc-base-cur        = bf_tt-allsum.dsc-base-acc
    bfacc_tt-allsum.dsc-rubl-cur        = bf_tt-allsum.dsc-rubl-acc
    bfacc_tt-allsum.vat-base-cur        = 0
    bfacc_tt-allsum.vat-rubl-cur        = 0
    bfacc_tt-allsum.vat-base-buyer-cur  = bf_tt-allsum.vat-base-acc
    bfacc_tt-allsum.vat-rubl-buyer-cur  = bf_tt-allsum.vat-rubl-acc
    bfacc_tt-allsum.slt-base-cur        = bf_tt-allsum.slt-base-acc
    bfacc_tt-allsum.slt-rubl-cur        = bf_tt-allsum.slt-rubl-acc
    bfacc_tt-allsum.road-tax-base-cur   = bf_tt-allsum.road-tax-base-acc
    bfacc_tt-allsum.road-tax-rubl-cur   = bf_tt-allsum.road-tax-rubl-acc
    bfacc_tt-allsum.excise-base-cur     = bf_tt-allsum.excise-base-acc
    bfacc_tt-allsum.excise-rubl-cur     = bf_tt-allsum.excise-rubl-acc
    bfacc_tt-allsum.sum-dsc-base-acc    = bf_tt-allsum.sum-dsc-base-acc
    bfacc_tt-allsum.sum-dsc-rubl-acc    = bf_tt-allsum.sum-dsc-rubl-acc
    bfacc_tt-allsum.sum-dsc-cli-acc     = bf_tt-allsum.sum-dsc-cli-acc
    bfacc_tt-allsum.dsc-base-acc        = bf_tt-allsum.dsc-base-acc
    bfacc_tt-allsum.dsc-rubl-acc        = bf_tt-allsum.dsc-rubl-acc
    bfacc_tt-allsum.dsc-cli-acc         = bf_tt-allsum.dsc-cli-acc
    bfacc_tt-allsum.vat-base-acc        = bf_tt-allsum.vat-base-acc
    bfacc_tt-allsum.vat-rubl-acc        = bf_tt-allsum.vat-rubl-acc
    bfacc_tt-allsum.vat-cli-acc         = bf_tt-allsum.vat-cli-acc
    bfacc_tt-allsum.slt-base-acc        = bf_tt-allsum.slt-base-acc
    bfacc_tt-allsum.slt-rubl-acc        = bf_tt-allsum.slt-rubl-acc
    bfacc_tt-allsum.slt-cli-acc         = bf_tt-allsum.slt-cli-acc
    bfacc_tt-allsum.excise-base-acc     = bf_tt-allsum.excise-base-acc
    bfacc_tt-allsum.excise-rubl-acc     = bf_tt-allsum.excise-rubl-acc
    bfacc_tt-allsum.excise-cli-acc      = bf_tt-allsum.excise-cli-acc
    bfacc_tt-allsum.road-tax-base-acc   = bf_tt-allsum.road-tax-base-acc
    bfacc_tt-allsum.road-tax-rubl-acc   = bf_tt-allsum.road-tax-rubl-acc
    bfacc_tt-allsum.road-tax-cli-acc    = bf_tt-allsum.road-tax-cli-acc
    bfacc_tt-allsum.transport-base-acc  = bf_tt-allsum.transport-base-acc
    bfacc_tt-allsum.transport-rubl-acc  = bf_tt-allsum.transport-rubl-acc
    bfacc_tt-allsum.transport-cli-acc   = bf_tt-allsum.transport-cli-acc
    bfacc_tt-allsum.other-base-acc      = bf_tt-allsum.other-base-acc
    bfacc_tt-allsum.other-rubl-acc      = bf_tt-allsum.other-rubl-acc
    bfacc_tt-allsum.other-cli-acc       = bf_tt-allsum.other-cli-acc
    .
  assign
    bfsacc_tt-allsum.fact-qnty           = bfs_tt-allsum.fact-qnty
    bfsacc_tt-allsum.cli-qnty            = bfs_tt-allsum.cli-qnty
    bfsacc_tt-allsum.sum-dsc-base-doc    = bfs_tt-allsum.sum-dsc-base-acc
    bfsacc_tt-allsum.sum-dsc-rubl-doc    = bfs_tt-allsum.sum-dsc-rubl-acc
    bfsacc_tt-allsum.dsc-base-doc        = bfs_tt-allsum.dsc-base-acc
    bfsacc_tt-allsum.dsc-rubl-doc        = bfs_tt-allsum.dsc-rubl-acc
    bfsacc_tt-allsum.vat-base-doc        = 0
    bfsacc_tt-allsum.vat-rubl-doc        = 0
    bfsacc_tt-allsum.vat-base-buyer-doc  = bfs_tt-allsum.vat-base-acc
    bfsacc_tt-allsum.vat-rubl-buyer-doc  = bfs_tt-allsum.vat-rubl-acc
    bfsacc_tt-allsum.slt-base-doc        = bfs_tt-allsum.slt-base-acc
    bfsacc_tt-allsum.slt-rubl-doc        = bfs_tt-allsum.slt-rubl-acc
    bfsacc_tt-allsum.road-tax-base-doc   = bfs_tt-allsum.road-tax-base-acc
    bfsacc_tt-allsum.road-tax-rubl-doc   = bfs_tt-allsum.road-tax-rubl-acc
    bfsacc_tt-allsum.excise-base-doc     = bfs_tt-allsum.excise-base-acc
    bfsacc_tt-allsum.excise-rubl-doc     = bfs_tt-allsum.excise-rubl-acc
    bfsacc_tt-allsum.sum-dsc-base-cur    = bfs_tt-allsum.sum-dsc-base-acc
    bfsacc_tt-allsum.sum-dsc-rubl-cur    = bfs_tt-allsum.sum-dsc-rubl-acc
    bfsacc_tt-allsum.dsc-base-cur        = bfs_tt-allsum.dsc-base-acc
    bfsacc_tt-allsum.dsc-rubl-cur        = bfs_tt-allsum.dsc-rubl-acc
    bfsacc_tt-allsum.vat-base-cur        = 0
    bfsacc_tt-allsum.vat-rubl-cur        = 0
    bfsacc_tt-allsum.vat-base-buyer-cur  = bfs_tt-allsum.vat-base-acc
    bfsacc_tt-allsum.vat-rubl-buyer-cur  = bfs_tt-allsum.vat-rubl-acc
    bfsacc_tt-allsum.slt-base-cur        = bfs_tt-allsum.slt-base-acc
    bfsacc_tt-allsum.slt-rubl-cur        = bfs_tt-allsum.slt-rubl-acc
    bfsacc_tt-allsum.road-tax-base-cur   = bfs_tt-allsum.road-tax-base-acc
    bfsacc_tt-allsum.road-tax-rubl-cur   = bfs_tt-allsum.road-tax-rubl-acc
    bfsacc_tt-allsum.excise-base-cur     = bfs_tt-allsum.excise-base-acc
    bfsacc_tt-allsum.excise-rubl-cur     = bfs_tt-allsum.excise-rubl-acc
    bfsacc_tt-allsum.sum-dsc-base-acc    = bfs_tt-allsum.sum-dsc-base-acc
    bfsacc_tt-allsum.sum-dsc-rubl-acc    = bfs_tt-allsum.sum-dsc-rubl-acc
    bfsacc_tt-allsum.sum-dsc-cli-acc     = bfs_tt-allsum.sum-dsc-cli-acc
    bfsacc_tt-allsum.dsc-base-acc        = bfs_tt-allsum.dsc-base-acc
    bfsacc_tt-allsum.dsc-rubl-acc        = bfs_tt-allsum.dsc-rubl-acc
    bfsacc_tt-allsum.dsc-cli-acc         = bfs_tt-allsum.dsc-cli-acc
    bfsacc_tt-allsum.vat-base-acc        = bfs_tt-allsum.vat-base-acc
    bfsacc_tt-allsum.vat-rubl-acc        = bfs_tt-allsum.vat-rubl-acc
    bfsacc_tt-allsum.vat-cli-acc         = bfs_tt-allsum.vat-cli-acc
    bfsacc_tt-allsum.slt-base-acc        = bfs_tt-allsum.slt-base-acc
    bfsacc_tt-allsum.slt-rubl-acc        = bfs_tt-allsum.slt-rubl-acc
    bfsacc_tt-allsum.slt-cli-acc         = bfs_tt-allsum.slt-cli-acc
    bfsacc_tt-allsum.excise-base-acc     = bfs_tt-allsum.excise-base-acc
    bfsacc_tt-allsum.excise-rubl-acc     = bfs_tt-allsum.excise-rubl-acc
    bfsacc_tt-allsum.excise-cli-acc      = bfs_tt-allsum.excise-cli-acc
    bfsacc_tt-allsum.road-tax-base-acc   = bfs_tt-allsum.road-tax-base-acc
    bfsacc_tt-allsum.road-tax-rubl-acc   = bfs_tt-allsum.road-tax-rubl-acc
    bfsacc_tt-allsum.road-tax-cli-acc    = bfs_tt-allsum.road-tax-cli-acc
    bfsacc_tt-allsum.transport-base-acc  = bfs_tt-allsum.transport-base-acc
    bfsacc_tt-allsum.transport-rubl-acc  = bfs_tt-allsum.transport-rubl-acc
    bfsacc_tt-allsum.transport-cli-acc   = bfs_tt-allsum.transport-cli-acc
    bfsacc_tt-allsum.other-base-acc      = bfs_tt-allsum.other-base-acc
    bfsacc_tt-allsum.other-rubl-acc      = bfs_tt-allsum.other-rubl-acc
    bfsacc_tt-allsum.other-cli-acc       = bfs_tt-allsum.other-cli-acc
    .
end.
otherwise do:
  return error substitute ("Неизвестный тип приобретения &1 по партии с кодом &2 по документу &3, порожденную документом &4 по товару &5 &6 &7.",
                           cl_tt-clcparts.purch-code,
                           cl_tt-clcparts.part-code,
                           cl_tt-clcparts.out-code,
                           cl_tt-clcparts.in-code,
                           cl_tt-clcparts.artic,
                           cl_tt-clcparts.prod-type,
                           cl_tt-clcparts.prod-code).
end.
end case.
end.
end procedure.
procedure clcprtsl_calc-line :
define input  parameter parrec-line as recid no-undo.
define variable v-tax-date         as   date                     no-undo.
define variable v-vat-pc           like ub.doc-line.vat-pc       no-undo.
define variable varr-b             as   character                no-undo.
define variable varr-btype         as   character                no-undo.
define variable varcur-base        like ub.gds-dtl.price-base    no-undo.
define variable varcur-road-tax    like ub.doc-line.road-tax     no-undo.
define variable varcur-excise      like ub.doc-line.excise       no-undo.
define variable varcur-vat-pc      like ub.doc-line.vat-pc       no-undo.
define variable varcur-cons-vat-pc like ub.doc-line.cons-vat-pc  no-undo.
define variable varcur-slt-pc      like ub.doc-line.slt-pc       no-undo.
define variable varcur-fact-qnty   like ub.gds-dtl.fact-qnty     no-undo.
define variable varb-code          like ub.bar-code.b-code       no-undo.
define variable vardoc-num         like ub.price-doc.doc-num     no-undo.
define variable varprice-sale      like ub.price-list.price-sale no-undo.
define variable varroad-tax        like ub.price-list.road-tax   no-undo.
define variable varexcise          like ub.price-list.excise     no-undo.
define variable varlastcur-base        like ub.gds-dtl.price-base no-undo.
define variable varlastcur-road-tax    like ub.gds-dtl.price-base no-undo.
define variable varlastcur-excise      like ub.gds-dtl.price-base     no-undo.
define variable v-b-pcode          like ub.bar-code.b-code     no-undo.
define variable v-varsum           as decimal                  no-undo.
define variable varprice-salef as decimal   no-undo .
define buffer bf_trn-doc             for ub.trn-doc.
define buffer bf_doc-line            for ub.doc-line.
define buffer bf_gds-dtl             for ub.gds-dtl.
define buffer bf_goods               for ub.goods.
define buffer bf_parts               for ub.parts.
define buffer bf_sysconf             for ub.sysconf.
define buffer bf_tt-allsum-line      for tt-allsum-line.
define buffer bfs_tt-allsum-line     for tt-allsum-line.
define buffer bfo_tt-allsum-line     for tt-allsum-line.
define buffer bfos_tt-allsum-line    for tt-allsum-line.
define buffer buf_parts        for ub.parts.
v-calcbypart = no.
do on error undo, return error return-value :
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varr-b
  )  .
  find first bf_doc-line where recid (bf_doc-line) = parrec-line no-lock.
  find first bf_trn-doc where bf_trn-doc.doc-code = bf_doc-line.doc-code no-lock.
  find first bf_goods where bf_goods.artic     = bf_doc-line.artic     and
                            bf_goods.prod-type = bf_doc-line.prod-type and
                            bf_goods.prod-code = bf_doc-line.prod-code no-lock.
  if bf_trn-doc.fact-date <> ?        then do:
    assign v-tax-date = bf_trn-doc.fact-date.
  end.
  else do:
    assign v-tax-date = ?.
  end.
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  bf_goods.gds-code
  ,input  '1':U
  ,input  v-tax-date
  ,input  bf_trn-doc.host-code
  ,input  bf_trn-doc.obj-type
  ,input  bf_trn-doc.obj-code
  ,output v-vat-pc
  ) no-error .
  if error-status :error
  or v-vat-pc = ? then do:
     return error substitute ("Ошибка при поиске НДС для товара &1 &2 &3", bf_goods.artic, bf_goods.prod-type, bf_goods.prod-code).
  end.
  if bf_goods.gds-type = 'у':U or
     bf_trn-doc.status_ = 'запрос':U then do:
    for each bf_tt-allsum-line
    on error undo, return error return-value
     :
      delete bf_tt-allsum-line.
    end.
    create bf_tt-allsum-line.
    assign
     bf_tt-allsum-line.sum-type = 'основная_сумма':U.
    for each bf_gds-dtl where bf_gds-dtl.doc-code  = bf_doc-line.doc-code  and
                              bf_gds-dtl.artic     = bf_doc-line.artic     and
                              bf_gds-dtl.prod-type = bf_doc-line.prod-type and
                              bf_gds-dtl.prod-code = bf_doc-line.prod-code no-lock on error undo, return error return-value :
      assign
        bf_tt-allsum-line.fact-qnty            =  bf_tt-allsum-line.fact-qnty        + bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.sum-dsc-base-doc     =  bf_tt-allsum-line.sum-dsc-base-doc + (bf_gds-dtl.price-base - bf_gds-dtl.discnt-base) * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.sum-dsc-rubl-doc     =  bf_tt-allsum-line.sum-dsc-rubl-doc + (bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl) * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.dsc-base-doc         =  bf_tt-allsum-line.dsc-base-doc     + bf_gds-dtl.discnt-base * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.dsc-rubl-doc         =  bf_tt-allsum-line.dsc-rubl-doc     + bf_gds-dtl.discnt-rubl * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.sum-dsc-base-cur     =  bf_tt-allsum-line.sum-dsc-base-cur + (if varr-b = "base" then bf_gds-dtl.cur-base else bf_gds-dtl.cur-base / bf_trn-doc.exch-rate * bf_trn-doc.exch-scale) * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.sum-dsc-rubl-cur     =  bf_tt-allsum-line.sum-dsc-rubl-cur + (if varr-b = "rubl" then bf_gds-dtl.cur-base else bf_gds-dtl.cur-base * bf_trn-doc.exch-rate / bf_trn-doc.exch-scale) * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.sum-dsc-base-acc     =  bf_tt-allsum-line.sum-dsc-base-acc + bf_doc-line.price-base * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.sum-dsc-rubl-acc     =  bf_tt-allsum-line.sum-dsc-rubl-acc + bf_doc-line.price-rubl * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.sum-dsc-cli-acc      =  ?
        bf_tt-allsum-line.vat-base-acc         =  bf_tt-allsum-line.vat-base-acc     + bf_doc-line.price-base * v-vat-pc / (100 + v-vat-pc) * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.vat-rubl-acc         =  bf_tt-allsum-line.vat-rubl-acc     + bf_doc-line.price-rubl * v-vat-pc / (100 + v-vat-pc) * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.vat-cli-acc          =  ?
        .
    end.
    assign
      bf_tt-allsum-line.cli-qnty             =  ?
      bf_tt-allsum-line.slt-base-doc         =  bf_tt-allsum-line.sum-dsc-base-doc * bf_doc-line.slt-pc / (100 + bf_doc-line.slt-pc)
      bf_tt-allsum-line.slt-rubl-doc         =  bf_tt-allsum-line.sum-dsc-rubl-doc * bf_doc-line.slt-pc / (100 + bf_doc-line.slt-pc)
      bf_tt-allsum-line.vat-base-buyer-doc   =  (bf_tt-allsum-line.sum-dsc-base-doc - bf_tt-allsum-line.slt-base-doc) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc)
      bf_tt-allsum-line.vat-rubl-buyer-doc   =  (bf_tt-allsum-line.sum-dsc-rubl-doc - bf_tt-allsum-line.slt-rubl-doc) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc)
      bf_tt-allsum-line.road-tax-base-doc    =  0
      bf_tt-allsum-line.road-tax-rubl-doc    =  0
      bf_tt-allsum-line.excise-base-doc      =  0
      bf_tt-allsum-line.excise-rubl-doc      =  0
      bf_tt-allsum-line.vat-base-doc         =  bf_tt-allsum-line.vat-base-buyer-doc
      bf_tt-allsum-line.vat-rubl-doc         =  bf_tt-allsum-line.vat-rubl-buyer-doc
      bf_tt-allsum-line.dsc-base-cur         =  0
      bf_tt-allsum-line.dsc-rubl-cur         =  0
      bf_tt-allsum-line.slt-base-cur         =  bf_tt-allsum-line.sum-dsc-base-cur * bf_doc-line.slt-pc / (100 + bf_doc-line.slt-pc)
      bf_tt-allsum-line.slt-rubl-cur         =  bf_tt-allsum-line.sum-dsc-rubl-cur * bf_doc-line.slt-pc / (100 + bf_doc-line.slt-pc)
      bf_tt-allsum-line.vat-base-buyer-cur   =  (bf_tt-allsum-line.sum-dsc-base-cur - bf_tt-allsum-line.slt-base-cur) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc)
      bf_tt-allsum-line.vat-rubl-buyer-cur   =  (bf_tt-allsum-line.sum-dsc-rubl-cur - bf_tt-allsum-line.slt-rubl-cur) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc)
      bf_tt-allsum-line.road-tax-base-cur    =  0
      bf_tt-allsum-line.road-tax-rubl-cur    =  0
      bf_tt-allsum-line.excise-base-cur      =  0
      bf_tt-allsum-line.excise-rubl-cur      =  0
      bf_tt-allsum-line.vat-base-cur         =  bf_tt-allsum-line.vat-base-buyer-cur
      bf_tt-allsum-line.vat-rubl-cur         =  bf_tt-allsum-line.vat-rubl-buyer-cur
      bf_tt-allsum-line.dsc-base-acc         =  0
      bf_tt-allsum-line.dsc-rubl-acc         =  0
      bf_tt-allsum-line.dsc-cli-acc          =  0
      bf_tt-allsum-line.slt-base-acc         =  0
      bf_tt-allsum-line.slt-rubl-acc         =  0
      bf_tt-allsum-line.slt-cli-acc          =  0
      bf_tt-allsum-line.road-tax-base-acc    =  0
      bf_tt-allsum-line.road-tax-rubl-acc    =  0
      bf_tt-allsum-line.road-tax-cli-acc     =  0
      bf_tt-allsum-line.excise-base-acc      =  0
      bf_tt-allsum-line.excise-rubl-acc      =  0
      bf_tt-allsum-line.excise-cli-acc       =  0
      bf_tt-allsum-line.transport-base-acc   =  0
      bf_tt-allsum-line.transport-rubl-acc   =  0
      bf_tt-allsum-line.transport-cli-acc    =  0
      bf_tt-allsum-line.other-base-acc       =  0
      bf_tt-allsum-line.other-rubl-acc       =  0
      bf_tt-allsum-line.other-cli-acc        =  0
      .
    create bfs_tt-allsum-line.
    assign
    bfs_tt-allsum-line.sum-type = 'основная_сумма_со_знаком':U.
    if bf_trn-doc.doc-type = 'инв':U or
       bf_trn-doc.doc-type = 'при':U    or
       bf_trn-doc.doc-type = 'возврат':U    then do:
       buffer-copy bf_tt-allsum-line except bf_tt-allsum-line.sum-type to bfs_tt-allsum-line.
    end.
    else do:
      assign
        bfs_tt-allsum-line.fact-qnty           =  - bf_tt-allsum-line.fact-qnty
        bfs_tt-allsum-line.cli-qnty            =  - bf_tt-allsum-line.cli-qnty
        bfs_tt-allsum-line.sum-dsc-base-doc    =  - bf_tt-allsum-line.sum-dsc-base-doc
        bfs_tt-allsum-line.sum-dsc-rubl-doc    =  - bf_tt-allsum-line.sum-dsc-rubl-doc
        bfs_tt-allsum-line.dsc-base-doc        =  - bf_tt-allsum-line.dsc-base-doc
        bfs_tt-allsum-line.dsc-rubl-doc        =  - bf_tt-allsum-line.dsc-rubl-doc
        bfs_tt-allsum-line.vat-base-doc        =  - bf_tt-allsum-line.vat-base-doc
        bfs_tt-allsum-line.vat-rubl-doc        =  - bf_tt-allsum-line.vat-rubl-doc
        bfs_tt-allsum-line.vat-base-buyer-doc  =  - bf_tt-allsum-line.vat-base-buyer-doc
        bfs_tt-allsum-line.vat-rubl-buyer-doc  =  - bf_tt-allsum-line.vat-rubl-buyer-doc
        bfs_tt-allsum-line.slt-base-doc        =  - bf_tt-allsum-line.slt-base-doc
        bfs_tt-allsum-line.slt-rubl-doc        =  - bf_tt-allsum-line.slt-rubl-doc
        bfs_tt-allsum-line.road-tax-base-doc   =  - bf_tt-allsum-line.road-tax-base-doc
        bfs_tt-allsum-line.road-tax-rubl-doc   =  - bf_tt-allsum-line.road-tax-rubl-doc
        bfs_tt-allsum-line.excise-base-doc     =  - bf_tt-allsum-line.excise-base-doc
        bfs_tt-allsum-line.excise-rubl-doc     =  - bf_tt-allsum-line.excise-rubl-doc
        bfs_tt-allsum-line.sum-dsc-base-cur    =  - bf_tt-allsum-line.sum-dsc-base-cur
        bfs_tt-allsum-line.sum-dsc-rubl-cur    =  - bf_tt-allsum-line.sum-dsc-rubl-cur
        bfs_tt-allsum-line.dsc-base-cur        =  - bf_tt-allsum-line.dsc-base-cur
        bfs_tt-allsum-line.dsc-rubl-cur        =  - bf_tt-allsum-line.dsc-rubl-cur
        bfs_tt-allsum-line.vat-base-cur        =  - bf_tt-allsum-line.vat-base-cur
        bfs_tt-allsum-line.vat-rubl-cur        =  - bf_tt-allsum-line.vat-rubl-cur
        bfs_tt-allsum-line.vat-base-buyer-cur  =  - bf_tt-allsum-line.vat-base-buyer-cur
        bfs_tt-allsum-line.vat-rubl-buyer-cur  =  - bf_tt-allsum-line.vat-rubl-buyer-cur
        bfs_tt-allsum-line.slt-base-cur        =  - bf_tt-allsum-line.slt-base-cur
        bfs_tt-allsum-line.slt-rubl-cur        =  - bf_tt-allsum-line.slt-rubl-cur
        bfs_tt-allsum-line.road-tax-base-cur   =  - bf_tt-allsum-line.road-tax-base-cur
        bfs_tt-allsum-line.road-tax-rubl-cur   =  - bf_tt-allsum-line.road-tax-rubl-cur
        bfs_tt-allsum-line.excise-base-cur     =  - bf_tt-allsum-line.excise-base-cur
        bfs_tt-allsum-line.excise-rubl-cur     =  - bf_tt-allsum-line.excise-rubl-cur
        bfs_tt-allsum-line.sum-dsc-base-acc    =  - bf_tt-allsum-line.sum-dsc-base-acc
        bfs_tt-allsum-line.sum-dsc-rubl-acc    =  - bf_tt-allsum-line.sum-dsc-rubl-acc
        bfs_tt-allsum-line.sum-dsc-cli-acc     =  - bf_tt-allsum-line.sum-dsc-cli-acc
        bfs_tt-allsum-line.dsc-base-acc        =  - bf_tt-allsum-line.dsc-base-acc
        bfs_tt-allsum-line.dsc-rubl-acc        =  - bf_tt-allsum-line.dsc-rubl-acc
        bfs_tt-allsum-line.dsc-cli-acc         =  - bf_tt-allsum-line.dsc-cli-acc
        bfs_tt-allsum-line.vat-base-acc        =  - bf_tt-allsum-line.vat-base-acc
        bfs_tt-allsum-line.vat-rubl-acc        =  - bf_tt-allsum-line.vat-rubl-acc
        bfs_tt-allsum-line.vat-cli-acc         =  - bf_tt-allsum-line.vat-cli-acc
        bfs_tt-allsum-line.slt-base-acc        =  - bf_tt-allsum-line.slt-base-acc
        bfs_tt-allsum-line.slt-rubl-acc        =  - bf_tt-allsum-line.slt-rubl-acc
        bfs_tt-allsum-line.slt-cli-acc         =  - bf_tt-allsum-line.slt-cli-acc
        bfs_tt-allsum-line.road-tax-base-acc   =  - bf_tt-allsum-line.road-tax-base-acc
        bfs_tt-allsum-line.road-tax-rubl-acc   =  - bf_tt-allsum-line.road-tax-rubl-acc
        bfs_tt-allsum-line.road-tax-cli-acc    =  - bf_tt-allsum-line.road-tax-cli-acc
        bfs_tt-allsum-line.excise-base-acc     =  - bf_tt-allsum-line.excise-base-acc
        bfs_tt-allsum-line.excise-rubl-acc     =  - bf_tt-allsum-line.excise-rubl-acc
        bfs_tt-allsum-line.excise-cli-acc      =  - bf_tt-allsum-line.excise-cli-acc
        bfs_tt-allsum-line.transport-base-acc  =  - bf_tt-allsum-line.transport-base-acc
        bfs_tt-allsum-line.transport-rubl-acc  =  - bf_tt-allsum-line.transport-rubl-acc
        bfs_tt-allsum-line.transport-cli-acc   =  - bf_tt-allsum-line.transport-cli-acc
        bfs_tt-allsum-line.other-base-acc      =  - bf_tt-allsum-line.other-base-acc
        bfs_tt-allsum-line.other-rubl-acc      =  - bf_tt-allsum-line.other-rubl-acc
        bfs_tt-allsum-line.other-cli-acc       =  - bf_tt-allsum-line.other-cli-acc
        .
    end.
    create bfo_tt-allsum-line.
    assign
      bfo_tt-allsum-line.sum-type = 'сумма_по_услуге':U.
    buffer-copy bf_tt-allsum-line except bf_tt-allsum-line.sum-type to bfo_tt-allsum-line.
    create bfos_tt-allsum-line.
    assign
      bfos_tt-allsum-line.sum-type = 'сумма_по_услуге_со_знаком':U.
    buffer-copy bfs_tt-allsum-line except bfs_tt-allsum-line.sum-type to bfos_tt-allsum-line.
  end.
  else do:
    assign
      varlastcur-base      = 0
      varlastcur-road-tax  = 0
      varlastcur-excise    = 0
      varcur-base          = 0
      varcur-road-tax      = 0
      varcur-excise        = 0
      varcur-vat-pc        = 0
      varcur-slt-pc        = 0
      varcur-fact-qnty     = 0
    .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  bf_goods.gds-code
  ,input  ?
  ,output varb-code
  )  .
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcprcex in g#library
  (input  bf_trn-doc.obj-type
  ,input  bf_trn-doc.obj-code
  ,input  varb-code
  ,input  0
  ,input  bf_trn-doc.fact-order
  ,output vardoc-num
  ,output varprice-sale
  ,output varroad-tax
  ,output varexcise
  ,output varcur-vat-pc
  ,output varcur-slt-pc
  )  .
    if varprice-sale = ?
    then do:
      assign
        varcur-vat-pc = 0
        varcur-slt-pc = 0
      .
    end.
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  bf_goods.gds-code
  ,input  '1':U
  ,input  bf_trn-doc.fact-date
  ,input  bf_trn-doc.host-code
  ,input  bf_trn-doc.obj-type
  ,input  bf_trn-doc.obj-code
  ,output varcur-vat-pc
  ) no-error .
    if varcur-vat-pc = ?
    then do:
      return error substitute ("Ошибка при поиске НДС для товара &1 &2 &3 документ &4", bf_goods.artic, bf_goods.prod-type, bf_goods.prod-code, bf_trn-doc.doc-code).
    end.
    if varcur-slt-pc = ?
    then do:
      return error substitute ("Ошибка при поиске НДС для товара &1 &2 &3 документ &4", bf_goods.artic, bf_goods.prod-type, bf_goods.prod-code, bf_trn-doc.doc-code).
    end.
    v-calcbypart = no.
    if bf_doc-line.whole-send-news = integer('1':U)   then
    v-calcbypart = yes.
    else do:
    for each bf_gds-dtl no-lock
      where bf_gds-dtl.doc-code  = bf_doc-line.doc-code
        and bf_gds-dtl.artic     = bf_doc-line.artic
        and bf_gds-dtl.prod-type = bf_doc-line.prod-type
        and bf_gds-dtl.prod-code = bf_doc-line.prod-code
    on error undo, return error return-value
    :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  bf_goods.gds-code
  ,input  bf_gds-dtl.prt-code
  ,output varb-code
  ) no-error .
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  bf_trn-doc.obj-type
  ,input  bf_trn-doc.obj-code
  ,input  varb-code
  ,input  0
  ,input  bf_trn-doc.fact-order
  ,output vardoc-num
  ,output varprice-sale
  ,output varroad-tax
  ,output varexcise
  )  .
          if varprice-sale = ?
          then do:
            assign
              varprice-sale = 0
              varroad-tax   = 0
              varexcise     = 0
            .
          end.
          assign
            varlastcur-base     = varprice-sale
            varlastcur-road-tax = varroad-tax
            varlastcur-excise   = varexcise
            varcur-base         = varcur-base      + varprice-sale * bf_gds-dtl.fact-qnty
            varcur-road-tax     = varcur-road-tax  + varroad-tax   * bf_gds-dtl.fact-qnty
            varcur-excise       = varcur-excise    + varexcise     * bf_gds-dtl.fact-qnty
            varcur-fact-qnty    = varcur-fact-qnty + bf_gds-dtl.fact-qnty
          .
      end.
    end.
    if varcur-fact-qnty = 0 then do:
      assign
        varcur-base      = varlastcur-base
        varcur-road-tax  = varlastcur-road-tax
        varcur-excise    = varlastcur-excise
      .
    end.
    else do:
      assign
        varcur-base      = varcur-base      / varcur-fact-qnty
        varcur-road-tax  = varcur-road-tax  / varcur-fact-qnty
        varcur-excise    = varcur-excise    / varcur-fact-qnty
      .
    end.
    if varcur-vat-pc = ?
    then do:
      return error substitute ("Нет текущего продажного НДС по товару &1 &2 &3", bf_goods.artic, bf_goods.prod-type, bf_goods.prod-code).
    end.
    if varcur-slt-pc = ?
    then do:
      return error substitute ("Нет текущего продажного НП по товару &1 &2 &3", bf_goods.artic, bf_goods.prod-type, bf_goods.prod-code).
    end.
    find first bf_sysconf where bf_sysconf.host-code = bf_trn-doc.host-code no-lock.
    assign
      varcur-cons-vat-pc = bf_sysconf.cons-vat-pc.
    if varcur-cons-vat-pc = ? then do:
      return error substitute ("Нет текущего продажного консигнационного НДС по фирме &1", bf_trn-doc.host-code).
    end.
    define buffer buf_tt-clcparts for tt-clcparts .
    for each buf_tt-clcparts
    on error undo, return error return-value
    :
      delete buf_tt-clcparts.
    end.
    for each bf_parts no-lock
      where bf_parts.out-code  = bf_doc-line.doc-code
        and bf_parts.obj-type  = bf_doc-line.obj-type
        and bf_parts.obj-code  = bf_doc-line.obj-code
        and bf_parts.artic     = bf_doc-line.artic
        and bf_parts.prod-type = bf_doc-line.prod-type
        and bf_parts.prod-code = bf_doc-line.prod-code
    on error undo, return error return-value
    :
      create buf_tt-clcparts .
      buffer-copy bf_parts to buf_tt-clcparts .
      if v-calcbypart = yes   then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run partbcod in g#library
  (buffer bf_parts
  ,output v-b-pcode
  ) no-error .
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  bf_parts.obj-type
  ,input  bf_parts.obj-code
  ,input  v-b-pcode
  ,input  0
  ,input  bf_trn-doc.fact-order
  ,output vardoc-num
  ,output varprice-salef
  ,output varroad-tax
  ,output varexcise
  ) no-error .
          if varprice-sale = ?
          then do:
            assign
              varprice-salef = 0
              varroad-tax   = 0
              varexcise     = 0
            .
          end.
          assign
          part-cur-base  = varprice-salef
          part-cur-road-tax  = varroad-tax
          part-cur-excise = varexcise.
      end.
    end.
    run clcprtsl_calc-ttable in this-procedure
      (input yes,
       input yes,
       input bf_doc-line.road-tax,
       input bf_doc-line.excise,
       input bf_doc-line.vat-pc,
       input bf_doc-line.cons-vat-pc,
       input bf_doc-line.slt-pc,
       input bf_trn-doc.base-rate,
       input bf_trn-doc.base-scale,
       input varr-b,
       input varcur-base,
       input varcur-road-tax,
       input varcur-excise,
       input varcur-vat-pc,
       input varcur-cons-vat-pc,
       input varcur-slt-pc
       ) no-error.
    if error-status:error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры clcprtsl_calc-ttable." skip
        return-value skip
        trim(error-status :get-message(1))
        trim(error-status :get-message(2))
        trim(error-status :get-message(3))
        trim(error-status :get-message(4))
        trim(error-status :get-message(5)) skip
        view-as alert-box error.
      undo, return error .
    end.
  end.
end.
end.
procedure clcprtsl_calc-ttable :
define input parameter paris-doc           as   logical                 no-undo.
define input parameter paris-cur           as   logical                 no-undo.
define input parameter parroad-tax         like ub.doc-line.road-tax    no-undo.
define input parameter parexcise           like ub.doc-line.excise      no-undo.
define input parameter parvat-pc           like ub.doc-line.vat-pc      no-undo.
define input parameter parcons-vat-pc      like ub.doc-line.cons-vat-pc no-undo.
define input parameter parslt-pc           like ub.doc-line.slt-pc      no-undo.
define input parameter parbase-rate        like ub.trn-doc.base-rate    no-undo.
define input parameter parbase-scale       like ub.trn-doc.base-scale   no-undo.
define input parameter parr-b              as   character               no-undo.
define input parameter parcur-base         like ub.gds-dtl.cur-base     no-undo.
define input parameter parcur-road-tax     like ub.doc-line.road-tax    no-undo.
define input parameter parcur-excise       like ub.doc-line.excise      no-undo.
define input parameter parcur-vat-pc       like ub.doc-line.vat-pc      no-undo.
define input parameter parcurcons-vat-pc   like ub.doc-line.cons-vat-pc no-undo.
define input parameter parcurslt-pc        like ub.doc-line.slt-pc      no-undo.
define buffer bf_tt-allsum      for tt-allsum.
define buffer bf_tt-clcparts    for tt-clcparts.
define buffer bf_tt-allsum-line for tt-allsum-line.
define variable v-b-pcode          like ub.bar-code.b-code     no-undo.
define variable vardoc-num         like ub.price-doc.doc-num     no-undo.
define variable varprice-sale      like ub.price-list.price-sale no-undo.
define variable varroad-tax        like ub.price-list.road-tax   no-undo.
define variable varexcise          like ub.price-list.excise     no-undo.
do on error undo, return error return-value :
for each bf_tt-allsum-line
on error undo, return error return-value
 :
  delete bf_tt-allsum-line.
end.
for each bf_tt-allsum
on error undo, return error return-value
:
  delete bf_tt-allsum.
end.
for each bf_tt-clcparts
on error undo, return error return-value
:
if v-calcbypart then do:
          assign
          parcur-base =   bf_tt-clcparts.part-cur-base
          parcur-road-tax = bf_tt-clcparts.part-cur-road-tax
          parcur-excise =   bf_tt-clcparts.part-cur-excise
          .
end.
   run clcprtsl_calc-parts in this-procedure (
     input recid(bf_tt-clcparts),
     input paris-doc,
     input paris-cur,
     input parroad-tax,
     input parexcise,
     input parvat-pc,
     input parcons-vat-pc,
     input parslt-pc,
     input parbase-rate,
     input parbase-scale,
     input parr-b,
     input parcur-base,
     input parcur-road-tax,
     input parcur-excise,
     input parcur-vat-pc,
     input parcurcons-vat-pc,
     input parcurslt-pc
     ) no-error.
  if error-status:error then do:
    message
      vss-workfile vss-revision vss-description skip
      vss-include-info17 skip
      "Ошибка при обсчете партии" skip
      "Документ партии " bf_tt-clcparts.out-code skip
      "Товар" bf_tt-clcparts.artic bf_tt-clcparts.prod-type bf_tt-clcparts.prod-code skip
      return-value skip
      error-status:get-message(1) skip
      error-status:get-message(2) skip
      error-status:get-message(3) skip
      view-as alert-box error .
    undo, return error .
  end.
  for each bf_tt-allsum on error undo, return error return-value :
    find first bf_tt-allsum-line where bf_tt-allsum-line.sum-type = bf_tt-allsum.sum-type no-error.
    if not available bf_tt-allsum-line then do:
      create bf_tt-allsum-line.
      assign
        bf_tt-allsum-line.sum-type = bf_tt-allsum.sum-type.
    end.
    assign
      bf_tt-allsum-line.fact-qnty              = bf_tt-allsum-line.fact-qnty            + bf_tt-allsum.fact-qnty
      bf_tt-allsum-line.cli-qnty               = bf_tt-allsum-line.cli-qnty             + bf_tt-allsum.cli-qnty
      bf_tt-allsum-line.sum-dsc-base-doc       = bf_tt-allsum-line.sum-dsc-base-doc     + bf_tt-allsum.sum-dsc-base-doc
      bf_tt-allsum-line.sum-dsc-rubl-doc       = bf_tt-allsum-line.sum-dsc-rubl-doc     + bf_tt-allsum.sum-dsc-rubl-doc
      bf_tt-allsum-line.dsc-base-doc           = bf_tt-allsum-line.dsc-base-doc         + bf_tt-allsum.dsc-base-doc
      bf_tt-allsum-line.dsc-rubl-doc           = bf_tt-allsum-line.dsc-rubl-doc         + bf_tt-allsum.dsc-rubl-doc
      bf_tt-allsum-line.vat-base-doc           = bf_tt-allsum-line.vat-base-doc         + bf_tt-allsum.vat-base-doc
      bf_tt-allsum-line.vat-rubl-doc           = bf_tt-allsum-line.vat-rubl-doc         + bf_tt-allsum.vat-rubl-doc
      bf_tt-allsum-line.vat-base-buyer-doc     = bf_tt-allsum-line.vat-base-buyer-doc   + bf_tt-allsum.vat-base-buyer-doc
      bf_tt-allsum-line.vat-rubl-buyer-doc     = bf_tt-allsum-line.vat-rubl-buyer-doc   + bf_tt-allsum.vat-rubl-buyer-doc
      bf_tt-allsum-line.slt-base-doc           = bf_tt-allsum-line.slt-base-doc         + bf_tt-allsum.slt-base-doc
      bf_tt-allsum-line.slt-rubl-doc           = bf_tt-allsum-line.slt-rubl-doc         + bf_tt-allsum.slt-rubl-doc
      bf_tt-allsum-line.road-tax-base-doc      = bf_tt-allsum-line.road-tax-base-doc    + bf_tt-allsum.road-tax-base-doc
      bf_tt-allsum-line.road-tax-rubl-doc      = bf_tt-allsum-line.road-tax-rubl-doc    + bf_tt-allsum.road-tax-rubl-doc
      bf_tt-allsum-line.excise-base-doc        = bf_tt-allsum-line.excise-base-doc      + bf_tt-allsum.excise-base-doc
      bf_tt-allsum-line.excise-rubl-doc        = bf_tt-allsum-line.excise-rubl-doc      + bf_tt-allsum.excise-rubl-doc
      bf_tt-allsum-line.sum-dsc-base-cur       = bf_tt-allsum-line.sum-dsc-base-cur     + bf_tt-allsum.sum-dsc-base-cur
      bf_tt-allsum-line.sum-dsc-rubl-cur       = bf_tt-allsum-line.sum-dsc-rubl-cur     + bf_tt-allsum.sum-dsc-rubl-cur
      bf_tt-allsum-line.dsc-base-cur           = bf_tt-allsum-line.dsc-base-cur         + bf_tt-allsum.dsc-base-cur
      bf_tt-allsum-line.dsc-rubl-cur           = bf_tt-allsum-line.dsc-rubl-cur         + bf_tt-allsum.dsc-rubl-cur
      bf_tt-allsum-line.vat-base-cur           = bf_tt-allsum-line.vat-base-cur         + bf_tt-allsum.vat-base-cur
      bf_tt-allsum-line.vat-rubl-cur           = bf_tt-allsum-line.vat-rubl-cur         + bf_tt-allsum.vat-rubl-cur
      bf_tt-allsum-line.vat-base-buyer-cur     = bf_tt-allsum-line.vat-base-buyer-cur   + bf_tt-allsum.vat-base-buyer-cur
      bf_tt-allsum-line.vat-rubl-buyer-cur     = bf_tt-allsum-line.vat-rubl-buyer-cur   + bf_tt-allsum.vat-rubl-buyer-cur
      bf_tt-allsum-line.slt-base-cur           = bf_tt-allsum-line.slt-base-cur         + bf_tt-allsum.slt-base-cur
      bf_tt-allsum-line.slt-rubl-cur           = bf_tt-allsum-line.slt-rubl-cur         + bf_tt-allsum.slt-rubl-cur
      bf_tt-allsum-line.road-tax-base-cur      = bf_tt-allsum-line.road-tax-base-cur    + bf_tt-allsum.road-tax-base-cur
      bf_tt-allsum-line.road-tax-rubl-cur      = bf_tt-allsum-line.road-tax-rubl-cur    + bf_tt-allsum.road-tax-rubl-cur
      bf_tt-allsum-line.excise-base-cur        = bf_tt-allsum-line.excise-base-cur      + bf_tt-allsum.excise-base-cur
      bf_tt-allsum-line.excise-rubl-cur        = bf_tt-allsum-line.excise-rubl-cur      + bf_tt-allsum.excise-rubl-cur
      bf_tt-allsum-line.sum-dsc-base-acc       = bf_tt-allsum-line.sum-dsc-base-acc     + bf_tt-allsum.sum-dsc-base-acc
      bf_tt-allsum-line.sum-dsc-rubl-acc       = bf_tt-allsum-line.sum-dsc-rubl-acc     + bf_tt-allsum.sum-dsc-rubl-acc
      bf_tt-allsum-line.sum-dsc-cli-acc        = bf_tt-allsum-line.sum-dsc-cli-acc      + bf_tt-allsum.sum-dsc-cli-acc
      bf_tt-allsum-line.dsc-base-acc           = bf_tt-allsum-line.dsc-base-acc         + bf_tt-allsum.dsc-base-acc
      bf_tt-allsum-line.dsc-rubl-acc           = bf_tt-allsum-line.dsc-rubl-acc         + bf_tt-allsum.dsc-rubl-acc
      bf_tt-allsum-line.dsc-cli-acc            = bf_tt-allsum-line.dsc-cli-acc          + bf_tt-allsum.dsc-cli-acc
      bf_tt-allsum-line.vat-base-acc           = bf_tt-allsum-line.vat-base-acc         + bf_tt-allsum.vat-base-acc
      bf_tt-allsum-line.vat-rubl-acc           = bf_tt-allsum-line.vat-rubl-acc         + bf_tt-allsum.vat-rubl-acc
      bf_tt-allsum-line.vat-cli-acc            = bf_tt-allsum-line.vat-cli-acc          + bf_tt-allsum.vat-cli-acc
      bf_tt-allsum-line.slt-base-acc           = bf_tt-allsum-line.slt-base-acc         + bf_tt-allsum.slt-base-acc
      bf_tt-allsum-line.slt-rubl-acc           = bf_tt-allsum-line.slt-rubl-acc         + bf_tt-allsum.slt-rubl-acc
      bf_tt-allsum-line.slt-cli-acc            = bf_tt-allsum-line.slt-cli-acc          + bf_tt-allsum.slt-cli-acc
      bf_tt-allsum-line.road-tax-base-acc      = bf_tt-allsum-line.road-tax-base-acc    + bf_tt-allsum.road-tax-base-acc
      bf_tt-allsum-line.road-tax-rubl-acc      = bf_tt-allsum-line.road-tax-rubl-acc    + bf_tt-allsum.road-tax-rubl-acc
      bf_tt-allsum-line.road-tax-cli-acc       = bf_tt-allsum-line.road-tax-cli-acc     + bf_tt-allsum.road-tax-cli-acc
      bf_tt-allsum-line.excise-base-acc        = bf_tt-allsum-line.excise-base-acc      + bf_tt-allsum.excise-base-acc
      bf_tt-allsum-line.excise-rubl-acc        = bf_tt-allsum-line.excise-rubl-acc      + bf_tt-allsum.excise-rubl-acc
      bf_tt-allsum-line.excise-cli-acc         = bf_tt-allsum-line.excise-cli-acc       + bf_tt-allsum.excise-cli-acc
      bf_tt-allsum-line.transport-base-acc     = bf_tt-allsum-line.transport-base-acc   + bf_tt-allsum.transport-base-acc
      bf_tt-allsum-line.transport-rubl-acc     = bf_tt-allsum-line.transport-rubl-acc   + bf_tt-allsum.transport-rubl-acc
      bf_tt-allsum-line.transport-cli-acc      = bf_tt-allsum-line.transport-cli-acc    + bf_tt-allsum.transport-cli-acc
      bf_tt-allsum-line.other-base-acc         = bf_tt-allsum-line.other-base-acc       + bf_tt-allsum.other-base-acc
      bf_tt-allsum-line.other-rubl-acc         = bf_tt-allsum-line.other-rubl-acc       + bf_tt-allsum.other-rubl-acc
      bf_tt-allsum-line.other-cli-acc          = bf_tt-allsum-line.other-cli-acc        + bf_tt-allsum.other-cli-acc
      .
  end.
end.
end.
end procedure.
define variable g#host-code as integer   no-undo .
assign g#host-code = v-cntxt-host-code-obj .
do
on error undo, return error
:
define variable var-client   as character initial "" no-undo .
define variable var-client1  as character initial "" no-undo .
define variable Line         as character no-undo .
define variable line1        as character no-undo .
define variable ItogStr      as character initial "" no-undo .
define variable titul        as integer initial 0  no-undo .
define variable NullStr      as integer initial 0  no-undo .
define variable CurrGrpName  as character no-undo .
define variable beg          as integer   no-undo .
define variable ii           as integer   no-undo .
define variable jj           as integer   no-undo .
define variable v-NameString as character no-undo .
define variable frmt         as character no-undo .
define variable LastGroup    as character initial "" no-undo .
define variable lvel         as integer initial 0 no-undo .
define variable old-lvel     as integer initial 0 no-undo .
define variable ind          as integer   no-undo .
define variable ij           as integer   no-undo .
define variable ObS          as integer initial 1  no-undo .
define variable vvv1         as decimal   no-undo .
define variable vvv2         as decimal   no-undo .
define variable v-qntyp      as decimal   no-undo .
  define variable frm-qnty1 as character no-undo .
  define variable frm-sum1  as character no-undo .
  if sz-qnty = 3 then assign frm-qnty1 = "->>>>>>>>9.999" .
  else                       frm-qnty1 = "->>>>>>>>>>>9" .
  assign frm-sum1 = "->>>>>>>>>9.99" .
  define Stream OutStream.
  def stream txt-file.
  define stream macr_excel .
  define variable v-row       as integer   no-undo .
  define variable v-col       as integer   no-undo .
  define variable v-ind       as integer   no-undo initial 1 .
  define variable v-file-name as character no-undo .
  run rep/r-obrt11.p
                 ( input RADIO-Nomenkl
                 , input Tog-obj
                 , input name-tov
                 , input no-nds
                 , input RADIO-AltObj
                 , input AltObj-list
                 , input sys-key
                 , input prod-zen
                 , input ShowZero
                 , input ShowZero-2
                 , input-output table gds-prop
                 , input-output table o_temp-parts) .
if session :set-wait-state( "compiler" ) then.
  assign
    make-excel = yes
    v-file-name = string(session :temp-directory) + "rpt" + string( g#report-num ) + ".txt"
  .
  output stream macr_excel to value(v-file-name) .
  assign v-ind = v-ind + 1 .
  case print-o :
    when "A3-lansc":U then
output stream OutStream to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size  value(62) .
    when "A4-lansc":U then
output stream OutStream to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size  value(43) .
    when "A4-port":U  then
output stream OutStream to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size  value(62) .
    when "to-file":U  then
output stream OutStream to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size  value(62) .
  end case .
  run PrintTitul in this-procedure .
  run PutColumnTitul in this-procedure .
  run PutColumnTitulExcel in this-procedure .
  if ExportZUM then do:
    output stream txt-file to value(string(session :temp-directory) + "rpz" + string( g#report-num ) + ".txt").
    run rep/r-ob2-ex.p (input tog-obj,input RADIO-AltObj,input no, output CurrGrpName) .
    put stream txt-file ReportNAme format "X(80)"  chr(10) .
    define variable ss1 as character no-undo .
    assign  ss1 = 'X(' + string(length (CurrGrpName)) + ')' .
    put stream txt-file CurrGrpName format ss1 chr(10) .
  end.
  for each gds-sum :
    delete gds-sum .
  end.
  create gds-sum .
  assign gds-sum.num = 1 .
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
    when "prod/grp-goods":u then do:
      Run Foreach4 in this-procedure.
    end.
    when "grp-goods/prod":u then do:
      Run Foreach5 in this-procedure.
    end.
    when "vat-ps":u then do:
      Run Foreach6 in this-procedure.
    end.
  end case.
  if ExportZUM then do:
    output stream txt-file close.
  end.
  output stream macr_excel close .
  run paramls-write in this-procedure (input "file",input string(v-ind),input v-file-name) .
  HIDE stream OutStream FRAME BottomFrame .
  OUTPUT stream OutStream CLOSE.
  run end-proc .
if session :set-wait-state( "" ) then.
  define variable disop as integer   no-undo .
  case print-o :
    when "A3-lansc":U then assign disop = 8.
    when "A4-lansc":U then assign disop = 8.
    when "A4-port":U then  assign disop = 0.
    when "to-file":U then do:
      if beg > 550 then assign disop = 3.
      else              assign disop = 1.
    end.
  end.
  define variable v-user-action as character no-undo .
  define variable v-printed as logical   no-undo .
  if sys-key = "parts" then do:
     run rep/runexcel.p (string( session:temp-directory) + "rpt" + string( g#report-num ) + ".txt").
  end.
  else do:
    run gbl/prnfilen.w
      (input  ""
      ,input  disop
      ,input  string(session :temp-directory) + "rpt" + string( g#report-num )
      ,input 7
      ,output v-user-action
      ,output v-printed
      ) .
  end.
end.
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
procedure PutColumnTitulExcel :
  do
  on error undo, return error return-value
  :
  assign
    v-col = 1
    v-row = 1
    line1 = ReportNAme
  .
  run macr_excel_char (line1, v-row, 4) .
  run macr_cell_format ( 11, yes, no, ?, v-row, 4, v-row, 4) .
  assign v-row = v-row + 1 .
  if length (str4 ) > 210 then assign str4 = substring (str4, 1, 210) + " ..." .
  run macr_excel_char (str4, v-row, v-col) .
  assign v-row = v-row + 1 .
def var t-class as char no-undo.
def var t-sort as char no-undo.
  case classify:
    when "no-classify":u    then t-class =   "Без классификации" .
    when "prod":u           then t-class =   "Производители"   .
    when "post":u           then t-class =   "Поставщики"   .
    when "grp-goods":u      then t-class =   "Группы товаров"  .
    when "post/grp-goods":u then t-class =   "Поставщики/Группы товаров" .
    when "prod/grp-goods":u then t-class =   "Производители/Группы товаров" .
    when "grp-goods/prod":u then t-class =   "Группы товаров/Производители" .
    when "grp-goods/post":u then t-class =   "Группы товаров/Поставщики" .
    when  "vat-ps":u        then t-class =   "Ставка НДС" .
    when  "sort":u          then t-class =   "Проба(Сорт)" .
    when  "n-level":u       then t-class =   "Группы с уровнем вложенности " .
    when  "t-level":u       then t-class =   "Терминальные группы" .
 end case.
  case sorttype:
    when "sort-pp":u               then t-sort =   "по порядку" .
    when "sort-code":u             then t-sort =   "по коду" .
    when "sort-artic":u            then t-sort =   "по артикулу"  .
    when "sort-qunty":u            then t-sort =   "по реализации".
    when "sort-name":u             then t-sort =   "по наименованию".
    when "sort-type":u             then t-sort =   "по типу ткани".
    when "sort-doc-code":u         then t-sort =   "по номеру документа".
    when "sort-recipe-code":u      then t-sort =   "по номеру рецепта".
 end case.
  if tog-lavel then do:
    run macr_excel_char ("Классификация : " + t-Class + "    Итоги с уровня  "  + String(var-lavel), v-row, v-col) .
  end.
  else do:
    run macr_excel_char ("Классификация : " + t-Class, v-row, v-col) .
  end.
  assign v-row = v-row + 1 .
  run macr_excel_char ("Выбор цен: " + (if x-SET_val_TYPE = 1 then "рублевые" else "валютные" ), v-row, v-col) .
  assign v-row = v-row + 1 .
  run macr_excel_char (str1, v-row, v-col) .
  assign v-row = v-row + 1 .
  run macr_excel_char (str2, v-row, v-col) .
  assign v-row = v-row + 1 .
  if RADIO-AltObj > 2 then do:
    run macr_excel_char (str3, v-row, v-col) .
    assign v-row = v-row + 1 .
  end.
  assign v-col = 1 .
  if use-column[1] = yes then do:
    run macr_excel_char ("Код", v-row, v-col) .
    run  macr_cell_size (13,?, v-row, v-col,?,?).
    assign v-col = v-col + 1 .
  end.
  if use-column[2] = yes then do:
    run macr_excel_char ((if sys-key = "parts" then " Артикул/Серия" else " Артикул"), v-row, v-col) .
    run  macr_cell_size (16,?, v-row, v-col,?,?).
    assign v-col = v-col + 1 .
  end.
  if use-column[3] = yes then do:
    run macr_excel_char ((if sys-key = "parts" then " Название товара/Поставщика" else " Название товара"), v-row, v-col) .
    run  macr_cell_size (40,?, v-row, v-col,?,?) .
    assign v-col = v-col + 1 .
  end.
  if use-column[4] = yes then do:
    run macr_excel_char ("Ед. изм", v-row, v-col) .
    run  macr_cell_size (5,?, v-row, v-col,?,?) .
    assign v-col = v-col + 1 .
  end.
  assign ii = v-col .
  if use-column[5] = yes then do:
    run macr_excel_char ("Учетная цена", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[6] = yes then do:
    run macr_excel_char ("Цена продажи", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[7] = yes then do:
    run macr_excel_char ("Наценка на конец периода", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[8] = yes then do:
    run macr_excel_char ("Дата послед. переоцен.", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[9] = yes then do:
    run macr_excel_char ("Номер послед. переоцен.", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[12] = yes then do:
    run macr_excel_char ("Остаток на начало (кол-во)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[31] = yes then do:
    run macr_excel_char ("Остаток на начало (сумма учет. цен)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[50] = yes then do:
    run macr_excel_char ("Остаток на начало (сумма прод. цен)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[14] = yes then do:
    run macr_excel_char ("Приход внешний (кол-во)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[33] = yes then do:
    run macr_excel_char ("Приход внешний (сумма учет. цен)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[15] = yes then do:
    run macr_excel_char ("Возврат поставщику (кол-во)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[34] = yes then do:
    run macr_excel_char ("Возврат поставщику (сумма учет. цен)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[16] = yes then do:
    run macr_excel_char ("Расход внешний (кол-во)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[35] = yes then do:
    run macr_excel_char ("Расход внешний (сумма учет. цен)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[52] = yes then do:
    run macr_excel_char ("Расход внешний (сумма прод. цен)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[68] = yes then do:
    run macr_excel_char ("Расход внешний (скидка)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[77] = yes then do:
    run macr_excel_char ("Расход внешний (% скидки)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[17] = yes then do:
    run macr_excel_char ("Возврат внешний (кол-во)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[36] = yes then do:
    run macr_excel_char ("Возврат внешний (сумма учет. цен)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[53] = yes then do:
    run macr_excel_char ("Возврат внешний (сумма прод. цен)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[69] = yes then do:
    run macr_excel_char ("Возврат внешний (скидка)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[78] = yes then do:
    run macr_excel_char ("Возврат внешний (% скидки)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[18] = yes then do:
    run macr_excel_char ("Расход-Возврат (кол-во)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[37] = yes then do:
    run macr_excel_char ("Расход-Возврат (сумма учет. цен)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[54] = yes then do:
    run macr_excel_char ("Расход-Возврат (сумма прод. цен)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[70] = yes then do:
    run macr_excel_char ("Расход-Возврат-скидка", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[79] = yes then do:
    run macr_excel_char ("Расход-Возврат (% скидки)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[19] = yes then do:
    run macr_excel_char ("Касса продажа (кол-во)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[38] = yes then do:
    run macr_excel_char ("Касса (сумма учет. цен)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[55] = yes then do:
    run macr_excel_char ("Касса (сумма прод. цен)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[71] = yes then do:
    run macr_excel_char ("Касса (скидка)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[80] = yes then do:
    run macr_excel_char ("Касса (% скидки)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[20] = yes then do:
    run macr_excel_char ("Касса возврат (кол-во)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[39] = yes then do:
    run macr_excel_char ("Касса возврат (сумма учет. цен)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[56] = yes then do:
    run macr_excel_char ("Касса возврат (сумма прод. цен)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[72] = yes then do:
    run macr_excel_char ("Касса возврат (скидка)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[81] = yes then do:
    run macr_excel_char ("Касса возврат (% скидки)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[21] = yes then do:
    run macr_excel_char ("Касса продажа-возврат (кол-во)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[40] = yes then do:
    run macr_excel_char ("Касса продажа-возврат (сумма учет. цен)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[57] = yes then do:
    run macr_excel_char ("Касса продажа-возврат (сумма прод. цен)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[73] = yes then do:
    run macr_excel_char ("Касса продажа-возврат-скидка", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[82] = yes then do:
    run macr_excel_char ("Касса продажа-возврат (% скидки)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[22] = yes then do:
    run macr_excel_char ("Всего расход (кол-во)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[41] = yes then do:
    run macr_excel_char ("Всего расход (сумма учет. цен)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[58] = yes then do:
    run macr_excel_char ("Всего расход (сумма прод. цен)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[74] = yes then do:
    run macr_excel_char ("Всего расход (скидка)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[83] = yes then do:
    run macr_excel_char ("Всего расход (% скидки)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[23] = yes then do:
    run macr_excel_char ("Всего возврат (кол-во)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[42] = yes then do:
    run macr_excel_char ("Всего возврат (сумма учет. цен)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[59] = yes then do:
    run macr_excel_char ("Всего возврат (сумма прод. цен)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[75] = yes then do:
    run macr_excel_char ("Всего возврат (скидка)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[84] = yes then do:
    run macr_excel_char ("Всего возврат (% скидки)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[24] = yes then do:
    run macr_excel_char ("Всего расход-возврат (кол-во)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[43] = yes then do:
    run macr_excel_char ("Всего расход-возврат (сумма учет. цен)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[60] = yes then do:
    run macr_excel_char ("Всего расход-возврат (сумма прод. цен)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[76] = yes then do:
    run macr_excel_char ("Всего расход-возврат-скидка", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[85] = yes then do:
    run macr_excel_char ("Всего расход-возврат (% скидки)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[25] = yes then do:
    run macr_excel_char ("Инвентаризация (кол-во)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[44] = yes then do:
    run macr_excel_char ("Инвентаризация (сумма учет. цен)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[61] = yes then do:
    run macr_excel_char ("Инвентаризация (сумма прод. цен)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[26] = yes then do:
    run macr_excel_char ("Списание (кол-во)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[45] = yes then do:
    run macr_excel_char ("Списание (сумма учет. цен)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[62] = yes then do:
    run macr_excel_char ("Списание (сумма прод. цен)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[27] = yes then do:
    run macr_excel_char ("Приход перемещение (кол-во)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[46] = yes then do:
    run macr_excel_char ("Приход перемещение (сумма учет. цен)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[63] = yes then do:
    run macr_excel_char ("Приход перемещение (сумма прод. цен)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[28] = yes then do:
    run macr_excel_char ("Расход перемещение (кол-во)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[47] = yes then do:
    run macr_excel_char ("Расход перемещение (сумма учет. цен)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[64] = yes then do:
    run macr_excel_char ("Расход перемещение (сумма прод. цен)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[29] = yes then do:
    run macr_excel_char ("Возврат перемещение (кол-во)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[48] = yes then do:
    run macr_excel_char ("Возврат перемещение (сумма учет. цен)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[65] = yes then do:
    run macr_excel_char ("Возврат перемещение (сумма прод. цен)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[30] = yes then do:
    run macr_excel_char ("Приход производство (кол-во)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[49] = yes then do:
    run macr_excel_char ("Приход производство (сумма учет. цен)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[66] = yes then do:
    run macr_excel_char ("Приход производство (сумма прод. цен)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[86] = yes then do:
    run macr_excel_char ("Списание производство (кол-во)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[87] = yes then do:
    run macr_excel_char ("Списание производство (сумма учет. цен)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[88] = yes then do:
    run macr_excel_char ("Списание производство (сумма прод. цен)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[67] = yes then do:
    run macr_excel_char ("Переоценка", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[13] = yes then do:
    run macr_excel_char ("Остаток на конец по партиям (кол-во)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[32] = yes then do:
    run macr_excel_char ("Остаток на конец по партиям (сумма учет. цен)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[51] = yes then do:
    run macr_excel_char ("Остаток на конец по партиям (сумма прод. цен)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[10] = yes then do:
    run macr_excel_char ("Эффективность", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[11] = yes then do:
    run macr_excel_char ("Фактический % наценки", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if RADIO-AltObj > 1 then do:
    run macr_excel_char ("Кол-во на альтерн. объектах", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[89] = yes then do:
    run macr_excel_char ("Свободно (кол-во)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[90] = yes then do:
    run macr_excel_char ("Свободно (сумма учет. цен)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[91] = yes then do:
    run macr_excel_char ("Свободно  (сумма прод. цен)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[92] = yes then do:
    run macr_excel_char ("Резерв (кол-во)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[93] = yes then do:
    run macr_excel_char ("Резерв (сумма учет. цен)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[94] = yes then do:
    run macr_excel_char ("Резерв  (сумма прод. цен)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[95] = yes then do:
    run macr_excel_char ("Резерв (скидка)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
  if use-column[96] = yes then do:
    run macr_excel_char ("Резерв (% скидки)", v-row, v-col) .
    assign v-col = v-col + 1 .
  end.
   if use-column[97] = yes then do: run macr_excel_char  ("Цена производителя без НДС"       , v-row, v-col) . assign v-col = v-col + 1 .  end.
   if use-column[98] = yes then do: run macr_excel_char  ("Цена производителя с НДС"         , v-row, v-col) . assign v-col = v-col + 1 .  end.
   if use-column[99] = yes then do: run macr_excel_char  ("НДС производителя, сумма"         , v-row, v-col) . assign v-col = v-col + 1 .  end.
   if use-column[100] = yes then do: run macr_excel_char ("НДС производителя(%)"             , v-row, v-col) . assign v-col = v-col + 1 .  end.
   if use-column[101] = yes then do: run macr_excel_char ("Цена поставщика без НДС"          , v-row, v-col) . assign v-col = v-col + 1 .  end.
   if use-column[102] = yes then do: run macr_excel_char ("Цена поставщика с НДС"            , v-row, v-col) . assign v-col = v-col + 1 .  end.
   if use-column[103] = yes then do: run macr_excel_char ("НДС поставщика (сумма)"           , v-row, v-col) . assign v-col = v-col + 1 .  end.
   if use-column[104] = yes then do: run macr_excel_char ("НДС поставщика (%)"               , v-row, v-col) . assign v-col = v-col + 1 .  end.
   if use-column[105] = yes then do: run macr_excel_char ("Размер оптовой надбавки (сумма)"  , v-row, v-col) . assign v-col = v-col + 1 .  end.
   if use-column[106] = yes then do: run macr_excel_char ("Размер оптовой надбавки  (%)"     , v-row, v-col) . assign v-col = v-col + 1 .  end.
   if use-column[107] = yes then do: run macr_excel_char ("Розничная цена с НДС"             , v-row, v-col) . assign v-col = v-col + 1 .  end.
   if use-column[108] = yes then do: run macr_excel_char ("Розничная цена без НДС"           , v-row, v-col) . assign v-col = v-col + 1 .  end.
   if use-column[109] = yes then do: run macr_excel_char ("Сумма НДС"                        , v-row, v-col) . assign v-col = v-col + 1 .  end.
   if use-column[110] = yes then do: run macr_excel_char ("Ставка НДС (%)"                   , v-row, v-col) . assign v-col = v-col + 1 .  end.
   if use-column[111] = yes then do: run macr_excel_char ("Размер розничной надбавки (сумма)", v-row, v-col) . assign v-col = v-col + 1 .  end.
   if use-column[112] = yes then do: run macr_excel_char ("Размер розничной надбавки (%)"    , v-row, v-col) . assign v-col = v-col + 1 .  end.
   if use-column[113] = yes then do: run macr_excel_char ("Размер общей надбавки (сумма)"    , v-row, v-col) . assign v-col = v-col + 1 .  end.
   if use-column[114] = yes then do: run macr_excel_char ("Размер общей надбавки (%)"        , v-row, v-col) . assign v-col = v-col + 1 .  end.
   if use-column[115] = yes then do: run macr_excel_char ("Размер розничной надбавки (от цен с НДС) (сумма)", v-row, v-col) . assign v-col = v-col + 1 .  end.
   if use-column[116] = yes then do: run macr_excel_char ("Размер розничной надбавки (от цен с НДС) (%)"    , v-row, v-col) . assign v-col = v-col + 1 .  end.
   if use-column[117] = yes then do: run macr_excel_char ("Размер общей надбавки (от цен с НДС) (сумма)"    , v-row, v-col) . assign v-col = v-col + 1 .  end.
   if use-column[118] = yes then do: run macr_excel_char ("Размер общей надбавки (от цен с НДС) (%)"        , v-row, v-col) . assign v-col = v-col + 1 .  end.
  run macr_cell_bordur ( v-row, 1, v-row, v-col - 1) .
  run macr_cell_format ( 10, yes, no, 35, v-row, 1, v-row, v-col - 1) .
  run  macr_cell_size (12,?, v-row, ii,v-row, v-col - 1) .
  assign v-row = v-row + 1 .
  end.
end procedure.
procedure PrintTitul :
  define variable ss1 as character no-undo .
  PUT stream OutStream SPACE(30) ReportNAme format "X(100)" SKIP .
  assign  ss1 = 'X(' + string(length (ReportHeader)) + ')' .
  PUT stream OutStream ReportHeader format ss1 SKIP.
  assign
    str4 = "Выбранные объекты: " + str4
    ss1 = 'X(' + string(length (str4)) + ')'
  .
  PUT stream OutStream str4 format ss1 SKIP.
  if RADIO-AltObj > 2 then do:
    assign ss1 = 'X(' + string(length (str3)) + ')' .
    PUT stream OutStream str3 format ss1 SKIP.
  end.
  define variable frm-qnty as character no-undo .
  if sz-qnty = 3 then assign frm-qnty = "->>>>>>>>9.999" .
  else                       frm-qnty = "->>>>>>>>>>>>9" .
  assign
    ii  = 1
    beg = 1
  .
  if use-column[1] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = " Код"
      line-frm.titul1 = ""
      line-frm.titul2 = ""
      line-frm.frm    = ">>>>>>>>>>>>9"
      line-frm.frmt   = "X(6)"
      ii  = ii + 1
      beg = beg + 14
    .
  end.
  if use-column[2] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = if sys-key = "parts" then " Артикул/Серия" else " Артикул"
      line-frm.titul1 = ""
      line-frm.titul2 = ""
      line-frm.frm    = "X(16)"
      line-frm.frmt   = "X(16)"
      ii  = ii + 1
      beg = beg + 17
    .
  end.
  if use-column[3] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = if sys-key = "parts" then " Название товара/Поставщика" else " Название товара"
      line-frm.titul1 = ""
      line-frm.titul2 = ""
      line-frm.frm    = "X(40)"
      line-frm.frmt   = "X(40)"
      ii  = ii + 1
      beg = beg + 41
    .
  end.
  if use-column[4] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Ед."
      line-frm.titul1 = "изм"
      line-frm.titul2 = ""
      line-frm.frm    = "X(4)"
      line-frm.frmt   = "X(3)"
      ii  = ii + 1
      beg = beg + 5
    .
  end.
  if use-column[5] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = " Учетная цена"
      line-frm.titul1 = ""
      line-frm.titul2 = ""
      line-frm.frm    = ">>>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[6] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = " Цена продажи"
      line-frm.titul1 = ""
      line-frm.titul2 = ""
      line-frm.frm    = ">>>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[7] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = " Наценка"
      line-frm.titul1 = " на конец"
      line-frm.titul2 = " периода"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[8] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = " Дата"
      line-frm.titul1 = " послед."
      line-frm.titul2 = "переоценки"
      line-frm.frm    = "99/99/9999"
      line-frm.frmt   = "X(10)"
      ii  = ii + 1
      beg = beg + 11
    .
  end.
  if use-column[9] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = " Номер"
      line-frm.titul1 = " послед."
      line-frm.titul2 = "переоценки"
      line-frm.frm    = "X(10)"
      line-frm.frmt   = "X(10)"
      ii  = ii + 1
      beg = beg + 11
    .
  end.
  if use-column[12] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = " Остаток"
      line-frm.titul1 = " на начало"
      line-frm.titul2 = " (кол-во)"
      line-frm.frm    = frm-qnty
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[31] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Остаток на"
      line-frm.titul1 = "начало (сумма"
      line-frm.titul2 = "учет. цен)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[50] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Остаток на"
      line-frm.titul1 = "начало (сумма"
      line-frm.titul2 = "прод. цен)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[14] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = " Приход"
      line-frm.titul1 = " внешний"
      line-frm.titul2 = " (кол-во)"
      line-frm.frm    = frm-qnty
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[33] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = " Приход"
      line-frm.titul1 = "внешний (сумма"
      line-frm.titul2 = "учет. цен)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[15] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = " Возврат"
      line-frm.titul1 = "поставщику"
      line-frm.titul2 = " (кол-во)"
      line-frm.frm    = frm-qnty
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[34] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = " Возврат"
      line-frm.titul1 = "пост-ку (сумма"
      line-frm.titul2 = "учет. цен)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[16] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = " Расход"
      line-frm.titul1 = "внешний"
      line-frm.titul2 = " (кол-во)"
      line-frm.frm    = frm-qnty
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[35] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = " Расход"
      line-frm.titul1 = "внешний (сумма"
      line-frm.titul2 = "учет. цен)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[52] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = " Расход"
      line-frm.titul1 = "внешний (сумма"
      line-frm.titul2 = "прод. цен)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[68] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = " Расход"
      line-frm.titul1 = "внешний"
      line-frm.titul2 = "(скидка)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[77] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = " Расход"
      line-frm.titul1 = "внешний"
      line-frm.titul2 = "(% скидки)"
      line-frm.frm    = "->,>>9.99"
      line-frm.frmt   = "X(9)"
      ii  = ii + 1
      beg = beg + 10
    .
  end.
  if use-column[17] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Возврат"
      line-frm.titul1 = "внешний"
      line-frm.titul2 = " (кол-во)"
      line-frm.frm    = frm-qnty
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[36] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = " Возврат"
      line-frm.titul1 = "внешний (сумма"
      line-frm.titul2 = "учет. цен)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[53] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = " Возврат"
      line-frm.titul1 = "внешний (сумма"
      line-frm.titul2 = "прод. цен)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[69] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Возврат"
      line-frm.titul1 = "внешний"
      line-frm.titul2 = "(скидка)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[78] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Возврат"
      line-frm.titul1 = "внешний"
      line-frm.titul2 = "(% скидки)"
      line-frm.frm    = "->,>>9.99"
      line-frm.frmt   = "X(9)"
      ii  = ii + 1
      beg = beg + 10
    .
  end.
  if use-column[18] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Расход-"
      line-frm.titul1 = "Возврат"
      line-frm.titul2 = " (кол-во)"
      line-frm.frm    = frm-qnty
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[37] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Расход-"
      line-frm.titul1 = "Возврат (сумма"
      line-frm.titul2 = "учет. цен)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[54] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Расход-"
      line-frm.titul1 = "Возврат (сумма"
      line-frm.titul2 = " прод. цен)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[70] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Расход-"
      line-frm.titul1 = "Возврат-"
      line-frm.titul2 = "скидка"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[79] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Расход-"
      line-frm.titul1 = "Возврат"
      line-frm.titul2 = "(% скидки)"
      line-frm.frm    = "->,>>9.99"
      line-frm.frmt   = "X(9)"
      ii  = ii + 1
      beg = beg + 10
    .
  end.
  if use-column[19] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Касса"
      line-frm.titul1 = "продажа"
      line-frm.titul2 = " (кол-во)"
      line-frm.frm    = frm-qnty
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[38] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Касса"
      line-frm.titul1 = "продажа (сумма"
      line-frm.titul2 = "учет. цен)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[55] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Касса"
      line-frm.titul1 = "продажа (сумма"
      line-frm.titul2 = "прод. цен)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[71] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Касса"
      line-frm.titul1 = "продажа"
      line-frm.titul2 = "(скидка)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[80] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Касса"
      line-frm.titul1 = "продажа"
      line-frm.titul2 = "(% скидки)"
      line-frm.frm    = "->,>>9.99"
      line-frm.frmt   = "X(9)"
      ii  = ii + 1
      beg = beg + 10
    .
  end.
  if use-column[20] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Касса"
      line-frm.titul1 = "возврат"
      line-frm.titul2 = " (кол-во)"
      line-frm.frm    = frm-qnty
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[39] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Касса"
      line-frm.titul1 = "возврат (сумма"
      line-frm.titul2 = "учет. цен)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[56] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Касса"
      line-frm.titul1 = "возврат (сумма"
      line-frm.titul2 = "прод. цен)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[72] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Касса"
      line-frm.titul1 = "возврат"
      line-frm.titul2 = "(скидка)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[81] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Касса"
      line-frm.titul1 = "возврат"
      line-frm.titul2 = "(% скидки)"
      line-frm.frm    = "->,>>9.99"
      line-frm.frmt   = "X(9)"
      ii  = ii + 1
      beg = beg + 10
    .
  end.
  if use-column[21] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Касса продажа"
      line-frm.titul1 = "-возврат"
      line-frm.titul2 = " (кол-во)"
      line-frm.frm    = frm-qnty
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[40] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Касса продажа-"
      line-frm.titul1 = "возврат (сумма"
      line-frm.titul2 = "учет. цен)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[57] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Касса продажа-"
      line-frm.titul1 = "возврат (сумма"
      line-frm.titul2 = "прод. цен)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[73] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Касса продажа"
      line-frm.titul1 = "-возврат"
      line-frm.titul2 = "-скидка"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[82] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Касса продажа"
      line-frm.titul1 = "-возврат"
      line-frm.titul2 = "(% скидки)"
      line-frm.frm    = "->,>>9.99"
      line-frm.frmt   = "X(9)"
      ii  = ii + 1
      beg = beg + 10
    .
  end.
  if use-column[22] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Всего"
      line-frm.titul1 = "расход"
      line-frm.titul2 = " (кол-во)"
      line-frm.frm    = frm-qnty
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[41] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Всего"
      line-frm.titul1 = "расход (сумма"
      line-frm.titul2 = "учет. цен)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[58] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Всего"
      line-frm.titul1 = "расход (сумма"
      line-frm.titul2 = "прод. цен)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[74] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Всего"
      line-frm.titul1 = "расход"
      line-frm.titul2 = "(скидка)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[83] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Всего"
      line-frm.titul1 = "расход"
      line-frm.titul2 = "(% скидки)"
      line-frm.frm    = "->,>>9.99"
      line-frm.frmt   = "X(9)"
      ii  = ii + 1
      beg = beg + 10
    .
  end.
  if use-column[23] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Всего"
      line-frm.titul1 = "возврат"
      line-frm.titul2 = " (кол-во)"
      line-frm.frm    = frm-qnty
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[42] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Всего"
      line-frm.titul1 = "возврат (сумма"
      line-frm.titul2 = "учет. цен)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[59] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Всего"
      line-frm.titul1 = "возврат (сумма"
      line-frm.titul2 = "прод. цен)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[75] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Всего"
      line-frm.titul1 = "возврат"
      line-frm.titul2 = "(скидка)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[84] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Всего"
      line-frm.titul1 = "возврат"
      line-frm.titul2 = "(% скидки)"
      line-frm.frm    = "->,>>9.99"
      line-frm.frmt   = "X(9)"
      ii  = ii + 1
      beg = beg + 10
    .
  end.
  if use-column[24] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Всего расход"
      line-frm.titul1 = "-возврат"
      line-frm.titul2 = " (кол-во)"
      line-frm.frm    = frm-qnty
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[43] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Всего расход-"
      line-frm.titul1 = "возврат (сумма"
      line-frm.titul2 = "учет. цен)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[60] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Всего расход-"
      line-frm.titul1 = "возврат (сумма"
      line-frm.titul2 = "прод. цен)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[76] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Всего расход"
      line-frm.titul1 = "-возврат"
      line-frm.titul2 = "-скидка"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[85] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Всего расход"
      line-frm.titul1 = "-возврат"
      line-frm.titul2 = "(% скидки)"
      line-frm.frm    = "->,>>9.99"
      line-frm.frmt   = "X(9)"
      ii  = ii + 1
      beg = beg + 10
    .
  end.
  if use-column[25] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Инвентаризация"
      line-frm.titul1 = "(кол-во)"
      line-frm.titul2 = ""
      line-frm.frm    = frm-qnty
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[44] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Инвентаризация"
      line-frm.titul1 = "(сумма учет."
      line-frm.titul2 = " цен)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[61] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Инвентаризация"
      line-frm.titul1 = "(сумма прод."
      line-frm.titul2 = " цен)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[26] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Списание"
      line-frm.titul1 = " (кол-во)"
      line-frm.titul2 = ""
      line-frm.frm    = frm-qnty
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[45] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Списание"
      line-frm.titul1 = "(сумма учет."
      line-frm.titul2 = " цен)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[62] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Списание"
      line-frm.titul1 = "(сумма прод."
      line-frm.titul2 = " цен)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[27] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Приход"
      line-frm.titul1 = "перемещение"
      line-frm.titul2 = " (кол-во)"
      line-frm.frm    = frm-qnty
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[46] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Приход"
      line-frm.titul1 = "перемещение"
      line-frm.titul2 = "(сумма учет. цен)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[63] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Приход"
      line-frm.titul1 = "перемещение"
      line-frm.titul2 = "(сумма прод. цен)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[28] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Расход"
      line-frm.titul1 = "перемещение"
      line-frm.titul2 = " (кол-во)"
      line-frm.frm    = frm-qnty
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[47] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Расход"
      line-frm.titul1 = "перемещение"
      line-frm.titul2 = "(сумма учет. цен)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[64] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Расход"
      line-frm.titul1 = "перемещение"
      line-frm.titul2 = "(сумма прод. цен)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[29] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Возврат"
      line-frm.titul1 = "перемещение"
      line-frm.titul2 = " (кол-во)"
      line-frm.frmt   = "X(14)"
      line-frm.frm    = frm-qnty
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[48] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Возврат"
      line-frm.titul1 = "перемещение"
      line-frm.titul2 = "(сумма учет. цен)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[65] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Возврат"
      line-frm.titul1 = "перемещение"
      line-frm.titul2 = "(сумма прод. цен)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[30] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Приход"
      line-frm.titul1 = "производство"
      line-frm.titul2 = " (кол-во)"
      line-frm.frm    = frm-qnty
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[49] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Приход"
      line-frm.titul1 = "производство"
      line-frm.titul2 = "(сумма учет. цен)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[66] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Приход"
      line-frm.titul1 = "производство"
      line-frm.titul2 = "(сумма прод. цен)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[86] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Списание"
      line-frm.titul1 = "производство"
      line-frm.titul2 = " (кол-во)"
      line-frm.frm    = frm-qnty
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[87] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Списание"
      line-frm.titul1 = "производство"
      line-frm.titul2 = "(сумма учет. цен)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[88] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Списание"
      line-frm.titul1 = "производство"
      line-frm.titul2 = "(сумма прод. цен)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[67] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Переоценка"
      line-frm.titul1 = ""
      line-frm.titul2 = ""
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[13] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Остаток на ко-"
      line-frm.titul1 = "нец по партиям"
      line-frm.titul2 = "(кол-во)"
      line-frm.frm    = frm-qnty
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[32] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Остаток на ко-"
      line-frm.titul1 = "нец по партиям"
      line-frm.titul2 = "(сум. уч. цен)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[51] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Остаток на ко-"
      line-frm.titul1 = "нец по партиям"
      line-frm.titul2 = "(сум.прод.цен)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[10] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Эффективность"
      line-frm.titul1 = ""
      line-frm.titul2 = ""
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[11] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Фактический"
      line-frm.titul1 = "% наценки"
      line-frm.titul2 = ""
      line-frm.frm    = "->,>>9.99"
      line-frm.frmt   = "X(9)"
      ii  = ii + 1
      beg = beg + 10
    .
  end.
  if RADIO-AltObj > 1 then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Кол-во на"
      line-frm.titul1 = "альтерн."
      line-frm.titul2 = "объектах"
      line-frm.frm    = frm-qnty
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[89] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Свободно"
      line-frm.titul1 = "на конец"
      line-frm.titul2 = "(кол-во)"
      line-frm.frm    = frm-qnty
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[90] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Свободно на"
      line-frm.titul1 = "конец (сумма"
      line-frm.titul2 = "учет. цен)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[91] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Свободно на"
      line-frm.titul1 = "конец (сумма"
      line-frm.titul2 = "прод. цен)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[92] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Резерв"
      line-frm.titul1 = "на конец"
      line-frm.titul2 = "(кол-во)"
      line-frm.frm    = frm-qnty
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[93] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Резерв на"
      line-frm.titul1 = "конец (сумма"
      line-frm.titul2 = "учет. цен)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[94] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Резерв на"
      line-frm.titul1 = "конец (сумма"
      line-frm.titul2 = "прод. цен)"
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[95] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Резерв"
      line-frm.titul1 = "(скидка)"
      line-frm.titul2 = ""
      line-frm.frm    = "->>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[96] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Резерв"
      line-frm.titul1 = "(% скидки)"
      line-frm.titul2 = ""
      line-frm.frm    = "->,>>9.99"
      line-frm.frmt   = "X(9)"
      ii  = ii + 1
      beg = beg + 10
    .
  end.
  if use-column[97] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Цена без НДС"
      line-frm.titul1 = "производителя"
      line-frm.titul2 = ""
      line-frm.frm    = "->>>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[98] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "%"
      line-frm.titul  = "Цена c НДС"
      line-frm.titul1 = "производителя"
      line-frm.frm    = "->>>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 10
    .
  end.
  if use-column[99] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "НДС"
      line-frm.titul1 = "произв"
      line-frm.titul2 = ""
      line-frm.frm    = "->>>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 15
    .
  end.
  if use-column[100] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "%"
      line-frm.titul1 = "НДС"
      line-frm.titul2 = "произв"
      line-frm.frm    = "->,>>9.99"
      line-frm.frmt   = "X(9)"
      ii  = ii + 1
      beg = beg + 10
    .
  end.
  if use-column[101] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Цена"
      line-frm.titul1 = "поставщика"
      line-frm.titul2 = "без НДС"
      line-frm.frm    = "->>>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 10
    .
  end.
  if use-column[102] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Цена"
      line-frm.titul1 = "поставщика"
      line-frm.titul2 = "с НДС "
      line-frm.frm    = "->>>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 10
    .
  end.
  if use-column[103] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "НДС"
      line-frm.titul1 = "поставщика"
      line-frm.titul2 = "(сумма) "
      line-frm.frm    = "->>>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 10
    .
  end.
  if use-column[104] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "НДС "
      line-frm.titul1 = "поставщика "
      line-frm.titul2 = "(%) "
      line-frm.frm    = "->>>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 10
    .
  end.
  if use-column[105] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Размер оптовой"
      line-frm.titul1 = "надбавки"
      line-frm.titul2 = "(сумма) "
      line-frm.frm    = "->>>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 10
    .
  end.
  if use-column[106] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Размер оптовой"
      line-frm.titul1 = "надбавки"
      line-frm.titul2 = "(%) "
      line-frm.frm    = "->>>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 10
    .
  end.
  if use-column[107] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Розничная "
      line-frm.titul1 = "цена партии"
      line-frm.titul2 = "с НДС"
      line-frm.frm    = "->>>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 10
    .
  end.
  if use-column[108] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Розничная "
      line-frm.titul1 = "цена партии"
      line-frm.titul2 = "без НДС"
      line-frm.frm    = "->>>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 10
    .
  end.
  if use-column[109] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Сумма"
      line-frm.titul1 = "НДС"
      line-frm.titul2 = " "
      line-frm.frm    = "->>>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 10
    .
  end.
  if use-column[110] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Ставка"
      line-frm.titul1 = "НДС "
      line-frm.titul2 = "%"
      line-frm.frm    = "->>>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 10
    .
  end.
  if use-column[111] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Размер  "
      line-frm.titul1 = "розничной надбавки"
      line-frm.titul2 = "(сумма) "
      line-frm.frm    = "->>>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 10
    .
  end.
  if use-column[112] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Размер  "
      line-frm.titul1 = "розничной надбавки"
      line-frm.titul2 = "(%) "
      line-frm.frm    = "->>>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 10
    .
  end.
  if use-column[113] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Размер "
      line-frm.titul1 = "общей надбавки"
      line-frm.titul2 = "(сумма) "
      line-frm.frm    = "->>>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 10
    .
  end.
  if use-column[114] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Размер "
      line-frm.titul1 = "общей надбавки"
      line-frm.titul2 = "(сумма) "
      line-frm.frm    = "->>>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 10
    .
  end.
  if use-column[115] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Размер  "
      line-frm.titul1 = "розничной надбавки"
      line-frm.titul2 = "(с НДС) (сумма) "
      line-frm.frm    = "->>>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 10
    .
  end.
  if use-column[116] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Размер  "
      line-frm.titul1 = "розничной надбавки"
      line-frm.titul2 = "(с НДС) (%) "
      line-frm.frm    = "->>>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 10
    .
  end.
  if use-column[117] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Размер "
      line-frm.titul1 = "общей надбавки"
      line-frm.titul2 = "(с НДС) (сумма) "
      line-frm.frm    = "->>>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 10
    .
  end.
  if use-column[118] = yes then do:
    create line-frm .
    assign
      line-frm.num    = ii
      line-frm.beg    = beg
      line-frm.titul  = "Размер "
      line-frm.titul1 = "общей надбавки"
      line-frm.titul2 = "(с НДС) (сумма) "
      line-frm.frm    = "->>>,>>>,>>9.99"
      line-frm.frmt   = "X(14)"
      ii  = ii + 1
      beg = beg + 10
    .
  end.
  assign
    frmt = "X(" + string(beg) + ')'
    Line = fill("-", beg).
  .
end.
procedure CheckNullOborot :
  do
  on error undo, return error return-value
  :
  if line-counter( Outstream ) + 5 > page-size( Outstream ) then do:
    put stream outstream  skip Line format frmt skip "продолжение - на следующей странице" AT 30 SKIP .
    page stream OutStream .
    run PutColumnTitul in this-procedure .
  end.
  if  ( v-row ) >= 63000 then do:
    Output stream Macr_Excel  close .
    run paramls-write in this-procedure (input "file",input string(v-ind),input v-file-name ) .
    run gbl/_tmpfile.p ("wb", ".txt", output v-file-name) .
    output stream  Macr_Excel to value(v-file-name) .
    v-ind = v-ind + 1 .
    run PutColumnTitulExcel in this-procedure .
  end.
  assign
    NullStr = 0
  .
  define variable null-ost as integer initial 0 no-undo .
  if ShowZero = no then do:
    if use-column[12] = yes or use-column[13] = yes or use-column[31] = yes or use-column[32] = yes or use-column[50] = yes or use-column[51] = yes then do:
      if ( gds-prop.StartWay-Qnty = 0    or gds-prop.StartWay-Qnty = ? )    and
         ( gds-prop.StartWay-CostSum = 0 or gds-prop.StartWay-CostSum = ? ) and
         ( gds-prop.StartWay-SaleSum = 0 or gds-prop.StartWay-SaleSum = ? ) and
         ( gds-prop.EndWay-Qnty = 0    or gds-prop.EndWay-Qnty = ? )        and
         ( gds-prop.EndWay-CostSum = 0 or gds-prop.EndWay-CostSum = ? )     and
         ( gds-prop.EndWay-SaleSum = 0 or gds-prop.EndWay-SaleSum = ? )
       then assign null-ost = 1 .
    end.
  end.
    if (( gds-prop.EndWay-Qnty - gds-prop.StartWay-Qnty ) = 0 )    and
       ( gds-prop.InExt-Qnty           = 0 or gds-prop.InExt-Qnty = ? )    and
       ( gds-prop.InExt-CostSum        = 0 or gds-prop.InExt-CostSum = ? ) and
       ( gds-prop.RetPost-Qnty         = 0 or gds-prop.RetPost-Qnty = ? ) and
       ( gds-prop.RetPost-CostSum      = 0 or gds-prop.RetPost-CostSum = ? )      and
       ( gds-prop.OutExt-Qnty          = 0 or gds-prop.OutExt-Qnty = ? )   and
       ( gds-prop.OutExt-CostSum       = 0 or gds-prop.OutExt-CostSum = ? ) and
       ( gds-prop.OutExt-SaleSum       = 0 or gds-prop.OutExt-SaleSum = ? ) and
       ( gds-prop.OutExt-DiscntSum     = 0 or gds-prop.OutExt-DiscntSum = ? )      and
       ( gds-prop.RetOut-Qnty          = 0 or gds-prop.RetOut-Qnty = ? )   and
       ( gds-prop.RetOut-CostSum       = 0 or gds-prop.RetOut-CostSum = ? ) and
       ( gds-prop.RetOut-SaleSum       = 0 or gds-prop.RetOut-SaleSum = ? ) and
       ( gds-prop.RetOut-DiscntSum     = 0 or gds-prop.RetOut-DiscntSum = ? )      and
       ( gds-prop.OutExtKass-Qnty      = 0 or gds-prop.OutExtKass-Qnty = ? )   and
       ( gds-prop.OutExtKass-CostSum   = 0 or gds-prop.OutExtKass-CostSum = ? ) and
       ( gds-prop.OutExtKass-SaleSum   = 0 or gds-prop.OutExtKass-SaleSum = ? ) and
       ( gds-prop.OutExtKass-DiscntSum = 0 or gds-prop.OutExtKass-DiscntSum = ? )      and
       ( gds-prop.RetOutKass-Qnty      = 0 or gds-prop.RetOutKass-Qnty = ? )   and
       ( gds-prop.RetOutKass-CostSum   = 0 or gds-prop.RetOutKass-CostSum = ? ) and
       ( gds-prop.RetOutKass-SaleSum   = 0 or gds-prop.RetOutKass-SaleSum = ? ) and
       ( gds-prop.RetOutKass-DiscntSum = 0 or gds-prop.RetOutKass-DiscntSum = ? )      and
       ( gds-prop.Inv-Qnty             = 0 or gds-prop.Inv-Qnty = ? )   and
       ( gds-prop.Inv-CostSum          = 0 or gds-prop.Inv-CostSum = ? ) and
       ( gds-prop.Inv-SaleSum          = 0 or gds-prop.Inv-SaleSum = ? ) and
       ( gds-prop.Spi-Qnty             = 0 or gds-prop.Spi-Qnty = ? )      and
       ( gds-prop.Spi-CostSum          = 0 or gds-prop.Spi-CostSum = ? )   and
       ( gds-prop.Spi-SaleSum          = 0 or gds-prop.Spi-SaleSum = ? ) and
       ( gds-prop.InInt-Qnty           = 0 or gds-prop.InInt-Qnty = ? )      and
       ( gds-prop.InInt-CostSum        = 0 or gds-prop.InInt-CostSum = ? )   and
       ( gds-prop.InInt-SaleSum        = 0 or gds-prop.InInt-SaleSum = ? ) and
       ( gds-prop.OutInt-Qnty          = 0 or gds-prop.OutInt-Qnty = ? )      and
       ( gds-prop.OutInt-CostSum       = 0 or gds-prop.OutInt-CostSum = ? )   and
       ( gds-prop.OutInt-SaleSum       = 0 or gds-prop.OutInt-SaleSum = ? ) and
       ( gds-prop.RetInt-Qnty          = 0 or gds-prop.RetInt-Qnty = ? )      and
       ( gds-prop.RetInt-CostSum       = 0 or gds-prop.RetInt-CostSum = ? )   and
       ( gds-prop.RetInt-SaleSum       = 0 or gds-prop.RetInt-SaleSum = ? ) and
       ( gds-prop.InProiz-Qnty         = 0 or gds-prop.InProiz-Qnty = ? )      and
       ( gds-prop.InProiz-CostSum      = 0 or gds-prop.InProiz-CostSum = ? )   and
       ( gds-prop.InProiz-SaleSum      = 0 or gds-prop.InProiz-SaleSum = ? ) and
       ( gds-prop.OutProiz-Qnty        = 0 or gds-prop.OutProiz-Qnty = ? )      and
       ( gds-prop.OutProiz-CostSum     = 0 or gds-prop.OutProiz-CostSum = ? )   and
       ( gds-prop.OutProiz-SaleSum     = 0 or gds-prop.OutProiz-SaleSum = ? )
      then do:
        if null-ost = 0 then do:
          if ShowZero-2 = no then NullStr = 1 .
        end.
        else do:
          NullStr = 2 .
        end.
      end.
    end.
end procedure.
PROCEDURE PutColumnTitul :
  put stream outstream  skip
    string( "Дата печати :" ) AT 5 format "x(15)" TODAY format "99.99.9999"
    string( " , " ) format "X(3)" string(TIME, "HH:MM")
    string( "Страница" ) AT 45 PAGE-NUMBER( outstream ) AT 55 FORMAT ">>>>9" SKIP
   Line format frmt skip .
  for each line-frm :
    put stream outstream  "|" at line-frm.beg  line-frm.titul format line-frm.frmt .
  end.
  put stream outstream    "|" skip .
  for each line-frm :
    put stream outstream  "|" at line-frm.beg  line-frm.titul1 format line-frm.frmt .
  end.
  put stream outstream    "|" skip .
  for each line-frm :
    put stream outstream  "|" at line-frm.beg  line-frm.titul2 format line-frm.frmt .
  end.
  put stream outstream    "|"  skip  Line format frmt skip .
END PROCEDURE.
procedure PutItogSum :
  define input  parameter p-num as integer   no-undo .
  define buffer buf_gds-sum for gds-sum .
  if p-num = 2 then do:
     if available obj-list then assign ItogStr = "Итого по объекту " + obj-list.obj-name + " (" + obj-list.obj-type + '#' + string(obj-list.obj-code) + ") :" .
     else assign ItogStr = "" .
  end.
  else if p-num = 1 then assign  ItogStr = "ИТОГО: " .
  find first buf_gds-sum where buf_gds-sum.num = p-num no-error .
  if buf_gds-sum.StartWay-Qnty  <> 0 or buf_gds-sum.StartWay-CostSum <> 0 or buf_gds-sum.StartWay-SaleSum <> 0 or buf_gds-sum.EndWay-Qnty   <> 0 or
     buf_gds-sum.EndWay-CostSum <> 0 or buf_gds-sum.EndWay-SaleSum   <> 0 or buf_gds-sum.InExt-Qnty       <> 0 or buf_gds-sum.InExt-CostSum <> 0 or
     buf_gds-sum.RetPost-Qnty   <> 0 or buf_gds-sum.RetPost-CostSum  <> 0 or buf_gds-sum.OutExt-Qnty      <> 0 or buf_gds-sum.OutExt-CostSum <> 0 or
     buf_gds-sum.OutExt-SaleSum <> 0 or buf_gds-sum.OutExt-DiscntSum <> 0 or buf_gds-sum.RetOut-Qnty      <> 0 or buf_gds-sum.RetOut-CostSum <> 0 or
     buf_gds-sum.RetOut-SaleSum <> 0 or buf_gds-sum.RetOut-DiscntSum <> 0 or buf_gds-sum.OutExtKass-Qnty  <> 0 or buf_gds-sum.OutExtKass-CostSum  <> 0 or
     buf_gds-sum.OutExtKass-SaleSum <> 0 or buf_gds-sum.OutExtKass-DiscntSum <> 0 or buf_gds-sum.RetOutKass-Qnty <> 0 or buf_gds-sum.RetOutKass-CostSum <> 0 or
     buf_gds-sum.RetOutKass-SaleSum <> 0 or buf_gds-sum.RetOutKass-DiscntSum <> 0 or buf_gds-sum.InInt-Qnty      <> 0 or buf_gds-sum.InInt-CostSum      <> 0 or
     buf_gds-sum.InInt-SaleSum      <> 0 or buf_gds-sum.OutInt-Qnty          <> 0 or buf_gds-sum.OutInt-CostSum  <> 0 or buf_gds-sum.OutInt-SaleSum     <> 0 or
     buf_gds-sum.RetInt-Qnty        <> 0 or buf_gds-sum.RetInt-CostSum       <> 0 or buf_gds-sum.RetInt-SaleSum  <> 0 or buf_gds-sum.Inv-Qnty           <> 0 or
     buf_gds-sum.Inv-CostSum        <> 0 or buf_gds-sum.Inv-SaleSum          <> 0 or buf_gds-sum.Spi-Qnty        <> 0 or buf_gds-sum.Spi-CostSum        <> 0 or
     buf_gds-sum.Spi-SaleSum        <> 0 or buf_gds-sum.InProiz-Qnty         <> 0 or buf_gds-sum.InProiz-CostSum <> 0 or buf_gds-sum.InProiz-SaleSum    <> 0 or
     buf_gds-sum.OutProiz-Qnty      <> 0 or buf_gds-sum.OutProiz-CostSum     <> 0 or buf_gds-sum.OutProiz-SaleSum <> 0 or buf_gds-sum.Per-SaleSum       <> 0 or
     buf_gds-sum.Free-Qnty          <> 0 or buf_gds-sum.Res-Qnty             <> 0
  then do:
    run PutTitul in this-procedure .
    if p-num = 4 and SumsOnly then do:
      if var-client <> "" then do:
        run macr_excel_char (var-client, v-row, 1) .
        assign v-row = v-row + 1 .
        PUT stream OutStream "| " var-client format "X(60)" "|" at beg  SKIP .
        assign  var-client = "" .
      end.
    end.
      assign v-col = 1 .
      run macr_excel_char (ItogStr, v-row, v-col) .
      if use-column[1]  = yes then assign v-col = v-col + 1 .
      if use-column[2]  = yes then assign v-col = v-col + 1 .
      if use-column[3]  = yes then assign v-col = v-col + 1 .
      if use-column[4]  = yes then assign v-col = v-col + 1 .
      if use-column[5]  = yes then assign v-col = v-col + 1 .
      if use-column[6]  = yes then assign v-col = v-col + 1 .
      if use-column[7]  = yes then assign v-col = v-col + 1 .
      if use-column[8]  = yes then assign v-col = v-col + 1 .
      if use-column[9]  = yes then assign v-col = v-col + 1 .
      if use-column[12] = yes then  do: run macr_excel_sum ( buf_gds-sum.StartWay-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[31] = yes then  do: run macr_excel_sum ( buf_gds-sum.StartWay-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[50] = yes then  do: run macr_excel_sum ( buf_gds-sum.StartWay-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[14] = yes then  do: run macr_excel_sum ( buf_gds-sum.InExt-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[33] = yes then  do: run macr_excel_sum ( buf_gds-sum.InExt-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[15] = yes then  do: run macr_excel_sum ( buf_gds-sum.RetPost-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[34] = yes then  do: run macr_excel_sum ( buf_gds-sum.RetPost-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[16] = yes then  do: run macr_excel_sum ( buf_gds-sum.OutExt-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[35] = yes then  do: run macr_excel_sum ( buf_gds-sum.OutExt-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[52] = yes then  do: run macr_excel_sum ( buf_gds-sum.OutExt-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[68] = yes then  do: run macr_excel_sum ( buf_gds-sum.OutExt-DiscntSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[77] = yes then  do: run macr_excel_sum ( buf_gds-sum.OutExt-DiscntSum * 100 / buf_gds-sum.OutExt-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[17] = yes then  do: run macr_excel_sum ( buf_gds-sum.RetOut-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[36] = yes then  do: run macr_excel_sum ( buf_gds-sum.RetOut-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[53] = yes then  do: run macr_excel_sum ( buf_gds-sum.RetOut-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[69] = yes then  do: run macr_excel_sum ( buf_gds-sum.RetOut-DiscntSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[78] = yes then  do: run macr_excel_sum ( buf_gds-sum.RetOut-DiscntSum * 100 / buf_gds-sum.RetOut-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[18] = yes then  do: run macr_excel_sum ( buf_gds-sum.OutExt-Qnty    - buf_gds-sum.RetOut-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[37] = yes then  do: run macr_excel_sum ( buf_gds-sum.OutExt-CostSum - buf_gds-sum.RetOut-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[54] = yes then  do: run macr_excel_sum ( buf_gds-sum.OutExt-SaleSum - buf_gds-sum.RetOut-SaleSum - (buf_gds-sum.OutExt-DiscntSum - buf_gds-sum.RetOut-DiscntSum), v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[70] = yes then  do: run macr_excel_sum ( buf_gds-sum.OutExt-DiscntSum - buf_gds-sum.RetOut-DiscntSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[79] = yes then  do: run macr_excel_sum ( ( buf_gds-sum.OutExt-DiscntSum - buf_gds-sum.RetOut-DiscntSum ) * 100 / ( buf_gds-sum.OutExt-SaleSum - buf_gds-sum.RetOut-SaleSum ), v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[19] = yes then  do: run macr_excel_sum ( buf_gds-sum.OutExtKass-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[38] = yes then  do: run macr_excel_sum ( buf_gds-sum.OutExtKass-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[55] = yes then  do: run macr_excel_sum ( buf_gds-sum.OutExtKass-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[71] = yes then  do: run macr_excel_sum ( buf_gds-sum.OutExtKass-DiscntSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[80] = yes then  do: run macr_excel_sum ( buf_gds-sum.OutExtKass-DiscntSum * 100 / buf_gds-sum.OutExtKass-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[20] = yes then  do: run macr_excel_sum ( buf_gds-sum.RetOutKass-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[39] = yes then  do: run macr_excel_sum ( buf_gds-sum.RetOutKass-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[56] = yes then  do: run macr_excel_sum ( buf_gds-sum.RetOutKass-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[72] = yes then  do: run macr_excel_sum ( buf_gds-sum.RetOutKass-DiscntSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[81] = yes then  do: run macr_excel_sum ( buf_gds-sum.RetOutKass-DiscntSum * 100 / buf_gds-sum.RetOutKass-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[21] = yes then  do: run macr_excel_sum ( buf_gds-sum.OutExtKass-Qnty    - buf_gds-sum.RetOutKass-Qnty , v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[40] = yes then  do: run macr_excel_sum ( buf_gds-sum.OutExtKass-CostSum - buf_gds-sum.RetOutKass-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[57] = yes then  do: run macr_excel_sum ( buf_gds-sum.OutExtKass-SaleSum - buf_gds-sum.RetOutKass-SaleSum - (buf_gds-sum.OutExtKass-DiscntSum - buf_gds-sum.RetOutKass-DiscntSum), v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[73] = yes then  do: run macr_excel_sum ( buf_gds-sum.OutExtKass-DiscntSum - buf_gds-sum.RetOutKass-DiscntSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[82] = yes then  do: run macr_excel_sum ( ( buf_gds-sum.OutExtKass-DiscntSum - buf_gds-sum.RetOutKass-DiscntSum ) * 100 / ( buf_gds-sum.OutExtKass-SaleSum - buf_gds-sum.RetOutKass-SaleSum ), v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[22] = yes then  do: run macr_excel_sum ( buf_gds-sum.OutExt-Qnty      + buf_gds-sum.OutExtKass-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[41] = yes then  do: run macr_excel_sum ( buf_gds-sum.OutExt-CostSum   + buf_gds-sum.OutExtKass-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[58] = yes then  do: run macr_excel_sum ( buf_gds-sum.OutExt-SaleSum   + buf_gds-sum.OutExtKass-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[74] = yes then  do: run macr_excel_sum ( buf_gds-sum.OutExt-DiscntSum + buf_gds-sum.OutExtKass-DiscntSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[83] = yes then  do: run macr_excel_sum ( ( buf_gds-sum.OutExt-DiscntSum + buf_gds-sum.OutExtKass-DiscntSum ) * 100 / ( buf_gds-sum.OutExt-SaleSum + buf_gds-sum.OutExtKass-SaleSum ) , v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[23] = yes then  do: run macr_excel_sum ( buf_gds-sum.RetOut-Qnty      + buf_gds-sum.RetOutKass-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[42] = yes then  do: run macr_excel_sum ( buf_gds-sum.RetOut-CostSum   + buf_gds-sum.RetOutKass-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[59] = yes then  do: run macr_excel_sum ( buf_gds-sum.RetOut-SaleSum   + buf_gds-sum.RetOutKass-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[75] = yes then  do: run macr_excel_sum ( buf_gds-sum.RetOut-DiscntSum + buf_gds-sum.RetOutKass-DiscntSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[84] = yes then  do: run macr_excel_sum ( ( buf_gds-sum.RetOut-DiscntSum + buf_gds-sum.RetOutKass-DiscntSum  ) * 100 / ( buf_gds-sum.RetOut-SaleSum + buf_gds-sum.RetOutKass-SaleSum ), v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[24] = yes then  do: run macr_excel_sum ( buf_gds-sum.OutExt-Qnty    - buf_gds-sum.RetOut-Qnty + buf_gds-sum.OutExtKass-Qnty - buf_gds-sum.RetOutKass-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[43] = yes then  do: run macr_excel_sum ( buf_gds-sum.OutExt-CostSum - buf_gds-sum.RetOut-CostSum + buf_gds-sum.OutExtKass-CostSum - buf_gds-sum.RetOutKass-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[60] = yes then  do: run macr_excel_sum ( buf_gds-sum.OutExt-SaleSum - buf_gds-sum.RetOut-SaleSum + buf_gds-sum.OutExtKass-SaleSum - buf_gds-sum.RetOutKass-SaleSum - ( buf_gds-sum.OutExt-DiscntSum - buf_gds-sum.RetOut-DiscntSum + buf_gds-sum.OutExtKass-DiscntSum - buf_gds-sum.RetOutKass-DiscntSum), v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[76] = yes then  do: run macr_excel_sum ( buf_gds-sum.OutExt-DiscntSum - buf_gds-sum.RetOut-DiscntSum + buf_gds-sum.OutExtKass-DiscntSum - buf_gds-sum.RetOutKass-DiscntSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[85] = yes then  do: run macr_excel_sum ( ( buf_gds-sum.OutExt-DiscntSum - buf_gds-sum.RetOut-DiscntSum + buf_gds-sum.OutExtKass-DiscntSum - buf_gds-sum.RetOutKass-DiscntSum ) * 100 / ( buf_gds-sum.OutExt-SaleSum - buf_gds-sum.RetOut-SaleSum + buf_gds-sum.OutExtKass-SaleSum - buf_gds-sum.RetOutKass-SaleSum  ), v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[25] = yes then  do: run macr_excel_sum ( buf_gds-sum.Inv-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[44] = yes then  do: run macr_excel_sum ( buf_gds-sum.Inv-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[61] = yes then  do: run macr_excel_sum ( buf_gds-sum.Inv-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[26] = yes then  do: run macr_excel_sum ( buf_gds-sum.Spi-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[45] = yes then  do: run macr_excel_sum ( buf_gds-sum.Spi-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[62] = yes then  do: run macr_excel_sum ( buf_gds-sum.Spi-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[27] = yes then  do: run macr_excel_sum ( buf_gds-sum.InInt-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[46] = yes then  do: run macr_excel_sum ( buf_gds-sum.InInt-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[63] = yes then  do: run macr_excel_sum ( buf_gds-sum.InInt-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[28] = yes then  do: run macr_excel_sum ( buf_gds-sum.OutInt-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[47] = yes then  do: run macr_excel_sum ( buf_gds-sum.OutInt-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[64] = yes then  do: run macr_excel_sum ( buf_gds-sum.OutInt-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[29] = yes then  do: run macr_excel_sum ( buf_gds-sum.RetInt-Qnty, v-row, v-col, sz-qnty) .    assign v-col = v-col + 1 . end.
      if use-column[48] = yes then  do: run macr_excel_sum ( buf_gds-sum.RetInt-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[65] = yes then  do: run macr_excel_sum ( buf_gds-sum.RetInt-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[30] = yes then  do: run macr_excel_sum ( buf_gds-sum.InProiz-Qnty, v-row, v-col, sz-qnty) .     assign v-col = v-col + 1 . end.
      if use-column[49] = yes then  do: run macr_excel_sum ( buf_gds-sum.InProiz-CostSum, v-row, v-col, 2) .  assign v-col = v-col + 1 . end.
      if use-column[66] = yes then  do: run macr_excel_sum ( buf_gds-sum.InProiz-SaleSum, v-row, v-col, 2) .  assign v-col = v-col + 1 . end.
      if use-column[86] = yes then  do: run macr_excel_sum ( buf_gds-sum.OutProiz-Qnty, v-row, v-col, sz-qnty) .    assign v-col = v-col + 1 . end.
      if use-column[87] = yes then  do: run macr_excel_sum ( buf_gds-sum.OutProiz-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[88] = yes then  do: run macr_excel_sum ( buf_gds-sum.OutProiz-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[67] = yes then  do: run macr_excel_sum ( buf_gds-sum.Per-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[13] = yes then  do: run macr_excel_sum ( buf_gds-sum.EndWay-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[32] = yes then  do: run macr_excel_sum ( buf_gds-sum.EndWay-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[51] = yes then  do: run macr_excel_sum ( buf_gds-sum.EndWay-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[10] = yes then do: run macr_excel_sum ( buf_gds-sum.Effect-Value, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[11] = yes then do: run macr_excel_sum ( buf_gds-sum.Effect-Value * 100 / ( buf_gds-sum.OutExt-CostSum + buf_gds-sum.OutExtKass-CostSum - buf_gds-sum.RetOut-CostSum - buf_gds-sum.RetOutKass-CostSum ), v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if RADIO-AltObj > 1 then do:     run macr_excel_sum ( buf_gds-sum.Alt-RestEnd-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[89] = yes then  do: run macr_excel_sum ( buf_gds-sum.Free-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[90] = yes then  do: run macr_excel_sum ( buf_gds-sum.Free-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[91] = yes then  do: run macr_excel_sum ( buf_gds-sum.Free-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[92] = yes then  do: run macr_excel_sum ( buf_gds-sum.Res-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[93] = yes then  do: run macr_excel_sum ( buf_gds-sum.Res-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[94] = yes then  do: run macr_excel_sum ( buf_gds-sum.Res-SaleSum - buf_gds-sum.Res-DiscntSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[95] = yes then  do: run macr_excel_sum ( buf_gds-sum.Res-DiscntSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[96] = yes then  do: run macr_excel_sum ( buf_gds-sum.Res-DiscntSum * 100 / buf_gds-sum.Res-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[97] = yes then  do:              assign v-col = v-col + 1 . end.
      if use-column[98] = yes then  do:              assign v-col = v-col + 1 . end.
      if use-column[99] = yes then  do:              assign v-col = v-col + 1 . end.
      if use-column[100] = yes then  do:                                     assign v-col = v-col + 1 . end.
      if use-column[101] = yes then  do:                                     assign v-col = v-col + 1 . end.
      if use-column[102] = yes then  do:                                     assign v-col = v-col + 1 . end.
      if use-column[103] = yes then  do:                                     assign v-col = v-col + 1 . end.
      if use-column[104] = yes then  do:                                     assign v-col = v-col + 1 . end.
      if use-column[105] = yes then  do:                                     assign v-col = v-col + 1 . end.
      if use-column[106] = yes then  do:                                     assign v-col = v-col + 1 . end.
      if use-column[107] = yes then  do:                                     assign v-col = v-col + 1 . end.
      if use-column[108] = yes then  do:                                     assign v-col = v-col + 1 . end.
      if use-column[109] = yes then  do:                                     assign v-col = v-col + 1 . end.
      if use-column[110] = yes then  do:                                     assign v-col = v-col + 1 . end.
      if use-column[111] = yes then  do:                                     assign v-col = v-col + 1 . end.
      if use-column[112] = yes then  do:                                     assign v-col = v-col + 1 . end.
      if use-column[113] = yes then  do:                                     assign v-col = v-col + 1 . end.
      if use-column[114] = yes then  do:                                     assign v-col = v-col + 1 . end.
      assign v-row = v-row + 1 .
      assign
        ii = 1
        jj = 1
      .
      if use-column[1]  = yes then assign ii = ii + 1  jj = jj + 1 .
      if use-column[2]  = yes then assign ii = ii + 1  jj = jj + 1.
      if use-column[3]  = yes then assign ii = ii + 1  jj = jj + 1.
      if use-column[4]  = yes then assign ii = ii + 1  jj = jj + 1.
      if use-column[5]  = yes then assign ii = ii + 1  jj = jj + 1.
      if use-column[6]  = yes then assign ii = ii + 1  jj = jj + 1.
      if use-column[7]  = yes then assign ii = ii + 1  jj = jj + 1.
      if use-column[8]  = yes then assign ii = ii + 1  jj = jj + 1.
      if use-column[9]  = yes then assign ii = ii + 1  jj = jj + 1.
      if use-column[12] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.StartWay-Qnty
          ii = ii + 1
        .
      end.
      if use-column[31] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.StartWay-CostSum
          ii = ii + 1
        .
      end.
      if use-column[50] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.StartWay-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[14] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.InExt-Qnty
          ii = ii + 1
        .
      end.
      if use-column[33] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.InExt-CostSum
          ii = ii + 1
        .
      end.
      if use-column[15] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.RetPost-Qnty
          ii = ii + 1
        .
      end.
      if use-column[34] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.RetPost-CostSum
          ii = ii + 1
        .
      end.
      if use-column[16] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.OutExt-Qnty
          ii = ii + 1
        .
      end.
      if use-column[35] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.OutExt-CostSum
          ii = ii + 1
        .
      end.
      if use-column[52] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.OutExt-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[68] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.OutExt-DiscntSum
          ii = ii + 1
        .
      end.
      if use-column[77] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.OutExt-DiscntSum * 100 / buf_gds-sum.OutExt-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[17] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.RetOut-Qnty
          ii = ii + 1
        .
      end.
      if use-column[36] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.RetOut-CostSum
          ii = ii + 1
        .
      end.
      if use-column[53] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.RetOut-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[69] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.RetOut-DiscntSum
          ii = ii + 1
        .
      end.
      if use-column[78] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.RetOut-DiscntSum * 100 / buf_gds-sum.RetOut-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[18] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.OutExt-Qnty - buf_gds-sum.RetOut-Qnty
          ii = ii + 1
        .
      end.
      if use-column[37] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.OutExt-CostSum - buf_gds-sum.RetOut-CostSum
          ii = ii + 1
        .
      end.
      if use-column[54] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.OutExt-SaleSum - buf_gds-sum.RetOut-SaleSum  - (buf_gds-sum.OutExt-DiscntSum - buf_gds-sum.RetOut-DiscntSum)
          ii = ii + 1
        .
      end.
      if use-column[70] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.OutExt-DiscntSum - buf_gds-sum.RetOut-DiscntSum
          ii = ii + 1
        .
      end.
      if use-column[79] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = ( buf_gds-sum.OutExt-DiscntSum - buf_gds-sum.RetOut-DiscntSum ) * 100 / ( buf_gds-sum.OutExt-SaleSum - buf_gds-sum.RetOut-SaleSum )
          ii = ii + 1
        .
      end.
      if use-column[19] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.OutExtKass-Qnty
          ii = ii + 1
        .
      end.
      if use-column[38] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.OutExtKass-CostSum
          ii = ii + 1
        .
      end.
      if use-column[55] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.OutExtKass-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[71] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.OutExtKass-DiscntSum
          ii = ii + 1
        .
      end.
      if use-column[80] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.OutExtKass-DiscntSum * 100 / buf_gds-sum.OutExtKass-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[20] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.RetOutKass-Qnty
          ii = ii + 1
        .
      end.
      if use-column[39] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.RetOutKass-CostSum
          ii = ii + 1
        .
      end.
      if use-column[56] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.RetOutKass-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[72] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.RetOutKass-DiscntSum
          ii = ii + 1
        .
      end.
      if use-column[81] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.RetOutKass-DiscntSum * 100 / buf_gds-sum.RetOutKass-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[21] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.OutExtKass-Qnty    - buf_gds-sum.RetOutKass-Qnty
          ii = ii + 1
        .
      end.
      if use-column[40] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.OutExtKass-CostSum - buf_gds-sum.RetOutKass-CostSum
          ii = ii + 1
        .
      end.
      if use-column[57] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.OutExtKass-SaleSum - buf_gds-sum.RetOutKass-SaleSum - (buf_gds-sum.OutExtKass-DiscntSum - buf_gds-sum.RetOutKass-DiscntSum)
          ii = ii + 1
        .
      end.
      if use-column[73] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.OutExtKass-DiscntSum - buf_gds-sum.RetOutKass-DiscntSum
          ii = ii + 1
        .
      end.
      if use-column[82] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = ( buf_gds-sum.OutExtKass-DiscntSum - buf_gds-sum.RetOutKass-DiscntSum ) * 100 / ( buf_gds-sum.OutExtKass-SaleSum - buf_gds-sum.RetOutKass-SaleSum )
          ii = ii + 1
        .
      end.
      if use-column[22] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.OutExt-Qnty      + buf_gds-sum.OutExtKass-Qnty
          ii = ii + 1
        .
      end.
      if use-column[41] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.OutExt-CostSum   + buf_gds-sum.OutExtKass-CostSum
          ii = ii + 1
        .
      end.
      if use-column[58] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.OutExt-SaleSum   + buf_gds-sum.OutExtKass-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[74] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.OutExt-DiscntSum + buf_gds-sum.OutExtKass-DiscntSum
          ii = ii + 1
        .
      end.
      if use-column[83] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = ( buf_gds-sum.OutExt-DiscntSum + buf_gds-sum.OutExtKass-DiscntSum ) * 100 / ( buf_gds-sum.OutExt-SaleSum + buf_gds-sum.OutExtKass-SaleSum )
          ii = ii + 1
        .
      end.
      if use-column[23] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.RetOut-Qnty      + buf_gds-sum.RetOutKass-Qnty
          ii = ii + 1
        .
      end.
      if use-column[42] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.RetOut-CostSum   + buf_gds-sum.RetOutKass-CostSum
          ii = ii + 1
        .
      end.
      if use-column[59] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.RetOut-SaleSum   + buf_gds-sum.RetOutKass-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[75] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.RetOut-DiscntSum + buf_gds-sum.RetOutKass-DiscntSum
          ii = ii + 1
        .
      end.
      if use-column[84] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = ( buf_gds-sum.RetOut-DiscntSum + buf_gds-sum.RetOutKass-DiscntSum  ) * 100 / ( buf_gds-sum.RetOut-SaleSum + buf_gds-sum.RetOutKass-SaleSum )
          ii = ii + 1
        .
      end.
      if use-column[24] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.OutExt-Qnty    - buf_gds-sum.RetOut-Qnty + buf_gds-sum.OutExtKass-Qnty - buf_gds-sum.RetOutKass-Qnty
          ii = ii + 1
        .
      end.
      if use-column[43] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.OutExt-CostSum - buf_gds-sum.RetOut-CostSum + buf_gds-sum.OutExtKass-CostSum - buf_gds-sum.RetOutKass-CostSum
          ii = ii + 1
        .
      end.
      if use-column[60] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.OutExt-SaleSum - buf_gds-sum.RetOut-SaleSum + buf_gds-sum.OutExtKass-SaleSum - buf_gds-sum.RetOutKass-SaleSum - (buf_gds-sum.OutExt-DiscntSum - buf_gds-sum.RetOut-DiscntSum + buf_gds-sum.OutExtKass-DiscntSum - buf_gds-sum.RetOutKass-DiscntSum)
          ii = ii + 1
        .
      end.
      if use-column[76] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.OutExt-DiscntSum - buf_gds-sum.RetOut-DiscntSum + buf_gds-sum.OutExtKass-DiscntSum - buf_gds-sum.RetOutKass-DiscntSum
          ii = ii + 1
        .
      end.
      if use-column[85] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = ( buf_gds-sum.OutExt-DiscntSum - buf_gds-sum.RetOut-DiscntSum + buf_gds-sum.OutExtKass-DiscntSum - buf_gds-sum.RetOutKass-DiscntSum ) * 100 / ( buf_gds-sum.OutExt-SaleSum - buf_gds-sum.RetOut-SaleSum + buf_gds-sum.OutExtKass-SaleSum - buf_gds-sum.RetOutKass-SaleSum  )
          ii = ii + 1
        .
      end.
      if use-column[25] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.Inv-Qnty
          ii = ii + 1
        .
      end.
      if use-column[44] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.Inv-CostSum
          ii = ii + 1
        .
      end.
      if use-column[61] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.Inv-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[26] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.Spi-Qnty
          ii = ii + 1
        .
      end.
      if use-column[45] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.Spi-CostSum
          ii = ii + 1
        .
      end.
      if use-column[62] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.Spi-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[27] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.InInt-Qnty
          ii = ii + 1
        .
      end.
      if use-column[46] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.InInt-CostSum
          ii = ii + 1
        .
      end.
      if use-column[63] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.InInt-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[28] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.OutInt-Qnty
          ii = ii + 1
        .
      end.
      if use-column[47] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.OutInt-CostSum
          ii = ii + 1
        .
      end.
      if use-column[64] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.OutInt-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[29] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.RetInt-Qnty
          ii = ii + 1
        .
      end.
      if use-column[48] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.RetInt-CostSum
          ii = ii + 1
        .
      end.
      if use-column[65] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.RetInt-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[30] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.InProiz-Qnty
          ii = ii + 1
        .
      end.
      if use-column[49] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.InProiz-CostSum
          ii = ii + 1
        .
      end.
      if use-column[66] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.InProiz-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[86] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.OutProiz-Qnty
          ii = ii + 1
        .
      end.
      if use-column[87] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.OutProiz-CostSum
          ii = ii + 1
        .
      end.
      if use-column[88] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.OutProiz-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[67] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.Per-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[13] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.EndWay-Qnty
          ii = ii + 1
        .
      end.
      if use-column[32] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.EndWay-CostSum
          ii = ii + 1
        .
      end.
      if use-column[51] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.EndWay-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[10] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.Effect-Value
          ii = ii + 1
        .
      end.
      if use-column[11] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.Effect-Value * 100 / ( buf_gds-sum.OutExt-CostSum + buf_gds-sum.OutExtKass-CostSum - buf_gds-sum.RetOut-CostSum - buf_gds-sum.RetOutKass-CostSum )
          ii = ii + 1
        .
        if line-frm.sum = ? then assign line-frm.sum = 0 .
      end.
      if RADIO-AltObj > 1 then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.Alt-RestEnd-Qnty
          ii = ii + 1
        .
      end.
      if use-column[89] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.Free-Qnty
          ii = ii + 1
        .
      end.
      if use-column[90] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.Free-CostSum
          ii = ii + 1
        .
      end.
      if use-column[91] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.Free-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[92] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.Res-Qnty
          ii = ii + 1
        .
      end.
      if use-column[93] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.Res-CostSum
          ii = ii + 1
        .
      end.
      if use-column[94] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.Res-SaleSum - buf_gds-sum.Res-DiscntSum
          ii = ii + 1
        .
      end.
      if use-column[95] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.Res-DiscntSum
          ii = ii + 1
        .
      end.
      if use-column[96] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = buf_gds-sum.Res-DiscntSum * 100 / buf_gds-sum.Res-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[97] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          ii = ii + 1
        .
      end.
      if use-column[98] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          ii = ii + 1
        .
      end.
      if use-column[99] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          ii = ii + 1
        .
      end.
      if use-column[100] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          ii = ii + 1
        .
      end.
      if use-column[101] = yes then do: find first line-frm where line-frm.num = ii . assign ii = ii + 1 .  end.
      if use-column[102] = yes then do: find first line-frm where line-frm.num = ii . assign ii = ii + 1 .  end.
      if use-column[103] = yes then do: find first line-frm where line-frm.num = ii . assign ii = ii + 1 .  end.
      if use-column[104] = yes then do: find first line-frm where line-frm.num = ii . assign ii = ii + 1 .  end.
      if use-column[105] = yes then do: find first line-frm where line-frm.num = ii . assign ii = ii + 1 .  end.
      if use-column[106] = yes then do: find first line-frm where line-frm.num = ii . assign ii = ii + 1 .  end.
      if use-column[107] = yes then do: find first line-frm where line-frm.num = ii . assign ii = ii + 1 .  end.
      if use-column[108] = yes then do: find first line-frm where line-frm.num = ii . assign ii = ii + 1 .  end.
      if use-column[109] = yes then do: find first line-frm where line-frm.num = ii . assign ii = ii + 1 .  end.
      if use-column[110] = yes then do: find first line-frm where line-frm.num = ii . assign ii = ii + 1 .  end.
      if use-column[111] = yes then do: find first line-frm where line-frm.num = ii . assign ii = ii + 1 .  end.
      if use-column[112] = yes then do: find first line-frm where line-frm.num = ii . assign ii = ii + 1 .  end.
      if use-column[113] = yes then do: find first line-frm where line-frm.num = ii . assign ii = ii + 1 .  end.
      if use-column[114] = yes then do: find first line-frm where line-frm.num = ii . assign ii = ii + 1 .  end.
      put stream outstream "| " ItogStr format "X(60)" .
      for each line-frm :
        if line-frm.num >= jj then do:
          if line-frm.frm  = "->>,>>>,>>9.99" and line-frm.sum > 99999999 then put stream outstream  "|" at line-frm.beg line-frm.sum format  "->>>>>>>>>9.99".
          else put stream outstream  "|" at line-frm.beg line-frm.sum format line-frm.frm .
        end.
      end.
      put stream outstream   "|"  skip Line format frmt skip.
    end.
end procedure.
procedure CalculSum :
  define input  parameter p-num as integer   no-undo .
  define buffer buf_gds-sum for gds-sum .
  find first buf_gds-sum where buf_gds-sum.num = p-num no-error .
define variable vss-include-info31 as character format "X(65)" no-undo
initial "@(#)$Workfile$".
assign
  buf_gds-sum.StartWay-Qnty         = buf_gds-sum.StartWay-Qnty          +  gds-prop.StartWay-Qnty
  buf_gds-sum.StartWay-CostSum      = buf_gds-sum.StartWay-CostSum       +  gds-prop.StartWay-CostSum
  buf_gds-sum.StartWay-SaleSum      = buf_gds-sum.StartWay-SaleSum       +  gds-prop.StartWay-SaleSum
  buf_gds-sum.EndWay-Qnty           = buf_gds-sum.EndWay-Qnty            +  gds-prop.EndWay-Qnty
  buf_gds-sum.EndWay-CostSum        = buf_gds-sum.EndWay-CostSum         +  gds-prop.EndWay-CostSum
  buf_gds-sum.EndWay-SaleSum        = buf_gds-sum.EndWay-SaleSum         +  gds-prop.EndWay-SaleSum
  buf_gds-sum.InExt-Qnty            = buf_gds-sum.InExt-Qnty             +  gds-prop.InExt-Qnty
  buf_gds-sum.InExt-CostSum         = buf_gds-sum.InExt-CostSum          +  gds-prop.InExt-CostSum
  buf_gds-sum.RetPost-Qnty          = buf_gds-sum.RetPost-Qnty           +  gds-prop.RetPost-Qnty
  buf_gds-sum.RetPost-CostSum       = buf_gds-sum.RetPost-CostSum        +  gds-prop.RetPost-CostSum
  buf_gds-sum.OutExt-Qnty           = buf_gds-sum.OutExt-Qnty            +  gds-prop.OutExt-Qnty
  buf_gds-sum.OutExt-CostSum        = buf_gds-sum.OutExt-CostSum         +  gds-prop.OutExt-CostSum
  buf_gds-sum.OutExt-SaleSum        = buf_gds-sum.OutExt-SaleSum         +  gds-prop.OutExt-SaleSum
  buf_gds-sum.OutExt-DiscntSum      = buf_gds-sum.OutExt-DiscntSum       +  gds-prop.OutExt-DiscntSum
  buf_gds-sum.RetOut-Qnty           = buf_gds-sum.RetOut-Qnty            +  gds-prop.RetOut-Qnty
  buf_gds-sum.RetOut-CostSum        = buf_gds-sum.RetOut-CostSum         +  gds-prop.RetOut-CostSum
  buf_gds-sum.RetOut-SaleSum        = buf_gds-sum.RetOut-SaleSum         +  gds-prop.RetOut-SaleSum
  buf_gds-sum.RetOut-DiscntSum      = buf_gds-sum.RetOut-DiscntSum       +  gds-prop.RetOut-DiscntSum
  buf_gds-sum.OutExtKass-Qnty       = buf_gds-sum.OutExtKass-Qnty        +  gds-prop.OutExtKass-Qnty
  buf_gds-sum.OutExtKass-CostSum    = buf_gds-sum.OutExtKass-CostSum     +  gds-prop.OutExtKass-CostSum
  buf_gds-sum.OutExtKass-SaleSum    = buf_gds-sum.OutExtKass-SaleSum     +  gds-prop.OutExtKass-SaleSum
  buf_gds-sum.OutExtKass-DiscntSum  = buf_gds-sum.OutExtKass-DiscntSum   +  gds-prop.OutExtKass-DiscntSum
  buf_gds-sum.RetOutKass-Qnty       = buf_gds-sum.RetOutKass-Qnty        +  gds-prop.RetOutKass-Qnty
  buf_gds-sum.RetOutKass-CostSum    = buf_gds-sum.RetOutKass-CostSum     +  gds-prop.RetOutKass-CostSum
.
assign
  buf_gds-sum.RetOutKass-SaleSum    = buf_gds-sum.RetOutKass-SaleSum     +  gds-prop.RetOutKass-SaleSum
  buf_gds-sum.RetOutKass-DiscntSum  = buf_gds-sum.RetOutKass-DiscntSum   +  gds-prop.RetOutKass-DiscntSum
  buf_gds-sum.InInt-Qnty            = buf_gds-sum.InInt-Qnty             +  gds-prop.InInt-Qnty
  buf_gds-sum.InInt-CostSum         = buf_gds-sum.InInt-CostSum          +  gds-prop.InInt-CostSum
  buf_gds-sum.InInt-SaleSum         = buf_gds-sum.InInt-SaleSum          +  gds-prop.InInt-SaleSum
  buf_gds-sum.OutInt-Qnty           = buf_gds-sum.OutInt-Qnty            +  gds-prop.OutInt-Qnty
  buf_gds-sum.OutInt-CostSum        = buf_gds-sum.OutInt-CostSum         +  gds-prop.OutInt-CostSum
  buf_gds-sum.OutInt-SaleSum        = buf_gds-sum.OutInt-SaleSum         +  gds-prop.OutInt-SaleSum
  buf_gds-sum.RetInt-Qnty           = buf_gds-sum.RetInt-Qnty            +  gds-prop.RetInt-Qnty
  buf_gds-sum.RetInt-CostSum        = buf_gds-sum.RetInt-CostSum         +  gds-prop.RetInt-CostSum
  buf_gds-sum.RetInt-SaleSum        = buf_gds-sum.RetInt-SaleSum         +  gds-prop.RetInt-SaleSum
  buf_gds-sum.Inv-Qnty              = buf_gds-sum.Inv-Qnty               +  gds-prop.Inv-Qnty
  buf_gds-sum.Inv-CostSum           = buf_gds-sum.Inv-CostSum            +  gds-prop.Inv-CostSum
  buf_gds-sum.Inv-SaleSum           = buf_gds-sum.Inv-SaleSum            +  gds-prop.Inv-SaleSum
  buf_gds-sum.Spi-Qnty              = buf_gds-sum.Spi-Qnty               +  gds-prop.Spi-Qnty
  buf_gds-sum.Spi-CostSum           = buf_gds-sum.Spi-CostSum            +  gds-prop.Spi-CostSum
  buf_gds-sum.Spi-SaleSum           = buf_gds-sum.Spi-SaleSum            +  gds-prop.Spi-SaleSum
  buf_gds-sum.InProiz-Qnty          = buf_gds-sum.InProiz-Qnty           +  gds-prop.InProiz-Qnty
  buf_gds-sum.InProiz-CostSum       = buf_gds-sum.InProiz-CostSum        +  gds-prop.InProiz-CostSum
  buf_gds-sum.InProiz-SaleSum       = buf_gds-sum.InProiz-SaleSum        +  gds-prop.InProiz-SaleSum
  buf_gds-sum.OutProiz-Qnty         = buf_gds-sum.OutProiz-Qnty          +  gds-prop.OutProiz-Qnty
  buf_gds-sum.OutProiz-CostSum      = buf_gds-sum.OutProiz-CostSum       +  gds-prop.OutProiz-CostSum
  buf_gds-sum.OutProiz-SaleSum      = buf_gds-sum.OutProiz-SaleSum       +  gds-prop.OutProiz-SaleSum
  buf_gds-sum.Per-SaleSum           = buf_gds-sum.Per-SaleSum            +  gds-prop.Per-SaleSum
  buf_gds-sum.Alt-RestEnd-Qnty      = buf_gds-sum.Alt-RestEnd-Qnty       +  gds-prop.Alt-RestEnd-Qnty
  buf_gds-sum.Effect-Value          = buf_gds-sum.Effect-Value           +  gds-prop.Effect-Value
  buf_gds-sum.Free-Qnty             = buf_gds-sum.Free-Qnty              +  gds-prop.Free-Qnty
  buf_gds-sum.Free-CostSum          = buf_gds-sum.Free-CostSum           +  gds-prop.Free-CostSum
  buf_gds-sum.Free-SaleSum          = buf_gds-sum.Free-SaleSum           +  gds-prop.Free-SaleSum
  buf_gds-sum.Res-Qnty              = buf_gds-sum.Res-Qnty               +  gds-prop.Res-Qnty
  buf_gds-sum.Res-CostSum           = buf_gds-sum.Res-CostSum            +  gds-prop.Res-CostSum
  buf_gds-sum.Res-DocSum            = buf_gds-sum.Res-DocSum             +  gds-prop.Res-DocSum
  buf_gds-sum.Res-SaleSum           = buf_gds-sum.Res-SaleSum            +  gds-prop.Res-SaleSum
  buf_gds-sum.Res-DiscntSum         = buf_gds-sum.Res-DiscntSum          +  gds-prop.Res-DiscntSum
.
end procedure.
procedure Create-gds-sum :
  define input  parameter p-num as integer   no-undo .
  define buffer buf_gds-sum for gds-sum .
  find first buf_gds-sum where buf_gds-sum.num = p-num no-error .
  if not available buf_gds-sum then do:
    create buf_gds-sum .
    assign
      buf_gds-sum.num = p-num
    .
  end.
define variable vss-include-info32 as character format "X(65)" no-undo
initial "@(#)$Workfile$".
assign
  buf_gds-sum.StartWay-Qnty         = 0
  buf_gds-sum.StartWay-CostSum      = 0
  buf_gds-sum.StartWay-SaleSum      = 0
  buf_gds-sum.EndWay-Qnty           = 0
  buf_gds-sum.EndWay-CostSum        = 0
  buf_gds-sum.EndWay-SaleSum        = 0
  buf_gds-sum.Free-Qnty             = 0
  buf_gds-sum.Free-CostSum          = 0
  buf_gds-sum.Free-SaleSum          = 0
  buf_gds-sum.Res-Qnty              = 0
  buf_gds-sum.Res-CostSum           = 0
  buf_gds-sum.Res-SaleSum           = 0
  buf_gds-sum.Res-DiscntSum         = 0
  buf_gds-sum.InExt-Qnty            = 0
  buf_gds-sum.InExt-CostSum         = 0
  buf_gds-sum.RetPost-Qnty          = 0
  buf_gds-sum.RetPost-CostSum       = 0
  buf_gds-sum.OutExt-Qnty           = 0
  buf_gds-sum.OutExt-CostSum        = 0
  buf_gds-sum.OutExt-SaleSum        = 0
  buf_gds-sum.OutExt-DiscntSum      = 0
  buf_gds-sum.RetOut-Qnty           = 0
  buf_gds-sum.RetOut-CostSum        = 0
  buf_gds-sum.RetOut-SaleSum        = 0
  buf_gds-sum.RetOut-DiscntSum      = 0
  buf_gds-sum.OutExtKass-Qnty       = 0
  buf_gds-sum.OutExtKass-CostSum    = 0
  buf_gds-sum.OutExtKass-SaleSum    = 0
  buf_gds-sum.OutExtKass-DiscntSum  = 0
  buf_gds-sum.RetOutKass-Qnty       = 0
  buf_gds-sum.RetOutKass-CostSum    = 0
  buf_gds-sum.RetOutKass-SaleSum    = 0
  buf_gds-sum.RetOutKass-DiscntSum  = 0
  buf_gds-sum.InInt-Qnty            = 0
  buf_gds-sum.InInt-CostSum         = 0
  buf_gds-sum.InInt-SaleSum         = 0
  buf_gds-sum.OutInt-Qnty           = 0
  buf_gds-sum.OutInt-CostSum        = 0
  buf_gds-sum.OutInt-SaleSum        = 0
  buf_gds-sum.RetInt-Qnty           = 0
  buf_gds-sum.RetInt-CostSum        = 0
  buf_gds-sum.RetInt-SaleSum        = 0
  buf_gds-sum.Inv-Qnty              = 0
  buf_gds-sum.Inv-CostSum           = 0
  buf_gds-sum.Inv-SaleSum           = 0
  buf_gds-sum.Spi-Qnty              = 0
  buf_gds-sum.Spi-CostSum           = 0
  buf_gds-sum.Spi-SaleSum           = 0
  buf_gds-sum.InProiz-Qnty          = 0
  buf_gds-sum.InProiz-CostSum       = 0
  buf_gds-sum.InProiz-SaleSum       = 0
  buf_gds-sum.OutProiz-Qnty         = 0
  buf_gds-sum.OutProiz-CostSum      = 0
  buf_gds-sum.OutProiz-SaleSum      = 0
  buf_gds-sum.Per-SaleSum           = 0
  buf_gds-sum.Effect-Value          = 0
  buf_gds-sum.Alt-RestEnd-Qnty      = 0
.
end procedure.
procedure PrintLine :
  if SumsOnly = no then do:
      if sys-key = "parts" then do:
         run macr_cell_format ( 10 , yes, no, ?, v-row, 1, v-row, 100) .
      end.
      assign v-col = 1 .
      if use-column[1]  = yes then do: run macr_excel_char ( string (gds-prop.b-code), v-row, v-col) . assign v-col = v-col + 1 . end.
      if use-column[2]  = yes then do: run macr_excel_char ( gds-prop.artic     , v-row, v-col) . assign v-col = v-col + 1 . end.
      if use-column[3]  = yes then do: run macr_excel_char ( gds-prop.gds-name  , v-row, v-col) . assign v-col = v-col + 1 . end.
      if use-column[4]  = yes then do: run macr_excel_char ( gds-prop.unit-base , v-row, v-col) . assign v-col = v-col + 1 . end.
      if use-column[5]  = yes then do: run macr_excel_sum  ( gds-prop.Cost-Price, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[6]  = yes then do:
        if prod-zen = yes then do:
          run macr_excel_sum  ( gds-prop.Avrg-Sale-Price, v-row, v-col, 2) .
        end.
        else do:
          run macr_excel_sum  ( gds-prop.Last-Sale-Price, v-row, v-col, 2) .
        end.
        assign v-col = v-col + 1 .
      end.
      if use-column[7]  = yes then do: run macr_excel_sum  ( gds-prop.Up-Plan, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[8]  = yes then do:
        if gds-prop.LastPer-Date <> ? then do: run macr_excel_char (string(gds-prop.LastPer-Date,"99.99.9999"), v-row, v-col) .  end.
        assign v-col = v-col + 1 .
      end.
      if use-column[9]  = yes then do: run macr_excel_char (gds-prop.LastPer-Num, v-row, v-col) . assign v-col = v-col + 1 . end.
      if use-column[12] = yes then  do: run macr_excel_sum ( gds-prop.StartWay-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[31] = yes then  do: run macr_excel_sum ( gds-prop.StartWay-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[50] = yes then  do: run macr_excel_sum ( gds-prop.StartWay-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[14] = yes then  do: run macr_excel_sum ( gds-prop.InExt-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[33] = yes then  do: run macr_excel_sum ( gds-prop.InExt-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[15] = yes then  do: run macr_excel_sum ( gds-prop.RetPost-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[34] = yes then  do: run macr_excel_sum ( gds-prop.RetPost-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[16] = yes then  do: run macr_excel_sum ( gds-prop.OutExt-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[35] = yes then  do: run macr_excel_sum ( gds-prop.OutExt-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[52] = yes then  do: run macr_excel_sum ( gds-prop.OutExt-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[68] = yes then  do: run macr_excel_sum ( gds-prop.OutExt-DiscntSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[77] = yes then  do: run macr_excel_sum ( gds-prop.OutExt-DiscntSum * 100 / gds-prop.OutExt-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[17] = yes then  do: run macr_excel_sum ( gds-prop.RetOut-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[36] = yes then  do: run macr_excel_sum ( gds-prop.RetOut-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[53] = yes then  do: run macr_excel_sum ( gds-prop.RetOut-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[69] = yes then  do: run macr_excel_sum ( gds-prop.RetOut-DiscntSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[78] = yes then  do: run macr_excel_sum ( gds-prop.RetOut-DiscntSum * 100 / gds-prop.RetOut-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[18] = yes then  do: run macr_excel_sum ( gds-prop.OutExt-Qnty    - gds-prop.RetOut-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[37] = yes then  do: run macr_excel_sum ( gds-prop.OutExt-CostSum - gds-prop.RetOut-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[54] = yes then  do: run macr_excel_sum ( gds-prop.OutExt-SaleSum - gds-prop.RetOut-SaleSum - gds-prop.OutExt-DiscntSum + gds-prop.RetOut-DiscntSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[70] = yes then  do: run macr_excel_sum ( gds-prop.OutExt-DiscntSum - gds-prop.RetOut-DiscntSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[79] = yes then  do: run macr_excel_sum ( ( gds-prop.OutExt-DiscntSum - gds-prop.RetOut-DiscntSum ) * 100 / ( gds-prop.OutExt-SaleSum - gds-prop.RetOut-SaleSum ), v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[19] = yes then  do: run macr_excel_sum ( gds-prop.OutExtKass-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[38] = yes then  do: run macr_excel_sum ( gds-prop.OutExtKass-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[55] = yes then  do: run macr_excel_sum ( gds-prop.OutExtKass-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[71] = yes then  do: run macr_excel_sum ( gds-prop.OutExtKass-DiscntSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[80] = yes then  do: run macr_excel_sum ( gds-prop.OutExtKass-DiscntSum * 100 / gds-prop.OutExtKass-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[20] = yes then  do: run macr_excel_sum ( gds-prop.RetOutKass-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[39] = yes then  do: run macr_excel_sum ( gds-prop.RetOutKass-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[56] = yes then  do: run macr_excel_sum ( gds-prop.RetOutKass-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[72] = yes then  do: run macr_excel_sum ( gds-prop.RetOutKass-DiscntSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[81] = yes then  do: run macr_excel_sum ( gds-prop.RetOutKass-DiscntSum * 100 / gds-prop.RetOutKass-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[21] = yes then  do: run macr_excel_sum ( gds-prop.OutExtKass-Qnty    - gds-prop.RetOutKass-Qnty , v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[40] = yes then  do: run macr_excel_sum ( gds-prop.OutExtKass-CostSum - gds-prop.RetOutKass-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[57] = yes then  do: run macr_excel_sum ( gds-prop.OutExtKass-SaleSum - gds-prop.RetOutKass-SaleSum - gds-prop.OutExtKass-DiscntSum + gds-prop.RetOutKass-DiscntSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[73] = yes then  do: run macr_excel_sum ( gds-prop.OutExtKass-DiscntSum - gds-prop.RetOutKass-DiscntSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[82] = yes then  do: run macr_excel_sum ( ( gds-prop.OutExtKass-DiscntSum - gds-prop.RetOutKass-DiscntSum ) * 100 / ( gds-prop.OutExtKass-SaleSum - gds-prop.RetOutKass-SaleSum ), v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[22] = yes then  do: run macr_excel_sum ( gds-prop.OutExt-Qnty      + gds-prop.OutExtKass-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[41] = yes then  do: run macr_excel_sum ( gds-prop.OutExt-CostSum   + gds-prop.OutExtKass-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[58] = yes then  do: run macr_excel_sum ( gds-prop.OutExt-SaleSum   + gds-prop.OutExtKass-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[74] = yes then  do: run macr_excel_sum ( gds-prop.OutExt-DiscntSum + gds-prop.OutExtKass-DiscntSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[83] = yes then  do: run macr_excel_sum ( ( gds-prop.OutExt-DiscntSum + gds-prop.OutExtKass-DiscntSum ) * 100 / ( gds-prop.OutExt-SaleSum + gds-prop.OutExtKass-SaleSum ) , v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[23] = yes then  do: run macr_excel_sum ( gds-prop.RetOut-Qnty      + gds-prop.RetOutKass-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[42] = yes then  do: run macr_excel_sum ( gds-prop.RetOut-CostSum   + gds-prop.RetOutKass-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[59] = yes then  do: run macr_excel_sum ( gds-prop.RetOut-SaleSum   + gds-prop.RetOutKass-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[75] = yes then  do: run macr_excel_sum ( gds-prop.RetOut-DiscntSum + gds-prop.RetOutKass-DiscntSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[84] = yes then  do: run macr_excel_sum ( ( gds-prop.RetOut-DiscntSum + gds-prop.RetOutKass-DiscntSum  ) * 100 / ( gds-prop.RetOut-SaleSum + gds-prop.RetOutKass-SaleSum ), v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[24] = yes then  do: run macr_excel_sum ( gds-prop.OutExt-Qnty    - gds-prop.RetOut-Qnty + gds-prop.OutExtKass-Qnty - gds-prop.RetOutKass-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[43] = yes then  do: run macr_excel_sum ( gds-prop.OutExt-CostSum - gds-prop.RetOut-CostSum + gds-prop.OutExtKass-CostSum - gds-prop.RetOutKass-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[60] = yes then  do: run macr_excel_sum ( gds-prop.OutExt-SaleSum - gds-prop.RetOut-SaleSum + gds-prop.OutExtKass-SaleSum - gds-prop.RetOutKass-SaleSum - gds-prop.OutExt-DiscntSum + gds-prop.RetOut-DiscntSum - gds-prop.OutExtKass-DiscntSum + gds-prop.RetOutKass-DiscntSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[76] = yes then  do: run macr_excel_sum ( gds-prop.OutExt-DiscntSum - gds-prop.RetOut-DiscntSum + gds-prop.OutExtKass-DiscntSum - gds-prop.RetOutKass-DiscntSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[85] = yes then  do: run macr_excel_sum ( ( gds-prop.OutExt-DiscntSum - gds-prop.RetOut-DiscntSum + gds-prop.OutExtKass-DiscntSum - gds-prop.RetOutKass-DiscntSum ) * 100 / ( gds-prop.OutExt-SaleSum - gds-prop.RetOut-SaleSum + gds-prop.OutExtKass-SaleSum - gds-prop.RetOutKass-SaleSum  ), v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[25] = yes then  do: run macr_excel_sum ( gds-prop.Inv-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[44] = yes then  do: run macr_excel_sum ( gds-prop.Inv-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[61] = yes then  do: run macr_excel_sum ( gds-prop.Inv-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[26] = yes then  do: run macr_excel_sum ( gds-prop.Spi-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[45] = yes then  do: run macr_excel_sum ( gds-prop.Spi-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[62] = yes then  do: run macr_excel_sum ( gds-prop.Spi-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[27] = yes then  do: run macr_excel_sum ( gds-prop.InInt-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[46] = yes then  do: run macr_excel_sum ( gds-prop.InInt-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[63] = yes then  do: run macr_excel_sum ( gds-prop.InInt-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[28] = yes then  do: run macr_excel_sum ( gds-prop.OutInt-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[47] = yes then  do: run macr_excel_sum ( gds-prop.OutInt-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[64] = yes then  do: run macr_excel_sum ( gds-prop.OutInt-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[29] = yes then  do: run macr_excel_sum ( gds-prop.RetInt-Qnty, v-row, v-col, sz-qnty) .    assign v-col = v-col + 1 . end.
      if use-column[48] = yes then  do: run macr_excel_sum ( gds-prop.RetInt-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[65] = yes then  do: run macr_excel_sum ( gds-prop.RetInt-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[30] = yes then  do: run macr_excel_sum ( gds-prop.InProiz-Qnty, v-row, v-col, sz-qnty) .     assign v-col = v-col + 1 . end.
      if use-column[49] = yes then  do: run macr_excel_sum ( gds-prop.InProiz-CostSum, v-row, v-col, 2) .  assign v-col = v-col + 1 . end.
      if use-column[66] = yes then  do: run macr_excel_sum ( gds-prop.InProiz-SaleSum, v-row, v-col, 2) .  assign v-col = v-col + 1 . end.
      if use-column[86] = yes then  do: run macr_excel_sum ( gds-prop.OutProiz-Qnty, v-row, v-col, sz-qnty) .    assign v-col = v-col + 1 . end.
      if use-column[87] = yes then  do: run macr_excel_sum ( gds-prop.OutProiz-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[88] = yes then  do: run macr_excel_sum ( gds-prop.OutProiz-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[67] = yes then  do: run macr_excel_sum ( gds-prop.Per-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[13] = yes then  do: run macr_excel_sum ( gds-prop.EndWay-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[32] = yes then  do: run macr_excel_sum ( gds-prop.EndWay-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[51] = yes then  do: run macr_excel_sum ( gds-prop.EndWay-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[10] =  yes then  do: run macr_excel_sum ( gds-prop.Effect-Value, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[11] =  yes then  do: run macr_excel_sum ( gds-prop.Up-Fact, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if RADIO-AltObj > 1  then  do: run macr_excel_sum ( gds-prop.Alt-RestEnd-Qnty, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[89] = yes then  do: run macr_excel_sum ( gds-prop.Free-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[90] = yes then  do: run macr_excel_sum ( gds-prop.Free-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[91] = yes then  do: run macr_excel_sum ( gds-prop.Free-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[92] = yes then  do: run macr_excel_sum ( gds-prop.Res-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[93] = yes then  do: run macr_excel_sum ( gds-prop.Res-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[94] = yes then  do: run macr_excel_sum ( gds-prop.Res-SaleSum - gds-prop.Res-DiscntSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[95] = yes then  do: run macr_excel_sum ( gds-prop.Res-DiscntSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[96] = yes then  do: run macr_excel_sum ( gds-prop.Res-DiscntSum * 100 / gds-prop.Res-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[97]  = yes then  do:                                     assign v-col = v-col + 1 . end.
      if use-column[98]  = yes then  do:                                     assign v-col = v-col + 1 . end.
      if use-column[99]  = yes then  do:                                     assign v-col = v-col + 1 . end.
      if use-column[100] = yes then  do:                                     assign v-col = v-col + 1 . end.
      if use-column[101] = yes then  do:                                     assign v-col = v-col + 1 . end.
      if use-column[102] = yes then  do:                                     assign v-col = v-col + 1 . end.
      if use-column[103] = yes then  do:                                     assign v-col = v-col + 1 . end.
      if use-column[104] = yes then  do:                                     assign v-col = v-col + 1 . end.
      if use-column[105] = yes then  do:                                     assign v-col = v-col + 1 . end.
      if use-column[106] = yes then  do:                                     assign v-col = v-col + 1 . end.
      if use-column[107] = yes then  do:                                     assign v-col = v-col + 1 . end.
      if use-column[108] = yes then  do:                                     assign v-col = v-col + 1 . end.
      if use-column[109] = yes then  do:                                     assign v-col = v-col + 1 . end.
      if use-column[110] = yes then  do:                                     assign v-col = v-col + 1 . end.
      if use-column[111] = yes then  do:                                     assign v-col = v-col + 1 . end.
      if use-column[112] = yes then  do:                                     assign v-col = v-col + 1 . end.
      if use-column[113] = yes then  do:                                     assign v-col = v-col + 1 . end.
      if use-column[114] = yes then  do:                                     assign v-col = v-col + 1 . end.
      assign v-row = v-row + 1 .
      if name-tov = 3 and use-column[3] = yes then do:
        assign   v-col = 1 .
        if use-column[1]  = yes then  assign v-col = v-col + 1 .
        if use-column[2]  = yes then  assign v-col = v-col + 1 .
        run macr_excel_char ( gds-prop.gds-name1, v-row, v-col) .
        assign
          v-row = v-row + 1
          .
      end.
      assign
        ii = 1
        jj = 1
      .
    if ExportZUM then do:
      if tog-obj = true then do:
        put stream txt-file
          gds-prop.obj-type format "X(5)"   CHR(9)
          gds-prop.obj-code format ">>>>>>>9" CHR(9)
          gds-prop.obj-name format "X(50)"   CHR(9)
        .
      end.
      put stream txt-file
        gds-prop.grp-name format "X(70)"  CHR(9)
        gds-prop.prod-type format "X(5)"   CHR(9)
        gds-prop.prod-code format ">>>>>>>>>>>9" CHR(9)
        gds-prop.prod-name format "X(50)"  CHR(9)
      .
    end.
      if use-column[1]  = yes then do:
        find first line-frm where line-frm.num = ii .
        put stream outstream  "|" at line-frm.beg gds-prop.b-code format line-frm.frm .
        if ExportZUM then put stream txt-file  gds-prop.b-code format line-frm.frm CHR(9).
        assign
          ii = ii + 1
          jj = jj + 1
        .
      end.
      if use-column[2]  = yes then do:
        find first line-frm where line-frm.num = ii .
        if ExportZUM then put stream txt-file  gds-prop.artic format "X(16)" CHR(9) .
        put stream outstream  "|" at line-frm.beg gds-prop.artic format line-frm.frm .
        assign
          ii = ii + 1
          jj = jj + 1
        .
      end.
      if use-column[3]  = yes then do:
        find first line-frm where line-frm.num = ii .
        if ExportZUM then put stream txt-file  gds-prop.gds-name format "X(40)" CHR(9) .
        put stream outstream  "|" at line-frm.beg gds-prop.gds-name format line-frm.frm .
        assign
          ii = ii + 1
          jj = jj + 1
        .
      end.
      if use-column[4]  = yes then do:
        find first line-frm where line-frm.num = ii .
        if ExportZUM then put stream txt-file  gds-prop.unit-base format "X(4)" CHR(9) .
        put stream outstream  "|" at line-frm.beg gds-prop.unit-base format line-frm.frm .
        assign
          ii = ii + 1
          jj = jj + 1
        .
      end.
      if use-column[5]  = yes then do:
        find first line-frm where line-frm.num = ii .
        if ExportZUM then put stream txt-file UNFORMATTED  replace(string(gds-prop.Cost-Price,frm-sum1),".",",")   CHR(9) .
        put stream outstream  "|" at line-frm.beg gds-prop.Cost-Price format line-frm.frm .
        assign
          ii = ii + 1
          jj = jj + 1
        .
      end.
      if use-column[6]  = yes then do:
        find first line-frm where line-frm.num = ii .
        if prod-zen = yes then do:
           if ExportZUM then put stream txt-file UNFORMATTED  replace(string(gds-prop.Avrg-Sale-Price,frm-sum1),".",",")   CHR(9) .
           put stream outstream  "|" at line-frm.beg gds-prop.Avrg-Sale-Price format line-frm.frm .
        end.
        else do:
          if ExportZUM then put stream txt-file UNFORMATTED  replace(string(gds-prop.Last-Sale-Price,frm-sum1),".",",")  CHR(9) .
          put stream outstream  "|" at line-frm.beg gds-prop.Last-Sale-Price format line-frm.frm .
        end.
        assign
          ii = ii + 1
          jj = jj + 1
        .
      end.
      if use-column[7]  = yes then do:
        find first line-frm where line-frm.num = ii .
        put stream outstream  "|" at line-frm.beg gds-prop.Up-Plan format line-frm.frm .
        if ExportZUM then put stream txt-file UNFORMATTED  replace(string(gds-prop.Up-Plan,frm-sum1),".",",")  CHR(9) .
        assign
          ii = ii + 1
          jj = jj + 1
        .
      end.
      if use-column[8]  = yes then do:
        find first line-frm where line-frm.num = ii .
        put stream outstream  "|" at line-frm.beg gds-prop.LastPer-Date format line-frm.frm .
        if ExportZUM then put stream txt-file  gds-prop.LastPer-Date format "99/99/9999" CHR(9) .
        assign
          ii = ii + 1
          jj = jj + 1
        .
      end.
      if use-column[9]  = yes then do:
        find first line-frm where line-frm.num = ii .
        put stream outstream  "|" at line-frm.beg gds-prop.LastPer-Num format line-frm.frm .
        if ExportZUM then put stream txt-file  gds-prop.LastPer-Num format "X(10)" CHR(9) .
        assign
          ii = ii + 1
          jj = jj + 1
        .
      end.
      if use-column[12] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.StartWay-Qnty
          ii = ii + 1
        .
      end.
      if use-column[31] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.StartWay-CostSum
          ii = ii + 1
        .
      end.
      if use-column[50] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.StartWay-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[14] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.InExt-Qnty
          ii = ii + 1
        .
      end.
      if use-column[33] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.InExt-CostSum
          ii = ii + 1
        .
      end.
      if use-column[15] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.RetPost-Qnty
          ii = ii + 1
        .
      end.
      if use-column[34] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.RetPost-CostSum
          ii = ii + 1
        .
      end.
      if use-column[16] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.OutExt-Qnty
          ii = ii + 1
        .
      end.
      if use-column[35] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.OutExt-CostSum
          ii = ii + 1
        .
      end.
      if use-column[52] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.OutExt-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[68] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.OutExt-DiscntSum
          ii = ii + 1
        .
      end.
      if use-column[77] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.OutExt-DiscntSum * 100 / gds-prop.OutExt-SaleSum
          ii = ii + 1
        .
        if line-frm.sum = ? then assign line-frm.sum = 0 .
      end.
      if use-column[17] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.RetOut-Qnty
          ii = ii + 1
        .
      end.
      if use-column[36] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.RetOut-CostSum
          ii = ii + 1
        .
      end.
      if use-column[53] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.RetOut-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[69] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.RetOut-DiscntSum
          ii = ii + 1
        .
      end.
      if use-column[78] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.RetOut-DiscntSum * 100 / gds-prop.RetOut-SaleSum
          ii = ii + 1
        .
        if line-frm.sum = ? then assign line-frm.sum = 0 .
      end.
      if use-column[18] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.OutExt-Qnty - gds-prop.RetOut-Qnty
          ii = ii + 1
        .
      end.
      if use-column[37] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.OutExt-CostSum - gds-prop.RetOut-CostSum
          ii = ii + 1
        .
      end.
      if use-column[54] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.OutExt-SaleSum - gds-prop.RetOut-SaleSum - gds-prop.OutExt-DiscntSum + gds-prop.RetOut-DiscntSum
          ii = ii + 1
        .
      end.
      if use-column[70] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.OutExt-DiscntSum - gds-prop.RetOut-DiscntSum
          ii = ii + 1
        .
      end.
      if use-column[79] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = ( gds-prop.OutExt-DiscntSum - gds-prop.RetOut-DiscntSum ) * 100 / ( gds-prop.OutExt-SaleSum - gds-prop.RetOut-SaleSum )
          ii = ii + 1
        .
        if line-frm.sum = ? then assign line-frm.sum = 0 .
      end.
      if use-column[19] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.OutExtKass-Qnty
          ii = ii + 1
        .
      end.
      if use-column[38] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.OutExtKass-CostSum
          ii = ii + 1
        .
      end.
      if use-column[55] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.OutExtKass-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[71] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.OutExtKass-DiscntSum
          ii = ii + 1
        .
      end.
      if use-column[80] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.OutExtKass-DiscntSum * 100 / gds-prop.OutExtKass-SaleSum
          ii = ii + 1
        .
        if line-frm.sum = ? then assign line-frm.sum = 0 .
      end.
      if use-column[20] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.RetOutKass-Qnty
          ii = ii + 1
        .
      end.
      if use-column[39] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.RetOutKass-CostSum
          ii = ii + 1
        .
      end.
      if use-column[56] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.RetOutKass-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[72] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.RetOutKass-DiscntSum
          ii = ii + 1
        .
      end.
      if use-column[81] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.RetOutKass-DiscntSum * 100 / gds-prop.RetOutKass-SaleSum
          ii = ii + 1
        .
        if line-frm.sum = ? then assign line-frm.sum = 0 .
      end.
      if use-column[21] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.OutExtKass-Qnty    - gds-prop.RetOutKass-Qnty
          ii = ii + 1
        .
      end.
      if use-column[40] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.OutExtKass-CostSum - gds-prop.RetOutKass-CostSum
          ii = ii + 1
        .
      end.
      if use-column[57] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.OutExtKass-SaleSum - gds-prop.RetOutKass-SaleSum - gds-prop.OutExtKass-DiscntSum + gds-prop.RetOutKass-DiscntSum
          ii = ii + 1
        .
      end.
      if use-column[73] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.OutExtKass-DiscntSum - gds-prop.RetOutKass-DiscntSum
          ii = ii + 1
        .
      end.
      if use-column[82] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = ( gds-prop.OutExtKass-DiscntSum - gds-prop.RetOutKass-DiscntSum ) * 100 / ( gds-prop.OutExtKass-SaleSum - gds-prop.RetOutKass-SaleSum )
          ii = ii + 1
        .
        if line-frm.sum = ? then assign line-frm.sum = 0 .
      end.
      if use-column[22] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.OutExt-Qnty      + gds-prop.OutExtKass-Qnty
          ii = ii + 1
        .
      end.
      if use-column[41] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.OutExt-CostSum   + gds-prop.OutExtKass-CostSum
          ii = ii + 1
        .
      end.
      if use-column[58] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.OutExt-SaleSum   + gds-prop.OutExtKass-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[74] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.OutExt-DiscntSum + gds-prop.OutExtKass-DiscntSum
          ii = ii + 1
        .
      end.
      if use-column[83] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = ( gds-prop.OutExt-DiscntSum + gds-prop.OutExtKass-DiscntSum ) * 100 / ( gds-prop.OutExt-SaleSum + gds-prop.OutExtKass-SaleSum )
          ii = ii + 1
        .
        if line-frm.sum = ? then assign line-frm.sum = 0 .
      end.
      if use-column[23] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.RetOut-Qnty      + gds-prop.RetOutKass-Qnty
          ii = ii + 1
        .
      end.
      if use-column[42] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.RetOut-CostSum   + gds-prop.RetOutKass-CostSum
          ii = ii + 1
        .
      end.
      if use-column[59] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.RetOut-SaleSum   + gds-prop.RetOutKass-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[75] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.RetOut-DiscntSum + gds-prop.RetOutKass-DiscntSum
          ii = ii + 1
        .
      end.
      if use-column[84] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = ( gds-prop.RetOut-DiscntSum + gds-prop.RetOutKass-DiscntSum  ) * 100 / ( gds-prop.RetOut-SaleSum + gds-prop.RetOutKass-SaleSum )
          ii = ii + 1
        .
        if line-frm.sum = ? then assign line-frm.sum = 0 .
      end.
      if use-column[24] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.OutExt-Qnty    - gds-prop.RetOut-Qnty + gds-prop.OutExtKass-Qnty - gds-prop.RetOutKass-Qnty
          ii = ii + 1
        .
      end.
      if use-column[43] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.OutExt-CostSum - gds-prop.RetOut-CostSum + gds-prop.OutExtKass-CostSum - gds-prop.RetOutKass-CostSum
          ii = ii + 1
        .
      end.
      if use-column[60] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.OutExt-SaleSum - gds-prop.RetOut-SaleSum + gds-prop.OutExtKass-SaleSum - gds-prop.RetOutKass-SaleSum - (gds-prop.OutExt-DiscntSum - gds-prop.RetOut-DiscntSum + gds-prop.OutExtKass-DiscntSum - gds-prop.RetOutKass-DiscntSum)
          ii = ii + 1
        .
      end.
      if use-column[76] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.OutExt-DiscntSum - gds-prop.RetOut-DiscntSum + gds-prop.OutExtKass-DiscntSum - gds-prop.RetOutKass-DiscntSum
          ii = ii + 1
        .
      end.
      if use-column[85] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = ( gds-prop.OutExt-DiscntSum - gds-prop.RetOut-DiscntSum + gds-prop.OutExtKass-DiscntSum - gds-prop.RetOutKass-DiscntSum ) * 100 / ( gds-prop.OutExt-SaleSum - gds-prop.RetOut-SaleSum + gds-prop.OutExtKass-SaleSum - gds-prop.RetOutKass-SaleSum  )
          ii = ii + 1
        .
        if line-frm.sum = ? then assign line-frm.sum = 0 .
      end.
      if use-column[25] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.Inv-Qnty
          ii = ii + 1
        .
      end.
      if use-column[44] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.Inv-CostSum
          ii = ii + 1
        .
      end.
      if use-column[61] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.Inv-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[26] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.Spi-Qnty
          ii = ii + 1
        .
      end.
      if use-column[45] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.Spi-CostSum
          ii = ii + 1
        .
      end.
      if use-column[62] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.Spi-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[27] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.InInt-Qnty
          ii = ii + 1
        .
      end.
      if use-column[46] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.InInt-CostSum
          ii = ii + 1
        .
      end.
      if use-column[63] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.InInt-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[28] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.OutInt-Qnty
          ii = ii + 1
        .
      end.
      if use-column[47] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.OutInt-CostSum
          ii = ii + 1
        .
      end.
      if use-column[64] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.OutInt-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[29] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.RetInt-Qnty
          ii = ii + 1
        .
      end.
      if use-column[48] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.RetInt-CostSum
          ii = ii + 1
        .
      end.
      if use-column[65] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.RetInt-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[30] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.InProiz-Qnty
          ii = ii + 1
        .
      end.
      if use-column[49] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.InProiz-CostSum
          ii = ii + 1
        .
      end.
      if use-column[66] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.InProiz-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[86] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.OutProiz-Qnty
          ii = ii + 1
        .
      end.
      if use-column[87] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.OutProiz-CostSum
          ii = ii + 1
        .
      end.
      if use-column[88] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.OutProiz-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[67] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.Per-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[13] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.EndWay-Qnty
          ii = ii + 1
        .
      end.
      if use-column[32] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.EndWay-CostSum
          ii = ii + 1
        .
      end.
      if use-column[51] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.EndWay-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[10] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.Effect-Value
          ii = ii + 1
        .
      end.
      if use-column[11] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.Up-Fact
          ii = ii + 1
        .
      end.
      if RADIO-AltObj > 1 then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.Alt-RestEnd-Qnty
          ii = ii + 1
        .
      end.
      if use-column[89] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.Free-Qnty
          ii = ii + 1
        .
      end.
      if use-column[90] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.Free-CostSum
          ii = ii + 1
        .
      end.
      if use-column[91] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.Free-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[92] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.Res-Qnty
          ii = ii + 1
        .
      end.
      if use-column[93] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.Res-CostSum
          ii = ii + 1
        .
      end.
      if use-column[94] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.Res-SaleSum - gds-prop.Res-DiscntSum
          ii = ii + 1
        .
      end.
      if use-column[95] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.Res-DiscntSum
          ii = ii + 1
        .
      end.
      if use-column[96] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = gds-prop.Res-DiscntSum * 100 / gds-prop.Res-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[97] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          ii = ii + 1
        .
      end.
      if use-column[98] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          ii = ii + 1
        .
      end.
      if use-column[99] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          ii = ii + 1
        .
      end.
      if use-column[100] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          ii = ii + 1
        .
      end.
      if use-column[101] = yes then do: find first line-frm where line-frm.num = ii . assign ii = ii + 1 .  end.
      if use-column[102] = yes then do: find first line-frm where line-frm.num = ii . assign ii = ii + 1 .  end.
      if use-column[103] = yes then do: find first line-frm where line-frm.num = ii . assign ii = ii + 1 .  end.
      if use-column[104] = yes then do: find first line-frm where line-frm.num = ii . assign ii = ii + 1 .  end.
      if use-column[105] = yes then do: find first line-frm where line-frm.num = ii . assign ii = ii + 1 .  end.
      if use-column[106] = yes then do: find first line-frm where line-frm.num = ii . assign ii = ii + 1 .  end.
      if use-column[107] = yes then do: find first line-frm where line-frm.num = ii . assign ii = ii + 1 .  end.
      if use-column[108] = yes then do: find first line-frm where line-frm.num = ii . assign ii = ii + 1 .  end.
      if use-column[109] = yes then do: find first line-frm where line-frm.num = ii . assign ii = ii + 1 .  end.
      if use-column[110] = yes then do: find first line-frm where line-frm.num = ii . assign ii = ii + 1 .  end.
      if use-column[111] = yes then do: find first line-frm where line-frm.num = ii . assign ii = ii + 1 .  end.
      if use-column[112] = yes then do: find first line-frm where line-frm.num = ii . assign ii = ii + 1 .  end.
      if use-column[113] = yes then do: find first line-frm where line-frm.num = ii . assign ii = ii + 1 .  end.
      if use-column[114] = yes then do: find first line-frm where line-frm.num = ii . assign ii = ii + 1 .  end.
      for each line-frm :
        if line-frm.num >= jj  then do:
          put stream outstream  "|" at line-frm.beg line-frm.sum format line-frm.frm .
          if ExportZUM then put stream txt-file UNFORMATTED  replace(string(line-frm.sum,frm-qnty1),".",",")  CHR(9) .
        end.
      end.
      put stream outstream   "|"  skip .
      if ExportZUM then put stream txt-file  chr(10) .
      if name-tov = 3 and use-column[3]  = yes then do:
        assign ii = 1  .
        if use-column[1]  = yes then do:
          find first line-frm where line-frm.num = ii .
          put stream outstream  "|" at line-frm.beg .
          assign ii = ii + 1 .
        end.
        if use-column[2]  = yes then do:
          find first line-frm where line-frm.num = ii .
          put stream outstream  "|" at line-frm.beg .
          assign ii = ii + 1 .
        end.
        find first line-frm where line-frm.num = ii .
        put stream outstream  "|" at line-frm.beg gds-prop.gds-name1 format line-frm.frm .
        assign  ii = ii + 1   .
        for each line-frm :
          if line-frm.num > ii  then  put stream outstream  "|" at line-frm.beg .
        end.
        put stream outstream   "|" at beg  skip .
      end.
    if sys-key = "parts" then do:
       run PrintParts ( gds-prop.artic, gds-prop.prod-type, gds-prop.prod-code , gds-prop.obj-type, gds-prop.obj-code )  .
    end.
  end.
end procedure.
procedure PutTitul :
  if titul = 0 and tog-obj = true then do:
    assign
      line1 = ""
      titul = 1
    .
    if available obj-list then assign  line1 = "По объекту: " + obj-list.obj-name + " (" + obj-list.obj-type + '#' + string(obj-list.obj-code) + ")" .
    run macr_excel_char (line1, v-row, 1) .
    assign v-row = v-row + 1 .
    put stream outstream   Line format frmt skip .
    PUT stream OutStream "| " line1 format "X(60)" "|" at beg  SKIP .
  end.
  if SumsOnly = no then do:
    if var-client <> "" then do:
      run macr_excel_char (var-client, v-row, 1) .
      assign v-row = v-row + 1 .
      PUT stream OutStream "| " var-client format "X(60)" "|" at beg  SKIP .
      assign  var-client = "" .
    end.
    if var-client1 <> "" then do:
      run macr_excel_char (var-client1, v-row, 1) .
      assign v-row = v-row + 1 .
      PUT stream OutStream "| " var-client1 format "X(60)" "|" at beg  SKIP .
      assign  var-client1 = "" .
    end.
  end.
end procedure.
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
      substitute('formula(&3,"r&1c&2")', p-row , p-col , format-excel-text-macr ( ss ) ) skip  .
 end.
END procedure.
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
PROCEDURE foreach1 :
  if tog-obj = true then do:
    for each obj-list no-lock :
      assign  titul = 0 .
      run Create-gds-sum in this-procedure (2) .
      if SortType = "sort-code":U then do:
        for each gds-prop
          where gds-prop.obj-type = obj-list.obj-type
            and gds-prop.obj-code = obj-list.obj-code
             by gds-prop.b-code :
          run CheckNullOborot in this-procedure .
          if NullStr < 1 then do:
              run PutTitul in this-procedure .
              run PrintLine in this-procedure .
            run CalculSum in this-procedure (2) .
            run CalculSum in this-procedure (1) .
          end.
        End.
                run PutItogSum in this-procedure (2) .
      end.
      else do:
        for each gds-prop
          where gds-prop.obj-type = obj-list.obj-type
            and gds-prop.obj-code = obj-list.obj-code
             by gds-prop.artic :
          run CheckNullOborot in this-procedure .
          if NullStr < 1 then do:
              run PutTitul in this-procedure .
              run PrintLine in this-procedure .
            run CalculSum in this-procedure (2) .
            run CalculSum in this-procedure (1) .
          end.
        End.
        run PutItogSum in this-procedure (2) .
      end.
      end.
  end.
  else do:
    if SortType = "sort-code":U then do:
      for each gds-prop
        by gds-prop.b-code :
        run CheckNullOborot in this-procedure .
        if NullStr < 1 then do:
          run PrintLine in this-procedure .
          run CalculSum in this-procedure (1) .
        end.
      End.
    end.
    else do:
      for each gds-prop
           by gds-prop.artic :
        run CheckNullOborot in this-procedure .
        if NullStr < 1 then do:
          run PrintLine in this-procedure .
          run CalculSum in this-procedure (1) .
        end.
      End.
    end.
  end.
  run PutItogSum in this-procedure (1) .
END PROCEDURE.
PROCEDURE foreach2 :
  if tog-obj = true then do:
    for each obj-list no-lock :
      assign  titul = 0 .
      run Create-gds-sum in this-procedure (2) .
      if SortType = "sort-code":U then do:
        for each gds-prop
          where gds-prop.obj-type = obj-list.obj-type
            and gds-prop.obj-code = obj-list.obj-code
          break by gds-prop.prod-name
                by gds-prop.b-code :
define variable vss-include-info33 as character format "X(65)" no-undo
initial "@(#)$Workfile$".
        if first-of(gds-prop.prod-name) then do:
          assign var-client = "Производитель " + gds-prop.prod-name .
          run Create-gds-sum in this-procedure (3) .
        End.
        run CheckNullOborot in this-procedure .
        if NullStr < 1 then do:
            run PutTitul in this-procedure .
            run PrintLine in this-procedure .
          run CalculSum in this-procedure (1) .
          if tog-obj = true then run CalculSum in this-procedure (2) .
          run CalculSum in this-procedure (3) .
        end.
        if last-of(gds-prop.prod-name) then do:
          assign
            ItogStr = "Итого по производителю " + gds-prop.prod-name + ":"
          .
          run PutItogSum in this-procedure (3) .
        End.
        End.
        run PutItogSum in this-procedure (2).
      end.
      else do:
        for each gds-prop
          where gds-prop.obj-type = obj-list.obj-type
            and gds-prop.obj-code = obj-list.obj-code
       break by gds-prop.prod-name
             by gds-prop.artic :
define variable vss-include-info34 as character format "X(65)" no-undo
initial "@(#)$Workfile$".
        if first-of(gds-prop.prod-name) then do:
          assign var-client = "Производитель " + gds-prop.prod-name .
          run Create-gds-sum in this-procedure (3) .
        End.
        run CheckNullOborot in this-procedure .
        if NullStr < 1 then do:
            run PutTitul in this-procedure .
            run PrintLine in this-procedure .
          run CalculSum in this-procedure (1) .
          if tog-obj = true then run CalculSum in this-procedure (2) .
          run CalculSum in this-procedure (3) .
        end.
        if last-of(gds-prop.prod-name) then do:
          assign
            ItogStr = "Итого по производителю " + gds-prop.prod-name + ":"
          .
          run PutItogSum in this-procedure (3) .
        End.
        End.
        run PutItogSum in this-procedure (2) .
      end.
    end.
  end.
  else do:
    if SortType = "sort-code":U then do:
      for each gds-prop
        break by gds-prop.prod-name
              by gds-prop.b-code :
define variable vss-include-info35 as character format "X(65)" no-undo
initial "@(#)$Workfile$".
        if first-of(gds-prop.prod-name) then do:
          assign var-client = "Производитель " + gds-prop.prod-name .
          run Create-gds-sum in this-procedure (3) .
        End.
        run CheckNullOborot in this-procedure .
        if NullStr < 1 then do:
            run PutTitul in this-procedure .
            run PrintLine in this-procedure .
          run CalculSum in this-procedure (1) .
          if tog-obj = true then run CalculSum in this-procedure (2) .
          run CalculSum in this-procedure (3) .
        end.
        if last-of(gds-prop.prod-name) then do:
          assign
            ItogStr = "Итого по производителю " + gds-prop.prod-name + ":"
          .
          run PutItogSum in this-procedure (3) .
        End.
      End.
    end.
    else do:
      for each gds-prop
     break by gds-prop.prod-name
           by gds-prop.artic :
define variable vss-include-info36 as character format "X(65)" no-undo
initial "@(#)$Workfile$".
        if first-of(gds-prop.prod-name) then do:
          assign var-client = "Производитель " + gds-prop.prod-name .
          run Create-gds-sum in this-procedure (3) .
        End.
        run CheckNullOborot in this-procedure .
        if NullStr < 1 then do:
            run PutTitul in this-procedure .
            run PrintLine in this-procedure .
          run CalculSum in this-procedure (1) .
          if tog-obj = true then run CalculSum in this-procedure (2) .
          run CalculSum in this-procedure (3) .
        end.
        if last-of(gds-prop.prod-name) then do:
          assign
            ItogStr = "Итого по производителю " + gds-prop.prod-name + ":"
          .
          run PutItogSum in this-procedure (3) .
        End.
      End.
    end.
  end.
  run PutItogSum in this-procedure (1) .
END PROCEDURE.
PROCEDURE foreach3 :
  if tog-obj = true then do:
    for each obj-list no-lock :
      assign
        LastGroup   = ""
        CurrGrpName = ""
        titul       = 0
      .
      run Create-gds-sum in this-procedure (2) .
      if SortType = "sort-code":U then do:
        for each gds-prop
          where gds-prop.obj-type = obj-list.obj-type
            and gds-prop.obj-code = obj-list.obj-code
          break by gds-prop.grp-name
                by gds-prop.b-code :
define variable vss-include-info37 as character format "X(65)" no-undo
initial "@(#)$Workfile$".
      if tog-tree = no then do:
        if first-of(gds-prop.grp-name) then do:
          if tog-lavel = yes then do:
            assign
              lvel = num-entries( right-trim(gds-prop.grp-name, chr(47)), chr(47) )
            .
            if var-lavel < lvel then do:
              assign CurrGrpName = "" .
              do ii = 1 to var-lavel :
                assign CurrGrpName = CurrGrpName + entry ( ii, gds-prop.grp-name, chr(47) )  + chr(47) .
              end.
              if LastGroup <> CurrGrpName then do:
                if LastGroup <> "" then do:
                  assign ItogStr = "Итого по " + LastGroup + ":"   .
                  run PutItogSum in this-procedure (3) .
                end.
                assign
                  LastGroup  = CurrGrpName
                  var-client = "Группа " + CurrGrpName
                .
                run Create-gds-sum in this-procedure (3) .
              end.
            end.
            else do:
              if LastGroup <> "" then do:
                assign ItogStr = "Итого по " + LastGroup + ":"   .
                run PutItogSum in this-procedure (3) .
              end.
              assign
                LastGroup  = gds-prop.grp-name
                var-client = "Группа " + gds-prop.grp-name
              .
              run Create-gds-sum in this-procedure (3) .
            end.
          end .
          else do:
            assign var-client = "Группа " + gds-prop.grp-name .
            run Create-gds-sum in this-procedure (3) .
          end .
        End .
        run CheckNullOborot in this-procedure .
        if NullStr < 1 then do:
            run PutTitul in this-procedure .
            run PrintLine in this-procedure .
          run CalculSum in this-procedure (1) .
          if tog-obj = true then run CalculSum in this-procedure (2) .
          run CalculSum in this-procedure (3) .
        end.
        if last-of(gds-prop.grp-name) and tog-lavel = no then do:
          assign
            ItogStr = "Итого по " + gds-prop.grp-name + ":"
          .
          run PutItogSum in this-procedure (3) .
        End.
      End.
      else do:
        if first-of(gds-prop.grp-name) then do:
          assign
            lvel = num-entries( right-trim(gds-prop.grp-name, chr(47)), chr(47) )
          .
          assign CurrGrpName = "" .
          do ind = 1 to lvel :
            assign CurrGrpName = CurrGrpName + entry ( ind, gds-prop.grp-name, chr(47) )  + chr(47) .
            find first tt-grp-tree
              where tt-grp-tree.full = CurrGrpName
            no-error .
            if not available tt-grp-tree then LEAVE.
          end.
          do ij = old-lvel to ind by -1 :
            find first tt-grp-tree
              where tt-grp-tree.num = (ij + 3) .
            assign ItogStr = "" .
            do jj = 1 to ij : assign ItogStr = ItogStr + "  " . end.
            assign ItogStr = ItogStr + tt-grp-tree.name .
            if ij <= var-lavel then do:
              run PutItogSum in this-procedure (tt-grp-tree.num) .
            end.
            delete tt-grp-tree .
          end.
          assign old-lvel = lvel .
          do ij = ind to lvel :
            create tt-grp-tree .
            if ij > ind then do:
              assign CurrGrpName = CurrGrpName + entry ( ij, gds-prop.grp-name, chr(47) )  + chr(47) .
            end.
            assign
              tt-grp-tree.num  = ij + 3
              tt-grp-tree.full = CurrGrpName
              tt-grp-tree.name = entry ( ij, gds-prop.grp-name, chr(47) )
              var-client = "Группа " + tt-grp-tree.name
            .
            run Create-gds-sum in this-procedure (tt-grp-tree.num) .
          end.
        end.
        run CheckNullOborot in this-procedure .
        if NullStr < 1 then do:
            run PutTitul in this-procedure .
            run PrintLine in this-procedure .
          run CalculSum in this-procedure (1) .
          if tog-obj = true then run CalculSum in this-procedure (2) .
          for each tt-grp-tree :
            run CalculSum in this-procedure (tt-grp-tree.num) .
          end.
        end.
      End.
        End.
      end.
      else do:
        for each gds-prop
          where gds-prop.obj-type = obj-list.obj-type
            and gds-prop.obj-code = obj-list.obj-code
          break by gds-prop.grp-name
                by gds-prop.artic :
define variable vss-include-info38 as character format "X(65)" no-undo
initial "@(#)$Workfile$".
      if tog-tree = no then do:
        if first-of(gds-prop.grp-name) then do:
          if tog-lavel = yes then do:
            assign
              lvel = num-entries( right-trim(gds-prop.grp-name, chr(47)), chr(47) )
            .
            if var-lavel < lvel then do:
              assign CurrGrpName = "" .
              do ii = 1 to var-lavel :
                assign CurrGrpName = CurrGrpName + entry ( ii, gds-prop.grp-name, chr(47) )  + chr(47) .
              end.
              if LastGroup <> CurrGrpName then do:
                if LastGroup <> "" then do:
                  assign ItogStr = "Итого по " + LastGroup + ":"   .
                  run PutItogSum in this-procedure (3) .
                end.
                assign
                  LastGroup  = CurrGrpName
                  var-client = "Группа " + CurrGrpName
                .
                run Create-gds-sum in this-procedure (3) .
              end.
            end.
            else do:
              if LastGroup <> "" then do:
                assign ItogStr = "Итого по " + LastGroup + ":"   .
                run PutItogSum in this-procedure (3) .
              end.
              assign
                LastGroup  = gds-prop.grp-name
                var-client = "Группа " + gds-prop.grp-name
              .
              run Create-gds-sum in this-procedure (3) .
            end.
          end .
          else do:
            assign var-client = "Группа " + gds-prop.grp-name .
            run Create-gds-sum in this-procedure (3) .
          end .
        End .
        run CheckNullOborot in this-procedure .
        if NullStr < 1 then do:
            run PutTitul in this-procedure .
            run PrintLine in this-procedure .
          run CalculSum in this-procedure (1) .
          if tog-obj = true then run CalculSum in this-procedure (2) .
          run CalculSum in this-procedure (3) .
        end.
        if last-of(gds-prop.grp-name) and tog-lavel = no then do:
          assign
            ItogStr = "Итого по " + gds-prop.grp-name + ":"
          .
          run PutItogSum in this-procedure (3) .
        End.
      End.
      else do:
        if first-of(gds-prop.grp-name) then do:
          assign
            lvel = num-entries( right-trim(gds-prop.grp-name, chr(47)), chr(47) )
          .
          assign CurrGrpName = "" .
          do ind = 1 to lvel :
            assign CurrGrpName = CurrGrpName + entry ( ind, gds-prop.grp-name, chr(47) )  + chr(47) .
            find first tt-grp-tree
              where tt-grp-tree.full = CurrGrpName
            no-error .
            if not available tt-grp-tree then LEAVE.
          end.
          do ij = old-lvel to ind by -1 :
            find first tt-grp-tree
              where tt-grp-tree.num = (ij + 3) .
            assign ItogStr = "" .
            do jj = 1 to ij : assign ItogStr = ItogStr + "  " . end.
            assign ItogStr = ItogStr + tt-grp-tree.name .
            if ij <= var-lavel then do:
              run PutItogSum in this-procedure (tt-grp-tree.num) .
            end.
            delete tt-grp-tree .
          end.
          assign old-lvel = lvel .
          do ij = ind to lvel :
            create tt-grp-tree .
            if ij > ind then do:
              assign CurrGrpName = CurrGrpName + entry ( ij, gds-prop.grp-name, chr(47) )  + chr(47) .
            end.
            assign
              tt-grp-tree.num  = ij + 3
              tt-grp-tree.full = CurrGrpName
              tt-grp-tree.name = entry ( ij, gds-prop.grp-name, chr(47) )
              var-client = "Группа " + tt-grp-tree.name
            .
            run Create-gds-sum in this-procedure (tt-grp-tree.num) .
          end.
        end.
        run CheckNullOborot in this-procedure .
        if NullStr < 1 then do:
            run PutTitul in this-procedure .
            run PrintLine in this-procedure .
          run CalculSum in this-procedure (1) .
          if tog-obj = true then run CalculSum in this-procedure (2) .
          for each tt-grp-tree :
            run CalculSum in this-procedure (tt-grp-tree.num) .
          end.
        end.
      End.
        End.
      end.
      if tog-lavel = yes then do:
        if tog-tree = yes then do:
          do ij = old-lvel to ind by -1 :
            find first tt-grp-tree
              where tt-grp-tree.num = (ij + 3) .
            assign ItogStr = "" .
            do jj = 1 to ij : assign ItogStr = ItogStr + "  " . end.
            assign ItogStr = ItogStr + tt-grp-tree.name .
            if ij <= var-lavel then do:
              run PutItogSum in this-procedure (tt-grp-tree.num) .
            end.
            delete tt-grp-tree .
          end.
          assign
            old-lvel = 0
          .
        end.
        else do:
          if LastGroup <> "" then do:
            assign ItogStr = "Итого по " + LastGroup + ":"   .
            run PutItogSum in this-procedure (3) .
          end.
        end.
      end.
      run PutItogSum in this-procedure (2) .
    end.
  end.
  else do:
    assign
      LastGroup   = ""
      CurrGrpName = ""
      titul       = 0
    .
    if SortType = "sort-code":U then do:
      for each gds-prop
        break by gds-prop.grp-name
              by gds-prop.b-code :
define variable vss-include-info39 as character format "X(65)" no-undo
initial "@(#)$Workfile$".
      if tog-tree = no then do:
        if first-of(gds-prop.grp-name) then do:
          if tog-lavel = yes then do:
            assign
              lvel = num-entries( right-trim(gds-prop.grp-name, chr(47)), chr(47) )
            .
            if var-lavel < lvel then do:
              assign CurrGrpName = "" .
              do ii = 1 to var-lavel :
                assign CurrGrpName = CurrGrpName + entry ( ii, gds-prop.grp-name, chr(47) )  + chr(47) .
              end.
              if LastGroup <> CurrGrpName then do:
                if LastGroup <> "" then do:
                  assign ItogStr = "Итого по " + LastGroup + ":"   .
                  run PutItogSum in this-procedure (3) .
                end.
                assign
                  LastGroup  = CurrGrpName
                  var-client = "Группа " + CurrGrpName
                .
                run Create-gds-sum in this-procedure (3) .
              end.
            end.
            else do:
              if LastGroup <> "" then do:
                assign ItogStr = "Итого по " + LastGroup + ":"   .
                run PutItogSum in this-procedure (3) .
              end.
              assign
                LastGroup  = gds-prop.grp-name
                var-client = "Группа " + gds-prop.grp-name
              .
              run Create-gds-sum in this-procedure (3) .
            end.
          end .
          else do:
            assign var-client = "Группа " + gds-prop.grp-name .
            run Create-gds-sum in this-procedure (3) .
          end .
        End .
        run CheckNullOborot in this-procedure .
        if NullStr < 1 then do:
            run PutTitul in this-procedure .
            run PrintLine in this-procedure .
          run CalculSum in this-procedure (1) .
          if tog-obj = true then run CalculSum in this-procedure (2) .
          run CalculSum in this-procedure (3) .
        end.
        if last-of(gds-prop.grp-name) and tog-lavel = no then do:
          assign
            ItogStr = "Итого по " + gds-prop.grp-name + ":"
          .
          run PutItogSum in this-procedure (3) .
        End.
      End.
      else do:
        if first-of(gds-prop.grp-name) then do:
          assign
            lvel = num-entries( right-trim(gds-prop.grp-name, chr(47)), chr(47) )
          .
          assign CurrGrpName = "" .
          do ind = 1 to lvel :
            assign CurrGrpName = CurrGrpName + entry ( ind, gds-prop.grp-name, chr(47) )  + chr(47) .
            find first tt-grp-tree
              where tt-grp-tree.full = CurrGrpName
            no-error .
            if not available tt-grp-tree then LEAVE.
          end.
          do ij = old-lvel to ind by -1 :
            find first tt-grp-tree
              where tt-grp-tree.num = (ij + 3) .
            assign ItogStr = "" .
            do jj = 1 to ij : assign ItogStr = ItogStr + "  " . end.
            assign ItogStr = ItogStr + tt-grp-tree.name .
            if ij <= var-lavel then do:
              run PutItogSum in this-procedure (tt-grp-tree.num) .
            end.
            delete tt-grp-tree .
          end.
          assign old-lvel = lvel .
          do ij = ind to lvel :
            create tt-grp-tree .
            if ij > ind then do:
              assign CurrGrpName = CurrGrpName + entry ( ij, gds-prop.grp-name, chr(47) )  + chr(47) .
            end.
            assign
              tt-grp-tree.num  = ij + 3
              tt-grp-tree.full = CurrGrpName
              tt-grp-tree.name = entry ( ij, gds-prop.grp-name, chr(47) )
              var-client = "Группа " + tt-grp-tree.name
            .
            run Create-gds-sum in this-procedure (tt-grp-tree.num) .
          end.
        end.
        run CheckNullOborot in this-procedure .
        if NullStr < 1 then do:
            run PutTitul in this-procedure .
            run PrintLine in this-procedure .
          run CalculSum in this-procedure (1) .
          if tog-obj = true then run CalculSum in this-procedure (2) .
          for each tt-grp-tree :
            run CalculSum in this-procedure (tt-grp-tree.num) .
          end.
        end.
      End.
      End.
    end.
    else do:
      for each gds-prop
        break by gds-prop.grp-name
              by gds-prop.artic :
define variable vss-include-info40 as character format "X(65)" no-undo
initial "@(#)$Workfile$".
      if tog-tree = no then do:
        if first-of(gds-prop.grp-name) then do:
          if tog-lavel = yes then do:
            assign
              lvel = num-entries( right-trim(gds-prop.grp-name, chr(47)), chr(47) )
            .
            if var-lavel < lvel then do:
              assign CurrGrpName = "" .
              do ii = 1 to var-lavel :
                assign CurrGrpName = CurrGrpName + entry ( ii, gds-prop.grp-name, chr(47) )  + chr(47) .
              end.
              if LastGroup <> CurrGrpName then do:
                if LastGroup <> "" then do:
                  assign ItogStr = "Итого по " + LastGroup + ":"   .
                  run PutItogSum in this-procedure (3) .
                end.
                assign
                  LastGroup  = CurrGrpName
                  var-client = "Группа " + CurrGrpName
                .
                run Create-gds-sum in this-procedure (3) .
              end.
            end.
            else do:
              if LastGroup <> "" then do:
                assign ItogStr = "Итого по " + LastGroup + ":"   .
                run PutItogSum in this-procedure (3) .
              end.
              assign
                LastGroup  = gds-prop.grp-name
                var-client = "Группа " + gds-prop.grp-name
              .
              run Create-gds-sum in this-procedure (3) .
            end.
          end .
          else do:
            assign var-client = "Группа " + gds-prop.grp-name .
            run Create-gds-sum in this-procedure (3) .
          end .
        End .
        run CheckNullOborot in this-procedure .
        if NullStr < 1 then do:
            run PutTitul in this-procedure .
            run PrintLine in this-procedure .
          run CalculSum in this-procedure (1) .
          if tog-obj = true then run CalculSum in this-procedure (2) .
          run CalculSum in this-procedure (3) .
        end.
        if last-of(gds-prop.grp-name) and tog-lavel = no then do:
          assign
            ItogStr = "Итого по " + gds-prop.grp-name + ":"
          .
          run PutItogSum in this-procedure (3) .
        End.
      End.
      else do:
        if first-of(gds-prop.grp-name) then do:
          assign
            lvel = num-entries( right-trim(gds-prop.grp-name, chr(47)), chr(47) )
          .
          assign CurrGrpName = "" .
          do ind = 1 to lvel :
            assign CurrGrpName = CurrGrpName + entry ( ind, gds-prop.grp-name, chr(47) )  + chr(47) .
            find first tt-grp-tree
              where tt-grp-tree.full = CurrGrpName
            no-error .
            if not available tt-grp-tree then LEAVE.
          end.
          do ij = old-lvel to ind by -1 :
            find first tt-grp-tree
              where tt-grp-tree.num = (ij + 3) .
            assign ItogStr = "" .
            do jj = 1 to ij : assign ItogStr = ItogStr + "  " . end.
            assign ItogStr = ItogStr + tt-grp-tree.name .
            if ij <= var-lavel then do:
              run PutItogSum in this-procedure (tt-grp-tree.num) .
            end.
            delete tt-grp-tree .
          end.
          assign old-lvel = lvel .
          do ij = ind to lvel :
            create tt-grp-tree .
            if ij > ind then do:
              assign CurrGrpName = CurrGrpName + entry ( ij, gds-prop.grp-name, chr(47) )  + chr(47) .
            end.
            assign
              tt-grp-tree.num  = ij + 3
              tt-grp-tree.full = CurrGrpName
              tt-grp-tree.name = entry ( ij, gds-prop.grp-name, chr(47) )
              var-client = "Группа " + tt-grp-tree.name
            .
            run Create-gds-sum in this-procedure (tt-grp-tree.num) .
          end.
        end.
        run CheckNullOborot in this-procedure .
        if NullStr < 1 then do:
            run PutTitul in this-procedure .
            run PrintLine in this-procedure .
          run CalculSum in this-procedure (1) .
          if tog-obj = true then run CalculSum in this-procedure (2) .
          for each tt-grp-tree :
            run CalculSum in this-procedure (tt-grp-tree.num) .
          end.
        end.
      End.
      End.
    end.
    if tog-lavel = yes then do:
      if tog-tree = yes then do:
          do ij = old-lvel to ind by -1 :
            find first tt-grp-tree
              where tt-grp-tree.num = (ij + 3) .
            assign ItogStr = "" .
            do jj = 1 to ij : assign ItogStr = ItogStr + "  " . end.
            assign ItogStr = ItogStr + tt-grp-tree.name .
            if ij <= var-lavel then do:
              run PutItogSum in this-procedure (tt-grp-tree.num) .
            end.
            delete tt-grp-tree .
          end.
      end.
      else do:
        if LastGroup <> "" then do:
          assign ItogStr = "Итого по " + LastGroup + ":"   .
          run PutItogSum in this-procedure (3) .
        end.
      end.
    end.
  end.
  run PutItogSum in this-procedure (1) .
END PROCEDURE.
PROCEDURE foreach4 :
  if tog-obj = true then do:
    for each obj-list no-lock :
      assign  titul = 0 .
      run Create-gds-sum in this-procedure (2) .
      if SortType = "sort-code":U then do:
        for each gds-prop
          where gds-prop.obj-type = obj-list.obj-type
            and gds-prop.obj-code = obj-list.obj-code
          break by gds-prop.prod-name
                by gds-prop.grp-code
                by gds-prop.b-code :
define variable vss-include-info41 as character format "X(65)" no-undo
initial "@(#)$Workfile$".
        if first-of(gds-prop.prod-name) then do:
          assign var-client = "Производитель " + gds-prop.prod-name .
          run Create-gds-sum in this-procedure (3) .
        End.
        if first-of(gds-prop.grp-code) then do:
          assign var-client1 = "Группа " + gds-prop.grp-name .
          run Create-gds-sum in this-procedure (4) .
        End.
        run CheckNullOborot in this-procedure .
        if NullStr < 1 then do:
            run PutTitul in this-procedure .
            run PrintLine in this-procedure .
          run CalculSum in this-procedure (1) .
          if tog-obj = true then run CalculSum in this-procedure (2) .
          run CalculSum in this-procedure (3) .
          run CalculSum in this-procedure (4) .
        end.
        if last-of(gds-prop.grp-code) then do:
          assign
            ItogStr = "Итого по группе " + gds-prop.grp-name + ":"
          .
          run PutItogSum in this-procedure (4) .
        End.
        if last-of(gds-prop.prod-name) then do:
          assign
            ItogStr = "Итого по производителю " + gds-prop.prod-name + ":"
          .
          run PutItogSum in this-procedure (3) .
        End.
        End.
        run PutItogSum in this-procedure (2) .
      end.
      else do:
        for each gds-prop
          where gds-prop.obj-type = obj-list.obj-type
            and gds-prop.obj-code = obj-list.obj-code
          break by gds-prop.prod-name
                by gds-prop.grp-code
                by gds-prop.artic :
define variable vss-include-info42 as character format "X(65)" no-undo
initial "@(#)$Workfile$".
        if first-of(gds-prop.prod-name) then do:
          assign var-client = "Производитель " + gds-prop.prod-name .
          run Create-gds-sum in this-procedure (3) .
        End.
        if first-of(gds-prop.grp-code) then do:
          assign var-client1 = "Группа " + gds-prop.grp-name .
          run Create-gds-sum in this-procedure (4) .
        End.
        run CheckNullOborot in this-procedure .
        if NullStr < 1 then do:
            run PutTitul in this-procedure .
            run PrintLine in this-procedure .
          run CalculSum in this-procedure (1) .
          if tog-obj = true then run CalculSum in this-procedure (2) .
          run CalculSum in this-procedure (3) .
          run CalculSum in this-procedure (4) .
        end.
        if last-of(gds-prop.grp-code) then do:
          assign
            ItogStr = "Итого по группе " + gds-prop.grp-name + ":"
          .
          run PutItogSum in this-procedure (4) .
        End.
        if last-of(gds-prop.prod-name) then do:
          assign
            ItogStr = "Итого по производителю " + gds-prop.prod-name + ":"
          .
          run PutItogSum in this-procedure (3) .
        End.
        End.
        run PutItogSum in this-procedure (2) .
      end.
    end.
  end.
  else do:
    if SortType = "sort-code":U then do:
      for each gds-prop
        break by gds-prop.prod-name
              by gds-prop.grp-code
              by gds-prop.b-code :
define variable vss-include-info43 as character format "X(65)" no-undo
initial "@(#)$Workfile$".
        if first-of(gds-prop.prod-name) then do:
          assign var-client = "Производитель " + gds-prop.prod-name .
          run Create-gds-sum in this-procedure (3) .
        End.
        if first-of(gds-prop.grp-code) then do:
          assign var-client1 = "Группа " + gds-prop.grp-name .
          run Create-gds-sum in this-procedure (4) .
        End.
        run CheckNullOborot in this-procedure .
        if NullStr < 1 then do:
            run PutTitul in this-procedure .
            run PrintLine in this-procedure .
          run CalculSum in this-procedure (1) .
          if tog-obj = true then run CalculSum in this-procedure (2) .
          run CalculSum in this-procedure (3) .
          run CalculSum in this-procedure (4) .
        end.
        if last-of(gds-prop.grp-code) then do:
          assign
            ItogStr = "Итого по группе " + gds-prop.grp-name + ":"
          .
          run PutItogSum in this-procedure (4) .
        End.
        if last-of(gds-prop.prod-name) then do:
          assign
            ItogStr = "Итого по производителю " + gds-prop.prod-name + ":"
          .
          run PutItogSum in this-procedure (3) .
        End.
      End.
    end.
    else do:
      for each gds-prop
        break by gds-prop.prod-name
              by gds-prop.grp-code
              by gds-prop.artic :
define variable vss-include-info44 as character format "X(65)" no-undo
initial "@(#)$Workfile$".
        if first-of(gds-prop.prod-name) then do:
          assign var-client = "Производитель " + gds-prop.prod-name .
          run Create-gds-sum in this-procedure (3) .
        End.
        if first-of(gds-prop.grp-code) then do:
          assign var-client1 = "Группа " + gds-prop.grp-name .
          run Create-gds-sum in this-procedure (4) .
        End.
        run CheckNullOborot in this-procedure .
        if NullStr < 1 then do:
            run PutTitul in this-procedure .
            run PrintLine in this-procedure .
          run CalculSum in this-procedure (1) .
          if tog-obj = true then run CalculSum in this-procedure (2) .
          run CalculSum in this-procedure (3) .
          run CalculSum in this-procedure (4) .
        end.
        if last-of(gds-prop.grp-code) then do:
          assign
            ItogStr = "Итого по группе " + gds-prop.grp-name + ":"
          .
          run PutItogSum in this-procedure (4) .
        End.
        if last-of(gds-prop.prod-name) then do:
          assign
            ItogStr = "Итого по производителю " + gds-prop.prod-name + ":"
          .
          run PutItogSum in this-procedure (3) .
        End.
      End.
    end.
  end.
  run PutItogSum in this-procedure (1) .
END PROCEDURE.
PROCEDURE foreach5 :
  if tog-obj = true then do:
    for each obj-list no-lock :
      assign  titul = 0 .
      run Create-gds-sum in this-procedure (2) .
      if SortType = "sort-code":U then do:
        for each gds-prop
          where gds-prop.obj-type = obj-list.obj-type
            and gds-prop.obj-code = obj-list.obj-code
          break by gds-prop.grp-code
                by gds-prop.prod-name
                by gds-prop.b-code :
define variable vss-include-info45 as character format "X(65)" no-undo
initial "@(#)$Workfile$".
        if first-of(gds-prop.grp-code) then do:
          assign var-client = "Группа " + gds-prop.grp-name .
          run Create-gds-sum in this-procedure (3) .
        End.
        if first-of(gds-prop.prod-name) then do:
          assign var-client1 = "Производитель " + gds-prop.prod-name .
          run Create-gds-sum in this-procedure (4) .
        End.
        run CheckNullOborot in this-procedure .
        if NullStr < 1 then do:
            run PutTitul in this-procedure .
            run PrintLine in this-procedure .
          run CalculSum in this-procedure (1) .
          if tog-obj = true then run CalculSum in this-procedure (2) .
          run CalculSum in this-procedure (3) .
          run CalculSum in this-procedure (4) .
        end.
        if last-of(gds-prop.prod-name) then do:
          assign
            ItogStr = "Итого по производителю " + gds-prop.prod-name + ":"
          .
          run PutItogSum in this-procedure (4) .
        End.
        if last-of(gds-prop.grp-code) then do:
          assign
            ItogStr = "Итого по группе " + gds-prop.grp-name + ":"
          .
          run PutItogSum in this-procedure (3) .
        End.
        End.
        run PutItogSum in this-procedure (2) .
      end.
      else do:
        for each gds-prop
          where gds-prop.obj-type = obj-list.obj-type
            and gds-prop.obj-code = obj-list.obj-code
          break by gds-prop.grp-code
                by gds-prop.prod-name
                by gds-prop.artic :
define variable vss-include-info46 as character format "X(65)" no-undo
initial "@(#)$Workfile$".
        if first-of(gds-prop.grp-code) then do:
          assign var-client = "Группа " + gds-prop.grp-name .
          run Create-gds-sum in this-procedure (3) .
        End.
        if first-of(gds-prop.prod-name) then do:
          assign var-client1 = "Производитель " + gds-prop.prod-name .
          run Create-gds-sum in this-procedure (4) .
        End.
        run CheckNullOborot in this-procedure .
        if NullStr < 1 then do:
            run PutTitul in this-procedure .
            run PrintLine in this-procedure .
          run CalculSum in this-procedure (1) .
          if tog-obj = true then run CalculSum in this-procedure (2) .
          run CalculSum in this-procedure (3) .
          run CalculSum in this-procedure (4) .
        end.
        if last-of(gds-prop.prod-name) then do:
          assign
            ItogStr = "Итого по производителю " + gds-prop.prod-name + ":"
          .
          run PutItogSum in this-procedure (4) .
        End.
        if last-of(gds-prop.grp-code) then do:
          assign
            ItogStr = "Итого по группе " + gds-prop.grp-name + ":"
          .
          run PutItogSum in this-procedure (3) .
        End.
        End.
        run PutItogSum in this-procedure (2) .
      end.
    end.
  end.
  else do:
    if SortType = "sort-code":U then do:
      for each gds-prop
        break by gds-prop.grp-code
              by gds-prop.prod-name
              by gds-prop.b-code :
define variable vss-include-info47 as character format "X(65)" no-undo
initial "@(#)$Workfile$".
        if first-of(gds-prop.grp-code) then do:
          assign var-client = "Группа " + gds-prop.grp-name .
          run Create-gds-sum in this-procedure (3) .
        End.
        if first-of(gds-prop.prod-name) then do:
          assign var-client1 = "Производитель " + gds-prop.prod-name .
          run Create-gds-sum in this-procedure (4) .
        End.
        run CheckNullOborot in this-procedure .
        if NullStr < 1 then do:
            run PutTitul in this-procedure .
            run PrintLine in this-procedure .
          run CalculSum in this-procedure (1) .
          if tog-obj = true then run CalculSum in this-procedure (2) .
          run CalculSum in this-procedure (3) .
          run CalculSum in this-procedure (4) .
        end.
        if last-of(gds-prop.prod-name) then do:
          assign
            ItogStr = "Итого по производителю " + gds-prop.prod-name + ":"
          .
          run PutItogSum in this-procedure (4) .
        End.
        if last-of(gds-prop.grp-code) then do:
          assign
            ItogStr = "Итого по группе " + gds-prop.grp-name + ":"
          .
          run PutItogSum in this-procedure (3) .
        End.
      End.
    end.
    else do:
      for each gds-prop
        break by gds-prop.grp-code
              by gds-prop.prod-name
              by gds-prop.artic :
define variable vss-include-info48 as character format "X(65)" no-undo
initial "@(#)$Workfile$".
        if first-of(gds-prop.grp-code) then do:
          assign var-client = "Группа " + gds-prop.grp-name .
          run Create-gds-sum in this-procedure (3) .
        End.
        if first-of(gds-prop.prod-name) then do:
          assign var-client1 = "Производитель " + gds-prop.prod-name .
          run Create-gds-sum in this-procedure (4) .
        End.
        run CheckNullOborot in this-procedure .
        if NullStr < 1 then do:
            run PutTitul in this-procedure .
            run PrintLine in this-procedure .
          run CalculSum in this-procedure (1) .
          if tog-obj = true then run CalculSum in this-procedure (2) .
          run CalculSum in this-procedure (3) .
          run CalculSum in this-procedure (4) .
        end.
        if last-of(gds-prop.prod-name) then do:
          assign
            ItogStr = "Итого по производителю " + gds-prop.prod-name + ":"
          .
          run PutItogSum in this-procedure (4) .
        End.
        if last-of(gds-prop.grp-code) then do:
          assign
            ItogStr = "Итого по группе " + gds-prop.grp-name + ":"
          .
          run PutItogSum in this-procedure (3) .
        End.
      End.
    end.
  end.
  run PutItogSum in this-procedure (1) .
END PROCEDURE.
PROCEDURE foreach6 :
  if tog-obj = true then do:
    for each obj-list no-lock :
      assign  titul = 0 .
      run Create-gds-sum in this-procedure (2) .
      if SortType = "sort-code":U then do:
        for each gds-prop
          where gds-prop.obj-type = obj-list.obj-type
            and gds-prop.obj-code = obj-list.obj-code
          break by gds-prop.vat-pc
                by gds-prop.b-code :
define variable vss-include-info49 as character format "X(65)" no-undo
initial "@(#)$Workfile$".
        if first-of(gds-prop.vat-pc) then do:
          assign var-client = "Ставка НДС: " +  String(gds-prop.vat-pc) + " %" .
          run Create-gds-sum in this-procedure (3) .
        End.
        run CheckNullOborot in this-procedure .
        if NullStr < 1 then do:
            run PutTitul in this-procedure .
            run PrintLine in this-procedure .
          run CalculSum in this-procedure (1) .
          if tog-obj = true then run CalculSum in this-procedure (2) .
          run CalculSum in this-procedure (3) .
        end.
        if last-of(gds-prop.vat-pc) then do:
          assign
            ItogStr = "Итого по ставке НДС " + String(gds-prop.vat-pc) + " % :"
          .
          run PutItogSum in this-procedure (3) .
        End.
        End.
        run PutItogSum in this-procedure (2).
      end.
      else do:
        for each gds-prop
          where gds-prop.obj-type = obj-list.obj-type
            and gds-prop.obj-code = obj-list.obj-code
          break by gds-prop.vat-pc
                by gds-prop.artic :
define variable vss-include-info50 as character format "X(65)" no-undo
initial "@(#)$Workfile$".
        if first-of(gds-prop.vat-pc) then do:
          assign var-client = "Ставка НДС: " +  String(gds-prop.vat-pc) + " %" .
          run Create-gds-sum in this-procedure (3) .
        End.
        run CheckNullOborot in this-procedure .
        if NullStr < 1 then do:
            run PutTitul in this-procedure .
            run PrintLine in this-procedure .
          run CalculSum in this-procedure (1) .
          if tog-obj = true then run CalculSum in this-procedure (2) .
          run CalculSum in this-procedure (3) .
        end.
        if last-of(gds-prop.vat-pc) then do:
          assign
            ItogStr = "Итого по ставке НДС " + String(gds-prop.vat-pc) + " % :"
          .
          run PutItogSum in this-procedure (3) .
        End.
        End.
        run PutItogSum in this-procedure (2) .
      end.
    end.
  end.
  else do:
    if SortType = "sort-code":U then do:
      for each gds-prop
        break by gds-prop.vat-pc
              by gds-prop.b-code :
define variable vss-include-info51 as character format "X(65)" no-undo
initial "@(#)$Workfile$".
        if first-of(gds-prop.vat-pc) then do:
          assign var-client = "Ставка НДС: " +  String(gds-prop.vat-pc) + " %" .
          run Create-gds-sum in this-procedure (3) .
        End.
        run CheckNullOborot in this-procedure .
        if NullStr < 1 then do:
            run PutTitul in this-procedure .
            run PrintLine in this-procedure .
          run CalculSum in this-procedure (1) .
          if tog-obj = true then run CalculSum in this-procedure (2) .
          run CalculSum in this-procedure (3) .
        end.
        if last-of(gds-prop.vat-pc) then do:
          assign
            ItogStr = "Итого по ставке НДС " + String(gds-prop.vat-pc) + " % :"
          .
          run PutItogSum in this-procedure (3) .
        End.
      End.
    end.
    else do:
      for each gds-prop
        break by gds-prop.vat-pc
              by gds-prop.artic :
define variable vss-include-info52 as character format "X(65)" no-undo
initial "@(#)$Workfile$".
        if first-of(gds-prop.vat-pc) then do:
          assign var-client = "Ставка НДС: " +  String(gds-prop.vat-pc) + " %" .
          run Create-gds-sum in this-procedure (3) .
        End.
        run CheckNullOborot in this-procedure .
        if NullStr < 1 then do:
            run PutTitul in this-procedure .
            run PrintLine in this-procedure .
          run CalculSum in this-procedure (1) .
          if tog-obj = true then run CalculSum in this-procedure (2) .
          run CalculSum in this-procedure (3) .
        end.
        if last-of(gds-prop.vat-pc) then do:
          assign
            ItogStr = "Итого по ставке НДС " + String(gds-prop.vat-pc) + " % :"
          .
          run PutItogSum in this-procedure (3) .
        End.
      End.
    end.
  end.
  run PutItogSum in this-procedure (1) .
END PROCEDURE.
procedure PrintParts :
define input  parameter p-artic     as character no-undo .
define input  parameter p-prod-type as character no-undo .
define input  parameter p-prod-code as integer   no-undo .
define input  parameter p-obj-type  as character no-undo .
define input  parameter p-obj-code  as integer   no-undo .
  do
  on error undo, return error return-value
  :
  for each o_temp-parts where
           o_temp-parts.artic     = p-artic        and
           o_temp-parts.prod-type = p-prod-type    and
           o_temp-parts.prod-code = p-prod-code    and
           o_temp-parts.obj-type  = p-obj-type     and
           o_temp-parts.obj-code  = p-obj-code      by o_temp-parts.fact-date by  o_temp-parts.b-code :
define variable vss-include-info53 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
      assign v-col = 1 .
      if use-column[1]  = yes then do: run macr_excel_char ( string ( o_temp-parts.b-code ) , v-row, v-col) . assign v-col = v-col + 1 . end.
      if use-column[2]  = yes then do: run macr_excel_char ( o_temp-parts.part-code  , v-row, v-col) . assign v-col = v-col + 1 . end.
      if use-column[3]  = yes then do: run macr_excel_char ( o_temp-parts.gds-name, v-row, v-col) . assign v-col = v-col + 1 . end.
      if use-column[4]  = yes then do: run macr_excel_char ( o_temp-parts.unit-base, v-row, v-col) . assign v-col = v-col + 1 . end.
      if use-column[5]  = yes then do: run macr_excel_sum  ( o_temp-parts.Cost-Price, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[6]  = yes then do:
        if prod-zen = yes then do:
          run macr_excel_sum  ( o_temp-parts.Avrg-Sale-Price, v-row, v-col, 2) .
        end.
        else do:
          run macr_excel_sum  ( o_temp-parts.Last-Sale-Price, v-row, v-col, 2) .
        end.
        assign v-col = v-col + 1 .
      end.
      if use-column[7]  = yes then do: run macr_excel_sum  ( o_temp-parts.Up-Plan, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[8]  = yes then do:
        if o_temp-parts.LastPer-Date <> ? then do: run macr_excel_char (string(o_temp-parts.LastPer-Date,"99.99.9999"), v-row, v-col) .  end.
        assign v-col = v-col + 1 .
      end.
      if use-column[9]  = yes then do: run macr_excel_char (o_temp-parts.LastPer-Num, v-row, v-col) . assign v-col = v-col + 1 . end.
      if use-column[12] = yes then  do: run macr_excel_sum ( o_temp-parts.StartWay-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[31] = yes then  do: run macr_excel_sum ( o_temp-parts.StartWay-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[50] = yes then  do: run macr_excel_sum ( o_temp-parts.StartWay-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[14] = yes then  do: run macr_excel_sum ( o_temp-parts.InExt-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[33] = yes then  do: run macr_excel_sum ( o_temp-parts.InExt-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[15] = yes then  do: run macr_excel_sum ( o_temp-parts.RetPost-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[34] = yes then  do: run macr_excel_sum ( o_temp-parts.RetPost-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[16] = yes then  do: run macr_excel_sum ( o_temp-parts.OutExt-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[35] = yes then  do: run macr_excel_sum ( o_temp-parts.OutExt-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[52] = yes then  do: run macr_excel_sum ( o_temp-parts.OutExt-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[68] = yes then  do: run macr_excel_sum ( o_temp-parts.OutExt-DiscntSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[77] = yes then  do: run macr_excel_sum ( o_temp-parts.OutExt-DiscntSum * 100 / o_temp-parts.OutExt-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[17] = yes then  do: run macr_excel_sum ( o_temp-parts.RetOut-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[36] = yes then  do: run macr_excel_sum ( o_temp-parts.RetOut-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[53] = yes then  do: run macr_excel_sum ( o_temp-parts.RetOut-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[69] = yes then  do: run macr_excel_sum ( o_temp-parts.RetOut-DiscntSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[78] = yes then  do: run macr_excel_sum ( o_temp-parts.RetOut-DiscntSum * 100 / o_temp-parts.RetOut-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[18] = yes then  do: run macr_excel_sum ( o_temp-parts.OutExt-Qnty    - o_temp-parts.RetOut-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[37] = yes then  do: run macr_excel_sum ( o_temp-parts.OutExt-CostSum - o_temp-parts.RetOut-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[54] = yes then  do: run macr_excel_sum ( o_temp-parts.OutExt-SaleSum - o_temp-parts.RetOut-SaleSum - o_temp-parts.OutExt-DiscntSum + o_temp-parts.RetOut-DiscntSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[70] = yes then  do: run macr_excel_sum ( o_temp-parts.OutExt-DiscntSum - o_temp-parts.RetOut-DiscntSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[79] = yes then  do: run macr_excel_sum ( ( o_temp-parts.OutExt-DiscntSum - o_temp-parts.RetOut-DiscntSum ) * 100 / ( o_temp-parts.OutExt-SaleSum - o_temp-parts.RetOut-SaleSum ), v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[19] = yes then  do: run macr_excel_sum ( o_temp-parts.OutExtKass-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[38] = yes then  do: run macr_excel_sum ( o_temp-parts.OutExtKass-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[55] = yes then  do: run macr_excel_sum ( o_temp-parts.OutExtKass-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[71] = yes then  do: run macr_excel_sum ( o_temp-parts.OutExtKass-DiscntSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[80] = yes then  do: run macr_excel_sum ( o_temp-parts.OutExtKass-DiscntSum * 100 / o_temp-parts.OutExtKass-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[20] = yes then  do: run macr_excel_sum ( o_temp-parts.RetOutKass-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[39] = yes then  do: run macr_excel_sum ( o_temp-parts.RetOutKass-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[56] = yes then  do: run macr_excel_sum ( o_temp-parts.RetOutKass-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[72] = yes then  do: run macr_excel_sum ( o_temp-parts.RetOutKass-DiscntSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[81] = yes then  do: run macr_excel_sum ( o_temp-parts.RetOutKass-DiscntSum * 100 / o_temp-parts.RetOutKass-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[21] = yes then  do: run macr_excel_sum ( o_temp-parts.OutExtKass-Qnty    - o_temp-parts.RetOutKass-Qnty , v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[40] = yes then  do: run macr_excel_sum ( o_temp-parts.OutExtKass-CostSum - o_temp-parts.RetOutKass-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[57] = yes then  do: run macr_excel_sum ( o_temp-parts.OutExtKass-SaleSum - o_temp-parts.RetOutKass-SaleSum - o_temp-parts.OutExtKass-DiscntSum + o_temp-parts.RetOutKass-DiscntSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[73] = yes then  do: run macr_excel_sum ( o_temp-parts.OutExtKass-DiscntSum - o_temp-parts.RetOutKass-DiscntSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[82] = yes then  do: run macr_excel_sum ( ( o_temp-parts.OutExtKass-DiscntSum - o_temp-parts.RetOutKass-DiscntSum ) * 100 / ( o_temp-parts.OutExtKass-SaleSum - o_temp-parts.RetOutKass-SaleSum ), v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[22] = yes then  do: run macr_excel_sum ( o_temp-parts.OutExt-Qnty      + o_temp-parts.OutExtKass-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[41] = yes then  do: run macr_excel_sum ( o_temp-parts.OutExt-CostSum   + o_temp-parts.OutExtKass-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[58] = yes then  do: run macr_excel_sum ( o_temp-parts.OutExt-SaleSum   + o_temp-parts.OutExtKass-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[74] = yes then  do: run macr_excel_sum ( o_temp-parts.OutExt-DiscntSum + o_temp-parts.OutExtKass-DiscntSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[83] = yes then  do: run macr_excel_sum ( ( o_temp-parts.OutExt-DiscntSum + o_temp-parts.OutExtKass-DiscntSum ) * 100 / ( o_temp-parts.OutExt-SaleSum + o_temp-parts.OutExtKass-SaleSum ) , v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[23] = yes then  do: run macr_excel_sum ( o_temp-parts.RetOut-Qnty      + o_temp-parts.RetOutKass-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[42] = yes then  do: run macr_excel_sum ( o_temp-parts.RetOut-CostSum   + o_temp-parts.RetOutKass-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[59] = yes then  do: run macr_excel_sum ( o_temp-parts.RetOut-SaleSum   + o_temp-parts.RetOutKass-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[75] = yes then  do: run macr_excel_sum ( o_temp-parts.RetOut-DiscntSum + o_temp-parts.RetOutKass-DiscntSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[84] = yes then  do: run macr_excel_sum ( ( o_temp-parts.RetOut-DiscntSum + o_temp-parts.RetOutKass-DiscntSum  ) * 100 / ( o_temp-parts.RetOut-SaleSum + o_temp-parts.RetOutKass-SaleSum ), v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[24] = yes then  do: run macr_excel_sum ( o_temp-parts.OutExt-Qnty    - o_temp-parts.RetOut-Qnty + o_temp-parts.OutExtKass-Qnty - o_temp-parts.RetOutKass-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[43] = yes then  do: run macr_excel_sum ( o_temp-parts.OutExt-CostSum - o_temp-parts.RetOut-CostSum + o_temp-parts.OutExtKass-CostSum - o_temp-parts.RetOutKass-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[60] = yes then  do: run macr_excel_sum ( o_temp-parts.OutExt-SaleSum - o_temp-parts.RetOut-SaleSum + o_temp-parts.OutExtKass-SaleSum - o_temp-parts.RetOutKass-SaleSum - o_temp-parts.OutExt-DiscntSum + o_temp-parts.RetOut-DiscntSum - o_temp-parts.OutExtKass-DiscntSum + o_temp-parts.RetOutKass-DiscntSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[76] = yes then  do: run macr_excel_sum ( o_temp-parts.OutExt-DiscntSum - o_temp-parts.RetOut-DiscntSum + o_temp-parts.OutExtKass-DiscntSum - o_temp-parts.RetOutKass-DiscntSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[85] = yes then  do: run macr_excel_sum ( ( o_temp-parts.OutExt-DiscntSum - o_temp-parts.RetOut-DiscntSum + o_temp-parts.OutExtKass-DiscntSum - o_temp-parts.RetOutKass-DiscntSum ) * 100 / ( o_temp-parts.OutExt-SaleSum - o_temp-parts.RetOut-SaleSum + o_temp-parts.OutExtKass-SaleSum - o_temp-parts.RetOutKass-SaleSum  ), v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[25] = yes then  do: run macr_excel_sum ( o_temp-parts.Inv-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[44] = yes then  do: run macr_excel_sum ( o_temp-parts.Inv-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[61] = yes then  do: run macr_excel_sum ( o_temp-parts.Inv-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[26] = yes then  do: run macr_excel_sum ( o_temp-parts.Spi-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[45] = yes then  do: run macr_excel_sum ( o_temp-parts.Spi-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[62] = yes then  do: run macr_excel_sum ( o_temp-parts.Spi-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[27] = yes then  do: run macr_excel_sum ( o_temp-parts.InInt-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[46] = yes then  do: run macr_excel_sum ( o_temp-parts.InInt-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[63] = yes then  do: run macr_excel_sum ( o_temp-parts.InInt-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[28] = yes then  do: run macr_excel_sum ( o_temp-parts.OutInt-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[47] = yes then  do: run macr_excel_sum ( o_temp-parts.OutInt-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[64] = yes then  do: run macr_excel_sum ( o_temp-parts.OutInt-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[29] = yes then  do: run macr_excel_sum ( o_temp-parts.RetInt-Qnty, v-row, v-col, sz-qnty) .    assign v-col = v-col + 1 . end.
      if use-column[48] = yes then  do: run macr_excel_sum ( o_temp-parts.RetInt-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[65] = yes then  do: run macr_excel_sum ( o_temp-parts.RetInt-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[30] = yes then  do: run macr_excel_sum ( o_temp-parts.InProiz-Qnty, v-row, v-col, sz-qnty) .     assign v-col = v-col + 1 . end.
      if use-column[49] = yes then  do: run macr_excel_sum ( o_temp-parts.InProiz-CostSum, v-row, v-col, 2) .  assign v-col = v-col + 1 . end.
      if use-column[66] = yes then  do: run macr_excel_sum ( o_temp-parts.InProiz-SaleSum, v-row, v-col, 2) .  assign v-col = v-col + 1 . end.
      if use-column[86] = yes then  do: run macr_excel_sum ( o_temp-parts.OutProiz-Qnty, v-row, v-col, sz-qnty) .    assign v-col = v-col + 1 . end.
      if use-column[87] = yes then  do: run macr_excel_sum ( o_temp-parts.OutProiz-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[88] = yes then  do: run macr_excel_sum ( o_temp-parts.OutProiz-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[67] = yes then  do: run macr_excel_sum ( o_temp-parts.Per-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[13] = yes then  do: run macr_excel_sum ( o_temp-parts.EndWay-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[32] = yes then  do: run macr_excel_sum ( o_temp-parts.EndWay-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[51] = yes then  do: run macr_excel_sum ( o_temp-parts.EndWay-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[10] =  yes then  do: run macr_excel_sum ( o_temp-parts.Effect-Value, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[11] =  yes then  do: run macr_excel_sum ( o_temp-parts.Up-Fact, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if RADIO-AltObj > 1  then  do: run macr_excel_sum ( o_temp-parts.Alt-RestEnd-Qnty, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[89] = yes then  do: run macr_excel_sum ( o_temp-parts.Free-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[90] = yes then  do: run macr_excel_sum ( o_temp-parts.Free-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[91] = yes then  do: run macr_excel_sum ( o_temp-parts.Free-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[92] = yes then  do: run macr_excel_sum ( o_temp-parts.Res-Qnty, v-row, v-col, sz-qnty) . assign v-col = v-col + 1 . end.
      if use-column[93] = yes then  do: run macr_excel_sum ( o_temp-parts.Res-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[94] = yes then  do: run macr_excel_sum ( o_temp-parts.Res-SaleSum - o_temp-parts.Res-DiscntSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[95] = yes then  do: run macr_excel_sum ( o_temp-parts.Res-DiscntSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[96] = yes then  do: run macr_excel_sum ( o_temp-parts.Res-DiscntSum * 100 / o_temp-parts.Res-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[97]  = yes then  do: run macr_excel_sum ( o_temp-parts.price-prod            , v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[98]  = yes then  do: run macr_excel_sum ( o_temp-parts.price-prodwithvat     , v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[99]  = yes then  do: run macr_excel_sum ( o_temp-parts.prod-vat              , v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[100] = yes then  do: run macr_excel_sum ( o_temp-parts.prod-vat-prc          , v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[101] = yes then  do: run macr_excel_sum ( o_temp-parts.price-supp            , v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[102] = yes then  do: run macr_excel_sum ( o_temp-parts.price-suppvat         , v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[103] = yes then  do: run macr_excel_sum ( o_temp-parts.suppvat               , v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[104] = yes then  do: run macr_excel_sum ( o_temp-parts.suppvat-prc           , v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[105] = yes then  do: run macr_excel_sum ( o_temp-parts.dis-1                 , v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[106] = yes then  do: run macr_excel_sum ( o_temp-parts.dis-1-prc             , v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[107] = yes then  do: run macr_excel_sum ( o_temp-parts.prod-crsavat          , v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[108] = yes then  do: run macr_excel_sum ( o_temp-parts.prod-crsa             , v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[109] = yes then  do: run macr_excel_sum ( o_temp-parts.vat-crsa              , v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[110] = yes then  do: run macr_excel_sum ( o_temp-parts.vat-crsa-prc          , v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[111] = yes then  do: run macr_excel_sum ( o_temp-parts.dis-2                 , v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[112] = yes then  do: run macr_excel_sum ( o_temp-parts.dis-2-prc             , v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[113] = yes then  do: run macr_excel_sum ( o_temp-parts.dis-3                 , v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[114] = yes then  do: run macr_excel_sum ( o_temp-parts.dis-3-prc             , v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[115] = yes then  do: run macr_excel_sum ( o_temp-parts.dis-2vat              , v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[116] = yes then  do: run macr_excel_sum ( o_temp-parts.dis-2-prcvat          , v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[117] = yes then  do: run macr_excel_sum ( o_temp-parts.dis-3vat              , v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      if use-column[118] = yes then  do: run macr_excel_sum ( o_temp-parts.dis-3-prcvat          , v-row, v-col, 2) . assign v-col = v-col + 1 . end.
      assign v-row = v-row + 1 .
      if name-tov = 3 and use-column[3]  = yes then do:
        assign   v-col = 1 .
        if use-column[1]  = yes then  assign v-col = v-col + 1 .
        if use-column[2]  = yes then  assign v-col = v-col + 1 .
        run macr_excel_char (o_temp-parts.gds-name1, v-row, v-col) .
        assign v-row = v-row + 1 .
      end.
      assign
        ii = 1
        jj = 1
      .
    if ExportZUM then do:
      if tog-obj = true then do:
        put stream txt-file
          o_temp-parts.obj-type format "X(5)"   CHR(9)
          o_temp-parts.obj-code format ">>>>>>>9" CHR(9)
          o_temp-parts.obj-name format "X(50)"   CHR(9)
        .
      end.
      put stream txt-file
        o_temp-parts.grp-name format "X(70)"  CHR(9)
        o_temp-parts.prod-type format "X(5)"   CHR(9)
        o_temp-parts.prod-code format ">>>>>>>>>>>9" CHR(9)
        o_temp-parts.prod-name format "X(50)"  CHR(9)
      .
    end.
      if use-column[1]  = yes then do:
        find first line-frm where line-frm.num = ii .
        put stream outstream  "|" at line-frm.beg o_temp-parts.b-code format line-frm.frm .
        if ExportZUM then put stream txt-file  o_temp-parts.b-code format line-frm.frm CHR(9).
        assign
          ii = ii + 1
          jj = jj + 1
        .
      end.
      if use-column[2]  = yes then do:
        find first line-frm where line-frm.num = ii .
        if ExportZUM then put stream txt-file  o_temp-parts.part-code format "X(16)" CHR(9) .
        put stream outstream  "|" at line-frm.beg o_temp-parts.part-code format line-frm.frm .
        assign
          ii = ii + 1
          jj = jj + 1
        .
      end.
      if use-column[3]  = yes then do:
        find first line-frm where line-frm.num = ii .
        if ExportZUM then put stream txt-file  o_temp-parts.gds-name format "X(40)" CHR(9) .
        put stream outstream  "|" at line-frm.beg o_temp-parts.gds-name format line-frm.frm .
        assign
          ii = ii + 1
          jj = jj + 1
        .
      end.
      if use-column[4]  = yes then do:
        find first line-frm where line-frm.num = ii .
        if ExportZUM then put stream txt-file  o_temp-parts.unit-base format "X(4)" CHR(9) .
        put stream outstream  "|" at line-frm.beg o_temp-parts.unit-base format line-frm.frm .
        assign
          ii = ii + 1
          jj = jj + 1
        .
      end.
      if use-column[5]  = yes then do:
        find first line-frm where line-frm.num = ii .
        if ExportZUM then put stream txt-file UNFORMATTED  replace(string(o_temp-parts.Cost-Price,frm-sum1),".",",")   CHR(9) .
        put stream outstream  "|" at line-frm.beg o_temp-parts.Cost-Price format line-frm.frm .
        assign
          ii = ii + 1
          jj = jj + 1
        .
      end.
      if use-column[6]  = yes then do:
        find first line-frm where line-frm.num = ii .
        if prod-zen = yes then do:
           if ExportZUM then put stream txt-file UNFORMATTED  replace(string(o_temp-parts.Avrg-Sale-Price,frm-sum1),".",",")   CHR(9) .
           put stream outstream  "|" at line-frm.beg o_temp-parts.Avrg-Sale-Price format line-frm.frm .
        end.
        else do:
          if ExportZUM then put stream txt-file UNFORMATTED  replace(string(o_temp-parts.Last-Sale-Price,frm-sum1),".",",")  CHR(9) .
          put stream outstream  "|" at line-frm.beg o_temp-parts.Last-Sale-Price format line-frm.frm .
        end.
        assign
          ii = ii + 1
          jj = jj + 1
        .
      end.
      if use-column[7]  = yes then do:
        find first line-frm where line-frm.num = ii .
        put stream outstream  "|" at line-frm.beg o_temp-parts.Up-Plan format line-frm.frm .
        if ExportZUM then put stream txt-file UNFORMATTED  replace(string(o_temp-parts.Up-Plan,frm-sum1),".",",")  CHR(9) .
        assign
          ii = ii + 1
          jj = jj + 1
        .
      end.
      if use-column[8]  = yes then do:
        find first line-frm where line-frm.num = ii .
        put stream outstream  "|" at line-frm.beg o_temp-parts.LastPer-Date format line-frm.frm .
        if ExportZUM then put stream txt-file  o_temp-parts.LastPer-Date format "99/99/9999" CHR(9) .
        assign
          ii = ii + 1
          jj = jj + 1
        .
      end.
      if use-column[9]  = yes then do:
        find first line-frm where line-frm.num = ii .
        put stream outstream  "|" at line-frm.beg o_temp-parts.LastPer-Num format line-frm.frm .
        if ExportZUM then put stream txt-file  o_temp-parts.LastPer-Num format "X(10)" CHR(9) .
        assign
          ii = ii + 1
          jj = jj + 1
        .
      end.
      if use-column[12] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.StartWay-Qnty
          ii = ii + 1
        .
      end.
      if use-column[31] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.StartWay-CostSum
          ii = ii + 1
        .
      end.
      if use-column[50] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.StartWay-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[14] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.InExt-Qnty
          ii = ii + 1
        .
      end.
      if use-column[33] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.InExt-CostSum
          ii = ii + 1
        .
      end.
      if use-column[15] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.RetPost-Qnty
          ii = ii + 1
        .
      end.
      if use-column[34] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.RetPost-CostSum
          ii = ii + 1
        .
      end.
      if use-column[16] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.OutExt-Qnty
          ii = ii + 1
        .
      end.
      if use-column[35] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.OutExt-CostSum
          ii = ii + 1
        .
      end.
      if use-column[52] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.OutExt-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[68] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.OutExt-DiscntSum
          ii = ii + 1
        .
      end.
      if use-column[77] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.OutExt-DiscntSum * 100 / o_temp-parts.OutExt-SaleSum
          ii = ii + 1
        .
        if line-frm.sum = ? then assign line-frm.sum = 0 .
      end.
      if use-column[17] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.RetOut-Qnty
          ii = ii + 1
        .
      end.
      if use-column[36] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.RetOut-CostSum
          ii = ii + 1
        .
      end.
      if use-column[53] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.RetOut-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[69] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.RetOut-DiscntSum
          ii = ii + 1
        .
      end.
      if use-column[78] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.RetOut-DiscntSum * 100 / o_temp-parts.RetOut-SaleSum
          ii = ii + 1
        .
        if line-frm.sum = ? then assign line-frm.sum = 0 .
      end.
      if use-column[18] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.OutExt-Qnty - o_temp-parts.RetOut-Qnty
          ii = ii + 1
        .
      end.
      if use-column[37] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.OutExt-CostSum - o_temp-parts.RetOut-CostSum
          ii = ii + 1
        .
      end.
      if use-column[54] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.OutExt-SaleSum - o_temp-parts.RetOut-SaleSum - o_temp-parts.OutExt-DiscntSum + o_temp-parts.RetOut-DiscntSum
          ii = ii + 1
        .
      end.
      if use-column[70] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.OutExt-DiscntSum - o_temp-parts.RetOut-DiscntSum
          ii = ii + 1
        .
      end.
      if use-column[79] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = ( o_temp-parts.OutExt-DiscntSum - o_temp-parts.RetOut-DiscntSum ) * 100 / ( o_temp-parts.OutExt-SaleSum - o_temp-parts.RetOut-SaleSum )
          ii = ii + 1
        .
        if line-frm.sum = ? then assign line-frm.sum = 0 .
      end.
      if use-column[19] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.OutExtKass-Qnty
          ii = ii + 1
        .
      end.
      if use-column[38] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.OutExtKass-CostSum
          ii = ii + 1
        .
      end.
      if use-column[55] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.OutExtKass-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[71] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.OutExtKass-DiscntSum
          ii = ii + 1
        .
      end.
      if use-column[80] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.OutExtKass-DiscntSum * 100 / o_temp-parts.OutExtKass-SaleSum
          ii = ii + 1
        .
        if line-frm.sum = ? then assign line-frm.sum = 0 .
      end.
      if use-column[20] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.RetOutKass-Qnty
          ii = ii + 1
        .
      end.
      if use-column[39] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.RetOutKass-CostSum
          ii = ii + 1
        .
      end.
      if use-column[56] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.RetOutKass-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[72] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.RetOutKass-DiscntSum
          ii = ii + 1
        .
      end.
      if use-column[81] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.RetOutKass-DiscntSum * 100 / o_temp-parts.RetOutKass-SaleSum
          ii = ii + 1
        .
        if line-frm.sum = ? then assign line-frm.sum = 0 .
      end.
      if use-column[21] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.OutExtKass-Qnty    - o_temp-parts.RetOutKass-Qnty
          ii = ii + 1
        .
      end.
      if use-column[40] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.OutExtKass-CostSum - o_temp-parts.RetOutKass-CostSum
          ii = ii + 1
        .
      end.
      if use-column[57] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.OutExtKass-SaleSum - o_temp-parts.RetOutKass-SaleSum - o_temp-parts.OutExtKass-DiscntSum + o_temp-parts.RetOutKass-DiscntSum
          ii = ii + 1
        .
      end.
      if use-column[73] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.OutExtKass-DiscntSum - o_temp-parts.RetOutKass-DiscntSum
          ii = ii + 1
        .
      end.
      if use-column[82] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = ( o_temp-parts.OutExtKass-DiscntSum - o_temp-parts.RetOutKass-DiscntSum ) * 100 / ( o_temp-parts.OutExtKass-SaleSum - o_temp-parts.RetOutKass-SaleSum )
          ii = ii + 1
        .
        if line-frm.sum = ? then assign line-frm.sum = 0 .
      end.
      if use-column[22] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.OutExt-Qnty      + o_temp-parts.OutExtKass-Qnty
          ii = ii + 1
        .
      end.
      if use-column[41] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.OutExt-CostSum   + o_temp-parts.OutExtKass-CostSum
          ii = ii + 1
        .
      end.
      if use-column[58] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.OutExt-SaleSum   + o_temp-parts.OutExtKass-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[74] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.OutExt-DiscntSum + o_temp-parts.OutExtKass-DiscntSum
          ii = ii + 1
        .
      end.
      if use-column[83] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = ( o_temp-parts.OutExt-DiscntSum + o_temp-parts.OutExtKass-DiscntSum ) * 100 / ( o_temp-parts.OutExt-SaleSum + o_temp-parts.OutExtKass-SaleSum )
          ii = ii + 1
        .
        if line-frm.sum = ? then assign line-frm.sum = 0 .
      end.
      if use-column[23] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.RetOut-Qnty      + o_temp-parts.RetOutKass-Qnty
          ii = ii + 1
        .
      end.
      if use-column[42] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.RetOut-CostSum   + o_temp-parts.RetOutKass-CostSum
          ii = ii + 1
        .
      end.
      if use-column[59] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.RetOut-SaleSum   + o_temp-parts.RetOutKass-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[75] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.RetOut-DiscntSum + o_temp-parts.RetOutKass-DiscntSum
          ii = ii + 1
        .
      end.
      if use-column[84] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = ( o_temp-parts.RetOut-DiscntSum + o_temp-parts.RetOutKass-DiscntSum  ) * 100 / ( o_temp-parts.RetOut-SaleSum + o_temp-parts.RetOutKass-SaleSum )
          ii = ii + 1
        .
        if line-frm.sum = ? then assign line-frm.sum = 0 .
      end.
      if use-column[24] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.OutExt-Qnty    - o_temp-parts.RetOut-Qnty + o_temp-parts.OutExtKass-Qnty - o_temp-parts.RetOutKass-Qnty
          ii = ii + 1
        .
      end.
      if use-column[43] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.OutExt-CostSum - o_temp-parts.RetOut-CostSum + o_temp-parts.OutExtKass-CostSum - o_temp-parts.RetOutKass-CostSum
          ii = ii + 1
        .
      end.
      if use-column[60] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.OutExt-SaleSum - o_temp-parts.RetOut-SaleSum + o_temp-parts.OutExtKass-SaleSum - o_temp-parts.RetOutKass-SaleSum - (o_temp-parts.OutExt-DiscntSum - o_temp-parts.RetOut-DiscntSum + o_temp-parts.OutExtKass-DiscntSum - o_temp-parts.RetOutKass-DiscntSum)
          ii = ii + 1
        .
      end.
      if use-column[76] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.OutExt-DiscntSum - o_temp-parts.RetOut-DiscntSum + o_temp-parts.OutExtKass-DiscntSum - o_temp-parts.RetOutKass-DiscntSum
          ii = ii + 1
        .
      end.
      if use-column[85] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = ( o_temp-parts.OutExt-DiscntSum - o_temp-parts.RetOut-DiscntSum + o_temp-parts.OutExtKass-DiscntSum - o_temp-parts.RetOutKass-DiscntSum ) * 100 / ( o_temp-parts.OutExt-SaleSum - o_temp-parts.RetOut-SaleSum + o_temp-parts.OutExtKass-SaleSum - o_temp-parts.RetOutKass-SaleSum  )
          ii = ii + 1
        .
        if line-frm.sum = ? then assign line-frm.sum = 0 .
      end.
      if use-column[25] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.Inv-Qnty
          ii = ii + 1
        .
      end.
      if use-column[44] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.Inv-CostSum
          ii = ii + 1
        .
      end.
      if use-column[61] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.Inv-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[26] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.Spi-Qnty
          ii = ii + 1
        .
      end.
      if use-column[45] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.Spi-CostSum
          ii = ii + 1
        .
      end.
      if use-column[62] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.Spi-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[27] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.InInt-Qnty
          ii = ii + 1
        .
      end.
      if use-column[46] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.InInt-CostSum
          ii = ii + 1
        .
      end.
      if use-column[63] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.InInt-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[28] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.OutInt-Qnty
          ii = ii + 1
        .
      end.
      if use-column[47] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.OutInt-CostSum
          ii = ii + 1
        .
      end.
      if use-column[64] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.OutInt-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[29] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.RetInt-Qnty
          ii = ii + 1
        .
      end.
      if use-column[48] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.RetInt-CostSum
          ii = ii + 1
        .
      end.
      if use-column[65] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.RetInt-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[30] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.InProiz-Qnty
          ii = ii + 1
        .
      end.
      if use-column[49] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.InProiz-CostSum
          ii = ii + 1
        .
      end.
      if use-column[66] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.InProiz-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[86] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.OutProiz-Qnty
          ii = ii + 1
        .
      end.
      if use-column[87] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.OutProiz-CostSum
          ii = ii + 1
        .
      end.
      if use-column[88] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.OutProiz-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[67] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.Per-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[13] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.EndWay-Qnty
          ii = ii + 1
        .
      end.
      if use-column[32] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.EndWay-CostSum
          ii = ii + 1
        .
      end.
      if use-column[51] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.EndWay-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[10] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.Effect-Value
          ii = ii + 1
        .
      end.
      if use-column[11] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.Up-Fact
          ii = ii + 1
        .
      end.
      if RADIO-AltObj > 1 then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.Alt-RestEnd-Qnty
          ii = ii + 1
        .
      end.
      if use-column[89] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.Free-Qnty
          ii = ii + 1
        .
      end.
      if use-column[90] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.Free-CostSum
          ii = ii + 1
        .
      end.
      if use-column[91] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.Free-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[92] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.Res-Qnty
          ii = ii + 1
        .
      end.
      if use-column[93] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.Res-CostSum
          ii = ii + 1
        .
      end.
      if use-column[94] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.Res-SaleSum - o_temp-parts.Res-DiscntSum
          ii = ii + 1
        .
      end.
      if use-column[95] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.Res-DiscntSum
          ii = ii + 1
        .
      end.
      if use-column[96] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.Res-DiscntSum * 100 / o_temp-parts.Res-SaleSum
          ii = ii + 1
        .
      end.
      if use-column[97] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.price-prod
          ii = ii + 1
        .
      end.
      if use-column[98] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.price-prodwithvat
          ii = ii + 1
        .
      end.
      if use-column[99] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.prod-vat
          ii = ii + 1
        .
      end.
      if use-column[100] = yes then do:
        find first line-frm where line-frm.num = ii .
        assign
          line-frm.sum = o_temp-parts.prod-vat-prc
          ii = ii + 1
        .
     end.
if use-column[101] = yes then do: find first line-frm where line-frm.num = ii. assign line-frm.sum = o_temp-parts.price-supp     ii = ii + 1 . end.
if use-column[102] = yes then do: find first line-frm where line-frm.num = ii. assign line-frm.sum = o_temp-parts.price-suppvat  ii = ii + 1 . end.
if use-column[103] = yes then do: find first line-frm where line-frm.num = ii. assign line-frm.sum = o_temp-parts.suppvat        ii = ii + 1 . end.
if use-column[104] = yes then do: find first line-frm where line-frm.num = ii. assign line-frm.sum = o_temp-parts.suppvat-prc    ii = ii + 1 . end.
if use-column[105] = yes then do: find first line-frm where line-frm.num = ii. assign line-frm.sum = o_temp-parts.dis-1          ii = ii + 1 . end.
if use-column[106] = yes then do: find first line-frm where line-frm.num = ii. assign line-frm.sum = o_temp-parts.dis-1-prc      ii = ii + 1 . end.
if use-column[107] = yes then do: find first line-frm where line-frm.num = ii. assign line-frm.sum = o_temp-parts.prod-crsavat   ii = ii + 1 . end.
if use-column[108] = yes then do: find first line-frm where line-frm.num = ii. assign line-frm.sum = o_temp-parts.prod-crsa      ii = ii + 1 . end.
if use-column[109] = yes then do: find first line-frm where line-frm.num = ii. assign line-frm.sum = o_temp-parts.vat-crsa       ii = ii + 1 . end.
if use-column[110] = yes then do: find first line-frm where line-frm.num = ii. assign line-frm.sum = o_temp-parts.vat-crsa-prc   ii = ii + 1 . end.
if use-column[111] = yes then do: find first line-frm where line-frm.num = ii. assign line-frm.sum = o_temp-parts.dis-2          ii = ii + 1 . end.
if use-column[112] = yes then do: find first line-frm where line-frm.num = ii. assign line-frm.sum = o_temp-parts.dis-2-prc      ii = ii + 1 . end.
if use-column[113] = yes then do: find first line-frm where line-frm.num = ii. assign line-frm.sum = o_temp-parts.dis-3          ii = ii + 1 . end.
if use-column[114] = yes then do: find first line-frm where line-frm.num = ii. assign line-frm.sum = o_temp-parts.dis-3-prc      ii = ii + 1 . end.
if use-column[115] = yes then do: find first line-frm where line-frm.num = ii. assign line-frm.sum = o_temp-parts.dis-2vat       ii = ii + 1 . end.
if use-column[116] = yes then do: find first line-frm where line-frm.num = ii. assign line-frm.sum = o_temp-parts.dis-2-prcvat   ii = ii + 1 . end.
if use-column[117] = yes then do: find first line-frm where line-frm.num = ii. assign line-frm.sum = o_temp-parts.dis-3vat       ii = ii + 1 . end.
if use-column[118] = yes then do: find first line-frm where line-frm.num = ii. assign line-frm.sum = o_temp-parts.dis-3-prcvat   ii = ii + 1 . end.
      for each line-frm :
        if line-frm.num >= jj  then do:
          put stream outstream  "|" at line-frm.beg line-frm.sum format line-frm.frm .
          if ExportZUM then put stream txt-file UNFORMATTED  replace(string(line-frm.sum,frm-qnty1),".",",")  CHR(9) .
        end.
      end.
      put stream outstream   "|"  skip .
      if ExportZUM then put stream txt-file  chr(10) .
      if name-tov = 3 and use-column[3]  = yes then do:
        assign ii = 1  .
        if use-column[1]  = yes then do:
          find first line-frm where line-frm.num = ii .
          put stream outstream  "|" at line-frm.beg .
          assign ii = ii + 1 .
        end.
        if use-column[2]  = yes then do:
          find first line-frm where line-frm.num = ii .
          put stream outstream  "|" at line-frm.beg .
          assign ii = ii + 1 .
        end.
        find first line-frm where line-frm.num = ii .
        put stream outstream  "|" at line-frm.beg o_temp-parts.gds-name1 format line-frm.frm .
        assign  ii = ii + 1   .
        for each line-frm :
          if line-frm.num > ii  then  put stream outstream  "|" at line-frm.beg .
        end.
        put stream outstream   "|" at beg  skip .
      end.
  end.
  end.
end procedure.
