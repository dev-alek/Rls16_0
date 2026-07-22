block-level on error undo, throw.
define input parameter x-store-code like ub.clients.obj-code no-undo.
define input parameter x-store-type like ub.clients.obj-type no-undo.
define input parameter x-base-type  like ub.currency.curr-abbr no-undo.
define input parameter x-base-code  like ub.currency.curr-code no-undo.
define input parameter classify  as int no-undo.
define input parameter Itog as logical no-undo .
define input parameter show-zero as logical no-undo .
define input parameter sorttype as character no-undo .
define input  parameter p-show-qnty as logical   no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Отчет Запасы по признакам".
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
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-cntxt-host-code-obj
  ,output base-code
  )  .
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure cur-time :
   define output parameter p-today as date      no-undo .
   define output parameter p-time  as integer   no-undo .
  do
  on error undo, return error
  :
    define variable v-date1 as date      no-undo .
    define variable v-date2 as date      no-undo .
    define variable v-time  as integer   no-undo .
    assign
      v-date1 = today
      v-time  = time
      v-date2 = today
    .
    if v-date1 <> v-date2
    then do:
      assign
        v-date1 = today
        v-time  = v-time
      .
    end.
    assign
      p-today = v-date1
      p-time  = v-time
    .
  end.
end.
function cur-time-date returns character
:
  return string(today, '99/99/9999':U) .
end.
function cur-time-mjd returns decimal
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return integer(v-date) - 2400002 + (v-time / 86400) .
end.
function cur-time-get-ending-index returns integer
(input p-number as integer
)
:
  if p-number < 0
  or p-number = ?
  then do:
    return 1 .
  end.
  define variable v-rest as integer   no-undo .
  assign
    p-number = p-number modulo 100
  .
  if p-number < 20
  then do:
    assign
      v-rest = p-number
    .
  end.
  else do:
    assign
      v-rest = p-number modulo 10
    .
  end.
  case v-rest :
    when 1
    then do:
      return 2 .
    end.
    when 2 or
    when 3 or
    when 4
    then do:
      return 3 .
    end.
    otherwise do:
      return 1 .
    end.
  end case .
end.
procedure cur-time-mjd-to-date :
   define input  parameter i-mjd-diff as decimal no-undo.
   define output parameter o-Date     as date    no-undo.
   define output parameter o-Time     as integer no-undo.
   define variable v-day-number as integer   no-undo .
   if    i-mjd-diff < 0
      or i-mjd-diff = ?
   then do:
      return "?" .
   end.
   assign
      v-day-number = truncate(i-mjd-diff,0).
      o-Date = date(v-day-number + 2400002).
      o-Time = truncate((i-mjd-diff - v-day-number) * 86400, 0)
  .
