block-level on error undo, throw.
define input parameter parparentproc            as widget-handle           no-undo .
define input parameter dateTo as date no-undo .
define input parameter dateFrom as date no-undo .
define input parameter onlyDel as logical no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Отчет по удаленным чека".
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
function fnc-convert-dot-to-colon returns character
    (input p-data as decimal, input p-accur as character, input p-num as integer) forward.
function fnc-convert-dot-to-colon returns character
(input p-data as decimal, input p-accur as character, input p-num as integer):
    define variable result as character no-undo.
    define variable v-str-result as character no-undo.
    if p-data = ? then p-data = 0 .
    p-data = round(p-data, p-num).
    v-str-result = trim(replace(string(p-data, p-accur), ".", ",")).
    return v-str-result.
END FUNCTION.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  stream PrnLibStream.
procedure prn-lib-prn-file :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-DIsabledoptions as integer no-undo .
  define variable v-report-name as character no-undo .
  define variable v-user-action as character no-undo .
  define variable v-printed     as logical   no-undo .
  define variable v-exist       as logical   no-undo .
  do
    on error undo, return error
    :
    run prn-lib-get-report-name  in this-procedure (
      input parParentProc
      ,output v-report-name
      ).
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run filenmln in g#library
  (input  v-report-name
  ,input  2
  ,output v-exist
  )  .
    if NOT v-exist then
    DO:
      Message
        "Нет заданий на печать ! "
        view-as alert-box .
      Return  .
    End.
    run gbl/prnfilen.w
      (input  ""
      ,input  p-DisabledOptions
      ,input  string(v-report-name )
      ,input  7
      ,output v-user-action
      ,output v-printed
      ) .
    if v-printed then
    do:
      return "YES" .
    end.
    else
    do:
      return "NO" .
    end.
  end.
end procedure.
procedure prn-lib-open-stream :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-page-size    as integer no-undo .
  define input parameter p-is-stream    as logical no-undo .
  define input parameter p-append       as logical no-undo .
  define variable v-report-name as character no-undo .
  do
    on error undo, return error
    :
    run prn-lib-get-report-name  in this-procedure (
      input parParentProc
      ,output v-report-name
      ).
    if p-is-stream then
    do:
      if p-append then
      do:
        output stream PrnLibStream to value( v-report-name )
          page-size value(p-page-size) append .
      end.
      if not p-append then
      do:
        output stream PrnLibStream to value( v-report-name )
          page-size value(p-page-size) .
      end.
    end.
    if not p-is-stream then
    do:
      if p-append then
      do:
        output to value( v-report-name )
          page-size value(p-page-size) append .
      end.
      if not p-append then
      do:
        output to value( v-report-name )
          page-size value(p-page-size) .
      end.
    end.
  end.
end procedure.
procedure prn-lib-open-exp :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-is-stream    as logical no-undo .
  define input parameter p-is-append    as logical no-undo .
  define output parameter p-ReportFileName as char init "report" no-undo.
  define output parameter p-process as logical no-undo .
  define variable glog as logical no-undo .
  do
    on error undo, return error
    :
    SYSTEM-DIALOG GET-FILE p-ReportFileName
      TITLE      "Укажите путь"
      FILTERS "Текстовый файл (*.txt)"   "*.txt"
      ASK-OVERWRITE
      CREATE-TEST-FILE
      SAVE-AS
      USE-FILENAME
      DEFAULT-EXTENSION "txt"
      UPDATE glog
      .
    if not glog then  return.
    p-ReportFileName = trim( string( p-ReportFileName ) ) .
    if p-is-stream then
    do:
      if p-is-append then
      do:
        OUTPUT stream PrnLibStream TO value ( p-ReportFileName ) PAGE-SIZE 0 append.
      end.
      else
      do:
        OUTPUT stream PrnLibStream TO value ( p-ReportFileName ) PAGE-SIZE 0.
      end.
    end.
    else
    do:
      if p-is-append then
      do:
        OUTPUT TO value ( p-ReportFileName ) PAGE-SIZE 0 append.
      end.
      else
      do:
        OUTPUT TO value ( p-ReportFileName ) PAGE-SIZE 0.
      end.
    end.
    p-process = yes.
  end.
end procedure.
procedure prn-lib-get-report-name :
  define input parameter parParentProc  as widget-handle no-undo.
  define output parameter p-report-name as character no-undo .
  p-report-name = ibs.th.gbl.gbl-inipar:prn-lib-get-report-name("rpt").
end procedure.
procedure prn-lib-reportviewer-report-name :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-report-name-html as character no-undo .
  ibs.th.gbl.gbl-inipar:prn-lib-reportviewer-report-name(p-report-name-html) no-error.
end procedure.
procedure prn-lib-reportviewer :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-report-name-html as character no-undo .
  define input parameter p-param        as character no-undo .
  define variable v-excel           as character no-undo init 'TRUE' .
  define variable v-value-character as character no-undo .
  define variable v-value-integer   as character no-undo .
  define variable v-value-date      as date      no-undo .
  define variable v-value-decimal   as decimal   no-undo .
  define variable rep-excel         as logical   no-undo .
  define variable excel-string      as character no-undo .
  define variable v-param-type      as character no-undo .
  define variable v-tth             as handle    no-undo .
  run adm/shattri.p (
    input "get":U
    ,input  ""
    ,input  0
    ,input  'report-glob':U
    ,input  'rep-excel':U
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output rep-excel
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    )  .
  if rep-excel then v-excel = "TRUE" .
  else v-excel = "FALSE" .
  if p-param eq ""
  then
     p-param = "EXCEL:" + v-excel.
  else
     p-param = p-param + chr(4) + "EXCEL:" + v-excel .
  ibs.th.gbl.gbl-inipar:prn-lib-reportviewer(p-report-name-html, p-param).
end procedure.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function usrfulnf returns character ( input p-user-id as character):
define variable v-user-name as character no-undo .
define variable vss-include-info10 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usrfulnm in g#library
  (input  p-user-id
  ,output v-user-name
  ) no-error .
if error-status:error
or v-user-name = ""
then do:
  return p-user-id.
end.
else do:
  return v-user-name.
end.
end function.
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
define temp-table tt-errorChk no-undo
field attr-code as character
field attr-value as character
field is-true as logical
.
create tt-errorChk .
assign
tt-errorChk.attr-code = "Сум-ош"
tt-errorChk.attr-value = "нулевая сумма оплат по чеку;"
.
create tt-errorChk .
assign
tt-errorChk.attr-code = "Карт-ош"
tt-errorChk.attr-value = "номер дисконтной карты отсутствует в справочнике дис-контных карт;"
.
create tt-errorChk .
assign
tt-errorChk.attr-code = "Сер-ош"
tt-errorChk.attr-value = "серийный товар продан не по бар-коду;"
.
create tt-errorChk .
assign
tt-errorChk.attr-code = "При-ош"
tt-errorChk.attr-value = "товар с непустой шкалой признаков продан по бар-коду артикула;"
.
create tt-errorChk .
assign
tt-errorChk.attr-code = "Смн-ош"
tt-errorChk.attr-value = "ошибка в номере смены;"
.
create tt-errorChk .
assign
tt-errorChk.attr-code = "Опл-ош"
tt-errorChk.attr-value = "код оплаты не найден в справочнике типов кассового платежа;"
.
create tt-errorChk .
assign
tt-errorChk.attr-code = "Скидка-ош"
tt-errorChk.attr-value = "если скидка на итог чека дана не в последней строке чека;"
.
create tt-errorChk .
assign
tt-errorChk.attr-code = "Тов-ош"
tt-errorChk.attr-value = "товары и услуги внутри одного чека, в чеке топливный то-вар при номере ТРК=0, в чеке не топливный товар при номере ТРК<>0;"
.
create tt-errorChk .
assign
tt-errorChk.attr-code = "Кол-ош"
tt-errorChk.attr-value = "штучный товар продан дробным количеством;"
.
create tt-errorChk .
assign
tt-errorChk.attr-code = "Прт-ош"
tt-errorChk.attr-value = "партионный товар в чеке пробит по бар-коду артикула (при-знака);"
.
create tt-errorChk .
assign
tt-errorChk.attr-code = "0"
tt-errorChk.attr-value = "товар не найден в базе данных. Товар может быть действительно не найден в базе данных или по това-ру не прошел контроль цен чеков, устанавливаемый в пункте меню Сервис/Контроль цен чеков"
.
create tt-errorChk .
assign
tt-errorChk.attr-code = ""
tt-errorChk.attr-value = "меню Сервис/Контроль цен чеков;"
.
create tt-errorChk .
assign
tt-errorChk.attr-code = "?"
tt-errorChk.attr-value = "в чеке не заполнены одно или несколько обязательных полей (то-вар, тип оплат и т.д.), нулевое ко-личество по товарным позициям;"
.
create tt-errorChk .
assign
tt-errorChk.attr-code = "Перс-ош"
tt-errorChk.attr-value = "не указан кассир;"
.
define temp-table tt-Chk no-undo
field attr-code as character
field attr-value as character
field is-true as logical
.
create tt-Chk .
assign
tt-Chk.attr-code = "T"
tt-Chk.attr-value = "товар означает, что чек не имеет ошибок и может быть включен в продажу"
.
create tt-Chk .
assign
tt-Chk.attr-code = "У"
tt-Chk.attr-value = "услуга означает, что чек не имеет ошибок и может быть включен в продажу"
.
function ChkGdsPromo returns logical
    (input iDocCode as character)
    :
    define buffer buf_chk-gds for ub.chk-gds.
    define buffer buf_chk-gds-attr for ub.chk-gds-attr.
    define variable vPromo as logical no-undo.
    vPromo = no.
    cspr:
    for each buf_chk-gds no-lock where
                 buf_chk-gds.doc-code = iDocCode,
           first buf_chk-gds-attr no-lock where
                 buf_chk-gds-attr.doc-code = buf_chk-gds.doc-code
             and buf_chk-gds-attr.line-num  = buf_chk-gds.line-num
             and buf_chk-gds-attr.attr-code = "CSPromo"
             and buf_chk-gds-attr.attr-value <> "0":
       vPromo = yes.
       leave cspr.
    end.
    return vPromo.
