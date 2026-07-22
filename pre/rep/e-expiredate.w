define variable vss-revision as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Отчёт по срокам годности маркированного товара".
define input parameter  parParentProc  as widget-handle no-undo.
define        variable temp-param-goods-choose as character no-undo .
define        variable temp-param-goods        as character no-undo init "1,2,3,4,5,6,7".
define        variable t-str                   as character no-undo .
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
define NEW shared variable gdsgrp_recids      as character no-undo.
define NEW shared variable fin-schet-recid    as character no-undo.
define NEW shared variable v-d-report-handle  as handle    no-undo .
define NEW shared temp-table g#customer no-undo
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    index pi is unique primary obj-type obj-code.
define NEW shared temp-table g#cli no-undo
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    index pi is unique primary obj-type obj-code.
define NEW shared temp-table tmp#grp no-undo
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
define NEW shared temp-table gds-list no-undo like ub.goods
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
define  NEW shared  temp-table gds-list-hist no-undo
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
NEW shared
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
define NEW shared temp-table X-init_obj-list no-undo
field obj-type like ub.clients.obj-type
field obj-code like ub.clients.obj-code
index pi is unique primary obj-type obj-code.
define variable p1 like ub.gds-obj.prod-type no-undo.
define variable p2 like ub.gds-obj.prod-code no-undo.
define variable p3 like ub.gds-obj.artic     no-undo.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable to-day       as date no-undo .
define NEW shared variable str1   as character  no-undo.
define NEW shared variable str2   as character  no-undo.
define NEW shared variable str3   as character  no-undo.
define NEW shared variable str4   as character  no-undo.
define NEW shared variable ReportNAme   as character  no-undo.
define NEW shared variable ReportProc   as character  no-undo.
define NEW shared variable ReportHeader as character  no-undo.
define NEW shared variable ReportPageWidth  as integer no-undo.
define NEW shared variable ReportPageHeight as integer no-undo.
define NEW shared variable ReportFontNum    as integer no-undo.
define NEW shared variable my-request as logical  init false no-undo.
define NEW shared variable v-delim as character no-undo .
define NEW shared variable v-sdate as character no-undo initial "/":U.
define NEW shared variable v-shortdate as character no-undo initial "dd/mm/yyyy":U .
define NEW shared variable my-handle  as handle no-undo .
define NEW shared variable parent-handle  as handle no-undo .
define NEW shared variable v-show-all-goods as logical  no-undo .
define NEW shared variable params-only      as logical   no-undo .
define NEW shared variable params-only-mode as character no-undo .
define NEW shared variable place-call       as character no-undo .
define NEW shared variable x-Goods-Editor   as character  no-undo .
define NEW shared variable x-Date-Alone     as date format "99/99/9999":u   no-undo .
define NEW shared variable x-Date-End       as date format "99/99/9999":u   no-undo .
define NEW shared variable x-Date-Start     as date format "99/99/9999":u   no-undo .
define NEW shared variable x-Shift-Alone    as integer format ">9":u         no-undo .
define NEW shared variable x-Shift-End      as integer format ">9":u         no-undo .
define NEW shared variable x-Shift-Start    as integer format ">9":u         no-undo .
define NEW shared variable x-SelectGood     as integer                      no-undo .
define NEW shared variable x-SelectObject   as character                          no-undo .
define NEW shared variable x-SET_PAY_TYPE   as integer  no-undo .
define NEW shared variable x-SET_val_TYPE   as integer  no-undo .
define NEW shared variable x-TOG-Shift      as logical  no-undo .
define NEW shared variable x-Radio-Task     as integer  no-undo .
define NEW shared variable x-TOG-Excel      as logical  no-undo .
define NEW shared variable x-TOG-list-hist  as logical  no-undo .
define NEW shared variable x-text-1 as character  no-undo .
define NEW shared variable x-text-2 as character  no-undo .
define NEW shared variable x-text-3 as character  no-undo .
define NEW shared variable x-text-4 as character  no-undo .
define NEW shared variable init-date-start  like x-date-start  no-undo .
define NEW shared variable init-date-end    like x-date-end    no-undo .
define NEW shared variable init-date-alone  like x-date-alone  no-undo .
define NEW shared variable init-shift-alone like x-shift-alone no-undo .
define NEW shared variable init-shift-start like x-shift-start no-undo .
define NEW shared variable init-shift-end   like x-shift-end   no-undo .
define NEW shared variable init-set_pay_type like x-set_pay_type   no-undo .
define NEW shared variable init-set_val_type like x-set_val_type   no-undo .
define NEW shared variable ref_date-start    as character   no-undo .
define NEW shared variable ref_date-end      as character   no-undo .
define NEW shared variable ref_date-alone    as character   no-undo .
define NEW shared work-table TDEDT  no-undo
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
define NEW shared variable str-obj-type as character  no-undo.
define NEW shared variable str-obj-code as character  no-undo.
define NEW shared variable str-obj-name as character  no-undo.
define NEW shared variable str-obj      as character  no-undo.
define NEW shared variable link#        as logical  no-undo init false.
define NEW shared variable  Verify-Arc-ot      as logical  no-undo init false.
define NEW shared variable  Verify-Arc-stk     as logical  no-undo init false.
define NEW shared variable  Verify-Arc-supp    as logical  no-undo init false.
define NEW shared variable  Verify-Arc-hold    as logical  no-undo init false.
define NEW shared variable  Verify-Arc-aht     as logical  no-undo init false.
define NEW shared variable  Verify-send-check  as logical  no-undo init false.
define NEW shared variable  Verify-Arc-fin     as logical  no-undo init false.
define NEW shared variable  Verify-Arc-strong  as logical  no-undo init false.
define NEW shared variable  Show-Crsa         as logical  no-undo init false.
define NEW shared variable  Show-Cost         as logical  no-undo init false.
define NEW shared variable  Show-Sale         as logical  no-undo init false.
define NEW shared variable  Name-Sale-price   as character no-undo .
define NEW shared variable  Format-Folder     as logical no-undo .
define NEW shared variable  Print-List-Hist   as logical no-undo init false.
define NEW shared variable Make-Excel     as logical  no-undo init false.
define NEW shared variable Make-Excel-com as logical  no-undo init false.
define NEW shared stream ForExcel.
define NEW shared variable Use-column   as logical extent 256 no-undo .
define NEW shared variable right-column as logical extent 256 no-undo .
define NEW shared temp-table Sheetf no-undo
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
  create Sheetf.
  assign
  sheetf.sheet-num = 1.
define variable l-stroka as character no-undo .
define NEW shared  variable ch#ExcelApplication as com-handle no-undo .
define NEW shared  variable ch#Workbook         as com-handle no-undo .
define NEW shared  variable ch#Worksheet        as com-handle no-undo .
define NEW shared  variable Num#Str#            as integer no-undo.
define NEW shared  variable Number-List         as integer no-undo init 1.
define NEW shared  variable v-excel-file        as character no-undo .
define variable Col-name as character  extent 256.
define variable Col-format as character  extent 256.
define variable Col-Post-format as character  extent 256.
run proc-page0-assign in this-procedure .
define variable v-del-1 as character no-undo .
if  v-delim = " " or v-delim = ? or v-delim = ""  then do:
    run gbl/getlocal.p ( output v-delim  , output v-del-1, output v-sdate, output v-shortdate ) no-error .
    if error-status :error then do:
      message error-status :error error-status :get-message(1)
              v-delim v-del-1.
        v-delim = ','  .
    end.
end.
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
my-handle = parParentProc .
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
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def new shared temp-table cli-list no-undo like ub.clients
  field to-del as logical
  index obj  is primary unique obj-type obj-code
  index cli-name      obj-name
  .
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  new shared  temp-table cli-list-hist no-undo
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
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-cntxt-host-code-obj
  ,output base-code
  )  .
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table userobjs_temp-user-obj no-undo
  field obj-type as character
  field obj-code as integer
  index xpk is primary unique obj-type obj-code
  .
procedure userobjs_clear :
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      delete buf_userobjs_temp-user-obj .
    end.
  end.
end .
procedure userobjs_object-count :
  define output parameter p-total-count as integer   no-undo .
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    assign
      p-total-count = 0
    .
    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      assign
        p-total-count = p-total-count + 1
      .
    end.
  end.
end.
procedure userobjs_append :
   define input  parameter p-obj-type as character no-undo .
   define input  parameter p-obj-code as integer   no-undo .
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    find first buf_userobjs_temp-user-obj
      where buf_userobjs_temp-user-obj.obj-type = p-obj-type
        and buf_userobjs_temp-user-obj.obj-code = p-obj-code
      no-error .
    if not available buf_userobjs_temp-user-obj
    then do:
      create buf_userobjs_temp-user-obj .
      assign
        buf_userobjs_temp-user-obj.obj-type = p-obj-type
        buf_userobjs_temp-user-obj.obj-code = p-obj-code
      .
    end.
  end.
