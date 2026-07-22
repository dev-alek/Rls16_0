define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init " Оборотная ведомость отчет ТПСИ (по типу приобретения )   ".
DEFINE VARIABLE  type-pr  AS WIDGET-HANDLE.
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
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable v-log as logical   no-undo .
CREATE WIDGET-POOL.
define variable State-source as  WIDGET-HANDLE.
DEFINE VARIABLE var-lavel AS INTEGER FORMAT ">>9":U INITIAL 1
     VIEW-AS FILL-IN NATIVE
     SIZE 5 BY 1 NO-UNDO.
DEFINE VARIABLE Classify AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Без классификации", "no-classify":U,
"Производители", "prod":U,
"Группы товаров", "grp-goods":U,
"Производители/Группы товаров", "prod/grp-goods":U,
"Группы товаров/Производители", "grp-goods/prod":U,
"Ставка НДС", "vat-ps":U
     size 32 by 5.67 NO-UNDO.
DEFINE VARIABLE r-gds AS INTEGER INITIAL 1
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Все товары", 2,
"Только свои", 3
     SIZE 35.38 BY .88 NO-UNDO.
DEFINE VARIABLE SortType AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "по коду", "sort-code":U,
"по артикулу", "sort-artic":U,
"по наимен.", "sort-name":U
     size 16.88 by 1.96 NO-UNDO.
DEFINE RECTANGLE RECT-5
     edge-chars 0.25 GRAPHIC-EDGE  NO-FILL
     SIZE 47.63 BY 8.63.
DEFINE RECTANGLE RECT-6
     edge-chars 0.25 GRAPHIC-EDGE  NO-FILL
     SIZE 47.63 BY 3.13.
DEFINE RECTANGLE RECT-8
     edge-chars 0.25 GRAPHIC-EDGE  NO-FILL
     SIZE 47.63 BY 4.38.
DEFINE RECTANGLE RECT-9
     edge-chars 0.25 GRAPHIC-EDGE  NO-FILL
     SIZE 30.63 BY 17.08.
DEFINE VARIABLE ShowZero AS LOGICAL INITIAL no
     LABEL "Нулевые остатки":L
     VIEW-AS TOGGLE-BOX
     size 19 by 0.83 NO-UNDO.
DEFINE VARIABLE ShowZero-2 AS LOGICAL INITIAL no
     LABEL "Нулевые обороты":L
     VIEW-AS TOGGLE-BOX
     size 19 by 0.83 NO-UNDO.
DEFINE VARIABLE SumsOnly AS LOGICAL INITIAL no
     LABEL "Только итоги":L
     VIEW-AS TOGGLE-BOX
     SIZE 19 BY .83 NO-UNDO.
DEFINE VARIABLE Tog-lavel AS LOGICAL INITIAL no
     LABEL "с уровня":L
     VIEW-AS TOGGLE-BOX
     size 12.63 by 1 NO-UNDO.
DEFINE VARIABLE Tog-obj AS LOGICAL INITIAL yes
     LABEL "Раздельно по объектам":L
     VIEW-AS TOGGLE-BOX
     size 39.38 by 1 NO-UNDO.
DEFINE VARIABLE VAT-Cost AS LOGICAL INITIAL no
     LABEL "НДС в учетных ценах":L
     VIEW-AS TOGGLE-BOX
     size 25.63 by 0.83 NO-UNDO.
DEFINE VARIABLE VAT-CRSA AS LOGICAL INITIAL no
     LABEL "НДС в продажных ценах":L
     VIEW-AS TOGGLE-BOX
     size 25.63 by 0.83 NO-UNDO.
DEFINE VARIABLE VAT-sale AS LOGICAL INITIAL no
     LABEL "НДС в ценах документа":L
     VIEW-AS TOGGLE-BOX
     size 25.63 by 0.83 NO-UNDO.
DEFINE FRAME F-Main
     Tog-obj at row 2.54 col 32.75
     Classify at row 3.79 col 32.75 NO-LABEL
     Tog-lavel at row 5.63 col 52
     var-lavel AT ROW 5.63 COL 63.38 COLON-ALIGNED NO-LABEL
     r-gds AT ROW 9.75 COL 43.25 NO-LABEL
     ShowZero-2 at row 12.04 col 33
     VAT-Cost at row 12.04 col 53.13
     ShowZero at row 12.92 col 33
     VAT-CRSA at row 12.92 col 53.13
     SumsOnly AT ROW 13.83 COL 33
     VAT-sale at row 13.83 col 53.13
     SortType at row 16.04 col 32.5 NO-LABEL
     "Товары :" VIEW-AS TEXT
          size 9 by 0.75 at row 9.75 col 32.75
          FGCOLOR 4
     "Сортировка :" VIEW-AS TEXT
          size 46.5 by 0.75 at row 15.17 col 32.63
          FGCOLOR 4
     RECT-6 AT ROW 15.08 COL 31.38
     "Классификация :" VIEW-AS TEXT
          size 46 by 0.75 at row 1.28 col 33
          FGCOLOR 4
     RECT-8 AT ROW 10.79 COL 31.38
     "Показать :" VIEW-AS TEXT
          size 46.13 by 0.75 at row 11 col 33
          FGCOLOR 4
     "Тип приобретения:" VIEW-AS TEXT
          SIZE 28.88 BY .67 AT ROW 1.38 COL 1.88
          FGCOLOR 4
     RECT-9 AT ROW 1.08 COL 1
     RECT-5 AT ROW 1 COL 31.38
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1 SCROLLABLE .
ASSIGN
       FRAME F-Main:SCROLLABLE       = FALSE
       FRAME F-Main:HIDDEN           = TRUE.
ASSIGN
       Tog-lavel:HIDDEN IN FRAME F-Main           = TRUE.
ASSIGN
       var-lavel:HIDDEN IN FRAME F-Main           = TRUE.
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
    DISABLE RECT-6 RECT-8 RECT-9 RECT-5 Tog-obj Classify r-gds ShowZero-2 VAT-Cost ShowZero VAT-CRSA VAT-sale SortType WITH FRAME F-Main.
    RUN dispatch ('disable-fields':U).
    RUN set-attribute-list ('ENABLED=no':U).
    RETURN.
END PROCEDURE.
PROCEDURE adm-edit-attribute-list :
      RUN adm/support/viewerd.w (INPUT THIS-PROCEDURE).
      RETURN.
