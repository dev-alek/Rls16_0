block-level on error undo, throw.
define input parameter iCntxtHostCodeObj as integer   no-undo.
define input parameter iChkTypeCodeList  as character no-undo.
define input parameter iGdsCodeList      as character no-undo.
define input parameter iCashPayList      as character no-undo.
define input parameter iTRKList          as character no-undo.
define input parameter iTranTimeMax      as integer   no-undo.
define input parameter iGrpChk           as logical   no-undo.
define input parameter iGrpTran          as logical   no-undo.
define variable vss-revision    as character     no-undo init "$ $":U .
define variable vss-author      as character     no-undo init "$ $":U .
define variable vss-date        as character     no-undo init "$ $":U .
define variable vss-workfile    as character     no-undo init "$ $":U .
define variable vss-archive     as character     no-undo init "$ $":U .
define variable vss-description as character     no-undo init "Отчет по длительности транзакций".
define variable parparentproc   as widget-handle no-undo.
define variable mParamStr       as character     no-undo extent 10.
define variable mProdBcStrList  as character     no-undo.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
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
procedure fd-attr-code :
  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo .
    define output parameter p-type           as character no-undo .
    define output parameter p-format         as character no-undo .
    define output parameter p-label          as character no-undo .
    define output parameter p-user-can-edit  as logical   no-undo .
    define output parameter p-output-display as logical   no-undo .
    define output parameter p-other          as character no-undo .
    case p-code :
            when 'shift-date':U then do:     assign     p-label = "Дата смены"     p-type = 'T':U      p-format = "99/99/9999"     p-label = "Дата смены"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'shift-num':U then do:     assign     p-label = "П.смены"     p-type = 'I':U      p-format = "99"     p-label = "П.смены"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'shift-name':U then do:     assign     p-label = "№ смены"     p-type = 'C':U      p-format = "X(2)"     p-label = "№ смены"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'barcode':U then do:     assign     p-label = "Штрих-код"     p-type = 'C':U      p-format = "X(20)"     p-label = "Штрих-код"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'lockid':U then do:     assign     p-label = "ID блокировки чека"     p-type = 'C':U      p-format = "X(2)"     p-label = "ID блокировки чека"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'cover_sheet':U then do:     assign     p-label = "Разбиение по номиналам"     p-type = 'C':U      p-format = "X(4000)"     p-label = "Разбиение по номиналам"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'pre-vedom':U then do:     assign     p-label = "Атрибут для препроводительной ведомости"     p-type = 'C':U      p-format = "X(256)"     p-label = "Атрибут для препроводительной ведомости"     p-user-can-edit  = false     p-output-display = false     p-other = '':u      .   end.
            when 'contr-kb':U then do:     assign     p-label = "Код кассовой книги получателя\отправителя при перемещении ДС между кассами"     p-type = 'I':U      p-format = ">>>9"     p-label = "Код кассовой книги получателя\отправителя при перемещении ДС между кассами"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
      otherwise do:
        undo, return error "неизвестный атрибут платежа" + " " + p-code .
      end.
    end.
  end.
end procedure.
procedure fd-attr-tooltip :
  do
  on error undo, return error
  :
    define input  parameter p-code    as character no-undo .
    define output parameter p-tooltip as character no-undo .
    define output parameter p-label   as character no-undo .
    case p-code :
            when 'shift-date':U then do:     assign     p-tooltip = "Дата смены"     p-label = "Дата смены" .   end.
            when 'shift-num':U then do:     assign     p-tooltip = "П.смены"     p-label = "П.смены" .   end.
            when 'shift-name':U then do:     assign     p-tooltip = "№ смены"     p-label = "№ смены" .   end.
            when 'barcode':U then do:     assign     p-tooltip = "Штрих-код"     p-label = "Штрих-код" .   end.
            when 'lockid':U then do:     assign     p-tooltip = "ID блокировки чека"     p-label = "ID блокировки чека" .   end.
            when 'cover_sheet':U then do:     assign     p-tooltip = "Разбиение по номиналам"     p-label = "Разбиение по номиналам" .   end.
            when 'pre-vedom':U then do:     assign     p-tooltip = "Атрибут для препроводительной ведомости"     p-label = "Атрибут для препроводительной ведомости" .   end.
            when 'contr-kb':U then do:     assign     p-tooltip = "Код кассовой книги получателя\отправителя при перемещении ДС между кассами"     p-label = "Код кассовой книги получателя\отправителя при перемещении ДС между кассами" .   end.
      otherwise do:
        undo, return error "неизвестный атрибут платежа" + " " + p-code .
      end.
    end.
  end.
end procedure.
procedure fin-doc-attr-write :
 do
 on error undo, return error return-value
 :
define input parameter p-host-code     like ub.fin-doc-attr.host-code  no-undo .
define input parameter p-fin-doc-code  like ub.fin-doc-attr.fin-doc-code   no-undo .
define input parameter p-attr-code     like ub.fin-doc-attr.attr-code  no-undo .
define input parameter p-attr-value    like ub.fin-doc-attr.attr-value no-undo .
define variable  v-format         as character no-undo .
define variable  v-label          as character no-undo .
define variable  v-user-can-edit  as logical   no-undo .
define variable  v-output-display as logical   no-undo .
define variable  v-other          as character no-undo .
define variable  v-type           as character no-undo .
define buffer buf_fin-doc-attr for ub.fin-doc-attr.
run fd-attr-code in this-procedure
                                  (input  p-attr-code
                                  ,output v-type
                                  ,output v-format
                                  ,output v-label
                                  ,output v-user-can-edit
                                  ,output v-output-display
                                  ,output v-other
                                  ) no-error .
if error-status :error then do:
  undo, return error return-value .
end.
find first buf_fin-doc-attr  exclusive-lock  where
          buf_fin-doc-attr.attr-code    = p-attr-code
      AND buf_fin-doc-attr.host-code    = p-host-code
      AND buf_fin-doc-attr.fin-doc-code     = p-fin-doc-code  no-error .
  if not available  buf_fin-doc-attr then do:
      create buf_fin-doc-attr.
      assign
      buf_fin-doc-attr.attr-code    = p-attr-code
      buf_fin-doc-attr.attr-value   = p-attr-value
      buf_fin-doc-attr.host-code    = p-host-code
      buf_fin-doc-attr.fin-doc-code     = p-fin-doc-code
      .
  end.
  else do:
       assign
       buf_fin-doc-attr.attr-value = p-attr-value.
  end.
 end.
end procedure.
procedure fd-attr-exist :
  do
  on error undo, return error
  :
    define input parameter p-host-code     like ub.fin-doc-attr.host-code  no-undo .
    define input parameter p-fin-doc-code  like ub.fin-doc-attr.fin-doc-code   no-undo .
    define input parameter p-code          like ub.fin-doc-attr.attr-code  no-undo .
    define output parameter p-exist   as logical  no-undo .
    define buffer buf_fin-doc-attr for ub.fin-doc-attr .
    define variable  v-type           as character no-undo .
    define variable  v-format         as character no-undo .
    define variable  v-label          as character no-undo .
    define variable  v-user-can-edit  as logical   no-undo .
    define variable  v-output-display as logical   no-undo .
    define variable  v-other          as character no-undo .
    run fd-attr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_fin-doc-attr exclusive-lock
      where buf_fin-doc-attr.host-code  = p-host-code
        and buf_fin-doc-attr.fin-doc-code  = p-fin-doc-code
        and buf_fin-doc-attr.attr-code = p-code
      no-error .
    if  available buf_fin-doc-attr then do:
      p-exist = yes.
    end.
  end.
end procedure.
procedure fd-attr-delete :
  do
  on error undo, return error
  :
  define input parameter p-host-code     like ub.fin-doc-attr.host-code  no-undo .
  define input parameter p-fin-doc-code  like ub.fin-doc-attr.fin-doc-code   no-undo .
  define input parameter p-code          like ub.fin-doc-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
    define buffer buf_fin-doc-attr for ub.fin-doc-attr .
    define variable  v-type           as character no-undo .
    define variable  v-format         as character no-undo .
    define variable  v-label          as character no-undo .
    define variable  v-user-can-edit  as logical   no-undo .
    define variable  v-output-display as logical   no-undo .
    define variable  v-other          as character no-undo .
    run fd-attr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_fin-doc-attr exclusive-lock
      where buf_fin-doc-attr.host-code  = p-host-code
        and buf_fin-doc-attr.fin-doc-code  = p-fin-doc-code
        and buf_fin-doc-attr.attr-code = p-code
      no-error NO-WAIT.
    if not available buf_fin-doc-attr then do:
      p-deleted = no.
    end.
    else do:
      delete buf_fin-doc-attr no-error .
      if error-status:error then do:
        undo, return error return-value .
      end.
      p-deleted = yes.
    end.
  end.
end procedure.
procedure fin-doc-attr-value :
 do
 on error undo, return error return-value
 :
define input  parameter p-host-code    like ub.fin-doc-attr.host-code    no-undo .
define input  parameter p-fin-doc-code like ub.fin-doc-attr.fin-doc-code     no-undo .
define input  parameter p-attr-code    like ub.fin-doc-attr.attr-code    no-undo .
define output parameter p-attr-value   like ub.fin-doc-attr.attr-value   no-undo .
define variable  v-format         as character no-undo .
define variable  v-label          as character no-undo .
define variable  v-user-can-edit  as logical   no-undo .
define variable  v-output-display as logical   no-undo .
define variable  v-other          as character no-undo .
define variable  v-type           as character no-undo .
define buffer buf_fin-doc-attr for ub.fin-doc-attr.
run fd-attr-code in this-procedure
  (input  p-attr-code
  ,output v-type
  ,output v-format
  ,output v-label
  ,output v-user-can-edit
  ,output v-output-display
  ,output v-other
  ) no-error .
if error-status :error then do:
  undo, return error return-value .
end.
find first buf_fin-doc-attr no-lock where
          buf_fin-doc-attr.attr-code    = p-attr-code
      AND buf_fin-doc-attr.host-code     = p-host-code
      AND buf_fin-doc-attr.fin-doc-code = p-fin-doc-code      no-error .
  if available  buf_fin-doc-attr then do:
    assign
    p-attr-value = buf_fin-doc-attr.attr-value
    .
  end.
  else do:
    p-attr-value = ? .
  end.
 end.
end procedure.
procedure fd-attr-news :
  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo .
    define output parameter p-news           as logical   no-undo .
    case p-code :
            when 'shift-date':U then do:     assign     p-news = no.   end.
            when 'shift-num':U then do:     assign     p-news = no.   end.
            when 'shift-name':U then do:     assign     p-news = no.   end.
            when 'barcode':U then do:     assign     p-news = no.   end.
            when 'lockid':U then do:     assign     p-news = no.   end.
            when 'cover_sheet':U then do:     assign     p-news = no.   end.
            when 'pre-vedom':U then do:     assign     p-news = no.   end.
      otherwise do:
        undo, return error "неизвестный атрибут платежа " + " " + p-code .
      end.
    end.
  end.
end procedure.
procedure c-fin-doc-attr-write :
 do
 on error undo, return error return-value
 :
define input parameter p-host-code     like ub.c-fin-doc-attr.host-code  no-undo .
define input parameter p-fin-doc-code  like ub.c-fin-doc-attr.fin-doc-code   no-undo .
define input parameter p-corr-user-db-num  like ub.c-fin-doc-attr.corr-user-db-num   no-undo .
define input parameter p-chip-num      like ub.c-fin-doc-attr.chip-num   no-undo .
define input parameter p-attr-code     like ub.c-fin-doc-attr.attr-code  no-undo .
define input parameter p-attr-value    like ub.c-fin-doc-attr.attr-value no-undo .
define variable  v-format         as character no-undo .
define variable  v-label          as character no-undo .
define variable  v-user-can-edit  as logical   no-undo .
define variable  v-output-display as logical   no-undo .
define variable  v-other          as character no-undo .
define variable  v-type           as character no-undo .
define buffer buf_c-fin-doc-attr for ub.c-fin-doc-attr.
run fd-attr-code in this-procedure
                                  (input  p-attr-code
                                  ,output v-type
                                  ,output v-format
                                  ,output v-label
                                  ,output v-user-can-edit
                                  ,output v-output-display
                                  ,output v-other
                                  ) no-error .
