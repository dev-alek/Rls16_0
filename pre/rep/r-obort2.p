block-level on error undo, throw.
define input parameter ShowZero           as logical   no-undo .
define input parameter ShowZero-2         as logical   no-undo .
define input parameter RADIO-Nomenkl      as integer   no-undo .
define input parameter Tog-obj            as logical   no-undo .
define input parameter Classify           as character no-undo .
define input parameter RADIO-AltObj       as integer   no-undo .
define input parameter AltObj-list        as character no-undo .
define input parameter SortType           as character no-undo .
define input parameter prod-zen           as logical   no-undo .
define input parameter print-o            as character no-undo .
define input parameter SumsOnly           as logical   no-undo .
define input parameter tog-lavel          as logical   no-undo .
define input parameter var-lavel          as integer   no-undo .
define input parameter tog-tree           as logical   no-undo .
define input parameter name-tov           as integer   no-undo .
define input parameter start-sum          as integer   no-undo .
define input parameter end-sum            as integer   no-undo .
define input parameter frm-qnty           as character no-undo .
define input parameter sz-qnty            as integer   no-undo .
define input parameter v-fact-order-start as decimal   no-undo .
define input parameter v-fact-order-end   as decimal   no-undo .
define input parameter SumsOnly2          as logical   no-undo .
define input parameter ExportZUM          as logical   no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-obort2.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-obort2.p $":U .
define variable vss-description as character no-undo init "Старая оборотка с признак".
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
def var vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info9 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
def var vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure r-cost :
  define input  parameter v-doc-code       like ub.doc-line.doc-code          no-undo .
  define input  parameter v-artic          like ub.doc-line.artic             no-undo .
  define input  parameter v-prod-type      like ub.doc-line.prod-type         no-undo .
  define input  parameter v-prod-code      like ub.doc-line.prod-code         no-undo .
  define output parameter v-fact-qnty      like ub.ot-line.fact-qnty       no-undo .
  define output parameter v-vat-pc         like ub.doc-line.vat-pc         no-undo .
  define output parameter v-slt-pc         like ub.doc-line.slt-pc         no-undo .
  define output parameter v-sum-base       like ub.ot-line.sum-base        no-undo .
  define output parameter v-sum-rubl       like ub.ot-line.sum-rubl        no-undo .
  define output parameter v-vat-base       like ub.ot-line.vat-base        no-undo .
  define output parameter v-vat-rubl       like ub.ot-line.vat-rubl        no-undo .
  define output parameter v-slt-base       like ub.ot-line.slt-base        no-undo .
  define output parameter v-slt-rubl       like ub.ot-line.slt-rubl        no-undo .
  define output parameter v-road-tax-base  like ub.ot-line.road-tax-base   no-undo .
  define output parameter v-road-tax-rubl  like ub.ot-line.road-tax-rubl   no-undo .
  define output parameter v-transport-base like ub.ot-line.transport-base  no-undo .
  define output parameter v-transport-rubl like ub.ot-line.transport-rubl  no-undo .
  define output parameter v-other-base     like ub.ot-line.other-base      no-undo .
  define output parameter v-other-rubl     like ub.ot-line.other-rubl      no-undo .
  define output parameter v-excise-base    like ub.ot-line.excise-base     no-undo .
  define output parameter v-excise-rubl    like ub.ot-line.excise-rubl     no-undo .
  do
  on error undo, return error
  :
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
    def var v-parts-fact-qnty as decimal   no-undo .
    define buffer buf_parts    for ub.parts    .
    define buffer buf_goods    for ub.goods    .
    define buffer buf_trn-doc  for ub.trn-doc  .
    define buffer buf_doc-line for ub.doc-line .
    find first buf_doc-line no-lock
      where buf_doc-line.doc-code  = v-doc-code
        and buf_doc-line.artic     = v-artic
        and buf_doc-line.prod-type = v-prod-type
        and buf_doc-line.prod-code = v-prod-code
      no-error .
    if not available buf_doc-line then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info10 skip
        "Ошибка задания входных параметров" skip
        "Не найдена строка документа"  skip
        "Документ" v-doc-code skip
        "Артикул" v-artic v-prod-type v-prod-code skip
        view-as alert-box error .
      return error .
    end.
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = v-doc-code
      no-error .
    if not available buf_trn-doc then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info10 skip
        "Ошибка задания входных параметров" skip
        "Не найден документ" skip
        "Документ" v-doc-code skip
        "Артикул" v-artic v-prod-type v-prod-code skip
        view-as alert-box error .
      undo, return error .
    end.
    find first buf_goods no-lock
      where buf_goods.artic     = buf_doc-line.artic
        and buf_goods.prod-type = buf_doc-line.prod-type
        and buf_goods.prod-code = buf_doc-line.prod-code
      no-error .
    if not available buf_goods then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info10 skip
        "Ошибка задания входных параметров" skip
        "Не найден товар" skip
        "Документ" v-doc-code skip
        "Артикул" v-artic v-prod-type v-prod-code skip
        view-as alert-box error .
      undo, return error .
    end.
    if buf_goods.gds-type = 'т':U then do:
          for each buf_parts no-lock
            where buf_parts.out-code  = buf_trn-doc.doc-code
              and buf_parts.obj-type  = buf_trn-doc.obj-type
              and buf_parts.obj-code  = buf_trn-doc.obj-code
              and buf_parts.artic     = buf_doc-line.artic
              and buf_parts.prod-type = buf_doc-line.prod-type
              and buf_parts.prod-code = buf_doc-line.prod-code
          on error undo, return error
          :
assign
  price-rubl-with-tax-loc = buf_parts.price-rubl
  price-base-with-tax-loc = buf_parts.price-base
.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
  if buf_parts.out-code = 'free-zone':U     or
     buf_parts.out-code = 'out-zone':U   or
     buf_parts.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-slt = yes.
  end.
  else do:
    find first in-vatp_doc-attr no-lock
      where in-vatp_doc-attr.doc-code  = buf_parts.out-code
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
   price-cli-with-tax-loc = buf_parts.price-cli
   cli-base-rate          = buf_parts.cli-base-rate.
  ASSIGN   road-tax-base-loc  = (if buf_parts.road-tax-base  = ? then 0 else buf_parts.road-tax-base)
           road-tax-rubl-loc  = (if buf_parts.road-tax-rubl  = ? then 0 else buf_parts.road-tax-rubl).
  ASSIGN  transport-base-loc = (if buf_parts.transport-base = ? then 0 else buf_parts.transport-base)
          transport-rubl-loc = (if buf_parts.transport-rubl = ? then 0 else buf_parts.transport-rubl)
          other-base-loc     = (if buf_parts.other-base     = ? then 0 else buf_parts.other-base)
          other-rubl-loc     = (if buf_parts.other-rubl     = ? then 0 else buf_parts.other-rubl)
          vat-pc-loc         = (if buf_parts.vat-pc         = ? then 0 else buf_parts.vat-pc)
          slt-pc-loc         = (if buf_parts.slt-pc         = ? then 0 else buf_parts.slt-pc).
          ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
    ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
  assign
    exch-rate-cli-loc = (buf_parts.price-rubl - transport-rubl-loc - other-rubl-loc - road-tax-rubl-loc - (if buf_parts.vat-type <> 'в т. ч.':U then vat-rubl-loc else 0) - (if buf_parts.slt-type <> 'в т. ч.':U then slt-rubl-loc else 0)) / buf_parts.price-cli .
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
              v-parts-fact-qnty  = (if buf_trn-doc.doc-type = 'при':U
                                    or buf_trn-doc.doc-type = 'возврат':U
                                    or buf_trn-doc.doc-type = 'инв':U
                                    then buf_parts.fact-qnty
                                    else - buf_parts.fact-qnty
                                   )
            .
            assign
              v-fact-qnty           = v-fact-qnty      + v-parts-fact-qnty
              v-sum-base            = v-sum-base       +  ( price-base-with-tax-loc * v-parts-fact-qnty )
              v-sum-rubl            = v-sum-rubl       +  ( price-rubl-with-tax-loc * v-parts-fact-qnty )
              v-vat-base            = v-vat-base       +  ( vat-base-loc            * v-parts-fact-qnty )
              v-vat-rubl            = v-vat-rubl       +  ( vat-rubl-loc            * v-parts-fact-qnty )
              v-slt-base            = v-slt-base       +  ( slt-base-loc            * v-parts-fact-qnty )
              v-slt-rubl            = v-slt-rubl       +  ( slt-rubl-loc            * v-parts-fact-qnty )
              v-road-tax-base       = v-road-tax-base  +  ( road-tax-base-loc       * v-parts-fact-qnty )
              v-road-tax-rubl       = v-road-tax-rubl  +  ( road-tax-rubl-loc       * v-parts-fact-qnty )
              v-excise-base         =   0
              v-excise-rubl         =   0
              v-transport-base      = v-transport-base +   (transport-base-loc      * v-parts-fact-qnty )
              v-transport-rubl      = v-transport-rubl +   (transport-rubl-loc      * v-parts-fact-qnty )
              v-other-base          = v-other-base     +   (other-base-loc          * v-parts-fact-qnty )
              v-other-rubl          = v-other-rubl     +   (other-rubl-loc          * v-parts-fact-qnty )
            .
        end.
assign
  price-rubl-with-tax-loc = buf_doc-line.price-rubl
  price-base-with-tax-loc = buf_doc-line.price-base
.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
   find first in-vatp_doc-attr no-lock
    where in-vatp_doc-attr.doc-code  = buf_trn-doc.doc-code
      and in-vatp_doc-attr.attr-code = 'envd':U
    no-error .
    if available in-vatp_doc-attr
       then do:
       assign
         in-vatp-have-vat-slt = no.
   end.
   else do:
     assign
       in-vatp-have-vat-slt = yes.
   end.
   find first in-vatp-goods where in-vatp-goods.artic     = buf_doc-line.artic     and
                                     in-vatp-goods.prod-type = buf_doc-line.prod-type and
                                     in-vatp-goods.prod-code = buf_doc-line.prod-code no-lock.
   if (not buf_trn-doc.internal and
           buf_trn-doc.doc-type = 'при':U) or
      in-vatp-goods.gds-type = 'у':U then do:
      if varinvprb = "base":u then do:
        assign
          road-tax-base-loc = buf_doc-line.road-tax
          road-tax-rubl-loc = buf_doc-line.road-tax * buf_trn-doc.base-rate / buf_trn-doc.base-scale.
      end.
      else do:
        ASSIGN
          road-tax-rubl-loc = buf_doc-line.road-tax
          road-tax-base-loc = buf_doc-line.road-tax / buf_trn-doc.base-rate * buf_trn-doc.base-scale.
      end.
      if road-tax-base-loc = ? then road-tax-base-loc = 0.
      if road-tax-rubl-loc = ? then road-tax-rubl-loc = 0.
      assign
        road-tax-cli-loc = ?.
      ASSIGN
        transport-base-loc = (if buf_doc-line.transport-base = ? then 0 else buf_doc-line.transport-base)
        transport-rubl-loc = (if buf_doc-line.transport-rubl = ? then 0 else buf_doc-line.transport-rubl)
        transport-cli-loc  = 0
        other-base-loc     = (if buf_doc-line.other-base     = ? then 0 else buf_doc-line.other-base)
        other-rubl-loc     = (if buf_doc-line.other-rubl     = ? then 0 else buf_doc-line.other-rubl)
        other-cli-loc      = 0
        vat-pc-loc         = (if buf_doc-line.vat-pc         = ? then 0 else buf_doc-line.vat-pc)
        slt-pc-loc         = (if buf_doc-line.slt-pc         = ? then 0 else buf_doc-line.slt-pc).
                              ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
            ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
      assign
        vat-cli-loc            = ?
        slt-cli-loc            = ?
        price-cli-with-tax-loc = ?.
   end.
   else do:
                                                for each in-vatp-parts where in-vatp-parts.out-code  = buf_doc-line.doc-code  and
                                      in-vatp-parts.obj-type  = buf_doc-line.obj-type  and
                                      in-vatp-parts.obj-code  = buf_doc-line.obj-code  and
                                      in-vatp-parts.artic     = buf_doc-line.artic     and
                                      in-vatp-parts.prod-type = buf_doc-line.prod-type and
                                      in-vatp-parts.prod-code = buf_doc-line.prod-code
                         use-index out-code no-lock:
          accumulate  in-vatp-parts.road-tax-base  * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.road-tax-rubl  * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.transport-base * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.transport-rubl * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.other-base     * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.other-rubl     * in-vatp-parts.fact-qnty (total)
                                                                                                              (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                      / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  / (100 + in-vatp-parts.vat-pc))  (total)
                                            (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                      / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  / (100 + in-vatp-parts.vat-pc))  (total)
                      .
      end.
      ASSIGN
        road-tax-base-loc   = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.road-tax-base  * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        road-tax-rubl-loc   = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.road-tax-rubl  * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        transport-base-loc  = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.transport-base * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        transport-rubl-loc  = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.transport-rubl * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        other-base-loc      = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.other-base     * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        other-rubl-loc      = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.other-rubl     * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
                                        vat-base-loc        = if buf_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / buf_doc-line.fact-qnty   else 0
        slt-base-loc        = if buf_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / buf_doc-line.fact-qnty   else 0
                vat-rubl-loc        = if buf_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / buf_doc-line.fact-qnty   else 0
        slt-rubl-loc        = if buf_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / buf_doc-line.fact-qnty   else 0
        vat-pc-loc          = (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  / (100 + in-vatp-parts.vat-pc)))
        slt-pc-loc          = (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                      / (100 + in-vatp-parts.slt-pc))).
      if road-tax-base-loc  = ? then road-tax-base-loc  = 0.
      if road-tax-rubl-loc  = ? then road-tax-rubl-loc  = 0.
      if transport-base-loc = ? then transport-base-loc = 0.
      if transport-rubl-loc = ? then transport-rubl-loc = 0.
      if other-base-loc     = ? then other-base-loc     = 0.
      if other-rubl-loc     = ? then other-rubl-loc     = 0.
      assign
        transport-cli-loc      = 0
        other-cli-loc          = 0
        road-tax-cli-loc       = ?
        vat-cli-loc            = ?
        slt-cli-loc            = ?
        price-cli-with-tax-loc = ?.
   end.
ASSIGN
          price-base-without-tax-loc = price-base-with-tax-loc - vat-base-loc - slt-base-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))
    price-rubl-without-tax-loc = price-rubl-with-tax-loc - vat-rubl-loc - slt-rubl-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))
.
        assign
            v-vat-pc              = vat-pc-loc
            v-slt-pc              = slt-pc-loc
        .
    end.
    else do:
          assign
            v-parts-fact-qnty           = (if buf_trn-doc.doc-type = 'при':U
                                      or buf_trn-doc.doc-type = 'возврат':U
                                      or buf_trn-doc.doc-type = 'инв':U
                                      then buf_doc-line.fact-qnty
                                      else - buf_doc-line.fact-qnty
                                    )
          .
assign
  price-rubl-with-tax-loc = buf_doc-line.price-rubl
  price-base-with-tax-loc = buf_doc-line.price-base
.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
   find first in-vatp_doc-attr no-lock
    where in-vatp_doc-attr.doc-code  = buf_trn-doc.doc-code
      and in-vatp_doc-attr.attr-code = 'envd':U
    no-error .
    if available in-vatp_doc-attr
       then do:
       assign
         in-vatp-have-vat-slt = no.
   end.
   else do:
     assign
       in-vatp-have-vat-slt = yes.
   end.
   find first in-vatp-goods where in-vatp-goods.artic     = buf_doc-line.artic     and
                                     in-vatp-goods.prod-type = buf_doc-line.prod-type and
                                     in-vatp-goods.prod-code = buf_doc-line.prod-code no-lock.
   if (not buf_trn-doc.internal and
           buf_trn-doc.doc-type = 'при':U) or
      in-vatp-goods.gds-type = 'у':U then do:
      if varinvprb = "base":u then do:
        assign
          road-tax-base-loc = buf_doc-line.road-tax
          road-tax-rubl-loc = buf_doc-line.road-tax * buf_trn-doc.base-rate / buf_trn-doc.base-scale.
      end.
      else do:
        ASSIGN
          road-tax-rubl-loc = buf_doc-line.road-tax
          road-tax-base-loc = buf_doc-line.road-tax / buf_trn-doc.base-rate * buf_trn-doc.base-scale.
      end.
      if road-tax-base-loc = ? then road-tax-base-loc = 0.
      if road-tax-rubl-loc = ? then road-tax-rubl-loc = 0.
      assign
        road-tax-cli-loc = ?.
      ASSIGN
        transport-base-loc = (if buf_doc-line.transport-base = ? then 0 else buf_doc-line.transport-base)
        transport-rubl-loc = (if buf_doc-line.transport-rubl = ? then 0 else buf_doc-line.transport-rubl)
        transport-cli-loc  = 0
        other-base-loc     = (if buf_doc-line.other-base     = ? then 0 else buf_doc-line.other-base)
        other-rubl-loc     = (if buf_doc-line.other-rubl     = ? then 0 else buf_doc-line.other-rubl)
        other-cli-loc      = 0
        vat-pc-loc         = (if buf_doc-line.vat-pc         = ? then 0 else buf_doc-line.vat-pc)
        slt-pc-loc         = (if buf_doc-line.slt-pc         = ? then 0 else buf_doc-line.slt-pc).
                              ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
            ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
      assign
        vat-cli-loc            = ?
        slt-cli-loc            = ?
        price-cli-with-tax-loc = ?.
   end.
   else do:
                                                for each in-vatp-parts where in-vatp-parts.out-code  = buf_doc-line.doc-code  and
                                      in-vatp-parts.obj-type  = buf_doc-line.obj-type  and
                                      in-vatp-parts.obj-code  = buf_doc-line.obj-code  and
                                      in-vatp-parts.artic     = buf_doc-line.artic     and
                                      in-vatp-parts.prod-type = buf_doc-line.prod-type and
                                      in-vatp-parts.prod-code = buf_doc-line.prod-code
                         use-index out-code no-lock:
          accumulate  in-vatp-parts.road-tax-base  * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.road-tax-rubl  * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.transport-base * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.transport-rubl * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.other-base     * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.other-rubl     * in-vatp-parts.fact-qnty (total)
                                                                                                              (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                      / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  / (100 + in-vatp-parts.vat-pc))  (total)
                                            (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                      / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  / (100 + in-vatp-parts.vat-pc))  (total)
                      .
      end.
      ASSIGN
        road-tax-base-loc   = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.road-tax-base  * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        road-tax-rubl-loc   = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.road-tax-rubl  * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        transport-base-loc  = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.transport-base * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        transport-rubl-loc  = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.transport-rubl * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        other-base-loc      = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.other-base     * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        other-rubl-loc      = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.other-rubl     * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
                                        vat-base-loc        = if buf_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / buf_doc-line.fact-qnty   else 0
        slt-base-loc        = if buf_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / buf_doc-line.fact-qnty   else 0
                vat-rubl-loc        = if buf_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / buf_doc-line.fact-qnty   else 0
        slt-rubl-loc        = if buf_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / buf_doc-line.fact-qnty   else 0
        vat-pc-loc          = (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  / (100 + in-vatp-parts.vat-pc)))
        slt-pc-loc          = (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                      / (100 + in-vatp-parts.slt-pc))).
      if road-tax-base-loc  = ? then road-tax-base-loc  = 0.
      if road-tax-rubl-loc  = ? then road-tax-rubl-loc  = 0.
      if transport-base-loc = ? then transport-base-loc = 0.
      if transport-rubl-loc = ? then transport-rubl-loc = 0.
      if other-base-loc     = ? then other-base-loc     = 0.
      if other-rubl-loc     = ? then other-rubl-loc     = 0.
      assign
        transport-cli-loc      = 0
        other-cli-loc          = 0
        road-tax-cli-loc       = ?
        vat-cli-loc            = ?
        slt-cli-loc            = ?
        price-cli-with-tax-loc = ?.
   end.
ASSIGN
          price-base-without-tax-loc = price-base-with-tax-loc - vat-base-loc - slt-base-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))
    price-rubl-without-tax-loc = price-rubl-with-tax-loc - vat-rubl-loc - slt-rubl-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))
.
          assign
            v-fact-qnty           = v-fact-qnty      + v-parts-fact-qnty
            v-vat-pc              = vat-pc-loc
            v-slt-pc              = slt-pc-loc
            v-sum-base            = v-sum-base       + (price-base-with-tax-loc * v-parts-fact-qnty)
            v-sum-rubl            = v-sum-rubl       + (price-rubl-with-tax-loc * v-parts-fact-qnty)
            v-vat-base            = v-vat-base       + (vat-base-loc            * v-parts-fact-qnty)
            v-vat-rubl            = v-vat-rubl       + (vat-rubl-loc            * v-parts-fact-qnty)
            v-slt-base            = v-slt-base       + (slt-base-loc            * v-parts-fact-qnty)
            v-slt-rubl            = v-slt-rubl       + (slt-rubl-loc            * v-parts-fact-qnty)
            v-road-tax-base       =  0
            v-road-tax-rubl       =  0
            v-excise-base         =  0
            v-excise-rubl         =  0
            v-transport-base      =  0
            v-transport-rubl      =  0
            v-other-base          =  0
            v-other-rubl          =  0
          .
    end.
  end.
end procedure.
define variable vss-include-info14 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure r-sale :
  define input parameter  p-doc-code          like ub.doc-line.doc-code          no-undo .
  define input parameter  p-artic             like ub.doc-line.artic             no-undo .
  define input parameter  p-prod-type         like ub.doc-line.prod-type         no-undo .
  define input parameter  p-prod-code         like ub.doc-line.prod-code         no-undo .
  define output parameter p-fact-qnty         like ub.ot-line.fact-qnty       no-undo .
  define output parameter p-vat-pc            like ub.doc-line.vat-pc         no-undo .
  define output parameter p-slt-pc            like ub.doc-line.slt-pc         no-undo .
  define output parameter p-sum-base          like ub.ot-line.sum-base        no-undo .
  define output parameter p-sum-rubl          like ub.ot-line.sum-rubl        no-undo .
  define output parameter p-vat-base          like ub.ot-line.vat-base        no-undo .
  define output parameter p-vat-rubl          like ub.ot-line.vat-rubl        no-undo .
  define output parameter p-slt-base          like ub.ot-line.slt-base        no-undo .
  define output parameter p-slt-rubl          like ub.ot-line.slt-rubl        no-undo .
  define output parameter p-road-tax-base     like ub.ot-line.road-tax-base   no-undo .
  define output parameter p-road-tax-rubl     like ub.ot-line.road-tax-rubl   no-undo .
  define output parameter p-transport-base    like ub.ot-line.transport-base  no-undo .
  define output parameter p-transport-rubl    like ub.ot-line.transport-rubl  no-undo .
  define output parameter p-other-base        like ub.ot-line.other-base      no-undo .
  define output parameter p-other-rubl        like ub.ot-line.other-rubl      no-undo .
  define output parameter p-excise-base       like ub.ot-line.excise-base     no-undo .
  define output parameter p-excise-rubl       like ub.ot-line.excise-rubl     no-undo .
  define variable vss-description as character no-undo initial "r-sale-01: обработка продажных цен товара".
  do
  on error undo, return error
  :
    define  variable price-rubl-with-tax-sale    like ub.doc-line.price-rubl no-undo.
    define  variable price-base-with-tax-sale    like ub.doc-line.price-base no-undo.
    define  variable price-rubl-without-tax-sale like ub.doc-line.price-rubl no-undo.
    define  variable price-base-without-tax-sale like ub.doc-line.price-base no-undo.
    define  variable vat-base-sale               like ub.doc-line.price-base no-undo.
    define  variable vat-rubl-sale               like ub.doc-line.price-rubl no-undo.
    define  variable vat-base-buyer              like ub.doc-line.price-base no-undo.
    define  variable vat-rubl-buyer              like ub.doc-line.price-rubl no-undo.
    define  variable slt-base-sale               like ub.doc-line.price-base no-undo.
    define  variable slt-rubl-sale               like ub.doc-line.price-rubl no-undo.
    define  variable road-tax-base-sale          like ub.doc-line.road-tax   no-undo.
    define  variable road-tax-rubl-sale          like ub.doc-line.road-tax   no-undo.
    define  variable excise-base-sale            like ub.doc-line.price-base no-undo.
    define  variable excise-rubl-sale            like ub.doc-line.price-rubl no-undo.
    define  variable discnt-base-sale            like ub.gds-dtl.discnt-base no-undo.
    define  variable discnt-rubl-sale            like ub.gds-dtl.discnt-rubl no-undo.
    define buffer out-vatp_gds-dtl     for ub.gds-dtl.
    define buffer buf_out-vatp_gds-dtl for ub.gds-dtl.
    define buffer out-vatp_parts       for ub.parts.
    define buffer out-vatp_sysconf     for ub.sysconf.
    define buffer out-vatp_doc-line    for ub.doc-line.
    define buffer out-vatp_goods       for ub.goods.
    define buffer out-vatp_trn-doc     for ub.trn-doc.
    define buffer out-vatp_doc-attr    for ub.doc-attr.
    define variable varprice-base-cons      like ub.doc-line.price-base initial 0.00 no-undo.
    define variable varprice-rubl-cons      like ub.doc-line.price-rubl initial 0.00 no-undo.
    define variable varfrm-cnsv-type         as   character                           no-undo.
    define variable varfrm-cnsv              as   character                           no-undo.
    define variable varroot-node             as   integer                             no-undo.
    define variable varempty-scale           as   logical                             no-undo.
    define variable varis-cons-parts-have    as   logical                             no-undo.
    define variable varsum-base-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-factovp  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-base-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-docovp   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-factovp  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-docovp   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varfact-qnty             like ub.parts.fact-qnty                  no-undo.
    define variable varcons-qnty             like ub.parts.fact-qnty                  no-undo.
    define variable varis-one-gds-dtl        as   logical                             no-undo.
    define variable varcurprice-base         like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurprice-rubl         like ub.gds-dtl.price-base               no-undo.
    define variable varcurdiscnt-base        like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurdiscnt-rubl        like ub.gds-dtl.price-base               no-undo.
    define variable varoutvprb               as   character                           no-undo.
    define variable out-vatp-have-vat-slt    as   logical initial yes                 no-undo.
    define buffer   in-vatp-trn-doco  for ub.trn-doc .
    define buffer   in-vatp-partso    for ub.parts   .
    define buffer   in-vatp-doco      for ub.trn-doc .
    define buffer   in-vatp-goodso    for ub.goods   .
    define buffer   in-vatp-sysconfo  for ub.sysconf .
    define buffer   in-vatp_doc-attro for ub.doc-attr.
    define variable in-vatp-have-vat-slto       as   logical initial yes    no-undo.
    define variable vat-pc-loco                 like ub.doc-line.vat-pc     no-undo.
    define variable varinvprbo                  as   character              no-undo.
    define variable slt-pc-loco                 like ub.doc-line.slt-pc     no-undo.
    define variable cli-base-rateo              as   decimal                no-undo.
    define variable price-rubl-with-tax-loco    like ub.doc-line.price-rubl no-undo.
    define variable price-base-with-tax-loco    like ub.doc-line.price-base no-undo.
    define variable price-cli-with-tax-loco     like ub.doc-line.price-cli  no-undo.
    define variable price-rubl-without-tax-loco like ub.doc-line.price-rubl no-undo.
    define variable price-base-without-tax-loco like ub.doc-line.price-base no-undo.
    define variable price-cli-without-tax-loco  like ub.doc-line.price-base no-undo.
    define variable vat-base-loco               like ub.doc-line.price-base no-undo.
    define variable vat-rubl-loco               like ub.doc-line.price-rubl no-undo.
    define variable vat-cli-loco                like ub.doc-line.price-rubl no-undo.
    define variable slt-base-loco               like ub.doc-line.price-base no-undo.
    define variable slt-rubl-loco               like ub.doc-line.price-rubl no-undo.
    define variable slt-cli-loco                like ub.doc-line.price-rubl no-undo.
    define variable road-tax-base-loco          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-rubl-loco          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-cli-loco           like ub.doc-line.road-tax   no-undo.
    define variable transport-base-loco         like ub.doc-line.price-base no-undo.
    define variable transport-rubl-loco         like ub.doc-line.price-rubl no-undo.
    define variable transport-cli-loco          like ub.doc-line.price-rubl no-undo.
    define variable other-base-loco             like ub.doc-line.price-base no-undo.
    define variable other-rubl-loco             like ub.doc-line.price-rubl no-undo.
    define variable other-cli-loco              like ub.doc-line.price-rubl no-undo.
    define variable exch-rate-cli-loco          like ub.trn-doc.exch-rate   no-undo.
    define variable varinvatp-envdo             as   character              no-undo.
    define variable varinvatp-typeo             as   character              no-undo.
    define variable v-gds-dtl-fact-qnty as decimal no-undo .
    define buffer buf_gds-dtl  for ub.gds-dtl .
    define buffer buf_goods    for ub.goods .
    define buffer buf_trn-doc  for ub.trn-doc .
    define buffer buf_doc-line for ub.doc-line .
    find first buf_doc-line no-lock
      where buf_doc-line.doc-code  = p-doc-code
        and buf_doc-line.artic     = p-artic
        and buf_doc-line.prod-type = p-prod-type
        and buf_doc-line.prod-code = p-prod-code
      no-error .
    if not available buf_doc-line then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info15 skip
        "Ошибка задания входных параметров" skip
        "Не найдена строка документа" skip
        "Документ" p-doc-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        view-as alert-box error .
      undo, return error .
    end.
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = buf_doc-line.doc-code
      no-error .
    if not available buf_trn-doc then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info15 skip
        "Не найден документ" skip
        "Документ" p-doc-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        view-as alert-box error .
      undo, return error .
    end.
    for each buf_gds-dtl no-lock
      where buf_gds-dtl.doc-code  = buf_doc-line.doc-code
        and buf_gds-dtl.artic     = buf_doc-line.artic
        and buf_gds-dtl.prod-type = buf_doc-line.prod-type
        and buf_gds-dtl.prod-code = buf_doc-line.prod-code
    on error undo, return error
    :
        if buf_trn-doc.doc-type <> 'инв':U
        then do:
            if buf_trn-doc.doc-type = 'при':U
            or buf_trn-doc.doc-type = 'возврат':U
            then do:
                assign
                    v-gds-dtl-fact-qnty = buf_gds-dtl.fact-qnty
                .
            end.
            else do:
                assign
                    v-gds-dtl-fact-qnty = - buf_gds-dtl.fact-qnty
                .
            end.
        end.
        else do:
            assign
                v-gds-dtl-fact-qnty = buf_gds-dtl.doc-qnty
            .
        end.
        if v-gds-dtl-fact-qnty <> 0
        then do:
if buf_trn-doc.ext-doc-type = 'ot':U or
   buf_trn-doc.ext-doc-type = ?                 then do:
  assign
   out-vatp-have-vat-slt = yes.
end.
else do:
  find first out-vatp_doc-attr no-lock
    where out-vatp_doc-attr.doc-code  = buf_trn-doc.doc-code
      and out-vatp_doc-attr.attr-code = 'envd':U
      no-error .
  if not available out-vatp_doc-attr then do:
    assign
      out-vatp-have-vat-slt = yes.
  end.
  else do:
     out-vatp-have-vat-slt = no.
  end.
end.
find first out-vatp_goods where out-vatp_goods.artic     = buf_doc-line.artic     and
                                   out-vatp_goods.prod-type = buf_doc-line.prod-type and
                                   out-vatp_goods.prod-code = buf_doc-line.prod-code no-lock.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  buf_doc-line.artic
  ,input  buf_doc-line.prod-type
  ,input  buf_doc-line.prod-code
  ,output varroot-node
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении корневого признака товара" skip
    "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtat in g#library
  (input  varroot-node
  ,input  'empty-scale=request'
  ,output varempty-scale
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении атрибута признака" skip
    "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
    "Признак" varroot-node skip
    "Запрашивался атрибут" "empty-scale=request" skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varoutvprb
  )  .
if varoutvprb = "base":u then do:
  assign
        road-tax-base-sale    =  (if buf_doc-line.road-tax = ? then 0 else buf_doc-line.road-tax * 1)
    excise-base-sale      =  (if buf_doc-line.excise   = ? then 0 else buf_doc-line.excise   * 1)
  .
end.
else do:
  assign
        road-tax-base-sale    =  (if buf_doc-line.road-tax = ? then 0 else buf_doc-line.road-tax / buf_trn-doc.base-rate * buf_trn-doc.base-scale)
    excise-base-sale      =  (if buf_doc-line.excise   = ? then 0 else buf_doc-line.excise   / buf_trn-doc.base-rate * buf_trn-doc.base-scale)
  .
end.
if varoutvprb = "rubl":u then do:
  assign
        road-tax-rubl-sale    = (if buf_doc-line.road-tax = ? then 0 else buf_doc-line.road-tax * 1)
    excise-rubl-sale      = (if buf_doc-line.excise   = ? then 0 else buf_doc-line.excise   * 1) .
end.
else do:
  assign
        road-tax-rubl-sale    = (if buf_doc-line.road-tax = ? then 0 else buf_doc-line.road-tax * buf_trn-doc.base-rate / buf_trn-doc.base-scale)
    excise-rubl-sale      = (if buf_doc-line.excise   = ? then 0 else buf_doc-line.excise   * buf_trn-doc.base-rate / buf_trn-doc.base-scale) .
end.
assign
  varis-cons-parts-have =  no.
