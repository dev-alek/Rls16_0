block-level on error undo, throw.
define input parameter x-store-code like ub.clients.obj-code   no-undo.
define input parameter x-store-type like ub.clients.obj-type   no-undo.
define input parameter x-base-type  like ub.currency.curr-abbr no-undo.
define input parameter x-base-code  like ub.currency.curr-code no-undo.
define input parameter xClassify  as char no-undo.
define input parameter xSortType  as char no-undo.
define input parameter xSumsOnly  as log  no-undo.
define input parameter xShowZero  as log  no-undo.
define input parameter xCOMBO-node as char no-undo.
define input parameter xTog-obj    as log no-undo.
define input parameter  xtog-lavel as log no-undo.
define input parameter  xvar-lavel as int no-undo. .
define buffer goods   for ub.goods  .
define buffer gds-obj for ub.gds-obj  .
define buffer clients for ub.clients  .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Оборотная ведомость отчет по 1 типу документа".
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
def var vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure tax-name:
define input  parameter pardef-tax  as character           no-undo.
define output parameter parname-tax as character initial ? no-undo.
define buffer bf_tax for ub.tax.
do on error undo, return error :
   case pardef-tax:
      when 'vat':U then do:
                  find first bf_tax where bf_tax.tax-code = integer('1':U) no-lock no-error.                     if available bf_tax then do:                                                                              assign parname-tax = bf_tax.tax-name.                                                               end.                                                                                                   else assign parname-tax = "Налог '1':U(не задействован)".
      end.
      when 'slt':U then do:
                  find first bf_tax where bf_tax.tax-code = integer('2':U) no-lock no-error.                     if available bf_tax then do:                                                                              assign parname-tax = bf_tax.tax-name.                                                               end.                                                                                                   else assign parname-tax = "Налог '2':U(не задействован)".
      end.
      when 'rdt':U then do:
                  find first bf_tax where bf_tax.tax-code = integer('3':U) no-lock no-error.                     if available bf_tax then do:                                                                              assign parname-tax = bf_tax.tax-name.                                                               end.                                                                                                   else assign parname-tax = "Налог '3':U(не задействован)".
      end.
      when 'exc':U then do:
                  find first bf_tax where bf_tax.tax-code = integer('4':U) no-lock no-error.                     if available bf_tax then do:                                                                              assign parname-tax = bf_tax.tax-name.                                                               end.                                                                                                   else assign parname-tax = "Налог '4':U(не задействован)".
      end.
      otherwise do:
         return error "Задан неверный параметр " + pardef-tax + " .".
      end.
   end case.
end.
end procedure.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
function func-vat returns decimal (
    input p-gds-code as integer  ,
    input p-obj-type as character ,
    input p-obj-code as integer  ).
define variable i-vat-pc as decimal no-undo .
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable rdtaxname as character no-undo.
define variable  tPrintRubl as log no-undo.
define variable  KOLSTR as integer no-undo .
define  stream  OutStream.
define  stream  OutStream2.
define variable ObjName       as   char no-undo.
define variable Select-Good   as   integer no-undo.
define variable ChosedType    as   integer no-undo.
define variable PayType       as   integer no-undo.
define variable RetClassify   as   char  no-undo.
define variable RetSortType   as   char  no-undo.
define variable Show-Negativ  as   logical  no-undo.
define variable Sums-Only     as   logical  no-undo.
define variable ValType       as   integer no-undo.
define variable Line          as   char        no-undo.
define variable FirstLine     as   logical     no-undo.
define variable rdtaxcdvalue  as character initial ? no-undo.
define variable rdtaxcdtype   as character initial ? no-undo.
define buffer   rt_tax        for ub.tax.
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
define variable gds-zap-unit-base     like ub.goods.unit-base     no-undo.
define variable gds-zap-prt-root      like ub.goods.prt-root     no-undo .
define variable gds-zap-gds-name      like ub.goods.gds-name     no-undo .
define variable gds-zap-prod-type     like ub.goods.prod-type    no-undo .
define variable gds-zap-prod-code     like ub.goods.prod-code    no-undo .
define variable gds-zap-artic         like ub.goods.artic        no-undo .
define variable gds-zap-b-code        like ub.bar-code.b-code    no-undo .
define variable gds-type              as char no-undo.
define variable type-Sum              as char no-undo.
define variable gds-zap-type          like ub.goods.gds-type     no-undo .
define variable gds-zap-grp-name      like ub.goods.grp-name     no-undo .
define variable gds-zap-prod-name     like ub.clients.obj-name   no-undo .
define variable gds-zap-price-base    like ub.stk-tot.sum-base no-undo.
define variable gds-zap-stoim-base    like ub.stk-tot.sum-base no-undo.
define variable gds-zap-qnty          like ub.stk-tot.fact-qnty no-undo.
define variable gds-zap-Nds           like ub.stk-tot.sum-base no-undo.
define variable gds-zap-Np            like ub.stk-tot.sum-base no-undo.
 define variable  F-qnty          as   char   no-undo.
 define variable  F-Summ          as   char   no-undo.
 define variable  F-Vat           as   char   no-undo.
 define variable  F-eff           as   char   no-undo.
 define variable  F-excise        as   char   no-undo.
 define variable  F-road-tax      as   char   no-undo.
 define variable  F-transport     as   char   no-undo.
 define variable  F-Other         as   char   no-undo.
 define variable  qnty          as   decimal EXTENT 3 Format "->>>>>>>>>9.999" no-undo.
 define variable  Summ          as   decimal EXTENT 3 Format "->>>>>>>>>>9.99" no-undo.
 define variable  Vat           as   decimal EXTENT 3 Format "->>>>>>>>>>>>9.<<" no-undo.
 define variable  eff           as   decimal EXTENT 3 Format "->>>>>>>>>>>>9.<<" no-undo.
 define variable  excise        as   decimal EXTENT 3 Format "->>>>>>>>>>>>9.<<" no-undo.
 define variable  road-tax      as   decimal EXTENT 3 Format "->>>>>>>>>>>>9.<<" no-undo.
 define variable  transport     as   decimal EXTENT 3 Format "->>>>>>>>>>>>9.<<" no-undo.
 define variable  Other         as   decimal EXTENT 3 Format "->>>>>>>>>>9.<<" no-undo.
 define variable  b1-qnty          as   decimal EXTENT 3 Format "->>>>>>>>>9.999" no-undo.
 define variable  b1-Summ          as   decimal EXTENT 3  Format "->>>>>>>>>>>>9.<<" no-undo.
 define variable  b1-Vat           as   decimal EXTENT 3  Format "->>>>>>>>>>>>9.<<" no-undo.
 define variable  b1-eff           as   decimal EXTENT 3  Format "->>>>>>>>>>>>9.<<" no-undo.
 define variable  b1-excise        as   decimal EXTENT 3  Format "->>>>>>>>>>>>9.<<" no-undo.
 define variable  b1-road-tax      as   decimal EXTENT 3  Format "->>>>>>>>>>>>9.<<" no-undo.
 define variable  b1-transport     as   decimal EXTENT 3  Format "->>>>>>>>>>>>9.<<" no-undo.
 define variable  b1-Other         as   decimal EXTENT 3  Format "->>>>>>>>>9.<<" no-undo.
 define variable  b2-qnty          as   decimal EXTENT 3 Format "->>>>>>>>>9.999" no-undo.
 define variable  b2-Summ          as   decimal  EXTENT 3 Format "->>>>>>>>>>>>9.<<" no-undo.
 define variable  b2-Vat           as   decimal  EXTENT 3 Format "->>>>>>>>>>>>9.<<" no-undo.
 define variable  b2-eff           as   decimal  EXTENT 3 Format "->>>>>>>>>>>>9.<<" no-undo.
 define variable  b2-excise        as   decimal  EXTENT 3 Format "->>>>>>>>>>>>9.<<" no-undo.
 define variable  b2-road-tax      as   decimal  EXTENT 3 Format "->>>>>>>>>>>>9.<<" no-undo.
 define variable  b2-transport     as   decimal  EXTENT 3 Format "->>>>>>>>>>>>9.<<" no-undo.
 define variable  b2-Other         as   decimal  EXTENT 3 Format "->>>>>>>>>9.<<" no-undo.
 define variable  bi-qnty          as   decimal  EXTENT 3 Format "->>>>>>>>>9.999" no-undo.
 define variable  bi-Summ          as   decimal  EXTENT 3 Format "->>>>>>>>>>>>9.<<" no-undo.
 define variable  bi-Vat           as   decimal  EXTENT 3 Format "->>>>>>>>>>>>9.<<" no-undo.
 define variable  bi-eff           as   decimal  EXTENT 3 Format "->>>>>>>>>>>>9.<<" no-undo.
 define variable  bi-excise        as   decimal  EXTENT 3 Format "->>>>>>>>>>>>9.<<" no-undo.
 define variable  bi-road-tax      as   decimal  EXTENT 3 Format "->>>>>>>>>>>>9.<<" no-undo.
 define variable  bi-transport     as   decimal  EXTENT 3 Format "->>>>>>>>>>>>9.<<" no-undo.
 define variable  bi-Other         as   decimal  EXTENT 3 Format "->>>>>>>>>9.<<" no-undo.
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
define variable  slt_R       like ub.stk-tot.sum-rubl   no-undo.
define variable  SLT_V       like ub.stk-tot.sum-rubl   no-undo.
define variable  Coast3       like ub.stk-tot.sum-rubl   no-undo.
define variable  Coast4       like ub.stk-tot.sum-rubl   no-undo.
define variable  temp-str as char no-undo.
define variable str as char format "X(60)" no-undo.
define variable i#i as int no-undo.
define variable xLavel as int  no-undo.
define variable list-field as char no-undo.
define variable str10 as char no-undo.
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
assign v-account = ( if integer( 50 ) = 0 then 100 else integer( 50 ) ).
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
DEFINE FRAME zapas
        gds-zap-b-code column-label  "Код! ":C10 format ">>>>>>>>>>" space(0)
        sym1 column-label ":!:" format "x(1)"       space(0)
        gds-zap-artic column-label "Артикул! ":C16 format "X(16)" space(0)
        sym2 column-label ":!:" format "x(1)"                         space(0)
        gds-zap-gds-name column-label "Название товара! ":C33 format "X(33)" space(0)
        sym3 column-label ":!:" format "x(1)"                                 space(0)
        gds-zap-unit-base column-label "Ед.!изм" format "X(3)"                 space(0)
        sym4 column-label ":!:" format "x(1)"                                   space(0)
        type-Sum column-label  "Тип!цен":C4 format "X(4)" space(0)
        sym5 column-label ":!:" format "x(1)" space(0)
        F-qnty   column-label "Количество! ":C15     Format "x(15)"     space(0)
        sym6 column-label ":!:" format "x(1)" space(0)
        F-Summ    column-label "Сумма!  ":C15     Format "x(15)"     space(0)
        sym7 column-label ":!:" format "x(1)" space(0)
        F-Vat   column-label "НДС! ":C15     Format "x(15)"     space(0)
        sym8 column-label ":!:" format "x(1)" space(0)
        F-excise             column-label "Акциз!  ":C15  Format "x(15)"   space(0)
        sym9 column-label ":!:" format "x(1)" space(0)
        F-road-tax               column-label "Дорожный налог!  ":C15  Format "x(15)"   space(0)
        sym10 column-label ":!:" format "x(1)" space(0)
        F-transport           column-label "Транспортный!налог":C15  Format "x(15)"   space(0)
        sym11 column-label ":!:" format "x(1)" space(0)
        F-Other         column-label "Скидка! ":C12  Format "x(12)"   space(0)
        sym12 column-label ":!:" format "x(1)" space(0)
        F-eff      column-label "Эффективность!% ":C15  Format "x(15)"   space(0)
    HEADER
        cur-time-print() AT 5 format "X(35)"
        "Цены указаны в" (if tPrintRubl then "РУБ" else x-base-type )
        string( "Страница " + string( PAGE-NUMBER( OutStream ), ">>>>9") ) AT 147 format "X(53)" SKIP
        Line format "X(198)" AT 1
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
        FirstLine     = FALSE.
        Line          = fill("-", 232).
        ValType       = IF (PayType = 1) Then 0  else x-SET_val_TYPE.
        run tax-name (input 'rdt':U, output rdtaxname ).
        assign F-road-tax :label = rdtaxname .
        if not ( show-sale and show-cost ) then  do:
             F-eff :label = "" .
             F-eff :hidden = true  .
            end .
        Run report-execute.