if error-status :error then do:
  undo, return error return-value .
end.
find first buf_c-fin-doc-attr  exclusive-lock  where
          buf_c-fin-doc-attr.attr-code    = p-attr-code
      AND buf_c-fin-doc-attr.host-code    = p-host-code
      AND buf_c-fin-doc-attr.fin-doc-code     = p-fin-doc-code
      AND buf_c-fin-doc-attr.corr-user-db-num = p-corr-user-db-num
      AND buf_c-fin-doc-attr.chip-num         = p-chip-num      no-error .
  if not available  buf_c-fin-doc-attr then do:
      create buf_c-fin-doc-attr.
      assign
      buf_c-fin-doc-attr.attr-code    = p-attr-code
      buf_c-fin-doc-attr.attr-value   = p-attr-value
      buf_c-fin-doc-attr.host-code    = p-host-code
      buf_c-fin-doc-attr.fin-doc-code     = p-fin-doc-code
      .
  end.
  else do:
        buf_c-fin-doc-attr.attr-value   = p-attr-value .
  end.
 end.
end procedure.
procedure c-fin-doc-attr-value :
 do
 on error undo, return error return-value
 :
define input  parameter p-host-code    like ub.c-fin-doc-attr.host-code    no-undo .
define input  parameter p-fin-doc-code like ub.c-fin-doc-attr.fin-doc-code     no-undo .
define input parameter p-corr-user-db-num  like ub.c-fin-doc-attr.corr-user-db-num   no-undo .
define input parameter p-chip-num      like ub.c-fin-doc-attr.chip-num   no-undo .
define input  parameter p-attr-code    like ub.c-fin-doc-attr.attr-code    no-undo .
define output parameter p-attr-value   like ub.c-fin-doc-attr.attr-value   no-undo .
define variable  v-format         as character no-undo .
define variable  v-label          as character no-undo .
define variable  v-user-can-edit  as logical   no-undo .
define variable  v-output-display as logical   no-undo .
define variable  v-other          as character no-undo .
define variable  v-type           as character no-undo .
define buffer buf_c-fin-doc-attr for ub.c-fin-doc-attr.
run fd-attr-code in this-procedure
  (input  p-attr-code
  ,output v-type
  ,output v-format
  ,output v-label
  ,output v-user-can-edit
  ,output v-output-display
  ,output v-other
  ) no-error .
if error-status :error then do:
  undo, return error return-value .
end.
find first buf_c-fin-doc-attr no-lock where
          buf_c-fin-doc-attr.attr-code    = p-attr-code
      AND buf_c-fin-doc-attr.fin-doc-code      = p-fin-doc-code
      AND buf_c-fin-doc-attr.host-code      = p-host-code
      AND buf_c-fin-doc-attr.corr-user-db-num = p-corr-user-db-num
      AND buf_c-fin-doc-attr.chip-num         = p-chip-num      no-error .
  if available  buf_c-fin-doc-attr then do:
    assign
    p-attr-value = buf_c-fin-doc-attr.attr-value
    .
  end.
  else do:
    p-attr-value = ? .
  end.
 end.
end procedure.
procedure c-fin-doc-attr-value-nextchip :
 do
 on error undo, return error return-value
 :
define input  parameter p-host-code    like ub.c-fin-doc-attr.host-code    no-undo .
define input  parameter p-fin-doc-code like ub.c-fin-doc-attr.fin-doc-code     no-undo .
define input parameter p-corr-user-db-num  like ub.c-fin-doc-attr.corr-user-db-num   no-undo .
define input parameter p-chip-num      like ub.c-fin-doc-attr.chip-num   no-undo .
define input  parameter p-attr-code    like ub.c-fin-doc-attr.attr-code    no-undo .
define output parameter p-attr-value   like ub.c-fin-doc-attr.attr-value   no-undo .
define variable  v-format         as character no-undo .
define variable  v-label          as character no-undo .
define variable  v-user-can-edit  as logical   no-undo .
define variable  v-output-display as logical   no-undo .
define variable  v-other          as character no-undo .
define variable  v-type           as character no-undo .
define buffer buf_c-fin-doc-attr for ub.c-fin-doc-attr.
run fd-attr-code in this-procedure
  (input  p-attr-code
  ,output v-type
  ,output v-format
  ,output v-label
  ,output v-user-can-edit
  ,output v-output-display
  ,output v-other
  ) no-error .
if error-status :error then do:
  undo, return error return-value .
end.
find first buf_c-fin-doc-attr no-lock where
          buf_c-fin-doc-attr.attr-code    = p-attr-code
      and buf_c-fin-doc-attr.fin-doc-code      = p-fin-doc-code
      and buf_c-fin-doc-attr.host-code      = p-host-code
      and buf_c-fin-doc-attr.corr-user-db-num = p-corr-user-db-num
      and buf_c-fin-doc-attr.chip-num         > p-chip-num      no-error .
  if available  buf_c-fin-doc-attr then do:
    assign
    p-attr-value = buf_c-fin-doc-attr.attr-value
    .
  end.
  else do:
    p-attr-value = ? .
  end.
 end.
end procedure.
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION gbclcode-is-this-db-code returns logical ( input p-db-num as integer
                                                    ,input p-range-type as character
                                                    ,input p-code as integer):
define variable v-seq-val as integer no-undo .
define buffer buf_code-range for ub.code-range.
find first buf_code-range no-lock where
          buf_code-range.db-num = p-db-num
    and  buf_code-range.range-type = p-range-type
    and  buf_code-range.stts = 'u'
    and buf_code-range.first-code <= p-code
    and buf_code-range.last-code >= p-code no-error .
if available buf_code-range then return yes.
CASE p-range-type:
  when 'pngb':U then do:
    v-seq-val = current-value(s-pngb-code, ub).
  end.
  when 'fmgb':U then do:
    v-seq-val = current-value(s-fmgb-code, ub).
  end.
END CASE.
if p-code <= v-seq-val then do:
  find first buf_code-range no-lock where
            buf_code-range.db-num = p-db-num
      and  buf_code-range.range-type = p-range-type
      and  buf_code-range.stts = 'a'
      and buf_code-range.first-code <= p-code
      no-error .
 if available buf_code-range then return yes.
end.
find first buf_code-range no-lock where
          buf_code-range.db-num = p-db-num
    and  buf_code-range.range-type = p-range-type
    and  buf_code-range.stts = 'f'
    and buf_code-range.first-code <= p-code
    and buf_code-range.last-code >= p-code
    no-error .
if available buf_code-range then return yes.
return no.
END FUNCTION.
FUNCTION gbclcode-is-this-db-code-short returns logical ( input p-db-num as integer
                                                    ,input p-range-type as character
                                                    ,input p-code as integer):
define variable v-seq-val as integer no-undo .
define buffer buf_code-range for ub.code-range.
CASE p-range-type:
  when 'pngb':U then do:
    v-seq-val = current-value(s-pngb-code, ub).
  end.
  when 'fmgb':U then do:
    v-seq-val = current-value(s-fmgb-code, ub).
  end.
END CASE.
if p-code <= v-seq-val then do:
  find first buf_code-range no-lock where
            buf_code-range.db-num = p-db-num
      and  buf_code-range.range-type = p-range-type
      and buf_code-range.first-code <= p-code
      and buf_code-range.last-code >= p-code no-error .
  if available buf_code-range then return yes.
end.
return no.
END FUNCTION.
FUNCTION gbclcode-is-this-db-role returns integer ( input p-role as character
                                                    ,input p-db-num as integer
                                                    ,input p-staff-code as integer
                                                    ,input p-date as date
                                                     ):
define buffer buf_staff for ub.staff.
if p-date = ? then do:
  p-date = today .
end.
find first buf_staff no-lock where
          buf_staff.role = p-role
      and buf_staff.role-level = 'db':U
      and buf_staff.db-num = p-db-num
      and buf_staff.staff-code = p-staff-code
      and buf_staff.date-end >= p-date use-index pi  no-error .
if available buf_staff then do:
  return buf_staff.psn-code.
end.
return 0.
end FUNCTION.
FUNCTION gbclcode-get-this-db-first-role returns integer ( input p-role as character
                                                          ,input p-db-num as integer
                                                          ,input p-date as date
                                                              ):
define buffer buf_staff for ub.staff.
define buffer buf2_staff for ub.staff.
if p-date = ? then do:
  p-date = today .
end.
for each  buf_staff no-lock where
          buf_staff.role = p-role
      and buf_staff.db-num = p-db-num,
first buf2_staff no-lock where
      buf2_staff.role = p-role
  and buf2_staff.role-level = 'db':U
  and buf2_staff.staff-code = buf_staff.staff-code
  and buf2_staff.date-start <= p-date
  and buf2_staff.date-end >= p-date
by buf_staff.staff-code
by date-start descending:
  return buf_staff.staff-code.
end.
end FUNCTION.
FUNCTION gbclcode-get-db-role returns integer ( input p-role as character
                                               ,input p-db-num as integer
                                               ,input p-psn-code as integer
                                               ,input p-date as date
                                               ,output p-c-password as character
                                                     ):
define buffer buf_staff for ub.staff.
if p-date = ? then do:
  p-date = today .
end.
find first buf_staff no-lock where
          buf_staff.role = p-role
      and buf_staff.role-level = 'db':U
      and buf_staff.db-num = p-db-num
     and buf_staff.date-end >= p-date
     and buf_staff.psn-code = p-psn-code use-index irole-psn no-error .
if available buf_staff
then do:
  assign
  p-c-password = buf_staff.password.
  return buf_staff.staff-code.
end.
p-c-password = ''.
return 0.
end FUNCTION.
FUNCTION gbclcode-is-psn-role returns integer (
                                              input p-role as character
                                              ,input p-psn-code as integer
                                              ,input p-date as date
                                                  ):
define buffer buf_staff for ub.staff.
if p-date = ? then do:
  p-date = today .
end.
for each buf_staff no-lock where
          buf_staff.psn-code = p-psn-code
     and  buf_staff.role = p-role
by buf_staff.role-level
by buf_staff.date-start
     :
  if  buf_staff.date-start <= p-date and
  buf_staff.date-end >= p-date  then do:
    return buf_staff.staff-code.
  end.
end.
return 0.
end FUNCTION.
FUNCTION gbclcode-get-role-name returns character ( input p-role as character):
define variable v-role-name as character no-undo .
assign
v-role-name = entry (lookup (p-role, 'C,S':U) + 1, ',':U + 'Кассир,Продавец':U)
no-error .
return v-role-name.
END.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION gbclcode-get-position returns character ( input p-role as character
                                                  ,input p-role-level as character
                                                  ,input p-work-place as character
                                                  ,input p-staff-code as integer
                                                             ):
define variable v-role-name as character no-undo .
define variable v-role-level as character no-undo .
define variable v-staff-code as integer no-undo .
assign
v-role-name = entry (lookup (p-role, 'C,S':U) + 1, ',':U + 'Кассир,Продавец':U)
v-role-level = substitute("&1 &2", entry (lookup (p-role-level, 'global,db,firm,object':U) + 1, ',':U + 'Глобально,БД,Фирма,Объект':U) , p-work-place)
v-staff-code = p-staff-code
no-error .
return substitute("&1, &2, Код &3"
                ,v-role-name
                ,v-role-level
                ,(if p-staff-code = 0 then chr(63) else string(p-staff-code))).
END.
FUNCTION gbclcode-get-work-place returns character (
                                                input p-role as character
                                               ,input p-role-level as character
                                               ,input p-db-num as integer
                                               ,input p-host-code as integer
                                               ,input p-obj-type as character
                                               ,input p-obj-code as integer
                                               ) :