END PROCEDURE.
PROCEDURE adm-enable :
    ENABLE UNLESS-HIDDEN RECT-6 RECT-8 RECT-9 RECT-5 Tog-obj Classify r-gds ShowZero-2 VAT-Cost ShowZero VAT-CRSA VAT-sale SortType WITH FRAME F-Main.
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
ON VALUE-CHANGED OF Classify IN FRAME F-Main
DO:
    Assign Classify.
    if Classify  Begins "prod":U OR
       Classify  Begins "grp-goods":U OR
       Classify  Begins "vat-ps":U
        then
        enable SumsOnly with frame F-Main .
   if Classify = "no-classify":U
      Then do:
            SumsOnly = FALSE .
            display SumsOnly with frame F-Main .
            disable SumsOnly with frame F-Main .
        end.
END.
ON VALUE-CHANGED OF Tog-lavel IN FRAME F-Main
DO:
   Assign tog-lavel.
  if tog-lavel =TRUE
        Then do:
            display  var-Lavel  with frame F-Main .
            enable   var-Lavel  with frame F-Main .
        end.
         Else do:
            display    var-Lavel with frame F-Main .
            disable    var-Lavel with frame F-Main .
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
PROCEDURE disable_UI :
  HIDE FRAME F-Main.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.
PROCEDURE local-initialize :
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ) .
   Tog-obj:screen-value in frame F-Main = 'yes':U.
   var-lavel:screen-value in frame F-Main = '1'.
define variable vss-include-info16 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    ,output v-log
    )  .
end.
 if not v-log then
    disable vat-Cost with frame F-Main.
define variable vss-include-info17 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    ,input  false
    ,output v-log
    )  .
end.
 if not v-log then
    disable vat-crsa with frame F-Main.
define variable vss-include-info18 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_reports_lookup-sale':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output v-log
    )  .
end.
 if not v-log then
    disable vat-sale with frame F-Main.
 run cr-ob in this-procedure
    ( 3 , 3 ,
    'Все,Выкуп,Консигнация,Ответственное хранение,Старая консигнация':L ,
    'all,r,cb,s,' + 'o':U).
END PROCEDURE.
PROCEDURE my-report :
for each obj-list :
   find first clients no-lock where
              clients.obj-code  = obj-list.obj-code  and
              clients.obj-type  = obj-list.obj-type  and
              clients.host-code = v-cntxt-host-code-obj no-error .
  if not available clients then do:
     message "Объект "
     obj-list.obj-code
     obj-list.obj-type
     obj-list.obj-name
     " не принадлежит фирме " v-cntxt-host-code-obj v-cntxt-host-name-obj
              "Определите список объектов , принадлежащих одной фирмы"
              view-as alert-box information .
     return error .
  end.
end.
run run-p in this-procedure  .
END PROCEDURE.
PROCEDURE my-var :
if VALID-HANDLE(type-pr) = false  then do:
    message "Нет архивов по типу приобретения !!!" skip
    view-as alert-box information .
    return 'First-page':U.
 end.
assign frame F-Main SumsOnly ShowZero tog-obj ShowZero-2
tog-lavel var-lavel Classify SortType r-gds VAT-Cost VAT-CRSA VAT-sale  .
if x-SelectObject = "currency":U and tog-obj = false then tog-obj = true .
Assign
 STR-obj-type = ''
 STR-obj-code = ''
 STR-obj-name = ''
 STR-obj      = ''.
For each obj-list no-lock:
 Assign
 STR-obj-type = STR-obj-type + obj-list.obj-type + ','
 STR-obj-code = STR-obj-code + String(obj-list.obj-code) + ','
 STR-obj-name = STR-obj-name + obj-list.obj-name + ','
 STR-obj = STR-obj +  obj-list.obj-type + '#' + string(obj-list.obj-code)  + ',' .
End.
ReportNAme = "О Т Ч Е Т  ТПСИ   по типу приобретения - "
                           + Caps ( entry( (lookup(type-pr:screen-value ,type-pr:RADIO-BUTTONS) - 1), type-pr:RADIO-BUTTONS )   )
                           .
def var t-class as char no-undo.
def var t-sort as char no-undo.
  case classify:
    when "no-classify":u    then t-class =   "Без классификации" .
    when "prod":u           then t-class =   "Производители"   .
    when "post":u           then t-class =   "Поставщики"   .
    when "grp-goods":u      then t-class =   "Группы товаров"  .
    when "post/grp-goods":u then t-class =   "Поставщики/Группы товаров" .
    when "prod/grp-goods":u then t-class =   "Производители/Группы товаров" .
    when "grp-goods/prod":u then t-class =   "Группы товаров/Производители" .
    when "grp-goods/post":u then t-class =   "Группы товаров/Поставщики" .
    when  "vat-ps":u        then t-class =   "Ставка НДС" .
    when  "sort":u          then t-class =   "Проба(Сорт)" .
    when  "n-level":u       then t-class =   "Группы с уровнем вложенности " .
    when  "t-level":u       then t-class =   "Терминальные группы" .
 end case.
  case sorttype:
    when "sort-pp":u               then t-sort =   "по порядку" .
    when "sort-code":u             then t-sort =   "по коду" .
    when "sort-artic":u            then t-sort =   "по артикулу"  .
    when "sort-qunty":u            then t-sort =   "по реализации".
    when "sort-name":u             then t-sort =   "по наименованию".
    when "sort-type":u             then t-sort =   "по типу ткани".
    when "sort-doc-code":u         then t-sort =   "по номеру документа".
    when "sort-recipe-code":u      then t-sort =   "по номеру рецепта".
 end case.
ReportHeader = "Классификация : " + t-Class.
ReportHeader = ReportHeader +
               (if tog-lavel  then "    Итоги с уровня  "  + String(var-lavel)  else " "    ).
ReportHeader = ReportHeader  + chr(10).
ReportHeader = ReportHeader +
               "Сортировка " + t-Sort + chr(10) +
               "Показать : " +
               (if SumsOnly     then "Только итоги, "  else " "            ) +
               (if Show-Cost    then "Суммы в учетных ценах, "  else " "   ) +
               (if Show-Crsa    then "Суммы в продажных ценах, "  else " " ) +
               (if Show-Sale    then "Суммы в продажных ценах документа , "  else " " ) +
               (if vat-Cost     then "НДС в учетных ценах, "  else " "   ) +
               (if vat-Crsa     then "НДС в продажных ценах, "  else " " ) +
               (if vat-Sale     then "НДС в продажных ценах документа , "  else " " ) +
               (if ShowZero     then " Показывать нулевые остатки "  else " Не показывать нулевые остатки" ) +
               (if ShowZero-2   then " Показывать нулевые обороты "  else " Не показывать нулевые обороты" ) .
