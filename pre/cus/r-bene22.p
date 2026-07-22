block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Движение товара по месту хранения".
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
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-cntxt-host-code-obj
  ,output base-code
  )  .
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define input parameter x-store-code like ub.clients.obj-code   no-undo.
define input parameter x-store-type like ub.clients.obj-type   no-undo.
define input parameter x-base-type  like ub.currency.curr-abbr no-undo.
define input parameter x-base-code  like ub.currency.curr-code no-undo.
define input parameter xClassify  as char no-undo.
define input parameter xSortType  as char no-undo.
define input parameter xSumsOnly  as log  no-undo.
define input parameter xShowZero  as log  no-undo.
define input parameter xTog-obj   as log no-undo.
define input parameter  xShowCost as log no-undo.
define input parameter  xShowSale as log no-undo.
define input parameter  xtog-lavel as log no-undo.
define input parameter  xvar-lavel as int no-undo. .
define input parameter fo0    like ub.ot-tot.fact-order no-undo.
define input parameter fo02   like ub.ot-tot.fact-order no-undo.
define input parameter fo1    like ub.ot-tot.fact-order no-undo.
define input parameter fo12   like ub.ot-tot.fact-order no-undo.
define input parameter fo2    like ub.ot-tot.fact-order no-undo.
define input parameter fo22   like ub.ot-tot.fact-order no-undo.
define input parameter fo3    like ub.ot-tot.fact-order no-undo.
define input parameter fo32   like ub.ot-tot.fact-order no-undo.
define input parameter fo4    like ub.ot-tot.fact-order no-undo.
define input parameter fo42   like ub.ot-tot.fact-order no-undo.
define input parameter fo5    like ub.ot-tot.fact-order no-undo.
define input parameter fo52   like ub.ot-tot.fact-order no-undo.
define input parameter Tog-Qnty  as log no-undo.
define input parameter xbsamount as int no-undo.
define input parameter x-host-code as integer no-undo .
define input parameter tog-voz as logical no-undo .
define input parameter ShowOrders  as log no-undo.
define input parameter  Number-Orders         as character no-undo .
define buffer goods   for ub.goods  .
define buffer gds-obj for ub.gds-obj  .
define buffer clients for ub.clients  .
define variable Number-Orders-empty   as character no-undo .
define variable QNTY-Orders as character no-undo .
define variable  tPrintRubl as log no-undo.
define  stream  OutStream.
define  stream  OutStream2.
define variable    ObjName           as   char no-undo.
define variable    Select-Good       as   integer no-undo.
define variable    ChosedType        as   integer no-undo.
define variable    PayType           as   integer no-undo.
define variable    RetClassify       as   char  no-undo.
define variable    RetSortType       as   char  no-undo.
define variable    Show-Negativ      as   logical  no-undo.
define variable    Sums-Only         as   logical  no-undo.
define variable    ValType           as   integer no-undo.
define variable    Line              as   char        no-undo.
define variable FirstLine         as   logical     no-undo.
define variable tot_tqnty as decimal  no-undo.
define variable break_group as logical no-undo init true.
define variable break_group1 as logical no-undo init true.
define variable stat      as log no-undo .
define variable InpError  as log no-undo .
define variable i         as integer init 0  no-undo .
define variable R         as integer init 0  no-undo .
define variable ii        as integer init 0  no-undo .
define variable rr        as integer init 0 no-undo .
define variable f-ii      as char no-undo .
define variable p         as integer no-undo init 0 .
define variable L         as integer no-undo init 0 .
define variable kk        as integer no-undo init 0 .
define variable c         as integer no-undo init 0 .
define variable rid-list  as character no-undo .
define variable gds-zap-unit-base     like ub.goods.unit-base     no-undo.
define variable gds-zap-prt-root      like ub.goods.prt-root     no-undo .
define variable gds-zap-gds-name      like ub.goods.gds-name     no-undo .
define variable gds-zap-prod-type     like ub.goods.prod-type    no-undo .
define variable gds-zap-prod-code     like ub.goods.prod-code    no-undo .
define variable gds-zap-artic         like ub.goods.artic        no-undo .
define variable gds-zap-b-code        like ub.bar-code.b-code    no-undo .
define variable gds-zap-type          like ub.goods.gds-type     no-undo .
define variable gds-type              as char no-undo.
define variable gds-zap-grp-name      like ub.goods.grp-name     no-undo .
define variable gds-zap-prod-name     like ub.clients.obj-name   no-undo .
define variable gds-zap-price-base    like ub.stk-line.sum-base no-undo.
define variable gds-zap-stoim-base    like ub.stk-line.sum-base no-undo.
define variable gds-zap-qnty          like ub.stk-line.fact-qnty no-undo.
define variable gds-zap-Nds           like ub.stk-line.VAT-base no-undo.
define variable gds-zap-Np            like ub.stk-line.SLT-base no-undo.
define variable F-ostatok-start    as   char  no-undo.
define variable F-ostatok-End      as   char  no-undo.
define variable ostatok-start      as   decimal EXTENT 6 Format "->>>>>>>>>9.999" no-undo.
define variable ostatok-End        as   decimal EXTENT 6 Format "->>>>>>>>>9.999" no-undo.
define variable B1-ostatok-start   as   decimal EXTENT 6 Format "->>>>>>>>>9.999" no-undo.
define variable B1-ostatok-End     as   decimal EXTENT 6 Format "->>>>>>>>>9.999" no-undo.
define variable B2-ostatok-start   as   decimal EXTENT 6 Format "->>>>>>>>>9.999" no-undo.
define variable B2-ostatok-End     as   decimal EXTENT 6 Format "->>>>>>>>>9.999" no-undo.
define variable Bi-ostatok-start   as   decimal EXTENT 6 Format "->>>>>>>>>9.999" no-undo.
define variable Bi-ostatok-End     as   decimal EXTENT 6 Format "->>>>>>>>>9.999" no-undo.
define variable prih             as   decimal EXTENT 6 Format "->>>>>>>>>>>>>>9.<<<" no-undo.
define variable rash             as   decimal EXTENT 6 Format "->>>>>>>>>>>>9.<<<"  no-undo.
define variable kassa            as   decimal EXTENT 6  Format "->>>>>>>>>>>>9.<<<" no-undo.
define variable Inv              as   decimal EXTENT 6  Format "->>>>>>>>>>>>9.<<<" no-undo.
define variable Overturn         as   decimal EXTENT 6  Format "->>>>>>>>>>>>9.<<<" no-undo.
define variable  ret-str          as   char    EXTENT 8   no-undo.
define variable B1-prih             as   decimal EXTENT 6 Format "->>>>>>>>>>>>9.<<<" no-undo.
define variable B1-rash             as   decimal EXTENT 6 Format "->>>>>>>>>>>>9.<<<" no-undo.
define variable B1-kassa            as   decimal EXTENT 6 Format "->>>>>>>>>>>>9.<<<" no-undo.
define variable B1-Overturn         as   decimal EXTENT 6 Format "->>>>>>>>>>>>9.<<<" no-undo.
define variable b1-ret-str          as   char EXTENT 8 Format "->>>>>>>>>>>>9.<<<" no-undo.
define variable b2-ret-str          as   char EXTENT 8 Format "->>>>>>>>>>>>9.<<<" no-undo.
define variable bi-ret-str          as   char EXTENT 8 Format "->>>>>>>>>>>>9.<<<" no-undo.
define variable f-zakaz             as   decimal Format "->>>>>>>>>>>>9.<<<"  no-undo.
define variable F-center-stock      as   decimal Format "->>>>>>>>>>>>9.<<<"  no-undo.
define variable f-avr               as   decimal Format "->>>>>>>>>>>>9.<<<"  no-undo.
define variable b1-f-zakaz            as   decimal Format "->>>>>>>>>>>>9.<<<"  no-undo.
define variable b1-F-Center-stock     as   decimal Format "->>>>>>>>>>>>9.<<<"  no-undo.
define variable b1-F-avr              as   decimal Format "->>>>>>>>>>>>9.<<<"  no-undo.
define variable B2-prih             as   decimal EXTENT 6 Format "->>>>>>>>>>>>9.<<<" no-undo.
define variable B2-rash             as   decimal EXTENT 6 Format "->>>>>>>>>>>>9.<<<" no-undo.
define variable B2-kassa            as   decimal EXTENT 6 Format "->>>>>>>>>>>>9.<<<" no-undo.
define variable B2-Inv              as   decimal EXTENT 6 Format "->>>>>>>>>>>>9.<<<" no-undo.
define variable B2-Overturn         as   decimal EXTENT 6 Format "->>>>>>>>>>>>9.<<<" no-undo.
define variable b2-f-zakaz            as   decimal Format "->>>>>>>>>>>>9.<<<"  no-undo.
define variable b2-F-Center-stock     as   decimal Format "->>>>>>>>>>>>9.<<<"  no-undo.
define variable b2-F-avr              as   decimal Format "->>>>>>>>>>>>9.<<<"  no-undo.
define variable Bi-prih             as   decimal EXTENT 6 Format "->>>>>>>>>>>>9.<<<" no-undo.
define variable Bi-rash             as   decimal EXTENT 6 Format "->>>>>>>>>>>>9.<<<" no-undo.
define variable Bi-kassa            as   decimal EXTENT 6 Format "->>>>>>>>>>>>9.<<<" no-undo.
define variable Bi-Inv              as   decimal EXTENT 6 Format "->>>>>>>>>>>>9.<<<" no-undo.
define variable Bi-Overturn         as   decimal EXTENT 6 Format "->>>>>>>>>>>>9.<<<" no-undo.
define variable bi-f-zakaz            as   decimal Format "->>>>>>>>>>>>9.<<<"  no-undo.
define variable bi-F-Center-stock     as   decimal Format "->>>>>>>>>>>>9.<<<"  no-undo.
define variable bi-F-avr              as   decimal Format "->>>>>>>>>>>>9.<<<"  no-undo.
define variable  Fact-order-1   like ub.stk-tot.Fact-order no-undo.
define variable  Quantity1      like ub.stk-tot.fact-qnty  no-undo.
define variable  Coast_R1       like ub.stk-tot.sum-rubl   no-undo.
define variable  Coast_V1       like ub.stk-tot.sum-rubl   no-undo.
define variable  VAT_R1         like ub.stk-tot.sum-rubl   no-undo.
define variable  VAT_V1         like ub.stk-tot.sum-rubl   no-undo.
define variable  Fact-order-2   like ub.stk-tot.Fact-order no-undo.
define variable  Quantity2      like ub.stk-tot.fact-qnty  no-undo.
define variable  Coast2         like ub.stk-tot.sum-rubl   no-undo.
define variable  Coast_R2       like ub.stk-tot.sum-rubl   no-undo.
define variable  Coast_V2       like ub.stk-tot.sum-rubl   no-undo.
define variable  VAT_R2         like ub.stk-tot.sum-rubl   no-undo.
define variable  VAT_V2         like ub.stk-tot.sum-rubl   no-undo.
define variable  Quantity    like ub.stk-tot.fact-qnty  no-undo.
define variable  Coast       like ub.stk-tot.sum-rubl   no-undo.
define variable  Coast_R     like ub.stk-tot.sum-rubl   no-undo.
define variable  Coast_V     like ub.stk-tot.sum-rubl   no-undo.
define variable  VAT_R       like ub.stk-tot.sum-rubl   no-undo.
define variable  VAT_V       like ub.stk-tot.sum-rubl   no-undo.
define variable  SLT_R       like ub.stk-tot.sum-rubl   no-undo.
define variable  SLT_V       like ub.stk-tot.sum-rubl   no-undo.
define variable  Coast3       like ub.stk-tot.sum-rubl   no-undo.
define variable  Coast4       like ub.stk-tot.sum-rubl   no-undo.
define variable  temp-str as char no-undo.
define variable str as char format "X(60)" no-undo.
define variable i#i as int no-undo.
define variable xLavel as int  no-undo.
define variable list-field as char no-undo.
define variable str10 as char no-undo.
define BUFFER stk-line2 FOR ub.stk-line  .
define variable s#ret-str as char no-undo.
define WORK-TABLE temp#sum-type no-undo
    FIELD sum-type as char
    FIELD xi as int.
