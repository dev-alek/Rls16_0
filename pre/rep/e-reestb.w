define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Реестр документов (Товарный отчет)".
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
def var vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function func-get-name-from-ext-type   returns char
  ( p-ext-type as character   ,
    p-caps     as logical ).
define variable v-ext-name as character no-undo .
run get-name-from-ext-type in this-procedure (
    input p-ext-type  ,
    input p-caps  ,
    output v-ext-name )
    no-error .
    if error-status :error then do:
       assign
         v-ext-name = p-ext-type
       .
    end.
 return (v-ext-name) .
end.
procedure get-name-from-ext-type :
 do
 on error undo, return error return-value
 :
define input  parameter p-ext-type as character no-undo .
define input  parameter p-caps     as logical no-undo   .
define output parameter p-ext-name as character no-undo .
define variable v-num as integer no-undo .
  if lookup ( p-ext-type , 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U ) = 0 then do :
    message
      vss-include-info13 skip
      "Неправильно задано значение входящего параметра! "
      "Нет такого типа документов " p-ext-type
      view-as alert-box error .
      undo, return error .
  end.
  v-num      = lookup ( p-ext-type , 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U ) .
  p-ext-name = entry  ( v-num , 'приход внешний,расход внешний,возврат пост.,касса продажа,возврат внешний,касса возврат,списание,инвентаризация,пересортица,приход внутренний,расход внутренний,возврат внутренний,расход  произв.,списан. произв.,приход  произв.,переоценка,коррекция учетных цен,корректировка отрицательных партий,смена типа приобретения,приход внутриобъектный,расход внутриобъектный':U ) .
  if p-caps  = true then do :
     p-ext-name = caps(substring(p-ext-name,1,1) ) + substring(p-ext-name, 2 , length (p-ext-name) - 1 ) .
  end .
  end.
end procedure.
define temp-table param-to-export no-undo
field param-code     as character
field param-sub-code as character
field param-type     as character
field param-value    as character
field param-comment  as character
index pi is unique primary  param-code     param-sub-code
.
procedure create-param-to-export :
 do
 on error undo, return error return-value
 :
 define input parameter p1 as character no-undo .
 define input parameter p2 as character no-undo .
 define input parameter p3 as character no-undo .
 define input parameter p4 as character no-undo .
 define input parameter p5 as character no-undo .
  create  param-to-export.
  assign
     param-to-export.param-code     =  p1
     param-to-export.param-sub-code =  p2
     param-to-export.param-type     =  p3
     param-to-export.param-value    =  p4
     param-to-export.param-comment  =  p5
  .
 end.
end procedure.
CREATE WIDGET-POOL.
define variable State-source as  WIDGET-HANDLE.
define variable g#log as logical   no-undo .
DEFINE VARIABLE EDITOR-1 AS CHARACTER INITIAL "Выбрать колонки для печати на закладке Формат можно только для Excel"
     VIEW-AS EDITOR NO-BOX
     SIZE 30 BY 2.5
     FGCOLOR 4  NO-UNDO.
DEFINE RECTANGLE RECT-12
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 35 BY 4.83.
DEFINE RECTANGLE RECT-14
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 35 BY 1.29.
DEFINE RECTANGLE RECT-15
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 35 BY 1.67.
DEFINE RECTANGLE RECT-16
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 35 BY 1.67.
DEFINE VARIABLE ap AS LOGICAL INITIAL yes
     LABEL "переоценка":L
     VIEW-AS TOGGLE-BOX
     SIZE 26.38 BY .75 NO-UNDO.
DEFINE VARIABLE CalcRest AS LOGICAL INITIAL yes
     LABEL "Расчет остатков"
     VIEW-AS TOGGLE-BOX
     SIZE 32 BY .75 NO-UNDO.
DEFINE VARIABLE CostSum AS LOGICAL INITIAL no
     LABEL "Учетные цены"
     VIEW-AS TOGGLE-BOX
     SIZE 32 BY .75 NO-UNDO.
DEFINE VARIABLE DispUpFact AS LOGICAL INITIAL no
     LABEL "Наценка"
     VIEW-AS TOGGLE-BOX
     SIZE 32 BY .75 NO-UNDO.
DEFINE VARIABLE ee AS LOGICAL INITIAL yes
     LABEL "расход внешний":L
     VIEW-AS TOGGLE-BOX
     SIZE 26.38 BY .75 NO-UNDO.
DEFINE VARIABLE em AS LOGICAL INITIAL yes
     LABEL "расход произв.":L
     VIEW-AS TOGGLE-BOX
     SIZE 26.38 BY .75 NO-UNDO.
DEFINE VARIABLE ep AS LOGICAL INITIAL yes
     LABEL "возврат поставщику"
     VIEW-AS TOGGLE-BOX
     SIZE 26.38 BY .75 NO-UNDO.
DEFINE VARIABLE es AS LOGICAL INITIAL yes
     LABEL "касса продажа":L
     VIEW-AS TOGGLE-BOX
     SIZE 26.38 BY .75 NO-UNDO.
DEFINE VARIABLE ev AS LOGICAL INITIAL yes
     LABEL "расход перемещение":L
     VIEW-AS TOGGLE-BOX
     SIZE 26.38 BY .75 NO-UNDO.
DEFINE VARIABLE ie AS LOGICAL INITIAL yes
     LABEL "приход внешний":L
     VIEW-AS TOGGLE-BOX
     SIZE 26.38 BY .75 NO-UNDO.
