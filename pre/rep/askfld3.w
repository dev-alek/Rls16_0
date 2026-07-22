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
     SIZE 27.38 BY 1.83
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
DEFINE VARIABLE FILL-IN-100 AS CHARACTER FORMAT "X(256)":U INITIAL "НДС производителя, %"
      VIEW-AS TEXT
     SIZE 29 BY .67 NO-UNDO.
DEFINE VARIABLE FILL-IN-101 AS CHARACTER FORMAT "X(256)":U INITIAL "Цена поставщика без НДС"
      VIEW-AS TEXT
     SIZE 29 BY .67 NO-UNDO.
DEFINE VARIABLE FILL-IN-102 AS CHARACTER FORMAT "X(256)":U INITIAL "Цена поставщика с НДС"
      VIEW-AS TEXT
     SIZE 29 BY .67 NO-UNDO.
DEFINE VARIABLE FILL-IN-103 AS CHARACTER FORMAT "X(256)":U INITIAL "НДС поставщика, сумма"
      VIEW-AS TEXT
     SIZE 29 BY .67 NO-UNDO.
DEFINE VARIABLE FILL-IN-104 AS CHARACTER FORMAT "X(256)":U INITIAL "НДС поставщика, %"
      VIEW-AS TEXT
     SIZE 29 BY .67 NO-UNDO.
DEFINE VARIABLE FILL-IN-105 AS CHARACTER FORMAT "X(256)":U INITIAL "Размер оптовой надбавки, сумма"
      VIEW-AS TEXT
     SIZE 31.5 BY .67 NO-UNDO.
DEFINE VARIABLE FILL-IN-106 AS CHARACTER FORMAT "X(256)":U INITIAL "Размер оптовой надбавки, %"
      VIEW-AS TEXT
     SIZE 31.5 BY .67 NO-UNDO.
DEFINE VARIABLE FILL-IN-107 AS CHARACTER FORMAT "X(256)":U INITIAL "Розничная цена партии с НДС"
      VIEW-AS TEXT
     SIZE 31.5 BY .67 NO-UNDO.
DEFINE VARIABLE FILL-IN-108 AS CHARACTER FORMAT "X(256)":U INITIAL "Розничная цена без НДС"
      VIEW-AS TEXT
     SIZE 31.5 BY .67 NO-UNDO.
DEFINE VARIABLE FILL-IN-109 AS CHARACTER FORMAT "X(256)":U INITIAL "Сумма НДС"
      VIEW-AS TEXT
     SIZE 31.5 BY .67 NO-UNDO.
DEFINE VARIABLE FILL-IN-110 AS CHARACTER FORMAT "X(256)":U INITIAL "Ставка НДС, %"
      VIEW-AS TEXT
     SIZE 31.5 BY .67 NO-UNDO.
DEFINE VARIABLE FILL-IN-111 AS CHARACTER FORMAT "X(256)":U INITIAL "Размер розничной надбавки (от цен без НДС), сумма"
      VIEW-AS TEXT
     SIZE 51.5 BY .67 NO-UNDO.
DEFINE VARIABLE FILL-IN-112 AS CHARACTER FORMAT "X(256)":U INITIAL "Размер розничной надбавки (от цен без НДС), %"
      VIEW-AS TEXT
     SIZE 51.5 BY .67 NO-UNDO.
DEFINE VARIABLE FILL-IN-113 AS CHARACTER FORMAT "X(256)":U INITIAL "Размер общей надбавки (от цен без НДС), сумма"
      VIEW-AS TEXT
     SIZE 51.5 BY .67 NO-UNDO.
DEFINE VARIABLE FILL-IN-114 AS CHARACTER FORMAT "X(256)":U INITIAL "Размер общей надбавки (от цен без НДС), %"
      VIEW-AS TEXT
     SIZE 51.5 BY .67 NO-UNDO.
DEFINE VARIABLE FILL-IN-115 AS CHARACTER FORMAT "X(256)":U INITIAL "Размер розничной надбавки (от цен с НДС), сумма"
      VIEW-AS TEXT
     SIZE 51.5 BY .67 NO-UNDO.
