CREATE WIDGET-POOL.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список колонок и определение ширины страницы".
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
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
DEFINE TEMP-TABLE List-field NO-UNDO
       field id as int
       field naim as char
       field use as log
       field make-correct as log
       field w-col as int
       .
RUN set-attribute-list (
    'Keys-Accepted = "",
     Keys-Supplied = ""':U).
RUN set-attribute-list (
    'SortBy-Options = ""':U).
DEFINE BUTTON B-demark
     LABEL "-"
     SIZE 3 BY 1 TOOLTIP "Снять все отметки".
DEFINE BUTTON B-mark
     LABEL "+"
     SIZE 3 BY 1 TOOLTIP "Отметить все колонки для печати".
DEFINE BUTTON b-mark-2
     LABEL "+-":L
     SIZE 3 BY 1 TOOLTIP "Отметить текущее поле для печати"
     BGCOLOR 8 .
DEFINE VARIABLE w-all AS INTEGER FORMAT ">>>":R3 INITIAL 0
     LABEL "Итого ширина отчета"
      VIEW-AS TEXT
     SIZE 4.38 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE w-all-1 AS INTEGER FORMAT ">>>":R3 INITIAL 0
      VIEW-AS TEXT
     SIZE 4.25 BY .67 TOOLTIP "Ширина отчета со всеми колонками"
     FGCOLOR 1  NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 1 GRAPHIC-EDGE
     SIZE 30.13 BY .08
     BGCOLOR 0 .
DEFINE QUERY br_table FOR
      List-field SCROLLING.
DEFINE BROWSE br_table
  QUERY br_table NO-LOCK DISPLAY
      List-field.use COLUMN-LABEL "П" FORMAT "+/" LABEL-FGCOLOR 4
      List-field.Naim COLUMN-LABEL "Наименование":C43 FORMAT "X(43)" LABEL-FGCOLOR 4
      List-field.w-col COLUMN-LABEL "Ширина" FORMAT ">>>" LABEL-FGCOLOR 4
    WITH NO-ASSIGN SEPARATORS SIZE 56 BY 15.83
         BGCOLOR 15 .
DEFINE FRAME F-Main
     br_table AT ROW 1 COL 1
     B-mark AT ROW 1.08 COL 57.38
     B-demark AT ROW 2.08 COL 57.38
     b-mark-2 AT ROW 3.08 COL 57.38
     w-all AT ROW 17.5 COL 55.01 RIGHT-ALIGNED
     w-all-1 AT ROW 17.5 COL 59.38 RIGHT-ALIGNED NO-LABEL
     RECT-1 AT ROW 17 COL 30
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1 SCROLLABLE
         BGCOLOR 8 FGCOLOR 0 .
DEFINE VARIABLE adm-sts           AS LOGICAL NO-UNDO.
DEFINE VARIABLE adm-brs-in-update AS LOGICAL NO-UNDO INIT no.
DEFINE VARIABLE adm-brs-initted   AS LOGICAL NO-UNDO INIT no.
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
     'YES~`':U +
     '~`':U +
     'List-field~`':U +
     'List-field~`':U +
     (IF adm-object-hdl = ? THEN "":U ELSE STRING(adm-object-hdl))
        + "~`":U +
     'Initial-Lock,Hide-on-Init,Disable-on-Init,Key-Name,Layout,Create-On-Add,SortBy-Case~`':U +
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
    DISABLE br_table B-mark RECT-1 B-demark b-mark-2 w-all w-all-1 WITH FRAME F-Main.
    RUN dispatch ('disable-fields':U).
    RUN set-attribute-list ('ENABLED=no':U).
    RETURN.
END PROCEDURE.
PROCEDURE adm-edit-attribute-list :
      RUN adm/support/browserd.w (INPUT THIS-PROCEDURE).
      RETURN.
END PROCEDURE.
PROCEDURE adm-enable :
    ENABLE UNLESS-HIDDEN br_table B-mark RECT-1 B-demark b-mark-2 w-all w-all-1 WITH FRAME F-Main.
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
  IF "List-field":U = "":U THEN
    RUN modify-list-attribute IN adm-broker-hdl
      (THIS-PROCEDURE, "REMOVE":U, "SUPPORTED-LINKS":U, "TABLEIO-TARGET":U).
  RUN use-create-on-add(?).
PROCEDURE adm-add-record :
   DEFINE VARIABLE trans-hdl-string  AS CHARACTER NO-UNDO.
   DEFINE VARIABLE cntr              AS INTEGER   NO-UNDO.
   DEFINE VARIABLE temp-rowid        AS ROWID     NO-UNDO.
   DEFINE VARIABLE saved-dictdb      AS CHARACTER NO-UNDO.
      IF group-assign-target = ? THEN
        RUN init-group-assign.
      IF NOT group-assign-target THEN
        RUN check-modified IN THIS-PROCEDURE ('check':U) NO-ERROR.
      ASSIGN adm-first-table = ROWID(List-field)
             adm-new-record = yes
             adm-adding-record = yes
             adm-query-empty = IF AVAILABLE(List-field)
                               THEN no ELSE yes.
      RUN set-attribute-list ("ADM-NEW-RECORD=yes,ADM-QUERY-EMPTY-ON-ADD=":U +
        IF adm-query-empty THEN "yes":U ELSE "no":U).
      RUN dispatch('enable-fields':U).
      IF (adm-create-on-add = no) AND (adm-first-tmpl-recid = ?) AND
         (DBTYPE(LDBNAME(BUFFER List-field)) EQ "PROGRESS":U)
      THEN DO:
          saved-dictdb = LDBNAME("DICTDB":U).
          CREATE ALIAS DICTDB FOR DATABASE
            VALUE(LDBNAME(BUFFER List-field)).
          RUN adm/objects/get-init.p (INPUT "List-field":U,
            OUTPUT adm-first-tmpl-recid).
          CREATE ALIAS DICTDB FOR DATABASE
            VALUE(saved-dictdb).
        END.
          DO WITH FRAME F-Main:
             IF NUM-RESULTS("br_table":U) = ? OR
              NUM-RESULTS("br_table":U) = 0
               OR BROWSE br_table:NUM-SELECTED-ROWS = 1 THEN
                adm-return-status = br_table:INSERT-ROW("AFTER":U).
              ELSE DO:
                MESSAGE
              "You must select a row after which the new row is to be inserted."
                    VIEW-AS ALERT-BOX.
                RETURN.
              END.
              adm-brs-initted = no.
          END.
      RUN notify ('add-record, GROUP-ASSIGN-TARGET':U).
      RUN new-state('update':U).
      RUN dispatch IN THIS-PROCEDURE ('apply-entry':U).
    RETURN.
END PROCEDURE.
PROCEDURE adm-assign-record :
        IF group-assign-target = ? THEN
          RUN init-group-assign.
        adm-updating-record = yes.
        IF adm-new-record THEN DO:
          IF (NOT adm-adding-record) OR
              (NOT adm-create-on-add) THEN
          DO:
             RUN dispatch ('create-record':U).
             IF RETURN-VALUE = "ADM-ERROR":U THEN UNDO, RETURN "ADM-ERROR":U.
          END.
          IF adm-create-on-add = yes THEN
          DO:
            RUN dispatch ('current-changed':U).
            IF RETURN-VALUE = "ADM-ERROR":U THEN
               RETURN "ADM-ERROR":U.
          END.
        END.
        ELSE DO:
            RUN dispatch ('current-changed':U).
            IF RETURN-VALUE = "ADM-ERROR":U THEN
               RETURN "ADM-ERROR":U.
        END.
        RUN dispatch ('assign-statement':U).
        IF RETURN-VALUE = "ADM-ERROR":U THEN
            UNDO, RETURN "ADM-ERROR":U.
        RUN notify ('assign-record,GROUP-ASSIGN-TARGET':U).
        IF RETURN-VALUE = "ADM-ERROR":U THEN UNDO, RETURN "ADM-ERROR":U.
        IF adm-new-record THEN
        DO:
            RUN get-attribute('Query-Position':U).
            IF RETURN-VALUE = 'no-record-available':U THEN
            DO:
              RUN new-state('record-available':U).
              RUN set-attribute-list('Query-Position = record-available':U).
            END.
            RUN dispatch('display-fields':U).
        END.
   RETURN.
  END PROCEDURE.
PROCEDURE adm-assign-statement :
  RETURN.
END PROCEDURE.
PROCEDURE adm-cancel-record :
  DEFINE VARIABLE source-str          AS CHARACTER NO-UNDO.
   RUN check-modified IN THIS-PROCEDURE ('clear':U) NO-ERROR.
   IF adm-new-record THEN
   DO:
      IF (adm-adding-record = yes) AND
         (adm-create-on-add = no)
      THEN DO:
        RELEASE List-field NO-ERROR.
      END.
      ELSE IF (adm-adding-record = yes) AND
        (adm-create-on-add = yes) AND
          (adm-create-complete = yes)
      THEN RUN dispatch ('delete-record':U).
        IF (adm-adding-record = no) OR (adm-create-on-add = no) THEN
          IF BROWSE br_table:NUM-SELECTED-ROWS = 1 THEN
            adm-return-status = br_table:DELETE-CURRENT-ROW()
             IN FRAME F-Main.
      adm-new-record = no.
      RUN set-attribute-list ("ADM-NEW-RECORD=no":U).
   END.
   ELSE RUN dispatch ('display-fields':U).
   RUN notify ('cancel-record, GROUP-ASSIGN-TARGET':U).
   RUN dispatch ('apply-entry':U).
   RUN get-link-handle IN adm-broker-hdl
       (THIS-PROCEDURE, 'GROUP-ASSIGN-SOURCE':U, OUTPUT source-str).
   adm-updating-record = no.
   IF source-str EQ "":U THEN
     RUN new-state('update-complete':U).
     adm-brs-in-update = no.
   RETURN.
  END PROCEDURE.
PROCEDURE adm-copy-record :
   DEFINE VARIABLE trans-hdl-string AS CHARACTER NO-UNDO.
      IF group-assign-target = ? THEN
        RUN init-group-assign.
      IF NOT group-assign-target THEN
        RUN check-modified IN THIS-PROCEDURE ('check':U) NO-ERROR.
      ASSIGN adm-first-table = ROWID(List-field)
             adm-new-record = yes
             adm-adding-record = no.
      RUN set-attribute-list ("ADM-NEW-RECORD=yes":U).
      RUN dispatch('enable-fields':U).
          DO WITH FRAME F-Main:
            IF NUM-RESULTS("br_table":U) = ? OR
               NUM-RESULTS("br_table":U) = 0 THEN
            DO:
                MESSAGE "Cannot perform Copy. There are no browse rows."
                    VIEW-AS ALERT-BOX WARNING.
                RUN dispatch ('cancel-record':U).
            END.
            ELSE DO:
             adm-first-prev-rowid = ROWID(List-field).
               IF NUM-RESULTS("br_table":U) = ? OR
                NUM-RESULTS("br_table":U) = 0
                 OR BROWSE br_table:NUM-SELECTED-ROWS = 1 THEN
                  adm-return-status = br_table:INSERT-ROW("AFTER":U).
               ELSE DO:
                  MESSAGE
              "You must select a row after which the new row is to be inserted."
                      VIEW-AS ALERT-BOX.
                  RETURN.
               END.
               adm-brs-initted = no.
            END.
          END.
      RUN notify ('copy-record, GROUP-ASSIGN-TARGET':U).
      RUN new-state('update':U).
    RETURN.
END PROCEDURE.
PROCEDURE adm-create-record :
    DEFINE VARIABLE source-str          AS CHARACTER NO-UNDO.
    DEFINE VARIABLE source-rowid-str    AS CHARACTER NO-UNDO.
       IF group-assign-target = yes THEN
       DO:
         RUN get-link-handle IN adm-broker-hdl
           (THIS-PROCEDURE, 'GROUP-ASSIGN-SOURCE':U,
              OUTPUT source-str).
         RUN send-records IN WIDGET-HANDLE (source-str)
             (INPUT "List-field":U,
              OUTPUT source-rowid-str).
         FIND List-field WHERE
             ROWID (List-field) =
                 TO-ROWID(source-rowid-str) NO-ERROR.
         IF ERROR-STATUS:ERROR THEN
         DO:
           RUN dispatch('show-errors':U).
           UNDO, RETURN "ADM-ERROR":U.
         END.
       END.
       ELSE DO:
           CREATE List-field NO-ERROR.
           IF ERROR-STATUS:ERROR THEN
           DO:
             RUN dispatch('show-errors':U).
             UNDO, RETURN "ADM-ERROR":U.
           END.
       END.
   RETURN.
END PROCEDURE.
PROCEDURE adm-current-changed :
   ASSIGN adm-first-table = ROWID(List-field).
  IF NOT group-assign-target THEN
  DO:
    FIND CURRENT List-field EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    IF NOT AVAILABLE List-field THEN
    DO:
      RUN dispatch('show-errors':U).
      IF ERROR-STATUS:GET-NUMBER(1) = 138 THEN
          RUN dispatch('get-next':U).
      ELSE FIND List-field WHERE
          ROWID(List-field) = adm-first-table NO-LOCK NO-ERROR.
      RETURN "ADM-ERROR":U.
    END.
    ELSE IF CURRENT-CHANGED List-field THEN
    DO:
      MESSAGE  SUBSTITUTE
          ("Sorry, this &1 has been changed by another user. ",
            "List-field") SKIP
            "Please note any differences and re-enter your changes."
                   VIEW-AS ALERT-BOX.
      RUN dispatch ('display-fields':U).
      UNDO, RETURN "ADM-ERROR":U.
    END.
  END.
  RETURN.
END PROCEDURE.
PROCEDURE adm-delete-record :
   DEFINE VARIABLE delete-failed AS LOGICAL NO-UNDO INIT no.
   IF group-assign-target = ? THEN
     RUN init-group-assign.
      IF BROWSE br_table:NUM-SELECTED-ROWS NE 1 THEN
      DO:
          MESSAGE "No row has been selected for deletion." VIEW-AS ALERT-BOX.
          RETURN.
      END.
      DO TRANSACTION ON STOP UNDO, LEAVE ON ERROR UNDO, LEAVE:
        IF group-assign-target NE yes THEN
        DO:
          FIND CURRENT List-field EXCLUSIVE-LOCK NO-WAIT
            NO-ERROR.
          IF ERROR-STATUS:ERROR THEN
          DO:
            RUN dispatch('show-errors':U).
            UNDO, RETURN "ADM-ERROR":U.
          END.
          DELETE List-field NO-ERROR.
        END.
        IF ERROR-STATUS:ERROR THEN
        DO:
          RUN dispatch('show-errors':U).
          delete-failed = yes.
        END.
        ELSE
            adm-return-status =
               br_table:DELETE-CURRENT-ROW() IN FRAME F-Main.
      END.
         IF NOT AVAILABLE (List-field) THEN
         DO:
           RUN new-state ('no-record-available':U).
           RUN set-attribute-list ('Query-Position = no-record-available':U).
           RUN notify ('row-available':U).
         END.
      IF delete-failed THEN
          UNDO, RETURN "ADM-ERROR":U.
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
  DEFINE VARIABLE source-str          AS CHARACTER NO-UNDO.
   IF ERROR-STATUS:ERROR THEN
       RUN dispatch('show-errors':U).
   RUN check-modified IN THIS-PROCEDURE ('clear':U) NO-ERROR.
   RUN get-link-handle IN adm-broker-hdl
      (THIS-PROCEDURE, 'GROUP-ASSIGN-SOURCE':U, OUTPUT source-str).
   IF adm-new-record AND NOT TRANSACTION THEN DO:
          adm-new-record = no.
          RUN set-attribute-list ("ADM-NEW-RECORD=no":U).
          ASSIGN adm-first-table = ROWID(List-field).
          IF source-str EQ "":U THEN
          DO:
              RUN set-attribute-list ('REPOSITION-PENDING=yes':U).
              RUN dispatch('open-query':U).
              RUN reposition-query (INPUT THIS-PROCEDURE).
              RUN dispatch('row-changed':U).
          END.
   END.
    FIND CURRENT List-field NO-LOCK NO-ERROR.
    RUN notify('end-update, GROUP-ASSIGN-TARGET':U).
    IF source-str EQ "":U THEN
        RUN new-state('update-complete':U).
      adm-brs-in-update = no.
    adm-updating-record = no.
    RUN dispatch IN THIS-PROCEDURE ('apply-entry':U).
  RETURN.
END PROCEDURE.
PROCEDURE adm-reset-record :
     RUN dispatch IN THIS-PROCEDURE ('display-fields':U).
     RUN notify ('reset-record, GROUP-ASSIGN-TARGET':U).
     RUN dispatch IN THIS-PROCEDURE ('apply-entry':U).
    RETURN.
END PROCEDURE.
PROCEDURE adm-update-record :
      DEFINE VARIABLE cRecordSrc AS CHARACTER NO-UNDO.
      DEFINE VARIABLE hRecordSrc AS HANDLE     NO-UNDO.
      DEFINE BUFFER bNewRecord FOR List-field.
      DO TRANSACTION ON STOP  UNDO, RETURN "ADM-ERROR":U
                     ON ERROR UNDO, RETURN "ADM-ERROR":U :
        RUN dispatch ('assign-record':U).
        IF  RETURN-VALUE = "ADM-ERROR":U THEN
            RETURN "ADM-ERROR":U.
      END.
      RUN dispatch ('end-update':U).
      FIND FIRST bNewRecord NO-LOCK NO-ERROR.
      IF NOT ERROR-STATUS:ERROR AND ROWID(bNewRecord) = ROWID (List-field) THEN
      DO:
        RUN get-link-handle IN adm-broker-hdl
            (INPUT THIS-PROCEDURE,
             INPUT "RECORD-SOURCE",
             OUTPUT cRecordSrc).
        hRecordSrc = WIDGET-HANDLE(cRecordSrc).
        IF VALID-HANDLE(hRecordSrc) THEN
        DO:
            RUN get-attribute IN hRecordSrc ("TYPE":U).
            IF RETURN-VALUE = "SmartQuery":U AND
               CAN-DO(hRecordSrc:INTERNAL-ENTRIES,"new-first-record") THEN
               RUN new-first-record IN hRecordSrc (INPUT ROWID (List-field)).
        END.
      END.
   RETURN.
END PROCEDURE.
PROCEDURE check-modified :
DEFINE INPUT PARAMETER check-state AS CHARACTER NO-UNDO.
DEFINE VARIABLE curr-widget       AS HANDLE      NO-UNDO.
DEFINE VARIABLE container-hdl-str AS CHARACTER   NO-UNDO.
DEFINE VARIABLE i                 AS INTEGER     NO-UNDO.
  IF NOT VALID-HANDLE(adm-object-hdl) THEN RETURN.
  IF group-assign-target = ? THEN
    RUN init-group-assign.
  IF check-state = "check":U AND group-assign-target THEN
    RETURN "":U.
  ELSE IF check-state = "group-check":U THEN
     check-state = "check":U.
  IF VALID-HANDLE(BROWSE br_table:HANDLE) AND
      AVAILABLE(List-field) THEN
  DO:
    ASSIGN curr-widget = BROWSE br_table:FIRST-COLUMN.
    DO WHILE VALID-HANDLE (curr-widget):
        IF NOT curr-widget:READ-ONLY AND curr-widget:MODIFIED THEN
        DO:
            IF check-state = "check":U THEN
            DO:
                RUN check-modified-message(curr-widget:TABLE).
                RETURN.
            END.
            ELSE IF check-state = "clear":U THEN
                curr-widget:MODIFIED = no.
        END.
        ASSIGN curr-widget = curr-widget:NEXT-COLUMN.
    END.
  END.
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
    IF LOOKUP("List-field":U, RETURN-VALUE, " ":U) NE 0 THEN
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
      ASSIGN adm-create-on-add =
          IF (p-attr-value EQ "NO":U) OR
             (p-attr-value NE "YES":U AND
           DBTYPE(LDBNAME(BUFFER List-field)) EQ "PROGRESS":U)
          THEN no ELSE yes.
        IF adm-create-on-add THEN
          BROWSE br_table:CREATE-ON-ADD = yes.
   RETURN.
END PROCEDURE.
PROCEDURE use-initial-lock :
  DEFINE INPUT PARAMETER p-attr-value AS CHARACTER NO-UNDO.
  ASSIGN adm-initial-lock = p-attr-value.
  RETURN.
END PROCEDURE.
PROCEDURE adm-display-fields :
      IF AVAILABLE List-field THEN
          DISPLAY List-field.use List-field.Naim List-field.w-col WITH BROWSE br_table
            NO-ERROR.
      DISPLAY UNLESS-HIDDEN w-all w-all-1
          WITH FRAME F-Main NO-ERROR.
    RUN check-modified IN THIS-PROCEDURE ('clear':U) NO-ERROR.
    RETURN.
END PROCEDURE.
PROCEDURE adm-open-query :
            OPEN QUERY br_table FOR EACH List-field WHERE TRUE NO-LOCK     .
        adm-query-opened = yes.
        IF NUM-RESULTS("br_table":U) = 0 THEN
            RUN new-state ('no-record-available,SELF':U).
        ELSE DO:
            RUN new-state ('record-available,SELF':U).
            RUN new-state ('first-record,SELF':U).
        END.
        IF NOT adm-updating-record THEN
            RUN dispatch IN THIS-PROCEDURE ('row-changed':U).
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
    DEFINE VARIABLE table-name                 AS ROWID NO-UNDO.
    RUN get-rowid IN p-requestor-hdl (OUTPUT table-name).
    IF table-name <> ? THEN
        REPOSITION br_table TO ROWID table-name NO-ERROR.
    RUN set-attribute-list ('REPOSITION-PENDING = NO':U).
    RETURN.
END PROCEDURE.
  adm-sts = br_table:SET-REPOSITIONED-ROW
    (br_table:DOWN,"CONDITIONAL":U).
  RUN set-attribute-list ('FIELDS-ENABLED=no,ADM-NEW-RECORD=no':U).
PROCEDURE set-size :
  DEFINE INPUT PARAMETER pd_height AS DECIMAL NO-UNDO.
  DEFINE INPUT PARAMETER pd_width  AS DECIMAL NO-UNDO.
  DEFINE VARIABLE hBrowse     AS HANDLE           NO-UNDO.
  DEFINE VARIABLE hFieldGroup AS HANDLE           NO-UNDO.
  DEFINE VARIABLE hFrame      AS HANDLE           NO-UNDO.
  DEFINE VARIABLE htmpWidget  AS HANDLE           NO-UNDO.
  DEFINE VARIABLE otherWidget AS LOGICAL          NO-UNDO.
  ASSIGN pd_height = MAX(pd_height, 2.0)
         pd_width  = MAX(pd_width, 2.0)
         hBrowse     = br_table:HANDLE IN FRAME F-Main
         hFieldGroup = hBrowse:PARENT
         htmpWidget  = hFieldGroup:FIRST-CHILD
         hFrame      = hFieldGroup:PARENT.
  Search-For-Siblings:
  REPEAT WHILE VALID-HANDLE(htmpWidget):
    IF htmpWidget NE hBrowse THEN DO:
      IF htmpWidget:TYPE NE "BUTTON" OR
         htmpWidget:X    NE 4 OR
         htmpWidget:Y    NE 4 THEN DO:
        RETURN.
      END.
    END.
    htmpWidget = htmpWidget:NEXT-SIBLING.
  END.
  IF pd_width < hBrowse:WIDTH THEN
    ASSIGN hBrowse:WIDTH = pd_width
           hFrame:WIDTH  = pd_width     NO-ERROR.
  ELSE
    ASSIGN hFrame:WIDTH  = pd_width
           hBrowse:WIDTH = pd_width     NO-ERROR.
  IF pd_height < hBrowse:HEIGHT THEN
    ASSIGN hBrowse:HEIGHT = pd_height
           hFrame:HEIGHT  = pd_height     NO-ERROR.
  ELSE
    ASSIGN hFrame:HEIGHT  = pd_height
           hBrowse:HEIGHT = pd_height     NO-ERROR.
END PROCEDURE.
ASSIGN
       FRAME F-Main:SCROLLABLE       = FALSE
       FRAME F-Main:HIDDEN           = TRUE.
ASSIGN
       B-demark:HIDDEN IN FRAME F-Main           = TRUE.
ASSIGN
       B-mark:HIDDEN IN FRAME F-Main           = TRUE.
ASSIGN
       b-mark-2:HIDDEN IN FRAME F-Main           = TRUE.
ASSIGN
       br_table:HIDDEN  IN FRAME F-Main                = TRUE.
ASSIGN
       RECT-1:HIDDEN IN FRAME F-Main           = TRUE.
ASSIGN
       w-all:HIDDEN IN FRAME F-Main           = TRUE.
ASSIGN
       w-all-1:HIDDEN IN FRAME F-Main           = TRUE.
ON CHOOSE OF B-demark IN FRAME F-Main
DO:
  For each List-field :
      If List-field.make-correct = true then List-field.use = false.
  End.
  apply "VALUE-CHANGED" to br_table in frame F-Main.
     OPEN QUERY br_table FOR EACH List-field WHERE TRUE NO-LOCK     .
END.
ON CHOOSE OF B-mark IN FRAME F-Main
DO:
  For each List-field  :
    If List-field.make-correct = true then  List-field.use = true.
  End.
  apply "VALUE-CHANGED" to br_table in frame F-Main.
     OPEN QUERY br_table FOR EACH List-field WHERE TRUE NO-LOCK     .
END.
ON CHOOSE OF b-mark-2 IN FRAME F-Main
OR MOUSE-SELECT-DBLCLICK OF br_table IN FRAME F-Main
DO:
define variable v-log as logical   no-undo .
find current List-field no-error.
  if not available List-field then do:
     message "Неправильный выбор строки.".
     return no-apply.
  end.
  If List-field.make-correct = true then DO:
    IF    List-field.use = true THEN DO:
          List-field.use = false.
          disp "" @ List-field.use with browse br_table no-error .
      End.
      Else DO:
           List-field.use = true.
           disp "+" @ List-field.use with browse br_table no-error .
      End.
   End.
     apply "VALUE-CHANGED" to br_table in frame F-Main.
     v-log = br_table:select-next-row () no-error .
END.
ON ROW-DISPLAY OF br_table IN FRAME F-Main
DO:
  if not list-field.make-correct  then
       assign
         list-field.naim  :bgcolor in browse br_table = 8
         list-field.use   :bgcolor in browse br_table = 8
         list-field.w-col :bgcolor in browse br_table = 8
         .
        Else
       assign
         list-field.naim  :bgcolor in browse br_table = ?
         list-field.use   :bgcolor in browse br_table = ?
         list-field.w-col :bgcolor in browse br_table = ?
         .
END.
ON ROW-ENTRY OF br_table IN FRAME F-Main
DO:
   IF br_table:NEW-ROW AND NOT adm-brs-initted THEN
   DO:
     adm-brs-initted = yes.
     IF adm-adding-record THEN
     DO:
       IF adm-create-on-add = no THEN
       DO:
         IF DBTYPE(LDBNAME(BUFFER List-field)) EQ "PROGRESS":U
         THEN DO:
          FIND List-field WHERE
            RECID(List-field)
              = adm-first-tmpl-recid.
          DISPLAY UNLESS-HIDDEN List-field.use List-field.Naim List-field.w-col
            WITH BROWSE br_table NO-ERROR.
         END.
        END.
        ELSE DO:
         DO TRANSACTION ON STOP  UNDO, RETURN "ADM-ERROR":U
                        ON ERROR UNDO, RETURN "ADM-ERROR":U.
           adm-create-complete = no.
           RUN dispatch ('create-record':U).
           IF RETURN-VALUE = "ADM-ERROR":U THEN UNDO, RETURN "ADM-ERROR":U.
           DISPLAY UNLESS-HIDDEN List-field.use List-field.Naim List-field.w-col
             WITH BROWSE br_table NO-ERROR.
         END.
         adm-create-complete = yes.
        END.
      END.
      ELSE
      DO:
         FIND List-field WHERE
           ROWID(List-field) =
              adm-first-prev-rowid NO-LOCK.
         DISPLAY UNLESS-HIDDEN List-field.use List-field.Naim List-field.w-col
           WITH BROWSE br_table.
      END.
   END.
END.
ON ROW-LEAVE OF br_table IN FRAME F-Main
DO:
DEFINE VARIABLE widget-enter  AS HANDLE NO-UNDO.
DEFINE VARIABLE widget-frame  AS HANDLE NO-UNDO.
DEFINE VARIABLE widget-parent AS HANDLE NO-UNDO.
  widget-enter = last-event:widget-enter.
  IF VALID-HANDLE(widget-enter) THEN widget-parent = widget-enter:PARENT.
  IF VALID-HANDLE(widget-parent) AND widget-parent:TYPE NE "BROWSE":U
    THEN widget-frame = widget-enter:FRAME.
  IF ((NOT VALID-HANDLE(widget-enter)) OR
      (widget-parent:TYPE = "BROWSE":U) OR
      (NOT VALID-HANDLE(widget-frame)) OR
      (NOT CAN-DO(widget-frame:PRIVATE-DATA, "ADM-PANEL":U)))
  THEN DO:
      IF adm-brs-in-update THEN
      DO:
        MESSAGE
        "You must complete or cancel the update before leaving the current row."
            VIEW-AS ALERT-BOX WARNING.
        RETURN NO-APPLY.
      END.
      IF br_table:CURRENT-ROW-MODIFIED  OR
        (adm-new-record AND BROWSE br_table:NUM-SELECTED-ROWS = 1) THEN
      DO:
        IF VALID-HANDLE (widget-parent) AND widget-parent:TYPE NE "BROWSE":U
        THEN DO:
          MESSAGE
          "Current record has been changed. " SKIP
          "Do you wish to save those changes?"
            VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE l-save AS LOGICAL.
          IF l-save THEN
          DO:
             RUN dispatch('update-record':U).
             IF RETURN-VALUE = "ADM-ERROR":U THEN
                 RETURN NO-APPLY.
          END.
          ELSE RUN dispatch ('cancel-record':U).
        END.
        ELSE DO:
          RUN dispatch('update-record':U).
          IF RETURN-VALUE = "ADM-ERROR":U THEN
              RETURN NO-APPLY.
        END.
      END.
  END.
END.
ON VALUE-CHANGED OF br_table IN FRAME F-Main
DO:
RUN get-attribute('ADM-NEW-RECORD':U).
IF RETURN-VALUE NE "YES":U THEN
  RUN notify ('row-available':U).
  w-all = 0.
  for each List-field no-lock :
      if List-field.use then
       assign
         w-all = w-all + List-field.w-col
         w-all = w-all + 1.
  End.
  if w-all > 0 Then DO:
      display w-all  with frame F-Main.
      RUN get-attribute IN THIS-PROCEDURE ('UIB-MODE').
      IF  RETURN-VALUE NE "DESIGN" THEN DO:
          define variable source-str as character.
          define variable state-source as handle .
          run get-link-handle IN adm-broker-hdl ( THIS-PROCEDURE, 'State':U , OUTPUT source-str ) no-error.
          State-source = WIDGET-HANDLE ( source-str ).
          IF VALID-HANDLE ( State-source ) THEN do :
             run view-how-name in State-source (input w-all) no-error.
             End.
      END.
  End.
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
  run load-table in this-procedure   .
  Assign w-all-1 = 0 w-all = 0.
  for each List-field no-lock :
      w-all-1 = w-all-1 + List-field.w-col.
      if List-field.use then
         assign
           w-all   = w-all + List-field.w-col
           w-all-1 = w-all-1 + 1
           w-all   = w-all + 1.
  End.
  display w-all  w-all-1 with frame F-Main .
  if can-find (first  List-field no-lock) then DO :
     display br_table B-demark B-mark b-mark-2 rect-1 w-all w-all-1
             with frame F-Main.
     End.
     OPEN QUERY br_table FOR EACH List-field WHERE TRUE NO-LOCK     .
PROCEDURE adm-row-available :
  DEFINE VARIABLE tbl-list           AS CHARACTER INIT "":U NO-UNDO.
  DEFINE VARIABLE rowid-list         AS CHARACTER NO-UNDO.
  DEFINE VARIABLE row-avail-cntr     AS INTEGER INIT 0 NO-UNDO.
  DEFINE VARIABLE row-avail-rowid    AS ROWID NO-UNDO.
  DEFINE VARIABLE row-avail-enabled  AS LOGICAL NO-UNDO.
  DEFINE VARIABLE link-handle        AS CHARACTER NO-UNDO.
  DEFINE VARIABLE record-source-hdl  AS HANDLE NO-UNDO.
  DEFINE VARIABLE different-row      AS LOGICAL NO-UNDO INIT no.
  DEFINE VARIABLE key-name           AS CHARACTER INIT ? NO-UNDO.
  DEFINE VARIABLE key-value          AS CHARACTER INIT ? NO-UNDO.
  RUN check-modified IN THIS-PROCEDURE ('check':U) NO-ERROR.
  IF adm-updating-record THEN RETURN.
  RUN get-attribute ('FIELDS-ENABLED':U).
  row-avail-enabled = IF RETURN-VALUE = "YES":U THEN yes ELSE no.
  RUN get-link-handle IN adm-broker-hdl (THIS-PROCEDURE, 'RECORD-SOURCE':U,
      OUTPUT link-handle) NO-ERROR.
  IF link-handle = "":U THEN
      RETURN.
  ASSIGN record-source-hdl = WIDGET-HANDLE(ENTRY(1,link-handle)).
  IF NUM-ENTRIES(link-handle) > 1 THEN
      MESSAGE "row-available in ":U THIS-PROCEDURE:FILE-NAME
          "encountered more than one RECORD-SOURCE.":U SKIP
          "The first - ":U record-source-hdl:file-name " - will be used.":U
             VIEW-AS ALERT-BOX ERROR.
  RUN get-attribute ('Key-Name':U).
  key-name = RETURN-VALUE.
  IF key-name = "":U THEN key-name = ?.
  IF key-name NE ? THEN DO:
    RUN send-key IN record-source-hdl (INPUT key-name, OUTPUT key-value)
      NO-ERROR.
    IF key-value NE ? THEN
      RUN set-attribute-list (SUBSTITUTE ('Key-Value="&1"':U, key-value)).
  END.
IF VALID-HANDLE (adm-object-hdl) THEN
    RUN dispatch IN THIS-PROCEDURE ('display-fields':U).
  IF key-name ne ? OR different-row
  THEN RUN dispatch IN THIS-PROCEDURE ('open-query':U).
  ELSE RUN notify IN THIS-PROCEDURE('row-available':U).
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME F-Main.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.
PROCEDURE local-apply-layout :
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'apply-layout':U ) .
END PROCEDURE.
PROCEDURE local-create-record :
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'create-record':U ) .
END PROCEDURE.
PROCEDURE local-initialize :
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ) .
END PROCEDURE.
procedure load-table :
define variable ki as integer no-undo .
define variable kj as integer no-undo .
define variable qnty-col as integer no-undo .
define variable qnty-row as integer no-undo .
define variable l-name-field as character no-undo .
for each list-field  :
   delete  list-field no-error .