DEFINE VARIABLE im AS LOGICAL INITIAL yes
     LABEL "приход произв.":L
     VIEW-AS TOGGLE-BOX
     SIZE 26.38 BY .75 NO-UNDO.
DEFINE VARIABLE iv AS LOGICAL INITIAL yes
     LABEL "приход перемещение":L
     VIEW-AS TOGGLE-BOX
     SIZE 26.38 BY .75 NO-UNDO.
DEFINE VARIABLE mp AS LOGICAL INITIAL yes
     LABEL "переоценка":L
     VIEW-AS TOGGLE-BOX
     SIZE 53.5 BY .75 NO-UNDO.
DEFINE VARIABLE NullPer AS LOGICAL INITIAL no
     LABEL "не удалять нулевые переоценки"
     VIEW-AS TOGGLE-BOX
     SIZE 32 BY .75 NO-UNDO.
DEFINE VARIABLE ot AS LOGICAL INITIAL yes
     LABEL "переоценка":L
     VIEW-AS TOGGLE-BOX
     SIZE 26.38 BY .75 NO-UNDO.
DEFINE VARIABLE pc AS LOGICAL INITIAL yes
     LABEL "переоценка":L
     VIEW-AS TOGGLE-BOX
     SIZE 26.38 BY .75 NO-UNDO.
DEFINE VARIABLE re AS LOGICAL INITIAL yes
     LABEL "возврат внешний":L
     VIEW-AS TOGGLE-BOX
     SIZE 26.38 BY .75 NO-UNDO.
DEFINE VARIABLE rs AS LOGICAL INITIAL yes
     LABEL "касса возврат":L
     VIEW-AS TOGGLE-BOX
     SIZE 26.38 BY .75 NO-UNDO.
DEFINE VARIABLE rv AS LOGICAL INITIAL yes
     LABEL "возврат перемещение":L
     VIEW-AS TOGGLE-BOX
     SIZE 26.38 BY .75 NO-UNDO.
DEFINE VARIABLE Serv AS LOGICAL INITIAL no
     LABEL "Реестр только по услугам"
     VIEW-AS TOGGLE-BOX
     SIZE 32 BY .75 NO-UNDO.
DEFINE VARIABLE VAT-SLT AS LOGICAL INITIAL no
     LABEL "НДС и НП детально"
     VIEW-AS TOGGLE-BOX
     SIZE 32 BY .75 NO-UNDO.
DEFINE VARIABLE VAT-SLT-s AS LOGICAL INITIAL no
     LABEL "распределение налогов"
     VIEW-AS TOGGLE-BOX
     SIZE 32 BY .75 NO-UNDO.
DEFINE VARIABLE vt AS LOGICAL INITIAL yes
     LABEL "инвентаризация":L
     VIEW-AS TOGGLE-BOX
     SIZE 26.38 BY .75 NO-UNDO.
DEFINE VARIABLE we AS LOGICAL INITIAL yes
     LABEL "списание":L
     VIEW-AS TOGGLE-BOX
     SIZE 26.38 BY .75 NO-UNDO.
DEFINE VARIABLE wm AS LOGICAL INITIAL yes
     LABEL "списан. произв.":L
     VIEW-AS TOGGLE-BOX
     SIZE 26.38 BY .75 NO-UNDO.
DEFINE FRAME F-Main
     ie AT ROW 1.88 COL 37
     VAT-SLT AT ROW 2.29 COL 2.38
     ee AT ROW 2.92 COL 37
     VAT-SLT-s AT ROW 3.13 COL 2.38
     ep AT ROW 3.83 COL 37
     CostSum AT ROW 3.92 COL 2.38
     es AT ROW 4.75 COL 37
     DispUpFact AT ROW 4.83 COL 2.38
     re AT ROW 5.71 COL 37
     Serv AT ROW 6.17 COL 2.38
     rs AT ROW 6.58 COL 37
     we AT ROW 7.5 COL 37
     NullPer AT ROW 7.88 COL 2.38
     vt AT ROW 8.29 COL 37
     iv AT ROW 9.29 COL 37
     CalcRest AT ROW 9.75 COL 2.38
     ev AT ROW 10.08 COL 37
     rv AT ROW 11.04 COL 37
     em AT ROW 11.88 COL 37
     wm AT ROW 12.71 COL 37
     im AT ROW 13.5 COL 37
     ot AT ROW 14.42 COL 37
     ap AT ROW 15.33 COL 37
     EDITOR-1 AT ROW 15.75 COL 2.5 NO-LABEL WIDGET-ID 2
     pc AT ROW 16.29 COL 37
     mp AT ROW 17.08 COL 37
     "Документы:" VIEW-AS TEXT
          SIZE 11 BY .75 AT ROW 1 COL 44
          FGCOLOR 4
     "Показать:" VIEW-AS TEXT
          SIZE 11 BY .75 AT ROW 1.42 COL 12
          FGCOLOR 4
     RECT-14 AT ROW 6.04 COL 1
     RECT-15 AT ROW 9.33 COL 1
     RECT-16 AT ROW 7.5 COL 1
     RECT-12 AT ROW 1.17 COL 1
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1 SCROLLABLE .
IF NOT THIS-PROCEDURE:PERSISTENT THEN DO:
  MESSAGE "c:\tester\Rls_16_0\rc_160_rus\cmpdir\src\rep\e-reestb.w should only be RUN PERSISTENT.":U
          VIEW-AS ALERT-BOX ERROR BUTTONS OK.
  RETURN.
