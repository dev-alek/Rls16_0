def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "".
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
define temp-table temp_onewin_items no-undo
    field itm-key       as integer
    field itmExtKey     as character
    field itmName       as character
    field itmDesc       as character
    field itmSelected   as logical
    index pi is primary unique
        itm-key
    index ie
        itmExtKey
.
define temp-table temp_onewin_itemsSelected no-undo
    field its-key   as integer
    field itm-key   as integer
    field itmExtKey as character
    index pi is primary unique
        its-key
    index im
        itm-key
.
define variable v-onewin7-itm-key    as integer      no-undo.
procedure onewin_clear :
    define buffer buf_temp_onewin_items        for temp_onewin_items.
do
for buf_temp_onewin_items
on error undo, return error
:
    empty temp-table buf_temp_onewin_items.
end.
end procedure.
procedure onewin_add-item :
define input parameter p-ext-key   as character        no-undo.
define input parameter p-item-name as character        no-undo.
define input parameter p-item-desc as character        no-undo.
define input parameter p-selected  as logical          no-undo.
    define buffer buf_temp_onewin_items        for temp_onewin_items.
do
for buf_temp_onewin_items
on error undo, return error
:
    find last buf_temp_onewin_items no-error.
    if available buf_temp_onewin_items then do:
      v-onewin7-itm-key = buf_temp_onewin_items.itm-key.
    end.
    else do:
      v-onewin7-itm-key = 0.
    end.
    assign
        v-onewin7-itm-key = v-onewin7-itm-key + 1
    .
    create buf_temp_onewin_items.
    assign
    buf_temp_onewin_items.itm-key      = v-onewin7-itm-key
    buf_temp_onewin_items.itmExtKey    = p-ext-key
    buf_temp_onewin_items.itmName      = p-item-name
    buf_temp_onewin_items.itmDesc      = p-item-desc
    buf_temp_onewin_items.itmSelected  = p-selected
    .
end.
end procedure.
procedure onewin_create-selection :
define input parameter p-itm-key as integer no-undo .
define input parameter p-itmextkey as character no-undo .
define variable v-counter as integer no-undo .
define buffer buf_temp_onewin_itemsSelected for temp_onewin_itemsSelected .
do
on error undo, return error
:
  find last buf_temp_onewin_itemsSelected use-index pi no-error.
  if available buf_temp_onewin_itemsSelected then do:
    v-counter = buf_temp_onewin_itemsSelected.its-key.
  end.
  find first buf_temp_onewin_itemsSelected where
       buf_temp_onewin_itemsSelected.itm-key = p-itm-key no-error.
  if not available buf_temp_onewin_itemsSelected then do:
    create buf_temp_onewin_itemsSelected.
    assign
    buf_temp_onewin_itemsSelected.its-key   = v-counter + 1
    v-counter = v-counter + 1
    buf_temp_onewin_itemsSelected.itm-key   = p-itm-key
    buf_temp_onewin_itemsSelected.itmExtKey = p-itmExtKey
    .
  end.
end.
end procedure.
procedure onewin_check-item :
define input parameter p-ext-key   as character        no-undo.
define output parameter p-exists as logical no-undo .
define buffer buf_temp_onewin_items for temp_onewin_items.
find first buf_temp_onewin_items where
buf_temp_onewin_items.itmExtKey    = p-ext-key no-error.
if available buf_temp_onewin_items then do:
  p-exists = yes.
end.
end procedure.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
CREATE WIDGET-POOL.
def var State-source as  WIDGET-HANDLE.
def buffer cli-post for ub.clients .
define variable events_recids  as character     no-undo .
define variable cd_recids      as character     no-undo .
define variable v-time-start   as integer       no-undo .
define variable v-time-end     as integer       no-undo .
define variable v-user-id      as character     no-undo .
define variable parparentproc  as widget-handle no-undo .
define variable v-supmode-id   as character     no-undo .
define variable v-b-codes      as character     no-undo .
define variable ii             as integer       no-undo .
DEFINE BUTTON b-cd-mode-select
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "v doc 2"
     SIZE 3 BY 1.