end.
function cur-time-mjd-to-string returns character
(input p-mjd-diff as decimal
)
:
  define variable v-day-number as integer   no-undo .
  define variable v-seconds    as integer   no-undo .
  define variable v-hour       as integer   no-undo .
  define variable v-min        as integer   no-undo .
  define variable v-day-name    as character no-undo extent 3 initial [   "дней",    "день",     "дня" ] .
  define variable v-hour-name   as character no-undo extent 3 initial [  "часов",     "час",    "часа" ] .
  define variable v-min-name    as character no-undo extent 3 initial [  "минут",  "минута",  "минуты" ] .
  define variable v-second-name as character no-undo extent 3 initial [ "секунд", "секунда", "секунды" ] .
  if p-mjd-diff < 0
  or p-mjd-diff = ?
  then do:
    return "?" .
  end.
  assign
    v-day-number = integer(truncate(p-mjd-diff,0))
    v-seconds    = truncate((p-mjd-diff - v-day-number) * 86400, 0)
  .
  if v-seconds > 86400
  then do:
    assign
      v-seconds = 86400 - 1
    .
  end.
  if v-seconds < 0
  then do:
    assign
      v-seconds = 0
    .
  end.
  assign
    v-hour = truncate(v-seconds / 3600, 0)
  .
  assign
    v-seconds = v-seconds modulo 3600
  .
  assign
    v-min = truncate(v-seconds / 60, 0)
  .
  assign
    v-seconds = v-seconds modulo 60
  .
  return
      (if v-day-number <> 0
        then string(v-day-number) + " " + v-day-name[cur-time-get-ending-index(v-day-number)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0
        then string(v-hour) + " " + v-hour-name[cur-time-get-ending-index(v-hour)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0 or v-min <> 0
        then string(v-min) + " " + v-min-name[cur-time-get-ending-index(v-min)] + " "
        else ""
      )
    + string(v-seconds) + " " + v-second-name[cur-time-get-ending-index(v-seconds)]
    .
end.
function cur-time-string returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM':U) .
end.
function cur-time-string-sec returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM:SS':U) .
end.
function cur-time-custom  returns character
(input p-prefix as character
,input p-date-format as character
,input p-delimiter as character
,input p-time-format as character
,input p-suffix as character
)
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return
    p-prefix
    + string(v-date, p-date-format)
    + p-delimiter
    + string(v-time, p-time-format)
    + p-suffix
    .
end.
function cur-time-print  returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return "Дата печати : " + string(v-date, '99.99.9999':U) + ' , ':U + string(v-time, 'HH:MM':U) .
end.
function cur-time-datetime returns datetime
:
  define variable v-char as character no-undo .
  define variable v-datetime as datetime no-undo .
  v-char = cur-time-string().
  v-datetime = datetime(v-char).
  return  v-datetime.
end.
function cur-time-string-msec returns character
:
  define variable v-date as datetime  no-undo .
  v-date = now.
  return string(v-date) .
end.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define temp-table temp-font no-undo
  field fontnum  as integer
  field fontname as character
  field fontsize as character
  field fonttype as character
  field font-h   as integer
  field font-w   as integer
  field v-row    as integer
  field v-col    as integer
  field v-row-lans as integer
  field v-col-lans as integer
index pi fontnum
.
procedure get-font-ini :
  do
  on error undo, return error return-value
  :
define variable ii as integer   no-undo .
define variable v-font7 as character no-undo .
define variable v-font as character no-undo .
define variable loc-name as character no-undo .
define variable loc-size as character no-undo .
define variable loc-type as character no-undo .
define variable old_H as integer   no-undo .
define variable old_w as integer   no-undo .
define variable old-row  as integer   no-undo .
define variable old-col  as integer   no-undo .
define variable old-row-lans  as integer   no-undo .
define variable old-col-lans  as integer   no-undo .
define variable vv as integer   no-undo .
empty temp-table temp-font.
  GET-KEY-VALUE SECTION "fonts" KEY "font7" VALUE v-font7 .
    case num-entries (v-font7) :
      when 4 then do:
          assign
            loc-name = entry ( 1 , v-font7 )
            loc-size = entry ( 2 , v-font7 )
            loc-type = entry ( 3 , v-font7 ) + "," +  entry ( 4 , v-font7 )
          .
      end.
      when 3 then do:
          assign
            loc-name = entry ( 1 , v-font7 )
            loc-size = entry ( 2 , v-font7 )
            loc-type = entry ( 3 , v-font7 )
          .
      end.
      when 2 then  do:
          assign
            loc-name = entry ( 1 , v-font7 )
            loc-size = entry ( 2 , v-font7 )
            loc-type = ""
          .
      end.
      when 1 then do:
          assign
            loc-name = trim(entry ( 1 , v-font7 ))
            loc-size = ""
            loc-type = ""
          .
      end.
    end case.
  create temp-font.
  assign
    temp-font.fontnum  = 7
    temp-font.fontname = trim(loc-name)
    temp-font.fontsize = trim(loc-size)
    temp-font.fonttype = trim(loc-type)
    temp-font.v-row    = 62
    temp-font.v-col    = 136
    temp-font.v-row-lans = 43
    temp-font.v-col-lans = 198
  .
  repeat ii = 16 to 100 :
    get-key-value section 'fonts' key 'font' + string(ii)   value v-font  .
    if v-font = "" or v-font = ? then leave.
    case num-entries (v-font) :
      when 4 then do:
          assign
            loc-name = entry ( 1 , v-font )
            loc-size = entry ( 2 , v-font )
            loc-type = entry ( 3 , v-font ) + "," +  entry ( 4 , v-font )
          .
      end.
      when 3 then do:
          assign
            loc-name = entry ( 1 , v-font )
            loc-size = entry ( 2 , v-font )
            loc-type = entry ( 3 , v-font )
          .
      end.
      when 2 then do:
          assign
            loc-name = entry ( 1 , v-font )
            loc-size = entry ( 2 , v-font )
            loc-type = ""
          .
      end.
      when 1 then do:
          assign
            loc-name = trim(entry ( 1 , v-font ))
            loc-size = ""
            loc-type = ""
          .
      end.
    end case.
  create temp-font.
  assign
    temp-font.fontnum  = ii
    temp-font.fontname = trim(loc-name)
    temp-font.fontsize = trim(loc-size)
    temp-font.fonttype = trim(loc-type)
  .
  end.
    for each temp-font :
       vv = integer(entry(2,temp-font.fontsize, "=" )) no-error .
       if  vv = ? then vv =  0 .
        run rep/exfont.p (
          input   temp-font.fontname ,
          input   vv ,
          input   temp-font.fonttype ,
          output  temp-font.font-h   ,
          output  temp-font.font-w   )
        .
    end.
find first temp-font where  temp-font.fontnum  = 7  .
old_H = temp-font.font-H .
old_w = temp-font.font-W .
old-row = temp-font.v-row .
old-col = temp-font.v-col .
old-row-lans = temp-font.v-row-lans .
old-col-lans = temp-font.v-col-lans .
    for each temp-font where
             temp-font.fontnum  <> 7 :
        assign
            temp-font.v-row    = old_H * old-row / temp-font.font-h
            temp-font.v-col    = old_W * old-col / temp-font.font-W
            temp-font.v-row-lans    = old_H * old-row-lans / temp-font.font-h
            temp-font.v-col-lans    = old_W * old-col-lans / temp-font.font-W
        .
    end.
  end.
end procedure.
PROCEDURE How-name :
define input  parameter h as integer no-undo .
define input  parameter w as integer no-undo .
define output parameter n as character  no-undo .
define variable A4port-H as integer   no-undo init 63.
define variable A4port-W as integer   no-undo init 136.
define variable A4lans-H as integer   no-undo init 43.
define variable A4lans-W as integer   no-undo init 198.
define variable Strim-W  as integer   no-undo init 278.
run define-a4-size (
     input ReportFontNum
    ,output A4port-H
    ,output A4port-W
    ,output A4lans-H
    ,output A4lans-W ).
If w >= 1 and w <= A4port-W Then DO:
  If h >= 1  and h <= A4lans-H Then n = "A4-lans":U.
  If h > A4lans-H  and h <= A4port-H Then n = "A4-port":U.
  If h > A4port-H              Then n = "to-file":U.
End.
If w > A4port-W and w <= A4lans-W Then DO:
  If h >= 1  and h <= A4lans-H Then n = "A4-lans":U.
  If h > A4lans-H  and h <= A4port-H Then n = "A3-lans":U.
  If h > A4port-H              Then n = "to-file":U.
End.
If w > A4lans-W and w <= Strim-W Then DO:
  If h >= 1  and h <= A4lans-H Then n = "to-file":U.
  If h > A4lans-H  and h <= A4port-H Then n = "A3-lans":U.
  If h > A4port-H              Then n = "to-file":U.
End.
If w > Strim-W Then DO:
   n = "to-file":U.
End.
END PROCEDURE.
PROCEDURE define-a4-size :
define input  parameter p-ReportFontNum as integer   no-undo .
define output parameter A4port-H as integer   no-undo .
define output parameter A4port-W as integer   no-undo .
define output parameter A4lans-H as integer   no-undo .
define output parameter A4lans-W as integer   no-undo .
if not can-find (first temp-font ) then do:
   run get-font-ini .
end.
find first temp-font where temp-font.fontnum = p-ReportFontNum no-error .
if available temp-font then do:
assign
  A4port-H = temp-font.v-row
  A4port-W = temp-font.v-col
  A4lans-H = temp-font.v-row-lans
  A4lans-W = temp-font.v-col-lans
.
end.
else do:
assign
  A4port-H = 63
  A4port-W = 136
  A4lans-H = 43
  A4lans-W = 198
.
end.
END PROCEDURE.
function func-vat returns decimal (
    input p-gds-code as integer  ,
    input p-obj-type as character ,
    input p-obj-code as integer  ).
define variable i-vat-pc as decimal no-undo .
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define buffer clients-p for ub.clients .
define buffer alt-ot-line for ub.ot-line .
define buffer crsa-ot-line for ub.ot-line .
define  shared temp-table alt-obj-list  NO-UNDO
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    .
define variable F-fact-date      as char no-undo.
define variable sss as integer no-undo .
define variable  Fact-order-1 like ub.stk-tot.Fact-order no-undo.
define variable  Quantity1    like ub.stk-tot.fact-qnty  no-undo.
define variable  Coast1       like ub.stk-tot.sum-rubl   no-undo.
define variable  Coast_R1       like ub.stk-tot.sum-rubl   no-undo.
define variable  Coast_V1       like ub.stk-tot.sum-rubl   no-undo.
define variable  VAT_R1         like ub.stk-tot.sum-rubl   no-undo.
define variable  VAT_V1         like ub.stk-tot.sum-rubl   no-undo.
define variable  Coast_R2       like ub.stk-tot.sum-rubl   no-undo.
define variable  Coast_V2       like ub.stk-tot.sum-rubl   no-undo.
define variable  VAT_R2         like ub.stk-tot.sum-rubl   no-undo.
define variable  VAT_V2         like ub.stk-tot.sum-rubl   no-undo.
define variable  Fact-order-2 like ub.stk-tot.Fact-order no-undo.
define variable  Quantity2    like ub.stk-tot.fact-qnty  no-undo.
define variable  Coast2       like ub.stk-tot.sum-rubl   no-undo.
define variable  Quantity    like ub.stk-tot.fact-qnty  no-undo.
define variable  Coast       like ub.stk-tot.sum-rubl   no-undo.
define variable  Quantity3    like ub.stk-tot.fact-qnty  no-undo.
define variable  Coast5       like ub.stk-tot.sum-rubl   no-undo.
define variable  Coast6       like ub.stk-tot.sum-rubl   no-undo.
define variable  Coast3         like ub.stk-tot.sum-rubl   no-undo.
define variable  Coast4         like ub.stk-tot.sum-rubl   no-undo.
define variable  find-str       as char no-undo.
define variable  temp-find-str  like find-str NO-UNDO.
define variable  tPrintRubl    as log no-undo .
define variable  startdate     as date no-undo.
define variable  enddate       as date no-undo.
define variable xTog-obj as logical no-undo init true .
define  stream  OutStream .
define variable    ObjName           as char no-undo.
define variable    PayType           as   integer no-undo.
define variable    ValType           as   integer no-undo.
define variable    Line              as  char     no-undo.
define variable tot_tqnty as decimal format "->>>,>>>,>>9.99" no-undo.
define variable break_group as logical no-undo init true.
define variable break_group1 as logical no-undo init true.
define variable    iI        as   integer no-undo.
define variable    i         as   integer no-undo .
define variable    j         as   integer no-undo.
define variable    K         as   integer no-undo.
define variable stat     as log no-undo .
define variable InpError as log no-undo .
define variable rid-list as character no-undo .
define variable curr-rep as char no-undo.
define variable listtd as char no-undo.
define variable NO-PRISE as logical no-undo  init true .
define variable Discnt-base# as decimal init 0  no-undo .
define variable n-nn as integer init 0 no-undo .
define variable n-nm as integer init 0 no-undo .
define variable n-no as integer init 0 no-undo .
define variable var-client as character no-undo .
define variable  Prtroot        like ub.gds-prt.node-code no-undo.
define variable    nn              as character no-undo .
define variable    f-artic         as character no-undo .
define variable    f-b-code        as character no-undo .
define variable    f-gds-name      as character no-undo .
define variable    f-prt-name      as character no-undo .
define variable    f-qnty          as decimal no-undo .
define variable    f-cost-sum      as decimal no-undo .
define variable    f-sale-sum      as decimal no-undo .
define variable    f-sale-other    as decimal no-undo .
define variable    f-qnty-alt          as decimal no-undo .
define variable    f-cost-sum-alt      as decimal no-undo .
define variable    f-sale-sum-alt      as decimal no-undo .
define variable    f-sale-other-alt    as decimal no-undo .
define variable    c-nn             as WIDGET-HANDLE no-undo .
define variable    c-f-artic        as WIDGET-HANDLE no-undo .
define variable    c-f-b-code       as WIDGET-HANDLE no-undo .
define variable    c-f-gds-name     as WIDGET-HANDLE no-undo .
define variable    c-f-prt-name     as WIDGET-HANDLE no-undo .
define variable    c-f-qnty         as WIDGET-HANDLE no-undo .
define variable    c-f-cost-sum     as WIDGET-HANDLE no-undo .
define variable    c-f-sale-sum     as WIDGET-HANDLE no-undo .
define variable    c-f-sale-other   as WIDGET-HANDLE no-undo .
define variable    c-f-qnty-alt         as WIDGET-HANDLE no-undo .
define variable    c-f-cost-sum-alt     as WIDGET-HANDLE no-undo .
define variable    c-f-sale-sum-alt     as WIDGET-HANDLE no-undo .
define variable    c-f-sale-other-alt   as WIDGET-HANDLE no-undo .
define variable    p-qnty          as decimal no-undo .
define variable    p-cost-sum      as decimal no-undo .
define variable    p-sale-sum      as decimal no-undo .
define variable    p-sale-other    as decimal no-undo .
define variable    p-qnty-alt          as decimal no-undo .
define variable    p-cost-sum-alt      as decimal no-undo .
define variable    p-sale-sum-alt      as decimal no-undo .
define variable    p-sale-other-alt    as decimal no-undo .
define variable    l1f-artic       as character no-undo .
define variable    l1f-b-code      as character no-undo .
define variable    l1f-gds-name    as character no-undo .
define variable    l1f-prt-name    as character no-undo .
define variable    l1f-qnty        as character no-undo .
define variable    l1f-cost-sum    as character no-undo .
define variable    l1f-sale-sum    as character no-undo .
define variable    l1f-sale-other  as character no-undo .
define variable    l1f-qnty-alt        as character no-undo .
define variable    l1f-cost-sum-alt    as character no-undo .
define variable    l1f-sale-sum-alt    as character no-undo .
define variable    l1f-sale-other-alt  as character no-undo .
define variable    l2f-artic         as character no-undo .
define variable    l2f-b-code        as character no-undo .
define variable    l2f-gds-name      as character no-undo .
define variable    l2f-prt-name      as character no-undo .
define variable    l2f-qnty          as character no-undo .
define variable    l2f-cost-sum      as character no-undo .
define variable    l2f-sale-sum      as character no-undo .
define variable    l2f-sale-other    as character no-undo .
define variable    l2f-qnty-alt          as character no-undo .
define variable    l2f-cost-sum-alt    as character no-undo .
define variable    l2f-sale-sum-alt    as character no-undo .
define variable    l2f-sale-other-alt  as character no-undo .
define variable    ff-f-qnty         as decimal no-undo .
define variable    ff-f-cost-sum     as decimal no-undo .
define variable    ff-f-sale-sum     as decimal no-undo .
define variable    ff-f-sale-other   as decimal no-undo .
define variable    ff-f-qnty-alt         as decimal no-undo .
define variable    ff-f-cost-sum-alt     as decimal no-undo .
define variable    ff-f-sale-sum-alt     as decimal no-undo .
define variable    ff-f-sale-other-alt   as decimal no-undo .
define variable    tf-f-qnty        as decimal no-undo .
define variable    tf-f-cost-sum    as decimal no-undo .
define variable    tf-f-sale-sum     as decimal no-undo .
define variable    tf-f-sale-other   as decimal no-undo .
define variable    tf-f-qnty-alt        as decimal no-undo .
define variable    tf-f-cost-sum-alt    as decimal no-undo .
define variable    tf-f-sale-sum-alt     as decimal no-undo .
define variable    tf-f-sale-other-alt   as decimal no-undo .
define variable x-time as integer no-undo .
define variable fix-doc-code  like ub.ot-tot.doc-code no-undo .
def  var l-col-type         as character no-undo .
def  var l-col-pos          as integer no-undo .
def  var l-row-pos           as integer no-undo init 1.
def  var l-col-len          as integer no-undo .
def  var l-col-format       as character no-undo .
def  var l-col-lable        as character no-undo .
DEFINE VARIABLE t-1 AS CHARACTER INITIAL "||||"
     VIEW-AS EDITOR
     SIZE 1 BY 6 NO-UNDO.
DEFINE FRAME top-frame
    t-1       AT ROW 1 COL 1 no-label
    HEADER
        cur-time-print() AT 5 format "X(35)"
        "Цены указаны в" (if tPrintRubl then "РУБ" else x-base-type )
        string( "Страница " + string( PAGE-NUMBER( OutStream ), ">>>>>>9") ) AT 110 format "X(16)" SKIP
     WITH 300 DOWN stream-io
         NO-UNDERLINE use-text NO-BOX no-label
         AT COL 1 ROW 1
         SIZE 300 BY 35  .
DEFINE FRAME zapas
   with width 300 down stream-io use-text NO-BOX no-label.
run cur-time in this-procedure ( output x-Date-End
                               , output x-time
                               ).
x-Date-Start   = x-date-alone.
find last ub.ot-tot  no-lock use-index pi .
if avail  ub.ot-tot then fix-doc-code = ub.ot-tot.doc-code .
                 else fix-doc-code = "" .
CREATE WIDGET-POOL "My-pool" PERSISTENT no-error .
l-row-pos = 3.
l-col-pos = 1.
Assign l-col-type="CHARACTER" l-col-len=9  l-col-format= "X(9)"         l-col-lable="N/N"                      .
  def var ed1 as handle .
  def var s1 as handle .
  def var sf1 as handle .
  def var l-1 as handle .
  def var ll-1 as handle .
  if l-row-pos = 0 then l-row-pos = 1.
  if use-column[1] = true then DO:
        CREATE EDITOR LL-1 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR ed1 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW =  l-row-pos + 1
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR L-1 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos + 3
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE FILL-IN C-nn IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME zapas:HANDLE
            DATA-TYPE = l-col-type
            FORMAT = l-col-format
            ROW = 1
            WIDTH-CHARS = l-col-len
            COLUMN = l-col-pos
        .
         if  (l-col-pos + l-col-len) <= 320 THEN DO:
        CREATE EDITOR s1 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos
            COLUMN = (l-col-pos + l-col-len)
            screen-value = "::::"
            WIDTH-CHARS = 1
            HEIGHT-CHARS = 5
        .
        CREATE EDITOR sf1 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME zapas:HANDLE
            ROW = 1
            Screen-value = ":"
            WIDTH-CHARS = 1
            COLUMN = l-col-pos + l-col-len
         .
           End.
        l-col-pos =  l-col-pos + l-col-len + 1.
   End .
Assign l-col-type="CHARACTER" l-col-len=10 l-col-format= "X(10)"        l-col-lable="Код"                      .
  def var ed2 as handle .
  def var s2 as handle .
  def var sf2 as handle .
  def var l-2 as handle .
  def var ll-2 as handle .
  if l-row-pos = 0 then l-row-pos = 1.
  if use-column[2] = true then DO:
        CREATE EDITOR LL-2 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR ed2 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW =  l-row-pos + 1
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR L-2 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos + 3
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE FILL-IN C-f-b-code IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME zapas:HANDLE
            DATA-TYPE = l-col-type
            FORMAT = l-col-format
            ROW = 1
            WIDTH-CHARS = l-col-len
            COLUMN = l-col-pos
        .
         if  (l-col-pos + l-col-len) <= 320 THEN DO:
        CREATE EDITOR s2 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos
            COLUMN = (l-col-pos + l-col-len)
            screen-value = "::::"
            WIDTH-CHARS = 1
            HEIGHT-CHARS = 5
        .
        CREATE EDITOR sf2 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME zapas:HANDLE
            ROW = 1
            Screen-value = ":"
            WIDTH-CHARS = 1
            COLUMN = l-col-pos + l-col-len
         .
           End.
        l-col-pos =  l-col-pos + l-col-len + 1.
   End .
Assign l-col-type="CHARACTER" l-col-len=16 l-col-format= "X(16)"        l-col-lable="Артикул"                  .
  def var ed3 as handle .
  def var s3 as handle .
  def var sf3 as handle .
  def var l-3 as handle .
  def var ll-3 as handle .
  if l-row-pos = 0 then l-row-pos = 1.
  if use-column[3] = true then DO:
        CREATE EDITOR LL-3 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR ed3 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW =  l-row-pos + 1
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR L-3 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos + 3
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE FILL-IN C-f-artic IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME zapas:HANDLE
            DATA-TYPE = l-col-type
            FORMAT = l-col-format
            ROW = 1
            WIDTH-CHARS = l-col-len
            COLUMN = l-col-pos
        .
         if  (l-col-pos + l-col-len) <= 320 THEN DO:
        CREATE EDITOR s3 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos
            COLUMN = (l-col-pos + l-col-len)
            screen-value = "::::"
            WIDTH-CHARS = 1
            HEIGHT-CHARS = 5
        .
        CREATE EDITOR sf3 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME zapas:HANDLE
            ROW = 1
            Screen-value = ":"
            WIDTH-CHARS = 1
            COLUMN = l-col-pos + l-col-len
         .
           End.
        l-col-pos =  l-col-pos + l-col-len + 1.
   End .
Assign l-col-type="CHARACTER" l-col-len=40 l-col-format= "X(40)"        l-col-lable="Название товара"          .
  def var ed4 as handle .
  def var s4 as handle .
  def var sf4 as handle .
  def var l-4 as handle .
  def var ll-4 as handle .
  if l-row-pos = 0 then l-row-pos = 1.
  if use-column[4] = true then DO:
        CREATE EDITOR LL-4 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR ed4 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW =  l-row-pos + 1
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR L-4 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos + 3
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE FILL-IN C-f-gds-name IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME zapas:HANDLE
            DATA-TYPE = l-col-type
            FORMAT = l-col-format
            ROW = 1
            WIDTH-CHARS = l-col-len
            COLUMN = l-col-pos
        .
         if  (l-col-pos + l-col-len) <= 320 THEN DO:
        CREATE EDITOR s4 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos
            COLUMN = (l-col-pos + l-col-len)
            screen-value = "::::"
            WIDTH-CHARS = 1
            HEIGHT-CHARS = 5
        .
        CREATE EDITOR sf4 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME zapas:HANDLE
            ROW = 1
            Screen-value = ":"
            WIDTH-CHARS = 1
            COLUMN = l-col-pos + l-col-len
         .
           End.
        l-col-pos =  l-col-pos + l-col-len + 1.
   End .
Assign l-col-type="CHARACTER" l-col-len=20 l-col-format= "X(20)"        l-col-lable="Признак"                  .
  def var ed5 as handle .
  def var s5 as handle .
  def var sf5 as handle .
  def var l-5 as handle .
  def var ll-5 as handle .
  if l-row-pos = 0 then l-row-pos = 1.
  if use-column[5] = true then DO:
        CREATE EDITOR LL-5 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR ed5 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW =  l-row-pos + 1
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR L-5 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos + 3
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE FILL-IN C-f-prt-name IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME zapas:HANDLE
            DATA-TYPE = l-col-type
            FORMAT = l-col-format
            ROW = 1
            WIDTH-CHARS = l-col-len
            COLUMN = l-col-pos
        .
         if  (l-col-pos + l-col-len) <= 320 THEN DO:
        CREATE EDITOR s5 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos
            COLUMN = (l-col-pos + l-col-len)
            screen-value = "::::"
            WIDTH-CHARS = 1
            HEIGHT-CHARS = 5
        .
        CREATE EDITOR sf5 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME zapas:HANDLE
            ROW = 1
            Screen-value = ":"
            WIDTH-CHARS = 1
            COLUMN = l-col-pos + l-col-len
         .
           End.
        l-col-pos =  l-col-pos + l-col-len + 1.
   End .
Assign l-col-type="DECIMAL"   l-col-len=12 l-col-format="->>>>>>>>>9.<<<" l-col-lable="Количество "           .
  def var ed6 as handle .
  def var s6 as handle .
  def var sf6 as handle .
  def var l-6 as handle .
  def var ll-6 as handle .
  if l-row-pos = 0 then l-row-pos = 1.
  if use-column[6] = true then DO:
        CREATE EDITOR LL-6 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR ed6 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW =  l-row-pos + 1
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR L-6 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos + 3
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE FILL-IN C-f-qnty IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME zapas:HANDLE
            DATA-TYPE = l-col-type
            FORMAT = l-col-format
            ROW = 1
            WIDTH-CHARS = l-col-len
            COLUMN = l-col-pos
        .
         if  (l-col-pos + l-col-len) <= 320 THEN DO:
        CREATE EDITOR s6 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos
            COLUMN = (l-col-pos + l-col-len)
            screen-value = "::::"
            WIDTH-CHARS = 1
            HEIGHT-CHARS = 5
        .
        CREATE EDITOR sf6 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME zapas:HANDLE
            ROW = 1
            Screen-value = ":"
            WIDTH-CHARS = 1
            COLUMN = l-col-pos + l-col-len
         .
           End.
        l-col-pos =  l-col-pos + l-col-len + 1.
   End .
Assign l-col-type="DECIMAL"   l-col-len=13 l-col-format="->>>>>>>>>>9.<<"  l-col-lable="Сумма в учетных ценах"   .
  def var ed7 as handle .
  def var s7 as handle .
  def var sf7 as handle .
  def var l-7 as handle .
  def var ll-7 as handle .
  if l-row-pos = 0 then l-row-pos = 1.
  if use-column[7] = true then DO:
        CREATE EDITOR LL-7 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR ed7 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW =  l-row-pos + 1
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR L-7 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos + 3
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE FILL-IN C-f-cost-sum IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME zapas:HANDLE
            DATA-TYPE = l-col-type
            FORMAT = l-col-format
            ROW = 1
            WIDTH-CHARS = l-col-len
            COLUMN = l-col-pos
        .
         if  (l-col-pos + l-col-len) <= 320 THEN DO:
        CREATE EDITOR s7 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos
            COLUMN = (l-col-pos + l-col-len)
            screen-value = "::::"
            WIDTH-CHARS = 1
            HEIGHT-CHARS = 5
        .
        CREATE EDITOR sf7 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME zapas:HANDLE
            ROW = 1
            Screen-value = ":"
            WIDTH-CHARS = 1
            COLUMN = l-col-pos + l-col-len
         .
           End.
        l-col-pos =  l-col-pos + l-col-len + 1.
   End .
Assign l-col-type="DECIMAL"   l-col-len=13 l-col-format="->>>>>>>>>>9.<<"  l-col-lable="Сумма в продажных ценах" .
  def var ed8 as handle .
  def var s8 as handle .
  def var sf8 as handle .
  def var l-8 as handle .
  def var ll-8 as handle .
  if l-row-pos = 0 then l-row-pos = 1.
  if use-column[8] = true then DO:
        CREATE EDITOR LL-8 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR ed8 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW =  l-row-pos + 1
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR L-8 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos + 3
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE FILL-IN C-f-sale-sum IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME zapas:HANDLE
            DATA-TYPE = l-col-type
            FORMAT = l-col-format
            ROW = 1
            WIDTH-CHARS = l-col-len
            COLUMN = l-col-pos
        .
         if  (l-col-pos + l-col-len) <= 320 THEN DO:
        CREATE EDITOR s8 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos
            COLUMN = (l-col-pos + l-col-len)
            screen-value = "::::"
            WIDTH-CHARS = 1
            HEIGHT-CHARS = 5
        .
        CREATE EDITOR sf8 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME zapas:HANDLE
            ROW = 1
            Screen-value = ":"
            WIDTH-CHARS = 1
            COLUMN = l-col-pos + l-col-len
         .
           End.
        l-col-pos =  l-col-pos + l-col-len + 1.
   End .
Assign l-col-type="DECIMAL"   l-col-len=7 l-col-format="->>>>9.<<"         l-col-lable="% наценки"               .
  def var ed9 as handle .
  def var s9 as handle .
  def var sf9 as handle .
  def var l-9 as handle .
  def var ll-9 as handle .
  if l-row-pos = 0 then l-row-pos = 1.
  if use-column[9] = true then DO:
        CREATE EDITOR LL-9 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR ed9 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW =  l-row-pos + 1
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR L-9 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos + 3
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE FILL-IN C-f-sale-other IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME zapas:HANDLE
            DATA-TYPE = l-col-type
            FORMAT = l-col-format
            ROW = 1
            WIDTH-CHARS = l-col-len
            COLUMN = l-col-pos
        .
         if  (l-col-pos + l-col-len) <= 320 THEN DO:
        CREATE EDITOR s9 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos
            COLUMN = (l-col-pos + l-col-len)
            screen-value = "::::"
            WIDTH-CHARS = 1
            HEIGHT-CHARS = 5
        .
        CREATE EDITOR sf9 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME zapas:HANDLE
            ROW = 1
            Screen-value = ":"
            WIDTH-CHARS = 1
            COLUMN = l-col-pos + l-col-len
         .
           End.
        l-col-pos =  l-col-pos + l-col-len + 1.
   End .
Assign l-col-type="DECIMAL"   l-col-len=12 l-col-format="->>>>>>>>>9.<<<"  l-col-lable="Количество "           .
  def var ed10 as handle .
  def var s10 as handle .
  def var sf10 as handle .
  def var l-10 as handle .
  def var ll-10 as handle .
  if l-row-pos = 0 then l-row-pos = 1.
  if use-column[10] = true then DO:
        CREATE EDITOR LL-10 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR ed10 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW =  l-row-pos + 1
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR L-10 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos + 3
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE FILL-IN C-f-qnty-alt IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME zapas:HANDLE
            DATA-TYPE = l-col-type
            FORMAT = l-col-format
            ROW = 1
            WIDTH-CHARS = l-col-len
            COLUMN = l-col-pos
        .
         if  (l-col-pos + l-col-len) <= 320 THEN DO:
        CREATE EDITOR s10 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos
            COLUMN = (l-col-pos + l-col-len)
            screen-value = "::::"
            WIDTH-CHARS = 1
            HEIGHT-CHARS = 5
        .
        CREATE EDITOR sf10 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME zapas:HANDLE
            ROW = 1
            Screen-value = ":"
            WIDTH-CHARS = 1
            COLUMN = l-col-pos + l-col-len
         .
           End.
        l-col-pos =  l-col-pos + l-col-len + 1.
   End .
Assign l-col-type="DECIMAL"   l-col-len=13 l-col-format="->>>>>>>>>>9.<<"  l-col-lable="Сумма в учетных ценах"   .
  def var ed11 as handle .
  def var s11 as handle .
  def var sf11 as handle .
  def var l-11 as handle .
  def var ll-11 as handle .
  if l-row-pos = 0 then l-row-pos = 1.
  if use-column[11] = true then DO:
        CREATE EDITOR LL-11 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR ed11 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW =  l-row-pos + 1
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR L-11 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos + 3
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE FILL-IN C-f-cost-sum-alt IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME zapas:HANDLE
            DATA-TYPE = l-col-type
            FORMAT = l-col-format
            ROW = 1
            WIDTH-CHARS = l-col-len
            COLUMN = l-col-pos
        .
         if  (l-col-pos + l-col-len) <= 320 THEN DO:
        CREATE EDITOR s11 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos
            COLUMN = (l-col-pos + l-col-len)
            screen-value = "::::"
            WIDTH-CHARS = 1
            HEIGHT-CHARS = 5
        .
        CREATE EDITOR sf11 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME zapas:HANDLE
            ROW = 1
            Screen-value = ":"
            WIDTH-CHARS = 1
            COLUMN = l-col-pos + l-col-len
         .
           End.
        l-col-pos =  l-col-pos + l-col-len + 1.
   End .
Assign l-col-type="DECIMAL"   l-col-len=13 l-col-format="->>>>>>>>>>9.<<"  l-col-lable="Сумма в продажных ценах" .
  def var ed12 as handle .
  def var s12 as handle .
  def var sf12 as handle .
  def var l-12 as handle .
  def var ll-12 as handle .
  if l-row-pos = 0 then l-row-pos = 1.
  if use-column[12] = true then DO:
        CREATE EDITOR LL-12 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR ed12 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW =  l-row-pos + 1
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR L-12 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos + 3
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE FILL-IN C-f-sale-sum-alt IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME zapas:HANDLE
            DATA-TYPE = l-col-type
            FORMAT = l-col-format
            ROW = 1
            WIDTH-CHARS = l-col-len
            COLUMN = l-col-pos
        .
         if  (l-col-pos + l-col-len) <= 320 THEN DO:
        CREATE EDITOR s12 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos
            COLUMN = (l-col-pos + l-col-len)
            screen-value = "::::"
            WIDTH-CHARS = 1
            HEIGHT-CHARS = 5
        .
        CREATE EDITOR sf12 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME zapas:HANDLE
            ROW = 1
            Screen-value = ":"
            WIDTH-CHARS = 1
            COLUMN = l-col-pos + l-col-len
         .
           End.
        l-col-pos =  l-col-pos + l-col-len + 1.
   End .
Assign l-col-type="DECIMAL"   l-col-len=7 l-col-format="->>>>9.<<"         l-col-lable="% наценки"               .
  def var ed13 as handle .
  def var s13 as handle .
  def var sf13 as handle .
  def var l-13 as handle .
  def var ll-13 as handle .
  if l-row-pos = 0 then l-row-pos = 1.
  if use-column[13] = true then DO:
        CREATE EDITOR LL-13 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR ed13 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW =  l-row-pos + 1
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR L-13 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos + 3
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE FILL-IN C-f-sale-other-alt IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME zapas:HANDLE
            DATA-TYPE = l-col-type
            FORMAT = l-col-format
            ROW = 1
            WIDTH-CHARS = l-col-len
            COLUMN = l-col-pos
        .
         if  (l-col-pos + l-col-len) <= 320 THEN DO:
        CREATE EDITOR s13 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos
            COLUMN = (l-col-pos + l-col-len)
            screen-value = "::::"
            WIDTH-CHARS = 1
            HEIGHT-CHARS = 5
        .
        CREATE EDITOR sf13 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME zapas:HANDLE
            ROW = 1
            Screen-value = ":"
            WIDTH-CHARS = 1
            COLUMN = l-col-pos + l-col-len
         .
           End.
        l-col-pos =  l-col-pos + l-col-len + 1.
   End .
l-row-pos = 1.
l-col-pos = 1.
Assign l-col-type="CHARACTER"
       l-col-len= -1 +
                  (if  c-nn         <> ? then  c-nn:WIDTH-CHARS + 1    Else 0 ) +
                  (if  c-f-b-code   <> ? then  c-f-b-code:WIDTH-CHARS  + 1     Else 0 ) +
                  (if  c-f-artic    <> ? then  c-f-artic:WIDTH-CHARS  + 1      Else 0 ) +
                  (if  c-f-gds-name <> ? then  c-f-gds-name:WIDTH-CHARS + 1    Else 0 ) +
                  (if  c-f-prt-name <> ? then  c-f-prt-name:WIDTH-CHARS + 1    Else 0 )
       l-col-format= "X(" + string(l-col-len) + ")"  l-col-lable= "Товар"                .
  def var ed14 as handle .
  def var s14 as handle .
  def var ll-14 as handle .
  if l-col-len > 0 then DO:
        CREATE EDITOR LL-14 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-frame:HANDLE
            ROW = l-row-pos
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR ed14 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-frame:HANDLE
            ROW = l-row-pos + 1
            COLUMN = l-col-pos
            screen-value = fill(" ",Integer((l-col-len - LENGTH(trim(l-col-lable))) / 2))  + l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
         if  (l-col-pos + l-col-len) <= 320 THEN DO:
        CREATE EDITOR s14 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-frame:HANDLE
            ROW = l-row-pos
            COLUMN = (l-col-pos + l-col-len)
            screen-value = "::"
            WIDTH-CHARS = 1
            HEIGHT-CHARS = 3
        .
           End.
        l-col-pos =  l-col-pos + l-col-len + 1.
   End.
Assign l-col-type="CHARACTER"
       l-col-len=  -1 +
                  (if  c-f-qnty       <> ? then  c-f-qnty:WIDTH-CHARS  + 1       Else 0 ) +
                  (if  c-f-cost-sum   <> ? then  c-f-cost-sum:WIDTH-CHARS + 1    Else 0 ) +
                  (if  c-f-sale-sum   <> ? then  c-f-sale-sum:WIDTH-CHARS + 1    Else 0 ) +
                  (if  c-f-sale-other <> ? then  c-f-sale-other:WIDTH-CHARS + 1  Else 0 )
       l-col-format= "X(" + string(l-col-len) + ")"  l-col-lable= "Объект 1"   .
  def var ed15 as handle .
  def var s15 as handle .
  def var ll-15 as handle .
  if l-col-len > 0 then DO:
        CREATE EDITOR LL-15 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-frame:HANDLE
            ROW = l-row-pos
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR ed15 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-frame:HANDLE
            ROW = l-row-pos + 1
            COLUMN = l-col-pos
            screen-value = fill(" ",Integer((l-col-len - LENGTH(trim(l-col-lable))) / 2))  + l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
         if  (l-col-pos + l-col-len) <= 320 THEN DO:
        CREATE EDITOR s15 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-frame:HANDLE
            ROW = l-row-pos
            COLUMN = (l-col-pos + l-col-len)
            screen-value = "::"
            WIDTH-CHARS = 1
            HEIGHT-CHARS = 3
        .
           End.
        l-col-pos =  l-col-pos + l-col-len + 1.
   End.
Assign l-col-type="CHARACTER"
       l-col-len=  -1 +
                  (if  c-f-qnty-alt       <> ? then  c-f-qnty-alt:WIDTH-CHARS  + 1       Else 0 ) +
                  (if  c-f-cost-sum-alt   <> ? then  c-f-cost-sum-alt:WIDTH-CHARS + 1    Else 0 ) +
                  (if  c-f-sale-sum-alt   <> ? then  c-f-sale-sum-alt:WIDTH-CHARS + 1    Else 0 ) +
                  (if  c-f-sale-other-alt <> ? then  c-f-sale-other-alt:WIDTH-CHARS + 1  Else 0 )
       l-col-format= "X(" + string(l-col-len) + ")"  l-col-lable= "Объект 2"   .
  def var ed16 as handle .
  def var s16 as handle .
  def var ll-16 as handle .
  if l-col-len > 0 then DO:
        CREATE EDITOR LL-16 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-frame:HANDLE
            ROW = l-row-pos
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR ed16 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-frame:HANDLE
            ROW = l-row-pos + 1
            COLUMN = l-col-pos
            screen-value = fill(" ",Integer((l-col-len - LENGTH(trim(l-col-lable))) / 2))  + l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
         if  (l-col-pos + l-col-len) <= 320 THEN DO:
        CREATE EDITOR s16 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-frame:HANDLE
            ROW = l-row-pos
            COLUMN = (l-col-pos + l-col-len)
            screen-value = "::"
            WIDTH-CHARS = 1
            HEIGHT-CHARS = 3
        .
           End.
        l-col-pos =  l-col-pos + l-col-len + 1.
   End.
   FIND first ub.clients where x-store-type = ub.clients.obj-type AND
                            x-store-code = ub.clients.obj-code no-lock no-error.
           If available ub.clients then  ObjName = ub.clients.obj-name.
                                else  ObjName="объект не определен".
     assign
        i             = 0
        startdate     = x-date-start
        enddate       = x-date-end
        PayType       = x-SET_PAY_TYPE
        ValType       = IF (PayType = 1) Then 0  else x-SET_val_TYPE.
        Find first ub.gds-prt where ub.gds-prt.node-name = '_Пустая шкала':U no-lock no-error.
        If available  ub.gds-prt then   Prtroot = ub.gds-prt.prt-root.
                              Else   Prtroot = 0.
        run init-gds-list.
        Run report-execute.
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
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION determined RETURNS DECIMAL (INPUT parundefine-var AS DECIMAL):
   IF parundefine-var = ? THEN RETURN 0.00.
                          ELSE RETURN parundefine-var.
END FUNCTION.
FUNCTION dtm-char RETURNS CHARACTER (INPUT p-undef-char AS CHARACTER):
   IF p-undef-char = ? THEN do:
     RETURN "?".
   end.
   ELSE do:
     RETURN p-undef-char .
   end.
END FUNCTION.
PROCEDURE report-execute :
  If (ValType=0 and x-base-code=0)  Or ValType=1
                                then   assign tPrintRubl = yes .
                                else   assign tPrintRubl = no .
   NO-PRISE = true .
  if var-report-r-b = "rubl"  Then
    if  x-base-code <> 0 and ValType = 2  then NO-PRISE = false  .
  else
    if  x-base-code <> 0 and ValType = 1  then NO-PRISE = false  .
  RUN waitfram-show( 'Подождите ...' ) .
  If ReportPageHeight = 0 then ReportPageHeight = 43 .
output stream OutStream to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size  value(ReportPageHeight) .
  FORM with FRAME Zapas .
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
form header
  line format "x(198)" at 1 skip
  "Продолжение - на следующей странице" at 30 skip
  with frame bottomframe width 232 page-bottom no-labels no-box .
view stream outstream frame bottomframe .
    if ReportPageHeight > 43  then Line = fill("-", 120).
       else Line = fill("-", 198).
  Run CalcItog in this-procedure.
  Run Print-Header in this-procedure.
    CAse classify :
      when 1 then do:
        Run Foreach1 in this-procedure.
      end.
      when 2 then do:
        Run Foreach2 in this-procedure.
      end.
      when 3 then do:
        Run Foreach3 in this-procedure.
      end.
      when 4 then do:
        Run Foreach4 in this-procedure.
      end.
    End case.
  HIDE stream OutStream FRAME BottomFrame .
  Run  Print-footer in this-procedure.
  HIDE STREAM OutStream FRAME Zapas .
  HIDE   STREAM OutStream FRAME top-Frame .
  DELETE WIDGET-POOL "My-pool".
  Output stream OutStream close.
  if Make-Excel then output stream ForExcel close.
  RUN waitfram-hide .
define variable v-user-action as character no-undo .
define variable v-printed as logical   no-undo .
define variable DisabledOptions as integer   no-undo .
define variable v-orient-page as character no-undo .
run How-name in this-procedure (
    input ReportPageHeight,
    input ReportPageWidth,
    output v-orient-page )
    .
if v-orient-page = "A4-lans":U then DisabledOptions = 8 .
                               else DisabledOptions = 0 .
run gbl/prnfilen.w
  (input  ""
  ,input  DisabledOptions
  ,input  string(session :temp-directory) + "rpt" + string( g#report-num )
  ,input  ReportFontNum
  ,output v-user-action
  ,output v-printed
  ) .
END PROCEDURE.
PROCEDURE print-header :
   PUT stream OutStream  string(v-cntxt-host-name-obj +  " , " + x-store-type  +  " " + ObjName)
         AT 50 format "X(85)" SKIP(2)
         REPORTNAME
         AT 35  format "X(100)" skip.
     PUT stream OutStream   "на "  + string(x-date-start,"99/99/9999") +
         " время " +  string(x-time,"HH:MM:SS")  AT 35 format "X(160)" SKIP.
      Repeat i = 1 to NUM-ENTRIES(STR2,chr(10)) :
        if LENGTH(trim(Entry(i,STR2,chr(10)))) > 1 then  PUT stream OutStream  Entry(i,STR2,chr(10))  AT 1 format "X(120)" SKIP.
      End.
     Repeat i = 1 to NUM-ENTRIES(STR3,chr(10)) :
       if LENGTH(trim(Entry(i,STR3,chr(10)))) > 1 then PUT stream OutStream  Entry(i,STR3,chr(10))  AT 1 format "X(120)" SKIP.
     End.
     Repeat i = 1 to NUM-ENTRIES(STR4,chr(10)) :
       if LENGTH(trim(Entry(i,STR4,chr(10)))) > 1 then PUT stream OutStream  Entry(i,STR4,chr(10))  AT 1 format "X(120)" SKIP.
     End.
     Repeat i = 1 to NUM-ENTRIES(ReportHeader,chr(10)) :
       if LENGTH(trim(Entry(i,ReportHeader,chr(10)))) > 1 then PUT stream OutStream  Entry(i,ReportHeader,chr(10))  AT 1 format "X(120)" SKIP.
     End.
    i=0.
  run rep/extitle.p (1) .
    display STREAM OutStream     with frame top-Frame .
   END PROCEDURE.
PROCEDURE Print-Footer :
  define variable v-today as date      no-undo.
  define variable v-time  as integer   no-undo.
  run cur-time in this-procedure ( output v-today
                                 , output v-time
                                 ).
  PUT STREAM OutStream UNFORMATTED " Печать закончена : " + string(v-time,"HH:MM:SS") SKIP.
  PUT STREAM OutStream UNFORMATTED " За время формирования отчета были закрыты документы : " SKIP.
  for each obj-list :
      for each ub.trn-doc no-lock where
          ub.trn-doc.status_ = 'факт':U and
          ub.trn-doc.flag_= true and
          ub.trn-doc.obj-code = obj-list.obj-code and
          ub.trn-doc.obj-type = obj-list.obj-type
          by ub.trn-doc.fact-order DESCENDING :
             If ub.trn-doc.fact-order <= fact-order-2 then leave.
             PUT STREAM OutStream  UNFORMATTED ub.trn-doc.doc-code SKIP.
      end.
  end.
  PUT STREAM OutStream UNFORMATTED " ______________________________________________________" SKIP.
   run on-same-page in this-procedure (input 1) .
   END PROCEDURE.
PROCEDURE U-LINE :
define variable ff as character no-undo .
if itog = false
Then do:
ff = fill("-",40).
  if c-nn <>  ?  then do :
    c-nn:screen-value = string(ff) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-b-code <>  ?  then do :
    c-f-b-code:screen-value = string(ff) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-artic <>  ?  then do :
    c-f-artic:screen-value = string(ff) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-gds-name <>  ?  then do :
    c-f-gds-name:screen-value = string(ff) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-prt-name <>  ?  then do :
    c-f-prt-name:screen-value = string(ff) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
if c-f-qnty <>  ?  then do :
Assign
    l1f-qnty  = c-f-qnty:DATA-TYPE
    l2f-qnty  = c-f-qnty:FORMAT
    c-f-qnty:DATA-TYPE = "CHARACTER"
    c-f-qnty:FORMAT    = "x(" + string(C-f-qnty:WIDTH-CHARS) + ")"
    c-f-qnty:screen-value = string(ff)  .
End.
if c-f-cost-sum <>  ?  then do :
Assign
    l1f-cost-sum  = c-f-cost-sum:DATA-TYPE
    l2f-cost-sum  = c-f-cost-sum:FORMAT
    c-f-cost-sum:DATA-TYPE = "CHARACTER"
    c-f-cost-sum:FORMAT    = "x(" + string(C-f-cost-sum:WIDTH-CHARS) + ")"
    c-f-cost-sum:screen-value = string(ff)  .
End.
if c-f-sale-sum <>  ?  then do :
Assign
    l1f-sale-sum  = c-f-sale-sum:DATA-TYPE
    l2f-sale-sum  = c-f-sale-sum:FORMAT
    c-f-sale-sum:DATA-TYPE = "CHARACTER"
    c-f-sale-sum:FORMAT    = "x(" + string(C-f-sale-sum:WIDTH-CHARS) + ")"
    c-f-sale-sum:screen-value = string(ff)  .
End.
if c-f-sale-other <>  ?  then do :
Assign
    l1f-sale-other  = c-f-sale-other:DATA-TYPE
    l2f-sale-other  = c-f-sale-other:FORMAT
    c-f-sale-other:DATA-TYPE = "CHARACTER"
    c-f-sale-other:FORMAT    = "x(" + string(C-f-sale-other:WIDTH-CHARS) + ")"
    c-f-sale-other:screen-value = string(ff)  .
End.
if c-f-qnty-alt <>  ?  then do :
Assign
    l1f-qnty-alt  = c-f-qnty-alt:DATA-TYPE
    l2f-qnty-alt  = c-f-qnty-alt:FORMAT
    c-f-qnty-alt:DATA-TYPE = "CHARACTER"
    c-f-qnty-alt:FORMAT    = "x(" + string(C-f-qnty-alt:WIDTH-CHARS) + ")"
    c-f-qnty-alt:screen-value = string(ff)  .
End.
if c-f-cost-sum-alt <>  ?  then do :
Assign
    l1f-cost-sum-alt  = c-f-cost-sum-alt:DATA-TYPE
    l2f-cost-sum-alt  = c-f-cost-sum-alt:FORMAT
    c-f-cost-sum-alt:DATA-TYPE = "CHARACTER"
    c-f-cost-sum-alt:FORMAT    = "x(" + string(C-f-cost-sum-alt:WIDTH-CHARS) + ")"
    c-f-cost-sum-alt:screen-value = string(ff)  .
End.
if c-f-sale-sum-alt <>  ?  then do :
Assign
    l1f-sale-sum-alt  = c-f-sale-sum-alt:DATA-TYPE
    l2f-sale-sum-alt  = c-f-sale-sum-alt:FORMAT
    c-f-sale-sum-alt:DATA-TYPE = "CHARACTER"
    c-f-sale-sum-alt:FORMAT    = "x(" + string(C-f-sale-sum-alt:WIDTH-CHARS) + ")"
    c-f-sale-sum-alt:screen-value = string(ff)  .
End.
if c-f-sale-other-alt <>  ?  then do :
Assign
    l1f-sale-other-alt  = c-f-sale-other-alt:DATA-TYPE
    l2f-sale-other-alt  = c-f-sale-other-alt:FORMAT
    c-f-sale-other-alt:DATA-TYPE = "CHARACTER"
    c-f-sale-other-alt:FORMAT    = "x(" + string(C-f-sale-other-alt:WIDTH-CHARS) + ")"
    c-f-sale-other-alt:screen-value = string(ff)  .
End.
  Display stream OutStream  with FRAME Zapas no-error .
  DOWN stream OutStream  with FRAME Zapas .
if c-f-qnty <>  ?  then do :
Assign
    c-f-qnty:DATA-TYPE = l1f-qnty
    c-f-qnty:FORMAT    = l2f-qnty.
End.
if c-f-cost-sum <>  ?  then do :
Assign
    c-f-cost-sum:DATA-TYPE = l1f-cost-sum
    c-f-cost-sum:FORMAT    = l2f-cost-sum.
End.
if c-f-sale-sum <>  ?  then do :
Assign
    c-f-sale-sum:DATA-TYPE = l1f-sale-sum
    c-f-sale-sum:FORMAT    = l2f-sale-sum.
End.
if c-f-sale-other <>  ?  then do :
Assign
    c-f-sale-other:DATA-TYPE = l1f-sale-other
    c-f-sale-other:FORMAT    = l2f-sale-other.
End.
if c-f-qnty-alt <>  ?  then do :
Assign
    c-f-qnty-alt:DATA-TYPE = l1f-qnty-alt
    c-f-qnty-alt:FORMAT    = l2f-qnty-alt.
End.
if c-f-cost-sum-alt <>  ?  then do :
Assign
    c-f-cost-sum-alt:DATA-TYPE = l1f-cost-sum-alt
    c-f-cost-sum-alt:FORMAT    = l2f-cost-sum-alt.
End.
if c-f-sale-sum-alt <>  ?  then do :
Assign
    c-f-sale-sum-alt:DATA-TYPE = l1f-sale-sum-alt
    c-f-sale-sum-alt:FORMAT    = l2f-sale-sum-alt.
End.
if c-f-sale-other-alt <>  ?  then do :
Assign
    c-f-sale-other-alt:DATA-TYPE = l1f-sale-other-alt
    c-f-sale-other-alt:FORMAT    = l2f-sale-other-alt.
End.
End.
END PROCEDURE.
PROCEDURE CalcItog :
    run ostatok (
        input x-store-code  ,
        input x-store-type  , x-TOG-Shift,
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
  for each ub.trn-doc no-lock where
      ub.trn-doc.status_   = 'факт':U  and
      ub.trn-doc.flag_     = true     and
      ub.trn-doc.host-code = v-cntxt-host-code-obj
      by ub.trn-doc.fact-order DESCENDING :
        fact-order-2 = ub.trn-doc.fact-order  .
        leave.
  end.
          Quantity1  = 0.
          Coast_R1   = 0.
          Coast_V1   = 0.
          VAT_R1     = 0.
          VAT_V1     = 0.
END PROCEDURE.
PROCEDURE foreach1 :
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$".
          n-nn = 0.
          n-no = n-no + 1 .
 For Each gds-list  break
                by
                   (if sorttype = "sort-artic":U then
                   ( gds-list.artic + gds-list.prod-type + string ( gds-list.prod-code ))
                   else (if sorttype = "sort-name":U then gds-list.gds-name
                                                     else string(gds-list.gds-code) ))
                by gds-list.artic
                 with FRAME Zapas :
              IF first-of(gds-list.artic) then DO:
                assign
                  f-qnty         = 0
                  f-cost-sum     = 0
                  f-sale-sum     = 0
                  f-sale-other   = 0
                  f-qnty-alt         = 0
                  f-cost-sum-alt     = 0
                  f-sale-sum-alt     = 0
                  f-sale-other-alt   = 0
                  .
              End.
          if last-of(gds-list.artic) then DO:
             n-nm = n-nm + 1.
If Integer(50) = 0 Then Temp1  = 100  .
                      Else Temp1 = Integer(50) .
     IF ( n-nm modulo Temp1 = 0 ) AND ( n-nm >= Temp1 ) then
         RUN waitfram-show( "Обработано строк : " + string( n-nm )) .
             For each obj-list no-lock :
                for each ub.gds-obj no-lock where
                    ub.gds-obj.artic     = gds-list.artic     and
                    ub.gds-obj.prod-type = gds-list.prod-type and
                    ub.gds-obj.prod-code = gds-list.prod-code and
                    ub.gds-obj.obj-code  = obj-list.obj-code and
                    ub.gds-obj.obj-type  = obj-list.obj-type    :
                    Assign
                      f-qnty       = f-qnty     + ub.gds-obj.free-qnty
                      f-cost-sum   = f-cost-sum + determined(gds-obj.fact-rubl)
                      f-sale-sum   = f-sale-sum + ub.gds-obj.fact-sale
                    .
                End.
             End.
             f-sale-other = 100 * determined((f-sale-sum - f-cost-sum) / f-cost-sum).
             For each alt-obj-list no-lock :
                for each ub.gds-obj no-lock where
                    ub.gds-obj.artic     = gds-list.artic     and
                    ub.gds-obj.prod-type = gds-list.prod-type and
                    ub.gds-obj.prod-code = gds-list.prod-code and
                    ub.gds-obj.obj-code  = alt-obj-list.obj-code and
                    ub.gds-obj.obj-type  = alt-obj-list.obj-type    :
                    Assign
                    f-qnty-alt       = f-qnty-alt     + ub.gds-obj.free-qnty
                    f-cost-sum-alt   = f-cost-sum-alt + determined(gds-obj.fact-rubl)
                    f-sale-sum-alt   = f-sale-sum-alt + ub.gds-obj.fact-sale
                    .
                End.
             End.
             f-sale-other-alt = 100 * determined((f-sale-sum-alt - f-cost-sum-alt) / f-cost-sum-alt).
             if itog = false and
                NOT(
                   ( f-qnty          = 0 and
                    f-cost-sum       = 0 and
                    f-sale-sum       = 0 and
                    f-sale-other     = 0 and
                    f-qnty-alt       = 0 and
                    f-cost-sum-alt   = 0 and
                    f-sale-sum-alt   = 0 and
                    f-sale-other-alt = 0  ))
             Then DO:
                    sss = 0 .
                    if show-zero = false  then do:
                       if c-f-qnty <>  ?  and  f-qnty <> 0 then sss = 1 .
                       if c-f-cost-sum       <>  ?  and  round(f-cost-sum       ,2) <> 0 then sss = 1 .
                       if c-f-sale-sum       <>  ?  and  round(f-sale-sum       ,2) <> 0 then sss = 1 .
                       if c-f-sale-other     <>  ?  and  round(f-sale-other     ,2) <> 0 then sss = 1 .
                       if c-f-qnty-alt       <>  ?  and  round(f-qnty-alt       ,2) <> 0 then sss = 1 .
                       if c-f-cost-sum-alt   <>  ?  and  round(f-cost-sum-alt   ,2) <> 0 then sss = 1 .
                       if c-f-sale-sum-alt   <>  ?  and  round(f-sale-sum-alt   ,2) <> 0 then sss = 1 .
                       if c-f-sale-other-alt <>  ?  and  round(f-sale-other-alt,2)  <> 0 then sss = 1 .
                    end.
                    else  do: sss = 1 . end.
                    if sss = 1 then do:
                      n-nn = n-nn + 1 .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  gds-list.gds-code
  ,input  ?
  ,output v-bar-code
  )  .
  if c-nn <>  ?  then do :
    c-nn:screen-value = string(string(n-nn)) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-artic <>  ?  then do :
    c-f-artic:screen-value = string(gds-list.artic) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-b-code <>  ?  then do :
    c-f-b-code:screen-value = string(string(v-bar-code,'999999999')) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-gds-name <>  ?  then do :
    c-f-gds-name:screen-value = string(gds-list.gds-name) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-qnty <>  ?  then do :
    c-f-qnty:screen-value = string(f-qnty) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-sum <>  ?  then do :
    c-f-cost-sum:screen-value = string(f-cost-sum) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-sum <>  ?  then do :
    c-f-sale-sum:screen-value = string(f-sale-sum) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-other <>  ?  then do :
    c-f-sale-other:screen-value = string(f-sale-other) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-qnty-alt <>  ?  then do :
    c-f-qnty-alt:screen-value = string(f-qnty-alt) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-sum-alt <>  ?  then do :
    c-f-cost-sum-alt:screen-value = string(f-cost-sum-alt) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-sum-alt <>  ?  then do :
    c-f-sale-sum-alt:screen-value = string(f-sale-sum-alt) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-other-alt <>  ?  then do :
    c-f-sale-other-alt:screen-value = string(f-sale-other-alt) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
                      display stream OutStream  no-error .
                      DOWN stream OutStream .
                      if Make-Excel then  put   stream ForExcel unformatted
                        string(n-nn)                      CHR(9)
                        v-bar-code                        CHR(9)
                        (gds-list.artic)                  CHR(9)
                        gds-list.gds-name                 CHR(9)
                                                          CHR(9)
                        excel-qnty(f-qnty        )        CHR(9)
                        excel-sum (f-cost-sum    )        CHR(9)
                        excel-sum (f-sale-sum    )        CHR(9)
                        excel-sum (f-sale-other  )        CHR(9)
                        excel-qnty(f-qnty-alt        )    CHR(9)
                        excel-sum (f-cost-sum-alt    )    CHR(9)
                        excel-sum (f-sale-sum-alt    )    CHR(9)
                        excel-sum (f-sale-other-alt  )    CHR(9)
                        chr(10) .
                        Run Display-prt in this-procedure  .
                    end.
             End.
              accumulate f-qnty               (TOTAL) .
              accumulate f-cost-sum           (TOTAL) .
              accumulate f-sale-sum           (TOTAL) .
              accumulate f-sale-other         (TOTAL) .
              accumulate f-qnty-alt           (TOTAL) .
              accumulate f-cost-sum-alt       (TOTAL) .
              accumulate f-sale-sum-alt       (TOTAL) .
              accumulate f-sale-other-alt     (TOTAL) .
                Assign
                  f-qnty              = 0
                  f-cost-sum          = 0
                  f-sale-sum          = 0
                  f-sale-other        = 0
                  f-qnty-alt          = 0
                  f-cost-sum-alt      = 0
                  f-sale-sum-alt      = 0
                  f-sale-other-alt    = 0
                 .
          End.
 End.
 run u-line.
  if c-nn <>  ?  then do :
    c-nn:screen-value = string('ИТОГО') .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-artic <>  ?  then do :
    c-f-artic:screen-value = string('по объектам') .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-qnty <>  ?  then do :
    c-f-qnty:screen-value = string(accum TOTAL f-qnty) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-sum <>  ?  then do :
    c-f-cost-sum:screen-value = string(accum TOTAL f-cost-sum) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-sum <>  ?  then do :
    c-f-sale-sum:screen-value = string(accum TOTAL f-sale-sum) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-other <>  ?  then do :
    c-f-sale-other:screen-value = string(accum TOTAL f-sale-other) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-qnty-alt <>  ?  then do :
    c-f-qnty-alt:screen-value = string(accum TOTAL f-qnty-alt) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-sum-alt <>  ?  then do :
    c-f-cost-sum-alt:screen-value = string(accum TOTAL f-cost-sum-alt) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-sum-alt <>  ?  then do :
    c-f-sale-sum-alt:screen-value = string(accum TOTAL f-sale-sum-alt) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-other-alt <>  ?  then do :
    c-f-sale-other-alt:screen-value = string(accum TOTAL f-sale-other-alt) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  Display stream OutStream with FRAME Zapas no-error.
  DOWN stream OutStream with FRAME Zapas.
  run u-line.
  if Make-Excel then  put   stream ForExcel unformatted
          "ИТОГО"                         CHR(9)
          "по объектам"                    CHR(9)
                                             CHR(9) CHR(9) CHR(9)
          excel-qnty(accum TOTAL f-qnty           )  CHR(9)
          excel-sum (accum TOTAL f-cost-sum       )  CHR(9)
          excel-sum (accum TOTAL f-sale-sum       )  CHR(9)
          excel-sum (accum TOTAL f-sale-other    )   CHR(9)
          excel-qnty(accum TOTAL f-qnty-alt           )  CHR(9)
          excel-sum (accum TOTAL f-cost-sum-alt       )  CHR(9)
          excel-sum (accum TOTAL f-sale-sum-alt       )  CHR(9)
          excel-sum (accum TOTAL f-sale-other-alt    )   CHR(9)
          chr(10) .
END PROCEDURE.
PROCEDURE foreach2 :
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$".
          n-nn = 0.
          n-no = n-no + 1 .
 For Each gds-list  break
                by gds-list.prod-type
                by gds-list.prod-code
                by
                   ( if sorttype = "sort-artic":U then
                   ( gds-list.artic + gds-list.prod-type + string ( gds-list.prod-code ))
                   else (if sorttype = "sort-name":U then gds-list.gds-name
                                                     else string(gds-list.gds-code) ))
                by gds-list.artic
                 with FRAME Zapas :
              IF first-of(gds-list.artic) then DO:
                assign
                  f-qnty         = 0
                  f-cost-sum     = 0
                  f-sale-sum     = 0
                  f-sale-other   = 0
                  f-qnty-alt         = 0
                  f-cost-sum-alt     = 0
                  f-sale-sum-alt     = 0
                  f-sale-other-alt   = 0
                  .
              End.
          if first-of(gds-list.prod-code) then DO:
              FIND FIRST clients-p where  gds-list.prod-type = clients-p.obj-type AND
                                          gds-list.prod-code = clients-p.obj-code no-lock no-error.
                  if avail clients-p then var-client = Clients-p.obj-name.
                  if  Itog = false Then do:
  if c-f-gds-name <>  ?  then do :
    c-f-gds-name:screen-value = string(var-client) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
                    Display stream OutStream .
                    DOWN stream OutStream .
                    if Make-Excel then  put   stream ForExcel unformatted var-client chr(10) .
                  End.
          End.
          if last-of(gds-list.artic) then DO:
             n-nm = n-nm + 1.
If Integer(50) = 0 Then Temp1  = 100  .
                      Else Temp1 = Integer(50) .
     IF ( n-nm modulo Temp1 = 0 ) AND ( n-nm >= Temp1 ) then
         RUN waitfram-show( "Обработано строк : " + string( n-nm )) .
             For each obj-list no-lock :
                for each ub.gds-obj no-lock where
                    ub.gds-obj.artic     = gds-list.artic     and
                    ub.gds-obj.prod-type = gds-list.prod-type and
                    ub.gds-obj.prod-code = gds-list.prod-code and
                    ub.gds-obj.obj-code  = obj-list.obj-code and
                    ub.gds-obj.obj-type  = obj-list.obj-type    :
                    Assign
                      f-qnty       = f-qnty     + ub.gds-obj.free-qnty
                      f-cost-sum   = f-cost-sum + determined(gds-obj.fact-rubl)
                      f-sale-sum   = f-sale-sum + ub.gds-obj.fact-sale
                    .
                End.
             End.
             f-sale-other = 100 * determined((f-sale-sum - f-cost-sum) / f-cost-sum).
             For each alt-obj-list no-lock :
                for each ub.gds-obj no-lock where
                    ub.gds-obj.artic     = gds-list.artic     and
                    ub.gds-obj.prod-type = gds-list.prod-type and
                    ub.gds-obj.prod-code = gds-list.prod-code and
                    ub.gds-obj.obj-code  = alt-obj-list.obj-code and
                    ub.gds-obj.obj-type  = alt-obj-list.obj-type    :
                    Assign
                    f-qnty-alt       = f-qnty-alt     + ub.gds-obj.free-qnty
                    f-cost-sum-alt   = f-cost-sum-alt + determined(gds-obj.fact-rubl)
                    f-sale-sum-alt   = f-sale-sum-alt + ub.gds-obj.fact-sale
                    .
                End.
             End.
             f-sale-other-alt = 100 * determined((f-sale-sum-alt - f-cost-sum-alt) / f-cost-sum-alt).
             if itog = false and
                NOT(
                   ( f-qnty          = 0 and
                    f-cost-sum       = 0 and
                    f-sale-sum       = 0 and
                    f-sale-other     = 0 and
                    f-qnty-alt       = 0 and
                    f-cost-sum-alt   = 0 and
                    f-sale-sum-alt   = 0 and
                    f-sale-other-alt = 0  ))
             Then DO:
                    sss = 0 .
                    if show-zero = false  then do:
                       if c-f-qnty <>  ?  and  f-qnty <> 0 then sss = 1 .
                       if c-f-cost-sum       <>  ?  and  round(f-cost-sum       ,2) <> 0 then sss = 1 .
                       if c-f-sale-sum       <>  ?  and  round(f-sale-sum       ,2) <> 0 then sss = 1 .
                       if c-f-sale-other     <>  ?  and  round(f-sale-other     ,2) <> 0 then sss = 1 .
                       if c-f-qnty-alt       <>  ?  and  round(f-qnty-alt       ,2) <> 0 then sss = 1 .
                       if c-f-cost-sum-alt   <>  ?  and  round(f-cost-sum-alt   ,2) <> 0 then sss = 1 .
                       if c-f-sale-sum-alt   <>  ?  and  round(f-sale-sum-alt   ,2) <> 0 then sss = 1 .
                       if c-f-sale-other-alt <>  ?  and  round(f-sale-other-alt,2)  <> 0 then sss = 1 .
                    end.
                    else  do: sss = 1 . end.
                    if sss = 1 then do:
                      n-nn = n-nn + 1 .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  gds-list.gds-code
  ,input  ?
  ,output v-bar-code
  )  .
  if c-nn <>  ?  then do :
    c-nn:screen-value = string(string(n-nn)) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-artic <>  ?  then do :
    c-f-artic:screen-value = string(gds-list.artic) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-b-code <>  ?  then do :
    c-f-b-code:screen-value = string(string(v-bar-code,'999999999')) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-gds-name <>  ?  then do :
    c-f-gds-name:screen-value = string(gds-list.gds-name) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-qnty <>  ?  then do :
    c-f-qnty:screen-value = string(f-qnty) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-sum <>  ?  then do :
    c-f-cost-sum:screen-value = string(f-cost-sum) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-sum <>  ?  then do :
    c-f-sale-sum:screen-value = string(f-sale-sum) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-other <>  ?  then do :
    c-f-sale-other:screen-value = string(f-sale-other) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-qnty-alt <>  ?  then do :
    c-f-qnty-alt:screen-value = string(f-qnty-alt) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-sum-alt <>  ?  then do :
    c-f-cost-sum-alt:screen-value = string(f-cost-sum-alt) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-sum-alt <>  ?  then do :
    c-f-sale-sum-alt:screen-value = string(f-sale-sum-alt) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-other-alt <>  ?  then do :
    c-f-sale-other-alt:screen-value = string(f-sale-other-alt) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
                      display stream OutStream  no-error .
                      DOWN stream OutStream .
                      if Make-Excel then  put   stream ForExcel unformatted
                        string(n-nn)                      CHR(9)
                        v-bar-code                        CHR(9)
                        (gds-list.artic)                  CHR(9)
                        gds-list.gds-name                 CHR(9)
                                                          CHR(9)
                        excel-qnty(f-qnty        )        CHR(9)
                        excel-sum (f-cost-sum    )        CHR(9)
                        excel-sum (f-sale-sum    )        CHR(9)
                        excel-sum (f-sale-other  )        CHR(9)
                        excel-qnty(f-qnty-alt        )    CHR(9)
                        excel-sum (f-cost-sum-alt    )    CHR(9)
                        excel-sum (f-sale-sum-alt    )    CHR(9)
                        excel-sum (f-sale-other-alt  )    CHR(9)
                        chr(10) .
                        Run Display-prt in this-procedure  .
                    end.
             End.
              accumulate f-qnty               (TOTAL  by gds-list.prod-code ) .
              accumulate f-cost-sum           (TOTAL  by gds-list.prod-code ) .
              accumulate f-sale-sum           (TOTAL  by gds-list.prod-code ) .
              accumulate f-sale-other         (TOTAL  by gds-list.prod-code ) .
              accumulate f-qnty-alt           (TOTAL  by gds-list.prod-code ) .
              accumulate f-cost-sum-alt       (TOTAL  by gds-list.prod-code ) .
              accumulate f-sale-sum-alt       (TOTAL  by gds-list.prod-code ) .
              accumulate f-sale-other-alt     (TOTAL  by gds-list.prod-code ) .
                Assign
                  f-qnty              = 0
                  f-cost-sum          = 0
                  f-sale-sum          = 0
                  f-sale-other        = 0
                  f-qnty-alt          = 0
                  f-cost-sum-alt      = 0
                  f-sale-sum-alt      = 0
                  f-sale-other-alt    = 0
                 .
          End.
          if last-of(gds-list.prod-code)  then do :
            f-artic = 'по произв.' .
  if c-nn <>  ?  then do :
    c-nn:screen-value = string('Итого') .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-artic <>  ?  then do :
    c-f-artic:screen-value = string(f-artic) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-gds-name <>  ?  then do :
    c-f-gds-name:screen-value = string(var-client) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-qnty <>  ?  then do :
    c-f-qnty:screen-value = string(accum TOTAL by gds-list.prod-code f-qnty    ) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-sum <>  ?  then do :
    c-f-cost-sum:screen-value = string(accum TOTAL by gds-list.prod-code f-cost-sum ) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-sum <>  ?  then do :
    c-f-sale-sum:screen-value = string(accum TOTAL  by gds-list.prod-code  f-sale-sum) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-other <>  ?  then do :
    c-f-sale-other:screen-value = string(accum TOTAL by  gds-list.prod-code  f-sale-other) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-qnty-alt <>  ?  then do :
    c-f-qnty-alt:screen-value = string(accum TOTAL by gds-list.prod-code f-qnty-alt    ) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-sum-alt <>  ?  then do :
    c-f-cost-sum-alt:screen-value = string(accum TOTAL by gds-list.prod-code f-cost-sum-alt ) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-sum-alt <>  ?  then do :
    c-f-sale-sum-alt:screen-value = string(accum TOTAL  by gds-list.prod-code  f-sale-sum-alt) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-other-alt <>  ?  then do :
    c-f-sale-other-alt:screen-value = string(accum TOTAL by  gds-list.prod-code  f-sale-other-alt) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
              Display stream OutStream  no-error .
              DOWN stream OutStream .
              if Make-Excel then  put   stream ForExcel unformatted
              "Итого"                                              CHR(9)
              'по произв.'
              var-client                                           CHR(9) CHR(9) CHR(9) CHR(9)
              excel-qnty(accum TOTAL by gds-list.prod-code  f-qnty           )    CHR(9)
              excel-sum (accum TOTAL by gds-list.prod-code  f-cost-sum       )   CHR(9)
              excel-sum (accum TOTAL by gds-list.prod-code  f-sale-sum       )   CHR(9)
              excel-sum (accum TOTAL by gds-list.prod-code  f-sale-other     )   CHR(9)
              excel-qnty(accum TOTAL by gds-list.prod-code  f-qnty-alt           )    CHR(9)
              excel-sum (accum TOTAL by gds-list.prod-code  f-cost-sum-alt       )   CHR(9)
              excel-sum (accum TOTAL by gds-list.prod-code  f-sale-sum-alt       )   CHR(9)
              excel-sum (accum TOTAL by gds-list.prod-code  f-sale-other-alt     )   CHR(9)
              chr(10) .
          End.
 End.
 run u-line.
  if c-nn <>  ?  then do :
    c-nn:screen-value = string('ИТОГО') .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-artic <>  ?  then do :
    c-f-artic:screen-value = string('по объектам') .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-qnty <>  ?  then do :
    c-f-qnty:screen-value = string(accum TOTAL f-qnty) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-sum <>  ?  then do :
    c-f-cost-sum:screen-value = string(accum TOTAL f-cost-sum) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-sum <>  ?  then do :
    c-f-sale-sum:screen-value = string(accum TOTAL f-sale-sum) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-other <>  ?  then do :
    c-f-sale-other:screen-value = string(accum TOTAL f-sale-other) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-qnty-alt <>  ?  then do :
    c-f-qnty-alt:screen-value = string(accum TOTAL f-qnty-alt) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-sum-alt <>  ?  then do :
    c-f-cost-sum-alt:screen-value = string(accum TOTAL f-cost-sum-alt) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-sum-alt <>  ?  then do :
    c-f-sale-sum-alt:screen-value = string(accum TOTAL f-sale-sum-alt) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-other-alt <>  ?  then do :
    c-f-sale-other-alt:screen-value = string(accum TOTAL f-sale-other-alt) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  Display stream OutStream with FRAME Zapas no-error.
  DOWN stream OutStream with FRAME Zapas.
  run u-line.
  if Make-Excel then  put   stream ForExcel unformatted
          "ИТОГО"                         CHR(9)
          "по объектам"                    CHR(9)
                                             CHR(9) CHR(9) CHR(9)
          excel-qnty(accum TOTAL f-qnty           )  CHR(9)
          excel-sum (accum TOTAL f-cost-sum       )  CHR(9)
          excel-sum (accum TOTAL f-sale-sum       )  CHR(9)
          excel-sum (accum TOTAL f-sale-other    )   CHR(9)
          excel-qnty(accum TOTAL f-qnty-alt           )  CHR(9)
          excel-sum (accum TOTAL f-cost-sum-alt       )  CHR(9)
          excel-sum (accum TOTAL f-sale-sum-alt       )  CHR(9)
          excel-sum (accum TOTAL f-sale-other-alt    )   CHR(9)
          chr(10) .
END PROCEDURE.
PROCEDURE foreach3 :
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$".
          n-nn = 0.
          n-no = n-no + 1 .
 For Each gds-list  break
                by gds-list.grp-name
                by
                   (if sorttype = "sort-artic":U then
                   ( gds-list.artic + gds-list.prod-type + string ( gds-list.prod-code ))
                   else (if sorttype = "sort-name":U then gds-list.gds-name
                                                     else string(gds-list.gds-code) ))
                by gds-list.artic
                 with FRAME Zapas :
              IF first-of(gds-list.artic) then DO:
                assign
                  f-qnty         = 0
                  f-cost-sum     = 0
                  f-sale-sum     = 0
                  f-sale-other   = 0
                  f-qnty-alt         = 0
                  f-cost-sum-alt     = 0
                  f-sale-sum-alt     = 0
                  f-sale-other-alt   = 0
                  .
              End.
          if first-of(gds-list.grp-name) then  DO:
            var-client = gds-list.grp-name.
            if  Itog = false Then do:
              PUT stream OutStream  gds-list.grp-name  AT 1 format "X(160)" SKIP.
              DOWN stream OutStream .
              if Make-Excel then  put   stream ForExcel unformatted gds-list.grp-name chr(10) .
            End.
          End.
          if last-of(gds-list.artic) then DO:
             n-nm = n-nm + 1.
If Integer(50) = 0 Then Temp1  = 100  .
                      Else Temp1 = Integer(50) .
     IF ( n-nm modulo Temp1 = 0 ) AND ( n-nm >= Temp1 ) then
         RUN waitfram-show( "Обработано строк : " + string( n-nm )) .
             For each obj-list no-lock :
                for each ub.gds-obj no-lock where
                    ub.gds-obj.artic     = gds-list.artic     and
                    ub.gds-obj.prod-type = gds-list.prod-type and
                    ub.gds-obj.prod-code = gds-list.prod-code and
                    ub.gds-obj.obj-code  = obj-list.obj-code and
                    ub.gds-obj.obj-type  = obj-list.obj-type    :
                    Assign
                      f-qnty       = f-qnty     + ub.gds-obj.free-qnty
                      f-cost-sum   = f-cost-sum + determined(gds-obj.fact-rubl)
                      f-sale-sum   = f-sale-sum + ub.gds-obj.fact-sale
                    .
                End.
             End.
             f-sale-other = 100 * determined((f-sale-sum - f-cost-sum) / f-cost-sum).
             For each alt-obj-list no-lock :
                for each ub.gds-obj no-lock where
                    ub.gds-obj.artic     = gds-list.artic     and
                    ub.gds-obj.prod-type = gds-list.prod-type and
                    ub.gds-obj.prod-code = gds-list.prod-code and
                    ub.gds-obj.obj-code  = alt-obj-list.obj-code and
                    ub.gds-obj.obj-type  = alt-obj-list.obj-type    :
                    Assign
                    f-qnty-alt       = f-qnty-alt     + ub.gds-obj.free-qnty
                    f-cost-sum-alt   = f-cost-sum-alt + determined(gds-obj.fact-rubl)
                    f-sale-sum-alt   = f-sale-sum-alt + ub.gds-obj.fact-sale
                    .
                End.
             End.
             f-sale-other-alt = 100 * determined((f-sale-sum-alt - f-cost-sum-alt) / f-cost-sum-alt).
             if itog = false and
                NOT(
                   ( f-qnty          = 0 and
                    f-cost-sum       = 0 and
                    f-sale-sum       = 0 and
                    f-sale-other     = 0 and
                    f-qnty-alt       = 0 and
                    f-cost-sum-alt   = 0 and
                    f-sale-sum-alt   = 0 and
                    f-sale-other-alt = 0  ))
             Then DO:
                    sss = 0 .
                    if show-zero = false  then do:
                       if c-f-qnty <>  ?  and  f-qnty <> 0 then sss = 1 .
                       if c-f-cost-sum       <>  ?  and  round(f-cost-sum       ,2) <> 0 then sss = 1 .
                       if c-f-sale-sum       <>  ?  and  round(f-sale-sum       ,2) <> 0 then sss = 1 .
                       if c-f-sale-other     <>  ?  and  round(f-sale-other     ,2) <> 0 then sss = 1 .
                       if c-f-qnty-alt       <>  ?  and  round(f-qnty-alt       ,2) <> 0 then sss = 1 .
                       if c-f-cost-sum-alt   <>  ?  and  round(f-cost-sum-alt   ,2) <> 0 then sss = 1 .
                       if c-f-sale-sum-alt   <>  ?  and  round(f-sale-sum-alt   ,2) <> 0 then sss = 1 .
                       if c-f-sale-other-alt <>  ?  and  round(f-sale-other-alt,2)  <> 0 then sss = 1 .
                    end.
                    else  do: sss = 1 . end.
                    if sss = 1 then do:
                      n-nn = n-nn + 1 .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  gds-list.gds-code
  ,input  ?
  ,output v-bar-code
  )  .
  if c-nn <>  ?  then do :
    c-nn:screen-value = string(string(n-nn)) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-artic <>  ?  then do :
    c-f-artic:screen-value = string(gds-list.artic) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-b-code <>  ?  then do :
    c-f-b-code:screen-value = string(string(v-bar-code,'999999999')) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-gds-name <>  ?  then do :
    c-f-gds-name:screen-value = string(gds-list.gds-name) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-qnty <>  ?  then do :
    c-f-qnty:screen-value = string(f-qnty) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-sum <>  ?  then do :
    c-f-cost-sum:screen-value = string(f-cost-sum) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-sum <>  ?  then do :
    c-f-sale-sum:screen-value = string(f-sale-sum) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-other <>  ?  then do :
    c-f-sale-other:screen-value = string(f-sale-other) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-qnty-alt <>  ?  then do :
    c-f-qnty-alt:screen-value = string(f-qnty-alt) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-sum-alt <>  ?  then do :
    c-f-cost-sum-alt:screen-value = string(f-cost-sum-alt) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-sum-alt <>  ?  then do :
    c-f-sale-sum-alt:screen-value = string(f-sale-sum-alt) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-other-alt <>  ?  then do :
    c-f-sale-other-alt:screen-value = string(f-sale-other-alt) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
                      display stream OutStream  no-error .
                      DOWN stream OutStream .
                      if Make-Excel then  put   stream ForExcel unformatted
                        string(n-nn)                      CHR(9)
                        v-bar-code                        CHR(9)
                        (gds-list.artic)                  CHR(9)
                        gds-list.gds-name                 CHR(9)
                                                          CHR(9)
                        excel-qnty(f-qnty        )        CHR(9)
                        excel-sum (f-cost-sum    )        CHR(9)
                        excel-sum (f-sale-sum    )        CHR(9)
                        excel-sum (f-sale-other  )        CHR(9)
                        excel-qnty(f-qnty-alt        )    CHR(9)
                        excel-sum (f-cost-sum-alt    )    CHR(9)
                        excel-sum (f-sale-sum-alt    )    CHR(9)
                        excel-sum (f-sale-other-alt  )    CHR(9)
                        chr(10) .
                        Run Display-prt in this-procedure  .
                    end.
             End.
              accumulate f-qnty               (TOTAL  by gds-list.grp-name ) .
              accumulate f-cost-sum           (TOTAL  by gds-list.grp-name ) .
              accumulate f-sale-sum           (TOTAL  by gds-list.grp-name ) .
              accumulate f-sale-other         (TOTAL  by gds-list.grp-name ) .
              accumulate f-qnty-alt           (TOTAL  by gds-list.grp-name ) .
              accumulate f-cost-sum-alt       (TOTAL  by gds-list.grp-name ) .
              accumulate f-sale-sum-alt       (TOTAL  by gds-list.grp-name ) .
              accumulate f-sale-other-alt     (TOTAL  by gds-list.grp-name ) .
                Assign
                  f-qnty              = 0
                  f-cost-sum          = 0
                  f-sale-sum          = 0
                  f-sale-other        = 0
                  f-qnty-alt          = 0
                  f-cost-sum-alt      = 0
                  f-sale-sum-alt      = 0
                  f-sale-other-alt    = 0
                 .
          End.
          if last-of(gds-list.grp-name)  then do :
            f-artic = 'по группе ' .
  if c-nn <>  ?  then do :
    c-nn:screen-value = string('Итого') .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-artic <>  ?  then do :
    c-f-artic:screen-value = string(f-artic) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-gds-name <>  ?  then do :
    c-f-gds-name:screen-value = string(var-client) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-qnty <>  ?  then do :
    c-f-qnty:screen-value = string(accum TOTAL by gds-list.grp-name f-qnty    ) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-sum <>  ?  then do :
    c-f-cost-sum:screen-value = string(accum TOTAL by gds-list.grp-name f-cost-sum ) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-sum <>  ?  then do :
    c-f-sale-sum:screen-value = string(accum TOTAL  by gds-list.grp-name  f-sale-sum) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-other <>  ?  then do :
    c-f-sale-other:screen-value = string(accum TOTAL by  gds-list.grp-name  f-sale-other) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-qnty-alt <>  ?  then do :
    c-f-qnty-alt:screen-value = string(accum TOTAL by gds-list.grp-name f-qnty-alt    ) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-sum-alt <>  ?  then do :
    c-f-cost-sum-alt:screen-value = string(accum TOTAL by gds-list.grp-name f-cost-sum-alt ) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-sum-alt <>  ?  then do :
    c-f-sale-sum-alt:screen-value = string(accum TOTAL  by gds-list.grp-name  f-sale-sum-alt) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-other-alt <>  ?  then do :
    c-f-sale-other-alt:screen-value = string(accum TOTAL by  gds-list.grp-name  f-sale-other-alt) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
              Display stream OutStream  no-error .
              DOWN stream OutStream .
              if Make-Excel then  put   stream ForExcel unformatted
              "Итого"                                              CHR(9)
              'по группе '
              var-client                                           CHR(9) CHR(9) CHR(9) CHR(9)
              excel-qnty(accum TOTAL by gds-list.grp-name  f-qnty           )    CHR(9)
              excel-sum (accum TOTAL by gds-list.grp-name  f-cost-sum       )   CHR(9)
              excel-sum (accum TOTAL by gds-list.grp-name  f-sale-sum       )   CHR(9)
              excel-sum (accum TOTAL by gds-list.grp-name  f-sale-other     )   CHR(9)
              excel-qnty(accum TOTAL by gds-list.grp-name  f-qnty-alt           )    CHR(9)
              excel-sum (accum TOTAL by gds-list.grp-name  f-cost-sum-alt       )   CHR(9)
              excel-sum (accum TOTAL by gds-list.grp-name  f-sale-sum-alt       )   CHR(9)
              excel-sum (accum TOTAL by gds-list.grp-name  f-sale-other-alt     )   CHR(9)
              chr(10) .
          End.
 End.
 run u-line.
  if c-nn <>  ?  then do :
    c-nn:screen-value = string('ИТОГО') .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-artic <>  ?  then do :
    c-f-artic:screen-value = string('по объектам') .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-qnty <>  ?  then do :
    c-f-qnty:screen-value = string(accum TOTAL f-qnty) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-sum <>  ?  then do :
    c-f-cost-sum:screen-value = string(accum TOTAL f-cost-sum) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-sum <>  ?  then do :
    c-f-sale-sum:screen-value = string(accum TOTAL f-sale-sum) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-other <>  ?  then do :
    c-f-sale-other:screen-value = string(accum TOTAL f-sale-other) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-qnty-alt <>  ?  then do :
    c-f-qnty-alt:screen-value = string(accum TOTAL f-qnty-alt) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-sum-alt <>  ?  then do :
    c-f-cost-sum-alt:screen-value = string(accum TOTAL f-cost-sum-alt) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-sum-alt <>  ?  then do :
    c-f-sale-sum-alt:screen-value = string(accum TOTAL f-sale-sum-alt) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-other-alt <>  ?  then do :
    c-f-sale-other-alt:screen-value = string(accum TOTAL f-sale-other-alt) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  Display stream OutStream with FRAME Zapas no-error.
  DOWN stream OutStream with FRAME Zapas.
  run u-line.
  if Make-Excel then  put   stream ForExcel unformatted
          "ИТОГО"                         CHR(9)
          "по объектам"                    CHR(9)
                                             CHR(9) CHR(9) CHR(9)
          excel-qnty(accum TOTAL f-qnty           )  CHR(9)
          excel-sum (accum TOTAL f-cost-sum       )  CHR(9)
          excel-sum (accum TOTAL f-sale-sum       )  CHR(9)
          excel-sum (accum TOTAL f-sale-other    )   CHR(9)
          excel-qnty(accum TOTAL f-qnty-alt           )  CHR(9)
          excel-sum (accum TOTAL f-cost-sum-alt       )  CHR(9)
          excel-sum (accum TOTAL f-sale-sum-alt       )  CHR(9)
          excel-sum (accum TOTAL f-sale-other-alt    )   CHR(9)
          chr(10) .
END PROCEDURE.
PROCEDURE foreach4 :
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$".
          n-nn = 0.
          n-no = n-no + 1 .
 For Each gds-list  break
                by gds-list.qnty
                   by
                   (if sorttype = "sort-artic":U then
                   ( gds-list.artic + gds-list.prod-type + string ( gds-list.prod-code ))
                   else (if sorttype = "sort-name":U then gds-list.gds-name
                                                     else string(gds-list.gds-code) ))
                by gds-list.artic
                 with FRAME Zapas :
              IF first-of(gds-list.artic) then DO:
                assign
                  f-qnty         = 0
                  f-cost-sum     = 0
                  f-sale-sum     = 0
                  f-sale-other   = 0
                  f-qnty-alt         = 0
                  f-cost-sum-alt     = 0
                  f-sale-sum-alt     = 0
                  f-sale-other-alt   = 0
                  .
              End.
          if first-of(gds-list.qnty) then DO:
              var-client = string(gds-list.qnty) + '%'.
              if  Itog = false Then do:
  if c-f-gds-name <>  ?  then do :
    c-f-gds-name:screen-value = string('Ставка НДС ' + string(gds-list.qnty) + '%') .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
                  Display stream OutStream .
                  DOWN stream OutStream .
                  if Make-Excel then  put   stream ForExcel unformatted 'Ставка НДС ' + string(gds-list.qnty) + '%' chr(10) .
              End.
          End.
          if last-of(gds-list.artic) then DO:
             n-nm = n-nm + 1.
If Integer(50) = 0 Then Temp1  = 100  .
                      Else Temp1 = Integer(50) .
     IF ( n-nm modulo Temp1 = 0 ) AND ( n-nm >= Temp1 ) then
         RUN waitfram-show( "Обработано строк : " + string( n-nm )) .
             For each obj-list no-lock :
                for each ub.gds-obj no-lock where
                    ub.gds-obj.artic     = gds-list.artic     and
                    ub.gds-obj.prod-type = gds-list.prod-type and
                    ub.gds-obj.prod-code = gds-list.prod-code and
                    ub.gds-obj.obj-code  = obj-list.obj-code and
                    ub.gds-obj.obj-type  = obj-list.obj-type    :
                    Assign
                      f-qnty       = f-qnty     + ub.gds-obj.free-qnty
                      f-cost-sum   = f-cost-sum + determined(gds-obj.fact-rubl)
                      f-sale-sum   = f-sale-sum + ub.gds-obj.fact-sale
                    .
                End.
             End.
             f-sale-other = 100 * determined((f-sale-sum - f-cost-sum) / f-cost-sum).
             For each alt-obj-list no-lock :
                for each ub.gds-obj no-lock where
                    ub.gds-obj.artic     = gds-list.artic     and
                    ub.gds-obj.prod-type = gds-list.prod-type and
                    ub.gds-obj.prod-code = gds-list.prod-code and
                    ub.gds-obj.obj-code  = alt-obj-list.obj-code and
                    ub.gds-obj.obj-type  = alt-obj-list.obj-type    :
                    Assign
                    f-qnty-alt       = f-qnty-alt     + ub.gds-obj.free-qnty
                    f-cost-sum-alt   = f-cost-sum-alt + determined(gds-obj.fact-rubl)
                    f-sale-sum-alt   = f-sale-sum-alt + ub.gds-obj.fact-sale
                    .
                End.
             End.
             f-sale-other-alt = 100 * determined((f-sale-sum-alt - f-cost-sum-alt) / f-cost-sum-alt).
             if itog = false and
                NOT(
                   ( f-qnty          = 0 and
                    f-cost-sum       = 0 and
                    f-sale-sum       = 0 and
                    f-sale-other     = 0 and
                    f-qnty-alt       = 0 and
                    f-cost-sum-alt   = 0 and
                    f-sale-sum-alt   = 0 and
                    f-sale-other-alt = 0  ))
             Then DO:
                    sss = 0 .
                    if show-zero = false  then do:
                       if c-f-qnty <>  ?  and  f-qnty <> 0 then sss = 1 .
                       if c-f-cost-sum       <>  ?  and  round(f-cost-sum       ,2) <> 0 then sss = 1 .
                       if c-f-sale-sum       <>  ?  and  round(f-sale-sum       ,2) <> 0 then sss = 1 .
                       if c-f-sale-other     <>  ?  and  round(f-sale-other     ,2) <> 0 then sss = 1 .
                       if c-f-qnty-alt       <>  ?  and  round(f-qnty-alt       ,2) <> 0 then sss = 1 .
                       if c-f-cost-sum-alt   <>  ?  and  round(f-cost-sum-alt   ,2) <> 0 then sss = 1 .
                       if c-f-sale-sum-alt   <>  ?  and  round(f-sale-sum-alt   ,2) <> 0 then sss = 1 .
                       if c-f-sale-other-alt <>  ?  and  round(f-sale-other-alt,2)  <> 0 then sss = 1 .
                    end.
                    else  do: sss = 1 . end.
                    if sss = 1 then do:
                      n-nn = n-nn + 1 .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  gds-list.gds-code
  ,input  ?
  ,output v-bar-code
  )  .
  if c-nn <>  ?  then do :
    c-nn:screen-value = string(string(n-nn)) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-artic <>  ?  then do :
    c-f-artic:screen-value = string(gds-list.artic) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-b-code <>  ?  then do :
    c-f-b-code:screen-value = string(string(v-bar-code,'999999999')) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-gds-name <>  ?  then do :
    c-f-gds-name:screen-value = string(gds-list.gds-name) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-qnty <>  ?  then do :
    c-f-qnty:screen-value = string(f-qnty) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-sum <>  ?  then do :
    c-f-cost-sum:screen-value = string(f-cost-sum) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-sum <>  ?  then do :
    c-f-sale-sum:screen-value = string(f-sale-sum) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-other <>  ?  then do :
    c-f-sale-other:screen-value = string(f-sale-other) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-qnty-alt <>  ?  then do :
    c-f-qnty-alt:screen-value = string(f-qnty-alt) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-sum-alt <>  ?  then do :
    c-f-cost-sum-alt:screen-value = string(f-cost-sum-alt) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-sum-alt <>  ?  then do :
    c-f-sale-sum-alt:screen-value = string(f-sale-sum-alt) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-other-alt <>  ?  then do :
    c-f-sale-other-alt:screen-value = string(f-sale-other-alt) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
                      display stream OutStream  no-error .
                      DOWN stream OutStream .
                      if Make-Excel then  put   stream ForExcel unformatted
                        string(n-nn)                      CHR(9)
                        v-bar-code                        CHR(9)
                        (gds-list.artic)                  CHR(9)
                        gds-list.gds-name                 CHR(9)
                                                          CHR(9)
                        excel-qnty(f-qnty        )        CHR(9)
                        excel-sum (f-cost-sum    )        CHR(9)
                        excel-sum (f-sale-sum    )        CHR(9)
                        excel-sum (f-sale-other  )        CHR(9)
                        excel-qnty(f-qnty-alt        )    CHR(9)
                        excel-sum (f-cost-sum-alt    )    CHR(9)
                        excel-sum (f-sale-sum-alt    )    CHR(9)
                        excel-sum (f-sale-other-alt  )    CHR(9)
                        chr(10) .
                        Run Display-prt in this-procedure  .
                    end.
             End.
              accumulate f-qnty               (TOTAL  by gds-list.qnty ) .
              accumulate f-cost-sum           (TOTAL  by gds-list.qnty ) .
              accumulate f-sale-sum           (TOTAL  by gds-list.qnty ) .
              accumulate f-sale-other         (TOTAL  by gds-list.qnty ) .
              accumulate f-qnty-alt           (TOTAL  by gds-list.qnty ) .
              accumulate f-cost-sum-alt       (TOTAL  by gds-list.qnty ) .
              accumulate f-sale-sum-alt       (TOTAL  by gds-list.qnty ) .
              accumulate f-sale-other-alt     (TOTAL  by gds-list.qnty ) .
                Assign
                  f-qnty              = 0
                  f-cost-sum          = 0
                  f-sale-sum          = 0
                  f-sale-other        = 0
                  f-qnty-alt          = 0
                  f-cost-sum-alt      = 0
                  f-sale-sum-alt      = 0
                  f-sale-other-alt    = 0
                 .
          End.
          if last-of(gds-list.qnty)  then do :
            f-artic = 'по ставке НДС ' .
  if c-nn <>  ?  then do :
    c-nn:screen-value = string('Итого') .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-artic <>  ?  then do :
    c-f-artic:screen-value = string(f-artic) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-gds-name <>  ?  then do :
    c-f-gds-name:screen-value = string(var-client) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-qnty <>  ?  then do :
    c-f-qnty:screen-value = string(accum TOTAL by gds-list.qnty f-qnty    ) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-sum <>  ?  then do :
    c-f-cost-sum:screen-value = string(accum TOTAL by gds-list.qnty f-cost-sum ) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-sum <>  ?  then do :
    c-f-sale-sum:screen-value = string(accum TOTAL  by gds-list.qnty  f-sale-sum) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-other <>  ?  then do :
    c-f-sale-other:screen-value = string(accum TOTAL by  gds-list.qnty  f-sale-other) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-qnty-alt <>  ?  then do :
    c-f-qnty-alt:screen-value = string(accum TOTAL by gds-list.qnty f-qnty-alt    ) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-sum-alt <>  ?  then do :
    c-f-cost-sum-alt:screen-value = string(accum TOTAL by gds-list.qnty f-cost-sum-alt ) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-sum-alt <>  ?  then do :
    c-f-sale-sum-alt:screen-value = string(accum TOTAL  by gds-list.qnty  f-sale-sum-alt) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-other-alt <>  ?  then do :
    c-f-sale-other-alt:screen-value = string(accum TOTAL by  gds-list.qnty  f-sale-other-alt) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
              Display stream OutStream  no-error .
              DOWN stream OutStream .
              if Make-Excel then  put   stream ForExcel unformatted
              "Итого"                                              CHR(9)
              'по ставке НДС '
              var-client                                           CHR(9) CHR(9) CHR(9) CHR(9)
              excel-qnty(accum TOTAL by gds-list.qnty  f-qnty           )    CHR(9)
              excel-sum (accum TOTAL by gds-list.qnty  f-cost-sum       )   CHR(9)
              excel-sum (accum TOTAL by gds-list.qnty  f-sale-sum       )   CHR(9)
              excel-sum (accum TOTAL by gds-list.qnty  f-sale-other     )   CHR(9)
              excel-qnty(accum TOTAL by gds-list.qnty  f-qnty-alt           )    CHR(9)
              excel-sum (accum TOTAL by gds-list.qnty  f-cost-sum-alt       )   CHR(9)
              excel-sum (accum TOTAL by gds-list.qnty  f-sale-sum-alt       )   CHR(9)
              excel-sum (accum TOTAL by gds-list.qnty  f-sale-other-alt     )   CHR(9)
              chr(10) .
          End.
 End.
 run u-line.
  if c-nn <>  ?  then do :
    c-nn:screen-value = string('ИТОГО') .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-artic <>  ?  then do :
    c-f-artic:screen-value = string('по объектам') .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-qnty <>  ?  then do :
    c-f-qnty:screen-value = string(accum TOTAL f-qnty) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-sum <>  ?  then do :
    c-f-cost-sum:screen-value = string(accum TOTAL f-cost-sum) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-sum <>  ?  then do :
    c-f-sale-sum:screen-value = string(accum TOTAL f-sale-sum) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-other <>  ?  then do :
    c-f-sale-other:screen-value = string(accum TOTAL f-sale-other) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-qnty-alt <>  ?  then do :
    c-f-qnty-alt:screen-value = string(accum TOTAL f-qnty-alt) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-sum-alt <>  ?  then do :
    c-f-cost-sum-alt:screen-value = string(accum TOTAL f-cost-sum-alt) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-sum-alt <>  ?  then do :
    c-f-sale-sum-alt:screen-value = string(accum TOTAL f-sale-sum-alt) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-other-alt <>  ?  then do :
    c-f-sale-other-alt:screen-value = string(accum TOTAL f-sale-other-alt) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  Display stream OutStream with FRAME Zapas no-error.
  DOWN stream OutStream with FRAME Zapas.
  run u-line.
  if Make-Excel then  put   stream ForExcel unformatted
          "ИТОГО"                         CHR(9)
          "по объектам"                    CHR(9)
                                             CHR(9) CHR(9) CHR(9)
          excel-qnty(accum TOTAL f-qnty           )  CHR(9)
          excel-sum (accum TOTAL f-cost-sum       )  CHR(9)
          excel-sum (accum TOTAL f-sale-sum       )  CHR(9)
          excel-sum (accum TOTAL f-sale-other    )   CHR(9)
          excel-qnty(accum TOTAL f-qnty-alt           )  CHR(9)
          excel-sum (accum TOTAL f-cost-sum-alt       )  CHR(9)
          excel-sum (accum TOTAL f-sale-sum-alt       )  CHR(9)
          excel-sum (accum TOTAL f-sale-other-alt    )   CHR(9)
          chr(10) .
