block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: 2014/01/27 14:27:46 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-o-good.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-o-good.p $":U .
define variable vss-description as character no-undo init "Оборотная ведомость отчет".
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
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure partrqst :
  define input  parameter p-doc-code                   like ub.doc-line.doc-code  no-undo .
  define input  parameter p-obj-type                   like ub.doc-line.obj-type  no-undo .
  define input  parameter p-obj-code                   like ub.doc-line.obj-code  no-undo .
  define input  parameter p-artic                      like ub.doc-line.artic     no-undo .
  define input  parameter p-prod-type                  like ub.doc-line.prod-type no-undo .
  define input  parameter p-prod-code                  like ub.doc-line.prod-code no-undo .
  define output parameter p-total-parts-qnty           like ub.parts.qnty         no-undo .
  define output parameter p-total-parts-fact-qnty      like ub.parts.fact-qnty    no-undo .
  define output parameter p-total-parts-cli-qnty       like ub.parts.cli-qnty     no-undo .
  define output parameter p-total-parts-fact-cli-qnty  like ub.parts.cli-qnty     no-undo .
  define output parameter p-total-parts-price-cli      as decimal                 no-undo .
  define output parameter p-total-parts-price-base     as decimal                 no-undo .
  define output parameter p-total-parts-price-rubl     as decimal                 no-undo .
  define output parameter p-total-parts-transport-base as decimal                 no-undo .
  define output parameter p-total-parts-transport-rubl as decimal                 no-undo .
  define output parameter p-total-parts-other-base     as decimal                 no-undo .
  define output parameter p-total-parts-other-rubl     as decimal                 no-undo .
  define variable vss-description as character no-undo init "partrqst: Суммарная информация по всем зарезервированным партиям строки документа".
  do
  on error undo, return error return-value
  :
    assign
      p-total-parts-qnty           = 0
      p-total-parts-fact-qnty      = 0
      p-total-parts-cli-qnty       = 0
      p-total-parts-fact-cli-qnty  = 0
      p-total-parts-price-cli      = 0
      p-total-parts-price-base     = 0
      p-total-parts-price-rubl     = 0
      p-total-parts-transport-base = 0
      p-total-parts-transport-rubl = 0
      p-total-parts-other-base     = 0
      p-total-parts-other-rubl     = 0
    .
    define buffer buf_parts for ub.parts .
    for each buf_parts no-lock
      where buf_parts.out-code  = p-doc-code
        and buf_parts.obj-type  = p-obj-type
        and buf_parts.obj-code  = p-obj-code
        and buf_parts.artic     = p-artic
        and buf_parts.prod-type = p-prod-type
        and buf_parts.prod-code = p-prod-code
    on error undo, return error return-value
    :
      define variable v-parts-fact-multiplier as decimal   no-undo .
      assign
        v-parts-fact-multiplier = 1
      .
      if buf_parts.qnty <> 0 then do:
        assign
          v-parts-fact-multiplier = buf_parts.fact-qnty / buf_parts.qnty
        .
      end.
      assign
        p-total-parts-qnty            = p-total-parts-qnty       + buf_parts.qnty
        p-total-parts-fact-qnty       = p-total-parts-fact-qnty  + buf_parts.fact-qnty
        p-total-parts-cli-qnty        = p-total-parts-cli-qnty   + buf_parts.cli-qnty
        p-total-parts-fact-cli-qnty   = p-total-parts-fact-cli-qnty
                                      + buf_parts.cli-qnty * v-parts-fact-multiplier
        p-total-parts-price-cli       = p-total-parts-price-cli  + buf_parts.cli-qnty  * buf_parts.price-cli
        p-total-parts-price-base      = p-total-parts-price-base + buf_parts.fact-qnty * buf_parts.price-base
        p-total-parts-price-rubl      = p-total-parts-price-rubl + buf_parts.fact-qnty * buf_parts.price-rubl
        p-total-parts-transport-base  = p-total-parts-transport-base
                                      + buf_parts.fact-qnty
                                        * (if   buf_parts.transport-base <> ?
                                          then buf_parts.transport-base
                                          else 0
                                          )
        p-total-parts-transport-rubl  = p-total-parts-transport-rubl
                                      + buf_parts.fact-qnty
                                        * (if   buf_parts.transport-rubl <> ?
                                          then buf_parts.transport-rubl
                                          else 0
                                          )
        p-total-parts-other-base      = p-total-parts-other-base
                                      + buf_parts.fact-qnty
                                        * (if   buf_parts.other-base <> ?
                                          then buf_parts.other-base
                                          else 0
                                          )
        p-total-parts-other-rubl      = p-total-parts-other-rubl
                                      + buf_parts.fact-qnty
                                        * (if   buf_parts.other-rubl <> ?
                                          then buf_parts.other-rubl
                                          else 0
                                          )
      .
    end.
  end.
end procedure.
function func-vat returns decimal (
    input p-gds-code as integer  ,
    input p-obj-type as character ,
    input p-obj-code as integer  ).