END.
DEFINE VAR adm-object-hdl       AS HANDLE NO-UNDO.
DEFINE VAR adm-query-opened        AS LOGICAL NO-UNDO INIT NO.
DEFINE VAR adm-row-avail-state     AS LOGICAL NO-UNDO INIT ?.
DEFINE VAR adm-initial-lock        AS CHARACTER NO-UNDO INIT "NO-LOCK":U.
DEFINE VAR adm-new-record          AS LOGICAL NO-UNDO INIT no.
DEFINE VAR adm-updating-record     AS LOGICAL NO-UNDO INIT no.
DEFINE VAR adm-check-modified-all  AS LOGICAL NO-UNDO INIT no.
DEFINE NEW GLOBAL SHARED VAR adm-broker-hdl    AS HANDLE  NO-UNDO.
      adm-object-hdl = FRAME F-Main:HANDLE.
RUN ensure-broker.
THIS-PROCEDURE:ADM-DATA =
     'ADM1.1~`':U +
     'SmartViewer~`':U +
     '~`':U +
     'NO ~`':U +
     '~`':U +
     '~`':U +
     '~`':U +
     (IF adm-object-hdl = ? THEN "":U ELSE STRING(adm-object-hdl))
        + "~`":U +
     'Initial-Lock,Hide-on-Init,Disable-on-Init,Key-Name,Layout,Create-On-Add~`':U +
     'Record-Source,Record-Target,TableIO-Target~`':U +
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
    DISABLE RECT-14 RECT-15 RECT-16 RECT-12 ie VAT-SLT ee VAT-SLT-s ep CostSum es DispUpFact re Serv rs we NullPer vt iv CalcRest ev rv em wm im ot ap EDITOR-1 pc mp WITH FRAME F-Main.
    RUN dispatch ('disable-fields':U).
    RUN set-attribute-list ('ENABLED=no':U).
    RETURN.
END PROCEDURE.
PROCEDURE adm-edit-attribute-list :
      RUN adm/support/viewerd.w (INPUT THIS-PROCEDURE).
      RETURN.
END PROCEDURE.
PROCEDURE adm-enable :
    ENABLE UNLESS-HIDDEN RECT-14 RECT-15 RECT-16 RECT-12 ie VAT-SLT ee VAT-SLT-s ep CostSum es DispUpFact re Serv rs we NullPer vt iv CalcRest ev rv em wm im ot ap EDITOR-1 pc mp WITH FRAME F-Main.
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
    ASSIGN curr-widget = FRAME F-Main:CURRENT-ITERATION.
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
  RUN set-attribute-list ('FIELDS-ENABLED=no,ADM-NEW-RECORD=no':U).
ASSIGN
       FRAME F-Main:SCROLLABLE       = FALSE
       FRAME F-Main:HIDDEN           = TRUE.
ASSIGN
       EDITOR-1:READ-ONLY IN FRAME F-Main        = TRUE.
ON VALUE-CHANGED OF ap IN FRAME F-Main
DO:
  run calc-rest in this-procedure .
END.
ON VALUE-CHANGED OF ee IN FRAME F-Main
DO:
  run calc-rest in this-procedure .
END.
ON VALUE-CHANGED OF em IN FRAME F-Main
DO:
  run calc-rest in this-procedure .
END.
ON VALUE-CHANGED OF ep IN FRAME F-Main
DO:
  run calc-rest in this-procedure .
END.
ON VALUE-CHANGED OF es IN FRAME F-Main
DO:
    run calc-rest in this-procedure .
END.
ON VALUE-CHANGED OF ev IN FRAME F-Main
DO:
  run calc-rest in this-procedure .
END.
ON VALUE-CHANGED OF ie IN FRAME F-Main
DO:
  run calc-rest in this-procedure .
END.
ON VALUE-CHANGED OF im IN FRAME F-Main
DO:
  run calc-rest in this-procedure .
END.
ON VALUE-CHANGED OF iv IN FRAME F-Main
DO:
  run calc-rest in this-procedure .
END.
ON VALUE-CHANGED OF mp IN FRAME F-Main
DO:
  run calc-rest in this-procedure .
END.
ON VALUE-CHANGED OF ot IN FRAME F-Main
DO:
  run calc-rest in this-procedure .
END.
ON VALUE-CHANGED OF pc IN FRAME F-Main
DO:
  run calc-rest in this-procedure .
END.
ON VALUE-CHANGED OF re IN FRAME F-Main
DO:
  run calc-rest in this-procedure .
END.
ON VALUE-CHANGED OF rs IN FRAME F-Main
DO:
  run calc-rest in this-procedure .
END.
ON VALUE-CHANGED OF rv IN FRAME F-Main
DO:
  run calc-rest in this-procedure .
END.
ON VALUE-CHANGED OF Serv IN FRAME F-Main
DO:
  assign serv.
  if serv then DO:
       CalcRest = false.
       disable CalcRest with frame F-Main.
       display CalcRest with frame F-Main.
       End.
     Else do:
       enable CalcRest with frame F-Main.
       display CalcRest with frame F-Main.
       End.
END.
ON VALUE-CHANGED OF vt IN FRAME F-Main
DO:
    run calc-rest in this-procedure .
