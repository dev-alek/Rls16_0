using ibs.th.bge.egais.*.
block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: ":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: 2023/10/16 15:13:33 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-alc-rees.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-alc-rees.p $":U .
define variable vss-description as character no-undo init "Реестр документов ЕГАИС".
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
define new shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define new shared variable RepPathName        as character no-undo .
define new shared variable PrintRubl          as logical   no-undo .
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    undo, return error substitute( "&1. &2&3&4", vss-include-info9, return-value, chr(10), error-status :get-message (1)).
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
    undo, return error substitute( "&1. &2&3&4", vss-include-info9, return-value, chr(10), error-status :get-message (1)).
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
  define temp-table tt-wb-header no-undo
    field wb-type-full as character label "Тип" format "X(10)"
    field num          as character label "№ пост."
    field wb-date      as date label "Дата"
    field shippingdate as date label "Дата поставки"
    field regID-Ship   as character format "X(21)" label "RegId контр."
    field NameShip     as character format "X(150)" label "Контрагент EGAIS"
    field regID-Cons   as character format "X(21)" label "Получатель EGAIS"
    field client       as character label "Контр. TH"
    field clientCons   as character label "Получ. TH"
    field cli-type     as character label "Тип клиента TH"
    field cli-code     as integer label "Код клиента TH"
    field obj-type     as character label "Тип клиента TH"
    field obj-code     as integer label "Код клиента TH"
    field ps           as character label "Примечание"
    field wbregid      as character format "X(21)" label "WBRegId"
    field Identity     as character label "ID EGAIS"
    field wb-type      as character label "Тип"
    field cargo-from   as character label  "Грузоотправитель"
    field uniq-key-rec as character
    field INNShip      as character label "ИНН контрагента"
    field KPPShip      as character label "КПП контрагента"
    field TransIdList  as character
    field UnitType     as character label "Тип единицы измерения"
    field verXSD       as character label "Версия XSD"
    index pi
    Identity
    .
  define temp-table tt-wb-gds-EG no-undo
    field gds-code       like ub.goods.gds-code label "Код товара в TH"
    field gds-name       like ub.goods.gds-name label "Полное наименование" format "X(150)"
    field alc-code       as character label "Алкогольный код" format "X(21)"
    field ms-base        like ub.goods.ms-base label "Объем" format ">>9.9<<"
    field alc-type-code  like ub.alc-type.alc-type-code label "Код АП"
    field proof          like ub.goods.proof label "Крепость" format ">9.9"
    field regID-i-p      as character format "X(21)" label "Импортер/Производитель"
    field i-p-name       as character label "Импортер/Производитель назв." format "X(150)"
    field i-p-th         as character label "Импортер/Производитель TH"
    field qnty           like ub.doc-line.doc-qnty label "Кол-во"
    field price          like ub.doc-line.price-rubl label "Цена"
    field refA           as character label "Справка A" format "X(25)"
    field refB           as character label "Справка B" format "X(25)"
    field beforRefB      as character label "Пред. справка B" format "X(25)"
    field Identity       as character label "ID EGAIS"
    field regID-Importer as character format "X(21)" label "Импортер"
    field importer-th    as character label "Импортер TH"
    field regID-Producer as character format "X(21)" label "Производитель"
    field Producer-th    as character label "Производитель TH"
    field nn             as integer label "№"
    field prod-list      as character format "x(1)"
    field importer-list  as character format "x(1)"
    field color-sts      as integer   format "99" init ?
    field UnitType       as character format "x(1)"
    index pi nn ascending
    index qntyIndex
    gds-code
    alc-code
    qnty
    .
  define temp-table tt-wb-act-header no-undo
    field num          as character label "№ пост."
    field wbregid      as character label "WBRegId" format "X(21)"
    field act-date     as date label "Дата"
    field status_      as character label "Статус"
    field note         as character label "Примечание" format "X(150)"
    index pi
    wbregid
    .
  define temp-table tt-wb-act-gds-EG no-undo
    field gds-code      as integer label "Код товара в TH"
    field gds-name      as character label "Полное наименование" format "X(150)"
    field doc-qnty      as decimal label "Кол-во по док."
    field fact-qnty     as decimal label "Кол-во факт."
    field RealQuantity  as decimal label "Кол-во акт"
    field refB          as character label "Справка B" format "X(25)"
    index pi as primary
    gds-code
    index name_
    gds-name
    .
  define temp-table tt-wb-info-client no-undo
    field obj-type        like ub.clients.obj-type
    field obj-code        like ub.clients.obj-code
    field obj-name-th     as character
    field obj-name-egais  as character
    field wb-type-client  as character
    field regID           as character format "X(21)"
    field inn             as character
    field kpp             as character
    field country         as character
    field regionCode      as character
    field district        as character
    field city            as character
    field settlement      as character
    field street          as character
    field house-number    as character
    field house-case      as character
    field house-apartment as character
    field house-litera    as character
    field postIndex       as character
    field description_    as character format "X(100)"
    index pi
    inn kpp
    .
  define temp-table tt-ticket no-undo
    field regid        as character label "RegId документа" format "X(21)"
    field doc          as character label "Документ" format "X(30)"
    field docType      as character label "Документ" format "X(30)"
    field ticket-date  as character label "Дата" format "X(29)"
    field status_      as character label "Статус"
    field comment      as character label "Коментарий" format "X(150)"
    field docId        as character label "DocId" format "X(40)"
    field TransId      as character label "TransId" format "X(40)"
    field Identity     as character label "Identity" format "X(21)"
    index pi
    regid
    .
  define temp-table tt-analiz no-undo
    field num           as character label "№ накл." format "X(50)"
    field wb-type       as character label "Тип" format "X(4)"
    field wb-date       as date      label "Дата"
    field wbregid       as character label "WBREGID" format "X(18)"
    field Identity      as character format "X(50)"
    field uniq-key-rec  as character format "X(50)"
    field url_          as character format "X(50)"
    field isMany        as logical   format "yes/no"
    field nnOrder       as integer
    field resource-type as character format "X(12)"
    index pi
    url_
    .
  define temp-table tt-alldoc no-undo
    field mark          as character format "X(1)" label "*"
    field url_          as character format "X(256)" label "URL"
    field typeDoc       as character format "X(14)" label "Тип"
    field typeDirection as character format "X(3)" label ""
    field date_         as date      label "Дата"
    field nnOrder       as integer   label "Порядковый №"
    field transId_      as date      label ""
    index pi
    nnOrder
    .
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define input parameter p-column-list as character no-undo.
define variable parParentProc         as widget-handle no-undo.
DEFINE VARIABLE v-file-name           AS CHARACTER     NO-UNDO .
DEFINE VARIABLE g#report-num          AS INTEGER       NO-UNDO.
define variable qh-wb-egais           as handle        no-undo.
define variable v-cntxt-host-name-obj as character     no-undo .
define variable v-report-name         as character     no-undo.
define variable v-period              as character     no-undo.
define variable v-short-obj-list      as character     no-undo.
define variable v-choice-gds          as character     no-undo.
define variable v-choice-obj          as character     no-undo.
define variable v-full-path-RepView   as character     no-undo.
define variable v-file-name-rep-htm   as character     no-undo.
define variable v-par-type            as character     no-undo.
define variable v-col1                as logical       no-undo init no.
define variable v-col2                as logical       no-undo init no.
define variable v-col3                as logical       no-undo init no.
define variable v-col4                as logical       no-undo init no.
define variable v-col5                as logical       no-undo init no.
define variable v-col6                as logical       no-undo init no.
define variable v-col7                as logical       no-undo init no .
define variable v-col8                as logical       no-undo init no .
define variable v-col9                as logical       no-undo init no .
define variable v-col10               as logical       no-undo init no .
define variable v-col11               as logical       no-undo init no .
define variable v-col12               as logical       no-undo init no.
DEFINE VARIABLE v-search              AS CHARACTER.
define variable v-value-character     as character     no-undo .
define variable v-value-decimal       as decimal       no-undo .
define variable v-value-integer       as integer       no-undo .
define variable v-value-logical       as logical       no-undo .
define variable v-value-type          as character     no-undo .
define variable v-value-date          as date          no-undo .
define variable v-ext-sys             as integer       no-undo .
define variable v-price               as decimal       no-undo.
define variable v-fs-rar              as character     no-undo .
define stream  macr_excel .
define stream  out-stream .
define stream OutStr-html.
define variable egaisWB as class WayBill no-undo.
function fnc-DD-MM-YYYY returns character
    (input p-dat-date as date) forward.