define variable v-work-place as character no-undo .
define variable v-obj-type as character no-undo .
  case p-role-level:
    when 'db':U then do:
      v-work-place = string(p-db-num, "99999").
    end.
    when 'firm':U then do:
      v-work-place = string(p-host-code, "99999").
    end.
    when 'object':U then do:
      assign
      v-work-place = p-obj-type + string(p-obj-code, "999999999")
      .
    end.
  END CASE.
  return v-work-place.
END FUNCTION.
FUNCTION gbclcode-get-level-last-code returns integer (
                                                        input p-role as character
                                                      , input p-role-level as character
                                                      , input p-work-place as character
                                                      , input p-date-start as date
                                                      ):
DEFINE VARIABLE v-today as date no-undo .
define buffer buf_staff for ub.staff.
if p-work-place = chr(63) then return ?.
if p-date-start = ? then do:
  v-today = today .
end.
else do:
  v-today = p-date-start.
end.
find last buf_staff no-lock where
          buf_staff.role = p-role
     and  buf_staff.role-level = p-role-level
     and  buf_staff.work-place = p-work-place
     and  buf_staff.date-start <= v-today + 1
     and  buf_staff.date-end >= v-today + 1
     use-index pi  no-error .
if available buf_staff
then return buf_staff.staff-code.
return 0.
end FUNCTION.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared stream PrnLibStream.
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
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define  temp-table tt-rep no-undo
   field obj-type          as character
   field obj-code          as integer
   field obj-name          as character
   field chk-date          as date
   field chk-time          as integer
   field sort-date         as date
   field sort-time         as integer
   field shift-date        as date
   field shift-name        as character
   field doc-code          as character
   field chk-num           as integer
   field line-num          as integer
   field doc-num2          as character
   field z-number          as integer
   field tran-num          as integer
   field chk-type-desc     as character
   field pay-desk          as character
   field cash-num          as integer
   field cashier           as character
   field trk-num           as integer
   field nozzle-num        as integer
   field fuel-code         as integer
   field gds-name          as character
   field volume            as decimal
   field price             as decimal
   field money             as decimal
   field cash-pay-code     as integer
   field cash-pay-name     as character
   field pay-card          as character
   field datetime-beg      as datetime
   field date-beg          as date
   field time-beg          as integer
   field datetime-end      as datetime
   field date-end          as date
   field time-end          as integer
   field time-length       as integer
   field all-time-length   as integer
   field all-time-length-2 as integer
   field multi-pay         as logical
   field resume-tran       as logical
   field uuid              as character
   field uuid-cheq         as character
   field grp-num           as integer
   field db-num            as integer
index pi obj-code shift-date shift-name sort-date sort-time pay-desk fuel-code trk-num nozzle-num
index si1 obj-code grp-num datetime-beg
index CashPayNname cash-pay-name
index GrpNum grp-num
index ChkTypeDesc chk-type-desc
index iuuid db-num uuid-cheq uuid
index UuidCheq db-num uuid uuid-cheq
index UuidCHKType db-num uuid chk-type-desc
index DateTimeBeg datetime-beg
index AllTimeLength2 all-time-length-2
index sort obj-code sort-date sort-time
.
define  temp-table tt-all-total-rep no-undo
   field obj-type           as character
   field obj-code           as integer
   field qty-chk            as integer
   field qty-tran           as integer
   field qty-chk-fuel       as integer
   field full-time-tran     as integer
   field avg-time-tran      as integer
   field avg-time-tran-fuel as integer
index obj obj-type obj-code
.
define  temp-table tt-total-rep no-undo like tt-all-total-rep
   field obj-name           as character
index ObjName obj-type obj-code obj-name
.
define  temp-table tt-grp no-undo
   field obj-type           as character
   field obj-code           as integer
   field obj-name           as character
   field grp-num            as integer
   field all-time-length    as integer
   field all-time-length-2  as integer
   field cash-pay-code      as integer
   field cash-pay-name      as character
   field resume-tran        as logical
index ObjName obj-type obj-code obj-name
index ResumeTran  resume-tran
index GrpNum grp-num
.
define  temp-table tt-grp-uuid no-undo
   field grp-num            as integer
   field uuid               as character
 index uid uuid grp-num.
.
define  temp-table tt-grp-cheq-uuid no-undo
   field grp-num            as integer
   field uuid               as character
 index uid uuid grp-num.
.
define  temp-table tt-pay no-undo
   field seq             as integer
   field volume          as decimal
   field money           as decimal
   field cash-pay-code   as integer
   field cash-pay-name   as character
   field pay-card        as character
   field multi-pay       as logical
  index pi seq
  .
procedure CreateOneRec:
   define parameter buffer obj-list  for obj-list.
   define parameter buffer chk-doc   for chk-doc.
   define parameter buffer tran-fuel for tran-fuel.
   define parameter buffer chk-gds   for chk-gds.
   define parameter buffer goods     for goods.
   define buffer cash-pay    for cash-pay.
   define buffer b-chk-gds   for chk-gds.
   define buffer b-tran-fuel for tran-fuel.
   define variable v-chk-type-desc as character no-undo.
   define variable v-cash-pay-code as integer   no-undo.
   define variable v-cash-pay-name as character no-undo.
   define variable v-pay-card      as character no-undo.
   define variable v-psn-code      as integer   no-undo.
   define variable v-db-num        as integer   no-undo.
   define variable vDateBeg        as datetime  no-undo.
   define variable vDateEnd        as datetime  no-undo.
   define variable vSeq            as integer   no-undo.
   define variable vMoney          as decimal   no-undo.
   define variable vVolume         as decimal   no-undo.
   define variable vTotSum         as decimal   no-undo.
   do:
      vVolume = if can-do("6,14,16", string(chk-doc.chk-type)) then chk-gds.doc-qnty else tran-fuel.volume.
      empty temp-table tt-pay.
      v-chk-type-desc = entry(lookup(string(chk-doc.chk-type), "1,6,8,11,12,13,40,69,96,14,15,16,17,36,101,106,108,111,112,113,169,196,114,115,116,117,136,201,206,208,301,306,2,3,4,5,7,43,44"), "Продажа,Возврат,Аннуляция,Инвентаризация,Z-отчет,Закрытие_смены,Открытие_смены,Списание,ВзврСпис,СбросТрнзкц,Перелив,ПеревТрнзкц,ТехПролив,РазблТрнзкц,_Продажа,_Возврат,_Аннуляция,_Инвентаризация,_Z-отчет,_Закрытие_смены,_Списание,_ВзврСпис,_СбросТрнзкц,_Перелив,_ПеревТрнзкц,_ТехПролив,_РазблТрнзкц,>Продажа,>Возврат,>Аннуляция,>>Продажа,>>Возврат,Инкассация,Касс_фонд,Перевод_опл,Расход_кассы,Декл_ден_ящ,Приход_Корр,Расход_Корр").
      for each chk-pay where
               chk-pay.doc-code = chk-gds.doc-code
      no-lock
      break
         by chk-pay.doc-code
         by chk-pay.tot-sum:
         if first-of(chk-pay.doc-code) and last-of(chk-pay.doc-code) then
            leave.
         vSeq = vSeq + 1.
         v-pay-card = if chk-pay.pay-card = "0" then "" else chk-pay.pay-card.
         find first cash-pay where
                    cash-pay.cdpay-code = chk-pay.pay-code
         no-lock no-error.
         if avail cash-pay then
            assign
               v-cash-pay-code = chk-pay.pay-code
               v-cash-pay-name = cash-pay.obj-name
               .
         else
            assign
               v-cash-pay-code = 0
               v-cash-pay-name = ""
               .
         vTotSum = chk-pay.tot-sum - (if last-of(chk-pay.doc-code) then
                                         (chk-doc.tot-doc - chk-gds.sum-base)
                                      else 0).
         create tt-pay.
         assign
            tt-pay.seq           = vSeq
            tt-pay.volume        = round(vVolume * vTotSum / chk-gds.sum-base, 2)
            tt-pay.money         = vTotSum
            tt-pay.cash-pay-code = v-cash-pay-code
            tt-pay.cash-pay-name = v-cash-pay-name
            tt-pay.pay-card      = v-pay-card
            tt-pay.multi-pay     = yes
            .
            if tt-pay.volume = ? then
               tt-pay.volume = 0.0.
      end.
      find first tt-pay no-error.
      if not avail tt-pay then do:
         find first chk-pay where
                    chk-pay.doc-code = chk-gds.doc-code
         no-lock no-error.
         if avail chk-pay then
            assign
               v-pay-card      = if chk-pay.pay-card = "0" then "" else chk-pay.pay-card
               vMoney          = chk-gds.sum-base
               v-cash-pay-code = chk-pay.pay-code
               .
         else
            assign
               v-pay-card       = ""
               vMoney           = tran-fuel.money
               v-cash-pay-code  = (if chk-doc.chk-type = 8 then 0 else tran-fuel.pay-code)
               .
         find first cash-pay where
                    cash-pay.cdpay-code = v-cash-pay-code
         no-lock no-error.
         v-cash-pay-name = if avail cash-pay then cash-pay.obj-name else "".
         create tt-pay.
         assign
            tt-pay.seq           = 1
            tt-pay.volume        = vVolume
            tt-pay.money         = if chk-doc.chk-type = 1 then vVolume * tran-fuel.price else vMoney
            tt-pay.cash-pay-code = v-cash-pay-code
            tt-pay.cash-pay-name = v-cash-pay-name
            tt-pay.pay-card      = v-pay-card
            .
      end.
      find first b-tran-fuel where
                 b-tran-fuel.db-num    = tran-fuel.db-num
             and b-tran-fuel.uuid      = tran-fuel.uuid
             and b-tran-fuel.uuid-cheq = ""
      no-lock no-error.
      if avail b-tran-fuel and b-tran-fuel.date-beg < tran-fuel.date-beg then
         vDateBeg = b-tran-fuel.date-beg.
      else
         vDateBeg = tran-fuel.date-beg.
      assign
         vDateBeg = vDateBeg           + timezone * 60000
         vDateEnd = tran-fuel.date-end + timezone * 60000.
         .
      for each tt-pay:
         create tt-rep.
         assign
            tt-rep.obj-type        = obj-list.obj-type
            tt-rep.obj-code        = obj-list.obj-code
            tt-rep.obj-name        = obj-list.obj-name
            tt-rep.chk-date        = chk-doc.chk-date
            tt-rep.chk-time        = chk-doc.chk-time
            tt-rep.sort-date       = chk-doc.chk-date
            tt-rep.sort-time       = chk-doc.chk-time
            tt-rep.shift-date      = chk-doc.shift-date
            tt-rep.shift-name      = chk-doc.shift-name + "(" + string(chk-doc.shift-num) + ")"
            tt-rep.doc-code        = chk-doc.doc-code
            tt-rep.chk-num         = chk-doc.chk-num
            tt-rep.line-num        = chk-gds.line-num
            tt-rep.doc-num2        = (if num-entries(chk-doc.doc-num2, ":") > 1 then entry(1, chk-doc.doc-num2, ":") else "")
            tt-rep.z-number        = chk-doc.z-number
            tt-rep.tran-num        = tran-fuel.tran-num
            tt-rep.chk-type-desc   = v-chk-type-desc
            tt-rep.cash-num        = tran-fuel.cash-num
            tt-rep.trk-num         = tran-fuel.trk-num + 1
            tt-rep.nozzle-num      = tran-fuel.nozzle-num + 1
            tt-rep.fuel-code       = chk-gds.b-code
            tt-rep.gds-name        = goods.gds-name
            tt-rep.volume          = tt-pay.volume
            tt-rep.price           = tran-fuel.price
            tt-rep.money           = if tt-pay.multi-pay then tt-pay.money else tt-pay.volume * tran-fuel.price
            tt-rep.cash-pay-code   = tt-pay.cash-pay-code
            tt-rep.cash-pay-name   = tt-pay.cash-pay-name
            tt-rep.pay-card        = tt-pay.pay-card
            tt-rep.datetime-beg    = vDateBeg
            tt-rep.date-beg        = date(vDateBeg)
            tt-rep.time-beg        = mtime(vDateBeg) / 1000
            tt-rep.datetime-end    = vDateEnd
            tt-rep.date-end        = date(vDateEnd)
            tt-rep.time-end        = mtime(vDateEnd) / 1000
            tt-rep.time-length     = (vDateEnd - vDateBeg) / 1000
            tt-rep.all-time-length = tt-rep.time-length
            tt-rep.multi-pay       = tt-pay.multi-pay
            tt-rep.resume-tran     = no
            tt-rep.uuid            = tran-fuel.uuid
            tt-rep.uuid-cheq       = tran-fuel.uuid-cheq
            tt-rep.db-num          = tran-fuel.db-num
            .
         if chk-doc.chk-type = 16 and chk-gds.src-qnty <= 0 then do:
            find first b-chk-gds where
                       b-chk-gds.doc-code = chk-gds.doc-code
                   and b-chk-gds.b-code   = chk-gds.b-code
                   and b-chk-gds.line-num > chk-gds.line-num
            no-lock no-error.
            if avail b-chk-gds then
               assign
                  tt-rep.volume     = b-chk-gds.doc-qnty
                  .
         end.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  obj-list.obj-type
  ,input  obj-list.obj-code
  ,output v-db-num
  )  .
         v-psn-code = gbclcode-is-this-db-role ('C':U,
                                                v-db-num,
                                                chk-doc.cashier,
                                                chk-doc.chk-date
                                                ).
         find first clients where
                    clients.obj-type = 'чел':U
                and clients.obj-code = v-psn-code
         no-lock no-error.
         if available clients then
            tt-rep.cashier = clients.obj-name.
      end.
   end.
