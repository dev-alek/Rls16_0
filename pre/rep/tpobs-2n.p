block-level on error undo, throw.
define  input parameter  p-type-pr as character no-undo .
define  input parameter x-store-code like ub.clients.obj-code   no-undo.
define  input parameter x-store-type like ub.clients.obj-type   no-undo.
define  input parameter x-base-type  like ub.currency.curr-abbr no-undo.
define  input parameter x-base-code  like ub.currency.curr-code no-undo.
define  input parameter xclassify    as char    no-undo.
define  input parameter xsorttype    as char    no-undo.
define  input parameter xsumsonly    as log     no-undo.
define  input parameter xshowzero    as log     no-undo.
define  input parameter xshowzero-2  as log     no-undo.
define  input parameter xtog-obj     as log     no-undo.
define  input parameter xtog-lavel   as log     no-undo.
define  input parameter xvar-lavel   as int     no-undo.
define  input parameter vat-cost     as logical no-undo .
define  input parameter vat-crsa     as logical no-undo .
define  input parameter vat-sale     as logical no-undo .
define  input parameter p-tpsy       as logical   no-undo .
define  input parameter p-type-tpsy-goods as integer   no-undo .
define buffer goods   for ub.goods  .
define buffer gds-obj for ub.gds-obj  .
define buffer clients for ub.clients  .
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Оборотная ведомость отчет (по типу приобретения)".
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
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
def var vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
def var vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define stream ahtlog .
define temp-table temp-aht-ot-tot no-undo like ub.aht-ot-tot .
define temp-table temp-aht-ot-line no-undo like ub.aht-ot-line .
define temp-table temp-aht-stk-tot no-undo like ub.aht-stk-tot .
define temp-table temp-aht-stk-line no-undo like ub.aht-stk-line .
procedure aht_get-sum-type :
  define input  parameter p-aht-type        as character no-undo .
  define output parameter p-allsum-sum-type as character no-undo .
  do
  on error undo, return error return-value
  :
    case p-aht-type :
      when 'r':U then do:
        assign
          p-allsum-sum-type = 'сумма_по_выкупу_со_знаком':U
        .
      end.
      when 'c':U then do:
        assign
          p-allsum-sum-type = 'сумма_по_консигнации_закупка_со_знаком':U
        .
      end.
      when 'b':U then do:
        assign
          p-allsum-sum-type = 'сумма_по_консигнации_выгода_со_знаком':U
        .
      end.
      when 's':U then do:
        assign
          p-allsum-sum-type = 'сумма_по_ответственному_хранению_со_знаком':U
        .
      end.
      when 'o':U then do:
        assign
          p-allsum-sum-type = 'сумма_по_старой_консигнации_со_знаком':U
        .
      end.
      when 'v':U then do:
        assign
          p-allsum-sum-type = 'сумма_по_услуге_со_знаком':U
        .
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info17 skip
          "Неизвестное значение типа приобретения" skip
          "Тип приобретения" p-aht-type skip
          view-as alert-box error .
        undo, return error .
      end.
    end.
  end.
end procedure.
procedure aht_get-stk-sum-type :
  define input  parameter p-ot-sum-type      as character no-undo .
  define input  parameter p-ext-doc-type     as character no-undo .
  define output parameter p-stk-ext-sum-type as character no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-stk-ext-sum-type = p-ot-sum-type + p-ext-doc-type
    .
  end.
end procedure.
procedure aht_store-ot-line :
  define input  parameter p-doc-code       as character no-undo .
  define input  parameter p-gds-code       as integer   no-undo .
  define input  parameter p-sum-type       as character no-undo .
  define input  parameter p-ext-doc-type   as character no-undo .
  define input  parameter p-obj-type       as character no-undo .
  define input  parameter p-obj-code       as integer   no-undo .
  define input  parameter p-fact-order     as decimal   no-undo .
  define input  parameter p-fact-qnty      as decimal   no-undo .
          define input  parameter p-cost-sum-base       as decimal   no-undo .     define input  parameter p-cost-sum-rubl       as decimal   no-undo .     define input  parameter p-cost-vat-base       as decimal   no-undo .     define input  parameter p-cost-vat-rubl       as decimal   no-undo .     define input  parameter p-cost-slt-base       as decimal   no-undo .     define input  parameter p-cost-slt-rubl       as decimal   no-undo .     define input  parameter p-cost-road-tax-base  as decimal   no-undo .     define input  parameter p-cost-road-tax-rubl  as decimal   no-undo .     define input  parameter p-cost-excise-base    as decimal   no-undo .     define input  parameter p-cost-excise-rubl    as decimal   no-undo .     define input  parameter p-cost-transport-base as decimal   no-undo .     define input  parameter p-cost-transport-rubl as decimal   no-undo .     define input  parameter p-cost-other-base     as decimal   no-undo .     define input  parameter p-cost-other-rubl     as decimal   no-undo .     define input  parameter p-cost-discnt-base    as decimal   no-undo .     define input  parameter p-cost-discnt-rubl    as decimal   no-undo .
          define input  parameter p-crsa-sum-base       as decimal   no-undo .     define input  parameter p-crsa-sum-rubl       as decimal   no-undo .     define input  parameter p-crsa-vat-base       as decimal   no-undo .     define input  parameter p-crsa-vat-rubl       as decimal   no-undo .     define input  parameter p-crsa-slt-base       as decimal   no-undo .     define input  parameter p-crsa-slt-rubl       as decimal   no-undo .     define input  parameter p-crsa-road-tax-base  as decimal   no-undo .     define input  parameter p-crsa-road-tax-rubl  as decimal   no-undo .     define input  parameter p-crsa-excise-base    as decimal   no-undo .     define input  parameter p-crsa-excise-rubl    as decimal   no-undo .     define input  parameter p-crsa-transport-base as decimal   no-undo .     define input  parameter p-crsa-transport-rubl as decimal   no-undo .     define input  parameter p-crsa-other-base     as decimal   no-undo .     define input  parameter p-crsa-other-rubl     as decimal   no-undo .     define input  parameter p-crsa-discnt-base    as decimal   no-undo .     define input  parameter p-crsa-discnt-rubl    as decimal   no-undo .
          define input  parameter p-sale-sum-base       as decimal   no-undo .     define input  parameter p-sale-sum-rubl       as decimal   no-undo .     define input  parameter p-sale-vat-base       as decimal   no-undo .     define input  parameter p-sale-vat-rubl       as decimal   no-undo .     define input  parameter p-sale-slt-base       as decimal   no-undo .     define input  parameter p-sale-slt-rubl       as decimal   no-undo .     define input  parameter p-sale-road-tax-base  as decimal   no-undo .     define input  parameter p-sale-road-tax-rubl  as decimal   no-undo .     define input  parameter p-sale-excise-base    as decimal   no-undo .     define input  parameter p-sale-excise-rubl    as decimal   no-undo .     define input  parameter p-sale-transport-base as decimal   no-undo .     define input  parameter p-sale-transport-rubl as decimal   no-undo .     define input  parameter p-sale-other-base     as decimal   no-undo .     define input  parameter p-sale-other-rubl     as decimal   no-undo .     define input  parameter p-sale-discnt-base    as decimal   no-undo .     define input  parameter p-sale-discnt-rubl    as decimal   no-undo .
  define buffer buf_temp-aht-ot-line for temp-aht-ot-line .
  do
  on error undo, return error return-value
  :
    find first buf_temp-aht-ot-line
      where buf_temp-aht-ot-line.doc-code  = p-doc-code
        and buf_temp-aht-ot-line.gds-code  = p-gds-code
        and buf_temp-aht-ot-line.sum-type  = p-sum-type
      no-error .
    if not available buf_temp-aht-ot-line then do:
      create buf_temp-aht-ot-line .
      assign
        buf_temp-aht-ot-line.doc-code     = p-doc-code
        buf_temp-aht-ot-line.gds-code     = p-gds-code
        buf_temp-aht-ot-line.sum-type     = p-sum-type
        buf_temp-aht-ot-line.ext-doc-type = p-ext-doc-type
        buf_temp-aht-ot-line.obj-type     = p-obj-type
        buf_temp-aht-ot-line.obj-code     = p-obj-code
        buf_temp-aht-ot-line.fact-order   = p-fact-order
      .
    end.
    assign
      buf_temp-aht-ot-line.fact-qnty = buf_temp-aht-ot-line.fact-qnty + p-fact-qnty
                                                      buf_temp-aht-ot-line.cost-sum-base       = buf_temp-aht-ot-line.cost-sum-base       + p-cost-sum-base            buf_temp-aht-ot-line.cost-sum-rubl       = buf_temp-aht-ot-line.cost-sum-rubl       + p-cost-sum-rubl            buf_temp-aht-ot-line.cost-vat-base       = buf_temp-aht-ot-line.cost-vat-base       + p-cost-vat-base            buf_temp-aht-ot-line.cost-vat-rubl       = buf_temp-aht-ot-line.cost-vat-rubl       + p-cost-vat-rubl            buf_temp-aht-ot-line.cost-slt-base       = buf_temp-aht-ot-line.cost-slt-base       + p-cost-slt-base            buf_temp-aht-ot-line.cost-slt-rubl       = buf_temp-aht-ot-line.cost-slt-rubl       + p-cost-slt-rubl            buf_temp-aht-ot-line.cost-road-tax-base  = buf_temp-aht-ot-line.cost-road-tax-base  + p-cost-road-tax-base       buf_temp-aht-ot-line.cost-road-tax-rubl  = buf_temp-aht-ot-line.cost-road-tax-rubl  + p-cost-road-tax-rubl       buf_temp-aht-ot-line.cost-excise-base    = buf_temp-aht-ot-line.cost-excise-base    + p-cost-excise-base         buf_temp-aht-ot-line.cost-excise-rubl    = buf_temp-aht-ot-line.cost-excise-rubl    + p-cost-excise-rubl         buf_temp-aht-ot-line.cost-transport-base = buf_temp-aht-ot-line.cost-transport-base + p-cost-transport-base      buf_temp-aht-ot-line.cost-transport-rubl = buf_temp-aht-ot-line.cost-transport-rubl + p-cost-transport-rubl      buf_temp-aht-ot-line.cost-other-base     = buf_temp-aht-ot-line.cost-other-base     + p-cost-other-base          buf_temp-aht-ot-line.cost-other-rubl     = buf_temp-aht-ot-line.cost-other-rubl     + p-cost-other-rubl          buf_temp-aht-ot-line.cost-discnt-base    = buf_temp-aht-ot-line.cost-discnt-base    + p-cost-discnt-base          buf_temp-aht-ot-line.cost-discnt-rubl    = buf_temp-aht-ot-line.cost-discnt-rubl    + p-cost-discnt-rubl
                                                      buf_temp-aht-ot-line.crsa-sum-base       = buf_temp-aht-ot-line.crsa-sum-base       + p-crsa-sum-base            buf_temp-aht-ot-line.crsa-sum-rubl       = buf_temp-aht-ot-line.crsa-sum-rubl       + p-crsa-sum-rubl            buf_temp-aht-ot-line.crsa-vat-base       = buf_temp-aht-ot-line.crsa-vat-base       + p-crsa-vat-base            buf_temp-aht-ot-line.crsa-vat-rubl       = buf_temp-aht-ot-line.crsa-vat-rubl       + p-crsa-vat-rubl            buf_temp-aht-ot-line.crsa-slt-base       = buf_temp-aht-ot-line.crsa-slt-base       + p-crsa-slt-base            buf_temp-aht-ot-line.crsa-slt-rubl       = buf_temp-aht-ot-line.crsa-slt-rubl       + p-crsa-slt-rubl            buf_temp-aht-ot-line.crsa-road-tax-base  = buf_temp-aht-ot-line.crsa-road-tax-base  + p-crsa-road-tax-base       buf_temp-aht-ot-line.crsa-road-tax-rubl  = buf_temp-aht-ot-line.crsa-road-tax-rubl  + p-crsa-road-tax-rubl       buf_temp-aht-ot-line.crsa-excise-base    = buf_temp-aht-ot-line.crsa-excise-base    + p-crsa-excise-base         buf_temp-aht-ot-line.crsa-excise-rubl    = buf_temp-aht-ot-line.crsa-excise-rubl    + p-crsa-excise-rubl         buf_temp-aht-ot-line.crsa-transport-base = buf_temp-aht-ot-line.crsa-transport-base + p-crsa-transport-base      buf_temp-aht-ot-line.crsa-transport-rubl = buf_temp-aht-ot-line.crsa-transport-rubl + p-crsa-transport-rubl      buf_temp-aht-ot-line.crsa-other-base     = buf_temp-aht-ot-line.crsa-other-base     + p-crsa-other-base          buf_temp-aht-ot-line.crsa-other-rubl     = buf_temp-aht-ot-line.crsa-other-rubl     + p-crsa-other-rubl          buf_temp-aht-ot-line.crsa-discnt-base    = buf_temp-aht-ot-line.crsa-discnt-base    + p-crsa-discnt-base          buf_temp-aht-ot-line.crsa-discnt-rubl    = buf_temp-aht-ot-line.crsa-discnt-rubl    + p-crsa-discnt-rubl
                                                      buf_temp-aht-ot-line.sale-sum-base       = buf_temp-aht-ot-line.sale-sum-base       + p-sale-sum-base            buf_temp-aht-ot-line.sale-sum-rubl       = buf_temp-aht-ot-line.sale-sum-rubl       + p-sale-sum-rubl            buf_temp-aht-ot-line.sale-vat-base       = buf_temp-aht-ot-line.sale-vat-base       + p-sale-vat-base            buf_temp-aht-ot-line.sale-vat-rubl       = buf_temp-aht-ot-line.sale-vat-rubl       + p-sale-vat-rubl            buf_temp-aht-ot-line.sale-slt-base       = buf_temp-aht-ot-line.sale-slt-base       + p-sale-slt-base            buf_temp-aht-ot-line.sale-slt-rubl       = buf_temp-aht-ot-line.sale-slt-rubl       + p-sale-slt-rubl            buf_temp-aht-ot-line.sale-road-tax-base  = buf_temp-aht-ot-line.sale-road-tax-base  + p-sale-road-tax-base       buf_temp-aht-ot-line.sale-road-tax-rubl  = buf_temp-aht-ot-line.sale-road-tax-rubl  + p-sale-road-tax-rubl       buf_temp-aht-ot-line.sale-excise-base    = buf_temp-aht-ot-line.sale-excise-base    + p-sale-excise-base         buf_temp-aht-ot-line.sale-excise-rubl    = buf_temp-aht-ot-line.sale-excise-rubl    + p-sale-excise-rubl         buf_temp-aht-ot-line.sale-transport-base = buf_temp-aht-ot-line.sale-transport-base + p-sale-transport-base      buf_temp-aht-ot-line.sale-transport-rubl = buf_temp-aht-ot-line.sale-transport-rubl + p-sale-transport-rubl      buf_temp-aht-ot-line.sale-other-base     = buf_temp-aht-ot-line.sale-other-base     + p-sale-other-base          buf_temp-aht-ot-line.sale-other-rubl     = buf_temp-aht-ot-line.sale-other-rubl     + p-sale-other-rubl          buf_temp-aht-ot-line.sale-discnt-base    = buf_temp-aht-ot-line.sale-discnt-base    + p-sale-discnt-base          buf_temp-aht-ot-line.sale-discnt-rubl    = buf_temp-aht-ot-line.sale-discnt-rubl    + p-sale-discnt-rubl
    .
  end.
end procedure.
procedure aht_update-ot-tot :
  define input  parameter p-obj-type            like ub.trn-doc.obj-type     no-undo .
  define input  parameter p-obj-code            like ub.trn-doc.obj-code     no-undo .
  define input  parameter p-fact-order          like ub.trn-doc.fact-order   no-undo .
  define input  parameter p-ext-doc-type        like ub.trn-doc.ext-doc-type no-undo .
  define buffer buf_temp-aht-ot-line for temp-aht-ot-line .
  define buffer buf_temp-aht-ot-tot for temp-aht-ot-tot .
  do
  on error undo, return error
  :
    for each buf_temp-aht-ot-line
    on error undo, return error
    :
      find first buf_temp-aht-ot-tot
        where buf_temp-aht-ot-tot.doc-code = buf_temp-aht-ot-line.doc-code
          and buf_temp-aht-ot-tot.sum-type = buf_temp-aht-ot-line.sum-type
        no-error .
      if not available buf_temp-aht-ot-tot then do:
        create buf_temp-aht-ot-tot .
        assign
          buf_temp-aht-ot-tot.doc-code     = buf_temp-aht-ot-line.doc-code
          buf_temp-aht-ot-tot.sum-type     = buf_temp-aht-ot-line.sum-type
          buf_temp-aht-ot-tot.ext-doc-type = p-ext-doc-type
          buf_temp-aht-ot-tot.obj-type     = p-obj-type
          buf_temp-aht-ot-tot.obj-code     = p-obj-code
          buf_temp-aht-ot-tot.fact-order   = p-fact-order
        .
      end.
      assign
        buf_temp-aht-ot-tot.fact-qnty = buf_temp-aht-ot-tot.fact-qnty + buf_temp-aht-ot-line.fact-qnty
                                                                        buf_temp-aht-ot-tot.cost-sum-base       = buf_temp-aht-ot-tot.cost-sum-base       + buf_temp-aht-ot-line.cost-sum-base            buf_temp-aht-ot-tot.cost-sum-rubl       = buf_temp-aht-ot-tot.cost-sum-rubl       + buf_temp-aht-ot-line.cost-sum-rubl            buf_temp-aht-ot-tot.cost-vat-base       = buf_temp-aht-ot-tot.cost-vat-base       + buf_temp-aht-ot-line.cost-vat-base            buf_temp-aht-ot-tot.cost-vat-rubl       = buf_temp-aht-ot-tot.cost-vat-rubl       + buf_temp-aht-ot-line.cost-vat-rubl            buf_temp-aht-ot-tot.cost-slt-base       = buf_temp-aht-ot-tot.cost-slt-base       + buf_temp-aht-ot-line.cost-slt-base            buf_temp-aht-ot-tot.cost-slt-rubl       = buf_temp-aht-ot-tot.cost-slt-rubl       + buf_temp-aht-ot-line.cost-slt-rubl            buf_temp-aht-ot-tot.cost-road-tax-base  = buf_temp-aht-ot-tot.cost-road-tax-base  + buf_temp-aht-ot-line.cost-road-tax-base       buf_temp-aht-ot-tot.cost-road-tax-rubl  = buf_temp-aht-ot-tot.cost-road-tax-rubl  + buf_temp-aht-ot-line.cost-road-tax-rubl       buf_temp-aht-ot-tot.cost-excise-base    = buf_temp-aht-ot-tot.cost-excise-base    + buf_temp-aht-ot-line.cost-excise-base         buf_temp-aht-ot-tot.cost-excise-rubl    = buf_temp-aht-ot-tot.cost-excise-rubl    + buf_temp-aht-ot-line.cost-excise-rubl         buf_temp-aht-ot-tot.cost-transport-base = buf_temp-aht-ot-tot.cost-transport-base + buf_temp-aht-ot-line.cost-transport-base      buf_temp-aht-ot-tot.cost-transport-rubl = buf_temp-aht-ot-tot.cost-transport-rubl + buf_temp-aht-ot-line.cost-transport-rubl      buf_temp-aht-ot-tot.cost-other-base     = buf_temp-aht-ot-tot.cost-other-base     + buf_temp-aht-ot-line.cost-other-base          buf_temp-aht-ot-tot.cost-other-rubl     = buf_temp-aht-ot-tot.cost-other-rubl     + buf_temp-aht-ot-line.cost-other-rubl          buf_temp-aht-ot-tot.cost-discnt-base    = buf_temp-aht-ot-tot.cost-discnt-base    + buf_temp-aht-ot-line.cost-discnt-base          buf_temp-aht-ot-tot.cost-discnt-rubl    = buf_temp-aht-ot-tot.cost-discnt-rubl    + buf_temp-aht-ot-line.cost-discnt-rubl
                                                                        buf_temp-aht-ot-tot.crsa-sum-base       = buf_temp-aht-ot-tot.crsa-sum-base       + buf_temp-aht-ot-line.crsa-sum-base            buf_temp-aht-ot-tot.crsa-sum-rubl       = buf_temp-aht-ot-tot.crsa-sum-rubl       + buf_temp-aht-ot-line.crsa-sum-rubl            buf_temp-aht-ot-tot.crsa-vat-base       = buf_temp-aht-ot-tot.crsa-vat-base       + buf_temp-aht-ot-line.crsa-vat-base            buf_temp-aht-ot-tot.crsa-vat-rubl       = buf_temp-aht-ot-tot.crsa-vat-rubl       + buf_temp-aht-ot-line.crsa-vat-rubl            buf_temp-aht-ot-tot.crsa-slt-base       = buf_temp-aht-ot-tot.crsa-slt-base       + buf_temp-aht-ot-line.crsa-slt-base            buf_temp-aht-ot-tot.crsa-slt-rubl       = buf_temp-aht-ot-tot.crsa-slt-rubl       + buf_temp-aht-ot-line.crsa-slt-rubl            buf_temp-aht-ot-tot.crsa-road-tax-base  = buf_temp-aht-ot-tot.crsa-road-tax-base  + buf_temp-aht-ot-line.crsa-road-tax-base       buf_temp-aht-ot-tot.crsa-road-tax-rubl  = buf_temp-aht-ot-tot.crsa-road-tax-rubl  + buf_temp-aht-ot-line.crsa-road-tax-rubl       buf_temp-aht-ot-tot.crsa-excise-base    = buf_temp-aht-ot-tot.crsa-excise-base    + buf_temp-aht-ot-line.crsa-excise-base         buf_temp-aht-ot-tot.crsa-excise-rubl    = buf_temp-aht-ot-tot.crsa-excise-rubl    + buf_temp-aht-ot-line.crsa-excise-rubl         buf_temp-aht-ot-tot.crsa-transport-base = buf_temp-aht-ot-tot.crsa-transport-base + buf_temp-aht-ot-line.crsa-transport-base      buf_temp-aht-ot-tot.crsa-transport-rubl = buf_temp-aht-ot-tot.crsa-transport-rubl + buf_temp-aht-ot-line.crsa-transport-rubl      buf_temp-aht-ot-tot.crsa-other-base     = buf_temp-aht-ot-tot.crsa-other-base     + buf_temp-aht-ot-line.crsa-other-base          buf_temp-aht-ot-tot.crsa-other-rubl     = buf_temp-aht-ot-tot.crsa-other-rubl     + buf_temp-aht-ot-line.crsa-other-rubl          buf_temp-aht-ot-tot.crsa-discnt-base    = buf_temp-aht-ot-tot.crsa-discnt-base    + buf_temp-aht-ot-line.crsa-discnt-base          buf_temp-aht-ot-tot.crsa-discnt-rubl    = buf_temp-aht-ot-tot.crsa-discnt-rubl    + buf_temp-aht-ot-line.crsa-discnt-rubl
                                                                        buf_temp-aht-ot-tot.sale-sum-base       = buf_temp-aht-ot-tot.sale-sum-base       + buf_temp-aht-ot-line.sale-sum-base            buf_temp-aht-ot-tot.sale-sum-rubl       = buf_temp-aht-ot-tot.sale-sum-rubl       + buf_temp-aht-ot-line.sale-sum-rubl            buf_temp-aht-ot-tot.sale-vat-base       = buf_temp-aht-ot-tot.sale-vat-base       + buf_temp-aht-ot-line.sale-vat-base            buf_temp-aht-ot-tot.sale-vat-rubl       = buf_temp-aht-ot-tot.sale-vat-rubl       + buf_temp-aht-ot-line.sale-vat-rubl            buf_temp-aht-ot-tot.sale-slt-base       = buf_temp-aht-ot-tot.sale-slt-base       + buf_temp-aht-ot-line.sale-slt-base            buf_temp-aht-ot-tot.sale-slt-rubl       = buf_temp-aht-ot-tot.sale-slt-rubl       + buf_temp-aht-ot-line.sale-slt-rubl            buf_temp-aht-ot-tot.sale-road-tax-base  = buf_temp-aht-ot-tot.sale-road-tax-base  + buf_temp-aht-ot-line.sale-road-tax-base       buf_temp-aht-ot-tot.sale-road-tax-rubl  = buf_temp-aht-ot-tot.sale-road-tax-rubl  + buf_temp-aht-ot-line.sale-road-tax-rubl       buf_temp-aht-ot-tot.sale-excise-base    = buf_temp-aht-ot-tot.sale-excise-base    + buf_temp-aht-ot-line.sale-excise-base         buf_temp-aht-ot-tot.sale-excise-rubl    = buf_temp-aht-ot-tot.sale-excise-rubl    + buf_temp-aht-ot-line.sale-excise-rubl         buf_temp-aht-ot-tot.sale-transport-base = buf_temp-aht-ot-tot.sale-transport-base + buf_temp-aht-ot-line.sale-transport-base      buf_temp-aht-ot-tot.sale-transport-rubl = buf_temp-aht-ot-tot.sale-transport-rubl + buf_temp-aht-ot-line.sale-transport-rubl      buf_temp-aht-ot-tot.sale-other-base     = buf_temp-aht-ot-tot.sale-other-base     + buf_temp-aht-ot-line.sale-other-base          buf_temp-aht-ot-tot.sale-other-rubl     = buf_temp-aht-ot-tot.sale-other-rubl     + buf_temp-aht-ot-line.sale-other-rubl          buf_temp-aht-ot-tot.sale-discnt-base    = buf_temp-aht-ot-tot.sale-discnt-base    + buf_temp-aht-ot-line.sale-discnt-base          buf_temp-aht-ot-tot.sale-discnt-rubl    = buf_temp-aht-ot-tot.sale-discnt-rubl    + buf_temp-aht-ot-line.sale-discnt-rubl
      .
    end.
  end.
