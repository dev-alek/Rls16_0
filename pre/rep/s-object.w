CREATE WIDGET-POOL.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Окно для вызова отчетов (Главная закладка № 1)".
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
function diff-list returns character (
  input parfirst-list  as character,
  input parsecond-list as character,
  input pardelim       as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem as character no-undo .
  def var v-result-list as character no-undo init "".
  def var v-num-parfirst-list as integer no-undo .
  assign
    v-num-parfirst-list = num-entries(parfirst-list, pardelim)
  .
  do ind = 1 to v-num-parfirst-list
  :
    assign
      v-elem = entry(ind, parfirst-list, pardelim)
    .
    if lookup(v-elem, parsecond-list, pardelim) = 0 then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  return v-result-list .
end function.
function add-list returns character (
 input parfirst-list  as character,
 input parsecond-list as character,
 input pardelim       as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem as character no-undo .
  def var v-result-list as character no-undo init "".
  def var v-num-parfirst-list as integer no-undo .
  assign
    v-num-parfirst-list = num-entries(parfirst-list, pardelim)
  .
  do ind = 1 to v-num-parfirst-list
  :
    assign
      v-elem = entry(ind, parfirst-list, pardelim)
    .
    if lookup(v-elem, v-result-list, pardelim) = 0 then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  def var v-num-parsecond-list as integer no-undo .
  assign
    v-num-parsecond-list = num-entries(parsecond-list, pardelim)
  .
  do ind = 1 to v-num-parsecond-list
  :
    assign
      v-elem = entry(ind, parsecond-list, pardelim)
    .
    if lookup(v-elem, v-result-list, pardelim) = 0 then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  return v-result-list .
end function.
function cross-list returns character (
 input parfirst-list  as character,
 input parsecond-list as character,
 input pardelim       as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem as character no-undo .
  def var v-result-list as character no-undo init "".
  def var v-num-parfirst-list as integer no-undo .
  assign
    v-num-parfirst-list = num-entries(parfirst-list, pardelim)
  .
  do ind = 1 to v-num-parfirst-list
  :
    assign
      v-elem = entry(ind, parfirst-list, pardelim)
    .
    if lookup(v-elem, v-result-list, pardelim) = 0
    and lookup(v-elem, parsecond-list, pardelim) > 0
    then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  return v-result-list .
end function.
function radio-label returns character (
 input par-rs-value  as character,
 input par-rs-radio-buttons as character)
 .
 DEFINE variable v-result-label as character no-undo.
 assign
 v-result-label =  ENTRY( (IF (LOOKUP(par-rs-value, par-rs-radio-buttons) MODULO 2 = 0)
                           then (LOOKUP(par-rs-value, par-rs-radio-buttons) - 1)
                           else LOOKUP(par-rs-value, par-rs-radio-buttons)
                          ), par-rs-radio-buttons
                        )
 v-result-label = REPLACE(v-result-label, "&":U, "":U)
 .
return v-result-label.
end function.
function m-radio-label returns character (
 input par-rs-value  as character,
 input par-rs-radio-buttons as character,
 input par-delim as character
 )
 .
 DEFINE variable v-result-label as character no-undo.
 assign
 v-result-label =  ENTRY( (IF (LOOKUP(par-rs-value, par-rs-radio-buttons, par-delim) MODULO 2 = 0)
                           then (LOOKUP(par-rs-value, par-rs-radio-buttons, par-delim) - 1)
                           else LOOKUP(par-rs-value, par-rs-radio-buttons, par-delim)
                          ), par-rs-radio-buttons, par-delim
                        )
 v-result-label = REPLACE(v-result-label, "&":U, "":U)
 .
return v-result-label.
end function.
FUNCTION mixlist returns character
(
 input parfirst-list  as character
 ,input parsecond-list as character
 ,input pardelim       as character
 ,input pardelim-result as character ) :
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem1 as character no-undo .
  def var v-elem2 as character no-undo .
  def var v-result-list as character no-undo init "".
  do ind = 1 to num-entries(parfirst-list, pardelim)
  :
    assign
      v-elem1 = entry(ind, parfirst-list, pardelim)
      v-elem2 = entry(ind, parsecond-list, pardelim)
    .
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim-result else "")
                      + v-elem1 + pardelim-result + v-elem2
      .
  end.
  return v-result-list .
END FUNCTION.
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
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
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
define shared variable lns-cnt as integer no-undo .
define shared variable s-notes   as character no-undo .
define variable proba1 as integer no-undo .
define variable list-mode                 as character no-undo .
define variable doc-mode                  as character no-undo .
define variable doc-rec                   as recid     no-undo .
define variable line-rec                  as recid     no-undo .
define variable gds-rec                   as recid     no-undo .
define variable prt-rec                   as recid     no-undo .
define variable line-mode                 as character no-undo .
define variable v-ok                      as logical   no-undo .
define variable state-source              as widget-handle no-undo .
define variable temp-str                  as character no-undo .
define variable temp-param-date           as integer   no-undo .
define variable temp-param-date-type-period  as character no-undo .
define variable temp-param-goods          as character no-undo .
define variable temp-param-obj            as character no-undo .
define variable temp-param-Pay            as character no-undo .
define variable temp-param-Pay-hide       as character no-undo .
define variable temp-param-obj-type       as character no-undo .
define variable temp-param-alon           as logical   no-undo .
define variable temp-param-customer       as character no-undo .
define variable temp-param-customer-type  as character no-undo .
define variable temp-param-schet          as character no-undo .
define variable temp-param-schet-hide     as character no-undo .
define variable temp-param-schet-init     as character no-undo .
define variable temp-param-schet-mode     as character no-undo .
define variable v-all-object              as logical   no-undo .
define variable t-str                     as character no-undo .
define variable str-obj#                  as character no-undo .
define variable str-obj2#                 as character no-undo .
define variable str-obj3#                 as character no-undo .
define variable v-curr-code               as integer   no-undo .
define variable schet-list                as character no-undo .
define variable init-shet-init            as character no-undo .
define variable v-curr-abbr               as character no-undo .
define variable mi-ed_date-alone-handle   as handle    no-undo .
define variable mi-ed_date-start-handle   as handle    no-undo .
define variable mi-ed_date-end-handle     as handle    no-undo .
define variable menu-ed_date-alone-handle   as handle    no-undo .
define variable menu-ed_date-start-handle   as handle    no-undo .
define variable menu-ed_date-end-handle     as handle    no-undo .
define variable keep-spis as character no-undo .
define variable choose-shift as logical no-undo init no .
define variable temp-param-goods-choose as character no-undo .
DEFINE BUTTON BUTTON-gds
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "BUTTON-gds"
     SIZE 3 BY .86.
DEFINE BUTTON BUTTON-keep-spis
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .86.
DEFINE BUTTON BUTTON-node
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "BUTTON-node"
     SIZE 3 BY .86.
DEFINE BUTTON BUTTON-node-2
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Button node 2"
     SIZE 3 BY .86
     BGCOLOR 3 .
DEFINE BUTTON BUTTON-obj
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "BUTTON-obj"
     SIZE 3 BY .86.
DEFINE BUTTON BUTTON-one
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Button one"
     SIZE 3 BY .86.
DEFINE BUTTON BUTTON-prod
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "BUTTON-prod"
     SIZE 3 BY .86.
DEFINE BUTTON BUTTON-prod-2
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Button prod 2"
     SIZE 3 BY .86
     BGCOLOR 4 .
DEFINE BUTTON BUTTON-schet
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .86.
DEFINE BUTTON BUTTON-schet-one
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .86.
DEFINE BUTTON BUTTON-schet-val
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .86.
DEFINE BUTTON BUTTON-shift
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .86 TOOLTIP "Выбор  смены на объекте"
     BGCOLOR 8 .
DEFINE BUTTON BUTTON-Shift-end
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .86 TOOLTIP "Выбор  смены на объекте"
     BGCOLOR 8 .
DEFINE BUTTON BUTTON-Shift-Start
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .86 TOOLTIP "Выбор  смены на объекте"
     BGCOLOR 8 .
DEFINE VARIABLE Radio-Period AS CHARACTER FORMAT "X(256)":U
     VIEW-AS COMBO-BOX INNER-LINES 14
     LIST-ITEM-PAIRS "За квартал (текущий)","1",
                     "За квартал (прошлый)","3"
     DROP-DOWN-LIST
     SIZE 52.6 BY 1
     BGCOLOR 15  NO-UNDO.
DEFINE VARIABLE customer-name AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 28.6 BY 2.52 TOOLTIP "Список выбранных Поставщиков"
     FONT 4 NO-UNDO.
DEFINE VARIABLE Goods-Editor AS CHARACTER
     VIEW-AS EDITOR MAX-CHARS 32000 SCROLLBAR-VERTICAL
     SIZE 33.4 BY 1.95
     FONT 4 NO-UNDO.
DEFINE VARIABLE lkp-schet AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 26 BY 1.95 TOOLTIP "Что выбрали"
     FONT 4 NO-UNDO.
DEFINE VARIABLE Date-Alone AS DATE FORMAT "99/99/9999":U
     LABEL "Дата"
     VIEW-AS FILL-IN
     SIZE 11 BY 1
     BGCOLOR 15  NO-UNDO.
DEFINE VARIABLE Date-End AS DATE FORMAT "99/99/9999":U
     LABEL "по"
     VIEW-AS FILL-IN NATIVE
     SIZE 11 BY 1
     BGCOLOR 15  NO-UNDO.
DEFINE VARIABLE Date-Start AS DATE FORMAT "99/99/9999":U
     LABEL "с"
     VIEW-AS FILL-IN NATIVE
     SIZE 11 BY 1
     BGCOLOR 15  NO-UNDO.
DEFINE VARIABLE Goods-count AS CHARACTER FORMAT "X(30)":U
      VIEW-AS TEXT
     SIZE 33.2 BY .67
     FGCOLOR 1 FONT 4 NO-UNDO.
DEFINE VARIABLE Obj-count AS CHARACTER FORMAT "X(30)":U
      VIEW-AS TEXT
     SIZE 24 BY .81
     FGCOLOR 1 FONT 4 NO-UNDO.
DEFINE VARIABLE Shift-Alone AS INTEGER FORMAT ">9":U INITIAL 1
     LABEL "смена"
     VIEW-AS FILL-IN
     SIZE 3 BY 1
     BGCOLOR 15  NO-UNDO.
DEFINE VARIABLE Shift-End AS INTEGER FORMAT ">9":U INITIAL 0
     LABEL "по"
     VIEW-AS FILL-IN NATIVE
     SIZE 3 BY 1
     BGCOLOR 15  NO-UNDO.
DEFINE VARIABLE Shift-Start AS INTEGER FORMAT ">9":U INITIAL 0
     LABEL "с"
     VIEW-AS FILL-IN NATIVE
     SIZE 3 BY 1
     BGCOLOR 15  NO-UNDO.
DEFINE VARIABLE TEXT-1 AS CHARACTER FORMAT "X(256)":U INITIAL "Выбор объекта"
      VIEW-AS TEXT
     SIZE 14 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE TEXT-2 AS CHARACTER FORMAT "X(256)":U INITIAL "Выбор товара"
      VIEW-AS TEXT
     SIZE 14 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE TEXT-3 AS CHARACTER FORMAT "X(256)":U INITIAL "Задание даты"
      VIEW-AS TEXT
     SIZE 14 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE TEXT-4 AS CHARACTER FORMAT "X(256)":U INITIAL "Выбор цен"
      VIEW-AS TEXT
     SIZE 14 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE text-5 AS CHARACTER FORMAT "X(256)":U INITIAL "Выбор поставщика"
      VIEW-AS TEXT
     SIZE 29.6 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE text-6 AS CHARACTER FORMAT "X(256)":U INITIAL "Выбор счета"
      VIEW-AS TEXT
     SIZE 15.6 BY .76
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE Radio-customer AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "все", 1,
"Выборочно", 2
     SIZE 25 BY 1 NO-UNDO.
DEFINE VARIABLE Radio-schet AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Все по фирме", 1,
"Своей фирмы", 2,
"Выборочно", 3,
"Один", 4,
"Все abbr_rublevye", 5,
"Все валютные", 6,
"По валюте", 7
     SIZE 15 BY 5.24 TOOLTIP "Выбор банковского счета" NO-UNDO.
DEFINE VARIABLE RADIO-task AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Календарные даты", 1,
"Сменные сутки", 2,
"Сменные сутки и порядок", 3,
"По сменам", 4
     SIZE 26 BY 3 NO-UNDO.
DEFINE VARIABLE SelectGood AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Все", 1,
"Группы товаров", 2,
"Производители", 3,
"Выборочно", 4,
"Один", 5,
"Хранимый список", 6,
"Гр. товаров + Производители", 7
     SIZE 29.8 BY 5.29
     BGCOLOR 8 FGCOLOR 0  NO-UNDO.
DEFINE VARIABLE SelectObject AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Все по фирме", "obj-firm",
"Текущий", "obj-currency",
"Выборочно", "obj-choice",
"Все", "all"
     SIZE 16.4 BY 2.76 NO-UNDO.
DEFINE VARIABLE SET_PAY_TYPE AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Продажные цены", 1,
"Учетные цены", 2,
"Цены документа", 3
     SIZE 19.2 BY 2.33 NO-UNDO.
DEFINE VARIABLE SET_val_TYPE AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "abbr_rub", 1,
"вал", 2,
"обе валюты", 3
     SIZE 26.2 BY 1.14 NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 59.8 BY 4.52.
DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 28.8 BY 4.52.
DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 25.8 BY 4.71.
DEFINE RECTANGLE RECT-4
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 34.2 BY 10.29
     BGCOLOR 8 FGCOLOR 0 .
DEFINE RECTANGLE RECT-7
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 28.6 BY 4.71.
DEFINE RECTANGLE RECT-node
     EDGE-PIXELS 1 GRAPHIC-EDGE
     SIZE 4 BY 1.19
     FGCOLOR 8 .
DEFINE RECTANGLE RECT-node-2
     EDGE-PIXELS 1 GRAPHIC-EDGE
     SIZE 4 BY 1.19
     BGCOLOR 8 FGCOLOR 8 .
DEFINE VARIABLE ShowCost AS LOGICAL INITIAL no
     LABEL "Учетные цены"
     VIEW-AS TOGGLE-BOX
     SIZE 18.8 BY .81 TOOLTIP "Показать суммы  в учетных ценах" NO-UNDO.
DEFINE VARIABLE ShowCrsa AS LOGICAL INITIAL no
     LABEL "Продажные цены"
     VIEW-AS TOGGLE-BOX
     SIZE 18.2 BY .81 TOOLTIP "Показать суммы  в продажных ценах" NO-UNDO.
DEFINE VARIABLE ShowSale AS LOGICAL INITIAL no
     LABEL "Цены документа"
     VIEW-AS TOGGLE-BOX
     SIZE 18.2 BY .81 TOOLTIP "Показать суммы  в ценах документа" NO-UNDO.
DEFINE VARIABLE TOG-Excel AS LOGICAL INITIAL yes
     LABEL "Есть экспорт в Excel"
     VIEW-AS TOGGLE-BOX
     SIZE 22.2 BY .81
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE TOG-list-hist AS LOGICAL INITIAL yes
     LABEL "Печать истории формир. списков"
     VIEW-AS TOGGLE-BOX
     SIZE 33.6 BY .81
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE TOG-Shift AS LOGICAL INITIAL yes
     LABEL "Смены"
     VIEW-AS TOGGLE-BOX
     SIZE 11.2 BY .81 NO-UNDO.
DEFINE VARIABLE TOG-Shift-2 AS LOGICAL INITIAL no
     LABEL "Одна смена"
     VIEW-AS TOGGLE-BOX
     SIZE 14.8 BY .81 NO-UNDO.
DEFINE FRAME F-Main
     Radio-Period AT ROW 2 COL 4 NO-LABEL WIDGET-ID 8
     TOG-Shift AT ROW 2 COL 32.2
     SET_PAY_TYPE AT ROW 2 COL 64.6 NO-LABEL
     Date-Alone AT ROW 2.05 COL 17.8 COLON-ALIGNED
     TOG-Shift-2 AT ROW 2.05 COL 44.8
     ShowCrsa AT ROW 2.1 COL 64.6
     RADIO-task AT ROW 2.24 COL 2 NO-LABEL
     ShowCost AT ROW 2.76 COL 64.6
     Shift-Alone AT ROW 2.95 COL 48.2 COLON-ALIGNED
     BUTTON-shift AT ROW 2.95 COL 53.4
     Shift-Start AT ROW 3.19 COL 30.6 COLON-ALIGNED
     BUTTON-Shift-Start AT ROW 3.24 COL 36 WIDGET-ID 2
     Shift-End AT ROW 3.24 COL 46.8 COLON-ALIGNED
     BUTTON-Shift-end AT ROW 3.24 COL 52 WIDGET-ID 6
     ShowSale AT ROW 3.43 COL 64.6
     Date-Start AT ROW 4.24 COL 30.6 COLON-ALIGNED
     Date-End AT ROW 4.24 COL 47 COLON-ALIGNED
     SET_val_TYPE AT ROW 4.24 COL 61.6 NO-LABEL
     SelectGood AT ROW 6.33 COL 1.8 NO-LABEL
     SelectObject AT ROW 6.52 COL 38.6 NO-LABEL
     Radio-customer AT ROW 6.52 COL 61.6 NO-LABEL
     BUTTON-node AT ROW 7.24 COL 31.6
     customer-name AT ROW 7.52 COL 61 NO-LABEL
     BUTTON-obj AT ROW 7.67 COL 56
     BUTTON-prod AT ROW 7.91 COL 31.6
     BUTTON-gds AT ROW 8.67 COL 31.6
     BUTTON-one AT ROW 9.48 COL 31.6
     BUTTON-keep-spis AT ROW 10.19 COL 31.6 WIDGET-ID 12
     Radio-schet AT ROW 11 COL 36 NO-LABEL
     BUTTON-node-2 AT ROW 11.81 COL 3.6
     BUTTON-prod-2 AT ROW 11.81 COL 7.6
     BUTTON-schet AT ROW 12.52 COL 55.2
     BUTTON-schet-one AT ROW 13.24 COL 55.2
     Goods-Editor AT ROW 13.62 COL 1 NO-LABEL
     BUTTON-schet-val AT ROW 15.52 COL 55.2
     lkp-schet AT ROW 16.52 COL 35.6 NO-LABEL
     TOG-Excel AT ROW 16.76 COL 1
     TOG-list-hist AT ROW 17.76 COL 1
     TEXT-3 AT ROW 1.29 COL 17.2 COLON-ALIGNED NO-LABEL
     TEXT-4 AT ROW 1.29 COL 68 COLON-ALIGNED NO-LABEL
     TEXT-2 AT ROW 5.67 COL 9 COLON-ALIGNED NO-LABEL
     text-5 AT ROW 5.76 COL 59.4 COLON-ALIGNED NO-LABEL
     TEXT-1 AT ROW 5.81 COL 39.6 COLON-ALIGNED NO-LABEL
     Obj-count AT ROW 9.24 COL 34.6 COLON-ALIGNED NO-LABEL
     text-6 AT ROW 10.24 COL 35 COLON-ALIGNED NO-LABEL
     Goods-count AT ROW 12.91 COL 1 NO-LABEL
     RECT-1 AT ROW 1 COL 1
     RECT-2 AT ROW 1 COL 60.8
     RECT-3 AT ROW 5.52 COL 35.2
     RECT-4 AT ROW 5.52 COL 1
     RECT-7 AT ROW 5.52 COL 61
     RECT-node AT ROW 11.05 COL 4.2
     RECT-node-2 AT ROW 11.05 COL 8.6
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1 SCROLLABLE
         BGCOLOR 8 FGCOLOR 0 .
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
      adm-object-hdl = FRAME F-Main:HANDLE.
RUN ensure-broker.
THIS-PROCEDURE:ADM-DATA =
     'ADM1.1~`':U +
     'SmartObject~`':U +
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
    DISABLE RECT-1 RECT-2 RECT-3 RECT-4 RECT-7 RECT-node RECT-node-2 Radio-Period TOG-Shift SET_PAY_TYPE Date-Alone TOG-Shift-2 ShowCrsa RADIO-task ShowCost Shift-Alone BUTTON-shift Shift-Start BUTTON-Shift-Start Shift-End BUTTON-Shift-end ShowSale Date-Start Date-End SET_val_TYPE SelectGood SelectObject Radio-customer BUTTON-node customer-name BUTTON-obj BUTTON-prod BUTTON-gds BUTTON-one BUTTON-keep-spis Radio-schet BUTTON-node-2 BUTTON-prod-2 Goods-Editor lkp-schet TOG-Excel TOG-list-hist TEXT-3 TEXT-4 TEXT-2 text-5 TEXT-1 Obj-count text-6 Goods-count WITH FRAME F-Main.
    RUN dispatch ('disable-fields':U).
    RUN set-attribute-list ('ENABLED=no':U).
    RETURN.
END PROCEDURE.
PROCEDURE adm-edit-attribute-list :
      RUN adm/support/viewerd.w (INPUT THIS-PROCEDURE).
      RETURN.
END PROCEDURE.
PROCEDURE adm-enable :
    ENABLE UNLESS-HIDDEN RECT-1 RECT-2 RECT-3 RECT-4 RECT-7 RECT-node RECT-node-2 Radio-Period TOG-Shift SET_PAY_TYPE Date-Alone TOG-Shift-2 ShowCrsa RADIO-task ShowCost Shift-Alone BUTTON-shift Shift-Start BUTTON-Shift-Start Shift-End BUTTON-Shift-end ShowSale Date-Start Date-End SET_val_TYPE SelectGood SelectObject Radio-customer BUTTON-node customer-name BUTTON-obj BUTTON-prod BUTTON-gds BUTTON-one BUTTON-keep-spis Radio-schet BUTTON-node-2 BUTTON-prod-2 Goods-Editor lkp-schet TOG-Excel TOG-list-hist TEXT-3 TEXT-4 TEXT-2 text-5 TEXT-1 Obj-count text-6 Goods-count WITH FRAME F-Main.
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
       BUTTON-gds:HIDDEN IN FRAME F-Main           = TRUE.
ASSIGN
       BUTTON-keep-spis:HIDDEN IN FRAME F-Main           = TRUE.
ASSIGN
       BUTTON-node:HIDDEN IN FRAME F-Main           = TRUE.
ASSIGN
       BUTTON-node-2:HIDDEN IN FRAME F-Main           = TRUE.
ASSIGN
       BUTTON-one:HIDDEN IN FRAME F-Main           = TRUE.
ASSIGN
       BUTTON-prod:HIDDEN IN FRAME F-Main           = TRUE.
ASSIGN
       BUTTON-prod-2:HIDDEN IN FRAME F-Main           = TRUE.
ASSIGN
  customer-name:READ-ONLY IN FRAME F-Main = TRUE.
ASSIGN
  Goods-Editor:READ-ONLY IN FRAME F-Main = TRUE.
ASSIGN
  lkp-schet:READ-ONLY IN FRAME F-Main = TRUE.
ASSIGN
  ShowCost:HIDDEN IN FRAME F-Main = TRUE.
ASSIGN
  ShowCrsa:HIDDEN IN FRAME F-Main = TRUE.
ASSIGN
  ShowSale:HIDDEN IN FRAME F-Main = TRUE.
ON CHOOSE OF BUTTON-gds IN FRAME F-Main
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
  if not params-only then
  do:
    for each gds-list :
      delete gds-list.
    end.
  end.
  if temp-param-goods-choose <> "" then
  do:
    run ref/gds-ref.p (
      input my-handle
      ,input "b-mark,b-sel"
      ,input 'все':U
      ,input "ptrlsug"
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
    end.
    if ref-list <> "" then
    do:
      v-recs = num-entries (ref-list).
      do num-rec = 0 to v-recs:
        if v-recs = 1 then
        do:
          num-rec = 1 .
        end.
        if num-rec > 0 then
        do:
          v-ref-rec = integer (entry (num-rec, ref-list)).
          find goods where recid (goods) = v-ref-rec no-lock.
          create gds-list .
          buffer-copy goods to gds-list .
        end.
        if v-recs = 1 then
        do:
          assign
            v-temp-seq = v-seq
            v-line     = 0
            dsp-rs     = substitute("Товар :&1 &2", goods.gds-name, stat-line(rs-status))
            v-item     = '':U
            v-tbl-name = 'goods':U
            v-bh       = buffer goods:handle
            v-tot-lns  = tot-lns
            .
        end.
        else
        do:
          if num-rec = 0 then
          do:
            assign
              v-temp-seq = v-seq
              v-line     = 0
              dsp-rs     = substitute("Товары : &1", stat-line(rs-status))
              v-item     = '':U
              v-tbl-name = '':U
              v-bh       = ?
              v-tot-lns  = tot-lns
              .
          end.
          else
          do:
            assign
              v-temp-seq = v-seq - 1
              v-line     = num-rec
              dsp-rs     = substitute("код &1 &2 &3&4 &5", goods.gds-code, goods.artic, goods.prod-type, goods.prod-code, goods.gds-name)
              v-item     = '':U
              v-tbl-name = 'goods':U
              v-bh       = buffer goods:handle
              v-tot-lns  = tot-lns + num-rec
              .
          end.
        end.
        v-no-hist = (if num-rec = 1 then 0 else num-rec).
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
  else
  do:
    run str/gds-list.w ( input my-handle, input v-cntxt-host-code-obj, input v-cntxt-obj-type, input v-cntxt-obj-code ).
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
ON CHOOSE OF BUTTON-keep-spis IN FRAME F-Main
  DO:
    for each gds-list :
      delete gds-list.
    end.
    keep-spis = "".
    define buffer buf_clob-bind for ub.clob-bind  .
    define variable v-rid-list as character no-undo .
run ref/clobbnds.w ( input my-handle
                    ,input this-procedure:handle
                    ,input 'b-sel'
                    ,input "uniq-key-rec"
                    ,input ""
                    ,input 'list':U
                    ,input 'gds-list'
                    ,input -1
                    ,input-output v-rid-list) no-error.
  find first buf_clob-bind no-lock where
            recid(buf_clob-bind) = integer(v-rid-list) no-error .
  if available buf_clob-bind then do:
    keep-spis = buf_clob-bind.field-name_ .
    lns-cnt = 1 .
    s-notes = substitute("Хранимый Файл списка : &1 &2", buf_clob-bind.field-name, buf_clob-bind.descr ).
  end.
  else do:
    keep-spis = "".
    lns-cnt = 0 .
    s-notes = " " .
  end.
    run new-state ("KEEP-SPIS="  + string(keep-spis)).
    run display-count in this-procedure .
    run display-count-other in this-procedure .
  END.
ON CHOOSE OF BUTTON-node IN FRAME F-Main
DO:
  run ref/gds-grp.w
   (             input my-handle
                ,input "b-sel,b-mark"
                ,input v-cntxt-obj-type
                ,input v-cntxt-obj-code
                ,input-output gdsgrp_recids ).
  run display-count-other in this-procedure .
END.
ON CHOOSE OF BUTTON-node-2 IN FRAME F-Main
DO:
  run ref/gds-grp.w
  (              input my-handle
                ,input "b-sel,b-mark"
                ,input v-cntxt-obj-type
                ,input v-cntxt-obj-code
                ,input-output gdsgrp_recids ).
  if num-entries(gdsgrp_recids) > 0
         then do:
            rect-node:bgcolor = 3 .
         end.
         else do:
            rect-node:bgcolor = 8 .
         end.
  run display-count-other in this-procedure  .
END.
ON CHOOSE OF BUTTON-obj IN FRAME F-Main
DO:
  assign SelectObject.
  my-request = false .
  run select-objects-proc in this-procedure .
END.
ON CHOOSE OF BUTTON-one IN FRAME F-Main
DO:
  define variable ri-list         as char no-undo .
  define buffer buf_goods for ub.goods .
  run ref/gds-ref.p
    ( my-handle
      ,'b-sel'
      ,?
      ,?
      ,?
      ,?
      ,?
      ,?
      ,?
      ,v-cntxt-obj-type
      ,v-cntxt-obj-code
      ,?
      , output ri-list) .
  for each gds-list :
     delete gds-list.
  End.
  If ri-list <> "" then DO:
     find first buf_goods where recid(buf_goods) = integer (ri-list) no-lock.
     buffer-copy buf_goods TO gds-list no-error.
     run display-count-other in this-procedure .
  End.
END.
ON CHOOSE OF BUTTON-prod IN FRAME F-Main
DO:
  define variable v-ind as integer   no-undo .
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
            if cli-grp_recids = "" then do:
                 Assign goods-count = '' Goods-Editor = ''.
                 Display goods-count Goods-Editor with frame F-Main .
            end.
            else do:
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
    else do:
       FOR EACH g#cli :
            delete g#cli .
        END .
        cli-grp_recids = "" .
    end.
run display-count-other in this-procedure .
END.
ON CHOOSE OF BUTTON-prod-2 IN FRAME F-Main
DO  :
  define variable v-ind as integer   no-undo .
  define buffer cli-prod for ub.clients .
  define variable cli-grp_recids as character no-undo .
          FOR EACH g#cli :
            delete g#cli .
           END .
     if SelectGood:screen-value = "7" then
        do with frame F-Main:
          run ref/cli-all.w
            (  my-handle
            ,  "b-sel,b-mark"
            ,  'про':U
            ,  'все':U
            ,  'текущие':U
            ,  ?
            ,  ",,,,,,NO,,"
            , ?
            , output cli-grp_recids ) .
            if cli-grp_recids = "" then do:
                 Assign goods-count = '' Goods-Editor = ''.
                 Display goods-count Goods-Editor with frame F-Main .
            end.
            else do:
                DO v-ind = 1 TO num-entries( cli-grp_recids ) :
                    FIND cli-prod WHERE recid( cli-prod ) = int( entry(v-ind, cli-grp_recids ) ) NO-LOCK.
                    create g#cli.
                    assign
                    g#cli.obj-type = cli-prod.obj-type
                    g#cli.obj-code = cli-prod.obj-code
                    g#cli.obj-name = cli-prod.obj-name.
                END.
            end.
            RECT-node-2:bgcolor = 3 .
        end.
    else do:
       FOR EACH g#cli :
            delete g#cli .
        END .
        cli-grp_recids = "" .
        RECT-node-2:bgcolor = 8 .
    end.
 if not can-find (first g#cli no-lock )  then  RECT-node-2:bgcolor = 8 .
run display-count-other in this-procedure  .
END.
ON CHOOSE OF BUTTON-schet IN FRAME F-Main
DO:
define variable v-status_ like ub.fin-schet.status_ no-undo init 'тек':U.
 schet-list = "" .
  assign radio-schet.
       run ref/finschts.w
       (   input my-handle,
           input v-cntxt-host-code-obj,
           input "b-mark,b-sel",
           input temp-param-schet-mode,
           input ?,
           input ?,
           input 0,
           input v-cntxt-host-code-obj ,
           input 0,
           input-output v-status_,
           input-output schet-list).
      if  schet-list = "" then do:
         define variable var-ll as integer no-undo .
         repeat var-ll = 7 to 1 by -1 :
            if lookup( string(var-ll) , temp-param-schet-hide) <> 0 then next.
            radio-schet = var-ll .
         end.
         display RADIO-schet with frame F-Main .
         run select-radio-schet-no-apply in this-procedure .
     end.
 fin-schet-recid =  schet-list .
END.
ON CHOOSE OF BUTTON-schet-one IN FRAME F-Main
DO:
 define variable v-status_ like ub.fin-schet.status_ no-undo init 'тек':U.
 define buffer buf_fin-schet for ub.fin-schet.
  schet-list          = "" .
 if temp-param-schet-init <> "" and temp-param-schet-init <> ? then do:
      find first buf_fin-schet no-lock where
        buf_fin-schet.code-schet = integer (temp-param-schet-init) and
        buf_fin-schet.host-code  = v-cntxt-host-code-obj no-error .
      if available buf_fin-schet then
        assign
          schet-list = string(recid(buf_fin-schet))
          v-status_  = buf_fin-schet.status_
          .
    end.
    run ref/finschts.w
      (   input my-handle,
      input v-cntxt-host-code-obj,
      input "b-sel",
      input temp-param-schet-mode,
      input ?,
      input ?,
      input 0,
      input v-cntxt-host-code-obj ,
      input 0,
      input-output v-status_,
      input-output schet-list).
    fin-schet-recid =  schet-list .
    if num-entries(schet-list) > 1 then
    do:
      message "Можно выбрать только один счет !!!" view-as alert-box .
      return no-apply.
    end.
    find first buf_fin-schet no-lock where    recid(buf_fin-schet) = integer (schet-list)   no-error .
    if not available buf_fin-schet
      then
    do :
      define variable var-ll as integer no-undo .
      repeat var-ll = 7 to 1 by -1 :
        if lookup( string(var-ll) , temp-param-schet-hide) <> 0 then next.
        radio-schet = var-ll .
      end.
    display RADIO-schet with frame F-Main .
    run select-radio-schet-no-apply in this-procedure .
  end.
  else do:
    lkp-schet = "Выбран счет  " +  string( buf_fin-schet.code-schet) .
    display lkp-schet with frame F-Main .
  end.
  if radio-schet = 4 then do:
    define variable v-code-schet as integer no-undo .
    if available buf_Fin-schet then do:
      assign
      v-code-schet = buf_fin-schet.code-schet.
    end.
    if ref_date-start <> '':u
    and entry(2, ref_date-start, chr(4)) = "finsttms":U then do:
      entry(3, ref_date-start, chr(4)) = "code-schet-start".
      entry(4, ref_date-start, chr(4)) = string(v-code-schet).
    end.
    if ref_date-end <> '':u
    and entry(2, ref_date-end, chr(4)) = "finsttms":U then do:
      entry(3, ref_date-end, chr(4)) = "code-schet-end".
      entry(4, ref_date-end, chr(4)) = string(v-code-schet).
    end.
    if ref_date-alone <> '':u
    and entry(2, ref_date-alone, chr(4)) = "finsttms":U then do:
      entry(3, ref_date-alone, chr(4)) = "code-schet-end1".
      entry(4, ref_date-alone, chr(4)) = string(v-code-schet).
    end.
  end.
  END.
ON CHOOSE OF BUTTON-schet-val IN FRAME F-Main
DO:
  define variable ref-rec as recid no-undo.
  define buffer buf_currency for ub.currency .
  v-curr-abbr =  "" .
    run ref/currency.w ( my-handle, "b-sel", input-output ref-rec ).
    if ref-rec = ? then
    do:
      define variable var-ll as integer no-undo .
      repeat var-ll = 7 to 1 by -1 :
        if lookup( string(var-ll) , temp-param-schet-hide) <> 0 then next.
        radio-schet = var-ll .
      end.
      display RADIO-schet with frame F-Main .
      run select-radio-schet-no-apply in this-procedure .
    end.
    else
    do:
      find currency where recid ( currency ) = ref-rec no-lock.
      assign
        v-curr-code = currency.curr-code
        schet-list  = "curr-code=" + string(currency.curr-code)
        v-curr-abbr = currency.curr-abbr
        lkp-schet   = temp-param-schet + " по : " + currency.curr-abbr
        .
      display lkp-schet with frame F-Main .
    end.
  END.
ON CHOOSE OF BUTTON-shift IN FRAME F-Main
DO:
  define variable v-doc-rec as recid no-undo.
  define variable rec-list-2 as character no-undo.
  define buffer buf_shift-obj for ub.shift-obj .
  IF  SelectObject:screen-value = "currency":U then do:
    find first buf_shift-obj No-LOCK WHERE
              buf_shift-obj.shift-date = date-start AND
              buf_shift-obj.shift-num = shift-alone AND
              buf_shift-obj.obj-type = v-cntxt-obj-type AND
              buf_shift-obj.obj-code = v-cntxt-obj-code No-ERROR.
    if available buf_shift-obj then
      rec-list-2 = string(recid(buf_shift-obj)).
  end.
  IF  SelectObject:screen-value = "currency":U
  then do:
      run str/sht-all.w
      (             input my-handle
                   ,input v-cntxt-obj-type
                   ,input v-cntxt-obj-code
                   ,input  "b-sel"
                   ,input "obj":U
                   ,input v-cntxt-obj-type
                   ,input v-cntxt-obj-code
                   ,input ReportProc
                   ,input-output rec-list-2 ).
  end.
  Else do:
      run str/sht-all.w
      (             input my-handle
                   ,input v-cntxt-obj-type
                   ,input v-cntxt-obj-code
                   ,input  "b-sel"
                   ,input "all":U
                   ,input '':U
                   ,input 0
                   ,input ReportProc
                   ,input-output rec-list-2 ).
    end.
    find first buf_shift-obj where recid (buf_shift-obj) = integer (entry(1,rec-list-2))  no-lock no-error.
    if available buf_shift-obj then DO:
       Assign
        date-start  = buf_shift-obj.shift-date
        shift-alone = buf_shift-obj.shift-num.
         enable date-start  shift-alone with frame F-Main.
       Display date-start  shift-alone with frame F-Main.
        apply "leave" to shift-alone .
        apply "leave" to date-start .
    End.
 END.
ON CHOOSE OF BUTTON-Shift-end IN FRAME F-Main
DO:
  define variable v-doc-rec as recid no-undo .
  define variable rec-list-2      as char no-undo.
  define buffer buf_shift-obj for ub.shift-obj .
  IF  SelectObject:screen-value = "currency":U then do:
    find first buf_shift-obj No-LOCK WHERE
              buf_shift-obj.shift-date = date-end AND
              buf_shift-obj.shift-num = shift-end AND
              buf_shift-obj.obj-type = v-cntxt-obj-type AND
              buf_shift-obj.obj-code = v-cntxt-obj-code No-ERROR.
    if available buf_shift-obj then
    rec-list-2 = string(recid(buf_shift-obj)).
  end.
  IF  SelectObject:screen-value = "currency":U
  then do:
      run str/sht-all.w
      (             input my-handle
                   ,input v-cntxt-obj-type
                   ,input v-cntxt-obj-code
                   ,input  "b-sel"
                   ,input "obj":U
                   ,input v-cntxt-obj-type
                   ,input v-cntxt-obj-code
                   ,input ReportProc
                   ,input-output rec-list-2 ).
  end.
  Else do:
      run str/sht-all.w
      (             input my-handle
                   ,input v-cntxt-obj-type
                   ,input v-cntxt-obj-code
                   ,input  "b-sel"
                   ,input "all":U
                   ,input '':U
                   ,input 0
                   ,input ReportProc
                   ,input-output rec-list-2 ).
    end.
    find first buf_shift-obj where recid (buf_shift-obj) = integer (entry(1,rec-list-2))  no-lock no-error.
    if available buf_shift-obj then DO:
       Assign
        date-end  = buf_shift-obj.shift-date
        shift-end = buf_shift-obj.shift-num.
       enable date-end  shift-end with frame F-Main.
       Display date-end  shift-end with frame F-Main.
        apply "leave" to shift-end .
        apply "leave" to date-end .
    End.
 END.
ON CHOOSE OF BUTTON-Shift-Start IN FRAME F-Main
DO:
  define variable v-doc-rec as recid no-undo .
  define variable rec-list-2      as char no-undo.
  define buffer buf_shift-obj for ub.shift-obj .
  IF  SelectObject:screen-value = "currency":U then do:
    find first buf_shift-obj No-LOCK WHERE
              buf_shift-obj.shift-date = date-start AND
              buf_shift-obj.shift-num = shift-start AND
              buf_shift-obj.obj-type = v-cntxt-obj-type AND
              buf_shift-obj.obj-code = v-cntxt-obj-code No-ERROR.
    if available buf_shift-obj then
    rec-list-2 = string(recid(buf_shift-obj)).
  end.
  IF  SelectObject:screen-value = "currency":U
  then do:
      run str/sht-all.w
      (             input my-handle
                   ,input v-cntxt-obj-type
                   ,input v-cntxt-obj-code
                   ,input  "b-sel"
                   ,input "obj":U
                   ,input v-cntxt-obj-type
                   ,input v-cntxt-obj-code
                   ,input ReportProc
                   ,input-output rec-list-2 ).
  end.
  Else do:
      run str/sht-all.w
        (             input my-handle
        ,input v-cntxt-obj-type
        ,input v-cntxt-obj-code
        ,input  "b-sel"
        ,input "all":U
        ,input '':U
        ,input 0
        ,input ReportProc
        ,input-output rec-list-2 ).
    end.
    find shift-obj where recid (shift-obj) = integer (entry(1,rec-list-2))  no-lock no-error.
    if AVAILABLE  shift-obj then
    DO:
      Assign
        date-start  = shift-obj.shift-date
        shift-start = shift-obj.shift-num.
      enable date-start  shift-start with frame F-Main.
      Display date-start  shift-start with frame F-Main.
        if TOG-Shift-2 then do:
            assign
             Date-End = Date-Start
             Shift-End = Shift-Start
             Date-End:SCREEN-VALUE = string(Date-Start)
             Shift-End:SCREEN-VALUE = string(Shift-Start)
             x-Date-End  = Date-End
             x-Shift-End = Shift-End
            .
    Display date-end  shift-end with frame F-Main.
        end.
      apply "leave" to shift-start .
      apply "leave" to date-start .
    End.
 END.
ON LEAVE OF Date-Alone IN FRAME F-Main
DO:
  Assign Date-Alone no-error.
  x-date-start = Date-Alone.
  x-date-end = Date-Alone.
  x-date-alone = Date-Alone.
  run new-state ("DATE-ALONE="  + String(DATE-ALONE:screen-value)).
END.
ON LEAVE OF Date-End IN FRAME F-Main
DO:
    Assign  Date-End no-error.
    X-Date-End       = Date-End.
    run verify-date in this-procedure .
    run new-state ("DATE-END="  + String(DATE-END:screen-value)).
END.
ON LEAVE OF Date-Start IN FRAME F-Main
DO:
    Assign  Date-Start no-error.
    X-Date-Start     = Date-Start.
    run new-state ("DATE-START="  + String(DATE-START:screen-value)).
END.
ON VALUE-CHANGED OF Radio-customer IN FRAME F-Main
DO:
    Assign
      Radio-customer
    .
DEFINE VARIABLE customer-recids AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-ii AS integer NO-UNDO.
define buffer buf_clients for ub.clients.
for each g#customer : delete g#customer. end.
  Case Radio-customer :
  when 1 then DO:
          Assign  customer-name = 'все':U.
          Display customer-name with frame F-Main .
       END.
  when 2 then
        do:
            if temp-param-customer-type  = "" then temp-param-customer-type = 'все':U.
            run str/cli-list.w
                         ( my-handle
                         , v-cntxt-host-code-obj
                         , v-cntxt-obj-type
                         , v-cntxt-obj-code
                            ) .
            if not can-find (first cli-list no-lock ) then do:
                 Assign  customer-name = 'все':U Radio-customer = 1.
                 Display customer-name Radio-customer with frame F-Main .
            end.
            else do:
                Assign  customer-name = ''.
                for each cli-list  :
                    create g#customer.
                    assign
                    g#customer.obj-type = cli-list.obj-type
                    g#customer.obj-code = cli-list.obj-code
                    g#customer.obj-name = cli-list.obj-name.
                    if LENGTH (customer-name) >= 10000 then do:
                       customer-name = trim(customer-name , '...') .
                       customer-name = customer-name + '...' .
                    end.
                    else customer-name = customer-name + cli-list.obj-name + chr(10).
                END.
                 Display customer-name with frame F-Main .
            end.
        end.
  End case.
  run new-state ("RADIO-CUSTOMER="  + string(Radio-customer)).
  END.
ON VALUE-CHANGED OF Radio-Period IN FRAME F-Main
DO:
  assign radio-period.
END.
ON VALUE-CHANGED OF Radio-schet IN FRAME F-Main
DO:
 Assign Radio-schet.
 display Radio-schet with frame F-Main .
 run select-radio-schet in this-procedure .
END.
ON VALUE-CHANGED OF RADIO-task IN FRAME F-Main
DO:
Assign RADIO-task Date-End Date-Start shift-end shift-start.
x-RADIO-task  = RADIO-task.
x-Date-End    = Date-End .
x-Date-Start  = Date-Start.
x-shift-End   = shift-End .
x-shift-Start = shift-Start.
x-shift-alone = shift-alone.
run display-radio-task in this-procedure .
run new-state ( "RADIO-TASK="  + String(RADIO-TASK:screen-value)).
END.
ON VALUE-CHANGED OF SelectGood IN FRAME F-Main
DO:
  run val-goods in this-procedure .
  RUN new-state ("SELECTGOOD="  + String(SelectGood:screen-value)).
END.
ON VALUE-CHANGED OF SelectObject IN FRAME F-Main
DO:
Assign SelectObject.
run select-objects-proc in this-procedure .
run val-obj in this-procedure .
run new-state ("SELECTOBJECT="  + SelectObject).
END.
ON VALUE-CHANGED OF SET_PAY_TYPE IN FRAME F-Main
DO:
    Assign SET_PAY_TYPE.
            X-SET_PAY_TYPE   = SET_PAY_TYPE.
   run set_val in this-procedure .
   run new-state ( "SET_PAY_TYPE ="  + String(SET_PAY_TYPE:screen-value)).
END.
ON VALUE-CHANGED OF SET_val_TYPE IN FRAME F-Main
DO:
  assign
    SET_val_TYPE
  .
  x-SET_val_TYPE = SET_val_TYPE.
    if Verify-Arc-stk then do:
      If var-report-r-b = "base" then do:
        if X-SET_val_TYPE = 1 and base-code <> 0
        then message
            "В валютной версии программы при базовой валюте, не равной рубл. - " skip
            "в колонках остатки по товару и автоматическая переоценка не будет учтена курсовая" skip
            "разница при печати отчета в продажных ценах и рублях. "
            view-as alert-box information Title "В н и м а н и е".
      end.
      else do:
      end.
    end.
  run new-state ("SET_VAL_TYPE="  + String(SET_VAL_TYPE:screen-value)).
END.
ON LEAVE OF Shift-Alone IN FRAME F-Main
  DO:
    Assign Shift-Alone Shift-End Shift-start.
    X-Shift-Alone   = Shift-Alone.
    X-Shift-End     = Shift-Alone.
    X-Shift-start   = Shift-alone.
    Shift-End       = Shift-Alone.
    Shift-start     = Shift-alone.
    if Shift-End:visible in frame F-Main    then   display Shift-end with frame F-Main .
    if Shift-start:visible in frame F-Main  then   display Shift-start with frame F-Main .
    display Shift-Alone with frame F-Main .
    run new-state ("SHIFT-ALONE="  + String(SHIFT-Alone:screen-value)).
  END.
ON LEAVE OF Shift-End IN FRAME F-Main
  DO:
    Assign Shift-End.
    X-Shift-End  = Shift-End.
    run new-state ( "SHIFT-END="  + String(SHIFT-END:screen-value)).
  END.
ON LEAVE OF Shift-Start IN FRAME F-Main
  DO:
    Assign Shift-Start.
    X-Shift-Start = Shift-Start.
    run new-state ( "SHIFT-START="  + String(SHIFT-START:screen-value)).
  END.
ON VALUE-CHANGED OF TOG-Excel IN FRAME F-Main
  DO:
    Assign Tog-Excel.
    If Tog-Excel Then Make-Excel = True.
    Else Make-Excel = False.
    run new-state ( "TOG-EXCEL ="  + String(Tog-Excel)).
  END.
ON VALUE-CHANGED OF TOG-list-hist IN FRAME F-Main
  DO:
    Assign Tog-list-hist.
    If Tog-list-hist Then print-list-hist = True.
    Else print-list-hist = False.
    run new-state ("TOG-list-hist ="  + String(Tog-list-hist)).
  END.
ON VALUE-CHANGED OF TOG-Shift IN FRAME F-Main
  DO:
    assign TOG-Shift .
    run val-shift  in this-procedure .
    if tog-shift:screen-value = string(true) then tog-shift = true .
    else tog-shift = false .
    if tog-shift = false  then x-tog-shift   = false .
    else x-tog-shift   = true .
    RUN new-state ("TOG-SHIFT ="  + String(Tog-SHIFT:screen-value)).
  END.
ON VALUE-CHANGED OF TOG-Shift-2 IN FRAME F-Main
DO:
  define buffer buf_shift-obj for ub.shift-obj .
Assign TOG-Shift-2.
Date-End:screen-value IN frame F-Main  = Date-Start:screen-value IN frame F-Main.
Shift-End:screen-value IN frame F-Main = Shift-Start:screen-value IN frame F-Main.
Date-End  = date (Date-Start:screen-value IN frame F-Main).
Shift-End = integer(Shift-Start:screen-value IN frame F-Main).
x-Date-End  = DAte(Date-Start:screen-value IN frame F-Main).
x-Shift-End = integer(Shift-Start:screen-value IN frame F-Main).
if TOG-Shift-2 then
    do:
        disable
            Date-End
            shift-end
        with frame F-Main.
    end.
else
    do:
        enable
            Date-End
            shift-end
        with frame F-Main.
    end.
Display Date-End shift-end with frame F-Main.
if can-find(first buf_shift-obj where buf_shift-obj.obj-code = v-cntxt-obj-code and
    buf_shift-obj.obj-type = v-cntxt-obj-type no-lock) then
        do:
            if tog-shift-2 then
                do:
                    disable button-shift-end with frame F-Main .
                end.
            else
                do:
                    enable button-shift-end with frame F-Main .
                end.
            display button-shift-end with frame F-Main .
        end.
END.
if not this-procedure :persistent
then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при запуске процедуры" skip
    "Данную процедуру следует запускать только с параметром persistent" skip
    view-as alert-box error .
  undo, return error .
end.
  define variable v-r-b as character no-undo .
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-r-b
  )  .
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of date-Alone in frame F-Main
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on delete-character of date-Alone in frame F-Main
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on ctrl-d of date-Alone in frame F-Main
do:
  define variable v-curr-sv-date as date no-undo .
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    run gbl/getcurdt.p
      (output v-curr-sv-date
      ) .
    assign
      self :screen-value = string(v-curr-sv-date) .
    .
  end.
  return no-apply.
end.
on ctrl-b of date-Alone in frame F-Main
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      assign
        v-new-sv-date = date( month(v-curr-sv-date), 1, year(v-curr-sv-date))
      .
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-e of date-Alone in frame F-Main
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/lastdate.p
        (input  v-curr-sv-date
        ,output v-new-sv-date
        ).
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-f of date-Alone in frame F-Main
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-ok            as logical   no-undo .
    define variable v-curr-sv-date  as date      no-undo .
    define variable v-description   as character no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/d-inpday.w
        (input ?
        ,input "Выбор даты"
        ,input v-description
        ,input ""
        ,input-output v-curr-sv-date
        ,output v-ok
        ).
      if v-ok = true
      then do:
        assign
          self :screen-value = string(v-curr-sv-date) .
        .
      end.
    end.
  end.
  return no-apply .
end.
  define MENU m-ed-date21
    MENU-ITEM m-ed-date21-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date21-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date21-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date21-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
    menu-ed_date-alone-handle = MENU m-ed-date21:handle.
  if date-Alone :POPUP-MENU in frame F-Main = ?
  then do:
    ASSIGN
      date-Alone :POPUP-MENU in frame F-Main = MENU m-ed-date21 :HANDLE
      date-Alone :MENU-MOUSE in frame F-Main = 3
    .
  end.
  define variable v-label-handle21 as handle no-undo .
  assign
    v-label-handle21 = date-Alone :side-label-handle in frame F-Main
  .
  if valid-handle (v-label-handle21)
  then do:
    if v-label-handle21 :tooltip = ""
    or v-label-handle21 :tooltip = ?
    then do:
      assign
        v-label-handle21 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date21-1 in menu m-ed-date21 DO:
    apply "ctrl-b":U to date-Alone in frame F-Main .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date21-2 in menu m-ed-date21 DO:
    apply "ctrl-d":U to date-Alone in frame F-Main .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date21-3 in menu m-ed-date21 DO:
    apply "ctrl-e":U to date-Alone in frame F-Main .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date21-4 in menu m-ed-date21 DO:
    apply "ctrl-f":U to date-Alone in frame F-Main .
  END.
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of date-End in frame F-Main
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on delete-character of date-End in frame F-Main
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on ctrl-d of date-End in frame F-Main
do:
  define variable v-curr-sv-date as date no-undo .
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    run gbl/getcurdt.p
      (output v-curr-sv-date
      ) .
    assign
      self :screen-value = string(v-curr-sv-date) .
    .
  end.
  return no-apply.
end.
on ctrl-b of date-End in frame F-Main
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      assign
        v-new-sv-date = date( month(v-curr-sv-date), 1, year(v-curr-sv-date))
      .
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-e of date-End in frame F-Main
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/lastdate.p
        (input  v-curr-sv-date
        ,output v-new-sv-date
        ).
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-f of date-End in frame F-Main
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-ok            as logical   no-undo .
    define variable v-curr-sv-date  as date      no-undo .
    define variable v-description   as character no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/d-inpday.w
        (input ?
        ,input "Выбор даты"
        ,input v-description
        ,input ""
        ,input-output v-curr-sv-date
        ,output v-ok
        ).
      if v-ok = true
      then do:
        assign
          self :screen-value = string(v-curr-sv-date) .
        .
      end.
    end.
  end.
  return no-apply .
end.
  define MENU m-ed-date23
    MENU-ITEM m-ed-date23-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date23-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date23-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date23-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
    menu-ed_date-end-handle = MENU m-ed-date23:handle.
  if date-End :POPUP-MENU in frame F-Main = ?
  then do:
    ASSIGN
      date-End :POPUP-MENU in frame F-Main = MENU m-ed-date23 :HANDLE
      date-End :MENU-MOUSE in frame F-Main = 3
    .
  end.
  define variable v-label-handle23 as handle no-undo .
  assign
    v-label-handle23 = date-End :side-label-handle in frame F-Main
  .
  if valid-handle (v-label-handle23)
  then do:
    if v-label-handle23 :tooltip = ""
    or v-label-handle23 :tooltip = ?
    then do:
      assign
        v-label-handle23 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date23-1 in menu m-ed-date23 DO:
    apply "ctrl-b":U to date-End in frame F-Main .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date23-2 in menu m-ed-date23 DO:
    apply "ctrl-d":U to date-End in frame F-Main .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date23-3 in menu m-ed-date23 DO:
    apply "ctrl-e":U to date-End in frame F-Main .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date23-4 in menu m-ed-date23 DO:
    apply "ctrl-f":U to date-End in frame F-Main .
  END.
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of date-Start in frame F-Main
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on delete-character of date-Start in frame F-Main
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on ctrl-d of date-Start in frame F-Main
do:
  define variable v-curr-sv-date as date no-undo .
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    run gbl/getcurdt.p
      (output v-curr-sv-date
      ) .
    assign
      self :screen-value = string(v-curr-sv-date) .
    .
  end.
  return no-apply.
end.
on ctrl-b of date-Start in frame F-Main
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      assign
        v-new-sv-date = date( month(v-curr-sv-date), 1, year(v-curr-sv-date))
      .
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-e of date-Start in frame F-Main
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/lastdate.p
        (input  v-curr-sv-date
        ,output v-new-sv-date
        ).
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-f of date-Start in frame F-Main
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-ok            as logical   no-undo .
    define variable v-curr-sv-date  as date      no-undo .
    define variable v-description   as character no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/d-inpday.w
        (input ?
        ,input "Выбор даты"
        ,input v-description
        ,input ""
        ,input-output v-curr-sv-date
        ,output v-ok
        ).
      if v-ok = true
      then do:
        assign
          self :screen-value = string(v-curr-sv-date) .
        .
      end.
    end.
  end.
  return no-apply .
end.
  define MENU m-ed-date25
    MENU-ITEM m-ed-date25-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date25-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date25-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date25-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
    menu-ed_date-start-handle = MENU m-ed-date25:handle.
  if date-Start :POPUP-MENU in frame F-Main = ?
  then do:
    ASSIGN
      date-Start :POPUP-MENU in frame F-Main = MENU m-ed-date25 :HANDLE
      date-Start :MENU-MOUSE in frame F-Main = 3
    .
  end.
  define variable v-label-handle25 as handle no-undo .
  assign
    v-label-handle25 = date-Start :side-label-handle in frame F-Main
  .
  if valid-handle (v-label-handle25)
  then do:
    if v-label-handle25 :tooltip = ""
    or v-label-handle25 :tooltip = ?
    then do:
      assign
        v-label-handle25 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date25-1 in menu m-ed-date25 DO:
    apply "ctrl-b":U to date-Start in frame F-Main .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date25-2 in menu m-ed-date25 DO:
    apply "ctrl-d":U to date-Start in frame F-Main .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date25-3 in menu m-ed-date25 DO:
    apply "ctrl-e":U to date-Start in frame F-Main .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date25-4 in menu m-ed-date25 DO:
    apply "ctrl-f":U to date-Start in frame F-Main .
  END.
procedure proc-mi-ed_date :
    define variable v-widget-ref as character no-undo .
    if (can-query (self, "sensitive")
        and
        self :sensitive = true
        )
        or (can-query (self, "read-only")
        and
        self :read-only = false
        )
        then
    do:
        if self :handle <> focus :handle
            then
        do:
            apply "entry":u to self .
        end.
    define variable v-curr-sv-date  as date      no-undo .
        assign
            v-curr-sv-date = date(self :screen-value) no-error
            .
        case self:handle:
            when mi-ed_date-alone-handle then
                do:
                    v-widget-ref = ref_date-alone.
                end.
            when mi-ed_date-start-handle then
                do:
                    v-widget-ref = ref_date-start.
                end.
            when mi-ed_date-end-handle then
                do:
                    v-widget-ref = ref_date-end.
                end.
        end case.
        assign
            v-widget-ref = substring(v-widget-ref, index(v-widget-ref, chr(4)) + 1).
        run gbl/getrefdt.p
            ( input my-handle
            ,input v-widget-ref
            ,input-output v-curr-sv-date
            ) no-error .
    end.
    return.
end procedure.
assign
  Radio-period :LIST-ITEM-PAIRS in frame F-Main = 'Год,year,Год (прошлый),year-last,Полугодие,halfyear,Полугодие (прошлое),halfyear-last,Квартал,quarter,Квартал (прошлый),quarter-last,Месяц,month,Месяц (прошлый),month-last,Неделя,week,Неделя (прошлая),week-last,День,day,Вчера,yesterday,Час (текущий),hour,Час (прошлый),hour-last,Смена,shift,Смена (прошлая),shift-last':U
  Radio-schet  :radio-buttons   in frame F-Main = "Все по фирме,1,Своей фирмы,2,Выборочно,3,Один,4,Все рублевые,5,Все валютные,6,По валюте,7"
  SET_val_TYPE :radio-buttons in frame F-Main   = "руб,1,вал,2,обе валюты,3"
  .
if v-r-b = 'base':U
  then
do:
  assign
    SET_val_TYPE = 2 .
  display  set_val_type with frame F-Main .
end.
PROCEDURE Assign-frame :
  define variable L#obj-code like obj-list.obj-code no-undo.
  define variable l#obj-type like obj-list.obj-type no-undo.
    define buffer cli-obj   for ub.clients .
    define buffer o-clients for ub.clients.
    Assign frame F-Main
        Date-Alone Date-End Date-Start Goods-count
        Goods-Editor Obj-count SelectGood SelectObject
        SET_PAY_TYPE SET_val_TYPE Shift-Alone
        Shift-End Shift-Start TEXT-1 TEXT-2 TEXT-3 TEXT-4 TOG-Shift
        RADIO-task Tog-Excel tog-list-hist tog-shift-2 showcost showcrsa showsale
        RADIO-period
  no-error.
  if  temp-param-date = 8  or temp-param-date = 7 then  tog-shift = true .
  if  tog-shift AND tog-shift-2 THEN
    Assign
      Date-End  = Date-start
      Shift-End = Shift-Start.
  If Tog-Excel Then Make-Excel = True.
  Else Make-Excel = False.
  If Tog-list-hist Then Print-List-Hist = True.
  Else Print-List-Hist = False.
Assign
  X-Date-Alone     = Date-Alone
  X-Date-End       = Date-End
  X-Date-Start     = Date-Start
  X-Goods-Editor   = Goods-Editor
  X-SelectGood     = SelectGood
  X-SelectObject   = SelectObject
  X-SET_PAY_TYPE   = SET_PAY_TYPE
  X-SET_val_TYPE   = SET_val_TYPE
  X-Shift-Alone    = Shift-Alone
  X-Shift-End      = Shift-End
  X-Shift-Start    = Shift-Start
  X-TEXT-1         = TEXT-1
  X-TEXT-2         = TEXT-2
  X-TEXT-3         = TEXT-3
  X-TEXT-4         = TEXT-4
  X-TOG-Shift      = TOG-Shift
  x-RADIO-task     = RADIO-task
  show-cost  = showcost
  show-crsa  = showcrsa
  show-sale  = showsale
  fin-schet-recid =  schet-list
    .
if Date-Alone:visible and date-end:visible = false then do:
   x-date-start = Date-Alone .
   x-date-end   = Date-Alone   .
end.
if RADIO-task = 4 then
assign
  X-Shift-End      = X-Shift-Alone
  X-Shift-Start    = X-Shift-Alone
  .
 Assign
 L#obj-code=0
 l#obj-type="".
  for each obj-list  by obj-list.obj-code by obj-list.obj-type :
      find first  o-clients where
      o-clients.obj-code = obj-list.obj-code and
      o-clients.obj-type = obj-list.obj-type  no-lock no-error .
      Assign obj-list.obj-name = if avail o-clients then  o-clients.obj-name else "".
     if obj-list.obj-code = L#obj-code and
        obj-list.obj-type = l#obj-type then  do:
        delete obj-list.
     end.
     else do:
        assign l#obj-code = obj-list.obj-code
               l#obj-type = obj-list.obj-type   .
     end.
  End.
    Case temp-param-date :
      When 0 then t-str = "" .
      When 1 then t-str = " На " + string(X-Date-Alone,"99/99/9999").
      When 2 then t-str = " За период с  " + string(X-Date-Start,"99/99/9999") + "  по " + string(X-Date-End,"99/99/9999") .
      When 3 then t-str = " По смене № " + string(X-Shift-Alone) + "  за период с " + string(X-Date-Start,"99/99/9999") + "  по " + string(X-Date-End,"99/99/9999") .
      When 4 then DO:
          if  tog-shift AND tog-shift-2 THEN
                t-str =
                " По смене № "  + string(X-Shift-Start)   +
                " на  " + string(X-Date-Start,"99/99/9999") .
          Else
                t-str =  (If X-TOG-Shift Then
                "Смены с "  + string(X-Shift-Start)   + " по "  + string(X-Shift-End)  Else "" ) +
                " За период с  " + string(X-Date-Start,"99/99/9999") + "  по " + string(X-Date-End,"99/99/9999") .
                End.
      When 5 OR when 6 then DO:
       CASE RAdio-TAsk:
            When 1 then  t-str = "Календарные сутки , За период с  " + string(X-Date-Start,"99/99/9999") + "  по " + string(X-Date-End,"99/99/9999") .
            when 2  then  t-str = "Сменные сутки , За период с  " + string(X-Date-Start,"99/99/9999") + "  по " + string(X-Date-End,"99/99/9999") .
            When 3 then  t-str = "Сменные сутки,  За период с  " + string(X-Date-Start,"99/99/9999") + "  по " + string(X-Date-End,"99/99/9999") +
                                  " Смены с "  + string(X-Shift-Start)   + " по "  + string(X-Shift-End)   .
            When 4 then  t-str = " По смене № " + string(X-Shift-Alone) + " За период с  " + string(X-Date-Start,"99/99/9999") + "  по " + string(X-Date-End,"99/99/9999") .
       End case.
              End.
      When 7 then t-str = " По смене № " + string(X-Shift-Alone) + "  дата открытия " + string(X-Date-Start,"99/99/9999") .
      When 8 then DO:
                t-str =
                "Смены с "  + string(X-Shift-Start)   + " по "  + string(X-Shift-End)  +
                " За период с  " + string(X-Date-Start,"99/99/9999") + "  по " + string(X-Date-End,"99/99/9999") .
      End.
      When 9 then DO:
                t-str =
                "Период : за " +  string (entry ( (lookup(radio-period,'Год,year,Год (прошлый),year-last,Полугодие,halfyear,Полугодие (прошлое),halfyear-last,Квартал,quarter,Квартал (прошлый),quarter-last,Месяц,month,Месяц (прошлый),month-last,Неделя,week,Неделя (прошлая),week-last,День,day,Вчера,yesterday,Час (текущий),hour,Час (прошлый),hour-last,Смена,shift,Смена (прошлая),shift-last':U) - 1)  , 'Год,year,Год (прошлый),year-last,Полугодие,halfyear,Полугодие (прошлое),halfyear-last,Квартал,quarter,Квартал (прошлый),quarter-last,Месяц,month,Месяц (прошлый),month-last,Неделя,week,Неделя (прошлая),week-last,День,day,Вчера,yesterday,Час (текущий),hour,Час (прошлый),hour-last,Смена,shift,Смена (прошлая),shift-last':U ) ) .
      End.
    End case.
     str1 = t-str.
    t-str = '' .
    if temp-param-goods = ""   Then str2 =" ".
    Else DO:
         run sel-x-selectgood  in this-procedure .
         str2 = Text-2 + ": "  + t-str .        .
         End.
    if temp-param-pay = ""   Then str3 =''.
       Else DO:
          If ( x-SET_val_TYPE = 0 and base-code=0)  Or x-SET_val_TYPE=1
            then  DO:
                  case X-SET_PAY_TYPE :
                    when 1 then str3 = Text-4 + ": "    +  "в рублевых ценах РЕАЛИЗАЦИИ".
                    when 2 then str3 = Text-4 + ": "    +  "в УЧЕТНЫХ рублевых ценах".
                    when 3 then str3 = Text-4 + ": "    +  "в рублевых ценах ДОКУМЕНТА".
                  end case.
                  End.
            else  DO:
                  case X-SET_PAY_TYPE :
                    when 1 then str3 = Text-4 + ": "    +  "в валютных ценах РЕАЛИЗАЦИИ".
                    when 2 then str3 = Text-4 + ": "    +  "в УЧЕТНЫХ валютных ценах".
                    when 3 then str3 = Text-4 + ": "    +  "в валютных ценах ДОКУМЕНТА".
                  end case.
                  End.
        End.
    if temp-param-obj = ""   Then str4 =''.
    Else do:
      t-str=''.
        if temp-param-Alon then do:
        if SelectObject = 'все':U THEN run sss in this-procedure .
        if SelectObject = "firm":U THEN run sss in this-procedure .
        if SelectObject = "currency":U then  run select-objects-proc in this-procedure .
        end.
        CAse SelectObject:
          When 'все':U then t-str = " По всем объектам ".
          OTHERWISE DO:
              FOR each Obj-list :
                  FIND cli-obj WHERE cli-obj.obj-type = obj-list.obj-type  AND
                                     cli-obj.obj-code = obj-list.obj-code NO-LOCK .
              if LENGTH(t-str) <= 6000 then
                 t-str = t-str + chr(10) + "     " + cli-obj.obj-name  + ' ' + obj-list.obj-type.
              End.
          End.
       End case.
       str4 = TEXT-1 + ": " + t-str.
       IF str-obj# <> "" Then
          str4 = str4  + chr(10) + "Не включены в список : " + str-obj# .
       IF str-obj2# <> "" Then
          str4 = str4   + chr(10) +  "Нет информации о чеках на объектах : " + str-obj2# .
       IF str-obj3# <> "" Then do:
          if not SelectObject = "firm":U then do:
             str4 = str4   + chr(10) +  "Не текущая фирма : " + str-obj3# .
          end.
       end.
     End.
     if temp-param-customer <> "" then do:
        t-str = "" .
              t-str = t-str + chr(10) + text-5 + ": " .
                for each g#customer:
                    if LENGTH (t-str) >= 10000 then do:
                       t-str = trim( t-str , '...') .
                       t-str = t-str + '...' .
                    end.
                    else t-str = t-str + chr(10) + "     " + g#customer.obj-name .
                End.
        if Radio-customer = 0 then Radio-customer = 1.
        if Radio-customer = 1 then t-str = t-str + chr(10) + "все" .
        str4 = str4 + t-str .
     end.
     if temp-param-schet <> "" then do:
        t-str = "" .
              t-str = t-str + chr(10) .
        if Radio-schet = 0 then Radio-schet = 1.
        t-str = t-str + chr(10) + lkp-schet .
        str4 = str4 + t-str .
     end.
run set-attribute-list IN THIS-PROCEDURE (
'KEEP-SPIS':U  + "=" + string(keep-spis) + "," +
'RADIO-CUSTOMER':U  + "=" + string(RADIO-CUSTOMER) + "," +
'RADIO-SCHET':U     + "=" + string(RADIO-SCHET)    + "," +
'EX-CURR-CODE':U     + "=" + string(v-curr-code)
 ) .
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME F-Main.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.
PROCEDURE Display-count :
if SelectGood = 6 then do:
        Assign
          goods-count = '(Выбрано ' + string(lns-cnt) + ' список)'
          Goods-Editor= s-notes
          .
end.
else do:
If can-find (First gds-list no-lock)
     then
        Assign
          goods-count = '(Выбрано ' + string(lns-cnt) + ' товаров)'
          Goods-Editor= s-notes
          .
     else
       Assign
       goods-count = ''
       Goods-Editor = ''
       .
 end.
  Display goods-count Goods-Editor with frame F-Main .
  x-Goods-Editor = Goods-Editor.
END PROCEDURE.
PROCEDURE Display-count-OTHER :
 x-SelectGood = Integer(SelectGood:screen-value IN frame F-Main).
   run sel-x-selectgood in this-procedure .
        if LENGTH (t-str) > 6000 then do:
          Assign  Goods-Editor = substring(T-str ,1, 6000) + chr(10) + "выборка для просмотра обрезана - слишком много записей " .
      end.
      else Assign  Goods-Editor = T-str  .
      Display goods-count Goods-Editor with frame F-Main .
              x-Goods-Editor = Goods-Editor.
END PROCEDURE.
PROCEDURE display-date :
define buffer buf_shift-obj for ub.shift-obj .
case temp-param-date:
    when 0 then do:
         disable Radio-task TEXT-3 Date-Alone BUTTON-shift Shift-Alone Date-End Date-Start  Shift-End Shift-Start TOG-Shift Radio-Period with frame F-Main .
         hide RADIO-task TEXT-3  Date-Alone BUTTON-shift  Shift-Alone Date-End Date-Start Shift-End Shift-Start TOG-Shift BUTTON-Shift-end BUTTON-Shift-Start  Radio-Period in frame F-Main .
         End.
    when 1 then do:
         enable TEXT-3  Date-Alone with frame F-Main .
         display TEXT-3  Date-Alone with frame F-Main .
         disable Radio-task Date-End Date-Start Shift-Alone  BUTTON-shift  Shift-End Shift-Start TOG-Shift  Radio-Period with frame F-Main .
         hide  RADIO-task   Date-End Date-Start Shift-Alone  BUTTON-shift Shift-End Shift-Start TOG-Shift BUTTON-Shift-end BUTTON-Shift-Start  Radio-Period in frame F-Main .
         End.
    when 2 then do:
         TEXT-3 = 'Выбор периода'.
         enable TEXT-3  Date-End Date-Start  with frame F-Main .
         display TEXT-3  Date-End Date-Start  with frame F-Main .
         disable Radio-task Date-Alone Shift-Alone  BUTTON-shift  Shift-End Shift-Start TOG-Shift  Radio-Period with frame F-Main .
         hide   RADIO-task Date-Alone  Shift-Alone  BUTTON-shift Shift-End Shift-Start TOG-Shift BUTTON-Shift-end BUTTON-Shift-Start  Radio-Period in frame F-Main .
         End.
    when 3 then do:
        TEXT-3 = 'Выбор смены'.
         enable  TEXT-3  Date-End Date-Start Shift-Start   Shift-Alone with frame F-Main .
         disable Date-Alone Shift-End shift-start TOG-Shift RADIO-task  Radio-Period with frame F-Main .
         hide    Date-Alone Shift-End shift-start  BUTTON-shift TOG-Shift RADIO-task BUTTON-Shift-end BUTTON-Shift-Start  Radio-Period  in   frame F-Main .
         display   TEXT-3  Date-End Date-Start Shift-Alone with frame F-Main .
         End.
    when 4 then do:
         if TOG-Shift-2 THEN DO:
            disable Date-End  shift-end  with frame F-Main .
         End.
         ELSE DO:
             enable Date-End shift-end  with frame F-Main   .
         End.
         enable  TEXT-3   Date-Start  Shift-Start TOG-Shift with frame F-Main .
         if not tog-shift then do:
            disable Shift-start shift-end BUTTON-Shift-end BUTTON-Shift-Start  Radio-Period with frame F-Main .
            hide Shift-start shift-end BUTTON-Shift-end BUTTON-Shift-Start  Radio-Period in frame F-Main .
         end .
         else do:
            if tog-shift-2 then
                do:
                    disable shift-end BUTTON-Shift-end Date-End with frame F-Main .
                    enable  Shift-start BUTTON-Shift-Start with frame F-Main .
                    display Shift-start BUTTON-Shift-Start with frame F-Main .
                    display TEXT-3 Date-Start Date-End Shift-Start Shift-End TOG-Shift with frame F-Main .
                end.
            else
                do:
                    enable  Shift-start shift-end BUTTON-Shift-end BUTTON-Shift-Start with frame F-Main .
                    display Shift-start shift-end BUTTON-Shift-end BUTTON-Shift-Start with frame F-Main .
                    display TEXT-3 Date-Start Date-End Shift-Start Shift-End TOG-Shift with frame F-Main .
                end.
         end.
         display Date-Start Date-End TOG-Shift with frame F-Main .
         disable Date-Alone BUTTON-shift Shift-Alone Radio-task  Radio-Period with frame F-Main .
         hide    RADIO-task BUTTON-shift Date-Alone Shift-Alone   Radio-Period in frame F-Main .
         if temp-param-obj = "" then do:
            if NOT can-find(first buf_shift-obj where buf_shift-obj.obj-code = v-cntxt-obj-code and
                                                  buf_shift-obj.obj-type = v-cntxt-obj-type no-lock ) then  DO:
                hide  Shift-Start TOG-Shift Shift-End TOG-Shift-2 BUTTON-Shift-end BUTTON-Shift-Start in frame F-Main .
            end.
            else do:
              if tog-shift then do:
                 enable BUTTON-Shift-Start with frame F-Main .
                  if not tog-shift-2 then
                    enable BUTTON-Shift-end  with frame F-Main .
              end.
            end.
         End.
    End.
    when 5 then do:
         enable  TEXT-3  Date-End Date-Start  RADIO-task  with frame F-Main .
         display TEXT-3  Date-End Date-Start  RADIO-task  with frame F-Main .
         disable Date-Alone BUTTON-shift  TOG-Shift   Radio-Period  with frame F-Main .
         hide Date-Alone BUTTON-shift  Shift-Alone TOG-Shift  Radio-Period  in frame F-Main .
         End.
    when 6 then do:
         enable  TEXT-3  Date-End Date-Start  RADIO-task  with frame F-Main .
         display TEXT-3  Date-End Date-Start  RADIO-task  with frame F-Main .
         disable Date-Alone TOG-Shift   Radio-Period with frame F-Main .
         hide Date-Alone BUTTON-shift  Shift-Alone TOG-Shift  Radio-Period  in frame F-Main .
         v-ok = RADIO-TASK:disable(radio-label("3", RADIO-TASK:radio-buttons)).
         v-ok = RADIO-TASK:disable(radio-label("4", RADIO-TASK:radio-buttons)).
         End.
    when 7 then do:
        TEXT-3 = 'Выбор смены'.
         enable  TEXT-3   Date-Start Shift-Start Shift-Alone with frame F-Main .
         disable Date-Alone date-end Shift-End shift-start TOG-Shift RADIO-task  Radio-Period  with frame F-Main .
         hide    Date-Alone date-end Shift-End shift-start TOG-Shift RADIO-task  Radio-Period  in   frame F-Main .
         display   TEXT-3  Date-Start Shift-Alone  BUTTON-shift  with frame F-Main .
         End.
    when 8 then do:
         tog-shift = true .
         tog-shift-2 = false  .
         x-tog-shift = true .
         enable   Date-Start  Shift-Start
                  Date-End  shift-end
                  BUTTON-Shift-end BUTTON-Shift-Start  with frame F-Main .
          display Shift-start shift-end
                  TEXT-3   Date-Start  Shift-Start Date-End Shift-End   with frame F-Main .
         hide  Date-Alone BUTTON-shift  Shift-Alone Radio-task   tog-shift tog-shift-2    Radio-Period
                RADIO-task   BUTTON-shift Date-Alone Shift-Alone in frame F-Main .
    End.
    when 9 then do:
         TEXT-3 ='Выбор периода'.
         enable  RADIO-period  with frame F-Main .
         display TEXT-3  RADIO-period  with frame F-Main .
         disable Date-Alone BUTTON-shift  TOG-Shift   Radio-task  with frame F-Main .
         hide Date-Alone BUTTON-shift  Shift-Alone TOG-Shift  Radio-task
              Date-Start  Date-End
              in frame F-Main .
   End.
End case.
if choose-shift
and TOG-Shift:sensitive
then do :
  TOG-Shift:screen-value in frame F-Main = "yes" .
  TOG-Shift = yes.
  apply "value-changed" to TOG-Shift in frame F-Main .
end .
END PROCEDURE.
PROCEDURE display-goods :
    define buffer buf_clob-bind for ub.clob-bind  .
    define variable v-temp-str as character no-undo .
    define variable J#         as integer   no-undo .
    define variable L#         as integer   no-undo .
    define variable RET#       as logical   no-undo .
    define variable R#         as integer   no-undo .
    IF  temp-param-goods = ""
        then
    DO:
        disable TEXT-2 SelectGood BUTTON-gds button-keep-spis BUTTON-node BUTTON-prod BUTTON-node-2 BUTTON-prod-2 BUTTON-one Goods-count Goods-Editor  with frame F-Main .
        hide TEXT-2 SelectGood  BUTTON-gds button-keep-spis  BUTTON-node BUTTON-prod  BUTTON-node-2 BUTTON-prod-2  BUTTON-one Goods-count Goods-Editor   in frame F-Main .
    End.
    Else
    DO:
        enable TEXT-2 with frame F-Main .
        display TEXT-2 SelectGood with frame F-Main .
if temp-param-goods <> "*":U then do :
  v-temp-str="".
  repeat l# =1 to num-entries(SelectGood:radio-buttons) / 2
  :
      if lookup(string(l#),replace(temp-param-goods,"!","")) = 0 then
        v-temp-str = v-temp-str + string(l#) + ','.
  end.
  repeat l# = 1  to num-entries(v-temp-str)
  :
    r# = 0.
    repeat j# = 1 to num-entries(SelectGood:radio-buttons) by 2
    :
      r# = r# + 1.
      if r# = integer(entry(l#,v-temp-str)) then
         ret# = SelectGood:disable(entry(j#,SelectGood:radio-buttons)).
    end.
  end.
  do l# = 1 to num-entries(temp-param-goods):
    if entry(l#,temp-param-goods) begins "!" then
    do:
      r# = integer(substring(entry(l#,temp-param-goods),2)) no-error.
      SelectGood:screen-value = entry(r# * 2,SelectGood:radio-buttons).
      assign SelectGood.
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
        if keep-spis <> "" then
        do:
            find first buf_clob-bind no-lock where
                buf_clob-bind.field-name_ = keep-spis no-error .
            if available buf_clob-bind then
            do:
                keep-spis = buf_clob-bind.field-name_ .
                s-notes =  substitute("Хранимый Файл списка : &1 &2", buf_clob-bind.field-name, buf_clob-bind.descr ).
            end.
        end.
    run display-count-other in this-procedure .
  End.
END PROCEDURE.
PROCEDURE display-obj :
define variable v-temp-str  as character no-undo .
define variable J#          as integer   no-undo .
define variable L#          as integer   no-undo .
define variable RET#        as logical   no-undo .
define variable R#          as integer   no-undo .
 IF temp-param-obj = ""
    then DO:
       disable TEXT-1 BUTTON-obj SelectObject Obj-count   with frame F-Main .
       hide    TEXT-1  BUTTON-obj SelectObject Obj-count   in frame F-Main .
    End.
    Else DO:  enable TEXT-1 with frame F-Main .
              display TEXT-1  SelectObject Obj-count  with frame F-Main .
if temp-param-obj <> "*":U then do :
  v-temp-str="".
  repeat l# =1 to num-entries(SelectObject:radio-buttons) / 2
  :
      if lookup(string(l#),replace(temp-param-obj,"!","")) = 0 then
        v-temp-str = v-temp-str + string(l#) + ','.
  end.
  repeat l# = 1  to num-entries(v-temp-str)
  :
    r# = 0.
    repeat j# = 1 to num-entries(SelectObject:radio-buttons) by 2
    :
      r# = r# + 1.
      if r# = integer(entry(l#,v-temp-str)) then
         ret# = SelectObject:disable(entry(j#,SelectObject:radio-buttons)).
    end.
  end.
  do l# = 1 to num-entries(temp-param-obj):
    if entry(l#,temp-param-obj) begins "!" then
    do:
      r# = integer(substring(entry(l#,temp-param-obj),2)) no-error.
      SelectObject:screen-value = entry(r# * 2,SelectObject:radio-buttons).
      assign SelectObject.
    end.
  end.
end.
    if SelectObject = "choice":U then do:
        if not can-find (first userobjs_temp-user-obj) then do:
          for each X-init_obj-list:
                create userobjs_temp-user-obj.
                assign
                  userobjs_temp-user-obj.obj-code = X-init_obj-list.obj-code
                  userobjs_temp-user-obj.obj-type = X-init_obj-list.obj-type
                .
          end.
         end.
    end.
     if (v-cntxt-obj-type = 'скл':U and temp-param-obj-type = 'shop')
     or (v-cntxt-obj-type = 'маг':U  and temp-param-obj-type = 'stock')
     then do:
        ret# = selectobject:disable(entry(3,selectobject:radio-buttons)).
        apply "value-changed" to selectobject in frame f-main.
        end.
     end.
END PROCEDURE.
PROCEDURE display-pay :
define variable v-temp-str  as character no-undo .
define variable J#          as integer   no-undo .
define variable L#          as integer   no-undo .
define variable RET#        as logical   no-undo .
define variable R#          as integer   no-undo .
IF temp-param-pay = "" then DO:
         disable   SET_PAY_TYPE   with frame F-Main .
         hide  SET_PAy_TYPE  in frame F-Main .
         SET_PAY_TYPE:screen-value IN frame F-Main = "2".
         SET_PAY_TYPE = 2.
                        end.
   Else do:
         enable TEXT-4  SET_PAY_TYPE SET_val_TYPE with frame F-Main .
         display TEXT-4 SET_PAY_TYPE with frame F-Main .
if temp-param-pay <> "*":U then do :
  v-temp-str="".
  repeat l# =1 to num-entries(SET_pay_TYPE:radio-buttons) / 2
  :
      if lookup(string(l#),replace(temp-param-pay,"!","")) = 0 then
        v-temp-str = v-temp-str + string(l#) + ','.
  end.
  repeat l# = 1  to num-entries(v-temp-str)
  :
    r# = 0.
    repeat j# = 1 to num-entries(SET_pay_TYPE:radio-buttons) by 2
    :
      r# = r# + 1.
      if r# = integer(entry(l#,v-temp-str)) then
         ret# = SET_pay_TYPE:disable(entry(j#,SET_pay_TYPE:radio-buttons)).
    end.
  end.
  do l# = 1 to num-entries(temp-param-pay):
    if entry(l#,temp-param-pay) begins "!" then
    do:
      r# = integer(substring(entry(l#,temp-param-pay),2)) no-error.
      SET_pay_TYPE:screen-value = entry(r# * 2,SET_pay_TYPE:radio-buttons).
      assign SET_pay_TYPE.
    end.
  end.
end.
         if Lookup(temp-param-pay, "2" ) > 0 Then
         Assign SET_PAY_TYPE:screen-value IN frame F-Main = "2"
                SET_PAY_TYPE = 2.
         End.
IF temp-param-pay-hide = "" then DO:
         disable   SET_val_TYPE  with frame F-Main .
         hide  SET_val_TYPE  in frame F-Main .
                        end.
   Else do:
         enable  SET_val_TYPE with frame F-Main .
         display TEXT-4  with frame F-Main .
if temp-param-pay-hide <> "*":U then do :
  v-temp-str="".
  repeat l# =1 to num-entries(SET_val_TYPE:radio-buttons) / 2
  :
      if lookup(string(l#),replace(temp-param-pay-hide,"!","")) = 0 then
        v-temp-str = v-temp-str + string(l#) + ','.
  end.
  repeat l# = 1  to num-entries(v-temp-str)
  :
    r# = 0.
    repeat j# = 1 to num-entries(SET_val_TYPE:radio-buttons) by 2
    :
      r# = r# + 1.
      if r# = integer(entry(l#,v-temp-str)) then
         ret# = SET_val_TYPE:disable(entry(j#,SET_val_TYPE:radio-buttons)).
    end.
  end.
  do l# = 1 to num-entries(temp-param-pay-hide):
    if entry(l#,temp-param-pay-hide) begins "!" then
    do:
      r# = integer(substring(entry(l#,temp-param-pay-hide),2)) no-error.
      SET_val_TYPE:screen-value = entry(r# * 2,SET_val_TYPE:radio-buttons).
      assign SET_val_TYPE.
    end.
  end.
end.
         End.
 IF temp-param-pay = ""  And  temp-param-pay-hide = "" then DO:
         disable  TEXT-4 SET_PAY_TYPE SET_val_TYPE  with frame F-Main .
         hide TEXT-4  SET_PAY_TYPE SET_val_TYPE  in frame F-Main .
                        end.
   Else do:
         enable  TEXT-4   with frame F-Main .
         display TEXT-4   with frame F-Main .
         end.
END PROCEDURE.
PROCEDURE display-RAdio-task :
Case RAdio-task:screen-value in frame F-Main :
  When '1' then DO:
    TOG-Shift = False.
    Hide   Date-Alone Shift-Alone  BUTTON-shift   Shift-End Shift-Start  TOG-Shift in frame F-Main .
    Display Date-End Date-Start with frame F-Main .
    x-TOG-Shift = False.
                End.
  When '2' then DO:
    TOG-Shift=true.
    Hide    Date-Alone Shift-Alone  BUTTON-shift Shift-End Shift-Start  TOG-Shift in frame F-Main .
    Display Date-End Date-Start with frame F-Main .
    x-TOG-Shift = True.
                End.
  When '3' then DO:
      TOG-Shift=true.
      enable Date-End Date-Start  Shift-End Shift-Start with frame F-Main .
      Hide   Date-Alone Shift-Alone    BUTTON-shift   TOG-Shift in frame F-Main .
      Display Date-End Date-Start Shift-End Shift-Start with frame F-Main .
      assign
      x-TOG-Shift = True.
                End.
  When '4' then DO:
       TOG-Shift=true.
       enable Date-End Date-Start  Shift-Alone with frame F-Main .
       Hide   Date-Alone   Shift-End  BUTTON-shift  Shift-Start TOG-Shift in frame F-Main .
       Display Date-End Date-Start  Shift-Alone  with frame F-Main .
       assign Date-End Date-Start  Shift-Alone.
       assign Shift-End   = Shift-Alone
              Shift-Start = Shift-Alone
              x-Shift-End   = Shift-Alone
              x-Shift-Start = Shift-Alone
              Shift-start:screen-value = string(Shift-Alone)
              Shift-End:screen-value = string(Shift-Alone)
              .
       x-TOG-Shift = True.
                End.
  End.
END PROCEDURE.
PROCEDURE init-radio-schet :
 do
 on error undo, return error return-value
 :
define variable ll as integer no-undo .
define buffer buf_fin-schet for ub.fin-schet.
  if temp-param-schet = "" then do:
     hide Radio-schet in frame F-Main
     Radio-schet BUTTON-schet BUTTON-schet-one BUTTON-schet-val lkp-schet text-6 in frame F-Main .
  end.
  else do:
    text-6 = temp-param-schet .
    display text-6 with frame F-Main .
      if temp-param-schet-init <> "" then do:
         radio-schet = 4 .
      end.
      if temp-param-schet-hide <> "" then do:
         repeat ll = 1 to num-entries(temp-param-schet-hide) - 1 :
           if radio-schet = 4  and entry(ll,temp-param-schet-hide) =  string( 4 )
              then message "Не верно заданы параметры для блока ВЫБОР СЧЕТА в вызывающей процедуре g- " view-as alert-box error .
           v-ok = radio-schet:disable ( radio-label(entry(ll,temp-param-schet-hide), radio-schet:radio-buttons)) .
           case integer (entry(ll,temp-param-schet-hide)) :
              when 4 then do:
                hide button-schet-one in frame F-Main .
              end.
              when 3 then do:
                hide button-schet in frame F-Main .
              end.
              when 7 then do:
                hide button-schet-val in frame F-Main .
              end.
           end case.
         end.
         repeat ll = 7 to 1 by -1 :
              if radio-schet <> 4 then do:
                  if lookup( string(ll) , temp-param-schet-hide) <> 0 then next.
                  radio-schet = ll .
              end.
         end.
                case radio-schet :
                      when 3 then do:
                          enable button-schet with frame F-Main .
                          disable button-schet-one button-schet-val with frame F-Main .
                      end.
                      when 4 then do:
                          enable button-schet-one with frame F-Main .
                          disable button-schet button-schet-val with frame F-Main .
                            if temp-param-schet-init <> "" and temp-param-schet-init <> ? then do:
                                  find first buf_fin-schet no-lock where
                                      buf_fin-schet.code-schet = integer (temp-param-schet-init) and
                                      buf_fin-schet.host-code  = v-cntxt-host-code-obj no-error .
                                      if available buf_fin-schet then
                                      assign
                                        schet-list = string(recid(buf_fin-schet))
                                      .
                            end.
                      end.
                      when 7 then do:
                          enable button-schet-val with frame F-Main .
                          disable button-schet-one button-schet with frame F-Main .
                      end.
                end case.
                lkp-schet = temp-param-schet + " по : " +
                            radio-label(string(RADIO-schet) , radio-schet:radio-buttons)
                            + chr(10) .
                define variable v-iii as integer no-undo .
                if schet-list <> ""
                   then do:
                      repeat v-iii = 1 to num-entries(schet-list) :
                        find first buf_fin-schet no-lock where    recid(buf_fin-schet) = integer (entry(v-iii,schet-list))   no-error .
                        if available buf_fin-schet then
                           lkp-schet  = lkp-schet  + string( buf_fin-schet.code-schet) + ", " .
                      end.
                end .
                display lkp-schet with frame F-Main .
      end.
      display radio-schet with frame F-Main .
  end.
  end.
END PROCEDURE.
PROCEDURE local-apply-layout :
define buffer buf_shift-obj for ub.shift-obj .
RUN dispatch IN THIS-PROCEDURE ( INPUT 'apply-layout':U ) .
run take-var in this-procedure .
if temp-param-date = 10
then do :
  temp-param-date = 4 .
end .
Assign
 Date-Alone   = X-Date-Alone
 Date-End     = X-Date-End
 Date-Start   = X-Date-Start
 Goods-Editor = X-Goods-Editor
 SelectGood   = X-SelectGood
 SelectObject = X-SelectObject
 SET_PAY_TYPE = X-SET_PAY_TYPE
 SET_val_TYPE = X-SET_val_TYPE
 Shift-Alone  = X-Shift-Alone
 Shift-End    = X-Shift-End
 Shift-Start  = X-Shift-Start
 TOG-Shift    = X-TOG-Shift
 RADIO-task   = x-RADIO-task      .
 if (init-SET_PAY_TYPE <> 0 or init-SET_PAY_TYPE <> ?)  and (x-SET_PAY_TYPE = ? or x-SET_PAY_TYPE = 0) then do:
    SET_PAY_TYPE = init-SET_PAY_TYPE.
 end.
If NOT can-find (First gds-list no-lock)
     then lns-cnt = 0.
    If x-Date-Alone = date('') then  Date-Alone   = init-Date-Alone.
    If x-Date-End   = date('') then  Date-End     = init-Date-End  .
    If x-Date-Start = date('') then  Date-Start   = init-Date-Start.
    If x-Shift-alone = 0 then        Shift-alone  = init-shift-alone.
    If x-Shift-start = 0 then        Shift-start  = init-shift-start.
    If x-Shift-end = 0 then          Shift-end    = init-shift-end  .
    if  temp-param-date  = 9  and ( radio-period = ? or radio-period = "" ) then do:
        if temp-param-date-type-period <> ? then radio-period = temp-param-date-type-period.
    end.
   Assign
      RADIO-task = x-RADIO-task
      .
     if can-find(first buf_shift-obj where buf_shift-obj.obj-code = v-cntxt-obj-code and
                                       buf_shift-obj.obj-type = v-cntxt-obj-type no-lock ) then  DO:
        If temp-param-date = 4 then  tog-shift = true .
        If temp-param-date = 8 or temp-param-date = 7 then  assign
                                        tog-shift = true
                                        x-tog-shift = true
                                        .
     end.
      If temp-param-date < 5 OR
         temp-param-date = 7 Then
        Assign
        RAdio-task = 0
        RAdio-task:screen-value in frame F-Main="".
      run val-shift    in this-procedure .
      run display-date in this-procedure .
      run verify-date  in this-procedure .
      If temp-param-date = 5  OR
         temp-param-date = 6
           Then   run display-radio-task in this-procedure .
      run display-goods in this-procedure .
      run val-goods in this-procedure .
      if temp-param-goods <> "" then do:
         run display-count-other in this-procedure .
      end.
      else
        hide goods-editor in frame F-Main.
  run display-obj in this-procedure .
  run val-obj in this-procedure .
  run display-pay in this-procedure .
  run set_val in this-procedure .
  if selectobject = 'все':U then run sss in this-procedure .
  if selectobject = "firm":U then run sss in this-procedure .
  run verify-check-currency in this-procedure .
  run sel-customer in this-procedure  .
  if ref_date-end <> '':U then do:
    if not valid-handle(mi-ed_date-end-handle) then do:
      create menu-item mi-ed_date-end-handle
      assign
      label = entry(1, ref_date-end, chr(4))
      name = 'mi-ed_date-alone'
      parent = menu-ed_date-end-handle
      triggers:
        on choose
          persistent run proc-mi-ed_date in this-procedure .
      end triggers.
    end.
  end.
  if ref_date-alone <> '':U then do:
    if not valid-handle(mi-ed_date-alone-handle) then do:
      create menu-item mi-ed_date-alone-handle
      assign
      label = entry(1, ref_date-alone, chr(4))
      name = 'mi-ed_date-alone'
      parent = menu-ed_date-alone-handle
      triggers:
        on choose
          persistent run proc-mi-ed_date in this-procedure .
      end triggers.
    end.
  end.
  if ref_date-start <> '':U then do:
    if not valid-handle(mi-ed_date-start-handle) then do:
      create menu-item mi-ed_date-start-handle
      assign
      label = entry(1, ref_date-start, chr(4))
      name = 'mi-ed_date-alone'
      parent = menu-ed_date-start-handle
      triggers:
        on choose
          persistent run proc-mi-ed_date in this-procedure .
      end triggers.
    end.
  end.
 if params-only-mode  = 'ПРОСМОТР':U then do:
      disable
      radio-task
      date-alone
      tog-shift-2
      tog-shift
      showcrsa
      showcost
      showsale
      shift-alone
      shift-end
      date-start
      date-end
      set_pay_type
      set_val_type
      selectgood
      selectobject
      radio-customer
      radio-schet
      radio-period
      tog-excel
      tog-list-hist
      with frame F-Main .
 end.
END PROCEDURE.
PROCEDURE local-enable :
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'enable':U ) .
END PROCEDURE.
PROCEDURE local-initialize :
DEFINE VARIABLE parParentProc     AS WIDGET-HANDLE NO-UNDO.
ASSIGN parParentProc = my-handle.
 do with frame F-Main:
      if not (v-cntxt-level = 'firm':U  or
              v-cntxt-level = 'global':U )  then do:
        assign
          SelectObject :radio-buttons =
              "Все по фирме" + chr(44) + "firm":U
            + chr(44) + "Текущий" + chr(44) + "currency":U
            + chr(44) + "Выборочно" + chr(44) + "choice":U
            + chr(44) + "Все" + chr(44) + 'все':U
        .
    end.
    else do:
        assign
          SelectObject :radio-buttons =
              "Все по фирме" + chr(44) + "firm":U
            + chr(44) + "Выборочно" + chr(44) + "choice":U
            + chr(44) + "Все" + chr(44) + 'все':U
        .
        BUTTON-obj:ROW = 7.92 .
    end.
  end.
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-cntxt-host-code-obj
  ,output base-code
  )  .
run take-var in this-procedure .
run init-radio-schet in this-procedure  .
If temp-param-date = 10 then
  tog-shift:screen-value in frame F-Main = string(true) .
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ) .
   if temp-param-obj <> ""  then do:
      if not (v-cntxt-level = 'firm':U  or
              v-cntxt-level = 'global':U )
              then    SelectObject =  "currency":U .
      Display SelectObject with frame F-Main.
      if SelectObject =  "choice":U then do:
         empty temp-table userobjs_temp-user-obj.
      end.
      else do:
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run create_obj-list in this-procedure
 ( input v-cntxt-obj-type ,
   input v-cntxt-obj-code )
   .
      end.
  end.
  If Make-Excel then DO:
     TOG-Excel = tRUE .
     Disable TOG-Excel  with frame F-Main.
     DISPLAY TOG-Excel  with frame F-Main.
     End.
     Else DO:
          Disable TOG-Excel  with frame F-Main.
          Hide    TOG-Excel  in frame F-Main.
          End.
  If Print-List-Hist then DO:
    TOG-List-hist = tRUE .
    ENABLE TOG-List-hist  with frame F-Main.
    DISPLAY TOG-List-hist  with frame F-Main.
  End.
  Else DO:
    Disable TOG-List-hist  with frame F-Main.
    Hide    TOG-List-hist  in frame F-Main.
  End.
  If Show-Cost then DO:
    Showcost = Show-cost.
     enable showcost  with frame F-Main.
     DISPLAY showcost  with frame F-Main.
     End.
  If Show-Crsa then DO:
    Showcrsa = Show-crsa.
     enable showcrsa  with frame F-Main.
     DISPLAY showcrsa  with frame F-Main.
     End.
  If Show-sale then DO:
    Showsale = Show-sale.
     enable showsale  with frame F-Main.
     DISPLAY showsale  with frame F-Main.
     End.
    IF Name-Sale-price <> "" THEN DO :
       define variable str as character no-undo .
       str = SET_PAY_TYPE:radio-buttons IN frame F-Main.
       str = entry(1,str) + ","  + entry(2,str) + "," + entry(3,str) + ","+ entry(4,str) + "," + Name-Sale-price + "," + entry(6,str).
       SET_PAY_TYPE:radio-buttons IN frame F-Main = str.
       showsale:label = Name-Sale-price .
     end.
      if (init-SET_val_type <> 0)
      and set_val_type:sensitive in frame F-Main
      and set_val_type:visible in frame F-Main
      then do:
        assign
        set_val_type:screen-value = string(init-SET_val_type)
        no-error .
      end.
END PROCEDURE.
PROCEDURE make-6-gds-list :
 define buffer buf-goods for ub.goods.
 if X-SelectGood = 7 Then do:
  run set-cursor IN adm-broker-hdl ("WAIT").
  for each gds-list  :
    delete gds-list.
  End.
      for each g#cli no-lock :
        for each tmp#grp no-lock :
          for each buf-goods where
              buf-goods.prod-type = g#cli.obj-type and
              buf-goods.prod-code = g#cli.obj-code and
              ( trim(buf-goods.grp-name)  begins trim(tmp#grp.grp-name) )
              no-lock :
                 if not can-find(first gds-list where gds-list.gds-code= buf-goods.gds-code) then  do:
                    create gds-list.
                    BUFFER-copy buf-goods TO gds-list  no-error  .
                 End.
           End.
        End.
      End.
    RUN set-cursor IN adm-broker-hdl ("").
 End.
END PROCEDURE.
PROCEDURE return-var :
def output parameter param-1 as char.
param-1 = 'qqqq'.
END PROCEDURE.
PROCEDURE sel-customer :
 do
 on error undo, return error return-value
 :
  if temp-param-customer = "" then do:
     hide Radio-customer in frame F-Main
     customer-name text-5 rect-7 in frame F-Main .
  end.
  else do:
    text-5 = temp-param-customer .
    display text-5 with frame F-Main .
  end.
  end.
END PROCEDURE.
PROCEDURE sel-x-SelectGood :
define variable grp_name    as char.
define buffer buf_gds-grp for ub.gds-grp .
define variable my-c as int no-undo.
IF temp-param-goods <> "" THEN DO:
        Case x-SelectGood :
          When 1 then t-str = " По всем товарам ".
          When 2 then DO:
              t-str = " По группам "  .
                        For each  tmp#grp :
                             delete tmp#grp.
                        End.
                        define variable v-ind as integer   no-undo .
                        Repeat v-ind = 1 To num-entries( gdsgrp_recids )
                        :
                              find first buf_gds-grp WHERE recid ( buf_gds-grp ) = integer ( Entry(v-ind,gdsgrp_recids )) NO-LOCK.
                              RUN grplib-get-full-name in this-procedure( input buf_gds-grp.node-code, output Grp_Name ).
                                if Grp_Name <> ? Then  if LENGTH(t-str) <= 6000 then t-str = t-str + chr(10) + "     " + Grp_Name .
                                Create tmp#grp.
                                Assign tmp#grp.node-code = buf_gds-grp.node-code
                                       tmp#grp.grp-name = Grp_Name
                                       tmp#grp.is-term = buf_gds-grp.is-term
                                       tmp#grp.lvl-num = buf_gds-grp.lvl-num
                                       .
                            end.
                if num-entries( gdsgrp_recids ) > 0 THEN
                   goods-count = "выбрано " + string(num-entries( gdsgrp_recids )) + " групп " .
                   ELSE goods-count = "НЕ выбрано !!!".
              End.
          When 3 then DO:
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
          When 4 then DO:
                        if can-find (first gds-list no-lock ) then DO:
                            t-str = " По списку товаров " +  s-Notes.
                            goods-count = "выбрано " + String(lns-cnt) .
                            End.
                         Else Assign goods-count = "НЕ выбрано !!!" t-str = "" lns-cnt = 0 .
                       End.
          When  6  then DO:
              if  keep-spis <> "" then DO:
                  t-str = s-Notes.
                  goods-count = "выбрано списков : " + String(lns-cnt) .
                  End.
                Else Assign goods-count = "НЕ выбрано !!!" t-str = "" lns-cnt = 0 .
              End.
          When 5 then DO:
                  find first gds-list no-lock no-error.
                   if available gds-list THEN  Assign t-str = " " +  gds-list.gds-name goods-count = "выбран 1 товар".
                                          ELSE Assign t-str = "" goods-count = "НЕ выбрано !!!" lns-cnt = 0 .
                 END.
          When 7 then DO:
              t-str = " По группам "  .
                        For each  tmp#grp :
                             delete tmp#grp.
                        End.
                        Repeat v-ind = 1 To num-entries( gdsgrp_recids ):
                            find first buf_gds-grp WHERE recid ( buf_gds-grp ) = integer ( Entry(v-ind,gdsgrp_recids )) NO-LOCK.
                              run grplib-get-full-name in this-procedure ( input buf_gds-grp.node-code, output Grp_Name ).
                                if Grp_Name <> ? Then if LENGTH(t-str) <= 6000 then t-str = t-str + chr(10) + "     " + Grp_Name .
                                Create tmp#grp.
                                Assign tmp#grp.node-code = buf_gds-grp.node-code
                                       tmp#grp.grp-name = Grp_Name
                                       tmp#grp.is-term = buf_gds-grp.is-term
                                       tmp#grp.lvl-num = buf_gds-grp.lvl-num
                                       .
                            end.
              t-str = t-str + chr(10) +  " По производителям " .
               my-c = 0.
                for each g#cli no-lock:
                    t-str = t-str + chr(10) + "     " + g#cli.obj-name no-error .
                    my-c =  my-c + 1 .
                End.
                if num-entries( gdsgrp_recids ) > 0  and my-c > 0 THEN DO:
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
  if available buf_clob-bind then do:
    keep-spis = buf_clob-bind.field-name_ .
    lns-cnt = 1 .
    s-notes = substitute("Хранимый Файл списка : &1 &2", buf_clob-bind.field-name, buf_clob-bind.descr ).
  end.
  else do:
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
PROCEDURE select-objects-proc :
  define variable v-ii as integer   no-undo .
  def buffer cli-obj  for ub.clients .
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
for each obj-list :
 delete obj-list.
end.
str-obj#  = "" .
str-obj2# = "" .
str-obj3# = "" .
case selectobject :
when "currency":U then do:
 run verify-check.
end.
when 'все':U then   do:
 run sss.
end.
when "all" then   do:
 run sss.
end.
when "firm":U then   do:
 run sss.
end.
when "choice":U then do:
  for each obj-list :
      delete obj-list.
  end.
  define variable v-object-exist as logical   no-undo .
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_object-exist in this-procedure
  (output v-object-exist
  )  .
  if not params-only and v-object-exist = false then do:
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_append in this-procedure
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  )  .
     v-object-exist = true .
  end.
  if my-request     = false
  or v-object-exist = false
  then do:
    define variable v-user-select as logical   no-undo .
    define variable v-recids as character no-undo .
    if params-only then do:
    run ref/thobjs.w
        ( input my-handle
        , input this-procedure:handle
        , input (if params-only-mode = 'ПРОСМОТР':U then "b-mark-hidden" else "b-mark,b-sel")
        , input 'все':U
        , input ''
        , input ?
        , input ?
        , input-output v-recids ) no-error .
     end.
     else do:
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_select-many in this-procedure
  (input  my-handle
  ,input  v-cntxt-db-num
  ,input  v-cntxt-userid
  ,input  v-cntxt-host-code-obj
  ,input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-user-select
  )  .
     end.
  end.
  my-request = true .
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_object-exist in this-procedure
  (output v-object-exist
  )  .
  if v-object-exist = false
  then do:
    if temp-param-obj-type = 'shop':u or temp-param-obj-type = 'stock':u then do:
      assign selectobject = "firm":U .
    end.
    else do:
      assign selectobject =  "currency":u .
    end.
    display selectobject with frame F-Main .
    disable button-obj   with frame F-Main .
    find cli-obj where cli-obj.obj-type = v-cntxt-obj-type and
                        cli-obj.obj-code = v-cntxt-obj-code no-lock .
    if temp-param-obj-type = 'shop':u or temp-param-obj-type = 'stock':u
    then do:
      run sss.
    end.
    else do:
      run verify-check.
    end.
  end.
  else do:
      define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
      define buffer buf_clients for ub.clients .
      define buffer buf_db for ub.db .
      define buffer buf_shop for ub.shop .
      define buffer buf_store for ub.store .
      define buffer buf_sysconf for ub.sysconf .
      for each buf_userobjs_temp-user-obj
      :
        find first buf_clients no-lock
          where buf_clients.obj-type = buf_userobjs_temp-user-obj.obj-type
            and buf_clients.obj-code = buf_userobjs_temp-user-obj.obj-code
          .
          if verify-send-check  and buf_clients.db-num <> v-cntxt-db-num  and v-all-object = false then do:
                find first buf_db where buf_db.db-num = buf_clients.db-num no-lock.
                if buf_db.send-check = false then do:
                  str-obj2# = str-obj2#  + " " + buf_clients.obj-name + ",".
                  next.
                end.
          end.
          if temp-param-obj-type = 'shop':u and v-all-object = false then do:
              if buf_userobjs_temp-user-obj.obj-type = 'скл':U then do:
                  str-obj# = str-obj#  +  " " +  buf_clients.obj-name  .
                  next.
                end.
          end.
          if temp-param-obj-type = 'stock':u and v-all-object = false then do:
              if buf_userobjs_temp-user-obj.obj-type = 'маг':U then do:
                  str-obj# = str-obj#  +  " " +  buf_clients.obj-name  .
                  next.
              end.
          end.
          case buf_userobjs_temp-user-obj.obj-type:
              when 'скл':U then
                  do:
                      find buf_store where buf_store.obj-code = buf_userobjs_temp-user-obj.obj-code no-lock.
                      find first buf_sysconf no-lock where buf_sysconf.host-code = buf_store.host-code no-error.
                      find first buf_clients no-lock where
                                  buf_clients.obj-type = buf_userobjs_temp-user-obj.obj-type and
                                  buf_clients.obj-code = buf_userobjs_temp-user-obj.obj-code
                          .
                      if buf_sysconf.base-code = base-code or v-all-object = true
                          then do:
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run create_obj-list in this-procedure
 ( input buf_userobjs_temp-user-obj.obj-type ,
   input buf_userobjs_temp-user-obj.obj-code )
   .
                          end.
                          else do:
                            str-obj# = str-obj#  +  " " +  buf_clients.obj-name + "," .
                          end.
                  end.
              when 'маг':U then
                  do:
                      find first buf_shop where buf_shop.obj-code = buf_userobjs_temp-user-obj.obj-code no-lock.
                      find first buf_sysconf no-lock where buf_sysconf.host-code = buf_shop.host-code no-error.
                      find first buf_clients no-lock where
                                  buf_clients.obj-type = buf_userobjs_temp-user-obj.obj-type and
                                  buf_clients.obj-code = buf_userobjs_temp-user-obj.obj-code no-error.
                      if buf_sysconf.base-code = base-code or v-all-object = true
                            then do:
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run create_obj-list in this-procedure
 ( input buf_userobjs_temp-user-obj.obj-type ,
   input buf_userobjs_temp-user-obj.obj-code )
   .
                          end.
                          else do:
                            str-obj# = str-obj#  +  " " +  buf_clients.obj-name + "," .
                          end.
                  end.
          end case.
        end.
    end.
end.
end case.
END PROCEDURE.
PROCEDURE select-radio-period :
define input  parameter p-radio-period as character no-undo .
  radio-period = p-radio-period .
display radio-period with frame F-Main .
END PROCEDURE.
PROCEDURE select-Radio-schet :
 do
 on error undo, return error return-value
 :
define buffer buf_fin-schet for ub.fin-schet.
assign frame F-Main
  RADIO-schet
.
lkp-schet = temp-param-schet + " по : " +
            radio-label(string(RADIO-schet  ) , radio-schet:radio-buttons)
            .
define variable v-iii as integer no-undo .
case radio-schet :
    when 3 then do:
      enable button-schet with frame F-Main .
      disable button-schet-one button-schet-val with frame F-Main .
      apply "CHOOSE" to button-schet IN  frame F-Main .
      lkp-schet = lkp-schet + chr(10)  .
          repeat v-iii = 1 to num-entries(schet-list) :
            find first buf_fin-schet no-lock where    recid(buf_fin-schet) = integer (entry(v-iii,schet-list))   no-error .
            if available buf_fin-schet then
                lkp-schet = lkp-schet  + string( buf_fin-schet.code-schet) + ", ".
          end.
    end.
    when 4 then do:
      enable button-schet-one with frame F-Main .
      disable button-schet button-schet-val with frame F-Main .
      apply "CHOOSE" to button-schet-one IN  frame F-Main .
    end.
    when 7 then do:
      enable button-schet-val with frame F-Main .
      disable button-schet-one button-schet with frame F-Main .
      apply "CHOOSE" to button-schet-val IN  frame F-Main .
    end.
    otherwise do:
    if button-schet-val:visible then  disable button-schet-val with frame F-Main .
    if button-schet-one:visible then  disable button-schet-one with frame F-Main .
    if button-schet    :visible then  disable button-schet with frame F-Main .
    end.
end case.
display lkp-schet with frame F-Main .
run new-state("RADIO-SCHET="  + string(Radio-schet)) .
case radio-schet:
  when 1
  or
  when 2
  or
  when 3
  or
  when 6
  or
  when 4
  then do:
    if ref_date-start <> '':u
    and entry(2, ref_date-start, chr(4)) = "finsttms":U then do:
      entry(3, ref_date-start, chr(4)) = "ext-type-stat-start".
      entry(4, ref_date-start, chr(4)) = "".
    end.
    if ref_date-end <> '':u
    and entry(2, ref_date-end, chr(4)) = "finsttms":U then do:
      entry(3, ref_date-end, chr(4)) = "ext-type-stat-end".
      entry(4, ref_date-end, chr(4)) = "".
    end.
    if ref_date-alone <> '':u
    and entry(2, ref_date-alone, chr(4)) = "finsttms":U then do:
      entry(3, ref_date-alone, chr(4)) = "ext-type-stat-start".
      entry(4, ref_date-alone, chr(4)) = "".
    end.
  end.
  when 4
  then do:
  end.
  when 5
  or when 7
  then do:
    if ref_date-start <> '':u
    and entry(2, ref_date-start, chr(4)) = "finsttms":U then do:
      entry(3, ref_date-start, chr(4)) = "currency-start".
      if radio-schet = 5 then  do:
        entry(4, ref_date-start, chr(4)) = "0".
      end.
      else do:
        entry(4, ref_date-start, chr(4)) = entry(2, schet-list, "=").
      end.
    end.
    if ref_date-end <> '':u
    and entry(2, ref_date-end, chr(4)) = "finsttms":U then do:
      entry(3, ref_date-end, chr(4)) = "currency-end".
      if radio-schet = 5 then  do:
        entry(4, ref_date-end, chr(4)) = "0".
      end.
      else do:
        entry(4, ref_date-end, chr(4)) = entry(2, schet-list, "=").
      end.
    end.
    if ref_date-alone <> '':u
    and entry(2, ref_date-alone, chr(4)) = "finsttms":U then do:
      entry(3, ref_date-alone, chr(4)) = "currency-end1".
      if radio-schet = 5 then  do:
        entry(4, ref_date-alone, chr(4)) = "0".
      end.
      else do:
        entry(4, ref_date-alone, chr(4)) = entry(2, schet-list, "=").
      end.
    end.
  end.
end case.
end.
END PROCEDURE.
PROCEDURE select-radio-schet-no-apply :
 do
 on error undo, return error return-value
 :
define buffer buf_fin-schet for ub.fin-schet.
assign frame F-Main
  RADIO-schet
.
lkp-schet = temp-param-schet + " по : " +
            radio-label(string(RADIO-schet  ) , radio-schet:radio-buttons)
            .
define variable v-iii as integer no-undo .
    case radio-schet :
       when 3 then do:
          enable button-schet with frame F-Main .
          disable button-schet-one button-schet-val with frame F-Main .
       end.
       when 4 then do:
          enable button-schet-one with frame F-Main .
          disable button-schet button-schet-val with frame F-Main .
       end.
       when 7 then do:
          enable button-schet-val with frame F-Main .
          disable button-schet-one button-schet with frame F-Main .
       end.
       otherwise do:
        if button-schet-val:visible then  disable button-schet-val with frame F-Main .
        if button-schet-one:visible then  disable button-schet-one with frame F-Main .
        if button-schet    :visible then  disable button-schet with frame F-Main .
       end.
    end case.
    display lkp-schet with frame F-Main .
    run new-state ( "RADIO-SCHET="  + string(Radio-schet) ) .
  end.
END PROCEDURE.
PROCEDURE select1 :
Link# = true.
  run select-page in state-source ( 1 ).
  run local-apply-layout in this-procedure .
END PROCEDURE.
PROCEDURE Set_VAl :
   IF SET_PAY_TYPE:screen-value IN frame F-Main = "3"
       then   enable SET_VAL_TYPE with frame F-Main .
   IF SET_PAY_TYPE:screen-value IN frame F-Main = "2"
       then   enable SET_VAL_TYPE with frame F-Main .
   IF SET_PAY_TYPE:screen-value IN frame F-Main = "1"
       THEN   disable SET_VAL_TYPE with frame F-Main .
   IF temp-param-pay = "" AND  temp-param-pay-hide = ""   THEN DO:
      disable SET_VAL_TYPE with frame F-Main .
      hide  SET_val_TYPE  in frame F-Main .
      End.
END PROCEDURE.
PROCEDURE sss :
define buffer buf_clients for ub.clients .
define buffer cli-obj      for ub.clients .
define buffer buf_user-obj for ub.user-obj .
define buffer buf_db for ub.db .
define buffer buf_store for ub.store .
define buffer buf_shop for ub.shop .
define buffer buf_sysconf for ub.sysconf .
 If NOT (temp-param-obj = '*'
    OR Lookup(string(4),replace(temp-param-obj,"!","")) > 0
    OR Lookup(string(1),replace(temp-param-obj,"!","")) > 0  ) then DO:
   message "Выполнить невозможно, смените текущий объект !" view-as alert-box error .
  return error.
 End.
  FOR EACH obj-list :  delete obj-list.  END.
  assign
    str-obj#  = ''
    str-obj2# = ''
    str-obj3# = ''
  .
  for each buf_user-obj no-lock
    where buf_user-obj.db-num  = v-cntxt-db-num
      and buf_user-obj.user-id = v-cntxt-userid ,
   each cli-obj no-lock
    where cli-obj.obj-type = buf_user-obj.obj-type
      and cli-obj.obj-code = buf_user-obj.obj-code
      and ( ( cli-obj.db-num = v-cntxt-db-num ) or v-cntxt-db-num = 0 )
  :
          find first buf_clients no-lock
            where buf_clients.obj-type = buf_user-obj.obj-type
              and buf_clients.obj-code = buf_user-obj.obj-code
            .
          if buf_clients.stts <> 0 then next.
          if verify-send-check and buf_clients.db-num <> v-cntxt-db-num  and v-all-object = false  then do:
             find first buf_db where buf_db.db-num = buf_clients.db-num no-lock.
             if buf_db.send-check = false then do:
              str-obj2# = str-obj2#  + " " + buf_clients.obj-name + ",".
              next.
            end.
          end.
          if temp-param-obj-type = 'shop':U and v-all-object = false  then do:
              if buf_user-obj.obj-type = 'скл':U then DO:
                str-obj# = str-obj#  +  " " + buf_clients.obj-name + ",".
                NEXT.
              End.
          End.
          if temp-param-obj-type = 'stock':U and v-all-object = false then do:
              if buf_user-obj.obj-type = 'маг':U then DO:
                str-obj# = str-obj#  +  " " +  buf_clients.obj-name + "," .
                next.
              end.
          end.
        CASE buf_user-obj.obj-type:
            when 'скл':U then do:
                    find first buf_store WHERE buf_store.obj-code = buf_user-obj.obj-code NO-LOCK.
                    if SelectObject = "firm":U and v-all-object = false then do:
                      if buf_store.host-code <> v-cntxt-host-code-obj then do:
                          str-obj3# = str-obj3#  + " " + buf_clients.obj-name + ",".
                          next.
                      end.
                    end.
                    FIND FIRST buf_sysconf No-LOCK where buf_sysconf.host-code = buf_store.host-code No-ERROR.
                    Find first buf_clients no-lock where
                                buf_clients.obj-type = buf_user-obj.obj-type AND
                                buf_clients.obj-code = buf_user-obj.obj-code No-ERROR.
                    if buf_sysconf.base-code = base-code then
                        do:
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run create_obj-list in this-procedure
 ( input buf_user-obj.obj-type ,
   input buf_user-obj.obj-code )
   .
                        end.
                        else do :
                        if v-all-object = false then  str-obj# = str-obj#  +  " "  +  buf_clients.obj-name +  "," .
                            else do:
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run create_obj-list in this-procedure
 ( input buf_user-obj.obj-type ,
   input buf_user-obj.obj-code )
   .
                            end.
                        end.
            end.
            when 'маг':U then  do:
                    find first buf_shop where buf_shop.obj-code = buf_user-obj.obj-code no-lock.
                    if selectobject = "firm":U and v-all-object = false then do:
                      if buf_shop.host-code <> v-cntxt-host-code-obj then do:
                          str-obj3# = str-obj3#  + " " + buf_clients.obj-name + "," .
                          next.
                      end.
                    end.
                    find first buf_sysconf no-lock where buf_sysconf.host-code = buf_shop.host-code no-error.
                    find first buf_clients no-lock where
                                buf_clients.obj-type = buf_user-obj.obj-type and
                                buf_clients.obj-code = buf_user-obj.obj-code no-error.
                    if buf_sysconf.base-code = base-code then
                        do:
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run create_obj-list in this-procedure
 ( input buf_user-obj.obj-type ,
   input buf_user-obj.obj-code )
   .
                        end.
                        else do:
                            if v-all-object = false then   str-obj# = str-obj#  +  " " +  buf_clients.obj-name +  "," .
                                else do:
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run create_obj-list in this-procedure
 ( input buf_user-obj.obj-type ,
   input buf_user-obj.obj-code )
   .
                                end.
                        end.
                end.
        END CASE.
 END.
 END PROCEDURE.
PROCEDURE state-changed :
  DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE    NO-UNDO.
  DEFINE INPUT PARAMETER p-state      AS CHARACTER NO-UNDO.
  define variable fl as integer   no-undo .
  assign
    fl = 0
  .
  RUN get-attribute IN THIS-PROCEDURE ('UIB-MODE').
  IF RETURN-VALUE NE "DESIGN" THEN DO:
    DEFINE VARIABLE source-str AS CHARACTER.
    RUN get-link-handle IN adm-broker-hdl ( THIS-PROCEDURE, 'Record':U , OUTPUT source-str ) no-error.
    assign
      State-source = WIDGET-HANDLE ( source-str )
    .
    if valid-handle ( state-source ) then do:
      run return-var in state-source no-error.
    end.
    if date-start <> x-date-start
    or date-end <> x-date-end
    then do:
      assign
        FL = 1
      .
    end.
  END.
  CASE p-state:
    when "link-changed":U then  DO:
        IF FL = 0 Then DO:
            run assign-frame in this-procedure  .
            run local-apply-layout in this-procedure .
            end.
         else do:
            run local-apply-layout in this-procedure .
            run assign-frame in this-procedure  .
            end.
         run take-var in this-procedure .
    end.
  END CASE.
END PROCEDURE.
PROCEDURE take-var :
  RUN get-attribute IN THIS-PROCEDURE ('UIB-MODE').
  IF RETURN-VALUE NE "DESIGN" THEN DO:
    RUN get-link-handle IN adm-broker-hdl ( THIS-PROCEDURE, 'Record':U , OUTPUT source-str ).
    State-source = WIDGET-HANDLE ( source-str ).
    IF not VALID-HANDLE ( State-source ) THEN
      Message "Не определен линк " 'Record':U view-as alert-box error.
  END.
   Run get-var in State-source (OUTPUT temp-str,
    OUTPUT temp-param-date,
    OUTPUT temp-param-date-type-period,
    OUTPUT temp-param-goods,
    OUTPUT temp-param-obj,
    OUTPUT temp-param-pay,
    OUTPUT temp-param-pay-hide,
    OUTPUT temp-param-obj-type,
    OUTPUT temp-param-Alon  ,
    OUTPUT temp-param-customer,
    OUTPUT temp-param-customer-type,
    OUTPUT temp-param-schet        ,
    OUTPUT temp-param-schet-hide   ,
    OUTPUT temp-param-schet-init   ,
    OUTPUT temp-param-schet-mode ,
    output v-all-object
    ).
  define variable temp-param-time   as character no-undo .
  define variable temp-param-goods1 as character no-undo .
  define variable ii                as integer   no-undo .
  temp-param-goods-choose = "" .
  if temp-param-goods <> "" then
  do:
    if num-entries(temp-param-goods,":") > 1 then
    do:
      do ii = 1 to num-entries (temp-param-goods,","):
        temp-param-time = entry (ii,temp-param-goods,",") .
        if num-entries(temp-param-time,":") > 1 then
        do:
          temp-param-goods1 = temp-param-goods1 + "," + entry(1,temp-param-time,":") .
          temp-param-goods-choose = temp-param-goods-choose + "," + entry(2,temp-param-time,":") .
        end.
        else
        do:
          temp-param-goods1 = temp-param-goods1 + "," + temp-param-time .
        end.
      end.
    end.
  end.
  if temp-param-goods1 <> "" then temp-param-goods = trim(temp-param-goods1,",") .
  temp-param-goods-choose = trim(temp-param-goods-choose,",") .
END PROCEDURE.
PROCEDURE val-goods :
If temp-param-goods <> "" THEN DO:
 assign
  goods-count  = ''
  Goods-Editor = ''
  .
Case Integer(SelectGood:screen-value IN frame F-Main):
    When 1 then DO:
       Disable RECT-node RECT-node-2 BUTTON-gds button-keep-spis BUTTON-node BUTTON-prod BUTTON-one BUTTON-prod-2 BUTTON-node-2 with frame F-Main .
       Goods-Editor = " По всем товарам ".
       RECT-node:bgcolor = 8.
       RECT-node-2:bgcolor = 8.
       End.
    When 2 then DO:
       Disable RECT-node RECT-node-2 BUTTON-gds button-keep-spis BUTTON-prod  BUTTON-one BUTTON-prod-2 BUTTON-node-2  with frame F-Main .
       enable BUTTON-node  with frame F-Main .
       RECT-node:bgcolor = 8.
       RECT-node-2:bgcolor = 8.
       End.
    When 3 then DO:
       Disable RECT-node RECT-node-2 BUTTON-gds button-keep-spis BUTTON-node   BUTTON-one BUTTON-prod-2 BUTTON-node-2  with frame F-Main .
       enable BUTTON-prod  with frame F-Main .
       RECT-node:bgcolor = 8.
       RECT-node-2:bgcolor = 8.
       End.
    When 4 then DO:
       Disable RECT-node RECT-node-2 BUTTON-node BUTTON-prod button-keep-spis BUTTON-one BUTTON-prod-2 BUTTON-node-2  with frame F-Main .
       enable BUTTON-gds with frame F-Main .
       RECT-node:bgcolor = 8.
       RECT-node-2:bgcolor = 8.
        END.
    When 6 then DO:
       Disable RECT-node RECT-node-2 BUTTON-node button-gds BUTTON-prod BUTTON-one BUTTON-prod-2 BUTTON-node-2  with frame F-Main .
       enable button-keep-spis with frame F-Main .
       RECT-node:bgcolor = 8.
       RECT-node-2:bgcolor = 8.
       END.
    When 5 then DO:
       Disable RECT-node RECT-node-2  BUTTON-node BUTTON-prod  BUTTON-gds button-keep-spis BUTTON-prod-2 BUTTON-node-2 with frame F-Main .
       enable BUTTON-one with frame F-Main .
       RECT-node:bgcolor = 8.
       RECT-node-2:bgcolor = 8.
       End.
    When 7 then DO:
       Disable RECT-node RECT-node-2 BUTTON-one BUTTON-node BUTTON-prod  BUTTON-gds button-keep-spis with frame F-Main .
       enable BUTTON-prod-2 BUTTON-node-2  with frame F-Main .
       End.
  End case.
  enable goods-count   Goods-Editor  with frame F-Main.
  display goods-count   Goods-Editor with frame F-Main.
End.
  Else  hide goods-count Goods-Editor in frame F-Main.
END PROCEDURE.
PROCEDURE val-obj :
If SelectObject:screen-value IN FRAME F-Main = "choice":U
    then  enable BUTTON-obj with frame F-Main .
    Else Disable BUTTON-obj with frame F-Main .
END PROCEDURE.
PROCEDURE val-shift :
define buffer buf_shift-obj for ub.shift-obj .
if TOG-Shift:screen-value IN frame F-Main = string(true)  Then DO:
    TOG-Shift = true .
    if tog-shift-2 then do:
      enable  shift-start tog-shift-2 with frame F-Main .
      display shift-start tog-shift-2 with frame F-Main .
      disable button-shift-end with frame F-Main .
    end.
    else do:
      enable shift-end shift-start tog-shift-2 with frame F-Main .
      display shift-end shift-start tog-shift-2 with frame F-Main .
    end.
    if  can-find(first buf_shift-obj where
                       buf_shift-obj.obj-code = v-cntxt-obj-code and
                       buf_shift-obj.obj-type = v-cntxt-obj-type no-lock )
        then do:
          enable  button-shift-start button-shift-end  with frame F-Main .
          display button-shift-start button-shift-end  with frame F-Main .
           if tog-shift-2 then do:
              disable  button-shift-end with frame F-Main .
           end.
           else do:
              enable  button-shift-end with frame F-Main .
           end.
              display button-shift-end with frame F-Main .
        end.
 End.
 Else DO:
  Tog-Shift-2 = False.
  Tog-Shift   = False.
  enable date-end with frame F-Main .
  disable Shift-End Shift-Start Tog-Shift-2 button-shift-end button-shift-start with frame F-Main .
  display Shift-End Shift-Start Tog-Shift-2 date-end with frame F-Main .
  hide Shift-End Shift-Start Tog-Shift-2 button-shift-start button-shift-end in frame F-Main .
 End.
END PROCEDURE.
PROCEDURE verify-check :
define buffer buf_clients for ub.clients .
define buffer buf_db for ub.db .
    Find first buf_clients no-lock where
                                                buf_clients.obj-type = v-cntxt-obj-TYPE AND
                                                buf_clients.obj-code = v-cntxt-obj-CODE No-ERROR.
             If Verify-send-check and buf_Clients.db-num <> v-cntxt-db-num  THEN DO:
                Find first buf_db where buf_db.db-num = buf_clients.db-num no-lock.
                    if buf_db.send-check = false then DO:
                                                MESSAGE 'Нельзя выбрать текущий объект !' view-as alert-box error.
                                                run verify-check-currency in this-procedure .
                                                End.
                    else do:
define variable vss-include-info39 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run create_obj-list in this-procedure
 ( input buf_clients.obj-type ,
   input buf_clients.obj-code )
   .
                    end.
                END.
                else do:
define variable vss-include-info40 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run create_obj-list in this-procedure
 ( input buf_clients.obj-type ,
   input buf_clients.obj-code )
   .
                end.
END PROCEDURE.
PROCEDURE verify-check-currency :
define buffer buf_clients for ub.clients .
define buffer buf_db for ub.db .
if selectobject = "currency":U then do:
    find first buf_clients no-lock where  buf_clients.obj-type = v-cntxt-obj-type and
                                      buf_clients.obj-code = v-cntxt-obj-code no-error.
             if verify-send-check and buf_clients.db-num <> v-cntxt-db-num  then do:
                find first buf_db where buf_db.db-num = buf_clients.db-num no-lock.
                    if buf_db.send-check = false then do:
                      str-obj2# = str-obj2#  + " " + buf_clients.obj-name + ",".
                      assign selectobject = 'все':U .
                      display selectobject with frame F-Main .
                      disable button-obj   with frame F-Main .
                      run sss in this-procedure .
                      return error.
                      end.
             end.
end.
END PROCEDURE.
PROCEDURE verify-date :
if Date(Date-End:screen-value In frame F-Main) < DATE(Date-Start:screen-value In frame F-Main) then DO:
   message "Интервал дат введен неверно !" view-as alert-box error TITLE "О Ш И Б К А !!!".
   Return error.
End.
END PROCEDURE.
PROCEDURE verify-obj :
if temp-param-obj <> "" Then DO:
   if selectobject = "choice":U then do:
      my-request = true .
      run select-objects-proc.
   end.
  if not can-find (first obj-list no-lock) then do:
      message "Не выбран объект !" skip
              "Объекты не включенные в список" str-obj#    skip
              str-obj2#   skip
              str-obj3#   skip
              view-as alert-box error.
  return error.
  end.
end.
END PROCEDURE.
PROCEDURE verify-shift :
def input parameter date1 as date no-undo.
def input parameter Shift1 as int no-undo.
define buffer buf_shift-obj for ub.shift-obj .
if NOT can-find
(first buf_Shift-obj where  buf_Shift-obj.shift-num = Shift1
                    AND buf_Shift-obj.shift-date = date1
                    AND can-find (first obj-list where obj-list.obj-code = buf_shift-obj.obj-code
                                                   AND obj-list.obj-type = buf_shift-obj.obj-type)=true)
  THEN DO:
   Bell.
   message "Нет смены " shift1 date1 " !" view-as alert-box error TITLE "О Ш И Б К А !!!".
   Return error.
   End.
   else do:
     x-tog-shift = true .
   end.
END PROCEDURE.
FUNCTION stat-line RETURNS CHARACTER(input p-status-chr as character):
DEFINE VARIABLE var-stat-line as character no-undo .
CASE p-status-chr:
  when 'все':U then do:
    assign
    var-stat-line = "(текущие и неактивные товары)"
    .
  end.
  when 'текущие':U then do:
    assign
    var-stat-line = "(текущие товары)"
    .
  end.
  when 'удаленные':U then do:
    assign
    var-stat-line = "(неактивные товары)"
    .
  end.
END CASE.
return var-stat-line .
END.