define variable i-vat-pc as decimal no-undo .
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define input parameter x-store-code like ub.clients.obj-code   no-undo.
define input parameter x-store-type like ub.clients.obj-type   no-undo.
define input parameter x-base-type  like ub.currency.curr-abbr no-undo.
define input parameter x-base-code  like ub.currency.curr-code no-undo.
define input parameter xCOMBO-node as char no-undo.
define input parameter xtog-inv as logical no-undo .
define input parameter xClassify  as char no-undo.
define input parameter xSortType  as char no-undo.
define input parameter xType  as char no-undo.
define variable inv-fact-order like ub.stk-tot.Fact-order init 0 no-undo.
define variable inv-str        as character init "" no-undo .
define variable Discnt-rubl# as decimal init 0  no-undo .
define variable Discnt-base# as decimal init 0  no-undo .
define variable tot-ov#      as decimal init 0  no-undo .
define variable v-ii as integer no-undo  .
define variable sums-only as logical no-undo .
define  variable  tPrintRubl as log no-undo.
define variable v-log as logical   no-undo .
define  stream  OutStream.
define  stream  OutStream2.
define    variable    ObjName           as   char no-undo.
define    variable    Select-Good       as   integer no-undo.
define    variable    ChosedType        as   integer no-undo.
define    variable    PayType           as   integer no-undo.
define    variable    ValType           as   integer no-undo.
define    variable    Line              as   char        no-undo.
define    variable    FirstLine         as   logical     no-undo.
define variable tow-unit  as log no-undo .
define variable stat     as log no-undo .
define variable InpError as log no-undo .
define variable i        as integer no-undo .
define variable p        as integer no-undo init 0 .
define variable kk        as integer no-undo init 0 .
define variable old-page as integer no-undo .
define variable new-page as integer no-undo .
define variable rid-list as character no-undo .
define  variable gds-zap-unit-base     like ub.goods.unit-base     no-undo.
define  variable gds-zap-prt-root      like ub.goods.prt-root     no-undo .
define  variable gds-zap-gds-name      like ub.goods.gds-name     no-undo .
define  variable gds-zap-prod-type     like ub.goods.prod-type    no-undo .
define  variable gds-zap-prod-code     like ub.goods.prod-code    no-undo .
define  variable gds-zap-artic         like ub.goods.artic        no-undo .
define  variable gds-zap-b-code        like ub.bar-code.b-code    no-undo .
define  variable gds-type              as char no-undo.
define  variable gds-zap-grp-name      like ub.goods.grp-name     no-undo .
define  variable gds-zap-prod-name     like ub.clients.obj-name   no-undo .
define  variable gds-zap-price-base    like ub.stk-tot.sum-rubl  no-undo.
define  variable gds-zap-stoim-base    like ub.stk-tot.sum-rubl  no-undo.
define  variable gds-zap-qnty          like ub.stk-tot.fact-qnty no-undo.
define  variable gds-zap-Nds           like ub.stk-tot.sum-rubl  no-undo.
define  variable gds-zap-Np            like ub.stk-tot.sum-rubl  no-undo.
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
define variable  coast-vat   like ub.stk-tot.sum-rubl   no-undo.
define variable  coast-vat1   like ub.stk-tot.sum-rubl   no-undo.
define variable  coast-vat2   like ub.stk-tot.sum-rubl   no-undo.
define variable  coast-vat3   like ub.stk-tot.sum-rubl   no-undo.
define variable  coast-vat4   like ub.stk-tot.sum-rubl   no-undo.
define variable  VAT_R       like ub.stk-tot.sum-rubl   no-undo.
define variable  VAT_V       like ub.stk-tot.sum-rubl   no-undo.
define variable  SLT_R       like ub.stk-tot.sum-rubl   no-undo.
define variable  SLT_V       like ub.stk-tot.sum-rubl   no-undo.
define variable  SLT_R1       like ub.stk-tot.sum-rubl   no-undo.
define variable  SLT_V1       like ub.stk-tot.sum-rubl   no-undo.
define variable  Coast3       like ub.stk-tot.sum-rubl   no-undo.
define variable  Coast4       like ub.stk-tot.sum-rubl   no-undo.
define variable  Coast1       like ub.stk-tot.sum-rubl   no-undo.
define variable  temp-str as char no-undo.
define variable str as char format "X(60)" no-undo.
define variable i#i as int no-undo.
define variable LL as int no-undo.
define variable xLavel as int  no-undo.
define variable list-field as char no-undo.
define variable str10 as char no-undo.
define variable curr-rep as char no-undo.
define variable NO-PRISE as logical no-undo  init true .
define variable s1 as decimal  FORMAT "->>>>>>>>9.<<<" no-undo .
define variable s2 as decimal  FORMAT "->>>>>>>>>9.<<" no-undo .
define variable s3 as decimal  FORMAT "->>>>>>>>>9.<<" no-undo .
define variable s4 as decimal  FORMAT "->>>>>>>>>9.<<" no-undo .
define variable s5 as decimal  FORMAT "->>>>>>>>>9.<<" no-undo .
define variable s6 as decimal  FORMAT "->>>>>>>>>9.<<" no-undo .
define variable s7 as decimal  FORMAT "->>>>>>>>>9.<<" no-undo .
define variable s8 as decimal  FORMAT "->>>>>>>>>9.<<" no-undo .
define variable s#1 as decimal FORMAT "->>>>>>>>9.<<<" no-undo .
define variable s#2 as decimal FORMAT "->>>>>>>>>9.<<" no-undo .
define variable s#3 as decimal FORMAT "->>>>>>>>>9.<<" no-undo .
define variable s#4 as decimal FORMAT "->>>>>>>>>9.<<" no-undo .
define variable s#5 as decimal FORMAT "->>>>>>>>>9.<<" no-undo .
define variable s#6 as decimal FORMAT "->>>>>>>>>9.<<" no-undo .
define variable s#7 as decimal FORMAT "->>>>>>>>>9.<<" no-undo .
define variable s#8 as decimal FORMAT "->>>>>>>>>9.<<" no-undo .
define variable     F-fact-date  as char  no-undo.
define variable     f-doc-code   as char  no-undo.
define variable     f-type-doc   as char  no-undo.
define variable     f-cli-name   as char  no-undo.
define variable     F-qnty       as decimal FORMAT "->>>>>>>>9.<<<" no-undo.
define variable     f-SumSALE    as decimal FORMAT "->>>>>>>>>9.99" no-undo.
define variable     f-SumCOST    as decimal FORMAT "->>>>>>>>>9.99" no-undo.
define variable     f-SumCRSA    as decimal FORMAT "->>>>>>>>>9.99" no-undo.
define variable     f-discnt-sum as decimal FORMAT "->>>>>>9.<<"  no-undo.
define variable     f-ov-sum     as decimal FORMAT "->>>>>>>>>9.99" no-undo.
define variable     F-VAT_pc     as char no-undo.
define variable     f-VAT-Sum    as decimal FORMAT "->>>>>>>9.99" no-undo.
define variable     F-SLT_pc     as char no-undo.
define variable     f-SLT-sum    as decimal FORMAT "->>>>>>>9.99" no-undo.
define variable     h-F-kol-1   AS WIDGET-HANDLE.
define variable     h-F-kol-2   AS WIDGET-HANDLE.
define variable     h-kol-1   AS WIDGET-HANDLE.
define variable     h-kol-2   AS WIDGET-HANDLE.
define variable     h-fact-date  AS WIDGET-HANDLE.
define variable     h-doc-code   AS WIDGET-HANDLE.
define variable     h-type-doc   AS WIDGET-HANDLE.
define variable     h-cli-name   AS WIDGET-HANDLE.
define variable     h-qnty       AS WIDGET-HANDLE.
define variable     h-SumSALE    AS WIDGET-HANDLE.
define variable     h-SumCOST    AS WIDGET-HANDLE.
define variable     h-SumCRSA    AS WIDGET-HANDLE.
define variable     h-discnt-sum AS WIDGET-HANDLE.
define variable     h-ov-sum     AS WIDGET-HANDLE.
define variable     h-VAT_pc     AS WIDGET-HANDLE.
define variable     h-VAT-Sum    AS WIDGET-HANDLE.
define variable     h-SLT_pc     AS WIDGET-HANDLE.
define variable     h-SLT-sum    AS WIDGET-HANDLE.
define variable     h-15     AS WIDGET-HANDLE.
define variable     h-16     AS WIDGET-HANDLE.
define variable     startdate  as date  no-undo.
define variable     enddate    as date  no-undo.
define variable     fact-date  as date  no-undo.
define variable     type-doc   as char  no-undo.
define variable     doc-code   as char  no-undo.
define variable     cli-name   as char  no-undo.
define variable     qnty       as decimal FORMAT "->>>>>>>>9.999" no-undo.
define variable     qnty-1     as decimal FORMAT "->>>>>>>>9.999" no-undo.
define variable     qnty-2     as decimal FORMAT "->>>>>>>>9.999" no-undo.
define variable     SumSALE    as decimal FORMAT "->>>>>>>>>>9.<<" no-undo.
define variable     SumCOST    as decimal FORMAT "->>>>>>>>>>9.<<" no-undo.
define variable     SumCRSA    as decimal FORMAT "->>>>>>>>>>9.<<" no-undo.
define variable     discnt-sum as decimal FORMAT "->>>>>>>>>9.<<"  no-undo.
define variable     ov-sum     as decimal FORMAT "->>>>>>>>>>9.<<"  no-undo.
define variable     VAT_pc     as char no-undo.
define variable     VAT-Sum    as decimal FORMAT "->>>>>>>>>>9.<<" no-undo.
define variable     SLT_pc     as char no-undo.
define variable     SLT-sum    as decimal FORMAT "->>>>>>>>>>9.<<" no-undo.
define variable TOT-SumCRSA   like SumCRSA no-undo.
define variable TOT-VAT-Sum   like VAT-Sum no-undo.
define variable TOT-SLT-sum   like SLT-sum no-undo.
define variable TOT-SumCOST   like SumCOST no-undo.
define variable TOT-SumSALE   like SumSALE no-undo.
define variable TOT-qnty      like qnty    no-undo.
define variable TOT-discnt-sum  like discnt-sum no-undo.
define variable TOT-ov-sum      like ov-sum     no-undo.
define variable cc as logical no-undo .
DEFINE BUFFER ot-line-Cost FOR ub.ot-line.
DEFINE BUFFER ot-line-Sale FOR ub.ot-line.
DEFINE VARIABLE sym1Handle AS WIDGET-HANDLE.
DEFINE VARIABLE sym1-ed AS CHARACTER INITIAL "::"
     VIEW-AS EDITOR
     SIZE 1 BY 2 NO-UNDO.
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
assign v-account = ( if integer( 50 ) = 0 then 100 else integer( 50 ) ).
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
DEFINE FRAME top-frame
    sym1-ed AT ROW 1 COL 1 no-label
    HEADER
        cur-time-print() AT 5 format "X(35)"
        x-store-type format "X(5)"
        ObjName format "X(35)" "Цены указаны в" (if tPrintRubl then "РУБ" else x-base-type )
        Line format "X(198)" AT 1
     WITH 232 DOWN stream-io  use-text NO-BOX
         NO-UNDERLINE
         AT COL 1 ROW 1
         SIZE 198 BY 15  .
DEFINE FRAME zapas
    F-fact-date column-label "1":C8 format "x(8)" space(0)
    sym1 column-label ":" format "X(1)" space(0)
    f-doc-code column-label "2":C10 format "X(10)" space(0)
    sym2 column-label ":" format "X(1)" space(0)
    f-type-doc column-label "3":C3 format "X(3)" space(0)
    sym3 column-label ":" format "X(1)" space(0)
    f-cli-name column-label "4":C30 format "X(30)" space(0)
    sym4 column-label ":" format "X(1)" space(0)
    F-qnty column-label "5":C10    space(0)
    sym5 column-label ":" format "X(1)" space(0)
    f-SumSALE column-label "6":C13  space(0)
    sym6 column-label ":" format "X(1)" space(0)
    f-SumCOST column-label "7":C13 space(0)
    sym7 column-label ":" format "X(1)" space(0)
    f-discnt-sum column-label "8":C9 space(0)
    sym8 column-label ":" format "X(1)" space(0)
    f-ov-sum column-label "9":C10  space(0)
    sym9 column-label ":" format "X(1)" space(0)
    f-SumCRSA column-label "10":C13 space(0)
    sym10 column-label ":" format "X(1)" space(0)
    F-VAT_pc column-label "11" format "x(2)" space(0)
    sym11 column-label ":" format "X(1)" space(0)
    f-VAT-Sum column-label "12":C10       space(0)
    sym12 column-label ":" format "X(1)" space(0)
    F-SLT_pc column-label "13" format "x(2)" space(0)
    sym13 column-label ":" format "X(1)" space(0)
    f-SLT-sum column-label "14":C12 space(0)
    sym17 column-label ":" format "X(1)" space(0)
    sym14 Format "X(13)"  column-label "15":C13  space(0)
    sym15 column-label ":" format "X(1)" space(0)
    sym16 column-label "16":C15 format "X(15)" space(0)
    HEADER
        Line format "X(198)" AT 1
   with width 232 down stream-io use-text NO-BOX .
     assign
        i=0
        Select-Good   = x-SelectGood
        PayType       = x-SET_PAY_TYPE
        FirstLine     = FALSE.
        Line          = fill("-", 232).
        startdate     = x-Date-Start           .
        enddate       = x-Date-End             .
        ValType       = IF (PayType = 1) Then 0  else x-SET_val_TYPE.
        tow-unit = false .
        if Num-entries(xType) = 3 then
           If entry(3,xType) = 'yes' Then tow-unit = true .
        sums-only = (if entry(2,xtype) = "yes" then  true
                                               else false )  no-error .
        if sums-only = ? then sums-only = false .