DEFINE BUTTON b-dc-sellect
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "user sellect 2"
     SIZE 3 BY 1.
DEFINE BUTTON b-doc-select
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Button 2"
     SIZE 3 BY 1.
DEFINE BUTTON b-user-sellect
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Button 1"
     SIZE 3 BY 1.
DEFINE VARIABLE event-type AS CHARACTER FORMAT "X(256)":U INITIAL "All"
     LABEL "Тип"
     VIEW-AS COMBO-BOX INNER-LINES 4
     LIST-ITEM-PAIRS "Все","All",
                     "Запрос пользователя","U",
                     "Реакция системы","S",
                     "Ошибка","E"
     DROP-DOWN-LIST
     SIZE 16.5 BY 1 NO-UNDO.
DEFINE VARIABLE v-disc-type AS INTEGER FORMAT ">9":U INITIAL 1
     VIEW-AS COMBO-BOX INNER-LINES 2
     LIST-ITEM-PAIRS "Любая",1,
                     "Процентная",2,
                     "Абсолютная",3
     DROP-DOWN-LIST
     SIZE 19.5 BY 1 NO-UNDO.
DEFINE VARIABLE ed-b-codes AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 31 BY 1.75 TOOLTIP "Список выбранных Поставщиков"
     FONT 4 NO-UNDO.
DEFINE VARIABLE ed-cd-names AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 31 BY 1.75 TOOLTIP "Список выбранных Поставщиков"
     FONT 4 NO-UNDO.
DEFINE VARIABLE ed-EventsName AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 31 BY 1.75 TOOLTIP "Список выбранных Поставщиков"
     FONT 4 NO-UNDO.
DEFINE VARIABLE v-bc-num AS CHARACTER FORMAT "X(16)":U
     VIEW-AS FILL-IN
     SIZE 21.5 BY 1 NO-UNDO.
DEFINE VARIABLE v-cd-supmode AS CHARACTER FORMAT "X(256)":U
     LABEL "Режим кассы"
     VIEW-AS FILL-IN
     SIZE 27.5 BY 1 NO-UNDO.
DEFINE VARIABLE v-dc-num AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 18.5 BY 1 NO-UNDO.
DEFINE VARIABLE v-disc-max AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0
     LABEL "по"
     VIEW-AS FILL-IN
     SIZE 11.88 BY 1 NO-UNDO.
DEFINE VARIABLE v-disc-min AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0
     LABEL "Диапазон скидок с"
     VIEW-AS FILL-IN
     SIZE 11.63 BY 1 NO-UNDO.
DEFINE VARIABLE v-doc-num AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 18.5 BY 1 NO-UNDO.
DEFINE VARIABLE v-h-end AS INTEGER FORMAT "99":U INITIAL 23
     LABEL "мин.  по"
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.
DEFINE VARIABLE v-h-start AS INTEGER FORMAT "99":U INITIAL 0
     LABEL "Время с"
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.
DEFINE VARIABLE v-m-end AS INTEGER FORMAT "99":U INITIAL 59
     LABEL ""
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.
DEFINE VARIABLE v-m-start AS INTEGER FORMAT "99":U INITIAL 0
     LABEL ""
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.
DEFINE VARIABLE v-qnty-max AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0
     LABEL "по"
     VIEW-AS FILL-IN
     SIZE 11.88 BY 1 NO-UNDO.
DEFINE VARIABLE v-qnty-min AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0
     LABEL "Диапазон кол-ва с"
     VIEW-AS FILL-IN
     SIZE 11.63 BY 1 NO-UNDO.
DEFINE VARIABLE v-summ-max AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0
     LABEL "по"
     VIEW-AS FILL-IN
     SIZE 11.88 BY 1 NO-UNDO.
DEFINE VARIABLE v-summ-min AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0
     LABEL "Диапазон сумм с"
     VIEW-AS FILL-IN
     SIZE 11.63 BY 1 NO-UNDO.
