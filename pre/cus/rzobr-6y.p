block-level on error undo, throw.
define input parameter x-store-code like ub.clients.obj-code   no-undo.
define input parameter x-store-type like ub.clients.obj-type   no-undo.
define input parameter x-base-type  like ub.currency.curr-abbr no-undo.
define input parameter x-base-code  like ub.currency.curr-code no-undo.
define input parameter xClassify  as char no-undo.
define input parameter xSortType  as char no-undo.
define input parameter xSumsOnly  as log  no-undo.
define input parameter xShowZero  as log  no-undo.
define input parameter xShowZero-2  as log  no-undo.
define input parameter xTog-obj   as log no-undo.
define input parameter xtog-lavel as log no-undo.
define input parameter xvar-lavel as int no-undo.
define input parameter vat-cost as logical no-undo .
define input parameter vat-crsa as logical no-undo .
define input parameter vat-sale as logical no-undo .
define buffer goods   for ub.goods  .
define buffer gds-obj for ub.gds-obj  .
define buffer clients for ub.clients  .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Оборотная ведомость отчет (совокупная)".
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
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-cntxt-host-code-obj
  ,output base-code
  )  .
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable div# as char no-undo.
define variable fr as logical no-undo .
define variable fr0 as logical no-undo .
define variable tmp#stroka as character no-undo .
define variable tmp#stroka0 as character no-undo .
define variable v-bar-code    like ub.bar-code.b-code no-undo  .
define variable s-bar-code   as character format "x(9)" no-undo .
define temp-table tmp-gds no-undo
  field id as integer
  field name      as character  format "x(256)"
  field f-name    as character  format "x(256)"
  field node-code as integer
  field lvl       as integer
 index pi id
.
define variable NEW-vat        like ub.doc-line.vat-pc    no-undo.
define variable LAST-vat       like ub.doc-line.vat-pc    no-undo.
define variable  var-vat-pc    like ub.doc-line.vat-pc    no-undo.
define variable g-ll as integer no-undo .
define variable id as integer no-undo .
define temp-table temp-gds-list no-undo
  field gds-code  like ub.goods.gds-code
  field prod-code like ub.goods.prod-code
  field grp-name  like ub.goods.grp-name
  field gds-name  like ub.goods.gds-name
  field artic     like ub.goods.artic
  field vat-pc    as decimal
   index pi is primary unique gds-code ascending
   index i1 artic     ascending
   index i2 prod-code ascending
   index i3 grp-name  ascending
   index i33 gds-name  ascending
   index i4 vat-pc    ascending
   index i5 prod-code grp-name   ascending
   index i6 grp-name  prod-code   ascending
   .