FUNCTION n-lavel RETURNS char (INPUT grp-name as char, INPUT lavel# as int ).
define variable str  as char format "X(60)"  no-undo.
define variable str2 as char  no-undo.
STR ="".
define variable i#i as int no-undo.
  REPEAT i#i =1 to lavel#:
      If i#i =1 then STR   = entry(1,grp-name, chr(47)) .
      Else DO:
          STR2 =   entry(i#i,grp-name, chr(47)) no-error.
          IF NOT ERROR-STATUS:ERROR  and str2 <> "":U then  STR = STR + chr(47) +  entry(i#i,grp-name, chr(47)) .
          End.
  End.
    RETURN (str + chr(47)).
END FUNCTION.
PROCEDURE report-execute :
  If (ValType=0 and x-base-code=0)  Or ValType=1
                                then   assign tPrintRubl = yes .
                                else   assign tPrintRubl = no .
output stream OutStream to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size  value(ReportPageHeight) .
   if xTog-obj  Then DO:
            FOR each obj-list no-lock:
                x-store-type = obj-list.obj-type.
                x-store-code = obj-list.obj-code.
                Run report-exec1.
            End.
                                               End.
  Else Run report-exec1.
  HIDE   STREAM OutStream FRAME ZAPAS .
  Output stream OutStream close.
if mFrameView
then do:
   HIDE FRAME InfoFrame.
end.
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
PROCEDURE report-exec1  :
   FIND FIRST clients where x-store-type = clients.obj-type AND
                            x-store-code = clients.obj-code no-lock no-error.
           If available clients then  ObjName = clients.obj-name.
                                         else  ObjName="объект не определен".
  FORM with FRAME zapas .
  Line = fill("-", 198).
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
form header
  line format "X(198)" at 1 skip
  "Продолжение - на следующей странице" at 30 skip
  with frame bottomframe width 232 page-bottom no-labels no-box .
view stream outstream frame bottomframe .
  run calcitog in this-procedure .
  run print-header.
   case RetClassify :
    when "prod/grp-goods":U then  run run4 in this-procedure .
    when "grp-goods/prod":U then  run run5 in this-procedure .
    when "vat-ps":U         then  run run7 in this-procedure .
    otherwise do:
      message "Ошибка вызова!" view-as alert-box error .
    end.
   end case.
  hide stream outstream frame bottomframe .
  run print-footer.
  end procedure.
PROCEDURE foreach :
IF ( i modulo v-account = 0 )  then DO:
 Assign
    v-kol-spice = (50 - LENGTH(reportname)) / 2
    RecordsString = fill(' ',v-kol-spice) + string(reportname)
    .
 Assign
    v-kol-spice = (50 - LENGTH(objname)) / 2
    RecordsString2 = fill(' ',v-kol-spice) + string(objname)
    .
          if  log-manager:logfile-name ne ?
          then DO:
              log-manager:write-message("DISP mFrameView=" + string(mFrameView), "frameRepError").
          end.
           if mFrameView
           then do:
            DISPLAY
              i @ RecordsDone
              RecordsString   @ RecordsString
              RecordsString2  @ RecordsString2
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
 If Show-cost  then DO:
   RUN Clear-item(1).
   if gds-zap-type = 'т':U THEN
run ob-line  in this-procedure (
input x-store-code ,
input x-store-type ,
input gds-zap-artic ,
input gds-zap-prod-code ,
input gds-zap-prod-type ,
input fact-order-1 ,
input fact-order-2 ,
input 'cost':U ,
input '##,##':U,
input xCOMBO-node ,
input xtog-obj) .
   if gds-zap-type = 'у':U THEN
run ob-line  in this-procedure (
input x-store-code ,
input x-store-type ,
input gds-zap-artic ,
input gds-zap-prod-code ,
input gds-zap-prod-type ,
input fact-order-1 ,
input fact-order-2 ,
input 'cssr':U ,
input '##,##':U,
input xCOMBO-node ,
input xtog-obj) .
   Run CAlc-Sub-itog (1).
   End.
 If Show-crsa  then DO:
   RUN Clear-item(2).
   if gds-zap-type = 'т':U THEN
run ob-line  in this-procedure (
input x-store-code ,
input x-store-type ,
input gds-zap-artic ,
input gds-zap-prod-code ,
input gds-zap-prod-type ,
input fact-order-1 ,
input fact-order-2 ,
input 'crsa':U ,
input '##,##':U,
input xCOMBO-node ,
input xtog-obj) .
   if gds-zap-type = 'у':U THEN
run ob-line  in this-procedure (
input x-store-code ,
input x-store-type ,
input gds-zap-artic ,
input gds-zap-prod-code ,
input gds-zap-prod-type ,
input fact-order-1 ,
input fact-order-2 ,
input 'cgsr':U ,
input '##,##':U,
input xCOMBO-node ,
input xtog-obj) .
   Run CAlc-Sub-itog (2).
   End.
  RUN Clear-item(3).
   if gds-zap-type = 'т':U THEN
run ob-line  in this-procedure (
input x-store-code ,
input x-store-type ,
input gds-zap-artic ,
input gds-zap-prod-code ,
input gds-zap-prod-type ,
input fact-order-1 ,
input fact-order-2 ,
input 'sale':U ,
input '##,##':U,
input xCOMBO-node ,
input xtog-obj) .
   if gds-zap-type = 'у':U THEN
run ob-line  in this-procedure (
input x-store-code ,
input x-store-type ,
input gds-zap-artic ,
input gds-zap-prod-code ,
input gds-zap-prod-type ,
input fact-order-1 ,
input fact-order-2 ,
input 'sasr':U ,
input '##,##':U,
input xCOMBO-node ,
input xtog-obj) .
   Run CAlc-Sub-itog (3).
END PROCEDURE.
PROCEDURE display-line :
    i = i + 1.
    IF  NOT (NOT Show-Negativ  AND
      ( qnty     [1]    = 0 and  qnty     [2]    = 0 and  qnty     [3]    = 0 and
        Summ     [1]    = 0 and  Summ     [2]    = 0 and  Summ     [3]    = 0 and
        Vat      [1]    = 0 and  Vat      [2]    = 0 and  Vat      [3]    = 0 and
        excise   [1]    = 0 and  excise   [2]    = 0 and  excise   [3]    = 0 and
        road-tax [1]    = 0 and  road-tax [2]    = 0 and  road-tax [3]    = 0 and
        transport[1]    = 0 and  transport[2]    = 0 and  transport[3]    = 0 and
        Other    [1]    = 0 and  Other    [2]    = 0 and  Other    [3]    = 0 )) Then dO:
        IF NOT Sums-Only then   do:
                if fr0 = true then do:
                    PUT stream  OutStream
                        tmp#stroka0
                        format "X(100)" SKIP.
                    fr0 = false .
                end.
              if fr = true then do:
                PUT stream  OutStream   space(10)
                        (if xtog-lavel = false then tmp#stroka
                                            else  str )
                    format "X(100)" SKIP.
                fr = false .
              end.
            Run Display-str1.
        end.
     END.
  END PROCEDURE.
PROCEDURE print-header :
if NOT FirstLine Then  Run Display-Title.
    FirstLine = TRUE .
    if xTog-obj and   x-SelectObject <> "currency":U   Then  DO:
          PUT stream  OutStream  UNFORMATTED  "ПО ОБЪЕКТУ : " + CAPS(ObjName)  AT 30 format "X(170)" SKIP.
          End.
     FORM with FRAME ZAPAS .  DOWN stream   OutStream 1 with FRAME ZAPAS .
      RUN clear--B1 (1) . RUN clear--B1 (2) . RUN clear--B1 (3) .
      RUN clear--B2 (1) .  RUN clear--B2 (2).  RUN clear--B2 (3).
      RUN clear--Bi (1) . RUN clear--Bi (2) . RUN clear--Bi (3) .
      break_group = true.
      break_group1 = true.
   END PROCEDURE.
PROCEDURE Print-Footer :
      If RetClassify = "no-classify":U  then Run U-line.
       gds-zap-artic = "ИТОГО" .
       Run display-BI.
       Run U-line.
       END PROCEDURE.
PROCEDURE U-LINE :
UNDERLINE stream OutStream  sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12
        gds-zap-b-code
        gds-zap-artic
        gds-zap-gds-name
        gds-zap-unit-base
        F-qnty
        F-Summ
        F-Vat
        F-eff
        F-excise
        F-road-tax
        F-transport
        F-Other
        type-Sum
        with FRAME ZAPAS .
        DOWN stream   OutStream 1 with FRAME ZAPAS.
        END PROCEDURE.
PROCEDURE P-LINE :
UNDERLINE stream OutStream
        sym3
        gds-zap-gds-name
        sym4
        gds-zap-unit-base
        sym5
        with FRAME ZAPAS.
        DOWN stream   OutStream 1 with FRAME ZAPAS .
        END PROCEDURE.
procedure run4 :
  case select-good :
      when 1  then do:
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
IF x-SelectObject = "currency":U  OR  xTog-obj THEN DO :
    for each gds-obj  where
          gds-obj.obj-type = x-store-type  and
          gds-obj.obj-code = x-store-code
          and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
      no-lock,
First clients  where  clients.obj-code = gds-obj.prod-code and
                      clients.obj-type = gds-obj.prod-type
                no-lock,
          First goods  where  gds-obj.gds-code   = goods.gds-code
no-lock
BREAK BY ((substring(clients.obj-name,1,10) + string(gds-obj.prod-code)))
      BY (gds-obj.grp-name)
    BY (goods.gds-name) :
      run item-goods ( "4" , "goods" ) .
      if return-value <> "" then NEXT.
        If Last-of(gds-obj.grp-name) Then Do:
        If String(Entry(2,"gds-obj.grp-name",".")) = "Grp-name"
          Then  Assign
                  S-bar-code   = " Итого по "
                  Gds-zap-artic = Substring(
                                       B2-name
                                      ,1,16)
                  Gds-zap-gds-name = Substring(
                                       B2-name
                                      ,17,40)
                                .
          Else  Assign
                  S-bar-code   = ""
                  Gds-zap-artic = "        Итого по "
                  Gds-zap-gds-name =   B2-name
                                .
            Run Display-b1 In This-procedure .
            Run Clear-b1 In This-procedure .
            Assign Break_Group = True.
        End.
        If Last-of((substring(clients.obj-name,1,10) + string(gds-obj.prod-code))) Then Do:
        If String(Entry(2,"(substring(clients.obj-name,1,10) + string(gds-obj.prod-code))",".")) = "Grp-name"
          Then  Assign
              S-bar-code   = "Итого по "
              Gds-zap-artic = Substring(
                                   B1-name
                                  ,1,16)
              Gds-zap-gds-name = Substring(
                                   B1-name
                                  ,17,40)
                            .
          Else Assign
              S-bar-code = ""
              Gds-zap-artic = If  ("4" = "4"  Or  "4" = "5") Then "Итого по "
                                                                 Else "  Итого по "
              Gds-zap-gds-name =   B1-name
              .
          Run Display-b2 In This-procedure .
          Run Clear-b2 In This-procedure .
          Run Clear-b1 In This-procedure .
          Assign  Break_Group1 = True.
        End.
    End.
  END.
  Else DO:
   For each obj-list no-lock :
                  FOR EACH gds-obj where
                gds-obj.obj-type = obj-list.obj-type    and
                gds-obj.obj-code = obj-list.obj-code
                and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
                no-lock :
                if NOT can-find(First temp-gds-list where temp-gds-list.gds-code = gds-obj.gds-code) Then do:
                    find first goods no-lock  where goods.gds-code  = gds-obj.gds-code .
                    Create temp-gds-list.
                    Assign
                      temp-gds-list.prod-code = gds-obj.prod-code
                      temp-gds-list.grp-name  = gds-obj.grp-name
                      temp-gds-list.gds-name  = goods.gds-name
                      temp-gds-list.gds-code  = gds-obj.gds-code
                      temp-gds-list.artic     = gds-obj.artic
                    .
                End.
            End.
  End.
  for each temp-gds-list no-lock
    , First goods     where goods.gds-code  = temp-gds-list.gds-code no-lock
                                     , First clients   where  clients.obj-code = goods.prod-code and
                                                              clients.obj-type = goods.prod-type
      BREAK
BY (substring(clients.obj-name,1,10) + string(gds-obj.prod-code))
BY (gds-obj.grp-name)
    BY goods.gds-name :
    run item-goods ( "4" , "goods" ) .
      if return-value <> "" then NEXT.
        If Last-of(gds-obj.grp-name) Then Do:
        If String(Entry(2,"gds-obj.grp-name",".")) = "Grp-name"
          Then  Assign
                  S-bar-code   = " Итого по "
                  Gds-zap-artic = Substring(
                                       B2-name
                                      ,1,16)
                  Gds-zap-gds-name = Substring(
                                       B2-name
                                      ,17,40)
                                .
          Else  Assign
                  S-bar-code   = ""
                  Gds-zap-artic = "        Итого по "
                  Gds-zap-gds-name =   B2-name
                                .
            Run Display-b1 In This-procedure .
            Run Clear-b1 In This-procedure .
            Assign Break_Group = True.
        End.
        If Last-of((substring(clients.obj-name,1,10) + string(gds-obj.prod-code))) Then Do:
        If String(Entry(2,"(substring(clients.obj-name,1,10) + string(gds-obj.prod-code))",".")) = "Grp-name"
          Then  Assign
              S-bar-code   = "Итого по "
              Gds-zap-artic = Substring(
                                   B1-name
                                  ,1,16)
              Gds-zap-gds-name = Substring(
                                   B1-name
                                  ,17,40)
                            .
          Else Assign
              S-bar-code = ""
              Gds-zap-artic = If  ("4" = "4"  Or  "4" = "5") Then "Итого по "
                                                                 Else "  Итого по "
              Gds-zap-gds-name =   B1-name
              .
          Run Display-b2 In This-procedure .
          Run Clear-b2 In This-procedure .
          Run Clear-b1 In This-procedure .
          Assign  Break_Group1 = True.
        End.
  End.
End.
  end.
      when 2  then do:
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  if x-selectobject = "currency":u  or  xtog-obj then do:
      for  each gds-obj
                  where gds-obj.obj-code   = x-store-code
                   and  gds-obj.obj-type   = x-store-type
                        and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
                        no-lock ,
              first  tmp#grp  where gds-obj.grp-name   begins tmp#grp.grp-name   no-lock ,
              first goods       where gds-obj.gds-code   = goods.gds-code  no-lock
                  break
                  by (substring(clients.obj-name,1,10) + string(gds-obj.prod-code))
                  by gds-obj.grp-name
                  by goods.gds-name :
                  run item-goods ( input "4" , input "goods" ) .
                  if return-value <> "" then next.
        If Last-of(gds-obj.grp-name) Then Do:
        If String(Entry(2,"gds-obj.grp-name",".")) = "Grp-name"
          Then  Assign
                  S-bar-code   = " Итого по "
                  Gds-zap-artic = Substring(
                                       B2-name
                                      ,1,16)
                  Gds-zap-gds-name = Substring(
                                       B2-name
                                      ,17,40)
                                .
          Else  Assign
                  S-bar-code   = ""
                  Gds-zap-artic = "        Итого по "
                  Gds-zap-gds-name =   B2-name
                                .
            Run Display-b1 In This-procedure .
            Run Clear-b1 In This-procedure .
            Assign Break_Group = True.
        End.
        If Last-of((substring(clients.obj-name,1,10) + string(gds-obj.prod-code))) Then Do:
        If String(Entry(2,"(substring(clients.obj-name,1,10) + string(gds-obj.prod-code))",".")) = "Grp-name"
          Then  Assign
              S-bar-code   = "Итого по "
              Gds-zap-artic = Substring(
                                   B1-name
                                  ,1,16)
              Gds-zap-gds-name = Substring(
                                   B1-name
                                  ,17,40)
                            .
          Else Assign
              S-bar-code = ""
              Gds-zap-artic = If  ("4" = "4"  Or  "4" = "5") Then "Итого по "
                                                                 Else "  Итого по "
              Gds-zap-gds-name =   B1-name
              .
          Run Display-b2 In This-procedure .
          Run Clear-b2 In This-procedure .
          Run Clear-b1 In This-procedure .
          Assign  Break_Group1 = True.
        End.
      end.
  end.
  else do:
      for each obj-list no-lock :
            for  each gds-obj
              where  gds-obj.obj-code   = obj-list.obj-code
                and  gds-obj.obj-type   = obj-list.obj-type
                     and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
              no-lock ,
              first  tmp#grp  where gds-obj.grp-name   begins tmp#grp.grp-name   no-lock ,
              first goods       where gds-obj.gds-code   = goods.gds-code  no-lock :
                    if not can-find(first temp-gds-list where temp-gds-list.gds-code = gds-obj.gds-code) then do:
                        create temp-gds-list.
                        assign
                          temp-gds-list.prod-code = gds-obj.prod-code
                          temp-gds-list.grp-name  = gds-obj.grp-name
                          temp-gds-list.gds-name  = goods.grp-name
                          temp-gds-list.gds-code  = gds-obj.gds-code
                          temp-gds-list.artic     = gds-obj.artic
                        .
                    end.
            end.
    end.
  for each temp-gds-list no-lock
    , first goods  where goods.gds-code  = temp-gds-list.gds-code no-lock
      break
        by (substring(clients.obj-name,1,10) + string(gds-obj.prod-code))
        by gds-obj.grp-name
    by goods.gds-name :
    run item-goods ( "4" , "goods" ) .
      if return-value <> "" then next.
        If Last-of(gds-obj.grp-name) Then Do:
        If String(Entry(2,"gds-obj.grp-name",".")) = "Grp-name"
          Then  Assign
                  S-bar-code   = " Итого по "
                  Gds-zap-artic = Substring(
                                       B2-name
                                      ,1,16)
                  Gds-zap-gds-name = Substring(
                                       B2-name
                                      ,17,40)
                                .
          Else  Assign
                  S-bar-code   = ""
                  Gds-zap-artic = "        Итого по "
                  Gds-zap-gds-name =   B2-name
                                .
            Run Display-b1 In This-procedure .
            Run Clear-b1 In This-procedure .
            Assign Break_Group = True.
        End.
        If Last-of((substring(clients.obj-name,1,10) + string(gds-obj.prod-code))) Then Do:
        If String(Entry(2,"(substring(clients.obj-name,1,10) + string(gds-obj.prod-code))",".")) = "Grp-name"
          Then  Assign
              S-bar-code   = "Итого по "
              Gds-zap-artic = Substring(
                                   B1-name
                                  ,1,16)
              Gds-zap-gds-name = Substring(
                                   B1-name
                                  ,17,40)
                            .
          Else Assign
              S-bar-code = ""
              Gds-zap-artic = If  ("4" = "4"  Or  "4" = "5") Then "Итого по "
                                                                 Else "  Итого по "
              Gds-zap-gds-name =   B1-name
              .
          Run Display-b2 In This-procedure .
          Run Clear-b2 In This-procedure .
          Run Clear-b1 In This-procedure .
          Assign  Break_Group1 = True.
        End.
  end.
end.
  end.
      when 3 then do:
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if x-selectobject = "currency":u  or  xtog-obj then do:
  for  each gds-obj
      where  gds-obj.obj-code   = x-store-code
        and  gds-obj.obj-type   = x-store-type
              and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
              no-lock ,
  first g#cli
        where gds-obj.prod-code  = g#cli.obj-code
        and  gds-obj.prod-type   = g#cli.obj-type
        no-lock,
  first goods
        where gds-obj.gds-code = goods.gds-code no-lock
        break
        by (substring(clients.obj-name,1,10) + string(gds-obj.prod-code))
        by (gds-obj.grp-name)
        by goods.gds-name :
        run item-goods ( "4" , "goods" ) .
        if return-value <> "" then next.
        If Last-of(gds-obj.grp-name) Then Do:
        If String(Entry(2,"gds-obj.grp-name",".")) = "Grp-name"
          Then  Assign
                  S-bar-code   = " Итого по "
                  Gds-zap-artic = Substring(
                                       B2-name
                                      ,1,16)
                  Gds-zap-gds-name = Substring(
                                       B2-name
                                      ,17,40)
                                .
          Else  Assign
                  S-bar-code   = ""
                  Gds-zap-artic = "        Итого по "
                  Gds-zap-gds-name =   B2-name
                                .
            Run Display-b1 In This-procedure .
            Run Clear-b1 In This-procedure .
            Assign Break_Group = True.
        End.
        If Last-of((substring(clients.obj-name,1,10) + string(gds-obj.prod-code))) Then Do:
        If String(Entry(2,"(substring(clients.obj-name,1,10) + string(gds-obj.prod-code))",".")) = "Grp-name"
          Then  Assign
              S-bar-code   = "Итого по "
              Gds-zap-artic = Substring(
                                   B1-name
                                  ,1,16)
              Gds-zap-gds-name = Substring(
                                   B1-name
                                  ,17,40)
                            .
          Else Assign
              S-bar-code = ""
              Gds-zap-artic = If  ("4" = "4"  Or  "4" = "5") Then "Итого по "
                                                                 Else "  Итого по "
              Gds-zap-gds-name =   B1-name
              .
          Run Display-b2 In This-procedure .
          Run Clear-b2 In This-procedure .
          Run Clear-b1 In This-procedure .
          Assign  Break_Group1 = True.
        End.
      end.
  end.
  else do:
    for each obj-list no-lock :
          for  each gds-obj
            where  gds-obj.obj-code   = obj-list.obj-code
              and  gds-obj.obj-type   = obj-list.obj-type
                    and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
                    no-lock ,
          first g#cli
              where gds-obj.prod-code  = g#cli.obj-code
              and  gds-obj.prod-type   = g#cli.obj-type
              no-lock,
          first goods
              where gds-obj.gds-code = goods.gds-code no-lock :
                if not can-find (first temp-gds-list where temp-gds-list.gds-code = gds-obj.gds-code) then do:
                    create temp-gds-list.
                    assign
                      temp-gds-list.prod-code = gds-obj.prod-code
                      temp-gds-list.grp-name  = gds-obj.grp-name
                      temp-gds-list.gds-name  = goods.gds-name
                      temp-gds-list.gds-code  = gds-obj.gds-code
                      temp-gds-list.artic     = gds-obj.artic
                    .
                end.
          end.
    end.
      for each temp-gds-list no-lock
        , first goods  where goods.gds-code  = temp-gds-list.gds-code no-lock
          break
            by (substring(clients.obj-name,1,10) + string(gds-obj.prod-code))
            by (gds-obj.grp-name)
            by goods.gds-name :
        run item-goods ( "4" , "goods" ) .
          if return-value <> "" then next.
        If Last-of(gds-obj.grp-name) Then Do:
        If String(Entry(2,"gds-obj.grp-name",".")) = "Grp-name"
          Then  Assign
                  S-bar-code   = " Итого по "
                  Gds-zap-artic = Substring(
                                       B2-name
                                      ,1,16)
                  Gds-zap-gds-name = Substring(
                                       B2-name
                                      ,17,40)
                                .
          Else  Assign
                  S-bar-code   = ""
                  Gds-zap-artic = "        Итого по "
                  Gds-zap-gds-name =   B2-name
                                .
            Run Display-b1 In This-procedure .
            Run Clear-b1 In This-procedure .
            Assign Break_Group = True.
        End.
        If Last-of((substring(clients.obj-name,1,10) + string(gds-obj.prod-code))) Then Do:
        If String(Entry(2,"(substring(clients.obj-name,1,10) + string(gds-obj.prod-code))",".")) = "Grp-name"
          Then  Assign
              S-bar-code   = "Итого по "
              Gds-zap-artic = Substring(
                                   B1-name
                                  ,1,16)
              Gds-zap-gds-name = Substring(
                                   B1-name
                                  ,17,40)
                            .
          Else Assign
              S-bar-code = ""
              Gds-zap-artic = If  ("4" = "4"  Or  "4" = "5") Then "Итого по "
                                                                 Else "  Итого по "
              Gds-zap-gds-name =   B1-name
              .
          Run Display-b2 In This-procedure .
          Run Clear-b2 In This-procedure .
          Run Clear-b1 In This-procedure .
          Assign  Break_Group1 = True.
        End.
      end.
end.
  end.
      otherwise do:
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
IF x-SelectObject = "currency":U  OR  xTog-obj THEN DO :
    for each gds-obj  where
          gds-obj.obj-type = x-store-type  and
          gds-obj.obj-code = x-store-code
          and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
      no-lock,
First clients  where  clients.obj-code = gds-obj.prod-code and
                      clients.obj-type = gds-obj.prod-type
                no-lock,
          First goods  where  gds-obj.gds-code   = goods.gds-code
      no-lock,
First gds-list  where gds-obj.gds-code  = gds-list.gds-code
no-lock
BREAK BY ((substring(clients.obj-name,1,10) + string(gds-list.prod-code)))
      BY (gds-list.grp-name)
    BY (gds-list.gds-name) :
      run item-goods ( "4" , "gds-list" ) .
      if return-value <> "" then NEXT.
        If Last-of(gds-list.grp-name) Then Do:
        If String(Entry(2,"gds-list.grp-name",".")) = "Grp-name"
          Then  Assign
                  S-bar-code   = " Итого по "
                  Gds-zap-artic = Substring(
                                       B2-name
                                      ,1,16)
                  Gds-zap-gds-name = Substring(
                                       B2-name
                                      ,17,40)
                                .
          Else  Assign
                  S-bar-code   = ""
                  Gds-zap-artic = "        Итого по "
                  Gds-zap-gds-name =   B2-name
                                .
            Run Display-b1 In This-procedure .
            Run Clear-b1 In This-procedure .
            Assign Break_Group = True.
        End.
        If Last-of((substring(clients.obj-name,1,10) + string(gds-list.prod-code))) Then Do:
        If String(Entry(2,"(substring(clients.obj-name,1,10) + string(gds-list.prod-code))",".")) = "Grp-name"
          Then  Assign
              S-bar-code   = "Итого по "
              Gds-zap-artic = Substring(
                                   B1-name
                                  ,1,16)
              Gds-zap-gds-name = Substring(
                                   B1-name
                                  ,17,40)
                            .
          Else Assign
              S-bar-code = ""
              Gds-zap-artic = If  ("4" = "4"  Or  "4" = "5") Then "Итого по "
                                                                 Else "  Итого по "
              Gds-zap-gds-name =   B1-name
              .
          Run Display-b2 In This-procedure .
          Run Clear-b2 In This-procedure .
          Run Clear-b1 In This-procedure .
          Assign  Break_Group1 = True.
        End.
    End.
  END.
  Else DO:
   For each obj-list no-lock :
                  FOR EACH gds-obj where
                gds-obj.obj-type = obj-list.obj-type    and
                gds-obj.obj-code = obj-list.obj-code
                and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
                no-lock,
          First gds-list  where gds-obj.gds-code  = gds-list.gds-code
                no-lock :
                if NOT can-find(First temp-gds-list where temp-gds-list.gds-code = gds-obj.gds-code) Then do:
                    find first goods no-lock  where goods.gds-code  = gds-obj.gds-code .
                    Create temp-gds-list.
                    Assign
                      temp-gds-list.prod-code = gds-obj.prod-code
                      temp-gds-list.grp-name  = gds-obj.grp-name
                      temp-gds-list.gds-name  = goods.gds-name
                      temp-gds-list.gds-code  = gds-obj.gds-code
                      temp-gds-list.artic     = gds-obj.artic
                    .
                End.
            End.
  End.
  for each temp-gds-list no-lock
    , First gds-list  where gds-list.gds-code  = temp-gds-list.gds-code no-lock
                                     , First clients   where  clients.obj-code = gds-list.prod-code and
                                                              clients.obj-type = gds-list.prod-type
      BREAK
BY (substring(clients.obj-name,1,10) + string(gds-list.prod-code))
BY (gds-list.grp-name)
    BY gds-list.gds-name :
    run item-goods ( "4" , "gds-list" ) .
      if return-value <> "" then NEXT.
        If Last-of(gds-list.grp-name) Then Do:
        If String(Entry(2,"gds-list.grp-name",".")) = "Grp-name"
          Then  Assign
                  S-bar-code   = " Итого по "
                  Gds-zap-artic = Substring(
                                       B2-name
                                      ,1,16)
                  Gds-zap-gds-name = Substring(
                                       B2-name
                                      ,17,40)
                                .
          Else  Assign
                  S-bar-code   = ""
                  Gds-zap-artic = "        Итого по "
                  Gds-zap-gds-name =   B2-name
                                .
            Run Display-b1 In This-procedure .
            Run Clear-b1 In This-procedure .
            Assign Break_Group = True.
        End.
        If Last-of((substring(clients.obj-name,1,10) + string(gds-list.prod-code))) Then Do:
        If String(Entry(2,"(substring(clients.obj-name,1,10) + string(gds-list.prod-code))",".")) = "Grp-name"
          Then  Assign
              S-bar-code   = "Итого по "
              Gds-zap-artic = Substring(
                                   B1-name
                                  ,1,16)
              Gds-zap-gds-name = Substring(
                                   B1-name
                                  ,17,40)
                            .
          Else Assign
              S-bar-code = ""
              Gds-zap-artic = If  ("4" = "4"  Or  "4" = "5") Then "Итого по "
                                                                 Else "  Итого по "
              Gds-zap-gds-name =   B1-name
              .
          Run Display-b2 In This-procedure .
          Run Clear-b2 In This-procedure .
          Run Clear-b1 In This-procedure .
          Assign  Break_Group1 = True.
        End.
  End.
End.
      end.
  end case.
end procedure.
procedure run5 :
       case select-good:
         when 1  then do:
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
IF x-SelectObject = "currency":U  OR  xTog-obj THEN DO :
    for each gds-obj  where
          gds-obj.obj-type = x-store-type  and
          gds-obj.obj-code = x-store-code
          and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
      no-lock,
First clients  where  clients.obj-code = gds-obj.prod-code and
                      clients.obj-type = gds-obj.prod-type
                no-lock,
          First goods  where  gds-obj.gds-code   = goods.gds-code
no-lock
BREAK BY (gds-obj.grp-name)
      BY ((substring(clients.obj-name,1,10) + string(gds-obj.prod-code)))
    BY (goods.gds-name) :
      run item-goods ( "5" , "goods" ) .
      if return-value <> "" then NEXT.
        If Last-of((substring(clients.obj-name,1,10) + string(gds-obj.prod-code))) Then Do:
        If String(Entry(2,"(substring(clients.obj-name,1,10) + string(gds-obj.prod-code))",".")) = "Grp-name"
          Then  Assign
                  S-bar-code   = " Итого по "
                  Gds-zap-artic = Substring(
                                       B2-name
                                      ,1,16)
                  Gds-zap-gds-name = Substring(
                                       B2-name
                                      ,17,40)
                                .
          Else  Assign
                  S-bar-code   = ""
                  Gds-zap-artic = "        Итого по "
                  Gds-zap-gds-name =   B2-name
                                .
            Run Display-b1 In This-procedure .
            Run Clear-b1 In This-procedure .
            Assign Break_Group = True.
        End.
        If Last-of(gds-obj.grp-name) Then Do:
        If String(Entry(2,"gds-obj.grp-name",".")) = "Grp-name"
          Then  Assign
              S-bar-code   = "Итого по "
              Gds-zap-artic = Substring(
                                   B1-name
                                  ,1,16)
              Gds-zap-gds-name = Substring(
                                   B1-name
                                  ,17,40)
                            .
          Else Assign
              S-bar-code = ""
              Gds-zap-artic = If  ("5" = "4"  Or  "5" = "5") Then "Итого по "
                                                                 Else "  Итого по "
              Gds-zap-gds-name =   B1-name
              .
          Run Display-b2 In This-procedure .
          Run Clear-b2 In This-procedure .
          Run Clear-b1 In This-procedure .
          Assign  Break_Group1 = True.
        End.
    End.
  END.
  Else DO:
   For each obj-list no-lock :
                  FOR EACH gds-obj where
                gds-obj.obj-type = obj-list.obj-type    and
                gds-obj.obj-code = obj-list.obj-code
                and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
                no-lock :
                if NOT can-find(First temp-gds-list where temp-gds-list.gds-code = gds-obj.gds-code) Then do:
                    find first goods no-lock  where goods.gds-code  = gds-obj.gds-code .
                    Create temp-gds-list.
                    Assign
                      temp-gds-list.prod-code = gds-obj.prod-code
                      temp-gds-list.grp-name  = gds-obj.grp-name
                      temp-gds-list.gds-name  = goods.gds-name
                      temp-gds-list.gds-code  = gds-obj.gds-code
                      temp-gds-list.artic     = gds-obj.artic
                    .
                End.
            End.
  End.
  for each temp-gds-list no-lock
    , First goods     where goods.gds-code  = temp-gds-list.gds-code no-lock
                                     , First clients   where  clients.obj-code = goods.prod-code and
                                                              clients.obj-type = goods.prod-type
      BREAK
BY gds-obj.grp-name
BY ((substring(clients.obj-name,1,10) + string(gds-obj.prod-code)))
    BY goods.gds-name :
    run item-goods ( "5" , "goods" ) .
      if return-value <> "" then NEXT.
        If Last-of((substring(clients.obj-name,1,10) + string(gds-obj.prod-code))) Then Do:
        If String(Entry(2,"(substring(clients.obj-name,1,10) + string(gds-obj.prod-code))",".")) = "Grp-name"
          Then  Assign
                  S-bar-code   = " Итого по "
                  Gds-zap-artic = Substring(
                                       B2-name
                                      ,1,16)
                  Gds-zap-gds-name = Substring(
                                       B2-name
                                      ,17,40)
                                .
          Else  Assign
                  S-bar-code   = ""
                  Gds-zap-artic = "        Итого по "
                  Gds-zap-gds-name =   B2-name
                                .
            Run Display-b1 In This-procedure .
            Run Clear-b1 In This-procedure .
            Assign Break_Group = True.
        End.
        If Last-of(gds-obj.grp-name) Then Do:
        If String(Entry(2,"gds-obj.grp-name",".")) = "Grp-name"
          Then  Assign
              S-bar-code   = "Итого по "
              Gds-zap-artic = Substring(
                                   B1-name
                                  ,1,16)
              Gds-zap-gds-name = Substring(
                                   B1-name
                                  ,17,40)
                            .
          Else Assign
              S-bar-code = ""
              Gds-zap-artic = If  ("5" = "4"  Or  "5" = "5") Then "Итого по "
                                                                 Else "  Итого по "
              Gds-zap-gds-name =   B1-name
              .
          Run Display-b2 In This-procedure .
          Run Clear-b2 In This-procedure .
          Run Clear-b1 In This-procedure .
          Assign  Break_Group1 = True.
        End.
  End.
End.
  end.
         when 2  then do:
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  if x-selectobject = "currency":u  or  xtog-obj then do:
      for  each gds-obj
                  where gds-obj.obj-code   = x-store-code
                   and  gds-obj.obj-type   = x-store-type
                        and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
                        no-lock ,
              first  tmp#grp  where gds-obj.grp-name   begins tmp#grp.grp-name   no-lock ,
              first goods       where gds-obj.gds-code   = goods.gds-code  no-lock
                  break
                  by gds-obj.grp-name
                  by (substring(clients.obj-name,1,10) + string(gds-obj.prod-code))
                  by goods.gds-name :
                  run item-goods ( input "5" , input "goods" ) .
                  if return-value <> "" then next.
        If Last-of((substring(clients.obj-name,1,10) + string(gds-obj.prod-code))) Then Do:
        If String(Entry(2,"(substring(clients.obj-name,1,10) + string(gds-obj.prod-code))",".")) = "Grp-name"
          Then  Assign
                  S-bar-code   = " Итого по "
                  Gds-zap-artic = Substring(
                                       B2-name
                                      ,1,16)
                  Gds-zap-gds-name = Substring(
                                       B2-name
                                      ,17,40)
                                .
          Else  Assign
                  S-bar-code   = ""
                  Gds-zap-artic = "        Итого по "
                  Gds-zap-gds-name =   B2-name
                                .
            Run Display-b1 In This-procedure .
            Run Clear-b1 In This-procedure .
            Assign Break_Group = True.
        End.
        If Last-of(gds-obj.grp-name) Then Do:
        If String(Entry(2,"gds-obj.grp-name",".")) = "Grp-name"
          Then  Assign
              S-bar-code   = "Итого по "
              Gds-zap-artic = Substring(
                                   B1-name
                                  ,1,16)
              Gds-zap-gds-name = Substring(
                                   B1-name
                                  ,17,40)
                            .
          Else Assign
              S-bar-code = ""
              Gds-zap-artic = If  ("5" = "4"  Or  "5" = "5") Then "Итого по "
                                                                 Else "  Итого по "
              Gds-zap-gds-name =   B1-name
              .
          Run Display-b2 In This-procedure .
          Run Clear-b2 In This-procedure .
          Run Clear-b1 In This-procedure .
          Assign  Break_Group1 = True.
        End.
      end.
  end.
  else do:
      for each obj-list no-lock :
            for  each gds-obj
              where  gds-obj.obj-code   = obj-list.obj-code
                and  gds-obj.obj-type   = obj-list.obj-type
                     and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
              no-lock ,
              first  tmp#grp  where gds-obj.grp-name   begins tmp#grp.grp-name   no-lock ,
              first goods       where gds-obj.gds-code   = goods.gds-code  no-lock :
                    if not can-find(first temp-gds-list where temp-gds-list.gds-code = gds-obj.gds-code) then do:
                        create temp-gds-list.
                        assign
                          temp-gds-list.prod-code = gds-obj.prod-code
                          temp-gds-list.grp-name  = gds-obj.grp-name
                          temp-gds-list.gds-name  = goods.grp-name
                          temp-gds-list.gds-code  = gds-obj.gds-code
                          temp-gds-list.artic     = gds-obj.artic
                        .
                    end.
            end.
    end.
  for each temp-gds-list no-lock
    , first goods  where goods.gds-code  = temp-gds-list.gds-code no-lock
      break
        by gds-obj.grp-name
        by (substring(clients.obj-name,1,10) + string(gds-obj.prod-code))
    by goods.gds-name :
    run item-goods ( "5" , "goods" ) .
      if return-value <> "" then next.
        If Last-of((substring(clients.obj-name,1,10) + string(gds-obj.prod-code))) Then Do:
        If String(Entry(2,"(substring(clients.obj-name,1,10) + string(gds-obj.prod-code))",".")) = "Grp-name"
          Then  Assign
                  S-bar-code   = " Итого по "
                  Gds-zap-artic = Substring(
                                       B2-name
                                      ,1,16)
                  Gds-zap-gds-name = Substring(
                                       B2-name
                                      ,17,40)
                                .
          Else  Assign
                  S-bar-code   = ""
                  Gds-zap-artic = "        Итого по "
                  Gds-zap-gds-name =   B2-name
                                .
            Run Display-b1 In This-procedure .
            Run Clear-b1 In This-procedure .
            Assign Break_Group = True.
        End.
        If Last-of(gds-obj.grp-name) Then Do:
        If String(Entry(2,"gds-obj.grp-name",".")) = "Grp-name"
          Then  Assign
              S-bar-code   = "Итого по "
              Gds-zap-artic = Substring(
                                   B1-name
                                  ,1,16)
              Gds-zap-gds-name = Substring(
                                   B1-name
                                  ,17,40)
                            .
          Else Assign
              S-bar-code = ""
              Gds-zap-artic = If  ("5" = "4"  Or  "5" = "5") Then "Итого по "
                                                                 Else "  Итого по "
              Gds-zap-gds-name =   B1-name
              .
          Run Display-b2 In This-procedure .
          Run Clear-b2 In This-procedure .
          Run Clear-b1 In This-procedure .
          Assign  Break_Group1 = True.
        End.
  end.
end.
  end.
         when 3 then do:
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if x-selectobject = "currency":u  or  xtog-obj then do:
  for  each gds-obj
      where  gds-obj.obj-code   = x-store-code
        and  gds-obj.obj-type   = x-store-type
              and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
              no-lock ,
  first g#cli
        where gds-obj.prod-code  = g#cli.obj-code
        and  gds-obj.prod-type   = g#cli.obj-type
        no-lock,
  first goods
        where gds-obj.gds-code = goods.gds-code no-lock
        break
        by gds-obj.grp-name
        by ((substring(clients.obj-name,1,10) + string(gds-obj.prod-code)))
        by goods.gds-name :
        run item-goods ( "5" , "goods" ) .
        if return-value <> "" then next.
        If Last-of((substring(clients.obj-name,1,10) + string(gds-obj.prod-code))) Then Do:
        If String(Entry(2,"(substring(clients.obj-name,1,10) + string(gds-obj.prod-code))",".")) = "Grp-name"
          Then  Assign
                  S-bar-code   = " Итого по "
                  Gds-zap-artic = Substring(
                                       B2-name
                                      ,1,16)
                  Gds-zap-gds-name = Substring(
                                       B2-name
                                      ,17,40)
                                .
          Else  Assign
                  S-bar-code   = ""
                  Gds-zap-artic = "        Итого по "
                  Gds-zap-gds-name =   B2-name
                                .
            Run Display-b1 In This-procedure .
            Run Clear-b1 In This-procedure .
            Assign Break_Group = True.
        End.
        If Last-of(gds-obj.grp-name) Then Do:
        If String(Entry(2,"gds-obj.grp-name",".")) = "Grp-name"
          Then  Assign
              S-bar-code   = "Итого по "
              Gds-zap-artic = Substring(
                                   B1-name
                                  ,1,16)
              Gds-zap-gds-name = Substring(
                                   B1-name
                                  ,17,40)
                            .
          Else Assign
              S-bar-code = ""
              Gds-zap-artic = If  ("5" = "4"  Or  "5" = "5") Then "Итого по "
                                                                 Else "  Итого по "
              Gds-zap-gds-name =   B1-name
              .
          Run Display-b2 In This-procedure .
          Run Clear-b2 In This-procedure .
          Run Clear-b1 In This-procedure .
          Assign  Break_Group1 = True.
        End.
      end.
  end.
  else do:
    for each obj-list no-lock :
          for  each gds-obj
            where  gds-obj.obj-code   = obj-list.obj-code
              and  gds-obj.obj-type   = obj-list.obj-type
                    and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
                    no-lock ,
          first g#cli
              where gds-obj.prod-code  = g#cli.obj-code
              and  gds-obj.prod-type   = g#cli.obj-type
              no-lock,
          first goods
              where gds-obj.gds-code = goods.gds-code no-lock :
                if not can-find (first temp-gds-list where temp-gds-list.gds-code = gds-obj.gds-code) then do:
                    create temp-gds-list.
                    assign
                      temp-gds-list.prod-code = gds-obj.prod-code
                      temp-gds-list.grp-name  = gds-obj.grp-name
                      temp-gds-list.gds-name  = goods.gds-name
                      temp-gds-list.gds-code  = gds-obj.gds-code
                      temp-gds-list.artic     = gds-obj.artic
                    .
                end.
          end.
    end.
      for each temp-gds-list no-lock
        , first goods  where goods.gds-code  = temp-gds-list.gds-code no-lock
          break
            by gds-obj.grp-name
            by ((substring(clients.obj-name,1,10) + string(gds-obj.prod-code)))
            by goods.gds-name :
        run item-goods ( "5" , "goods" ) .
          if return-value <> "" then next.
        If Last-of((substring(clients.obj-name,1,10) + string(gds-obj.prod-code))) Then Do:
        If String(Entry(2,"(substring(clients.obj-name,1,10) + string(gds-obj.prod-code))",".")) = "Grp-name"
          Then  Assign
                  S-bar-code   = " Итого по "
                  Gds-zap-artic = Substring(
                                       B2-name
                                      ,1,16)
                  Gds-zap-gds-name = Substring(
                                       B2-name
                                      ,17,40)
                                .
          Else  Assign
                  S-bar-code   = ""
                  Gds-zap-artic = "        Итого по "
                  Gds-zap-gds-name =   B2-name
                                .
            Run Display-b1 In This-procedure .
            Run Clear-b1 In This-procedure .
            Assign Break_Group = True.
        End.
        If Last-of(gds-obj.grp-name) Then Do:
        If String(Entry(2,"gds-obj.grp-name",".")) = "Grp-name"
          Then  Assign
              S-bar-code   = "Итого по "
              Gds-zap-artic = Substring(
                                   B1-name
                                  ,1,16)
              Gds-zap-gds-name = Substring(
                                   B1-name
                                  ,17,40)
                            .
          Else Assign
              S-bar-code = ""
              Gds-zap-artic = If  ("5" = "4"  Or  "5" = "5") Then "Итого по "
                                                                 Else "  Итого по "
              Gds-zap-gds-name =   B1-name
              .
          Run Display-b2 In This-procedure .
          Run Clear-b2 In This-procedure .
          Run Clear-b1 In This-procedure .
          Assign  Break_Group1 = True.
        End.
      end.
end.
  end.
         otherwise do:
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
IF x-SelectObject = "currency":U  OR  xTog-obj THEN DO :
    for each gds-obj  where
          gds-obj.obj-type = x-store-type  and
          gds-obj.obj-code = x-store-code
          and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
      no-lock,
First clients  where  clients.obj-code = gds-obj.prod-code and
                      clients.obj-type = gds-obj.prod-type
                no-lock,
          First goods  where  gds-obj.gds-code   = goods.gds-code
      no-lock,
First gds-list  where gds-obj.gds-code  = gds-list.gds-code
no-lock
BREAK BY (gds-list.grp-name)
      BY ((substring(clients.obj-name,1,10) + string(gds-list.prod-code)))
    BY (gds-list.gds-name) :
      run item-goods ( "5" , "gds-list" ) .
      if return-value <> "" then NEXT.
        If Last-of((substring(clients.obj-name,1,10) + string(gds-list.prod-code))) Then Do:
        If String(Entry(2,"(substring(clients.obj-name,1,10) + string(gds-list.prod-code))",".")) = "Grp-name"
          Then  Assign
                  S-bar-code   = " Итого по "
                  Gds-zap-artic = Substring(
                                       B2-name
                                      ,1,16)
                  Gds-zap-gds-name = Substring(
                                       B2-name
                                      ,17,40)
                                .
          Else  Assign
                  S-bar-code   = ""
                  Gds-zap-artic = "        Итого по "
                  Gds-zap-gds-name =   B2-name
                                .
            Run Display-b1 In This-procedure .
            Run Clear-b1 In This-procedure .
            Assign Break_Group = True.
        End.
        If Last-of(gds-list.grp-name) Then Do:
        If String(Entry(2,"gds-list.grp-name",".")) = "Grp-name"
          Then  Assign
              S-bar-code   = "Итого по "
              Gds-zap-artic = Substring(
                                   B1-name
                                  ,1,16)
              Gds-zap-gds-name = Substring(
                                   B1-name
                                  ,17,40)
                            .
          Else Assign
              S-bar-code = ""
              Gds-zap-artic = If  ("5" = "4"  Or  "5" = "5") Then "Итого по "
                                                                 Else "  Итого по "
              Gds-zap-gds-name =   B1-name
              .
          Run Display-b2 In This-procedure .
          Run Clear-b2 In This-procedure .
          Run Clear-b1 In This-procedure .
          Assign  Break_Group1 = True.
        End.
    End.
  END.
  Else DO:
   For each obj-list no-lock :
                  FOR EACH gds-obj where
                gds-obj.obj-type = obj-list.obj-type    and
                gds-obj.obj-code = obj-list.obj-code
                and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
                no-lock,
          First gds-list  where gds-obj.gds-code  = gds-list.gds-code
                no-lock :
                if NOT can-find(First temp-gds-list where temp-gds-list.gds-code = gds-obj.gds-code) Then do:
                    find first goods no-lock  where goods.gds-code  = gds-obj.gds-code .
                    Create temp-gds-list.
                    Assign
                      temp-gds-list.prod-code = gds-obj.prod-code
                      temp-gds-list.grp-name  = gds-obj.grp-name
                      temp-gds-list.gds-name  = goods.gds-name
                      temp-gds-list.gds-code  = gds-obj.gds-code
                      temp-gds-list.artic     = gds-obj.artic
                    .
                End.
            End.
  End.
  for each temp-gds-list no-lock
    , First gds-list  where gds-list.gds-code  = temp-gds-list.gds-code no-lock
                                     , First clients   where  clients.obj-code = gds-list.prod-code and
                                                              clients.obj-type = gds-list.prod-type
      BREAK
BY gds-list.grp-name
BY ((substring(clients.obj-name,1,10) + string(gds-list.prod-code)))
    BY gds-list.gds-name :
    run item-goods ( "5" , "gds-list" ) .
      if return-value <> "" then NEXT.
        If Last-of((substring(clients.obj-name,1,10) + string(gds-list.prod-code))) Then Do:
        If String(Entry(2,"(substring(clients.obj-name,1,10) + string(gds-list.prod-code))",".")) = "Grp-name"
          Then  Assign
                  S-bar-code   = " Итого по "
                  Gds-zap-artic = Substring(
                                       B2-name
                                      ,1,16)
                  Gds-zap-gds-name = Substring(
                                       B2-name
                                      ,17,40)
                                .
          Else  Assign
                  S-bar-code   = ""
                  Gds-zap-artic = "        Итого по "
                  Gds-zap-gds-name =   B2-name
                                .
            Run Display-b1 In This-procedure .
            Run Clear-b1 In This-procedure .
            Assign Break_Group = True.
        End.
        If Last-of(gds-list.grp-name) Then Do:
        If String(Entry(2,"gds-list.grp-name",".")) = "Grp-name"
          Then  Assign
              S-bar-code   = "Итого по "
              Gds-zap-artic = Substring(
                                   B1-name
                                  ,1,16)
              Gds-zap-gds-name = Substring(
                                   B1-name
                                  ,17,40)
                            .
          Else Assign
              S-bar-code = ""
              Gds-zap-artic = If  ("5" = "4"  Or  "5" = "5") Then "Итого по "
                                                                 Else "  Итого по "
              Gds-zap-gds-name =   B1-name
              .
          Run Display-b2 In This-procedure .
          Run Clear-b2 In This-procedure .
          Run Clear-b1 In This-procedure .
          Assign  Break_Group1 = True.
        End.
  End.
End.
         end.
      end case.
end procedure.
procedure run7 :
      case select-good:
        when 1  then do:
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
IF x-SelectObject = "currency":U  OR  xTog-obj then do :
define variable first-l26 as logical   no-undo .
  first-l26 = true .
  for each gds-obj
    where gds-obj.obj-type = x-store-type
      and gds-obj.obj-code = x-store-code
          and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
          no-lock,
      first goods  where  goods.gds-code = gds-obj.gds-code
      no-lock
      break by func-vat (input gds-obj.gds-code , input x-store-type, input x-store-code)
            by (goods.gds-name)
            :
      var-vat-pc = func-vat ( input gds-obj.gds-code, input x-store-type, input x-store-code) .
      if last-vat <> var-vat-pc then do:
          if not first-l26 then do:
            Assign
                s-bar-code    = ""
                gds-zap-artic = "        Итого по "
                gds-zap-gds-name = b1-name
                .
              run display-b1.
              run clear-b1  .
          end.
          Assign
            first-l26 = false
            break_group = true
            break_group1 = true
            .
          end.
      first-l26 = false .
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
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
      BREAK BY (func-vat(gds-obj.gds-code,gds-obj.obj-type,gds-obj.obj-code))  BY goods.gds-name :
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
        when 2  then do:
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if x-selectobject = "currency":u  or  xtog-obj then do :
define variable first-l29 as logical   no-undo .
  first-l29 = true .
      for  each gds-obj where
                gds-obj.obj-code   = x-store-code and
                gds-obj.obj-type   = x-store-type
                and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
                no-lock ,
      first  tmp#grp  where gds-obj.grp-name   begins tmp#grp.grp-name   no-lock ,
      first goods       where gds-obj.gds-code   = goods.gds-code  no-lock
      break by func-vat (input gds-obj.gds-code , input x-store-type, input x-store-code)
            by (goods.gds-name)
            :
      var-vat-pc = func-vat ( input gds-obj.gds-code, input x-store-type, input x-store-code) .
      if last-vat <> var-vat-pc then do:
          if not first-l29 then do:
            Assign
                s-bar-code    = ""
                gds-zap-artic = "        Итого по "
                gds-zap-gds-name = b1-name
                .
              run display-b1.
              run clear-b1  .
          end.
          Assign
            first-l29 = false
            break_group = true
            break_group1 = true
            .
          end.
      first-l29 = false .
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
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
      break by (func-vat(gds-obj.gds-code,gds-obj.obj-type,gds-obj.obj-code))  by goods.gds-name :
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
        when 3 then do:
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if x-selectobject = "currency":u or xtog-obj then do:
define variable first-l31 as logical   no-undo .
  first-l31 = true .
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
            by (goods.gds-name)
            :
      var-vat-pc = func-vat ( input gds-obj.gds-code, input x-store-type, input x-store-code) .
      if last-vat <> var-vat-pc then do:
          if not first-l31 then do:
            Assign
                s-bar-code    = ""
                gds-zap-artic = "        Итого по "
                gds-zap-gds-name = b1-name
                .
              run display-b1.
              run clear-b1  .
          end.
          Assign
            first-l31 = false
            break_group = true
            break_group1 = true
            .
          end.
      first-l31 = false .
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
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
          break by (func-vat(gds-obj.gds-code,gds-obj.obj-type,gds-obj.obj-code))   by goods.gds-name :
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
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
IF x-SelectObject = "currency":U  OR  xTog-obj then do :
define variable first-l33 as logical   no-undo .
  first-l33 = true .
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
            by (gds-list.gds-name)
            :
      var-vat-pc = func-vat ( input gds-obj.gds-code, input x-store-type, input x-store-code) .
      if last-vat <> var-vat-pc then do:
          if not first-l33 then do:
            Assign
                s-bar-code    = ""
                gds-zap-artic = "        Итого по "
                gds-zap-gds-name = b1-name
                .
              run display-b1.
              run clear-b1  .
          end.
          Assign
            first-l33 = false
            break_group = true
            break_group1 = true
            .
          end.
      first-l33 = false .
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
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
      BREAK BY (func-vat(gds-obj.gds-code,gds-obj.obj-type,gds-obj.obj-code))  BY gds-list.gds-name :
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
        input x-store-type  , x-TOG-Shift,
        input x-date-start - 1 ,
        input date('')      ,  x-Shift-Start,x-Shift-End,
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
define variable jjj as integer no-undo init 0.
if show-cost and show-sale then
   assign
      eff[1] = Summ[3]  - Summ[1]
      eff[3] = if Summ[1] <> 0 then ((Summ[3]  - Summ[1]) * 100 / Summ[1] )  else 0
    .
           if show-cost then DO:  Run di (1,"учет", 1, gds-zap-b-code,gds-zap-artic,gds-zap-gds-name,gds-zap-unit-base,"").  jjj = jjj + 1. End.
           if show-crsa then DO:
             if jjj = 0
                then   Run di (2,"прод", 1, gds-zap-b-code,gds-zap-artic,gds-zap-gds-name,gds-zap-unit-base,"").
                Else   Run di (2,"прод", 1, "","","","","").
               jjj = jjj + 1. End.
           if show-sale then DO:  if jjj = 0
              then Run di (3,"док.", 1, gds-zap-b-code,gds-zap-artic,gds-zap-gds-name,gds-zap-unit-base,"").
              Else Run di (3,"док.", 1, "","","","","").
              jjj = jjj + 1. End.
END PROCEDURE.
PROCEDURE display-Bi  :
if show-cost and show-sale then
   assign
      bi-eff[1] = bi-Summ [3]  - bi-Summ  [1]
      bi-eff[3] = if bi-Summ  [1] <> 0 then ((bi-Summ [3]  - bi-Summ  [1]) * 100 / bi-Summ  [1] )
                                else 0
    .
           if show-cost then run di(1,"учет",1,  "", gds-zap-artic ,"" ,"", "BI":U).
           if show-crsa then run di(2,"прод",1,  "", gds-zap-artic ,"" ,"", "BI":U).
           if show-sale then run di(3,"док.",1,  "", gds-zap-artic ,"" ,"", "BI":U).
END PROCEDURE.
PROCEDURE display-B1  :
IF  NOT (NOT Show-Negativ  AND
 (
b1-qnty     [1]    = 0 and  b1-qnty     [2]    = 0 and b1-qnty     [3]    = 0  and
b1-Summ     [1]    = 0 and  b1-Summ     [2]    = 0 and  b1-Summ     [3]    = 0 and
b1-Vat      [1]    = 0 and  b1-Vat      [2]    = 0 and  b1-Vat      [3]    = 0 and
b1-excise   [1]    = 0 and  b1-excise   [2]    = 0 and  b1-excise   [3]    = 0 and
b1-road-tax [1]    = 0 and  b1-road-tax [2]    = 0 and  b1-road-tax [3]    = 0 and
b1-transport[1]    = 0 and  b1-transport[2]    = 0 and  b1-transport[3]    = 0 and
b1-Other    [1]    = 0 and  b1-Other    [2]    = 0 and  b1-Other    [3]    = 0 )) Then DO:
  if Sums-Only THEN do:
      if fr0 = true then do:
          PUT stream  OutStream  tmp#stroka0 format "X(100)" SKIP.
          if Make-Excel then  put   stream ForExcel unformatted String(tmp#stroka0) skip.
          fr0 = false .
        end.
    end.
    assign
     gds-zap-artic = "Итого"
     gds-zap-gds-name = temp-str
    .
        if show-cost and show-sale then
          assign
              b1-eff[1] = b1-Summ [3]  - b1-Summ  [1]
              b1-eff[3] = if b1-Summ  [1] <> 0 then ((b1-Summ [3]  - b1-Summ  [1]) * 100 / b1-Summ  [1] )
                                        else 0
            .
         if show-cost then  Run di(1,"учет"  ,1, "", gds-zap-artic, gds-zap-gds-name ,"","B1":U).
         if show-crsa then  Run di(2,"прод"  ,1, "", gds-zap-artic, gds-zap-gds-name ,"","B1":U).
         if show-sale then  Run di(3,"док."  ,1, "", gds-zap-artic, gds-zap-gds-name ,"","B1":U).
  Run u-line.
  End.
END PROCEDURE.
PROCEDURE display-B2  :
IF  NOT (NOT Show-Negativ  AND
  ( b2-qnty     [1]    = 0 and  b2-qnty     [2]    = 0 and  b2-qnty     [3]    = 0 and
    b2-Summ     [1]    = 0 and  b2-Summ     [2]    = 0 and  b2-Summ     [3]    = 0 and
    b2-Vat      [1]    = 0 and  b2-Vat      [2]    = 0 and  b2-Vat      [3]    = 0 and
    b2-excise   [1]    = 0 and  b2-excise   [2]    = 0 and  b2-excise   [3]    = 0 and
    b2-road-tax [1]    = 0 and  b2-road-tax [2]    = 0 and  b2-road-tax [3]    = 0 and
    b2-transport[1]    = 0 and  b2-transport[2]    = 0 and  b2-transport[3]    = 0 and
    b2-Other    [1]    = 0 and  b2-Other    [2]    = 0 and  b2-Other    [3]    = 0 ) )Then dO:
    assign
     gds-zap-artic = ""
     gds-zap-gds-name = tmp#stroka0
    .
        if show-cost and show-sale then
        assign
            b2-eff[1] = b2-Summ [3]  - b2-Summ  [1]
            b2-eff[3] = if b2-Summ  [1] <> 0 then ((b2-Summ [3]  - b2-Summ  [1]) * 100 / b2-Summ  [1] )
                                      else 0
          .
       if show-cost then  Run di (1, "учет", 1 ,"Итого",gds-zap-artic, gds-zap-gds-name,"", "B2":U).
       if show-crsa then  Run di (2, "прод", 1 ,"Итого",gds-zap-artic, gds-zap-gds-name,"", "B2":U).
       if show-sale then  Run di (3, "док.", 1 ,"Итого",gds-zap-artic, gds-zap-gds-name,"", "B2":U).
       Run u-line.
end.
END PROCEDURE.
PROCEDURE Clear--B1  :
define input parameter tt#          as   int                 no-undo.
 Assign
    b1-qnty     [tt#]   = 0
    b1-Summ     [tt#]    = 0
    b1-Vat      [tt#]    = 0
    b1-eff      [tt#]    = 0
    b1-excise   [tt#]    = 0
    b1-road-tax [tt#]    = 0
    b1-transport[tt#]    = 0
    b1-Other    [tt#]    = 0  .
 END PROCEDURE.
PROCEDURE Clear--B2  :
define input parameter tt#          as   int                 no-undo.
 Assign
    b2-qnty         = 0
    b2-Summ        [tt#]  = 0
    b2-Vat         [tt#]  = 0
    b2-eff         [tt#]  = 0
    b2-excise      [tt#]  = 0
    b2-road-tax    [tt#]  = 0
    b2-transport   [tt#]  = 0
    b2-Other       [tt#]  = 0  .
END PROCEDURE.
PROCEDURE Clear--Bi  :
define input parameter tt#          as   int                 no-undo.
 Assign
    bi-qnty         = 0
    bi-Summ        [tt#]  = 0
    bi-Vat         [tt#]  = 0
    bi-eff         [tt#]  = 0
    bi-excise      [tt#]  = 0
    bi-road-tax    [tt#]  = 0
    bi-transport   [tt#]  = 0
    bi-Other       [tt#]  = 0  .
END PROCEDURE.
PROCEDURE Display-title :
   PUT stream  OutStream  UNFORMATTED  string( v-cntxt-host-name-obj +  " , " + x-store-type  +  " " + ObjName) AT 50 format "X(85)" SKIP(2)
          REPORTNAME  AT 20 format "X(170)" SKIP
          Trim(str1)  AT 35 format "X(75)" SKIP.
     Repeat i = 1 to NUM-ENTRIES(str2,chr(10)) :
      PUT stream  OutStream  UNFORMATTED  Entry(i,str2,chr(10))  AT 1 format "X(170)" SKIP.
     End.
    i=0.
     Repeat i = 1 to NUM-ENTRIES(str3,chr(10)) :
      PUT stream  OutStream  UNFORMATTED  Entry(i,str3,chr(10))  AT 1 format "X(170)" SKIP.
     End.
    i=0.
     Repeat i = 1 to NUM-ENTRIES(str4,chr(10)) :
      PUT stream  OutStream  UNFORMATTED  Entry(i,str4,chr(10))  AT 1 format "X(170)" SKIP.
     End.
    i=0.
     Repeat i = 1 to NUM-ENTRIES(ReportHeader,chr(10)) :
      PUT stream  OutStream  UNFORMATTED  Entry(i,ReportHeader,chr(10))  AT 1 format "X(170)" SKIP.
     End.
    i=0.
END PROCEDURE.
PROCEDURE ob-line  :
define input  parameter x-store-code     like ub.clients.obj-code     no-undo.
define input  parameter x-store-type     like ub.clients.obj-type     no-undo.
define INPUT  parameter x-artic          like ub.ot-line.artic        no-undo.
define INPUT  parameter x-prod-code      like ub.ot-line.prod-code    no-undo.
define INPUT  parameter x-prod-type      like ub.ot-line.prod-type    no-undo.
define INPUT  parameter x-Fact-order-1   like ub.ot-line.Fact-order   no-undo.
define INPUT  parameter x-Fact-order-2   like ub.ot-line.Fact-order   no-undo.
define input  parameter x-sum-type       like ub.ot-line.sum-type     no-undo.
define input  parameter x-cat-id         like ub.ot-line.cat-id       no-undo.
define input  parameter x-ext-doc-type   like ub.ot-line.ext-doc-type no-undo.
define input  parameter xTog-obj         as   log                  no-undo.
define variable  tt#          as   int                 no-undo.
 if x-sum-type = 'cost':U  OR x-sum-type = 'cssr':U  then tt# = 1.
  if x-sum-type = 'crsa':U  OR x-sum-type = 'cgsr':U  then tt# = 2.
  if x-sum-type = 'sale':U  OR x-sum-type = 'sasr':U  then tt# = 3.
  For EAch obj-list no-lock:
   if  xTog-obj THEN
       if   NOT(    x-store-type     = obj-list.obj-type
            AND    x-store-code      = obj-list.obj-code ) Then NEXT.
     IF x-ext-doc-type = 'rs':U + ',' + 'es':U  Then DO:
       FOR each ub.ot-line where
                        ub.ot-line.artic         = x-artic
                  AND   ub.ot-line.fact-order   <= x-fact-order-2
                  AND   ub.ot-line.fact-order   >= x-fact-order-1
                  AND   ub.ot-line.obj-code     = obj-list.obj-code
                  AND   ub.ot-line.obj-type     = obj-list.obj-type
                  AND   ub.ot-line.prod-code    = x-prod-code
                  AND   ub.ot-line.prod-type    = x-prod-type
                  AND   ub.ot-line.sum-type     = x-sum-type
                  And   (ot-line.ext-doc-type = 'rs':U
                         OR ub.ot-line.ext-doc-type = 'es':U)
                    no-lock :
           If tPrintRubl = yes Then
           ASSIGN qnty       [tt#]     = qnty     [tt#]        +  ub.ot-line.fact-qnty
                  Summ     [tt#]     = Summ      [tt#]      +  ub.ot-line.sum-rubl
                  Vat      [tt#]     = Vat       [tt#]      +  ub.ot-line.VAT-rubl
                  excise   [tt#]     = excise    [tt#]      +  ub.ot-line.excise-rubl
                  road-tax [tt#]     = road-tax  [tt#]      +  ub.ot-line.road-tax-rubl
                  transport[tt#]     = transport [tt#]      +  ub.ot-line.transport-rubl
                  Other    [tt#]     = Other     [tt#]      +  ub.ot-line.Other-rubl           .
           Else
           ASSIGN qnty       [tt#]     = qnty       [tt#]      +  ub.ot-line.fact-qnty
                  Summ      [tt#]     = Summ        [tt#]    +  ub.ot-line.sum-base
                  Vat       [tt#]     = Vat         [tt#]    +  ub.ot-line.VAT-base
                  excise    [tt#]     = excise      [tt#]    +  ub.ot-line.excise-base
                  road-tax  [tt#]     = road-tax    [tt#]    +  ub.ot-line.road-tax-base
                  transport [tt#]     = transport   [tt#]    +  ub.ot-line.transport-base
                  Other     [tt#]     = Other       [tt#]    +  ub.ot-line.Other-base           .
        End.
     End.
     Else DO:
       FOR each ub.ot-line where
                        ub.ot-line.artic         = x-artic
                  AND   ub.ot-line.fact-order   <= x-fact-order-2
                  AND   ub.ot-line.fact-order   >= x-fact-order-1
                  AND   ub.ot-line.obj-code     = obj-list.obj-code
                  AND   ub.ot-line.obj-type     = obj-list.obj-type
                  AND   ub.ot-line.prod-code    = x-prod-code
                  AND   ub.ot-line.prod-type    = x-prod-type
                  AND   ub.ot-line.sum-type     = x-sum-type
                  And   ub.ot-line.ext-doc-type = x-ext-doc-type
                    no-lock :
           If tPrintRubl = yes Then
           ASSIGN qnty  [tt#]          = qnty    [tt#]         +  ub.ot-line.fact-qnty
                  Summ       [tt#]    = Summ       [tt#]     +  ub.ot-line.sum-rubl
                  Vat        [tt#]    = Vat        [tt#]     +  ub.ot-line.VAT-rubl
                  excise     [tt#]    = excise     [tt#]     +  ub.ot-line.excise-rubl
                  road-tax   [tt#]    = road-tax   [tt#]     +  ub.ot-line.road-tax-rubl
                  transport  [tt#]    = transport  [tt#]     +  ub.ot-line.transport-rubl
                  Other      [tt#]    = Other      [tt#]     +  ub.ot-line.Other-rubl           .
           Else
           ASSIGN qnty    [tt#]        = qnty     [tt#]        +  ub.ot-line.fact-qnty
                  Summ       [tt#]    = Summ        [tt#]    +  ub.ot-line.sum-base
                  Vat        [tt#]    = Vat         [tt#]    +  ub.ot-line.VAT-base
                  excise     [tt#]    = excise      [tt#]    +  ub.ot-line.excise-base
                  road-tax   [tt#]    = road-tax    [tt#]    +  ub.ot-line.road-tax-base
                  transport  [tt#]    = transport   [tt#]    +  ub.ot-line.transport-base
                  Other      [tt#]    = Other       [tt#]    +  ub.ot-line.Other-base           .
        End.
      End.
  END.
END PROCEDURE.
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
  PROCEDURE Calc-Sub-itog :
  define input parameter tt#          as   int                 no-undo.
  Assign
  B1-qnty     [tt#] = B1-qnty       [tt#] + qnty            [tt#]
  B1-Summ     [tt#]  = B1-Summ     [tt#]    + Summ          [tt#]
  B1-Vat      [tt#]  = B1-Vat      [tt#]    + Vat           [tt#]
  B1-excise   [tt#]  = B1-excise   [tt#]    + excise        [tt#]
  B1-road-tax [tt#]  = B1-road-tax [tt#]    + road-tax      [tt#]
  B1-transport[tt#]  = B1-transport[tt#]    + transport     [tt#]
  B1-Other    [tt#]  = B1-Other    [tt#]    + Other         [tt#]
  B2-qnty     [tt#]   = B2-qnty      [tt#]  + qnty        [tt#]
  B2-Summ     [tt#]  = B2-Summ       [tt#]  + Summ       [tt#]
  B2-Vat      [tt#]  = B2-Vat        [tt#]  + Vat        [tt#]
  B2-excise   [tt#]  = B2-excise     [tt#]  + excise     [tt#]
  B2-road-tax [tt#]  = B2-road-tax   [tt#]  + road-tax   [tt#]
  B2-transport[tt#]  = B2-transport  [tt#]  + transport  [tt#]
  B2-Other    [tt#]  = B2-Other      [tt#]  + Other      [tt#]
  Bi-qnty     [tt#]  = Bi-qnty      [tt#]   + qnty     [tt#]
  Bi-Summ     [tt#]  = Bi-Summ      [tt#]   + Summ     [tt#]
  Bi-Vat      [tt#]  = Bi-Vat       [tt#]   + Vat      [tt#]
  Bi-excise   [tt#]  = Bi-excise    [tt#]   + excise   [tt#]
  Bi-road-tax [tt#]  = Bi-road-tax  [tt#]   + road-tax [tt#]
  Bi-transport[tt#]  = Bi-transport [tt#]   + transport[tt#]
  Bi-Other    [tt#]  = Bi-Other     [tt#]   + Other    [tt#]    .
END PROCEDURE.
PROCEDURE Clear-item :
 define input parameter tt#          as   int                 no-undo.
 Assign
  Qnty      [tt#]   = 0
  Summ      [tt#]  = 0
  Vat       [tt#]  = 0
  eff       [tt#]  = 0
  Excise    [tt#]  = 0
  Road-tax  [tt#]  = 0
  Transport [tt#]  = 0
  Other     [tt#]  = 0 .
 END PROCEDURE.
PROCEDURE Item-Goods :
 define input parameter  par-3 as char no-undo.
 define input parameter  par-4 as char no-undo.
 define variable v-vat-pc        like ub.doc-line.vat-pc    no-undo.
 define variable v-host-code     like ub.sysconf.host-code  no-undo.
 define variable v-gds-code      like ub.goods.gds-code     no-undo.
     if par-4 = "goods":U  Then DO:
          FIND FIRST clients WHERE clients.obj-type = Goods.prod-type AND
                              clients.obj-code = Goods.prod-code use-index pi NO-LOCK .
                                assign
                                    gds-zap-unit-base  = Goods.unit-base
                                    gds-zap-prt-root   = Goods.prt-root
                                    gds-zap-prod-type  = Goods.prod-type
                                    gds-zap-prod-code  = Goods.prod-code
                                    gds-zap-artic      = Goods.artic
                                    gds-zap-type       = Goods.gds-type
                                    gds-zap-grp-name   = Goods.grp-name
                                    gds-zap-b-code     = Goods.gds-code
                                    gds-zap-prod-name  = clients.obj-name .
                                if g#gds-engl then
                                    assign gds-zap-gds-name = Goods.engl-name.
                                else
                                    assign gds-zap-gds-name = Goods.gds-name.
                            End.
     if par-4 = "gds-list":U  Then DO:
          FIND FIRST clients WHERE clients.obj-type = gds-list.prod-type AND
                              clients.obj-code = gds-list.prod-code use-index pi NO-LOCK .
                                assign
                                    gds-zap-unit-base  = gds-list.unit-base
                                    gds-zap-prt-root   = gds-list.prt-root
                                    gds-zap-prod-type  = gds-list.prod-type
                                    gds-zap-prod-code  = gds-list.prod-code
                                    gds-zap-type       = gds-list.gds-type
                                    gds-zap-artic      = gds-list.artic
                                    gds-zap-grp-name   = gds-list.grp-name
                                    gds-zap-b-code     = gds-list.gds-code
                                    gds-zap-prod-name  = clients.obj-name .
                                if g#gds-engl then
                                    assign gds-zap-gds-name = gds-list.engl-name.
                                else
                                    assign gds-zap-gds-name = gds-list.gds-name.
                            End.
    Run foreach .
      If  break_group = true and par-3 <> "1"  then DO:
                     If break_group1 = True THEN  DO:
                               if (par-3 = "3"  OR  par-3 = "5" ) and  par-3 <> "6"
                                  then temp-str = string("ГРУППА : " + gds-zap-grp-name ).
                                  else temp-str = string("ПРОИЗВОДИТЕЛЬ : " + gds-zap-prod-name ) .
                               if par-3 = "6"  then do:
                                  assign
                                      v-gds-code = ( if par-4 = "gds-list" then Gds-list.gds-code
                                                                           else goods.gds-code )
                                  .
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  x-store-type
  ,input  x-store-code
  ,output v-host-code
  )  .
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  v-gds-code
  ,input  '1':U
  ,input  ?
  ,input  v-host-code
  ,input  x-store-type
  ,input  x-store-code
  ,output v-vat-pc
  ) no-error .
                                  assign
                                    temp-str = string( "СТАВКА НДС : " + string(v-vat-pc) + "%" )
                                  .
                               end.
                             fr0 = true .
                             tmp#stroka0 = temp-str.
                     End.
                     IF  (par-3 = "4"  OR  par-3 = "5")  THEN DO:
                         temp-str =
                             ( if par-3 = "4"
                                  then string("ГРУППА : " + gds-zap-grp-name )
                                  else string("ПРОИЗВОДИТЕЛЬ : " + gds-zap-prod-name ) ).
                              if NOT xSumsOnly THEN DO :
                              tmp#stroka = temp-str.
                              fr = true .
                              end.
                              break_group1 = false.
                     END.
                      break_group = false.
    End.
          Run display-line.
 END PROCEDURE.
PROCEDURE Di :
define input parameter tt# as int no-undo.
define input parameter p1 as char no-undo.
define input parameter p2 as int no-undo.
define input parameter p3 as char no-undo.
define input parameter p4 as char no-undo.
define input parameter p5 as char no-undo.
define input parameter p6 as char no-undo.
define input parameter p7 as char no-undo.
 CASE CAPS(p7) :
   WHEN "B1":U  Then  DO:
   IF  NOT (NOT Show-Negativ  AND
     (b1-qnty  [tt#]           = 0 and
       b1-Summ     [tt#] = 0 and
       b1-Vat      [tt#] = 0 and
       b1-excise   [tt#] = 0 and
       b1-road-tax [tt#] = 0 and
       b1-transport[tt#] = 0 and
       b1-Other    [tt#] = 0 ))  THEN DO:
             DISPLAY stream  OutStream sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12
                p1   @ type-Sum
                p3 @ gds-zap-b-code
                p4 @ gds-zap-artic
                p5 @ gds-zap-gds-name
                p6 @ gds-zap-unit-base
                b1-qnty      @ F-qnty
                b1-Summ     [tt#]  @ F-Summ
                b1-Vat      [tt#]  @ F-Vat
                b1-eff      [tt#] when b1-eff[tt#] <> 0  @ F-eff
                b1-excise   [tt#]  @ F-excise
                b1-road-tax [tt#]  @ F-road-tax
                b1-transport[tt#]  @ F-transport
                b1-Other    [tt#]  @ F-Other
               with FRAME ZAPAS .          DOWN stream   OutStream 1 with FRAME ZAPAS. End.
    End.
   WHEN "B2":U  Then do:
   IF  NOT (NOT Show-Negativ  AND
   (b2-qnty  [tt#]           = 0 and
       b2-Summ     [tt#] = 0 and
       b2-Vat      [tt#] = 0 and
       b2-excise   [tt#] = 0 and
       b2-road-tax [tt#] = 0 and
       b2-transport[tt#] = 0 and
       b2-Other    [tt#] = 0 ))  THEN  DO:
      DISPLAY stream  OutStream sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12
                p1 @ type-Sum
                p3 @ gds-zap-b-code
                p4 @ gds-zap-artic
                p5 @ gds-zap-gds-name
                p6 @ gds-zap-unit-base
                b2-qnty    [tt#]    @ F-qnty
                b2-Summ     [tt#]  @ F-Summ
                b2-Vat      [tt#]  @ F-Vat
                b2-eff      [tt#] when b2-eff[tt#] <> 0  @ F-eff
                b2-excise   [tt#]  @ F-excise
                b2-road-tax [tt#]  @ F-road-tax
                b2-transport[tt#]  @ F-transport
                b2-Other    [tt#]  @ F-Other
                with FRAME ZAPAS .          DOWN stream   OutStream 1 with FRAME ZAPAS. End.
       End.
   WHEN "BI":U Then DO:
             DISPLAY stream  OutStream sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12
                p1   @ type-Sum
                p3 @ gds-zap-b-code
                p4 @ gds-zap-artic
                p5 @ gds-zap-gds-name
                p6 @ gds-zap-unit-base
                bi-qnty    [tt#]    @ F-qnty
                bi-Summ     [tt#]  @ F-Summ
                bi-Vat      [tt#]  @ F-Vat
                bi-eff      [tt#] when bi-eff[tt#] <> 0 @ F-eff
                bi-excise   [tt#]  @ F-excise
                bi-road-tax [tt#]  @ F-road-tax
                bi-transport[tt#]  @ F-transport
                bi-Other    [tt#]  @ F-Other
               with FRAME ZAPAS .        DOWN stream   OutStream 1 with FRAME ZAPAS.
            End.
   WHEN ""  Then DO:
             DISPLAY stream  OutStream sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12
                p1   @ type-Sum
                p3   @ gds-zap-b-code
                p4 @ gds-zap-artic
                p5 @ gds-zap-gds-name
                p6 @ gds-zap-unit-base
                qnty     [tt#]  @ F-qnty
                Summ     [tt#]  @ F-Summ
                Vat      [tt#]  @ F-Vat
                eff      [tt#]  when eff[tt#] <> 0   @ F-eff
                excise   [tt#]  @ F-excise
                road-tax [tt#]  @ F-road-tax
                transport[tt#]  @ F-transport
                Other    [tt#]  @ F-Other
               with FRAME ZAPAS .        DOWN stream   OutStream 1 with FRAME ZAPAS.
             End.
   End case.
 END PROCEDURE.
PROCEDURE Clear-B1  :
define variable tt#          as   int                 no-undo.
repeat tt# = 1 to 3 :
 Assign
    b1-qnty      = 0
    b1-Summ     [tt#]    = 0
    b1-Vat      [tt#]    = 0
    b1-eff      [tt#]    = 0
    b1-excise   [tt#]    = 0
    b1-road-tax [tt#]    = 0
    b1-transport[tt#]    = 0
    b1-Other    [tt#]    = 0  .
   End.
 END PROCEDURE.
PROCEDURE Clear-B2  :
define variable tt#          as   int                 no-undo.
repeat tt# = 1 to 3 :
 Assign
    b2-qnty         = 0
    b2-Summ        [tt#]  = 0
    b2-Vat         [tt#]  = 0
    b2-eff         [tt#]  = 0
    b2-excise      [tt#]  = 0
    b2-road-tax    [tt#]  = 0
    b2-transport   [tt#]  = 0
    b2-Other       [tt#]  = 0  .
    End.
END PROCEDURE.
PROCEDURE Clear-Bi  :
define variable tt#          as   int                 no-undo.
repeat tt# = 1 to 3 :
 Assign
    bi-qnty         = 0
    bi-Summ        [tt#]  = 0
    bi-Vat         [tt#]  = 0
    bi-eff         [tt#]  = 0
    bi-excise      [tt#]  = 0
    bi-road-tax    [tt#]  = 0
    bi-transport   [tt#]  = 0
    bi-Other       [tt#]  = 0  .
    End.
END PROCEDURE.