end.
procedure userobjs_object-exist :
  define output parameter p-object-exist as logical   no-undo .
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    find first buf_userobjs_temp-user-obj
      no-error .
    if not available buf_userobjs_temp-user-obj
    then do:
      assign
        p-object-exist = false
      .
    end.
    else do:
      assign
        p-object-exist = true
      .
    end.
  end.
end.
procedure userobjs_transfer :
  define input  parameter p-callback-handle as handle no-undo .
  define variable vss-description as character no-undo init "userobjs_transfer: Передача списка объектов".
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    if valid-handle(p-callback-handle) <> true
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Неизвестный указатель на процедуру" skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-callback-handle :get-signature("userobjs_append") = ""
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        substitute("В процедуре &1 не найдена внутренняя процедура userobjs_append"
                  ,p-callback-handle :file-name
                  ) skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      run userobjs_append in p-callback-handle
        (input  buf_userobjs_temp-user-obj.obj-type
        ,input  buf_userobjs_temp-user-obj.obj-code
        ) .
    end.
  end.
end procedure.
procedure userobjs_select-one :
   define input  parameter parparentproc     as widget-handle no-undo .
   define input  parameter p-db-num          as integer   no-undo .
   define input  parameter p-user-id         as character no-undo .
   define input  parameter p-host-code-obj   as integer   no-undo .
   define input  parameter p-obj-type        as character no-undo .
   define input  parameter p-obj-code        as integer   no-undo .
   define output parameter p-user-select     as logical   no-undo .
   define output parameter p-select-obj-type as character no-undo .
   define output parameter p-select-obj-code as character no-undo .
  do
  on error undo, return error return-value
  :
    run gbl/userobjs.w
      (input  parparentproc
      ,input  this-procedure :handle
      ,input  p-db-num
      ,input  p-user-id
      ,input  p-host-code-obj
      ,input  p-obj-type
      ,input  p-obj-code
      ,INPUT  "b-sel"
      ,output p-user-select
      ,output p-select-obj-type
      ,output p-select-obj-code
      ) .
  end.
end.
procedure userobjs_select-many :
  define input  parameter parparentproc   as widget-handle no-undo .
  define input  parameter p-db-num        as integer   no-undo .
  define input  parameter p-user-id       as character no-undo .
  define input  parameter p-host-code-obj as integer   no-undo .
  define input  parameter p-obj-type      as character no-undo .
  define input  parameter p-obj-code      as integer   no-undo .
  define output parameter p-user-select   as logical   no-undo .
  define variable v-select-obj-type as character no-undo .
  define variable v-select-obj-code as integer   no-undo .
  do
  on error undo, return error return-value
  :
    run gbl/userobjs.w
      (input  parparentproc
      ,input  this-procedure :handle
      ,input  p-db-num
      ,input  p-user-id
      ,input  p-host-code-obj
      ,input  p-obj-type
      ,input  p-obj-code
      ,INPUT  "b-sel,b-mark"
      ,output p-user-select
      ,output v-select-obj-type
      ,output v-select-obj-code
      ) .
  end.
end.
procedure thobjs :
   define input        parameter parparentproc     as widget-handle no-undo .
   define input        parameter i-bttns           as character     no-undo .
   define input        parameter i-list-mode       as character     no-undo.
   define input        parameter i-obj-type        as character     no-undo.
   define input        parameter i-db-num          as integer       no-undo.
   define input        parameter i-host-code       as integer       no-undo.
   define input-output parameter p-rid-list        as character     no-undo .
run ref/thobjs.p
        ( input parparentproc
         ,input  this-procedure :handle
        , input i-bttns
        , input i-list-mode
        , input i-obj-type
        , input i-db-num
        , input i-host-code
        , input-output p-rid-list ) no-error .
end.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gen-key-rec :
  define input  parameter p-tbl-name    as character no-undo.
  define input  parameter p-bh_tbl-name as handle    no-undo.
  define output parameter p-key-rec     as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-rec). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-rec). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-rec). endkey", vss-workfile )
  :
    define variable fh               as handle    no-undo .
    define variable v-ok             as logical   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    if p-tbl-name = ?
      or p-tbl-name = "":U
    then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы.", vss-include-info18 ).
    end.
    if not p-bh_tbl-name:available then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-include-info18, p-tbl-name ).
    end.
    assign
      p-key-rec = p-tbl-name
      v-inform  = p-bh_tbl-name:index-information(1)
      v-ind     = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = p-bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info18, p-tbl-name ).
    end.
    else do:
      assign
        v-idx-field-qnty = num-entries( v-inform ) - 4
      .
      if v-idx-field-qnty < 2 then do:
        return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info18, v-inform, p-tbl-name ).
      end.
      do v-ind = 1 to v-idx-field-qnty by 2
      on error undo, return error
      :
        assign
          fh = p-bh_tbl-name:buffer-field( entry( 4 + v-ind, v-inform, ",":U ) ).
          p-key-rec = p-key-rec + chr(3) + substitute("&1", replace(fh:buffer-value(),chr(3),chr(2) + chr(9) + chr (2)))
        .
      end.
    end.
    if p-key-rec = ? then do:
      assign
        p-key-rec = "":U
      .
      return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", vss-include-info18, p-tbl-name ).
    end.
  end.
  return.
end procedure.
procedure gen-where-keyr-tab :
  define input  parameter i-tableSerach as character no-undo.
  define input  parameter i-tablekey   as character  no-undo.
  define input  parameter p-key-rec    as character  no-undo.
  define input  parameter p-key-handle as handle     no-undo .
  define input  parameter p-db-name    as character  no-undo .
  define input  parameter p-tt-handle  as handle     no-undo .
  define output parameter o-Where      as character  no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-row-keyr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-row-keyr). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable fh_key           as handle    no-undo .
    define variable fh_search        as handle    no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-field-name     as character no-undo .
    define variable v-field-val      as character no-undo .
    define variable v-word-link      as character no-undo .
    define variable vTable           as character no-undo.
    define variable bh_tbl-key       as handle    no-undo .
    assign
      p-key-rec = trim( p-key-rec )
    .
    if p-key-handle <> ? then do:
      if not valid-handle(p-key-handle)
         or p-key-handle:type <> "buffer"
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Задан невалидный буфер для поиска.", vss-include-info18 ).
      end.
      if num-entries( p-key-rec, chr(3) ) > 1
        or p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. При поиске по буферу вместо ключа (&2) должено быть 'имя таблицы'.", vss-include-info18, p-key-rec ).
      end.
    end.
    else do:
      if p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info18 ).
      end.
    end.
    assign
      vTable = entry( 1 , p-key-rec, chr(3) )
    .
    if p-tt-handle <> ?
      and ( not valid-handle(p-tt-handle)
            or p-tt-handle:type <> "buffer"
          )
    then do:
      return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. &2&3Передан невалидный handle для поиска или handle не типа BUFFER", vss-include-info18, vTable, chr(10) ).
    end.
    if p-tt-handle = ? then do:
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, vTable )
      .
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    else do:
      create buffer bh_tbl-name for table p-tt-handle:table-handle .
    end.
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Таблица &2 не имеет первичного ключа", vss-include-info18, vTable ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info18, v-inform, vTable ).
    end.
    assign
      o-where     = "where":U
      v-word-link = "":U
      v-field-num = num-entries( p-key-rec, chr(3) ) - 1
      v-count-fld = 0
    .
    if i-tablekey ne "" and i-tablekey ne ?
    then do:
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tablekey )
      .
      create buffer bh_tbl-key for table v-full-tbl-name .
    end.
    if i-tableSerach ne "" and i-tableSerach ne ?
    then do:
      delete object bh_tbl-name no-error.
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tableSerach )
      .
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if p-key-handle = ?
        and v-count-fld > v-field-num
      then do:
        leave block_where.
      end.
      define variable VfieldKeyTable as handle no-undo.
      assign
        v-field-name = entry( 4 + v-ind, v-inform, ",":U )
        fh_search    = bh_tbl-name:buffer-field( v-field-name )
      .
      if     bh_tbl-key ne ?
      then do:
         VfieldKeyTable = bh_tbl-key:buffer-field( v-field-name ) no-error.
         if VfieldKeyTable eq ?
         then next block_where.
      end.
      if v-full-tbl-name ne "" and v-full-tbl-name ne ?
      then
         o-where = substitute( "&1 &2 &3.&4 =", o-where, v-word-link,v-full-tbl-name, v-field-name ).
      else
         o-where = substitute( "&1 &2 &3 =", o-where, v-word-link, v-field-name ).
      if p-key-handle = ? then do:
        assign
          v-field-val = replace (entry( v-count-fld + 1 , p-key-rec, chr(3) ),chr(2) + chr(9) + chr (2),chr(3))
        .
      end.
      else do:
        assign
          fh_key = p-key-handle:buffer-field( v-field-name )
        .
        if fh_key = ?
          or not valid-handle( fh_key )
        then do:
          delete object bh_tbl-name.
          if     bh_tbl-key ne ?
          then
             delete object bh_tbl-key.
          return error substitute( "&1. Буфер &2 не содержит поля &3 необходимого для поиска.", vss-include-info18, p-key-handle:name, v-field-name ).
        end.
        assign
          v-field-val = fh_key:buffer-value
        .
      end.
      if fh_search:data-type ="character":U then do:
        assign
          v-field-val = replace( v-field-val, '~~':U, '~~~~':U )
          v-field-val = replace( v-field-val, '"':U, '~~"':U )
          v-field-val = replace( v-field-val, "'":U, "~~'":U )
          v-field-val = replace( v-field-val, '~{':U, '~~~{':U )
          v-field-val = replace( v-field-val, '~}':U, '~~~}':U )
          v-field-val = replace( v-field-val, '~\':U, '~~~\':U )
          v-field-val = replace( v-field-val, chr(10), '~~n':U )
          v-field-val = replace( v-field-val, chr(9), '~~t':U )
          v-field-val = replace( v-field-val, chr(13), '~~r':U )
          v-field-val = replace( v-field-val, chr(27), '~~E':U )
          v-field-val = replace( v-field-val, chr(8), '~~b':U )
          v-field-val = replace( v-field-val, chr(12), '~~f':U )
          v-field-val = substitute( '"&1"', v-field-val )
        .
      end.
      assign
        o-where = substitute( "&1 &2", o-where, v-field-val )
      .
      if v-word-link = "":U then do:
        assign
          v-word-link = "and":U
        .
      end.
    end.
    delete object bh_tbl-name.
    if     bh_tbl-key ne ?
    then
       delete object bh_tbl-key.
    if p-key-handle = ?
      and v-count-fld <> v-field-num
    then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2", vss-include-info18, vTable ).
    end.
  end.
end procedure.
procedure gen-hn-keyr-tab :
  define input  parameter i-tableSerach as character no-undo.
  define input  parameter i-tablekey   as character no-undo.
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter o-hn         as handle    no-undo.
  define variable v-full-tbl-name as character no-undo.
  define variable v-where         as character no-undo.
  define variable bh_tbl-name     as handle    no-undo.
  define variable vTable          as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-row-keyr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-row-keyr). endkey", vss-workfile ):
      run gen-where-keyr-tab(i-tableSerach,
                             i-tablekey,
                             p-key-rec,
                             p-key-handle,
                             p-db-name,
                             p-tt-handle,
                             output v-where).
      if i-tableSerach ne "" and i-tableSerach ne ?
      then do:
         v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tableSerach ).
         create buffer bh_tbl-name for table v-full-tbl-name .
      end.
      else do:
         if p-tt-handle = ? then do:
            assign
               vTable = entry( 1 , p-key-rec, chr(3) )
            .
            v-full-tbl-name = substitute( "&1.&2":U, p-db-name, vTable ).
            create buffer bh_tbl-name for table v-full-tbl-name .
         end.
         else do:
            create buffer bh_tbl-name for table p-tt-handle:table-handle .
         end.
      end.
      if p-tt-handle = ? then do:
         bh_tbl-name:find-first( v-where, p-stts-lock ) no-error .
      end.
      else do:
         bh_tbl-name:find-first( v-where ) no-error .
      end.
      o-hn = bh_tbl-name.
   end.