end procedure.
procedure aht_update-stk-table :
  define input  parameter p-fact-order     like ub.trn-doc.fact-order   no-undo .
  define input  parameter p-cut-fact-order like ub.trn-doc.fact-order   no-undo .
  define input  parameter p-ext-doc-type   like ub.trn-doc.ext-doc-type no-undo .
  define input  parameter p-trn-doc        as logical   no-undo .
  define buffer buf_temp-aht-ot-tot for temp-aht-ot-tot .
  define buffer buf_temp-aht-ot-line for temp-aht-ot-line .
  define variable v-stk-ext-sum-type as character no-undo .
  do
  on error undo, return error
  :
    for each buf_temp-aht-ot-tot
    on error undo, return error
    :
      run aht_get-stk-sum-type in this-procedure
        (input  buf_temp-aht-ot-tot.sum-type
        ,input  p-ext-doc-type
        ,output v-stk-ext-sum-type
        ) .
      run aht_store-stk-tot in this-procedure
        (buffer buf_temp-aht-ot-tot
        ,input buf_temp-aht-ot-tot.sum-type
        ,input p-fact-order
        ,input p-cut-fact-order
        ,input p-ext-doc-type
        ,input false
        ) .
      run aht_store-stk-tot in this-procedure
        (buffer buf_temp-aht-ot-tot
        ,input v-stk-ext-sum-type
        ,input p-fact-order
        ,input p-cut-fact-order
        ,input p-ext-doc-type
        ,input p-trn-doc
        ) .
    end.
    for each buf_temp-aht-ot-line
    on error undo, return error
    :
      run aht_get-stk-sum-type in this-procedure
        (input  buf_temp-aht-ot-line.sum-type
        ,input  p-ext-doc-type
        ,output v-stk-ext-sum-type
        ) .
      run aht_store-stk-line in this-procedure
        (buffer buf_temp-aht-ot-line
        ,input buf_temp-aht-ot-line.sum-type
        ,input p-fact-order
        ,input p-cut-fact-order
        ,input p-ext-doc-type
        ,input false
        ) .
      run aht_store-stk-line in this-procedure
        (buffer buf_temp-aht-ot-line
        ,input v-stk-ext-sum-type
        ,input p-fact-order
        ,input p-cut-fact-order
        ,input p-ext-doc-type
        ,input p-trn-doc
        ) .
    end.
  end.
end procedure.
procedure aht_store-stk-tot :
  define parameter buffer buf_temp-aht-ot-tot for temp-aht-ot-tot .
  define input  parameter p-stk-sum-type      as character no-undo .
  define input  parameter p-fact-order        like ub.trn-doc.fact-order   no-undo .
  define input  parameter p-cut-fact-order    like ub.trn-doc.fact-order   no-undo .
  define input  parameter p-ext-doc-type      like ub.trn-doc.ext-doc-type no-undo .
  define input  parameter p-update-sale       as logical   no-undo .
  define buffer buf_aht-stk-tot for ub.aht-stk-tot .
  define buffer new-buf_aht-stk-tot for ub.aht-stk-tot .
  do
  on error undo, return error return-value
  :
    find last buf_aht-stk-tot exclusive-lock
      where buf_aht-stk-tot.obj-type   = buf_temp-aht-ot-tot.obj-type
        and buf_aht-stk-tot.obj-code   = buf_temp-aht-ot-tot.obj-code
        and buf_aht-stk-tot.sum-type   = p-stk-sum-type
        and buf_aht-stk-tot.fact-order <= p-fact-order
      use-index category
      no-error .
    if not available buf_aht-stk-tot
    or buf_aht-stk-tot.fact-order <> p-fact-order
    then do:
      create new-buf_aht-stk-tot .
      assign
        new-buf_aht-stk-tot.obj-type   = buf_temp-aht-ot-tot.obj-type
        new-buf_aht-stk-tot.obj-code   = buf_temp-aht-ot-tot.obj-code
        new-buf_aht-stk-tot.fact-order = p-fact-order
        new-buf_aht-stk-tot.sum-type   = p-stk-sum-type
      .
      if available buf_aht-stk-tot then do:
        assign
          new-buf_aht-stk-tot.fact-qnty = buf_aht-stk-tot.fact-qnty
                                                                      new-buf_aht-stk-tot.cost-sum-base       = buf_aht-stk-tot.cost-sum-base             new-buf_aht-stk-tot.cost-sum-rubl       = buf_aht-stk-tot.cost-sum-rubl             new-buf_aht-stk-tot.cost-vat-base       = buf_aht-stk-tot.cost-vat-base             new-buf_aht-stk-tot.cost-vat-rubl       = buf_aht-stk-tot.cost-vat-rubl             new-buf_aht-stk-tot.cost-slt-base       = buf_aht-stk-tot.cost-slt-base             new-buf_aht-stk-tot.cost-slt-rubl       = buf_aht-stk-tot.cost-slt-rubl             new-buf_aht-stk-tot.cost-road-tax-base  = buf_aht-stk-tot.cost-road-tax-base        new-buf_aht-stk-tot.cost-road-tax-rubl  = buf_aht-stk-tot.cost-road-tax-rubl        new-buf_aht-stk-tot.cost-excise-base    = buf_aht-stk-tot.cost-excise-base          new-buf_aht-stk-tot.cost-excise-rubl    = buf_aht-stk-tot.cost-excise-rubl          new-buf_aht-stk-tot.cost-transport-base = buf_aht-stk-tot.cost-transport-base       new-buf_aht-stk-tot.cost-transport-rubl = buf_aht-stk-tot.cost-transport-rubl       new-buf_aht-stk-tot.cost-other-base     = buf_aht-stk-tot.cost-other-base           new-buf_aht-stk-tot.cost-other-rubl     = buf_aht-stk-tot.cost-other-rubl           new-buf_aht-stk-tot.cost-discnt-base    = buf_aht-stk-tot.cost-discnt-base          new-buf_aht-stk-tot.cost-discnt-rubl    = buf_aht-stk-tot.cost-discnt-rubl
                                                                      new-buf_aht-stk-tot.crsa-sum-base       = buf_aht-stk-tot.crsa-sum-base             new-buf_aht-stk-tot.crsa-sum-rubl       = buf_aht-stk-tot.crsa-sum-rubl             new-buf_aht-stk-tot.crsa-vat-base       = buf_aht-stk-tot.crsa-vat-base             new-buf_aht-stk-tot.crsa-vat-rubl       = buf_aht-stk-tot.crsa-vat-rubl             new-buf_aht-stk-tot.crsa-slt-base       = buf_aht-stk-tot.crsa-slt-base             new-buf_aht-stk-tot.crsa-slt-rubl       = buf_aht-stk-tot.crsa-slt-rubl             new-buf_aht-stk-tot.crsa-road-tax-base  = buf_aht-stk-tot.crsa-road-tax-base        new-buf_aht-stk-tot.crsa-road-tax-rubl  = buf_aht-stk-tot.crsa-road-tax-rubl        new-buf_aht-stk-tot.crsa-excise-base    = buf_aht-stk-tot.crsa-excise-base          new-buf_aht-stk-tot.crsa-excise-rubl    = buf_aht-stk-tot.crsa-excise-rubl          new-buf_aht-stk-tot.crsa-transport-base = buf_aht-stk-tot.crsa-transport-base       new-buf_aht-stk-tot.crsa-transport-rubl = buf_aht-stk-tot.crsa-transport-rubl       new-buf_aht-stk-tot.crsa-other-base     = buf_aht-stk-tot.crsa-other-base           new-buf_aht-stk-tot.crsa-other-rubl     = buf_aht-stk-tot.crsa-other-rubl           new-buf_aht-stk-tot.crsa-discnt-base    = buf_aht-stk-tot.crsa-discnt-base          new-buf_aht-stk-tot.crsa-discnt-rubl    = buf_aht-stk-tot.crsa-discnt-rubl
        .
        if p-update-sale then do:
          assign
                                                                                    new-buf_aht-stk-tot.sale-sum-base       = buf_aht-stk-tot.sale-sum-base             new-buf_aht-stk-tot.sale-sum-rubl       = buf_aht-stk-tot.sale-sum-rubl             new-buf_aht-stk-tot.sale-vat-base       = buf_aht-stk-tot.sale-vat-base             new-buf_aht-stk-tot.sale-vat-rubl       = buf_aht-stk-tot.sale-vat-rubl             new-buf_aht-stk-tot.sale-slt-base       = buf_aht-stk-tot.sale-slt-base             new-buf_aht-stk-tot.sale-slt-rubl       = buf_aht-stk-tot.sale-slt-rubl             new-buf_aht-stk-tot.sale-road-tax-base  = buf_aht-stk-tot.sale-road-tax-base        new-buf_aht-stk-tot.sale-road-tax-rubl  = buf_aht-stk-tot.sale-road-tax-rubl        new-buf_aht-stk-tot.sale-excise-base    = buf_aht-stk-tot.sale-excise-base          new-buf_aht-stk-tot.sale-excise-rubl    = buf_aht-stk-tot.sale-excise-rubl          new-buf_aht-stk-tot.sale-transport-base = buf_aht-stk-tot.sale-transport-base       new-buf_aht-stk-tot.sale-transport-rubl = buf_aht-stk-tot.sale-transport-rubl       new-buf_aht-stk-tot.sale-other-base     = buf_aht-stk-tot.sale-other-base           new-buf_aht-stk-tot.sale-other-rubl     = buf_aht-stk-tot.sale-other-rubl           new-buf_aht-stk-tot.sale-discnt-base    = buf_aht-stk-tot.sale-discnt-base          new-buf_aht-stk-tot.sale-discnt-rubl    = buf_aht-stk-tot.sale-discnt-rubl
          .
        end.
      end.
    end.
    if p-stk-sum-type <> 'v':U
    then do:
      for each buf_aht-stk-tot exclusive-lock
        where buf_aht-stk-tot.obj-type   = buf_temp-aht-ot-tot.obj-type
          and buf_aht-stk-tot.obj-code   = buf_temp-aht-ot-tot.obj-code
          and buf_aht-stk-tot.sum-type   = p-stk-sum-type
          and buf_aht-stk-tot.fact-order >= p-fact-order
          and buf_aht-stk-tot.fact-order <= p-cut-fact-order
      :
        assign
          buf_aht-stk-tot.fact-qnty = buf_aht-stk-tot.fact-qnty + buf_temp-aht-ot-tot.fact-qnty
                                                                                          buf_aht-stk-tot.cost-sum-base       = buf_aht-stk-tot.cost-sum-base       + buf_temp-aht-ot-tot.cost-sum-base            buf_aht-stk-tot.cost-sum-rubl       = buf_aht-stk-tot.cost-sum-rubl       + buf_temp-aht-ot-tot.cost-sum-rubl            buf_aht-stk-tot.cost-vat-base       = buf_aht-stk-tot.cost-vat-base       + buf_temp-aht-ot-tot.cost-vat-base            buf_aht-stk-tot.cost-vat-rubl       = buf_aht-stk-tot.cost-vat-rubl       + buf_temp-aht-ot-tot.cost-vat-rubl            buf_aht-stk-tot.cost-slt-base       = buf_aht-stk-tot.cost-slt-base       + buf_temp-aht-ot-tot.cost-slt-base            buf_aht-stk-tot.cost-slt-rubl       = buf_aht-stk-tot.cost-slt-rubl       + buf_temp-aht-ot-tot.cost-slt-rubl            buf_aht-stk-tot.cost-road-tax-base  = buf_aht-stk-tot.cost-road-tax-base  + buf_temp-aht-ot-tot.cost-road-tax-base       buf_aht-stk-tot.cost-road-tax-rubl  = buf_aht-stk-tot.cost-road-tax-rubl  + buf_temp-aht-ot-tot.cost-road-tax-rubl       buf_aht-stk-tot.cost-excise-base    = buf_aht-stk-tot.cost-excise-base    + buf_temp-aht-ot-tot.cost-excise-base         buf_aht-stk-tot.cost-excise-rubl    = buf_aht-stk-tot.cost-excise-rubl    + buf_temp-aht-ot-tot.cost-excise-rubl         buf_aht-stk-tot.cost-transport-base = buf_aht-stk-tot.cost-transport-base + buf_temp-aht-ot-tot.cost-transport-base      buf_aht-stk-tot.cost-transport-rubl = buf_aht-stk-tot.cost-transport-rubl + buf_temp-aht-ot-tot.cost-transport-rubl      buf_aht-stk-tot.cost-other-base     = buf_aht-stk-tot.cost-other-base     + buf_temp-aht-ot-tot.cost-other-base          buf_aht-stk-tot.cost-other-rubl     = buf_aht-stk-tot.cost-other-rubl     + buf_temp-aht-ot-tot.cost-other-rubl          buf_aht-stk-tot.cost-discnt-base    = buf_aht-stk-tot.cost-discnt-base    + buf_temp-aht-ot-tot.cost-discnt-base          buf_aht-stk-tot.cost-discnt-rubl    = buf_aht-stk-tot.cost-discnt-rubl    + buf_temp-aht-ot-tot.cost-discnt-rubl
                                                                                          buf_aht-stk-tot.crsa-sum-base       = buf_aht-stk-tot.crsa-sum-base       + buf_temp-aht-ot-tot.crsa-sum-base            buf_aht-stk-tot.crsa-sum-rubl       = buf_aht-stk-tot.crsa-sum-rubl       + buf_temp-aht-ot-tot.crsa-sum-rubl            buf_aht-stk-tot.crsa-vat-base       = buf_aht-stk-tot.crsa-vat-base       + buf_temp-aht-ot-tot.crsa-vat-base            buf_aht-stk-tot.crsa-vat-rubl       = buf_aht-stk-tot.crsa-vat-rubl       + buf_temp-aht-ot-tot.crsa-vat-rubl            buf_aht-stk-tot.crsa-slt-base       = buf_aht-stk-tot.crsa-slt-base       + buf_temp-aht-ot-tot.crsa-slt-base            buf_aht-stk-tot.crsa-slt-rubl       = buf_aht-stk-tot.crsa-slt-rubl       + buf_temp-aht-ot-tot.crsa-slt-rubl            buf_aht-stk-tot.crsa-road-tax-base  = buf_aht-stk-tot.crsa-road-tax-base  + buf_temp-aht-ot-tot.crsa-road-tax-base       buf_aht-stk-tot.crsa-road-tax-rubl  = buf_aht-stk-tot.crsa-road-tax-rubl  + buf_temp-aht-ot-tot.crsa-road-tax-rubl       buf_aht-stk-tot.crsa-excise-base    = buf_aht-stk-tot.crsa-excise-base    + buf_temp-aht-ot-tot.crsa-excise-base         buf_aht-stk-tot.crsa-excise-rubl    = buf_aht-stk-tot.crsa-excise-rubl    + buf_temp-aht-ot-tot.crsa-excise-rubl         buf_aht-stk-tot.crsa-transport-base = buf_aht-stk-tot.crsa-transport-base + buf_temp-aht-ot-tot.crsa-transport-base      buf_aht-stk-tot.crsa-transport-rubl = buf_aht-stk-tot.crsa-transport-rubl + buf_temp-aht-ot-tot.crsa-transport-rubl      buf_aht-stk-tot.crsa-other-base     = buf_aht-stk-tot.crsa-other-base     + buf_temp-aht-ot-tot.crsa-other-base          buf_aht-stk-tot.crsa-other-rubl     = buf_aht-stk-tot.crsa-other-rubl     + buf_temp-aht-ot-tot.crsa-other-rubl          buf_aht-stk-tot.crsa-discnt-base    = buf_aht-stk-tot.crsa-discnt-base    + buf_temp-aht-ot-tot.crsa-discnt-base          buf_aht-stk-tot.crsa-discnt-rubl    = buf_aht-stk-tot.crsa-discnt-rubl    + buf_temp-aht-ot-tot.crsa-discnt-rubl
        .
        if p-update-sale then do:
          assign
                                                                                                            buf_aht-stk-tot.sale-sum-base       = buf_aht-stk-tot.sale-sum-base       + buf_temp-aht-ot-tot.sale-sum-base            buf_aht-stk-tot.sale-sum-rubl       = buf_aht-stk-tot.sale-sum-rubl       + buf_temp-aht-ot-tot.sale-sum-rubl            buf_aht-stk-tot.sale-vat-base       = buf_aht-stk-tot.sale-vat-base       + buf_temp-aht-ot-tot.sale-vat-base            buf_aht-stk-tot.sale-vat-rubl       = buf_aht-stk-tot.sale-vat-rubl       + buf_temp-aht-ot-tot.sale-vat-rubl            buf_aht-stk-tot.sale-slt-base       = buf_aht-stk-tot.sale-slt-base       + buf_temp-aht-ot-tot.sale-slt-base            buf_aht-stk-tot.sale-slt-rubl       = buf_aht-stk-tot.sale-slt-rubl       + buf_temp-aht-ot-tot.sale-slt-rubl            buf_aht-stk-tot.sale-road-tax-base  = buf_aht-stk-tot.sale-road-tax-base  + buf_temp-aht-ot-tot.sale-road-tax-base       buf_aht-stk-tot.sale-road-tax-rubl  = buf_aht-stk-tot.sale-road-tax-rubl  + buf_temp-aht-ot-tot.sale-road-tax-rubl       buf_aht-stk-tot.sale-excise-base    = buf_aht-stk-tot.sale-excise-base    + buf_temp-aht-ot-tot.sale-excise-base         buf_aht-stk-tot.sale-excise-rubl    = buf_aht-stk-tot.sale-excise-rubl    + buf_temp-aht-ot-tot.sale-excise-rubl         buf_aht-stk-tot.sale-transport-base = buf_aht-stk-tot.sale-transport-base + buf_temp-aht-ot-tot.sale-transport-base      buf_aht-stk-tot.sale-transport-rubl = buf_aht-stk-tot.sale-transport-rubl + buf_temp-aht-ot-tot.sale-transport-rubl      buf_aht-stk-tot.sale-other-base     = buf_aht-stk-tot.sale-other-base     + buf_temp-aht-ot-tot.sale-other-base          buf_aht-stk-tot.sale-other-rubl     = buf_aht-stk-tot.sale-other-rubl     + buf_temp-aht-ot-tot.sale-other-rubl          buf_aht-stk-tot.sale-discnt-base    = buf_aht-stk-tot.sale-discnt-base    + buf_temp-aht-ot-tot.sale-discnt-base          buf_aht-stk-tot.sale-discnt-rubl    = buf_aht-stk-tot.sale-discnt-rubl    + buf_temp-aht-ot-tot.sale-discnt-rubl
          .
        end.
      end.
    end.
  end.
