def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Представленность матрицы товаров на объекте (закладка № 2)".
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
CREATE WIDGET-POOL.
def var State-source as  WIDGET-HANDLE.
def var ii as integer no-undo .
define variable cli-list as character no-undo .
define buffer buf_clients for clients .
DEFINE BUTTON BUTTON-cli
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "2"
     SIZE 2.88 BY 1.
DEFINE BUTTON BUTTON-cli-2
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "2"
     SIZE 2.88 BY 1.
DEFINE VARIABLE cli-type AS CHARACTER FORMAT "X(256)":U
     VIEW-AS COMBO-BOX INNER-LINES 2
     DROP-DOWN-LIST
     SIZE 6 BY 1 NO-UNDO.
DEFINE VARIABLE cli-type-2 AS CHARACTER FORMAT "X(256)":U
     VIEW-AS COMBO-BOX INNER-LINES 2
     DROP-DOWN-LIST
     SIZE 6 BY 1 NO-UNDO.
DEFINE VARIABLE cli-code AS INTEGER FORMAT ">>>>>>>>>>>9" INITIAL 0
     LABEL "1"
     VIEW-AS FILL-IN
     SIZE 6 BY 1.
DEFINE VARIABLE cli-code-2 AS INTEGER FORMAT ">>>>>>>>>>>9" INITIAL 0
     LABEL "2"
     VIEW-AS FILL-IN
     SIZE 6 BY 1.
DEFINE VARIABLE cli-name AS CHARACTER FORMAT "X(40)"
      VIEW-AS TEXT
     SIZE 47.5 BY 1.
DEFINE VARIABLE cli-name-2 AS CHARACTER FORMAT "X(40)"
      VIEW-AS TEXT
     SIZE 47 BY 1.
DEFINE VARIABLE FILL-date AS DATE FORMAT "99/99/99":U
     VIEW-AS FILL-IN
     SIZE 9 BY 1 NO-UNDO.
DEFINE VARIABLE FILL-date1 AS DATE FORMAT "99/99/99":U
     LABEL "c"
     VIEW-AS FILL-IN
     SIZE 9 BY 1 NO-UNDO.
DEFINE VARIABLE FILL-date2 AS DATE FORMAT "99/99/99":U
     LABEL "по"
     VIEW-AS FILL-IN
     SIZE 9 BY 1 NO-UNDO.
DEFINE VARIABLE FILL-time AS INTEGER FORMAT ">9":U INITIAL 0
     LABEL "время (часы)"
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.
DEFINE VARIABLE var-lavel AS INTEGER FORMAT ">>9":U INITIAL 1
     VIEW-AS FILL-IN NATIVE
     SIZE 5 BY .79 NO-UNDO.
DEFINE VARIABLE var-lavel-2 AS INTEGER FORMAT ">>9":U INITIAL 1
     VIEW-AS FILL-IN NATIVE
     SIZE 5 BY .79 NO-UNDO.
DEFINE VARIABLE Classify AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Без классификации", "no-classify":U,
"Группы поставщиков", "post":U,
"Группы товаров", "grp-goods":U,
"Группы поставщиков/Группы товаров", "post/grp-goods":U,
"Группы товаров/Группы поставщиков", "grp-goods/post":U
     SIZE 38.5 BY 5
     FGCOLOR 0  NO-UNDO.
DEFINE VARIABLE Rad-Goods AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "все", 1,
"только 0", 2
     SIZE 13 BY 2.29
     FGCOLOR 0  NO-UNDO.
DEFINE VARIABLE Rad-Inter AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "за период", 1,
"на дату", 2
     SIZE 12 BY 2.17 NO-UNDO.
DEFINE VARIABLE SortType AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "по артикулу", "sort-article":U,
"по наимен.", "sort-name":U
     SIZE 14 BY 2.25
     FGCOLOR 0  NO-UNDO.