define shared  TEMP-TABLE temp#obj-list no-undo
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    field grp-name like ub.clients.grp-name
    Index byGR grp-name ASCENDING.
define TEMP-TABLE TMP#bs no-undo
    FIELD   b-code         LIKE gds-zap-b-code
    FIELD   Artic          LIKE gds-zap-artic
    FIELD   Prod-code      LIKE gds-zap-prod-code
    FIELD   Prod-type      LIKE gds-zap-prod-type
    FIELD   Prt-root       LIKE gds-zap-prt-root
    FIELD   Grp-name       LIKE gds-zap-grp-name
    FIELD   F-zakaz        LIKE ub.stk-tot.fact-qnty
    FIELD   F-center-stock LIKE ub.stk-tot.fact-qnty
    FIELD   Prih           like ub.stk-tot.fact-qnty
    FIELD   Ostatok-end    like ub.stk-tot.fact-qnty
    FIELD   f-avr          LIKE ub.stk-tot.fact-qnty
    FIELD   Kassa1         like ub.stk-tot.fact-qnty
    FIELD   Kassa2         like ub.stk-tot.fact-qnty
    FIELD   Kassa3         like ub.stk-tot.fact-qnty
    FIELD   Kassa4         like ub.stk-tot.fact-qnty
    FIELD   Kassa5         like ub.stk-tot.fact-qnty
    FIELD   Kassa6         like ub.stk-tot.fact-qnty
    FIELD   Ret-str        as   char    EXTENT 8
    INDEX By-B-code    B-code   ASCENDING
    INDEX By-Artic     Artic    ASCENDING
    INDEX By-Grp-Name  Grp-name ASCENDING
    INDEX Byf-Avr      F-avr    DESCENDING .