end.
procedure InitTT:
   define input parameter i-tog-shift       as logical   no-undo.
   define input parameter i-date-start      as date      no-undo.
   define input parameter i-date-end        as date      no-undo.
   define input parameter i-Shift-Start     as integer   no-undo.
   define input parameter i-Shift-End       as integer   no-undo.
   define input parameter iChkTypeCodeList  as character no-undo.
   define input parameter iGdsCodeList      as character no-undo.
   define input parameter iTRKList          as character no-undo.
   define buffer chk-doc      for chk-doc.
   define buffer chk-doc-attr for chk-doc-attr.
   define buffer chk-gds      for chk-gds.
   define buffer goods        for goods.
   define buffer cash-pay     for cash-pay.
   define buffer prod-bc      for prod-bc.
   define buffer b-tran-fuel  for tran-fuel.
   define variable v-gds-code as integer  no-undo.
   define variable vDateBeg   as datetime no-undo.
   define variable vDateEnd   as datetime no-undo.
   define variable vCount     as integer  no-undo.
   if i-tog-shift then do:
      for
          each obj-list,
          each chk-doc where
               chk-doc.obj-type    = obj-list.obj-type
           and chk-doc.obj-code    = obj-list.obj-code
           and
               chk-doc.shift-date >= i-date-start
           and chk-doc.shift-date <= i-date-end
           and can-do(iChkTypeCodeList, string(chk-doc.chk-type))
      no-lock,
         first chk-doc-attr where
               chk-doc-attr.doc-code  = chk-doc.doc-code
           and chk-doc-attr.attr-code = "CheckId"
      no-lock,
         each tran-fuel where
              tran-fuel.uuid-cheq = chk-doc-attr.attr-value
          and can-do(iTRKList, string(tran-fuel.trk-num + 1))
      no-lock:
         v-gds-code = tran-fuel.fuel-code.
         if v-gds-code < 100 then do:
            find first prod-bc where
                       prod-bc.b-str = string(v-gds-code)
            no-lock no-error.
            if avail prod-bc then do:
               find first chk-gds where
                          chk-gds.doc-code = chk-doc.doc-code
                      and chk-gds.b-code   = prod-bc.b-code
               no-lock no-error.
               find first goods where
                          goods.gds-code = prod-bc.b-code
               no-lock no-error.
               if not avail chk-gds or not avail goods
               then
                  next.
               v-gds-code = goods.gds-code.
            end.
            else next.
         end.
         else do:
            find first chk-gds where
                       chk-gds.doc-code = chk-doc.doc-code
                   and chk-gds.b-code   = v-gds-code
            no-lock no-error.
            find first goods where
                       goods.gds-code = v-gds-code
            no-lock no-error.
            if not avail chk-gds or not avail goods
            then
               next.
         end.
         if not can-do(iGdsCodeList, string(v-gds-code)) then next.
         if (chk-doc.shift-date = i-date-start and chk-doc.shift-num < i-Shift-Start) or
            (chk-doc.shift-date = i-date-end   and chk-doc.shift-num > i-Shift-End)
         then
            next.
         run CreateOneRec(buffer obj-list,
                          buffer chk-doc,
                          buffer tran-fuel,
                          buffer chk-gds,
                          buffer goods
                          ).
      end.
   end.
   else do:
     TRAN-FUEL:
     for each tran-fuel where
              tran-fuel.date-beg >= datetime(string(i-date-start) + " 00:00:00") - timezone * 60000
          and tran-fuel.date-beg <= datetime(string(i-date-end + 2) + " 23:59:59") - timezone * 60000
          and can-do(iTRKList, string(tran-fuel.trk-num + 1))
     no-lock:
       release chk-doc-attr.
       if tran-fuel.num-cheq > 0 then do:
for first chk-doc-attr where
          chk-doc-attr.attr-code  = "CheckId"
      and chk-doc-attr.attr-value = tran-fuel.uuid-cheq
no-lock,
    first chk-doc where
          chk-doc.doc-code = chk-doc-attr.doc-code
      and can-do(iChkTypeCodeList, string(chk-doc.chk-type))
no-lock
,
    first obj-list where
          obj-list.obj-type = chk-doc.obj-type
      and obj-list.obj-code = chk-doc.obj-code
no-lock
:
  v-gds-code = tran-fuel.fuel-code.
  if v-gds-code < 100 then do:
    find first prod-bc where
               prod-bc.b-str = string(v-gds-code)
    no-lock no-error.
    if avail prod-bc then do:
       find first chk-gds where
                  chk-gds.doc-code = chk-doc.doc-code
              and chk-gds.b-code   = prod-bc.b-code
       no-lock no-error.
       find first goods where
                  goods.gds-code = prod-bc.b-code
       no-lock no-error.
       if not avail chk-gds or not avail goods
       then
          next TRAN-FUEL.
       v-gds-code = goods.gds-code.
    end.
    else next TRAN-FUEL.
  end.
  else do:
     find first chk-gds where
                chk-gds.doc-code = chk-doc.doc-code
            and chk-gds.b-code   = v-gds-code
     no-lock no-error.
     find first goods where
                goods.gds-code = v-gds-code
     no-lock no-error.
     if not avail chk-gds or not avail goods
     then
        next TRAN-FUEL.
  end.
  if not can-do(iGdsCodeList, string(v-gds-code)) then next TRAN-FUEL.
    run CreateOneRec(buffer obj-list,
                     buffer chk-doc,
                     buffer tran-fuel,
                     buffer chk-gds,
                     buffer goods
                     ).
end.
       end.
       if not available chk-doc-attr then do:
for first obj-list where
          obj-list.obj-type = 'маг':U
      and obj-list.obj-code = tran-fuel.obj-code
no-lock:
  for first b-tran-fuel where
            b-tran-fuel.db-num    =  tran-fuel.db-num
        and b-tran-fuel.uuid      =  tran-fuel.uuid
        and b-tran-fuel.uuid-cheq <> tran-fuel.uuid-cheq
  no-lock,
      first chk-doc-attr where
            chk-doc-attr.attr-code  = "CheckId"
        and chk-doc-attr.attr-value = b-tran-fuel.uuid-cheq
  no-lock,
      first chk-doc where
            chk-doc.doc-code = chk-doc-attr.doc-code
        and chk-doc.chk-type = 17
  no-lock:
     next TRAN-FUEL.
  end.
  v-gds-code = tran-fuel.fuel-code.
  if v-gds-code < 100 then do:
    find first prod-bc where
               prod-bc.b-str = string(v-gds-code)
    no-lock no-error.
    if avail prod-bc then do:
       find first goods where
                  goods.gds-code = prod-bc.b-code
       no-lock no-error.
       if not avail goods then
          next TRAN-FUEL.
       v-gds-code = goods.gds-code.
    end.
  end.
  else do:
     find first goods where
                goods.gds-code = v-gds-code
     no-lock no-error.
     if not avail goods
     then
        next TRAN-FUEL.
  end.
  if not can-do(iGdsCodeList, string(v-gds-code)) then next TRAN-FUEL.
  assign
    vDateBeg = tran-fuel.date-beg + timezone * 60000
    vDateEnd = tran-fuel.date-end + timezone * 60000
  .
  create tt-rep.
  assign
    tt-rep.obj-type        = obj-list.obj-type
    tt-rep.obj-code        = obj-list.obj-code
    tt-rep.obj-name        = obj-list.obj-name
    tt-rep.sort-date       = date(vDateBeg)
    tt-rep.sort-time       = mtime(vDateBeg) / 1000
    tt-rep.chk-num         = tran-fuel.num-cheq
    tt-rep.tran-num        = tran-fuel.tran-num
    tt-rep.cash-num        = tran-fuel.cash-num
    tt-rep.trk-num         = tran-fuel.trk-num + 1
    tt-rep.nozzle-num      = tran-fuel.nozzle-num + 1
    tt-rep.fuel-code       = goods.gds-code
    tt-rep.gds-name        = goods.gds-name
    tt-rep.volume          = tran-fuel.volume
    tt-rep.price           = tran-fuel.price
    tt-rep.money           = tran-fuel.money
    tt-rep.datetime-beg    = vDateBeg
    tt-rep.date-beg        = date(vDateBeg)
    tt-rep.time-beg        = mtime(vDateBeg) / 1000
    tt-rep.datetime-end    = vDateEnd
    tt-rep.date-end        = date(vDateEnd)
    tt-rep.time-end        = mtime(vDateEnd) / 1000
    tt-rep.time-length     = (vDateEnd - vDateBeg) / 1000
    tt-rep.all-time-length = tt-rep.time-length
    tt-rep.multi-pay       = no
    tt-rep.resume-tran     = no
    tt-rep.uuid            = tran-fuel.uuid
    tt-rep.uuid-cheq       = tran-fuel.uuid-cheq
    tt-rep.db-num          = tran-fuel.db-num
  .
  if tt-rep.uuid-cheq = "" then do:
     vCount = vCount + 1.
     tt-rep.uuid-cheq = "empty-" + string(vCount, "99999999").
  end.
end.
       end.
     end.
   end.
   release tt-rep.