DEFINE VARIABLE FILL-IN-116 AS CHARACTER FORMAT "X(256)":U INITIAL "Размер розничной надбавки (от цен с НДС), %"
      VIEW-AS TEXT
     SIZE 52 BY .67 NO-UNDO.
DEFINE VARIABLE FILL-IN-117 AS CHARACTER FORMAT "X(256)":U INITIAL "Размер общей надбавки (от цен с НДС), сумма"
      VIEW-AS TEXT
     SIZE 52 BY .67 NO-UNDO.
DEFINE VARIABLE FILL-IN-118 AS CHARACTER FORMAT "X(256)":U INITIAL "Размер общей надбавки (от цен с НДС), %"
      VIEW-AS TEXT
     SIZE 51.5 BY .67 NO-UNDO.
DEFINE VARIABLE FILL-IN-51 AS CHARACTER FORMAT "X(256)" INITIAL "  Формат вывода на печать  "
      VIEW-AS TEXT
     SIZE 27 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE FILL-IN-97 AS CHARACTER FORMAT "X(256)":U INITIAL "Цена производителя без НДС"
      VIEW-AS TEXT
     SIZE 29 BY .67 NO-UNDO.
DEFINE VARIABLE FILL-IN-98 AS CHARACTER FORMAT "X(256)":U INITIAL "Цена производителя с НДС"
      VIEW-AS TEXT
     SIZE 29 BY .67 NO-UNDO.
DEFINE VARIABLE FILL-IN-99 AS CHARACTER FORMAT "X(256)":U INITIAL "НДС производителя, сумма"
      VIEW-AS TEXT
     SIZE 29 BY .67 NO-UNDO.
DEFINE VARIABLE only-file AS CHARACTER FORMAT "X(256)" INITIAL "  вывод в файл  "
      VIEW-AS TEXT
     SIZE 16 BY .67
     BGCOLOR 15 FGCOLOR 9  NO-UNDO.