define variable vss-include-info17 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  cc = v-log.
     CREATE WIDGET-POOL "qq" PERSISTENT.
create editor h-fact-date in widget-pool "qq"
assign
    frame = frame top-frame:handle
    column = 1
    screen-value = string ('Дата закрытия')
    width-chars = 8
    .
create editor h-doc-code in widget-pool "qq"
assign
    frame = frame top-frame:handle
    column = 10
    screen-value = string ('Номер документа')
    width-chars = 10
    .
create editor h-type-doc in widget-pool "qq"
assign
    frame = frame top-frame:handle
    column = 21
    screen-value = string ('Тип')
    width-chars = 3
    .
create editor h-cli-name in widget-pool "qq"
assign
    frame = frame top-frame:handle
    column = 25
    screen-value = string ('Контрагент')
    width-chars = 30
    .
create editor h-qnty in widget-pool "qq"
assign
    frame = frame top-frame:handle
    column = 56
    screen-value = string ('Количество')
    width-chars = 10
    .
create editor h-SumSALE in widget-pool "qq"
assign
    frame = frame top-frame:handle
    column = 68
    screen-value = string ('Сумма по документу')
    width-chars = 13
    .
create editor h-SumCOST in widget-pool "qq"
assign
    frame = frame top-frame:handle
    column = 83
    screen-value = string ('Сумма по учетной цене')
    width-chars = 13
    .
create editor h-discnt-sum in widget-pool "qq"
assign
    frame = frame top-frame:handle
    column = 98
    screen-value = string ('Сумма скидки')
    width-chars = 10
    .
create editor h-ov-sum in widget-pool "qq"
assign
    frame = frame top-frame:handle
    column = 108
    screen-value = string ('Сумма авт. переоценки')
    width-chars = 10
    .
create editor h-SumCRSA in widget-pool "qq"
assign
    frame = frame top-frame:handle
    column = 123
    screen-value = string ('Сумма прод. цен')
    width-chars = 10
    .
create editor h-VAT_pc in widget-pool "qq"
assign
    frame = frame top-frame:handle
    column = 138
    screen-value = string ('НДС %')
    width-chars = 2
    .
create editor h-VAT-Sum in widget-pool "qq"
assign
    frame = frame top-frame:handle
    column = 141
    screen-value = string ('Сумма НДС')
    width-chars = 9
    .
create editor h-SLT_pc in widget-pool "qq"
assign
    frame = frame top-frame:handle
    column = 154
    screen-value = string ('НП %')
    width-chars = 2
    .
create editor h-SLT-sum in widget-pool "qq"
assign
    frame = frame top-frame:handle
    column = 157
    screen-value = string ('Сумма НП')
    width-chars = 9
    .
     IF  tow-unit = true THEN DO:
create editor h-f-kol-1 in widget-pool "qq"
assign
    frame = frame top-frame:handle
    column = 171
    screen-value = string ('Количество в шт.')
    width-chars = 10
    .
create editor h-f-kol-2 in widget-pool "qq"
assign
    frame = frame top-frame:handle
    column = 183
    screen-value = string ('Количество вес')
    width-chars = 10
    .
            CREATE FILL-IN h-kol-1 IN WIDGET-POOL "qq"
              ASSIGN
                FRAME = FRAME zapas:HANDLE
                DATA-TYPE = "DECIMAL"
                FORMAT = "->>>>>>>9.<<<"
                COLUMN =  171
                .
            CREATE FILL-IN h-kol-2 IN WIDGET-POOL "qq"
              ASSIGN
                FRAME = FRAME zapas:HANDLE
                DATA-TYPE = "DECIMAL"
                FORMAT = "->>>>>>>9.<<<"
                COLUMN =  181
                .
       End.
       else do:
         Assign
            sym14:label in frame zapas = ''
            sym15:label in frame zapas = ''
            sym16:label in frame zapas = ''
            Line         = fill("-", 232 - 28).
            .
       End.
    run report-execute.
PROCEDURE report-execute :
  If (ValType=0 and x-base-code=0)  Or ValType=1
                                then   assign tPrintRubl = yes .
                                else   assign tPrintRubl = no .
  NO-PRISE = true .
    if var-report-r-b = "rubl"  Then    if  x-base-code <> 0 and ValType = 2  then NO-PRISE = false  .
                                else    if  x-base-code <> 0 and ValType = 1  then NO-PRISE = false  .