end.
procedure AfterCalc:
   define input parameter i-tog-shift  as logical   no-undo.
   define input parameter i-date-end   as date      no-undo.
   define input parameter iTRKList     as character no-undo.
   define input parameter iCashPayList as character no-undo.
   define input parameter iTranTimeMax as integer   no-undo.
   define buffer b-chk-gds    for chk-gds.
   define buffer b-tt-rep     for tt-rep.
   define buffer b2-tt-rep    for tt-rep.
   define variable vI                   as integer   no-undo.
   define variable vCheck               as logical   no-undo.
   define variable vCheckResumeTran     as logical   no-undo.
   define variable v-all-time-length    as integer   no-undo.
   define variable v-count-grp-num      as integer   no-undo.
   define variable v-prev-datetime-end  as datetime  no-undo.
   define variable v-first-datetime-beg as datetime  no-undo.
   define variable vResumeTran          as logical   no-undo.
   define variable vUuidCheq            as character no-undo.
   define variable vFirstRecId          as recid     no-undo.
   define variable vConfirmResumeTran   as logical   no-undo.
   define variable vRecId               as recid     no-undo.
   define variable vRowId               as rowid     no-undo.
   define variable vRowIdList           as character no-undo.
   define variable v-gds-code           as integer   no-undo.
   define variable vTrkNum              as integer   no-undo.
   for each  tt-grp:
      delete tt-grp.
   end.
   for each  tt-grp-uuid:
      delete tt-grp-uuid.
   end.
   for each  tt-grp-cheq-uuid:
      delete tt-grp-cheq-uuid.
   end.
   for each tt-rep where
            not can-do(iTRKList, string(tt-rep.trk-num)):
      delete tt-rep.
   end.
   for each tt-rep where
            tt-rep.cash-pay-name = "":
      find first tran-fuel where
                 tran-fuel.db-num   = tt-rep.db-num
             and tran-fuel.tran-num = tt-rep.tran-num
             and tran-fuel.num-cheq = integer(tt-rep.doc-num2)
      no-lock no-error.
      if avail tran-fuel then do:
         for first chk-doc-attr where
                   chk-doc-attr.attr-code  = "CheckId"
               and chk-doc-attr.attr-value = tran-fuel.uuid-cheq
         no-lock,
             first chk-doc where
                   chk-doc.doc-code = chk-doc-attr.doc-code
         no-lock
               ,
             first obj-list where
                   obj-list.obj-type = chk-doc.obj-type
               and obj-list.obj-code = chk-doc.obj-code
         no-lock
               :
            v-gds-code = tran-fuel.fuel-code.
            if v-gds-code < 100 then do:
               find first prod-bc where
                          prod-bc.b-str = string(tran-fuel.fuel-code)
               no-lock no-error.
               if avail prod-bc then do:
                  find first chk-gds where
                             chk-gds.doc-code = chk-doc.doc-code
                         and chk-gds.b-code   = prod-bc.b-code
                  no-lock no-error.
                  find first goods where
                             goods.gds-code = prod-bc.b-code
                  no-lock no-error.
                  if not avail chk-gds or not avail goods
                  then
                     next.
                  v-gds-code = goods.gds-code.
               end.
            end.
            else do:
               find first chk-gds where
                          chk-gds.doc-code = chk-doc.doc-code
                      and chk-gds.b-code   = v-gds-code
               no-lock no-error.
               find first goods where
                          goods.gds-code = v-gds-code
               no-lock no-error.
               if not avail chk-gds or not avail goods
               then
                  next.
            end.
            find first chk-pay where
                       chk-pay.doc-code = chk-gds.doc-code
            no-lock no-error.
            if avail chk-pay then do:
               find first cash-pay where
                          cash-pay.cdpay-code = chk-pay.pay-code
               no-lock no-error.
               if avail cash-pay then
                  assign
                     tt-rep.cash-pay-code = chk-pay.pay-code
                     tt-rep.cash-pay-name = cash-pay.obj-name.
            end.
         end.
      end.
   end.
   v-count-grp-num = 0.
   for each tt-rep
      by tt-rep.obj-code
      by tt-rep.sort-date
      by tt-rep.sort-time:
      block-grp-uuid:
      for each tt-grp-uuid where  tt-grp-uuid.uuid     = tt-rep.uuid
      no-lock:
         for each tt-grp where
                    tt-grp.obj-type = tt-rep.obj-type
                and tt-grp.obj-code = tt-rep.obj-code
                and tt-grp.obj-name = tt-rep.obj-name
                and tt-grp.grp-num  = tt-grp-uuid.grp-num
                :
                find first tt-grp-cheq-uuid where tt-grp-cheq-uuid.grp-num = tt-grp.grp-num
                                              and tt-grp-cheq-uuid.uuid     = tt-rep.uuid-cheq
                no-error.
                leave block-grp-uuid.
             end.
      end.
      if not available tt-grp
      then do:
         block-grp-cheq:
         for each tt-grp-cheq-uuid where  tt-grp-cheq-uuid.uuid     = tt-rep.uuid-cheq
         no-lock:
            for each tt-grp where
                       tt-grp.obj-type = tt-rep.obj-type
                   and tt-grp.obj-code = tt-rep.obj-code
                   and tt-grp.obj-name = tt-rep.obj-name
                   and tt-grp.grp-num  = tt-grp-cheq-uuid.grp-num
                   :
                   find first tt-grp-uuid where tt-grp-uuid.grp-num = tt-grp.grp-num
                                            and tt-grp-uuid.uuid     = tt-rep.uuid
                   no-error.
                   leave block-grp-cheq.
            end.
         end.
      end.
      if     not avail tt-grp
      then do:
         v-count-grp-num = v-count-grp-num + 1.
         create tt-grp.
         assign
            tt-grp.obj-type = tt-rep.obj-type
            tt-grp.obj-code = tt-rep.obj-code
            tt-grp.obj-name = tt-rep.obj-name
            tt-grp.grp-num  = v-count-grp-num
            .
      end.
      if not available tt-grp-cheq-uuid
      then do:
         create tt-grp-cheq-uuid.
         assign
            tt-grp-cheq-uuid.grp-num  = tt-grp.grp-num
            tt-grp-cheq-uuid.uuid     = tt-rep.uuid-cheq
         .
      end.
      if not available tt-grp-uuid
      then do:
         create tt-grp-uuid.
         assign
            tt-grp-uuid.grp-num = tt-grp.grp-num
            tt-grp-uuid.uuid     = tt-rep.uuid
         .
      end.
      tt-rep.grp-num = tt-grp.grp-num.
      if tt-grp.cash-pay-name = "" then
         assign
            tt-grp.cash-pay-code = tt-rep.cash-pay-code
            tt-grp.cash-pay-name = tt-rep.cash-pay-name
            .
      release tt-grp.
   end.
   for each tt-rep
   break
      by tt-rep.obj-code
      by tt-rep.grp-num
      by tt-rep.sort-date
      by tt-rep.sort-time
      by tt-rep.datetime-beg:
      if first-of(tt-rep.grp-num) then do:
         assign
            vUuidCheq          = ""
            vResumeTran        = no
            vConfirmResumeTran = no
            .
         if tt-rep.chk-type-desc = "Продажа" then
            assign
               vUuidCheq   = tt-rep.uuid-cheq
               vResumeTran = yes
               vTrkNum     = tt-rep.trk-num
               .
         find first b-tt-rep where recid(b-tt-rep) = vFirstRecId no-error.
      end.
      else do:
         if tt-rep.chk-type-desc = "Продажа" and
            tt-rep.uuid-cheq     = vUuidCheq and
            tt-rep.multi-pay     = no        and
            vResumeTran          = yes
         then
            assign
               tt-rep.resume-tran = yes
               vConfirmResumeTran = yes
               .
         else
            if tt-rep.chk-type-desc = "Продажа" and
               tt-rep.uuid-cheq     = vUuidCheq and
               tt-rep.multi-pay     = no
            then
               assign
                  vResumeTran = yes
                  vTrkNum     = tt-rep.trk-num
               .
            else
               vResumeTran = no.
         for first b-tt-rep where
                   b-tt-rep.db-num   = tt-rep.db-num
               and b-tt-rep.uuid     = tt-rep.uuid
               and b-tt-rep.chk-num = 0:
           assign
             tt-rep.resume-tran = yes
             vConfirmResumeTran = yes
           .
           for first tt-grp-uuid where
                     tt-grp-uuid.uuid = b-tt-rep.uuid:
              delete tt-grp-uuid.
           end.
           delete b-tt-rep.
         end.
      end.
      if last-of(tt-rep.grp-num) and not first-of(tt-rep.grp-num) and vConfirmResumeTran then do:
         for first tt-grp where tt-grp.grp-num = tt-rep.grp-num:
            tt-grp.resume-tran = yes.
         end.
      end.
   end.
   for each tt-grp where
            tt-grp.resume-tran = yes:
      for each tt-rep where
               tt-rep.grp-num = tt-grp.grp-num
      break
         by tt-rep.obj-code
         by tt-rep.grp-num
         by tt-rep.datetime-beg
         by tt-rep.sort-date
         by tt-rep.sort-time:
         if not first-of(tt-rep.grp-num) and tt-rep.chk-type-desc = "Продажа" then do:
            find first b-tt-rep where
                       recid(b-tt-rep)        = vRecId
                   and b-tt-rep.chk-type-desc = "Продажа"
            no-error.
            if avail b-tt-rep then do:
               assign
                  b-tt-rep.datetime-end    = tt-rep.datetime-beg
                  b-tt-rep.date-end        = tt-rep.date-beg
                  b-tt-rep.time-end        = tt-rep.time-beg
                  b-tt-rep.time-length     = (b-tt-rep.datetime-end - b-tt-rep.datetime-beg) / 1000
                  .
            end.
         end.
         vRecId = recid(tt-rep).
      end.
   end.
   repeat preselect each tt-rep where
                         tt-rep.chk-type-desc = "ПеревТрнзкц":
      find next tt-rep.
      find first b-chk-gds where
                 b-chk-gds.doc-code =  tt-rep.doc-code
             and b-chk-gds.line-num <> chk-gds.line-num
      no-lock no-error.
      if avail b-chk-gds then do:
         find first b-tt-rep where
                    b-tt-rep.db-num    =  tt-rep.db-num
                and b-tt-rep.uuid      =  tt-rep.uuid
                and b-tt-rep.uuid-cheq <> tt-rep.uuid-cheq
         no-error.
         if avail b-tt-rep then do:
            find first b2-tt-rep where
                       b2-tt-rep.db-num    =  B-tt-rep.db-num
                   and b2-tt-rep.uuid-cheq =  b-tt-rep.uuid-cheq
                   and b2-tt-rep.uuid      <> b-tt-rep.uuid
            no-lock no-error.
            if avail b2-tt-rep then do:
               create b-tt-rep.
               buffer-copy b2-tt-rep to b-tt-rep
                  assign
                     b-tt-rep.chk-date        = tt-rep.chk-date
                     b-tt-rep.chk-time        = tt-rep.chk-time
                     b-tt-rep.sort-date       = tt-rep.sort-date
                     b-tt-rep.sort-time       = tt-rep.sort-time
                     b-tt-rep.doc-code        = tt-rep.doc-code
                     b-tt-rep.chk-num         = tt-rep.chk-num
                     b-tt-rep.line-num        = b-chk-gds.line-num
                     b-tt-rep.doc-num2        = tt-rep.doc-num2
                     b-tt-rep.z-number        = tt-rep.z-number
                     b-tt-rep.chk-type-desc   = tt-rep.chk-type-desc
                     b-tt-rep.resume-tran     = no
                     b-tt-rep.uuid-cheq       = tt-rep.uuid-cheq
                     .
            end.
         end.
      end.
   end.
   for each tt-grp:
      for each tt-rep where
               tt-rep.grp-num = tt-grp.grp-num
      break
         by tt-rep.obj-code
         by tt-rep.grp-num
         by tt-rep.datetime-beg
         by tt-rep.sort-date
         by tt-rep.sort-time:
         if not first-of(tt-rep.grp-num) and tt-rep.chk-type-desc = "ПеревТрнзкц" then do:
            find first b-tt-rep where
                       recid(b-tt-rep)        = vRecId
                   and b-tt-rep.chk-type-desc = "Продажа"
            no-error.
            if avail b-tt-rep then do:
               assign
                  b-tt-rep.datetime-end    = tt-rep.datetime-end
                  b-tt-rep.date-end        = tt-rep.date-end
                  b-tt-rep.time-end        = tt-rep.time-end
                  b-tt-rep.time-length     = (b-tt-rep.datetime-end - b-tt-rep.datetime-beg) / 1000
                  .
            end.
         end.
         vRecId = recid(tt-rep).
      end.
   end.
   for each tt-rep where
            tt-rep.chk-type-desc = "Возврат":
      find last b-tt-rep where
                b-tt-rep.DB-NUM        = tt-rep.db-num
            and b-tt-rep.uuid          = tt-rep.uuid
            and b-tt-rep.chk-type-desc = "Продажа"
      no-error.
      if avail b-tt-rep then do:
         assign
            tt-rep.datetime-beg = b-tt-rep.datetime-beg
            tt-rep.date-beg     = b-tt-rep.date-beg
            tt-rep.time-beg     = b-tt-rep.time-beg
            tt-rep.time-length  = (tt-rep.datetime-end - tt-rep.datetime-beg) / 1000
            .
      end.
   end.
   for each tt-rep where
            tt-rep.chk-type-desc = "СбросТрнзкц":
      find last b-tt-rep where
                b-tt-rep.DB-NUM        = tt-rep.db-num
            and b-tt-rep.uuid          = tt-rep.uuid
            and b-tt-rep.chk-type-desc = "Продажа"
      no-error.
      if avail b-tt-rep then do:
         assign
            tt-rep.datetime-beg = b-tt-rep.datetime-beg
            tt-rep.date-beg     = b-tt-rep.date-beg
            tt-rep.time-beg     = b-tt-rep.time-beg
            tt-rep.time-length  = (tt-rep.datetime-end - tt-rep.datetime-beg) / 1000
            .
      end.
   end.
   for each tt-rep where
            tt-rep.chk-type-desc = "ПеревТрнзкц":
      find first b-tt-rep where
                 b-tt-rep.DB-NUM        = tt-rep.db-num
             and b-tt-rep.uuid          = tt-rep.uuid
             and b-tt-rep.chk-type-desc = "Продажа"
      no-error.
      if avail b-tt-rep then do:
         assign
            tt-rep.datetime-beg = b-tt-rep.datetime-beg
            tt-rep.date-beg     = b-tt-rep.date-beg
            tt-rep.time-beg     = b-tt-rep.time-beg
            tt-rep.time-length  = (tt-rep.datetime-end - tt-rep.datetime-beg) / 1000
            .
      end.
   end.
   for each tt-rep where
            tt-rep.chk-type-desc = "ТехПролив":
      find first tran-fuel where
                 tran-fuel.db-num    =  tt-rep.db-num
             and tran-fuel.uuid      =  tt-rep.uuid
             and tran-fuel.uuid-cheq <> tt-rep.uuid-cheq
      no-lock no-error.
      if avail tran-fuel then do:
         assign
            tt-rep.datetime-beg = tran-fuel.date-beg + timezone * 60000
            tt-rep.date-beg     = date(tt-rep.datetime-beg)
            tt-rep.time-beg     = mtime(tt-rep.datetime-beg) / 1000
            tt-rep.time-length  = (tt-rep.datetime-end - tt-rep.datetime-beg) / 1000
            .
      end.
   end.
   for each tt-rep
   break
      by tt-rep.obj-code
      by tt-rep.grp-num
      by tt-rep.datetime-beg
      by tt-rep.sort-date
      by tt-rep.sort-time:
      if first-of(tt-rep.grp-num) then do:
         vRowId = ?.
      end.
      if can-do("Возврат,СбросТрнзкц", tt-rep.chk-type-desc) and vRowId <> ? then do:
         for first b-tt-rep where rowid(b-tt-rep) = vRowId:
            assign
               b-tt-rep.datetime-end    = tt-rep.datetime-end
               b-tt-rep.date-end        = tt-rep.date-end
               b-tt-rep.time-end        = tt-rep.time-end
               b-tt-rep.time-length     = (b-tt-rep.datetime-end - b-tt-rep.datetime-beg) / 1000
               .
         end.
      end.
      vRowId = rowid(tt-rep).
   end.
   for each tt-rep
   break
      by tt-rep.obj-code
      by tt-rep.grp-num
      by tt-rep.datetime-beg
      by tt-rep.sort-date
      by tt-rep.sort-time:
      if first-of(tt-rep.grp-num) then do:
         vRowIdList = "".
      end.
      if tt-rep.chk-type-desc = "Аннуляция" then
         vRowIdList = vRowIdList + (if vRowIdList > "" then "," else "") + string(rowid(tt-rep)).
      else if tt-rep.chk-type-desc = "Продажа" then do:
         do vI = 1 to num-entries(vRowIdList):
            vRowId = to-rowid(entry(vI, vRowIdList)).
            for first b-tt-rep where rowid(b-tt-rep) = vRowId:
               assign
                  b-tt-rep.datetime-end    = tt-rep.datetime-end
                  b-tt-rep.date-end        = tt-rep.date-end
                  b-tt-rep.time-end        = tt-rep.time-end
                  b-tt-rep.time-length     = (b-tt-rep.datetime-end - b-tt-rep.datetime-beg) / 1000
                  .
            end.
         end.
         vRowIdList = "".
      end.
   end.
   for each tt-rep
   break
      by tt-rep.obj-code
      by tt-rep.grp-num
      by tt-rep.sort-date
      by tt-rep.sort-time
      by tt-rep.datetime-beg:
      if first-of(tt-rep.grp-num) then do:
         vI = 0.
         find first b-tt-rep where
                    rowid(b-tt-rep) = rowid(tt-rep).
      end.
      vI = vI + 1.
      if last-of(tt-rep.grp-num) and vI = 2 then do:
         if b-tt-rep.chk-type-desc  = "Продажа"           and
            b-tt-rep.uuid           = tt-rep.uuid         and
            tt-rep.uuid-cheq        begins "empty-"       and
            b-tt-rep.trk-num        = tt-rep.trk-num      and
            b-tt-rep.nozzle-num     = tt-rep.nozzle-num   and
            b-tt-rep.fuel-code      = tt-rep.fuel-code    and
            b-tt-rep.volume         = tt-rep.volume       and
            b-tt-rep.datetime-beg  <= tt-rep.datetime-beg
         then
            tt-rep.chk-type-desc = "Перелив".
      end.
   end.
   for each tt-rep where
            not can-do(iCashPayList, string(tt-rep.cash-pay-code)):
      delete tt-rep.
   end.
   if i-tog-shift = no then do:
      for each tt-rep where
               tt-rep.datetime-beg > datetime(string(i-date-end) + " 23:59:59"):
         delete tt-rep.
      end.
   end.
   for each tt-rep
   break
      by tt-rep.obj-code
      by tt-rep.grp-num
      by tt-rep.datetime-beg
      by tt-rep.sort-date
      by tt-rep.sort-time:
      if first-of(tt-rep.grp-num) then do:
         assign
            v-all-time-length    = 0
            v-prev-datetime-end  = datetime("01/01/1990 00:00:00")
            v-first-datetime-beg = tt-rep.datetime-beg
            .
      end.
      if tt-rep.datetime-end > v-prev-datetime-end then
         v-all-time-length = v-all-time-length + (tt-rep.datetime-end - max(tt-rep.datetime-beg, v-prev-datetime-end)) / 1000.
      v-prev-datetime-end = max(tt-rep.datetime-end, v-prev-datetime-end).
      if last-of(tt-rep.grp-num) then do:
         find first tt-grp where
                    tt-grp.grp-num = tt-rep.grp-num
         no-error.
         if avail tt-grp then
            assign
               tt-grp.all-time-length   = v-all-time-length
               tt-grp.all-time-length-2 = (tt-rep.datetime-end - v-first-datetime-beg) / 1000
               .
      end.
   end.
   for each tt-rep:
      find first tt-grp where
                 tt-grp.grp-num = tt-rep.grp-num
      no-error.
      if avail tt-grp then do:
         assign
            tt-rep.all-time-length   = tt-grp.all-time-length
            tt-rep.all-time-length-2 = tt-grp.all-time-length-2
            .
      end.
   end.
   for each tt-rep where
            tt-rep.all-time-length-2 < iTranTimeMax * 60:
      delete tt-rep.
   end.
   for each tt-grp-uuid:
      delete tt-grp-uuid.
   end.
   for each tt-rep
   break
      by tt-rep.obj-type
      by tt-rep.obj-code
      by tt-rep.sort-date
      by tt-rep.sort-time
      by tt-rep.uuid-cheq
      by tt-rep.datetime-beg:
      if first-of(tt-rep.obj-code) then do:
         create tt-total-rep.
         assign
            tt-total-rep.obj-type = tt-rep.obj-type
            tt-total-rep.obj-code = tt-rep.obj-code
            tt-total-rep.obj-name = tt-rep.obj-name
            .
      end.
      if first-of(tt-rep.uuid-cheq) then do:
         vCheck = no.
         tt-total-rep.qty-chk = tt-total-rep.qty-chk + 1.
      end.
      find first tt-grp-uuid where tt-grp-uuid.grp-num = 0
                               and tt-grp-uuid.uuid     = tt-rep.uuid
      no-error.
      if not available tt-grp-uuid
      then do:
         vCheck = yes.
         create tt-grp-uuid.
         assign
            tt-grp-uuid.grp-num = 0
            tt-grp-uuid.uuid     = tt-rep.uuid
         .
      end.
      if last-of(tt-rep.uuid-cheq) then do:
         if vCheck then
            tt-total-rep.qty-chk-fuel = tt-total-rep.qty-chk-fuel + 1.
      end.
   end.
   release tt-total-rep.
   for each tt-rep,
      first tt-total-rep where
            tt-total-rep.obj-type = tt-rep.obj-type
        and tt-total-rep.obj-code = tt-rep.obj-code
        and tt-total-rep.obj-name = tt-rep.obj-name
   break
      by tt-rep.obj-type
      by tt-rep.obj-code
      by tt-rep.obj-name
      by tt-rep.tran-num:
      if first-of(tt-rep.tran-num) then do:
         tt-total-rep.qty-tran       = tt-total-rep.qty-tran + 1.
         tt-total-rep.full-time-tran = tt-total-rep.full-time-tran + tt-rep.time-length.
      end.
   end.
   for each tt-total-rep:
      tt-total-rep.avg-time-tran      = tt-total-rep.full-time-tran / tt-total-rep.qty-tran.
      tt-total-rep.avg-time-tran-fuel = tt-total-rep.full-time-tran / tt-total-rep.qty-chk-fuel.
   end.
   for each tt-grp-uuid:
      delete tt-grp-uuid.
   end.
   for each tt-rep
   break
      by tt-rep.obj-type
      by tt-rep.obj-code
      by tt-rep.sort-date
      by tt-rep.sort-time
      by tt-rep.uuid-cheq
      by tt-rep.datetime-beg:
      if first-of(tt-rep.obj-code) then do:
         create tt-all-total-rep.
         assign
            tt-all-total-rep.obj-type = tt-rep.obj-type
            tt-all-total-rep.obj-code = tt-rep.obj-code
            .
      end.
      if first-of(tt-rep.uuid-cheq) then do:
         vCheck = no.
         tt-all-total-rep.qty-chk = tt-all-total-rep.qty-chk + 1.
      end.
      find first tt-grp-uuid where tt-grp-uuid.grp-num = 0
                               and tt-grp-uuid.uuid     = tt-rep.uuid
      no-error.
      if not available tt-grp-uuid
      then do:
         vCheck = yes.
         create tt-grp-uuid.
         assign
            tt-grp-uuid.grp-num = 0
            tt-grp-uuid.uuid     = tt-rep.uuid
         .
      end.
      if last-of(tt-rep.uuid-cheq) then do:
         if vCheck then
            tt-all-total-rep.qty-chk-fuel = tt-all-total-rep.qty-chk-fuel + 1.
      end.
   end.
   release tt-all-total-rep.
   for each tt-rep,
      first tt-all-total-rep where
            tt-all-total-rep.obj-type = tt-rep.obj-type
        and tt-all-total-rep.obj-code = tt-rep.obj-code
   break
      by tt-rep.obj-type
      by tt-rep.obj-code
      by tt-rep.tran-num:
      if first-of(tt-rep.tran-num) then do:
         tt-all-total-rep.qty-tran       = tt-all-total-rep.qty-tran + 1.
         tt-all-total-rep.full-time-tran = tt-all-total-rep.full-time-tran + tt-rep.time-length.
      end.
   end.
   for each tt-all-total-rep:
      tt-all-total-rep.avg-time-tran      = tt-all-total-rep.full-time-tran / tt-all-total-rep.qty-tran.
      tt-all-total-rep.avg-time-tran-fuel = tt-all-total-rep.full-time-tran / tt-all-total-rep.qty-chk-fuel.
   end.