DEFINE RECTANGLE RECT-5
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 45.75 BY 8.
DEFINE RECTANGLE RECT-7
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 42.25 BY 3.42.
DEFINE RECTANGLE RECT-8
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 23 BY 8.
DEFINE RECTANGLE RECT-9
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 69.5 BY 3.42.
DEFINE VARIABLE ShowGoods AS LOGICAL INITIAL no
     LABEL "Показать товары":L
     VIEW-AS TOGGLE-BOX
     SIZE 19 BY .83
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE Tog-lavel AS LOGICAL INITIAL no
     LABEL "с уровня":L
     VIEW-AS TOGGLE-BOX
     SIZE 12.63 BY .79
     FGCOLOR 0  NO-UNDO.
DEFINE VARIABLE Tog-lavel-2 AS LOGICAL INITIAL no
     LABEL "с уровня":L
     VIEW-AS TOGGLE-BOX
     SIZE 12.63 BY .79
     FGCOLOR 0  NO-UNDO.
DEFINE FRAME F-Main
     Rad-Inter AT ROW 2 COL 3 NO-LABEL
     FILL-date1 AT ROW 2 COL 17.25 COLON-ALIGNED
     FILL-date2 AT ROW 2 COL 31.63 COLON-ALIGNED
     FILL-date AT ROW 3.08 COL 13.75 COLON-ALIGNED NO-LABEL
     FILL-time AT ROW 3.13 COL 37.63 COLON-ALIGNED
     cli-code AT ROW 5.5 COL 4 COLON-ALIGNED
     cli-type AT ROW 5.5 COL 10.5 COLON-ALIGNED NO-LABEL
     BUTTON-cli AT ROW 5.5 COL 18.5
     cli-code-2 AT ROW 6.75 COL 4 COLON-ALIGNED
     cli-type-2 AT ROW 6.75 COL 10.5 COLON-ALIGNED NO-LABEL
     BUTTON-cli-2 AT ROW 6.75 COL 18.5
     ShowGoods AT ROW 8.75 COL 49.5
     Classify AT ROW 9.5 COL 2.75 NO-LABEL
     Rad-Goods AT ROW 9.71 COL 51 NO-LABEL
     Tog-lavel-2 AT ROW 10.46 COL 28.25
     var-lavel-2 AT ROW 10.46 COL 39.13 COLON-ALIGNED NO-LABEL
     var-lavel AT ROW 11.29 COL 39.13 COLON-ALIGNED NO-LABEL
     Tog-lavel AT ROW 11.33 COL 28.25
     SortType AT ROW 13.75 COL 50.5 NO-LABEL
     cli-name AT ROW 5.5 COL 21 NO-LABEL
     cli-name-2 AT ROW 6.75 COL 21.5 NO-LABEL
     "Классификация :" VIEW-AS TEXT
          SIZE 15 BY .75 AT ROW 8.63 COL 7.13
          FGCOLOR 4
     "Сортировка :" VIEW-AS TEXT
          SIZE 13.63 BY .75 AT ROW 12.79 COL 50.13
          FGCOLOR 4
     "Выбор отчета:" VIEW-AS TEXT
          SIZE 19.38 BY .67 AT ROW 1.25 COL 3
          FGCOLOR 4
     "Объекты для анализа:" VIEW-AS TEXT
          SIZE 22.25 BY .67 AT ROW 4.88 COL 2.75
          FGCOLOR 4
     RECT-8 AT ROW 8.5 COL 48
     RECT-5 AT ROW 8.46 COL 1.75
     RECT-7 AT ROW 1.04 COL 1.75
     RECT-9 AT ROW 4.75 COL 1.5
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
    DISABLE RECT-8 RECT-5 RECT-7 RECT-9 Rad-Inter FILL-date1 FILL-date2 FILL-date FILL-time cli-code cli-type BUTTON-cli cli-code-2 cli-type-2 BUTTON-cli-2 ShowGoods Classify Rad-Goods SortType WITH FRAME F-Main.
    RUN dispatch ('disable-fields':U).
    RUN set-attribute-list ('ENABLED=no':U).
    RETURN.
