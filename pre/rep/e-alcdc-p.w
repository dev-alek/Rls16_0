using Progress.Lang.*.
using Ibs.Th.Gbl.Rep-Out.
using ibs.th.bge.egais.extgds.
using ibs.th.bge.egais.extFormF1.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "".
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
procedure factord :
  define input  parameter p-fact-date            as date    no-undo .
  define input  parameter p-fact-time            as integer no-undo .
  define input  parameter p-fact-num             as integer no-undo .
  define input  parameter p-shift-date           as date    no-undo .
  define input  parameter p-shift-num            as integer no-undo .
  define input  parameter p-shift-on             as logical no-undo .
  define output parameter p-fact-order           as decimal no-undo .
  define output parameter p-shift-end-fact-order as decimal no-undo .
  define output parameter p-day-end-fact-order   as decimal no-undo .
  define variable vss-description as character no-undo init "factord: Определение порядкового номера документа".
  if p-fact-date = ?
  then do:
    return error "Не указана фактическая дата" .
  end.
  define variable v-fact-date-num as integer no-undo .
  assign
    v-fact-date-num = integer(p-fact-date)
  .
  if p-fact-num = ?
  or p-fact-num = 0
  then do:
    return error "Не задан p-fact-num " + string(p-fact-num) .
  end.
  if p-fact-num < 0
  then do:
    return error "Отрицательный fact-num " + string(p-fact-num) .
  end.
  if p-fact-num >= 100000000
  then do:
    return error "Недопустимо большой fact-num " + string(p-fact-num) .
  end.
  if p-shift-on = true
  then do:
    if p-shift-date = ?
    then do:
      return error "Не задана дата смены" .
    end.
    if p-shift-num = ?
    or p-shift-num = 0
    then do:
      return error "Не задан номер смены" .
    end.
  end.
  else do:
    assign
      p-shift-date = p-fact-date
      p-shift-num  = 24
    .
  end.
  define variable v-shift-offset as integer no-undo .
  if p-shift-date = p-fact-date
  then do:
    assign
      v-shift-offset = 1
    .
  end.
  if p-shift-date < p-fact-date
  then do:
    assign
      v-shift-offset = 0
    .
  end.
  if p-shift-date > p-fact-date
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильная дата закрытия смены" skip
      "Дата закрытия не смены не может быть раньше чем дата открытия смены" skip
      view-as alert-box error .
    undo, return error
      substitute("Дата закрытия не смены &1 не может быть раньше чем дата открытия смены &2"
        ,string(p-fact-date, '99/99/9999':U)
        ,string(p-shift-date, '99/99/9999':U)
        )
    .
  end.
  if p-shift-num < 1
  or p-shift-num > 24
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильный номер смены" skip
      "p-shift-num" p-shift-num skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  assign
    p-fact-order           = v-fact-date-num
                           + v-shift-offset * 0.5
                           + p-shift-num    * 0.02 - 0.01
                           + p-fact-num     * 0.0000000001
    p-shift-end-fact-order = v-fact-date-num
                           + v-shift-offset * 0.5
                           + p-shift-num    * 0.02
    p-day-end-fact-order   = v-fact-date-num
                           + 0.99
  .
  if p-fact-order           <= v-fact-date-num
  or p-shift-end-fact-order <= v-fact-date-num
  or p-fact-order           >= p-shift-end-fact-order - 0.0000000001
  or p-shift-end-fact-order >= p-day-end-fact-order
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Внутренняя ошибка при генерации фактического номера" skip
      "p-fact-date"            p-fact-date            skip
      "p-fact-time"            p-fact-time            skip
      "p-fact-num"             p-fact-num             skip
      "p-shift-date"           p-shift-date           skip
      "p-shift-num"            p-shift-num            skip
      "p-shift-on"             p-shift-on             skip
      "p-shift-end-fact-order" p-shift-end-fact-order skip
      "p-day-end-fact-order"   p-day-end-fact-order   skip
      "v-fact-date-num"        v-fact-date-num        skip
      view-as alert-box error .
    undo, return error return-value .
  end.
end procedure.
procedure day-begin-fact-order :
  define input  parameter p-fact-date            as date    no-undo .
  define output parameter p-day-begin-fact-order as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-date = ?
    then do:
      assign
        p-day-begin-fact-order = 0
      .
    end.
    else do:
      assign
        p-day-begin-fact-order = integer(p-fact-date)
      .
    end.
  end.
end procedure.
procedure factord-max-fact-order :
  define output parameter p-max-fact-order as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    run day-begin-fact-order in this-procedure
      (input  date(1, 1, 5000)
      ,output p-max-fact-order
      ) .
  end.
end procedure.
procedure factord-cut-archive :
  define input  parameter p-obj-type             as character no-undo .
  define input  parameter p-obj-code             as integer   no-undo .
  define input  parameter p-fact-date            as date      no-undo .
  define output parameter p-shift-on             as logical   no-undo .
  define output parameter p-shift-date           as date      no-undo .
  define output parameter p-shift-num            as integer   no-undo .
  define output parameter p-day-end-fact-order   as decimal   no-undo .
  define output parameter p-shift-end-fact-order as decimal   no-undo .
  define variable v-fact-order as decimal   no-undo .
  define buffer buf_shift-obj for ub.shift-obj .
  do
  on error undo, return error return-value
  :
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output p-shift-on
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута объекта" skip
        "Объект" p-obj-type p-obj-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-shift-on = false
    then do:
      assign
        p-shift-date               = ?
        p-shift-num                = 0
      .
    end.
    else do:
      find first buf_shift-obj share-lock
        where buf_shift-obj.obj-type   = p-obj-type
          and buf_shift-obj.obj-code   = p-obj-code
          and buf_shift-obj.shift-date > p-fact-date
        use-index pi
        no-error .
      if not available buf_shift-obj
      or buf_shift-obj.status_ <> 'зкр':U
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Невозможно вычислить последнюю смену" skip
          "Отсутствует закрытая смена с датой большей чем дата инициализации архива" skip
          "Объект" p-obj-type p-obj-code skip
          "Дата" p-fact-date skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      find last buf_shift-obj share-lock
        where buf_shift-obj.obj-type = p-obj-type
          and buf_shift-obj.obj-code = p-obj-code
          and buf_shift-obj.shift-date <= p-fact-date
        use-index pi
        no-error .
      if available buf_shift-obj
      then do:
        if  buf_shift-obj.status_ = 'зкр':U
        then do:
          assign
            p-shift-date = buf_shift-obj.shift-date
            p-shift-num  = buf_shift-obj.shift-num
          .
        end.
        else do:
          message
            vss-workfile vss-revision vss-description skip
            "Невозможно вычислить последнюю смену" skip
            "Статус смены отличен от статуса" 'зкр':U skip
            "Объект" p-obj-type p-obj-code skip
            "Дата" p-fact-date skip
            "Смена" buf_shift-obj.shift-date buf_shift-obj.shift-num skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end.
      else do:
        assign
          p-shift-date = p-fact-date - 1
          p-shift-num  = 1
        .
      end.
    end.
    run factord in this-procedure
      (input  p-fact-date
      ,input  1
      ,input  1
      ,input  p-shift-date
      ,input  p-shift-num
      ,input  p-shift-on
      ,output v-fact-order
      ,output p-shift-end-fact-order
      ,output p-day-end-fact-order
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры factord"
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure factord-lock-shift :
  define input  parameter p-obj-type  as character no-undo .
  define input  parameter p-obj-code  as integer   no-undo .
  define input  parameter p-fact-date as date      no-undo .
  define parameter buffer buf_shift-obj for ub.shift-obj .
  define variable v-shift-on      as logical   no-undo .
  define variable v-extra-message as character no-undo .
  define variable v-error as character no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output v-shift-on
  ) no-error .
    if error-status :error
    then do:
      v-error = substitute("Ошибка при определении атрибута объекта  &1 &2 &3 &4" ,p-obj-type , p-obj-code  , error-status :get-message(1) , return-value) .
      undo, return error v-error .
    end.
    if v-shift-on = true
    then do:
      find first buf_shift-obj share-lock
        where buf_shift-obj.obj-type   = p-obj-type
          and buf_shift-obj.obj-code   = p-obj-code
          and buf_shift-obj.shift-date > p-fact-date
        use-index pi
        no-error .
      if not available buf_shift-obj
      or buf_shift-obj.status_ <> 'зкр':U
      then do:
        find last buf_shift-obj
          where buf_shift-obj.obj-type = p-obj-type
            and buf_shift-obj.obj-code = p-obj-code
            and buf_shift-obj.status_  = 'зкр':U
          use-index stts
          no-error .
        if available buf_shift-obj
        then do:
          assign
            v-extra-message =
                  substitute("Дата начала последеней закрытой смены на объекте &1"
                            ,string(buf_shift-obj.shift-date, '99/99/9999':u)
                            )
          .
        end.
        v-error = substitute("Ошибка при блокировке смены объекта  &1 &2 Отсутствует закрытая смена с датой большей чем указанная дата  &5  &3 &4" ,p-obj-type , p-obj-code  , error-status :get-message(1) , return-value , p-fact-date) .
        undo, return error v-error .
      end.
    end.
  end.
end procedure.
procedure factord-end-day :
  define input  parameter p-fact-date            as date    no-undo .
  define output parameter p-day-end-fact-order   as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-date = ?
    then do:
      return error "Не указана фактическая дата" .
    end.
    assign
      p-day-end-fact-order = integer(p-fact-date) + 0.99
    .
  end.
end procedure.
procedure factord-to-date :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-fact-date  as date    no-undo .
  define variable v-ref-date  as date      no-undo .
  define variable v-ref-delta as integer   no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
      v-ref-date  = date(1, 1, 2000)
    .
    assign
      v-ref-delta = integer(truncate(p-fact-order, 0)) - integer(v-ref-date)
    .
    assign
      p-fact-date = v-ref-date + v-ref-delta
    .
  end.
end procedure.
procedure factord-to-fact-num :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-fact-num   as integer no-undo .
  define variable v-fact-order-trunc as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
     v-fact-order-trunc = truncate(p-fact-order, 2)
    .
    assign
      p-fact-num = (p-fact-order - v-fact-order-trunc ) * 10000000000
    .
  end.
end procedure.
procedure factord-to-shift-num :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-shift-num   as integer no-undo .
  define variable  p-shift-numd  as decimal   no-undo .
  define variable v-fact-order-trunc as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
     v-fact-order-trunc = truncate(p-fact-order, 2)  - truncate(p-fact-order,0)
    .
    if v-fact-order-trunc < 0.5 then do:
      v-fact-order-trunc = v-fact-order-trunc + 0.5.
    end.
    assign
      p-shift-numd = (( v-fact-order-trunc  * 100 - 50 ) + 1 ) / 2
      .
     assign
      p-shift-num = truncate (p-shift-numd , 0)
    .
  end.
end procedure.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-parts no-undo   like ub.parts   field free-qnty as decimal   field free-cli-qnty as decimal .
procedure partslib-clear-temp-parts :
  define buffer buf_temp-parts for temp-parts .
  do
  on error undo, return error
  :
    for each buf_temp-parts
    on error undo, return error
    :
      delete buf_temp-parts .
    end.
  end.
end procedure.
procedure partslib-create-temp-parts :
  define parameter buffer buf_parts       for ub.parts .
  define parameter buffer buf_temp-parts  for temp-parts .
  define input  parameter p-goods-twounit as logical   no-undo .
  define variable v-base-part-code as character no-undo .
  do
  on error undo, return error
  :
    if p-goods-twounit = true
    then do:
      assign
        v-base-part-code = entry(1, buf_parts.part-code, '#':U)
      .
    end.
    else do:
      assign
        v-base-part-code = buf_parts.part-code
      .
    end.
    find first buf_temp-parts exclusive-lock
      where buf_temp-parts.obj-type  = buf_parts.obj-type
        and buf_temp-parts.obj-code  = buf_parts.obj-code
        and buf_temp-parts.artic     = buf_parts.artic
        and buf_temp-parts.prod-type = buf_parts.prod-type
        and buf_temp-parts.prod-code = buf_parts.prod-code
        and buf_temp-parts.in-code   = buf_parts.in-code
        and buf_temp-parts.out-code  = 'free-zone':U
        and buf_temp-parts.part-code = v-base-part-code
      no-error.
    if not available buf_temp-parts
    then do:
      create buf_temp-parts .
      buffer-copy buf_parts to buf_temp-parts
      assign
        buf_temp-parts.out-code  = 'free-zone':U
        buf_temp-parts.part-code = v-base-part-code
        buf_temp-parts.rsrv-free = yes
        buf_temp-parts.status_   = no
        buf_temp-parts.qnty      = 0
        buf_temp-parts.fact-qnty = 0
        buf_temp-parts.real-qnty = 0
        buf_temp-parts.cli-qnty  = 0
      .
    end.
  end.
end procedure.
procedure partslib-init-temp-parts :
  define input parameter p-obj-type        like ub.parts.obj-type  no-undo .
  define input parameter p-obj-code        like ub.parts.obj-code  no-undo .
  define input parameter p-artic           like ub.parts.artic     no-undo .
  define input parameter p-prod-type       like ub.parts.prod-type no-undo .
  define input parameter p-prod-code       like ub.parts.prod-code no-undo .
  define buffer buf_parts      for ub.parts .
  define buffer buf_temp-parts for temp-parts .
  define variable v-goods-twounit    as logical   no-undo .
  do
  on error undo, return error
  :
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsat in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,input  'twounit=request':u
  ,output v-goods-twounit
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info18 skip
        "Ошибка при определении атрибута товара" skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "twounit=request" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    run partslib-clear-temp-parts in this-procedure .
    for each buf_parts
      where buf_parts.obj-type  = p-obj-type
        and buf_parts.obj-code  = p-obj-code
        and buf_parts.artic     = p-artic
        and buf_parts.prod-type = p-prod-type
        and buf_parts.prod-code = p-prod-code
        and buf_parts.rsrv-free = yes
        and buf_parts.status_   = no
        and buf_parts.in-code   <> buf_parts.out-code
    on error undo, return error
    :
      run partslib-create-temp-parts in this-procedure
        (buffer buf_parts
        ,buffer buf_temp-parts
        ,input  v-goods-twounit
        ) .
      define variable v-parts-qnty          as decimal   no-undo .
      define variable v-parts-cli-qnty      as decimal   no-undo .
      define variable v-parts-free-qnty     as decimal   no-undo .
      define variable v-parts-free-cli-qnty as decimal   no-undo .
      if buf_parts.out-code = 'free-zone':U
      then do:
        assign
          v-parts-qnty          = buf_parts.qnty
          v-parts-cli-qnty      = buf_parts.cli-qnty
          v-parts-free-qnty     = buf_parts.qnty
          v-parts-free-cli-qnty = buf_parts.cli-qnty
        .
      end.
      else do:
        assign
          v-parts-qnty          = abs(buf_parts.qnty)
          v-parts-cli-qnty      = abs(buf_parts.cli-qnty)
          v-parts-free-qnty     = 0
          v-parts-free-cli-qnty = 0
        .
      end.
      assign
        buf_temp-parts.qnty          = buf_temp-parts.qnty          + v-parts-qnty
        buf_temp-parts.fact-qnty     = buf_temp-parts.fact-qnty     + v-parts-qnty
        buf_temp-parts.real-qnty     = 0
        buf_temp-parts.cli-qnty      = buf_temp-parts.cli-qnty      + v-parts-cli-qnty
        buf_temp-parts.free-qnty     = buf_temp-parts.free-qnty     + v-parts-free-qnty
        buf_temp-parts.free-cli-qnty = buf_temp-parts.free-cli-qnty + v-parts-free-cli-qnty
      .
    end.
  end.