END.
ON VALUE-CHANGED OF we IN FRAME F-Main
DO:
  run calc-rest in this-procedure .
END.
ON VALUE-CHANGED OF wm IN FRAME F-Main
DO:
  run calc-rest in this-procedure .
END.
define variable  list-com-hand as character no-undo .
list-com-hand = "" .
list-com-hand = list-com-hand + string(ie:handle) + "," .
list-com-hand = list-com-hand + string(ee:handle) + "," .
list-com-hand = list-com-hand + string(ep:handle) + "," .
list-com-hand = list-com-hand + string(es:handle) + "," .
list-com-hand = list-com-hand + string(re:handle) + "," .
list-com-hand = list-com-hand + string(rs:handle) + "," .
list-com-hand = list-com-hand + string(we:handle) + "," .
list-com-hand = list-com-hand + string(vt:handle) + "," .
list-com-hand = list-com-hand + string(iv:handle) + "," .
list-com-hand = list-com-hand + string(ev:handle) + "," .
list-com-hand = list-com-hand + string(rv:handle) + "," .
list-com-hand = list-com-hand + string(em:handle) + "," .
list-com-hand = list-com-hand + string(wm:handle) + "," .
list-com-hand = list-com-hand + string(im:handle) + "," .
list-com-hand = list-com-hand + string(ot:handle) + "," .
list-com-hand = list-com-hand + string(ap:handle) + "," .
list-com-hand = list-com-hand + string(pc:handle) + "," .
list-com-hand = list-com-hand + string(mp:handle) + "," .
PROCEDURE calc-rest :
assign FRAME F-Main ie ee ep es re rs we vt iv ev rv em wm im ot ap pc mp    .
if  ie
AND ee
AND  ep
AND  es
AND  re
AND  rs
AND  we
AND  vt
AND  iv
AND  ev
AND  rv
AND  em
AND  wm
AND  im
AND  ot
AND  ap
AND  pc
   then
    do:
        assign CalcRest = yes.
        DISPLAY CalcRest WITH FRAME F-Main.
        ENABLE CalcRest WITH FRAME F-Main.
    end.
else
    do:
        assign CalcRest = no.
        DISPLAY CalcRest WITH FRAME F-Main.
        DISABLE CalcRest WITH FRAME F-Main.
    end.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME F-Main.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY ie VAT-SLT ee VAT-SLT-s ep CostSum es DispUpFact re Serv rs we NullPer
          vt iv CalcRest ev rv em wm im ot ap EDITOR-1 pc mp
      WITH FRAME F-Main.
  ENABLE RECT-14 RECT-15 RECT-16 RECT-12 ie VAT-SLT ee VAT-SLT-s ep CostSum es
         DispUpFact re Serv rs we NullPer vt iv CalcRest ev rv em wm im ot ap
         EDITOR-1 pc mp
      WITH FRAME F-Main.
END PROCEDURE.
PROCEDURE local-initialize :
  run dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ) .
define variable vss-include-info14 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    ,input  false
    ,output g#log
    )  .
end.
   if not  g#log then do :
   CostSum = false .
   DispUpFact = false .
   disable CostSum DispUpFact  with frame F-Main .
   display CostSum  DispUpFact with frame F-Main .
 end.
define variable lab-handle as handle no-undo .
define variable i as integer no-undo .
define variable v-code as character no-undo .
define variable v-nn as integer   no-undo .
v-nn = num-entries (list-com-hand) .
do i = 1 to v-nn :
 lab-handle = widget-handle (entry( i , list-com-hand) ) no-error .
 if valid-handle(lab-handle) = true and  error-status :error = false   then do:
    v-code = lab-handle:name.
    lab-handle:label = func-get-name-from-ext-type ( v-code, true  ) .
    end.
end.
END PROCEDURE.
PROCEDURE my-report :
fOR EACH tdedt: DELETE tdedt. eND.
IF ie then  do:
create tdedt.
assign tdedt.id =  'ie':U
       tdedt.n  = "01"
.
run get-name-from-ext-type in this-procedure (
    input tdedt.id  ,
    input false  ,
    output tdedt.name )
     .
                       END.
IF ee then  do:
create tdedt.
assign tdedt.id =  'ee':U
       tdedt.n  = "02"
.
run get-name-from-ext-type in this-procedure (
    input tdedt.id  ,
    input false  ,
    output tdedt.name )
     .
                       END.
IF ep then  do:
create tdedt.
assign tdedt.id =  'ep':U
       tdedt.n  = "03"
.
run get-name-from-ext-type in this-procedure (
    input tdedt.id  ,
    input false  ,
    output tdedt.name )
     .
                 END.
IF es then  do:
create tdedt.
assign tdedt.id =  'es':U
       tdedt.n  = "04"
.
run get-name-from-ext-type in this-procedure (
    input tdedt.id  ,
    input false  ,
    output tdedt.name )
     .
             END.
IF re then  do:
create tdedt.
assign tdedt.id =  're':U
       tdedt.n  = "05"
.
run get-name-from-ext-type in this-procedure (
    input tdedt.id  ,
    input false  ,
    output tdedt.name )
     .
               END.
IF rs then  do:
create tdedt.
assign tdedt.id =  'rs':U
       tdedt.n  = "06"
.
run get-name-from-ext-type in this-procedure (
    input tdedt.id  ,
    input false  ,
    output tdedt.name )
     .
     END.
IF we then  do:
create tdedt.
assign tdedt.id =  'we':U
       tdedt.n  = "07"