DEFINE VARIABLE v-user-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 18.5 BY 1 NO-UNDO.
DEFINE VARIABLE rb-b-codes AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Все", 1,
"Выборочно", 2
     SIZE 12 BY 1.75 NO-UNDO.
DEFINE VARIABLE rb-cd AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Все", 1,
"Выборочно", 2
     SIZE 12 BY 1.75 NO-UNDO.
DEFINE VARIABLE rb-events AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Все", 1,
"Выборочно", 2
     SIZE 12 BY 1.5 NO-UNDO.
DEFINE FRAME F-Main
     ed-EventsName AT ROW 2 COL 15.5 NO-LABEL
     event-type AT ROW 2.08 COL 52 COLON-ALIGNED WIDGET-ID 20
     rb-events AT ROW 2.13 COL 3 NO-LABEL
     b-user-sellect AT ROW 4.13 COL 67.5 WIDGET-ID 24
     v-user-name AT ROW 4.17 COL 47 COLON-ALIGNED NO-LABEL WIDGET-ID 90
     rb-cd AT ROW 4.63 COL 3 NO-LABEL WIDGET-ID 2
     ed-cd-names AT ROW 4.63 COL 15.5 NO-LABEL WIDGET-ID 12
     v-doc-num AT ROW 6.13 COL 47 COLON-ALIGNED NO-LABEL WIDGET-ID 92
     b-doc-select AT ROW 6.13 COL 67.5 WIDGET-ID 46
     v-cd-supmode AT ROW 6.75 COL 13.5 COLON-ALIGNED WIDGET-ID 100
     b-cd-mode-select AT ROW 6.75 COL 43 WIDGET-ID 84
     b-dc-sellect AT ROW 8.04 COL 67.5 WIDGET-ID 80
     v-dc-num AT ROW 8.13 COL 47 COLON-ALIGNED NO-LABEL WIDGET-ID 94
     rb-b-codes AT ROW 8.75 COL 3 NO-LABEL WIDGET-ID 16
     ed-b-codes AT ROW 8.75 COL 15.5 NO-LABEL WIDGET-ID 14
     v-bc-num AT ROW 9.88 COL 47 COLON-ALIGNED NO-LABEL WIDGET-ID 96
     v-h-start AT ROW 11.33 COL 10.38 COLON-ALIGNED WIDGET-ID 28
     v-m-start AT ROW 11.33 COL 16.25 COLON-ALIGNED WIDGET-ID 30
     v-h-end AT ROW 11.33 COL 30.25 COLON-ALIGNED WIDGET-ID 32
     v-m-end AT ROW 11.33 COL 36 COLON-ALIGNED WIDGET-ID 34
     v-summ-min AT ROW 12.83 COL 18.38 COLON-ALIGNED WIDGET-ID 38
     v-summ-max AT ROW 12.83 COL 35.13 COLON-ALIGNED WIDGET-ID 40
     v-qnty-min AT ROW 14.29 COL 18.38 COLON-ALIGNED WIDGET-ID 44
     v-qnty-max AT ROW 14.29 COL 35.13 COLON-ALIGNED WIDGET-ID 42
     v-disc-min AT ROW 15.75 COL 18.38 COLON-ALIGNED WIDGET-ID 72
     v-disc-max AT ROW 15.75 COL 35.13 COLON-ALIGNED WIDGET-ID 70
     v-disc-type AT ROW 15.79 COL 49 COLON-ALIGNED NO-LABEL WIDGET-ID 102
     "мин." VIEW-AS TEXT
          SIZE 4.38 BY .67 AT ROW 11.54 COL 42.13 WIDGET-ID 36
     "Список событий:" VIEW-AS TEXT
          SIZE 19.38 BY .67 AT ROW 1.25 COL 7.13
          FGCOLOR 4
     "Список касс:" VIEW-AS TEXT
          SIZE 13.5 BY .67 AT ROW 3.88 COL 6.5 WIDGET-ID 8
          FGCOLOR 4
     "Список штрихкодов:" VIEW-AS TEXT
          SIZE 19.38 BY .67 AT ROW 8 COL 6.5 WIDGET-ID 10
          FGCOLOR 4
     "Пользователь:" VIEW-AS TEXT
          SIZE 13.5 BY .67 AT ROW 3.42 COL 49.38 WIDGET-ID 22
          FGCOLOR 4
     "Дисконтная карта:" VIEW-AS TEXT
          SIZE 21.5 BY .67 AT ROW 7.38 COL 49 WIDGET-ID 76
          FGCOLOR 4
     "Тип скидки:" VIEW-AS TEXT
          SIZE 13.5 BY .67 AT ROW 15.13 COL 51 WIDGET-ID 74
          FGCOLOR 4
     "Тип и номер документа:" VIEW-AS TEXT
          SIZE 21.5 BY .75 AT ROW 5.38 COL 49 WIDGET-ID 48
          FGCOLOR 4
     "Банковская карта:" VIEW-AS TEXT
          SIZE 18 BY .75 AT ROW 9.13 COL 49.5 WIDGET-ID 78
          FGCOLOR 4
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1 SCROLLABLE .
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
    DISABLE ed-EventsName event-type rb-events b-user-sellect rb-cd ed-cd-names b-doc-select b-cd-mode-select b-dc-sellect rb-b-codes ed-b-codes v-bc-num v-h-start v-m-start v-h-end v-m-end v-summ-min v-summ-max v-qnty-min v-qnty-max v-disc-min v-disc-max v-disc-type WITH FRAME F-Main.
    RUN dispatch ('disable-fields':U).
    RUN set-attribute-list ('ENABLED=no':U).
    RETURN.
