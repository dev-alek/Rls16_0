block-level on error undo, throw.
define input parameter x-store-code like ub.clients.obj-code   no-undo.
define input parameter x-store-type like ub.clients.obj-type   no-undo.
define input parameter x-base-type  like ub.currency.curr-abbr no-undo.
define input parameter x-base-code  like ub.currency.curr-code no-undo.
define input parameter xClassify      as char no-undo.
define input parameter xSortType      as char no-undo.
define input parameter xSumsOnly      as logical  no-undo.
define input parameter xShowZero      as logical  no-undo.
define input parameter xShowZero-2    as logical  no-undo.
define input parameter xTog-obj       as logical  no-undo.
define input parameter xShowCost      as logical  no-undo.
define input parameter xShowCostNDS   as logical  no-undo.
define input parameter xShowCrsa      as logical  no-undo.
define input parameter xShowCrsaNDS   as logical  no-undo.
define input parameter xShowSale      as logical  no-undo.
define input parameter xShowSaleNDS   as logical  no-undo.
define input parameter xtog-lavel     as logical  no-undo.
define input parameter xvar-lavel     as int  no-undo.
define input parameter xserv          as char no-undo.
define input parameter print-o        as char no-undo.
define input parameter xShowmediator  as logical  no-undo.
define input parameter xShowSaleSlt   as logical  no-undo.
define input parameter x-vat          as logical  no-undo.
define input parameter xlongname      as logical   no-undo .
define input parameter x-tog-wt       as logical   no-undo .
define input parameter x-tog-ms       as logical   no-undo .
define input parameter p-is-petrol    as logical   no-undo .
define buffer goods   for ub.goods  .
define buffer gds-obj for ub.gds-obj  .
define buffer clients for ub.clients  .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Оборотная ведомость".
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
define temp-table temp#sum-type no-undo
    FIELD sum-type as char
    FIELD xi as int .
define variable v-name-type as character no-undo .
if x-vat then x-vat = false .
         else x-vat = true .
if x-vat then v-name-type = "учет.".
else  v-name-type = "учет-НДС".
define variable  long-p         as logical  no-undo .
define variable  Null-str#      as decimal  no-undo.
define variable  Null-str2#     as decimal  no-undo.
define variable  b1-Null-str#   as decimal  no-undo.
define variable  b1-Null-str2#  as decimal  no-undo.
define variable  b2-Null-str#   as decimal  no-undo.
define variable  b2-Null-str2#  as decimal  no-undo.
define variable  tPrintRubl as logical no-undo.
define stream  OutStream.
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
define variable    Line2             as   char        no-undo.
define variable    FirstLine         as   logical     no-undo.
define variable mediator-host-code as integer no-undo .
define variable f-flag             as logical no-undo .
define variable tot_tqnty as decimal  no-undo.
define variable break_group as logical no-undo init true.
define variable break_group1 as logical no-undo init true.
define variable stat      as logical    no-undo .
define variable InpError  as logical    no-undo .
define variable i         as integer    no-undo .
define variable p         as integer    no-undo init 0 .
define variable kk        as integer    no-undo init 0 .
define variable old-page  as integer    no-undo .
define variable new-page  as integer    no-undo .
define variable rid-list  as character  no-undo .
define variable gds-zap-unit-base     like ub.goods.unit-base     no-undo.
define variable gds-zap-prt-root      like ub.goods.prt-root      no-undo .
define variable gds-zap-gds-name      like ub.goods.gds-name      no-undo .
define variable gds-zap-prod-type     like ub.goods.prod-type     no-undo .
define variable gds-zap-prod-code     like ub.goods.prod-code     no-undo .
define variable gds-zap-artic         like ub.goods.artic         no-undo .
define variable gds-zap-b-code        like ub.bar-code.b-code     no-undo .
define variable gds-type              as char no-undo.
define variable gds-zap-type          like ub.goods.gds-type     no-undo .
define variable gds-zap-grp-name      like ub.goods.grp-name     no-undo .
define variable gds-zap-prod-name     like ub.clients.obj-name   no-undo .
define variable gds-zap-price-base    like ub.stk-tot.sum-base   no-undo.
define variable gds-zap-stoim-base    like ub.stk-tot.sum-base   no-undo.
define variable gds-zap-qnty          like ub.stk-tot.fact-qnty  no-undo.
define variable gds-zap-Nds           like ub.stk-tot.sum-base   no-undo.
define variable gds-zap-Np            like ub.stk-tot.sum-base   no-undo.
define variable gds-wt-base           like ub.goods.wt-base      no-undo .
define variable gds-ms-base           like ub.goods.ms-base      no-undo .
define variable F-ostatok-End      as   char  no-undo.
define variable ostatok-start      as   decimal EXTENT 12  no-undo .
define variable ostatok-End        as   decimal EXTENT 12  no-undo.
define variable B1-ostatok-start   as   decimal EXTENT 12  no-undo.
define variable B1-ostatok-End     as   decimal EXTENT 12  no-undo.
define variable B2-ostatok-start   as   decimal EXTENT 12  no-undo.
define variable B2-ostatok-End     as   decimal EXTENT 12  no-undo.
define variable Bi-ostatok-start   as   decimal EXTENT 12  no-undo.
define variable Bi-ostatok-End     as   decimal EXTENT 12  no-undo.
define variable Bo-ostatok-start   as   decimal EXTENT 12  no-undo.
define variable Bo-ostatok-End     as   decimal EXTENT 12  no-undo.
define variable c-s-bar-code        AS   WIDGET-HANDLE  no-undo.
define variable c-gds-zap-artic     AS   WIDGET-HANDLE  no-undo.
define variable c-gds-zap-gds-name  AS   WIDGET-HANDLE  no-undo.
define variable c-gds-zap-unit-base AS   WIDGET-HANDLE  no-undo.
define variable c-gds-type          AS   WIDGET-HANDLE  no-undo.
define variable C-ostatok-start     AS   WIDGET-HANDLE  no-undo.
define variable C-ostatok-End       AS   WIDGET-HANDLE  no-undo.
define variable c-str-num           AS   WIDGET-HANDLE  no-undo.
define variable v-gds-num          as integer   no-undo .
define variable l-col-type         as character no-undo .
define variable l-col-pos          as integer no-undo .
define variable l-col-len          as integer no-undo .
define variable l-col-format       as character no-undo .
define variable l-col-lable        as character no-undo .
define variable first-lavel as integer no-undo .
define variable v-Format-string as character no-undo .
define variable  c-oborot-ie as widget-handle no-undo.
define variable  f-oborot-ie as character no-undo.
define variable    oborot-ie as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b1-oborot-ie as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b2-oborot-ie as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bi-oborot-ie as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bo-oborot-ie as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable  c-oborot-ee as widget-handle no-undo.
define variable  f-oborot-ee as character no-undo.
define variable    oborot-ee as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b1-oborot-ee as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b2-oborot-ee as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bi-oborot-ee as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bo-oborot-ee as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable  c-oborot-ep as widget-handle no-undo.
define variable  f-oborot-ep as character no-undo.
define variable    oborot-ep as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b1-oborot-ep as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b2-oborot-ep as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bi-oborot-ep as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bo-oborot-ep as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable  c-oborot-es as widget-handle no-undo.
define variable  f-oborot-es as character no-undo.
define variable    oborot-es as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b1-oborot-es as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b2-oborot-es as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bi-oborot-es as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bo-oborot-es as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable  c-oborot-re as widget-handle no-undo.
define variable  f-oborot-re as character no-undo.
define variable    oborot-re as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b1-oborot-re as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b2-oborot-re as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bi-oborot-re as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bo-oborot-re as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable  c-oborot-rs as widget-handle no-undo.
define variable  f-oborot-rs as character no-undo.
define variable    oborot-rs as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b1-oborot-rs as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b2-oborot-rs as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bi-oborot-rs as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bo-oborot-rs as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable  c-oborot-we as widget-handle no-undo.
define variable  f-oborot-we as character no-undo.
define variable    oborot-we as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b1-oborot-we as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b2-oborot-we as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bi-oborot-we as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bo-oborot-we as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable  c-oborot-vt as widget-handle no-undo.
define variable  f-oborot-vt as character no-undo.
define variable    oborot-vt as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b1-oborot-vt as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b2-oborot-vt as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bi-oborot-vt as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bo-oborot-vt as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable  c-oborot-iv as widget-handle no-undo.
define variable  f-oborot-iv as character no-undo.
define variable    oborot-iv as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b1-oborot-iv as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b2-oborot-iv as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bi-oborot-iv as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bo-oborot-iv as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable  c-oborot-ev as widget-handle no-undo.
define variable  f-oborot-ev as character no-undo.
define variable    oborot-ev as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b1-oborot-ev as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b2-oborot-ev as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bi-oborot-ev as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bo-oborot-ev as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable  c-oborot-rv as widget-handle no-undo.
define variable  f-oborot-rv as character no-undo.
define variable    oborot-rv as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b1-oborot-rv as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b2-oborot-rv as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bi-oborot-rv as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bo-oborot-rv as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable  c-oborot-em as widget-handle no-undo.
define variable  f-oborot-em as character no-undo.
define variable    oborot-em as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b1-oborot-em as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b2-oborot-em as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bi-oborot-em as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bo-oborot-em as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable  c-oborot-wm as widget-handle no-undo.
define variable  f-oborot-wm as character no-undo.
define variable    oborot-wm as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b1-oborot-wm as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b2-oborot-wm as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bi-oborot-wm as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bo-oborot-wm as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable  c-oborot-im as widget-handle no-undo.
define variable  f-oborot-im as character no-undo.
define variable    oborot-im as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b1-oborot-im as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b2-oborot-im as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bi-oborot-im as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bo-oborot-im as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable  c-oborot-ot as widget-handle no-undo.
define variable  f-oborot-ot as character no-undo.
define variable    oborot-ot as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b1-oborot-ot as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b2-oborot-ot as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bi-oborot-ot as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bo-oborot-ot as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable  c-oborot-pc as widget-handle no-undo.
define variable  f-oborot-pc as character no-undo.
define variable    oborot-pc as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b1-oborot-pc as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b2-oborot-pc as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bi-oborot-pc as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bo-oborot-pc as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable  c-oborot-ap as widget-handle no-undo.
define variable  f-oborot-ap as character no-undo.
define variable    oborot-ap as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b1-oborot-ap as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b2-oborot-ap as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bi-oborot-ap as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bo-oborot-ap as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable  c-oborot-disc as widget-handle no-undo.
define variable  f-oborot-disc as character no-undo.
define variable    oborot-disc as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b1-oborot-disc as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b2-oborot-disc as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bi-oborot-disc as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bo-oborot-disc as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable  c-oborot-eff as widget-handle no-undo.
define variable  f-oborot-eff as character no-undo.
define variable    oborot-eff as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b1-oborot-eff as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b2-oborot-eff as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bi-oborot-eff as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bo-oborot-eff as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable  c-oborot-prc as widget-handle no-undo.
define variable  f-oborot-prc as character no-undo.
define variable    oborot-prc as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b1-oborot-prc as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b2-oborot-prc as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bi-oborot-prc as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bo-oborot-prc as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable  c-oborot-r-v as widget-handle no-undo.
define variable  f-oborot-r-v as character no-undo.
define variable    oborot-r-v as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b1-oborot-r-v as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b2-oborot-r-v as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bi-oborot-r-v as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bo-oborot-r-v as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable  c-oborot-sum-cost as widget-handle no-undo.
define variable  f-oborot-sum-cost as character no-undo.
define variable    oborot-sum-cost as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b1-oborot-sum-cost as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b2-oborot-sum-cost as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bi-oborot-sum-cost as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bo-oborot-sum-cost as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable  c-oborot-sum-crsa as widget-handle no-undo.
define variable  f-oborot-sum-crsa as character no-undo.
define variable    oborot-sum-crsa as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b1-oborot-sum-crsa as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b2-oborot-sum-crsa as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bi-oborot-sum-crsa as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bo-oborot-sum-crsa as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable  c-oborot-sum-sale as widget-handle no-undo.
define variable  f-oborot-sum-sale as character no-undo.
define variable    oborot-sum-sale as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b1-oborot-sum-sale as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b2-oborot-sum-sale as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bi-oborot-sum-sale as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bo-oborot-sum-sale as decimal   extent 12 format "->>>>>>>>>>>9.<<<":U no-undo .
  define temp-table tt-obj-list no-undo
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    index pi is primary unique obj-type obj-code
    index name obj-name
    .
define variable NN      as   int  no-undo.
define variable report1 as int no-undo.
define variable report2 as int no-undo.
define variable ErrorLevel as int no-undo.
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
define variable str as char format "X(60)" no-undo.
define variable i#i as int no-undo.
define variable xLavel as int  no-undo.
define variable list-field as char no-undo.
define variable str10 as char no-undo.
define buffer kg-obj-list for obj-list .
DEFINE new shared VARIABLE t-1 AS CHARACTER INITIAL "|||"
     VIEW-AS EDITOR
     SIZE 1 BY 4 NO-UNDO.
DEFINE new shared FRAME top-frame
    t-1       AT ROW 1 COL 1 no-label
    HEADER
     cur-time-print() AT 5 format "X(35)"
        "Цены указаны в" (if tPrintRubl then "РУБ" else x-base-type )
        string( "Страница " + string( PAGE-NUMBER( OutStream ), ">>>>>>9") ) AT 110 format "X(16)" SKIP
     WITH 340 DOWN stream-io
         NO-UNDERLINE use-text NO-BOX no-label
         AT COL 1 ROW 1
         SIZE 340 BY 35  .
DEFINE new shared FRAME zapas
   with width 340 down stream-io use-text NO-BOX no-label.
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
IF ( i modulo v-account = 0 )  then DO:
 Assign
    v-kol-spice = (50 - LENGTH('Оборотная ведомость по всем типам')) / 2
    RecordsString = fill(' ',v-kol-spice) + string('Оборотная ведомость по всем типам')
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
def new shared var ed1 as handle .
def new shared  var s1 as handle .
def new shared  var sf1 as handle .
def new shared  var l-1 as handle .
def new shared  var ll-1 as handle .
def new shared var ed2 as handle .
def new shared  var s2 as handle .
def new shared  var sf2 as handle .
def new shared  var l-2 as handle .
def new shared  var ll-2 as handle .
def new shared var ed3 as handle .
def new shared  var s3 as handle .
def new shared  var sf3 as handle .
def new shared  var l-3 as handle .
def new shared  var ll-3 as handle .
def new shared var ed4 as handle .
def new shared  var s4 as handle .
def new shared  var sf4 as handle .
def new shared  var l-4 as handle .
def new shared  var ll-4 as handle .
def new shared var ed5 as handle .
def new shared  var s5 as handle .
def new shared  var sf5 as handle .
def new shared  var l-5 as handle .
def new shared  var ll-5 as handle .
def new shared var ed6 as handle .
def new shared  var s6 as handle .
def new shared  var sf6 as handle .
def new shared  var l-6 as handle .
def new shared  var ll-6 as handle .
def new shared var ed7 as handle .
def new shared  var s7 as handle .
def new shared  var sf7 as handle .
def new shared  var l-7 as handle .
def new shared  var ll-7 as handle .
def new shared var ed8 as handle .
def new shared  var s8 as handle .
def new shared  var sf8 as handle .
def new shared  var l-8 as handle .
def new shared  var ll-8 as handle .
def new shared var ed9 as handle .
def new shared  var s9 as handle .
def new shared  var sf9 as handle .
def new shared  var l-9 as handle .
def new shared  var ll-9 as handle .
def new shared var ed10 as handle .
def new shared  var s10 as handle .
def new shared  var sf10 as handle .
def new shared  var l-10 as handle .
def new shared  var ll-10 as handle .
def new shared var ed11 as handle .
def new shared  var s11 as handle .
def new shared  var sf11 as handle .
def new shared  var l-11 as handle .
def new shared  var ll-11 as handle .
def new shared var ed12 as handle .
def new shared  var s12 as handle .
def new shared  var sf12 as handle .
def new shared  var l-12 as handle .
def new shared  var ll-12 as handle .
def new shared var ed13 as handle .
def new shared  var s13 as handle .
def new shared  var sf13 as handle .
def new shared  var l-13 as handle .
def new shared  var ll-13 as handle .
def new shared var ed14 as handle .
def new shared  var s14 as handle .
def new shared  var sf14 as handle .
def new shared  var l-14 as handle .
def new shared  var ll-14 as handle .
def new shared var ed15 as handle .
def new shared  var s15 as handle .
def new shared  var sf15 as handle .
def new shared  var l-15 as handle .
def new shared  var ll-15 as handle .
def new shared var ed16 as handle .
def new shared  var s16 as handle .
def new shared  var sf16 as handle .
def new shared  var l-16 as handle .
def new shared  var ll-16 as handle .
def new shared var ed17 as handle .
def new shared  var s17 as handle .
def new shared  var sf17 as handle .
def new shared  var l-17 as handle .
def new shared  var ll-17 as handle .
def new shared var ed18 as handle .
def new shared  var s18 as handle .
def new shared  var sf18 as handle .
def new shared  var l-18 as handle .
def new shared  var ll-18 as handle .
def new shared var ed19 as handle .
def new shared  var s19 as handle .
def new shared  var sf19 as handle .
def new shared  var l-19 as handle .
def new shared  var ll-19 as handle .
def new shared var ed20 as handle .
def new shared  var s20 as handle .
def new shared  var sf20 as handle .
def new shared  var l-20 as handle .
def new shared  var ll-20 as handle .
def new shared var ed21 as handle .
def new shared  var s21 as handle .
def new shared  var sf21 as handle .
def new shared  var l-21 as handle .
def new shared  var ll-21 as handle .
def new shared var ed22 as handle .
def new shared  var s22 as handle .
def new shared  var sf22 as handle .
def new shared  var l-22 as handle .
def new shared  var ll-22 as handle .
def new shared var ed23 as handle .
def new shared  var s23 as handle .
def new shared  var sf23 as handle .
def new shared  var l-23 as handle .
def new shared  var ll-23 as handle .
def new shared var ed24 as handle .
def new shared  var s24 as handle .
def new shared  var sf24 as handle .
def new shared  var l-24 as handle .
def new shared  var ll-24 as handle .
def new shared var ed25 as handle .
def new shared  var s25 as handle .
def new shared  var sf25 as handle .
def new shared  var l-25 as handle .
def new shared  var ll-25 as handle .
def new shared var ed26 as handle .
def new shared  var s26 as handle .
def new shared  var sf26 as handle .
def new shared  var l-26 as handle .
def new shared  var ll-26 as handle .
def new shared var ed27 as handle .
def new shared  var s27 as handle .
def new shared  var sf27 as handle .
def new shared  var l-27 as handle .
def new shared  var ll-27 as handle .
def new shared var ed28 as handle .
def new shared  var s28 as handle .
def new shared  var sf28 as handle .
def new shared  var l-28 as handle .
def new shared  var ll-28 as handle .
  run rep/r-in-ob.p (
   input          x-base-type
 , input          x-base-code
 , input          tprintrubl
 , input-output   c-s-bar-code
 , input-output   c-gds-zap-artic
 , input-output   c-gds-zap-gds-name
 , input-output   c-gds-zap-unit-base
 , input-output   c-gds-type
 , input-output   c-ostatok-start
 , input-output   c-ostatok-end
 , input-output   c-oborot-ie
 , input-output   c-oborot-ee
 , input-output   c-oborot-ep
 , input-output   c-oborot-es
 , input-output   c-oborot-re
 , input-output   c-oborot-rs
 , input-output   c-oborot-we
 , input-output   c-oborot-vt
 , input-output   c-oborot-iv
 , input-output   c-oborot-ev
 , input-output   c-oborot-rv
 , input-output   c-oborot-em
 , input-output   c-oborot-wm
 , input-output   c-oborot-im
 , input-output   c-oborot-ot
 , input-output   c-oborot-pc
 , input-output   c-oborot-ap
 , input-output   c-oborot-disc
 , input-output   c-oborot-eff
 , input-output   c-oborot-prc
 , input-output   c-oborot-r-v
 , input-output   c-str-num
 , input-output   l-col-type
 , input-output   l-col-pos
 , input-output   l-col-len
 , input-output   l-col-format
 , input-output   l-col-lable
  ).
  define variable time-start as integer no-undo .
  Run init-proc in this-procedure .
  if f-flag = false then RETURN .
  Run report-execute   in this-procedure .
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
procedure init-proc :
 time-start = time.
assign
  i               = 0
  xlavel          = xvar-lavel
  Select-Good     = x-SelectGood
  PayType         = x-SET_PAY_TYPE
  RetClassify     = xClassify
  RetSortType     = xSortType
  Sums-Only       = xSumsOnly
  Show-Negativ    = xShowZero
  Show-Negativ-2  = xShowZero-2
  FirstLine       = FALSE
  line            = fill('-', MINIMUM(l-col-pos,189))
  line2            = fill('-', l-col-pos - 1)
  .
  if p-is-petrol = true  then
  assign
    Select-Good  = 4
    x-SelectGood = 4
  .
  if  x-date-end  - x-date-start > 400
      then long-p = true    .
      else  long-p = false     .
  x-SelectObject = "".
  find first ub.gds-grp where  ub.gds-grp.upper-code = 0 no-lock no-error .
  if avail ub.gds-grp then   first-lavel = ub.gds-grp.node-code.
                   else first-lavel = 0.
  ValType         = IF (PayType = 1) Then 0  else x-SET_val_TYPE.
  If (ValType=0 and x-base-code=0)  Or ValType=1
    then assign tPrintRubl = yes .
    else assign tPrintRubl = no .
  run rep/ob-sumtp.p (output table temp#sum-type ).
  Run find-mediator  in this-procedure  ( INPUT v-cntxt-host-code-obj ,input xShowmediator, OUTPUT mediator-host-code, OUTPUT f-flag) .
end procedure.
PROCEDURE report-execute :
  Case print-o :
  when "A4-lansc":U then DO:
output stream OutStream to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size  value(43) .
  end.
  when "A4-port":U then DO:
output stream OutStream to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size  value(63) .
  end.
  when "A3-lansc":U then DO:
output stream OutStream to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size  value(63) .
  end.
  OTHERWISE DO:
output stream OutStream to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size  value(43) .
  end.
  end case.
 define variable gj as integer no-undo init 0.
   if xTog-obj  Then DO:
            FOR each obj-list no-lock:
                x-store-type = obj-list.obj-type.
                x-store-code = obj-list.obj-code.
                gj = gj + 1 .
                Run report-exec1   in this-procedure .
            End.
           if gj > 1 then DO :
              run display-bo   in this-procedure .
              run u-line  in this-procedure .
           End.
          End.
  Else  Run report-exec1   in this-procedure .
  put stream outstream " Время составления отчета " string((time - time-start),"hh:mm:ss" ) .
  HIDE   STREAM OutStream FRAME ZAPAS .
  HIDE   STREAM OutStream FRAME top-Frame .
  Output stream OutStream close.
if mFrameView
then do:
   HIDE FRAME InfoFrame.
end.
  DELETE WIDGET-POOL "My-pool".
   define variable v-user-action as character no-undo .
   define variable v-printed as logical   no-undo .
   define variable DisabledOptions as integer   no-undo .
  Case print-o :
  when "A4-lansc":U then DO:
      DisabledOptions = 8 .
     end.
  when "A4-port":U then DO:
      DisabledOptions = 0 .
     end.
  when "A3-lansc":U then DO:
      DisabledOptions = 8 .
                      end.
  OTHERWISE DO:
      DisabledOptions = 1 .
      end.
   End case.
   run gbl/prnfilen.w
     (input  ""
     ,input  DisabledOptions
     ,input  string(session :temp-directory) + "rpt" + string( g#report-num )
     ,input  7
     ,output v-user-action
     ,output v-printed
     ) .
END PROCEDURE.
PROCEDURE foreach :
  define buffer buf_goods for ub.goods.
  find first  buf_goods no-lock where buf_goods.gds-code = gds-zap-b-code no-error .
  Assign
    p-price-med = 0
    Null-str# = 1
    Null-str2# = 1
    gds-ms-base        = if buf_goods.ms-base = ? then 0 else buf_goods.ms-base
    gds-wt-base        = if buf_goods.wt-base = ? then 0 else buf_goods.wt-base
  .
IF ( i modulo v-account = 0 )  then DO:
          if  log-manager:logfile-name ne ?
          then DO:
              log-manager:write-message("DISP mFrameView=" + string(mFrameView), "frameRepError").
          end.
           if mFrameView
           then do:
            DISPLAY
              i @ RecordsDone
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
  RUN Clear-item   in this-procedure .
  if xshowmediator = true then do :
       run find-last-prise-med in this-procedure (
          input gds-zap-artic ,
          input gds-zap-prod-type ,
          input gds-zap-prod-code ,
          input mediator-host-code ,
          output p-price-med   )
            .
    End.
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
    if p-is-petrol then do:
quantity = 0 .
for each kg-obj-list no-lock
   where xtog-obj = false
      or (kg-obj-list.obj-type = x-store-type and kg-obj-list.obj-code = x-store-code )
      :
    run ost-line-kg in this-procedure
     (input   kg-obj-list.obj-code  ,
      input   kg-obj-list.obj-type  ,
      input   gds-zap-artic     ,
      input   gds-zap-prod-code ,
      input   gds-zap-prod-type ,
      input   Fact-order-1               ,
      output  quantity    ) .
assign
  ostatok-start [11]   = ostatok-start [11] +  quantity
 b1-ostatok-start [11] =  b1-ostatok-start [11] + quantity
 b2-ostatok-start [11] =  b2-ostatok-start [11] + quantity
 bo-ostatok-start [11] =  bo-ostatok-start [11] + quantity
 .
 assign
  bi-ostatok-start [11] =  bi-ostatok-start [11] + quantity
 .
end.
    end.
If xshowcrsa Or xshowCrsaNDS OR use-column[23] OR use-column[24]  or xShowmediator   Then DO:
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
If xshowsale Or xshowsaleNDS Or xshowsaleSLT  Then DO:
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
    if p-is-petrol then do:
quantity = 0 .
for each kg-obj-list no-lock
   where xtog-obj = false
      or (kg-obj-list.obj-type = x-store-type and kg-obj-list.obj-code = x-store-code )
      :
    run ost-line-kg in this-procedure
     (input   kg-obj-list.obj-code  ,
      input   kg-obj-list.obj-type  ,
      input   gds-zap-artic     ,
      input   gds-zap-prod-code ,
      input   gds-zap-prod-type ,
      input   Fact-order-2               ,
      output  quantity    ) .
assign
  ostatok-end [11]   = ostatok-end [11] +  quantity
 b1-ostatok-end [11] =  b1-ostatok-end [11] + quantity
 b2-ostatok-end [11] =  b2-ostatok-end [11] + quantity
 bo-ostatok-end [11] =  bo-ostatok-end [11] + quantity
 .
 assign
  bi-ostatok-end [11] =  bi-ostatok-end [11] + quantity
 .
end.
    end.
If xshowCrsa Or xshowCrsaNDS OR use-column[23] OR use-column[24]  or xShowmediator Then DO:
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
If xshowsale Or
   xshowsaleNDS Or
   xshowsaleSLT    Then DO:
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
   if gds-zap-type = 'т':U
      then
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
input '' ,
input xtog-obj) .
      else
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
input '' ,
input xtog-obj) .
   Run CAlc-Sub-itog   in this-procedure (0).
  If xshowCrsa Or xshowCrsaNDS  OR   use-column[23] OR use-column[24]  or xShowmediator   Then DO:
     if gds-zap-type = 'т':U
        THEN
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
input '' ,
input xtog-obj) .
        else
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
input '' ,
input xtog-obj) .
     Run CAlc-Sub-itog  in this-procedure  (3).
  End.
  If xshowsale Or xshowsaleNDS   Or xshowsaleSLT
               OR use-column[21] OR use-column[23] OR use-column[24]  Then DO:
      if gds-zap-type = 'т':U
         THEN
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
input '' ,
input xtog-obj) .
         else
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
input '' ,
input xtog-obj) .
      Run CAlc-Sub-itog   in this-procedure (6).
  End.
  if NOT Show-negativ   then  Run Null-str-pr  in this-procedure .
  if NOT Show-negativ-2 then  Run Null-str-pr2  in this-procedure .
if x-tog-wt then do :
    run calc-ms-wt in this-procedure ( input ostatok-start[1] , input gds-wt-base , input-output    ostatok-start[11] , input-output bi-ostatok-start[11] , input-output bo-ostatok-start[11] , input-output b1-ostatok-start[11] , input-output b2-ostatok-start[11] ) .
    run calc-ms-wt in this-procedure ( input ostatok-end[1] , input gds-wt-base , input-output    ostatok-end[11] , input-output bi-ostatok-end[11] , input-output bo-ostatok-end[11] , input-output b1-ostatok-end[11] , input-output b2-ostatok-end[11] ) .
    run calc-ms-wt in this-procedure ( input oborot-ie[1] , input gds-wt-base , input-output    oborot-ie[11] , input-output bi-oborot-ie[11] , input-output bo-oborot-ie[11] , input-output b1-oborot-ie[11] , input-output b2-oborot-ie[11] ) .
  run calc-pt-ob in this-procedure ( input 'ie' , input x-store-type , input x-store-code  , input gds-zap-artic     , input gds-zap-prod-type , input gds-zap-prod-code , input-output    oborot-ie[11] , input-output bi-oborot-ie[11] , input-output bo-oborot-ie[11] , input-output b1-oborot-ie[11] , input-output b2-oborot-ie[11] ) .
    run calc-ms-wt in this-procedure ( input oborot-ee[1] , input gds-wt-base , input-output    oborot-ee[11] , input-output bi-oborot-ee[11] , input-output bo-oborot-ee[11] , input-output b1-oborot-ee[11] , input-output b2-oborot-ee[11] ) .
  run calc-pt-ob in this-procedure ( input 'ee' , input x-store-type , input x-store-code  , input gds-zap-artic     , input gds-zap-prod-type , input gds-zap-prod-code , input-output    oborot-ee[11] , input-output bi-oborot-ee[11] , input-output bo-oborot-ee[11] , input-output b1-oborot-ee[11] , input-output b2-oborot-ee[11] ) .
    run calc-ms-wt in this-procedure ( input oborot-ep[1] , input gds-wt-base , input-output    oborot-ep[11] , input-output bi-oborot-ep[11] , input-output bo-oborot-ep[11] , input-output b1-oborot-ep[11] , input-output b2-oborot-ep[11] ) .
  run calc-pt-ob in this-procedure ( input 'ep' , input x-store-type , input x-store-code  , input gds-zap-artic     , input gds-zap-prod-type , input gds-zap-prod-code , input-output    oborot-ep[11] , input-output bi-oborot-ep[11] , input-output bo-oborot-ep[11] , input-output b1-oborot-ep[11] , input-output b2-oborot-ep[11] ) .
    run calc-ms-wt in this-procedure ( input oborot-es[1] , input gds-wt-base , input-output    oborot-es[11] , input-output bi-oborot-es[11] , input-output bo-oborot-es[11] , input-output b1-oborot-es[11] , input-output b2-oborot-es[11] ) .
  run calc-pt-ob in this-procedure ( input 'es' , input x-store-type , input x-store-code  , input gds-zap-artic     , input gds-zap-prod-type , input gds-zap-prod-code , input-output    oborot-es[11] , input-output bi-oborot-es[11] , input-output bo-oborot-es[11] , input-output b1-oborot-es[11] , input-output b2-oborot-es[11] ) .
    run calc-ms-wt in this-procedure ( input oborot-re[1] , input gds-wt-base , input-output    oborot-re[11] , input-output bi-oborot-re[11] , input-output bo-oborot-re[11] , input-output b1-oborot-re[11] , input-output b2-oborot-re[11] ) .
  run calc-pt-ob in this-procedure ( input 're' , input x-store-type , input x-store-code  , input gds-zap-artic     , input gds-zap-prod-type , input gds-zap-prod-code , input-output    oborot-re[11] , input-output bi-oborot-re[11] , input-output bo-oborot-re[11] , input-output b1-oborot-re[11] , input-output b2-oborot-re[11] ) .
    run calc-ms-wt in this-procedure ( input oborot-rs[1] , input gds-wt-base , input-output    oborot-rs[11] , input-output bi-oborot-rs[11] , input-output bo-oborot-rs[11] , input-output b1-oborot-rs[11] , input-output b2-oborot-rs[11] ) .
  run calc-pt-ob in this-procedure ( input 'rs' , input x-store-type , input x-store-code  , input gds-zap-artic     , input gds-zap-prod-type , input gds-zap-prod-code , input-output    oborot-rs[11] , input-output bi-oborot-rs[11] , input-output bo-oborot-rs[11] , input-output b1-oborot-rs[11] , input-output b2-oborot-rs[11] ) .
    run calc-ms-wt in this-procedure ( input oborot-we[1] , input gds-wt-base , input-output    oborot-we[11] , input-output bi-oborot-we[11] , input-output bo-oborot-we[11] , input-output b1-oborot-we[11] , input-output b2-oborot-we[11] ) .
  run calc-pt-ob in this-procedure ( input 'we' , input x-store-type , input x-store-code  , input gds-zap-artic     , input gds-zap-prod-type , input gds-zap-prod-code , input-output    oborot-we[11] , input-output bi-oborot-we[11] , input-output bo-oborot-we[11] , input-output b1-oborot-we[11] , input-output b2-oborot-we[11] ) .
    run calc-ms-wt in this-procedure ( input oborot-vt[1] , input gds-wt-base , input-output    oborot-vt[11] , input-output bi-oborot-vt[11] , input-output bo-oborot-vt[11] , input-output b1-oborot-vt[11] , input-output b2-oborot-vt[11] ) .
  run calc-pt-ob in this-procedure ( input 'vt' , input x-store-type , input x-store-code  , input gds-zap-artic     , input gds-zap-prod-type , input gds-zap-prod-code , input-output    oborot-vt[11] , input-output bi-oborot-vt[11] , input-output bo-oborot-vt[11] , input-output b1-oborot-vt[11] , input-output b2-oborot-vt[11] ) .
    run calc-ms-wt in this-procedure ( input oborot-iv[1] , input gds-wt-base , input-output    oborot-iv[11] , input-output bi-oborot-iv[11] , input-output bo-oborot-iv[11] , input-output b1-oborot-iv[11] , input-output b2-oborot-iv[11] ) .
  run calc-pt-ob in this-procedure ( input 'iv' , input x-store-type , input x-store-code  , input gds-zap-artic     , input gds-zap-prod-type , input gds-zap-prod-code , input-output    oborot-iv[11] , input-output bi-oborot-iv[11] , input-output bo-oborot-iv[11] , input-output b1-oborot-iv[11] , input-output b2-oborot-iv[11] ) .
    run calc-ms-wt in this-procedure ( input oborot-ev[1] , input gds-wt-base , input-output    oborot-ev[11] , input-output bi-oborot-ev[11] , input-output bo-oborot-ev[11] , input-output b1-oborot-ev[11] , input-output b2-oborot-ev[11] ) .
  run calc-pt-ob in this-procedure ( input 'ev' , input x-store-type , input x-store-code  , input gds-zap-artic     , input gds-zap-prod-type , input gds-zap-prod-code , input-output    oborot-ev[11] , input-output bi-oborot-ev[11] , input-output bo-oborot-ev[11] , input-output b1-oborot-ev[11] , input-output b2-oborot-ev[11] ) .
    run calc-ms-wt in this-procedure ( input oborot-rv[1] , input gds-wt-base , input-output    oborot-rv[11] , input-output bi-oborot-rv[11] , input-output bo-oborot-rv[11] , input-output b1-oborot-rv[11] , input-output b2-oborot-rv[11] ) .
  run calc-pt-ob in this-procedure ( input 'rv' , input x-store-type , input x-store-code  , input gds-zap-artic     , input gds-zap-prod-type , input gds-zap-prod-code , input-output    oborot-rv[11] , input-output bi-oborot-rv[11] , input-output bo-oborot-rv[11] , input-output b1-oborot-rv[11] , input-output b2-oborot-rv[11] ) .
    run calc-ms-wt in this-procedure ( input oborot-em[1] , input gds-wt-base , input-output    oborot-em[11] , input-output bi-oborot-em[11] , input-output bo-oborot-em[11] , input-output b1-oborot-em[11] , input-output b2-oborot-em[11] ) .
  run calc-pt-ob in this-procedure ( input 'em' , input x-store-type , input x-store-code  , input gds-zap-artic     , input gds-zap-prod-type , input gds-zap-prod-code , input-output    oborot-em[11] , input-output bi-oborot-em[11] , input-output bo-oborot-em[11] , input-output b1-oborot-em[11] , input-output b2-oborot-em[11] ) .
    run calc-ms-wt in this-procedure ( input oborot-im[1] , input gds-wt-base , input-output    oborot-im[11] , input-output bi-oborot-im[11] , input-output bo-oborot-im[11] , input-output b1-oborot-im[11] , input-output b2-oborot-im[11] ) .
  run calc-pt-ob in this-procedure ( input 'im' , input x-store-type , input x-store-code  , input gds-zap-artic     , input gds-zap-prod-type , input gds-zap-prod-code , input-output    oborot-im[11] , input-output bi-oborot-im[11] , input-output bo-oborot-im[11] , input-output b1-oborot-im[11] , input-output b2-oborot-im[11] ) .
    run calc-ms-wt in this-procedure ( input oborot-ot[1] , input gds-wt-base , input-output    oborot-ot[11] , input-output bi-oborot-ot[11] , input-output bo-oborot-ot[11] , input-output b1-oborot-ot[11] , input-output b2-oborot-ot[11] ) .
  run calc-pt-ob in this-procedure ( input 'ot' , input x-store-type , input x-store-code  , input gds-zap-artic     , input gds-zap-prod-type , input gds-zap-prod-code , input-output    oborot-ot[11] , input-output bi-oborot-ot[11] , input-output bo-oborot-ot[11] , input-output b1-oborot-ot[11] , input-output b2-oborot-ot[11] ) .
    run calc-ms-wt in this-procedure ( input oborot-ap[1] , input gds-wt-base , input-output    oborot-ap[11] , input-output bi-oborot-ap[11] , input-output bo-oborot-ap[11] , input-output b1-oborot-ap[11] , input-output b2-oborot-ap[11] ) .
  run calc-pt-ob in this-procedure ( input 'ap' , input x-store-type , input x-store-code  , input gds-zap-artic     , input gds-zap-prod-type , input gds-zap-prod-code , input-output    oborot-ap[11] , input-output bi-oborot-ap[11] , input-output bo-oborot-ap[11] , input-output b1-oborot-ap[11] , input-output b2-oborot-ap[11] ) .
    run calc-ms-wt in this-procedure ( input oborot-pc[1] , input gds-wt-base , input-output    oborot-pc[11] , input-output bi-oborot-pc[11] , input-output bo-oborot-pc[11] , input-output b1-oborot-pc[11] , input-output b2-oborot-pc[11] ) .
  run calc-pt-ob in this-procedure ( input 'pc' , input x-store-type , input x-store-code  , input gds-zap-artic     , input gds-zap-prod-type , input gds-zap-prod-code , input-output    oborot-pc[11] , input-output bi-oborot-pc[11] , input-output bo-oborot-pc[11] , input-output b1-oborot-pc[11] , input-output b2-oborot-pc[11] ) .