.
run get-name-from-ext-type in this-procedure (
    input tdedt.id  ,
    input false  ,
    output tdedt.name )
     .
                       END.
IF vt then  do:
create tdedt.
assign tdedt.id =  'vt':U
       tdedt.n  = "08"
.
run get-name-from-ext-type in this-procedure (
    input tdedt.id  ,
    input false  ,
    output tdedt.name )
     .
create tdedt.
assign tdedt.id =  'vp':U
       tdedt.n  = "08"
.
run get-name-from-ext-type in this-procedure (
    input tdedt.id  ,
    input false  ,
    output tdedt.name )
     .
                                   END.
IF iv then  do:
create tdedt.
assign tdedt.id =  'iv':U
       tdedt.n  = "09"
.
run get-name-from-ext-type in this-procedure (
    input tdedt.id  ,
    input false  ,
    output tdedt.name )
     .
                       END.
IF ev then  do:
create tdedt.
assign tdedt.id =  'ev':U
       tdedt.n  = "10"
.
run get-name-from-ext-type in this-procedure (
    input tdedt.id  ,
    input false  ,
    output tdedt.name )
     .
                       END.
IF rv then  do:
create tdedt.
assign tdedt.id =  'rv':U
       tdedt.n  = "11"
.
run get-name-from-ext-type in this-procedure (
    input tdedt.id  ,
    input false  ,
    output tdedt.name )
     .
               END.
IF em then  do:
create tdedt.
assign tdedt.id =  'em':U
       tdedt.n  = "12"
.
run get-name-from-ext-type in this-procedure (
    input tdedt.id  ,
    input false  ,
    output tdedt.name )
     .
                         END.
IF wm then  do:
create tdedt.
assign tdedt.id =  'wm':U
       tdedt.n  = "13"
.
run get-name-from-ext-type in this-procedure (
    input tdedt.id  ,
    input false  ,
    output tdedt.name )
     .
                         END.
IF im then  do:
create tdedt.
assign tdedt.id =  'im':U
       tdedt.n  = "14"
.
run get-name-from-ext-type in this-procedure (
    input tdedt.id  ,
    input false  ,
    output tdedt.name )
     .
                         END.
IF ot then  do:
create tdedt.
assign tdedt.id =  'ot':U
       tdedt.n  = "15"
.
run get-name-from-ext-type in this-procedure (
    input tdedt.id  ,
    input false  ,
    output tdedt.name )
     .
                         END.
IF ap then  do:
create tdedt.
assign tdedt.id =  'ap':U
       tdedt.n  = "16"
.
run get-name-from-ext-type in this-procedure (
    input tdedt.id  ,
    input false  ,
    output tdedt.name )
     .
                   END.
IF pc then  do:
create tdedt.
assign tdedt.id =  'pc':U
       tdedt.n  = "17"
.
run get-name-from-ext-type in this-procedure (
    input tdedt.id  ,
    input false  ,
    output tdedt.name )
     .
                   END.
IF mp then  do:
create tdedt.
assign tdedt.id =  'mp':U
       tdedt.n  = "18"
.
run get-name-from-ext-type in this-procedure (
    input tdedt.id  ,
    input false  ,
    output tdedt.name )
     .
                   END.
if serv = true then
  run rep/r-reestb.p
                 (input v-cntxt-obj-code ,
                  input v-cntxt-obj-type ,
                  input base-type ,
                  input base-code ,
                  input VAT-SLT,
                  input VAT-SLT-s,
                  input CostSum,
                  input DispUpFact  ,
                  input Serv,
                  input ?,
                  input NullPer,
                  input CalcRest) .
 Else  run rep/r-reest2.p
                 (input v-cntxt-obj-code ,
                  input v-cntxt-obj-type ,
                  input base-type ,
                  input base-code ,
                  input VAT-SLT,
                  input VAT-SLT-s,
                  input CostSum,
                  input DispUpFact  ,
                  input Serv,
                  input ?,
                  input NullPer,
                  input CalcRest)
                  .
END PROCEDURE.
PROCEDURE my-var :
assign frame F-Main ie ee ep es re rs we vt iv ev rv em wm im ot ap pc mp
 VAT-SLT VAT-SLT-s
 CostSum DispUpFact
 Serv  NullPer CalcRest.