END PROCEDURE.
PROCEDURE adm-edit-attribute-list :
      RUN adm/support/viewerd.w (INPUT THIS-PROCEDURE).
      RETURN.
END PROCEDURE.
PROCEDURE adm-enable :
    ENABLE UNLESS-HIDDEN ed-EventsName event-type rb-events b-user-sellect rb-cd ed-cd-names b-doc-select b-cd-mode-select b-dc-sellect rb-b-codes ed-b-codes v-bc-num v-h-start v-m-start v-h-end v-m-end v-summ-min v-summ-max v-qnty-min v-qnty-max v-disc-min v-disc-max v-disc-type WITH FRAME F-Main.
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
       FRAME F-Main:SCROLLABLE                      = FALSE
       FRAME F-Main:HIDDEN                          = TRUE.
ASSIGN
       ed-b-codes:READ-ONLY IN FRAME F-Main         = TRUE.
ASSIGN
       ed-cd-names:READ-ONLY IN FRAME F-Main        = TRUE.
ASSIGN
       ed-EventsName:READ-ONLY IN FRAME F-Main      = TRUE.
ASSIGN
       v-cd-supmode:READ-ONLY IN FRAME F-Main       = TRUE.
ASSIGN
       v-dc-num:READ-ONLY IN FRAME F-Main           = TRUE.
ASSIGN
       v-doc-num:READ-ONLY IN FRAME F-Main          = TRUE.
ASSIGN
       v-user-name:READ-ONLY IN FRAME F-Main        = TRUE.
ON CHOOSE OF b-cd-mode-select IN FRAME F-Main
DO:
   define variable v-rid    as character    no-undo.
   define buffer buf_wi-mode     for ub.wi-mode .
   run adm/wi-modes.w   ( INPUT parparentproc
                        , INPUT 'b-sel':U
                        , input 'все':U
                        , input ""
                        , INPUT-OUTPUT v-rid
                        ) NO-ERROR.
   if v-rid = ""
   then do:
      RETURN.
   end.
   find first buf_wi-mode
      where recid( buf_wi-mode ) = INTEGER(ENTRY(1, v-rid))
      NO-LOCK
      no-error.
   IF AVAILABLE buf_wi-mode THEN DO:
      ASSIGN
         v-supmode-id =  buf_wi-mode.mode-id
         v-cd-supmode =  buf_wi-mode.mode-name
      .
   END.
   Display
      v-cd-supmode
   with frame F-Main
   .
