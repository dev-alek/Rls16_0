define input  parameter       p-type   as integer   no-undo .
define input-output parameter prod-zen as logical no-undo .
define output parameter       print-o  as character no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Поля для расширенной оборотки".
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
define variable parparentproc     as widget-handle no-undo.
assign parparentproc =  my-handle .
define variable g#userid as character no-undo .
run get-userid  in parparentproc ( output g#userid ).
define variable col-size as integer no-undo .
define variable s-column  as integer EXTENT   120  no-undo .
DEFINE BUTTON A-3
     LABEL "A3"
     SIZE 4.25 BY 1.13.
DEFINE BUTTON B-exit AUTO-GO
     LABEL "Ввод"
     SIZE 12 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-help
     LABEL "Помощь"
     SIZE 10.38 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-mark
     LABEL "Отметить *"
     SIZE 12 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-quit AUTO-END-KEY
     LABEL "Отмена"
     SIZE 12 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-unmark
     LABEL "Снять *"
     SIZE 12 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE only-text-exel AS CHARACTER INITIAL "На экране возможно отобразить ограниченное число символов. Полная информация возможна при выводе в Excel"
     VIEW-AS EDITOR NO-BOX
     SIZE 27.38 BY 2.83
     FGCOLOR 12 FONT 4 NO-UNDO.
DEFINE VARIABLE a3 AS CHARACTER FORMAT "X(256)":C6 INITIAL "A3"
      VIEW-AS TEXT
     SIZE 8.13 BY 1.58
     BGCOLOR 15 FGCOLOR 9 FONT 4 NO-UNDO.
DEFINE VARIABLE a4-lansc AS CHARACTER FORMAT "X(256)" INITIAL "A4"
      VIEW-AS TEXT
     SIZE 5.38 BY .96
     BGCOLOR 15 FGCOLOR 9 FONT 4 NO-UNDO.
DEFINE VARIABLE A4-port AS CHARACTER FORMAT "X(256)" INITIAL "A4"
      VIEW-AS TEXT
     SIZE 3.13 BY 1.46
     BGCOLOR 15 FGCOLOR 9 FONT 4 NO-UNDO.
DEFINE VARIABLE F-col-size AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 7 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE FILL-IN-10 AS CHARACTER FORMAT "X(256)":U INITIAL "Расход - Возврат"
      VIEW-AS TEXT
     SIZE 25 BY 1 NO-UNDO.
DEFINE VARIABLE FILL-IN-11 AS CHARACTER FORMAT "X(256)":U INITIAL "Касса продажа"
      VIEW-AS TEXT
     SIZE 25.38 BY 1 NO-UNDO.
DEFINE VARIABLE FILL-IN-12 AS CHARACTER FORMAT "X(256)":U INITIAL "Касса возврат"
      VIEW-AS TEXT
     SIZE 25.38 BY 1 NO-UNDO.
DEFINE VARIABLE FILL-IN-13 AS CHARACTER FORMAT "X(256)":U INITIAL "Касса продажа - возврат"
      VIEW-AS TEXT
     SIZE 25.13 BY 1 NO-UNDO.
DEFINE VARIABLE FILL-IN-14 AS CHARACTER FORMAT "X(256)":U INITIAL "Всего расход внеш."
      VIEW-AS TEXT
     SIZE 25 BY 1 NO-UNDO.
DEFINE VARIABLE FILL-IN-15 AS CHARACTER FORMAT "X(256)":U INITIAL "Всего возврат внеш."
      VIEW-AS TEXT
     SIZE 24.63 BY 1 NO-UNDO.
DEFINE VARIABLE FILL-IN-16 AS CHARACTER FORMAT "X(256)":U INITIAL "Всего расх.-возвр. внеш."
      VIEW-AS TEXT
     SIZE 24.13 BY 1 NO-UNDO.
DEFINE VARIABLE FILL-IN-17 AS CHARACTER FORMAT "X(256)":U INITIAL "Инвентаризация"
      VIEW-AS TEXT
     SIZE 23.75 BY 1 NO-UNDO.
DEFINE VARIABLE FILL-IN-18 AS CHARACTER FORMAT "X(256)":U INITIAL "Списание"
      VIEW-AS TEXT
     SIZE 23.63 BY 1 NO-UNDO.
DEFINE VARIABLE FILL-IN-19 AS CHARACTER FORMAT "X(256)":U INITIAL "Приход перемещение"
      VIEW-AS TEXT
     SIZE 23.75 BY 1 NO-UNDO.
DEFINE VARIABLE FILL-IN-2 AS CHARACTER FORMAT "X(256)":U INITIAL "Остатки"
      VIEW-AS TEXT
     SIZE 13 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE FILL-IN-20 AS CHARACTER FORMAT "X(256)":U INITIAL "Расход перемещение"
      VIEW-AS TEXT
     SIZE 23.75 BY 1 NO-UNDO.
DEFINE VARIABLE FILL-IN-21 AS CHARACTER FORMAT "X(256)":U INITIAL "Возврат перемещение"
      VIEW-AS TEXT
     SIZE 24.13 BY 1 NO-UNDO.
DEFINE VARIABLE FILL-IN-22 AS CHARACTER FORMAT "X(256)":U INITIAL "Приход производство"
      VIEW-AS TEXT
     SIZE 24.38 BY 1 NO-UNDO.
DEFINE VARIABLE FILL-IN-23 AS CHARACTER FORMAT "X(256)":U INITIAL "Расход производство"
      VIEW-AS TEXT
     SIZE 23.88 BY 1 NO-UNDO.
DEFINE VARIABLE FILL-IN-24 AS CHARACTER FORMAT "X(256)":U INITIAL "Переоценка"
      VIEW-AS TEXT
     SIZE 24.5 BY 1 NO-UNDO.
DEFINE VARIABLE FILL-IN-25 AS CHARACTER FORMAT "X(256)":U INITIAL "Код"
      VIEW-AS TEXT
     SIZE 29 BY .67 NO-UNDO.
DEFINE VARIABLE FILL-IN-26 AS CHARACTER FORMAT "X(256)":U INITIAL "Артикул"
      VIEW-AS TEXT
     SIZE 29 BY .67 NO-UNDO.
DEFINE VARIABLE FILL-IN-27 AS CHARACTER FORMAT "X(256)":U INITIAL "Название товара"
      VIEW-AS TEXT
     SIZE 29 BY .67 NO-UNDO.
DEFINE VARIABLE FILL-IN-28 AS CHARACTER FORMAT "X(256)":U INITIAL "Ед.изм"
      VIEW-AS TEXT
     SIZE 29 BY .67 NO-UNDO.
DEFINE VARIABLE FILL-IN-29 AS CHARACTER FORMAT "X(256)":U INITIAL "Дата последней переоценки"
      VIEW-AS TEXT
     SIZE 29 BY .67 NO-UNDO.
DEFINE VARIABLE FILL-IN-3 AS CHARACTER FORMAT "X(256)":U INITIAL "Остаток на начало"
      VIEW-AS TEXT
     SIZE 23.5 BY 1 NO-UNDO.
DEFINE VARIABLE FILL-IN-30 AS CHARACTER FORMAT "X(256)":U INITIAL "Эффективность"
      VIEW-AS TEXT
     SIZE 24.63 BY .67 NO-UNDO.
DEFINE VARIABLE FILL-IN-31 AS CHARACTER FORMAT "X(256)":U INITIAL "Фактический % наценки"
      VIEW-AS TEXT
     SIZE 24.75 BY .67 NO-UNDO.
DEFINE VARIABLE FILL-IN-32 AS CHARACTER FORMAT "X(256)":U INITIAL "Учетная цена"
      VIEW-AS TEXT
     SIZE 29 BY .67 NO-UNDO.
DEFINE VARIABLE FILL-IN-39 AS CHARACTER FORMAT "X(256)":U INITIAL "Кол-во"
      VIEW-AS TEXT
     SIZE 7.38 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE FILL-IN-4 AS CHARACTER FORMAT "X(256)":U INITIAL "Остаток на конец"
      VIEW-AS TEXT
     SIZE 23.88 BY 1 NO-UNDO.
DEFINE VARIABLE FILL-IN-40 AS CHARACTER FORMAT "X(256)":U INITIAL "Сумма"
      VIEW-AS TEXT
     SIZE 6.38 BY .63
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE FILL-IN-41 AS CHARACTER FORMAT "X(256)":U INITIAL "учет. цен"
      VIEW-AS TEXT
     SIZE 9.63 BY .63
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE FILL-IN-42 AS CHARACTER FORMAT "X(256)":U INITIAL "прод. цен"
      VIEW-AS TEXT
     SIZE 9.25 BY .63
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE FILL-IN-43 AS CHARACTER FORMAT "X(256)":U INITIAL "Сумма"
      VIEW-AS TEXT
     SIZE 6.38 BY .63
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE FILL-IN-44 AS CHARACTER FORMAT "X(256)":U INITIAL "Сумма"
      VIEW-AS TEXT
     SIZE 6.38 BY .63
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE FILL-IN-45 AS CHARACTER FORMAT "X(256)":U INITIAL "скидок"
      VIEW-AS TEXT
     SIZE 6.38 BY .63
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE FILL-IN-46 AS CHARACTER FORMAT "X(256)":U INITIAL "скидок"
      VIEW-AS TEXT
     SIZE 6.38 BY .63
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE FILL-IN-47 AS CHARACTER FORMAT "X(256)":U INITIAL "%"
      VIEW-AS TEXT
     SIZE 3.25 BY .63
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE FILL-IN-48 AS CHARACTER FORMAT "X(256)":U INITIAL "Продажная цена"
      VIEW-AS TEXT
     SIZE 25.5 BY .67 NO-UNDO.
DEFINE VARIABLE FILL-IN-49 AS CHARACTER FORMAT "X(256)":U INITIAL "Номер последней переоценки"
      VIEW-AS TEXT
     SIZE 29 BY .67 NO-UNDO.
DEFINE VARIABLE FILL-IN-5 AS CHARACTER FORMAT "X(256)":U INITIAL "Оборот"
      VIEW-AS TEXT
     SIZE 13 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE FILL-IN-50 AS CHARACTER FORMAT "X(256)":U INITIAL "Наценка на конец периода"
      VIEW-AS TEXT
     SIZE 29 BY .67 NO-UNDO.
DEFINE VARIABLE FILL-IN-51 AS CHARACTER FORMAT "X(256)" INITIAL "  Формат вывода на печать  "
      VIEW-AS TEXT
     SIZE 25.88 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE FILL-IN-52 AS CHARACTER FORMAT "X(256)":U INITIAL "Свободно на конец"
      VIEW-AS TEXT
     SIZE 23.88 BY .71 NO-UNDO.
DEFINE VARIABLE FILL-IN-53 AS CHARACTER FORMAT "X(256)":U INITIAL "Зарезервировано на конец"
      VIEW-AS TEXT
     SIZE 25 BY .67 NO-UNDO.
DEFINE VARIABLE FILL-IN-6 AS CHARACTER FORMAT "X(256)":U INITIAL "Приход внешний"
      VIEW-AS TEXT
     SIZE 23.88 BY 1 NO-UNDO.
DEFINE VARIABLE FILL-IN-7 AS CHARACTER FORMAT "X(256)":U INITIAL "Возврат поставщику"
      VIEW-AS TEXT
     SIZE 24.13 BY 1 NO-UNDO.
DEFINE VARIABLE FILL-IN-8 AS CHARACTER FORMAT "X(256)":U INITIAL "Расход внешний"
      VIEW-AS TEXT
     SIZE 24.75 BY 1 NO-UNDO.
DEFINE VARIABLE FILL-IN-9 AS CHARACTER FORMAT "X(256)":U INITIAL "Возврат внешний"
      VIEW-AS TEXT
     SIZE 25 BY 1 NO-UNDO.
DEFINE VARIABLE only-file AS CHARACTER FORMAT "X(256)" INITIAL "  вывод в файл  "
      VIEW-AS TEXT
     SIZE 16 BY .67
     BGCOLOR 15 FGCOLOR 9  NO-UNDO.
DEFINE VARIABLE RADIO-SET-2 AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Средняя за период", 1,
"Последняя за период", 2
     SIZE 28.13 BY 1.29 NO-UNDO.
DEFINE RECTANGLE RECT-18
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 66 BY 17.33.
DEFINE RECTANGLE RECT-19
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 65.88 BY 3.75.
DEFINE RECTANGLE RECT-20
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 29.38 BY 2.
DEFINE RECTANGLE RECT-21
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 36.38 BY 17.25.
DEFINE VARIABLE TOG-1 AS LOGICAL INITIAL yes
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .67 NO-UNDO.
DEFINE VARIABLE TOG-10 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .67 NO-UNDO.
DEFINE VARIABLE TOG-11 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .67 NO-UNDO.
DEFINE VARIABLE TOG-12 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .88 NO-UNDO.
DEFINE VARIABLE TOG-13 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .88 NO-UNDO.
DEFINE VARIABLE TOG-14 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .88 NO-UNDO.
DEFINE VARIABLE TOG-15 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .88 NO-UNDO.
DEFINE VARIABLE TOG-16 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .88 NO-UNDO.
DEFINE VARIABLE TOG-17 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE TOG-18 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE TOG-19 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE TOG-2 AS LOGICAL INITIAL yes
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .67 NO-UNDO.
DEFINE VARIABLE TOG-20 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE TOG-21 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE TOG-22 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .75 NO-UNDO.
DEFINE VARIABLE TOG-23 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE TOG-24 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE TOG-25 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE TOG-26 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE TOG-27 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE TOG-28 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE TOG-29 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE TOG-3 AS LOGICAL INITIAL yes
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .67 NO-UNDO.
DEFINE VARIABLE TOG-30 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE TOG-31 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE TOG-32 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE TOG-33 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE TOG-34 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE TOG-35 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE TOG-36 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE TOG-37 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE TOG-38 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE TOG-39 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE TOG-4 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .67 NO-UNDO.
DEFINE VARIABLE TOG-40 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE TOG-41 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE TOG-42 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE TOG-43 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .71 NO-UNDO.
DEFINE VARIABLE TOG-44 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE TOG-45 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE TOG-46 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE TOG-47 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE TOG-48 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE TOG-49 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE TOG-5 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .67 NO-UNDO.
DEFINE VARIABLE TOG-50 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .75 NO-UNDO.
DEFINE VARIABLE TOG-51 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE TOG-52 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE TOG-53 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE TOG-54 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE TOG-55 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE TOG-56 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE TOG-57 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE TOG-58 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE TOG-59 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE TOG-6 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .67 NO-UNDO.
DEFINE VARIABLE TOG-60 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE TOG-61 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE TOG-62 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE TOG-63 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE TOG-64 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE TOG-65 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE TOG-66 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE TOG-67 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE TOG-68 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE TOG-69 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE TOG-7 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .67 NO-UNDO.
DEFINE VARIABLE TOG-70 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE TOG-71 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE TOG-72 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE TOG-73 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE TOG-74 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE TOG-75 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE TOG-76 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE TOG-77 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE TOG-78 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE TOG-79 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE TOG-8 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .67 NO-UNDO.
DEFINE VARIABLE TOG-80 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE TOG-81 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE TOG-82 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE TOG-83 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE TOG-84 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE TOG-85 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE TOG-86 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.38 BY .83 NO-UNDO.
DEFINE VARIABLE TOG-87 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE TOG-88 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.13 BY .83 NO-UNDO.
DEFINE VARIABLE TOG-89 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .88 NO-UNDO.
DEFINE VARIABLE TOG-9 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .67 NO-UNDO.
DEFINE VARIABLE TOG-90 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE TOG-91 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE TOG-92 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .88 NO-UNDO.
DEFINE VARIABLE TOG-93 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE TOG-94 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE TOG-95 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE VARIABLE TOG-96 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .83 NO-UNDO.
DEFINE FRAME Dialog-Frame
     B-quit AT ROW 1 COL 2.25
     B-exit AT ROW 1 COL 14.25
     B-mark AT ROW 1 COL 26.25
     B-unmark AT ROW 1 COL 38.13
     B-help AT ROW 1 COL 50.25
     TOG-1 AT ROW 2.92 COL 35.5 RIGHT-ALIGNED
     TOG-12 AT ROW 3.04 COL 67.75 RIGHT-ALIGNED
     TOG-31 AT ROW 3.04 COL 76.25 RIGHT-ALIGNED
     TOG-50 AT ROW 3.08 COL 84.75 RIGHT-ALIGNED
     TOG-2 AT ROW 3.79 COL 35.5 RIGHT-ALIGNED
     TOG-13 AT ROW 3.88 COL 67.75 RIGHT-ALIGNED
     TOG-51 AT ROW 3.88 COL 84.75 RIGHT-ALIGNED
     TOG-32 AT ROW 3.92 COL 76.38 RIGHT-ALIGNED
     TOG-3 AT ROW 4.67 COL 35.5 RIGHT-ALIGNED
     TOG-89 AT ROW 4.79 COL 67.75 RIGHT-ALIGNED
     TOG-90 AT ROW 4.79 COL 76.25 RIGHT-ALIGNED
     TOG-91 AT ROW 4.79 COL 84.75 RIGHT-ALIGNED
     TOG-4 AT ROW 5.54 COL 35.5 RIGHT-ALIGNED
     TOG-92 AT ROW 5.67 COL 67.75 RIGHT-ALIGNED
     TOG-93 AT ROW 5.67 COL 76.25 RIGHT-ALIGNED
     TOG-94 AT ROW 5.67 COL 84.75 RIGHT-ALIGNED
     TOG-95 AT ROW 5.71 COL 96.38 RIGHT-ALIGNED
     TOG-96 AT ROW 5.71 COL 102.63 RIGHT-ALIGNED
     TOG-5 AT ROW 6.33 COL 35.5 RIGHT-ALIGNED
     TOG-6 AT ROW 7.08 COL 35.5 RIGHT-ALIGNED
     TOG-14 AT ROW 7.17 COL 67.75 RIGHT-ALIGNED
     TOG-33 AT ROW 7.17 COL 76.38 RIGHT-ALIGNED
     RADIO-SET-2 AT ROW 7.67 COL 2.88 NO-LABEL
     TOG-15 AT ROW 7.96 COL 67.75 RIGHT-ALIGNED
     TOG-34 AT ROW 8.08 COL 76.38 RIGHT-ALIGNED
     TOG-7 AT ROW 9 COL 35.5 RIGHT-ALIGNED
     TOG-16 AT ROW 9.04 COL 67.75 RIGHT-ALIGNED
     TOG-35 AT ROW 9.04 COL 76.38 RIGHT-ALIGNED
     TOG-52 AT ROW 9.04 COL 84.75 RIGHT-ALIGNED
     TOG-68 AT ROW 9.04 COL 96.38 RIGHT-ALIGNED
     TOG-77 AT ROW 9.04 COL 102.63 RIGHT-ALIGNED
     TOG-8 AT ROW 9.75 COL 35.5 RIGHT-ALIGNED
     TOG-17 AT ROW 9.88 COL 67.75 RIGHT-ALIGNED
     TOG-36 AT ROW 9.88 COL 76.38 RIGHT-ALIGNED
     TOG-53 AT ROW 9.88 COL 84.75 RIGHT-ALIGNED
     TOG-69 AT ROW 9.88 COL 96.38 RIGHT-ALIGNED
     TOG-78 AT ROW 9.88 COL 102.63 RIGHT-ALIGNED
     TOG-9 AT ROW 10.46 COL 35.5 RIGHT-ALIGNED
     TOG-18 AT ROW 10.71 COL 67.75 RIGHT-ALIGNED
     TOG-37 AT ROW 10.71 COL 76.38 RIGHT-ALIGNED
     TOG-54 AT ROW 10.71 COL 84.75 RIGHT-ALIGNED
     TOG-70 AT ROW 10.71 COL 96.38 RIGHT-ALIGNED
     TOG-79 AT ROW 10.71 COL 102.63 RIGHT-ALIGNED
     TOG-10 AT ROW 11.21 COL 35.5 RIGHT-ALIGNED
     TOG-19 AT ROW 11.58 COL 67.75 RIGHT-ALIGNED
     TOG-55 AT ROW 11.58 COL 84.75 RIGHT-ALIGNED
     TOG-71 AT ROW 11.58 COL 96.38 RIGHT-ALIGNED
     TOG-80 AT ROW 11.58 COL 102.63 RIGHT-ALIGNED
     TOG-38 AT ROW 11.63 COL 76.38 RIGHT-ALIGNED
     TOG-11 AT ROW 12 COL 35.5 RIGHT-ALIGNED WIDGET-ID 24
     TOG-20 AT ROW 12.42 COL 67.75 RIGHT-ALIGNED
     TOG-56 AT ROW 12.42 COL 84.75 RIGHT-ALIGNED
     TOG-72 AT ROW 12.42 COL 96.38 RIGHT-ALIGNED
     TOG-82 AT ROW 12.42 COL 102.63 RIGHT-ALIGNED
     TOG-39 AT ROW 12.5 COL 76.38 RIGHT-ALIGNED
     TOG-73 AT ROW 13.08 COL 96.38 RIGHT-ALIGNED
     TOG-21 AT ROW 13.25 COL 67.75 RIGHT-ALIGNED
     TOG-40 AT ROW 13.25 COL 76.38 RIGHT-ALIGNED
     TOG-57 AT ROW 13.25 COL 84.75 RIGHT-ALIGNED
     TOG-81 AT ROW 13.29 COL 102.63 RIGHT-ALIGNED
     TOG-58 AT ROW 14.25 COL 84.75 RIGHT-ALIGNED
     TOG-74 AT ROW 14.25 COL 96.38 RIGHT-ALIGNED
     TOG-83 AT ROW 14.25 COL 102.63 RIGHT-ALIGNED
     TOG-22 AT ROW 14.29 COL 67.75 RIGHT-ALIGNED
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         DEFAULT-BUTTON B-exit CANCEL-BUTTON B-quit.
DEFINE FRAME Dialog-Frame
     TOG-41 AT ROW 14.29 COL 76.38 RIGHT-ALIGNED
     TOG-42 AT ROW 15.08 COL 76.38 RIGHT-ALIGNED
     TOG-59 AT ROW 15.08 COL 84.63 RIGHT-ALIGNED
     TOG-75 AT ROW 15.08 COL 96.38 RIGHT-ALIGNED
     TOG-84 AT ROW 15.08 COL 102.63 RIGHT-ALIGNED
     TOG-23 AT ROW 15.17 COL 67.75 RIGHT-ALIGNED
     TOG-24 AT ROW 15.88 COL 67.75 RIGHT-ALIGNED
     TOG-60 AT ROW 15.92 COL 84.75 RIGHT-ALIGNED
     TOG-76 AT ROW 15.92 COL 96.38 RIGHT-ALIGNED
     TOG-85 AT ROW 15.92 COL 102.63 RIGHT-ALIGNED
     TOG-43 AT ROW 15.96 COL 76.38 RIGHT-ALIGNED
     TOG-25 AT ROW 16.96 COL 67.88 RIGHT-ALIGNED
     TOG-61 AT ROW 16.96 COL 84.75 RIGHT-ALIGNED
     TOG-44 AT ROW 17 COL 76.38 RIGHT-ALIGNED
     TOG-26 AT ROW 17.75 COL 67.88 RIGHT-ALIGNED
     TOG-45 AT ROW 17.75 COL 76.38 RIGHT-ALIGNED
     TOG-62 AT ROW 17.75 COL 84.75 RIGHT-ALIGNED
     TOG-46 AT ROW 18.63 COL 76.38 RIGHT-ALIGNED
     TOG-27 AT ROW 18.71 COL 67.88 RIGHT-ALIGNED
     TOG-63 AT ROW 18.71 COL 84.75 RIGHT-ALIGNED
     TOG-47 AT ROW 19.42 COL 76.38 RIGHT-ALIGNED
     TOG-28 AT ROW 19.46 COL 67.88 RIGHT-ALIGNED
     TOG-64 AT ROW 19.46 COL 84.75 RIGHT-ALIGNED
     TOG-48 AT ROW 20.21 COL 76.38 RIGHT-ALIGNED
     TOG-29 AT ROW 20.33 COL 67.88 RIGHT-ALIGNED
     TOG-65 AT ROW 20.33 COL 84.75 RIGHT-ALIGNED
     TOG-30 AT ROW 21.29 COL 67.88 RIGHT-ALIGNED
     TOG-66 AT ROW 21.29 COL 84.75 RIGHT-ALIGNED
     TOG-49 AT ROW 21.33 COL 76.38 RIGHT-ALIGNED
     only-text-exel AT ROW 21.42 COL 4.38 NO-LABEL
     TOG-86 AT ROW 22.13 COL 66.38
     TOG-87 AT ROW 22.13 COL 75
     TOG-88 AT ROW 22.13 COL 83.38
     TOG-67 AT ROW 23 COL 84.75 RIGHT-ALIGNED
     A-3 AT ROW 23.04 COL 26.88
     FILL-IN-40 AT ROW 1.33 COL 72.5 NO-LABEL
     FILL-IN-43 AT ROW 1.33 COL 82 NO-LABEL
     FILL-IN-44 AT ROW 1.33 COL 91.5 NO-LABEL
     FILL-IN-39 AT ROW 1.38 COL 63.75 NO-LABEL
     FILL-IN-47 AT ROW 1.38 COL 99.25 NO-LABEL
     FILL-IN-41 AT ROW 1.92 COL 70.88 NO-LABEL
     FILL-IN-42 AT ROW 1.96 COL 80.88 NO-LABEL
     FILL-IN-45 AT ROW 1.96 COL 91.13 NO-LABEL
     FILL-IN-46 AT ROW 1.96 COL 98.25 NO-LABEL
     FILL-IN-2 AT ROW 2.46 COL 43 NO-LABEL
     FILL-IN-25 AT ROW 3 COL 2.38 NO-LABEL
     FILL-IN-3 AT ROW 3.04 COL 41 NO-LABEL
     FILL-IN-26 AT ROW 3.75 COL 2.38 NO-LABEL
     FILL-IN-4 AT ROW 3.92 COL 41 NO-LABEL
     FILL-IN-27 AT ROW 4.63 COL 2.38 NO-LABEL
     FILL-IN-52 AT ROW 4.83 COL 41 NO-LABEL
     FILL-IN-28 AT ROW 5.46 COL 2.38 NO-LABEL
     FILL-IN-53 AT ROW 5.67 COL 41 NO-LABEL
     FILL-IN-32 AT ROW 6.25 COL 2.38 NO-LABEL
     FILL-IN-5 AT ROW 6.58 COL 43 NO-LABEL
     FILL-IN-48 AT ROW 7.08 COL 2.13 NO-LABEL
     FILL-IN-6 AT ROW 7.25 COL 41 NO-LABEL
     FILL-IN-7 AT ROW 8.04 COL 41 NO-LABEL
     FILL-IN-50 AT ROW 9 COL 2.38 NO-LABEL
     FILL-IN-8 AT ROW 9.04 COL 41 NO-LABEL
     FILL-IN-29 AT ROW 9.75 COL 2.38 NO-LABEL
     FILL-IN-9 AT ROW 9.83 COL 41 NO-LABEL
     FILL-IN-49 AT ROW 10.46 COL 2.38 NO-LABEL
     FILL-IN-10 AT ROW 10.63 COL 41 NO-LABEL
     FILL-IN-30 AT ROW 11.21 COL 2.5 NO-LABEL
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         DEFAULT-BUTTON B-exit CANCEL-BUTTON B-quit.
DEFINE FRAME Dialog-Frame
     FILL-IN-11 AT ROW 11.63 COL 41 NO-LABEL
     FILL-IN-31 AT ROW 12 COL 2.5 NO-LABEL WIDGET-ID 22
     FILL-IN-12 AT ROW 12.46 COL 41 NO-LABEL
     FILL-IN-13 AT ROW 13.25 COL 41 NO-LABEL
     FILL-IN-14 AT ROW 14.25 COL 41 NO-LABEL
     FILL-IN-15 AT ROW 15.04 COL 41 NO-LABEL
     FILL-IN-16 AT ROW 15.83 COL 41 NO-LABEL
     FILL-IN-17 AT ROW 16.83 COL 41 NO-LABEL
     FILL-IN-18 AT ROW 17.63 COL 41 NO-LABEL
     FILL-IN-19 AT ROW 18.63 COL 41 NO-LABEL
     FILL-IN-20 AT ROW 19.46 COL 41 NO-LABEL
     FILL-IN-21 AT ROW 20.25 COL 41 NO-LABEL
     FILL-IN-51 AT ROW 20.5 COL 4 NO-LABEL
     F-col-size AT ROW 20.5 COL 29 COLON-ALIGNED NO-LABEL
     FILL-IN-22 AT ROW 21.25 COL 41 NO-LABEL
     FILL-IN-23 AT ROW 21.96 COL 39 COLON-ALIGNED NO-LABEL
     a3 AT ROW 22.08 COL 12.5 COLON-ALIGNED NO-LABEL
     A4-port AT ROW 22.25 COL 15.38 COLON-ALIGNED NO-LABEL
     a4-lansc AT ROW 22.42 COL 13.88 COLON-ALIGNED NO-LABEL
     only-file AT ROW 22.5 COL 7.25 COLON-ALIGNED NO-LABEL
     FILL-IN-24 AT ROW 23.21 COL 39 COLON-ALIGNED NO-LABEL
     "(-скидки)" VIEW-AS TEXT
          SIZE 8.75 BY .67 AT ROW 15.92 COL 85.5
     "(-скидки)" VIEW-AS TEXT
          SIZE 8.75 BY .67 AT ROW 13.38 COL 85.38
     "Колонки":C28 VIEW-AS TEXT
          SIZE 27.38 BY .67 AT ROW 2.08 COL 2.25
          FGCOLOR 4
     "Показать":C8 VIEW-AS TEXT
          SIZE 8.88 BY .67 AT ROW 2.08 COL 31.38
          FGCOLOR 4
     "(-скидки)" VIEW-AS TEXT
          SIZE 8.75 BY .67 AT ROW 10.83 COL 85.5
     "(-скидки)" VIEW-AS TEXT
          SIZE 8.75 BY .67 AT ROW 5.79 COL 85.5
     RECT-21 AT ROW 7.25 COL 70.5
     RECT-18 AT ROW 6.96 COL 40.5
     RECT-19 AT ROW 2.83 COL 40.5
     RECT-20 AT ROW 7.04 COL 1.75
     SPACE(75.99) SKIP(15.49)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Выбор колонок для печати"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON B-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       A-3:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       B-help:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       B-unmark:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       only-text-exel:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF A-3 IN FRAME Dialog-Frame
DO:
  Display a3  with frame Dialog-Frame.
  Hide  A4-port  a4-lansc  only-file  in frame Dialog-Frame.
  print-o = "A3-lansc":U.
END.
ON CHOOSE OF B-exit IN FRAME Dialog-Frame
DO:
  define variable l-ind as integer no-undo .
  run eq-frame.
 find first ubflt.usr-flt share-lock
   where ubflt.usr-flt.user-name  = g#userid
     and ubflt.usr-flt.call-point = "e-obort1":U
   no-error .
 if NOT avail ubflt.usr-flt then  create ubflt.usr-flt.
 Assign
   ubflt.usr-flt.user-name = g#userid
   ubflt.usr-flt.call-point   = "e-obort1":U
   ubflt.usr-flt.list_ = "" .
   repeat l-ind = 1 to 120 :
     if   use-column[ l-ind ] =  true then ubflt.usr-flt.list_ = ubflt.usr-flt.list_  + string( l-ind ) + "," .
   End.
   ubflt.usr-flt.list_ = ubflt.usr-flt.list_  + string( "print-o=" + print-o ) + ",prod-zen=" + string( prod-zen ) + "," .
END.
ON CHOOSE OF B-mark IN FRAME Dialog-Frame
DO:
  Assign
   TOG-1:screen-value  in frame Dialog-Frame = string( true  )
   TOG-2:screen-value  in frame Dialog-Frame = string( true  )
   TOG-3:screen-value  in frame Dialog-Frame = string( true  )
   TOG-4:screen-value  in frame Dialog-Frame = string( true  )
   TOG-5:screen-value  in frame Dialog-Frame = string( true  )
   TOG-6:screen-value  in frame Dialog-Frame = string( true  )
   TOG-7:screen-value  in frame Dialog-Frame = string( true  )
   TOG-8:screen-value  in frame Dialog-Frame = string( true  )
   TOG-9:screen-value  in frame Dialog-Frame = string( true  )
   TOG-10:screen-value in frame Dialog-Frame = string( true  )
   TOG-11:screen-value in frame Dialog-Frame = string( true  )
   TOG-12:screen-value in frame Dialog-Frame = string( true  )
   TOG-13:screen-value in frame Dialog-Frame = string( true  )
   TOG-14:screen-value in frame Dialog-Frame = string( true  )
   TOG-15:screen-value in frame Dialog-Frame = string( true  )
   TOG-16:screen-value in frame Dialog-Frame = string( true  )
   TOG-17:screen-value in frame Dialog-Frame = string( true  )
   TOG-18:screen-value in frame Dialog-Frame = string( true  )
   TOG-19:screen-value in frame Dialog-Frame = string( true  )
   TOG-20:screen-value in frame Dialog-Frame = string( true  )
   TOG-21:screen-value in frame Dialog-Frame = string( true )
   TOG-22:screen-value in frame Dialog-Frame = string( true )
   TOG-23:screen-value in frame Dialog-Frame = string( true )
   TOG-24:screen-value in frame Dialog-Frame = string( true )
   TOG-25:screen-value in frame Dialog-Frame = string( true )
   TOG-26:screen-value in frame Dialog-Frame = string( true )
   TOG-27:screen-value in frame Dialog-Frame = string( true )
   TOG-28:screen-value in frame Dialog-Frame = string( true )
   TOG-29:screen-value in frame Dialog-Frame = string( true )
   TOG-30:screen-value in frame Dialog-Frame = string( true )
   TOG-31:screen-value  in frame Dialog-Frame = string( true )
   TOG-32:screen-value  in frame Dialog-Frame = string( true )
   TOG-33:screen-value  in frame Dialog-Frame = string( true )
   TOG-34:screen-value  in frame Dialog-Frame = string( true )
   TOG-35:screen-value  in frame Dialog-Frame = string( true )
   TOG-36:screen-value  in frame Dialog-Frame = string( true )
   TOG-37:screen-value  in frame Dialog-Frame = string( true )
   TOG-38:screen-value  in frame Dialog-Frame = string( true )
   TOG-39:screen-value  in frame Dialog-Frame = string( true )
   TOG-40:screen-value  in frame Dialog-Frame = string( true )
   TOG-41:screen-value  in frame Dialog-Frame = string( true )
   TOG-42:screen-value  in frame Dialog-Frame = string( true )
   TOG-43:screen-value  in frame Dialog-Frame = string( true )
   TOG-44:screen-value  in frame Dialog-Frame = string( true )
   TOG-45:screen-value  in frame Dialog-Frame = string( true )
   TOG-46:screen-value  in frame Dialog-Frame = string( true )
   TOG-47:screen-value  in frame Dialog-Frame = string( true )
   TOG-48:screen-value  in frame Dialog-Frame = string( true )
   TOG-49:screen-value  in frame Dialog-Frame = string( true )
   TOG-50:screen-value  in frame Dialog-Frame = string( true )
   TOG-51:screen-value  in frame Dialog-Frame = string( true )
   TOG-52:screen-value  in frame Dialog-Frame = string( true )
   TOG-53:screen-value  in frame Dialog-Frame = string( true )
   TOG-54:screen-value  in frame Dialog-Frame = string( true )
   TOG-55:screen-value  in frame Dialog-Frame = string( true )
   TOG-56:screen-value  in frame Dialog-Frame = string( true )
   TOG-57:screen-value  in frame Dialog-Frame = string( true )
   TOG-58:screen-value  in frame Dialog-Frame = string( true )
   TOG-59:screen-value  in frame Dialog-Frame = string( true )
   TOG-60:screen-value  in frame Dialog-Frame = string( true )
   TOG-61:screen-value  in frame Dialog-Frame = string( true )
   TOG-62:screen-value  in frame Dialog-Frame = string( true )
   TOG-63:screen-value  in frame Dialog-Frame = string( true )
   TOG-64:screen-value  in frame Dialog-Frame = string( true )
   TOG-65:screen-value  in frame Dialog-Frame = string( true )
   TOG-66:screen-value  in frame Dialog-Frame = string( true )
   TOG-67:screen-value  in frame Dialog-Frame = string( true )
   TOG-68:screen-value  in frame Dialog-Frame = string( true )
   TOG-69:screen-value  in frame Dialog-Frame = string( true )
   TOG-70:screen-value  in frame Dialog-Frame = string( true )
   TOG-71:screen-value  in frame Dialog-Frame = string( true )
   TOG-72:screen-value  in frame Dialog-Frame = string( true )
   TOG-73:screen-value  in frame Dialog-Frame = string( true )
   TOG-74:screen-value  in frame Dialog-Frame = string( true )
   TOG-75:screen-value  in frame Dialog-Frame = string( true )
   TOG-76:screen-value  in frame Dialog-Frame = string( true )
   TOG-77:screen-value  in frame Dialog-Frame = string( true )
   TOG-78:screen-value  in frame Dialog-Frame = string( true )
   TOG-79:screen-value  in frame Dialog-Frame = string( true )
   TOG-80:screen-value  in frame Dialog-Frame = string( true )
   TOG-81:screen-value  in frame Dialog-Frame = string( true )
   TOG-82:screen-value  in frame Dialog-Frame = string( true )
   TOG-83:screen-value  in frame Dialog-Frame = string( true )
   TOG-84:screen-value  in frame Dialog-Frame = string( true )
   TOG-85:screen-value  in frame Dialog-Frame = string( true )
   TOG-86:screen-value  in frame Dialog-Frame = string( true )
   TOG-87:screen-value  in frame Dialog-Frame = string( true )
   TOG-88:screen-value  in frame Dialog-Frame = string( true )
   TOG-89:screen-value  in frame Dialog-Frame = string( true )
   TOG-90:screen-value  in frame Dialog-Frame = string( true )
   TOG-91:screen-value  in frame Dialog-Frame = string( true )
   TOG-92:screen-value  in frame Dialog-Frame = string( true )
   TOG-93:screen-value  in frame Dialog-Frame = string( true )
   TOG-94:screen-value  in frame Dialog-Frame = string( true )
   TOG-95:screen-value  in frame Dialog-Frame = string( true )
   TOG-96:screen-value  in frame Dialog-Frame = string( true )
  .
  Display
     only-text-exel
     with frame Dialog-Frame.
  Hide
  only-file
  a-3
  A4-port
  a4-lansc
  a3
  in frame Dialog-Frame.
  print-o = "to-file":U.
END.
ON CHOOSE OF B-unmark IN FRAME Dialog-Frame
DO:
  Assign
   TOG-1:screen-value  in frame Dialog-Frame = string( false  )
   TOG-2:screen-value  in frame Dialog-Frame = string( false  )
   TOG-3:screen-value  in frame Dialog-Frame = string( false  )
   TOG-4:screen-value  in frame Dialog-Frame = string( false  )
   TOG-5:screen-value  in frame Dialog-Frame = string( false  )
   TOG-6:screen-value  in frame Dialog-Frame = string( false  )
   TOG-7:screen-value  in frame Dialog-Frame = string( false  )
   TOG-8:screen-value  in frame Dialog-Frame = string( false  )
   TOG-9:screen-value  in frame Dialog-Frame = string( false  )
   TOG-10:screen-value in frame Dialog-Frame = string( false  )
   TOG-11:screen-value in frame Dialog-Frame = string( false  )
   TOG-12:screen-value in frame Dialog-Frame = string( false  )
   TOG-13:screen-value in frame Dialog-Frame = string( false  )
   TOG-14:screen-value in frame Dialog-Frame = string( false  )
   TOG-15:screen-value in frame Dialog-Frame = string( false  )
   TOG-16:screen-value in frame Dialog-Frame = string( false  )
   TOG-17:screen-value in frame Dialog-Frame = string( false  )
   TOG-18:screen-value in frame Dialog-Frame = string( false  )
   TOG-19:screen-value in frame Dialog-Frame = string( false  )
   TOG-20:screen-value in frame Dialog-Frame = string( false  )
   TOG-21:screen-value in frame Dialog-Frame = string( false  )
   TOG-22:screen-value in frame Dialog-Frame = string( false  )
   TOG-23:screen-value in frame Dialog-Frame = string( false  )
   TOG-24:screen-value in frame Dialog-Frame = string( false  )
   TOG-25:screen-value in frame Dialog-Frame = string( false  )
   TOG-26:screen-value in frame Dialog-Frame = string( false  )
   TOG-27:screen-value in frame Dialog-Frame = string( false  )
   TOG-28:screen-value in frame Dialog-Frame = string( false  )
   TOG-29:screen-value in frame Dialog-Frame = string( false  )
   TOG-30:screen-value in frame Dialog-Frame = string( false  )
   TOG-31:screen-value  in frame Dialog-Frame = string( false  )
   TOG-32:screen-value  in frame Dialog-Frame = string( false  )
   TOG-33:screen-value  in frame Dialog-Frame = string( false  )
   TOG-34:screen-value  in frame Dialog-Frame = string( false  )
   TOG-35:screen-value  in frame Dialog-Frame = string( false  )
   TOG-36:screen-value  in frame Dialog-Frame = string( false  )
   TOG-37:screen-value  in frame Dialog-Frame = string( false  )
   TOG-38:screen-value  in frame Dialog-Frame = string( false  )
   TOG-39:screen-value  in frame Dialog-Frame = string( false  )
   TOG-40:screen-value in frame Dialog-Frame = string( false  )
   TOG-41:screen-value  in frame Dialog-Frame = string( false  )
   TOG-42:screen-value  in frame Dialog-Frame = string( false  )
   TOG-43:screen-value  in frame Dialog-Frame = string( false  )
   TOG-44:screen-value  in frame Dialog-Frame = string( false  )
   TOG-45:screen-value  in frame Dialog-Frame = string( false  )
   TOG-46:screen-value  in frame Dialog-Frame = string( false  )
   TOG-47:screen-value  in frame Dialog-Frame = string( false  )
   TOG-48:screen-value  in frame Dialog-Frame = string( false  )
   TOG-49:screen-value  in frame Dialog-Frame = string( false  )
   TOG-50:screen-value in frame Dialog-Frame = string( false  )
   TOG-51:screen-value  in frame Dialog-Frame = string( false  )
   TOG-52:screen-value  in frame Dialog-Frame = string( false  )
   TOG-53:screen-value  in frame Dialog-Frame = string( false  )
   TOG-54:screen-value  in frame Dialog-Frame = string( false  )
   TOG-55:screen-value  in frame Dialog-Frame = string( false  )
   TOG-56:screen-value  in frame Dialog-Frame = string( false  )
   TOG-57:screen-value  in frame Dialog-Frame = string( false  )
   TOG-58:screen-value  in frame Dialog-Frame = string( false  )
   TOG-59:screen-value  in frame Dialog-Frame = string( false  )
   TOG-60:screen-value in frame Dialog-Frame = string( false  )
   TOG-61:screen-value  in frame Dialog-Frame = string( false  )
   TOG-62:screen-value  in frame Dialog-Frame = string( false  )
   TOG-63:screen-value  in frame Dialog-Frame = string( false  )
   TOG-64:screen-value  in frame Dialog-Frame = string( false  )
   TOG-65:screen-value  in frame Dialog-Frame = string( false  )
   TOG-66:screen-value  in frame Dialog-Frame = string( false  )
   TOG-67:screen-value  in frame Dialog-Frame = string( false  )
   TOG-68:screen-value  in frame Dialog-Frame = string( false  )
   TOG-69:screen-value  in frame Dialog-Frame = string( false  )
   TOG-70:screen-value in frame Dialog-Frame = string( false  )
   TOG-71:screen-value  in frame Dialog-Frame = string( false  )
   TOG-72:screen-value  in frame Dialog-Frame = string( false  )
   TOG-73:screen-value  in frame Dialog-Frame = string( false  )
   TOG-74:screen-value  in frame Dialog-Frame = string( false  )
   TOG-75:screen-value  in frame Dialog-Frame = string( false  )
   TOG-76:screen-value  in frame Dialog-Frame = string( false  )
   TOG-77:screen-value  in frame Dialog-Frame = string( false  )
   TOG-78:screen-value  in frame Dialog-Frame = string( false  )
   TOG-79:screen-value  in frame Dialog-Frame = string( false  )
   TOG-80:screen-value in frame Dialog-Frame = string( false  )
   TOG-81:screen-value  in frame Dialog-Frame = string( false  )
   TOG-82:screen-value  in frame Dialog-Frame = string( false  )
   TOG-83:screen-value  in frame Dialog-Frame = string( false  )
   TOG-84:screen-value  in frame Dialog-Frame = string( false  )
   TOG-85:screen-value  in frame Dialog-Frame = string( false  )
   TOG-86:screen-value  in frame Dialog-Frame = string( false  )
   TOG-87:screen-value  in frame Dialog-Frame = string( false  )
   TOG-88:screen-value  in frame Dialog-Frame = string( false  )
   TOG-89:screen-value  in frame Dialog-Frame = string( false  )
   TOG-90:screen-value  in frame Dialog-Frame = string( false  )
   TOG-91:screen-value  in frame Dialog-Frame = string( false  )
   TOG-92:screen-value  in frame Dialog-Frame = string( false  )
   TOG-93:screen-value  in frame Dialog-Frame = string( false  )
   TOG-94:screen-value  in frame Dialog-Frame = string( false  )
   TOG-95:screen-value  in frame Dialog-Frame = string( false  )
   TOG-96:screen-value  in frame Dialog-Frame = string( false  )
  .
  Display
  A4-port
  with frame Dialog-Frame.
  hide
  only-text-exel
  only-file
  a4-lansc
  a3
  in frame Dialog-Frame.
END.
ON MOUSE-SELECT-CLICK OF RECT-18 IN FRAME Dialog-Frame
DO:
END.
ON VALUE-CHANGED OF TOG-1,  TOG-2,  TOG-3 , TOG-4,  TOG-5,  TOG-6,  TOG-7,  TOG-8,  TOG-9,  TOG-10, TOG-11, TOG-12, TOG-13 ,TOG-14, TOG-15, TOG-16, TOG-17, TOG-18, TOG-19, TOG-20, TOG-21, TOG-22, TOG-23 ,TOG-24, TOG-25, TOG-26, TOG-27, TOG-28, TOG-29, TOG-30, TOG-31, TOG-32, TOG-33 ,TOG-34, TOG-35, TOG-36, TOG-37, TOG-38, TOG-39, TOG-40, TOG-41, TOG-42, TOG-43 ,TOG-44, TOG-45, TOG-46, TOG-47, TOG-48, TOG-49, TOG-50, TOG-51, TOG-52, TOG-53 ,TOG-54, TOG-55, TOG-56, TOG-57, TOG-58, TOG-59, TOG-60, TOG-61, TOG-62, TOG-63 ,TOG-64, TOG-65, TOG-66, TOG-67, TOG-68, TOG-69, TOG-70, TOG-71, TOG-72, TOG-73 ,TOG-74, TOG-75, TOG-76, TOG-77, TOG-78, TOG-79, TOG-80, TOG-81, TOG-82, TOG-83 ,TOG-84, TOG-85, TOG-86, TOG-87, TOG-88
    IN FRAME Dialog-Frame
DO:
  RUN Show-format.
END.
ON MOUSE-SELECT-CLICK OF RECT-19 IN FRAME Dialog-Frame
DO:
END.
ON VALUE-CHANGED OF TOG-1,  TOG-2,  TOG-3 , TOG-4,  TOG-5,  TOG-6,  TOG-7,  TOG-8,  TOG-9,  TOG-10, TOG-11, TOG-12, TOG-13 ,TOG-14, TOG-15, TOG-16, TOG-17, TOG-18, TOG-19, TOG-20, TOG-21, TOG-22, TOG-23 ,TOG-24, TOG-25, TOG-26, TOG-27, TOG-28, TOG-29, TOG-30, TOG-31, TOG-32, TOG-33 ,TOG-34, TOG-35, TOG-36, TOG-37, TOG-38, TOG-39, TOG-40, TOG-41, TOG-42, TOG-43 ,TOG-44, TOG-45, TOG-46, TOG-47, TOG-48, TOG-49, TOG-50, TOG-51, TOG-52, TOG-53 ,TOG-54, TOG-55, TOG-56, TOG-57, TOG-58, TOG-59, TOG-60, TOG-61, TOG-62, TOG-63 ,TOG-64, TOG-65, TOG-66, TOG-67, TOG-68, TOG-69, TOG-70, TOG-71, TOG-72, TOG-73 ,TOG-74, TOG-75, TOG-76, TOG-77, TOG-78, TOG-79, TOG-80, TOG-81, TOG-82, TOG-83 ,TOG-84, TOG-85, TOG-86, TOG-87, TOG-88
    IN FRAME Dialog-Frame
DO:
  RUN Show-format.
END.
ON MOUSE-SELECT-CLICK OF RECT-21 IN FRAME Dialog-Frame
DO:
END.
ON VALUE-CHANGED OF TOG-1,  TOG-2,  TOG-3 , TOG-4,  TOG-5,  TOG-6,  TOG-7,  TOG-8,  TOG-9,  TOG-10, TOG-11, TOG-12, TOG-13 ,TOG-14, TOG-15, TOG-16, TOG-17, TOG-18, TOG-19, TOG-20, TOG-21, TOG-22, TOG-23 ,TOG-24, TOG-25, TOG-26, TOG-27, TOG-28, TOG-29, TOG-30, TOG-31, TOG-32, TOG-33 ,TOG-34, TOG-35, TOG-36, TOG-37, TOG-38, TOG-39, TOG-40, TOG-41, TOG-42, TOG-43 ,TOG-44, TOG-45, TOG-46, TOG-47, TOG-48, TOG-49, TOG-50, TOG-51, TOG-52, TOG-53 ,TOG-54, TOG-55, TOG-56, TOG-57, TOG-58, TOG-59, TOG-60, TOG-61, TOG-62, TOG-63 ,TOG-64, TOG-65, TOG-66, TOG-67, TOG-68, TOG-69, TOG-70, TOG-71, TOG-72, TOG-73 ,TOG-74, TOG-75, TOG-76, TOG-77, TOG-78, TOG-79, TOG-80, TOG-81, TOG-82, TOG-83 ,TOG-84, TOG-85, TOG-86, TOG-87, TOG-88
    IN FRAME Dialog-Frame
DO:
  RUN Show-format.
END.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame Dialog-Frame
do:
  run gbl/app_help.p
    (input this-procedure :file-name
    ,input ''
    ,input ?
    ) no-error.
  if error-status :error then do:
    message
      "Ошибка при вызове помощи"
      error-status :get-message(1)
      view-as alert-box .
  end.
end.
run minbtn-set in this-procedure .
on choose of b-help in frame Dialog-Frame
do:
  apply "help":u to frame Dialog-Frame .
end.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure minbtn-set :
    do
        on error undo, return error return-value
        :
        define variable ii              as integer       no-undo .
        define variable fh              as widget-handle no-undo .
        define variable hh              as widget-handle no-undo .
        define variable v-h             as handle        extent 4 no-undo .
        define variable v-name-button   as character     no-undo .
        define variable v-help-old-x    as decimal       no-undo .
        define variable v-help-old-y    as decimal       no-undo .
        define variable v-help-old-size as decimal       no-undo .
        define variable v-frame-width   as decimal       no-undo .
        define variable jj              as integer       no-undo .
        do
            on error undo, return error
            :
            assign
                v-frame-width = frame Dialog-Frame:width - 0.3
                fh            = frame Dialog-Frame:first-child
                hh            = fh:first-child
                ii            = 1
                .
            do while valid-handle(hh):
                if LOOKUP(lc(hh:name), "b-help,b-print,b-history,b-hist,b-hist-user,b-sch") > 0  then
                do:
                    case lc(hh:name) :
                        when "b-help" then
                            do:
                                hh:load-image-up("cmp/b-help.bmp":u) .
                                hh:load-image-down("cmp/b-help.bmp":u) .
                                hh:load-image-insensitive("cmp/b-help.bmp":u) .
                                hh:TOOLTIP = "Помощь" .
                                v-help-old-x = hh:column .
                                v-help-old-y = hh:row    .
                                v-help-old-size = hh:width .
                                hh:width-chars = 2.5 .
                            end.
                        when "b-print" then
                            do:
                                hh:load-image("cmp/b-print.bmp":u) .
                                hh:TOOLTIP = "Печать" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-history" or
                        when "b-hist" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-sch" then
                            do:
                                hh:load-image("cmp/b-sch.bmp":u) .
                                hh:TOOLTIP = "Установка Фильтра" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-hist-user" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История пользователя" .
                                ii = ii + 1 .
                            end.
                    end case.
                end.
                hh = hh:next-sibling.
            end.
            b-help:column = v-frame-width - b-help:width-chars.
            jj = 0.
            repeat ii = 4 to 1 by -1 :
                if valid-handle (v-h[ii] ) then
                do:
                    jj  = jj + 1 .
                    v-h[ii]:column = v-frame-width - b-help:width-chars - ( 3 * jj ).
                    v-h[ii]:row    = v-help-old-y .
                end.
            end.
        end.
    end.
end procedure.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable  all-empty  as integer no-undo init 0 .
define variable  ii  as integer no-undo init 0 .
if prod-zen = no then RADIO-SET-2 = 2 .
else RADIO-SET-2 = 1 .
repeat ii = 1 to 120 :
  if use-column[ii ] then all-empty  = all-empty + 1 .
End.
 if all-empty =0 then
    apply "CHOOSE" TO B-mark IN FRAME Dialog-Frame.
 Else
 Assign
    TOG-1  = use-column[1 ]
    TOG-2  = use-column[2 ]
    TOG-3  = use-column[3 ]
    TOG-4  = use-column[4 ]
    TOG-5  = use-column[5 ]
    TOG-6  = use-column[6 ]
    TOG-7  = use-column[7 ]
    TOG-8  = use-column[8 ]
    TOG-9  = use-column[9 ]
    TOG-10 = use-column[10]
    TOG-11 = use-column[11]
    TOG-12 = use-column[12]
    TOG-13 = use-column[13]
    TOG-14 = use-column[14]
    TOG-15 = use-column[15]
    TOG-16 = use-column[16]
    TOG-17 = use-column[17]
    TOG-18 = use-column[18]
    TOG-19 = use-column[19]
    TOG-20 = use-column[20]
    TOG-21 = use-column[21]
    TOG-22 = use-column[22]
    TOG-23 = use-column[23]
    TOG-24 = use-column[24]
    TOG-25 = use-column[25]
    TOG-26 = use-column[26]
    TOG-27 = use-column[27]
    TOG-28 = use-column[28]
    TOG-29 = use-column[29]
    TOG-30 = use-column[30]
    TOG-31 = use-column[31]
    TOG-32 = use-column[32]
    TOG-33 = use-column[33]
    TOG-34 = use-column[34]
    TOG-35 = use-column[35]
    TOG-36 = use-column[36]
    TOG-37 = use-column[37]
    TOG-38 = use-column[38]
    TOG-39 = use-column[39]
    TOG-40 = use-column[40]
    TOG-41 = use-column[41]
    TOG-42 = use-column[42]
    TOG-43 = use-column[43]
    TOG-44 = use-column[44]
    TOG-45 = use-column[45]
    TOG-46 = use-column[46]
    TOG-47 = use-column[47]
    TOG-48 = use-column[48]
    TOG-49 = use-column[49]
    TOG-50 = use-column[50]
    TOG-51 = use-column[51]
    TOG-52 = use-column[52]
    TOG-53 = use-column[53]
    TOG-54 = use-column[54]
    TOG-55 = use-column[55]
    TOG-56 = use-column[56]
    TOG-57 = use-column[57]
    TOG-58 = use-column[58]
    TOG-59 = use-column[59]
    TOG-60 = use-column[60]
    TOG-61 = use-column[61]
    TOG-62 = use-column[62]
    TOG-63 = use-column[63]
    TOG-64 = use-column[64]
    TOG-65 = use-column[65]
    TOG-66 = use-column[66]
    TOG-67 = use-column[67]
    TOG-68 = use-column[68]
    TOG-69 = use-column[69]
    TOG-70 = use-column[70]
    TOG-71 = use-column[71]
    TOG-72 = use-column[72]
    TOG-73 = use-column[73]
    TOG-74 = use-column[74]
    TOG-75 = use-column[75]
    TOG-76 = use-column[76]
    TOG-77 = use-column[77]
    TOG-78 = use-column[78]
    TOG-79 = use-column[79]
    TOG-80 = use-column[80]
    TOG-81 = use-column[81]
    TOG-82 = use-column[82]
    TOG-83 = use-column[83]
    TOG-84 = use-column[84]
    TOG-85 = use-column[85]
    TOG-86 = use-column[86]
    TOG-87 = use-column[87]
    TOG-88 = use-column[88]
    TOG-89 = use-column[89]
    TOG-90 = use-column[90]
    TOG-91 = use-column[91]
    TOG-92 = use-column[92]
    TOG-93 = use-column[93]
    TOG-94 = use-column[94]
    TOG-95 = use-column[95]
    TOG-96 = use-column[96]
  .
  Assign
  s-column[1 ] =  9
  s-column[2 ] =  16
  s-column[3 ] =  38
  s-column[4 ] =  3
  s-column[5 ] =  10
  s-column[6 ] =  10
  s-column[7 ] =  10
  s-column[8 ] =  10
  s-column[9 ] =  10
  s-column[10] =  14
  s-column[11] =  10
  s-column[12] =  14
  s-column[13] =  14
  s-column[14] =  14
  s-column[15] =  14
  s-column[16] =  14
  s-column[17] =  14
  s-column[18] =  14
  s-column[19] =  14
  s-column[20] =  14
  s-column[21] =  14
  s-column[22] =  14
  s-column[23] =  14
  s-column[24] =  14
  s-column[25] =  14
  s-column[26] =  14
  s-column[27] =  14
  s-column[28] =  14
  s-column[29] =  14
  s-column[30] =  14
  s-column[31] =  14
  s-column[32] =  14
  s-column[33] =  14
  s-column[34] =  14
  s-column[35] =  14
  s-column[36] =  14
  s-column[37] =  14
  s-column[38] =  14
  s-column[39] =  14
  s-column[40] =  14
  s-column[41] =  14
  s-column[42] =  14
  s-column[43] =  14
  s-column[44] =  14
  s-column[45] =  14
  s-column[46] =  14
  s-column[47] =  14
  s-column[48] =  14
  s-column[49] =  14
  s-column[50] =  14
  s-column[51] =  14
  s-column[52] =  14
  s-column[53] =  14
  s-column[54] =  14
  s-column[55] =  14
  s-column[56] =  14
  s-column[57] =  14
  s-column[58] =  14
  s-column[59] =  14
  s-column[60] =  14
  s-column[61] =  14
  s-column[62] =  14
  s-column[63] =  14
  s-column[64] =  14
  s-column[65] =  14
  s-column[66] =  14
  s-column[67] =  14
  s-column[68] =  14
  s-column[69] =  14
  s-column[70] =  14
  s-column[71] =  14
  s-column[72] =  14
  s-column[73] =  14
  s-column[74] =  14
  s-column[75] =  14
  s-column[76] =  14
  s-column[77] =  14
  s-column[78] =  14
  s-column[79] =  14
  s-column[80] =  14
  s-column[81] =  14
  s-column[82] =  14
  s-column[83] =  14
  s-column[84] =  14
  s-column[85] =  14
  s-column[86] =  14
  s-column[87] =  14
  s-column[88] =  14
  s-column[89] =  14
  s-column[90] =  14
  s-column[91] =  14
  s-column[92] =  14
  s-column[93] =  14
  s-column[94] =  14
  s-column[95] =  14
  s-column[96] =  14
  s-column[97] =  14
  s-column[98] =  14
  s-column[99] =  14
  s-column[100] =  14
    s-column[101] =  14
    s-column[102] =  14
    s-column[103] =  14
    s-column[104] =  14
    s-column[105] =  14
    s-column[106] =  14
    s-column[107] =  14
    s-column[108] =  14
    s-column[109] =  14
    s-column[110] =  14
    s-column[111] =  14
    s-column[112] =  14
    s-column[113] =  14
    s-column[114] =  14
    s-column[115] =  14
    s-column[116] =  14
    s-column[117] =  14
    s-column[118] =  14
    s-column[119] =  14
    s-column[120] =  14
  .
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN enable_UI.
  define variable Log-Res1 as logical   no-undo .
  define variable Log-Res2 as logical   no-undo .
define variable vss-include-info15 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_reports_lookup-cost':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  yes
    ,output Log-Res1
    )  .