DEFINE VARIABLE TOG-100 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .67 NO-UNDO.
DEFINE VARIABLE TOG-101 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .67 NO-UNDO.
DEFINE VARIABLE TOG-102 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .67 NO-UNDO.
DEFINE VARIABLE TOG-103 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .67 NO-UNDO.
DEFINE VARIABLE TOG-104 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .67 NO-UNDO.
DEFINE VARIABLE TOG-105 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .67 NO-UNDO.
DEFINE VARIABLE TOG-106 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .67 NO-UNDO.
DEFINE VARIABLE TOG-107 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .67 NO-UNDO.
DEFINE VARIABLE TOG-108 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .67 NO-UNDO.
DEFINE VARIABLE TOG-109 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .67 NO-UNDO.
DEFINE VARIABLE TOG-110 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .67 NO-UNDO.
DEFINE VARIABLE TOG-111 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .67 NO-UNDO.
DEFINE VARIABLE TOG-112 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .67 NO-UNDO.
DEFINE VARIABLE TOG-113 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .67 NO-UNDO.
DEFINE VARIABLE TOG-114 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .67 NO-UNDO.
DEFINE VARIABLE TOG-115 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .67 NO-UNDO.
DEFINE VARIABLE TOG-116 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .67 NO-UNDO.
DEFINE VARIABLE TOG-117 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .67 NO-UNDO.
DEFINE VARIABLE TOG-118 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .67 NO-UNDO.
DEFINE VARIABLE TOG-97 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .67 NO-UNDO.
DEFINE VARIABLE TOG-98 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .67 NO-UNDO.
DEFINE VARIABLE TOG-99 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .67 NO-UNDO.
DEFINE FRAME dialog-Frame
     B-quit AT ROW 1 COL 2.25
     B-exit AT ROW 1 COL 14.25
     B-mark AT ROW 1 COL 26.25
     B-unmark AT ROW 1 COL 38.13
     B-help AT ROW 1 COL 50.25
     TOG-97 AT ROW 2.75 COL 55.63 RIGHT-ALIGNED
     TOG-98 AT ROW 3.42 COL 55.63 RIGHT-ALIGNED WIDGET-ID 4
     TOG-99 AT ROW 4.29 COL 55.63 RIGHT-ALIGNED WIDGET-ID 18
     TOG-100 AT ROW 4.96 COL 55.63 RIGHT-ALIGNED WIDGET-ID 20
     TOG-101 AT ROW 5.96 COL 55.63 RIGHT-ALIGNED WIDGET-ID 24
     TOG-102 AT ROW 6.71 COL 55.63 RIGHT-ALIGNED WIDGET-ID 28
     TOG-103 AT ROW 7.79 COL 55.63 RIGHT-ALIGNED WIDGET-ID 32
     TOG-104 AT ROW 8.58 COL 55.63 RIGHT-ALIGNED WIDGET-ID 36
     TOG-105 AT ROW 9.63 COL 55.63 RIGHT-ALIGNED WIDGET-ID 40
     TOG-106 AT ROW 10.38 COL 55.63 RIGHT-ALIGNED WIDGET-ID 44
     TOG-107 AT ROW 11.33 COL 55.63 RIGHT-ALIGNED WIDGET-ID 48
     TOG-108 AT ROW 12.13 COL 55.63 RIGHT-ALIGNED WIDGET-ID 52
     TOG-109 AT ROW 13.08 COL 55.63 RIGHT-ALIGNED WIDGET-ID 56
     TOG-110 AT ROW 13.83 COL 55.63 RIGHT-ALIGNED WIDGET-ID 60
     TOG-111 AT ROW 14.75 COL 55.63 RIGHT-ALIGNED WIDGET-ID 66
     TOG-112 AT ROW 15.5 COL 55.63 RIGHT-ALIGNED WIDGET-ID 68
     TOG-113 AT ROW 16.5 COL 55.63 RIGHT-ALIGNED WIDGET-ID 74
     TOG-114 AT ROW 17.25 COL 55.63 RIGHT-ALIGNED WIDGET-ID 76
     TOG-115 AT ROW 18.25 COL 55.63 RIGHT-ALIGNED WIDGET-ID 102
     TOG-116 AT ROW 19 COL 55.63 RIGHT-ALIGNED WIDGET-ID 104
     TOG-117 AT ROW 20 COL 55.63 RIGHT-ALIGNED WIDGET-ID 106
     TOG-118 AT ROW 20.75 COL 55.63 RIGHT-ALIGNED WIDGET-ID 108
     only-text-exel AT ROW 22.92 COL 4.38 NO-LABEL
     A-3 AT ROW 24.54 COL 26.88
     FILL-IN-97 AT ROW 2.75 COL 1.5 NO-LABEL
     FILL-IN-98 AT ROW 3.38 COL 1.5 NO-LABEL WIDGET-ID 2
     FILL-IN-99 AT ROW 4.25 COL 1.5 NO-LABEL WIDGET-ID 14
     FILL-IN-100 AT ROW 4.88 COL 1.5 NO-LABEL WIDGET-ID 16
     FILL-IN-101 AT ROW 5.88 COL 1.5 NO-LABEL WIDGET-ID 22
     FILL-IN-102 AT ROW 6.63 COL 1.5 NO-LABEL WIDGET-ID 26
     FILL-IN-103 AT ROW 7.71 COL 1.5 NO-LABEL WIDGET-ID 30
     FILL-IN-104 AT ROW 8.5 COL 1.5 NO-LABEL WIDGET-ID 34
     FILL-IN-105 AT ROW 9.54 COL 1.5 NO-LABEL WIDGET-ID 38
     FILL-IN-106 AT ROW 10.29 COL 1.5 NO-LABEL WIDGET-ID 42
     FILL-IN-107 AT ROW 11.25 COL 1.5 NO-LABEL WIDGET-ID 46
     FILL-IN-108 AT ROW 12.04 COL 1.5 NO-LABEL WIDGET-ID 50
     FILL-IN-109 AT ROW 13 COL 1.5 NO-LABEL WIDGET-ID 54
     FILL-IN-110 AT ROW 13.75 COL 1.5 NO-LABEL WIDGET-ID 58
     FILL-IN-111 AT ROW 14.75 COL 1.5 NO-LABEL WIDGET-ID 62
     FILL-IN-112 AT ROW 15.5 COL 1.5 NO-LABEL WIDGET-ID 64
     FILL-IN-113 AT ROW 16.5 COL 1.5 NO-LABEL WIDGET-ID 70
     FILL-IN-114 AT ROW 17.25 COL 1.5 NO-LABEL WIDGET-ID 72
     FILL-IN-115 AT ROW 18.25 COL 1.5 NO-LABEL WIDGET-ID 94
     FILL-IN-116 AT ROW 19 COL 1.5 NO-LABEL WIDGET-ID 96
     FILL-IN-117 AT ROW 20 COL 1.5 NO-LABEL WIDGET-ID 98
     FILL-IN-118 AT ROW 20.75 COL 1.5 NO-LABEL WIDGET-ID 100
     FILL-IN-51 AT ROW 22 COL 4 NO-LABEL
     F-col-size AT ROW 22 COL 32 COLON-ALIGNED NO-LABEL
     a3 AT ROW 23.58 COL 12.5 COLON-ALIGNED NO-LABEL
     A4-port AT ROW 23.75 COL 15.38 COLON-ALIGNED NO-LABEL
     a4-lansc AT ROW 23.92 COL 13.88 COLON-ALIGNED NO-LABEL
     only-file AT ROW 24 COL 7.25 COLON-ALIGNED NO-LABEL
     "Показать":C8 VIEW-AS TEXT
          SIZE 8.88 BY .67 AT ROW 2 COL 51.5
          FGCOLOR 4
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         DEFAULT-BUTTON B-exit CANCEL-BUTTON B-quit.
DEFINE FRAME dialog-Frame
     "Колонки":C28 VIEW-AS TEXT
          SIZE 27.38 BY .67 AT ROW 2.08 COL 2.25
          FGCOLOR 4
     SPACE(32.24) SKIP(23.16)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Выбор колонок для печати партий по АПТЕКЕ"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON B-quit.
