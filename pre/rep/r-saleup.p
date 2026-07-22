block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: 0500dccfad42, 789, rls $":U .
define variable vss-author      as character no-undo init "$Author: PGridchina $":U .
define variable vss-date        as character no-undo init "$Date: Wed Sep 14 14:42:19 2016 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-saleup.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-saleup.p $":U .
define variable vss-description as character no-undo init "Отчет по продажам упаковками".
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
define input parameter parparentproc  as   widget-handle  no-undo .
define input parameter SortType  as integer no-undo.
define input parameter Classify  as integer no-undo.
define input parameter p-det-obj as logical no-undo.
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
define variable vss-include-info7 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define temp-table temp_grplib_grp no-undo
    field sel           as character
    field nabor         as character
    field full-name     as character
    field print-code    as character
    field sort-name     as character
    field node-code     as integer
    field upper-code    as integer
    field calc-method   as character
    field round-method  as character
    field increase-pc   as decimal
    field min-marg      as character
    field max-marg      as character
    field cli-type      as character
    field cli-code      as integer
    field notcorr      as character
    field name          as character
    field level         as integer
    field mark          as character
    index pi is primary unique sort-name
    index fn full-name
    index nc is unique node-code
    index sl sel
    index uc upper-code
.
define temp-table temp_grplib_found-grp no-undo
    field full-name   as character
    field sort-name   as character
    field node-code   as integer
    field level       as integer
    field is-terminal as logical
    index pi is primary unique sort-name
    index fn full-name
    index lv level
    index it is-terminal
.
define temp-table temp_found-result-nodelist no-undo
    field node-code     as recid
    field processed     as logical
    field sort-name     as character
    field full-name     as character
    index pi is primary unique node-code
    index ps processed
.
define variable v-grplib-not-fill-extra-info        as logical      no-undo.
define variable v-grplib-no-warning-grp-amount      as logical      no-undo.
define variable v-grplib-grp-amount-for-load        as integer      no-undo.
procedure grplib-get-parameters :
define input parameter p-store-type     as character        no-undo.
define input parameter p-store-code     as integer          no-undo.
do
on error undo, return error
:
    assign
        v-grplib-not-fill-extra-info = no
    .
end.
end procedure.
procedure grplib-get-sort-name :
do
on error undo, return error
:
define input parameter p-node-code  as integer      no-undo.
define output parameter p-sort-name as character    no-undo.
    define variable v-upper-code    as integer           no-undo.
    define buffer buf_gds-grp       for ub.gds-grp.
    define buffer buf_upper_gds-grp for ub.gds-grp.
    find first buf_gds-grp no-lock
         where buf_gds-grp.node-code = p-node-code
    no-error.
    if not available buf_gds-grp
    then do:
        undo, return error "grplib-get-sort-name: Не найдена группа товаров с кодом " + string( p-node-code ).
    end.
    assign
        p-sort-name  = ""
        v-upper-code = 1
    .
    do while buf_gds-grp.upper-code <> 0
    on error undo, return error "grplib-get-sort-name: Ошибка составления полного имени группы"
    :
        assign
            p-sort-name  = buf_gds-grp.node-name
                         + (if p-sort-name <> "" then chr(2) else "")
                         + p-sort-name
            v-upper-code = buf_gds-grp.upper-code
        .
        find first buf_gds-grp no-lock
             where buf_gds-grp.node-code = v-upper-code
        no-error.
        if not available buf_gds-grp
        then do:
            undo, return error "grplib-get-sort-name: Не найдена группа товаров с кодом "
                                + string( v-upper-code )
                                + ". Ошибка ссылки в дереве товаров для узла p-node-code".
        end.
    end.
end.
end procedure.
define variable vss-include-info8 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
procedure grplib-get-full-name :
   define input parameter p-node-code  as integer      no-undo.
   define output parameter p-full-name as character    no-undo.
   do
on error undo, return error
:
    define variable v-upper-code    as integer           no-undo.
    define buffer buf_gds-grp       for ub.gds-grp.
    define buffer buf_upper_gds-grp for ub.gds-grp.
    find first buf_gds-grp no-lock
         where buf_gds-grp.node-code = p-node-code
    no-error.
    if not available buf_gds-grp
    then do:
        undo, return error "grplib-get-full-name: Не найдена группа товаров с кодом " + string( p-node-code ).
    end.
    assign
        p-full-name  = ""
        v-upper-code = 1
    .
    do while buf_gds-grp.upper-code <> 0
    on error undo, return error "grplib-get-full-name: Ошибка составления полного имени группы"
    :
        assign
            p-full-name  = buf_gds-grp.node-name
                         + (if p-full-name <> "" then chr(47) else "")
                         + p-full-name
            v-upper-code = buf_gds-grp.upper-code
        .
        find first buf_gds-grp no-lock
             where buf_gds-grp.node-code = v-upper-code
        no-error.
        if not available buf_gds-grp
        then do:
            undo, return error "grplib-get-full-name: Не найдена группа товаров с кодом "
                                + string( v-upper-code )
                                + ". Ошибка ссылки в дереве товаров для узла p-node-code".
        end.
    end.
    assign
    p-full-name = p-full-name + (if p-full-name = "":U then "":U else chr(47))
    .
end.
end .
procedure grplib-get-node-from-full-name :
define input parameter p-full-name as character no-undo .
define output parameter p-node-code as integer no-undo .
define variable v-ii as integer no-undo .
define variable v-upper-code as integer no-undo .
define variable v-root-code as integer no-undo .
define variable v-entry as character no-undo .
define buffer buf_gds-grp       for ub.gds-grp.
do
on error undo, return error
:
  find first buf_gds-grp no-lock
      where buf_gds-grp.upper-code = 0
  no-error .
  if not available buf_gds-grp
  then do:
      undo, return error substitute("Не найдена корневая группа товаров (upper-code = 0)").
  end.
  else do:
    assign
    v-root-code = buf_gds-grp.node-code
    .
  end.
  v-upper-code = v-root-code.
  do v-ii = 1 to num-entries(p-full-name, chr(47)):
    assign
    v-entry = entry(v-ii, p-full-name, chr(47)).
    if v-entry = '' then leave.
    find first buf_gds-grp no-lock where
              buf_gds-grp.node-name = v-entry
          and buf_gds-grp.upper-code = v-upper-code
          no-error.
    if not available buf_gds-grp then do:
      undo, return error substitute("Не найдена подгруппа &1 в группе с вн. кодом &2", v-entry, v-upper-code).
    end.
    else do:
      p-node-code = buf_gds-grp.node-code.
      v-upper-code = buf_gds-grp.node-code.
    end.
  end.
end.
end .
procedure grplib-get-root-code :
do
on error undo, return error
:
define output parameter p-root-code as integer      no-undo.
    define buffer buf_gds-grp       for ub.gds-grp.
    find first buf_gds-grp no-lock
        where buf_gds-grp.upper-code = 0
    no-error .
    if not available buf_gds-grp
    then do:
        undo, return error .
    end.
    else do:
        assign
            p-root-code = buf_gds-grp.node-code
        .
    end.
end.
end procedure.
procedure grplib-find-grp-by-full-name :
do
on error undo, return error
:
define input parameter p-search-name  as character    no-undo.
define input parameter p-fill-path    as logical      no-undo.
define output parameter p-found       as logical      no-undo.
    define variable v-upper-code    as integer          no-undo.
    define variable v-counter       as integer           no-undo.
    define variable v-level         as integer           no-undo.
    define variable v-full-name     as character         no-undo.
    define variable v-sort-name     as character         no-undo.
    define buffer buf_gds-grp       for ub.gds-grp.
    assign
        p-search-name = replace( p-search-name, chr(47), chr(2) )
    .
    run grplib-get-root-code ( output v-upper-code ) no-error .
    if error-status :error
    then do:
        undo, return error "grplib-expand-name: Ошибка при поиске корневого узла".
    end.
    assign
        v-full-name  = ""
        v-level      = num-entries( p-search-name, chr(2) )
    .
    for each temp_grplib_found-grp
    :
        delete temp_grplib_found-grp.
    end.
    start-name-analyze:
    do v-counter = 1 to v-level
    :
        if v-counter < v-level
        then do:
            find first buf_gds-grp no-lock
                 where buf_gds-grp.upper-code = v-upper-code
                   and buf_gds-grp.node-name  = entry( v-counter, p-search-name, chr(2) )
            no-error .
            if not available buf_gds-grp
            then do:
                assign
                    v-full-name  = p-search-name
                    v-sort-name  = p-search-name
                .
                return error "grplib-expand-name: не найдена группа " + entry( v-level, p-search-name, chr(2) ).
            end.
            else do:
                assign
                    v-full-name = v-full-name + ( if v-full-name = "" then "" else chr(47) )        + buf_gds-grp.node-name
                    v-sort-name = v-sort-name + ( if v-sort-name = "" then "" else chr(2) ) + buf_gds-grp.node-name
                    v-upper-code = buf_gds-grp.node-code
                .
                if p-fill-path = yes
                then do:
                    create temp_grplib_found-grp.
                    assign
                        temp_grplib_found-grp.full-name = v-full-name + chr(47)
                        temp_grplib_found-grp.sort-name = v-sort-name
                        temp_grplib_found-grp.node-code = v-upper-code
                        temp_grplib_found-grp.level     = v-counter
                    .
                end.
            end.
        end.
        else do:
            for each buf_gds-grp no-lock
               where buf_gds-grp.upper-code = v-upper-code
                 and buf_gds-grp.node-name begins entry( v-counter, p-search-name, chr(2) )
            :
                assign
                    p-found = yes
                .
                create temp_grplib_found-grp.
                assign
                    temp_grplib_found-grp.full-name = v-full-name
                                                        + (if v-full-name = "" then "" else chr(47) )
                                                        + buf_gds-grp.node-name + chr(47)
                    temp_grplib_found-grp.sort-name = v-sort-name
                                                        + ( if v-sort-name = "" then "" else chr(2) )
                                                        + buf_gds-grp.node-name
                    temp_grplib_found-grp.node-code = buf_gds-grp.node-code
                    temp_grplib_found-grp.level     = v-level
                .
            end.
            if p-found = no
            then do:
                assign
                    v-full-name  = p-search-name
                    v-sort-name  = p-search-name
                .
                for each temp_grplib_found-grp
                :
                    delete temp_grplib_found-grp.
                end.
                assign
                    p-found = no
                .
            end.
        end.
    end.