if type-pr:screen-value = "all" then ReportHeader =  ReportHeader  +    chr(10) + "Итоги по типам приобретения показываются , если типов приобретения больше одного." .
Sheetf.Excel-Column-Lable = "Код,Артикул,Название товара ,Ед.изм,т/у,Скидка,Остаток на  начало,,,,,,,Приход,,,,,,,Расход,,,,,,,Касса,,,,,,,Инвентаризация|Смена типа приобретения,,,,,,,Переоценка,,,,,,,Остаток на конец,,,,,,,, "  + chr(10).
Sheetf.Excel-Column-Lable = Excel-Column-Lable + ",,,,,, " +
      Fill ( "кол-во ,учет.сумма ,прод.сумма ,в ценах док-та ,учет.НДС,прод.НДС,НДС в ценах док-та ," , 7) .
Sheetf.Sizes = "10,16,60,7,3,13," + Fill("13,", 49) .
Sheetf.make-correct = fill("false,", 55) .
Sheetf.ColFOrmat = "2=@;3=@"  .
END PROCEDURE.
def var vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure cr-ob :
 do
 on error undo, return error return-value
 :
define input parameter p-x as integer no-undo .
define input parameter p-y as integer no-undo .
define input parameter type-pr-name as character no-undo .
define input parameter type-pr-val  as character no-undo .
define variable l-str as character no-undo .
define variable i as integer no-undo .
if type-pr-name = ? then type-pr-name = 'Все,Выкуп,Консигнаци,Консигнация закупка,Консигнация выгода,Ответственное хранение,Старая консигнация':L .
if type-pr-val  = ?then type-pr-val  = 'all,r,cb,c,b,s,1':U .
repeat i = 1 to num-entries(type-pr-name) :
 l-str =  l-str  + entry(i ,type-pr-name) + ","  +
                   entry(i ,type-pr-val)  + "," .
end.
l-str = substring(l-str,1 , LENGTH (l-str) - 1) .
if num-entries(l-str) < 2 then do:
    message "Нет архивов по типу приобретения !!!" skip
    vss-include-info19 skip
    view-as alert-box information .
    return 'First-page':U.
   end.
   create radio-set type-pr
   assign
    row    = p-y
    column = p-x
    frame  = frame F-Main:handle
    horizontal    = false
    radio-buttons = l-str
 .
if valid-handle(type-pr) = false then do:
    message "Нет архивов по типу приобретения !!!" skip
    vss-include-info19 skip
    view-as alert-box information .
    return 'First-page':U.
 end.
  type-pr:sensitive = yes  .
  type-pr:visible   = yes  .
 end.
end procedure.
PROCEDURE run-p :
    if type-pr:screen-value = "all" then do:
    case SortType :
      when "sort-artic" then do:
        run proc-a in this-procedure .
      end.
      when "sort-code" then do:
        run proc-s in this-procedure .
      end.
      when "sort-name" then do:
        run proc-t in this-procedure .
      end.
    end case.
    end.
    else do:
      case SortType :
        when "sort-artic" then do:
          run proc-r in this-procedure .
        end.
        when "sort-code" then do:
          run proc-c in this-procedure .
        end.
        when "sort-name" then do:
          run proc-n in this-procedure .
        end.
      end case.
    end.
END PROCEDURE.
PROCEDURE state-changed :
  DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE    NO-UNDO.
  DEFINE INPUT PARAMETER p-state      AS CHARACTER NO-UNDO.
  CASE p-state:
  END CASE.