define variable     v#b-code         LIKE gds-zap-b-code no-undo.
define variable     v#artic          LIKE gds-zap-artic  no-undo.
define variable     v#prod-code      LIKE gds-zap-prod-code  no-undo.
define variable     v#prod-type      LIKE gds-zap-prod-type  no-undo.
define variable     v#prt-root       LIKE gds-zap-prt-root   no-undo.
define variable     v#grp-name       LIKE gds-zap-grp-name   no-undo.
define variable     v#F-zakaz        LIKE ub.stk-tot.fact-qnty           no-undo.
define variable     v#F-center-stock LIKE ub.stk-tot.fact-qnty     no-undo.
define variable     v#Prih           like ub.stk-tot.fact-qnty  no-undo.
define variable     v#ostatok-end    like ub.stk-tot.fact-qnty  no-undo.
define variable     v#f-avr          LIKE ub.stk-tot.fact-qnty              no-undo.
define variable     v#kASSA1         like ub.stk-tot.fact-qnty  no-undo.
define variable     v#KAssa2         like ub.stk-tot.fact-qnty  no-undo.
define variable     v#KAssa3         like ub.stk-tot.fact-qnty  no-undo.
define variable     v#KAssa4         like ub.stk-tot.fact-qnty  no-undo.
define variable     v#KAssa5         like ub.stk-tot.fact-qnty  no-undo.
define variable     v#KAssa6         like ub.stk-tot.fact-qnty  no-undo.
define variable     V#ret-str        as   char    EXTENT 8    no-undo.
FUNCTION format-return  RETURNS decimal (INPUT orig as char ) .
define variable rtext AS CHARACTER no-undo .
define variable strt AS INTEGER no-undo .
define variable leng AS INTEGER no-undo .
Assign rtext = orig .
  leng = 1.
  strt =  index(rtext,'=').
  if strt = 0 then Return decimal(rtext).
  SUBSTRING(rtext,strt,leng,"CHARACTER") = "" .
   strt =  index(rtext,'"').
  if strt > 0 then
  SUBSTRING(rtext,strt,leng,"CHARACTER") = "" .
  strt =  index(rtext, v-delim).
  if strt > 0 then
     SUBSTRING(rtext,strt,leng,"CHARACTER") = "." .
  strt =  index(rtext,'"').
  if strt > 0 then
  SUBSTRING(rtext,strt,leng,"CHARACTER") = "" .