assign
  varfact-qnty       = 0
  varcons-qnty       = 0
  varprice-base-cons = 0
  varprice-rubl-cons = 0.
find first out-vatp_doc-line where
           out-vatp_doc-line.doc-code   = buf_trn-doc.doc-code
       and out-vatp_doc-line.artic      = buf_doc-line.artic
       and out-vatp_doc-line.prod-type  = buf_doc-line.prod-type
       and out-vatp_doc-line.prod-code  = buf_doc-line.prod-code no-lock no-error.
if available out-vatp_doc-line           and
  (out-vatp_doc-line.status_ = 'запрос':U or out-vatp_goods.gds-type = 'у':U) then do:
  assign
    varfact-qnty = out-vatp_doc-line.fact-qnty.
end.
else do:
  for each out-vatp_parts where out-vatp_parts.out-code   = buf_trn-doc.doc-code
                               and out-vatp_parts.obj-type   = buf_trn-doc.obj-type
                               and out-vatp_parts.obj-code   = buf_trn-doc.obj-code
                               and out-vatp_parts.artic      = buf_doc-line.artic
                               and out-vatp_parts.prod-type  = buf_doc-line.prod-type
                               and out-vatp_parts.prod-code  = buf_doc-line.prod-code no-lock :
    if out-vatp_parts.purch-code = 2 then do:
assign
  price-rubl-with-tax-loco = out-vatp_parts.price-rubl
  price-base-with-tax-loco = out-vatp_parts.price-base
.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprbo
  )  .
  if out-vatp_parts.out-code = 'free-zone':U     or
     out-vatp_parts.out-code = 'out-zone':U   or
     out-vatp_parts.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-slto = yes.
  end.
  else do:
    find first in-vatp_doc-attro no-lock
      where in-vatp_doc-attro.doc-code  = out-vatp_parts.out-code
        and in-vatp_doc-attro.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attro then do:
      assign
        in-vatp-have-vat-slto = yes.
    end.
    else do:
         in-vatp-have-vat-slto = no.
    end.
  end.
  assign
   price-cli-with-tax-loco = out-vatp_parts.price-cli
   cli-base-rateo          = out-vatp_parts.cli-base-rate.
  ASSIGN   road-tax-base-loco  = (if out-vatp_parts.road-tax-base  = ? then 0 else out-vatp_parts.road-tax-base)
           road-tax-rubl-loco  = (if out-vatp_parts.road-tax-rubl  = ? then 0 else out-vatp_parts.road-tax-rubl).
  ASSIGN  transport-base-loco = (if out-vatp_parts.transport-base = ? then 0 else out-vatp_parts.transport-base)
          transport-rubl-loco = (if out-vatp_parts.transport-rubl = ? then 0 else out-vatp_parts.transport-rubl)
          other-base-loco     = (if out-vatp_parts.other-base     = ? then 0 else out-vatp_parts.other-base)
          other-rubl-loco     = (if out-vatp_parts.other-rubl     = ? then 0 else out-vatp_parts.other-rubl)
          vat-pc-loco         = (if out-vatp_parts.vat-pc         = ? then 0 else out-vatp_parts.vat-pc)
          slt-pc-loco         = (if out-vatp_parts.slt-pc         = ? then 0 else out-vatp_parts.slt-pc).
          ASSIGN   slt-base-loco    = (if in-vatp-have-vat-slto = no then 0 else (price-base-with-tax-loco - ((if road-tax-base-loco  = ? then 0 else road-tax-base-loco) + (if transport-base-loco = ? then 0 else transport-base-loco) + (if other-base-loco = ? then 0 else other-base-loco)))                           * slt-pc-loco / (100 + slt-pc-loco))                        vat-base-loco    = (if in-vatp-have-vat-slto = no then 0 else (price-base-with-tax-loco - ((if road-tax-base-loco  = ? then 0 else road-tax-base-loco) + (if transport-base-loco = ? then 0 else transport-base-loco) + (if other-base-loco = ? then 0 else other-base-loco))) * (1 - slt-pc-loco / (100 + slt-pc-loco)) * vat-pc-loco / (100 + vat-pc-loco)).
    ASSIGN   slt-rubl-loco    = (if in-vatp-have-vat-slto = no then 0 else (price-rubl-with-tax-loco - ((if road-tax-rubl-loco  = ? then 0 else road-tax-rubl-loco) + (if transport-rubl-loco = ? then 0 else transport-rubl-loco) + (if other-rubl-loco = ? then 0 else other-rubl-loco)))                           * slt-pc-loco / (100 + slt-pc-loco))                        vat-rubl-loco    = (if in-vatp-have-vat-slto = no then 0 else (price-rubl-with-tax-loco - ((if road-tax-rubl-loco  = ? then 0 else road-tax-rubl-loco) + (if transport-rubl-loco = ? then 0 else transport-rubl-loco) + (if other-rubl-loco = ? then 0 else other-rubl-loco))) * (1 - slt-pc-loco / (100 + slt-pc-loco)) * vat-pc-loco / (100 + vat-pc-loco)).
  assign
    exch-rate-cli-loco = (out-vatp_parts.price-rubl - transport-rubl-loco - other-rubl-loco - road-tax-rubl-loco - (if out-vatp_parts.vat-type <> 'в т. ч.':U then vat-rubl-loco else 0) - (if out-vatp_parts.slt-type <> 'в т. ч.':U then slt-rubl-loco else 0)) / out-vatp_parts.price-cli .
  assign
    slt-cli-loco        = slt-rubl-loco       / exch-rate-cli-loco
    vat-cli-loco        = vat-rubl-loco       / exch-rate-cli-loco
    road-tax-cli-loco   = road-tax-rubl-loco  / exch-rate-cli-loco
    transport-cli-loco  = 0
    other-cli-loco      = 0
  .
ASSIGN
          price-base-without-tax-loco = price-base-with-tax-loco - vat-base-loco - slt-base-loco - ((if road-tax-base-loco  = ? then 0 else road-tax-base-loco) + (if transport-base-loco = ? then 0 else transport-base-loco) + (if other-base-loco = ? then 0 else other-base-loco))
    price-rubl-without-tax-loco = price-rubl-with-tax-loco - vat-rubl-loco - slt-rubl-loco - ((if road-tax-rubl-loco  = ? then 0 else road-tax-rubl-loco) + (if transport-rubl-loco = ? then 0 else transport-rubl-loco) + (if other-rubl-loco = ? then 0 else other-rubl-loco))
.
      assign
        varprice-base-cons = varprice-base-cons + (price-base-with-tax-loco - (if road-tax-base-loco = ? then 0 else road-tax-base-loco))* out-vatp_parts.fact-qnty
        varprice-rubl-cons = varprice-rubl-cons + (price-rubl-with-tax-loco - (if road-tax-rubl-loco = ? then 0 else road-tax-rubl-loco))* out-vatp_parts.fact-qnty.
      assign
        varis-cons-parts-have = yes
        varcons-qnty          = varcons-qnty + out-vatp_parts.fact-qnty.
    end.
    assign
      varfact-qnty = varfact-qnty + out-vatp_parts.fact-qnty.
  end.
end.
assign
  varprice-base-cons = varprice-base-cons / varcons-qnty
  varprice-rubl-cons = varprice-rubl-cons / varcons-qnty.
if varprice-base-cons = ? then do:
  assign
    varprice-base-cons = 0.
end.
if varprice-rubl-cons = ? then do:
  assign
    varprice-rubl-cons = 0.
end.
assign
    slt-base-sale               = (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc)
  vat-base-buyer              = (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc)
  discnt-base-sale            = buf_gds-dtl.discnt-base
  price-base-with-tax-sale    = (buf_gds-dtl.price-base - buf_gds-dtl.discnt-base)
    slt-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc)
  vat-rubl-buyer              = (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc)
  discnt-rubl-sale            = buf_gds-dtl.discnt-rubl
  price-rubl-with-tax-sale    = (buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl)
  .
if buf_trn-doc.doc-type = 'инв':U then do:
  assign
    varfact-qnty = buf_gds-dtl.doc-qnty.
end.
else do:
  assign
    varfact-qnty = buf_gds-dtl.fact-qnty.
end.
if varis-cons-parts-have = no then do:
  assign
        vat-base-sale               = (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc)
        vat-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc).
