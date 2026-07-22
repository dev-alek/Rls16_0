block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-discnt-dtl as logical no-undo .
define input parameter p-pay-card as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: eb58aa57459c, 2002, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Wed Sep 18 21:01:08 2019 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-cpych.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/r-cpych.p $":U .
define variable vss-description as character no-undo init "Отчет по продажам в разрезе платежных карт - выполнение отчета".
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
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
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define temp-table temp-cpych no-undo
field pay-card as character
field fpay-card as character
field chk-date as date
field chk-time as integer
field doc-code as character
field obj-type as character
field obj-code as integer
field b-code as integer
field gds-code as integer
field line-num as integer
field price-base as decimal
field doc-qnty as decimal
field doc-qnty-2 as decimal
field sum-tot as decimal
field discnt as decimal
field discnt-sum as decimal
field sum-netto as decimal
field num-chk as integer
field is-ptrl as logical
field category as character
index pi is unique primary
pay-card
doc-code
obj-type
obj-code
line-num
index igds
obj-type
obj-code
gds-code
index iview
obj-type
obj-code
fpay-card
chk-date
chk-time
doc-code
line-num
index iview2
obj-type
obj-code
doc-code
index icat
category
.
define temp-table temp-inkas no-undo
field inkas-code as character
field obj-type as character
field obj-code as integer
field shift-date as date
field shift-num as integer
index pi is unique primary
inkas-code
index iview
obj-type
obj-code
shift-date
shift-num
inkas-code
.
define temp-table temp-discnt no-undo
field obj-type as character
field obj-code as integer
field discnt-type as integer
field discnt-sum as decimal
index pi is unique primary
obj-type
obj-code
discnt-type
.
define variable v-header as character no-undo .
define variable v-header-curr as character no-undo .
define variable v-rubl as logical no-undo .
define variable v-r-b as logical no-undo .
define variable v-curr-r-b as character no-undo .
define variable v-one-curr-code as logical no-undo .
define variable v-curr-code like ub.currency.curr-code no-undo init ?.
define variable v-base-code as integer no-undo .
define variable Line            as character no-undo.
define variable date_string     as character no-undo.
define variable v-pay-card      as character no-undo .
define variable v-pay-card-itog      as character no-undo .
define variable v-chk-date-time as character no-undo .
define variable v-sum-tot as decimal no-undo .
define variable v-discnt-name as character no-undo .
define variable v-sum-netto as decimal no-undo .
define variable v-line as integer no-undo .
define variable num-objs as integer no-undo .
define variable ii-excel as integer no-undo .
define variable ii-page as integer no-undo init 1.
define variable v-qnty-2 as decimal no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .
define variable par-l-mask  as logical no-undo .
define variable v-param-type as character no-undo .
DEFINE shared TEMP-TABLE tt-cash-pay  no-undo LIKE ub.cash-pay.
define buffer buf1_sheetf for sheetf.
define buffer buf_sheetf for sheetf.
define buffer buf_temp-inkas for temp-inkas.
define buffer buf_chk-gds for ub.chk-gds.
define buffer buf_bar-code for ub.bar-code.
define buffer buf_goods for ub.goods.
define buffer buf_chk-discnt for ub.chk-discnt.
define buffer buf_currency for ub.currency.
define buffer buf_temp-cpych for temp-cpych.
define buffer gds-obj_temp-cpych for temp-cpych.
define buffer gds_temp-cpych for temp-cpych.
define buffer obj_temp-cpych for temp-cpych.
define buffer all_temp-cpych for temp-cpych.
define buffer card-obj_temp-cpych for temp-cpych.
define buffer card_temp-cpych for temp-cpych.
define buffer obj_temp-discnt for temp-discnt.
define buffer all_temp-discnt for temp-discnt.
define buffer buf_inkas for ub.inkas.
run waitfram-show in this-procedure ("Ждите...").
run adm/shattri.p (
      input "get":U
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  'dc-ref':U
    ,input  'l-mask':U
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output par-l-mask
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    ) no-error .
for each thbjattr_thbj-attr where
       thbjattr_thbj-attr.obj-type = v-cntxt-obj-type
   and thbjattr_thbj-attr.obj-code = v-cntxt-obj-code
   and thbjattr_thbj-attr.upper-prop-code = 'dc-ref':U
on error undo, return error return-value :
  case thbjattr_thbj-attr.prop-code:
    when 'l-mask':U then do:
      assign
      par-l-mask = thbjattr_thbj-attr.property-value-logical.
    end.
  end case.
end.
for each buf_temp-inkas:
  delete buf_temp-inkas.
end.
FOR EACH obj-list No-LOCK:
  num-objs = num-objs + 1.
  case X-Radio-task > 1:
    when yes then do:
      _inkas:
      for each  buf_Inkas no-lock where
                buf_inkas.shift-date  >= x-date-start
            AND buf_inkas.shift-date  <= x-date-end
            AND buf_inkas.obj-type   = obj-list.obj-type
            AND buf_inkas.obj-code   = obj-list.obj-code:
        IF X-Radio-task = 3
        AND  ((buf_inkas.shift-date = x-date-start AND buf_inkas.shift-num < X-shift-start) OR
              (buf_inkas.shift-date = x-date-end AND  buf_inkas.shift-num > X-shift-end) ) THEN DO:
           next _inkas.
        END.
        IF X-radio-task = 4
        AND buf_inkas.shift-num <> X-Shift-Alone then DO:
          next _inkas.
        END.
        create buf_temp-inkas.
        buffer-copy buf_inkas to buf_temp-inkas.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  buf_inkas.host-code
  ,output v-base-code
  )  .
        assign
        v-curr-code = (if v-curr-code = ? then v-base-code else v-curr-code)
        v-one-curr-code = (if v-base-code = v-curr-code then yes else no)
        .
        run process-inkas in this-procedure ( buffer buf_temp-inkas ).
        release buf_temp-inkas.
      END.
    end.
    when no then do:
      for each  buf_Inkas no-lock where
                buf_inkas.doc-date  >= x-date-start
            AND buf_inkas.doc-date  <= x-date-end
            AND buf_inkas.obj-type   = obj-list.obj-type
            AND buf_inkas.obj-code   = obj-list.obj-code
            AND buf_inkas.status_     = 'факт':U:
        create buf_temp-inkas.
        buffer-copy buf_inkas to buf_temp-inkas.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  buf_inkas.host-code
  ,output v-base-code
  )  .
        assign
        v-curr-code = (if v-curr-code = ? then v-base-code else v-curr-code)
        v-one-curr-code = (if v-base-code = v-curr-code then yes else no)
        .
        run process-inkas in this-procedure ( buffer buf_temp-inkas ).
        release buf_temp-inkas.
      end.
    end.
  end case.
END.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
assign
v-r-b = (if v-curr-r-b = 'rubl':U or v-one-curr-code then yes else no)
v-rubl =(if not v-r-b or (v-r-b = yes and v-curr-r-b = 'rubl':U)
        then yes
        else no)