END PROCEDURE.
PROCEDURE proc-a :
case Classify :
  when "no-classify" then do:
     if tog-obj = true then
        run rep/tpoba-1y.p ( input type-pr:screen-value , input v-cntxt-obj-code , input v-cntxt-obj-type , input base-type  , input base-code  ,input Classify ,input SortType ,                    input SumsOnly  ,  input ShowZero  ,  input ShowZero-2 , input tog-obj    ,input tog-lavel,input var-lavel,                    input vat-cost, input vat-crsa , input vat-sale , input true , input r-gds ) .
      else
        run rep/tpoba-1n.p ( input type-pr:screen-value , input v-cntxt-obj-code , input v-cntxt-obj-type , input base-type  , input base-code  ,input Classify ,input SortType ,                    input SumsOnly  ,  input ShowZero  ,  input ShowZero-2 , input tog-obj    ,input tog-lavel,input var-lavel,                    input vat-cost, input vat-crsa , input vat-sale , input true , input r-gds ) .
  end.
  when "prod" then do:
     if tog-obj = true then
        run rep/tpoba-3y.p ( input type-pr:screen-value , input v-cntxt-obj-code , input v-cntxt-obj-type , input base-type  , input base-code  ,input Classify ,input SortType ,                    input SumsOnly  ,  input ShowZero  ,  input ShowZero-2 , input tog-obj    ,input tog-lavel,input var-lavel,                    input vat-cost, input vat-crsa , input vat-sale , input true , input r-gds ) .
      else
        run rep/tpoba-3n.p ( input type-pr:screen-value , input v-cntxt-obj-code , input v-cntxt-obj-type , input base-type  , input base-code  ,input Classify ,input SortType ,                    input SumsOnly  ,  input ShowZero  ,  input ShowZero-2 , input tog-obj    ,input tog-lavel,input var-lavel,                    input vat-cost, input vat-crsa , input vat-sale , input true , input r-gds ) .
  end.
  when "grp-goods" then do:
     if tog-obj = true then
        run rep/tpoba-2y.p ( input type-pr:screen-value , input v-cntxt-obj-code , input v-cntxt-obj-type , input base-type  , input base-code  ,input Classify ,input SortType ,                    input SumsOnly  ,  input ShowZero  ,  input ShowZero-2 , input tog-obj    ,input tog-lavel,input var-lavel,                    input vat-cost, input vat-crsa , input vat-sale , input true , input r-gds ) .
      else
        run rep/tpoba-2n.p ( input type-pr:screen-value , input v-cntxt-obj-code , input v-cntxt-obj-type , input base-type  , input base-code  ,input Classify ,input SortType ,                    input SumsOnly  ,  input ShowZero  ,  input ShowZero-2 , input tog-obj    ,input tog-lavel,input var-lavel,                    input vat-cost, input vat-crsa , input vat-sale , input true , input r-gds ) .
  end.
  when "prod/grp-goods" then do:
     if tog-obj = true then
        run rep/tpoba-4y.p ( input type-pr:screen-value , input v-cntxt-obj-code , input v-cntxt-obj-type , input base-type  , input base-code  ,input Classify ,input SortType ,                    input SumsOnly  ,  input ShowZero  ,  input ShowZero-2 , input tog-obj    ,input tog-lavel,input var-lavel,                    input vat-cost, input vat-crsa , input vat-sale , input true , input r-gds ) .
      else
        run rep/tpoba-4n.p ( input type-pr:screen-value , input v-cntxt-obj-code , input v-cntxt-obj-type , input base-type  , input base-code  ,input Classify ,input SortType ,                    input SumsOnly  ,  input ShowZero  ,  input ShowZero-2 , input tog-obj    ,input tog-lavel,input var-lavel,                    input vat-cost, input vat-crsa , input vat-sale , input true , input r-gds ) .
  end.
  when "grp-goods/prod" then do:
     if tog-obj = true then
        run rep/tpoba-5y.p ( input type-pr:screen-value , input v-cntxt-obj-code , input v-cntxt-obj-type , input base-type  , input base-code  ,input Classify ,input SortType ,                    input SumsOnly  ,  input ShowZero  ,  input ShowZero-2 , input tog-obj    ,input tog-lavel,input var-lavel,                    input vat-cost, input vat-crsa , input vat-sale , input true , input r-gds ) .
      else
        run rep/tpoba-5n.p ( input type-pr:screen-value , input v-cntxt-obj-code , input v-cntxt-obj-type , input base-type  , input base-code  ,input Classify ,input SortType ,                    input SumsOnly  ,  input ShowZero  ,  input ShowZero-2 , input tog-obj    ,input tog-lavel,input var-lavel,                    input vat-cost, input vat-crsa , input vat-sale , input true , input r-gds ) .
  end.
  when "vat-ps" then do:
     if tog-obj = true then
        run rep/tpoba-6y.p ( input type-pr:screen-value , input v-cntxt-obj-code , input v-cntxt-obj-type , input base-type  , input base-code  ,input Classify ,input SortType ,                    input SumsOnly  ,  input ShowZero  ,  input ShowZero-2 , input tog-obj    ,input tog-lavel,input var-lavel,                    input vat-cost, input vat-crsa , input vat-sale , input true , input r-gds ) .
      else
        run rep/tpoba-6n.p ( input type-pr:screen-value , input v-cntxt-obj-code , input v-cntxt-obj-type , input base-type  , input base-code  ,input Classify ,input SortType ,                    input SumsOnly  ,  input ShowZero  ,  input ShowZero-2 , input tog-obj    ,input tog-lavel,input var-lavel,                    input vat-cost, input vat-crsa , input vat-sale , input true , input r-gds ) .
  end.
end case.
END PROCEDURE.
PROCEDURE proc-s :
case Classify :
  when "no-classify" then do:
     if tog-obj = true then
        run rep/tpobs-1y.p ( input type-pr:screen-value , input v-cntxt-obj-code , input v-cntxt-obj-type , input base-type  , input base-code  ,input Classify ,input SortType ,                    input SumsOnly  ,  input ShowZero  ,  input ShowZero-2 , input tog-obj    ,input tog-lavel,input var-lavel,                    input vat-cost, input vat-crsa , input vat-sale , input true , input r-gds ) .
      else
        run rep/tpobs-1n.p ( input type-pr:screen-value , input v-cntxt-obj-code , input v-cntxt-obj-type , input base-type  , input base-code  ,input Classify ,input SortType ,                    input SumsOnly  ,  input ShowZero  ,  input ShowZero-2 , input tog-obj    ,input tog-lavel,input var-lavel,                    input vat-cost, input vat-crsa , input vat-sale , input true , input r-gds ) .
  end.
  when "prod" then do:
     if tog-obj = true then
        run rep/tpobs-3y.p ( input type-pr:screen-value , input v-cntxt-obj-code , input v-cntxt-obj-type , input base-type  , input base-code  ,input Classify ,input SortType ,                    input SumsOnly  ,  input ShowZero  ,  input ShowZero-2 , input tog-obj    ,input tog-lavel,input var-lavel,                    input vat-cost, input vat-crsa , input vat-sale , input true , input r-gds ) .
      else
        run rep/tpobs-3n.p ( input type-pr:screen-value , input v-cntxt-obj-code , input v-cntxt-obj-type , input base-type  , input base-code  ,input Classify ,input SortType ,                    input SumsOnly  ,  input ShowZero  ,  input ShowZero-2 , input tog-obj    ,input tog-lavel,input var-lavel,                    input vat-cost, input vat-crsa , input vat-sale , input true , input r-gds ) .
  end.
  when "grp-goods" then do:
     if tog-obj = true then
        run rep/tpobs-2y.p ( input type-pr:screen-value , input v-cntxt-obj-code , input v-cntxt-obj-type , input base-type  , input base-code  ,input Classify ,input SortType ,                    input SumsOnly  ,  input ShowZero  ,  input ShowZero-2 , input tog-obj    ,input tog-lavel,input var-lavel,                    input vat-cost, input vat-crsa , input vat-sale , input true , input r-gds ) .
      else
        run rep/tpobs-2n.p ( input type-pr:screen-value , input v-cntxt-obj-code , input v-cntxt-obj-type , input base-type  , input base-code  ,input Classify ,input SortType ,                    input SumsOnly  ,  input ShowZero  ,  input ShowZero-2 , input tog-obj    ,input tog-lavel,input var-lavel,                    input vat-cost, input vat-crsa , input vat-sale , input true , input r-gds ) .
  end.
  when "prod/grp-goods" then do:
     if tog-obj = true then
        run rep/tpobs-4y.p ( input type-pr:screen-value , input v-cntxt-obj-code , input v-cntxt-obj-type , input base-type  , input base-code  ,input Classify ,input SortType ,                    input SumsOnly  ,  input ShowZero  ,  input ShowZero-2 , input tog-obj    ,input tog-lavel,input var-lavel,                    input vat-cost, input vat-crsa , input vat-sale , input true , input r-gds ) .
      else
        run rep/tpobs-4n.p ( input type-pr:screen-value , input v-cntxt-obj-code , input v-cntxt-obj-type , input base-type  , input base-code  ,input Classify ,input SortType ,                    input SumsOnly  ,  input ShowZero  ,  input ShowZero-2 , input tog-obj    ,input tog-lavel,input var-lavel,                    input vat-cost, input vat-crsa , input vat-sale , input true , input r-gds ) .
  end.
  when "grp-goods/prod" then do:
     if tog-obj = true then
        run rep/tpobs-5y.p ( input type-pr:screen-value , input v-cntxt-obj-code , input v-cntxt-obj-type , input base-type  , input base-code  ,input Classify ,input SortType ,                    input SumsOnly  ,  input ShowZero  ,  input ShowZero-2 , input tog-obj    ,input tog-lavel,input var-lavel,                    input vat-cost, input vat-crsa , input vat-sale , input true , input r-gds ) .
      else
        run rep/tpobs-5n.p ( input type-pr:screen-value , input v-cntxt-obj-code , input v-cntxt-obj-type , input base-type  , input base-code  ,input Classify ,input SortType ,                    input SumsOnly  ,  input ShowZero  ,  input ShowZero-2 , input tog-obj    ,input tog-lavel,input var-lavel,                    input vat-cost, input vat-crsa , input vat-sale , input true , input r-gds ) .
  end.
  when "vat-ps" then do:
     if tog-obj = true then
        run rep/tpobs-6y.p ( input type-pr:screen-value , input v-cntxt-obj-code , input v-cntxt-obj-type , input base-type  , input base-code  ,input Classify ,input SortType ,                    input SumsOnly  ,  input ShowZero  ,  input ShowZero-2 , input tog-obj    ,input tog-lavel,input var-lavel,                    input vat-cost, input vat-crsa , input vat-sale , input true , input r-gds ) .
      else
        run rep/tpobs-6n.p ( input type-pr:screen-value , input v-cntxt-obj-code , input v-cntxt-obj-type , input base-type  , input base-code  ,input Classify ,input SortType ,                    input SumsOnly  ,  input ShowZero  ,  input ShowZero-2 , input tog-obj    ,input tog-lavel,input var-lavel,                    input vat-cost, input vat-crsa , input vat-sale , input true , input r-gds ) .
  end.
