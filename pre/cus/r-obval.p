block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter pcurr-code like ub.trn-doc.exch-code no-undo.
define input parameter pnum-obj    as integer no-undo.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-obval.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/r-obval.p $":U .
define variable vss-description as character no-undo init "Оборот в валюте поставщика - создание записей во времнной таблице".
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def shared temp-table cli-list no-undo like ub.clients
  field to-del as logical
  index obj  is primary unique obj-type obj-code
  index cli-name      obj-name
  .
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared  temp-table cli-list-hist no-undo
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define SHARED temp-table temp-goods no-undo
  FIELD supp-type like ub.parts.supp-type
  FIELD supp-code like ub.parts.supp-code
  FIELD exch-code like ub.parts.exch-code
  FIELD obj-type like ub.parts.obj-type
  FIELD obj-code like ub.parts.obj-code
  FIELD artic like ub.goods.artic
  FIELD prod-type like ub.goods.prod-type
  FIELD prod-code like ub.goods.prod-code
  FIELD in-code like ub.parts.in-code
  FIELD part-code like ub.parts.part-code
  FIELD curr-name like ub.currency.curr-abbr
  FIELD unit like ub.goods.unit-base
  FIELD gds-name like ub.goods.gds-name
  FIELD VAT-PC like ub.parts.vat-pc
  FIELD SLT-PC like ub.parts.slt-pc
  FIELD in-date like ub.trn-doc.fact-date
  FIELD qnty-all like ub.parts.fact-qnty
  FIELD obj-in-type like ub.clients.obj-type
  FIELD obj-in-code like ub.clients.obj-code
  FIELD qnty-in like ub.parts.fact-qnty
  FIELD qnty-out like ub.parts.fact-qnty
  FIELD qnty-rest like ub.parts.fact-qnty
  FIELD price-cli-in-brutto like ub.parts.price-cli
  FIELD price-cli-in like ub.parts.price-cli
  FIELD vat-type like ub.parts.vat-type
  FIELD slt-type like ub.parts.slt-type
  FIELD price-cli-in-sum as decimal
  FIELD price-cli-out-sum as decimal
  index pi is UNIQUE PRIMARY
  supp-type
  supp-code
  exch-code
  artic
  prod-type
  prod-code
  in-code
  part-code
  obj-type
  obj-code
  .
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
DEFINE VARIABLE doc-num like ub.trn-doc.doc-code no-undo.
DEFINE VARIABLE is-out as decimal no-undo.
DEFINE VARIABLE is-prihod as logical no-undo.
DEFINE VARIABLE is-rashod as logical no-undo.
DEFINE VARIABLE prt-qnty as decimal no-undo.
define buffer for-doc for ub.trn-doc.
define buffer for-line for ub.doc-line.
define buffer in-parts for ub.parts.
define buffer b-temp-goods for temp-goods.
DEFINE VARIABLE my-accum as integer no-undo .
DEFINE VARIABLE all-obj-type as character no-undo.
DEFINE VARIABLE all-obj-code as integer no-undo.
DEFINE VARIABLE for-part-code like ub.parts.part-code no-undo.
DEFINE VARIABLE is-twounit as logical no-undo .
DEFINE VARIABLE first-find as logical no-undo .
DEFINE VARIABLE         v-supp-type     like ub.parts-attr.supp-type        no-undo .
DEFINE VARIABLE         v-supp-code     like ub.parts-attr.supp-code        no-undo .
DEFINE VARIABLE         v-in-code       like ub.parts-attr.income-in-code   no-undo .
DEFINE VARIABLE         v-part-code     like ub.parts-attr.part-code        no-undo .
DEFINE VARIABLE         v-gds-code      like ub.parts-attr.gds-code         no-undo .
DEFINE VARIABLE         v-price-cli     like ub.parts-attr.price-cli        no-undo .
DEFINE VARIABLE         v-cli-base-rate like ub.parts-attr.cli-base-rate    no-undo .
DEFINE VARIABLE         v-obj-type      like ub.parts-attr.obj-type         no-undo .
DEFINE VARIABLE         v-obj-code      like ub.parts-attr.obj-code         no-undo .
DEFINE VARIABLE         v-vat-type      like ub.parts-attr.vat-type         no-undo .
DEFINE VARIABLE         v-slt-type      like ub.parts-attr.slt-type         no-undo .
DEFINE VARIABLE         v-vat-pc        like ub.parts-attr.vat-pc           no-undo .
DEFINE VARIABLE         v-slt-pc        like ub.parts-attr.slt-pc           no-undo .
DEFINE VARIABLE         v-fact-qnty     like ub.parts-attr.fact-qnty        no-undo .
DEFINE VARIABLE         v-qnty          like ub.parts-attr.doc-qnty         no-undo .
DEFINE VARIABLE         v-fact-date     like ub.parts-attr.fact-date        no-undo .
DEFINE VARIABLE         v-exch-code     like ub.parts-attr.exch-code        no-undo .
DEFINE VARIABLE         v-inv           as logical                          no-undo .
DEFINE VARIABLE         v-real-is-prihod as logical no-undo .
DEFINE VARIABLE         v-real-is-rashod as logical no-undo .
define buffer buf_parts-attr for ub.parts-attr.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
   define variable loc-price-without-abs        like ub.doc-line.price-base no-undo.
   define variable loc-price-slt                like ub.doc-line.price-base no-undo.
   define variable loc-price-vat                like ub.doc-line.price-base no-undo.
   define variable loc-price-no-vat-slt         like ub.doc-line.price-base no-undo.
   define variable loc-price-cli-netto          like ub.doc-line.price-base no-undo.