Return decimal(rtext).
END FUNCTION.
     assign
        i=0
        xlavel = xvar-lavel
        Select-Good   = x-SelectGood
        PayType       = x-SET_PAY_TYPE
        RetClassify   = xClassify
        RetSortType   = xSortType
        Sums-Only     = xSumsOnly
        Show-Negativ  = xShowZero
        FirstLine     = FALSE.
        Line          = fill("-", 232).
        ValType       = IF (PayType = 1) Then 0  else x-SET_val_TYPE.
    For each Temp#obj-list break by Temp#obj-list.grp-name:
        if last-of (Temp#obj-list.grp-name) THEN DO:
        s#ret-str = s#ret-str + CHR(9).
        END.
    End.
        For each obj-list share-lock :
           if NOT can-find (first Temp#obj-list where  Temp#obj-list.obj-code = obj-list.obj-code And
                                                       Temp#obj-list.obj-type = obj-list.obj-type)
             THEN DELETE obj-list no-error.
        End.
        run report-execute.
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
PROCEDURE report-execute :
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
case x-set_pay_type :
  when 1 then do:
        tprintrubl = ( var-report-r-b = 'rubl':U ) .
  end.
  when 2 or when 3 then do:
        if x-set_val_type = 1  then tprintrubl = yes .
        if x-set_val_type = 2  then tprintrubl = no  .
  end.
end case.
  run waitfram-show( 'Подождите ...' ) .
   output stream OutStream to value( string( session:temp-directory +
                            "rpt" + string( g#report-num ) ) )      .
   run maket.
   run report-exec1.
  output stream outstream close.
  run waitfram-hide .
  if Make-Excel then output stream ForExcel close.
  run rep/runexcel.p (string( session:temp-directory) + "rpt" + string( g#report-num ) + ".txt").
END PROCEDURE.
PROCEDURE foreach :
 R = R + 1.
If Integer(10) = 0 Then Temp1  = 100  .
                      Else Temp1 = Integer(10) .
     IF ( R modulo Temp1 = 0 ) AND ( R >= Temp1 ) then
         RUN waitfram-show( "Обработано строк : " + string( R )) .
  run clear-item.
  run zakaz.
  if not show-negativ  and  f-zakaz  = 0 then return.
   run ob-line ( input   x-store-code,input   x-store-type,input   gds-zap-artic,input   gds-zap-prod-code ,
      INPUT   gds-zap-prod-type,
      INPUT   Fact-order-2,
      INPUT   Fact-order-2,
      input   'crsa':U ,input   '##,##':U, input   "", input   xTog-obj ,
      input   3 ,
      output  ostatok-end[1] ,
      output  ret-str[8] ) .
   run ob-line-1 ( input   x-store-code   ,  input   x-store-type   ,  input   gds-zap-artic       ,  input   gds-zap-prod-code   ,
      INPUT   gds-zap-prod-type   ,
      INPUT   Fact-order-1,
      INPUT   Fact-order-2,
      input   'crsa':U    ,  input   '##,##':U, input   "", input   xTog-obj ,
      input   1 ,
      output prih[1] ,
      output ret-str[1]).
F-center-stock =  f-zakaz - prih[1].
   RUN ob-line-1 ( input   x-store-code   , input   x-store-type   , INPUT   gds-zap-artic       ,  INPUT   gds-zap-prod-code   ,      INPUT   gds-zap-prod-type   ,
      INPUT   Fo0,
      INPUT   Fo02,
      input   'crsa':U    ,   input   '##,##':U,   input   ""      ,   input   xTog-obj ,
      input   2 ,
      output kassa[1] ,
      output ret-str[2]  ).
 if Showorders = false THEN DO:
   run ob-line-1 ( input   x-store-code   , input   x-store-type   , input   gds-zap-artic       ,  input   gds-zap-prod-code   ,      input   gds-zap-prod-type   ,
      input   fo1,
      input   fo12,
      input   'crsa':U    ,   input   '##,##':U,   input   ""      ,   input   xtog-obj ,
      input   2 ,
      output kassa[2] ,
      output ret-str[3]  ).
   run ob-line-1 ( input   x-store-code   , input   x-store-type   , input   gds-zap-artic       ,  input   gds-zap-prod-code   ,      input   gds-zap-prod-type   ,
      input   fo2,
      input   fo22,
      input   'crsa':U    ,   input   '##,##':U,   input   ""      ,   input   xtog-obj ,
      input   2 ,
      output kassa[3] ,
      output ret-str[4]  ).
   run ob-line-1 ( input   x-store-code   , input   x-store-type   , input   gds-zap-artic       ,  input   gds-zap-prod-code   ,      input   gds-zap-prod-type   ,
      input   fo3,
      input   fo32,
      input   'crsa':U    ,   input   '##,##':U,   input   ""      ,   input   xtog-obj ,
      input   2 ,
      output kassa[4] ,
      output ret-str[5]  ).
   run ob-line-1 ( input   x-store-code   , input   x-store-type   , input   gds-zap-artic       ,  input   gds-zap-prod-code   ,      input   gds-zap-prod-type   ,
      input   fo4,
      input   fo42,
      input   'crsa':U    ,   input   '##,##':U,   input   ""      ,   input   xtog-obj ,
      input   2 ,
      output kassa[5] ,
      output ret-str[6]  ).
   run ob-line-1 ( input   x-store-code   , input   x-store-type   , input   gds-zap-artic       ,  input   gds-zap-prod-code   ,      input   gds-zap-prod-type   ,
      input   fo5,
      input   fo52,
      input   'crsa':U    ,   input   '##,##':U,   input   ""      ,   input   xtog-obj ,
      input   2 ,
      output kassa[6] ,
      output ret-str[7]  ).
End.
   f-avr =  round(kassa[1] / If integer(Fo02 - Fo0) = 0 then 1 else integer(Fo02 - Fo0) , 3) .
     IF   f-zakaz  = 0 AND
          Prih[1] = 0 and
          kassa[1] = 0 and
          kassa[2] = 0 and
          kassa[3] = 0 and
          kassa[4] = 0 and
          kassa[5] = 0 and
          kassa[6] = 0 and
          ostatok-end[1] = 0
          THEN RETURN.
      rr = rr + 1 .
      run maketemptable  .
END PROCEDURE.
PROCEDURE print-header :
if NOT FirstLine Then
    FirstLine = TRUE .
    if xTog-obj and   x-SelectObject <> "currency":U   Then  DO:
          if Make-Excel then  put   stream ForExcel unformatted "ПО ОБЪЕКТУ : " + CAPS(ObjName)  SKIP.
          End.
      run clear-b1 .
      run clear-b2.
      run clear-bi .
      break_group = true.
      break_group1 = true.
   END PROCEDURE.
PROCEDURE Print-Footer :
       run di ("bi", 1, "","ИТОГО","","","bi").
       END PROCEDURE.
PROCEDURE U-LINE :
        END PROCEDURE.
PROCEDURE P-LINE :
        END PROCEDURE.
procedure run2 :
     if not xtog-lavel then do:   run run2sort1.    end.
       else do:   run lavel1.      end.
   end procedure.
procedure run2sort1 :
              case select-good :
                  when 1  then do:
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    BY (temp-gds-list.artic) :
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
    BY temp-gds-list.artic :
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
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                  by temp-gds-list.artic :
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
    by temp-gds-list.artic :
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
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
        by temp-gds-list.artic :
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
            by temp-gds-list.artic :
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
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    BY (gds-list.artic) :
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
    BY gds-list.artic :
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
    define buffer buf_obj-list20 for obj-list.
  for each buf_obj-list20 no-lock :
      if xtog-obj and  not (buf_obj-list20.obj-type = x-store-type  and
                            buf_obj-list20.obj-code = x-store-code )
      then next.
        for  each gds-obj   where
                            gds-obj.obj-type = buf_obj-list20.obj-type    and
                            gds-obj.obj-code = buf_obj-list20.obj-code
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
        by temp-gds-list.artic :
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
    define buffer buf_obj-list21 for obj-list.
  for each buf_obj-list21 no-lock :
      if xtog-obj and  not (buf_obj-list21.obj-type = x-store-type  and
                            buf_obj-list21.obj-code = x-store-code )
      then next.
        for  each gds-obj   where
                            gds-obj.obj-type = buf_obj-list21.obj-type    and
                            gds-obj.obj-code = buf_obj-list21.obj-code
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
        by temp-gds-list.artic :
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
    define buffer buf_obj-list22 for obj-list.
  for each buf_obj-list22 no-lock :
      if xtog-obj and  not (buf_obj-list22.obj-type = x-store-type  and
                            buf_obj-list22.obj-code = x-store-code )
      then next.
        for  each gds-obj   where
                  gds-obj.obj-type = buf_obj-list22.obj-type    and
                  gds-obj.obj-code = buf_obj-list22.obj-code
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
        by temp-gds-list.artic :
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
    define buffer buf_obj-list23 for obj-list.
  for each buf_obj-list23 no-lock :
      if xtog-obj and  not (buf_obj-list23.obj-type = x-store-type  and
                            buf_obj-list23.obj-code = x-store-code )
      then next.
        for  each gds-obj   where
                            gds-obj.obj-type = buf_obj-list23.obj-type    and
                            gds-obj.obj-code = buf_obj-list23.obj-code
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
        by gds-list.artic :
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
PROCEDURE CalcItog :
    run ostatok (
        input x-store-code  ,
        input x-store-type  ,x-TOG-Shift,
        input x-date-start - 1 ,
        input date('')      , x-Shift-Start,x-Shift-End,
        input 'crsa':U   ,
        input '##,##':U,
        input xTog-obj ,
        output  Quantity1  ,
        output  Coast_R1   ,
        output  Coast_V1   ,
        output  VAT_R1     ,
        output  VAT_V1     ,
        output  Fact-order-1 ).
    run ostatok (
        input x-store-code  ,
        input x-store-type  , x-TOG-Shift,
        input x-date-start  ,
        input x-date-end    ,  x-Shift-Start,x-Shift-End,
        input 'crsa':U   ,
        input '##,##':U,
        input xTog-obj ,
        output  Quantity1  ,
        output  Coast_R1   ,
        output  Coast_V1   ,
        output  VAT_R1     ,
        output  VAT_V1     ,
        output  Fact-order-2 ).
          Quantity1  = 0.
          Coast_R1   = 0.
          Coast_V1   = 0.
          VAT_R1     = 0.
          VAT_V1     = 0.
END PROCEDURE.
PROCEDURE display-str1  :
END PROCEDURE.
PROCEDURE display-Bi  :
END PROCEDURE.
PROCEDURE display-B1  :
END PROCEDURE.
PROCEDURE display-B2  :
END PROCEDURE.
PROCEDURE Clear-B1  :
 REPEAT kk = 1 to 6 :
 Assign
    b1-Prih           [kk]= 0
    b1-Rash           [kk]= 0
    b1-KAssa          [kk]= 0
    b1-Overturn       [kk]= 0
    b1-ostatok-end    [kk]= 0
    b1-ostatok-start  [kk]= 0
    b1-f-zakaz        = 0
    b1-F-Center-stock = 0
    b1-F-avr          = 0  .
   End.
   REPEAT kk = 1 to 8 :
     b1-ret-str[kk] = s#ret-str.
   End.
 END PROCEDURE.
PROCEDURE Clear-B2  :
 REPEAT kk = 1 to 6 :
 Assign
    b2-Prih                                            [kk]    = 0
    b2-Rash                                            [kk]    = 0
    b2-KAssa                                           [kk]    = 0
    b2-Inv                                             [kk]    = 0
    b2-Overturn                                        [kk]    = 0
    b2-ostatok-end                                     [kk]    = 0
    b2-ostatok-start                                   [kk]    = 0
    b2-f-zakaz        = 0
    b2-F-Center-stock = 0
    b2-F-avr          = 0  .
   End.
   REPEAT kk = 1 to 8 :
   B1-ret-str[kk] = s#ret-str.
   End.
END PROCEDURE.
PROCEDURE Clear-Bi  :
 REPEAT kk = 1 to 6 :
 Assign
    bi-Prih                                            [kk]    = 0
    bi-Rash                                            [kk]    = 0
    bi-KAssa                                           [kk]    = 0
    bi-ostatok-end                                     [kk]    = 0
    bi-ostatok-start                                   [kk]    = 0
    bi-f-zakaz                                                = 0
    bi-F-Center-stock                                         = 0
    bi-F-avr                                                  = 0  .
   End.
   REPEAT kk = 1 to 8 :
   B1-ret-str[kk] = s#ret-str.
   End.
END PROCEDURE.
PROCEDURE Display-title :
    run rep/extitle.p (1) .
END PROCEDURE.
PROCEDURE ob-line  :
define input  parameter x-store-code     like ub.clients.obj-code      no-undo.
define input  parameter x-store-type     like ub.clients.obj-type      no-undo.
define INPUT  parameter x-artic          like ub.stk-line.artic        no-undo.
define INPUT  parameter x-prod-code      like ub.stk-line.prod-code    no-undo.
define INPUT  parameter x-prod-type      like ub.stk-line.prod-type    no-undo.
define INPUT  parameter x-Fact-order-1   like ub.stk-line.Fact-order   no-undo.
define INPUT  parameter x-Fact-order-2   like ub.stk-line.Fact-order   no-undo.
define input  parameter x-sum-type       like ub.stk-line.sum-type     no-undo.
define input  parameter x-cat-id         like ub.stk-line.cat-id       no-undo.
define input  parameter x-ext-doc-type   like ub.ot-line.ext-doc-type no-undo.
define input  parameter xTog-obj         as log no-undo.
define input  parameter xi               as int no-undo.
define output  parameter Quntity         like ub.stk-line.fact-qnty   no-undo.
define output  parameter ret-str         as char  no-undo.
define variable  First-sum   like ub.stk-line.fact-qnty   no-undo.
define variable  Second-sum  like ub.stk-line.fact-qnty   no-undo.
define variable  Temp-First-sum  like ub.stk-line.fact-qnty   no-undo.
define variable  Temp-Second-sum  like ub.stk-line.fact-qnty   no-undo.
  Assign First-sum = 0 Second-sum = 0 Temp-First-sum = 0 Temp-Second-sum = 0 ret-str = "".
  For EAch Temp#obj-list  no-lock BREAK by Temp#obj-list.grp-name :
      FIND LAST ub.stk-line where
                              ub.stk-line.artic         = x-artic
                        AND   ub.stk-line.fact-order   <= x-fact-order-2
                        AND   ub.stk-line.obj-code     = Temp#obj-list.obj-code
                        AND   ub.stk-line.obj-type     = Temp#obj-list.obj-type
                        AND   ub.stk-line.prod-code    = x-prod-code
                        AND   ub.stk-line.prod-type    = x-prod-type
                        AND   ub.stk-line.sum-type     = 'crsa':U
                        AND   ub.stk-line.cat-id       = '##,##':U
                        USE-index category no-lock  no-error.
              if available ub.stk-LINE THEN Second-sum = Second-sum + ub.stk-line.fact-qnty.
              if available ub.stk-LINE THEN Temp-Second-sum = Temp-Second-sum + ub.stk-line.fact-qnty.
    if LAST-of (Temp#obj-list.grp-name) Then
      Assign ret-str = ret-str + excel-sum ( Temp-Second-sum )
             ret-str = ret-str + CHR(9)
             Temp-First-sum  = 0
             Temp-Second-sum = 0.
   End.
   Quntity = Second-sum .
END PROCEDURE.
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
PROCEDURE report-exec1  :
   FIND FIRST ub.clients where x-store-type = ub.clients.obj-type AND
                               x-store-code = ub.clients.obj-code no-lock no-error.
           If available ub.clients then  ObjName = ub.clients.obj-name.
                                         else  ObjName="объект не определен".
  run waitfram-show in this-procedure (objname) .
  run calcitog in this-procedure .
  run print-header in this-procedure .
  run run2 in this-procedure .
  run printtemptable in this-procedure .
  run print-footer in this-procedure .
  END PROCEDURE.
PROCEDURE Calc-Sub-itog :
define input parameter tt as int no-undo.
define variable b as int no-undo.
define variable c as int no-undo.
define variable temp-sum1 as decimal no-undo .
define variable temp-sum2 as decimal no-undo .
define variable temp-sumi as decimal no-undo .
define variable temp-sum1# as decimal no-undo .
define variable temp-sum2# as decimal no-undo .
define variable temp-sumi# as decimal no-undo .
define variable ret-str-1 as character no-undo .
define variable ret-str-2 as character no-undo .
define variable ret-str-i as character no-undo .
define variable v-nn as integer   no-undo .
  b1-ostatok-end [1] =  b1-ostatok-end [1] + TMP#bs.ostatok-end.
  b2-ostatok-end [1] =  b2-ostatok-end [1] + TMP#bs.ostatok-end.
  bi-ostatok-end [1] =  bi-ostatok-end [1] + TMP#bs.ostatok-end.
  B1-Prih[1]    = B1-Prih[1]    + TMP#bs.Prih.
  B2-Prih[1]    = B2-Prih[1]    + TMP#bs.Prih .
  Bi-Prih[1]    = Bi-Prih[1]    + TMP#bs.Prih  .
  B1-f-zakaz    = B1-f-zakaz   + TMP#bs.f-zakaz.
  B2-f-zakaz    = B2-f-zakaz   + TMP#bs.f-zakaz.
  Bi-f-zakaz    = Bi-f-zakaz   + TMP#bs.f-zakaz.
  B1-F-Center-stock = B1-F-Center-stock  +  TMP#bs.F-Center-stock.
  B2-F-Center-stock = B2-F-Center-stock  +  TMP#bs.F-Center-stock.
  Bi-F-Center-stock = Bi-F-Center-stock  +  TMP#bs.F-Center-stock.
  B1-KAssa[1]    = B1-KAssa[1]   +  TMP#bs.KAssa1 .  B2-kassa[1]    = B2-kassa[1]   +  TMP#bs.kassa1 .  Bi-Kassa[1]    = Bi-Kassa[1]   +  TMP#bs.Kassa1 .
  B1-KAssa[2]    = B1-KAssa[2]   +  TMP#bs.KAssa2 .  B2-kassa[2]    = B2-kassa[2]   +  TMP#bs.kassa2 .  Bi-Kassa[2]    = Bi-Kassa[2]   +  TMP#bs.Kassa2 .
  B1-KAssa[3]    = B1-KAssa[3]   +  TMP#bs.KAssa3 .  B2-kassa[3]    = B2-kassa[3]   +  TMP#bs.kassa3 .  Bi-Kassa[3]    = Bi-Kassa[3]   +  TMP#bs.Kassa3 .
  B1-KAssa[4]    = B1-KAssa[4]   +  TMP#bs.KAssa4 .  B2-kassa[4]    = B2-kassa[4]   +  TMP#bs.kassa4 .  Bi-Kassa[4]    = Bi-Kassa[4]   +  TMP#bs.Kassa4 .
  B1-KAssa[5]    = B1-KAssa[5]   +  TMP#bs.KAssa5 .  B2-kassa[5]    = B2-kassa[5]   +  TMP#bs.kassa5 .  Bi-Kassa[5]    = Bi-Kassa[5]   +  TMP#bs.Kassa5 .
  B1-KAssa[6]    = B1-KAssa[6]   +  TMP#bs.KAssa6 .  B2-kassa[6]    = B2-kassa[6]   +  TMP#bs.kassa6 .  Bi-Kassa[6]    = Bi-Kassa[6]   +  TMP#bs.Kassa6 .
  B1-F-avr =  round(b1-kassa[1] / If integer(Fo02 - Fo0) = 0 then 1 else integer(Fo02 - Fo0) , 3) .
  B2-F-avr =  round(b2-kassa[1] / If integer(Fo02 - Fo0) = 0 then 1 else integer(Fo02 - Fo0) , 3) .
  Bi-F-avr =  round(bi-kassa[1] / If integer(Fo02 - Fo0) = 0 then 1 else integer(Fo02 - Fo0) , 3) .
  repeat   c = 1 to 8 :
      Assign
      Temp-sum1  = 0 ret-str-1 = ""
      Temp-sum2  = 0 ret-str-2 = ""
      Temp-sumi  = 0 ret-str-i = "" .
      v-nn = num-entries(tmp#bs.ret-str [c] , CHR(9)) - 1 .
      repeat  b = 1 to v-nn :
          Temp-sum1# = format-return(entry(b,B1-Ret-str [c],CHR(9))) no-error . if ERROR-STATUS :error then Temp-sum1# = 0.
          Temp-sum2# = format-return(entry(b,B2-Ret-str [c],CHR(9))) no-error . if ERROR-STATUS :error then Temp-sum2# = 0.
          Temp-sumi# = format-return(entry(b,Bi-Ret-str [c],CHR(9))) no-error . if ERROR-STATUS :error then Temp-sumi# = 0.
          Temp-sum1 = Temp-sum1# + format-return(entry(b,TMP#bs.Ret-str [c],CHR(9))) no-error.
          Temp-sum2 = Temp-sum2# + format-return(entry(b,TMP#bs.Ret-str [c],CHR(9))) no-error.
          Temp-sumi = Temp-sumi# + format-return(entry(b,TMP#bs.Ret-str [c],CHR(9))) no-error.
          Assign
                 ret-str-1 = ret-str-1 + excel-sum((decimal(Temp-sum1) ))
                 ret-str-1 = ret-str-1 + CHR(9)
                 ret-str-2 = ret-str-2 + excel-sum((decimal(Temp-sum2) ))
                 ret-str-2 = ret-str-2 + CHR(9)
                 ret-str-i = ret-str-i + excel-sum((decimal(Temp-sumi) ))
                 ret-str-i = ret-str-i + CHR(9).
      End.
      b1-ret-str[c] =  ret-str-1.
      b2-ret-str[c] =  ret-str-2.
      bi-ret-str[c] =  ret-str-i.
  End.
END PROCEDURE.
PROCEDURE Clear-item :
define variable kk as int no-undo.
 REPEAT kk = 1 to 6:
 Assign
    prih                 [kk]    = 0
    rash                 [kk]    = 0
    kassa                [kk]    = 0
    Inv                  [kk]    = 0
    Overturn             [kk]    = 0
    ostatok-end      [kk] =   0
    ostatok-start    [kk] =   0   .
       End.
   REPEAT kk = 1 to 8 :
   B1-ret-str[kk] = s#ret-str.
   B2-ret-str[kk] = s#ret-str.
   Bi-ret-str[kk] = s#ret-str.
   End.
 END PROCEDURE.
PROCEDURE Item-Goods :
 define input parameter  par-3 as char no-undo.
 define input parameter  par-4 as char no-undo.
      if par-4 = "goods":U  Then
                                assign
                                    gds-zap-prt-root   = ub.goods.prt-root
                                    gds-zap-prod-type  = ub.goods.prod-type
                                    gds-zap-prod-code  = ub.goods.prod-code
                                    gds-zap-artic      = ub.goods.artic
                                    gds-zap-grp-name   = ub.goods.grp-name
                                    gds-zap-b-code     = ub.goods.gds-code.
     if par-4 = "gds-list":U  Then
                                assign
                                    gds-zap-prt-root   = gds-list.prt-root
                                    gds-zap-prod-type  = gds-list.prod-type
                                    gds-zap-prod-code  = gds-list.prod-code
                                    gds-zap-artic      = gds-list.artic
                                    gds-zap-grp-name   = gds-list.grp-name
                                    gds-zap-b-code     = gds-list.gds-code.
          FIND FIRST ub.clients WHERE ub.clients.obj-type = gds-zap-prod-type AND
                                   ub.clients.obj-code = gds-zap-prod-code use-index pi NO-LOCK .
                                   gds-zap-prod-name  = ub.clients.obj-name .
   if xtog-lavel = true  and  xLavel > 0 then
      gds-zap-grp-name = n-lavel(INPUT gds-zap-grp-name, Input xLavel ) .
   run foreach in this-procedure .
   Return error.
 END PROCEDURE.
PROCEDURE Di :
define input parameter p1 as char no-undo.
define input parameter p2 as int no-undo.
define input parameter p3 as char no-undo.
define input parameter p4 as char no-undo.
define input parameter p5 as char no-undo.
define input parameter p6 as char no-undo.
define input parameter p7 as char no-undo.
 CASE CAPS(p7) :
   WHEN "B1":U  Then
            run display-str-ex ( '' ,
                p3                  ,
                p4                  ,
                b1-F-zakaz          ,
                b1-F-center-stock   ,
                b1-Prih       [1]   ,
                b1-ostatok-end[1]   ,
                b1-F-avr            ,
                b1-KAssa      [1]   ,
                b1-KAssa      [2]   ,
                b1-KAssa      [3]   ,
                b1-KAssa      [4]   ,
                b1-KAssa      [5]   ,
                b1-KAssa      [6]  , "B1":U ).
   WHEN "B2":U  Then
             run display-str-ex ( '',
                p3                  ,
                p4                  ,
                b2-F-zakaz          ,
                b2-F-center-stock   ,
                b2-Prih [1]         ,
                b2-ostatok-end[1]   ,
                b2-F-avr            ,
                b2-KAssa      [1]   ,
                b2-KAssa      [2]   ,
                b2-KAssa      [3]   ,
                b2-KAssa      [4]   ,
                b2-KAssa      [5]   ,
                b2-KAssa      [6]  , "B2":U ).
   WHEN "BI":U Then
             run display-str-ex ( '',
                ''                   ,
                p4                   ,
                bi-F-zakaz           ,
                bi-F-center-stock    ,
                bi-Prih          [1] ,
                bi-ostatok-end   [1] ,
                bi-f-avr             ,
                bi-kAssa       [1]   ,
                bi-KAssa         [2] ,
                bi-KAssa         [3] ,
                bi-KAssa         [4] ,
                bi-KAssa         [5] ,
                bi-KAssa         [6] , "BI":U).
   WHEN ""  Then
             run display-str-ex ( ':',
                ii                    ,
                p4                    ,
                F-zakaz               ,
                F-center-stock        ,
                Prih          [1]     ,
                ostatok-end   [1]     ,
                f-avr                 ,
                kASSA         [1]     ,
                KAssa         [2]     ,
                KAssa         [3]     ,
                KAssa         [4]     ,
                KAssa         [5]     ,
                KAssa         [6]    , "":U ).
       End case.
 END PROCEDURE.
procedure zakaz :
   F-zakaz = 0.
   For each Temp#obj-list :
   For each ub.trn-doc where
          ub.trn-doc.doc-date <= x-date-end
    AND   ub.trn-doc.doc-date >= x-date-start
    AND   ub.trn-doc.status_   = 'запрос':U
    AND   ub.trn-doc.internal  = false
    AND   ub.trn-doc.obj-code   = Temp#obj-list.obj-code
    AND   ub.trn-doc.obj-type   = Temp#obj-list.obj-type
     no-lock :
      For each ub.doc-line where
              ub.trn-doc.doc-code =  ub.doc-line.doc-code
        AND   ub.doc-line.obj-code   = Temp#obj-list.obj-code
        AND   ub.doc-line.obj-type   = Temp#obj-list.obj-type
        AND   ub.doc-line.prod-code  = gds-zap-prod-code
        AND   ub.doc-line.prod-type  = gds-zap-prod-type
        AND   ub.doc-line.status_    = 'запрос':U
        AND   ub.doc-line.artic      = gds-zap-artic    no-lock :
              F-zakaz = F-zakaz  +  ub.doc-line.doc-qnty   .
      End.
   End.
End.
End procedure.
Procedure maket :
  Create temp#sum-type no-error.
  Assign temp#sum-type.sum-type =   'ie':U       temp#sum-type.xi = 1      .
  Create temp#sum-type no-error.
  Assign temp#sum-type.sum-type =   'iv':U       temp#sum-type.xi = 1      .
  Create temp#sum-type no-error.
  Assign temp#sum-type.sum-type =  'ev':U       temp#sum-type.xi = 1      .
  Create temp#sum-type no-error.
  Assign temp#sum-type.sum-type =  'es':U       temp#sum-type.xi = 2  .
  Create temp#sum-type no-error.
  Assign temp#sum-type.sum-type =  'rs':U   temp#sum-type.xi = 2  .
  if tog-voz then DO:
    Create temp#sum-type no-error.
    Assign temp#sum-type.sum-type =  're':U        temp#sum-type.xi = 2  .
  End.
  Create temp#sum-type no-error.
  Assign temp#sum-type.sum-type = 'crsa':U  temp#sum-type.xi = 3  .
 End procedure.
Procedure Display-str-ex :
 define input parameter  p0  as char no-undo.
 define input parameter  p1  as char no-undo.
 define input parameter  p2  as char no-undo.
 define input parameter  p3  as decimal   no-undo.
 define input parameter  p4  as decimal Format "->>>>>>>>>>>>9.<<<"  no-undo.
 define input parameter  p5  as decimal Format "->>>>>>>>>>>>9.<<<"  no-undo.
 define input parameter  p6  as decimal Format "->>>>>>>>>>>>9.<<<"  no-undo.
 define input parameter  p7  as decimal Format "->>>>>>>>>>>>9.<<<"  no-undo.
 define input parameter  p8  as decimal Format "->>>>>>>>>>>>9.<<<"  no-undo.
 define input parameter  p9  as decimal Format "->>>>>>>>>>>>9.<<<"  no-undo.
 define input parameter  p10 as decimal Format "->>>>>>>>>>>>9.<<<"  no-undo.
 define input parameter  p11 as decimal Format "->>>>>>>>>>>>9.<<<"  no-undo.
 define input parameter  p12 as decimal Format "->>>>>>>>>>>>9.<<<"  no-undo.
 define input parameter  p13 as decimal Format "->>>>>>>>>>>>9.<<<"  no-undo.
 define input parameter  B as char no-undo.
define variable v-nn as integer   no-undo .
 if p0 <> ':' THEN DO:
               if Make-Excel then  put   stream ForExcel unformatted
                p1   CHR(9)
                p2   CHR(9)
                excel-sum(p3)   CHR(9)
                excel-sum(p4)   CHR(9)
                excel-sum(p5)   CHR(9)
                 if b <> "BI":U THEN string(b1-ret-str[1])
                                ELSE string(bi-ret-str[1])
                excel-sum(p6)   CHR(9)
                 if b <> "BI":U THEN string(b1-ret-str[8])
                                ELSE string(bi-ret-str[8])
                excel-sum(p7)   CHR(9)
                excel-sum(p8)   CHR(9)
                 if b <> "BI":U THEN string(b1-ret-str[2])
                                ELSE string(bi-ret-str[2])
                                .
                if Showorders = false THEN DO:
                if Make-Excel then  put   stream ForExcel unformatted
                 excel-sum(p9)   CHR(9)
                 if b <> "BI":U THEN string(b1-ret-str[3])
                                ELSE string(bi-ret-str[3])
                 excel-sum(p10)  CHR(9)
                 if b <> "BI":U THEN string(b1-ret-str[4])
                                ELSE string(bi-ret-str[4])
                excel-sum(p11)  CHR(9)
                 if b <> "BI":U THEN string(b1-ret-str[5])
                                ELSE string(bi-ret-str[5])
                excel-sum(p12)  CHR(9)
                 if b <> "BI":U THEN string(b1-ret-str[6])
                                ELSE string(bi-ret-str[6])
                excel-sum(p13)  CHR(9)
                 if b <> "BI":U THEN string(b1-ret-str[7])
                                ELSE string(bi-ret-str[7]) Skip.
                               End.
                  if Make-Excel then  put   stream ForExcel unformatted Skip.
                 End.
               Else DO:
 define variable i as integer no-undo .
 qnty-orders = "".
if showorders = true then DO:
    v-nn = num-entries(Number-Orders) .
    repeat i = 1 to  v-nn :
    If entry(i,Number-Orders) <> ?
       and entry(i,Number-Orders) <> "."
       and entry(i,Number-Orders) <> ""
       and entry(i,Number-Orders) <> "0" Then DO:
      Find first ub.doc-line where
            entry(i,Number-Orders)    = ub.doc-line.doc-code
            AND   ub.doc-line.prod-code  = TMP#bs.prod-code
            AND   ub.doc-line.prod-type  = TMP#bs.prod-type
            AND   ub.doc-line.status_    = 'запрос':U
            AND   ub.doc-line.artic      = TMP#bs.artic
            no-lock no-error .
            qnty-orders =  qnty-orders  +
                      (if avail ub.doc-line then
                      string(ub.doc-line.fact-qnty)  Else "0")  +  CHR(9) .
     End.
    End.
 End.
 Else qnty-orders = "".
      if Make-Excel then  put   stream ForExcel unformatted
        p1   CHR(9)
        p2   CHR(9)
        excel-sum(p3)   CHR(9)
        excel-sum(p4)   CHR(9)
        excel-sum(p5)   CHR(9)
        string(TMP#bs.ret-str[1])
        excel-sum(p6)   CHR(9)
        string(TMP#bs.ret-str[8])
        excel-sum(p7)   CHR(9)
        excel-sum(p8)   CHR(9)
        string(TMP#bs.ret-str[2] )
        .
      if Showorders = false THEN DO:
      if Make-Excel then  put   stream ForExcel unformatted
        excel-sum(p9)   CHR(9)
        string(TMP#bs.ret-str[3]  )
        excel-sum(p10)  CHR(9)
        string(TMP#bs.ret-str[4])
        excel-sum(p11)  CHR(9)
        string(TMP#bs.ret-str[5])
        excel-sum(p12)  CHR(9)
        string(TMP#bs.ret-str[6])
        excel-sum(p13)  CHR(9)
        string(TMP#bs.ret-str[7])
        Skip.
      End.
      if Showorders = true  THEN DO:
         if Make-Excel then  put   stream ForExcel unformatted qnty-orders       skip  .
      End.
      if Make-Excel then  put   stream ForExcel unformatted Skip.
  End.
End procedure.
PROCEDURE Maketemptable :
   Assign
    v#b-code        = gds-zap-b-code
    v#artic         = gds-zap-artic
    v#prod-code     = gds-zap-prod-code
    v#prod-type     = gds-zap-prod-type
    v#prt-root      = gds-zap-prt-root
    v#grp-name      = gds-zap-grp-name
    v#F-zakaz       =  F-zakaz
    v#F-center-stock=  F-center-stock
    v#Prih          =  Prih          [1]
    v#ostatok-end   =  ostatok-end   [1]
    v#f-avr         =  f-avr
    v#kASSA1        =  kASSA         [1]
    v#KAssa2        =  KAssa         [2]
    v#KAssa3        =  KAssa         [3]
    v#KAssa4        =  KAssa         [4]
    v#KAssa5        =  KAssa         [5]
    v#KAssa6        =  KAssa         [6]
    no-error.
     Repeat l = 1 to 8 :
       V#ret-str[l] = (ret-str[l]).
     End.
   Create TMP#bs no-error.
   run eqq no-error.
END PROCEDURE.
PROCEDURE Eqq :
   Assign
    TMP#bs.b-code        = v#b-code
    TMP#bs.artic         = v#artic
    TMP#bs.prod-code     = v#prod-code
    TMP#bs.prod-type     = v#prod-type
    TMP#bs.prt-root      = v#prt-root
    TMP#bs.grp-name      = v#grp-name
    TMP#bs.F-zakaz       = v#F-zakaz
    TMP#bs.F-center-stock= v#F-center-stock
    TMP#bs.Prih          = v#Prih
    TMP#bs.ostatok-end   = v#ostatok-end
    TMP#bs.f-avr         = v#f-avr
    TMP#bs.kASSA1        = v#kASSA1
    TMP#bs.KAssa2        = v#KAssa2
    TMP#bs.KAssa3        = v#KAssa3
    TMP#bs.KAssa4        = v#KAssa4
    TMP#bs.KAssa5        = v#KAssa5
    TMP#bs.KAssa6        = v#KAssa6
    TMP#bs.KAssa6        = v#KAssa6    no-error    .
     Repeat l = 1 to 8 :
       TMP#bs.ret-str[l] = v#ret-str[l] no-error.
     End.
END PROCEDURE.
PROCEDURE PrintTempTAble :
define variable i as int init 0  no-undo.
 Case RetClassify  :
  WHEN "no-classify":U then DO:
        For each TMP#bs   no-lock by
        (if xSorttype = "sort-code":U  THEN string(TMP#bs.b-code)
          ELSE if xSorttype = "sort-artic":U  THEN TMP#bs.artic
                ELSE  string( TMP#bs.f-avr,"-9999999999.999"))  :
                    i = i + 1 .
        If  Tog-Qnty = true   and  TMP#bs.f-avr = 0 then next.
        If  Tog-Qnty = true  and I <= xBSAmount Then DO:
             run display-line-tmp in this-procedure (i).  end.
        If  Tog-Qnty = false  Then  DO:
            run display-line-tmp in this-procedure (i). end.
        End.
    End.
    when  "grp-goods":U then do:
      if xtog-lavel = false then do:
        For each TMP#bs where
        ( Tog-Qnty = false OR TMP#bs.f-avr <> 0 )
         no-lock  BREAK by TMP#bs.grp-name BY
        (if xSorttype = "sort-code":U  THEN string(TMP#bs.b-code)
          ELSE if xSorttype = "sort-artic":U  THEN TMP#bs.artic
                ELSE  string(TMP#bs.f-avr,"-9999999999.999"))  :
                    i = i + 1 .
            if First-of(TMP#bs.grp-name) then do:
              run sub-head in this-procedure (tmp#bs.grp-name).
              End.
            If  Tog-Qnty = true  and I <= xBSAmount Then  Run display-line-tMP(i).
            If  Tog-Qnty = false Then   Run display-line-tMP(i).
            if last-of(TMP#bs.grp-name) then do :
               i = 0.
               run sub-foot in this-procedure (tmp#bs.grp-name).
               End.
            End.
       end.
       else do:
        for each tmp#bs where
        ( tog-qnty = false or tmp#bs.f-avr <> 0 )
         no-lock  break
          by (n-lavel(tmp#bs.grp-name,xlavel))
          by str
          by (if xsorttype = "sort-code":u  then string(tmp#bs.b-code)
                                            else
                                              if xsorttype = "sort-artic":u
                                                 then tmp#bs.artic
                                                 else  string(tmp#bs.f-avr,"-9999999999.999"))  :
           str = n-lavel(input tmp#bs.grp-name, input xlavel ) .
           i = i + 1 .
            if First-of(str) then do:
              run sub-head in this-procedure (str).
              End.
            If  Tog-Qnty = true  and I <= xBSAmount Then  run display-line-tmp in this-procedure (i).
            If  Tog-Qnty = false Then   run display-line-tmp in this-procedure (i).
            if last-of(str) then do :
               i = 0.
               run sub-foot in this-procedure (str).
               End.
        end.
       end.
     end.
  End case.
END PROCEDURE.
PROCEDURE display-line-tMP :
define input parameter i as int no-undo.
run display-str-ex ( ':',
  i                     ,
  TMP#bs.artic          ,
  TMP#bs.F-zakaz        ,
  TMP#bs.F-center-stock ,
  TMP#bs.Prih           ,
  TMP#bs.ostatok-end    ,
  TMP#bs.f-avr          ,
  TMP#bs.kASSA1         ,
  TMP#bs.KAssa2         ,
  TMP#bs.KAssa3         ,
  TMP#bs.KAssa4         ,
  TMP#bs.KAssa5         ,
  TMP#bs.KAssa6
  , "":U).
run calc-sub-itog in this-procedure (0).
END PROCEDURE.
PROCEDURE ob-line-1  :
define input  parameter x-store-code     like ub.clients.obj-code      no-undo.
define input  parameter x-store-type     like ub.clients.obj-type      no-undo.
define INPUT  parameter x-artic          like ub.stk-line.artic        no-undo.
define INPUT  parameter x-prod-code      like ub.stk-line.prod-code    no-undo.
define INPUT  parameter x-prod-type      like ub.stk-line.prod-type    no-undo.
define INPUT  parameter x-Fact-order-1   like ub.stk-line.Fact-order   no-undo.
define INPUT  parameter x-Fact-order-2   like ub.stk-line.Fact-order   no-undo.
define input  parameter x-sum-type       like ub.stk-line.sum-type     no-undo.
define input  parameter x-cat-id         like ub.stk-line.cat-id       no-undo.
define input  parameter x-ext-doc-type   like ub.ot-line.ext-doc-type no-undo.
define input  parameter xTog-obj         as log no-undo.
define input  parameter xi               as int no-undo.
define output  parameter Quntity         like ub.stk-line.fact-qnty   no-undo.
define output  parameter ret-str         as char  no-undo.
define variable  First-sum   like ub.stk-line.fact-qnty   no-undo.
define variable  Second-sum  like ub.stk-line.fact-qnty   no-undo.
define variable  Temp-First-sum   like ub.stk-line.fact-qnty   no-undo.
define variable  Temp-Second-sum  like ub.stk-line.fact-qnty   no-undo.
  if x-Fact-order-2 < x-Fact-order-1 Then x-Fact-order-2 = x-Fact-order-1.
  Assign First-sum = 0 Second-sum = 0 Temp-First-sum = 0 Temp-Second-sum = 0 ret-str = "" .
  For each Temp#obj-list   no-lock BREAK by Temp#obj-list.grp-name :
    FOR each temp#sum-type where temp#sum-type.xi = xi no-lock :
      For each  ub.ot-line where
                              ub.ot-line.artic         = x-artic
                        AND   ub.ot-line.fact-order   <= x-fact-order-2
                        AND   ub.ot-line.fact-order   >= x-fact-order-1
                        AND   ub.ot-line.obj-code     = Temp#obj-list.obj-code
                        AND   ub.ot-line.obj-type     = Temp#obj-list.obj-type
                        AND   ub.ot-line.prod-code    = x-prod-code
                        AND   ub.ot-line.prod-type    = x-prod-type
                        AND   ub.ot-line.sum-type     = 'crsa':U
                        AND   ub.ot-line.ext-doc-type = temp#sum-type.sum-type
                           no-lock  :
            Assign
            First-sum      = First-sum + ub.ot-line.fact-qnty
            Temp-First-sum = Temp-First-sum + ub.ot-line.fact-qnty.
      End.
    End.
    if LAST-of (Temp#obj-list.grp-name) Then
      Assign ret-str = ret-str + String(decimal(Temp-first-sum) )
             ret-str = ret-str + CHR(9)
             Temp-First-sum  = 0 .
 End.
 Quntity = first-sum.
END PROCEDURE.
Procedure Sub-head :
define input parameter p1 as character no-undo .
  temp-str = string("ГРУППА : " + p1 ).
             if Make-Excel then  put   stream ForExcel unformatted temp-str format "X(100)" SKIP.
 End procedure.
Procedure Sub-Foot :
define input parameter p1 as character no-undo .
  temp-str = string("Итого по"+ CHR(9) + " ГРУППА : " + p1 ).
  run di ("b1", 1, "Итого по",p1,"","","b1").
  run clear-b1.
 End procedure.
 procedure display-line :
  do
  on error undo, return error return-value
  :
  end.
 end procedure.