end case.
END PROCEDURE.
PROCEDURE proc-t :
case Classify :
  when "no-classify" then do:
     if tog-obj = true then
        run rep/tpobt-1y.p ( input type-pr:screen-value , input v-cntxt-obj-code , input v-cntxt-obj-type , input base-type  , input base-code  ,input Classify ,input SortType ,                    input SumsOnly  ,  input ShowZero  ,  input ShowZero-2 , input tog-obj    ,input tog-lavel,input var-lavel,                    input vat-cost, input vat-crsa , input vat-sale , input true , input r-gds ) .
      else
        run rep/tpobt-1n.p ( input type-pr:screen-value , input v-cntxt-obj-code , input v-cntxt-obj-type , input base-type  , input base-code  ,input Classify ,input SortType ,                    input SumsOnly  ,  input ShowZero  ,  input ShowZero-2 , input tog-obj    ,input tog-lavel,input var-lavel,                    input vat-cost, input vat-crsa , input vat-sale , input true , input r-gds ) .
  end.
  when "prod" then do:
     if tog-obj = true then
        run rep/tpobt-3y.p ( input type-pr:screen-value , input v-cntxt-obj-code , input v-cntxt-obj-type , input base-type  , input base-code  ,input Classify ,input SortType ,                    input SumsOnly  ,  input ShowZero  ,  input ShowZero-2 , input tog-obj    ,input tog-lavel,input var-lavel,                    input vat-cost, input vat-crsa , input vat-sale , input true , input r-gds ) .
      else
        run rep/tpobt-3n.p ( input type-pr:screen-value , input v-cntxt-obj-code , input v-cntxt-obj-type , input base-type  , input base-code  ,input Classify ,input SortType ,                    input SumsOnly  ,  input ShowZero  ,  input ShowZero-2 , input tog-obj    ,input tog-lavel,input var-lavel,                    input vat-cost, input vat-crsa , input vat-sale , input true , input r-gds ) .
  end.
  when "grp-goods" then do:
     if tog-obj = true then
        run rep/tpobt-2y.p ( input type-pr:screen-value , input v-cntxt-obj-code , input v-cntxt-obj-type , input base-type  , input base-code  ,input Classify ,input SortType ,                    input SumsOnly  ,  input ShowZero  ,  input ShowZero-2 , input tog-obj    ,input tog-lavel,input var-lavel,                    input vat-cost, input vat-crsa , input vat-sale , input true , input r-gds ) .
      else
        run rep/tpobt-2n.p ( input type-pr:screen-value , input v-cntxt-obj-code , input v-cntxt-obj-type , input base-type  , input base-code  ,input Classify ,input SortType ,                    input SumsOnly  ,  input ShowZero  ,  input ShowZero-2 , input tog-obj    ,input tog-lavel,input var-lavel,                    input vat-cost, input vat-crsa , input vat-sale , input true , input r-gds ) .
  end.
  when "prod/grp-goods" then do:
     if tog-obj = true then
        run rep/tpobt-4y.p ( input type-pr:screen-value , input v-cntxt-obj-code , input v-cntxt-obj-type , input base-type  , input base-code  ,input Classify ,input SortType ,                    input SumsOnly  ,  input ShowZero  ,  input ShowZero-2 , input tog-obj    ,input tog-lavel,input var-lavel,                    input vat-cost, input vat-crsa , input vat-sale , input true , input r-gds ) .
      else
        run rep/tpobt-4n.p ( input type-pr:screen-value , input v-cntxt-obj-code , input v-cntxt-obj-type , input base-type  , input base-code  ,input Classify ,input SortType ,                    input SumsOnly  ,  input ShowZero  ,  input ShowZero-2 , input tog-obj    ,input tog-lavel,input var-lavel,                    input vat-cost, input vat-crsa , input vat-sale , input true , input r-gds ) .
  end.
  when "grp-goods/prod" then do:
     if tog-obj = true then
        run rep/tpobt-5y.p ( input type-pr:screen-value , input v-cntxt-obj-code , input v-cntxt-obj-type , input base-type  , input base-code  ,input Classify ,input SortType ,                    input SumsOnly  ,  input ShowZero  ,  input ShowZero-2 , input tog-obj    ,input tog-lavel,input var-lavel,                    input vat-cost, input vat-crsa , input vat-sale , input true , input r-gds ) .
      else
        run rep/tpobt-5n.p ( input type-pr:screen-value , input v-cntxt-obj-code , input v-cntxt-obj-type , input base-type  , input base-code  ,input Classify ,input SortType ,                    input SumsOnly  ,  input ShowZero  ,  input ShowZero-2 , input tog-obj    ,input tog-lavel,input var-lavel,                    input vat-cost, input vat-crsa , input vat-sale , input true , input r-gds ) .
  end.
  when "vat-ps" then do:
     if tog-obj = true then
        run rep/tpobt-6y.p ( input type-pr:screen-value , input v-cntxt-obj-code , input v-cntxt-obj-type , input base-type  , input base-code  ,input Classify ,input SortType ,                    input SumsOnly  ,  input ShowZero  ,  input ShowZero-2 , input tog-obj    ,input tog-lavel,input var-lavel,                    input vat-cost, input vat-crsa , input vat-sale , input true , input r-gds ) .
      else
        run rep/tpobt-6n.p ( input type-pr:screen-value , input v-cntxt-obj-code , input v-cntxt-obj-type , input base-type  , input base-code  ,input Classify ,input SortType ,                    input SumsOnly  ,  input ShowZero  ,  input ShowZero-2 , input tog-obj    ,input tog-lavel,input var-lavel,                    input vat-cost, input vat-crsa , input vat-sale , input true , input r-gds ) .
  end.