end.
function ChkPromoLine returns logical
    (input iDocCode as character,
    input iLineNum as integer)
    :
    define buffer buf_chk-gds for ub.chk-gds.
    define buffer buf_chk-gds-attr for ub.chk-gds-attr.
    define variable vPromo as logical no-undo.
    vPromo = no.
    find first buf_chk-gds-attr no-lock where
                 buf_chk-gds-attr.doc-code = iDocCode
             and buf_chk-gds-attr.line-num  = iLineNum
             and buf_chk-gds-attr.attr-code = "CSPromo"
             and buf_chk-gds-attr.attr-value <> "0"
    no-error.
    if avail buf_chk-gds-attr then vPromo = yes.
    return vPromo.
end.
function ChkPromoSum returns decimal
    (input iDocCode as character,
     input iLineNum as integer)
    :
   define buffer buf_chk-gds-attr for ub.chk-gds-attr.
   define variable vSumPromo as decimal no-undo.
   find first buf_chk-gds-attr no-lock where
              buf_chk-gds-attr.doc-code = iDocCode
          and buf_chk-gds-attr.line-num  = iLineNum
          and buf_chk-gds-attr.attr-code = "CSPromoSum"
      no-error.
   if avail buf_chk-gds-attr then
      vSumPromo = DEC(buf_chk-gds-attr.attr-value) no-error.
   return vSumPromo.
end function.
function ChkPromoPrice returns logical
    (input iDocCode as character,
     input iLineNum as integer)
    :
   define buffer buf_chk-gds-attr for ub.chk-gds-attr.
   define variable v-is-promo as logical no-undo.
   v-is-promo = no.
   find first buf_chk-gds-attr no-lock where
              buf_chk-gds-attr.doc-code = iDocCode
          and buf_chk-gds-attr.line-num  = iLineNum
          and buf_chk-gds-attr.attr-code = "CSPromo"
      no-error.
   if avail buf_chk-gds-attr
     and can-do("2,4,5,7", buf_chk-gds-attr.attr-value)
   then v-is-promo = yes.
   return v-is-promo.
end function.
function ChkDopLitr returns logical
    (input iDocCode as character,
     input iLineNum as integer)
    :
   define buffer buf_chk-gds-attr for ub.chk-gds-attr.
   define variable v-is-promo as logical no-undo.
   v-is-promo = no.
   find first buf_chk-gds-attr no-lock where
              buf_chk-gds-attr.doc-code = iDocCode
          and buf_chk-gds-attr.line-num  = iLineNum
          and buf_chk-gds-attr.attr-code = "CSPromo"
      no-error.
   if avail buf_chk-gds-attr and
     buf_chk-gds-attr.attr-value = "3"
   then v-is-promo = yes.
   return v-is-promo.
end function.
function RoundUp return decimal
    (input iQnty as decimal,
     input iPrice as decimal):
    def var vSum  as decimal no-undo.
    def var vSumR as decimal no-undo.
    vSum = ABSOLUTE(iQnty) * iPrice.
    vSumR = Round(vSum,2).
    if vSumR < vSum then vSumR = vSumR + 0.01.
    if iQnty < 0 then vSumR = - vSumR.
    return vSumR.
end function.
function GetPromoSum returns decimal
    (input iDocCode as character)
    :
    define buffer buf_chk-doc for ub.chk-doc.
    define buffer buf2_chk-doc for ub.chk-doc.
    define buffer buf_chk-gds for ub.chk-gds.
    define buffer buf_chk-gds-attr for ub.chk-gds-attr.
    define buffer buf2_chk-gds for ub.chk-gds.
    define buffer buf2_chk-gds-attr for ub.chk-gds-attr.
    define variable v-price-base as decimal no-undo.
    define variable v-doc-qnty as decimal no-undo.
    define variable v-sum-base as decimal no-undo.
    define variable v-sum-all as decimal no-undo.
    define variable v-sum-promo as decimal no-undo.
    define variable v-sum-chk as decimal no-undo.
    assign
       v-price-base = 0
       v-doc-qnty = 0
       v-sum-all = 0
       v-sum-chk = 0
       v-sum-promo = 0
       .
    for each buf_chk-gds no-lock where
             buf_chk-gds.doc-code = iDocCode,
       first buf_chk-gds-attr no-lock where
             buf_chk-gds-attr.doc-code = buf_chk-gds.doc-code
         and buf_chk-gds-attr.line-num  = buf_chk-gds.line-num
         and buf_chk-gds-attr.attr-code = "CSPromoSum"
       :
       v-sum-promo = Dec(buf_chk-gds-attr.attr-value).
    end.
    if v-sum-promo = 0 then do:
        for each buf_chk-gds no-lock where
                 buf_chk-gds.doc-code = iDocCode,
           first buf_chk-gds-attr no-lock where
                 buf_chk-gds-attr.doc-code = buf_chk-gds.doc-code
             and buf_chk-gds-attr.line-num  = buf_chk-gds.line-num
             and buf_chk-gds-attr.attr-code = "CSPromo"
             and can-do("1,6", buf_chk-gds-attr.attr-value)
           :
           assign
             v-price-base = buf_chk-gds.price-base
             v-doc-qnty   = if buf_chk-gds.doc-qnty = ? then buf_chk-gds.src-qnty else buf_chk-gds.doc-qnty
             v-sum-base = if buf_chk-gds.sum-base = ? then round(v-doc-qnty * v-price-base, 2) else buf_chk-gds.sum-base
             .
        end.
        for each buf_chk-gds no-lock where
                 buf_chk-gds.doc-code = iDocCode,
           first buf_chk-gds-attr no-lock where
                 buf_chk-gds-attr.doc-code = buf_chk-gds.doc-code
             and buf_chk-gds-attr.line-num  = buf_chk-gds.line-num
             and buf_chk-gds-attr.attr-code = "CSPromo"
             and can-do("2,4,5,7", buf_chk-gds-attr.attr-value)
           :
           if v-price-base = 0 then do:
              find first buf_chk-doc no-lock where
                         buf_chk-doc.doc-code = iDocCode
                  no-error.
              if avail buf_chk-doc and
                 buf_chk-doc.chk-type = int('6':U) and
                 buf_chk-doc.doc-num2 > ""  and
                 num-entries(buf_chk-doc.doc-num2,":") = 2
              then
              for first buf2_chk-doc no-lock where
                        buf2_chk-doc.obj-code = buf_chk-doc.obj-code
                    and buf2_chk-doc.obj-type = buf_chk-doc.obj-type
                    and buf2_chk-doc.chk-type = int('1':U)
                    and buf2_chk-doc.chk-num = int(entry(1,buf_chk-doc.doc-num2,":"))
                    and buf2_chk-doc.z-number = int(entry(2, buf_chk-doc.doc-num2,":"))
                    :
                for each buf2_chk-gds no-lock where
                         buf2_chk-gds.doc-code = buf2_chk-doc.doc-code,
                   first buf2_chk-gds-attr no-lock where
                         buf2_chk-gds-attr.doc-code = buf2_chk-gds.doc-code
                     and buf2_chk-gds-attr.line-num  = buf2_chk-gds.line-num
                     and buf2_chk-gds-attr.attr-code = "CSPromo"
                     and can-do("1,6", buf2_chk-gds-attr.attr-value)
                   :
                    v-price-base = buf2_chk-gds.price-base.
                end.
              end.
           end.
           if buf_chk-gds.sum-base = ? or buf_chk-gds.src-qnty = 0 then do:
               assign
                  v-sum-all = (buf_chk-gds.src-qnty + v-doc-qnty) * v-price-base
                  v-sum-chk = v-sum-base + RoundUp(buf_chk-gds.src-qnty, buf_chk-gds.src-price)
                  .
           end.
           else do:
              assign
              v-sum-all = (buf_chk-gds.doc-qnty + v-doc-qnty ) * v-price-base
              v-sum-chk = v-sum-base + buf_chk-gds.sum-base
              .
           end.
        end.
        v-sum-promo = Round(v-sum-all, 2) - Round(v-sum-chk, 2).
    end.
    return v-sum-promo.