end.
else do:
  if buf_trn-doc.doc-type = 'инв':U then do:
    assign
            vat-base-sale               = (if out-vatp-have-vat-slt = no then 0 else (((buf_gds-dtl.price-base - buf_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale - varprice-base-cons) * buf_doc-line.cons-vat-pc / (100 + buf_doc-line.cons-vat-pc) * buf_gds-dtl.doc-qnty * varcons-qnty / varfact-qnty + ((buf_gds-dtl.price-base - buf_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc) * buf_gds-dtl.doc-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
            vat-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else (((buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale - varprice-rubl-cons) * buf_doc-line.cons-vat-pc / (100 + buf_doc-line.cons-vat-pc) * buf_gds-dtl.doc-qnty * varcons-qnty / varfact-qnty + ((buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc) * buf_gds-dtl.doc-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
     .
  end.
  else do:
    assign
            vat-base-sale               = (if out-vatp-have-vat-slt = no then 0 else (((buf_gds-dtl.price-base - buf_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale - varprice-base-cons) * buf_doc-line.cons-vat-pc / (100 + buf_doc-line.cons-vat-pc) * buf_gds-dtl.fact-qnty * varcons-qnty / varfact-qnty + ((buf_gds-dtl.price-base - buf_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - varprice-base-cons) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc) * buf_gds-dtl.fact-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
            vat-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else (((buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale - varprice-rubl-cons) * buf_doc-line.cons-vat-pc / (100 + buf_doc-line.cons-vat-pc) * buf_gds-dtl.fact-qnty * varcons-qnty / varfact-qnty + ((buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - varprice-rubl-cons) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc) * buf_gds-dtl.fact-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
     .
  end.
end.
assign
price-base-without-tax-sale = price-base-with-tax-sale - vat-base-sale - slt-base-sale - road-tax-base-sale
price-rubl-without-tax-sale = price-rubl-with-tax-sale - vat-rubl-sale - slt-rubl-sale - road-tax-rubl-sale.
            ASSIGN
                p-fact-qnty           = p-fact-qnty     + v-gds-dtl-fact-qnty
                p-sum-base            = p-sum-base      + price-base-with-tax-sale  * v-gds-dtl-fact-qnty
                p-sum-rubl            = p-sum-rubl      + price-rubl-with-tax-sale  * v-gds-dtl-fact-qnty
                p-vat-base            = p-vat-base      + vat-base-sale             * v-gds-dtl-fact-qnty
                p-vat-rubl            = p-vat-rubl      + vat-rubl-sale             * v-gds-dtl-fact-qnty
                p-slt-base            = p-slt-base      + slt-base-sale             * v-gds-dtl-fact-qnty
                p-slt-rubl            = p-slt-rubl      + slt-rubl-sale             * v-gds-dtl-fact-qnty
                p-road-tax-base       = p-road-tax-base + road-tax-base-sale        * v-gds-dtl-fact-qnty
                p-road-tax-rubl       = p-road-tax-rubl + road-tax-rubl-sale        * v-gds-dtl-fact-qnty
                p-excise-base         = p-excise-base   + excise-base-sale          * v-gds-dtl-fact-qnty
                p-excise-rubl         = p-excise-rubl   + excise-rubl-sale          * v-gds-dtl-fact-qnty
                p-other-base          = p-other-base    + discnt-base-sale          * v-gds-dtl-fact-qnty
                p-other-rubl          = p-other-rubl    + discnt-rubl-sale          * v-gds-dtl-fact-qnty
            .
        end.
    end.
    assign
        p-transport-base      = 0
        p-transport-rubl      = 0
        p-vat-pc              = buf_doc-line.vat-pc
        p-slt-pc              = buf_doc-line.slt-pc
    .
  end.
  if p-fact-qnty      = ?
  or p-vat-pc         = ?
  or p-slt-pc         = ?
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
      vss-include-info15 skip
      "Получены неопределенные значения" skip
      "Документ" p-doc-code skip
      "Артикул" p-artic p-prod-type p-prod-code skip
      "fact-qnty     " p-fact-qnty      skip
      "vat-pc        " p-vat-pc         skip
      "slt-pc        " p-slt-pc         skip
      "sum-base      " p-sum-base       skip
      "sum-rubl      " p-sum-rubl       skip
      "vat-base      " p-vat-base       skip
      "vat-rubl      " p-vat-rubl       skip
      "slt-base      " p-slt-base       skip
      "slt-rubl      " p-slt-rubl       skip
      "road-tax-base " p-road-tax-base  skip
      "road-tax-rubl " p-road-tax-rubl  skip
      "transport-base" p-transport-base skip
      "transport-rubl" p-transport-rubl skip
      "other-base    " p-other-base     skip
      "other-rubl    " p-other-rubl     skip
      "excise-base   " p-excise-base    skip
      "excise-rubl   " p-excise-rubl    skip
      view-as alert-box error .
    undo, return error .
  end.
end procedure.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define  shared variable RepPathName        as character no-undo .
define  shared variable PrintRubl          as logical   no-undo .
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-pl-gds no-undo   like ub.pl-gds .
define temp-table temp-prt-obj no-undo   field prt-code         like ub.prt-obj.prt-code     field price-sale       like ub.prt-obj.price-sale   field fact-qnty        like ub.prt-obj.fact-qnty    field price-list-qnty  like ub.prt-obj.fact-qnty    field is-term          as logical   field prt-obj-recid    as recid     field price-list-recid as recid     index xpk is primary unique prt-code   index xie1 is-term .
procedure prdoclib-process-goods :
  define input  parameter p-obj-type          as character no-undo .
  define input  parameter p-obj-code          as integer   no-undo .
  define input  parameter p-artic             as character no-undo .
  define input  parameter p-prod-type         as character no-undo .
  define input  parameter p-prod-code         as integer   no-undo .
  define input  parameter p-check-price-list  as logical   no-undo .
  define input  parameter p-check-price-parts as logical   no-undo .
  define input  parameter p-doc-num           as character no-undo .
  define input  parameter p-fact-date         as date      no-undo .
  define input  parameter p-corr-user-db-num  as integer   no-undo .
  define input  parameter p-corr-user-name    as character no-undo .
  define input  parameter p-corr-date         as date      no-undo .
  define input  parameter p-corr-time         as integer   no-undo .
  define input  parameter p-corr-time-str     as character no-undo .
  define output parameter p-gds-obj-fact-qnty as decimal   no-undo .
  define variable vss-description as character no-undo initial "prdoclib-process-goods-01: обработка продажных цен товара".
  define buffer buf_gds-obj      for ub.gds-obj .
  define buffer buf_prt-obj      for ub.prt-obj .
  define buffer buf_price-list   for ub.price-list .
  define buffer buf_bar-code     for ub.bar-code .
  define buffer buf_temp-prt-obj for temp-prt-obj .
  define variable v-gds-code             like ub.goods.gds-code    no-undo .
  define variable v-root-node            like ub.prt-obj.prt-code  no-undo .
  define variable v-root-b-code          like ub.bar-code.b-code   no-undo .
  define variable v-total-term-fact-qnty like ub.prt-obj.fact-qnty no-undo .
  define variable v-total-fact-sale      like ub.gds-obj.fact-sale no-undo .
  define variable v-doc-num     like ub.price-list.doc-num    no-undo .
  define variable v-price-sale  like ub.price-list.price-sale no-undo .
  define variable v-road-tax    like ub.price-list.road-tax   no-undo .
  define variable v-excise      like ub.price-list.excise     no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,output v-root-node
  )  .
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdscr in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,input  v-root-node
  ,buffer buf_gds-obj
  ,buffer buf_prt-obj
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info20 skip
        "Ошибка при начале товародвижения товара на объекте" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    find current buf_gds-obj  exclusive-lock .
    find current buf_prt-obj  exclusive-lock .
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,output v-gds-code
  )  .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  v-gds-code
  ,input  v-root-node
  ,output v-root-b-code
  )  .
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  v-root-b-code
  ,input  v-root-b-code
  ,input  0
  ,output v-doc-num
  ,output v-price-sale
  ,output v-road-tax
  ,output v-excise
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info20 skip
        "Ошибка при определении цены признака на объекте" skip
        "Объект"     p-obj-type p-obj-code  skip
        "Бар-код"    v-root-b-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    run prdoclib-init-temp-prt-obj in this-procedure
      (input p-obj-type
      ,input p-obj-code
      ,input p-artic
      ,input p-prod-type
      ,input p-prod-code
      ,input v-price-sale
      ) .
    find first buf_price-list no-lock
      where buf_price-list.doc-num    = v-doc-num
        and buf_price-list.price-type = ""
        and buf_price-list.b-code     = v-root-b-code
      .
    find first buf_temp-prt-obj
      where buf_temp-prt-obj.prt-code = v-root-node
      .
    assign
      buf_temp-prt-obj.price-sale       = v-price-sale
      buf_temp-prt-obj.price-list-qnty  = buf_price-list.doc-qnty
      buf_temp-prt-obj.price-list-recid = recid(buf_price-list)
    .
    define variable l-empty-scale as logical no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtat in g#library
  (input  v-root-node
  ,input  'empty-scale=request'
  ,output l-empty-scale
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info20 skip
        "Ошибка при определении атрибута шкалы" skip
        "Код признака" v-root-node skip
        "Запрашивался атрибут" "empty-scale=request" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    assign
      v-total-term-fact-qnty = 0
      v-total-fact-sale      = 0
    .
    if l-empty-scale = true
    then do:
      for each buf_price-list
        where buf_price-list.doc-num    = v-doc-num
          and buf_price-list.main-price = false
          and buf_price-list.artic      = p-artic
          and buf_price-list.prod-type  = p-prod-type
          and buf_price-list.prod-code  = p-prod-code
          and buf_price-list.price-type = ""
      on error undo, return error return-value
      :
        if buf_price-list.doc-qnty <> ? and p-check-price-parts
        then do:
          message
            vss-workfile vss-revision vss-description skip
            vss-include-info20 skip
            "Ошибка при закрытии переоценки" skip
            "Для неосновного бар-кода товара с пустой шкалой" skip
            "указано количество отличное от ?" skip
            "Переоценка" v-doc-num skip
            "Бар-код" buf_price-list.b-code skip
            "Артикул" p-artic p-prod-type p-prod-code skip
            "Количество" buf_price-list.doc-qnty skip
            view-as alert-box error .
          undo, return error .
        end.
      end.
    end.
    if l-empty-scale = false
    then do:
      define variable v-unit-base like ub.goods.unit-base no-undo .
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run unitbase in g#library
  (input  v-gds-code
  ,output v-unit-base
  ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info20 skip
          "Ошибка при определении базовой единицы измерения товара" skip
          "Код товара" v-gds-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
      for each buf_price-list
        where buf_price-list.doc-num    = v-doc-num
          and buf_price-list.main-price = false
          and buf_price-list.artic      = p-artic
          and buf_price-list.prod-type  = p-prod-type
          and buf_price-list.prod-code  = p-prod-code
          and buf_price-list.price-type = ""
      on error undo, return error
      :
        if buf_price-list.doc-qnty = ?
        then do:
          find first buf_bar-code no-lock
            where buf_bar-code.b-code = buf_price-list.b-code
            no-error .
          if  available buf_bar-code
          and buf_bar-code.unit-cli = v-unit-base
          then do:
            message
              vss-workfile vss-revision vss-description skip
              vss-include-info20 skip
              "Ошибка при закрытии переоценки" skip
              "Не задано количество для бар-кода с основной единицей измерения" skip
              "Переоценка" v-doc-num skip
              "Бар-код" buf_price-list.b-code skip
              "Артикул" p-artic p-prod-type p-prod-code skip
              "Количество" buf_price-list.doc-qnty skip
              "Основная единица измерения" v-unit-base skip
              "Единица измерения бар-кода" buf_bar-code.unit-cli skip
              view-as alert-box error .
            undo, return error .
          end.
          next .
        end.
        find first buf_bar-code no-lock
          where buf_bar-code.b-code = buf_price-list.b-code
          no-error .
        if not available buf_bar-code
        then do:
          message
            vss-workfile vss-revision vss-description skip
            vss-include-info20 skip
            "В переоценке задан несуществующий бар-код" skip
            "Переоценка" v-doc-num skip
            "Артикул" p-artic p-prod-type p-prod-code skip
            "Бар-код" buf_price-list.b-code skip
            view-as alert-box error .
          undo, return error .
        end.
        if buf_bar-code.in-code <> ""
        or buf_bar-code.part-code <> ""
        then do:
          message
            vss-workfile vss-revision vss-description skip
            vss-include-info20 skip
            "В переоценке задан бар-код партии" skip
            "Данная версия системы не рассчитана на работу со специальными ценами по партиям" skip
            "Переоценка" v-doc-num skip
            "Бар-код" buf_price-list.b-code skip
            "Артикул" p-artic p-prod-type p-prod-code skip
            "Код ПН" buf_bar-code.in-code buf_bar-code.part-code skip
            view-as alert-box error .
          undo, return error .
        end.
        if buf_bar-code.node-code <> v-root-node
        then do:
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtobjcr in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,input  buf_bar-code.node-code
  ,buffer buf_prt-obj
  ) no-error .
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              vss-include-info20 skip
              "Невозможно найти prt-obj" skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error .
          end.
          run prdoclib-create-temp-prt-obj in this-procedure
            (input  v-price-sale
            ,buffer buf_prt-obj
            ,buffer buf_temp-prt-obj
            ).
          assign
            buf_temp-prt-obj.price-sale       = buf_price-list.price-sale
            buf_temp-prt-obj.price-list-qnty  = buf_price-list.doc-qnty
            buf_temp-prt-obj.price-list-recid = recid(buf_price-list)
          .
        end.
      end.
      for each buf_temp-prt-obj
        where buf_temp-prt-obj.is-term = true
      :
        if buf_temp-prt-obj.price-list-recid <> ?
        then do:
          assign
            v-total-term-fact-qnty = v-total-term-fact-qnty
                                  + buf_temp-prt-obj.fact-qnty
            v-total-fact-sale = v-total-fact-sale
                              + buf_temp-prt-obj.fact-qnty * buf_temp-prt-obj.price-sale
          .
        end.
        if p-check-price-list = true
        then do:
          if buf_temp-prt-obj.price-list-recid = ?
          or buf_temp-prt-obj.fact-qnty = buf_temp-prt-obj.price-list-qnty
          then do:
          end.
          else do:
            message
              vss-workfile vss-revision vss-description skip
              vss-include-info20 skip
              "Ошибка при закрытии переоценки" skip
              "Несовпадают текущие количества по признаку" skip
              "и количество признака в переоценке" skip
              "Переоценка" v-doc-num skip
              "Артикул" p-artic p-prod-type p-prod-code skip
              "Код признака" buf_temp-prt-obj.prt-code skip
              "Количество по признаку" buf_temp-prt-obj.fact-qnty skip
              "Количество по переоценке" buf_temp-prt-obj.price-list-qnty skip
              "Корень шкалы товара" v-root-node skip
              view-as alert-box error .
            undo, return error .
          end.
        end.
      end.
    end.
    find first buf_temp-prt-obj
      where buf_temp-prt-obj.prt-code = v-root-node
      .
    assign
      buf_temp-prt-obj.fact-qnty = buf_temp-prt-obj.fact-qnty
                                  - v-total-term-fact-qnty
    .
    if p-check-price-list = true
    then do:
      if buf_temp-prt-obj.fact-qnty <> buf_temp-prt-obj.price-list-qnty and p-check-price-parts
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info20 skip
          "Ошибка при закрытии переоценки" skip
          "Несовпадают текущие количества по корневому признаку" skip
          "и количество признака в переоценке" skip
          "Переоценка" v-doc-num skip
          "Артикул" p-artic p-prod-type p-prod-code skip
          "Код признака" buf_temp-prt-obj.prt-code skip
          "Количество по признаку" buf_temp-prt-obj.fact-qnty skip
          "Количество по переоценке" buf_temp-prt-obj.price-list-qnty skip
          view-as alert-box error .
        undo, return error .
      end.
    end.
    assign
      v-total-fact-sale = v-total-fact-sale
                        + buf_temp-prt-obj.fact-qnty * buf_temp-prt-obj.price-sale
    .
    if v-total-fact-sale = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info20 skip
        "Ошибка при вычислении суммы в продажных ценах" skip
        "Получено неопределенное значение" skip
        "Переоценка" v-doc-num skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "Код признака" buf_temp-prt-obj.prt-code skip
        "Сумма в продажных ценах" v-total-fact-sale skip
        view-as alert-box error .
      undo, return error .
    end.
    define variable v-old-fact-qnty     as decimal   no-undo .
    define variable v-old-fact-cli-qnty as decimal   no-undo .
    define variable v-old-fact-base     as decimal   no-undo .
    define variable v-old-fact-rubl     as decimal   no-undo .
    define variable v-old-fact-sale     as decimal   no-undo .
    assign
      v-old-fact-qnty     = buf_gds-obj.fact-qnty
      v-old-fact-cli-qnty = buf_gds-obj.fact-cli-qnty
      v-old-fact-base     = buf_gds-obj.fact-base
      v-old-fact-rubl     = buf_gds-obj.fact-rubl
      v-old-fact-sale     = buf_gds-obj.fact-sale
    .
    assign
      buf_gds-obj.price-sale = v-price-sale
      buf_gds-obj.fact-sale  = v-total-fact-sale
    .
    define variable v-corr-date as date      no-undo .
    define variable v-corr-time as integer   no-undo .
    run cur-time in this-procedure
      (output v-corr-date
      ,output v-corr-time
      ) .
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gohist in g#library
  (input  buf_gds-obj.obj-type
  ,input  buf_gds-obj.obj-code
  ,input  buf_gds-obj.gds-code
  ,input  'close':U
  ,input  buf_gds-obj.fact-qnty
  ,input  buf_gds-obj.fact-cli-qnty
  ,input  buf_gds-obj.fact-base
  ,input  buf_gds-obj.fact-rubl
  ,input  buf_gds-obj.fact-sale
  ,input  v-old-fact-qnty
  ,input  v-old-fact-cli-qnty
  ,input  v-old-fact-base
  ,input  v-old-fact-rubl
  ,input  v-old-fact-sale
  ,input  'price-doc':U
  ,input  p-doc-num
  ,input  p-fact-date
  ,input  p-corr-user-db-num
  ,input  p-corr-user-name
  ,input  p-corr-date
  ,input  p-corr-time
  ,input  p-corr-time-str
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при создании истории по товару на объекте" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    assign
      p-gds-obj-fact-qnty = buf_gds-obj.fact-qnty
    .
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if  buf_gds-obj.first-doc <> ?
and buf_gds-obj.first-doc > p-fact-date then do:
  assign
    buf_gds-obj.first-doc  = p-fact-date
  .
end.
if  buf_gds-obj.last-doc <> ?
and buf_gds-obj.last-doc < p-fact-date then do:
  assign
    buf_gds-obj.last-doc   = p-fact-date
  .
end.
    for each buf_temp-prt-obj
    ,first buf_prt-obj exclusive-lock
      where recid(buf_prt-obj) = buf_temp-prt-obj.prt-obj-recid
    on error undo, return error return-value
    :
      assign
        buf_prt-obj.price-sale = buf_temp-prt-obj.price-sale
      .
    end.
  end.
end procedure.
procedure prdoclib-clear-temp-prt-obj :
  define buffer buf_temp-prt-obj for temp-prt-obj .
  do
  on error undo, return error return-value
  :
    for each buf_temp-prt-obj
    on error undo, return error return-value
    :
      delete buf_temp-prt-obj .
    end.
  end.
end procedure.
procedure prdoclib-create-temp-prt-obj :
  define input parameter  p-root-price-sale like ub.price-list.price-sale no-undo .
  define parameter buffer buf_prt-obj       for ub.prt-obj .
  define parameter buffer buf_temp-prt-obj  for temp-prt-obj .
  define buffer buf_gds-prt for ub.gds-prt .
  do
  on error undo, return error return-value
  :
    find first buf_temp-prt-obj
      where buf_temp-prt-obj.prt-code = buf_prt-obj.prt-code
      no-error .
    if not available buf_temp-prt-obj
    then do:
      create buf_temp-prt-obj .
      assign
        buf_temp-prt-obj.prt-code         = buf_prt-obj.prt-code
        buf_temp-prt-obj.price-sale       = ?
        buf_temp-prt-obj.fact-qnty        = buf_prt-obj.fact-qnty
        buf_temp-prt-obj.price-list-qnty  = ?
        buf_temp-prt-obj.prt-obj-recid    = recid(buf_prt-obj)
        buf_temp-prt-obj.price-list-recid = ?
      .
      find first buf_gds-prt no-lock
        where buf_gds-prt.node-code = buf_temp-prt-obj.prt-code
        .
      assign
        buf_temp-prt-obj.is-term = buf_gds-prt.is-term
      .
      if buf_temp-prt-obj.is-term
      then do:
        assign
          buf_temp-prt-obj.price-sale = p-root-price-sale
        .
      end.
    end.
  end.
end procedure.
procedure prdoclib-temp-prt-obj-by-prt-root :
  define input parameter  p-prt-code like ub.prt-obj.prt-code no-undo .
  define parameter buffer buf_temp-prt-obj  for temp-prt-obj .
  define buffer buf_gds-prt for ub.gds-prt .
  do
  on error undo, return error return-value
  :
    find first buf_temp-prt-obj
      where buf_temp-prt-obj.prt-code = p-prt-code
      no-error .
    if not available buf_temp-prt-obj
    then do:
      create buf_temp-prt-obj .
      assign
        buf_temp-prt-obj.prt-code         = p-prt-code
        buf_temp-prt-obj.price-sale       = ?
        buf_temp-prt-obj.fact-qnty        = 0
        buf_temp-prt-obj.price-list-qnty  = ?
        buf_temp-prt-obj.prt-obj-recid    = ?
        buf_temp-prt-obj.price-list-recid = ?
      .
      find first buf_gds-prt no-lock
        where buf_gds-prt.node-code = buf_temp-prt-obj.prt-code
        .
      assign
        buf_temp-prt-obj.is-term = buf_gds-prt.is-term
      .
      if buf_temp-prt-obj.is-term
      then do:
        assign
          buf_temp-prt-obj.price-sale = 0
        .
      end.
    end.
  end.
end procedure.
procedure prdoclib-init-temp-prt-obj :
  define input parameter p-obj-type        like ub.prt-obj.obj-type  no-undo .
  define input parameter p-obj-code        like ub.prt-obj.obj-code  no-undo .
  define input parameter p-artic           like ub.prt-obj.artic     no-undo .
  define input parameter p-prod-type       like ub.prt-obj.prod-type no-undo .
  define input parameter p-prod-code       like ub.prt-obj.prod-code no-undo .
  define input parameter p-root-price-sale like ub.prt-obj.price-sale no-undo .
  define buffer buf_prt-obj      for ub.prt-obj .
  define buffer buf_temp-prt-obj for temp-prt-obj .
  do
  on error undo, return error return-value
  :
    run prdoclib-clear-temp-prt-obj in this-procedure .
    for each buf_prt-obj
      where buf_prt-obj.obj-type  = p-obj-type
        and buf_prt-obj.obj-code  = p-obj-code
        and buf_prt-obj.artic     = p-artic
        and buf_prt-obj.prod-type = p-prod-type
        and buf_prt-obj.prod-code = p-prod-code
    on error undo, return error return-value
    :
      run prdoclib-create-temp-prt-obj in this-procedure
        (input  p-root-price-sale
        ,buffer buf_prt-obj
        ,buffer buf_temp-prt-obj
        ).
    end.
  end.
end procedure.
procedure prdoclib-calc-fact-sale :
  define input  parameter p-price-list-recid   as recid     no-undo .
  define output parameter p-fact-qnty          as decimal   no-undo .
  define output parameter p-cur-base           as decimal   no-undo .
  define output parameter p-cur-VAT-base       as decimal   no-undo .
  define output parameter p-cur-SLT-base       as decimal   no-undo .
  define output parameter p-cur-road-tax-base  as decimal   no-undo .
  define output parameter p-cur-excise-base    as decimal   no-undo .
  define buffer buf_main_price-list for ub.price-list .
  define buffer buf_price-list      for ub.price-list .
  define buffer buf_goods           for ub.goods .
  define buffer buf_gds-obj         for ub.gds-obj .
  define buffer buf_bar-code        for ub.bar-code .
  define variable l-empty-scale   as logical   no-undo .
  do
  on error undo, return error substitute("  &1 &2 " , return-value , error-status :get-message(1)  )
  on stop undo, return error substitute(" stop &1 &2" , return-value , error-status :get-message(1)  )
  on end-key undo, return error substitute(" end-key &1 &2" , return-value , error-status :get-message(1)  )
  :
    find first buf_main_price-list no-lock
      where recid(buf_main_price-list) = p-price-list-recid
      no-error .
    if not available buf_main_price-list
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info20 skip
        "Ошибка задания входных параметров" skip
        "Не найдена строка переоценки" skip
        "Код записи (recid)" p-price-list-recid skip
        view-as alert-box error .
      undo, return error substitute("  &1 &2 " , return-value , error-status :get-message(1)  )   .
    end.
    if buf_main_price-list.main-price <> true
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info20 skip
        "Ошибка задания входных параметров" skip
        "Строка переоценки не является основной" skip
        "Код записи (recid)" p-price-list-recid skip
        "Переоценка" buf_main_price-list.doc-num skip
        "Артикул" buf_main_price-list.artic buf_main_price-list.prod-type buf_main_price-list.prod-code skip
        "Бар-код" buf_main_price-list.b-code skip
        view-as alert-box error .
      undo, return error substitute("  &1 &2 " , return-value , error-status :get-message(1)  )  .
    end.
    find first buf_goods no-lock
      where buf_goods.artic     = buf_main_price-list.artic
        and buf_goods.prod-type = buf_main_price-list.prod-type
        and buf_goods.prod-code = buf_main_price-list.prod-code
      no-error .
    if not available buf_goods
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info20 skip
        "Не найден товар" skip
        "Переоценка" buf_main_price-list.doc-num skip
        "Артикул" buf_main_price-list.artic buf_main_price-list.prod-type buf_main_price-list.prod-code skip
        view-as alert-box error .
      undo, return error substitute("  &1 &2 " , return-value , error-status :get-message(1)  ) .
    end.
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsat in g#library
  (input  buf_main_price-list.artic
  ,input  buf_main_price-list.prod-type
  ,input  buf_main_price-list.prod-code
  ,input  'empty-scale=request':u
  ,output l-empty-scale
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info20 skip
        "Ошибка при определении атрибута товара" skip
        "Артикул" buf_main_price-list.artic buf_main_price-list.prod-type buf_main_price-list.prod-code skip
        'empty-scale=request':u skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error substitute("  &1 &2 " , return-value , error-status :get-message(1)  ) .
    end.
    find first buf_gds-obj no-lock
      where buf_gds-obj.gds-code = buf_goods.gds-code
        and buf_gds-obj.obj-type = buf_main_price-list.obj-type
        and buf_gds-obj.obj-code = buf_main_price-list.obj-code
      no-error .
      if not available buf_gds-obj then do:
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjcr in g#library
  (input  buf_main_price-list.obj-type
  ,input  buf_main_price-list.obj-code
  ,input  buf_goods.artic
  ,input  buf_goods.prod-type
  ,input  buf_goods.prod-code
  ,buffer buf_gds-obj
  ) no-error .
        if error-status :error then do:
           undo, return error substitute("  &1 &2 " , return-value , error-status :get-message(1)  ) .
        end.
      end.
    define variable price-rubl-with-tax-sale-prl    as decimal   no-undo .
    define variable price-base-with-tax-sale-prl    as decimal   no-undo .
    define variable price-rubl-without-tax-sale-prl as decimal   no-undo .
    define variable price-base-without-tax-sale-prl as decimal   no-undo .
    define variable vat-base-sale-prl               as decimal   no-undo .
    define variable vat-rubl-sale-prl               as decimal   no-undo .
    define variable vat-base-buyer-prl              as decimal   no-undo .
    define variable vat-rubl-buyer-prl              as decimal   no-undo .
    define variable slt-base-sale-prl               as decimal   no-undo .
    define variable slt-rubl-sale-prl               as decimal   no-undo .
    define variable road-tax-base-sale-prl          as decimal   no-undo .
    define variable road-tax-rubl-sale-prl          as decimal   no-undo .
    define variable excise-base-sale-prl            as decimal   no-undo .
    define variable excise-rubl-sale-prl            as decimal   no-undo .
    define variable discnt-base-sale-prl            as decimal   no-undo .
    define variable discnt-rubl-sale-prl            as decimal   no-undo .
    if buf_main_price-list.doc-qnty <> 0
    then do:
      run prl-vat in this-procedure
        (input  recid(buf_main_price-list)
        ,output price-rubl-with-tax-sale-prl
        ,output price-base-with-tax-sale-prl
        ,output price-rubl-without-tax-sale-prl
        ,output price-base-without-tax-sale-prl
        ,output vat-base-sale-prl
        ,output vat-rubl-sale-prl
        ,output vat-base-buyer-prl
        ,output vat-rubl-buyer-prl
        ,output slt-base-sale-prl
        ,output slt-rubl-sale-prl
        ,output road-tax-base-sale-prl
        ,output road-tax-rubl-sale-prl
        ,output excise-base-sale-prl
        ,output excise-rubl-sale-prl
        ,output discnt-base-sale-prl
        ,output discnt-rubl-sale-prl
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info20 skip
          "Ошибка при вызове процеды prl-vat" skip
          "Документ" buf_main_price-list.doc-num skip
          "Артикул" buf_main_price-list.artic buf_main_price-list.prod-type buf_main_price-list.prod-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error substitute("  &1 &2 " , return-value , error-status :get-message(1)  ) .
      end.
    end.
    else do:
      assign
        price-rubl-with-tax-sale-prl    = 0
        price-base-with-tax-sale-prl    = 0
        price-rubl-without-tax-sale-prl = 0
        price-base-without-tax-sale-prl = 0
        vat-base-sale-prl               = 0
        vat-rubl-sale-prl               = 0
        vat-base-buyer-prl              = 0
        vat-rubl-buyer-prl              = 0
        slt-base-sale-prl               = 0
        slt-rubl-sale-prl               = 0
        road-tax-base-sale-prl          = 0
        road-tax-rubl-sale-prl          = 0
        excise-base-sale-prl            = 0
        excise-rubl-sale-prl            = 0
        discnt-base-sale-prl            = 0
        discnt-rubl-sale-prl            = 0
      .
    end.
    define variable v-curr-r-b as character no-undo .
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
    if v-curr-r-b = 'base':U
    then do:
      assign
        p-fact-qnty         = buf_main_price-list.doc-qnty
        p-cur-base          = price-base-with-tax-sale-prl * buf_main_price-list.doc-qnty
        p-cur-VAT-base      = vat-base-sale-prl * buf_main_price-list.doc-qnty
        p-cur-SLT-base      = slt-base-sale-prl * buf_main_price-list.doc-qnty
        p-cur-road-tax-base = road-tax-base-sale-prl * buf_main_price-list.doc-qnty
        p-cur-excise-base   = excise-base-sale-prl * buf_main_price-list.doc-qnty
      .
    end.
    else do:
      assign
        p-fact-qnty         = buf_main_price-list.doc-qnty
        p-cur-base          = price-rubl-with-tax-sale-prl * buf_main_price-list.doc-qnty
        p-cur-VAT-base      = vat-rubl-sale-prl * buf_main_price-list.doc-qnty
        p-cur-SLT-base      = slt-rubl-sale-prl * buf_main_price-list.doc-qnty
        p-cur-road-tax-base = road-tax-rubl-sale-prl * buf_main_price-list.doc-qnty
        p-cur-excise-base   = excise-rubl-sale-prl * buf_main_price-list.doc-qnty
      .
    end.
      define variable v-unit-base like ub.goods.unit-base no-undo .
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run unitbase in g#library
  (input  buf_goods.gds-code
  ,output v-unit-base
  ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info20 skip
          "Ошибка при определении базовой единицы измерения товара" skip
          "Код товара" buf_goods.gds-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error substitute("  &1 &2 " , return-value , error-status :get-message(1)  ) .
      end.
      for each buf_price-list no-lock
        where buf_price-list.doc-num    = buf_main_price-list.doc-num
          and buf_price-list.main-price = false
          and buf_price-list.artic      = buf_main_price-list.artic
          and buf_price-list.prod-type  = buf_main_price-list.prod-type
          and buf_price-list.prod-code  = buf_main_price-list.prod-code
      :
        if buf_price-list.doc-qnty = ?
        then do:
          find first buf_bar-code no-lock
            where buf_bar-code.b-code = buf_price-list.b-code
            no-error .
          if available buf_bar-code
          and buf_bar-code.unit-cli = v-unit-base
          then do:
            message
              vss-workfile vss-revision vss-description skip
              vss-include-info20 skip
              "Ошибка при закрытии переоценки" skip
              "Не задано количество для бар-кода с основной единицей измерения" skip
              "Переоценка" buf_main_price-list.doc-num skip
              "Бар-код" buf_price-list.b-code skip
              "Артикул" buf_main_price-list.artic buf_main_price-list.prod-type buf_main_price-list.prod-code skip
              "Количество" buf_price-list.doc-qnty skip
              "Основная единица измерения" v-unit-base skip
              "Единица измерения бар-кода" buf_bar-code.unit-cli skip
              view-as alert-box error .
            undo, return error substitute("  &1 &2 " , return-value , error-status :get-message(1)  ) .
          end.
          next .
        end.
        if not can-find
          (first buf_bar-code
          where buf_bar-code.b-code = buf_price-list.b-code
          )
        then do:
          message
            vss-workfile vss-revision vss-description skip
            vss-include-info20 skip
            "В переоценке задан несуществующий бар-код" skip
            "Переоценка" buf_price-list.doc-num skip
            "Артикул" buf_price-list.artic buf_price-list.prod-type buf_price-list.prod-code skip
            "Бар-код" buf_price-list.b-code skip
            view-as alert-box error .
          undo, return error substitute("  &1 &2 " , return-value , error-status :get-message(1)  ) .
        end.
        if buf_price-list.doc-qnty <> 0
        then do:
          run prl-vat in this-procedure
            (input  recid(buf_price-list)
            ,output price-rubl-with-tax-sale-prl
            ,output price-base-with-tax-sale-prl
            ,output price-rubl-without-tax-sale-prl
            ,output price-base-without-tax-sale-prl
            ,output vat-base-sale-prl
            ,output vat-rubl-sale-prl
            ,output vat-base-buyer-prl
            ,output vat-rubl-buyer-prl
            ,output slt-base-sale-prl
            ,output slt-rubl-sale-prl
            ,output road-tax-base-sale-prl
            ,output road-tax-rubl-sale-prl
            ,output excise-base-sale-prl
            ,output excise-rubl-sale-prl
            ,output discnt-base-sale-prl
            ,output discnt-rubl-sale-prl
            ) no-error .
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              vss-include-info20 skip
              "Ошибка при вызове процеды prl-vat" skip
              "Документ" buf_price-list.doc-num skip
              "Артикул" buf_price-list.artic buf_price-list.prod-type buf_price-list.prod-code skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error substitute("  &1 &2 " , return-value , error-status :get-message(1)  ) .
          end.
        end.
        else do:
          assign
            price-rubl-with-tax-sale-prl    = 0
            price-base-with-tax-sale-prl    = 0
            price-rubl-without-tax-sale-prl = 0
            price-base-without-tax-sale-prl = 0
            vat-base-sale-prl               = 0
            vat-rubl-sale-prl               = 0
            vat-base-buyer-prl              = 0
            vat-rubl-buyer-prl              = 0
            slt-base-sale-prl               = 0
            slt-rubl-sale-prl               = 0
            road-tax-base-sale-prl          = 0
            road-tax-rubl-sale-prl          = 0
            excise-base-sale-prl            = 0
            excise-rubl-sale-prl            = 0
            discnt-base-sale-prl            = 0
            discnt-rubl-sale-prl            = 0
          .
        end.
        if v-curr-r-b = 'base':U
        then do:
          assign
            p-fact-qnty         = p-fact-qnty
                                + buf_price-list.doc-qnty
            p-cur-base          = p-cur-base
                                + price-base-with-tax-sale-prl * buf_price-list.doc-qnty
            p-cur-VAT-base      = p-cur-VAT-base
                                + vat-base-sale-prl * buf_price-list.doc-qnty
            p-cur-SLT-base      = p-cur-SLT-base
                                + slt-base-sale-prl * buf_price-list.doc-qnty
            p-cur-road-tax-base = p-cur-road-tax-base
                                + road-tax-base-sale-prl * buf_price-list.doc-qnty
            p-cur-excise-base   = p-cur-excise-base
                                + excise-base-sale-prl * buf_price-list.doc-qnty
          .
        end.
        else do:
          assign
            p-fact-qnty         = p-fact-qnty
                                + buf_price-list.doc-qnty
            p-cur-base          = p-cur-base
                                + price-rubl-with-tax-sale-prl * buf_price-list.doc-qnty
            p-cur-VAT-base      = p-cur-VAT-base
                                + vat-rubl-sale-prl * buf_price-list.doc-qnty
            p-cur-SLT-base      = p-cur-SLT-base
                                + slt-rubl-sale-prl * buf_price-list.doc-qnty
            p-cur-road-tax-base = p-cur-road-tax-base
                                + road-tax-rubl-sale-prl * buf_price-list.doc-qnty
            p-cur-excise-base   = p-cur-excise-base
                                + excise-rubl-sale-prl * buf_price-list.doc-qnty
          .
        end.
      end.
  end.
end procedure.
procedure prdoclib-calc-prc :
  define input  parameter p-price-doc-recid as   recid                  no-undo.
  define input  parameter p-cons-pay        as   integer                no-undo.
  define output parameter p-ov-cons         like ub.doc-line.price-base no-undo.
  define output parameter p-ov-VAT-cons     like ub.doc-line.price-base no-undo.
  define output parameter p-ov-SLT-cons     like ub.doc-line.price-base no-undo.
  define output parameter p-ov-prch         like ub.doc-line.price-base no-undo.
  define output parameter p-ov-VAT-prch     like ub.doc-line.price-base no-undo.
  define output parameter p-ov-SLT-prch     like ub.doc-line.price-base no-undo.
  do
  on error undo, return error return-value
  :
    define buffer buf_price-doc       for ub.price-doc .
    define buffer buf_price-list      for ub.price-list .
    define buffer buf_parts           for ub.parts .
    define variable v-ov-qnty     as decimal   no-undo .
    define variable v-ov-base     as decimal   no-undo .
    define variable v-ov-VAT-base as decimal   no-undo .
    define variable v-ov-SLT-base as decimal   no-undo .
    define variable v-cons-qnty   as decimal   no-undo .
    define variable v-prch-qnty   as decimal   no-undo .
    define variable v-cons-mult   as decimal   no-undo .
    define variable v-prch-mult   as decimal   no-undo .
    find first buf_price-doc no-lock
      where recid(buf_price-doc) = p-price-doc-recid
      no-error .
    if not available buf_price-doc
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info20 skip
        "Ошибка задания входных параметров" skip
        "Не найден документ переоценки" skip
        "Код записи (recid)" p-price-doc-recid skip
        view-as alert-box error .
      undo, return error .
    end.
    for each buf_price-list no-lock
      where buf_price-list.doc-num    = buf_price-doc.doc-num
        and buf_price-list.main-price = true
    on error undo, return error return-value
    :
      run prdoclib-calc-ov
        (input recid(buf_price-list)
        ,output v-ov-qnty
        ,output v-ov-base
        ,output v-ov-VAT-base
        ,output v-ov-SLT-base
        ) no-error .
      if error-status :error
      then do:
        if error-status :get-message(1) <> ""
        then do:
          message
            vss-workfile vss-revision vss-description skip
            vss-include-info20 skip
            "Ошибка при вызове процедуры prdoclib-calc-ov" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
        end.
        undo, return error return-value .
      end.
      assign
        v-cons-qnty = 0
        v-prch-qnty = 0
      .
      for each buf_parts no-lock
        where buf_parts.out-code  = buf_price-list.doc-num
          and buf_parts.obj-type  = buf_price-list.obj-type
          and buf_parts.obj-code  = buf_price-list.obj-code
          and buf_parts.artic     = buf_price-list.artic
          and buf_parts.prod-type = buf_price-list.prod-type
          and buf_parts.prod-code = buf_price-list.prod-code
      on error undo, return error return-value
      :
        if buf_parts.pay-code = p-cons-pay
        then do:
          assign
            v-cons-qnty = v-cons-qnty + buf_parts.fact-qnty
          .
        end.
        else do:
          assign
            v-prch-qnty = v-prch-qnty + buf_parts.fact-qnty
          .
        end.
      end.
      if (v-cons-qnty + v-prch-qnty) = 0
      then do:
        assign
          v-cons-mult = 0
          v-prch-mult = 1
        .
      end.
      else do:
        assign
          v-cons-mult = v-cons-qnty / (v-cons-qnty + v-prch-qnty)
          v-prch-mult = v-prch-qnty / (v-cons-qnty + v-prch-qnty)
        .
      end.
      assign
        p-ov-cons     = p-ov-cons     + v-ov-base     * v-cons-mult
        p-ov-VAT-cons = p-ov-VAT-cons + v-ov-VAT-base * v-cons-mult
        p-ov-SLT-cons = p-ov-SLT-cons + v-ov-SLT-base * v-cons-mult
        p-ov-prch     = p-ov-prch     + v-ov-base     * v-prch-mult
        p-ov-VAT-prch = p-ov-VAT-prch + v-ov-VAT-base * v-prch-mult
        p-ov-SLT-prch = p-ov-SLT-prch + v-ov-SLT-base * v-prch-mult
      .
    end.
  end.
end procedure.
procedure prdoclib-calc-ov :
  define input  parameter p-price-list-recid as recid     no-undo .
  define output parameter p-fact-qnty        as decimal   no-undo .
  define output parameter p-ov-base          as decimal   no-undo .
  define output parameter p-ov-VAT-base      as decimal   no-undo .
  define output parameter p-ov-SLT-base      as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    define buffer buf_main_price-list    for ub.price-list .
    define buffer buf_prev_price-list    for ub.price-list .
    define buffer buf_special_price-list for ub.price-list .
    define buffer buf_goods              for ub.goods .
    define variable v-fact-qnty             like ub.doc-line.price-base no-undo.
    define variable v-cur-base              like ub.doc-line.price-base no-undo.
    define variable v-cur-VAT-base          like ub.doc-line.price-base no-undo.
    define variable v-cur-SLT-base          like ub.doc-line.price-base no-undo.
    define variable v-cur-road-tax-base     like ub.doc-line.price-base no-undo.
    define variable v-cur-excise-base       like ub.doc-line.price-base no-undo.
    define variable v-prev-price-list-recid as   recid                  no-undo.
    define variable v-prev-cli-base-rate    like ub.goods.cli-base-rate no-undo.
    define variable v-prev-fact-qnty        like ub.doc-line.price-base no-undo.
    define variable v-prev-cur-base         like ub.doc-line.price-base no-undo.
    define variable v-prev-cur-VAT-base     like ub.doc-line.price-base no-undo.
    define variable v-prev-cur-SLT-base     like ub.doc-line.price-base no-undo.
    find first buf_main_price-list no-lock
      where recid(buf_main_price-list) = p-price-list-recid
      no-error .
    if not available buf_main_price-list
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info20 skip
        "Ошибка задания входных параметров" skip
        "Не найдена строка переоценки" skip
        "Код записи (recid)" p-price-list-recid skip
        view-as alert-box error .
      undo, return error .
    end.
    if buf_main_price-list.main-price <> true
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info20 skip
        "Ошибка задания входных параметров" skip
        "Строка переоценки не является основной" skip
        "Код записи (recid)" p-price-list-recid skip
        "Переоценка" buf_main_price-list.doc-num skip
        "Артикул" buf_main_price-list.artic buf_main_price-list.prod-type buf_main_price-list.prod-code skip
        "Бар-код" buf_main_price-list.b-code skip
        view-as alert-box error .
      undo, return error .
    end.
    run prdoclib-calc-fact-sale in this-procedure
      (input  recid(buf_main_price-list)
      ,output v-fact-qnty
      ,output v-cur-base
      ,output v-cur-VAT-base
      ,output v-cur-SLT-base
      ,output v-cur-road-tax-base
      ,output v-cur-excise-base
      ) no-error.
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info20 skip
        "Ошибка при расчете сумм переоценки." skip
        "Документ переоценки" buf_main_price-list.doc-num skip
        "Товар" buf_main_price-list.artic buf_main_price-list.prod-type buf_main_price-list.prod-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodepls in g#library
  (input  buf_main_price-list.obj-type
  ,input  buf_main_price-list.obj-code
  ,input  buf_main_price-list.b-code
  ,input  buf_main_price-list.b-code
  ,input  buf_main_price-list.fact-order
  ,output v-prev-price-list-recid
  ,output v-prev-cli-base-rate
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info20 skip
        "Ошибка при поиске предыдущей переоценки." skip
        "Документ переоценки " buf_main_price-list.doc-num skip
        "Товар " buf_main_price-list.artic buf_main_price-list.prod-type buf_main_price-list.prod-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    if v-prev-price-list-recid <> ?
    then do:
      find first buf_prev_price-list no-lock
        where recid(buf_prev_price-list) = v-prev-price-list-recid
        .
      find first buf_special_price-list no-lock
        where buf_special_price-list.doc-num    = buf_prev_price-list.doc-num
          and buf_special_price-list.main-price = false
          and buf_special_price-list.artic      = buf_prev_price-list.artic
          and buf_special_price-list.prod-type  = buf_prev_price-list.prod-type
          and buf_special_price-list.prod-code  = buf_prev_price-list.prod-code
          and buf_special_price-list.doc-qnty   <> ?
        no-error .
      if available buf_special_price-list
      then do:
        message
          "Товар имеет специальные цены на признаки" skip
          "Разбиение суммы переоценки по консигнации, выкупу невозможно" skip
          "Переоценка" buf_prev_price-list.doc-num skip
          "Товар" buf_prev_price-list.artic buf_prev_price-list.prod-type buf_prev_price-list.prod-code skip
          view-as alert-box error .
        undo, return error .
      end.
      find first buf_goods no-lock
        where buf_goods.artic     = buf_main_price-list.artic
          and buf_goods.prod-type = buf_main_price-list.prod-type
          and buf_goods.prod-code = buf_main_price-list.prod-code
        no-error .
      if not available buf_goods
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info20 skip
          "Не найден товар" skip
          "Переоценка" buf_main_price-list.doc-num skip
          "Артикул" buf_main_price-list.artic buf_main_price-list.prod-type buf_main_price-list.prod-code skip
          view-as alert-box error .
        undo, return error .
      end.
      if buf_prev_price-list.vat-pc = ?
      or buf_prev_price-list.slt-pc = ?
      then do:
        message
          "В переоценке не заданы налоги товара" skip
          "Разбиение суммы переоценки по консигнации, выкупу невозможно" skip
          "Переоценка" buf_prev_price-list.doc-num skip
          "Товар" buf_prev_price-list.artic buf_prev_price-list.prod-type buf_prev_price-list.prod-code skip
          "НДС" buf_prev_price-list.vat-pc skip
          "НП" buf_prev_price-list.slt-pc skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      define variable v-prev-cur-SLT-pc as decimal no-undo .
      assign
        v-prev-cur-SLT-pc   = buf_prev_price-list.price-sale * buf_prev_price-list.slt-pc / (100 + buf_prev_price-list.slt-pc)
      .
      assign
        v-prev-cur-base     = v-fact-qnty * buf_prev_price-list.price-sale
        v-prev-cur-VAT-base = v-fact-qnty
                            * (buf_prev_price-list.price-sale - v-prev-cur-SLT-pc)
                            * buf_prev_price-list.vat-pc / (100 + buf_prev_price-list.vat-pc)
        v-prev-cur-SLT-base = v-fact-qnty * v-prev-cur-SLT-pc
      .
      assign
        p-fact-qnty   = v-fact-qnty
        p-ov-base     = v-cur-base     - v-prev-cur-base
        p-ov-VAT-base = v-cur-VAT-base - v-prev-cur-VAT-base
        p-ov-SLT-base = v-cur-SLT-base - v-prev-cur-SLT-base
      .
    end.
    else do:
      assign
        v-prev-cur-base     = 0
        v-prev-cur-VAT-base = 0
        v-prev-cur-SLT-base = 0
        .
      assign
        p-fact-qnty   = v-fact-qnty
        p-ov-base     = v-cur-base     - v-prev-cur-base
        p-ov-VAT-base = v-cur-VAT-base - v-prev-cur-VAT-base
        p-ov-SLT-base = v-cur-SLT-base - v-prev-cur-SLT-base
      .
    end.
  end.
end procedure.
procedure prdoclib-init-prt-obj-by-factord :
  define input parameter p-obj-type           like ub.gds-obj.obj-type  no-undo .
  define input parameter p-obj-code           like ub.gds-obj.obj-code  no-undo .
  define input parameter p-artic              like ub.gds-obj.artic     no-undo .
  define input parameter p-prod-type          like ub.gds-obj.prod-type no-undo .
  define input parameter p-prod-code          like ub.gds-obj.prod-code no-undo .
  define input parameter p-fact-order         as decimal   no-undo .
  define input parameter p-include-fact-order as logical   no-undo .
  define variable vss-description as character no-undo init "prdoclib-init-prt-obj-by-factord: определение остатков по признакам на любой момент времени".
  define buffer buf_gds-obj      for ub.gds-obj .
  define buffer buf_doc-line     for ub.doc-line .
  define buffer buf_temp-prt-obj for temp-prt-obj .
  define variable v-total-gds-dtl-qnty as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    do transaction
    on error undo, return error return-value
    :
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
          vss-include-info20 skip
          "Невозможно найти gds-obj" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
      find current buf_gds-obj exclusive-lock .
    end.
    run prdoclib-init-temp-prt-obj in this-procedure
      (input p-obj-type
      ,input p-obj-code
      ,input p-artic
      ,input p-prod-type
      ,input p-prod-code
      ,input 0
      ) .
    for each buf_temp-prt-obj
      where buf_temp-prt-obj.is-term <> true
    on error undo, return error return-value
    :
      delete buf_temp-prt-obj .
    end.
    if p-include-fact-order = true
    then do:
      assign
       p-fact-order = p-fact-order - 0.0000000001
      .
    end.
    for each buf_doc-line no-lock
      where buf_doc-line.obj-type   = p-obj-type
        and buf_doc-line.obj-code   = p-obj-code
        and buf_doc-line.artic      = p-artic
        and buf_doc-line.prod-type  = p-prod-type
        and buf_doc-line.prod-code  = p-prod-code
        and buf_doc-line.status_    = 'факт':U
        and buf_doc-line.fact-order >= p-fact-order
    on error undo, return error return-value
    :
      run prdoclib-process-document in this-procedure
        (input  buf_doc-line.doc-code
        ,input  p-obj-type
        ,input  p-obj-code
        ,input  p-artic
        ,input  p-prod-type
        ,input  p-prod-code
        ,output v-total-gds-dtl-qnty
        ) .
    end.
  end.
end procedure.
procedure prdoclib-process-document :
  define input  parameter p-doc-code           as character no-undo .
  define input  parameter p-obj-type           as character no-undo .
  define input  parameter p-obj-code           as integer   no-undo .
  define input  parameter p-artic              as character no-undo .
  define input  parameter p-prod-type          as character no-undo .
  define input  parameter p-prod-code          as integer   no-undo .
  define output parameter p-total-gds-dtl-qnty as decimal   no-undo .
  define buffer buf_trn-doc      for ub.trn-doc .
  define buffer buf_gds-dtl      for ub.gds-dtl .
  define buffer buf_temp-prt-obj for temp-prt-obj .
  do
  on error undo, return error return-value
  :
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-doc-code
      no-error .
    if not available buf_trn-doc then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info20 skip
        "Ошибка при поиске документа" skip
        "Документ" p-doc-code skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        view-as alert-box error .
      undo, return error .
    end.
    assign
      p-total-gds-dtl-qnty = 0
    .
    for each buf_gds-dtl no-lock
      where buf_gds-dtl.doc-code  = p-doc-code
        and buf_gds-dtl.artic     = p-artic
        and buf_gds-dtl.prod-type = p-prod-type
        and buf_gds-dtl.prod-code = p-prod-code
    on error undo, return error
    :
      define variable v-term-node as integer   no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run termnode in g#library
  (input  buf_gds-dtl.prt-code
  ,output v-term-node
  )  .
      run prdoclib-temp-prt-obj-by-prt-root in this-procedure
        (input  v-term-node
        ,buffer buf_temp-prt-obj
        ) .
      if buf_temp-prt-obj.is-term <> true then do:
        undo, return error substitute("Документ ссылается на нетерминальный признак. Код признака &1"
                                     ,buf_gds-dtl.prt-code
                                     ) .
      end.
      case buf_trn-doc.doc-type :
        when 'при':U or
        when 'возврат':U
        then do:
          assign
            p-total-gds-dtl-qnty        = p-total-gds-dtl-qnty
                                        - buf_gds-dtl.fact-qnty
            buf_temp-prt-obj.fact-qnty  = buf_temp-prt-obj.fact-qnty
                                        - buf_gds-dtl.fact-qnty
          .
        end.
        when 'рас':U or
        when 'спи':U
        then do:
          assign
            p-total-gds-dtl-qnty        = p-total-gds-dtl-qnty
                                        + buf_gds-dtl.fact-qnty
            buf_temp-prt-obj.fact-qnty  = buf_temp-prt-obj.fact-qnty
                                        + buf_gds-dtl.fact-qnty
          .
        end.
        when 'инв':U
        then do:
          assign
            p-total-gds-dtl-qnty        = p-total-gds-dtl-qnty
                                        - buf_gds-dtl.doc-qnty
            buf_temp-prt-obj.fact-qnty  = buf_temp-prt-obj.fact-qnty
                                        - buf_gds-dtl.doc-qnty
          .
        end.
        otherwise do:
          undo, return error substitute("Неизвестный тип документа &1"
                                       ,buf_trn-doc.doc-type
                                       ) .
        end.
      end.
    end.
  end.
end procedure.
procedure prdoclib-prc-pl-document :
  define input  parameter p-doc-code              as character no-undo .
  define input  parameter p-obj-type              as character no-undo .
  define input  parameter p-obj-code              as integer   no-undo .
  define input  parameter p-gds-code              as integer   no-undo .
  define output parameter p-total-pl-gds-qnty     as decimal   no-undo .
  define output parameter p-total-pl-gds-cli-qnty as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    define buffer buf_trn-doc      for ub.trn-doc .
    define buffer buf_doc-pl       for ub.doc-pl .
    define buffer buf_temp-pl-gds for temp-pl-gds .
    define variable v-sign as decimal   no-undo .
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-doc-code
      no-error .
    if not available buf_trn-doc then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info20 skip
        "Ошибка при поиске документа" skip
        "Документ" p-doc-code skip
        "Объект" p-obj-type p-obj-code skip
        "Товар" p-gds-code skip
        view-as alert-box error .
      undo, return error .
    end.
    assign
      p-total-pl-gds-qnty     = 0
      p-total-pl-gds-cli-qnty = 0
    .
    for each buf_doc-pl no-lock
      where buf_doc-pl.out-code  = p-doc-code
        and buf_doc-pl.gds-code  = p-gds-code
    on error undo, return error return-value
    :
      find first buf_temp-pl-gds
        where buf_temp-pl-gds.obj-type = buf_trn-doc.obj-type
          and buf_temp-pl-gds.obj-code = buf_trn-doc.obj-code
          and buf_temp-pl-gds.pl-code  = buf_doc-pl.pl-code
        .
      case buf_trn-doc.doc-type :
        when 'при':U
        or when 'возврат':U
        or when 'инв':U
        then do:
          assign
            v-sign = -1.0
          .
        end.
        when 'рас':U or
        when 'спи':U
        then do:
          assign
            v-sign = 1.0
          .
        end.
        otherwise do:
          undo, return error substitute("(prdoclib-prc-pl-document) Неизвестный тип документа &1", buf_trn-doc.doc-type ) .
        end.
      end case.
      assign
        p-total-pl-gds-qnty           = p-total-pl-gds-qnty           + buf_doc-pl.fact-qnty     * v-sign
        p-total-pl-gds-cli-qnty       = p-total-pl-gds-cli-qnty       + buf_doc-pl.cli-fact-qnty * v-sign
        buf_temp-pl-gds.fact-qnty     = buf_temp-pl-gds.fact-qnty     + buf_doc-pl.fact-qnty     * v-sign
        buf_temp-pl-gds.cli-fact-qnty = buf_temp-pl-gds.cli-fact-qnty + buf_doc-pl.cli-fact-qnty * v-sign
      .
    end.
  end.
end procedure.
procedure prdoclib-init-prt-obj-by-date :
  define input parameter p-obj-type   like ub.gds-obj.obj-type  no-undo .
  define input parameter p-obj-code   like ub.gds-obj.obj-code  no-undo .
  define input parameter p-artic      like ub.gds-obj.artic     no-undo .
  define input parameter p-prod-type  like ub.gds-obj.prod-type no-undo .
  define input parameter p-prod-code  like ub.gds-obj.prod-code no-undo .
  define input parameter p-fact-date  as date      no-undo .
  define variable vss-description as character no-undo init "prdoclib-init-prt-obj-by-date: определение остатков по признакам на конец дня".
  do
  on error undo, return error return-value
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
        vss-include-info20 skip
        "Ошибка при определении момента времени, на который требуется остаток" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "Дата" p-fact-date skip
        view-as alert-box error .
      undo, return error .
    end.
    run prdoclib-init-prt-obj-by-date-factord in this-procedure
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
        vss-include-info20 skip
        "Ошибка при вызове метода prdoclib-init-prt-obj-by-date-factord" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "Дата" p-fact-date skip
        view-as alert-box error .
      undo, return error .
    end.
  end.
end procedure.
procedure prdoclib-calc-temp-fact-sale :
  define input  parameter p-obj-type           as character no-undo .
  define input  parameter p-obj-code           as integer   no-undo .
  define input  parameter p-gds-code           as integer   no-undo .
  define input  parameter p-day-end-fact-order as decimal   no-undo .
  define input  parameter p-curr-r-b           as character no-undo .
  define output parameter p-fact-qnty          as decimal   no-undo .
  define output parameter p-cur-base           as decimal   no-undo .
  define output parameter p-cur-VAT-base       as decimal   no-undo .
  define output parameter p-cur-SLT-base       as decimal   no-undo .
  define output parameter p-cur-road-tax-base  as decimal   no-undo .
  define output parameter p-cur-excise-base    as decimal   no-undo .
  define buffer buf_temp-prt-obj for temp-prt-obj .
  define variable v-prt-b-code        like ub.bar-code.b-code no-undo .
  define variable v-cli-base-rate     like ub.bar-code.cli-base-rate no-undo .
  define variable parrecid-prl        as recid     no-undo .
  define variable v-fact-qnty         as decimal   no-undo .
  define variable v-cur-base          as decimal   no-undo .
  define variable v-cur-VAT-base      as decimal   no-undo .
  define variable v-cur-SLT-base      as decimal   no-undo .
  define variable v-cur-road-tax-base as decimal   no-undo .
  define variable v-cur-excise-base   as decimal   no-undo .
  define variable price-rubl-with-tax-sale-prl    as decimal   no-undo .
  define variable price-base-with-tax-sale-prl    as decimal   no-undo .
  define variable price-rubl-without-tax-sale-prl as decimal   no-undo .
  define variable price-base-without-tax-sale-prl as decimal   no-undo .
  define variable vat-base-sale-prl               as decimal   no-undo .
  define variable vat-rubl-sale-prl               as decimal   no-undo .
  define variable vat-base-buyer-prl              as decimal   no-undo .
  define variable vat-rubl-buyer-prl              as decimal   no-undo .
  define variable slt-base-sale-prl               as decimal   no-undo .
  define variable slt-rubl-sale-prl               as decimal   no-undo .
  define variable road-tax-base-sale-prl          as decimal   no-undo .
  define variable road-tax-rubl-sale-prl          as decimal   no-undo .
  define variable excise-base-sale-prl            as decimal   no-undo .
  define variable excise-rubl-sale-prl            as decimal   no-undo .
  define variable discnt-base-sale-prl            as decimal   no-undo .
  define variable discnt-rubl-sale-prl            as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    for each buf_temp-prt-obj no-lock
    on error undo, return error return-value
    :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  p-gds-code
  ,input  buf_temp-prt-obj.prt-code
  ,output v-prt-b-code
  ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении бар-кода признака" skip
          "Код товара"   p-gds-code skip
          "Код признака" buf_temp-prt-obj.prt-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodepls in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  v-prt-b-code
  ,input  0
  ,input  p-day-end-fact-order
  ,output parrecid-prl
  ,output v-cli-base-rate
  ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении цены бар-кода" skip
          "Объект" p-obj-type p-obj-code skip
          "Бар-код" v-prt-b-code skip
          "fact-order" p-day-end-fact-order skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
      if parrecid-prl <> ?
      then do:
        run prl-vat in this-procedure
          (input  parrecid-prl
          ,output price-rubl-with-tax-sale-prl
          ,output price-base-with-tax-sale-prl
          ,output price-rubl-without-tax-sale-prl
          ,output price-base-without-tax-sale-prl
          ,output vat-base-sale-prl
          ,output vat-rubl-sale-prl
          ,output vat-base-buyer-prl
          ,output vat-rubl-buyer-prl
          ,output slt-base-sale-prl
          ,output slt-rubl-sale-prl
          ,output road-tax-base-sale-prl
          ,output road-tax-rubl-sale-prl
          ,output excise-base-sale-prl
          ,output excise-rubl-sale-prl
          ,output discnt-base-sale-prl
          ,output discnt-rubl-sale-prl
          ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при вызове процеды prl-vat" skip
            "Объект" p-obj-type p-obj-code skip
            "Код товара" p-gds-code skip
            "Указатель на запись переоценки" parrecid-prl skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error .
        end.
      end.
      else do:
        assign
          price-rubl-with-tax-sale-prl    = 0
          price-base-with-tax-sale-prl    = 0
          price-rubl-without-tax-sale-prl = 0
          price-base-without-tax-sale-prl = 0
          vat-base-sale-prl               = 0
          vat-rubl-sale-prl               = 0
          slt-base-sale-prl               = 0
          slt-rubl-sale-prl               = 0
          road-tax-base-sale-prl          = 0
          road-tax-rubl-sale-prl          = 0
          excise-base-sale-prl            = 0
          excise-rubl-sale-prl            = 0
          discnt-base-sale-prl            = 0
          discnt-rubl-sale-prl            = 0
        .
      end.
      assign
        v-fact-qnty         = v-fact-qnty
                            + buf_temp-prt-obj.fact-qnty
        v-cur-base          = v-cur-base
                            + (if p-curr-r-b = 'base':U
                                then price-base-with-tax-sale-prl
                                else price-rubl-with-tax-sale-prl
                              )
                            * buf_temp-prt-obj.fact-qnty
        v-cur-VAT-base      = v-cur-VAT-base
                            + (if p-curr-r-b = 'base':U
                                then vat-base-sale-prl
                                else vat-rubl-sale-prl
                              )
                            * buf_temp-prt-obj.fact-qnty
        v-cur-SLT-base      = v-cur-SLT-base
                            + (if p-curr-r-b = 'base':U
                                then slt-base-sale-prl
                                else slt-rubl-sale-prl
                              )
                            * buf_temp-prt-obj.fact-qnty
        v-cur-road-tax-base = v-cur-road-tax-base
                            + (if p-curr-r-b = 'base':U
                                then road-tax-base-sale-prl
                                else road-tax-rubl-sale-prl
                              )
                            * buf_temp-prt-obj.fact-qnty
        v-cur-excise-base   = v-cur-excise-base
                            + (if p-curr-r-b = 'base':U
                                then excise-base-sale-prl
                                else excise-rubl-sale-prl
                              )
                            * buf_temp-prt-obj.fact-qnty
      .
    end.
    assign
      p-fact-qnty         = v-fact-qnty
      p-cur-base          = v-cur-base
      p-cur-VAT-base      = v-cur-VAT-base
      p-cur-SLT-base      = v-cur-SLT-base
      p-cur-road-tax-base = v-cur-road-tax-base
      p-cur-excise-base   = v-cur-excise-base
    .
  end.
end procedure.
procedure prdoclib-clear-temp-pl-gds :
  define buffer buf_temp-pl-gds for temp-pl-gds .
  do
  on error undo, return error return-value
  :
    for each buf_temp-pl-gds
    on error undo, return error return-value
    :
      delete buf_temp-pl-gds .
    end.
  end.
end procedure.
procedure prdoclib-init-temp-pl-gds :
  define input parameter p-obj-type        like ub.pl-gds.obj-type  no-undo .
  define input parameter p-obj-code        like ub.pl-gds.obj-code  no-undo .
  define input parameter p-gds-code        like ub.pl-gds.gds-code  no-undo .
  define buffer buf_pl-gds      for ub.pl-gds .
  define buffer buf_temp-pl-gds for temp-pl-gds .
  do
  on error undo, return error return-value
  :
    run prdoclib-clear-temp-pl-gds in this-procedure .
    for each buf_pl-gds
      where buf_pl-gds.obj-type = p-obj-type
        and buf_pl-gds.obj-code = p-obj-code
        and buf_pl-gds.gds-code = p-gds-code
    on error undo, return error return-value
    :
      create buf_temp-pl-gds .
      buffer-copy buf_pl-gds to buf_temp-pl-gds .
    end.
  end.
end procedure.
procedure prdoclib-init-pl-gds-by-factord :
  define input parameter p-obj-type           like ub.gds-obj.obj-type  no-undo .
  define input parameter p-obj-code           like ub.gds-obj.obj-code  no-undo .
  define input parameter p-artic              like ub.gds-obj.artic     no-undo .
  define input parameter p-prod-type          like ub.gds-obj.prod-type no-undo .
  define input parameter p-prod-code          like ub.gds-obj.prod-code no-undo .
  define input parameter p-fact-order         as decimal   no-undo .
  define input parameter p-include-fact-order as logical   no-undo .
  define variable vss-description as character no-undo init "prdoclib-init-pl-gds-by-factord: определение остатков по признакам на любой момент времени".
  define buffer buf_goods       for ub.goods .
  define buffer buf_gds-obj     for ub.gds-obj .
  define buffer buf_doc-line    for ub.doc-line .
  define buffer buf_temp-pl-gds for temp-pl-gds .
  define variable v-total-pl-gds-qnty     as decimal   no-undo .
  define variable v-total-pl-gds-cli-qnty as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    do transaction
    on error undo, return error return-value
    :
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
          vss-include-info20 skip
          "Невозможно найти gds-obj" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      find current buf_gds-obj exclusive-lock .
    end.
    find first buf_goods no-lock
      where buf_goods.artic     = p-artic
        and buf_goods.prod-type = p-prod-type
        and buf_goods.prod-code = p-prod-code
      .
    run prdoclib-init-temp-pl-gds in this-procedure
      (input p-obj-type
      ,input p-obj-code
      ,input buf_goods.gds-code
      ) .
    if p-include-fact-order = true
    then do:
      assign
       p-fact-order = p-fact-order - 0.0000000001
      .
    end.
    for each buf_doc-line no-lock
      where buf_doc-line.obj-type   = p-obj-type
        and buf_doc-line.obj-code   = p-obj-code
        and buf_doc-line.artic      = p-artic
        and buf_doc-line.prod-type  = p-prod-type
        and buf_doc-line.prod-code  = p-prod-code
        and buf_doc-line.status_    = 'факт':U
        and buf_doc-line.fact-order >= p-fact-order
    on error undo, return error return-value
    :
      run prdoclib-prc-pl-document in this-procedure
        ( input  buf_doc-line.doc-code
         ,input  p-obj-type
         ,input  p-obj-code
         ,input  buf_goods.gds-code
         ,output v-total-pl-gds-qnty
         ,output v-total-pl-gds-cli-qnty
        ) .
    end.
  end.
end procedure.
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure prl-vat:
  define input parameter parrecid as recid no-undo.
    define output parameter price-rubl-with-tax-saleprl    like ub.doc-line.price-rubl no-undo.
    define output parameter price-base-with-tax-saleprl    like ub.doc-line.price-base no-undo.
    define output parameter price-rubl-without-tax-saleprl like ub.doc-line.price-rubl no-undo.
    define output parameter price-base-without-tax-saleprl like ub.doc-line.price-base no-undo.
    define output parameter vat-base-saleprl               like ub.doc-line.price-base no-undo.
    define output parameter vat-rubl-saleprl               like ub.doc-line.price-rubl no-undo.
    define output parameter vat-base-buyerprl              like ub.doc-line.price-base no-undo.
    define output parameter vat-rubl-buyerprl              like ub.doc-line.price-rubl no-undo.
    define output parameter slt-base-saleprl               like ub.doc-line.price-base no-undo.
    define output parameter slt-rubl-saleprl               like ub.doc-line.price-rubl no-undo.
    define output parameter road-tax-base-saleprl          like ub.doc-line.road-tax   no-undo.
    define output parameter road-tax-rubl-saleprl          like ub.doc-line.road-tax   no-undo.
    define output parameter excise-base-saleprl            like ub.doc-line.price-base no-undo.
    define output parameter excise-rubl-saleprl            like ub.doc-line.price-rubl no-undo.
    define output parameter discnt-base-saleprl            like ub.gds-dtl.discnt-base no-undo.
    define output parameter discnt-rubl-saleprl            like ub.gds-dtl.discnt-rubl no-undo.
    define buffer out-vatp_gds-dtlprl     for ub.gds-dtl.
    define buffer buf_out-vatp_gds-dtlprl for ub.gds-dtl.
    define buffer out-vatp_partsprl       for ub.parts.
    define buffer out-vatp_sysconfprl     for ub.sysconf.
    define buffer out-vatp_doc-lineprl    for ub.doc-line.
    define buffer out-vatp_goodsprl       for ub.goods.
    define buffer out-vatp_trn-docprl     for ub.trn-doc.
    define buffer out-vatp_doc-attrprl    for ub.doc-attr.
    define variable varprice-base-consprl      like ub.doc-line.price-base initial 0.00 no-undo.
    define variable varprice-rubl-consprl      like ub.doc-line.price-rubl initial 0.00 no-undo.
    define variable varfrm-cnsv-typeprl         as   character                           no-undo.
    define variable varfrm-cnsvprl              as   character                           no-undo.
    define variable varroot-nodeprl             as   integer                             no-undo.
    define variable varempty-scaleprl           as   logical                             no-undo.
    define variable varis-cons-parts-haveprl    as   logical                             no-undo.
    define variable varsum-base-factovpprl      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-factovpprl      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-factovpprl      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-factovpprl  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-factovpprl      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-base-docovpprl       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-docovpprl       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-docovpprl       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-docovpprl   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-docovpprl       like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-factovpprl      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-factovpprl      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-factovpprl      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-factovpprl  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-factovpprl      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-docovpprl       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-docovpprl       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-docovpprl       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-docovpprl   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-docovpprl       like ub.gds-dtl.price-base               no-undo.
    define variable varfact-qntyprl             like ub.parts.fact-qnty                  no-undo.
    define variable varcons-qntyprl             like ub.parts.fact-qnty                  no-undo.
    define variable varis-one-gds-dtlprl        as   logical                             no-undo.
    define variable varcurprlprice-base         like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurprlprice-rubl         like ub.gds-dtl.price-base               no-undo.
    define variable varcurprldiscnt-base        like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurprldiscnt-rubl        like ub.gds-dtl.price-base               no-undo.
    define variable varoutvprbprl               as   character                           no-undo.
    define variable out-vatp-have-vat-sltprl    as   logical initial yes                 no-undo.
    define buffer   in-vatp-trn-docoprl  for ub.trn-doc .
    define buffer   in-vatp-partsoprl    for ub.parts   .
    define buffer   in-vatp-docoprl      for ub.trn-doc .
    define buffer   in-vatp-goodsoprl    for ub.goods   .
    define buffer   in-vatp-sysconfoprl  for ub.sysconf .
    define buffer   in-vatp_doc-attroprl for ub.doc-attr.
    define variable in-vatp-have-vat-sltoprl       as   logical initial yes    no-undo.
    define variable vat-pc-locoprl                 like ub.doc-line.vat-pc     no-undo.
    define variable varinvprboprl                  as   character              no-undo.
    define variable slt-pc-locoprl                 like ub.doc-line.slt-pc     no-undo.
    define variable cli-base-rateoprl              as   decimal                no-undo.
    define variable price-rubl-with-tax-locoprl    like ub.doc-line.price-rubl no-undo.
    define variable price-base-with-tax-locoprl    like ub.doc-line.price-base no-undo.
    define variable price-cli-with-tax-locoprl     like ub.doc-line.price-cli  no-undo.
    define variable price-rubl-without-tax-locoprl like ub.doc-line.price-rubl no-undo.
    define variable price-base-without-tax-locoprl like ub.doc-line.price-base no-undo.
    define variable price-cli-without-tax-locoprl  like ub.doc-line.price-base no-undo.
    define variable vat-base-locoprl               like ub.doc-line.price-base no-undo.
    define variable vat-rubl-locoprl               like ub.doc-line.price-rubl no-undo.
    define variable vat-cli-locoprl                like ub.doc-line.price-rubl no-undo.
    define variable slt-base-locoprl               like ub.doc-line.price-base no-undo.
    define variable slt-rubl-locoprl               like ub.doc-line.price-rubl no-undo.
    define variable slt-cli-locoprl                like ub.doc-line.price-rubl no-undo.
    define variable road-tax-base-locoprl          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-rubl-locoprl          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-cli-locoprl           like ub.doc-line.road-tax   no-undo.
    define variable transport-base-locoprl         like ub.doc-line.price-base no-undo.
    define variable transport-rubl-locoprl         like ub.doc-line.price-rubl no-undo.
    define variable transport-cli-locoprl          like ub.doc-line.price-rubl no-undo.
    define variable other-base-locoprl             like ub.doc-line.price-base no-undo.
    define variable other-rubl-locoprl             like ub.doc-line.price-rubl no-undo.
    define variable other-cli-locoprl              like ub.doc-line.price-rubl no-undo.
    define variable exch-rate-cli-locoprl          like ub.trn-doc.exch-rate   no-undo.
    define variable varinvatp-envdoprl             as   character              no-undo.
    define variable varinvatp-typeoprl             as   character              no-undo.
  define buffer bf_price-list for ub.price-list.
  define buffer bf_goods      for ub.goods.
  define buffer bf_sysconf    for ub.sysconf.
  define buffer bf_parts      for ub.parts.
  define variable varbase-rate   like ub.trn-doc.base-rate     no-undo.
  define variable varbase-scale  like ub.trn-doc.base-scale    no-undo.
  define variable varroad-tax    like ub.price-list.road-tax   no-undo.
  define variable varexcise      like ub.price-list.excise     no-undo.
  define variable varvat-pc      like ub.doc-line.vat-pc       no-undo.
  define variable varslt-pc      like ub.doc-line.slt-pc       no-undo.
  define variable varprice-base  like ub.price-list.price-sale no-undo.
  define variable varprice-rubl  like ub.price-list.price-sale no-undo.
  define variable vardiscnt-base like ub.price-list.price-sale no-undo.
  define variable vardiscnt-rubl like ub.price-list.price-sale no-undo.
  define variable v-host-code    like ub.sysconf.host-code     no-undo.
  define variable vardoc-num     like ub.price-list.doc-num    no-undo.
  define variable vardoc-code    like ub.price-list.doc-num    no-undo.
  define variable varobj-type    like ub.price-list.obj-type   no-undo.
  define variable varobj-code    like ub.price-list.obj-code   no-undo.
  define variable varartic       like ub.price-list.artic      no-undo.
  define variable varprod-type   like ub.price-list.prod-type  no-undo.
  define variable varprod-code   like ub.price-list.prod-code  no-undo.
  define variable varfact-qnty   like ub.price-list.doc-qnty   no-undo.
  define variable varcons-vat-pc like ub.doc-line.vat-pc       no-undo.
  define variable varext-doc-type like ub.trn-doc.ext-doc-type no-undo.
  define variable vardoc-qnty     like ub.price-list.doc-qnty no-undo.
  define variable vardoc-type     as   character              no-undo.
  do
  on error undo, return error "Ошибка при вызове процедуры prl-vat."
  :
    find first bf_price-list no-lock
      where recid(bf_price-list) = parrecid
      no-error .
    if not available bf_price-list
    then do:
      return error "Ошибка во входящих параметрах prl-vat.i" .
    end.
    find first bf_goods no-lock
      where bf_goods.artic     = bf_price-list.artic
        and bf_goods.prod-type = bf_price-list.prod-type
        and bf_goods.prod-code = bf_price-list.prod-code
      no-error .
    if not available bf_goods
    then do:
      undo, return error substitute("Не найден товар &1 &2 &3 для переоценки с кодом &4",bf_price-list.artic,bf_price-list.prod-type,bf_price-list.prod-code,parrecid).
    end.
    assign
      varvat-pc = bf_price-list.vat-pc
      varslt-pc = bf_price-list.slt-pc
    .
    if varvat-pc = ?
    then do:
      undo, return error substitute("В переоценке &1 для товара &2 &3 &4 не задан НДС",bf_price-list.doc-num,bf_price-list.artic,bf_price-list.prod-type,bf_price-list.prod-code).
    end.
    if varslt-pc = ?
    then do:
      undo, return error substitute("В переоценке &1 для товара &2 &3 &4 не задан НП",bf_price-list.doc-num,bf_price-list.artic,bf_price-list.prod-type,bf_price-list.prod-code).
    end.
    assign
      varbase-rate   = 1
      varbase-scale  = 1
      varroad-tax    = bf_price-list.road-tax
      varexcise      = bf_price-list.excise
      varprice-base  = bf_price-list.price-sale
      varprice-rubl  = bf_price-list.price-sale
      vardiscnt-base = 0
      vardiscnt-rubl = 0
    .
    assign
      varfact-qnty = 0
    .
    for each bf_parts no-lock
      where bf_parts.out-code   = bf_price-list.doc-num
        and bf_parts.obj-type   = bf_price-list.obj-type
        and bf_parts.obj-code   = bf_price-list.obj-code
        and bf_parts.artic      = bf_price-list.artic
        and bf_parts.prod-type  = bf_price-list.prod-type
        and bf_parts.prod-code  = bf_price-list.prod-code
    :
      assign
        varfact-qnty = varfact-qnty + bf_parts.fact-qnty
      .
    end.
    assign
      vardoc-num   = bf_price-list.doc-num
      vardoc-code  = bf_price-list.doc-num
      varobj-type  = bf_price-list.obj-type
      varobj-code  = bf_price-list.obj-code
      varartic     = bf_price-list.artic
      varprod-type = bf_price-list.prod-type
      varprod-code = bf_price-list.prod-code
      vardoc-qnty  = varfact-qnty
      varext-doc-type = 'ot':U
    .
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  bf_price-list.obj-type
  ,input  bf_price-list.obj-code
  ,output v-host-code
  )  .
    find first bf_sysconf no-lock
      where bf_sysconf.host-code = v-host-code
      .
    if bf_sysconf.cons-vat-pc = ?
    then do:
      return error "Не задан консигнационный НДС по фирме." .
    end.
    else do:
      assign
        varcons-vat-pc = bf_sysconf.cons-vat-pc
      .
    end.
if varext-doc-type = 'ot':U or
   varext-doc-type = ?                 then do:
  assign
   out-vatp-have-vat-sltprl = yes.
end.
else do:
  find first out-vatp_doc-attrprl no-lock
    where out-vatp_doc-attrprl.doc-code  = vardoc-code
      and out-vatp_doc-attrprl.attr-code = 'envd':U
      no-error .
  if not available out-vatp_doc-attrprl then do:
    assign
      out-vatp-have-vat-sltprl = yes.
  end.
  else do:
     out-vatp-have-vat-sltprl = no.
  end.
end.
find first out-vatp_goodsprl where out-vatp_goodsprl.artic     = varartic     and
                                   out-vatp_goodsprl.prod-type = varprod-type and
                                   out-vatp_goodsprl.prod-code = varprod-code no-lock.
define variable vss-include-info39 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  varartic
  ,input  varprod-type
  ,input  varprod-code
  ,output varroot-nodeprl
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении корневого признака товара" skip
    "Артикул" varartic varprod-type varprod-code skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtat in g#library
  (input  varroot-nodeprl
  ,input  'empty-scale=request'
  ,output varempty-scaleprl
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении атрибута признака" skip
    "Артикул" varartic varprod-type varprod-code skip
    "Признак" varroot-nodeprl skip
    "Запрашивался атрибут" "empty-scale=request" skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
define variable vss-include-info40 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varoutvprbprl
  )  .
if varoutvprbprl = "base":u then do:
  assign
        road-tax-base-saleprl    =  (if varroad-tax = ? then 0 else varroad-tax * 1)
    excise-base-saleprl      =  (if varexcise   = ? then 0 else varexcise   * 1)
  .
end.
else do:
  assign
        road-tax-base-saleprl    =  (if varroad-tax = ? then 0 else varroad-tax / varbase-rate * varbase-scale)
    excise-base-saleprl      =  (if varexcise   = ? then 0 else varexcise   / varbase-rate * varbase-scale)
  .
end.
if varoutvprbprl = "rubl":u then do:
  assign
        road-tax-rubl-saleprl    = (if varroad-tax = ? then 0 else varroad-tax * 1)
    excise-rubl-saleprl      = (if varexcise   = ? then 0 else varexcise   * 1) .
end.
else do:
  assign
        road-tax-rubl-saleprl    = (if varroad-tax = ? then 0 else varroad-tax * varbase-rate / varbase-scale)
    excise-rubl-saleprl      = (if varexcise   = ? then 0 else varexcise   * varbase-rate / varbase-scale) .
end.
assign
  varis-cons-parts-haveprl =  no.
assign
  varfact-qntyprl       = 0
  varcons-qntyprl       = 0
  varprice-base-consprl = 0
  varprice-rubl-consprl = 0.
find first out-vatp_doc-lineprl where
           out-vatp_doc-lineprl.doc-code   = vardoc-num
       and out-vatp_doc-lineprl.artic      = varartic
       and out-vatp_doc-lineprl.prod-type  = varprod-type
       and out-vatp_doc-lineprl.prod-code  = varprod-code no-lock no-error.
if available out-vatp_doc-lineprl           and
  (out-vatp_doc-lineprl.status_ = 'запрос':U or out-vatp_goodsprl.gds-type = 'у':U) then do:
  assign
    varfact-qntyprl = out-vatp_doc-lineprl.fact-qnty.
end.
else do:
  for each out-vatp_partsprl where out-vatp_partsprl.out-code   = vardoc-num
                               and out-vatp_partsprl.obj-type   = varobj-type
                               and out-vatp_partsprl.obj-code   = varobj-code
                               and out-vatp_partsprl.artic      = varartic
                               and out-vatp_partsprl.prod-type  = varprod-type
                               and out-vatp_partsprl.prod-code  = varprod-code no-lock :
    if out-vatp_partsprl.purch-code = 2 then do:
assign
  price-rubl-with-tax-locoprl = out-vatp_partsprl.price-rubl
  price-base-with-tax-locoprl = out-vatp_partsprl.price-base
.
define variable vss-include-info41 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprboprl
  )  .
  if out-vatp_partsprl.out-code = 'free-zone':U     or
     out-vatp_partsprl.out-code = 'out-zone':U   or
     out-vatp_partsprl.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-sltoprl = yes.
  end.
  else do:
    find first in-vatp_doc-attroprl no-lock
      where in-vatp_doc-attroprl.doc-code  = out-vatp_partsprl.out-code
        and in-vatp_doc-attroprl.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attroprl then do:
      assign
        in-vatp-have-vat-sltoprl = yes.
    end.
    else do:
         in-vatp-have-vat-sltoprl = no.
    end.
  end.
  assign
   price-cli-with-tax-locoprl = out-vatp_partsprl.price-cli
   cli-base-rateoprl          = out-vatp_partsprl.cli-base-rate.
  ASSIGN   road-tax-base-locoprl  = (if out-vatp_partsprl.road-tax-base  = ? then 0 else out-vatp_partsprl.road-tax-base)
           road-tax-rubl-locoprl  = (if out-vatp_partsprl.road-tax-rubl  = ? then 0 else out-vatp_partsprl.road-tax-rubl).
  ASSIGN  transport-base-locoprl = (if out-vatp_partsprl.transport-base = ? then 0 else out-vatp_partsprl.transport-base)
          transport-rubl-locoprl = (if out-vatp_partsprl.transport-rubl = ? then 0 else out-vatp_partsprl.transport-rubl)
          other-base-locoprl     = (if out-vatp_partsprl.other-base     = ? then 0 else out-vatp_partsprl.other-base)
          other-rubl-locoprl     = (if out-vatp_partsprl.other-rubl     = ? then 0 else out-vatp_partsprl.other-rubl)
          vat-pc-locoprl         = (if out-vatp_partsprl.vat-pc         = ? then 0 else out-vatp_partsprl.vat-pc)
          slt-pc-locoprl         = (if out-vatp_partsprl.slt-pc         = ? then 0 else out-vatp_partsprl.slt-pc).
          ASSIGN   slt-base-locoprl    = (if in-vatp-have-vat-sltoprl = no then 0 else (price-base-with-tax-locoprl - ((if road-tax-base-locoprl  = ? then 0 else road-tax-base-locoprl) + (if transport-base-locoprl = ? then 0 else transport-base-locoprl) + (if other-base-locoprl = ? then 0 else other-base-locoprl)))                           * slt-pc-locoprl / (100 + slt-pc-locoprl))                        vat-base-locoprl    = (if in-vatp-have-vat-sltoprl = no then 0 else (price-base-with-tax-locoprl - ((if road-tax-base-locoprl  = ? then 0 else road-tax-base-locoprl) + (if transport-base-locoprl = ? then 0 else transport-base-locoprl) + (if other-base-locoprl = ? then 0 else other-base-locoprl))) * (1 - slt-pc-locoprl / (100 + slt-pc-locoprl)) * vat-pc-locoprl / (100 + vat-pc-locoprl)).
    ASSIGN   slt-rubl-locoprl    = (if in-vatp-have-vat-sltoprl = no then 0 else (price-rubl-with-tax-locoprl - ((if road-tax-rubl-locoprl  = ? then 0 else road-tax-rubl-locoprl) + (if transport-rubl-locoprl = ? then 0 else transport-rubl-locoprl) + (if other-rubl-locoprl = ? then 0 else other-rubl-locoprl)))                           * slt-pc-locoprl / (100 + slt-pc-locoprl))                        vat-rubl-locoprl    = (if in-vatp-have-vat-sltoprl = no then 0 else (price-rubl-with-tax-locoprl - ((if road-tax-rubl-locoprl  = ? then 0 else road-tax-rubl-locoprl) + (if transport-rubl-locoprl = ? then 0 else transport-rubl-locoprl) + (if other-rubl-locoprl = ? then 0 else other-rubl-locoprl))) * (1 - slt-pc-locoprl / (100 + slt-pc-locoprl)) * vat-pc-locoprl / (100 + vat-pc-locoprl)).
  assign
    exch-rate-cli-locoprl = (out-vatp_partsprl.price-rubl - transport-rubl-locoprl - other-rubl-locoprl - road-tax-rubl-locoprl - (if out-vatp_partsprl.vat-type <> 'в т. ч.':U then vat-rubl-locoprl else 0) - (if out-vatp_partsprl.slt-type <> 'в т. ч.':U then slt-rubl-locoprl else 0)) / out-vatp_partsprl.price-cli .
  assign
    slt-cli-locoprl        = slt-rubl-locoprl       / exch-rate-cli-locoprl
    vat-cli-locoprl        = vat-rubl-locoprl       / exch-rate-cli-locoprl
    road-tax-cli-locoprl   = road-tax-rubl-locoprl  / exch-rate-cli-locoprl
    transport-cli-locoprl  = 0
    other-cli-locoprl      = 0
  .
ASSIGN
          price-base-without-tax-locoprl = price-base-with-tax-locoprl - vat-base-locoprl - slt-base-locoprl - ((if road-tax-base-locoprl  = ? then 0 else road-tax-base-locoprl) + (if transport-base-locoprl = ? then 0 else transport-base-locoprl) + (if other-base-locoprl = ? then 0 else other-base-locoprl))
    price-rubl-without-tax-locoprl = price-rubl-with-tax-locoprl - vat-rubl-locoprl - slt-rubl-locoprl - ((if road-tax-rubl-locoprl  = ? then 0 else road-tax-rubl-locoprl) + (if transport-rubl-locoprl = ? then 0 else transport-rubl-locoprl) + (if other-rubl-locoprl = ? then 0 else other-rubl-locoprl))
.
      assign
        varprice-base-consprl = varprice-base-consprl + (price-base-with-tax-locoprl - (if road-tax-base-locoprl = ? then 0 else road-tax-base-locoprl))* out-vatp_partsprl.fact-qnty
        varprice-rubl-consprl = varprice-rubl-consprl + (price-rubl-with-tax-locoprl - (if road-tax-rubl-locoprl = ? then 0 else road-tax-rubl-locoprl))* out-vatp_partsprl.fact-qnty.
      assign
        varis-cons-parts-haveprl = yes
        varcons-qntyprl          = varcons-qntyprl + out-vatp_partsprl.fact-qnty.
    end.
    assign
      varfact-qntyprl = varfact-qntyprl + out-vatp_partsprl.fact-qnty.
  end.
end.
assign
  varprice-base-consprl = varprice-base-consprl / varcons-qntyprl
  varprice-rubl-consprl = varprice-rubl-consprl / varcons-qntyprl.
if varprice-base-consprl = ? then do:
  assign
    varprice-base-consprl = 0.
end.
if varprice-rubl-consprl = ? then do:
  assign
    varprice-rubl-consprl = 0.
end.
assign
    slt-base-saleprl               = (if out-vatp-have-vat-sltprl = no then 0 else varprice-base - vardiscnt-base                - road-tax-base-saleprl) * varSLT-pc / (100 + varSLT-pc)
  vat-base-buyerprl              = (if out-vatp-have-vat-sltprl = no then 0 else varprice-base - vardiscnt-base - (if out-vatp-have-vat-sltprl = no then 0 else varprice-base - vardiscnt-base                - road-tax-base-saleprl) * varSLT-pc / (100 + varSLT-pc) - road-tax-base-saleprl) * varvat-pc / (100 + varvat-pc)
  discnt-base-saleprl            = vardiscnt-base
  price-base-with-tax-saleprl    = (varprice-base - vardiscnt-base)
    slt-rubl-saleprl               = (if out-vatp-have-vat-sltprl = no then 0 else varprice-rubl - vardiscnt-rubl                - road-tax-rubl-saleprl) * varSLT-pc / (100 + varSLT-pc)
  vat-rubl-buyerprl              = (if out-vatp-have-vat-sltprl = no then 0 else varprice-rubl - vardiscnt-rubl - (if out-vatp-have-vat-sltprl = no then 0 else varprice-rubl - vardiscnt-rubl                - road-tax-rubl-saleprl) * varSLT-pc / (100 + varSLT-pc) - road-tax-rubl-saleprl) * varvat-pc / (100 + varvat-pc)
  discnt-rubl-saleprl            = vardiscnt-rubl
  price-rubl-with-tax-saleprl    = (varprice-rubl - vardiscnt-rubl)
  .
if vardoc-type = 'инв':U then do:
  assign
    varfact-qntyprl = vardoc-qnty.
end.
else do:
  assign
    varfact-qntyprl = varfact-qnty.
end.
if varis-cons-parts-haveprl = no then do:
  assign
        vat-base-saleprl               = (if out-vatp-have-vat-sltprl = no then 0 else varprice-base - vardiscnt-base - (if out-vatp-have-vat-sltprl = no then 0 else varprice-base - vardiscnt-base                - road-tax-base-saleprl) * varSLT-pc / (100 + varSLT-pc) - road-tax-base-saleprl) * varvat-pc / (100 + varvat-pc)
        vat-rubl-saleprl               = (if out-vatp-have-vat-sltprl = no then 0 else varprice-rubl - vardiscnt-rubl - (if out-vatp-have-vat-sltprl = no then 0 else varprice-rubl - vardiscnt-rubl                - road-tax-rubl-saleprl) * varSLT-pc / (100 + varSLT-pc) - road-tax-rubl-saleprl) * varvat-pc / (100 + varvat-pc).
end.
else do:
  if vardoc-type = 'инв':U then do:
    assign
            vat-base-saleprl               = (if out-vatp-have-vat-sltprl = no then 0 else (((varprice-base - vardiscnt-base) - (if out-vatp-have-vat-sltprl = no then 0 else varprice-base - vardiscnt-base                - road-tax-base-saleprl) * varSLT-pc / (100 + varSLT-pc) - road-tax-base-saleprl - varprice-base-consprl) * varcons-vat-pc / (100 + varcons-vat-pc) * vardoc-qnty * varcons-qntyprl / varfact-qntyprl + ((varprice-base - vardiscnt-base) - (if out-vatp-have-vat-sltprl = no then 0 else varprice-base - vardiscnt-base                - road-tax-base-saleprl) * varSLT-pc / (100 + varSLT-pc) - road-tax-base-saleprl) * varvat-pc / (100 + varvat-pc) * vardoc-qnty * (varfact-qntyprl - varcons-qntyprl) / varfact-qntyprl) / varfact-qntyprl)
            vat-rubl-saleprl               = (if out-vatp-have-vat-sltprl = no then 0 else (((varprice-rubl - vardiscnt-rubl) - (if out-vatp-have-vat-sltprl = no then 0 else varprice-rubl - vardiscnt-rubl                - road-tax-rubl-saleprl) * varSLT-pc / (100 + varSLT-pc) - road-tax-rubl-saleprl - varprice-rubl-consprl) * varcons-vat-pc / (100 + varcons-vat-pc) * vardoc-qnty * varcons-qntyprl / varfact-qntyprl + ((varprice-rubl - vardiscnt-rubl) - (if out-vatp-have-vat-sltprl = no then 0 else varprice-rubl - vardiscnt-rubl                - road-tax-rubl-saleprl) * varSLT-pc / (100 + varSLT-pc) - road-tax-rubl-saleprl) * varvat-pc / (100 + varvat-pc) * vardoc-qnty * (varfact-qntyprl - varcons-qntyprl) / varfact-qntyprl) / varfact-qntyprl)
     .
  end.
  else do:
    assign
            vat-base-saleprl               = (if out-vatp-have-vat-sltprl = no then 0 else (((varprice-base - vardiscnt-base) - (if out-vatp-have-vat-sltprl = no then 0 else varprice-base - vardiscnt-base                - road-tax-base-saleprl) * varSLT-pc / (100 + varSLT-pc) - road-tax-base-saleprl - varprice-base-consprl) * varcons-vat-pc / (100 + varcons-vat-pc) * varfact-qnty * varcons-qntyprl / varfact-qntyprl + ((varprice-base - vardiscnt-base) - (if out-vatp-have-vat-sltprl = no then 0 else varprice-base - vardiscnt-base                - road-tax-base-saleprl) * varSLT-pc / (100 + varSLT-pc) - varprice-base-consprl) * varvat-pc / (100 + varvat-pc) * varfact-qnty * (varfact-qntyprl - varcons-qntyprl) / varfact-qntyprl) / varfact-qntyprl)
            vat-rubl-saleprl               = (if out-vatp-have-vat-sltprl = no then 0 else (((varprice-rubl - vardiscnt-rubl) - (if out-vatp-have-vat-sltprl = no then 0 else varprice-rubl - vardiscnt-rubl                - road-tax-rubl-saleprl) * varSLT-pc / (100 + varSLT-pc) - road-tax-rubl-saleprl - varprice-rubl-consprl) * varcons-vat-pc / (100 + varcons-vat-pc) * varfact-qnty * varcons-qntyprl / varfact-qntyprl + ((varprice-rubl - vardiscnt-rubl) - (if out-vatp-have-vat-sltprl = no then 0 else varprice-rubl - vardiscnt-rubl                - road-tax-rubl-saleprl) * varSLT-pc / (100 + varSLT-pc) - varprice-rubl-consprl) * varvat-pc / (100 + varvat-pc) * varfact-qnty * (varfact-qntyprl - varcons-qntyprl) / varfact-qntyprl) / varfact-qntyprl)
     .
  end.
end.
assign
price-base-without-tax-saleprl = price-base-with-tax-saleprl - vat-base-saleprl - slt-base-saleprl - road-tax-base-saleprl
price-rubl-without-tax-saleprl = price-rubl-with-tax-saleprl - vat-rubl-saleprl - slt-rubl-saleprl - road-tax-rubl-saleprl.
  end.
end procedure.
define variable vss-include-info42 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info43 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info44 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info45 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info46 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-cntxt-host-code-obj
  ,output base-code
  )  .
define variable vss-include-info47 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable g#host-code as integer   no-undo .
assign g#host-code = v-cntxt-host-code-obj .
  DEFINE temp-table gds-prop no-undo
    field   Avrg-Sale-Price  as decimal
    field   Up-Plan          as  decimal
    field   Cost-Price       as  decimal
    field   Last-Sale-Price  as decimal
    field   LastPer-Date     as  date
    field   LastPer-Num      as  char
    field   obj-type         as  char
    field   obj-code         as  integer
    field   obj-name         as  char
    field   prod-type        as  char
    field   prod-code        as  integer
    field   prod-name        as  char
    field   artic            as  char
    field   gds-code         as  integer
    field   gds-name         as  char
    field   gds-name1        as  char
    field   grp-name         as  char
    field   unit-base        as  char
    field   b-code           as  char
    field   empty-scale      as  logical
    field   grp-code         as  integer
    field   vat-pc           as  decimal
    INDEX pi  IS PRIMARY   obj-type obj-code artic  prod-type prod-code
    INDEX pi1              obj-type obj-code b-code prod-type prod-code
    INDEX pi2              obj-type obj-code gds-code
    INDEX pi3              prod-name
    INDEX pi4              grp-code
    INDEX pi5              vat-pc
 .
  DEFINE temp-table temp-prt no-undo
    field   obj-type         as  char
    field   obj-code         as  integer
    field   prt-code         as  integer
    field   gds-code         as  integer
    field   sum              as  decimal
    field   doc-type         as  character
    field   sum-type         as  integer
    field   b-code           as  integer
    INDEX pi  IS PRIMARY   obj-type obj-code gds-code prt-code
    INDEX pi1              doc-type sum-type
  .
  DEFINE temp-table temp-sum no-undo
    field   num              as  integer
    field   sum              as  decimal
    field   doc-type         as  character
    field   sum-type         as  integer
    field   level            as  integer
    INDEX pi  IS PRIMARY   level num
    INDEX pi1              doc-type
  .
  DEFINE temp-table tt-grp-tree no-undo
    field  num          as  integer
    field  full         as character
    field  name         as character
    INDEX pi  IS PRIMARY unique full
    INDEX pi1 num
  .
  define buffer buf_goods    for goods.
  define buffer buf_clients  for clients.
  define buffer buf1_clients for clients.
  define buffer buf2_clients for clients.
  define buffer buf_gds-obj  for gds-obj.
  define buffer buf_doc-line for doc-line.
  define buffer b_obj-list for obj-list.
  define variable Counter1     as integer   no-undo .
  define variable var-client   as character initial "" no-undo .
  define variable var-client1  as character initial "" no-undo .
  define variable Line         as character no-undo .
  define variable ItogStr      as character initial "" no-undo .
  define variable titul        as integer initial 0  no-undo .
  define variable NullStr      as integer initial 0  no-undo .
  define variable CurrGrpName  as character no-undo .
  define variable beg          as integer   no-undo .
  define variable ii           as integer   no-undo .
  define variable jj           as integer   no-undo .
  define variable frmt         as character no-undo .
  define variable LastGroup    as character initial "" no-undo .
  define variable lvel        as integer initial 0 no-undo .
  define variable old-lvel    as integer initial 0 no-undo .
  define variable ind          as integer   no-undo .
  define variable ij           as integer   no-undo .
  define variable line1         as character no-undo .
  define variable v-root-node   as integer   no-undo .
  define variable is-prn-titul  as logical initial no  no-undo .
  define variable p-num       as integer   no-undo .
  define variable start-col as integer initial 0  no-undo .
  define variable frm-sum  as character initial "->>,>>>,>>9.99" no-undo .
  define variable frm-prc  as character initial "->,>>9.99" no-undo .
  define variable par-dec as character no-undo .
  define variable par-tho as character no-undo .
  run gbl/getexdel.p (output par-dec,output par-tho).
  define variable frm-qnty1 as character no-undo .
  define variable frm-sum1  as character no-undo .
  if sz-qnty = 3 then assign frm-qnty1 = "->>>>>>>>9.999" .
  else                       frm-qnty1 = "->>>>>>>>>>>9" .
  assign frm-sum1 = "->>>>>>>>>9.99" .
  def stream txt-file.
  define new shared Stream OutStream.
  define new shared stream macr_excel .
  define variable v-row       as integer   no-undo .
  define variable v-col       as integer   no-undo .
  define variable v-ind       as integer   no-undo initial 1 .
  define variable v-file-name as character no-undo .
  assign
    frmt = "X(" + string(end-sum) + ')'
    Line = fill("-", end-sum).
  .
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
  for each gds-prop :
    delete gds-prop .
  end.
  if x-SelectGood = 1 then do:
    for each obj-list :
      for each buf_gds-obj no-lock
        where buf_gds-obj.obj-type  = obj-list.obj-type
          and buf_gds-obj.obj-code  = obj-list.obj-code
        :
define variable vss-include-info48 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
  if buf_gds-obj.last-doc < x-date-start and buf_gds-obj.fact-qnty = 0 and buf_gds-obj.avrg-qnty = 0 and buf_gds-obj.fact-sale =0 and buf_gds-obj.fact-base = 0 then next .
  case RADIO-Nomenkl :
    when 2 then
      if buf_gds-obj.stts <> 0 then next .
    when 3 then
      if buf_gds-obj.stts = 0  then next .
  end case.
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
  if tog-obj = true then do:
    find first gds-prop
      where gds-prop.prod-type = buf_gds-obj.prod-type
        and gds-prop.prod-code = buf_gds-obj.prod-code
        and gds-prop.artic     = buf_gds-obj.artic
        and gds-prop.obj-type  = buf_gds-obj.obj-type
        and gds-prop.obj-code  = buf_gds-obj.obj-code
    no-error .
  end.
  else do:
    find first gds-prop
      where gds-prop.prod-type = buf_gds-obj.prod-type
        and gds-prop.prod-code = buf_gds-obj.prod-code
        and gds-prop.artic     = buf_gds-obj.artic
    no-error .
  end.
  if not available gds-prop  then do:
    find first buf_goods    no-lock where buf_goods.gds-code = buf_gds-obj.gds-code .
    find first buf1_clients no-lock where buf1_clients.obj-type = buf_gds-obj.prod-type and buf1_clients.obj-code = buf_gds-obj.prod-code .
    create gds-prop .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_goods.gds-code
  ,input  ?
  ,output ii
  ) no-error .
    if error-status :error then do:
      message vss-workfile vss-revision vss-description skip "Ошибка при определении бар-кода товара" skip
        "Артикул товара" skip buf_gds-obj.artic   view-as alert-box error .
    end.
define variable vss-include-info49 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  buf_gds-obj.gds-code
  ,input  '1':U
  ,input  ?
  ,input  g#host-code
  ,input  buf_gds-obj.obj-type
  ,input  buf_gds-obj.obj-code
  ,output gds-prop.vat-pc
  ) no-error .
    assign
       gds-prop.prod-type = buf_goods.prod-type
       gds-prop.prod-code = buf_goods.prod-code
       gds-prop.artic     = buf_goods.artic
       gds-prop.gds-code  = buf_goods.gds-code
       gds-prop.grp-name  = trim( buf_goods.grp-name )
       gds-prop.grp-code  = buf_goods.grp-code
       gds-prop.prod-name = buf1_clients.obj-name
       gds-prop.unit-base = buf_goods.unit-base
       gds-prop.b-code    = string(ii,">>>>>>>>>>>>9")
       gds-prop.gds-name1 = buf_goods.engl-name
    .
    if tog-obj = true then do:
      find first buf2_clients no-lock where buf2_clients.obj-type = obj-list.obj-type and buf2_clients.obj-code = obj-list.obj-code .
      assign
        gds-prop.obj-type  = buf2_clients.obj-type
        gds-prop.obj-code  = buf2_clients.obj-code
        gds-prop.obj-name  = buf2_clients.obj-name
      .
    end.
    else do:
      assign
        gds-prop.obj-type  = ""
        gds-prop.obj-code  = -1
        gds-prop.obj-name  = ""
      .
    end.
    if name-tov = 2 then assign gds-prop.gds-name = buf_goods.engl-name.
    else                 assign gds-prop.gds-name = buf_goods.gds-name.
define variable vss-include-info50 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  buf_goods.artic
  ,input  buf_goods.prod-type
  ,input  buf_goods.prod-code
  ,output v-root-node
  )  .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtat in g#library
  (input  v-root-node
  ,input  'empty-scale=request'
  ,output gds-prop.empty-scale
  )  .
    if x-SET_val_TYPE = 1  then assign gds-prop.Cost-Price = buf_gds-obj.last-rubl .
    else                        assign gds-prop.Cost-Price = buf_gds-obj.last-base .
  end.
  if use-column[5] = yes or use-column[6] = yes or use-column[8] = yes or use-column[9] = yes then do:
    find last price-list no-lock
      where price-list.obj-type  = buf_gds-obj.obj-type
        and price-list.obj-code  = buf_gds-obj.obj-code
        and price-list.b-code    = int(gds-prop.b-code)
        and price-list.fact-order < v-fact-order-end
      use-index fact-close no-error .
    if available price-list then do:
      find first price-doc no-lock where price-doc.doc-num  = price-list.doc-num .
      if tog-obj = true or price-doc.fact-order > gds-prop.Avrg-Sale-Price then do:
        assign
          gds-prop.Avrg-Sale-Price = price-list.fact-order
          gds-prop.Last-Sale-Price = price-list.price-sale
          gds-prop.LastPer-Date    = price-doc.doc-date
          gds-prop.LastPer-Num     = price-doc.doc-num
        .
      end .
    end .
  end.
        run CalcOstatki in this-procedure .
        run CalcOborot  in this-procedure .
      end.
    end.
  end.
  else do:
    for each obj-list :
      case x-SelectGood :
        when 1 then do:
        end.
        when 3 then do:
          for each G#cli :
            for each buf_gds-obj  no-lock
              where buf_gds-obj.obj-type  = obj-list.obj-type
                and buf_gds-obj.obj-code  = obj-list.obj-code
                and buf_gds-obj.prod-type = G#cli.obj-type
                and buf_gds-obj.prod-code = G#cli.obj-code
              use-index pi  :
define variable vss-include-info51 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
  if buf_gds-obj.last-doc < x-date-start and buf_gds-obj.fact-qnty = 0 and buf_gds-obj.avrg-qnty = 0 and buf_gds-obj.fact-sale =0 and buf_gds-obj.fact-base = 0 then next .
  case RADIO-Nomenkl :
    when 2 then
      if buf_gds-obj.stts <> 0 then next .
    when 3 then
      if buf_gds-obj.stts = 0  then next .
  end case.
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
  if tog-obj = true then do:
    find first gds-prop
      where gds-prop.prod-type = buf_gds-obj.prod-type
        and gds-prop.prod-code = buf_gds-obj.prod-code
        and gds-prop.artic     = buf_gds-obj.artic
        and gds-prop.obj-type  = buf_gds-obj.obj-type
        and gds-prop.obj-code  = buf_gds-obj.obj-code
    no-error .
  end.
  else do:
    find first gds-prop
      where gds-prop.prod-type = buf_gds-obj.prod-type
        and gds-prop.prod-code = buf_gds-obj.prod-code
        and gds-prop.artic     = buf_gds-obj.artic
    no-error .
  end.
  if not available gds-prop  then do:
    find first buf_goods    no-lock where buf_goods.gds-code = buf_gds-obj.gds-code .
    find first buf1_clients no-lock where buf1_clients.obj-type = buf_gds-obj.prod-type and buf1_clients.obj-code = buf_gds-obj.prod-code .
    create gds-prop .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_goods.gds-code
  ,input  ?
  ,output ii
  ) no-error .
    if error-status :error then do:
      message vss-workfile vss-revision vss-description skip "Ошибка при определении бар-кода товара" skip
        "Артикул товара" skip buf_gds-obj.artic   view-as alert-box error .
    end.
define variable vss-include-info52 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  buf_gds-obj.gds-code
  ,input  '1':U
  ,input  ?
  ,input  g#host-code
  ,input  buf_gds-obj.obj-type
  ,input  buf_gds-obj.obj-code
  ,output gds-prop.vat-pc
  ) no-error .
    assign
       gds-prop.prod-type = buf_goods.prod-type
       gds-prop.prod-code = buf_goods.prod-code
       gds-prop.artic     = buf_goods.artic
       gds-prop.gds-code  = buf_goods.gds-code
       gds-prop.grp-name  = trim( buf_goods.grp-name )
       gds-prop.grp-code  = buf_goods.grp-code
       gds-prop.prod-name = buf1_clients.obj-name
       gds-prop.unit-base = buf_goods.unit-base
       gds-prop.b-code    = string(ii,">>>>>>>>>>>>9")
       gds-prop.gds-name1 = buf_goods.engl-name
    .
    if tog-obj = true then do:
      find first buf2_clients no-lock where buf2_clients.obj-type = obj-list.obj-type and buf2_clients.obj-code = obj-list.obj-code .
      assign
        gds-prop.obj-type  = buf2_clients.obj-type
        gds-prop.obj-code  = buf2_clients.obj-code
        gds-prop.obj-name  = buf2_clients.obj-name
      .
    end.
    else do:
      assign
        gds-prop.obj-type  = ""
        gds-prop.obj-code  = -1
        gds-prop.obj-name  = ""
      .
    end.
    if name-tov = 2 then assign gds-prop.gds-name = buf_goods.engl-name.
    else                 assign gds-prop.gds-name = buf_goods.gds-name.
define variable vss-include-info53 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  buf_goods.artic
  ,input  buf_goods.prod-type
  ,input  buf_goods.prod-code
  ,output v-root-node
  )  .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtat in g#library
  (input  v-root-node
  ,input  'empty-scale=request'
  ,output gds-prop.empty-scale
  )  .
    if x-SET_val_TYPE = 1  then assign gds-prop.Cost-Price = buf_gds-obj.last-rubl .
    else                        assign gds-prop.Cost-Price = buf_gds-obj.last-base .
  end.
  if use-column[5] = yes or use-column[6] = yes or use-column[8] = yes or use-column[9] = yes then do:
    find last price-list no-lock
      where price-list.obj-type  = buf_gds-obj.obj-type
        and price-list.obj-code  = buf_gds-obj.obj-code
        and price-list.b-code    = int(gds-prop.b-code)
        and price-list.fact-order < v-fact-order-end
      use-index fact-close no-error .
    if available price-list then do:
      find first price-doc no-lock where price-doc.doc-num  = price-list.doc-num .
      if tog-obj = true or price-doc.fact-order > gds-prop.Avrg-Sale-Price then do:
        assign
          gds-prop.Avrg-Sale-Price = price-list.fact-order
          gds-prop.Last-Sale-Price = price-list.price-sale
          gds-prop.LastPer-Date    = price-doc.doc-date
          gds-prop.LastPer-Num     = price-doc.doc-num
        .
      end .
    end .
  end.
              run CalcOstatki in this-procedure .
              run CalcOborot  in this-procedure .
            end .
          end.
        end .
        when 2 then do:
          for each tmp#grp :
            run grplib-get-full-name in this-procedure( input tmp#grp.node-code, output CurrGrpName ) .
            for each buf_gds-obj no-lock
              where buf_gds-obj.obj-type = obj-list.obj-type
                and buf_gds-obj.obj-code = obj-list.obj-code
                and buf_gds-obj.grp-name begins CurrGrpName
              use-index obj-grp :
define variable vss-include-info54 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
  if buf_gds-obj.last-doc < x-date-start and buf_gds-obj.fact-qnty = 0 and buf_gds-obj.avrg-qnty = 0 and buf_gds-obj.fact-sale =0 and buf_gds-obj.fact-base = 0 then next .
  case RADIO-Nomenkl :
    when 2 then
      if buf_gds-obj.stts <> 0 then next .
    when 3 then
      if buf_gds-obj.stts = 0  then next .
  end case.
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
  if tog-obj = true then do:
    find first gds-prop
      where gds-prop.prod-type = buf_gds-obj.prod-type
        and gds-prop.prod-code = buf_gds-obj.prod-code
        and gds-prop.artic     = buf_gds-obj.artic
        and gds-prop.obj-type  = buf_gds-obj.obj-type
        and gds-prop.obj-code  = buf_gds-obj.obj-code
    no-error .
  end.
  else do:
    find first gds-prop
      where gds-prop.prod-type = buf_gds-obj.prod-type
        and gds-prop.prod-code = buf_gds-obj.prod-code
        and gds-prop.artic     = buf_gds-obj.artic
    no-error .
  end.
  if not available gds-prop  then do:
    find first buf_goods    no-lock where buf_goods.gds-code = buf_gds-obj.gds-code .
    find first buf1_clients no-lock where buf1_clients.obj-type = buf_gds-obj.prod-type and buf1_clients.obj-code = buf_gds-obj.prod-code .
    create gds-prop .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_goods.gds-code
  ,input  ?
  ,output ii
  ) no-error .
    if error-status :error then do:
      message vss-workfile vss-revision vss-description skip "Ошибка при определении бар-кода товара" skip
        "Артикул товара" skip buf_gds-obj.artic   view-as alert-box error .
    end.
define variable vss-include-info55 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  buf_gds-obj.gds-code
  ,input  '1':U
  ,input  ?
  ,input  g#host-code
  ,input  buf_gds-obj.obj-type
  ,input  buf_gds-obj.obj-code
  ,output gds-prop.vat-pc
  ) no-error .
    assign
       gds-prop.prod-type = buf_goods.prod-type
       gds-prop.prod-code = buf_goods.prod-code
       gds-prop.artic     = buf_goods.artic
       gds-prop.gds-code  = buf_goods.gds-code
       gds-prop.grp-name  = trim( buf_goods.grp-name )
       gds-prop.grp-code  = buf_goods.grp-code
       gds-prop.prod-name = buf1_clients.obj-name
       gds-prop.unit-base = buf_goods.unit-base
       gds-prop.b-code    = string(ii,">>>>>>>>>>>>9")
       gds-prop.gds-name1 = buf_goods.engl-name
    .
    if tog-obj = true then do:
      find first buf2_clients no-lock where buf2_clients.obj-type = obj-list.obj-type and buf2_clients.obj-code = obj-list.obj-code .
      assign
        gds-prop.obj-type  = buf2_clients.obj-type
        gds-prop.obj-code  = buf2_clients.obj-code
        gds-prop.obj-name  = buf2_clients.obj-name
      .
    end.
    else do:
      assign
        gds-prop.obj-type  = ""
        gds-prop.obj-code  = -1
        gds-prop.obj-name  = ""
      .
    end.
    if name-tov = 2 then assign gds-prop.gds-name = buf_goods.engl-name.
    else                 assign gds-prop.gds-name = buf_goods.gds-name.
define variable vss-include-info56 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  buf_goods.artic
  ,input  buf_goods.prod-type
  ,input  buf_goods.prod-code
  ,output v-root-node
  )  .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtat in g#library
  (input  v-root-node
  ,input  'empty-scale=request'
  ,output gds-prop.empty-scale
  )  .
    if x-SET_val_TYPE = 1  then assign gds-prop.Cost-Price = buf_gds-obj.last-rubl .
    else                        assign gds-prop.Cost-Price = buf_gds-obj.last-base .
  end.
  if use-column[5] = yes or use-column[6] = yes or use-column[8] = yes or use-column[9] = yes then do:
    find last price-list no-lock
      where price-list.obj-type  = buf_gds-obj.obj-type
        and price-list.obj-code  = buf_gds-obj.obj-code
        and price-list.b-code    = int(gds-prop.b-code)
        and price-list.fact-order < v-fact-order-end
      use-index fact-close no-error .
    if available price-list then do:
      find first price-doc no-lock where price-doc.doc-num  = price-list.doc-num .
      if tog-obj = true or price-doc.fact-order > gds-prop.Avrg-Sale-Price then do:
        assign
          gds-prop.Avrg-Sale-Price = price-list.fact-order
          gds-prop.Last-Sale-Price = price-list.price-sale
          gds-prop.LastPer-Date    = price-doc.doc-date
          gds-prop.LastPer-Num     = price-doc.doc-num
        .
      end .
    end .
  end.
              run CalcOstatki in this-procedure .
              run CalcOborot  in this-procedure .
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
define variable vss-include-info57 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
  if buf_gds-obj.last-doc < x-date-start and buf_gds-obj.fact-qnty = 0 and buf_gds-obj.avrg-qnty = 0 and buf_gds-obj.fact-sale =0 and buf_gds-obj.fact-base = 0 then next .
  case RADIO-Nomenkl :
    when 2 then
      if buf_gds-obj.stts <> 0 then next .
    when 3 then
      if buf_gds-obj.stts = 0  then next .
  end case.
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
  if tog-obj = true then do:
    find first gds-prop
      where gds-prop.prod-type = buf_gds-obj.prod-type
        and gds-prop.prod-code = buf_gds-obj.prod-code
        and gds-prop.artic     = buf_gds-obj.artic
        and gds-prop.obj-type  = buf_gds-obj.obj-type
        and gds-prop.obj-code  = buf_gds-obj.obj-code
    no-error .
  end.
  else do:
    find first gds-prop
      where gds-prop.prod-type = buf_gds-obj.prod-type
        and gds-prop.prod-code = buf_gds-obj.prod-code
        and gds-prop.artic     = buf_gds-obj.artic
    no-error .
  end.
  if not available gds-prop  then do:
    find first buf_goods    no-lock where buf_goods.gds-code = buf_gds-obj.gds-code .
    find first buf1_clients no-lock where buf1_clients.obj-type = buf_gds-obj.prod-type and buf1_clients.obj-code = buf_gds-obj.prod-code .
    create gds-prop .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_goods.gds-code
  ,input  ?
  ,output ii
  ) no-error .
    if error-status :error then do:
      message vss-workfile vss-revision vss-description skip "Ошибка при определении бар-кода товара" skip
        "Артикул товара" skip buf_gds-obj.artic   view-as alert-box error .
    end.
define variable vss-include-info58 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  buf_gds-obj.gds-code
  ,input  '1':U
  ,input  ?
  ,input  g#host-code
  ,input  buf_gds-obj.obj-type
  ,input  buf_gds-obj.obj-code
  ,output gds-prop.vat-pc
  ) no-error .
    assign
       gds-prop.prod-type = buf_goods.prod-type
       gds-prop.prod-code = buf_goods.prod-code
       gds-prop.artic     = buf_goods.artic
       gds-prop.gds-code  = buf_goods.gds-code
       gds-prop.grp-name  = trim( buf_goods.grp-name )
       gds-prop.grp-code  = buf_goods.grp-code
       gds-prop.prod-name = buf1_clients.obj-name
       gds-prop.unit-base = buf_goods.unit-base
       gds-prop.b-code    = string(ii,">>>>>>>>>>>>9")
       gds-prop.gds-name1 = buf_goods.engl-name
    .
    if tog-obj = true then do:
      find first buf2_clients no-lock where buf2_clients.obj-type = obj-list.obj-type and buf2_clients.obj-code = obj-list.obj-code .
      assign
        gds-prop.obj-type  = buf2_clients.obj-type
        gds-prop.obj-code  = buf2_clients.obj-code
        gds-prop.obj-name  = buf2_clients.obj-name
      .
    end.
    else do:
      assign
        gds-prop.obj-type  = ""
        gds-prop.obj-code  = -1
        gds-prop.obj-name  = ""
      .
    end.
    if name-tov = 2 then assign gds-prop.gds-name = buf_goods.engl-name.
    else                 assign gds-prop.gds-name = buf_goods.gds-name.
define variable vss-include-info59 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  buf_goods.artic
  ,input  buf_goods.prod-type
  ,input  buf_goods.prod-code
  ,output v-root-node
  )  .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtat in g#library
  (input  v-root-node
  ,input  'empty-scale=request'
  ,output gds-prop.empty-scale
  )  .
    if x-SET_val_TYPE = 1  then assign gds-prop.Cost-Price = buf_gds-obj.last-rubl .
    else                        assign gds-prop.Cost-Price = buf_gds-obj.last-base .
  end.
  if use-column[5] = yes or use-column[6] = yes or use-column[8] = yes or use-column[9] = yes then do:
    find last price-list no-lock
      where price-list.obj-type  = buf_gds-obj.obj-type
        and price-list.obj-code  = buf_gds-obj.obj-code
        and price-list.b-code    = int(gds-prop.b-code)
        and price-list.fact-order < v-fact-order-end
      use-index fact-close no-error .
    if available price-list then do:
      find first price-doc no-lock where price-doc.doc-num  = price-list.doc-num .
      if tog-obj = true or price-doc.fact-order > gds-prop.Avrg-Sale-Price then do:
        assign
          gds-prop.Avrg-Sale-Price = price-list.fact-order
          gds-prop.Last-Sale-Price = price-list.price-sale
          gds-prop.LastPer-Date    = price-doc.doc-date
          gds-prop.LastPer-Num     = price-doc.doc-num
        .
      end .
    end .
  end.
            run CalcOstatki in this-procedure .
            run CalcOborot  in this-procedure .
          end.
        end.
      end case.
    end.
  end.
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
  run rep/r-obrt21.p (input 2, input RADIO-AltObj, input end-sum, output ii, output ii   ) .
  run rep/r-obrt21.p (input 1, input RADIO-AltObj, input end-sum, output start-col, output v-row) .
  if ExportZUM then do:
    output stream txt-file to value(string(session :temp-directory) + "rpz" + string( g#report-num ) + ".txt").
    run rep/r-ob2-ex.p (input tog-obj,input RADIO-AltObj,input yes, output CurrGrpName) .
    put stream txt-file ReportNAme format "X(80)"  chr(10) .
    define variable ss1 as character no-undo .
    assign  ss1 = 'X(' + string(length (CurrGrpName)) + ')' .
    put stream txt-file CurrGrpName format ss1 chr(10) .
  end.
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
if mFrameView
then do:
   HIDE FRAME InfoFrame.
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
  run gbl/prnfilen.w
    (input  ""
    ,input  disop
    ,input  string(session :temp-directory) + "rpt" + string( g#report-num )
    ,input 7
    ,output v-user-action
    ,output v-printed
    ) .
end.
define variable vss-include-info60 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
PROCEDURE CalcOstatki :
  define buffer buf_stk-line for stk-line.
  define buffer buf_temp-prt-obj for temp-prt-obj .
define variable vss-include-info61 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
  if use-column[6] = yes or use-column[7] = yes or use-column[51] = yes then do:
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_gds-obj.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = 'crsa':U
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order < v-fact-order-end
      use-index category no-error .
    if available buf_stk-line then do:
      if x-SET_val_TYPE = 1  then  run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, "ost-end", -1, gds-prop.b-code, buf_stk-line.sum-rubl) .
      else                         run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, "ost-end", -1, gds-prop.b-code, buf_stk-line.sum-base) .
    end.
  end.
  if use-column[7] = yes or use-column[32] = yes or use-column[13] = yes then do:
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_gds-obj.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = 'cost':U
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order < v-fact-order-end
      use-index category no-error .
    if available buf_stk-line then do:
      run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, "ost-end", -1, gds-prop.b-code, buf_stk-line.fact-qnty) .
      if x-SET_val_TYPE = 1  then  run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, "ost-end", -1, gds-prop.b-code, buf_stk-line.sum-rubl) .
      else                         run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, "ost-end", -1, gds-prop.b-code, buf_stk-line.sum-base) .
    end.
  end.
  if use-column[6] = yes or use-column[50] = yes then do:
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_gds-obj.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = 'crsa':U
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order  <= v-fact-order-start
      use-index category no-error .
    if available buf_stk-line then do:
      if x-SET_val_TYPE = 1  then  run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, "ost-beg", -1, gds-prop.b-code, buf_stk-line.sum-rubl) .
      else                         run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, "ost-beg", -1, gds-prop.b-code, buf_stk-line.sum-base) .
    end.
  end.
  if use-column[12] = yes or use-column[31] = yes then do:
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_gds-obj.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = 'cost':U
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-start
      use-index category no-error .
    if available buf_stk-line then do:
      run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, "ost-beg", -1, gds-prop.b-code, buf_stk-line.fact-qnty) .
      if x-SET_val_TYPE = 1  then  run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, "ost-beg", -1, gds-prop.b-code, buf_stk-line.sum-rubl) .
      else                         run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, "ost-beg", -1, gds-prop.b-code, buf_stk-line.sum-base) .
    end.
  end.
  if RADIO-AltObj = 2 then do :
    for each buf_clients no-lock :
      find first b_obj-list no-lock where b_obj-list.obj-type = buf_clients.obj-type and b_obj-list.obj-code = buf_clients.obj-code no-error .
      if available b_obj-list then next .
      find last buf_stk-line no-lock
        where buf_stk-line.obj-type  = buf_clients.obj-type
          and buf_stk-line.obj-code  = buf_clients.obj-code
          and buf_stk-line.artic     = buf_gds-obj.artic
          and buf_stk-line.prod-type = buf_gds-obj.prod-type
          and buf_stk-line.prod-code = buf_gds-obj.prod-code
          and buf_stk-line.sum-type  = 'cost':U
          and buf_stk-line.cat-id    = '##,##'
          and buf_stk-line.fact-order < v-fact-order-end
        use-index category no-error .
      if available buf_stk-line then run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, "alt-ost", -1, gds-prop.b-code, buf_stk-line.fact-qnty) .
    end.
  end.
  else do:
    if RADIO-AltObj = 3 then do :
      assign p-num = num-entries( AltObj-list ) .
      do ii = 1 to p-num by 2 :
        find last buf_stk-line no-lock
          where buf_stk-line.obj-type  = entry( ii, AltObj-list )
            and buf_stk-line.obj-code  = integer( entry( ii + 1 , AltObj-list ))
            and buf_stk-line.artic     = buf_gds-obj.artic
            and buf_stk-line.prod-type = buf_gds-obj.prod-type
            and buf_stk-line.prod-code = buf_gds-obj.prod-code
            and buf_stk-line.sum-type  = 'cost':U
            and buf_stk-line.cat-id    = '##,##'
            and buf_stk-line.fact-order < v-fact-order-end
        use-index category no-error .
        if available buf_stk-line then run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, "alt-ost", -1, gds-prop.b-code, buf_stk-line.fact-qnty) .
      end.
    end.
  end.