ReportNAme = "Р Е Е С Т Р   Д О К У М Е Н Т О В  ( Т О В А Р Н Ы Й   О Т Ч Е Т )".
ReportHeader = IF VAT-SLT THEN VAT-SLT:label + chr(10) Else "" .
ReportHeader = (ReportHeader) + IF VAT-SLT-s   THEN VAT-SLT-s:label + chr(10) Else "" .
ReportHeader = (ReportHeader) + IF CostSum     THEN CostSum:label + chr(10) Else "".
ReportHeader = (ReportHeader) + IF DispUpFact  THEN DispUpFact:label + chr(10) Else "" .
ReportHeader = (ReportHeader) + IF  Serv       THEN Serv:label + chr(10) Else "" .
ReportHeader = (ReportHeader) + IF  NullPer    THEN NullPer:label + chr(10) Else "без нулевых остатков по переоценке" + chr(10) .
ReportHeader = (ReportHeader) + IF  CalcRest   THEN CalcRest:label + chr(10) Else ""  .
ReportHeader = (ReportHeader) + "документы : "  + chr(10).
ReportHeader = (ReportHeader)               + IF  ie THen      (ie:label) + ","  else " " .
ReportHeader = (ReportHeader)               + IF  ee then      (ee:label) + ","  else " ".
ReportHeader = (ReportHeader)               + IF  ep then      (ep:label) + ","  else " ".
ReportHeader = (ReportHeader)               + IF  es THen      (es:label) + ","  else " ".
ReportHeader = (ReportHeader)               + IF  re then      (re:label) + ","  else " ".
ReportHeader = (ReportHeader) +  chr(10).
ReportHeader = (ReportHeader)               + IF  rs then      (rs:label) + ","  else " ".
ReportHeader = (ReportHeader)               + IF  we THen      (we:label) + ","  else " ".
ReportHeader = (ReportHeader)               + IF  vt then      (vt:label) + ","  else " ".
ReportHeader = (ReportHeader)               + IF  iv then      (iv:label) + ","  else " ".
ReportHeader = (ReportHeader)               + IF  ev THen      (ev:label) + ","  else " ".
ReportHeader = (ReportHeader) +  chr(10).
ReportHeader = (ReportHeader)               + IF  rv then      (rv:label) + ","  else " ".
ReportHeader = (ReportHeader)               + IF  em then      (em:label) + ","  else " " .
ReportHeader = (ReportHeader)               + IF  wm THen      wm:label + ","  else " " .
ReportHeader = (ReportHeader)               + IF  im then      im:label + ","  else " ".
ReportHeader = (ReportHeader)               + IF  ap then      ap:label + ","  else " ".
ReportHeader = (ReportHeader)               + IF  pc then      pc:label + ","  else " ".
ReportHeader = (ReportHeader)               + IF  mp then      mp:label + ","  else " ".
ReportHeader = (ReportHeader)               + IF  ot then      ot:label        else " " .
 sheetf.Excel-Column-Lable =
           "Дата закрытия"
  + ","  + "№ документа"
  + ","  + "Контрагент"
  + ","  + "Количество"
  + ","  + "Сумма с НДС"
  + ","  + "Сумма без НДС"
  + ","  + "Сумма скидки"
  + ","  + "Сумма авт. переоценки"
  + ","  + "Сумма в продажных ценах"
  + ","  + "Ставка НДС"
  + ","  + "Сумма НДС"
  + ","  + "Ставка НП"
  + ","  + "Сумма налога с продаж" .
 sheetf.Sizes        =  "10,16,30,13,15,15,15,15,15,15,15,15,15" .
 sheetf.make-correct =
 "false,false,false,false,false,false,false,false,false,false,false,false,false"
  .
END PROCEDURE.
PROCEDURE report-to-ach :
 do
 on error undo, return error return-value
 :
 DEFINE INPUT-OUTPUT  PARAMETER TABLE FOR param-to-export .
  for each  param-to-export : delete  param-to-export. end.
define variable cconnect as character no-undo .
define variable user-name as character no-undo .
define variable vss-include-info15 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usrfulnm in g#library
  (input  v-cntxt-userid
  ,output user-name
  )  .
 get-key-value section "rep-sets" key "conpar" value cconnect .
define variable v-base-key as character no-undo .
run gbl/base-key.p
   (output v-base-key
  ) .
  run create-param-to-export  in this-procedure
  ( input 'base-key'  ,
   input ''  ,
   input 'character'  ,
   input v-base-key  ,
   input 'ключ' )
 .
  run create-param-to-export  in this-procedure
  ( input 'db-connect'  ,
   input ''  ,
   input 'character'  ,
   input cconnect  ,
   input 'строка коннекта к БД' )
 .
  run create-param-to-export  in this-procedure
  ( input 'report-code'  ,
   input ''  ,
   input 'character'  ,
   input ReportProc  ,
   input 'уникальный код отчета' )
 .
define variable v-host-code like ub.sysconf.host-code no-undo .
define variable v-host-name like ub.clients.obj-name no-undo .
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostname in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-host-code
  ,output v-host-name
  )  .
  run create-param-to-export  in this-procedure
  ( input 'firm-name'  ,
   input ''  ,
   input 'character'  ,
   input v-host-name  ,
   input 'имя фирмы' )
 .
  run create-param-to-export  in this-procedure
  ( input 'firm-code'  ,
   input ''  ,
   input 'integer'  ,
   input string(v-cntxt-host-code-obj)  ,
   input 'код фирмы' )
 .
  run create-param-to-export  in this-procedure
  ( input 'user-name'  ,
   input ''  ,
   input 'character'  ,
   input user-name  ,
   input 'имя пользователя' )
 .
  run create-param-to-export  in this-procedure
  ( input 'store-type'  ,
   input ''  ,
   input 'character'  ,
   input v-cntxt-obj-type  ,
   input 'текущий объект - тип'  )
 .
  run create-param-to-export  in this-procedure
  ( input 'store-code'  ,
   input ''  ,
   input 'integer'  ,
   input string(v-cntxt-obj-code)  ,
   input 'текущий объект - код' )
 .
  run create-param-to-export  in this-procedure
  ( input 'date-start'  ,
   input ''  ,
   input 'data'  ,
   input string(x-date-start,'99/99/9999')  ,
   input 'дата начала интервала'  )
 .
  run create-param-to-export  in this-procedure
  ( input 'date-end'  ,
   input ''  ,
   input 'data'  ,
   input string(x-date-end,'99/99/9999')  ,
   input 'дата конца интервала' )
 .
  run create-param-to-export  in this-procedure
  ( input 'user-id'  ,
   input ''  ,
   input 'character'  ,
   input v-cntxt-userid  ,
   input 'код пользователя' )
 .