end function.
function GetUnBaseSum returns decimal
    (input iDocCode as character,
     input iLineNum as integer,
     input iQnty as decimal,
     input iPrice as decimal):
   define buffer buf_chk-gds-attr for ub.chk-gds-attr.
   define variable vBaseSum as decimal no-undo.
   define variable vDiscSum as decimal no-undo.
   vDiscSum = 0.
   find first buf_chk-gds-attr no-lock where
                     buf_chk-gds-attr.doc-code = iDocCode
                 and buf_chk-gds-attr.line-num  = iLineNum
                 and buf_chk-gds-attr.attr-code = "CSPromoSum"
          no-error.
   if avail buf_chk-gds-attr then
      vDiscSum = dec(buf_chk-gds-attr.attr-value) no-error.
   vBaseSum = iQnty * iPrice + vDiscSum.
   if vDiscSum = 0 and ChkPromoPrice(iDocCode, iLineNum) then
      vBaseSum = RoundUp(iQnty, iPrice).
   return vBaseSum.
end function.
function GetRoundSum returns decimal
    (input iDocCode as character,
     input iLineNum as integer,
     input iQnty as decimal,
     input iPrice as decimal):
   define buffer buf_chk-gds-attr for ub.chk-gds-attr.
   define variable vBaseSum as decimal no-undo.
   if ChkPromoPrice(iDocCode, iLineNum) then
      vBaseSum = RoundUp(iQnty, iPrice).
   else vBaseSum = iQnty * iPrice.
   return vBaseSum.
end function.
function GetRoundSumChkDel returns decimal
    (input iDocCode as character,
     input iLineNum as integer,
     input iChipNum as integer,
     input iQnty as decimal,
     input iPrice as decimal):
   define buffer  buf_c-chk-doc-attr for ub.c-chk-doc-attr.
   define variable vBaseSum as decimal no-undo.
   define variable vIsPromo as logical no-undo.
   for each buf_c-chk-doc-attr no-lock where
            buf_c-chk-doc-attr.doc-code = iDocCode
        and buf_c-chk-doc-attr.chip-num = iChipNum
       :
       if num-entries(buf_c-chk-doc-attr.attr-code, chr(4)) > 1
       then do :
         if entry(1, buf_c-chk-doc-attr.attr-code, chr(4)) begins "gds="
         and entry(2, buf_c-chk-doc-attr.attr-code, chr(4)) = "CSPromo"
         and entry(2, entry(1, buf_c-chk-doc-attr.attr-code, chr(4)), "=") = String(iLineNum)
         and can-do("2,4,5,7", buf_c-chk-doc-attr.attr-value)
         then vIsPromo = yes.
       end.
   end.
   if ChkPromoPrice(iDocCode, iLineNum) then
      vBaseSum = RoundUp(iQnty, iPrice).
   else vBaseSum = iQnty * iPrice.
   return vBaseSum.
end function.
function GetSaleRetDisc returns decimal
    (input iDocCode as character,
     input iSaleCode as character):
   define buffer buf_chk-gds-attr for ub.chk-gds-attr.
   define buffer buf_chk-gds for ub.chk-gds.
   define variable vQntyPromoRet as decimal no-undo.
   define variable vQntyPromoSel as decimal no-undo.
   define variable vDiscSumRet   as decimal no-undo.
   define variable vDiscSumSale  as decimal no-undo.
   vDiscSumRet = 0.
   cspr:
   for each  buf_chk-gds no-lock where
             buf_chk-gds.doc-code = iDocCode,
       first buf_chk-gds-attr no-lock where
             buf_chk-gds-attr.doc-code  = buf_chk-gds.doc-code
         and buf_chk-gds-attr.line-num  = buf_chk-gds.line-num
         and buf_chk-gds-attr.attr-code = "CSPromo"
         and can-do("2,4,5,7", buf_chk-gds-attr.attr-value)
       :
       vQntyPromoRet = buf_chk-gds.src-qnty.
       leave cspr.
   end.
   if vQntyPromoRet <> 0 then
   for each  buf_chk-gds no-lock where
             buf_chk-gds.doc-code = iSaleCode:
       find first buf_chk-gds-attr no-lock where
                  buf_chk-gds-attr.doc-code  = buf_chk-gds.doc-code
              and buf_chk-gds-attr.line-num  = buf_chk-gds.line-num
              and buf_chk-gds-attr.attr-code = "CSPromo"
       no-error.
       if avail buf_chk-gds-attr
            and can-do("2,4,5,7", buf_chk-gds-attr.attr-value)
       then
         vQntyPromoSel = buf_chk-gds.src-qnty.
       find first buf_chk-gds-attr no-lock where
                 buf_chk-gds-attr.doc-code  = buf_chk-gds.doc-code
             and buf_chk-gds-attr.line-num  = buf_chk-gds.line-num
             and buf_chk-gds-attr.attr-code = "CSPromoSum"
       no-error.
       if avail buf_chk-gds-attr then
          vDiscSumSale = dec(buf_chk-gds-attr.attr-value) no-error.
   end.
   if vQntyPromoRet <> 0 and
      vQntyPromoSel = -1 * vQntyPromoRet
   then vDiscSumRet = -1 * vDiscSumSale.
   return vDiscSumRet.