end.
define stream sOutStr-html.
function f_disp_time returns character
   (input iTime as integer):
   define variable vHour    as integer   no-undo.
   define variable vMinute  as integer   no-undo.
   define variable vSec     as integer   no-undo.
   define variable vTimeStr as character no-undo.
   if iTime < 0 then return "".
   vHour = truncate(iTime / 3600, 0).
   vMinute = truncate((iTime - vHour * 3600) / 60, 0).
   vSec = iTime - vHour * 3600 - vMinute * 60.
   vTimeStr = trim(string(vHour, ">>>99")) + ":" +
              string(vMinute, "99")  + ":" +
              string(vSec,    "99").
   return vTimeStr.
end function.
function fDate2Str returns character
   (input idate as date,
    input iformat as char):
   define variable vdatestr as character no-undo.
   if idate = ? then
      vdatestr = "".
   else
      vdatestr = trim(string(idate, iformat)).
   return vdatestr.
end function.
function fDec2Str returns character
   (input idec as decimal,
    input iformat as char):
   define variable vdecstr as character no-undo.
   if idec = ? then
      vdecstr = "".
   else
      vdecstr = trim(string(idec, iformat)).
   return vdecstr.
end function.
function fInt2Str returns character
   (input iInt as integer,
    input iformat as char):
   define variable vIntStr as character no-undo.
   if iInt = ? then
      vIntStr = "".
   else
      vIntStr = trim(string(iInt, iformat)).
   return vIntStr.