define variable sum_1     as   decimal  format "->>>>>>>>>>>9.<<<" no-undo.
define variable sum_2     as   decimal  format "->>>>>>>>>>>9.<<<" no-undo.
define variable b1-sum_1  as   decimal  format "->>>>>>>>>>>9.<<<" no-undo.
define variable b1-sum_2  as   decimal  format "->>>>>>>>>>>9.<<<" no-undo.
define variable b2-sum_1  as   decimal  format "->>>>>>>>>>>9.<<<" no-undo.
define variable b2-sum_2  as   decimal  format "->>>>>>>>>>>9.<<<" no-undo.
define variable bi-sum_1  as   decimal  format "->>>>>>>>>>>9.<<<" no-undo.
define variable bi-sum_2  as   decimal  format "->>>>>>>>>>>9.<<<" no-undo.
define variable bo-sum_1  as   decimal  format "->>>>>>>>>>>9.<<<" no-undo.
define variable bo-sum_2  as   decimal  format "->>>>>>>>>>>9.<<<" no-undo.
FUNCTION n-lavel RETURNS char (INPUT grp-name as char, INPUT lavel# as int ).
define variable  str  as char format "X(60)"  no-undo.
define variable  str2 as char no-undo.
define variable v-r as character no-undo init "" .
define variable  i#i as int no-undo.
STR = "".
repeat i#i =1 to lavel#:
    if i#i =1 then str   = entry(1,grp-name, chr(47)) .
    else do:
        str2 = entry(i#i,grp-name, chr(47)) no-error.
        if not error-status:error  and str2 <> "":u then
               str = str +  chr(47) +  entry(i#i,grp-name, chr(47)) no-error .
        end.
end.
if str <> ? then do:
v-r = str + chr(47) .
end.
RETURN v-r .
END FUNCTION.
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
  define temp-table tt-obj-list no-undo
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    index pi is primary unique obj-type obj-code
    index name obj-name
    .
function func-vat returns decimal (
    input p-gds-code as integer  ,
    input p-obj-type as character ,
    input p-obj-code as integer  ).
define variable i-vat-pc as decimal no-undo .
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  p-gds-code
  ,input  '1':U
  ,input  x-Date-End
  ,input  v-cntxt-host-code-obj
  ,input  p-obj-type
  ,input  p-obj-code
  ,output i-vat-pc
  ) no-error .
if error-status :error then return 0 .
else return i-vat-pc.
end function .
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable xserv as char init 'все':U no-undo.
define variable   tPrintRubl as log no-undo.
define  stream  OutStream.
define  stream  OutStream2.
define variable    ObjName           as   char no-undo.
define variable    Select-Good       as   integer no-undo.
define variable    ChosedType        as   integer no-undo.
define variable    PayType           as   integer no-undo.
define variable    RetClassify       as   char  no-undo.
define variable    RetSortType       as   char  no-undo.
define variable    Show-Negativ      as   logical  no-undo.
define variable    Show-Negativ-2    as   logical  no-undo.
define variable    Sums-Only         as   logical  no-undo.
define variable    ValType           as   integer no-undo.
define variable    Line              as   char        no-undo.
define variable    FirstLine         as   logical     no-undo.
define variable tot_tqnty as decimal  no-undo.
define variable break_group as logical no-undo init true.
define variable break_group1 as logical no-undo init true.
define variable stat     as log no-undo .
define variable InpError as log no-undo .
define variable i        as integer no-undo .
define variable p        as integer no-undo init 0 .
define variable kk        as integer no-undo init 0 .
define variable old-page as integer no-undo .
define variable new-page as integer no-undo .
define variable rid-list as character no-undo .
define variable   Null-str#      as decimal  no-undo.
define variable   Null-str2#     as decimal  no-undo.
define variable   b1-Null-str#   as decimal  no-undo.
define variable   b1-Null-str2#  as decimal  no-undo.
define variable   b2-Null-str#   as decimal  no-undo.
define variable   b2-Null-str2#  as decimal  no-undo.
define variable gds-zap-unit-base     like ub.goods.unit-base     no-undo.
define variable gds-zap-prt-root      like ub.goods.prt-root     no-undo .
define variable gds-zap-gds-name      like ub.goods.gds-name     no-undo .
define variable gds-zap-prod-type     like ub.goods.prod-type    no-undo .
define variable gds-zap-prod-code     like ub.goods.prod-code    no-undo .
define variable gds-zap-artic         like ub.goods.artic        no-undo .
define variable gds-zap-b-code        like ub.bar-code.b-code    no-undo .
define variable gds-type              as char no-undo.
define variable gds-zap-type          like ub.goods.gds-type no-undo .
define variable gds-zap-grp-name      like ub.goods.grp-name     no-undo .
define variable gds-zap-prod-name     like ub.clients.obj-name   no-undo .
define variable gds-zap-price-base    like ub.stk-tot.sum-base no-undo.
define variable gds-zap-stoim-base    like ub.stk-tot.sum-base no-undo.
define variable gds-zap-qnty          like ub.stk-tot.fact-qnty no-undo.
define variable gds-zap-Nds           like ub.stk-tot.sum-base no-undo.
define variable gds-zap-Np            like ub.stk-tot.sum-base no-undo.
define variable F-ostatok-start    as   char  no-undo.
define variable F-ostatok-End      as   char  no-undo.
define variable ostatok-start      as   decimal EXTENT 10 Format "->>>>>>>>>>9.<<<" no-undo.
define variable ostatok-End        as   decimal EXTENT 10 Format "->>>>>>>>>>9.<<<" no-undo.
define variable B1-ostatok-start   as   decimal EXTENT 10 Format "->>>>>>>>>>9.<<<" no-undo.
define variable B1-ostatok-End     as   decimal EXTENT 10 Format "->>>>>>>>>>9.<<<" no-undo.
define variable B2-ostatok-start   as   decimal EXTENT 10 Format "->>>>>>>>>>9.<<<" no-undo.
define variable B2-ostatok-End     as   decimal EXTENT 10 Format "->>>>>>>>>>9.<<<" no-undo.
define variable Bi-ostatok-start   as   decimal EXTENT 10 Format "->>>>>>>>>>9.<<<" no-undo.
define variable Bi-ostatok-End     as   decimal EXTENT 10 Format "->>>>>>>>>>9.<<<" no-undo.
define variable Bo-ostatok-start   as   decimal EXTENT 10 Format "->>>>>>>>>>9.<<<" no-undo.
define variable Bo-ostatok-End     as   decimal EXTENT 10 Format "->>>>>>>>>>9.<<<" no-undo.
define variable F-prih             as   char  no-undo.
define variable F-rash             as   char  no-undo.
define variable F-kassa            as   char  no-undo.
define variable F-Inv              as   char  no-undo.
define variable F-Overturn         as   char  no-undo.
define variable prih             as   decimal EXTENT 10 Format "->>>>>>>>>>9.<<<" no-undo.
define variable rash             as   decimal EXTENT 10 Format "->>>>>>>>>>9.<<<" no-undo.
define variable kassa            as   decimal EXTENT 10 Format "->>>>>>>>>>9.<<<" no-undo.
define variable Inv              as   decimal EXTENT 10 Format "->>>>>>>>>>9.<<<" no-undo.
define variable Overturn         as   decimal EXTENT 10 Format "->>>>>>>>>>9.<<<" no-undo.
define variable B1-prih             as   decimal EXTENT 10 Format "->>>>>>>>>>9.<<<" no-undo.
define variable B1-rash             as   decimal EXTENT 10 Format "->>>>>>>>>>9.<<<" no-undo.
define variable B1-kassa            as   decimal EXTENT 10 Format "->>>>>>>>>>9.<<<" no-undo.
define variable B1-Inv              as   decimal EXTENT 10 Format "->>>>>>>>>>9.<<<" no-undo.
define variable B1-Overturn         as   decimal EXTENT 10 Format "->>>>>>>>>>9.<<<" no-undo.
define variable B2-prih             as   decimal EXTENT 10 Format "->>>>>>>>>>9.<<<" no-undo.
define variable B2-rash             as   decimal EXTENT 10 Format "->>>>>>>>>>9.<<<" no-undo.
define variable B2-kassa            as   decimal EXTENT 10 Format "->>>>>>>>>>9.<<<" no-undo.
define variable B2-Inv              as   decimal EXTENT 10 Format "->>>>>>>>>>9.<<<" no-undo.
define variable B2-Overturn         as   decimal EXTENT 10 Format "->>>>>>>>>>9.<<<" no-undo.
define variable Bi-prih             as   decimal EXTENT 10 Format "->>>>>>>>>>9.<<<" no-undo.
define variable Bi-rash             as   decimal EXTENT 10 Format "->>>>>>>>>>9.<<<" no-undo.
define variable Bi-kassa            as   decimal EXTENT 10 Format "->>>>>>>>>>9.<<<" no-undo.
define variable Bi-Inv              as   decimal EXTENT 10 Format "->>>>>>>>>>9.<<<" no-undo.
define variable Bi-Overturn         as   decimal EXTENT 10 Format "->>>>>>>>>>9.<<<" no-undo.
define variable Bo-prih             as   decimal EXTENT 10 Format "->>>>>>>>>>9.<<<" no-undo.
define variable Bo-rash             as   decimal EXTENT 10 Format "->>>>>>>>>>9.<<<" no-undo.
define variable Bo-kassa            as   decimal EXTENT 10 Format "->>>>>>>>>>9.<<<" no-undo.
define variable Bo-Inv              as   decimal EXTENT 10 Format "->>>>>>>>>>9.<<<" no-undo.
define variable Bo-Overturn         as   decimal EXTENT 10 Format "->>>>>>>>>>9.<<<" no-undo.
define variable gds-zap-other         like ub.stk-tot.sum-base no-undo.
define variable bo-gds-zap-other         like ub.stk-tot.sum-base no-undo.
define variable bi-gds-zap-other         like ub.stk-tot.sum-base no-undo.
define variable b1-gds-zap-other         like ub.stk-tot.sum-base no-undo.
define variable b2-gds-zap-other         like ub.stk-tot.sum-base no-undo.
define variable  Fact-order-1   like ub.stk-tot.Fact-order no-undo.
define variable  Quantity1      like ub.stk-tot.fact-qnty  no-undo.
define variable  Coast_R1       like ub.stk-tot.sum-rubl   no-undo.
define variable  Coast_V1       like ub.stk-tot.sum-rubl   no-undo.
define variable  VAT_R1         like ub.stk-tot.sum-rubl   no-undo.
define variable  VAT_V1         like ub.stk-tot.sum-rubl   no-undo.
define variable  Fact-order-2   like ub.stk-tot.Fact-order no-undo.
define variable  Quantity2      like ub.stk-tot.fact-qnty  no-undo.
define variable  Coast2         like ub.stk-tot.sum-rubl   no-undo.
define variable  Coast_R2       like ub.stk-tot.sum-rubl   no-undo.
define variable  Coast_V2       like ub.stk-tot.sum-rubl   no-undo.
define variable  VAT_R2         like ub.stk-tot.sum-rubl   no-undo.
define variable  VAT_V2         like ub.stk-tot.sum-rubl   no-undo.
define variable  Quantity    like ub.stk-tot.fact-qnty  no-undo.
define variable  Coast       like ub.stk-tot.sum-rubl   no-undo.
define variable  Coast_R     like ub.stk-tot.sum-rubl   no-undo.
define variable  Coast_V     like ub.stk-tot.sum-rubl   no-undo.
define variable  VAT_R       like ub.stk-tot.sum-rubl   no-undo.
define variable  VAT_V       like ub.stk-tot.sum-rubl   no-undo.
define variable  SLT_R       like ub.stk-tot.sum-rubl   no-undo.
define variable  SLT_V       like ub.stk-tot.sum-rubl   no-undo.
define variable  Coast3       like ub.stk-tot.sum-rubl   no-undo.
define variable  Coast4       like ub.stk-tot.sum-rubl   no-undo.
define variable  temp-str as char no-undo.
define variable xShowCost as logical no-undo .
define variable xShowSale as logical no-undo .
define variable xShowcrsa as logical no-undo .
define variable str as char format "X(60)" no-undo.
define variable i#i as int no-undo.
define variable xLavel as int  no-undo.
define variable list-field as char no-undo.
define variable str10 as char no-undo.
DEFINE FRAME zapas
        s-bar-code column-label  "Код! ! ":C9 space(0)
        sym1 column-label ":!:!:" format "x(1)"       space(0)
        gds-zap-artic column-label "Артикул! ! ":C16 format "X(16)" space(0)
        sym2 column-label ":!:!:" format "x(1)"                         space(0)
        gds-zap-gds-name column-label "Название товара! ! ":C36 format "X(36)" space(0)
        sym3 column-label ":!:!:" format "x(1)"                                     space(0)
        gds-zap-unit-base column-label "Ед.!изм! " format "X(3)"                  space(0)
        sym4 column-label ":!:!:" format "x(1)"                                     space(0)
        gds-type column-label "Тип!данных! ":C6 format "X(6)"                  space(0)
        sym5 column-label ":!:!:" format "x(1)" space(0)
        F-ostatok-start     column-label "Остаток на!начало! ":C14 format "x(14)"           space(0)
        sym6 column-label ":!:!:" format "x(1)" space(0)
        F-Prih       column-label "Приход! ! ":C14     Format "x(14)"     space(0)
        sym7 column-label ":!:!:" format "x(1)" space(0)
        F-Rash       column-label "Расход! ! ":C14  Format "x(14)"   space(0)
        sym8 column-label ":!:!:" format "x(1)" space(0)
        F-kassa             column-label "Касса! ! ":C14  Format "x(14)"   space(0)
        sym9  column-label ":!:!:" format "x(1)" space(0)
        F-Inv               column-label "Инвентаризация! ! ":C14  Format "x(14)"   space(0)
        sym10 column-label ":!:!:" format "x(1)" space(0)
        F-Overturn         column-label "Переоценка! ! ":C14  Format "x(14)"   space(0)
        sym11 column-label ":!:!:" format "x(1)" space(0)
        gds-zap-other      column-label "Скидка! ! ":C13     space(0)
        sym12 column-label ":!:!:" format "x(1)" space(0)
        F-ostatok-end     column-label "Остаток!на конец! ":C14 format "x(14)"           space(0)
    HEADER
        string( "Дата печати : " + string(TODAY,"99.99.9999") +  " , " + string(TIME, "HH:MM") ) AT 5 format "X(35)"
        "Цены указаны в" (if tPrintRubl then "РУБ" else x-base-type )
        string( "Страница " + string( PAGE-NUMBER( OutStream ), ">>>>>9") ) AT 147 format "X(53)" SKIP
        Line format "X(194)" AT 1
   with width 232 down stream-io use-text NO-BOX.
     assign
        i=0
        xlavel = xvar-lavel
        Select-Good   = x-SelectGood
        PayType       = x-SET_PAY_TYPE
        RetClassify   = xClassify
        RetSortType   = xSortType
        Sums-Only     = xSumsOnly
        Show-Negativ  = xShowZero
        Show-Negativ-2  = xShowZero-2
        xShowCost     = Show-Cost
        xShowSale     = Show-Sale
        xShowcrsa     = Show-crsa
        FirstLine     = FALSE
        Line          = fill("-", 232)
        ValType       = IF (PayType = 1) Then 0  else x-SET_val_TYPE.
     run report-execute.
PROCEDURE report-execute :
define variable gj as integer no-undo init 0.
  If (ValType=0 and x-base-code=0)  Or ValType=1
                                then   assign tPrintRubl = yes .
                                else   assign tPrintRubl = no .
  run waitfram-show( 'Подождите ...' ) .
  if ReportPageHeight = 0 then ReportPageHeight  = 43.
output stream OutStream to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size  value(ReportPageHeight) .
  FIND FIRST clients where x-store-type = clients.obj-type AND
                           x-store-code = clients.obj-code no-lock no-error.
  If available clients then  ObjName = clients.obj-name.
                                else  ObjName="объект не определен".
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
form header
  line format "X(194)" at 1 skip
  "Продолжение - на следующей странице" at 30 skip
  with frame bottomframe width 232 page-bottom no-labels no-box .
view stream outstream frame bottomframe .
       FOR each obj-list no-lock:
          x-store-type = obj-list.obj-type.
          x-store-code = obj-list.obj-code.
          gj = gj + 1.
          run report-exec1.
      End.
      if gj > 1 then do:
        HIDE stream OutStream FRAME BottomFrame .
        run display-bo.
        run u-line.
      End.
  HIDE stream OutStream FRAME BottomFrame .
  HIDE   STREAM OutStream FRAME ZAPAS .
  Output stream OutStream close.
  run waitfram-hide .
  if Make-Excel then output stream ForExcel close.
  define variable v-user-action as character no-undo .
  define variable v-printed as logical   no-undo .
  define variable DisabledOptions as integer   no-undo .
  define variable v-orient-page as character no-undo .
  run How-name in this-procedure (
      input ReportPageHeight,
      input ReportPageWidth,
      output v-orient-page )
      .
  if v-orient-page = "A4-lans":U then DisabledOptions = 8 .
                                 else DisabledOptions = 0 .
  run gbl/prnfilen.w
    (input  ""
    ,input  DisabledOptions
    ,input  string(session :temp-directory) + "rpt" + string( g#report-num )
    ,input  ReportFontNum
    ,output v-user-action
    ,output v-printed
    ) .
END PROCEDURE.
PROCEDURE foreach :
If Integer(50) = 0 Then Temp1  = 100  .
                      Else Temp1 = Integer(50) .
     IF ( i modulo Temp1 = 0 ) AND ( i >= Temp1 ) then
         RUN waitfram-show( "Обработано строк : " + string( i )) .
  run clear-item.
run ost-line in this-procedure
               (input   x-store-code  ,
                input   x-store-type  ,
                input   gds-zap-artic     ,
                input   gds-zap-prod-code ,
                input   gds-zap-prod-type ,
                input   x-tog-shift       ,
                input   Fact-order-1               ,
                input   'cost':U            ,
                input   '##,##':U    ,
                input   xtog-obj    ,
                output  quantity    ,
                output  coast_r     ,
                output  coast_v     ,
                output  vat_r       ,
                output  vat_v       ,
                output  slt_r       ,
                output  slt_v       ).
assign
  ostatok-start [1 + 0]   = quantity
 ostatok-start [2 + 0]   = if tprintrubl then coast_r else coast_v
 ostatok-start [3 + 0]   = if tprintrubl then vat_r   else vat_v
 b1-ostatok-start [1 + 0] =  b1-ostatok-start [1 + 0] + ostatok-start [1 + 0]
 b1-ostatok-start [2 + 0] =  b1-ostatok-start [2 + 0] + ostatok-start [2 + 0]
 b1-ostatok-start [3 + 0] =  b1-ostatok-start [3 + 0] + ostatok-start [3 + 0]
 b2-ostatok-start [1 + 0] =  b2-ostatok-start [1 + 0] + ostatok-start [1 + 0]
 b2-ostatok-start [2 + 0] =  b2-ostatok-start [2 + 0] + ostatok-start [2 + 0]
 b2-ostatok-start [3 + 0] =  b2-ostatok-start [3 + 0] + ostatok-start [3 + 0]
 .
 assign
  bi-ostatok-start [1 + 0] =  bi-ostatok-start [1 + 0] + ostatok-start [1 + 0]
  bi-ostatok-start [2 + 0] =  bi-ostatok-start [2 + 0] + ostatok-start [2 + 0]
  bi-ostatok-start [3 + 0] =  bi-ostatok-start [3 + 0] + ostatok-start [3 + 0]
 .
If  xshowcrsa or vat-crsa Then DO:
run ost-line in this-procedure
               (input   x-store-code  ,
                input   x-store-type  ,
                input   gds-zap-artic     ,
                input   gds-zap-prod-code ,
                input   gds-zap-prod-type ,
                input   x-tog-shift       ,
                input   Fact-order-1               ,
                input   'crsa':U            ,
                input   '##,##':U    ,
                input   xtog-obj    ,
                output  quantity    ,
                output  coast_r     ,
                output  coast_v     ,
                output  vat_r       ,
                output  vat_v       ,
                output  slt_r       ,
                output  slt_v       ).
assign
  ostatok-start [4]        = round(ostatok-start [1] *  p-price-med , 2)
 ostatok-start [2 + 3]   = if tprintrubl then coast_r else coast_v
 ostatok-start [3 + 3]   = if tprintrubl then vat_r   else vat_v
 b1-ostatok-start [1 + 3] =  b1-ostatok-start [1 + 3] + ostatok-start [1 + 3]
 b1-ostatok-start [2 + 3] =  b1-ostatok-start [2 + 3] + ostatok-start [2 + 3]
 b1-ostatok-start [3 + 3] =  b1-ostatok-start [3 + 3] + ostatok-start [3 + 3]
 b2-ostatok-start [1 + 3] =  b2-ostatok-start [1 + 3] + ostatok-start [1 + 3]
 b2-ostatok-start [2 + 3] =  b2-ostatok-start [2 + 3] + ostatok-start [2 + 3]
 b2-ostatok-start [3 + 3] =  b2-ostatok-start [3 + 3] + ostatok-start [3 + 3]
 .
 assign
  bi-ostatok-start [1 + 3] =  bi-ostatok-start [1 + 3] + ostatok-start [1 + 3]
  bi-ostatok-start [2 + 3] =  bi-ostatok-start [2 + 3] + ostatok-start [2 + 3]
  bi-ostatok-start [3 + 3] =  bi-ostatok-start [3 + 3] + ostatok-start [3 + 3]
 .
   End.
If xshowsale or vat-sale Then DO:
run ost-line in this-procedure
               (input   x-store-code  ,
                input   x-store-type  ,
                input   gds-zap-artic     ,
                input   gds-zap-prod-code ,
                input   gds-zap-prod-type ,
                input   x-tog-shift       ,
                input   Fact-order-1               ,
                input   'crsa':U            ,
                input   '##,##':U    ,
                input   xtog-obj    ,
                output  quantity    ,
                output  coast_r     ,
                output  coast_v     ,
                output  vat_r       ,
                output  vat_v       ,
                output  slt_r       ,
                output  slt_v       ).
assign
  ostatok-start [1 + 6]   = quantity
 ostatok-start [2 + 6]   = if tprintrubl then coast_r else coast_v
 ostatok-start [3 + 6]   = if tprintrubl then vat_r   else vat_v
 ostatok-start [10]        = if tprintrubl then slt_r   else slt_v
 b1-ostatok-start [1 + 6] =  b1-ostatok-start [1 + 6] + ostatok-start [1 + 6]
 b1-ostatok-start [2 + 6] =  b1-ostatok-start [2 + 6] + ostatok-start [2 + 6]
 b1-ostatok-start [3 + 6] =  b1-ostatok-start [3 + 6] + ostatok-start [3 + 6]
 b2-ostatok-start [1 + 6] =  b2-ostatok-start [1 + 6] + ostatok-start [1 + 6]
 b2-ostatok-start [2 + 6] =  b2-ostatok-start [2 + 6] + ostatok-start [2 + 6]
 b2-ostatok-start [3 + 6] =  b2-ostatok-start [3 + 6] + ostatok-start [3 + 6]
 b1-ostatok-start [10] =  b1-ostatok-start [10] + ostatok-start [10]
 b2-ostatok-start [10] =  b2-ostatok-start [10] + ostatok-start [10]
 .
 assign
  bi-ostatok-start [1 + 6] =  bi-ostatok-start [1 + 6] + ostatok-start [1 + 6]
  bi-ostatok-start [2 + 6] =  bi-ostatok-start [2 + 6] + ostatok-start [2 + 6]
  bi-ostatok-start [3 + 6] =  bi-ostatok-start [3 + 6] + ostatok-start [3 + 6]
  bi-ostatok-start [10] =  bi-ostatok-start [10] + ostatok-start [10]
 .
   End.
run ost-line in this-procedure
               (input   x-store-code  ,
                input   x-store-type  ,
                input   gds-zap-artic     ,
                input   gds-zap-prod-code ,
                input   gds-zap-prod-type ,
                input   x-tog-shift       ,
                input   Fact-order-2               ,
                input   'cost':U            ,
                input   '##,##':U    ,
                input   xtog-obj    ,
                output  quantity    ,
                output  coast_r     ,
                output  coast_v     ,
                output  vat_r       ,
                output  vat_v       ,
                output  slt_r       ,
                output  slt_v       ).
assign
  ostatok-end [1 + 0]   = quantity
 ostatok-end [2 + 0]   = if tprintrubl then coast_r else coast_v
 ostatok-end [3 + 0]   = if tprintrubl then vat_r   else vat_v
 b1-ostatok-end [1 + 0] =  b1-ostatok-end [1 + 0] + ostatok-end [1 + 0]
 b1-ostatok-end [2 + 0] =  b1-ostatok-end [2 + 0] + ostatok-end [2 + 0]
 b1-ostatok-end [3 + 0] =  b1-ostatok-end [3 + 0] + ostatok-end [3 + 0]
 b2-ostatok-end [1 + 0] =  b2-ostatok-end [1 + 0] + ostatok-end [1 + 0]
 b2-ostatok-end [2 + 0] =  b2-ostatok-end [2 + 0] + ostatok-end [2 + 0]
 b2-ostatok-end [3 + 0] =  b2-ostatok-end [3 + 0] + ostatok-end [3 + 0]
 .
 assign
  bi-ostatok-end [1 + 0] =  bi-ostatok-end [1 + 0] + ostatok-end [1 + 0]
  bi-ostatok-end [2 + 0] =  bi-ostatok-end [2 + 0] + ostatok-end [2 + 0]
  bi-ostatok-end [3 + 0] =  bi-ostatok-end [3 + 0] + ostatok-end [3 + 0]
 .
If  xshowcrsa or vat-crsa Then DO:
run ost-line in this-procedure
               (input   x-store-code  ,
                input   x-store-type  ,
                input   gds-zap-artic     ,
                input   gds-zap-prod-code ,
                input   gds-zap-prod-type ,
                input   x-tog-shift       ,
                input   Fact-order-2               ,
                input   'crsa':U            ,
                input   '##,##':U    ,
                input   xtog-obj    ,
                output  quantity    ,
                output  coast_r     ,
                output  coast_v     ,
                output  vat_r       ,
                output  vat_v       ,
                output  slt_r       ,
                output  slt_v       ).
assign
  ostatok-end [4]        = round(ostatok-end [1] *  p-price-med , 2)
 ostatok-end [2 + 3]   = if tprintrubl then coast_r else coast_v
 ostatok-end [3 + 3]   = if tprintrubl then vat_r   else vat_v
 b1-ostatok-end [1 + 3] =  b1-ostatok-end [1 + 3] + ostatok-end [1 + 3]
 b1-ostatok-end [2 + 3] =  b1-ostatok-end [2 + 3] + ostatok-end [2 + 3]
 b1-ostatok-end [3 + 3] =  b1-ostatok-end [3 + 3] + ostatok-end [3 + 3]
 b2-ostatok-end [1 + 3] =  b2-ostatok-end [1 + 3] + ostatok-end [1 + 3]
 b2-ostatok-end [2 + 3] =  b2-ostatok-end [2 + 3] + ostatok-end [2 + 3]
 b2-ostatok-end [3 + 3] =  b2-ostatok-end [3 + 3] + ostatok-end [3 + 3]
 .
 assign
  bi-ostatok-end [1 + 3] =  bi-ostatok-end [1 + 3] + ostatok-end [1 + 3]
  bi-ostatok-end [2 + 3] =  bi-ostatok-end [2 + 3] + ostatok-end [2 + 3]
  bi-ostatok-end [3 + 3] =  bi-ostatok-end [3 + 3] + ostatok-end [3 + 3]
 .
   End.
If xshowsale or vat-sale Then DO:
run ost-line in this-procedure
               (input   x-store-code  ,
                input   x-store-type  ,
                input   gds-zap-artic     ,
                input   gds-zap-prod-code ,
                input   gds-zap-prod-type ,
                input   x-tog-shift       ,
                input   Fact-order-2               ,
                input   'crsa':U            ,
                input   '##,##':U    ,
                input   xtog-obj    ,
                output  quantity    ,
                output  coast_r     ,
                output  coast_v     ,
                output  vat_r       ,
                output  vat_v       ,
                output  slt_r       ,
                output  slt_v       ).
assign
  ostatok-end [1 + 6]   = quantity
 ostatok-end [2 + 6]   = if tprintrubl then coast_r else coast_v
 ostatok-end [3 + 6]   = if tprintrubl then vat_r   else vat_v
 ostatok-end [10]        = if tprintrubl then slt_r   else slt_v
 b1-ostatok-end [1 + 6] =  b1-ostatok-end [1 + 6] + ostatok-end [1 + 6]
 b1-ostatok-end [2 + 6] =  b1-ostatok-end [2 + 6] + ostatok-end [2 + 6]
 b1-ostatok-end [3 + 6] =  b1-ostatok-end [3 + 6] + ostatok-end [3 + 6]
 b2-ostatok-end [1 + 6] =  b2-ostatok-end [1 + 6] + ostatok-end [1 + 6]
 b2-ostatok-end [2 + 6] =  b2-ostatok-end [2 + 6] + ostatok-end [2 + 6]
 b2-ostatok-end [3 + 6] =  b2-ostatok-end [3 + 6] + ostatok-end [3 + 6]
 b1-ostatok-end [10] =  b1-ostatok-end [10] + ostatok-end [10]
 b2-ostatok-end [10] =  b2-ostatok-end [10] + ostatok-end [10]
 .
 assign
  bi-ostatok-end [1 + 6] =  bi-ostatok-end [1 + 6] + ostatok-end [1 + 6]
  bi-ostatok-end [2 + 6] =  bi-ostatok-end [2 + 6] + ostatok-end [2 + 6]
  bi-ostatok-end [3 + 6] =  bi-ostatok-end [3 + 6] + ostatok-end [3 + 6]
  bi-ostatok-end [10] =  bi-ostatok-end [10] + ostatok-end [10]
 .
   End.
    case  gds-zap-type :
    when 'у':U THEN DO:
      run ob-line (
          input   x-store-code   ,
          input   x-store-type   ,
          INPUT   gds-zap-artic       ,
          INPUT   gds-zap-prod-code   ,
          INPUT   gds-zap-prod-type   ,
          INPUT   Fact-order-1,
          INPUT   Fact-order-2,
          input   'cssr':U    ,
          input   '##,##':U,
          input   ""    ,
          input   xTog-obj) .
     End.
    when 'т':U THEN DO:
      run ob-line (
          input   x-store-code   ,
          input   x-store-type   ,
          INPUT   gds-zap-artic       ,
          INPUT   gds-zap-prod-code   ,
          INPUT   gds-zap-prod-type   ,
          INPUT   Fact-order-1,
          INPUT   Fact-order-2,
          input   'cost':U    ,
          input   '##,##':U,
          input   ""    ,
          input   xTog-obj) .
      End.
      End case.
   run calc-sub-itog (0).
  If xshowcrsa OR  xshowsale or vat-crsa or vat-sale Then DO:
    case  gds-zap-type :
    when 'у':U THEN DO:
      run ob-line (
          input   x-store-code   ,
          input   x-store-type   ,
          INPUT   gds-zap-artic       ,
          INPUT   gds-zap-prod-code   ,
          INPUT   gds-zap-prod-type   ,
          INPUT   Fact-order-1,
          INPUT   Fact-order-2,
          input   'cgsr':U    ,
          input   '##,##':U,
          input   ""    ,
          input   xTog-obj) .
     End.
    when 'т':U THEN DO:
      run ob-line (
          input   x-store-code   ,
          input   x-store-type   ,
          INPUT   gds-zap-artic       ,
          INPUT   gds-zap-prod-code   ,
          INPUT   gds-zap-prod-type   ,
          INPUT   Fact-order-1,
          INPUT   Fact-order-2,
          input   'crsa':U    ,
          input   '##,##':U,
          input   ""    ,
          input   xTog-obj) .
      End.
          End case.
     run calc-sub-itog (3).
     End.
  If xshowsale  Then DO:
    case  gds-zap-type :
    when 'у':U THEN DO:
      run ob-line (
          input   x-store-code   ,
          input   x-store-type   ,
          INPUT   gds-zap-artic       ,
          INPUT   gds-zap-prod-code   ,
          INPUT   gds-zap-prod-type   ,
          INPUT   Fact-order-1,
          INPUT   Fact-order-2,
          input   'sasr':U    ,
          input   '##,##':U,
          input   ""    ,
          input   xTog-obj) .
     End.
    when 'т':U THEN DO:
      run ob-line (
          input   x-store-code   ,
          input   x-store-type   ,
          INPUT   gds-zap-artic       ,
          INPUT   gds-zap-prod-code   ,
          INPUT   gds-zap-prod-type   ,
          INPUT   Fact-order-1,
          INPUT   Fact-order-2,
          input   'sale':U    ,
          input   '##,##':U,
          input   ""    ,
          input   xTog-obj) .
      End.
          End case.
     run calc-sub-itog (6).
     End.
END PROCEDURE.
PROCEDURE display-line :
     i = i + 1.
        if NOT( NOT Show-Negativ-2 and
         ( prih         [1]   = 0 AND
          rash          [1]   = 0 AND
          kassa         [1]   = 0 AND
          Inv           [1]   = 0 AND
          Overturn      [1]   = 0 AND
          Overturn      [5]   = 0 AND
          Overturn      [8]   = 0 ) ) then DO:
        IF  NOT (NOT Show-Negativ  AND (
              prih          [1]   = 0 AND
              rash          [1]   = 0 AND
              kassa         [1]   = 0 AND
              Inv           [1]   = 0 AND
              Overturn      [1]   = 0 AND
              Overturn      [5]   = 0 AND
              ostatok-start [1]   = 0 AND
              ostatok-End   [1]   = 0   )) then DO:
        IF NOT Sums-Only then DO:
            if fr0 = true then do:
              PUT stream  OutStream  tmp#stroka0 format "X(100)" SKIP.
              if Make-Excel then  put   stream ForExcel unformatted String(tmp#stroka0) skip.
              fr0 = false .
            end.
            if fr = true then dO:
              PUT stream OutStream space(10) temp-str format "X(100)" SKIP.
              if Make-Excel then  put   stream ForExcel unformatted CHR(9) String(temp-str) skip.
              fr = false .
            end.
           run display-str1 in this-procedure.
          End.
        End.
     END.
  END PROCEDURE.
PROCEDURE print-header :
if NOT FirstLine Then DO:
   run display-title.
   FORM with FRAME ZAPAS .  DOWN stream   OutStream 1 with FRAME ZAPAS .
End.
 FirstLine = TRUE .
    if xTog-obj and   x-SelectObject <> "currency":U   Then  DO:
          PUT stream  OutStream  UNFORMATTED     "ПО ОБЪЕКТУ : " + CAPS(clients.obj-name)  AT 30 format "X(170)" SKIP.
          if Make-Excel then  put   stream ForExcel unformatted   "ПО ОБЪЕКТУ : " + CAPS(clients.obj-name) format "X(170)" SKIP.
      End.
      run clear-b1 .
      run clear-b2.
      run clear-bi .
      break_group = true.
      break_group1 = true.
   END PROCEDURE.
PROCEDURE Print-Footer :
      If RetClassify = "no-classify":U  then run u-line.
       gds-zap-artic = "ИТОГО" .
       run display-bi.
       run u-line.
       END PROCEDURE.
PROCEDURE U-LINE :
UNDERLINE stream OutStream  sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12
        s-bar-code
        gds-zap-artic
        gds-zap-gds-name
        gds-zap-unit-base
        gds-type
        F-ostatok-start
        F-Prih
        F-Rash
        F-KAssa
        F-Inv
        F-Overturn
        F-ostatok-end
        gds-zap-other
        with FRAME ZAPAS .
        DOWN stream   OutStream 1 with FRAME ZAPAS.
        END PROCEDURE.
PROCEDURE P-LINE :
UNDERLINE stream OutStream  sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12
        gds-zap-artic
        gds-zap-gds-name
        gds-zap-unit-base
        gds-type
        F-ostatok-start
        F-Prih
        F-Rash
        F-KAssa
        F-Inv
        F-Overturn
        F-ostatok-end
        gds-zap-other
        with FRAME ZAPAS .
        DOWN stream   OutStream 1 with FRAME ZAPAS.
        END PROCEDURE.
procedure run7 :
      case select-good:
        when 1   then do:
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
IF x-SelectObject = "currency":U  OR  xTog-obj then do :
define variable first-l17 as logical   no-undo .
  first-l17 = true .
  for each gds-obj
    where gds-obj.obj-type = x-store-type
      and gds-obj.obj-code = x-store-code
          and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
          no-lock,
      first goods  where  goods.gds-code = gds-obj.gds-code
      no-lock
      break by func-vat (input gds-obj.gds-code , input x-store-type, input x-store-code)
            by (goods.artic)
            :
      var-vat-pc = func-vat ( input gds-obj.gds-code, input x-store-type, input x-store-code) .
      if last-vat <> var-vat-pc then do:
          if not first-l17 then do:
            Assign
                s-bar-code    = ""
                gds-zap-artic = "        Итого по "
                gds-zap-gds-name = b1-name
                .
              run display-b1.
              run clear-b1  .
          end.
          Assign
            first-l17 = false
            break_group = true
            break_group1 = true
            .
          end.
      first-l17 = false .
      run item-goods ( "6" , "goods" ) .
      last-vat = func-vat (input gds-obj.gds-code , input x-store-type, input x-store-code) .
   end.
    Assign
        s-bar-code   = ""
        gds-zap-artic = "        Итого по "
        gds-zap-gds-name = b1-name
        .
      run display-b1.
      run clear-b1.
end.
else do:
   For each obj-list no-lock :
                  FOR EACH gds-obj where
                      gds-obj.obj-type = obj-list.obj-type    and
                      gds-obj.obj-code = obj-list.obj-code
                      and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
                      no-lock :
                      find first temp-gds-list where temp-gds-list.gds-code = gds-obj.gds-code no-error .
                      if not available temp-gds-list then do:
                          find first goods no-lock  where goods.gds-code  = gds-obj.gds-code .
                          Create temp-gds-list.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  gds-obj.gds-code
  ,input  '1':U
  ,input  ?
  ,input  v-cntxt-host-code-obj
  ,input  gds-obj.obj-type
  ,input  gds-obj.obj-code
  ,output var-vat-pc
  ) no-error .
                          Assign
                            temp-gds-list.prod-code = gds-obj.prod-code
                            temp-gds-list.grp-name  = gds-obj.grp-name
                            temp-gds-list.gds-name  = goods.gds-name
                            temp-gds-list.gds-code  = gds-obj.gds-code
                            temp-gds-list.artic     = gds-obj.artic
                            temp-gds-list.vat-pc    = var-vat-pc
                          .
                      End.
                      else do:
                      if temp-gds-list.vat-pc = 0 or temp-gds-list.vat-pc = ? then do:
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  gds-obj.gds-code
  ,input  '1':U
  ,input  ?
  ,input  v-cntxt-host-code-obj
  ,input  gds-obj.obj-type
  ,input  gds-obj.obj-code
  ,output var-vat-pc
  ) no-error .
                            Assign
                              temp-gds-list.vat-pc    = var-vat-pc
                            .
                      end.
                      end.
            End.
  End.
  for each temp-gds-list no-lock
    , First goods     where goods.gds-code  = temp-gds-list.gds-code no-lock
      BREAK BY (func-vat(gds-obj.gds-code,gds-obj.obj-type,gds-obj.obj-code))  BY goods.artic :
    run item-goods ( "6" , "goods" ) .
      if return-value <> "" then NEXT.
        If Last-of((func-vat(gds-obj.gds-code,gds-obj.obj-type,gds-obj.obj-code))) Then Do:
        If String(Entry(2,"(func-vat(gds-obj.gds-code,gds-obj.obj-type,gds-obj.obj-code))",".")) = "Grp-name"
          Then  Assign
                  S-bar-code   = " Итого по "
                  Gds-zap-artic = Substring(
                                      B1-name
                                      ,1,16)
                  Gds-zap-gds-name = Substring(
                                      B1-name
                                      ,17,40)
                                .
          Else  Assign
                  S-bar-code   = ""
                  Gds-zap-artic = "        Итого по "
                  Gds-zap-gds-name =  B1-name
                                .
            Run Display-b1 In This-procedure .
            Run Clear-b1 In This-procedure .
            Assign Break_Group = True.
        End.
  End.
End.
  end.
        when 2   then do:
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if x-selectobject = "currency":u  or  xtog-obj then do :
define variable first-l20 as logical   no-undo .
  first-l20 = true .
      for  each gds-obj where
                gds-obj.obj-code   = x-store-code and
                gds-obj.obj-type   = x-store-type
                and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
                no-lock ,
      first  tmp#grp  where gds-obj.grp-name   begins tmp#grp.grp-name   no-lock ,
      first goods       where gds-obj.gds-code   = goods.gds-code  no-lock
      break by func-vat (input gds-obj.gds-code , input x-store-type, input x-store-code)
            by (goods.artic)
            :
      var-vat-pc = func-vat ( input gds-obj.gds-code, input x-store-type, input x-store-code) .
      if last-vat <> var-vat-pc then do:
          if not first-l20 then do:
            Assign
                s-bar-code    = ""
                gds-zap-artic = "        Итого по "
                gds-zap-gds-name = b1-name
                .
              run display-b1.
              run clear-b1  .
          end.
          Assign
            first-l20 = false
            break_group = true
            break_group1 = true
            .
          end.
      first-l20 = false .
      run item-goods ( "6" , "goods" ) .
      last-vat = func-vat (input gds-obj.gds-code , input x-store-type, input x-store-code) .
   end.
    Assign
        s-bar-code   = ""
        gds-zap-artic = "        Итого по "
        gds-zap-gds-name = b1-name
        .
      run display-b1.
      run clear-b1.
end.
else do:
   for each obj-list no-lock :
            for each gds-obj where
                gds-obj.obj-type = obj-list.obj-type    and
                gds-obj.obj-code = obj-list.obj-code
                and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
                 no-lock ,
              first  tmp#grp  where gds-obj.grp-name   begins tmp#grp.grp-name   no-lock ,
              first goods       where gds-obj.gds-code   = goods.gds-code  no-lock :
                  if not can-find(first temp-gds-list where temp-gds-list.gds-code = gds-obj.gds-code) then do:
                              create temp-gds-list.
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  gds-obj.gds-code
  ,input  '1':U
  ,input  ?
  ,input  v-cntxt-host-code-obj
  ,input  gds-obj.obj-type
  ,input  gds-obj.obj-code
  ,output var-vat-pc
  ) no-error .
                              assign
                                temp-gds-list.prod-code = gds-obj.prod-code
                                temp-gds-list.grp-name  = gds-obj.grp-name
                                temp-gds-list.gds-name  = goods.gds-name
                                temp-gds-list.gds-code  = gds-obj.gds-code
                                temp-gds-list.artic     = gds-obj.artic
                                temp-gds-list.vat-pc    = var-vat-pc
                              .
                  end.
            end.
  end.
  for each temp-gds-list no-lock
    , first goods     where goods.gds-code  = temp-gds-list.gds-code no-lock
      break by (func-vat(gds-obj.gds-code,gds-obj.obj-type,gds-obj.obj-code))  by goods.artic :
    run item-goods ( "6" , "goods" ) .
      if return-value <> "" then next.
        If Last-of((func-vat(gds-obj.gds-code,gds-obj.obj-type,gds-obj.obj-code))) Then Do:
        If String(Entry(2,"(func-vat(gds-obj.gds-code,gds-obj.obj-type,gds-obj.obj-code))",".")) = "Grp-name"
          Then  Assign
                  S-bar-code   = " Итого по "
                  Gds-zap-artic = Substring(
                                      B1-name
                                      ,1,16)
                  Gds-zap-gds-name = Substring(
                                      B1-name
                                      ,17,40)
                                .
          Else  Assign
                  S-bar-code   = ""
                  Gds-zap-artic = "        Итого по "
                  Gds-zap-gds-name =  B1-name
                                .
            Run Display-b1 In This-procedure .
            Run Clear-b1 In This-procedure .
            Assign Break_Group = True.
        End.
  end.
end.
  end.
        when 3  then do:
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if x-selectobject = "currency":u or xtog-obj then do:
define variable first-l22 as logical   no-undo .
  first-l22 = true .
  for  each gds-obj
      where gds-obj.obj-code   = x-store-code
        and gds-obj.obj-type   = x-store-type
            and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
            no-lock ,
  first g#cli
        where gds-obj.prod-code  = g#cli.obj-code
        and  gds-obj.prod-type   = g#cli.obj-type
        no-lock,
  first goods
        where gds-obj.gds-code = goods.gds-code no-lock
      break by func-vat (input gds-obj.gds-code , input x-store-type, input x-store-code)
            by (goods.artic)
            :
      var-vat-pc = func-vat ( input gds-obj.gds-code, input x-store-type, input x-store-code) .
      if last-vat <> var-vat-pc then do:
          if not first-l22 then do:
            Assign
                s-bar-code    = ""
                gds-zap-artic = "        Итого по "
                gds-zap-gds-name = b1-name
                .
              run display-b1.
              run clear-b1  .
          end.
          Assign
            first-l22 = false
            break_group = true
            break_group1 = true
            .
          end.
      first-l22 = false .
      run item-goods ( "6" , "goods" ) .
      last-vat = func-vat (input gds-obj.gds-code , input x-store-type, input x-store-code) .
   end.
    Assign
        s-bar-code   = ""
        gds-zap-artic = "        Итого по "
        gds-zap-gds-name = b1-name
        .
      run display-b1.
      run clear-b1.
  end.
  else do:
    for each obj-list no-lock :
          for  each gds-obj
            where  gds-obj.obj-code   = obj-list.obj-code
              and  gds-obj.obj-type   = obj-list.obj-type
              and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
            no-lock ,
          first g#cli
              where gds-obj.prod-code = g#cli.obj-code
              and   gds-obj.prod-type = g#cli.obj-type
              no-lock,
          first goods
              where gds-obj.gds-code = goods.gds-code no-lock :
                if not can-find (first temp-gds-list where temp-gds-list.gds-code = gds-obj.gds-code) then do:
                    create temp-gds-list.
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  gds-obj.gds-code
  ,input  '1':U
  ,input  ?
  ,input  v-cntxt-host-code-obj
  ,input  gds-obj.obj-type
  ,input  gds-obj.obj-code
  ,output var-vat-pc
  ) no-error .
                    assign
                      temp-gds-list.prod-code = gds-obj.prod-code
                      temp-gds-list.grp-name  = gds-obj.grp-name
                      temp-gds-list.gds-name  = goods.gds-name
                      temp-gds-list.gds-code  = gds-obj.gds-code
                      temp-gds-list.artic     = gds-obj.artic
                      temp-gds-list.vat-pc    = var-vat-pc
                    .
                end.
          end.
    end.
      for each temp-gds-list no-lock
        , first goods  where goods.gds-code  = temp-gds-list.gds-code no-lock
          break by (func-vat(gds-obj.gds-code,gds-obj.obj-type,gds-obj.obj-code))   by goods.artic :
        run item-goods ( "6" , "goods" ) .
          if return-value <> "" then next.
        If Last-of((func-vat(gds-obj.gds-code,gds-obj.obj-type,gds-obj.obj-code))) Then Do:
        If String(Entry(2,"(func-vat(gds-obj.gds-code,gds-obj.obj-type,gds-obj.obj-code))",".")) = "Grp-name"
          Then  Assign
                  S-bar-code   = " Итого по "
                  Gds-zap-artic = Substring(
                                      B1-name
                                      ,1,16)
                  Gds-zap-gds-name = Substring(
                                      B1-name
                                      ,17,40)
                                .
          Else  Assign
                  S-bar-code   = ""
                  Gds-zap-artic = "        Итого по "
                  Gds-zap-gds-name =  B1-name
                                .
            Run Display-b1 In This-procedure .
            Run Clear-b1 In This-procedure .
            Assign Break_Group = True.
        End.
      end.