end.
end procedure.
procedure grplib-find-all-subgroup :
do
on error undo, return error
:
define input parameter p-start-node-code    as integer      no-undo.
define input parameter p-terminal-only      as logical      no-undo.
    define variable v-start-full-name   as character     no-undo.
    define variable v-start-sort-name   as character     no-undo.
    define variable v-not-found         as logical       no-undo.
    define variable v-is-terminal       as logical       no-undo.
    define buffer buf_gds-grp           for ub.gds-grp.
    create temp_found-result-nodelist.
    assign
        temp_found-result-nodelist.node-code = p-start-node-code
        temp_found-result-nodelist.processed = no
    .
    run grplib-get-full-name in this-procedure (
          input p-start-node-code
        , output v-start-full-name
    ).
    run grplib-get-full-name in this-procedure (
          input p-start-node-code
        , output v-start-sort-name
    ).
    process-nodes:
    do while yes
    :
        find first temp_found-result-nodelist
             where temp_found-result-nodelist.node-code = p-start-node-code
        .
        assign
            temp_found-result-nodelist.processed = yes
        .
        for each buf_gds-grp no-lock
           where buf_gds-grp.upper-code = p-start-node-code
        on error undo, return error
        :
            run grplib-is-terminal in this-procedure (
                  input buf_gds-grp.node-code
                , output v-is-terminal
            ).
            if v-is-terminal = yes
            then do:
                create temp_grplib_found-grp.
                assign
                    temp_grplib_found-grp.full-name   = right-trim(v-start-full-name, chr(47)) +
                                                        chr(47) + buf_gds-grp.node-name + chr(47)
                    temp_grplib_found-grp.sort-name   = right-trim(v-start-sort-name, chr(2)) +
                                                        chr(2) + buf_gds-grp.node-name + chr(2)
                    temp_grplib_found-grp.node-code   = buf_gds-grp.node-code
                    temp_grplib_found-grp.is-terminal = yes
                .
            end.
            else do:
                create temp_found-result-nodelist.
                assign
                    temp_found-result-nodelist.node-code = buf_gds-grp.node-code
                    temp_found-result-nodelist.full-name = right-trim(v-start-full-name, chr(47)) +
                                                           chr(47) + buf_gds-grp.node-name + chr(47)
                    temp_found-result-nodelist.sort-name = right-trim(v-start-sort-name, chr(2)) +
                                                           chr(2) + buf_gds-grp.node-name + chr(2)
                    temp_found-result-nodelist.processed = no
                .
                if p-terminal-only = no
                then do:
                    create temp_grplib_found-grp.
                    assign
                        temp_grplib_found-grp.full-name   = right-trim(v-start-full-name, chr(47)) +
                                                            chr(47) + buf_gds-grp.node-name + chr(47)
                        temp_grplib_found-grp.sort-name   = right-trim(v-start-sort-name, chr(2)) +
                                                            chr(2) + buf_gds-grp.node-name + chr(2)
                        temp_grplib_found-grp.node-code   = buf_gds-grp.node-code
                        temp_grplib_found-grp.is-terminal = no
                    .
                end.
            end.
        end.
        find first temp_found-result-nodelist
             where temp_found-result-nodelist.processed = no
        no-error.
        if not available temp_found-result-nodelist
        then do:
            leave process-nodes.
        end.
        else do:
            assign
                p-start-node-code = temp_found-result-nodelist.node-code
                v-start-full-name = temp_found-result-nodelist.full-name
                v-start-sort-name = temp_found-result-nodelist.sort-name
            .
        end.
    end.
end.
end procedure.
procedure grplib-expand-name :
define input parameter p-start-name as character        no-undo.
define output parameter p-end-name  as character        no-undo.
    define variable v-is-terminal   as logical      no-undo.
    define variable v-found         as character    no-undo.
    define buffer buf_temp_grplib_found-grp     for temp_grplib_found-grp.
do
for buf_temp_grplib_found-grp
on error undo, return error
:
    run grplib-find-grp-by-full-name in this-procedure (
          input p-start-name
        , input no
        , output v-found
    ) no-error.
    run grplib-get-max-substring in this-procedure (
                input length( p-start-name )
              , output p-end-name
    ) no-error .
    if error-status :error
    then do:
        assign
            p-end-name = ""
        .
    end.
    else do:
        find first temp_grplib_found-grp
            where temp_grplib_found-grp.full-name = p-end-name
        no-error.
        if available temp_grplib_found-grp
        then do:
            find first buf_temp_grplib_found-grp
                where buf_temp_grplib_found-grp.full-name begins p-end-name
                and recid( buf_temp_grplib_found-grp ) <> recid( temp_grplib_found-grp )
            no-error.
            if not available buf_temp_grplib_found-grp
            then do:
                run grplib-is-terminal in this-procedure (
                    input temp_grplib_found-grp.node-code
                    , output v-is-terminal
                ).
            end.
        end.
    end.
end.
end procedure.
procedure grplib-get-max-substring :
do
on error undo, return error
:
define input parameter p-min-substring-length   as integer      no-undo.
define output parameter p-substring             as character    no-undo.
        define variable v-char-counter  as integer           no-undo.
        define variable v-current-char  as character         no-undo.
        define variable v-names-counter  as integer           no-undo.
        define variable v-base-string   as character         no-undo.
        assign
            v-char-counter  = p-min-substring-length
        .
        find first temp_grplib_found-grp no-error.
        if not available temp_grplib_found-grp
        then do:
            undo, return error "grplib-get-max-substring: Нет строк для вычисления общей подстроки".
        end.
        else do:
            assign
                v-base-string  = temp_grplib_found-grp.full-name
                v-char-counter = 0
            .
            counter-block:
            do while yes
            on error undo, return error "grplib-get-max-substring: Ошибка вычисления продолжения имени группы."
            :
                assign
                    v-char-counter  = v-char-counter + 1
                    v-current-char  = substring( v-base-string, v-char-counter, 1 )
                    v-names-counter = 0
                .
                compare-block:
                for each temp_grplib_found-grp
                :
                    assign
                        v-names-counter = v-names-counter + 1
                    .
                    if v-names-counter = 1
                    then do:
                        next compare-block.
                    end.
                    if substring( temp_grplib_found-grp.full-name, v-char-counter, 1 ) <> v-current-char
                    then do:
                        leave counter-block.
                    end.
                end.
                if v-names-counter = 1
                then do:
                    assign
                        p-substring = v-base-string
                    .
                    return.
                end.
            end.
            assign
                p-substring = substring( v-base-string, 1, v-char-counter - 1 )
            .
        end.
end.
end procedure.
procedure grplib-is-terminal :
do
on error undo, return error "Ошибка процедуры grplib-is-terminal"
:
define input parameter p-node-code      as integer      no-undo.
define output parameter p-is-terminal   as logical      no-undo.
    define buffer buf_gds-grp       for ub.gds-grp.
    find first buf_gds-grp no-lock
        where buf_gds-grp.upper-code = p-node-code
    no-error .
    if not available buf_gds-grp
    then do:
        assign
            p-is-terminal = yes
        .
    end.
    else do:
        assign
            p-is-terminal = no
        .
    end.
end.
end procedure.
procedure grplib-have-goods :
do
on error undo, return error
:
define input parameter p-node-code      as integer      no-undo.
define output parameter p-have-goods   as logical      no-undo.
    define buffer buf_goods         for ub.goods.
    find first buf_goods no-lock
         where buf_goods.grp-code = p-node-code
    no-error .
    if available buf_goods
    then do:
        assign
            p-have-goods = yes
        .
    end.
    else do:
        assign
            p-have-goods = no
        .
    end.
end.
end procedure.
procedure grplib-find-by-substring :
do
on error undo, return error
:
define input parameter p-start-code         as integer      no-undo.
define input parameter p-full-search-string as character    no-undo.
define output parameter p-found-code        as integer      no-undo.
define output parameter p-full-name         as character    no-undo.
    define variable v-start-code     as integer           no-undo.
    define variable v-found          as logical  init no  no-undo.
    define buffer buf_gds-grp       for ub.gds-grp.
    search-grp:
    for each buf_gds-grp no-lock
        where buf_gds-grp.node-code > p-start-code
    :
        if index( buf_gds-grp.node-name, p-full-search-string ) <> 0
        then do:
            assign
                p-found-code = buf_gds-grp.node-code
                v-found      = yes
            .
            run grplib-get-full-name in this-procedure (
                  input p-found-code
                , output p-full-name
            ) no-error .
            if error-status :error
            then do:
                undo, return error "grplib-find-by-substring: Ошибка вычисления полного имени группы." + chr(10) + return-value.
            end.
            leave search-grp.
        end.
    end.
    if v-found = yes
    then do:
    end.
    else do:
        assign
            p-full-name  = ""
            p-found-code = 0
        .
    end.
end.
end procedure.
procedure grplib-analyze-grp-name :
do
on error undo, return error
:
define input parameter p-grp-name       as character            no-undo.
define input parameter p-upper-code     as integer              no-undo.
define output parameter p-error-message as character init ""    no-undo.
    define variable v-char-list     as character    no-undo.
    define variable v-char-counter  as integer      no-undo.
    define variable v-full-name     as character    no-undo.
    if p-grp-name = "" then do:
        assign
            p-error-message = "Название группы не может быть пустым.".
        .
    end.
    else do:
        assign
            v-char-list = "47,92,58,63,34,60,62,171,187,183"
        .
        do v-char-counter = 1 to num-entries( v-char-list )
        :
            if index( p-grp-name, chr( integer( entry( v-char-counter, v-char-list ) ) ) ) <> 0
            then do:
                assign
                    p-error-message = 'Название группы не может содержать символы /\:*?"<>|«»·'
                .
                return.
            end.
        end.
        if p-upper-code > 0
        then do:
            run grplib-get-full-name in this-procedure (
                  input p-upper-code
                , output v-full-name
            ) no-error .
            if error-status :error
            then do:
                undo, return error "grplib-analyze-grp-name: Не удалось вычислить полное имя группы." + chr(10) + return-value.
            end.
            if length( v-full-name ) + 1 + length( p-grp-name ) > 350
            then do:
                assign
                    p-error-message = 'Полное название группы не может содержать более 350 символов.'
                .
            end.
        end.
    end.
end.
end procedure.
procedure grplib-get-lvl-num :
define input parameter p-node-code  as integer      no-undo.
define output parameter p-lvl-num   as integer      no-undo.
    define variable v-full-name    as character    no-undo.
do
on error undo, return error
:
    run grplib-get-full-name in this-procedure (
          input p-node-code
        , output v-full-name
    ).
    assign
        p-lvl-num = num-entries( v-full-name, chr(47) ) - 1
    .
    if p-lvl-num = -1
    then do:
        assign
            p-lvl-num = 0
        .
    end.
end.
end procedure.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define  shared variable RepPathName        as character no-undo .
define  shared variable PrintRubl          as logical   no-undo .
def var vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-param no-undo   field param-code     as character   field param-sub-code as character   field param-value    as character   index xpk is primary unique param-code param-sub-code   .
procedure paramls-clear :
  define buffer buf_temp-param for temp-param .
  do
  on error undo, return error return-value
  :
    for each buf_temp-param
    on error undo, return error
    :
      delete buf_temp-param .
    end.
  end.
end procedure.
procedure paramls-write :
  define input  parameter p-code     as character no-undo .
  define input  parameter p-sub-code as character no-undo .
  define input  parameter p-value    as character no-undo .
  define buffer buf_temp-param for temp-param .
  do
  on error undo, return error return-value
  :
    find first buf_temp-param
      where buf_temp-param.param-code     = p-code
        and buf_temp-param.param-sub-code = p-sub-code
      no-error .
    if not available buf_temp-param then do:
      create buf_temp-param .
      assign
        buf_temp-param.param-code     = p-code
        buf_temp-param.param-sub-code = p-sub-code
      .
    end.
    assign
      buf_temp-param.param-value = p-value
    .
  end.
end procedure.
procedure paramls-read :
  define input  parameter p-code          as character no-undo .
  define input  parameter p-sub-code      as character no-undo .
  define input  parameter p-default-value as character no-undo .
  define output parameter p-value         as character no-undo .
  define buffer buf_temp-param for temp-param .
  do
  on error undo, return error return-value
  :
    find first buf_temp-param
      where buf_temp-param.param-code     = p-code
        and buf_temp-param.param-sub-code = p-sub-code
      no-error .
    if available buf_temp-param then do:
      assign
        p-value = buf_temp-param.param-value
      .
    end.
    else do:
      assign
        p-value = p-default-value
      .
    end.
  end.
end procedure.
procedure paramls-append :
  define input  parameter p-code     as character no-undo .
  define input  parameter p-sub-code as character no-undo .
  define input  parameter p-value    as character no-undo .
  define buffer buf_temp-param for temp-param .
  do
  on error undo, return error return-value
  :
    find first buf_temp-param
         where buf_temp-param.param-code     = p-code
           and buf_temp-param.param-sub-code = p-sub-code
      no-error .
    if not available buf_temp-param then do:
      create buf_temp-param .
      assign
        buf_temp-param.param-code     = p-code
        buf_temp-param.param-sub-code = p-sub-code
        buf_temp-param.param-value    = p-value
      .
    end.
    else do:
        assign
            buf_temp-param.param-value = buf_temp-param.param-value + ",":U + p-value
        .
    end.
  end.
end procedure.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-cntxt-host-code-obj
  ,output base-code
  )  .
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define new global shared variable g#libbcrcn as handle no-undo .
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable varscales-pref as character no-undo .
define variable varpgscales-pref as character no-undo .
define variable varscales-pref-type17 as character no-undo.
varscales-pref  = ?.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'sclspref':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output varscales-pref
  ,output varscales-pref-type17
  ) no-error .
if varscales-pref = ? then do:
  assign
  varscales-pref = '21,23,25':U.