end procedure.
procedure gen-hn-keyr :
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter o-hn         as handle    no-undo.
  run gen-hn-keyr-tab(?,?,p-key-rec,p-key-handle,p-db-name,p-tt-handle,p-stts-lock,output o-hn).
end.
procedure gen-row-keyr :
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter p-tbl-row    as rowid     no-undo.
  define output parameter p-tbl-name   as character no-undo.
  define variable vHn as handle no-undo.
    run gen-hn-keyr-tab(?,?,p-key-rec,p-key-handle,p-db-name,p-tt-handle,p-stts-lock,output vHn).
    p-tbl-row = if vHn:available then vHn:rowid else ?.
    p-tbl-name =  vHn:table.
    delete object vHn no-error.
  if p-tbl-row = ? then do:
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info18, p-tbl-name, p-key-rec ).
  end.
  else do:
    return.
  end.
end procedure.
procedure gen-key-fv :
  define input  parameter p-key-rec    as character no-undo .
  define output parameter p-field-list as character no-undo .
  define output parameter p-value-list as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-fv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-fv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-fv). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable v-tbl-name       as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-delim-key      as character no-undo .
    if p-key-rec = ?
      or p-key-rec = "":U
    then do:
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info18 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверный уникальный ключ.", vss-include-info18 ).
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info18, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info18, v-inform, v-tbl-name ).
    end.
    assign
      p-field-list = "":U
      p-value-list = "":U
      v-delim-key  = "":U
      v-field-num  = num-entries( p-key-rec, chr(3) ) - 1
      v-count-fld  = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if v-count-fld > v-field-num then do:
        leave block_where.
      end.
      assign
        p-field-list = p-field-list + v-delim-key + entry( 4 + v-ind, v-inform, ",":U )
        p-value-list = p-value-list + v-delim-key + entry( v-count-fld + 1 , p-key-rec, chr(3) )
      .
      if v-ind = 1 then do:
        assign
          v-delim-key = chr(3)
        .
      end.
    end.
    delete object bh_tbl-name.
    if v-count-fld <> v-field-num then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info18, v-tbl-name ).
    end.
  end.
end procedure.
procedure gen-key-field :
  define input  parameter p-table      as character no-undo .
  define output parameter p-field-list as character no-undo .
  do
  on error  undo, return error substitute( "&1 (gen-key-fv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-fv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-fv). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable v-tbl-name       as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-delim-key      as character no-undo .
    if p-table = ?
      or p-table = "":U
    then do:
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан таблица.", vss-include-info18 ).
    end.
    assign
      v-tbl-name      = p-table
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверная таблица.", vss-include-info18 ).
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info18, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info18, v-inform, v-tbl-name ).
    end.
    assign
      p-field-list = "":U
      v-delim-key  = "":U
      v-count-fld  = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      p-field-list = p-field-list + v-delim-key + entry( 4 + v-ind, v-inform, ",":U ).
      if v-ind = 1 then do:
        assign
          v-delim-key = chr(3)
        .
      end.
    end.
    delete object bh_tbl-name.
  end.
end procedure.
procedure create-gds-list-hist :
define input parameter p-mode as character no-undo .
define input-output parameter p-seq as integer no-undo .
define input parameter p-line as integer no-undo .
define variable p-list-table as character no-undo .
define input parameter p-hist-mode as character no-undo .
define input parameter p-des as character no-undo .
define input parameter p-num-recs as integer no-undo .
define input parameter p-option as character no-undo .
define input parameter p-status_ as character no-undo .
define input parameter p-item as character no-undo .
define input parameter p-tbl-name as character no-undo .
define input parameter p-bh_tbl-name as handle no-undo .
define variable v-num-add as integer no-undo .
define variable v-num-ignored as integer no-undo .
define buffer buf_gds-list-hist for gds-list-hist.
  do
  on error undo, return error
  :
    CASE p-mode:
      when 'title' then do:
        find first buf_gds-list-hist where
                   buf_gds-list-hist.id = 0   no-error.
        if not available buf_gds-list-hist then do:
          create buf_gds-list-hist.
          assign
          buf_gds-list-hist.id = 0
          buf_gds-list-hist.line = 0
          buf_gds-list-hist.list-table = '':U
          .
        end.
        assign
        buf_gds-list-hist.des =  p-des
        buf_gds-list-hist.num-recs = p-num-recs
        buf_gds-list-hist.option_  = p-option
        buf_gds-list-hist.item_ = p-item
        .
      end.
      when 'ДОБАВЛЕНИЕ':U then do:
        if p-option begins 'single' then do:
          CASE p-hist-mode:
            when '+':U then do:
              assign
              v-num-add = 1
              v-num-ignored  = 0
              .
            end.
            when '-':U then do:
              assign
              v-num-add = 1
              v-num-ignored  = 0
              .
            end.
            when '*':U then do:
              assign
              v-num-add = p-num-recs - 1
              p-num-recs = 1
              v-num-ignored  = 0
              .
            end.
          END CASE.
        end.
        create buf_gds-list-hist.
        assign
        buf_gds-list-hist.id = p-seq
        buf_gds-list-hist.list-table = p-list-table
         p-seq = (if p-line = 0 then (p-seq + 1) else p-seq)
        buf_gds-list-hist.des =  p-des
        buf_gds-list-hist.line = p-line
        buf_gds-list-hist.num-recs = p-num-recs
        buf_gds-list-hist.option_  = p-option
        buf_gds-list-hist.item_ = p-item
        buf_gds-list-hist.hist-mode =  p-hist-mode
        buf_gds-list-hist.status_ =  p-status_
        buf_gds-list-hist.num-add = v-num-add
        buf_gds-list-hist.num-ignored = v-num-ignored
        .
      end.
      when 'ИЗМЕНЕНИЕ':U + chr(4) + 'des' then do:
        find first buf_gds-list-hist where
                  buf_gds-list-hist.id = p-seq
              and buf_gds-list-hist.line = p-line no-error .
        if  available buf_gds-list-hist then do:
          assign
          buf_gds-list-hist.des =  p-des
          buf_gds-list-hist.num-recs = p-num-recs
          buf_gds-list-hist.option_  = p-option
          buf_gds-list-hist.item_ = p-item
          buf_gds-list-hist.list-table = (if p-list-table <> '':U and p-list-table <> ?
                                     then p-list-table
                                     else buf_gds-list-hist.list-table)
          .
        end.
      end.
      when 'ИЗМЕНЕНИЕ':U + chr(4) + 'mode' then do:
        find first buf_gds-list-hist where
                  buf_gds-list-hist.id = p-seq
              and buf_gds-list-hist.line = p-line  no-error .
        if available buf_gds-list-hist then do:
          assign
          buf_gds-list-hist.hist-mode =  p-hist-mode
          buf_gds-list-hist.num-recs  = (if buf_gds-list-hist.line = 0 then p-num-recs else buf_gds-list-hist.num-recs)
          buf_gds-list-hist.list-table = (if p-list-table <> '':U and p-list-table <> ?
                                     then p-list-table
                                     else buf_gds-list-hist.list-table)
          .
        end.
      end.
    END CASE.
    if p-tbl-name <> "":U
    and valid-handle(p-bh_tbl-name)
    then do:
      run gen-key-rec  in this-procedure (
                                            input  p-tbl-name
                                           ,input  p-bh_tbl-name
                                           ,output p-item) no-error .
      if not error-status:error then do:
        assign
        buf_gds-list-hist.item_ = p-item
        .
      end.
      else do:
        assign
        buf_gds-list-hist.item_ = "!ERROR"
        .
      end.
    end.
  end.