end.
if x-tog-ms then do :
    run calc-ms-wt in this-procedure ( input ostatok-start[1] , input gds-ms-base , input-output    ostatok-start[12] , input-output bi-ostatok-start[12] , input-output bo-ostatok-start[12] , input-output b1-ostatok-start[12] , input-output b2-ostatok-start[12] ) .
    run calc-ms-wt in this-procedure ( input ostatok-end[1] , input gds-ms-base , input-output    ostatok-end[12] , input-output bi-ostatok-end[12] , input-output bo-ostatok-end[12] , input-output b1-ostatok-end[12] , input-output b2-ostatok-end[12] ) .
    run calc-ms-wt in this-procedure ( input oborot-ie[1] , input gds-ms-base , input-output    oborot-ie[12] , input-output bi-oborot-ie[12] , input-output bo-oborot-ie[12] , input-output b1-oborot-ie[12] , input-output b2-oborot-ie[12] ) .
    run calc-ms-wt in this-procedure ( input oborot-ee[1] , input gds-ms-base , input-output    oborot-ee[12] , input-output bi-oborot-ee[12] , input-output bo-oborot-ee[12] , input-output b1-oborot-ee[12] , input-output b2-oborot-ee[12] ) .
    run calc-ms-wt in this-procedure ( input oborot-ep[1] , input gds-ms-base , input-output    oborot-ep[12] , input-output bi-oborot-ep[12] , input-output bo-oborot-ep[12] , input-output b1-oborot-ep[12] , input-output b2-oborot-ep[12] ) .
    run calc-ms-wt in this-procedure ( input oborot-es[1] , input gds-ms-base , input-output    oborot-es[12] , input-output bi-oborot-es[12] , input-output bo-oborot-es[12] , input-output b1-oborot-es[12] , input-output b2-oborot-es[12] ) .
    run calc-ms-wt in this-procedure ( input oborot-re[1] , input gds-ms-base , input-output    oborot-re[12] , input-output bi-oborot-re[12] , input-output bo-oborot-re[12] , input-output b1-oborot-re[12] , input-output b2-oborot-re[12] ) .
    run calc-ms-wt in this-procedure ( input oborot-rs[1] , input gds-ms-base , input-output    oborot-rs[12] , input-output bi-oborot-rs[12] , input-output bo-oborot-rs[12] , input-output b1-oborot-rs[12] , input-output b2-oborot-rs[12] ) .
    run calc-ms-wt in this-procedure ( input oborot-we[1] , input gds-ms-base , input-output    oborot-we[12] , input-output bi-oborot-we[12] , input-output bo-oborot-we[12] , input-output b1-oborot-we[12] , input-output b2-oborot-we[12] ) .
    run calc-ms-wt in this-procedure ( input oborot-vt[1] , input gds-ms-base , input-output    oborot-vt[12] , input-output bi-oborot-vt[12] , input-output bo-oborot-vt[12] , input-output b1-oborot-vt[12] , input-output b2-oborot-vt[12] ) .
    run calc-ms-wt in this-procedure ( input oborot-iv[1] , input gds-ms-base , input-output    oborot-iv[12] , input-output bi-oborot-iv[12] , input-output bo-oborot-iv[12] , input-output b1-oborot-iv[12] , input-output b2-oborot-iv[12] ) .
    run calc-ms-wt in this-procedure ( input oborot-ev[1] , input gds-ms-base , input-output    oborot-ev[12] , input-output bi-oborot-ev[12] , input-output bo-oborot-ev[12] , input-output b1-oborot-ev[12] , input-output b2-oborot-ev[12] ) .
    run calc-ms-wt in this-procedure ( input oborot-rv[1] , input gds-ms-base , input-output    oborot-rv[12] , input-output bi-oborot-rv[12] , input-output bo-oborot-rv[12] , input-output b1-oborot-rv[12] , input-output b2-oborot-rv[12] ) .
    run calc-ms-wt in this-procedure ( input oborot-em[1] , input gds-ms-base , input-output    oborot-em[12] , input-output bi-oborot-em[12] , input-output bo-oborot-em[12] , input-output b1-oborot-em[12] , input-output b2-oborot-em[12] ) .
    run calc-ms-wt in this-procedure ( input oborot-im[1] , input gds-ms-base , input-output    oborot-im[12] , input-output bi-oborot-im[12] , input-output bo-oborot-im[12] , input-output b1-oborot-im[12] , input-output b2-oborot-im[12] ) .
    run calc-ms-wt in this-procedure ( input oborot-ot[1] , input gds-ms-base , input-output    oborot-ot[12] , input-output bi-oborot-ot[12] , input-output bo-oborot-ot[12] , input-output b1-oborot-ot[12] , input-output b2-oborot-ot[12] ) .
    run calc-ms-wt in this-procedure ( input oborot-ap[1] , input gds-ms-base , input-output    oborot-ap[12] , input-output bi-oborot-ap[12] , input-output bo-oborot-ap[12] , input-output b1-oborot-ap[12] , input-output b2-oborot-ap[12] ) .
    run calc-ms-wt in this-procedure ( input oborot-pc[1] , input gds-ms-base , input-output    oborot-pc[12] , input-output bi-oborot-pc[12] , input-output bo-oborot-pc[12] , input-output b1-oborot-pc[12] , input-output b2-oborot-pc[12] ) .