ASSIGN
       FRAME dialog-Frame:SCROLLABLE       = FALSE
       FRAME dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       A-3:HIDDEN IN FRAME dialog-Frame           = TRUE.
ASSIGN
       B-help:HIDDEN IN FRAME dialog-Frame           = TRUE.
ASSIGN
       B-unmark:HIDDEN IN FRAME dialog-Frame           = TRUE.
ASSIGN
       only-text-exel:READ-ONLY IN FRAME dialog-Frame        = TRUE.
ON WINDOW-CLOSE OF FRAME dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF A-3 IN FRAME dialog-Frame
DO:
  Display a3  with frame dialog-Frame.
  Hide  A4-port  a4-lansc  only-file  in frame dialog-Frame.
  print-o = "A3-lansc":U.
END.
ON CHOOSE OF B-exit IN FRAME dialog-Frame
DO:
  define variable l-ind as integer no-undo .
  run eq-frame.
 find first ubflt.usr-flt exclusive-lock
   where ubflt.usr-flt.user-name  = g#userid
     and ubflt.usr-flt.call-point = "e-obort3":U
   no-error .
    if not available ubflt.usr-flt then do:
      create ubflt.usr-flt.
      assign
      ubflt.usr-flt.user-name = g#userid
      ubflt.usr-flt.call-point   = "e-obort3":u
      ubflt.usr-flt.list_ = "" .
    end.
   repeat l-ind = 97 to 120 :
     if   use-column[ l-ind ] =  true then ubflt.usr-flt.list_ = ubflt.usr-flt.list_  + string( l-ind ) + "," .
   End.
   ubflt.usr-flt.list_ = ubflt.usr-flt.list_  + string( "print-o=" + print-o ) + ",prod-zen=" + string( prod-zen ) + "," .