end procedure.
FUNCTION get-line-mode returns character(input p-hist-mode as character):
case p-hist-mode:
  when '+':U then
    return  'ДОБАВЛЕНИЕ':U.
  when '-':U then
    return  'удаление':U.
  when '*':U then
    return  'ОСТАВИТЬ':U.
end CASE.
END FUNCTION.
FUNCTION get-hist-mode returns character(input p-line-mode as character):
case p-line-mode:
  when 'ДОБАВЛЕНИЕ':U then
    return  "+".
  when 'удаление':U then
    return  "-".
  when 'ОСТАВИТЬ':U then
    return  "*".
end CASE.
END FUNCTION.
procedure proc-write-filter-expression :
define input parameter p-filter-expression as character no-undo .
define variable v-ii as integer no-undo .
output to value(string(g#report-num) + ".whr").
put .
if num-entries(p-filter-expression) > 0 then do:
   put unformatted 'and ('.
   do v-ii = 1 to num-entries(p-filter-expression):
     put unformatted entry(v-ii, p-filter-expression) skip.
   end.
   put unformatted ')'.
end.
output close.
end procedure.
procedure proc-write-filter-expression-var :
define input parameter p-filter-expression as character no-undo .
define output parameter p-string as character no-undo .
define variable v-ii as integer no-undo .
if num-entries(p-filter-expression) > 0 then do:
   p-string = 'and ('.
   do v-ii = 1 to num-entries(p-filter-expression):
     p-string = p-string + entry(v-ii, p-filter-expression) + chr(10).
   end.
   p-string = p-string + ')'.
end.
end procedure.
define shared variable lns-cnt                 as integer   no-undo .
define shared variable s-notes                 as character no-undo .
define        variable keep-spis               as character no-undo .
FUNCTION customerName RETURNS CHARACTER
    ( p-dogovor as character)  FORWARD.
DEFINE BUTTON b-exit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON Btn_OK AUTO-GO
     LABEL "_ В&ыполнить"
     SIZE 12 BY 1
     BGCOLOR 8 .
DEFINE BUTTON BUTTON-1
     IMAGE-UP FILE "adeicon\ts-up":U
     IMAGE-DOWN FILE "adeicon\ts-down":U
     IMAGE-INSENSITIVE FILE "adeicon\ts-up":U NO-FOCUS
     LABEL "&1.Параметры"
     SIZE 15 BY 1.17 TOOLTIP "Параметры".
DEFINE BUTTON BUTTON-gds
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "BUTTON-gds"
     SIZE 3 BY .88.
DEFINE BUTTON BUTTON-node
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "BUTTON-node"
     SIZE 3 BY .88.
DEFINE BUTTON BUTTON-prod
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "BUTTON-prod"
     SIZE 3 BY .88.
DEFINE BUTTON i-exit
     IMAGE-UP FILE "cmp/i-run.bmp":U
     IMAGE-DOWN FILE "cmp/i-run.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/i-rund.bmp":U
     LABEL ""
     SIZE 2.5 BY .75.
DEFINE VARIABLE Goods-Editor AS CHARACTER
     VIEW-AS EDITOR MAX-CHARS 32000 SCROLLBAR-VERTICAL
     SIZE 42.75 BY 1.96
     FONT 4 NO-UNDO.
DEFINE VARIABLE F-button-1 AS CHARACTER FORMAT "X(256)":U INITIAL "Параметры"
      VIEW-AS TEXT
     SIZE 13 BY .67 TOOLTIP "Параметры" NO-UNDO.
DEFINE VARIABLE f-period AS CHARACTER FORMAT "X(256)":U initial "7"
     VIEW-AS FILL-IN
     SIZE 5 BY 1 NO-UNDO.
DEFINE VARIABLE Goods-count AS CHARACTER FORMAT "X(30)":U
      VIEW-AS TEXT
     SIZE 42.75 BY .67
     FGCOLOR 1 FONT 4 NO-UNDO.
DEFINE VARIABLE TEXT-1 AS CHARACTER FORMAT "X(256)":U INITIAL "Выбор товара"
      VIEW-AS TEXT
     SIZE 14 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE TEXT-2 AS CHARACTER FORMAT "X(256)":U INITIAL "Период контроля"
      VIEW-AS TEXT
     SIZE 16.5 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE period-control AS INTEGER INITIAL 1
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "3 дня", 0,
"7 дней", 1,
"14 дней", 2,
"Свой вариант", 3
     SIZE 20 BY 4.13 NO-UNDO.
DEFINE VARIABLE SelectGood AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Все", 1,
"Группы товаров", 2,
"Производители", 3,
"Выборочно", 4
     SIZE 39.25 BY 4.13
     FGCOLOR 0  NO-UNDO.
DEFINE RECTANGLE RECT-8
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 45.5 BY 8.5.
DEFINE RECTANGLE RECT-9
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 31.5 BY 6.75.
DEFINE VARIABLE expired-goods AS LOGICAL INITIAL no
     LABEL "Показать просроченные товары"
     VIEW-AS TOGGLE-BOX
     SIZE 31 BY .83
     FONT 1 NO-UNDO.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1 WIDGET-ID 4
     BUTTON-1 AT ROW 2.5 COL 2 WIDGET-ID 14
     Btn_OK AT ROW 1 COL 11 WIDGET-ID 10
     i-exit AT ROW 1.08 COL 11.13 WIDGET-ID 12 NO-TAB-STOP
     SelectGood AT ROW 5.5 COL 3.25 NO-LABEL WIDGET-ID 390
     period-control AT ROW 5.5 COL 50 NO-LABEL WIDGET-ID 418
     BUTTON-node AT ROW 6.58 COL 43 WIDGET-ID 402
     BUTTON-prod AT ROW 7.63 COL 43 WIDGET-ID 406
     f-period AT ROW 8.5 COL 69 COLON-ALIGNED NO-LABEL WIDGET-ID 428
     BUTTON-gds AT ROW 8.67 COL 43 WIDGET-ID 398
     Goods-Editor AT ROW 10.67 COL 3.25 NO-LABEL WIDGET-ID 412
     expired-goods AT ROW 11.79 COL 49 WIDGET-ID 92
     F-button-1 AT ROW 2.75 COL 1 COLON-ALIGNED NO-LABEL WIDGET-ID 372
     TEXT-1 AT ROW 4.25 COL 11 COLON-ALIGNED NO-LABEL WIDGET-ID 414
     TEXT-2 AT ROW 4.25 COL 49.75 COLON-ALIGNED NO-LABEL WIDGET-ID 426
     Goods-count AT ROW 9.92 COL 3.25 NO-LABEL WIDGET-ID 432
     RECT-8 AT ROW 4.5 COL 2 WIDGET-ID 416
     RECT-9 AT ROW 4.5 COL 48.5 WIDGET-ID 430
     SPACE(2.99) SKIP(2.07)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Отчёт по срокам годности маркированного товара" WIDGET-ID 100.
FUNCTION stat-line RETURNS CHARACTER
    (input p-status-chr as character )  FORWARD.
DEFINE VAR adm-object-hdl       AS HANDLE NO-UNDO.
DEFINE VAR adm-query-opened        AS LOGICAL NO-UNDO INIT NO.
DEFINE VAR adm-row-avail-state     AS LOGICAL NO-UNDO INIT ?.
DEFINE VAR adm-initial-lock        AS CHARACTER NO-UNDO INIT "NO-LOCK":U.
DEFINE VAR adm-new-record          AS LOGICAL NO-UNDO INIT no.
DEFINE VAR adm-updating-record     AS LOGICAL NO-UNDO INIT no.
DEFINE VAR adm-check-modified-all  AS LOGICAL NO-UNDO INIT no.
DEFINE NEW GLOBAL SHARED VAR adm-broker-hdl    AS HANDLE  NO-UNDO.
      adm-object-hdl = FRAME Dialog-Frame:HANDLE.
RUN ensure-broker.
THIS-PROCEDURE:ADM-DATA =
     'ADM1.1~`':U +
     'Dialog-Box~`':U +
     '~`':U +
     'NO ~`':U +
     '~`':U +
     '~`':U +
     '~`':U +
     (IF adm-object-hdl = ? THEN "":U ELSE STRING(adm-object-hdl))
        + "~`":U +
     '?~`':U +
     '~`':U +
     '~`':U +
     '~`~`~`~`~`~`~`~`~`~`~`':U +
     IF THIS-PROCEDURE:ADM-DATA = "":U OR THIS-PROCEDURE:ADM-DATA = ?
         THEN "^^":U
     ELSE "^":U + ENTRY(2, THIS-PROCEDURE:ADM-DATA, "^":U) +
          "^":U + ENTRY(3, THIS-PROCEDURE:ADM-DATA, "^":U).
PROCEDURE adm-apply-entry :
  RUN broker-apply-entry IN adm-broker-hdl (THIS-PROCEDURE) NO-ERROR.
END PROCEDURE.
PROCEDURE adm-destroy :
 RUN broker-destroy IN adm-broker-hdl (THIS-PROCEDURE) NO-ERROR.
END PROCEDURE.
PROCEDURE adm-disable :
    DISABLE b-exit RECT-8 RECT-9 BUTTON-1 Btn_OK i-exit SelectGood period-control BUTTON-node BUTTON-prod BUTTON-gds Goods-Editor expired-goods F-button-1 TEXT-1 TEXT-2 Goods-count WITH FRAME Dialog-Frame.
    RUN dispatch ('disable-fields':U).
    RUN set-attribute-list ('ENABLED=no':U).
    RETURN.
END PROCEDURE.
PROCEDURE adm-edit-attribute-list :
   MESSAGE "There is no attribute list dialog for this object.":U
          VIEW-AS ALERT-BOX WARNING.
      RETURN.
END PROCEDURE.
PROCEDURE adm-enable :
    ENABLE UNLESS-HIDDEN b-exit RECT-8 RECT-9 BUTTON-1 Btn_OK i-exit SelectGood period-control BUTTON-node BUTTON-prod BUTTON-gds Goods-Editor expired-goods F-button-1 TEXT-1 TEXT-2 Goods-count WITH FRAME Dialog-Frame.
    RUN enable_UI IN THIS-PROCEDURE NO-ERROR.
    RUN set-attribute-list ('ENABLED=yes':U).
    RETURN.
END PROCEDURE.
PROCEDURE adm-exit :
     RUN notify ('exit':U).
  RETURN.
END PROCEDURE.
PROCEDURE adm-hide :
  RUN broker-hide IN adm-broker-hdl (THIS-PROCEDURE) NO-ERROR.
END PROCEDURE.
PROCEDURE adm-initialize :
  RUN broker-initialize IN adm-broker-hdl (THIS-PROCEDURE) NO-ERROR.
END PROCEDURE.
PROCEDURE adm-show-errors :
    DEFINE VARIABLE        cntr                  AS INTEGER   NO-UNDO.
    DO cntr = 1 TO ERROR-STATUS:NUM-MESSAGES:
        MESSAGE ERROR-STATUS:GET-MESSAGE(cntr).
    END.
    RETURN.
END PROCEDURE.
PROCEDURE adm-UIB-mode :
  RUN broker-UIB-mode IN adm-broker-hdl (THIS-PROCEDURE) NO-ERROR.
END PROCEDURE.
PROCEDURE adm-view :
  RUN broker-view IN adm-broker-hdl (THIS-PROCEDURE) NO-ERROR.
END PROCEDURE.
PROCEDURE dispatch :
    DEFINE INPUT PARAMETER p-method-name    AS CHARACTER NO-UNDO.
    RUN broker-dispatch IN adm-broker-hdl
        (THIS-PROCEDURE, p-method-name) NO-ERROR.
    IF RETURN-VALUE = "ADM-ERROR":U THEN RETURN "ADM-ERROR":U.
END PROCEDURE.
PROCEDURE ensure-broker :
RUN get-attribute IN adm-broker-hdl ('TYPE':U) NO-ERROR.
IF RETURN-VALUE NE "ADM-Broker":U THEN
DO:
    RUN adm/objects/broker.p PERSISTENT set adm-broker-hdl.
    RUN set-broker-owner IN adm-broker-hdl (THIS-PROCEDURE).
END.
END PROCEDURE.
PROCEDURE get-attribute :
  DEFINE INPUT PARAMETER p-attr-name    AS CHARACTER NO-UNDO.
  RUN broker-get-attribute IN adm-broker-hdl
      (INPUT THIS-PROCEDURE, INPUT p-attr-name) NO-ERROR.
  RETURN RETURN-VALUE.
END PROCEDURE.
PROCEDURE get-attribute-list :
  DEFINE OUTPUT PARAMETER p-attr-list AS CHARACTER NO-UNDO.
  RUN broker-get-attribute-list IN adm-broker-hdl
      (INPUT THIS-PROCEDURE,
       INPUT ?,
       OUTPUT p-attr-list) NO-ERROR.
  RETURN.
END PROCEDURE.
PROCEDURE new-state :
  DEFINE INPUT PARAMETER p-state AS CHARACTER NO-UNDO.
  RUN broker-new-state IN adm-broker-hdl (THIS-PROCEDURE, p-state) NO-ERROR.
  RETURN.
END PROCEDURE.
PROCEDURE notify :
  DEFINE INPUT PARAMETER p-method AS CHARACTER NO-UNDO.
  RUN broker-notify IN adm-broker-hdl (THIS-PROCEDURE, p-method) NO-ERROR.
  IF RETURN-VALUE = "ADM-ERROR":U THEN
      RETURN "ADM-ERROR":U.
  RETURN.
END PROCEDURE.
PROCEDURE set-attribute-list :
  DEFINE INPUT PARAMETER p-attr-list    AS CHARACTER NO-UNDO.
  RUN ensure-broker.
  RUN broker-set-attribute-list IN adm-broker-hdl
      (INPUT THIS-PROCEDURE, INPUT p-attr-list) NO-ERROR.
  RETURN.
END PROCEDURE.
PROCEDURE set-position :
    DEFINE INPUT PARAMETER p-row    AS DECIMAL NO-UNDO.
    DEFINE INPUT PARAMETER p-col    AS DECIMAL NO-UNDO.
    IF VALID-HANDLE(adm-object-hdl) THEN
    DO:
      ASSIGN adm-object-hdl:ROW    =   p-row
             adm-object-hdl:COLUMN =   p-col.
    END.
    RETURN.
END PROCEDURE.
PROCEDURE adm-display-fields :
    RUN check-modified IN THIS-PROCEDURE ('clear':U) NO-ERROR.
    RETURN.
END PROCEDURE.
PROCEDURE adm-open-query :
  RETURN.
END PROCEDURE.
PROCEDURE adm-row-changed :
      IF VALID-HANDLE(adm-object-hdl) THEN
        RUN dispatch IN THIS-PROCEDURE ('display-fields':U).
      RUN notify ('row-available':U).
      RETURN.
END PROCEDURE.
PROCEDURE reposition-query :
    DEFINE INPUT PARAMETER p-requestor-hdl     AS HANDLE NO-UNDO.
    RUN set-attribute-list ('REPOSITION-PENDING = NO':U).
    RETURN.
END PROCEDURE.
  DEFINE VARIABLE adm-first-table         AS ROWID NO-UNDO.
  DEFINE VARIABLE adm-second-table        AS ROWID NO-UNDO.
  DEFINE VARIABLE adm-third-table         AS ROWID NO-UNDO.
  DEFINE VARIABLE adm-adding-record       AS LOGICAL NO-UNDO INIT no.
  DEFINE VARIABLE adm-return-status       AS LOGICAL   NO-UNDO.
  DEFINE VARIABLE adm-first-prev-rowid    AS ROWID     NO-UNDO.
  DEFINE VARIABLE adm-second-prev-rowid   AS ROWID     NO-UNDO.
  DEFINE VARIABLE adm-third-prev-rowid    AS ROWID     NO-UNDO.
  DEFINE VARIABLE adm-first-tmpl-recid    AS RECID     NO-UNDO INIT ?.
  DEFINE VARIABLE adm-second-tmpl-recid   AS RECID     NO-UNDO INIT ?.
  DEFINE VARIABLE adm-third-tmpl-recid    AS RECID     NO-UNDO INIT ?.
  DEFINE VARIABLE adm-index-pos           AS INTEGER   NO-UNDO.
  DEFINE VARIABLE adm-query-empty         AS LOGICAL   NO-UNDO.
  DEFINE VARIABLE adm-create-complete     AS LOGICAL   NO-UNDO.
  DEFINE VARIABLE adm-create-on-add       AS LOGICAL   NO-UNDO INIT ?.
  DEFINE VARIABLE group-assign-target     AS LOGICAL   NO-UNDO INIT ?.
  DEFINE VARIABLE group-target-list       AS CHARACTER NO-UNDO INIT ?.
  IF "":U = "":U THEN
    RUN modify-list-attribute IN adm-broker-hdl
      (THIS-PROCEDURE, "REMOVE":U, "SUPPORTED-LINKS":U, "TABLEIO-TARGET":U).
  RUN use-create-on-add(?).
PROCEDURE adm-add-record :
    MESSAGE "Object ":U THIS-PROCEDURE:FILE-NAME
       "must have at least one Enabled Table to perform Add.":U
       VIEW-AS ALERT-BOX ERROR.
    RETURN.
END PROCEDURE.
PROCEDURE adm-assign-record :
 MESSAGE
       "Object ":U THIS-PROCEDURE:FILE-NAME
         "must have at least one Enabled Table to perform Assign.":U
           VIEW-AS ALERT-BOX ERROR.
   RETURN.
  END PROCEDURE.
PROCEDURE adm-assign-statement :
  RETURN.
END PROCEDURE.
PROCEDURE adm-cancel-record :
   RETURN.
  END PROCEDURE.
PROCEDURE adm-copy-record :
    MESSAGE "Object ":U THIS-PROCEDURE:FILE-NAME
     "must have at least one Enabled Table to perform Copy.":U
       VIEW-AS ALERT-BOX ERROR.
    RETURN.
END PROCEDURE.
PROCEDURE adm-create-record :
   RETURN.
END PROCEDURE.
PROCEDURE adm-current-changed :
  RETURN.
END PROCEDURE.
PROCEDURE adm-delete-record :
 MESSAGE
       "Object ":U THIS-PROCEDURE:FILE-NAME
         "must have at least one Enabled Table to perform Delete.":U
           VIEW-AS ALERT-BOX ERROR.
    RUN dispatch IN THIS-PROCEDURE ('apply-entry':U).
    RETURN.
END PROCEDURE.
PROCEDURE adm-disable-fields :
      RUN notify ('disable-fields, GROUP-ASSIGN-TARGET':U).
    RETURN.
END PROCEDURE.
PROCEDURE adm-enable-fields :
    RETURN.
END PROCEDURE.
PROCEDURE adm-end-update :
  RETURN.
END PROCEDURE.
PROCEDURE adm-reset-record :
    RETURN.
END PROCEDURE.
PROCEDURE adm-update-record :
    MESSAGE
      "Object ":U THIS-PROCEDURE:FILE-NAME
        "must have at least one Enabled Table to perform Update.":U
          VIEW-AS ALERT-BOX ERROR.
   RETURN.
END PROCEDURE.
PROCEDURE check-modified :
DEFINE INPUT PARAMETER check-state AS CHARACTER NO-UNDO.
DEFINE VARIABLE curr-widget       AS HANDLE      NO-UNDO.
DEFINE VARIABLE container-hdl-str AS CHARACTER   NO-UNDO.
DEFINE VARIABLE i                 AS INTEGER     NO-UNDO.
  IF check-state = "check":U THEN
  DO:
    RUN get-link-handle IN adm-broker-hdl
      (INPUT THIS-PROCEDURE, INPUT 'GROUP-ASSIGN-TARGET':U,
         OUTPUT group-target-list).
    IF group-target-list NE "":U THEN
    DO i = 1 TO NUM-ENTRIES(group-target-list):
      curr-widget = WIDGET-HANDLE(ENTRY(i, group-target-list)).
      RUN check-modified IN curr-widget ('group-check':U).
      IF RETURN-VALUE NE "":U THEN
      DO:
        RUN check-modified-message(RETURN-VALUE).
        RETURN "":U.
      END.
    END.
  END.
  RETURN "":U.
END PROCEDURE.
PROCEDURE check-modified-message :
  DEFINE INPUT PARAMETER p-changed-table AS CHARACTER NO-UNDO.
     RUN request-attribute IN adm-broker-hdl (THIS-PROCEDURE,
        'CONTAINER-SOURCE':U, 'HIDDEN':U).
     IF RETURN-VALUE = "YES":U THEN
        RUN notify ('view,CONTAINER-SOURCE':U).
     MESSAGE IF p-changed-table NE ? THEN
        SUBSTITUTE ("Current &1 record has been changed.", p-changed-table)
        ELSE "Current values have been changed."
        SKIP "  Do you wish to save those changes?"
        VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE ANS AS LOGICAL.
     IF ANS THEN
     DO:
        IF group-assign-target THEN
          RUN notify('update-record,GROUP-ASSIGN-SOURCE':U).
        ELSE RUN dispatch('update-record':U).
        IF RETURN-VALUE = "ADM-ERROR":U THEN
        DO:
            MESSAGE "Changes to the previous record were not saved."
              VIEW-AS ALERT-BOX ERROR.
            IF group-assign-target THEN
              RUN notify('cancel-record,GROUP-ASSIGN-SOURCE':U).
            ELSE RUN dispatch ('cancel-record':U).
        END.
     END.
     ELSE DO:
       IF group-assign-target THEN
          RUN notify('cancel-record,GROUP-ASSIGN-SOURCE':U).
       ELSE RUN dispatch('cancel-record':U).
     END.
     RETURN.
END PROCEDURE.
PROCEDURE get-rowid :
    DEFINE OUTPUT PARAMETER p-table           AS ROWID NO-UNDO.
    ASSIGN
    p-table   =   adm-first-table.
    RETURN.
END PROCEDURE.
PROCEDURE init-group-assign :
    RUN request-attribute IN adm-broker-hdl
      (THIS-PROCEDURE, 'GROUP-ASSIGN-SOURCE':U, 'ENABLED-TABLES':U).
    IF LOOKUP("":U, RETURN-VALUE, " ":U) NE 0 THEN
      group-assign-target = yes.
    ELSE group-assign-target = no.
    RETURN.
END PROCEDURE.
PROCEDURE set-editors :
    DEFINE INPUT PARAMETER p-field-setting  AS CHARACTER NO-UNDO.
    DEFINE VARIABLE curr-widget             AS HANDLE    NO-UNDO.
    DEFINE VARIABLE read-only-list          AS CHARACTER NO-UNDO INIT "":U.
    ASSIGN curr-widget = FRAME Dialog-Frame:CURRENT-ITERATION.
    ASSIGN curr-widget = curr-widget:FIRST-CHILD.
    DO WHILE VALID-HANDLE (curr-widget):
        IF curr-widget:TYPE = "EDITOR":U AND curr-widget:TABLE NE ? AND
           curr-widget:HIDDEN = no THEN DO:
          CASE p-field-setting:
            WHEN "INITIALIZE":U THEN
            DO:
              IF curr-widget:READ-ONLY = yes THEN read-only-list =
                  read-only-list +
                    (IF read-only-list NE "":U THEN ",":U ELSE "":U) +
                     STRING(curr-widget).
            END.
            WHEN "DISABLE":U OR
            WHEN "ENABLE":U THEN
            DO:
                curr-widget:SENSITIVE = yes.
                RUN get-attribute ('Read-Only-Editors':U).
                IF RETURN-VALUE = ? OR
                  LOOKUP (STRING(curr-widget), RETURN-VALUE) EQ 0 THEN
                    curr-widget:READ-ONLY =
                      IF p-field-setting = "ENABLE":U THEN no ELSE yes.
            END.
            WHEN "CLEAR":U THEN
                curr-widget:SCREEN-VALUE = "":U.
          END CASE.
        END.
        ASSIGN curr-widget = curr-widget:NEXT-SIBLING.
    END.
    IF p-field-setting = "INITIALIZE":U AND read-only-list NE "":U THEN
      RUN set-attribute-list ('Read-Only-Editors = "':U + read-only-list
        + '"':U).
    RETURN.
END PROCEDURE.
PROCEDURE use-check-modified-all :
 DEFINE INPUT PARAMETER p-attr-value AS CHARACTER NO-UNDO.
  ASSIGN adm-check-modified-all = IF p-attr-value = "YES":U THEN yes ELSE no.
  RETURN.
END PROCEDURE.
PROCEDURE use-create-on-add :
DEFINE INPUT PARAMETER p-attr-value AS CHARACTER NO-UNDO.
   RETURN.
END PROCEDURE.
PROCEDURE use-initial-lock :
  DEFINE INPUT PARAMETER p-attr-value AS CHARACTER NO-UNDO.
  ASSIGN adm-initial-lock = p-attr-value.
  RETURN.
END PROCEDURE.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       BUTTON-gds:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       BUTTON-node:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       Goods-Editor:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
        APPLY "END-ERROR":U TO SELF.
    END.
ON CHOOSE OF Btn_OK IN FRAME Dialog-Frame
DO:
            assign
                SelectGood
                expired-goods
                .
             run rep/r-expireDate.p(input parParentProc,
                input SelectGood,
                input integer(f-period),
                input expired-goods
                ) .
    END.
ON CHOOSE OF BUTTON-gds IN FRAME Dialog-Frame
DO:
        define variable ref-list       as character no-undo.
        define variable vRecId         as recid     no-undo.
        define variable vAnswer        as logical   no-undo.
        define variable vI             as integer   no-undo.
        define variable v-seq          as integer   no-undo .
        define variable num-rec        as integer   init 0 no-undo.
        define variable v-bh           as handle    no-undo .
        define variable v-recs         as integer   no-undo .
        define variable v-temp-seq     as integer   no-undo .
        define variable v-line         as integer   no-undo .
        define variable v-item         as character no-undo .
        define variable v-tot-lns      as integer   no-undo .
        define variable v-ref-rec      as recid     no-undo .
        define variable dsp-rs         as character no-undo .
        define variable rs-status      as character no-undo init 'текущие':U.
        define variable v-tbl-name     as character no-undo .
        define variable rs-list-method as character no-undo init "goods".
        define variable tot-lns        as integer   init ? no-undo.
        define variable v-no-hist      as integer   no-undo init -1.
        define variable v-first        as logical   no-undo .
            run ref/gds-ref.p (
                input parParentProc
                ,input "b-mark,b-sel"
                ,input 'все':U
                ,input 'все':U
                ,input ?
                ,input ?
                ,input ?
                ,input ?
                ,input ?
                ,input v-cntxt-obj-type
                ,input v-cntxt-obj-code
                ,input ?
                ,output ref-list).
            if ref-list = "" and can-find(first gds-list) then
            do:
                message
                    "Не было выбрано ни одного товара. Очистить список ранее выбранных товаров?"
                    view-as alert-box QUESTION buttons YES-NO update vAnswer.
                if not vAnswer then return.
                else do:
                    empty temp-table gds-list .
                    empty temp-table gds-list-hist .
                end.
            end.
            find first gds-list no-error .
            if available (gds-list) then v-first = true .
            if ref-list <> "" then
            do:
                empty temp-table gds-list .
                empty temp-table gds-list-hist .
                v-recs = num-entries (ref-list).
                _next:
                do num-rec = 0 to v-recs:
                    if v-recs = 1 then
                    do:
                        num-rec = 1 .
                    end.
                    if num-rec > 0 then
                    do:
                        v-ref-rec = integer (entry (num-rec, ref-list)).
                        find goods where recid (goods) = v-ref-rec no-lock.
                        find first gds-list where gds-list.gds-code = goods.gds-code no-error .
                        if not available (gds-list) then do:
                        create gds-list .
                        buffer-copy goods to gds-list .
                        end.
                        else next _next .
                    end.
                    if v-recs = 1 then
                    do:
                        assign
                            v-temp-seq = v-seq
                            v-line     = 0
                            v-item     = '':U
                            v-tbl-name = 'goods':U
                            v-bh       = buffer goods:handle
                            v-tot-lns  = tot-lns
                            .
                            if not v-first then dsp-rs     = substitute("Товар :&1 &2", goods.gds-name, stat-line(rs-status)) .
                            else dsp-rs     = substitute("Товар :&1 ", goods.gds-name) .
                    end.
                    else
                    do:
                        if num-rec = 0 then
                        do:
                            if not v-first then do:
                            assign
                                v-temp-seq = v-seq
                                v-line     = 0
                                v-item     = '':U
                                v-tbl-name = '':U
                                v-bh       = ?
                                v-tot-lns  = tot-lns
                                .
                                dsp-rs     = substitute("Товары : &1", stat-line(rs-status)) .
                            end.
                        end.
                        else
                        do:
                            assign
                                v-temp-seq = v-seq - 1
                                v-line     = num-rec
                                dsp-rs     = substitute("&1 ", goods.gds-name)
                                v-item     = '':U
                                v-tbl-name = 'goods':U
                                v-bh       = buffer goods:handle
                                v-tot-lns  = tot-lns + num-rec
                                .
                        end.
                    end.
                    v-no-hist = (if num-rec = 1 then 0 else num-rec).
                    if dsp-rs <> "" then do:
                    run create-gds-list-hist in this-procedure(input 'ДОБАВЛЕНИЕ':U
                        , input-output v-temp-seq
                        , input v-line
                        , input '':U
                        , input dsp-rs
                        , input v-tot-lns
                        , input rs-list-method
                        , input rs-status
                        , input v-item
                        , input v-tbl-name
                        , input v-bh
                        ).
                    if num-rec = 0 or v-recs = 1 then v-seq  = v-temp-seq.
                    end.
                end.
            end.
        lns-cnt = 0 .
        for each gds-list :
            lns-cnt = lns-cnt + 1 .
        end.
        define variable v-i as integer no-undo .
        s-notes =  "" .
        for each gds-list-hist :
            v-i = v-i + 1 .
            s-notes = s-notes + chr(10) + gds-list-hist.hist-mode +  gds-list-hist.des .
            if v-i > 10 then
            do:
                s-notes = s-notes + " ... " .
                leave.
            end.
        end.
        run display-count-other in this-procedure .
    END.
ON CHOOSE OF BUTTON-node IN FRAME Dialog-Frame
DO:
        run ref/gds-grp.w
            (             input my-handle
            ,input "b-sel,b-mark"
            ,input v-cntxt-obj-type
            ,input v-cntxt-obj-code
            ,input-output gdsgrp_recids ).
        run display-count-other in this-procedure .
    END.
ON CHOOSE OF BUTTON-prod IN FRAME Dialog-Frame
DO:
        define variable v-ind as integer no-undo .
        define buffer cli-prod for ub.clients .
        define variable cli-grp_recids as character no-undo .
        FOR EACH g#cli :
            delete g#cli .
        END .
        if SelectGood:screen-value = "3" then
        do:
            run ref/cli-all.w
                ( my-handle
                , "b-sel,b-mark"
                , 'про':U
                , 'все':U
                , 'текущие':U
                , ?
                , ",,,,,,NO,,"
                , ?
                , output cli-grp_recids ) no-error .
            if error-status :error then
                message vss-workfile vss-revision vss-description skip
                    error-status :get-message(1) skip
                    "Ошибка вызова cli-all.w"
                    view-as alert-box error .
            if cli-grp_recids = "" then
            do:
                Assign
                    goods-count  = ''
                    Goods-Editor = ''.
                Display goods-count Goods-Editor with frame Dialog-Frame .
            end.
            else
            do:
                DO v-ind = 1 TO num-entries( cli-grp_recids )
                    :
                    FIND cli-prod WHERE recid( cli-prod ) = int( entry(v-ind, cli-grp_recids ) ) NO-LOCK.
                    create g#cli.
                    assign
                        g#cli.obj-type = cli-prod.obj-type
                        g#cli.obj-code = cli-prod.obj-code
                        g#cli.obj-name = cli-prod.obj-name.
                END.
            end.
        end.
        else
        do:
            FOR EACH g#cli :
                delete g#cli .
            END .
            cli-grp_recids = "" .
        end.
        run display-count-other in this-procedure .
    END.
ON VALUE-CHANGED OF f-period IN FRAME Dialog-Frame
DO:
        assign f-period .
    END.
ON CHOOSE OF i-exit IN FRAME Dialog-Frame
DO:
        APPLY "choose" TO btn_ok.
    END.
ON VALUE-CHANGED OF period-control IN FRAME Dialog-Frame
DO:
        assign period-control .
        case period-control:
            when 0 then
                do:
                    hide f-period in frame Dialog-Frame .
                    f-period = "3" .
                end.
            when 1 then
                do:
                    hide f-period in frame Dialog-Frame .
                    f-period = "7" .
                end.
            when 2 then
                do:
                    hide f-period in frame Dialog-Frame .
                    f-period = "14" .
                end.
            when 3 then
                do:
                    enable f-period with frame Dialog-Frame .
                end.
        end case .
    END.
ON VALUE-CHANGED OF SelectGood IN FRAME Dialog-Frame
DO:
        run val-goods in this-procedure .
        RUN new-state ("SELECTGOOD="  + String(SelectGood:screen-value)).
    END.
  RUN set-attribute-list ('FIELDS-ENABLED=no,ADM-NEW-RECORD=no':U).
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
    ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    RUN enable_UI.
    hide BUTTON-node button-gds BUTTON-prod in frame Dialog-Frame .
    WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
    HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
    DISPLAY SelectGood period-control expired-goods Goods-Editor F-button-1
        TEXT-1 TEXT-2
        WITH FRAME Dialog-Frame.
    ENABLE b-exit Btn_OK BUTTON-1 i-exit RECT-8 RECT-9 SelectGood period-control
        expired-goods Goods-Editor F-button-1
        TEXT-1 TEXT-2
        WITH FRAME Dialog-Frame.
    VIEW FRAME Dialog-Frame.
END PROCEDURE.
FUNCTION customerName RETURNS CHARACTER
    ( p-dogovor as character) :
    define variable ii    as integer   no-undo .
    define variable name_ as character no-undo .
    define buffer buf_contract for ub.contract .
    do ii = 1 to num-entries(p-dogovor):
        find first buf_contract no-lock where buf_contract.contract-code = integer(entry(ii,p-dogovor,",")) no-error .
        if available (buf_contract) then
        do:
            name_ = name_ + ", " + buf_contract.contract-prn-code .
        end.
    end.
    if name_ <> "" then name_ = trim(name_,",") .
    RETURN name_ .
END FUNCTION.
PROCEDURE val-goods :
    If temp-param-goods <> "" THEN
    DO:
        assign
            Goods-Editor = ''
            goods-count = ''
            .
        Case Integer(SelectGood:screen-value IN frame Dialog-Frame):
            When 1 then
                DO:
                    hide BUTTON-gds BUTTON-node BUTTON-prod in frame Dialog-Frame .
                    Goods-Editor = " По всем товарам ".
                End.
            When 2 then
                DO:
                    hide BUTTON-gds BUTTON-prod in frame Dialog-Frame .
                    enable BUTTON-node  with frame Dialog-Frame .
                End.
             When 4 then
                DO:
                    hide BUTTON-node BUTTON-prod in frame Dialog-Frame .
                    enable BUTTON-gds with frame Dialog-Frame .
                END.
             When 3 then
                DO:
                    hide BUTTON-node BUTTON-gds in frame Dialog-Frame .
                    enable BUTTON-prod with frame Dialog-Frame .
                END.
        End case.
        enable Goods-Editor  with frame Dialog-Frame.
        display Goods-Editor goods-count with frame Dialog-Frame.
    End.
    Else  hide Goods-Editor in frame Dialog-Frame.
END PROCEDURE.
FUNCTION stat-line RETURNS CHARACTER(input p-status-chr as character):
    DEFINE VARIABLE var-stat-line as character no-undo .
    CASE p-status-chr:
        when 'все':U then
            do:
                assign
                    var-stat-line = "(текущие и неактивные товары)"
                    .
            end.
        when 'текущие':U then
            do:
                assign
                    var-stat-line = "(текущие товары)"
                    .
            end.
        when 'удаленные':U then
            do:
                assign
                    var-stat-line = "(неактивные товары)"
                    .
            end.
    END CASE.
    return var-stat-line .
END.
PROCEDURE Display-count :
if SelectGood = 6 then
    do:
        Assign
            goods-count  = '(Выбрано ' + string(lns-cnt) + ' список)'
            Goods-Editor = s-notes
            .
    end.
    else
    do:
        If can-find (First gds-list no-lock)
            then
            Assign
                goods-count  = '(Выбрано ' + string(lns-cnt) + ' товаров)'
                Goods-Editor = s-notes
                .
        else
            Assign
                goods-count  = ''
                Goods-Editor = ''
                .
    end.
    Display goods-count Goods-Editor with frame Dialog-Frame .
    x-Goods-Editor = Goods-Editor.
END PROCEDURE.
PROCEDURE Display-count-OTHER :
    x-SelectGood = Integer(SelectGood:screen-value IN frame Dialog-Frame).
    run sel-x-selectgood in this-procedure .
    if LENGTH (t-str) > 6000 then
    do:
        Assign
            Goods-Editor = substring(T-str ,1, 6000) + chr(10) + "выборка для просмотра обрезана - слишком много записей " .
    end.
    else Assign  Goods-Editor = T-str  .
    Display goods-count Goods-Editor with frame Dialog-Frame .
    x-Goods-Editor = Goods-Editor.
END PROCEDURE.
PROCEDURE sel-x-SelectGood :
    define variable grp_name as char.
    define buffer buf_gds-grp for ub.gds-grp .
    define variable my-c as int no-undo.
    IF temp-param-goods <> "" THEN
    DO:
        Case x-SelectGood :
            When 1 then
                t-str = " По всем товарам ".
            When 2 then
                DO:
                    t-str = " По группам "  .
                    For each  tmp#grp :
                        delete tmp#grp.
                    End.
                    define variable v-ind as integer no-undo .
                    Repeat v-ind = 1 To num-entries( gdsgrp_recids )
                        :
                        find first buf_gds-grp WHERE recid ( buf_gds-grp ) = integer ( Entry(v-ind,gdsgrp_recids )) NO-LOCK.
                        RUN grplib-get-full-name in this-procedure( input buf_gds-grp.node-code, output Grp_Name ).
                        if Grp_Name <> ? Then
                            if LENGTH(t-str) <= 6000 then t-str = t-str + chr(10) + "     " + Grp_Name .
                        Create tmp#grp.
                        Assign
                            tmp#grp.node-code = buf_gds-grp.node-code
                            tmp#grp.grp-name  = Grp_Name
                            tmp#grp.is-term   = buf_gds-grp.is-term
                            tmp#grp.lvl-num   = buf_gds-grp.lvl-num
                            .
                    end.
                    if num-entries( gdsgrp_recids ) > 0 THEN
                        goods-count = "выбрано " + string(num-entries( gdsgrp_recids )) + " групп " .
                    ELSE goods-count = "НЕ выбрано !!!".
                End.
            When 3 then
                DO:
                    t-str = ''.
                    t-str = " По производителям " .
                    my-c = 0.
                    for each g#cli no-lock:
                        if LENGTH(t-str) <= 6000 then t-str = t-str + chr(10) + "     " + g#cli.obj-name .
                        my-c =  my-c + 1 .
                    End.
                    if my-c > 0 THEN
                        goods-count = "выбрано " + String(my-c) .
                    ELSE goods-count = "НЕ выбрано !!!".
                END.
            When 4 then
                DO:
                    if can-find (first gds-list no-lock ) then
                    DO:
                        t-str = " По списку товаров " +  s-Notes.
                        goods-count = "выбрано " + String(lns-cnt) .
                    End.
                    Else Assign goods-count = "НЕ выбрано !!!" t-str       = "" lns-cnt     = 0 .
                End.
            When  6  then
                DO:
                    if  keep-spis <> "" then
                    DO:
                        t-str = s-Notes.
                        goods-count = "выбрано списков : " + String(lns-cnt) .
                    End.
                    Else Assign goods-count = "НЕ выбрано !!!" t-str       = "" lns-cnt     = 0 .
                End.
            When 5 then
                DO:
                    find first gds-list no-lock no-error.
                    if available gds-list THEN  Assign t-str       = " " +  gds-list.gds-name goods-count = "выбран 1 товар".
                    ELSE Assign t-str       = "" goods-count = "НЕ выбрано !!!" lns-cnt     = 0 .
                END.
            When 7 then
                DO:
                    t-str = " По группам "  .
                    For each  tmp#grp :
                        delete tmp#grp.
                    End.
                    Repeat v-ind = 1 To num-entries( gdsgrp_recids ):
                        find first buf_gds-grp WHERE recid ( buf_gds-grp ) = integer ( Entry(v-ind,gdsgrp_recids )) NO-LOCK.
                        run grplib-get-full-name in this-procedure ( input buf_gds-grp.node-code, output Grp_Name ).
                        if Grp_Name <> ? Then
                            if LENGTH(t-str) <= 6000 then t-str = t-str + chr(10) + "     " + Grp_Name .
                        Create tmp#grp.
                        Assign
                            tmp#grp.node-code = buf_gds-grp.node-code
                            tmp#grp.grp-name  = Grp_Name
                            tmp#grp.is-term   = buf_gds-grp.is-term
                            tmp#grp.lvl-num   = buf_gds-grp.lvl-num
                            .
                    end.
                    t-str = t-str + chr(10) +  " По производителям " .
                    my-c = 0.
                    for each g#cli no-lock:
                        t-str = t-str + chr(10) + "     " + g#cli.obj-name no-error .
                        my-c =  my-c + 1 .
                    End.
                    if num-entries( gdsgrp_recids ) > 0  and my-c > 0 THEN
                    DO:
                        goods-count = "выбрано " + string(num-entries( gdsgrp_recids )) + " групп "
                            + string(my-c) + " производителей " .
                    End.
                    ELSE goods-count = "НЕ выбрано !!!".
                End.
        End case.
    END.
END PROCEDURE.
PROCEDURE select-keep-spis :
    define input  parameter p-keep-spis as character no-undo .
    define buffer buf_clob-bind for ub.clob-bind  .
    keep-spis = p-keep-spis.
    find first buf_clob-bind no-lock where
        buf_clob-bind.field-name_ = keep-spis no-error .
    if available buf_clob-bind then
    do:
        keep-spis = buf_clob-bind.field-name_ .
        lns-cnt = 1 .
        s-notes = substitute("Хранимый Файл списка : &1 &2", buf_clob-bind.field-name, buf_clob-bind.descr ).
    end.
    else
    do:
        keep-spis = "".
        lns-cnt = 0 .
        s-notes = " " .
    end.
    run display-count       in this-procedure .
    run display-count-other in this-procedure .
    selectgood    = 6 .
    x-selectgood  = 6 .
    run val-goods in this-procedure .
END PROCEDURE.