end function.
function fStrNvl returns character
   (input iStr     as character,
    input iDefault as character):
   return if iStr > "" then iStr else iDefault.
end function.
run BeforeCalc.
run initTT(x-tog-shift,
           X-date-start,
           X-date-end,
           X-Shift-Start,
           X-Shift-End,
           iChkTypeCodeList,
           iGdsCodeList,
           iTRKList).
run AfterCalc(x-tog-shift,
              X-date-end,
              iTRKList,
              iCashPayList,
              iTranTimeMax).
run PrintTT.
procedure BeforeCalc:
   define variable vI       as integer   no-undo.
   define variable vJ       as integer   no-undo.
   define variable vStr     as character no-undo.
   define variable vChkCode as character no-undo.
   if x-tog-shift then do:
      vI = vI + 1.
      if X-shift-start = X-shift-end then
         mParamStr[vI] = "Смена: " + string(X-shift-start).
      else
         mParamStr[vI] = "Смены: c " + string(X-shift-start) + " по " + string(X-shift-end).
   end.
   vI = vI + 1.
   if X-date-start = X-date-end then
      mParamStr[vI] = "За дату : " + string(X-date-start, "99.99.9999").
   else
      mParamStr[vI] = "За период c " + string(X-date-start, "99.99.9999") + " по " + string(X-date-end, "99.99.9999").
   vI = vI + 1.
   mParamStr[vI] = "Выбор объекта: ".
   for each obj-list:
      mParamStr[vI] = mParamStr[vI] + obj-list.obj-name + "," .
   end.
   mParamStr[vI] = trim(mParamStr[vI], ",").
   vI = vI + 1.
   if iGdsCodeList = "*" then do:
      mParamStr[vI] = "Вся номенклатура".
      mProdBcStrList = "*".
   end.
   else do:
      mParamStr[vI] = "Номенклатура: ".
      vStr = "".
      for each goods where
               can-do(iGdsCodeList, string(goods.gds-code))
      no-lock:
         vStr = vStr + "," + string(goods.gds-code) + "(" + goods.gds-name + ")".
         for each prod-bc where
                  prod-bc.b-code = goods.gds-code
         no-lock:
            mProdBcStrList = mProdBcStrList + "," + prod-bc.b-str.
         end.
      end.
      vStr = trim(vStr, ",").
      mProdBcStrList = trim(mProdBcStrList, ",").
      mParamStr[vI] = mParamStr[vI] + vStr.
   end.
   vI = vI + 1.
   if iTRKList = "*" then
      mParamStr[vI] = "Все ТРК".
   else
      mParamStr[vI] = "ТРК: " + iTRKList.
   mParamStr[vI] = mParamStr[vI] + ", все пистолеты".
   vI = vI + 1.
   if iCashPayList = "*" then
      mParamStr[vI] = "Все типы оплаты".
   else do:
      mParamStr[vI] = "Типы оплаты: ".
      vStr = "".
      for each cash-pay where
               can-do(iCashPayList, string(cash-pay.cdpay-code))
      no-lock:
         vStr = vStr + "," + cash-pay.obj-name.
      end.
      vStr = trim(vStr, ",").
      mParamStr[vI] = mParamStr[vI] + vStr.
   end.
   vI = vI + 1.
   if iChkTypeCodeList = "*" then
      mParamStr[vI] = "Все типы чеков".
   else do:
      mParamStr[vI] = "Типы чеков: ".
      vStr = "".
      do vJ = 1 to num-entries("1,6,8,11,12,13,40,69,96,14,15,16,17,36,101,106,108,111,112,113,169,196,114,115,116,117,136,201,206,208,301,306,2,3,4,5,7,43,44"):
         vChkCode = entry(vJ, "1,6,8,11,12,13,40,69,96,14,15,16,17,36,101,106,108,111,112,113,169,196,114,115,116,117,136,201,206,208,301,306,2,3,4,5,7,43,44").
         if can-do(iChkTypeCodeList, vChkCode) then
            vStr = vStr + "," + entry(vJ, "Продажа,Возврат,Аннуляция,Инвентаризация,Z-отчет,Закрытие_смены,Открытие_смены,Списание,ВзврСпис,СбросТрнзкц,Перелив,ПеревТрнзкц,ТехПролив,РазблТрнзкц,_Продажа,_Возврат,_Аннуляция,_Инвентаризация,_Z-отчет,_Закрытие_смены,_Списание,_ВзврСпис,_СбросТрнзкц,_Перелив,_ПеревТрнзкц,_ТехПролив,_РазблТрнзкц,>Продажа,>Возврат,>Аннуляция,>>Продажа,>>Возврат,Инкассация,Касс_фонд,Перевод_опл,Расход_кассы,Декл_ден_ящ,Приход_Корр,Расход_Корр").
      end.
      vStr = trim(vStr, ",").
      mParamStr[vI] = mParamStr[vI] + vStr.
   end.
   if iTranTimeMax > 0 then do:
      vI = vI + 1.
      mParamStr[vI] = "Только с жизненным циклом заказа НП более " + string(iTranTimeMax) + " минут".
   end.
   vI = vI + 1.
   if not iGrpChk and not iGrpTran then
      mParamStr[vI] = "Без группировки".
   else do:
      mParamStr[vI] = "С группировкой по ".
      if iGrpChk then
         mParamStr[vI] = mParamStr[vI] + "чекам".
      if iGrpTran then
         mParamStr[vI] = mParamStr[vI] +
                        (if iGrpChk then " и " else "") +
                         "транзакциям".
   end.