end case.
END PROCEDURE.
PROCEDURE proc-r :
case Classify :
  when "no-classify" then do:
     if tog-obj = true then
        run rep/tpobr-1y.p ( input type-pr:screen-value , input v-cntxt-obj-code , input v-cntxt-obj-type , input base-type  , input base-code  ,input Classify ,input SortType ,                    input SumsOnly  ,  input ShowZero  ,  input ShowZero-2 , input tog-obj    ,input tog-lavel,input var-lavel,                    input vat-cost, input vat-crsa , input vat-sale , input true , input r-gds ) .
      else
        run rep/tpobr-1n.p ( input type-pr:screen-value , input v-cntxt-obj-code , input v-cntxt-obj-type , input base-type  , input base-code  ,input Classify ,input SortType ,                    input SumsOnly  ,  input ShowZero  ,  input ShowZero-2 , input tog-obj    ,input tog-lavel,input var-lavel,                    input vat-cost, input vat-crsa , input vat-sale , input true , input r-gds ) .
  end.
  when "prod" then do:
     if tog-obj = true then
        run rep/tpobr-3y.p ( input type-pr:screen-value , input v-cntxt-obj-code , input v-cntxt-obj-type , input base-type  , input base-code  ,input Classify ,input SortType ,                    input SumsOnly  ,  input ShowZero  ,  input ShowZero-2 , input tog-obj    ,input tog-lavel,input var-lavel,                    input vat-cost, input vat-crsa , input vat-sale , input true , input r-gds ) .
      else
        run rep/tpobr-3n.p ( input type-pr:screen-value , input v-cntxt-obj-code , input v-cntxt-obj-type , input base-type  , input base-code  ,input Classify ,input SortType ,                    input SumsOnly  ,  input ShowZero  ,  input ShowZero-2 , input tog-obj    ,input tog-lavel,input var-lavel,                    input vat-cost, input vat-crsa , input vat-sale , input true , input r-gds ) .
  end.
  when "grp-goods" then do:
     if tog-obj = true then
        run rep/tpobr-2y.p ( input type-pr:screen-value , input v-cntxt-obj-code , input v-cntxt-obj-type , input base-type  , input base-code  ,input Classify ,input SortType ,                    input SumsOnly  ,  input ShowZero  ,  input ShowZero-2 , input tog-obj    ,input tog-lavel,input var-lavel,                    input vat-cost, input vat-crsa , input vat-sale , input true , input r-gds ) .
      else
        run rep/tpobr-2n.p ( input type-pr:screen-value , input v-cntxt-obj-code , input v-cntxt-obj-type , input base-type  , input base-code  ,input Classify ,input SortType ,                    input SumsOnly  ,  input ShowZero  ,  input ShowZero-2 , input tog-obj    ,input tog-lavel,input var-lavel,                    input vat-cost, input vat-crsa , input vat-sale , input true , input r-gds ) .
  end.
  when "prod/grp-goods" then do:
     if tog-obj = true then
        run rep/tpobr-4y.p ( input type-pr:screen-value , input v-cntxt-obj-code , input v-cntxt-obj-type , input base-type  , input base-code  ,input Classify ,input SortType ,                    input SumsOnly  ,  input ShowZero  ,  input ShowZero-2 , input tog-obj    ,input tog-lavel,input var-lavel,                    input vat-cost, input vat-crsa , input vat-sale , input true , input r-gds ) .
      else
        run rep/tpobr-4n.p ( input type-pr:screen-value , input v-cntxt-obj-code , input v-cntxt-obj-type , input base-type  , input base-code  ,input Classify ,input SortType ,                    input SumsOnly  ,  input ShowZero  ,  input ShowZero-2 , input tog-obj    ,input tog-lavel,input var-lavel,                    input vat-cost, input vat-crsa , input vat-sale , input true , input r-gds ) .
  end.
  when "grp-goods/prod" then do:
     if tog-obj = true then
        run rep/tpobr-5y.p ( input type-pr:screen-value , input v-cntxt-obj-code , input v-cntxt-obj-type , input base-type  , input base-code  ,input Classify ,input SortType ,                    input SumsOnly  ,  input ShowZero  ,  input ShowZero-2 , input tog-obj    ,input tog-lavel,input var-lavel,                    input vat-cost, input vat-crsa , input vat-sale , input true , input r-gds ) .
      else
        run rep/tpobr-5n.p ( input type-pr:screen-value , input v-cntxt-obj-code , input v-cntxt-obj-type , input base-type  , input base-code  ,input Classify ,input SortType ,                    input SumsOnly  ,  input ShowZero  ,  input ShowZero-2 , input tog-obj    ,input tog-lavel,input var-lavel,                    input vat-cost, input vat-crsa , input vat-sale , input true , input r-gds ) .
  end.
  when "vat-ps" then do:
     if tog-obj = true then
        run rep/tpobr-6y.p ( input type-pr:screen-value , input v-cntxt-obj-code , input v-cntxt-obj-type , input base-type  , input base-code  ,input Classify ,input SortType ,                    input SumsOnly  ,  input ShowZero  ,  input ShowZero-2 , input tog-obj    ,input tog-lavel,input var-lavel,                    input vat-cost, input vat-crsa , input vat-sale , input true , input r-gds ) .
      else
        run rep/tpobr-6n.p ( input type-pr:screen-value , input v-cntxt-obj-code , input v-cntxt-obj-type , input base-type  , input base-code  ,input Classify ,input SortType ,                    input SumsOnly  ,  input ShowZero  ,  input ShowZero-2 , input tog-obj    ,input tog-lavel,input var-lavel,                    input vat-cost, input vat-crsa , input vat-sale , input true , input r-gds ) .
  end.