end.
  if not Log-Res1 then do:
    DISABLE
      TOG-31 TOG-32 TOG-33 TOG-34 TOG-35 TOG-36 TOG-37 TOG-38 TOG-39 TOG-40 TOG-41
      TOG-42 TOG-43 TOG-44 TOG-45 TOG-46 TOG-47 TOG-48 TOG-49 TOG-87 TOG-90 TOG-93
      TOG-68 TOG-69 TOG-70 TOG-71 TOG-72 TOG-73 TOG-74 TOG-75 TOG-76 TOG-77 TOG-78 TOG-79
      TOG-80 TOG-81 TOG-82 TOG-83 TOG-84 TOG-85 TOG-95 TOG-96
    WITH FRAME Dialog-Frame.
  end.
define variable vss-include-info16 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_reports_lookup-crsa':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  yes
    ,output Log-Res2
    )  .
end.
  if not Log-Res2 then do:
    DISABLE
      TOG-31 TOG-32 TOG-33 TOG-34 TOG-35 TOG-36 TOG-37 TOG-38 TOG-39 TOG-40 TOG-41
      TOG-42 TOG-43 TOG-44 TOG-45 TOG-46 TOG-47 TOG-48 TOG-49 TOG-87 TOG-90 TOG-93
      TOG-68 TOG-69 TOG-70 TOG-71 TOG-72 TOG-73 TOG-74 TOG-75 TOG-76 TOG-77 TOG-78 TOG-79
      TOG-80 TOG-81 TOG-82 TOG-83 TOG-84 TOG-85 TOG-95 TOG-96
    WITH FRAME Dialog-Frame.
  end.
  if p-type = 1 then do:
     disable tog-89 tog-90 tog-91 tog-92 tog-93 tog-94 tog-95 tog-96 with frame Dialog-Frame.
  end.
  if p-type = 3  then do:
     disable tog-89 tog-90 tog-91 tog-92 tog-93 tog-94 tog-95 tog-96 radio-set-2 with frame Dialog-Frame.
  end.
  RUN Show-format.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY TOG-1 TOG-12 TOG-31 TOG-50 TOG-2 TOG-13 TOG-51 TOG-32 TOG-3 TOG-89
          TOG-90 TOG-91 TOG-4 TOG-92 TOG-93 TOG-94 TOG-95 TOG-96 TOG-5 TOG-6
          TOG-14 TOG-33 RADIO-SET-2 TOG-15 TOG-34 TOG-7 TOG-16 TOG-35 TOG-52
          TOG-68 TOG-77 TOG-8 TOG-17 TOG-36 TOG-53 TOG-69 TOG-78 TOG-9 TOG-18
          TOG-37 TOG-54 TOG-70 TOG-79 TOG-10 TOG-19 TOG-55 TOG-71 TOG-80 TOG-38
          TOG-11 TOG-20 TOG-56 TOG-72 TOG-82 TOG-39 TOG-73 TOG-21 TOG-40 TOG-57
          TOG-81 TOG-58 TOG-74 TOG-83 TOG-22 TOG-41 TOG-42 TOG-59 TOG-75 TOG-84
          TOG-23 TOG-24 TOG-60 TOG-76 TOG-85 TOG-43 TOG-25 TOG-61 TOG-44 TOG-26
          TOG-45 TOG-62 TOG-46 TOG-27 TOG-63 TOG-47 TOG-28 TOG-64 TOG-48 TOG-29
          TOG-65 TOG-30 TOG-66 TOG-49 only-text-exel TOG-86 TOG-87 TOG-88 TOG-67
          FILL-IN-40 FILL-IN-43 FILL-IN-44 FILL-IN-39 FILL-IN-47 FILL-IN-41
          FILL-IN-42 FILL-IN-45 FILL-IN-46 FILL-IN-2 FILL-IN-25 FILL-IN-3
          FILL-IN-26 FILL-IN-4 FILL-IN-27 FILL-IN-52 FILL-IN-28 FILL-IN-53
          FILL-IN-32 FILL-IN-5 FILL-IN-48 FILL-IN-6 FILL-IN-7 FILL-IN-50
          FILL-IN-8 FILL-IN-29 FILL-IN-9 FILL-IN-49 FILL-IN-10 FILL-IN-30
          FILL-IN-11 FILL-IN-31 FILL-IN-12 FILL-IN-13 FILL-IN-14 FILL-IN-15
          FILL-IN-16 FILL-IN-17 FILL-IN-18 FILL-IN-19 FILL-IN-20 FILL-IN-21
          FILL-IN-51 F-col-size FILL-IN-22 FILL-IN-23 a3 A4-port a4-lansc
          only-file FILL-IN-24
      WITH FRAME Dialog-Frame.
  ENABLE B-quit B-exit B-mark B-unmark B-help RECT-21 RECT-18 RECT-19 RECT-20
         TOG-1 TOG-12 TOG-31 TOG-50 TOG-2 TOG-13 TOG-51 TOG-32 TOG-3 TOG-89
         TOG-90 TOG-91 TOG-4 TOG-92 TOG-93 TOG-94 TOG-95 TOG-96 TOG-5 TOG-6
         TOG-14 TOG-33 RADIO-SET-2 TOG-15 TOG-34 TOG-7 TOG-16 TOG-35 TOG-52
         TOG-68 TOG-77 TOG-8 TOG-17 TOG-36 TOG-53 TOG-69 TOG-78 TOG-9 TOG-18
         TOG-37 TOG-54 TOG-70 TOG-79 TOG-10 TOG-19 TOG-55 TOG-71 TOG-80 TOG-38
         TOG-11 TOG-20 TOG-56 TOG-72 TOG-82 TOG-39 TOG-73 TOG-21 TOG-40 TOG-57
         TOG-81 TOG-58 TOG-74 TOG-83 TOG-22 TOG-41 TOG-42 TOG-59 TOG-75 TOG-84
         TOG-23 TOG-24 TOG-60 TOG-76 TOG-85 TOG-43 TOG-25 TOG-61 TOG-44 TOG-26
         TOG-45 TOG-62 TOG-46 TOG-27 TOG-63 TOG-47 TOG-28 TOG-64 TOG-48 TOG-29
         TOG-65 TOG-30 TOG-66 TOG-49 only-text-exel TOG-86 TOG-87 TOG-88 TOG-67
         A-3 FILL-IN-40 FILL-IN-43 FILL-IN-44 FILL-IN-39 FILL-IN-47 FILL-IN-41
         FILL-IN-42 FILL-IN-45 FILL-IN-46 FILL-IN-2 FILL-IN-25 FILL-IN-3
         FILL-IN-26 FILL-IN-4 FILL-IN-27 FILL-IN-52 FILL-IN-28 FILL-IN-53
         FILL-IN-32 FILL-IN-5 FILL-IN-48 FILL-IN-6 FILL-IN-7 FILL-IN-50
         FILL-IN-8 FILL-IN-29 FILL-IN-9 FILL-IN-49 FILL-IN-10 FILL-IN-30
         FILL-IN-11 FILL-IN-31 FILL-IN-12 FILL-IN-13 FILL-IN-14 FILL-IN-15
         FILL-IN-16 FILL-IN-17 FILL-IN-18 FILL-IN-19 FILL-IN-20 FILL-IN-21
         FILL-IN-51 F-col-size FILL-IN-22 FILL-IN-23 a3 A4-port a4-lansc
         only-file FILL-IN-24
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE Show-format :
define variable ij as integer no-undo .
  run eq-frame.
  col-size = 0.
  repeat ij = 1 to 120 :
    if use-column[ij] then col-size = col-size + s-column[ij] + 1 .
  End.
  F-col-size:screen-value in frame Dialog-Frame = string( col-size).
  F-col-size = string(col-size).
  Display F-col-size with frame Dialog-Frame.
  If col-size >= 1 and col-size <= 136 Then DO:
    Display A4-port a-3  with frame Dialog-Frame.
    Hide a4-lansc a3 only-file only-text-exel in frame Dialog-Frame.
    print-o = "A4-port":U.
  End.
  If col-size > 136 and col-size <= 198 Then DO:
    Display  a4-lansc a-3  with frame Dialog-Frame.
    Hide A4-port a3 only-file only-text-exel in frame Dialog-Frame.
    print-o = "A4-lansc":U.
  End.
  If col-size > 198 and col-size <= 235 Then DO:
    Display a3 a-3  with frame Dialog-Frame.
    Hide A4-port a4-lansc only-text-exel  only-file in frame Dialog-Frame.
    print-o = "A3-lansc":U.
  End.
  If col-size > 235 Then DO:
    Display only-file a-3 with frame Dialog-Frame.
    Hide A4-port a4-lansc a3 only-text-exel in frame Dialog-Frame.
    print-o = "to-file":U.
  End.
  If col-size > 550 Then DO:
    Display  only-text-exel  with frame Dialog-Frame.
    Hide only-file a-3 A4-port a4-lansc a3 in frame Dialog-Frame.
    print-o = "to-file":U.
  End.