function fnc-convert-dot-to-colon returns character
    (input p-data as decimal, input p-accur as character) forward.
define variable bh-wb-gds-EG-header as handle no-undo.
define variable bh-wb-gds-EG        as handle no-undo.
define buffer buf_trn-doc   for trn-doc.
define buffer buf_clob-bind for clob-bind.
define buffer buf_clients   for clients.
define temp-table alc-rees no-undo
    field num          as character
    field wb-date      as date
    field obj          as character
    field shippregid   as character
    field cli          as character
    field cliname      as character
    field wb-type      as character
    field trn-doc-code as character
    field status_      as character
    field is-sent      as character
    field wbregid      as character
    field Identity     as character
    field uniq-key-rec as character
    field obj-type     as char
    field obj-code     as integer
    field inn          as char
    field price        as decimal
    field kpp          as char
    field trn-date     as date
    field trn-tot      as decimal
    field flag_        as char
    field rash_        as char
    index pi
    Identity
    .
run adm/shattri.p (
    input "get":U
    ,input '':U
    ,input 0
    ,input 'egais':U
    ,input 'egais-exsys':U
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output v-value-logical
    ,output v-value-type
    ,input-output TABLE thbjattr_thbj-attr
    ) no-error .
assign
    v-ext-sys = v-value-integer .