end function.
function SetPromoDisc return logical
 (input iDocCode as character,
     input iLineNum as integer
     )
    :
   define buffer buf_chk-doc for ub.chk-doc.
   define buffer buf2_chk-doc for ub.chk-doc.
   define buffer buf_chk-gds for ub.chk-gds.
   define buffer buf2_chk-gds for ub.chk-gds.
   define buffer buf_chk-gds-attr for ub.chk-gds-attr.
   define buffer buf2_chk-gds-attr for ub.chk-gds-attr.
   define buffer buf_chk-discnt for ub.chk-discnt.
   define buffer buf2_chk-discnt for ub.chk-discnt.
   define buffer buf_chk-discnt-attr for ub.chk-discnt-attr.
   define buffer buf2_chk-discnt-attr for ub.chk-discnt-attr.
   define variable v-promo-sum as decimal no-undo.
   define variable v-disc-promo-id as character no-undo.
   define variable var-discnt-id as integer no-undo.
   define variable v-chk-sale as character no-undo.
   find first buf_chk-gds-attr no-lock where
              buf_chk-gds-attr.doc-code = iDocCode
          and buf_chk-gds-attr.line-num  = iLineNum
          and buf_chk-gds-attr.attr-code = "CSPromo"
      no-error.
   if avail buf_chk-gds-attr
     then do:
     find first buf_chk-discnt no-lock where
                buf_chk-discnt.doc-code = buf_chk-gds-attr.doc-code
            and buf_chk-discnt.line-num = buf_chk-gds-attr.line-num
            and buf_chk-discnt.record-type = 0
            and buf_chk-discnt.promo-id > ""
            no-error.
     if not avail buf_chk-discnt then do:
        find first buf_chk-doc no-lock where
                   buf_chk-doc.doc-code = iDocCode
           no-error.
        find first buf_chk-gds no-lock where
                   buf_chk-gds.doc-code = iDocCode
              and  buf_chk-gds.line-num = iLineNum
           no-error.
       for first buf2_chk-doc no-lock where
                 buf2_chk-doc.obj-code = buf_chk-doc.obj-code
             and buf2_chk-doc.obj-type = buf_chk-doc.obj-type
             and buf2_chk-doc.pay-desk = buf_chk-doc.pay-desk
             and buf2_chk-doc.chk-type = int('1':U)
             and buf2_chk-doc.chk-num  = int(entry(1,buf_chk-doc.doc-num2,":"))
             and buf2_chk-doc.z-number = int(entry(2, buf_chk-doc.doc-num2,":"))
           :
           find first buf2_chk-gds no-lock where
                      buf2_chk-gds.doc-code = buf2_chk-doc.doc-code
                 and  buf2_chk-gds.b-code   = buf_chk-gds.b-code
           no-error.
           if not avail buf2_chk-gds then return no.
           v-chk-sale = buf2_chk-doc.doc-code.
           find first buf_chk-discnt no-lock where
                      buf_chk-discnt.doc-code =  buf2_chk-doc.doc-code and
                      buf_chk-discnt.record-type = 1 and
                      buf_chk-discnt.object-line-num = buf2_chk-gds.line-num and
                      buf_chk-discnt.promo-id > ""
           no-error .
           if avail buf_chk-discnt
           then do:
              v-disc-promo-id = buf_chk-discnt.promo-id.
              find first buf2_chk-discnt no-lock where
                buf2_chk-discnt.doc-code = iDocCode and
                buf2_chk-discnt.record-type = 5 and
                buf2_chk-discnt.line-num = 0 and
                buf2_chk-discnt.promo-id =  v-disc-promo-id
              no-error.
              find first buf2_chk-discnt-attr no-lock where
                         buf2_chk-discnt-attr.doc-code = iDocCode and
                         buf2_chk-discnt-attr.record-type = 5 and
                         buf2_chk-discnt-attr.line-num = 0 and
                         buf2_chk-discnt-attr.attr-code = "promo-id" and
                         buf2_chk-discnt-attr.attr-value = v-disc-promo-id
                    no-error .
              if not avail buf2_chk-discnt
              then do:
                  for each buf_chk-discnt no-lock where
                           buf_chk-discnt.doc-code = buf_chk-gds-attr.doc-code
                       and buf_chk-discnt.record-type = 5:
                       var-discnt-id  = var-discnt-id + 1.
                  end.
                  create buf2_chk-discnt.
                  assign
                    buf2_chk-discnt.doc-code = iDocCode
                    buf2_chk-discnt.record-type = 5
                    buf2_chk-discnt.line-num = 0
                    buf2_chk-discnt.promo-id = v-disc-promo-id
                    buf2_chk-discnt.object-sum = 0
                    buf2_chk-discnt.discnt-id = if avail buf2_chk-discnt-attr
                                                   then buf2_chk-discnt-attr.discnt-id
                                                   else (var-discnt-id + 1)
                    var-discnt-id = 0
                    buf2_chk-discnt.object-line-num = 0
                    buf2_chk-discnt.pay-desk = buf_chk-doc.pay-desk
                    buf2_chk-discnt.obj-code = buf_chk-doc.obj-code
                    buf2_chk-discnt.obj-type = buf_chk-doc.obj-type
                    buf2_chk-discnt.chk-date = buf_chk-doc.chk-date
                    buf2_chk-discnt.shift-date = buf_chk-doc.shift-date
                    buf2_chk-discnt.shift-num = buf_chk-doc.shift-num
                    buf2_chk-discnt.chk-time = buf_chk-doc.chk-time
                    .
              end.
              if avail buf2_chk-discnt and
                 not avail buf2_chk-discnt-attr
              then do:
                 create buf2_chk-discnt-attr.
                 assign
                    buf2_chk-discnt-attr.doc-code = iDocCode
                    buf2_chk-discnt-attr.discnt-id = buf2_chk-discnt.discnt-id
                    buf2_chk-discnt-attr.record-type     = 5
                    buf2_chk-discnt-attr.line-num        = 0
                    buf2_chk-discnt-attr.object-line-num = 0
                    buf2_chk-discnt-attr.attr-code       = "promo-id"
                    buf2_chk-discnt-attr.attr-value      = v-disc-promo-id
                    .
              end.
           end.
       end.
        v-promo-sum = 0.
        if can-do("1,6,7", buf_chk-gds-attr.attr-value)
        then do:
           if v-chk-sale <> ? and v-chk-sale <> "" then
              v-promo-sum = GetSaleRetDisc(iDocCode,v-chk-sale).
           v-promo-sum = if v-promo-sum = 0 then GetPromoSum(iDocCode) else v-promo-sum.
           if v-promo-sum <> 0 then do:
               find first buf2_chk-gds-attr no-lock where
                          buf2_chk-gds-attr.doc-code = iDocCode
                      and buf2_chk-gds-attr.line-num  = iLineNum
                      and buf2_chk-gds-attr.attr-code = "CSPromoSum"
                  no-error.
               if not avail buf2_chk-gds-attr then do:
                   create buf2_chk-gds-attr.
                   assign
                      buf2_chk-gds-attr.doc-code = iDocCode
                      buf2_chk-gds-attr.line-num  = iLineNum
                      buf2_chk-gds-attr.attr-code = "CSPromoSum"
                      buf2_chk-gds-attr.attr-value = string(Round(v-promo-sum,2))
                      .
               end.
           end.
        end.
        for each buf_chk-discnt no-lock where
                buf_chk-discnt.doc-code = buf_chk-gds-attr.doc-code
            and buf_chk-discnt.record-type = 0:
           var-discnt-id  = var-discnt-id + 1.
        end.
        create buf_chk-discnt.
        assign
            buf_chk-discnt.doc-code = iDocCode
            buf_chk-discnt.line-num = iLineNum
            buf_chk-discnt.record-type = 0
            buf_chk-discnt.discnt-id = (var-discnt-id + 1)
            buf_chk-discnt.time-oper = buf_chk-gds.time-oper
            buf_chk-discnt.line-type = integer('1':U)
            buf_chk-discnt.line-sign = no
            buf_chk-discnt.pass-discnt = integer('0':U)
            buf_chk-discnt.value-type = integer('2':U)
            buf_chk-discnt.src-d-card = buf_chk-gds.src-d-card
            buf_chk-discnt.d-card = buf_chk-gds.d-card
            buf_chk-discnt.discnt-value-abs = 0
            buf_chk-discnt.discnt-value-pcnt = 0
            buf_chk-discnt.object-line-num = iLineNum
            buf_chk-discnt.pay-desk = buf_chk-doc.pay-desk
            buf_chk-discnt.obj-code = buf_chk-doc.obj-code
            buf_chk-discnt.obj-type = buf_chk-doc.obj-type
            buf_chk-discnt.chk-date = buf_chk-doc.chk-date
            buf_chk-discnt.chk-time = buf_chk-doc.chk-time
            buf_chk-discnt.shift-date = buf_chk-doc.shift-date
            buf_chk-discnt.shift-num = buf_chk-doc.shift-num
            buf_chk-discnt.object-qnty = buf_chk-gds.src-qnty
            buf_chk-discnt.object-sum = buf_chk-gds.src-sum
            var-discnt-id = var-discnt-id + 1
            buf_chk-discnt.promo-id = v-disc-promo-id
            buf_chk-discnt.discnt-type = integer('7':U)
            .
        find first buf_chk-discnt-attr no-lock where
                   buf_chk-discnt-attr.attr-code = "promo-id"
               and buf_chk-discnt-attr.discnt-id = buf_chk-discnt.discnt-id
               and buf_chk-discnt-attr.doc-code = buf_chk-discnt.doc-code
               and buf_chk-discnt-attr.line-num = buf_chk-discnt.line-num
               no-error.
        if not avail buf_chk-discnt-attr then
        do:
            create buf_chk-discnt-attr .
            assign
                buf_chk-discnt-attr.attr-code = "promo-id"
                buf_chk-discnt-attr.attr-value = buf_chk-discnt.promo-id
                buf_chk-discnt-attr.discnt-id = buf_chk-discnt.discnt-id
                buf_chk-discnt-attr.doc-code = buf_chk-discnt.doc-code
                buf_chk-discnt-attr.line-num = buf_chk-discnt.line-num
                buf_chk-discnt-attr.object-line-num = buf_chk-discnt.object-line-num
                buf_chk-discnt-attr.record-type = buf_chk-discnt.record-type
                .
         end.
     end.
   end.
   return yes.
end function.
function GetPromoPriceSum returns decimal
    (input iDocCode as character)
    :
    define buffer buf_chk-gds for ub.chk-gds.
    define buffer buf_chk-gds-attr for ub.chk-gds-attr.
    define variable vPromoSum as decimal no-undo.
    vPromoSum = 0.
    cspr:
    for each buf_chk-gds no-lock where
                 buf_chk-gds.doc-code = iDocCode,
           first buf_chk-gds-attr no-lock where
                 buf_chk-gds-attr.doc-code = buf_chk-gds.doc-code
             and buf_chk-gds-attr.line-num  = buf_chk-gds.line-num
             and buf_chk-gds-attr.attr-code = "CSPromo"
             and can-do("2,4,5,7", buf_chk-gds-attr.attr-value):
       vPromoSum = RoundUp(buf_chk-gds.src-qnty, buf_chk-gds.src-price).
       leave cspr.
    end.
    return vPromoSum.
end.
function GetPromoPriceLine returns integer
    (input iDocCode as character)
    :
    define buffer buf_chk-gds for ub.chk-gds.
    define buffer buf_chk-gds-attr for ub.chk-gds-attr.
    define variable vPromoLine as integer no-undo.
    vPromoLine = 0.
    cspr:
    for each buf_chk-gds no-lock where
                 buf_chk-gds.doc-code = iDocCode,
           first buf_chk-gds-attr no-lock where
                 buf_chk-gds-attr.doc-code = buf_chk-gds.doc-code
             and buf_chk-gds-attr.line-num  = buf_chk-gds.line-num
             and buf_chk-gds-attr.attr-code = "CSPromo"
             and can-do("2,4,5,7", buf_chk-gds-attr.attr-value):
       vPromoLine = buf_chk-gds-attr.line-num.
       leave cspr.
    end.
    return vPromoLine.