END PROCEDURE.
procedure eq-frame:
  Assign frame Dialog-Frame  TOG-1 TOG-12 TOG-31 TOG-50 TOG-2 TOG-13 TOG-51 TOG-32 TOG-3 TOG-89 TOG-90 TOG-91 TOG-4 TOG-92 TOG-93 TOG-94 TOG-95 TOG-96 TOG-5 TOG-6 TOG-14 TOG-33 TOG-15 TOG-34 TOG-7 TOG-16 TOG-35 TOG-52 TOG-68 TOG-77 TOG-8 TOG-17 TOG-36 TOG-53 TOG-69 TOG-78 TOG-9 TOG-18 TOG-37 TOG-54 TOG-70 TOG-79 TOG-10 TOG-19 TOG-55 TOG-71 TOG-80 TOG-38 TOG-11 TOG-20 TOG-56 TOG-72 TOG-82 TOG-39 TOG-73 TOG-21 TOG-40 TOG-57 TOG-81 TOG-58 TOG-74 TOG-83 TOG-22 TOG-41 TOG-42 TOG-59 TOG-75 TOG-84 TOG-23 TOG-24 TOG-60 TOG-76 TOG-85 TOG-43 TOG-25 TOG-61 TOG-44 TOG-26 TOG-45 TOG-62 TOG-46 TOG-27 TOG-63 TOG-47 TOG-28 TOG-64 TOG-48 TOG-29 TOG-65 TOG-30 TOG-66 TOG-49 TOG-86 TOG-87 TOG-88 TOG-67 .
  Assign RADIO-SET-2.
  if RADIO-SET-2 = 1 then prod-zen = yes .
  else prod-zen = no .
  Assign
  use-column[1 ] =  TOG-1
  use-column[2 ] =  TOG-2
  use-column[3 ] =  TOG-3
  use-column[4 ] =  TOG-4
  use-column[5 ] =  TOG-5
  use-column[6 ] =  TOG-6
  use-column[7 ] =  TOG-7
  use-column[8 ] =  TOG-8
  use-column[9 ] =  TOG-9
  use-column[10] =  TOG-10
  use-column[11] =  TOG-11
  use-column[12] =  TOG-12
  use-column[13] =  TOG-13
  use-column[14] =  TOG-14
  use-column[15] =  TOG-15
  use-column[16] =  TOG-16
  use-column[17] =  TOG-17
  use-column[18] =  TOG-18
  use-column[19] =  TOG-19
  use-column[20] =  TOG-20
  use-column[21] =  TOG-21
  use-column[22] =  TOG-22
  use-column[23] =  TOG-23
  use-column[24] =  TOG-24
  use-column[25] =  TOG-25
  use-column[26] =  TOG-26
  use-column[27] =  TOG-27
  use-column[28] =  TOG-28
  use-column[29] =  TOG-29
  use-column[30] =  TOG-30
  use-column[31] =  TOG-31
  use-column[32] =  TOG-32
  use-column[33] =  TOG-33
  use-column[34] =  TOG-34
  use-column[35] =  TOG-35
  use-column[36] =  TOG-36
  use-column[37] =  TOG-37
  use-column[38] =  TOG-38
  use-column[39] =  TOG-39
  use-column[40] =  TOG-40
  use-column[41] =  TOG-41
  use-column[42] =  TOG-42
  use-column[43] =  TOG-43
  use-column[44] =  TOG-44
  use-column[45] =  TOG-45
  use-column[46] =  TOG-46
  use-column[47] =  TOG-47
  use-column[48] =  TOG-48
  use-column[49] =  TOG-49
  use-column[50] =  TOG-50
  use-column[51] =  TOG-51
  use-column[52] =  TOG-52
  use-column[53] =  TOG-53
  use-column[54] =  TOG-54
  use-column[55] =  TOG-55
  use-column[56] =  TOG-56
  use-column[57] =  TOG-57
  use-column[58] =  TOG-58
  use-column[59] =  TOG-59
  use-column[60] =  TOG-60
  use-column[61] =  TOG-61
  use-column[62] =  TOG-62
  use-column[63] =  TOG-63
  use-column[64] =  TOG-64
  use-column[65] =  TOG-65
  use-column[66] =  TOG-66
  use-column[67] =  TOG-67
  use-column[68] =  TOG-68
  use-column[69] =  TOG-69
  use-column[70] =  TOG-70
  use-column[71] =  TOG-71
  use-column[72] =  TOG-72
  use-column[73] =  TOG-73
  use-column[74] =  TOG-74
  use-column[75] =  TOG-75
  use-column[76] =  TOG-76
  use-column[77] =  TOG-77
  use-column[78] =  TOG-78
  use-column[79] =  TOG-79
  use-column[80] =  TOG-80
  use-column[81] =  TOG-81
  use-column[82] =  TOG-82
  use-column[83] =  TOG-83
  use-column[84] =  TOG-84
  use-column[85] =  TOG-85
  use-column[86] =  TOG-86
  use-column[87] =  TOG-87
  use-column[88] =  TOG-88
  use-column[89] =  TOG-89
  use-column[90] =  TOG-90
  use-column[91] =  TOG-91
  use-column[92] =  TOG-92
  use-column[93] =  TOG-93
  use-column[94] =  TOG-94
  use-column[95] =  TOG-95
  use-column[96] =  TOG-96
  .
end procedure.