define variable v-base-code like ub.sysconf.base-code no-undo .
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-cntxt-host-code-obj
  ,output v-base-code
  )  .
define buffer buf_currency for ub.currency.
find first buf_currency no-lock where
          buf_currency.curr-code = v-base-code.
  run create-param-to-export  in this-procedure
  ( input 'base-type'  ,
   input ''  ,
   input 'character'  ,
   input string(buf_currency.curr-abbr)  ,
   input 'тип базовой валюты' )
 .
  run create-param-to-export  in this-procedure
  ( input 'base-code'  ,
   input ''  ,
   input 'integer'  ,
   input string(v-base-code)  ,
   input 'код базовой валюты' )
 .
if Show-Crsa or Show-Cost or Show-Sale then do:
  run create-param-to-export  in this-procedure
  ( input 'crsa'  ,
   input ''  ,
   input 'logical'  ,
   input string(show-Crsa,'yes/no')  ,
   input '  продажные цены' )
 .
  run create-param-to-export  in this-procedure
  ( input 'cost'  ,
   input ''  ,
   input 'logical'  ,
   input string(show-cost,'yes/no')  ,
   input '  учетные цены' )
 .
  run create-param-to-export  in this-procedure
  ( input 'sale'  ,
   input ''  ,
   input 'logical'  ,
   input string(show-sale,'yes/no')  ,
   input '  цены документа' )
 .
end.
else do:
  run create-param-to-export  in this-procedure
  ( input 'set-pay-type'  ,
   input ''  ,
   input 'integer'  ,
   input string(x-set_pay_type)  ,
   input 'тип цены Продажные цены=1 Учетные цены=2 Цены документа=3 ' )
 .