end.
define buffer buf_obj-list  for obj-list .
define buffer buf_clients   for ub.clients .
define buffer buf_c-chk-doc for ub.c-chk-doc .
define buffer buf_shift-obj for ub.shift-obj .
define buffer buf_c-chk-gds for ub.c-chk-gds .
define buffer buf_chk-doc   for ub.chk-doc .
define buffer buf_chk-gds   for ub.chk-gds .
define buffer buf_chk-pay   for ub.c-chk-pay .
define variable p-report-id     as character no-undo .
define variable p-log-file-name as character no-undo .
define variable p-batch         as integer   no-undo .
define variable p-codex-id      as integer   no-undo .
define variable p-ruleset-id    as integer   no-undo .
define variable p-plain-txt     as logical   no-undo .
define variable p-xls           as logical   no-undo .
define variable p-dir-name      as character no-undo .
define variable namePay         as character no-undo .
define variable varcurr-name    as character no-undo .
define variable v-nameObj       as character no-undo .
define variable v-nameHost      as character no-undo .
define variable v-period        as character no-undo .
define variable v-delPeriod     as character no-undo .
define variable v-obj-code      as integer   no-undo .
define variable v-obj-type      as character no-undo .
define variable namePNPO        as character no-undo .
define variable nameGoods       as character no-undo .
define variable kk              as integer   no-undo .
define variable jj              as integer   no-undo .
define variable ff              as integer   no-undo .
define variable vv              as integer   no-undo .
define temp-table tt-chk-gds like ub.c-chk-gds
   field base-sum as decimal.
define temp-table tt-chk-pay like ub.c-chk-pay .
DEFINE NEW SHARED TEMP-TABLE tt-pay-info no-undo
  FIELD line-num      like ub.chk-pay.line-num
  field calc-rate     like ub.curr-shop.exch-rate
  field exch-date     like ub.curr-shop.exch-date
  field exch-time     like ub.curr-shop.exch-time
  field exch-time-str as character
  field exch-rate     like ub.curr-shop.exch-rate
  field exch-scale    like ub.curr-shop.exch-scale
  index pi is unique PRIMARY
  line-num
  .
define stream Out-Stream.
define stream OutStr-html.
FUNCTION get-pay RETURNS CHARACTER
  ( input parpay-code as integer,  input parcurr-code as integer, output parcurr-name as character)  FORWARD.
function pr-objname returns character
  (input p-obj-code as integer ) forward.
define variable v-file-name-rep-htm as character no-undo .
define variable ii                  as integer   no-undo .
if dateFrom = ? and dateTo <> ? then dateFrom = today .
if dateFrom <> ? and dateTo = ? then dateTo = 01/01/1970 .
run get-report-num (output p-report-id).
v-file-name-rep-htm = session:temp-directory + string(p-report-id) + ".html".
output stream OutStr-html to value(v-file-name-rep-htm) convert target 'UTF-8'.
put stream OutStr-html unformatted
"<!DOCTYPE HTML>" skip
' <html>' skip
'  <head>' skip
'   <meta charset="utf-8">' skip
'    <style type="text/css">' skip
'      table ' + chr(123) + ' border-collapse: collapse; ' + chr(125) skip
'      .class1 ' + chr(123) + ' border-collapse: collapse; ' + chr(125) skip
'      tbody td, th ' + chr(123) + ' border-collapse: collapse; border: 1px solid black;' + chr(125) skip
'   </style>' skip
'  </head>' skip
  .
find first ub.clients no-lock where ub.clients.obj-code = v-cntxt-host-code-obj and ub.clients.obj-type = 'орг':U no-error .
if available (ub.clients) then v-nameHost = ub.clients.obj-name .
for each buf_obj-list where buf_obj-list.obj-type = 'маг':U no-lock:
  if not onlyDel then
  do:
    if x-TOG-Shift = yes then
    do:
      for each buf_c-chk-doc no-lock
        where buf_c-chk-doc.obj-code = buf_obj-list.obj-code
        and buf_c-chk-doc.obj-type = buf_obj-list.obj-type
        and buf_c-chk-doc.shift-date >= X-date-Start
        and buf_c-chk-doc.shift-date <= x-Date-End
        and buf_c-chk-doc.is-del:
        if buf_c-chk-doc.shift-date = x-Date-Start and buf_c-chk-doc.shift-num < x-Shift-Start then next .
        if buf_c-chk-doc.shift-date = x-Date-End and buf_c-chk-doc.shift-num > x-Shift-End then next .
        if dateFrom <> ? or dateTo <> ? then
        do:
          if buf_c-chk-doc.corr-date < dateTo then next .
          if buf_c-chk-doc.corr-date > dateFrom then next .
        end.
        run tt-tempError .
      end.
    end.
    else
    do:
      for each buf_c-chk-doc no-lock
        where buf_c-chk-doc.obj-code = buf_obj-list.obj-code
        and buf_c-chk-doc.obj-type = buf_obj-list.obj-type
        and buf_c-chk-doc.chk-date >= x-Date-Start
        and buf_c-chk-doc.chk-date <= x-Date-End
        and buf_c-chk-doc.is-del:
        if dateFrom <> ? or dateTo <> ? then
        do:
          if buf_c-chk-doc.corr-date < dateTo then next .
          if buf_c-chk-doc.corr-date > dateFrom then next .
        end.
        run tt-tempError .
      end.
    end.
  end.
  else
  do:
    for each buf_c-chk-doc no-lock
      where buf_c-chk-doc.obj-code = buf_obj-list.obj-code
      and buf_c-chk-doc.obj-type = buf_obj-list.obj-type
      and buf_c-chk-doc.corr-date >= dateTo
      and buf_c-chk-doc.corr-date <= dateFrom
      and buf_c-chk-doc.is-del
      :
      run tt-tempError .
    end.
  end.
end.
run pr-header .
run pr-line .
run pr-foot .
procedure tt-tempError:
  define buffer buf_errorChk for tt-errorChk .
  for each tt-errorChk:
    if lookup(tt-errorChk.attr-code,buf_c-chk-doc.office,",") > 0 then
      tt-errorChk.is-true = true .
  end.
  for first tt-errorChk where tt-errorChk.attr-code = "0" and tt-errorChk.is-true:
    find first buf_errorChk where buf_errorChk.attr-code = " " no-error .
    buf_errorChk.is-true = true .
  end.