.
DEFINE FRAME OutFrame
v-pay-card                        column-label "№ карты"          format "X(19)"
v-chk-date-time                   column-label "Дата,время"       format "X(16)"
buf_chk-gds.doc-code              column-label "Чек №"            format "X(19)"
buf_goods.artic                   column-label "Артикул"          format "X(16)"
buf_goods.gds-name                column-label "Наименование"     format "X(36)"
buf_chk-gds.price-base            column-label "Цена"             format ">>>,>>9.99"
buf_chk-gds.doc-qnty              column-label "Количество"       format "->>>,>>9.999"
v-qnty-2                          column-label "Кол-во кг"        format "->>>,>>9.999"
v-sum-tot                         column-label "Сумма без скидки" format "->>>,>>>,>>9.99"
v-discnt-name                     column-label "Тип скидки"       format "X(20)"
buf_chk-discnt.discnt-value-pcnt  column-label "% скидки"         format "->9.99"
buf_chk-discnt.discnt-value-abs   column-label "Сумма скидки"     format "->>,>>>,>>9.99"
v-sum-netto                       column-label "Сумма нетто"      format "->>>,>>>,>>9.99"
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
assign
v-rubl = (if not v-r-b or (v-r-b = yes and v-curr-r-b = 'rubl':U)
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
assign
sheetf.Excel-Column-Lable =  "№ карты,Дата-время,Чек №,Артикул,Наименование,Цена,Количество,Кол-во кг,Сумма без скидки,Тип скидки,% скидки,Сумма скидки,Сумма нетто"
sheetf.colformat = "1=@;2=@;3=@;4=@;5=@;6=0.00;7=0.000;8=0.000;9=0.00;11=0.00;12=0.00;13=0.00"
sheetf.sizes = "19,16,19,16,36,10,12,12,15,20,6,14,15"
v-r-b = (if v-curr-r-b = 'rubl':U or v-one-curr-code then yes else no)
.
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
"Отчет по продажам в разрезе платежных карт"
format "x(50)" SKIP(1).
PUT stream PrnLibStream UNFORMATTED
str1 skip
str2 skip
str4 skip
v-header-curr skip
reportheader skip
.
FORM with FRAME OutFrame.
VIEW STREAM PrnLibStream FRAME BottomFrame .
VIEW STREAM PrnLibStream FRAME OutFrame .
for each obj-list
break
by obj-list.obj-type
by obj-list.obj-code
:
  if ii-excel > 32000 then do:                                                               if   Make-Excel Then  do:   Output stream ForExcel close.   assign   number-list = number-list + 1   .   os-delete value( v-excel-file + ".":U + string(number-list)).   Output Stream ForExcel to value( v-excel-file + ".":U + string(number-list ) ) . end.                                                                          find first buf_sheetf where                                                                     buf_sheetf.sheet-num = ii-page + 1 no-error.                                if not available buf_sheetf then do:                                                    create buf_sheetf.                                                                  end.                                                                                  buffer-copy buf1_sheetf except sheet-num                                              to buf_sheetf                                                                         assign                                                                                buf_sheetf.sheet-num = ii-page + 1                                                    .                                                                                     run rep/extitle.p (ii-page) .                                                              assign                                                                                ii-page = ii-page + 1                                                                 ii-excel = 0                                                                          .                                                                                   end.
  for each buf_temp-cpych where
          buf_temp-cpych.obj-type = obj-list.obj-type
      and buf_temp-cpych.obj-code = obj-list.obj-code
      and buf_temp-cpych.category = ""
  break
  by buf_temp-cpych.fpay-card
  by buf_temp-cpych.chk-date
  by buf_temp-cpych.chk-time
  by buf_temp-cpych.doc-code
  :
    find first buf_bar-code no-lock where
              buf_bar-code.b-code = buf_temp-cpych.b-code no-error.
    if available buf_bar-code then do:
      find first buf_goods no-lock where
                buf_goods.gds-code = buf_bar-code.b-code no-error.
    end.
    if available buf_goods
    or buf_temp-cpych.is-ptrl = no
    then do:
      find first gds-obj_temp-cpych where
                gds-obj_temp-cpych.obj-type = obj-list.obj-type
            and gds-obj_temp-cpych.obj-code = obj-list.obj-code
            and gds-obj_temp-cpych.category = "gds-obj"
            and gds-obj_temp-cpych.gds-code = (if buf_temp-cpych.is-ptrl
                                               then  buf_goods.gds-code
                                               else -1)
                                               no-error.
      if not available gds-obj_temp-cpych then do:
        create gds-obj_temp-cpych.
        assign
        gds-obj_temp-cpych.pay-card = ''
        gds-obj_temp-cpych.fpay-card = ''
        gds-obj_temp-cpych.chk-date  = ?
        gds-obj_temp-cpych.chk-time = 0
        gds-obj_temp-cpych.doc-code = ''
        gds-obj_temp-cpych.obj-type = obj-list.obj-type
        gds-obj_temp-cpych.obj-code = obj-list.obj-code
        gds-obj_temp-cpych.b-code  = 0
        gds-obj_temp-cpych.gds-code = (if buf_temp-cpych.is-ptrl
                                       then buf_goods.gds-code
                                       else -1)
        gds-obj_temp-cpych.line-num = v-line + 1
        v-line = v-line + 1
        gds-obj_temp-cpych.num-chk = 0
        gds-obj_temp-cpych.discnt = 0
        gds-obj_temp-cpych.category = "gds-obj"
        .
      end.
      find first gds_temp-cpych where
                gds_temp-cpych.obj-type = ''
            and gds_temp-cpych.obj-code = 0
            and gds_temp-cpych.category = "gds"
            and gds_temp-cpych.gds-code = (if buf_temp-cpych.is-ptrl
                                           then buf_goods.gds-code
                                           else -1) no-error.
      if not available gds_temp-cpych then do:
        create gds_temp-cpych.
        assign
        gds_temp-cpych.pay-card = ''
        gds_temp-cpych.fpay-card = ''
        gds_temp-cpych.chk-date  = ?
        gds_temp-cpych.chk-time = 0
        gds_temp-cpych.doc-code = ''
        gds_temp-cpych.obj-type = ''
        gds_temp-cpych.obj-code = 0
        gds_temp-cpych.b-code  = 0
        gds_temp-cpych.gds-code = (if buf_temp-cpych.is-ptrl
                                   then buf_goods.gds-code
                                   else -1)
        gds_temp-cpych.line-num = v-line + 1
        v-line = v-line + 1
        gds_temp-cpych.num-chk = 0
        gds_temp-cpych.discnt = 0
        gds_temp-cpych.category = "gds"
        .
      end.
    end.
    find first obj_temp-cpych where
              obj_temp-cpych.obj-type = obj-list.obj-type
          and obj_temp-cpych.obj-code = obj-list.obj-code
          and obj_temp-cpych.category = "obj" no-error.
    if not available obj_temp-cpych then do:
      create obj_temp-cpych.
      assign
      obj_temp-cpych.pay-card = ''
      obj_temp-cpych.fpay-card = ''
      obj_temp-cpych.chk-date  = ?
      obj_temp-cpych.chk-time = 0
      obj_temp-cpych.doc-code = ''
      obj_temp-cpych.obj-type = obj-list.obj-type
      obj_temp-cpych.obj-code = obj-list.obj-code
      obj_temp-cpych.b-code  = 0
      obj_temp-cpych.gds-code = 0
      obj_temp-cpych.line-num = v-line + 1
      v-line = v-line + 1
      obj_temp-cpych.num-chk = 0
      obj_temp-cpych.discnt = 0
      obj_temp-cpych.category = "obj"
      .
    end.
    find first all_temp-cpych where
              all_temp-cpych.obj-type = ''
          and all_temp-cpych.obj-code = 0
          and all_temp-cpych.category = "all"
          and all_temp-cpych.gds-code = 0 no-error.
    if not available all_temp-cpych then do:
      create all_temp-cpych.
      assign
      all_temp-cpych.pay-card = ''
      all_temp-cpych.fpay-card = ''
      all_temp-cpych.chk-date  = ?
      all_temp-cpych.chk-time = 0
      all_temp-cpych.doc-code = ''
      all_temp-cpych.obj-type = ''
      all_temp-cpych.obj-code = 0
      all_temp-cpych.b-code  = 0
      all_temp-cpych.gds-code = 0
      all_temp-cpych.line-num = v-line + 1
      v-line = v-line + 1
      all_temp-cpych.num-chk = 0
      all_temp-cpych.discnt = 0
      all_temp-cpych.category = "all"
      .
    end.
    assign
    gds-obj_temp-cpych.doc-qnty = gds-obj_temp-cpych.doc-qnty + buf_temp-cpych.doc-qnty
    gds-obj_temp-cpych.doc-qnty-2 = gds-obj_temp-cpych.doc-qnty-2 + buf_temp-cpych.doc-qnty-2
    gds-obj_temp-cpych.sum-tot  = gds-obj_temp-cpych.sum-tot + buf_temp-cpych.sum-tot
    gds-obj_temp-cpych.sum-netto  = gds-obj_temp-cpych.sum-netto + buf_temp-cpych.sum-netto
    gds-obj_temp-cpych.discnt-sum  = gds-obj_temp-cpych.discnt-sum + buf_temp-cpych.discnt * buf_temp-cpych.doc-qnty
    gds_temp-cpych.doc-qnty = gds_temp-cpych.doc-qnty + buf_temp-cpych.doc-qnty
    gds_temp-cpych.doc-qnty-2 = gds_temp-cpych.doc-qnty-2 + buf_temp-cpych.doc-qnty-2
    gds_temp-cpych.sum-tot  = gds_temp-cpych.sum-tot + buf_temp-cpych.sum-tot
    gds_temp-cpych.sum-netto  = gds_temp-cpych.sum-netto + buf_temp-cpych.sum-netto
    gds_temp-cpych.discnt-sum  = gds_temp-cpych.discnt-sum + buf_temp-cpych.discnt * buf_temp-cpych.doc-qnty
    obj_temp-cpych.doc-qnty = obj_temp-cpych.doc-qnty + buf_temp-cpych.doc-qnty
    obj_temp-cpych.doc-qnty-2 = obj_temp-cpych.doc-qnty-2 + buf_temp-cpych.doc-qnty-2
    obj_temp-cpych.sum-tot  = obj_temp-cpych.sum-tot + buf_temp-cpych.sum-tot
    obj_temp-cpych.sum-netto  = obj_temp-cpych.sum-netto + buf_temp-cpych.sum-netto
    obj_temp-cpych.discnt-sum  = obj_temp-cpych.discnt-sum + buf_temp-cpych.discnt * buf_temp-cpych.doc-qnty
    all_temp-cpych.doc-qnty = all_temp-cpych.doc-qnty + buf_temp-cpych.doc-qnty
    all_temp-cpych.doc-qnty-2 = all_temp-cpych.doc-qnty-2 + buf_temp-cpych.doc-qnty-2
    all_temp-cpych.sum-tot  = all_temp-cpych.sum-tot + buf_temp-cpych.sum-tot
    all_temp-cpych.sum-netto  = all_temp-cpych.sum-netto + buf_temp-cpych.sum-netto
    all_temp-cpych.discnt-sum  = all_temp-cpych.discnt-sum + buf_temp-cpych.discnt * buf_temp-cpych.doc-qnty
    .
    v-pay-card = if first-of(buf_temp-cpych.fpay-card)
                  then buf_temp-cpych.fpay-card
                  else ''.
    if par-l-mask and v-cntxt-db-num <> 0 and v-pay-card <> "" then v-pay-card = substring(v-pay-card,1,6) + "XXXXXX" + substring (v-pay-card,13,4).
    if first-of(buf_temp-cpych.fpay-card) then do:
      if ii-excel > 32000 then do:                                                               if   Make-Excel Then  do:   Output stream ForExcel close.   assign   number-list = number-list + 1   .   os-delete value( v-excel-file + ".":U + string(number-list)).   Output Stream ForExcel to value( v-excel-file + ".":U + string(number-list ) ) . end.                                                                          find first buf_sheetf where                                                                     buf_sheetf.sheet-num = ii-page + 1 no-error.                                if not available buf_sheetf then do:                                                    create buf_sheetf.                                                                  end.                                                                                  buffer-copy buf1_sheetf except sheet-num                                              to buf_sheetf                                                                         assign                                                                                buf_sheetf.sheet-num = ii-page + 1                                                    .                                                                                     run rep/extitle.p (ii-page) .                                                              assign                                                                                ii-page = ii-page + 1                                                                 ii-excel = 0                                                                          .                                                                                   end.
    end.
    display stream prnlibstream
    v-pay-card
    (string(buf_temp-cpych.chk-date, "99.99.9999") + chr(32) + string(buf_temp-cpych.chk-time, "HH:MM")) @ v-chk-date-time
    buf_temp-cpych.doc-code  @ buf_chk-gds.doc-code
    (if available buf_goods then buf_goods.artic else "") @ buf_goods.artic
    (if available buf_goods then buf_goods.gds-name else "!!!НЕИЗВ. ТОВАР") @ buf_goods.gds-name
    buf_temp-cpych.price-base @ buf_chk-gds.price-base
    buf_temp-cpych.doc-qnty @  buf_chk-gds.doc-qnty
    buf_temp-cpych.doc-qnty-2 @  v-qnty-2
    buf_temp-cpych.sum-tot @ v-sum-tot
    buf_temp-cpych.discnt / buf_temp-cpych.price-base * 100 @  buf_chk-discnt.discnt-value-pcnt
    buf_temp-cpych.discnt * buf_temp-cpych.doc-qnty @  buf_chk-discnt.discnt-value-abs
    buf_temp-cpych.sum-netto @ v-sum-netto
    with frame outframe.
    down 1 stream prnlibstream
    with frame outframe.
    if Make-Excel then  put   stream ForExcel unformatted
    v-pay-card CHR(9)
    (string(buf_temp-cpych.chk-date, "99.99.9999") + chr(32) + string(buf_temp-cpych.chk-time, "HH:MM")) CHR(9)
    buf_temp-cpych.doc-code CHR(9)
    (if available buf_goods then buf_goods.artic else "") CHR(9)
    (if available buf_goods then buf_goods.gds-name else "!!!НЕИЗВ. ТОВАР") CHR(9)
    buf_temp-cpych.price-base CHR(9)
    buf_temp-cpych.doc-qnty CHR(9)
    buf_temp-cpych.doc-qnty-2 CHR(9)
    buf_temp-cpych.sum-tot CHR(9)
    CHR(9)
    buf_temp-cpych.discnt / buf_temp-cpych.price-base CHR(9)
    buf_temp-cpych.discnt * buf_temp-cpych.doc-qnty CHR(9)
    buf_temp-cpych.sum-netto CHR(9)
    skip.
    ii-excel = ii-excel + 1.
    if p-discnt-dtl then do:
      for each buf_chk-discnt no-lock where
              buf_chk-discnt.record-type = 1
          and buf_chk-discnt.doc-code = buf_temp-cpych.doc-code
          and buf_chk-discnt.line-num = buf_temp-cpych.line-num:
         find first obj_temp-discnt where
                  obj_temp-discnt.obj-type = obj-list.obj-type
              and obj_temp-discnt.obj-code = obj-list.obj-code
              and obj_temp-discnt.discnt-type = buf_chk-discnt.discnt-type no-error.
         if not available obj_temp-discnt then do:
           create obj_temp-discnt.
           assign
           obj_temp-discnt.obj-type = obj-list.obj-type
           obj_temp-discnt.obj-code = obj-list.obj-code
           obj_temp-discnt.discnt-type = buf_chk-discnt.discnt-type
           .
         end.
         find first all_temp-discnt where
                  all_temp-discnt.obj-type = ''
              and all_temp-discnt.obj-code = 0
              and all_temp-discnt.discnt-type = buf_chk-discnt.discnt-type no-error.
         if not available all_temp-discnt then do:
           create all_temp-discnt.
           assign
           all_temp-discnt.obj-type = ''
           all_temp-discnt.obj-code = 0
           all_temp-discnt.discnt-type = buf_chk-discnt.discnt-type
           .
         end.
         assign
         obj_temp-discnt.discnt-sum = obj_temp-discnt.discnt-sum + buf_chk-discnt.discnt-value-abs
         all_temp-discnt.discnt-sum = all_temp-discnt.discnt-sum + buf_chk-discnt.discnt-value-abs
         .
         release obj_temp-discnt.
         release all_temp-discnt.
        display stream prnlibstream
        entry (lookup (string(buf_chk-discnt.discnt-type), '0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,23,17,18,19,20,21,22,998,999,1001':U), '?,Клиент,Стандарт,Временная,Количество,Сумма,Персонал,Промо,Уценка,Счастл.час,Комплект,Сезонная,Катег,Ручная,Карта-маска,Округл. в пользу.клиента,Катег с исп шаблона,Оплата топливным купоном (Ашан),Абсолютная,Группа,Платеж,ЛНР,Округление,Оплата,Доп.условие,Другое,Погрешность':U) @ v-discnt-name
        buf_chk-discnt.discnt-value-pcnt
        buf_chk-discnt.discnt-value-abs
        with frame outframe.
        down 1 stream prnlibstream
        with frame outframe.
        if Make-Excel then  put   stream ForExcel unformatted
        CHR(9)
        CHR(9)
        CHR(9)
        CHR(9)
        CHR(9)
        CHR(9)
        CHR(9)
        CHR(9)
        CHR(9)
        entry (lookup (string(buf_chk-discnt.discnt-type), '0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,23,17,18,19,20,21,22,998,999,1001':U), '?,Клиент,Стандарт,Временная,Количество,Сумма,Персонал,Промо,Уценка,Счастл.час,Комплект,Сезонная,Катег,Ручная,Карта-маска,Округл. в пользу.клиента,Катег с исп шаблона,Оплата топливным купоном (Ашан),Абсолютная,Группа,Платеж,ЛНР,Округление,Оплата,Доп.условие,Другое,Погрешность':U) CHR(9)
        buf_chk-discnt.discnt-value-pcnt CHR(9)
        buf_chk-discnt.discnt-value-abs CHR(9)
        skip
        .
        ii-excel = ii-excel + 1.
      end.
      for each buf_chk-discnt no-lock where
              buf_chk-discnt.record-type = 2
          and buf_chk-discnt.doc-code = buf_temp-cpych.doc-code
          and buf_chk-discnt.line-num = buf_temp-cpych.line-num:
        find first all_temp-discnt where
                all_temp-discnt.obj-type = obj-list.obj-type
            and all_temp-discnt.obj-code = obj-list.obj-code
            and all_temp-discnt.discnt-type = buf_chk-discnt.discnt-type no-error.
        if not available all_temp-discnt then do:
          create all_temp-discnt.
          assign
          all_temp-discnt.obj-type = ''
          all_temp-discnt.obj-code = 0
          all_temp-discnt.discnt-type = buf_chk-discnt.discnt-type
          .
        end.
        assign
        obj_temp-discnt.discnt-sum = obj_temp-discnt.discnt-sum + buf_chk-discnt.discnt-value-abs
        all_temp-discnt.discnt-sum = all_temp-discnt.discnt-sum + buf_chk-discnt.discnt-value-abs
        .
        release obj_temp-discnt.
        release all_temp-discnt.
        display stream prnlibstream
        "Погрешность" @ v-discnt-name
        buf_chk-discnt.discnt-value-pcnt
        buf_chk-discnt.discnt-value-abs
        with frame outframe.
        down 1 stream prnlibstream
        with frame outframe.
        if Make-Excel then  put   stream ForExcel unformatted
        CHR(9)
        CHR(9)
        CHR(9)
        CHR(9)
        CHR(9)
        CHR(9)
        CHR(9)
        CHR(9)
        "Погрешность" CHR(9)
        buf_chk-discnt.discnt-value-pcnt CHR(9)
        buf_chk-discnt.discnt-value-abs CHR(9)
        skip
        .
        ii-excel = ii-excel + 1.
      end.
    end.
    release gds-obj_temp-cpych.
    release obj_temp-cpych.
    release gds_temp-cpych.
    release all_temp-cpych.
    if last-of(buf_temp-cpych.fpay-card)
    then do:
      if par-l-mask and v-cntxt-db-num <> 0 and buf_temp-cpych.fpay-card <> "" then v-pay-card-itog = substring(buf_temp-cpych.fpay-card,1,6) + "XXXXXX" + substring (buf_temp-cpych.fpay-card,13,4).
      else v-pay-card-itog = buf_temp-cpych.fpay-card .
      find first card-obj_temp-cpych where
                card-obj_temp-cpych.obj-type = obj-list.obj-typ
            and card-obj_temp-cpych.obj-code = obj-list.obj-code
            and card-obj_temp-cpych.pay-card  =  buf_temp-cpych.pay-card
            and card-obj_temp-cpych.category  =  "card-obj"            .
      display stream prnlibstream
      '' @ v-pay-card
      "Итого по карте" @ v-chk-date-time
      v-pay-card-itog  @ buf_chk-gds.doc-code
      '' @ buf_goods.artic
      'чеков:' @ buf_goods.gds-name
      card-obj_temp-cpych.num-chk @ buf_chk-gds.price-base
      card-obj_temp-cpych.doc-qnty @  buf_chk-gds.doc-qnty
      card-obj_temp-cpych.doc-qnty-2 @  v-qnty-2
      card-obj_temp-cpych.sum-tot @ v-sum-tot
      card-obj_temp-cpych.discnt-sum @  buf_chk-discnt.discnt-value-abs
      card-obj_temp-cpych.sum-netto @ v-sum-netto
      with frame outframe.
      down 1 stream prnlibstream
      with frame outframe.
      if Make-Excel then  put   stream ForExcel unformatted
      '' CHR(9)
      "Итого по карте" CHR(9)
      v-pay-card-itog  CHR(9)
      '' CHR(9)
      'чеков:' CHR(9)
      card-obj_temp-cpych.num-chk CHR(9)
      card-obj_temp-cpych.doc-qnty CHR(9)
      card-obj_temp-cpych.doc-qnty-2 CHR(9)
      card-obj_temp-cpych.sum-tot CHR(9)
      CHR(9)
      CHR(9)
      card-obj_temp-cpych.discnt-sum  CHR(9)
      card-obj_temp-cpych.sum-netto CHR(9)
      skip.
      ii-excel = ii-excel + 1.
    end.
  end.
  if num-objs = 1 then do:
    underline stream PrnLibStream
    v-pay-card
    v-chk-date-time
    buf_chk-gds.doc-code
    buf_goods.artic
    buf_goods.gds-name
    buf_chk-gds.price-base
    buf_chk-gds.doc-qnty
    v-qnty-2
    v-sum-tot
    v-discnt-name
    buf_chk-discnt.discnt-value-pcnt
    buf_chk-discnt.discnt-value-abs
    v-sum-netto
    with frame OutFrame.
    down 1 stream PrnLibstream
    with frame OutFrame.
  end.
  if num-objs = 1 then do:
    put stream PrnLibStream unformatted
    "Итого по видам топлива и сопутствующим товарам"
    skip
    .
    if Make-Excel then  put   stream ForExcel unformatted
    "Итого по видам топлива и сопутствующим товарам"
    skip
    .
    ii-excel = ii-excel + 1.
    for each gds-obj_temp-cpych where
              gds-obj_temp-cpych.obj-type = obj-list.obj-typ
          and gds-obj_temp-cpych.obj-code = obj-list.obj-code
          and gds-obj_temp-cpych.category  =  "gds-obj" :
      if gds-obj_temp-cpych.gds-code > 0 then do:
        find first buf_goods no-lock where
                    buf_goods.gds-code = gds-obj_temp-cpych.gds-code no-error.
        display stream prnlibstream
        '' @ v-chk-date-time
        ''  @ buf_chk-gds.doc-code
        '' @ buf_goods.artic
        (if available buf_goods then buf_goods.artic else "") @ buf_goods.artic
        (if available buf_goods then buf_goods.gds-name else "!!!НЕИЗВ. ТОВАР") @ buf_goods.gds-name
        gds-obj_temp-cpych.doc-qnty @  buf_chk-gds.doc-qnty
        gds-obj_temp-cpych.doc-qnty-2 @  v-qnty-2
        gds-obj_temp-cpych.sum-tot @ v-sum-tot
        gds-obj_temp-cpych.discnt-sum @  buf_chk-discnt.discnt-value-abs
        gds-obj_temp-cpych.sum-netto @ v-sum-netto
        with frame outframe.
        down 1 stream prnlibstream
        with frame outframe.
        if Make-Excel then  put   stream ForExcel unformatted
        CHR(9)
        CHR(9)
        CHR(9)
        (if available buf_goods then buf_goods.artic else "") CHR(9)
        (if available buf_goods then buf_goods.gds-name else "!!!НЕИЗВ. ТОВАР") CHR(9)
        CHR(9)
        gds-obj_temp-cpych.doc-qnty CHR(9)
        gds-obj_temp-cpych.doc-qnty-2 CHR(9)
        gds-obj_temp-cpych.sum-tot CHR(9)
        CHR(9)
        CHR(9)
        gds-obj_temp-cpych.discnt-sum CHR(9)
        gds-obj_temp-cpych.sum-netto CHR(9)
        skip
        .
        ii-excel = ii-excel + 1.
      end.
      else do:
        display stream prnlibstream
        "" @ v-chk-date-time
        ''  @ buf_chk-gds.doc-code
        '' @ buf_goods.artic
        "Сопутствующие товары" @ buf_goods.gds-name
        gds-obj_temp-cpych.doc-qnty @  buf_chk-gds.doc-qnty
        gds-obj_temp-cpych.sum-tot @ v-sum-tot
        gds-obj_temp-cpych.discnt-sum @  buf_chk-discnt.discnt-value-abs
        gds-obj_temp-cpych.sum-netto @ v-sum-netto
        with frame outframe.
        down 1 stream prnlibstream
        with frame outframe.
        if Make-Excel then  put   stream ForExcel unformatted
        CHR(9)
        CHR(9)
        CHR(9)
        CHR(9)
        "Сопутствующие товары" CHR(9)
        CHR(9)
        gds-obj_temp-cpych.doc-qnty  CHR(9)
        CHR(9)
        gds-obj_temp-cpych.sum-tot CHR(9)
        CHR(9)
        CHR(9)
        gds-obj_temp-cpych.discnt-sum  CHR(9)
        gds-obj_temp-cpych.sum-netto
        skip
        .
        ii-excel = ii-excel + 1.
      end.
    end.
    if p-discnt-dtl
    and can-find(first obj_temp-discnt where
              obj_temp-discnt.obj-type = obj-list.obj-type
          and obj_temp-discnt.obj-code = obj-list.obj-code)
    then do:
      put stream PrnLibStream unformatted
      "Итого по типам скидок"
      skip
      .
      if Make-Excel then  put   stream ForExcel unformatted
      "Итого по типам скидок"
      skip
      .
      for each obj_temp-discnt where
              obj_temp-discnt.obj-type = obj-list.obj-type
          and obj_temp-discnt.obj-code = obj-list.obj-code:
          display stream prnlibstream
        "---------->" @ v-pay-card
        entry (lookup (string(obj_temp-discnt.discnt-type), '0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,23,17,18,19,20,21,22,998,999,1001':U), '?,Клиент,Стандарт,Временная,Количество,Сумма,Персонал,Промо,Уценка,Счастл.час,Комплект,Сезонная,Катег,Ручная,Карта-маска,Округл. в пользу.клиента,Катег с исп шаблона,Оплата топливным купоном (Ашан),Абсолютная,Группа,Платеж,ЛНР,Округление,Оплата,Доп.условие,Другое,Погрешность':U) @ v-discnt-name
        obj_temp-discnt.discnt-sum @ buf_chk-discnt.discnt-value-abs
        with frame outframe.
        down 1 stream prnlibstream
        with frame outframe.
        if Make-Excel then  put   stream ForExcel unformatted
        "---------->" CHR(9)
        CHR(9)
        CHR(9)
        CHR(9)
        CHR(9)
        CHR(9)
        CHR(9)
        CHR(9)
        CHR(9)
        entry (lookup (string(obj_temp-discnt.discnt-type), '0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,23,17,18,19,20,21,22,998,999,1001':U), '?,Клиент,Стандарт,Временная,Количество,Сумма,Персонал,Промо,Уценка,Счастл.час,Комплект,Сезонная,Катег,Ручная,Карта-маска,Округл. в пользу.клиента,Катег с исп шаблона,Оплата топливным купоном (Ашан),Абсолютная,Группа,Платеж,ЛНР,Округление,Оплата,Доп.условие,Другое,Погрешность':U) CHR(9)
        CHR(9)
        obj_temp-discnt.discnt-sum CHR(9)
        skip
        .
        ii-excel = ii-excel + 1.
    end.
    end.
  end.
  underline stream PrnLibStream
  v-pay-card
  v-chk-date-time
  buf_chk-gds.doc-code
  buf_goods.artic
  buf_goods.gds-name
  buf_chk-gds.price-base
  buf_chk-gds.doc-qnty
  v-qnty-2
  v-sum-tot
  v-discnt-name
  buf_chk-discnt.discnt-value-pcnt
  buf_chk-discnt.discnt-value-abs
  v-sum-netto
  with frame OutFrame.
  down 1 stream PrnLibstream
  with frame OutFrame.
  find first obj_temp-cpych where
            obj_temp-cpych.obj-type = obj-list.obj-typ
        and obj_temp-cpych.obj-code = obj-list.obj-code
        and obj_temp-cpych.category  =  "obj" no-error.
  if not available obj_temp-cpych then do:
    create obj_temp-cpych.
    assign
    obj_temp-cpych.pay-card = ''
    obj_temp-cpych.fpay-card = ''
    obj_temp-cpych.chk-date  = ?
    obj_temp-cpych.chk-time = 0
    obj_temp-cpych.doc-code = ''
    obj_temp-cpych.obj-type = obj-list.obj-type
    obj_temp-cpych.obj-code = obj-list.obj-code
    obj_temp-cpych.b-code  = 0
    obj_temp-cpych.gds-code = 0
    obj_temp-cpych.line-num = v-line + 1
    v-line = v-line + 1
    obj_temp-cpych.num-chk = 0
    obj_temp-cpych.discnt = 0
    obj_temp-cpych.category = "obj"
    .
  end.
  display stream prnlibstream
  "Итого по объекту" @ v-pay-card
  substitute('&1&2', obj-list.obj-type, obj-list.obj-code) @ v-chk-date-time
  obj-list.obj-name @ buf_chk-gds.doc-code
  '' @ buf_goods.artic
  'чеков:' @ buf_goods.gds-name
  obj_temp-cpych.num-chk @ buf_chk-gds.price-base
  obj_temp-cpych.doc-qnty @  buf_chk-gds.doc-qnty
  obj_temp-cpych.doc-qnty-2 @  v-qnty-2
  obj_temp-cpych.sum-tot @ v-sum-tot
  obj_temp-cpych.discnt-sum @  buf_chk-discnt.discnt-value-abs
  obj_temp-cpych.sum-netto @ v-sum-netto
  with frame outframe.
  if Make-Excel then  put   stream ForExcel unformatted
  "Итого по объекту" CHR(9)
  substitute('&1&2', obj-list.obj-type, obj-list.obj-code) CHR(9)
  obj-list.obj-name CHR(9)
  CHR(9)
  'чеков:' CHR(9)
  obj_temp-cpych.num-chk CHR(9)
  obj_temp-cpych.doc-qnty CHR(9)
  obj_temp-cpych.doc-qnty-2 CHR(9)
  obj_temp-cpych.sum-tot CHR(9)
  CHR(9)
  CHR(9)
  obj_temp-cpych.discnt-sum  CHR(9)
  obj_temp-cpych.sum-netto
  skip.
  ii-excel = ii-excel + 1.
  if num-objs > 1 then do:
    down 1 stream prnlibstream
    with frame outframe.
    underline stream PrnLibStream
    v-pay-card
    v-chk-date-time
    buf_chk-gds.doc-code
    buf_goods.artic
    buf_goods.gds-name
    buf_chk-gds.price-base
    buf_chk-gds.doc-qnty
    v-qnty-2
    v-sum-tot
    v-discnt-name
    buf_chk-discnt.discnt-value-pcnt
    buf_chk-discnt.discnt-value-abs
    v-sum-netto
    with frame OutFrame.
    down 1 stream PrnLibstream
    with frame OutFrame.
  end.
end.
if num-objs > 1 then do:
  put stream PrnLibStream unformatted
  "Итого по видам топлива и сопутствующим товарам"
  skip
  .
  if Make-Excel then  put   stream ForExcel unformatted
  "Итого по видам топлива и сопутствующим товарам"
  skip
  .
  ii-excel = ii-excel + 1.
  for each gds_temp-cpych where
        gds_temp-cpych.category = "gds":
    if gds_temp-cpych.gds-code > 0 then do:
      find first buf_goods no-lock where
                  buf_goods.gds-code = gds_temp-cpych.gds-code no-error.
      display stream prnlibstream
      "" @ v-chk-date-time
      '' @ buf_chk-gds.doc-code
      (if available buf_goods then buf_goods.artic else "") @ buf_goods.artic
      (if available buf_goods then buf_goods.gds-name else "!!!НЕИЗВ. ТОВАР") @ buf_goods.gds-name
      gds_temp-cpych.doc-qnty @  buf_chk-gds.doc-qnty
      gds_temp-cpych.doc-qnty-2 @ v-qnty-2
      gds_temp-cpych.sum-tot @ v-sum-tot
      gds_temp-cpych.discnt-sum @  buf_chk-discnt.discnt-value-abs
      gds_temp-cpych.sum-netto @ v-sum-netto
      with frame outframe.
      down 1 stream prnlibstream
      with frame outframe.
      if Make-Excel then  put   stream ForExcel unformatted
      CHR(9)
      CHR(9)
      CHR(9)
      (if available buf_goods then buf_goods.artic else "") CHR(9)
      (if available buf_goods then buf_goods.gds-name else "!!!НЕИЗВ. ТОВАР") CHR(9)
      CHR(9)
      gds_temp-cpych.doc-qnty  CHR(9)
      gds_temp-cpych.doc-qnty-2  CHR(9)
      gds_temp-cpych.sum-tot CHR(9)
      CHR(9)
      CHR(9)
      gds_temp-cpych.discnt-sum CHR(9)
      gds_temp-cpych.sum-netto
      skip.
      ii-excel = ii-excel + 1.
    end.
    else do:
      display stream prnlibstream
      "Итого по " @ v-chk-date-time
      ''  @ buf_chk-gds.doc-code
      '' @ buf_goods.artic
      "Сопутствующие товары" @ buf_goods.gds-name
      gds_temp-cpych.doc-qnty @  buf_chk-gds.doc-qnty
      gds_temp-cpych.doc-qnty-2 @  v-qnty-2
      gds_temp-cpych.sum-tot @ v-sum-tot
      gds_temp-cpych.discnt-sum @  buf_chk-discnt.discnt-value-abs
      gds_temp-cpych.sum-netto @ v-sum-netto
      with frame outframe.
      down 1 stream prnlibstream
      with frame outframe.
      if Make-Excel then  put   stream ForExcel unformatted
      CHR(9)
      CHR(9)
      CHR(9)
      CHR(9)
      "Сопутствующие товары" CHR(9)
      CHR(9)
      gds_temp-cpych.doc-qnty  CHR(9)
      gds_temp-cpych.doc-qnty-2  CHR(9)
      gds_temp-cpych.sum-tot CHR(9)
      CHR(9)
      CHR(9)
      gds_temp-cpych.discnt-sum CHR(9)
      gds_temp-cpych.sum-netto
      skip.
      ii-excel = ii-excel + 1.
    end.
  end.
  if p-discnt-dtl
  and can-find(first obj_temp-discnt where
            obj_temp-discnt.obj-type = ''
        and obj_temp-discnt.obj-code = 0)
  then do:
    put stream PrnLibStream unformatted
    "Итого по типам скидок"
    skip
    .
    if Make-Excel then  put   stream ForExcel unformatted
    "Итого по типам скидок"
    skip
    .
    ii-excel = ii-excel + 1.
    for each all_temp-discnt where
            all_temp-discnt.obj-type = ''
        and all_temp-discnt.obj-code = 0:
        display stream prnlibstream
      "---------->" @ v-pay-card
      entry (lookup (string(all_temp-discnt.discnt-type), '0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,23,17,18,19,20,21,22,998,999,1001':U), '?,Клиент,Стандарт,Временная,Количество,Сумма,Персонал,Промо,Уценка,Счастл.час,Комплект,Сезонная,Катег,Ручная,Карта-маска,Округл. в пользу.клиента,Катег с исп шаблона,Оплата топливным купоном (Ашан),Абсолютная,Группа,Платеж,ЛНР,Округление,Оплата,Доп.условие,Другое,Погрешность':U) @ v-discnt-name
      all_temp-discnt.discnt-sum @ buf_chk-discnt.discnt-value-abs
      with frame outframe.
      down 1 stream prnlibstream
      with frame outframe.
      if Make-Excel then  put   stream ForExcel unformatted
      "---------->" CHR(9)
      CHR(9)
      CHR(9)
      CHR(9)
      CHR(9)
      CHR(9)
      CHR(9)
      CHR(9)
      CHR(9)
      entry (lookup (string(all_temp-discnt.discnt-type), '0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,23,17,18,19,20,21,22,998,999,1001':U), '?,Клиент,Стандарт,Временная,Количество,Сумма,Персонал,Промо,Уценка,Счастл.час,Комплект,Сезонная,Катег,Ручная,Карта-маска,Округл. в пользу.клиента,Катег с исп шаблона,Оплата топливным купоном (Ашан),Абсолютная,Группа,Платеж,ЛНР,Округление,Оплата,Доп.условие,Другое,Погрешность':U) CHR(9)
      CHR(9)
      all_temp-discnt.discnt-sum CHR(9)
      skip
      .
      ii-excel = ii-excel + 1.
    end.
  end.
end.
find first all_temp-cpych where
          all_temp-cpych.obj-type = ''
      and all_temp-cpych.obj-code = 0
      and all_temp-cpych.category  =  "all" no-error.
if not available all_temp-cpych then do:
  create all_temp-cpych.
  assign
  all_temp-cpych.pay-card = ''
  all_temp-cpych.fpay-card = ''
  all_temp-cpych.chk-date  = ?
  all_temp-cpych.chk-time = 0
  all_temp-cpych.doc-code = ''
  all_temp-cpych.obj-type = obj-list.obj-type
  all_temp-cpych.obj-code = obj-list.obj-code
  all_temp-cpych.b-code  = 0
  all_temp-cpych.gds-code = 0
  all_temp-cpych.line-num = v-line + 1
  v-line = v-line + 1
  all_temp-cpych.num-chk = 0
  all_temp-cpych.discnt = 0
  all_temp-cpych.category = "all"
  .
end.
underline stream PrnLibStream
v-pay-card
v-chk-date-time
buf_chk-gds.doc-code
buf_goods.artic
buf_goods.gds-name
buf_chk-gds.price-base
buf_chk-gds.doc-qnty
v-qnty-2
v-sum-tot
v-discnt-name
buf_chk-discnt.discnt-value-pcnt
buf_chk-discnt.discnt-value-abs
v-sum-netto
with frame OutFrame.
down 1 stream PrnLibstream
with frame OutFrame.
display stream prnlibstream
"ИТОГО ПО ВСЕМ ОБЪЕКТАМ" @ v-pay-card
'' @ v-chk-date-time
'' @ buf_chk-gds.doc-code
'' @ buf_goods.artic
'чеков:' @ buf_goods.gds-name
all_temp-cpych.num-chk @ buf_chk-gds.price-base
all_temp-cpych.doc-qnty @  buf_chk-gds.doc-qnty
all_temp-cpych.doc-qnty-2 @  v-qnty-2
all_temp-cpych.sum-tot @ v-sum-tot
all_temp-cpych.discnt-sum @  buf_chk-discnt.discnt-value-abs
all_temp-cpych.sum-netto @ v-sum-netto
with frame outframe.
down 1 stream prnlibstream
with frame outframe.
if Make-Excel then  put   stream ForExcel unformatted
"ИТОГО ПО ВСЕМ ОБЪЕКТАМ" CHR(9)
CHR(9)
CHR(9)
CHR(9)
'чеков:' CHR(9)
all_temp-cpych.num-chk CHR(9)
all_temp-cpych.doc-qnty CHR(9)
all_temp-cpych.doc-qnty-2 CHR(9)
all_temp-cpych.sum-tot  CHR(9)
CHR(9)
CHR(9)
all_temp-cpych.discnt-sum  CHR(9)
all_temp-cpych.sum-netto
skip
.
ii-excel = ii-excel + 1.
run waitfram-hide in this-procedure .
HIDE STREAM PrnLibStream FRAME BottomFrame .
OUTPUT STREAM PrnLibStream CLOSE.
if Make-Excel then output stream ForExcel close.
run waitfram-hide in this-procedure .
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 8
                                          ).