END.
ON CHOOSE OF b-dc-sellect IN FRAME F-Main
DO:
   define variable v-rid    as character    no-undo.
   define buffer buf_dis-card    for ub.dis-card .
   run ref/discards.w
      ( parParentProc
      , "b-sel"
      , 'все':U
      , v-cntxt-host-code-obj
      , v-cntxt-obj-type
      , v-cntxt-obj-code
      , ?
      , ?
      , output v-rid
      ) .
   if v-rid = ""
   then do:
      RETURN.
   end.
   find first buf_dis-card
      where recid( buf_dis-card ) = INTEGER(ENTRY(1, v-rid))
      NO-LOCK
      no-error.
   IF AVAILABLE buf_dis-card THEN DO:
      ASSIGN
         v-dc-num = STRING(buf_dis-card.d-card)
      .
   END.
   Display
      v-dc-num
   with frame F-Main
   .
END.
ON CHOOSE OF b-doc-select IN FRAME F-Main
DO:
   define variable v-rid    as character    no-undo.
   define buffer buf_chk-doc     for ub.chk-doc .
   run str/chk-docs.w   ( input parparentproc
                        , input "b-sel,b-mark"
                        , input 'объект':U
                        , input ?
                        , input v-cntxt-obj-type
                        , input v-cntxt-obj-code
                        , input '':U
                        , input '':U
                        , input 0
                        , input ?
                        , input ?
                        , input 0
                        , output v-rid
                        ) NO-ERROR.
   IF v-rid = "":U
   THEN DO:
      RETURN.
   END.
   FIND FIRST buf_chk-doc
      where RECID(buf_chk-doc) = INTEGER(ENTRY(1, v-rid))
      no-lock
      NO-ERROR
      .
   IF AVAILABLE buf_chk-doc
   THEN DO:
      ASSIGN
         v-doc-num = buf_chk-doc.doc-code
      .
   END.
   Display
      v-doc-num
   with frame F-Main
   .
END.
ON CHOOSE OF b-user-sellect IN FRAME F-Main
DO:
   define buffer buf_user-account      for ub.user-account .
   define variable v-accepted      as logical      no-undo.
   run onewin_clear in this-procedure.
   for each buf_user-account
   :
      run onewin_add-item in this-procedure ( input buf_user-account.user-id
                                            , input substitute ( "&1 &2 &3 (&4)"
                                                               , buf_user-account.last-Name
                                                               , buf_user-account.first-Name
                                                               , buf_user-account.second-Name
                                                               , buf_user-account.user-id
                                                               )
                                            , input substitute ( "&1 &2 &3 (&4)"
                                                               , buf_user-account.last-Name
                                                               , buf_user-account.first-Name
                                                               , buf_user-account.second-Name
                                                               , buf_user-account.user-id
                                                               )
                                            , input no
                                          ).
   end.
   run gbl/onewin.w  ( input my-handle
                     , input  0
                     , input  "Список пользователей"
                     , input  "":U
                     , input  "&Тест"
                     , input  table temp_onewin_items
                     , output table temp_onewin_itemsSelected
                     , output v-user-id
                     , output v-accepted
                     ) .
    if v-accepted then do:
        find first buf_user-account where buf_user-account.user-id = v-user-id
                                    no-error.
            assign v-user-name = buf_user-account.last-Name
            .
        display v-user-name with frame F-Main.
    end.
END.
ON VALUE-CHANGED OF rb-b-codes IN FRAME F-Main
DO:
   ASSIGN
      rb-b-codes
   .
   CASE rb-b-codes :
      when 1
      then DO:
          Assign
            ed-b-codes
            v-b-codes   = ed-b-codes
            ed-b-codes  = 'все':U
            ed-b-codes:READ-ONLY = TRUE
          .
      END.
      when 2
      then DO:
         Assign
            ed-b-codes     = v-b-codes
            ed-b-codes:READ-ONLY = FALSE
         .
      END.
      OTHERWISE DO:
      END.
   END CASE.
   Display
      ed-b-codes
   with frame F-Main
   .
   APPLY "ENTRY" TO ed-b-codes.