end procedure.
procedure aht_store-stk-line :
  define parameter buffer buf_temp-aht-ot-line for temp-aht-ot-line .
  define input  parameter p-stk-sum-type   as character no-undo .
  define input  parameter p-fact-order     like ub.trn-doc.fact-order   no-undo .
  define input  parameter p-cut-fact-order like ub.trn-doc.fact-order   no-undo .
  define input  parameter p-ext-doc-type   like ub.trn-doc.ext-doc-type no-undo .
  define input  parameter p-update-sale    as logical   no-undo .
  define buffer buf_aht-stk-line for ub.aht-stk-line .
  define buffer new-buf_aht-stk-line for ub.aht-stk-line .
  do
  on error undo, return error return-value
  :
    find last buf_aht-stk-line exclusive-lock
      where buf_aht-stk-line.obj-type   = buf_temp-aht-ot-line.obj-type
        and buf_aht-stk-line.obj-code   = buf_temp-aht-ot-line.obj-code
        and buf_aht-stk-line.gds-code   = buf_temp-aht-ot-line.gds-code
        and buf_aht-stk-line.sum-type   = p-stk-sum-type
        and buf_aht-stk-line.fact-order <= p-fact-order
      use-index category
      no-error .
    if not available buf_aht-stk-line
    or buf_aht-stk-line.fact-order <> p-fact-order
    then do:
      create new-buf_aht-stk-line .
      assign
        new-buf_aht-stk-line.obj-type   = buf_temp-aht-ot-line.obj-type
        new-buf_aht-stk-line.obj-code   = buf_temp-aht-ot-line.obj-code
        new-buf_aht-stk-line.gds-code   = buf_temp-aht-ot-line.gds-code
        new-buf_aht-stk-line.fact-order = p-fact-order
        new-buf_aht-stk-line.sum-type   = p-stk-sum-type
      .
      if available buf_aht-stk-line then do:
        assign
          new-buf_aht-stk-line.fact-qnty = buf_aht-stk-line.fact-qnty
                                                                      new-buf_aht-stk-line.cost-sum-base       = buf_aht-stk-line.cost-sum-base             new-buf_aht-stk-line.cost-sum-rubl       = buf_aht-stk-line.cost-sum-rubl             new-buf_aht-stk-line.cost-vat-base       = buf_aht-stk-line.cost-vat-base             new-buf_aht-stk-line.cost-vat-rubl       = buf_aht-stk-line.cost-vat-rubl             new-buf_aht-stk-line.cost-slt-base       = buf_aht-stk-line.cost-slt-base             new-buf_aht-stk-line.cost-slt-rubl       = buf_aht-stk-line.cost-slt-rubl             new-buf_aht-stk-line.cost-road-tax-base  = buf_aht-stk-line.cost-road-tax-base        new-buf_aht-stk-line.cost-road-tax-rubl  = buf_aht-stk-line.cost-road-tax-rubl        new-buf_aht-stk-line.cost-excise-base    = buf_aht-stk-line.cost-excise-base          new-buf_aht-stk-line.cost-excise-rubl    = buf_aht-stk-line.cost-excise-rubl          new-buf_aht-stk-line.cost-transport-base = buf_aht-stk-line.cost-transport-base       new-buf_aht-stk-line.cost-transport-rubl = buf_aht-stk-line.cost-transport-rubl       new-buf_aht-stk-line.cost-other-base     = buf_aht-stk-line.cost-other-base           new-buf_aht-stk-line.cost-other-rubl     = buf_aht-stk-line.cost-other-rubl           new-buf_aht-stk-line.cost-discnt-base    = buf_aht-stk-line.cost-discnt-base          new-buf_aht-stk-line.cost-discnt-rubl    = buf_aht-stk-line.cost-discnt-rubl
                                                                      new-buf_aht-stk-line.crsa-sum-base       = buf_aht-stk-line.crsa-sum-base             new-buf_aht-stk-line.crsa-sum-rubl       = buf_aht-stk-line.crsa-sum-rubl             new-buf_aht-stk-line.crsa-vat-base       = buf_aht-stk-line.crsa-vat-base             new-buf_aht-stk-line.crsa-vat-rubl       = buf_aht-stk-line.crsa-vat-rubl             new-buf_aht-stk-line.crsa-slt-base       = buf_aht-stk-line.crsa-slt-base             new-buf_aht-stk-line.crsa-slt-rubl       = buf_aht-stk-line.crsa-slt-rubl             new-buf_aht-stk-line.crsa-road-tax-base  = buf_aht-stk-line.crsa-road-tax-base        new-buf_aht-stk-line.crsa-road-tax-rubl  = buf_aht-stk-line.crsa-road-tax-rubl        new-buf_aht-stk-line.crsa-excise-base    = buf_aht-stk-line.crsa-excise-base          new-buf_aht-stk-line.crsa-excise-rubl    = buf_aht-stk-line.crsa-excise-rubl          new-buf_aht-stk-line.crsa-transport-base = buf_aht-stk-line.crsa-transport-base       new-buf_aht-stk-line.crsa-transport-rubl = buf_aht-stk-line.crsa-transport-rubl       new-buf_aht-stk-line.crsa-other-base     = buf_aht-stk-line.crsa-other-base           new-buf_aht-stk-line.crsa-other-rubl     = buf_aht-stk-line.crsa-other-rubl           new-buf_aht-stk-line.crsa-discnt-base    = buf_aht-stk-line.crsa-discnt-base          new-buf_aht-stk-line.crsa-discnt-rubl    = buf_aht-stk-line.crsa-discnt-rubl
        .
        if p-update-sale then do:
          assign
                                                                                    new-buf_aht-stk-line.sale-sum-base       = buf_aht-stk-line.sale-sum-base             new-buf_aht-stk-line.sale-sum-rubl       = buf_aht-stk-line.sale-sum-rubl             new-buf_aht-stk-line.sale-vat-base       = buf_aht-stk-line.sale-vat-base             new-buf_aht-stk-line.sale-vat-rubl       = buf_aht-stk-line.sale-vat-rubl             new-buf_aht-stk-line.sale-slt-base       = buf_aht-stk-line.sale-slt-base             new-buf_aht-stk-line.sale-slt-rubl       = buf_aht-stk-line.sale-slt-rubl             new-buf_aht-stk-line.sale-road-tax-base  = buf_aht-stk-line.sale-road-tax-base        new-buf_aht-stk-line.sale-road-tax-rubl  = buf_aht-stk-line.sale-road-tax-rubl        new-buf_aht-stk-line.sale-excise-base    = buf_aht-stk-line.sale-excise-base          new-buf_aht-stk-line.sale-excise-rubl    = buf_aht-stk-line.sale-excise-rubl          new-buf_aht-stk-line.sale-transport-base = buf_aht-stk-line.sale-transport-base       new-buf_aht-stk-line.sale-transport-rubl = buf_aht-stk-line.sale-transport-rubl       new-buf_aht-stk-line.sale-other-base     = buf_aht-stk-line.sale-other-base           new-buf_aht-stk-line.sale-other-rubl     = buf_aht-stk-line.sale-other-rubl           new-buf_aht-stk-line.sale-discnt-base    = buf_aht-stk-line.sale-discnt-base          new-buf_aht-stk-line.sale-discnt-rubl    = buf_aht-stk-line.sale-discnt-rubl
          .
        end.
      end.
    end.
    if p-stk-sum-type <> 'v':U
    then do:
      for each buf_aht-stk-line exclusive-lock
        where buf_aht-stk-line.obj-type   = buf_temp-aht-ot-line.obj-type
          and buf_aht-stk-line.obj-code   = buf_temp-aht-ot-line.obj-code
          and buf_aht-stk-line.gds-code   = buf_temp-aht-ot-line.gds-code
          and buf_aht-stk-line.sum-type   = p-stk-sum-type
          and buf_aht-stk-line.fact-order >= p-fact-order
          and buf_aht-stk-line.fact-order <= p-cut-fact-order
      :
        assign
          buf_aht-stk-line.fact-qnty = buf_aht-stk-line.fact-qnty + buf_temp-aht-ot-line.fact-qnty
                                                                                          buf_aht-stk-line.cost-sum-base       = buf_aht-stk-line.cost-sum-base       + buf_temp-aht-ot-line.cost-sum-base            buf_aht-stk-line.cost-sum-rubl       = buf_aht-stk-line.cost-sum-rubl       + buf_temp-aht-ot-line.cost-sum-rubl            buf_aht-stk-line.cost-vat-base       = buf_aht-stk-line.cost-vat-base       + buf_temp-aht-ot-line.cost-vat-base            buf_aht-stk-line.cost-vat-rubl       = buf_aht-stk-line.cost-vat-rubl       + buf_temp-aht-ot-line.cost-vat-rubl            buf_aht-stk-line.cost-slt-base       = buf_aht-stk-line.cost-slt-base       + buf_temp-aht-ot-line.cost-slt-base            buf_aht-stk-line.cost-slt-rubl       = buf_aht-stk-line.cost-slt-rubl       + buf_temp-aht-ot-line.cost-slt-rubl            buf_aht-stk-line.cost-road-tax-base  = buf_aht-stk-line.cost-road-tax-base  + buf_temp-aht-ot-line.cost-road-tax-base       buf_aht-stk-line.cost-road-tax-rubl  = buf_aht-stk-line.cost-road-tax-rubl  + buf_temp-aht-ot-line.cost-road-tax-rubl       buf_aht-stk-line.cost-excise-base    = buf_aht-stk-line.cost-excise-base    + buf_temp-aht-ot-line.cost-excise-base         buf_aht-stk-line.cost-excise-rubl    = buf_aht-stk-line.cost-excise-rubl    + buf_temp-aht-ot-line.cost-excise-rubl         buf_aht-stk-line.cost-transport-base = buf_aht-stk-line.cost-transport-base + buf_temp-aht-ot-line.cost-transport-base      buf_aht-stk-line.cost-transport-rubl = buf_aht-stk-line.cost-transport-rubl + buf_temp-aht-ot-line.cost-transport-rubl      buf_aht-stk-line.cost-other-base     = buf_aht-stk-line.cost-other-base     + buf_temp-aht-ot-line.cost-other-base          buf_aht-stk-line.cost-other-rubl     = buf_aht-stk-line.cost-other-rubl     + buf_temp-aht-ot-line.cost-other-rubl          buf_aht-stk-line.cost-discnt-base    = buf_aht-stk-line.cost-discnt-base    + buf_temp-aht-ot-line.cost-discnt-base          buf_aht-stk-line.cost-discnt-rubl    = buf_aht-stk-line.cost-discnt-rubl    + buf_temp-aht-ot-line.cost-discnt-rubl
                                                                                          buf_aht-stk-line.crsa-sum-base       = buf_aht-stk-line.crsa-sum-base       + buf_temp-aht-ot-line.crsa-sum-base            buf_aht-stk-line.crsa-sum-rubl       = buf_aht-stk-line.crsa-sum-rubl       + buf_temp-aht-ot-line.crsa-sum-rubl            buf_aht-stk-line.crsa-vat-base       = buf_aht-stk-line.crsa-vat-base       + buf_temp-aht-ot-line.crsa-vat-base            buf_aht-stk-line.crsa-vat-rubl       = buf_aht-stk-line.crsa-vat-rubl       + buf_temp-aht-ot-line.crsa-vat-rubl            buf_aht-stk-line.crsa-slt-base       = buf_aht-stk-line.crsa-slt-base       + buf_temp-aht-ot-line.crsa-slt-base            buf_aht-stk-line.crsa-slt-rubl       = buf_aht-stk-line.crsa-slt-rubl       + buf_temp-aht-ot-line.crsa-slt-rubl            buf_aht-stk-line.crsa-road-tax-base  = buf_aht-stk-line.crsa-road-tax-base  + buf_temp-aht-ot-line.crsa-road-tax-base       buf_aht-stk-line.crsa-road-tax-rubl  = buf_aht-stk-line.crsa-road-tax-rubl  + buf_temp-aht-ot-line.crsa-road-tax-rubl       buf_aht-stk-line.crsa-excise-base    = buf_aht-stk-line.crsa-excise-base    + buf_temp-aht-ot-line.crsa-excise-base         buf_aht-stk-line.crsa-excise-rubl    = buf_aht-stk-line.crsa-excise-rubl    + buf_temp-aht-ot-line.crsa-excise-rubl         buf_aht-stk-line.crsa-transport-base = buf_aht-stk-line.crsa-transport-base + buf_temp-aht-ot-line.crsa-transport-base      buf_aht-stk-line.crsa-transport-rubl = buf_aht-stk-line.crsa-transport-rubl + buf_temp-aht-ot-line.crsa-transport-rubl      buf_aht-stk-line.crsa-other-base     = buf_aht-stk-line.crsa-other-base     + buf_temp-aht-ot-line.crsa-other-base          buf_aht-stk-line.crsa-other-rubl     = buf_aht-stk-line.crsa-other-rubl     + buf_temp-aht-ot-line.crsa-other-rubl          buf_aht-stk-line.crsa-discnt-base    = buf_aht-stk-line.crsa-discnt-base    + buf_temp-aht-ot-line.crsa-discnt-base          buf_aht-stk-line.crsa-discnt-rubl    = buf_aht-stk-line.crsa-discnt-rubl    + buf_temp-aht-ot-line.crsa-discnt-rubl
        .
        if p-update-sale then do:
          assign
                                                                                                            buf_aht-stk-line.sale-sum-base       = buf_aht-stk-line.sale-sum-base       + buf_temp-aht-ot-line.sale-sum-base            buf_aht-stk-line.sale-sum-rubl       = buf_aht-stk-line.sale-sum-rubl       + buf_temp-aht-ot-line.sale-sum-rubl            buf_aht-stk-line.sale-vat-base       = buf_aht-stk-line.sale-vat-base       + buf_temp-aht-ot-line.sale-vat-base            buf_aht-stk-line.sale-vat-rubl       = buf_aht-stk-line.sale-vat-rubl       + buf_temp-aht-ot-line.sale-vat-rubl            buf_aht-stk-line.sale-slt-base       = buf_aht-stk-line.sale-slt-base       + buf_temp-aht-ot-line.sale-slt-base            buf_aht-stk-line.sale-slt-rubl       = buf_aht-stk-line.sale-slt-rubl       + buf_temp-aht-ot-line.sale-slt-rubl            buf_aht-stk-line.sale-road-tax-base  = buf_aht-stk-line.sale-road-tax-base  + buf_temp-aht-ot-line.sale-road-tax-base       buf_aht-stk-line.sale-road-tax-rubl  = buf_aht-stk-line.sale-road-tax-rubl  + buf_temp-aht-ot-line.sale-road-tax-rubl       buf_aht-stk-line.sale-excise-base    = buf_aht-stk-line.sale-excise-base    + buf_temp-aht-ot-line.sale-excise-base         buf_aht-stk-line.sale-excise-rubl    = buf_aht-stk-line.sale-excise-rubl    + buf_temp-aht-ot-line.sale-excise-rubl         buf_aht-stk-line.sale-transport-base = buf_aht-stk-line.sale-transport-base + buf_temp-aht-ot-line.sale-transport-base      buf_aht-stk-line.sale-transport-rubl = buf_aht-stk-line.sale-transport-rubl + buf_temp-aht-ot-line.sale-transport-rubl      buf_aht-stk-line.sale-other-base     = buf_aht-stk-line.sale-other-base     + buf_temp-aht-ot-line.sale-other-base          buf_aht-stk-line.sale-other-rubl     = buf_aht-stk-line.sale-other-rubl     + buf_temp-aht-ot-line.sale-other-rubl          buf_aht-stk-line.sale-discnt-base    = buf_aht-stk-line.sale-discnt-base    + buf_temp-aht-ot-line.sale-discnt-base          buf_aht-stk-line.sale-discnt-rubl    = buf_aht-stk-line.sale-discnt-rubl    + buf_temp-aht-ot-line.sale-discnt-rubl
          .
        end.
      end.
    end.
  end.
end procedure.
procedure aht_store-ot-table :
  define buffer buf_temp-aht-ot-tot for temp-aht-ot-tot .
  define buffer buf_aht-ot-tot for ub.aht-ot-tot .
  define buffer buf_temp-aht-ot-line for temp-aht-ot-line .
  define buffer buf_aht-ot-line for ub.aht-ot-line .
  define buffer buf_temp-aht-stk-tot for temp-aht-stk-tot .
  define buffer buf_aht-stk-tot for ub.aht-stk-tot .
  define buffer buf_temp-aht-stk-line for temp-aht-stk-line .
  define buffer buf_aht-stk-line for ub.aht-stk-line .
  do
  on error undo, return error
  :
    for each buf_temp-aht-ot-tot
    on error undo, return error
    :
      if
                              buf_temp-aht-ot-tot.cost-sum-base       = ? or    buf_temp-aht-ot-tot.cost-sum-rubl       = ? or    buf_temp-aht-ot-tot.cost-vat-base       = ? or    buf_temp-aht-ot-tot.cost-vat-rubl       = ? or    buf_temp-aht-ot-tot.cost-slt-base       = ? or    buf_temp-aht-ot-tot.cost-slt-rubl       = ? or    buf_temp-aht-ot-tot.cost-road-tax-base  = ? or    buf_temp-aht-ot-tot.cost-road-tax-rubl  = ? or    buf_temp-aht-ot-tot.cost-excise-base    = ? or    buf_temp-aht-ot-tot.cost-excise-rubl    = ? or    buf_temp-aht-ot-tot.cost-transport-base = ? or    buf_temp-aht-ot-tot.cost-transport-rubl = ? or    buf_temp-aht-ot-tot.cost-other-base     = ? or    buf_temp-aht-ot-tot.cost-other-rubl     = ? or    buf_temp-aht-ot-tot.cost-discnt-base    = ? or    buf_temp-aht-ot-tot.cost-discnt-rubl    = ?
      or
                              buf_temp-aht-ot-tot.crsa-sum-base       = ? or    buf_temp-aht-ot-tot.crsa-sum-rubl       = ? or    buf_temp-aht-ot-tot.crsa-vat-base       = ? or    buf_temp-aht-ot-tot.crsa-vat-rubl       = ? or    buf_temp-aht-ot-tot.crsa-slt-base       = ? or    buf_temp-aht-ot-tot.crsa-slt-rubl       = ? or    buf_temp-aht-ot-tot.crsa-road-tax-base  = ? or    buf_temp-aht-ot-tot.crsa-road-tax-rubl  = ? or    buf_temp-aht-ot-tot.crsa-excise-base    = ? or    buf_temp-aht-ot-tot.crsa-excise-rubl    = ? or    buf_temp-aht-ot-tot.crsa-transport-base = ? or    buf_temp-aht-ot-tot.crsa-transport-rubl = ? or    buf_temp-aht-ot-tot.crsa-other-base     = ? or    buf_temp-aht-ot-tot.crsa-other-rubl     = ? or    buf_temp-aht-ot-tot.crsa-discnt-base    = ? or    buf_temp-aht-ot-tot.crsa-discnt-rubl    = ?
      or
                              buf_temp-aht-ot-tot.sale-sum-base       = ? or    buf_temp-aht-ot-tot.sale-sum-rubl       = ? or    buf_temp-aht-ot-tot.sale-vat-base       = ? or    buf_temp-aht-ot-tot.sale-vat-rubl       = ? or    buf_temp-aht-ot-tot.sale-slt-base       = ? or    buf_temp-aht-ot-tot.sale-slt-rubl       = ? or    buf_temp-aht-ot-tot.sale-road-tax-base  = ? or    buf_temp-aht-ot-tot.sale-road-tax-rubl  = ? or    buf_temp-aht-ot-tot.sale-excise-base    = ? or    buf_temp-aht-ot-tot.sale-excise-rubl    = ? or    buf_temp-aht-ot-tot.sale-transport-base = ? or    buf_temp-aht-ot-tot.sale-transport-rubl = ? or    buf_temp-aht-ot-tot.sale-other-base     = ? or    buf_temp-aht-ot-tot.sale-other-rubl     = ? or    buf_temp-aht-ot-tot.sale-discnt-base    = ? or    buf_temp-aht-ot-tot.sale-discnt-rubl    = ?
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info17 skip
          "При расчета складского архива по типам приобретения получено неопределенное значение" skip
          "Документ" buf_temp-aht-ot-tot.doc-code skip
          "Тип суммы" buf_temp-aht-ot-tot.sum-type skip
          view-as alert-box error .
        output stream ahtlog to ahtlog.txt append .
        export stream ahtlog
          vss-include-info17 buf_temp-aht-ot-tot.doc-code .
                                                        export stream ahtlog "temp-aht-ot-tot.cost-sum-base"       buf_temp-aht-ot-tot.cost-sum-base        .     export stream ahtlog "temp-aht-ot-tot.cost-sum-rubl"       buf_temp-aht-ot-tot.cost-sum-rubl        .     export stream ahtlog "temp-aht-ot-tot.cost-vat-base"       buf_temp-aht-ot-tot.cost-vat-base        .     export stream ahtlog "temp-aht-ot-tot.cost-vat-rubl"       buf_temp-aht-ot-tot.cost-vat-rubl        .     export stream ahtlog "temp-aht-ot-tot.cost-slt-base"       buf_temp-aht-ot-tot.cost-slt-base        .     export stream ahtlog "temp-aht-ot-tot.cost-slt-rubl"       buf_temp-aht-ot-tot.cost-slt-rubl        .     export stream ahtlog "temp-aht-ot-tot.cost-road-tax-base"  buf_temp-aht-ot-tot.cost-road-tax-base   .     export stream ahtlog "temp-aht-ot-tot.cost-road-tax-rubl"  buf_temp-aht-ot-tot.cost-road-tax-rubl   .     export stream ahtlog "temp-aht-ot-tot.cost-excise-base"    buf_temp-aht-ot-tot.cost-excise-base     .     export stream ahtlog "temp-aht-ot-tot.cost-excise-rubl"    buf_temp-aht-ot-tot.cost-excise-rubl     .     export stream ahtlog "temp-aht-ot-tot.cost-transport-base" buf_temp-aht-ot-tot.cost-transport-base  .     export stream ahtlog "temp-aht-ot-tot.cost-transport-rubl" buf_temp-aht-ot-tot.cost-transport-rubl  .     export stream ahtlog "temp-aht-ot-tot.cost-other-base"     buf_temp-aht-ot-tot.cost-other-base      .     export stream ahtlog "temp-aht-ot-tot.cost-other-rubl"     buf_temp-aht-ot-tot.cost-other-rubl      .     export stream ahtlog "temp-aht-ot-tot.cost-discnt-base"    buf_temp-aht-ot-tot.cost-discnt-base     .     export stream ahtlog "temp-aht-ot-tot.cost-discnt-rubl"    buf_temp-aht-ot-tot.cost-discnt-rubl     .
                                                        export stream ahtlog "temp-aht-ot-tot.crsa-sum-base"       buf_temp-aht-ot-tot.crsa-sum-base        .     export stream ahtlog "temp-aht-ot-tot.crsa-sum-rubl"       buf_temp-aht-ot-tot.crsa-sum-rubl        .     export stream ahtlog "temp-aht-ot-tot.crsa-vat-base"       buf_temp-aht-ot-tot.crsa-vat-base        .     export stream ahtlog "temp-aht-ot-tot.crsa-vat-rubl"       buf_temp-aht-ot-tot.crsa-vat-rubl        .     export stream ahtlog "temp-aht-ot-tot.crsa-slt-base"       buf_temp-aht-ot-tot.crsa-slt-base        .     export stream ahtlog "temp-aht-ot-tot.crsa-slt-rubl"       buf_temp-aht-ot-tot.crsa-slt-rubl        .     export stream ahtlog "temp-aht-ot-tot.crsa-road-tax-base"  buf_temp-aht-ot-tot.crsa-road-tax-base   .     export stream ahtlog "temp-aht-ot-tot.crsa-road-tax-rubl"  buf_temp-aht-ot-tot.crsa-road-tax-rubl   .     export stream ahtlog "temp-aht-ot-tot.crsa-excise-base"    buf_temp-aht-ot-tot.crsa-excise-base     .     export stream ahtlog "temp-aht-ot-tot.crsa-excise-rubl"    buf_temp-aht-ot-tot.crsa-excise-rubl     .     export stream ahtlog "temp-aht-ot-tot.crsa-transport-base" buf_temp-aht-ot-tot.crsa-transport-base  .     export stream ahtlog "temp-aht-ot-tot.crsa-transport-rubl" buf_temp-aht-ot-tot.crsa-transport-rubl  .     export stream ahtlog "temp-aht-ot-tot.crsa-other-base"     buf_temp-aht-ot-tot.crsa-other-base      .     export stream ahtlog "temp-aht-ot-tot.crsa-other-rubl"     buf_temp-aht-ot-tot.crsa-other-rubl      .     export stream ahtlog "temp-aht-ot-tot.crsa-discnt-base"    buf_temp-aht-ot-tot.crsa-discnt-base     .     export stream ahtlog "temp-aht-ot-tot.crsa-discnt-rubl"    buf_temp-aht-ot-tot.crsa-discnt-rubl     .
                                                        export stream ahtlog "temp-aht-ot-tot.sale-sum-base"       buf_temp-aht-ot-tot.sale-sum-base        .     export stream ahtlog "temp-aht-ot-tot.sale-sum-rubl"       buf_temp-aht-ot-tot.sale-sum-rubl        .     export stream ahtlog "temp-aht-ot-tot.sale-vat-base"       buf_temp-aht-ot-tot.sale-vat-base        .     export stream ahtlog "temp-aht-ot-tot.sale-vat-rubl"       buf_temp-aht-ot-tot.sale-vat-rubl        .     export stream ahtlog "temp-aht-ot-tot.sale-slt-base"       buf_temp-aht-ot-tot.sale-slt-base        .     export stream ahtlog "temp-aht-ot-tot.sale-slt-rubl"       buf_temp-aht-ot-tot.sale-slt-rubl        .     export stream ahtlog "temp-aht-ot-tot.sale-road-tax-base"  buf_temp-aht-ot-tot.sale-road-tax-base   .     export stream ahtlog "temp-aht-ot-tot.sale-road-tax-rubl"  buf_temp-aht-ot-tot.sale-road-tax-rubl   .     export stream ahtlog "temp-aht-ot-tot.sale-excise-base"    buf_temp-aht-ot-tot.sale-excise-base     .     export stream ahtlog "temp-aht-ot-tot.sale-excise-rubl"    buf_temp-aht-ot-tot.sale-excise-rubl     .     export stream ahtlog "temp-aht-ot-tot.sale-transport-base" buf_temp-aht-ot-tot.sale-transport-base  .     export stream ahtlog "temp-aht-ot-tot.sale-transport-rubl" buf_temp-aht-ot-tot.sale-transport-rubl  .     export stream ahtlog "temp-aht-ot-tot.sale-other-base"     buf_temp-aht-ot-tot.sale-other-base      .     export stream ahtlog "temp-aht-ot-tot.sale-other-rubl"     buf_temp-aht-ot-tot.sale-other-rubl      .     export stream ahtlog "temp-aht-ot-tot.sale-discnt-base"    buf_temp-aht-ot-tot.sale-discnt-base     .     export stream ahtlog "temp-aht-ot-tot.sale-discnt-rubl"    buf_temp-aht-ot-tot.sale-discnt-rubl     .
        output stream ahtlog close .
        undo, return error .
      end.
      find first buf_aht-ot-tot exclusive-lock
        where buf_aht-ot-tot.doc-code = buf_temp-aht-ot-tot.doc-code
          and buf_aht-ot-tot.sum-type = buf_temp-aht-ot-tot.sum-type
        no-error .
      if not available buf_aht-ot-tot then do:
        create buf_aht-ot-tot .
      end.
                  assign
        buf_aht-ot-tot.doc-code     = buf_temp-aht-ot-tot.doc-code       buf_aht-ot-tot.sum-type     = buf_temp-aht-ot-tot.sum-type       buf_aht-ot-tot.ext-doc-type = buf_temp-aht-ot-tot.ext-doc-type   buf_aht-ot-tot.obj-type     = buf_temp-aht-ot-tot.obj-type       buf_aht-ot-tot.obj-code     = buf_temp-aht-ot-tot.obj-code       buf_aht-ot-tot.fact-order   = buf_temp-aht-ot-tot.fact-order
      .
      assign
        buf_aht-ot-tot.fact-qnty = buf_temp-aht-ot-tot.fact-qnty
                                                        buf_aht-ot-tot.cost-sum-base       = buf_temp-aht-ot-tot.cost-sum-base             buf_aht-ot-tot.cost-sum-rubl       = buf_temp-aht-ot-tot.cost-sum-rubl             buf_aht-ot-tot.cost-vat-base       = buf_temp-aht-ot-tot.cost-vat-base             buf_aht-ot-tot.cost-vat-rubl       = buf_temp-aht-ot-tot.cost-vat-rubl             buf_aht-ot-tot.cost-slt-base       = buf_temp-aht-ot-tot.cost-slt-base             buf_aht-ot-tot.cost-slt-rubl       = buf_temp-aht-ot-tot.cost-slt-rubl             buf_aht-ot-tot.cost-road-tax-base  = buf_temp-aht-ot-tot.cost-road-tax-base        buf_aht-ot-tot.cost-road-tax-rubl  = buf_temp-aht-ot-tot.cost-road-tax-rubl        buf_aht-ot-tot.cost-excise-base    = buf_temp-aht-ot-tot.cost-excise-base          buf_aht-ot-tot.cost-excise-rubl    = buf_temp-aht-ot-tot.cost-excise-rubl          buf_aht-ot-tot.cost-transport-base = buf_temp-aht-ot-tot.cost-transport-base       buf_aht-ot-tot.cost-transport-rubl = buf_temp-aht-ot-tot.cost-transport-rubl       buf_aht-ot-tot.cost-other-base     = buf_temp-aht-ot-tot.cost-other-base           buf_aht-ot-tot.cost-other-rubl     = buf_temp-aht-ot-tot.cost-other-rubl           buf_aht-ot-tot.cost-discnt-base    = buf_temp-aht-ot-tot.cost-discnt-base          buf_aht-ot-tot.cost-discnt-rubl    = buf_temp-aht-ot-tot.cost-discnt-rubl
                                                        buf_aht-ot-tot.crsa-sum-base       = buf_temp-aht-ot-tot.crsa-sum-base             buf_aht-ot-tot.crsa-sum-rubl       = buf_temp-aht-ot-tot.crsa-sum-rubl             buf_aht-ot-tot.crsa-vat-base       = buf_temp-aht-ot-tot.crsa-vat-base             buf_aht-ot-tot.crsa-vat-rubl       = buf_temp-aht-ot-tot.crsa-vat-rubl             buf_aht-ot-tot.crsa-slt-base       = buf_temp-aht-ot-tot.crsa-slt-base             buf_aht-ot-tot.crsa-slt-rubl       = buf_temp-aht-ot-tot.crsa-slt-rubl             buf_aht-ot-tot.crsa-road-tax-base  = buf_temp-aht-ot-tot.crsa-road-tax-base        buf_aht-ot-tot.crsa-road-tax-rubl  = buf_temp-aht-ot-tot.crsa-road-tax-rubl        buf_aht-ot-tot.crsa-excise-base    = buf_temp-aht-ot-tot.crsa-excise-base          buf_aht-ot-tot.crsa-excise-rubl    = buf_temp-aht-ot-tot.crsa-excise-rubl          buf_aht-ot-tot.crsa-transport-base = buf_temp-aht-ot-tot.crsa-transport-base       buf_aht-ot-tot.crsa-transport-rubl = buf_temp-aht-ot-tot.crsa-transport-rubl       buf_aht-ot-tot.crsa-other-base     = buf_temp-aht-ot-tot.crsa-other-base           buf_aht-ot-tot.crsa-other-rubl     = buf_temp-aht-ot-tot.crsa-other-rubl           buf_aht-ot-tot.crsa-discnt-base    = buf_temp-aht-ot-tot.crsa-discnt-base          buf_aht-ot-tot.crsa-discnt-rubl    = buf_temp-aht-ot-tot.crsa-discnt-rubl
                                                        buf_aht-ot-tot.sale-sum-base       = buf_temp-aht-ot-tot.sale-sum-base             buf_aht-ot-tot.sale-sum-rubl       = buf_temp-aht-ot-tot.sale-sum-rubl             buf_aht-ot-tot.sale-vat-base       = buf_temp-aht-ot-tot.sale-vat-base             buf_aht-ot-tot.sale-vat-rubl       = buf_temp-aht-ot-tot.sale-vat-rubl             buf_aht-ot-tot.sale-slt-base       = buf_temp-aht-ot-tot.sale-slt-base             buf_aht-ot-tot.sale-slt-rubl       = buf_temp-aht-ot-tot.sale-slt-rubl             buf_aht-ot-tot.sale-road-tax-base  = buf_temp-aht-ot-tot.sale-road-tax-base        buf_aht-ot-tot.sale-road-tax-rubl  = buf_temp-aht-ot-tot.sale-road-tax-rubl        buf_aht-ot-tot.sale-excise-base    = buf_temp-aht-ot-tot.sale-excise-base          buf_aht-ot-tot.sale-excise-rubl    = buf_temp-aht-ot-tot.sale-excise-rubl          buf_aht-ot-tot.sale-transport-base = buf_temp-aht-ot-tot.sale-transport-base       buf_aht-ot-tot.sale-transport-rubl = buf_temp-aht-ot-tot.sale-transport-rubl       buf_aht-ot-tot.sale-other-base     = buf_temp-aht-ot-tot.sale-other-base           buf_aht-ot-tot.sale-other-rubl     = buf_temp-aht-ot-tot.sale-other-rubl           buf_aht-ot-tot.sale-discnt-base    = buf_temp-aht-ot-tot.sale-discnt-base          buf_aht-ot-tot.sale-discnt-rubl    = buf_temp-aht-ot-tot.sale-discnt-rubl
      .
    end.
    for each buf_temp-aht-ot-line
    on error undo, return error
    :
      if
                              buf_temp-aht-ot-line.cost-sum-base       = ? or    buf_temp-aht-ot-line.cost-sum-rubl       = ? or    buf_temp-aht-ot-line.cost-vat-base       = ? or    buf_temp-aht-ot-line.cost-vat-rubl       = ? or    buf_temp-aht-ot-line.cost-slt-base       = ? or    buf_temp-aht-ot-line.cost-slt-rubl       = ? or    buf_temp-aht-ot-line.cost-road-tax-base  = ? or    buf_temp-aht-ot-line.cost-road-tax-rubl  = ? or    buf_temp-aht-ot-line.cost-excise-base    = ? or    buf_temp-aht-ot-line.cost-excise-rubl    = ? or    buf_temp-aht-ot-line.cost-transport-base = ? or    buf_temp-aht-ot-line.cost-transport-rubl = ? or    buf_temp-aht-ot-line.cost-other-base     = ? or    buf_temp-aht-ot-line.cost-other-rubl     = ? or    buf_temp-aht-ot-line.cost-discnt-base    = ? or    buf_temp-aht-ot-line.cost-discnt-rubl    = ?
      or
                              buf_temp-aht-ot-line.crsa-sum-base       = ? or    buf_temp-aht-ot-line.crsa-sum-rubl       = ? or    buf_temp-aht-ot-line.crsa-vat-base       = ? or    buf_temp-aht-ot-line.crsa-vat-rubl       = ? or    buf_temp-aht-ot-line.crsa-slt-base       = ? or    buf_temp-aht-ot-line.crsa-slt-rubl       = ? or    buf_temp-aht-ot-line.crsa-road-tax-base  = ? or    buf_temp-aht-ot-line.crsa-road-tax-rubl  = ? or    buf_temp-aht-ot-line.crsa-excise-base    = ? or    buf_temp-aht-ot-line.crsa-excise-rubl    = ? or    buf_temp-aht-ot-line.crsa-transport-base = ? or    buf_temp-aht-ot-line.crsa-transport-rubl = ? or    buf_temp-aht-ot-line.crsa-other-base     = ? or    buf_temp-aht-ot-line.crsa-other-rubl     = ? or    buf_temp-aht-ot-line.crsa-discnt-base    = ? or    buf_temp-aht-ot-line.crsa-discnt-rubl    = ?
      or
                              buf_temp-aht-ot-line.sale-sum-base       = ? or    buf_temp-aht-ot-line.sale-sum-rubl       = ? or    buf_temp-aht-ot-line.sale-vat-base       = ? or    buf_temp-aht-ot-line.sale-vat-rubl       = ? or    buf_temp-aht-ot-line.sale-slt-base       = ? or    buf_temp-aht-ot-line.sale-slt-rubl       = ? or    buf_temp-aht-ot-line.sale-road-tax-base  = ? or    buf_temp-aht-ot-line.sale-road-tax-rubl  = ? or    buf_temp-aht-ot-line.sale-excise-base    = ? or    buf_temp-aht-ot-line.sale-excise-rubl    = ? or    buf_temp-aht-ot-line.sale-transport-base = ? or    buf_temp-aht-ot-line.sale-transport-rubl = ? or    buf_temp-aht-ot-line.sale-other-base     = ? or    buf_temp-aht-ot-line.sale-other-rubl     = ? or    buf_temp-aht-ot-line.sale-discnt-base    = ? or    buf_temp-aht-ot-line.sale-discnt-rubl    = ?
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info17 skip
          "При расчета складского архива по типам приобретения получено неопределенное значение" skip
          "Документ" buf_temp-aht-ot-line.doc-code skip
          "Код товара" buf_temp-aht-ot-line.gds-code skip
          "Тип суммы" buf_temp-aht-ot-line.sum-type skip
          view-as alert-box error .
        undo, return error .
      end.
      find first buf_aht-ot-line exclusive-lock
        where buf_aht-ot-line.doc-code  = buf_temp-aht-ot-line.doc-code
          and buf_aht-ot-line.gds-code  = buf_temp-aht-ot-line.gds-code
          and buf_aht-ot-line.sum-type  = buf_temp-aht-ot-line.sum-type
        no-error .
      if not available buf_aht-ot-line then do:
        create buf_aht-ot-line .
      end.
                  assign
        buf_aht-ot-line.doc-code     = buf_temp-aht-ot-line.doc-code       buf_aht-ot-line.gds-code     = buf_temp-aht-ot-line.gds-code       buf_aht-ot-line.sum-type     = buf_temp-aht-ot-line.sum-type       buf_aht-ot-line.ext-doc-type = buf_temp-aht-ot-line.ext-doc-type   buf_aht-ot-line.obj-type     = buf_temp-aht-ot-line.obj-type       buf_aht-ot-line.obj-code     = buf_temp-aht-ot-line.obj-code       buf_aht-ot-line.fact-order   = buf_temp-aht-ot-line.fact-order
      .
      assign
        buf_aht-ot-line.fact-qnty = buf_temp-aht-ot-line.fact-qnty
                                                        buf_aht-ot-line.cost-sum-base       = buf_temp-aht-ot-line.cost-sum-base             buf_aht-ot-line.cost-sum-rubl       = buf_temp-aht-ot-line.cost-sum-rubl             buf_aht-ot-line.cost-vat-base       = buf_temp-aht-ot-line.cost-vat-base             buf_aht-ot-line.cost-vat-rubl       = buf_temp-aht-ot-line.cost-vat-rubl             buf_aht-ot-line.cost-slt-base       = buf_temp-aht-ot-line.cost-slt-base             buf_aht-ot-line.cost-slt-rubl       = buf_temp-aht-ot-line.cost-slt-rubl             buf_aht-ot-line.cost-road-tax-base  = buf_temp-aht-ot-line.cost-road-tax-base        buf_aht-ot-line.cost-road-tax-rubl  = buf_temp-aht-ot-line.cost-road-tax-rubl        buf_aht-ot-line.cost-excise-base    = buf_temp-aht-ot-line.cost-excise-base          buf_aht-ot-line.cost-excise-rubl    = buf_temp-aht-ot-line.cost-excise-rubl          buf_aht-ot-line.cost-transport-base = buf_temp-aht-ot-line.cost-transport-base       buf_aht-ot-line.cost-transport-rubl = buf_temp-aht-ot-line.cost-transport-rubl       buf_aht-ot-line.cost-other-base     = buf_temp-aht-ot-line.cost-other-base           buf_aht-ot-line.cost-other-rubl     = buf_temp-aht-ot-line.cost-other-rubl           buf_aht-ot-line.cost-discnt-base    = buf_temp-aht-ot-line.cost-discnt-base          buf_aht-ot-line.cost-discnt-rubl    = buf_temp-aht-ot-line.cost-discnt-rubl
                                                        buf_aht-ot-line.crsa-sum-base       = buf_temp-aht-ot-line.crsa-sum-base             buf_aht-ot-line.crsa-sum-rubl       = buf_temp-aht-ot-line.crsa-sum-rubl             buf_aht-ot-line.crsa-vat-base       = buf_temp-aht-ot-line.crsa-vat-base             buf_aht-ot-line.crsa-vat-rubl       = buf_temp-aht-ot-line.crsa-vat-rubl             buf_aht-ot-line.crsa-slt-base       = buf_temp-aht-ot-line.crsa-slt-base             buf_aht-ot-line.crsa-slt-rubl       = buf_temp-aht-ot-line.crsa-slt-rubl             buf_aht-ot-line.crsa-road-tax-base  = buf_temp-aht-ot-line.crsa-road-tax-base        buf_aht-ot-line.crsa-road-tax-rubl  = buf_temp-aht-ot-line.crsa-road-tax-rubl        buf_aht-ot-line.crsa-excise-base    = buf_temp-aht-ot-line.crsa-excise-base          buf_aht-ot-line.crsa-excise-rubl    = buf_temp-aht-ot-line.crsa-excise-rubl          buf_aht-ot-line.crsa-transport-base = buf_temp-aht-ot-line.crsa-transport-base       buf_aht-ot-line.crsa-transport-rubl = buf_temp-aht-ot-line.crsa-transport-rubl       buf_aht-ot-line.crsa-other-base     = buf_temp-aht-ot-line.crsa-other-base           buf_aht-ot-line.crsa-other-rubl     = buf_temp-aht-ot-line.crsa-other-rubl           buf_aht-ot-line.crsa-discnt-base    = buf_temp-aht-ot-line.crsa-discnt-base          buf_aht-ot-line.crsa-discnt-rubl    = buf_temp-aht-ot-line.crsa-discnt-rubl
                                                        buf_aht-ot-line.sale-sum-base       = buf_temp-aht-ot-line.sale-sum-base             buf_aht-ot-line.sale-sum-rubl       = buf_temp-aht-ot-line.sale-sum-rubl             buf_aht-ot-line.sale-vat-base       = buf_temp-aht-ot-line.sale-vat-base             buf_aht-ot-line.sale-vat-rubl       = buf_temp-aht-ot-line.sale-vat-rubl             buf_aht-ot-line.sale-slt-base       = buf_temp-aht-ot-line.sale-slt-base             buf_aht-ot-line.sale-slt-rubl       = buf_temp-aht-ot-line.sale-slt-rubl             buf_aht-ot-line.sale-road-tax-base  = buf_temp-aht-ot-line.sale-road-tax-base        buf_aht-ot-line.sale-road-tax-rubl  = buf_temp-aht-ot-line.sale-road-tax-rubl        buf_aht-ot-line.sale-excise-base    = buf_temp-aht-ot-line.sale-excise-base          buf_aht-ot-line.sale-excise-rubl    = buf_temp-aht-ot-line.sale-excise-rubl          buf_aht-ot-line.sale-transport-base = buf_temp-aht-ot-line.sale-transport-base       buf_aht-ot-line.sale-transport-rubl = buf_temp-aht-ot-line.sale-transport-rubl       buf_aht-ot-line.sale-other-base     = buf_temp-aht-ot-line.sale-other-base           buf_aht-ot-line.sale-other-rubl     = buf_temp-aht-ot-line.sale-other-rubl           buf_aht-ot-line.sale-discnt-base    = buf_temp-aht-ot-line.sale-discnt-base          buf_aht-ot-line.sale-discnt-rubl    = buf_temp-aht-ot-line.sale-discnt-rubl
      .
    end.
  end.