procedure process-inkas :
define parameter buffer buf_temp-inkas for temp-inkas.
define variable v-doc-code as character no-undo .
define buffer buf_tt-cash-pay  for tt-cash-pay.
define buffer buf_chk-pay for ub.chk-pay.
define buffer buf_chk-doc for ub.chk-doc.
define buffer buf_temp-cpych for temp-cpych.
define buffer card-obj_temp-cpych for temp-cpych.
define buffer card_temp-cpych for temp-cpych.
for each buf_tt-cash-pay,
      each buf_chk-pay no-lock where
          buf_chk-pay.out-code = buf_temp-inkas.inkas-code
        and buf_chk-pay.pay-code = buf_tt-cash-pay.cdpay-code
        and buf_chk-pay.curr-code = buf_tt-cash-pay.curr-code
by  buf_chk-pay.doc-code           :
  if buf_chk-pay.pay-card = "0"
  or buf_chk-pay.pay-card = ""
  or buf_chk-pay.pay-card = ? then next.
  if p-pay-card <> ''
  and buf_chk-pay.pay-card <> p-pay-card then next.
  if v-doc-code <> buf_chk-pay.doc-code then do:
    find first card-obj_temp-cpych where
            card-obj_temp-cpych.pay-card = buf_chk-pay.pay-card
        and card-obj_temp-cpych.obj-type = buf_chk-pay.obj-type
        and card-obj_temp-cpych.obj-code = buf_chk-pay.obj-code
        and card-obj_temp-cpych.category = "card-obj"
        no-error.
    if not available card-obj_temp-cpych then do:
      create card-obj_temp-cpych.
      assign
      card-obj_temp-cpych.pay-card = buf_chk-pay.pay-card
      card-obj_temp-cpych.fpay-card = fill( chr(32) , 16 - length(buf_chk-pay.pay-card)) + buf_chk-pay.pay-card
      card-obj_temp-cpych.chk-date  = ?
      card-obj_temp-cpych.chk-time = 0
      card-obj_temp-cpych.doc-code = ''
      card-obj_temp-cpych.obj-type = buf_chk-pay.obj-type
      card-obj_temp-cpych.obj-code = buf_chk-pay.obj-code
      card-obj_temp-cpych.b-code   = 0
      card-obj_temp-cpych.line-num  = 0
      card-obj_temp-cpych.category = "card-obj"
      .
    end.
    find first card_temp-cpych where
            card_temp-cpych.pay-card = buf_chk-pay.pay-card
        and card_temp-cpych.obj-type = ''
        and card_temp-cpych.obj-code = 0
        and card_temp-cpych.category = "card"
        no-error.
    if not available card_temp-cpych then do:
      create card_temp-cpych.
      assign
      card_temp-cpych.pay-card = buf_chk-pay.pay-card
      card_temp-cpych.fpay-card = fill( chr(32) , 16 - length(buf_chk-pay.pay-card)) + buf_chk-pay.pay-card
      card_temp-cpych.chk-date  = ?
      card_temp-cpych.chk-time = 0
      card_temp-cpych.doc-code = ''
      card_temp-cpych.obj-type = ''
      card_temp-cpych.obj-code = 0
      card_temp-cpych.b-code   = 0
      card_temp-cpych.line-num  = 0
      card_temp-cpych.category = "card"
      .
    end.
    find first obj_temp-cpych where
              obj_temp-cpych.obj-type = obj-list.obj-type
          and obj_temp-cpych.obj-code = obj-list.obj-code
          and obj_temp-cpych.category = "obj" no-error.
    if not available obj_temp-cpych then do:
      create obj_temp-cpych.
      assign
      obj_temp-cpych.pay-card = ''
      obj_temp-cpych.fpay-card = ''
      obj_temp-cpych.chk-date  = ?
      obj_temp-cpych.chk-time = 0
      obj_temp-cpych.doc-code = ''
      obj_temp-cpych.obj-type = obj-list.obj-type
      obj_temp-cpych.obj-code = obj-list.obj-code
      obj_temp-cpych.b-code  = 0
      obj_temp-cpych.gds-code = 0
      obj_temp-cpych.line-num = v-line + 1
      v-line = v-line + 1
      obj_temp-cpych.num-chk = 0
      obj_temp-cpych.discnt = 0
      obj_temp-cpych.category = "obj"
      .
    end.
    find first all_temp-cpych where
              all_temp-cpych.obj-type = ''
          and all_temp-cpych.obj-code = 0
          and all_temp-cpych.category = "all" no-error.
    if not available all_temp-cpych then do:
      create all_temp-cpych.
      assign
      all_temp-cpych.pay-card = ''
      all_temp-cpych.fpay-card = ''
      all_temp-cpych.chk-date  = ?
      all_temp-cpych.chk-time = 0
      all_temp-cpych.doc-code = ''
      all_temp-cpych.obj-type = ''
      all_temp-cpych.obj-code = 0
      all_temp-cpych.b-code  = 0
      all_temp-cpych.gds-code = 0
      all_temp-cpych.line-num = v-line + 1
      v-line = v-line + 1
      all_temp-cpych.num-chk = 0
      all_temp-cpych.discnt = 0
      all_temp-cpych.category = "all"
      .
    end.
    find first buf_temp-cpych where
            buf_temp-cpych.pay-card = buf_chk-pay.pay-card
        and buf_temp-cpych.doc-code = buf_chk-pay.doc-code no-error.
    if not available buf_temp-cpych then do:
      find first buf_chk-doc no-lock where
                buf_chk-doc.doc-code = buf_chk-pay.doc-code no-error.
      if available buf_chk-doc then do:
        assign
        card-obj_temp-cpych.num-chk = card-obj_temp-cpych.num-chk + 1
        card_temp-cpych.num-chk     = card_temp-cpych.num-chk + 1
        obj_temp-cpych.num-chk     = obj_temp-cpych.num-chk + 1
        all_temp-cpych.num-chk     = all_temp-cpych.num-chk + 1
        .
        for each buf_chk-gds no-lock where
                buf_chk-gds.doc-code = buf_chk-doc.doc-code:
          create buf_temp-cpych.
          assign
          buf_temp-cpych.pay-card = buf_chk-pay.pay-card
          buf_temp-cpych.fpay-card = fill( chr(32) , 16 - length(buf_chk-pay.pay-card)) + buf_chk-pay.pay-card
          buf_temp-cpych.chk-date  = buf_chk-doc.chk-date
          buf_temp-cpych.chk-time = buf_chk-doc.chk-time
          buf_temp-cpych.doc-code = buf_chk-doc.doc-code
          buf_temp-cpych.obj-type = buf_chk-doc.obj-type
          buf_temp-cpych.obj-code = buf_chk-doc.obj-code
          buf_temp-cpych.b-code   = buf_chk-gds.b-code
          buf_temp-cpych.price-base = buf_chk-gds.price-base
          buf_temp-cpych.doc-qnty = buf_chk-gds.doc-qnty
          buf_temp-cpych.doc-qnty-2 = (if buf_chk-gds.pump > 0
                                       then buf_chk-gds.doc-qnty * buf_chk-gds.density
                                       else 0)
          buf_temp-cpych.sum-tot   = buf_chk-gds.doc-qnty * buf_chk-gds.price-base
          buf_temp-cpych.discnt    = buf_chk-gds.discnt
          buf_temp-cpych.sum-netto  = buf_chk-gds.doc-qnty * (buf_chk-gds.price-base - buf_chk-gds.discnt)
          buf_temp-cpych.num-chk = 0
          buf_temp-cpych.line-num = buf_chk-gds.line-num
          buf_temp-cpych.is-ptrl = (buf_chk-gds.pump > 0)
          buf_temp-cpych.category = ""
          .
          assign
          card-obj_temp-cpych.doc-qnty  = card-obj_temp-cpych.doc-qnty + buf_chk-gds.doc-qnty
          card-obj_temp-cpych.doc-qnty-2  = card-obj_temp-cpych.doc-qnty-2 + (if buf_chk-gds.pump > 0
                                                                              then buf_chk-gds.doc-qnty * buf_chk-gds.density
                                                                              else 0)
          card-obj_temp-cpych.sum-tot   = card-obj_temp-cpych.sum-tot + buf_chk-gds.doc-qnty * buf_chk-gds.price-base
          card-obj_temp-cpych.sum-netto  = card-obj_temp-cpych.sum-netto + buf_chk-gds.doc-qnty * (buf_chk-gds.price-base - buf_chk-gds.discnt)
          card_temp-cpych.doc-qnty  = card_temp-cpych.doc-qnty + buf_chk-gds.doc-qnty
          card_temp-cpych.doc-qnty-2  = card_temp-cpych.doc-qnty + (if buf_chk-gds.pump > 0
                                                                    then buf_chk-gds.doc-qnty * buf_chk-gds.density
                                                                    else 0)
          card_temp-cpych.sum-tot   = card_temp-cpych.sum-tot + buf_chk-gds.doc-qnty * buf_chk-gds.price-base
          card_temp-cpych.sum-netto  = card_temp-cpych.sum-netto + buf_chk-gds.doc-qnty * (buf_chk-gds.price-base - buf_chk-gds.discnt)
          .
          release buf_temp-cpych.
        end.
      end.
      release card-obj_temp-cpych.
      release card_temp-cpych.
      release obj_temp-cpych.
      release all_temp-cpych.
    end.
    v-doc-code = buf_chk-pay.doc-code.
  end.
end.
end procedure.