if pnum-obj > 1 then
assign
all-obj-type = ""
all-obj-code = 0
.
else do:
  find first obj-list No-LOCK No-ERROR.
  if avail obj-list then do:
    assign
    all-obj-type = obj-list.obj-type
    all-obj-code = obj-list.obj-code
    .
  end.
end.
FOR EACH temp-goods:
  delete temp-goods.
END.
FOR EACH obj-list NO-LOCK:
  FOR EACH for-doc No-LOCK WHERE
          for-doc.obj-type = obj-list.obj-type AND
          for-doc.obj-code = obj-list.obj-code AND
          for-doc.fact-date >= X-date-start AND
          for-doc.fact-date <= X-date-end AND
          for-doc.status_ = 'факт':U:
    if for-doc.office then NEXT.
    if LOOKUP(for-doc.ext-doc-type, 'iv,rv,ev':U + 'ap,pc':U) > 0 then NEXT.
    assign
    doc-num = for-doc.doc-code
    is-out = if LOOKUP(for-doc.ext-doc-type, 'ie,re,rs,vt,im':U) > 0  then 1 else -1
    is-prihod = if (for-doc.ext-doc-type = 'ie':U OR
                    for-doc.ext-doc-type = 'ep':U
                    )
                then yes else no
    is-rashod = NOt is-prihod
    .
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FOR  each for-line NO-LOCk WHERE
          for-line.doc-code = doc-num:
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run doclicod in g#library
  (input  recid(for-line)
  ,output v-gds-code
  ) no-error .
  if error-status:error then do:
    next.
  end.
  my-accum = my-accum + 1.
  IF my-accum MODULO 50  = 0 then do:
    run waitfram-show in this-procedure ("Обработано " + string(my-accum) + " партий ").
  end.
  FOR EACH ub.parts NO-LOCK WHERE
          ub.parts.artic = for-line.artic AND
          ub.parts.prod-type = for-line.prod-type AND
          ub.parts.prod-code = for-line.prod-code AND
          ub.parts.out-code = doc-num AND
          ub.parts.obj-type = for-line.obj-type AND
          ub.parts.obj-code = for-line.obj-code :
    first-find = yes.
    FIND FIRST ub.goods No-LOCK WHERE
                ub.goods.artic = for-line.artic AND
                ub.goods.prod-type = for-line.prod-type AND
                ub.goods.prod-code = for-line.prod-code No-ERROR.
    find first buf_parts-attr no-lock where
               buf_parts-attr.in-code = ub.parts.in-code
           AND buf_parts-attr.gds-code = v-gds-code
           AND buf_parts-attr.part-code = ub.parts.part-code no-error .
    if avail buf_parts-attr then do:
      IF buf_parts-attr.is-supp = no  then NEXT.
      if not can-find(FIRST cli-list where
                            cli-list.obj-type = buf_parts-attr.supp-type AND
                            cli-list.obj-code = buf_parts-attr.supp-code) then NEXT.
      assign
      v-in-code = buf_parts-attr.income-in-code
      v-part-code = buf_parts-attr.income-part-code
      v-supp-type = buf_parts-attr.supp-type
      v-supp-code = buf_parts-attr.supp-code
      v-inv       = (buf_parts-attr.ext-doc-type = 'vt':U or buf_parts-attr.ext-doc-type = 'vp':U)
      .
    end.
    else do:
      IF ub.parts.is-supp = no  then NEXT.
      if not can-find(FIRST cli-list where
                            cli-list.obj-type = ub.parts.supp-type AND
                            cli-list.obj-code = ub.parts.supp-code) then NEXT.
      assign
      v-in-code = ub.parts.in-code
      v-part-code = ub.parts.part-code
      v-supp-type = buf_parts-attr.supp-type
      v-supp-code = buf_parts-attr.supp-code
      v-inv       = ub.parts.doc-type = 'инв':U
      .
    end.
    if v-in-code <> ub.parts.out-code then do:
      find first ub.units No-LOCK WHERE
                  ub.units.unit-name = ub.goods.unit-base NO-ERROR.
      if avail ub.units and lookup('2ед':U, ub.units.type ) > 0
      then do:
        assign
        is-twounit = yes
        for-part-code = substr(v-part-code, 1, index(v-part-code, '#':U) - 1)
        .
      end.
      else do:
        assign
        is-twounit = no
        for-part-code = v-part-code
        .
      end.
    end.
    else do:
      assign
      is-twounit = no
      FOR-PART-CODE = v-PART-CODE.
    end.
    FIND FIRST b-temp-goods WHERE
              b-temp-goods.artic = for-line.artic AND
              b-temp-goods.prod-type = for-line.prod-type AND
              b-temp-goods.prod-code = for-line.prod-code AND
              b-temp-goods.supp-type = v-supp-type AND
              b-temp-goods.supp-code = v-supp-code AND
              b-temp-goods.in-code = v-in-code AND
              b-temp-goods.part-code = FOR-part-code AND
              b-temp-goods.obj-type = all-obj-type AND
              b-temp-goods.obj-code = all-obj-code
              No-error.
    IF not avail b-temp-goods then do:
      if avail buf_parts-attr then do:
        if ( (pcurr-code <> ?) AND (buf_parts-attr.exch-code <> pcurr-code) ) then NEXT.
        FIND FIRST ub.currency No-LOCK WHERE
                  ub.currency.curr-code = buf_parts-attr.exch-code No-ERROR.
        assign
        v-price-cli = buf_parts-attr.price-cli
        v-cli-base-rate = buf_parts-attr.cli-base-rate
        v-obj-type = buf_parts-attr.obj-type
        v-obj-code = buf_parts-attr.obj-code
        v-vat-type = buf_parts-attr.vat-type
        v-slt-type = buf_parts-attr.slt-type
        v-vat-pc   = buf_parts-attr.vat-pc
        v-slt-pc   = buf_parts-attr.slt-pc
        v-fact-qnty = buf_parts-attr.fact-qnty
        v-qnty      = buf_parts-attr.doc-qnty
        v-exch-code = buf_parts-attr.exch-code
        v-fact-date = buf_parts-attr.fact-date
        .
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if buf_parts-attr.VAT-type = 'нет':U then do:
  if buf_parts-attr.SLT-type = 'нет':U      or
     buf_parts-attr.SLT-Type = 'без':U then do:
    assign
      loc-price-VAT        = buf_parts-attr.price-cli                             * buf_parts-attr.vat-pc / 100
      loc-price-slt        = buf_parts-attr.price-cli * (1 + buf_parts-attr.vat-pc / 100) * buf_parts-attr.slt-pc / 100
      loc-price-no-vat-slt = buf_parts-attr.price-cli.
  end.
  else do:
    assign
      loc-price-VAT        = buf_parts-attr.price-cli / ((100 / buf_parts-attr.vat-pc) * (1 + buf_parts-attr.slt-pc / 100) + buf_parts-attr.slt-pc / 100)
      loc-price-slt        = buf_parts-attr.price-cli * ( 1 - 1 / (1 + buf_parts-attr.slt-pc / 100 + buf_parts-attr.slt-pc / 100 * buf_parts-attr.vat-pc / 100 ))
      loc-price-no-vat-slt = buf_parts-attr.price-cli - loc-price-slt.
  end.