if gds-prop.empty-scale = no then do:
  define var parrecid-prl as recid no-undo .
  define variable v-prt-b-code like ub.bar-code.b-code no-undo .
  define variable v-cli-base-rate like ub.bar-code.cli-base-rate no-undo .
  define buffer buf_gds-prop for gds-prop.
  define variable vat-pc-sale-prl     as decimal   no-undo .
  define variable slt-pc-sale-prl     as decimal   no-undo .
  define variable price-rubl-with-tax-sale-prl     as decimal   no-undo .
  define variable price-base-with-tax-sale-prl     as decimal   no-undo .
  define variable price-rubl-without-tax-sale-prl  as decimal   no-undo .
  define variable price-base-without-tax-sale-prl  as decimal   no-undo .
  define variable vat-base-sale-prl                as decimal   no-undo .
  define variable vat-rubl-sale-prl                as decimal   no-undo .
  define variable vat-base-buyer-prl               as decimal   no-undo .
  define variable vat-rubl-buyer-prl               as decimal   no-undo .
  define variable slt-base-sale-prl                as decimal   no-undo .
  define variable slt-rubl-sale-prl                as decimal   no-undo .
  define variable road-tax-base-sale-prl           as decimal   no-undo .
  define variable road-tax-rubl-sale-prl           as decimal   no-undo .
  define variable excise-base-sale-prl             as decimal   no-undo .
  define variable excise-rubl-sale-prl             as decimal   no-undo .
  define variable discnt-base-sale-prl             as decimal   no-undo .
  define variable discnt-rubl-sale-prl             as decimal   no-undo .
  define variable sum-zak  as decimal   no-undo .
  define variable sum-prod as decimal   no-undo .
  if use-column[7] = yes or use-column[12] = yes or use-column[31] = yes or use-column[50] = yes then do:
    run  prdoclib-init-prt-obj-by-factord in this-procedure
       ( input buf_gds-obj.obj-type  ,         input buf_gds-obj.obj-code  ,         input buf_gds-obj.artic  ,
         input buf_gds-obj.prod-type ,         input buf_gds-obj.prod-code ,         input v-fact-order-start ,
         input false ) .
    if use-column[7] = yes or use-column[31] = yes then do:
      find last buf_stk-line no-lock
        where buf_stk-line.obj-type  = buf_gds-obj.obj-type
          and buf_stk-line.obj-code  = buf_gds-obj.obj-code
          and buf_stk-line.artic     = buf_gds-obj.artic
          and buf_stk-line.prod-type = buf_gds-obj.prod-type
          and buf_stk-line.prod-code = buf_gds-obj.prod-code
          and buf_stk-line.sum-type  = 'cost':U
          and buf_stk-line.cat-id    = '##,##'
          and buf_stk-line.fact-order  <= v-fact-order-start
        use-index category no-error .
      if available buf_stk-line then do:
        if x-SET_val_TYPE = 1  then assign sum-zak = buf_stk-line.sum-rubl / buf_stk-line.fact-qnty .
        else                        assign sum-zak = buf_stk-line.sum-base / buf_stk-line.fact-qnty .
      end.
      else assign sum-zak = 0.
    end.
    for each buf_temp-prt-obj no-lock :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_gds-obj.gds-code
  ,input  buf_temp-prt-obj.prt-code
  ,output v-prt-b-code
  ) no-error .
      if error-status :error then do:
        message  vss-workfile vss-revision vss-description skip "Ошибка при определении бар-кода признака" skip
              "Код товара"   buf_gds-obj.gds-code skip  "Код признака" buf_temp-prt-obj.prt-code skip error-status :get-message(1) skip
          return-value skip
        view-as alert-box error .
        undo, return error .
      end.
