block-level on error undo, throw.
define input  parameter p-date-start      as date      no-undo .
define input  parameter p-time-start-sec  as integer   no-undo .
define input  parameter p-date-end        as date      no-undo .
define input  parameter p-time-end-sec    as integer   no-undo .
define variable vss-revision    as character no-undo init "$Revision: 03db1cb6171b, 2763, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Сб фев 20 15:59:21 2021 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-hazkrt.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-hazkrt.p $":U .
define variable vss-description as character no-undo init "Отчет Почасовая реализация на АЗК".
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
define variable g#report-num  as integer no-undo .
run get-report-num in my-handle (output g#report-num).
def var vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info10 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define stream excel-line.
define stream excel-cell.
define temp-table temp_cell-data no-undo
    field data-key as character
    field data-value as character
    index pi is primary unique data-key
.
define temp-table temp_sheet1_line-data no-undo
    field sheet-name    as character
    field xl-line-id    as integer
    field objName      as character
    field fuelName     as character
    field daySale      as character
    field salePrice    as character
    field notFuelSale as character
    index pi is primary unique
        xl-line-id
.
define variable v-hazkrtxl-sheet1-cur-data-row  as integer      no-undo.
define variable v-hazkrtxl-cell-file-name       as character    no-undo.
define variable v-hazkrtxl-data-file-name       as character    no-undo.
procedure hazkrtxl-init :
do
on error undo, return error
:
    assign
        v-hazkrtxl-sheet1-cur-data-row = 0
    .
    run gbl/_tmpfile.p (
          input "xd"
        , input ".txt"
        , output v-hazkrtxl-data-file-name
    ).
    output stream excel-line to value( v-hazkrtxl-data-file-name ).
    run gbl/_tmpfile.p (
          input "xc"
        , input ".txt"
        , output v-hazkrtxl-cell-file-name
    ).
    output stream excel-cell to value( v-hazkrtxl-cell-file-name ).
    run hazkrtxl-write-cell-data in this-procedure (
          input "sheetList":U
        , input "Сводка":U
    ).
    run hazkrtxl-write-cell-data in this-procedure (
          input "Сводка_regularExpressions":U
        , input "1":U
    ).
    if printrubl
    then do:
        run hazkrtxl-write-cell-data in this-procedure (
              input "Сводка_valutCode":U
            , input "0":U
        ).
    end.
    else do:
        run hazkrtxl-write-cell-data in this-procedure (
              input "Сводка_valutCode":U
            , input "1":U
        ).
    end.
    run hazkrtxl-write-cell-data in this-procedure (
          input "Сводка_columnList":U
        , input "objName,fuelName,daySale,salePrice,notFuelSale":U
    ).
    run hazkrtxl-write-cell-data in this-procedure (
          input "Сводка_columnType":U
        , input "S,S,S,S,D":U
    ).
end.
end procedure.
procedure hazkrtxl-write-line-data :
define input parameter p-obj-name       as character        no-undo.
define input parameter p-fuel-name      as character        no-undo.
define input parameter p-day-sale       as character        no-undo.
define input parameter p-sale-price     as character        no-undo.
define input parameter p-not-fuel-sale  as character        no-undo.
    define buffer buf_temp_sheet1_line-data        for temp_sheet1_line-data.
do
for buf_temp_sheet1_line-data
on error undo, return error
:
    for each buf_temp_sheet1_line-data
    :
        delete buf_temp_sheet1_line-data.
    end.
    create buf_temp_sheet1_line-data.
    assign
        v-hazkrtxl-sheet1-cur-data-row = v-hazkrtxl-sheet1-cur-data-row + 1
    .
    assign
        buf_temp_sheet1_line-data.sheet-name  = "Сводка":U
        buf_temp_sheet1_line-data.xl-line-id  = v-hazkrtxl-sheet1-cur-data-row
        buf_temp_sheet1_line-data.objName     = p-obj-name
        buf_temp_sheet1_line-data.fuelName    = p-fuel-name
        buf_temp_sheet1_line-data.daySale     = p-day-sale
        buf_temp_sheet1_line-data.salePrice   = p-sale-price
        buf_temp_sheet1_line-data.notFuelSale = p-not-fuel-sale
    .
    put stream excel-line unformatted
                        buf_temp_sheet1_line-data.sheet-name
        CHR(9)   "DTA":U
        CHR(9)   buf_temp_sheet1_line-data.objName
        CHR(9)   buf_temp_sheet1_line-data.fuelName
        CHR(9)   buf_temp_sheet1_line-data.daySale
        CHR(9)   buf_temp_sheet1_line-data.salePrice
        CHR(9)   buf_temp_sheet1_line-data.notFuelSale
        chr(10)
    .
end.
end procedure.
procedure hazkrtxl-write-cell-data :
define input parameter p-data-key   as character        no-undo.
define input parameter p-data-value as character        no-undo.
    define buffer buf_temp_cell-data     for temp_cell-data.
do
for buf_temp_cell-data
on error undo, return error
:
    find first buf_temp_cell-data
         where buf_temp_cell-data.data-key = p-data-key
    no-error.
    if not available buf_temp_cell-data
    then do:
        create buf_temp_cell-data.
        assign
            buf_temp_cell-data.data-key = p-data-key
        .
    end.
    assign
        buf_temp_cell-data.data-value = p-data-value
    .
    put stream excel-cell unformatted
                        buf_temp_cell-data.data-key
        CHR(9)   buf_temp_cell-data.data-value
        chr(10)
    .
end.
end procedure.
procedure hazkrtxl-run-excel :
define input parameter p-header-filename    as character        no-undo.
define input parameter p-data-filename      as character        no-undo.
    define variable v-template-file-name    as character    no-undo.
    define variable v-vb-file-name          as character    no-undo.
    define buffer buf_temp-param for temp-param .
do
for buf_temp-param
on error undo, return error
:
    create buf_temp-param.
    assign
        v-template-file-name    = search( "exe/hazkrt1.xlt" )
        v-vb-file-name          = search( "exe/t_form.bas" )
    .
    if v-template-file-name = ?
    or v-template-file-name = "":U
    then do:
        message
            "Ошибка имени файла шаблона."
        view-as alert-box error.
    end.
    if v-vb-file-name = ?
    or v-vb-file-name = "":U
    then do:
        message
            "Ошибка имени файла кода обработки."
        view-as alert-box error.
    end.
    run paramls-write in this-procedure (
          input "template":U
        , input "template-file-name":U
        , input v-template-file-name
    ).
    run paramls-write in this-procedure (
          input "template":U
        , input "vb-file-name":U
        , input v-vb-file-name
    ).
    run paramls-write in this-procedure (
          input "data":U
        , input "data-header-filename":U
        , input p-header-filename
    ).
    run paramls-write in this-procedure (
          input "data":U
        , input "data-filename":U
        , input p-data-filename
    ).
    run gbl/macroxlt.p (
        input-output table buf_temp-param
    ) no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip "Ошибка создания файла Excel."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
end.
end procedure.
procedure hazkrtxl-close :
do
on error undo, return error
:
    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append.
        export "exe/hazkrt1.xlt":U.
        export "exe/t_form.bas":U.
        export v-hazkrtxl-cell-file-name.
        export v-hazkrtxl-data-file-name.
    output close.
end.
end procedure.
define temp-table tt-fuel-goods no-undo like ub.goods
  field gds-order as integer
  field b-code    like ub.bar-code.b-code
index pi is primary unique gds-order gds-code
index bc b-code
.
define temp-table tt-fuel-density no-undo
  field obj-type like obj-list.obj-type
  field obj-code like obj-list.obj-code
  field den-date as date
  field b-code   like ub.bar-code.b-code
  field density  as decimal
index pi is primary unique obj-type obj-code den-date b-code
.
define temp-table tt-host-list no-undo
  field host-code as integer
  field host-name as character
index pi host-code
.
define temp-table tt-fuel-chk no-undo like ub.chk-gds
  field db-num   like obj-list.db-num
  field obj-type like obj-list.obj-type
  field obj-code like obj-list.obj-code
index pi is primary unique obj-type obj-code b-code doc-code line-num
index db db-num b-code price-base
.
define temp-table tt-gds-sale no-undo
  field db-num   like obj-list.db-num
  field obj-type like obj-list.obj-type
  field obj-code like obj-list.obj-code
  field sale-sum as decimal
  field db-name  as character
index pi is primary unique db-num
index db db-num
.
define temp-table tt-price no-undo
  field db-num    like obj-list.db-num
  field b-code    like ub.bar-code.b-code
  field gds-code  like ub.goods.gds-code
  field price     as decimal
  field is-unique as logical
index pi is primary unique db-num b-code
.
define temp-table tt-report no-undo
  field db-num      like obj-list.db-num
  field db-name     as character
  field gds-order   as integer
  field gds-name    as character
  field vol-rtl     as decimal
  field price-rtl   as decimal
  field sale-sum    as decimal
index pi is primary unique db-num gds-order
.
define variable v-hosts as character no-undo .
define frame hazkrt
        sym1 column-label ":!:" format "X(1)" space(0)
        tt-report.db-name column-label "№ АЗС ! " format "X(10)" space(0)
        sym2 column-label ":!:" format "X(1)" space(0)
        tt-report.gds-name column-label "Топливо ! " format "X(20)" space(0)
        sym3 column-label ":!:" format "X(1)" space(0)
        tt-report.vol-rtl column-label "Реализация за сутки ! (тонн)" format ">>>>>>>>>9.99" space(0)
        sym4 column-label ":!:" format "X(1)" space(0)
        tt-report.price-rtl column-label "Цена реализации! " format ">>>>>>>>>9.99" space(0)
        sym5 column-label ":!:" format "X(1)" space(0)
        tt-report.sale-sum column-label "Выручка от реализации сопутствующих ! товаров за сутки " format "->>>>>>>>>>>>9.99" space(0)
        sym6 column-label ":!:" format "X(1)" space(0)
header
  v-hosts skip(1)
  "C:  " string(p-date-start , "99/99/9999") format "X(12)" string(p-time-start-sec, "hh:mm")  skip
  "По: " string(p-date-end , "99/99/9999") format "X(12)" string(p-time-end-sec, "hh:mm")  skip
  fill('-',106) format "X(106)"
with width 235 down stream-io.
function is-correct-name return logical ( input p-name as character) forward.
do on error undo , return error return-value :
if session :set-wait-state( "compiler" ) then.
  run hazkrtxl-init in this-procedure .
  run waitfram-show in this-procedure ("Проверка топливных товаров...").
  run load-param-ptrl-gds in this-procedure .
  run load-chk in this-procedure .
  run calc-chk in this-procedure .
  run print-header in this-procedure .
  define stream out-stream.
output stream out-stream to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size  value(62) .
  put stream out-stream "1" skip.
  output stream out-stream close.
  run waitfram-show in this-procedure ("Удаление временных данных...").
  run clear-tt in this-procedure .
  run hazkrtxl-close in this-procedure .
  run waitfram-hide in this-procedure .
if session :set-wait-state( "" ) then.
  os-delete value( string( session:temp-directory ) + "rpt" + string( g#report-num ) + ".txl" )  .
  os-rename
    value( string( session:temp-directory ) + "$" + string( g#report-num ) + ".txl" )
    value( string( session:temp-directory ) + "rpt" + string( g#report-num ) + ".txl" )
  .
  define variable v-user-action   as character no-undo .
  define variable v-printed       as logical   no-undo .
  define variable DisabledOptions as integer   no-undo .
  define variable v-orient-page as character no-undo .
  run How-name in this-procedure (
      input ReportPageHeight,
      input ReportPageWidth,
      output v-orient-page )
      .
  if v-orient-page = "A4-lans":U then DisabledOptions = 20 .
                                else DisabledOptions = 0 .
  run gbl/prnfilen.w
      (input  ""
      ,input  DisabledOptions
      ,input  string(session :temp-directory) + "rpt" + string( g#report-num )
      ,input  ReportFontNum
      ,output v-user-action
      ,output v-printed
      ) .
  os-delete value( string( session:temp-directory ) + "rpt" + string( g#report-num ) ) .
  os-delete value( string( session:temp-directory ) + "rpt" + string( g#report-num ) + ".txl" ) .
end.
procedure load-param-ptrl-gds :
do
on error undo, return error return-value
:
  define buffer buf_bar-code      for ub.bar-code.
  define buffer buf_goods         for ub.goods.
  define buffer buf_tt-fuel-goods for tt-fuel-goods.
  define buffer buf_gds-prt       for ub.gds-prt.
  define variable v-par-val       as character no-undo .
  define variable v-par-type      as character no-undo .
  define variable v-value-date    as date      no-undo .
  define variable v-value-decimal as decimal   no-undo .
  define variable v-value-integer as integer   no-undo .
  define variable v-value-logical as logical   no-undo .
  define variable v-tth           as handle               no-undo .
  define variable v-num           as integer              no-undo .
  define variable v-i             as integer              no-undo .
  define variable v-bc            like ub.bar-code.b-code no-undo .
  define variable v-gds-code      like ub.goods.gds-code  no-undo .
  define variable v-gds-code-str  as character            no-undo .
  run adm/shattri.p (
      input "get":U
      ,input  ''
      ,input  0
      ,input  'report-glob':U
      ,input  'rep-sort':U
      ,output v-par-val
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-par-type
      ,INPUT-OUTPUT table-handle v-tth
                    ) no-error.
  if error-status :error
     or v-par-val = "":U
  then do:
    delete object v-tth.
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка чтения конфигурационного параметра " + 'rep-sort':U + "." skip
      "Отчет не может быть сформирован"
      view-as alert-box error.
    undo, return error.
  end.
  else do:
  assign
    v-num = num-entries(v-par-val).
  end.
  delete object v-tth.
  do v-i = 1 to v-num:
    assign
      v-gds-code =  integer( entry( v-i , v-par-val ) )
    .
    find first buf_goods no-lock
      where   buf_goods.gds-code = v-gds-code
    no-error .
    if not available buf_goods then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найден товар с кодом " + string(v-gds-code) + "." skip
        "Отчет не может быть сформирован."
        view-as alert-box error.
      undo, return error.
    end.
    find first buf_gds-prt no-lock
      where buf_gds-prt.upper-code = buf_goods.prt-root
    .
    find first buf_bar-code no-lock
      where buf_bar-code.gds-code   = buf_goods.gds-code
        and buf_bar-code.unit-cli   = buf_goods.unit-base
        and buf_bar-code.node-code  = buf_gds-prt.node-code
        and buf_bar-code.part-code  = ""
        and buf_bar-code.in-code    = ""
    no-error .
    if not available buf_bar-code then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найден бар-код для товара " + string(buf_goods.gds-code)+ " заданый в параметре " + "rep-sort":U + "." skip
        "Отчет не может быть сформирован."
        view-as alert-box error.
      undo, return error.
    end.
    else do:
      find first buf_tt-fuel-goods
        where buf_tt-fuel-goods.gds-code = buf_goods.gds-code
      no-error .
      if available buf_tt-fuel-goods then do:
        message
          vss-workfile vss-revision vss-description skip
          "В параметре " + "rep-sort":U + " заданы повторяющиеся коды " + string(v-gds-code)  skip
          "Отчет не может быть сформирован."
          view-as alert-box error.
        undo, return error.
      end.
      create buf_tt-fuel-goods.
      buffer-copy buf_goods to buf_tt-fuel-goods
      assign
        buf_tt-fuel-goods.gds-order = v-i
        buf_tt-fuel-goods.b-code    = buf_bar-code.b-code
      .
    end.
  end.
end.
end procedure.
procedure load-firms :
do
on error undo, return error return-value
:
  define variable v-host-code as integer    no-undo .
  define variable v-host-name as character  no-undo .
  empty temp-table tt-host-list.
  for each obj-list no-lock
  :
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostname in g#library
  (input  obj-list.obj-type
  ,input  obj-list.obj-code
  ,output v-host-code
  ,output v-host-name
  )  .
    find first tt-host-list
      where tt-host-list.host-code = v-host-code
    no-error .
    if not available tt-host-list then do:
      create tt-host-list.
      assign
        tt-host-list.host-code = v-host-code
        tt-host-list.host-name = v-host-name
      .
    end.
  end.
end.
end procedure.
procedure load-chk :
define buffer buf_chk-doc         for ub.chk-doc.
define buffer buf_chk-pay         for ub.chk-pay.
define buffer buf_chk-gds         for ub.chk-gds.
define buffer buf_inkas           for ub.inkas.
define buffer buf_goods           for ub.goods.
define buffer buf_tt-fuel-goods   for tt-fuel-goods.
define buffer buf_tt-fuel-density for tt-fuel-density.
define buffer buf_tt-gds-sale     for tt-gds-sale.
define buffer buf_tt-fuel-chk     for tt-fuel-chk.
define variable v-ptrl-volume   as decimal   no-undo .
define variable v-gds-sale-sum  as decimal   no-undo .
define variable v-days-num      as integer   no-undo .
define variable v-day           as integer   no-undo .
do
on error undo, return error return-value
:
  assign
    v-days-num = p-date-end - p-date-start
  .
  for each obj-list no-lock
  :
    assign
      v-gds-sale-sum = 0
    .
    run waitfram-show in this-procedure ("Обработка чеков по объекту " + obj-list.obj-name + " ..." ).
    _chk-doc:
    for each buf_chk-doc no-lock
        where buf_chk-doc.obj-type  = obj-list.obj-type
          and buf_chk-doc.obj-code  = obj-list.obj-code
          and buf_chk-doc.chk-date >= p-date-start
          and buf_chk-doc.chk-date <= p-date-end ,
        first buf_inkas no-lock
        where buf_inkas.inkas-code = buf_chk-doc.out-code
          and buf_inkas.status_    = 'факт':U
    :
      if      buf_chk-doc.chk-date = p-date-start
          and buf_chk-doc.chk-time < p-time-start-sec
      then do:
        next _chk-doc.
      end.
      if      buf_chk-doc.chk-date = p-date-end
          and buf_chk-doc.chk-time > ( p-time-end-sec + 60 )
      then do:
        next _chk-doc.
      end.
      if lookup( string(buf_chk-doc.chk-type) , '14,15,16,36,17,8,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U ) > 0 then do :
        next _chk-doc.
      end.
      for each buf_chk-gds no-lock
        where buf_chk-gds.doc-code = buf_chk-doc.doc-code
      :
        find first buf_tt-fuel-goods no-lock
          where buf_tt-fuel-goods.b-code = buf_chk-gds.b-code
        no-error .
        if available buf_tt-fuel-goods then do:
          find first buf_tt-fuel-chk
            where buf_tt-fuel-chk.obj-type = buf_chk-doc.obj-type
              and buf_tt-fuel-chk.obj-code = buf_chk-doc.obj-code
              and buf_tt-fuel-chk.b-code   = buf_chk-gds.b-code
              and buf_tt-fuel-chk.doc-code = buf_chk-gds.doc-code
              and buf_tt-fuel-chk.line-num = buf_chk-gds.line-num
          no-error .
          if not available buf_tt-fuel-chk then do:
            create buf_tt-fuel-chk.
            buffer-copy buf_chk-gds to buf_tt-fuel-chk
            assign
              buf_tt-fuel-chk.obj-type    = buf_chk-doc.obj-type
              buf_tt-fuel-chk.obj-code    = buf_chk-doc.obj-code
              buf_tt-fuel-chk.db-num      = obj-list.db-num
              buf_tt-fuel-chk.price-base  = ( buf_chk-gds.price-base - buf_chk-gds.discnt)
            .
          end.
        end.
        else do:
        assign
          v-gds-sale-sum = v-gds-sale-sum + ( buf_chk-gds.doc-qnty * ( buf_chk-gds.price-base - buf_chk-gds.discnt) )
        .
        end.
      end.
    end.
    find first buf_tt-gds-sale
      where buf_tt-gds-sale.db-num = obj-list.db-num
    no-error .
    if not available buf_tt-gds-sale then do:
      create buf_tt-gds-sale.
    end.
    assign
      buf_tt-gds-sale.db-num   = obj-list.db-num
      buf_tt-gds-sale.sale-sum = buf_tt-gds-sale.sale-sum + v-gds-sale-sum
    .
  end.
end.
end procedure.
procedure calc-chk :
define buffer buf_tt-fuel-chk     for tt-fuel-chk.
define buffer sch_tt-fuel-chk     for tt-fuel-chk.
define buffer buf_tt-price        for tt-price.
define buffer buf_tt-fuel-density for tt-fuel-density.
define buffer bf_tt-fuel-density  for tt-fuel-density.
define buffer buf_tt-report       for tt-report.
define buffer buf_tt-gds-sale     for tt-gds-sale .
define buffer buf_tt-fuel-goods   for tt-fuel-goods.
define variable v-density       like ub.doc-line.fact-density.
define variable v-unique-price  as logical   no-undo .
define variable v-sum1          as decimal   no-undo .
define variable v-sum2          as decimal   no-undo .
define variable v-gds-sale-sum  as decimal   no-undo .
define variable v-db-name       as character no-undo .
do
on error undo, return error return-value
:
   for each buf_tt-fuel-chk
      break by buf_tt-fuel-chk.db-num
      by buf_tt-fuel-chk.b-code
      :
      if first-of(buf_tt-fuel-chk.db-num) or first-of(buf_tt-fuel-chk.b-code) then
      do:
         run waitfram-show in this-procedure ("Расчет по базе " + string( buf_tt-fuel-chk.db-num ) + " ..." ).
         find first sch_tt-fuel-chk no-lock
            where sch_tt-fuel-chk.db-num      = buf_tt-fuel-chk.db-num
            and sch_tt-fuel-chk.b-code      = buf_tt-fuel-chk.b-code
            and sch_tt-fuel-chk.price-base <> buf_tt-fuel-chk.price-base
            no-error .
         create buf_tt-price.
         assign
            buf_tt-price.db-num    = buf_tt-fuel-chk.db-num
            buf_tt-price.b-code    = buf_tt-fuel-chk.b-code
            buf_tt-price.price     = buf_tt-fuel-chk.price-base
            buf_tt-price.is-unique = if available sch_tt-fuel-chk then no else yes
            v-unique-price         = if available sch_tt-fuel-chk then no else yes
            .
      end.
      if not v-unique-price then
      do :
         assign
            v-sum1 = v-sum1 + ( buf_tt-fuel-chk.price-base * buf_tt-fuel-chk.doc-qnty )
            v-sum2 = v-sum2 + buf_tt-fuel-chk.doc-qnty
            .
      end.
      if last-of(buf_tt-fuel-chk.db-num) or last-of(buf_tt-fuel-chk.b-code) then
      do:
         if not v-unique-price then
         do :
            find first buf_tt-price
               where buf_tt-price.db-num    = buf_tt-fuel-chk.db-num
               and buf_tt-price.b-code  = buf_tt-fuel-chk.b-code
               no-error .
            if available buf_tt-price then
            do:
               assign
                  buf_tt-price.price = if v-sum2 > 0 then ( v-sum1 / v-sum2 ) else 0
                  .
            end.
         end.
         assign
            v-sum1 = 0
            v-sum2 = 0
            .
      end.
      find first buf_tt-fuel-density
         where buf_tt-fuel-density.obj-type  = buf_tt-fuel-chk.obj-type
         and buf_tt-fuel-density.obj-code  = buf_tt-fuel-chk.obj-code
         and buf_tt-fuel-density.den-date  = buf_tt-fuel-chk.chk-date
         and buf_tt-fuel-density.b-code    = buf_tt-fuel-chk.b-code
         no-error .
      if not available buf_tt-fuel-density then
      do:
         run find-density in this-procedure ( input buf_tt-fuel-chk.obj-type
            , input buf_tt-fuel-chk.obj-code
            , input buf_tt-fuel-chk.chk-date
            , input buf_tt-fuel-chk.b-code
            , output v-density
            ) .
         if v-density <> 0 then
         do:
            create buf_tt-fuel-density .
            assign
               buf_tt-fuel-density.obj-type = buf_tt-fuel-chk.obj-type
               buf_tt-fuel-density.obj-code = buf_tt-fuel-chk.obj-code
               buf_tt-fuel-density.den-date = buf_tt-fuel-chk.chk-date
               buf_tt-fuel-density.b-code   = buf_tt-fuel-chk.b-code
               buf_tt-fuel-density.density  = v-density
               .
         end.
         else
         do:
            find first bf_tt-fuel-density
               where bf_tt-fuel-density.obj-type  = buf_tt-fuel-chk.obj-type
               and bf_tt-fuel-density.obj-code  = buf_tt-fuel-chk.obj-code
               and bf_tt-fuel-density.b-code    = buf_tt-fuel-chk.b-code
               no-error .
            if available (bf_tt-fuel-density) then
            do:
               create buf_tt-fuel-density .
               assign
                  buf_tt-fuel-density.obj-type = buf_tt-fuel-chk.obj-type
                  buf_tt-fuel-density.obj-code = buf_tt-fuel-chk.obj-code
                  buf_tt-fuel-density.den-date = buf_tt-fuel-chk.chk-date
                  buf_tt-fuel-density.b-code   = buf_tt-fuel-chk.b-code
                  buf_tt-fuel-density.density  = bf_tt-fuel-density.density
                  .
            end.
            else
            do:
               for first ub.bar-code no-lock where ub.bar-code.b-code = buf_tt-fuel-density.b-code,
                  first ub.goods no-lock where ub.goods.gds-code = ub.bar-code.gds-code:
                  message
                     substitute( "Для объекта &5 &6 не найден ни один документ &4 для товара артикул: &2 , наименование: &3 . &4 Плотность для товара будет равно 0 ."
                     , ""
                     , ub.goods.artic
                     , ub.goods.gds-name
                     , chr(10)
                     , buf_tt-fuel-chk.obj-type
                     , buf_tt-fuel-chk.obj-code
                     )
                     view-as alert-box information.
               end.
               create buf_tt-fuel-density .
               assign
                  buf_tt-fuel-density.obj-type = buf_tt-fuel-chk.obj-type
                  buf_tt-fuel-density.obj-code = buf_tt-fuel-chk.obj-code
                  buf_tt-fuel-density.den-date = buf_tt-fuel-chk.chk-date
                  buf_tt-fuel-density.b-code   = buf_tt-fuel-chk.b-code
                  buf_tt-fuel-density.density  = v-density
                  .
            end.
         end.
      end.
   end.
  for each buf_tt-fuel-chk
  break by buf_tt-fuel-chk.db-num
        by buf_tt-fuel-chk.b-code
  :
    if first-of(buf_tt-fuel-chk.db-num) or first-of (buf_tt-fuel-chk.b-code) then do:
      find first buf_tt-gds-sale
        where buf_tt-gds-sale.db-num = buf_tt-fuel-chk.db-num
      no-error .
      find first tt-fuel-goods
        where tt-fuel-goods.b-code = buf_tt-fuel-chk.b-code
      no-error .
      find first buf_tt-price
        where buf_tt-price.db-num = buf_tt-fuel-chk.db-num
          and buf_tt-price.b-code = buf_tt-fuel-chk.b-code
      no-error .
      create buf_tt-report.
      assign
        buf_tt-report.db-num    = buf_tt-fuel-chk.db-num
        buf_tt-report.db-name   = buf_tt-gds-sale.db-name
        buf_tt-report.gds-order = tt-fuel-goods.gds-order
        buf_tt-report.gds-name  = tt-fuel-goods.gds-name
        buf_tt-report.sale-sum  = buf_tt-gds-sale.sale-sum
        buf_tt-report.price-rtl = buf_tt-price.price
      .
    end.
    find first buf_tt-fuel-density
      where buf_tt-fuel-density.obj-type = buf_tt-fuel-chk.obj-type
        and buf_tt-fuel-density.obj-code = buf_tt-fuel-chk.obj-code
        and buf_tt-fuel-density.den-date = buf_tt-fuel-chk.chk-date
        and buf_tt-fuel-density.b-code   = buf_tt-fuel-chk.b-code
    no-error .
    if not available buf_tt-fuel-density then do:
      message
        substitute ( "Не найдено значение плотности для топлива с бар-кодом: &1&5 на  объекте &2 &3 за &4"
                   , buf_tt-fuel-chk.b-code
                   , buf_tt-fuel-chk.obj-type
                   , buf_tt-fuel-chk.obj-code
                   , buf_tt-fuel-chk.chk-date
                   , chr(10)
                   )
      view-as alert-box error.
      undo, return error.
    end.
    assign
      buf_tt-report.vol-rtl = buf_tt-report.vol-rtl + ( buf_tt-fuel-chk.doc-qnty * buf_tt-fuel-density.density )
    .
  end.
  define variable v-gds-name  as character no-undo .
  define variable v-vol-rtl   as character no-undo .
  define variable v-price-rtl as character no-undo .
  for each buf_tt-report
  break by buf_tt-report.db-num
        by buf_tt-report.gds-order
  :
    assign
      buf_tt-report.vol-rtl   = round( ( buf_tt-report.vol-rtl / 1000 ) , 2 )
      buf_tt-report.sale-sum  = round( ( buf_tt-report.sale-sum / 1000 ) , 2 )
    .
  end.
  for each obj-list no-lock
    break by obj-list.db-num
  :
    if first-of(obj-list.db-num) then do:
      assign
        v-db-name = ""
      .
      for each buf_tt-fuel-goods no-lock
      :
        find first buf_tt-report
          where buf_tt-report.db-num    = obj-list.db-num
            and buf_tt-report.gds-order = buf_tt-fuel-goods.gds-order
        no-error .
        if not available buf_tt-report then do:
          find first buf_tt-gds-sale
            where buf_tt-gds-sale.db-num = obj-list.db-num
          no-error .
          create buf_tt-report.
          assign
            buf_tt-report.db-num    = obj-list.db-num
            buf_tt-report.gds-order = buf_tt-fuel-goods.gds-order
            buf_tt-report.gds-name  = buf_tt-fuel-goods.gds-name
            buf_tt-report.vol-rtl   = 0
            buf_tt-report.price-rtl = 0
            buf_tt-report.sale-sum  = if available buf_tt-gds-sale then
                                        round( ( buf_tt-gds-sale.sale-sum / 1000 ) , 2 )
                                      else
                                        0
          .
        end.
      end.
    end.
    if is-correct-name( input obj-list.obj-name ) then do:
      assign
        v-db-name = obj-list.obj-name
      .
    end.
    if last-of(obj-list.db-num) then do:
      if v-db-name = "" then do:
        assign
          v-db-name = "БД " + string(obj-list.db-num)
        .
      end.
      assign
        buf_tt-report.db-name = v-db-name
      .
    end.
  end.
  for each buf_tt-report
  break by buf_tt-report.db-num
        by buf_tt-report.gds-order
  :
    assign
      v-gds-name   = v-gds-name   + chr(6) + buf_tt-report.gds-name
      v-vol-rtl    = v-vol-rtl    + chr(6) + string(buf_tt-report.vol-rtl)
      v-price-rtl  = v-price-rtl  + chr(6) + string( buf_tt-report.price-rtl , ">>>>>>9.99" )
    .
    if last-of (buf_tt-report.db-num) then do:
      assign
        v-gds-name   = trim( v-gds-name  , chr(6) )
        v-vol-rtl    = trim( v-vol-rtl   , chr(6) )
        v-price-rtl  = trim( v-price-rtl , chr(6) )
      .
      run hazkrtxl-write-line-data in this-procedure ( input buf_tt-report.db-name
                                                     , input v-gds-name
                                                     , input v-vol-rtl
                                                     , input v-price-rtl
                                                     , input buf_tt-report.sale-sum
                                                     ) .
      assign
        v-gds-name  = "":U
        v-vol-rtl   = "":U
        v-price-rtl = "":U
      .
    end.
  end.
end.
end procedure.
procedure find-density :
define input  parameter p-obj-type  like obj-list.obj-type    no-undo .
define input  parameter p-obj-code  like obj-list.obj-code    no-undo .
define input  parameter p-date      as date                   no-undo .
define input  parameter p-b-code    like ub.bar-code.b-code   no-undo .
define output parameter p-density   like ub.doc-line.fact-density  no-undo .
define buffer buf_trn-doc       for ub.trn-doc.
define buffer buf_doc-line      for ub.doc-line.
define buffer buf_goods         for ub.goods.
define buffer buf_tt-fuel-goods for tt-fuel-goods.
define variable v-i     as integer   no-undo .
define variable v-sum1  as decimal   no-undo .
define variable v-sum2  as decimal   no-undo .
do
on error undo, return error return-value
:
  find first buf_tt-fuel-goods
    where buf_tt-fuel-goods.b-code = p-b-code
  no-error .
  if not available buf_tt-fuel-goods then return.
  find first buf_goods no-lock
    where buf_goods.gds-code = buf_tt-fuel-goods.gds-code
  no-error .
  if not available buf_goods then do :
    message
      "Не найден товар с бар-кодом " + string( p-b-code )
    view-as alert-box error.
    undo, return error.
  end.
  for each buf_trn-doc no-lock
        where buf_trn-doc.obj-type     = p-obj-type
          and buf_trn-doc.obj-code     = p-obj-code
          and buf_trn-doc.status_      = 'факт':U
          and buf_trn-doc.fact-date    = p-date
          and buf_trn-doc.ext-doc-type = 'ie':U,
      each buf_doc-line no-lock
        where buf_doc-line.doc-code   = buf_trn-doc.doc-code
          and buf_doc-line.artic      = buf_goods.artic
          and buf_doc-line.prod-type  = buf_goods.prod-type
          and buf_doc-line.prod-code  = buf_goods.prod-code
  :
    assign
      v-sum1 = v-sum1 + (buf_doc-line.fact-qnty * buf_doc-line.fact-density)
      v-sum2 = v-sum2 + buf_doc-line.fact-qnty
    .
  end.
  if v-sum2 > 0 then do:
    assign
      p-density = v-sum1 / v-sum2
    .
    return .
  end.
  _find-last-doc:
  for each buf_trn-doc no-lock
        where buf_trn-doc.obj-type     = p-obj-type
          and buf_trn-doc.obj-code     = p-obj-code
          and buf_trn-doc.status_      = 'факт':U
          and buf_trn-doc.fact-date    < p-date
          and buf_trn-doc.ext-doc-type = 'ie':U
  by fact-date descending
  :
    find first buf_doc-line no-lock
      where buf_doc-line.doc-code   = buf_trn-doc.doc-code
        and buf_doc-line.artic      = buf_goods.artic
        and buf_doc-line.prod-type  = buf_goods.prod-type
        and buf_doc-line.prod-code  = buf_goods.prod-code
    no-error .
    if available buf_doc-line then do:
      assign
        v-sum1 = buf_doc-line.fact-density
      .
      leave _find-last-doc .
    end.
  end.
  if v-sum1 > 0 then do:
    assign
      p-density = v-sum1
    .
  end.
  else do:
    assign
      p-density = 0
    .
  end.
end.
end procedure.
procedure get-hosts :
define output parameter p-host-list as character no-undo .
define buffer buf_tt-host-list for tt-host-list.
do
on error undo, return error return-value
:
  run load-firms in this-procedure .
  for each buf_tt-host-list :
    assign
      p-host-list = p-host-list + buf_tt-host-list.host-name + "\n"
    .
  end.
  assign
    p-host-list = trim( p-host-list , "\n" )
  .
end.
end procedure.
procedure print-header :
do
on error undo, return error return-value
:
  run get-hosts in this-procedure ( output v-hosts ).
  run hazkrtxl-write-cell-data in this-procedure ( input "h_hostName":U
                                                 , input v-hosts
                                                 ).
  run hazkrtxl-write-cell-data in this-procedure ( input "h_dateDayStart":U
                                                 , input day(p-date-start)
                                                 ).
  run hazkrtxl-write-cell-data in this-procedure ( input "h_dateMonthStart":U
                                                 , input month(p-date-start)
                                                 ).
  run hazkrtxl-write-cell-data in this-procedure ( input "h_dateYearStart":U
                                                 , input year(p-date-start)
                                                 ).
  run hazkrtxl-write-cell-data in this-procedure ( input "h_dateTimeStart":U
                                                 , input string( p-time-start-sec , "HH:MM")
                                                 ).
  run hazkrtxl-write-cell-data in this-procedure ( input "h_dateDayEnd":U
                                                 , input day(p-date-end)
                                                 ).
  run hazkrtxl-write-cell-data in this-procedure ( input "h_dateMonthEnd":U
                                                 , input month(p-date-end)
                                                 ).
  run hazkrtxl-write-cell-data in this-procedure ( input "h_dateYearEnd":U
                                                 , input year(p-date-end)
                                                 ).
  run hazkrtxl-write-cell-data in this-procedure ( input "h_dateTimeEnd":U
                                                 , input string( p-time-end-sec , "HH:MM")
                                                 ).
end.
end procedure.
procedure clear-tt :
do
on error undo, return error return-value
:
  empty temp-table tt-fuel-goods .
  empty temp-table tt-fuel-density .
  empty temp-table tt-host-list .
  empty temp-table tt-fuel-chk .
  empty temp-table tt-gds-sale .
  empty temp-table tt-price .
  empty temp-table tt-report .
end.
end procedure.
function is-correct-name return logical ( input p-name as character) :
define variable v-word  as character  no-undo.
define variable v-num   as integer    no-undo.
define variable v-i     as integer    no-undo.
v-num = num-entries("АЗС,АЗК":U).
_find-cycle:
do v-i = 1 to v-num :
    v-word = entry( v-i , "АЗС,АЗК":U ) .
    if ( index( caps(p-name) , v-word ) > 0 ) then do :
        return yes.
    end.
end.
return no.
end function.