end case.
END PROCEDURE.
PROCEDURE proc-c :
case Classify :
  when "no-classify" then do:
     if tog-obj = true then
        run rep/tpobc-1y.p ( input type-pr:screen-value , input v-cntxt-obj-code , input v-cntxt-obj-type , input base-type  , input base-code  ,input Classify ,input SortType ,                    input SumsOnly  ,  input ShowZero  ,  input ShowZero-2 , input tog-obj    ,input tog-lavel,input var-lavel,                    input vat-cost, input vat-crsa , input vat-sale , input true , input r-gds ) .
      else
        run rep/tpobc-1n.p ( input type-pr:screen-value , input v-cntxt-obj-code , input v-cntxt-obj-type , input base-type  , input base-code  ,input Classify ,input SortType ,                    input SumsOnly  ,  input ShowZero  ,  input ShowZero-2 , input tog-obj    ,input tog-lavel,input var-lavel,                    input vat-cost, input vat-crsa , input vat-sale , input true , input r-gds ) .
  end.
  when "prod" then do:
     if tog-obj = true then
        run rep/tpobc-3y.p ( input type-pr:screen-value , input v-cntxt-obj-code , input v-cntxt-obj-type , input base-type  , input base-code  ,input Classify ,input SortType ,                    input SumsOnly  ,  input ShowZero  ,  input ShowZero-2 , input tog-obj    ,input tog-lavel,input var-lavel,                    input vat-cost, input vat-crsa , input vat-sale , input true , input r-gds ) .
      else
        run rep/tpobc-3n.p ( input type-pr:screen-value , input v-cntxt-obj-code , input v-cntxt-obj-type , input base-type  , input base-code  ,input Classify ,input SortType ,                    input SumsOnly  ,  input ShowZero  ,  input ShowZero-2 , input tog-obj    ,input tog-lavel,input var-lavel,                    input vat-cost, input vat-crsa , input vat-sale , input true , input r-gds ) .
  end.
  when "grp-goods" then do:
     if tog-obj = true then
        run rep/tpobc-2y.p ( input type-pr:screen-value , input v-cntxt-obj-code , input v-cntxt-obj-type , input base-type  , input base-code  ,input Classify ,input SortType ,                    input SumsOnly  ,  input ShowZero  ,  input ShowZero-2 , input tog-obj    ,input tog-lavel,input var-lavel,                    input vat-cost, input vat-crsa , input vat-sale , input true , input r-gds ) .
      else
        run rep/tpobc-2n.p ( input type-pr:screen-value , input v-cntxt-obj-code , input v-cntxt-obj-type , input base-type  , input base-code  ,input Classify ,input SortType ,                    input SumsOnly  ,  input ShowZero  ,  input ShowZero-2 , input tog-obj    ,input tog-lavel,input var-lavel,                    input vat-cost, input vat-crsa , input vat-sale , input true , input r-gds ) .
  end.
  when "prod/grp-goods" then do:
     if tog-obj = true then
        run rep/tpobc-4y.p ( input type-pr:screen-value , input v-cntxt-obj-code , input v-cntxt-obj-type , input base-type  , input base-code  ,input Classify ,input SortType ,                    input SumsOnly  ,  input ShowZero  ,  input ShowZero-2 , input tog-obj    ,input tog-lavel,input var-lavel,                    input vat-cost, input vat-crsa , input vat-sale , input true , input r-gds ) .
      else
        run rep/tpobc-4n.p ( input type-pr:screen-value , input v-cntxt-obj-code , input v-cntxt-obj-type , input base-type  , input base-code  ,input Classify ,input SortType ,                    input SumsOnly  ,  input ShowZero  ,  input ShowZero-2 , input tog-obj    ,input tog-lavel,input var-lavel,                    input vat-cost, input vat-crsa , input vat-sale , input true , input r-gds ) .
  end.
  when "grp-goods/prod" then do:
     if tog-obj = true then
        run rep/tpobc-5y.p ( input type-pr:screen-value , input v-cntxt-obj-code , input v-cntxt-obj-type , input base-type  , input base-code  ,input Classify ,input SortType ,                    input SumsOnly  ,  input ShowZero  ,  input ShowZero-2 , input tog-obj    ,input tog-lavel,input var-lavel,                    input vat-cost, input vat-crsa , input vat-sale , input true , input r-gds ) .
      else
        run rep/tpobc-5n.p ( input type-pr:screen-value , input v-cntxt-obj-code , input v-cntxt-obj-type , input base-type  , input base-code  ,input Classify ,input SortType ,                    input SumsOnly  ,  input ShowZero  ,  input ShowZero-2 , input tog-obj    ,input tog-lavel,input var-lavel,                    input vat-cost, input vat-crsa , input vat-sale , input true , input r-gds ) .
  end.
  when "vat-ps" then do:
     if tog-obj = true then
        run rep/tpobc-6y.p ( input type-pr:screen-value , input v-cntxt-obj-code , input v-cntxt-obj-type , input base-type  , input base-code  ,input Classify ,input SortType ,                    input SumsOnly  ,  input ShowZero  ,  input ShowZero-2 , input tog-obj    ,input tog-lavel,input var-lavel,                    input vat-cost, input vat-crsa , input vat-sale , input true , input r-gds ) .
      else
        run rep/tpobc-6n.p ( input type-pr:screen-value , input v-cntxt-obj-code , input v-cntxt-obj-type , input base-type  , input base-code  ,input Classify ,input SortType ,                    input SumsOnly  ,  input ShowZero  ,  input ShowZero-2 , input tog-obj    ,input tog-lavel,input var-lavel,                    input vat-cost, input vat-crsa , input vat-sale , input true , input r-gds ) .
  end.
