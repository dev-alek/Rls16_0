block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Оборотная ведомость - дерево".
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
define work-table temp#sum-type no-undo
    field sum-type as char
    field xi as int.
define input parameter x-store-code like ub.clients.obj-code   no-undo.
define input parameter x-store-type like ub.clients.obj-type   no-undo.
define input parameter x-base-type  like ub.currency.curr-abbr no-undo.
define input parameter x-base-code  like ub.currency.curr-code no-undo.
define input parameter xclassify  as char no-undo.
define input parameter xsorttype  as char no-undo.
define input parameter xsumsonly  as log  no-undo.
define input parameter xshowzero  as log  no-undo.
define input parameter xshowzero-2  as log  no-undo.
define input parameter xtog-obj   as log no-undo.
define input parameter xshowcost  as log no-undo.
define input parameter xshowcostnds  as log no-undo.
define input parameter xshowcrsa     as log no-undo.
define input parameter xshowcrsands  as log no-undo.
define input parameter xshowsale     as log no-undo.
define input parameter xshowsalends  as log no-undo.
define input parameter xtog-lavel   as log  no-undo.
define input parameter xvar-lavel   as int  no-undo.
define input parameter xserv        as char no-undo.
define input parameter print-o      as char no-undo.
define input parameter xshowmediator as log no-undo.
define input parameter xshowsaleslt  as log no-undo.
define input parameter x-vat         as log no-undo.
define input  parameter xlongname as logical   no-undo .
define input  parameter x-tog-wt  as logical   no-undo .
define input  parameter x-tog-ms  as logical   no-undo .
define input parameter p-is-petrol    as logical   no-undo .
define variable v-name-type as character no-undo .
if x-vat then x-vat = false .
         else x-vat = true .
if x-vat then v-name-type = "учет.".
else  v-name-type = "учет-НДС".
define  variable  long-p as logical no-undo .
define  variable  null-str#   as decimal  no-undo.
define  variable  null-str2#   as decimal  no-undo.
define  variable  tprintrubl as log no-undo.
define  stream  outstream.
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
define variable    line2             as   char        no-undo.
define variable    firstline         as   logical     no-undo.
define variable mediator-host-code as integer no-undo .
define variable f-flag             as logical no-undo .
define variable tot_tqnty as decimal  no-undo.
define variable break_group as logical no-undo init true.
define variable break_group1 as logical no-undo init true.
define variable stat      as log        no-undo .
define variable inperror  as log        no-undo .
define variable i         as integer    no-undo .
define variable p         as integer    no-undo init 0 .
define variable kk        as integer    no-undo init 0 .
define variable old-page  as integer    no-undo .
define variable new-page  as integer    no-undo .
define variable rid-list  as character  no-undo .
define variable t-time as integer no-undo .
define variable m                       as integer no-undo.
define variable l                       as integer no-undo.
define variable i-str                   as integer no-undo.
define variable allcol                  as int no-undo.
define variable num#str                 as int no-undo.
define  stream  outstream.
define  stream  outstream2.
define variable nk as integer no-undo .
define variable lp as int no-undo.
define variable mp as int no-undo.
define variable mp-1 as int no-undo.
define variable gds-zap-unit-base     like ub.goods.unit-base    no-undo .
define variable gds-zap-prt-root      like ub.goods.prt-root     no-undo .
define variable gds-zap-gds-name      like ub.goods.gds-name     no-undo .
define variable gds-zap-prod-type     like ub.goods.prod-type    no-undo .
define variable gds-zap-prod-code     like ub.goods.prod-code    no-undo .
define variable gds-zap-artic         like ub.goods.artic        no-undo .
define variable gds-zap-b-code        like ub.bar-code.b-code    no-undo .
define variable gds-type              as char no-undo .
define variable gds-zap-type          like ub.goods.gds-type    no-undo .
define variable gds-zap-grp-name      like ub.goods.grp-name    no-undo .
define variable gds-zap-prod-name     like ub.clients.obj-name  no-undo .
define variable gds-zap-price-base    like ub.stk-tot.sum-base  no-undo .
define variable gds-zap-stoim-base    like ub.stk-tot.sum-base  no-undo .
define variable gds-zap-qnty          like ub.stk-tot.fact-qnty no-undo .
define variable gds-zap-nds           like ub.stk-tot.sum-base  no-undo .
define variable gds-zap-np            like ub.stk-tot.sum-base  no-undo .
define variable f-ostatok-start    as   char  no-undo.
define variable f-ostatok-end      as   char  no-undo.
define variable ostatok-start      as   decimal extent 10  format "->>>>>>>>>>>9.<<<" no-undo.
define variable ostatok-end        as   decimal extent 10  format "->>>>>>>>>>>9.<<<" no-undo.
define variable b1-ostatok-start   as   decimal extent 10  format "->>>>>>>>>>>9.<<<" no-undo.
define variable b1-ostatok-end     as   decimal extent 10  format "->>>>>>>>>>>9.<<<" no-undo.
define variable b2-ostatok-start   as   decimal extent 10  format "->>>>>>>>>>>9.<<<" no-undo.
define variable b2-ostatok-end     as   decimal extent 10  format "->>>>>>>>>>>9.<<<" no-undo.
define variable bi-ostatok-start   as   decimal extent 10  format "->>>>>>>>>>>9.<<<" no-undo.
define variable bi-ostatok-end     as   decimal extent 10  format "->>>>>>>>>>>9.<<<" no-undo.
define variable bo-ostatok-start   as   decimal extent 10  format "->>>>>>>>>>>9.<<<" no-undo.
define variable bo-ostatok-end     as   decimal extent 10  format "->>>>>>>>>>>9.<<<" no-undo.
define variable c-s-bar-code        AS   WIDGET-HANDLE  no-undo.
define variable c-gds-zap-artic     AS   WIDGET-HANDLE  no-undo.
define variable c-gds-zap-gds-name  AS   WIDGET-HANDLE  no-undo.
define variable c-gds-zap-unit-base AS   WIDGET-HANDLE  no-undo.
define variable c-gds-type          AS   WIDGET-HANDLE  no-undo.
define variable C-ostatok-start    AS   WIDGET-HANDLE  no-undo.
define variable C-ostatok-End      AS   WIDGET-HANDLE  no-undo.
define variable c-str-num          AS   WIDGET-HANDLE  no-undo.
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
define variable  c-oborot-ie as widget-handle no-undo.
define variable  f-oborot-ie as character no-undo.
define variable    oborot-ie as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b1-oborot-ie as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b2-oborot-ie as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bi-oborot-ie as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bo-oborot-ie as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable  c-oborot-ee as widget-handle no-undo.
define variable  f-oborot-ee as character no-undo.
define variable    oborot-ee as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b1-oborot-ee as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b2-oborot-ee as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bi-oborot-ee as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bo-oborot-ee as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable  c-oborot-ep as widget-handle no-undo.
define variable  f-oborot-ep as character no-undo.
define variable    oborot-ep as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b1-oborot-ep as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b2-oborot-ep as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bi-oborot-ep as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bo-oborot-ep as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable  c-oborot-es as widget-handle no-undo.
define variable  f-oborot-es as character no-undo.
define variable    oborot-es as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b1-oborot-es as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b2-oborot-es as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bi-oborot-es as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bo-oborot-es as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable  c-oborot-re as widget-handle no-undo.
define variable  f-oborot-re as character no-undo.
define variable    oborot-re as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b1-oborot-re as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b2-oborot-re as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bi-oborot-re as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bo-oborot-re as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable  c-oborot-rs as widget-handle no-undo.
define variable  f-oborot-rs as character no-undo.
define variable    oborot-rs as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b1-oborot-rs as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b2-oborot-rs as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bi-oborot-rs as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bo-oborot-rs as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable  c-oborot-we as widget-handle no-undo.
define variable  f-oborot-we as character no-undo.
define variable    oborot-we as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b1-oborot-we as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b2-oborot-we as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bi-oborot-we as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bo-oborot-we as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable  c-oborot-vt as widget-handle no-undo.
define variable  f-oborot-vt as character no-undo.
define variable    oborot-vt as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b1-oborot-vt as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b2-oborot-vt as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bi-oborot-vt as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bo-oborot-vt as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable  c-oborot-iv as widget-handle no-undo.
define variable  f-oborot-iv as character no-undo.
define variable    oborot-iv as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b1-oborot-iv as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b2-oborot-iv as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bi-oborot-iv as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bo-oborot-iv as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable  c-oborot-ev as widget-handle no-undo.
define variable  f-oborot-ev as character no-undo.
define variable    oborot-ev as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b1-oborot-ev as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b2-oborot-ev as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bi-oborot-ev as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bo-oborot-ev as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable  c-oborot-rv as widget-handle no-undo.
define variable  f-oborot-rv as character no-undo.
define variable    oborot-rv as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b1-oborot-rv as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b2-oborot-rv as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bi-oborot-rv as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bo-oborot-rv as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable  c-oborot-em as widget-handle no-undo.
define variable  f-oborot-em as character no-undo.
define variable    oborot-em as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b1-oborot-em as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b2-oborot-em as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bi-oborot-em as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bo-oborot-em as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable  c-oborot-wm as widget-handle no-undo.
define variable  f-oborot-wm as character no-undo.
define variable    oborot-wm as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b1-oborot-wm as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b2-oborot-wm as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bi-oborot-wm as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bo-oborot-wm as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable  c-oborot-im as widget-handle no-undo.
define variable  f-oborot-im as character no-undo.
define variable    oborot-im as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b1-oborot-im as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b2-oborot-im as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bi-oborot-im as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bo-oborot-im as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable  c-oborot-ot as widget-handle no-undo.
define variable  f-oborot-ot as character no-undo.
define variable    oborot-ot as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b1-oborot-ot as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b2-oborot-ot as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bi-oborot-ot as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bo-oborot-ot as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable  c-oborot-pc as widget-handle no-undo.
define variable  f-oborot-pc as character no-undo.
define variable    oborot-pc as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b1-oborot-pc as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b2-oborot-pc as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bi-oborot-pc as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bo-oborot-pc as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable  c-oborot-ap as widget-handle no-undo.
define variable  f-oborot-ap as character no-undo.
define variable    oborot-ap as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b1-oborot-ap as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b2-oborot-ap as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bi-oborot-ap as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bo-oborot-ap as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable  c-oborot-disc as widget-handle no-undo.
define variable  f-oborot-disc as character no-undo.
define variable    oborot-disc as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b1-oborot-disc as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b2-oborot-disc as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bi-oborot-disc as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bo-oborot-disc as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable  c-oborot-eff as widget-handle no-undo.
define variable  f-oborot-eff as character no-undo.
define variable    oborot-eff as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b1-oborot-eff as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b2-oborot-eff as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bi-oborot-eff as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bo-oborot-eff as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable  c-oborot-prc as widget-handle no-undo.
define variable  f-oborot-prc as character no-undo.
define variable    oborot-prc as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b1-oborot-prc as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b2-oborot-prc as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bi-oborot-prc as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bo-oborot-prc as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable  c-oborot-r-v as widget-handle no-undo.
define variable  f-oborot-r-v as character no-undo.
define variable    oborot-r-v as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b1-oborot-r-v as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b2-oborot-r-v as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bi-oborot-r-v as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bo-oborot-r-v as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable  c-oborot-sum-cost as widget-handle no-undo.
define variable  f-oborot-sum-cost as character no-undo.
define variable    oborot-sum-cost as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b1-oborot-sum-cost as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b2-oborot-sum-cost as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bi-oborot-sum-cost as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bo-oborot-sum-cost as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable  c-oborot-sum-crsa as widget-handle no-undo.
define variable  f-oborot-sum-crsa as character no-undo.
define variable    oborot-sum-crsa as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b1-oborot-sum-crsa as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b2-oborot-sum-crsa as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bi-oborot-sum-crsa as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bo-oborot-sum-crsa as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable  c-oborot-sum-sale as widget-handle no-undo.
define variable  f-oborot-sum-sale as character no-undo.
define variable    oborot-sum-sale as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b1-oborot-sum-sale as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable b2-oborot-sum-sale as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bi-oborot-sum-sale as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
define variable bo-oborot-sum-sale as decimal   extent 10 format "->>>>>>>>>>>9.<<<":U no-undo .
  define temp-table tt-obj-list no-undo
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    index pi is primary unique obj-type obj-code
    index name obj-name
    .
define temp-table tmp-gds-tree no-undo
  field id as integer
  field node-code   like ub.gds-grp.node-code
  field lvl         like ub.gds-grp.lvl-num
  field upper-cod   like ub.gds-grp.upper-code
  field f-name      like ub.goods.grp-name
  field ie       as decimal extent 10 format "->>>>>>>>>>>9.<<<"
  field ee       as decimal extent 10 format "->>>>>>>>>>>9.<<<"
  field ep       as decimal extent 10 format "->>>>>>>>>>>9.<<<"
  field es       as decimal extent 10 format "->>>>>>>>>>>9.<<<"
  field re       as decimal extent 10 format "->>>>>>>>>>>9.<<<"
  field rs  as decimal extent 10 format "->>>>>>>>>>>9.<<<"
  field we     as decimal extent 10 format "->>>>>>>>>>>9.<<<"
  field vt     as decimal extent 10 format "->>>>>>>>>>>9.<<<"
  field iv     as decimal extent 10 format "->>>>>>>>>>>9.<<<"
  field ev     as decimal extent 10 format "->>>>>>>>>>>9.<<<"
  field rv     as decimal extent 10 format "->>>>>>>>>>>9.<<<"
  field em     as decimal extent 10 format "->>>>>>>>>>>9.<<<"
  field wm     as decimal extent 10 format "->>>>>>>>>>>9.<<<"
  field im     as decimal extent 10 format "->>>>>>>>>>>9.<<<"
  field ot     as decimal extent 10 format "->>>>>>>>>>>9.<<<"
  field pc     as decimal extent 10 format "->>>>>>>>>>>9.<<<"
  field ap     as decimal extent 10 format "->>>>>>>>>>>9.<<<"
  field disc                             as decimal extent 10 format "->>>>>>>>>>>9.<<<"
  field eff                              as decimal extent 10 format "->>>>>>>>>>>9.<<<"
  field prc                              as decimal extent 10 format "->>>>>>>>>>>9.<<<"
  field ostatok-start                    as decimal extent 10 format "->>>>>>>>>>>9.<<<"
  field ostatok-end                      as decimal extent 10 format "->>>>>>>>>>>9.<<<"
  field oborot-sum-sale                  as decimal extent 10 format "->>>>>>>>>>>9.<<<"
  field oborot-sum-cost                  as decimal extent 10 format "->>>>>>>>>>>9.<<<"
 index pi id
 index i-name f-name
 index i-code  node-code
.
define variable nn      as     int  no-undo.
define variable report1 as     int no-undo.
define variable report2 as     int no-undo.
define variable errorlevel as  int no-undo.
define variable first-lavel as integer no-undo .
define variable l-col-type         as character no-undo .
define variable l-col-pos          as integer no-undo .
define variable l-col-len          as integer no-undo .
define variable l-col-format       as character no-undo .
define variable l-col-lable        as character no-undo .
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
define variable  temp-str-2 as char no-undo.
define variable str as char format "x(60)" no-undo.
define variable i#i as int no-undo.
define variable xlavel as int  no-undo.
define variable list-field as char no-undo.
define variable str10 as char no-undo.
  allcol = num-entries( sizes) - 1 .
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
IF ( i-str modulo v-account = 0 )  then DO:
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
              i-str @ RecordsDone
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
define new shared variable t-1 as character initial "|||"
     view-as editor
     size 1 by 4 no-undo.
define new shared frame top-frame
    t-1       at row 1 col 1 no-label
    header
        string(  "Дата печати : " + string( today,"99.99.9999") +  " , " + string( time, "hh:mm") ) at 5 format "x(35)"
        "Цены указаны в" ( if tprintrubl then "РУБ" else x-base-type )
        string(  "Страница " + string(  page-number(  outstream ), ">>>>>>9") ) at 110 format "x(16)" skip
     with 340 down stream-io
         no-underline use-text no-box no-label
         at col 1 row 1
         size 340 by 35  .
define new shared  frame zapas
   with width 340 down stream-io use-text no-box no-label.
t-time = time.
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
     assign
        number-list    = 1
        i              = 0
        xlavel         = xvar-lavel
        select-good    = x-selectgood
        paytype        = x-set_pay_type
        retclassify    = xclassify
        retsorttype    = xsorttype
        sums-only      = xsumsonly
        show-negativ   = xshowzero
        x-selectobject = "".
        firstline      = false.
        valtype        = if ( paytype = 1) then 0  else x-set_val_type.
    assign
      line  = fill( '-', minimum( l-col-pos,189))
      line2 = fill( '-', l-col-pos)
      .
  if  x-date-end  - x-date-start > 100
      then long-p = true    .
      else  long-p = false     .
  find first ub.gds-grp where  ub.gds-grp.upper-code = 0 no-lock no-error .
  if avail ub.gds-grp then  first-lavel = ub.gds-grp.node-code.
                   else first-lavel = 0.
  valtype         = if ( paytype = 1) then 0  else x-set_val_type.
  if ( valtype=0 and x-base-code=0)  or valtype=1
    then assign tprintrubl = yes .
    else assign tprintrubl = no .
  run make-tt-ed in this-procedure  .
  run find-mediator  in this-procedure
     (  input  v-cntxt-host-code-obj ,
       input  xshowmediator,
       output mediator-host-code,
       output f-flag) .
  if f-flag = false then return.
  g-ll = xlavel .
  run pp in this-procedure ( 1,first-lavel,"").
  run report-execute in this-procedure .
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
procedure report-execute :
  if ( valtype=0 and x-base-code=0)  or valtype=1
                                then   assign tprintrubl = yes .
                                else   assign tprintrubl = no .
  case print-o :
  when "a4-lansc":u then do:
output stream outstream to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size  value(43) .
  end.
  when "a4-port":u then do:
output stream outstream to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size  value(63) .
  end.
  when "a3-lansc":u then do:
output stream outstream to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size  value(63) .
  end.
  otherwise do:
output stream outstream to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size  value(43) .
  end.
  end case.
   define variable gj as integer no-undo init 0.
   if xtog-obj  then do:
            for each obj-list no-lock:
                x-store-type = obj-list.obj-type.
                x-store-code = obj-list.obj-code.
                run report-exec1 in this-procedure .
                gj = gj + 1 .
            end.
           if gj > 1 then   run display-bo in this-procedure .
          end.
  else  run report-exec1 in this-procedure .
  put stream outstream " Время составления отчета " string( ( time - t-time),"hh:mm:ss" ) .
  hide   stream outstream frame zapas .
  hide   stream outstream frame top-frame .
  output stream outstream close.
if mFrameView
then do:
   HIDE FRAME InfoFrame.
end.
  delete widget-pool "my-pool".
  define variable v-user-action as character no-undo .
  define variable v-printed as logical   no-undo .
  define variable DisabledOptions as integer   no-undo .
  case print-o :
      when "a4-lansc":u then do:
        DisabledOptions = 8 .
        end.
      when "a4-port":u then do:
        DisabledOptions = 0 .
        end.
      when "a3-lansc":u then do:
        DisabledOptions = 8 .
                          end.
      otherwise do:
        DisabledOptions = 1 .
          end.
   end case.
   run gbl/prnfilen.w
     ( input  ""
     ,input  DisabledOptions
     ,input  string( session :temp-directory) + "rpt" + string(  g#report-num )
     ,input 7
     ,output v-user-action
     ,output v-printed
     ) .
end procedure.
procedure report-exec1 :
   find first ub.clients where x-store-type = ub.clients.obj-type and
                            x-store-code = ub.clients.obj-code no-lock no-error.
           if available ub.clients then  objname = ub.clients.obj-name.
                                         else  objname="объект не определен".
  form with frame zapas .
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
form header
  line format "x(197)" at 1 skip
  "Продолжение - на следующей странице" at 30 skip
  with frame bottomframe width 340 page-bottom no-labels no-box .
view stream outstream frame bottomframe .
  run calcitog in this-procedure .
  run print-header in this-procedure .
  run run2 in this-procedure .
  run print-det in this-procedure .
  hide stream outstream frame bottomframe .
  run print-footer in this-procedure .
end procedure.
procedure run2 :
  for each tmp-gds-tree :
      delete tmp-gds-tree  .
  end.
  case select-good :
      when 1   then do: run run21 in this-procedure .  end.
      when 2   then do: run run22 in this-procedure .  end.
      when 3  then do: run run23 in this-procedure .  end.
       otherwise do:
         run run24 in this-procedure .
       end.
  end case.
end procedure.
procedure run21 :
define variable o-tog-obj as logical no-undo .
define variable ox-store-type as character no-undo .
define variable ox-store-code as integer no-undo .
assign
  o-tog-obj     = xtog-obj
  ox-store-type = x-store-type
  ox-store-code = x-store-code
  xtog-obj = true         .
define buffer b_gds-obj for ub.gds-obj .
define buffer b_goods for ub.goods .
define buffer b_gds-grp for ub.gds-grp .
define variable n as integer no-undo .
define variable n-1 as integer no-undo .
   for each obj-list  where
     (  o-tog-obj = false or
        (  obj-list.obj-type = x-store-type and
          obj-list.obj-code = x-store-code ) ) :
          x-store-type = obj-list.obj-type.
          x-store-code = obj-list.obj-code.
      for  each b_gds-obj  no-lock  where
                b_gds-obj.obj-type = obj-list.obj-type    and
                b_gds-obj.obj-code = obj-list.obj-code
                and (  b_gds-obj.last-doc = ? or b_gds-obj.last-doc >= x-date-start or b_gds-obj.fact-qnty <> 0 or b_gds-obj.avrg-qnty <> 0 or b_gds-obj.fact-sale <> 0 or b_gds-obj.fact-base <> 0 )
                :
        find first  b_goods  no-lock where b_gds-obj.gds-code    = b_goods.gds-code  no-error   .
        find first  b_gds-grp no-lock where b_gds-grp.node-code  = b_goods.grp-code  no-error .
          if available b_goods  and available b_gds-grp then do:
            n = n + 1 .                                                                      find first tmp-gds-tree where  tmp-gds-tree.node-code  = b_gds-grp.node-code no-error .               if not available tmp-gds-tree then do:                                                                create tmp-gds-tree.                                                                                  end.                                                                                                  assign                                                                                                tmp-gds-tree.id  = n                                                                                  tmp-gds-tree.f-name     = b_goods.grp-name                                                            tmp-gds-tree.node-code  = b_gds-grp.node-code                                                         tmp-gds-tree.lvl        = b_gds-grp.lvl-num                                                           tmp-gds-tree.upper-cod  = b_gds-grp.upper-code                                                        .                                                                                                                                                                                     assign                                                                                                gds-zap-artic      = b_goods.artic                                                                    gds-zap-prod-type  = b_goods.prod-type                                                                gds-zap-prod-code  = b_goods.prod-code                                                                gds-zap-type       = b_goods.gds-type                                                                 .                                                                                                     run foreach  in this-procedure .                                                                      do n-1 = 1 to 10 :                                                                             assign                                                                                                tmp-gds-tree.ie        [n-1]  = tmp-gds-tree.ie        [n-1]  + oborot-ie        [n-1]tmp-gds-tree.ee       [n-1]  = tmp-gds-tree.ee       [n-1]  + oborot-ee       [n-1]tmp-gds-tree.ep     [n-1]  = tmp-gds-tree.ep     [n-1]  + oborot-ep     [n-1]tmp-gds-tree.es    [n-1]  = tmp-gds-tree.es    [n-1]  + oborot-es    [n-1]tmp-gds-tree.re    [n-1]  = tmp-gds-tree.re    [n-1]  + oborot-re    [n-1]tmp-gds-tree.rs[n-1] = tmp-gds-tree.rs [n-1]  + oborot-rs[n-1]tmp-gds-tree.we[n-1]  = tmp-gds-tree.we[n-1]  + oborot-we[n-1]tmp-gds-tree.vt [n-1]  = tmp-gds-tree.vt [n-1]  + oborot-vt [n-1]tmp-gds-tree.iv  [n-1]  = tmp-gds-tree.iv  [n-1]  + oborot-iv  [n-1]tmp-gds-tree.ev  [n-1]  = tmp-gds-tree.ev  [n-1]  + oborot-ev  [n-1]tmp-gds-tree.rv  [n-1]  = tmp-gds-tree.rv  [n-1]  + oborot-rv  [n-1]tmp-gds-tree.em  [n-1]  = tmp-gds-tree.em  [n-1]  + oborot-em  [n-1]tmp-gds-tree.wm  [n-1]  = tmp-gds-tree.wm  [n-1]  + oborot-wm  [n-1]tmp-gds-tree.im  [n-1]  = tmp-gds-tree.im  [n-1]  + oborot-im  [n-1]tmp-gds-tree.ot  [n-1]  = tmp-gds-tree.ot  [n-1]  + oborot-ot  [n-1]tmp-gds-tree.pc  [n-1]  = tmp-gds-tree.pc  [n-1]  + oborot-pc  [n-1]tmp-gds-tree.ap  [n-1]  = tmp-gds-tree.ap  [n-1]  + oborot-ap  [n-1]tmp-gds-tree.disc                           [n-1]  = tmp-gds-tree.disc                           [n-1]  + oborot-disc                           [n-1]   tmp-gds-tree.ostatok-start                  [n-1]  = tmp-gds-tree.ostatok-start                  [n-1]  + ostatok-start                         [n-1]   tmp-gds-tree.ostatok-end                    [n-1]  = tmp-gds-tree.ostatok-end                    [n-1]  + ostatok-end                           [n-1]   tmp-gds-tree.oborot-sum-sale                [n-1]  = tmp-gds-tree.oborot-sum-sale                [n-1]  + oborot-sum-sale                        [1]    tmp-gds-tree.oborot-sum-cost                [n-1]  = tmp-gds-tree.oborot-sum-cost               [n-1]  + oborot-sum-cost                        [1]    .              end.
          end.
      end.
   end.
assign
   xtog-obj     = o-tog-obj
   x-store-type = ox-store-type
   x-store-code = ox-store-code
.
end procedure.
procedure run24 :
define buffer b_gds-obj for ub.gds-obj .
define buffer b_goods for ub.goods .
define buffer b_gds-grp for ub.gds-grp .
define variable n as integer no-undo .
define variable n-1 as integer no-undo .
define variable o-tog-obj as logical no-undo .
define variable ox-store-type as character no-undo .
define variable ox-store-code as integer no-undo .
assign
  o-tog-obj     = xtog-obj
  ox-store-type = x-store-type
  ox-store-code = x-store-code
  xtog-obj = true         .
   for each obj-list  :
      if  o-tog-obj = true  then   do:
         if not
        (  obj-list.obj-type = x-store-type and obj-list.obj-code = x-store-code ) then next.
      end.
      x-store-type = obj-list.obj-type.
      x-store-code = obj-list.obj-code.
      for  each b_gds-obj  no-lock  where
                b_gds-obj.obj-type = obj-list.obj-type    and
                b_gds-obj.obj-code = obj-list.obj-code
                and (  b_gds-obj.last-doc = ? or b_gds-obj.last-doc >= x-date-start or b_gds-obj.fact-qnty <> 0 or b_gds-obj.avrg-qnty <> 0 or b_gds-obj.fact-sale <> 0 or b_gds-obj.fact-base <> 0 )
                ,
                first gds-list where gds-list.gds-code = b_gds-obj.gds-code :
        find first  b_goods  no-lock where b_gds-obj.gds-code    = b_goods.gds-code  no-error   .
        find first  b_gds-grp no-lock where b_gds-grp.node-code  = b_goods.grp-code  no-error .
          if available b_goods  and available b_gds-grp then do:
            n = n + 1 .                                                                      find first tmp-gds-tree where  tmp-gds-tree.node-code  = b_gds-grp.node-code no-error .               if not available tmp-gds-tree then do:                                                                create tmp-gds-tree.                                                                                  end.                                                                                                  assign                                                                                                tmp-gds-tree.id  = n                                                                                  tmp-gds-tree.f-name     = b_goods.grp-name                                                            tmp-gds-tree.node-code  = b_gds-grp.node-code                                                         tmp-gds-tree.lvl        = b_gds-grp.lvl-num                                                           tmp-gds-tree.upper-cod  = b_gds-grp.upper-code                                                        .                                                                                                                                                                                     assign                                                                                                gds-zap-artic      = b_goods.artic                                                                    gds-zap-prod-type  = b_goods.prod-type                                                                gds-zap-prod-code  = b_goods.prod-code                                                                gds-zap-type       = b_goods.gds-type                                                                 .                                                                                                     run foreach  in this-procedure .                                                                      do n-1 = 1 to 10 :                                                                             assign                                                                                                tmp-gds-tree.ie        [n-1]  = tmp-gds-tree.ie        [n-1]  + oborot-ie        [n-1]tmp-gds-tree.ee       [n-1]  = tmp-gds-tree.ee       [n-1]  + oborot-ee       [n-1]tmp-gds-tree.ep     [n-1]  = tmp-gds-tree.ep     [n-1]  + oborot-ep     [n-1]tmp-gds-tree.es    [n-1]  = tmp-gds-tree.es    [n-1]  + oborot-es    [n-1]tmp-gds-tree.re    [n-1]  = tmp-gds-tree.re    [n-1]  + oborot-re    [n-1]tmp-gds-tree.rs[n-1] = tmp-gds-tree.rs [n-1]  + oborot-rs[n-1]tmp-gds-tree.we[n-1]  = tmp-gds-tree.we[n-1]  + oborot-we[n-1]tmp-gds-tree.vt [n-1]  = tmp-gds-tree.vt [n-1]  + oborot-vt [n-1]tmp-gds-tree.iv  [n-1]  = tmp-gds-tree.iv  [n-1]  + oborot-iv  [n-1]tmp-gds-tree.ev  [n-1]  = tmp-gds-tree.ev  [n-1]  + oborot-ev  [n-1]tmp-gds-tree.rv  [n-1]  = tmp-gds-tree.rv  [n-1]  + oborot-rv  [n-1]tmp-gds-tree.em  [n-1]  = tmp-gds-tree.em  [n-1]  + oborot-em  [n-1]tmp-gds-tree.wm  [n-1]  = tmp-gds-tree.wm  [n-1]  + oborot-wm  [n-1]tmp-gds-tree.im  [n-1]  = tmp-gds-tree.im  [n-1]  + oborot-im  [n-1]tmp-gds-tree.ot  [n-1]  = tmp-gds-tree.ot  [n-1]  + oborot-ot  [n-1]tmp-gds-tree.pc  [n-1]  = tmp-gds-tree.pc  [n-1]  + oborot-pc  [n-1]tmp-gds-tree.ap  [n-1]  = tmp-gds-tree.ap  [n-1]  + oborot-ap  [n-1]tmp-gds-tree.disc                           [n-1]  = tmp-gds-tree.disc                           [n-1]  + oborot-disc                           [n-1]   tmp-gds-tree.ostatok-start                  [n-1]  = tmp-gds-tree.ostatok-start                  [n-1]  + ostatok-start                         [n-1]   tmp-gds-tree.ostatok-end                    [n-1]  = tmp-gds-tree.ostatok-end                    [n-1]  + ostatok-end                           [n-1]   tmp-gds-tree.oborot-sum-sale                [n-1]  = tmp-gds-tree.oborot-sum-sale                [n-1]  + oborot-sum-sale                        [1]    tmp-gds-tree.oborot-sum-cost                [n-1]  = tmp-gds-tree.oborot-sum-cost               [n-1]  + oborot-sum-cost                        [1]    .              end.
          end.
      end.
   end.
assign
   xtog-obj     = o-tog-obj
   x-store-type = ox-store-type
   x-store-code = ox-store-code
.
end procedure.
procedure run22 :
define variable o-tog-obj as logical no-undo .
define variable ox-store-type as character no-undo .
define variable ox-store-code as integer no-undo .
assign
  o-tog-obj     = xtog-obj
  ox-store-type = x-store-type
  ox-store-code = x-store-code
  xtog-obj = true         .
define buffer b_gds-obj for ub.gds-obj .
define buffer b_goods for ub.goods .
define buffer b_gds-grp for ub.gds-grp .
define variable n as integer no-undo .
define variable n-1 as integer no-undo .
   for each obj-list  where
     (  o-tog-obj = false or
        (  obj-list.obj-type = x-store-type and
          obj-list.obj-code = x-store-code ))  :
          x-store-type = obj-list.obj-type.
          x-store-code = obj-list.obj-code.
      for  each b_gds-obj  no-lock  where
                b_gds-obj.obj-type = obj-list.obj-type    and
                b_gds-obj.obj-code = obj-list.obj-code
                and (  b_gds-obj.last-doc = ? or b_gds-obj.last-doc >= x-date-start or b_gds-obj.fact-qnty <> 0 or b_gds-obj.avrg-qnty <> 0 or b_gds-obj.fact-sale <> 0 or b_gds-obj.fact-base <> 0 )
                ,
         first  tmp#grp  where trim( b_gds-obj.grp-name) begins trim( tmp#grp.grp-name)
                :
        find first  b_goods  no-lock where b_gds-obj.gds-code    = b_goods.gds-code  no-error   .
        find first  b_gds-grp no-lock where b_gds-grp.node-code  = b_goods.grp-code  no-error .
          if available b_goods  and available b_gds-grp then do:
            n = n + 1 .                                                                      find first tmp-gds-tree where  tmp-gds-tree.node-code  = b_gds-grp.node-code no-error .               if not available tmp-gds-tree then do:                                                                create tmp-gds-tree.                                                                                  end.                                                                                                  assign                                                                                                tmp-gds-tree.id  = n                                                                                  tmp-gds-tree.f-name     = b_goods.grp-name                                                            tmp-gds-tree.node-code  = b_gds-grp.node-code                                                         tmp-gds-tree.lvl        = b_gds-grp.lvl-num                                                           tmp-gds-tree.upper-cod  = b_gds-grp.upper-code                                                        .                                                                                                                                                                                     assign                                                                                                gds-zap-artic      = b_goods.artic                                                                    gds-zap-prod-type  = b_goods.prod-type                                                                gds-zap-prod-code  = b_goods.prod-code                                                                gds-zap-type       = b_goods.gds-type                                                                 .                                                                                                     run foreach  in this-procedure .                                                                      do n-1 = 1 to 10 :                                                                             assign                                                                                                tmp-gds-tree.ie        [n-1]  = tmp-gds-tree.ie        [n-1]  + oborot-ie        [n-1]tmp-gds-tree.ee       [n-1]  = tmp-gds-tree.ee       [n-1]  + oborot-ee       [n-1]tmp-gds-tree.ep     [n-1]  = tmp-gds-tree.ep     [n-1]  + oborot-ep     [n-1]tmp-gds-tree.es    [n-1]  = tmp-gds-tree.es    [n-1]  + oborot-es    [n-1]tmp-gds-tree.re    [n-1]  = tmp-gds-tree.re    [n-1]  + oborot-re    [n-1]tmp-gds-tree.rs[n-1] = tmp-gds-tree.rs [n-1]  + oborot-rs[n-1]tmp-gds-tree.we[n-1]  = tmp-gds-tree.we[n-1]  + oborot-we[n-1]tmp-gds-tree.vt [n-1]  = tmp-gds-tree.vt [n-1]  + oborot-vt [n-1]tmp-gds-tree.iv  [n-1]  = tmp-gds-tree.iv  [n-1]  + oborot-iv  [n-1]tmp-gds-tree.ev  [n-1]  = tmp-gds-tree.ev  [n-1]  + oborot-ev  [n-1]tmp-gds-tree.rv  [n-1]  = tmp-gds-tree.rv  [n-1]  + oborot-rv  [n-1]tmp-gds-tree.em  [n-1]  = tmp-gds-tree.em  [n-1]  + oborot-em  [n-1]tmp-gds-tree.wm  [n-1]  = tmp-gds-tree.wm  [n-1]  + oborot-wm  [n-1]tmp-gds-tree.im  [n-1]  = tmp-gds-tree.im  [n-1]  + oborot-im  [n-1]tmp-gds-tree.ot  [n-1]  = tmp-gds-tree.ot  [n-1]  + oborot-ot  [n-1]tmp-gds-tree.pc  [n-1]  = tmp-gds-tree.pc  [n-1]  + oborot-pc  [n-1]tmp-gds-tree.ap  [n-1]  = tmp-gds-tree.ap  [n-1]  + oborot-ap  [n-1]tmp-gds-tree.disc                           [n-1]  = tmp-gds-tree.disc                           [n-1]  + oborot-disc                           [n-1]   tmp-gds-tree.ostatok-start                  [n-1]  = tmp-gds-tree.ostatok-start                  [n-1]  + ostatok-start                         [n-1]   tmp-gds-tree.ostatok-end                    [n-1]  = tmp-gds-tree.ostatok-end                    [n-1]  + ostatok-end                           [n-1]   tmp-gds-tree.oborot-sum-sale                [n-1]  = tmp-gds-tree.oborot-sum-sale                [n-1]  + oborot-sum-sale                        [1]    tmp-gds-tree.oborot-sum-cost                [n-1]  = tmp-gds-tree.oborot-sum-cost               [n-1]  + oborot-sum-cost                        [1]    .              end.
          end.
      end.
   end.
assign
   xtog-obj     = o-tog-obj
   x-store-type = ox-store-type
   x-store-code = ox-store-code
.
end procedure.
procedure run23 :
define variable o-tog-obj as logical no-undo .
define variable ox-store-type as character no-undo .
define variable ox-store-code as integer no-undo .
assign
  o-tog-obj     = xtog-obj
  ox-store-type = x-store-type
  ox-store-code = x-store-code
  xtog-obj = true         .
define buffer b_gds-obj for ub.gds-obj .
define buffer b_goods for ub.goods .
define buffer b_gds-grp for ub.gds-grp .
define variable n as integer no-undo .
define variable n-1 as integer no-undo .
   for each obj-list  where
     (  o-tog-obj = false or
        (  obj-list.obj-type = x-store-type and
          obj-list.obj-code = x-store-code ))  :
  x-store-type = obj-list.obj-type.
  x-store-code = obj-list.obj-code.
      for  each b_gds-obj  no-lock  where
                b_gds-obj.obj-type = obj-list.obj-type    and
                b_gds-obj.obj-code = obj-list.obj-code
                and (  b_gds-obj.last-doc = ? or b_gds-obj.last-doc >= x-date-start or b_gds-obj.fact-qnty <> 0 or b_gds-obj.avrg-qnty <> 0 or b_gds-obj.fact-sale <> 0 or b_gds-obj.fact-base <> 0 )
                ,
        first g#cli
              where b_gds-obj.prod-code   = g#cli.obj-code
              and   b_gds-obj.prod-type   = g#cli.obj-type
                :
        find first  b_goods  no-lock where b_gds-obj.gds-code    = b_goods.gds-code  no-error   .
        find first  b_gds-grp no-lock where b_gds-grp.node-code  = b_goods.grp-code  no-error .
          if available b_goods  and available b_gds-grp then do:
            n = n + 1 .                                                                      find first tmp-gds-tree where  tmp-gds-tree.node-code  = b_gds-grp.node-code no-error .               if not available tmp-gds-tree then do:                                                                create tmp-gds-tree.                                                                                  end.                                                                                                  assign                                                                                                tmp-gds-tree.id  = n                                                                                  tmp-gds-tree.f-name     = b_goods.grp-name                                                            tmp-gds-tree.node-code  = b_gds-grp.node-code                                                         tmp-gds-tree.lvl        = b_gds-grp.lvl-num                                                           tmp-gds-tree.upper-cod  = b_gds-grp.upper-code                                                        .                                                                                                                                                                                     assign                                                                                                gds-zap-artic      = b_goods.artic                                                                    gds-zap-prod-type  = b_goods.prod-type                                                                gds-zap-prod-code  = b_goods.prod-code                                                                gds-zap-type       = b_goods.gds-type                                                                 .                                                                                                     run foreach  in this-procedure .                                                                      do n-1 = 1 to 10 :                                                                             assign                                                                                                tmp-gds-tree.ie        [n-1]  = tmp-gds-tree.ie        [n-1]  + oborot-ie        [n-1]tmp-gds-tree.ee       [n-1]  = tmp-gds-tree.ee       [n-1]  + oborot-ee       [n-1]tmp-gds-tree.ep     [n-1]  = tmp-gds-tree.ep     [n-1]  + oborot-ep     [n-1]tmp-gds-tree.es    [n-1]  = tmp-gds-tree.es    [n-1]  + oborot-es    [n-1]tmp-gds-tree.re    [n-1]  = tmp-gds-tree.re    [n-1]  + oborot-re    [n-1]tmp-gds-tree.rs[n-1] = tmp-gds-tree.rs [n-1]  + oborot-rs[n-1]tmp-gds-tree.we[n-1]  = tmp-gds-tree.we[n-1]  + oborot-we[n-1]tmp-gds-tree.vt [n-1]  = tmp-gds-tree.vt [n-1]  + oborot-vt [n-1]tmp-gds-tree.iv  [n-1]  = tmp-gds-tree.iv  [n-1]  + oborot-iv  [n-1]tmp-gds-tree.ev  [n-1]  = tmp-gds-tree.ev  [n-1]  + oborot-ev  [n-1]tmp-gds-tree.rv  [n-1]  = tmp-gds-tree.rv  [n-1]  + oborot-rv  [n-1]tmp-gds-tree.em  [n-1]  = tmp-gds-tree.em  [n-1]  + oborot-em  [n-1]tmp-gds-tree.wm  [n-1]  = tmp-gds-tree.wm  [n-1]  + oborot-wm  [n-1]tmp-gds-tree.im  [n-1]  = tmp-gds-tree.im  [n-1]  + oborot-im  [n-1]tmp-gds-tree.ot  [n-1]  = tmp-gds-tree.ot  [n-1]  + oborot-ot  [n-1]tmp-gds-tree.pc  [n-1]  = tmp-gds-tree.pc  [n-1]  + oborot-pc  [n-1]tmp-gds-tree.ap  [n-1]  = tmp-gds-tree.ap  [n-1]  + oborot-ap  [n-1]tmp-gds-tree.disc                           [n-1]  = tmp-gds-tree.disc                           [n-1]  + oborot-disc                           [n-1]   tmp-gds-tree.ostatok-start                  [n-1]  = tmp-gds-tree.ostatok-start                  [n-1]  + ostatok-start                         [n-1]   tmp-gds-tree.ostatok-end                    [n-1]  = tmp-gds-tree.ostatok-end                    [n-1]  + ostatok-end                           [n-1]   tmp-gds-tree.oborot-sum-sale                [n-1]  = tmp-gds-tree.oborot-sum-sale                [n-1]  + oborot-sum-sale                        [1]    tmp-gds-tree.oborot-sum-cost                [n-1]  = tmp-gds-tree.oborot-sum-cost               [n-1]  + oborot-sum-cost                        [1]    .              end.
          end.
      end.
   end.
assign
   xtog-obj     = o-tog-obj
   x-store-type = ox-store-type
   x-store-code = ox-store-code
.
end procedure.
procedure print-det :
define variable n-1 as integer no-undo .
IF ( i-str modulo v-account = 0 )  then DO:
 Assign
    v-kol-spice = (50 - LENGTH('Суммирование дерева')) / 2
    RecordsString = fill(' ',v-kol-spice) + string('Суммирование дерева')
    .
          if  log-manager:logfile-name ne ?
          then DO:
              log-manager:write-message("DISP mFrameView=" + string(mFrameView), "frameRepError").
          end.
           if mFrameView
           then do:
            DISPLAY
              i-str @ RecordsDone
              RecordsString   @ RecordsString
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
    for each tmp-gds no-lock   :
        run clear-b1  in this-procedure .
        for each tmp-gds-tree no-lock
            where (  (  trim( tmp-gds-tree.f-name)  ) begins ( trim( tmp-gds.f-name) ) ) :
             i-str = i-str + 1 .
IF ( i-str modulo v-account = 0 )  then DO:
 Assign
    v-kol-spice = (50 - LENGTH('Суммирование дерева по группам ')) / 2
    RecordsString = fill(' ',v-kol-spice) + string('Суммирование дерева по группам ')
    .
 Assign
    v-kol-spice = (50 - LENGTH(tmp-gds.f-name)) / 2
    RecordsString2 = fill(' ',v-kol-spice) + string(tmp-gds.f-name)
    .
          if  log-manager:logfile-name ne ?
          then DO:
              log-manager:write-message("DISP mFrameView=" + string(mFrameView), "frameRepError").
          end.
           if mFrameView
           then do:
            DISPLAY
              i-str @ RecordsDone
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
                  do n-1 = 1 to 10 :
                  assign
                    b1-oborot-ie        [n-1]  = tmp-gds-tree.ie        [n-1]  + b1-oborot-ie        [n-1]
                    b1-oborot-ee       [n-1]  = tmp-gds-tree.ee       [n-1]  + b1-oborot-ee       [n-1]
                    b1-oborot-ep     [n-1]  = tmp-gds-tree.ep     [n-1]  + b1-oborot-ep     [n-1]
                    b1-oborot-es    [n-1]  = tmp-gds-tree.es    [n-1]  + b1-oborot-es    [n-1]
                    b1-oborot-re    [n-1]  = tmp-gds-tree.re    [n-1]  + b1-oborot-re    [n-1]
                    b1-oborot-rs[n-1] = tmp-gds-tree.rs [n-1]  + b1-oborot-rs[n-1]
                    b1-oborot-we[n-1]  = tmp-gds-tree.we[n-1]  + b1-oborot-we[n-1]
                    b1-oborot-vt [n-1]  = tmp-gds-tree.vt [n-1]  + b1-oborot-vt [n-1]
                    b1-oborot-iv  [n-1]  = tmp-gds-tree.iv  [n-1]  + b1-oborot-iv  [n-1]
                    b1-oborot-ev  [n-1]  = tmp-gds-tree.ev  [n-1]  + b1-oborot-ev  [n-1]
                    b1-oborot-rv  [n-1]  = tmp-gds-tree.rv  [n-1]  + b1-oborot-rv  [n-1]
                    b1-oborot-em  [n-1]  = tmp-gds-tree.em  [n-1]  + b1-oborot-em  [n-1]
                    b1-oborot-wm  [n-1]  = tmp-gds-tree.wm  [n-1]  + b1-oborot-wm  [n-1]
                    b1-oborot-im  [n-1]  = tmp-gds-tree.im  [n-1]  + b1-oborot-im  [n-1]
                    b1-oborot-ot  [n-1]  = tmp-gds-tree.ot  [n-1]  + b1-oborot-ot  [n-1]
                    b1-oborot-pc  [n-1]  = tmp-gds-tree.pc  [n-1]  + b1-oborot-pc [n-1]
                    b1-oborot-ap  [n-1]  = tmp-gds-tree.ap  [n-1]  + b1-oborot-ap [n-1]
                    b1-oborot-disc                           [n-1]  = tmp-gds-tree.disc                           [n-1]  + b1-oborot-disc                           [n-1]
                    b1-ostatok-start                         [n-1]  = tmp-gds-tree.ostatok-start                  [n-1]  + b1-ostatok-start                         [n-1]
                    b1-ostatok-end                           [n-1]  = tmp-gds-tree.ostatok-end                    [n-1]  + b1-ostatok-end                           [n-1]
                    b1-oborot-sum-sale                       [n-1]  = tmp-gds-tree.oborot-sum-sale                [n-1]  + b1-oborot-sum-sale                       [n-1]
                    b1-oborot-sum-cost                       [n-1]  = tmp-gds-tree.oborot-sum-cost                [n-1]  + b1-oborot-sum-cost                       [n-1]
                  .
                 end.
                 i = i + 1 .
        end.
        b1-oborot-eff[1 ]  = ( b1-oborot-sum-sale[8] - b1-oborot-sum-cost[2] ) .
        if  b1-oborot-sum-cost[2] <>  0 then
            b1-oborot-prc[1] = 100 * ( b1-oborot-sum-sale[8] - b1-oborot-sum-cost[2] ) / b1-oborot-sum-cost[2] .
            else b1-oborot-prc[1] = 0.
            if not
            (
              b1-oborot-ie                 [1]    = 0 and
              b1-oborot-ee                 [1]    = 0 and
              b1-oborot-ep              [1]    = 0 and
              b1-oborot-es            [1]    = 0 and
              b1-oborot-re             [1]    = 0 and
              b1-oborot-rs        [1]    = 0 and
              b1-oborot-we                 [1]    = 0 and
              b1-oborot-vt                       [1]    = 0 and
              b1-oborot-iv                 [1]    = 0 and
              b1-oborot-ev                 [1]    = 0 and
              b1-oborot-rv             [1]    = 0 and
              b1-oborot-em                  [1]    = 0 and
              b1-oborot-wm                  [1]    = 0 and
              b1-oborot-im                  [1]    = 0 and
              b1-oborot-ot                  [1]    = 0 and
              b1-oborot-pc           [1]    = 0 and
              b1-oborot-ap           [1]    = 0 and
              b1-oborot-disc                            [1]    = 0 and
              b1-ostatok-end                                    [1]    = 0 and
              b1-ostatok-start                                  [1]    = 0 and
              b1-oborot-ie                 [2]    = 0 and
              b1-oborot-ee                 [2]    = 0 and
              b1-oborot-ep              [2]    = 0 and
              b1-oborot-es            [2]    = 0 and
              b1-oborot-re             [2]    = 0 and
              b1-oborot-rs        [2]    = 0 and
              b1-oborot-we                 [2]    = 0 and
              b1-oborot-vt                       [2]    = 0 and
              b1-oborot-iv                 [2]    = 0 and
              b1-oborot-ev                 [2]    = 0 and
              b1-oborot-rv             [2]    = 0 and
              b1-oborot-em                  [2]    = 0 and
              b1-oborot-wm                  [2]    = 0 and
              b1-oborot-im                  [2]    = 0 and
              b1-oborot-ot                  [2]    = 0 and
              b1-oborot-pc           [2]    = 0 and
              b1-oborot-ap           [2]    = 0 and
              b1-oborot-disc                            [2]    = 0 and
              b1-ostatok-end                                    [2]    = 0 and
              b1-ostatok-start                                  [2]    = 0 and
              b1-oborot-ot                  [2]    = 0
              )  then do:
                  assign
                    s-bar-code       = substring( tmp-gds.name,1,9)
                    sf1:screen-value = substring( tmp-gds.name,10,1)
                    gds-zap-artic    = substring( tmp-gds.name,11,16)
                    sf2:screen-value = substring( tmp-gds.name,27,1)
                    gds-zap-gds-name = substring( tmp-gds.name,28,40)
                    no-error .
                    run display-b1  in this-procedure .
                    if tmp-gds.lvl = 1 then do:
                       run calc-s-itog   in this-procedure .
                    end.
                    run clear-b1  in this-procedure .
                    assign
                      sf1:screen-value =""
                      sf2:screen-value =""
                      no-error .
                end.
   end.
end procedure.
procedure foreach :
  assign
    p-price-med = 0
    null-str# = 1
    i-str = i-str + 1
  .
  if xshowmediator = true then do :
       run find-last-prise-med in this-procedure (
          input gds-zap-artic ,
          input gds-zap-prod-type ,
          input gds-zap-prod-code ,
          input mediator-host-code ,
          output p-price-med   )
          .
    end.
IF ( i-str modulo v-account = 0 )  then DO:
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
              i-str @ RecordsDone
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
  run clear-item  in this-procedure .
run ost-line in this-procedure
    (input   x-store-code  ,
    input   x-store-type  ,
    input   gds-zap-artic     ,
    input   gds-zap-prod-code ,
    input   gds-zap-prod-type ,
    input   x-tog-shift       ,
    input   fact-order-1               ,
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
 .
if xshowcrsa or xshowcrsands or use-column[23] or use-column[24] or xshowmediator then do :
run ost-line in this-procedure
    (input   x-store-code  ,
    input   x-store-type  ,
    input   gds-zap-artic     ,
    input   gds-zap-prod-code ,
    input   gds-zap-prod-type ,
    input   x-tog-shift       ,
    input   fact-order-1               ,
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
 .
   end.
if xshowsale or xshowsalends or xshowsaleslt then do:
run ost-line in this-procedure
    (input   x-store-code  ,
    input   x-store-type  ,
    input   gds-zap-artic     ,
    input   gds-zap-prod-code ,
    input   gds-zap-prod-type ,
    input   x-tog-shift       ,
    input   fact-order-1               ,
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
 .
   end.
run ost-line in this-procedure
    (input   x-store-code  ,
    input   x-store-type  ,
    input   gds-zap-artic     ,
    input   gds-zap-prod-code ,
    input   gds-zap-prod-type ,
    input   x-tog-shift       ,
    input   fact-order-2               ,
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
 .
if xshowcrsa or xshowcrsands or use-column[23] or use-column[24]  or xshowmediator then do :
run ost-line in this-procedure
    (input   x-store-code  ,
    input   x-store-type  ,
    input   gds-zap-artic     ,
    input   gds-zap-prod-code ,
    input   gds-zap-prod-type ,
    input   x-tog-shift       ,
    input   fact-order-2               ,
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
 .
   end.
if xshowsale or xshowsalends or xshowsaleslt then do :
run ost-line in this-procedure
    (input   x-store-code  ,
    input   x-store-type  ,
    input   gds-zap-artic     ,
    input   gds-zap-prod-code ,
    input   gds-zap-prod-type ,
    input   x-tog-shift       ,
    input   fact-order-2               ,
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
 .
   end.
   if gds-zap-type = 'т':U then
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
   if xshowcrsa or xshowcrsands or use-column[23] or use-column[24]  or xshowmediator   then do:
      if gds-zap-type = 'т':U  then
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
   end.
   if xshowsale or xshowsalends
      or use-column[21] or use-column[23] or use-column[24]   or xshowmediator  then do:
      if gds-zap-type = 'т':U  then
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
   end.
end procedure.
procedure print-header :
if not firstline then  run display-title  in this-procedure .
    firstline = true .
    if xtog-obj and   x-selectobject <> "currency":u   then  do:
          PUT stream  OutStream  UNFORMATTED  "ПО ОБЪЕКТУ : " + caps( objname)  at 30 format "x(170)" skip.
          end.
          form with FRAME ZAPAS .   DOWN stream   OutStream 1 with FRAME ZAPAS .
      run clear-b1  in this-procedure .
      run clear-bi  in this-procedure .
      break_group = true.
      break_group1 = true.
      display stream outstream     with frame top-frame .
      display stream outstream     with frame top-2 .
end procedure.
procedure print-footer :
    gds-zap-artic = "ИТОГО" .
    run display-bi  in this-procedure .
    run u-line      in this-procedure .
end procedure.
procedure calcitog :
    run ostatok  in this-procedure (
        input x-store-code  ,
        input x-store-type  , x-tog-shift ,
        input x-date-start - 1 ,
        input date( '')      , ?, ?,
        input 'crsa':U   ,
        input '##,##':U,
        input xtog-obj ,
        output  quantity1  ,
        output  coast_r1   ,
        output  coast_v1   ,
        output  vat_r1     ,
        output  vat_v1     ,
        output  fact-order-1 ).
    run ostatok  in this-procedure (
        input x-store-code  ,
        input x-store-type  , x-tog-shift ,
        input x-date-start  ,
        input x-date-end    ,  ?, ?,
        input 'crsa':U   ,
        input '##,##':U,
        input xtog-obj ,
        output  quantity1  ,
        output  coast_r1   ,
        output  coast_v1   ,
        output  vat_r1     ,
        output  vat_v1     ,
        output  fact-order-2 ).
          quantity1  = 0.
          coast_r1   = 0.
          coast_v1   = 0.
          vat_r1     = 0.
          vat_v1     = 0.
end procedure.
procedure display-str1  :
 end procedure.
procedure display-bi  :
 if line-counter( OutStream )  > page-size( OutStream ) then DO : display STREAM OutStream    with frame top-frame. end.
  p = p + 1.
  if use-column[28] then c-str-num:screen-value           = '' .
  if use-column[1] then  c-s-bar-code:screen-value        = ''.
  if use-column[2] then  c-gds-zap-artic:screen-value     = gds-zap-artic.
  if use-column[3] then  c-gds-zap-gds-name:screen-value  = ''.
  if use-column[4] then  c-gds-zap-unit-base:screen-value = ''.
  if use-column[5] then  c-gds-type:screen-value          = "кол-во"   .
  if use-column[21] then C-oborot-disc:screen-value  = string( bi-oborot-disc [1]) .
  if use-column[23] then C-oborot-eff:screen-value  = string( bi-oborot-eff [1]) .
  if use-column[24] then C-oborot-prc:screen-value  = string( bi-oborot-prc [1]) .
  if use-column[6]  then C-ostatok-start:screen-value                          = string( bi-ostatok-start  [1])                         .
  if use-column[7]  then C-oborot-ie:screen-value          = string( bi-oborot-ie [1]        )  .
  if use-column[8]  then C-oborot-iv:screen-value          = string( bi-oborot-iv [1]        )  .
  if use-column[9]  then C-oborot-im:screen-value           = string( bi-oborot-im  [1]        )  .
  if use-column[10] then C-oborot-ee:screen-value          = string( bi-oborot-ee [1]        )  .
  if use-column[11] then C-oborot-ev:screen-value          = string( bi-oborot-ev [1]        )  .
  if use-column[12] then C-oborot-em:screen-value           = string( bi-oborot-em  [1]        )  .
  if use-column[13] then C-oborot-we:screen-value          = string( bi-oborot-we         [1])  .
  if use-column[14] then C-oborot-es:screen-value     = string( bi-oborot-es    [1])  .
  if use-column[15] then C-oborot-rs:screen-value = string( bi-oborot-rs[1])  .
  if use-column[16] then C-oborot-re:screen-value      = string( bi-oborot-re     [1])  .
  if use-column[17] then C-oborot-ep:screen-value       = string( bi-oborot-ep      [1])  .
  if use-column[18] then C-oborot-rv:screen-value      = string( bi-oborot-rv     [1])  .
  if use-column[19] then C-oborot-vt:screen-value                = string( bi-oborot-vt               [1])  .
  if use-column[20] then C-oborot-ot:screen-value           = string( bi-oborot-ot          [1])  .
  if use-column[22] then C-ostatok-end:screen-value                            = string( bi-ostatok-end                           [1])  .
  if use-column[25] then C-oborot-ap:screen-value     = string( bi-oborot-ap    [1])  .
  if use-column[26] then C-oborot-pc:screen-value     = string( bi-oborot-pc    [1])  .
  if use-column[27] then C-oborot-r-v:screen-value                      = string( bi-oborot-ee         [1] +
                                                                                         bi-oborot-re     [1] +
                                                                                         bi-oborot-es    [1] +
                                                                                         bi-oborot-rs[1] ).
  DISPLAY stream  OutStream  with FRAME ZAPAS .  DOWN stream   OutStream 1 with FRAME ZAPAS.
if xshowcost    then do:  run price-vat in this-procedure ( 'bi').  end.
if xshowcostnds then do:
 if line-counter( OutStream )  > page-size( OutStream ) then DO : display STREAM OutStream    with frame top-frame. end.
  p = p + 1.
  if use-column[28] then c-str-num:screen-value           = '' .
  if use-column[1] then  c-s-bar-code:screen-value        = ''.
  if use-column[2] then  c-gds-zap-artic:screen-value     = ''.
  if use-column[3] then  c-gds-zap-gds-name:screen-value  = ''.
  if use-column[4] then  c-gds-zap-unit-base:screen-value = ''.
  if use-column[5] then  c-gds-type:screen-value          = "НДС учет."   .
  if use-column[6]  then C-ostatok-start:screen-value                          = string( bi-ostatok-start  [3])                         .
  if use-column[7]  then C-oborot-ie:screen-value          = string( bi-oborot-ie [3]        )  .
  if use-column[8]  then C-oborot-iv:screen-value          = string( bi-oborot-iv [3]        )  .
  if use-column[9]  then C-oborot-im:screen-value           = string( bi-oborot-im  [3]        )  .
  if use-column[10] then C-oborot-ee:screen-value          = string( bi-oborot-ee [3]        )  .
  if use-column[11] then C-oborot-ev:screen-value          = string( bi-oborot-ev [3]        )  .
  if use-column[12] then C-oborot-em:screen-value           = string( bi-oborot-em  [3]        )  .
  if use-column[13] then C-oborot-we:screen-value          = string( bi-oborot-we         [3])  .
  if use-column[14] then C-oborot-es:screen-value     = string( bi-oborot-es    [3])  .
  if use-column[15] then C-oborot-rs:screen-value = string( bi-oborot-rs[3])  .
  if use-column[16] then C-oborot-re:screen-value      = string( bi-oborot-re     [3])  .
  if use-column[17] then C-oborot-ep:screen-value       = string( bi-oborot-ep      [3])  .
  if use-column[18] then C-oborot-rv:screen-value      = string( bi-oborot-rv     [3])  .
  if use-column[19] then C-oborot-vt:screen-value                = string( bi-oborot-vt               [3])  .
  if use-column[20] then C-oborot-ot:screen-value           = string( bi-oborot-ot          [3])  .
  if use-column[22] then C-ostatok-end:screen-value                            = string( bi-ostatok-end                           [3])  .
  if use-column[25] then C-oborot-ap:screen-value     = string( bi-oborot-ap    [3])  .
  if use-column[26] then C-oborot-pc:screen-value     = string( bi-oborot-pc    [3])  .
  if use-column[27] then C-oborot-r-v:screen-value                      = string( bi-oborot-ee         [3] +
                                                                                         bi-oborot-re     [3] +
                                                                                         bi-oborot-es    [3] +
                                                                                         bi-oborot-rs[3] ).
  DISPLAY stream  OutStream  with FRAME ZAPAS .  DOWN stream   OutStream 1 with FRAME ZAPAS.
  end.
if xshowcrsa    then do:
 if line-counter( OutStream )  > page-size( OutStream ) then DO : display STREAM OutStream    with frame top-frame. end.
  p = p + 1.
  if use-column[28] then c-str-num:screen-value           = '' .
  if use-column[1] then  c-s-bar-code:screen-value        = ''.
  if use-column[2] then  c-gds-zap-artic:screen-value     = ''.
  if use-column[3] then  c-gds-zap-gds-name:screen-value  = ''.
  if use-column[4] then  c-gds-zap-unit-base:screen-value = ''.
  if use-column[5] then  c-gds-type:screen-value          = "прод."   .
  if use-column[6]  then C-ostatok-start:screen-value                          = string( bi-ostatok-start  [5])                         .
  if use-column[7]  then C-oborot-ie:screen-value          = string( bi-oborot-ie [5]        )  .
  if use-column[8]  then C-oborot-iv:screen-value          = string( bi-oborot-iv [5]        )  .
  if use-column[9]  then C-oborot-im:screen-value           = string( bi-oborot-im  [5]        )  .
  if use-column[10] then C-oborot-ee:screen-value          = string( bi-oborot-ee [5]        )  .
  if use-column[11] then C-oborot-ev:screen-value          = string( bi-oborot-ev [5]        )  .
  if use-column[12] then C-oborot-em:screen-value           = string( bi-oborot-em  [5]        )  .
  if use-column[13] then C-oborot-we:screen-value          = string( bi-oborot-we         [5])  .
  if use-column[14] then C-oborot-es:screen-value     = string( bi-oborot-es    [5])  .
  if use-column[15] then C-oborot-rs:screen-value = string( bi-oborot-rs[5])  .
  if use-column[16] then C-oborot-re:screen-value      = string( bi-oborot-re     [5])  .
  if use-column[17] then C-oborot-ep:screen-value       = string( bi-oborot-ep      [5])  .
  if use-column[18] then C-oborot-rv:screen-value      = string( bi-oborot-rv     [5])  .
  if use-column[19] then C-oborot-vt:screen-value                = string( bi-oborot-vt               [5])  .
  if use-column[20] then C-oborot-ot:screen-value           = string( bi-oborot-ot          [5])  .
  if use-column[22] then C-ostatok-end:screen-value                            = string( bi-ostatok-end                           [5])  .
  if use-column[25] then C-oborot-ap:screen-value     = string( bi-oborot-ap    [5])  .
  if use-column[26] then C-oborot-pc:screen-value     = string( bi-oborot-pc    [5])  .
  if use-column[27] then C-oborot-r-v:screen-value                      = string( bi-oborot-ee         [5] +
                                                                                         bi-oborot-re     [5] +
                                                                                         bi-oborot-es    [5] +
                                                                                         bi-oborot-rs[5] ).
  DISPLAY stream  OutStream  with FRAME ZAPAS .  DOWN stream   OutStream 1 with FRAME ZAPAS.
  end.
if xshowcrsands then do:
 if line-counter( OutStream )  > page-size( OutStream ) then DO : display STREAM OutStream    with frame top-frame. end.
  p = p + 1.
  if use-column[28] then c-str-num:screen-value           = '' .
  if use-column[1] then  c-s-bar-code:screen-value        = ''.
  if use-column[2] then  c-gds-zap-artic:screen-value     = ''.
  if use-column[3] then  c-gds-zap-gds-name:screen-value  = ''.
  if use-column[4] then  c-gds-zap-unit-base:screen-value = ''.
  if use-column[5] then  c-gds-type:screen-value          = "НДС прод."   .
  if use-column[6]  then C-ostatok-start:screen-value                          = string( bi-ostatok-start  [6])                         .
  if use-column[7]  then C-oborot-ie:screen-value          = string( bi-oborot-ie [6]        )  .
  if use-column[8]  then C-oborot-iv:screen-value          = string( bi-oborot-iv [6]        )  .
  if use-column[9]  then C-oborot-im:screen-value           = string( bi-oborot-im  [6]        )  .
  if use-column[10] then C-oborot-ee:screen-value          = string( bi-oborot-ee [6]        )  .
  if use-column[11] then C-oborot-ev:screen-value          = string( bi-oborot-ev [6]        )  .
  if use-column[12] then C-oborot-em:screen-value           = string( bi-oborot-em  [6]        )  .
  if use-column[13] then C-oborot-we:screen-value          = string( bi-oborot-we         [6])  .
  if use-column[14] then C-oborot-es:screen-value     = string( bi-oborot-es    [6])  .
  if use-column[15] then C-oborot-rs:screen-value = string( bi-oborot-rs[6])  .
  if use-column[16] then C-oborot-re:screen-value      = string( bi-oborot-re     [6])  .
  if use-column[17] then C-oborot-ep:screen-value       = string( bi-oborot-ep      [6])  .
  if use-column[18] then C-oborot-rv:screen-value      = string( bi-oborot-rv     [6])  .
  if use-column[19] then C-oborot-vt:screen-value                = string( bi-oborot-vt               [6])  .
  if use-column[20] then C-oborot-ot:screen-value           = string( bi-oborot-ot          [6])  .
  if use-column[22] then C-ostatok-end:screen-value                            = string( bi-ostatok-end                           [6])  .
  if use-column[25] then C-oborot-ap:screen-value     = string( bi-oborot-ap    [6])  .
  if use-column[26] then C-oborot-pc:screen-value     = string( bi-oborot-pc    [6])  .
  if use-column[27] then C-oborot-r-v:screen-value                      = string( bi-oborot-ee         [6] +
                                                                                         bi-oborot-re     [6] +
                                                                                         bi-oborot-es    [6] +
                                                                                         bi-oborot-rs[6] ).
  DISPLAY stream  OutStream  with FRAME ZAPAS .  DOWN stream   OutStream 1 with FRAME ZAPAS.
  end.
if xshowsale    then do:
 if line-counter( OutStream )  > page-size( OutStream ) then DO : display STREAM OutStream    with frame top-frame. end.
  p = p + 1.
  if use-column[28] then c-str-num:screen-value           = '' .
  if use-column[1] then  c-s-bar-code:screen-value        = ''.
  if use-column[2] then  c-gds-zap-artic:screen-value     = ''.
  if use-column[3] then  c-gds-zap-gds-name:screen-value  = ''.
  if use-column[4] then  c-gds-zap-unit-base:screen-value = ''.
  if use-column[5] then  c-gds-type:screen-value          = "док."   .
  if use-column[6]  then C-ostatok-start:screen-value                          = string( bi-ostatok-start  [8])                         .
  if use-column[7]  then C-oborot-ie:screen-value          = string( bi-oborot-ie [8]        )  .
  if use-column[8]  then C-oborot-iv:screen-value          = string( bi-oborot-iv [8]        )  .
  if use-column[9]  then C-oborot-im:screen-value           = string( bi-oborot-im  [8]        )  .
  if use-column[10] then C-oborot-ee:screen-value          = string( bi-oborot-ee [8]        )  .
  if use-column[11] then C-oborot-ev:screen-value          = string( bi-oborot-ev [8]        )  .
  if use-column[12] then C-oborot-em:screen-value           = string( bi-oborot-em  [8]        )  .
  if use-column[13] then C-oborot-we:screen-value          = string( bi-oborot-we         [8])  .
  if use-column[14] then C-oborot-es:screen-value     = string( bi-oborot-es    [8])  .
  if use-column[15] then C-oborot-rs:screen-value = string( bi-oborot-rs[8])  .
  if use-column[16] then C-oborot-re:screen-value      = string( bi-oborot-re     [8])  .
  if use-column[17] then C-oborot-ep:screen-value       = string( bi-oborot-ep      [8])  .
  if use-column[18] then C-oborot-rv:screen-value      = string( bi-oborot-rv     [8])  .
  if use-column[19] then C-oborot-vt:screen-value                = string( bi-oborot-vt               [8])  .
  if use-column[20] then C-oborot-ot:screen-value           = string( bi-oborot-ot          [8])  .
  if use-column[22] then C-ostatok-end:screen-value                            = string( bi-ostatok-end                           [8])  .
  if use-column[25] then C-oborot-ap:screen-value     = string( bi-oborot-ap    [8])  .
  if use-column[26] then C-oborot-pc:screen-value     = string( bi-oborot-pc    [8])  .
  if use-column[27] then C-oborot-r-v:screen-value                      = string( bi-oborot-ee         [8] +
                                                                                         bi-oborot-re     [8] +
                                                                                         bi-oborot-es    [8] +
                                                                                         bi-oborot-rs[8] ).
  DISPLAY stream  OutStream  with FRAME ZAPAS .  DOWN stream   OutStream 1 with FRAME ZAPAS.
  end.
if xshowsalends then do:
 if line-counter( OutStream )  > page-size( OutStream ) then DO : display STREAM OutStream    with frame top-frame. end.
  p = p + 1.
  if use-column[28] then c-str-num:screen-value           = '' .
  if use-column[1] then  c-s-bar-code:screen-value        = ''.
  if use-column[2] then  c-gds-zap-artic:screen-value     = ''.
  if use-column[3] then  c-gds-zap-gds-name:screen-value  = ''.
  if use-column[4] then  c-gds-zap-unit-base:screen-value = ''.
  if use-column[5] then  c-gds-type:screen-value          = "НДС док."   .
  if use-column[6]  then C-ostatok-start:screen-value                          = string( bi-ostatok-start  [9])                         .
  if use-column[7]  then C-oborot-ie:screen-value          = string( bi-oborot-ie [9]        )  .
  if use-column[8]  then C-oborot-iv:screen-value          = string( bi-oborot-iv [9]        )  .
  if use-column[9]  then C-oborot-im:screen-value           = string( bi-oborot-im  [9]        )  .
  if use-column[10] then C-oborot-ee:screen-value          = string( bi-oborot-ee [9]        )  .
  if use-column[11] then C-oborot-ev:screen-value          = string( bi-oborot-ev [9]        )  .
  if use-column[12] then C-oborot-em:screen-value           = string( bi-oborot-em  [9]        )  .
  if use-column[13] then C-oborot-we:screen-value          = string( bi-oborot-we         [9])  .
  if use-column[14] then C-oborot-es:screen-value     = string( bi-oborot-es    [9])  .
  if use-column[15] then C-oborot-rs:screen-value = string( bi-oborot-rs[9])  .
  if use-column[16] then C-oborot-re:screen-value      = string( bi-oborot-re     [9])  .
  if use-column[17] then C-oborot-ep:screen-value       = string( bi-oborot-ep      [9])  .
  if use-column[18] then C-oborot-rv:screen-value      = string( bi-oborot-rv     [9])  .
  if use-column[19] then C-oborot-vt:screen-value                = string( bi-oborot-vt               [9])  .
  if use-column[20] then C-oborot-ot:screen-value           = string( bi-oborot-ot          [9])  .
  if use-column[22] then C-ostatok-end:screen-value                            = string( bi-ostatok-end                           [9])  .
  if use-column[25] then C-oborot-ap:screen-value     = string( bi-oborot-ap    [9])  .
  if use-column[26] then C-oborot-pc:screen-value     = string( bi-oborot-pc    [9])  .
  if use-column[27] then C-oborot-r-v:screen-value                      = string( bi-oborot-ee         [9] +
                                                                                         bi-oborot-re     [9] +
                                                                                         bi-oborot-es    [9] +
                                                                                         bi-oborot-rs[9] ).
  DISPLAY stream  OutStream  with FRAME ZAPAS .  DOWN stream   OutStream 1 with FRAME ZAPAS.
  end.
if xshowsaleslt then do:
 if line-counter( OutStream )  > page-size( OutStream ) then DO : display STREAM OutStream    with frame top-frame. end.
  p = p + 1.
  if use-column[28] then c-str-num:screen-value           = '' .
  if use-column[1] then  c-s-bar-code:screen-value        = ''.
  if use-column[2] then  c-gds-zap-artic:screen-value     = ''.
  if use-column[3] then  c-gds-zap-gds-name:screen-value  = ''.
  if use-column[4] then  c-gds-zap-unit-base:screen-value = ''.
  if use-column[5] then  c-gds-type:screen-value          = "НсП док."   .
  if use-column[6]  then C-ostatok-start:screen-value                          = string( bi-ostatok-start  [10])                         .
  if use-column[7]  then C-oborot-ie:screen-value          = string( bi-oborot-ie [10]        )  .
  if use-column[8]  then C-oborot-iv:screen-value          = string( bi-oborot-iv [10]        )  .
  if use-column[9]  then C-oborot-im:screen-value           = string( bi-oborot-im  [10]        )  .
  if use-column[10] then C-oborot-ee:screen-value          = string( bi-oborot-ee [10]        )  .
  if use-column[11] then C-oborot-ev:screen-value          = string( bi-oborot-ev [10]        )  .
  if use-column[12] then C-oborot-em:screen-value           = string( bi-oborot-em  [10]        )  .
  if use-column[13] then C-oborot-we:screen-value          = string( bi-oborot-we         [10])  .
  if use-column[14] then C-oborot-es:screen-value     = string( bi-oborot-es    [10])  .
  if use-column[15] then C-oborot-rs:screen-value = string( bi-oborot-rs[10])  .
  if use-column[16] then C-oborot-re:screen-value      = string( bi-oborot-re     [10])  .
  if use-column[17] then C-oborot-ep:screen-value       = string( bi-oborot-ep      [10])  .
  if use-column[18] then C-oborot-rv:screen-value      = string( bi-oborot-rv     [10])  .
  if use-column[19] then C-oborot-vt:screen-value                = string( bi-oborot-vt               [10])  .
  if use-column[20] then C-oborot-ot:screen-value           = string( bi-oborot-ot          [10])  .
  if use-column[22] then C-ostatok-end:screen-value                            = string( bi-ostatok-end                           [10])  .
  if use-column[25] then C-oborot-ap:screen-value     = string( bi-oborot-ap    [10])  .
  if use-column[26] then C-oborot-pc:screen-value     = string( bi-oborot-pc    [10])  .
  if use-column[27] then C-oborot-r-v:screen-value                      = string( bi-oborot-ee         [10] +
                                                                                         bi-oborot-re     [10] +
                                                                                         bi-oborot-es    [10] +
                                                                                         bi-oborot-rs[10] ).
  DISPLAY stream  OutStream  with FRAME ZAPAS .  DOWN stream   OutStream 1 with FRAME ZAPAS.
  end.
if xshowmediator then do:
 if line-counter( OutStream )  > page-size( OutStream ) then DO : display STREAM OutStream    with frame top-frame. end.
  p = p + 1.
  if use-column[28] then c-str-num:screen-value           = '' .
  if use-column[1] then  c-s-bar-code:screen-value        = ''.
  if use-column[2] then  c-gds-zap-artic:screen-value     = ''.
  if use-column[3] then  c-gds-zap-gds-name:screen-value  = ''.
  if use-column[4] then  c-gds-zap-unit-base:screen-value = ''.
  if use-column[5] then  c-gds-type:screen-value          = "поср."   .
  if use-column[6]  then C-ostatok-start:screen-value                          = string( bi-ostatok-start  [4])                         .
  if use-column[7]  then C-oborot-ie:screen-value          = string( bi-oborot-ie [4]        )  .
  if use-column[8]  then C-oborot-iv:screen-value          = string( bi-oborot-iv [4]        )  .
  if use-column[9]  then C-oborot-im:screen-value           = string( bi-oborot-im  [4]        )  .
  if use-column[10] then C-oborot-ee:screen-value          = string( bi-oborot-ee [4]        )  .
  if use-column[11] then C-oborot-ev:screen-value          = string( bi-oborot-ev [4]        )  .
  if use-column[12] then C-oborot-em:screen-value           = string( bi-oborot-em  [4]        )  .
  if use-column[13] then C-oborot-we:screen-value          = string( bi-oborot-we         [4])  .
  if use-column[14] then C-oborot-es:screen-value     = string( bi-oborot-es    [4])  .
  if use-column[15] then C-oborot-rs:screen-value = string( bi-oborot-rs[4])  .
  if use-column[16] then C-oborot-re:screen-value      = string( bi-oborot-re     [4])  .
  if use-column[17] then C-oborot-ep:screen-value       = string( bi-oborot-ep      [4])  .
  if use-column[18] then C-oborot-rv:screen-value      = string( bi-oborot-rv     [4])  .
  if use-column[19] then C-oborot-vt:screen-value                = string( bi-oborot-vt               [4])  .
  if use-column[20] then C-oborot-ot:screen-value           = string( bi-oborot-ot          [4])  .
  if use-column[22] then C-ostatok-end:screen-value                            = string( bi-ostatok-end                           [4])  .
  if use-column[25] then C-oborot-ap:screen-value     = string( bi-oborot-ap    [4])  .
  if use-column[26] then C-oborot-pc:screen-value     = string( bi-oborot-pc    [4])  .
  if use-column[27] then C-oborot-r-v:screen-value                      = string( bi-oborot-ee         [4] +
                                                                                         bi-oborot-re     [4] +
                                                                                         bi-oborot-es    [4] +
                                                                                         bi-oborot-rs[4] ).
  DISPLAY stream  OutStream  with FRAME ZAPAS .  DOWN stream   OutStream 1 with FRAME ZAPAS.
  end.
run clear-bi  in this-procedure .
end procedure.
procedure display-bo  :
 if line-counter( OutStream )  > page-size( OutStream ) then DO : display STREAM OutStream    with frame top-frame. end.
  p = p + 1.
  if use-column[28] then c-str-num:screen-value           = '' .
  if use-column[1] then  c-s-bar-code:screen-value        = ''.
  if use-column[2] then  c-gds-zap-artic:screen-value     = 'ИТОГО ПО'.
  if use-column[3] then  c-gds-zap-gds-name:screen-value  = 'ОБЪЕКТАМ'.
  if use-column[4] then  c-gds-zap-unit-base:screen-value = ''.
  if use-column[5] then  c-gds-type:screen-value          = "кол-во"   .
  if use-column[21] then C-oborot-disc:screen-value  = string( bo-oborot-disc [1]) .
  if use-column[23] then C-oborot-eff:screen-value  = string( bo-oborot-eff [1]) .
  if use-column[24] then C-oborot-prc:screen-value  = string( bo-oborot-prc [1]) .
  if use-column[6]  then C-ostatok-start:screen-value                          = string( bo-ostatok-start  [1])                         .
  if use-column[7]  then C-oborot-ie:screen-value          = string( bo-oborot-ie [1]        )  .
  if use-column[8]  then C-oborot-iv:screen-value          = string( bo-oborot-iv [1]        )  .
  if use-column[9]  then C-oborot-im:screen-value           = string( bo-oborot-im  [1]        )  .
  if use-column[10] then C-oborot-ee:screen-value          = string( bo-oborot-ee [1]        )  .
  if use-column[11] then C-oborot-ev:screen-value          = string( bo-oborot-ev [1]        )  .
  if use-column[12] then C-oborot-em:screen-value           = string( bo-oborot-em  [1]        )  .
  if use-column[13] then C-oborot-we:screen-value          = string( bo-oborot-we         [1])  .
  if use-column[14] then C-oborot-es:screen-value     = string( bo-oborot-es    [1])  .
  if use-column[15] then C-oborot-rs:screen-value = string( bo-oborot-rs[1])  .
  if use-column[16] then C-oborot-re:screen-value      = string( bo-oborot-re     [1])  .
  if use-column[17] then C-oborot-ep:screen-value       = string( bo-oborot-ep      [1])  .
  if use-column[18] then C-oborot-rv:screen-value      = string( bo-oborot-rv     [1])  .
  if use-column[19] then C-oborot-vt:screen-value                = string( bo-oborot-vt               [1])  .
  if use-column[20] then C-oborot-ot:screen-value           = string( bo-oborot-ot          [1])  .
  if use-column[22] then C-ostatok-end:screen-value                            = string( bo-ostatok-end                           [1])  .
  if use-column[25] then C-oborot-ap:screen-value     = string( bo-oborot-ap    [1])  .
  if use-column[26] then C-oborot-pc:screen-value     = string( bo-oborot-pc    [1])  .
  if use-column[27] then C-oborot-r-v:screen-value                      = string( bo-oborot-ee         [1] +
                                                                                         bo-oborot-re     [1] +
                                                                                         bo-oborot-es    [1] +
                                                                                         bo-oborot-rs[1] ).
  DISPLAY stream  OutStream  with FRAME ZAPAS .  DOWN stream   OutStream 1 with FRAME ZAPAS.
if xshowcost    then do:  run price-vat in this-procedure ( 'bo').  end.
if xshowcostnds then do:
 if line-counter( OutStream )  > page-size( OutStream ) then DO : display STREAM OutStream    with frame top-frame. end.
  p = p + 1.
  if use-column[28] then c-str-num:screen-value           = '' .
  if use-column[1] then  c-s-bar-code:screen-value        = ''.
  if use-column[2] then  c-gds-zap-artic:screen-value     = ''.
  if use-column[3] then  c-gds-zap-gds-name:screen-value  = ''.
  if use-column[4] then  c-gds-zap-unit-base:screen-value = ''.
  if use-column[5] then  c-gds-type:screen-value          = "НДС учет."   .
  if use-column[6]  then C-ostatok-start:screen-value                          = string( bo-ostatok-start  [3])                         .
  if use-column[7]  then C-oborot-ie:screen-value          = string( bo-oborot-ie [3]        )  .
  if use-column[8]  then C-oborot-iv:screen-value          = string( bo-oborot-iv [3]        )  .
  if use-column[9]  then C-oborot-im:screen-value           = string( bo-oborot-im  [3]        )  .
  if use-column[10] then C-oborot-ee:screen-value          = string( bo-oborot-ee [3]        )  .
  if use-column[11] then C-oborot-ev:screen-value          = string( bo-oborot-ev [3]        )  .
  if use-column[12] then C-oborot-em:screen-value           = string( bo-oborot-em  [3]        )  .
  if use-column[13] then C-oborot-we:screen-value          = string( bo-oborot-we         [3])  .
  if use-column[14] then C-oborot-es:screen-value     = string( bo-oborot-es    [3])  .
  if use-column[15] then C-oborot-rs:screen-value = string( bo-oborot-rs[3])  .
  if use-column[16] then C-oborot-re:screen-value      = string( bo-oborot-re     [3])  .
  if use-column[17] then C-oborot-ep:screen-value       = string( bo-oborot-ep      [3])  .
  if use-column[18] then C-oborot-rv:screen-value      = string( bo-oborot-rv     [3])  .
  if use-column[19] then C-oborot-vt:screen-value                = string( bo-oborot-vt               [3])  .
  if use-column[20] then C-oborot-ot:screen-value           = string( bo-oborot-ot          [3])  .
  if use-column[22] then C-ostatok-end:screen-value                            = string( bo-ostatok-end                           [3])  .
  if use-column[25] then C-oborot-ap:screen-value     = string( bo-oborot-ap    [3])  .
  if use-column[26] then C-oborot-pc:screen-value     = string( bo-oborot-pc    [3])  .
  if use-column[27] then C-oborot-r-v:screen-value                      = string( bo-oborot-ee         [3] +
                                                                                         bo-oborot-re     [3] +
                                                                                         bo-oborot-es    [3] +
                                                                                         bo-oborot-rs[3] ).
  DISPLAY stream  OutStream  with FRAME ZAPAS .  DOWN stream   OutStream 1 with FRAME ZAPAS.
  end.
if xshowcrsa    then do:
 if line-counter( OutStream )  > page-size( OutStream ) then DO : display STREAM OutStream    with frame top-frame. end.
  p = p + 1.
  if use-column[28] then c-str-num:screen-value           = '' .
  if use-column[1] then  c-s-bar-code:screen-value        = ''.
  if use-column[2] then  c-gds-zap-artic:screen-value     = ''.
  if use-column[3] then  c-gds-zap-gds-name:screen-value  = ''.
  if use-column[4] then  c-gds-zap-unit-base:screen-value = ''.
  if use-column[5] then  c-gds-type:screen-value          = "прод."   .
  if use-column[6]  then C-ostatok-start:screen-value                          = string( bo-ostatok-start  [5])                         .
  if use-column[7]  then C-oborot-ie:screen-value          = string( bo-oborot-ie [5]        )  .
  if use-column[8]  then C-oborot-iv:screen-value          = string( bo-oborot-iv [5]        )  .
  if use-column[9]  then C-oborot-im:screen-value           = string( bo-oborot-im  [5]        )  .
  if use-column[10] then C-oborot-ee:screen-value          = string( bo-oborot-ee [5]        )  .
  if use-column[11] then C-oborot-ev:screen-value          = string( bo-oborot-ev [5]        )  .
  if use-column[12] then C-oborot-em:screen-value           = string( bo-oborot-em  [5]        )  .
  if use-column[13] then C-oborot-we:screen-value          = string( bo-oborot-we         [5])  .
  if use-column[14] then C-oborot-es:screen-value     = string( bo-oborot-es    [5])  .
  if use-column[15] then C-oborot-rs:screen-value = string( bo-oborot-rs[5])  .
  if use-column[16] then C-oborot-re:screen-value      = string( bo-oborot-re     [5])  .
  if use-column[17] then C-oborot-ep:screen-value       = string( bo-oborot-ep      [5])  .
  if use-column[18] then C-oborot-rv:screen-value      = string( bo-oborot-rv     [5])  .
  if use-column[19] then C-oborot-vt:screen-value                = string( bo-oborot-vt               [5])  .
  if use-column[20] then C-oborot-ot:screen-value           = string( bo-oborot-ot          [5])  .
  if use-column[22] then C-ostatok-end:screen-value                            = string( bo-ostatok-end                           [5])  .
  if use-column[25] then C-oborot-ap:screen-value     = string( bo-oborot-ap    [5])  .
  if use-column[26] then C-oborot-pc:screen-value     = string( bo-oborot-pc    [5])  .
  if use-column[27] then C-oborot-r-v:screen-value                      = string( bo-oborot-ee         [5] +
                                                                                         bo-oborot-re     [5] +
                                                                                         bo-oborot-es    [5] +
                                                                                         bo-oborot-rs[5] ).
  DISPLAY stream  OutStream  with FRAME ZAPAS .  DOWN stream   OutStream 1 with FRAME ZAPAS.
  end.
if xshowcrsands then do:
 if line-counter( OutStream )  > page-size( OutStream ) then DO : display STREAM OutStream    with frame top-frame. end.
  p = p + 1.
  if use-column[28] then c-str-num:screen-value           = '' .
  if use-column[1] then  c-s-bar-code:screen-value        = ''.
  if use-column[2] then  c-gds-zap-artic:screen-value     = ''.
  if use-column[3] then  c-gds-zap-gds-name:screen-value  = ''.
  if use-column[4] then  c-gds-zap-unit-base:screen-value = ''.
  if use-column[5] then  c-gds-type:screen-value          = "НДС прод."   .
  if use-column[6]  then C-ostatok-start:screen-value                          = string( bo-ostatok-start  [6])                         .
  if use-column[7]  then C-oborot-ie:screen-value          = string( bo-oborot-ie [6]        )  .
  if use-column[8]  then C-oborot-iv:screen-value          = string( bo-oborot-iv [6]        )  .
  if use-column[9]  then C-oborot-im:screen-value           = string( bo-oborot-im  [6]        )  .
  if use-column[10] then C-oborot-ee:screen-value          = string( bo-oborot-ee [6]        )  .
  if use-column[11] then C-oborot-ev:screen-value          = string( bo-oborot-ev [6]        )  .
  if use-column[12] then C-oborot-em:screen-value           = string( bo-oborot-em  [6]        )  .
  if use-column[13] then C-oborot-we:screen-value          = string( bo-oborot-we         [6])  .
  if use-column[14] then C-oborot-es:screen-value     = string( bo-oborot-es    [6])  .
  if use-column[15] then C-oborot-rs:screen-value = string( bo-oborot-rs[6])  .
  if use-column[16] then C-oborot-re:screen-value      = string( bo-oborot-re     [6])  .
  if use-column[17] then C-oborot-ep:screen-value       = string( bo-oborot-ep      [6])  .
  if use-column[18] then C-oborot-rv:screen-value      = string( bo-oborot-rv     [6])  .
  if use-column[19] then C-oborot-vt:screen-value                = string( bo-oborot-vt               [6])  .
  if use-column[20] then C-oborot-ot:screen-value           = string( bo-oborot-ot          [6])  .
  if use-column[22] then C-ostatok-end:screen-value                            = string( bo-ostatok-end                           [6])  .
  if use-column[25] then C-oborot-ap:screen-value     = string( bo-oborot-ap    [6])  .
  if use-column[26] then C-oborot-pc:screen-value     = string( bo-oborot-pc    [6])  .
  if use-column[27] then C-oborot-r-v:screen-value                      = string( bo-oborot-ee         [6] +
                                                                                         bo-oborot-re     [6] +
                                                                                         bo-oborot-es    [6] +
                                                                                         bo-oborot-rs[6] ).
  DISPLAY stream  OutStream  with FRAME ZAPAS .  DOWN stream   OutStream 1 with FRAME ZAPAS.
  end.
if xshowsale    then do:
 if line-counter( OutStream )  > page-size( OutStream ) then DO : display STREAM OutStream    with frame top-frame. end.
  p = p + 1.
  if use-column[28] then c-str-num:screen-value           = '' .
  if use-column[1] then  c-s-bar-code:screen-value        = ''.
  if use-column[2] then  c-gds-zap-artic:screen-value     = ''.
  if use-column[3] then  c-gds-zap-gds-name:screen-value  = ''.
  if use-column[4] then  c-gds-zap-unit-base:screen-value = ''.
  if use-column[5] then  c-gds-type:screen-value          = "док."   .
  if use-column[6]  then C-ostatok-start:screen-value                          = string( bo-ostatok-start  [8])                         .
  if use-column[7]  then C-oborot-ie:screen-value          = string( bo-oborot-ie [8]        )  .
  if use-column[8]  then C-oborot-iv:screen-value          = string( bo-oborot-iv [8]        )  .
  if use-column[9]  then C-oborot-im:screen-value           = string( bo-oborot-im  [8]        )  .
  if use-column[10] then C-oborot-ee:screen-value          = string( bo-oborot-ee [8]        )  .
  if use-column[11] then C-oborot-ev:screen-value          = string( bo-oborot-ev [8]        )  .
  if use-column[12] then C-oborot-em:screen-value           = string( bo-oborot-em  [8]        )  .
  if use-column[13] then C-oborot-we:screen-value          = string( bo-oborot-we         [8])  .
  if use-column[14] then C-oborot-es:screen-value     = string( bo-oborot-es    [8])  .
  if use-column[15] then C-oborot-rs:screen-value = string( bo-oborot-rs[8])  .
  if use-column[16] then C-oborot-re:screen-value      = string( bo-oborot-re     [8])  .
  if use-column[17] then C-oborot-ep:screen-value       = string( bo-oborot-ep      [8])  .
  if use-column[18] then C-oborot-rv:screen-value      = string( bo-oborot-rv     [8])  .
  if use-column[19] then C-oborot-vt:screen-value                = string( bo-oborot-vt               [8])  .
  if use-column[20] then C-oborot-ot:screen-value           = string( bo-oborot-ot          [8])  .
  if use-column[22] then C-ostatok-end:screen-value                            = string( bo-ostatok-end                           [8])  .
  if use-column[25] then C-oborot-ap:screen-value     = string( bo-oborot-ap    [8])  .
  if use-column[26] then C-oborot-pc:screen-value     = string( bo-oborot-pc    [8])  .
  if use-column[27] then C-oborot-r-v:screen-value                      = string( bo-oborot-ee         [8] +
                                                                                         bo-oborot-re     [8] +
                                                                                         bo-oborot-es    [8] +
                                                                                         bo-oborot-rs[8] ).
  DISPLAY stream  OutStream  with FRAME ZAPAS .  DOWN stream   OutStream 1 with FRAME ZAPAS.
  end.
if xshowsalends then do:
 if line-counter( OutStream )  > page-size( OutStream ) then DO : display STREAM OutStream    with frame top-frame. end.
  p = p + 1.
  if use-column[28] then c-str-num:screen-value           = '' .
  if use-column[1] then  c-s-bar-code:screen-value        = ''.
  if use-column[2] then  c-gds-zap-artic:screen-value     = ''.
  if use-column[3] then  c-gds-zap-gds-name:screen-value  = ''.
  if use-column[4] then  c-gds-zap-unit-base:screen-value = ''.
  if use-column[5] then  c-gds-type:screen-value          = "НДС док."   .
  if use-column[6]  then C-ostatok-start:screen-value                          = string( bo-ostatok-start  [9])                         .
  if use-column[7]  then C-oborot-ie:screen-value          = string( bo-oborot-ie [9]        )  .
  if use-column[8]  then C-oborot-iv:screen-value          = string( bo-oborot-iv [9]        )  .
  if use-column[9]  then C-oborot-im:screen-value           = string( bo-oborot-im  [9]        )  .
  if use-column[10] then C-oborot-ee:screen-value          = string( bo-oborot-ee [9]        )  .
  if use-column[11] then C-oborot-ev:screen-value          = string( bo-oborot-ev [9]        )  .
  if use-column[12] then C-oborot-em:screen-value           = string( bo-oborot-em  [9]        )  .
  if use-column[13] then C-oborot-we:screen-value          = string( bo-oborot-we         [9])  .
  if use-column[14] then C-oborot-es:screen-value     = string( bo-oborot-es    [9])  .
  if use-column[15] then C-oborot-rs:screen-value = string( bo-oborot-rs[9])  .
  if use-column[16] then C-oborot-re:screen-value      = string( bo-oborot-re     [9])  .
  if use-column[17] then C-oborot-ep:screen-value       = string( bo-oborot-ep      [9])  .
  if use-column[18] then C-oborot-rv:screen-value      = string( bo-oborot-rv     [9])  .
  if use-column[19] then C-oborot-vt:screen-value                = string( bo-oborot-vt               [9])  .
  if use-column[20] then C-oborot-ot:screen-value           = string( bo-oborot-ot          [9])  .
  if use-column[22] then C-ostatok-end:screen-value                            = string( bo-ostatok-end                           [9])  .
  if use-column[25] then C-oborot-ap:screen-value     = string( bo-oborot-ap    [9])  .
  if use-column[26] then C-oborot-pc:screen-value     = string( bo-oborot-pc    [9])  .
  if use-column[27] then C-oborot-r-v:screen-value                      = string( bo-oborot-ee         [9] +
                                                                                         bo-oborot-re     [9] +
                                                                                         bo-oborot-es    [9] +
                                                                                         bo-oborot-rs[9] ).
  DISPLAY stream  OutStream  with FRAME ZAPAS .  DOWN stream   OutStream 1 with FRAME ZAPAS.
  end.
if xshowsaleslt then do:
 if line-counter( OutStream )  > page-size( OutStream ) then DO : display STREAM OutStream    with frame top-frame. end.
  p = p + 1.
  if use-column[28] then c-str-num:screen-value           = '' .
  if use-column[1] then  c-s-bar-code:screen-value        = ''.
  if use-column[2] then  c-gds-zap-artic:screen-value     = ''.
  if use-column[3] then  c-gds-zap-gds-name:screen-value  = ''.
  if use-column[4] then  c-gds-zap-unit-base:screen-value = ''.
  if use-column[5] then  c-gds-type:screen-value          = "НсП док."   .
  if use-column[6]  then C-ostatok-start:screen-value                          = string( bo-ostatok-start  [10])                         .
  if use-column[7]  then C-oborot-ie:screen-value          = string( bo-oborot-ie [10]        )  .
  if use-column[8]  then C-oborot-iv:screen-value          = string( bo-oborot-iv [10]        )  .
  if use-column[9]  then C-oborot-im:screen-value           = string( bo-oborot-im  [10]        )  .
  if use-column[10] then C-oborot-ee:screen-value          = string( bo-oborot-ee [10]        )  .
  if use-column[11] then C-oborot-ev:screen-value          = string( bo-oborot-ev [10]        )  .
  if use-column[12] then C-oborot-em:screen-value           = string( bo-oborot-em  [10]        )  .
  if use-column[13] then C-oborot-we:screen-value          = string( bo-oborot-we         [10])  .
  if use-column[14] then C-oborot-es:screen-value     = string( bo-oborot-es    [10])  .
  if use-column[15] then C-oborot-rs:screen-value = string( bo-oborot-rs[10])  .
  if use-column[16] then C-oborot-re:screen-value      = string( bo-oborot-re     [10])  .
  if use-column[17] then C-oborot-ep:screen-value       = string( bo-oborot-ep      [10])  .
  if use-column[18] then C-oborot-rv:screen-value      = string( bo-oborot-rv     [10])  .
  if use-column[19] then C-oborot-vt:screen-value                = string( bo-oborot-vt               [10])  .
  if use-column[20] then C-oborot-ot:screen-value           = string( bo-oborot-ot          [10])  .
  if use-column[22] then C-ostatok-end:screen-value                            = string( bo-ostatok-end                           [10])  .
  if use-column[25] then C-oborot-ap:screen-value     = string( bo-oborot-ap    [10])  .
  if use-column[26] then C-oborot-pc:screen-value     = string( bo-oborot-pc    [10])  .
  if use-column[27] then C-oborot-r-v:screen-value                      = string( bo-oborot-ee         [10] +
                                                                                         bo-oborot-re     [10] +
                                                                                         bo-oborot-es    [10] +
                                                                                         bo-oborot-rs[10] ).
  DISPLAY stream  OutStream  with FRAME ZAPAS .  DOWN stream   OutStream 1 with FRAME ZAPAS.
  end.
if xshowmediator then do:
 if line-counter( OutStream )  > page-size( OutStream ) then DO : display STREAM OutStream    with frame top-frame. end.
  p = p + 1.
  if use-column[28] then c-str-num:screen-value           = '' .
  if use-column[1] then  c-s-bar-code:screen-value        = ''.
  if use-column[2] then  c-gds-zap-artic:screen-value     = ''.
  if use-column[3] then  c-gds-zap-gds-name:screen-value  = ''.
  if use-column[4] then  c-gds-zap-unit-base:screen-value = ''.
  if use-column[5] then  c-gds-type:screen-value          = "поср."   .
  if use-column[6]  then C-ostatok-start:screen-value                          = string( bo-ostatok-start  [4])                         .
  if use-column[7]  then C-oborot-ie:screen-value          = string( bo-oborot-ie [4]        )  .
  if use-column[8]  then C-oborot-iv:screen-value          = string( bo-oborot-iv [4]        )  .
  if use-column[9]  then C-oborot-im:screen-value           = string( bo-oborot-im  [4]        )  .
  if use-column[10] then C-oborot-ee:screen-value          = string( bo-oborot-ee [4]        )  .
  if use-column[11] then C-oborot-ev:screen-value          = string( bo-oborot-ev [4]        )  .
  if use-column[12] then C-oborot-em:screen-value           = string( bo-oborot-em  [4]        )  .
  if use-column[13] then C-oborot-we:screen-value          = string( bo-oborot-we         [4])  .
  if use-column[14] then C-oborot-es:screen-value     = string( bo-oborot-es    [4])  .
  if use-column[15] then C-oborot-rs:screen-value = string( bo-oborot-rs[4])  .
  if use-column[16] then C-oborot-re:screen-value      = string( bo-oborot-re     [4])  .
  if use-column[17] then C-oborot-ep:screen-value       = string( bo-oborot-ep      [4])  .
  if use-column[18] then C-oborot-rv:screen-value      = string( bo-oborot-rv     [4])  .
  if use-column[19] then C-oborot-vt:screen-value                = string( bo-oborot-vt               [4])  .
  if use-column[20] then C-oborot-ot:screen-value           = string( bo-oborot-ot          [4])  .
  if use-column[22] then C-ostatok-end:screen-value                            = string( bo-ostatok-end                           [4])  .
  if use-column[25] then C-oborot-ap:screen-value     = string( bo-oborot-ap    [4])  .
  if use-column[26] then C-oborot-pc:screen-value     = string( bo-oborot-pc    [4])  .
  if use-column[27] then C-oborot-r-v:screen-value                      = string( bo-oborot-ee         [4] +
                                                                                         bo-oborot-re     [4] +
                                                                                         bo-oborot-es    [4] +
                                                                                         bo-oborot-rs[4] ).
  DISPLAY stream  OutStream  with FRAME ZAPAS .  DOWN stream   OutStream 1 with FRAME ZAPAS.
  end.
run clear-bo  in this-procedure .
end procedure.
procedure display-b1  :
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
  if xshowcost    then do:  run price-vat in this-procedure ( 'b1').  end.
  if xshowcostnds then do:
 if line-counter( OutStream )  > page-size( OutStream ) then DO : display STREAM OutStream    with frame top-frame. end.
  p = p + 1.
  if use-column[28] then c-str-num:screen-value           = '' .
  if use-column[1] then  c-s-bar-code:screen-value        = ''.
  if use-column[2] then  c-gds-zap-artic:screen-value     = ''.
  if use-column[3] then  c-gds-zap-gds-name:screen-value  = ''.
  if use-column[4] then  c-gds-zap-unit-base:screen-value = ''.
  if use-column[5] then  c-gds-type:screen-value          = "НДС учет."   .
  if use-column[6]  then C-ostatok-start:screen-value                          = string( b1-ostatok-start  [3])                         .
  if use-column[7]  then C-oborot-ie:screen-value          = string( b1-oborot-ie [3]        )  .
  if use-column[8]  then C-oborot-iv:screen-value          = string( b1-oborot-iv [3]        )  .
  if use-column[9]  then C-oborot-im:screen-value           = string( b1-oborot-im  [3]        )  .
  if use-column[10] then C-oborot-ee:screen-value          = string( b1-oborot-ee [3]        )  .
  if use-column[11] then C-oborot-ev:screen-value          = string( b1-oborot-ev [3]        )  .
  if use-column[12] then C-oborot-em:screen-value           = string( b1-oborot-em  [3]        )  .
  if use-column[13] then C-oborot-we:screen-value          = string( b1-oborot-we         [3])  .
  if use-column[14] then C-oborot-es:screen-value     = string( b1-oborot-es    [3])  .
  if use-column[15] then C-oborot-rs:screen-value = string( b1-oborot-rs[3])  .
  if use-column[16] then C-oborot-re:screen-value      = string( b1-oborot-re     [3])  .
  if use-column[17] then C-oborot-ep:screen-value       = string( b1-oborot-ep      [3])  .
  if use-column[18] then C-oborot-rv:screen-value      = string( b1-oborot-rv     [3])  .
  if use-column[19] then C-oborot-vt:screen-value                = string( b1-oborot-vt               [3])  .
  if use-column[20] then C-oborot-ot:screen-value           = string( b1-oborot-ot          [3])  .
  if use-column[22] then C-ostatok-end:screen-value                            = string( b1-ostatok-end                           [3])  .
  if use-column[25] then C-oborot-ap:screen-value     = string( b1-oborot-ap    [3])  .
  if use-column[26] then C-oborot-pc:screen-value     = string( b1-oborot-pc    [3])  .
  if use-column[27] then C-oborot-r-v:screen-value                      = string( b1-oborot-ee         [3] +
                                                                                         b1-oborot-re     [3] +
                                                                                         b1-oborot-es    [3] +
                                                                                         b1-oborot-rs[3] ).
  DISPLAY stream  OutStream  with FRAME ZAPAS .  DOWN stream   OutStream 1 with FRAME ZAPAS.
  end.
  if xshowcrsa    then do:
 if line-counter( OutStream )  > page-size( OutStream ) then DO : display STREAM OutStream    with frame top-frame. end.
  p = p + 1.
  if use-column[28] then c-str-num:screen-value           = '' .
  if use-column[1] then  c-s-bar-code:screen-value        = ''.
  if use-column[2] then  c-gds-zap-artic:screen-value     = ''.
  if use-column[3] then  c-gds-zap-gds-name:screen-value  = ''.
  if use-column[4] then  c-gds-zap-unit-base:screen-value = ''.
  if use-column[5] then  c-gds-type:screen-value          = "прод."   .
  if use-column[6]  then C-ostatok-start:screen-value                          = string( b1-ostatok-start  [5])                         .
  if use-column[7]  then C-oborot-ie:screen-value          = string( b1-oborot-ie [5]        )  .
  if use-column[8]  then C-oborot-iv:screen-value          = string( b1-oborot-iv [5]        )  .
  if use-column[9]  then C-oborot-im:screen-value           = string( b1-oborot-im  [5]        )  .
  if use-column[10] then C-oborot-ee:screen-value          = string( b1-oborot-ee [5]        )  .
  if use-column[11] then C-oborot-ev:screen-value          = string( b1-oborot-ev [5]        )  .
  if use-column[12] then C-oborot-em:screen-value           = string( b1-oborot-em  [5]        )  .
  if use-column[13] then C-oborot-we:screen-value          = string( b1-oborot-we         [5])  .
  if use-column[14] then C-oborot-es:screen-value     = string( b1-oborot-es    [5])  .
  if use-column[15] then C-oborot-rs:screen-value = string( b1-oborot-rs[5])  .
  if use-column[16] then C-oborot-re:screen-value      = string( b1-oborot-re     [5])  .
  if use-column[17] then C-oborot-ep:screen-value       = string( b1-oborot-ep      [5])  .
  if use-column[18] then C-oborot-rv:screen-value      = string( b1-oborot-rv     [5])  .
  if use-column[19] then C-oborot-vt:screen-value                = string( b1-oborot-vt               [5])  .
  if use-column[20] then C-oborot-ot:screen-value           = string( b1-oborot-ot          [5])  .
  if use-column[22] then C-ostatok-end:screen-value                            = string( b1-ostatok-end                           [5])  .
  if use-column[25] then C-oborot-ap:screen-value     = string( b1-oborot-ap    [5])  .
  if use-column[26] then C-oborot-pc:screen-value     = string( b1-oborot-pc    [5])  .
  if use-column[27] then C-oborot-r-v:screen-value                      = string( b1-oborot-ee         [5] +
                                                                                         b1-oborot-re     [5] +
                                                                                         b1-oborot-es    [5] +
                                                                                         b1-oborot-rs[5] ).
  DISPLAY stream  OutStream  with FRAME ZAPAS .  DOWN stream   OutStream 1 with FRAME ZAPAS.
  end.
  if xshowcrsands then do:
 if line-counter( OutStream )  > page-size( OutStream ) then DO : display STREAM OutStream    with frame top-frame. end.
  p = p + 1.
  if use-column[28] then c-str-num:screen-value           = '' .
  if use-column[1] then  c-s-bar-code:screen-value        = ''.
  if use-column[2] then  c-gds-zap-artic:screen-value     = ''.
  if use-column[3] then  c-gds-zap-gds-name:screen-value  = ''.
  if use-column[4] then  c-gds-zap-unit-base:screen-value = ''.
  if use-column[5] then  c-gds-type:screen-value          = "НДС прод."   .
  if use-column[6]  then C-ostatok-start:screen-value                          = string( b1-ostatok-start  [6])                         .
  if use-column[7]  then C-oborot-ie:screen-value          = string( b1-oborot-ie [6]        )  .
  if use-column[8]  then C-oborot-iv:screen-value          = string( b1-oborot-iv [6]        )  .
  if use-column[9]  then C-oborot-im:screen-value           = string( b1-oborot-im  [6]        )  .
  if use-column[10] then C-oborot-ee:screen-value          = string( b1-oborot-ee [6]        )  .
  if use-column[11] then C-oborot-ev:screen-value          = string( b1-oborot-ev [6]        )  .
  if use-column[12] then C-oborot-em:screen-value           = string( b1-oborot-em  [6]        )  .
  if use-column[13] then C-oborot-we:screen-value          = string( b1-oborot-we         [6])  .
  if use-column[14] then C-oborot-es:screen-value     = string( b1-oborot-es    [6])  .
  if use-column[15] then C-oborot-rs:screen-value = string( b1-oborot-rs[6])  .
  if use-column[16] then C-oborot-re:screen-value      = string( b1-oborot-re     [6])  .
  if use-column[17] then C-oborot-ep:screen-value       = string( b1-oborot-ep      [6])  .
  if use-column[18] then C-oborot-rv:screen-value      = string( b1-oborot-rv     [6])  .
  if use-column[19] then C-oborot-vt:screen-value                = string( b1-oborot-vt               [6])  .
  if use-column[20] then C-oborot-ot:screen-value           = string( b1-oborot-ot          [6])  .
  if use-column[22] then C-ostatok-end:screen-value                            = string( b1-ostatok-end                           [6])  .
  if use-column[25] then C-oborot-ap:screen-value     = string( b1-oborot-ap    [6])  .
  if use-column[26] then C-oborot-pc:screen-value     = string( b1-oborot-pc    [6])  .
  if use-column[27] then C-oborot-r-v:screen-value                      = string( b1-oborot-ee         [6] +
                                                                                         b1-oborot-re     [6] +
                                                                                         b1-oborot-es    [6] +
                                                                                         b1-oborot-rs[6] ).
  DISPLAY stream  OutStream  with FRAME ZAPAS .  DOWN stream   OutStream 1 with FRAME ZAPAS.
  end.
  if xshowsale    then do:
 if line-counter( OutStream )  > page-size( OutStream ) then DO : display STREAM OutStream    with frame top-frame. end.
  p = p + 1.
  if use-column[28] then c-str-num:screen-value           = '' .
  if use-column[1] then  c-s-bar-code:screen-value        = ''.
  if use-column[2] then  c-gds-zap-artic:screen-value     = ''.
  if use-column[3] then  c-gds-zap-gds-name:screen-value  = ''.
  if use-column[4] then  c-gds-zap-unit-base:screen-value = ''.
  if use-column[5] then  c-gds-type:screen-value          = "док."   .
  if use-column[6]  then C-ostatok-start:screen-value                          = string( b1-ostatok-start  [8])                         .
  if use-column[7]  then C-oborot-ie:screen-value          = string( b1-oborot-ie [8]        )  .
  if use-column[8]  then C-oborot-iv:screen-value          = string( b1-oborot-iv [8]        )  .
  if use-column[9]  then C-oborot-im:screen-value           = string( b1-oborot-im  [8]        )  .
  if use-column[10] then C-oborot-ee:screen-value          = string( b1-oborot-ee [8]        )  .
  if use-column[11] then C-oborot-ev:screen-value          = string( b1-oborot-ev [8]        )  .
  if use-column[12] then C-oborot-em:screen-value           = string( b1-oborot-em  [8]        )  .
  if use-column[13] then C-oborot-we:screen-value          = string( b1-oborot-we         [8])  .
  if use-column[14] then C-oborot-es:screen-value     = string( b1-oborot-es    [8])  .
  if use-column[15] then C-oborot-rs:screen-value = string( b1-oborot-rs[8])  .
  if use-column[16] then C-oborot-re:screen-value      = string( b1-oborot-re     [8])  .
  if use-column[17] then C-oborot-ep:screen-value       = string( b1-oborot-ep      [8])  .
  if use-column[18] then C-oborot-rv:screen-value      = string( b1-oborot-rv     [8])  .
  if use-column[19] then C-oborot-vt:screen-value                = string( b1-oborot-vt               [8])  .
  if use-column[20] then C-oborot-ot:screen-value           = string( b1-oborot-ot          [8])  .
  if use-column[22] then C-ostatok-end:screen-value                            = string( b1-ostatok-end                           [8])  .
  if use-column[25] then C-oborot-ap:screen-value     = string( b1-oborot-ap    [8])  .
  if use-column[26] then C-oborot-pc:screen-value     = string( b1-oborot-pc    [8])  .
  if use-column[27] then C-oborot-r-v:screen-value                      = string( b1-oborot-ee         [8] +
                                                                                         b1-oborot-re     [8] +
                                                                                         b1-oborot-es    [8] +
                                                                                         b1-oborot-rs[8] ).
  DISPLAY stream  OutStream  with FRAME ZAPAS .  DOWN stream   OutStream 1 with FRAME ZAPAS.
  end.
  if xshowsalends then do:
 if line-counter( OutStream )  > page-size( OutStream ) then DO : display STREAM OutStream    with frame top-frame. end.
  p = p + 1.
  if use-column[28] then c-str-num:screen-value           = '' .
  if use-column[1] then  c-s-bar-code:screen-value        = ''.
  if use-column[2] then  c-gds-zap-artic:screen-value     = ''.
  if use-column[3] then  c-gds-zap-gds-name:screen-value  = ''.
  if use-column[4] then  c-gds-zap-unit-base:screen-value = ''.
  if use-column[5] then  c-gds-type:screen-value          = "НДС док."   .
  if use-column[6]  then C-ostatok-start:screen-value                          = string( b1-ostatok-start  [9])                         .
  if use-column[7]  then C-oborot-ie:screen-value          = string( b1-oborot-ie [9]        )  .
  if use-column[8]  then C-oborot-iv:screen-value          = string( b1-oborot-iv [9]        )  .
  if use-column[9]  then C-oborot-im:screen-value           = string( b1-oborot-im  [9]        )  .
  if use-column[10] then C-oborot-ee:screen-value          = string( b1-oborot-ee [9]        )  .
  if use-column[11] then C-oborot-ev:screen-value          = string( b1-oborot-ev [9]        )  .
  if use-column[12] then C-oborot-em:screen-value           = string( b1-oborot-em  [9]        )  .
  if use-column[13] then C-oborot-we:screen-value          = string( b1-oborot-we         [9])  .
  if use-column[14] then C-oborot-es:screen-value     = string( b1-oborot-es    [9])  .
  if use-column[15] then C-oborot-rs:screen-value = string( b1-oborot-rs[9])  .
  if use-column[16] then C-oborot-re:screen-value      = string( b1-oborot-re     [9])  .
  if use-column[17] then C-oborot-ep:screen-value       = string( b1-oborot-ep      [9])  .
  if use-column[18] then C-oborot-rv:screen-value      = string( b1-oborot-rv     [9])  .
  if use-column[19] then C-oborot-vt:screen-value                = string( b1-oborot-vt               [9])  .
  if use-column[20] then C-oborot-ot:screen-value           = string( b1-oborot-ot          [9])  .
  if use-column[22] then C-ostatok-end:screen-value                            = string( b1-ostatok-end                           [9])  .
  if use-column[25] then C-oborot-ap:screen-value     = string( b1-oborot-ap    [9])  .
  if use-column[26] then C-oborot-pc:screen-value     = string( b1-oborot-pc    [9])  .
  if use-column[27] then C-oborot-r-v:screen-value                      = string( b1-oborot-ee         [9] +
                                                                                         b1-oborot-re     [9] +
                                                                                         b1-oborot-es    [9] +
                                                                                         b1-oborot-rs[9] ).
  DISPLAY stream  OutStream  with FRAME ZAPAS .  DOWN stream   OutStream 1 with FRAME ZAPAS.
  end.
  if xshowsaleslt then do:
 if line-counter( OutStream )  > page-size( OutStream ) then DO : display STREAM OutStream    with frame top-frame. end.
  p = p + 1.
  if use-column[28] then c-str-num:screen-value           = '' .
  if use-column[1] then  c-s-bar-code:screen-value        = ''.
  if use-column[2] then  c-gds-zap-artic:screen-value     = ''.
  if use-column[3] then  c-gds-zap-gds-name:screen-value  = ''.
  if use-column[4] then  c-gds-zap-unit-base:screen-value = ''.
  if use-column[5] then  c-gds-type:screen-value          = "НсП док."   .
  if use-column[6]  then C-ostatok-start:screen-value                          = string( b1-ostatok-start  [10])                         .
  if use-column[7]  then C-oborot-ie:screen-value          = string( b1-oborot-ie [10]        )  .
  if use-column[8]  then C-oborot-iv:screen-value          = string( b1-oborot-iv [10]        )  .
  if use-column[9]  then C-oborot-im:screen-value           = string( b1-oborot-im  [10]        )  .
  if use-column[10] then C-oborot-ee:screen-value          = string( b1-oborot-ee [10]        )  .
  if use-column[11] then C-oborot-ev:screen-value          = string( b1-oborot-ev [10]        )  .
  if use-column[12] then C-oborot-em:screen-value           = string( b1-oborot-em  [10]        )  .
  if use-column[13] then C-oborot-we:screen-value          = string( b1-oborot-we         [10])  .
  if use-column[14] then C-oborot-es:screen-value     = string( b1-oborot-es    [10])  .
  if use-column[15] then C-oborot-rs:screen-value = string( b1-oborot-rs[10])  .
  if use-column[16] then C-oborot-re:screen-value      = string( b1-oborot-re     [10])  .
  if use-column[17] then C-oborot-ep:screen-value       = string( b1-oborot-ep      [10])  .
  if use-column[18] then C-oborot-rv:screen-value      = string( b1-oborot-rv     [10])  .
  if use-column[19] then C-oborot-vt:screen-value                = string( b1-oborot-vt               [10])  .
  if use-column[20] then C-oborot-ot:screen-value           = string( b1-oborot-ot          [10])  .
  if use-column[22] then C-ostatok-end:screen-value                            = string( b1-ostatok-end                           [10])  .
  if use-column[25] then C-oborot-ap:screen-value     = string( b1-oborot-ap    [10])  .
  if use-column[26] then C-oborot-pc:screen-value     = string( b1-oborot-pc    [10])  .
  if use-column[27] then C-oborot-r-v:screen-value                      = string( b1-oborot-ee         [10] +
                                                                                         b1-oborot-re     [10] +
                                                                                         b1-oborot-es    [10] +
                                                                                         b1-oborot-rs[10] ).
  DISPLAY stream  OutStream  with FRAME ZAPAS .  DOWN stream   OutStream 1 with FRAME ZAPAS.
  end.
  if xshowmediator then do:
 if line-counter( OutStream )  > page-size( OutStream ) then DO : display STREAM OutStream    with frame top-frame. end.
  p = p + 1.
  if use-column[28] then c-str-num:screen-value           = '' .
  if use-column[1] then  c-s-bar-code:screen-value        = ''.
  if use-column[2] then  c-gds-zap-artic:screen-value     = ''.
  if use-column[3] then  c-gds-zap-gds-name:screen-value  = ''.
  if use-column[4] then  c-gds-zap-unit-base:screen-value = ''.
  if use-column[5] then  c-gds-type:screen-value          = "поср."   .
  if use-column[6]  then C-ostatok-start:screen-value                          = string( b1-ostatok-start  [4])                         .
  if use-column[7]  then C-oborot-ie:screen-value          = string( b1-oborot-ie [4]        )  .
  if use-column[8]  then C-oborot-iv:screen-value          = string( b1-oborot-iv [4]        )  .
  if use-column[9]  then C-oborot-im:screen-value           = string( b1-oborot-im  [4]        )  .
  if use-column[10] then C-oborot-ee:screen-value          = string( b1-oborot-ee [4]        )  .
  if use-column[11] then C-oborot-ev:screen-value          = string( b1-oborot-ev [4]        )  .
  if use-column[12] then C-oborot-em:screen-value           = string( b1-oborot-em  [4]        )  .
  if use-column[13] then C-oborot-we:screen-value          = string( b1-oborot-we         [4])  .
  if use-column[14] then C-oborot-es:screen-value     = string( b1-oborot-es    [4])  .
  if use-column[15] then C-oborot-rs:screen-value = string( b1-oborot-rs[4])  .
  if use-column[16] then C-oborot-re:screen-value      = string( b1-oborot-re     [4])  .
  if use-column[17] then C-oborot-ep:screen-value       = string( b1-oborot-ep      [4])  .
  if use-column[18] then C-oborot-rv:screen-value      = string( b1-oborot-rv     [4])  .
  if use-column[19] then C-oborot-vt:screen-value                = string( b1-oborot-vt               [4])  .
  if use-column[20] then C-oborot-ot:screen-value           = string( b1-oborot-ot          [4])  .
  if use-column[22] then C-ostatok-end:screen-value                            = string( b1-ostatok-end                           [4])  .
  if use-column[25] then C-oborot-ap:screen-value     = string( b1-oborot-ap    [4])  .
  if use-column[26] then C-oborot-pc:screen-value     = string( b1-oborot-pc    [4])  .
  if use-column[27] then C-oborot-r-v:screen-value                      = string( b1-oborot-ee         [4] +
                                                                                         b1-oborot-re     [4] +
                                                                                         b1-oborot-es    [4] +
                                                                                         b1-oborot-rs[4] ).
  DISPLAY stream  OutStream  with FRAME ZAPAS .  DOWN stream   OutStream 1 with FRAME ZAPAS.
  end.
end procedure.
procedure clear-b1  :
repeat kk = 1 to 10 :
assign
b1-oborot-ie         [kk] = 0
b1-oborot-ee         [kk] = 0
b1-oborot-ep      [kk] = 0
b1-oborot-es    [kk] = 0
b1-oborot-re     [kk] = 0
b1-oborot-rs [kk] = 0
b1-oborot-we         [kk] = 0
b1-oborot-vt               [kk] = 0
b1-oborot-iv         [kk] = 0
b1-oborot-ev         [kk] = 0
b1-oborot-rv     [kk] = 0
b1-oborot-em          [kk] = 0
b1-oborot-wm          [kk] = 0
b1-oborot-im          [kk] = 0
b1-oborot-ot          [kk] = 0
b1-oborot-disc                    [kk] = 0
b1-oborot-eff                     [kk] = 0
b1-oborot-prc                     [kk] = 0
b1-ostatok-end                           [kk] = 0
b1-ostatok-start                         [kk] = 0
b1-oborot-sum-sale                       [kk] = 0
b1-oborot-sum-cost                       [kk] = 0
b1-oborot-ap [kk] = 0
b1-oborot-pc [kk] = 0
.
end.
end procedure.
procedure clear-bi  :
repeat kk = 1 to 10 :
assign
bi-oborot-ie         [kk] = 0
bi-oborot-ee         [kk] = 0
bi-oborot-ep      [kk] = 0
bi-oborot-es    [kk] = 0
bi-oborot-re     [kk] = 0
bi-oborot-rs [kk] = 0
bi-oborot-we         [kk] = 0
bi-oborot-vt               [kk] = 0
bi-oborot-iv         [kk] = 0
bi-oborot-ev         [kk] = 0
bi-oborot-rv     [kk] = 0
bi-oborot-em          [kk] = 0
bi-oborot-wm          [kk] = 0
bi-oborot-im          [kk] = 0
bi-oborot-ot          [kk] = 0
bi-oborot-disc                    [kk] = 0
bi-oborot-eff                     [kk] = 0
bi-oborot-prc                     [kk] = 0
bi-ostatok-end                           [kk] = 0
bi-ostatok-start                         [kk] = 0
bi-oborot-sum-sale                       [kk] = 0
bi-oborot-sum-cost                       [kk] = 0
bi-oborot-ap [kk] = 0
bi-oborot-pc [kk] = 0
.
end.
end procedure.
procedure clear-bo  :
repeat kk = 1 to 10 :
assign
bo-oborot-ie         [kk] = 0
bo-oborot-ee         [kk] = 0
bo-oborot-ep      [kk] = 0
bo-oborot-es    [kk] = 0
bo-oborot-re     [kk] = 0
bo-oborot-rs [kk] = 0
bo-oborot-we         [kk] = 0
bo-oborot-vt               [kk] = 0
bo-oborot-iv         [kk] = 0
bo-oborot-ev         [kk] = 0
bo-oborot-rv     [kk] = 0
bo-oborot-em          [kk] = 0
bo-oborot-wm          [kk] = 0
bo-oborot-im          [kk] = 0
bo-oborot-ot          [kk] = 0
bo-oborot-disc                    [kk] = 0
bo-oborot-eff                     [kk] = 0
bo-oborot-prc                     [kk] = 0
bo-ostatok-end                           [kk] = 0
bo-ostatok-start                         [kk] = 0
bo-oborot-sum-sale                       [kk] = 0
bo-oborot-sum-cost                       [kk] = 0
bo-oborot-ap [kk] = 0
bo-oborot-pc [kk] = 0
.
end.
end procedure.
procedure display-title :
   PUT stream  OutStream  UNFORMATTED  string( v-cntxt-host-name-obj +  " , " + x-store-type  +  " " + objname) at 50 format "x(85)" skip( 2)
          reportname  at 1 format "x(133)" skip
          trim( str1)  at 35 format "x(75)" skip.
     repeat i = 1 to num-entries( str2,chr( 10)) :
      PUT stream  OutStream  UNFORMATTED  entry( i,str2,chr( 10))  at 1 format "x(130)" skip.
     end.
    i=0.
     repeat i = 1 to num-entries( str3,chr( 10)) :
      PUT stream  OutStream  UNFORMATTED  entry( i,str3,chr( 10))  at 1 format "x(130)" skip.
     end.
    i=0.
     repeat i = 1 to num-entries( str4,chr( 10)) :
      PUT stream  OutStream  UNFORMATTED  entry( i,str4,chr( 10))  at 1 format "x(130)" skip.
     end.
    i=0.
     repeat i = 1 to num-entries( reportheader,chr( 10)) :
      PUT stream  OutStream  UNFORMATTED  entry( i,reportheader,chr( 10))  at 1 format "x(130)" skip.
     end.
    i=0.
 end procedure.
procedure ob-line  :
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
end procedure.
procedure sum-i :
def input parameter ob like oborot-ot[1] no-undo.
def input parameter tt as int  no-undo.
def input-output parameter b1 like b1-oborot-ot[1] no-undo.
def input-output parameter b2 like b1-oborot-ot[1] no-undo.
def input-output parameter bi like b1-oborot-ot[1] no-undo.
def input-output parameter bo like b1-oborot-ot[1] no-undo.
def input parameter ob2 like oborot-ot[1] no-undo.
def input-output parameter b1- like b1-oborot-ot[1] no-undo.
def input-output parameter b2- like b1-oborot-ot[1] no-undo.
def input-output parameter bi- like b1-oborot-ot[1] no-undo.
def input-output parameter bo- like b1-oborot-ot[1] no-undo.
assign
 b1  = b1 + ob
 b2  = b2 + ob
 b1- = b1- + ob2
 b2- = b2- + ob2
 .
if tmp-gds.lvl <= 1 then do:
    assign
    bi = bi + ob
    bo = bo + ob
    bi- = bi- + ob2
    bo- = bo- + ob2
    .
end.
end procedure.
procedure clear-item :
define variable kk as int no-undo.
 repeat kk = 1 to 10 :
 assign
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
    oborot-pc           [kk]    = 0
    oborot-ap           [kk]    = 0
    oborot-disc                             [kk]    = 0
    oborot-eff                             [kk]    = 0
    oborot-prc                             [kk]    = 0
    ostatok-end      [kk] =   0
    ostatok-start    [kk] =   0   .
       end.
 end procedure.
procedure null-str-pr :
 if (
     oborot-ie     [1]         = 0  and
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
     oborot-ot                 [2] = 0  and
     oborot-pc           [1]    = 0 and
     oborot-ap           [1]    = 0 and
     ostatok-end[1]                                    = 0  and
     ostatok-start[1]                                  = 0 and
     oborot-ie     [2]         = 0  and
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
     oborot-pc           [2]    = 0 and
     oborot-ap           [2]    = 0 and
     ostatok-end[2]                                    = 0  and
     ostatok-start[2]                                  = 0
     ) then   null-str# = 0    .
 end procedure.
procedure null-str-pr2 :
 if (
     oborot-ie     [1]         = 0  and
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
     oborot-pc           [1]    = 0 and
     oborot-ap           [1]    = 0 and
     oborot-ie     [2]         = 0  and
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
     oborot-pc           [2]    = 0 and
     oborot-ap           [2]    = 0 and
     oborot-ot                 [2] = 0
     ) then   null-str2# = 0    .
 end procedure.
procedure u-line:
        PUT stream  OutStream  UNFORMATTED  line2 format "x(319)" skip.
end procedure.
procedure p-line:
end procedure.
procedure make-tt-ed :
create temp#sum-type.
assign temp#sum-type.sum-type = 'csdt':U + 'ie':U temp#sum-type.xi = 1 . create temp#sum-type.
assign temp#sum-type.sum-type = 'csdt':U + 'ee':U temp#sum-type.xi = 2 . create temp#sum-type.
assign temp#sum-type.sum-type = 'csdt':U + 'ep':U temp#sum-type.xi = 3 . create temp#sum-type.
assign temp#sum-type.sum-type = 'csdt':U + 'es':U temp#sum-type.xi = 4 . create temp#sum-type.
assign temp#sum-type.sum-type = 'csdt':U + 're':U temp#sum-type.xi = 5 . create temp#sum-type.
assign temp#sum-type.sum-type = 'csdt':U + 'rs':U temp#sum-type.xi = 6 . create temp#sum-type.
assign temp#sum-type.sum-type = 'csdt':U + 'we':U temp#sum-type.xi = 7 . create temp#sum-type.
assign temp#sum-type.sum-type = 'csdt':U + 'vt':U temp#sum-type.xi = 8 . create temp#sum-type.
assign temp#sum-type.sum-type = 'csdt':U + 'iv':U temp#sum-type.xi = 9 . create temp#sum-type.
assign temp#sum-type.sum-type = 'csdt':U + 'ev':U temp#sum-type.xi = 10. create temp#sum-type.
assign temp#sum-type.sum-type = 'csdt':U + 'rv':U temp#sum-type.xi = 11. create temp#sum-type.
assign temp#sum-type.sum-type = 'csdt':U + 'em':U temp#sum-type.xi = 12. create temp#sum-type.
assign temp#sum-type.sum-type = 'csdt':U + 'wm':U temp#sum-type.xi = 12. create temp#sum-type.
assign temp#sum-type.sum-type = 'csdt':U + 'im':U temp#sum-type.xi = 13. create temp#sum-type.
assign temp#sum-type.sum-type = 'csdt':U + 'ot':U temp#sum-type.xi = 14.
create temp#sum-type.
assign temp#sum-type.sum-type = 'csdt':U + 'ap':U temp#sum-type.xi = 15 . create temp#sum-type.
assign temp#sum-type.sum-type = 'csdt':U + 'pc':U temp#sum-type.xi = 16 .
create temp#sum-type.
assign temp#sum-type.sum-type = 'cgdt':U + 'ie':U temp#sum-type.xi = 101 . create temp#sum-type.
assign temp#sum-type.sum-type = 'cgdt':U + 'ee':U temp#sum-type.xi = 102 . create temp#sum-type.
assign temp#sum-type.sum-type = 'cgdt':U + 'ep':U temp#sum-type.xi = 103 . create temp#sum-type.
assign temp#sum-type.sum-type = 'cgdt':U + 'es':U temp#sum-type.xi = 104 . create temp#sum-type.
assign temp#sum-type.sum-type = 'cgdt':U + 're':U temp#sum-type.xi = 105 . create temp#sum-type.
assign temp#sum-type.sum-type = 'cgdt':U + 'rs':U temp#sum-type.xi = 106 . create temp#sum-type.
assign temp#sum-type.sum-type = 'cgdt':U + 'we':U temp#sum-type.xi = 107 . create temp#sum-type.
assign temp#sum-type.sum-type = 'cgdt':U + 'vt':U temp#sum-type.xi = 108 . create temp#sum-type.
assign temp#sum-type.sum-type = 'cgdt':U + 'iv':U temp#sum-type.xi = 109 . create temp#sum-type.
assign temp#sum-type.sum-type = 'cgdt':U + 'ev':U temp#sum-type.xi = 110. create temp#sum-type.
assign temp#sum-type.sum-type = 'cgdt':U + 'rv':U temp#sum-type.xi = 111. create temp#sum-type.
assign temp#sum-type.sum-type = 'cgdt':U + 'em':U temp#sum-type.xi = 112. create temp#sum-type.
assign temp#sum-type.sum-type = 'cgdt':U + 'wm':U temp#sum-type.xi = 112. create temp#sum-type.
assign temp#sum-type.sum-type = 'cgdt':U + 'im':U temp#sum-type.xi = 113. create temp#sum-type.
assign temp#sum-type.sum-type = 'cgdt':U + 'ot':U temp#sum-type.xi = 114.
create temp#sum-type.
assign temp#sum-type.sum-type = 'cgdt':U + 'ap':U temp#sum-type.xi = 115 . create temp#sum-type.
assign temp#sum-type.sum-type = 'cgdt':U + 'pc':U temp#sum-type.xi = 116 .
create temp#sum-type.
assign temp#sum-type.sum-type = 'sadt':U + 'ie':U temp#sum-type.xi = 201 . create temp#sum-type.
assign temp#sum-type.sum-type = 'sadt':U + 'ee':U temp#sum-type.xi = 202 . create temp#sum-type.
assign temp#sum-type.sum-type = 'sadt':U + 'ep':U temp#sum-type.xi = 203 . create temp#sum-type.
assign temp#sum-type.sum-type = 'sadt':U + 'es':U temp#sum-type.xi = 204 . create temp#sum-type.
assign temp#sum-type.sum-type = 'sadt':U + 're':U temp#sum-type.xi = 205 . create temp#sum-type.
assign temp#sum-type.sum-type = 'sadt':U + 'rs':U temp#sum-type.xi = 206 . create temp#sum-type.
assign temp#sum-type.sum-type = 'sadt':U + 'we':U temp#sum-type.xi = 207 . create temp#sum-type.
assign temp#sum-type.sum-type = 'sadt':U + 'vt':U temp#sum-type.xi = 208 . create temp#sum-type.
assign temp#sum-type.sum-type = 'sadt':U + 'iv':U temp#sum-type.xi = 209 . create temp#sum-type.
assign temp#sum-type.sum-type = 'sadt':U + 'ev':U temp#sum-type.xi = 210. create temp#sum-type.
assign temp#sum-type.sum-type = 'sadt':U + 'rv':U temp#sum-type.xi = 211. create temp#sum-type.
assign temp#sum-type.sum-type = 'sadt':U + 'em':U temp#sum-type.xi = 212. create temp#sum-type.
assign temp#sum-type.sum-type = 'sadt':U + 'wm':U temp#sum-type.xi = 212. create temp#sum-type.
assign temp#sum-type.sum-type = 'sadt':U + 'im':U temp#sum-type.xi = 213. create temp#sum-type.
assign temp#sum-type.sum-type = 'sadt':U + 'ot':U temp#sum-type.xi = 214.
create temp#sum-type.
assign temp#sum-type.sum-type = 'sadt':U + 'ap':U temp#sum-type.xi = 215 . create temp#sum-type.
assign temp#sum-type.sum-type = 'sadt':U + 'pc':U temp#sum-type.xi = 216 .
end procedure.
procedure pp :
define input parameter ll as integer no-undo .
define input parameter uu as integer no-undo .
define input parameter ff as character no-undo .
if ll > g-ll then return.
if ll < 1 then return.
  for each   ub.gds-grp no-lock where ub.gds-grp.lvl-num = ll
      and    ub.gds-grp.upper-code = uu
      :
       id = id + 1 .
            create tmp-gds.
            assign
              tmp-gds.id        = id
              tmp-gds.name      = (if ll = 1 then "" else fill("_",ll)) + ub.gds-grp.node-name + chr(47)
              tmp-gds.f-name    = ff + ub.gds-grp.node-name + chr(47)
              tmp-gds.node-code = ub.gds-grp.node-code
              tmp-gds.lvl = ub.gds-grp.lvl-num
              .
            run pp in this-procedure (ll + 1 , ub.gds-grp.node-code , tmp-gds.f-name ).
  End.
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
procedure calc-s-itog :
define variable n-1 as integer no-undo .
    do n-1 = 1 to 10 :
    assign
      bi-oborot-ie        [n-1]  =bi-oborot-ie        [n-1]  + b1-oborot-ie        [n-1]
      bi-oborot-ee       [n-1]  =bi-oborot-ee       [n-1]  + b1-oborot-ee       [n-1]
      bi-oborot-ep     [n-1]  =bi-oborot-ep     [n-1]  + b1-oborot-ep     [n-1]
      bi-oborot-es    [n-1]  =bi-oborot-es    [n-1]  + b1-oborot-es    [n-1]
      bi-oborot-re    [n-1]  =bi-oborot-re    [n-1]  + b1-oborot-re    [n-1]
      bi-oborot-rs[n-1] = bi-oborot-rs[n-1]  + b1-oborot-rs[n-1]
      bi-oborot-we[n-1]  =bi-oborot-we[n-1]  + b1-oborot-we[n-1]
      bi-oborot-vt [n-1]  =bi-oborot-vt [n-1]  + b1-oborot-vt [n-1]
      bi-oborot-iv  [n-1]  =bi-oborot-iv  [n-1]  + b1-oborot-iv  [n-1]
      bi-oborot-ev  [n-1]  =bi-oborot-ev  [n-1]  + b1-oborot-ev  [n-1]
      bi-oborot-rv  [n-1]  =bi-oborot-rv  [n-1]  + b1-oborot-rv  [n-1]
      bi-oborot-em  [n-1]  =bi-oborot-em  [n-1]  + b1-oborot-em  [n-1]
      bi-oborot-wm  [n-1]  =bi-oborot-wm  [n-1]  + b1-oborot-wm  [n-1]
      bi-oborot-im  [n-1]  =bi-oborot-im  [n-1]  + b1-oborot-im  [n-1]
      bi-oborot-ot  [n-1]  =bi-oborot-ot  [n-1]  + b1-oborot-ot  [n-1]
      bi-oborot-pc  [n-1]  =bi-oborot-pc  [n-1]  + b1-oborot-pc [n-1]
      bi-oborot-ap  [n-1]  =bi-oborot-ap  [n-1]  + b1-oborot-ap [n-1]
      bi-oborot-disc                           [n-1]  =bi-oborot-disc                           [n-1]  + b1-oborot-disc                           [n-1]
      bi-oborot-sum-sale                       [n-1]  =bi-oborot-sum-sale                       [n-1]  + b1-oborot-sum-sale                       [n-1]
      bi-oborot-sum-cost                       [n-1]  =bi-oborot-sum-cost                       [n-1]  + b1-oborot-sum-cost                       [n-1]
      bi-ostatok-start                         [n-1]  =bi-ostatok-start                     [n-1]  + b1-ostatok-start                         [n-1]
      bi-ostatok-end                           [n-1]  =bi-ostatok-end                       [n-1]  + b1-ostatok-end                           [n-1]
      bo-oborot-ie        [n-1]  =bo-oborot-ie        [n-1]  + b1-oborot-ie        [n-1]
      bo-oborot-ee       [n-1]  =bo-oborot-ee       [n-1]  + b1-oborot-ee       [n-1]
      bo-oborot-ep     [n-1]  =bo-oborot-ep     [n-1]  + b1-oborot-ep     [n-1]
      bo-oborot-es    [n-1]  =bo-oborot-es    [n-1]  + b1-oborot-es    [n-1]
      bo-oborot-re    [n-1]  =bo-oborot-re    [n-1]  + b1-oborot-re    [n-1]
      bo-oborot-rs[n-1] = bo-oborot-rs[n-1]  + b1-oborot-rs[n-1]
      bo-oborot-we[n-1]  =bo-oborot-we[n-1]  + b1-oborot-we[n-1]
      bo-oborot-vt [n-1]  =bo-oborot-vt [n-1]  + b1-oborot-vt [n-1]
      bo-oborot-iv  [n-1]  =bo-oborot-iv  [n-1]  + b1-oborot-iv  [n-1]
      bo-oborot-ev  [n-1]  =bo-oborot-ev  [n-1]  + b1-oborot-ev  [n-1]
      bo-oborot-rv  [n-1]  =bo-oborot-rv  [n-1]  + b1-oborot-rv  [n-1]
      bo-oborot-em  [n-1]  =bo-oborot-em  [n-1]  + b1-oborot-em  [n-1]
      bo-oborot-wm  [n-1]  =bo-oborot-wm  [n-1]  + b1-oborot-wm  [n-1]
      bo-oborot-im  [n-1]  =bo-oborot-im  [n-1]  + b1-oborot-im  [n-1]
      bo-oborot-ot  [n-1]  =bo-oborot-ot  [n-1]  + b1-oborot-ot  [n-1]
      bo-oborot-pc  [n-1]  =bo-oborot-pc  [n-1]  + b1-oborot-pc [n-1]
      bo-oborot-ap  [n-1]  =bo-oborot-ap  [n-1]  + b1-oborot-ap [n-1]
      bo-oborot-disc                           [n-1]  =bo-oborot-disc                           [n-1]  + b1-oborot-disc                           [n-1]
      bo-oborot-sum-sale                       [n-1]  =bo-oborot-sum-sale                       [n-1]  + b1-oborot-sum-sale                       [n-1]
      bo-oborot-sum-cost                       [n-1]  =bo-oborot-sum-cost                       [n-1]  + b1-oborot-sum-cost                       [n-1]
      bo-ostatok-start                         [n-1]  =bo-ostatok-start                     [n-1]  + b1-ostatok-start                         [n-1]
      bo-ostatok-end                           [n-1]  =bo-ostatok-end                       [n-1]  + b1-ostatok-end                           [n-1]
    .
    end.
end procedure.
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
run price-vat-1 ( pp).
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
run PRICE-VAT-2 ( pp).
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
run PRICE-VAT-3 ( pp).
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
run PRICE-VAT-4 ( pp).
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
    DISPLAY stream  OutStream  with FRAME ZAPAS .  DOWN stream   OutStream 1 with FRAME ZAPAS.
END PROCEDURE.