end.
qnty-col = MINIMUM(num-entries(entry (1,Sheetf.Excel-Column-Lable,CHR(10))),num-entries(Sheetf.sizes)).
qnty-row = num-entries(Sheetf.Excel-Column-Lable,CHR(10)).
repeat ki = 1 to qnty-col :
    l-name-field = '' .
    Repeat kj = 1 to  qnty-row :
      l-name-field = l-name-field  +
        if entry(ki, (entry(kJ,Sheetf.Excel-Column-Lable,CHR(10)))) = ""
          Then  fill(" ",10) + (if (kj <> qnty-row)  then  "/"   else " ")
          Else entry(ki, (entry(kJ,Sheetf.Excel-Column-Lable,CHR(10)))) +
            if (kj <> qnty-row)  then  "/"   else " ".
    End.
    if NOT(trim(l-name-field) = "" OR trim(l-name-field) = "/") THEN DO:
        create List-field.
          Repeat kj = 1 to  qnty-row :
            List-field.naim = List-field.naim +
              if entry(ki, (entry(kJ,Sheetf.Excel-Column-Lable,CHR(10)))) = ""
                Then  fill(" ",10) + (if (kj <> qnty-row)  then  "/"   else " ")
                Else entry(ki, (entry(kJ,Sheetf.Excel-Column-Lable,CHR(10)))) +
                  if (kj <> qnty-row)  then  "/"   else " ".
           End.
     if num-entries(Sheetf.make-correct) = qnty-col then DO:
       List-field.make-correct = if entry(ki ,Sheetf.make-correct) = "false":U  or  entry(ki,Sheetf.make-correct) = ""
                                    then false  else true .
       end.
       else do:
             List-field.make-correct = false  .
             end.
       List-field.w-col = integer(entry(ki ,Sheetf.sizes)) no-error  .
       List-field.use = use-column[ki] .
       if List-field.make-correct = false then  List-field.use = true  .
    End.
    if num-entries(Sheetf.Rights-column) = qnty-col then DO :
       if trim(entry(ki ,Sheetf.Rights-column)) = "false":U  then
       assign
           List-field.make-correct = false
           List-field.use = false .
    End.