end procedure.
procedure aht_add-document :
  define input  parameter p-doc-code     like ub.aht-doc.doc-code     no-undo .
  define input  parameter p-obj-type     like ub.aht-doc.obj-type     no-undo .
  define input  parameter p-obj-code     like ub.aht-doc.obj-code     no-undo .
  define input  parameter p-ext-doc-type like ub.aht-doc.ext-doc-type no-undo .
  define input  parameter p-is-trn-doc   like ub.aht-doc.is-trn-doc   no-undo .
  define input  parameter p-fact-order   like ub.aht-doc.fact-order   no-undo .
  define input  parameter p-fact-date    like ub.aht-doc.fact-date    no-undo .
  define input  parameter p-shift-date   like ub.aht-doc.shift-date   no-undo .
  define input  parameter p-shift-num    like ub.aht-doc.shift-num    no-undo .
  define buffer buf_aht-doc for ub.aht-doc .
  do
  on error undo, return error return-value
  :
    find first buf_aht-doc exclusive-lock
      where buf_aht-doc.doc-code = p-doc-code
      no-error .
    if available buf_aht-doc then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info17 skip
        "Попытка повторного создания записи" skip
        "Документ" p-doc-code skip
        view-as alert-box error .
      undo, return error .
    end.
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info17 skip
        "Ошибка задания входных параметров" skip
        "Не задан номер документа" skip
        "Документ" p-doc-code skip
        "Номер документа" p-fact-order skip
        view-as alert-box error .
      undo, return error .
    end.
    create buf_aht-doc .
    assign
      buf_aht-doc.doc-code     = p-doc-code
      buf_aht-doc.obj-type     = p-obj-type
      buf_aht-doc.obj-code     = p-obj-code
      buf_aht-doc.ext-doc-type = p-ext-doc-type
      buf_aht-doc.is-trn-doc   = p-is-trn-doc
      buf_aht-doc.fact-order   = p-fact-order
      buf_aht-doc.fact-date    = p-fact-date
      buf_aht-doc.shift-date   = p-shift-date
      buf_aht-doc.shift-num    = p-shift-num
    .
  end.
end procedure.
procedure aht_add-date :
  define input  parameter p-obj-type     like ub.aht-stk.obj-type     no-undo .
  define input  parameter p-obj-code     like ub.aht-stk.obj-code     no-undo .
  define input  parameter p-stk-type     like ub.aht-stk.stk-type     no-undo .
  define input  parameter p-fact-order   like ub.aht-stk.fact-order   no-undo .
  define input  parameter p-fact-date    like ub.aht-stk.fact-date    no-undo .
  define input  parameter p-shift-date   like ub.aht-stk.shift-date   no-undo .
  define input  parameter p-shift-num    like ub.aht-stk.shift-num    no-undo .
  define buffer buf_aht-stk for ub.aht-stk .
  do
  on error undo, return error return-value
  :
    find first buf_aht-stk no-lock
      where buf_aht-stk.obj-type   = p-obj-type
        and buf_aht-stk.obj-code   = p-obj-code
        and buf_aht-stk.stk-type   = p-stk-type
        and buf_aht-stk.fact-order = p-fact-order
      no-error .
    if not available buf_aht-stk then do:
      create buf_aht-stk .
      assign
        buf_aht-stk.obj-type   = p-obj-type
        buf_aht-stk.obj-code   = p-obj-code
        buf_aht-stk.stk-type   = p-stk-type
        buf_aht-stk.fact-order = p-fact-order
        buf_aht-stk.fact-date  = p-fact-date
        buf_aht-stk.shift-date = p-shift-date
        buf_aht-stk.shift-num  = p-shift-num
      .
    end.
  end.
end procedure.
def var vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE aht-ostatok :
def input parameter x-store-code  like ub.clients.obj-code    no-undo.
def input parameter x-store-type  like ub.clients.obj-type    no-undo.
def input parameter x-tog-shift   as   logical             no-undo.
def input parameter x-date-start  like ub.aht-stk.Fact-date   no-undo.
def input parameter x-date-end    like ub.aht-stk.Fact-date   no-undo.
def input parameter x-shift-start as integer               no-undo.
def input parameter x-shift-end   as integer               no-undo.
def input parameter x-sum-type    like ub.aht-stk.stk-type    no-undo.
def input parameter xTog-obj   as log no-undo.
def output parameter Fact-order  like ub.aht-stk.Fact-order  no-undo.
def var              Fact-order#   like ub.aht-stk.Fact-order  no-undo.
def var              Fact-orderS   as char  no-undo.
def var x-date-start-t  like ub.aht-stk.shift-date   no-undo.
    Assign
      Fact-order   = 0
     .
 x-date-start-t  = x-date-start + 1 .
IF x-date-end = date('') then DO:
   Fact-order = 0 .
   For each obj-list
       WHERE  (NOT xTog-obj OR
              (x-store-type = obj-list.obj-type AND x-store-code = obj-list.obj-code))
              no-lock :
      IF  x-TOG-Shift = False Then DO:
                       find last ub.aht-stk where ub.aht-stk.obj-type = obj-list.obj-type and                                             ub.aht-stk.obj-code = obj-list.obj-code and                                             ub.aht-stk.stk-type = x-sum-type
                            and ub.aht-stk.Fact-date <=  x-date-start
                            and ub.aht-stk.shift-num = 0
                            USE-INDEX obj-date no-lock no-error .
           if Available ub.aht-stk THEN  Assign  Fact-order#  = ub.aht-stk.Fact-order .
      End.
      Else  DO :
          find last ub.aht-stk where ub.aht-stk.obj-type = obj-list.obj-type and                                             ub.aht-stk.obj-code = obj-list.obj-code and                                             ub.aht-stk.stk-type = x-sum-type and
            (ub.aht-stk.shift-date  = x-date-start-t and
            ub.aht-stk.shift-num  < x-shift-start or
            ub.aht-stk.shift-date  < x-date-start-t  )
            and ub.aht-stk.shift-num  > 0
            USE-INDEX obj-Shift no-lock no-error .
         If Available ub.aht-stk then  Assign  Fact-order#  = ub.aht-stk.Fact-order .
        END.
    If Fact-order < Fact-order#  and Fact-order# <> 0  THEN  Fact-order = Fact-order# .
  End.
End.
Else DO:
  For each obj-list  WHERE
     (NOT xTog-obj OR (x-store-type = obj-list.obj-type AND x-store-code = obj-list.obj-code))
      no-lock :
   IF  x-TOG-Shift = False Then DO:
       find last ub.aht-stk where ub.aht-stk.obj-type = obj-list.obj-type and                                             ub.aht-stk.obj-code = obj-list.obj-code and                                             ub.aht-stk.stk-type = x-sum-type and
            ub.aht-stk.Fact-date <= x-date-end
            and ub.aht-stk.shift-num = 0
            USE-INDEX obj-date no-lock no-error.
       If Available ub.aht-stk then  Assign  Fact-order#  = ub.aht-stk.Fact-order .
   END.
   Else DO:
        find last ub.aht-stk where ub.aht-stk.obj-type = obj-list.obj-type and                                             ub.aht-stk.obj-code = obj-list.obj-code and                                             ub.aht-stk.stk-type = x-sum-type and
            (ub.aht-stk.shift-date  = x-date-end and
            ub.aht-stk.shift-num  <= x-shift-end or
            ub.aht-stk.shift-date  < x-date-end       ) and
            ub.aht-stk.shift-num   > 0      use-index obj-Shift no-lock no-error.
            if Available ub.aht-stk THEN Assign  Fact-order#  = ub.aht-stk.Fact-order .
    End.
    if Fact-order < Fact-order#  THEN  Fact-order = Fact-order#.
  End.