END PROCEDURE.
PROCEDURE adm-edit-attribute-list :
      RUN adm/support/viewerd.w (INPUT THIS-PROCEDURE).
      RETURN.
END PROCEDURE.
PROCEDURE adm-enable :
    ENABLE UNLESS-HIDDEN RECT-8 RECT-5 RECT-7 RECT-9 Rad-Inter FILL-date1 FILL-date2 FILL-date FILL-time cli-code cli-type BUTTON-cli cli-code-2 cli-type-2 BUTTON-cli-2 ShowGoods Classify Rad-Goods SortType WITH FRAME F-Main.
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
ON CHOOSE OF BUTTON-cli IN FRAME F-Main
DO:
  run ref/cli-all.w ( my-handle, "b-sel", 'объект':U, 'все':U, 'текущие':U, ?, ",,,,,,NO,,":u, "without-obj":U, output cli-list ) .
  if cli-list <> "" then do:
    find first buf_clients no-lock where RECID(buf_clients) = int (cli-list) no-error.
    assign cli-type = buf_clients.obj-type  cli-code = buf_clients.obj-code  cli-name = buf_clients.obj-name .
  end.
  else assign cli-name = ""   cli-code = ?  .
  display cli-name    cli-code   with frame F-Main.
END.
ON CHOOSE OF BUTTON-cli-2 IN FRAME F-Main
DO:
  run ref/cli-all.w ( my-handle, "b-sel", 'объект':U, 'все':U, 'текущие':U, ?, ",,,,,,NO,,":u, "without-obj":U, output cli-list ) .
  if cli-list <> "" then do:
    find first buf_clients no-lock where RECID(buf_clients) = int (cli-list) no-error.
    assign cli-type-2 = buf_clients.obj-type  cli-code-2 = buf_clients.obj-code  cli-name-2 = buf_clients.obj-name .
  end.
  else assign cli-name-2 = ""   cli-code-2 = ?  .
  display cli-name-2    cli-code-2   with frame F-Main.
END.
ON VALUE-CHANGED OF Classify IN FRAME F-Main
DO:
  Assign Classify.
  if Classify = "grp-goods":U  Then do:
    display TOG-lavel   with frame F-Main .
    enable  TOG-lavel   with frame F-Main .
  end.
  Else do:
    assign TOG-lavel = no .
    display  TOG-lavel  var-Lavel with frame F-Main .
    disable  TOG-lavel  var-Lavel with frame F-Main .
  end.
  if Classify = "post":U Then do:
    display TOG-lavel-2   with frame F-Main .
    enable  TOG-lavel-2   with frame F-Main .
  end.
  Else do:
    assign TOG-lavel-2 = no .
    display  TOG-lavel-2  var-Lavel-2 with frame F-Main .
    disable  TOG-lavel-2  var-Lavel-2 with frame F-Main .
  end.
END.
ON LEAVE OF cli-code IN FRAME F-Main
DO:
  if cli-code = int ( cli-code:screen-value ) then return.
  assign cli-code.
  find first buf_clients no-lock where buf_clients.obj-type = cli-type and buf_clients.obj-code = cli-code no-error.
  if not available buf_clients then apply "CHOOSE" to BUTTON-cli IN FRAME F-Main .
  else do:
    assign cli-name = buf_clients.obj-name   cli-code = buf_clients.obj-code .
    display cli-name  cli-code  with frame F-Main.
  end.
END.
ON RETURN OF cli-code IN FRAME F-Main
DO:
  if cli-code = int ( cli-code:screen-value ) then return.
  assign cli-code.
  find first buf_clients no-lock where buf_clients.obj-type = cli-type and buf_clients.obj-code = cli-code no-error.
  if not available buf_clients then apply "CHOOSE" to BUTTON-cli IN FRAME F-Main .
  else do:
    assign cli-name = buf_clients.obj-name   cli-code = buf_clients.obj-code .
    display cli-name  cli-code  with frame F-Main.
  end.