end.
else do:
  if buf_parts-attr.SLT-type = 'нет':U      or
     buf_parts-attr.SLT-Type = 'без':U then do:
    assign
      loc-price-VAT        = buf_parts-attr.price-cli                                               * buf_parts-attr.vat-pc / (100 + buf_parts-attr.vat-pc)
      loc-price-slt        = buf_parts-attr.price-cli                                               * buf_parts-attr.slt-pc / 100
      loc-price-no-vat-slt = buf_parts-attr.price-cli - loc-price-VAT.
  end.
  else do:
    assign
      loc-price-VAT        = buf_parts-attr.price-cli * (100 / ( 100 + buf_parts-attr.slt-pc))              * buf_parts-attr.vat-pc / (100 + buf_parts-attr.vat-pc)
      loc-price-slt        = buf_parts-attr.price-cli                                               * buf_parts-attr.slt-pc / (100 + buf_parts-attr.slt-pc)
      loc-price-no-vat-slt = buf_parts-attr.price-cli - loc-price-VAT - loc-price-SLT.
  end.
end.
assign loc-price-without-abs = loc-price-no-vat-slt + loc-price-VAT + loc-price-slt.
    assign
    loc-price-cli-netto = loc-price-without-abs  / buf_parts-attr.cli-base-rate.
      end.
      else do:
        FIND FIRST ub.trn-doc No-LOCK WHERE
                  ub.trn-doc.doc-code = v-in-code No-ERROR.
        if not avail ub.trn-doc then do:
          message "Не найдена ПН " v-in-code
          view-as alert-box WARNING.
          NEXT.
        end.
        assign
        v-exch-code = ub.trn-doc.exch-code
        v-fact-date = ub.trn-doc.fact-date
        .
        if ( (pcurr-code <> ?) AND (ub.trn-doc.exch-code <> pcurr-code) ) then NEXT.
        FIND FIRST ub.currency No-LOCK WHERE
                  ub.currency.curr-code = ub.trn-doc.exch-code No-ERROR.
        if v-in-code <> ub.parts.out-code then do:
          FIND FIRST in-parts No-LOCK WHERE
                    in-parts.artic = ub.parts.artic AND
                    in-parts.prod-type = ub.parts.prod-type AND
                    in-parts.prod-code = ub.parts.prod-code AND
                    in-parts.supp-type = v-supp-type AND
                    in-parts.supp-code = v-supp-code AND
                    in-parts.in-code = ub.trn-doc.doc-code AND
                    in-parts.out-code = ub.trn-doc.doc-code AND
                    in-parts.part-code = for-part-code
                    No-ERROR.
          IF not avail in-parts then do:
            message "Не найдена партия по ПН " v-in-code
            ub.parts.artic ub.parts.prod-type ub.parts.prod-code
            "Поставщик" v-supp-type v-supp-code
            "Код партии" for-part-code
            view-as alert-box WARNING.
            NEXT.
          END.
        end.
        else do:
          find first in-parts No-LOCK WHERE
                      recid(in-parts) = recid(ub.parts) No-ERROR.
        end.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if ub.trn-doc.VAT-type = 'нет':U then do:
  if ub.trn-doc.SLT-type = 'нет':U      or
     ub.trn-doc.SLT-Type = 'без':U then do:
    assign
      loc-price-VAT        = in-parts.price-cli                             * in-parts.vat-pc / 100
      loc-price-slt        = in-parts.price-cli * (1 + in-parts.vat-pc / 100) * in-parts.slt-pc / 100
      loc-price-no-vat-slt = in-parts.price-cli.
  end.
  else do:
    assign
      loc-price-VAT        = in-parts.price-cli / ((100 / in-parts.vat-pc) * (1 + in-parts.slt-pc / 100) + in-parts.slt-pc / 100)
      loc-price-slt        = in-parts.price-cli * ( 1 - 1 / (1 + in-parts.slt-pc / 100 + in-parts.slt-pc / 100 * in-parts.vat-pc / 100 ))
      loc-price-no-vat-slt = in-parts.price-cli - loc-price-slt.
  end.