end procedure.
procedure partslib-init-temp-parts-by-factord :
  define input parameter p-obj-type           like ub.parts.obj-type  no-undo .
  define input parameter p-obj-code           like ub.parts.obj-code  no-undo .
  define input parameter p-artic              like ub.parts.artic     no-undo .
  define input parameter p-prod-type          like ub.parts.prod-type no-undo .
  define input parameter p-prod-code          like ub.parts.prod-code no-undo .
  define input parameter p-fact-order         as decimal   no-undo .
  define input parameter p-include-fact-order as logical   no-undo .
  define variable vss-description as character no-undo init "partslib-init-temp-parts-by-factord: определение партий свободной зоны на любую дату".
  define buffer buf_gds-obj  for ub.gds-obj .
  do
  on error undo, return error
  :
    do transaction
    on error undo, return error
    :
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjcr in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,buffer buf_gds-obj
  ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info18 skip
          "Невозможно найти товар на объекте" skip
          "Объект" p-obj-type p-obj-code skip
          "Артикул" p-artic p-prod-type p-prod-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
      find current buf_gds-obj exclusive-lock .
    end.
    run partslib-init-temp-parts in this-procedure
      (input p-obj-type
      ,input p-obj-code
      ,input p-artic
      ,input p-prod-type
      ,input p-prod-code
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info18 skip
        "Ошибка при инициализации текущего остатка по партиям свободной зоны" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "p-fact-order" p-fact-order skip
        view-as alert-box error .
      undo, return error .
    end.
    if p-include-fact-order = true
    then do:
      assign
        p-fact-order = p-fact-order - 0.0000000001
      .
    end.
    define variable v-max-fact-order as character no-undo .
    run factord-max-fact-order in this-procedure
      (output v-max-fact-order
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info18 skip
        "Ошибка при вызове процедуры factord-max-fact-order" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "p-fact-order" p-fact-order skip
        view-as alert-box error .
      undo, return error .
    end.
    run partslib-update-by-factord in this-procedure
      (input p-obj-type
      ,input p-obj-code
      ,input p-artic
      ,input p-prod-type
      ,input p-prod-code
      ,input p-fact-order
      ,input v-max-fact-order
      ,input false
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info18 skip
        "Ошибка при вызове процедуры partslib-update-by-factord" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "p-fact-order" p-fact-order skip
        "v-max-fact-order" v-max-fact-order skip
        view-as alert-box error .
      undo, return error .
    end.
  end.
end procedure.
procedure partslib-update-by-factord :
  define input parameter p-obj-type           like ub.parts.obj-type  no-undo .
  define input parameter p-obj-code           like ub.parts.obj-code  no-undo .
  define input parameter p-artic              like ub.parts.artic     no-undo .
  define input parameter p-prod-type          like ub.parts.prod-type no-undo .
  define input parameter p-prod-code          like ub.parts.prod-code no-undo .
  define input parameter p-start-fact-order   as decimal   no-undo .
  define input parameter p-end-fact-order     as decimal   no-undo .
  define input parameter p-lock-gds-obj       as logical   no-undo .
  define variable vss-description as character no-undo init "partslib-init-temp-parts-by-factord: определение партий свободной зоны на любую дату".
  define buffer buf_gds-obj  for ub.gds-obj .
  define buffer buf_doc-line for ub.doc-line .
  define variable v-total-parts-qnty as decimal   no-undo .
  define variable v-goods-gds-goods  as logical   no-undo .
  define variable v-goods-twounit    as logical   no-undo .
  do
  on error undo, return error
  :
    if p-start-fact-order > p-end-fact-order
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info18 skip
        "Ошибка задания входных параметров" skip
        "Начало интервала превышает конец интервала" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "p-start-fact-order" p-start-fact-order skip
        "p-end-fact-order"   p-end-fact-order skip
        view-as alert-box error .
      undo, return error .
    end.
    if p-lock-gds-obj = true
    then do:
      do transaction
      on error undo, return error
      :
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjcr in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,buffer buf_gds-obj
  ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            vss-include-info18 skip
            "Невозможно найти gds-obj" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error .
        end.
        find current buf_gds-obj exclusive-lock .
      end.
    end.
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsat in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,input  'gds-goods=request':u
  ,output v-goods-gds-goods
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info18 skip
        "Ошибка при определении атрибута товара" skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "gds-goods=request" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsat in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,input  'twounit=request':u
  ,output v-goods-twounit
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info18 skip
        "Ошибка при определении атрибута товара" skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "twounit=request" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    for each buf_doc-line no-lock
      where buf_doc-line.obj-type   = p-obj-type
        and buf_doc-line.obj-code   = p-obj-code
        and buf_doc-line.artic      = p-artic
        and buf_doc-line.prod-type  = p-prod-type
        and buf_doc-line.prod-code  = p-prod-code
        and buf_doc-line.status_    = 'факт':U
        and buf_doc-line.fact-order > p-start-fact-order
        and buf_doc-line.fact-order <= p-end-fact-order
    on error undo, return error
    :
      run partslib-process-document in this-procedure
        (input  buf_doc-line.doc-code
        ,input  p-obj-type
        ,input  p-obj-code
        ,input  p-artic
        ,input  p-prod-type
        ,input  p-prod-code
        ,input  v-goods-gds-goods
        ,input  v-goods-twounit
        ,output v-total-parts-qnty
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info18 skip
          "Ошибка при вызове процедуры partslib-process-document" skip
          "Документ" buf_doc-line.doc-code skip
          "Объект" p-obj-type p-obj-code skip
          "Артикул" p-artic p-prod-type p-prod-code skip
          "p-start-fact-order" p-start-fact-order skip
          "p-end-fact-order" p-end-fact-order skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
  end.
end procedure.
procedure partslib-process-document :
  define input  parameter p-doc-code         as character no-undo .
  define input  parameter p-obj-type         as character no-undo .
  define input  parameter p-obj-code         as integer   no-undo .
  define input  parameter p-artic            as character no-undo .
  define input  parameter p-prod-type        as character no-undo .
  define input  parameter p-prod-code        as integer   no-undo .
  define input  parameter p-goods-gds-goods  as logical   no-undo .
  define input  parameter p-goods-twounit    as logical   no-undo .
  define output parameter p-total-parts-qnty as decimal   no-undo .
  define variable v-parts-sign as integer   no-undo .
  define buffer buf_trn-doc    for ub.trn-doc .
  define buffer buf_doc-line   for ub.doc-line .
  define buffer buf_parts      for ub.parts .
  define buffer buf_temp-parts for temp-parts .
  do
  on error undo, return error return-value
  :
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-doc-code
      no-error .
    if not available buf_trn-doc
    then do:
      undo, return error substitute("Ошибка при поиске документа. Документ &1"
                                   ,p-doc-code
                                   ) .
    end.
    case buf_trn-doc.doc-type
    :
      when 'при':U or
      when 'возврат':U or
      when 'инв':U
      then do:
        assign
          v-parts-sign = -1
        .
      end.
      when 'рас':U or
      when 'спи':U
      then do:
        assign
          v-parts-sign = 1
        .
      end.
      otherwise do:
        undo, return error substitute("Неизвестный тип документа &1"
                                    ,buf_trn-doc.doc-type
                                    ) .
      end.
    end.
    find first buf_doc-line no-lock
      where buf_doc-line.doc-code  = p-doc-code
        and buf_doc-line.artic     = p-artic
        and buf_doc-line.prod-type = p-prod-type
        and buf_doc-line.prod-code = p-prod-code
      no-error .
    if not available buf_doc-line
    then do:
      undo, return error substitute("Ошибка при поиске строки документа. Документ &1. Артикул &2 &3 &4"
                                   ,p-doc-code
                                   ,artic
                                   ,prod-type
                                   ,prod-code
                                   ) .
    end.
    assign
      p-total-parts-qnty = 0
    .
    if p-goods-gds-goods = true
    then do:
      for each buf_parts no-lock
        where buf_parts.out-code  = p-doc-code
          and buf_parts.obj-type  = p-obj-type
          and buf_parts.obj-code  = p-obj-code
          and buf_parts.artic     = p-artic
          and buf_parts.prod-type = p-prod-type
          and buf_parts.prod-code = p-prod-code
      on error undo, return error
      :
        run partslib-create-temp-parts in this-procedure
          (buffer buf_parts
          ,buffer buf_temp-parts
          ,input  p-goods-twounit
          ) .
        assign
          p-total-parts-qnty        = p-total-parts-qnty
                                    + v-parts-sign * buf_parts.fact-qnty
          buf_temp-parts.qnty       = buf_temp-parts.qnty
                                    + v-parts-sign * buf_parts.fact-qnty
          buf_temp-parts.fact-qnty  = buf_temp-parts.fact-qnty
                                    + v-parts-sign * buf_parts.fact-qnty
          buf_temp-parts.cli-qnty   = buf_temp-parts.cli-qnty
                                    + v-parts-sign * buf_parts.cli-qnty
        .
        if buf_temp-parts.qnty = 0
        then do:
          delete buf_temp-parts .
        end.
      end.
    end.
    else do:
      assign
        p-total-parts-qnty = p-total-parts-qnty
                           + v-parts-sign * buf_doc-line.fact-qnty
      .
    end.
  end.
end procedure.
procedure partslib-init-temp-parts-by-date :
  define input parameter p-obj-type        like ub.parts.obj-type  no-undo .
  define input parameter p-obj-code        like ub.parts.obj-code  no-undo .
  define input parameter p-artic           like ub.parts.artic     no-undo .
  define input parameter p-prod-type       like ub.parts.prod-type no-undo .
  define input parameter p-prod-code       like ub.parts.prod-code no-undo .
  define input parameter p-fact-date       as date      no-undo .
  define variable vss-description as character no-undo init "partslib-init-temp-parts-by-date: определение партий свободной зоны на любую дату".
  do
  on error undo, return error
  :
    define variable v-fact-order                as decimal   no-undo .
    define variable v-shift-end-fact-order      as decimal   no-undo .
    define variable v-day-end-fact-order        as decimal   no-undo .
    run factord in this-procedure
      (input  p-fact-date
      ,input  1
      ,input  1
      ,input  ?
      ,input  0
      ,input  false
      ,output v-fact-order
      ,output v-shift-end-fact-order
      ,output v-day-end-fact-order
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info18 skip
        "Ошибка при определении момента времени, на который требуется остаток" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "Дата" p-fact-date skip
        view-as alert-box error .
      undo, return error .
    end.
    run partslib-init-temp-parts-by-factord in this-procedure
      (input p-obj-type
      ,input p-obj-code
      ,input p-artic
      ,input p-prod-type
      ,input p-prod-code
      ,input v-day-end-fact-order
      ,input false
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info18 skip
        "Ошибка при вызове метода partslib-init-temp-parts-by-factord" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "Дата" p-fact-date skip
        view-as alert-box error .
      undo, return error .
    end.
  end.
end procedure.
procedure partslib-calc-cost :
  define output parameter p-fact-qnty      as decimal   no-undo .
  define output parameter p-vat-pc         as decimal   no-undo .
  define output parameter p-slt-pc         as decimal   no-undo .
  define output parameter p-sum-base       as decimal   no-undo .
  define output parameter p-sum-rubl       as decimal   no-undo .
  define output parameter p-vat-base       as decimal   no-undo .
  define output parameter p-vat-rubl       as decimal   no-undo .
  define output parameter p-slt-base       as decimal   no-undo .
  define output parameter p-slt-rubl       as decimal   no-undo .
  define output parameter p-road-tax-base  as decimal   no-undo .
  define output parameter p-road-tax-rubl  as decimal   no-undo .
  define output parameter p-transport-base as decimal   no-undo .
  define output parameter p-transport-rubl as decimal   no-undo .
  define output parameter p-other-base     as decimal   no-undo .
  define output parameter p-other-rubl     as decimal   no-undo .
  define output parameter p-excise-base    as decimal   no-undo .
  define output parameter p-excise-rubl    as decimal   no-undo .
  define variable vss-description as character no-undo init "partslib-calc-cost: расчет сумм в учетных ценах".
  do
  on error undo, return error return-value
  :
    define buffer buf_temp-parts for temp-parts .
    define buffer   in-vatp-trn-doc  for ub.trn-doc .
    define buffer   in-vatp-parts    for ub.parts   .
    define buffer   in-vatp-doc      for ub.trn-doc .
    define buffer   in-vatp-goods    for ub.goods   .
    define buffer   in-vatp-sysconf  for ub.sysconf .
    define buffer   in-vatp_doc-attr for ub.doc-attr.
    define variable in-vatp-have-vat-slt       as   logical initial yes    no-undo.
    define variable vat-pc-loc                 like ub.doc-line.vat-pc     no-undo.
    define variable varinvprb                  as   character              no-undo.
    define variable slt-pc-loc                 like ub.doc-line.slt-pc     no-undo.
    define variable cli-base-rate              as   decimal                no-undo.
    define variable price-rubl-with-tax-loc    like ub.doc-line.price-rubl no-undo.
    define variable price-base-with-tax-loc    like ub.doc-line.price-base no-undo.
    define variable price-cli-with-tax-loc     like ub.doc-line.price-cli  no-undo.
    define variable price-rubl-without-tax-loc like ub.doc-line.price-rubl no-undo.
    define variable price-base-without-tax-loc like ub.doc-line.price-base no-undo.
    define variable price-cli-without-tax-loc  like ub.doc-line.price-base no-undo.
    define variable vat-base-loc               like ub.doc-line.price-base no-undo.
    define variable vat-rubl-loc               like ub.doc-line.price-rubl no-undo.
    define variable vat-cli-loc                like ub.doc-line.price-rubl no-undo.
    define variable slt-base-loc               like ub.doc-line.price-base no-undo.
    define variable slt-rubl-loc               like ub.doc-line.price-rubl no-undo.
    define variable slt-cli-loc                like ub.doc-line.price-rubl no-undo.
    define variable road-tax-base-loc          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-rubl-loc          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-cli-loc           like ub.doc-line.road-tax   no-undo.
    define variable transport-base-loc         like ub.doc-line.price-base no-undo.
    define variable transport-rubl-loc         like ub.doc-line.price-rubl no-undo.
    define variable transport-cli-loc          like ub.doc-line.price-rubl no-undo.
    define variable other-base-loc             like ub.doc-line.price-base no-undo.
    define variable other-rubl-loc             like ub.doc-line.price-rubl no-undo.
    define variable other-cli-loc              like ub.doc-line.price-rubl no-undo.
    define variable exch-rate-cli-loc          like ub.trn-doc.exch-rate   no-undo.
    define variable varinvatp-envd             as   character              no-undo.
    define variable varinvatp-type             as   character              no-undo.
    for each buf_temp-parts
    on error undo, return error
    :
assign
  price-rubl-with-tax-loc = buf_temp-parts.price-rubl
  price-base-with-tax-loc = buf_temp-parts.price-base
.
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
  if buf_temp-parts.out-code = 'free-zone':U     or
     buf_temp-parts.out-code = 'out-zone':U   or
     buf_temp-parts.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-slt = yes.
  end.
  else do:
    find first in-vatp_doc-attr no-lock
      where in-vatp_doc-attr.doc-code  = buf_temp-parts.out-code
        and in-vatp_doc-attr.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attr then do:
      assign
        in-vatp-have-vat-slt = yes.
    end.
    else do:
         in-vatp-have-vat-slt = no.
    end.
  end.
  assign
   price-cli-with-tax-loc = buf_temp-parts.price-cli
   cli-base-rate          = buf_temp-parts.cli-base-rate.
  ASSIGN   road-tax-base-loc  = (if buf_temp-parts.road-tax-base  = ? then 0 else buf_temp-parts.road-tax-base)
           road-tax-rubl-loc  = (if buf_temp-parts.road-tax-rubl  = ? then 0 else buf_temp-parts.road-tax-rubl).
  ASSIGN  transport-base-loc = (if buf_temp-parts.transport-base = ? then 0 else buf_temp-parts.transport-base)
          transport-rubl-loc = (if buf_temp-parts.transport-rubl = ? then 0 else buf_temp-parts.transport-rubl)
          other-base-loc     = (if buf_temp-parts.other-base     = ? then 0 else buf_temp-parts.other-base)
          other-rubl-loc     = (if buf_temp-parts.other-rubl     = ? then 0 else buf_temp-parts.other-rubl)
          vat-pc-loc         = (if buf_temp-parts.vat-pc         = ? then 0 else buf_temp-parts.vat-pc)
          slt-pc-loc         = (if buf_temp-parts.slt-pc         = ? then 0 else buf_temp-parts.slt-pc).
          ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
    ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
  assign
    exch-rate-cli-loc = (buf_temp-parts.price-rubl - transport-rubl-loc - other-rubl-loc - road-tax-rubl-loc - (if buf_temp-parts.vat-type <> 'в т. ч.':U then vat-rubl-loc else 0) - (if buf_temp-parts.slt-type <> 'в т. ч.':U then slt-rubl-loc else 0)) / buf_temp-parts.price-cli .
  assign
    slt-cli-loc        = slt-rubl-loc       / exch-rate-cli-loc
    vat-cli-loc        = vat-rubl-loc       / exch-rate-cli-loc
    road-tax-cli-loc   = road-tax-rubl-loc  / exch-rate-cli-loc
    transport-cli-loc  = 0
    other-cli-loc      = 0
  .
ASSIGN
          price-base-without-tax-loc = price-base-with-tax-loc - vat-base-loc - slt-base-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))
    price-rubl-without-tax-loc = price-rubl-with-tax-loc - vat-rubl-loc - slt-rubl-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))
.
      assign
        p-fact-qnty      = p-fact-qnty      + buf_temp-parts.fact-qnty
        p-vat-pc         = p-vat-pc         + vat-pc-loc
        p-slt-pc         = p-slt-pc         + slt-pc-loc
        p-sum-base       = p-sum-base       + price-base-with-tax-loc * buf_temp-parts.fact-qnty
        p-sum-rubl       = p-sum-rubl       + price-rubl-with-tax-loc * buf_temp-parts.fact-qnty
        p-vat-base       = p-vat-base       + vat-base-loc            * buf_temp-parts.fact-qnty
        p-vat-rubl       = p-vat-rubl       + vat-rubl-loc            * buf_temp-parts.fact-qnty
        p-slt-base       = p-slt-base       + slt-base-loc            * buf_temp-parts.fact-qnty
        p-slt-rubl       = p-slt-rubl       + slt-rubl-loc            * buf_temp-parts.fact-qnty
        p-road-tax-base  = p-road-tax-base  + road-tax-base-loc       * buf_temp-parts.fact-qnty
        p-road-tax-rubl  = p-road-tax-rubl  + road-tax-rubl-loc       * buf_temp-parts.fact-qnty
        p-transport-base = p-transport-base + transport-base-loc      * buf_temp-parts.fact-qnty
        p-transport-rubl = p-transport-rubl + transport-rubl-loc      * buf_temp-parts.fact-qnty
        p-other-base     = p-other-base     + other-base-loc          * buf_temp-parts.fact-qnty
        p-other-rubl     = p-other-rubl     + other-rubl-loc          * buf_temp-parts.fact-qnty
        p-excise-base    = p-excise-base    + 0
        p-excise-rubl    = p-excise-rubl    + 0
      .
    end.
    if p-fact-qnty      = ?
    or p-sum-base       = ?
    or p-sum-rubl       = ?
    or p-vat-base       = ?
    or p-vat-rubl       = ?
    or p-slt-base       = ?
    or p-slt-rubl       = ?
    or p-road-tax-base  = ?
    or p-road-tax-rubl  = ?
    or p-transport-base = ?
    or p-transport-rubl = ?
    or p-other-base     = ?
    or p-other-rubl     = ?
    or p-excise-base    = ?
    or p-excise-rubl    = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info18 skip
        "Программа in-vatp.i вернула неопределенные значения" skip
        "p-fact-qnty"      p-fact-qnty      skip
        "p-sum-base"       p-sum-base       skip
        "p-sum-rubl"       p-sum-rubl       skip
        "p-vat-base"       p-vat-base       skip
        "p-vat-rubl"       p-vat-rubl       skip
        "p-slt-base"       p-slt-base       skip
        "p-slt-rubl"       p-slt-rubl       skip
        "p-road-tax-base"  p-road-tax-base  skip
        "p-road-tax-rubl"  p-road-tax-rubl  skip
        "p-transport-base" p-transport-base skip
        "p-transport-rubl" p-transport-rubl skip
        "p-other-base"     p-other-base     skip
        "p-other-rubl"     p-other-rubl     skip
        "p-excise-base"    p-excise-base    skip
        "p-excise-rubl"    p-excise-rubl    skip
        view-as alert-box error .
      undo, return error .
    end.
  end.
end procedure.
define variable vss-include-info25 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define variable v-fmtcli-name          as character    no-undo.
define variable v-fmtcli-engl-name     as character    no-undo.
define variable v-fmtcli-addres        as character    no-undo.
define variable v-fmtcli-post-addres   as character    no-undo.
define variable v-fmtcli-full-addres   as character    no-undo.
define variable v-fmtcli-phone         as character    no-undo.
define variable v-fmtcli-inn           as character    no-undo.
define variable v-fmtcli-kpp           as character    no-undo.
define variable v-fmtcli-okpo          as character    no-undo.
define variable v-fmtcli-country       as character    no-undo.
define variable v-fmtcli-city          as character    no-undo.
define variable v-fmtcli-index         as character    no-undo.
define variable v-fmtcli-schet-exists  as logical      no-undo.
define variable v-fmtcli-bank-exists   as logical      no-undo.
define variable v-fmtcli-bank-r-schet  as character    no-undo.
define variable v-fmtcli-bank-c-schet  as character    no-undo.
define variable v-fmtcli-bank-bik      as character    no-undo.
define variable v-fmtcli-bank-name     as character    no-undo.
define variable v-fmtcli-bank-addres   as character    no-undo.
define variable v-fmtcli-bank-city     as character    no-undo.
procedure fmtcli-get-bank :
define input parameter p-host-code      as integer          no-undo.
define input parameter p-obj-type       as character        no-undo.
define input parameter p-obj-code       as integer          no-undo.
define input parameter p-curr-code      as integer          no-undo.
    define buffer buf_fin-schet     for ub.fin-schet.
    define buffer buf_fin-bank      for ub.fin-bank.
do
for buf_fin-schet
  , buf_fin-bank
on error undo, return error
:
    assign
        v-fmtcli-schet-exists       = no
        v-fmtcli-bank-exists        = no
        v-fmtcli-bank-r-schet       = "":U
        v-fmtcli-bank-c-schet       = "":U
        v-fmtcli-bank-bik           = "":U
        v-fmtcli-bank-name          = "":U
        v-fmtcli-bank-addres        = "":U
        v-fmtcli-bank-city          = "":U
    .
    search-for-schet:
    for each buf_fin-schet no-lock
       where buf_fin-schet.host-code = p-host-code
         and buf_fin-schet.cli-type  = p-obj-type
         and buf_fin-schet.cli-code  = p-obj-code
         and buf_fin-schet.curr-code = p-curr-code
    on error undo, return error
    :
        if buf_fin-schet.status_   = 'удал':U
        then do:
        end.
        else do:
            assign
                v-fmtcli-schet-exists   = yes
                v-fmtcli-bank-r-schet   = trim( buf_fin-schet.r-schet )
                v-fmtcli-bank-c-schet   = trim( buf_fin-schet.c-schet )
            .
            find first buf_fin-bank no-lock
                 where buf_fin-bank.host-code = p-host-code
                   and buf_fin-bank.code-bank = buf_fin-schet.code-bank
            no-error.
            if available buf_fin-bank
            then do:
                assign
                    v-fmtcli-bank-exists      = yes
                    v-fmtcli-bank-bik         = trim( buf_fin-bank.bik )
                    v-fmtcli-bank-name        = trim( buf_fin-bank.bank-name )
                    v-fmtcli-bank-addres      = trim(buf_fin-bank.addres)
                    v-fmtcli-bank-city      = trim(buf_fin-bank.bank-city)
                .
            end.
            else do:
                assign
                    v-fmtcli-bank-exists    = no
                    v-fmtcli-bank-bik       = "":U
                    v-fmtcli-bank-name      = "":U
                    v-fmtcli-bank-addres    = "":U
                    v-fmtcli-bank-city      = "":U
                .
            end.
            leave search-for-schet.
        end.
    end.
end.
end procedure.
procedure fmtcli-get-client :
define input parameter p-obj-type       as character    no-undo.
define input parameter p-obj-code       as integer      no-undo.
    define variable v-temp-fmtcli-address      as character     no-undo.
    define variable v-num-country-city    as integer      no-undo.
    define buffer buf_clients   for ub.clients.
    define buffer buf_firm      for ub.firm.
    define buffer buf_store     for ub.store.
    define buffer buf_shop      for ub.shop.
    define buffer buf_person    for ub.person.
do
for buf_clients
  , buf_firm
  , buf_store
  , buf_shop
  , buf_person
on error undo, return error
:
    assign
        v-fmtcli-name           = "":U
        v-fmtcli-addres         = "":U
        v-fmtcli-post-addres    = "":U
        v-fmtcli-full-addres    = "":U
        v-fmtcli-phone          = "":U
        v-fmtcli-inn            = "":U
        v-fmtcli-kpp            = "":U
        v-fmtcli-okpo           = "":U
        v-fmtcli-city           = "":U
        v-fmtcli-index          = "":U
        v-fmtcli-country        = "":U
    .
    find first buf_clients no-lock
         where buf_clients.obj-type = p-obj-type
           and buf_clients.obj-code = p-obj-code
    .
    assign
        v-fmtcli-name = buf_clients.obj-name
    .
    case buf_clients.obj-type:
       when 'орг':U
       then do:
            find first buf_firm no-lock
                 where buf_firm.firm-code = buf_clients.obj-code
                 no-error
            .
            if available buf_firm
            then do:
                assign
                    v-num-country-city = num-entries( buf_firm.city )
                    v-fmtcli-engl-name = buf_firm.engl-name
                .
                if v-num-country-city > 0
                then do:
                    assign
                        v-fmtcli-country    = trim( entry( 1, buf_firm.city ) )
                    .
                end.
                if v-num-country-city > 1
                then do:
                    assign
                        v-fmtcli-city       = trim( entry( 2, buf_firm.city ) )
                    .
                end.
                run fmtcli-concatenate-strings in this-procedure (
                      input v-fmtcli-full-addres
                    , input v-fmtcli-country
                    , input ", ":U
                    , input 50
                    , output v-fmtcli-full-addres
                ).
                run fmtcli-concatenate-strings in this-procedure (
                      input v-fmtcli-full-addres
                    , input v-fmtcli-city
                    , input ", ":U
                    , input 50
                    , output v-fmtcli-full-addres
                ).
                run fmtcli-concatenate-strings in this-procedure (
                      input v-fmtcli-full-addres
                    , input IF buf_firm.ind = 0 THEN "" ELSE string( buf_firm.ind )
                    , input ", ":U
                    , input 50
                    , output v-fmtcli-full-addres
                ).
                run fmtcli-concatenate-strings in this-procedure (
                      input v-fmtcli-post-addres
                    , input v-fmtcli-country
                    , input ", ":U
                    , input 50
                    , output v-fmtcli-post-addres
                ).
                run fmtcli-concatenate-strings in this-procedure (
                      input v-fmtcli-post-addres
                    , input v-fmtcli-city
                    , input ", ":U
                    , input 50
                    , output v-fmtcli-post-addres
                ).
                run fmtcli-concatenate-strings in this-procedure (
                      input v-fmtcli-post-addres
                    , input string( buf_firm.ind )
                    , input ", ":U
                    , input 50
                    , output v-fmtcli-post-addres
                ).
                run fmtcli-concatenate-strings in this-procedure (
                      input substring( buf_firm.addres1, 1, 50 )
                    , input buf_firm.addres2
                    , input " ":U
                    , input 50
                    , output v-temp-fmtcli-address
                ).
                run fmtcli-concatenate-strings in this-procedure (
                      input v-temp-fmtcli-address
                    , input substring( buf_firm.addres1, 51, 50 )
                    , input " ":U
                    , input 50
                    , output v-temp-fmtcli-address
                ).
                run fmtcli-concatenate-strings in this-procedure (
                      input v-temp-fmtcli-address
                    , input substring( buf_firm.addres1, 101, 50 )
                    , input " ":U
                    , input 50
                    , output v-temp-fmtcli-address
                ).
                assign
                    v-fmtcli-addres = v-temp-fmtcli-address
                .
                if buf_firm.addres1 <> ?
                then do:
                    run fmtcli-concatenate-strings in this-procedure (
                          input v-fmtcli-full-addres
                        , input v-fmtcli-addres
                        , input ", ":U
                        , input 0
                        , output v-fmtcli-full-addres
                    ).
                end.
                run fmtcli-concatenate-strings in this-procedure (
                      input substring( buf_firm.post-addr1, 1, 50 )
                    , input buf_firm.post-addr2
                    , input " ":U
                    , input 50
                    , output v-fmtcli-post-addres
                ).
                run fmtcli-concatenate-strings in this-procedure (
                      input v-fmtcli-post-addres
                    , input substring( buf_firm.post-addr1, 51, 50 )
                    , input " ":U
                    , input 50
                    , output v-fmtcli-post-addres
                ).
                run fmtcli-concatenate-strings in this-procedure (
                      input v-fmtcli-post-addres
                    , input substring( buf_firm.post-addr1, 101, 50 )
                    , input " ":U
                    , input 50
                    , output v-fmtcli-post-addres
                ).
                assign
                    v-fmtcli-phone         = buf_firm.phone
                    v-fmtcli-inn           = buf_firm.inn
                    v-fmtcli-kpp           = buf_firm.kpp
                    v-fmtcli-okpo          = buf_firm.okpo
                    v-fmtcli-index         = string( buf_firm.ind )
                .
            end.
       end.
       when 'маг':U
       then do:
            find first buf_shop no-lock
                 where buf_shop.obj-code = buf_clients.obj-code
            .
            if available buf_shop
            then do:
                run fmtcli-concatenate-strings in this-procedure (
                      input buf_shop.addres1
                    , input buf_shop.addres2
                    , input " ":U
                    , input 50
                    , output v-fmtcli-addres
                ).
                assign
                    v-fmtcli-full-addres = v-fmtcli-addres
                    v-fmtcli-post-addres = v-fmtcli-addres
                    v-fmtcli-phone       = buf_shop.phone
                    v-fmtcli-inn         = "":U
                    v-fmtcli-kpp         = "":U
                    v-fmtcli-okpo        = "":U
                    v-fmtcli-city        = "":U
                    v-fmtcli-index       = "":U
                .
            end.
       end.
       when 'скл':U
       then do:
            find first buf_store no-lock
                 where buf_store.obj-code = buf_clients.obj-code
            .
            if available buf_store
            then do:
                run fmtcli-concatenate-strings in this-procedure (
                      input buf_store.addres1
                    , input buf_store.addres2
                    , input " ":U
                    , input 50
                    , output v-fmtcli-addres
                ).
                assign
                    v-fmtcli-full-addres = v-fmtcli-addres
                    v-fmtcli-phone       = buf_store.phone
                    v-fmtcli-inn         = "":U
                    v-fmtcli-kpp         = "":U
                    v-fmtcli-okpo        = "":U
                    v-fmtcli-city        = "":U
                    v-fmtcli-index       = "":U
                .
            end.
       end.
       when 'чел':U
       then do:
            find first buf_person no-lock
                 where buf_person.psn-code = buf_clients.obj-code
            .
            if available buf_person
            then do:
                run fmtcli-concatenate-strings in this-procedure (
                      input ( if buf_person.ind = 0 or buf_person.ind = ?
                              then "":U
                              else string( buf_person.ind, "999999")
                              )
                    , input buf_person.city
                    , input ", ":U
                    , input 0
                    , output v-fmtcli-full-addres
                ).
                assign
                    v-fmtcli-addres = buf_person.address
                .
                run fmtcli-concatenate-strings in this-procedure (
                      input v-fmtcli-full-addres
                    , input v-fmtcli-addres
                    , input ", ":U
                    , input 0
                    , output v-fmtcli-full-addres
                ).
                assign
                    v-fmtcli-phone     = buf_person.phone1
                    v-fmtcli-inn       = buf_person.inn
                    v-fmtcli-kpp       = buf_person.kpp
                    v-fmtcli-okpo      = buf_person.okpo
                    v-fmtcli-city      = buf_person.city
                    v-fmtcli-index     = string( buf_person.ind )
                .
            end.
       end.
    end case.
end.
end procedure.
procedure fmtcli-concatenate-strings :
define input parameter p-string-1       as character        no-undo.
define input parameter p-string-2       as character        no-undo.
define input parameter p-delimiter      as character        no-undo.
define input parameter p-length         as integer          no-undo.
define output parameter p-out-string    as character        no-undo.
do
on error undo, return error
:
    assign
        p-out-string = ( if p-string-1 = ?
                         then "":U
                         else trim( p-string-1 ) )
    .
    assign
        p-out-string = p-out-string
                     + ( if p-out-string = "":U
                         or length( p-out-string ) = p-length
                         or p-string-2 = ?
                         or trim( p-string-2 ) = "":U
                         then "":U
                         else p-delimiter )
                     + ( if p-string-2 = ?
                         or trim( p-string-2 ) = "":U
                         then "":U
                         else trim( p-string-2 ) )
    .
end.
end procedure.
def var vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure clntattr-code :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-code in g#attr-lib
      (input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-value :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-value    like ub.clients-attr.attr-value no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-value in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-write :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define input  parameter p-value    like ub.clients-attr.attr-value no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-write in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,input  p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-exist :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-exist in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-delete :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-delete in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-copy-to :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define input  parameter p-bh       as handle no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-copy-to in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,input  p-bh
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-archive-attr :
  define output parameter p-archive-attr-list as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-archive-attr in g#attr-lib
      (output  p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-auto-author-attr :
  define output parameter p-archive-attr-list as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-auto-author-attr in g#attr-lib
      (output  p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-archive-by-type :
  define input  parameter p-archive-type      as character no-undo .
  define output parameter p-archive-attr-list as character no-undo .
  define variable vss-description as character no-undo initial "clntattr-get-archive-by-type-01: возвращает список атрибутов для складского архива".
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-archive-by-type in g#attr-lib
      (input  p-archive-type
      ,output p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-vat-register :
  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-vat-register in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-requisite-alc-decl :
  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-requisite-alc-decl in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-manual-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
procedure thbjattr_code :
   define input  parameter p-upper-code     as character no-undo .
   define input  parameter p-code           as character no-undo .
   define output parameter p-label          as character no-undo .
   define output parameter p-user-can-edit  as logical   no-undo .
   define output parameter p-output-display as logical   no-undo .
   define output parameter p-other          as character no-undo .
   define output parameter p-prop-list      as character no-undo .
   define output parameter p-prop-type-list as character no-undo .
   define output parameter p-prop-label-list as character no-undo .
   define output parameter p-global          as logical no-undo .
   define output parameter p-host           as logical no-undo .
   define output parameter p-shop           as logical no-undo .
   define output parameter p-store          as logical no-undo .
   define output parameter p-db             as logical no-undo .
   define variable p-region as logical no-undo.
   run thbjattr_code_reg in this-procedure (
                                            p-upper-code,
                                            p-code,
                                            output p-label,
                                            output p-user-can-edit,
                                            output p-output-display,
                                            output p-other,
                                            output p-prop-list,
                                            output p-prop-type-list,
                                            output p-prop-label-list,
                                            output p-global,
                                            output p-host,
                                            output p-shop,
                                            output p-store,
                                            output p-db,
                                            output p-region
                                            ).
end procedure.
procedure thbjattr_code_reg :
define input  parameter p-upper-code     as character no-undo .
define input  parameter p-code           as character no-undo .
define output parameter p-label          as character no-undo .
define output parameter p-user-can-edit  as logical   no-undo .
define output parameter p-output-display as logical   no-undo .
define output parameter p-other          as character no-undo .
define output parameter p-prop-list      as character no-undo .
define output parameter p-prop-type-list as character no-undo .
define output parameter p-prop-label-list as character no-undo .
define output parameter p-global          as logical no-undo .
define output parameter p-host           as logical no-undo .
define output parameter p-shop           as logical no-undo .
define output parameter p-store          as logical no-undo .
define output parameter p-db             as logical no-undo .
define output parameter p-region         as logical no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_code in g#attr-lib
    (input  p-upper-code
    ,input  p-code
    ,output p-label
    ,output p-user-can-edit
    ,output p-output-display
    ,output p-other
    ,output p-prop-list
    ,output p-prop-type-list
    ,output p-prop-label-list
    ,output p-global
    ,output p-host
    ,output p-shop
    ,output p-store
    ,output p-db
    ,output p-region
    ) no-error .
  if error-status :error
  then do:
    undo, return error substitute( "&1. &2&3&4", vss-include-info27, return-value, chr(10), error-status :get-message (1)).
  end.
end.
end procedure.
procedure thbjattr_tooltip :
define input  parameter p-upper-code  as character no-undo .
define input  parameter p-code      as character no-undo .
define output parameter p-tooltip   as character no-undo .
define output parameter p-label     as character no-undo .
define output parameter p-tooltip-code as character no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_tooltip in g#attr-lib
    (input  p-upper-code
    ,input  p-code
    ,output p-tooltip
    ,output p-label
    ,output p-tooltip-code
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_legacy :
define input  parameter p-upper-code     as character no-undo .
define output parameter p-level-way      as character no-undo .
define output parameter p-up-way         as character no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_legacy in g#attr-lib
    (input  p-upper-code
    ,output p-level-way
    ,output p-up-way
    ) no-error .
  if error-status :error
  then do:
    undo, return error substitute( "&1. &2&3&4", vss-include-info27, return-value, chr(10), error-status :get-message (1)).
  end.
end.
end procedure.
procedure thbjattr_value :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-code     like ub.thbj-attr.prop-code  no-undo .
define output parameter p-value-character like ub.thbj-attr.property-value-character no-undo .
define output parameter p-value-date    like ub.thbj-attr.property-value-date no-undo .
define output parameter p-value-decimal like ub.thbj-attr.property-value-decimal no-undo .
define output parameter p-value-integer like ub.thbj-attr.property-value-integer no-undo .
define output parameter p-value-logical like ub.thbj-attr.property-value-logical no-undo .
define output parameter p-type     as character no-undo .
define output parameter p-found as decimal no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_value in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  p-code
    ,output p-value-character
    ,output p-value-date
    ,output p-value-decimal
    ,output p-value-integer
    ,output p-value-logical
    ,output p-type
    ,output p-found
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_get-section :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-param-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-mode as character no-undo .
define input-output parameter table-handle p-tth.
define output parameter p-all-found as decimal no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_get-section in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-param-code
    ,input  p-mode
    ,input-output table-handle p-tth
    ,output p-all-found
    ) no-error .
  if error-status :error
  then do:
    delete object p-tth.
    undo, return error return-value .
  end.
  delete object p-tth.
end.
end procedure.
procedure thbjattr_write :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-code     like ub.thbj-attr.prop-code  no-undo .
define input  parameter p-value-character like ub.thbj-attr.property-value-character no-undo .
define input  parameter p-value-date like ub.thbj-attr.property-value-date no-undo .
define input  parameter p-value-decimal like ub.thbj-attr.property-value-decimal no-undo .
define input  parameter p-value-integer like ub.thbj-attr.property-value-integer no-undo .
define input  parameter p-value-logical like ub.thbj-attr.property-value-logical no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_write in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  p-code
    ,input  p-value-character
    ,input  p-value-date
    ,input  p-value-decimal
    ,input  p-value-integer
    ,input  p-value-logical
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_set-section :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter table-handle p-tth.
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_set-section in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  table-handle p-tth
    ) no-error .
  if error-status :error
  then do:
    delete object p-tth.
    undo, return error return-value .
  end.
  delete object p-tth.
end.
end procedure.
procedure thbjattr_delete :
define input  parameter p-obj-type   like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code   like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-code       like ub.thbj-attr.prop-code  no-undo .
define output parameter p-deleted  as logical no-undo.
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_delete in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  p-code
    ,output p-deleted
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_delete-section :
define input  parameter p-obj-type   like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code   like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_delete-section in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_manual-edit :
define input  parameter p-ucode          as character no-undo .
define input  parameter p-code           as character no-undo .
define output parameter p-section-num    as integer no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_manual-edit in g#attr-lib
    (input  p-ucode
    ,input  p-code
    ,output  p-section-num
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
CREATE WIDGET-POOL.
define variable g#log as logical   no-undo .
define variable alc-producers_recids as character no-undo.
define variable alc-suppliers_recids as character no-undo.
define variable alc-types_recids as character no-undo.
define variable ii as integer no-undo.
define variable l-ok as logical no-undo.
define variable quarter              as integer   no-undo.
define variable firm-post-code    as character no-undo.
define variable firm-reg-code     as character no-undo.
define variable firm-district     as character no-undo.
define variable firm-city         as character no-undo.
define variable firm-settlement       as character no-undo.
define variable firm-street       as character no-undo.
define variable firm-house-number as character no-undo.
define variable firm-house-litera     as character no-undo.
define variable firm-house-case       as character no-undo.
define variable firm-house-apartment  as character no-undo.
define variable firm-director-f       as character no-undo.
define variable firm-director-i       as character no-undo.
define variable firm-director-o       as character no-undo.
define variable firm-accountant-f     as character no-undo.
define variable firm-accountant-i     as character no-undo.
define variable firm-accountant-o     as character no-undo.
define variable firm-e-mail      as character no-undo.
define variable firm-country-code     as character no-undo.
define variable v-value-character   as character no-undo .
define variable v-value-decimal     as decimal   no-undo .
define variable v-value-integer     as integer   no-undo .
define variable v-value-logical     as logical   no-undo .
define variable v-value-type        as character no-undo .
define variable v-value-date        as date      no-undo .
define variable v-ext-sys           as integer   no-undo .
define variable v-kpp               as character no-undo .
define variable v-inner-code        as integer   no-undo .
define variable ext-cl              as class extgds no-undo .
define variable ext-FormF1          as class extFormF1 no-undo .
define temp-table alc-producers
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    index pi is unique primary obj-type obj-code.
define temp-table alc-suppliers
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    index pi is unique primary obj-type obj-code.
define temp-table alc-types
    field type-code     like ub.alc-type.alc-type-inner-code
    field alc-type-name like ub.alc-type.alc-type-name
    field alc-type-code like ub.alc-type.alc-type-code
    index pi is unique primary type-code.
define temp-table alc-goods
    field gds-code  like ub.alc-type-gds.gds-code
    field artic     like ub.goods.artic
    field prod-type like ub.goods.prod-type
    field prod-code like ub.goods.prod-code
    field alpha1    like ub.goods.alpha1
    field type-code like ub.alc-type-gds.alc-type-inner-code
    field vol       like ub.goods.ms-base
    index pi is unique primary gds-code.
define temp-table page-2
    field obj-type          like ub.clients.obj-type
    field obj-code          like ub.clients.obj-code
    field obj-name          like ub.clients.obj-name
    field country-code      as   character
    field kpp               like ub.firm.kpp
    field post-code         as   character
    field reg-code          as   character
    field district          as   character
    field city              as   character
    field settlement        as   character
    field street            as   character
    field house-number      as   character
    field house-litera      as   character
    field house-case        as   character
    field apartment         as   character
    index pi is unique primary obj-type obj-code.
define temp-table part-1
    field prod-code         like ub.goods.prod-code
    field prod-type         like ub.goods.prod-type
    field type-code         like ub.alc-type.alc-type-inner-code
    field foreign           as logical
    field obj-type          like ub.clients.obj-type
    field obj-code          like ub.clients.obj-code
    field obj-kpp           like ub.firm.kpp
    field alc-type-name     like ub.alc-type.alc-type-name
    field alc-type-code     like ub.alc-type.alc-type-code
    field producer-obj-name like ub.clients.obj-name
    field producer-inn      like ub.firm.inn
    field producer-kpp      like ub.firm.kpp
    field remain-6          as decimal decimals 5
    field inc-7             as decimal decimals 5
    field inc-8             as decimal decimals 5
    field inc-9             as decimal decimals 5
    field inc-10            as decimal decimals 5
    field inc-11            as decimal decimals 5
    field inc-12            as decimal decimals 5
    field inc-13            as decimal decimals 5
    field inc-14            as decimal decimals 5
    field exp-15            as decimal decimals 5
    field exp-16            as decimal decimals 5
    field exp-17            as decimal decimals 5
    field exp-18            as decimal decimals 5
    field exp-19            as decimal decimals 5
    field remain-20         as decimal decimals 5
    index pi is unique primary type-code prod-code prod-type obj-type obj-code
    index producer-obj-name producer-obj-name.
define temp-table part-2
    field obj-type                   like ub.clients.obj-type
    field obj-code                   like ub.clients.obj-code
    field obj-kpp                    like ub.firm.kpp
    field prod-code                  like ub.goods.prod-code
    field prod-type                  like ub.goods.prod-type
    field supplier-code              like ub.goods.prod-code
    field supplier-type              like ub.goods.prod-type
    field alc-type-name              like ub.alc-type.alc-type-name
    field alc-type-code              like ub.alc-type.alc-type-code
    field producer-obj-name          like ub.clients.obj-name
    field producer-inn               like ub.firm.inn
    field producer-kpp               like ub.firm.kpp
    field supplier-obj-name          like ub.clients.obj-name
    field supplier-inn               like ub.firm.inn
    field supplier-kpp               like ub.firm.kpp
    field supplier-serial-number     as character
    field supplier-date-get          as character
    field supplier-date-to           as character
    field supplier-get-from          like ub.alc-sale-lic.who-are-got
    field purchase-date              as date
    field GTD                        like ub.parts.cst-code
    field TTN                        as character
    field total                      as decimal
    index obj-date-sort obj-type obj-code purchase-date
    index alc-sort alc-type-code
    index licenses supplier-serial-number.
define temp-table tt-parts-info
    field obj-type          like ub.clients.obj-type
    field obj-code          like ub.clients.obj-code
    field part-code         like ub.parts.part-code
    field out-code          like ub.parts.out-code
    field in-code           like ub.parts.in-code
    field artic             like ub.goods.artic
    field alc-code          as character
    field prod-type         like ub.goods.prod-type
    field prod-code         like ub.goods.prod-code
    field alc-type-code     like ub.alc-type.alc-type-code
    field producer-obj-name like ub.clients.obj-name
    field producer-inn      like ub.firm.inn
    field producer-kpp      like ub.firm.kpp
    field remain-6          as   decimal decimals 5
    field inc-7             as   decimal decimals 5
    field inc-8             as   decimal decimals 5
    field inc-9             as   decimal decimals 5
    field inc-10            as   decimal decimals 5
    field inc-11            as   decimal decimals 5
    field inc-12            as   decimal decimals 5
    field inc-13            as   decimal decimals 5
    field inc-14            as   decimal decimals 5
    field exp-15            as   decimal decimals 5
    field exp-16            as   decimal decimals 5
    field exp-17            as   decimal decimals 5
    field exp-18            as   decimal decimals 5
    field exp-19            as   decimal decimals 5
    field remain-20         as   decimal decimals 5
    field importer          as   character
    index pi as primary unique
        obj-type obj-code artic prod-type prod-code in-code out-code part-code
.
define stream OutStr-html.
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define stream logStr.
define variable v-inn-err as logical no-undo .
define buffer buf_clients           for ub.clients.
define buffer buf_alc-type          for ub.alc-type.
define buffer buf_alc-type-attr     for ub.alc-type-attr.
define buffer buf_clients-attr      for ub.clients-attr.
define buffer buf_alc-type-gds      for ub.alc-type-gds.
define buffer buf_goods             for ub.goods.
define buffer buf_trn-doc           for ub.trn-doc.
define buffer buf_doc-line          for ub.doc-line.
define buffer buf_parts             for ub.parts.
define buffer buf_firm              for ub.firm.
define buffer buf_alc-supp-lic      for ub.alc-supp-lic.
define buffer buf_person            for ub.person.
define buffer buf_alc-sale-lic      for ub.alc-sale-lic.
define buffer buf_sysconf           for ub.sysconf.
define buffer buf_part-2            for part-2.
define buffer x_ext-classif         for ub.ext-classif.
DEFINE VARIABLE EDITOR-ALC-PRODUCER AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 50 BY 2.62 NO-UNDO.
DEFINE VARIABLE EDITOR-ALC-TYPE AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 50 BY 2.62 NO-UNDO.
DEFINE VARIABLE EDITOR-SUPPLIER AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 50 BY 2.62 NO-UNDO.
DEFINE VARIABLE FILL-IN-kor AS INTEGER FORMAT ">>9":U
     LABEL "№ кор"
     VIEW-AS FILL-IN
     SIZE 5 BY 1 NO-UNDO.
DEFINE VARIABLE RADIO-ALC-PRODUCER AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Все", 1,
"Выборочно", 2
     SIZE 16 BY 2.38 NO-UNDO.
DEFINE VARIABLE RADIO-ALC-TYPE AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Все", 1,
"Выборочно", 2
     SIZE 16 BY 2.38 NO-UNDO.
DEFINE VARIABLE RADIO-SET-form AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Первичная", 1,
"Корректирующая", 2
     SIZE 41 BY .95 NO-UNDO.
DEFINE VARIABLE RADIO-SET-ver AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "4.31", 1,
          "4.30", 3,
"4.20", 2
     SIZE 20 BY .95 NO-UNDO.
DEFINE VARIABLE RADIO-SUPPLIER AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Все", 1,
"Выборочно", 2
     SIZE 16 BY 2.38 NO-UNDO.
DEFINE RECTANGLE RECT-13
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 72 BY 18.
DEFINE VARIABLE TOGGLE-Excel AS LOGICAL INITIAL yes
     LABEL "Excel"
     VIEW-AS TOGGLE-BOX
     SIZE 10 BY .81 NO-UNDO.
DEFINE VARIABLE TOGGLE-XML AS LOGICAL INITIAL yes
     LABEL "XML"
     VIEW-AS TOGGLE-BOX
     SIZE 9 BY .81 NO-UNDO.
DEFINE VARIABLE TOGGLE-KPP AS LOGICAL INITIAL no
     LABEL "Объединять данные по объектам с одинаковым КПП"
     VIEW-AS TOGGLE-BOX
     SIZE 50 BY .81 NO-UNDO.
DEFINE FRAME F-Main
     RADIO-SET-ver AT ROW 1.62 COL 13 NO-LABEL WIDGET-ID 58
     FILL-IN-kor AT ROW 2.43 COL 65 COLON-ALIGNED WIDGET-ID 70
     RADIO-SET-form AT ROW 2.5 COL 13 NO-LABEL WIDGET-ID 66
     RADIO-ALC-PRODUCER AT ROW 4.81 COL 4 NO-LABEL WIDGET-ID 26
     EDITOR-ALC-PRODUCER AT ROW 4.81 COL 22 NO-LABEL WIDGET-ID 32
     RADIO-SUPPLIER AT ROW 8.86 COL 4 NO-LABEL WIDGET-ID 50
     EDITOR-SUPPLIER AT ROW 8.86 COL 22 NO-LABEL WIDGET-ID 40
     RADIO-ALC-TYPE AT ROW 12.67 COL 4 NO-LABEL WIDGET-ID 44
     EDITOR-ALC-TYPE AT ROW 12.67 COL 22 NO-LABEL WIDGET-ID 42
     TOGGLE-Excel AT ROW 15.76 COL 33 WIDGET-ID 52
     TOGGLE-XML AT ROW 15.76 COL 44 WIDGET-ID 54
     TOGGLE-KPP AT ROW 17 COL 4 WIDGET-ID 80
     "Выбор поставщика" VIEW-AS TEXT
          SIZE 23 BY .62 AT ROW 8.14 COL 4 WIDGET-ID 34
          FGCOLOR 4
     "Форма" VIEW-AS TEXT
          SIZE 9 BY .62 AT ROW 2.67 COL 4 WIDGET-ID 64
          FGCOLOR 4
     "Версия" VIEW-AS TEXT
          SIZE 9 BY .62 AT ROW 1.71 COL 4 WIDGET-ID 62
          FGCOLOR 4
     "Выбор вида алкогольной продукции" VIEW-AS TEXT
          SIZE 38 BY .62 AT ROW 11.95 COL 4 WIDGET-ID 48
          FGCOLOR 4
     "Выбор производителя" VIEW-AS TEXT
          SIZE 23 BY .62 AT ROW 3.86 COL 4 WIDGET-ID 30
          FGCOLOR 4
     "Вывести отчет в формате:" VIEW-AS TEXT
          SIZE 28 BY .71 AT ROW 15.86 COL 4 WIDGET-ID 56
     RECT-13 AT ROW 1.29 COL 2 WIDGET-ID 18
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1 SCROLLABLE
         BGCOLOR 8 .
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
    DISABLE RECT-13 RADIO-SET-ver FILL-IN-kor RADIO-SET-form RADIO-ALC-PRODUCER EDITOR-ALC-PRODUCER RADIO-SUPPLIER EDITOR-SUPPLIER RADIO-ALC-TYPE EDITOR-ALC-TYPE TOGGLE-Excel TOGGLE-XML TOGGLE-KPP WITH FRAME F-Main.
    RUN dispatch ('disable-fields':U).
    RUN set-attribute-list ('ENABLED=no':U).
    RETURN.
END PROCEDURE.
PROCEDURE adm-edit-attribute-list :
      RUN adm/support/viewerd.w (INPUT THIS-PROCEDURE).
      RETURN.
END PROCEDURE.
PROCEDURE adm-enable :
    ENABLE UNLESS-HIDDEN RECT-13 RADIO-SET-ver FILL-IN-kor RADIO-SET-form RADIO-ALC-PRODUCER EDITOR-ALC-PRODUCER RADIO-SUPPLIER EDITOR-SUPPLIER RADIO-ALC-TYPE EDITOR-ALC-TYPE TOGGLE-Excel TOGGLE-XML TOGGLE-KPP WITH FRAME F-Main.
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
       FRAME F-Main:HIDDEN           = TRUE
       FRAME F-Main:PRIVATE-DATA     =
                "DLGCLOSE".
ASSIGN
       EDITOR-ALC-PRODUCER:READ-ONLY IN FRAME F-Main        = TRUE.
ASSIGN
       EDITOR-ALC-TYPE:READ-ONLY IN FRAME F-Main        = TRUE.
ASSIGN
       EDITOR-SUPPLIER:READ-ONLY IN FRAME F-Main        = TRUE.
ON VALUE-CHANGED OF RADIO-ALC-PRODUCER IN FRAME F-Main
DO:
    assign RADIO-ALC-PRODUCER.
    for each alc-producers:
        delete alc-producers.
    end.
    case RADIO-ALC-PRODUCER:
       when 1 then do:
           assign  EDITOR-ALC-PRODUCER = "По всем производителям".
           display EDITOR-ALC-PRODUCER with frame F-Main.
       end.
       when 2 then do:
           run ref/cli-all.w ( my-handle
                        , "b-sel,b-mark"
                        , 'орг':U
                        , 'все':U
                        , ?
                        , ?
                        , ",,,,,,NO,,"
                        , ?
                        , output alc-producers_recids).
           if alc-producers_recids = "" then do:
                assign  EDITOR-ALC-PRODUCER = "По всем производителям" RADIO-ALC-PRODUCER = 1.
                display EDITOR-ALC-PRODUCER RADIO-ALC-PRODUCER with frame F-Main.
           end.
           else do:
               assign  EDITOR-ALC-PRODUCER = ''.
               do ii = 1 to num-entries( alc-producers_recids ):
                   find first buf_clients where recid( buf_clients ) = int(entry( ii, alc-producers_recids )) no-lock no-error.
                     if available buf_clients then do:
                         create alc-producers.
                         assign
                           alc-producers.obj-type = buf_clients.obj-type
                           alc-producers.obj-code = buf_clients.obj-code
                           alc-producers.obj-name = buf_clients.obj-name.
                           EDITOR-ALC-PRODUCER = EDITOR-ALC-PRODUCER + alc-producers.obj-name + chr(10).
                     end.
               end.
                display EDITOR-ALC-PRODUCER with frame F-Main .
           end.
       end.
    end case.
END.
ON VALUE-CHANGED OF RADIO-ALC-TYPE IN FRAME F-Main
DO:
    assign RADIO-ALC-TYPE.
    for each alc-types : delete alc-types. end.
    case RADIO-ALC-TYPE:
       when 1 then do:
           assign  EDITOR-ALC-TYPE = "По всем типам продукции".
           display EDITOR-ALC-TYPE with frame F-Main.
       end.
       when 2 then do:
           run ref/alc-type.w ( my-handle
                              , "b-sel,b-mark,alc-p"
                              , input-output alc-types_recids
                              , output l-ok).
           if alc-types_recids = "" then do:
                assign  EDITOR-ALC-TYPE = "По всем типам продукции" RADIO-ALC-TYPE = 1.
                display EDITOR-ALC-TYPE RADIO-ALC-TYPE with frame F-Main.
           end.
           else do:
               for each alc-types exclusive-lock:
                   delete alc-types.
               end.
               assign  EDITOR-ALC-TYPE = ''.
               do ii = 1 to num-entries(alc-types_recids):
                   find first buf_alc-type where recid( buf_alc-type ) = int(entry( ii, alc-types_recids)) no-lock no-error.
                     if available buf_alc-type then do:
                         create alc-types.
                         assign
                           alc-types.type-code     = buf_alc-type.alc-type-inner-code
                           alc-types.alc-type-name = buf_alc-type.alc-type-name
                           alc-types.alc-type-code = buf_alc-type.alc-type-code
                           EDITOR-ALC-TYPE = EDITOR-ALC-TYPE + alc-types.alc-type-name + chr(10).
                     end.
               end.
                display EDITOR-ALC-TYPE with frame F-Main .
           end.
       end.
    end case.
END.
ON VALUE-CHANGED OF RADIO-SUPPLIER IN FRAME F-Main
DO:
    assign RADIO-SUPPLIER.
    for each alc-suppliers:
        delete alc-suppliers.
    end.
    case RADIO-SUPPLIER:
       when 1 then do:
           assign  EDITOR-SUPPLIER = "По всем поставщикам".
           display EDITOR-SUPPLIER with frame F-Main.
       end.
       when 2 then do:
           run ref/cli-all.w ( my-handle
                        , "b-sel,b-mark"
                        , 'орг':U
                        , 'все':U
                        , ?
                        , ?
                        , ",,,,,,NO,,"
                        , ?
                        , output alc-suppliers_recids).
           if alc-suppliers_recids = "" then do:
                assign  EDITOR-SUPPLIER = "По всем поставщикам" RADIO-SUPPLIER = 1.
                display EDITOR-SUPPLIER RADIO-SUPPLIER with frame F-Main.
           end.
           else do:
               assign  EDITOR-SUPPLIER = ''.
               do ii = 1 to num-entries( alc-suppliers_recids ):
                   find first buf_clients where recid( buf_clients ) = int(entry( ii, alc-suppliers_recids )) no-lock no-error.
                     if available buf_clients then do:
                         create alc-suppliers.
                         assign
                           alc-suppliers.obj-type = buf_clients.obj-type
                           alc-suppliers.obj-code = buf_clients.obj-code
                           alc-suppliers.obj-name = buf_clients.obj-name
                           EDITOR-SUPPLIER = EDITOR-SUPPLIER + alc-suppliers.obj-name + chr(10).
                end.
            end.
                display EDITOR-SUPPLIER with frame F-Main .
            end.
       end.
    end case.
END.
ON VALUE-CHANGED OF RADIO-SET-form IN FRAME F-Main
DO:
    assign RADIO-SET-form.
    case RADIO-SET-form:
        when 1 then
            assign FILL-IN-kor:hidden in frame F-Main = true.
        when 2 then
            assign FILL-IN-kor:hidden in frame F-Main = false.
    end case.
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
PROCEDURE my-report :
define variable fact-order-start as decimal   no-undo.
define variable fact-order-end   as decimal   no-undo.
define variable wait-message     as character no-undo.
define variable imp-or-prod-type as character no-undo.
define variable imp-or-prod-code as integer   no-undo.
define variable v-attr-val       as character no-undo.
define variable v-attr-type      as character no-undo.
assign frame F-Main RADIO-ALC-PRODUCER RADIO-ALC-TYPE RADIO-SUPPLIER TOGGLE-Excel
    TOGGLE-XML TOGGLE-KPP RADIO-SET-ver RADIO-SET-form FILL-IN-kor.
for each part-1 exclusive-lock:
    delete part-1.
end.
for each part-1 exclusive-lock:
    delete part-2.
end.
quarter = 1.
l-ok = yes.
if day(x-date-start) = 1 and month(x-date-end + 1) <> month(x-date-end) then do:
    if month(x-date-start) = 1  and month(x-date-end) = 3  then quarter = 3.
    if month(x-date-start) = 4  and month(x-date-end) = 6  then quarter = 6.
    if month(x-date-start) = 7  and month(x-date-end) = 9  then quarter = 9.
    if month(x-date-start) = 10 and month(x-date-end) = 12 then quarter = 0.
end.
if quarter = 1 then message "Даты не совпадают с кварталом" skip "Продолжить?" view-as alert-box buttons yes-no update l-OK.
if l-ok = no then return.
run day-begin-fact-order(input x-date-start, output fact-order-start).
run factord-end-day(input x-date-end, output fact-order-end).
if RADIO-ALC-PRODUCER = 2 then do:
    for each alc-producers exclusive-lock :
        find first buf_clients-attr no-lock where buf_clients-attr.obj-code = alc-producers.obj-code
                                              and buf_clients-attr.obj-type = alc-producers.obj-type
                                              and buf_clients-attr.attr-code = 'cli-alc-producer':U no-error.
        if not available (buf_clients-attr) then delete alc-producers.
    end.
    end.
if TOGGLE-Excel = no and TOGGLE-XML = no then do:
    message "Выберите формат вывода" view-as alert-box warning buttons ok.
    return.
end.
case RADIO-ALC-TYPE:
    when 1 then do:
        for each alc-types exclusive-lock:
            delete alc-types.
        end.
        for each buf_alc-type,
            first buf_alc-type-attr where buf_alc-type-attr.attr-code = "alc-type"
                                     and buf_alc-type-attr.attr-value = "2"
                                     and buf_alc-type-attr.alc-type-inner-code = buf_alc-type.alc-type-inner-code
                                     :
            create alc-types.
            assign
            alc-types.type-code     = buf_alc-type.alc-type-inner-code
            alc-types.alc-type-name = buf_alc-type.alc-type-name
            alc-types.alc-type-code = buf_alc-type.alc-type-code.
        end.
    end.
end case.
case x-SelectGood:
    when 1 then do:
        for each alc-goods exclusive-lock:
            delete alc-goods.
        end.
      for each alc-types no-lock:
        for each buf_alc-type-gds no-lock
                                  where buf_alc-type-gds.alc-type-inner-code = alc-types.type-code:
            for first buf_goods no-lock where buf_goods.gds-code = buf_alc-type-gds.gds-code
                                        and buf_goods.stts = 0:
                if RADIO-ALC-PRODUCER = 2 and
                not can-find(first alc-producers where alc-producers.obj-type = buf_goods.prod-type
                                                   and alc-producers.obj-code = buf_goods.prod-code)
                then next.
                create alc-goods.
                assign
                alc-goods.gds-code  = buf_alc-type-gds.gds-code
                alc-goods.type-code = buf_alc-type-gds.alc-type-inner-code
                alc-goods.artic     = buf_goods.artic
                alc-goods.prod-type = buf_goods.prod-type
                alc-goods.prod-code = buf_goods.prod-code
                alc-goods.alpha1    = buf_goods.alpha1
                alc-goods.vol       = buf_goods.ms-base.
            end.
        end.
      end.
    end.
end case.
for first buf_clients no-lock where buf_clients.obj-code = v-cntxt-host-code-obj
                              and   buf_clients.obj-type = 'орг':U:
  run fmtcli-get-client in this-procedure ( input buf_clients.obj-type, input  buf_clients.obj-code ).
end.
for first buf_clients-attr no-lock where buf_clients-attr.obj-type = 'орг':U
                                   and   buf_clients-attr.obj-code = v-cntxt-host-code-obj
                                   and   buf_clients-attr.attr-code = 'requisite-alc-decl':U:
    assign
        v-fmtcli-name         = entry( 1, buf_clients-attr.attr-value, "|")
        firm-country-code     = entry( 3, buf_clients-attr.attr-value, "|")
        firm-post-code    = entry( 4, buf_clients-attr.attr-value, "|")
        firm-reg-code     = entry( 5, buf_clients-attr.attr-value, "|")
        firm-district     = entry( 6, buf_clients-attr.attr-value, "|")
        firm-city             = entry( 7, buf_clients-attr.attr-value, "|")
        firm-settlement       = entry( 8, buf_clients-attr.attr-value, "|")
        firm-street       = entry( 9, buf_clients-attr.attr-value, "|")
        firm-house-number     = entry (10,buf_clients-attr.attr-value,"|")
        firm-house-case       = entry (11,buf_clients-attr.attr-value,"|")
        firm-house-apartment = entry (12,buf_clients-attr.attr-value,"|")
        firm-house-litera     = entry (13,buf_clients-attr.attr-value,"|")
        firm-director-f       = entry (14,buf_clients-attr.attr-value,"|")
        firm-director-i       = entry (15,buf_clients-attr.attr-value,"|")
        firm-director-o       = entry (16,buf_clients-attr.attr-value,"|")
        firm-accountant-f     = entry (17,buf_clients-attr.attr-value,"|")
        firm-accountant-i     = entry (18,buf_clients-attr.attr-value,"|")
        firm-accountant-o     = entry (19,buf_clients-attr.attr-value,"|") no-error.
end.
for first buf_firm no-lock where buf_firm.firm-code = v-cntxt-host-code-obj:
        firm-e-mail     = buf_firm.e-mail.
end.
for each obj-list no-lock break by obj-list.obj-type :
    v-kpp = "" .
    for first buf_clients-attr no-lock where buf_clients-attr.obj-code  = obj-list.obj-code
                                       and   buf_clients-attr.obj-type  = obj-list.obj-type
                                       and   buf_clients-attr.attr-code = 'kpp':U:
        v-kpp = buf_clients-attr.attr-value.
    end.
    if v-kpp = "" then  v-kpp = v-fmtcli-kpp.
    if TOGGLE-KPP then do :
        find first page-2 exclusive-lock where page-2.kpp = v-kpp no-error.
        if available page-2 then do :
            release page-2 .
            next .
        end.
    end.
    if not available page-2 then do :
        create page-2.
        page-2.obj-type = obj-list.obj-type.
        page-2.obj-code = obj-list.obj-code.
        page-2.kpp      = v-kpp .
    end.
    for first buf_clients-attr no-lock where buf_clients-attr.obj-code  = obj-list.obj-code
                                       and   buf_clients-attr.obj-type  = obj-list.obj-type
                                       and   buf_clients-attr.attr-code = 'requisite-alc-decl':U:
        assign
        page-2.obj-name     = entry( 1, buf_clients-attr.attr-value, "|")
        page-2.country-code = entry( 3, buf_clients-attr.attr-value, "|")
        page-2.post-code   = entry( 4, buf_clients-attr.attr-value, "|")
        page-2.reg-code     = entry( 5, buf_clients-attr.attr-value, "|")
        page-2.district     = entry( 6, buf_clients-attr.attr-value, "|")
        page-2.city         = entry( 7, buf_clients-attr.attr-value, "|")
        page-2.settlement   = entry( 8, buf_clients-attr.attr-value, "|")
        page-2.street       = entry( 9, buf_clients-attr.attr-value, "|")
        page-2.house-number = entry( 10, buf_clients-attr.attr-value, "|")
        page-2.house-case   = entry (11,buf_clients-attr.attr-value,"|")
        page-2.apartment    = entry (12,buf_clients-attr.attr-value,"|")
        page-2.house-litera = entry (13,buf_clients-attr.attr-value,"|") no-error.
    end.
    release page-2 .
end.
ext-cl = new extgds(yes) .
ext-FormF1 = new extFormF1(yes) .
output stream logStr to value("alc-dec-p_errors.txt") .
v-inn-err = false.
for each obj-list no-lock:
    wait-message = string("Идёт расчет остатков на конец периода по объекту " + obj-list.obj-name).
    run waitfram-show in this-procedure (input wait-message).
    for each alc-goods no-lock by alc-goods.type-code :
        run partslib-clear-temp-parts in this-procedure.
        if TOGGLE-KPP then do :
            run my-init-temp-parts-by-factord in this-procedure  (input obj-list.obj-type
                                                                       ,input obj-list.obj-code
                                                                       ,input alc-goods.artic
                                                                       ,input alc-goods.prod-type
                                                                       ,input alc-goods.prod-code
                                                                       ,input fact-order-end).
        end.
        else do :
            run partslib-init-temp-parts-by-factord in this-procedure  (input obj-list.obj-type
                                                                       ,input obj-list.obj-code
                                                                       ,input alc-goods.artic
                                                                       ,input alc-goods.prod-type
                                                                       ,input alc-goods.prod-code
                                                                       ,input fact-order-end
                                                                       ,input true).
       end.
       for each temp-parts no-lock where temp-parts.fact-qnty <> 0:
          if RADIO-SUPPLIER = 2 and
          not can-find(first alc-suppliers where alc-suppliers.obj-type = temp-parts.supp-type
                                             and alc-suppliers.obj-code = temp-parts.supp-code)
          then next.
          v-inner-code = ? .
          if num-entries(temp-parts.alc-ref-ab-path) = 4 and entry(4, temp-parts.alc-ref-ab-path) <> "" then do :
            find first alc-types no-lock where trim(alc-types.alc-type-code) = trim(entry(4, temp-parts.alc-ref-ab-path)) no-error .
            if available alc-types then v-inner-code = alc-types.type-code .
            else next .
          end.
          if v-inner-code = ? then v-inner-code = alc-goods.type-code .
           find first tt-parts-info exclusive-lock where tt-parts-info.obj-type         = obj-list.obj-type
                                                     and tt-parts-info.obj-code         = obj-list.obj-code
                                                     and tt-parts-info.artic            = alc-goods.artic
                                                     and tt-parts-info.prod-type        = alc-goods.prod-type
                                                     and tt-parts-info.prod-code        = alc-goods.prod-code
                                                     and tt-parts-info.in-code          = temp-parts.in-code
                                                     and tt-parts-info.out-code         = temp-parts.out-code
                                                     and tt-parts-info.part-code        = temp-parts.part-code no-error .
           if not available tt-parts-info then do :
               create tt-parts-info .
               assign
                tt-parts-info.obj-type         = obj-list.obj-type
                tt-parts-info.obj-code         = obj-list.obj-code
                tt-parts-info.artic            = alc-goods.artic
                tt-parts-info.prod-type        = alc-goods.prod-type
                tt-parts-info.prod-code        = alc-goods.prod-code
                tt-parts-info.in-code          = temp-parts.in-code
                tt-parts-info.out-code         = temp-parts.out-code
                tt-parts-info.part-code        = temp-parts.part-code
               .
           end.
            v-kpp = "" .
            for first buf_clients-attr no-lock where buf_clients-attr.obj-code  = obj-list.obj-code
                                               and   buf_clients-attr.obj-type  = obj-list.obj-type
                                               and   buf_clients-attr.attr-code = 'kpp':U:
                v-kpp = buf_clients-attr.attr-value.
            end.
            if v-kpp = "" then  v-kpp = v-fmtcli-kpp.
            ext-FormF1:Release_() .
            if num-entries(temp-parts.alc-ref-ab-path) = 4 and entry(1, temp-parts.alc-ref-ab-path) <> "" then do :
                ext-FormF1:OpenQueryExtFormF1(entry(1, temp-parts.alc-ref-ab-path)) .
            end.
            ext-cl:Release_() .
            if num-entries(temp-parts.alc-ref-ab-path) = 4 and entry(3, temp-parts.alc-ref-ab-path) <> "" then do :
                ext-cl:OpenQueryExtGds(alc-goods.gds-code, entry(3, temp-parts.alc-ref-ab-path)) .
                tt-parts-info.alc-code =  entry(3, temp-parts.alc-ref-ab-path) .
            end.
            if temp-parts.alc-imp-code <> 0 then assign
                    imp-or-prod-type = temp-parts.alc-imp-type
                    imp-or-prod-code = temp-parts.alc-imp-code
                    tt-parts-info.importer = 'Импортер из алк.атр. партии' .
            else
            if ext-FormF1:NumBundles > 0
            and ext-FormF1:GetExtFormF1Value():CliRegIdOrigCli <> ""
            and ext-FormF1:GetExtFormF1Value():CliRegIdOrigCli <> ?
            then do :
                imp-or-prod-type = ext-FormF1:GetExtFormF1Value():CliRegIdOrigCli .
                imp-or-prod-code = 0 .
                tt-parts-info.importer = 'ЕГАИС. Оригинальный клиент из Справки А (Справки 1)' .
            end.
            else
            if ext-cl:NumBundles > 0
            and ext-cl:GetExtGdsValue(1):CliRegIdProd <> ""
            and ext-cl:GetExtGdsValue(1):CliRegIdProd <> ?
            then do :
                if ext-cl:GetExtGdsValue(1):CliRegIdImpor <> ""
                and ext-cl:GetExtGdsValue(1):CliRegIdImpor <> ?
                then do :
                        if trim(ext-cl:GetExtGdsValue(1):CountryProd) = "643"
                        or trim(ext-cl:GetExtGdsValue(1):CountryProd) = "051"
                        or trim(ext-cl:GetExtGdsValue(1):CountryProd) = "398"
                        or trim(ext-cl:GetExtGdsValue(1):CountryProd) = "417"
                        or trim(ext-cl:GetExtGdsValue(1):CountryProd) = "112"
                        then
                        assign
                            imp-or-prod-type = ext-cl:GetExtGdsValue(1):CliRegIdProd
                            imp-or-prod-code = 0
                            tt-parts-info.importer = 'ЕГАИС. Производитель из Таможенного Союза'
                        .
                        else
                        assign
                            imp-or-prod-type = ext-cl:GetExtGdsValue(1):CliRegIdImpor
                            imp-or-prod-code = 0
                            tt-parts-info.importer = 'ЕГАИС. Импортер'
                        .
                end.
                else
                assign
                    imp-or-prod-type = ext-cl:GetExtGdsValue(1):CliRegIdProd
                    imp-or-prod-code = 0
                    tt-parts-info.importer = 'ЕГАИС. Производитель'
                .
            end.
            else assign
                    imp-or-prod-type = temp-parts.prod-type
                    imp-or-prod-code = temp-parts.prod-code
                    tt-parts-info.importer = 'Производитель из карточки товара' .
          release part-1 no-error.
          if TOGGLE-KPP then do :
              find first part-1 where part-1.type-code = v-inner-code
                                and   part-1.prod-code = imp-or-prod-code
                                and   part-1.prod-type = imp-or-prod-type
                                and   part-1.obj-kpp   = v-kpp no-error.
          end.
          else do :
              find first part-1 where part-1.type-code = v-inner-code
                                and   part-1.prod-code = imp-or-prod-code
                                and   part-1.prod-type = imp-or-prod-type
                                and   part-1.obj-code  = obj-list.obj-code
                                and   part-1.obj-type  = obj-list.obj-type no-error.
          end.
          if not available (part-1) then do:
              create part-1.
              assign
              part-1.type-code = v-inner-code
              part-1.prod-code = imp-or-prod-code
              part-1.prod-type = imp-or-prod-type
              part-1.obj-code  = obj-list.obj-code
              part-1.obj-type  = obj-list.obj-type
              part-1.obj-kpp   = v-kpp .
          for first buf_clients-attr no-lock where buf_clients-attr.obj-type  = temp-parts.prod-type
                                             and   buf_clients-attr.obj-code  = temp-parts.prod-code
                                             and   buf_clients-attr.attr-code = 'foreign-producer':U
                                             and   buf_clients-attr.attr-value = "yes":
              part-1.foreign = yes.
          end.
          if num-entries(temp-parts.alc-ref-ab-path) = 4 and entry(4, temp-parts.alc-ref-ab-path) <> "" then do :
              part-1.alc-type-code = trim(entry(4, temp-parts.alc-ref-ab-path)) .
              for first alc-types no-lock where trim(alc-types.alc-type-code) = trim(entry(4, temp-parts.alc-ref-ab-path)) :
                  part-1.alc-type-name = alc-types.alc-type-name .
              end.
          end.
          else
          for first alc-types no-lock where alc-types.type-code = alc-goods.type-code:
              assign
              part-1.alc-type-code = alc-types.alc-type-code
              part-1.alc-type-name = alc-types.alc-type-name.
          end.
          case imp-or-prod-type:
              when 'орг':U then do:
                  find first buf_firm no-lock where buf_firm.firm-code = imp-or-prod-code.
                  find first buf_clients no-lock where buf_clients.obj-code = imp-or-prod-code
                                                 and   buf_clients.obj-type = imp-or-prod-type.
                  assign
                  part-1.producer-obj-name = buf_clients.obj-name
                  part-1.producer-inn = buf_firm.inn
                  part-1.producer-kpp = buf_firm.kpp.
              end.
              when 'маг':U or when 'скл':U then do:
              find first buf_clients no-lock where buf_clients.obj-code = imp-or-prod-code
                                             and   buf_clients.obj-type = imp-or-prod-type.
              find first buf_firm no-lock where buf_firm.firm-code = buf_clients.host-code.
              release buf_clients-attr.
              find first buf_clients-attr no-lock where buf_clients-attr.obj-code  = imp-or-prod-code
                                                  and   buf_clients-attr.obj-type  = imp-or-prod-type
                                                  and   buf_clients-attr.attr-code = 'kpp':U no-error.
              assign
                  part-1.producer-obj-name = buf_clients.obj-name
                  part-1.producer-inn = buf_firm.inn
                  part-1.producer-kpp = (if buf_clients-attr.attr-value <> ""
                                        and buf_clients-attr.attr-value <> ?
                                        then buf_clients-attr.attr-value else buf_firm.kpp).
              end.
              when 'чел':U then do:
                  find first buf_person no-lock where buf_person.psn-code = imp-or-prod-code.
                  find first buf_clients no-lock where buf_clients.obj-code = imp-or-prod-code
                                                 and   buf_clients.obj-type = imp-or-prod-type.
                  assign
                  part-1.producer-obj-name = buf_clients.obj-name
                  part-1.producer-inn = buf_person.inn
                  part-1.producer-kpp = buf_person.kpp.
              end.
              otherwise do :
                    if ext-FormF1:NumBundles > 0
                    and ext-FormF1:GetExtFormF1Value():CliRegIdOrigCli <> ""
                    and ext-FormF1:GetExtFormF1Value():CliRegIdOrigCli <> ?
                    then do :
                        part-1.producer-obj-name = ext-FormF1:GetExtFormF1Value():FullNameOrigCli .
                        part-1.producer-inn = ext-FormF1:GetExtFormF1Value():INNOrigCli .
                        part-1.producer-kpp = ext-FormF1:GetExtFormF1Value():KPPOrigCli .
                    end.
                    else
                    if ext-cl:GetExtGdsValue(1):CliRegIdImpor <> ""
                    and ext-cl:GetExtGdsValue(1):CliRegIdImpor <> ?
                    then do :
                        if trim(ext-cl:GetExtGdsValue(1):CountryProd) = "643"
                        or trim(ext-cl:GetExtGdsValue(1):CountryProd) = "051"
                        or trim(ext-cl:GetExtGdsValue(1):CountryProd) = "398"
                        or trim(ext-cl:GetExtGdsValue(1):CountryProd) = "417"
                        or trim(ext-cl:GetExtGdsValue(1):CountryProd) = "112"
                        then
                        assign
                            part-1.producer-obj-name = ext-cl:GetExtGdsValue(1):FullNameProd
                            part-1.producer-inn = ext-cl:GetExtGdsValue(1):INNProd
                            part-1.producer-kpp = ext-cl:GetExtGdsValue(1):KPPProd
                        .
                        else
                        assign
                            part-1.producer-obj-name = ext-cl:GetExtGdsValue(1):FullNameImpor
                            part-1.producer-inn = ext-cl:GetExtGdsValue(1):INNImpor
                            part-1.producer-kpp = ext-cl:GetExtGdsValue(1):KPPImpor
                        .
                    end.
                    else do :
                        assign
                            part-1.producer-obj-name = ext-cl:GetExtGdsValue(1):FullNameProd
                            part-1.producer-inn = ext-cl:GetExtGdsValue(1):INNProd
                            part-1.producer-kpp = ext-cl:GetExtGdsValue(1):KPPProd
                        .
                    end.
              end.
          end case.
          if part-1.producer-inn = "" or part-1.producer-inn = ?
          or part-1.producer-kpp = "" or part-1.producer-kpp = ?
          then do :
              if part-1.producer-inn <> "" and part-1.producer-inn <> ?
              and (part-1.producer-kpp = "" or part-1.producer-kpp = ?)
              and tt-parts-info.importer = 'ЕГАИС. Производитель из Таможенного Союза'
              then do :
              end.
              else do :
                  put stream logStr unformatted 'Производитель/импортер "'  part-1.producer-obj-name
                   '" - не заполнен ИНН и/или КПП (' tt-parts-info.importer '). Артикул: ' tt-parts-info.artic ' ; партия по ПН № ' temp-parts.in-code skip .
                  v-inn-err = true .
              end.
          end.
          end.
          part-1.remain-20 = part-1.remain-20 + temp-parts.fact-qnty * alc-goods.vol / 10.
          assign
            tt-parts-info.alc-type-code     = part-1.alc-type-code
            tt-parts-info.producer-obj-name = part-1.producer-obj-name
            tt-parts-info.producer-inn      = part-1.producer-inn
            tt-parts-info.producer-kpp      = part-1.producer-kpp
          no-error .
          tt-parts-info.remain-20 = temp-parts.fact-qnty * alc-goods.vol / 10 no-error.
       end.
    end.
end.
for each obj-list no-lock:
    wait-message = string("Идёт расчет остатков на начало периода по объекту " + obj-list.obj-name).
    run waitfram-show in this-procedure (input wait-message).
    for each alc-goods no-lock by alc-goods.type-code :
        run partslib-clear-temp-parts in this-procedure.
        if TOGGLE-KPP then do :
            run my-init-temp-parts-by-factord in this-procedure  (input obj-list.obj-type
                                                                       ,input obj-list.obj-code
                                                                       ,input alc-goods.artic
                                                                       ,input alc-goods.prod-type
                                                                       ,input alc-goods.prod-code
                                                                       ,input fact-order-start).
        end.
        else do :
            run partslib-init-temp-parts-by-factord in this-procedure  (input obj-list.obj-type
                                                                       ,input obj-list.obj-code
                                                                       ,input alc-goods.artic
                                                                       ,input alc-goods.prod-type
                                                                       ,input alc-goods.prod-code
                                                                       ,input fact-order-start
                                                                       ,input true).
       end.
       for each temp-parts no-lock where temp-parts.fact-qnty <> 0:
          if RADIO-SUPPLIER = 2 and
          not can-find(first alc-suppliers where alc-suppliers.obj-type = temp-parts.supp-type
                                             and alc-suppliers.obj-code = temp-parts.supp-code)
          then next.
          v-inner-code = ? .
          if num-entries(temp-parts.alc-ref-ab-path) = 4 and entry(4, temp-parts.alc-ref-ab-path) <> "" then do :
            find first alc-types no-lock where trim(alc-types.alc-type-code) = trim(entry(4, temp-parts.alc-ref-ab-path)) no-error .
            if available alc-types then v-inner-code = alc-types.type-code .
            else next .
          end.
          if v-inner-code = ? then v-inner-code = alc-goods.type-code .
           find first tt-parts-info exclusive-lock where tt-parts-info.obj-type         = obj-list.obj-type
                                                     and tt-parts-info.obj-code         = obj-list.obj-code
                                                     and tt-parts-info.artic            = alc-goods.artic
                                                     and tt-parts-info.prod-type        = alc-goods.prod-type
                                                     and tt-parts-info.prod-code        = alc-goods.prod-code
                                                     and tt-parts-info.in-code          = temp-parts.in-code
                                                     and tt-parts-info.out-code         = temp-parts.out-code
                                                     and tt-parts-info.part-code        = temp-parts.part-code no-error .
           if not available tt-parts-info then do :
               create tt-parts-info .
               assign
                tt-parts-info.obj-type         = obj-list.obj-type
                tt-parts-info.obj-code         = obj-list.obj-code
                tt-parts-info.artic            = alc-goods.artic
                tt-parts-info.prod-type        = alc-goods.prod-type
                tt-parts-info.prod-code        = alc-goods.prod-code
                tt-parts-info.in-code          = temp-parts.in-code
                tt-parts-info.out-code         = temp-parts.out-code
                tt-parts-info.part-code        = temp-parts.part-code
               .
           end.
            v-kpp = "" .
            for first buf_clients-attr no-lock where buf_clients-attr.obj-code  = obj-list.obj-code
                                               and   buf_clients-attr.obj-type  = obj-list.obj-type
                                               and   buf_clients-attr.attr-code = 'kpp':U:
                v-kpp = buf_clients-attr.attr-value.
            end.
            if v-kpp = "" then  v-kpp = v-fmtcli-kpp.
            ext-FormF1:Release_() .
            if num-entries(temp-parts.alc-ref-ab-path) = 4 and entry(1, temp-parts.alc-ref-ab-path) <> "" then do :
                ext-FormF1:OpenQueryExtFormF1(entry(1, temp-parts.alc-ref-ab-path)) .
            end.
            ext-cl:Release_() .
            if num-entries(temp-parts.alc-ref-ab-path) = 4 and entry(3, temp-parts.alc-ref-ab-path) <> "" then do :
                ext-cl:OpenQueryExtGds(alc-goods.gds-code, entry(3, temp-parts.alc-ref-ab-path)) .
                tt-parts-info.alc-code =  entry(3, temp-parts.alc-ref-ab-path) .
            end.
            if temp-parts.alc-imp-code <> 0 then assign
                    imp-or-prod-type = temp-parts.alc-imp-type
                    imp-or-prod-code = temp-parts.alc-imp-code
                    tt-parts-info.importer = 'Импортер из алк.атр. партии' .
            else
            if ext-FormF1:NumBundles > 0
            and ext-FormF1:GetExtFormF1Value():CliRegIdOrigCli <> ""
            and ext-FormF1:GetExtFormF1Value():CliRegIdOrigCli <> ?
            then do :
                imp-or-prod-type = ext-FormF1:GetExtFormF1Value():CliRegIdOrigCli .
                imp-or-prod-code = 0 .
                tt-parts-info.importer = 'ЕГАИС. Оригинальный клиент из Справки А (Справки 1)' .
            end.
            else
            if ext-cl:NumBundles > 0
            and ext-cl:GetExtGdsValue(1):CliRegIdProd <> ""
            and ext-cl:GetExtGdsValue(1):CliRegIdProd <> ?
            then do :
                if ext-cl:GetExtGdsValue(1):CliRegIdImpor <> ""
                and ext-cl:GetExtGdsValue(1):CliRegIdImpor <> ?
                then do :
                        if trim(ext-cl:GetExtGdsValue(1):CountryProd) = "643"
                        or trim(ext-cl:GetExtGdsValue(1):CountryProd) = "051"
                        or trim(ext-cl:GetExtGdsValue(1):CountryProd) = "398"
                        or trim(ext-cl:GetExtGdsValue(1):CountryProd) = "417"
                        or trim(ext-cl:GetExtGdsValue(1):CountryProd) = "112"
                        then
                        assign
                            imp-or-prod-type = ext-cl:GetExtGdsValue(1):CliRegIdProd
                            imp-or-prod-code = 0
                            tt-parts-info.importer = 'ЕГАИС. Производитель из Таможенного Союза'
                        .
                        else
                        assign
                            imp-or-prod-type = ext-cl:GetExtGdsValue(1):CliRegIdImpor
                            imp-or-prod-code = 0
                            tt-parts-info.importer = 'ЕГАИС. Импортер'
                        .
                end.
                else
                assign
                    imp-or-prod-type = ext-cl:GetExtGdsValue(1):CliRegIdProd
                    imp-or-prod-code = 0
                    tt-parts-info.importer = 'ЕГАИС. Производитель'
                .
            end.
            else assign
                    imp-or-prod-type = temp-parts.prod-type
                    imp-or-prod-code = temp-parts.prod-code
                    tt-parts-info.importer = 'Производитель из карточки товара' .
          release part-1 no-error.
          if TOGGLE-KPP then do :
              find first part-1 where part-1.type-code = v-inner-code
                                and   part-1.prod-code = imp-or-prod-code
                                and   part-1.prod-type = imp-or-prod-type
                                and   part-1.obj-kpp   = v-kpp no-error.
          end.
          else do :
              find first part-1 where part-1.type-code = v-inner-code
                                and   part-1.prod-code = imp-or-prod-code
                                and   part-1.prod-type = imp-or-prod-type
                                and   part-1.obj-code  = obj-list.obj-code
                                and   part-1.obj-type  = obj-list.obj-type no-error.
          end.
          if not available (part-1) then do:
              create part-1.
              assign
              part-1.type-code = v-inner-code
              part-1.prod-code = imp-or-prod-code
              part-1.prod-type = imp-or-prod-type
              part-1.obj-code  = obj-list.obj-code
              part-1.obj-type  = obj-list.obj-type
              part-1.obj-kpp   = v-kpp .
          for first buf_clients-attr no-lock where buf_clients-attr.obj-type  = temp-parts.prod-type
                                             and   buf_clients-attr.obj-code  = temp-parts.prod-code
                                             and   buf_clients-attr.attr-code = 'foreign-producer':U
                                             and   buf_clients-attr.attr-value = "yes":
              part-1.foreign = yes.
          end.
          if num-entries(temp-parts.alc-ref-ab-path) = 4 and entry(4, temp-parts.alc-ref-ab-path) <> "" then do :
              part-1.alc-type-code = trim(entry(4, temp-parts.alc-ref-ab-path)) .
              for first alc-types no-lock where trim(alc-types.alc-type-code) = trim(entry(4, temp-parts.alc-ref-ab-path)) :
                  part-1.alc-type-name = alc-types.alc-type-name .
              end.
          end.
          else
          for first alc-types no-lock where alc-types.type-code = alc-goods.type-code:
              assign
              part-1.alc-type-code = alc-types.alc-type-code
              part-1.alc-type-name = alc-types.alc-type-name.
          end.
          case imp-or-prod-type:
              when 'орг':U then do:
                  find first buf_firm no-lock where buf_firm.firm-code = imp-or-prod-code.
                  find first buf_clients no-lock where buf_clients.obj-code = imp-or-prod-code
                                                 and   buf_clients.obj-type = imp-or-prod-type.
                  assign
                  part-1.producer-obj-name = buf_clients.obj-name
                  part-1.producer-inn = buf_firm.inn
                  part-1.producer-kpp = buf_firm.kpp.
              end.
              when 'маг':U or when 'скл':U then do:
              find first buf_clients no-lock where buf_clients.obj-code = imp-or-prod-code
                                             and   buf_clients.obj-type = imp-or-prod-type.
              find first buf_firm no-lock where buf_firm.firm-code = buf_clients.host-code.
              release buf_clients-attr.
              find first buf_clients-attr no-lock where buf_clients-attr.obj-code  = imp-or-prod-code
                                                  and   buf_clients-attr.obj-type  = imp-or-prod-type
                                                  and   buf_clients-attr.attr-code = 'kpp':U no-error.
              assign
                  part-1.producer-obj-name = buf_clients.obj-name
                  part-1.producer-inn = buf_firm.inn
                  part-1.producer-kpp = (if buf_clients-attr.attr-value <> ""
                                        and buf_clients-attr.attr-value <> ?
                                        then buf_clients-attr.attr-value else buf_firm.kpp).
              end.
              when 'чел':U then do:
                  find first buf_person no-lock where buf_person.psn-code = imp-or-prod-code.
                  find first buf_clients no-lock where buf_clients.obj-code = imp-or-prod-code
                                                 and   buf_clients.obj-type = imp-or-prod-type.
                  assign
                  part-1.producer-obj-name = buf_clients.obj-name
                  part-1.producer-inn = buf_person.inn
                  part-1.producer-kpp = buf_person.kpp.
              end.
              otherwise do :
                    if ext-FormF1:NumBundles > 0
                    and ext-FormF1:GetExtFormF1Value():CliRegIdOrigCli <> ""
                    and ext-FormF1:GetExtFormF1Value():CliRegIdOrigCli <> ?
                    then do :
                        part-1.producer-obj-name = ext-FormF1:GetExtFormF1Value():FullNameOrigCli .
                        part-1.producer-inn = ext-FormF1:GetExtFormF1Value():INNOrigCli .
                        part-1.producer-kpp = ext-FormF1:GetExtFormF1Value():KPPOrigCli .
                    end.
                    else
                    if ext-cl:GetExtGdsValue(1):CliRegIdImpor <> ""
                    and ext-cl:GetExtGdsValue(1):CliRegIdImpor <> ?
                    then do :
                        if trim(ext-cl:GetExtGdsValue(1):CountryProd) = "643"
                        or trim(ext-cl:GetExtGdsValue(1):CountryProd) = "051"
                        or trim(ext-cl:GetExtGdsValue(1):CountryProd) = "398"
                        or trim(ext-cl:GetExtGdsValue(1):CountryProd) = "417"
                        or trim(ext-cl:GetExtGdsValue(1):CountryProd) = "112"
                        then
                        assign
                            part-1.producer-obj-name = ext-cl:GetExtGdsValue(1):FullNameProd
                            part-1.producer-inn = ext-cl:GetExtGdsValue(1):INNProd
                            part-1.producer-kpp = ext-cl:GetExtGdsValue(1):KPPProd
                        .
                        else
                        assign
                            part-1.producer-obj-name = ext-cl:GetExtGdsValue(1):FullNameImpor
                            part-1.producer-inn = ext-cl:GetExtGdsValue(1):INNImpor
                            part-1.producer-kpp = ext-cl:GetExtGdsValue(1):KPPImpor
                        .
                    end.
                    else do :
                        assign
                            part-1.producer-obj-name = ext-cl:GetExtGdsValue(1):FullNameProd
                            part-1.producer-inn = ext-cl:GetExtGdsValue(1):INNProd
                            part-1.producer-kpp = ext-cl:GetExtGdsValue(1):KPPProd
                        .
                    end.
              end.
          end case.
          if part-1.producer-inn = "" or part-1.producer-inn = ?
          or part-1.producer-kpp = "" or part-1.producer-kpp = ?
          then do :
              if part-1.producer-inn <> "" and part-1.producer-inn <> ?
              and (part-1.producer-kpp = "" or part-1.producer-kpp = ?)
              and tt-parts-info.importer = 'ЕГАИС. Производитель из Таможенного Союза'
              then do :
              end.
              else do :
                  put stream logStr unformatted 'Производитель/импортер "'  part-1.producer-obj-name
                   '" - не заполнен ИНН и/или КПП (' tt-parts-info.importer '). Артикул: ' tt-parts-info.artic ' ; партия по ПН № ' temp-parts.in-code skip .
                  v-inn-err = true .
              end.
          end.
          end.
          part-1.remain-6 = part-1.remain-6 + temp-parts.fact-qnty * alc-goods.vol / 10.
          assign
            tt-parts-info.alc-type-code     = part-1.alc-type-code
            tt-parts-info.producer-obj-name = part-1.producer-obj-name
            tt-parts-info.producer-inn      = part-1.producer-inn
            tt-parts-info.producer-kpp      = part-1.producer-kpp
          no-error .
          tt-parts-info.remain-6 = temp-parts.fact-qnty * alc-goods.vol / 10.
       end.
    end.
end.
for each obj-list no-lock:
    wait-message = string("Идёт сбор данных по объекту " + obj-list.obj-name).
    run waitfram-show in this-procedure (input wait-message).
    for each alc-goods no-lock:
        for each buf_doc-line no-lock where buf_doc-line.obj-type     = obj-list.obj-type
                                      and   buf_doc-line.obj-code     = obj-list.obj-code
                                      and   buf_doc-line.fact-order   >= fact-order-start
                                      and   buf_doc-line.fact-order   <= fact-order-end
                                      and   buf_doc-line.status_      = 'факт':U
                                      and   buf_doc-line.artic        = alc-goods.artic
                                      and   buf_doc-line.prod-code    = alc-goods.prod-code
                                      and   buf_doc-line.prod-type    = alc-goods.prod-type
                                      and   lookup(buf_doc-line.ext-doc-type, "ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im") <> ? :
             for each buf_parts no-lock where   buf_parts.prod-type = alc-goods.prod-type
                                          and   buf_parts.prod-code = alc-goods.prod-code
                                          and   buf_parts.artic     = alc-goods.artic
                                          and   buf_parts.out-code  = buf_doc-line.doc-code:
                    if buf_parts.fact-qnty = 0
                    then next .
                    if RADIO-SUPPLIER = 2 and
                    not can-find(first alc-suppliers where alc-suppliers.obj-type = buf_parts.supp-type
                                                       and alc-suppliers.obj-code = buf_parts.supp-code)
                    then next.
                    v-inner-code = ? .
                    if num-entries(buf_parts.alc-ref-ab-path) = 4 and entry(4, buf_parts.alc-ref-ab-path) <> "" then do :
                      find first alc-types no-lock where trim(alc-types.alc-type-code) = trim(entry(4, buf_parts.alc-ref-ab-path)) no-error .
                      if available alc-types then v-inner-code = alc-types.type-code .
                      else next .
                    end.
                    if v-inner-code = ? then v-inner-code = alc-goods.type-code .
                   find first tt-parts-info exclusive-lock where tt-parts-info.obj-type         = obj-list.obj-type
                                                             and tt-parts-info.obj-code         = obj-list.obj-code
                                                             and tt-parts-info.artic            = alc-goods.artic
                                                             and tt-parts-info.prod-type        = alc-goods.prod-type
                                                             and tt-parts-info.prod-code        = alc-goods.prod-code
                                                             and tt-parts-info.in-code          = buf_parts.in-code
                                                             and tt-parts-info.out-code         = buf_parts.out-code
                                                             and tt-parts-info.part-code        = buf_parts.part-code no-error .
                   if not available tt-parts-info then do :
                       create tt-parts-info .
                       assign
                        tt-parts-info.obj-type         = obj-list.obj-type
                        tt-parts-info.obj-code         = obj-list.obj-code
                        tt-parts-info.artic            = alc-goods.artic
                        tt-parts-info.prod-type        = alc-goods.prod-type
                        tt-parts-info.prod-code        = alc-goods.prod-code
                        tt-parts-info.in-code          = buf_parts.in-code
                        tt-parts-info.out-code         = buf_parts.out-code
                        tt-parts-info.part-code        = buf_parts.part-code
                       .
                   end.
                    v-kpp = "" .
                    for first buf_clients-attr no-lock where buf_clients-attr.obj-code  = obj-list.obj-code
                                                       and   buf_clients-attr.obj-type  = obj-list.obj-type
                                                       and   buf_clients-attr.attr-code = 'kpp':U:
                        v-kpp = buf_clients-attr.attr-value.
                    end.
                    if v-kpp = "" then  v-kpp = v-fmtcli-kpp.
                    ext-FormF1:Release_() .
                    if num-entries(buf_parts.alc-ref-ab-path) = 4 and entry(1, buf_parts.alc-ref-ab-path) <> "" then do :
                        ext-FormF1:OpenQueryExtFormF1(entry(1, buf_parts.alc-ref-ab-path)) .
                    end.
                    ext-cl:Release_() .
                    if num-entries(buf_parts.alc-ref-ab-path) = 4 and entry(3, buf_parts.alc-ref-ab-path) <> "" then do :
                        ext-cl:OpenQueryExtGds(alc-goods.gds-code, entry(3, buf_parts.alc-ref-ab-path)) .
                        tt-parts-info.alc-code =  entry(3, buf_parts.alc-ref-ab-path) .
                    end.
                    if buf_parts.alc-imp-code <> 0 then assign
                            imp-or-prod-type = buf_parts.alc-imp-type
                            imp-or-prod-code = buf_parts.alc-imp-code
                            tt-parts-info.importer = 'Импортер из алк.атр. партии' .
                    else
                    if ext-FormF1:NumBundles > 0
                    and ext-FormF1:GetExtFormF1Value():CliRegIdOrigCli <> ""
                    and ext-FormF1:GetExtFormF1Value():CliRegIdOrigCli <> ?
                    then do :
                        imp-or-prod-type = ext-FormF1:GetExtFormF1Value():CliRegIdOrigCli .
                        imp-or-prod-code = 0 .
                        tt-parts-info.importer = 'ЕГАИС. Оригинальный клиент из Справки А (Справки 1)' .
                    end.
                    else
                    if ext-cl:NumBundles > 0
                    and ext-cl:GetExtGdsValue(1):CliRegIdProd <> ""
                    and ext-cl:GetExtGdsValue(1):CliRegIdProd <> ?
                    then do :
                        if ext-cl:GetExtGdsValue(1):CliRegIdImpor <> ""
                        and ext-cl:GetExtGdsValue(1):CliRegIdImpor <> ?
                        then do :
                                if trim(ext-cl:GetExtGdsValue(1):CountryProd) = "643"
                                or trim(ext-cl:GetExtGdsValue(1):CountryProd) = "051"
                                or trim(ext-cl:GetExtGdsValue(1):CountryProd) = "398"
                                or trim(ext-cl:GetExtGdsValue(1):CountryProd) = "417"
                                or trim(ext-cl:GetExtGdsValue(1):CountryProd) = "112"
                                then
                                assign
                                    imp-or-prod-type = ext-cl:GetExtGdsValue(1):CliRegIdProd
                                    imp-or-prod-code = 0
                                    tt-parts-info.importer = 'ЕГАИС. Производитель из Таможенного Союза'
                                .
                                else
                                assign
                                    imp-or-prod-type = ext-cl:GetExtGdsValue(1):CliRegIdImpor
                                    imp-or-prod-code = 0
                                    tt-parts-info.importer = 'ЕГАИС. Импортер'
                                .
                        end.
                        else
                        assign
                            imp-or-prod-type = ext-cl:GetExtGdsValue(1):CliRegIdProd
                            imp-or-prod-code = 0
                            tt-parts-info.importer = 'ЕГАИС. Производитель'
                        .
                    end.
                    else assign
                        imp-or-prod-type = buf_parts.prod-type
                        imp-or-prod-code = buf_parts.prod-code
                        tt-parts-info.importer = 'Производитель из карточки товара' .
                release part-1 no-error.
                if TOGGLE-KPP then do :
                      find first part-1 where part-1.type-code = v-inner-code
                                        and   part-1.prod-code = imp-or-prod-code
                                        and   part-1.prod-type = imp-or-prod-type
                                        and   part-1.obj-kpp   = v-kpp no-error.
                end.
                else do :
                      find first part-1 where part-1.type-code = v-inner-code
                                        and   part-1.prod-code = imp-or-prod-code
                                        and   part-1.prod-type = imp-or-prod-type
                                        and   part-1.obj-code  = obj-list.obj-code
                                        and   part-1.obj-type  = obj-list.obj-type no-error.
                end.
                if not available (part-1) then do:
                    create part-1.
                    assign
                    part-1.type-code = v-inner-code
                    part-1.prod-code = imp-or-prod-code
                    part-1.prod-type = imp-or-prod-type
                    part-1.obj-code  = obj-list.obj-code
                    part-1.obj-type  = obj-list.obj-type
                    part-1.obj-kpp   = v-kpp.
                    for first buf_clients-attr no-lock where buf_clients-attr.obj-type  = buf_parts.prod-type
                                                       and   buf_clients-attr.obj-code  = buf_parts.prod-code
                                                       and   buf_clients-attr.attr-code = 'foreign-producer':U
                                                       and   buf_clients-attr.attr-value = "yes":
                        part-1.foreign = yes.
                    end.
                    if num-entries(buf_parts.alc-ref-ab-path) = 4 and entry(4, buf_parts.alc-ref-ab-path) <> "" then do :
                        part-1.alc-type-code = trim(entry(4, buf_parts.alc-ref-ab-path)) .
                        for first alc-types no-lock where trim(alc-types.alc-type-code) = trim(entry(4, buf_parts.alc-ref-ab-path)) :
                            part-1.alc-type-name = alc-types.alc-type-name .
                        end.
                    end.
                    else
                    for first alc-types no-lock where alc-types.type-code = alc-goods.type-code:
                        assign
                        part-1.alc-type-code = alc-types.alc-type-code
                        part-1.alc-type-name = alc-types.alc-type-name.
                    end.
                    case imp-or-prod-type:
                        when 'орг':U then do:
                            find first buf_firm no-lock where buf_firm.firm-code = imp-or-prod-code.
                            find first buf_clients no-lock where buf_clients.obj-code = imp-or-prod-code
                                                           and   buf_clients.obj-type = imp-or-prod-type.
                            assign
                            part-1.producer-obj-name = buf_clients.obj-name
                            part-1.producer-inn = buf_firm.inn
                            part-1.producer-kpp = buf_firm.kpp.
                        end.
                        when 'маг':U or when 'скл':U then do:
                        find first buf_clients no-lock where buf_clients.obj-code = imp-or-prod-code
                                                       and   buf_clients.obj-type = imp-or-prod-type.
                        find first buf_firm no-lock where buf_firm.firm-code = buf_clients.host-code.
                        release buf_clients-attr.
                        find first buf_clients-attr no-lock where buf_clients-attr.obj-code  = imp-or-prod-code
                                                            and   buf_clients-attr.obj-type  = imp-or-prod-type
                                                            and   buf_clients-attr.attr-code = 'kpp':U no-error.
                        assign
                            part-1.producer-obj-name = buf_clients.obj-name
                            part-1.producer-inn = buf_firm.inn
                            part-1.producer-kpp = (if buf_clients-attr.attr-value <> ""
                                                  and buf_clients-attr.attr-value <> ?
                                                  then buf_clients-attr.attr-value else buf_firm.kpp).
                        end.
                        when 'чел':U then do:
                            find first buf_person no-lock where buf_person.psn-code = imp-or-prod-code.
                            find first buf_clients no-lock where buf_clients.obj-code = imp-or-prod-code
                                                           and   buf_clients.obj-type = imp-or-prod-type.
                            assign
                            part-1.producer-obj-name = buf_clients.obj-name
                            part-1.producer-inn = buf_person.inn
                            part-1.producer-kpp = buf_person.kpp.
                        end.
                        otherwise do :
                            if ext-FormF1:NumBundles > 0
                            and ext-FormF1:GetExtFormF1Value():CliRegIdOrigCli <> ""
                            and ext-FormF1:GetExtFormF1Value():CliRegIdOrigCli <> ?
                            then do :
                                part-1.producer-obj-name = ext-FormF1:GetExtFormF1Value():FullNameOrigCli .
                                part-1.producer-inn = ext-FormF1:GetExtFormF1Value():INNOrigCli .
                                part-1.producer-kpp = ext-FormF1:GetExtFormF1Value():KPPOrigCli .
                            end.
                            else
                            if ext-cl:GetExtGdsValue(1):CliRegIdImpor <> ""
                            and ext-cl:GetExtGdsValue(1):CliRegIdImpor <> ?
                            then do :
                                if trim(ext-cl:GetExtGdsValue(1):CountryProd) = "643"
                                or trim(ext-cl:GetExtGdsValue(1):CountryProd) = "051"
                                or trim(ext-cl:GetExtGdsValue(1):CountryProd) = "398"
                                or trim(ext-cl:GetExtGdsValue(1):CountryProd) = "417"
                                or trim(ext-cl:GetExtGdsValue(1):CountryProd) = "112"
                                then
                                assign
                                    part-1.producer-obj-name = ext-cl:GetExtGdsValue(1):FullNameProd
                                    part-1.producer-inn = ext-cl:GetExtGdsValue(1):INNProd
                                    part-1.producer-kpp = ext-cl:GetExtGdsValue(1):KPPProd
                                .
                                else
                                assign
                                    part-1.producer-obj-name = ext-cl:GetExtGdsValue(1):FullNameImpor
                                    part-1.producer-inn = ext-cl:GetExtGdsValue(1):INNImpor
                                    part-1.producer-kpp = ext-cl:GetExtGdsValue(1):KPPImpor
                                .
                            end.
                            else do :
                                assign
                                    part-1.producer-obj-name = ext-cl:GetExtGdsValue(1):FullNameProd
                                    part-1.producer-inn = ext-cl:GetExtGdsValue(1):INNProd
                                    part-1.producer-kpp = ext-cl:GetExtGdsValue(1):KPPProd
                                .
                            end.
                        end.
                    end case.
                    if part-1.producer-inn = "" or part-1.producer-inn = ?
                    or part-1.producer-kpp = "" or part-1.producer-kpp = ?
                    then do :
                        if part-1.producer-inn <> "" and part-1.producer-inn <> ?
                        and (part-1.producer-kpp = "" or part-1.producer-kpp = ?)
                        and tt-parts-info.importer = 'ЕГАИС. Производитель из Таможенного Союза'
                        then do :
                        end.
                        else do :
                            put stream logStr unformatted 'Производитель/импортер "'  part-1.producer-obj-name
                             '" - не заполнен ИНН и/или КПП (' tt-parts-info.importer '). Артикул: ' tt-parts-info.artic ' ; партия по ПН № ' buf_parts.in-code skip .
                            v-inn-err = true .
                        end.
                    end.
                end.
                assign
                    tt-parts-info.alc-type-code     = part-1.alc-type-code
                    tt-parts-info.producer-obj-name = part-1.producer-obj-name
                    tt-parts-info.producer-inn      = part-1.producer-inn
                    tt-parts-info.producer-kpp      = part-1.producer-kpp
                no-error .
                case buf_doc-line.ext-doc-type:
                    when "ie" then do:
                        if alc-goods.alpha1 <> "RU" and
                           alc-goods.alpha1 <> "AM" and
                           alc-goods.alpha1 <> "KZ" and
                           alc-goods.alpha1 <> "KG" and
                           alc-goods.alpha1 <> "BY"
                         then do:
                            if buf_parts.alc-imp-code <> 0 then assign
                                    part-1.inc-9 = part-1.inc-9 + buf_parts.fact-qnty * alc-goods.vol / 10
                                    tt-parts-info.inc-9 = buf_parts.fact-qnty * alc-goods.vol / 10 .
                            else
                            if ext-FormF1:NumBundles > 0
                            and ext-FormF1:GetExtFormF1Value():CliRegIdOrigCli <> ""
                            and ext-FormF1:GetExtFormF1Value():CliRegIdOrigCli <> ?
                            then do :
                                if ext-FormF1:GetExtFormF1Value():CliEgaisTypeOrigCli = 'FO'
                                then
                                assign
                                    part-1.inc-9 = part-1.inc-9 + buf_parts.fact-qnty * alc-goods.vol / 10
                                    tt-parts-info.inc-9 = buf_parts.fact-qnty * alc-goods.vol / 10
                                .
                                else
                                assign
                                    part-1.inc-8 = part-1.inc-8 + buf_parts.fact-qnty * alc-goods.vol / 10
                                    tt-parts-info.inc-8 = buf_parts.fact-qnty * alc-goods.vol / 10
                                .
                            end.
                            else
                            if ext-cl:NumBundles > 0
                            and ext-cl:GetExtGdsValue(1):CliRegIdProd <> ""
                            and ext-cl:GetExtGdsValue(1):CliRegIdProd <> ?
                            then do :
                                if ext-cl:GetExtGdsValue(1):CliRegIdImpor <> ""
                                and ext-cl:GetExtGdsValue(1):CliRegIdImpor <> ?
                                then do :
                                        if trim(ext-cl:GetExtGdsValue(1):CountryProd) = "643"
                                        or trim(ext-cl:GetExtGdsValue(1):CountryProd) = "051"
                                        or trim(ext-cl:GetExtGdsValue(1):CountryProd) = "398"
                                        or trim(ext-cl:GetExtGdsValue(1):CountryProd) = "417"
                                        or trim(ext-cl:GetExtGdsValue(1):CountryProd) = "112"
                                        then
                                        assign
                                            part-1.inc-8 = part-1.inc-8 + buf_parts.fact-qnty * alc-goods.vol / 10
                                            tt-parts-info.inc-8 = buf_parts.fact-qnty * alc-goods.vol / 10
                                        .
                                        else
                                        assign
                                            part-1.inc-9 = part-1.inc-9 + buf_parts.fact-qnty * alc-goods.vol / 10
                                            tt-parts-info.inc-9 = buf_parts.fact-qnty * alc-goods.vol / 10
                                        .
                                end.
                                else
                                assign
                                    part-1.inc-8 = part-1.inc-8 + buf_parts.fact-qnty * alc-goods.vol / 10
                                    tt-parts-info.inc-8 = buf_parts.fact-qnty * alc-goods.vol / 10
                                .
                            end.
                            else do:
                                if part-1.foreign = yes
                                    then assign
                                        part-1.inc-9 = part-1.inc-9 + buf_parts.fact-qnty * alc-goods.vol / 10
                                        tt-parts-info.inc-9 = buf_parts.fact-qnty * alc-goods.vol / 10 .
                                    else assign
                                        part-1.inc-8 = part-1.inc-8 + buf_parts.fact-qnty * alc-goods.vol / 10
                                        tt-parts-info.inc-8 = buf_parts.fact-qnty * alc-goods.vol / 10 .
                            end.
                        end.
                        else do:
                            for first buf_trn-doc no-lock where buf_trn-doc.doc-code = buf_parts.out-code:
                                if  buf_trn-doc.cli-code = alc-goods.prod-code
                                and buf_trn-doc.cli-type = alc-goods.prod-type
                                    then assign part-1.inc-7 = part-1.inc-7 + buf_parts.fact-qnty * alc-goods.vol / 10
                                                tt-parts-info.inc-8 = buf_parts.fact-qnty * alc-goods.vol / 10 .
                                else do:
                                    release buf_clients-attr no-error.
                                    find first buf_clients-attr no-lock where buf_clients-attr.obj-code = buf_trn-doc.cli-code
                                                                        and   buf_clients-attr.obj-type = buf_trn-doc.cli-type
                                                                        and   buf_clients-attr.attr-code = 'cli-alc-producer':U
                                                                        and   buf_clients-attr.attr-value = "yes" no-error.
                                    if available (buf_clients-attr)
                                                  then assign
                                                    part-1.inc-7 = part-1.inc-7 + buf_parts.fact-qnty * alc-goods.vol / 10
                                                    tt-parts-info.inc-7 = buf_parts.fact-qnty * alc-goods.vol / 10 .
                                                  else assign
                                                    part-1.inc-8 = part-1.inc-8 + buf_parts.fact-qnty * alc-goods.vol / 10
                                                    tt-parts-info.inc-8 = buf_parts.fact-qnty * alc-goods.vol / 10 .
                                end.
                            end.
                        end.
                    end.
                    when "ee" then do:
                        part-1.exp-16 = part-1.exp-16 + buf_parts.fact-qnty * alc-goods.vol / 10.
                        tt-parts-info.exp-16 = buf_parts.fact-qnty * alc-goods.vol / 10.
                    end.
                    when "ep" then do:
                        part-1.exp-17 = part-1.exp-17 + buf_parts.fact-qnty * alc-goods.vol / 10.
                        tt-parts-info.exp-17 = buf_parts.fact-qnty * alc-goods.vol / 10.
                    end.
                    when "es" then do:
                        part-1.exp-15 = part-1.exp-15 + buf_parts.fact-qnty * alc-goods.vol / 10.
                        tt-parts-info.exp-15 = buf_parts.fact-qnty * alc-goods.vol / 10.
                    end.
                    when "re" then do:
                        part-1.inc-11 = part-1.inc-11 + buf_parts.fact-qnty * alc-goods.vol / 10.
                        tt-parts-info.inc-11 = buf_parts.fact-qnty * alc-goods.vol / 10.
                    end.
                    when "rs" then do:
                        part-1.inc-11 = part-1.inc-11 + buf_parts.fact-qnty * alc-goods.vol / 10.
                        tt-parts-info.inc-11 = buf_parts.fact-qnty * alc-goods.vol / 10.
                    end.
                    when "we" then do:
                        part-1.exp-16 = part-1.exp-16 + buf_parts.fact-qnty * alc-goods.vol / 10.
                        tt-parts-info.exp-16 = buf_parts.fact-qnty * alc-goods.vol / 10.
                    end.
                    when "vt" then do:
                        if buf_parts.fact-qnty > 0
                            then do:
                                part-1.inc-12 = part-1.inc-12 + buf_parts.fact-qnty * alc-goods.vol / 10.
                                tt-parts-info.inc-12 = buf_parts.fact-qnty * alc-goods.vol / 10.
                            end.
                            else do:
                                part-1.exp-16 = part-1.exp-16 + absolute(buf_parts.fact-qnty) * alc-goods.vol / 10.
                                tt-parts-info.exp-16 = absolute(buf_parts.fact-qnty) * alc-goods.vol / 10.
                            end.
                    end.
                    when "vp" then do:
                        if buf_parts.fact-qnty > 0
                        then do:
                            part-1.inc-12 = part-1.inc-12 + buf_parts.fact-qnty * alc-goods.vol / 10.
                            tt-parts-info.inc-12 = buf_parts.fact-qnty * alc-goods.vol / 10.
                        end.
                        else do:
                            part-1.exp-16 = part-1.exp-16 + absolute(buf_parts.fact-qnty) * alc-goods.vol / 10.
                            tt-parts-info.exp-16 = absolute(buf_parts.fact-qnty) * alc-goods.vol / 10.
                        end.
                    end.
                    when "iv" then do:
                        if TOGGLE-KPP then do :
                            for first buf_trn-doc no-lock where buf_trn-doc.doc-code = buf_doc-line.doc-code :
                                v-kpp = "" .
                                for first buf_clients-attr no-lock where buf_clients-attr.obj-code  = buf_trn-doc.cli-code
                                                                   and   buf_clients-attr.obj-type  = buf_trn-doc.cli-type
                                                                   and   buf_clients-attr.attr-code = 'kpp':U:
                                    v-kpp = buf_clients-attr.attr-value.
                                end.
                                if v-kpp = "" then  v-kpp = v-fmtcli-kpp.
                                if v-kpp <> part-1.obj-kpp then do :
                                    part-1.inc-13 = part-1.inc-13 + buf_parts.fact-qnty * alc-goods.vol / 10.
                                    tt-parts-info.inc-13 = buf_parts.fact-qnty * alc-goods.vol / 10.
                                end.
                            end.
                        end.
                        else assign
                        part-1.inc-13 = part-1.inc-13 + buf_parts.fact-qnty * alc-goods.vol / 10
                        tt-parts-info.inc-13 = buf_parts.fact-qnty * alc-goods.vol / 10 .
                    end.
                    when "im" then do:
                        part-1.inc-12 = part-1.inc-12 + buf_parts.fact-qnty * alc-goods.vol / 10.
                        tt-parts-info.inc-12 = buf_parts.fact-qnty * alc-goods.vol / 10.
                    end.
                    when "ev" then do:
                        if TOGGLE-KPP then do :
                            for first buf_trn-doc no-lock where buf_trn-doc.doc-code = buf_doc-line.doc-code :
                                v-kpp = "" .
                                for first buf_clients-attr no-lock where buf_clients-attr.obj-code  = buf_trn-doc.cli-code
                                                                   and   buf_clients-attr.obj-type  = buf_trn-doc.cli-type
                                                                   and   buf_clients-attr.attr-code = 'kpp':U:
                                    v-kpp = buf_clients-attr.attr-value.
                                end.
                                if v-kpp = "" then  v-kpp = v-fmtcli-kpp.
                                if v-kpp <> part-1.obj-kpp then do :
                                    part-1.exp-18 = part-1.exp-18 + buf_parts.fact-qnty * alc-goods.vol / 10.
                                    tt-parts-info.exp-18 = buf_parts.fact-qnty * alc-goods.vol / 10.
                                end.
                            end.
                        end.
                        else assign
                        part-1.exp-18 = part-1.exp-18 + buf_parts.fact-qnty * alc-goods.vol / 10
                        tt-parts-info.exp-18 = buf_parts.fact-qnty * alc-goods.vol / 10 .
                    end.
                    when "rv" then do:
                        if TOGGLE-KPP then do :
                            for first buf_trn-doc no-lock where buf_trn-doc.doc-code = buf_doc-line.doc-code :
                                v-kpp = "" .
                                for first buf_clients-attr no-lock where buf_clients-attr.obj-code  = buf_trn-doc.cli-code
                                                                   and   buf_clients-attr.obj-type  = buf_trn-doc.cli-type
                                                                   and   buf_clients-attr.attr-code = 'kpp':U:
                                    v-kpp = buf_clients-attr.attr-value.
                                end.
                                if v-kpp = "" then  v-kpp = v-fmtcli-kpp.
                                if v-kpp <> part-1.obj-kpp then do :
                                    part-1.inc-13 = part-1.inc-13 + buf_parts.fact-qnty * alc-goods.vol / 10.
                                    tt-parts-info.inc-13 = buf_parts.fact-qnty * alc-goods.vol / 10 .
                                end.
                            end.
                        end.
                        else assign
                        part-1.inc-13 = part-1.inc-13 + buf_parts.fact-qnty * alc-goods.vol / 10
                        tt-parts-info.inc-13 = buf_parts.fact-qnty * alc-goods.vol / 10 .
                    end.
                    when "em" then do:
                        part-1.exp-16 = part-1.exp-16 + buf_parts.fact-qnty * alc-goods.vol / 10.
                        tt-parts-info.exp-16 = buf_parts.fact-qnty * alc-goods.vol / 10 .
                    end.
                    when "wm" then do:
                        part-1.exp-16 = part-1.exp-16 + buf_parts.fact-qnty * alc-goods.vol / 10.
                        tt-parts-info.exp-16 = buf_parts.fact-qnty * alc-goods.vol / 10 .
                    end.
                end case.
                part-1.inc-10 = part-1.inc-7  + part-1.inc-8  + part-1.inc-9.
                part-1.inc-14 = part-1.inc-10 + part-1.inc-11 + part-1.inc-12 + part-1.inc-13.
                part-1.exp-19 = part-1.exp-15 + part-1.exp-16 + part-1.exp-17 + part-1.exp-18.
                tt-parts-info.inc-10 = tt-parts-info.inc-7 + tt-parts-info.inc-8 + tt-parts-info.inc-9 .
                tt-parts-info.inc-14 = tt-parts-info.inc-10 + tt-parts-info.inc-11 + tt-parts-info.inc-12 + tt-parts-info.inc-13 .
                tt-parts-info.exp-19 = tt-parts-info.exp-15 + tt-parts-info.exp-16 + tt-parts-info.exp-17 + tt-parts-info.exp-18 .
                if buf_doc-line.ext-doc-type = "ie" then do:
                        create part-2.
                        assign
                        part-2.obj-type = part-1.obj-type
                        part-2.obj-code = part-1.obj-code
                        part-2.obj-kpp  = part-1.obj-kpp
                        part-2.prod-code = part-1.prod-code
                        part-2.prod-type = part-1.prod-type
                        part-2.alc-type-name = part-1.alc-type-name
                        part-2.alc-type-code = part-1.alc-type-code
                        part-2.producer-obj-name = part-1.producer-obj-name
                        part-2.producer-inn = part-1.producer-inn
                        part-2.producer-kpp = part-1.producer-kpp
                        part-2.GTD = buf_parts.cst-code
                        part-2.total = buf_parts.fact-qnty * alc-goods.vol / 10.
                    for first buf_trn-doc no-lock where buf_trn-doc.doc-code = buf_doc-line.doc-code:
                        run gbl/trdcat-v.p (input buf_trn-doc.doc-code
                                           ,input 'Shipper':U
                                           ,output v-attr-val
                                           ,output v-attr-type
                                           ) no-error.
                        if v-attr-val <> "" then do:
                            part-2.supplier-code = integer(substring(v-attr-val, 4)).
                            part-2.supplier-type = substring(v-attr-val, 1, 3).
                            for first buf_clients where buf_clients.obj-type = part-2.supplier-type
                                                    and buf_clients.obj-code = part-2.supplier-code no-lock:
                                part-2.supplier-obj-name = buf_clients.obj-name.
                            end.
                        end.
                        else do:
                            assign
                            part-2.supplier-code = buf_trn-doc.cli-code
                            part-2.supplier-type = buf_trn-doc.cli-type
                            part-2.supplier-obj-name = buf_trn-doc.cli-name.
                        end.
                            case buf_trn-doc.cli-type:
                            when 'орг':U then do:
                                find first buf_firm no-lock where buf_firm.firm-code = part-2.supplier-code.
                                assign
                                part-2.supplier-inn = buf_firm.inn
                                part-2.supplier-kpp = buf_firm.kpp.
                            end.
                            when 'маг':U or when 'скл':U then do:
                            find first buf_clients no-lock where buf_clients.obj-code = part-2.supplier-code
                                                           and   buf_clients.obj-type = part-2.supplier-type.
                            find first buf_firm no-lock where buf_firm.firm-code = buf_clients.host-code.
                            release buf_clients-attr.
                            find first buf_clients-attr no-lock where buf_clients-attr.obj-code  = part-2.supplier-code
                                                                and   buf_clients-attr.obj-type  = part-2.supplier-type
                                                                and   buf_clients-attr.attr-code = 'kpp':U no-error.
                            assign
                                part-2.supplier-inn = buf_firm.inn
                                part-2.supplier-kpp = (if buf_clients-attr.attr-value <> ""
                                                      and buf_clients-attr.attr-value <> ?
                                                      then buf_clients-attr.attr-value else buf_firm.kpp).
                            end.
                            when 'чел':U then do:
                                find first buf_person  no-lock where buf_person.psn-code = part-2.supplier-code.
                                find first buf_clients no-lock where buf_clients.obj-code = part-2.supplier-code
                                                               and   buf_clients.obj-type = part-2.supplier-type.
                                assign
                                part-2.supplier-obj-name = buf_clients.obj-name
                                part-2.supplier-inn = buf_person.inn
                                part-2.supplier-kpp = buf_person.kpp.
                            end.
                        end case.
                        for first buf_alc-supp-lic no-lock where buf_alc-supp-lic.cli-type = part-2.supplier-type
                                                           and   buf_alc-supp-lic.cli-code = part-2.supplier-code
                                                           and   buf_alc-supp-lic.date-from <= buf_trn-doc.fact-date
                                                           and   buf_alc-supp-lic.date-to   >= buf_trn-doc.fact-date:
                            assign
                            part-2.supplier-serial-number = buf_alc-supp-lic.seria + " " +  buf_alc-supp-lic.number
                            part-2.supplier-date-get = string(buf_alc-supp-lic.date-get, "99.99.9999")
                            part-2.supplier-date-to = string(buf_alc-supp-lic.date-to, "99.99.9999")
                            part-2.supplier-get-from = buf_alc-supp-lic.who-are-got.
                        end.
                        run gbl/trdcat-v.p   ( input buf_trn-doc.doc-code
                           , input 'dids':U
                           , output v-attr-val
                           , output v-attr-type
                           ) no-error.
                           part-2.purchase-date = (if v-attr-val <> "" then date(v-attr-val) else buf_trn-doc.fact-date).
                        run gbl/trdcat-v.p   ( input buf_trn-doc.doc-code
                           , input 'nids':U
                           , output v-attr-val
                           , output v-attr-type
                           ) no-error.
                           part-2.TTN = (if v-attr-val <> "" then v-attr-val else "Не определено").
                    end.
                end.
            end.
        end.
    end.
end.
delete object ext-cl no-error .
delete object ext-FormF1 no-error .
output stream logStr close .
define buffer buf_part-1 for part-1 .
for each part-1 exclusive-lock where part-1.producer-inn <> "" :
    if TOGGLE-KPP then do :
        find first buf_part-1 exclusive-lock where buf_part-1.alc-type-code = part-1.alc-type-code
                                               and buf_part-1.producer-inn  = part-1.producer-inn
                                               and buf_part-1.producer-kpp  = part-1.producer-kpp
                                               and buf_part-1.obj-kpp       = part-1.obj-kpp
                                               and rowid(buf_part-1) <> rowid(part-1) no-error.
    end.
    else do :
        find first buf_part-1 exclusive-lock where buf_part-1.alc-type-code = part-1.alc-type-code
                                               and buf_part-1.producer-inn  = part-1.producer-inn
                                               and buf_part-1.producer-kpp  = part-1.producer-kpp
                                               and buf_part-1.obj-type      = part-1.obj-type
                                               and buf_part-1.obj-code      = part-1.obj-code
                                               and rowid(buf_part-1) <> rowid(part-1) no-error.
    end.
    if available buf_part-1 then do :
        if part-1.prod-code = 0 then do :
            assign
                buf_part-1.inc-7  = buf_part-1.inc-7  + part-1.inc-7
                buf_part-1.inc-8  = buf_part-1.inc-8  + part-1.inc-8
                buf_part-1.inc-9  = buf_part-1.inc-9  + part-1.inc-9
                buf_part-1.inc-10 = buf_part-1.inc-10 + part-1.inc-10
                buf_part-1.inc-11 = buf_part-1.inc-11 + part-1.inc-11
                buf_part-1.inc-12 = buf_part-1.inc-12 + part-1.inc-12
                buf_part-1.inc-13 = buf_part-1.inc-13 + part-1.inc-13
                buf_part-1.inc-14 = buf_part-1.inc-14 + part-1.inc-14
                buf_part-1.exp-15 = buf_part-1.exp-15 + part-1.exp-15
                buf_part-1.exp-16 = buf_part-1.exp-16 + part-1.exp-16
                buf_part-1.exp-17 = buf_part-1.exp-17 + part-1.exp-17
                buf_part-1.exp-18 = buf_part-1.exp-18 + part-1.exp-18
                buf_part-1.exp-19 = buf_part-1.exp-19 + part-1.exp-19
                buf_part-1.remain-6 = buf_part-1.remain-6 + part-1.remain-6
                buf_part-1.remain-20 = buf_part-1.remain-20 + part-1.remain-20
            .
            delete part-1.
            next.
        end.
        if buf_part-1.prod-code = 0 then do :
            assign
                part-1.inc-7  = part-1.inc-7  + buf_part-1.inc-7
                part-1.inc-8  = part-1.inc-8  + buf_part-1.inc-8
                part-1.inc-9  = part-1.inc-9  + buf_part-1.inc-9
                part-1.inc-10 = part-1.inc-10 + buf_part-1.inc-10
                part-1.inc-11 = part-1.inc-11 + buf_part-1.inc-11
                part-1.inc-12 = part-1.inc-12 + buf_part-1.inc-12
                part-1.inc-13 = part-1.inc-13 + buf_part-1.inc-13
                part-1.inc-14 = part-1.inc-14 + buf_part-1.inc-14
                part-1.exp-15 = part-1.exp-15 + buf_part-1.exp-15
                part-1.exp-16 = part-1.exp-16 + buf_part-1.exp-16
                part-1.exp-17 = part-1.exp-17 + buf_part-1.exp-17
                part-1.exp-18 = part-1.exp-18 + buf_part-1.exp-18
                part-1.exp-19 = part-1.exp-19 + buf_part-1.exp-19
                part-1.remain-6 = part-1.remain-6 + buf_part-1.remain-6
                part-1.remain-20 = part-1.remain-20 + buf_part-1.remain-20
            .
            delete buf_part-1.
            next.
        end.
    end.
end.
for each part-2 exclusive-lock :
    if TOGGLE-KPP then do :
        find first buf_part-2 exclusive-lock where buf_part-2.alc-type-code = part-2.alc-type-code
                                               and buf_part-2.producer-inn  = part-2.producer-inn
                                               and buf_part-2.producer-kpp  = part-2.producer-kpp
                                               and buf_part-2.obj-kpp       = part-2.obj-kpp
                                               and buf_part-2.TTN           = part-2.TTN
                                               and buf_part-2.supplier-type = part-2.supplier-type
                                               and buf_part-2.supplier-code = part-2.supplier-code
                                               and rowid(buf_part-2) <> rowid(part-2) no-error.
    end.
    else do :
        find first buf_part-2 exclusive-lock where buf_part-2.alc-type-code = part-2.alc-type-code
                                               and buf_part-2.producer-inn  = part-2.producer-inn
                                               and buf_part-2.producer-kpp  = part-2.producer-kpp
                                               and buf_part-2.obj-type      = part-2.obj-type
                                               and buf_part-2.obj-code      = part-2.obj-code
                                               and buf_part-2.TTN           = part-2.TTN
                                               and buf_part-2.supplier-type = part-2.supplier-type
                                               and buf_part-2.supplier-code = part-2.supplier-code
                                               and rowid(buf_part-2) <> rowid(part-2) no-error.
    end.
    if available buf_part-2 then do :
        if part-2.prod-code = 0 then do :
            assign
                buf_part-2.total = buf_part-2.total + part-2.total
            .
            delete part-2.
            next.
        end.
        if buf_part-2.prod-code = 0 then do :
            assign
                part-2.total = part-2.total + buf_part-2.total
            .
            delete buf_part-2.
            next.
        end.
    end.
end.
define variable new-prod-code as integer no-undo .
assign new-prod-code = 1 .
for each part-1 exclusive-lock where part-1.prod-code = 0 break by part-1.prod-type :
    for each part-2 exclusive-lock where part-2.alc-type-code = part-1.alc-type-code
                                     and part-2.prod-code = part-1.prod-code
                                     and part-2.prod-type = part-1.prod-type
                                     and part-2.obj-code  = part-1.obj-code
                                     and part-2.obj-type  = part-1.obj-type :
        assign part-2.prod-code = 10000 + new-prod-code .
    end.
    assign part-1.prod-code = 10000 + new-prod-code .
    if last-of(part-1.prod-type) then assign new-prod-code = new-prod-code + 1 .
end.
wait-message = string("Идёт формирование отчета").
run waitfram-show in this-procedure (input wait-message).
run print-info .
if TOGGLE-Excel = yes then run excel-output.
if TOGGLE-XML = yes then run xml-output.
run waitfram-hide.
if v-inn-err
then do :
    define variable v-user-action    as character no-undo.
    define variable v-printed        as logical   no-undo.
    message "Есть замечания по формированию декларации" view-as alert-box.
    run gbl/prnfilen.w
       (input  "Ошибки алкогольной декларации"
       ,input  0
       ,input  "alc-dec-p_errors.txt"
       ,input  7
       ,output v-user-action
       ,output v-printed
       ).
end.
apply "go".
END PROCEDURE.
procedure print-info :
    define var v-act-file as char no-undo.
    v-act-file  = session:temp-directory + "rpt" +  "alc-dec_parts-info_beer.html".
    output stream OutStr-html to value(v-act-file) convert target 'UTF-8'.
    put stream OutStr-html unformatted
        substitute(
        '<!doctype html>
                 <html>
              <head>
              <meta charset="UTF-8">
                 <!-- Стили документа -->
              <style>
                table ~{border-collapse: collapse; ~}
                tbody td, th ~{border: 1px solid black;~}
                #myid ~{font-weight: bold;~}
                .class1 ~{font-style: italic;~}
                .class2 ~{font-family: Arial;~}
              </style>
              </head>
                  <body>
                  <table orientation="landscape" name="лист1" repeat_rows="1:1" hide_zero="True">
                  <thead>
                  <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                  <tr class="set_columns">
                        <td style="width:40px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                        <td style="width:80px"></td>
                        <td style="width:80px"></td>
                        <td style="width:80px"></td>
                        <td style="width:80px"></td>
                        <td style="width:120px"></td>
                        <td style="width:180px"></td>
                        <td style="width:80px"></td>
                        <td style="width:80px"></td>
                        <td style="width:120px"></td>
                        <td style="width:90px"></td>
                        <td style="width:90px"></td>
                        <td style="width:90px"></td>
                        <td style="width:90px"></td>
                        <td style="width:90px"></td>
                        <td style="width:90px"></td>
                        <td style="width:90px"></td>
                        <td style="width:90px"></td>
                        <td style="width:90px"></td>
                        <td style="width:90px"></td>
                        <td style="width:90px"></td>
                        <td style="width:90px"></td>
                        <td style="width:90px"></td>
                  </tr>
                  <tr>
                        <td colspan="25" style="front-weight: bold; text-align: center;">Информация по партиям для алкогольной декларации</td>
                  </tr>
        </thead>
            <tbody>
                <tr>
                <th>Код объекта</th>
                <th>Тип объекта</th>
                <th>Код АП</th>
                <th>Номер приходного документа (in-code)</th>
                <th>Номер документа (out-code)</th>
                <th>Номер партии (part-code)</th>
                <th>Артикул</th>
                <th>Алк. Код</th>
                <th>Имя произв.</th>
                <th>ИНН произв.</th>
                <th>КПП произв.</th>
                <th>Откуда</th>
                <th>6</th>
                <th>7</th>
                <th>8</th>
                <th>9</th>
                <th>10</th>
                <th>11</th>
                <th>12</th>
                <th>13</th>
                <th>14</th>
                <th>15</th>
                <th>16</th>
                <th>17</th>
                <th>18</th>
                </tr>').
    for each tt-parts-info break by tt-parts-info.obj-type by tt-parts-info.obj-code by tt-parts-info.alc-type-code :
        put stream OutStr-html unformatted
            '<tr style="height: 50px;">' skip
             '<td text_wrap="true">' + string(tt-parts-info.obj-type) + '</td>' skip
             '<td text_wrap="true">' + string(tt-parts-info.obj-code) + '</td>' skip
             '<td text_wrap="true">' + string(tt-parts-info.alc-type-code) + '</td>' skip
             '<td text_wrap="true">' + string(tt-parts-info.in-code) + '</td>' skip
             '<td text_wrap="true">' + string(tt-parts-info.out-code) + '</td>' skip
             '<td text_wrap="true">' + string(tt-parts-info.part-code) + '</td>' skip
             '<td text_wrap="true">' + string(tt-parts-info.artic) + '</td>' skip
             '<td text_wrap="true">' + string(tt-parts-info.alc-code) + '</td>' skip
             '<td text_wrap="true">' + string(tt-parts-info.producer-obj-name) + '</td>' skip
             '<td text_wrap="true">' + string(tt-parts-info.producer-inn) + '</td>' skip
             '<td text_wrap="true">' + string(tt-parts-info.producer-kpp) + '</td>' skip
             '<td text_wrap="true">' + string(tt-parts-info.importer) + '</td>' skip
             '<td text_wrap="true">' + string(tt-parts-info.remain-6) + '</td>' skip
             '<td text_wrap="true">' + string(tt-parts-info.inc-7) + '</td>' skip
             '<td text_wrap="true">' + string(tt-parts-info.inc-8) + '</td>' skip
             '<td text_wrap="true">' + string(tt-parts-info.inc-9) + '</td>' skip
             '<td text_wrap="true">' + string(tt-parts-info.inc-10) + '</td>' skip
             '<td text_wrap="true">' + string(tt-parts-info.inc-11) + '</td>' skip
             '<td text_wrap="true">' + string(decimal(tt-parts-info.inc-12) + decimal(tt-parts-info.inc-13)) + '</td>' skip
             '<td text_wrap="true">' + string(tt-parts-info.inc-14) + '</td>' skip
             '<td text_wrap="true">' + string(tt-parts-info.exp-15) + '</td>' skip
             '<td text_wrap="true">' + string(decimal(tt-parts-info.exp-16) + decimal(tt-parts-info.exp-18)) + '</td>' skip
             '<td text_wrap="true">' + string(tt-parts-info.exp-17) + '</td>' skip
             '<td text_wrap="true">' + string(tt-parts-info.exp-19) + '</td>' skip
             '<td text_wrap="true">' + string(tt-parts-info.remain-20) + '</td>' skip
             '</tr>' skip
             '</tbody>' skip
          .
    end.
    output stream OutStr-html close.
end.
PROCEDURE excel-output :
define variable hSAXWriter as handle no-undo.
define variable xml_tmp as character no-undo.
define variable xslt as character no-undo.
define variable nn as integer no-undo.
define variable Report-out as class Rep-Out no-undo.
xml_tmp = session:temp-directory + "alc-decl-tmp.xml".
create sax-writer hSAXWriter.
hSAXWriter:formatted = true.
hSAXWriter:encoding = "utf-8":U.
hSAXWriter:set-output-destination("file":U, xml_tmp).
hSAXWriter:start-document().
hSAXWriter:start-element ("report").
hSAXWriter:start-element ("page-1").
    hSAXWriter:write-data-element ("inn",v-fmtcli-inn).
    hSAXWriter:write-data-element ("kpp",v-fmtcli-kpp).
    hSAXWriter:write-data-element ("quarter",string(quarter)).
    if quarter <> 1 then hSAXWriter:write-data-element ("year",string(year(x-date-start))).
    hSAXWriter:write-data-element ("name",v-fmtcli-name).
    hSAXWriter:write-data-element ("post-code",firm-post-code).
    hSAXWriter:write-data-element ("region",firm-reg-code).
    hSAXWriter:write-data-element ("district",firm-district).
    hSAXWriter:write-data-element ("city", if firm-city <> "" then firm-city else firm-settlement).
    hSAXWriter:write-data-element ("street",firm-street).
    hSAXWriter:write-data-element ("house",if firm-house-number <> "" then "д. " + firm-house-number + firm-house-litera else ""
                                          + if firm-house-case <> "" then " кор. " + firm-house-case  else ""
                                          + if firm-house-apartment <> "" then " кв. " + firm-house-apartment else "").
    hSAXWriter:write-data-element ("phone",v-fmtcli-phone).
    hSAXWriter:write-data-element ("e-mail",firm-e-mail).
    hSAXWriter:write-data-element ("director",firm-director-f + " " + firm-director-i + " " + firm-director-o).
    hSAXWriter:write-data-element ("accountant",firm-accountant-f + " " + firm-accountant-i + " " + firm-accountant-o).
    hSAXWriter:write-data-element ("date",string(day(today), "99") + string(month(today), "99") + string(year(today), "9999")).
hSAXWriter:end-element ("page-1").
hSAXWriter:start-element ("page-2").
    hSAXWriter:insert-attribute ("inn",v-fmtcli-inn).
    hSAXWriter:insert-attribute ("kpp",v-fmtcli-kpp).
    for each page-2 no-lock:
        hSAXWriter:start-element ("objects").
            hSAXWriter:write-data-element("o1", page-2.kpp).
            hSAXWriter:write-data-element("o2", page-2.post-code).
            hSAXWriter:write-data-element("o3", page-2.reg-code).
            hSAXWriter:write-data-element("o4", page-2.district).
            hSAXWriter:write-data-element("o5", if page-2.city <> "" then page-2.city else page-2.settlement ).
            hSAXWriter:write-data-element("o6", page-2.street).
            hSAXWriter:write-data-element("o7", if page-2.house-number <> "" then "д. " + page-2.house-number + page-2.house-litera else ""
                                                + if page-2.house-case <> "" then " кор. " + page-2.house-case  else ""
                                                + if page-2.apartment <> "" then " кв. " + page-2.apartment else "").
        hSAXWriter:end-element ("objects").
    end.
hSAXWriter:end-element ("page-2").
hSAXWriter:start-element ("part-1").
hSAXWriter:start-element ("firm").
    nn = 1.
    hSAXWriter:write-data-element("header", v-fmtcli-name).
for each part-1 no-lock break by part-1.alc-type-code:
    accumulate part-1.remain-6  (total).
    accumulate part-1.inc-7     (total).
    accumulate part-1.inc-8     (total).
    accumulate part-1.inc-9     (total).
    accumulate part-1.inc-10    (total).
    accumulate part-1.inc-11    (total).
    accumulate part-1.inc-12    (total).
    accumulate part-1.inc-13    (total).
    accumulate part-1.inc-14    (total).
    accumulate part-1.exp-15    (total).
    accumulate part-1.exp-16    (total).
    accumulate part-1.exp-17    (total).
    accumulate part-1.exp-18    (total).
    accumulate part-1.exp-19    (total).
    accumulate part-1.remain-20 (total).
    accumulate part-1.remain-6  (total by part-1.alc-type-code).
    accumulate part-1.inc-7     (total by part-1.alc-type-code).
    accumulate part-1.inc-8     (total by part-1.alc-type-code).
    accumulate part-1.inc-9     (total by part-1.alc-type-code).
    accumulate part-1.inc-10    (total by part-1.alc-type-code).
    accumulate part-1.inc-11    (total by part-1.alc-type-code).
    accumulate part-1.inc-12    (total by part-1.alc-type-code).
    accumulate part-1.inc-13    (total by part-1.alc-type-code).
    accumulate part-1.inc-14    (total by part-1.alc-type-code).
    accumulate part-1.exp-15    (total by part-1.alc-type-code).
    accumulate part-1.exp-16    (total by part-1.alc-type-code).
    accumulate part-1.exp-17    (total by part-1.alc-type-code).
    accumulate part-1.exp-18    (total by part-1.alc-type-code).
    accumulate part-1.exp-19    (total by part-1.alc-type-code).
    accumulate part-1.remain-20 (total by part-1.alc-type-code).
    if last-of (part-1.alc-type-code) then do:
      hSAXWriter:start-element ("row").
        nn = nn + 1.
        hSAXWriter:write-data-element("n", string(nn)).
        hSAXWriter:write-data-element("c01" ,part-1.alc-type-name).
        hSAXWriter:write-data-element("c02" ,part-1.alc-type-code).
        hSAXWriter:write-data-element("c03" ,"").
        hSAXWriter:write-data-element("c04" ,"").
        hSAXWriter:write-data-element("c05" ,"").
        hSAXWriter:write-data-element("c06" ,string(accum total by part-1.alc-type-code part-1.remain-6 )).
        hSAXWriter:write-data-element("c07" ,string(accum total by part-1.alc-type-code part-1.inc-7    )).
        hSAXWriter:write-data-element("c08" ,string(accum total by part-1.alc-type-code part-1.inc-8    )).
        hSAXWriter:write-data-element("c09" ,string(accum total by part-1.alc-type-code part-1.inc-9    )).
        hSAXWriter:write-data-element("c10" ,string(accum total by part-1.alc-type-code part-1.inc-10   )).
        hSAXWriter:write-data-element("c11" ,string(accum total by part-1.alc-type-code part-1.inc-11   )).
        hSAXWriter:write-data-element("c12" ,string( decimal(accum total by part-1.alc-type-code part-1.inc-12)
                                                   + decimal(accum total by part-1.alc-type-code part-1.inc-13) )).
        hSAXWriter:write-data-element("c13" ,string(accum total by part-1.alc-type-code part-1.inc-14   )).
        hSAXWriter:write-data-element("c14" ,string(accum total by part-1.alc-type-code part-1.exp-15   )).
        hSAXWriter:write-data-element("c15" ,string(decimal(accum total by part-1.alc-type-code part-1.exp-16)
                                                  + decimal(accum total by part-1.alc-type-code part-1.exp-18) )).
        hSAXWriter:write-data-element("c16" ,string(accum total by part-1.alc-type-code part-1.exp-17   )).
        hSAXWriter:write-data-element("c17" ,string(accum total by part-1.alc-type-code part-1.exp-19   )).
        hSAXWriter:write-data-element("c18" ,string(accum total by part-1.alc-type-code part-1.remain-20)).
      hSAXWriter:end-element ("row").
    end.
end.
      hSAXWriter:start-element ("row").
        nn = nn + 1.
        hSAXWriter:write-data-element("n", string(nn)).
        hSAXWriter:write-data-element("c01" ,"ИТОГО").
        hSAXWriter:write-data-element("c02" ,"").
        hSAXWriter:write-data-element("c03" ,"").
        hSAXWriter:write-data-element("c04" ,"").
        hSAXWriter:write-data-element("c05" ,"").
        hSAXWriter:write-data-element("c06" ,string(accum total part-1.remain-6 )).
        hSAXWriter:write-data-element("c07" ,string(accum total part-1.inc-7    )).
        hSAXWriter:write-data-element("c08" ,string(accum total part-1.inc-8    )).
        hSAXWriter:write-data-element("c09" ,string(accum total part-1.inc-9    )).
        hSAXWriter:write-data-element("c10" ,string(accum total part-1.inc-10   )).
        hSAXWriter:write-data-element("c11" ,string(accum total part-1.inc-11   )).
        hSAXWriter:write-data-element("c12" ,string(decimal(accum total part-1.inc-12)
                                                  + decimal(accum total part-1.inc-13) )).
        hSAXWriter:write-data-element("c13" ,string(accum total part-1.inc-14   )).
        hSAXWriter:write-data-element("c14" ,string(decimal(accum total part-1.exp-16)
                                                  + decimal(accum total part-1.exp-18) )).
        hSAXWriter:write-data-element("c15" ,string(accum total part-1.exp-16   )).
        hSAXWriter:write-data-element("c16" ,string(accum total part-1.exp-17   )).
        hSAXWriter:write-data-element("c17" ,string(accum total part-1.exp-19   )).
        hSAXWriter:write-data-element("c18" ,string(accum total part-1.remain-20)).
      hSAXWriter:end-element ("row").
hSAXWriter:end-element ("firm").
for each part-1 no-lock break by part-1.obj-type by part-1.obj-code by part-1.alc-type-code:
    if first-of (part-1.obj-code) then do:
        hSAXWriter:start-element ("object").
        find first buf_clients where buf_clients.obj-code = part-1.obj-code
                                and buf_clients.obj-type = part-1.obj-type.
        nn = nn + 1.
        hSAXWriter:write-data-element("n", string(nn)).
        hSAXWriter:write-data-element("header", buf_clients.obj-name).
    end.
    accumulate part-1.remain-6  (total by part-1.obj-code).
    accumulate part-1.inc-7     (total by part-1.obj-code).
    accumulate part-1.inc-8     (total by part-1.obj-code).
    accumulate part-1.inc-9     (total by part-1.obj-code).
    accumulate part-1.inc-10    (total by part-1.obj-code).
    accumulate part-1.inc-11    (total by part-1.obj-code).
    accumulate part-1.inc-12    (total by part-1.obj-code).
    accumulate part-1.inc-13    (total by part-1.obj-code).
    accumulate part-1.inc-14    (total by part-1.obj-code).
    accumulate part-1.exp-15    (total by part-1.obj-code).
    accumulate part-1.exp-16    (total by part-1.obj-code).
    accumulate part-1.exp-17    (total by part-1.obj-code).
    accumulate part-1.exp-18    (total by part-1.obj-code).
    accumulate part-1.exp-19    (total by part-1.obj-code).
    accumulate part-1.remain-20 (total by part-1.obj-code).
    hSAXWriter:start-element ("row").
        nn = nn + 1.
        hSAXWriter:write-data-element("n", string(nn)).
        hSAXWriter:write-data-element("c01" , part-1.alc-type-name).
        hSAXWriter:write-data-element("c02" ,string(part-1.alc-type-code)).
        hSAXWriter:write-data-element("c03" ,part-1.producer-obj-name).
        hSAXWriter:write-data-element("c04" ,part-1.producer-inn).
        hSAXWriter:write-data-element("c05" ,part-1.producer-kpp).
        hSAXWriter:write-data-element("c06" ,string(part-1.remain-6)).
        hSAXWriter:write-data-element("c07" ,string(part-1.inc-7)).
        hSAXWriter:write-data-element("c08" ,string(part-1.inc-8)).
        hSAXWriter:write-data-element("c09" ,string(part-1.inc-9)).
        hSAXWriter:write-data-element("c10" ,string(part-1.inc-10)).
        hSAXWriter:write-data-element("c11" ,string(part-1.inc-11)).
        hSAXWriter:write-data-element("c12" ,string(decimal(part-1.inc-12) + decimal(part-1.inc-13) )).
        hSAXWriter:write-data-element("c13" ,string(part-1.inc-14)).
        hSAXWriter:write-data-element("c14" ,string(part-1.exp-15)).
        hSAXWriter:write-data-element("c15" ,string(decimal(part-1.exp-16) + decimal(part-1.exp-18) )).
        hSAXWriter:write-data-element("c16" ,string(part-1.exp-17)).
        hSAXWriter:write-data-element("c17" ,string(part-1.exp-19)).
        hSAXWriter:write-data-element("c18" ,string(part-1.remain-20)).
    hSAXWriter:end-element ("row").
    if last-of (part-1.obj-code) then do:
        hSAXWriter:start-element ("row").
            nn = nn + 1.
            hSAXWriter:write-data-element("n", string(nn)).
            hSAXWriter:write-data-element("c01" ,"ИТОГО").
            hSAXWriter:write-data-element("c02" ,"").
            hSAXWriter:write-data-element("c03" ,"").
            hSAXWriter:write-data-element("c04" ,"").
            hSAXWriter:write-data-element("c05" ,"").
            hSAXWriter:write-data-element("c06" ,string(accum total by part-1.obj-code part-1.remain-6 )).
            hSAXWriter:write-data-element("c07" ,string(accum total by part-1.obj-code part-1.inc-7    )).
            hSAXWriter:write-data-element("c08" ,string(accum total by part-1.obj-code part-1.inc-8    )).
            hSAXWriter:write-data-element("c09" ,string(accum total by part-1.obj-code part-1.inc-9    )).
            hSAXWriter:write-data-element("c10" ,string(accum total by part-1.obj-code part-1.inc-10   )).
            hSAXWriter:write-data-element("c11" ,string(accum total by part-1.obj-code part-1.inc-11   )).
            hSAXWriter:write-data-element("c12" ,string(decimal (accum total by part-1.obj-code part-1.inc-12)
                                                      + decimal (accum total by part-1.obj-code part-1.inc-13) )).
            hSAXWriter:write-data-element("c13" ,string(accum total by part-1.obj-code part-1.inc-14   )).
            hSAXWriter:write-data-element("c14" ,string(accum total by part-1.obj-code part-1.exp-15   )).
            hSAXWriter:write-data-element("c15" ,string(decimal (accum total by part-1.obj-code part-1.exp-16)
                                                      + decimal (accum total by part-1.obj-code part-1.exp-18) )).
            hSAXWriter:write-data-element("c16" ,string(accum total by part-1.obj-code part-1.exp-17   )).
            hSAXWriter:write-data-element("c17" ,string(accum total by part-1.obj-code part-1.exp-19   )).
            hSAXWriter:write-data-element("c18" ,string(accum total by part-1.obj-code part-1.remain-20)).
        hSAXWriter:end-element ("row").
       hSAXWriter:end-element ("object").
    end.
end.
hSAXWriter:end-element ("part-1").
hSAXWriter:start-element ("part-2").
hSAXWriter:start-element ("firm").
    nn = 1.
    hSAXWriter:write-data-element ("header", v-fmtcli-name ).
for each part-2 no-lock break by part-2.alc-type-code:
    accumulate part-2.total (total).
    accumulate part-2.total (total by part-2.alc-type-code).
    if last-of (part-2.alc-type-code) then do:
      hSAXWriter:start-element ("row").
        nn = nn + 1.
        hSAXWriter:write-data-element ("n", string(nn)).
        hSAXWriter:write-data-element("c01" ,part-2.alc-type-name).
        hSAXWriter:write-data-element("c02" ,part-2.alc-type-code).
        hSAXWriter:write-data-element("c03" ,"").
        hSAXWriter:write-data-element("c04" ,"").
        hSAXWriter:write-data-element("c05" ,"").
        hSAXWriter:write-data-element("c06" ,"").
        hSAXWriter:write-data-element("c07" ,"").
        hSAXWriter:write-data-element("c08" ,"").
        hSAXWriter:write-data-element("c09" ,"").
        hSAXWriter:write-data-element("c10" ,"").
        hSAXWriter:write-data-element("c11" ,"").
        hSAXWriter:write-data-element("c12" ,string(accum total by part-2.alc-type-code part-2.total)).
      hSAXWriter:end-element ("row").
    end.
end.
      hSAXWriter:start-element ("row").
        nn = nn + 1.
        hSAXWriter:write-data-element ("n", string(nn)).
        hSAXWriter:write-data-element("c01" ,"Итого").
        hSAXWriter:write-data-element("c02" ,"").
        hSAXWriter:write-data-element("c03" ,"").
        hSAXWriter:write-data-element("c04" ,"").
        hSAXWriter:write-data-element("c05" ,"").
        hSAXWriter:write-data-element("c06" ,"").
        hSAXWriter:write-data-element("c07" ,"").
        hSAXWriter:write-data-element("c08" ,"").
        hSAXWriter:write-data-element("c09" ,"").
        hSAXWriter:write-data-element("c10" ,"").
        hSAXWriter:write-data-element("c11" ,"").
        hSAXWriter:write-data-element("c12" ,string(accum total part-2.total)).
      hSAXWriter:end-element ("row").
hSAXWriter:end-element ("firm").
for each part-2 no-lock break by part-2.obj-type by part-2.obj-code by part-2.purchase-date:
    if first-of(part-2.obj-code) then do:
        hSAXWriter:start-element ("object").
        find first buf_clients where buf_clients.obj-code = part-2.obj-code
                                and buf_clients.obj-type = part-2.obj-type.
        nn = nn + 1.
        hSAXWriter:write-data-element ("n", string(nn)).
        hSAXWriter:write-data-element ("header", buf_clients.obj-name).
    end.
    accumulate part-2.total (total by part-2.obj-code).
    hSAXWriter:start-element ("row").
        nn = nn + 1.
        hSAXWriter:write-data-element ("n", string(nn)).
        hSAXWriter:write-data-element("c01", part-2.alc-type-name).
        hSAXWriter:write-data-element("c02", part-2.alc-type-code).
        hSAXWriter:write-data-element("c03", part-2.producer-obj-name).
        hSAXWriter:write-data-element("c04", part-2.producer-inn).
        hSAXWriter:write-data-element("c05", part-2.producer-kpp).
        hSAXWriter:write-data-element("c06", part-2.supplier-obj-name).
        hSAXWriter:write-data-element("c07", part-2.supplier-inn).
        hSAXWriter:write-data-element("c08", part-2.supplier-kpp).
        hSAXWriter:write-data-element("c09", string(part-2.purchase-date)).
        hSAXWriter:write-data-element("c10", part-2.TTN).
        hSAXWriter:write-data-element("c11", part-2.GTD).
        hSAXWriter:write-data-element("c12", string(part-2.total)).
    hSAXWriter:end-element ("row").
    if last-of (part-2.obj-code) then do:
        hSAXWriter:start-element ("row").
            nn = nn + 1.
            hSAXWriter:write-data-element ("n", string(nn)).
            hSAXWriter:write-data-element("c01", "ИТОГО").
            hSAXWriter:write-data-element("c02", "").
            hSAXWriter:write-data-element("c03", "").
            hSAXWriter:write-data-element("c04", "").
            hSAXWriter:write-data-element("c05", "").
            hSAXWriter:write-data-element("c06", "").
            hSAXWriter:write-data-element("c07", "").
            hSAXWriter:write-data-element("c08", "").
            hSAXWriter:write-data-element("c09", "").
            hSAXWriter:write-data-element("c10", "").
            hSAXWriter:write-data-element("c11", "").
            hSAXWriter:write-data-element("c12", string(accum total by part-2.obj-code part-2.total)).
        hSAXWriter:end-element ("row").
       hSAXWriter:end-element ("object").
    end.
end.
hSAXWriter:end-element ("part-2").
hSAXWriter:end-element ("report").
hSAXWriter:end-document().
delete object hSAXWriter no-error.
xslt = search("exe\alcdc-pril12.xsl").
Report-out = new Rep-Out().
Report-out:office(xml_tmp, xslt).
delete object Report-out.
end procedure.
PROCEDURE xml-output :
define variable hSAXWriter as handle no-undo.
define variable xml        as character no-undo.
define variable ii-ob   as integer no-undo.
define variable ii-impr as integer no-undo.
define variable ii-pos  as integer no-undo.
define variable ii-dv   as integer no-undo.
define variable MyUUID as raw       no-undo.
define variable vGUID  as character no-undo.
assign
  MyUUID = generate-uuid
  vGUID  = guid(MyUUID).
  ii = 0.
xml = session:temp-directory + "R2_" + v-fmtcli-inn + "_" + string(quarter, "99") + substring(string(year(today)), 4, 1) + "_" +
      string(day(today), "99") + string(month(today), "99") + string(year(today), "9999") + "_" + vGUID + ".xml".
create sax-writer hSAXWriter.
hSAXWriter:formatted = true.
hSAXWriter:encoding = "windows-1251":U.
hSAXWriter:set-output-destination("file":U, xml).
hSAXWriter:start-document().
hSAXWriter:start-element ("Файл").
    hSAXWriter:insert-attribute ("ДатаДок", string(day(today), "99") + "." + string(month(today), "99")  + "." + string(year(today), "9999")).
    case RADIO-SET-ver:
        when 1 then hSAXWriter:insert-attribute ("ВерсФорм", "4.31").
        when 3 then hSAXWriter:insert-attribute ("ВерсФорм", "4.30").
        when 2 then hSAXWriter:insert-attribute ("ВерсФорм", "4.20").
    end case.
    hSAXWriter:insert-attribute ("НаимПрог", "Trade House").
    hSAXWriter:start-element ("ФормаОтч").
        case RADIO-SET-ver:
            when 1 then do:
                hSAXWriter:insert-attribute ("НомФорм", "12").
                hSAXWriter:insert-attribute ("ПризПериодОтч", string(quarter)).
                hSAXWriter:insert-attribute ("ГодПериодОтч", string(year(x-date-start))).
            end.
            when 3 then do:
                hSAXWriter:insert-attribute ("НомФорм", "12").
                hSAXWriter:insert-attribute ("ПризПериодОтч", string(quarter)).
                hSAXWriter:insert-attribute ("ГодПериодОтч", string(year(x-date-start))).
            end.
            when 2 then do:
                hSAXWriter:insert-attribute ("ГодПериодОтч", string(year(x-date-start))).
                hSAXWriter:insert-attribute ("НомФорм", "12-о").
                hSAXWriter:insert-attribute ("ПризПериодОтч", string(quarter)).
                hSAXWriter:insert-attribute ("ПризФОтч", "4").
            end.
        end case.
        case RADIO-SET-form:
            when 1 then do:
        hSAXWriter:write-empty-element("Первичная").
            end.
            when 2 then do:
                hSAXWriter:write-empty-element("Корректирующая").
                    hSAXWriter:insert-attribute ("НомерКорр", string(FILL-IN-kor)).
            end.
        end case.
    hSAXWriter:end-element ("ФормаОтч").
    hSAXWriter:start-element ("Справочники").
        ii = 0.
        for each part-1 no-lock break by part-1.prod-type by part-1.prod-code:
            if last-of(part-1.prod-code) then do:
            ii = ii + 1.
            hSAXWriter:start-element ("ПроизводителиИмпортеры").
                hSAXWriter:insert-attribute ("ИДПроизвИмп", if part-1.prod-type = 'чел':U then string(part-1.prod-code + 1000) else string(part-1.prod-code)).
                hSAXWriter:insert-attribute ("П000000000004", part-1.producer-obj-name).
                hSAXWriter:write-empty-element ("ЮЛ").
                    hSAXWriter:insert-attribute ("П000000000005", part-1.producer-inn).
                    hSAXWriter:insert-attribute ("П000000000006", part-1.producer-kpp).
            hSAXWriter:end-element ("ПроизводителиИмпортеры").
            end.
        end.
        for each part-2 no-lock break by part-2.supplier-type by part-2.supplier-code:
            if first-of(part-2.supplier-code) then do:
                ii = ii + 1.
                hSAXWriter:start-element ("Поставщики").
                    hSAXWriter:insert-attribute ("ИдПостав", if part-2.supplier-type = 'чел':U then string(part-2.supplier-code + 1000) else string(part-2.supplier-code)).
                    hSAXWriter:insert-attribute ("П000000000007", part-2.supplier-obj-name).
                        hSAXWriter:write-empty-element ("ЮЛ").
                            hSAXWriter:insert-attribute ("П000000000009", part-2.supplier-inn).
                            hSAXWriter:insert-attribute ("П000000000010", part-2.supplier-kpp).
                hSAXWriter:end-element ("Поставщики").
            end.
        end.
    hSAXWriter:end-element ("Справочники").
    hSAXWriter:start-element ("Документ").
        hSAXWriter:start-element ("Организация").
            hSAXWriter:start-element ("Реквизиты").
                case RADIO-SET-ver:
                    when 1 then hSAXWriter:insert-attribute ("Наим", v-fmtcli-name).
                    when 3 then hSAXWriter:insert-attribute ("НаимОрг", v-fmtcli-name).
                    when 2 then hSAXWriter:insert-attribute ("НаимОрг", v-fmtcli-name).
                end case.
                hSAXWriter:insert-attribute ("ТелОрг", v-fmtcli-phone).
                hSAXWriter:insert-attribute ("EmailОтпр", firm-e-mail).
                hSAXWriter:start-element ("АдрОрг").
                    hSAXWriter:write-data-element ("КодСтраны", firm-country-code).
                    hSAXWriter:write-data-element ("Индекс", firm-post-code).
                    hSAXWriter:write-data-element ("КодРегион", string(integer(firm-reg-code), "99")).
                    hSAXWriter:write-data-element ("Район", firm-district).
                    hSAXWriter:write-data-element ("Город", firm-city).
                    hSAXWriter:write-data-element ("НаселПункт", firm-settlement).
                    hSAXWriter:write-data-element ("Улица", firm-street).
                    hSAXWriter:write-data-element ("Дом", firm-house-number).
                    hSAXWriter:write-data-element ("Корпус", firm-house-case).
                    hSAXWriter:write-data-element ("Литера", firm-house-litera).
                    hSAXWriter:write-data-element ("Кварт", firm-house-apartment).
                hSAXWriter:end-element ("АдрОрг").
                hSAXWriter:write-empty-element ("ЮЛ").
                    hSAXWriter:insert-attribute ("ИННЮЛ", v-fmtcli-inn).
                    hSAXWriter:insert-attribute ("КППЮЛ", v-fmtcli-kpp).
            hSAXWriter:end-element ("Реквизиты").
            hSAXWriter:start-element ("ОтветЛицо").
                hSAXWriter:start-element ("Руководитель").
                    hSAXWriter:write-data-element ("Фамилия", firm-director-f).
                    hSAXWriter:write-data-element ("Имя", firm-director-i).
                    hSAXWriter:write-data-element ("Отчество", firm-director-o).
                hSAXWriter:end-element ("Руководитель").
                hSAXWriter:start-element ("Главбух").
                    hSAXWriter:write-data-element ("Фамилия", firm-accountant-f).
                    hSAXWriter:write-data-element ("Имя", firm-accountant-i).
                    hSAXWriter:write-data-element ("Отчество", firm-accountant-o).
                hSAXWriter:end-element ("Главбух").
            hSAXWriter:end-element ("ОтветЛицо").
        hSAXWriter:end-element ("Организация").
        for each page-2 no-lock:
            hSAXWriter:start-element ("ОбъемОборота").
                hSAXWriter:insert-attribute ("КППЮЛ", page-2.kpp).
                case RADIO-SET-ver:
                    when 1 then hSAXWriter:insert-attribute ("Наим", page-2.obj-name).
                    when 3 then hSAXWriter:insert-attribute ("НаимЮЛ", page-2.obj-name).
                    when 2 then hSAXWriter:insert-attribute ("НаимЮЛ", page-2.obj-name).
                end case.
                if can-find (first part-1 where part-1.obj-type = page-2.obj-type
                                          and   part-1.obj-code = page-2.obj-code
                                          and   (part-1.inc-14 <> 0 or part-1.exp-19 <> 0 ))
                then do:
                    hSAXWriter:insert-attribute ("НаличиеОборота", "true").
                end.
                else do:
                    hSAXWriter:insert-attribute ("НаличиеОборота", "false").
                end.
                hSAXWriter:start-element ("АдрОрг").
                    hSAXWriter:write-data-element ("КодСтраны", page-2.country-code).
                    hSAXWriter:write-data-element ("Индекс", page-2.post-code).
                    hSAXWriter:write-data-element ("КодРегион", string(integer(page-2.reg-code), "99")).
                    hSAXWriter:write-data-element ("Район", page-2.district).
                    hSAXWriter:write-data-element ("Город", page-2.city).
                    hSAXWriter:write-data-element ("НаселПункт", page-2.settlement).
                    hSAXWriter:write-data-element ("Улица", page-2.street).
                    hSAXWriter:write-data-element ("Дом", page-2.house-number).
                    hSAXWriter:write-data-element ("Корпус", page-2.house-case).
                    hSAXWriter:write-data-element ("Литера", page-2.house-litera).
                    hSAXWriter:write-data-element ("Кварт", page-2.apartment).
                hSAXWriter:end-element ("АдрОрг").
                ii-ob = 0.
                for each part-1 no-lock where part-1.obj-code = page-2.obj-code
                                        and   part-1.obj-type = page-2.obj-type
                                        break by part-1.alc-type-code:
                    if first-of(part-1.alc-type-code) then do:
                        ii-impr = 0.
                        ii-ob = ii-ob + 1.
                        hSAXWriter:start-element ("Оборот").
                            hSAXWriter:insert-attribute ("ПN", string(ii-ob)).
                            hSAXWriter:insert-attribute ("П000000000003", part-1.alc-type-code).
                    end.
                    hSAXWriter:start-element ("СведПроизвИмпорт").
                        ii-impr = ii-impr + 1.
                        hSAXWriter:insert-attribute ("ПN", string(ii-impr)).
                        hSAXWriter:insert-attribute ("ИдПроизвИмп", if part-1.prod-type = 'чел':U then string(part-1.prod-code + 1000) else string(part-1.prod-code)).
                        ii-pos = 0.
                        for each part-2 where part-2.alc-type-code = part-1.alc-type-code
                                        and  (
                                              (part-2.prod-code = part-1.prod-code and part-2.prod-type = part-1.prod-type)
                                           or (part-2.producer-inn = part-1.producer-inn and part-2.producer-kpp = part-1.producer-kpp)
                                                )
                                        and   part-2.obj-code  = part-1.obj-code
                                        and   part-2.obj-type  = part-1.obj-type
                                        break by part-2.supplier-code:
                            if first-of(part-2.supplier-code) then do:
                                ii-pos = ii-pos + 1.
                                hSAXWriter:start-element ("Поставщик").
                                    hSAXWriter:insert-attribute ("ПN", string(ii-impr)).
                                    hSAXWriter:insert-attribute ("ИдПоставщика", if part-2.supplier-type = 'чел':U then string(part-2.supplier-code + 1000) else string(part-2.supplier-code)).
                            end.
                            hSAXWriter:write-empty-element ("Продукция").
                                hSAXWriter:insert-attribute ("П200000000013", string(part-2.purchase-date, "99.99.9999")).
                                hSAXWriter:insert-attribute ("П200000000014", part-2.TTN).
                                hSAXWriter:insert-attribute ("П200000000015", part-2.GTD).
                                hSAXWriter:insert-attribute ("П200000000016", string(part-2.total)).
                            if last-of(part-2.supplier-code) then do:
                                hSAXWriter:end-element ("Поставщик").
                            end.
                        end.
                        hSAXWriter:write-empty-element ("Движение").
                            hSAXWriter:insert-attribute ("ПN", "1").
                            hSAXWriter:insert-attribute ("П100000000006", string(part-1.remain-6)).
                            hSAXWriter:insert-attribute ("П100000000007", string(part-1.inc-7)).
                            hSAXWriter:insert-attribute ("П100000000008", string(part-1.inc-8)).
                            hSAXWriter:insert-attribute ("П100000000009", string(part-1.inc-9)).
                            hSAXWriter:insert-attribute ("П100000000010", string(part-1.inc-10)).
                            hSAXWriter:insert-attribute ("П100000000011", string(part-1.inc-11)).
                            hSAXWriter:insert-attribute ("П100000000012", string(decimal(part-1.inc-12) + decimal(part-1.inc-13))).
                            hSAXWriter:insert-attribute ("П100000000013", string(part-1.inc-14)).
                            hSAXWriter:insert-attribute ("П100000000014", string(part-1.exp-15)).
                            hSAXWriter:insert-attribute ("П100000000015", string(decimal(part-1.exp-16) + decimal(part-1.exp-18))).
                            hSAXWriter:insert-attribute ("П100000000016", string(part-1.exp-17)).
                            hSAXWriter:insert-attribute ("П100000000017", string(part-1.exp-19)).
                            hSAXWriter:insert-attribute ("П100000000018", string(part-1.remain-20)).
                        hSAXWriter:end-element ("СведПроизвИмпорт").
                    if last-of(part-1.alc-type-code) then do:
                        hSAXWriter:end-element ("Оборот").
                    end.
                end.
            hSAXWriter:end-element ("ОбъемОборота").
        end.
    hSAXWriter:end-element ("Документ").
hSAXWriter:end-element ("Файл").
hSAXWriter:end-document().
delete object hSAXWriter no-error.
message "Вывод в XML завершен." skip
        "Путь к сформированному файлу: " skip
        xml
view-as alert-box information.
end procedure.
PROCEDURE local-initialize :
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ) .
    assign
    EDITOR-ALC-PRODUCER = "По всем производителям"
    EDITOR-SUPPLIER = "По всем поставщикам"
    EDITOR-ALC-TYPE = "По всем типам продукции"
    TOGGLE-Excel    = yes
    TOGGLE-XML      = yes.
    display EDITOR-ALC-PRODUCER EDITOR-SUPPLIER EDITOR-ALC-TYPE TOGGLE-Excel TOGGLE-XML with frame F-Main.
    assign FILL-IN-kor:hidden in frame F-Main = true.
END PROCEDURE.
PROCEDURE my-params :
END PROCEDURE.
PROCEDURE my-var :
END PROCEDURE.
PROCEDURE write-to-log :
define input param p-str as char no-undo.
do
on error undo, return error
:
   message
      p-str
      skip
   view-as alert-box error.
end.
END PROCEDURE.
procedure my-init-temp-parts-by-factord :
  define input parameter p-obj-type           like ub.parts.obj-type  no-undo .
  define input parameter p-obj-code           like ub.parts.obj-code  no-undo .
  define input parameter p-artic              like ub.parts.artic     no-undo .
  define input parameter p-prod-type          like ub.parts.prod-type no-undo .
  define input parameter p-prod-code          like ub.parts.prod-code no-undo .
  define input parameter p-fact-order         as decimal   no-undo .
  define variable vss-description as character no-undo init "partslib-init-temp-parts-by-factord: определение партий свободной зоны на любую дату".
  define buffer buf_gds-obj  for ub.gds-obj .
  do
  on error undo, return error
  :
    do transaction
    on error undo, return error
    :
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjcr in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,buffer buf_gds-obj
  ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Невозможно найти товар на объекте" skip
          "Объект" p-obj-type p-obj-code skip
          "Артикул" p-artic p-prod-type p-prod-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
      find current buf_gds-obj exclusive-lock .
    end.
    run partslib-init-temp-parts in this-procedure
      (input p-obj-type
      ,input p-obj-code
      ,input p-artic
      ,input p-prod-type
      ,input p-prod-code
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при инициализации текущего остатка по партиям свободной зоны" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "p-fact-order" p-fact-order skip
        view-as alert-box error .
      undo, return error .
    end.
    assign
      p-fact-order = p-fact-order - 0.0000000001
    .
    define variable v-max-fact-order as character no-undo .
    run factord-max-fact-order in this-procedure
      (output v-max-fact-order
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры factord-max-fact-order" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "p-fact-order" p-fact-order skip
        view-as alert-box error .
      undo, return error .
    end.
    run my-update-by-factord in this-procedure
      (input p-obj-type
      ,input p-obj-code
      ,input p-artic
      ,input p-prod-type
      ,input p-prod-code
      ,input p-fact-order
      ,input v-max-fact-order
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры partslib-update-by-factord" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "p-fact-order" p-fact-order skip
        "v-max-fact-order" v-max-fact-order skip
        view-as alert-box error .
      undo, return error .
    end.
  end.
end procedure.
procedure my-update-by-factord :
  define input parameter p-obj-type           like ub.parts.obj-type  no-undo .
  define input parameter p-obj-code           like ub.parts.obj-code  no-undo .
  define input parameter p-artic              like ub.parts.artic     no-undo .
  define input parameter p-prod-type          like ub.parts.prod-type no-undo .
  define input parameter p-prod-code          like ub.parts.prod-code no-undo .
  define input parameter p-start-fact-order   as decimal   no-undo .
  define input parameter p-end-fact-order     as decimal   no-undo .
  define variable vss-description as character no-undo init "partslib-init-temp-parts-by-factord: определение партий свободной зоны на любую дату".
  define buffer buf_gds-obj  for ub.gds-obj .
  define buffer buf_doc-line for ub.doc-line .
  define variable v-total-parts-qnty as decimal   no-undo .
  define variable v-goods-gds-goods  as logical   no-undo .
  define variable v-goods-twounit    as logical   no-undo .
  define variable v-kpp2            as character no-undo .
  do
  on error undo, return error
  :
    if p-start-fact-order > p-end-fact-order
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Начало интервала превышает конец интервала" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "p-start-fact-order" p-start-fact-order skip
        "p-end-fact-order"   p-end-fact-order skip
        view-as alert-box error .
      undo, return error .
    end.
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsat in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,input  'gds-goods=request':u
  ,output v-goods-gds-goods
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута товара" skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "gds-goods=request" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsat in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,input  'twounit=request':u
  ,output v-goods-twounit
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута товара" skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "twounit=request" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    for each buf_doc-line no-lock
      where buf_doc-line.obj-type   = p-obj-type
        and buf_doc-line.obj-code   = p-obj-code
        and buf_doc-line.artic      = p-artic
        and buf_doc-line.prod-type  = p-prod-type
        and buf_doc-line.prod-code  = p-prod-code
        and buf_doc-line.status_    = 'факт':U
        and buf_doc-line.fact-order > p-start-fact-order
        and buf_doc-line.fact-order <= p-end-fact-order
    on error undo, return error
    :
      if (buf_doc-line.ext-doc-type = 'iv' or buf_doc-line.ext-doc-type = 'ev' or buf_doc-line.ext-doc-type = 'rv')
      then do :
        for first buf_trn-doc no-lock where buf_trn-doc.doc-code = buf_doc-line.doc-code :
            v-kpp = "" .
            for first buf_clients-attr no-lock where buf_clients-attr.obj-code  = buf_trn-doc.cli-code
                                               and   buf_clients-attr.obj-type  = buf_trn-doc.cli-type
                                               and   buf_clients-attr.attr-code = 'kpp':U:
                v-kpp = buf_clients-attr.attr-value.
            end.
            if v-kpp = "" then  v-kpp = v-fmtcli-kpp.
            v-kpp2 = "" .
            for first buf_clients-attr no-lock where buf_clients-attr.obj-code  = buf_trn-doc.obj-code
                                               and   buf_clients-attr.obj-type  = buf_trn-doc.obj-type
                                               and   buf_clients-attr.attr-code = 'kpp':U:
                v-kpp2 = buf_clients-attr.attr-value.
            end.
            if v-kpp2 = "" then  v-kpp2 = v-fmtcli-kpp.
            if v-kpp = v-kpp2 then next .
        end.
      end.
      run partslib-process-document in this-procedure
        (input  buf_doc-line.doc-code
        ,input  p-obj-type
        ,input  p-obj-code
        ,input  p-artic
        ,input  p-prod-type
        ,input  p-prod-code
        ,input  v-goods-gds-goods
        ,input  v-goods-twounit
        ,output v-total-parts-qnty
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове процедуры partslib-process-document" skip
          "Документ" buf_doc-line.doc-code skip
          "Объект" p-obj-type p-obj-code skip
          "Артикул" p-artic p-prod-type p-prod-code skip
          "p-start-fact-order" p-start-fact-order skip
          "p-end-fact-order" p-end-fact-order skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
  end.
end procedure.