egaisWB = new WayBill ( "" , 0 , v-fs-rar , v-ext-sys ).
create query qh-wb-egais.
RUN get-full-path-RepViewer(OUTPUT v-full-path-RepView).
RUN get-report-num IN my-handle (OUTPUT g#report-num).
for each obj-list no-lock
    :
    RUN define-full-path-Report(INPUT g#report-num, INPUT obj-list.obj-code , OUTPUT v-file-name-rep-htm).
    RUN create-file(v-file-name-rep-htm).
    for each buf_clob-bind where buf_clob-bind.field-name_ = 'egais-wb':U and  date(entry (1, buf_clob-bind.descr, chr(4))) >= X-Date-Start and  date (entry (1, buf_clob-bind.descr, chr(4))) <= X-Date-End :
        if entry (9, buf_clob-bind.descr, chr(4)) <> "" and entry (9, buf_clob-bind.descr, chr(4)) <> "0" and entry (9, buf_clob-bind.descr, chr(4)) <> obj-list.obj-type + string (obj-list.obj-code)
            then next.
        egaisWB:GetHndlTable(1, buf_clob-bind.uniq-key-rec).
        bh-wb-gds-EG-header = egaisWB:HndlHeader.
        bh-wb-gds-EG = egaisWB:HndlLine.
        v-price = 0 .
        bh-wb-gds-EG-header:find-first() no-error.
        bh-wb-gds-EG = egaisWB:GetHndlTable(2, buf_clob-bind.uniq-key-rec).
        qh-wb-egais:set-buffers (bh-wb-gds-EG).
        qh-wb-egais:query-prepare ("for each tt-wb-gds-EG ").
        qh-wb-egais:query-open.
        qh-wb-egais:GET-FIRST ().
        do while  bh-wb-gds-EG:available:
            v-price =  v-price + (bh-wb-gds-EG:buffer-field('price'):buffer-value())  *  (bh-wb-gds-EG:buffer-field('qnty'):buffer-value()  ).
            qh-wb-egais:get-next().
            if not bh-wb-gds-EG:available then leave.
        end.
        create alc-rees.
        assign
            alc-rees.wbregid      = bh-wb-gds-EG-header:buffer-field('wbregid'):buffer-value()
            alc-rees.price        = v-price
            alc-rees.INN          = bh-wb-gds-EG-header:buffer-field('INNShip'):buffer-value()
            alc-rees.KPP          = bh-wb-gds-EG-header:buffer-field('KPPShip '):buffer-value()
            alc-rees.wb-date      = date (entry (1, buf_clob-bind.descr, chr(4)))
            alc-rees.num          = entry (2, buf_clob-bind.descr, chr(4))
            alc-rees.shippregid   = entry (3, buf_clob-bind.descr, chr(4))
            alc-rees.Identity     = entry (4, buf_clob-bind.descr, chr(4))
            alc-rees.trn-doc-code = entry (6, buf_clob-bind.descr, chr(4))
            alc-rees.is-sent      = entry (7, buf_clob-bind.descr, chr(4))
            alc-rees.wb-type      = "приход вн."
            when entry (8, buf_clob-bind.descr, chr(4)) = 'ie':U
            alc-rees.obj          = entry (9, buf_clob-bind.descr, chr(4)) .
        alc-rees.rash_ = entry (10, buf_clob-bind.descr, chr(4)) no-error.
        assign
            alc-rees.uniq-key-rec = buf_clob-bind.uniq-key-rec
            alc-rees.obj-type     = obj-list.obj-type
            alc-rees.obj-code     = obj-list.obj-code
            .
        find first trn-doc where trn-doc.doc-code = alc-rees.trn-doc no-lock no-error.
        if available trn-doc then
        do:
            assign
                alc-rees.trn-date = trn-doc.doc-date
                alc-rees.trn-tot  = trn-doc.tot-rubl
                alc-rees.flag_    = if trn-doc.flag_ then "да" else "нет".
        end.
        if alc-rees.rash_ <> "" then  alc-rees.status_ = alc-rees.rash_.
        find first ub.ext-classif no-lock
            where ub.ext-classif.classif-subject = 'clients':U
            and ub.ext-classif.classif-name = 'clients-esys':U
            and ub.ext-classif.db-num = 0
            and ub.ext-classif.key#_one = v-ext-sys
            and ub.ext-classif.CharKey_Three = alc-rees.shippregid
            no-error.
        if available (ub.ext-classif) then
        do:
            find first buf_clients where buf_clients.obj-type = entry (2, ub.ext-classif.uniq-key-rec, chr(3)) and buf_clients.obj-code = integer (entry (3, ub.ext-classif.uniq-key-rec, chr(3))) no-error.
            if available (buf_clients)
                then
            do:
                alc-rees.cli = buf_clients.obj-type + string (buf_clients.obj-code).
                alc-rees.cliname = buf_clients.obj-name.
            end.
        end.
        find first buf_trn-doc where buf_trn-doc.doc-code = alc-rees.trn-doc-code no-error.
        if available (buf_trn-doc)
            then alc-rees.status_ = buf_trn-doc.status_ + (if buf_trn-doc.flag_ then "+" else "-").
    end.
    run proc-create-HTML (input obj-list.obj-code, input obj-list.obj-type, input obj-list.obj-name).
    v-search = v-search + " "  + v-file-name-rep-htm.
    v-search = trim(v-search," ") .
end.
run prn-lib-reportviewer in this-procedure (
    input parParentProc
    ,input v-search
    ,input ""
    ) .
if error-status:error then
do:
    message return-value view-as alert-box.
    return .
end.
procedure proc-create-HTML:
    define input parameter p-obj-code as integer no-undo.
    define input parameter p-obj-type as character no-undo.
    define input parameter p-obj-name as character no-undo.
    DO:
        OUTPUT stream OutStr-html to value(v-file-name-rep-htm) append convert target 'UTF-8'.
        PUT STREAM OutStr-html UNFORMATTED
            "<!DOCTYPE HTML>" SKIP
            ' <html>' SKIP
            '  <head>' SKIP
            '   <meta charset="utf-8">' SKIP
            '    <style type="text/css">' SKIP
            '      table ' + chr(123) + ' border-collapse: collapse; font-size:9pt; font-family:Calibri; table-layout: fixed; width: 540px; hight:  padding: 8px;  ' + chr(125) SKIP
            '      td ' + chr(123) ' border: 1px black solid; word-wrap:break-word; ' + chr(125) SKIP
            '      htm' SKIP
            '      .rotate ' + chr(123) SKIP
            '        -webkit-transform: rotate(-90deg);' SKIP
            '        -moz-transform: rotate(-90deg);' SKIP
            '        -ms-transform: rotate(-90deg);' SKIP
            '        -o-transform: rotate(-90deg);' SKIP
            '        transform: rotate(-90deg);' SKIP
            '        -webkit-transform-origin: 50% 50%;' SKIP
            '        -moz-transform-origin: 50% 50%;' SKIP
            '        -ms-transform-origin: 50% 50%;' SKIP
            '        -o-transform-origin: 50% 50%;' SKIP
            '        transform-origin: 50% 50%;' SKIP
            '        filter: progid:DXImageTransform.Microsoft.BasicImage(rotation=3);' SKIP
            '          ' + chr(125) SKIP
            '            th' + ' ' + chr(123) SKIP
            '            border: 1px black solid;' SKIP
            '            word-wrap: break-word;' SKIP
            '          ' + chr(125) SKIP
            '   </style>' SKIP
            '  </head>' SKIP
            .
    END.
    do:
        PUT STREAM OutStr-html UNFORMATTED
            ' <body>' SKIP
            '   <table name="' + p-obj-name + '" fit_to_page="true" orientation="landscape" outline_below="false">' SKIP
            '     <thead>' SKIP
            '       <tr class="set_columns">' SKIP
            .
        if lookup("Поставщик ЕГАИС",p-column-list) <> 0  then
        do:
            v-col1 = yes.
            PUT STREAM OutStr-html UNFORMATTED
                '         <td style="width: 200px; border: none;"></td>' SKIP
                .
        end.
        if lookup("ID поставщика",p-column-list) <> 0  then
        do:
            v-col2 = yes.
            PUT STREAM OutStr-html UNFORMATTED
                '         <td style="width: 100px; border: none;"></td>' SKIP
                .
        end.
        if lookup("ИНН/КПП",p-column-list) <> 0  then
        do:
            v-col3 = yes.
            PUT STREAM OutStr-html UNFORMATTED
                '         <td style="width: 150px; border: none;"></td>' SKIP
                .
        end.
        if lookup("Дата документа из ЕГАИС",p-column-list) <> 0  then
        do:
            v-col4 = yes.
            PUT STREAM OutStr-html UNFORMATTED
                '         <td style="width: 100px; border: none;"></td>' SKIP
                .
        end.
        if lookup("№ документа поставщика",p-column-list) <> 0  then
        do:
            v-col5 = yes.
            PUT STREAM OutStr-html UNFORMATTED
                '         <td style="width: 100px; border: none;"></td>' SKIP
                .
        end.
        if lookup("№ накладной в ЕГИС",p-column-list) <> 0  then
        do:
            v-col6 = yes.
            PUT STREAM OutStr-html UNFORMATTED
                '         <td style="width: 115px; border: none;"></td>' SKIP
                .
        end.
        if lookup("дата TH",p-column-list) <> 0  then
        do:
            v-col7 = yes.
            PUT STREAM OutStr-html UNFORMATTED
                '         <td style="width: 100px; border: none;"></td>' SKIP
                .
        end.
        if lookup("№ документа TH",p-column-list) <> 0  then
        do:
            v-col8 = yes.
            PUT STREAM OutStr-html UNFORMATTED
                '         <td style="width: 70px; border: none;"></td>' SKIP
                .
        end.
        if lookup("Сумма документа TH",p-column-list) <> 0  then
        do:
            v-col9 = yes.
            PUT STREAM OutStr-html UNFORMATTED
                '         <td style="width: 80px; border: none;"></td>' SKIP
                .
        end.
        if lookup("Сумма документа ЕГАИС",p-column-list) <> 0  then
        do:
            v-col10 = yes.
            PUT STREAM OutStr-html UNFORMATTED
                '         <td style="width: 100px; border: none;"></td>' SKIP
                .
        end.
        if lookup("Cтатус",p-column-list) <> 0  then
        do:
            v-col11 = yes.
            PUT STREAM OutStr-html UNFORMATTED
                '         <td style="width: 70px; border: none;"></td>' SKIP
                .
        end.
        if lookup("Расхождение(да/нет)",p-column-list) <> 0  then
        do:
            v-col12 = yes.
            PUT STREAM OutStr-html UNFORMATTED
                '         <td style="width: 80px; border: none;"></td>' SKIP
                .
        end.
        PUT STREAM OutStr-html UNFORMATTED
            '       </tr>' SKIP
            .
    end.
    DO:
        PUT STREAM OutStr-html UNFORMATTED
            '<tr>' SKIP
            '         <td colspan="8" style="border: none;   text-align: center;  font-size: 12pt;  font-weight: bold;">Накладные,принятые с ЕГАИС. Объект:  ' + p-obj-name  + '  за период:  ' + string(x-date-start)  + ' - ' + string(X-Date-End) + '</td>' SKIP
            '</tr>' skip
            '  <tr>' SKIP
            '    <td colspan="8" style="border: none;   text-align: center;  font-size: 12pt;  font-weight: bold;"></td>' SKIP
            '</tr>' skip
            '</thead>' SKIP
            .
    end.
    DO:
        PUT STREAM OutStr-html UNFORMATTED
            '     <tbody>' skip
            '       <tr style="height: 80px;">' SKIP
            .
        if v-col1 then     PUT STREAM OutStr-html UNFORMATTED        '         <th  num="" style="background-color:#ffffcc; font-size:9pt; text-align: center;">Поставщик ЕГАИС </th>' SKIP.
        if v-col2 then     PUT STREAM OutStr-html UNFORMATTED '         <th  num="" style="background-color:#ffffcc; font-size:9pt; text-align: center;">ID Поставщика </th>' SKIP.
        if v-col3 then     PUT STREAM OutStr-html UNFORMATTED        '         <th  num="" style="background-color:#ffffcc; font-size:9pt; text-align: center;">ИНН/КПП </th>' SKIP .
        if v-col4 then     PUT STREAM OutStr-html UNFORMATTED     '         <th  num="" style="background-color:#ffffcc; font-size:9pt; text-align: center;">Дата документа </th>' SKIP.
        if v-col5 then     PUT STREAM OutStr-html UNFORMATTED    '         <th  num="" style="background-color:#ffffcc; font-size:9pt; text-align: center;">№ док.поставщика</th>' SKIP.
        if v-col6 then     PUT STREAM OutStr-html UNFORMATTED      '         <th  num="" style="background-color:#ffffcc; font-size:9pt; text-align: center;">№ накладной в ЕГАИС</th>' SKIP .
        if v-col7 then     PUT STREAM OutStr-html UNFORMATTED  '         <th  num="" style="background-color:#ffffcc; font-size:9pt; text-align: center;">дата TH </th>' SKIP.
        if v-col8 then     PUT STREAM OutStr-html UNFORMATTED '         <th  num="" style="background-color:#ffffcc; font-size:9pt; text-align: center;">№ док. TH </th>' SKIP.
        if v-col9 then     PUT STREAM OutStr-html UNFORMATTED   '         <th  num="" style="background-color:#ffffcc; font-size:9pt; text-align: center;">сумма док. TH </th>' SKIP.
        if v-col10 then    PUT STREAM OutStr-html UNFORMATTED   '         <th  num="" style="background-color:#ffffcc; font-size:9pt; text-align: center;">сумма док. ЕГАИС </th>' SKIP.
        if v-col11 then    PUT STREAM OutStr-html UNFORMATTED  '         <th  num="" style="background-color:#ffffcc; font-size:9pt; text-align: center;">Статус </th>' SKIP.
        if v-col12 then    PUT STREAM OutStr-html UNFORMATTED   '         <th  num="" style="background-color:#ffffcc; font-size:9pt; text-align: center;">Расхождение (да/нет) </th>' SKIP.
        PUT STREAM OutStr-html UNFORMATTED
            '</tr>'
            .
        output stream OutStr-html close.
    end.
    DO:
        OUTPUT stream OutStr-html to value(v-file-name-rep-htm) append convert target 'UTF-8'.
        for each alc-rees where alc-rees.obj-type = p-obj-type and alc-rees.obj-code = p-obj-code  break by alc-rees.wb-date :
            PUT STREAM OutStr-html UNFORMATTED
                '       <tr>' SKIP
                .
            if alc-rees.rash = "rejected" then
            do:
                if v-col1 then      PUT STREAM OutStr-html UNFORMATTED   '         <td text_wrap="true" style="background-color:#B22222;display: yes; text-align: left;border: 1px solid black;">'   +  alc-rees.cliname + '</td>'  SKIP.
                if v-col2 then      PUT STREAM OutStr-html UNFORMATTED   '         <td text_wrap="true" style="background-color:#B22222;display: yes; text-align: left;border: 1px solid black;">'  +   alc-rees.shippregid + '</td>'  SKIP.
                if v-col3 then      PUT STREAM OutStr-html UNFORMATTED   '         <td style="background-color:#B22222; display: yes; text-align: center;border: 1px solid black;">' + alc-rees.inn + "/" +  alc-rees.kpp + '</td>' SKIP.
                if v-col4 then      PUT STREAM OutStr-html UNFORMATTED   '         <td style="background-color:#B22222;display: yes; text-align: center;border: 1px solid black;">'    + fnc-DD-MM-YYYY(date(string(alc-rees.wb-date,"99.99.9999"))) + '</td>' skip.
                if v-col5 then      PUT STREAM OutStr-html UNFORMATTED   '         <td style="background-color:#B22222;display: yes; text-align: center;border: 1px solid black;">' + alc-rees.num +  '</td>' SKIP.
                if v-col6 then      PUT STREAM OutStr-html UNFORMATTED   '         <td style="background-color:#B22222;display: yes; text-align: center;border: 1px solid black;">' + alc-rees.wbregid +  '</td>' SKIP.
                if v-col7 then      PUT STREAM OutStr-html UNFORMATTED   '         <td style="background-color:#B22222;display: yes; text-align: center;border: 1px solid black;">' + if  fnc-DD-MM-YYYY(date(string(alc-rees.trn-date,"99.99.9999")))  <> ? then  fnc-DD-MM-YYYY(date(string(alc-rees.trn-date,"99.99.9999")))  + '</td>' else " " + '</td>' skip.
                if v-col8 then      PUT STREAM OutStr-html UNFORMATTED   '         <td style="background-color:#B22222;display: yes; text-align: left;border: 1px solid black;">'  +    alc-rees.trn-doc-code     + '</td>'  SKIP.
                if v-col9 then      PUT STREAM OutStr-html UNFORMATTED   '         <td text_wrap="true" style="background-color:#B22222;display: yes; text-align: left;border: 1px solid black;">'  + if alc-rees.trn-tot <> ?  then fnc-convert-dot-to-colon( alc-rees.trn-tot, "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip.
                if v-col10 then     PUT STREAM OutStr-html UNFORMATTED   '         <td text_wrap="true" style="background-color:#B22222;display: yes; text-align: left;border: 1px solid black;"> '  + if alc-rees.price <> ?  then fnc-convert-dot-to-colon( alc-rees.price, "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip.
                if v-col11 then     PUT STREAM OutStr-html UNFORMATTED   '         <td style="background-color:#B22222;display: yes; text-align: left;border: 1px solid black;">'  +    alc-rees.status_   + '</td>'  SKIP.
                if v-col12 then     PUT STREAM OutStr-html UNFORMATTED   '         <td style="background-color:#B22222;display: yes; text-align: left;border: 1px solid black;"> ' + alc-rees.flag_ + ' </td>'  SKIP.
            end.
            else
            do:
                if alc-rees.trn-doc = "отказ" then
                do:
                    if v-col1 then      PUT STREAM OutStr-html UNFORMATTED   '         <td text_wrap="true" style="background-color:#4169E1;display: yes; text-align: left;border: 1px solid black;">'   +  alc-rees.cliname + '</td>'  SKIP.
                    if v-col2 then      PUT STREAM OutStr-html UNFORMATTED   '         <td text_wrap="true" style="background-color:#4169E1;display: yes; text-align: left;border: 1px solid black;">'  +   alc-rees.shippregid + '</td>'  SKIP.
                    if v-col3 then      PUT STREAM OutStr-html UNFORMATTED   '         <td style="background-color:#4169E1; display: yes; text-align: center;border: 1px solid black;">' + alc-rees.inn + "/" +  alc-rees.kpp + '</td>' SKIP.
                    if v-col4 then      PUT STREAM OutStr-html UNFORMATTED   '         <td style="background-color:#4169E1;display: yes; text-align: center;border: 1px solid black;">'           + fnc-DD-MM-YYYY(date(string(alc-rees.wb-date,"99.99.9999"))) + '</td>' skip.
                    if v-col5 then      PUT STREAM OutStr-html UNFORMATTED   '         <td style="background-color:#4169E1;display: yes; text-align: center;border: 1px solid black;">' + alc-rees.num +  '</td>' SKIP.
                    if v-col6 then      PUT STREAM OutStr-html UNFORMATTED   '         <td style="background-color:#4169E1;display: yes; text-align: center;border: 1px solid black;">' + alc-rees.wbregid +  '</td>' SKIP.
                    if v-col7 then      PUT STREAM OutStr-html UNFORMATTED   '         <td style="background-color:#4169E1;display: yes; text-align: center;border: 1px solid black;">'  + if  fnc-DD-MM-YYYY(date(string(alc-rees.trn-date,"99.99.9999")))  <> ? then  fnc-DD-MM-YYYY(date(string(alc-rees.trn-date,"99.99.9999"))) + '</td>' else " " + '</td>' skip.
                    if v-col8 then      PUT STREAM OutStr-html UNFORMATTED   '         <td style="background-color:#4169E1;display: yes; text-align: left;border: 1px solid black;">'  +    alc-rees.trn-doc-code     + '</td>'  SKIP.
                    if v-col9 then      PUT STREAM OutStr-html UNFORMATTED   '         <td text_wrap="true" style="background-color:#4169E1;display: yes; text-align: left;border: 1px solid black;">' + if alc-rees.trn-tot <> ?  then fnc-convert-dot-to-colon( alc-rees.trn-tot, "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip.
                    if v-col10 then     PUT STREAM OutStr-html UNFORMATTED   '         <td text_wrap="true" style="background-color:#4169E1;display: yes; text-align: left;border: 1px solid black;"> '  + if alc-rees.price <> ?  then fnc-convert-dot-to-colon( alc-rees.price, "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip.
                    if v-col11 then     PUT STREAM OutStr-html UNFORMATTED   '         <td style="background-color:#4169E1;display: yes; text-align: left;border: 1px solid black;">'  +    alc-rees.status_   + '</td>'  SKIP.
                    if v-col12 then     PUT STREAM OutStr-html UNFORMATTED   '         <td style="background-color:#4169E1;display: yes; text-align: left;border: 1px solid black;"> ' + alc-rees.flag_ + ' </td>'  SKIP.
                end.
                else
                do:
                    if alc-rees.trn-doc = "нет" or alc-rees.rash = "Accepted" then
                    do:
                        if v-col1 then      PUT STREAM OutStr-html UNFORMATTED   '         <td text_wrap="true" style="background-color:#A9A9A9;display: yes; text-align: left;border: 1px solid black;">'   +  alc-rees.cliname + '</td>'  SKIP.
                        if v-col2 then      PUT STREAM OutStr-html UNFORMATTED   '         <td text_wrap="true" style="background-color:#A9A9A9;display: yes; text-align: left;border: 1px solid black;">'  +   alc-rees.shippregid + '</td>'  SKIP.
                        if v-col3 then      PUT STREAM OutStr-html UNFORMATTED   '         <td style="background-color:#A9A9A9; display: yes; text-align: center;border: 1px solid black;">' + alc-rees.inn + "/" +  alc-rees.kpp + '</td>' SKIP.
                        if v-col4 then      PUT STREAM OutStr-html UNFORMATTED   '         <td style="background-color:#A9A9A9;display: yes; text-align: center;border: 1px solid black;">'           + fnc-DD-MM-YYYY(date(string(alc-rees.wb-date,"99.99.9999"))) + '</td>' skip.
                        if v-col5 then      PUT STREAM OutStr-html UNFORMATTED   '         <td style="background-color:#A9A9A9;display: yes; text-align: center;border: 1px solid black;">' + alc-rees.num +  '</td>' SKIP.
                        if v-col6 then      PUT STREAM OutStr-html UNFORMATTED   '         <td style="background-color:#A9A9A9;display: yes; text-align: center;border: 1px solid black;">' + alc-rees.wbregid +  '</td>' SKIP.
                        if v-col7 then      PUT STREAM OutStr-html UNFORMATTED   '         <td style="background-color:#A9A9A9;display: yes; text-align: center;border: 1px solid black;">' + if  fnc-DD-MM-YYYY(date(string(alc-rees.trn-date,"99.99.9999")))  <> ? then  fnc-DD-MM-YYYY(date(string(alc-rees.trn-date,"99.99.9999")))  + '</td>' else " " + '</td>' skip.
                        if v-col8 then      PUT STREAM OutStr-html UNFORMATTED   '         <td style="background-color:#A9A9A9;display: yes; text-align: left;border: 1px solid black;">'  +    alc-rees.trn-doc-code     + '</td>'  SKIP.
                        if v-col9 then      PUT STREAM OutStr-html UNFORMATTED   '         <td text_wrap="true" style="background-color:#A9A9A9;display: yes; text-align: left;border: 1px solid black;">'  + if alc-rees.trn-tot <> ?  then fnc-convert-dot-to-colon( alc-rees.trn-tot, "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip.
                        if v-col10 then     PUT STREAM OutStr-html UNFORMATTED   '         <td text_wrap="true" style="background-color:#A9A9A9;display: yes; text-align: left;border: 1px solid black;"> '  + if alc-rees.price <> ?  then fnc-convert-dot-to-colon( alc-rees.price, "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip.
                        if v-col11 then     PUT STREAM OutStr-html UNFORMATTED   '         <td style="background-color:#A9A9A9;display: yes; text-align: left;border: 1px solid black;">'  +    alc-rees.status_   + '</td>'  SKIP.
                        if v-col12 then     PUT STREAM OutStr-html UNFORMATTED   '         <td style="background-color:#A9A9A9;display: yes; text-align: left;border: 1px solid black;"> ' + alc-rees.flag_ + ' </td>'  SKIP.
                    end.
                    else
                    do:
                        if v-col1 then      PUT STREAM OutStr-html UNFORMATTED   '         <td text_wrap="true" style="display: yes; text-align: left;border: 1px solid black;">'   +  alc-rees.cliname + '</td>'  SKIP.
                        if v-col2 then      PUT STREAM OutStr-html UNFORMATTED   '         <td text_wrap="true" style="display: yes; text-align: left;border: 1px solid black;">'  +   alc-rees.shippregid + '</td>'  SKIP.
                        if v-col3 then      PUT STREAM OutStr-html UNFORMATTED   '         <td style="display: yes; text-align: center;border: 1px solid black;">' + alc-rees.inn + "/" +  alc-rees.kpp + '</td>' SKIP.
                        if v-col4 then      PUT STREAM OutStr-html UNFORMATTED   '         <td style="display: yes; text-align: center;border: 1px solid black;">'  + fnc-DD-MM-YYYY(date(string(alc-rees.wb-date,"99.99.9999"))) + '</td>' skip.
                        if v-col5 then      PUT STREAM OutStr-html UNFORMATTED   '         <td style="display: yes; text-align: center;border: 1px solid black;">' + alc-rees.num +  '</td>' SKIP.
                        if v-col6 then      PUT STREAM OutStr-html UNFORMATTED   '         <td style="display: yes; text-align: center;border: 1px solid black;">' + alc-rees.wbregid +  '</td>' SKIP.
                        if v-col7 then      PUT STREAM OutStr-html UNFORMATTED   '         <td style="display: yes; text-align: center;border: 1px solid black;">' + if  fnc-DD-MM-YYYY(date(string(alc-rees.trn-date,"99.99.9999")))  <> ? then  fnc-DD-MM-YYYY(date(string(alc-rees.trn-date,"99.99.9999"))) + '</td>' else " " + '</td>' skip.
                        if v-col8 then      PUT STREAM OutStr-html UNFORMATTED   '         <td style="display: yes; text-align: left;border: 1px solid black;">'  +    alc-rees.trn-doc-code     + '</td>'  SKIP.
                        if v-col9 then      PUT STREAM OutStr-html UNFORMATTED   '         <td text_wrap="true" style="display: yes; text-align: left;border: 1px solid black;">'    + if alc-rees.trn-tot <> ?  then fnc-convert-dot-to-colon( alc-rees.trn-tot, "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip.
                        if v-col10 then     PUT STREAM OutStr-html UNFORMATTED   '         <td text_wrap="true" style="display: yes; text-align: left;border: 1px solid black;"> '   + if alc-rees.price <> ?  then fnc-convert-dot-to-colon( alc-rees.price, "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip.
                        if v-col11 then     PUT STREAM OutStr-html UNFORMATTED   '         <td style="display: yes; text-align: left;border: 1px solid black;">'  +    alc-rees.status_   + '</td>'  SKIP.
                        if v-col12 then     PUT STREAM OutStr-html UNFORMATTED   '         <td style="display: yes; text-align: left;border: 1px solid black;"> ' + alc-rees.flag_ + ' </td>'  SKIP.
                    end.
                end.
            end.
            PUT STREAM OutStr-html UNFORMATTED
                '</tr>' SKIP
                .
        end.
    end.
    DO:
        PUT STREAM OutStr-html UNFORMATTED
            '    </tbody>'
            '   </table>' SKIP
            '  </body>' SKIP
            ' </html>' SKIP
            .
        OUTPUT stream OutStr-html close.
    END.
end procedure.
function fnc-convert-dot-to-colon returns character
(input p-data as decimal, input p-accur as character):
    define variable result as character no-undo.
    define variable v-str-result as character no-undo.
    p-data = round(p-data, 2).
    v-str-result = trim(replace(string(p-data, p-accur), ".", ",")).
    return v-str-result.
END FUNCTION.
FUNCTION fnc-DD-MM-YYYY RETURNS CHARACTER
    (INPUT p-dat-date AS DATE):
    DEFINE VARIABLE result     AS CHARACTER NO-UNDO.
    DEFINE VARIABLE p-str-date AS CHARACTER NO-UNDO.
    p-str-date = REPLACE(STRING(p-dat-date,'99.99.9999'), "/", ".").
    RETURN p-str-date.
END FUNCTION.
PROCEDURE get-full-path-RepViewer:
    DEFINE OUTPUT PARAMETER p-fill-path-RepView AS CHARACTER NO-UNDO.
    IF SEARCH("exe\ReportViewer\reportviewer.exe") <> ? THEN
    DO:
        p-fill-path-RepView = SEARCH("exe\ReportViewer\reportviewer.exe").
    END.
    ELSE
    DO:
        MESSAGE "Не найдена программа просмотра отчёта!" VIEW-AS ALERT-BOX ERROR.
    END.
END PROCEDURE.
PROCEDURE search-full-path-Report:
    DEFINE INPUT PARAMETER p-file-name AS CHARACTER NO-UNDO.
    IF SEARCH(p-file-name) = ? THEN
    DO:
        MESSAGE "Не найден файл отчёта: " p-file-name VIEW-AS ALERT-BOX ERROR.
    END.
    ELSE
    DO:
        p-file-name = SEARCH(p-file-name).
    END.
END PROCEDURE.
PROCEDURE create-file:
    DEFINE INPUT PARAMETER p-file-name AS CHARACTER NO-UNDO.
    OUTPUT to value(STRING(p-file-name)).
    OUTPUT close.
END PROCEDURE.
PROCEDURE define-full-path-Report:
    DEFINE INPUT PARAMETER p-rep-num AS INTEGER NO-UNDO.
    DEFINE INPUT PARAMETER name-obj AS INTEGER.
    DEFINE OUTPUT PARAMETER p-file-name-rep-htm AS CHARACTER NO-UNDO.
    p-file-name-rep-htm = SESSION:TEMP-DIRECTORY +   "Объект" + string(name-obj) + ".html".
END PROCEDURE.
PROCEDURE Report-Viewer:
    DEFINE INPUT PARAMETER p-full-path-RepView AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER p-search AS CHARACTER NO-UNDO.
    OS-COMMAND NO-WAIT VALUE(p-full-path-RepView +  " true " + p-search).
END PROCEDURE.