END.
ON CHOOSE OF B-mark IN FRAME dialog-Frame
DO:
  Assign
     TOG-97:screen-value  in frame dialog-Frame = string( true )
     TOG-98:screen-value  in frame dialog-Frame = string( true )
     TOG-99:screen-value  in frame dialog-Frame = string( true )
    TOG-100:screen-value  in frame dialog-Frame = string( true )
    TOG-101:screen-value  in frame dialog-Frame = string( true )
    TOG-102:screen-value  in frame dialog-Frame = string( true )
    TOG-103:screen-value  in frame dialog-Frame = string( true )
    TOG-104:screen-value  in frame dialog-Frame = string( true )
    TOG-105:screen-value  in frame dialog-Frame = string( true )
    TOG-106:screen-value  in frame dialog-Frame = string( true )
    TOG-107:screen-value  in frame dialog-Frame = string( true )
    TOG-108:screen-value  in frame dialog-Frame = string( true )
    TOG-109:screen-value  in frame dialog-Frame = string( true )
    TOG-110:screen-value  in frame dialog-Frame = string( true )
    TOG-111:screen-value  in frame dialog-Frame = string( true )
    TOG-112:screen-value  in frame dialog-Frame = string( true )
    TOG-113:screen-value  in frame dialog-Frame = string( true )
    TOG-114:screen-value  in frame dialog-Frame = string( true )
    TOG-115:screen-value  in frame dialog-Frame = string( true )
    TOG-116:screen-value  in frame dialog-Frame = string( true )
    TOG-117:screen-value  in frame dialog-Frame = string( true )
    TOG-118:screen-value  in frame dialog-Frame = string( true )
    .
  Assign
     TOG-97 =  true
     TOG-98 =  true
     TOG-99 =  true
    TOG-100 =  true
    TOG-101 =  true
    TOG-102 =  true
    TOG-103 =  true
    TOG-104 =  true
    TOG-105 =  true
    TOG-106 =  true
    TOG-107 =  true
    TOG-108 =  true
    TOG-109 =  true
    TOG-110 =  true
    TOG-111 =  true
    TOG-112 =  true
    TOG-113 =  true
    TOG-114 =  true
    TOG-115 =  true
    TOG-116 =  true
    TOG-117 =  true
    TOG-118 =  true
  .
  Display
     only-text-exel
     with frame dialog-Frame.
  Hide
  only-file
  a-3
  A4-port
  a4-lansc
  a3
  in frame dialog-Frame.
  print-o = "to-file":U.
END.
ON CHOOSE OF B-unmark IN FRAME dialog-Frame
DO:
  Assign
    TOG-97:screen-value  in frame dialog-Frame = string( false  )
    TOG-98:screen-value  in frame dialog-Frame = string( false  )
    TOG-99:screen-value  in frame dialog-Frame = string( false  )
    TOG-100:screen-value  in frame dialog-Frame = string( false )
    TOG-101:screen-value  in frame dialog-Frame = string( false )
    TOG-102:screen-value  in frame dialog-Frame = string( false )
    TOG-103:screen-value  in frame dialog-Frame = string( false )
    TOG-104:screen-value  in frame dialog-Frame = string( false )
    TOG-105:screen-value  in frame dialog-Frame = string( false )
    TOG-106:screen-value  in frame dialog-Frame = string( false )
    TOG-107:screen-value  in frame dialog-Frame = string( false )
    TOG-108:screen-value  in frame dialog-Frame = string( false )
    TOG-109:screen-value  in frame dialog-Frame = string( false )
    TOG-110:screen-value  in frame dialog-Frame = string( false )
    TOG-111:screen-value  in frame dialog-Frame = string( false )
    TOG-112:screen-value  in frame dialog-Frame = string( false )
    TOG-113:screen-value  in frame dialog-Frame = string( false )
    TOG-114:screen-value  in frame dialog-Frame = string( false )
    TOG-115:screen-value  in frame dialog-Frame = string( false )
    TOG-116:screen-value  in frame dialog-Frame = string( false )
    TOG-117:screen-value  in frame dialog-Frame = string( false )
    TOG-118:screen-value  in frame dialog-Frame = string( false )
  .
  Display
  A4-port
  with frame dialog-Frame.
  hide
  only-text-exel
  only-file
  a4-lansc
  a3
  in frame dialog-Frame.