define variable vss-include-info62 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodepls in g#library
  (input  buf_gds-obj.obj-type
  ,input  buf_gds-obj.obj-code
  ,input  v-prt-b-code
  ,input  0
  ,input  v-fact-order-start
  ,output parrecid-prl
  ,output v-cli-base-rate
  ) no-error .
      if error-status :error then do:
        message  vss-workfile vss-revision vss-description skip "Ошибка при определении цены бар-кода" skip
              "Объект" buf_gds-obj.obj-type buf_gds-obj.obj-code skip  "Бар-код" v-prt-b-code skip
              "fact-order" v-fact-order-start skip  error-status :get-message(1) skip  return-value skip
        view-as alert-box error .
        undo, return error .
      end.
      if parrecid-prl <> ? then do:
        run prl-vat in this-procedure
            (input  parrecid-prl
            ,output price-rubl-with-tax-sale-prl            ,output price-base-with-tax-sale-prl
            ,output price-rubl-without-tax-sale-prl         ,output price-base-without-tax-sale-prl
            ,output vat-base-sale-prl                       ,output vat-rubl-sale-prl
            ,output vat-base-buyer-prl                      ,output vat-rubl-buyer-prl
            ,output slt-base-sale-prl                       ,output slt-rubl-sale-prl
            ,output road-tax-base-sale-prl                  ,output road-tax-rubl-sale-prl
            ,output excise-base-sale-prl                    ,output excise-rubl-sale-prl
            ,output discnt-base-sale-prl                    ,output discnt-rubl-sale-prl
            ) no-error .
        if error-status :error then do:
            message vss-workfile vss-revision vss-description skip "Ошибка при вызове процеды prl-vat" skip
              "Артикул" buf_gds-obj.artic buf_gds-obj.prod-type buf_gds-obj.prod-code skip
              error-status :get-message(1) skip  return-value skip    view-as alert-box error .
            undo, return error .
        end.
      end.
      else do:
        assign
          price-rubl-with-tax-sale-prl    = 0
          price-base-with-tax-sale-prl    = 0
        .
      end.
      if x-SET_val_TYPE = 1 then assign sum-prod = price-rubl-with-tax-sale-prl * buf_temp-prt-obj.fact-qnty  .
      else                       assign sum-prod = price-base-with-tax-sale-prl * buf_temp-prt-obj.fact-qnty  .
      run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, "ost-beg", buf_temp-prt-obj.prt-code, v-prt-b-code, buf_temp-prt-obj.fact-qnty) .
      run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, "ost-beg", buf_temp-prt-obj.prt-code, v-prt-b-code, sum-zak * buf_temp-prt-obj.fact-qnty) .
      run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, "ost-beg", buf_temp-prt-obj.prt-code, v-prt-b-code, sum-prod) .
    end.
  end.
  if use-column[7] = yes or use-column[13] = yes or use-column[32] = yes or use-column[51] = yes then do:
    run  prdoclib-init-prt-obj-by-factord in this-procedure
       ( input buf_gds-obj.obj-type  ,         input buf_gds-obj.obj-code  ,         input buf_gds-obj.artic     ,
         input buf_gds-obj.prod-type ,         input buf_gds-obj.prod-code ,         input v-fact-order-end ,
         input false ) .
    if use-column[7] = yes or use-column[31] = yes then do:
      find last buf_stk-line no-lock
        where buf_stk-line.obj-type  = buf_gds-obj.obj-type
          and buf_stk-line.obj-code  = buf_gds-obj.obj-code
          and buf_stk-line.artic     = buf_gds-obj.artic
          and buf_stk-line.prod-type = buf_gds-obj.prod-type
          and buf_stk-line.prod-code = buf_gds-obj.prod-code
          and buf_stk-line.sum-type  = 'cost':U
          and buf_stk-line.cat-id    = '##,##'
          and buf_stk-line.fact-order  <= v-fact-order-end
        use-index category no-error .
      if available buf_stk-line then do:
        if x-SET_val_TYPE = 1  then assign sum-zak = buf_stk-line.sum-rubl / buf_stk-line.fact-qnty .
        else                        assign sum-zak = buf_stk-line.sum-base / buf_stk-line.fact-qnty .
      end.
      else assign sum-zak = 0.
    end.
    for each buf_temp-prt-obj no-lock :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_gds-obj.gds-code
  ,input  buf_temp-prt-obj.prt-code
  ,output v-prt-b-code
  ) no-error .
      if error-status :error then do:
        message  vss-workfile vss-revision vss-description skip "Ошибка при определении бар-кода признака" skip
              "Код товара"   buf_gds-obj.gds-code skip  "Код признака" buf_temp-prt-obj.prt-code skip error-status :get-message(1) skip
          return-value skip
        view-as alert-box error .
        undo, return error .
      end.