end.
 if not can-find ( first   List-field where           List-field.make-correct = true  ) then do:
    for each list-field  :
      delete  list-field no-error .
    end.
 end.
end  procedure.
procedure read-table :
define variable s-i as integer no-undo .
define variable s-t as character no-undo .
define buffer buf_usr-flt for ubflt.usr-flt  .
For each  List-field no-lock :
    s-i = s-i + 1.
    Use-Column[s-i]  = List-field.use.
    s-t =  s-t + string(list-field.use , "true/false")  + ";".
End.
 find first buf_usr-flt exclusive-lock where
            buf_usr-flt.user-name = g#userid and
            buf_usr-flt.call-point   = ReportProc  no-error .
     if not available  buf_usr-flt then  create buf_usr-flt.
       Assign
         buf_usr-flt.user-name = g#userid
         buf_usr-flt.call-point   = ReportProc
         buf_usr-flt.list_ = buf_usr-flt.list_ + "," + string( "Use-column=" + s-t ) + ","
         .
end  procedure.
PROCEDURE op-br :
   run read-table in this-procedure .
   run load-table in this-procedure .
     OPEN QUERY br_table FOR EACH List-field WHERE TRUE NO-LOCK     .
END PROCEDURE.
PROCEDURE send-records :
  DEFINE INPUT PARAMETER p-tbl-list AS CHARACTER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-rowid-list AS CHARACTER NO-UNDO.
  DEFINE VARIABLE i            AS INTEGER   NO-UNDO.
  DEFINE VARIABLE link-handle  AS CHARACTER NO-UNDO.
  DEFINE VARIABLE rowid-string AS CHARACTER NO-UNDO.
  DO i = 1 TO NUM-ENTRIES(p-tbl-list):
      IF i > 1 THEN p-rowid-list = p-rowid-list + ",":U.
      CASE ENTRY(i, p-tbl-list):
    WHEN "List-field":U THEN p-rowid-list = p-rowid-list +
        IF AVAILABLE List-field THEN STRING(ROWID(List-field))
        ELSE "?":U.
        OTHERWISE
        DO:
            RUN get-link-handle IN adm-broker-hdl (INPUT THIS-PROCEDURE,
                INPUT "RECORD-SOURCE":U, OUTPUT link-handle) NO-ERROR.
            IF link-handle NE "":U THEN
            DO:
                IF NUM-ENTRIES(link-handle) > 1 THEN
                    MESSAGE "send-records in ":U THIS-PROCEDURE:FILE-NAME
                            "encountered more than one RECORD-SOURCE.":U SKIP
                            "The first will be used.":U
                            VIEW-AS ALERT-BOX ERROR.
                RUN send-records IN WIDGET-HANDLE(ENTRY(1,link-handle))
                    (INPUT ENTRY(i, p-tbl-list), OUTPUT rowid-string).
                p-rowid-list = p-rowid-list + rowid-string.
            END.
            ELSE
            DO:
                MESSAGE "Requested table":U ENTRY(i, p-tbl-list)
                        "does not match tables in send-records":U
                        "in procedure":U THIS-PROCEDURE:FILE-NAME ".":U SKIP
                        "Check that objects are linked properly and that":U
                        "database qualification is consistent.":U
                    VIEW-AS ALERT-BOX ERROR.
                RETURN ERROR.
            END.
        END.
        END CASE.
    END.