END.
ON VALUE-CHANGED OF rb-cd IN FRAME F-Main
DO:
   define buffer buf_cash-desk      for ub.cash-desk .
   ASSIGN
      rb-cd
   .
   CASE rb-cd :
      when 1
      then DO:
          Assign
            ed-cd-names = 'все':U
            cd_recids = "":U
          .
          Display
            ed-cd-names
          with frame F-Main
          .
          FOR EACH  buf_cash-desk
              NO-LOCK
              :
                  ASSIGN
                     cd_recids = IF cd_recids = "":U THEN STRING(RECID(buf_cash-desk))
                                                     ELSE cd_recids + "," + STRING(RECID(buf_cash-desk))
                  .
          END.
       END.
      when 2
      then DO:
         define variable v-rec    as recid        no-undo.
         IF x-SelectObject = STRING(2)
         THEN DO:
            run ref/cashlist.w   ( INPUT my-handle
                                 , INPUT "b-sel,b-mark":U
                                 , INPUT 'объект':U
                                 , INPUT 0
                                 , INPUT 0
                                 , INPUT v-cntxt-obj-type
                                 , INPUT v-cntxt-obj-code
                                 , INPUT v-rec
                                 , output cd_recids
                                 ) .
         END.
         ELSE DO:
            run ref/cashlist.w   ( INPUT my-handle
                                 , INPUT "b-sel,b-mark":U
                                 , INPUT 'все':U
                                 , INPUT 0
                                 , INPUT 0
                                 , INPUT v-cntxt-obj-type
                                 , INPUT v-cntxt-obj-code
                                 , INPUT v-rec
                                 , output cd_recids
                                 ) .
         END.
         if cd_recids = ""
         then do:
            Assign
               ed-cd-names = 'все':U
               rb-cd = 1
            .
            Display
               ed-cd-names
               rb-cd
            with frame F-Main
            .
            end.
            else do:
            Assign
               ed-cd-names = "":U
            .
            DO ii = 1 TO num-entries( cd_recids ) :
               FIND FIRST buf_cash-desk
                    WHERE recid( buf_cash-desk ) = int(entry( ii, cd_recids ))
                    NO-LOCK
                    .
               ASSIGN
                  ed-cd-names = ed-cd-names
                              + SUBSTITUTE ( "Маг. &1 &2 &3"
                                           , buf_cash-desk.obj-code
                                           , buf_cash-desk.pos-type
                                           , buf_cash-desk.cash-num
                                           )
                              + chr(10)
               .
               END.
            Display
               ed-cd-names
            with frame F-Main
            .
            end.
      END.
      OTHERWISE DO:
      END.
   END CASE.
  END.
ON VALUE-CHANGED OF rb-events IN FRAME F-Main
DO:
   define buffer buf_cd-events      for ub.cd-events .
   define variable v-ok    as logical      no-undo.
   ASSIGN
      rb-events
   .
   CASE rb-events :
      when 1
      then DO:
          Assign
            ed-EventsName = 'все':U
            events_recids = "":U
          .
          Display
            ed-EventsName
          with frame F-Main
          .
          FOR EACH  buf_cd-events
              NO-LOCK
              :
                  ASSIGN
                     events_recids = IF events_recids = "":U THEN STRING(recid(buf_cd-events))
                                                             ELSE events_recids + "," + STRING(recid(buf_cd-events))
                  .
          END.
      END.
      when 2
      then DO:
         run ref/cd-event.w  ( INPUT my-handle
                             , INPUT "b-mark"
                             , input-output events_recids
                             , OUTPUT v-ok
                              ) .
         if events_recids = ""
         OR NOT v-ok
         then do:
            Assign
               ed-EventsName = 'все':U
               rb-events = 1
            .
            Display
               ed-EventsName
               rb-events
            with frame F-Main
            .
         end.
         else do:
            Assign
               ed-EventsName = "":U
            .
            DO ii = 1 TO num-entries( events_recids ) :
               FIND FIRST buf_cd-events
                    WHERE recid( buf_cd-events ) = int(entry( ii, events_recids ))
                    NO-LOCK
                    .
            ASSIGN
                  ed-EventsName = ed-EventsName + buf_cd-events.event-name + chr(10)
               .
            END.
            Display
               ed-EventsName
            with frame F-Main
   .
         end.
      END.
      OTHERWISE DO:
      END.
   END CASE.