define variable vss-include-info63 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodepls in g#library
  (input  buf_gds-obj.obj-type
  ,input  buf_gds-obj.obj-code
  ,input  v-prt-b-code
  ,input  0
  ,input  v-fact-order-end
  ,output parrecid-prl
  ,output v-cli-base-rate
  ) no-error .
      if error-status :error then do:
        message  vss-workfile vss-revision vss-description skip "Ошибка при определении цены бар-кода" skip
              "Объект" buf_gds-obj.obj-type buf_gds-obj.obj-code skip  "Бар-код" v-prt-b-code skip
              "fact-order" v-fact-order-start skip  error-status :get-message(1) skip  return-value skip
        view-as alert-box error .
        undo, return error .
      end.
      if parrecid-prl <> ? then do:
        run prl-vat in this-procedure
            (input  parrecid-prl
            ,output price-rubl-with-tax-sale-prl   ,output price-base-with-tax-sale-prl
            ,output price-rubl-without-tax-sale-prl,output price-base-without-tax-sale-prl
            ,output vat-base-sale-prl              ,output vat-rubl-sale-prl
            ,output vat-base-buyer-prl             ,output vat-rubl-buyer-prl
            ,output slt-base-sale-prl              ,output slt-rubl-sale-prl
            ,output road-tax-base-sale-prl         ,output road-tax-rubl-sale-prl
            ,output excise-base-sale-prl           ,output excise-rubl-sale-prl
            ,output discnt-base-sale-prl           ,output discnt-rubl-sale-prl
         ) no-error .
        if error-status :error then do:
            message vss-workfile vss-revision vss-description skip "Ошибка при вызове процеды prl-vat" skip
              "Артикул" buf_gds-obj.artic buf_gds-obj.prod-type buf_gds-obj.prod-code skip
              error-status :get-message(1) skip  return-value skip    view-as alert-box error .
            undo, return error .
        end.
      end.
      else do:
        assign
          price-rubl-with-tax-sale-prl    = 0
          price-base-with-tax-sale-prl    = 0
        .
      end.
      if x-SET_val_TYPE = 1 then assign sum-prod = price-rubl-with-tax-sale-prl * buf_temp-prt-obj.fact-qnty  .
      else                       assign sum-prod = price-base-with-tax-sale-prl * buf_temp-prt-obj.fact-qnty  .
      run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, "ost-end", buf_temp-prt-obj.prt-code, v-prt-b-code, buf_temp-prt-obj.fact-qnty) .
      run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, "ost-end", buf_temp-prt-obj.prt-code, v-prt-b-code, sum-zak * buf_temp-prt-obj.fact-qnty) .
      run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, "ost-end", buf_temp-prt-obj.prt-code, v-prt-b-code, sum-prod) .
    end.
  end.
end.
END PROCEDURE.
PROCEDURE CalcOborot :
define variable vss-include-info64 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define variable v1-fact-qnty         like ub.ot-line.fact-qnty       no-undo .
define variable v1-vat-pc            like ub.doc-line.vat-pc         no-undo .
define variable v1-slt-pc            like ub.doc-line.slt-pc         no-undo .
define variable v1-sum-base          like ub.ot-line.sum-base        no-undo .
define variable v1-sum-rubl          like ub.ot-line.sum-rubl        no-undo .
define variable v1-vat-base          like ub.ot-line.vat-base        no-undo .
define variable v1-vat-rubl          like ub.ot-line.vat-rubl        no-undo .
define variable v1-slt-base          like ub.ot-line.slt-base        no-undo .
define variable v1-slt-rubl          like ub.ot-line.slt-rubl        no-undo .
define variable v1-road-tax-base     like ub.ot-line.road-tax-base   no-undo .
define variable v1-road-tax-rubl     like ub.ot-line.road-tax-rubl   no-undo .
define variable v1-transport-base    like ub.ot-line.transport-base  no-undo .
define variable v1-transport-rubl    like ub.ot-line.transport-rubl  no-undo .
define variable v1-other-base        like ub.ot-line.other-base      no-undo .
define variable v1-other-rubl        like ub.ot-line.other-rubl      no-undo .
define variable v1-excise-base       like ub.ot-line.excise-base     no-undo .
define variable v1-excise-rubl       like ub.ot-line.excise-rubl     no-undo .
define variable v2-fact-qnty         like ub.ot-line.fact-qnty       no-undo .
define variable v2-vat-pc            like ub.doc-line.vat-pc         no-undo .
define variable v2-slt-pc            like ub.doc-line.slt-pc         no-undo .
define variable v2-sum-base          like ub.ot-line.sum-base        no-undo .
define variable v2-sum-rubl          like ub.ot-line.sum-rubl        no-undo .
define variable v2-vat-base          like ub.ot-line.vat-base        no-undo .
define variable v2-vat-rubl          like ub.ot-line.vat-rubl        no-undo .
define variable v2-slt-base          like ub.ot-line.slt-base        no-undo .
define variable v2-slt-rubl          like ub.ot-line.slt-rubl        no-undo .
define variable v2-road-tax-base     like ub.ot-line.road-tax-base   no-undo .
define variable v2-road-tax-rubl     like ub.ot-line.road-tax-rubl   no-undo .
define variable v2-transport-base    like ub.ot-line.transport-base  no-undo .
define variable v2-transport-rubl    like ub.ot-line.transport-rubl  no-undo .
define variable v2-other-base        like ub.ot-line.other-base      no-undo .
define variable v2-other-rubl        like ub.ot-line.other-rubl      no-undo .
define variable v2-excise-base       like ub.ot-line.excise-base     no-undo .
define variable v2-excise-rubl       like ub.ot-line.excise-rubl     no-undo .
define variable v-prt-b-code like ub.bar-code.b-code no-undo .
define buffer buf_gds-dtl for gds-dtl.
  for each buf_doc-line no-lock
    where buf_doc-line.obj-type   = buf_gds-obj.obj-type
      and buf_doc-line.obj-code   = buf_gds-obj.obj-code
      and buf_doc-line.prod-type  = buf_gds-obj.prod-type
      and buf_doc-line.prod-code  = buf_gds-obj.prod-code
      and buf_doc-line.artic      = buf_gds-obj.artic
      and buf_doc-line.status_    = 'факт':U
      and buf_doc-line.fact-order >= v-fact-order-start
      and buf_doc-line.fact-order <  v-fact-order-end
    :
    run r-cost in this-procedure ( input buf_doc-line.doc-code   , input buf_doc-line.artic , input buf_doc-line.prod-type
                                 , input buf_doc-line.prod-code  , output v1-fact-qnty        , output v1-vat-pc
                                 , output v1-slt-pc              , output v1-sum-base         , output v1-sum-rubl
                                 , output v1-vat-base            , output v1-vat-rubl         , output v1-slt-base
                                 , output v1-slt-rubl            , output v1-road-tax-base    , output v1-road-tax-rubl
                                 , output v1-transport-base      , output v1-transport-rubl   , output v1-other-base
                                 , output v1-other-rubl          , output v1-excise-base      , output v1-excise-rubl ).
    run r-sale in this-procedure ( input buf_doc-line.doc-code   , input buf_doc-line.artic   , input buf_doc-line.prod-type
                                   , input buf_doc-line.prod-code , output v2-fact-qnty       , output v2-vat-pc
                                   , output v2-slt-pc            , output v2-sum-base         , output v2-sum-rubl
                                   , output v2-vat-base          , output v2-vat-rubl         , output v2-slt-base
                                   , output v2-slt-rubl          , output v2-road-tax-base    , output v2-road-tax-rubl
                                   , output v2-transport-base    , output v2-transport-rubl   , output v2-other-base
                                   , output v2-other-rubl        , output v2-excise-base      , output v2-excise-rubl ).
    if gds-prop.empty-scale = no then do:
      FOR EACH buf_gds-dtl no-lock
        where buf_gds-dtl.artic     = buf_doc-line.artic
          AND buf_gds-dtl.doc-code  = buf_doc-line.doc-code
          AND buf_gds-dtl.prod-code = buf_doc-line.prod-code
          AND buf_gds-dtl.prod-type = buf_doc-line.prod-type
        :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_gds-obj.gds-code
  ,input  buf_gds-dtl.prt-code
  ,output v-prt-b-code
  ) no-error .
        if error-status :error then do:
          message  vss-workfile vss-revision vss-description skip "Ошибка при определении бар-кода признака" skip
              "Код товара"   buf_gds-obj.gds-code skip  "Код признака" buf_gds-dtl.prt-code skip error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
          undo, return error .
        end.
        if buf_doc-line.ext-doc-type = 'vt':U or buf_doc-line.ext-doc-type = 'vp':U then do:
          run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, buf_doc-line.ext-doc-type, buf_gds-dtl.prt-code, v-prt-b-code, buf_gds-dtl.doc-qnty ) .
          if x-SET_val_TYPE = 1  then run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, buf_doc-line.ext-doc-type, buf_gds-dtl.prt-code, v-prt-b-code, buf_gds-dtl.doc-qnty * v1-sum-rubl / v1-fact-qnty ) .
          else                        run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, buf_doc-line.ext-doc-type, buf_gds-dtl.prt-code, v-prt-b-code, buf_gds-dtl.doc-qnty * v1-sum-base / v1-fact-qnty ) .
          if buf_doc-line.ext-doc-type <> 'ie':U         and
             buf_doc-line.ext-doc-type <> 'ep':U      then do:
            if x-SET_val_TYPE = 1  then run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, buf_doc-line.ext-doc-type, buf_gds-dtl.prt-code, v-prt-b-code, buf_gds-dtl.doc-qnty * buf_gds-dtl.price-rubl ) .
            else                        run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, buf_doc-line.ext-doc-type, buf_gds-dtl.prt-code, v-prt-b-code, buf_gds-dtl.doc-qnty * buf_gds-dtl.price-base ) .
          end.
        end.
        else do:
          run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, buf_doc-line.ext-doc-type, buf_gds-dtl.prt-code, v-prt-b-code, buf_gds-dtl.fact-qnty ) .
          if x-SET_val_TYPE = 1  then run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, buf_doc-line.ext-doc-type, buf_gds-dtl.prt-code, v-prt-b-code, buf_gds-dtl.fact-qnty * v1-sum-rubl / v1-fact-qnty ) .
          else                        run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, buf_doc-line.ext-doc-type, buf_gds-dtl.prt-code, v-prt-b-code, buf_gds-dtl.fact-qnty * v1-sum-base / v1-fact-qnty ) .
          if buf_doc-line.ext-doc-type <> 'ie':U         and
             buf_doc-line.ext-doc-type <> 'ep':U      then do:
            if x-SET_val_TYPE = 1  then run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, buf_doc-line.ext-doc-type, buf_gds-dtl.prt-code, v-prt-b-code, buf_gds-dtl.fact-qnty * buf_gds-dtl.price-rubl ) .
            else                        run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, buf_doc-line.ext-doc-type, buf_gds-dtl.prt-code, v-prt-b-code, buf_gds-dtl.fact-qnty * buf_gds-dtl.price-base ) .
            if   buf_doc-line.ext-doc-type = 'ee':U
              or buf_doc-line.ext-doc-type = 'es':U
              or buf_doc-line.ext-doc-type = 're':U
              or buf_doc-line.ext-doc-type = 'rs':U
            then do:
              if x-SET_val_TYPE = 1  then run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 3, buf_doc-line.ext-doc-type, buf_gds-dtl.prt-code, v-prt-b-code,  buf_gds-dtl.fact-qnty * buf_gds-dtl.discnt-rubl ) .
              else                        run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 3, buf_doc-line.ext-doc-type, buf_gds-dtl.prt-code, v-prt-b-code,  buf_gds-dtl.fact-qnty * buf_gds-dtl.discnt-base ) .
            end.
          end.
        end.
      end.
    end.
    if buf_doc-line.ext-doc-type = 'ee':U      or
       buf_doc-line.ext-doc-type = 'es':U or
       buf_doc-line.ext-doc-type = 'ep':U   or
       buf_doc-line.ext-doc-type = 'ev':U      or
       buf_doc-line.ext-doc-type = 'we':U      or
       buf_doc-line.ext-doc-type = 'wm':U       then
      assign
        v1-fact-qnty  = - v1-fact-qnty
        v1-sum-rubl   = - v1-sum-rubl
        v1-sum-base   = - v1-sum-base
        v2-sum-rubl   = - v2-sum-rubl
        v2-sum-base   = - v2-sum-base
        v2-other-rubl = - v2-other-rubl
        v2-other-base = - v2-other-base
      .
    run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, buf_doc-line.ext-doc-type, -1, gds-prop.b-code, v1-fact-qnty) .
    if x-SET_val_TYPE = 1  then run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, buf_doc-line.ext-doc-type, -1, gds-prop.b-code, v1-sum-rubl) .
    else                        run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, buf_doc-line.ext-doc-type, -1, gds-prop.b-code, v1-sum-base) .
    if buf_doc-line.ext-doc-type <> 'ie':U and  buf_doc-line.ext-doc-type <> 'ep':U  then do:
      if   buf_doc-line.ext-doc-type = 'ee':U
        or buf_doc-line.ext-doc-type = 'es':U
        or buf_doc-line.ext-doc-type = 're':U
        or buf_doc-line.ext-doc-type = 'rs':U
      then do:
        if x-SET_val_TYPE = 1  then do:
          run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 3, buf_doc-line.ext-doc-type, -1, gds-prop.b-code, v2-other-rubl) .
          run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 4, buf_doc-line.ext-doc-type, -1, gds-prop.b-code, v2-other-rubl * 100 / v2-sum-rubl) .
          run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 5, buf_doc-line.ext-doc-type, -1, gds-prop.b-code, v2-sum-rubl) .
        end.
        else do:
          run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 3, buf_doc-line.ext-doc-type, -1, gds-prop.b-code, v2-other-base) .
          run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 4, buf_doc-line.ext-doc-type, -1, gds-prop.b-code, v2-other-base * 100 / v2-sum-base) .
          run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 5, buf_doc-line.ext-doc-type, -1, gds-prop.b-code, v2-sum-base) .
        end.
      end.
      else do:
        if x-SET_val_TYPE = 1  then run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, buf_doc-line.ext-doc-type, -1, gds-prop.b-code, v2-sum-rubl) .
        else                        run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, buf_doc-line.ext-doc-type, -1, gds-prop.b-code, v2-sum-base) .
      end.
    end.
  end.
  assign
    v1-sum-rubl = 0
    v2-sum-rubl = 0
  .
  if buf_goods.gds-type = 'у':U then assign line1 = 'gdsr':U .
  else                                       assign line1 = 'cgdt':U .
  if use-column[67] = yes then do:
    run GetEndSum (input (line1 + 'ot':U) ,output v1-sum-rubl ) .
    run GetBegSum (input (line1 + 'ot':U) ,output v2-sum-rubl ) .
    run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, 'ot':U, -1, gds-prop.b-code, v1-sum-rubl - v2-sum-rubl) .
  end.
  run GetEndSum (input (line1 + 'ee':U) ,output v1-sum-rubl ) .
  run GetBegSum (input (line1 + 'ee':U) ,output v2-sum-rubl ) .
  run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, 'ee':U, -1, gds-prop.b-code, v2-sum-rubl - v1-sum-rubl) .
  run GetEndSum (input (line1 + 'es':U) ,output v1-sum-rubl ) .
  run GetBegSum (input (line1 + 'es':U) ,output v2-sum-rubl ) .
  run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, 'es':U, -1, gds-prop.b-code, v2-sum-rubl - v1-sum-rubl) .
  run GetEndSum (input (line1 + 're':U) ,output v1-sum-rubl ) .
  run GetBegSum (input (line1 + 're':U) ,output v2-sum-rubl ) .
  run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, 're':U, -1, gds-prop.b-code, v1-sum-rubl - v2-sum-rubl) .
  run GetEndSum (input (line1 + 'rs':U) ,output v1-sum-rubl ) .
  run GetBegSum (input (line1 + 'rs':U) ,output v2-sum-rubl ) .
  run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, 'rs':U, -1, gds-prop.b-code, v1-sum-rubl - v2-sum-rubl) .
END PROCEDURE.
procedure CalculSum :
  define input  parameter p-num as integer   no-undo .
  define buffer buf_temp-sum for temp-sum .
  for each temp-sum where temp-sum.level = -1 :
    find first buf_temp-sum
      where buf_temp-sum.level    = p-num
        and buf_temp-sum.num      = temp-sum.num
        and buf_temp-sum.doc-type = temp-sum.doc-type
        and buf_temp-sum.sum-type = temp-sum.sum-type
    no-error .
    if not available buf_temp-sum then do:
      create buf_temp-sum .
      assign
        buf_temp-sum.level    = p-num
        buf_temp-sum.num      = temp-sum.num
        buf_temp-sum.doc-type = temp-sum.doc-type
        buf_temp-sum.sum-type = temp-sum.sum-type
        buf_temp-sum.sum      = temp-sum.sum
      .
    end.
    else assign buf_temp-sum.sum = buf_temp-sum.sum + temp-sum.sum .
  end.