end procedure .
procedure pr-header:
  put stream OutStr-html unformatted
    '<body>' skip
    '<TABLE name="1"  fit_to_page="true" orientation="landscape" CELLSPACING="0" BORDER="0">'skip
    '<thead>' skip
    .
  put stream OutStr-html unformatted
    '<tr class="set_columns">' skip
    '<td style="width: 60px;"></td>' skip
    '<td style="width: 60px;"></td>' skip
    '<td style="width: 50px;"></td>' skip
    '<td style="width: 50px;"></td>' skip
    '<td style="width: 70px;"></td>' skip
    '<td style="width: 80px;"></td>' skip
    '<td style="width: 60px;"></td>' skip
    '<td style="width: 60px;"></td>' skip
    '<td style="width: 60px;"></td>' skip
    '<td style="width: 50px;"></td>' skip
    '<td style="width: 70px;"></td>' skip
    '<td style="width: 60px;"></td>' skip
    '<td style="width: 70px;"></td>' skip
    '<td style="width: 80px;"></td>' skip
    '<td style="width: 60px;"></td>' skip
    '<td style="width: 120px;"></td>' skip
    '<td style="width: 80px;"></td>' skip
    '<td style="width: 80px;"></td>' skip
    '<td style="width: 80px;"></td>' skip
    '<td style="width: 80px;"></td>' skip
    '<td style="width: 100px;"></td>' skip
    '<td style="width: 100px;"></td>' skip
    '</tr>' skip
    .
  ff = 0 .
  for each tt-errorChk where tt-errorChk.is-true:
    ff = ff + 1 .
  end.
  if x-TOG-Shift then
  do:
    v-period = "По сменам: с " + string (x-Date-Start,"99.99.9999") + " "+ string (x-Shift-Start) + " по " + string (x-Date-End,"99.99.9999") + " " + string (x-Shift-End) .
  end.
  else
  do:
    v-period = "За период с " + string (x-Date-Start,"99.99.9999") + " по " + string (x-Date-End,"99.99.9999") .
  end.
  if dateTo <> ? and dateFrom <> ? then
  do:
    if dateFrom <> dateTo then
      v-delPeriod = "Период удаления чека: с " + string(dateTo,"99.99.9999") + " по " + string(dateFrom,"99.99.9999") .
    else
      v-delPeriod = "Дата удаления чека: " + string(dateTo,"99.99.9999") .
  end.
  put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="7" style="text-align: left;">' + string(v-nameHost) + ' </td>' skip
    '<td colspan="15" style="text-align: left; font-weight:bold;">Расшифровка состояний чека на момент удаления</td>' skip
    '</tr>' skip
    .
  if ff > 0 then
  do:
    put stream OutStr-html unformatted
      '<tr>' skip
      '<td colspan="7" style="text-align: left;">дата формирования: ' + string(today,"99.99.99") + ' ' + string(time,"HH:MM") + ' </td>' skip
      '<td colspan="15" style="text-align: left; font-weight:bold;">Состояние чека с ошибкой:</td>' skip
      '</tr>' skip
      .
  end.
  else
  do:
    put stream OutStr-html unformatted
      '<tr>' skip
      '<td colspan="7" style="text-align: left;">дата формирования: ' + string(today,"99.99.99") + ' ' + string(time,"HH:MM") + ' </td>' skip
      '<td colspan="15" style="text-align: left; font-weight:bold;">Состояние чека без ошибки:</td>' skip
      '</tr>' skip
      .
  end.
  if ff > 0 then
  do:
    ii = 0 .
    for each tt-errorChk where tt-errorChk.is-true:
      ii = ii + 1 .
      if ii = 1 then
      do:
        if not onlyDel then
        do:
          put stream OutStr-html unformatted
            '<tr>' skip
            '<td colspan="7" style="text-align: left;">' + v-period + '</td>' skip .
        end.
        else
        do:
          put stream OutStr-html unformatted
            '<tr>' skip
            '<td colspan="7" style="text-align: left;"></td>' skip .
        end.
        put stream OutStr-html unformatted
          '<td colspan="2" style="text-align: left; font-weight:bold;">' + string(tt-errorChk.attr-code) + ' </td>' skip
          '<td text_wrap="true" colspan="13" style="text-align: left;">' + string(tt-errorChk.attr-value) + ' </td>' skip
          '</tr>' skip
          .
      end.
      else if ii = 2 then
        do:
          if v-delPeriod <> "" then
          do:
            put stream OutStr-html unformatted
              '<tr>' skip
              '<td colspan="7" style="text-align: left;">' + v-delPeriod + '</td>' skip .
          end.
          else
          do:
            put stream OutStr-html unformatted
              '<tr>' skip
              '<td colspan="7" style="text-align: left;"></td>' skip .
          end.
          put stream OutStr-html unformatted
            '<td colspan="2" style="text-align: left; font-weight:bold;">' + string(tt-errorChk.attr-code) + ' </td>' skip
            '<td text_wrap="true" colspan="13" style="text-align: left;">' + string(tt-errorChk.attr-value) + ' </td>' skip
            '</tr>' skip
            .
        end.
        else
        do:
          put stream OutStr-html unformatted
            '<tr>' skip
            '<td colspan="7" style="text-align: left;"></td>' skip
            '<td colspan="2" style="text-align: left; font-weight:bold;">' + string(tt-errorChk.attr-code) + ' </td>' skip
            '<td text_wrap="true" colspan="13" style="text-align: left;">' + string(tt-errorChk.attr-value) + ' </td>' skip
            '</tr>' skip
            .
        end.
    end.
    if ii = 1 then
    do:
      if not onlyDel then
      do:
        put stream OutStr-html unformatted
          '<tr>' skip
          '<td colspan="7" style="text-align: left;">' + v-period + '</td>' skip .
      end.
      else
      do:
        put stream OutStr-html unformatted
          '<tr>' skip
          '<td colspan="7" style="text-align: left;"></td>' skip .
      end.
      put stream OutStr-html unformatted
        '<td text_wrap="true" colspan="15" style="text-align: left; font-weight:bold;">Состояние чека без ошибки:</td>' skip
        '</tr>' skip
        .
      if v-delPeriod <> "" then
      do:
        put stream OutStr-html unformatted
          '<tr>' skip
          '<td colspan="7" style="text-align: left;">' + v-delPeriod + '</td>' skip .
      end.
      else
      do:
        put stream OutStr-html unformatted
          '<tr>' skip
          '<td colspan="7" style="text-align: left;"></td>' skip .
      end.
      put stream OutStr-html unformatted
        '<td text_wrap="true" colspan="15" style="text-align: left;">Тип "Т" - Товар, или "У" - Услуга означает, что чек не имеет ошибок и может быть включен в продажу;</td>' skip
        '</tr>' skip
        .
      put stream OutStr-html unformatted
        '<tr>' skip
        '<td colspan="22" style="text-align: left; font-weight:bold;">Отчет по удаленным чекам</td>' skip
        '</tr>' skip
        .
    end.
    else if ii = 2 then
      do:
        if v-delPeriod <> "" then
        do:
          put stream OutStr-html unformatted
            '<tr>' skip
            '<td colspan="7" style="text-align: left;">' + v-delPeriod + '</td>' skip .
        end.
        else
        do:
          put stream OutStr-html unformatted
            '<tr>' skip
            '<td colspan="7" style="text-align: left;"></td>' skip .
        end.
        put stream OutStr-html unformatted
          '<td text_wrap="true" colspan="15" style="text-align: left; font-weight:bold;">Состояние чека без ошибки:</td>' skip
          '</tr>' skip
          .
        put stream OutStr-html unformatted
          '<tr>' skip
          '<td colspan="7" style="text-align: left;"></td>' skip
          '<td text_wrap="true" colspan="15" style="text-align: left;">Тип "Т" - Товар, или "У" - Услуга означает, что чек не имеет ошибок и может быть включен в продажу;</td>' skip
          '</tr>' skip
          .
        put stream OutStr-html unformatted
          '<tr>' skip
          '<td colspan="22" style="text-align: left; font-weight:bold;">Отчет по удаленным чекам</td>' skip
          '</tr>' skip
          .
      end.
      else
      do:
        put stream OutStr-html unformatted
          '<tr>' skip
          '<td colspan="7" style="text-align: left;"></td>' skip
          '<td text_wrap="true" colspan="15" style="text-align: left; font-weight:bold;">Состояние чека без ошибки:</td>' skip
          '</tr>' skip
          .
        put stream OutStr-html unformatted
          '<tr>' skip
          '<td colspan="7" style="text-align: left;"></td>' skip
          '<td text_wrap="true" colspan="15" style="text-align: left;">Тип "Т" - Товар, или "У" - Услуга означает, что чек не имеет ошибок и может быть включен в продажу;</td>' skip
          '</tr>' skip
          .
        put stream OutStr-html unformatted
          '<tr>' skip
          '<td colspan="22" style="text-align: left; font-weight:bold;">Отчет по удаленным чекам</td>' skip
          '</tr>' skip
          .
      end.
  end.
  else
  do:
    if not onlyDel then
    do:
      put stream OutStr-html unformatted
        '<tr>' skip
        '<td colspan="7" style="text-align: left;">' + v-period + '</td>' skip .
    end.
    else
    do:
      put stream OutStr-html unformatted
        '<tr>' skip
        '<td colspan="7" style="text-align: left;"></td>' skip .
    end.
    put stream OutStr-html unformatted
      '<td text_wrap="true" colspan="15" style="text-align: left;">Тип "Т" - Товар, или "У" - Услуга означает, что чек не имеет ошибок и может быть включен в продажу;</td>' skip
      '</tr>' skip
      .
    if v-delPeriod <> "" then
    do:
      put stream OutStr-html unformatted
        '<tr>' skip
        '<td colspan="7" style="text-align: left;">' + v-delPeriod + '</td>' skip .
    end.
    else
    do:
      put stream OutStr-html unformatted
        '<tr>' skip
        '<td colspan="7" style="text-align: left;"></td>' skip .
    end.
    put stream OutStr-html unformatted
      '<tr>' skip
      '<td colspan="22" style="text-align: left; font-weight:bold;">Отчет по удаленным чекам</td>' skip
      '</tr>' skip
      .
  end.
  put stream OutStr-html unformatted
    '</thead>' skip .
end.
procedure pr-line:
  put stream OutStr-html unformatted
    '<tbody>' skip
    '<TR>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">ПНПО</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Наименование объекта</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Номер кассы</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Смена</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Дата смены в чеке</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Тип чека</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Соcтояние на момент удаления чека</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Номер чека (Касса)</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Номер чека (ТН)</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Создан в ТН</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Дата чека</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Время чека</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Дата удаления чека</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Время удаления чека</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Смена на дату удаления</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Продукт/Товар в чеке</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Кол-во</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Цена за ед.</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Сумма по строке</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Сумма по чеку</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">Тип оплаты</TD>' skip
    '<TD text_wrap="true" style="text-align: center; font-weight:bold; background-color: silver;">ФИО Пользователя</TD>' skip
    '</TR>'skip
    .
  for each buf_obj-list where buf_obj-list.obj-type = 'маг':U no-lock:
    put stream OutStr-html unformatted
      '<tr>' skip
      '<td colspan="22" style="text-align: left; font-weight:bold;">По объекту: ' + string(buf_obj-list.obj-code) + ' ' + pr-objname(buf_obj-list.obj-code) + ' </td>' skip
      '</tr>' skip
      '</thead>' skip .
    if not onlyDel then
    do:
      if x-TOG-Shift = yes then
      do:
        for each buf_c-chk-doc no-lock
          where buf_c-chk-doc.obj-code = buf_obj-list.obj-code
          and buf_c-chk-doc.obj-type = buf_obj-list.obj-type
          and buf_c-chk-doc.shift-date >= X-date-Start
          and buf_c-chk-doc.shift-date <= x-Date-End
          and buf_c-chk-doc.is-del:
          if buf_c-chk-doc.shift-date = x-Date-Start and buf_c-chk-doc.shift-num < x-Shift-Start then next .
          if buf_c-chk-doc.shift-date = x-Date-End and buf_c-chk-doc.shift-num > x-Shift-End then next .
          if dateFrom <> ? or dateTo <> ? then
          do:
            if buf_c-chk-doc.corr-date < dateTo then next .
            if buf_c-chk-doc.corr-date > dateFrom then next .
          end.
          run primtReport .
        end.
      end.
      else
      do:
        for each buf_c-chk-doc no-lock
          where buf_c-chk-doc.obj-code = buf_obj-list.obj-code
          and buf_c-chk-doc.obj-type = buf_obj-list.obj-type
          and buf_c-chk-doc.chk-date >= x-Date-Start
          and buf_c-chk-doc.chk-date <= x-Date-End
          and buf_c-chk-doc.is-del:
          if dateFrom <> ? or dateTo <> ? then
          do:
            if buf_c-chk-doc.corr-date < dateTo then next .
            if buf_c-chk-doc.corr-date > dateFrom then next .
          end.
          run primtReport .
        end.
      end.
    end.
    else
    do:
      for each buf_c-chk-doc no-lock
        where buf_c-chk-doc.obj-code = buf_obj-list.obj-code
        and buf_c-chk-doc.obj-type = buf_obj-list.obj-type
        and buf_c-chk-doc.corr-date >= dateTo
        and buf_c-chk-doc.corr-date <= dateFrom
        and buf_c-chk-doc.is-del
        :
        run primtReport .
      end.
    end.
  end.