END PROCEDURE.
PROCEDURE Display-prt :
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$".
IF gds-list.prt-root <> Prtroot Then DO:
    for each ub.gds-prt no-lock where
        ub.gds-prt.prt-root = gds-list.prt-root and
        ub.gds-prt.IS-term   =  true
        by ub.gds-prt.f-name with FRAME Zapas :
            For each obj-list no-lock :
                for each ub.prt-obj no-lock where
                    ub.prt-obj.artic     = gds-list.artic     and
                    ub.prt-obj.prod-type = gds-list.prod-type and
                    ub.prt-obj.prod-code = gds-list.prod-code and
                    ub.prt-obj.obj-code  = obj-list.obj-code and
                    ub.prt-obj.obj-type  = obj-list.obj-type and
                    ub.prt-obj.IS-term   =  true and
                    ub.prt-obj.prt-code  = ub.gds-prt.node-code :
                    Assign
                      p-qnty      = p-qnty       + ub.prt-obj.free-qnty
                      p-sale-sum  = p-sale-sum   + ub.prt-obj.free-qnty * ub.prt-obj.price-sale .
                End.
            End.
            Assign
              p-cost-sum     = determined( f-cost-sum * p-qnty  / f-qnty)
              p-sale-other   = 100 * determined((p-sale-sum - p-cost-sum) / p-cost-sum)
              .
            For each alt-obj-list no-lock :
                for each ub.prt-obj no-lock where
                    ub.prt-obj.artic     = gds-list.artic     and
                    ub.prt-obj.prod-type = gds-list.prod-type and
                    ub.prt-obj.prod-code = gds-list.prod-code and
                    ub.prt-obj.obj-code  = alt-obj-list.obj-code and
                    ub.prt-obj.obj-type  = alt-obj-list.obj-type and
                    ub.prt-obj.IS-term   = true and
                    ub.prt-obj.prt-code  = ub.gds-prt.node-code
                    :
                    assign
                      p-qnty-alt      = p-qnty-alt       + ub.prt-obj.free-qnty
                      p-sale-sum-alt  = p-sale-sum-alt   + ub.prt-obj.free-qnty * ub.prt-obj.price-sale
                   .
                end.
            end.
            assign
              p-cost-sum-alt     = determined( f-cost-sum-alt * p-qnty-alt  / f-qnty-alt)
              p-sale-other-alt   = 100 * determined ((p-sale-sum-alt - p-cost-sum-alt) / p-cost-sum-alt)
              .
            if  NOT(
                  p-qnty      =  0  and
                  p-cost-sum    =  0  and
                  p-sale-sum    =  0  and
                  p-sale-other  =  0 and
                  p-qnty-alt      =  0  and
                  p-cost-sum-alt    =  0  and
                  p-sale-sum-alt    =  0  and
                  p-sale-other-alt  =  0
                  ) then DO:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  gds-list.gds-code
  ,input  ub.gds-prt.node-code
  ,output v-bar-code
  )  .
  if c-nn <>  ?  then do :
    c-nn:screen-value = string('') .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-artic <>  ?  then do :
    c-f-artic:screen-value = string('') .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-b-code <>  ?  then do :
    c-f-b-code:screen-value = string(string(v-bar-code,'999999999')) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-prt-name <>  ?  then do :
    c-f-prt-name:screen-value = string(ub.gds-prt.f-name) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-qnty <>  ?  then do :
    c-f-qnty:screen-value = string(p-qnty) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-sum <>  ?  then do :
    c-f-cost-sum:screen-value = string(p-cost-sum) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-sum <>  ?  then do :
    c-f-sale-sum:screen-value = string(p-sale-sum) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-other <>  ?  then do :
    c-f-sale-other:screen-value = string(p-sale-other) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-qnty-alt <>  ?  then do :
    c-f-qnty-alt:screen-value = string(p-qnty-alt) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-sum-alt <>  ?  then do :
    c-f-cost-sum-alt:screen-value = string(p-cost-sum-alt) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-sum-alt <>  ?  then do :
    c-f-sale-sum-alt:screen-value = string(p-sale-sum-alt) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-other-alt <>  ?  then do :
    c-f-sale-other-alt:screen-value = string(p-sale-other-alt) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
                Display stream OutStream no-error.
                DOWN stream OutStream .
                    if Make-Excel then  put   stream ForExcel unformatted
                     string(n-nn)                 CHR(9)
                     v-bar-code                   CHR(9)
                                                  CHR(9)
                                                  CHR(9)
                     ub.gds-prt.f-name               CHR(9)
                     excel-qnty(p-qnty        )   CHR(9)
                     excel-sum (p-cost-sum    )   CHR(9)
                     excel-sum (p-sale-sum    )   CHR(9)
                     excel-sum (p-sale-other  )   CHR(9)
                     excel-qnty(p-qnty-alt      ) CHR(9)
                     excel-sum (p-cost-sum-alt  ) CHR(9)
                     excel-sum (p-sale-sum-alt  ) CHR(9)
                     excel-sum (p-sale-other-alt) CHR(9)
                     chr(10) .
            End.
            Assign
              p-qnty            =  0
              p-cost-sum        =  0
              p-sale-sum        =  0
              p-sale-other      =  0
              p-qnty-alt        =  0
              p-cost-sum-alt    =  0
              p-sale-sum-alt    =  0
              p-sale-other-alt  =  0
              .
    End.