end.
else do:
  if ub.trn-doc.SLT-type = 'нет':U      or
     ub.trn-doc.SLT-Type = 'без':U then do:
    assign
      loc-price-VAT        = in-parts.price-cli                                               * in-parts.vat-pc / (100 + in-parts.vat-pc)
      loc-price-slt        = in-parts.price-cli                                               * in-parts.slt-pc / 100
      loc-price-no-vat-slt = in-parts.price-cli - loc-price-VAT.
  end.
  else do:
    assign
      loc-price-VAT        = in-parts.price-cli * (100 / ( 100 + in-parts.slt-pc))              * in-parts.vat-pc / (100 + in-parts.vat-pc)
      loc-price-slt        = in-parts.price-cli                                               * in-parts.slt-pc / (100 + in-parts.slt-pc)
      loc-price-no-vat-slt = in-parts.price-cli - loc-price-VAT - loc-price-SLT.
  end.
end.
assign loc-price-without-abs = loc-price-no-vat-slt + loc-price-VAT + loc-price-slt.
    assign
    loc-price-cli-netto = loc-price-without-abs  / in-parts.cli-base-rate.
        assign
        v-price-cli = in-parts.price-cli
        v-cli-base-rate = in-parts.cli-base-rate
        v-obj-type = in-parts.obj-type
        v-obj-code = in-parts.obj-code
        v-vat-type = in-parts.vat-type
        v-slt-type = in-parts.slt-type
        v-vat-pc   = in-parts.vat-pc
        v-slt-pc   = in-parts.slt-pc
        v-fact-qnty = in-parts.fact-qnty
        v-qnty = in-parts.qnty
        .
      end.
      create temp-goods.
      assign
      temp-goods.supp-type = v-supp-type
      temp-goods.supp-code = v-supp-code
      temp-goods.exch-code = v-exch-code
      temp-goods.artic = for-line.artic
      temp-goods.prod-type = for-line.prod-type
      temp-goods.prod-code = for-line.prod-code
      temp-goods.in-code =  v-in-code
      temp-goods.part-code = for-part-code
      temp-goods.obj-code = ub.parts.obj-code
      temp-goods.obj-type = ub.parts.obj-type
      temp-goods.unit = ub.goods.unit-base
      temp-goods.gds-name = ub.goods.gds-name
      temp-goods.IN-date =  v-fact-date
      temp-goods.price-cli-in-brutto = v-price-cli / v-cli-base-rate
      temp-goods.price-cli-in = loc-price-cli-netto
      temp-goods.obj-in-type = v-obj-type
      temp-goods.obj-in-code = v-obj-code
      temp-goods.qnty-all = v-fact-qnty
      temp-goods.vat-type = v-vat-type
      temp-goods.slt-type = v-slt-type
      temp-goods.curr-name = (if avail ub.currency then ub.currency.curr-abbr else string(temp-goods.exch-code))
      temp-goods.slt-pc = v-slt-pc
      temp-goods.vat-pc = v-vat-pc
      .
      if all-obj-code = 0 then do:
        create b-temp-goods.
        assign
        b-temp-goods.supp-type = v-supp-type
        b-temp-goods.supp-code = v-supp-code
        b-temp-goods.exch-code = v-exch-code
        b-temp-goods.artic = for-line.artic
        b-temp-goods.prod-type = for-line.prod-type
        b-temp-goods.prod-code = for-line.prod-code
        b-temp-goods.in-code =  v-in-code
        b-temp-goods.part-code = for-part-code
        b-temp-goods.obj-code = all-obj-code
        b-temp-goods.obj-type = all-obj-type
        b-temp-goods.unit = ub.goods.unit-base
        b-temp-goods.gds-name = ub.goods.gds-name
        b-temp-goods.IN-date =  v-fact-date
        b-temp-goods.price-cli-in-brutto = v-price-cli / v-cli-base-rate
        b-temp-goods.price-cli-in = loc-price-cli-netto
        b-temp-goods.qnty-all = v-qnty
        b-temp-goods.obj-in-type = v-obj-type
        b-temp-goods.obj-in-code = v-obj-code
        b-temp-goods.qnty-rest = v-qnty
        b-temp-goods.vat-type = v-vat-type
        b-temp-goods.slt-type = v-slt-type
        b-temp-goods.curr-name = (if avail ub.currency then ub.currency.curr-abbr else string(b-temp-goods.exch-code))
        b-temp-goods.slt-pc = v-slt-pc
        b-temp-goods.vat-pc = v-vat-pc
        .
      end.
    END.
    else do:
      first-find = no.
      if NOT (b-temp-goods.obj-type = obj-list.obj-type AND
              b-temp-goods.obj-code = obj-list.obj-code) then do:
        FIND FIRST temp-goods WHERE
              temp-goods.supp-type = v-supp-type AND
              temp-goods.supp-code = v-supp-code AND
              temp-goods.artic = for-line.artic AND
              temp-goods.prod-type = for-line.prod-type AND
              temp-goods.prod-code = for-line.prod-code AND
              temp-goods.in-code = v-in-code AND
              temp-goods.part-code = for-part-code AND
              temp-goods.obj-type = obj-list.obj-type AND
              temp-goods.obj-code = obj-list.obj-code
              No-error.
        if not avail temp-goods then do:
          create temp-goods.
          buffer-copy b-temp-goods
          except
          b-temp-goods.obj-type
          b-temp-goods.obj-code
          b-temp-goods.qnty-in
          b-temp-goods.qnty-out
          b-temp-goods.price-cli-in-sum
          b-temp-goods.price-cli-out-sum
          to temp-goods
          assign
          temp-goods.obj-type = obj-list.obj-type
          temp-goods.obj-code = obj-list.obj-code
          .
        end.
      end.
    end.
    assign
    prt-qnty =  is-out * ub.parts.fact-qnty
    v-real-is-prihod = (if v-inv
                        then (if prt-qnty >=0
                              then yes
                              else no)
                        else is-prihod)
    v-real-is-rashod = (if v-inv
                        then (if prt-qnty < 0
                              then yes
                              else no)
                        else is-rashod)
    .
    if all-obj-code = 0 or first-find then do:
      assign
      temp-goods.qnty-in = temp-goods.qnty-in +  (if v-real-is-prihod then prt-qnty else 0)
      temp-goods.qnty-out = temp-goods.qnty-out +  (if v-real-is-rashod then prt-qnty else 0)
      temp-goods.price-cli-in-sum = temp-goods.price-cli-in-sum +
                                    (if v-real-is-prihod
                                    then temp-goods.price-cli-in * prt-qnty
                                    else 0)
      temp-goods.price-cli-out-sum = temp-goods.price-cli-out-sum +
                                    (if v-real-is-rashod
                                    then temp-goods.price-cli-in * prt-qnty
                                    else 0)
      .
    end.
    if all-obj-code = 0 or not first-find then do:
      assign
      b-temp-goods.qnty-in = b-temp-goods.qnty-in +  (if v-real-is-prihod then prt-qnty else 0)
      b-temp-goods.qnty-out = b-temp-goods.qnty-out +  (if v-real-is-rashod then prt-qnty else 0)
      b-temp-goods.price-cli-in-sum = b-temp-goods.price-cli-in-sum +
                                    (if v-real-is-prihod
                                    then b-temp-goods.price-cli-in * prt-qnty
                                    else 0)
      b-temp-goods.price-cli-out-sum = b-temp-goods.price-cli-out-sum +
                                    (if v-real-is-rashod
                                    then b-temp-goods.price-cli-in * prt-qnty
                                    else 0)
      b-temp-goods.qnty-rest = b-temp-goods.qnty-rest + prt-qnty
      .
    end.
  END.
END.
  END.
END.
run waitfram-hide in this-procedure .