end procedure.
procedure PrintTT:
   define variable vReportId     as character no-undo.
   define variable vFileNameRep  as character no-undo.
   define variable vLevel        as character no-undo.
   define variable vPrevUuidCheq as character no-undo.
   define variable vPrevUuid     as character no-undo.
   define variable vStr          as character no-undo.
   define variable vI            as integer   no-undo.
   do on error undo, return error return-value:
      run get-report-num(output vReportId).
      vFileNameRep = session:temp-directory + string(vReportId) + ".html".
      output stream sOutStr-html to value(vFileNameRep) convert target 'UTF-8'.
      put stream sOutStr-html unformatted
         "<!DOCTYPE HTML>" skip
            ' <html>' skip
            '  <head>' skip
            '   <meta charset="utf-8">' skip
            '    <style type="text/css">' skip
            '      table ' + chr(123) + ' border-collapse: collapse; ' + chr(125) skip
            '      .class1 ' + chr(123) + ' border-collapse: collapse; ' + chr(125) skip
            '      tbody td, th ' + chr(123) + ' border-collapse: collapse; border: 1px solid black; height: 14px;' + chr(125) skip
            '   </style>' skip
            '  </head>' skip
         .
      put stream sOutStr-html unformatted
           '<body>' skip
           '<TABLE name="1" outline_below="true" fit_to_page="true" orientation="landscape" CELLSPACING="0" BORDER="0">' skip
           '<thead>' skip
           '<TR class="set_columns">' skip
               '<TD style="width:  68px;"></TD>' skip
               '<TD style="width: 111px;"></TD>' skip
               '<TD style="width:  84px;"></TD>' skip
               '<TD style="width:  78px;"></TD>' skip
               '<TD style="width:  88px;"></TD>' skip
               '<TD style="width:  80px;"></TD>' skip
               '<TD style="width:  95px;"></TD>' skip
               '<TD style="width:  84px;"></TD>' skip
               '<TD style="width: 148px;"></TD>' skip
               '<TD style="width:  64px;"></TD>' skip
               '<TD style="width: 150px;"></TD>' skip
               '<TD style="width:  65px;"></TD>' skip
               '<TD style="width: 108px;"></TD>' skip
               '<TD style="width:  72px;"></TD>' skip
               '<TD style="width: 113px;"></TD>' skip
               '<TD style="width:  79px;"></TD>' skip
               '<TD style="width:  82px;"></TD>' skip
               '<TD style="width:  97px;"></TD>' skip
               '<TD style="width: 150px;"></TD>' skip
               '<TD style="width: 157px;"></TD>' skip
               '<TD style="width:  88px;"></TD>' skip
               '<TD style="width:  81px;"></TD>' skip
               '<TD style="width:  85px;"></TD>' skip
               '<TD style="width: 100px;"></TD>' skip
               '<TD style="width:  91px;"></TD>' skip
               '<TD style="width:  91px;"></TD>' skip
               '<TD style="width: 103px;"></TD>' skip
           '</TR>' skip
           '<TR>' skip
               '<TD colspan="12" STYLE="font-size: 14px;">' + 'Отчет по продолжительности топливных транзакций' + '</TD>'skip
           '</TR>' skip
           .
      do vI = 1 to extent(mParamStr):
         if mParamStr[vI] = "" then leave.
         put stream sOutStr-html unformatted
              '<TR>' skip
                  '<TD colspan="12" STYLE="font-size: 14px;">' + mParamStr[vI] + '</TD>' skip
              '</TR>' skip
            .
      end.
      put stream sOutStr-html unformatted
           '<TR>' skip
               '<TD colspan="12" STYLE="font-size: 14px;">Дата печати: ' + string(today, "99.99.9999") + ' ' + string(time, "HH:MM") + '</TD>' skip
           '</TR>' skip
           '</thead>' skip
         .
      put stream sOutStr-html unformatted
         '<tbody>'
         '<TR >'skip
            '<TH style="text-align: center; font-weight:bold; ">Название АЗС/АЗК</TH>'                 skip
            '<TH style="text-align: center; font-weight:bold; ">Дата чека</TH>'                        skip
            '<TH style="text-align: center; font-weight:bold; ">Время чека</TH>'                       skip
            '<TH style="text-align: center; font-weight:bold; ">Дата смены</TH>'                       skip
            '<TH style="text-align: center; font-weight:bold; ">Номер смены</TH>'                      skip
            '<TH style="text-align: center; font-weight:bold; ">Номер чека</TH>'                       skip
            '<TH style="text-align: center; font-weight:bold; ">Номер Z-отчета</TH>'                   skip
            '<TH style="text-align: center; font-weight:bold; ">Номер топливной транзакции</TH>'       skip
            '<TH style="text-align: center; font-weight:bold; ">Тип чека</TH>'                         skip
            '<TH style="text-align: center; font-weight:bold; ">Номер кассы</TH>'                      skip
            '<TH style="text-align: center; font-weight:bold; ">ФИО кассира</TH>'                      skip
            '<TH style="text-align: center; font-weight:bold; ">Номер ТРК</TH>'                        skip
            '<TH style="text-align: center; font-weight:bold; ">Номер пистолета</TH>'                  skip
            '<TH style="text-align: center; font-weight:bold; ">Код топлива</TH>'                      skip
            '<TH style="text-align: center; font-weight:bold; ">Наименование топлива</TH>'             skip
            '<TH style="text-align: center; font-weight:bold; ">Объем топлива, л</TH>'                 skip
            '<TH style="text-align: center; font-weight:bold; ">Цена топлива, р</TH>'                  skip
            '<TH style="text-align: center; font-weight:bold; ">Сумма, р</TH>'                         skip
            '<TH style="text-align: center; font-weight:bold; ">Тип оплаты</TH>'                       skip
            '<TH style="text-align: center; font-weight:bold; ">Номер карты</TH>'                      skip
            '<TH style="text-align: center; font-weight:bold; ">Дата начала транзакции</TH>'           skip
            '<TH style="text-align: center; font-weight:bold; ">Время начала транзакции</TH>'          skip
            '<TH style="text-align: center; font-weight:bold; ">Дата окончания транзакции</TH>'        skip
            '<TH style="text-align: center; font-weight:bold; ">Время окончания транзакции</TH>'       skip
            '<TH style="text-align: center; font-weight:bold; ">Продолжительность транзакции (*)</TH>' skip
            '<TH style="text-align: center; font-weight:bold; ">Жизненный цикл заказа НП</TH>'         skip
            '<TH style="text-align: center; font-weight:bold; ">Продолжение налива</TH>'               skip
         '</TR>'skip
         .
      for each tt-rep
      break
         by tt-rep.obj-code
         by tt-rep.grp-num
         by tt-rep.sort-date
         by tt-rep.sort-time
         by tt-rep.datetime-beg
         by tt-rep.datetime-end:
         vLevel = "".
         if not first-of(tt-rep.grp-num) then do:
            if iGrpChk or iGrpTran then do:
               if iGrpChk and iGrpTran then
                  vLevel = 'level="2"'.
               else if iGrpChk and tt-rep.uuid-cheq = vPrevUuidCheq then
                  vLevel = 'level="2"'.
               else if iGrpTran and tt-rep.uuid = vPrevUuid then
                  vLevel = 'level="2"'.
            end.
         end.
         assign
            vPrevUuidCheq = tt-rep.uuid-cheq
            vPrevUuid     = tt-rep.uuid
            .
         put stream sOutStr-html unformatted
            '<TR ' vLevel '>' skip
                '<TD text_wrap="true" style="text-align: center">' fStrNvl(tt-rep.obj-name, "")                                '</TD>' skip
                '<TD style="text-align: center">'                  fdate2str(tt-rep.chk-date, "99.99.9999")                    '</TD>' skip
                '<TD style="text-align: center">'                  if tt-rep.chk-date = ? then "" else fStrNvl(string(tt-rep.chk-time, "HH:MM:SS"), "") '</TD>' skip
                '<TD style="text-align: center">'                  fdate2str(tt-rep.shift-date, "99.99.9999")                  '</TD>' skip
                '<TD style="text-align: center">'                  fStrNvl(tt-rep.shift-name, "")                              '</TD>' skip
                '<TD style="text-align: center">'                  fInt2Str(tt-rep.chk-num, ">>>>>>>>>>")                      '</TD>' skip
                '<TD style="text-align: center">'                  fInt2Str(tt-rep.z-number, ">>>>>>>>>>")                     '</TD>' skip
                '<TD style="text-align: center">'                  fInt2Str(tt-rep.tran-num, ">>>>>>>>>9")                     '</TD>' skip
                '<TD text_wrap="true" style="text-align: center">' fStrNvl(tt-rep.chk-type-desc, "")                           '</TD>' skip
                '<TD style="text-align: center">'                  fInt2Str(tt-rep.cash-num, ">>>>9")                          '</TD>' skip
                '<TD text_wrap="true" style="text-align: left">' fStrNvl(tt-rep.cashier, "")                                 '</TD>' skip
                '<TD style="text-align: center">'                  fInt2Str(tt-rep.trk-num, ">>9")                             '</TD>' skip
                '<TD style="text-align: center">'                  fInt2Str(tt-rep.nozzle-num, ">>9")                          '</TD>' skip
                '<TD style="text-align: center">'                  fInt2Str(tt-rep.fuel-code, ">>>>>>>>>9")                    '</TD>' skip
                '<TD text_wrap="true" style="text-align: center">' fStrNvl(tt-rep.gds-name, "")                                '</TD>' skip
                '<TD num="#,##0.00" val="' + fDec2Str(tt-rep.volume, "->>>>>>>>>>>9.99") + '" style="text-align: right">' + fDec2Str(tt-rep.volume, "->>>>>>>>>>>9.99") + '</TD>' skip
                '<TD num="#,##0.00" val="' + fDec2Str(tt-rep.price, "->>>>>>>>>>>9.99") + '" style="text-align: right">'  + fDec2Str(tt-rep.price, "->>>>>>>>>>>9.99") + '</TD>' skip
                '<TD num="#,##0.00" val="' + fDec2Str(tt-rep.money, "->>>>>>>>>>>9.99") + '" style="text-align: right">'  + fDec2Str(tt-rep.money, "->>>>>>>>>>>9.99") + '</TD>' skip
                '<TD text_wrap="true" style="text-align: center">' fStrNvl(tt-rep.cash-pay-name, "")                           '</TD>' skip
                '<TD style="text-align: center">'                  fStrNvl(tt-rep.pay-card, "")                                '</TD>' skip
                '<TD style="text-align: center">'                  fdate2str(tt-rep.date-beg, "99.99.9999")                    '</TD>' skip
                '<TD style="text-align: center">'                  fStrNvl(string(tt-rep.time-beg, "HH:MM:SS"), "")            '</TD>' skip
                '<TD style="text-align: center">'                  fdate2str(tt-rep.date-end, "99.99.9999")                    '</TD>' skip
                '<TD style="text-align: center">'                  fStrNvl(string(tt-rep.time-end, "HH:MM:SS"), "")            '</TD>' skip
                '<TD style="text-align: center">'                  fStrNvl(f_disp_time(tt-rep.time-length), "")                '</TD>' skip
                '<TD style="text-align: center">'                  fStrNvl(f_disp_time(tt-rep.all-time-length-2), "")          '</TD>' skip
                '<TD style="text-align: center">'                  string(tt-rep.resume-tran, "+/-")                           '</TD>' skip
            '</TR>' skip.
         if last-of(tt-rep.obj-code) then do:
            for first tt-total-rep where
                      tt-total-rep.obj-type = tt-rep.obj-type
                  and tt-total-rep.obj-code = tt-rep.obj-code
                  and tt-total-rep.obj-name = tt-rep.obj-name:
               put stream sOutStr-html unformatted
                  '<TR >' skip
                      '<TD style="text-align: left; font-weight:bold">'                   "Итого по:"                                                '</TD>' skip
                      '<TD style="text-align: left; font-weight:bold">'                   fStrNvl(tt-total-rep.obj-name, "")                         '</TD>' skip
                      '<TD text_wrap="true" style="text-align: left; font-weight:bold">'  "Количество чеков"                                         '</TD>' skip
                      '<TD style="text-align: left; font-weight:bold">'                    fInt2Str(tt-total-rep.qty-chk, ">>>9")                    '</TD>' skip
                      '<TD text_wrap="true" style="text-align: left; font-weight:bold">'  "Количество транзакций"                                    '</TD>' skip
                      '<TD style="text-align: left; font-weight:bold">'                    fInt2Str(tt-total-rep.qty-tran, ">>>9")                   '</TD>' skip
                      '<TD text_wrap="true" style="text-align: left; font-weight:bold">'  "Количество  чеков с транзакциями"                         '</TD>' skip
                      '<TD style="text-align: left; font-weight:bold">'                    fInt2Str(tt-total-rep.qty-chk-fuel, ">>>9")               '</TD>' skip
                      '<TD text_wrap="true" style="text-align: left; font-weight:bold">'  "Общая продолжительность"                                  '</TD>' skip
                      '<TD style="text-align: left; font-weight:bold">'                    fStrNvl(f_disp_time(tt-total-rep.full-time-tran), "")     '</TD>' skip
                      '<TD text_wrap="true" style="text-align: left; font-weight:bold">'  "Средняя продолжительность"                                '</TD>' skip
                      '<TD style="text-align: left; font-weight:bold">'                    fStrNvl(f_disp_time(tt-total-rep.avg-time-tran), "")      '</TD>' skip
                      '<TD text_wrap="true" style="text-align: left; font-weight:bold">'  "Средняя длительность жизненного цикла заказа НП"          '</TD>' skip
                      '<TD style="text-align: left; font-weight:bold">'                    fStrNvl(f_disp_time(tt-total-rep.avg-time-tran-fuel), "") '</TD>' skip
                      .
            end.
            do vI = 1 to 13:
               put stream sOutStr-html unformatted
                  '<TD style="text-align: right"> </TD>' skip
                  .
            end.
            put stream sOutStr-html unformatted
                  '</TR>' skip.
         end.
      end.
      for first tt-all-total-rep:
         put stream sOutStr-html unformatted
            '<TR >' skip
                '<TD style="text-align: left; font-weight:bold">'                   "Итого по:"                                                    '</TD>' skip
                '<TD text_wrap="true" style="text-align: left; font-weight:bold">'  "Всем выбранным объектам"                                      '</TD>' skip
                '<TD text_wrap="true" style="text-align: left; font-weight:bold">'  "Количество чеков"                                             '</TD>' skip
                '<TD style="text-align: left; font-weight:bold">'                    fInt2Str(tt-all-total-rep.qty-chk, ">>>9")                    '</TD>' skip
                '<TD text_wrap="true" style="text-align: left; font-weight:bold">'  "Количество транзакций"                                        '</TD>' skip
                '<TD style="text-align: left; font-weight:bold">'                    fInt2Str(tt-all-total-rep.qty-tran, ">>>9")                   '</TD>' skip
                '<TD text_wrap="true" style="text-align: left; font-weight:bold">'  "Количество  чеков с транзакциями"                             '</TD>' skip
                '<TD style="text-align: left; font-weight:bold">'                    fInt2Str(tt-all-total-rep.qty-chk-fuel, ">>>9")               '</TD>' skip
                '<TD text_wrap="true" style="text-align: left; font-weight:bold">'  "Общая продолжительность"                                      '</TD>' skip
                '<TD style="text-align: left; font-weight:bold">'                    fStrNvl(f_disp_time(tt-all-total-rep.full-time-tran), "")     '</TD>' skip
                '<TD text_wrap="true" style="text-align: left; font-weight:bold">'  "Средняя продолжительность"                                    '</TD>' skip
                '<TD style="text-align: left; font-weight:bold">'                    fStrNvl(f_disp_time(tt-all-total-rep.avg-time-tran), "")      '</TD>' skip
                '<TD text_wrap="true" style="text-align: left; font-weight:bold">'  "Средняя длительность жизненного цикла заказа НП"              '</TD>' skip
                '<TD style="text-align: left; font-weight:bold">'                    fStrNvl(f_disp_time(tt-all-total-rep.avg-time-tran-fuel), "") '</TD>' skip
                .
         do vI = 1 to 13:
            put stream sOutStr-html unformatted
               '<TD style="text-align: right"> </TD>' skip
               .
         end.
         put stream sOutStr-html unformatted
               '</TR>' skip.
      end.
      vStr = "(*) В отчете для всех строк с транзакцией, связанной с несколькими чеками или строками чеков (при смешанной оплате), " +
             "отображается одинаковая продолжительность. Данное время не определяет длительность выполнения конкретной кассовой операции " +
             "(например, возврат, сброс, аннуляция, смешанная оплата), относящейся к транзакции".
      put stream sOutStr-html unformatted
         '<TR>'  skip
            '<TD colspan="27" STYLE="font-size: 11px;">' + vStr + '</TD>' skip
         '</TR>' skip.
      put stream sOutStr-html unformatted
         '</tbody>' skip
         '</table>' skip
         '</body>' skip
         '</html>' skip
         .
      output stream sOutStr-html close.
      run prn-lib-reportviewer-report-name in this-procedure (
          input parparentproc
          ,input vFileNameRep
          ) no-error.
      if error-status:error then
      do:
          message "error-status:error = " error-status:error skip return-value view-as alert-box.
          return .
      end.
   end.
end procedure.
PROCEDURE get-report-num :
define output parameter p-report-num as integer no-undo .
  do
  on error undo, return error return-value
  :
    run gbl/getrpnum.p (output p-report-num).
  end.
END PROCEDURE.