end procedure.
procedure PrintLine :
define variable vss-include-info65 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
  if line-counter( Outstream ) + 3 > page-size( Outstream ) then do:
    put stream outstream  skip Line format frmt skip "продолжение - на следующей странице" AT 30 SKIP .
    page stream OutStream .
    run rep/r-obrt21.p (input 2, input RADIO-AltObj, input end-sum, output ii, output ii   ) .
  end.
  if  ( v-row ) >= 63000 then do:
    Output stream Macr_Excel  close .
    run paramls-write in this-procedure (input "file",input string(v-ind),input v-file-name ) .
    run gbl/_tmpfile.p ("wb", ".txt", output v-file-name) .
    output stream  Macr_Excel to value(v-file-name) .
    v-ind = v-ind + 1 .
    run rep/r-obrt21.p (input 1, input RADIO-AltObj, input end-sum, output start-col, output v-row) .
  end.
  for each temp-sum where temp-sum.level = -1 :
    assign temp-sum.sum = 0  .
  end.
  assign jj = 1 .
  do ii = 1 to 9 :
    if use-column[ii]  = yes then assign jj = jj + 1 .
  end.
  if use-column[12] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, "ost-beg", -1, jj ) .          assign jj = jj + 1 . end.
  if use-column[31] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, "ost-beg", -1, jj ) .          assign jj = jj + 1 . end.
  if use-column[50] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, "ost-beg", -1, jj ) .          assign jj = jj + 1 . end.
  if use-column[14] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, 'ie':U, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[33] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, 'ie':U, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[15] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, 'ep':U, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[34] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, 'ep':U, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[16] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, 'ee':U, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[35] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, 'ee':U, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[52] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, 'ee':U, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[68] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 3, 'ee':U, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[77] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 4, 'ee':U, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[17] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, 're':U, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[36] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, 're':U, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[53] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, 're':U, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[69] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 3, 're':U, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[78] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 4, 're':U, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[18] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, "rs-vz", -1, jj ) . assign jj = jj + 1 . end.
  if use-column[37] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, "rs-vz", -1, jj ) . assign jj = jj + 1 . end.
  if use-column[54] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, "rs-vz", -1, jj ) . assign jj = jj + 1 . end.
  if use-column[70] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 3, "rs-vz", -1, jj ) . assign jj = jj + 1 . end.
  if use-column[79] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 4, "rs-vz", -1, jj ) . assign jj = jj + 1 . end.
  if use-column[19] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, 'es':U, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[38] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, 'es':U, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[55] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, 'es':U, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[71] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 3, 'es':U, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[80] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 4, 'es':U, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[20] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, 'rs':U, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[39] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, 'rs':U, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[56] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, 'rs':U, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[72] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 3, 'rs':U, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[81] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 4, 'rs':U, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[21] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, "rs-vz-k", -1, jj ) . assign jj = jj + 1 . end.
  if use-column[40] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, "rs-vz-k", -1, jj ) . assign jj = jj + 1 . end.
  if use-column[57] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, "rs-vz-k", -1, jj ) . assign jj = jj + 1 . end.
  if use-column[73] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 3, "rs-vz-k", -1, jj ) . assign jj = jj + 1 . end.
  if use-column[82] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 4, "rs-vz-k", -1, jj ) . assign jj = jj + 1 . end.
  if use-column[22] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, "rs-all", -1, jj ) . assign jj = jj + 1 . end.
  if use-column[41] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, "rs-all", -1, jj ) . assign jj = jj + 1 . end.
  if use-column[58] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, "rs-all", -1, jj ) . assign jj = jj + 1 . end.
  if use-column[74] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 3, "rs-all", -1, jj ) . assign jj = jj + 1 . end.
  if use-column[83] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 4, "rs-all", -1, jj ) . assign jj = jj + 1 . end.
  if use-column[23] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, "vz-all", -1, jj ) . assign jj = jj + 1 . end.
  if use-column[42] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, "vz-all", -1, jj ) . assign jj = jj + 1 . end.
  if use-column[59] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, "vz-all", -1, jj ) . assign jj = jj + 1 . end.
  if use-column[75] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 3, "vz-all", -1, jj ) . assign jj = jj + 1 . end.
  if use-column[84] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 4, "vz-all", -1, jj ) . assign jj = jj + 1 . end.
  if use-column[24] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, "rs-vz-all", -1, jj ) . assign jj = jj + 1 . end.
  if use-column[43] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, "rs-vz-all", -1, jj ) . assign jj = jj + 1 . end.
  if use-column[60] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, "rs-vz-all", -1, jj ) . assign jj = jj + 1 . end.
  if use-column[76] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 3, "rs-vz-all", -1, jj ) . assign jj = jj + 1 . end.
  if use-column[85] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 4, "rs-vz-all", -1, jj ) . assign jj = jj + 1 . end.
  if use-column[25] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, 'vt':U, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[44] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, 'vt':U, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[61] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, 'vt':U, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[26] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, 'we':U, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[45] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, 'we':U, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[62] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, 'we':U, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[27] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, 'iv':U, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[46] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, 'iv':U, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[63] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, 'iv':U, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[28] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, 'ev':U, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[47] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, 'ev':U, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[64] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, 'ev':U, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[29] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, 'rv':U, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[48] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, 'rv':U, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[65] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, 'rv':U, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[30] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, 'im':U, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[49] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, 'im':U, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[66] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, 'im':U, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[86] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, 'wm':U, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[87] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, 'wm':U, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[88] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, 'wm':U, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[67] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, 'ot':U, -1, jj ) . assign jj = jj + 1 . end.
  if use-column[13] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, "ost-end", -1, jj ) . assign jj = jj + 1 . end.
  if use-column[32] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, "ost-end", -1, jj ) . assign jj = jj + 1 . end.
  if use-column[51] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, "ost-end", -1, jj ) . assign jj = jj + 1 . end.
  if use-column[10] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, "eff-val", -1, jj ) . assign jj = jj + 1 . end.
  if use-column[11] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 4, "eff-prc", -1, jj ) . assign jj = jj + 1 . end.
  if RADIO-AltObj > 1     then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, "alt-ost", -1, jj ) . assign jj = jj + 1 . end.
  if use-column[6] = yes or use-column[7] = yes  then do:
    define variable smm1 as decimal initial 0 no-undo .
    define variable smm2 as decimal initial 0 no-undo .
    define variable tp  as integer   no-undo .
    find first temp-prt
      where temp-prt.obj-type = gds-prop.obj-type   and temp-prt.obj-code = gds-prop.obj-code
        and temp-prt.gds-code = gds-prop.gds-code   and temp-prt.prt-code = -1
        and temp-prt.sum-type = 2            and temp-prt.doc-type = 'ee':U
    no-error .
    if available temp-prt then assign smm2 = temp-prt.sum .
    find first temp-prt
      where temp-prt.obj-type = gds-prop.obj-type   and temp-prt.obj-code = gds-prop.obj-code
        and temp-prt.gds-code = gds-prop.gds-code   and temp-prt.prt-code = -1
        and temp-prt.sum-type = 2            and temp-prt.doc-type = 'es':U
    no-error .
    if available temp-prt then assign smm2 = smm2 + temp-prt.sum .
    find first temp-prt
      where temp-prt.obj-type = gds-prop.obj-type   and temp-prt.obj-code = gds-prop.obj-code
        and temp-prt.gds-code = gds-prop.gds-code   and temp-prt.prt-code = -1
        and temp-prt.sum-type = 2            and temp-prt.doc-type = 're':U
    no-error .
    if available temp-prt then assign smm2 = smm2 - temp-prt.sum .
    find first temp-prt
      where temp-prt.obj-type = gds-prop.obj-type   and temp-prt.obj-code = gds-prop.obj-code
        and temp-prt.gds-code = gds-prop.gds-code   and temp-prt.prt-code = -1
        and temp-prt.sum-type = 2            and temp-prt.doc-type = 'rs':U
    no-error .
    if available temp-prt then assign smm2 = smm2 - temp-prt.sum .
    if use-column[6] = yes then do:
      find first temp-prt
        where temp-prt.obj-type = gds-prop.obj-type   and temp-prt.obj-code = gds-prop.obj-code
          and temp-prt.gds-code = gds-prop.gds-code   and temp-prt.prt-code = -1
          and temp-prt.sum-type = 0            and temp-prt.doc-type = 'ee':U
      no-error .
      if available temp-prt then assign smm1 = temp-prt.sum .
      find first temp-prt
        where temp-prt.obj-type = gds-prop.obj-type   and temp-prt.obj-code = gds-prop.obj-code
          and temp-prt.gds-code = gds-prop.gds-code   and temp-prt.prt-code = -1
          and temp-prt.sum-type = 0            and temp-prt.doc-type = 'es':U
      no-error .
      if available temp-prt then assign smm1 = smm1 + temp-prt.sum .
      find first temp-prt
        where temp-prt.obj-type = gds-prop.obj-type   and temp-prt.obj-code = gds-prop.obj-code
          and temp-prt.gds-code = gds-prop.gds-code   and temp-prt.prt-code = -1
          and temp-prt.sum-type = 0            and temp-prt.doc-type = 're':U
      no-error .
      if available temp-prt then assign smm1 = smm1 - temp-prt.sum .
      find first temp-prt
        where temp-prt.obj-type = gds-prop.obj-type   and temp-prt.obj-code = gds-prop.obj-code
          and temp-prt.gds-code = gds-prop.gds-code   and temp-prt.prt-code = -1
          and temp-prt.sum-type = 0            and temp-prt.doc-type = 'rs':U
      no-error .
      if available temp-prt then assign smm1 = smm1 - temp-prt.sum .
      assign gds-prop.Avrg-Sale-Price = smm2 / smm1 .
    end.
    if use-column[7] = yes then do:
      find first temp-prt
        where temp-prt.obj-type = gds-prop.obj-type   and temp-prt.obj-code = gds-prop.obj-code
          and temp-prt.gds-code = gds-prop.gds-code   and temp-prt.prt-code = -1
          and temp-prt.sum-type = 1            and temp-prt.doc-type = 'ee':U
      no-error .
      if available temp-prt then assign smm1 = temp-prt.sum .
      find first temp-prt
        where temp-prt.obj-type = gds-prop.obj-type   and temp-prt.obj-code = gds-prop.obj-code
          and temp-prt.gds-code = gds-prop.gds-code   and temp-prt.prt-code = -1
          and temp-prt.sum-type = 1            and temp-prt.doc-type = 'es':U
      no-error .
      if available temp-prt then assign smm1 = smm1 + temp-prt.sum .
      find first temp-prt
        where temp-prt.obj-type = gds-prop.obj-type   and temp-prt.obj-code = gds-prop.obj-code
          and temp-prt.gds-code = gds-prop.gds-code   and temp-prt.prt-code = -1
          and temp-prt.sum-type = 1            and temp-prt.doc-type = 're':U
      no-error .
      if available temp-prt then assign smm1 = smm1 - temp-prt.sum .
      find first temp-prt
        where temp-prt.obj-type = gds-prop.obj-type   and temp-prt.obj-code = gds-prop.obj-code
          and temp-prt.gds-code = gds-prop.gds-code   and temp-prt.prt-code = -1
          and temp-prt.sum-type = 1            and temp-prt.doc-type = 'rs':U
      no-error .
      if available temp-prt then assign smm1 = smm1 - temp-prt.sum .
      assign gds-prop.Up-Plan = (smm2 - smm1) * 100 / smm1 .
    end.
  end.
  define variable  null-ostat  as logical initial yes no-undo .
  define variable  null-oborot as logical initial yes no-undo .
  assign NullStr = 0 .
  for each temp-sum where temp-sum.level = -1 and ( temp-sum.doc-type = "ost-beg" or temp-sum.doc-type = "ost-end" ) :
    if temp-sum.sum <> 0 then do:
      assign null-ostat = no .
      leave.
    end.
  end.
  for each temp-sum  where temp-sum.level = -1 and temp-sum.doc-type <> "ost-beg"  and temp-sum.doc-type <> "ost-end" :
    if temp-sum.sum <> 0 then do:
      assign null-oborot = no .
      leave.
    end.
  end.
  if ShowZero = no and ShowZero-2 = no then do:
    if null-oborot = yes then do:
      if null-ostat = yes then NullStr = 2 .
      else                     NullStr = 1 .
    end.
    else NullStr = 0 .
  end.
  if ShowZero = yes and ShowZero-2 = no then do:
    if null-oborot = yes then do:
      if null-ostat = yes then NullStr = 2 .
      else                     NullStr = 1 .
    end.
    else do:
      if null-ostat = yes then NullStr = 2 .
      else                     NullStr = 0 .
    end.
  end.
  if ShowZero = no and ShowZero-2 = yes then do:
    if null-oborot = yes then do:
      if null-ostat = yes then NullStr = 2 .
      else                     NullStr = 0 .
    end.
    else NullStr = 0 .
  end.
  if NullStr = 0 and SumsOnly = no then do:
    assign  is-prn-titul = yes  .
    run PutTitul in this-procedure .
    assign
      v-col = 1
      beg   = 1
    .
    if ExportZUM and (SumsOnly2 or gds-prop.empty-scale) then do:
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
      put stream outstream  "|" at beg gds-prop.b-code format "X(13)" .
      if ExportZUM and (SumsOnly2 or gds-prop.empty-scale) then put stream txt-file  gds-prop.b-code format "X(13)" CHR(9).
      run macr_excel_char (string(gds-prop.b-code), v-row, v-col) .
      assign v-col = v-col + 1    beg = beg + 14 .
    end.
    if use-column[2]  = yes then do:
      put stream outstream  "|" at beg gds-prop.artic format "X(16)" .
      if ExportZUM and (SumsOnly2 or gds-prop.empty-scale) then put stream txt-file  gds-prop.artic format "X(16)" CHR(9) .
      run macr_excel_char (gds-prop.artic, v-row, v-col) .
      assign v-col = v-col + 1    beg = beg + 17 .
    end.
    if use-column[3]  = yes then do:
      put stream outstream  "|" at beg gds-prop.gds-name format "X(40)" .
      if ExportZUM and (SumsOnly2 or gds-prop.empty-scale) then put stream txt-file  gds-prop.gds-name format "X(40)" CHR(9) .
      run macr_excel_char (gds-prop.gds-name, v-row, v-col) .
      assign v-col = v-col + 1    beg = beg + 41 .
    end.
    if ExportZUM and (SumsOnly2 or gds-prop.empty-scale)  then put stream txt-file  CHR(9) .
    if use-column[4]  = yes then do:
      put stream outstream  "|" at beg gds-prop.unit-base format "X(4)" .
      if ExportZUM and (SumsOnly2 or gds-prop.empty-scale) then put stream txt-file  gds-prop.unit-base format "X(4)" CHR(9) .
      run macr_excel_char (gds-prop.unit-base, v-row, v-col) .
      assign v-col = v-col + 1    beg = beg + 5 .
    end.
    if use-column[5]  = yes then do:
      put stream outstream  "|" at beg gds-prop.Cost-Price format ">>>,>>>,>>9.99" .
      if ExportZUM and (SumsOnly2 or gds-prop.empty-scale) then put stream txt-file UNFORMATTED  replace(string(gds-prop.Cost-Price,frm-sum1),".",",")  CHR(9) .
      run macr_excel_sum  ( gds-prop.Cost-Price, v-row, v-col, 2) .
      assign v-col = v-col + 1    beg = beg + 15 .
    end.
    if use-column[6]  = yes then do:
      if prod-zen = yes then do:
        put stream outstream  "|" at beg gds-prop.Avrg-Sale-Price format ">>>,>>>,>>9.99" .
        if ExportZUM and (SumsOnly2 or gds-prop.empty-scale) then put stream txt-file UNFORMATTED  replace(string(gds-prop.Avrg-Sale-Price,frm-sum1),".",",")  CHR(9) .
        run macr_excel_sum  ( gds-prop.Avrg-Sale-Price, v-row, v-col, 2) .
      end.
      else do:
        put stream outstream  "|" at beg gds-prop.Last-Sale-Price format ">>>,>>>,>>9.99" .
        if ExportZUM and (SumsOnly2 or gds-prop.empty-scale) then put stream txt-file UNFORMATTED  replace(string(gds-prop.Last-Sale-Price,frm-sum1),".",",")  CHR(9) .
        run macr_excel_sum  ( gds-prop.Last-Sale-Price, v-row, v-col, 2) .
      end.
      assign v-col = v-col + 1    beg = beg + 15 .
    end.
    if use-column[7]  = yes then do:
      put stream outstream  "|" at beg gds-prop.Up-Plan format "->>,>>>,>>9.99" .
      if ExportZUM and (SumsOnly2 or gds-prop.empty-scale) then put stream txt-file  UNFORMATTED  replace(string(gds-prop.Up-Plan,frm-sum1),".",",")   CHR(9) .
      run macr_excel_sum  ( gds-prop.Up-Plan, v-row, v-col, 2) .
      assign v-col = v-col + 1    beg = beg + 15 .
    end.
    if use-column[8]  = yes then do:
      if gds-prop.LastPer-Date <> ? then do:
        put stream outstream  "|" at beg gds-prop.LastPer-Date format "99/99/9999" .
        if ExportZUM and (SumsOnly2 or gds-prop.empty-scale) then put stream txt-file  gds-prop.LastPer-Date format "99/99/9999" CHR(9) .
        run macr_excel_char (string(gds-prop.LastPer-Date,"99.99.9999"), v-row, v-col) .
      end.
      assign v-col = v-col + 1    beg = beg + 11 .
    end.
    if use-column[9]  = yes then do:
      put stream outstream  "|" at beg gds-prop.LastPer-Num format "X(10)" .
      if ExportZUM and (SumsOnly2 or gds-prop.empty-scale) then put stream txt-file  gds-prop.LastPer-Num format "X(10)" CHR(9) .
      run macr_excel_char (gds-prop.LastPer-Num, v-row, v-col) .
      assign v-col = v-col + 1    beg = beg + 11 .
    end.
    if SumsOnly2 or gds-prop.empty-scale then do:
      for each temp-sum where temp-sum.level = -1 :
        case temp-sum.sum-type :
          when 0 then do:
            put stream outstream  "|" at beg temp-sum.sum format frm-qnty  .
            if ExportZUM then put stream txt-file UNFORMATTED  replace(string(temp-sum.sum,frm-qnty1),".",",")  CHR(9) .
            run macr_excel_sum (temp-sum.sum, v-row, v-col, sz-qnty) .
            assign  beg = beg + 15 .
          end.
          when 1 or when 2 or when 3 then do:
            put stream outstream  "|" at beg temp-sum.sum format frm-sum .
            if ExportZUM then put stream txt-file UNFORMATTED  replace(string(temp-sum.sum,frm-sum1),".",",")  CHR(9) .
            run macr_excel_sum (temp-sum.sum, v-row, v-col, 2) .
            assign  beg = beg + 15 .
          end.
          when 4 then do:
            put stream outstream  "|" at beg temp-sum.sum format frm-prc .
            if ExportZUM then put stream txt-file  UNFORMATTED  replace(string(temp-sum.sum,frm-sum1),".",",")  CHR(9) .
            run macr_excel_sum (temp-sum.sum, v-row, v-col, 2) .
            assign  beg = beg + 10 .
          end.
        end.
        assign v-col = v-col + 1 .
      end.
    end.
    else do:
      for each temp-sum where temp-sum.level = -1 :
        case temp-sum.sum-type :
          when 0 or when 1 or when 2 or when 3 then do:
            put stream outstream  "|" at beg  .     assign  beg = beg + 15 .
          end.
          when 4 then do:
            put stream outstream  "|" at beg  .     assign  beg = beg + 10 .
          end.
        end.
        assign v-col = v-col + 1 .
      end.
    end.
    put stream outstream   "|"  skip .
    if ExportZUM then put stream txt-file  chr(10) .
    assign v-row = v-row + 1 .
    if name-tov = 3 and use-column[3]  = yes then do:
      assign   v-col = 1     beg   = 1 .
      put stream outstream  "|"  .
      if use-column[1]  = yes then  assign v-col = v-col + 1    beg = beg + 14 .
      if use-column[2]  = yes then  assign v-col = v-col + 1    beg = beg + 17 .
      put stream outstream  "|" at beg gds-prop.gds-name1 format "X(40)"  "|"   "|" at end-sum skip .
      run macr_excel_char (gds-prop.gds-name1, v-row, v-col) .
      assign v-row = v-row + 1 .
    end.
  end.
  if NullStr < 2 then do:
    if tog-obj = true then run CalculSum in this-procedure (2) .
    run CalculSum in this-procedure (1) .
  end.
  if gds-prop.empty-scale = no and NullStr = 0 and SumsOnly = no then do:
    run PrintScale .
  end.
end procedure.
procedure PutItogSum :
  define input  parameter p-num as integer   no-undo .
  define buffer buf_temp-sum for temp-sum .
  if p-num = 2 then do:
    assign ItogStr = "Итого по объекту " + obj-list.obj-name + " (" + obj-list.obj-type + '#' + string(obj-list.obj-code) + ") :" .
  end.
  else do:
    if p-num = 1 then assign  ItogStr = "ИТОГО: " .
    else do:
      for each  buf_temp-sum where buf_temp-sum.level = p-num :
        if buf_temp-sum.sum <> 0 then assign is-prn-titul = yes .
      end.
      run PutTitul in this-procedure .
    end.
  end.
  if p-num < 2 or ( p-num < 4 and var-client = "" ) or var-client1 = "" then do:
    assign v-col = 1 .
    if line-counter( Outstream ) + 5 > page-size( Outstream ) then do:
      put stream outstream  skip Line format frmt skip "продолжение - на следующей странице" AT 30 SKIP .
      page stream OutStream .
      run rep/r-obrt21.p (input 2, input RADIO-AltObj, input end-sum, output ii, output ii   ) .
    end.
    run macr_excel_char (ItogStr, v-row, v-col) .
    put stream outstream "| " ItogStr format "X(60)" .
    assign
      beg = start-sum
      v-col = start-col
    .
    for each  buf_temp-sum where buf_temp-sum.level = p-num :
      case buf_temp-sum.sum-type :
        when 0 then do:
          put stream outstream  "|" at beg buf_temp-sum.sum format frm-qnty  .
          run macr_excel_sum (buf_temp-sum.sum, v-row, v-col, sz-qnty) .
          assign  beg = beg + 15 .
        end.
        when 1 or when 2 or when 3 then do:
          put stream outstream  "|" at beg buf_temp-sum.sum format frm-sum .
          run macr_excel_sum (buf_temp-sum.sum, v-row, v-col, 2) .
          assign  beg = beg + 15 .
        end.
        when 4 then do:
          put stream outstream  "|" at beg .
          assign  beg = beg + 10 .
        end.
      end.
      assign v-col = v-col + 1 .
    end.
    put stream outstream   "|"  skip Line format frmt skip.
    assign v-row = v-row + 1 .
  end.
end procedure.
procedure PutTitul :
  if titul = 0 and tog-obj = true  then do:
    define variable line1 as character no-undo .
    assign
      line1 = ""
      titul = 1
    .
    assign  line1 = "По объекту: " + obj-list.obj-name + " (" + obj-list.obj-type + '#' + string(obj-list.obj-code) + ")" .
    run macr_excel_char (line1, v-row, 1) .
    assign v-row = v-row + 1 .
    put stream outstream   Line format frmt skip .
    PUT stream OutStream "| " line1 format "X(60)" "|" at beg  SKIP .
  end.
  if SumsOnly = no and is-prn-titul then do:
    assign is-prn-titul = no .
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
procedure Add-temp-prt :
  define input  parameter p-obj-code as integer   no-undo .
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-gds-code as integer   no-undo .
  define input  parameter p-num      as integer   no-undo .
  define input  parameter p-type     as character no-undo .
  define input  parameter p-prt-code as integer   no-undo .
  define input  parameter p-b-code   as integer   no-undo .
  define input  parameter p-val      as decimal   no-undo .
  do on error undo, return error return-value :
    find first temp-prt
      where temp-prt.obj-type = p-obj-type
        and temp-prt.obj-code = p-obj-code
        and temp-prt.gds-code = p-gds-code
        and temp-prt.prt-code = p-prt-code
        and temp-prt.sum-type = p-num
        and temp-prt.doc-type = p-type
    no-error .
    if not available temp-prt then do:
      create temp-prt .
      ASSIGN
        temp-prt.obj-type = p-obj-type
        temp-prt.obj-code = p-obj-code
        temp-prt.gds-code = p-gds-code
        temp-prt.prt-code = p-prt-code
        temp-prt.b-code   = p-b-code
        temp-prt.doc-type = p-type
        temp-prt.sum-type = p-num
      .
    end.
    assign temp-prt.sum = temp-prt.sum + p-val .
  end.
end procedure.
procedure Add-temp-sum :
  define input  parameter p-obj-code as integer   no-undo .
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-gds-code as integer   no-undo .
  define input  parameter p-num      as integer   no-undo .
  define input  parameter p-type     as character no-undo .
  define input  parameter p-prt-code as integer   no-undo .
  define input  parameter p-count    as integer   no-undo .
  define buffer buf_temp-prt for temp-prt .
  define variable lvl as integer  no-undo .
  if p-prt-code <> -1 then  assign lvl = - 2 .
  else                      assign lvl = - 1 .
  do on error undo, return error return-value :
    find first temp-sum
      where temp-sum.level    = lvl
        and temp-sum.num      = p-count
        and temp-sum.doc-type = p-type
        and temp-sum.sum-type = p-num
    no-error  .
    if not available temp-sum then do:
      create temp-sum .
      assign
        temp-sum.doc-type = p-type
        temp-sum.num      = p-count
        temp-sum.level    = lvl
        temp-sum.sum-type = p-num
        temp-sum.sum      = 0
      .
    end.
    if     p-type <> "rs-vz"     and p-type <> "rs-vz-k" and p-type <> "rs-all"  and p-type <> "vz-all"
       and p-type <> "rs-vz-all" and p-type <> "eff-val" and p-type <> "eff-prc" then do:
      find first buf_temp-prt
        where buf_temp-prt.obj-type = p-obj-type          and buf_temp-prt.obj-code = p-obj-code
          and buf_temp-prt.gds-code = p-gds-code          and buf_temp-prt.prt-code = p-prt-code
          and buf_temp-prt.sum-type = p-num               and buf_temp-prt.doc-type = p-type
      no-error .
      if available buf_temp-prt then assign temp-sum.sum  = buf_temp-prt.sum  .
    end.
    else do:
      if p-num = 4 and p-type <> "eff-prc" then do:
        define buffer buf1_temp-sum for temp-sum .
        find first buf1_temp-sum where buf1_temp-sum.level = lvl and buf1_temp-sum.sum-type = 3 and buf1_temp-sum.doc-type = p-type no-error .
        if available buf1_temp-sum then assign temp-sum.sum  = buf1_temp-sum.sum * 100 .
        find first buf1_temp-sum where buf1_temp-sum.level = lvl and buf1_temp-sum.sum-type = 4 and buf1_temp-sum.doc-type = p-type no-error .
        if available buf1_temp-sum then assign temp-sum.sum  = temp-sum.sum / buf1_temp-sum.sum .
      end.
      else do:
        case p-type :
          when "rs-vz" then do:
            find first buf_temp-prt
              where buf_temp-prt.obj-type = p-obj-type       and buf_temp-prt.obj-code = p-obj-code
                and buf_temp-prt.gds-code = p-gds-code       and buf_temp-prt.prt-code = p-prt-code
                and buf_temp-prt.sum-type = p-num            and buf_temp-prt.doc-type = 'ee':U
            no-error .
            if available buf_temp-prt then assign temp-sum.sum = buf_temp-prt.sum .
            find first buf_temp-prt
              where buf_temp-prt.obj-type = p-obj-type       and buf_temp-prt.obj-code = p-obj-code
                and buf_temp-prt.gds-code = p-gds-code       and buf_temp-prt.prt-code = p-prt-code
                and buf_temp-prt.sum-type = p-num            and buf_temp-prt.doc-type = 're':U
            no-error .
            if available buf_temp-prt then assign temp-sum.sum = temp-sum.sum - buf_temp-prt.sum .
            if p-num = 2 then do:
              find first buf_temp-prt
                where buf_temp-prt.obj-type = p-obj-type       and buf_temp-prt.obj-code = p-obj-code
                  and buf_temp-prt.gds-code = p-gds-code       and buf_temp-prt.prt-code = p-prt-code
                  and buf_temp-prt.sum-type = 3            and buf_temp-prt.doc-type = 'ee':U
              no-error .
              if available buf_temp-prt then assign temp-sum.sum = temp-sum.sum - buf_temp-prt.sum .
              find first buf_temp-prt
                where buf_temp-prt.obj-type = p-obj-type       and buf_temp-prt.obj-code = p-obj-code
                  and buf_temp-prt.gds-code = p-gds-code       and buf_temp-prt.prt-code = p-prt-code
                  and buf_temp-prt.sum-type = 3            and buf_temp-prt.doc-type = 're':U
              no-error .
              if available buf_temp-prt then assign temp-sum.sum = temp-sum.sum + buf_temp-prt.sum .
            end.
          end.
          when "rs-vz-k" then do:
            find first buf_temp-prt
              where buf_temp-prt.obj-type = p-obj-type       and buf_temp-prt.obj-code = p-obj-code
                and buf_temp-prt.gds-code = p-gds-code       and buf_temp-prt.prt-code = p-prt-code
                and buf_temp-prt.sum-type = p-num            and buf_temp-prt.doc-type = 'es':U
            no-error .
            if available buf_temp-prt then assign temp-sum.sum = buf_temp-prt.sum .
            find first buf_temp-prt
              where buf_temp-prt.obj-type = p-obj-type       and buf_temp-prt.obj-code = p-obj-code
                and buf_temp-prt.gds-code = p-gds-code       and buf_temp-prt.prt-code = p-prt-code
                and buf_temp-prt.sum-type = p-num            and buf_temp-prt.doc-type = 'rs':U
            no-error .
            if available buf_temp-prt then assign temp-sum.sum = temp-sum.sum - buf_temp-prt.sum .
            if p-num = 2 then do:
              find first buf_temp-prt
                where buf_temp-prt.obj-type = p-obj-type   and buf_temp-prt.obj-code = p-obj-code
                  and buf_temp-prt.gds-code = p-gds-code   and buf_temp-prt.prt-code = p-prt-code
                  and buf_temp-prt.sum-type = 3            and buf_temp-prt.doc-type = 'es':U
              no-error .
              if available buf_temp-prt then assign temp-sum.sum = temp-sum.sum - buf_temp-prt.sum .
              find first buf_temp-prt
                where buf_temp-prt.obj-type = p-obj-type   and buf_temp-prt.obj-code = p-obj-code
                  and buf_temp-prt.gds-code = p-gds-code   and buf_temp-prt.prt-code = p-prt-code
                  and buf_temp-prt.sum-type = 3            and buf_temp-prt.doc-type = 'rs':U
              no-error .
              if available buf_temp-prt then assign temp-sum.sum = temp-sum.sum + buf_temp-prt.sum .
            end.
          end.
          when "rs-all" then do:
            find first buf_temp-prt
              where buf_temp-prt.obj-type = p-obj-type       and buf_temp-prt.obj-code = p-obj-code
                and buf_temp-prt.gds-code = p-gds-code       and buf_temp-prt.prt-code = p-prt-code
                and buf_temp-prt.sum-type = p-num            and buf_temp-prt.doc-type = 'ee':U
            no-error .
            if available buf_temp-prt then assign temp-sum.sum = buf_temp-prt.sum .
            find first buf_temp-prt
              where buf_temp-prt.obj-type = p-obj-type       and buf_temp-prt.obj-code = p-obj-code
                and buf_temp-prt.gds-code = p-gds-code       and buf_temp-prt.prt-code = p-prt-code
                and buf_temp-prt.sum-type = p-num            and buf_temp-prt.doc-type = 'es':U
            no-error .
            if available buf_temp-prt then assign temp-sum.sum = temp-sum.sum + buf_temp-prt.sum .
          end.
          when "vz-all" then do:
            find first buf_temp-prt
              where buf_temp-prt.obj-type = p-obj-type       and buf_temp-prt.obj-code = p-obj-code
                and buf_temp-prt.gds-code = p-gds-code       and buf_temp-prt.prt-code = p-prt-code
                and buf_temp-prt.sum-type = p-num            and buf_temp-prt.doc-type = 're':U
            no-error .
            if available buf_temp-prt then assign temp-sum.sum = buf_temp-prt.sum .
            find first buf_temp-prt
              where buf_temp-prt.obj-type = p-obj-type       and buf_temp-prt.obj-code = p-obj-code
                and buf_temp-prt.gds-code = p-gds-code       and buf_temp-prt.prt-code = p-prt-code
                and buf_temp-prt.sum-type = p-num            and buf_temp-prt.doc-type = 'rs':U
            no-error .
            if available buf_temp-prt then assign temp-sum.sum = temp-sum.sum + buf_temp-prt.sum .
            if p-num = 2 then do:
              find first buf_temp-prt
                where buf_temp-prt.obj-type = p-obj-type       and buf_temp-prt.obj-code = p-obj-code
                  and buf_temp-prt.gds-code = p-gds-code       and buf_temp-prt.prt-code = p-prt-code
                  and buf_temp-prt.sum-type = 3            and buf_temp-prt.doc-type = 'ee':U
              no-error .
              if available buf_temp-prt then assign temp-sum.sum = temp-sum.sum - buf_temp-prt.sum .
              find first buf_temp-prt
                where buf_temp-prt.obj-type = p-obj-type       and buf_temp-prt.obj-code = p-obj-code
                  and buf_temp-prt.gds-code = p-gds-code       and buf_temp-prt.prt-code = p-prt-code
                  and buf_temp-prt.sum-type = 3            and buf_temp-prt.doc-type = 're':U
              no-error .
              if available buf_temp-prt then assign temp-sum.sum = temp-sum.sum + buf_temp-prt.sum .
              find first buf_temp-prt
                where buf_temp-prt.obj-type = p-obj-type   and buf_temp-prt.obj-code = p-obj-code
                  and buf_temp-prt.gds-code = p-gds-code   and buf_temp-prt.prt-code = p-prt-code
                  and buf_temp-prt.sum-type = 3            and buf_temp-prt.doc-type = 'es':U
              no-error .
              if available buf_temp-prt then assign temp-sum.sum = temp-sum.sum - buf_temp-prt.sum .
              find first buf_temp-prt
                where buf_temp-prt.obj-type = p-obj-type   and buf_temp-prt.obj-code = p-obj-code
                  and buf_temp-prt.gds-code = p-gds-code   and buf_temp-prt.prt-code = p-prt-code
                  and buf_temp-prt.sum-type = 3            and buf_temp-prt.doc-type = 'rs':U
              no-error .
              if available buf_temp-prt then assign temp-sum.sum = temp-sum.sum + buf_temp-prt.sum .
            end.
          end.
          when "rs-vz-all" then do:
            find first buf_temp-prt
              where buf_temp-prt.obj-type = p-obj-type       and buf_temp-prt.obj-code = p-obj-code
                and buf_temp-prt.gds-code = p-gds-code       and buf_temp-prt.prt-code = p-prt-code
                and buf_temp-prt.sum-type = p-num            and buf_temp-prt.doc-type = 'ee':U
            no-error .
            if available buf_temp-prt then assign temp-sum.sum = buf_temp-prt.sum .
            find first buf_temp-prt
              where buf_temp-prt.obj-type = p-obj-type       and buf_temp-prt.obj-code = p-obj-code
                and buf_temp-prt.gds-code = p-gds-code       and buf_temp-prt.prt-code = p-prt-code
                and buf_temp-prt.sum-type = p-num            and buf_temp-prt.doc-type = 'es':U
            no-error .
            if available buf_temp-prt then assign temp-sum.sum = temp-sum.sum + buf_temp-prt.sum .
            find first buf_temp-prt
              where buf_temp-prt.obj-type = p-obj-type       and buf_temp-prt.obj-code = p-obj-code
                and buf_temp-prt.gds-code = p-gds-code       and buf_temp-prt.prt-code = p-prt-code
                and buf_temp-prt.sum-type = p-num            and buf_temp-prt.doc-type = 're':U
            no-error .
            if available buf_temp-prt then assign temp-sum.sum = temp-sum.sum - buf_temp-prt.sum .
            find first buf_temp-prt
              where buf_temp-prt.obj-type = p-obj-type       and buf_temp-prt.obj-code = p-obj-code
                and buf_temp-prt.gds-code = p-gds-code       and buf_temp-prt.prt-code = p-prt-code
                and buf_temp-prt.sum-type = p-num            and buf_temp-prt.doc-type = 'rs':U
            no-error .
            if available buf_temp-prt then assign temp-sum.sum = temp-sum.sum - buf_temp-prt.sum .
          end.
          when "eff-val" or when "eff-prc" then do:
            define variable sm1 as decimal initial 0 no-undo .
            define variable sm2 as decimal initial 0 no-undo .
            find first buf_temp-prt
              where buf_temp-prt.obj-type = p-obj-type       and buf_temp-prt.obj-code = p-obj-code
                and buf_temp-prt.gds-code = p-gds-code       and buf_temp-prt.prt-code = p-prt-code
                and buf_temp-prt.sum-type = 5               and buf_temp-prt.doc-type = 'ee':U
            no-error .
            if available buf_temp-prt then assign sm2 = buf_temp-prt.sum .
            find first buf_temp-prt
              where buf_temp-prt.obj-type = p-obj-type   and buf_temp-prt.obj-code = p-obj-code
                and buf_temp-prt.gds-code = p-gds-code   and buf_temp-prt.prt-code = p-prt-code
                and buf_temp-prt.sum-type = 5            and buf_temp-prt.doc-type = 'es':U
            no-error .
            if available buf_temp-prt then assign sm2 = sm2 + buf_temp-prt.sum .
            find first buf_temp-prt
              where buf_temp-prt.obj-type = p-obj-type   and buf_temp-prt.obj-code = p-obj-code
                and buf_temp-prt.gds-code = p-gds-code   and buf_temp-prt.prt-code = p-prt-code
                and buf_temp-prt.sum-type = 5            and buf_temp-prt.doc-type = 're':U
            no-error .
            if available buf_temp-prt then assign sm2 = sm2 - buf_temp-prt.sum .
            find first buf_temp-prt
              where buf_temp-prt.obj-type = p-obj-type   and buf_temp-prt.obj-code = p-obj-code
                and buf_temp-prt.gds-code = p-gds-code   and buf_temp-prt.prt-code = p-prt-code
                and buf_temp-prt.sum-type = 5            and buf_temp-prt.doc-type = 'rs':U
            no-error .
            if available buf_temp-prt then assign sm2 = sm2 - buf_temp-prt.sum .
            find first buf_temp-prt
              where buf_temp-prt.obj-type = p-obj-type   and buf_temp-prt.obj-code = p-obj-code
                and buf_temp-prt.gds-code = p-gds-code   and buf_temp-prt.prt-code = p-prt-code
                and buf_temp-prt.sum-type = 1            and buf_temp-prt.doc-type = 'ee':U
            no-error .
            if available buf_temp-prt then assign sm1 = buf_temp-prt.sum .
            find first buf_temp-prt
              where buf_temp-prt.obj-type = p-obj-type       and buf_temp-prt.obj-code = p-obj-code
                and buf_temp-prt.gds-code = p-gds-code       and buf_temp-prt.prt-code = p-prt-code
                and buf_temp-prt.sum-type = 1            and buf_temp-prt.doc-type = 'es':U
            no-error .
            if available buf_temp-prt then assign sm1 = sm1 + buf_temp-prt.sum .
            find first buf_temp-prt
              where buf_temp-prt.obj-type = p-obj-type       and buf_temp-prt.obj-code = p-obj-code
                and buf_temp-prt.gds-code = p-gds-code       and buf_temp-prt.prt-code = p-prt-code
                and buf_temp-prt.sum-type = 1            and buf_temp-prt.doc-type = 're':U
            no-error .
            if available buf_temp-prt then assign sm1 = sm1 - buf_temp-prt.sum .
            find first buf_temp-prt
              where buf_temp-prt.obj-type = p-obj-type       and buf_temp-prt.obj-code = p-obj-code
                and buf_temp-prt.gds-code = p-gds-code       and buf_temp-prt.prt-code = p-prt-code
                and buf_temp-prt.sum-type = 1            and buf_temp-prt.doc-type = 'rs':U
            no-error .
            if available buf_temp-prt then assign sm1 = sm1 - buf_temp-prt.sum .
            if p-type = "eff-prc" then assign temp-sum.sum = (sm2 - sm1) * 100 / sm1 .
            else                       assign temp-sum.sum = sm2 - sm1 .
          end.
        end.
      end.
    end.
    if temp-sum.sum = ? then assign temp-sum.sum = 0 .
  end.