end.
  end.
        otherwise do:
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
IF x-SelectObject = "currency":U  OR  xTog-obj then do :
define variable first-l24 as logical   no-undo .
  first-l24 = true .
  for each gds-obj
    where gds-obj.obj-type = x-store-type
      and gds-obj.obj-code = x-store-code
          and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
          no-lock,
      first goods  where  goods.gds-code = gds-obj.gds-code
      no-lock,
      First gds-list  where gds-list.gds-code =  gds-obj.gds-code
      no-lock
      break by func-vat (input gds-obj.gds-code , input x-store-type, input x-store-code)
            by (gds-list.artic)
            :
      var-vat-pc = func-vat ( input gds-obj.gds-code, input x-store-type, input x-store-code) .
      if last-vat <> var-vat-pc then do:
          if not first-l24 then do:
            Assign
                s-bar-code    = ""
                gds-zap-artic = "        Итого по "
                gds-zap-gds-name = b1-name
                .
              run display-b1.
              run clear-b1  .
          end.
          Assign
            first-l24 = false
            break_group = true
            break_group1 = true
            .
          end.
      first-l24 = false .
      run item-goods ( "6" , "gds-list" ) .
      last-vat = func-vat (input gds-obj.gds-code , input x-store-type, input x-store-code) .
   end.
    Assign
        s-bar-code   = ""
        gds-zap-artic = "        Итого по "
        gds-zap-gds-name = b1-name
        .
      run display-b1.
      run clear-b1.