end.
define variable varpgscales-pref-type17 as character no-undo.
varpgscales-pref  = ?.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'scpgpref':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output varpgscales-pref
  ,output varpgscales-pref-type17
  ) no-error .
if varpgscales-pref = ? then do:
  assign
  varpgscales-pref = '24IIIIIQQ000C,28IIIIIQQQ00C':U.
end.
define temp-table tt-line no-undo
  field artic     like ub.goods.artic
  field prod-type like ub.goods.prod-type
  field prod-code like ub.goods.prod-code
  field gds-code  like ub.goods.gds-code
  field gds-name  like ub.goods.gds-name
  field grp-name  like ub.goods.grp-name
  field obj-code  like ub.clients.obj-code
  field obj-type  like ub.clients.obj-type
  field obj-name  like ub.clients.obj-name
  field unit      like ub.bar-code.unit-cli
  field rate      like ub.bar-code.cli-base-rate
  field qnty      as decimal
  field sum       as decimal
    index pi is primary gds-code
    index grp-artic   grp-name artic
    index grp-name    grp-name artic prod-type prod-code
    index obj         gds-code obj-type obj-code
    index unit        unit rate
.
define temp-table tt-sum no-undo
  field prod-type like ub.goods.prod-type
  field prod-code like ub.goods.prod-code
  field grp-name  like ub.goods.grp-name
  field obj-code  like ub.clients.obj-code
  field obj-type  like ub.clients.obj-type
  field sum       as decimal
    index pi is primary unique obj-type obj-code grp-name prod-type prod-code
.
define temp-table tt-chk-gds no-undo like ub.chk-gds
  field obj-code  like ub.clients.obj-code
  field obj-type  like ub.clients.obj-type
    index pi is primary b-code src-code obj-code obj-type
.
define buffer bf1_tt-sum for tt-sum.
define buffer bf2_tt-sum for tt-sum.
define buffer bf3_tt-sum for tt-sum.
define buffer bf4_tt-sum for tt-sum.
define buffer bf5_tt-sum for tt-sum.
define buffer bf6_tt-sum for tt-sum.
define buffer bf7_tt-sum for tt-sum.
define buffer buf_chk-doc for ub.chk-doc.
define buffer buf_chk-gds for ub.chk-gds.
define buffer buf_bar-code for ub.bar-code.
define buffer buf_clients for ub.clients.
define buffer buf_gds-obj for ub.gds-obj.
define buffer buf_goods   for ub.goods.
define variable v-sum-itog as decimal no-undo .
define variable CurrGrpName            as character no-undo .
define variable v-NameString           as character no-undo .
define variable v-row                  as integer   no-undo .
define variable v-col                  as integer   no-undo .
define variable v-cur-db-num           as integer   no-undo .
define variable v-db-list              as character no-undo .
define variable v-obj-list             as character no-undo .
define variable   Counter1            as   integer        no-undo.
assign  Counter1 = 0 .
empty temp-table tt-line .
empty temp-table tt-sum  .
v-sum-itog = 0 .
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-cur-db-num
  )  .
if v-cur-db-num = 0 then do :
  for each obj-list no-lock :
    for first db where db.db-num > 0 and db.db-num = obj-list.db-num no-lock :
      if db.send-check = false then do :
        v-db-list = v-db-list + ", " + db.db-name .
        v-obj-list = v-obj-list + ', "' + obj-list.obj-name + '"' .
      end.
    end.
  end.
  if v-obj-list <> ? and v-obj-list <> "" then do :
    v-db-list  = substring(v-db-list,3).
    v-obj-list = substring(v-obj-list,3).
  end.
end.
if v-obj-list <> ? and v-obj-list <> "" then do :
  message ("На " + v-db-list + " отключена пересылка чеков. ~ Данные по " + v-obj-list + " будут нулевыми. ~ Продолжить формирование отчёта?")
  view-as alert-box question buttons yes-no update b as logical .
  if not b then return no-apply .
end.
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
  for each obj-list :
   for each buf_chk-doc where buf_chk-doc.chk-date >= X-date-start     and
                             buf_chk-doc.chk-date <= X-date-end
                             and  buf_chk-doc.obj-type = obj-list.obj-type
                             and buf_chk-doc.obj-code = obj-list.obj-code no-lock :
    for each buf_chk-gds where buf_chk-gds.doc-code  = buf_chk-doc.doc-code and
                               buf_chk-gds.doc-qnty <> 0 no-lock :
      create tt-chk-gds.
      buffer-copy buf_chk-gds to tt-chk-gds.
      assign
        tt-chk-gds.obj-code = buf_chk-doc.obj-code
        tt-chk-gds.obj-type = buf_chk-doc.obj-type
      .
    end.
  end.
      case x-SelectGood :
      when 1 then do:
          for each buf_gds-obj no-lock
            where buf_gds-obj.obj-type  = obj-list.obj-type
              and buf_gds-obj.obj-code  = obj-list.obj-code
            :
            run fill-tt in this-procedure
                          (input buf_gds-obj.artic,
                           input buf_gds-obj.prod-type,
                           input buf_gds-obj.prod-code,
                           input buf_gds-obj.gds-code,
                           input buf_gds-obj.grp-name
                           ) .
            assign Counter1 = Counter1 + 1.
IF ( Counter1 modulo v-account = 0 )  then DO:
          if  log-manager:logfile-name ne ?
          then DO:
              log-manager:write-message("DISP mFrameView=" + string(mFrameView), "frameRepError").
          end.
           if mFrameView
           then do:
            DISPLAY
              Counter1 @ RecordsDone
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
          end.
      end.
        when 3 then do:
          for each G#cli ,
              each buf_gds-obj  no-lock
            where buf_gds-obj.obj-type  = obj-list.obj-type
              and buf_gds-obj.obj-code  = obj-list.obj-code
              and buf_gds-obj.prod-type = G#cli.obj-type
              and buf_gds-obj.prod-code = G#cli.obj-code
             use-index pi  :
             run fill-tt in this-procedure
                          (input artic,
                           input prod-type,
                           input prod-code,
                           input gds-code,
                           input grp-name
                           ).
             assign Counter1 = Counter1 + 1.