END.
ON LEAVE OF v-bc-num IN FRAME F-Main
DO:
  ASSIGN
    v-bc-num
  .
END.
ON LEAVE OF v-disc-max IN FRAME F-Main
DO:
    ASSIGN
    v-disc-max
    v-disc-min
  .
  IF v-disc-max < v-disc-min
  THEN DO:
      message
         "Неправильно указаны границы диапазона"
         skip
      view-as alert-box error.
      RETURN NO-APPLY.
  END.
END.
ON VALUE-CHANGED OF v-disc-type IN FRAME F-Main
DO:
  ASSIGN
    v-disc-type
  .
END.
ON LEAVE OF v-h-end IN FRAME F-Main
DO:
      ASSIGN
     v-h-end
   .
   RUN mandatory-24 IN THIS-PROCEDURE
      (INPUT-OUTPUT v-h-end ) .
   ASSIGN
      v-time-end = v-h-end * 60 * 60 + v-m-end * 60
   .
   display v-h-end  with frame F-Main .
END.
ON LEAVE OF v-h-start IN FRAME F-Main
DO:
    ASSIGN
     v-h-start
   .
   RUN mandatory-24 IN THIS-PROCEDURE
      (INPUT-OUTPUT v-h-start ) .
   ASSIGN
      v-time-start = v-h-start * 60 * 60 + v-m-start * 60
   .
   display v-h-start  with frame F-Main .
END.
ON LEAVE OF v-m-end IN FRAME F-Main
DO:
       ASSIGN
     v-m-end
   .
   RUN mandatory-60 IN THIS-PROCEDURE
      (INPUT-OUTPUT v-m-end ) .
   ASSIGN
        v-time-end = v-h-end * 60 * 60 + v-m-end * 60
   .
   display v-m-end  with frame F-Main .
END.
ON LEAVE OF v-m-start IN FRAME F-Main
DO:
     ASSIGN
     v-m-start
   .
   RUN mandatory-60 IN THIS-PROCEDURE
      (INPUT-OUTPUT v-m-start ) .
   ASSIGN
        v-time-start = v-h-start * 60 * 60 + v-m-start * 60
   .
   display v-m-start  with frame F-Main .
END.
ON LEAVE OF v-qnty-max IN FRAME F-Main
DO:
   ASSIGN
    v-qnty-max
    v-qnty-min
  .
  IF v-qnty-max < v-qnty-min
  THEN DO:
      message
         "Неправильно указаны границы диапазона"
         skip
      view-as alert-box error.
      RETURN NO-APPLY .
  END.
END.
ON LEAVE OF v-summ-max IN FRAME F-Main
DO:
  ASSIGN
    v-summ-max
    v-summ-min
  .
  IF v-summ-max < v-summ-min
  THEN DO:
      message
         "Неправильно указаны границы диапазона"
         skip
      view-as alert-box error.
      RETURN NO-APPLY .
  END.
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
   assign
      parparentproc = my-handle
   .
   DISPLAY
      event-type
      v-disc-type
      v-h-start v-m-start v-h-end v-m-end
   with frame F-Main.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
PROCEDURE disable_UI :
  HIDE FRAME F-Main.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.
PROCEDURE local-initialize :
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ) .
END PROCEDURE.
PROCEDURE mandatory-24 :
DEFINE INPUT-OUTPUT PARAMETER p-time AS INTEGER NO-UNDO .
DO
ON error undo, RETURN:
   IF p-time > 23 THEN DO:
       ASSIGN
           p-time = 23
       .
       RETURN .
   END.
   IF p-time < 0 THEN DO:
       ASSIGN
           p-time = 0
       .
       RETURN .
   END.