end.
procedure primtReport:
  for first ub.clients no-lock where ub.clients.obj-code = buf_c-chk-doc.obj-code and ub.clients.obj-type = buf_c-chk-doc.obj-type:
    for first buf_clients no-lock where buf_clients.obj-code = ub.clients.host-code and buf_clients.obj-type = 'орг':U:
      namePNPO = buf_clients.obj-name .
    end.
  end.
  put stream OutStr-html unformatted
    '<TR>' skip
    '<TD text_wrap="true" style="text-align: center;">' + namePNPO + '</TD>' skip
    '<TD text_wrap="true" style="text-align: center;">' + ub.clients.obj-name + '</TD>' skip
    '<TD text_wrap="true" style="text-align: center;">' + string(buf_c-chk-doc.pay-desk) + '</TD>' skip
    '<TD text_wrap="true" style="text-align: center;">' + if buf_c-chk-doc.shift-num = 0 then "" + '</TD>' else string(buf_c-chk-doc.shift-name) + '</TD>' skip
    '<TD text_wrap="true" style="text-align: center;">' + if buf_c-chk-doc.src-shift-date <> ? then STRING(buf_c-chk-doc.src-shift-date,"99.99.9999") + '</TD>' else ""  + '</TD>' skip
    '<TD text_wrap="true" style="text-align: center;">' + ENTRY(LOOKUP(string(buf_c-chk-doc.chk-type), "1,6,8,11,12,13,40,69,96,14,15,16,17,36,101,106,108,111,112,113,169,196,114,115,116,117,136,201,206,208,301,306,2,3,4,5,7,43,44"),"Продажа,Возврат,Аннуляция,Инвентаризация,Z-отчет,Закрытие_смены,Открытие_смены,Списание,ВзврСпис,СбросТрнзкц,Перелив,ПеревТрнзкц,ТехПролив,РазблТрнзкц,_Продажа,_Возврат,_Аннуляция,_Инвентаризация,_Z-отчет,_Закрытие_смены,_Списание,_ВзврСпис,_СбросТрнзкц,_Перелив,_ПеревТрнзкц,_ТехПролив,_РазблТрнзкц,>Продажа,>Возврат,>Аннуляция,>>Продажа,>>Возврат,Инкассация,Касс_фонд,Перевод_опл,Расход_кассы,Декл_ден_ящ,Приход_Корр,Расход_Корр") + '</TD>' skip
    '<TD text_wrap="true" style="text-align: center;">' + string(buf_c-chk-doc.office) + '</TD>' skip
    '<TD text_wrap="true" style="text-align: center;">' + string(buf_c-chk-doc.chk-num) + ":" + string(buf_c-chk-doc.z-number) + '</TD>' skip
    '<TD text_wrap="true" style="text-align: center;">' + string(buf_c-chk-doc.doc-code) + '</TD>' skip
    '<TD text_wrap="true" style="text-align: center;">' + if buf_c-chk-doc.is-add then "+" + '</TD>' else "-" + '</TD>' skip
    '<TD text_wrap="true" style="text-align: center;">' + string(buf_c-chk-doc.chk-date,"99.99.9999") + '</TD>' skip
    '<TD text_wrap="true" style="text-align: center;">' + string(buf_c-chk-doc.chk-time,"HH:MM") + '</TD>' skip
    '<TD text_wrap="true" style="text-align: center;">' + string(buf_c-chk-doc.corr-date,"99.99.9999") + '</TD>' skip
    '<TD text_wrap="true" style="text-align: center;">' + string(buf_c-chk-doc.corr-time,"HH:MM") + '</TD>' skip
    .
        vv = 0 .
  for each ub.shift-obj no-lock where ub.shift-obj.obj-code = buf_c-chk-doc.obj-code and ub.shift-obj.obj-type = buf_c-chk-doc.obj-type and
    ub.shift-obj.status_ <> 'ожд':U and
    (ub.shift-obj.open-date < buf_c-chk-doc.corr-date or ub.shift-obj.open-date = buf_c-chk-doc.corr-date) and
    if ub.shift-obj.close-date <> ? then (ub.shift-obj.close-date > buf_c-chk-doc.corr-date or ub.shift-obj.close-date = buf_c-chk-doc.corr-date or ub.shift-obj.status_ = 'тек':U)
    else ub.shift-obj.close-date = ?:
      if ub.shift-obj.status_ <> 'тек':U then do:
      if ub.shift-obj.open-date = buf_c-chk-doc.corr-date and ub.shift-obj.open-time > buf_c-chk-doc.corr-time then next .
      if ub.shift-obj.close-date = buf_c-chk-doc.corr-date and ub.shift-obj.close-time < buf_c-chk-doc.corr-time then next .
      end.
      put stream OutStr-html unformatted
        '<TD text_wrap="true" style="text-align: center;">' + string(ub.shift-obj.shift-date,"99.99.9999") + " " + string(ub.shift-obj.shift-name) + '</TD>' skip
        .
      vv = 1 .
      leave .
  end.
  if vv = 0 then
  do:
    put stream OutStr-html unformatted
      '<TD text_wrap="true" style="text-align: center;"></TD>' skip
      .
  end.
  ii = 0 .
  kk = 0 .
  jj = 0 .
  namePay = "" .
  empty temp-table tt-chk-pay .
  empty temp-table tt-chk-gds .
  for each buf_c-chk-gds no-lock where buf_c-chk-gds.doc-code = buf_c-chk-doc.doc-code:
    find first tt-chk-gds no-lock where tt-chk-gds.doc-code = buf_c-chk-gds.doc-code and
      tt-chk-gds.line-num = buf_c-chk-gds.line-num and
      tt-chk-gds.b-code = buf_c-chk-gds.b-code no-error .
    if available (tt-chk-gds) then next .
    kk = kk + 1 .
    create tt-chk-gds .
    buffer-copy buf_c-chk-gds to tt-chk-gds .
    tt-chk-gds.base-sum = GetRoundSumChkDel(tt-chk-gds.doc-code,
                                            tt-chk-gds.line-num,
                                            tt-chk-gds.chip-num,
                                            tt-chk-gds.doc-qnty,
                                            tt-chk-gds.price-base).
  end .
  for each buf_chk-pay no-lock where buf_chk-pay.doc-code = buf_c-chk-doc.doc-code:
    find first tt-chk-pay no-lock where tt-chk-pay.doc-code = buf_chk-pay.doc-code and
      tt-chk-pay.line-num = buf_chk-pay.line-num no-error .
    if available (tt-chk-pay) then next .
    create tt-chk-pay .
    buffer-copy buf_chk-pay to tt-chk-pay .
  end .
  for each tt-chk-pay:
    namePay = namePay + ", " + get-pay(tt-chk-pay.pay-code, tt-chk-pay.curr-code, output varcurr-name) .
  end.
  namePay = trim (namePay,",") .
  find first tt-chk-gds no-error .
  if available (tt-chk-gds) then
  do:
    for each tt-chk-gds:
      find first ub.bar-code no-lock where ub.bar-code.b-code = tt-chk-gds.b-code no-error .
      if available (ub.bar-code) then
      do:
        find first ub.goods no-lock where ub.goods.gds-code = ub.bar-code.gds-code no-error .
        if available (ub.goods) then nameGoods = ub.goods.gds-name .
        else nameGoods = "" .
      end.
      else nameGoods = "" .
      if jj = 0 then
      do:
        put stream OutStr-html unformatted
          '<TD text_wrap="true" style="text-align: center;">' + nameGoods + '</TD>' skip
          '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(tt-chk-gds.doc-qnty,"->>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(tt-chk-gds.doc-qnty,"->>>>>>>>>>>>>>9.99",2) + '</TD>' skip
          '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(tt-chk-gds.price-base,"->>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(tt-chk-gds.price-base,"->>>>>>>>>>>>>>9.99",2) + '</TD>' skip
          '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(tt-chk-gds.base-sum,"->>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(tt-chk-gds.price-base * tt-chk-gds.doc-qnty,"->>>>>>>>>>>>>>9.99",2) + '</TD>' skip
          '<TD rowspan = "' string(kk) + '" text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(buf_c-chk-doc.tot-doc,"->>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(buf_c-chk-doc.tot-doc,"->>>>>>>>>>>>>>9.99",2) + '</TD>' skip
          .
        put stream OutStr-html unformatted
          '<TD rowspan = "' + string(kk) + '" text_wrap="true" style="text-align: center;">' + namePay + '</TD>' skip
          .
        put stream OutStr-html unformatted
          '<TD rowspan = "' + string(kk) + '" text_wrap="true" style="text-align: center;">' +  usrfulnf(buf_c-chk-doc.corr-user-name) + '</TD>' skip
          '</TR>'skip
          .
        jj = jj + 1.
      end.
      else
      do:
        put stream OutStr-html unformatted
          '<TR>' skip
          '<TD text_wrap="true" style="text-align: center;">' + namePNPO + '</TD>' skip
          '<TD text_wrap="true" style="text-align: center;">' + ub.clients.obj-name + '</TD>' skip
          '<TD text_wrap="true" style="text-align: center;">' + string(buf_c-chk-doc.pay-desk) + '</TD>' skip
          '<TD text_wrap="true" style="text-align: center;">' + if buf_c-chk-doc.shift-num = 0 then "" + '</TD>' else string(buf_c-chk-doc.shift-name) + '</TD>' skip
          '<TD text_wrap="true" style="text-align: center;">' + if buf_c-chk-doc.src-shift-date <> ? then STRING(buf_c-chk-doc.src-shift-date,"99.99.9999") + '</TD>' else ""  + '</TD>' skip
          '<TD text_wrap="true" style="text-align: center;">' + ENTRY(LOOKUP(string(buf_c-chk-doc.chk-type), "1,6,8,11,12,13,40,69,96,14,15,16,17,36,101,106,108,111,112,113,169,196,114,115,116,117,136,201,206,208,301,306,2,3,4,5,7,43,44"),"Продажа,Возврат,Аннуляция,Инвентаризация,Z-отчет,Закрытие_смены,Открытие_смены,Списание,ВзврСпис,СбросТрнзкц,Перелив,ПеревТрнзкц,ТехПролив,РазблТрнзкц,_Продажа,_Возврат,_Аннуляция,_Инвентаризация,_Z-отчет,_Закрытие_смены,_Списание,_ВзврСпис,_СбросТрнзкц,_Перелив,_ПеревТрнзкц,_ТехПролив,_РазблТрнзкц,>Продажа,>Возврат,>Аннуляция,>>Продажа,>>Возврат,Инкассация,Касс_фонд,Перевод_опл,Расход_кассы,Декл_ден_ящ,Приход_Корр,Расход_Корр") + '</TD>' skip
          '<TD text_wrap="true" style="text-align: center;">' + string(buf_c-chk-doc.office) + '</TD>' skip
          '<TD text_wrap="true" style="text-align: center;">' + string(buf_c-chk-doc.chk-num) + ":" + string(buf_c-chk-doc.z-number) + '</TD>' skip
          '<TD text_wrap="true" style="text-align: center;">' + string(buf_c-chk-doc.doc-code) + '</TD>' skip
          '<TD text_wrap="true" style="text-align: center;">' + if buf_c-chk-doc.is-add then "+" + '</TD>' else "-" + '</TD>' skip
          '<TD text_wrap="true" style="text-align: center;">' + string(buf_c-chk-doc.chk-date,"99.99.9999") + '</TD>' skip
          '<TD text_wrap="true" style="text-align: center;">' + string(buf_c-chk-doc.chk-time,"HH:MM") + '</TD>' skip
          '<TD text_wrap="true" style="text-align: center;">' + string(buf_c-chk-doc.corr-date,"99.99.9999") + '</TD>' skip
          '<TD text_wrap="true" style="text-align: center;">' + string(buf_c-chk-doc.corr-time,"HH:MM") + '</TD>' skip
          .
        vv = 0 .
    for each ub.shift-obj no-lock where ub.shift-obj.obj-code = buf_c-chk-doc.obj-code and ub.shift-obj.obj-type = buf_c-chk-doc.obj-type and
      (ub.shift-obj.open-date < buf_c-chk-doc.corr-date or ub.shift-obj.open-date = buf_c-chk-doc.corr-date) and
      ub.shift-obj.status_ <> 'ожд':U and
      if ub.shift-obj.close-date <> ? then (ub.shift-obj.close-date > buf_c-chk-doc.corr-date or ub.shift-obj.close-date = buf_c-chk-doc.corr-date) else ub.shift-obj.close-date = ?:
      if ub.shift-obj.open-date = buf_c-chk-doc.corr-date and ub.shift-obj.open-time > buf_c-chk-doc.corr-time then next .
      if ub.shift-obj.close-date = buf_c-chk-doc.corr-date and ub.shift-obj.close-time < buf_c-chk-doc.corr-time then next .
          put stream OutStr-html unformatted
            '<TD text_wrap="true" style="text-align: center;">' + string(ub.shift-obj.shift-date,"99.99.9999") + " " + string(ub.shift-obj.shift-name) + '</TD>' skip
            .
          vv = 1 .
          leave .
        end.
        if vv = 0 then
        do:
          put stream OutStr-html unformatted
            '<TD text_wrap="true" style="text-align: center;"></TD>' skip
            .
        end.
        put stream OutStr-html unformatted
          '<TD text_wrap="true" style="text-align: center;">' + string(nameGoods) + '</TD>' skip
          '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(tt-chk-gds.doc-qnty,"->>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(tt-chk-gds.doc-qnty,"->>>>>>>>>>>>>>9.99",2) + '</TD>' skip
          '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(tt-chk-gds.price-base,"->>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(tt-chk-gds.price-base,"->>>>>>>>>>>>>>9.99",2) + '</TD>' skip
          '<TD text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(tt-chk-gds.base-sum,"->>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(tt-chk-gds.price-base * tt-chk-gds.doc-qnty,"->>>>>>>>>>>>>>9.99",2) + '</TD>' skip
          '</TR>'skip
          .
      end.
    end.
  end.
  else
  do:
    put stream OutStr-html unformatted
      '<TD text_wrap="true" style="text-align: center;"></TD>' skip
      '<TD text_wrap="true" style="text-align: right;"></TD>' skip
      '<TD text_wrap="true" style="text-align: right;"></TD>' skip
      '<TD text_wrap="true" style="text-align: right;"></TD>' skip
      '<TD text_wrap="true" style="text-align: right;"></TD>' skip
      '<TD text_wrap="true" style="text-align: center;"></TD>' skip
      '<TD text_wrap="true" style="text-align: center;">' +  usrfulnf(buf_c-chk-doc.corr-user-name) + '</TD>' skip
      '</TR>'skip
      .
  end.