end procedure.
procedure PrintScale :
  do
  on error undo, return error return-value
  :
    if line-counter( Outstream ) + 2 > page-size( Outstream ) then do:
      put stream outstream  skip Line format frmt skip "продолжение - на следующей странице" AT 30 SKIP .
      page stream OutStream .
      run rep/r-obrt21.p (input 2, input RADIO-AltObj, input end-sum, output ii, output ii) .
    end.
    if  ( v-row ) >= 63000 then do:
      Output stream Macr_Excel  close .
      run paramls-write in this-procedure (input "file",input string(v-ind),input v-file-name ) .
      run gbl/_tmpfile.p ("wb", ".txt", output v-file-name) .
      output stream  Macr_Excel to value(v-file-name) .
      v-ind = v-ind + 1 .
      run rep/r-obrt21.p (input 1, input RADIO-AltObj, input end-sum, output start-col, output v-row) .
    end.
    define variable  null-ostat1  as logical initial yes no-undo .
    define variable  null-oborot1 as logical initial yes no-undo .
    define variable  NullStr1     as integer initial 0   no-undo .
    for each temp-prt
      where temp-prt.obj-type = gds-prop.obj-type
        and temp-prt.obj-code = gds-prop.obj-code
        and temp-prt.gds-code = gds-prop.gds-code
        and temp-prt.prt-code > - 1
        break by temp-prt.prt-code
      :
      if first-of ( temp-prt.prt-code ) then do:
        for each temp-sum where temp-sum.level = -2 : assign temp-sum.sum = 0 . end.
        assign jj = 1 .
        do ii = 1 to 9 :
          if use-column[ii]  = yes then assign jj = jj + 1 .
        end.
        if use-column[12] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, "ost-beg",                   temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[31] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, "ost-beg",                   temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[50] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, "ost-beg",                   temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[14] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, 'ie':U,          temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[33] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, 'ie':U,          temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[15] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, 'ep':U,       temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[34] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, 'ep':U,       temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[16] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, 'ee':U,          temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[35] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, 'ee':U,          temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[52] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, 'ee':U,          temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[68] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 3, 'ee':U,          temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[77] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 4, 'ee':U,          temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[17] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, 're':U,      temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[36] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, 're':U,      temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[53] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, 're':U,      temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[69] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 3, 're':U,      temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[78] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 4, 're':U,      temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[18] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, "rs-vz",                     temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[37] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, "rs-vz",                     temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[54] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, "rs-vz",                     temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[70] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 3, "rs-vz",                     temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[79] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 4, "rs-vz",                     temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[19] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, 'es':U,     temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[38] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, 'es':U,     temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[55] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, 'es':U,     temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[71] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 3, 'es':U,     temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[80] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 4, 'es':U,     temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[20] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, 'rs':U, temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[39] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, 'rs':U, temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[56] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, 'rs':U, temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[72] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 3, 'rs':U, temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[81] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 4, 'rs':U, temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[21] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, "rs-vz-k",                   temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[40] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, "rs-vz-k",                   temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[57] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, "rs-vz-k",                   temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[73] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 3, "rs-vz-k",                   temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[82] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 4, "rs-vz-k",                   temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[22] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, "rs-all",                    temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[41] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, "rs-all",                    temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[58] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, "rs-all",                    temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[74] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 3, "rs-all",                    temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[83] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 4, "rs-all",                    temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[23] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, "vz-all",                    temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[42] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, "vz-all",                    temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[59] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, "vz-all",                    temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[75] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 3, "vz-all",                    temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[84] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 4, "vz-all",                    temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[24] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, "rs-vz-all",                 temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[43] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, "rs-vz-all",                 temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[60] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, "rs-vz-all",                 temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[76] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 3, "rs-vz-all",                 temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[85] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 4, "rs-vz-all",                 temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[25] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, 'vt':U,                temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[44] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, 'vt':U,                temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[61] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, 'vt':U,                temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[26] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, 'we':U,          temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[45] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, 'we':U,          temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[62] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, 'we':U,          temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[27] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, 'iv':U,          temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[46] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, 'iv':U,          temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[63] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, 'iv':U,          temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[28] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, 'ev':U,          temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[47] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, 'ev':U,          temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[64] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, 'ev':U,          temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[29] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, 'rv':U,      temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[48] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, 'rv':U,      temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[65] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, 'rv':U,      temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[30] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, 'im':U,           temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[49] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, 'im':U,           temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[66] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, 'im':U,           temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[86] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, 'wm':U,           temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[87] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, 'wm':U,           temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[88] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, 'wm':U,           temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[67] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, 'ot':U,           temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[13] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, "ost-end",                   temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[32] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, "ost-end",                   temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        if use-column[51] = yes then do:  run Add-temp-sum ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, "ost-end",                   temp-prt.prt-code, jj ) . assign jj = jj + 1 . end.
        assign
          null-ostat1  = yes
          null-oborot1 = yes
          NullStr1     = 0
        .
        for each temp-sum where temp-sum.level = -2 and ( temp-sum.doc-type = "ost-beg" or temp-sum.doc-type = "ost-end" ) :
          if temp-sum.sum <> 0 then do:
            assign null-ostat1 = no .
            leave.
          end.
        end.
        for each temp-sum  where temp-sum.level = -2 and temp-sum.doc-type <> "ost-beg"  and temp-sum.doc-type <> "ost-end" :
          if temp-sum.sum <> 0 then do:
            assign null-oborot1 = no .
            leave.
          end.
        end.
        if ShowZero = no and ShowZero-2 = no then do:
          if null-oborot1 = yes then do:
            if null-ostat1 = yes then NullStr1 = 2 .
            else                      NullStr1 = 1 .
          end.
          else NullStr1 = 0 .
        end.
        if ShowZero = yes and ShowZero-2 = no then do:
          if null-oborot1 = yes then do:
            if null-ostat1 = yes then NullStr1 = 2 .
            else                      NullStr1 = 1 .
          end.
          else do:
            if null-ostat1 = yes then NullStr1 = 2 .
            else                      NullStr1 = 0 .
          end.
        end.
        if ShowZero = no and ShowZero-2 = yes then do:
          if null-oborot1 = yes then do:
            if null-ostat1 = yes then NullStr1 = 2 .
            else                      NullStr1 = 0 .
          end.
          else NullStr1 = 0 .
        end.
        if NullStr1 > 0 then next .
        assign
          v-col = 1
          beg   = 1
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
          put stream outstream  "|" at beg temp-prt.b-code format ">>>>>>>>>>>>9" .
          if ExportZUM then put stream txt-file  temp-prt.b-code format ">>>>>>>>>>>>9" CHR(9) .
          run macr_excel_char (string(temp-prt.b-code), v-row, v-col) .
          assign v-col = v-col + 1    beg = beg + 14 .
        end.
        if use-column[2]  = yes then do:
           if ExportZUM then put stream txt-file gds-prop.artic format "X(16)" CHR(9) .
           assign v-col = v-col + 1    beg = beg + 17 .
        end.
        FIND FIRST gds-prt WHERE gds-prt.node-code  = temp-prt.prt-code NO-LOCK no-error .
        if use-column[3]  = yes then do:
          put stream outstream  "|" at beg '  /'+ gds-prt.f-name format "X(40)" .
          run macr_excel_char ('  /'+ gds-prt.f-name, v-row, v-col) .
          if ExportZUM then put stream txt-file  gds-prop.gds-name format "X(40)" CHR(9) .
          assign v-col = v-col + 1    beg = beg + 41 .
        end.
        if ExportZUM then put stream txt-file  ' /'+ gds-prt.f-name format "X(60)" CHR(9) .
        if use-column[4]  = yes then do:
          put stream outstream  "|" at beg gds-prop.unit-base format "X(4)" .
          if ExportZUM then put stream txt-file  gds-prop.unit-base format "X(4)" CHR(9) .
          run macr_excel_char (gds-prop.unit-base, v-row, v-col) .
          assign v-col = v-col + 1    beg = beg + 5 .
        end.
        if use-column[5]  = yes then do:
          if ExportZUM then put stream txt-file UNFORMATTED  replace(string(gds-prop.Cost-Price,frm-sum1),".",",")  CHR(9) .
          assign v-col = v-col + 1    beg = beg + 15 .
        end.
        if use-column[6]  = yes then do:
          if prod-zen = yes then do:
            if ExportZUM then put stream txt-file UNFORMATTED  replace(string(gds-prop.Avrg-Sale-Price,frm-sum1),".",",")  CHR(9) .
          end.
          else do:
            if ExportZUM then put stream txt-file UNFORMATTED  replace(string(gds-prop.Last-Sale-Price,frm-sum1),".",",")  CHR(9) .
          end.
          assign v-col = v-col + 1    beg = beg + 15 .
        end.
        if use-column[7]  = yes then do:
          if ExportZUM then put stream txt-file UNFORMATTED  replace(string(gds-prop.Up-Plan,frm-sum1),".",",")  CHR(9) .
          assign v-col = v-col + 1    beg = beg + 15 .
        end.
        if use-column[8]  = yes then do:
          if ExportZUM then put stream txt-file gds-prop.LastPer-Date format "99/99/9999"   CHR(9) .
          assign v-col = v-col + 1    beg = beg + 11 .
        end.
        if use-column[9]  = yes then do:
          if ExportZUM then put stream txt-file gds-prop.LastPer-Num format "X(10)" CHR(9) .
          assign v-col = v-col + 1    beg = beg + 11 .
        end.
        for each temp-sum where temp-sum.level = -2 :
          case temp-sum.sum-type :
            when 0 then do:
              put stream outstream  "|" at beg temp-sum.sum format frm-qnty  .
              if ExportZUM then put stream txt-file UNFORMATTED  replace(string(temp-sum.sum,frm-qnty1),".",",") CHR(9) .
              run macr_excel_sum (temp-sum.sum, v-row, v-col, sz-qnty) .
              assign  beg = beg + 15 .
            end.
            when  2 then do:
              put stream outstream  "|" at beg temp-sum.sum format frm-sum .
              if ExportZUM then put stream txt-file UNFORMATTED  replace(string(temp-sum.sum,frm-sum1),".",",")  CHR(9) .
              run macr_excel_sum (temp-sum.sum, v-row, v-col, 2) .
              assign  beg = beg + 15 .
            end.
            when 1 or when 3 then do:
              if ExportZUM then put stream txt-file  CHR(9) .
              put stream outstream  "|" at beg .
              assign  beg = beg + 15 .
            end.
            when 4 then do:
              if ExportZUM then put stream txt-file  CHR(9) .
              put stream outstream  "|" at beg .
              assign  beg = beg + 10 .
            end.
          end.
          assign v-col = v-col + 1 .
        end.
        put stream outstream   "|"  skip .
        if ExportZUM then put stream txt-file  chr(10) .
        assign v-row = v-row + 1 .
      end.
    end.
  end.
end procedure.
procedure GetBegSum :
  do on error undo, return error return-value :
    define input  parameter p-find as character no-undo .
    define output parameter p-sum as decimal   no-undo .
    define buffer buf_stk-line for stk-line.
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_gds-obj.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.sum-type  = p-find
        and buf_stk-line.fact-order <= v-fact-order-start
      use-index category no-error .
    if available buf_stk-line then do:
      if x-SET_val_TYPE = 1  then assign p-sum = buf_stk-line.sum-rubl .
      else                        assign p-sum = buf_stk-line.sum-base .
    end.
  end.
end procedure.
procedure GetEndSum :
  do on error undo, return error return-value :
    define input  parameter p-find as character no-undo .
    define output parameter p-sum as decimal   no-undo .
    define buffer buf_stk-line for stk-line.
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_gds-obj.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.sum-type  = p-find
        and buf_stk-line.fact-order < v-fact-order-end
      use-index category no-error .
    if available buf_stk-line then do:
      if x-SET_val_TYPE = 1  then assign p-sum = buf_stk-line.sum-rubl .
      else                        assign p-sum = buf_stk-line.sum-base .
    end.
  end.
end procedure.
PROCEDURE foreach1 :
  if tog-obj = true then do:
    for each obj-list no-lock :
      assign  titul = 0 .
      for each temp-sum where temp-sum.level = 2 : assign temp-sum.sum = 0 . end.
      for each gds-prop where gds-prop.obj-type = obj-list.obj-type and gds-prop.obj-code = obj-list.obj-code by if SortType = "sort-code":U   then  gds-prop.b-code Else  gds-prop.artic :
        run PrintLine in this-procedure .
      End.
      run PutItogSum in this-procedure (2) .
    end.
  end.
  else do:
    for each gds-prop by if SortType = "sort-code":U   then  gds-prop.b-code Else  gds-prop.artic :
      run PrintLine in this-procedure .
    End.
  end.
  run PutItogSum in this-procedure (1) .
END PROCEDURE.
PROCEDURE foreach2 :
  if tog-obj = true then do:
    for each obj-list no-lock :
      assign  titul = 0 .
      for each temp-sum where temp-sum.level = 2 : assign temp-sum.sum = 0 . end.
      for each gds-prop where gds-prop.obj-type = obj-list.obj-type and gds-prop.obj-code = obj-list.obj-code break by gds-prop.prod-name by if SortType = "sort-code":U   then  gds-prop.b-code Else  gds-prop.artic :
define variable vss-include-info66 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        if first-of(gds-prop.prod-name) then do:
          assign var-client = "Производитель " + gds-prop.prod-name .
          for each temp-sum where temp-sum.level = 3 : assign temp-sum.sum = 0 . end.
        End.
        run PrintLine in this-procedure .
        if NullStr < 2 then run CalculSum in this-procedure (3) .
        if last-of(gds-prop.prod-name) then do:
          assign ItogStr = "Итого по производителю " + gds-prop.prod-name + ":"  .
          run PutItogSum in this-procedure (3) .
        End.
      End.
      run PutItogSum in this-procedure (2).
    end.
  end.
  else do:
    for each gds-prop break by gds-prop.prod-name by if SortType = "sort-code":U   then  gds-prop.b-code Else  gds-prop.artic :
define variable vss-include-info67 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        if first-of(gds-prop.prod-name) then do:
          assign var-client = "Производитель " + gds-prop.prod-name .
          for each temp-sum where temp-sum.level = 3 : assign temp-sum.sum = 0 . end.
        End.
        run PrintLine in this-procedure .
        if NullStr < 2 then run CalculSum in this-procedure (3) .
        if last-of(gds-prop.prod-name) then do:
          assign ItogStr = "Итого по производителю " + gds-prop.prod-name + ":"  .
          run PutItogSum in this-procedure (3) .
        End.
    End.
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
      for each temp-sum where temp-sum.level = 2 : assign temp-sum.sum = 0 . end.
      for each gds-prop
        where gds-prop.obj-type = obj-list.obj-type
          and gds-prop.obj-code = obj-list.obj-code
        break by gds-prop.grp-name by if SortType = "sort-code":U   then  gds-prop.b-code Else  gds-prop.artic :
define variable vss-include-info68 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
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
                  assign ItogStr = "Итог по гр. " + LastGroup + ":"   .
                  run PutItogSum in this-procedure (3) .
                end.
                assign
                  LastGroup  = CurrGrpName
                  var-client = "Группа " + CurrGrpName
                .
                for each temp-sum where temp-sum.level = 3 : assign temp-sum.sum = 0 . end.
              end.
            end.
            else do:
              if LastGroup <> "" then do:
                assign ItogStr = "Итог по гр. " + LastGroup + ":"   .
                run PutItogSum in this-procedure (3) .
              end.
              assign
                LastGroup  = gds-prop.grp-name
                var-client = "Группа " + gds-prop.grp-name
              .
              for each temp-sum where temp-sum.level = 3 : assign temp-sum.sum = 0 . end.
            end.
          end .
          else do:
            assign var-client = "Группа " + gds-prop.grp-name .
            for each temp-sum where temp-sum.level = 3 : assign temp-sum.sum = 0 . end.
          end .
        End .
        run PrintLine in this-procedure .
        if NullStr < 2 then run CalculSum in this-procedure (3) .
        if last-of(gds-prop.grp-name) and tog-lavel = no then do:
          assign ItogStr = "Итог по гр. " + gds-prop.grp-name + ":" .
          run PutItogSum in this-procedure (3) .
        End.
      End.
      else do:
        if first-of(gds-prop.grp-name) then do:
          assign
            lvel = num-entries( right-trim(gds-prop.grp-name, chr(47)), chr(47) )
            CurrGrpName = ""
          .
          do ind = 1 to lvel :
            assign CurrGrpName = CurrGrpName + entry ( ind, gds-prop.grp-name, chr(47) )  + chr(47)  .
            find first tt-grp-tree where tt-grp-tree.full = CurrGrpName  no-error .
            if not available tt-grp-tree then LEAVE.
          end.
          do ij = old-lvel to ind by -1 :
            find first tt-grp-tree where tt-grp-tree.num = (ij + 3) .
            assign ItogStr = "" .
            do jj = 1 to ij : assign ItogStr = ItogStr + "  " . end.
            assign ItogStr = ItogStr + tt-grp-tree.name .
            if ij <= var-lavel then run PutItogSum in this-procedure (tt-grp-tree.num) .
            delete tt-grp-tree .
          end.
          assign old-lvel = lvel .
          do ij = ind to lvel :
            create tt-grp-tree .
            if ij > ind then assign CurrGrpName = CurrGrpName + entry ( ij, gds-prop.grp-name, chr(47) )  + chr(47)  .
            assign
              tt-grp-tree.num  = ij + 3
              tt-grp-tree.full = CurrGrpName
              tt-grp-tree.name = entry ( ij, gds-prop.grp-name, chr(47) )
              var-client = "Группа " + tt-grp-tree.name
            .
            for each temp-sum where temp-sum.level = tt-grp-tree.num : assign temp-sum.sum = 0 . end.
          end.
        end.
        run PrintLine in this-procedure .
        if NullStr < 2 then do:
          for each tt-grp-tree :
            run CalculSum in this-procedure (tt-grp-tree.num) .
          end.
        end.
      End.
      End.
      if tog-lavel = yes then do:
        if tog-tree = yes then do:
          do ij = old-lvel to ind by -1 :
            find first tt-grp-tree where tt-grp-tree.num = (ij + 3) .
            assign ItogStr = "" .
            do jj = 1 to ij : assign ItogStr = ItogStr + "  " . end.
            assign ItogStr = ItogStr + tt-grp-tree.name .
            if ij <= var-lavel then do:
              run PutItogSum in this-procedure (tt-grp-tree.num) .
            end.
            delete tt-grp-tree .
          end.
          assign old-lvel = 0 .
        end.
        else do:
          if LastGroup <> "" then do:
            assign ItogStr = "Итог по гр. " + LastGroup + ":"   .
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
    for each gds-prop break by gds-prop.grp-name by if SortType = "sort-code":U   then  gds-prop.b-code Else  gds-prop.artic :
define variable vss-include-info69 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
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
                  assign ItogStr = "Итог по гр. " + LastGroup + ":"   .
                  run PutItogSum in this-procedure (3) .
                end.
                assign
                  LastGroup  = CurrGrpName
                  var-client = "Группа " + CurrGrpName
                .
                for each temp-sum where temp-sum.level = 3 : assign temp-sum.sum = 0 . end.
              end.
            end.
            else do:
              if LastGroup <> "" then do:
                assign ItogStr = "Итог по гр. " + LastGroup + ":"   .
                run PutItogSum in this-procedure (3) .
              end.
              assign
                LastGroup  = gds-prop.grp-name
                var-client = "Группа " + gds-prop.grp-name
              .
              for each temp-sum where temp-sum.level = 3 : assign temp-sum.sum = 0 . end.
            end.
          end .
          else do:
            assign var-client = "Группа " + gds-prop.grp-name .
            for each temp-sum where temp-sum.level = 3 : assign temp-sum.sum = 0 . end.
          end .
        End .
        run PrintLine in this-procedure .
        if NullStr < 2 then run CalculSum in this-procedure (3) .
        if last-of(gds-prop.grp-name) and tog-lavel = no then do:
          assign ItogStr = "Итог по гр. " + gds-prop.grp-name + ":" .
          run PutItogSum in this-procedure (3) .
        End.
      End.
      else do:
        if first-of(gds-prop.grp-name) then do:
          assign
            lvel = num-entries( right-trim(gds-prop.grp-name, chr(47)), chr(47) )
            CurrGrpName = ""
          .
          do ind = 1 to lvel :
            assign CurrGrpName = CurrGrpName + entry ( ind, gds-prop.grp-name, chr(47) )  + chr(47)  .
            find first tt-grp-tree where tt-grp-tree.full = CurrGrpName  no-error .
            if not available tt-grp-tree then LEAVE.
          end.
          do ij = old-lvel to ind by -1 :
            find first tt-grp-tree where tt-grp-tree.num = (ij + 3) .
            assign ItogStr = "" .
            do jj = 1 to ij : assign ItogStr = ItogStr + "  " . end.
            assign ItogStr = ItogStr + tt-grp-tree.name .
            if ij <= var-lavel then run PutItogSum in this-procedure (tt-grp-tree.num) .
            delete tt-grp-tree .
          end.
          assign old-lvel = lvel .
          do ij = ind to lvel :
            create tt-grp-tree .
            if ij > ind then assign CurrGrpName = CurrGrpName + entry ( ij, gds-prop.grp-name, chr(47) )  + chr(47)  .
            assign
              tt-grp-tree.num  = ij + 3
              tt-grp-tree.full = CurrGrpName
              tt-grp-tree.name = entry ( ij, gds-prop.grp-name, chr(47) )
              var-client = "Группа " + tt-grp-tree.name
            .
            for each temp-sum where temp-sum.level = tt-grp-tree.num : assign temp-sum.sum = 0 . end.
          end.
        end.
        run PrintLine in this-procedure .
        if NullStr < 2 then do:
          for each tt-grp-tree :
            run CalculSum in this-procedure (tt-grp-tree.num) .
          end.
        end.
      End.
    End.
    if tog-lavel = yes then do:
      if tog-tree = yes then do:
        do ij = old-lvel to ind by -1 :
          find first tt-grp-tree where tt-grp-tree.num = (ij + 3) .
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
          assign ItogStr = "Итог по гр. " + LastGroup + ":"   .
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
      for each temp-sum where temp-sum.level = 2 : assign temp-sum.sum = 0 . end.
      for each gds-prop
        where gds-prop.obj-type = obj-list.obj-type
          and gds-prop.obj-code = obj-list.obj-code
        break by gds-prop.prod-name
              by gds-prop.grp-code
              by if SortType = "sort-code":U   then  gds-prop.b-code Else  gds-prop.artic :
define variable vss-include-info70 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        if first-of(gds-prop.prod-name) then do:
          assign var-client = "Производитель " + gds-prop.prod-name .
          for each temp-sum where temp-sum.level = 3 : assign temp-sum.sum = 0 . end.
        End.
        if first-of(gds-prop.grp-code) then do:
          assign var-client1 = "Группа " + gds-prop.grp-name .
          for each temp-sum where temp-sum.level = 4 : assign temp-sum.sum = 0 . end.
        End.
        run PrintLine in this-procedure .
        if NullStr < 2 then do:
          run CalculSum in this-procedure (3) .
          run CalculSum in this-procedure (4) .
        end.
        if last-of(gds-prop.grp-code) then do:
          assign ItogStr = "Итого по группе " + gds-prop.grp-name + ":"  .
          run PutItogSum in this-procedure (4) .
        End.
        if last-of(gds-prop.prod-name) then do:
          assign ItogStr = "Итого по производителю " + gds-prop.prod-name + ":" .
          run PutItogSum in this-procedure (3) .
        End.
      End.
      run PutItogSum in this-procedure (2) .
    end.
  end.
  else do:
    for each gds-prop break by gds-prop.prod-name by gds-prop.grp-code by if SortType = "sort-code":U   then  gds-prop.b-code Else  gds-prop.artic :
define variable vss-include-info71 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        if first-of(gds-prop.prod-name) then do:
          assign var-client = "Производитель " + gds-prop.prod-name .
          for each temp-sum where temp-sum.level = 3 : assign temp-sum.sum = 0 . end.
        End.
        if first-of(gds-prop.grp-code) then do:
          assign var-client1 = "Группа " + gds-prop.grp-name .
          for each temp-sum where temp-sum.level = 4 : assign temp-sum.sum = 0 . end.
        End.
        run PrintLine in this-procedure .
        if NullStr < 2 then do:
          run CalculSum in this-procedure (3) .
          run CalculSum in this-procedure (4) .
        end.
        if last-of(gds-prop.grp-code) then do:
          assign ItogStr = "Итого по группе " + gds-prop.grp-name + ":"  .
          run PutItogSum in this-procedure (4) .
        End.
        if last-of(gds-prop.prod-name) then do:
          assign ItogStr = "Итого по производителю " + gds-prop.prod-name + ":" .
          run PutItogSum in this-procedure (3) .
        End.
    End.
  end.
  run PutItogSum in this-procedure (1) .
END PROCEDURE.
PROCEDURE foreach5 :
  if tog-obj = true then do:
    for each obj-list no-lock :
      assign  titul = 0 .
      for each temp-sum where temp-sum.level = 2 : assign temp-sum.sum = 0 . end.
      for each gds-prop
        where gds-prop.obj-type = obj-list.obj-type
          and gds-prop.obj-code = obj-list.obj-code
        break by gds-prop.grp-code
              by gds-prop.prod-name
              by if SortType = "sort-code":U   then  gds-prop.b-code Else  gds-prop.artic :
define variable vss-include-info72 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        if first-of(gds-prop.grp-code) then do:
          assign var-client = "Группа " + gds-prop.grp-name .
          for each temp-sum where temp-sum.level = 3 : assign temp-sum.sum = 0 . end.
        End.
        if first-of(gds-prop.prod-name) then do:
          assign var-client1 = "Производитель " + gds-prop.prod-name .
          for each temp-sum where temp-sum.level = 4 : assign temp-sum.sum = 0 . end.
        End.
        run PrintLine in this-procedure .
        if NullStr < 2 then do:
          run CalculSum in this-procedure (3) .
          run CalculSum in this-procedure (4) .
        end.
        if last-of(gds-prop.prod-name) then do:
          assign ItogStr = "Итого по производителю " + gds-prop.prod-name + ":" .
          run PutItogSum in this-procedure (4) .
        End.
        if last-of(gds-prop.grp-code) then do:
          assign ItogStr = "Итого по группе " + gds-prop.grp-name + ":" .
          run PutItogSum in this-procedure (3) .
        End.
      End.
      run PutItogSum in this-procedure (2) .
    end.
  end.
  else do:
    for each gds-prop break by gds-prop.grp-code by gds-prop.prod-name by if SortType = "sort-code":U   then  gds-prop.b-code Else  gds-prop.artic :
define variable vss-include-info73 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        if first-of(gds-prop.grp-code) then do:
          assign var-client = "Группа " + gds-prop.grp-name .
          for each temp-sum where temp-sum.level = 3 : assign temp-sum.sum = 0 . end.
        End.
        if first-of(gds-prop.prod-name) then do:
          assign var-client1 = "Производитель " + gds-prop.prod-name .
          for each temp-sum where temp-sum.level = 4 : assign temp-sum.sum = 0 . end.
        End.
        run PrintLine in this-procedure .
        if NullStr < 2 then do:
          run CalculSum in this-procedure (3) .
          run CalculSum in this-procedure (4) .
        end.
        if last-of(gds-prop.prod-name) then do:
          assign ItogStr = "Итого по производителю " + gds-prop.prod-name + ":" .
          run PutItogSum in this-procedure (4) .
        End.
        if last-of(gds-prop.grp-code) then do:
          assign ItogStr = "Итого по группе " + gds-prop.grp-name + ":" .
          run PutItogSum in this-procedure (3) .
        End.
    End.
  end.
  run PutItogSum in this-procedure (1) .
END PROCEDURE.
PROCEDURE foreach6 :
  if tog-obj = true then do:
    for each obj-list no-lock :
      assign  titul = 0 .
      for each temp-sum where temp-sum.level = 2 : assign temp-sum.sum = 0 . end.
      for each gds-prop
        where gds-prop.obj-type = obj-list.obj-type
          and gds-prop.obj-code = obj-list.obj-code
        break by gds-prop.vat-pc
              by if SortType = "sort-code":U   then  gds-prop.b-code Else  gds-prop.artic :
define variable vss-include-info74 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        if first-of(gds-prop.vat-pc) then do:
          assign var-client = "Ставка НДС: " +  String(gds-prop.vat-pc) + " %" .
          for each temp-sum where temp-sum.level = 3 : assign temp-sum.sum = 0 . end.
        End.
        run PrintLine in this-procedure .
        if NullStr < 2 then run CalculSum in this-procedure (3) .
        if last-of(gds-prop.vat-pc) then do:
          assign ItogStr = "Итого по ставке НДС " + String(gds-prop.vat-pc) + " % :"  .
          run PutItogSum in this-procedure (3) .
        End.
      End.
      run PutItogSum in this-procedure (2).
    end.
  end.
  else do:
    for each gds-prop break by gds-prop.vat-pc by if SortType = "sort-code":U   then  gds-prop.b-code Else  gds-prop.artic :
define variable vss-include-info75 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
        if first-of(gds-prop.vat-pc) then do:
          assign var-client = "Ставка НДС: " +  String(gds-prop.vat-pc) + " %" .
          for each temp-sum where temp-sum.level = 3 : assign temp-sum.sum = 0 . end.
        End.
        run PrintLine in this-procedure .
        if NullStr < 2 then run CalculSum in this-procedure (3) .
        if last-of(gds-prop.vat-pc) then do:
          assign ItogStr = "Итого по ставке НДС " + String(gds-prop.vat-pc) + " % :"  .
          run PutItogSum in this-procedure (3) .
        End.
    End.
  end.
  run PutItogSum in this-procedure (1) .
END PROCEDURE.
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
FUNCTION format-excel-text-macr RETURNS CHAR ( INPUT Start-Text AS CHAR ) :
def var  i    AS INT NO-UNDO.
def var  ch   AS CHAR NO-UNDO.
def var  N    AS INT NO-UNDO.
def var  iPos AS INT NO-UNDO.
  N = NUM-ENTRIES(TRIM(Start-Text), CHR(10)) - 1 .
  DO i = 1 TO N :
    iPos = INDEX( Start-Text, CHR(10)).
    IF iPos > 0 THEN
      SUBSTRing( Start-Text, iPos , 1 ) = ' '.
  END.
  N = NUM-ENTRIES(TRIM(Start-Text), CHR(13)) - 1 .
  DO i = 1 TO N :
    iPos = INDEX( Start-Text, CHR(13)).
    IF iPos > 0 THEN
      SUBSTRing( Start-Text, iPos, 1 ) = ' '.
  END.
  IF INDEX( Start-Text, '"' ) = 0 THEN
    Start-Text =  '"'   + TRIM( Start-Text) + '"'   .
    ELSE DO:
      N = NUM-ENTRIES(TRIM(Start-Text), '"') - 1.
      DO i = 1 TO N :
        ch = ch + ENTRY(i,TRIM(Start-Text), '"' ) + '""'.
      END.
      ch = ch + ENTRY(NUM-ENTRIES(TRIM(Start-Text), '"'),TRIM(Start-Text), '"' ).
      Start-Text = '"'  + ch  + '"' .
    END.
  N = NUM-ENTRIES(TRIM(Start-Text), CHR(10)) - 1 .
  DO i = 1 TO N :
    iPos = INDEX( Start-Text, CHR(10)).
    IF iPos > 0 THEN
      SUBSTRing( Start-Text, iPos , 1 ) = ' '.
  END.
    if NUM-ENTRIES(TRIM(Start-Text), CHR(10)) > 1 then  message NUM-ENTRIES(TRIM(Start-Text), CHR(10)) Start-Text.
  RETURN Start-Text.
END.
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
 assign ss = string( Round( p-val, p-typ) ) .
 put  stream macr_excel unformatted substitute('formula(&3,"r&1c&2")', p-row , p-col , ss ) skip  .
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
put  stream macr_excel unformatted     substitute('select("r&1c&2:r&3c&4 ")' , p-row , p-col , p-row-2 , p-col-2 )  skip .
put  stream macr_excel unformatted     substitute('COLUMN.WIDTH(&1,,,,)' , s-w  )  skip.
put  stream macr_excel unformatted     'FORMAT.TEXT(2,2,0,,,,,)'  skip.
 end.
end procedure.