END.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame dialog-Frame
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
on choose of b-help in frame dialog-Frame
do:
  apply "help":u to frame dialog-Frame .
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
                v-frame-width = frame dialog-Frame:width - 0.3
                fh            = frame dialog-Frame:first-child
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
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME dialog-Frame:PARENT eq ?
THEN FRAME dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable  all-empty  as integer no-undo init 0 .
define variable  ii  as integer no-undo init 0 .
 find first ubflt.usr-flt no-lock
   where ubflt.usr-flt.user-name  = g#userid
     and ubflt.usr-flt.call-point = "e-obort3":U
   no-error .
 if NOT available ubflt.usr-flt then do:
    create ubflt.usr-flt.
    Assign
      ubflt.usr-flt.user-name = g#userid
      ubflt.usr-flt.call-point   = "e-obort3":U
      ubflt.usr-flt.list_ = "" .
 end.
  repeat ii = 97 to 120 :
    use-column[ii] = false  .
    all-empty = 0.
  end.
  repeat ii = 97 to 120 :
    if lookup( string(ii)  , ubflt.usr-flt.list_ ) > 0 then  do:
      use-column[ii] = true .
    end.
    if use-column[ii] then all-empty  = all-empty + 1 .
  end.
 if all-empty =0 then do:
    apply "CHOOSE" TO B-mark IN FRAME dialog-Frame.
 end.
 Else
 Assign
    TOG-97 = use-column[97]
    TOG-98 = use-column[98]
    TOG-99 = use-column[99]
    TOG-100 = use-column[100]
    TOG-101 = use-column[101]
    TOG-102 = use-column[102]
    TOG-103 = use-column[103]
    TOG-104 = use-column[104]
    TOG-105 = use-column[105]
    TOG-106 = use-column[106]
    TOG-107 = use-column[107]
    TOG-108 = use-column[108]
    TOG-109 = use-column[109]
    TOG-110 = use-column[110]
    TOG-111 = use-column[111]
    TOG-112 = use-column[112]
    TOG-113 = use-column[113]
    TOG-114 = use-column[114]
    TOG-115 = use-column[115]
    TOG-116 = use-column[116]
    TOG-117 = use-column[117]
    TOG-118 = use-column[118]
  .
  display
    TOG-97
    TOG-98
    TOG-99
    TOG-100
    TOG-101
    TOG-102
    TOG-103
    TOG-104
    TOG-105
    TOG-106
    TOG-107
    TOG-108
    TOG-109
    TOG-110
    TOG-111
    TOG-112
    TOG-113
    TOG-114
    TOG-115
    TOG-116
    TOG-117
    TOG-118
    with frame dialog-Frame
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
  end.
  enable  tog-97 tog-98 tog-99 tog-100
     TOG-101
     TOG-102
     TOG-103
     TOG-104
     TOG-105
     TOG-106
     TOG-107
     TOG-108
     TOG-109
     TOG-110
     TOG-111
     TOG-112
     TOG-113
     TOG-114
     TOG-115
     TOG-116
     TOG-117
     TOG-118
  with frame dialog-Frame.
  display  tog-97 tog-98 tog-99 tog-100
     TOG-101
     TOG-102
     TOG-103
     TOG-104
     TOG-105
     TOG-106
     TOG-107
     TOG-108
     TOG-109
     TOG-110
     TOG-111
     TOG-112
     TOG-113
     TOG-114
     TOG-115
     TOG-116
     TOG-117
     TOG-118
  with frame dialog-Frame.
  RUN Show-format.
  WAIT-FOR GO OF FRAME dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY TOG-97 TOG-98 TOG-99 TOG-100 TOG-101 TOG-102 TOG-103 TOG-104 TOG-105
          TOG-106 TOG-107 TOG-108 TOG-109 TOG-110 TOG-111 TOG-112 TOG-113
          TOG-114 TOG-115 TOG-116 TOG-117 TOG-118 only-text-exel FILL-IN-97
          FILL-IN-98 FILL-IN-99 FILL-IN-100 FILL-IN-101 FILL-IN-102 FILL-IN-103
          FILL-IN-104 FILL-IN-105 FILL-IN-106 FILL-IN-107 FILL-IN-108
          FILL-IN-109 FILL-IN-110 FILL-IN-111 FILL-IN-112 FILL-IN-113
          FILL-IN-114 FILL-IN-115 FILL-IN-116 FILL-IN-117 FILL-IN-118 FILL-IN-51
          F-col-size a3 A4-port a4-lansc only-file
      WITH FRAME dialog-Frame.
  ENABLE B-quit B-exit B-mark B-unmark B-help TOG-97 TOG-98 TOG-99 TOG-100
         TOG-101 TOG-102 TOG-103 TOG-104 TOG-105 TOG-106 TOG-107 TOG-108
         TOG-109 TOG-110 TOG-111 TOG-112 TOG-113 TOG-114 TOG-115 TOG-116
         TOG-117 TOG-118 only-text-exel A-3 FILL-IN-97 FILL-IN-98 FILL-IN-99
         FILL-IN-100 FILL-IN-101 FILL-IN-102 FILL-IN-103 FILL-IN-104
         FILL-IN-105 FILL-IN-106 FILL-IN-107 FILL-IN-108 FILL-IN-109
         FILL-IN-110 FILL-IN-111 FILL-IN-112 FILL-IN-113 FILL-IN-114
         FILL-IN-115 FILL-IN-116 FILL-IN-117 FILL-IN-118 FILL-IN-51 F-col-size
         a3 A4-port a4-lansc only-file
      WITH FRAME dialog-Frame.
  VIEW FRAME dialog-Frame.
