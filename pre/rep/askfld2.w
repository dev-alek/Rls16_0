def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Поля для отчета бенетона ".
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
define input-output parameter ParamStr as character no-undo .
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
DEFINE VARIABLE parParentProc     AS WIDGET-HANDLE NO-UNDO.
ASSIGN parParentProc =  my-handle .
  define variable g#userid as character no-undo .
  run get-userid  in parParentProc ( output g#userid ).
DEFINE BUTTON B-quit AUTO-END-KEY
     LABEL "Отмена"
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
DEFINE BUTTON B-exit AUTO-GO
     LABEL "Ввод"
     SIZE 12 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-unmark
     LABEL "Снять *"
     SIZE 12 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE FILL-IN-25 AS CHARACTER FORMAT "X(256)":U INITIAL "Цена поставщика"
      VIEW-AS TEXT
     SIZE 29 BY 1 NO-UNDO.
DEFINE VARIABLE FILL-IN-26 AS CHARACTER FORMAT "X(256)":U INITIAL "Розничная базовая цена"
      VIEW-AS TEXT
     SIZE 29 BY 1 NO-UNDO.
DEFINE VARIABLE FILL-IN-27 AS CHARACTER FORMAT "X(256)":U INITIAL "Розничная текущая цена"
      VIEW-AS TEXT
     SIZE 29 BY 1 NO-UNDO.
DEFINE VARIABLE FILL-IN-28 AS CHARACTER FORMAT "X(256)":U INITIAL "Заказы подробно"
      VIEW-AS TEXT
     SIZE 29 BY 1 NO-UNDO.
DEFINE VARIABLE FILL-IN-29 AS CHARACTER FORMAT "X(256)":U INITIAL "Остаток на складе в Италии"
      VIEW-AS TEXT
     SIZE 29 BY 1 NO-UNDO.
DEFINE VARIABLE FILL-IN-30 AS CHARACTER FORMAT "X(256)":U INITIAL "Приход внутр. (с др. объектов)"
      VIEW-AS TEXT
     SIZE 30.25 BY 1 NO-UNDO.
DEFINE VARIABLE FILL-IN-31 AS CHARACTER FORMAT "X(256)":U INITIAL "Остаток на складе"
      VIEW-AS TEXT
     SIZE 30.5 BY 1 NO-UNDO.
DEFINE VARIABLE FILL-IN-32 AS CHARACTER FORMAT "X(256)":U INITIAL "Заказы итого"
      VIEW-AS TEXT
     SIZE 29 BY 1 NO-UNDO.
DEFINE VARIABLE FILL-IN-48 AS CHARACTER FORMAT "X(256)":U INITIAL "Приход внешний подробно"
      VIEW-AS TEXT
     SIZE 29 BY 1 NO-UNDO.
DEFINE VARIABLE FILL-IN-49 AS CHARACTER FORMAT "X(256)":U INITIAL "Приход внутренний (отложка)"
      VIEW-AS TEXT
     SIZE 29 BY 1 NO-UNDO.
DEFINE VARIABLE FILL-IN-50 AS CHARACTER FORMAT "X(256)":U INITIAL "Приход внешний итого"
      VIEW-AS TEXT
     SIZE 29 BY 1 NO-UNDO.
DEFINE VARIABLE FILL-IN-52 AS CHARACTER FORMAT "X(256)":U INITIAL "Реализация за сезон"
      VIEW-AS TEXT
     SIZE 30.5 BY 1 NO-UNDO.
DEFINE VARIABLE FILL-IN-53 AS CHARACTER FORMAT "X(256)":U INITIAL "Реализация за период итого"
      VIEW-AS TEXT
     SIZE 30.5 BY 1 NO-UNDO.
DEFINE VARIABLE FILL-IN-54 AS CHARACTER FORMAT "X(256)":U INITIAL "Реализация за период подробно"
      VIEW-AS TEXT
     SIZE 30.5 BY 1 NO-UNDO.
DEFINE VARIABLE FILL-IN-55 AS CHARACTER FORMAT "X(256)":U INITIAL "Среднесуточная реализация"
      VIEW-AS TEXT
     SIZE 30.5 BY 1 NO-UNDO.
DEFINE VARIABLE FILL-IN-56 AS CHARACTER FORMAT "X(256)":U INITIAL "Внутр. перемещ. (на др. объект)"
      VIEW-AS TEXT
     SIZE 31.5 BY 1 NO-UNDO.
DEFINE VARIABLE FILL-IN-57 AS CHARACTER FORMAT "X(256)":U INITIAL "Инвентаризация"
      VIEW-AS TEXT
     SIZE 30.5 BY 1 NO-UNDO.
DEFINE VARIABLE FILL-IN-58 AS CHARACTER FORMAT "X(256)":U INITIAL "Нетто-Приход"
      VIEW-AS TEXT
     SIZE 29 BY 1 NO-UNDO.
DEFINE RECTANGLE RECT-21
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 73.38 BY 11.
DEFINE VARIABLE TOG-1 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .88 NO-UNDO.
DEFINE VARIABLE TOG-10 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .88 NO-UNDO.
DEFINE VARIABLE TOG-11 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .88 NO-UNDO.
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
     SIZE 2.5 BY .88 NO-UNDO.
DEFINE VARIABLE TOG-18 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .88 NO-UNDO.
DEFINE VARIABLE TOG-2 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .88 NO-UNDO.
DEFINE VARIABLE TOG-3 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .88 NO-UNDO.
DEFINE VARIABLE TOG-4 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .88 NO-UNDO.
DEFINE VARIABLE TOG-5 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .88 NO-UNDO.
DEFINE VARIABLE TOG-6 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .88 NO-UNDO.
DEFINE VARIABLE TOG-7 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .88 NO-UNDO.
DEFINE VARIABLE TOG-8 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .88 NO-UNDO.
DEFINE VARIABLE TOG-9 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .88 NO-UNDO.
DEFINE FRAME Dialog-Frame
     B-quit AT ROW 1 COL 2.25
     B-exit AT ROW 1 COL 14.25
     B-mark AT ROW 1 COL 26.25
     B-unmark AT ROW 1 COL 38.13
     B-help AT ROW 1 COL 50.25
     TOG-1 AT ROW 4.5 COL 33.63
     TOG-10 AT ROW 4.5 COL 70
     TOG-2 AT ROW 5.58 COL 33.63
     TOG-11 AT ROW 5.58 COL 70
     TOG-3 AT ROW 6.71 COL 33.63
     TOG-12 AT ROW 6.71 COL 70
     TOG-4 AT ROW 7.79 COL 33.63
     TOG-13 AT ROW 7.79 COL 70
     TOG-5 AT ROW 8.92 COL 33.63
     TOG-14 AT ROW 8.92 COL 70
     TOG-6 AT ROW 10 COL 33.63
     TOG-15 AT ROW 10 COL 70
     TOG-7 AT ROW 11.08 COL 33.63
     TOG-16 AT ROW 11.08 COL 70
     TOG-8 AT ROW 12.21 COL 33.63
     TOG-17 AT ROW 12.21 COL 70
     TOG-9 AT ROW 13.29 COL 33.63
     TOG-18 AT ROW 13.29 COL 70
     FILL-IN-25 AT ROW 4.5 COL 2.38 NO-LABEL
     FILL-IN-30 AT ROW 4.5 COL 35.75 COLON-ALIGNED NO-LABEL
     FILL-IN-58 AT ROW 5.54 COL 38 NO-LABEL
     FILL-IN-26 AT ROW 5.58 COL 2.38 NO-LABEL
     FILL-IN-31 AT ROW 6.54 COL 36.25 COLON-ALIGNED NO-LABEL
     FILL-IN-27 AT ROW 6.71 COL 2.38 NO-LABEL
     FILL-IN-52 AT ROW 7.67 COL 36.13 COLON-ALIGNED NO-LABEL
     FILL-IN-28 AT ROW 7.79 COL 2.38 NO-LABEL
     FILL-IN-53 AT ROW 8.75 COL 36.5 COLON-ALIGNED NO-LABEL
     FILL-IN-32 AT ROW 8.92 COL 2.38 NO-LABEL
     FILL-IN-54 AT ROW 9.88 COL 36.38 COLON-ALIGNED NO-LABEL
     FILL-IN-48 AT ROW 10 COL 2.38 NO-LABEL
     FILL-IN-55 AT ROW 10.96 COL 36.13 COLON-ALIGNED NO-LABEL
     FILL-IN-50 AT ROW 11.08 COL 2.38 NO-LABEL
     FILL-IN-56 AT ROW 12.04 COL 36.25 COLON-ALIGNED NO-LABEL
     FILL-IN-29 AT ROW 12.21 COL 2.38 NO-LABEL
     FILL-IN-57 AT ROW 13.17 COL 36.13 COLON-ALIGNED NO-LABEL
     FILL-IN-49 AT ROW 13.29 COL 2.38 NO-LABEL
     "Показать":C8 VIEW-AS TEXT
          SIZE 8.88 BY .67 AT ROW 2.63 COL 30
          FGCOLOR 4
     RECT-21 AT ROW 3.83 COL 1.88
     "Колонки":C28 VIEW-AS TEXT
          SIZE 25.38 BY .67 AT ROW 2.63 COL 1.88
          FGCOLOR 4
     "Колонки":C28 VIEW-AS TEXT
          SIZE 25.38 BY .67 AT ROW 2.63 COL 39.75
          FGCOLOR 4
     "Показать":C8 VIEW-AS TEXT
          SIZE 8.88 BY .67 AT ROW 2.63 COL 66.88
          FGCOLOR 4
     SPACE(0.61) SKIP(11.65)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Выбор колонок для печати"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON B-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-mark IN FRAME Dialog-Frame
DO:
  Assign
   TOG-1 = true
   TOG-2 = true
   TOG-3 = true
   TOG-4 = true
   TOG-5 = true
   TOG-6 = true
   TOG-7 = true
   TOG-8 = true
   TOG-9 = true
   TOG-10 = true
   TOG-11 = true
   TOG-12 = true
   TOG-13 = true
   TOG-14 = true
   TOG-15 = true
   TOG-16 = true
   TOG-17 = true
   TOG-18 = true
  .
  Display  TOG-1 TOG-10 TOG-2 TOG-11 TOG-3 TOG-12 TOG-4 TOG-13 TOG-5 TOG-14 TOG-6 TOG-15 TOG-7 TOG-16 TOG-8 TOG-17 TOG-9 TOG-18 with frame Dialog-Frame.
END.
ON CHOOSE OF B-exit IN FRAME Dialog-Frame
DO:
  def var l-ind as integer no-undo .
  assign TOG-1 TOG-10 TOG-2 TOG-11 TOG-3 TOG-12 TOG-4 TOG-13 TOG-5 TOG-14 TOG-6 TOG-15 TOG-7 TOG-16 TOG-8 TOG-17 TOG-9 TOG-18.
  assign ParamStr = "" .
  if TOG-1  = yes then ParamStr = ParamStr + "1," .
  if TOG-2  = yes then ParamStr = ParamStr + "2," .
  if TOG-3  = yes then ParamStr = ParamStr + "3," .
  if TOG-4  = yes then ParamStr = ParamStr + "4," .
  if TOG-5  = yes then ParamStr = ParamStr + "5," .
  if TOG-6  = yes then ParamStr = ParamStr + "6," .
  if TOG-7  = yes then ParamStr = ParamStr + "7," .
  if TOG-8  = yes then ParamStr = ParamStr + "8," .
  if TOG-9  = yes then ParamStr = ParamStr + "9," .
  if TOG-10 = yes then ParamStr = ParamStr + "10," .
  if TOG-11 = yes then ParamStr = ParamStr + "11," .
  if TOG-12 = yes then ParamStr = ParamStr + "12," .
  if TOG-13 = yes then ParamStr = ParamStr + "13," .
  if TOG-14 = yes then ParamStr = ParamStr + "14," .
  if TOG-15 = yes then ParamStr = ParamStr + "15," .
  if TOG-16 = yes then ParamStr = ParamStr + "16," .
  if TOG-17 = yes then ParamStr = ParamStr + "17," .
  if TOG-18 = yes then ParamStr = ParamStr + "18," .
 find first ubflt.usr-flt share-lock where
   ubflt.usr-flt.user-name  = g#userid and
   ubflt.usr-flt.call-point = "e-ben-dt":U
 no-error .
 if NOT avail ubflt.usr-flt then  create ubflt.usr-flt.
 Assign
   ubflt.usr-flt.user-name  = g#userid
   ubflt.usr-flt.call-point = "e-ben-dt":U
   ubflt.usr-flt.list_      = ParamStr
 .
END.
ON CHOOSE OF B-unmark IN FRAME Dialog-Frame
DO:
  Assign
   TOG-1 = false
   TOG-2 = false
   TOG-3 = false
   TOG-4 = false
   TOG-5 = false
   TOG-6 = false
   TOG-7 = false
   TOG-8 = false
   TOG-9 = false
   TOG-10 = false
   TOG-11 = false
   TOG-12 = false
   TOG-13 = false
   TOG-14 = false
   TOG-15 = false
   TOG-16 = false
   TOG-17 = false
   TOG-18 = false
  .
  Display  TOG-1 TOG-10 TOG-2 TOG-11 TOG-3 TOG-12 TOG-4 TOG-13 TOG-5 TOG-14 TOG-6 TOG-15 TOG-7 TOG-16 TOG-8 TOG-17 TOG-9 TOG-18 with frame Dialog-Frame.
END.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  def var  ii  as integer no-undo init 0 .
  DO ii = 1 TO NUM-ENTRIES(ParamStr):
    case integer(ENTRY(ii,ParamStr)) :
      when 1  then TOG-1  = yes .
      when 2  then TOG-2  = yes .
      when 3  then TOG-3  = yes .
      when 4  then TOG-4  = yes .
      when 5  then TOG-5  = yes .
      when 6  then TOG-6  = yes .
      when 7  then TOG-7  = yes .
      when 8  then TOG-8  = yes .
      when 9  then TOG-9  = yes .
      when 10 then TOG-10 = yes .
      when 11 then TOG-11 = yes .
      when 12 then TOG-12 = yes .
      when 13 then TOG-13 = yes .
      when 14 then TOG-14 = yes .
      when 15 then TOG-15 = yes .
      when 16 then TOG-16 = yes .
      when 17 then TOG-17 = yes .
      when 18 then TOG-18 = yes .
    end case.
  END.
  Display  TOG-1 TOG-10 TOG-2 TOG-11 TOG-3 TOG-12 TOG-4 TOG-13 TOG-5 TOG-14 TOG-6 TOG-15 TOG-7 TOG-16 TOG-8 TOG-17 TOG-9 TOG-18 with frame Dialog-Frame.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN enable_UI.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY TOG-1 TOG-10 TOG-2 TOG-11 TOG-3 TOG-12 TOG-4 TOG-13 TOG-5 TOG-14 TOG-6
          TOG-15 TOG-7 TOG-16 TOG-8 TOG-17 TOG-9 TOG-18 FILL-IN-25 FILL-IN-30
          FILL-IN-58 FILL-IN-26 FILL-IN-31 FILL-IN-27 FILL-IN-52 FILL-IN-28
          FILL-IN-53 FILL-IN-32 FILL-IN-54 FILL-IN-48 FILL-IN-55 FILL-IN-50
          FILL-IN-56 FILL-IN-29 FILL-IN-57 FILL-IN-49
      WITH FRAME Dialog-Frame.
  ENABLE RECT-21 B-quit B-exit B-mark B-unmark B-help TOG-1 TOG-10 TOG-2
         TOG-11 TOG-3 TOG-12 TOG-4 TOG-13 TOG-5 TOG-14 TOG-6 TOG-15 TOG-7
         TOG-16 TOG-8 TOG-17 TOG-9 TOG-18 FILL-IN-25 FILL-IN-30 FILL-IN-58
         FILL-IN-26 FILL-IN-31 FILL-IN-27 FILL-IN-52 FILL-IN-28 FILL-IN-53
         FILL-IN-32 FILL-IN-54 FILL-IN-48 FILL-IN-55 FILL-IN-50 FILL-IN-56
         FILL-IN-29 FILL-IN-57 FILL-IN-49
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE eq-frame :
  DISPLAY TOG-1 TOG-10 TOG-2 TOG-11 TOG-3 TOG-12 TOG-4 TOG-13 TOG-5 TOG-14 TOG-6
          TOG-15 TOG-7 TOG-16 TOG-8 TOG-17 TOG-9 TOG-18 FILL-IN-25 FILL-IN-30
          FILL-IN-58 FILL-IN-26 FILL-IN-31 FILL-IN-27 FILL-IN-52 FILL-IN-28
          FILL-IN-53 FILL-IN-32 FILL-IN-54 FILL-IN-48 FILL-IN-55 FILL-IN-50
          FILL-IN-56 FILL-IN-29 FILL-IN-57 FILL-IN-49
      WITH FRAME Dialog-Frame.
  ENABLE RECT-21 B-quit B-exit B-mark B-unmark B-help TOG-1 TOG-10 TOG-2
         TOG-11 TOG-3 TOG-12 TOG-4 TOG-13 TOG-5 TOG-14 TOG-6 TOG-15 TOG-7
         TOG-16 TOG-8 TOG-17 TOG-9 TOG-18 FILL-IN-25 FILL-IN-30 FILL-IN-58
         FILL-IN-26 FILL-IN-31 FILL-IN-27 FILL-IN-52 FILL-IN-28 FILL-IN-53
         FILL-IN-32 FILL-IN-54 FILL-IN-48 FILL-IN-55 FILL-IN-50 FILL-IN-56
         FILL-IN-29 FILL-IN-57 FILL-IN-49
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