end.
else do:
   For each obj-list no-lock :
                  FOR EACH gds-obj where
                      gds-obj.obj-type = obj-list.obj-type    and
                      gds-obj.obj-code = obj-list.obj-code
                      and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
                      no-lock,
                First gds-list  where gds-obj.gds-code  = gds-list.gds-code
                      no-lock :
                      find first temp-gds-list where temp-gds-list.gds-code = gds-obj.gds-code no-error .
                      if not available temp-gds-list then do:
                          find first goods no-lock  where goods.gds-code  = gds-obj.gds-code .
                          Create temp-gds-list.
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  gds-obj.gds-code
  ,input  '1':U
  ,input  ?
  ,input  v-cntxt-host-code-obj
  ,input  gds-obj.obj-type
  ,input  gds-obj.obj-code
  ,output var-vat-pc
  ) no-error .
                          Assign
                            temp-gds-list.prod-code = gds-obj.prod-code
                            temp-gds-list.grp-name  = gds-obj.grp-name
                            temp-gds-list.gds-name  = goods.gds-name
                            temp-gds-list.gds-code  = gds-obj.gds-code
                            temp-gds-list.artic     = gds-obj.artic
                            temp-gds-list.vat-pc    = var-vat-pc
                          .
                      End.
                      else do:
                      if temp-gds-list.vat-pc = 0 or temp-gds-list.vat-pc = ? then do:
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  gds-obj.gds-code
  ,input  '1':U
  ,input  ?
  ,input  v-cntxt-host-code-obj
  ,input  gds-obj.obj-type
  ,input  gds-obj.obj-code
  ,output var-vat-pc
  ) no-error .
                            Assign
                              temp-gds-list.vat-pc    = var-vat-pc
                            .
                      end.
                      end.
            End.
  End.
  for each temp-gds-list no-lock
    , First gds-list  where gds-list.gds-code  = temp-gds-list.gds-code no-lock
      BREAK BY (func-vat(gds-obj.gds-code,gds-obj.obj-type,gds-obj.obj-code))  BY gds-list.artic :
    run item-goods ( "6" , "gds-list" ) .
      if return-value <> "" then NEXT.
        If Last-of((func-vat(gds-obj.gds-code,gds-obj.obj-type,gds-obj.obj-code))) Then Do:
        If String(Entry(2,"(func-vat(gds-obj.gds-code,gds-obj.obj-type,gds-obj.obj-code))",".")) = "Grp-name"
          Then  Assign
                  S-bar-code   = " Итого по "
                  Gds-zap-artic = Substring(
                                      B1-name
                                      ,1,16)
                  Gds-zap-gds-name = Substring(
                                      B1-name
                                      ,17,40)
                                .
          Else  Assign
                  S-bar-code   = ""
                  Gds-zap-artic = "        Итого по "
                  Gds-zap-gds-name =  B1-name
                                .
            Run Display-b1 In This-procedure .
            Run Clear-b1 In This-procedure .
            Assign Break_Group = True.
        End.
  End.
End.
        end.
      end case.
end procedure.
PROCEDURE CalcItog :
    run ostatok (
        input x-store-code  ,
        input x-store-type  ,x-TOG-Shift,
        input x-date-start - 1 ,
        input date('')      , x-Shift-Start,x-Shift-End,
        input 'crsa':U   ,
        input '##,##':U,
        input xTog-obj ,
        output  Quantity1  ,
        output  Coast_R1   ,
        output  Coast_V1   ,
        output  VAT_R1     ,
        output  VAT_V1     ,
        output  Fact-order-1 ).
    run ostatok (
        input x-store-code  ,
        input x-store-type  , x-TOG-Shift,
        input x-date-start  ,
        input x-date-end    , x-Shift-Start,x-Shift-End,
        input 'crsa':U   ,
        input '##,##':U,
        input xTog-obj ,
        output  Quantity1  ,
        output  Coast_R1   ,
        output  Coast_V1   ,
        output  VAT_R1     ,
        output  VAT_V1     ,
        output  Fact-order-2 ).
          Quantity1  = 0.
          Coast_R1   = 0.
          Coast_V1   = 0.
          VAT_R1     = 0.
          VAT_V1     = 0.
END PROCEDURE.
PROCEDURE display-str1  :
           run di-qnty ("кол-во", 1, s-bar-code,gds-zap-artic,gds-zap-gds-name,gds-zap-unit-base,"").
         if xshowcost    then do: run di ( "учет.", 2,"","","","",""). end.
         if xshowcrsa    then do: run di ( "прод.", 5,"","","","","" ).  end.
         if xshowsale    then do: run di ( "док." , 8,"","","","","" ).  end.
         if vat-cost    then do: run di ( "уч.НДС", 3,"","","","","" ). end.
         if vat-crsa    then do: run di ( "пр.НДС", 6,"","","","","" ).  end.
         if vat-sale    then do: run di ( "дк.НДС", 9,"","","","","" ).  end.
end procedure.
procedure display-bi  :
           run di-qnty("кол-во",1,  "", gds-zap-artic ,"" ,"", "bi":u).
         if xshowcost    then do: run di ("учет." , 2 , "","", "", "", "bi":u).  end.
         if xshowcrsa    then do: run di ("прод." , 5, "","", "", "",  "bi":u).  end.
         if xshowsale    then do: run di ("док." , 8, "","", "", "",  "bi":u).  end.
         if vat-cost    then do: run di ( "уч.НДС", 3,"","","","","bi":u ). end.
         if vat-crsa    then do: run di ( "пр.НДС", 6,"","","","","bi":u ).  end.
         if vat-sale    then do: run di ( "дк.НДС", 9,"","","","","bi":u ).  end.
END PROCEDURE.
PROCEDURE display-Bo  :
           run di-qnty("кол-во",1,  "", "ИТОГО ПО" ,"ОБЪЕКТАМ" ,"", "bo":u).
         if xshowcost    then do: run di ("учет." , 2 , "","", "", "", "bo":u).  end.
         if xshowcrsa    then do: run di ("прод." , 5, "","", "", "",  "bo":u).  end.
         if xshowsale    then do: run di ("док." , 8, "","", "", "",  "bo":u).  end.
         if vat-cost    then do: run di ( "уч.НДС", 3,"","","","","bo":u ). end.
         if vat-crsa    then do: run di ( "пр.НДС", 6,"","","","","bo":u ).  end.
         if vat-sale    then do: run di ( "дк.НДС", 9,"","","","","bo":u ).  end.