END.
ON LEAVE OF cli-code-2 IN FRAME F-Main
DO:
  if cli-code-2 = int ( cli-code-2:screen-value ) then return.
  assign cli-code-2.
  find first buf_clients no-lock where buf_clients.obj-type = cli-type-2 and buf_clients.obj-code = cli-code-2 no-error.
  if not available buf_clients then apply "CHOOSE" to BUTTON-cli-2 IN FRAME F-Main .
  else do:
    assign cli-name-2 = buf_clients.obj-name   cli-code-2 = buf_clients.obj-code .
    display cli-name-2  cli-code-2  with frame F-Main.
  end.
END.
ON RETURN OF cli-code-2 IN FRAME F-Main
DO:
  if cli-code-2 = int ( cli-code-2:screen-value ) then return.
  assign cli-code-2.
  find first buf_clients no-lock where buf_clients.obj-type = cli-type-2 and buf_clients.obj-code = cli-code-2 no-error.
  if not available buf_clients then apply "CHOOSE" to BUTTON-cli-2 IN FRAME F-Main .
  else do:
    assign cli-name-2 = buf_clients.obj-name   cli-code-2 = buf_clients.obj-code .
    display cli-name-2  cli-code-2  with frame F-Main.
  end.
END.
ON VALUE-CHANGED OF cli-type IN FRAME F-Main
DO:
  assign cli-type .
  if cli-code <> 0 and cli-code <> ? then do:
    find first buf_clients no-lock where buf_clients.obj-type = cli-type and buf_clients.obj-code = cli-code no-error.
    if not available buf_clients then assign cli-name = ""                     cli-code = ? .
    else                              assign cli-name = buf_clients.obj-name   cli-code = buf_clients.obj-code .
  end.
  display cli-name  cli-code  with frame F-Main.
END.
ON VALUE-CHANGED OF cli-type-2 IN FRAME F-Main
DO:
  assign cli-type-2 .
  if cli-code-2 <> 0 and cli-code-2 <> ? then do:
    find first buf_clients no-lock where buf_clients.obj-type = cli-type-2 and buf_clients.obj-code = cli-code-2 no-error.
    if not available buf_clients then assign cli-name-2 = ""                     cli-code-2 = ? .
    else                              assign cli-name-2 = buf_clients.obj-name   cli-code-2 = buf_clients.obj-code .
  end.
  display cli-name-2  cli-code-2  with frame F-Main.
END.
ON VALUE-CHANGED OF Rad-Inter IN FRAME F-Main
DO:
   Assign Rad-Inter.
   if Rad-Inter = 1 Then do:
     enable   FILL-date1  FILL-date2   with frame F-Main .
     disable  FILL-date   FILL-time    with frame F-Main .
   end.
   Else do:
     disable  FILL-date1  FILL-date2   with frame F-Main .
     enable   FILL-date   FILL-time    with frame F-Main .
   end.
   display  FILL-date  FILL-date1  FILL-date2  FILL-time  with frame F-Main .
END.
ON VALUE-CHANGED OF ShowGoods IN FRAME F-Main
DO:
  assign ShowGoods .
  if ShowGoods = yes then do:
    enable   Rad-Goods SortType with frame F-Main .
  end.
  else do:
    disable   Rad-Goods SortType with frame F-Main .
  end.
END.
ON VALUE-CHANGED OF Tog-lavel IN FRAME F-Main
DO:
  Assign tog-lavel.
  if tog-lavel =TRUE Then do:
    display  var-Lavel  with frame F-Main .
    enable   var-Lavel  with frame F-Main .
  end.
  Else do:
    display    var-Lavel with frame F-Main .
    disable    var-Lavel with frame F-Main .
  end.