END PROCEDURE.
PROCEDURE Show-format :
define variable ij as integer no-undo .
  run eq-frame.
  col-size = 0.
  repeat ij = 1 to 120 :
    if use-column[ij] then col-size = col-size + s-column[ij] + 1 .
  End.
  F-col-size:screen-value in frame dialog-Frame = string( col-size).
  F-col-size = string(col-size).
  Display F-col-size with frame dialog-Frame.
  If col-size >= 1 and col-size <= 136 Then DO:
    Display A4-port a-3  with frame dialog-Frame.
    Hide a4-lansc a3 only-file only-text-exel in frame dialog-Frame.
    print-o = "A4-port":U.
  End.
  If col-size > 136 and col-size <= 198 Then DO:
    Display  a4-lansc a-3  with frame dialog-Frame.
    Hide A4-port a3 only-file only-text-exel in frame dialog-Frame.
    print-o = "A4-lansc":U.
  End.
  If col-size > 198 and col-size <= 235 Then DO:
    Display a3 a-3  with frame dialog-Frame.
    Hide A4-port a4-lansc only-text-exel  only-file in frame dialog-Frame.
    print-o = "A3-lansc":U.
  End.
  If col-size > 235 Then DO:
    Display only-file a-3 with frame dialog-Frame.
    Hide A4-port a4-lansc a3 only-text-exel in frame dialog-Frame.
    print-o = "to-file":U.
  End.
  If col-size > 550 Then DO:
    Display  only-text-exel  with frame dialog-Frame.
    Hide only-file a-3 A4-port a4-lansc a3 in frame dialog-Frame.
    print-o = "to-file":U.
  End.
END PROCEDURE.
procedure eq-frame:
  Assign frame dialog-Frame  TOG-97 TOG-98 TOG-99 TOG-100 TOG-101 TOG-102 TOG-103 TOG-104 TOG-105 TOG-106 TOG-107 TOG-108 TOG-109 TOG-110 TOG-111 TOG-112 TOG-113 TOG-114 TOG-115 TOG-116 TOG-117 TOG-118 .
  Assign
    use-column[97]  =  TOG-97
    use-column[98]  =  TOG-98
    use-column[99]  =  TOG-99
    use-column[100] =  TOG-100
    use-column[101]  =  TOG-101
    use-column[102]  =  TOG-102
    use-column[103]  =  TOG-103
    use-column[104]  =  TOG-104
    use-column[105]  =  TOG-105
    use-column[106]  =  TOG-106
    use-column[107]  =  TOG-107
    use-column[108]  =  TOG-108
    use-column[109]  =  TOG-109
    use-column[110]  =  TOG-110
    use-column[111]  =  TOG-111
    use-column[112]  =  TOG-112
    use-column[113]  =  TOG-113
    use-column[114]  =  TOG-114
    use-column[115]  =  TOG-115
    use-column[116]  =  TOG-116
    use-column[117]  =  TOG-117
    use-column[118]  =  TOG-118
  .
end procedure.