output stream OutStream to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size  value(ReportPageHeight) .
  FORM HEADER
      string( "Страница " + string( PAGE-NUMBER( OutStream ), ">>>>>9") ) AT 170 format "x(24)" SKIP
    with FRAME BottomFrame2 width 235 PAGE-BOTTOM NO-LABELS NO-BOX .
 VIEW STREAM OutStream FRAME BottomFrame2 .
   run Display-main-title.
   ll = 0.
   FOR EACH OBJ-list no-lock :
   ll = ll + 1 .
      x-store-code = obj-list.obj-code.
      x-store-type = obj-list.obj-type.
      if ll > 1 THEN Page stream OutStream.
      run Display-object.
      Case xClassify :
      When  "no-classify":U THEN DO:
            For each gds-list  no-lock :
                run report-exec1.
                HIDE STREAM OutStream FRAME ZAPAS .
            End.
        End.
      When  "prod":U THEN DO:
            For each gds-list no-lock break by gds-list.prod-type by gds-list.prod-code   :
                if first-of (gds-list.prod-code) Then
                run subtit-prod (1).
                run report-exec1.
                HIDE STREAM OutStream FRAME ZAPAS .
                accumulate  tot-qnty            (total by  gds-list.prod-code by gds-list.prod-type) .
                accumulate  tot-SumSALE         (total by  gds-list.prod-code by gds-list.prod-type) .
                accumulate tot-SumCOST          (total by  gds-list.prod-code by gds-list.prod-type) .
                accumulate tot-SumCRSA          (total by  gds-list.prod-code by gds-list.prod-type) .
                accumulate tot-discnt-sum       (total by  gds-list.prod-code by gds-list.prod-type) .
                accumulate tot-ov-sum           (total by  gds-list.prod-code by gds-list.prod-type) .
                accumulate tot-VAT-Sum          (total by  gds-list.prod-code by gds-list.prod-type) .
                accumulate tot-SLT-sum          (total by  gds-list.prod-code by gds-list.prod-type) .
                if last-of (gds-list.prod-code) Then
                DO:
                  s#1 = accum total by gds-list.prod-code tot-qnty.
                  s#2 = accum total by gds-list.prod-code tot-SumSALE.
                  s#3 = accum total by gds-list.prod-code tot-SumCOST.
                  s#4 = accum total by gds-list.prod-code tot-SumCRSA .
                  s#5 = accum total by gds-list.prod-code tot-discnt-sum .
                  s#6 = accum total by gds-list.prod-code tot-ov-sum .
                  s#7 = accum total by gds-list.prod-code tot-VAT-Sum.
                  s#8 = accum total by gds-list.prod-code tot-SLT-sum.
                  if not (s#1 = 0 and
                          s#2 = 0 and
                          s#3 = 0 and
                          s#4 = 0 and
                          s#5 = 0 and
                          s#6 = 0 and
                          s#7 = 0 and
                          s#8 = 0) then  run subfoot-prod (1).
                  End.
            End.           End.
      When  "grp-goods":U  Then Do:
            For each gds-list no-lock break by gds-list.grp-name  :
                if first-of (gds-list.grp-name) Then
                run subtit-grp (1).
                run report-exec1.
                HIDE STREAM OutStream FRAME ZAPAS .
                accumulate tot-qnty             (total by  gds-list.grp-name) .
                accumulate tot-SumSALE          (total by  gds-list.grp-name) .
                accumulate tot-SumCOST          (total by  gds-list.grp-name) .
                accumulate tot-SumCRSA          (total by  gds-list.grp-name) .
                accumulate tot-discnt-sum       (total by  gds-list.grp-name) .
                accumulate tot-ov-sum           (total by  gds-list.grp-name) .
                accumulate tot-VAT-Sum          (total by  gds-list.grp-name) .
                accumulate tot-SLT-sum          (total by  gds-list.grp-name) .
                if last-of (gds-list.grp-name) Then DO:
                            s1 = accum total by gds-list.grp-name tot-qnty.
                            s2 = accum total by gds-list.grp-name tot-SumSALE.
                            s3 = accum total by gds-list.grp-name tot-SumCOST.
                            s4 = accum total by gds-list.grp-name tot-SumCRSA .
                            s5 = accum total by gds-list.grp-name tot-discnt-sum .
                            s6 = accum total by gds-list.grp-name tot-ov-sum .
                            s7 = accum total by gds-list.grp-name tot-VAT-Sum.
                            s8 = accum total by gds-list.grp-name tot-SLT-sum.
                  if not (s1 = 0 and
                          s2 = 0 and
                          s3 = 0 and
                          s4 = 0 and
                          s5 = 0 and
                          s6 = 0 and
                          s7 = 0 and
                          s8 = 0 ) then run subfoot-grp (1).
            End.            End.
          end.
      When  "prod/grp-goods":U Then DO:
            for each gds-list no-lock  break by gds-list.prod-type by gds-list.prod-code  by gds-list.grp-name:
                if first-of (gds-list.prod-code) then run subtit-prod (1).
                if first-of (gds-list.grp-name)  then
                   if not sums-only  then run subtit-grp (2).
                run report-exec1.
                hide stream outstream frame zapas .
                  s#1 = s#1 + tot-qnty.          s1 = s1 + tot-qnty.
                  s#2 = s#2 + tot-SumSALE.       s2 = s2 + tot-SumSALE.
                  s#3 = s#3 + tot-SumCOST.       s3 = s3 + tot-SumCOST.
                  s#4 = s#4 + tot-SumCRSA .      s4 = s4 + tot-SumCRSA .
                  s#5 = s#5 + tot-discnt-sum .   s5 = s5 + tot-discnt-sum .
                  s#6 = s#6 + tot-ov-sum .       s6 = s6 + tot-ov-sum .
                  s#7 = s#7 + tot-VAT-Sum.       s7 = s7 + tot-VAT-Sum.
                  s#8 = s#8 + tot-SLT-sum.       s8 = s8 + tot-SLT-sum.
                if last-of (gds-list.grp-name)  Then DO:
                  if not (s1 = 0 and
                          s2 = 0 and
                          s3 = 0 and
                          s4 = 0 and
                          s5 = 0 and
                          s6 = 0 and
                          s7 = 0 and
                          s8 = 0 ) then run subfoot-grp (2).
                  Assign s1 = 0 s2 = 0 s3 = 0  s4 = 0  s5 = 0 s6 = 0 s7 = 0 s8 = 0.
                End.
                if last-of (gds-list.prod-code) Then DO:
                  if not (s#1 = 0 and
                          s#2 = 0 and
                          s#3 = 0 and
                          s#4 = 0 and
                          s#5 = 0 and
                          s#6 = 0 and
                          s#7 = 0 and
                          s#8 = 0 ) then  run subfoot-prod (1).
                  Assign s#1 = 0 s#2 = 0 s#3 = 0  s#4 = 0  s#5 = 0 s#6 = 0 s#7 = 0 s#8 = 0.
                  End.
            End.           End.
      When  "grp-goods/prod":U Then DO:
            For each gds-list no-lock  break  by gds-list.grp-name   by gds-list.prod-type by gds-list.prod-code :
                if first-of (gds-list.grp-name)  then run subtit-grp (1).
                if first-of (gds-list.prod-code) then
                   if not sums-only  then run subtit-prod (2).
                run report-exec1.
                hide stream outstream frame zapas .
                  s#1 = s#1 + tot-qnty.          s1 = s1 + tot-qnty.
                  s#2 = s#2 + tot-SumSALE.       s2 = s2 + tot-SumSALE.
                  s#3 = s#3 + tot-SumCOST.       s3 = s3 + tot-SumCOST.
                  s#4 = s#4 + tot-SumCRSA .      s4 = s4 + tot-SumCRSA .
                  s#5 = s#5 + tot-discnt-sum .   s5 = s5 + tot-discnt-sum .
                  s#6 = s#6 + tot-ov-sum .       s6 = s6 + tot-ov-sum .
                  s#7 = s#7 + tot-VAT-Sum.       s7 = s7 + tot-VAT-Sum.
                  s#8 = s#8 + tot-SLT-sum.       s8 = s8 + tot-SLT-sum.
                if last-of (gds-list.prod-code) Then DO:
                  if not (s#1 = 0 and
                          s#2 = 0 and
                          s#3 = 0 and
                          s#4 = 0 and
                          s#5 = 0 and
                          s#6 = 0 and
                          s#7 = 0 and
                          s#8 = 0 ) then  run subfoot-prod (2).
                  assign s#1 = 0 s#2 = 0 s#3 = 0  s#4 = 0  s#5 = 0 s#6 = 0 s#7 = 0 s#8 = 0.
                  end.
                  if last-of (gds-list.grp-name)  then do:
                  if not (s1 = 0 and
                          s2 = 0 and
                          s3 = 0 and
                          s4 = 0 and
                          s5 = 0 and
                          s6 = 0 and
                          s7 = 0 and
                          s8 = 0 ) then run subfoot-grp (1).
                    Assign s1 = 0 s2 = 0 s3 = 0  s4 = 0  s5 = 0 s6 = 0 s7 = 0 s8 = 0.
                    End.
                End.   End.
      When  "sort":U THEN DO:
            For each gds-list no-lock break by gds-list.sort   :
                if first-of (gds-list.sort) Then
                    if not sums-only  then run subtit-vat-sort (1).
                run report-exec1.
                hide stream outstream frame zapas .
                accumulate  tot-qnty            (total by  gds-list.sort) .
                accumulate  tot-sumsale         (total by  gds-list.sort) .
                accumulate tot-sumcost          (total by  gds-list.sort) .
                accumulate tot-sumcrsa          (total by  gds-list.sort) .
                accumulate tot-discnt-sum       (total by  gds-list.sort) .
                accumulate tot-ov-sum           (total by  gds-list.sort) .
                accumulate tot-vat-sum          (total by  gds-list.sort) .
                accumulate tot-slt-sum          (total by  gds-list.sort) .
                if last-of (gds-list.sort) Then
                DO:
                  s#1 = accum total by gds-list.sort tot-qnty.
                  s#2 = accum total by gds-list.sort tot-SumSALE.
                  s#3 = accum total by gds-list.sort tot-SumCOST.
                  s#4 = accum total by gds-list.sort tot-SumCRSA .
                  s#5 = accum total by gds-list.sort tot-discnt-sum .
                  s#6 = accum total by gds-list.sort tot-ov-sum .
                  s#7 = accum total by gds-list.sort tot-VAT-Sum.
                  s#8 = accum total by gds-list.sort tot-SLT-sum.
                  if not (s#1 = 0 and
                          s#2 = 0 and
                          s#3 = 0 and
                          s#4 = 0 and
                          s#5 = 0 and
                          s#6 = 0 and
                          s#7 = 0 and
                          s#8 = 0 ) then  run subfoot-vat-sort (1).
                  End.
            End.           End.
      When  "vat-ps":U THEN DO:
            For each gds-list no-lock ,
               first ub.gds-obj where
                     ub.gds-obj.gds-code = gds-list.gds-code and
                     ub.gds-obj.obj-code = x-store-code and
                     ub.gds-obj.obj-type = x-store-type
                     :
                gds-list.qnty = (func-vat(gds-obj.gds-code,gds-obj.obj-type,gds-obj.obj-code)) .
             end.
            For each gds-list no-lock , first ub.gds-obj where ub.gds-obj.gds-code = gds-list.gds-code and
                ub.gds-obj.obj-code = x-store-code and
                ub.gds-obj.obj-type = x-store-type
            break by gds-list.qnty   :
                if first-of (gds-list.qnty) Then run subtit-vat-sort (2).
                Run report-exec1.
                HIDE STREAM OutStream FRAME ZAPAS .
                accumulate tot-qnty             (total by  gds-list.qnty) .
                accumulate tot-SumSALE          (total by  gds-list.qnty) .
                accumulate tot-SumCOST          (total by  gds-list.qnty) .
                accumulate tot-SumCRSA          (total by  gds-list.qnty) .
                accumulate tot-discnt-sum       (total by  gds-list.qnty) .
                accumulate tot-ov-sum           (total by  gds-list.qnty) .
                accumulate tot-VAT-Sum          (total by  gds-list.qnty) .
                accumulate tot-SLT-sum          (total by  gds-list.qnty) .
                if last-of (gds-list.qnty) Then
                DO:
                  s#1 = accum total by gds-list.qnty tot-qnty.
                  s#2 = accum total by gds-list.qnty tot-SumSALE.
                  s#3 = accum total by gds-list.qnty tot-SumCOST.
                  s#4 = accum total by gds-list.qnty tot-SumCRSA .
                  s#5 = accum total by gds-list.qnty tot-discnt-sum .
                  s#6 = accum total by gds-list.qnty tot-ov-sum .
                  s#7 = accum total by gds-list.qnty tot-VAT-Sum.
                  s#8 = accum total by gds-list.qnty tot-SLT-sum.
                  if not (s#1 = 0 and
                          s#2 = 0 and
                          s#3 = 0 and
                          s#4 = 0 and
                          s#5 = 0 and
                          s#6 = 0 and
                          s#7 = 0 and
                          s#8 = 0 ) then run subfoot-vat-sort (2).
                  End.
            End.           End.
      End case.
  End.
  HIDE STREAM OutStream FRAME top-Frame .
  Output stream OutStream close.
  DELETE WIDGET-POOL "qq".
if mFrameView
then do:
   HIDE FRAME InfoFrame.
end.
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
    ,input ReportFontNum
    ,output v-user-action
    ,output v-printed
    ) .
END PROCEDURE.
PROCEDURE display-line :
   i = i + 1.
   v-ii = v-ii + 1.
IF ( v-ii modulo v-account = 0 )  then DO:
 Assign
    v-kol-spice = (50 - LENGTH(reportname)) / 2
    RecordsString = fill(' ',v-kol-spice) + string(reportname)
    .
 Assign
    v-kol-spice = (50 - LENGTH(ObjName)) / 2
    RecordsString2 = fill(' ',v-kol-spice) + string(ObjName)
    .
          if  log-manager:logfile-name ne ?
          then DO:
              log-manager:write-message("DISP mFrameView=" + string(mFrameView), "frameRepError").
          end.
           if mFrameView
           then do:
            DISPLAY
              v-ii @ RecordsDone
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
  if NOT (xtype begins "all") OR
    entry(2,xtype) = "no"    then DO:
           DISPLAY stream  OutStream sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12 sym13
           fact-date  @  F-fact-date
           type-doc   @  f-type-doc
           doc-code   @  f-doc-code
           cli-name   @  f-cli-name
           qnty       @  F-qnty
           SumSALE    @  f-SumSALE
           SumCOST when (cc = true )    @  f-SumCOST
           SumCRSA    @  f-SumCRSA
           discnt-sum @  f-discnt-sum
           ov-sum      when ( NO-PRISE = true ) @  f-ov-sum
           VAT_pc     @  F-VAT_pc
           VAT-Sum    @  f-VAT-Sum
           SLT_pc     @  F-SLT_pc
           SLT-sum    @  f-SLT-sum
           with FRAME ZAPAS . DOWN stream   OutStream 1 with FRAME ZAPAS.
           End.
END PROCEDURE.
PROCEDURE print-header :
   If xtype begins "all":U OR xtype = "goods":U  Then  run display-title-mgds.
   i = 0.
    If NOT (xtype begins "all":U) Then DO:
        run display-title.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
CASE "1" :
WHEN  "1" then
TEMPSTR =  string( "Остаток на начало периода (" + string( startdate, "99/99/9999" ) + ")" )   .
WHEN "2" then
TEMPSTR = string( "Остаток на конец периода (" + string( enddate, "99/99/9999" ) + ")" )  .
OTHERWISE
TEMPSTR =string( "Оборот с " + string( startdate, "99/99/9999" ) + " по " + string( enddate, "99/99/9999" ) )  .
end CASE.
PUT STREAM OutStream
SKIP
SPACE(5)
TEMPSTR format "x(72)"
SKIP
SPACE(32) string( "Количество: " + trim( string( Quantity1, "->>>,>>>,>>9.<<<" ) ) ) format "x(72)"
SKIP.
IF PayType = 2 OR PayType = 0  then do:
define variable vss-include-info19 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
if  v-log = true  then
PUT STREAM OutStream
SPACE(23) string( "Cумма   УЧЕТНЫХ  цен: " +
            trim( string( Coast1 , "->>>,>>>,>>>,>>>,>>9.99" ) ) + " " +
            curr-rep
          ) format "x(72)"
          SKIP.
PUT STREAM OutStream
SPACE(23) string( "Cумма УЧЕТНЫХ цен без НДС: " +
     trim( string( (Coast1 - Coast-vat1  ) , "->>>,>>>,>>>,>>>,>>9.99" ) ) + " " +
     curr-rep
     ) format "x(72)"
     SKIP.
end.
Else   PUT STREAM OutStream
SPACE(23) string(  "Cумма ПРОДАЖНЫХ цен: " +
            trim( string( Coast1, "->>>,>>>,>>>,>>>,>>9.99" ) ) + " " +
            curr-rep
          ) format "x(72)"
          SKIP.
.
        if no-prise then do:
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PUT STREAM OutStream
SPACE(23)
string( "Cумма ПРОДАЖНЫХ цен: " +
              trim( string( Coast3, "->>>,>>>,>>>,>>>,>>9.99" ) ) + " " +
              curr-rep
            ) format "x(72)"
  SKIP
  .
  end.
        if xtype =  "" then  do: display stream outstream  with frame top-frame . end.
    End.
END PROCEDURE.
PROCEDURE Print-Footer :
IF NOT ( tot-qnty       = 0  and
   tot-SumSALE    = 0  and
   tot-SumCOST    = 0  and
   tot-SumCRSA    = 0  and
   tot-discnt-sum = 0  and
   tot-ov-sum     = 0  and
   tot-VAT-Sum    = 0  and
   tot-SLT-sum    = 0 ) Then do:
      DISPLAY stream  OutStream sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12 sym13
           "ИТОГО"  @  F-fact-date
           gds-list.artic     @  f-doc-code
           gds-list.gds-name  @  f-cli-name
           tot-qnty       @  F-qnty
           tot-SumSALE    @  f-SumSALE
           tot-SumCOST  when (cc = true )   @  f-SumCOST
           tot-SumCRSA    @  f-SumCRSA
           tot-discnt-sum @  f-discnt-sum
           tot-ov-sum  when (NO-PRISE = true )   @  f-ov-sum
           ""     @  F-VAT_pc
           tot-VAT-Sum    @  f-VAT-Sum
           ""     @  F-SLT_pc
           tot-SLT-sum    @  f-SLT-sum
           with FRAME ZAPAS . DOWN stream   OutStream 1 with FRAME ZAPAS.
End.
 If NOT (xtype begins "all":U) Then DO:
        Quantity = Quantity2 - Quantity1.
        Coast = Coast2 - Coast1 .
        Coast-vat = Coast-vat2 - Coast-vat1 .
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
CASE "" :
WHEN  "1" then
TEMPSTR =  string( "Остаток на начало периода (" + string( startdate, "99/99/9999" ) + ")" )   .
WHEN "2" then
TEMPSTR = string( "Остаток на конец периода (" + string( enddate, "99/99/9999" ) + ")" )  .
OTHERWISE
TEMPSTR =string( "Оборот с " + string( startdate, "99/99/9999" ) + " по " + string( enddate, "99/99/9999" ) )  .
end CASE.
PUT STREAM OutStream
SKIP
SPACE(5)
TEMPSTR format "x(72)"
SKIP
SPACE(32) string( "Количество: " + trim( string( Quantity, "->>>,>>>,>>9.<<<" ) ) ) format "x(72)"
SKIP.
IF PayType = 2 OR PayType = 0  then do:
define variable vss-include-info22 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
if  v-log = true  then
PUT STREAM OutStream
SPACE(23) string( "Cумма   УЧЕТНЫХ  цен: " +
            trim( string( Coast , "->>>,>>>,>>>,>>>,>>9.99" ) ) + " " +
            curr-rep
          ) format "x(72)"
          SKIP.
PUT STREAM OutStream
SPACE(23) string( "Cумма УЧЕТНЫХ цен без НДС: " +
     trim( string( (Coast - Coast-vat  ) , "->>>,>>>,>>>,>>>,>>9.99" ) ) + " " +
     curr-rep
     ) format "x(72)"
     SKIP.
end.
Else   PUT STREAM OutStream
SPACE(23) string(  "Cумма ПРОДАЖНЫХ цен: " +
            trim( string( Coast, "->>>,>>>,>>>,>>>,>>9.99" ) ) + " " +
            curr-rep
          ) format "x(72)"
          SKIP.
.
        Coast = Coast4 - Coast3 .
        Coast-vat = Coast-vat4 - Coast-vat3 .
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PUT STREAM OutStream
SPACE(23)
string( "Cумма ПРОДАЖНЫХ цен: " +
              trim( string( Coast, "->>>,>>>,>>>,>>>,>>9.99" ) ) + " " +
              curr-rep
            ) format "x(72)"
  SKIP
  .
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
CASE "2" :
WHEN  "1" then
TEMPSTR =  string( "Остаток на начало периода (" + string( startdate, "99/99/9999" ) + ")" )   .
WHEN "2" then
TEMPSTR = string( "Остаток на конец периода (" + string( enddate, "99/99/9999" ) + ")" )  .
OTHERWISE
TEMPSTR =string( "Оборот с " + string( startdate, "99/99/9999" ) + " по " + string( enddate, "99/99/9999" ) )  .
end CASE.
PUT STREAM OutStream
SKIP
SPACE(5)
TEMPSTR format "x(72)"
SKIP
SPACE(32) string( "Количество: " + trim( string( Quantity2, "->>>,>>>,>>9.<<<" ) ) ) format "x(72)"
SKIP.
IF PayType = 2 OR PayType = 0  then do:
define variable vss-include-info25 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
if  v-log = true  then
PUT STREAM OutStream
SPACE(23) string( "Cумма   УЧЕТНЫХ  цен: " +
            trim( string( Coast2 , "->>>,>>>,>>>,>>>,>>9.99" ) ) + " " +
            curr-rep
          ) format "x(72)"
          SKIP.
PUT STREAM OutStream
SPACE(23) string( "Cумма УЧЕТНЫХ цен без НДС: " +
     trim( string( (Coast2 - Coast-vat2  ) , "->>>,>>>,>>>,>>>,>>9.99" ) ) + " " +
     curr-rep
     ) format "x(72)"
     SKIP.
end.
Else   PUT STREAM OutStream
SPACE(23) string(  "Cумма ПРОДАЖНЫХ цен: " +
            trim( string( Coast2, "->>>,>>>,>>>,>>>,>>9.99" ) ) + " " +
            curr-rep
          ) format "x(72)"
          SKIP.
.
      if NO-PRISE Then DO:
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PUT STREAM OutStream
SPACE(23)
string( "Cумма ПРОДАЖНЫХ цен: " +
              trim( string( Coast4, "->>>,>>>,>>>,>>>,>>9.99" ) ) + " " +
              curr-rep
            ) format "x(72)"
  SKIP
  .
   End.
   End.
END PROCEDURE.
PROCEDURE U-LINE :
UNDERLINE stream OutStream  sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12 Sym13 sym17
F-fact-date
f-type-doc
f-doc-code
f-cli-name
F-qnty
f-SumSALE
f-SumCOST
f-SumCRSA
f-discnt-sum
f-ov-sum
F-VAT_pc
F-VAT-Sum
F-SLT_pc
F-SLT-sum
sym14 when  (h-kol-1 <> ?)
sym15 when  (h-kol-1 <> ?)
sym16 when  (h-kol-1 <> ?)
with FRAME ZAPAS .
DOWN stream   OutStream 1 with FRAME ZAPAS.
END PROCEDURE.
PROCEDURE P-LINE :
UNDERLINE stream OutStream        with FRAME ZAPAS.        DOWN stream   OutStream 1 with FRAME ZAPAS .
END PROCEDURE.
PROCEDURE CalcItog :
    run ostatok (
        input x-store-code  ,
        input x-store-type  ,x-TOG-Shift,
        input x-date-start - 1 ,
        input date('')      ,  x-Shift-Start,x-Shift-End,
        input 'crsa':U   ,
        input '##,##':U,
        input true ,
        output  Quantity1  ,
        output  Coast_R1   ,
        output  Coast_V1   ,
        output  VAT_R1     ,
        output  VAT_V1     ,
        output  Fact-order-1 ).
    run ostatok (
        input x-store-code  ,
        input x-store-type  ,x-TOG-Shift,
        input x-date-start  ,
        input x-date-end    ,  x-Shift-Start,x-Shift-End,
        input 'crsa':U   ,
        input '##,##':U,
        input true ,
        output  Quantity1  ,
        output  Coast_R1   ,
        output  Coast_V1   ,
        output  VAT_R1     ,
        output  VAT_V1     ,
        output  Fact-order-2 ).
    if xtog-inv and inv-fact-order > 0 then  Fact-order-1 = inv-fact-order.
    run ost-line (
        input x-store-code  ,
        input x-store-type  ,
        input gds-list.artic       ,
        input gds-list.prod-code   ,
        input gds-list.prod-type    ,
        input x-TOG-Shift ,
        input Fact-order-1 ,
        input 'cost':U   ,
        input '##,##':U,
        input YES ,
        output  Quantity1  ,
        output  Coast_R1   ,
        output  Coast_V1   ,
        output  VAT_R1     ,
        output  VAT_V1     ,
        output  slt_R1     ,
        output  slt_V1     ).
        Coast1 =  IF tPrintRubl then  Coast_R1
                                else  Coast_V1 .
        Coast-vat1 =  IF tPrintRubl then  vat_R1
                                    else  vat_V1 .
        run ost-line (
        input x-store-code  ,
        input x-store-type  ,
        input gds-list.artic       ,
        input gds-list.prod-code   ,
        input gds-list.prod-type   ,
        input x-TOG-Shift ,
        input Fact-order-1 ,
        input 'crsa':U   ,
        input '##,##':U,
        input YES ,
        output  Quantity1  ,
        output  Coast_R1   ,
        output  Coast_V1   ,
        output  VAT_R1     ,
        output  VAT_V1     ,
        output  slt_R1     ,
        output  slt_V1     ).
        Coast3 =  IF tPrintRubl then  Coast_R1
                                else  Coast_V1 .
        Coast-vat3 =  IF tPrintRubl then  vat_R1
                                    else  vat_V1 .
define variable Quantity2-1 as decimal   no-undo .
    run ost-line (
        input x-store-code  ,
        input x-store-type  ,
        input gds-list.artic       ,
        input gds-list.prod-code   ,
        input gds-list.prod-type    ,
        input x-TOG-Shift ,
        input Fact-order-2 ,
        input 'cost':U   ,
        input '##,##':U,
        input YES ,
        output  Quantity2  ,
        output  Coast_R2   ,
        output  Coast_V2   ,
        output  VAT_R2     ,
        output  VAT_V2     ,
        output  slt_R1     ,
        output  slt_V1     ).
        Coast2 =  IF tPrintRubl then  Coast_R2
                                else  Coast_V2 .
        Coast-vat2 =  IF tPrintRubl then  vat_R2
                                else  vat_V2 .
    run ost-line (
        input x-store-code  ,
        input x-store-type  ,
        input gds-list.artic       ,
        input gds-list.prod-code   ,
        input gds-list.prod-type    ,
        input x-TOG-Shift ,
        input Fact-order-2 ,
        input 'crsa':U   ,
        input '##,##':U,
        input YES ,
        output  Quantity2-1  ,
        output  Coast_R2   ,
        output  Coast_V2   ,
        output  VAT_R2     ,
        output  VAT_V2     ,
        output  slt_R1     ,
        output  slt_V1     ).
        Coast4 =  IF tPrintRubl then  Coast_R2
                                else  Coast_V2 .
        Coast-vat4 =  IF tPrintRubl then  vat_R2
                                else  vat_V2 .
END PROCEDURE.
PROCEDURE Display-main-title :
   PUT stream  OutStream  UNFORMATTED  string( v-cntxt-host-name-obj +  " , " + x-store-type  +  " " + ObjName) AT 50 format "X(85)" SKIP(2)
          REPORTNAME  AT 20 format "X(170)" SKIP
          Trim(str1)  AT 35 format "X(75)" SKIP.
End procedure.
PROCEDURE Display-title :
     PUT stream  OutStream  UNFORMATTED "Товар  : "
              + gds-list.artic + " "
              + gds-list.gds-name
              AT 1 format "X(170)" SKIP.
     Repeat i = 1 to NUM-ENTRIES(ReportHeader,chr(10)) :
      PUT stream  OutStream  UNFORMATTED  Entry(i,ReportHeader,chr(10))  AT 1 format "X(170)" SKIP.
     End.
    if xtog-inv and inv-fact-order > 0  then do:
            PUT stream  OutStream  UNFORMATTED  inv-str AT 1 format "X(170)" SKIP. end.
    i=0.
END PROCEDURE.
PROCEDURE Display-object :
   FIND FIRST ub.clients where x-store-type = ub.clients.obj-type AND
                            x-store-code = ub.clients.obj-code no-lock no-error.
           If available ub.clients then  ObjName = ub.clients.obj-name.
                                         else  ObjName="объект не определен".
     if xtype <> "" then  do:
     display STREAM OutStream  with frame top-Frame .
     run U-line.
     End.
     PUT stream  OutStream  UNFORMATTED  "Объект  : " + ObjName FORMAT "X(170)" skip.
end procedure.
PROCEDURE Display-title-mgds :
     PUT stream  OutStream  UNFORMATTED  "Товар  : " + gds-list.artic + " " + gds-list.gds-name + " " +  gds-list.PS  + " (" + gds-list.sort  + "*)"
                 AT 1 format "X(198)" .
     if xtog-inv and inv-fact-order > 0  then do : PUT stream  OutStream  UNFORMATTED  inv-str AT 1 format "X(170)". end.
     PUT stream  OutStream  UNFORMATTED  SKIP.
     run u-line.
     i = 0.
END PROCEDURE.
PROCEDURE ob-line  :
define input  parameter x-store-code     like ub.clients.obj-code     no-undo.
define input  parameter x-store-type     like ub.clients.obj-type     no-undo.
define INPUT  parameter x-artic          like ub.ot-line.artic        no-undo.
define INPUT  parameter x-prod-code      like ub.ot-line.prod-code    no-undo.
define INPUT  parameter x-prod-type      like ub.ot-line.prod-type    no-undo.
define INPUT  parameter x-Fact-order-1   like ub.ot-line.Fact-order   no-undo.
define INPUT  parameter x-Fact-order-2   like ub.ot-line.Fact-order   no-undo.
define input  parameter x-sum-type       like ub.ot-line.sum-type     no-undo.
define input  parameter x-cat-id         like ub.ot-line.cat-id       no-undo.
define input  parameter x-ext-doc-type   like ub.ot-line.ext-doc-type no-undo.
define input  parameter xTog-obj         as   log                  no-undo.
 define variable v-total-parts-qnty           like ub.parts.qnty      no-undo .   define variable v-total-parts-fact-qnty      like ub.parts.fact-qnty no-undo .   define variable v-total-parts-cli-qnty       like ub.parts.cli-qnty  no-undo .   define variable v-total-parts-fact-cli-qnty  like ub.parts.cli-qnty  no-undo .   define variable v-total-parts-price-cli      as decimal no-undo .   define variable v-total-parts-price-base     as decimal no-undo .   define variable v-total-parts-price-rubl     as decimal no-undo .   define variable v-total-parts-transport-base as decimal no-undo .   define variable v-total-parts-transport-rubl as decimal no-undo .   define variable v-total-parts-other-base     as decimal no-undo .   define variable v-total-parts-other-rubl     as decimal no-undo .
 FOR each ub.ot-line
                   where ub.ot-line.artic        = x-artic
                  AND   ub.ot-line.fact-order   <= x-fact-order-2
                  AND   ub.ot-line.fact-order   >= x-fact-order-1
                  AND   ub.ot-line.prod-code     = x-prod-code
                  AND   ub.ot-line.prod-type     = x-prod-type
                  AND   ub.ot-line.obj-code      = x-store-code
                  AND   ub.ot-line.obj-type      = x-store-type
                  AND   (ub.ot-line.sum-type     = 'crsa':U OR ub.ot-line.sum-type = 'cgsr':U)
                  And   ((x-ext-doc-type = 'все':U) OR (ub.ot-line.ext-doc-type  = x-ext-doc-type ))
                        no-lock break by ub.ot-line.artic  :
         Find First ot-line-Cost where
                        ot-line-Cost.artic        = x-artic
                  AND   ot-line-Cost.fact-order   = ub.ot-line.fact-order
                  AND   ot-line-Cost.obj-code     = ub.ot-line.obj-code
                  AND   ot-line-Cost.obj-type     = ub.ot-line.obj-type
                  AND   ot-line-Cost.prod-code    = x-prod-code
                  AND   ot-line-Cost.prod-type    = x-prod-type
                  AND   (ot-line-Cost.sum-type    = 'cost':U OR ot-line-cost.sum-type = 'cssr':U)
                  And   ot-line-Cost.doc-code     = ub.ot-line.doc-code
                    no-lock use-Index pi  no-error.
        Find First ot-line-Sale where
                        ot-line-Sale.artic        = x-artic
                  AND   ot-line-Sale.fact-order   = ub.ot-line.fact-order
                  AND   ot-line-Sale.obj-code     = ub.ot-line.obj-code
                  AND   ot-line-Sale.obj-type     = ub.ot-line.obj-type
                  AND   ot-line-Sale.prod-code    = x-prod-code
                  AND   ot-line-Sale.prod-type    = x-prod-type
                  AND   (ot-line-Sale.sum-type    = 'sale':U OR ot-line-sale.sum-type = 'sasr':U)
                  And   ot-line-Sale.doc-code     = ub.ot-line.doc-code
                    no-lock use-Index pi  no-error.
          Assign
            doc-code   = ub.ot-line.doc-code
            qnty       = ub.ot-line.fact-qnty
            .
           If ub.ot-line.ext-doc-type  <> 'ot':U Then DO:
                  Find Last ub.trn-doc  where ub.trn-doc.doc-code = ub.ot-line.doc-code no-lock no-error.
                    If Available ub.trn-doc then DO:
                    Find First ub.doc-line  where ub.trn-doc.doc-code = ub.doc-line.doc-code
                  AND   ub.doc-line.prod-code    = x-prod-code
                  AND   ub.doc-line.prod-type    = x-prod-type
                  AND   ub.doc-line.artic        = x-artic   no-lock no-error.
                    Assign
                    type-doc   =  ub.trn-doc.doc-type
                    fact-date  =  ub.trn-doc.fact-date
                    cli-name   =  ub.trn-doc.cli-name
                    discnt-sum = if avail ot-line-Sale then
                                 ( if tPrintRubl then ot-line-Sale.other-rubl
                                                Else ot-line-Sale.other-base )
                                  Else 0
                    .
                    if  ub.ot-line.ext-doc-type  = 'vt':U or ub.ot-line.ext-doc-type  = 'vp':U Then DO:
                        Assign  discnt-sum = 0  .
                        End.
                    End.
                  End.
              Else DO:
                  Find Last ub.price-doc where ub.price-doc.doc-num = ub.ot-line.doc-code no-lock no-error.
                  If Available ub.price-doc then
                    Assign
                    type-doc   = 'пер'
                    fact-date  = ub.price-doc.fact-date
                    cli-name   =  ""
                    discnt-sum = 0
                    qnty       = if available ot-line-Cost then ot-line-Cost.fact-qnty else 0
                    .
              End.
     If Available ot-line-sale Then
       Assign
                SumSALE    = if tPrintRubl then ot-line-sale.sum-rubl else ot-line-sale.sum-base
                VAT-Sum    = if tPrintRubl then ot-line-sale.VAT-rubl else ot-line-sale.VAT-base
                SLT-sum    = if tPrintRubl then ot-line-sale.SLT-rubl else ot-line-sale.SLT-base
                VAT_pc     = (Entry(1,ot-line-sale.cat-id))
                SLT_pc     = (Entry(2,ot-line-sale.cat-id))
              .
         Else
               Assign
                SumSALE    = 0
                VAT-Sum    = if tPrintRubl then ub.ot-line.VAT-rubl else ub.ot-line.VAT-base
                SLT-sum    = if tPrintRubl then ub.ot-line.SLT-rubl else ub.ot-line.SLT-base
                VAT_pc     = (Entry(1,ot-line.cat-id))
                SLT_pc     = (Entry(2,ot-line.cat-id))
              .
     If Available ot-line-cost Then
        SumCOST    = if tPrintRubl then ot-line-cost.sum-rubl else ot-line-cost.sum-base.
         Else  SumCOST    = 0.
     Assign
     SumCRSA    = if tPrintRubl then ub.ot-line.sum-rubl else ub.ot-line.sum-base
     .
     If (ub.ot-line.ext-doc-type  = 'ot':U  OR
         ub.ot-line.ext-doc-type  = 'vt':U       OR
         ub.ot-line.ext-doc-type  = 'vp':U  )
        Then ov-sum      = 0.
        Else ov-sum      = SumCRSA   - discnt-sum - SumSALE.
  Assign qnty-1 = 0   qnty-2 = 0 .
  IF  tow-unit = true THEN DO :
       FIND FIRST ub.units no-LOCK WHERE  ub.units.unit-name = gds-list.unit-base No-ERROR.
       define variable var1 as integer no-undo .
     var1 = 0 .
     IF  LOOKUP('2ед':U, ub.units.type ) > 0  THEN  var1 = 1.
     IF  LOOKUP('доп':U, ub.units.type) > 0   THEN  var1 = 2.
    CASE var1:
        when 0 then DO : Assign qnty-1 = 0   qnty-2 = 0 .                              End.
        when 1 then DO :  If avail ub.doc-line then
                          run partrqst in this-procedure
                            (input  ub.doc-line.doc-code
                            ,input  ub.doc-line.obj-type
                            ,input  ub.doc-line.obj-code
                            ,input  ub.doc-line.artic
                            ,input  ub.doc-line.prod-type
                            ,input  ub.doc-line.prod-code
                                                        ,output v-total-parts-qnty   ,output v-total-parts-fact-qnty   ,output v-total-parts-cli-qnty   ,output v-total-parts-fact-cli-qnty   ,output v-total-parts-price-cli   ,output v-total-parts-price-base   ,output v-total-parts-price-rubl   ,output v-total-parts-transport-base   ,output v-total-parts-transport-rubl   ,output v-total-parts-other-base   ,output v-total-parts-other-rubl
                            ).
                            Assign qnty-1 = (If avail ub.doc-line
                                            then  (If  qnty  = 0 Then 0
                                                       Else (If  qnty  < 0
                                                                Then (-1) * ABSOLUTE(v-total-parts-fact-cli-qnty)
                                                                Else v-total-parts-fact-cli-qnty)
                                                   )
                                            else  0)
                                   qnty-2 = qnty .
                    End.
        when 2 then DO : Assign qnty-1 = qnty
                                qnty-2 = gds-list.wt-cart * qnty-1.
                   End.
    End.
     IF h-kol-1 <> ?  THEN h-kol-1:screen-value =  string(qnty-1)  .
     IF h-kol-2 <> ?  THEN h-kol-2:screen-value =  string(qnty-2)  .
     ov-sum      = SumCRSA   - discnt-sum - SumSALE.
     If ub.ot-line.ext-doc-type  = 'ot':U Then ov-sum = 0.
End.
    Assign
        TOT-SumCRSA    = TOT-SumCRSA + SumCRSA
        TOT-VAT-Sum    = TOT-VAT-Sum + VAT-Sum
        TOT-SLT-sum    = TOT-SLT-sum + SLT-sum
        TOT-SumCOST    = TOT-SumCOST + SumCOST
        TOT-SumSALE    = TOT-SumSALE + SumSALE
        TOT-discnt-sum = TOT-discnt-sum + discnt-sum
        TOT-ov-sum     = TOT-ov-sum     + ov-sum    .
       TOT-qnty  = TOT-qnty  + qnty .
 if first-of(ub.ot-line.artic)  then DO:
      if not sums-only then run print-header.
  End.
  run display-line in this-procedure .
End.
END PROCEDURE.
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
PROCEDURE report-exec1  :
        if xtog-inv then DO:
          For each ub.trn-doc where
            ub.trn-doc.doc-type = 'инв':U and
            ub.trn-doc.ext-doc-type = 'vt':U and
            ub.trn-doc.fact-date >= startdate and
            ub.trn-doc.obj-code   = x-store-code and
            ub.trn-doc.obj-type   = x-store-type and
            ub.trn-doc.status_    = 'факт':U
            no-lock,
            first ub.doc-line where
                ub.doc-line.artic      = gds-list.artic     and
                ub.doc-line.prod-type  = gds-list.prod-type and
                ub.doc-line.prod-code  = gds-list.prod-code and
                ub.doc-line.doc-code   = ub.trn-doc.doc-code   no-lock :
                Assign
                   inv-fact-order = ub.trn-doc.fact-order
                   inv-str        = 'Последняя инвентаризация ' +  string(ub.trn-doc.fact-date ,"99/99/9999" ) + " документ № " + ub.doc-line.doc-code.
          End.
         End.
Assign TOT-SumCRSA = 0
       TOT-VAT-Sum = 0
       TOT-SLT-sum = 0
       TOT-SumCOST = 0
       TOT-SumSALE = 0
       TOT-qnty    = 0
       TOT-discnt-sum = 0
       TOT-ov-sum     = 0.
   FIND FIRST ub.clients where x-store-type = ub.clients.obj-type AND
                            x-store-code = ub.clients.obj-code no-lock no-error.
           If available ub.clients then  ObjName = ub.clients.obj-name.
                                         else  ObjName="объект не определен".
  run calcitog.
  form with frame zapas .
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
form header
  line format "x(197)" at 1 skip
  "Продолжение - на следующей странице" at 30 skip
  with frame bottomframe width 232 page-bottom no-labels no-box .
view stream outstream frame bottomframe .
  run ob-line  in this-procedure (
      input   x-store-code   ,
      input   x-store-type   ,
      input   gds-list.artic       ,
      input   gds-list.prod-code   ,
      input   gds-list.prod-type   ,
      input   fact-order-1,
      input   fact-order-2,
      input   'crsa':U,
      input   '##,##':U,
      input   xcombo-node ,
      input   yes ) .
   hide stream outstream frame bottomframe2 .
  run print-footer.
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
procedure calc-discnt-base.
discnt-rubl# =  0.
discnt-base# =  0.
for each ub.gds-dtl where ub.gds-dtl.doc-code = ub.trn-doc.doc-code and
                ub.gds-dtl.artic      = ub.doc-line.artic     and
                ub.gds-dtl.prod-type  = ub.doc-line.prod-type and
                ub.gds-dtl.prod-code  = ub.doc-line.prod-code no-lock :
  discnt-rubl# = discnt-rubl# + (ub.gds-dtl.discnt-rubl * ub.gds-dtl.doc-qnty ).
  discnt-base# = discnt-base# + (ub.gds-dtl.discnt-base * ub.gds-dtl.doc-qnty ).
  tot-ov#      = tot-ov#      + ((ub.gds-dtl.cur-base - ub.gds-dtl.price-base ) * ub.gds-dtl.fact-qnty ).
  if discnt-rubl# = ? then discnt-rubl# = 0.
  if discnt-base# = ? then discnt-base# = 0.
  if tot-ov# = ?      then tot-ov#      = 0.
end.
end procedure.
procedure subtit-prod.
   define input parameter x-ord  as integer no-undo .
   find first ub.clients where ub.clients.obj-code = gds-list.prod-code and
                            ub.clients.obj-type = gds-list.prod-type no-lock.
   PUT stream  OutStream  UNFORMATTED "Производитель : " + ub.clients.obj-name  at  (x-ord * 10) - 10   format "x(100)" skip.
end procedure.
procedure subfoot-prod.
   define input parameter x-ord  as integer no-undo .
   find first ub.clients where ub.clients.obj-code = gds-list.prod-code and
                            ub.clients.obj-type = gds-list.prod-type no-lock.
   PUT stream  OutStream  UNFORMATTED "Итого по пр-лю : " + ub.clients.obj-name at  (x-ord * 10) - 10    format "x(" + string (53 - ((x-ord * 10) - 10) ) + ")"
   s#1 at 56   format "->>>>>>>>>9.<<<"
   s#2 at 68   format "->>>>>>>>>>9.<<"
   s#3 at 83   format "->>>>>>>>>>9.<<"
   s#4 at 123  format "->>>>>>>>>>9.<<"
   s#7 at 141  format "->>>>>>>>>9.<<"
   s#8 at 157  format "->>>>>>>>>9.<<"
   skip.
end procedure.
procedure subfoot-grp.
   define input parameter x-ord  as integer no-undo .
   PUT stream  OutStream  UNFORMATTED  "Итого по группе  " +  gds-list.grp-name at  (x-ord * 10) - 10   format "x(" + string (53 - ((x-ord * 10) - 10) ) + ")"
   s1 at 56  format "->>>>>>>>>9.<<<"
   s2 at 68   format "->>>>>>>>>>9.<<"
   s3 at 83   format "->>>>>>>>>>9.<<"
   s4 at 123  format "->>>>>>>>>>9.<<"
   s7 at 141  format "->>>>>>>>>9.<<"
   s8 at 157  format "->>>>>>>>>9.<<"
   skip.
end procedure.
procedure subtit-grp.
   define input parameter x-ord  as integer no-undo .
   PUT stream  OutStream  UNFORMATTED "Группа : " + gds-list.grp-name at  (x-ord * 10) - 10   format "x(100)" skip.
end procedure.
procedure subfoot-vat-sort.
   define input parameter x-ord  as integer no-undo .
   case x-ord:
   when 1 then str = "Итого по пробе ".
   when 2 then str = "Итого по НДС   ".
   end case.
   PUT stream  OutStream  UNFORMATTED  str + (if x-ord=1 then  gds-list.sort  else string(gds-list.qnty)  )  at  1   format "x(52)"
   s#1 at 56   format "->>>>>>>>>>>9.<<<"
   s#2 at 68   format "->>>>>>>>>>>9.<<"
   s#3 at 83   format "->>>>>>>>>>>9.<<"
   s#4 at 123  format "->>>>>>>>>>>9.<<"
   s#7 at 141  format "->>>>>>>>>>9.<<"
   s#8 at 157  format "->>>>>>>>>>9.<<"
   skip.
end procedure.
procedure subtit-vat-sort.
   define input parameter x-ord  as integer no-undo .
   case x-ord:
   when 1 then str = "Проба ".
   when 2 then str = "НДС   ".
   end case.
   PUT stream  OutStream  UNFORMATTED  str + (if x-ord=1 then  gds-list.sort  else string(gds-list.qnty))  at  1   format "x(100)" skip.
end procedure.