end case.
END PROCEDURE.
PROCEDURE proc-n :
case Classify :
  when "no-classify" then do:
     if tog-obj = true then
        run rep/tpobn-1y.p ( input type-pr:screen-value , input v-cntxt-obj-code , input v-cntxt-obj-type , input base-type  , input base-code  ,input Classify ,input SortType ,                    input SumsOnly  ,  input ShowZero  ,  input ShowZero-2 , input tog-obj    ,input tog-lavel,input var-lavel,                    input vat-cost, input vat-crsa , input vat-sale , input true , input r-gds ) .
      else
        run rep/tpobn-1n.p ( input type-pr:screen-value , input v-cntxt-obj-code , input v-cntxt-obj-type , input base-type  , input base-code  ,input Classify ,input SortType ,                    input SumsOnly  ,  input ShowZero  ,  input ShowZero-2 , input tog-obj    ,input tog-lavel,input var-lavel,                    input vat-cost, input vat-crsa , input vat-sale , input true , input r-gds ) .
  end.
  when "prod" then do:
     if tog-obj = true then
        run rep/tpobn-3y.p ( input type-pr:screen-value , input v-cntxt-obj-code , input v-cntxt-obj-type , input base-type  , input base-code  ,input Classify ,input SortType ,                    input SumsOnly  ,  input ShowZero  ,  input ShowZero-2 , input tog-obj    ,input tog-lavel,input var-lavel,                    input vat-cost, input vat-crsa , input vat-sale , input true , input r-gds ) .
      else
        run rep/tpobn-3n.p ( input type-pr:screen-value , input v-cntxt-obj-code , input v-cntxt-obj-type , input base-type  , input base-code  ,input Classify ,input SortType ,                    input SumsOnly  ,  input ShowZero  ,  input ShowZero-2 , input tog-obj    ,input tog-lavel,input var-lavel,                    input vat-cost, input vat-crsa , input vat-sale , input true , input r-gds ) .
  end.
  when "grp-goods" then do:
     if tog-obj = true then
        run rep/tpobn-2y.p ( input type-pr:screen-value , input v-cntxt-obj-code , input v-cntxt-obj-type , input base-type  , input base-code  ,input Classify ,input SortType ,                    input SumsOnly  ,  input ShowZero  ,  input ShowZero-2 , input tog-obj    ,input tog-lavel,input var-lavel,                    input vat-cost, input vat-crsa , input vat-sale , input true , input r-gds ) .
      else
        run rep/tpobn-2n.p ( input type-pr:screen-value , input v-cntxt-obj-code , input v-cntxt-obj-type , input base-type  , input base-code  ,input Classify ,input SortType ,                    input SumsOnly  ,  input ShowZero  ,  input ShowZero-2 , input tog-obj    ,input tog-lavel,input var-lavel,                    input vat-cost, input vat-crsa , input vat-sale , input true , input r-gds ) .
  end.
  when "prod/grp-goods" then do:
     if tog-obj = true then
        run rep/tpobn-4y.p ( input type-pr:screen-value , input v-cntxt-obj-code , input v-cntxt-obj-type , input base-type  , input base-code  ,input Classify ,input SortType ,                    input SumsOnly  ,  input ShowZero  ,  input ShowZero-2 , input tog-obj    ,input tog-lavel,input var-lavel,                    input vat-cost, input vat-crsa , input vat-sale , input true , input r-gds ) .
      else
        run rep/tpobn-4n.p ( input type-pr:screen-value , input v-cntxt-obj-code , input v-cntxt-obj-type , input base-type  , input base-code  ,input Classify ,input SortType ,                    input SumsOnly  ,  input ShowZero  ,  input ShowZero-2 , input tog-obj    ,input tog-lavel,input var-lavel,                    input vat-cost, input vat-crsa , input vat-sale , input true , input r-gds ) .
  end.
  when "grp-goods/prod" then do:
     if tog-obj = true then
        run rep/tpobn-5y.p ( input type-pr:screen-value , input v-cntxt-obj-code , input v-cntxt-obj-type , input base-type  , input base-code  ,input Classify ,input SortType ,                    input SumsOnly  ,  input ShowZero  ,  input ShowZero-2 , input tog-obj    ,input tog-lavel,input var-lavel,                    input vat-cost, input vat-crsa , input vat-sale , input true , input r-gds ) .
      else
        run rep/tpobn-5n.p ( input type-pr:screen-value , input v-cntxt-obj-code , input v-cntxt-obj-type , input base-type  , input base-code  ,input Classify ,input SortType ,                    input SumsOnly  ,  input ShowZero  ,  input ShowZero-2 , input tog-obj    ,input tog-lavel,input var-lavel,                    input vat-cost, input vat-crsa , input vat-sale , input true , input r-gds ) .
  end.
  when "vat-ps" then do:
     if tog-obj = true then
        run rep/tpobn-6y.p ( input type-pr:screen-value , input v-cntxt-obj-code , input v-cntxt-obj-type , input base-type  , input base-code  ,input Classify ,input SortType ,                    input SumsOnly  ,  input ShowZero  ,  input ShowZero-2 , input tog-obj    ,input tog-lavel,input var-lavel,                    input vat-cost, input vat-crsa , input vat-sale , input true , input r-gds ) .
      else
        run rep/tpobn-6n.p ( input type-pr:screen-value , input v-cntxt-obj-code , input v-cntxt-obj-type , input base-type  , input base-code  ,input Classify ,input SortType ,                    input SumsOnly  ,  input ShowZero  ,  input ShowZero-2 , input tog-obj    ,input tog-lavel,input var-lavel,                    input vat-cost, input vat-crsa , input vat-sale , input true , input r-gds ) .
  end.
end case.
END PROCEDURE.