IF ( Counter1 modulo v-account = 0 )  then DO:
          if  log-manager:logfile-name ne ?
          then DO:
              log-manager:write-message("DISP mFrameView=" + string(mFrameView), "frameRepError").
          end.
           if mFrameView
           then do:
            DISPLAY
              Counter1 @ RecordsDone
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
          end.
        end .
        when 2 then do:
          for each tmp#grp :
            run grplib-get-full-name in this-procedure( input tmp#grp.node-code, output CurrGrpName ) .
            for each buf_gds-obj no-lock
              where buf_gds-obj.obj-type  = obj-list.obj-type
                and buf_gds-obj.obj-code  = obj-list.obj-code
                and buf_gds-obj.grp-name begins CurrGrpName
              use-index obj-grp :
              run fill-tt in this-procedure
                          (input artic,
                           input prod-type,
                           input prod-code,
                           input gds-code,
                           input grp-name
                           ).
              assign Counter1 = Counter1 + 1.
IF ( Counter1 modulo v-account = 0 )  then DO:
          if  log-manager:logfile-name ne ?
          then DO:
              log-manager:write-message("DISP mFrameView=" + string(mFrameView), "frameRepError").
          end.
           if mFrameView
           then do:
            DISPLAY
              Counter1 @ RecordsDone
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
            end .
          end.
        end.
       otherwise do:
          for each gds-list ,
              each buf_gds-obj no-lock
            where buf_gds-obj.obj-type  = obj-list.obj-type
              and buf_gds-obj.obj-code  = obj-list.obj-code
              and buf_gds-obj.artic     = gds-list.artic
              and buf_gds-obj.prod-type = gds-list.prod-type
              and buf_gds-obj.prod-code = gds-list.prod-code
            :
            run fill-tt in this-procedure
                          (input gds-list.artic,
                           input gds-list.prod-type,
                           input gds-list.prod-code,
                           input gds-list.gds-code,
                           input gds-list.grp-name
                           ).
            assign Counter1 = Counter1 + 1.
IF ( Counter1 modulo v-account = 0 )  then DO:
          if  log-manager:logfile-name ne ?
          then DO:
              log-manager:write-message("DISP mFrameView=" + string(mFrameView), "frameRepError").
          end.
           if mFrameView
           then do:
            DISPLAY
              Counter1 @ RecordsDone
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
          end.
        end.
      end case.
  end.
  run print-header in this-procedure .
  case classify:
    when 1 then run class1 in this-procedure .
    when 2 then run class2 in this-procedure .
    when 3 then run class3 in this-procedure .
    when 4 then run class4 in this-procedure .
    when 5 then run class5 in this-procedure .
  end case.
  if Make-Excel then  put   stream ForExcel unformatted
               CHR(9)
               CHR(9)
               CHR(9)
               CHR(9)
               CHR(9)
               CHR(9)
              "Итого:   "       CHR(9)
              v-sum-itog        CHR(9)
    skip.
if mFrameView
then do:
   HIDE FRAME InfoFrame.
end.
if session :set-wait-state( "" ) then.
  if Make-Excel then output stream ForExcel close.
run get-report-num in my-handle (output g#report-num).
run rep/runexcel.p (string( session:temp-directory) + "rpt" + string( g#report-num ) + ".txt").
Procedure fill-tt :
  define input parameter p-artic     like goods.artic     no-undo.
  define input parameter p-prod-type like goods.prod-type no-undo.
  define input parameter p-prod-code like goods.prod-code no-undo.
  define input parameter p-gds-code  like goods.gds-code  no-undo.
  define input parameter p-grp-name  like goods.grp-name  no-undo.
find first buf_goods where buf_goods.gds-code = p-gds-code no-lock .
  DEFINE BUFFER b_bar-code FOR  ub.bar-code .
  DEFINE BUFFER buf_prod-bc  FOR  ub.prod-bc.
  DEFINE BUFFER buf_place    FOR  ub.place.
  DEFINE VARIABLE v-cResult  AS CHARACTER NO-UNDO INITIAL "".
  DEFINE VARIABLE v-cType-bc AS CHARACTER NO-UNDO INITIAL "".
  DEFINE VARIABLE v-dWeight  AS DECIMAL   NO-UNDO INITIAL 0.
for first buf_bar-code where buf_bar-code.gds-code = p-gds-code  and buf_bar-code.unit-cli = buf_goods.unit-base  no-lock,
       each  tt-chk-gds where tt-chk-gds.b-code = buf_bar-code.b-code  and tt-chk-gds.obj-type = obj-list.obj-type and
                                 tt-chk-gds.obj-code = obj-list.obj-code and tt-chk-gds.doc-qnty <> tt-chk-gds.src-qnty  no-lock break by tt-chk-gds.src-code
        :
if (valid-handle(g#libbcrcn) <> true) then do:   run str/libbcrcn.p persistent no-error .   if error-status :error or (valid-handle(g#libbcrcn) <> true) then do:     message       "Error starting libbcrcn.p" skip       g#libbcrcn skip       g#libbcrcn :type skip       g#libbcrcn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libbcrcn_bc-rcnz in g#libbcrcn
(
 input  parparentproc
,input  tt-chk-gds.src-code
,input  ?
,input  obj-list.obj-type
,input  obj-list.obj-code
,input  yes
,input  no
,input  varscales-pref
,input  varpgscales-pref
,output v-cResult
,output v-cType-bc
,output v-dWeight
,buffer b_bar-code
,buffer buf_prod-bc
,buffer buf_place
) no-error.
          if not available b_bar-code then next.
            if p-det-obj then do :
              find first tt-line where tt-line.gds-code = p-gds-code        and
                                       tt-line.obj-type = obj-list.obj-type and
                                       tt-line.obj-code = obj-list.obj-code and
                                       tt-line.unit     = b_bar-code.unit-cli  and
                                       tt-line.rate     = b_bar-code.cli-base-rate
                                        no-lock no-error.
              if not available tt-line then do :
                create tt-line.
                assign
                  tt-line.artic     = p-artic
                  tt-line.prod-code = p-prod-code
                  tt-line.prod-type = p-prod-type
                  tt-line.gds-code  = p-gds-code
                  tt-line.gds-name  = buf_goods.gds-name
                  tt-line.obj-type  = obj-list.obj-type
                  tt-line.obj-code  = obj-list.obj-code
                  tt-line.obj-name  = obj-list.obj-name
                  tt-line.grp-name  = p-grp-name
                  tt-line.unit      = b_bar-code.unit-cli
                  tt-line.rate      = b_bar-code.cli-base-rate
                  tt-line.qnty      = 0
                  tt-line.sum       = 0
                .
              end.
              assign
                tt-line.qnty = tt-line.qnty + tt-chk-gds.src-qnty
                tt-line.sum  = tt-line.sum  + tt-chk-gds.sum-base
                v-sum-itog   = v-sum-itog   + tt-chk-gds.sum-base
              .
              find first bf1_tt-sum where bf1_tt-sum.obj-type = obj-list.obj-type   and
                                          bf1_tt-sum.obj-code = obj-list.obj-code   and
                                          bf1_tt-sum.prod-type = "-1"               and
                                          bf1_tt-sum.prod-code = -1                 and
                                          bf1_tt-sum.grp-name  = "-1"               no-lock no-error.
              if not available bf1_tt-sum then do :
                create bf1_tt-sum.
                assign
                  bf1_tt-sum.obj-type = obj-list.obj-type
                  bf1_tt-sum.obj-code = obj-list.obj-code
                  bf1_tt-sum.prod-type = "-1"
                  bf1_tt-sum.prod-code = -1
                  bf1_tt-sum.grp-name  = "-1"
                  bf1_tt-sum.sum      = 0
                .
              end.
              bf1_tt-sum.sum = bf1_tt-sum.sum + tt-chk-gds.sum-base.
              find first bf2_tt-sum where bf2_tt-sum.obj-type  = obj-list.obj-type  and
                                      bf2_tt-sum.obj-code  = obj-list.obj-code  and
                                      bf2_tt-sum.prod-type = p-prod-type        and
                                      bf2_tt-sum.prod-code = p-prod-code        and
                                      bf2_tt-sum.grp-name  = "-1"               no-lock no-error.
              if not available bf2_tt-sum then do :
                create bf2_tt-sum.
                assign
                  bf2_tt-sum.obj-type  = obj-list.obj-type
                  bf2_tt-sum.obj-code  = obj-list.obj-code
                  bf2_tt-sum.prod-type = p-prod-type
                  bf2_tt-sum.prod-code = p-prod-code
                  bf2_tt-sum.grp-name  = "-1"
                  bf2_tt-sum.sum       = 0
                .
              end.
              bf2_tt-sum.sum = bf2_tt-sum.sum + tt-chk-gds.sum-base.
              find first bf3_tt-sum where bf3_tt-sum.obj-type  = obj-list.obj-type  and
                                      bf3_tt-sum.obj-code  = obj-list.obj-code  and
                                      bf3_tt-sum.prod-type = "-1"               and
                                      bf3_tt-sum.prod-code = -1                 and
                                      bf3_tt-sum.grp-name  = p-grp-name         no-lock no-error.
              if not available bf3_tt-sum then do :
                create bf3_tt-sum.
                assign
                  bf3_tt-sum.obj-type  = obj-list.obj-type
                  bf3_tt-sum.obj-code  = obj-list.obj-code
                  bf3_tt-sum.prod-type = "-1"
                  bf3_tt-sum.prod-code = -1
                  bf3_tt-sum.grp-name  = p-grp-name
                  bf3_tt-sum.sum       = 0
                .
              end.
              bf3_tt-sum.sum = bf3_tt-sum.sum + tt-chk-gds.sum-base.
              find first bf4_tt-sum where bf4_tt-sum.obj-type  = obj-list.obj-type  and
                                      bf4_tt-sum.obj-code  = obj-list.obj-code  and
                                      bf4_tt-sum.prod-type = p-prod-type        and
                                      bf4_tt-sum.prod-code = p-prod-code        and
                                      bf4_tt-sum.grp-name  = p-grp-name         no-lock no-error.
              if not available bf4_tt-sum then do :
                create bf4_tt-sum.
                assign
                  bf4_tt-sum.obj-type  = obj-list.obj-type
                  bf4_tt-sum.obj-code  = obj-list.obj-code
                  bf4_tt-sum.prod-type = p-prod-type
                  bf4_tt-sum.prod-code = p-prod-code
                  bf4_tt-sum.grp-name  = p-grp-name
                  bf4_tt-sum.sum       = 0
                .
              end.
              bf4_tt-sum.sum = bf4_tt-sum.sum + tt-chk-gds.sum-base.
            end.
            else do :
              find first tt-line where tt-line.gds-code = p-gds-code and
                                       tt-line.unit     = b_bar-code.unit-cli  and
                                       tt-line.rate     = b_bar-code.cli-base-rate
                                       no-lock no-error.
              if not available tt-line then do :
                create tt-line.
                assign
                  tt-line.artic     = p-artic
                  tt-line.prod-code = p-prod-code
                  tt-line.prod-type = p-prod-type
                  tt-line.gds-code  = p-gds-code
                  tt-line.gds-name  = buf_goods.gds-name
                  tt-line.grp-name  = p-grp-name
                  tt-line.unit      = b_bar-code.unit-cli
                  tt-line.rate      = b_bar-code.cli-base-rate
                  tt-line.qnty      = 0
                  tt-line.sum       = 0
                .
              end.
              assign
                tt-line.qnty = tt-line.qnty + tt-chk-gds.src-qnty
                tt-line.sum  = tt-line.sum  + tt-chk-gds.sum-base
                v-sum-itog   = v-sum-itog   + tt-chk-gds.sum-base
              .
            end.
              find first bf5_tt-sum where bf5_tt-sum.obj-type  = "-1"               and
                                      bf5_tt-sum.obj-code  = -1                 and
                                      bf5_tt-sum.prod-type = p-prod-type        and
                                      bf5_tt-sum.prod-code = p-prod-code        and
                                      bf5_tt-sum.grp-name  = "-1"               no-lock no-error.
              if not available bf5_tt-sum then do :
                create bf5_tt-sum.
                assign
                  bf5_tt-sum.obj-type  = "-1"
                  bf5_tt-sum.obj-code  = -1
                  bf5_tt-sum.prod-type = p-prod-type
                  bf5_tt-sum.prod-code = p-prod-code
                  bf5_tt-sum.grp-name  = "-1"
                  bf5_tt-sum.sum       = 0
                .
              end.
              bf5_tt-sum.sum = bf5_tt-sum.sum + tt-chk-gds.sum-base.
              find first bf6_tt-sum where bf6_tt-sum.obj-type  = "-1"               and
                                      bf6_tt-sum.obj-code  = -1                 and
                                      bf6_tt-sum.grp-name  = p-grp-name         and
                                      bf6_tt-sum.prod-type = "-1"               and
                                      bf6_tt-sum.prod-code = -1                 no-lock no-error.
              if not available bf6_tt-sum then do :
                create bf6_tt-sum.
                assign
                  bf6_tt-sum.obj-type  = "-1"
                  bf6_tt-sum.obj-code  = -1
                  bf6_tt-sum.grp-name  = p-grp-name
                  bf6_tt-sum.prod-type = "-1"
                  bf6_tt-sum.prod-code = -1
                  bf6_tt-sum.sum       = 0
                .
              end.
              bf6_tt-sum.sum = bf6_tt-sum.sum + tt-chk-gds.sum-base.
              find first bf7_tt-sum where bf7_tt-sum.obj-type  = "-1"               and
                                      bf7_tt-sum.obj-code  = -1                 and
                                      bf7_tt-sum.prod-type = p-prod-type        and
                                      bf7_tt-sum.prod-code = p-prod-code        and
                                      bf7_tt-sum.grp-name  = p-grp-name         no-lock no-error.
              if not available bf7_tt-sum then do :
                create bf7_tt-sum.
                assign
                  bf7_tt-sum.obj-type  = "-1"
                  bf7_tt-sum.obj-code  = -1
                  bf7_tt-sum.prod-type = p-prod-type
                  bf7_tt-sum.prod-code = p-prod-code
                  bf7_tt-sum.grp-name  = p-grp-name
                  bf7_tt-sum.sum       = 0
                .
              end.
              bf7_tt-sum.sum = bf7_tt-sum.sum + tt-chk-gds.sum-base.
      end.
end.
procedure print-line :
  define input parameter p-line-recid as recid no-undo.
  for tt-line field (artic
                     gds-code
                     gds-name
                     unit
                     rate
                     qnty
                     sum     ) where recid (tt-line) = p-line-recid no-lock :
    if Make-Excel then  put   stream ForExcel unformatted
              tt-line.artic     CHR(9)
              tt-line.gds-code  CHR(9)
              tt-line.gds-name  CHR(9)
              tt-line.unit      CHR(9)
              tt-line.rate      CHR(9)
              tt-line.qnty      CHR(9)
              (tt-line.rate * tt-line.qnty)      CHR(9)
              tt-line.sum       CHR(9)
    skip.
  end.
end.
procedure print-header :
find first sheetf where sheet-num = 1 .
    assign
    Sheetf.MergeCellsH = ""
    Sheetf.MergeCellsV = ""
    Sheetf.Excel-Column-Lable = "Артикул" + chr(44) +
                         "Код" + chr(44) +
                         "Наименование" + chr(44) +
                         "Ед. Изм." + chr(44) +
                         "Коэффициент" + chr(44) +
                         "Оборот в количестве упаковок. (Продажа-возврат)" + chr(44) +
                         "Оборот в количестве в пересчёте на штуки. (Продажа-возврат)" + chr(44) +
                         "Сумма в продажных ценах"
    Sheetf.Sizes = "10,10,80,5,10,15,15,20"
    Sheetf.colformat = "1=@;2=@;3=@;4=@;5=0;6=0;7=0;8=0,00;"
    .
  RUN rep/extitle.p (1).
end.
procedure class1 :
  do on error undo, return error return-value :
  if not p-det-obj then do :
    case SortType:
      when 1 then do:
        for each tt-line break by tt-line.gds-code :  run print-line in this-procedure (input recid(tt-line)) .  end.
      end.
      when 2 then do:
        for each tt-line break by tt-line.artic :     run print-line in this-procedure (input recid(tt-line)) .  end.
      end.
      when 3 then do:
        for each tt-line break by tt-line.gds-name :  run print-line in this-procedure (input recid(tt-line)) .  end.
      end.
    end case.
  end.
  if  p-det-obj then do :
    case SortType:
      when 1 then do:
        for each tt-line break by tt-line.obj-type by tt-line.obj-code by tt-line.gds-code :
          if first-of(tt-line.obj-code) then if Make-Excel then  put   stream ForExcel unformatted tt-line.obj-name skip.
          run print-line in this-procedure (input recid(tt-line)) .
          if last-of(tt-line.obj-code) then do:
            find first tt-sum where tt-sum.obj-type = tt-line.obj-type and
                                    tt-sum.obj-code = tt-line.obj-code and
                                    tt-sum.prod-type = "-1"            and
                                    tt-sum.prod-code = -1              and
                                    tt-sum.grp-name  = "-1"            no-lock no-error.
            if Make-Excel then  put   stream ForExcel unformatted CHR(9) CHR(9) CHR(9) CHR(9)
                        ("Итого по " + string(tt-line.obj-name) + " :")         CHR(9) CHR(9) CHR(9)
                        tt-sum.sum
            skip.
          end.
        end.
      end.
      when 2 then do:
        for each tt-line break by tt-line.obj-type by tt-line.obj-code by tt-line.artic :
          if first-of(tt-line.obj-code) then if Make-Excel then  put   stream ForExcel unformatted tt-line.obj-name skip.
          run print-line in this-procedure (input recid(tt-line)) .
          if last-of(tt-line.obj-code) then do:
            find first tt-sum where tt-sum.obj-type = tt-line.obj-type and
                                    tt-sum.obj-code = tt-line.obj-code and
                                    tt-sum.prod-type = "-1"            and
                                    tt-sum.prod-code = -1              and
                                    tt-sum.grp-name  = "-1"            no-lock no-error.
            if Make-Excel then  put   stream ForExcel unformatted CHR(9) CHR(9) CHR(9) CHR(9)
                        ("Итого по " + string(tt-line.obj-name) + " :")         CHR(9) CHR(9) CHR(9)
                        tt-sum.sum
            skip.
          end.
        end.
      end.
      when 3 then do:
        for each tt-line break by tt-line.obj-type by tt-line.obj-code by tt-line.gds-name :
          if first-of(tt-line.obj-code) then if Make-Excel then  put   stream ForExcel unformatted tt-line.obj-name skip.
          run print-line in this-procedure (input recid(tt-line)) .
          if last-of(tt-line.obj-code) then do:
            find first tt-sum where tt-sum.obj-type = tt-line.obj-type and
                                    tt-sum.obj-code = tt-line.obj-code and
                                    tt-sum.prod-type = "-1"            and
                                    tt-sum.prod-code = -1              and
                                    tt-sum.grp-name  = "-1"            no-lock no-error.
            if Make-Excel then  put   stream ForExcel unformatted CHR(9) CHR(9) CHR(9) CHR(9)
                        ("Итого по " + string(tt-line.obj-name) + " :")         CHR(9) CHR(9) CHR(9)
                        tt-sum.sum
            skip.
          end.
        end.
      end.
    end case.
  end.
  end.
end procedure.
procedure class2 :
  do on error undo, return error return-value :
  if not p-det-obj then do :
    case SortType:
      when 1 then do:
        for each tt-line break by tt-line.prod-type by tt-line.prod-code by tt-line.gds-code :
          if first-of(tt-line.prod-code) then do:
            find first buf_clients no-lock where buf_clients.obj-type = tt-line.prod-type and buf_clients.obj-code = tt-line.prod-code .
            if Make-Excel then  put   stream ForExcel unformatted buf_clients.obj-name skip.
          end.
          run print-line in this-procedure (input recid(tt-line)) .
          if last-of(tt-line.prod-code) then do:
            find first tt-sum where tt-sum.obj-type  = "-1"              and
                                    tt-sum.obj-code  = -1                and
                                    tt-sum.prod-type = tt-line.prod-type and
                                    tt-sum.prod-code = tt-line.prod-code and
                                    tt-sum.grp-name  = "-1"              no-lock no-error.
            if Make-Excel then  put   stream ForExcel unformatted CHR(9) CHR(9) CHR(9) CHR(9)
                        ("Итого по " + string(buf_clients.obj-name) + " :")         CHR(9) CHR(9) CHR(9)
                        tt-sum.sum
            skip.
          end.
        end.
      end.
      when 2 then do:
        for each tt-line break by tt-line.prod-type by tt-line.prod-code by tt-line.artic :
          if first-of(tt-line.prod-code) then do:
            find first buf_clients no-lock where buf_clients.obj-type = tt-line.prod-type and buf_clients.obj-code = tt-line.prod-code .
            if Make-Excel then  put   stream ForExcel unformatted buf_clients.obj-name skip.
          end.
          run print-line in this-procedure (input recid(tt-line)) .
          if last-of(tt-line.prod-code) then do:
            find first tt-sum where tt-sum.obj-type  = "-1"              and
                                    tt-sum.obj-code  = -1                and
                                    tt-sum.prod-type = tt-line.prod-type and
                                    tt-sum.prod-code = tt-line.prod-code and
                                    tt-sum.grp-name  = "-1"              no-lock no-error.
            if Make-Excel then  put   stream ForExcel unformatted CHR(9) CHR(9) CHR(9) CHR(9)
                        ("Итого по " + string(buf_clients.obj-name) + " :")         CHR(9) CHR(9) CHR(9)
                        tt-sum.sum
            skip.
          end.
        end.
      end.
      when 3 then do:
        for each tt-line break by tt-line.prod-type by tt-line.prod-code by tt-line.gds-name :
          if first-of(tt-line.prod-code) then do:
            find first buf_clients no-lock where buf_clients.obj-type = tt-line.prod-type and buf_clients.obj-code = tt-line.prod-code .
            if Make-Excel then  put   stream ForExcel unformatted buf_clients.obj-name skip.
          end.
          run print-line in this-procedure (input recid(tt-line)) .
          if last-of(tt-line.prod-code) then do:
            find first tt-sum where tt-sum.obj-type  = "-1"              and
                                    tt-sum.obj-code  = -1                and
                                    tt-sum.prod-type = tt-line.prod-type and
                                    tt-sum.prod-code = tt-line.prod-code and
                                    tt-sum.grp-name  = "-1"              no-lock no-error.
            if Make-Excel then  put   stream ForExcel unformatted CHR(9) CHR(9) CHR(9) CHR(9)
                        ("Итого по " + string(buf_clients.obj-name) + " :")         CHR(9) CHR(9) CHR(9)
                        tt-sum.sum
            skip.
          end.
        end.
      end.
    end case.
  end.
  if p-det-obj then do :
    case SortType:
      when 1 then do:
        for each tt-line break by tt-line.obj-type by tt-line.obj-code by tt-line.prod-type by tt-line.prod-code by tt-line.gds-code :
          if first-of(tt-line.obj-code) then if Make-Excel then  put   stream ForExcel unformatted tt-line.obj-name skip.
          if first-of(tt-line.prod-code) then do:
            find first buf_clients no-lock where buf_clients.obj-type = tt-line.prod-type and buf_clients.obj-code = tt-line.prod-code .
            if Make-Excel then  put   stream ForExcel unformatted buf_clients.obj-name skip.
          end.
          run print-line in this-procedure (input recid(tt-line)) .
          if last-of(tt-line.prod-code) then do:
            find first tt-sum where tt-sum.obj-type  = tt-line.obj-type  and
                                    tt-sum.obj-code  = tt-line.obj-code  and
                                    tt-sum.prod-type = tt-line.prod-type and
                                    tt-sum.prod-code = tt-line.prod-code and
                                    tt-sum.grp-name  = "-1"              no-lock no-error.
            if Make-Excel then  put   stream ForExcel unformatted CHR(9) CHR(9) CHR(9) CHR(9)
                        ("Итого по " + string(buf_clients.obj-name) + " :")         CHR(9) CHR(9) CHR(9)
                        tt-sum.sum
            skip.
          end.
          if last-of(tt-line.obj-code) then do:
            find first tt-sum where tt-sum.obj-type = tt-line.obj-type and
                                    tt-sum.obj-code = tt-line.obj-code and
                                    tt-sum.prod-type = "-1"            and
                                    tt-sum.prod-code = -1              and
                                    tt-sum.grp-name  = "-1"            no-lock no-error.
            if Make-Excel then  put   stream ForExcel unformatted CHR(9) CHR(9) CHR(9) CHR(9)
                        ("Итого по " + string(tt-line.obj-name) + " :")         CHR(9) CHR(9) CHR(9)
                        tt-sum.sum
            skip.
          end.
        end.
      end.
      when 2 then do:
        for each tt-line break by tt-line.obj-type by tt-line.obj-code by tt-line.prod-type by tt-line.prod-code by tt-line.artic :
          if first-of(tt-line.obj-code) then if Make-Excel then  put   stream ForExcel unformatted tt-line.obj-name skip.
          if first-of(tt-line.prod-code) then do:
            find first buf_clients no-lock where buf_clients.obj-type = tt-line.prod-type and buf_clients.obj-code = tt-line.prod-code .
            if Make-Excel then  put   stream ForExcel unformatted buf_clients.obj-name skip.
          end.
          run print-line in this-procedure (input recid(tt-line)) .
          if last-of(tt-line.prod-code) then do:
            find first tt-sum where tt-sum.obj-type  = tt-line.obj-type  and
                                    tt-sum.obj-code  = tt-line.obj-code  and
                                    tt-sum.prod-type = tt-line.prod-type and
                                    tt-sum.prod-code = tt-line.prod-code and
                                    tt-sum.grp-name  = "-1"              no-lock no-error.
            if Make-Excel then  put   stream ForExcel unformatted CHR(9) CHR(9) CHR(9) CHR(9)
                        ("Итого по " + string(buf_clients.obj-name) + " :")         CHR(9) CHR(9) CHR(9)
                        tt-sum.sum
            skip.
          end.
          if last-of(tt-line.obj-code) then do:
            find first tt-sum where tt-sum.obj-type = tt-line.obj-type and
                                    tt-sum.obj-code = tt-line.obj-code and
                                    tt-sum.prod-type = "-1"            and
                                    tt-sum.prod-code = -1              and
                                    tt-sum.grp-name  = "-1"            no-lock no-error.
            if Make-Excel then  put   stream ForExcel unformatted CHR(9) CHR(9) CHR(9) CHR(9)
                        ("Итого по " + string(tt-line.obj-name) + " :")         CHR(9) CHR(9) CHR(9)
                        tt-sum.sum
            skip.
          end.
        end.
      end.
      when 3 then do:
        for each tt-line break by tt-line.obj-type by tt-line.obj-code by tt-line.prod-type by tt-line.prod-code by tt-line.gds-name :
          if first-of(tt-line.obj-code) then if Make-Excel then  put   stream ForExcel unformatted tt-line.obj-name skip.
          if first-of(tt-line.prod-code) then do:
            find first buf_clients no-lock where buf_clients.obj-type = tt-line.prod-type and buf_clients.obj-code = tt-line.prod-code .
            if Make-Excel then  put   stream ForExcel unformatted buf_clients.obj-name skip.
          end.
          run print-line in this-procedure (input recid(tt-line)) .
          if last-of(tt-line.prod-code) then do:
            find first tt-sum where tt-sum.obj-type  = tt-line.obj-type  and
                                    tt-sum.obj-code  = tt-line.obj-code  and
                                    tt-sum.prod-type = tt-line.prod-type and
                                    tt-sum.prod-code = tt-line.prod-code and
                                    tt-sum.grp-name  = "-1"              no-lock no-error.
            if Make-Excel then  put   stream ForExcel unformatted CHR(9) CHR(9) CHR(9) CHR(9)
                        ("Итого по " + string(buf_clients.obj-name) + " :")         CHR(9) CHR(9) CHR(9)
                        tt-sum.sum
            skip.
          end.
          if last-of(tt-line.obj-code) then do:
            find first tt-sum where tt-sum.obj-type = tt-line.obj-type and
                                    tt-sum.obj-code = tt-line.obj-code and
                                    tt-sum.prod-type = "-1"            and
                                    tt-sum.prod-code = -1              and
                                    tt-sum.grp-name  = "-1"            no-lock no-error.
            if Make-Excel then  put   stream ForExcel unformatted CHR(9) CHR(9) CHR(9) CHR(9)
                        ("Итого по " + string(tt-line.obj-name) + " :")         CHR(9) CHR(9) CHR(9)
                        tt-sum.sum
            skip.
          end.
        end.
      end.
    end case.
  end.
  end.
end procedure.
procedure class3 :
  do on error undo, return error return-value :
  if not p-det-obj then do :
    case SortType:
      when 1 then do:
        for each tt-line break by tt-line.grp-name by tt-line.gds-code :
          if first-of(tt-line.grp-name) then do:
            if Make-Excel then  put   stream ForExcel unformatted tt-line.grp-name skip.
          end.
          run print-line in this-procedure (input recid(tt-line)) .
          if last-of(tt-line.grp-name) then do:
            find first tt-sum where tt-sum.obj-type  = "-1"              and
                                    tt-sum.obj-code  = -1                and
                                    tt-sum.prod-type = "-1"              and
                                    tt-sum.prod-code = -1                and
                                    tt-sum.grp-name  = tt-line.grp-name  no-lock no-error.
            if Make-Excel then  put   stream ForExcel unformatted CHR(9) CHR(9) CHR(9) CHR(9)
                        ("Итого по " + string(tt-line.grp-name) + " :")         CHR(9) CHR(9) CHR(9)
                        tt-sum.sum
            skip.
          end.
        end.
      end.
      when 2 then do:
        for each tt-line break by tt-line.grp-name by tt-line.artic :
          if first-of(tt-line.grp-name) then do:
            if Make-Excel then  put   stream ForExcel unformatted tt-line.grp-name skip.
          end.
          run print-line in this-procedure (input recid(tt-line)) .
          if last-of(tt-line.grp-name) then do:
            find first tt-sum where tt-sum.obj-type  = "-1"              and
                                    tt-sum.obj-code  = -1                and
                                    tt-sum.prod-type = "-1"              and
                                    tt-sum.prod-code = -1                and
                                    tt-sum.grp-name  = tt-line.grp-name  no-lock no-error.
            if Make-Excel then  put   stream ForExcel unformatted CHR(9) CHR(9) CHR(9) CHR(9)
                        ("Итого по " + string(tt-line.grp-name) + " :")         CHR(9) CHR(9) CHR(9)
                        tt-sum.sum
            skip.
          end.
        end.
      end.
      when 3 then do:
        for each tt-line break by tt-line.grp-name by tt-line.gds-name :
          if first-of(tt-line.grp-name) then do:
            if Make-Excel then  put   stream ForExcel unformatted tt-line.grp-name skip.
          end.
          run print-line in this-procedure (input recid(tt-line)) .
          if last-of(tt-line.grp-name) then do:
            find first tt-sum where tt-sum.obj-type  = "-1"              and
                                    tt-sum.obj-code  = -1                and
                                    tt-sum.prod-type = "-1"              and
                                    tt-sum.prod-code = -1                and
                                    tt-sum.grp-name  = tt-line.grp-name  no-lock no-error.
            if Make-Excel then  put   stream ForExcel unformatted CHR(9) CHR(9) CHR(9) CHR(9)
                        ("Итого по " + string(tt-line.grp-name) + " :")         CHR(9) CHR(9) CHR(9)
                        tt-sum.sum
            skip.
          end.
        end.
      end.
    end case.
  end.
  if p-det-obj then do :
    case SortType:
      when 1 then do:
        for each tt-line break by tt-line.obj-type by tt-line.obj-code by tt-line.grp-name by tt-line.gds-code :
          if first-of(tt-line.obj-code) then if Make-Excel then  put   stream ForExcel unformatted tt-line.obj-name skip.
          if first-of(tt-line.grp-name) then do:
            if Make-Excel then  put   stream ForExcel unformatted tt-line.grp-name skip.
          end.
          run print-line in this-procedure (input recid(tt-line)) .
          if last-of(tt-line.grp-name) then do:
            find first tt-sum where tt-sum.obj-type  = tt-line.obj-type  and
                                    tt-sum.obj-code  = tt-line.obj-code  and
                                    tt-sum.prod-type = "-1"              and
                                    tt-sum.prod-code = -1                and
                                    tt-sum.grp-name  = tt-line.grp-name  no-lock no-error.
            if Make-Excel then  put   stream ForExcel unformatted CHR(9) CHR(9) CHR(9) CHR(9)
                        ("Итого по " + string(tt-line.grp-name) + " :")         CHR(9) CHR(9) CHR(9)
                        tt-sum.sum
            skip.
          end.
          if last-of(tt-line.obj-code) then do:
            find first tt-sum where tt-sum.obj-type = tt-line.obj-type and
                                    tt-sum.obj-code = tt-line.obj-code and
                                    tt-sum.prod-type = "-1"            and
                                    tt-sum.prod-code = -1              and
                                    tt-sum.grp-name  = "-1"            no-lock no-error.
            if Make-Excel then  put   stream ForExcel unformatted CHR(9) CHR(9) CHR(9) CHR(9)
                        ("Итого по " + string(tt-line.obj-name) + " :")         CHR(9) CHR(9) CHR(9)
                        tt-sum.sum
            skip.
          end.
        end.
      end.
      when 2 then do:
        for each tt-line break by tt-line.obj-type by tt-line.obj-code by tt-line.grp-name by tt-line.artic :
          if first-of(tt-line.obj-code) then if Make-Excel then  put   stream ForExcel unformatted tt-line.obj-name skip.
          if first-of(tt-line.grp-name) then do:
            if Make-Excel then  put   stream ForExcel unformatted tt-line.grp-name skip.
          end.
          run print-line in this-procedure (input recid(tt-line)) .
          if last-of(tt-line.grp-name) then do:
            find first tt-sum where tt-sum.obj-type  = tt-line.obj-type  and
                                    tt-sum.obj-code  = tt-line.obj-code  and
                                    tt-sum.prod-type = "-1"              and
                                    tt-sum.prod-code = -1                and
                                    tt-sum.grp-name  = tt-line.grp-name  no-lock no-error.
            if Make-Excel then  put   stream ForExcel unformatted CHR(9) CHR(9) CHR(9) CHR(9)
                        ("Итого по " + string(tt-line.grp-name) + " :")         CHR(9) CHR(9) CHR(9)
                        tt-sum.sum
            skip.
          end.
          if last-of(tt-line.obj-code) then do:
            find first tt-sum where tt-sum.obj-type = tt-line.obj-type and
                                    tt-sum.obj-code = tt-line.obj-code and
                                    tt-sum.prod-type = "-1"            and
                                    tt-sum.prod-code = -1              and
                                    tt-sum.grp-name  = "-1"            no-lock no-error.
            if Make-Excel then  put   stream ForExcel unformatted CHR(9) CHR(9) CHR(9) CHR(9)
                        ("Итого по " + string(tt-line.obj-name) + " :")         CHR(9) CHR(9) CHR(9)
                        tt-sum.sum
            skip.
          end.
        end.
      end.
      when 3 then do:
        for each tt-line break by tt-line.obj-type by tt-line.obj-code by tt-line.grp-name by tt-line.gds-name :
          if first-of(tt-line.obj-code) then if Make-Excel then  put   stream ForExcel unformatted tt-line.obj-name skip.
          if first-of(tt-line.grp-name) then do:
            if Make-Excel then  put   stream ForExcel unformatted tt-line.grp-name skip.
          end.
          run print-line in this-procedure (input recid(tt-line)) .
          if last-of(tt-line.grp-name) then do:
            find first tt-sum where tt-sum.obj-type  = tt-line.obj-type  and
                                    tt-sum.obj-code  = tt-line.obj-code  and
                                    tt-sum.prod-type = "-1"              and
                                    tt-sum.prod-code = -1                and
                                    tt-sum.grp-name  = tt-line.grp-name  no-lock no-error.
            if Make-Excel then  put   stream ForExcel unformatted CHR(9) CHR(9) CHR(9) CHR(9)
                        ("Итого по " + string(tt-line.grp-name) + " :")         CHR(9) CHR(9) CHR(9)
                        tt-sum.sum
            skip.
          end.
          if last-of(tt-line.obj-code) then do:
            find first tt-sum where tt-sum.obj-type = tt-line.obj-type and
                                    tt-sum.obj-code = tt-line.obj-code and
                                    tt-sum.prod-type = "-1"            and
                                    tt-sum.prod-code = -1              and
                                    tt-sum.grp-name  = "-1"            no-lock no-error.
            if Make-Excel then  put   stream ForExcel unformatted CHR(9) CHR(9) CHR(9) CHR(9)
                        ("Итого по " + string(tt-line.obj-name) + " :")         CHR(9) CHR(9) CHR(9)
                        tt-sum.sum
            skip.
          end.
        end.
      end.
    end case.
  end.
  end.
end procedure.
procedure class4 :
  do on error undo, return error return-value :
  if not p-det-obj then do :
    case SortType:
      when 1 then do:
        for each tt-line break by tt-line.prod-type by tt-line.prod-code by tt-line.grp-name by tt-line.gds-code :
          if first-of(tt-line.prod-code) then do:
            find first buf_clients no-lock where buf_clients.obj-type = tt-line.prod-type and buf_clients.obj-code = tt-line.prod-code .
            if Make-Excel then  put   stream ForExcel unformatted buf_clients.obj-name skip.
          end.
          if first-of(tt-line.grp-name) then do:
            if Make-Excel then  put   stream ForExcel unformatted tt-line.grp-name skip.
          end.
          run print-line in this-procedure (input recid(tt-line)) .
          if last-of(tt-line.grp-name) then do:
            find first tt-sum where tt-sum.obj-type  = "-1"              and
                                    tt-sum.obj-code  = -1                and
                                    tt-sum.prod-type = tt-line.prod-type and
                                    tt-sum.prod-code = tt-line.prod-code and
                                    tt-sum.grp-name  = tt-line.grp-name  no-lock no-error.
            if Make-Excel then  put   stream ForExcel unformatted CHR(9) CHR(9) CHR(9) CHR(9)
                        ("Итого по " + string(tt-line.grp-name) + " :")         CHR(9) CHR(9) CHR(9)
                        tt-sum.sum
            skip.
          end.
          if last-of(tt-line.prod-code) then do:
            find first tt-sum where tt-sum.obj-type  = "-1"              and
                                    tt-sum.obj-code  = -1                and
                                    tt-sum.prod-type = tt-line.prod-type and
                                    tt-sum.prod-code = tt-line.prod-code and
                                    tt-sum.grp-name  = "-1"              no-lock no-error.
            if Make-Excel then  put   stream ForExcel unformatted CHR(9) CHR(9) CHR(9) CHR(9)
                        ("Итого по " + string(buf_clients.obj-name) + " :")         CHR(9) CHR(9) CHR(9)
                        tt-sum.sum
            skip.
          end.
        end.
      end.
      when 2 then do:
        for each tt-line break by tt-line.prod-type by tt-line.prod-code by tt-line.grp-name by tt-line.artic :
          if first-of(tt-line.prod-code) then do:
            find first buf_clients no-lock where buf_clients.obj-type = tt-line.prod-type and buf_clients.obj-code = tt-line.prod-code .
            if Make-Excel then  put   stream ForExcel unformatted buf_clients.obj-name skip.
          end.
          if first-of(tt-line.grp-name) then do:
            if Make-Excel then  put   stream ForExcel unformatted tt-line.grp-name skip.
          end.
          run print-line in this-procedure (input recid(tt-line)) .
          if last-of(tt-line.grp-name) then do:
            find first tt-sum where tt-sum.obj-type  = "-1"              and
                                    tt-sum.obj-code  = -1                and
                                    tt-sum.prod-type = tt-line.prod-type and
                                    tt-sum.prod-code = tt-line.prod-code and
                                    tt-sum.grp-name  = tt-line.grp-name  no-lock no-error.
            if Make-Excel then  put   stream ForExcel unformatted CHR(9) CHR(9) CHR(9) CHR(9)
                        ("Итого по " + string(tt-line.grp-name) + " :")         CHR(9) CHR(9) CHR(9)
                        tt-sum.sum
            skip.
          end.
          if last-of(tt-line.prod-code) then do:
            find first tt-sum where tt-sum.obj-type  = "-1"              and
                                    tt-sum.obj-code  = -1                and
                                    tt-sum.prod-type = tt-line.prod-type and
                                    tt-sum.prod-code = tt-line.prod-code and
                                    tt-sum.grp-name  = "-1"              no-lock no-error.
            if Make-Excel then  put   stream ForExcel unformatted CHR(9) CHR(9) CHR(9) CHR(9)
                        ("Итого по " + string(buf_clients.obj-name) + " :")         CHR(9) CHR(9) CHR(9)
                        tt-sum.sum
            skip.
          end.
        end.
      end.
      when 3 then do:
        for each tt-line break by tt-line.prod-type by tt-line.prod-code by tt-line.grp-name by tt-line.gds-name :
          if first-of(tt-line.prod-code) then do:
            find first buf_clients no-lock where buf_clients.obj-type = tt-line.prod-type and buf_clients.obj-code = tt-line.prod-code .
            if Make-Excel then  put   stream ForExcel unformatted buf_clients.obj-name skip.
          end.
          if first-of(tt-line.grp-name) then do:
            if Make-Excel then  put   stream ForExcel unformatted tt-line.grp-name skip.
          end.
          run print-line in this-procedure (input recid(tt-line)) .
          if last-of(tt-line.grp-name) then do:
            find first tt-sum where tt-sum.obj-type  = "-1"              and
                                    tt-sum.obj-code  = -1                and
                                    tt-sum.prod-type = tt-line.prod-type and
                                    tt-sum.prod-code = tt-line.prod-code and
                                    tt-sum.grp-name  = tt-line.grp-name  no-lock no-error.
            if Make-Excel then  put   stream ForExcel unformatted CHR(9) CHR(9) CHR(9) CHR(9)
                        ("Итого по " + string(tt-line.grp-name) + " :")         CHR(9) CHR(9) CHR(9)
                        tt-sum.sum
            skip.
          end.
          if last-of(tt-line.prod-code) then do:
            find first tt-sum where tt-sum.obj-type  = "-1"              and
                                    tt-sum.obj-code  = -1                and
                                    tt-sum.prod-type = tt-line.prod-type and
                                    tt-sum.prod-code = tt-line.prod-code and
                                    tt-sum.grp-name  = "-1"              no-lock no-error.
            if Make-Excel then  put   stream ForExcel unformatted CHR(9) CHR(9) CHR(9) CHR(9)
                        ("Итого по " + string(buf_clients.obj-name) + " :")         CHR(9) CHR(9) CHR(9)
                        tt-sum.sum
            skip.
          end.
        end.
      end.
    end case.
  end.
  if p-det-obj then do :
    case SortType:
      when 1 then do:
        for each tt-line break by tt-line.obj-type by tt-line.obj-code by tt-line.prod-type by tt-line.prod-code by tt-line.grp-name by tt-line.gds-code :
          if first-of(tt-line.obj-code) then if Make-Excel then  put   stream ForExcel unformatted tt-line.obj-name skip.
          if first-of(tt-line.prod-code) then do:
            find first buf_clients no-lock where buf_clients.obj-type = tt-line.prod-type and buf_clients.obj-code = tt-line.prod-code .
            if Make-Excel then  put   stream ForExcel unformatted buf_clients.obj-name skip.
          end.
          if first-of(tt-line.grp-name) then do:
            if Make-Excel then  put   stream ForExcel unformatted tt-line.grp-name skip.
          end.
          run print-line in this-procedure (input recid(tt-line)) .
          if last-of(tt-line.grp-name) then do:
            find first tt-sum where tt-sum.obj-type  = tt-line.obj-type  and
                                    tt-sum.obj-code  = tt-line.obj-code  and
                                    tt-sum.prod-type = tt-line.prod-type and
                                    tt-sum.prod-code = tt-line.prod-code and
                                    tt-sum.grp-name  = tt-line.grp-name  no-lock no-error.
            if Make-Excel then  put   stream ForExcel unformatted CHR(9) CHR(9) CHR(9) CHR(9)
                        ("Итого по " + string(tt-line.grp-name) + " :")         CHR(9) CHR(9) CHR(9)
                        tt-sum.sum
            skip.
          end.
          if last-of(tt-line.prod-code) then do:
            find first tt-sum where tt-sum.obj-type  = tt-line.obj-type  and
                                    tt-sum.obj-code  = tt-line.obj-code  and
                                    tt-sum.prod-type = tt-line.prod-type and
                                    tt-sum.prod-code = tt-line.prod-code and
                                    tt-sum.grp-name  = "-1"              no-lock no-error.
            if Make-Excel then  put   stream ForExcel unformatted CHR(9) CHR(9) CHR(9) CHR(9)
                        ("Итого по " + string(buf_clients.obj-name) + " :")         CHR(9) CHR(9) CHR(9)
                        tt-sum.sum
            skip.
          end.
          if last-of(tt-line.obj-code) then do:
            find first tt-sum where tt-sum.obj-type = tt-line.obj-type and
                                    tt-sum.obj-code = tt-line.obj-code and
                                    tt-sum.prod-type = "-1"            and
                                    tt-sum.prod-code = -1              and
                                    tt-sum.grp-name  = "-1"            no-lock no-error.
            if Make-Excel then  put   stream ForExcel unformatted CHR(9) CHR(9) CHR(9) CHR(9)
                        ("Итого по " + string(tt-line.obj-name) + " :")         CHR(9) CHR(9) CHR(9)
                        tt-sum.sum
            skip.
          end.
        end.
      end.
      when 2 then do:
        for each tt-line break by tt-line.obj-type by tt-line.obj-code by tt-line.prod-type by tt-line.prod-code by tt-line.grp-name by tt-line.artic :
          if first-of(tt-line.obj-code) then if Make-Excel then  put   stream ForExcel unformatted tt-line.obj-name skip.
          if first-of(tt-line.prod-code) then do:
            find first buf_clients no-lock where buf_clients.obj-type = tt-line.prod-type and buf_clients.obj-code = tt-line.prod-code .
            if Make-Excel then  put   stream ForExcel unformatted buf_clients.obj-name skip.
          end.
          if first-of(tt-line.grp-name) then do:
            if Make-Excel then  put   stream ForExcel unformatted tt-line.grp-name skip.
          end.
          run print-line in this-procedure (input recid(tt-line)) .
          if last-of(tt-line.grp-name) then do:
            find first tt-sum where tt-sum.obj-type  = tt-line.obj-type  and
                                    tt-sum.obj-code  = tt-line.obj-code  and
                                    tt-sum.prod-type = tt-line.prod-type and
                                    tt-sum.prod-code = tt-line.prod-code and
                                    tt-sum.grp-name  = tt-line.grp-name  no-lock no-error.
            if Make-Excel then  put   stream ForExcel unformatted CHR(9) CHR(9) CHR(9) CHR(9)
                        ("Итого по " + string(tt-line.grp-name) + " :")         CHR(9) CHR(9) CHR(9)
                        tt-sum.sum
            skip.
          end.
          if last-of(tt-line.prod-code) then do:
            find first tt-sum where tt-sum.obj-type  = tt-line.obj-type  and
                                    tt-sum.obj-code  = tt-line.obj-code  and
                                    tt-sum.prod-type = tt-line.prod-type and
                                    tt-sum.prod-code = tt-line.prod-code and
                                    tt-sum.grp-name  = "-1"              no-lock no-error.
            if Make-Excel then  put   stream ForExcel unformatted CHR(9) CHR(9) CHR(9) CHR(9)
                        ("Итого по " + string(buf_clients.obj-name) + " :")         CHR(9) CHR(9) CHR(9)
                        tt-sum.sum
            skip.
          end.
          if last-of(tt-line.obj-code) then do:
            find first tt-sum where tt-sum.obj-type = tt-line.obj-type and
                                    tt-sum.obj-code = tt-line.obj-code and
                                    tt-sum.prod-type = "-1"            and
                                    tt-sum.prod-code = -1              and
                                    tt-sum.grp-name  = "-1"            no-lock no-error.
            if Make-Excel then  put   stream ForExcel unformatted CHR(9) CHR(9) CHR(9) CHR(9)
                        ("Итого по " + string(tt-line.obj-name) + " :")         CHR(9) CHR(9) CHR(9)
                        tt-sum.sum
            skip.
          end.
        end.
      end.
      when 3 then do:
        for each tt-line break by tt-line.obj-type by tt-line.obj-code by tt-line.prod-type by tt-line.prod-code by tt-line.grp-name by tt-line.gds-name :
          if first-of(tt-line.obj-code) then if Make-Excel then  put   stream ForExcel unformatted tt-line.obj-name skip.
          if first-of(tt-line.prod-code) then do:
            find first buf_clients no-lock where buf_clients.obj-type = tt-line.prod-type and buf_clients.obj-code = tt-line.prod-code .
            if Make-Excel then  put   stream ForExcel unformatted buf_clients.obj-name skip.
          end.
          if first-of(tt-line.grp-name) then do:
            if Make-Excel then  put   stream ForExcel unformatted tt-line.grp-name skip.
          end.
          run print-line in this-procedure (input recid(tt-line)) .
          if last-of(tt-line.grp-name) then do:
            find first tt-sum where tt-sum.obj-type  = tt-line.obj-type  and
                                    tt-sum.obj-code  = tt-line.obj-code  and
                                    tt-sum.prod-type = tt-line.prod-type and
                                    tt-sum.prod-code = tt-line.prod-code and
                                    tt-sum.grp-name  = tt-line.grp-name  no-lock no-error.
            if Make-Excel then  put   stream ForExcel unformatted CHR(9) CHR(9) CHR(9) CHR(9)
                        ("Итого по " + string(tt-line.grp-name) + " :")         CHR(9) CHR(9) CHR(9)
                        tt-sum.sum
            skip.
          end.
          if last-of(tt-line.prod-code) then do:
            find first tt-sum where tt-sum.obj-type  = tt-line.obj-type  and
                                    tt-sum.obj-code  = tt-line.obj-code  and
                                    tt-sum.prod-type = tt-line.prod-type and
                                    tt-sum.prod-code = tt-line.prod-code and
                                    tt-sum.grp-name  = "-1"              no-lock no-error.
            if Make-Excel then  put   stream ForExcel unformatted CHR(9) CHR(9) CHR(9) CHR(9)
                        ("Итого по " + string(buf_clients.obj-name) + " :")         CHR(9) CHR(9) CHR(9)
                        tt-sum.sum
            skip.
          end.
          if last-of(tt-line.obj-code) then do:
            find first tt-sum where tt-sum.obj-type = tt-line.obj-type and
                                    tt-sum.obj-code = tt-line.obj-code and
                                    tt-sum.prod-type = "-1"            and
                                    tt-sum.prod-code = -1              and
                                    tt-sum.grp-name  = "-1"            no-lock no-error.
            if Make-Excel then  put   stream ForExcel unformatted CHR(9) CHR(9) CHR(9) CHR(9)
                        ("Итого по " + string(tt-line.obj-name) + " :")         CHR(9) CHR(9) CHR(9)
                        tt-sum.sum
            skip.
          end.
        end.
      end.
    end case.
  end.
  end.
end procedure.
procedure class5 :
  do on error undo, return error return-value :
  if not p-det-obj then do :
    case SortType:
      when 1 then do:
        for each tt-line break by tt-line.grp-name by tt-line.prod-type by tt-line.prod-code by tt-line.gds-code :
          if first-of(tt-line.grp-name) then do:
            if Make-Excel then  put   stream ForExcel unformatted tt-line.grp-name skip.
          end.
          if first-of(tt-line.prod-code) then do:
            find first buf_clients no-lock where buf_clients.obj-type = tt-line.prod-type and buf_clients.obj-code = tt-line.prod-code .
            if Make-Excel then  put   stream ForExcel unformatted buf_clients.obj-name skip.
          end.
          run print-line in this-procedure (input recid(tt-line)) .
          if last-of(tt-line.prod-code) then do:
            find first tt-sum where tt-sum.obj-type  = "-1"              and
                                    tt-sum.obj-code  = -1                and
                                    tt-sum.prod-type = tt-line.prod-type and
                                    tt-sum.prod-code = tt-line.prod-code and
                                    tt-sum.grp-name  = tt-line.grp-name  no-lock no-error.
            if Make-Excel then  put   stream ForExcel unformatted CHR(9) CHR(9) CHR(9) CHR(9)
                        ("Итого по " + string(buf_clients.obj-name) + " :")         CHR(9) CHR(9) CHR(9)
                        tt-sum.sum
            skip.
          end.
          if last-of(tt-line.grp-name) then do:
            find first tt-sum where tt-sum.obj-type  = "-1"              and
                                    tt-sum.obj-code  = -1                and
                                    tt-sum.prod-type = "-1"              and
                                    tt-sum.prod-code = -1                and
                                    tt-sum.grp-name  = tt-line.grp-name  no-lock no-error.
            if Make-Excel then  put   stream ForExcel unformatted CHR(9) CHR(9) CHR(9) CHR(9)
                        ("Итого по " + string(tt-line.grp-name) + " :")         CHR(9) CHR(9) CHR(9)
                        tt-sum.sum
            skip.
          end.
        end.
      end.
      when 2 then do:
        for each tt-line break by tt-line.grp-name by tt-line.prod-type by tt-line.prod-code by tt-line.artic :
          if first-of(tt-line.grp-name) then do:
            if Make-Excel then  put   stream ForExcel unformatted tt-line.grp-name skip.
          end.
          if first-of(tt-line.prod-code) then do:
            find first buf_clients no-lock where buf_clients.obj-type = tt-line.prod-type and buf_clients.obj-code = tt-line.prod-code .
            if Make-Excel then  put   stream ForExcel unformatted buf_clients.obj-name skip.
          end.
          run print-line in this-procedure (input recid(tt-line)) .
          if last-of(tt-line.prod-code) then do:
            find first tt-sum where tt-sum.obj-type  = "-1"              and
                                    tt-sum.obj-code  = -1                and
                                    tt-sum.prod-type = tt-line.prod-type and
                                    tt-sum.prod-code = tt-line.prod-code and
                                    tt-sum.grp-name  = tt-line.grp-name  no-lock no-error.
            if Make-Excel then  put   stream ForExcel unformatted CHR(9) CHR(9) CHR(9) CHR(9)
                        ("Итого по " + string(buf_clients.obj-name) + " :")         CHR(9) CHR(9) CHR(9)
                        tt-sum.sum
            skip.
          end.
          if last-of(tt-line.grp-name) then do:
            find first tt-sum where tt-sum.obj-type  = "-1"              and
                                    tt-sum.obj-code  = -1                and
                                    tt-sum.prod-type = "-1"              and
                                    tt-sum.prod-code = -1                and
                                    tt-sum.grp-name  = tt-line.grp-name  no-lock no-error.
            if Make-Excel then  put   stream ForExcel unformatted CHR(9) CHR(9) CHR(9) CHR(9)
                        ("Итого по " + string(tt-line.grp-name) + " :")         CHR(9) CHR(9) CHR(9)
                        tt-sum.sum
            skip.
          end.
        end.
      end.
      when 3 then do:
        for each tt-line break by tt-line.grp-name by tt-line.prod-type by tt-line.prod-code by tt-line.gds-name :
          if first-of(tt-line.grp-name) then do:
            if Make-Excel then  put   stream ForExcel unformatted tt-line.grp-name skip.
          end.
          if first-of(tt-line.prod-code) then do:
            find first buf_clients no-lock where buf_clients.obj-type = tt-line.prod-type and buf_clients.obj-code = tt-line.prod-code .
            if Make-Excel then  put   stream ForExcel unformatted buf_clients.obj-name skip.
          end.
          run print-line in this-procedure (input recid(tt-line)) .
          if last-of(tt-line.prod-code) then do:
            find first tt-sum where tt-sum.obj-type  = "-1"              and
                                    tt-sum.obj-code  = -1                and
                                    tt-sum.prod-type = tt-line.prod-type and
                                    tt-sum.prod-code = tt-line.prod-code and
                                    tt-sum.grp-name  = tt-line.grp-name  no-lock no-error.
            if Make-Excel then  put   stream ForExcel unformatted CHR(9) CHR(9) CHR(9) CHR(9)
                        ("Итого по " + string(buf_clients.obj-name) + " :")         CHR(9) CHR(9) CHR(9)
                        tt-sum.sum
            skip.
          end.
          if last-of(tt-line.grp-name) then do:
            find first tt-sum where tt-sum.obj-type  = "-1"              and
                                    tt-sum.obj-code  = -1                and
                                    tt-sum.prod-type = "-1"              and
                                    tt-sum.prod-code = -1                and
                                    tt-sum.grp-name  = tt-line.grp-name  no-lock no-error.
            if Make-Excel then  put   stream ForExcel unformatted CHR(9) CHR(9) CHR(9) CHR(9)
                        ("Итого по " + string(tt-line.grp-name) + " :")         CHR(9) CHR(9) CHR(9)
                        tt-sum.sum
            skip.
          end.
        end.
      end.
    end case.
  end.
  if p-det-obj then do :
    case SortType:
      when 1 then do:
        for each tt-line break by tt-line.obj-type by tt-line.obj-code by tt-line.grp-name by tt-line.prod-type by tt-line.prod-code by tt-line.gds-code :
          if first-of(tt-line.obj-code) then if Make-Excel then  put   stream ForExcel unformatted tt-line.obj-name skip.
          if first-of(tt-line.grp-name) then do:
            if Make-Excel then  put   stream ForExcel unformatted tt-line.grp-name skip.
          end.
          if first-of(tt-line.prod-code) then do:
            find first buf_clients no-lock where buf_clients.obj-type = tt-line.prod-type and buf_clients.obj-code = tt-line.prod-code .
            if Make-Excel then  put   stream ForExcel unformatted buf_clients.obj-name skip.
          end.
          run print-line in this-procedure (input recid(tt-line)) .
          if last-of(tt-line.prod-code) then do:
            find first tt-sum where tt-sum.obj-type  = tt-line.obj-type  and
                                    tt-sum.obj-code  = tt-line.obj-code  and
                                    tt-sum.prod-type = tt-line.prod-type and
                                    tt-sum.prod-code = tt-line.prod-code and
                                    tt-sum.grp-name  = tt-line.grp-name  no-lock no-error.
            if Make-Excel then  put   stream ForExcel unformatted CHR(9) CHR(9) CHR(9) CHR(9)
                        ("Итого по " + string(buf_clients.obj-name) + " :")         CHR(9) CHR(9) CHR(9)
                        tt-sum.sum
            skip.
          end.
          if last-of(tt-line.grp-name) then do:
            find first tt-sum where tt-sum.obj-type  = tt-line.obj-type  and
                                    tt-sum.obj-code  = tt-line.obj-code  and
                                    tt-sum.prod-type = "-1"              and
                                    tt-sum.prod-code = -1                and
                                    tt-sum.grp-name  = tt-line.grp-name  no-lock no-error.
            if Make-Excel then  put   stream ForExcel unformatted CHR(9) CHR(9) CHR(9) CHR(9)
                        ("Итого по " + string(tt-line.grp-name) + " :")         CHR(9) CHR(9) CHR(9)
                        tt-sum.sum
            skip.
          end.
          if last-of(tt-line.obj-code) then do:
            find first tt-sum where tt-sum.obj-type = tt-line.obj-type and
                                    tt-sum.obj-code = tt-line.obj-code and
                                    tt-sum.prod-type = "-1"            and
                                    tt-sum.prod-code = -1              and
                                    tt-sum.grp-name  = "-1"            no-lock no-error.
            if Make-Excel then  put   stream ForExcel unformatted CHR(9) CHR(9) CHR(9) CHR(9)
                        ("Итого по " + string(tt-line.obj-name) + " :")         CHR(9) CHR(9) CHR(9)
                        tt-sum.sum
            skip.
          end.
        end.
      end.
      when 2 then do:
        for each tt-line break by tt-line.obj-type by tt-line.obj-code by tt-line.grp-name by tt-line.prod-type by tt-line.prod-code by tt-line.artic :
          if first-of(tt-line.obj-code) then if Make-Excel then  put   stream ForExcel unformatted tt-line.obj-name skip.
          if first-of(tt-line.grp-name) then do:
            if Make-Excel then  put   stream ForExcel unformatted tt-line.grp-name skip.
          end.
          if first-of(tt-line.prod-code) then do:
            find first buf_clients no-lock where buf_clients.obj-type = tt-line.prod-type and buf_clients.obj-code = tt-line.prod-code .
            if Make-Excel then  put   stream ForExcel unformatted buf_clients.obj-name skip.
          end.
          run print-line in this-procedure (input recid(tt-line)) .
          if last-of(tt-line.prod-code) then do:
            find first tt-sum where tt-sum.obj-type  = tt-line.obj-type  and
                                    tt-sum.obj-code  = tt-line.obj-code  and
                                    tt-sum.prod-type = tt-line.prod-type and
                                    tt-sum.prod-code = tt-line.prod-code and
                                    tt-sum.grp-name  = tt-line.grp-name  no-lock no-error.
            if Make-Excel then  put   stream ForExcel unformatted CHR(9) CHR(9) CHR(9) CHR(9)
                        ("Итого по " + string(buf_clients.obj-name) + " :")         CHR(9) CHR(9) CHR(9)
                        tt-sum.sum
            skip.
          end.
          if last-of(tt-line.grp-name) then do:
            find first tt-sum where tt-sum.obj-type  = tt-line.obj-type  and
                                    tt-sum.obj-code  = tt-line.obj-code  and
                                    tt-sum.prod-type = "-1"              and
                                    tt-sum.prod-code = -1                and
                                    tt-sum.grp-name  = tt-line.grp-name  no-lock no-error.
            if Make-Excel then  put   stream ForExcel unformatted CHR(9) CHR(9) CHR(9) CHR(9)
                        ("Итого по " + string(tt-line.grp-name) + " :")         CHR(9) CHR(9) CHR(9)
                        tt-sum.sum
            skip.
          end.
          if last-of(tt-line.obj-code) then do:
            find first tt-sum where tt-sum.obj-type = tt-line.obj-type and
                                    tt-sum.obj-code = tt-line.obj-code and
                                    tt-sum.prod-type = "-1"            and
                                    tt-sum.prod-code = -1              and
                                    tt-sum.grp-name  = "-1"            no-lock no-error.
            if Make-Excel then  put   stream ForExcel unformatted CHR(9) CHR(9) CHR(9) CHR(9)
                        ("Итого по " + string(tt-line.obj-name) + " :")         CHR(9) CHR(9) CHR(9)
                        tt-sum.sum
            skip.
          end.
        end.
      end.
      when 3 then do:
        for each tt-line break by tt-line.obj-type by tt-line.obj-code by tt-line.grp-name by tt-line.prod-type by tt-line.prod-code by tt-line.gds-name :
          if first-of(tt-line.obj-code) then if Make-Excel then  put   stream ForExcel unformatted tt-line.obj-name skip.
          if first-of(tt-line.grp-name) then do:
            if Make-Excel then  put   stream ForExcel unformatted tt-line.grp-name skip.
          end.
          if first-of(tt-line.prod-code) then do:
            find first buf_clients no-lock where buf_clients.obj-type = tt-line.prod-type and buf_clients.obj-code = tt-line.prod-code .
            if Make-Excel then  put   stream ForExcel unformatted buf_clients.obj-name skip.
          end.
          run print-line in this-procedure (input recid(tt-line)) .
          if last-of(tt-line.prod-code) then do:
            find first tt-sum where tt-sum.obj-type  = tt-line.obj-type  and
                                    tt-sum.obj-code  = tt-line.obj-code  and
                                    tt-sum.prod-type = tt-line.prod-type and
                                    tt-sum.prod-code = tt-line.prod-code and
                                    tt-sum.grp-name  = tt-line.grp-name  no-lock no-error.
            if Make-Excel then  put   stream ForExcel unformatted CHR(9) CHR(9) CHR(9) CHR(9)
                        ("Итого по " + string(buf_clients.obj-name) + " :")         CHR(9) CHR(9) CHR(9)
                        tt-sum.sum
            skip.
          end.
          if last-of(tt-line.grp-name) then do:
            find first tt-sum where tt-sum.obj-type  = tt-line.obj-type  and
                                    tt-sum.obj-code  = tt-line.obj-code  and
                                    tt-sum.prod-type = "-1"              and
                                    tt-sum.prod-code = -1                and
                                    tt-sum.grp-name  = tt-line.grp-name  no-lock no-error.
            if Make-Excel then  put   stream ForExcel unformatted CHR(9) CHR(9) CHR(9) CHR(9)
                        ("Итого по " + string(tt-line.grp-name) + " :")         CHR(9) CHR(9) CHR(9)
                        tt-sum.sum
            skip.
          end.
          if last-of(tt-line.obj-code) then do:
            find first tt-sum where tt-sum.obj-type = tt-line.obj-type and
                                    tt-sum.obj-code = tt-line.obj-code and
                                    tt-sum.prod-type = "-1"            and
                                    tt-sum.prod-code = -1              and
                                    tt-sum.grp-name  = "-1"            no-lock no-error.
            if Make-Excel then  put   stream ForExcel unformatted CHR(9) CHR(9) CHR(9) CHR(9)
                        ("Итого по " + string(tt-line.obj-name) + " :")         CHR(9) CHR(9) CHR(9)
                        tt-sum.sum
            skip.
          end.
        end.
      end.
    end case.
  end.
  end.
end procedure.