End.
END PROCEDURE.
PROCEDURE on-same-page :
  define input parameter p-line-number as integer  no-undo .
  if p-line-number > page-size( OutStream ) then do:
    return .
  end.
  if line-counter( OutStream ) + p-line-number > page-size( OutStream ) then do:
    page stream OutStream .
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
procedure init-gds-list :
  do
  on error undo, return error return-value
  :
  run waitfram-show ( "Подготовка списка товара..." ).
    if x-SelectGood <> 1 then do:
        for each obj-list :
           for each ub.gds-obj no-lock where ub.gds-obj.obj-type =  obj-list.obj-type and
                                          ub.gds-obj.obj-code =  obj-list.obj-code   :
                find first gds-list      where gds-list.gds-code = ub.gds-obj.gds-code no-error .
                if available gds-list then do:
                    if gds-list.gds-type   <> 'т':U or (p-show-qnty = true  and ub.gds-obj.free-qnty <= 0 ) then do:
                          delete gds-list .
                    end.
                    else do:
                       if classify = 4 then
                       gds-list.qnty = func-vat (gds-list.gds-code,ub.gds-obj.obj-type,ub.gds-obj.obj-code) .
                    end.
                end.
           end.
        end.
    end.
    else do:
        for each obj-list :
           for each ub.gds-obj no-lock where ub.gds-obj.obj-type =  obj-list.obj-type and
                                          ub.gds-obj.obj-code =  obj-list.obj-code   :
                find first gds-list      where gds-list.gds-code = ub.gds-obj.gds-code no-error .
                if not available gds-list then do:
                    if (p-show-qnty = true  and ub.gds-obj.free-qnty > 0) or p-show-qnty = false then do:
                        find first ub.goods no-lock where ub.goods.gds-code = ub.gds-obj.gds-code no-error .
                        create gds-list.
                        BUFFER-COPY ub.goods TO gds-list.
                         if classify = 4 then
                         gds-list.qnty = func-vat (gds-list.gds-code,ub.gds-obj.obj-type,ub.gds-obj.obj-code) .
                    end.
                end.
           end.
        end.
    end.
    if p-show-qnty = false  and x-SelectGood = 1  then do:
        for each alt-obj-list :
          for each ub.gds-obj no-lock where ub.gds-obj.obj-type =  alt-obj-list.obj-type and
                                          ub.gds-obj.obj-code =  alt-obj-list.obj-code
          :
            find first gds-list      where gds-list.gds-code = ub.gds-obj.gds-code no-error .
            if not available gds-list then do:
                find first ub.goods no-lock where ub.goods.gds-code = ub.gds-obj.gds-code no-error .
                create gds-list.
                BUFFER-COPY ub.goods TO gds-list.
                  if classify = 4 then
                  gds-list.qnty = func-vat (gds-list.gds-code,ub.gds-obj.obj-type,ub.gds-obj.obj-code) .
            end.
          end.
        end.
    end.
end.
end procedure.