end.
put stream OutStr-html unformatted
  '</tbody>' skip .
procedure pr-foot:
  put stream OutStr-html unformatted
    '</table>' skip
    '</body>' skip
    '</html>' skip
    .
end.
output stream OutStr-html close.
run prn-lib-reportviewer in this-procedure (
  input this-procedure
  ,input v-file-name-rep-htm
  ,input ""
  ) no-error.
if error-status:error then
do:
  message return-value view-as alert-box.
  return .
end.
PROCEDURE get-pay-proc :
  define input parameter parpay-code as integer no-undo.
  define input parameter parcurr-code as integer no-undo.
  define output parameter parcurr-name as character no-undo.
  define output parameter varpay-name like ub.cash-pay.obj-name no-undo.
  define buffer loc_cash-pay for ub.cash-pay.
  define buffer loc_currency for ub.currency.
  FIND FIRST loc_cash-pay No-LOCK WHERE
    loc_cash-pay.cdpay-code = parpay-code AND
    loc_cash-pay.curr-code = parcurr-code No-ERROR.
  if avail loc_cash-pay then
  do:
    varpay-name = loc_cash-pay.obj-name.
  end.
  else
  do:
    if buf_c-chk-doc.chk-type = integer('12':U)
      and parpay-code = 0
      and parcurr-code = 0 then
    do:
      varpay-name = "Неизвестная оплата".
    end.
  end.
END PROCEDURE.
PROCEDURE get-report-num :
   define output parameter p-report-num as integer no-undo .
   do
      on error undo, return error return-value
      :
      run gbl/getrpnum.p (output p-report-num).
   end.
END PROCEDURE.
FUNCTION get-pay RETURNS CHARACTER
  ( input parpay-code as integer,  input parcurr-code as integer, output parcurr-name as character) :
  define variable varpay-name like ub.cash-pay.obj-name no-undo.
  run get-pay-proc in this-procedure (
    input  parpay-code
    ,input  parcurr-code
    ,output parcurr-name
    ,output varpay-name ).
  return varpay-name.
END FUNCTION.
FUNCTION pr-objname RETURNS character
  ( INPUT p-obj-code AS integer) :
  define variable v-obj-name as character no-undo .
  find first ub.clients no-lock where ub.clients.obj-code = p-obj-code and ub.clients.obj-type = 'маг':U no-error .
  if AVAILABLE (ub.clients) then v-obj-name = ub.clients.obj-name .
  RETURN v-obj-name.
END FUNCTION.