END.
ON VALUE-CHANGED OF Tog-lavel-2 IN FRAME F-Main
DO:
   Assign tog-lavel-2.
   if tog-lavel-2 = TRUE Then do:
     display  var-Lavel-2  with frame F-Main .
     enable   var-Lavel-2  with frame F-Main .
   end.
   Else do:
     display    var-Lavel-2 with frame F-Main .
     disable    var-Lavel-2 with frame F-Main .
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
    var-lavel:screen-value in frame F-Main = '1'.
    var-lavel-2:screen-value in frame F-Main = '1'.
    cli-type:list-items     = 'скл':U + "," + 'маг':U .
    cli-type:screen-value   = 'маг':U .
    cli-type-2:list-items   = 'скл':U + "," + 'маг':U .
    cli-type-2:screen-value = 'скл':U .
    assign cli-type cli-type-2 .
    apply "VALUE-CHANGED" to ShowGoods IN FRAME F-Main .
    apply "VALUE-CHANGED" to Rad-Inter IN FRAME F-Main .
END PROCEDURE.
PROCEDURE my-report :
  if Rad-Inter = 1 then do:
    if FILL-date1 = ? THEN DO:
      message "Не задана дата начала интервала!" view-as alert-box ERROR.
      return.
    end.
    if FILL-date2 = ? THEN DO:
      message "Не задана дата окончания интервала!" view-as alert-box ERROR.
      return.
    end.
    if FILL-date1 > FILL-date2 THEN DO:
      message "Дата начала интервала больше даты окончания!" view-as alert-box ERROR.
      return.
    end.
  end.
  else do:
    if FILL-date = ? THEN DO:
      message "Не задана дата отчета!" view-as alert-box ERROR.
      return.
    end.
    if FILL-time > 23 then do:
      message "Время отчета должно быть от 0 до 23 часов!" view-as alert-box ERROR.
      return.
    end.
    assign
      FILL-date1 = FILL-date
      FILL-date2 = FILL-date
    .
  end.
  if cli-code = ? or cli-code = 0 then do:
    message "Не задан 1 объект для отчета!" view-as alert-box ERROR.
    return.
  end.
  if cli-code-2 = ? or cli-code-2 = 0 then do:
    message "Не задан 2 объект для отчета!" view-as alert-box ERROR.
    return.
  end.
   run rep/r-mattov.p  (
                  input Rad-Inter   ,
                  input FILL-date1  ,
                  input FILL-date2  ,
                  input FILL-time   ,
                  input cli-code    ,
                  input cli-type    ,
                  input cli-code-2  ,
                  input cli-type-2  ,
                  input ShowGoods   ,
                  input Rad-Goods   ,
                  input Classify    ,
                  input SortType    ,
                  input tog-lavel   ,
                  input var-lavel   ,
                  input tog-lavel-2 ,
                  input var-lavel-2) .
END PROCEDURE.
PROCEDURE my-var :
assign frame F-Main  Classify SortType  Tog-lavel  var-lavel Tog-lavel-2  Var-lavel-2
                            Rad-Inter FILL-date1 FILL-date2 FILL-date FILL-time cli-code cli-type
                            cli-code-2 cli-type-2 ShowGoods Rad-Goods  .
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
if Classify = "time":U THEN t-class =   "Временные интервалы" .
if Classify = "time/grp-goods":U THEN t-class =   "Временные интервалы/Группы товаров" .
ReportNAme = "Представленность матрицы товаров на объекте" .
if Rad-Inter = 1 then ReportNAme = ReportNAme + " c " + string(FILL-date1,"99/99/99") + " по " + string(FILL-date2,"99/99/99") .
else                  ReportNAme = ReportNAme + " на " + string(FILL-time,"99") + " ч. " + string(FILL-date,"99/99/99") .
ReportHeader = "Классификация : " + t-Class .
ReportHeader = ReportHeader + (if tog-lavel  then "    Итоги с уровня товаров "  + String(var-lavel)  else " "    ).
ReportHeader = ReportHeader + (if tog-lavel-2  then "    Итоги с уровня поставщиков "  + String(var-lavel-2)  else " "    ).
 assign
   str1 = cli-name
   str2 = cli-name-2
 .
END PROCEDURE.
PROCEDURE state-changed :
  DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE    NO-UNDO.
  DEFINE INPUT PARAMETER p-state      AS CHARACTER NO-UNDO.
  CASE p-state:
  END CASE.
END PROCEDURE.