end procedure.
PROCEDURE display-B1  :
      if NOT( NOT Show-Negativ-2 and
         ( b1-prih         [1]   = 0 AND
           b1-rash          [1]   = 0 AND
           b1-kassa         [1]   = 0 AND
           b1-Inv           [1]   = 0 AND
           b1-Overturn      [1]   = 0 AND
           b1-Overturn      [5]   = 0 AND
           b1-Overturn      [8]   = 0 ) ) then DO:
        IF  NOT (NOT Show-Negativ  AND (
              b1-prih          [1]   = 0 AND
              b1-rash          [1]   = 0 AND
              b1-kassa         [1]   = 0 AND
              b1-Inv           [1]   = 0 AND
              b1-Overturn      [1]   = 0 AND
              b1-Overturn      [5]   = 0 AND
              b1-ostatok-start [1]   = 0 AND
              b1-ostatok-End   [1]   = 0   )) then DO:
              if Sums-Only THEN do:
                  if fr0 = true then do:
                      PUT stream  OutStream  tmp#stroka0 format "X(100)" SKIP.
                      if Make-Excel then  put   stream ForExcel unformatted String(tmp#stroka0) skip.
                      fr0 = false .
                    end.
               end.
        run di-qnty in this-procedure ("кол-во"  ,1, s-bar-code, gds-zap-artic, gds-zap-gds-name ,"","b1":u).
        if xshowcost    then do: run di in this-procedure ("учет." ,2 ,"","", "", "", "b1":u).  end.
        if xshowcrsa    then do: run di in this-procedure ("прод." , 5, "","", "", "", "b1":u).  end.
        if xshowsale    then do: run di in this-procedure ("док." , 8, "","", "", "", "b1":u).  end.
        if vat-cost    then do: run di in this-procedure ( "уч.НДС", 3,"","","","","b1":u ). end.
        if vat-crsa    then do: run di in this-procedure ( "пр.НДС", 6,"","","","","b1":u ).  end.
        if vat-sale    then do: run di in this-procedure ( "дк.НДС", 9,"","","","","b1":u ).  end.
       if not sums-only then run p-line.
 End.
 end.
END PROCEDURE.
PROCEDURE display-B2  :
     if NOT( NOT Show-Negativ-2 and
         ( b2-prih         [1]   = 0 AND
           b2-rash          [1]   = 0 AND
           b2-kassa         [1]   = 0 AND
           b2-Inv           [1]   = 0 AND
           b2-Overturn      [1]   = 0 AND
           b2-Overturn      [5]   = 0 AND
           b2-Overturn      [8]   = 0 ) ) then DO:
        IF  NOT (NOT Show-Negativ  AND (
              b2-prih          [1]   = 0 AND
              b2-rash          [1]   = 0 AND
              b2-kassa         [1]   = 0 AND
              b2-Inv           [1]   = 0 AND
              b2-Overturn      [1]   = 0 AND
              b2-Overturn      [5]   = 0 AND
              b2-ostatok-start [1]   = 0 AND
              b2-ostatok-End   [1]   = 0   )) then DO:
        run di-qnty( "кол-во", 1 ,s-bar-code,gds-zap-artic, gds-zap-gds-name,"", "b2":u).
        if xshowcost    then do: run di ("учет.", 2, "","", "", "", "b2":u).  end.
        if xshowcrsa    then do: run di ("прод.", 5 ,"","", "", "", "b2":u).  end.
        if xshowsale    then do: run di ("док.", 8 ,"","", "", "", "b2":u).  end.
         if vat-cost    then do: run di ( "уч.НДС", 3,"","","","","b2":u ). end.
         if vat-crsa    then do: run di ( "пр.НДС", 6,"","","","","b2":u ).  end.
         if vat-sale    then do: run di ( "дк.НДС", 9,"","","","","b2":u ).  end.
 End.
end.
END PROCEDURE.
PROCEDURE Clear-B1  :
 b1-gds-zap-other           = 0.
 REPEAT kk = 1 to 9 :
 Assign
    b1-Prih                                            [kk]    = 0
    b1-Rash                                            [kk]    = 0
    b1-KAssa                                           [kk]    = 0
    b1-Inv                                             [kk]    = 0
    b1-Overturn                                        [kk]    = 0
    b1-ostatok-end                                     [kk]    = 0
    b1-ostatok-start                                   [kk]    = 0   .
   End.
 END PROCEDURE.
PROCEDURE Clear-B2  :
 b2-gds-zap-other           = 0.
 REPEAT kk = 1 to 9 :
 Assign
    b2-Prih                                            [kk]    = 0
    b2-Rash                                            [kk]    = 0
    b2-KAssa                                           [kk]    = 0
    b2-Inv                                             [kk]    = 0
    b2-Overturn                                        [kk]    = 0
    b2-ostatok-end                                     [kk]    = 0
    b2-ostatok-start                                   [kk]    = 0   .
   End.
END PROCEDURE.
PROCEDURE Clear-Bi  :
 bi-gds-zap-other           = 0.
 REPEAT kk = 1 to 9 :
 Assign
    bi-Prih                                            [kk]    = 0
    bi-Rash                                            [kk]    = 0
    bi-KAssa                                           [kk]    = 0
    bi-Inv                                             [kk]    = 0
    bi-Overturn                                        [kk]    = 0
    bi-ostatok-end                                     [kk]    = 0
    bi-ostatok-start                                   [kk]    = 0   .
   End.
END PROCEDURE.
PROCEDURE Display-title :
define variable v-nn as integer   no-undo .
   PUT stream  OutStream  UNFORMATTED  string( v-cntxt-host-name-obj +  " , " + x-store-type  +  " " + ObjName) AT 50 format "X(85)" SKIP(2)
          REPORTNAME  AT 20 format "X(170)" SKIP
          Trim(str1)  AT 35 format "X(75)" SKIP.
     v-nn = NUM-ENTRIES(str2,chr(10)) .
     Repeat i = 1 to v-nn:
      PUT stream  OutStream  UNFORMATTED  Entry(i,str2,chr(10))  AT 1 format "X(170)" SKIP.
     End.
    i=0.
       PUT stream  OutStream  UNFORMATTED  Trim(str3)  AT 35 format "X(75)" SKIP.
     v-nn = NUM-ENTRIES(str4,chr(10)).
     Repeat i = 1 to v-nn :
      PUT stream  OutStream  UNFORMATTED  Entry(i,str4,chr(10))  AT 1 format "X(170)" SKIP.
     End.
    i=0.
     v-nn = NUM-ENTRIES(ReportHeader,chr(10)) .
     Repeat i = 1 to v-nn :
      PUT stream  OutStream  UNFORMATTED  Entry(i,ReportHeader,chr(10))  AT 1 format "X(170)" SKIP.
     End.
    i=0.
    run rep/extitle.p (1) .
END PROCEDURE.
PROCEDURE ob-line  :
define input  parameter x-store-code   like ub.clients.obj-code     no-undo.
define input  parameter x-store-type   like ub.clients.obj-type     no-undo.
define INPUT  parameter x-artic        like ub.ot-line.artic        no-undo.
define INPUT  parameter x-prod-code    like ub.ot-line.prod-code    no-undo.
define INPUT  parameter x-prod-type    like ub.ot-line.prod-type    no-undo.
define INPUT  parameter x-Fact-order-1   like ub.ot-line.Fact-order   no-undo.
define INPUT  parameter x-Fact-order-2   like ub.ot-line.Fact-order   no-undo.
define input  parameter x-sum-type       like ub.ot-line.sum-type     no-undo.
define input  parameter x-cat-id         like ub.ot-line.cat-id       no-undo.
define input  parameter x-ext-doc-type   like ub.ot-line.ext-doc-type no-undo.
define input  parameter xTog-obj           as log no-undo.
define variable  tt#          as   int                 no-undo.
 if (x-sum-type = 'cost':U  or x-sum-type = 'cssr':U) then tt# = 0.
 if (x-sum-type = 'crsa':U  or x-sum-type = 'cgsr':U) then tt# = 3.
 if (x-sum-type = 'sale':U  or x-sum-type = 'sasr':U) then tt# = 6.
     FOR each ub.ot-line where
                        ub.ot-line.artic         = x-artic
                  AND   ub.ot-line.fact-order   <= x-fact-order-2
                  AND   ub.ot-line.fact-order   >= x-fact-order-1
                  AND   ub.ot-line.obj-code     = x-store-code
                  AND   ub.ot-line.obj-type     = x-store-type
                  AND   ub.ot-line.prod-code    = x-prod-code
                  AND   ub.ot-line.prod-type    = x-prod-type
                  AND   ub.ot-line.sum-type     = x-sum-type
                    no-lock :
    CASE ub.ot-line.ext-doc-type:
              WHEN        'ie':U  OR
              WHEN        're':U  OR
              WHEN        'iv':U    OR
              WHEN        'rv':U OR
              WHEN        'im':U     THEN
              DO:
              ASSIGN prih[1 + tt#]   = prih[1 + tt#]   +  ub.ot-line.fact-qnty
                     prih[2 + tt#]   = prih[2 + tt#]   +  if tPrintRubl then ub.ot-line.sum-rubl Else  ub.ot-line.sum-base
                     prih[3 + tt#]   = prih[3 + tt#]   +  if tPrintRubl then ub.ot-line.VAT-rubl Else  ub.ot-line.VAT-base  .
              if tt# = 6 then gds-zap-other  = gds-zap-other   +   (if tPrintRubl then ub.ot-line.other-rubl  Else  ub.ot-line.other-base ) .
              End.
              WHEN       'ee':U      OR
              WHEN       'ep':U    OR
              WHEN       'ev':U     OR
              WHEN       'em':U       OR
              WHEN       'wm':U       OR
              WHEN       'we':U     THEN
              DO:
              ASSIGN  rash[1 + tt#]   = rash[1 + tt#]   +  ub.ot-line.fact-qnty
                      rash[2 + tt#]   = rash[2 + tt#]   +  if tPrintRubl then ub.ot-line.sum-rubl Else  ub.ot-line.sum-base
                      rash[3 + tt#]   = rash[3 + tt#]   +  if tPrintRubl then ub.ot-line.VAT-rubl Else  ub.ot-line.VAT-base  .
              if tt# = 6 then gds-zap-other  = gds-zap-other   +   (if tPrintRubl then ub.ot-line.other-rubl  Else  ub.ot-line.other-base ) .
              End.
              WHEN       'es':U  OR
              WHEN       'rs':U THEN
              DO:
              ASSIGN kassa[1 + tt#]   = kassa[1 + tt#]   +  ub.ot-line.fact-qnty
                     kassa[2 + tt#]   = kassa[2 + tt#]   +  if tPrintRubl then ub.ot-line.sum-rubl Else  ub.ot-line.sum-base
                     kassa[3 + tt#]   = kassa[3 + tt#]   +  if tPrintRubl then ub.ot-line.VAT-rubl Else  ub.ot-line.VAT-base  .
              if tt# = 6 then gds-zap-other  = gds-zap-other   +   (if tPrintRubl then ub.ot-line.other-rubl  Else  ub.ot-line.other-base ) .
              End.
          WHEN  'vt':U or when 'vp':U     THEN
              DO:
              ASSIGN INV[1 + tt#]   = INV[1 + tt#]   +  ub.ot-line.fact-qnty
                    inv[2 + tt#]   = inv[2 + tt#]   +  if tPrintRubl then ub.ot-line.sum-rubl Else  ub.ot-line.sum-base
                    Inv[3 + tt#]   = Inv[3 + tt#]   +  if tPrintRubl then ub.ot-line.VAT-rubl Else  ub.ot-line.vat-base  .
              if tt# = 6 then gds-zap-other  = gds-zap-other   +   (if tPrintRubl then ub.ot-line.other-rubl  Else  ub.ot-line.other-base ) .
              End.
          WHEN       'ot':U THEN
              DO:
              ASSIGN Overturn[1 + tt#]   = Overturn[1 + tt#]   +  ub.ot-line.fact-qnty
                    Overturn[2 + tt#]   = Overturn[2 + tt#]   +  if tPrintRubl then ub.ot-line.sum-rubl Else  ub.ot-line.sum-base
                    Overturn[3 + tt#]   = Overturn[3 + tt#]   +  if tPrintRubl then ub.ot-line.vat-rubl Else  ub.ot-line.vat-base  .
              if tt# = 6 then gds-zap-other  = gds-zap-other   +   (if tPrintRubl then ub.ot-line.other-rubl  Else  ub.ot-line.other-base ) .
              End.
      End CASE.
  END.
  if tt# = 6 then DO:
           ASSIGN Overturn[1 + tt#]   = (Ostatok-end[1 + tt#]  - Ostatok-start[1 + tt#] )  -  (INV[1 + tt#] + prih[1 + tt#]   +  kassa[1 + tt#]  +  rash[1 + tt#]  )
                  Overturn[2 + tt#]   = (Ostatok-end[2 + tt#]  - Ostatok-start[2 + tt#] )  -  (inv[2 + tt#] + prih[2 + tt#]   +  kassa[2 + tt#]  +  rash[2 + tt#]  )
                  Overturn[3 + tt#]   = (Ostatok-end[3 + tt#]  - Ostatok-start[3 + tt#] )  -  (Inv[3 + tt#] + prih[3 + tt#]   +  kassa[3 + tt#]  +  rash[3 + tt#]  )  .
  End.
END PROCEDURE.
procedure ost-line :
  define input  parameter x-store-code like ub.clients.obj-code    no-undo .
  define input  parameter x-store-type like ub.clients.obj-type    no-undo .
  define input  parameter x-artic      like ub.stk-line.artic      no-undo .
  define input  parameter x-prod-code  like ub.stk-line.prod-code  no-undo .
  define input  parameter x-prod-type  like ub.stk-line.prod-type  no-undo .
  define input  parameter x-tog-shift  as logical no-undo .
  define input  parameter x-fact-order like ub.stk-line.fact-order no-undo .
  define input  parameter x-sum-type   like ub.stk-line.sum-type   no-undo .
  define input  parameter x-cat-id     like ub.stk-line.cat-id     no-undo .
  define input  parameter xtog-obj     as logical no-undo .
  define output parameter quantity     like ub.stk-line.fact-qnty  no-undo .
  define output parameter coast_r      like ub.stk-line.sum-rubl   no-undo .
  define output parameter coast_v      like ub.stk-line.sum-rubl   no-undo .
  define output parameter vat_r        like ub.stk-line.sum-rubl   no-undo .
  define output parameter vat_v        like ub.stk-line.sum-rubl   no-undo .
  define output parameter slt_r        like ub.stk-line.sum-rubl   no-undo .
  define output parameter slt_v        like ub.stk-line.sum-rubl   no-undo .
  define buffer buff-obj-list  for obj-list .
  define buffer buff-stk-line  for ub.stk-line .
  assign
    Quantity = 0
    Coast_R  = 0
    Coast_V  = 0
    VAT_R    = 0
    VAT_V    = 0
    SLT_R    = 0
    SLT_V    = 0
  .
  if  x-tog-shift = false then do:
    for each buff-obj-list no-lock
      where xtog-obj = false
         or (buff-obj-list.obj-type = x-store-type
            and buff-obj-list.obj-code = x-store-code
            )
    on error undo, return error
    :
    find last buff-stk-line no-lock
      where buff-stk-line.obj-type   = buff-obj-list.obj-type
        and buff-stk-line.obj-code   = buff-obj-list.obj-code
        and buff-stk-line.artic      = x-artic
        and buff-stk-line.prod-type  = x-prod-type
        and buff-stk-line.prod-code  = x-prod-code
        and buff-stk-line.sum-type   = x-sum-type
        and buff-stk-line.cat-id     = '##,##':U
        and buff-stk-line.fact-order <= x-fact-order
        and buff-stk-line.shift-num  = 0
      use-index category
      no-error .
    if available buff-stk-line then do:
      assign
        Quantity = Quantity + buff-stk-line.fact-qnty
        Coast_R  = Coast_R  + buff-stk-line.sum-rubl
        Coast_V  = Coast_V  + buff-stk-line.sum-base
        VAT_R    = VAT_R    + buff-stk-line.VAT-rubl
        VAT_V    = VAT_V    + buff-stk-line.VAT-base
        SLT_R    = SLT_R    + buff-stk-line.SLT-rubl
        SLT_V    = SLT_V    + buff-stk-line.SLT-base
      .
    end.
   end.
  end.
  else do:
    for each buff-obj-list no-lock
      where xtog-obj = false
         or (buff-obj-list.obj-type = x-store-type
            and buff-obj-list.obj-code = x-store-code
            )
    on error undo, return error
    :
      find last buff-stk-line no-lock
        where buff-stk-line.obj-type   = buff-obj-list.obj-type
          and buff-stk-line.obj-code   = buff-obj-list.obj-code
          and buff-stk-line.artic      = x-artic
          and buff-stk-line.prod-type  = x-prod-type
          and buff-stk-line.prod-code  = x-prod-code
          and buff-stk-line.sum-type   = x-sum-type
          and buff-stk-line.cat-id     = '##,##':U
          and buff-stk-line.fact-order <= x-fact-order
          and buff-stk-line.shift-num  > 0
        use-index category
        no-error .
      if available buff-stk-line then do:
        assign
          Quantity = Quantity +  buff-stk-line.fact-qnty
          Coast_R  = Coast_R  +  buff-stk-line.sum-rubl
          Coast_V  = Coast_V  +  buff-stk-line.sum-base
          VAT_R    = VAT_R    +  buff-stk-line.VAT-rubl
          VAT_V    = VAT_V    +  buff-stk-line.VAT-base
          SLT_R    = SLT_R    +  buff-stk-line.SLT-rubl
          SLT_V    = SLT_V    +  buff-stk-line.SLT-base
        .
      end.
    end.
  end.
end procedure.
procedure ost-lineother-tax :
  define input  parameter x-store-code like ub.clients.obj-code      no-undo.
  define input  parameter x-store-type like ub.clients.obj-type      no-undo.
  define input  parameter x-artic      like ub.stk-line.artic        no-undo.
  define input  parameter x-prod-code  like ub.stk-line.prod-code    no-undo.
  define input  parameter x-prod-type  like ub.stk-line.prod-type    no-undo.
  define input  parameter x-tog-shift  as logical no-undo .
  define input  parameter x-fact-order like ub.stk-line.fact-order   no-undo.
  define input  parameter x-sum-type   like ub.stk-line.sum-type     no-undo.
  define input  parameter x-type-id    like ub.stk-line.cat-id       no-undo.
  define input  parameter xTog-obj     as logical no-undo .
  define output parameter Quantity     like ub.stk-line.fact-qnty   no-undo.
  define output parameter Coast_R      like ub.stk-line.sum-rubl    no-undo.
  define output parameter Coast_V      like ub.stk-line.sum-rubl    no-undo.
  define output parameter VAT_R        like ub.stk-line.sum-rubl    no-undo.
  define output parameter VAT_V        like ub.stk-line.sum-rubl    no-undo.
  define output parameter SLT_R        like ub.stk-line.sum-rubl    no-undo.
  define output parameter SLT_V        like ub.stk-line.sum-rubl    no-undo.
  define output parameter other_R      like ub.stk-line.sum-rubl    no-undo.
  define output parameter other_V      like ub.stk-line.sum-rubl    no-undo.
  define buffer buff-obj-list  for obj-list .
  define buffer buff-stk-line  for ub.stk-line .
  assign
    Quantity = 0
    Coast_R  = 0
    Coast_V  = 0
    VAT_R    = 0
    VAT_V    = 0
    SLT_R    = 0
    SLT_V    = 0
    other_R  = 0
    other_V  = 0
  .
  if  x-tog-shift = false then do:
    for each buff-obj-list no-lock
      where xtog-obj = false
         or (buff-obj-list.obj-type = x-store-type
            and buff-obj-list.obj-code = x-store-code
            )
    on error undo, return error
    :
    find last buff-stk-line no-lock
      where buff-stk-line.obj-type   = buff-obj-list.obj-type
        and buff-stk-line.obj-code   = buff-obj-list.obj-code
        and buff-stk-line.artic      = x-artic
        and buff-stk-line.prod-type  = x-prod-type
        and buff-stk-line.prod-code  = x-prod-code
        and buff-stk-line.sum-type   = x-sum-type
        and buff-stk-line.cat-id     = '##,##':U
        and buff-stk-line.fact-order <= x-fact-order
        and buff-stk-line.shift-num  = 0
      use-index category
      no-error .
    if available buff-stk-line then do:
      assign
        Quantity = Quantity + buff-stk-line.fact-qnty
        Coast_R  = Coast_R  + buff-stk-line.sum-rubl
        Coast_V  = Coast_V  + buff-stk-line.sum-base
        VAT_R    = VAT_R    + buff-stk-line.VAT-rubl
        VAT_V    = VAT_V    + buff-stk-line.VAT-base
        SLT_R    = SLT_R    + buff-stk-line.SLT-rubl
        SLT_V    = SLT_V    + buff-stk-line.SLT-base
        other_R  = other_R  + buff-stk-line.other-rubl
        other_V  = other_V  + buff-stk-line.other-base
      .
    end.
 end.
  end.
  else do:
    for each buff-obj-list no-lock
      where xtog-obj = false
         or (buff-obj-list.obj-type = x-store-type
            and buff-obj-list.obj-code = x-store-code
            )
    on error undo, return error
    :
      find last buff-stk-line no-lock
        where buff-stk-line.obj-type   = buff-obj-list.obj-type
          and buff-stk-line.obj-code   = buff-obj-list.obj-code
          and buff-stk-line.artic      = x-artic
          and buff-stk-line.prod-type  = x-prod-type
          and buff-stk-line.prod-code  = x-prod-code
          and buff-stk-line.sum-type   = x-sum-type
          and buff-stk-line.cat-id     = '##,##':U
          and buff-stk-line.fact-order <= x-fact-order
          and buff-stk-line.shift-num  > 0
        use-index category
        no-error .
      if available buff-stk-line then do:
        assign
          Quantity = Quantity +  buff-stk-line.fact-qnty
          Coast_R  = Coast_R  +  buff-stk-line.sum-rubl
          Coast_V  = Coast_V  +  buff-stk-line.sum-base
          VAT_R    = VAT_R    +  buff-stk-line.VAT-rubl
          VAT_V    = VAT_V    +  buff-stk-line.VAT-base
          SLT_R    = SLT_R    +  buff-stk-line.SLT-rubl
          SLT_V    = SLT_V    +  buff-stk-line.SLT-base
          other_R = other_R   +  buff-stk-line.other-rubl
          other_V = other_V   +  buff-stk-line.other-base
        .
      end.
    end.
  end.
end procedure.
procedure ost-line-kg :
  define  input parameter p-obj-code    like ub.stk-line.obj-code   no-undo .
  define  input parameter p-obj-type    like ub.stk-line.obj-type   no-undo .
  define  input parameter p-artic       like ub.stk-line.artic      no-undo .
  define  input parameter p-prod-code   like ub.stk-line.prod-code  no-undo .
  define  input parameter p-prod-type   like ub.stk-line.prod-type  no-undo .
  define  input parameter p-fact-order  like ub.stk-line.fact-order no-undo .
  define output parameter p-quantity-kg like ub.stk-line.fact-qnty  no-undo initial 0.00 .
  define buffer buff-obj-list  for obj-list .
  define buffer buf_doc-line for ub.doc-line .
  define buffer buf_inv-line for ub.inv-line .
  do
  on error undo, return error
  :
    for each buf_doc-line no-lock where
             buf_doc-line.obj-type    = p-obj-type   and
             buf_doc-line.obj-code    = p-obj-code   and
             buf_doc-line.prod-type   = p-prod-type  and
             buf_doc-line.prod-code   = p-prod-code  and
             buf_doc-line.artic       = p-artic      and
             buf_doc-line.status_     = 'факт':U      and
             buf_doc-line.fact-order <= p-fact-order
          by buf_doc-line.fact-order    descending
    :
      find first buf_inv-line no-lock where
                 buf_inv-line.doc-code  = buf_doc-line.doc-code  and
                 buf_inv-line.artic     = buf_doc-line.artic     and
                 buf_inv-line.prod-type = buf_doc-line.prod-type and
                 buf_inv-line.prod-code = buf_doc-line.prod-code no-error .
      if available buf_inv-line
      then do:
        if buf_inv-line.after-cli-qnty <> ?
        then do:
          assign
            p-quantity-kg = buf_inv-line.after-cli-qnty
          .
          leave .
        end.
      end.
    end.
    if p-quantity-kg = ?
    then do:
      assign
        p-quantity-kg = 0
      .
    end.
  end.
end procedure.
PROCEDURE ostatok :
def input parameter x-store-code  like ub.clients.obj-code    no-undo.
def input parameter x-store-type  like ub.clients.obj-type    no-undo.
def input parameter x-tog-shift   as   logical             no-undo.
def input parameter x-date-start  like ub.stk-tot.Fact-date   no-undo.
def input parameter x-date-end    like ub.stk-tot.Fact-date   no-undo.
def input parameter x-shift-start as integer               no-undo.
def input parameter x-shift-end   as integer               no-undo.
def input parameter x-sum-type    like ub.stk-tot.sum-type    no-undo.
def input parameter x-cat-id      like ub.stk-tot.cat-id      no-undo.
def input parameter xTog-obj   as log no-undo.
def output parameter Quantity    like ub.stk-tot.fact-qnty   no-undo.
def output parameter Coast_R     like ub.stk-tot.sum-rubl    no-undo.
def output parameter Coast_V     like ub.stk-tot.sum-rubl    no-undo.
def output parameter VAT_R       like ub.stk-tot.sum-rubl    no-undo.
def output parameter VAT_V       like ub.stk-tot.sum-rubl    no-undo.
def output parameter Fact-order  like ub.stk-tot.Fact-order  no-undo.
def var              Fact-order#   like ub.stk-tot.Fact-order  no-undo.
def var              Fact-orderS   as char  no-undo.
def var x-date-start-t  like ub.stk-tot.shift-date   no-undo.
   Assign
      Fact-order   = 0
      Quantity     = 0
      Coast_R      = 0
      Coast_V      = 0
      VAT_R        = 0
      VAT_V        = 0 .
 x-date-start-t  = x-date-start + 1 .
IF x-date-end = date('') then DO:
   Fact-order = 0 .
   for each obj-list
       where  ( not xtog-obj or
              ( x-store-type = obj-list.obj-type and x-store-code = obj-list.obj-code ))
              no-lock :
      if  x-tog-shift = false then do:
                       find last ub.stk-tot where ub.stk-tot.obj-type = obj-list.obj-type and                             ub.stk-tot.obj-code = obj-list.obj-code and                             ub.stk-tot.sum-type = x-sum-type and                             ub.stk-tot.cat-id   = x-cat-id   and
                            ub.stk-tot.Fact-date <=  x-date-start
                            and ub.stk-tot.shift-num = 0
                            USE-INDEX fact-date no-lock no-error .
           if Available ub.stk-tot THEN  Assign                           Quantity     = Quantity   + ub.stk-tot.fact-qnty                           Coast_R      = Coast_R    + ub.stk-tot.sum-rubl                           Coast_V      = Coast_V    + ub.stk-tot.sum-base                           VAT_R        = VAT_R      + ub.stk-tot.VAT-rubl                           VAT_V        = VAT_V      + ub.stk-tot.VAT-base                           Fact-order#  = ub.stk-tot.Fact-order.
      End.
      Else  DO :
          find last ub.stk-tot where ub.stk-tot.obj-type = obj-list.obj-type and                             ub.stk-tot.obj-code = obj-list.obj-code and                             ub.stk-tot.sum-type = x-sum-type and                             ub.stk-tot.cat-id   = x-cat-id   and
           (ub.stk-tot.shift-date  = x-date-start-t and
            ub.stk-tot.shift-num  < x-shift-start or
            ub.stk-tot.shift-date  < x-date-start-t  )
            and ub.stk-tot.shift-num  > 0
            USE-INDEX Shift-num no-lock no-error .
         If Available ub.stk-tot then  Assign                           Quantity     = Quantity   + ub.stk-tot.fact-qnty                           Coast_R      = Coast_R    + ub.stk-tot.sum-rubl                           Coast_V      = Coast_V    + ub.stk-tot.sum-base                           VAT_R        = VAT_R      + ub.stk-tot.VAT-rubl                           VAT_V        = VAT_V      + ub.stk-tot.VAT-base                           Fact-order#  = ub.stk-tot.Fact-order.
        END.
    If Fact-order < Fact-order#  and Fact-order# <> 0  THEN  Fact-order = Fact-order# .
  End.
End.
Else DO:
  For each obj-list  WHERE
     (NOT xTog-obj OR (x-store-type = obj-list.obj-type AND x-store-code = obj-list.obj-code))
      no-lock :
   IF  x-TOG-Shift = False Then DO:
       find last ub.stk-tot where ub.stk-tot.obj-type = obj-list.obj-type and                             ub.stk-tot.obj-code = obj-list.obj-code and                             ub.stk-tot.sum-type = x-sum-type and                             ub.stk-tot.cat-id   = x-cat-id   and
            ub.stk-tot.Fact-date <= x-date-end
            and ub.stk-tot.shift-num = 0
            USE-INDEX fact-date no-lock no-error.
       if available ub.stk-tot then  Assign                           Quantity     = Quantity   + ub.stk-tot.fact-qnty                           Coast_R      = Coast_R    + ub.stk-tot.sum-rubl                           Coast_V      = Coast_V    + ub.stk-tot.sum-base                           VAT_R        = VAT_R      + ub.stk-tot.VAT-rubl                           VAT_V        = VAT_V      + ub.stk-tot.VAT-base                           Fact-order#  = ub.stk-tot.Fact-order.
   END.
   Else DO:
        find last ub.stk-tot where ub.stk-tot.obj-type = obj-list.obj-type and                             ub.stk-tot.obj-code = obj-list.obj-code and                             ub.stk-tot.sum-type = x-sum-type and                             ub.stk-tot.cat-id   = x-cat-id   and
            (ub.stk-tot.shift-date  = x-date-end and
            ub.stk-tot.shift-num  <= x-shift-end or
            ub.stk-tot.shift-date  < x-date-end       ) and
            ub.stk-tot.shift-num   > 0      use-index shift-num no-lock no-error.
            if Available ub.stk-tot THEN Assign                           Quantity     = Quantity   + ub.stk-tot.fact-qnty                           Coast_R      = Coast_R    + ub.stk-tot.sum-rubl                           Coast_V      = Coast_V    + ub.stk-tot.sum-base                           VAT_R        = VAT_R      + ub.stk-tot.VAT-rubl                           VAT_V        = VAT_V      + ub.stk-tot.VAT-base                           Fact-order#  = ub.stk-tot.Fact-order.
    End.
    if Fact-order < Fact-order#  THEN  Fact-order = Fact-order#.
  End.
End.
END PROCEDURE.
PROCEDURE report-exec1  :
   FIND FIRST clients where x-store-type = clients.obj-type AND
                            x-store-code = clients.obj-code no-lock no-error.
  run waitfram-show(clients.obj-name) .
  run calcitog.
  run print-header.
   case retclassify :
     when "vat-ps":u         then run run7.
     otherwise do:
       message "Ошибка вызова!"  view-as alert-box error .
     end.
   end case.
  run print-footer.
  END PROCEDURE.
PROCEDURE Calc-Sub-itog :
define input parameter tt as int no-undo.
define variable b as int no-undo.
if tt = 6  then Assign
  B1-gds-zap-other = B1-gds-zap-other +  gds-zap-other
  B2-gds-zap-other = B2-gds-zap-other +  gds-zap-other
  Bi-gds-zap-other = Bi-gds-zap-other +  gds-zap-other
  Bo-gds-zap-other = Bo-gds-zap-other +  gds-zap-other
  .
repeat b = 1 to 3:
  Assign
  B1-Prih[b + TT]    = B1-Prih[b + TT]    +  Prih[b + TT]
  B2-Prih[b + TT]    = B2-Prih[b + TT]    +  Prih[b + TT]
  Bi-Prih[b + TT]    = Bi-Prih[b + TT]    +  Prih[b + TT]
  Bo-Prih[b + TT]    = Bo-Prih[b + TT]    +  Prih[b + TT]
  Bo-ostatok-start[b + TT]    = Bo-ostatok-start[b + TT]    +  ostatok-start[b + TT]
  Bo-ostatok-end[b + TT]      = Bo-ostatok-end[b + TT]      +  ostatok-end[b + TT]
  B1-RAsh[b + TT]    = B1-RAsh[b + TT]    +  RAsh[b + TT]
  B2-RAsh[b + TT]    = B2-RAsh[b + TT]    +  RAsh[b + TT]
  Bi-RAsh[b + TT]    = Bi-RAsh[b + TT]    +  RAsh[b + TT]
  Bo-RAsh[b + TT]    = Bo-RAsh[b + TT]    +  RAsh[b + TT]
  B1-KAssa[b + TT]    = B1-KAssa[b + TT]    +  KAssa[b + TT]
  B2-kassa[b + TT]    = B2-kassa[b + TT]    +  kassa[b + TT]
  Bi-Kassa[b + TT]    = Bi-Kassa[b + TT]    +  Kassa[b + TT]
  Bo-Kassa[b + TT]    = Bo-Kassa[b + TT]    +  Kassa[b + TT]
  B1-Inv[b + TT]    = B1-Inv[b + TT]    +  Inv[b + TT]
  B2-Inv[b + TT]    = B2-Inv[b + TT]    +  Inv[b + TT]
  Bi-Inv[b + TT]    = Bi-Inv[b + TT]    +  Inv[b + TT]
  Bo-Inv[b + TT]    = Bo-Inv[b + TT]    +  Inv[b + TT]
  B1-Overturn[b + TT]    = B1-Overturn[b + TT]    +  Overturn[b + TT]
  B2-Overturn[b + TT]    = B2-Overturn[b + TT]    +  Overturn[b + TT]
  Bi-Overturn[b + TT]    = Bi-Overturn[b + TT]    +  Overturn[b + TT]
  Bo-Overturn[b + TT]    = Bo-Overturn[b + TT]    +  Overturn[b + TT] .
End.
END PROCEDURE.
PROCEDURE Clear-item :
define variable kk as int no-undo.
 gds-zap-other = 0 .
 REPEAT kk = 1 to 9 :
 Assign
    prih            [kk]    = 0
    rash            [kk]    = 0
    kassa           [kk]    = 0
    Inv             [kk]    = 0
    Overturn        [kk]    = 0
    ostatok-end     [kk]    = 0
    ostatok-start   [kk]    = 0 .
       End.
 END PROCEDURE.
PROCEDURE Item-Goods :
   define input parameter  par-3 as char no-undo.
   define input parameter  par-4 as char no-undo.
     if par-4 = "goods":U  Then DO:
        assign
            gds-zap-unit-base  = Goods.unit-base
            gds-zap-prt-root   = Goods.prt-root
            gds-zap-prod-type  = Goods.prod-type
            gds-zap-prod-code  = Goods.prod-code
            gds-zap-artic      = Goods.artic
            gds-zap-grp-name   = Goods.grp-name
            gds-zap-b-code     = Goods.gds-code
            gds-zap-type       = Goods.gds-type.
        if g#gds-engl then
            assign gds-zap-gds-name = Goods.engl-name.
        else
            assign gds-zap-gds-name = Goods.gds-name.
     End.
     if par-4 = "gds-list":U  Then DO:
        assign
            gds-zap-unit-base  = gds-list.unit-base
            gds-zap-prt-root   = gds-list.prt-root
            gds-zap-prod-type  = gds-list.prod-type
            gds-zap-prod-code  = gds-list.prod-code
            gds-zap-artic      = gds-list.artic
            gds-zap-grp-name   = gds-list.grp-name
            gds-zap-b-code     = gds-list.gds-code
            gds-zap-type       = gds-list.gds-type.
        if g#gds-engl then
            assign gds-zap-gds-name = gds-list.engl-name.
        else
            assign gds-zap-gds-name = gds-list.gds-name.
     End.
    run foreach.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  gds-zap-b-code
  ,input  ?
  ,output v-bar-code
  )  .
s-bar-code = string (v-bar-code,"999999999").
    If  break_group = true  and par-3 <> "1"  then DO :
         FIND FIRST clients WHERE clients.obj-type = gds-zap-prod-type AND clients.obj-code = gds-zap-prod-code use-index pi NO-LOCK .
         gds-zap-prod-name  = clients.obj-name.
          If break_group1 = true  THEN  DO :
            if (par-3 = "3"  OR  par-3 = "5" ) and  par-3 <> "6"
              then DO: Assign temp-str = string("ГРУППА : " + gds-zap-grp-name )         b1-name = gds-zap-grp-name . end.
              else DO: Assign temp-str = string("ПРОИЗВОДИТЕЛЬ : " + gds-zap-prod-name ) b1-name = gds-zap-prod-name. end.
            if par-3 = "6"  then  dO:
               if xTog-obj = true then do:
                 var-vat-pc = func-vat (input gds-zap-b-code , input x-store-type, input x-store-code)
                  .
                end.
               else do:
                var-vat-pc = temp-gds-list.vat-pc .
                end.
                assign
                    temp-str = string( "СТАВКА НДС : " + string(var-vat-pc) + "%" )
                    b1-name = temp-str.
                end.
            if NOT xSumsOnly or (par-3 = "4" Or par-3 = "5" ) THEN DO :
                fr0 = true .
                tmp#stroka0 = temp-str.
            End.
          End.
            IF (par-3 = "4"  OR  par-3 = "5")  THEN DO:
              if par-3 = "4"
                then Assign temp-str = string("ГРУППА : " + gds-zap-grp-name )          b2-name = gds-zap-grp-name .
                else Assign temp-str = string("ПРОИЗВОДИТЕЛЬ : " + gds-zap-prod-name )  b2-name = gds-zap-prod-name.
              if NOT xSumsOnly THEN DO:
                  fr = true .
              End.
              break_group1 = false.
            END.
       break_group = false.
    End.
    run display-line.
 END PROCEDURE.
PROCEDURE Di :
define input parameter p1 as char no-undo.
define input parameter p2 as int no-undo.
define input parameter p3 as char no-undo.
define input parameter p4 as char no-undo.
define input parameter p5 as char no-undo.
define input parameter p6 as char no-undo.
define input parameter p7 as char no-undo.
 CASE CAPS(p7) :
   WHEN "B1":U  Then DO:
    DISPLAY stream  OutStream sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12
      p3 @ s-bar-code
      p4 @ gds-zap-artic
      p5 @ gds-zap-gds-name
      p6 @ gds-zap-unit-base
      p1 @ gds-type
      b1-ostatok-start [p2] format "->>>>>>>>>>9.<<" @  F-ostatok-start
      b1-Prih          [p2] format "->>>>>>>>>>9.<<" @  F-Prih
      b1-RAsh          [p2] format "->>>>>>>>>>9.<<" @  F-RAsh
      b1-KAssa         [p2] format "->>>>>>>>>>9.<<" @  F-KAssa
      b1-Inv           [p2] format "->>>>>>>>>>9.<<" @  F-Inv
      b1-Overturn      [p2] format "->>>>>>>>>>9.<<" @  F-Overturn
      b1-Ostatok-end   [p2] format "->>>>>>>>>>9.<<" @  F-Ostatok-end
      b1-gds-zap-other      format "->>>>>>>>>>9.<<" when (p2 = 1) @  gds-zap-other
      with FRAME ZAPAS .
               DOWN stream   OutStream 1 with FRAME ZAPAS.
                End.
   WHEN "B2":U  Then  DO:
    DISPLAY stream  OutStream sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12
      p3 @ s-bar-code
      p4 @ gds-zap-artic
      p5 @ gds-zap-gds-name
      p6 @ gds-zap-unit-base
      p1 @ gds-type
      b2-ostatok-start [p2] format "->>>>>>>>>>9.<<" @  F-ostatok-start
      b2-Prih          [p2] format "->>>>>>>>>>9.<<" @  F-Prih
      b2-RAsh          [p2] format "->>>>>>>>>>9.<<" @  F-RAsh
      b2-KAssa         [p2] format "->>>>>>>>>>9.<<" @  F-KAssa
      b2-Inv           [p2] format "->>>>>>>>>>9.<<" @  F-Inv
      b2-Overturn      [p2] format "->>>>>>>>>>9.<<" @  F-Overturn
      b2-Ostatok-end   [p2] format "->>>>>>>>>>9.<<" @  F-Ostatok-end
      b2-gds-zap-other      format "->>>>>>>>>>9.<<" when (p2 = 1) @  gds-zap-other
      with FRAME ZAPAS .
               DOWN stream   OutStream 1 with FRAME ZAPAS.
              End.
   WHEN "BI":U Then  DO:
    DISPLAY stream  OutStream sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12
      p3 @ s-bar-code
      p4 @ gds-zap-artic
      p5 @ gds-zap-gds-name
      p6 @ gds-zap-unit-base
      p1 @ gds-type
      bi-ostatok-start [p2] format "->>>>>>>>>>9.<<" @  F-ostatok-start
      bi-Prih          [p2] format "->>>>>>>>>>9.<<" @  F-Prih
      bi-RAsh          [p2] format "->>>>>>>>>>9.<<" @  F-RAsh
      bi-KAssa         [p2] format "->>>>>>>>>>9.<<" @  F-KAssa
      bi-Inv           [p2] format "->>>>>>>>>>9.<<" @  F-Inv
      bi-Overturn      [p2] format "->>>>>>>>>>9.<<" @  F-Overturn
      bi-Ostatok-end   [p2] format "->>>>>>>>>>9.<<" @  F-Ostatok-end
      bi-gds-zap-other      format "->>>>>>>>>>9.<<" when (p2 = 1) @  gds-zap-other
      with FRAME ZAPAS .
               DOWN stream   OutStream 1 with FRAME ZAPAS.
              End.
   WHEN "BO":U Then  DO:
    DISPLAY stream  OutStream sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12
      p3 @ s-bar-code
      p4 @ gds-zap-artic
      p5 @ gds-zap-gds-name
      p6 @ gds-zap-unit-base
      p1 @ gds-type
      bo-ostatok-start [p2] format "->>>>>>>>>>9.<<" @  F-ostatok-start
      bo-Prih          [p2] format "->>>>>>>>>>9.<<" @  F-Prih
      bo-RAsh          [p2] format "->>>>>>>>>>9.<<" @  F-RAsh
      bo-KAssa         [p2] format "->>>>>>>>>>9.<<" @  F-KAssa
      bo-Inv           [p2] format "->>>>>>>>>>9.<<" @  F-Inv
      bo-Overturn      [p2] format "->>>>>>>>>>9.<<" @  F-Overturn
      bo-Ostatok-end   [p2] format "->>>>>>>>>>9.<<" @  F-Ostatok-end
      bo-gds-zap-other      format "->>>>>>>>>>9.<<" when (p2 = 1) @  gds-zap-other
      with FRAME ZAPAS .
               DOWN stream   OutStream 1 with FRAME ZAPAS.
              End.
   WHEN ""  Then  DO:
    DISPLAY stream  OutStream sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12
      p3 @ s-bar-code
      p4 @ gds-zap-artic
      p5 @ gds-zap-gds-name
      p6 @ gds-zap-unit-base
      p1 @ gds-type
      ostatok-start [p2] format "->>>>>>>>>>9.<<" @  F-ostatok-start
      Prih          [p2] format "->>>>>>>>>>9.<<" @  F-Prih
      RAsh          [p2] format "->>>>>>>>>>9.<<" @  F-RAsh
      KAssa         [p2] format "->>>>>>>>>>9.<<" @  F-KAssa
      Inv           [p2] format "->>>>>>>>>>9.<<" @  F-Inv
      Overturn      [p2] format "->>>>>>>>>>9.<<" @  F-Overturn
      Ostatok-end   [p2] format "->>>>>>>>>>9.<<" @  F-Ostatok-end
      gds-zap-other      format "->>>>>>>>>>9.<<" when (p2 = 1) @  gds-zap-other
      with FRAME ZAPAS .
               DOWN stream   OutStream 1 with FRAME ZAPAS.
              End.
   End case.
 END PROCEDURE.
PROCEDURE Di-qnty :
define input parameter p1 as char no-undo.
define input parameter p2 as int no-undo.
define input parameter p3 as char no-undo.
define input parameter p4 as char no-undo.
define input parameter p5 as char no-undo.
define input parameter p6 as char no-undo.
define input parameter p7 as char no-undo.
 CASE CAPS(p7) :
   WHEN "B1":U  Then DO :
    DISPLAY stream  OutStream sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12
      p3 @ s-bar-code
      p4 @ gds-zap-artic
      p5 @ gds-zap-gds-name
      p6 @ gds-zap-unit-base
      p1 @ gds-type
      b1-ostatok-start [p2] format "->>>>>>>>>>9.<<<" @  F-ostatok-start
      b1-Prih          [p2] format "->>>>>>>>>>9.<<<" @  F-Prih
      b1-RAsh          [p2] format "->>>>>>>>>>9.<<<" @  F-RAsh
      b1-KAssa         [p2] format "->>>>>>>>>>9.<<<" @  F-KAssa
      b1-Inv           [p2] format "->>>>>>>>>>9.<<<" @  F-Inv
      b1-Overturn      [p2] format "->>>>>>>>>>9.<<<" @  F-Overturn
      b1-Ostatok-end   [p2] format "->>>>>>>>>>9.<<<" @  F-Ostatok-end
      b1-gds-zap-other      format "->>>>>>>>>>9.<<<" when (p2 = 1) @  gds-zap-other
      with FRAME ZAPAS .
if Make-Excel then  put   stream ForExcel unformatted
  p3 CHR(9)
  p4 CHR(9)
  gds-zap-gds-name CHR(9)
  p6 CHR(9)
  gds-zap-type     CHR(9)
  excel-sum(b1-gds-zap-other   )   CHR(9)
  excel-qnty(b1-ostatok-start[1])  CHR(9)
  excel-sum(b1-ostatok-start[2])  CHR(9)
  excel-sum(b1-ostatok-start[5])  CHR(9)
  excel-sum(b1-ostatok-start[8])  CHR(9)
  excel-sum(b1-ostatok-start[3])  CHR(9)
  excel-sum(b1-ostatok-start[6])  CHR(9)
  excel-sum(b1-ostatok-start[9])  CHR(9)
  excel-qnty(b1-Prih         [1])  CHR(9)
  excel-sum(b1-Prih         [2])  CHR(9)
  excel-sum(b1-Prih         [5])  CHR(9)
  excel-sum(b1-Prih         [8])  CHR(9)
  excel-sum(b1-Prih         [3])  CHR(9)
  excel-sum(b1-Prih         [6])  CHR(9)
  excel-sum(b1-Prih         [9])  CHR(9)
  excel-qnty(b1-RAsh         [1])  CHR(9)
  excel-sum(b1-RAsh         [2])  CHR(9)
  excel-sum(b1-RAsh         [5])  CHR(9)
  excel-sum(b1-RAsh         [8])  CHR(9)
  excel-sum(b1-RAsh         [3])  CHR(9)
  excel-sum(b1-RAsh         [6])  CHR(9)
  excel-sum(b1-RAsh         [9])  CHR(9)
  excel-qnty(b1-KAssa        [1])  CHR(9)
  excel-sum(b1-KAssa        [2])  CHR(9)
  excel-sum(b1-KAssa        [5])  CHR(9)
  excel-sum(b1-KAssa        [8])  CHR(9)
  excel-sum(b1-KAssa        [3])  CHR(9)
  excel-sum(b1-KAssa        [6])  CHR(9)
  excel-sum(b1-KAssa        [9])  CHR(9)
  excel-qnty(b1-Inv          [1])  CHR(9)
  excel-sum(b1-Inv          [2])  CHR(9)
  excel-sum(b1-Inv          [5])  CHR(9)
  excel-sum(b1-Inv          [8])  CHR(9)
  excel-sum(b1-Inv          [3])  CHR(9)
  excel-sum(b1-Inv          [6])  CHR(9)
  excel-sum(b1-Inv          [9])  CHR(9)
  excel-qnty(b1-Overturn     [1])  CHR(9)
  excel-sum(b1-Overturn     [2])  CHR(9)
  excel-sum(b1-Overturn     [5])  CHR(9)
  excel-sum(b1-Overturn     [8])  CHR(9)
  excel-sum(b1-Overturn     [3])  CHR(9)
  excel-sum(b1-Overturn     [6])  CHR(9)
  excel-sum(b1-Overturn     [9])  CHR(9)
  excel-qnty(b1-Ostatok-end  [1])  CHR(9)
  excel-sum(b1-Ostatok-end  [2])  CHR(9)
  excel-sum(b1-Ostatok-end  [5])  CHR(9)
  excel-sum(b1-Ostatok-end  [8])  CHR(9)
  excel-sum(b1-Ostatok-end  [3])  CHR(9)
  excel-sum(b1-Ostatok-end  [6])  CHR(9)
  excel-sum(b1-Ostatok-end  [9])  CHR(9)
  skip.
                End.
   WHEN "B2":U  Then DO :
    DISPLAY stream  OutStream sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12
      p3 @ s-bar-code
      p4 @ gds-zap-artic
      p5 @ gds-zap-gds-name
      p6 @ gds-zap-unit-base
      p1 @ gds-type
      b2-ostatok-start [p2] format "->>>>>>>>>>9.<<<" @  F-ostatok-start
      b2-Prih          [p2] format "->>>>>>>>>>9.<<<" @  F-Prih
      b2-RAsh          [p2] format "->>>>>>>>>>9.<<<" @  F-RAsh
      b2-KAssa         [p2] format "->>>>>>>>>>9.<<<" @  F-KAssa
      b2-Inv           [p2] format "->>>>>>>>>>9.<<<" @  F-Inv
      b2-Overturn      [p2] format "->>>>>>>>>>9.<<<" @  F-Overturn
      b2-Ostatok-end   [p2] format "->>>>>>>>>>9.<<<" @  F-Ostatok-end
      b2-gds-zap-other      format "->>>>>>>>>>9.<<<" when (p2 = 1) @  gds-zap-other
      with FRAME ZAPAS .
if Make-Excel then  put   stream ForExcel unformatted
  p3 CHR(9)
  p4 CHR(9)
  gds-zap-gds-name CHR(9)
  p6 CHR(9)
  gds-zap-type     CHR(9)
  excel-sum(b2-gds-zap-other   )   CHR(9)
  excel-qnty(b2-ostatok-start[1])  CHR(9)
  excel-sum(b2-ostatok-start[2])  CHR(9)
  excel-sum(b2-ostatok-start[5])  CHR(9)
  excel-sum(b2-ostatok-start[8])  CHR(9)
  excel-sum(b2-ostatok-start[3])  CHR(9)
  excel-sum(b2-ostatok-start[6])  CHR(9)
  excel-sum(b2-ostatok-start[9])  CHR(9)
  excel-qnty(b2-Prih         [1])  CHR(9)
  excel-sum(b2-Prih         [2])  CHR(9)
  excel-sum(b2-Prih         [5])  CHR(9)
  excel-sum(b2-Prih         [8])  CHR(9)
  excel-sum(b2-Prih         [3])  CHR(9)
  excel-sum(b2-Prih         [6])  CHR(9)
  excel-sum(b2-Prih         [9])  CHR(9)
  excel-qnty(b2-RAsh         [1])  CHR(9)
  excel-sum(b2-RAsh         [2])  CHR(9)
  excel-sum(b2-RAsh         [5])  CHR(9)
  excel-sum(b2-RAsh         [8])  CHR(9)
  excel-sum(b2-RAsh         [3])  CHR(9)
  excel-sum(b2-RAsh         [6])  CHR(9)
  excel-sum(b2-RAsh         [9])  CHR(9)
  excel-qnty(b2-KAssa        [1])  CHR(9)
  excel-sum(b2-KAssa        [2])  CHR(9)
  excel-sum(b2-KAssa        [5])  CHR(9)
  excel-sum(b2-KAssa        [8])  CHR(9)
  excel-sum(b2-KAssa        [3])  CHR(9)
  excel-sum(b2-KAssa        [6])  CHR(9)
  excel-sum(b2-KAssa        [9])  CHR(9)
  excel-qnty(b2-Inv          [1])  CHR(9)
  excel-sum(b2-Inv          [2])  CHR(9)
  excel-sum(b2-Inv          [5])  CHR(9)
  excel-sum(b2-Inv          [8])  CHR(9)
  excel-sum(b2-Inv          [3])  CHR(9)
  excel-sum(b2-Inv          [6])  CHR(9)
  excel-sum(b2-Inv          [9])  CHR(9)
  excel-qnty(b2-Overturn     [1])  CHR(9)
  excel-sum(b2-Overturn     [2])  CHR(9)
  excel-sum(b2-Overturn     [5])  CHR(9)
  excel-sum(b2-Overturn     [8])  CHR(9)
  excel-sum(b2-Overturn     [3])  CHR(9)
  excel-sum(b2-Overturn     [6])  CHR(9)
  excel-sum(b2-Overturn     [9])  CHR(9)
  excel-qnty(b2-Ostatok-end  [1])  CHR(9)
  excel-sum(b2-Ostatok-end  [2])  CHR(9)
  excel-sum(b2-Ostatok-end  [5])  CHR(9)
  excel-sum(b2-Ostatok-end  [8])  CHR(9)
  excel-sum(b2-Ostatok-end  [3])  CHR(9)
  excel-sum(b2-Ostatok-end  [6])  CHR(9)
  excel-sum(b2-Ostatok-end  [9])  CHR(9)
  skip.
             End.
   WHEN "BI":U Then  DO :
    DISPLAY stream  OutStream sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12
      p3 @ s-bar-code
      p4 @ gds-zap-artic
      p5 @ gds-zap-gds-name
      p6 @ gds-zap-unit-base
      p1 @ gds-type
      bi-ostatok-start [p2] format "->>>>>>>>>>9.<<<" @  F-ostatok-start
      bi-Prih          [p2] format "->>>>>>>>>>9.<<<" @  F-Prih
      bi-RAsh          [p2] format "->>>>>>>>>>9.<<<" @  F-RAsh
      bi-KAssa         [p2] format "->>>>>>>>>>9.<<<" @  F-KAssa
      bi-Inv           [p2] format "->>>>>>>>>>9.<<<" @  F-Inv
      bi-Overturn      [p2] format "->>>>>>>>>>9.<<<" @  F-Overturn
      bi-Ostatok-end   [p2] format "->>>>>>>>>>9.<<<" @  F-Ostatok-end
      bi-gds-zap-other      format "->>>>>>>>>>9.<<<" when (p2 = 1) @  gds-zap-other
      with FRAME ZAPAS .
if Make-Excel then  put   stream ForExcel unformatted
  p3 CHR(9)
  p4 CHR(9)
  CHR(9)
  p6 CHR(9)
  CHR(9)
  CHR(9)
  excel-qnty(bi-ostatok-start[1])  CHR(9)
  excel-sum(bi-ostatok-start[2])  CHR(9)
  excel-sum(bi-ostatok-start[5])  CHR(9)
  excel-sum(bi-ostatok-start[8])  CHR(9)
  excel-sum(bi-ostatok-start[3])  CHR(9)
  excel-sum(bi-ostatok-start[6])  CHR(9)
  excel-sum(bi-ostatok-start[9])  CHR(9)
  excel-qnty(bi-Prih         [1])  CHR(9)
  excel-sum(bi-Prih         [2])  CHR(9)
  excel-sum(bi-Prih         [5])  CHR(9)
  excel-sum(bi-Prih         [8])  CHR(9)
  excel-sum(bi-Prih         [3])  CHR(9)
  excel-sum(bi-Prih         [6])  CHR(9)
  excel-sum(bi-Prih         [9])  CHR(9)
  excel-qnty(bi-RAsh         [1])  CHR(9)
  excel-sum(bi-RAsh         [2])  CHR(9)
  excel-sum(bi-RAsh         [5])  CHR(9)
  excel-sum(bi-RAsh         [8])  CHR(9)
  excel-sum(bi-RAsh         [3])  CHR(9)
  excel-sum(bi-RAsh         [6])  CHR(9)
  excel-sum(bi-RAsh         [9])  CHR(9)
  excel-qnty(bi-KAssa        [1])  CHR(9)
  excel-sum(bi-KAssa        [2])  CHR(9)
  excel-sum(bi-KAssa        [5])  CHR(9)
  excel-sum(bi-KAssa        [8])  CHR(9)
  excel-sum(bi-KAssa        [3])  CHR(9)
  excel-sum(bi-KAssa        [6])  CHR(9)
  excel-sum(bi-KAssa        [9])  CHR(9)
  excel-qnty(bi-Inv          [1])  CHR(9)
  excel-sum(bi-Inv          [2])  CHR(9)
  excel-sum(bi-Inv          [5])  CHR(9)
  excel-sum(bi-Inv          [8])  CHR(9)
  excel-sum(bi-Inv          [3])  CHR(9)
  excel-sum(bi-Inv          [6])  CHR(9)
  excel-sum(bi-Inv          [9])  CHR(9)
  excel-qnty(bi-Overturn     [1])  CHR(9)
  excel-sum(bi-Overturn     [2])  CHR(9)
  excel-sum(bi-Overturn     [5])  CHR(9)
  excel-sum(bi-Overturn     [8])  CHR(9)
  excel-sum(bi-Overturn     [3])  CHR(9)
  excel-sum(bi-Overturn     [6])  CHR(9)
  excel-sum(bi-Overturn     [9])  CHR(9)
  excel-qnty(bi-Ostatok-end  [1])  CHR(9)
  excel-sum(bi-Ostatok-end  [2])  CHR(9)
  excel-sum(bi-Ostatok-end  [5])  CHR(9)
  excel-sum(bi-Ostatok-end  [8])  CHR(9)
  excel-sum(bi-Ostatok-end  [3])  CHR(9)
  excel-sum(bi-Ostatok-end  [6])  CHR(9)
  excel-sum(bi-Ostatok-end  [9])  CHR(9)
  skip.
             End.
   WHEN "BO":U Then  DO :
    DISPLAY stream  OutStream sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12
      p3 @ s-bar-code
      p4 @ gds-zap-artic
      p5 @ gds-zap-gds-name
      p6 @ gds-zap-unit-base
      p1 @ gds-type
      bo-ostatok-start [p2] format "->>>>>>>>>>9.<<<" @  F-ostatok-start
      bo-Prih          [p2] format "->>>>>>>>>>9.<<<" @  F-Prih
      bo-RAsh          [p2] format "->>>>>>>>>>9.<<<" @  F-RAsh
      bo-KAssa         [p2] format "->>>>>>>>>>9.<<<" @  F-KAssa
      bo-Inv           [p2] format "->>>>>>>>>>9.<<<" @  F-Inv
      bo-Overturn      [p2] format "->>>>>>>>>>9.<<<" @  F-Overturn
      bo-Ostatok-end   [p2] format "->>>>>>>>>>9.<<<" @  F-Ostatok-end
      bo-gds-zap-other      format "->>>>>>>>>>9.<<<" when (p2 = 1) @  gds-zap-other
      with FRAME ZAPAS .
if Make-Excel then  put   stream ForExcel unformatted
  p3 CHR(9)
  p4 CHR(9)
  gds-zap-gds-name CHR(9)
  p6 CHR(9)
  gds-zap-type     CHR(9)
  excel-sum(bo-gds-zap-other   )   CHR(9)
  excel-qnty(bo-ostatok-start[1])  CHR(9)
  excel-sum(bo-ostatok-start[2])  CHR(9)
  excel-sum(bo-ostatok-start[5])  CHR(9)
  excel-sum(bo-ostatok-start[8])  CHR(9)
  excel-sum(bo-ostatok-start[3])  CHR(9)
  excel-sum(bo-ostatok-start[6])  CHR(9)
  excel-sum(bo-ostatok-start[9])  CHR(9)
  excel-qnty(bo-Prih         [1])  CHR(9)
  excel-sum(bo-Prih         [2])  CHR(9)
  excel-sum(bo-Prih         [5])  CHR(9)
  excel-sum(bo-Prih         [8])  CHR(9)
  excel-sum(bo-Prih         [3])  CHR(9)
  excel-sum(bo-Prih         [6])  CHR(9)
  excel-sum(bo-Prih         [9])  CHR(9)
  excel-qnty(bo-RAsh         [1])  CHR(9)
  excel-sum(bo-RAsh         [2])  CHR(9)
  excel-sum(bo-RAsh         [5])  CHR(9)
  excel-sum(bo-RAsh         [8])  CHR(9)
  excel-sum(bo-RAsh         [3])  CHR(9)
  excel-sum(bo-RAsh         [6])  CHR(9)
  excel-sum(bo-RAsh         [9])  CHR(9)
  excel-qnty(bo-KAssa        [1])  CHR(9)
  excel-sum(bo-KAssa        [2])  CHR(9)
  excel-sum(bo-KAssa        [5])  CHR(9)
  excel-sum(bo-KAssa        [8])  CHR(9)
  excel-sum(bo-KAssa        [3])  CHR(9)
  excel-sum(bo-KAssa        [6])  CHR(9)
  excel-sum(bo-KAssa        [9])  CHR(9)
  excel-qnty(bo-Inv          [1])  CHR(9)
  excel-sum(bo-Inv          [2])  CHR(9)
  excel-sum(bo-Inv          [5])  CHR(9)
  excel-sum(bo-Inv          [8])  CHR(9)
  excel-sum(bo-Inv          [3])  CHR(9)
  excel-sum(bo-Inv          [6])  CHR(9)
  excel-sum(bo-Inv          [9])  CHR(9)
  excel-qnty(bo-Overturn     [1])  CHR(9)
  excel-sum(bo-Overturn     [2])  CHR(9)
  excel-sum(bo-Overturn     [5])  CHR(9)
  excel-sum(bo-Overturn     [8])  CHR(9)
  excel-sum(bo-Overturn     [3])  CHR(9)
  excel-sum(bo-Overturn     [6])  CHR(9)
  excel-sum(bo-Overturn     [9])  CHR(9)
  excel-qnty(bo-Ostatok-end  [1])  CHR(9)
  excel-sum(bo-Ostatok-end  [2])  CHR(9)
  excel-sum(bo-Ostatok-end  [5])  CHR(9)
  excel-sum(bo-Ostatok-end  [8])  CHR(9)
  excel-sum(bo-Ostatok-end  [3])  CHR(9)
  excel-sum(bo-Ostatok-end  [6])  CHR(9)
  excel-sum(bo-Ostatok-end  [9])  CHR(9)
  skip.
             End.
   WHEN ""  Then     DO :
    DISPLAY stream  OutStream sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12
      p3 @ s-bar-code
      p4 @ gds-zap-artic
      p5 @ gds-zap-gds-name
      p6 @ gds-zap-unit-base
      p1 @ gds-type
      ostatok-start [p2] format "->>>>>>>>>>9.<<<" @  F-ostatok-start
      Prih          [p2] format "->>>>>>>>>>9.<<<" @  F-Prih
      RAsh          [p2] format "->>>>>>>>>>9.<<<" @  F-RAsh
      KAssa         [p2] format "->>>>>>>>>>9.<<<" @  F-KAssa
      Inv           [p2] format "->>>>>>>>>>9.<<<" @  F-Inv
      Overturn      [p2] format "->>>>>>>>>>9.<<<" @  F-Overturn
      Ostatok-end   [p2] format "->>>>>>>>>>9.<<<" @  F-Ostatok-end
      gds-zap-other      format "->>>>>>>>>>9.<<<" when (p2 = 1) @  gds-zap-other
      with FRAME ZAPAS .
if Make-Excel then  put   stream ForExcel unformatted
  p3 CHR(9)
  p4 CHR(9)
  gds-zap-gds-name CHR(9)
  p6 CHR(9)
  gds-zap-type     CHR(9)
  excel-sum(gds-zap-other   )   CHR(9)
  excel-qnty(ostatok-start[1])  CHR(9)
  excel-sum(ostatok-start[2])  CHR(9)
  excel-sum(ostatok-start[5])  CHR(9)
  excel-sum(ostatok-start[8])  CHR(9)
  excel-sum(ostatok-start[3])  CHR(9)
  excel-sum(ostatok-start[6])  CHR(9)
  excel-sum(ostatok-start[9])  CHR(9)
  excel-qnty(Prih         [1])  CHR(9)
  excel-sum(Prih         [2])  CHR(9)
  excel-sum(Prih         [5])  CHR(9)
  excel-sum(Prih         [8])  CHR(9)
  excel-sum(Prih         [3])  CHR(9)
  excel-sum(Prih         [6])  CHR(9)
  excel-sum(Prih         [9])  CHR(9)
  excel-qnty(RAsh         [1])  CHR(9)
  excel-sum(RAsh         [2])  CHR(9)
  excel-sum(RAsh         [5])  CHR(9)
  excel-sum(RAsh         [8])  CHR(9)
  excel-sum(RAsh         [3])  CHR(9)
  excel-sum(RAsh         [6])  CHR(9)
  excel-sum(RAsh         [9])  CHR(9)
  excel-qnty(KAssa        [1])  CHR(9)
  excel-sum(KAssa        [2])  CHR(9)
  excel-sum(KAssa        [5])  CHR(9)
  excel-sum(KAssa        [8])  CHR(9)
  excel-sum(KAssa        [3])  CHR(9)
  excel-sum(KAssa        [6])  CHR(9)
  excel-sum(KAssa        [9])  CHR(9)
  excel-qnty(Inv          [1])  CHR(9)
  excel-sum(Inv          [2])  CHR(9)
  excel-sum(Inv          [5])  CHR(9)
  excel-sum(Inv          [8])  CHR(9)
  excel-sum(Inv          [3])  CHR(9)
  excel-sum(Inv          [6])  CHR(9)
  excel-sum(Inv          [9])  CHR(9)
  excel-qnty(Overturn     [1])  CHR(9)
  excel-sum(Overturn     [2])  CHR(9)
  excel-sum(Overturn     [5])  CHR(9)
  excel-sum(Overturn     [8])  CHR(9)
  excel-sum(Overturn     [3])  CHR(9)
  excel-sum(Overturn     [6])  CHR(9)
  excel-sum(Overturn     [9])  CHR(9)
  excel-qnty(Ostatok-end  [1])  CHR(9)
  excel-sum(Ostatok-end  [2])  CHR(9)
  excel-sum(Ostatok-end  [5])  CHR(9)
  excel-sum(Ostatok-end  [8])  CHR(9)
  excel-sum(Ostatok-end  [3])  CHR(9)
  excel-sum(Ostatok-end  [6])  CHR(9)
  excel-sum(Ostatok-end  [9])  CHR(9)
  skip.
              End.
   End case.
               DOWN stream   OutStream 1 with FRAME ZAPAS.
 END PROCEDURE.