end.
END PROCEDURE.
PROCEDURE display-line :
  i = i + 1.
   IF NOT  (NOT Show-Negativ   AND Null-Str#  = 0  ) then DO:
      IF NOT  (NOT Show-Negativ-2 AND Null-Str2# = 0  ) then DO:
        new-page = PAGE-NUMBER( OutStream).
        If old-page <> new-page then p = 0.
        IF NOT Sums-Only then  do:
            if fr0 = true then do:
              PUT stream  OutStream  tmp#stroka0 format "X(100)" SKIP.
              fr0 = false .
            end.
            if fr = true then dO:
              PUT stream OutStream space(6) temp-str format "X(100)" SKIP.
              fr = false .
            end.
            Run Display-str1  in this-procedure .
            end.
      End.
    END.
    old-page = new-page.
END PROCEDURE.
PROCEDURE print-header :
if NOT FirstLine Then  Run Display-Title  in this-procedure .
    FirstLine = TRUE .
    if xTog-obj and   x-SelectObject <> "currency":U   Then  DO:
          PUT stream  OutStream  UNFORMATTED
          string(  "ПО ОБЪЕКТУ : (" + x-store-type  + string(x-store-code)  +  ") " + ObjName)
          AT 30 format "X(170)" SKIP.
          End.
          FORM with FRAME ZAPAS .   DOWN stream   OutStream 1 with FRAME ZAPAS .
      RUN Clear-B1  in this-procedure .
      RUN Clear-B2  in this-procedure .
      RUN Clear-Bi  in this-procedure .
      break_group = true.
      break_group1 = true.
      display STREAM OutStream     with frame top-Frame .
      display STREAM OutStream     with frame top-2 .
END PROCEDURE.
PROCEDURE Print-Footer :
      If RetClassify = "no-classify":U  then Run U-line  in this-procedure .
       gds-zap-artic = "ИТОГО" .
       Run display-BI  in this-procedure .
       Run U-line  in this-procedure .
       END PROCEDURE.
PROCEDURE U-LINE :
        PUT stream  OutStream  UNFORMATTED  line2 SKIP.
END PROCEDURE.
PROCEDURE P-LINE :
        END PROCEDURE.
PROCEDURE CalcItog :
    run ostatok   in this-procedure (
        input x-store-code  ,
        input x-store-type  , x-TOG-Shift,
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
    run ostatok   in this-procedure (
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
  assign
    v-gds-num = v-gds-num + 1
  .
 if line-counter( OutStream )  > page-size( OutStream ) then DO : display STREAM OutStream    with frame top-frame. end.
  p = p + 1.
  if use-column[28] then c-str-num:screen-value           =  string( v-gds-num ) .
  if use-column[1] then  c-s-bar-code:screen-value        = s-bar-code.
  if use-column[2] then  c-gds-zap-artic:screen-value     = gds-zap-artic.
  if use-column[3] then  c-gds-zap-gds-name:screen-value  = gds-zap-gds-name.
  if use-column[4] then  c-gds-zap-unit-base:screen-value = gds-zap-unit-base.
  if use-column[5] then  c-gds-type:screen-value          = "кол-во"   .
  if use-column[21] then C-oborot-disc:screen-value  = string(  oborot-disc [1]) .
  if use-column[23] then C-oborot-eff:screen-value  = string(  oborot-eff [1]) .
  if use-column[24] then C-oborot-prc:screen-value  = string(  oborot-prc [1]) .
  if use-column[6]  then C-ostatok-start:screen-value                          = string(  ostatok-start  [1])                         .
  if use-column[7]  then C-oborot-ie:screen-value          = string(  oborot-ie [1]        )  .
  if use-column[8]  then C-oborot-iv:screen-value          = string(  oborot-iv [1]        )  .
  if use-column[9]  then C-oborot-im:screen-value           = string(  oborot-im  [1]        )  .
  if use-column[10] then C-oborot-ee:screen-value          = string(  oborot-ee [1]        )  .
  if use-column[11] then C-oborot-ev:screen-value          = string(  oborot-ev [1]        )  .
  if use-column[12] then C-oborot-em:screen-value           = string(  oborot-em  [1]        )  .
  if use-column[13] then C-oborot-we:screen-value          = string(  oborot-we         [1])  .
  if use-column[14] then C-oborot-es:screen-value     = string(  oborot-es    [1])  .
  if use-column[15] then C-oborot-rs:screen-value = string(  oborot-rs[1])  .
  if use-column[16] then C-oborot-re:screen-value      = string(  oborot-re     [1])  .
  if use-column[17] then C-oborot-ep:screen-value       = string(  oborot-ep      [1])  .
  if use-column[18] then C-oborot-rv:screen-value      = string(  oborot-rv     [1])  .
  if use-column[19] then C-oborot-vt:screen-value                = string(  oborot-vt               [1])  .
  if use-column[20] then C-oborot-ot:screen-value           = string(  oborot-ot          [1])  .
  if use-column[22] then C-ostatok-end:screen-value                            = string(  ostatok-end                           [1])  .
  if use-column[25] then C-oborot-ap:screen-value     = string(  oborot-ap    [1])  .
  if use-column[26] then C-oborot-pc:screen-value     = string(  oborot-pc    [1])  .
  if use-column[27] then C-oborot-r-v:screen-value                      = string(  oborot-ee         [1] +
                                                                                          oborot-re     [1] +
                                                                                          oborot-es    [1] +
                                                                                          oborot-rs[1] ).
  DISPLAY stream  OutStream  with FRAME ZAPAS .  DOWN stream   OutStream 1 with FRAME ZAPAS.
  if x-tog-wt then do :
 if line-counter( OutStream )  > page-size( OutStream ) then DO : display STREAM OutStream    with frame top-frame. end.
  p = p + 1.
  if use-column[28] then c-str-num:screen-value           = '' .
  if use-column[5] then  c-gds-type:screen-value          = "вес"   .
  if use-column[6]  then C-ostatok-start:screen-value                          = string(  ostatok-start  [11])                         .
  if use-column[7]  then C-oborot-ie:screen-value          = string(  oborot-ie [11]        )  .
  if use-column[8]  then C-oborot-iv:screen-value          = string(  oborot-iv [11]        )  .
  if use-column[9]  then C-oborot-im:screen-value           = string(  oborot-im  [11]        )  .
  if use-column[10] then C-oborot-ee:screen-value          = string(  oborot-ee [11]        )  .
  if use-column[11] then C-oborot-ev:screen-value          = string(  oborot-ev [11]        )  .
  if use-column[12] then C-oborot-em:screen-value           = string(  oborot-em  [11]        )  .
  if use-column[13] then C-oborot-we:screen-value          = string(  oborot-we         [11])  .
  if use-column[14] then C-oborot-es:screen-value     = string(  oborot-es    [11])  .
  if use-column[15] then C-oborot-rs:screen-value = string(  oborot-rs[11])  .
  if use-column[16] then C-oborot-re:screen-value      = string(  oborot-re     [11])  .
  if use-column[17] then C-oborot-ep:screen-value       = string(  oborot-ep      [11])  .
  if use-column[18] then C-oborot-rv:screen-value      = string(  oborot-rv     [11])  .
  if use-column[19] then C-oborot-vt:screen-value                = string(  oborot-vt               [11])  .
  if use-column[20] then C-oborot-ot:screen-value           = string(  oborot-ot          [11])  .
  if use-column[22] then C-ostatok-end:screen-value                            = string(  ostatok-end                           [11])  .
  if use-column[25] then C-oborot-ap:screen-value     = string(  oborot-ap    [11])  .
  if use-column[26] then C-oborot-pc:screen-value     = string(  oborot-pc    [11])  .
  if use-column[27] then C-oborot-r-v:screen-value                      = string(  oborot-ee         [11] +
                                                                                          oborot-re     [11] +
                                                                                          oborot-es    [11] +
                                                                                          oborot-rs[11] ).
  DISPLAY stream  OutStream  with FRAME ZAPAS .  DOWN stream   OutStream 1 with FRAME ZAPAS.
  end.
  if x-tog-ms then do :
 if line-counter( OutStream )  > page-size( OutStream ) then DO : display STREAM OutStream    with frame top-frame. end.
  p = p + 1.
  if use-column[28] then c-str-num:screen-value           = '' .
  if use-column[5] then  c-gds-type:screen-value          = "объем"   .
  if use-column[6]  then C-ostatok-start:screen-value                          = string(  ostatok-start  [12])                         .
  if use-column[7]  then C-oborot-ie:screen-value          = string(  oborot-ie [12]        )  .
  if use-column[8]  then C-oborot-iv:screen-value          = string(  oborot-iv [12]        )  .
  if use-column[9]  then C-oborot-im:screen-value           = string(  oborot-im  [12]        )  .
  if use-column[10] then C-oborot-ee:screen-value          = string(  oborot-ee [12]        )  .
  if use-column[11] then C-oborot-ev:screen-value          = string(  oborot-ev [12]        )  .
  if use-column[12] then C-oborot-em:screen-value           = string(  oborot-em  [12]        )  .
  if use-column[13] then C-oborot-we:screen-value          = string(  oborot-we         [12])  .
  if use-column[14] then C-oborot-es:screen-value     = string(  oborot-es    [12])  .
  if use-column[15] then C-oborot-rs:screen-value = string(  oborot-rs[12])  .
  if use-column[16] then C-oborot-re:screen-value      = string(  oborot-re     [12])  .
  if use-column[17] then C-oborot-ep:screen-value       = string(  oborot-ep      [12])  .
  if use-column[18] then C-oborot-rv:screen-value      = string(  oborot-rv     [12])  .
  if use-column[19] then C-oborot-vt:screen-value                = string(  oborot-vt               [12])  .
  if use-column[20] then C-oborot-ot:screen-value           = string(  oborot-ot          [12])  .
  if use-column[22] then C-ostatok-end:screen-value                            = string(  ostatok-end                           [12])  .
  if use-column[25] then C-oborot-ap:screen-value     = string(  oborot-ap    [12])  .
  if use-column[26] then C-oborot-pc:screen-value     = string(  oborot-pc    [12])  .
  if use-column[27] then C-oborot-r-v:screen-value                      = string(  oborot-ee         [12] +
                                                                                          oborot-re     [12] +
                                                                                          oborot-es    [12] +
                                                                                          oborot-rs[12] ).
  DISPLAY stream  OutStream  with FRAME ZAPAS .  DOWN stream   OutStream 1 with FRAME ZAPAS.
  end.
  if xShowCost    Then DO: run PRICE-VAT in this-procedure ('').  end.
  if xShowCostNDS Then DO:
 if line-counter( OutStream )  > page-size( OutStream ) then DO : display STREAM OutStream    with frame top-frame. end.
  p = p + 1.
  if use-column[28] then c-str-num:screen-value           = '' .
  if use-column[5] then  c-gds-type:screen-value          = "НДС учет."   .
  if use-column[6]  then C-ostatok-start:screen-value                          = string(  ostatok-start  [3])                         .
  if use-column[7]  then C-oborot-ie:screen-value          = string(  oborot-ie [3]        )  .
  if use-column[8]  then C-oborot-iv:screen-value          = string(  oborot-iv [3]        )  .
  if use-column[9]  then C-oborot-im:screen-value           = string(  oborot-im  [3]        )  .
  if use-column[10] then C-oborot-ee:screen-value          = string(  oborot-ee [3]        )  .
  if use-column[11] then C-oborot-ev:screen-value          = string(  oborot-ev [3]        )  .
  if use-column[12] then C-oborot-em:screen-value           = string(  oborot-em  [3]        )  .
  if use-column[13] then C-oborot-we:screen-value          = string(  oborot-we         [3])  .
  if use-column[14] then C-oborot-es:screen-value     = string(  oborot-es    [3])  .
  if use-column[15] then C-oborot-rs:screen-value = string(  oborot-rs[3])  .
  if use-column[16] then C-oborot-re:screen-value      = string(  oborot-re     [3])  .
  if use-column[17] then C-oborot-ep:screen-value       = string(  oborot-ep      [3])  .
  if use-column[18] then C-oborot-rv:screen-value      = string(  oborot-rv     [3])  .
  if use-column[19] then C-oborot-vt:screen-value                = string(  oborot-vt               [3])  .
  if use-column[20] then C-oborot-ot:screen-value           = string(  oborot-ot          [3])  .
  if use-column[22] then C-ostatok-end:screen-value                            = string(  ostatok-end                           [3])  .
  if use-column[25] then C-oborot-ap:screen-value     = string(  oborot-ap    [3])  .
  if use-column[26] then C-oborot-pc:screen-value     = string(  oborot-pc    [3])  .
  if use-column[27] then C-oborot-r-v:screen-value                      = string(  oborot-ee         [3] +
                                                                                          oborot-re     [3] +
                                                                                          oborot-es    [3] +
                                                                                          oborot-rs[3] ).
  DISPLAY stream  OutStream  with FRAME ZAPAS .  DOWN stream   OutStream 1 with FRAME ZAPAS.
  End.
  if xShowCrsa    Then DO:
 if line-counter( OutStream )  > page-size( OutStream ) then DO : display STREAM OutStream    with frame top-frame. end.
  p = p + 1.
  if use-column[28] then c-str-num:screen-value           = '' .
  if use-column[5] then  c-gds-type:screen-value          = "прод."   .
  if use-column[6]  then C-ostatok-start:screen-value                          = string(  ostatok-start  [5])                         .
  if use-column[7]  then C-oborot-ie:screen-value          = string(  oborot-ie [5]        )  .
  if use-column[8]  then C-oborot-iv:screen-value          = string(  oborot-iv [5]        )  .
  if use-column[9]  then C-oborot-im:screen-value           = string(  oborot-im  [5]        )  .
  if use-column[10] then C-oborot-ee:screen-value          = string(  oborot-ee [5]        )  .
  if use-column[11] then C-oborot-ev:screen-value          = string(  oborot-ev [5]        )  .
  if use-column[12] then C-oborot-em:screen-value           = string(  oborot-em  [5]        )  .
  if use-column[13] then C-oborot-we:screen-value          = string(  oborot-we         [5])  .
  if use-column[14] then C-oborot-es:screen-value     = string(  oborot-es    [5])  .
  if use-column[15] then C-oborot-rs:screen-value = string(  oborot-rs[5])  .
  if use-column[16] then C-oborot-re:screen-value      = string(  oborot-re     [5])  .
  if use-column[17] then C-oborot-ep:screen-value       = string(  oborot-ep      [5])  .
  if use-column[18] then C-oborot-rv:screen-value      = string(  oborot-rv     [5])  .
  if use-column[19] then C-oborot-vt:screen-value                = string(  oborot-vt               [5])  .
  if use-column[20] then C-oborot-ot:screen-value           = string(  oborot-ot          [5])  .
  if use-column[22] then C-ostatok-end:screen-value                            = string(  ostatok-end                           [5])  .
  if use-column[25] then C-oborot-ap:screen-value     = string(  oborot-ap    [5])  .
  if use-column[26] then C-oborot-pc:screen-value     = string(  oborot-pc    [5])  .
  if use-column[27] then C-oborot-r-v:screen-value                      = string(  oborot-ee         [5] +
                                                                                          oborot-re     [5] +
                                                                                          oborot-es    [5] +
                                                                                          oborot-rs[5] ).
  DISPLAY stream  OutStream  with FRAME ZAPAS .  DOWN stream   OutStream 1 with FRAME ZAPAS.
  End.
  if xShowCrsaNds Then DO:
 if line-counter( OutStream )  > page-size( OutStream ) then DO : display STREAM OutStream    with frame top-frame. end.
  p = p + 1.
  if use-column[28] then c-str-num:screen-value           = '' .
  if use-column[5] then  c-gds-type:screen-value          = "НДС прод."   .
  if use-column[6]  then C-ostatok-start:screen-value                          = string(  ostatok-start  [6])                         .
  if use-column[7]  then C-oborot-ie:screen-value          = string(  oborot-ie [6]        )  .
  if use-column[8]  then C-oborot-iv:screen-value          = string(  oborot-iv [6]        )  .
  if use-column[9]  then C-oborot-im:screen-value           = string(  oborot-im  [6]        )  .
  if use-column[10] then C-oborot-ee:screen-value          = string(  oborot-ee [6]        )  .
  if use-column[11] then C-oborot-ev:screen-value          = string(  oborot-ev [6]        )  .
  if use-column[12] then C-oborot-em:screen-value           = string(  oborot-em  [6]        )  .
  if use-column[13] then C-oborot-we:screen-value          = string(  oborot-we         [6])  .
  if use-column[14] then C-oborot-es:screen-value     = string(  oborot-es    [6])  .
  if use-column[15] then C-oborot-rs:screen-value = string(  oborot-rs[6])  .
  if use-column[16] then C-oborot-re:screen-value      = string(  oborot-re     [6])  .
  if use-column[17] then C-oborot-ep:screen-value       = string(  oborot-ep      [6])  .
  if use-column[18] then C-oborot-rv:screen-value      = string(  oborot-rv     [6])  .
  if use-column[19] then C-oborot-vt:screen-value                = string(  oborot-vt               [6])  .
  if use-column[20] then C-oborot-ot:screen-value           = string(  oborot-ot          [6])  .
  if use-column[22] then C-ostatok-end:screen-value                            = string(  ostatok-end                           [6])  .
  if use-column[25] then C-oborot-ap:screen-value     = string(  oborot-ap    [6])  .
  if use-column[26] then C-oborot-pc:screen-value     = string(  oborot-pc    [6])  .
  if use-column[27] then C-oborot-r-v:screen-value                      = string(  oborot-ee         [6] +
                                                                                          oborot-re     [6] +
                                                                                          oborot-es    [6] +
                                                                                          oborot-rs[6] ).
  DISPLAY stream  OutStream  with FRAME ZAPAS .  DOWN stream   OutStream 1 with FRAME ZAPAS.
  End.
  if xShowSAle    Then DO:
 if line-counter( OutStream )  > page-size( OutStream ) then DO : display STREAM OutStream    with frame top-frame. end.
  p = p + 1.
  if use-column[28] then c-str-num:screen-value           = '' .
  if use-column[5] then  c-gds-type:screen-value          = "док."   .
  if use-column[6]  then C-ostatok-start:screen-value                          = string(  ostatok-start  [8])                         .
  if use-column[7]  then C-oborot-ie:screen-value          = string(  oborot-ie [8]        )  .
  if use-column[8]  then C-oborot-iv:screen-value          = string(  oborot-iv [8]        )  .
  if use-column[9]  then C-oborot-im:screen-value           = string(  oborot-im  [8]        )  .
  if use-column[10] then C-oborot-ee:screen-value          = string(  oborot-ee [8]        )  .
  if use-column[11] then C-oborot-ev:screen-value          = string(  oborot-ev [8]        )  .
  if use-column[12] then C-oborot-em:screen-value           = string(  oborot-em  [8]        )  .
  if use-column[13] then C-oborot-we:screen-value          = string(  oborot-we         [8])  .
  if use-column[14] then C-oborot-es:screen-value     = string(  oborot-es    [8])  .
  if use-column[15] then C-oborot-rs:screen-value = string(  oborot-rs[8])  .
  if use-column[16] then C-oborot-re:screen-value      = string(  oborot-re     [8])  .
  if use-column[17] then C-oborot-ep:screen-value       = string(  oborot-ep      [8])  .
  if use-column[18] then C-oborot-rv:screen-value      = string(  oborot-rv     [8])  .
  if use-column[19] then C-oborot-vt:screen-value                = string(  oborot-vt               [8])  .
  if use-column[20] then C-oborot-ot:screen-value           = string(  oborot-ot          [8])  .
  if use-column[22] then C-ostatok-end:screen-value                            = string(  ostatok-end                           [8])  .
  if use-column[25] then C-oborot-ap:screen-value     = string(  oborot-ap    [8])  .
  if use-column[26] then C-oborot-pc:screen-value     = string(  oborot-pc    [8])  .
  if use-column[27] then C-oborot-r-v:screen-value                      = string(  oborot-ee         [8] +
                                                                                          oborot-re     [8] +
                                                                                          oborot-es    [8] +
                                                                                          oborot-rs[8] ).
  DISPLAY stream  OutStream  with FRAME ZAPAS .  DOWN stream   OutStream 1 with FRAME ZAPAS.
  End.
  if xShowSaleNds Then DO:
 if line-counter( OutStream )  > page-size( OutStream ) then DO : display STREAM OutStream    with frame top-frame. end.
  p = p + 1.
  if use-column[28] then c-str-num:screen-value           = '' .
  if use-column[5] then  c-gds-type:screen-value          = "НДС док."   .
  if use-column[6]  then C-ostatok-start:screen-value                          = string(  ostatok-start  [9])                         .
  if use-column[7]  then C-oborot-ie:screen-value          = string(  oborot-ie [9]        )  .
  if use-column[8]  then C-oborot-iv:screen-value          = string(  oborot-iv [9]        )  .
  if use-column[9]  then C-oborot-im:screen-value           = string(  oborot-im  [9]        )  .
  if use-column[10] then C-oborot-ee:screen-value          = string(  oborot-ee [9]        )  .
  if use-column[11] then C-oborot-ev:screen-value          = string(  oborot-ev [9]        )  .
  if use-column[12] then C-oborot-em:screen-value           = string(  oborot-em  [9]        )  .
  if use-column[13] then C-oborot-we:screen-value          = string(  oborot-we         [9])  .
  if use-column[14] then C-oborot-es:screen-value     = string(  oborot-es    [9])  .
  if use-column[15] then C-oborot-rs:screen-value = string(  oborot-rs[9])  .
  if use-column[16] then C-oborot-re:screen-value      = string(  oborot-re     [9])  .
  if use-column[17] then C-oborot-ep:screen-value       = string(  oborot-ep      [9])  .
  if use-column[18] then C-oborot-rv:screen-value      = string(  oborot-rv     [9])  .
  if use-column[19] then C-oborot-vt:screen-value                = string(  oborot-vt               [9])  .
  if use-column[20] then C-oborot-ot:screen-value           = string(  oborot-ot          [9])  .
  if use-column[22] then C-ostatok-end:screen-value                            = string(  ostatok-end                           [9])  .
  if use-column[25] then C-oborot-ap:screen-value     = string(  oborot-ap    [9])  .
  if use-column[26] then C-oborot-pc:screen-value     = string(  oborot-pc    [9])  .
  if use-column[27] then C-oborot-r-v:screen-value                      = string(  oborot-ee         [9] +
                                                                                          oborot-re     [9] +
                                                                                          oborot-es    [9] +
                                                                                          oborot-rs[9] ).
  DISPLAY stream  OutStream  with FRAME ZAPAS .  DOWN stream   OutStream 1 with FRAME ZAPAS.
  End.
  if xShowSaleSLT Then DO:
 if line-counter( OutStream )  > page-size( OutStream ) then DO : display STREAM OutStream    with frame top-frame. end.
  p = p + 1.
  if use-column[28] then c-str-num:screen-value           = '' .
  if use-column[5] then  c-gds-type:screen-value          = "НсП док."   .
  if use-column[6]  then C-ostatok-start:screen-value                          = string(  ostatok-start  [10])                         .
  if use-column[7]  then C-oborot-ie:screen-value          = string(  oborot-ie [10]        )  .
  if use-column[8]  then C-oborot-iv:screen-value          = string(  oborot-iv [10]        )  .
  if use-column[9]  then C-oborot-im:screen-value           = string(  oborot-im  [10]        )  .
  if use-column[10] then C-oborot-ee:screen-value          = string(  oborot-ee [10]        )  .
  if use-column[11] then C-oborot-ev:screen-value          = string(  oborot-ev [10]        )  .
  if use-column[12] then C-oborot-em:screen-value           = string(  oborot-em  [10]        )  .
  if use-column[13] then C-oborot-we:screen-value          = string(  oborot-we         [10])  .
  if use-column[14] then C-oborot-es:screen-value     = string(  oborot-es    [10])  .
  if use-column[15] then C-oborot-rs:screen-value = string(  oborot-rs[10])  .
  if use-column[16] then C-oborot-re:screen-value      = string(  oborot-re     [10])  .
  if use-column[17] then C-oborot-ep:screen-value       = string(  oborot-ep      [10])  .
  if use-column[18] then C-oborot-rv:screen-value      = string(  oborot-rv     [10])  .
  if use-column[19] then C-oborot-vt:screen-value                = string(  oborot-vt               [10])  .
  if use-column[20] then C-oborot-ot:screen-value           = string(  oborot-ot          [10])  .
  if use-column[22] then C-ostatok-end:screen-value                            = string(  ostatok-end                           [10])  .
  if use-column[25] then C-oborot-ap:screen-value     = string(  oborot-ap    [10])  .
  if use-column[26] then C-oborot-pc:screen-value     = string(  oborot-pc    [10])  .
  if use-column[27] then C-oborot-r-v:screen-value                      = string(  oborot-ee         [10] +
                                                                                          oborot-re     [10] +
                                                                                          oborot-es    [10] +
                                                                                          oborot-rs[10] ).
  DISPLAY stream  OutStream  with FRAME ZAPAS .  DOWN stream   OutStream 1 with FRAME ZAPAS.
  End.
  if xShowMediator Then DO:
 if line-counter( OutStream )  > page-size( OutStream ) then DO : display STREAM OutStream    with frame top-frame. end.
  p = p + 1.
  if use-column[28] then c-str-num:screen-value           = '' .
  if use-column[5] then  c-gds-type:screen-value          = "поср."   .
  if use-column[6]  then C-ostatok-start:screen-value                          = string(  ostatok-start  [4])                         .
  if use-column[7]  then C-oborot-ie:screen-value          = string(  oborot-ie [4]        )  .
  if use-column[8]  then C-oborot-iv:screen-value          = string(  oborot-iv [4]        )  .
  if use-column[9]  then C-oborot-im:screen-value           = string(  oborot-im  [4]        )  .
  if use-column[10] then C-oborot-ee:screen-value          = string(  oborot-ee [4]        )  .
  if use-column[11] then C-oborot-ev:screen-value          = string(  oborot-ev [4]        )  .
  if use-column[12] then C-oborot-em:screen-value           = string(  oborot-em  [4]        )  .
  if use-column[13] then C-oborot-we:screen-value          = string(  oborot-we         [4])  .
  if use-column[14] then C-oborot-es:screen-value     = string(  oborot-es    [4])  .
  if use-column[15] then C-oborot-rs:screen-value = string(  oborot-rs[4])  .
  if use-column[16] then C-oborot-re:screen-value      = string(  oborot-re     [4])  .
  if use-column[17] then C-oborot-ep:screen-value       = string(  oborot-ep      [4])  .
  if use-column[18] then C-oborot-rv:screen-value      = string(  oborot-rv     [4])  .
  if use-column[19] then C-oborot-vt:screen-value                = string(  oborot-vt               [4])  .
  if use-column[20] then C-oborot-ot:screen-value           = string(  oborot-ot          [4])  .
  if use-column[22] then C-ostatok-end:screen-value                            = string(  ostatok-end                           [4])  .
  if use-column[25] then C-oborot-ap:screen-value     = string(  oborot-ap    [4])  .
  if use-column[26] then C-oborot-pc:screen-value     = string(  oborot-pc    [4])  .
  if use-column[27] then C-oborot-r-v:screen-value                      = string(  oborot-ee         [4] +
                                                                                          oborot-re     [4] +
                                                                                          oborot-es    [4] +
                                                                                          oborot-rs[4] ).
  DISPLAY stream  OutStream  with FRAME ZAPAS .  DOWN stream   OutStream 1 with FRAME ZAPAS.
   End.
END PROCEDURE.
PROCEDURE display-Bi  :
 if line-counter( OutStream )  > page-size( OutStream ) then DO : display STREAM OutStream    with frame top-frame. end.
  p = p + 1.
  if use-column[28] then c-str-num:screen-value           = '' .
  if use-column[1] then  c-s-bar-code:screen-value        = ''.
  if use-column[2] then  c-gds-zap-artic:screen-value     = gds-zap-artic.
  if use-column[3] then  c-gds-zap-gds-name:screen-value  = ''.
  if use-column[4] then  c-gds-zap-unit-base:screen-value = ''.
  if use-column[5] then  c-gds-type:screen-value          = "кол-во"   .
  if use-column[21] then C-oborot-disc:screen-value  = string( Bi-oborot-disc [1]) .
  if use-column[23] then C-oborot-eff:screen-value  = string( Bi-oborot-eff [1]) .
  if use-column[24] then C-oborot-prc:screen-value  = string( Bi-oborot-prc [1]) .
  if use-column[6]  then C-ostatok-start:screen-value                          = string( Bi-ostatok-start  [1])                         .
  if use-column[7]  then C-oborot-ie:screen-value          = string( Bi-oborot-ie [1]        )  .
  if use-column[8]  then C-oborot-iv:screen-value          = string( Bi-oborot-iv [1]        )  .
  if use-column[9]  then C-oborot-im:screen-value           = string( Bi-oborot-im  [1]        )  .
  if use-column[10] then C-oborot-ee:screen-value          = string( Bi-oborot-ee [1]        )  .
  if use-column[11] then C-oborot-ev:screen-value          = string( Bi-oborot-ev [1]        )  .
  if use-column[12] then C-oborot-em:screen-value           = string( Bi-oborot-em  [1]        )  .
  if use-column[13] then C-oborot-we:screen-value          = string( Bi-oborot-we         [1])  .
  if use-column[14] then C-oborot-es:screen-value     = string( Bi-oborot-es    [1])  .
  if use-column[15] then C-oborot-rs:screen-value = string( Bi-oborot-rs[1])  .
  if use-column[16] then C-oborot-re:screen-value      = string( Bi-oborot-re     [1])  .
  if use-column[17] then C-oborot-ep:screen-value       = string( Bi-oborot-ep      [1])  .
  if use-column[18] then C-oborot-rv:screen-value      = string( Bi-oborot-rv     [1])  .
  if use-column[19] then C-oborot-vt:screen-value                = string( Bi-oborot-vt               [1])  .
  if use-column[20] then C-oborot-ot:screen-value           = string( Bi-oborot-ot          [1])  .
  if use-column[22] then C-ostatok-end:screen-value                            = string( Bi-ostatok-end                           [1])  .
  if use-column[25] then C-oborot-ap:screen-value     = string( Bi-oborot-ap    [1])  .
  if use-column[26] then C-oborot-pc:screen-value     = string( Bi-oborot-pc    [1])  .
  if use-column[27] then C-oborot-r-v:screen-value                      = string( Bi-oborot-ee         [1] +
                                                                                         Bi-oborot-re     [1] +
                                                                                         Bi-oborot-es    [1] +
                                                                                         Bi-oborot-rs[1] ).
  DISPLAY stream  OutStream  with FRAME ZAPAS .  DOWN stream   OutStream 1 with FRAME ZAPAS.
  if x-tog-wt then do :
 if line-counter( OutStream )  > page-size( OutStream ) then DO : display STREAM OutStream    with frame top-frame. end.
  p = p + 1.
  if use-column[28] then c-str-num:screen-value           = '' .
  if use-column[5] then  c-gds-type:screen-value          = "вес"   .
  if use-column[6]  then C-ostatok-start:screen-value                          = string( Bi-ostatok-start  [11])                         .
  if use-column[7]  then C-oborot-ie:screen-value          = string( Bi-oborot-ie [11]        )  .
  if use-column[8]  then C-oborot-iv:screen-value          = string( Bi-oborot-iv [11]        )  .
  if use-column[9]  then C-oborot-im:screen-value           = string( Bi-oborot-im  [11]        )  .
  if use-column[10] then C-oborot-ee:screen-value          = string( Bi-oborot-ee [11]        )  .
  if use-column[11] then C-oborot-ev:screen-value          = string( Bi-oborot-ev [11]        )  .
  if use-column[12] then C-oborot-em:screen-value           = string( Bi-oborot-em  [11]        )  .
  if use-column[13] then C-oborot-we:screen-value          = string( Bi-oborot-we         [11])  .
  if use-column[14] then C-oborot-es:screen-value     = string( Bi-oborot-es    [11])  .
  if use-column[15] then C-oborot-rs:screen-value = string( Bi-oborot-rs[11])  .
  if use-column[16] then C-oborot-re:screen-value      = string( Bi-oborot-re     [11])  .
  if use-column[17] then C-oborot-ep:screen-value       = string( Bi-oborot-ep      [11])  .
  if use-column[18] then C-oborot-rv:screen-value      = string( Bi-oborot-rv     [11])  .
  if use-column[19] then C-oborot-vt:screen-value                = string( Bi-oborot-vt               [11])  .
  if use-column[20] then C-oborot-ot:screen-value           = string( Bi-oborot-ot          [11])  .
  if use-column[22] then C-ostatok-end:screen-value                            = string( Bi-ostatok-end                           [11])  .
  if use-column[25] then C-oborot-ap:screen-value     = string( Bi-oborot-ap    [11])  .
  if use-column[26] then C-oborot-pc:screen-value     = string( Bi-oborot-pc    [11])  .
  if use-column[27] then C-oborot-r-v:screen-value                      = string( Bi-oborot-ee         [11] +
                                                                                         Bi-oborot-re     [11] +
                                                                                         Bi-oborot-es    [11] +
                                                                                         Bi-oborot-rs[11] ).
  DISPLAY stream  OutStream  with FRAME ZAPAS .  DOWN stream   OutStream 1 with FRAME ZAPAS.
  end.
  if x-tog-ms then do :
 if line-counter( OutStream )  > page-size( OutStream ) then DO : display STREAM OutStream    with frame top-frame. end.
  p = p + 1.
  if use-column[28] then c-str-num:screen-value           = '' .
  if use-column[5] then  c-gds-type:screen-value          = "объем"   .
  if use-column[6]  then C-ostatok-start:screen-value                          = string( Bi-ostatok-start  [12])                         .
  if use-column[7]  then C-oborot-ie:screen-value          = string( Bi-oborot-ie [12]        )  .
  if use-column[8]  then C-oborot-iv:screen-value          = string( Bi-oborot-iv [12]        )  .
  if use-column[9]  then C-oborot-im:screen-value           = string( Bi-oborot-im  [12]        )  .
  if use-column[10] then C-oborot-ee:screen-value          = string( Bi-oborot-ee [12]        )  .
  if use-column[11] then C-oborot-ev:screen-value          = string( Bi-oborot-ev [12]        )  .
  if use-column[12] then C-oborot-em:screen-value           = string( Bi-oborot-em  [12]        )  .
  if use-column[13] then C-oborot-we:screen-value          = string( Bi-oborot-we         [12])  .
  if use-column[14] then C-oborot-es:screen-value     = string( Bi-oborot-es    [12])  .
  if use-column[15] then C-oborot-rs:screen-value = string( Bi-oborot-rs[12])  .
  if use-column[16] then C-oborot-re:screen-value      = string( Bi-oborot-re     [12])  .
  if use-column[17] then C-oborot-ep:screen-value       = string( Bi-oborot-ep      [12])  .
  if use-column[18] then C-oborot-rv:screen-value      = string( Bi-oborot-rv     [12])  .
  if use-column[19] then C-oborot-vt:screen-value                = string( Bi-oborot-vt               [12])  .
  if use-column[20] then C-oborot-ot:screen-value           = string( Bi-oborot-ot          [12])  .
  if use-column[22] then C-ostatok-end:screen-value                            = string( Bi-ostatok-end                           [12])  .
  if use-column[25] then C-oborot-ap:screen-value     = string( Bi-oborot-ap    [12])  .
  if use-column[26] then C-oborot-pc:screen-value     = string( Bi-oborot-pc    [12])  .
  if use-column[27] then C-oborot-r-v:screen-value                      = string( Bi-oborot-ee         [12] +
                                                                                         Bi-oborot-re     [12] +
                                                                                         Bi-oborot-es    [12] +
                                                                                         Bi-oborot-rs[12] ).
  DISPLAY stream  OutStream  with FRAME ZAPAS .  DOWN stream   OutStream 1 with FRAME ZAPAS.
  end.
  if xShowCost    Then DO:  run PRICE-VAT in this-procedure ('Bi').  end.
  if xShowCostNDS Then DO:
 if line-counter( OutStream )  > page-size( OutStream ) then DO : display STREAM OutStream    with frame top-frame. end.
  p = p + 1.
  if use-column[28] then c-str-num:screen-value           = '' .
  if use-column[1] then  c-s-bar-code:screen-value        = ''.
  if use-column[2] then  c-gds-zap-artic:screen-value     = ''.
  if use-column[3] then  c-gds-zap-gds-name:screen-value  = ''.
  if use-column[4] then  c-gds-zap-unit-base:screen-value = ''.
  if use-column[5] then  c-gds-type:screen-value          = "НДС учет."   .
  if use-column[6]  then C-ostatok-start:screen-value                          = string( Bi-ostatok-start  [3])                         .
  if use-column[7]  then C-oborot-ie:screen-value          = string( Bi-oborot-ie [3]        )  .
  if use-column[8]  then C-oborot-iv:screen-value          = string( Bi-oborot-iv [3]        )  .
  if use-column[9]  then C-oborot-im:screen-value           = string( Bi-oborot-im  [3]        )  .
  if use-column[10] then C-oborot-ee:screen-value          = string( Bi-oborot-ee [3]        )  .
  if use-column[11] then C-oborot-ev:screen-value          = string( Bi-oborot-ev [3]        )  .
  if use-column[12] then C-oborot-em:screen-value           = string( Bi-oborot-em  [3]        )  .
  if use-column[13] then C-oborot-we:screen-value          = string( Bi-oborot-we         [3])  .
  if use-column[14] then C-oborot-es:screen-value     = string( Bi-oborot-es    [3])  .
  if use-column[15] then C-oborot-rs:screen-value = string( Bi-oborot-rs[3])  .
  if use-column[16] then C-oborot-re:screen-value      = string( Bi-oborot-re     [3])  .
  if use-column[17] then C-oborot-ep:screen-value       = string( Bi-oborot-ep      [3])  .
  if use-column[18] then C-oborot-rv:screen-value      = string( Bi-oborot-rv     [3])  .
  if use-column[19] then C-oborot-vt:screen-value                = string( Bi-oborot-vt               [3])  .
  if use-column[20] then C-oborot-ot:screen-value           = string( Bi-oborot-ot          [3])  .
  if use-column[22] then C-ostatok-end:screen-value                            = string( Bi-ostatok-end                           [3])  .
  if use-column[25] then C-oborot-ap:screen-value     = string( Bi-oborot-ap    [3])  .
  if use-column[26] then C-oborot-pc:screen-value     = string( Bi-oborot-pc    [3])  .
  if use-column[27] then C-oborot-r-v:screen-value                      = string( Bi-oborot-ee         [3] +
                                                                                         Bi-oborot-re     [3] +
                                                                                         Bi-oborot-es    [3] +
                                                                                         Bi-oborot-rs[3] ).
  DISPLAY stream  OutStream  with FRAME ZAPAS .  DOWN stream   OutStream 1 with FRAME ZAPAS.
  End.
  if xShowCrsa    Then DO:
 if line-counter( OutStream )  > page-size( OutStream ) then DO : display STREAM OutStream    with frame top-frame. end.
  p = p + 1.
  if use-column[28] then c-str-num:screen-value           = '' .
  if use-column[1] then  c-s-bar-code:screen-value        = ''.
  if use-column[2] then  c-gds-zap-artic:screen-value     = ''.
  if use-column[3] then  c-gds-zap-gds-name:screen-value  = ''.
  if use-column[4] then  c-gds-zap-unit-base:screen-value = ''.
  if use-column[5] then  c-gds-type:screen-value          = "прод."   .
  if use-column[6]  then C-ostatok-start:screen-value                          = string( Bi-ostatok-start  [5])                         .
  if use-column[7]  then C-oborot-ie:screen-value          = string( Bi-oborot-ie [5]        )  .
  if use-column[8]  then C-oborot-iv:screen-value          = string( Bi-oborot-iv [5]        )  .
  if use-column[9]  then C-oborot-im:screen-value           = string( Bi-oborot-im  [5]        )  .
  if use-column[10] then C-oborot-ee:screen-value          = string( Bi-oborot-ee [5]        )  .
  if use-column[11] then C-oborot-ev:screen-value          = string( Bi-oborot-ev [5]        )  .
  if use-column[12] then C-oborot-em:screen-value           = string( Bi-oborot-em  [5]        )  .
  if use-column[13] then C-oborot-we:screen-value          = string( Bi-oborot-we         [5])  .
  if use-column[14] then C-oborot-es:screen-value     = string( Bi-oborot-es    [5])  .
  if use-column[15] then C-oborot-rs:screen-value = string( Bi-oborot-rs[5])  .
  if use-column[16] then C-oborot-re:screen-value      = string( Bi-oborot-re     [5])  .
  if use-column[17] then C-oborot-ep:screen-value       = string( Bi-oborot-ep      [5])  .
  if use-column[18] then C-oborot-rv:screen-value      = string( Bi-oborot-rv     [5])  .
  if use-column[19] then C-oborot-vt:screen-value                = string( Bi-oborot-vt               [5])  .
  if use-column[20] then C-oborot-ot:screen-value           = string( Bi-oborot-ot          [5])  .
  if use-column[22] then C-ostatok-end:screen-value                            = string( Bi-ostatok-end                           [5])  .
  if use-column[25] then C-oborot-ap:screen-value     = string( Bi-oborot-ap    [5])  .
  if use-column[26] then C-oborot-pc:screen-value     = string( Bi-oborot-pc    [5])  .
  if use-column[27] then C-oborot-r-v:screen-value                      = string( Bi-oborot-ee         [5] +
                                                                                         Bi-oborot-re     [5] +
                                                                                         Bi-oborot-es    [5] +
                                                                                         Bi-oborot-rs[5] ).
  DISPLAY stream  OutStream  with FRAME ZAPAS .  DOWN stream   OutStream 1 with FRAME ZAPAS.
  End.
  if xShowCrsaNds Then DO:
 if line-counter( OutStream )  > page-size( OutStream ) then DO : display STREAM OutStream    with frame top-frame. end.
  p = p + 1.
  if use-column[28] then c-str-num:screen-value           = '' .
  if use-column[1] then  c-s-bar-code:screen-value        = ''.
  if use-column[2] then  c-gds-zap-artic:screen-value     = ''.
  if use-column[3] then  c-gds-zap-gds-name:screen-value  = ''.
  if use-column[4] then  c-gds-zap-unit-base:screen-value = ''.
  if use-column[5] then  c-gds-type:screen-value          = "НДС прод."   .
  if use-column[6]  then C-ostatok-start:screen-value                          = string( Bi-ostatok-start  [6])                         .
  if use-column[7]  then C-oborot-ie:screen-value          = string( Bi-oborot-ie [6]        )  .
  if use-column[8]  then C-oborot-iv:screen-value          = string( Bi-oborot-iv [6]        )  .
  if use-column[9]  then C-oborot-im:screen-value           = string( Bi-oborot-im  [6]        )  .
  if use-column[10] then C-oborot-ee:screen-value          = string( Bi-oborot-ee [6]        )  .
  if use-column[11] then C-oborot-ev:screen-value          = string( Bi-oborot-ev [6]        )  .
  if use-column[12] then C-oborot-em:screen-value           = string( Bi-oborot-em  [6]        )  .
  if use-column[13] then C-oborot-we:screen-value          = string( Bi-oborot-we         [6])  .
  if use-column[14] then C-oborot-es:screen-value     = string( Bi-oborot-es    [6])  .
  if use-column[15] then C-oborot-rs:screen-value = string( Bi-oborot-rs[6])  .
  if use-column[16] then C-oborot-re:screen-value      = string( Bi-oborot-re     [6])  .
  if use-column[17] then C-oborot-ep:screen-value       = string( Bi-oborot-ep      [6])  .
  if use-column[18] then C-oborot-rv:screen-value      = string( Bi-oborot-rv     [6])  .
  if use-column[19] then C-oborot-vt:screen-value                = string( Bi-oborot-vt               [6])  .
  if use-column[20] then C-oborot-ot:screen-value           = string( Bi-oborot-ot          [6])  .
  if use-column[22] then C-ostatok-end:screen-value                            = string( Bi-ostatok-end                           [6])  .
  if use-column[25] then C-oborot-ap:screen-value     = string( Bi-oborot-ap    [6])  .
  if use-column[26] then C-oborot-pc:screen-value     = string( Bi-oborot-pc    [6])  .
  if use-column[27] then C-oborot-r-v:screen-value                      = string( Bi-oborot-ee         [6] +
                                                                                         Bi-oborot-re     [6] +
                                                                                         Bi-oborot-es    [6] +
                                                                                         Bi-oborot-rs[6] ).
  DISPLAY stream  OutStream  with FRAME ZAPAS .  DOWN stream   OutStream 1 with FRAME ZAPAS.
  End.
  if xShowSAle    Then DO:
 if line-counter( OutStream )  > page-size( OutStream ) then DO : display STREAM OutStream    with frame top-frame. end.
  p = p + 1.
  if use-column[28] then c-str-num:screen-value           = '' .
  if use-column[1] then  c-s-bar-code:screen-value        = ''.
  if use-column[2] then  c-gds-zap-artic:screen-value     = ''.
  if use-column[3] then  c-gds-zap-gds-name:screen-value  = ''.
  if use-column[4] then  c-gds-zap-unit-base:screen-value = ''.
  if use-column[5] then  c-gds-type:screen-value          = "док."   .
  if use-column[6]  then C-ostatok-start:screen-value                          = string( Bi-ostatok-start  [8])                         .
  if use-column[7]  then C-oborot-ie:screen-value          = string( Bi-oborot-ie [8]        )  .
  if use-column[8]  then C-oborot-iv:screen-value          = string( Bi-oborot-iv [8]        )  .
  if use-column[9]  then C-oborot-im:screen-value           = string( Bi-oborot-im  [8]        )  .
  if use-column[10] then C-oborot-ee:screen-value          = string( Bi-oborot-ee [8]        )  .
  if use-column[11] then C-oborot-ev:screen-value          = string( Bi-oborot-ev [8]        )  .
  if use-column[12] then C-oborot-em:screen-value           = string( Bi-oborot-em  [8]        )  .
  if use-column[13] then C-oborot-we:screen-value          = string( Bi-oborot-we         [8])  .
  if use-column[14] then C-oborot-es:screen-value     = string( Bi-oborot-es    [8])  .
  if use-column[15] then C-oborot-rs:screen-value = string( Bi-oborot-rs[8])  .
  if use-column[16] then C-oborot-re:screen-value      = string( Bi-oborot-re     [8])  .
  if use-column[17] then C-oborot-ep:screen-value       = string( Bi-oborot-ep      [8])  .
  if use-column[18] then C-oborot-rv:screen-value      = string( Bi-oborot-rv     [8])  .
  if use-column[19] then C-oborot-vt:screen-value                = string( Bi-oborot-vt               [8])  .
  if use-column[20] then C-oborot-ot:screen-value           = string( Bi-oborot-ot          [8])  .
  if use-column[22] then C-ostatok-end:screen-value                            = string( Bi-ostatok-end                           [8])  .
  if use-column[25] then C-oborot-ap:screen-value     = string( Bi-oborot-ap    [8])  .
  if use-column[26] then C-oborot-pc:screen-value     = string( Bi-oborot-pc    [8])  .
  if use-column[27] then C-oborot-r-v:screen-value                      = string( Bi-oborot-ee         [8] +
                                                                                         Bi-oborot-re     [8] +
                                                                                         Bi-oborot-es    [8] +
                                                                                         Bi-oborot-rs[8] ).
  DISPLAY stream  OutStream  with FRAME ZAPAS .  DOWN stream   OutStream 1 with FRAME ZAPAS.
  End.
  if xShowSaleNds Then DO:
 if line-counter( OutStream )  > page-size( OutStream ) then DO : display STREAM OutStream    with frame top-frame. end.
  p = p + 1.
  if use-column[28] then c-str-num:screen-value           = '' .
  if use-column[1] then  c-s-bar-code:screen-value        = ''.
  if use-column[2] then  c-gds-zap-artic:screen-value     = ''.
  if use-column[3] then  c-gds-zap-gds-name:screen-value  = ''.
  if use-column[4] then  c-gds-zap-unit-base:screen-value = ''.
  if use-column[5] then  c-gds-type:screen-value          = "НДС док."   .
  if use-column[6]  then C-ostatok-start:screen-value                          = string( Bi-ostatok-start  [9])                         .
  if use-column[7]  then C-oborot-ie:screen-value          = string( Bi-oborot-ie [9]        )  .
  if use-column[8]  then C-oborot-iv:screen-value          = string( Bi-oborot-iv [9]        )  .
  if use-column[9]  then C-oborot-im:screen-value           = string( Bi-oborot-im  [9]        )  .
  if use-column[10] then C-oborot-ee:screen-value          = string( Bi-oborot-ee [9]        )  .
  if use-column[11] then C-oborot-ev:screen-value          = string( Bi-oborot-ev [9]        )  .
  if use-column[12] then C-oborot-em:screen-value           = string( Bi-oborot-em  [9]        )  .
  if use-column[13] then C-oborot-we:screen-value          = string( Bi-oborot-we         [9])  .
  if use-column[14] then C-oborot-es:screen-value     = string( Bi-oborot-es    [9])  .
  if use-column[15] then C-oborot-rs:screen-value = string( Bi-oborot-rs[9])  .
  if use-column[16] then C-oborot-re:screen-value      = string( Bi-oborot-re     [9])  .
  if use-column[17] then C-oborot-ep:screen-value       = string( Bi-oborot-ep      [9])  .
  if use-column[18] then C-oborot-rv:screen-value      = string( Bi-oborot-rv     [9])  .
  if use-column[19] then C-oborot-vt:screen-value                = string( Bi-oborot-vt               [9])  .
  if use-column[20] then C-oborot-ot:screen-value           = string( Bi-oborot-ot          [9])  .
  if use-column[22] then C-ostatok-end:screen-value                            = string( Bi-ostatok-end                           [9])  .
  if use-column[25] then C-oborot-ap:screen-value     = string( Bi-oborot-ap    [9])  .
  if use-column[26] then C-oborot-pc:screen-value     = string( Bi-oborot-pc    [9])  .
  if use-column[27] then C-oborot-r-v:screen-value                      = string( Bi-oborot-ee         [9] +
                                                                                         Bi-oborot-re     [9] +
                                                                                         Bi-oborot-es    [9] +
                                                                                         Bi-oborot-rs[9] ).
  DISPLAY stream  OutStream  with FRAME ZAPAS .  DOWN stream   OutStream 1 with FRAME ZAPAS.
  End.
  if xShowSaleSlt Then DO:
 if line-counter( OutStream )  > page-size( OutStream ) then DO : display STREAM OutStream    with frame top-frame. end.
  p = p + 1.
  if use-column[28] then c-str-num:screen-value           = '' .
  if use-column[1] then  c-s-bar-code:screen-value        = ''.
  if use-column[2] then  c-gds-zap-artic:screen-value     = ''.
  if use-column[3] then  c-gds-zap-gds-name:screen-value  = ''.
  if use-column[4] then  c-gds-zap-unit-base:screen-value = ''.
  if use-column[5] then  c-gds-type:screen-value          = "НсП док."   .
  if use-column[6]  then C-ostatok-start:screen-value                          = string( Bi-ostatok-start  [10])                         .
  if use-column[7]  then C-oborot-ie:screen-value          = string( Bi-oborot-ie [10]        )  .
  if use-column[8]  then C-oborot-iv:screen-value          = string( Bi-oborot-iv [10]        )  .
  if use-column[9]  then C-oborot-im:screen-value           = string( Bi-oborot-im  [10]        )  .
  if use-column[10] then C-oborot-ee:screen-value          = string( Bi-oborot-ee [10]        )  .
  if use-column[11] then C-oborot-ev:screen-value          = string( Bi-oborot-ev [10]        )  .
  if use-column[12] then C-oborot-em:screen-value           = string( Bi-oborot-em  [10]        )  .
  if use-column[13] then C-oborot-we:screen-value          = string( Bi-oborot-we         [10])  .
  if use-column[14] then C-oborot-es:screen-value     = string( Bi-oborot-es    [10])  .
  if use-column[15] then C-oborot-rs:screen-value = string( Bi-oborot-rs[10])  .
  if use-column[16] then C-oborot-re:screen-value      = string( Bi-oborot-re     [10])  .
  if use-column[17] then C-oborot-ep:screen-value       = string( Bi-oborot-ep      [10])  .
  if use-column[18] then C-oborot-rv:screen-value      = string( Bi-oborot-rv     [10])  .
  if use-column[19] then C-oborot-vt:screen-value                = string( Bi-oborot-vt               [10])  .
  if use-column[20] then C-oborot-ot:screen-value           = string( Bi-oborot-ot          [10])  .
  if use-column[22] then C-ostatok-end:screen-value                            = string( Bi-ostatok-end                           [10])  .
  if use-column[25] then C-oborot-ap:screen-value     = string( Bi-oborot-ap    [10])  .
  if use-column[26] then C-oborot-pc:screen-value     = string( Bi-oborot-pc    [10])  .
  if use-column[27] then C-oborot-r-v:screen-value                      = string( Bi-oborot-ee         [10] +
                                                                                         Bi-oborot-re     [10] +
                                                                                         Bi-oborot-es    [10] +
                                                                                         Bi-oborot-rs[10] ).
  DISPLAY stream  OutStream  with FRAME ZAPAS .  DOWN stream   OutStream 1 with FRAME ZAPAS.
  End.
  if xShowmediator Then DO:
 if line-counter( OutStream )  > page-size( OutStream ) then DO : display STREAM OutStream    with frame top-frame. end.
  p = p + 1.
  if use-column[28] then c-str-num:screen-value           = '' .
  if use-column[1] then  c-s-bar-code:screen-value        = ''.
  if use-column[2] then  c-gds-zap-artic:screen-value     = ''.
  if use-column[3] then  c-gds-zap-gds-name:screen-value  = ''.
  if use-column[4] then  c-gds-zap-unit-base:screen-value = ''.
  if use-column[5] then  c-gds-type:screen-value          = "поср."   .
  if use-column[6]  then C-ostatok-start:screen-value                          = string( Bi-ostatok-start  [4])                         .
  if use-column[7]  then C-oborot-ie:screen-value          = string( Bi-oborot-ie [4]        )  .
  if use-column[8]  then C-oborot-iv:screen-value          = string( Bi-oborot-iv [4]        )  .
  if use-column[9]  then C-oborot-im:screen-value           = string( Bi-oborot-im  [4]        )  .
  if use-column[10] then C-oborot-ee:screen-value          = string( Bi-oborot-ee [4]        )  .
  if use-column[11] then C-oborot-ev:screen-value          = string( Bi-oborot-ev [4]        )  .
  if use-column[12] then C-oborot-em:screen-value           = string( Bi-oborot-em  [4]        )  .
  if use-column[13] then C-oborot-we:screen-value          = string( Bi-oborot-we         [4])  .
  if use-column[14] then C-oborot-es:screen-value     = string( Bi-oborot-es    [4])  .
  if use-column[15] then C-oborot-rs:screen-value = string( Bi-oborot-rs[4])  .
  if use-column[16] then C-oborot-re:screen-value      = string( Bi-oborot-re     [4])  .
  if use-column[17] then C-oborot-ep:screen-value       = string( Bi-oborot-ep      [4])  .
  if use-column[18] then C-oborot-rv:screen-value      = string( Bi-oborot-rv     [4])  .
  if use-column[19] then C-oborot-vt:screen-value                = string( Bi-oborot-vt               [4])  .
  if use-column[20] then C-oborot-ot:screen-value           = string( Bi-oborot-ot          [4])  .
  if use-column[22] then C-ostatok-end:screen-value                            = string( Bi-ostatok-end                           [4])  .
  if use-column[25] then C-oborot-ap:screen-value     = string( Bi-oborot-ap    [4])  .
  if use-column[26] then C-oborot-pc:screen-value     = string( Bi-oborot-pc    [4])  .
  if use-column[27] then C-oborot-r-v:screen-value                      = string( Bi-oborot-ee         [4] +
                                                                                         Bi-oborot-re     [4] +
                                                                                         Bi-oborot-es    [4] +
                                                                                         Bi-oborot-rs[4] ).
  DISPLAY stream  OutStream  with FRAME ZAPAS .  DOWN stream   OutStream 1 with FRAME ZAPAS.
  End.
END PROCEDURE.
PROCEDURE display-Bo  :
 if line-counter( OutStream )  > page-size( OutStream ) then DO : display STREAM OutStream    with frame top-frame. end.
  p = p + 1.
  if use-column[28] then c-str-num:screen-value           = '' .
  if use-column[1] then  c-s-bar-code:screen-value        = ''.
  if use-column[2] then  c-gds-zap-artic:screen-value     = 'ИТОГО ПО'.
  if use-column[3] then  c-gds-zap-gds-name:screen-value  = 'ОБЪЕКТАМ'.
  if use-column[4] then  c-gds-zap-unit-base:screen-value = ''.
  if use-column[5] then  c-gds-type:screen-value          = "кол-во"   .
  if use-column[21] then C-oborot-disc:screen-value  = string( Bo-oborot-disc [1]) .
  if use-column[23] then C-oborot-eff:screen-value  = string( Bo-oborot-eff [1]) .
  if use-column[24] then C-oborot-prc:screen-value  = string( Bo-oborot-prc [1]) .
  if use-column[6]  then C-ostatok-start:screen-value                          = string( Bo-ostatok-start  [1])                         .
  if use-column[7]  then C-oborot-ie:screen-value          = string( Bo-oborot-ie [1]        )  .
  if use-column[8]  then C-oborot-iv:screen-value          = string( Bo-oborot-iv [1]        )  .
  if use-column[9]  then C-oborot-im:screen-value           = string( Bo-oborot-im  [1]        )  .
  if use-column[10] then C-oborot-ee:screen-value          = string( Bo-oborot-ee [1]        )  .
  if use-column[11] then C-oborot-ev:screen-value          = string( Bo-oborot-ev [1]        )  .
  if use-column[12] then C-oborot-em:screen-value           = string( Bo-oborot-em  [1]        )  .
  if use-column[13] then C-oborot-we:screen-value          = string( Bo-oborot-we         [1])  .
  if use-column[14] then C-oborot-es:screen-value     = string( Bo-oborot-es    [1])  .
  if use-column[15] then C-oborot-rs:screen-value = string( Bo-oborot-rs[1])  .
  if use-column[16] then C-oborot-re:screen-value      = string( Bo-oborot-re     [1])  .
  if use-column[17] then C-oborot-ep:screen-value       = string( Bo-oborot-ep      [1])  .
  if use-column[18] then C-oborot-rv:screen-value      = string( Bo-oborot-rv     [1])  .
  if use-column[19] then C-oborot-vt:screen-value                = string( Bo-oborot-vt               [1])  .
  if use-column[20] then C-oborot-ot:screen-value           = string( Bo-oborot-ot          [1])  .
  if use-column[22] then C-ostatok-end:screen-value                            = string( Bo-ostatok-end                           [1])  .
  if use-column[25] then C-oborot-ap:screen-value     = string( Bo-oborot-ap    [1])  .
  if use-column[26] then C-oborot-pc:screen-value     = string( Bo-oborot-pc    [1])  .
  if use-column[27] then C-oborot-r-v:screen-value                      = string( Bo-oborot-ee         [1] +
                                                                                         Bo-oborot-re     [1] +
                                                                                         Bo-oborot-es    [1] +
                                                                                         Bo-oborot-rs[1] ).
  DISPLAY stream  OutStream  with FRAME ZAPAS .  DOWN stream   OutStream 1 with FRAME ZAPAS.
  if x-tog-wt then do :
 if line-counter( OutStream )  > page-size( OutStream ) then DO : display STREAM OutStream    with frame top-frame. end.
  p = p + 1.
  if use-column[28] then c-str-num:screen-value           = '' .
  if use-column[5] then  c-gds-type:screen-value          = "вес"   .
  if use-column[6]  then C-ostatok-start:screen-value                          = string( Bo-ostatok-start  [11])                         .
  if use-column[7]  then C-oborot-ie:screen-value          = string( Bo-oborot-ie [11]        )  .
  if use-column[8]  then C-oborot-iv:screen-value          = string( Bo-oborot-iv [11]        )  .
  if use-column[9]  then C-oborot-im:screen-value           = string( Bo-oborot-im  [11]        )  .
  if use-column[10] then C-oborot-ee:screen-value          = string( Bo-oborot-ee [11]        )  .
  if use-column[11] then C-oborot-ev:screen-value          = string( Bo-oborot-ev [11]        )  .
  if use-column[12] then C-oborot-em:screen-value           = string( Bo-oborot-em  [11]        )  .
  if use-column[13] then C-oborot-we:screen-value          = string( Bo-oborot-we         [11])  .
  if use-column[14] then C-oborot-es:screen-value     = string( Bo-oborot-es    [11])  .
  if use-column[15] then C-oborot-rs:screen-value = string( Bo-oborot-rs[11])  .
  if use-column[16] then C-oborot-re:screen-value      = string( Bo-oborot-re     [11])  .
  if use-column[17] then C-oborot-ep:screen-value       = string( Bo-oborot-ep      [11])  .
  if use-column[18] then C-oborot-rv:screen-value      = string( Bo-oborot-rv     [11])  .
  if use-column[19] then C-oborot-vt:screen-value                = string( Bo-oborot-vt               [11])  .
  if use-column[20] then C-oborot-ot:screen-value           = string( Bo-oborot-ot          [11])  .
  if use-column[22] then C-ostatok-end:screen-value                            = string( Bo-ostatok-end                           [11])  .
  if use-column[25] then C-oborot-ap:screen-value     = string( Bo-oborot-ap    [11])  .
  if use-column[26] then C-oborot-pc:screen-value     = string( Bo-oborot-pc    [11])  .
  if use-column[27] then C-oborot-r-v:screen-value                      = string( Bo-oborot-ee         [11] +
                                                                                         Bo-oborot-re     [11] +
                                                                                         Bo-oborot-es    [11] +
                                                                                         Bo-oborot-rs[11] ).
  DISPLAY stream  OutStream  with FRAME ZAPAS .  DOWN stream   OutStream 1 with FRAME ZAPAS.
  end.
  if x-tog-ms then do :
 if line-counter( OutStream )  > page-size( OutStream ) then DO : display STREAM OutStream    with frame top-frame. end.
  p = p + 1.
  if use-column[28] then c-str-num:screen-value           = '' .
  if use-column[5] then  c-gds-type:screen-value          = "объем"   .
  if use-column[6]  then C-ostatok-start:screen-value                          = string( Bo-ostatok-start  [12])                         .
  if use-column[7]  then C-oborot-ie:screen-value          = string( Bo-oborot-ie [12]        )  .
  if use-column[8]  then C-oborot-iv:screen-value          = string( Bo-oborot-iv [12]        )  .
  if use-column[9]  then C-oborot-im:screen-value           = string( Bo-oborot-im  [12]        )  .
  if use-column[10] then C-oborot-ee:screen-value          = string( Bo-oborot-ee [12]        )  .
  if use-column[11] then C-oborot-ev:screen-value          = string( Bo-oborot-ev [12]        )  .
  if use-column[12] then C-oborot-em:screen-value           = string( Bo-oborot-em  [12]        )  .
  if use-column[13] then C-oborot-we:screen-value          = string( Bo-oborot-we         [12])  .
  if use-column[14] then C-oborot-es:screen-value     = string( Bo-oborot-es    [12])  .
  if use-column[15] then C-oborot-rs:screen-value = string( Bo-oborot-rs[12])  .
  if use-column[16] then C-oborot-re:screen-value      = string( Bo-oborot-re     [12])  .
  if use-column[17] then C-oborot-ep:screen-value       = string( Bo-oborot-ep      [12])  .
  if use-column[18] then C-oborot-rv:screen-value      = string( Bo-oborot-rv     [12])  .
  if use-column[19] then C-oborot-vt:screen-value                = string( Bo-oborot-vt               [12])  .
  if use-column[20] then C-oborot-ot:screen-value           = string( Bo-oborot-ot          [12])  .
  if use-column[22] then C-ostatok-end:screen-value                            = string( Bo-ostatok-end                           [12])  .
  if use-column[25] then C-oborot-ap:screen-value     = string( Bo-oborot-ap    [12])  .
  if use-column[26] then C-oborot-pc:screen-value     = string( Bo-oborot-pc    [12])  .
  if use-column[27] then C-oborot-r-v:screen-value                      = string( Bo-oborot-ee         [12] +
                                                                                         Bo-oborot-re     [12] +
                                                                                         Bo-oborot-es    [12] +
                                                                                         Bo-oborot-rs[12] ).
  DISPLAY stream  OutStream  with FRAME ZAPAS .  DOWN stream   OutStream 1 with FRAME ZAPAS.
  end.
  if xShowCost    Then DO:  run PRICE-VAT in this-procedure ('Bo').  end.
  if xShowCostNDS Then DO:
 if line-counter( OutStream )  > page-size( OutStream ) then DO : display STREAM OutStream    with frame top-frame. end.
  p = p + 1.
  if use-column[28] then c-str-num:screen-value           = '' .
  if use-column[1] then  c-s-bar-code:screen-value        = ''.
  if use-column[2] then  c-gds-zap-artic:screen-value     = ''.
  if use-column[3] then  c-gds-zap-gds-name:screen-value  = ''.
  if use-column[4] then  c-gds-zap-unit-base:screen-value = ''.
  if use-column[5] then  c-gds-type:screen-value          = "НДС учет."   .
  if use-column[6]  then C-ostatok-start:screen-value                          = string( Bo-ostatok-start  [3])                         .
  if use-column[7]  then C-oborot-ie:screen-value          = string( Bo-oborot-ie [3]        )  .
  if use-column[8]  then C-oborot-iv:screen-value          = string( Bo-oborot-iv [3]        )  .
  if use-column[9]  then C-oborot-im:screen-value           = string( Bo-oborot-im  [3]        )  .
  if use-column[10] then C-oborot-ee:screen-value          = string( Bo-oborot-ee [3]        )  .
  if use-column[11] then C-oborot-ev:screen-value          = string( Bo-oborot-ev [3]        )  .
  if use-column[12] then C-oborot-em:screen-value           = string( Bo-oborot-em  [3]        )  .
  if use-column[13] then C-oborot-we:screen-value          = string( Bo-oborot-we         [3])  .
  if use-column[14] then C-oborot-es:screen-value     = string( Bo-oborot-es    [3])  .
  if use-column[15] then C-oborot-rs:screen-value = string( Bo-oborot-rs[3])  .
  if use-column[16] then C-oborot-re:screen-value      = string( Bo-oborot-re     [3])  .
  if use-column[17] then C-oborot-ep:screen-value       = string( Bo-oborot-ep      [3])  .
  if use-column[18] then C-oborot-rv:screen-value      = string( Bo-oborot-rv     [3])  .
  if use-column[19] then C-oborot-vt:screen-value                = string( Bo-oborot-vt               [3])  .
  if use-column[20] then C-oborot-ot:screen-value           = string( Bo-oborot-ot          [3])  .
  if use-column[22] then C-ostatok-end:screen-value                            = string( Bo-ostatok-end                           [3])  .
  if use-column[25] then C-oborot-ap:screen-value     = string( Bo-oborot-ap    [3])  .
  if use-column[26] then C-oborot-pc:screen-value     = string( Bo-oborot-pc    [3])  .
  if use-column[27] then C-oborot-r-v:screen-value                      = string( Bo-oborot-ee         [3] +
                                                                                         Bo-oborot-re     [3] +
                                                                                         Bo-oborot-es    [3] +
                                                                                         Bo-oborot-rs[3] ).
  DISPLAY stream  OutStream  with FRAME ZAPAS .  DOWN stream   OutStream 1 with FRAME ZAPAS.
  End.
  if xShowCrsa    Then DO:
 if line-counter( OutStream )  > page-size( OutStream ) then DO : display STREAM OutStream    with frame top-frame. end.
  p = p + 1.
  if use-column[28] then c-str-num:screen-value           = '' .
  if use-column[1] then  c-s-bar-code:screen-value        = ''.
  if use-column[2] then  c-gds-zap-artic:screen-value     = ''.
  if use-column[3] then  c-gds-zap-gds-name:screen-value  = ''.
  if use-column[4] then  c-gds-zap-unit-base:screen-value = ''.
  if use-column[5] then  c-gds-type:screen-value          = "прод."   .
  if use-column[6]  then C-ostatok-start:screen-value                          = string( Bo-ostatok-start  [5])                         .
  if use-column[7]  then C-oborot-ie:screen-value          = string( Bo-oborot-ie [5]        )  .
  if use-column[8]  then C-oborot-iv:screen-value          = string( Bo-oborot-iv [5]        )  .
  if use-column[9]  then C-oborot-im:screen-value           = string( Bo-oborot-im  [5]        )  .
  if use-column[10] then C-oborot-ee:screen-value          = string( Bo-oborot-ee [5]        )  .
  if use-column[11] then C-oborot-ev:screen-value          = string( Bo-oborot-ev [5]        )  .
  if use-column[12] then C-oborot-em:screen-value           = string( Bo-oborot-em  [5]        )  .
  if use-column[13] then C-oborot-we:screen-value          = string( Bo-oborot-we         [5])  .
  if use-column[14] then C-oborot-es:screen-value     = string( Bo-oborot-es    [5])  .
  if use-column[15] then C-oborot-rs:screen-value = string( Bo-oborot-rs[5])  .
  if use-column[16] then C-oborot-re:screen-value      = string( Bo-oborot-re     [5])  .
  if use-column[17] then C-oborot-ep:screen-value       = string( Bo-oborot-ep      [5])  .
  if use-column[18] then C-oborot-rv:screen-value      = string( Bo-oborot-rv     [5])  .
  if use-column[19] then C-oborot-vt:screen-value                = string( Bo-oborot-vt               [5])  .
  if use-column[20] then C-oborot-ot:screen-value           = string( Bo-oborot-ot          [5])  .
  if use-column[22] then C-ostatok-end:screen-value                            = string( Bo-ostatok-end                           [5])  .
  if use-column[25] then C-oborot-ap:screen-value     = string( Bo-oborot-ap    [5])  .
  if use-column[26] then C-oborot-pc:screen-value     = string( Bo-oborot-pc    [5])  .
  if use-column[27] then C-oborot-r-v:screen-value                      = string( Bo-oborot-ee         [5] +
                                                                                         Bo-oborot-re     [5] +
                                                                                         Bo-oborot-es    [5] +
                                                                                         Bo-oborot-rs[5] ).
  DISPLAY stream  OutStream  with FRAME ZAPAS .  DOWN stream   OutStream 1 with FRAME ZAPAS.
  End.
  if xShowCrsaNds Then DO:
 if line-counter( OutStream )  > page-size( OutStream ) then DO : display STREAM OutStream    with frame top-frame. end.
  p = p + 1.
  if use-column[28] then c-str-num:screen-value           = '' .
  if use-column[1] then  c-s-bar-code:screen-value        = ''.
  if use-column[2] then  c-gds-zap-artic:screen-value     = ''.
  if use-column[3] then  c-gds-zap-gds-name:screen-value  = ''.
  if use-column[4] then  c-gds-zap-unit-base:screen-value = ''.
  if use-column[5] then  c-gds-type:screen-value          = "НДС прод."   .
  if use-column[6]  then C-ostatok-start:screen-value                          = string( Bo-ostatok-start  [6])                         .
  if use-column[7]  then C-oborot-ie:screen-value          = string( Bo-oborot-ie [6]        )  .
  if use-column[8]  then C-oborot-iv:screen-value          = string( Bo-oborot-iv [6]        )  .
  if use-column[9]  then C-oborot-im:screen-value           = string( Bo-oborot-im  [6]        )  .
  if use-column[10] then C-oborot-ee:screen-value          = string( Bo-oborot-ee [6]        )  .
  if use-column[11] then C-oborot-ev:screen-value          = string( Bo-oborot-ev [6]        )  .
  if use-column[12] then C-oborot-em:screen-value           = string( Bo-oborot-em  [6]        )  .
  if use-column[13] then C-oborot-we:screen-value          = string( Bo-oborot-we         [6])  .
  if use-column[14] then C-oborot-es:screen-value     = string( Bo-oborot-es    [6])  .
  if use-column[15] then C-oborot-rs:screen-value = string( Bo-oborot-rs[6])  .
  if use-column[16] then C-oborot-re:screen-value      = string( Bo-oborot-re     [6])  .
  if use-column[17] then C-oborot-ep:screen-value       = string( Bo-oborot-ep      [6])  .
  if use-column[18] then C-oborot-rv:screen-value      = string( Bo-oborot-rv     [6])  .
  if use-column[19] then C-oborot-vt:screen-value                = string( Bo-oborot-vt               [6])  .
  if use-column[20] then C-oborot-ot:screen-value           = string( Bo-oborot-ot          [6])  .
  if use-column[22] then C-ostatok-end:screen-value                            = string( Bo-ostatok-end                           [6])  .
  if use-column[25] then C-oborot-ap:screen-value     = string( Bo-oborot-ap    [6])  .
  if use-column[26] then C-oborot-pc:screen-value     = string( Bo-oborot-pc    [6])  .
  if use-column[27] then C-oborot-r-v:screen-value                      = string( Bo-oborot-ee         [6] +
                                                                                         Bo-oborot-re     [6] +
                                                                                         Bo-oborot-es    [6] +
                                                                                         Bo-oborot-rs[6] ).
  DISPLAY stream  OutStream  with FRAME ZAPAS .  DOWN stream   OutStream 1 with FRAME ZAPAS.
  End.
  if xShowSAle    Then DO:
 if line-counter( OutStream )  > page-size( OutStream ) then DO : display STREAM OutStream    with frame top-frame. end.
  p = p + 1.
  if use-column[28] then c-str-num:screen-value           = '' .
  if use-column[1] then  c-s-bar-code:screen-value        = ''.
  if use-column[2] then  c-gds-zap-artic:screen-value     = ''.
  if use-column[3] then  c-gds-zap-gds-name:screen-value  = ''.
  if use-column[4] then  c-gds-zap-unit-base:screen-value = ''.
  if use-column[5] then  c-gds-type:screen-value          = "док."   .
  if use-column[6]  then C-ostatok-start:screen-value                          = string( Bo-ostatok-start  [8])                         .
  if use-column[7]  then C-oborot-ie:screen-value          = string( Bo-oborot-ie [8]        )  .
  if use-column[8]  then C-oborot-iv:screen-value          = string( Bo-oborot-iv [8]        )  .
  if use-column[9]  then C-oborot-im:screen-value           = string( Bo-oborot-im  [8]        )  .
  if use-column[10] then C-oborot-ee:screen-value          = string( Bo-oborot-ee [8]        )  .
  if use-column[11] then C-oborot-ev:screen-value          = string( Bo-oborot-ev [8]        )  .
  if use-column[12] then C-oborot-em:screen-value           = string( Bo-oborot-em  [8]        )  .
  if use-column[13] then C-oborot-we:screen-value          = string( Bo-oborot-we         [8])  .
  if use-column[14] then C-oborot-es:screen-value     = string( Bo-oborot-es    [8])  .
  if use-column[15] then C-oborot-rs:screen-value = string( Bo-oborot-rs[8])  .
  if use-column[16] then C-oborot-re:screen-value      = string( Bo-oborot-re     [8])  .
  if use-column[17] then C-oborot-ep:screen-value       = string( Bo-oborot-ep      [8])  .
  if use-column[18] then C-oborot-rv:screen-value      = string( Bo-oborot-rv     [8])  .
  if use-column[19] then C-oborot-vt:screen-value                = string( Bo-oborot-vt               [8])  .
  if use-column[20] then C-oborot-ot:screen-value           = string( Bo-oborot-ot          [8])  .
  if use-column[22] then C-ostatok-end:screen-value                            = string( Bo-ostatok-end                           [8])  .
  if use-column[25] then C-oborot-ap:screen-value     = string( Bo-oborot-ap    [8])  .
  if use-column[26] then C-oborot-pc:screen-value     = string( Bo-oborot-pc    [8])  .
  if use-column[27] then C-oborot-r-v:screen-value                      = string( Bo-oborot-ee         [8] +
                                                                                         Bo-oborot-re     [8] +
                                                                                         Bo-oborot-es    [8] +
                                                                                         Bo-oborot-rs[8] ).
  DISPLAY stream  OutStream  with FRAME ZAPAS .  DOWN stream   OutStream 1 with FRAME ZAPAS.
  End.
  if xShowSaleNds Then DO:
 if line-counter( OutStream )  > page-size( OutStream ) then DO : display STREAM OutStream    with frame top-frame. end.
  p = p + 1.
  if use-column[28] then c-str-num:screen-value           = '' .
  if use-column[1] then  c-s-bar-code:screen-value        = ''.
  if use-column[2] then  c-gds-zap-artic:screen-value     = ''.
  if use-column[3] then  c-gds-zap-gds-name:screen-value  = ''.
  if use-column[4] then  c-gds-zap-unit-base:screen-value = ''.
  if use-column[5] then  c-gds-type:screen-value          = "НДС док."   .
  if use-column[6]  then C-ostatok-start:screen-value                          = string( Bo-ostatok-start  [9])                         .
  if use-column[7]  then C-oborot-ie:screen-value          = string( Bo-oborot-ie [9]        )  .
  if use-column[8]  then C-oborot-iv:screen-value          = string( Bo-oborot-iv [9]        )  .
  if use-column[9]  then C-oborot-im:screen-value           = string( Bo-oborot-im  [9]        )  .
  if use-column[10] then C-oborot-ee:screen-value          = string( Bo-oborot-ee [9]        )  .
  if use-column[11] then C-oborot-ev:screen-value          = string( Bo-oborot-ev [9]        )  .
  if use-column[12] then C-oborot-em:screen-value           = string( Bo-oborot-em  [9]        )  .
  if use-column[13] then C-oborot-we:screen-value          = string( Bo-oborot-we         [9])  .
  if use-column[14] then C-oborot-es:screen-value     = string( Bo-oborot-es    [9])  .
  if use-column[15] then C-oborot-rs:screen-value = string( Bo-oborot-rs[9])  .
  if use-column[16] then C-oborot-re:screen-value      = string( Bo-oborot-re     [9])  .
  if use-column[17] then C-oborot-ep:screen-value       = string( Bo-oborot-ep      [9])  .
  if use-column[18] then C-oborot-rv:screen-value      = string( Bo-oborot-rv     [9])  .
  if use-column[19] then C-oborot-vt:screen-value                = string( Bo-oborot-vt               [9])  .
  if use-column[20] then C-oborot-ot:screen-value           = string( Bo-oborot-ot          [9])  .
  if use-column[22] then C-ostatok-end:screen-value                            = string( Bo-ostatok-end                           [9])  .
  if use-column[25] then C-oborot-ap:screen-value     = string( Bo-oborot-ap    [9])  .
  if use-column[26] then C-oborot-pc:screen-value     = string( Bo-oborot-pc    [9])  .
  if use-column[27] then C-oborot-r-v:screen-value                      = string( Bo-oborot-ee         [9] +
                                                                                         Bo-oborot-re     [9] +
                                                                                         Bo-oborot-es    [9] +
                                                                                         Bo-oborot-rs[9] ).
  DISPLAY stream  OutStream  with FRAME ZAPAS .  DOWN stream   OutStream 1 with FRAME ZAPAS.
  End.
  if xShowSaleslt Then DO:
 if line-counter( OutStream )  > page-size( OutStream ) then DO : display STREAM OutStream    with frame top-frame. end.
  p = p + 1.
  if use-column[28] then c-str-num:screen-value           = '' .
  if use-column[1] then  c-s-bar-code:screen-value        = ''.
  if use-column[2] then  c-gds-zap-artic:screen-value     = ''.
  if use-column[3] then  c-gds-zap-gds-name:screen-value  = ''.
  if use-column[4] then  c-gds-zap-unit-base:screen-value = ''.
  if use-column[5] then  c-gds-type:screen-value          = "НсП док."   .
  if use-column[6]  then C-ostatok-start:screen-value                          = string( Bo-ostatok-start  [10])                         .
  if use-column[7]  then C-oborot-ie:screen-value          = string( Bo-oborot-ie [10]        )  .
  if use-column[8]  then C-oborot-iv:screen-value          = string( Bo-oborot-iv [10]        )  .
  if use-column[9]  then C-oborot-im:screen-value           = string( Bo-oborot-im  [10]        )  .
  if use-column[10] then C-oborot-ee:screen-value          = string( Bo-oborot-ee [10]        )  .
  if use-column[11] then C-oborot-ev:screen-value          = string( Bo-oborot-ev [10]        )  .
  if use-column[12] then C-oborot-em:screen-value           = string( Bo-oborot-em  [10]        )  .
  if use-column[13] then C-oborot-we:screen-value          = string( Bo-oborot-we         [10])  .
  if use-column[14] then C-oborot-es:screen-value     = string( Bo-oborot-es    [10])  .
  if use-column[15] then C-oborot-rs:screen-value = string( Bo-oborot-rs[10])  .
  if use-column[16] then C-oborot-re:screen-value      = string( Bo-oborot-re     [10])  .
  if use-column[17] then C-oborot-ep:screen-value       = string( Bo-oborot-ep      [10])  .
  if use-column[18] then C-oborot-rv:screen-value      = string( Bo-oborot-rv     [10])  .
  if use-column[19] then C-oborot-vt:screen-value                = string( Bo-oborot-vt               [10])  .
  if use-column[20] then C-oborot-ot:screen-value           = string( Bo-oborot-ot          [10])  .
  if use-column[22] then C-ostatok-end:screen-value                            = string( Bo-ostatok-end                           [10])  .
  if use-column[25] then C-oborot-ap:screen-value     = string( Bo-oborot-ap    [10])  .
  if use-column[26] then C-oborot-pc:screen-value     = string( Bo-oborot-pc    [10])  .
  if use-column[27] then C-oborot-r-v:screen-value                      = string( Bo-oborot-ee         [10] +
                                                                                         Bo-oborot-re     [10] +
                                                                                         Bo-oborot-es    [10] +
                                                                                         Bo-oborot-rs[10] ).
  DISPLAY stream  OutStream  with FRAME ZAPAS .  DOWN stream   OutStream 1 with FRAME ZAPAS.
  End.
  if xShowmediator Then DO:
 if line-counter( OutStream )  > page-size( OutStream ) then DO : display STREAM OutStream    with frame top-frame. end.
  p = p + 1.
  if use-column[28] then c-str-num:screen-value           = '' .
  if use-column[1] then  c-s-bar-code:screen-value        = ''.
  if use-column[2] then  c-gds-zap-artic:screen-value     = ''.
  if use-column[3] then  c-gds-zap-gds-name:screen-value  = ''.
  if use-column[4] then  c-gds-zap-unit-base:screen-value = ''.
  if use-column[5] then  c-gds-type:screen-value          = "поср."   .
  if use-column[6]  then C-ostatok-start:screen-value                          = string( Bo-ostatok-start  [4])                         .
  if use-column[7]  then C-oborot-ie:screen-value          = string( Bo-oborot-ie [4]        )  .
  if use-column[8]  then C-oborot-iv:screen-value          = string( Bo-oborot-iv [4]        )  .
  if use-column[9]  then C-oborot-im:screen-value           = string( Bo-oborot-im  [4]        )  .
  if use-column[10] then C-oborot-ee:screen-value          = string( Bo-oborot-ee [4]        )  .
  if use-column[11] then C-oborot-ev:screen-value          = string( Bo-oborot-ev [4]        )  .
  if use-column[12] then C-oborot-em:screen-value           = string( Bo-oborot-em  [4]        )  .
  if use-column[13] then C-oborot-we:screen-value          = string( Bo-oborot-we         [4])  .
  if use-column[14] then C-oborot-es:screen-value     = string( Bo-oborot-es    [4])  .
  if use-column[15] then C-oborot-rs:screen-value = string( Bo-oborot-rs[4])  .
  if use-column[16] then C-oborot-re:screen-value      = string( Bo-oborot-re     [4])  .
  if use-column[17] then C-oborot-ep:screen-value       = string( Bo-oborot-ep      [4])  .
  if use-column[18] then C-oborot-rv:screen-value      = string( Bo-oborot-rv     [4])  .
  if use-column[19] then C-oborot-vt:screen-value                = string( Bo-oborot-vt               [4])  .
  if use-column[20] then C-oborot-ot:screen-value           = string( Bo-oborot-ot          [4])  .
  if use-column[22] then C-ostatok-end:screen-value                            = string( Bo-ostatok-end                           [4])  .
  if use-column[25] then C-oborot-ap:screen-value     = string( Bo-oborot-ap    [4])  .
  if use-column[26] then C-oborot-pc:screen-value     = string( Bo-oborot-pc    [4])  .
  if use-column[27] then C-oborot-r-v:screen-value                      = string( Bo-oborot-ee         [4] +
                                                                                         Bo-oborot-re     [4] +
                                                                                         Bo-oborot-es    [4] +
                                                                                         Bo-oborot-rs[4] ).
  DISPLAY stream  OutStream  with FRAME ZAPAS .  DOWN stream   OutStream 1 with FRAME ZAPAS.
  End.
END PROCEDURE.
PROCEDURE display-B1  :
  b1-Null-str# = 1.
  b1-Null-str2# = 1.
  if not show-negativ   then  run b1-null-str-pr   in this-procedure .
  if not show-negativ-2 then  run b1-null-str-pr2  in this-procedure .
   if not     ( not show-negativ   and b1-null-str#  = 0  ) then do :
      if not  ( not show-negativ-2 and b1-null-str2# = 0  ) then do :
              if Sums-Only THEN do:
                  if fr0 = true then do:
                      PUT stream  OutStream  tmp#stroka0 format "X(100)" SKIP.
                      fr0 = false .
                    end.
               end.
 if line-counter( OutStream )  > page-size( OutStream ) then DO : display STREAM OutStream    with frame top-frame. end.
  p = p + 1.
  if use-column[28] then c-str-num:screen-value           = '' .
  if use-column[1] then  c-s-bar-code:screen-value        = s-bar-code.
  if use-column[2] then  c-gds-zap-artic:screen-value     = gds-zap-artic.
  if use-column[3] then  c-gds-zap-gds-name:screen-value  = gds-zap-gds-name.
  if use-column[4] then  c-gds-zap-unit-base:screen-value = ''.
  if use-column[5] then  c-gds-type:screen-value          = "кол-во"   .
  if use-column[21] then C-oborot-disc:screen-value  = string( b1-oborot-disc [1]) .
  if use-column[23] then C-oborot-eff:screen-value  = string( b1-oborot-eff [1]) .
  if use-column[24] then C-oborot-prc:screen-value  = string( b1-oborot-prc [1]) .
  if use-column[6]  then C-ostatok-start:screen-value                          = string( b1-ostatok-start  [1])                         .
  if use-column[7]  then C-oborot-ie:screen-value          = string( b1-oborot-ie [1]        )  .
  if use-column[8]  then C-oborot-iv:screen-value          = string( b1-oborot-iv [1]        )  .
  if use-column[9]  then C-oborot-im:screen-value           = string( b1-oborot-im  [1]        )  .
  if use-column[10] then C-oborot-ee:screen-value          = string( b1-oborot-ee [1]        )  .
  if use-column[11] then C-oborot-ev:screen-value          = string( b1-oborot-ev [1]        )  .
  if use-column[12] then C-oborot-em:screen-value           = string( b1-oborot-em  [1]        )  .
  if use-column[13] then C-oborot-we:screen-value          = string( b1-oborot-we         [1])  .
  if use-column[14] then C-oborot-es:screen-value     = string( b1-oborot-es    [1])  .
  if use-column[15] then C-oborot-rs:screen-value = string( b1-oborot-rs[1])  .
  if use-column[16] then C-oborot-re:screen-value      = string( b1-oborot-re     [1])  .
  if use-column[17] then C-oborot-ep:screen-value       = string( b1-oborot-ep      [1])  .
  if use-column[18] then C-oborot-rv:screen-value      = string( b1-oborot-rv     [1])  .
  if use-column[19] then C-oborot-vt:screen-value                = string( b1-oborot-vt               [1])  .
  if use-column[20] then C-oborot-ot:screen-value           = string( b1-oborot-ot          [1])  .
  if use-column[22] then C-ostatok-end:screen-value                            = string( b1-ostatok-end                           [1])  .
  if use-column[25] then C-oborot-ap:screen-value     = string( b1-oborot-ap    [1])  .
  if use-column[26] then C-oborot-pc:screen-value     = string( b1-oborot-pc    [1])  .
  if use-column[27] then C-oborot-r-v:screen-value                      = string( b1-oborot-ee         [1] +
                                                                                         b1-oborot-re     [1] +
                                                                                         b1-oborot-es    [1] +
                                                                                         b1-oborot-rs[1] ).
  DISPLAY stream  OutStream  with FRAME ZAPAS .  DOWN stream   OutStream 1 with FRAME ZAPAS.
        assign
            sf1:screen-value = ""
            sf2:screen-value = ""
            no-error .
          if x-tog-wt then do :
 if line-counter( OutStream )  > page-size( OutStream ) then DO : display STREAM OutStream    with frame top-frame. end.
  p = p + 1.
  if use-column[28] then c-str-num:screen-value           = '' .
  if use-column[5] then  c-gds-type:screen-value          = "вес"   .
  if use-column[6]  then C-ostatok-start:screen-value                          = string( B1-ostatok-start  [11])                         .
  if use-column[7]  then C-oborot-ie:screen-value          = string( B1-oborot-ie [11]        )  .
  if use-column[8]  then C-oborot-iv:screen-value          = string( B1-oborot-iv [11]        )  .
  if use-column[9]  then C-oborot-im:screen-value           = string( B1-oborot-im  [11]        )  .
  if use-column[10] then C-oborot-ee:screen-value          = string( B1-oborot-ee [11]        )  .
  if use-column[11] then C-oborot-ev:screen-value          = string( B1-oborot-ev [11]        )  .
  if use-column[12] then C-oborot-em:screen-value           = string( B1-oborot-em  [11]        )  .
  if use-column[13] then C-oborot-we:screen-value          = string( B1-oborot-we         [11])  .
  if use-column[14] then C-oborot-es:screen-value     = string( B1-oborot-es    [11])  .
  if use-column[15] then C-oborot-rs:screen-value = string( B1-oborot-rs[11])  .
  if use-column[16] then C-oborot-re:screen-value      = string( B1-oborot-re     [11])  .
  if use-column[17] then C-oborot-ep:screen-value       = string( B1-oborot-ep      [11])  .
  if use-column[18] then C-oborot-rv:screen-value      = string( B1-oborot-rv     [11])  .
  if use-column[19] then C-oborot-vt:screen-value                = string( B1-oborot-vt               [11])  .
  if use-column[20] then C-oborot-ot:screen-value           = string( B1-oborot-ot          [11])  .
  if use-column[22] then C-ostatok-end:screen-value                            = string( B1-ostatok-end                           [11])  .
  if use-column[25] then C-oborot-ap:screen-value     = string( B1-oborot-ap    [11])  .
  if use-column[26] then C-oborot-pc:screen-value     = string( B1-oborot-pc    [11])  .
  if use-column[27] then C-oborot-r-v:screen-value                      = string( B1-oborot-ee         [11] +
                                                                                         B1-oborot-re     [11] +
                                                                                         B1-oborot-es    [11] +
                                                                                         B1-oborot-rs[11] ).
  DISPLAY stream  OutStream  with FRAME ZAPAS .  DOWN stream   OutStream 1 with FRAME ZAPAS.
  end.
          if x-tog-ms then do :
 if line-counter( OutStream )  > page-size( OutStream ) then DO : display STREAM OutStream    with frame top-frame. end.
  p = p + 1.
  if use-column[28] then c-str-num:screen-value           = '' .
  if use-column[5] then  c-gds-type:screen-value          = "объем"   .
  if use-column[6]  then C-ostatok-start:screen-value                          = string( B1-ostatok-start  [12])                         .
  if use-column[7]  then C-oborot-ie:screen-value          = string( B1-oborot-ie [12]        )  .
  if use-column[8]  then C-oborot-iv:screen-value          = string( B1-oborot-iv [12]        )  .
  if use-column[9]  then C-oborot-im:screen-value           = string( B1-oborot-im  [12]        )  .
  if use-column[10] then C-oborot-ee:screen-value          = string( B1-oborot-ee [12]        )  .
  if use-column[11] then C-oborot-ev:screen-value          = string( B1-oborot-ev [12]        )  .
  if use-column[12] then C-oborot-em:screen-value           = string( B1-oborot-em  [12]        )  .
  if use-column[13] then C-oborot-we:screen-value          = string( B1-oborot-we         [12])  .
  if use-column[14] then C-oborot-es:screen-value     = string( B1-oborot-es    [12])  .
  if use-column[15] then C-oborot-rs:screen-value = string( B1-oborot-rs[12])  .
  if use-column[16] then C-oborot-re:screen-value      = string( B1-oborot-re     [12])  .
  if use-column[17] then C-oborot-ep:screen-value       = string( B1-oborot-ep      [12])  .
  if use-column[18] then C-oborot-rv:screen-value      = string( B1-oborot-rv     [12])  .
  if use-column[19] then C-oborot-vt:screen-value                = string( B1-oborot-vt               [12])  .
  if use-column[20] then C-oborot-ot:screen-value           = string( B1-oborot-ot          [12])  .
  if use-column[22] then C-ostatok-end:screen-value                            = string( B1-ostatok-end                           [12])  .
  if use-column[25] then C-oborot-ap:screen-value     = string( B1-oborot-ap    [12])  .
  if use-column[26] then C-oborot-pc:screen-value     = string( B1-oborot-pc    [12])  .
  if use-column[27] then C-oborot-r-v:screen-value                      = string( B1-oborot-ee         [12] +
                                                                                         B1-oborot-re     [12] +
                                                                                         B1-oborot-es    [12] +
                                                                                         B1-oborot-rs[12] ).
  DISPLAY stream  OutStream  with FRAME ZAPAS .  DOWN stream   OutStream 1 with FRAME ZAPAS.
  end.
          if xShowCost     Then  DO:  run PRICE-VAT in this-procedure ('B1').                 End.
          if xShowCostNDS  Then  DO:
 if line-counter( OutStream )  > page-size( OutStream ) then DO : display STREAM OutStream    with frame top-frame. end.
  p = p + 1.
  if use-column[28] then c-str-num:screen-value           = '' .
  if use-column[1] then  c-s-bar-code:screen-value        = ''.
  if use-column[2] then  c-gds-zap-artic:screen-value     = ''.
  if use-column[3] then  c-gds-zap-gds-name:screen-value  = ''.
  if use-column[4] then  c-gds-zap-unit-base:screen-value = ''.
  if use-column[5] then  c-gds-type:screen-value          = "НДС учет."   .
  if use-column[6]  then C-ostatok-start:screen-value                          = string( B1-ostatok-start  [3])                         .
  if use-column[7]  then C-oborot-ie:screen-value          = string( B1-oborot-ie [3]        )  .
  if use-column[8]  then C-oborot-iv:screen-value          = string( B1-oborot-iv [3]        )  .
  if use-column[9]  then C-oborot-im:screen-value           = string( B1-oborot-im  [3]        )  .
  if use-column[10] then C-oborot-ee:screen-value          = string( B1-oborot-ee [3]        )  .
  if use-column[11] then C-oborot-ev:screen-value          = string( B1-oborot-ev [3]        )  .
  if use-column[12] then C-oborot-em:screen-value           = string( B1-oborot-em  [3]        )  .
  if use-column[13] then C-oborot-we:screen-value          = string( B1-oborot-we         [3])  .
  if use-column[14] then C-oborot-es:screen-value     = string( B1-oborot-es    [3])  .
  if use-column[15] then C-oborot-rs:screen-value = string( B1-oborot-rs[3])  .
  if use-column[16] then C-oborot-re:screen-value      = string( B1-oborot-re     [3])  .
  if use-column[17] then C-oborot-ep:screen-value       = string( B1-oborot-ep      [3])  .
  if use-column[18] then C-oborot-rv:screen-value      = string( B1-oborot-rv     [3])  .
  if use-column[19] then C-oborot-vt:screen-value                = string( B1-oborot-vt               [3])  .
  if use-column[20] then C-oborot-ot:screen-value           = string( B1-oborot-ot          [3])  .
  if use-column[22] then C-ostatok-end:screen-value                            = string( B1-ostatok-end                           [3])  .
  if use-column[25] then C-oborot-ap:screen-value     = string( B1-oborot-ap    [3])  .
  if use-column[26] then C-oborot-pc:screen-value     = string( B1-oborot-pc    [3])  .
  if use-column[27] then C-oborot-r-v:screen-value                      = string( B1-oborot-ee         [3] +
                                                                                         B1-oborot-re     [3] +
                                                                                         B1-oborot-es    [3] +
                                                                                         B1-oborot-rs[3] ).
  DISPLAY stream  OutStream  with FRAME ZAPAS .  DOWN stream   OutStream 1 with FRAME ZAPAS.
  End.
          if xShowCrsa     Then  DO:
 if line-counter( OutStream )  > page-size( OutStream ) then DO : display STREAM OutStream    with frame top-frame. end.
  p = p + 1.
  if use-column[28] then c-str-num:screen-value           = '' .
  if use-column[1] then  c-s-bar-code:screen-value        = ''.
  if use-column[2] then  c-gds-zap-artic:screen-value     = ''.
  if use-column[3] then  c-gds-zap-gds-name:screen-value  = ''.
  if use-column[4] then  c-gds-zap-unit-base:screen-value = ''.
  if use-column[5] then  c-gds-type:screen-value          = "прод."   .
  if use-column[6]  then C-ostatok-start:screen-value                          = string( B1-ostatok-start  [5])                         .
  if use-column[7]  then C-oborot-ie:screen-value          = string( B1-oborot-ie [5]        )  .
  if use-column[8]  then C-oborot-iv:screen-value          = string( B1-oborot-iv [5]        )  .
  if use-column[9]  then C-oborot-im:screen-value           = string( B1-oborot-im  [5]        )  .
  if use-column[10] then C-oborot-ee:screen-value          = string( B1-oborot-ee [5]        )  .
  if use-column[11] then C-oborot-ev:screen-value          = string( B1-oborot-ev [5]        )  .
  if use-column[12] then C-oborot-em:screen-value           = string( B1-oborot-em  [5]        )  .
  if use-column[13] then C-oborot-we:screen-value          = string( B1-oborot-we         [5])  .
  if use-column[14] then C-oborot-es:screen-value     = string( B1-oborot-es    [5])  .
  if use-column[15] then C-oborot-rs:screen-value = string( B1-oborot-rs[5])  .
  if use-column[16] then C-oborot-re:screen-value      = string( B1-oborot-re     [5])  .
  if use-column[17] then C-oborot-ep:screen-value       = string( B1-oborot-ep      [5])  .
  if use-column[18] then C-oborot-rv:screen-value      = string( B1-oborot-rv     [5])  .
  if use-column[19] then C-oborot-vt:screen-value                = string( B1-oborot-vt               [5])  .
  if use-column[20] then C-oborot-ot:screen-value           = string( B1-oborot-ot          [5])  .
  if use-column[22] then C-ostatok-end:screen-value                            = string( B1-ostatok-end                           [5])  .
  if use-column[25] then C-oborot-ap:screen-value     = string( B1-oborot-ap    [5])  .
  if use-column[26] then C-oborot-pc:screen-value     = string( B1-oborot-pc    [5])  .
  if use-column[27] then C-oborot-r-v:screen-value                      = string( B1-oborot-ee         [5] +
                                                                                         B1-oborot-re     [5] +
                                                                                         B1-oborot-es    [5] +
                                                                                         B1-oborot-rs[5] ).
  DISPLAY stream  OutStream  with FRAME ZAPAS .  DOWN stream   OutStream 1 with FRAME ZAPAS.
  End.
          if xShowCrsaNds  Then  DO:
 if line-counter( OutStream )  > page-size( OutStream ) then DO : display STREAM OutStream    with frame top-frame. end.
  p = p + 1.
  if use-column[28] then c-str-num:screen-value           = '' .
  if use-column[1] then  c-s-bar-code:screen-value        = ''.
  if use-column[2] then  c-gds-zap-artic:screen-value     = ''.
  if use-column[3] then  c-gds-zap-gds-name:screen-value  = ''.
  if use-column[4] then  c-gds-zap-unit-base:screen-value = ''.
  if use-column[5] then  c-gds-type:screen-value          = "НДС прод."   .
  if use-column[6]  then C-ostatok-start:screen-value                          = string( B1-ostatok-start  [6])                         .
  if use-column[7]  then C-oborot-ie:screen-value          = string( B1-oborot-ie [6]        )  .
  if use-column[8]  then C-oborot-iv:screen-value          = string( B1-oborot-iv [6]        )  .
  if use-column[9]  then C-oborot-im:screen-value           = string( B1-oborot-im  [6]        )  .
  if use-column[10] then C-oborot-ee:screen-value          = string( B1-oborot-ee [6]        )  .
  if use-column[11] then C-oborot-ev:screen-value          = string( B1-oborot-ev [6]        )  .
  if use-column[12] then C-oborot-em:screen-value           = string( B1-oborot-em  [6]        )  .
  if use-column[13] then C-oborot-we:screen-value          = string( B1-oborot-we         [6])  .
  if use-column[14] then C-oborot-es:screen-value     = string( B1-oborot-es    [6])  .
  if use-column[15] then C-oborot-rs:screen-value = string( B1-oborot-rs[6])  .
  if use-column[16] then C-oborot-re:screen-value      = string( B1-oborot-re     [6])  .
  if use-column[17] then C-oborot-ep:screen-value       = string( B1-oborot-ep      [6])  .
  if use-column[18] then C-oborot-rv:screen-value      = string( B1-oborot-rv     [6])  .
  if use-column[19] then C-oborot-vt:screen-value                = string( B1-oborot-vt               [6])  .
  if use-column[20] then C-oborot-ot:screen-value           = string( B1-oborot-ot          [6])  .
  if use-column[22] then C-ostatok-end:screen-value                            = string( B1-ostatok-end                           [6])  .
  if use-column[25] then C-oborot-ap:screen-value     = string( B1-oborot-ap    [6])  .
  if use-column[26] then C-oborot-pc:screen-value     = string( B1-oborot-pc    [6])  .
  if use-column[27] then C-oborot-r-v:screen-value                      = string( B1-oborot-ee         [6] +
                                                                                         B1-oborot-re     [6] +
                                                                                         B1-oborot-es    [6] +
                                                                                         B1-oborot-rs[6] ).
  DISPLAY stream  OutStream  with FRAME ZAPAS .  DOWN stream   OutStream 1 with FRAME ZAPAS.
  End.
          if xShowSAle     Then  DO:
 if line-counter( OutStream )  > page-size( OutStream ) then DO : display STREAM OutStream    with frame top-frame. end.
  p = p + 1.
  if use-column[28] then c-str-num:screen-value           = '' .
  if use-column[1] then  c-s-bar-code:screen-value        = ''.
  if use-column[2] then  c-gds-zap-artic:screen-value     = ''.
  if use-column[3] then  c-gds-zap-gds-name:screen-value  = ''.
  if use-column[4] then  c-gds-zap-unit-base:screen-value = ''.
  if use-column[5] then  c-gds-type:screen-value          = "док."   .
  if use-column[6]  then C-ostatok-start:screen-value                          = string( B1-ostatok-start  [8])                         .
  if use-column[7]  then C-oborot-ie:screen-value          = string( B1-oborot-ie [8]        )  .
  if use-column[8]  then C-oborot-iv:screen-value          = string( B1-oborot-iv [8]        )  .
  if use-column[9]  then C-oborot-im:screen-value           = string( B1-oborot-im  [8]        )  .
  if use-column[10] then C-oborot-ee:screen-value          = string( B1-oborot-ee [8]        )  .
  if use-column[11] then C-oborot-ev:screen-value          = string( B1-oborot-ev [8]        )  .
  if use-column[12] then C-oborot-em:screen-value           = string( B1-oborot-em  [8]        )  .
  if use-column[13] then C-oborot-we:screen-value          = string( B1-oborot-we         [8])  .
  if use-column[14] then C-oborot-es:screen-value     = string( B1-oborot-es    [8])  .
  if use-column[15] then C-oborot-rs:screen-value = string( B1-oborot-rs[8])  .
  if use-column[16] then C-oborot-re:screen-value      = string( B1-oborot-re     [8])  .
  if use-column[17] then C-oborot-ep:screen-value       = string( B1-oborot-ep      [8])  .
  if use-column[18] then C-oborot-rv:screen-value      = string( B1-oborot-rv     [8])  .
  if use-column[19] then C-oborot-vt:screen-value                = string( B1-oborot-vt               [8])  .
  if use-column[20] then C-oborot-ot:screen-value           = string( B1-oborot-ot          [8])  .
  if use-column[22] then C-ostatok-end:screen-value                            = string( B1-ostatok-end                           [8])  .
  if use-column[25] then C-oborot-ap:screen-value     = string( B1-oborot-ap    [8])  .
  if use-column[26] then C-oborot-pc:screen-value     = string( B1-oborot-pc    [8])  .
  if use-column[27] then C-oborot-r-v:screen-value                      = string( B1-oborot-ee         [8] +
                                                                                         B1-oborot-re     [8] +
                                                                                         B1-oborot-es    [8] +
                                                                                         B1-oborot-rs[8] ).
  DISPLAY stream  OutStream  with FRAME ZAPAS .  DOWN stream   OutStream 1 with FRAME ZAPAS.
  End.
          if xShowSaleNds  Then  DO:
 if line-counter( OutStream )  > page-size( OutStream ) then DO : display STREAM OutStream    with frame top-frame. end.
  p = p + 1.
  if use-column[28] then c-str-num:screen-value           = '' .
  if use-column[1] then  c-s-bar-code:screen-value        = ''.
  if use-column[2] then  c-gds-zap-artic:screen-value     = ''.
  if use-column[3] then  c-gds-zap-gds-name:screen-value  = ''.
  if use-column[4] then  c-gds-zap-unit-base:screen-value = ''.
  if use-column[5] then  c-gds-type:screen-value          = "НДС док."   .
  if use-column[6]  then C-ostatok-start:screen-value                          = string( B1-ostatok-start  [9])                         .
  if use-column[7]  then C-oborot-ie:screen-value          = string( B1-oborot-ie [9]        )  .
  if use-column[8]  then C-oborot-iv:screen-value          = string( B1-oborot-iv [9]        )  .
  if use-column[9]  then C-oborot-im:screen-value           = string( B1-oborot-im  [9]        )  .
  if use-column[10] then C-oborot-ee:screen-value          = string( B1-oborot-ee [9]        )  .
  if use-column[11] then C-oborot-ev:screen-value          = string( B1-oborot-ev [9]        )  .
  if use-column[12] then C-oborot-em:screen-value           = string( B1-oborot-em  [9]        )  .
  if use-column[13] then C-oborot-we:screen-value          = string( B1-oborot-we         [9])  .
  if use-column[14] then C-oborot-es:screen-value     = string( B1-oborot-es    [9])  .
  if use-column[15] then C-oborot-rs:screen-value = string( B1-oborot-rs[9])  .
  if use-column[16] then C-oborot-re:screen-value      = string( B1-oborot-re     [9])  .
  if use-column[17] then C-oborot-ep:screen-value       = string( B1-oborot-ep      [9])  .
  if use-column[18] then C-oborot-rv:screen-value      = string( B1-oborot-rv     [9])  .
  if use-column[19] then C-oborot-vt:screen-value                = string( B1-oborot-vt               [9])  .
  if use-column[20] then C-oborot-ot:screen-value           = string( B1-oborot-ot          [9])  .
  if use-column[22] then C-ostatok-end:screen-value                            = string( B1-ostatok-end                           [9])  .
  if use-column[25] then C-oborot-ap:screen-value     = string( B1-oborot-ap    [9])  .
  if use-column[26] then C-oborot-pc:screen-value     = string( B1-oborot-pc    [9])  .
  if use-column[27] then C-oborot-r-v:screen-value                      = string( B1-oborot-ee         [9] +
                                                                                         B1-oborot-re     [9] +
                                                                                         B1-oborot-es    [9] +
                                                                                         B1-oborot-rs[9] ).
  DISPLAY stream  OutStream  with FRAME ZAPAS .  DOWN stream   OutStream 1 with FRAME ZAPAS.
  End.
          if xShowSaleSlt  Then  DO:
 if line-counter( OutStream )  > page-size( OutStream ) then DO : display STREAM OutStream    with frame top-frame. end.
  p = p + 1.
  if use-column[28] then c-str-num:screen-value           = '' .
  if use-column[1] then  c-s-bar-code:screen-value        = ''.
  if use-column[2] then  c-gds-zap-artic:screen-value     = ''.
  if use-column[3] then  c-gds-zap-gds-name:screen-value  = ''.
  if use-column[4] then  c-gds-zap-unit-base:screen-value = ''.
  if use-column[5] then  c-gds-type:screen-value          = "НсП док."   .
  if use-column[6]  then C-ostatok-start:screen-value                          = string( B1-ostatok-start  [10])                         .
  if use-column[7]  then C-oborot-ie:screen-value          = string( B1-oborot-ie [10]        )  .
  if use-column[8]  then C-oborot-iv:screen-value          = string( B1-oborot-iv [10]        )  .
  if use-column[9]  then C-oborot-im:screen-value           = string( B1-oborot-im  [10]        )  .
  if use-column[10] then C-oborot-ee:screen-value          = string( B1-oborot-ee [10]        )  .
  if use-column[11] then C-oborot-ev:screen-value          = string( B1-oborot-ev [10]        )  .
  if use-column[12] then C-oborot-em:screen-value           = string( B1-oborot-em  [10]        )  .
  if use-column[13] then C-oborot-we:screen-value          = string( B1-oborot-we         [10])  .
  if use-column[14] then C-oborot-es:screen-value     = string( B1-oborot-es    [10])  .
  if use-column[15] then C-oborot-rs:screen-value = string( B1-oborot-rs[10])  .
  if use-column[16] then C-oborot-re:screen-value      = string( B1-oborot-re     [10])  .
  if use-column[17] then C-oborot-ep:screen-value       = string( B1-oborot-ep      [10])  .
  if use-column[18] then C-oborot-rv:screen-value      = string( B1-oborot-rv     [10])  .
  if use-column[19] then C-oborot-vt:screen-value                = string( B1-oborot-vt               [10])  .
  if use-column[20] then C-oborot-ot:screen-value           = string( B1-oborot-ot          [10])  .
  if use-column[22] then C-ostatok-end:screen-value                            = string( B1-ostatok-end                           [10])  .
  if use-column[25] then C-oborot-ap:screen-value     = string( B1-oborot-ap    [10])  .
  if use-column[26] then C-oborot-pc:screen-value     = string( B1-oborot-pc    [10])  .
  if use-column[27] then C-oborot-r-v:screen-value                      = string( B1-oborot-ee         [10] +
                                                                                         B1-oborot-re     [10] +
                                                                                         B1-oborot-es    [10] +
                                                                                         B1-oborot-rs[10] ).
  DISPLAY stream  OutStream  with FRAME ZAPAS .  DOWN stream   OutStream 1 with FRAME ZAPAS.
  End.
          if xShowmediator Then  DO:
 if line-counter( OutStream )  > page-size( OutStream ) then DO : display STREAM OutStream    with frame top-frame. end.
  p = p + 1.
  if use-column[28] then c-str-num:screen-value           = '' .
  if use-column[1] then  c-s-bar-code:screen-value        = ''.
  if use-column[2] then  c-gds-zap-artic:screen-value     = ''.
  if use-column[3] then  c-gds-zap-gds-name:screen-value  = ''.
  if use-column[4] then  c-gds-zap-unit-base:screen-value = ''.
  if use-column[5] then  c-gds-type:screen-value          = "поср."   .
  if use-column[6]  then C-ostatok-start:screen-value                          = string( B1-ostatok-start  [4])                         .
  if use-column[7]  then C-oborot-ie:screen-value          = string( B1-oborot-ie [4]        )  .
  if use-column[8]  then C-oborot-iv:screen-value          = string( B1-oborot-iv [4]        )  .
  if use-column[9]  then C-oborot-im:screen-value           = string( B1-oborot-im  [4]        )  .
  if use-column[10] then C-oborot-ee:screen-value          = string( B1-oborot-ee [4]        )  .
  if use-column[11] then C-oborot-ev:screen-value          = string( B1-oborot-ev [4]        )  .
  if use-column[12] then C-oborot-em:screen-value           = string( B1-oborot-em  [4]        )  .
  if use-column[13] then C-oborot-we:screen-value          = string( B1-oborot-we         [4])  .
  if use-column[14] then C-oborot-es:screen-value     = string( B1-oborot-es    [4])  .
  if use-column[15] then C-oborot-rs:screen-value = string( B1-oborot-rs[4])  .
  if use-column[16] then C-oborot-re:screen-value      = string( B1-oborot-re     [4])  .
  if use-column[17] then C-oborot-ep:screen-value       = string( B1-oborot-ep      [4])  .
  if use-column[18] then C-oborot-rv:screen-value      = string( B1-oborot-rv     [4])  .
  if use-column[19] then C-oborot-vt:screen-value                = string( B1-oborot-vt               [4])  .
  if use-column[20] then C-oborot-ot:screen-value           = string( B1-oborot-ot          [4])  .
  if use-column[22] then C-ostatok-end:screen-value                            = string( B1-ostatok-end                           [4])  .
  if use-column[25] then C-oborot-ap:screen-value     = string( B1-oborot-ap    [4])  .
  if use-column[26] then C-oborot-pc:screen-value     = string( B1-oborot-pc    [4])  .
  if use-column[27] then C-oborot-r-v:screen-value                      = string( B1-oborot-ee         [4] +
                                                                                         B1-oborot-re     [4] +
                                                                                         B1-oborot-es    [4] +
                                                                                         B1-oborot-rs[4] ).
  DISPLAY stream  OutStream  with FRAME ZAPAS .  DOWN stream   OutStream 1 with FRAME ZAPAS.
  End.
      end.
   end.
END PROCEDURE.
PROCEDURE display-B2  :
  b2-Null-str#  = 1 .
  b2-Null-str2# = 1 .
  if not show-negativ   then  run b2-null-str-pr   in this-procedure .
  if not show-negativ-2 then  run b2-null-str-pr2  in this-procedure .
   if not  (not show-negativ   and b2-null-str#  = 0  ) then do :
      if not  (not show-negativ-2 and b2-null-str2# = 0  ) then do :
 if line-counter( OutStream )  > page-size( OutStream ) then DO : display STREAM OutStream    with frame top-frame. end.
  p = p + 1.
  if use-column[28] then c-str-num:screen-value           = '' .
  if use-column[1] then  c-s-bar-code:screen-value        = s-bar-code.
  if use-column[2] then  c-gds-zap-artic:screen-value     = gds-zap-artic.
  if use-column[3] then  c-gds-zap-gds-name:screen-value  = gds-zap-gds-name.
  if use-column[4] then  c-gds-zap-unit-base:screen-value = ''.
  if use-column[5] then  c-gds-type:screen-value          = "кол-во"   .
  if use-column[21] then C-oborot-disc:screen-value  = string( b1-oborot-disc [1]) .
  if use-column[23] then C-oborot-eff:screen-value  = string( b1-oborot-eff [1]) .
  if use-column[24] then C-oborot-prc:screen-value  = string( b1-oborot-prc [1]) .
  if use-column[6]  then C-ostatok-start:screen-value                          = string( b1-ostatok-start  [1])                         .
  if use-column[7]  then C-oborot-ie:screen-value          = string( b1-oborot-ie [1]        )  .
  if use-column[8]  then C-oborot-iv:screen-value          = string( b1-oborot-iv [1]        )  .
  if use-column[9]  then C-oborot-im:screen-value           = string( b1-oborot-im  [1]        )  .
  if use-column[10] then C-oborot-ee:screen-value          = string( b1-oborot-ee [1]        )  .
  if use-column[11] then C-oborot-ev:screen-value          = string( b1-oborot-ev [1]        )  .
  if use-column[12] then C-oborot-em:screen-value           = string( b1-oborot-em  [1]        )  .
  if use-column[13] then C-oborot-we:screen-value          = string( b1-oborot-we         [1])  .
  if use-column[14] then C-oborot-es:screen-value     = string( b1-oborot-es    [1])  .
  if use-column[15] then C-oborot-rs:screen-value = string( b1-oborot-rs[1])  .
  if use-column[16] then C-oborot-re:screen-value      = string( b1-oborot-re     [1])  .
  if use-column[17] then C-oborot-ep:screen-value       = string( b1-oborot-ep      [1])  .
  if use-column[18] then C-oborot-rv:screen-value      = string( b1-oborot-rv     [1])  .
  if use-column[19] then C-oborot-vt:screen-value                = string( b1-oborot-vt               [1])  .
  if use-column[20] then C-oborot-ot:screen-value           = string( b1-oborot-ot          [1])  .
  if use-column[22] then C-ostatok-end:screen-value                            = string( b1-ostatok-end                           [1])  .
  if use-column[25] then C-oborot-ap:screen-value     = string( b1-oborot-ap    [1])  .
  if use-column[26] then C-oborot-pc:screen-value     = string( b1-oborot-pc    [1])  .
  if use-column[27] then C-oborot-r-v:screen-value                      = string( b1-oborot-ee         [1] +
                                                                                         b1-oborot-re     [1] +
                                                                                         b1-oborot-es    [1] +
                                                                                         b1-oborot-rs[1] ).
  DISPLAY stream  OutStream  with FRAME ZAPAS .  DOWN stream   OutStream 1 with FRAME ZAPAS.
        if x-tog-wt then do :
 if line-counter( OutStream )  > page-size( OutStream ) then DO : display STREAM OutStream    with frame top-frame. end.
  p = p + 1.
  if use-column[28] then c-str-num:screen-value           = '' .
  if use-column[5] then  c-gds-type:screen-value          = "вес"   .
  if use-column[6]  then C-ostatok-start:screen-value                          = string( B2-ostatok-start  [11])                         .
  if use-column[7]  then C-oborot-ie:screen-value          = string( B2-oborot-ie [11]        )  .
  if use-column[8]  then C-oborot-iv:screen-value          = string( B2-oborot-iv [11]        )  .
  if use-column[9]  then C-oborot-im:screen-value           = string( B2-oborot-im  [11]        )  .
  if use-column[10] then C-oborot-ee:screen-value          = string( B2-oborot-ee [11]        )  .
  if use-column[11] then C-oborot-ev:screen-value          = string( B2-oborot-ev [11]        )  .
  if use-column[12] then C-oborot-em:screen-value           = string( B2-oborot-em  [11]        )  .
  if use-column[13] then C-oborot-we:screen-value          = string( B2-oborot-we         [11])  .
  if use-column[14] then C-oborot-es:screen-value     = string( B2-oborot-es    [11])  .
  if use-column[15] then C-oborot-rs:screen-value = string( B2-oborot-rs[11])  .
  if use-column[16] then C-oborot-re:screen-value      = string( B2-oborot-re     [11])  .
  if use-column[17] then C-oborot-ep:screen-value       = string( B2-oborot-ep      [11])  .
  if use-column[18] then C-oborot-rv:screen-value      = string( B2-oborot-rv     [11])  .
  if use-column[19] then C-oborot-vt:screen-value                = string( B2-oborot-vt               [11])  .
  if use-column[20] then C-oborot-ot:screen-value           = string( B2-oborot-ot          [11])  .
  if use-column[22] then C-ostatok-end:screen-value                            = string( B2-ostatok-end                           [11])  .
  if use-column[25] then C-oborot-ap:screen-value     = string( B2-oborot-ap    [11])  .
  if use-column[26] then C-oborot-pc:screen-value     = string( B2-oborot-pc    [11])  .
  if use-column[27] then C-oborot-r-v:screen-value                      = string( B2-oborot-ee         [11] +
                                                                                         B2-oborot-re     [11] +
                                                                                         B2-oborot-es    [11] +
                                                                                         B2-oborot-rs[11] ).
  DISPLAY stream  OutStream  with FRAME ZAPAS .  DOWN stream   OutStream 1 with FRAME ZAPAS.
  end.
        if x-tog-ms then do :
 if line-counter( OutStream )  > page-size( OutStream ) then DO : display STREAM OutStream    with frame top-frame. end.
  p = p + 1.
  if use-column[28] then c-str-num:screen-value           = '' .
  if use-column[5] then  c-gds-type:screen-value          = "объем"   .
  if use-column[6]  then C-ostatok-start:screen-value                          = string( B2-ostatok-start  [12])                         .
  if use-column[7]  then C-oborot-ie:screen-value          = string( B2-oborot-ie [12]        )  .
  if use-column[8]  then C-oborot-iv:screen-value          = string( B2-oborot-iv [12]        )  .
  if use-column[9]  then C-oborot-im:screen-value           = string( B2-oborot-im  [12]        )  .
  if use-column[10] then C-oborot-ee:screen-value          = string( B2-oborot-ee [12]        )  .
  if use-column[11] then C-oborot-ev:screen-value          = string( B2-oborot-ev [12]        )  .
  if use-column[12] then C-oborot-em:screen-value           = string( B2-oborot-em  [12]        )  .
  if use-column[13] then C-oborot-we:screen-value          = string( B2-oborot-we         [12])  .
  if use-column[14] then C-oborot-es:screen-value     = string( B2-oborot-es    [12])  .
  if use-column[15] then C-oborot-rs:screen-value = string( B2-oborot-rs[12])  .
  if use-column[16] then C-oborot-re:screen-value      = string( B2-oborot-re     [12])  .
  if use-column[17] then C-oborot-ep:screen-value       = string( B2-oborot-ep      [12])  .
  if use-column[18] then C-oborot-rv:screen-value      = string( B2-oborot-rv     [12])  .
  if use-column[19] then C-oborot-vt:screen-value                = string( B2-oborot-vt               [12])  .
  if use-column[20] then C-oborot-ot:screen-value           = string( B2-oborot-ot          [12])  .
  if use-column[22] then C-ostatok-end:screen-value                            = string( B2-ostatok-end                           [12])  .
  if use-column[25] then C-oborot-ap:screen-value     = string( B2-oborot-ap    [12])  .
  if use-column[26] then C-oborot-pc:screen-value     = string( B2-oborot-pc    [12])  .
  if use-column[27] then C-oborot-r-v:screen-value                      = string( B2-oborot-ee         [12] +
                                                                                         B2-oborot-re     [12] +
                                                                                         B2-oborot-es    [12] +
                                                                                         B2-oborot-rs[12] ).
  DISPLAY stream  OutStream  with FRAME ZAPAS .  DOWN stream   OutStream 1 with FRAME ZAPAS.
  end.
        if xShowCost    Then DO:  run PRICE-VAT in this-procedure ('B2').  end.
        if xShowCostNDS Then DO:
 if line-counter( OutStream )  > page-size( OutStream ) then DO : display STREAM OutStream    with frame top-frame. end.
  p = p + 1.
  if use-column[28] then c-str-num:screen-value           = '' .
  if use-column[1] then  c-s-bar-code:screen-value        = ''.
  if use-column[2] then  c-gds-zap-artic:screen-value     = ''.
  if use-column[3] then  c-gds-zap-gds-name:screen-value  = ''.
  if use-column[4] then  c-gds-zap-unit-base:screen-value = ''.
  if use-column[5] then  c-gds-type:screen-value          = "НДС учет."   .
  if use-column[6]  then C-ostatok-start:screen-value                          = string( B2-ostatok-start  [3])                         .
  if use-column[7]  then C-oborot-ie:screen-value          = string( B2-oborot-ie [3]        )  .
  if use-column[8]  then C-oborot-iv:screen-value          = string( B2-oborot-iv [3]        )  .
  if use-column[9]  then C-oborot-im:screen-value           = string( B2-oborot-im  [3]        )  .
  if use-column[10] then C-oborot-ee:screen-value          = string( B2-oborot-ee [3]        )  .
  if use-column[11] then C-oborot-ev:screen-value          = string( B2-oborot-ev [3]        )  .
  if use-column[12] then C-oborot-em:screen-value           = string( B2-oborot-em  [3]        )  .
  if use-column[13] then C-oborot-we:screen-value          = string( B2-oborot-we         [3])  .
  if use-column[14] then C-oborot-es:screen-value     = string( B2-oborot-es    [3])  .
  if use-column[15] then C-oborot-rs:screen-value = string( B2-oborot-rs[3])  .
  if use-column[16] then C-oborot-re:screen-value      = string( B2-oborot-re     [3])  .
  if use-column[17] then C-oborot-ep:screen-value       = string( B2-oborot-ep      [3])  .
  if use-column[18] then C-oborot-rv:screen-value      = string( B2-oborot-rv     [3])  .
  if use-column[19] then C-oborot-vt:screen-value                = string( B2-oborot-vt               [3])  .
  if use-column[20] then C-oborot-ot:screen-value           = string( B2-oborot-ot          [3])  .
  if use-column[22] then C-ostatok-end:screen-value                            = string( B2-ostatok-end                           [3])  .
  if use-column[25] then C-oborot-ap:screen-value     = string( B2-oborot-ap    [3])  .
  if use-column[26] then C-oborot-pc:screen-value     = string( B2-oborot-pc    [3])  .
  if use-column[27] then C-oborot-r-v:screen-value                      = string( B2-oborot-ee         [3] +
                                                                                         B2-oborot-re     [3] +
                                                                                         B2-oborot-es    [3] +
                                                                                         B2-oborot-rs[3] ).
  DISPLAY stream  OutStream  with FRAME ZAPAS .  DOWN stream   OutStream 1 with FRAME ZAPAS.
  End.
        if xShowCrsa    Then DO:
 if line-counter( OutStream )  > page-size( OutStream ) then DO : display STREAM OutStream    with frame top-frame. end.
  p = p + 1.
  if use-column[28] then c-str-num:screen-value           = '' .
  if use-column[1] then  c-s-bar-code:screen-value        = ''.
  if use-column[2] then  c-gds-zap-artic:screen-value     = ''.
  if use-column[3] then  c-gds-zap-gds-name:screen-value  = ''.
  if use-column[4] then  c-gds-zap-unit-base:screen-value = ''.
  if use-column[5] then  c-gds-type:screen-value          = "прод."   .
  if use-column[6]  then C-ostatok-start:screen-value                          = string( B2-ostatok-start  [5])                         .
  if use-column[7]  then C-oborot-ie:screen-value          = string( B2-oborot-ie [5]        )  .
  if use-column[8]  then C-oborot-iv:screen-value          = string( B2-oborot-iv [5]        )  .
  if use-column[9]  then C-oborot-im:screen-value           = string( B2-oborot-im  [5]        )  .
  if use-column[10] then C-oborot-ee:screen-value          = string( B2-oborot-ee [5]        )  .
  if use-column[11] then C-oborot-ev:screen-value          = string( B2-oborot-ev [5]        )  .
  if use-column[12] then C-oborot-em:screen-value           = string( B2-oborot-em  [5]        )  .
  if use-column[13] then C-oborot-we:screen-value          = string( B2-oborot-we         [5])  .
  if use-column[14] then C-oborot-es:screen-value     = string( B2-oborot-es    [5])  .
  if use-column[15] then C-oborot-rs:screen-value = string( B2-oborot-rs[5])  .
  if use-column[16] then C-oborot-re:screen-value      = string( B2-oborot-re     [5])  .
  if use-column[17] then C-oborot-ep:screen-value       = string( B2-oborot-ep      [5])  .
  if use-column[18] then C-oborot-rv:screen-value      = string( B2-oborot-rv     [5])  .
  if use-column[19] then C-oborot-vt:screen-value                = string( B2-oborot-vt               [5])  .
  if use-column[20] then C-oborot-ot:screen-value           = string( B2-oborot-ot          [5])  .
  if use-column[22] then C-ostatok-end:screen-value                            = string( B2-ostatok-end                           [5])  .
  if use-column[25] then C-oborot-ap:screen-value     = string( B2-oborot-ap    [5])  .
  if use-column[26] then C-oborot-pc:screen-value     = string( B2-oborot-pc    [5])  .
  if use-column[27] then C-oborot-r-v:screen-value                      = string( B2-oborot-ee         [5] +
                                                                                         B2-oborot-re     [5] +
                                                                                         B2-oborot-es    [5] +
                                                                                         B2-oborot-rs[5] ).
  DISPLAY stream  OutStream  with FRAME ZAPAS .  DOWN stream   OutStream 1 with FRAME ZAPAS.
   End.
        if xShowCrsaNds Then DO:
 if line-counter( OutStream )  > page-size( OutStream ) then DO : display STREAM OutStream    with frame top-frame. end.
  p = p + 1.
  if use-column[28] then c-str-num:screen-value           = '' .
  if use-column[1] then  c-s-bar-code:screen-value        = ''.
  if use-column[2] then  c-gds-zap-artic:screen-value     = ''.
  if use-column[3] then  c-gds-zap-gds-name:screen-value  = ''.
  if use-column[4] then  c-gds-zap-unit-base:screen-value = ''.
  if use-column[5] then  c-gds-type:screen-value          = "НДС прод."   .
  if use-column[6]  then C-ostatok-start:screen-value                          = string( B2-ostatok-start  [6])                         .
  if use-column[7]  then C-oborot-ie:screen-value          = string( B2-oborot-ie [6]        )  .
  if use-column[8]  then C-oborot-iv:screen-value          = string( B2-oborot-iv [6]        )  .
  if use-column[9]  then C-oborot-im:screen-value           = string( B2-oborot-im  [6]        )  .
  if use-column[10] then C-oborot-ee:screen-value          = string( B2-oborot-ee [6]        )  .
  if use-column[11] then C-oborot-ev:screen-value          = string( B2-oborot-ev [6]        )  .
  if use-column[12] then C-oborot-em:screen-value           = string( B2-oborot-em  [6]        )  .
  if use-column[13] then C-oborot-we:screen-value          = string( B2-oborot-we         [6])  .
  if use-column[14] then C-oborot-es:screen-value     = string( B2-oborot-es    [6])  .
  if use-column[15] then C-oborot-rs:screen-value = string( B2-oborot-rs[6])  .
  if use-column[16] then C-oborot-re:screen-value      = string( B2-oborot-re     [6])  .
  if use-column[17] then C-oborot-ep:screen-value       = string( B2-oborot-ep      [6])  .
  if use-column[18] then C-oborot-rv:screen-value      = string( B2-oborot-rv     [6])  .
  if use-column[19] then C-oborot-vt:screen-value                = string( B2-oborot-vt               [6])  .
  if use-column[20] then C-oborot-ot:screen-value           = string( B2-oborot-ot          [6])  .
  if use-column[22] then C-ostatok-end:screen-value                            = string( B2-ostatok-end                           [6])  .
  if use-column[25] then C-oborot-ap:screen-value     = string( B2-oborot-ap    [6])  .
  if use-column[26] then C-oborot-pc:screen-value     = string( B2-oborot-pc    [6])  .
  if use-column[27] then C-oborot-r-v:screen-value                      = string( B2-oborot-ee         [6] +
                                                                                         B2-oborot-re     [6] +
                                                                                         B2-oborot-es    [6] +
                                                                                         B2-oborot-rs[6] ).
  DISPLAY stream  OutStream  with FRAME ZAPAS .  DOWN stream   OutStream 1 with FRAME ZAPAS.
  End.
        if xShowSAle    Then DO:
 if line-counter( OutStream )  > page-size( OutStream ) then DO : display STREAM OutStream    with frame top-frame. end.
  p = p + 1.
  if use-column[28] then c-str-num:screen-value           = '' .
  if use-column[1] then  c-s-bar-code:screen-value        = ''.
  if use-column[2] then  c-gds-zap-artic:screen-value     = ''.
  if use-column[3] then  c-gds-zap-gds-name:screen-value  = ''.
  if use-column[4] then  c-gds-zap-unit-base:screen-value = ''.
  if use-column[5] then  c-gds-type:screen-value          = "док."   .
  if use-column[6]  then C-ostatok-start:screen-value                          = string( B2-ostatok-start  [8])                         .
  if use-column[7]  then C-oborot-ie:screen-value          = string( B2-oborot-ie [8]        )  .
  if use-column[8]  then C-oborot-iv:screen-value          = string( B2-oborot-iv [8]        )  .
  if use-column[9]  then C-oborot-im:screen-value           = string( B2-oborot-im  [8]        )  .
  if use-column[10] then C-oborot-ee:screen-value          = string( B2-oborot-ee [8]        )  .
  if use-column[11] then C-oborot-ev:screen-value          = string( B2-oborot-ev [8]        )  .
  if use-column[12] then C-oborot-em:screen-value           = string( B2-oborot-em  [8]        )  .
  if use-column[13] then C-oborot-we:screen-value          = string( B2-oborot-we         [8])  .
  if use-column[14] then C-oborot-es:screen-value     = string( B2-oborot-es    [8])  .
  if use-column[15] then C-oborot-rs:screen-value = string( B2-oborot-rs[8])  .
  if use-column[16] then C-oborot-re:screen-value      = string( B2-oborot-re     [8])  .
  if use-column[17] then C-oborot-ep:screen-value       = string( B2-oborot-ep      [8])  .
  if use-column[18] then C-oborot-rv:screen-value      = string( B2-oborot-rv     [8])  .
  if use-column[19] then C-oborot-vt:screen-value                = string( B2-oborot-vt               [8])  .
  if use-column[20] then C-oborot-ot:screen-value           = string( B2-oborot-ot          [8])  .
  if use-column[22] then C-ostatok-end:screen-value                            = string( B2-ostatok-end                           [8])  .
  if use-column[25] then C-oborot-ap:screen-value     = string( B2-oborot-ap    [8])  .
  if use-column[26] then C-oborot-pc:screen-value     = string( B2-oborot-pc    [8])  .
  if use-column[27] then C-oborot-r-v:screen-value                      = string( B2-oborot-ee         [8] +
                                                                                         B2-oborot-re     [8] +
                                                                                         B2-oborot-es    [8] +
                                                                                         B2-oborot-rs[8] ).
  DISPLAY stream  OutStream  with FRAME ZAPAS .  DOWN stream   OutStream 1 with FRAME ZAPAS.
   End.
        if xShowSaleNds Then DO:
 if line-counter( OutStream )  > page-size( OutStream ) then DO : display STREAM OutStream    with frame top-frame. end.
  p = p + 1.
  if use-column[28] then c-str-num:screen-value           = '' .
  if use-column[1] then  c-s-bar-code:screen-value        = ''.
  if use-column[2] then  c-gds-zap-artic:screen-value     = ''.
  if use-column[3] then  c-gds-zap-gds-name:screen-value  = ''.
  if use-column[4] then  c-gds-zap-unit-base:screen-value = ''.
  if use-column[5] then  c-gds-type:screen-value          = "НДС док."   .
  if use-column[6]  then C-ostatok-start:screen-value                          = string( B2-ostatok-start  [9])                         .
  if use-column[7]  then C-oborot-ie:screen-value          = string( B2-oborot-ie [9]        )  .
  if use-column[8]  then C-oborot-iv:screen-value          = string( B2-oborot-iv [9]        )  .
  if use-column[9]  then C-oborot-im:screen-value           = string( B2-oborot-im  [9]        )  .
  if use-column[10] then C-oborot-ee:screen-value          = string( B2-oborot-ee [9]        )  .
  if use-column[11] then C-oborot-ev:screen-value          = string( B2-oborot-ev [9]        )  .
  if use-column[12] then C-oborot-em:screen-value           = string( B2-oborot-em  [9]        )  .
  if use-column[13] then C-oborot-we:screen-value          = string( B2-oborot-we         [9])  .
  if use-column[14] then C-oborot-es:screen-value     = string( B2-oborot-es    [9])  .
  if use-column[15] then C-oborot-rs:screen-value = string( B2-oborot-rs[9])  .
  if use-column[16] then C-oborot-re:screen-value      = string( B2-oborot-re     [9])  .
  if use-column[17] then C-oborot-ep:screen-value       = string( B2-oborot-ep      [9])  .
  if use-column[18] then C-oborot-rv:screen-value      = string( B2-oborot-rv     [9])  .
  if use-column[19] then C-oborot-vt:screen-value                = string( B2-oborot-vt               [9])  .
  if use-column[20] then C-oborot-ot:screen-value           = string( B2-oborot-ot          [9])  .
  if use-column[22] then C-ostatok-end:screen-value                            = string( B2-ostatok-end                           [9])  .
  if use-column[25] then C-oborot-ap:screen-value     = string( B2-oborot-ap    [9])  .
  if use-column[26] then C-oborot-pc:screen-value     = string( B2-oborot-pc    [9])  .
  if use-column[27] then C-oborot-r-v:screen-value                      = string( B2-oborot-ee         [9] +
                                                                                         B2-oborot-re     [9] +
                                                                                         B2-oborot-es    [9] +
                                                                                         B2-oborot-rs[9] ).
  DISPLAY stream  OutStream  with FRAME ZAPAS .  DOWN stream   OutStream 1 with FRAME ZAPAS.
  End.
        if xShowSaleslt Then DO:
 if line-counter( OutStream )  > page-size( OutStream ) then DO : display STREAM OutStream    with frame top-frame. end.
  p = p + 1.
  if use-column[28] then c-str-num:screen-value           = '' .
  if use-column[1] then  c-s-bar-code:screen-value        = ''.
  if use-column[2] then  c-gds-zap-artic:screen-value     = ''.
  if use-column[3] then  c-gds-zap-gds-name:screen-value  = ''.
  if use-column[4] then  c-gds-zap-unit-base:screen-value = ''.
  if use-column[5] then  c-gds-type:screen-value          = "НсП док."   .
  if use-column[6]  then C-ostatok-start:screen-value                          = string( B2-ostatok-start  [10])                         .
  if use-column[7]  then C-oborot-ie:screen-value          = string( B2-oborot-ie [10]        )  .
  if use-column[8]  then C-oborot-iv:screen-value          = string( B2-oborot-iv [10]        )  .
  if use-column[9]  then C-oborot-im:screen-value           = string( B2-oborot-im  [10]        )  .
  if use-column[10] then C-oborot-ee:screen-value          = string( B2-oborot-ee [10]        )  .
  if use-column[11] then C-oborot-ev:screen-value          = string( B2-oborot-ev [10]        )  .
  if use-column[12] then C-oborot-em:screen-value           = string( B2-oborot-em  [10]        )  .
  if use-column[13] then C-oborot-we:screen-value          = string( B2-oborot-we         [10])  .
  if use-column[14] then C-oborot-es:screen-value     = string( B2-oborot-es    [10])  .
  if use-column[15] then C-oborot-rs:screen-value = string( B2-oborot-rs[10])  .
  if use-column[16] then C-oborot-re:screen-value      = string( B2-oborot-re     [10])  .
  if use-column[17] then C-oborot-ep:screen-value       = string( B2-oborot-ep      [10])  .
  if use-column[18] then C-oborot-rv:screen-value      = string( B2-oborot-rv     [10])  .
  if use-column[19] then C-oborot-vt:screen-value                = string( B2-oborot-vt               [10])  .
  if use-column[20] then C-oborot-ot:screen-value           = string( B2-oborot-ot          [10])  .
  if use-column[22] then C-ostatok-end:screen-value                            = string( B2-ostatok-end                           [10])  .
  if use-column[25] then C-oborot-ap:screen-value     = string( B2-oborot-ap    [10])  .
  if use-column[26] then C-oborot-pc:screen-value     = string( B2-oborot-pc    [10])  .
  if use-column[27] then C-oborot-r-v:screen-value                      = string( B2-oborot-ee         [10] +
                                                                                         B2-oborot-re     [10] +
                                                                                         B2-oborot-es    [10] +
                                                                                         B2-oborot-rs[10] ).
  DISPLAY stream  OutStream  with FRAME ZAPAS .  DOWN stream   OutStream 1 with FRAME ZAPAS.
  End.
        if xShowmediator Then DO:
 if line-counter( OutStream )  > page-size( OutStream ) then DO : display STREAM OutStream    with frame top-frame. end.
  p = p + 1.
  if use-column[28] then c-str-num:screen-value           = '' .
  if use-column[1] then  c-s-bar-code:screen-value        = ''.
  if use-column[2] then  c-gds-zap-artic:screen-value     = ''.
  if use-column[3] then  c-gds-zap-gds-name:screen-value  = ''.
  if use-column[4] then  c-gds-zap-unit-base:screen-value = ''.
  if use-column[5] then  c-gds-type:screen-value          = "поср."   .
  if use-column[6]  then C-ostatok-start:screen-value                          = string( B2-ostatok-start  [4])                         .
  if use-column[7]  then C-oborot-ie:screen-value          = string( B2-oborot-ie [4]        )  .
  if use-column[8]  then C-oborot-iv:screen-value          = string( B2-oborot-iv [4]        )  .
  if use-column[9]  then C-oborot-im:screen-value           = string( B2-oborot-im  [4]        )  .
  if use-column[10] then C-oborot-ee:screen-value          = string( B2-oborot-ee [4]        )  .
  if use-column[11] then C-oborot-ev:screen-value          = string( B2-oborot-ev [4]        )  .
  if use-column[12] then C-oborot-em:screen-value           = string( B2-oborot-em  [4]        )  .
  if use-column[13] then C-oborot-we:screen-value          = string( B2-oborot-we         [4])  .
  if use-column[14] then C-oborot-es:screen-value     = string( B2-oborot-es    [4])  .
  if use-column[15] then C-oborot-rs:screen-value = string( B2-oborot-rs[4])  .
  if use-column[16] then C-oborot-re:screen-value      = string( B2-oborot-re     [4])  .
  if use-column[17] then C-oborot-ep:screen-value       = string( B2-oborot-ep      [4])  .
  if use-column[18] then C-oborot-rv:screen-value      = string( B2-oborot-rv     [4])  .
  if use-column[19] then C-oborot-vt:screen-value                = string( B2-oborot-vt               [4])  .
  if use-column[20] then C-oborot-ot:screen-value           = string( B2-oborot-ot          [4])  .
  if use-column[22] then C-ostatok-end:screen-value                            = string( B2-ostatok-end                           [4])  .
  if use-column[25] then C-oborot-ap:screen-value     = string( B2-oborot-ap    [4])  .
  if use-column[26] then C-oborot-pc:screen-value     = string( B2-oborot-pc    [4])  .
  if use-column[27] then C-oborot-r-v:screen-value                      = string( B2-oborot-ee         [4] +
                                                                                         B2-oborot-re     [4] +
                                                                                         B2-oborot-es    [4] +
                                                                                         B2-oborot-rs[4] ).
  DISPLAY stream  OutStream  with FRAME ZAPAS .  DOWN stream   OutStream 1 with FRAME ZAPAS.
  End.
  if NOT xSumsOnly THEN Run u-line  in this-procedure .
end.
end.
END PROCEDURE.
PROCEDURE Clear-B1  :
repeat kk = 1 to 12 :
assign
B1-oborot-ie         [kk] = 0
B1-oborot-ee         [kk] = 0
B1-oborot-ep      [kk] = 0
B1-oborot-es    [kk] = 0
B1-oborot-re     [kk] = 0
B1-oborot-rs [kk] = 0
B1-oborot-we         [kk] = 0
B1-oborot-vt               [kk] = 0
B1-oborot-iv         [kk] = 0
B1-oborot-ev         [kk] = 0
B1-oborot-rv     [kk] = 0
B1-oborot-em          [kk] = 0
B1-oborot-wm          [kk] = 0
B1-oborot-im          [kk] = 0
B1-oborot-ot          [kk] = 0
B1-oborot-disc                    [kk] = 0
B1-oborot-eff                     [kk] = 0
B1-oborot-prc                     [kk] = 0
B1-ostatok-end                           [kk] = 0
B1-ostatok-start                         [kk] = 0
B1-oborot-sum-sale                       [kk] = 0
B1-oborot-sum-cost                       [kk] = 0
B1-oborot-ap [kk] = 0
B1-oborot-pc [kk] = 0
.
end.
END PROCEDURE.
PROCEDURE Clear-B2  :
repeat kk = 1 to 12 :
assign
B2-oborot-ie         [kk] = 0
B2-oborot-ee         [kk] = 0
B2-oborot-ep      [kk] = 0
B2-oborot-es    [kk] = 0
B2-oborot-re     [kk] = 0
B2-oborot-rs [kk] = 0
B2-oborot-we         [kk] = 0
B2-oborot-vt               [kk] = 0
B2-oborot-iv         [kk] = 0
B2-oborot-ev         [kk] = 0
B2-oborot-rv     [kk] = 0
B2-oborot-em          [kk] = 0
B2-oborot-wm          [kk] = 0
B2-oborot-im          [kk] = 0
B2-oborot-ot          [kk] = 0
B2-oborot-disc                    [kk] = 0
B2-oborot-eff                     [kk] = 0
B2-oborot-prc                     [kk] = 0
B2-ostatok-end                           [kk] = 0
B2-ostatok-start                         [kk] = 0
B2-oborot-sum-sale                       [kk] = 0
B2-oborot-sum-cost                       [kk] = 0
B2-oborot-ap [kk] = 0
B2-oborot-pc [kk] = 0
.
end.
END PROCEDURE.
PROCEDURE Clear-Bi  :
repeat kk = 1 to 12 :
assign
Bi-oborot-ie         [kk] = 0
Bi-oborot-ee         [kk] = 0
Bi-oborot-ep      [kk] = 0
Bi-oborot-es    [kk] = 0
Bi-oborot-re     [kk] = 0
Bi-oborot-rs [kk] = 0
Bi-oborot-we         [kk] = 0
Bi-oborot-vt               [kk] = 0
Bi-oborot-iv         [kk] = 0
Bi-oborot-ev         [kk] = 0
Bi-oborot-rv     [kk] = 0
Bi-oborot-em          [kk] = 0
Bi-oborot-wm          [kk] = 0
Bi-oborot-im          [kk] = 0
Bi-oborot-ot          [kk] = 0
Bi-oborot-disc                    [kk] = 0
Bi-oborot-eff                     [kk] = 0
Bi-oborot-prc                     [kk] = 0
Bi-ostatok-end                           [kk] = 0
Bi-ostatok-start                         [kk] = 0
Bi-oborot-sum-sale                       [kk] = 0
Bi-oborot-sum-cost                       [kk] = 0
Bi-oborot-ap [kk] = 0
Bi-oborot-pc [kk] = 0
.
end.
END PROCEDURE.
PROCEDURE Display-title :
   PUT stream  OutStream  UNFORMATTED  string( v-cntxt-host-name-obj +  " , " + x-store-type  +  " " + ObjName) AT 50 format "X(85)" SKIP(2)
          REPORTNAME  AT 1 format "X(133)" SKIP
          Trim(str1)  AT 35 format "X(75)" SKIP.
     Repeat i = 1 to NUM-ENTRIES(str2,chr(10)) :
      PUT stream  OutStream  UNFORMATTED  Entry(i,str2,chr(10))  AT 1 format "X(130)" SKIP.
     End.
    i=0.
     Repeat i = 1 to NUM-ENTRIES(str3,chr(10)) :
      PUT stream  OutStream  UNFORMATTED  Entry(i,str3,chr(10))  AT 1 format "X(130)" SKIP.
     End.
    i=0.
     Repeat i = 1 to NUM-ENTRIES(str4,chr(10)) :
      PUT stream  OutStream  UNFORMATTED  Entry(i,str4,chr(10))  AT 1 format "X(130)" SKIP.
     End.
    i=0.
     Repeat i = 1 to NUM-ENTRIES(ReportHeader,chr(10)) :
      PUT stream  OutStream  UNFORMATTED  Entry(i,ReportHeader,chr(10))  AT 1 format "X(130)" SKIP.
     End.
    i=0.
END PROCEDURE.
PROCEDURE ob-line  :
define input  parameter x-store-code     like ub.clients.obj-code     no-undo.
define input  parameter x-store-type     like ub.clients.obj-type     no-undo.
define input  parameter x-artic          like ub.ot-line.artic        no-undo.
define input  parameter x-prod-code      like ub.ot-line.prod-code    no-undo.
define input  parameter x-prod-type      like ub.ot-line.prod-type    no-undo.
define input  parameter x-fact-order-1   like ub.ot-line.fact-order   no-undo.
define input  parameter x-fact-order-2   like ub.ot-line.fact-order   no-undo.
define input  parameter x-sum-type       like ub.ot-line.sum-type     no-undo.
define input  parameter x-cat-id         like ub.ot-line.cat-id       no-undo.
define input  parameter x-ext-doc-type   like ub.ot-line.ext-doc-type no-undo.
define input  parameter xtog-obj           as log no-undo.
define variable  quantity#    like ub.ot-line.fact-qnty   no-undo.
define variable  coast_r#     like ub.ot-line.sum-rubl    no-undo.
define variable  coast_v#     like ub.ot-line.sum-rubl    no-undo.
define variable  vat_r#       like ub.ot-line.sum-rubl    no-undo.
define variable  vat_v#       like ub.ot-line.sum-rubl    no-undo.
define variable  slt_r#       like ub.ot-line.sum-rubl    no-undo.
define variable  slt_v#       like ub.ot-line.sum-rubl    no-undo.
define variable  v-summa  as decimal extent 4 no-undo .
define variable  tt#          as int no-undo.
define variable v-ii as integer no-undo .
define variable slt  as decimal no-undo .
define variable disc  as decimal no-undo .
define variable xi as integer no-undo .
define variable v-tt as integer no-undo .
 if (x-sum-type = 'cost':U  or x-sum-type = 'cssr':U) then assign tt# = 0 v-tt = 0.
    else
    if (x-sum-type = 'crsa':U  or x-sum-type = 'cgsr':U) then assign tt# = 3  v-tt = 100.
    else
    assign tt# = 6  v-tt = 200.
  if long-p = false then do :
  for each obj-list no-lock:
   if  xtog-obj then
       if   not(x-store-type     = obj-list.obj-type
            and x-store-code    = obj-list.obj-code ) then next.
        for each ub.ot-line where
                  ub.ot-line.artic         = x-artic
            and   ub.ot-line.prod-code    = x-prod-code
            and   ub.ot-line.prod-type    = x-prod-type
            and   ub.ot-line.fact-order   <= x-fact-order-2
            and   ub.ot-line.fact-order   >= x-fact-order-1
            and   ub.ot-line.obj-code     = obj-list.obj-code
            and   ub.ot-line.obj-type     = obj-list.obj-type
            and   ub.ot-line.sum-type     = x-sum-type
            no-lock :
            case ub.ot-line.ext-doc-type:
  WHEN 'ie':U THEN DO:
    ASSIGN oborot-ie[1 + tt#]   = oborot-ie[1 + tt#]   +  ub.ot-line.fact-qnty
          oborot-ie[2 + tt#]   = oborot-ie[2 + tt#]   +  if tprintrubl then ub.ot-line.sum-rubl else ub.ot-line.sum-base
          oborot-ie[3 + tt#]   = oborot-ie[3 + tt#]   +  if tprintrubl then ub.ot-line.vat-rubl else ub.ot-line.vat-base  .
      if tt# = 6 Then   assign
          oborot-disc[1]   = oborot-disc[1]   +  if tprintrubl then ub.ot-line.other-rubl else ub.ot-line.other-base
          oborot-ie[10]   = oborot-ie[10]   +  if tprintrubl then ub.ot-line.slt-rubl else ub.ot-line.slt-base  .
          End.
  WHEN 'ee':U THEN DO:
    ASSIGN oborot-ee[1 + tt#]   = oborot-ee[1 + tt#]   +  ub.ot-line.fact-qnty
          oborot-ee[2 + tt#]   = oborot-ee[2 + tt#]   +  if tprintrubl then ub.ot-line.sum-rubl else ub.ot-line.sum-base
          oborot-ee[3 + tt#]   = oborot-ee[3 + tt#]   +  if tprintrubl then ub.ot-line.vat-rubl else ub.ot-line.vat-base  .
      if tt# = 6 Then   assign
          oborot-disc[1]   = oborot-disc[1]   +  if tprintrubl then ub.ot-line.other-rubl else ub.ot-line.other-base
          oborot-ee[10]   = oborot-ee[10]   +  if tprintrubl then ub.ot-line.slt-rubl else ub.ot-line.slt-base  .
          End.
  WHEN 'ep':U THEN DO:
    ASSIGN oborot-ep[1 + tt#]   = oborot-ep[1 + tt#]   +  ub.ot-line.fact-qnty
          oborot-ep[2 + tt#]   = oborot-ep[2 + tt#]   +  if tprintrubl then ub.ot-line.sum-rubl else ub.ot-line.sum-base
          oborot-ep[3 + tt#]   = oborot-ep[3 + tt#]   +  if tprintrubl then ub.ot-line.vat-rubl else ub.ot-line.vat-base  .
      if tt# = 6 Then   assign
          oborot-disc[1]   = oborot-disc[1]   +  if tprintrubl then ub.ot-line.other-rubl else ub.ot-line.other-base
          oborot-ep[10]   = oborot-ep[10]   +  if tprintrubl then ub.ot-line.slt-rubl else ub.ot-line.slt-base  .
          End.
  WHEN 'es':U THEN DO:
    ASSIGN oborot-es[1 + tt#]   = oborot-es[1 + tt#]   +  ub.ot-line.fact-qnty
          oborot-es[2 + tt#]   = oborot-es[2 + tt#]   +  if tprintrubl then ub.ot-line.sum-rubl else ub.ot-line.sum-base
          oborot-es[3 + tt#]   = oborot-es[3 + tt#]   +  if tprintrubl then ub.ot-line.vat-rubl else ub.ot-line.vat-base  .
      if tt# = 6 Then   assign
          oborot-disc[1]   = oborot-disc[1]   +  if tprintrubl then ub.ot-line.other-rubl else ub.ot-line.other-base
          oborot-es[10]   = oborot-es[10]   +  if tprintrubl then ub.ot-line.slt-rubl else ub.ot-line.slt-base  .
          End.
  WHEN 're':U THEN DO:
    ASSIGN oborot-re[1 + tt#]   = oborot-re[1 + tt#]   +  ub.ot-line.fact-qnty
          oborot-re[2 + tt#]   = oborot-re[2 + tt#]   +  if tprintrubl then ub.ot-line.sum-rubl else ub.ot-line.sum-base
          oborot-re[3 + tt#]   = oborot-re[3 + tt#]   +  if tprintrubl then ub.ot-line.vat-rubl else ub.ot-line.vat-base  .
      if tt# = 6 Then   assign
          oborot-disc[1]   = oborot-disc[1]   +  if tprintrubl then ub.ot-line.other-rubl else ub.ot-line.other-base
          oborot-re[10]   = oborot-re[10]   +  if tprintrubl then ub.ot-line.slt-rubl else ub.ot-line.slt-base  .
          End.
  WHEN 'rs':U THEN DO:
    ASSIGN oborot-rs[1 + tt#]   = oborot-rs[1 + tt#]   +  ub.ot-line.fact-qnty
          oborot-rs[2 + tt#]   = oborot-rs[2 + tt#]   +  if tprintrubl then ub.ot-line.sum-rubl else ub.ot-line.sum-base
          oborot-rs[3 + tt#]   = oborot-rs[3 + tt#]   +  if tprintrubl then ub.ot-line.vat-rubl else ub.ot-line.vat-base  .
      if tt# = 6 Then   assign
          oborot-disc[1]   = oborot-disc[1]   +  if tprintrubl then ub.ot-line.other-rubl else ub.ot-line.other-base
          oborot-rs[10]   = oborot-rs[10]   +  if tprintrubl then ub.ot-line.slt-rubl else ub.ot-line.slt-base  .
          End.
  WHEN 'we':U THEN DO:
    ASSIGN oborot-we[1 + tt#]   = oborot-we[1 + tt#]   +  ub.ot-line.fact-qnty
          oborot-we[2 + tt#]   = oborot-we[2 + tt#]   +  if tprintrubl then ub.ot-line.sum-rubl else ub.ot-line.sum-base
          oborot-we[3 + tt#]   = oborot-we[3 + tt#]   +  if tprintrubl then ub.ot-line.vat-rubl else ub.ot-line.vat-base  .
      if tt# = 6 Then   assign
          oborot-disc[1]   = oborot-disc[1]   +  if tprintrubl then ub.ot-line.other-rubl else ub.ot-line.other-base
          oborot-we[10]   = oborot-we[10]   +  if tprintrubl then ub.ot-line.slt-rubl else ub.ot-line.slt-base  .
          End.
  WHEN 'vt':U  OR  WHEN 'mp':U OR WHEN 'vp':U THEN DO:
    ASSIGN oborot-vt[1 + tt#]   = oborot-vt[1 + tt#]   +  ub.ot-line.fact-qnty
          oborot-vt[2 + tt#]   = oborot-vt[2 + tt#]   +  if tprintrubl then ub.ot-line.sum-rubl else ub.ot-line.sum-base
          oborot-vt[3 + tt#]   = oborot-vt[3 + tt#]   +  if tprintrubl then ub.ot-line.vat-rubl else ub.ot-line.vat-base  .
        if tt# = 6 Then  assign
          oborot-disc[1]   = oborot-disc[1]   +  if tprintrubl then ub.ot-line.other-rubl else ub.ot-line.other-base
          oborot-vt[10]   = oborot-vt[10]   +  if tprintrubl then ub.ot-line.slt-rubl else ub.ot-line.slt-base  .
          End.
  WHEN 'iv':U THEN DO:
    ASSIGN oborot-iv[1 + tt#]   = oborot-iv[1 + tt#]   +  ub.ot-line.fact-qnty
          oborot-iv[2 + tt#]   = oborot-iv[2 + tt#]   +  if tprintrubl then ub.ot-line.sum-rubl else ub.ot-line.sum-base
          oborot-iv[3 + tt#]   = oborot-iv[3 + tt#]   +  if tprintrubl then ub.ot-line.vat-rubl else ub.ot-line.vat-base  .
      if tt# = 6 Then   assign
          oborot-disc[1]   = oborot-disc[1]   +  if tprintrubl then ub.ot-line.other-rubl else ub.ot-line.other-base
          oborot-iv[10]   = oborot-iv[10]   +  if tprintrubl then ub.ot-line.slt-rubl else ub.ot-line.slt-base  .
          End.
  WHEN 'ev':U THEN DO:
    ASSIGN oborot-ev[1 + tt#]   = oborot-ev[1 + tt#]   +  ub.ot-line.fact-qnty
          oborot-ev[2 + tt#]   = oborot-ev[2 + tt#]   +  if tprintrubl then ub.ot-line.sum-rubl else ub.ot-line.sum-base
          oborot-ev[3 + tt#]   = oborot-ev[3 + tt#]   +  if tprintrubl then ub.ot-line.vat-rubl else ub.ot-line.vat-base  .
      if tt# = 6 Then   assign
          oborot-disc[1]   = oborot-disc[1]   +  if tprintrubl then ub.ot-line.other-rubl else ub.ot-line.other-base
          oborot-ev[10]   = oborot-ev[10]   +  if tprintrubl then ub.ot-line.slt-rubl else ub.ot-line.slt-base  .
          End.
  WHEN 'rv':U THEN DO:
    ASSIGN oborot-rv[1 + tt#]   = oborot-rv[1 + tt#]   +  ub.ot-line.fact-qnty
          oborot-rv[2 + tt#]   = oborot-rv[2 + tt#]   +  if tprintrubl then ub.ot-line.sum-rubl else ub.ot-line.sum-base
          oborot-rv[3 + tt#]   = oborot-rv[3 + tt#]   +  if tprintrubl then ub.ot-line.vat-rubl else ub.ot-line.vat-base  .
      if tt# = 6 Then   assign
          oborot-disc[1]   = oborot-disc[1]   +  if tprintrubl then ub.ot-line.other-rubl else ub.ot-line.other-base
          oborot-rv[10]   = oborot-rv[10]   +  if tprintrubl then ub.ot-line.slt-rubl else ub.ot-line.slt-base  .
          End.
  WHEN 'wm':U  OR  WHEN 'em':U THEN DO:
    ASSIGN oborot-em[1 + tt#]   = oborot-em[1 + tt#]   +  ub.ot-line.fact-qnty
          oborot-em[2 + tt#]   = oborot-em[2 + tt#]   +  if tprintrubl then ub.ot-line.sum-rubl else ub.ot-line.sum-base
          oborot-em[3 + tt#]   = oborot-em[3 + tt#]   +  if tprintrubl then ub.ot-line.vat-rubl else ub.ot-line.vat-base  .
        if tt# = 6 Then  assign
          oborot-disc[1]   = oborot-disc[1]   +  if tprintrubl then ub.ot-line.other-rubl else ub.ot-line.other-base
          oborot-em[10]   = oborot-em[10]   +  if tprintrubl then ub.ot-line.slt-rubl else ub.ot-line.slt-base  .
          End.
  WHEN 'im':U THEN DO:
    ASSIGN oborot-im[1 + tt#]   = oborot-im[1 + tt#]   +  ub.ot-line.fact-qnty
          oborot-im[2 + tt#]   = oborot-im[2 + tt#]   +  if tprintrubl then ub.ot-line.sum-rubl else ub.ot-line.sum-base
          oborot-im[3 + tt#]   = oborot-im[3 + tt#]   +  if tprintrubl then ub.ot-line.vat-rubl else ub.ot-line.vat-base  .
      if tt# = 6 Then   assign
          oborot-disc[1]   = oborot-disc[1]   +  if tprintrubl then ub.ot-line.other-rubl else ub.ot-line.other-base
          oborot-im[10]   = oborot-im[10]   +  if tprintrubl then ub.ot-line.slt-rubl else ub.ot-line.slt-base  .
          End.
  WHEN 'ot':U THEN DO:
    ASSIGN oborot-ot[1 + tt#]   = oborot-ot[1 + tt#]   +  ub.ot-line.fact-qnty
          oborot-ot[2 + tt#]   = oborot-ot[2 + tt#]   +  if tprintrubl then ub.ot-line.sum-rubl else ub.ot-line.sum-base
          oborot-ot[3 + tt#]   = oborot-ot[3 + tt#]   +  if tprintrubl then ub.ot-line.vat-rubl else ub.ot-line.vat-base  .
      if tt# = 6 Then   assign
          oborot-disc[1]   = oborot-disc[1]   +  if tprintrubl then ub.ot-line.other-rubl else ub.ot-line.other-base
          oborot-ot[10]   = oborot-ot[10]   +  if tprintrubl then ub.ot-line.slt-rubl else ub.ot-line.slt-base  .
          End.
  WHEN 'ap':U THEN DO:
    ASSIGN oborot-ap[1 + tt#]   = oborot-ap[1 + tt#]   +  ub.ot-line.fact-qnty
          oborot-ap[2 + tt#]   = oborot-ap[2 + tt#]   +  if tprintrubl then ub.ot-line.sum-rubl else ub.ot-line.sum-base
          oborot-ap[3 + tt#]   = oborot-ap[3 + tt#]   +  if tprintrubl then ub.ot-line.vat-rubl else ub.ot-line.vat-base  .
      if tt# = 6 Then   assign
          oborot-disc[1]   = oborot-disc[1]   +  if tprintrubl then ub.ot-line.other-rubl else ub.ot-line.other-base
          oborot-ap[10]   = oborot-ap[10]   +  if tprintrubl then ub.ot-line.slt-rubl else ub.ot-line.slt-base  .
          End.
  WHEN 'pc':U THEN DO:
    ASSIGN oborot-pc[1 + tt#]   = oborot-pc[1 + tt#]   +  ub.ot-line.fact-qnty
          oborot-pc[2 + tt#]   = oborot-pc[2 + tt#]   +  if tprintrubl then ub.ot-line.sum-rubl else ub.ot-line.sum-base
          oborot-pc[3 + tt#]   = oborot-pc[3 + tt#]   +  if tprintrubl then ub.ot-line.vat-rubl else ub.ot-line.vat-base  .
      if tt# = 6 Then   assign
          oborot-disc[1]   = oborot-disc[1]   +  if tprintrubl then ub.ot-line.other-rubl else ub.ot-line.other-base
          oborot-pc[10]   = oborot-pc[10]   +  if tprintrubl then ub.ot-line.slt-rubl else ub.ot-line.slt-base  .
          End.
            end case.
        end.
   end.
end.
else do:
xi = 1 + v-tt. run ob-line-stk ( input   x-store-code    ,input   x-store-type    ,input   x-artic         ,input   x-prod-code     ,input   x-prod-type     ,input   x-fact-order-1  ,input   x-fact-order-2  ,input   x-sum-type      ,input   x-cat-id        ,input   x-ext-doc-type  ,input   xtog-obj        ,input   xi              ,output  oborot-ie [1 + tt#] ,output  oborot-ie [2 + tt#] ,output  oborot-ie [3 + tt#] ,output  slt      ,output  disc ).    if tt# = 6 then   assign              oborot-disc[1] = oborot-disc[1] + disc     oborot-ie[10]    = oborot-ie[10]    + slt  .
xi = 2 + v-tt. run ob-line-stk ( input   x-store-code    ,input   x-store-type    ,input   x-artic         ,input   x-prod-code     ,input   x-prod-type     ,input   x-fact-order-1  ,input   x-fact-order-2  ,input   x-sum-type      ,input   x-cat-id        ,input   x-ext-doc-type  ,input   xtog-obj        ,input   xi              ,output  oborot-ee [1 + tt#] ,output  oborot-ee [2 + tt#] ,output  oborot-ee [3 + tt#] ,output  slt      ,output  disc ).    if tt# = 6 then   assign              oborot-disc[1] = oborot-disc[1] + disc     oborot-ee[10]    = oborot-ee[10]    + slt  .
xi = 3 + v-tt. run ob-line-stk ( input   x-store-code    ,input   x-store-type    ,input   x-artic         ,input   x-prod-code     ,input   x-prod-type     ,input   x-fact-order-1  ,input   x-fact-order-2  ,input   x-sum-type      ,input   x-cat-id        ,input   x-ext-doc-type  ,input   xtog-obj        ,input   xi              ,output  oborot-ep [1 + tt#] ,output  oborot-ep [2 + tt#] ,output  oborot-ep [3 + tt#] ,output  slt      ,output  disc ).    if tt# = 6 then   assign              oborot-disc[1] = oborot-disc[1] + disc     oborot-ep[10]    = oborot-ep[10]    + slt  .
xi = 4 + v-tt. run ob-line-stk ( input   x-store-code    ,input   x-store-type    ,input   x-artic         ,input   x-prod-code     ,input   x-prod-type     ,input   x-fact-order-1  ,input   x-fact-order-2  ,input   x-sum-type      ,input   x-cat-id        ,input   x-ext-doc-type  ,input   xtog-obj        ,input   xi              ,output  oborot-es [1 + tt#] ,output  oborot-es [2 + tt#] ,output  oborot-es [3 + tt#] ,output  slt      ,output  disc ).    if tt# = 6 then   assign              oborot-disc[1] = oborot-disc[1] + disc     oborot-es[10]    = oborot-es[10]    + slt  .
xi = 5 + v-tt. run ob-line-stk ( input   x-store-code    ,input   x-store-type    ,input   x-artic         ,input   x-prod-code     ,input   x-prod-type     ,input   x-fact-order-1  ,input   x-fact-order-2  ,input   x-sum-type      ,input   x-cat-id        ,input   x-ext-doc-type  ,input   xtog-obj        ,input   xi              ,output  oborot-re [1 + tt#] ,output  oborot-re [2 + tt#] ,output  oborot-re [3 + tt#] ,output  slt      ,output  disc ).    if tt# = 6 then   assign              oborot-disc[1] = oborot-disc[1] + disc     oborot-re[10]    = oborot-re[10]    + slt  .
xi = 6 + v-tt. run ob-line-stk ( input   x-store-code    ,input   x-store-type    ,input   x-artic         ,input   x-prod-code     ,input   x-prod-type     ,input   x-fact-order-1  ,input   x-fact-order-2  ,input   x-sum-type      ,input   x-cat-id        ,input   x-ext-doc-type  ,input   xtog-obj        ,input   xi              ,output  oborot-rs [1 + tt#] ,output  oborot-rs [2 + tt#] ,output  oborot-rs [3 + tt#] ,output  slt      ,output  disc ).    if tt# = 6 then   assign              oborot-disc[1] = oborot-disc[1] + disc     oborot-rs[10]    = oborot-rs[10]    + slt  .
xi = 7 + v-tt. run ob-line-stk ( input   x-store-code    ,input   x-store-type    ,input   x-artic         ,input   x-prod-code     ,input   x-prod-type     ,input   x-fact-order-1  ,input   x-fact-order-2  ,input   x-sum-type      ,input   x-cat-id        ,input   x-ext-doc-type  ,input   xtog-obj        ,input   xi              ,output  oborot-we [1 + tt#] ,output  oborot-we [2 + tt#] ,output  oborot-we [3 + tt#] ,output  slt      ,output  disc ).    if tt# = 6 then   assign              oborot-disc[1] = oborot-disc[1] + disc     oborot-we[10]    = oborot-we[10]    + slt  .
xi = 8 + v-tt. run ob-line-stk ( input   x-store-code    ,input   x-store-type    ,input   x-artic         ,input   x-prod-code     ,input   x-prod-type     ,input   x-fact-order-1  ,input   x-fact-order-2  ,input   x-sum-type      ,input   x-cat-id        ,input   x-ext-doc-type  ,input   xtog-obj        ,input   xi              ,output  oborot-vt [1 + tt#] ,output  oborot-vt [2 + tt#] ,output  oborot-vt [3 + tt#] ,output  slt      ,output  disc ).    if tt# = 6 then   assign              oborot-disc[1] = oborot-disc[1] + disc     oborot-vt[10]    = oborot-vt[10]    + slt  .
xi = 9 + v-tt. run ob-line-stk ( input   x-store-code    ,input   x-store-type    ,input   x-artic         ,input   x-prod-code     ,input   x-prod-type     ,input   x-fact-order-1  ,input   x-fact-order-2  ,input   x-sum-type      ,input   x-cat-id        ,input   x-ext-doc-type  ,input   xtog-obj        ,input   xi              ,output  oborot-iv [1 + tt#] ,output  oborot-iv [2 + tt#] ,output  oborot-iv [3 + tt#] ,output  slt      ,output  disc ).    if tt# = 6 then   assign              oborot-disc[1] = oborot-disc[1] + disc     oborot-iv[10]    = oborot-iv[10]    + slt  .
xi = 10 + v-tt. run ob-line-stk ( input   x-store-code    ,input   x-store-type    ,input   x-artic         ,input   x-prod-code     ,input   x-prod-type     ,input   x-fact-order-1  ,input   x-fact-order-2  ,input   x-sum-type      ,input   x-cat-id        ,input   x-ext-doc-type  ,input   xtog-obj        ,input   xi              ,output  oborot-ev [1 + tt#] ,output  oborot-ev [2 + tt#] ,output  oborot-ev [3 + tt#] ,output  slt      ,output  disc ).    if tt# = 6 then   assign              oborot-disc[1] = oborot-disc[1] + disc     oborot-ev[10]    = oborot-ev[10]    + slt  .
xi = 11 + v-tt. run ob-line-stk ( input   x-store-code    ,input   x-store-type    ,input   x-artic         ,input   x-prod-code     ,input   x-prod-type     ,input   x-fact-order-1  ,input   x-fact-order-2  ,input   x-sum-type      ,input   x-cat-id        ,input   x-ext-doc-type  ,input   xtog-obj        ,input   xi              ,output  oborot-rv [1 + tt#] ,output  oborot-rv [2 + tt#] ,output  oborot-rv [3 + tt#] ,output  slt      ,output  disc ).    if tt# = 6 then   assign              oborot-disc[1] = oborot-disc[1] + disc     oborot-rv[10]    = oborot-rv[10]    + slt  .
xi = 12 + v-tt. run ob-line-stk ( input   x-store-code    ,input   x-store-type    ,input   x-artic         ,input   x-prod-code     ,input   x-prod-type     ,input   x-fact-order-1  ,input   x-fact-order-2  ,input   x-sum-type      ,input   x-cat-id        ,input   x-ext-doc-type  ,input   xtog-obj        ,input   xi              ,output  oborot-em [1 + tt#] ,output  oborot-em [2 + tt#] ,output  oborot-em [3 + tt#] ,output  slt      ,output  disc ).    if tt# = 6 then   assign              oborot-disc[1] = oborot-disc[1] + disc     oborot-em[10]    = oborot-em[10]    + slt  .
xi = 13 + v-tt. run ob-line-stk ( input   x-store-code    ,input   x-store-type    ,input   x-artic         ,input   x-prod-code     ,input   x-prod-type     ,input   x-fact-order-1  ,input   x-fact-order-2  ,input   x-sum-type      ,input   x-cat-id        ,input   x-ext-doc-type  ,input   xtog-obj        ,input   xi              ,output  oborot-im [1 + tt#] ,output  oborot-im [2 + tt#] ,output  oborot-im [3 + tt#] ,output  slt      ,output  disc ).    if tt# = 6 then   assign              oborot-disc[1] = oborot-disc[1] + disc     oborot-im[10]    = oborot-im[10]    + slt  .
xi = 14 + v-tt. run ob-line-stk ( input   x-store-code    ,input   x-store-type    ,input   x-artic         ,input   x-prod-code     ,input   x-prod-type     ,input   x-fact-order-1  ,input   x-fact-order-2  ,input   x-sum-type      ,input   x-cat-id        ,input   x-ext-doc-type  ,input   xtog-obj        ,input   xi              ,output  oborot-ot [1 + tt#] ,output  oborot-ot [2 + tt#] ,output  oborot-ot [3 + tt#] ,output  slt      ,output  disc ).    if tt# = 6 then   assign              oborot-disc[1] = oborot-disc[1] + disc     oborot-ot[10]    = oborot-ot[10]    + slt  .
xi = 15 + v-tt. run ob-line-stk ( input   x-store-code    ,input   x-store-type    ,input   x-artic         ,input   x-prod-code     ,input   x-prod-type     ,input   x-fact-order-1  ,input   x-fact-order-2  ,input   x-sum-type      ,input   x-cat-id        ,input   x-ext-doc-type  ,input   xtog-obj        ,input   xi              ,output  oborot-ap [1 + tt#] ,output  oborot-ap [2 + tt#] ,output  oborot-ap [3 + tt#] ,output  slt      ,output  disc ).    if tt# = 6 then   assign              oborot-disc[1] = oborot-disc[1] + disc     oborot-ap[10]    = oborot-ap[10]    + slt  .
xi = 16 + v-tt. run ob-line-stk ( input   x-store-code    ,input   x-store-type    ,input   x-artic         ,input   x-prod-code     ,input   x-prod-type     ,input   x-fact-order-1  ,input   x-fact-order-2  ,input   x-sum-type      ,input   x-cat-id        ,input   x-ext-doc-type  ,input   xtog-obj        ,input   xi              ,output  oborot-pc [1 + tt#] ,output  oborot-pc [2 + tt#] ,output  oborot-pc [3 + tt#] ,output  slt      ,output  disc ).    if tt# = 6 then   assign              oborot-disc[1] = oborot-disc[1] + disc     oborot-pc[10]    = oborot-pc[10]    + slt  .
end.
  if tt# = 6 then do:
  if  xshowmediator = false then
      oborot-sum-cost[1] =
      oborot-ee[2]      +
      oborot-es[2] +
      oborot-re[2]  +
      oborot-rs[2]
      .
      else
      oborot-sum-cost[1] =
      oborot-ee[4]      +
      oborot-es[4] +
      oborot-re[4]  +
      oborot-rs[4]
      .
     repeat v-ii = 1 to 1 :
     v-summa[v-ii ]  =
        oborot-ie[v-ii ] + oborot-ee[v-ii ] + oborot-ep[v-ii ] +
        oborot-es[v-ii ] + oborot-re[v-ii ] + oborot-rs[v-ii ] +
        oborot-we[v-ii ] + oborot-vt[v-ii ] + oborot-iv[v-ii ] +
        oborot-ev[v-ii ] + oborot-rv[v-ii ] + oborot-em[v-ii ] +
        oborot-im[v-ii ] .
     end.
     repeat v-ii = 2 to 4 :
     v-summa[v-ii ]  =
        oborot-ie[v-ii + tt#] + oborot-ee[v-ii + tt#] + oborot-ep[v-ii + tt#] +
        oborot-es[v-ii + tt#] + oborot-re[v-ii + tt#] + oborot-rs[v-ii + tt#] +
        oborot-we[v-ii + tt#] + oborot-vt[v-ii + tt#] + oborot-iv[v-ii + tt#] +
        oborot-ev[v-ii + tt#] + oborot-rv[v-ii + tt#] + oborot-em[v-ii + tt#] +
        oborot-im[v-ii + tt#] .
     end.
      oborot-sum-sale[1] =
      oborot-ee[2 + tt#] +
      oborot-es[2 + tt#] +
      oborot-re[2 + tt#] +
      oborot-rs[2 + tt#]
      .
       assign oborot-ot[1 + tt#] = (ostatok-end[1 + tt#]  - ostatok-start[1 + tt#])  -  (v-summa[1])
        oborot-ot[2 + tt#] = (ostatok-end[2 + tt#]  - ostatok-start[2 + tt#])  -  (v-summa[2])
                                                                                                  -  oborot-disc[1]
        oborot-ot[3 + tt#] = (ostatok-end[3 + tt#]  - ostatok-start[3 + tt#])  -  (v-summa[3])
        oborot-ot[10] = (ostatok-end[10]  - ostatok-start[10])                 -  (v-summa[4])
        .
        oborot-eff[1] = -1 * (oborot-sum-sale[1] - oborot-sum-cost[1]) .
        if oborot-sum-cost[1] <>  0 then
          oborot-prc[1] = 100 * (oborot-sum-sale[1] - oborot-sum-cost[1] ) / oborot-sum-cost[1].
          else oborot-prc[1] = 0.
  end.
oborot-ie[4]   = Round(oborot-ie[1]   *  p-price-med , 2) .
oborot-ee[4]   = Round(oborot-ee[1]   *  p-price-med , 2) .
oborot-ep[4]   = Round(oborot-ep[1]   *  p-price-med , 2) .
oborot-es[4]   = Round(oborot-es[1]   *  p-price-med , 2) .
oborot-re[4]   = Round(oborot-re[1]   *  p-price-med , 2) .
oborot-rs[4]   = Round(oborot-rs[1]   *  p-price-med , 2) .
oborot-we[4]   = Round(oborot-we[1]   *  p-price-med , 2) .
oborot-vt[4]   = Round(oborot-vt[1]   *  p-price-med , 2) .
oborot-iv[4]   = Round(oborot-iv[1]   *  p-price-med , 2) .
oborot-ev[4]   = Round(oborot-ev[1]   *  p-price-med , 2) .
oborot-rv[4]   = Round(oborot-rv[1]   *  p-price-med , 2) .
oborot-em[4]   = Round(oborot-em[1]   *  p-price-med , 2) .
oborot-im[4]   = Round(oborot-im[1]   *  p-price-med , 2) .
oborot-ot[4]   = Round(oborot-ot[1]   *  p-price-med , 2) .
oborot-ap[4]   = Round(oborot-ap[1]   *  p-price-med , 2) .
oborot-pc[4]   = Round(oborot-pc[1]   *  p-price-med , 2) .
END PROCEDURE.
PROCEDURE report-exec1  :
   FIND FIRST clients where x-store-type = clients.obj-type AND
                            x-store-code = clients.obj-code no-lock no-error.
           If available clients then  ObjName = clients.obj-name.
                                         else  ObjName="объект не определен".
  FORM with FRAME zapas .
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
form header
  line format "X(197)" at 1 skip
  "Продолжение - на следующей странице" at 30 skip
  with frame bottomframe width 340 page-bottom no-labels no-box .
view stream outstream frame bottomframe .
  Run CalcItog  in this-procedure .
  Run Print-Header  in this-procedure .
   CASE RetClassify :
      when "grp-goods":U then       Run Run2  in this-procedure .
      otherwise do:
        message "" view-as alert-box error .
      end.
   End case.
  HIDE stream OutStream FRAME BottomFrame .
  Run Print-footer  in this-procedure .
  END PROCEDURE.
PROCEDURE Calc-Sub-itog :
define input parameter tt as int no-undo.
define variable tt2 as integer no-undo .
define variable ji as integer no-undo .
  if tt = 6 then tt2 = 7 .
            else tt2 = tt.
Repeat i# = 1 + tt to 3 + tt2 :
run sum-i (
 input oborot-vt[i#]
,input tt
,input-output b1-oborot-vt[i#]
,input-output b2-oborot-vt[i#]
,input-output bi-oborot-vt[i#]
,input-output bo-oborot-vt[i#]
,input oborot-ie[i#]
,input-output b1-oborot-ie[i#]
,input-output b2-oborot-ie[i#]
,input-output bi-oborot-ie[i#]
,input-output bo-oborot-ie[i#]
) .
run sum-i (
 input oborot-iv[i#]
,input tt
,input-output b1-oborot-iv[i#]
,input-output b2-oborot-iv[i#]
,input-output bi-oborot-iv[i#]
,input-output bo-oborot-iv[i#]
,input oborot-ee[i#]
,input-output b1-oborot-ee[i#]
,input-output b2-oborot-ee[i#]
,input-output bi-oborot-ee[i#]
,input-output bo-oborot-ee[i#]
) .
run sum-i (
 input oborot-ev[i#]
,input tt
,input-output b1-oborot-ev[i#]
,input-output b2-oborot-ev[i#]
,input-output bi-oborot-ev[i#]
,input-output bo-oborot-ev[i#]
,input oborot-ep[i#]
,input-output b1-oborot-ep[i#]
,input-output b2-oborot-ep[i#]
,input-output bi-oborot-ep[i#]
,input-output bo-oborot-ep[i#]
) .
run sum-i (
 input oborot-rv[i#]
,input tt
,input-output b1-oborot-rv[i#]
,input-output b2-oborot-rv[i#]
,input-output bi-oborot-rv[i#]
,input-output bo-oborot-rv[i#]
,input oborot-es[i#]
,input-output b1-oborot-es[i#]
,input-output b2-oborot-es[i#]
,input-output bi-oborot-es[i#]
,input-output bo-oborot-es[i#]
) .
run sum-i (
 input oborot-em[i#]
,input tt
,input-output b1-oborot-em[i#]
,input-output b2-oborot-em[i#]
,input-output bi-oborot-em[i#]
,input-output bo-oborot-em[i#]
,input oborot-re[i#]
,input-output b1-oborot-re[i#]
,input-output b2-oborot-re[i#]
,input-output bi-oborot-re[i#]
,input-output bo-oborot-re[i#]
) .
run sum-i (
 input oborot-im[i#]
,input tt
,input-output b1-oborot-im[i#]
,input-output b2-oborot-im[i#]
,input-output bi-oborot-im[i#]
,input-output bo-oborot-im[i#]
,input oborot-rs[i#]
,input-output b1-oborot-rs[i#]
,input-output b2-oborot-rs[i#]
,input-output bi-oborot-rs[i#]
,input-output bo-oborot-rs[i#]
) .
run sum-i (
 input oborot-ap[i#]
,input tt
,input-output b1-oborot-ap[i#]
,input-output b2-oborot-ap[i#]
,input-output bi-oborot-ap[i#]
,input-output bo-oborot-ap[i#]
,input oborot-pc[i#]
,input-output b1-oborot-pc[i#]
,input-output b2-oborot-pc[i#]
,input-output bi-oborot-pc[i#]
,input-output bo-oborot-pc[i#]
) .
run sum-i (
 input oborot-ot[i#]
,input tt
,input-output b1-oborot-ot[i#]
,input-output b2-oborot-ot[i#]
,input-output bi-oborot-ot[i#]
,input-output bo-oborot-ot[i#]
,input oborot-we[i#]
,input-output b1-oborot-we[i#]
,input-output b2-oborot-we[i#]
,input-output bi-oborot-we[i#]
,input-output bo-oborot-we[i#]
) .
  B1-oborot-em[ i#] = B1-oborot-em[ i#] + oborot-wm[ i#].
  B2-oborot-em[ i#] = B2-oborot-em[ i#] + oborot-wm[ i#].
  Bi-oborot-em[ i#] = Bi-oborot-em[ i#] + oborot-wm[ i#].
  Bo-oborot-em[ i#] = Bo-oborot-em[ i#] + oborot-wm[ i#].
  Bo-ostatok-start[ i#]  = Bo-ostatok-start[i#]  + ostatok-start[ i#]  .
  Bo-ostatok-end[ i#]    = Bo-ostatok-end[i#]    + ostatok-end[ i#]    .
  if i# = 7 then B1-oborot-disc[1 ]  = B1-oborot-disc[1]  + oborot-disc[1]  .
  if i# = 7 then B2-oborot-disc[1 ]  = B2-oborot-disc[1]  + oborot-disc[1]  .
  if i# = 7 then Bi-oborot-disc[1 ]  = Bi-oborot-disc[1]  + oborot-disc[1]  .
  if i# = 7 then Bo-oborot-disc[1 ]  = Bo-oborot-disc[1]  + oborot-disc[1]  .
  if i# = 8 then
    assign
      bi-oborot-sum-Sale[ i#]  = Bi-oborot-ee[ i#] +
                              Bi-oborot-re[ i#]         +
                              Bi-oborot-rs[ i#]    +
                              Bi-oborot-es[ i#]
      b1-oborot-sum-Sale[ i#]  = B1-oborot-ee[ i#] +
                              B1-oborot-re[ i#]         +
                              B1-oborot-rs[ i#]    +
                              B1-oborot-es[ i#]
      b2-oborot-sum-Sale[ i#]  = B2-oborot-ee[ i#] +
                              B2-oborot-re[ i#]         +
                              B2-oborot-rs[ i#]    +
                              B2-oborot-es[ i#]
      bo-oborot-sum-Sale[ i#]  = Bo-oborot-ee[ i#] +
                              Bo-oborot-re[ i#]         +
                              Bo-oborot-rs[ i#]    +
                              Bo-oborot-es[ i#]
      .
  if i# = 2 and  xShowmediator = false   then do:
      ji = 2.
      assign
        bi-oborot-sum-cost[ i#]  = Bi-oborot-ee[ ji] +
                                Bi-oborot-re[ ji]         +
                                Bi-oborot-rs[ ji]    +
                                Bi-oborot-es[ ji]
        b1-oborot-sum-cost[ i#]  = B1-oborot-ee[ ji] +
                                B1-oborot-re[ ji]         +
                                B1-oborot-rs[ ji]    +
                                B1-oborot-es[ ji]
        b2-oborot-sum-cost[ i#]  = B2-oborot-ee[ ji] +
                                B2-oborot-re[ ji]         +
                                B2-oborot-rs[ ji]    +
                                B2-oborot-es[ ji]
        bo-oborot-sum-cost[ i#]  = Bo-oborot-ee[ ji] +
                                Bo-oborot-re[ ji]         +
                                Bo-oborot-rs[ ji]    +
                                Bo-oborot-es[ ji]
        .
  end.
  if  xShowmediator = true  then do:
  if i# = 8 then B1-oborot-sum-cost[2 ]  = B1-oborot-sum-cost[2]  + oborot-sum-cost[1]  .
  if i# = 8 then B2-oborot-sum-cost[2 ]  = B2-oborot-sum-cost[2]  + oborot-sum-cost[1]  .
  if i# = 8 then Bi-oborot-sum-cost[2 ]  = Bi-oborot-sum-cost[2]  + oborot-sum-cost[1]  .
  if i# = 8 then Bo-oborot-sum-cost[2 ]  = Bo-oborot-sum-cost[2]  + oborot-sum-cost[1]  .
  end.
  if i# = 8 then B1-oborot-eff[1 ]  = B1-oborot-eff[1]  + oborot-eff[1]  .
  if i# = 8 then B2-oborot-eff[1 ]  = B2-oborot-eff[1]  + oborot-eff[1]  .
  if i# = 8 then Bi-oborot-eff[1 ]  = Bi-oborot-eff[1]  + oborot-eff[1]  .
  if i# = 8 then Bo-oborot-eff[1 ]  = Bo-oborot-eff[1]  + oborot-eff[1]  .
  if i# = 8 then    if  Bi-oborot-sum-cost[2] <>  0 then
                        Bi-oborot-prc[1] = 100 * (BI-oborot-sum-sale[8] - BI-oborot-sum-cost[2] ) / Bi-oborot-sum-cost[2] .
                   else Bi-oborot-prc[1] = 0.
  if i# = 8 then    if  Bo-oborot-sum-cost[2] <>  0 then
                        BO-oborot-prc[1] = 100 * (Bo-oborot-sum-sale[8] - Bo-oborot-sum-cost[2] ) / Bo-oborot-sum-cost[2] .
                   else BO-oborot-prc[1] = 0.
  if i# = 8 then    if  B1-oborot-sum-cost[2] <>  0 then
                        B1-oborot-prc[1] = 100 * (B1-oborot-sum-sale[8] - B1-oborot-sum-cost[2] ) / B1-oborot-sum-cost[2] .
                   else B1-oborot-prc[1] = 0.
  if i# = 8 then    if  B2-oborot-sum-cost[2] <>  0 then
                        B2-oborot-prc[1] = 100 * (B2-oborot-sum-sale[8] - B2-oborot-sum-cost[2] ) / B2-oborot-sum-cost[2] .
                   else B2-oborot-prc[1] = 0.
 End.
END PROCEDURE.
PROCEDURE Sum-i :
define input parameter ob like oborot-ot[1] no-undo.
define input parameter tt as int  no-undo.
define input-output parameter b1 like b1-oborot-ot[1] no-undo.
define input-output parameter b2 like b1-oborot-ot[1] no-undo.
define input-output parameter bi like b1-oborot-ot[1] no-undo.
define input-output parameter bo like b1-oborot-ot[1] no-undo.
define input parameter ob2 like oborot-ot[1] no-undo.
define input-output parameter b1- like b1-oborot-ot[1] no-undo.
define input-output parameter b2- like b1-oborot-ot[1] no-undo.
define input-output parameter bi- like b1-oborot-ot[1] no-undo.
define input-output parameter bo- like b1-oborot-ot[1] no-undo.
Assign
  B1 = B1 + ob
  B2 = B2 + ob
  B1- = B1- + ob2
  B2- = B2- + ob2
  Bi = Bi + ob
  Bo = Bo + ob
  Bi- = Bi- + ob2
  Bo- = Bo- + ob2
.
END PROCEDURE.
PROCEDURE Clear-item :
define variable kk as int no-undo.
 REPEAT kk = 1 to 12 :
 Assign
    oborot-ie                 [kk]    = 0
    oborot-ee                 [kk]    = 0
    oborot-ep              [kk]    = 0
    oborot-es            [kk]    = 0
    oborot-re             [kk]    = 0
    oborot-rs        [kk]    = 0
    oborot-we                 [kk]    = 0
    oborot-vt                       [kk]    = 0
    oborot-iv                 [kk]    = 0
    oborot-ev                 [kk]    = 0
    oborot-rv             [kk]    = 0
    oborot-em                  [kk]    = 0
    oborot-wm                  [kk]    = 0
    oborot-im                  [kk]    = 0
    oborot-ot                  [kk]    = 0
    oborot-disc                            [kk]    = 0
    oborot-eff                            [kk]    = 0
    oborot-prc                            [kk]    = 0
    oborot-ap            [kk]    = 0
    oborot-pc            [kk]    = 0
    oborot-r-v                                    [kk]    = 0
    ostatok-end      [kk] =   0
    ostatok-start    [kk] =   0   .
       End.
 END PROCEDURE.
PROCEDURE Item-Goods :
 define input parameter  par-3 as char no-undo.
 define input parameter  par-4 as char no-undo.
 if line-counter( OutStream )  > page-size( OutStream ) then DO :
                 display STREAM OutStream    with frame top-frame .
                 display STREAM OutStream    with frame top-2 .
                 end.
     if par-4 = "goods":U  Then  assign
                gds-zap-unit-base  = goods.unit-base
                gds-zap-prt-root   = Goods.prt-root
                gds-zap-prod-type  = Goods.prod-type
                gds-zap-prod-code  = Goods.prod-code
                gds-zap-artic      = Goods.artic
                gds-zap-type       = Goods.gds-type
                gds-zap-grp-name   = Goods.grp-name
                gds-zap-b-code     = Goods.gds-code
                gds-zap-gds-name   = if g#gds-engl then Goods.engl-name
                                                    else Goods.gds-name.
     if par-4 = "gds-list":U  Then  assign
                  gds-zap-unit-base  = gds-list.unit-base
                  gds-zap-prt-root   = gds-list.prt-root
                  gds-zap-prod-type  = gds-list.prod-type
                  gds-zap-prod-code  = gds-list.prod-code
                  gds-zap-artic      = gds-list.artic
                  gds-zap-type       = gds-list.gds-type
                  gds-zap-grp-name   = gds-list.grp-name
                  gds-zap-b-code     = gds-list.gds-code
                  gds-zap-gds-name   = if g#gds-engl then Gds-list.engl-name
                                                      else Gds-list.gds-name.
  Run foreach  in this-procedure .
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
  Run display-line   in this-procedure .
END PROCEDURE.
Procedure Null-str-pr :
 if (
     oborot-im [1]                  = 0 and
     oborot-wm [1]                  = 0 and
     oborot-em [1]                  = 0 and
     oborot-ie     [1]             = 0 and
     oborot-ee                 [1] = 0  and
     oborot-ep              [1] = 0  and
     oborot-es            [1] = 0  and
     oborot-re             [1] = 0  and
     oborot-rs        [1] = 0  and
     oborot-we                 [1] = 0  and
     oborot-vt                       [1] = 0  and
     oborot-iv                 [1] = 0  and
     oborot-ev                 [1] = 0  and
     oborot-rv             [1] = 0  and
     oborot-ot                  [2] = 0  and
     oborot-ap            [1]    = 0 and
     oborot-pc            [1]    = 0 and
     ostatok-end[1]                                     = 0  and
     ostatok-start[1]                                   = 0 and
     oborot-im [2]                  = 0 and
     oborot-wm [2]                  = 0 and
     oborot-em [2]                  = 0 and
     oborot-ie     [2]             = 0 and
     oborot-ee                [2] = 0  and
     oborot-ep              [2] = 0  and
     oborot-es            [2] = 0  and
     oborot-re             [2] = 0  and
     oborot-rs        [2] = 0  and
     oborot-we                 [2] = 0  and
     oborot-vt                       [2] = 0  and
     oborot-iv                 [2] = 0  and
     oborot-ev                 [2] = 0  and
     oborot-rv             [2] = 0  and
      oborot-ap            [2]    = 0 and
     oborot-pc            [2]    = 0 and
     ostatok-end[2]                                     = 0  and
     ostatok-start[2]                                   = 0
      ) then   Null-str# = 0    .
END PROCEDURE.
Procedure Null-str-pr2 :
 if (
     oborot-im                 [1] = 0 and
     oborot-wm                 [1] = 0 and
     oborot-em [1]                  = 0 and
     oborot-ie                 [1] = 0  and
     oborot-ee                 [1] = 0  and
     oborot-ep              [1] = 0  and
     oborot-es            [1] = 0  and
     oborot-re             [1] = 0  and
     oborot-rs        [1] = 0  and
     oborot-we                 [1] = 0  and
     oborot-vt                       [1] = 0  and
     oborot-iv                [1] = 0  and
     oborot-ev                [1] = 0  and
     oborot-rv            [1] = 0  and
     oborot-ot                 [1] = 0  and
     oborot-ot                 [2] = 0  and
    oborot-ap            [1]    = 0 and
    oborot-pc            [1]    = 0 and
     oborot-im                 [2] = 0 and
     oborot-wm                 [2] = 0 and
     oborot-em [2]                  = 0 and
     oborot-ie                 [2] = 0  and
     oborot-ee                 [2] = 0  and
     oborot-ep              [2] = 0  and
     oborot-es            [2] = 0  and
     oborot-re             [2] = 0  and
     oborot-rs        [2] = 0  and
     oborot-we                 [2] = 0  and
     oborot-vt                       [2] = 0  and
     oborot-iv                [2] = 0  and
     oborot-ev                [2] = 0  and
     oborot-rv            [2] = 0  and
    oborot-ap            [2]    = 0 and
    oborot-pc            [2]    = 0
     ) then   Null-str2# = 0    .
END PROCEDURE.
Procedure b1-Null-str-pr :
 if (
     b1-oborot-im [1]                  = 0 and
     b1-oborot-wm [1]                  = 0 and
     b1-oborot-em [1]                  = 0 and
     b1-oborot-ie     [1]             = 0 and
     b1-oborot-ee                 [1] = 0  and
     b1-oborot-ep              [1] = 0  and
     b1-oborot-es            [1] = 0  and
     b1-oborot-re             [1] = 0  and
     b1-oborot-rs        [1] = 0  and
     b1-oborot-we                 [1] = 0  and
     b1-oborot-vt                       [1] = 0  and
     b1-oborot-iv                 [1] = 0  and
     b1-oborot-ev                 [1] = 0  and
     b1-oborot-rv             [1] = 0  and
     b1-oborot-ot                  [2] = 0  and
     b1-oborot-ap            [1]    = 0 and
     b1-oborot-pc            [1]    = 0 and
     b1-ostatok-end[1]                                     = 0  and
     b1-ostatok-start[1]                                   = 0  and
     b1-oborot-im [2]                  = 0 and
     b1-oborot-wm [2]                  = 0 and
     b1-oborot-em [2]                  = 0 and
     b1-oborot-ie     [2]             = 0 and
     b1-oborot-ee                 [2] = 0  and
     b1-oborot-ep              [2] = 0  and
     b1-oborot-es            [2] = 0  and
     b1-oborot-re             [2] = 0  and
     b1-oborot-rs        [2] = 0  and
     b1-oborot-we                 [2] = 0  and
     b1-oborot-vt                       [2] = 0  and
     b1-oborot-iv                 [2] = 0  and
     b1-oborot-ev                 [2] = 0  and
     b1-oborot-rv             [2] = 0  and
     b1-oborot-ap            [2]    = 0 and
     b1-oborot-pc            [2]    = 0 and
     b1-ostatok-end[2]                                     = 0  and
     b1-ostatok-start[2]                                   = 0
     ) then  b1-Null-str# = 0    .
END PROCEDURE.
Procedure b1-Null-str-pr2 :
 if (
     b1-oborot-im                 [1] = 0 and
     b1-oborot-wm                 [1] = 0 and
     b1-oborot-em                 [1] = 0 and
     b1-oborot-ie                 [1] = 0  and
     b1-oborot-ee                 [1] = 0  and
     b1-oborot-ep              [1] = 0  and
     b1-oborot-es            [1] = 0  and
     b1-oborot-re             [1] = 0  and
     b1-oborot-rs        [1] = 0  and
     b1-oborot-we                 [1] = 0  and
     b1-oborot-vt                       [1] = 0  and
     b1-oborot-iv                [1] = 0  and
     b1-oborot-ev                [1] = 0  and
     b1-oborot-rv            [1] = 0  and
     b1-oborot-ot                 [1] = 0  and
     b1-oborot-ap            [1] = 0  and
     b1-oborot-pc            [1] = 0  and
     b1-oborot-ot                 [2] = 0  and
     b1-oborot-im                 [2] = 0  and
     b1-oborot-wm                 [2] = 0  and
     b1-oborot-em                 [2] = 0  and
     b1-oborot-ie                 [2] = 0  and
     b1-oborot-ee                 [2] = 0  and
     b1-oborot-ep              [2] = 0  and
     b1-oborot-es            [2] = 0  and
     b1-oborot-re             [2] = 0  and
     b1-oborot-rs        [2] = 0  and
     b1-oborot-we                 [2] = 0  and
     b1-oborot-vt                       [2] = 0  and
     b1-oborot-iv                [2] = 0  and
     b1-oborot-ev                [2] = 0  and
     b1-oborot-rv            [2] = 0  and
     b1-oborot-ap            [2] = 0  and
     b1-oborot-pc            [2] = 0
     ) then   b1-Null-str2# = 0    .
    END PROCEDURE.
Procedure b2-Null-str-pr :
 if (
     b2-oborot-im [1]                  = 0 and
     b2-oborot-wm [1]                  = 0 and
     b2-oborot-em [1]                  = 0 and
     b2-oborot-ie     [1]             = 0 and
     b2-oborot-ee                 [1] = 0  and
     b2-oborot-ep              [1] = 0  and
     b2-oborot-es            [1] = 0  and
     b2-oborot-re             [1] = 0  and
     b2-oborot-rs        [1] = 0  and
     b2-oborot-we                 [1] = 0  and
     b2-oborot-vt                       [1] = 0  and
     b2-oborot-iv                 [1] = 0  and
     b2-oborot-ev                 [1] = 0  and
     b2-oborot-rv             [1] = 0  and
     b2-oborot-ot                  [2] = 0  and
     b2-oborot-ap            [1]    = 0 and
     b2-oborot-pc            [1]    = 0 and
     b2-ostatok-end[1]                                     = 0  and
     b2-ostatok-start[1]                                   = 0  and
     b2-oborot-im [2]                  = 0 and
     b2-oborot-wm [2]                  = 0 and
     b2-oborot-em [2]                  = 0 and
     b2-oborot-ie     [2]             = 0 and
     b2-oborot-ee                 [2] = 0  and
     b2-oborot-ep              [2] = 0  and
     b2-oborot-es            [2] = 0  and
     b2-oborot-re             [2] = 0  and
     b2-oborot-rs        [2] = 0  and
     b2-oborot-we                 [2] = 0  and
     b2-oborot-vt                       [2] = 0  and
     b2-oborot-iv                 [2] = 0  and
     b2-oborot-ev                 [2] = 0  and
     b2-oborot-rv             [2] = 0  and
     b2-oborot-ap             [2]    = 0 and
     b2-oborot-pc             [2]    = 0 and
     b2-ostatok-end[2]                                     = 0  and
     b2-ostatok-start[2]                                   = 0
     ) then  b2-Null-str# = 0    .
END PROCEDURE.
Procedure b2-Null-str-pr2 :
 if (
     b2-oborot-im                 [1] = 0 and
     b2-oborot-wm                 [1] = 0 and
     b2-oborot-em [1]                  = 0 and
     b2-oborot-ie                 [1] = 0  and
     b2-oborot-ee                 [1] = 0  and
     b2-oborot-ep              [1] = 0  and
     b2-oborot-es            [1] = 0  and
     b2-oborot-re             [1] = 0  and
     b2-oborot-rs        [1] = 0  and
     b2-oborot-we                 [1] = 0  and
     b2-oborot-vt                       [1] = 0  and
     b2-oborot-iv                [1] = 0  and
     b2-oborot-ev                [1] = 0  and
     b2-oborot-rv            [1] = 0  and
     b2-oborot-ot                 [1] = 0  and
     b2-oborot-ap            [1]    = 0 and
     b2-oborot-pc            [1]    = 0 and
     b2-oborot-ot                 [2] = 0 and
     b2-oborot-im                 [2] = 0 and
     b2-oborot-wm                 [2] = 0 and
     b2-oborot-em [2]                 = 0 and
     b2-oborot-ie                 [2] = 0  and
     b2-oborot-ee                 [2] = 0  and
     b2-oborot-ep              [2] = 0  and
     b2-oborot-es            [2] = 0  and
     b2-oborot-re             [2] = 0  and
     b2-oborot-rs        [2] = 0  and
     b2-oborot-we                 [2] = 0  and
     b2-oborot-vt                       [2] = 0  and
     b2-oborot-iv                [2] = 0  and
     b2-oborot-ev                [2] = 0  and
     b2-oborot-rv            [2] = 0  and
     b2-oborot-ot                 [2] = 0  and
     b2-oborot-ap            [2]    = 0 and
     b2-oborot-pc            [2]    = 0
      ) then   b2-Null-str2# = 0    .
END PROCEDURE.
PROCEDURE PRICE-VAT :
define input parameter PP as character no-undo .
if pp = '' THEN DO:
if line-counter( OutStream ) > page-size( OutStream ) then DO: display STREAM OutStream with frame top-frame. end.
p = p + 1.
if use-column[5] then  c-gds-type:screen-value          = v-name-type.
if use-column[6]  then C-ostatok-start:screen-value                          = if x-vat then  string(  ostatok-start  [2]                         ) else  string(  ostatok-start  [2]                        -  ostatok-start  [3]                       )  .
if use-column[7]  then C-oborot-ie:screen-value          = if x-vat then  string(  oborot-ie [2]          ) else  string(  oborot-ie [2]         -  oborot-ie [3]        )  .
if use-column[8]  then C-oborot-iv:screen-value          = if x-vat then  string(  oborot-iv [2]          ) else  string(  oborot-iv [2]         -  oborot-iv [3]        )  .
if use-column[9]  then C-oborot-im:screen-value           = if x-vat then  string(  oborot-im  [2]          ) else  string(  oborot-im  [2]         -  oborot-im  [3]        )  .
if use-column[10] then C-oborot-ee:screen-value          = if x-vat then  string(  oborot-ee [2]          ) else  string(  oborot-ee [2]         -  oborot-ee [3]        )  .
if use-column[11] then C-oborot-ev:screen-value          = if x-vat then  string(  oborot-ev [2]          ) else  string(  oborot-ev [2]         -  oborot-ev [3]        )  .
if use-column[12] then C-oborot-em:screen-value           = if x-vat then  string(  oborot-em  [2]          ) else  string(  oborot-em  [2]         -  oborot-em  [3]        )  .
if use-column[13] then C-oborot-we:screen-value          = if x-vat then  string(  oborot-we         [2]  ) else  string(  oborot-we         [2] -  oborot-we         [3])  .
if use-column[14] then C-oborot-es:screen-value     = if x-vat then  string(  oborot-es    [2]  ) else  string(  oborot-es    [2] -  oborot-es    [3])  .
if use-column[15] then C-oborot-rs:screen-value = if x-vat then  string(  oborot-rs[2]  ) else  string(  oborot-rs[2] -  oborot-rs[3])  .
if use-column[16] then C-oborot-re:screen-value      = if x-vat then  string(  oborot-re     [2]  ) else  string(  oborot-re     [2] -  oborot-re     [3])  .
if use-column[17] then C-oborot-ep:screen-value       = if x-vat then  string(  oborot-ep      [2]  ) else  string(  oborot-ep      [2] -  oborot-ep      [3])  .
if use-column[18] then C-oborot-rv:screen-value      = if x-vat then  string(  oborot-rv     [2]  ) else  string(  oborot-rv     [2] -  oborot-rv     [3])  .
if use-column[19] then C-oborot-vt:screen-value                = if x-vat then  string(  oborot-vt               [2]  ) else  string(  oborot-vt               [2] -  oborot-vt               [3])  .
if use-column[20] then C-oborot-ot:screen-value           = if x-vat then  string(  oborot-ot          [2]  ) else  string(  oborot-ot          [2] -  oborot-ot          [3])  .
if use-column[22] then C-ostatok-end:screen-value                            = if x-vat then  string(  ostatok-end                           [2]  ) else  string(  ostatok-end                           [2] -  ostatok-end                           [3])  .
if use-column[25] then C-oborot-ap:screen-value     = if x-vat then  string(  oborot-ap    [2])   else  string(  oborot-ap [2]    -  oborot-ap [3]   )  .
if use-column[26] then C-oborot-pc:screen-value     = if x-vat then  string(  oborot-pc    [2])   else  string(  oborot-pc [2]    -  oborot-pc [3]   )  .
if use-column[27] then C-oborot-r-v:screen-value                             = if x-vat then  string(
                                                                                         oborot-ee         [2] +
                                                                                         oborot-re     [2] +
                                                                                         oborot-es    [2] +
                                                                                         oborot-rs[2]
                                                                                        )
                                                                                         else  string(
                                                                                       ( oborot-ee         [2] +
                                                                                         oborot-re     [2] +
                                                                                         oborot-es    [2] +
                                                                                         oborot-rs[2]) -
                                                                                       ( oborot-ee         [3] +
                                                                                         oborot-re     [3] +
                                                                                         oborot-es    [3] +
                                                                                         oborot-rs[3] )
                                                                                         ).
DISPLAY stream OutStream with FRAME ZAPAS.  DOWN stream   OutStream 1 with FRAME ZAPAS.
   End.
run PRICE-VAT-1 (pp).
END PROCEDURE.
PROCEDURE PRICE-VAT-1 :
define input parameter PP as character no-undo .
if pp = 'Bi' THEN DO:
if line-counter( OutStream ) > page-size( OutStream ) then DO: display STREAM OutStream with frame top-frame. end.
p = p + 1.
if use-column[1] then  c-s-bar-code:screen-value        = ''.
if use-column[2] then  c-gds-zap-artic:screen-value     = ''.
if use-column[3] then  c-gds-zap-gds-name:screen-value  = ''.
if use-column[4] then  c-gds-zap-unit-base:screen-value = ''.
if use-column[5] then  c-gds-type:screen-value          = v-name-type.
if use-column[6]  then C-ostatok-start:screen-value                          = if x-vat then  string( Bi-ostatok-start  [2]                         ) else  string( Bi-ostatok-start  [2]                        - Bi-ostatok-start  [3]                       )  .
if use-column[7]  then C-oborot-ie:screen-value          = if x-vat then  string( Bi-oborot-ie [2]          ) else  string( Bi-oborot-ie [2]         - Bi-oborot-ie [3]        )  .
if use-column[8]  then C-oborot-iv:screen-value          = if x-vat then  string( Bi-oborot-iv [2]          ) else  string( Bi-oborot-iv [2]         - Bi-oborot-iv [3]        )  .
if use-column[9]  then C-oborot-im:screen-value           = if x-vat then  string( Bi-oborot-im  [2]          ) else  string( Bi-oborot-im  [2]         - Bi-oborot-im  [3]        )  .
if use-column[10] then C-oborot-ee:screen-value          = if x-vat then  string( Bi-oborot-ee [2]          ) else  string( Bi-oborot-ee [2]         - Bi-oborot-ee [3]        )  .
if use-column[11] then C-oborot-ev:screen-value          = if x-vat then  string( Bi-oborot-ev [2]          ) else  string( Bi-oborot-ev [2]         - Bi-oborot-ev [3]        )  .
if use-column[12] then C-oborot-em:screen-value           = if x-vat then  string( Bi-oborot-em  [2]          ) else  string( Bi-oborot-em  [2]         - Bi-oborot-em  [3]        )  .
if use-column[13] then C-oborot-we:screen-value          = if x-vat then  string( Bi-oborot-we         [2]  ) else  string( Bi-oborot-we         [2] - Bi-oborot-we         [3])  .
if use-column[14] then C-oborot-es:screen-value     = if x-vat then  string( Bi-oborot-es    [2]  ) else  string( Bi-oborot-es    [2] - Bi-oborot-es    [3])  .
if use-column[15] then C-oborot-rs:screen-value = if x-vat then  string( Bi-oborot-rs[2]  ) else  string( Bi-oborot-rs[2] - Bi-oborot-rs[3])  .
if use-column[16] then C-oborot-re:screen-value      = if x-vat then  string( Bi-oborot-re     [2]  ) else  string( Bi-oborot-re     [2] - Bi-oborot-re     [3])  .
if use-column[17] then C-oborot-ep:screen-value       = if x-vat then  string( Bi-oborot-ep      [2]  ) else  string( Bi-oborot-ep      [2] - Bi-oborot-ep      [3])  .
if use-column[18] then C-oborot-rv:screen-value      = if x-vat then  string( Bi-oborot-rv     [2]  ) else  string( Bi-oborot-rv     [2] - Bi-oborot-rv     [3])  .
if use-column[19] then C-oborot-vt:screen-value                = if x-vat then  string( Bi-oborot-vt               [2]  ) else  string( Bi-oborot-vt               [2] - Bi-oborot-vt               [3])  .
if use-column[20] then C-oborot-ot:screen-value           = if x-vat then  string( Bi-oborot-ot          [2]  ) else  string( Bi-oborot-ot          [2] - Bi-oborot-ot          [3])  .
if use-column[22] then C-ostatok-end:screen-value                            = if x-vat then  string( Bi-ostatok-end                           [2]  ) else  string( Bi-ostatok-end                           [2] - Bi-ostatok-end                           [3])  .
if use-column[25] then C-oborot-ap:screen-value     = if x-vat then  string( Bi-oborot-ap    [2])   else  string( Bi-oborot-ap [2]    - Bi-oborot-ap [3]   )  .
if use-column[26] then C-oborot-pc:screen-value     = if x-vat then  string( Bi-oborot-pc    [2])   else  string( Bi-oborot-pc [2]    - Bi-oborot-pc [3]   )  .
if use-column[27] then C-oborot-r-v:screen-value                             = if x-vat then  string(
                                                                                        Bi-oborot-ee         [2] +
                                                                                        Bi-oborot-re     [2] +
                                                                                        Bi-oborot-es    [2] +
                                                                                        Bi-oborot-rs[2]
                                                                                        )
                                                                                         else  string(
                                                                                       (Bi-oborot-ee         [2] +
                                                                                        Bi-oborot-re     [2] +
                                                                                        Bi-oborot-es    [2] +
                                                                                        Bi-oborot-rs[2]) -
                                                                                       (Bi-oborot-ee         [3] +
                                                                                        Bi-oborot-re     [3] +
                                                                                        Bi-oborot-es    [3] +
                                                                                        Bi-oborot-rs[3] )
                                                                                         ).
DISPLAY stream OutStream with FRAME ZAPAS.  DOWN stream   OutStream 1 with FRAME ZAPAS.
  End.
run PRICE-VAT-2(pp).
END PROCEDURE.
PROCEDURE PRICE-VAT-2 :
define input parameter PP as character no-undo .
if pp = 'Bo' THEN DO:
if line-counter( OutStream ) > page-size( OutStream ) then DO: display STREAM OutStream with frame top-frame. end.
p = p + 1.
if use-column[1] then  c-s-bar-code:screen-value        = ''.
if use-column[2] then  c-gds-zap-artic:screen-value     = ''.
if use-column[3] then  c-gds-zap-gds-name:screen-value  = ''.
if use-column[4] then  c-gds-zap-unit-base:screen-value = ''.
if use-column[5] then  c-gds-type:screen-value          = v-name-type.
if use-column[6]  then C-ostatok-start:screen-value                          = if x-vat then  string( Bo-ostatok-start  [2]                         ) else  string( Bo-ostatok-start  [2]                        - Bo-ostatok-start  [3]                       )  .
if use-column[7]  then C-oborot-ie:screen-value          = if x-vat then  string( Bo-oborot-ie [2]          ) else  string( Bo-oborot-ie [2]         - Bo-oborot-ie [3]        )  .
if use-column[8]  then C-oborot-iv:screen-value          = if x-vat then  string( Bo-oborot-iv [2]          ) else  string( Bo-oborot-iv [2]         - Bo-oborot-iv [3]        )  .
if use-column[9]  then C-oborot-im:screen-value           = if x-vat then  string( Bo-oborot-im  [2]          ) else  string( Bo-oborot-im  [2]         - Bo-oborot-im  [3]        )  .
if use-column[10] then C-oborot-ee:screen-value          = if x-vat then  string( Bo-oborot-ee [2]          ) else  string( Bo-oborot-ee [2]         - Bo-oborot-ee [3]        )  .
if use-column[11] then C-oborot-ev:screen-value          = if x-vat then  string( Bo-oborot-ev [2]          ) else  string( Bo-oborot-ev [2]         - Bo-oborot-ev [3]        )  .
if use-column[12] then C-oborot-em:screen-value           = if x-vat then  string( Bo-oborot-em  [2]          ) else  string( Bo-oborot-em  [2]         - Bo-oborot-em  [3]        )  .
if use-column[13] then C-oborot-we:screen-value          = if x-vat then  string( Bo-oborot-we         [2]  ) else  string( Bo-oborot-we         [2] - Bo-oborot-we         [3])  .
if use-column[14] then C-oborot-es:screen-value     = if x-vat then  string( Bo-oborot-es    [2]  ) else  string( Bo-oborot-es    [2] - Bo-oborot-es    [3])  .
if use-column[15] then C-oborot-rs:screen-value = if x-vat then  string( Bo-oborot-rs[2]  ) else  string( Bo-oborot-rs[2] - Bo-oborot-rs[3])  .
if use-column[16] then C-oborot-re:screen-value      = if x-vat then  string( Bo-oborot-re     [2]  ) else  string( Bo-oborot-re     [2] - Bo-oborot-re     [3])  .
if use-column[17] then C-oborot-ep:screen-value       = if x-vat then  string( Bo-oborot-ep      [2]  ) else  string( Bo-oborot-ep      [2] - Bo-oborot-ep      [3])  .
if use-column[18] then C-oborot-rv:screen-value      = if x-vat then  string( Bo-oborot-rv     [2]  ) else  string( Bo-oborot-rv     [2] - Bo-oborot-rv     [3])  .
if use-column[19] then C-oborot-vt:screen-value                = if x-vat then  string( Bo-oborot-vt               [2]  ) else  string( Bo-oborot-vt               [2] - Bo-oborot-vt               [3])  .
if use-column[20] then C-oborot-ot:screen-value           = if x-vat then  string( Bo-oborot-ot          [2]  ) else  string( Bo-oborot-ot          [2] - Bo-oborot-ot          [3])  .
if use-column[22] then C-ostatok-end:screen-value                            = if x-vat then  string( Bo-ostatok-end                           [2]  ) else  string( Bo-ostatok-end                           [2] - Bo-ostatok-end                           [3])  .
if use-column[25] then C-oborot-ap:screen-value     = if x-vat then  string( Bo-oborot-ap    [2])   else  string( Bo-oborot-ap [2]    - Bo-oborot-ap [3]   )  .
if use-column[26] then C-oborot-pc:screen-value     = if x-vat then  string( Bo-oborot-pc    [2])   else  string( Bo-oborot-pc [2]    - Bo-oborot-pc [3]   )  .
if use-column[27] then C-oborot-r-v:screen-value                             = if x-vat then  string(
                                                                                        Bo-oborot-ee         [2] +
                                                                                        Bo-oborot-re     [2] +
                                                                                        Bo-oborot-es    [2] +
                                                                                        Bo-oborot-rs[2]
                                                                                        )
                                                                                         else  string(
                                                                                       (Bo-oborot-ee         [2] +
                                                                                        Bo-oborot-re     [2] +
                                                                                        Bo-oborot-es    [2] +
                                                                                        Bo-oborot-rs[2]) -
                                                                                       (Bo-oborot-ee         [3] +
                                                                                        Bo-oborot-re     [3] +
                                                                                        Bo-oborot-es    [3] +
                                                                                        Bo-oborot-rs[3] )
                                                                                         ).
DISPLAY stream OutStream with FRAME ZAPAS.  DOWN stream   OutStream 1 with FRAME ZAPAS.
  End.
run PRICE-VAT-3(pp).
END PROCEDURE.
PROCEDURE PRICE-VAT-3 :
define input parameter PP as character no-undo .
if pp =  'B1' THEN DO:
if line-counter( OutStream ) > page-size( OutStream ) then DO: display STREAM OutStream with frame top-frame. end.
p = p + 1.
if use-column[1] then  c-s-bar-code:screen-value        = ''.
if use-column[2] then  c-gds-zap-artic:screen-value     = ''.
if use-column[3] then  c-gds-zap-gds-name:screen-value  = ''.
if use-column[4] then  c-gds-zap-unit-base:screen-value = ''.
if use-column[5] then  c-gds-type:screen-value          = v-name-type.
if use-column[6]  then C-ostatok-start:screen-value                          = if x-vat then  string( B1-ostatok-start  [2]                         ) else  string( B1-ostatok-start  [2]                        - B1-ostatok-start  [3]                       )  .
if use-column[7]  then C-oborot-ie:screen-value          = if x-vat then  string( B1-oborot-ie [2]          ) else  string( B1-oborot-ie [2]         - B1-oborot-ie [3]        )  .
if use-column[8]  then C-oborot-iv:screen-value          = if x-vat then  string( B1-oborot-iv [2]          ) else  string( B1-oborot-iv [2]         - B1-oborot-iv [3]        )  .
if use-column[9]  then C-oborot-im:screen-value           = if x-vat then  string( B1-oborot-im  [2]          ) else  string( B1-oborot-im  [2]         - B1-oborot-im  [3]        )  .
if use-column[10] then C-oborot-ee:screen-value          = if x-vat then  string( B1-oborot-ee [2]          ) else  string( B1-oborot-ee [2]         - B1-oborot-ee [3]        )  .
if use-column[11] then C-oborot-ev:screen-value          = if x-vat then  string( B1-oborot-ev [2]          ) else  string( B1-oborot-ev [2]         - B1-oborot-ev [3]        )  .
if use-column[12] then C-oborot-em:screen-value           = if x-vat then  string( B1-oborot-em  [2]          ) else  string( B1-oborot-em  [2]         - B1-oborot-em  [3]        )  .
if use-column[13] then C-oborot-we:screen-value          = if x-vat then  string( B1-oborot-we         [2]  ) else  string( B1-oborot-we         [2] - B1-oborot-we         [3])  .
if use-column[14] then C-oborot-es:screen-value     = if x-vat then  string( B1-oborot-es    [2]  ) else  string( B1-oborot-es    [2] - B1-oborot-es    [3])  .
if use-column[15] then C-oborot-rs:screen-value = if x-vat then  string( B1-oborot-rs[2]  ) else  string( B1-oborot-rs[2] - B1-oborot-rs[3])  .
if use-column[16] then C-oborot-re:screen-value      = if x-vat then  string( B1-oborot-re     [2]  ) else  string( B1-oborot-re     [2] - B1-oborot-re     [3])  .
if use-column[17] then C-oborot-ep:screen-value       = if x-vat then  string( B1-oborot-ep      [2]  ) else  string( B1-oborot-ep      [2] - B1-oborot-ep      [3])  .
if use-column[18] then C-oborot-rv:screen-value      = if x-vat then  string( B1-oborot-rv     [2]  ) else  string( B1-oborot-rv     [2] - B1-oborot-rv     [3])  .
if use-column[19] then C-oborot-vt:screen-value                = if x-vat then  string( B1-oborot-vt               [2]  ) else  string( B1-oborot-vt               [2] - B1-oborot-vt               [3])  .
if use-column[20] then C-oborot-ot:screen-value           = if x-vat then  string( B1-oborot-ot          [2]  ) else  string( B1-oborot-ot          [2] - B1-oborot-ot          [3])  .
if use-column[22] then C-ostatok-end:screen-value                            = if x-vat then  string( B1-ostatok-end                           [2]  ) else  string( B1-ostatok-end                           [2] - B1-ostatok-end                           [3])  .
if use-column[25] then C-oborot-ap:screen-value     = if x-vat then  string( B1-oborot-ap    [2])   else  string( B1-oborot-ap [2]    - B1-oborot-ap [3]   )  .
if use-column[26] then C-oborot-pc:screen-value     = if x-vat then  string( B1-oborot-pc    [2])   else  string( B1-oborot-pc [2]    - B1-oborot-pc [3]   )  .
if use-column[27] then C-oborot-r-v:screen-value                             = if x-vat then  string(
                                                                                        B1-oborot-ee         [2] +
                                                                                        B1-oborot-re     [2] +
                                                                                        B1-oborot-es    [2] +
                                                                                        B1-oborot-rs[2]
                                                                                        )
                                                                                         else  string(
                                                                                       (B1-oborot-ee         [2] +
                                                                                        B1-oborot-re     [2] +
                                                                                        B1-oborot-es    [2] +
                                                                                        B1-oborot-rs[2]) -
                                                                                       (B1-oborot-ee         [3] +
                                                                                        B1-oborot-re     [3] +
                                                                                        B1-oborot-es    [3] +
                                                                                        B1-oborot-rs[3] )
                                                                                         ).
DISPLAY stream OutStream with FRAME ZAPAS.  DOWN stream   OutStream 1 with FRAME ZAPAS.
  End.
run PRICE-VAT-4(pp).
END PROCEDURE.
PROCEDURE PRICE-VAT-4 :
define input parameter PP as character no-undo .
if pp =   'B2' THEN DO:
if line-counter( OutStream ) > page-size( OutStream ) then DO: display STREAM OutStream with frame top-frame. end.
p = p + 1.
if use-column[1] then  c-s-bar-code:screen-value        = ''.
if use-column[2] then  c-gds-zap-artic:screen-value     = ''.
if use-column[3] then  c-gds-zap-gds-name:screen-value  = ''.
if use-column[4] then  c-gds-zap-unit-base:screen-value = ''.
if use-column[5] then  c-gds-type:screen-value          = v-name-type.
if use-column[6]  then C-ostatok-start:screen-value                          = if x-vat then  string( B2-ostatok-start  [2]                         ) else  string( B2-ostatok-start  [2]                        - B2-ostatok-start  [3]                       )  .
if use-column[7]  then C-oborot-ie:screen-value          = if x-vat then  string( B2-oborot-ie [2]          ) else  string( B2-oborot-ie [2]         - B2-oborot-ie [3]        )  .
if use-column[8]  then C-oborot-iv:screen-value          = if x-vat then  string( B2-oborot-iv [2]          ) else  string( B2-oborot-iv [2]         - B2-oborot-iv [3]        )  .
if use-column[9]  then C-oborot-im:screen-value           = if x-vat then  string( B2-oborot-im  [2]          ) else  string( B2-oborot-im  [2]         - B2-oborot-im  [3]        )  .
if use-column[10] then C-oborot-ee:screen-value          = if x-vat then  string( B2-oborot-ee [2]          ) else  string( B2-oborot-ee [2]         - B2-oborot-ee [3]        )  .
if use-column[11] then C-oborot-ev:screen-value          = if x-vat then  string( B2-oborot-ev [2]          ) else  string( B2-oborot-ev [2]         - B2-oborot-ev [3]        )  .
if use-column[12] then C-oborot-em:screen-value           = if x-vat then  string( B2-oborot-em  [2]          ) else  string( B2-oborot-em  [2]         - B2-oborot-em  [3]        )  .
if use-column[13] then C-oborot-we:screen-value          = if x-vat then  string( B2-oborot-we         [2]  ) else  string( B2-oborot-we         [2] - B2-oborot-we         [3])  .
if use-column[14] then C-oborot-es:screen-value     = if x-vat then  string( B2-oborot-es    [2]  ) else  string( B2-oborot-es    [2] - B2-oborot-es    [3])  .
if use-column[15] then C-oborot-rs:screen-value = if x-vat then  string( B2-oborot-rs[2]  ) else  string( B2-oborot-rs[2] - B2-oborot-rs[3])  .
if use-column[16] then C-oborot-re:screen-value      = if x-vat then  string( B2-oborot-re     [2]  ) else  string( B2-oborot-re     [2] - B2-oborot-re     [3])  .
if use-column[17] then C-oborot-ep:screen-value       = if x-vat then  string( B2-oborot-ep      [2]  ) else  string( B2-oborot-ep      [2] - B2-oborot-ep      [3])  .
if use-column[18] then C-oborot-rv:screen-value      = if x-vat then  string( B2-oborot-rv     [2]  ) else  string( B2-oborot-rv     [2] - B2-oborot-rv     [3])  .
if use-column[19] then C-oborot-vt:screen-value                = if x-vat then  string( B2-oborot-vt               [2]  ) else  string( B2-oborot-vt               [2] - B2-oborot-vt               [3])  .
if use-column[20] then C-oborot-ot:screen-value           = if x-vat then  string( B2-oborot-ot          [2]  ) else  string( B2-oborot-ot          [2] - B2-oborot-ot          [3])  .
if use-column[22] then C-ostatok-end:screen-value                            = if x-vat then  string( B2-ostatok-end                           [2]  ) else  string( B2-ostatok-end                           [2] - B2-ostatok-end                           [3])  .
if use-column[25] then C-oborot-ap:screen-value     = if x-vat then  string( B2-oborot-ap    [2])   else  string( B2-oborot-ap [2]    - B2-oborot-ap [3]   )  .
if use-column[26] then C-oborot-pc:screen-value     = if x-vat then  string( B2-oborot-pc    [2])   else  string( B2-oborot-pc [2]    - B2-oborot-pc [3]   )  .
if use-column[27] then C-oborot-r-v:screen-value                             = if x-vat then  string(
                                                                                        B2-oborot-ee         [2] +
                                                                                        B2-oborot-re     [2] +
                                                                                        B2-oborot-es    [2] +
                                                                                        B2-oborot-rs[2]
                                                                                        )
                                                                                         else  string(
                                                                                       (B2-oborot-ee         [2] +
                                                                                        B2-oborot-re     [2] +
                                                                                        B2-oborot-es    [2] +
                                                                                        B2-oborot-rs[2]) -
                                                                                       (B2-oborot-ee         [3] +
                                                                                        B2-oborot-re     [3] +
                                                                                        B2-oborot-es    [3] +
                                                                                        B2-oborot-rs[3] )
                                                                                         ).
DISPLAY stream OutStream with FRAME ZAPAS.  DOWN stream   OutStream 1 with FRAME ZAPAS.
End.
END PROCEDURE.
procedure pp :
define input parameter ll as integer no-undo .
define input parameter uu as integer no-undo .
define input parameter ff as character no-undo .
End procedure.
procedure find-last-prise-med :
define input parameter p-artic     like ub.goods.artic no-undo .
define input parameter p-prod-type like ub.goods.prod-type no-undo .
define input parameter p-prod-code like ub.goods.prod-code no-undo .
define input parameter p-host-code like ub.gds-obj.host-code no-undo .
define output parameter  p-price   like ub.gds-obj.last-base no-undo .
define buffer p-gds-obj   for  ub.gds-obj .
define buffer buf_trn-doc for  ub.trn-doc .
define variable v-fact-order as decimal no-undo .
p-price = 0 .
  define variable v-in-date as date      no-undo .
  define variable fl as logical no-undo .
  fl = yes.
  v-fact-order = 0 .
  for each tt-obj-list no-lock break by tt-obj-list.obj-type by tt-obj-list.obj-code
  :
    find first p-gds-obj no-lock
      where p-gds-obj.artic     = p-artic         and
              p-gds-obj.prod-type = p-prod-type     and
              p-gds-obj.prod-code = p-prod-code     and
              p-gds-obj.obj-code  = tt-obj-list.obj-code and
              p-gds-obj.obj-type  = tt-obj-list.obj-type
      no-error .
    if available p-gds-obj then do:
    if p-gds-obj.in-date = ?  then next .
    if fl = yes then do:
      assign
        v-in-date = p-gds-obj.in-date
        p-price   =  if tPrintRubl then  p-gds-obj.last-rubl else  p-gds-obj.last-base
        fl = no
    .
     find first buf_trn-doc no-lock  where buf_trn-doc.doc-code = p-gds-obj.in-code no-error  .
     if available buf_trn-doc  then  v-fact-order = buf_trn-doc.fact-order .
    end.
      if p-gds-obj.in-date >= v-in-date   then do:
         if p-gds-obj.in-date = v-in-date then do:
            find first buf_trn-doc no-lock  where buf_trn-doc.doc-code = p-gds-obj.in-code no-error .
            if available buf_trn-doc  then
                if buf_trn-doc.fact-order >  v-fact-order   then do:
                  assign
                    v-fact-order = buf_trn-doc.fact-order
                    p-price   =  if tPrintRubl then  p-gds-obj.last-rubl else  p-gds-obj.last-base
                    v-in-date =   p-gds-obj.in-date
                  .
                end.
         end.
         else do:
          find first buf_trn-doc no-lock  where buf_trn-doc.doc-code = p-gds-obj.in-code no-error .
          if available buf_trn-doc  then
              assign
                p-price   =    if tPrintRubl then  p-gds-obj.last-rubl else  p-gds-obj.last-base
                v-in-date =    p-gds-obj.in-date
                v-fact-order = buf_trn-doc.fact-order .
              .
          end.
        if p-price = ? then   p-price  = 0 .
      end.
    end.
  End .
  if p-price = ? then   p-price  = 0 .
end procedure.
procedure find-mediator :
define input  parameter c-host-code as integer no-undo .
define input  parameter p-Showmediatr as logical no-undo .
define output parameter p-host-code as integer no-undo .
define output parameter p-flag as logical no-undo .
define buffer b-sysconf  for ub.sysconf.
 p-host-code = 0 .
 p-flag  = true .
    if p-Showmediatr = true then do:
    find first ub.sysconf where ub.sysconf.avrg-price = true no-lock no-error .
          if avail ub.sysconf then DO :
            p-host-code = ub.sysconf.host-code.
            if tPrintRubl = false then do:
                  find first b-sysconf where b-sysconf.host-code = c-host-code no-lock no-error .
                        if  ub.sysconf.base-code <> b-sysconf.base-code then DO:
                              p-flag  = false  .
                              message "Базовая валюта посредника и базовая валюта текущей фирмы не совпадает . Нельзя получить отчет в валюте !"
                              view-as alert-box error.
                        end.
            end.
          end.
          for each ub.shop no-lock where ub.shop.host-code = p-host-code :
              create tt-obj-list no-error .
              assign tt-obj-list.obj-type = 'маг':U
                     tt-obj-list.obj-code = ub.shop.obj-code no-error .
          end.
          for each ub.store no-lock where ub.store.host-code = p-host-code :
              create tt-obj-list no-error .
              assign tt-obj-list.obj-type = 'скл':U
                     tt-obj-list.obj-code = ub.store.obj-code no-error .
          end.
    End.
 End procedure .
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
          Quantity = Quantity +  buff-stk-line.fact-qnty
          Coast_R  = Coast_R  +  buff-stk-line.sum-rubl
          Coast_V  = Coast_V  +  buff-stk-line.sum-base
          VAT_R    = VAT_R    +  buff-stk-line.VAT-rubl
          VAT_V    = VAT_V    +  buff-stk-line.VAT-base
          SLT_R    = SLT_R    +  buff-stk-line.SLT-rubl
          SLT_V    = SLT_V    +  buff-stk-line.SLT-base
          other_R  = other_R  +  buff-stk-line.other-rubl
          other_V  = other_V  +  buff-stk-line.other-base
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
procedure run2 :
    case select-good :
        when 1  then do:
    define buffer buf_obj-list17 for obj-list.
  for each buf_obj-list17 no-lock :
      if xtog-obj and  not (buf_obj-list17.obj-type = x-store-type  and
                            buf_obj-list17.obj-code = x-store-code )
      then next.
        for  each gds-obj   where
                            gds-obj.obj-type = buf_obj-list17.obj-type    and
                            gds-obj.obj-code = buf_obj-list17.obj-code
                            and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
                            no-lock ,
        first goods where gds-obj.gds-code  = goods.gds-code
                            no-lock :
            if not can-find(first temp-gds-list where temp-gds-list.gds-code = gds-obj.gds-code) then do:
                create temp-gds-list.
                assign
                  temp-gds-list.prod-code = gds-obj.prod-code
                  temp-gds-list.grp-name  = ""
                  temp-gds-list.gds-code  = gds-obj.gds-code
                  temp-gds-list.artic     = gds-obj.artic
                  temp-gds-list.gds-name  = goods.gds-name
                  .
                  temp-gds-list.grp-name  = n-lavel(input gds-obj.grp-name, input xlavel )
                  .
            end.
        end.
 end.
  for each temp-gds-list no-lock
    , first goods  where goods.gds-code  = temp-gds-list.gds-code no-lock
      break
        by  temp-gds-list.grp-name
        by temp-gds-list.gds-name :
        str = n-lavel(input goods.grp-name, input xlavel ) no-error .
find clients where clients.obj-type = goods.prod-type and
                   clients.obj-code = goods.prod-code no-lock .
  assign
      gds-zap-unit-base  = goods.unit-base
      gds-zap-prt-root   = goods.prt-root
      gds-zap-prod-type  = goods.prod-type
      gds-zap-prod-code  = goods.prod-code
      gds-zap-artic      = goods.artic
      gds-zap-type       = goods.gds-type
      gds-zap-grp-name   = goods.grp-name
      gds-zap-b-code     = goods.gds-code
      gds-zap-prod-name  = clients.obj-name .
  if g#gds-engl then
      assign gds-zap-gds-name = goods.engl-name.
  else
      assign gds-zap-gds-name = goods.gds-name.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  gds-zap-b-code
  ,input  ?
  ,output v-bar-code
  )  .
  s-bar-code = string (v-bar-code,"999999999").
  run foreach in this-procedure .
    if  first-of ( temp-gds-list.grp-name )  then do:
        fr = true .
        l-stroka = "ГРУППА : " + str .
        temp-str = l-stroka.
    end.
   run display-line in this-procedure .
   if last-of( temp-gds-list.grp-name ) then do:
      s-bar-code = "Итого по " .
      gds-zap-artic = substring(str,1,16) .
      gds-zap-gds-name = substring(str,17,250) .
      run display-b1 in this-procedure .
      run clear-b1 in this-procedure .
      run clear-b2 in this-procedure .
   end.
  end.
   end.
        when 2  then do:
    define buffer buf_obj-list18 for obj-list.
  for each buf_obj-list18 no-lock :
      if xtog-obj and  not (buf_obj-list18.obj-type = x-store-type  and
                            buf_obj-list18.obj-code = x-store-code )
      then next.
        for  each gds-obj   where
                            gds-obj.obj-type = buf_obj-list18.obj-type    and
                            gds-obj.obj-code = buf_obj-list18.obj-code
                            and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
                              no-lock ,
        first  tmp#grp
              where  gds-obj.grp-name   begins tmp#grp.grp-name
                  no-lock ,
        first goods where gds-obj.gds-code  = goods.gds-code
                            no-lock :
            if not can-find(first temp-gds-list where temp-gds-list.gds-code = gds-obj.gds-code) then do:
                create temp-gds-list.
                assign
                  temp-gds-list.prod-code = gds-obj.prod-code
                  temp-gds-list.grp-name  = ""
                  temp-gds-list.gds-code  = gds-obj.gds-code
                  temp-gds-list.artic     = gds-obj.artic
                  temp-gds-list.gds-name  = goods.gds-name
                  .
                  temp-gds-list.grp-name  = n-lavel(input gds-obj.grp-name, input xlavel )
                  .
            end.
        end.
 end.
  for each temp-gds-list no-lock
    , first goods  where goods.gds-code  = temp-gds-list.gds-code no-lock
      break
        by  temp-gds-list.grp-name
        by temp-gds-list.gds-name :
        str = n-lavel(input goods.grp-name, input xlavel ) no-error .
find clients where clients.obj-type = goods.prod-type and
                   clients.obj-code = goods.prod-code no-lock .
  assign
      gds-zap-unit-base  = goods.unit-base
      gds-zap-prt-root   = goods.prt-root
      gds-zap-prod-type  = goods.prod-type
      gds-zap-prod-code  = goods.prod-code
      gds-zap-artic      = goods.artic
      gds-zap-type       = goods.gds-type
      gds-zap-grp-name   = goods.grp-name
      gds-zap-b-code     = goods.gds-code
      gds-zap-prod-name  = clients.obj-name .
  if g#gds-engl then
      assign gds-zap-gds-name = goods.engl-name.
  else
      assign gds-zap-gds-name = goods.gds-name.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  gds-zap-b-code
  ,input  ?
  ,output v-bar-code
  )  .
  s-bar-code = string (v-bar-code,"999999999").
  run foreach in this-procedure .
    if  first-of ( temp-gds-list.grp-name )  then do:
        fr = true .
        l-stroka = "ГРУППА : " + str .
        temp-str = l-stroka.
    end.
   run display-line in this-procedure .
   if last-of( temp-gds-list.grp-name ) then do:
      s-bar-code = "Итого по " .
      gds-zap-artic = substring(str,1,16) .
      gds-zap-gds-name = substring(str,17,250) .
      run display-b1 in this-procedure .
      run clear-b1 in this-procedure .
      run clear-b2 in this-procedure .
   end.
  end.
   end.
        when 3 then do:
    define buffer buf_obj-list19 for obj-list.
  for each buf_obj-list19 no-lock :
      if xtog-obj and  not (buf_obj-list19.obj-type = x-store-type  and
                            buf_obj-list19.obj-code = x-store-code )
      then next.
        for  each gds-obj   where
                  gds-obj.obj-type = buf_obj-list19.obj-type    and
                  gds-obj.obj-code = buf_obj-list19.obj-code
                  and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
                    no-lock ,
        first g#cli
              where    g#cli.obj-code = gds-obj.prod-code
              and      g#cli.obj-type = gds-obj.prod-type
                       no-lock ,
        first goods where goods.gds-code = gds-obj.gds-code
                            no-lock :
            if not can-find ( first temp-gds-list where temp-gds-list.gds-code = gds-obj.gds-code) then do:
                create temp-gds-list.
                assign
                  temp-gds-list.prod-code = gds-obj.prod-code
                  temp-gds-list.grp-name  = ""
                  temp-gds-list.gds-code  = gds-obj.gds-code
                  temp-gds-list.artic     = gds-obj.artic
                  temp-gds-list.gds-name  = goods.gds-name
                  .
                  temp-gds-list.grp-name  = n-lavel(input gds-obj.grp-name, input xlavel )
                  .
            end.
        end.
 end.
  for each temp-gds-list no-lock
    , first goods     where goods.gds-code     = temp-gds-list.gds-code no-lock
      break
        by  temp-gds-list.grp-name
        by temp-gds-list.gds-name :
        str = n-lavel(input goods.grp-name, input xlavel ) no-error .
find clients where clients.obj-type = goods.prod-type and
                   clients.obj-code = goods.prod-code no-lock .
  assign
      gds-zap-unit-base  = goods.unit-base
      gds-zap-prt-root   = goods.prt-root
      gds-zap-prod-type  = goods.prod-type
      gds-zap-prod-code  = goods.prod-code
      gds-zap-artic      = goods.artic
      gds-zap-type       = goods.gds-type
      gds-zap-grp-name   = goods.grp-name
      gds-zap-b-code     = goods.gds-code
      gds-zap-prod-name  = clients.obj-name .
  if g#gds-engl then
      assign gds-zap-gds-name = goods.engl-name.
  else
      assign gds-zap-gds-name = goods.gds-name.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  gds-zap-b-code
  ,input  ?
  ,output v-bar-code
  )  .
  s-bar-code = string (v-bar-code,"999999999").
  run foreach in this-procedure .
    if  first-of ( temp-gds-list.grp-name )  then do:
        fr = true .
        l-stroka = "ГРУППА : " + str .
        temp-str = l-stroka.
    end.
   run display-line in this-procedure .
   if last-of( temp-gds-list.grp-name ) then do:
      s-bar-code = "Итого по " .
      gds-zap-artic = substring(str,1,16) .
      gds-zap-gds-name = substring(str,17,250) .
      run display-b1 in this-procedure .
      run clear-b1 in this-procedure .
      run clear-b2 in this-procedure .
   end.
  end.
   end.
        otherwise do:
    define buffer buf_obj-list20 for obj-list.
  for each buf_obj-list20 no-lock :
      if xtog-obj and  not (buf_obj-list20.obj-type = x-store-type  and
                            buf_obj-list20.obj-code = x-store-code )
      then next.
        for  each gds-obj   where
                            gds-obj.obj-type = buf_obj-list20.obj-type    and
                            gds-obj.obj-code = buf_obj-list20.obj-code
                            and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
                            no-lock ,
        first gds-list where gds-obj.gds-code  = gds-list.gds-code
                            no-lock :
            if not can-find(first temp-gds-list where temp-gds-list.gds-code = gds-obj.gds-code) then do:
                create temp-gds-list.
                assign
                  temp-gds-list.prod-code = gds-obj.prod-code
                  temp-gds-list.grp-name  = ""
                  temp-gds-list.gds-code  = gds-obj.gds-code
                  temp-gds-list.artic     = gds-obj.artic
                  temp-gds-list.gds-name  = gds-list.gds-name
                  .
                  temp-gds-list.grp-name  = n-lavel(input gds-obj.grp-name, input xlavel )
                  .
            end.
        end.
 end.
  for each temp-gds-list no-lock
    , first gds-list  where gds-list.gds-code  = temp-gds-list.gds-code no-lock
      break
        by  temp-gds-list.grp-name
        by gds-list.gds-name :
        str = n-lavel(input gds-list.grp-name, input xlavel ) no-error .
find clients where clients.obj-type = gds-list.prod-type and
                   clients.obj-code = gds-list.prod-code no-lock .
  assign
      gds-zap-unit-base  = gds-list.unit-base
      gds-zap-prt-root   = gds-list.prt-root
      gds-zap-prod-type  = gds-list.prod-type
      gds-zap-prod-code  = gds-list.prod-code
      gds-zap-artic      = gds-list.artic
      gds-zap-type       = gds-list.gds-type
      gds-zap-grp-name   = gds-list.grp-name
      gds-zap-b-code     = gds-list.gds-code
      gds-zap-prod-name  = clients.obj-name .
  if g#gds-engl then
      assign gds-zap-gds-name = gds-list.engl-name.
  else
      assign gds-zap-gds-name = gds-list.gds-name.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  gds-zap-b-code
  ,input  ?
  ,output v-bar-code
  )  .
  s-bar-code = string (v-bar-code,"999999999").
  run foreach in this-procedure .
    if  first-of ( temp-gds-list.grp-name )  then do:
        fr = true .
        l-stroka = "ГРУППА : " + str .
        temp-str = l-stroka.
    end.
   run display-line in this-procedure .
   if last-of( temp-gds-list.grp-name ) then do:
      s-bar-code = "Итого по " .
      gds-zap-artic = substring(str,1,16) .
      gds-zap-gds-name = substring(str,17,250) .
      run display-b1 in this-procedure .
      run clear-b1 in this-procedure .
      run clear-b2 in this-procedure .
   end.
  end.
        end.
    end case.
end procedure.
PROCEDURE ob-line-stk  :
define input  parameter x-store-code     like ub.clients.obj-code      no-undo.
define input  parameter x-store-type     like ub.clients.obj-type      no-undo.
define INPUT  parameter x-artic          like ub.stk-line.artic        no-undo.
define INPUT  parameter x-prod-code      like ub.stk-line.prod-code    no-undo.
define INPUT  parameter x-prod-type      like ub.stk-line.prod-type    no-undo.
define INPUT  parameter x-Fact-order-1   like ub.stk-line.Fact-order   no-undo.
define INPUT  parameter x-Fact-order-2   like ub.stk-line.Fact-order   no-undo.
define input  parameter x-sum-type       like ub.stk-line.sum-type     no-undo.
define input  parameter x-cat-id         like ub.stk-line.cat-id       no-undo.
define input  parameter x-ext-doc-type   like ub.ot-line.ext-doc-type  no-undo.
define input  parameter xTog-obj         as log                     no-undo.
define input  parameter xi               as int                     no-undo.
define output  parameter Quntity         like ub.stk-line.fact-qnty   no-undo.
define output  parameter sum             like ub.stk-line.sum-base    no-undo.
define output  parameter vat             like ub.stk-line.sum-base    no-undo.
define output  parameter slt             like ub.stk-line.sum-base    no-undo.
define output  parameter disc            like ub.stk-line.sum-base    no-undo.
define variable  First-qnty   like ub.stk-line.fact-qnty   no-undo.
define variable  Second-qnty  like ub.stk-line.fact-qnty   no-undo.
define variable  First-sum   like ub.stk-line.sum-base   no-undo.
define variable  Second-sum  like ub.stk-line.sum-base   no-undo.
define variable  First-vat   like ub.stk-line.sum-base   no-undo.
define variable  Second-vat  like ub.stk-line.sum-base   no-undo.
define variable  First-slt   like ub.stk-line.sum-base   no-undo.
define variable  Second-slt  like ub.stk-line.sum-base   no-undo.
define variable  First-disc   like ub.stk-line.sum-base   no-undo.
define variable  Second-disc  like ub.stk-line.sum-base   no-undo.
define buffer stk-line2 for ub.stk-line .
if x-Fact-order-2 < x-Fact-order-1 Then x-Fact-order-2 = x-Fact-order-1.
 Assign
   First-qnty  = 0
   Second-qnty = 0
   Quntity     = 0
   First-sum  = 0
   Second-sum = 0
   sum        = 0
   First-vat  = 0
   Second-vat = 0
   vat        = 0
   First-slt   = 0
   Second-slt  = 0
   slt         = 0
   First-disc  = 0
   Second-disc = 0
   disc        = 0
  .
  For each obj-list  no-lock :
   if  xTog-obj THEN
       if   NOT(    x-store-type     = obj-list.obj-type
            AND    x-store-code      = obj-list.obj-code ) Then NEXT.
   FOR each temp#sum-type where temp#sum-type.xi = xi no-lock :
      find last ub.stk-line no-lock
        where ub.stk-line.obj-type   = obj-list.obj-type
          and ub.stk-line.obj-code   = obj-list.obj-code
          and ub.stk-line.artic      = x-artic
          and ub.stk-line.prod-type  = x-prod-type
          and ub.stk-line.prod-code  = x-prod-code
          and ub.stk-line.sum-type   = temp#sum-type.sum-type
          and ub.stk-line.cat-id     = '##,##':U
          and ub.stk-line.fact-order <= x-fact-order-1
        use-index category
        no-error .
      if available ub.stk-line then do:
        assign
          First-qnty = First-qnty + ub.stk-line.fact-qnty
          First-sum  = First-sum  + (if tprintrubl then ub.stk-line.sum-rubl   else ub.stk-line.sum-base  )
          First-vat  = First-vat  + (if tprintrubl then ub.stk-line.vat-rubl   else ub.stk-line.vat-base  )
          First-disc = First-disc + (if tprintrubl then ub.stk-line.other-rubl else ub.stk-line.other-base )
          First-slt  = First-slt  + (if tprintrubl then ub.stk-line.slt-rubl   else ub.stk-line.slt-base   )
        .
      end.
      find last stk-line2 no-lock
        where stk-line2.obj-code   = obj-list.obj-code
          and stk-line2.obj-type   = obj-list.obj-type
          and stk-line2.artic      = x-artic
          and stk-line2.prod-type  = x-prod-type
          and stk-line2.prod-code  = x-prod-code
          and stk-line2.sum-type   = temp#sum-type.sum-type
          and stk-line2.cat-id     = '##,##':U
          and stk-line2.fact-order <= x-fact-order-2
        use-index category
        no-error .
      if available stk-line2 then do:
        assign
          Second-qnty = Second-qnty + Stk-line2.fact-qnty
          Second-sum  = Second-sum  + (if tprintrubl then stk-line2.sum-rubl else stk-line2.sum-base    )
          Second-vat  = Second-vat  + (if tprintrubl then stk-line2.vat-rubl else stk-line2.vat-base    )
          second-disc = second-disc + (if tprintrubl then stk-line2.other-rubl else stk-line2.other-base )
          second-slt  = second-slt  + (if tprintrubl then stk-line2.slt-rubl   else stk-line2.slt-base   )
        .
      end.
   end.
 end.
 Assign
   Quntity = Second-qnty - first-qnty
   sum     = Second-sum  - first-sum
   vat     = Second-vat  - first-vat
   slt     = Second-slt  - first-slt
   disc    = Second-disc  - first-disc
   .
END PROCEDURE.
procedure create-pul:
end procedure.
procedure calc-ms-wt :
define input        parameter p-oborot-num      as decimal   no-undo .
define input        parameter p-gds-wt-ms-base  as decimal   no-undo .
define input-output parameter p-oborot          as decimal   no-undo .
define input-output parameter p-bi-oborot       as decimal   no-undo .
define input-output parameter p-bo-oborot       as decimal   no-undo .
define input-output parameter p-b1-oborot       as decimal   no-undo .
define input-output parameter p-b2-oborot       as decimal   no-undo .
do
on error undo, return error return-value
:
if p-is-petrol = true then return .
  assign
    p-oborot    = p-oborot-num * p-gds-wt-ms-base
    p-bi-oborot = p-bi-oborot + p-oborot
    p-bo-oborot = p-bo-oborot + p-oborot
    p-b1-oborot = p-b1-oborot + p-oborot
    p-b2-oborot = p-b2-oborot + p-oborot
  .
end.
end procedure.
procedure calc-pt-ob :
define input  parameter p-ext-doc-type  as character no-undo .
define input  parameter x-store-type as character no-undo .
define input  parameter x-store-code as integer   no-undo .
define input  parameter p-artic         as character no-undo .
define input  parameter p-prod-type     as character no-undo .
define input  parameter p-prod-code     as integer   no-undo .
define input-output parameter p-oborot          as decimal   no-undo .
define input-output parameter p-bi-oborot       as decimal   no-undo .
define input-output parameter p-bo-oborot       as decimal   no-undo .
define input-output parameter p-b1-oborot       as decimal   no-undo .
define input-output parameter p-b2-oborot       as decimal   no-undo .
  do
  on error undo, return error return-value
  :
define variable v-oborot as decimal   no-undo .
define buffer buf_inv-line for ub.inv-line  .
define buffer buf_doc-line for ub.doc-line  .
define buffer buf1_obj-list for obj-list .
v-oborot = 0 .
if p-is-petrol = false   then return .
  for each buf1_obj-list no-lock :
   if  xtog-obj then
       if   not(x-store-type     = buf1_obj-list.obj-type
            and x-store-code     = buf1_obj-list.obj-code ) then next.
    for each buf_doc-line  no-lock where
          buf_doc-line.obj-type     = buf1_obj-list.obj-type and
          buf_doc-line.obj-code     = buf1_obj-list.obj-code and
          buf_doc-line.artic        = p-artic and
          buf_doc-line.prod-type    = p-prod-type and
          buf_doc-line.prod-code    = p-prod-code and
          buf_doc-line.ext-doc-type = p-ext-doc-type and
          buf_doc-line.status_      = 'факт':U        and
          buf_doc-line.fact-order   <= fact-order-2  and
          buf_doc-line.fact-order   >= fact-order-1
          :
          for each buf_inv-line no-lock where
                  buf_inv-line.doc-code  =  buf_doc-line.doc-code  and
                  buf_inv-line.artic     =  buf_doc-line.artic     and
                  buf_inv-line.prod-type =  buf_doc-line.prod-type and
                  buf_inv-line.prod-code =  buf_doc-line.prod-code
                  :
                  if p-ext-doc-type = 'vt':U  then v-oborot = v-oborot + buf_doc-line.cli-qnty .
                      else do:
                      if p-ext-doc-type = 'we':U    or
                         p-ext-doc-type = 'ee':U    or
                         p-ext-doc-type = 'ev':U    or
                         p-ext-doc-type = 'ep':U or
                         p-ext-doc-type = 'em':U     or
                         p-ext-doc-type = 'wm':U     or
                         p-ext-doc-type = 'es':U   then
                           v-oborot = v-oborot - buf_inv-line.wast-cli-qnty .
                           else v-oborot = v-oborot + buf_inv-line.wast-cli-qnty .
                      end.
          end.
    end.
    assign
      p-oborot    = v-oborot
      p-bi-oborot = p-bi-oborot + p-oborot
      p-bo-oborot = p-bo-oborot + p-oborot
      p-b1-oborot = p-b1-oborot + p-oborot
      p-b2-oborot = p-b2-oborot + p-oborot
    .
end.
end.
end procedure.