END PROCEDURE.
PROCEDURE state-changed :
  DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE    NO-UNDO.
  DEFINE INPUT PARAMETER p-state      AS CHARACTER NO-UNDO.
  CASE p-state:
    WHEN "update-begin":U THEN
    DO:
        adm-brs-in-update = yes.
        RUN dispatch ('enable-fields':U).
        IF RETURN-VALUE = "ADM-ERROR":U THEN
        DO:
          RUN new-state('update-failed,TABLEIO-SOURCE':U).
          RUN new-state('update-complete':U).
        END.
        ELSE DO:
          RUN dispatch ('apply-entry':U).
          RUN new-state('update':U).
        END.
    END.
    WHEN "update":U THEN
      DO:
        DEFINE VARIABLE group-link AS CHARACTER NO-UNDO INIT "":U.
        RUN get-link-handle IN adm-broker-hdl
            (INPUT THIS-PROCEDURE, 'GROUP-ASSIGN-TARGET':U, OUTPUT group-link)
                NO-ERROR.
        IF LOOKUP(STRING(p-issuer-hdl), group-link) EQ 0 THEN
          br_table:SENSITIVE IN FRAME F-Main = no.
      END.
    WHEN "update-complete":U THEN DO:
        br_table:SENSITIVE IN FRAME F-Main = yes.
        adm-brs-in-update = no.
        RUN get-attribute IN p-issuer-hdl ('QUERY-OBJECT':U).
        IF RETURN-VALUE NE "YES":U THEN
        DO:
          IF NUM-RESULTS("br_table":U) NE ? AND
             NUM-RESULTS("br_table":U) NE 0
          THEN DO:
            GET CURRENT br_table.
            RUN dispatch ('row-changed':U).
          END.
        END.
        RUN new-state ('update-complete':U).
    END.
    WHEN "delete-complete":U THEN DO:
       DEFINE VARIABLE sts AS LOGICAL NO-UNDO.
       sts = br_table:DELETE-CURRENT-ROW() IN FRAME F-Main.
       IF NUM-RESULTS("br_table":U) = 0 THEN
         RUN notify('row-available':U).
    END.
    WHEN   'first-record':U        OR
      WHEN 'last-record':U         OR
      WHEN 'only-record':U         OR
      WHEN 'not-first-or-last':U   OR
      WHEN 'no-record-available':U OR
      WHEN 'no-external-record-available':U THEN
        RUN set-attribute-list('Query-Position=':U + p-state).
  END CASE.
  Apply "VALUE-CHANGED" to br_table in frame F-Main.
END PROCEDURE.