END.
END PROCEDURE.
PROCEDURE mandatory-60 :
DEFINE INPUT-OUTPUT PARAMETER p-time AS INTEGER NO-UNDO .
DO
ON error undo, RETURN:
   IF p-time > 59 THEN DO:
       ASSIGN
           p-time = 59
       .
       RETURN .
   END.
   IF p-time < 0 THEN DO:
       ASSIGN
           p-time = 0
       .
       RETURN .
   END.
END.
END PROCEDURE.
PROCEDURE my-report :
FIND FIRST tmp#grp NO-ERROR.
 DO WITH frame F-Main:
   ASSIGN
      event-type
      rb-events
      rb-cd
      rb-b-codes
      ed-b-codes
      v-bc-num v-h-start v-m-start v-h-end v-m-end
      v-summ-min v-summ-max
      v-qnty-min v-qnty-max
      v-disc-min v-disc-max
      v-disc-type
   .
 END.
IF x-SelectObject = "currency":U
THEN DO:
   define variable v-new-rec     as character    no-undo .
   define variable v-new-name    as character    no-undo .
   define variable v-err         as logical      no-undo .
   define buffer buf_cash-desk      for ub.cash-desk .
   FIND FIRST obj-list .
   DO ii = 1 TO num-entries( cd_recids ) :
      FIND FIRST buf_cash-desk
            WHERE recid( buf_cash-desk ) = int(entry( ii, cd_recids ))
            NO-LOCK
            .
      IF buf_cash-desk.obj-code = obj-list.obj-code
      THEN DO:
         ASSIGN
            v-new-rec  = IF v-new-rec = "":U THEN STRING(RECID(buf_cash-desk))
                                             ELSE v-new-rec + "," + STRING(RECID(buf_cash-desk))
            v-new-name = v-new-name
                        + SUBSTITUTE ( "Маг. &1 &2 &3"
                                       , buf_cash-desk.obj-code
                                       , buf_cash-desk.pos-type
                                       , buf_cash-desk.cash-num
                                       )
                        + chr(10)
         .
      END.
      ELSE DO:
         ASSIGN
            v-err = TRUE
         .
      END.
   END.
   IF v-err
   THEN DO:
      ASSIGN
         cd_recids   = v-new-rec
         ed-cd-names = v-new-name
      .
      Display
         ed-cd-names
      with frame F-Main.
      message
         "Выбранные кассы не принадлежат текущему объекту"
         skip "Список был ограничен."
      view-as alert-box information.
      RETURN.
   END.
end.
 IF rb-b-codes = 1
 THEN DO:
   ASSIGN
      v-b-codes = "":U
   .
 END.
 else do:
   ASSIGN
      v-b-codes = ed-b-codes
   .
 end.
ASSIGN
      v-time-start = v-h-start * 60 * 60 + v-m-start * 60
.
ASSIGN
      v-time-end = v-h-end * 60 * 60 + v-m-end * 60
.
 run rep/r-evlog.p ( INPUT my-handle
                   , INPUT events_recids
                   , INPUT cd_recids
                   , INPUT v-user-id
                   , INPUT v-time-start
                   , INPUT v-time-end
                   , INPUT event-type
                   , INPUT v-supmode-id
                   , INPUT v-doc-num
                   , INPUT v-b-codes
                   , INPUT v-summ-min
                   , INPUT v-summ-max
                   , INPUT v-qnty-min
                   , INPUT v-qnty-max
                   , INPUT v-dc-num
                   , INPUT v-bc-num
                   , INPUT v-disc-type
                   , INPUT v-disc-min
                   , INPUT v-disc-max
                   ) .
END PROCEDURE.
PROCEDURE my-var :
END PROCEDURE.
PROCEDURE state-changed :
  DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE    NO-UNDO.
  DEFINE INPUT PARAMETER p-state      AS CHARACTER NO-UNDO.
  CASE p-state:
  END CASE.
  END PROCEDURE.