end.
  run create-param-to-export  in this-procedure
  ( input 'rubl-val'  ,
   input ''  ,
   input 'integer'  ,
   input string(x-SET_val_TYPE)  ,
   input 'печатать в рублях или валюте руб=1  вал=2  обе=3 ' )
 .
  run create-param-to-export  in this-procedure
  ( input 'reportname'  ,
   input ''  ,
   input 'character'  ,
   input reportname  ,
   input 'название отчета' )
 .
  run create-param-to-export  in this-procedure
  ( input 'select-good'  ,
   input ''  ,
   input 'integer'  ,
   input string(x-selectgood)  ,
   input 'тип выбора товара all=1 grp=2 prod=3 choice=4 one=5 grp-prod=6' )
 .
 define variable ii as integer no-undo .
 define variable ii-name as character no-undo .
 define variable ii-1 as integer no-undo .
 define variable ii-name-1 as character no-undo .
  define variable ii-2 as integer no-undo .
 define variable ii-name-2 as character no-undo .
 define variable ii-3 as integer no-undo .
 define variable ii-name-3 as character no-undo .
 if x-selectgood = 1     Or
    x-selectgood = 2     Or
    x-selectgood = 3    Or
    x-selectgood = 4  then do:
 ii = 0.
      for each gds-list :
        ii = ii + 1 .
        if ii = 1 then ii-name = "список товаров - содержит gds-code  (уникальный ключ товара)" .
                  else ii-name = "" .
  run create-param-to-export  in this-procedure
  ( input 'gds-list'  ,
   input string(ii)  ,
   input 'integer'  ,
   input string(gds-list.gds-code)  ,
   input ii-name )
 .
      end.
 end.
 if x-selectgood = 2 then do:
 ii-2 = 0.
      for each tmp#grp :
        ii-2 = ii-2 + 1 .
        if ii-2 = 1 then ii-name-2 = "список товаров - содержит  <node-code#grp-name>  (уникальный ключ списка групп)" .
                  else ii-name-2 = "" .
  run create-param-to-export  in this-procedure
  ( input 'tmp#grp'  ,
   input string(ii-2)  ,
   input 'integer character '  ,
   input string(tmp#grp.node-code) + '#' +  (tmp#grp.grp-name)  ,
   input ii-name-2 )
 .
      end.
 end.
 if x-selectgood = 3 then do:
 ii-3 = 0.
      for each g#cli :
        ii-3 = ii-3 + 1 .
        if ii-3 = 1 then ii-name-3 = "список товаров - содержит  <node-code#grp-name>  (уникальный ключ списка производителе)" .
                    else ii-name-3 = "" .
  run create-param-to-export  in this-procedure
  ( input 'g#cli'  ,
   input string(ii-3)  ,
   input 'character integer'  ,
   input g#cli.obj-type + '#' + string(g#cli.obj-code)  ,
   input ii-name-3 )
 .
      end.
 end.
  run create-param-to-export  in this-procedure
  ( input 'select-object'  ,
   input ''  ,
   input 'character'  ,
   input x-selectobject  ,
   input 'тип выбора объекта   -currency -choice -firm -все' )
 .
 ii-1 = 0.
  for each obj-list :
    ii-1 = ii-1 + 1 .
    if ii-1 = 1 then ii-name-1 = "список объектов - содержит <obj-type#obj-code>  (уникальный ключ clients)" .
              else ii-name-1 = "" .
  run create-param-to-export  in this-procedure
  ( input 'obj-list'  ,
   input string(ii-1)  ,
   input 'character integer'  ,
   input obj-list.obj-type + '#' + string (obj-list.obj-code)  ,
   input ii-name-1 )
 .
  end.
  run create-param-to-export  in this-procedure
  ( input 'vat-slt'                             ,
   input ''                                    ,
   input 'logical'                             ,
   input string(vat-slt,'yes/no')              ,
   input vat-slt:label in frame F-Main )
 .
  run create-param-to-export  in this-procedure
  ( input 'vat-slt-detale'                       ,
   input ''                                     ,
   input 'logical'                              ,
   input string(vat-slt-s,'yes/no')             ,
   input vat-slt-s:label in frame F-Main )
 .
  run create-param-to-export  in this-procedure
  ( input 'cost-sum'                                            ,
   input ''                                                    ,
   input 'logical'                                             ,
   input string(costsum,'yes/no')                              ,
   input costsum:label in frame F-Main                 )
 .
  run create-param-to-export  in this-procedure
  ( input 'discont'                                             ,
   input ''                                                    ,
   input 'logical'                                             ,
   input string(dispupfact,'yes/no')                           ,
   input dispupfact:label in frame F-Main              )
 .
  run create-param-to-export  in this-procedure
  ( input 'service'                                             ,
   input ''                                                    ,
   input 'logical'                                             ,
   input string(serv,'yes/no')                                 ,
   input serv:label in frame F-Main                    )
 .
  run create-param-to-export  in this-procedure
  ( input 'null-pricelist'                                      ,
   input ''                                                    ,
   input 'logical'                                             ,
   input string(nullper,'yes/no')                              ,
   input nullper:label in frame F-Main                 )
 .
  run create-param-to-export  in this-procedure
  ( input 'calc-rest '                                          ,
   input ''                                                    ,
   input 'logical'                                             ,
   input string(calcrest ,'yes/no')                            ,
   input calcrest :label in frame F-Main               )
 .
  run create-param-to-export  in this-procedure
  ( input 'ie'                             ,
   input ''                               ,
   input 'logical'                        ,
   input string(ie,'yes/no')              ,
   input ie:label in frame F-Main )
 .
  run create-param-to-export  in this-procedure
  ( input 'ee'                             ,
   input ''                               ,
   input 'logical'                        ,
   input string(ee,'yes/no')              ,
   input ee:label in frame F-Main )
 .
  run create-param-to-export  in this-procedure
  ( input 'ep'                             ,
   input ''                               ,
   input 'logical'                        ,
   input string(ep,'yes/no')              ,
   input ep:label in frame F-Main )
 .
  run create-param-to-export  in this-procedure
  ( input 'es'                             ,
   input ''                               ,
   input 'logical'                        ,
   input string(es,'yes/no')              ,
   input es:label in frame F-Main )
 .
  run create-param-to-export  in this-procedure
  ( input 're'                             ,
   input ''                               ,
   input 'logical'                        ,
   input string(re,'yes/no')              ,
   input re:label in frame F-Main )
 .
  run create-param-to-export  in this-procedure
  ( input 'rs'                             ,
   input ''                               ,
   input 'logical'                        ,
   input string(rs,'yes/no')              ,
   input rs:label in frame F-Main )
 .
  run create-param-to-export  in this-procedure
  ( input 'we'                             ,
   input ''                               ,
   input 'logical'                        ,
   input string(we,'yes/no')              ,
   input we:label in frame F-Main )
 .
  run create-param-to-export  in this-procedure
  ( input 'vt'                             ,
   input ''                               ,
   input 'logical'                        ,
   input string(vt,'yes/no')              ,
   input vt:label in frame F-Main )
 .
  run create-param-to-export  in this-procedure
  ( input 'iv'                             ,
   input ''                               ,
   input 'logical'                        ,
   input string(iv,'yes/no')              ,
   input iv:label in frame F-Main )
 .
  run create-param-to-export  in this-procedure
  ( input 'ev'                             ,
   input ''                               ,
   input 'logical'                        ,
   input string(ev,'yes/no')              ,
   input ev:label in frame F-Main )
 .
  run create-param-to-export  in this-procedure
  ( input 'rv'                             ,
   input ''                               ,
   input 'logical'                        ,
   input string(rv,'yes/no')              ,
   input rv:label in frame F-Main )
 .
  run create-param-to-export  in this-procedure
  ( input 'em'                             ,
   input ''                               ,
   input 'logical'                        ,
   input string(em,'yes/no')              ,
   input em:label in frame F-Main )
 .
  run create-param-to-export  in this-procedure
  ( input 'wm'                             ,
   input ''                               ,
   input 'logical'                        ,
   input string(wm,'yes/no')              ,
   input wm:label in frame F-Main )
 .
  run create-param-to-export  in this-procedure
  ( input 'im'                             ,
   input ''                               ,
   input 'logical'                        ,
   input string(im,'yes/no')              ,
   input im:label in frame F-Main )
 .
  run create-param-to-export  in this-procedure
  ( input 'ot'                             ,
   input ''                               ,
   input 'logical'                        ,
   input string(ot,'yes/no')              ,
   input ot:label in frame F-Main )
 .
  end.
END PROCEDURE.
PROCEDURE state-changed :
  DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE    NO-UNDO.
  DEFINE INPUT PARAMETER p-state      AS CHARACTER NO-UNDO.
  CASE p-state:
  END CASE.
END PROCEDURE.