End.
END PROCEDURE.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure gdsoattr-name :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-name in g#attr-lib
      (input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-value :
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define output parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-value in g#attr-lib
      (input  p-code
      ,input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-gds-code :
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define input  parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define output parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-gds-code in g#attr-lib
      (input  p-code
      ,input  p-value
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-gds-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-write :
  define input parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define input parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define input parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-write in g#attr-lib
      (input p-gds-code
      ,input p-obj-type
      ,input p-obj-code
      ,input p-code
      ,input p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-exist :
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define output parameter p-exist    as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-exist in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-delete :
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-delete in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-doc-tickets :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-doc-tickets in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-dop-alt-name :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-dop-alt-name in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-gds-margins :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-gds-margins in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-normal-wastage :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-normal-wastage in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-attr-margin-value :
  define input  parameter p-gds-code         as integer   no-undo .
  define input  parameter p-obj-type         as character no-undo .
  define input  parameter p-obj-code         as integer   no-undo .
  define output parameter p-min-value        as decimal   no-undo initial ? .
  define output parameter p-max-value        as decimal   no-undo initial ? .
  define output parameter p-increase-pc      as decimal   no-undo initial ? .
  define output parameter p-rmethod          as character no-undo initial '':U .
  define output parameter p-base             as decimal   no-undo initial ? .
  define output parameter p-range-margin     as integer   no-undo .
  define output parameter p-exists-margin    as logical   no-undo .
  define output parameter p-range-increase   as integer   no-undo .
  define output parameter p-exists-increase  as logical   no-undo .
  define output parameter p-range-rmethod    as integer   no-undo .
  define output parameter p-exists-rmethod   as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-margin-value in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-min-value
      ,output p-max-value
      ,output p-increase-pc
      ,output p-rmethod
      ,output p-base
      ,output p-range-margin
      ,output p-exists-margin
      ,output p-range-increase
      ,output p-exists-increase
      ,output p-range-rmethod
      ,output p-exists-rmethod
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-o-normal-wastage-value :
  define input-output parameter objNormWast as class ibs.th.ref.normwastsub no-undo.
do
on error undo, return error
:
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-o-normal-wastage-value in g#attr-lib
      (input-output objNormWast
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-copy :
  define input  parameter p-code as character no-undo .
  define output parameter p-copy as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-copy in g#attr-lib
      (input  p-code
      ,output p-copy
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-attr_check-code-dt-seasons :
  define input  parameter p-code     like ub.goods.gds-code   no-undo .
  define input  parameter p-obj-type like ub.clients.obj-type no-undo .
  define input  parameter p-obj-code like ub.clients.obj-code no-undo .
  define output parameter p-gds-code like ub.goods.gds-code   no-undo .
  define output parameter p-dt-code  as   integer             no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-code-dt-seasons in g#attr-lib
      (input p-code
      ,input p-obj-type
      ,input p-obj-code
      ,output p-gds-code
      ,output p-dt-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
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
define temp-table temp-tpsi-clients no-undo like ub.clients.
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure tpsi-gds-fill-tpsi-obj-table :
define input parameter p-db-num like ub.db.db-num no-undo .
define variable v-is-tpsi-obj as logical no-undo .
define buffer buf_clients for ub.clients.
  do
  on error undo, return error return-value
  :
    for each temp-tpsi-clients :
      delete temp-tpsi-clients.
    end.
    _clients:
    for each buf_clients no-lock where
          buf_clients.db-num = p-db-num:
      assign
      v-is-tpsi-obj = no.
      run gbl/tpsi-obj.p (
                      input buf_clients.obj-type
                    ,input buf_clients.obj-code
                    ,output v-is-tpsi-obj) .
      if not v-is-tpsi-obj then NEXT _clients.
      create temp-tpsi-clients.
      buffer-copy
      buf_clients to
      temp-tpsi-clients.
    end.
  end.
end procedure.
procedure tpsi-gds-proprietor :
define input parameter p-gds-code like ub.goods.gds-code no-undo .
define input parameter p-db-num   like ub.db.db-num      no-undo .
define output parameter p-proprietor-host-code like ub.clients.host-code no-undo .
define output parameter p-proprietor-obj-type like ub.clients.obj-type no-undo .
define output parameter p-proprietor-obj-code like ub.clients.obj-code no-undo .
define variable v-is-tpsi-obj as logical no-undo .
do
on error undo, return error return-value
:
    define buffer buf_clients for ub.clients.
    define buffer buf_gds-obj-attr for ub.gds-obj-attr.
    assign
    p-proprietor-obj-type = "":U
    p-proprietor-obj-code = ?
    p-proprietor-host-code = ?
    .
    _gds-obj-attr:
    for each buf_clients no-lock where
            buf_clients.db-num = p-db-num,
      each buf_gds-obj-attr no-lock where
          buf_gds-obj-attr.obj-type = buf_Clients.obj-type
      AND buf_gds-obj-attr.obj-code = buf_clients.obj-code
      AND buf_gds-obj-attr.gds-code = p-gds-code
      AND buf_gds-obj-attr.attr-code = 'proprietor':U:
      if logical(buf_gds-obj-attr.attr-value) = yes then do:
        assign
        v-is-tpsi-obj = no.
        run gbl/tpsi-obj.p (
                        input buf_gds-obj-attr.obj-type
                      ,input buf_gds-obj-attr.obj-code
                      ,output v-is-tpsi-obj) .
        if not v-is-tpsi-obj then NEXT _gds-obj-attr.
        assign
        p-proprietor-obj-type = buf_gds-obj-attr.obj-type
        p-proprietor-obj-code = buf_gds-obj-attr.obj-code
        p-proprietor-host-code = buf_clients.host-code
        .
        LEAVE.
      end.
    end.
end.
end procedure.
procedure tpsi-preselect-gds-proprietor :
define input parameter p-gds-code like ub.goods.gds-code no-undo .
define input parameter p-db-num   like ub.db.db-num      no-undo .
define output parameter p-proprietor-host-code like ub.clients.host-code no-undo .
define output parameter p-proprietor-obj-type like ub.clients.obj-type no-undo .
define output parameter p-proprietor-obj-code like ub.clients.obj-code no-undo .
do
on error undo, return error return-value
:
    define buffer buf_clients for ub.clients.
    define buffer buf_gds-obj-attr for ub.gds-obj-attr.
    assign
    p-proprietor-obj-type = "":U
    p-proprietor-obj-code = ?
    p-proprietor-host-code = ?
    .
    _gds-obj-attr:
    for each temp-tpsi-clients no-lock where
            temp-tpsi-clients.db-num = p-db-num,
      each buf_gds-obj-attr no-lock where
          buf_gds-obj-attr.obj-type = temp-tpsi-clients.obj-type
      AND buf_gds-obj-attr.obj-code = temp-tpsi-clients.obj-code
      AND buf_gds-obj-attr.gds-code = p-gds-code
      AND buf_gds-obj-attr.attr-code = 'proprietor':U:
      if logical(buf_gds-obj-attr.attr-value) = yes then do:
        assign
        p-proprietor-obj-type = buf_gds-obj-attr.obj-type
        p-proprietor-obj-code = buf_gds-obj-attr.obj-code
        p-proprietor-host-code = temp-tpsi-clients.host-code
        .
        LEAVE.
      end.
    end.
end.
end procedure.
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
define variable  x-type-pr as character no-undo .
define variable  xserv as char init 'все':U no-undo.
define variable   tprintrubl as log no-undo.
define variable g1 as character no-undo .
define variable g2 as character no-undo .
define variable f_e as integer   no-undo .
define variable x-db-num as integer   no-undo .
def  stream  outstream.
def  stream  outstream2.
define variable    objname           as   char no-undo.
define variable    select-good       as   integer no-undo.
define variable    chosedtype        as   integer no-undo.
define variable    paytype           as   integer no-undo.
define variable    retclassify       as   char  no-undo.
define variable    retsorttype       as   char  no-undo.
define variable    show-negativ      as   logical  no-undo.
define variable    show-negativ-2    as   logical  no-undo.
define variable    sums-only         as   logical  no-undo.
define variable    valtype           as   integer no-undo.
define variable    line              as   char        no-undo.
define variable    firstline         as   logical     no-undo.
define variable tot_tqnty as decimal  no-undo.
define variable break_group as logical no-undo init true.
define variable break_group1 as logical no-undo init true.
define variable str_svoi as character no-undo .
str_svoi = fill(" ", 28 ) + "|СВОИ   " .
define variable stat     as log no-undo .
define variable inperror as log no-undo .
define variable i        as integer no-undo .
define variable p        as integer no-undo init 0 .
define variable kk        as integer no-undo init 0 .
define variable old-page as integer no-undo .
define variable new-page as integer no-undo .
define variable rid-list as character no-undo .
define variable   null-str#      as decimal  no-undo.
define variable   null-str2#     as decimal  no-undo.
define variable   b1-null-str#   as decimal  no-undo.
define variable   b1-null-str2#  as decimal  no-undo.
define variable   b2-null-str#   as decimal  no-undo.
define variable   b2-null-str2#  as decimal  no-undo.
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
define variable gds-zap-nds           like ub.stk-tot.sum-base no-undo.
define variable gds-zap-np            like ub.stk-tot.sum-base no-undo.
define variable f-ostatok-start    as   char  no-undo.
define variable f-ostatok-end      as   char  no-undo.
define variable ostatok-start      as   decimal extent 20 format "->>>>>>>>>>9.<<<" no-undo.
define variable ostatok-end        as   decimal extent 20 format "->>>>>>>>>>9.<<<" no-undo.
define variable b1-ostatok-start   as   decimal extent 20 format "->>>>>>>>>>9.<<<" no-undo.
define variable b1-ostatok-end     as   decimal extent 20 format "->>>>>>>>>>9.<<<" no-undo.
define variable b2-ostatok-start   as   decimal extent 20 format "->>>>>>>>>>9.<<<" no-undo.
define variable b2-ostatok-end     as   decimal extent 20 format "->>>>>>>>>>9.<<<" no-undo.
define variable bi-ostatok-start   as   decimal extent 20 format "->>>>>>>>>>9.<<<" no-undo.
define variable bi-ostatok-end     as   decimal extent 20 format "->>>>>>>>>>9.<<<" no-undo.
define variable bo-ostatok-start   as   decimal extent 20 format "->>>>>>>>>>9.<<<" no-undo.
define variable bo-ostatok-end     as   decimal extent 20 format "->>>>>>>>>>9.<<<" no-undo.
define variable f-prih             as   char  no-undo.
define variable f-rash             as   char  no-undo.
define variable f-kassa            as   char  no-undo.
define variable f-inv              as   char  no-undo.
define variable f-overturn         as   char  no-undo.
define variable prih             as   decimal extent 20 format "->>>>>>>>>>9.<<<" no-undo.
define variable rash             as   decimal extent 20 format "->>>>>>>>>>9.<<<" no-undo.
define variable kassa            as   decimal extent 20 format "->>>>>>>>>>9.<<<" no-undo.
define variable inv              as   decimal extent 20 format "->>>>>>>>>>9.<<<" no-undo.
define variable overturn         as   decimal extent 20 format "->>>>>>>>>>9.<<<" no-undo.
define variable b1-prih             as   decimal extent 20 format "->>>>>>>>>>9.<<<" no-undo.
define variable b1-rash             as   decimal extent 20 format "->>>>>>>>>>9.<<<" no-undo.
define variable b1-kassa            as   decimal extent 20 format "->>>>>>>>>>9.<<<" no-undo.
define variable b1-inv              as   decimal extent 20 format "->>>>>>>>>>9.<<<" no-undo.
define variable b1-overturn         as   decimal extent 20 format "->>>>>>>>>>9.<<<" no-undo.
define variable b2-prih             as   decimal extent 20 format "->>>>>>>>>>9.<<<" no-undo.
define variable b2-rash             as   decimal extent 20 format "->>>>>>>>>>9.<<<" no-undo.
define variable b2-kassa            as   decimal extent 20 format "->>>>>>>>>>9.<<<" no-undo.
define variable b2-inv              as   decimal extent 20 format "->>>>>>>>>>9.<<<" no-undo.
define variable b2-overturn         as   decimal extent 20 format "->>>>>>>>>>9.<<<" no-undo.
define variable bi-prih             as   decimal extent 20 format "->>>>>>>>>>9.<<<" no-undo.
define variable bi-rash             as   decimal extent 20 format "->>>>>>>>>>9.<<<" no-undo.
define variable bi-kassa            as   decimal extent 20 format "->>>>>>>>>>9.<<<" no-undo.
define variable bi-inv              as   decimal extent 20 format "->>>>>>>>>>9.<<<" no-undo.
define variable bi-overturn         as   decimal extent 20 format "->>>>>>>>>>9.<<<" no-undo.
define variable bo-prih             as   decimal extent 20 format "->>>>>>>>>>9.<<<" no-undo.
define variable bo-rash             as   decimal extent 20 format "->>>>>>>>>>9.<<<" no-undo.
define variable bo-kassa            as   decimal extent 20 format "->>>>>>>>>>9.<<<" no-undo.
define variable bo-inv              as   decimal extent 20 format "->>>>>>>>>>9.<<<" no-undo.
define variable bo-overturn         as   decimal extent 20 format "->>>>>>>>>>9.<<<" no-undo.
define variable gds-zap-other         like ub.stk-tot.sum-base no-undo.
define variable bo-gds-zap-other         like ub.stk-tot.sum-base no-undo.
define variable bi-gds-zap-other         like ub.stk-tot.sum-base no-undo.
define variable b1-gds-zap-other         like ub.stk-tot.sum-base no-undo.
define variable b2-gds-zap-other         like ub.stk-tot.sum-base no-undo.
define variable  fact-order-1   like ub.stk-tot.fact-order no-undo.
define variable  quantity1      like ub.stk-tot.fact-qnty  no-undo.
define variable  coast_r1       like ub.stk-tot.sum-rubl   no-undo.
define variable  coast_v1       like ub.stk-tot.sum-rubl   no-undo.
define variable  vat_r1         like ub.stk-tot.sum-rubl   no-undo.
define variable  vat_v1         like ub.stk-tot.sum-rubl   no-undo.
define variable  fact-order-2   like ub.stk-tot.fact-order no-undo.
define variable  quantity2      like ub.stk-tot.fact-qnty  no-undo.
define variable  coast2         like ub.stk-tot.sum-rubl   no-undo.
define variable  coast_r2       like ub.stk-tot.sum-rubl   no-undo.
define variable  coast_v2       like ub.stk-tot.sum-rubl   no-undo.
define variable  vat_r2         like ub.stk-tot.sum-rubl   no-undo.
define variable  vat_v2         like ub.stk-tot.sum-rubl   no-undo.
define variable  quantity    like ub.stk-tot.fact-qnty  no-undo.
define variable  coast       like ub.stk-tot.sum-rubl   no-undo.
define variable  coast_r     like ub.stk-tot.sum-rubl   no-undo.
define variable  coast_v     like ub.stk-tot.sum-rubl   no-undo.
define variable  vat_r       like ub.stk-tot.sum-rubl   no-undo.
define variable  vat_v       like ub.stk-tot.sum-rubl   no-undo.
define variable  slt_r       like ub.stk-tot.sum-rubl   no-undo.
define variable  slt_v       like ub.stk-tot.sum-rubl   no-undo.
define variable  coast3       like ub.stk-tot.sum-rubl   no-undo.
define variable  coast4       like ub.stk-tot.sum-rubl   no-undo.
define variable  temp-str as char no-undo.
define variable xshowcost as logical no-undo .
define variable xshowsale as logical no-undo .
define variable xshowcrsa as logical no-undo .
define variable arh-type-sale as character no-undo .
define variable arh-type-crsa as character no-undo .
define variable arh-type-cost as character no-undo .
define variable arh-type-sadt as character no-undo .
define variable arh-type-cgdt as character no-undo .
define variable arh-type-csdt as character no-undo .
define variable arh-type-allsum  as character no-undo .
define variable str as char format "x(60)" no-undo.
define variable i#i as int no-undo.
define variable xlavel as int  no-undo.
define variable list-field as char no-undo.
define variable str10 as char no-undo.
define frame zapas
        s-bar-code column-label  "Код! ! ":c9 space(0)
        sym1 column-label ":!:!:" format "x(1)"       space(0)
        gds-zap-artic column-label "Артикул! ! ":c16 format "x(16)" space(0)
        sym2 column-label ":!:!:" format "x(1)"                         space(0)
        gds-zap-gds-name column-label "Название товара! ! ":c36 format "x(36)" space(0)
        sym3 column-label ":!:!:" format "x(1)"                                     space(0)
        gds-zap-unit-base column-label "Ед.!изм! " format "x(3)"                  space(0)
        sym4 column-label ":!:!:" format "x(1)"                                     space(0)
        gds-type column-label "Тип!данных! ":c6 format "x(6)"                  space(0)
        sym5 column-label ":!:!:" format "x(1)" space(0)
        f-ostatok-start     column-label "Остаток на!начало! ":c14 format "x(14)"           space(0)
        sym6 column-label ":!:!:" format "x(1)" space(0)
        f-prih       column-label "Приход! ! ":c14     format "x(14)"     space(0)
        sym7 column-label ":!:!:" format "x(1)" space(0)
        f-rash       column-label "Расход! ! ":c14  format "x(14)"   space(0)
        sym8 column-label ":!:!:" format "x(1)" space(0)
        f-kassa             column-label "Касса! ! ":c14  format "x(14)"   space(0)
        sym9  column-label ":!:!:" format "x(1)" space(0)
        f-inv               column-label "Инвентаризация!Смена типа!приобретения":c14  format "x(14)"   space(0)
        sym10 column-label ":!:!:" format "x(1)" space(0)
        f-overturn         column-label "Переоценка!продажной и!учетной цен":c14  format "x(14)"   space(0)
        sym11 column-label ":!:!:" format "x(1)" space(0)
        gds-zap-other      column-label "Скидка! ! ":c13     space(0)
        sym12 column-label ":!:!:" format "x(1)" space(0)
        f-ostatok-end     column-label "Остаток!на конец! ":c14 format "x(14)"           space(0)
    header
        string( "Дата печати : " + string(today,"99.99.9999") +  " , " + string(time, "hh:mm") ) at 5 format "x(35)"
        "Цены указаны в" (if tprintrubl then "руб" else x-base-type )
        string( "Страница " + string( page-number( outstream ), ">>>>>9") ) at 147 format "x(53)" skip
        line format "x(194)" at 1
   with width 232 down stream-io use-text no-box.
     assign
        i = 0
        xlavel        = xvar-lavel
        select-good   = x-selectgood
        paytype       = x-set_pay_type
        retclassify   = xclassify
        retsorttype   = xsorttype
        sums-only     = xsumsonly
        show-negativ  = xshowzero
        show-negativ-2  = xshowzero-2
        xshowcost     = show-cost
        xshowsale     = show-sale
        xshowcrsa     = show-crsa
        firstline     = false
        line          = fill("-", 232)
        valtype       = if (paytype = 1) then 0  else x-set_val_type.
   run report-execute.
procedure report-execute :
define variable gj as integer no-undo init 0.
  if (valtype=0 and x-base-code=0)  or valtype=1
                                then   assign tprintrubl = yes .
                                else   assign tprintrubl = no .
  if reportpageheight = 0 then reportpageheight  = 43.
output stream outstream to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size  value(reportpageheight) .
  find first clients where x-store-type = clients.obj-type and
                           x-store-code = clients.obj-code no-lock no-error.
  if available clients then  objname = clients.obj-name.
                                else  objname="объект не определен".
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
form header
  line format "x(194)" at 1 skip
  "Продолжение - на следующей странице" at 30 skip
  with frame bottomframe width 232 page-bottom no-labels no-box .
view stream outstream frame bottomframe .
     run report-exec1.
  hide stream outstream frame bottomframe .
  hide   stream outstream frame zapas .
  output stream outstream close.
if mFrameView
then do:
   HIDE FRAME InfoFrame.
end.
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
    ,input reportfontNum
    ,output v-user-action
    ,output v-printed
    ) .
end procedure.
procedure clear-line :
 do on error undo, return error return-value :
 define variable l as integer   no-undo init 1.
 repeat L = 1 to 20 :
    assign
        ostatok-start[L]  = 0
        ostatok-end[L]  = 0
  .
 end.
 end.
end procedure.
procedure ost-line :
do
on error undo, return error return-value
:
define input parameter p-store-type like ub.clients.obj-type no-undo .
define input parameter p-store-code like ub.clients.obj-code no-undo.
define input parameter p-gds-code   like goods.gds-code no-undo .
define input parameter p-db-num as integer   no-undo .
define variable p-ok as logical   no-undo .
if  p-tpsy = true then do:
    run ver-owner
    ( input  p-gds-code,
      input  p-db-num  ,
      output p-ok ) .
      if p-ok = true  then
          run ost-line-body(10 , p-store-type , p-store-code) .
      if p-type-tpsy-goods = 2 then
          run ost-line-body(0 , p-store-type , p-store-code) .
end.
if  p-tpsy = false  then do:
 run ost-line-body(0 , p-store-type , p-store-code) .
end.
end.
end procedure.
procedure foreach :
define variable old-type as character no-undo .
define variable old-gds-zap-gds-name as character no-undo .
   old-type = x-type-pr.
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
  run clear-item.
  run clear-line.
  for each obj-list  no-lock :
    if x-type-pr = "cb" then do:
       x-type-pr = "b".
       run ost-line (obj-list.obj-type , obj-list.obj-code , gds-zap-b-code , obj-list.db-num ) .
       x-type-pr = "c".
       run ost-line (obj-list.obj-type , obj-list.obj-code  , gds-zap-b-code , obj-list.db-num) .
       x-type-pr = old-type .
    end.
    else do:
       run ost-line (obj-list.obj-type , obj-list.obj-code  , gds-zap-b-code , obj-list.db-num) .
    end.
  end.
   run ob-line (
          input   x-store-code   ,
          input   x-store-type   ,
          input   gds-zap-b-code ,
          input   fact-order-1,
          input   fact-order-2,
          input   x-type-pr     ,
          input   xtog-obj) .
   run calc-sub-itog .
end procedure.
procedure display-line :
if num-entries(gds-zap-gds-name, "|") = 2 then
assign
  g1 =  entry(1 ,gds-zap-gds-name, "|")
  g2 =  entry(2 ,gds-zap-gds-name, "|")
.
assign
  g1 =  gds-zap-gds-name
  g2 =  ""
.
     i = i + 1.
        if not( not show-negativ-2 and
         ( prih         [1]   = 0 and
          rash          [1]   = 0 and
          kassa         [1]   = 0 and
          inv           [1]   = 0 and
          overturn      [1]   = 0 and
          overturn      [5]   = 0 and
          overturn      [8]   = 0 ) ) then do:
        if  not (not show-negativ  and (
              prih          [1]   = 0 and
              rash          [1]   = 0 and
              kassa         [1]   = 0 and
              inv           [1]   = 0 and
              overturn      [1]   = 0 and
              overturn      [5]   = 0 and
              ostatok-start [1]   = 0 and
              ostatok-end   [1]   = 0   )) then do:
        if not sums-only then do:
            if fr0 = true then do:
              put stream  outstream  tmp#stroka0 format "x(100)" skip.
              if Make-Excel then  put   stream ForExcel unformatted string(tmp#stroka0) skip.
              fr0 = false .
            end.
            if fr = true then do:
              put stream outstream space(10) temp-str format "x(100)" skip.
              if Make-Excel then  put   stream ForExcel unformatted CHR(9) string(temp-str) skip.
              fr = false .
            end.
           run display-str1 in this-procedure.
          end.
        end.
     end.
  end procedure.
procedure print-header :
if not firstline then do:
   run display-title.
   form with FRAME ZAPAS .  DOWN stream   OutStream 1 with FRAME ZAPAS .
end.
 firstline = true .
    if xtog-obj and   x-selectobject <> "currency":u   then  do:
          PUT stream  OutStream  UNFORMATTED     "ПО ОБЪЕКТУ : " + caps(clients.obj-name)  at 30 format "x(170)" skip.
          if Make-Excel then  put   stream ForExcel unformatted   "ПО ОБЪЕКТУ : " + caps(clients.obj-name) format "x(170)" skip.
      end.
      run clear-b1 .
      run clear-b2.
      run clear-bi .
      break_group = true.
      break_group1 = true.
   end procedure.
procedure print-footer :
      if retclassify = "no-classify":u  then run u-line.
       gds-zap-artic = "ИТОГО" .
       run display-bi.
       run u-line.
       end procedure.
procedure u-line :
underline stream outstream  sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12
  s-bar-code
  gds-zap-artic
  gds-zap-gds-name
  gds-zap-unit-base
  gds-type
  f-ostatok-start
  f-prih
  f-rash
  f-kassa
  f-inv
  f-overturn
  f-ostatok-end
  gds-zap-other
  with FRAME ZAPAS .
  DOWN stream   OutStream 1 with FRAME ZAPAS.
end procedure.
procedure p-line :
underline stream outstream  sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12
        gds-zap-artic
        gds-zap-gds-name
        gds-zap-unit-base
        gds-type
        f-ostatok-start
        f-prih
        f-rash
        f-kassa
        f-inv
        f-overturn
        f-ostatok-end
        gds-zap-other
        with FRAME ZAPAS .
        DOWN stream   OutStream 1 with FRAME ZAPAS.
end procedure.
procedure run2 :
     if not xtog-lavel then do:   run run2sort1.    end.
       else do:   run lavel1.      end.
   end procedure.
procedure run2sort1 :
              case select-good :
                  when 1  then do:
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
IF x-SelectObject = "currency":U  OR  xTog-obj THEN DO :
    for each gds-obj  where
          gds-obj.obj-type = x-store-type  and
          gds-obj.obj-code = x-store-code
          and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
                no-lock,
          First goods  where  gds-obj.gds-code   = goods.gds-code
no-lock
BREAK
      BY (temp-gds-list.grp-name)
    BY (temp-gds-list.gds-code) :
      run item-goods ( "3" , "goods" ) .
      if return-value <> "" then NEXT.
        If Last-of(temp-gds-list.grp-name) Then Do:
        If String(Entry(2,"temp-gds-list.grp-name",".")) = "Grp-name"
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
      BREAK
BY (temp-gds-list.grp-name)
    BY temp-gds-list.gds-code :
    run item-goods ( "3" , "goods" ) .
      if return-value <> "" then NEXT.
        If Last-of(temp-gds-list.grp-name) Then Do:
        If String(Entry(2,"temp-gds-list.grp-name",".")) = "Grp-name"
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
                  by temp-gds-list.grp-name
                  by temp-gds-list.gds-code :
                  run item-goods ( input "3" , input "goods" ) .
                  if return-value <> "" then next.
        If Last-of(temp-gds-list.grp-name) Then Do:
        If String(Entry(2,"temp-gds-list.grp-name",".")) = "Grp-name"
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
        by temp-gds-list.grp-name
    by temp-gds-list.gds-code :
    run item-goods ( "3" , "goods" ) .
      if return-value <> "" then next.
        If Last-of(temp-gds-list.grp-name) Then Do:
        If String(Entry(2,"temp-gds-list.grp-name",".")) = "Grp-name"
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
        by (temp-gds-list.grp-name)
        by temp-gds-list.gds-code :
        run item-goods ( "3" , "goods" ) .
        if return-value <> "" then next.
        If Last-of(temp-gds-list.grp-name) Then Do:
        If String(Entry(2,"temp-gds-list.grp-name",".")) = "Grp-name"
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
            by (temp-gds-list.grp-name)
            by temp-gds-list.gds-code :
        run item-goods ( "3" , "goods" ) .
          if return-value <> "" then next.
        If Last-of(temp-gds-list.grp-name) Then Do:
        If String(Entry(2,"temp-gds-list.grp-name",".")) = "Grp-name"
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
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
IF x-SelectObject = "currency":U  OR  xTog-obj THEN DO :
    for each gds-obj  where
          gds-obj.obj-type = x-store-type  and
          gds-obj.obj-code = x-store-code
          and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
                no-lock,
          First goods  where  gds-obj.gds-code   = goods.gds-code
      no-lock,
First gds-list  where gds-obj.gds-code  = gds-list.gds-code
no-lock
BREAK
      BY (gds-list.grp-name)
    BY (gds-list.gds-code) :
      run item-goods ( "3" , "gds-list" ) .
      if return-value <> "" then NEXT.
        If Last-of(gds-list.grp-name) Then Do:
        If String(Entry(2,"gds-list.grp-name",".")) = "Grp-name"
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
      BREAK
BY (gds-list.grp-name)
    BY gds-list.gds-code :
    run item-goods ( "3" , "gds-list" ) .
      if return-value <> "" then NEXT.
        If Last-of(gds-list.grp-name) Then Do:
        If String(Entry(2,"gds-list.grp-name",".")) = "Grp-name"
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
procedure lavel1 :
              case select-good :
                  when 1  then do:
    define buffer buf_obj-list26 for obj-list.
  for each buf_obj-list26 no-lock :
      if xtog-obj and  not (buf_obj-list26.obj-type = x-store-type  and
                            buf_obj-list26.obj-code = x-store-code )
      then next.
        for  each gds-obj   where
                            gds-obj.obj-type = buf_obj-list26.obj-type    and
                            gds-obj.obj-code = buf_obj-list26.obj-code
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
        by temp-gds-list.gds-code :
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
    define buffer buf_obj-list27 for obj-list.
  for each buf_obj-list27 no-lock :
      if xtog-obj and  not (buf_obj-list27.obj-type = x-store-type  and
                            buf_obj-list27.obj-code = x-store-code )
      then next.
        for  each gds-obj   where
                            gds-obj.obj-type = buf_obj-list27.obj-type    and
                            gds-obj.obj-code = buf_obj-list27.obj-code
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
        by temp-gds-list.gds-code :
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
    define buffer buf_obj-list28 for obj-list.
  for each buf_obj-list28 no-lock :
      if xtog-obj and  not (buf_obj-list28.obj-type = x-store-type  and
                            buf_obj-list28.obj-code = x-store-code )
      then next.
        for  each gds-obj   where
                  gds-obj.obj-type = buf_obj-list28.obj-type    and
                  gds-obj.obj-code = buf_obj-list28.obj-code
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
        by temp-gds-list.gds-code :
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
    define buffer buf_obj-list29 for obj-list.
  for each buf_obj-list29 no-lock :
      if xtog-obj and  not (buf_obj-list29.obj-type = x-store-type  and
                            buf_obj-list29.obj-code = x-store-code )
      then next.
        for  each gds-obj   where
                            gds-obj.obj-type = buf_obj-list29.obj-type    and
                            gds-obj.obj-code = buf_obj-list29.obj-code
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
        by gds-list.gds-code :
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
procedure calcitog :
    run aht-ostatok (
        input x-store-code     ,
        input x-store-type     ,
        input x-tog-shift      ,
        input x-date-start - 1 ,
        input date('')         ,
        input x-shift-start    ,
        input x-shift-end      ,
        input "n"    ,
        input xtog-obj         ,
        output  fact-order-1 ) .
    run aht-ostatok (
        input x-store-code  ,
        input x-store-type  , x-tog-shift,
        input x-date-start  ,
        input x-date-end    , x-shift-start,x-shift-end,
        input "n" ,
        input xtog-obj ,
        output  fact-order-2 ).
end procedure.
procedure display-str1  :
   if p-tpsy = no  or ( p-tpsy = true and  p-type-tpsy-goods = 2 ) then do:
         run di-qnty ("кол-во", 1, s-bar-code,gds-zap-artic,gds-zap-gds-name,gds-zap-unit-base,"").
         if xshowcost   then do: run di ( "учет." , 2,"","","","","" ). end.
         if xshowcrsa   then do: run di ( "прод." , 5,"","","","","" ). end.
         if xshowsale   then do: run di ( "док."  , 8,"","","","","" ). end.
         if vat-cost    then do: run di ( "уч.НДС", 3,"","","","","" ). end.
         if vat-crsa    then do: run di ( "пр.НДС", 6,"","","","","" ). end.
         if vat-sale    then do: run di ( "дк.НДС", 9,"","","","","" ). end.
   end.
   if p-tpsy = true  then do:
         if  p-type-tpsy-goods = 3 then
             run di-qnty ("кол-во", 11, s-bar-code,gds-zap-artic,gds-zap-gds-name,gds-zap-unit-base,"").
         else
            run di-qnty ("кол-во", 11, "","",str_svoi,"","").
         if xshowcost   then do: run di ( "учет." , 12,"","","","","" ). end.
         if xshowcrsa   then do: run di ( "прод." , 15,"","","","","" ). end.
         if xshowsale   then do: run di ( "док."  , 18,"","","","","" ). end.
         if vat-cost    then do: run di ( "уч.НДС", 13,"","","","","" ). end.
         if vat-crsa    then do: run di ( "пр.НДС", 16,"","","","","" ). end.
         if vat-sale    then do: run di ( "дк.НДС", 19,"","","","","" ). end.
   end.
end procedure.
procedure display-bi  :
      if p-tpsy = no  or ( p-tpsy = true and  p-type-tpsy-goods = 2 ) then do:
         run di-qnty("кол-во",1,  "", gds-zap-artic ,"" ,"", "bi":u).
         if xshowcost    then do: run di ( "учет." , 2,"","","","","bi":u).  end.
         if xshowcrsa    then do: run di ( "прод." , 5,"","","","","bi":u).  end.
         if xshowsale    then do: run di ( "док."  , 8,"","","","","bi":u).  end.
         if vat-cost     then do: run di ( "уч.НДС", 3,"","","","","bi":u ). end.
         if vat-crsa     then do: run di ( "пр.НДС", 6,"","","","","bi":u ).  end.
         if vat-sale     then do: run di ( "дк.НДС", 9,"","","","","bi":u ).  end.
   end.
   if p-tpsy = true  then do:
         if  p-type-tpsy-goods = 3 then
            run di-qnty("кол-во",11, "" , gds-zap-artic ,""   ,"", "bi":u).
         else
            run di-qnty("кол-во",11, "" , ""      , str_svoi  ,"", "bi":u).
            if xshowcost    then do: run di ( "учет." , 12,"","","","","bi":u).  end.
            if xshowcrsa    then do: run di ( "прод." , 15,"","","","","bi":u).  end.
            if xshowsale    then do: run di ( "док."  , 18,"","","","","bi":u).  end.
            if vat-cost     then do: run di ( "уч.НДС", 13,"","","","","bi":u ). end.
            if vat-crsa     then do: run di ( "пр.НДС", 16,"","","","","bi":u ).  end.
            if vat-sale     then do: run di ( "дк.НДС", 19,"","","","","bi":u ).  end.
   end.
end procedure.
procedure display-bo  :
     if p-tpsy = no  or ( p-tpsy = true and  p-type-tpsy-goods = 2 ) then do:
         run di-qnty("кол-во",1,  "", "ИТОГО ПО" ,"ОБЪЕКТАМ" ,"", "bo":u).
         if xshowcost    then do: run di ("учет." , 2 , "","", "", "", "bo":u).  end.
         if xshowcrsa    then do: run di ("прод." , 5, "","", "", "",  "bo":u).  end.
         if xshowsale    then do: run di ("док." , 8, "","", "", "",  "bo":u).  end.
         if vat-cost    then do: run di ( "уч.НДС", 3,"","","","","bo":u ). end.
         if vat-crsa    then do: run di ( "пр.НДС", 6,"","","","","bo":u ).  end.
         if vat-sale    then do: run di ( "дк.НДС", 9,"","","","","bo":u ).  end.
   end.
   if p-tpsy = true  then do:
         if  p-type-tpsy-goods = 3 then
             run di-qnty("кол-во",11,  "", "ИТОГО ПО" ,"ОБЪЕКТАМ" ,"", "bo":u).
         else
            run di-qnty("кол-во",11,  "", "ИТОГО ПО" ,"ОБЪЕКТАМ                свои товары" ,"", "bo":u).
         if xshowcost    then do: run di ("учет." , 12 ,"","","","","bo":u ).  end.
         if xshowcrsa    then do: run di ("прод." , 15 ,"","","","","bo":u ).  end.
         if xshowsale    then do: run di ("док."  , 18 ,"","","","","bo":u ).  end.
         if vat-cost     then do: run di ( "уч.НДС", 13,"","","","","bo":u ).  end.
         if vat-crsa     then do: run di ( "пр.НДС", 16,"","","","","bo":u ).  end.
         if vat-sale     then do: run di ( "дк.НДС", 19,"","","","","bo":u ).  end.
   end.
end procedure.
procedure display-b1  :
      if not( not show-negativ-2 and
         ( b1-prih          [1]   = 0 and
           b1-rash          [1]   = 0 and
           b1-kassa         [1]   = 0 and
           b1-inv           [1]   = 0 and
           b1-overturn      [1]   = 0 and
           b1-overturn      [5]   = 0 and
           b1-overturn      [8]   = 0 ) ) then do:
        if  not (not show-negativ  and (
              b1-prih          [1]   = 0 and
              b1-rash          [1]   = 0 and
              b1-kassa         [1]   = 0 and
              b1-inv           [1]   = 0 and
              b1-overturn      [1]   = 0 and
              b1-overturn      [5]   = 0 and
              b1-ostatok-start [1]   = 0 and
              b1-ostatok-end   [1]   = 0   )) then do:
              if sums-only then do:
                  if fr0 = true then do:
                      put stream  outstream  tmp#stroka0 format "x(100)" skip.
                      if Make-Excel then  put   stream ForExcel unformatted string(tmp#stroka0) skip.
                      fr0 = false .
                    end.
               end.
   if p-tpsy = no  or ( p-tpsy = true and  p-type-tpsy-goods = 2 ) then do:
        run di-qnty in this-procedure ("кол-во"  ,1, s-bar-code, gds-zap-artic, gds-zap-gds-name  ,"","b1":u).
        if xshowcost    then do: run di in this-procedure ("учет." ,2 ,"","", "", "", "b1":u).  end.
        if xshowcrsa    then do: run di in this-procedure ("прод." , 5, "","", "", "", "b1":u).  end.
        if xshowsale    then do: run di in this-procedure ("док." , 8, "","", "", "", "b1":u).  end.
        if vat-cost    then do: run di in this-procedure ( "уч.НДС", 3,"","","","","b1":u ). end.
        if vat-crsa    then do: run di in this-procedure ( "пр.НДС", 6,"","","","","b1":u ).  end.
        if vat-sale    then do: run di in this-procedure ( "дк.НДС", 9,"","","","","b1":u ).  end.
   end.
   if p-tpsy = true  then do:
         if  p-type-tpsy-goods = 3 then
             run di-qnty ("кол-во"  ,11, s-bar-code, gds-zap-artic, gds-zap-gds-name  ,"","b1":u).
         else
            run di-qnty in this-procedure ("кол-во"  ,11, "","", str_svoi, "","b1":u).
        if xshowcost    then do: run di in this-procedure ("учет." ,12 ,"","", "", "", "b1":u).  end.
        if xshowcrsa    then do: run di in this-procedure ("прод." ,15, "","", "", "", "b1":u).  end.
        if xshowsale    then do: run di in this-procedure ("док." , 18, "","", "", "", "b1":u).  end.
        if vat-cost    then do: run di in this-procedure ( "уч.НДС", 13,"","","","","b1":u ). end.
        if vat-crsa    then do: run di in this-procedure ( "пр.НДС", 16,"","","","","b1":u ).  end.
        if vat-sale    then do: run di in this-procedure ( "дк.НДС", 19,"","","","","b1":u ).  end.
   end.
       if not sums-only then run p-line.
 end.
 end.
end procedure.
procedure display-b2  :
     if not( not show-negativ-2 and
         ( b2-prih         [1]   = 0 and
           b2-rash          [1]   = 0 and
           b2-kassa         [1]   = 0 and
           b2-inv           [1]   = 0 and
           b2-overturn      [1]   = 0 and
           b2-overturn      [5]   = 0 and
           b2-overturn      [8]   = 0 ) ) then do:
        if  not (not show-negativ  and (
              b2-prih          [1]   = 0 and
              b2-rash          [1]   = 0 and
              b2-kassa         [1]   = 0 and
              b2-inv           [1]   = 0 and
              b2-overturn      [1]   = 0 and
              b2-overturn      [5]   = 0 and
              b2-ostatok-start [1]   = 0 and
              b2-ostatok-end   [1]   = 0   )) then do:
   if p-tpsy = no  or ( p-tpsy = true and  p-type-tpsy-goods = 2 ) then do:
        run di-qnty( "кол-во", 1 ,s-bar-code,gds-zap-artic, gds-zap-gds-name,"", "b2":u).
        if xshowcost    then do: run di ("учет.", 2, "","", "", "", "b2":u).  end.
        if xshowcrsa    then do: run di ("прод.", 5 ,"","", "", "", "b2":u).  end.
        if xshowsale    then do: run di ("док.", 8 ,"","", "", "", "b2":u).  end.
         if vat-cost    then do: run di ( "уч.НДС", 3,"","","","","b2":u ). end.
         if vat-crsa    then do: run di ( "пр.НДС", 6,"","","","","b2":u ).  end.
         if vat-sale    then do: run di ( "дк.НДС", 9,"","","","","b2":u ).  end.
   end.
   if p-tpsy = true  then do:
         if  p-type-tpsy-goods = 3 then
             run di-qnty ("кол-во"  ,11, s-bar-code, gds-zap-artic, gds-zap-gds-name  ,"","b2":u).
         else
          run di-qnty( "кол-во", 11 ,"","", str_svoi,"", "b2":u).
        if xshowcost    then do: run di ("учет.", 12, "","", "", "", "b2":u).  end.
        if xshowcrsa    then do: run di ("прод.", 15 ,"","", "", "", "b2":u).  end.
        if xshowsale    then do: run di ("док.", 18 ,"","", "", "", "b2":u).  end.
         if vat-cost    then do: run di ( "уч.НДС", 13,"","","","","b2":u ). end.
         if vat-crsa    then do: run di ( "пр.НДС", 16,"","","","","b2":u ).  end.
         if vat-sale    then do: run di ( "дк.НДС", 19,"","","","","b2":u ).  end.
   end.
 end.
end.
end procedure.
procedure clear-b1  :
 b1-gds-zap-other           = 0.
 repeat kk = 1 to 20 :
 assign
    b1-prih                                            [kk]    = 0
    b1-rash                                            [kk]    = 0
    b1-kassa                                           [kk]    = 0
    b1-inv                                             [kk]    = 0
    b1-overturn                                        [kk]    = 0
    b1-ostatok-end                                     [kk]    = 0
    b1-ostatok-start                                   [kk]    = 0   .
   end.
 end procedure.
procedure clear-b2  :
 b2-gds-zap-other      = 0.
 repeat kk = 1 to 20 :
 assign
    b2-prih                                            [kk]    = 0
    b2-rash                                            [kk]    = 0
    b2-kassa                                           [kk]    = 0
    b2-inv                                             [kk]    = 0
    b2-overturn                                        [kk]    = 0
    b2-ostatok-end                                     [kk]    = 0
    b2-ostatok-start                                   [kk]    = 0   .
   end.
end procedure.
procedure clear-bi  :
 bi-gds-zap-other           = 0.
 repeat kk = 1 to 20 :
 assign
    bi-prih                                            [kk]    = 0
    bi-rash                                            [kk]    = 0
    bi-kassa                                           [kk]    = 0
    bi-inv                                             [kk]    = 0
    bi-overturn                                        [kk]    = 0
    bi-ostatok-end                                     [kk]    = 0
    bi-ostatok-start                                   [kk]    = 0   .
   end.
end procedure.
procedure display-title :
define variable v-nn as integer   no-undo .
   PUT stream  OutStream  UNFORMATTED  string( v-cntxt-host-name-obj +  " , " + x-store-type  +  " " + objname) at 50 format "x(85)" skip(2)
          reportname  at 20 format "x(170)" skip
          trim(str1)  at 35 format "x(75)" skip.
     v-nn = num-entries(str2,chr(10)) .
     repeat i = 1 to v-nn :
      PUT stream  OutStream  UNFORMATTED  entry(i,str2,chr(10))  at 1 format "x(170)" skip.
     end.
    i=0.
     PUT stream  OutStream  UNFORMATTED  trim(str3)  at 35 format "x(75)" skip.
     v-nn = num-entries(str4,chr(10)) .
     repeat i = 1 to v-nn:
       PUT stream  OutStream  UNFORMATTED  entry(i,str4,chr(10))  at 1 format "x(170)" skip.
     end.
    i=0.
     v-nn = num-entries( reportheader,chr(10)) .
     repeat i = 1 to v-nn :
      PUT stream  OutStream  UNFORMATTED  entry(i,reportheader,chr(10))  at 1 format "x(170)" skip.
     end.
    i=0.
    run rep/extitle.p (1) .
end procedure.
procedure report-exec1  :
   find first clients where x-store-type = clients.obj-type and
                            x-store-code = clients.obj-code no-lock no-error.
  run calcitog.
  run print-header.
   case retclassify :
      when "grp-goods":u then      run run2 in this-procedure .
      otherwise do:
        message "error" view-as alert-box error .
      end.
   end case.
  run print-footer.
  end procedure.
procedure calc-sub-itog :
define variable b  as int no-undo.
assign
  b1-gds-zap-other = b1-gds-zap-other +  gds-zap-other
  b2-gds-zap-other = b2-gds-zap-other +  gds-zap-other
  bi-gds-zap-other = bi-gds-zap-other +  gds-zap-other
  bo-gds-zap-other = bo-gds-zap-other +  gds-zap-other
  .
repeat b = 1 to 20 :
  assign
  b1-ostatok-start[b ]    = b1-ostatok-start[b ]    +  ostatok-start[b ]
  b1-ostatok-end  [b ]    = b1-ostatok-end  [b ]    +  ostatok-end  [b ]
  b2-ostatok-start[b ]    = b2-ostatok-start[b ]    +  ostatok-start[b ]
  b2-ostatok-end  [b ]    = b2-ostatok-end  [b ]    +  ostatok-end  [b ]
  bi-ostatok-start[b ]    = bi-ostatok-start[b ]    +  ostatok-start[b ]
  bi-ostatok-end  [b ]    = bi-ostatok-end  [b ]    +  ostatok-end  [b ]
  bo-ostatok-start[b ]    = bo-ostatok-start[b ]    +  ostatok-start[b ]
  bo-ostatok-end  [b ]    = bo-ostatok-end  [b ]    +  ostatok-end  [b ]
  b1-prih[b ]    = b1-prih[b ]    +  prih[b ]
  b2-prih[b ]    = b2-prih[b ]    +  prih[b ]
  bi-prih[b ]    = bi-prih[b ]    +  prih[b ]
  bo-prih[b ]    = bo-prih[b ]    +  prih[b ]
  b1-rash[b ]    = b1-rash[b ]    +  rash[b ]
  b2-rash[b ]    = b2-rash[b ]    +  rash[b ]
  bi-rash[b ]    = bi-rash[b ]    +  rash[b ]
  bo-rash[b ]    = bo-rash[b ]    +  rash[b ]
  b1-kassa[b ]    = b1-kassa[b ]    +  kassa[b ]
  b2-kassa[b ]    = b2-kassa[b ]    +  kassa[b ]
  bi-kassa[b ]    = bi-kassa[b ]    +  kassa[b ]
  bo-kassa[b ]    = bo-kassa[b ]    +  kassa[b ]
  b1-inv[b ]    = b1-inv[b ]    +  inv[b ]
  b2-inv[b ]    = b2-inv[b ]    +  inv[b ]
  bi-inv[b ]    = bi-inv[b ]    +  inv[b ]
  bo-inv[b ]    = bo-inv[b ]    +  inv[b ]
  b1-overturn[b ]    = b1-overturn[b ]    +  overturn[b ]
  b2-overturn[b ]    = b2-overturn[b ]    +  overturn[b ]
  bi-overturn[b ]    = bi-overturn[b ]    +  overturn[b ]
  bo-overturn[b ]    = bo-overturn[b ]    +  overturn[b ]
  .
end.
end procedure.
procedure clear-item :
define variable kk as int no-undo.
 gds-zap-other = 0 .
 repeat kk = 1 to 20 :
 assign
    prih            [kk]    = 0
    rash            [kk]    = 0
    kassa           [kk]    = 0
    inv             [kk]    = 0
    overturn        [kk]    = 0
    ostatok-end     [kk]    = 0
    ostatok-start   [kk]    = 0 .
       end.
 end procedure.
procedure item-goods :
   def input parameter  par-3 as char no-undo.
   def input parameter  par-4 as char no-undo.
     if par-4 = "goods":u  then do:
        assign
            gds-zap-unit-base  = goods.unit-base
            gds-zap-prt-root   = goods.prt-root
            gds-zap-prod-type  = goods.prod-type
            gds-zap-prod-code  = goods.prod-code
            gds-zap-artic      = goods.artic
            gds-zap-grp-name   = goods.grp-name
            gds-zap-b-code     = goods.gds-code
            gds-zap-type       = goods.gds-type.
        if g#gds-engl then
            assign gds-zap-gds-name = goods.engl-name.
        else
            assign gds-zap-gds-name = goods.gds-name.
     end.
     if par-4 = "gds-list":u  then do:
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
     end.
    define variable old-gds-zap-gds-name as character no-undo .
    old-gds-zap-gds-name = gds-zap-gds-name.
    x-type-pr = "r".
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
    gds-zap-gds-name = string(old-gds-zap-gds-name,"x(28)") + "|" + "Выкуп".
    run display-line.
    x-type-pr = "cb".
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
    gds-zap-gds-name = string(old-gds-zap-gds-name,"x(28)") + "|"   + "Консиг".
    run display-line.
    x-type-pr = "s".
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
    gds-zap-gds-name = string(old-gds-zap-gds-name,"x(28)") + "|"   + "Отв.хр.".
    run display-line.
    x-type-pr = 'o':U.
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
    gds-zap-gds-name = string(old-gds-zap-gds-name,"x(28)") + "|"   + "Ст.конс".
    run display-line.
 end procedure.
procedure di :
def input parameter p1 as char no-undo.
def input parameter p2 as int no-undo.
def input parameter p3 as char no-undo.
def input parameter p4 as char no-undo.
def input parameter p5 as char no-undo.
def input parameter p6 as char no-undo.
def input parameter p7 as char no-undo.
 case caps(p7) :
   when "b1":u  then do:
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
                end.
   when "b2":u  then  do:
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
              end.
   when "bi":u then  do:
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
              end.
   when "bo":u then  do:
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
              end.
   when ""  then  do:
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
              end.
   end case.
 end procedure.
procedure di-qnty :
def input parameter p1 as char no-undo.
def input parameter p2 as int no-undo.
def input parameter p3 as char no-undo.
def input parameter p4 as char no-undo.
def input parameter p5 as char no-undo.
def input parameter p6 as char no-undo.
def input parameter p7 as char no-undo.
 case caps(p7) :
   when "b1":u  then do :
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
              if num-entries(g1, "|") = 2 then assign  g1 =  "" .
              p6 = "" .
              gds-zap-type = "" .
 if  p2 > 10  then f_e = 10 .
              else f_e =  0 .
if Make-Excel then  put   stream ForExcel unformatted
  p3 CHR(9)
  p4 CHR(9)
  if f_e = 0 then g1 else p5 CHR(9)
  p6 CHR(9)
  gds-zap-type CHR(9)
  excel-sum(b1-gds-zap-other   )  CHR(9)
  excel-qnty(b1-ostatok-start[1  + f_e ])  CHR(9)
  excel-sum(b1-ostatok-start[2  + f_e ])  CHR(9)
  excel-sum(b1-ostatok-start[5  + f_e ])  CHR(9)
  excel-sum(b1-ostatok-start[8  + f_e ])  CHR(9)
  .
  if Make-Excel then  put   stream ForExcel unformatted
  excel-sum(b1-ostatok-start[3  + f_e ])  CHR(9)
  excel-sum(b1-ostatok-start[6  + f_e ])  CHR(9)
  excel-sum(b1-ostatok-start[9  + f_e ])  CHR(9)
  excel-qnty(b1-Prih        [1  + f_e ])  CHR(9)
  excel-sum(b1-Prih         [2  + f_e ])  CHR(9)
  excel-sum(b1-Prih         [5  + f_e ])  CHR(9)
  excel-sum(b1-Prih         [8  + f_e ])  CHR(9)
  excel-sum(b1-Prih         [3  + f_e ])  CHR(9)
  excel-sum(b1-Prih         [6  + f_e ])  CHR(9)
  excel-sum(b1-Prih         [9  + f_e ])  CHR(9)
  .
  if Make-Excel then  put   stream ForExcel unformatted
  excel-qnty(b1-RAsh        [1  + f_e ])  CHR(9)
  excel-sum(b1-RAsh         [2  + f_e ])  CHR(9)
  excel-sum(b1-RAsh         [5  + f_e ])  CHR(9)
  excel-sum(b1-RAsh         [8  + f_e ])  CHR(9)
  excel-sum(b1-RAsh         [3  + f_e ])  CHR(9)
  excel-sum(b1-RAsh         [6  + f_e ])  CHR(9)
  excel-sum(b1-RAsh         [9  + f_e ])  CHR(9)
  excel-qnty(b1-KAssa       [1  + f_e ])  CHR(9)
  excel-sum(b1-KAssa        [2  + f_e ])  CHR(9)
  excel-sum(b1-KAssa        [5  + f_e ])  CHR(9)
  excel-sum(b1-KAssa        [8  + f_e ])  CHR(9)
  excel-sum(b1-KAssa        [3  + f_e ])  CHR(9)
  excel-sum(b1-KAssa        [6  + f_e ])  CHR(9)
  .
  if Make-Excel then  put   stream ForExcel unformatted
  excel-sum(b1-KAssa        [9  + f_e ])  CHR(9)
  excel-qnty(b1-Inv         [1  + f_e ])  CHR(9)
  excel-sum(b1-Inv          [2  + f_e ])  CHR(9)
  excel-sum(b1-Inv          [5  + f_e ])  CHR(9)
  excel-sum(b1-Inv          [8  + f_e ])  CHR(9)
  excel-sum(b1-Inv          [3  + f_e ])  CHR(9)
  excel-sum(b1-Inv          [6  + f_e ])  CHR(9)
  excel-sum(b1-Inv          [9  + f_e ])  CHR(9)
  .
  if Make-Excel then  put   stream ForExcel unformatted
  excel-qnty(b1-Overturn    [1  + f_e ])  CHR(9)
  excel-sum(b1-Overturn     [2  + f_e ])  CHR(9)
  excel-sum(b1-Overturn     [5  + f_e ])  CHR(9)
  excel-sum(b1-Overturn     [8  + f_e ])  CHR(9)
  excel-sum(b1-Overturn     [3  + f_e ])  CHR(9)
  excel-sum(b1-Overturn     [6  + f_e ])  CHR(9)
  excel-sum(b1-Overturn     [9  + f_e ])  CHR(9)
  excel-qnty(b1-Ostatok-end [1  + f_e ])  CHR(9)
  excel-sum(b1-Ostatok-end  [2  + f_e ])  CHR(9)
  excel-sum(b1-Ostatok-end  [5  + f_e ])  CHR(9)
  excel-sum(b1-Ostatok-end  [8  + f_e ])  CHR(9)
  excel-sum(b1-Ostatok-end  [3  + f_e ])  CHR(9)
  excel-sum(b1-Ostatok-end  [6  + f_e ])  CHR(9)
  excel-sum(b1-Ostatok-end  [9  + f_e ])  CHR(9)
  g2
  skip.
                end.
   when "b2":u  then do :
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
              assign
              g1 = p5
              p6 = "" .
              gds-zap-type = "" .
 if  p2 > 10  then f_e = 10 .
              else f_e =  0 .
if Make-Excel then  put   stream ForExcel unformatted
  p3 CHR(9)
  p4 CHR(9)
  if f_e = 0 then g1 else p5 CHR(9)
  p6 CHR(9)
  gds-zap-type CHR(9)
  excel-sum(b2-gds-zap-other   )  CHR(9)
  excel-qnty(b2-ostatok-start[1  + f_e ])  CHR(9)
  excel-sum(b2-ostatok-start[2  + f_e ])  CHR(9)
  excel-sum(b2-ostatok-start[5  + f_e ])  CHR(9)
  excel-sum(b2-ostatok-start[8  + f_e ])  CHR(9)
  .
  if Make-Excel then  put   stream ForExcel unformatted
  excel-sum(b2-ostatok-start[3  + f_e ])  CHR(9)
  excel-sum(b2-ostatok-start[6  + f_e ])  CHR(9)
  excel-sum(b2-ostatok-start[9  + f_e ])  CHR(9)
  excel-qnty(b2-Prih        [1  + f_e ])  CHR(9)
  excel-sum(b2-Prih         [2  + f_e ])  CHR(9)
  excel-sum(b2-Prih         [5  + f_e ])  CHR(9)
  excel-sum(b2-Prih         [8  + f_e ])  CHR(9)
  excel-sum(b2-Prih         [3  + f_e ])  CHR(9)
  excel-sum(b2-Prih         [6  + f_e ])  CHR(9)
  excel-sum(b2-Prih         [9  + f_e ])  CHR(9)
  .
  if Make-Excel then  put   stream ForExcel unformatted
  excel-qnty(b2-RAsh        [1  + f_e ])  CHR(9)
  excel-sum(b2-RAsh         [2  + f_e ])  CHR(9)
  excel-sum(b2-RAsh         [5  + f_e ])  CHR(9)
  excel-sum(b2-RAsh         [8  + f_e ])  CHR(9)
  excel-sum(b2-RAsh         [3  + f_e ])  CHR(9)
  excel-sum(b2-RAsh         [6  + f_e ])  CHR(9)
  excel-sum(b2-RAsh         [9  + f_e ])  CHR(9)
  excel-qnty(b2-KAssa       [1  + f_e ])  CHR(9)
  excel-sum(b2-KAssa        [2  + f_e ])  CHR(9)
  excel-sum(b2-KAssa        [5  + f_e ])  CHR(9)
  excel-sum(b2-KAssa        [8  + f_e ])  CHR(9)
  excel-sum(b2-KAssa        [3  + f_e ])  CHR(9)
  excel-sum(b2-KAssa        [6  + f_e ])  CHR(9)
  .
  if Make-Excel then  put   stream ForExcel unformatted
  excel-sum(b2-KAssa        [9  + f_e ])  CHR(9)
  excel-qnty(b2-Inv         [1  + f_e ])  CHR(9)
  excel-sum(b2-Inv          [2  + f_e ])  CHR(9)
  excel-sum(b2-Inv          [5  + f_e ])  CHR(9)
  excel-sum(b2-Inv          [8  + f_e ])  CHR(9)
  excel-sum(b2-Inv          [3  + f_e ])  CHR(9)
  excel-sum(b2-Inv          [6  + f_e ])  CHR(9)
  excel-sum(b2-Inv          [9  + f_e ])  CHR(9)
  .
  if Make-Excel then  put   stream ForExcel unformatted
  excel-qnty(b2-Overturn    [1  + f_e ])  CHR(9)
  excel-sum(b2-Overturn     [2  + f_e ])  CHR(9)
  excel-sum(b2-Overturn     [5  + f_e ])  CHR(9)
  excel-sum(b2-Overturn     [8  + f_e ])  CHR(9)
  excel-sum(b2-Overturn     [3  + f_e ])  CHR(9)
  excel-sum(b2-Overturn     [6  + f_e ])  CHR(9)
  excel-sum(b2-Overturn     [9  + f_e ])  CHR(9)
  excel-qnty(b2-Ostatok-end [1  + f_e ])  CHR(9)
  excel-sum(b2-Ostatok-end  [2  + f_e ])  CHR(9)
  excel-sum(b2-Ostatok-end  [5  + f_e ])  CHR(9)
  excel-sum(b2-Ostatok-end  [8  + f_e ])  CHR(9)
  excel-sum(b2-Ostatok-end  [3  + f_e ])  CHR(9)
  excel-sum(b2-Ostatok-end  [6  + f_e ])  CHR(9)
  excel-sum(b2-Ostatok-end  [9  + f_e ])  CHR(9)
  g2
  skip.
             end.
   when "bi":u then  do :
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
             g1 = p5 .
             p6 = "" .
             gds-zap-type = "" .
 if  p2 > 10  then f_e = 10 .
              else f_e =  0 .
if Make-Excel then  put   stream ForExcel unformatted
  p3 CHR(9)
  p4 CHR(9)
  if f_e = 0 then g1 else p5 CHR(9)
  p6 CHR(9)
  gds-zap-type CHR(9)
  excel-sum(bi-gds-zap-other   )  CHR(9)
  excel-qnty(bi-ostatok-start[1  + f_e ])  CHR(9)
  excel-sum(bi-ostatok-start[2  + f_e ])  CHR(9)
  excel-sum(bi-ostatok-start[5  + f_e ])  CHR(9)
  excel-sum(bi-ostatok-start[8  + f_e ])  CHR(9)
  .
  if Make-Excel then  put   stream ForExcel unformatted
  excel-sum(bi-ostatok-start[3  + f_e ])  CHR(9)
  excel-sum(bi-ostatok-start[6  + f_e ])  CHR(9)
  excel-sum(bi-ostatok-start[9  + f_e ])  CHR(9)
  excel-qnty(bi-Prih        [1  + f_e ])  CHR(9)
  excel-sum(bi-Prih         [2  + f_e ])  CHR(9)
  excel-sum(bi-Prih         [5  + f_e ])  CHR(9)
  excel-sum(bi-Prih         [8  + f_e ])  CHR(9)
  excel-sum(bi-Prih         [3  + f_e ])  CHR(9)
  excel-sum(bi-Prih         [6  + f_e ])  CHR(9)
  excel-sum(bi-Prih         [9  + f_e ])  CHR(9)
  .
  if Make-Excel then  put   stream ForExcel unformatted
  excel-qnty(bi-RAsh        [1  + f_e ])  CHR(9)
  excel-sum(bi-RAsh         [2  + f_e ])  CHR(9)
  excel-sum(bi-RAsh         [5  + f_e ])  CHR(9)
  excel-sum(bi-RAsh         [8  + f_e ])  CHR(9)
  excel-sum(bi-RAsh         [3  + f_e ])  CHR(9)
  excel-sum(bi-RAsh         [6  + f_e ])  CHR(9)
  excel-sum(bi-RAsh         [9  + f_e ])  CHR(9)
  excel-qnty(bi-KAssa       [1  + f_e ])  CHR(9)
  excel-sum(bi-KAssa        [2  + f_e ])  CHR(9)
  excel-sum(bi-KAssa        [5  + f_e ])  CHR(9)
  excel-sum(bi-KAssa        [8  + f_e ])  CHR(9)
  excel-sum(bi-KAssa        [3  + f_e ])  CHR(9)
  excel-sum(bi-KAssa        [6  + f_e ])  CHR(9)
  .
  if Make-Excel then  put   stream ForExcel unformatted
  excel-sum(bi-KAssa        [9  + f_e ])  CHR(9)
  excel-qnty(bi-Inv         [1  + f_e ])  CHR(9)
  excel-sum(bi-Inv          [2  + f_e ])  CHR(9)
  excel-sum(bi-Inv          [5  + f_e ])  CHR(9)
  excel-sum(bi-Inv          [8  + f_e ])  CHR(9)
  excel-sum(bi-Inv          [3  + f_e ])  CHR(9)
  excel-sum(bi-Inv          [6  + f_e ])  CHR(9)
  excel-sum(bi-Inv          [9  + f_e ])  CHR(9)
  .
  if Make-Excel then  put   stream ForExcel unformatted
  excel-qnty(bi-Overturn    [1  + f_e ])  CHR(9)
  excel-sum(bi-Overturn     [2  + f_e ])  CHR(9)
  excel-sum(bi-Overturn     [5  + f_e ])  CHR(9)
  excel-sum(bi-Overturn     [8  + f_e ])  CHR(9)
  excel-sum(bi-Overturn     [3  + f_e ])  CHR(9)
  excel-sum(bi-Overturn     [6  + f_e ])  CHR(9)
  excel-sum(bi-Overturn     [9  + f_e ])  CHR(9)
  excel-qnty(bi-Ostatok-end [1  + f_e ])  CHR(9)
  excel-sum(bi-Ostatok-end  [2  + f_e ])  CHR(9)
  excel-sum(bi-Ostatok-end  [5  + f_e ])  CHR(9)
  excel-sum(bi-Ostatok-end  [8  + f_e ])  CHR(9)
  excel-sum(bi-Ostatok-end  [3  + f_e ])  CHR(9)
  excel-sum(bi-Ostatok-end  [6  + f_e ])  CHR(9)
  excel-sum(bi-Ostatok-end  [9  + f_e ])  CHR(9)
  g2
  skip.
             end.
   when "bo":u then  do :
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
             g1 = p5 .
              p6 = "" .
             gds-zap-type = "" .
 if  p2 > 10  then f_e = 10 .
              else f_e =  0 .
if Make-Excel then  put   stream ForExcel unformatted
  p3 CHR(9)
  p4 CHR(9)
  if f_e = 0 then g1 else p5 CHR(9)
  p6 CHR(9)
  gds-zap-type CHR(9)
  excel-sum(bo-gds-zap-other   )  CHR(9)
  excel-qnty(bo-ostatok-start[1  + f_e ])  CHR(9)
  excel-sum(bo-ostatok-start[2  + f_e ])  CHR(9)
  excel-sum(bo-ostatok-start[5  + f_e ])  CHR(9)
  excel-sum(bo-ostatok-start[8  + f_e ])  CHR(9)
  .
  if Make-Excel then  put   stream ForExcel unformatted
  excel-sum(bo-ostatok-start[3  + f_e ])  CHR(9)
  excel-sum(bo-ostatok-start[6  + f_e ])  CHR(9)
  excel-sum(bo-ostatok-start[9  + f_e ])  CHR(9)
  excel-qnty(bo-Prih        [1  + f_e ])  CHR(9)
  excel-sum(bo-Prih         [2  + f_e ])  CHR(9)
  excel-sum(bo-Prih         [5  + f_e ])  CHR(9)
  excel-sum(bo-Prih         [8  + f_e ])  CHR(9)
  excel-sum(bo-Prih         [3  + f_e ])  CHR(9)
  excel-sum(bo-Prih         [6  + f_e ])  CHR(9)
  excel-sum(bo-Prih         [9  + f_e ])  CHR(9)
  .
  if Make-Excel then  put   stream ForExcel unformatted
  excel-qnty(bo-RAsh        [1  + f_e ])  CHR(9)
  excel-sum(bo-RAsh         [2  + f_e ])  CHR(9)
  excel-sum(bo-RAsh         [5  + f_e ])  CHR(9)
  excel-sum(bo-RAsh         [8  + f_e ])  CHR(9)
  excel-sum(bo-RAsh         [3  + f_e ])  CHR(9)
  excel-sum(bo-RAsh         [6  + f_e ])  CHR(9)
  excel-sum(bo-RAsh         [9  + f_e ])  CHR(9)
  excel-qnty(bo-KAssa       [1  + f_e ])  CHR(9)
  excel-sum(bo-KAssa        [2  + f_e ])  CHR(9)
  excel-sum(bo-KAssa        [5  + f_e ])  CHR(9)
  excel-sum(bo-KAssa        [8  + f_e ])  CHR(9)
  excel-sum(bo-KAssa        [3  + f_e ])  CHR(9)
  excel-sum(bo-KAssa        [6  + f_e ])  CHR(9)
  .
  if Make-Excel then  put   stream ForExcel unformatted
  excel-sum(bo-KAssa        [9  + f_e ])  CHR(9)
  excel-qnty(bo-Inv         [1  + f_e ])  CHR(9)
  excel-sum(bo-Inv          [2  + f_e ])  CHR(9)
  excel-sum(bo-Inv          [5  + f_e ])  CHR(9)
  excel-sum(bo-Inv          [8  + f_e ])  CHR(9)
  excel-sum(bo-Inv          [3  + f_e ])  CHR(9)
  excel-sum(bo-Inv          [6  + f_e ])  CHR(9)
  excel-sum(bo-Inv          [9  + f_e ])  CHR(9)
  .
  if Make-Excel then  put   stream ForExcel unformatted
  excel-qnty(bo-Overturn    [1  + f_e ])  CHR(9)
  excel-sum(bo-Overturn     [2  + f_e ])  CHR(9)
  excel-sum(bo-Overturn     [5  + f_e ])  CHR(9)
  excel-sum(bo-Overturn     [8  + f_e ])  CHR(9)
  excel-sum(bo-Overturn     [3  + f_e ])  CHR(9)
  excel-sum(bo-Overturn     [6  + f_e ])  CHR(9)
  excel-sum(bo-Overturn     [9  + f_e ])  CHR(9)
  excel-qnty(bo-Ostatok-end [1  + f_e ])  CHR(9)
  excel-sum(bo-Ostatok-end  [2  + f_e ])  CHR(9)
  excel-sum(bo-Ostatok-end  [5  + f_e ])  CHR(9)
  excel-sum(bo-Ostatok-end  [8  + f_e ])  CHR(9)
  excel-sum(bo-Ostatok-end  [3  + f_e ])  CHR(9)
  excel-sum(bo-Ostatok-end  [6  + f_e ])  CHR(9)
  excel-sum(bo-Ostatok-end  [9  + f_e ])  CHR(9)
  g2
  skip.
             end.
   when ""  then     do :
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
 if  p2 > 10  then f_e = 10 .
              else f_e =  0 .
if Make-Excel then  put   stream ForExcel unformatted
  p3 CHR(9)
  p4 CHR(9)
  if f_e = 0 then g1 else p5 CHR(9)
  p6 CHR(9)
  gds-zap-type CHR(9)
  excel-sum(gds-zap-other   )  CHR(9)
  excel-qnty(ostatok-start[1  + f_e ])  CHR(9)
  excel-sum(ostatok-start[2  + f_e ])  CHR(9)
  excel-sum(ostatok-start[5  + f_e ])  CHR(9)
  excel-sum(ostatok-start[8  + f_e ])  CHR(9)
  .
  if Make-Excel then  put   stream ForExcel unformatted
  excel-sum(ostatok-start[3  + f_e ])  CHR(9)
  excel-sum(ostatok-start[6  + f_e ])  CHR(9)
  excel-sum(ostatok-start[9  + f_e ])  CHR(9)
  excel-qnty(Prih        [1  + f_e ])  CHR(9)
  excel-sum(Prih         [2  + f_e ])  CHR(9)
  excel-sum(Prih         [5  + f_e ])  CHR(9)
  excel-sum(Prih         [8  + f_e ])  CHR(9)
  excel-sum(Prih         [3  + f_e ])  CHR(9)
  excel-sum(Prih         [6  + f_e ])  CHR(9)
  excel-sum(Prih         [9  + f_e ])  CHR(9)
  .
  if Make-Excel then  put   stream ForExcel unformatted
  excel-qnty(RAsh        [1  + f_e ])  CHR(9)
  excel-sum(RAsh         [2  + f_e ])  CHR(9)
  excel-sum(RAsh         [5  + f_e ])  CHR(9)
  excel-sum(RAsh         [8  + f_e ])  CHR(9)
  excel-sum(RAsh         [3  + f_e ])  CHR(9)
  excel-sum(RAsh         [6  + f_e ])  CHR(9)
  excel-sum(RAsh         [9  + f_e ])  CHR(9)
  excel-qnty(KAssa       [1  + f_e ])  CHR(9)
  excel-sum(KAssa        [2  + f_e ])  CHR(9)
  excel-sum(KAssa        [5  + f_e ])  CHR(9)
  excel-sum(KAssa        [8  + f_e ])  CHR(9)
  excel-sum(KAssa        [3  + f_e ])  CHR(9)
  excel-sum(KAssa        [6  + f_e ])  CHR(9)
  .
  if Make-Excel then  put   stream ForExcel unformatted
  excel-sum(KAssa        [9  + f_e ])  CHR(9)
  excel-qnty(Inv         [1  + f_e ])  CHR(9)
  excel-sum(Inv          [2  + f_e ])  CHR(9)
  excel-sum(Inv          [5  + f_e ])  CHR(9)
  excel-sum(Inv          [8  + f_e ])  CHR(9)
  excel-sum(Inv          [3  + f_e ])  CHR(9)
  excel-sum(Inv          [6  + f_e ])  CHR(9)
  excel-sum(Inv          [9  + f_e ])  CHR(9)
  .
  if Make-Excel then  put   stream ForExcel unformatted
  excel-qnty(Overturn    [1  + f_e ])  CHR(9)
  excel-sum(Overturn     [2  + f_e ])  CHR(9)
  excel-sum(Overturn     [5  + f_e ])  CHR(9)
  excel-sum(Overturn     [8  + f_e ])  CHR(9)
  excel-sum(Overturn     [3  + f_e ])  CHR(9)
  excel-sum(Overturn     [6  + f_e ])  CHR(9)
  excel-sum(Overturn     [9  + f_e ])  CHR(9)
  excel-qnty(Ostatok-end [1  + f_e ])  CHR(9)
  excel-sum(Ostatok-end  [2  + f_e ])  CHR(9)
  excel-sum(Ostatok-end  [5  + f_e ])  CHR(9)
  excel-sum(Ostatok-end  [8  + f_e ])  CHR(9)
  excel-sum(Ostatok-end  [3  + f_e ])  CHR(9)
  excel-sum(Ostatok-end  [6  + f_e ])  CHR(9)
  excel-sum(Ostatok-end  [9  + f_e ])  CHR(9)
  g2
  skip.
              end.
   end case.
               DOWN stream   OutStream 1 with FRAME ZAPAS.
 end procedure.
procedure ost-line-body :
do on error undo, return error return-value :
define input parameter p-num        as   integer   no-undo .
define input parameter p-store-type like ub.clients.obj-type no-undo .
define input parameter p-store-code like ub.clients.obj-code no-undo .
 find last  ub.aht-stk-line where
                        ub.aht-stk-line.gds-code   = gds-zap-b-code
                  and   ub.aht-stk-line.fact-order <= fact-order-1
                  and   ub.aht-stk-line.obj-code   = p-store-code
                  and   ub.aht-stk-line.obj-type   = p-store-type
                  and   ub.aht-stk-line.sum-type   = x-type-pr
                        use-index category no-lock no-error.
        if available ub.aht-stk-line then do:
            if  tprintrubl  then
                  assign
                        ostatok-start[1 + p-num]  = ostatok-start[1 + p-num] +  (if ub.aht-stk-line.sum-type <> "b"
                                                                then round( ub.aht-stk-line.fact-qnty,3) else 0 )
                        ostatok-start[2 + p-num]  =ostatok-start[2 + p-num] +  round( ub.aht-stk-line.cost-sum-rubl ,2)
                        ostatok-start[3 + p-num]  =ostatok-start[3 + p-num] +  round( ub.aht-stk-line.cost-vat-rubl ,2)
                        ostatok-start[4 + p-num]  =ostatok-start[4 + p-num] +  0
                        ostatok-start[5 + p-num]  =ostatok-start[5 + p-num]  + round( ub.aht-stk-line.crsa-sum-rubl ,2)
                        ostatok-start[6 + p-num]  =ostatok-start[6 + p-num]  + round( ub.aht-stk-line.crsa-vat-rubl ,2)
                        ostatok-start[7 + p-num]  =ostatok-start[7 + p-num]  + round( ub.aht-stk-line.sale-discnt-rubl ,2)
                        ostatok-start[8 + p-num]  =ostatok-start[8 + p-num]  + round( ub.aht-stk-line.crsa-sum-rubl ,2)
                        ostatok-start[9 + p-num]  =ostatok-start[9 + p-num]  + round( ub.aht-stk-line.crsa-vat-rubl ,2)
                        ostatok-start[10 + p-num] =ostatok-start[10 + p-num] + round( ub.aht-stk-line.crsa-slt-rubl ,2)
                        .
              else
                  assign
                        ostatok-start[1 + p-num]  = ostatok-start[1 + p-num] + (if ub.aht-stk-line.sum-type <> "b"
                                                                   then round( ub.aht-stk-line.fact-qnty,3) else 0 )
                        ostatok-start[2 + p-num]  = ostatok-start[2 + p-num] +  round( ub.aht-stk-line.cost-sum-base ,2)
                        ostatok-start[3 + p-num]  = ostatok-start[3 + p-num] +  round( ub.aht-stk-line.cost-vat-base ,2)
                        ostatok-start[4 + p-num]  = ostatok-start[4 + p-num] +  0
                        ostatok-start[5 + p-num]  = ostatok-start[5 + p-num]  + round( ub.aht-stk-line.crsa-sum-base ,2)
                        ostatok-start[6 + p-num]  = ostatok-start[6 + p-num]  + round( ub.aht-stk-line.crsa-vat-base ,2)
                        ostatok-start[7 + p-num]  = ostatok-start[7 + p-num]  + round( ub.aht-stk-line.sale-discnt-base ,2)
                        ostatok-start[8 + p-num]  = ostatok-start[8 + p-num]  + round( ub.aht-stk-line.crsa-sum-base ,2)
                        ostatok-start[9 + p-num]  = ostatok-start[9 + p-num]  + round( ub.aht-stk-line.crsa-vat-base ,2)
                        ostatok-start[10 + p-num] = ostatok-start[10 + p-num] + round( ub.aht-stk-line.crsa-slt-base ,2)
                  .
             end.
 find last  ub.aht-stk-line where
                        ub.aht-stk-line.gds-code   = gds-zap-b-code
                  and   ub.aht-stk-line.fact-order <= fact-order-2
                  and   ub.aht-stk-line.obj-code   = p-store-code
                  and   ub.aht-stk-line.obj-type   = p-store-type
                  and   ub.aht-stk-line.sum-type   = x-type-pr
                        use-index category no-lock no-error.
        if available ub.aht-stk-line then do:
            if  tprintrubl  then
                  assign
                        ostatok-end[1 + p-num]  = ostatok-end[1 + p-num] + (if ub.aht-stk-line.sum-type <> "b"
                                                               then round( ub.aht-stk-line.fact-qnty,3) else 0 )
                        ostatok-end[2 + p-num]  = ostatok-end[2 + p-num] + round( ub.aht-stk-line.cost-sum-rubl ,2)
                        ostatok-end[3 + p-num]  = ostatok-end[3 + p-num] + round( ub.aht-stk-line.cost-vat-rubl ,2)
                        ostatok-end[4 + p-num]  = ostatok-end[4 + p-num] + 0
                        ostatok-end[5 + p-num]  = ostatok-end[5 + p-num] + round( ub.aht-stk-line.crsa-sum-rubl ,2)
                        ostatok-end[6 + p-num]  = ostatok-end[6 + p-num] + round( ub.aht-stk-line.crsa-vat-rubl ,2)
                        ostatok-end[7 + p-num]  = ostatok-end[7 + p-num] + round( ub.aht-stk-line.sale-discnt-rubl ,2)
                        ostatok-end[8 + p-num]  = ostatok-end[8 + p-num] + round( ub.aht-stk-line.crsa-sum-rubl ,2)
                        ostatok-end[9 + p-num]  = ostatok-end[9 + p-num] + round( ub.aht-stk-line.crsa-vat-rubl ,2)
                        ostatok-end[10 + p-num] = ostatok-end[10 + p-num] + round( ub.aht-stk-line.crsa-slt-rubl ,2)
                        .
              else
                  assign
                        ostatok-end[1 + p-num]  = ostatok-end[1 + p-num] +  (if ub.aht-stk-line.sum-type <> "b"
                                                                then round( ub.aht-stk-line.fact-qnty,3) else 0 )
                        ostatok-end[2 + p-num]  = ostatok-end[2 + p-num] +  round( ub.aht-stk-line.cost-sum-base ,2)
                        ostatok-end[3 + p-num]  = ostatok-end[3 + p-num] +  round( ub.aht-stk-line.cost-vat-base ,2)
                        ostatok-end[4 + p-num]  = ostatok-end[4 + p-num] +  0
                        ostatok-end[5 + p-num]  = ostatok-end[5 + p-num] +  round( ub.aht-stk-line.crsa-sum-base ,2)
                        ostatok-end[6 + p-num]  = ostatok-end[6 + p-num] +  round( ub.aht-stk-line.crsa-vat-base ,2)
                        ostatok-end[7 + p-num]  = ostatok-end[7 + p-num] +  round( ub.aht-stk-line.sale-discnt-base ,2)
                        ostatok-end[8 + p-num]  = ostatok-end[8 + p-num] +  round( ub.aht-stk-line.crsa-sum-base ,2)
                        ostatok-end[9 + p-num]  = ostatok-end[9 + p-num] +  round( ub.aht-stk-line.crsa-vat-base ,2)
                        ostatok-end[10 + p-num] = ostatok-end[10 + p-num] + round( ub.aht-stk-line.crsa-slt-base ,2)
                  .
             end.
end.
end procedure.
procedure ob-line  :
do on error undo, return error return-value :
def input  parameter x-store-code     like ub.clients.obj-code         no-undo .
def input  parameter x-store-type     like ub.clients.obj-type         no-undo .
def input  parameter x-gds-code       like ub.aht-ot-line.gds-code     no-undo .
def input  parameter x-fact-order-1   like ub.aht-ot-line.fact-order   no-undo .
def input  parameter x-fact-order-2   like ub.aht-ot-line.fact-order   no-undo .
def input  parameter x-sum-type       like ub.aht-ot-line.sum-type     no-undo .
def input  parameter xtog-obj         as logical no-undo .
define variable      tt#              as integer no-undo .
define variable x-type-pr1 as character no-undo .
define variable x-type-pr2 as character no-undo .
define variable p-ok as logical   no-undo .
 if x-sum-type = arh-type-cost then tt# = 0 .
 if x-sum-type = arh-type-crsa then tt# = 3 .
 if x-sum-type = arh-type-sale then tt# = 6 .
if  x-sum-type = "cb" then
 assign
    x-type-pr1 = "c"
    x-type-pr2 = "b"
 .
else
 assign
    x-type-pr1 = x-sum-type
    x-type-pr2 = x-sum-type
 .
  for each obj-list  no-lock :
     for each ub.aht-ot-line where
                      ( ub.aht-ot-line.gds-code      = x-gds-code
                  and   ub.aht-ot-line.fact-order   <= x-fact-order-2
                  and   ub.aht-ot-line.fact-order   >= x-fact-order-1
                  and   ub.aht-ot-line.obj-code     = obj-list.obj-code
                  and   ub.aht-ot-line.obj-type     = obj-list.obj-type
                  and   ub.aht-ot-line.sum-type     = x-type-pr1 )
                  OR  ( ub.aht-ot-line.gds-code      = x-gds-code
                  and   ub.aht-ot-line.fact-order   <= x-fact-order-2
                  and   ub.aht-ot-line.fact-order   >= x-fact-order-1
                  and   ub.aht-ot-line.obj-code     = obj-list.obj-code
                  and   ub.aht-ot-line.obj-type     = obj-list.obj-type
                  and   ub.aht-ot-line.sum-type     = x-type-pr2 )
                  no-lock :
    if  p-tpsy = true then do:
        run ver-owner2
        ( input  ub.aht-ot-line.gds-code,
          input  ub.aht-ot-line.obj-type,
          input  ub.aht-ot-line.obj-code,
          output p-ok ) .
    end.
    case ub.aht-ot-line.ext-doc-type:
              when        'ie':U  or
              when        're':U  or
              when        'iv':U    or
              when        'rv':U or
              when        'im':U     then
              do:
              assign
                     prih[1 ]   = prih[1 ]   + (if ub.aht-ot-line.sum-type <> "b" then round( ub.aht-ot-line.fact-qnty,3) else 0 )
                     prih[2 ]   = prih[2 ]   +  if tprintrubl then ub.aht-ot-line.cost-sum-rubl else  ub.aht-ot-line.cost-sum-base
                     prih[3 ]   = prih[3 ]   +  if tprintrubl then ub.aht-ot-line.cost-vat-rubl else  ub.aht-ot-line.cost-vat-base
                     prih[4 ]   = prih[4 ]
                     prih[5 ]   = prih[5 ]   +  if tprintrubl then ub.aht-ot-line.crsa-sum-rubl else  ub.aht-ot-line.crsa-sum-base
                     prih[6 ]   = prih[6 ]   +  if tprintrubl then ub.aht-ot-line.crsa-vat-rubl else  ub.aht-ot-line.crsa-vat-base
                     prih[7 ]   = prih[7 ]   +  if tprintrubl then ub.aht-ot-line.sale-discnt-rubl else  ub.aht-ot-line.sale-discnt-base
                     prih[8 ]   = prih[8 ]   +  if tprintrubl then ub.aht-ot-line.sale-sum-rubl else  ub.aht-ot-line.sale-sum-base
                     prih[9 ]   = prih[9 ]   +  if tprintrubl then ub.aht-ot-line.sale-vat-rubl else  ub.aht-ot-line.sale-vat-base
                     gds-zap-other   = gds-zap-other  +  if tprintrubl then ub.aht-ot-line.sale-discnt-rubl else  ub.aht-ot-line.sale-discnt-base
               .
     if p-ok = true then do:
        assign
          prih[11 ]   = prih[11 ]   + (if ub.aht-ot-line.sum-type <> "b" then round( ub.aht-ot-line.fact-qnty,3) else 0 )
          prih[12 ]   = prih[12 ]   +  if tprintrubl then ub.aht-ot-line.cost-sum-rubl else  ub.aht-ot-line.cost-sum-base
          prih[13 ]   = prih[13 ]   +  if tprintrubl then ub.aht-ot-line.cost-vat-rubl else  ub.aht-ot-line.cost-vat-base
          prih[14 ]   = prih[14 ]
          prih[15 ]   = prih[15 ]   +  if tprintrubl then ub.aht-ot-line.crsa-sum-rubl else  ub.aht-ot-line.crsa-sum-base
          prih[16 ]   = prih[16 ]   +  if tprintrubl then ub.aht-ot-line.crsa-vat-rubl else  ub.aht-ot-line.crsa-vat-base
          prih[17 ]   = prih[17 ]   +  if tprintrubl then ub.aht-ot-line.sale-discnt-rubl else  ub.aht-ot-line.sale-discnt-base
          prih[18 ]   = prih[18 ]   +  if tprintrubl then ub.aht-ot-line.sale-sum-rubl else  ub.aht-ot-line.sale-sum-base
          prih[19 ]   = prih[19 ]   +  if tprintrubl then ub.aht-ot-line.sale-vat-rubl else  ub.aht-ot-line.sale-vat-base
          .
     end.
              end.
              when       'ee':U      or
              when       'ep':U    or
              when       'ev':U     or
              when       'em':U       or
              when       'wm':U       or
              when       'we':U     then
              do:
                assign
                    rash[1  ]   = rash[1 ]   +  (if ub.aht-ot-line.sum-type <> "b" then round( ub.aht-ot-line.fact-qnty,3) else 0 )
                    rash[2  ]   = rash[2 ]   +  if tprintrubl then ub.aht-ot-line.cost-sum-rubl else  ub.aht-ot-line.cost-sum-base
                    rash[3 ]   = rash[3 ]   +  if tprintrubl then ub.aht-ot-line.cost-vat-rubl else  ub.aht-ot-line.cost-vat-base
                    rash[4 ]   = rash[4 ]
                    rash[5 ]   = rash[5 ]   +  if tprintrubl then ub.aht-ot-line.crsa-sum-rubl else  ub.aht-ot-line.crsa-sum-base
                    rash[6 ]   = rash[6 ]   +  if tprintrubl then ub.aht-ot-line.crsa-vat-rubl else  ub.aht-ot-line.crsa-vat-base
                    rash[7 ]   = rash[7 ]   +  if tprintrubl then ub.aht-ot-line.sale-discnt-rubl else  ub.aht-ot-line.sale-discnt-base
                    rash[8 ]   = rash[8 ]   +  if tprintrubl then ub.aht-ot-line.sale-sum-rubl else  ub.aht-ot-line.sale-sum-base
                    rash[9 ]   = rash[9 ]   +  if tprintrubl then ub.aht-ot-line.sale-vat-rubl else  ub.aht-ot-line.sale-vat-base
                    gds-zap-other   = gds-zap-other  +  if tprintrubl then ub.aht-ot-line.sale-discnt-rubl else  ub.aht-ot-line.sale-discnt-base
              .
                if p-ok = true then do:
                  assign
                    rash[11  ]   = rash[11 ]   +  (if ub.aht-ot-line.sum-type <> "b" then round( ub.aht-ot-line.fact-qnty,3) else 0 )
                    rash[12  ]   = rash[12 ]   +  if tprintrubl then ub.aht-ot-line.cost-sum-rubl else  ub.aht-ot-line.cost-sum-base
                    rash[13 ]   = rash[13 ]   +  if tprintrubl then ub.aht-ot-line.cost-vat-rubl else  ub.aht-ot-line.cost-vat-base
                    rash[14 ]   = rash[14 ]
                    rash[15 ]   = rash[15 ]   +  if tprintrubl then ub.aht-ot-line.crsa-sum-rubl else  ub.aht-ot-line.crsa-sum-base
                    rash[16 ]   = rash[16 ]   +  if tprintrubl then ub.aht-ot-line.crsa-vat-rubl else  ub.aht-ot-line.crsa-vat-base
                    rash[17 ]   = rash[17 ]   +  if tprintrubl then ub.aht-ot-line.sale-discnt-rubl else  ub.aht-ot-line.sale-discnt-base
                    rash[18 ]   = rash[18 ]   +  if tprintrubl then ub.aht-ot-line.sale-sum-rubl else  ub.aht-ot-line.sale-sum-base
                    rash[19 ]   = rash[19 ]   +  if tprintrubl then ub.aht-ot-line.sale-vat-rubl else  ub.aht-ot-line.sale-vat-base
                  .
                end.
              end.
              when       'es':U  or
              when       'rs':U then
              do:
                  assign
                    kassa[1  ]   = kassa[1 ]   +  (if ub.aht-ot-line.sum-type <> "b" then round( ub.aht-ot-line.fact-qnty,3) else 0 )
                    kassa[2  ]   = kassa[2 ]   +  if tprintrubl then ub.aht-ot-line.cost-sum-rubl else  ub.aht-ot-line.cost-sum-base
                    kassa[3  ]   = kassa[3 ]   +  if tprintrubl then ub.aht-ot-line.cost-vat-rubl else  ub.aht-ot-line.cost-vat-base
                    kassa[4  ]   = kassa[4 ]
                    kassa[5  ]   = kassa[5 ]   +  if tprintrubl then ub.aht-ot-line.crsa-sum-rubl else  ub.aht-ot-line.crsa-sum-base
                    kassa[6  ]   = kassa[6 ]   +  if tprintrubl then ub.aht-ot-line.crsa-vat-rubl else  ub.aht-ot-line.crsa-vat-base
                    kassa[7  ]   = kassa[7 ]   +  if tprintrubl then ub.aht-ot-line.sale-discnt-rubl else  ub.aht-ot-line.sale-discnt-base
                    kassa[8  ]   = kassa[8 ]   +  if tprintrubl then ub.aht-ot-line.sale-sum-rubl else  ub.aht-ot-line.sale-sum-base
                    kassa[9  ]   = kassa[9 ]   +  if tprintrubl then ub.aht-ot-line.sale-vat-rubl else  ub.aht-ot-line.sale-vat-base
                    gds-zap-other   = gds-zap-other  +  if tprintrubl then ub.aht-ot-line.sale-discnt-rubl else  ub.aht-ot-line.sale-discnt-base
                    .
                  if p-ok = true then
                  assign
                    kassa[11  ]   = kassa[11 ]   +  (if ub.aht-ot-line.sum-type <> "b" then round( ub.aht-ot-line.fact-qnty,3) else 0 )
                    kassa[12  ]   = kassa[12 ]   +  if tprintrubl then ub.aht-ot-line.cost-sum-rubl else  ub.aht-ot-line.cost-sum-base
                    kassa[13  ]   = kassa[13 ]   +  if tprintrubl then ub.aht-ot-line.cost-vat-rubl else  ub.aht-ot-line.cost-vat-base
                    kassa[14  ]   = kassa[14 ]
                    kassa[15  ]   = kassa[15 ]   +  if tprintrubl then ub.aht-ot-line.crsa-sum-rubl else  ub.aht-ot-line.crsa-sum-base
                    kassa[16  ]   = kassa[16 ]   +  if tprintrubl then ub.aht-ot-line.crsa-vat-rubl else  ub.aht-ot-line.crsa-vat-base
                    kassa[17  ]   = kassa[17 ]   +  if tprintrubl then ub.aht-ot-line.sale-discnt-rubl else  ub.aht-ot-line.sale-discnt-base
                    kassa[18  ]   = kassa[18 ]   +  if tprintrubl then ub.aht-ot-line.sale-sum-rubl else  ub.aht-ot-line.sale-sum-base
                    kassa[19  ]   = kassa[19 ]   +  if tprintrubl then ub.aht-ot-line.sale-vat-rubl else  ub.aht-ot-line.sale-vat-base
                    .
              end.
          when       'vt':U            or
          when       'pc':U or
          when       'vp':U       then do:
              assign
                inv[1  ]   = inv[1 ]   +  (if ub.aht-ot-line.sum-type <> "b" then round( ub.aht-ot-line.fact-qnty,3) else 0 )
                inv[2  ]   = inv[2 ]   +  if tprintrubl then ub.aht-ot-line.cost-sum-rubl else  ub.aht-ot-line.cost-sum-base
                inv[3  ]   = inv[3 ]   +  if tprintrubl then ub.aht-ot-line.cost-vat-rubl else  ub.aht-ot-line.cost-vat-base
                inv[4  ]   = inv[4 ]
                inv[5  ]   = inv[5 ]   +  if tprintrubl then ub.aht-ot-line.crsa-sum-rubl else  ub.aht-ot-line.crsa-sum-base
                inv[6  ]   = inv[6 ]   +  if tprintrubl then ub.aht-ot-line.crsa-vat-rubl else  ub.aht-ot-line.crsa-vat-base
                inv[7  ]   = inv[7 ]   +  if tprintrubl then ub.aht-ot-line.sale-discnt-rubl else  ub.aht-ot-line.sale-discnt-base
                inv[8  ]   = inv[8 ]   +  if tprintrubl then ub.aht-ot-line.sale-sum-rubl else  ub.aht-ot-line.sale-sum-base
                inv[9  ]   = inv[9 ]   +  if tprintrubl then ub.aht-ot-line.sale-vat-rubl else  ub.aht-ot-line.sale-vat-base
                gds-zap-other   = gds-zap-other  +  if tprintrubl then ub.aht-ot-line.sale-discnt-rubl else  ub.aht-ot-line.sale-discnt-base
                .
              if p-ok = true then
              assign
                inv[11  ]   = inv[11 ]   +  (if ub.aht-ot-line.sum-type <> "b" then round( ub.aht-ot-line.fact-qnty,3) else 0 )
                inv[12  ]   = inv[12 ]   +  if tprintrubl then ub.aht-ot-line.cost-sum-rubl else  ub.aht-ot-line.cost-sum-base
                inv[13  ]   = inv[13 ]   +  if tprintrubl then ub.aht-ot-line.cost-vat-rubl else  ub.aht-ot-line.cost-vat-base
                inv[14  ]   = inv[14 ]
                inv[15  ]   = inv[15 ]   +  if tprintrubl then ub.aht-ot-line.crsa-sum-rubl else  ub.aht-ot-line.crsa-sum-base
                inv[16  ]   = inv[16 ]   +  if tprintrubl then ub.aht-ot-line.crsa-vat-rubl else  ub.aht-ot-line.crsa-vat-base
                inv[17  ]   = inv[17 ]   +  if tprintrubl then ub.aht-ot-line.sale-discnt-rubl else  ub.aht-ot-line.sale-discnt-base
                inv[18  ]   = inv[18 ]   +  if tprintrubl then ub.aht-ot-line.sale-sum-rubl else  ub.aht-ot-line.sale-sum-base
                inv[19  ]   = inv[19 ]   +  if tprintrubl then ub.aht-ot-line.sale-vat-rubl else  ub.aht-ot-line.sale-vat-base
                .
              end.
          when       'ot':U or
          when       'ap':U then
              do:
                 assign
                    overturn[1  ]   = overturn[1 ]   +  (if ub.aht-ot-line.sum-type <> "b" then round( ub.aht-ot-line.fact-qnty,3) else 0 )
                    overturn[2  ]   = overturn[2 ]   +  if tprintrubl then ub.aht-ot-line.cost-sum-rubl else  ub.aht-ot-line.cost-sum-base
                    overturn[3  ]   = overturn[3 ]   +  if tprintrubl then ub.aht-ot-line.cost-vat-rubl else  ub.aht-ot-line.cost-vat-base
                    overturn[4  ]   = overturn[4 ]
                    overturn[5  ]   = overturn[5 ]   +  if tprintrubl then ub.aht-ot-line.crsa-sum-rubl else  ub.aht-ot-line.crsa-sum-base
                    overturn[6  ]   = overturn[6 ]   +  if tprintrubl then ub.aht-ot-line.crsa-vat-rubl else  ub.aht-ot-line.crsa-vat-base
                    overturn[7  ]   = overturn[7 ]   +  if tprintrubl then ub.aht-ot-line.sale-discnt-rubl else  ub.aht-ot-line.sale-discnt-base
                    overturn[8  ]   = overturn[8 ]   +  if tprintrubl then ub.aht-ot-line.sale-sum-rubl else  ub.aht-ot-line.sale-sum-base
                    overturn[9  ]   = overturn[9 ]   +  if tprintrubl then ub.aht-ot-line.sale-vat-rubl else  ub.aht-ot-line.sale-vat-base
                    gds-zap-other   = gds-zap-other  +  if tprintrubl then ub.aht-ot-line.sale-discnt-rubl else  ub.aht-ot-line.sale-discnt-base
                    .
                 if p-ok = true then
                 assign
                    overturn[11  ]   = overturn[11 ]   +  (if ub.aht-ot-line.sum-type <> "b" then round( ub.aht-ot-line.fact-qnty,3) else 0 )
                    overturn[12  ]   = overturn[12 ]   +  if tprintrubl then ub.aht-ot-line.cost-sum-rubl else  ub.aht-ot-line.cost-sum-base
                    overturn[13  ]   = overturn[13 ]   +  if tprintrubl then ub.aht-ot-line.cost-vat-rubl else  ub.aht-ot-line.cost-vat-base
                    overturn[14  ]   = overturn[14 ]
                    overturn[15  ]   = overturn[15 ]   +  if tprintrubl then ub.aht-ot-line.crsa-sum-rubl else  ub.aht-ot-line.crsa-sum-base
                    overturn[16  ]   = overturn[16 ]   +  if tprintrubl then ub.aht-ot-line.crsa-vat-rubl else  ub.aht-ot-line.crsa-vat-base
                    overturn[17  ]   = overturn[17 ]   +  if tprintrubl then ub.aht-ot-line.sale-discnt-rubl else  ub.aht-ot-line.sale-discnt-base
                    overturn[18  ]   = overturn[18 ]   +  if tprintrubl then ub.aht-ot-line.sale-sum-rubl else  ub.aht-ot-line.sale-sum-base
                    overturn[19  ]   = overturn[19 ]   +  if tprintrubl then ub.aht-ot-line.sale-vat-rubl else  ub.aht-ot-line.sale-vat-base
                    .
              end.
      end case.
   end.
  end.
  assign
    tt# = 6
    overturn[1 + tt# ]   = (ostatok-end[1 + tt# ]  - ostatok-start[1 + tt# ] )  -  (inv[1 + tt# ] + prih[1 + tt# ] + kassa[1 + tt# ] + rash[1 + tt# ]  )
    overturn[2 + tt# ]   = (ostatok-end[2 + tt# ]  - ostatok-start[2 + tt# ] )  -  (inv[2 + tt# ] + prih[2 + tt# ] + kassa[2 + tt# ] + rash[2 + tt# ]  )
    overturn[3 + tt# ]   = (ostatok-end[3 + tt# ]  - ostatok-start[3 + tt# ] )  -  (inv[3 + tt# ] + prih[3 + tt# ] + kassa[3 + tt# ] + rash[3 + tt# ]  )
  .
  if p-ok = true then
  assign
    tt# = 6
    overturn[1 + tt# ]   = (ostatok-end[1 + tt# ]  - ostatok-start[1 + tt# ] )  -  (inv[1 + tt# ] + prih[1 + tt# ] + kassa[1 + tt# ] + rash[1 + tt# ]  )
    overturn[2 + tt# ]   = (ostatok-end[2 + tt# ]  - ostatok-start[2 + tt# ] )  -  (inv[2 + tt# ] + prih[2 + tt# ] + kassa[2 + tt# ] + rash[2 + tt# ]  )
    overturn[3 + tt# ]   = (ostatok-end[3 + tt# ]  - ostatok-start[3 + tt# ] )  -  (inv[3 + tt# ] + prih[3 + tt# ] + kassa[3 + tt# ] + rash[3 + tt# ]  )
  .
end.
end procedure.
procedure ver-owner :
  do
  on error undo, return error return-value
  :
define input  parameter p-gds-code like ub.goods.gds-code no-undo .
define input  parameter p-db-num as integer   no-undo .
define output parameter p-ok as logical   no-undo .
define variable  p-proprietor-host-code like ub.clients.host-code no-undo .
define variable  p-proprietor-obj-type  like ub.clients.obj-type no-undo .
define variable  p-proprietor-obj-code  like ub.clients.obj-code no-undo .
p-ok = false .
if  p-tpsy = false  then return.
  run tpsi-gds-proprietor (
      input  p-gds-code             ,
      input  p-db-num               ,
      output p-proprietor-host-code ,
      output p-proprietor-obj-type  ,
      output p-proprietor-obj-code )  .
 if p-proprietor-host-code = v-cntxt-host-code-obj then p-ok = true  .
end.
end procedure.
procedure ver-owner2 :
  do
  on error undo, return error return-value
  :
define input  parameter p-gds-code like ub.goods.gds-code no-undo .
define input  parameter p-obj-type  like ub.clients.obj-type no-undo .
define input  parameter p-obj-code  like ub.clients.obj-code no-undo .
define output parameter p-ok as logical   no-undo .
define variable  p-proprietor-host-code like ub.clients.host-code no-undo .
define variable  p-proprietor-obj-type  like ub.clients.obj-type no-undo .
define variable  p-proprietor-obj-code  like ub.clients.obj-code no-undo .
p-ok = false .
if  p-tpsy = false  then return.
define buffer buf_obj-list for obj-list.
find first buf_obj-list where
      buf_obj-list.obj-type = p-obj-type and
      buf_obj-list.obj-code = p-obj-code
      no-error .
if error-status :error then return .
  run tpsi-gds-proprietor (
      input  p-gds-code             ,
      input  buf_obj-list.db-num     ,
      output p-proprietor-host-code ,
      output p-proprietor-obj-type  ,
      output p-proprietor-obj-code )  .
 if p-proprietor-host-code = v-cntxt-host-code-obj then p-ok = true  .
end.
end procedure.
