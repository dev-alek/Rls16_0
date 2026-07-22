block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-gdscrd.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-gdscrd.p $":U .
define variable vss-description as character no-undo init "Карточка товара".
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
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    define  variable price-rubl-with-tax-sale    like ub.doc-line.price-rubl no-undo.
    define  variable price-base-with-tax-sale    like ub.doc-line.price-base no-undo.
    define  variable price-rubl-without-tax-sale like ub.doc-line.price-rubl no-undo.
    define  variable price-base-without-tax-sale like ub.doc-line.price-base no-undo.
    define  variable vat-base-sale               like ub.doc-line.price-base no-undo.
    define  variable vat-rubl-sale               like ub.doc-line.price-rubl no-undo.
    define  variable vat-base-buyer              like ub.doc-line.price-base no-undo.
    define  variable vat-rubl-buyer              like ub.doc-line.price-rubl no-undo.
    define  variable slt-base-sale               like ub.doc-line.price-base no-undo.
    define  variable slt-rubl-sale               like ub.doc-line.price-rubl no-undo.
    define  variable road-tax-base-sale          like ub.doc-line.road-tax   no-undo.
    define  variable road-tax-rubl-sale          like ub.doc-line.road-tax   no-undo.
    define  variable excise-base-sale            like ub.doc-line.price-base no-undo.
    define  variable excise-rubl-sale            like ub.doc-line.price-rubl no-undo.
    define  variable discnt-base-sale            like ub.gds-dtl.discnt-base no-undo.
    define  variable discnt-rubl-sale            like ub.gds-dtl.discnt-rubl no-undo.
    define buffer out-vatp_gds-dtl     for ub.gds-dtl.
    define buffer buf_out-vatp_gds-dtl for ub.gds-dtl.
    define buffer out-vatp_parts       for ub.parts.
    define buffer out-vatp_sysconf     for ub.sysconf.
    define buffer out-vatp_doc-line    for ub.doc-line.
    define buffer out-vatp_goods       for ub.goods.
    define buffer out-vatp_trn-doc     for ub.trn-doc.
    define buffer out-vatp_doc-attr    for ub.doc-attr.
    define variable varprice-base-cons      like ub.doc-line.price-base initial 0.00 no-undo.
    define variable varprice-rubl-cons      like ub.doc-line.price-rubl initial 0.00 no-undo.
    define variable varfrm-cnsv-type         as   character                           no-undo.
    define variable varfrm-cnsv              as   character                           no-undo.
    define variable varroot-node             as   integer                             no-undo.
    define variable varempty-scale           as   logical                             no-undo.
    define variable varis-cons-parts-have    as   logical                             no-undo.
    define variable varsum-base-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-factovp  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-base-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-docovp   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-factovp  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-docovp   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varfact-qnty             like ub.parts.fact-qnty                  no-undo.
    define variable varcons-qnty             like ub.parts.fact-qnty                  no-undo.
    define variable varis-one-gds-dtl        as   logical                             no-undo.
    define variable varcurprice-base         like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurprice-rubl         like ub.gds-dtl.price-base               no-undo.
    define variable varcurdiscnt-base        like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurdiscnt-rubl        like ub.gds-dtl.price-base               no-undo.
    define variable varoutvprb               as   character                           no-undo.
    define variable out-vatp-have-vat-slt    as   logical initial yes                 no-undo.
    define buffer   in-vatp-trn-doco  for ub.trn-doc .
    define buffer   in-vatp-partso    for ub.parts   .
    define buffer   in-vatp-doco      for ub.trn-doc .
    define buffer   in-vatp-goodso    for ub.goods   .
    define buffer   in-vatp-sysconfo  for ub.sysconf .
    define buffer   in-vatp_doc-attro for ub.doc-attr.
    define variable in-vatp-have-vat-slto       as   logical initial yes    no-undo.
    define variable vat-pc-loco                 like ub.doc-line.vat-pc     no-undo.
    define variable varinvprbo                  as   character              no-undo.
    define variable slt-pc-loco                 like ub.doc-line.slt-pc     no-undo.
    define variable cli-base-rateo              as   decimal                no-undo.
    define variable price-rubl-with-tax-loco    like ub.doc-line.price-rubl no-undo.
    define variable price-base-with-tax-loco    like ub.doc-line.price-base no-undo.
    define variable price-cli-with-tax-loco     like ub.doc-line.price-cli  no-undo.
    define variable price-rubl-without-tax-loco like ub.doc-line.price-rubl no-undo.
    define variable price-base-without-tax-loco like ub.doc-line.price-base no-undo.
    define variable price-cli-without-tax-loco  like ub.doc-line.price-base no-undo.
    define variable vat-base-loco               like ub.doc-line.price-base no-undo.
    define variable vat-rubl-loco               like ub.doc-line.price-rubl no-undo.
    define variable vat-cli-loco                like ub.doc-line.price-rubl no-undo.
    define variable slt-base-loco               like ub.doc-line.price-base no-undo.
    define variable slt-rubl-loco               like ub.doc-line.price-rubl no-undo.
    define variable slt-cli-loco                like ub.doc-line.price-rubl no-undo.
    define variable road-tax-base-loco          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-rubl-loco          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-cli-loco           like ub.doc-line.road-tax   no-undo.
    define variable transport-base-loco         like ub.doc-line.price-base no-undo.
    define variable transport-rubl-loco         like ub.doc-line.price-rubl no-undo.
    define variable transport-cli-loco          like ub.doc-line.price-rubl no-undo.
    define variable other-base-loco             like ub.doc-line.price-base no-undo.
    define variable other-rubl-loco             like ub.doc-line.price-rubl no-undo.
    define variable other-cli-loco              like ub.doc-line.price-rubl no-undo.
    define variable exch-rate-cli-loco          like ub.trn-doc.exch-rate   no-undo.
    define variable varinvatp-envdo             as   character              no-undo.
    define variable varinvatp-typeo             as   character              no-undo.
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
define input parameter x-type-dog as integer no-undo .
define input parameter xtog-inv   as logical no-undo .
define input parameter xtog-ov    as logical no-undo.
define variable make-one as logical no-undo .
make-one =  false    .
define variable inv-fact-order like ub.stk-tot.Fact-order init 0 no-undo.
define variable inv-fact-date as date no-undo .
define variable inv-str        as character init "" no-undo .
define variable v-ii as integer no-undo  .
define  shared var   v-x-artic      like   ub.goods.artic    no-undo  .
define  shared var   v-x-prod-type  like   ub.goods.prod-type no-undo .
define  shared var   v-x-prod-code  like   ub.goods.prod-code no-undo .
define buffer b-goods for ub.goods .
define variable cur-dn1 as character no-undo .
define variable  tPrintRubl as log no-undo.
define variable t-char as character no-undo .
define  stream  OutStream.
define  stream  OutStream2.
define variable    ObjName           as   char no-undo.
define variable    Select-Good       as   integer no-undo.
define variable    ChosedType        as   integer no-undo.
define variable    PayType           as   integer no-undo.
define variable    ValType           as   integer no-undo.
define variable    Line              as   char        no-undo.
define variable    FirstLine         as   logical     no-undo.
define variable f-o as decimal format "->>>>>>>>9.999999999"no-undo .
define variable f-o1 as decimal format "->>>>>>>>9.999999999"no-undo .
define variable v-p as logical no-undo .
define variable tow-unit  as log no-undo .
define variable stat     as log no-undo .
define variable InpError as log no-undo .
define variable i        as integer no-undo .
define variable ii        as integer no-undo .
define variable p        as integer no-undo init 0 .
define variable kk        as integer no-undo init 0 .
define variable old-page as integer no-undo .
define variable new-page as integer no-undo .
define variable rid-list as character no-undo .
define variable gds-zap-unit-base     like ub.goods.unit-base     no-undo.
define variable gds-zap-prt-root      like ub.goods.prt-root     no-undo .
define variable gds-zap-gds-name      like ub.goods.gds-name     no-undo .
define variable gds-zap-prod-type     like ub.goods.prod-type    no-undo .
define variable gds-zap-prod-code     like ub.goods.prod-code    no-undo .
define variable gds-zap-artic         like ub.goods.artic        no-undo .
define variable gds-zap-b-code        like ub.bar-code.b-code    no-undo .
define variable gds-type              as char no-undo.
define variable gds-zap-grp-name      like ub.goods.grp-name     no-undo .
define variable gds-zap-prod-name     like ub.clients.obj-name   no-undo .
define variable gds-zap-price-base    like ub.stk-tot.sum-rubl  no-undo.
define variable gds-zap-stoim-base    like ub.stk-tot.sum-rubl  no-undo.
define variable gds-zap-qnty          like ub.stk-tot.fact-qnty no-undo.
define variable gds-zap-Nds           like ub.stk-tot.sum-rubl  no-undo.
define variable gds-zap-Np            like ub.stk-tot.sum-rubl  no-undo.
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
define variable     F-fact-date  as char                            no-undo.
define variable     f-doc-code   as char                            no-undo.
define variable     f-type-doc   as char                            no-undo.
define variable     f-cli-name   as char                            no-undo.
define variable     F-qnty       as decimal FORMAT "->>>>>>>>9.<<<" no-undo.
define variable     F-qnty-o     as decimal FORMAT "->>>>>>>>>>>9.<<<" no-undo.
define variable     f-SumSALE    as decimal FORMAT "->>>>>>>>>9.99" no-undo.
define variable     f-SumSALE-o  as decimal FORMAT "->>>>>>>>>9.99" no-undo.
define variable     f-PriceSALE  as decimal FORMAT "->>>>>>>>>9.99" no-undo.
define variable     f-discnt-sum as decimal FORMAT "->>>>>>9.<<"  no-undo.
define variable     vvv as decimal  FORMAT "->>>>>>>>>>>9.99"  no-undo.
define variable     h-F-kol-1   AS WIDGET-HANDLE.
define variable     h-F-kol-2   AS WIDGET-HANDLE.
define variable     h-kol-1     AS WIDGET-HANDLE.
define variable     h-kol-2     AS WIDGET-HANDLE.
define variable     h-fact-date   AS WIDGET-HANDLE.
define variable     h-doc-code    AS WIDGET-HANDLE.
define variable     h-type-doc    AS WIDGET-HANDLE.
define variable     h-cli-name    AS WIDGET-HANDLE.
define variable     h-qnty        AS WIDGET-HANDLE.
define variable     h-qnty-o      AS WIDGET-HANDLE.
define variable     h-SumSALE     AS WIDGET-HANDLE.
define variable     h-SumSALE-o   AS WIDGET-HANDLE.
define variable     h-PriceSALE   AS WIDGET-HANDLE.
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
define variable     qnty-o     as decimal FORMAT "->>>>>>>>9.999" no-undo.
define variable     qnty-1     as decimal FORMAT "->>>>>>>>9.999" no-undo.
define variable     qnty-2     as decimal FORMAT "->>>>>>>>9.999" no-undo.
define variable     SumSALE    as decimal FORMAT "->>>>>>>>>>9.<<" no-undo.
define variable     SumSALE-o  as decimal FORMAT "->>>>>>>>>>9.<<" no-undo.
define variable     PriceSALE  as decimal FORMAT "->>>>>>>>>>9.<<" no-undo.
define variable     discnt-sum as decimal FORMAT "->>>>>>>>>9.<<"  no-undo.
define variable TOT-SumSALE     like SumSALE no-undo.
define variable TOT-qnty        like qnty    no-undo.
define variable TOT-discnt-sum  like discnt-sum no-undo.
define buffer sale-ot-line  for  ub.ot-line .
DEFINE VARIABLE sym1Handle AS WIDGET-HANDLE.
DEFINE VARIABLE sym1-ed AS CHARACTER INITIAL "::"
     VIEW-AS EDITOR
     SIZE 1 BY 2 NO-UNDO.
DEFINE VARIABLE OpenedDocs AS LOGICAL INITIAL yes.
DEFINE VARIABLE PriceDocs AS LOGICAL INITIAL yes.
DEFINE VARIABLE ClosedDocs AS LOGICAL INITIAL yes.
define variable start-date as date no-undo .
define variable end-date   as date no-undo .
define variable rest-qnty as dec no-undo.
define variable rest-base as dec no-undo.
define variable rest-qnty1 as dec no-undo.
define variable rest-base1 as dec no-undo.
define buffer b-price-doc for ub.price-doc.
define buffer p-price-doc for ub.price-doc.
define buffer p-price-list for ub.price-list.
define buffer b-price-list for ub.price-list.
define buffer old-price-list for ub.price-list.
define buffer prev-price-list for ub.price-list.
define buffer  curr-price-list for ub.price-list .
define buffer b-doc-line for ub.doc-line.
define variable  Prtroot        like ub.gds-prt.node-code no-undo.
define variable BadResults      as      log     no-undo.
define variable q1 as decimal no-undo .
define variable q2 as decimal no-undo .
define temp-table gds-rep   no-undo
      field ii as integer
      field nn as integer
      field doc-code as char format "x(13)" label "Номер"
      field doc-num as char format "x(13)" label "Номер"
      field doc-type as char format "x(1)" label 'т':U
      field fact-num as dec format "999999" label "fact-num"
      field fact-order as dec format "->>>>>>>>>9.9999999999"
      field obj as char format "x(9)" label 'объект':U
      field clients as char  format "x(30)" label "Контрагент"
      field fact-date like ub.trn-doc.fact-date
      field fact-qnty as dec format "->>,>>>,>>9.99" label "Кол-во"
      field rest-qnty as dec format "->>,>>>,>>9.99" label "Остаток"
      field sale-base as dec format "->>,>>>,>>9.99" label "Цена/разница  "
      field tot-base as dec format "->>,>>>,>>9.99" label "Сумма (Б.вал.)"
      field rest-base as dec format "->>,>>>,>>9.99" label "Остаток(Б.вал)"
      field discnt-pc as dec format "->>9.99%" label "% ск."
      field discnt-tot as dec format "->>,>>>,>>9.99" label "Сумма ск."
      field netto as dec format "->>,>>>,>>9.99" label "Сумма нетто"
      field sale as dec format "->>,>>>,>>9.99" label 'цена':U
      field vv as dec format "->>,>>>,>>9.99" label "расчет"
      field ext-doc-type as character
      INDEX i-fact-ord fact-order ASCENDING
           .
define variable nn as integer no-undo .
define buffer gds-rep-p for gds-rep.
define buffer buf-gds-rep-2 for gds-rep.
define buffer buf-gds-rep-3 for gds-rep.
define buffer gds-dtl-ch for ub.gds-dtl.
define temp-table gds-rep-befor no-undo   like gds-rep .
define buffer buf-gds-rep-befor for gds-rep-befor .
 define variable v-total-tot-ov as decimal no-undo .
 define variable old-main-price as decimal no-undo .
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
assign v-account = ( if integer( 1 ) = 0 then 100 else integer( 1 ) ).
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
    F-qnty-o column-label "6":C13    space(0)
    sym6 column-label ":" format "X(1)" space(0)
    f-PriceSALE column-label "7":C13  space(0)
    sym7 column-label ":" format "X(1)" space(0)
    f-discnt-sum column-label "8":C9 space(0)
    sym8 column-label ":" format "X(1)" space(0)
    f-SumSALE column-label "9":C13  space(0)
    sym9 column-label ":" format "X(1)" space(0)
    f-SumSALE-o column-label "10":C13  space(0)
    sym10 column-label ":" format "X(1)" space(0)
    HEADER
        Line format "X(198)" AT 1
   with width 232 down stream-io use-text NO-BOX .
     assign
        i=0
        Select-Good   = x-SelectGood
        PayType       = x-SET_PAY_TYPE
        FirstLine     = FALSE
        Line          = fill("-",138)
        startdate     = x-Date-Start
        enddate       = x-Date-End
        start-date    = x-Date-Start
        end-date      = x-Date-End
        OpenedDocs    = if (x-type-dog <> 1 ) then true else false
        PriceDocs     = xtog-ov
        ClosedDocs    = if (x-type-dog <> 2 ) then true else false
        ValType       = IF (PayType = 1) Then 0  else x-SET_val_TYPE
        tow-unit = false
        .
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
if paytype = 2 then PriceDocs = true .
curr-rep = (if tPrintRubl then "РУБ" else x-base-type ) .
t-char = 'Остаток ,' + (if tPrintRubl then 'РУБ' else x-base-type) .
     DELETE WIDGET-POOL "qq" no-error  .
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
create editor h-qnty-o in widget-pool "qq"
assign
    frame = frame top-frame:handle
    column = 70
    screen-value = string ('Остаток (количество)')
    width-chars = 13
    .
create editor h-PriceSALE in widget-pool "qq"
assign
    frame = frame top-frame:handle
    column = 84
    screen-value = string ('Цена/разница')
    width-chars = 13
    .
create editor h-discnt-sum in widget-pool "qq"
assign
    frame = frame top-frame:handle
    column = 98
    screen-value = string ('Сумма скидки')
    width-chars = 10
    .
create editor h-SumSALE in widget-pool "qq"
assign
    frame = frame top-frame:handle
    column = 109
    screen-value = string ('Сумма по документу')
    width-chars = 13
    .
        if PriceDocs = true then do:
create editor h-SumSALE-o in widget-pool "qq"
assign
    frame = frame top-frame:handle
    column = 123
    screen-value = string (t-char)
    width-chars = 13
    .
            End.
            else f-SumSALE-o:label in frame zapas = " ".
        Find first ub.gds-prt where ub.gds-prt.node-name = '_Пустая шкала':U no-lock no-error.
        If available  ub.gds-prt then   Prtroot = ub.gds-prt.prt-root.
                              Else   Prtroot = 0.
    run report-execute in this-procedure .
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-pl-gds no-undo   like ub.pl-gds .
define temp-table temp-prt-obj no-undo   field prt-code         like ub.prt-obj.prt-code     field price-sale       like ub.prt-obj.price-sale   field fact-qnty        like ub.prt-obj.fact-qnty    field price-list-qnty  like ub.prt-obj.fact-qnty    field is-term          as logical   field prt-obj-recid    as recid     field price-list-recid as recid     index xpk is primary unique prt-code   index xie1 is-term .
procedure prdoclib-process-goods :
  define input  parameter p-obj-type          as character no-undo .
  define input  parameter p-obj-code          as integer   no-undo .
  define input  parameter p-artic             as character no-undo .
  define input  parameter p-prod-type         as character no-undo .
  define input  parameter p-prod-code         as integer   no-undo .
  define input  parameter p-check-price-list  as logical   no-undo .
  define input  parameter p-check-price-parts as logical   no-undo .
  define input  parameter p-doc-num           as character no-undo .
  define input  parameter p-fact-date         as date      no-undo .
  define input  parameter p-corr-user-db-num  as integer   no-undo .
  define input  parameter p-corr-user-name    as character no-undo .
  define input  parameter p-corr-date         as date      no-undo .
  define input  parameter p-corr-time         as integer   no-undo .
  define input  parameter p-corr-time-str     as character no-undo .
  define output parameter p-gds-obj-fact-qnty as decimal   no-undo .
  define variable vss-description as character no-undo initial "prdoclib-process-goods-01: обработка продажных цен товара".
  define buffer buf_gds-obj      for ub.gds-obj .
  define buffer buf_prt-obj      for ub.prt-obj .
  define buffer buf_price-list   for ub.price-list .
  define buffer buf_bar-code     for ub.bar-code .
  define buffer buf_temp-prt-obj for temp-prt-obj .
  define variable v-gds-code             like ub.goods.gds-code    no-undo .
  define variable v-root-node            like ub.prt-obj.prt-code  no-undo .
  define variable v-root-b-code          like ub.bar-code.b-code   no-undo .
  define variable v-total-term-fact-qnty like ub.prt-obj.fact-qnty no-undo .
  define variable v-total-fact-sale      like ub.gds-obj.fact-sale no-undo .
  define variable v-doc-num     like ub.price-list.doc-num    no-undo .
  define variable v-price-sale  like ub.price-list.price-sale no-undo .
  define variable v-road-tax    like ub.price-list.road-tax   no-undo .
  define variable v-excise      like ub.price-list.excise     no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,output v-root-node
  )  .
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdscr in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,input  v-root-node
  ,buffer buf_gds-obj
  ,buffer buf_prt-obj
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info16 skip
        "Ошибка при начале товародвижения товара на объекте" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    find current buf_gds-obj  exclusive-lock .
    find current buf_prt-obj  exclusive-lock .
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,output v-gds-code
  )  .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  v-gds-code
  ,input  v-root-node
  ,output v-root-b-code
  )  .
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  v-root-b-code
  ,input  v-root-b-code
  ,input  0
  ,output v-doc-num
  ,output v-price-sale
  ,output v-road-tax
  ,output v-excise
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info16 skip
        "Ошибка при определении цены признака на объекте" skip
        "Объект"     p-obj-type p-obj-code  skip
        "Бар-код"    v-root-b-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    run prdoclib-init-temp-prt-obj in this-procedure
      (input p-obj-type
      ,input p-obj-code
      ,input p-artic
      ,input p-prod-type
      ,input p-prod-code
      ,input v-price-sale
      ) .
    find first buf_price-list no-lock
      where buf_price-list.doc-num    = v-doc-num
        and buf_price-list.price-type = ""
        and buf_price-list.b-code     = v-root-b-code
      .
    find first buf_temp-prt-obj
      where buf_temp-prt-obj.prt-code = v-root-node
      .
    assign
      buf_temp-prt-obj.price-sale       = v-price-sale
      buf_temp-prt-obj.price-list-qnty  = buf_price-list.doc-qnty
      buf_temp-prt-obj.price-list-recid = recid(buf_price-list)
    .
    define variable l-empty-scale as logical no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtat in g#library
  (input  v-root-node
  ,input  'empty-scale=request'
  ,output l-empty-scale
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info16 skip
        "Ошибка при определении атрибута шкалы" skip
        "Код признака" v-root-node skip
        "Запрашивался атрибут" "empty-scale=request" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    assign
      v-total-term-fact-qnty = 0
      v-total-fact-sale      = 0
    .
    if l-empty-scale = true
    then do:
      for each buf_price-list
        where buf_price-list.doc-num    = v-doc-num
          and buf_price-list.main-price = false
          and buf_price-list.artic      = p-artic
          and buf_price-list.prod-type  = p-prod-type
          and buf_price-list.prod-code  = p-prod-code
          and buf_price-list.price-type = ""
      on error undo, return error return-value
      :
        if buf_price-list.doc-qnty <> ? and p-check-price-parts
        then do:
          message
            vss-workfile vss-revision vss-description skip
            vss-include-info16 skip
            "Ошибка при закрытии переоценки" skip
            "Для неосновного бар-кода товара с пустой шкалой" skip
            "указано количество отличное от ?" skip
            "Переоценка" v-doc-num skip
            "Бар-код" buf_price-list.b-code skip
            "Артикул" p-artic p-prod-type p-prod-code skip
            "Количество" buf_price-list.doc-qnty skip
            view-as alert-box error .
          undo, return error .
        end.
      end.
    end.
    if l-empty-scale = false
    then do:
      define variable v-unit-base like ub.goods.unit-base no-undo .
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run unitbase in g#library
  (input  v-gds-code
  ,output v-unit-base
  ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info16 skip
          "Ошибка при определении базовой единицы измерения товара" skip
          "Код товара" v-gds-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
      for each buf_price-list
        where buf_price-list.doc-num    = v-doc-num
          and buf_price-list.main-price = false
          and buf_price-list.artic      = p-artic
          and buf_price-list.prod-type  = p-prod-type
          and buf_price-list.prod-code  = p-prod-code
          and buf_price-list.price-type = ""
      on error undo, return error
      :
        if buf_price-list.doc-qnty = ?
        then do:
          find first buf_bar-code no-lock
            where buf_bar-code.b-code = buf_price-list.b-code
            no-error .
          if  available buf_bar-code
          and buf_bar-code.unit-cli = v-unit-base
          then do:
            message
              vss-workfile vss-revision vss-description skip
              vss-include-info16 skip
              "Ошибка при закрытии переоценки" skip
              "Не задано количество для бар-кода с основной единицей измерения" skip
              "Переоценка" v-doc-num skip
              "Бар-код" buf_price-list.b-code skip
              "Артикул" p-artic p-prod-type p-prod-code skip
              "Количество" buf_price-list.doc-qnty skip
              "Основная единица измерения" v-unit-base skip
              "Единица измерения бар-кода" buf_bar-code.unit-cli skip
              view-as alert-box error .
            undo, return error .
          end.
          next .
        end.
        find first buf_bar-code no-lock
          where buf_bar-code.b-code = buf_price-list.b-code
          no-error .
        if not available buf_bar-code
        then do:
          message
            vss-workfile vss-revision vss-description skip
            vss-include-info16 skip
            "В переоценке задан несуществующий бар-код" skip
            "Переоценка" v-doc-num skip
            "Артикул" p-artic p-prod-type p-prod-code skip
            "Бар-код" buf_price-list.b-code skip
            view-as alert-box error .
          undo, return error .
        end.
        if buf_bar-code.in-code <> ""
        or buf_bar-code.part-code <> ""
        then do:
          message
            vss-workfile vss-revision vss-description skip
            vss-include-info16 skip
            "В переоценке задан бар-код партии" skip
            "Данная версия системы не рассчитана на работу со специальными ценами по партиям" skip
            "Переоценка" v-doc-num skip
            "Бар-код" buf_price-list.b-code skip
            "Артикул" p-artic p-prod-type p-prod-code skip
            "Код ПН" buf_bar-code.in-code buf_bar-code.part-code skip
            view-as alert-box error .
          undo, return error .
        end.
        if buf_bar-code.node-code <> v-root-node
        then do:
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtobjcr in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,input  buf_bar-code.node-code
  ,buffer buf_prt-obj
  ) no-error .
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              vss-include-info16 skip
              "Невозможно найти prt-obj" skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error .
          end.
          run prdoclib-create-temp-prt-obj in this-procedure
            (input  v-price-sale
            ,buffer buf_prt-obj
            ,buffer buf_temp-prt-obj
            ).
          assign
            buf_temp-prt-obj.price-sale       = buf_price-list.price-sale
            buf_temp-prt-obj.price-list-qnty  = buf_price-list.doc-qnty
            buf_temp-prt-obj.price-list-recid = recid(buf_price-list)
          .
        end.
      end.
      for each buf_temp-prt-obj
        where buf_temp-prt-obj.is-term = true
      :
        if buf_temp-prt-obj.price-list-recid <> ?
        then do:
          assign
            v-total-term-fact-qnty = v-total-term-fact-qnty
                                  + buf_temp-prt-obj.fact-qnty
            v-total-fact-sale = v-total-fact-sale
                              + buf_temp-prt-obj.fact-qnty * buf_temp-prt-obj.price-sale
          .
        end.
        if p-check-price-list = true
        then do:
          if buf_temp-prt-obj.price-list-recid = ?
          or buf_temp-prt-obj.fact-qnty = buf_temp-prt-obj.price-list-qnty
          then do:
          end.
          else do:
            message
              vss-workfile vss-revision vss-description skip
              vss-include-info16 skip
              "Ошибка при закрытии переоценки" skip
              "Несовпадают текущие количества по признаку" skip
              "и количество признака в переоценке" skip
              "Переоценка" v-doc-num skip
              "Артикул" p-artic p-prod-type p-prod-code skip
              "Код признака" buf_temp-prt-obj.prt-code skip
              "Количество по признаку" buf_temp-prt-obj.fact-qnty skip
              "Количество по переоценке" buf_temp-prt-obj.price-list-qnty skip
              "Корень шкалы товара" v-root-node skip
              view-as alert-box error .
            undo, return error .
          end.
        end.
      end.
    end.
    find first buf_temp-prt-obj
      where buf_temp-prt-obj.prt-code = v-root-node
      .
    assign
      buf_temp-prt-obj.fact-qnty = buf_temp-prt-obj.fact-qnty
                                  - v-total-term-fact-qnty
    .
    if p-check-price-list = true
    then do:
      if buf_temp-prt-obj.fact-qnty <> buf_temp-prt-obj.price-list-qnty and p-check-price-parts
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info16 skip
          "Ошибка при закрытии переоценки" skip
          "Несовпадают текущие количества по корневому признаку" skip
          "и количество признака в переоценке" skip
          "Переоценка" v-doc-num skip
          "Артикул" p-artic p-prod-type p-prod-code skip
          "Код признака" buf_temp-prt-obj.prt-code skip
          "Количество по признаку" buf_temp-prt-obj.fact-qnty skip
          "Количество по переоценке" buf_temp-prt-obj.price-list-qnty skip
          view-as alert-box error .
        undo, return error .
      end.
    end.
    assign
      v-total-fact-sale = v-total-fact-sale
                        + buf_temp-prt-obj.fact-qnty * buf_temp-prt-obj.price-sale
    .
    if v-total-fact-sale = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info16 skip
        "Ошибка при вычислении суммы в продажных ценах" skip
        "Получено неопределенное значение" skip
        "Переоценка" v-doc-num skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "Код признака" buf_temp-prt-obj.prt-code skip
        "Сумма в продажных ценах" v-total-fact-sale skip
        view-as alert-box error .
      undo, return error .
    end.
    define variable v-old-fact-qnty     as decimal   no-undo .
    define variable v-old-fact-cli-qnty as decimal   no-undo .
    define variable v-old-fact-base     as decimal   no-undo .
    define variable v-old-fact-rubl     as decimal   no-undo .
    define variable v-old-fact-sale     as decimal   no-undo .
    assign
      v-old-fact-qnty     = buf_gds-obj.fact-qnty
      v-old-fact-cli-qnty = buf_gds-obj.fact-cli-qnty
      v-old-fact-base     = buf_gds-obj.fact-base
      v-old-fact-rubl     = buf_gds-obj.fact-rubl
      v-old-fact-sale     = buf_gds-obj.fact-sale
    .
    assign
      buf_gds-obj.price-sale = v-price-sale
      buf_gds-obj.fact-sale  = v-total-fact-sale
    .
    define variable v-corr-date as date      no-undo .
    define variable v-corr-time as integer   no-undo .
    run cur-time in this-procedure
      (output v-corr-date
      ,output v-corr-time
      ) .
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gohist in g#library
  (input  buf_gds-obj.obj-type
  ,input  buf_gds-obj.obj-code
  ,input  buf_gds-obj.gds-code
  ,input  'close':U
  ,input  buf_gds-obj.fact-qnty
  ,input  buf_gds-obj.fact-cli-qnty
  ,input  buf_gds-obj.fact-base
  ,input  buf_gds-obj.fact-rubl
  ,input  buf_gds-obj.fact-sale
  ,input  v-old-fact-qnty
  ,input  v-old-fact-cli-qnty
  ,input  v-old-fact-base
  ,input  v-old-fact-rubl
  ,input  v-old-fact-sale
  ,input  'price-doc':U
  ,input  p-doc-num
  ,input  p-fact-date
  ,input  p-corr-user-db-num
  ,input  p-corr-user-name
  ,input  p-corr-date
  ,input  p-corr-time
  ,input  p-corr-time-str
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при создании истории по товару на объекте" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    assign
      p-gds-obj-fact-qnty = buf_gds-obj.fact-qnty
    .
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if  buf_gds-obj.first-doc <> ?
and buf_gds-obj.first-doc > p-fact-date then do:
  assign
    buf_gds-obj.first-doc  = p-fact-date
  .
end.
if  buf_gds-obj.last-doc <> ?
and buf_gds-obj.last-doc < p-fact-date then do:
  assign
    buf_gds-obj.last-doc   = p-fact-date
  .
end.
    for each buf_temp-prt-obj
    ,first buf_prt-obj exclusive-lock
      where recid(buf_prt-obj) = buf_temp-prt-obj.prt-obj-recid
    on error undo, return error return-value
    :
      assign
        buf_prt-obj.price-sale = buf_temp-prt-obj.price-sale
      .
    end.
  end.
end procedure.
procedure prdoclib-clear-temp-prt-obj :
  define buffer buf_temp-prt-obj for temp-prt-obj .
  do
  on error undo, return error return-value
  :
    for each buf_temp-prt-obj
    on error undo, return error return-value
    :
      delete buf_temp-prt-obj .
    end.
  end.
end procedure.
procedure prdoclib-create-temp-prt-obj :
  define input parameter  p-root-price-sale like ub.price-list.price-sale no-undo .
  define parameter buffer buf_prt-obj       for ub.prt-obj .
  define parameter buffer buf_temp-prt-obj  for temp-prt-obj .
  define buffer buf_gds-prt for ub.gds-prt .
  do
  on error undo, return error return-value
  :
    find first buf_temp-prt-obj
      where buf_temp-prt-obj.prt-code = buf_prt-obj.prt-code
      no-error .
    if not available buf_temp-prt-obj
    then do:
      create buf_temp-prt-obj .
      assign
        buf_temp-prt-obj.prt-code         = buf_prt-obj.prt-code
        buf_temp-prt-obj.price-sale       = ?
        buf_temp-prt-obj.fact-qnty        = buf_prt-obj.fact-qnty
        buf_temp-prt-obj.price-list-qnty  = ?
        buf_temp-prt-obj.prt-obj-recid    = recid(buf_prt-obj)
        buf_temp-prt-obj.price-list-recid = ?
      .
      find first buf_gds-prt no-lock
        where buf_gds-prt.node-code = buf_temp-prt-obj.prt-code
        .
      assign
        buf_temp-prt-obj.is-term = buf_gds-prt.is-term
      .
      if buf_temp-prt-obj.is-term
      then do:
        assign
          buf_temp-prt-obj.price-sale = p-root-price-sale
        .
      end.
    end.
  end.
end procedure.
procedure prdoclib-temp-prt-obj-by-prt-root :
  define input parameter  p-prt-code like ub.prt-obj.prt-code no-undo .
  define parameter buffer buf_temp-prt-obj  for temp-prt-obj .
  define buffer buf_gds-prt for ub.gds-prt .
  do
  on error undo, return error return-value
  :
    find first buf_temp-prt-obj
      where buf_temp-prt-obj.prt-code = p-prt-code
      no-error .
    if not available buf_temp-prt-obj
    then do:
      create buf_temp-prt-obj .
      assign
        buf_temp-prt-obj.prt-code         = p-prt-code
        buf_temp-prt-obj.price-sale       = ?
        buf_temp-prt-obj.fact-qnty        = 0
        buf_temp-prt-obj.price-list-qnty  = ?
        buf_temp-prt-obj.prt-obj-recid    = ?
        buf_temp-prt-obj.price-list-recid = ?
      .
      find first buf_gds-prt no-lock
        where buf_gds-prt.node-code = buf_temp-prt-obj.prt-code
        .
      assign
        buf_temp-prt-obj.is-term = buf_gds-prt.is-term
      .
      if buf_temp-prt-obj.is-term
      then do:
        assign
          buf_temp-prt-obj.price-sale = 0
        .
      end.
    end.
  end.
end procedure.
procedure prdoclib-init-temp-prt-obj :
  define input parameter p-obj-type        like ub.prt-obj.obj-type  no-undo .
  define input parameter p-obj-code        like ub.prt-obj.obj-code  no-undo .
  define input parameter p-artic           like ub.prt-obj.artic     no-undo .
  define input parameter p-prod-type       like ub.prt-obj.prod-type no-undo .
  define input parameter p-prod-code       like ub.prt-obj.prod-code no-undo .
  define input parameter p-root-price-sale like ub.prt-obj.price-sale no-undo .
  define buffer buf_prt-obj      for ub.prt-obj .
  define buffer buf_temp-prt-obj for temp-prt-obj .
  do
  on error undo, return error return-value
  :
    run prdoclib-clear-temp-prt-obj in this-procedure .
    for each buf_prt-obj
      where buf_prt-obj.obj-type  = p-obj-type
        and buf_prt-obj.obj-code  = p-obj-code
        and buf_prt-obj.artic     = p-artic
        and buf_prt-obj.prod-type = p-prod-type
        and buf_prt-obj.prod-code = p-prod-code
    on error undo, return error return-value
    :
      run prdoclib-create-temp-prt-obj in this-procedure
        (input  p-root-price-sale
        ,buffer buf_prt-obj
        ,buffer buf_temp-prt-obj
        ).
    end.
  end.
end procedure.
procedure prdoclib-calc-fact-sale :
  define input  parameter p-price-list-recid   as recid     no-undo .
  define output parameter p-fact-qnty          as decimal   no-undo .
  define output parameter p-cur-base           as decimal   no-undo .
  define output parameter p-cur-VAT-base       as decimal   no-undo .
  define output parameter p-cur-SLT-base       as decimal   no-undo .
  define output parameter p-cur-road-tax-base  as decimal   no-undo .
  define output parameter p-cur-excise-base    as decimal   no-undo .
  define buffer buf_main_price-list for ub.price-list .
  define buffer buf_price-list      for ub.price-list .
  define buffer buf_goods           for ub.goods .
  define buffer buf_gds-obj         for ub.gds-obj .
  define buffer buf_bar-code        for ub.bar-code .
  define variable l-empty-scale   as logical   no-undo .
  do
  on error undo, return error substitute("  &1 &2 " , return-value , error-status :get-message(1)  )
  on stop undo, return error substitute(" stop &1 &2" , return-value , error-status :get-message(1)  )
  on end-key undo, return error substitute(" end-key &1 &2" , return-value , error-status :get-message(1)  )
  :
    find first buf_main_price-list no-lock
      where recid(buf_main_price-list) = p-price-list-recid
      no-error .
    if not available buf_main_price-list
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info16 skip
        "Ошибка задания входных параметров" skip
        "Не найдена строка переоценки" skip
        "Код записи (recid)" p-price-list-recid skip
        view-as alert-box error .
      undo, return error substitute("  &1 &2 " , return-value , error-status :get-message(1)  )   .
    end.
    if buf_main_price-list.main-price <> true
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info16 skip
        "Ошибка задания входных параметров" skip
        "Строка переоценки не является основной" skip
        "Код записи (recid)" p-price-list-recid skip
        "Переоценка" buf_main_price-list.doc-num skip
        "Артикул" buf_main_price-list.artic buf_main_price-list.prod-type buf_main_price-list.prod-code skip
        "Бар-код" buf_main_price-list.b-code skip
        view-as alert-box error .
      undo, return error substitute("  &1 &2 " , return-value , error-status :get-message(1)  )  .
    end.
    find first buf_goods no-lock
      where buf_goods.artic     = buf_main_price-list.artic
        and buf_goods.prod-type = buf_main_price-list.prod-type
        and buf_goods.prod-code = buf_main_price-list.prod-code
      no-error .
    if not available buf_goods
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info16 skip
        "Не найден товар" skip
        "Переоценка" buf_main_price-list.doc-num skip
        "Артикул" buf_main_price-list.artic buf_main_price-list.prod-type buf_main_price-list.prod-code skip
        view-as alert-box error .
      undo, return error substitute("  &1 &2 " , return-value , error-status :get-message(1)  ) .
    end.
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsat in g#library
  (input  buf_main_price-list.artic
  ,input  buf_main_price-list.prod-type
  ,input  buf_main_price-list.prod-code
  ,input  'empty-scale=request':u
  ,output l-empty-scale
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info16 skip
        "Ошибка при определении атрибута товара" skip
        "Артикул" buf_main_price-list.artic buf_main_price-list.prod-type buf_main_price-list.prod-code skip
        'empty-scale=request':u skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error substitute("  &1 &2 " , return-value , error-status :get-message(1)  ) .
    end.
    find first buf_gds-obj no-lock
      where buf_gds-obj.gds-code = buf_goods.gds-code
        and buf_gds-obj.obj-type = buf_main_price-list.obj-type
        and buf_gds-obj.obj-code = buf_main_price-list.obj-code
      no-error .
      if not available buf_gds-obj then do:
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjcr in g#library
  (input  buf_main_price-list.obj-type
  ,input  buf_main_price-list.obj-code
  ,input  buf_goods.artic
  ,input  buf_goods.prod-type
  ,input  buf_goods.prod-code
  ,buffer buf_gds-obj
  ) no-error .
        if error-status :error then do:
           undo, return error substitute("  &1 &2 " , return-value , error-status :get-message(1)  ) .
        end.
      end.
    define variable price-rubl-with-tax-sale-prl    as decimal   no-undo .
    define variable price-base-with-tax-sale-prl    as decimal   no-undo .
    define variable price-rubl-without-tax-sale-prl as decimal   no-undo .
    define variable price-base-without-tax-sale-prl as decimal   no-undo .
    define variable vat-base-sale-prl               as decimal   no-undo .
    define variable vat-rubl-sale-prl               as decimal   no-undo .
    define variable vat-base-buyer-prl              as decimal   no-undo .
    define variable vat-rubl-buyer-prl              as decimal   no-undo .
    define variable slt-base-sale-prl               as decimal   no-undo .
    define variable slt-rubl-sale-prl               as decimal   no-undo .
    define variable road-tax-base-sale-prl          as decimal   no-undo .
    define variable road-tax-rubl-sale-prl          as decimal   no-undo .
    define variable excise-base-sale-prl            as decimal   no-undo .
    define variable excise-rubl-sale-prl            as decimal   no-undo .
    define variable discnt-base-sale-prl            as decimal   no-undo .
    define variable discnt-rubl-sale-prl            as decimal   no-undo .
    if buf_main_price-list.doc-qnty <> 0
    then do:
      run prl-vat in this-procedure
        (input  recid(buf_main_price-list)
        ,output price-rubl-with-tax-sale-prl
        ,output price-base-with-tax-sale-prl
        ,output price-rubl-without-tax-sale-prl
        ,output price-base-without-tax-sale-prl
        ,output vat-base-sale-prl
        ,output vat-rubl-sale-prl
        ,output vat-base-buyer-prl
        ,output vat-rubl-buyer-prl
        ,output slt-base-sale-prl
        ,output slt-rubl-sale-prl
        ,output road-tax-base-sale-prl
        ,output road-tax-rubl-sale-prl
        ,output excise-base-sale-prl
        ,output excise-rubl-sale-prl
        ,output discnt-base-sale-prl
        ,output discnt-rubl-sale-prl
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info16 skip
          "Ошибка при вызове процеды prl-vat" skip
          "Документ" buf_main_price-list.doc-num skip
          "Артикул" buf_main_price-list.artic buf_main_price-list.prod-type buf_main_price-list.prod-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error substitute("  &1 &2 " , return-value , error-status :get-message(1)  ) .
      end.
    end.
    else do:
      assign
        price-rubl-with-tax-sale-prl    = 0
        price-base-with-tax-sale-prl    = 0
        price-rubl-without-tax-sale-prl = 0
        price-base-without-tax-sale-prl = 0
        vat-base-sale-prl               = 0
        vat-rubl-sale-prl               = 0
        vat-base-buyer-prl              = 0
        vat-rubl-buyer-prl              = 0
        slt-base-sale-prl               = 0
        slt-rubl-sale-prl               = 0
        road-tax-base-sale-prl          = 0
        road-tax-rubl-sale-prl          = 0
        excise-base-sale-prl            = 0
        excise-rubl-sale-prl            = 0
        discnt-base-sale-prl            = 0
        discnt-rubl-sale-prl            = 0
      .
    end.
    define variable v-curr-r-b as character no-undo .
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
    if v-curr-r-b = 'base':U
    then do:
      assign
        p-fact-qnty         = buf_main_price-list.doc-qnty
        p-cur-base          = price-base-with-tax-sale-prl * buf_main_price-list.doc-qnty
        p-cur-VAT-base      = vat-base-sale-prl * buf_main_price-list.doc-qnty
        p-cur-SLT-base      = slt-base-sale-prl * buf_main_price-list.doc-qnty
        p-cur-road-tax-base = road-tax-base-sale-prl * buf_main_price-list.doc-qnty
        p-cur-excise-base   = excise-base-sale-prl * buf_main_price-list.doc-qnty
      .
    end.
    else do:
      assign
        p-fact-qnty         = buf_main_price-list.doc-qnty
        p-cur-base          = price-rubl-with-tax-sale-prl * buf_main_price-list.doc-qnty
        p-cur-VAT-base      = vat-rubl-sale-prl * buf_main_price-list.doc-qnty
        p-cur-SLT-base      = slt-rubl-sale-prl * buf_main_price-list.doc-qnty
        p-cur-road-tax-base = road-tax-rubl-sale-prl * buf_main_price-list.doc-qnty
        p-cur-excise-base   = excise-rubl-sale-prl * buf_main_price-list.doc-qnty
      .
    end.
      define variable v-unit-base like ub.goods.unit-base no-undo .
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run unitbase in g#library
  (input  buf_goods.gds-code
  ,output v-unit-base
  ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info16 skip
          "Ошибка при определении базовой единицы измерения товара" skip
          "Код товара" buf_goods.gds-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error substitute("  &1 &2 " , return-value , error-status :get-message(1)  ) .
      end.
      for each buf_price-list no-lock
        where buf_price-list.doc-num    = buf_main_price-list.doc-num
          and buf_price-list.main-price = false
          and buf_price-list.artic      = buf_main_price-list.artic
          and buf_price-list.prod-type  = buf_main_price-list.prod-type
          and buf_price-list.prod-code  = buf_main_price-list.prod-code
      :
        if buf_price-list.doc-qnty = ?
        then do:
          find first buf_bar-code no-lock
            where buf_bar-code.b-code = buf_price-list.b-code
            no-error .
          if available buf_bar-code
          and buf_bar-code.unit-cli = v-unit-base
          then do:
            message
              vss-workfile vss-revision vss-description skip
              vss-include-info16 skip
              "Ошибка при закрытии переоценки" skip
              "Не задано количество для бар-кода с основной единицей измерения" skip
              "Переоценка" buf_main_price-list.doc-num skip
              "Бар-код" buf_price-list.b-code skip
              "Артикул" buf_main_price-list.artic buf_main_price-list.prod-type buf_main_price-list.prod-code skip
              "Количество" buf_price-list.doc-qnty skip
              "Основная единица измерения" v-unit-base skip
              "Единица измерения бар-кода" buf_bar-code.unit-cli skip
              view-as alert-box error .
            undo, return error substitute("  &1 &2 " , return-value , error-status :get-message(1)  ) .
          end.
          next .
        end.
        if not can-find
          (first buf_bar-code
          where buf_bar-code.b-code = buf_price-list.b-code
          )
        then do:
          message
            vss-workfile vss-revision vss-description skip
            vss-include-info16 skip
            "В переоценке задан несуществующий бар-код" skip
            "Переоценка" buf_price-list.doc-num skip
            "Артикул" buf_price-list.artic buf_price-list.prod-type buf_price-list.prod-code skip
            "Бар-код" buf_price-list.b-code skip
            view-as alert-box error .
          undo, return error substitute("  &1 &2 " , return-value , error-status :get-message(1)  ) .
        end.
        if buf_price-list.doc-qnty <> 0
        then do:
          run prl-vat in this-procedure
            (input  recid(buf_price-list)
            ,output price-rubl-with-tax-sale-prl
            ,output price-base-with-tax-sale-prl
            ,output price-rubl-without-tax-sale-prl
            ,output price-base-without-tax-sale-prl
            ,output vat-base-sale-prl
            ,output vat-rubl-sale-prl
            ,output vat-base-buyer-prl
            ,output vat-rubl-buyer-prl
            ,output slt-base-sale-prl
            ,output slt-rubl-sale-prl
            ,output road-tax-base-sale-prl
            ,output road-tax-rubl-sale-prl
            ,output excise-base-sale-prl
            ,output excise-rubl-sale-prl
            ,output discnt-base-sale-prl
            ,output discnt-rubl-sale-prl
            ) no-error .
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              vss-include-info16 skip
              "Ошибка при вызове процеды prl-vat" skip
              "Документ" buf_price-list.doc-num skip
              "Артикул" buf_price-list.artic buf_price-list.prod-type buf_price-list.prod-code skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error substitute("  &1 &2 " , return-value , error-status :get-message(1)  ) .
          end.
        end.
        else do:
          assign
            price-rubl-with-tax-sale-prl    = 0
            price-base-with-tax-sale-prl    = 0
            price-rubl-without-tax-sale-prl = 0
            price-base-without-tax-sale-prl = 0
            vat-base-sale-prl               = 0
            vat-rubl-sale-prl               = 0
            vat-base-buyer-prl              = 0
            vat-rubl-buyer-prl              = 0
            slt-base-sale-prl               = 0
            slt-rubl-sale-prl               = 0
            road-tax-base-sale-prl          = 0
            road-tax-rubl-sale-prl          = 0
            excise-base-sale-prl            = 0
            excise-rubl-sale-prl            = 0
            discnt-base-sale-prl            = 0
            discnt-rubl-sale-prl            = 0
          .
        end.
        if v-curr-r-b = 'base':U
        then do:
          assign
            p-fact-qnty         = p-fact-qnty
                                + buf_price-list.doc-qnty
            p-cur-base          = p-cur-base
                                + price-base-with-tax-sale-prl * buf_price-list.doc-qnty
            p-cur-VAT-base      = p-cur-VAT-base
                                + vat-base-sale-prl * buf_price-list.doc-qnty
            p-cur-SLT-base      = p-cur-SLT-base
                                + slt-base-sale-prl * buf_price-list.doc-qnty
            p-cur-road-tax-base = p-cur-road-tax-base
                                + road-tax-base-sale-prl * buf_price-list.doc-qnty
            p-cur-excise-base   = p-cur-excise-base
                                + excise-base-sale-prl * buf_price-list.doc-qnty
          .
        end.
        else do:
          assign
            p-fact-qnty         = p-fact-qnty
                                + buf_price-list.doc-qnty
            p-cur-base          = p-cur-base
                                + price-rubl-with-tax-sale-prl * buf_price-list.doc-qnty
            p-cur-VAT-base      = p-cur-VAT-base
                                + vat-rubl-sale-prl * buf_price-list.doc-qnty
            p-cur-SLT-base      = p-cur-SLT-base
                                + slt-rubl-sale-prl * buf_price-list.doc-qnty
            p-cur-road-tax-base = p-cur-road-tax-base
                                + road-tax-rubl-sale-prl * buf_price-list.doc-qnty
            p-cur-excise-base   = p-cur-excise-base
                                + excise-rubl-sale-prl * buf_price-list.doc-qnty
          .
        end.
      end.
  end.
end procedure.
procedure prdoclib-calc-prc :
  define input  parameter p-price-doc-recid as   recid                  no-undo.
  define input  parameter p-cons-pay        as   integer                no-undo.
  define output parameter p-ov-cons         like ub.doc-line.price-base no-undo.
  define output parameter p-ov-VAT-cons     like ub.doc-line.price-base no-undo.
  define output parameter p-ov-SLT-cons     like ub.doc-line.price-base no-undo.
  define output parameter p-ov-prch         like ub.doc-line.price-base no-undo.
  define output parameter p-ov-VAT-prch     like ub.doc-line.price-base no-undo.
  define output parameter p-ov-SLT-prch     like ub.doc-line.price-base no-undo.
  do
  on error undo, return error return-value
  :
    define buffer buf_price-doc       for ub.price-doc .
    define buffer buf_price-list      for ub.price-list .
    define buffer buf_parts           for ub.parts .
    define variable v-ov-qnty     as decimal   no-undo .
    define variable v-ov-base     as decimal   no-undo .
    define variable v-ov-VAT-base as decimal   no-undo .
    define variable v-ov-SLT-base as decimal   no-undo .
    define variable v-cons-qnty   as decimal   no-undo .
    define variable v-prch-qnty   as decimal   no-undo .
    define variable v-cons-mult   as decimal   no-undo .
    define variable v-prch-mult   as decimal   no-undo .
    find first buf_price-doc no-lock
      where recid(buf_price-doc) = p-price-doc-recid
      no-error .
    if not available buf_price-doc
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info16 skip
        "Ошибка задания входных параметров" skip
        "Не найден документ переоценки" skip
        "Код записи (recid)" p-price-doc-recid skip
        view-as alert-box error .
      undo, return error .
    end.
    for each buf_price-list no-lock
      where buf_price-list.doc-num    = buf_price-doc.doc-num
        and buf_price-list.main-price = true
    on error undo, return error return-value
    :
      run prdoclib-calc-ov
        (input recid(buf_price-list)
        ,output v-ov-qnty
        ,output v-ov-base
        ,output v-ov-VAT-base
        ,output v-ov-SLT-base
        ) no-error .
      if error-status :error
      then do:
        if error-status :get-message(1) <> ""
        then do:
          message
            vss-workfile vss-revision vss-description skip
            vss-include-info16 skip
            "Ошибка при вызове процедуры prdoclib-calc-ov" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
        end.
        undo, return error return-value .
      end.
      assign
        v-cons-qnty = 0
        v-prch-qnty = 0
      .
      for each buf_parts no-lock
        where buf_parts.out-code  = buf_price-list.doc-num
          and buf_parts.obj-type  = buf_price-list.obj-type
          and buf_parts.obj-code  = buf_price-list.obj-code
          and buf_parts.artic     = buf_price-list.artic
          and buf_parts.prod-type = buf_price-list.prod-type
          and buf_parts.prod-code = buf_price-list.prod-code
      on error undo, return error return-value
      :
        if buf_parts.pay-code = p-cons-pay
        then do:
          assign
            v-cons-qnty = v-cons-qnty + buf_parts.fact-qnty
          .
        end.
        else do:
          assign
            v-prch-qnty = v-prch-qnty + buf_parts.fact-qnty
          .
        end.
      end.
      if (v-cons-qnty + v-prch-qnty) = 0
      then do:
        assign
          v-cons-mult = 0
          v-prch-mult = 1
        .
      end.
      else do:
        assign
          v-cons-mult = v-cons-qnty / (v-cons-qnty + v-prch-qnty)
          v-prch-mult = v-prch-qnty / (v-cons-qnty + v-prch-qnty)
        .
      end.
      assign
        p-ov-cons     = p-ov-cons     + v-ov-base     * v-cons-mult
        p-ov-VAT-cons = p-ov-VAT-cons + v-ov-VAT-base * v-cons-mult
        p-ov-SLT-cons = p-ov-SLT-cons + v-ov-SLT-base * v-cons-mult
        p-ov-prch     = p-ov-prch     + v-ov-base     * v-prch-mult
        p-ov-VAT-prch = p-ov-VAT-prch + v-ov-VAT-base * v-prch-mult
        p-ov-SLT-prch = p-ov-SLT-prch + v-ov-SLT-base * v-prch-mult
      .
    end.
  end.
end procedure.
procedure prdoclib-calc-ov :
  define input  parameter p-price-list-recid as recid     no-undo .
  define output parameter p-fact-qnty        as decimal   no-undo .
  define output parameter p-ov-base          as decimal   no-undo .
  define output parameter p-ov-VAT-base      as decimal   no-undo .
  define output parameter p-ov-SLT-base      as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    define buffer buf_main_price-list    for ub.price-list .
    define buffer buf_prev_price-list    for ub.price-list .
    define buffer buf_special_price-list for ub.price-list .
    define buffer buf_goods              for ub.goods .
    define variable v-fact-qnty             like ub.doc-line.price-base no-undo.
    define variable v-cur-base              like ub.doc-line.price-base no-undo.
    define variable v-cur-VAT-base          like ub.doc-line.price-base no-undo.
    define variable v-cur-SLT-base          like ub.doc-line.price-base no-undo.
    define variable v-cur-road-tax-base     like ub.doc-line.price-base no-undo.
    define variable v-cur-excise-base       like ub.doc-line.price-base no-undo.
    define variable v-prev-price-list-recid as   recid                  no-undo.
    define variable v-prev-cli-base-rate    like ub.goods.cli-base-rate no-undo.
    define variable v-prev-fact-qnty        like ub.doc-line.price-base no-undo.
    define variable v-prev-cur-base         like ub.doc-line.price-base no-undo.
    define variable v-prev-cur-VAT-base     like ub.doc-line.price-base no-undo.
    define variable v-prev-cur-SLT-base     like ub.doc-line.price-base no-undo.
    find first buf_main_price-list no-lock
      where recid(buf_main_price-list) = p-price-list-recid
      no-error .
    if not available buf_main_price-list
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info16 skip
        "Ошибка задания входных параметров" skip
        "Не найдена строка переоценки" skip
        "Код записи (recid)" p-price-list-recid skip
        view-as alert-box error .
      undo, return error .
    end.
    if buf_main_price-list.main-price <> true
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info16 skip
        "Ошибка задания входных параметров" skip
        "Строка переоценки не является основной" skip
        "Код записи (recid)" p-price-list-recid skip
        "Переоценка" buf_main_price-list.doc-num skip
        "Артикул" buf_main_price-list.artic buf_main_price-list.prod-type buf_main_price-list.prod-code skip
        "Бар-код" buf_main_price-list.b-code skip
        view-as alert-box error .
      undo, return error .
    end.
    run prdoclib-calc-fact-sale in this-procedure
      (input  recid(buf_main_price-list)
      ,output v-fact-qnty
      ,output v-cur-base
      ,output v-cur-VAT-base
      ,output v-cur-SLT-base
      ,output v-cur-road-tax-base
      ,output v-cur-excise-base
      ) no-error.
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info16 skip
        "Ошибка при расчете сумм переоценки." skip
        "Документ переоценки" buf_main_price-list.doc-num skip
        "Товар" buf_main_price-list.artic buf_main_price-list.prod-type buf_main_price-list.prod-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodepls in g#library
  (input  buf_main_price-list.obj-type
  ,input  buf_main_price-list.obj-code
  ,input  buf_main_price-list.b-code
  ,input  buf_main_price-list.b-code
  ,input  buf_main_price-list.fact-order
  ,output v-prev-price-list-recid
  ,output v-prev-cli-base-rate
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info16 skip
        "Ошибка при поиске предыдущей переоценки." skip
        "Документ переоценки " buf_main_price-list.doc-num skip
        "Товар " buf_main_price-list.artic buf_main_price-list.prod-type buf_main_price-list.prod-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    if v-prev-price-list-recid <> ?
    then do:
      find first buf_prev_price-list no-lock
        where recid(buf_prev_price-list) = v-prev-price-list-recid
        .
      find first buf_special_price-list no-lock
        where buf_special_price-list.doc-num    = buf_prev_price-list.doc-num
          and buf_special_price-list.main-price = false
          and buf_special_price-list.artic      = buf_prev_price-list.artic
          and buf_special_price-list.prod-type  = buf_prev_price-list.prod-type
          and buf_special_price-list.prod-code  = buf_prev_price-list.prod-code
          and buf_special_price-list.doc-qnty   <> ?
        no-error .
      if available buf_special_price-list
      then do:
        message
          "Товар имеет специальные цены на признаки" skip
          "Разбиение суммы переоценки по консигнации, выкупу невозможно" skip
          "Переоценка" buf_prev_price-list.doc-num skip
          "Товар" buf_prev_price-list.artic buf_prev_price-list.prod-type buf_prev_price-list.prod-code skip
          view-as alert-box error .
        undo, return error .
      end.
      find first buf_goods no-lock
        where buf_goods.artic     = buf_main_price-list.artic
          and buf_goods.prod-type = buf_main_price-list.prod-type
          and buf_goods.prod-code = buf_main_price-list.prod-code
        no-error .
      if not available buf_goods
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info16 skip
          "Не найден товар" skip
          "Переоценка" buf_main_price-list.doc-num skip
          "Артикул" buf_main_price-list.artic buf_main_price-list.prod-type buf_main_price-list.prod-code skip
          view-as alert-box error .
        undo, return error .
      end.
      if buf_prev_price-list.vat-pc = ?
      or buf_prev_price-list.slt-pc = ?
      then do:
        message
          "В переоценке не заданы налоги товара" skip
          "Разбиение суммы переоценки по консигнации, выкупу невозможно" skip
          "Переоценка" buf_prev_price-list.doc-num skip
          "Товар" buf_prev_price-list.artic buf_prev_price-list.prod-type buf_prev_price-list.prod-code skip
          "НДС" buf_prev_price-list.vat-pc skip
          "НП" buf_prev_price-list.slt-pc skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      define variable v-prev-cur-SLT-pc as decimal no-undo .
      assign
        v-prev-cur-SLT-pc   = buf_prev_price-list.price-sale * buf_prev_price-list.slt-pc / (100 + buf_prev_price-list.slt-pc)
      .
      assign
        v-prev-cur-base     = v-fact-qnty * buf_prev_price-list.price-sale
        v-prev-cur-VAT-base = v-fact-qnty
                            * (buf_prev_price-list.price-sale - v-prev-cur-SLT-pc)
                            * buf_prev_price-list.vat-pc / (100 + buf_prev_price-list.vat-pc)
        v-prev-cur-SLT-base = v-fact-qnty * v-prev-cur-SLT-pc
      .
      assign
        p-fact-qnty   = v-fact-qnty
        p-ov-base     = v-cur-base     - v-prev-cur-base
        p-ov-VAT-base = v-cur-VAT-base - v-prev-cur-VAT-base
        p-ov-SLT-base = v-cur-SLT-base - v-prev-cur-SLT-base
      .
    end.
    else do:
      assign
        v-prev-cur-base     = 0
        v-prev-cur-VAT-base = 0
        v-prev-cur-SLT-base = 0
        .
      assign
        p-fact-qnty   = v-fact-qnty
        p-ov-base     = v-cur-base     - v-prev-cur-base
        p-ov-VAT-base = v-cur-VAT-base - v-prev-cur-VAT-base
        p-ov-SLT-base = v-cur-SLT-base - v-prev-cur-SLT-base
      .
    end.
  end.
end procedure.
procedure prdoclib-init-prt-obj-by-factord :
  define input parameter p-obj-type           like ub.gds-obj.obj-type  no-undo .
  define input parameter p-obj-code           like ub.gds-obj.obj-code  no-undo .
  define input parameter p-artic              like ub.gds-obj.artic     no-undo .
  define input parameter p-prod-type          like ub.gds-obj.prod-type no-undo .
  define input parameter p-prod-code          like ub.gds-obj.prod-code no-undo .
  define input parameter p-fact-order         as decimal   no-undo .
  define input parameter p-include-fact-order as logical   no-undo .
  define variable vss-description as character no-undo init "prdoclib-init-prt-obj-by-factord: определение остатков по признакам на любой момент времени".
  define buffer buf_gds-obj      for ub.gds-obj .
  define buffer buf_doc-line     for ub.doc-line .
  define buffer buf_temp-prt-obj for temp-prt-obj .
  define variable v-total-gds-dtl-qnty as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    do transaction
    on error undo, return error return-value
    :
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
          vss-include-info16 skip
          "Невозможно найти gds-obj" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
      find current buf_gds-obj exclusive-lock .
    end.
    run prdoclib-init-temp-prt-obj in this-procedure
      (input p-obj-type
      ,input p-obj-code
      ,input p-artic
      ,input p-prod-type
      ,input p-prod-code
      ,input 0
      ) .
    for each buf_temp-prt-obj
      where buf_temp-prt-obj.is-term <> true
    on error undo, return error return-value
    :
      delete buf_temp-prt-obj .
    end.
    if p-include-fact-order = true
    then do:
      assign
       p-fact-order = p-fact-order - 0.0000000001
      .
    end.
    for each buf_doc-line no-lock
      where buf_doc-line.obj-type   = p-obj-type
        and buf_doc-line.obj-code   = p-obj-code
        and buf_doc-line.artic      = p-artic
        and buf_doc-line.prod-type  = p-prod-type
        and buf_doc-line.prod-code  = p-prod-code
        and buf_doc-line.status_    = 'факт':U
        and buf_doc-line.fact-order >= p-fact-order
    on error undo, return error return-value
    :
      run prdoclib-process-document in this-procedure
        (input  buf_doc-line.doc-code
        ,input  p-obj-type
        ,input  p-obj-code
        ,input  p-artic
        ,input  p-prod-type
        ,input  p-prod-code
        ,output v-total-gds-dtl-qnty
        ) .
    end.
  end.
end procedure.
procedure prdoclib-process-document :
  define input  parameter p-doc-code           as character no-undo .
  define input  parameter p-obj-type           as character no-undo .
  define input  parameter p-obj-code           as integer   no-undo .
  define input  parameter p-artic              as character no-undo .
  define input  parameter p-prod-type          as character no-undo .
  define input  parameter p-prod-code          as integer   no-undo .
  define output parameter p-total-gds-dtl-qnty as decimal   no-undo .
  define buffer buf_trn-doc      for ub.trn-doc .
  define buffer buf_gds-dtl      for ub.gds-dtl .
  define buffer buf_temp-prt-obj for temp-prt-obj .
  do
  on error undo, return error return-value
  :
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-doc-code
      no-error .
    if not available buf_trn-doc then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info16 skip
        "Ошибка при поиске документа" skip
        "Документ" p-doc-code skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        view-as alert-box error .
      undo, return error .
    end.
    assign
      p-total-gds-dtl-qnty = 0
    .
    for each buf_gds-dtl no-lock
      where buf_gds-dtl.doc-code  = p-doc-code
        and buf_gds-dtl.artic     = p-artic
        and buf_gds-dtl.prod-type = p-prod-type
        and buf_gds-dtl.prod-code = p-prod-code
    on error undo, return error
    :
      define variable v-term-node as integer   no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run termnode in g#library
  (input  buf_gds-dtl.prt-code
  ,output v-term-node
  )  .
      run prdoclib-temp-prt-obj-by-prt-root in this-procedure
        (input  v-term-node
        ,buffer buf_temp-prt-obj
        ) .
      if buf_temp-prt-obj.is-term <> true then do:
        undo, return error substitute("Документ ссылается на нетерминальный признак. Код признака &1"
                                     ,buf_gds-dtl.prt-code
                                     ) .
      end.
      case buf_trn-doc.doc-type :
        when 'при':U or
        when 'возврат':U
        then do:
          assign
            p-total-gds-dtl-qnty        = p-total-gds-dtl-qnty
                                        - buf_gds-dtl.fact-qnty
            buf_temp-prt-obj.fact-qnty  = buf_temp-prt-obj.fact-qnty
                                        - buf_gds-dtl.fact-qnty
          .
        end.
        when 'рас':U or
        when 'спи':U
        then do:
          assign
            p-total-gds-dtl-qnty        = p-total-gds-dtl-qnty
                                        + buf_gds-dtl.fact-qnty
            buf_temp-prt-obj.fact-qnty  = buf_temp-prt-obj.fact-qnty
                                        + buf_gds-dtl.fact-qnty
          .
        end.
        when 'инв':U
        then do:
          assign
            p-total-gds-dtl-qnty        = p-total-gds-dtl-qnty
                                        - buf_gds-dtl.doc-qnty
            buf_temp-prt-obj.fact-qnty  = buf_temp-prt-obj.fact-qnty
                                        - buf_gds-dtl.doc-qnty
          .
        end.
        otherwise do:
          undo, return error substitute("Неизвестный тип документа &1"
                                       ,buf_trn-doc.doc-type
                                       ) .
        end.
      end.
    end.
  end.
end procedure.
procedure prdoclib-prc-pl-document :
  define input  parameter p-doc-code              as character no-undo .
  define input  parameter p-obj-type              as character no-undo .
  define input  parameter p-obj-code              as integer   no-undo .
  define input  parameter p-gds-code              as integer   no-undo .
  define output parameter p-total-pl-gds-qnty     as decimal   no-undo .
  define output parameter p-total-pl-gds-cli-qnty as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    define buffer buf_trn-doc      for ub.trn-doc .
    define buffer buf_doc-pl       for ub.doc-pl .
    define buffer buf_temp-pl-gds for temp-pl-gds .
    define variable v-sign as decimal   no-undo .
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-doc-code
      no-error .
    if not available buf_trn-doc then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info16 skip
        "Ошибка при поиске документа" skip
        "Документ" p-doc-code skip
        "Объект" p-obj-type p-obj-code skip
        "Товар" p-gds-code skip
        view-as alert-box error .
      undo, return error .
    end.
    assign
      p-total-pl-gds-qnty     = 0
      p-total-pl-gds-cli-qnty = 0
    .
    for each buf_doc-pl no-lock
      where buf_doc-pl.out-code  = p-doc-code
        and buf_doc-pl.gds-code  = p-gds-code
    on error undo, return error return-value
    :
      find first buf_temp-pl-gds
        where buf_temp-pl-gds.obj-type = buf_trn-doc.obj-type
          and buf_temp-pl-gds.obj-code = buf_trn-doc.obj-code
          and buf_temp-pl-gds.pl-code  = buf_doc-pl.pl-code
        .
      case buf_trn-doc.doc-type :
        when 'при':U
        or when 'возврат':U
        or when 'инв':U
        then do:
          assign
            v-sign = -1.0
          .
        end.
        when 'рас':U or
        when 'спи':U
        then do:
          assign
            v-sign = 1.0
          .
        end.
        otherwise do:
          undo, return error substitute("(prdoclib-prc-pl-document) Неизвестный тип документа &1", buf_trn-doc.doc-type ) .
        end.
      end case.
      assign
        p-total-pl-gds-qnty           = p-total-pl-gds-qnty           + buf_doc-pl.fact-qnty     * v-sign
        p-total-pl-gds-cli-qnty       = p-total-pl-gds-cli-qnty       + buf_doc-pl.cli-fact-qnty * v-sign
        buf_temp-pl-gds.fact-qnty     = buf_temp-pl-gds.fact-qnty     + buf_doc-pl.fact-qnty     * v-sign
        buf_temp-pl-gds.cli-fact-qnty = buf_temp-pl-gds.cli-fact-qnty + buf_doc-pl.cli-fact-qnty * v-sign
      .
    end.
  end.
end procedure.
procedure prdoclib-init-prt-obj-by-date :
  define input parameter p-obj-type   like ub.gds-obj.obj-type  no-undo .
  define input parameter p-obj-code   like ub.gds-obj.obj-code  no-undo .
  define input parameter p-artic      like ub.gds-obj.artic     no-undo .
  define input parameter p-prod-type  like ub.gds-obj.prod-type no-undo .
  define input parameter p-prod-code  like ub.gds-obj.prod-code no-undo .
  define input parameter p-fact-date  as date      no-undo .
  define variable vss-description as character no-undo init "prdoclib-init-prt-obj-by-date: определение остатков по признакам на конец дня".
  do
  on error undo, return error return-value
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
        vss-include-info16 skip
        "Ошибка при определении момента времени, на который требуется остаток" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "Дата" p-fact-date skip
        view-as alert-box error .
      undo, return error .
    end.
    run prdoclib-init-prt-obj-by-date-factord in this-procedure
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
        vss-include-info16 skip
        "Ошибка при вызове метода prdoclib-init-prt-obj-by-date-factord" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "Дата" p-fact-date skip
        view-as alert-box error .
      undo, return error .
    end.
  end.
end procedure.
procedure prdoclib-calc-temp-fact-sale :
  define input  parameter p-obj-type           as character no-undo .
  define input  parameter p-obj-code           as integer   no-undo .
  define input  parameter p-gds-code           as integer   no-undo .
  define input  parameter p-day-end-fact-order as decimal   no-undo .
  define input  parameter p-curr-r-b           as character no-undo .
  define output parameter p-fact-qnty          as decimal   no-undo .
  define output parameter p-cur-base           as decimal   no-undo .
  define output parameter p-cur-VAT-base       as decimal   no-undo .
  define output parameter p-cur-SLT-base       as decimal   no-undo .
  define output parameter p-cur-road-tax-base  as decimal   no-undo .
  define output parameter p-cur-excise-base    as decimal   no-undo .
  define buffer buf_temp-prt-obj for temp-prt-obj .
  define variable v-prt-b-code        like ub.bar-code.b-code no-undo .
  define variable v-cli-base-rate     like ub.bar-code.cli-base-rate no-undo .
  define variable parrecid-prl        as recid     no-undo .
  define variable v-fact-qnty         as decimal   no-undo .
  define variable v-cur-base          as decimal   no-undo .
  define variable v-cur-VAT-base      as decimal   no-undo .
  define variable v-cur-SLT-base      as decimal   no-undo .
  define variable v-cur-road-tax-base as decimal   no-undo .
  define variable v-cur-excise-base   as decimal   no-undo .
  define variable price-rubl-with-tax-sale-prl    as decimal   no-undo .
  define variable price-base-with-tax-sale-prl    as decimal   no-undo .
  define variable price-rubl-without-tax-sale-prl as decimal   no-undo .
  define variable price-base-without-tax-sale-prl as decimal   no-undo .
  define variable vat-base-sale-prl               as decimal   no-undo .
  define variable vat-rubl-sale-prl               as decimal   no-undo .
  define variable vat-base-buyer-prl              as decimal   no-undo .
  define variable vat-rubl-buyer-prl              as decimal   no-undo .
  define variable slt-base-sale-prl               as decimal   no-undo .
  define variable slt-rubl-sale-prl               as decimal   no-undo .
  define variable road-tax-base-sale-prl          as decimal   no-undo .
  define variable road-tax-rubl-sale-prl          as decimal   no-undo .
  define variable excise-base-sale-prl            as decimal   no-undo .
  define variable excise-rubl-sale-prl            as decimal   no-undo .
  define variable discnt-base-sale-prl            as decimal   no-undo .
  define variable discnt-rubl-sale-prl            as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    for each buf_temp-prt-obj no-lock
    on error undo, return error return-value
    :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  p-gds-code
  ,input  buf_temp-prt-obj.prt-code
  ,output v-prt-b-code
  ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении бар-кода признака" skip
          "Код товара"   p-gds-code skip
          "Код признака" buf_temp-prt-obj.prt-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodepls in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  v-prt-b-code
  ,input  0
  ,input  p-day-end-fact-order
  ,output parrecid-prl
  ,output v-cli-base-rate
  ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении цены бар-кода" skip
          "Объект" p-obj-type p-obj-code skip
          "Бар-код" v-prt-b-code skip
          "fact-order" p-day-end-fact-order skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
      if parrecid-prl <> ?
      then do:
        run prl-vat in this-procedure
          (input  parrecid-prl
          ,output price-rubl-with-tax-sale-prl
          ,output price-base-with-tax-sale-prl
          ,output price-rubl-without-tax-sale-prl
          ,output price-base-without-tax-sale-prl
          ,output vat-base-sale-prl
          ,output vat-rubl-sale-prl
          ,output vat-base-buyer-prl
          ,output vat-rubl-buyer-prl
          ,output slt-base-sale-prl
          ,output slt-rubl-sale-prl
          ,output road-tax-base-sale-prl
          ,output road-tax-rubl-sale-prl
          ,output excise-base-sale-prl
          ,output excise-rubl-sale-prl
          ,output discnt-base-sale-prl
          ,output discnt-rubl-sale-prl
          ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при вызове процеды prl-vat" skip
            "Объект" p-obj-type p-obj-code skip
            "Код товара" p-gds-code skip
            "Указатель на запись переоценки" parrecid-prl skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error .
        end.
      end.
      else do:
        assign
          price-rubl-with-tax-sale-prl    = 0
          price-base-with-tax-sale-prl    = 0
          price-rubl-without-tax-sale-prl = 0
          price-base-without-tax-sale-prl = 0
          vat-base-sale-prl               = 0
          vat-rubl-sale-prl               = 0
          slt-base-sale-prl               = 0
          slt-rubl-sale-prl               = 0
          road-tax-base-sale-prl          = 0
          road-tax-rubl-sale-prl          = 0
          excise-base-sale-prl            = 0
          excise-rubl-sale-prl            = 0
          discnt-base-sale-prl            = 0
          discnt-rubl-sale-prl            = 0
        .
      end.
      assign
        v-fact-qnty         = v-fact-qnty
                            + buf_temp-prt-obj.fact-qnty
        v-cur-base          = v-cur-base
                            + (if p-curr-r-b = 'base':U
                                then price-base-with-tax-sale-prl
                                else price-rubl-with-tax-sale-prl
                              )
                            * buf_temp-prt-obj.fact-qnty
        v-cur-VAT-base      = v-cur-VAT-base
                            + (if p-curr-r-b = 'base':U
                                then vat-base-sale-prl
                                else vat-rubl-sale-prl
                              )
                            * buf_temp-prt-obj.fact-qnty
        v-cur-SLT-base      = v-cur-SLT-base
                            + (if p-curr-r-b = 'base':U
                                then slt-base-sale-prl
                                else slt-rubl-sale-prl
                              )
                            * buf_temp-prt-obj.fact-qnty
        v-cur-road-tax-base = v-cur-road-tax-base
                            + (if p-curr-r-b = 'base':U
                                then road-tax-base-sale-prl
                                else road-tax-rubl-sale-prl
                              )
                            * buf_temp-prt-obj.fact-qnty
        v-cur-excise-base   = v-cur-excise-base
                            + (if p-curr-r-b = 'base':U
                                then excise-base-sale-prl
                                else excise-rubl-sale-prl
                              )
                            * buf_temp-prt-obj.fact-qnty
      .
    end.
    assign
      p-fact-qnty         = v-fact-qnty
      p-cur-base          = v-cur-base
      p-cur-VAT-base      = v-cur-VAT-base
      p-cur-SLT-base      = v-cur-SLT-base
      p-cur-road-tax-base = v-cur-road-tax-base
      p-cur-excise-base   = v-cur-excise-base
    .
  end.
end procedure.
procedure prdoclib-clear-temp-pl-gds :
  define buffer buf_temp-pl-gds for temp-pl-gds .
  do
  on error undo, return error return-value
  :
    for each buf_temp-pl-gds
    on error undo, return error return-value
    :
      delete buf_temp-pl-gds .
    end.
  end.
end procedure.
procedure prdoclib-init-temp-pl-gds :
  define input parameter p-obj-type        like ub.pl-gds.obj-type  no-undo .
  define input parameter p-obj-code        like ub.pl-gds.obj-code  no-undo .
  define input parameter p-gds-code        like ub.pl-gds.gds-code  no-undo .
  define buffer buf_pl-gds      for ub.pl-gds .
  define buffer buf_temp-pl-gds for temp-pl-gds .
  do
  on error undo, return error return-value
  :
    run prdoclib-clear-temp-pl-gds in this-procedure .
    for each buf_pl-gds
      where buf_pl-gds.obj-type = p-obj-type
        and buf_pl-gds.obj-code = p-obj-code
        and buf_pl-gds.gds-code = p-gds-code
    on error undo, return error return-value
    :
      create buf_temp-pl-gds .
      buffer-copy buf_pl-gds to buf_temp-pl-gds .
    end.
  end.
end procedure.
procedure prdoclib-init-pl-gds-by-factord :
  define input parameter p-obj-type           like ub.gds-obj.obj-type  no-undo .
  define input parameter p-obj-code           like ub.gds-obj.obj-code  no-undo .
  define input parameter p-artic              like ub.gds-obj.artic     no-undo .
  define input parameter p-prod-type          like ub.gds-obj.prod-type no-undo .
  define input parameter p-prod-code          like ub.gds-obj.prod-code no-undo .
  define input parameter p-fact-order         as decimal   no-undo .
  define input parameter p-include-fact-order as logical   no-undo .
  define variable vss-description as character no-undo init "prdoclib-init-pl-gds-by-factord: определение остатков по признакам на любой момент времени".
  define buffer buf_goods       for ub.goods .
  define buffer buf_gds-obj     for ub.gds-obj .
  define buffer buf_doc-line    for ub.doc-line .
  define buffer buf_temp-pl-gds for temp-pl-gds .
  define variable v-total-pl-gds-qnty     as decimal   no-undo .
  define variable v-total-pl-gds-cli-qnty as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    do transaction
    on error undo, return error return-value
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
          vss-include-info16 skip
          "Невозможно найти gds-obj" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      find current buf_gds-obj exclusive-lock .
    end.
    find first buf_goods no-lock
      where buf_goods.artic     = p-artic
        and buf_goods.prod-type = p-prod-type
        and buf_goods.prod-code = p-prod-code
      .
    run prdoclib-init-temp-pl-gds in this-procedure
      (input p-obj-type
      ,input p-obj-code
      ,input buf_goods.gds-code
      ) .
    if p-include-fact-order = true
    then do:
      assign
       p-fact-order = p-fact-order - 0.0000000001
      .
    end.
    for each buf_doc-line no-lock
      where buf_doc-line.obj-type   = p-obj-type
        and buf_doc-line.obj-code   = p-obj-code
        and buf_doc-line.artic      = p-artic
        and buf_doc-line.prod-type  = p-prod-type
        and buf_doc-line.prod-code  = p-prod-code
        and buf_doc-line.status_    = 'факт':U
        and buf_doc-line.fact-order >= p-fact-order
    on error undo, return error return-value
    :
      run prdoclib-prc-pl-document in this-procedure
        ( input  buf_doc-line.doc-code
         ,input  p-obj-type
         ,input  p-obj-code
         ,input  buf_goods.gds-code
         ,output v-total-pl-gds-qnty
         ,output v-total-pl-gds-cli-qnty
        ) .
    end.
  end.
end procedure.
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure prl-vat:
  define input parameter parrecid as recid no-undo.
    define output parameter price-rubl-with-tax-saleprl    like ub.doc-line.price-rubl no-undo.
    define output parameter price-base-with-tax-saleprl    like ub.doc-line.price-base no-undo.
    define output parameter price-rubl-without-tax-saleprl like ub.doc-line.price-rubl no-undo.
    define output parameter price-base-without-tax-saleprl like ub.doc-line.price-base no-undo.
    define output parameter vat-base-saleprl               like ub.doc-line.price-base no-undo.
    define output parameter vat-rubl-saleprl               like ub.doc-line.price-rubl no-undo.
    define output parameter vat-base-buyerprl              like ub.doc-line.price-base no-undo.
    define output parameter vat-rubl-buyerprl              like ub.doc-line.price-rubl no-undo.
    define output parameter slt-base-saleprl               like ub.doc-line.price-base no-undo.
    define output parameter slt-rubl-saleprl               like ub.doc-line.price-rubl no-undo.
    define output parameter road-tax-base-saleprl          like ub.doc-line.road-tax   no-undo.
    define output parameter road-tax-rubl-saleprl          like ub.doc-line.road-tax   no-undo.
    define output parameter excise-base-saleprl            like ub.doc-line.price-base no-undo.
    define output parameter excise-rubl-saleprl            like ub.doc-line.price-rubl no-undo.
    define output parameter discnt-base-saleprl            like ub.gds-dtl.discnt-base no-undo.
    define output parameter discnt-rubl-saleprl            like ub.gds-dtl.discnt-rubl no-undo.
    define buffer out-vatp_gds-dtlprl     for ub.gds-dtl.
    define buffer buf_out-vatp_gds-dtlprl for ub.gds-dtl.
    define buffer out-vatp_partsprl       for ub.parts.
    define buffer out-vatp_sysconfprl     for ub.sysconf.
    define buffer out-vatp_doc-lineprl    for ub.doc-line.
    define buffer out-vatp_goodsprl       for ub.goods.
    define buffer out-vatp_trn-docprl     for ub.trn-doc.
    define buffer out-vatp_doc-attrprl    for ub.doc-attr.
    define variable varprice-base-consprl      like ub.doc-line.price-base initial 0.00 no-undo.
    define variable varprice-rubl-consprl      like ub.doc-line.price-rubl initial 0.00 no-undo.
    define variable varfrm-cnsv-typeprl         as   character                           no-undo.
    define variable varfrm-cnsvprl              as   character                           no-undo.
    define variable varroot-nodeprl             as   integer                             no-undo.
    define variable varempty-scaleprl           as   logical                             no-undo.
    define variable varis-cons-parts-haveprl    as   logical                             no-undo.
    define variable varsum-base-factovpprl      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-factovpprl      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-factovpprl      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-factovpprl  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-factovpprl      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-base-docovpprl       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-docovpprl       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-docovpprl       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-docovpprl   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-docovpprl       like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-factovpprl      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-factovpprl      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-factovpprl      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-factovpprl  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-factovpprl      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-docovpprl       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-docovpprl       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-docovpprl       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-docovpprl   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-docovpprl       like ub.gds-dtl.price-base               no-undo.
    define variable varfact-qntyprl             like ub.parts.fact-qnty                  no-undo.
    define variable varcons-qntyprl             like ub.parts.fact-qnty                  no-undo.
    define variable varis-one-gds-dtlprl        as   logical                             no-undo.
    define variable varcurprlprice-base         like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurprlprice-rubl         like ub.gds-dtl.price-base               no-undo.
    define variable varcurprldiscnt-base        like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurprldiscnt-rubl        like ub.gds-dtl.price-base               no-undo.
    define variable varoutvprbprl               as   character                           no-undo.
    define variable out-vatp-have-vat-sltprl    as   logical initial yes                 no-undo.
    define buffer   in-vatp-trn-docoprl  for ub.trn-doc .
    define buffer   in-vatp-partsoprl    for ub.parts   .
    define buffer   in-vatp-docoprl      for ub.trn-doc .
    define buffer   in-vatp-goodsoprl    for ub.goods   .
    define buffer   in-vatp-sysconfoprl  for ub.sysconf .
    define buffer   in-vatp_doc-attroprl for ub.doc-attr.
    define variable in-vatp-have-vat-sltoprl       as   logical initial yes    no-undo.
    define variable vat-pc-locoprl                 like ub.doc-line.vat-pc     no-undo.
    define variable varinvprboprl                  as   character              no-undo.
    define variable slt-pc-locoprl                 like ub.doc-line.slt-pc     no-undo.
    define variable cli-base-rateoprl              as   decimal                no-undo.
    define variable price-rubl-with-tax-locoprl    like ub.doc-line.price-rubl no-undo.
    define variable price-base-with-tax-locoprl    like ub.doc-line.price-base no-undo.
    define variable price-cli-with-tax-locoprl     like ub.doc-line.price-cli  no-undo.
    define variable price-rubl-without-tax-locoprl like ub.doc-line.price-rubl no-undo.
    define variable price-base-without-tax-locoprl like ub.doc-line.price-base no-undo.
    define variable price-cli-without-tax-locoprl  like ub.doc-line.price-base no-undo.
    define variable vat-base-locoprl               like ub.doc-line.price-base no-undo.
    define variable vat-rubl-locoprl               like ub.doc-line.price-rubl no-undo.
    define variable vat-cli-locoprl                like ub.doc-line.price-rubl no-undo.
    define variable slt-base-locoprl               like ub.doc-line.price-base no-undo.
    define variable slt-rubl-locoprl               like ub.doc-line.price-rubl no-undo.
    define variable slt-cli-locoprl                like ub.doc-line.price-rubl no-undo.
    define variable road-tax-base-locoprl          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-rubl-locoprl          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-cli-locoprl           like ub.doc-line.road-tax   no-undo.
    define variable transport-base-locoprl         like ub.doc-line.price-base no-undo.
    define variable transport-rubl-locoprl         like ub.doc-line.price-rubl no-undo.
    define variable transport-cli-locoprl          like ub.doc-line.price-rubl no-undo.
    define variable other-base-locoprl             like ub.doc-line.price-base no-undo.
    define variable other-rubl-locoprl             like ub.doc-line.price-rubl no-undo.
    define variable other-cli-locoprl              like ub.doc-line.price-rubl no-undo.
    define variable exch-rate-cli-locoprl          like ub.trn-doc.exch-rate   no-undo.
    define variable varinvatp-envdoprl             as   character              no-undo.
    define variable varinvatp-typeoprl             as   character              no-undo.
  define buffer bf_price-list for ub.price-list.
  define buffer bf_goods      for ub.goods.
  define buffer bf_sysconf    for ub.sysconf.
  define buffer bf_parts      for ub.parts.
  define variable varbase-rate   like ub.trn-doc.base-rate     no-undo.
  define variable varbase-scale  like ub.trn-doc.base-scale    no-undo.
  define variable varroad-tax    like ub.price-list.road-tax   no-undo.
  define variable varexcise      like ub.price-list.excise     no-undo.
  define variable varvat-pc      like ub.doc-line.vat-pc       no-undo.
  define variable varslt-pc      like ub.doc-line.slt-pc       no-undo.
  define variable varprice-base  like ub.price-list.price-sale no-undo.
  define variable varprice-rubl  like ub.price-list.price-sale no-undo.
  define variable vardiscnt-base like ub.price-list.price-sale no-undo.
  define variable vardiscnt-rubl like ub.price-list.price-sale no-undo.
  define variable v-host-code    like ub.sysconf.host-code     no-undo.
  define variable vardoc-num     like ub.price-list.doc-num    no-undo.
  define variable vardoc-code    like ub.price-list.doc-num    no-undo.
  define variable varobj-type    like ub.price-list.obj-type   no-undo.
  define variable varobj-code    like ub.price-list.obj-code   no-undo.
  define variable varartic       like ub.price-list.artic      no-undo.
  define variable varprod-type   like ub.price-list.prod-type  no-undo.
  define variable varprod-code   like ub.price-list.prod-code  no-undo.
  define variable varfact-qnty   like ub.price-list.doc-qnty   no-undo.
  define variable varcons-vat-pc like ub.doc-line.vat-pc       no-undo.
  define variable varext-doc-type like ub.trn-doc.ext-doc-type no-undo.
  define variable vardoc-qnty     like ub.price-list.doc-qnty no-undo.
  define variable vardoc-type     as   character              no-undo.
  do
  on error undo, return error "Ошибка при вызове процедуры prl-vat."
  :
    find first bf_price-list no-lock
      where recid(bf_price-list) = parrecid
      no-error .
    if not available bf_price-list
    then do:
      return error "Ошибка во входящих параметрах prl-vat.i" .
    end.
    find first bf_goods no-lock
      where bf_goods.artic     = bf_price-list.artic
        and bf_goods.prod-type = bf_price-list.prod-type
        and bf_goods.prod-code = bf_price-list.prod-code
      no-error .
    if not available bf_goods
    then do:
      undo, return error substitute("Не найден товар &1 &2 &3 для переоценки с кодом &4",bf_price-list.artic,bf_price-list.prod-type,bf_price-list.prod-code,parrecid).
    end.
    assign
      varvat-pc = bf_price-list.vat-pc
      varslt-pc = bf_price-list.slt-pc
    .
    if varvat-pc = ?
    then do:
      undo, return error substitute("В переоценке &1 для товара &2 &3 &4 не задан НДС",bf_price-list.doc-num,bf_price-list.artic,bf_price-list.prod-type,bf_price-list.prod-code).
    end.
    if varslt-pc = ?
    then do:
      undo, return error substitute("В переоценке &1 для товара &2 &3 &4 не задан НП",bf_price-list.doc-num,bf_price-list.artic,bf_price-list.prod-type,bf_price-list.prod-code).
    end.
    assign
      varbase-rate   = 1
      varbase-scale  = 1
      varroad-tax    = bf_price-list.road-tax
      varexcise      = bf_price-list.excise
      varprice-base  = bf_price-list.price-sale
      varprice-rubl  = bf_price-list.price-sale
      vardiscnt-base = 0
      vardiscnt-rubl = 0
    .
    assign
      varfact-qnty = 0
    .
    for each bf_parts no-lock
      where bf_parts.out-code   = bf_price-list.doc-num
        and bf_parts.obj-type   = bf_price-list.obj-type
        and bf_parts.obj-code   = bf_price-list.obj-code
        and bf_parts.artic      = bf_price-list.artic
        and bf_parts.prod-type  = bf_price-list.prod-type
        and bf_parts.prod-code  = bf_price-list.prod-code
    :
      assign
        varfact-qnty = varfact-qnty + bf_parts.fact-qnty
      .
    end.
    assign
      vardoc-num   = bf_price-list.doc-num
      vardoc-code  = bf_price-list.doc-num
      varobj-type  = bf_price-list.obj-type
      varobj-code  = bf_price-list.obj-code
      varartic     = bf_price-list.artic
      varprod-type = bf_price-list.prod-type
      varprod-code = bf_price-list.prod-code
      vardoc-qnty  = varfact-qnty
      varext-doc-type = 'ot':U
    .
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  bf_price-list.obj-type
  ,input  bf_price-list.obj-code
  ,output v-host-code
  )  .
    find first bf_sysconf no-lock
      where bf_sysconf.host-code = v-host-code
      .
    if bf_sysconf.cons-vat-pc = ?
    then do:
      return error "Не задан консигнационный НДС по фирме." .
    end.
    else do:
      assign
        varcons-vat-pc = bf_sysconf.cons-vat-pc
      .
    end.
if varext-doc-type = 'ot':U or
   varext-doc-type = ?                 then do:
  assign
   out-vatp-have-vat-sltprl = yes.
end.
else do:
  find first out-vatp_doc-attrprl no-lock
    where out-vatp_doc-attrprl.doc-code  = vardoc-code
      and out-vatp_doc-attrprl.attr-code = 'envd':U
      no-error .
  if not available out-vatp_doc-attrprl then do:
    assign
      out-vatp-have-vat-sltprl = yes.
  end.
  else do:
     out-vatp-have-vat-sltprl = no.
  end.
end.
find first out-vatp_goodsprl where out-vatp_goodsprl.artic     = varartic     and
                                   out-vatp_goodsprl.prod-type = varprod-type and
                                   out-vatp_goodsprl.prod-code = varprod-code no-lock.
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  varartic
  ,input  varprod-type
  ,input  varprod-code
  ,output varroot-nodeprl
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении корневого признака товара" skip
    "Артикул" varartic varprod-type varprod-code skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtat in g#library
  (input  varroot-nodeprl
  ,input  'empty-scale=request'
  ,output varempty-scaleprl
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении атрибута признака" skip
    "Артикул" varartic varprod-type varprod-code skip
    "Признак" varroot-nodeprl skip
    "Запрашивался атрибут" "empty-scale=request" skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varoutvprbprl
  )  .
if varoutvprbprl = "base":u then do:
  assign
        road-tax-base-saleprl    =  (if varroad-tax = ? then 0 else varroad-tax * 1)
    excise-base-saleprl      =  (if varexcise   = ? then 0 else varexcise   * 1)
  .
end.
else do:
  assign
        road-tax-base-saleprl    =  (if varroad-tax = ? then 0 else varroad-tax / varbase-rate * varbase-scale)
    excise-base-saleprl      =  (if varexcise   = ? then 0 else varexcise   / varbase-rate * varbase-scale)
  .
end.
if varoutvprbprl = "rubl":u then do:
  assign
        road-tax-rubl-saleprl    = (if varroad-tax = ? then 0 else varroad-tax * 1)
    excise-rubl-saleprl      = (if varexcise   = ? then 0 else varexcise   * 1) .
end.
else do:
  assign
        road-tax-rubl-saleprl    = (if varroad-tax = ? then 0 else varroad-tax * varbase-rate / varbase-scale)
    excise-rubl-saleprl      = (if varexcise   = ? then 0 else varexcise   * varbase-rate / varbase-scale) .
end.
assign
  varis-cons-parts-haveprl =  no.
assign
  varfact-qntyprl       = 0
  varcons-qntyprl       = 0
  varprice-base-consprl = 0
  varprice-rubl-consprl = 0.
find first out-vatp_doc-lineprl where
           out-vatp_doc-lineprl.doc-code   = vardoc-num
       and out-vatp_doc-lineprl.artic      = varartic
       and out-vatp_doc-lineprl.prod-type  = varprod-type
       and out-vatp_doc-lineprl.prod-code  = varprod-code no-lock no-error.
if available out-vatp_doc-lineprl           and
  (out-vatp_doc-lineprl.status_ = 'запрос':U or out-vatp_goodsprl.gds-type = 'у':U) then do:
  assign
    varfact-qntyprl = out-vatp_doc-lineprl.fact-qnty.
end.
else do:
  for each out-vatp_partsprl where out-vatp_partsprl.out-code   = vardoc-num
                               and out-vatp_partsprl.obj-type   = varobj-type
                               and out-vatp_partsprl.obj-code   = varobj-code
                               and out-vatp_partsprl.artic      = varartic
                               and out-vatp_partsprl.prod-type  = varprod-type
                               and out-vatp_partsprl.prod-code  = varprod-code no-lock :
    if out-vatp_partsprl.purch-code = 2 then do:
assign
  price-rubl-with-tax-locoprl = out-vatp_partsprl.price-rubl
  price-base-with-tax-locoprl = out-vatp_partsprl.price-base
.
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprboprl
  )  .
  if out-vatp_partsprl.out-code = 'free-zone':U     or
     out-vatp_partsprl.out-code = 'out-zone':U   or
     out-vatp_partsprl.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-sltoprl = yes.
  end.
  else do:
    find first in-vatp_doc-attroprl no-lock
      where in-vatp_doc-attroprl.doc-code  = out-vatp_partsprl.out-code
        and in-vatp_doc-attroprl.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attroprl then do:
      assign
        in-vatp-have-vat-sltoprl = yes.
    end.
    else do:
         in-vatp-have-vat-sltoprl = no.
    end.
  end.
  assign
   price-cli-with-tax-locoprl = out-vatp_partsprl.price-cli
   cli-base-rateoprl          = out-vatp_partsprl.cli-base-rate.
  ASSIGN   road-tax-base-locoprl  = (if out-vatp_partsprl.road-tax-base  = ? then 0 else out-vatp_partsprl.road-tax-base)
           road-tax-rubl-locoprl  = (if out-vatp_partsprl.road-tax-rubl  = ? then 0 else out-vatp_partsprl.road-tax-rubl).
  ASSIGN  transport-base-locoprl = (if out-vatp_partsprl.transport-base = ? then 0 else out-vatp_partsprl.transport-base)
          transport-rubl-locoprl = (if out-vatp_partsprl.transport-rubl = ? then 0 else out-vatp_partsprl.transport-rubl)
          other-base-locoprl     = (if out-vatp_partsprl.other-base     = ? then 0 else out-vatp_partsprl.other-base)
          other-rubl-locoprl     = (if out-vatp_partsprl.other-rubl     = ? then 0 else out-vatp_partsprl.other-rubl)
          vat-pc-locoprl         = (if out-vatp_partsprl.vat-pc         = ? then 0 else out-vatp_partsprl.vat-pc)
          slt-pc-locoprl         = (if out-vatp_partsprl.slt-pc         = ? then 0 else out-vatp_partsprl.slt-pc).
          ASSIGN   slt-base-locoprl    = (if in-vatp-have-vat-sltoprl = no then 0 else (price-base-with-tax-locoprl - ((if road-tax-base-locoprl  = ? then 0 else road-tax-base-locoprl) + (if transport-base-locoprl = ? then 0 else transport-base-locoprl) + (if other-base-locoprl = ? then 0 else other-base-locoprl)))                           * slt-pc-locoprl / (100 + slt-pc-locoprl))                        vat-base-locoprl    = (if in-vatp-have-vat-sltoprl = no then 0 else (price-base-with-tax-locoprl - ((if road-tax-base-locoprl  = ? then 0 else road-tax-base-locoprl) + (if transport-base-locoprl = ? then 0 else transport-base-locoprl) + (if other-base-locoprl = ? then 0 else other-base-locoprl))) * (1 - slt-pc-locoprl / (100 + slt-pc-locoprl)) * vat-pc-locoprl / (100 + vat-pc-locoprl)).
    ASSIGN   slt-rubl-locoprl    = (if in-vatp-have-vat-sltoprl = no then 0 else (price-rubl-with-tax-locoprl - ((if road-tax-rubl-locoprl  = ? then 0 else road-tax-rubl-locoprl) + (if transport-rubl-locoprl = ? then 0 else transport-rubl-locoprl) + (if other-rubl-locoprl = ? then 0 else other-rubl-locoprl)))                           * slt-pc-locoprl / (100 + slt-pc-locoprl))                        vat-rubl-locoprl    = (if in-vatp-have-vat-sltoprl = no then 0 else (price-rubl-with-tax-locoprl - ((if road-tax-rubl-locoprl  = ? then 0 else road-tax-rubl-locoprl) + (if transport-rubl-locoprl = ? then 0 else transport-rubl-locoprl) + (if other-rubl-locoprl = ? then 0 else other-rubl-locoprl))) * (1 - slt-pc-locoprl / (100 + slt-pc-locoprl)) * vat-pc-locoprl / (100 + vat-pc-locoprl)).
  assign
    exch-rate-cli-locoprl = (out-vatp_partsprl.price-rubl - transport-rubl-locoprl - other-rubl-locoprl - road-tax-rubl-locoprl - (if out-vatp_partsprl.vat-type <> 'в т. ч.':U then vat-rubl-locoprl else 0) - (if out-vatp_partsprl.slt-type <> 'в т. ч.':U then slt-rubl-locoprl else 0)) / out-vatp_partsprl.price-cli .
  assign
    slt-cli-locoprl        = slt-rubl-locoprl       / exch-rate-cli-locoprl
    vat-cli-locoprl        = vat-rubl-locoprl       / exch-rate-cli-locoprl
    road-tax-cli-locoprl   = road-tax-rubl-locoprl  / exch-rate-cli-locoprl
    transport-cli-locoprl  = 0
    other-cli-locoprl      = 0
  .
ASSIGN
          price-base-without-tax-locoprl = price-base-with-tax-locoprl - vat-base-locoprl - slt-base-locoprl - ((if road-tax-base-locoprl  = ? then 0 else road-tax-base-locoprl) + (if transport-base-locoprl = ? then 0 else transport-base-locoprl) + (if other-base-locoprl = ? then 0 else other-base-locoprl))
    price-rubl-without-tax-locoprl = price-rubl-with-tax-locoprl - vat-rubl-locoprl - slt-rubl-locoprl - ((if road-tax-rubl-locoprl  = ? then 0 else road-tax-rubl-locoprl) + (if transport-rubl-locoprl = ? then 0 else transport-rubl-locoprl) + (if other-rubl-locoprl = ? then 0 else other-rubl-locoprl))
.
      assign
        varprice-base-consprl = varprice-base-consprl + (price-base-with-tax-locoprl - (if road-tax-base-locoprl = ? then 0 else road-tax-base-locoprl))* out-vatp_partsprl.fact-qnty
        varprice-rubl-consprl = varprice-rubl-consprl + (price-rubl-with-tax-locoprl - (if road-tax-rubl-locoprl = ? then 0 else road-tax-rubl-locoprl))* out-vatp_partsprl.fact-qnty.
      assign
        varis-cons-parts-haveprl = yes
        varcons-qntyprl          = varcons-qntyprl + out-vatp_partsprl.fact-qnty.
    end.
    assign
      varfact-qntyprl = varfact-qntyprl + out-vatp_partsprl.fact-qnty.
  end.
end.
assign
  varprice-base-consprl = varprice-base-consprl / varcons-qntyprl
  varprice-rubl-consprl = varprice-rubl-consprl / varcons-qntyprl.
if varprice-base-consprl = ? then do:
  assign
    varprice-base-consprl = 0.
end.
if varprice-rubl-consprl = ? then do:
  assign
    varprice-rubl-consprl = 0.
end.
assign
    slt-base-saleprl               = (if out-vatp-have-vat-sltprl = no then 0 else varprice-base - vardiscnt-base                - road-tax-base-saleprl) * varSLT-pc / (100 + varSLT-pc)
  vat-base-buyerprl              = (if out-vatp-have-vat-sltprl = no then 0 else varprice-base - vardiscnt-base - (if out-vatp-have-vat-sltprl = no then 0 else varprice-base - vardiscnt-base                - road-tax-base-saleprl) * varSLT-pc / (100 + varSLT-pc) - road-tax-base-saleprl) * varvat-pc / (100 + varvat-pc)
  discnt-base-saleprl            = vardiscnt-base
  price-base-with-tax-saleprl    = (varprice-base - vardiscnt-base)
    slt-rubl-saleprl               = (if out-vatp-have-vat-sltprl = no then 0 else varprice-rubl - vardiscnt-rubl                - road-tax-rubl-saleprl) * varSLT-pc / (100 + varSLT-pc)
  vat-rubl-buyerprl              = (if out-vatp-have-vat-sltprl = no then 0 else varprice-rubl - vardiscnt-rubl - (if out-vatp-have-vat-sltprl = no then 0 else varprice-rubl - vardiscnt-rubl                - road-tax-rubl-saleprl) * varSLT-pc / (100 + varSLT-pc) - road-tax-rubl-saleprl) * varvat-pc / (100 + varvat-pc)
  discnt-rubl-saleprl            = vardiscnt-rubl
  price-rubl-with-tax-saleprl    = (varprice-rubl - vardiscnt-rubl)
  .
if vardoc-type = 'инв':U then do:
  assign
    varfact-qntyprl = vardoc-qnty.
end.
else do:
  assign
    varfact-qntyprl = varfact-qnty.
end.
if varis-cons-parts-haveprl = no then do:
  assign
        vat-base-saleprl               = (if out-vatp-have-vat-sltprl = no then 0 else varprice-base - vardiscnt-base - (if out-vatp-have-vat-sltprl = no then 0 else varprice-base - vardiscnt-base                - road-tax-base-saleprl) * varSLT-pc / (100 + varSLT-pc) - road-tax-base-saleprl) * varvat-pc / (100 + varvat-pc)
        vat-rubl-saleprl               = (if out-vatp-have-vat-sltprl = no then 0 else varprice-rubl - vardiscnt-rubl - (if out-vatp-have-vat-sltprl = no then 0 else varprice-rubl - vardiscnt-rubl                - road-tax-rubl-saleprl) * varSLT-pc / (100 + varSLT-pc) - road-tax-rubl-saleprl) * varvat-pc / (100 + varvat-pc).
end.
else do:
  if vardoc-type = 'инв':U then do:
    assign
            vat-base-saleprl               = (if out-vatp-have-vat-sltprl = no then 0 else (((varprice-base - vardiscnt-base) - (if out-vatp-have-vat-sltprl = no then 0 else varprice-base - vardiscnt-base                - road-tax-base-saleprl) * varSLT-pc / (100 + varSLT-pc) - road-tax-base-saleprl - varprice-base-consprl) * varcons-vat-pc / (100 + varcons-vat-pc) * vardoc-qnty * varcons-qntyprl / varfact-qntyprl + ((varprice-base - vardiscnt-base) - (if out-vatp-have-vat-sltprl = no then 0 else varprice-base - vardiscnt-base                - road-tax-base-saleprl) * varSLT-pc / (100 + varSLT-pc) - road-tax-base-saleprl) * varvat-pc / (100 + varvat-pc) * vardoc-qnty * (varfact-qntyprl - varcons-qntyprl) / varfact-qntyprl) / varfact-qntyprl)
            vat-rubl-saleprl               = (if out-vatp-have-vat-sltprl = no then 0 else (((varprice-rubl - vardiscnt-rubl) - (if out-vatp-have-vat-sltprl = no then 0 else varprice-rubl - vardiscnt-rubl                - road-tax-rubl-saleprl) * varSLT-pc / (100 + varSLT-pc) - road-tax-rubl-saleprl - varprice-rubl-consprl) * varcons-vat-pc / (100 + varcons-vat-pc) * vardoc-qnty * varcons-qntyprl / varfact-qntyprl + ((varprice-rubl - vardiscnt-rubl) - (if out-vatp-have-vat-sltprl = no then 0 else varprice-rubl - vardiscnt-rubl                - road-tax-rubl-saleprl) * varSLT-pc / (100 + varSLT-pc) - road-tax-rubl-saleprl) * varvat-pc / (100 + varvat-pc) * vardoc-qnty * (varfact-qntyprl - varcons-qntyprl) / varfact-qntyprl) / varfact-qntyprl)
     .
  end.
  else do:
    assign
            vat-base-saleprl               = (if out-vatp-have-vat-sltprl = no then 0 else (((varprice-base - vardiscnt-base) - (if out-vatp-have-vat-sltprl = no then 0 else varprice-base - vardiscnt-base                - road-tax-base-saleprl) * varSLT-pc / (100 + varSLT-pc) - road-tax-base-saleprl - varprice-base-consprl) * varcons-vat-pc / (100 + varcons-vat-pc) * varfact-qnty * varcons-qntyprl / varfact-qntyprl + ((varprice-base - vardiscnt-base) - (if out-vatp-have-vat-sltprl = no then 0 else varprice-base - vardiscnt-base                - road-tax-base-saleprl) * varSLT-pc / (100 + varSLT-pc) - varprice-base-consprl) * varvat-pc / (100 + varvat-pc) * varfact-qnty * (varfact-qntyprl - varcons-qntyprl) / varfact-qntyprl) / varfact-qntyprl)
            vat-rubl-saleprl               = (if out-vatp-have-vat-sltprl = no then 0 else (((varprice-rubl - vardiscnt-rubl) - (if out-vatp-have-vat-sltprl = no then 0 else varprice-rubl - vardiscnt-rubl                - road-tax-rubl-saleprl) * varSLT-pc / (100 + varSLT-pc) - road-tax-rubl-saleprl - varprice-rubl-consprl) * varcons-vat-pc / (100 + varcons-vat-pc) * varfact-qnty * varcons-qntyprl / varfact-qntyprl + ((varprice-rubl - vardiscnt-rubl) - (if out-vatp-have-vat-sltprl = no then 0 else varprice-rubl - vardiscnt-rubl                - road-tax-rubl-saleprl) * varSLT-pc / (100 + varSLT-pc) - varprice-rubl-consprl) * varvat-pc / (100 + varvat-pc) * varfact-qnty * (varfact-qntyprl - varcons-qntyprl) / varfact-qntyprl) / varfact-qntyprl)
     .
  end.
end.
assign
price-base-without-tax-saleprl = price-base-with-tax-saleprl - vat-base-saleprl - slt-base-saleprl - road-tax-base-saleprl
price-rubl-without-tax-saleprl = price-rubl-with-tax-saleprl - vat-rubl-saleprl - slt-rubl-saleprl - road-tax-rubl-saleprl.
  end.
end procedure.
PROCEDURE report-execute :
  NO-PRISE = true .
  if var-report-r-b = "rubl"  Then do:
    if  x-base-code <> 0 and ValType = 2  then NO-PRISE = false  .
  end.
  else do:
    if  x-base-code <> 0 and ValType = 1  then NO-PRISE = false  .
  end.
  if  ReportPageHeight = 0 then  ReportPageHeight = 43.
output stream OutStream to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size  value(ReportPageHeight) .
  find first ub.goods where
                        ub.goods.prod-code    = v-x-prod-code
                  AND   ub.goods.prod-type    = v-x-prod-type
                  AND   ub.goods.artic        = v-x-artic no-lock no-error .
  find first b-goods where
                        b-goods.prod-code    = v-x-prod-code
                  AND   b-goods.prod-type    = v-x-prod-type
                  AND   b-goods.artic        = v-x-artic no-lock no-error .
  IF ub.goods.prt-root = Prtroot Then make-one = true .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  b-goods.gds-code
  ,input  ?
  ,output v-bar-code
  )  .
  run display-title in this-procedure .
  display STREAM OutStream  with frame top-Frame .
    FORM HEADER
      string( "Страница " + string( PAGE-NUMBER( OutStream ), ">>>>>9") ) AT 100 format "x(24)" SKIP
    with FRAME BottomFrame2 width 235 PAGE-BOTTOM NO-LABELS NO-BOX .
 VIEW STREAM OutStream FRAME BottomFrame2 .
   ll = 0.
   FOR EACH OBJ-list no-lock :
   ll = ll + 1 .
      x-store-code = obj-list.obj-code.
      x-store-type = obj-list.obj-type.
      Quantity = 0 .
      Coast    = 0 .
      if ll > 1 THEN Page stream OutStream.
      run report-exec1.
  End.
  HIDE STREAM OutStream FRAME ZAPAS .
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
  DisabledOptions = 8 .
  run gbl/prnfilen.w
    (input  ""
    ,input  DisabledOptions
    ,input  string(session :temp-directory) + "rpt" + string( g#report-num )
    ,input 7
    ,output v-user-action
    ,output v-printed
    ) .
  eND PROCEDURE.
PROCEDURE display-line :
   i = i + 1.
   v-ii = v-ii + 1.
IF ( v-ii modulo v-account = 0 )  then DO:
 Assign
    v-kol-spice = (50 - LENGTH(reportname)) / 2
    RecordsString = fill(' ',v-kol-spice) + string(reportname)
    .
 Assign
    v-kol-spice = (50 - LENGTH(ub.goods.gds-name)) / 2
    RecordsString2 = fill(' ',v-kol-spice) + string(ub.goods.gds-name)
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
    DISPLAY stream  OutStream sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8  sym9 sym10
    fact-date  @  F-fact-date
    type-doc   @  f-type-doc
    doc-code   @  f-doc-code
    cli-name   @  f-cli-name
    qnty       @  F-qnty
    qnty-o     @  F-qnty-o
    PriceSALE  @  f-PriceSALE
    SumSALE    @  f-SumSALE
    SumSALE-o when ( PriceDocs = true ) @  f-SumSALE-o
    discnt-sum @  f-discnt-sum
    with FRAME ZAPAS . DOWN stream   OutStream 1 with FRAME ZAPAS.
END PROCEDURE.
PROCEDURE display-line-ext :
define input parameter v-doc-code as character no-undo .
define buffer bf_doc-line for ub.doc-line.
define variable l-qnty as decimal no-undo .
define variable l-pr   as decimal no-undo .
find first bf_doc-line no-lock where bf_doc-line.doc-code = v-doc-code
                  and   ub.goods.prod-code    = bf_doc-line.prod-code
                  AND   ub.goods.prod-type    = bf_doc-line.prod-type
                  AND   ub.goods.artic        = bf_doc-line.artic
                  no-error .
   i = i + 1.
   v-ii = v-ii + 1.
   run local-fchg-qnty in this-procedure (input  recid(bf_doc-line), output l-qnty) no-error.
   l-pr    = if ( SumSALE / l-qnty) <> ? then SumSALE / l-qnty else 0.
IF ( v-ii modulo v-account = 0 )  then DO:
 Assign
    v-kol-spice = (50 - LENGTH(reportname)) / 2
    RecordsString = fill(' ',v-kol-spice) + string(reportname)
    .
 Assign
    v-kol-spice = (50 - LENGTH(ub.goods.gds-name)) / 2
    RecordsString2 = fill(' ',v-kol-spice) + string(ub.goods.gds-name)
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
    DISPLAY stream  OutStream sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8  sym9 sym10
    fact-date  @  F-fact-date
    type-doc   @  f-type-doc
    doc-code   @  f-doc-code
    cli-name   @  f-cli-name
    l-qnty     @  F-qnty
    qnty-o     @  F-qnty-o
    l-pr       @  f-PriceSALE
    SumSALE    @  f-SumSALE
    SumSALE-o when ( PriceDocs = true ) @  f-SumSALE-o
    discnt-sum @  f-discnt-sum
    with FRAME ZAPAS . DOWN stream   OutStream 1 with FRAME ZAPAS.
END PROCEDURE.
PROCEDURE display-line2 :
   i = i + 1.
   v-ii = v-ii + 1.
IF ( v-ii modulo v-account = 0 )  then DO:
 Assign
    v-kol-spice = (50 - LENGTH(reportname)) / 2
    RecordsString = fill(' ',v-kol-spice) + string(reportname)
    .
 Assign
    v-kol-spice = (50 - LENGTH(ub.goods.gds-name)) / 2
    RecordsString2 = fill(' ',v-kol-spice) + string(ub.goods.gds-name)
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
    DISPLAY stream  OutStream sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8  sym9 sym10
    fact-date  @  F-fact-date
    type-doc   @  f-type-doc
    doc-code   @  f-doc-code
    cli-name   @  f-cli-name
    qnty       @  F-qnty
    PriceSALE  @  f-PriceSALE
    SumSALE    @  f-SumSALE
    discnt-sum @  f-discnt-sum
    with FRAME ZAPAS . DOWN stream   OutStream 1 with FRAME ZAPAS.
END PROCEDURE.
PROCEDURE Print-Footer :
  Quantity2 =  rest-qnty .
  Coast2    =  rest-base .
  run U-LINE in this-procedure .
  if x-type-dog <> 2  then do:
    TEMPSTR =  string( "Остаток на конец периода (" + string( enddate, "99/99/9999" ) + ")" )  .
    PUT STREAM OutStream
      SKIP
      SPACE(5)
      TEMPSTR format "x(72)"
      SKIP
      SPACE(32) string( "Количество: " + trim( string( Quantity2, "->>>,>>>,>>9.<<<" ) ) ) format "x(72)"
      SKIP.
      PUT STREAM OutStream
      SPACE(32)
      if PriceDocs = true  then
        string( "Cумма  цен: " +
        trim( string( Coast2, "->>>,>>>,>>>,>>>,>>9.99" ) ) + " " +
        curr-rep )
      else    ""
      format "x(72)"  SKIP
      .
    end.
  END PROCEDURE.
PROCEDURE U-LINE :
UNDERLINE stream OutStream  sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8  sym9 sym10
F-fact-date
f-type-doc
f-doc-code
f-cli-name
F-qnty-o
F-qnty
f-priceSALE
f-SumSALE
f-SumSALE-o
f-discnt-sum
with FRAME ZAPAS .
DOWN stream   OutStream 1 with FRAME ZAPAS.
END PROCEDURE.
PROCEDURE Display-title :
     PUT stream  OutStream  UNFORMATTED  string( v-cntxt-host-name-obj +  " , " + x-store-type  +  " " + ObjName) AT 50 format "X(85)" SKIP(2)
      CAPS(REPORTNAME) + chr(10) +
      ub.goods.artic + " " + ub.goods.gds-name + " " +  ub.goods.PS  +
      (if ub.goods.sort <> "" then  " (" + ub.goods.sort  + "*)"   else " ")
        AT 20 format "X(170)" SKIP
      Trim(str1)  AT 35 format "X(75)" SKIP
      Trim(str3)  AT 35 format "X(75)" SKIP.
      Repeat i = 1 to NUM-ENTRIES(ReportHeader,chr(10)) :
          PUT stream OutStream  Entry(i,ReportHeader,chr(10))  AT 1 format "X(160)" SKIP.
      End.
      i = 0 .
      FIND FIRST ub.clients where x-store-type = ub.clients.obj-type AND
                                x-store-code = ub.clients.obj-code no-lock no-error.
      If available ub.clients then  ObjName    = ub.clients.obj-name.
                           else  ObjName    = "объект не определен" .
     PUT stream  OutStream  UNFORMATTED  "Объект  : " + ObjName FORMAT "X(170)" skip.
       TEMPSTR =  string( "Остаток на начало периода (" + string( startdate, "99/99/9999" ) + ")" )   .
    run make-temp-table-befor in this-procedure .
    Quantity1 = rest-qnty .
    Coast1    = rest-base .
    if x-type-dog <> 2  then do:
    PUT STREAM OutStream
    SKIP
    SPACE(5)
    TEMPSTR format "x(72)"
    SKIP
    SPACE(32) string( "Количество: " + trim( string( Quantity1, "->>>,>>>,>>9.<<<" ) ) ) format "x(72)"
    SKIP
      SPACE(32)
      string( "Cумма  цен: " +
                   trim( string( Coast1, "->>>,>>>,>>>,>>>,>>9.99" ) ) + " " +
                   curr-rep ) format "x(72)"
        SKIP
       .
    end.
end procedure.
PROCEDURE Print-temp-t  :
define input  parameter x-store-code     like ub.clients.obj-code     no-undo.
define input  parameter x-store-type     like ub.clients.obj-type     no-undo.
define INPUT  parameter x-artic          like ub.ot-line.artic        no-undo.
define INPUT  parameter x-prod-code      like ub.ot-line.prod-code    no-undo.
define INPUT  parameter x-prod-type      like ub.ot-line.prod-type    no-undo.
define INPUT  parameter x-Fact-order-1   like ub.ot-line.Fact-order   no-undo.
define INPUT  parameter x-Fact-order-2   like ub.ot-line.Fact-order   no-undo.
define input  parameter x-sum-type       like ub.ot-line.sum-type     no-undo.
define input  parameter x-cat-id         like ub.ot-line.cat-id       no-undo.
define input  parameter xTog-obj         as   log                  no-undo.
define variable first-rec as logical init true no-undo .
define variable t-qnty like Quantity no-undo .
define variable t-cost like Coast    no-undo .
define variable v1 as decimal no-undo .
define variable v2 as decimal no-undo .
 run make-temp-table in this-procedure .
        if ClosedDocs OR PriceDocs then
            do:
                FOR EACH gds-rep WHERE ( ( ClosedDocs AND gds-rep.doc-type <> "пер" ) OR
                                                               ( PriceDocs AND gds-rep.doc-type = "пер" ) ) AND
                                                               gds-rep.fact-num <> 0
                            BY gds-rep.fact-order  by gds-rep.nn:
                    ACCUMULATE gds-rep.doc-code ( COUNT ) .
                    assign
                      type-doc   = gds-rep.doc-type
                      fact-date  = gds-rep.fact-date
                      cli-name   = gds-rep.clients
                      discnt-sum = gds-rep.discnt-tot
                      doc-code   = gds-rep.doc-code
                      qnty       = gds-rep.fact-qnty
                      SumSALE    = gds-rep.netto
                      PriceSALE  = gds-rep.sale-base
                      qnty-o     = gds-rep.rest-qnty
                      SumSALE-o  = gds-rep.rest-base
                      vvv        = gds-rep.vv
                      .
                    if gds-rep.ext-doc-type = 'ap':U then do:
                      run display-line-ext in this-procedure (input  doc-code) .
                    end.
                    else do:
                       run display-line in this-procedure .
                    end.
                    rest-qnty = gds-rep.rest-qnty .
                    rest-base = gds-rep.rest-base .
                END .
                if ( ACCUM COUNT gds-rep.doc-code ) <> 0 then
                    BadResults = FALSE .
            end.
        if OpenedDocs AND
           can-find( first gds-rep where gds-rep.fact-num = 0 ) then
            do:
                DISPLAY stream  OutStream
                "--------"  @  F-fact-date
                string( "Открытые документы !" )   @  f-cli-name
                with FRAME ZAPAS . DOWN stream   OutStream 1 with FRAME ZAPAS .
                FOR EACH gds-rep where gds-rep.fact-num = 0 BY gds-rep.fact-date :
                    ACCUMULATE gds-rep.doc-code ( COUNT ) .
                    assign
                      type-doc   = gds-rep.doc-type
                      fact-date  = gds-rep.fact-date
                      cli-name   = gds-rep.clients
                      discnt-sum = gds-rep.discnt-tot
                      doc-code   = gds-rep.doc-code
                      qnty       = gds-rep.fact-qnty
                      SumSALE    = gds-rep.netto
                      PriceSALE  = gds-rep.sale-base
                      qnty-o     = gds-rep.rest-qnty
                      SumSALE-o  = gds-rep.rest-base
                      .
                    run display-line2 in this-procedure  .
                END .
                if ( ACCUM COUNT gds-rep.doc-code ) <> 0 then
                    BadResults = FALSE .
            end.
END PROCEDURE.
PROCEDURE report-exec1 :
        if xtog-inv then DO:
          For each ub.trn-doc where ub.trn-doc.doc-type = 'инв':U and
            ub.trn-doc.fact-date >= startdate and
            ub.trn-doc.obj-code   = x-store-code and
            ub.trn-doc.obj-type   = x-store-type and
            ub.trn-doc.status_    = 'факт':U
            no-lock,
            first ub.doc-line where
                ub.doc-line.artic      = v-x-artic     and
                ub.doc-line.prod-type  = v-x-prod-type and
                ub.doc-line.prod-code  = v-x-prod-code and
                ub.doc-line.doc-code   = ub.trn-doc.doc-code   no-lock :
                Assign
                   inv-fact-order = ub.trn-doc.fact-order
                   inv-fact-date  = ub.trn-doc.fact-date
                   inv-str        = "Последняя инвентаризация " +  string(trn-doc.fact-date ,"99/99/9999" ) + " документ № " + ub.doc-line.doc-code.
          End.
         End.
Assign
       TOT-SumSALE    = 0
       TOT-qnty       = 0
       TOT-discnt-sum = 0
       .
   FIND FIRST ub.clients where ub.clients.obj-type = x-store-type AND
                            ub.clients.obj-code = x-store-code no-lock no-error .
           If available ub.clients then  ObjName = ub.clients.obj-name .
                                else  ObjName = "объект не определен" .
  FORM with FRAME zapas .
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
form header
  line format "X(197)" at 1 skip
  "Продолжение - на следующей странице" at 30 skip
  with frame bottomframe width 232 page-bottom no-labels no-box .
view stream outstream frame bottomframe .
  run print-temp-t in this-procedure (
      input   x-store-code   ,
      input   x-store-type   ,
      INPUT   v-x-artic      ,
      INPUT   v-x-prod-code  ,
      INPUT   v-x-prod-type  ,
      INPUT   Fact-order-1   ,
      INPUT   Fact-order-2   ,
      input   'crsa':U    ,
      input   '##,##':U ,
      input   YES ) .
  HIDE stream OutStream FRAME BottomFrame2 .
  run print-footer in this-procedure .
END PROCEDURE.
Procedure make-temp-table :
define variable cur-dn as character no-undo .
define variable cur-pr as decimal no-undo .
define variable cur-rt as decimal no-undo .
define variable cur-ex as decimal no-undo .
define variable f-o as decimal no-undo .
define variable price-old like ub.price-list.price-sale no-undo .
define variable t-dec as decimal no-undo .
define variable cost-sum-base as decimal no-undo  .
define variable cost-sum-rubl  as decimal no-undo .
define variable v1 as decimal no-undo .
define variable v2 as decimal no-undo .
define variable v11 as decimal no-undo .
define variable v21 as decimal no-undo .
define variable sum-rest-base as decimal no-undo .
define variable sum-rest-base1 as decimal no-undo .
define variable             v-fact-qnty  as decimal no-undo .
define variable             v-sale-base  as decimal no-undo .
define variable             v-netto      as decimal no-undo .
define variable             v-tot-base   as decimal no-undo .
if ClosedDocs then
    FOR EACH ub.doc-line WHERE ub.doc-line.artic = b-goods.artic
                   AND ub.doc-line.prod-code = b-goods.prod-code
                   AND ub.doc-line.prod-type = b-goods.prod-type
                   AND ub.doc-line.obj-type = x-store-type
                   AND ub.doc-line.obj-code = x-store-code
                   NO-LOCK ,
        EACH ub.trn-doc WHERE ub.trn-doc.doc-code = ub.doc-line.doc-code
                                    AND ub.trn-doc.fact-date >= start-date
                                    AND ub.trn-doc.fact-date <= end-date
                                    AND ub.trn-doc.fact-num <> 0
                        NO-LOCK BY ub.trn-doc.fact-order :
if trn-doc.ext-doc-type = 'ot':U or
   trn-doc.ext-doc-type = ?                 then do:
  assign
   out-vatp-have-vat-slt = yes.
end.
else do:
  find first out-vatp_doc-attr no-lock
    where out-vatp_doc-attr.doc-code  = trn-doc.doc-code
      and out-vatp_doc-attr.attr-code = 'envd':U
      no-error .
  if not available out-vatp_doc-attr then do:
    assign
      out-vatp-have-vat-slt = yes.
  end.
  else do:
     out-vatp-have-vat-slt = no.
  end.
end.
find first out-vatp_goods where out-vatp_goods.artic     = doc-line.artic     and
                                   out-vatp_goods.prod-type = doc-line.prod-type and
                                   out-vatp_goods.prod-code = doc-line.prod-code no-lock.
define variable vss-include-info39 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  doc-line.artic
  ,input  doc-line.prod-type
  ,input  doc-line.prod-code
  ,output varroot-node
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении корневого признака товара" skip
    "Артикул" doc-line.artic doc-line.prod-type doc-line.prod-code skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtat in g#library
  (input  varroot-node
  ,input  'empty-scale=request'
  ,output varempty-scale
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении атрибута признака" skip
    "Артикул" doc-line.artic doc-line.prod-type doc-line.prod-code skip
    "Признак" varroot-node skip
    "Запрашивался атрибут" "empty-scale=request" skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
define variable vss-include-info40 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varoutvprb
  )  .
if varoutvprb = "base":u then do:
  assign
        road-tax-base-sale    =  (if doc-line.road-tax = ? then 0 else doc-line.road-tax * 1)
    excise-base-sale      =  (if doc-line.excise   = ? then 0 else doc-line.excise   * 1)
  .
end.
else do:
  assign
        road-tax-base-sale    =  (if doc-line.road-tax = ? then 0 else doc-line.road-tax / trn-doc.base-rate * trn-doc.base-scale)
    excise-base-sale      =  (if doc-line.excise   = ? then 0 else doc-line.excise   / trn-doc.base-rate * trn-doc.base-scale)
  .
end.
if varoutvprb = "rubl":u then do:
  assign
        road-tax-rubl-sale    = (if doc-line.road-tax = ? then 0 else doc-line.road-tax * 1)
    excise-rubl-sale      = (if doc-line.excise   = ? then 0 else doc-line.excise   * 1) .
end.
else do:
  assign
        road-tax-rubl-sale    = (if doc-line.road-tax = ? then 0 else doc-line.road-tax * trn-doc.base-rate / trn-doc.base-scale)
    excise-rubl-sale      = (if doc-line.excise   = ? then 0 else doc-line.excise   * trn-doc.base-rate / trn-doc.base-scale) .
end.
assign
  varis-cons-parts-have =  no.
assign
  varfact-qnty       = 0
  varcons-qnty       = 0
  varprice-base-cons = 0
  varprice-rubl-cons = 0.
find first out-vatp_doc-line where
           out-vatp_doc-line.doc-code   = trn-doc.doc-code
       and out-vatp_doc-line.artic      = doc-line.artic
       and out-vatp_doc-line.prod-type  = doc-line.prod-type
       and out-vatp_doc-line.prod-code  = doc-line.prod-code no-lock no-error.
if available out-vatp_doc-line           and
  (out-vatp_doc-line.status_ = 'запрос':U or out-vatp_goods.gds-type = 'у':U) then do:
  assign
    varfact-qnty = out-vatp_doc-line.fact-qnty.
end.
else do:
  for each out-vatp_parts where out-vatp_parts.out-code   = trn-doc.doc-code
                               and out-vatp_parts.obj-type   = trn-doc.obj-type
                               and out-vatp_parts.obj-code   = trn-doc.obj-code
                               and out-vatp_parts.artic      = doc-line.artic
                               and out-vatp_parts.prod-type  = doc-line.prod-type
                               and out-vatp_parts.prod-code  = doc-line.prod-code no-lock :
    if out-vatp_parts.purch-code = 2 then do:
assign
  price-rubl-with-tax-loco = out-vatp_parts.price-rubl
  price-base-with-tax-loco = out-vatp_parts.price-base
.
define variable vss-include-info41 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprbo
  )  .
  if out-vatp_parts.out-code = 'free-zone':U     or
     out-vatp_parts.out-code = 'out-zone':U   or
     out-vatp_parts.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-slto = yes.
  end.
  else do:
    find first in-vatp_doc-attro no-lock
      where in-vatp_doc-attro.doc-code  = out-vatp_parts.out-code
        and in-vatp_doc-attro.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attro then do:
      assign
        in-vatp-have-vat-slto = yes.
    end.
    else do:
         in-vatp-have-vat-slto = no.
    end.
  end.
  assign
   price-cli-with-tax-loco = out-vatp_parts.price-cli
   cli-base-rateo          = out-vatp_parts.cli-base-rate.
  ASSIGN   road-tax-base-loco  = (if out-vatp_parts.road-tax-base  = ? then 0 else out-vatp_parts.road-tax-base)
           road-tax-rubl-loco  = (if out-vatp_parts.road-tax-rubl  = ? then 0 else out-vatp_parts.road-tax-rubl).
  ASSIGN  transport-base-loco = (if out-vatp_parts.transport-base = ? then 0 else out-vatp_parts.transport-base)
          transport-rubl-loco = (if out-vatp_parts.transport-rubl = ? then 0 else out-vatp_parts.transport-rubl)
          other-base-loco     = (if out-vatp_parts.other-base     = ? then 0 else out-vatp_parts.other-base)
          other-rubl-loco     = (if out-vatp_parts.other-rubl     = ? then 0 else out-vatp_parts.other-rubl)
          vat-pc-loco         = (if out-vatp_parts.vat-pc         = ? then 0 else out-vatp_parts.vat-pc)
          slt-pc-loco         = (if out-vatp_parts.slt-pc         = ? then 0 else out-vatp_parts.slt-pc).
          ASSIGN   slt-base-loco    = (if in-vatp-have-vat-slto = no then 0 else (price-base-with-tax-loco - ((if road-tax-base-loco  = ? then 0 else road-tax-base-loco) + (if transport-base-loco = ? then 0 else transport-base-loco) + (if other-base-loco = ? then 0 else other-base-loco)))                           * slt-pc-loco / (100 + slt-pc-loco))                        vat-base-loco    = (if in-vatp-have-vat-slto = no then 0 else (price-base-with-tax-loco - ((if road-tax-base-loco  = ? then 0 else road-tax-base-loco) + (if transport-base-loco = ? then 0 else transport-base-loco) + (if other-base-loco = ? then 0 else other-base-loco))) * (1 - slt-pc-loco / (100 + slt-pc-loco)) * vat-pc-loco / (100 + vat-pc-loco)).
    ASSIGN   slt-rubl-loco    = (if in-vatp-have-vat-slto = no then 0 else (price-rubl-with-tax-loco - ((if road-tax-rubl-loco  = ? then 0 else road-tax-rubl-loco) + (if transport-rubl-loco = ? then 0 else transport-rubl-loco) + (if other-rubl-loco = ? then 0 else other-rubl-loco)))                           * slt-pc-loco / (100 + slt-pc-loco))                        vat-rubl-loco    = (if in-vatp-have-vat-slto = no then 0 else (price-rubl-with-tax-loco - ((if road-tax-rubl-loco  = ? then 0 else road-tax-rubl-loco) + (if transport-rubl-loco = ? then 0 else transport-rubl-loco) + (if other-rubl-loco = ? then 0 else other-rubl-loco))) * (1 - slt-pc-loco / (100 + slt-pc-loco)) * vat-pc-loco / (100 + vat-pc-loco)).
  assign
    exch-rate-cli-loco = (out-vatp_parts.price-rubl - transport-rubl-loco - other-rubl-loco - road-tax-rubl-loco - (if out-vatp_parts.vat-type <> 'в т. ч.':U then vat-rubl-loco else 0) - (if out-vatp_parts.slt-type <> 'в т. ч.':U then slt-rubl-loco else 0)) / out-vatp_parts.price-cli .
  assign
    slt-cli-loco        = slt-rubl-loco       / exch-rate-cli-loco
    vat-cli-loco        = vat-rubl-loco       / exch-rate-cli-loco
    road-tax-cli-loco   = road-tax-rubl-loco  / exch-rate-cli-loco
    transport-cli-loco  = 0
    other-cli-loco      = 0
  .
ASSIGN
          price-base-without-tax-loco = price-base-with-tax-loco - vat-base-loco - slt-base-loco - ((if road-tax-base-loco  = ? then 0 else road-tax-base-loco) + (if transport-base-loco = ? then 0 else transport-base-loco) + (if other-base-loco = ? then 0 else other-base-loco))
    price-rubl-without-tax-loco = price-rubl-with-tax-loco - vat-rubl-loco - slt-rubl-loco - ((if road-tax-rubl-loco  = ? then 0 else road-tax-rubl-loco) + (if transport-rubl-loco = ? then 0 else transport-rubl-loco) + (if other-rubl-loco = ? then 0 else other-rubl-loco))
.
      assign
        varprice-base-cons = varprice-base-cons + (price-base-with-tax-loco - (if road-tax-base-loco = ? then 0 else road-tax-base-loco))* out-vatp_parts.fact-qnty
        varprice-rubl-cons = varprice-rubl-cons + (price-rubl-with-tax-loco - (if road-tax-rubl-loco = ? then 0 else road-tax-rubl-loco))* out-vatp_parts.fact-qnty.
      assign
        varis-cons-parts-have = yes
        varcons-qnty          = varcons-qnty + out-vatp_parts.fact-qnty.
    end.
    assign
      varfact-qnty = varfact-qnty + out-vatp_parts.fact-qnty.
  end.
end.
assign
  varprice-base-cons = varprice-base-cons / varcons-qnty
  varprice-rubl-cons = varprice-rubl-cons / varcons-qnty.
if varprice-base-cons = ? then do:
  assign
    varprice-base-cons = 0.
end.
if varprice-rubl-cons = ? then do:
  assign
    varprice-rubl-cons = 0.
end.
assign
  varsum-base-factovp     = 0
  varslt-base-factovp     = 0
  varvat-base-factovp     = 0
  varvatcons-base-factovp = 0
  vardsc-base-factovp     = 0
  varsum-base-docovp      = 0
  varslt-base-docovp      = 0
  varvat-base-docovp      = 0
  varvatcons-base-docovp  = 0
  vardsc-base-docovp      = 0
  varsum-rubl-factovp     = 0
  varslt-rubl-factovp     = 0
  varvat-rubl-factovp     = 0
  varvatcons-rubl-factovp = 0
  vardsc-rubl-factovp     = 0
  varsum-rubl-docovp      = 0
  varslt-rubl-docovp      = 0
  varvat-rubl-docovp      = 0
  varvatcons-rubl-docovp  = 0
  vardsc-rubl-docovp      = 0.
assign
  varis-one-gds-dtl = no.
find first out-vatp_gds-dtl where out-vatp_gds-dtl.doc-code  = trn-doc.doc-code  and
                                     out-vatp_gds-dtl.artic     = doc-line.artic     and
                                     out-vatp_gds-dtl.prod-type = doc-line.prod-type and
                                     out-vatp_gds-dtl.prod-code = doc-line.prod-code no-lock no-error.
if available out-vatp_gds-dtl then do:
  find first buf_out-vatp_gds-dtl where buf_out-vatp_gds-dtl.doc-code  =  trn-doc.doc-code                and
                                           buf_out-vatp_gds-dtl.artic     =  doc-line.artic                   and
                                           buf_out-vatp_gds-dtl.prod-type =  doc-line.prod-type               and
                                           buf_out-vatp_gds-dtl.prod-code =  doc-line.prod-code               and
                                           recid(buf_out-vatp_gds-dtl)    <> recid(out-vatp_gds-dtl) no-lock no-error.
  if not available buf_out-vatp_gds-dtl then do:
    assign
      varis-one-gds-dtl = yes.
  end.
  if varoutvprb = "base":u then do:
    assign
      varcurprice-base = out-vatp_gds-dtl.cur-base
      varcurprice-rubl = out-vatp_gds-dtl.cur-base * ((out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl) / (out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base)).
  end.
  else do:
    assign
      varcurprice-base = out-vatp_gds-dtl.cur-base / ((out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl) / (out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base))
      varcurprice-rubl = out-vatp_gds-dtl.cur-base.
  end.
  if varempty-scale    = yes or
     varis-one-gds-dtl = yes   then do:
    assign
                price-base-with-tax-sale    = (out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base)
        slt-base-sale               = (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc)
        vat-base-buyer              = (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-base-sale) * doc-line.vat-pc / (100 + doc-line.vat-pc)
        discnt-base-sale            = out-vatp_gds-dtl.discnt-base
                price-rubl-with-tax-sale    = (out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl)
        slt-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc)
        vat-rubl-buyer              = (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-rubl-sale) * doc-line.vat-pc / (100 + doc-line.vat-pc)
        discnt-rubl-sale            = out-vatp_gds-dtl.discnt-rubl
        .
    if trn-doc.doc-type = 'инв':U then do:
      ASSIGN
                vat-base-sale               = (if out-vatp-have-vat-slt = no then 0 else (((out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-base-sale - varprice-base-cons) * doc-line.cons-vat-pc / (100 + doc-line.cons-vat-pc) * out-vatp_gds-dtl.doc-qnty * varcons-qnty / varfact-qnty + ((out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-base-sale) * doc-line.vat-pc / (100 + doc-line.vat-pc) * out-vatp_gds-dtl.doc-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
                vat-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else (((out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-rubl-sale - varprice-rubl-cons) * doc-line.cons-vat-pc / (100 + doc-line.cons-vat-pc) * out-vatp_gds-dtl.doc-qnty * varcons-qnty / varfact-qnty + ((out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-rubl-sale) * doc-line.vat-pc / (100 + doc-line.vat-pc) * out-vatp_gds-dtl.doc-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
        .
    end.
    else do:
      ASSIGN
                vat-base-sale               = (if out-vatp-have-vat-slt = no then 0 else (((out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-base-sale - varprice-base-cons) * doc-line.cons-vat-pc / (100 + doc-line.cons-vat-pc) * out-vatp_gds-dtl.fact-qnty * varcons-qnty / varfact-qnty + ((out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-base-sale ) * doc-line.vat-pc / (100 + doc-line.vat-pc) * out-vatp_gds-dtl.fact-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
                vat-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else (((out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-rubl-sale - varprice-rubl-cons) * doc-line.cons-vat-pc / (100 + doc-line.cons-vat-pc) * out-vatp_gds-dtl.fact-qnty * varcons-qnty / varfact-qnty + ((out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-rubl-sale) * doc-line.vat-pc / (100 + doc-line.vat-pc) * out-vatp_gds-dtl.fact-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
        .
    end.
  end.
  else do:
    for each out-vatp_gds-dtl where out-vatp_gds-dtl.doc-code  = trn-doc.doc-code  and
                                       out-vatp_gds-dtl.artic     = doc-line.artic     and
                                       out-vatp_gds-dtl.prod-type = doc-line.prod-type and
                                       out-vatp_gds-dtl.prod-code = doc-line.prod-code no-lock :
      if varoutvprb = "base":u then do:
        assign
          varcurprice-base = out-vatp_gds-dtl.cur-base
          varcurprice-rubl = out-vatp_gds-dtl.cur-base * ((out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl) / (out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base)).
      end.
      else do:
        assign
          varcurprice-base = out-vatp_gds-dtl.cur-base / ((out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl) / (out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base))
          varcurprice-rubl = out-vatp_gds-dtl.cur-base.
      end.
      assign
             varsum-base-factovp = varsum-base-factovp + (out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base)                 * out-vatp_gds-dtl.fact-qnty
       varslt-base-factovp = varslt-base-factovp + (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc)                   * out-vatp_gds-dtl.fact-qnty
       varvat-base-factovp = varvat-base-factovp + (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-base-sale) * doc-line.vat-pc / (100 + doc-line.vat-pc)                   * out-vatp_gds-dtl.fact-qnty
       varvatcons-base-factovp = varvatcons-base-factovp + (((out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-base-sale - varprice-base-cons) * doc-line.cons-vat-pc / (100 + doc-line.cons-vat-pc) * out-vatp_gds-dtl.fact-qnty * varcons-qnty / varfact-qnty + ((out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-base-sale) * doc-line.vat-pc / (100 + doc-line.vat-pc) * out-vatp_gds-dtl.fact-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty)
       vardsc-base-factovp = vardsc-base-factovp + out-vatp_gds-dtl.discnt-base * out-vatp_gds-dtl.fact-qnty
       varsum-base-docovp  = varsum-base-docovp  + (out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base)                 * out-vatp_gds-dtl.doc-qnty
       varslt-base-docovp  = varslt-base-docovp  + (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc)                   * out-vatp_gds-dtl.doc-qnty
       varvat-base-docovp  = varvat-base-docovp  + (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-base-sale) * doc-line.vat-pc / (100 + doc-line.vat-pc)                   * out-vatp_gds-dtl.doc-qnty
       varvatcons-base-docovp  = varvatcons-base-docovp  + (((out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-base-sale - varprice-base-cons) * doc-line.cons-vat-pc / (100 + doc-line.cons-vat-pc) * out-vatp_gds-dtl.doc-qnty * varcons-qnty / varfact-qnty + ((out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-base-sale) * doc-line.vat-pc / (100 + doc-line.vat-pc) * out-vatp_gds-dtl.doc-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty)
       vardsc-base-docovp  = vardsc-base-docovp  + out-vatp_gds-dtl.discnt-base * out-vatp_gds-dtl.doc-qnty
      .
      assign
             varsum-rubl-factovp = varsum-rubl-factovp + (out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl)                 * out-vatp_gds-dtl.fact-qnty
       varslt-rubl-factovp = varslt-rubl-factovp + (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc)                   * out-vatp_gds-dtl.fact-qnty
       varvat-rubl-factovp = varvat-rubl-factovp + (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-rubl-sale) * doc-line.vat-pc / (100 + doc-line.vat-pc)                   * out-vatp_gds-dtl.fact-qnty
       varvatcons-rubl-factovp = varvatcons-rubl-factovp + (((out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-rubl-sale - varprice-rubl-cons) * doc-line.cons-vat-pc / (100 + doc-line.cons-vat-pc) * out-vatp_gds-dtl.fact-qnty * varcons-qnty / varfact-qnty + ((out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-rubl-sale) * doc-line.vat-pc / (100 + doc-line.vat-pc) * out-vatp_gds-dtl.fact-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty)
       vardsc-rubl-factovp = vardsc-rubl-factovp + out-vatp_gds-dtl.discnt-rubl * out-vatp_gds-dtl.fact-qnty
       varsum-rubl-docovp  = varsum-rubl-docovp  + (out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl)                 * out-vatp_gds-dtl.doc-qnty
       varslt-rubl-docovp  = varslt-rubl-docovp  + (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc)                   * out-vatp_gds-dtl.doc-qnty
       varvat-rubl-docovp  = varvat-rubl-docovp  + (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-rubl-sale) * doc-line.vat-pc / (100 + doc-line.vat-pc)                   * out-vatp_gds-dtl.doc-qnty
       varvatcons-rubl-docovp  = varvatcons-rubl-docovp  + (((out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-rubl-sale - varprice-rubl-cons) * doc-line.cons-vat-pc / (100 + doc-line.cons-vat-pc) * out-vatp_gds-dtl.doc-qnty * varcons-qnty / varfact-qnty + ((out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-rubl-sale) * doc-line.vat-pc / (100 + doc-line.vat-pc) * out-vatp_gds-dtl.doc-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty)
       vardsc-rubl-docovp  = vardsc-rubl-docovp  + out-vatp_gds-dtl.discnt-rubl * out-vatp_gds-dtl.doc-qnty   .
    end.
    if trn-doc.doc-type = 'инв':U then do:
      ASSIGN
                price-base-with-tax-sale    = varsum-base-docovp / varfact-qnty
        slt-base-sale               = varslt-base-docovp / varfact-qnty
        vat-base-buyer              = varvat-base-docovp / varfact-qnty
        discnt-base-sale            = vardsc-base-docovp / varfact-qnty
        vat-base-sale               = varvatcons-base-docovp / varfact-qnty
                price-rubl-with-tax-sale    = varsum-rubl-docovp / varfact-qnty
        slt-rubl-sale               = varslt-rubl-docovp / varfact-qnty
        vat-rubl-buyer              = varvat-rubl-docovp / varfact-qnty
        discnt-rubl-sale            = vardsc-rubl-docovp / varfact-qnty
        vat-rubl-sale               = varvatcons-rubl-docovp / varfact-qnty.
    end.
    else do:
      ASSIGN
                price-base-with-tax-sale    = varsum-base-factovp / varfact-qnty
        slt-base-sale               = varslt-base-factovp / varfact-qnty
        vat-base-buyer              = varvat-base-factovp / varfact-qnty
        discnt-base-sale            = vardsc-base-factovp / varfact-qnty
        vat-base-sale               = varvatcons-base-factovp / varfact-qnty
                price-rubl-with-tax-sale    = varsum-rubl-factovp / varfact-qnty
        slt-rubl-sale               = varslt-rubl-factovp / varfact-qnty
        vat-rubl-buyer              = varvat-rubl-factovp / varfact-qnty
        discnt-rubl-sale            = vardsc-rubl-factovp / varfact-qnty
        vat-rubl-sale               = varvatcons-rubl-factovp / varfact-qnty.
    end.
  end.
end.
assign
  price-base-without-tax-sale = price-base-with-tax-sale - vat-base-sale - slt-base-sale - road-tax-base-sale
  price-rubl-without-tax-sale = price-rubl-with-tax-sale - vat-rubl-sale - slt-rubl-sale - road-tax-rubl-sale.
assign
  price-rubl-with-tax-loc = doc-line.price-rubl
  price-base-with-tax-loc = doc-line.price-base
.
define variable vss-include-info42 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
   find first in-vatp_doc-attr no-lock
    where in-vatp_doc-attr.doc-code  = trn-doc.doc-code
      and in-vatp_doc-attr.attr-code = 'envd':U
    no-error .
    if available in-vatp_doc-attr
       then do:
       assign
         in-vatp-have-vat-slt = no.
   end.
   else do:
     assign
       in-vatp-have-vat-slt = yes.
   end.
   find first in-vatp-goods where in-vatp-goods.artic     = doc-line.artic     and
                                     in-vatp-goods.prod-type = doc-line.prod-type and
                                     in-vatp-goods.prod-code = doc-line.prod-code no-lock.
   if (not trn-doc.internal and
           trn-doc.doc-type = 'при':U) or
      in-vatp-goods.gds-type = 'у':U then do:
      if varinvprb = "base":u then do:
        assign
          road-tax-base-loc = doc-line.road-tax
          road-tax-rubl-loc = doc-line.road-tax * trn-doc.base-rate / trn-doc.base-scale.
      end.
      else do:
        ASSIGN
          road-tax-rubl-loc = doc-line.road-tax
          road-tax-base-loc = doc-line.road-tax / trn-doc.base-rate * trn-doc.base-scale.
      end.
      if road-tax-base-loc = ? then road-tax-base-loc = 0.
      if road-tax-rubl-loc = ? then road-tax-rubl-loc = 0.
      assign
        road-tax-cli-loc = ?.
      ASSIGN
        transport-base-loc = (if doc-line.transport-base = ? then 0 else doc-line.transport-base)
        transport-rubl-loc = (if doc-line.transport-rubl = ? then 0 else doc-line.transport-rubl)
        transport-cli-loc  = 0
        other-base-loc     = (if doc-line.other-base     = ? then 0 else doc-line.other-base)
        other-rubl-loc     = (if doc-line.other-rubl     = ? then 0 else doc-line.other-rubl)
        other-cli-loc      = 0
        vat-pc-loc         = (if doc-line.vat-pc         = ? then 0 else doc-line.vat-pc)
        slt-pc-loc         = (if doc-line.slt-pc         = ? then 0 else doc-line.slt-pc).
                              ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
            ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
      assign
        vat-cli-loc            = ?
        slt-cli-loc            = ?
        price-cli-with-tax-loc = ?.
   end.
   else do:
                                                for each in-vatp-parts where in-vatp-parts.out-code  = doc-line.doc-code  and
                                      in-vatp-parts.obj-type  = doc-line.obj-type  and
                                      in-vatp-parts.obj-code  = doc-line.obj-code  and
                                      in-vatp-parts.artic     = doc-line.artic     and
                                      in-vatp-parts.prod-type = doc-line.prod-type and
                                      in-vatp-parts.prod-code = doc-line.prod-code
                         use-index out-code no-lock:
          accumulate  in-vatp-parts.road-tax-base  * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.road-tax-rubl  * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.transport-base * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.transport-rubl * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.other-base     * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.other-rubl     * in-vatp-parts.fact-qnty (total)
                                                                                                              (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                      / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  / (100 + in-vatp-parts.vat-pc))  (total)
                                            (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                      / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  / (100 + in-vatp-parts.vat-pc))  (total)
                      .
      end.
      ASSIGN
        road-tax-base-loc   = if doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.road-tax-base  * in-vatp-parts.fact-qnty) / doc-line.fact-qnty  else 0
        road-tax-rubl-loc   = if doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.road-tax-rubl  * in-vatp-parts.fact-qnty) / doc-line.fact-qnty  else 0
        transport-base-loc  = if doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.transport-base * in-vatp-parts.fact-qnty) / doc-line.fact-qnty  else 0
        transport-rubl-loc  = if doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.transport-rubl * in-vatp-parts.fact-qnty) / doc-line.fact-qnty  else 0
        other-base-loc      = if doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.other-base     * in-vatp-parts.fact-qnty) / doc-line.fact-qnty  else 0
        other-rubl-loc      = if doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.other-rubl     * in-vatp-parts.fact-qnty) / doc-line.fact-qnty  else 0
                                        vat-base-loc        = if doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / doc-line.fact-qnty   else 0
        slt-base-loc        = if doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / doc-line.fact-qnty   else 0
                vat-rubl-loc        = if doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / doc-line.fact-qnty   else 0
        slt-rubl-loc        = if doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / doc-line.fact-qnty   else 0
        vat-pc-loc          = (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  / (100 + in-vatp-parts.vat-pc)))
        slt-pc-loc          = (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                      / (100 + in-vatp-parts.slt-pc))).
      if road-tax-base-loc  = ? then road-tax-base-loc  = 0.
      if road-tax-rubl-loc  = ? then road-tax-rubl-loc  = 0.
      if transport-base-loc = ? then transport-base-loc = 0.
      if transport-rubl-loc = ? then transport-rubl-loc = 0.
      if other-base-loc     = ? then other-base-loc     = 0.
      if other-rubl-loc     = ? then other-rubl-loc     = 0.
      assign
        transport-cli-loc      = 0
        other-cli-loc          = 0
        road-tax-cli-loc       = ?
        vat-cli-loc            = ?
        slt-cli-loc            = ?
        price-cli-with-tax-loc = ?.
   end.
ASSIGN
          price-base-without-tax-loc = price-base-with-tax-loc - vat-base-loc - slt-base-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))
    price-rubl-without-tax-loc = price-rubl-with-tax-loc - vat-rubl-loc - slt-rubl-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))
.
        if paytype = 2 then
        run r-cost in this-procedure ( input ub.doc-line.doc-code      ,input ub.doc-line.artic ,input ub.doc-line.prod-type
              ,input ub.doc-line.prod-code      ,output t-dec      ,output t-dec      ,output t-dec
              ,output cost-sum-base      ,output cost-sum-rubl      ,output t-dec      ,output t-dec      ,output t-dec
              ,output t-dec      ,output t-dec      ,output t-dec      ,output t-dec      ,output t-dec      ,output t-dec
              ,output t-dec      ,output t-dec      ,output t-dec ) no-error .
        CREATE gds-rep.
        assign
            gds-rep.ii        = 0
            gds-rep.doc-code  = ub.trn-doc.doc-code
            gds-rep.doc-num   = ub.trn-doc.doc-code
            gds-rep.doc-type  = ub.trn-doc.doc-type
            gds-rep.ext-doc-type = ub.trn-doc.ext-doc-type
            gds-rep.fact-num  = ub.trn-doc.fact-num
            gds-rep.fact-order = ub.trn-doc.fact-order
            gds-rep.fact-date = ub.trn-doc.fact-date
            gds-rep.fact-qnty = ( if can-do('рас,спи':U, ub.trn-doc.doc-type)
                                             then ( - ub.doc-line.fact-qnty )
                                             else ub.doc-line.fact-qnty ) .
            case ub.trn-doc.ext-doc-type :
             when 'pc':U then do:
                 gds-rep.clients   = "Смена типа приобретения" .
             end.
             when 'ap':U then do:
                 gds-rep.clients   = "Коррекция учетной цены"   .
             end.
             OTHERWISE do:
                gds-rep.clients   = ub.trn-doc.cli-name .
             end.
            end case.
            If PayType = 2 then do:
                Assign
                    gds-rep.sale-base  =( if tPrintRubl then cost-sum-rubl else cost-sum-base ) / gds-rep.fact-qnty
                    gds-rep.discnt-tot = 0 .
            end.
            Else do:
                if var-report-r-b = "rubl" then
                    Assign
                        gds-rep.sale-base  = price-rubl-with-tax-sale + ( discnt-rubl-sale  )
                        gds-rep.discnt-tot = discnt-rubl-sale *  abs(gds-rep.fact-qnty)  .
                else
                    Assign
                        gds-rep.sale-base  = price-base-with-tax-sale + ( discnt-base-sale  )
                        gds-rep.discnt-tot = discnt-base-sale *  abs(gds-rep.fact-qnty)  .
            end.
            if gds-rep.sale-base = ? then
                gds-rep.sale-base = 0 .
            if gds-rep.discnt-tot = ? then
                gds-rep.discnt-tot = 0 .
            If PayType = 2 then
                gds-rep.tot-base = ( if tPrintRubl then cost-sum-rubl else cost-sum-base ).
              Else do:
                 if var-report-r-b  = "rubl" then gds-rep.tot-base = gds-rep.fact-qnty * price-rubl-with-tax-sale.
                                             else gds-rep.tot-base = gds-rep.fact-qnty * price-base-with-tax-sale.
              end.
            if gds-rep.tot-base = ? then
               gds-rep.tot-base = 0 .
        if  ub.trn-doc.doc-type = 'инв':U  Then do:
                assign
                    rest-qnty = rest-qnty + gds-rep.fact-qnty
                    rest-base = rest-base + gds-rep.tot-base.
            end.
         Else do:
                assign
                    rest-qnty = rest-qnty + gds-rep.fact-qnty
                    rest-base = rest-base + ( gds-rep.fact-qnty * gds-rep.sale-base ) .
         end.
         assign
            gds-rep.rest-qnty = rest-qnty
            gds-rep.rest-base = rest-base
            gds-rep.netto = gds-rep.tot-base  .
            v-total-tot-ov = 0 .
        if gds-rep.netto = ? then
            gds-rep.netto = 0 .
            for each gds-dtl-ch where gds-dtl-ch.doc-code  = ub.doc-line.doc-code  and
                                      gds-dtl-ch.artic     = ub.doc-line.artic     and
                                      gds-dtl-ch.prod-type = ub.doc-line.prod-type and
                                      gds-dtl-ch.prod-code = ub.doc-line.prod-code no-lock :
                assign
                      v-total-tot-ov  = v-total-tot-ov
                                      + (gds-dtl-ch.cur-base -
                                      ( if var-report-r-b  = "rubl" then gds-dtl-ch.price-rubl
                                                                  else gds-dtl-ch.price-base )
                                      ) * gds-dtl-ch.fact-qnty.
            end.
        if ( v-total-tot-ov  <> 0  and  PayType <> 2 ) then
            do:
                CREATE gds-rep.
                assign
                    gds-rep.ii = 1
                    gds-rep.doc-code = "------>"
                    gds-rep.doc-type = 'а'
                    gds-rep.fact-num = ub.trn-doc.fact-num
                    gds-rep.ext-doc-type = ub.trn-doc.ext-doc-type
                    gds-rep.fact-order = ub.trn-doc.fact-order
                    gds-rep.clients  = "переоценка оборотов"
                    gds-rep.fact-date = ub.trn-doc.fact-date
                    gds-rep.fact-qnty = abs( ub.doc-line.fact-qnty ) .
               if can-do('рас,спи':U,trn-doc.doc-type) then
                    assign
                        gds-rep.sale-base = ( v-total-tot-ov ) / ( - ub.doc-line.fact-qnty )
                        .
                else
                    assign
                        gds-rep.sale-base = ( v-total-tot-ov ) / ub.doc-line.fact-qnty
                        .
                if gds-rep.sale-base = ? then
                    gds-rep.sale-base = 0 .
                rest-base = rest-base + ub.doc-line.fact-qnty * gds-rep.sale-base.
                assign
                    gds-rep.discnt-tot = 0
                    gds-rep.tot-base = gds-rep.fact-qnty * gds-rep.sale-base
                    gds-rep.rest-qnty = rest-qnty
                    gds-rep.rest-base = rest-base
                    gds-rep.netto = ub.doc-line.fact-qnty * gds-rep.sale-base
                .
            end.
            run price-prt in this-procedure ( input (gds-rep.fact-order) , output v1, output v2) .
            gds-rep.vv = v2.
            v-ii = v-ii  + 1 .
IF ( v-ii modulo v-account = 0 )  then DO:
 Assign
    v-kol-spice = (50 - LENGTH(reportname)) / 2
    RecordsString = fill(' ',v-kol-spice) + string(reportname)
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
    END.
if PayType <> 2 Then  DO:
if PriceDocs then
    FOR EACH p-price-list WHERE
                   p-price-list.obj-type  = x-store-type
               AND p-price-list.obj-code  = x-store-code
               AND p-price-list.artic     = b-goods.artic
               AND p-price-list.prod-type = b-goods.prod-type
               AND p-price-list.prod-code = b-goods.prod-code
               NO-LOCK,
        EACH p-price-doc WHERE p-price-doc.doc-num = p-price-list.doc-num
                                    AND p-price-doc.fact-date >= start-date
                                    AND p-price-doc.fact-date <= end-date
                                    AND p-price-doc.fact-num <> 0
                        NO-LOCK break BY p-price-doc.fact-order by p-price-list.doc-num by p-price-list.main-price desc :
       f-o1  = p-price-doc.fact-order  .
       if first-of(p-price-list.doc-num) then DO:
          Assign
                v-fact-qnty  = 0
                v-sale-base  = 0
                v-netto      = 0
                v-tot-base   = 0
                v-p = true
                .
            f-o = p-price-doc.fact-order .
define variable vss-include-info43 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  p-price-list.obj-type
  ,input  p-price-list.obj-code
  ,input  p-price-list.b-code
  ,input  0
  ,input  f-o
  ,output cur-dn
  ,output cur-pr
  ,output cur-rt
  ,output cur-ex
  )  .
            if cur-pr = ? then cur-pr = 0 .
            price-old = cur-pr .
          end.
          if p-price-list.doc-qnty <> ? then do:
            Assign
                v-fact-qnty  = v-fact-qnty + p-price-list.doc-qnty
                v-sale-base  = v-sale-base + (p-price-list.price-sale - price-old )
                v-netto      = v-netto     + (p-price-list.doc-qnty * (p-price-list.price-sale - price-old ))
                v-tot-base   = v-tot-base  + (p-price-list.doc-qnty * (p-price-list.price-sale - price-old ))
                .
                if main-price = false then v-p = false .
                If make-one = false  then do:
                CREATE gds-rep.
                assign
                    gds-rep.ii  = ii
                    gds-rep.doc-code  = p-price-list.doc-num
                    gds-rep.fact-date = p-price-doc.fact-date
                    gds-rep.doc-type  = "пер"
                    gds-rep.fact-num  = p-price-doc.fact-num
                    gds-rep.fact-order  = f-o1
                    gds-rep.clients   = 'переоценка':U   +
                    (if p-price-list.main-price = false then
                    " " + string(p-price-list.b-code) else " " )
                    gds-rep.fact-qnty = p-price-list.doc-qnty
                    gds-rep.sale-base = p-price-list.price-sale - price-old
                    gds-rep.discnt-tot = 0
                    gds-rep.netto      = gds-rep.fact-qnty  * gds-rep.sale-base
                    gds-rep.tot-base   = gds-rep.fact-qnty  * gds-rep.sale-base
                    ii = II + 1
                    .
                  end.
          end.
          if last-of(p-price-list.doc-num) then DO:
            If make-one then do:
            CREATE gds-rep.
            assign
                gds-rep.ii  = ii
                gds-rep.doc-code  = p-price-list.doc-num
                gds-rep.fact-date = p-price-doc.fact-date
                gds-rep.doc-type  = "пер"
                gds-rep.fact-num  = p-price-doc.fact-num
                gds-rep.fact-order  = f-o1
                gds-rep.clients   = 'переоценка':U
                gds-rep.fact-qnty = v-fact-qnty
                gds-rep.sale-base = If (v-netto / v-fact-qnty ) <> ? then (v-netto / v-fact-qnty ) else 0
                gds-rep.discnt-tot = 0
                gds-rep.netto      = v-netto
                gds-rep.tot-base   = v-tot-base
                ii = II + 1
                .
             end.
             else do:
                  IF ub.goods.prt-root <> Prtroot Then DO:
                   run price-prt in this-procedure ( input (f-o ) , output v1, output v2) .
                   CREATE gds-rep.
                   assign
                    gds-rep.ii  = ii
                    gds-rep.doc-code = "----->>"
                    gds-rep.doc-type = 'п'
                    gds-rep.fact-num = p-price-doc.fact-num
                    gds-rep.fact-order = f-o1
                    gds-rep.clients  = "переоценка признаков"
                    gds-rep.fact-date = p-price-doc.fact-date
                    gds-rep.fact-qnty  = 0
                    gds-rep.sale-base  = 0
                    gds-rep.discnt-tot = 0
                    gds-rep.tot-base = 0
                    gds-rep.netto = v-netto
                    ii = II + 1
                  .
                  end.
             end.
IF ( v-ii modulo v-account = 0 )  then DO:
 Assign
    v-kol-spice = (50 - LENGTH(reportname)) / 2
    RecordsString = fill(' ',v-kol-spice) + string(reportname)
    .
 Assign
    v-kol-spice = (50 - LENGTH('Переоценки')) / 2
    RecordsString2 = fill(' ',v-kol-spice) + string('Переоценки')
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
          end.
END.
for each gds-rep :
    run price-prt in this-procedure ( input (gds-rep.fact-order) , output v1, output v2) .
    gds-rep.vv = v2 .
end.
Assign
    rest-base = rest-base1
    rest-qnty = rest-qnty1.
 FOR  EACH buf-gds-rep-3 where buf-gds-rep-3.fact-num <> 0
                             BY buf-gds-rep-3.fact-order
                             by buf-gds-rep-3.ii :
    if buf-gds-rep-3.doc-type  = 'п' then do:
             assign
              buf-gds-rep-3.rest-base = buf-gds-rep-3.vv
              buf-gds-rep-3.netto = buf-gds-rep-3.vv - rest-base
            .
          if buf-gds-rep-3.netto = 0 then do:
             delete buf-gds-rep-3 .
             next.
             end.
    end.
    if buf-gds-rep-3.doc-type  = "пер"
      then do :
            If make-one then do:
                    run price-prt in this-procedure ( input buf-gds-rep-3.fact-order , output v1, output v2) .
                    assign  buf-gds-rep-3.rest-qnty = v1
                            buf-gds-rep-3.rest-base = buf-gds-rep-3.vv .
            end.
            else do:
              IF ub.goods.prt-root <> Prtroot Then DO:
                    assign  buf-gds-rep-3.rest-qnty = rest-qnty
                            buf-gds-rep-3.rest-base = rest-base + buf-gds-rep-3.netto .
              end.
            end.
      end.
      else do :
          assign
                buf-gds-rep-3.rest-qnty = rest-qnty + buf-gds-rep-3.fact-qnty
                buf-gds-rep-3.rest-base = rest-base + buf-gds-rep-3.netto - buf-gds-rep-3.discnt-tot .
                if  buf-gds-rep-3.rest-base <> buf-gds-rep-3.rest-qnty * buf-gds-rep-3.sale-base  then do:
                    if buf-gds-rep-3.doc-type  = 'возврат':U then
                       buf-gds-rep-3.rest-base = buf-gds-rep-3.rest-qnty * buf-gds-rep-3.sale-base .
                 end.
      end.
   if buf-gds-rep-3.doc-type = 'а' then Assign
                                buf-gds-rep-3.rest-qnty = rest-qnty
                                buf-gds-rep-3.rest-base = rest-base + buf-gds-rep-3.netto .
    nn = nn + 1.
    buf-gds-rep-3.nn = nn.
    rest-base = buf-gds-rep-3.rest-base.
    rest-qnty = buf-gds-rep-3.rest-qnty.
END .
end.
if OpenedDocs then do:
    FOR EACH ub.doc-line WHERE ub.doc-line.artic = b-goods.artic
                   AND ub.doc-line.prod-code = b-goods.prod-code
                   AND ub.doc-line.prod-type = b-goods.prod-type
                   AND ub.doc-line.obj-type = x-store-type
                   AND ub.doc-line.obj-code = x-store-code
                   NO-LOCK ,
        EACH ub.trn-doc WHERE ub.trn-doc.doc-code = ub.doc-line.doc-code
                                    AND ub.trn-doc.doc-date >= start-date
                                    AND ub.trn-doc.doc-date <= end-date
                                    AND ub.trn-doc.fact-num = 0
                        NO-LOCK BY ub.trn-doc.doc-date :
if trn-doc.ext-doc-type = 'ot':U or
   trn-doc.ext-doc-type = ?                 then do:
  assign
   out-vatp-have-vat-slt = yes.
end.
else do:
  find first out-vatp_doc-attr no-lock
    where out-vatp_doc-attr.doc-code  = trn-doc.doc-code
      and out-vatp_doc-attr.attr-code = 'envd':U
      no-error .
  if not available out-vatp_doc-attr then do:
    assign
      out-vatp-have-vat-slt = yes.
  end.
  else do:
     out-vatp-have-vat-slt = no.
  end.
end.
find first out-vatp_goods where out-vatp_goods.artic     = doc-line.artic     and
                                   out-vatp_goods.prod-type = doc-line.prod-type and
                                   out-vatp_goods.prod-code = doc-line.prod-code no-lock.
define variable vss-include-info44 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  doc-line.artic
  ,input  doc-line.prod-type
  ,input  doc-line.prod-code
  ,output varroot-node
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении корневого признака товара" skip
    "Артикул" doc-line.artic doc-line.prod-type doc-line.prod-code skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtat in g#library
  (input  varroot-node
  ,input  'empty-scale=request'
  ,output varempty-scale
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении атрибута признака" skip
    "Артикул" doc-line.artic doc-line.prod-type doc-line.prod-code skip
    "Признак" varroot-node skip
    "Запрашивался атрибут" "empty-scale=request" skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
define variable vss-include-info45 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varoutvprb
  )  .
if varoutvprb = "base":u then do:
  assign
        road-tax-base-sale    =  (if doc-line.road-tax = ? then 0 else doc-line.road-tax * 1)
    excise-base-sale      =  (if doc-line.excise   = ? then 0 else doc-line.excise   * 1)
  .
end.
else do:
  assign
        road-tax-base-sale    =  (if doc-line.road-tax = ? then 0 else doc-line.road-tax / trn-doc.base-rate * trn-doc.base-scale)
    excise-base-sale      =  (if doc-line.excise   = ? then 0 else doc-line.excise   / trn-doc.base-rate * trn-doc.base-scale)
  .
end.
if varoutvprb = "rubl":u then do:
  assign
        road-tax-rubl-sale    = (if doc-line.road-tax = ? then 0 else doc-line.road-tax * 1)
    excise-rubl-sale      = (if doc-line.excise   = ? then 0 else doc-line.excise   * 1) .
end.
else do:
  assign
        road-tax-rubl-sale    = (if doc-line.road-tax = ? then 0 else doc-line.road-tax * trn-doc.base-rate / trn-doc.base-scale)
    excise-rubl-sale      = (if doc-line.excise   = ? then 0 else doc-line.excise   * trn-doc.base-rate / trn-doc.base-scale) .
end.
assign
  varis-cons-parts-have =  no.
assign
  varfact-qnty       = 0
  varcons-qnty       = 0
  varprice-base-cons = 0
  varprice-rubl-cons = 0.
find first out-vatp_doc-line where
           out-vatp_doc-line.doc-code   = trn-doc.doc-code
       and out-vatp_doc-line.artic      = doc-line.artic
       and out-vatp_doc-line.prod-type  = doc-line.prod-type
       and out-vatp_doc-line.prod-code  = doc-line.prod-code no-lock no-error.
if available out-vatp_doc-line           and
  (out-vatp_doc-line.status_ = 'запрос':U or out-vatp_goods.gds-type = 'у':U) then do:
  assign
    varfact-qnty = out-vatp_doc-line.fact-qnty.
end.
else do:
  for each out-vatp_parts where out-vatp_parts.out-code   = trn-doc.doc-code
                               and out-vatp_parts.obj-type   = trn-doc.obj-type
                               and out-vatp_parts.obj-code   = trn-doc.obj-code
                               and out-vatp_parts.artic      = doc-line.artic
                               and out-vatp_parts.prod-type  = doc-line.prod-type
                               and out-vatp_parts.prod-code  = doc-line.prod-code no-lock :
    if out-vatp_parts.purch-code = 2 then do:
assign
  price-rubl-with-tax-loco = out-vatp_parts.price-rubl
  price-base-with-tax-loco = out-vatp_parts.price-base
.
define variable vss-include-info46 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprbo
  )  .
  if out-vatp_parts.out-code = 'free-zone':U     or
     out-vatp_parts.out-code = 'out-zone':U   or
     out-vatp_parts.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-slto = yes.
  end.
  else do:
    find first in-vatp_doc-attro no-lock
      where in-vatp_doc-attro.doc-code  = out-vatp_parts.out-code
        and in-vatp_doc-attro.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attro then do:
      assign
        in-vatp-have-vat-slto = yes.
    end.
    else do:
         in-vatp-have-vat-slto = no.
    end.
  end.
  assign
   price-cli-with-tax-loco = out-vatp_parts.price-cli
   cli-base-rateo          = out-vatp_parts.cli-base-rate.
  ASSIGN   road-tax-base-loco  = (if out-vatp_parts.road-tax-base  = ? then 0 else out-vatp_parts.road-tax-base)
           road-tax-rubl-loco  = (if out-vatp_parts.road-tax-rubl  = ? then 0 else out-vatp_parts.road-tax-rubl).
  ASSIGN  transport-base-loco = (if out-vatp_parts.transport-base = ? then 0 else out-vatp_parts.transport-base)
          transport-rubl-loco = (if out-vatp_parts.transport-rubl = ? then 0 else out-vatp_parts.transport-rubl)
          other-base-loco     = (if out-vatp_parts.other-base     = ? then 0 else out-vatp_parts.other-base)
          other-rubl-loco     = (if out-vatp_parts.other-rubl     = ? then 0 else out-vatp_parts.other-rubl)
          vat-pc-loco         = (if out-vatp_parts.vat-pc         = ? then 0 else out-vatp_parts.vat-pc)
          slt-pc-loco         = (if out-vatp_parts.slt-pc         = ? then 0 else out-vatp_parts.slt-pc).
          ASSIGN   slt-base-loco    = (if in-vatp-have-vat-slto = no then 0 else (price-base-with-tax-loco - ((if road-tax-base-loco  = ? then 0 else road-tax-base-loco) + (if transport-base-loco = ? then 0 else transport-base-loco) + (if other-base-loco = ? then 0 else other-base-loco)))                           * slt-pc-loco / (100 + slt-pc-loco))                        vat-base-loco    = (if in-vatp-have-vat-slto = no then 0 else (price-base-with-tax-loco - ((if road-tax-base-loco  = ? then 0 else road-tax-base-loco) + (if transport-base-loco = ? then 0 else transport-base-loco) + (if other-base-loco = ? then 0 else other-base-loco))) * (1 - slt-pc-loco / (100 + slt-pc-loco)) * vat-pc-loco / (100 + vat-pc-loco)).
    ASSIGN   slt-rubl-loco    = (if in-vatp-have-vat-slto = no then 0 else (price-rubl-with-tax-loco - ((if road-tax-rubl-loco  = ? then 0 else road-tax-rubl-loco) + (if transport-rubl-loco = ? then 0 else transport-rubl-loco) + (if other-rubl-loco = ? then 0 else other-rubl-loco)))                           * slt-pc-loco / (100 + slt-pc-loco))                        vat-rubl-loco    = (if in-vatp-have-vat-slto = no then 0 else (price-rubl-with-tax-loco - ((if road-tax-rubl-loco  = ? then 0 else road-tax-rubl-loco) + (if transport-rubl-loco = ? then 0 else transport-rubl-loco) + (if other-rubl-loco = ? then 0 else other-rubl-loco))) * (1 - slt-pc-loco / (100 + slt-pc-loco)) * vat-pc-loco / (100 + vat-pc-loco)).
  assign
    exch-rate-cli-loco = (out-vatp_parts.price-rubl - transport-rubl-loco - other-rubl-loco - road-tax-rubl-loco - (if out-vatp_parts.vat-type <> 'в т. ч.':U then vat-rubl-loco else 0) - (if out-vatp_parts.slt-type <> 'в т. ч.':U then slt-rubl-loco else 0)) / out-vatp_parts.price-cli .
  assign
    slt-cli-loco        = slt-rubl-loco       / exch-rate-cli-loco
    vat-cli-loco        = vat-rubl-loco       / exch-rate-cli-loco
    road-tax-cli-loco   = road-tax-rubl-loco  / exch-rate-cli-loco
    transport-cli-loco  = 0
    other-cli-loco      = 0
  .
ASSIGN
          price-base-without-tax-loco = price-base-with-tax-loco - vat-base-loco - slt-base-loco - ((if road-tax-base-loco  = ? then 0 else road-tax-base-loco) + (if transport-base-loco = ? then 0 else transport-base-loco) + (if other-base-loco = ? then 0 else other-base-loco))
    price-rubl-without-tax-loco = price-rubl-with-tax-loco - vat-rubl-loco - slt-rubl-loco - ((if road-tax-rubl-loco  = ? then 0 else road-tax-rubl-loco) + (if transport-rubl-loco = ? then 0 else transport-rubl-loco) + (if other-rubl-loco = ? then 0 else other-rubl-loco))
.
      assign
        varprice-base-cons = varprice-base-cons + (price-base-with-tax-loco - (if road-tax-base-loco = ? then 0 else road-tax-base-loco))* out-vatp_parts.fact-qnty
        varprice-rubl-cons = varprice-rubl-cons + (price-rubl-with-tax-loco - (if road-tax-rubl-loco = ? then 0 else road-tax-rubl-loco))* out-vatp_parts.fact-qnty.
      assign
        varis-cons-parts-have = yes
        varcons-qnty          = varcons-qnty + out-vatp_parts.fact-qnty.
    end.
    assign
      varfact-qnty = varfact-qnty + out-vatp_parts.fact-qnty.
  end.
end.
assign
  varprice-base-cons = varprice-base-cons / varcons-qnty
  varprice-rubl-cons = varprice-rubl-cons / varcons-qnty.
if varprice-base-cons = ? then do:
  assign
    varprice-base-cons = 0.
end.
if varprice-rubl-cons = ? then do:
  assign
    varprice-rubl-cons = 0.
end.
assign
  varsum-base-factovp     = 0
  varslt-base-factovp     = 0
  varvat-base-factovp     = 0
  varvatcons-base-factovp = 0
  vardsc-base-factovp     = 0
  varsum-base-docovp      = 0
  varslt-base-docovp      = 0
  varvat-base-docovp      = 0
  varvatcons-base-docovp  = 0
  vardsc-base-docovp      = 0
  varsum-rubl-factovp     = 0
  varslt-rubl-factovp     = 0
  varvat-rubl-factovp     = 0
  varvatcons-rubl-factovp = 0
  vardsc-rubl-factovp     = 0
  varsum-rubl-docovp      = 0
  varslt-rubl-docovp      = 0
  varvat-rubl-docovp      = 0
  varvatcons-rubl-docovp  = 0
  vardsc-rubl-docovp      = 0.
assign
  varis-one-gds-dtl = no.
find first out-vatp_gds-dtl where out-vatp_gds-dtl.doc-code  = trn-doc.doc-code  and
                                     out-vatp_gds-dtl.artic     = doc-line.artic     and
                                     out-vatp_gds-dtl.prod-type = doc-line.prod-type and
                                     out-vatp_gds-dtl.prod-code = doc-line.prod-code no-lock no-error.
if available out-vatp_gds-dtl then do:
  find first buf_out-vatp_gds-dtl where buf_out-vatp_gds-dtl.doc-code  =  trn-doc.doc-code                and
                                           buf_out-vatp_gds-dtl.artic     =  doc-line.artic                   and
                                           buf_out-vatp_gds-dtl.prod-type =  doc-line.prod-type               and
                                           buf_out-vatp_gds-dtl.prod-code =  doc-line.prod-code               and
                                           recid(buf_out-vatp_gds-dtl)    <> recid(out-vatp_gds-dtl) no-lock no-error.
  if not available buf_out-vatp_gds-dtl then do:
    assign
      varis-one-gds-dtl = yes.
  end.
  if varoutvprb = "base":u then do:
    assign
      varcurprice-base = out-vatp_gds-dtl.cur-base
      varcurprice-rubl = out-vatp_gds-dtl.cur-base * ((out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl) / (out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base)).
  end.
  else do:
    assign
      varcurprice-base = out-vatp_gds-dtl.cur-base / ((out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl) / (out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base))
      varcurprice-rubl = out-vatp_gds-dtl.cur-base.
  end.
  if varempty-scale    = yes or
     varis-one-gds-dtl = yes   then do:
    assign
                price-base-with-tax-sale    = (out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base)
        slt-base-sale               = (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc)
        vat-base-buyer              = (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-base-sale) * doc-line.vat-pc / (100 + doc-line.vat-pc)
        discnt-base-sale            = out-vatp_gds-dtl.discnt-base
                price-rubl-with-tax-sale    = (out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl)
        slt-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc)
        vat-rubl-buyer              = (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-rubl-sale) * doc-line.vat-pc / (100 + doc-line.vat-pc)
        discnt-rubl-sale            = out-vatp_gds-dtl.discnt-rubl
        .
    if trn-doc.doc-type = 'инв':U then do:
      ASSIGN
                vat-base-sale               = (if out-vatp-have-vat-slt = no then 0 else (((out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-base-sale - varprice-base-cons) * doc-line.cons-vat-pc / (100 + doc-line.cons-vat-pc) * out-vatp_gds-dtl.doc-qnty * varcons-qnty / varfact-qnty + ((out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-base-sale) * doc-line.vat-pc / (100 + doc-line.vat-pc) * out-vatp_gds-dtl.doc-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
                vat-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else (((out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-rubl-sale - varprice-rubl-cons) * doc-line.cons-vat-pc / (100 + doc-line.cons-vat-pc) * out-vatp_gds-dtl.doc-qnty * varcons-qnty / varfact-qnty + ((out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-rubl-sale) * doc-line.vat-pc / (100 + doc-line.vat-pc) * out-vatp_gds-dtl.doc-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
        .
    end.
    else do:
      ASSIGN
                vat-base-sale               = (if out-vatp-have-vat-slt = no then 0 else (((out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-base-sale - varprice-base-cons) * doc-line.cons-vat-pc / (100 + doc-line.cons-vat-pc) * out-vatp_gds-dtl.fact-qnty * varcons-qnty / varfact-qnty + ((out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-base-sale ) * doc-line.vat-pc / (100 + doc-line.vat-pc) * out-vatp_gds-dtl.fact-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
                vat-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else (((out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-rubl-sale - varprice-rubl-cons) * doc-line.cons-vat-pc / (100 + doc-line.cons-vat-pc) * out-vatp_gds-dtl.fact-qnty * varcons-qnty / varfact-qnty + ((out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-rubl-sale) * doc-line.vat-pc / (100 + doc-line.vat-pc) * out-vatp_gds-dtl.fact-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
        .
    end.
  end.
  else do:
    for each out-vatp_gds-dtl where out-vatp_gds-dtl.doc-code  = trn-doc.doc-code  and
                                       out-vatp_gds-dtl.artic     = doc-line.artic     and
                                       out-vatp_gds-dtl.prod-type = doc-line.prod-type and
                                       out-vatp_gds-dtl.prod-code = doc-line.prod-code no-lock :
      if varoutvprb = "base":u then do:
        assign
          varcurprice-base = out-vatp_gds-dtl.cur-base
          varcurprice-rubl = out-vatp_gds-dtl.cur-base * ((out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl) / (out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base)).
      end.
      else do:
        assign
          varcurprice-base = out-vatp_gds-dtl.cur-base / ((out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl) / (out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base))
          varcurprice-rubl = out-vatp_gds-dtl.cur-base.
      end.
      assign
             varsum-base-factovp = varsum-base-factovp + (out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base)                 * out-vatp_gds-dtl.fact-qnty
       varslt-base-factovp = varslt-base-factovp + (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc)                   * out-vatp_gds-dtl.fact-qnty
       varvat-base-factovp = varvat-base-factovp + (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-base-sale) * doc-line.vat-pc / (100 + doc-line.vat-pc)                   * out-vatp_gds-dtl.fact-qnty
       varvatcons-base-factovp = varvatcons-base-factovp + (((out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-base-sale - varprice-base-cons) * doc-line.cons-vat-pc / (100 + doc-line.cons-vat-pc) * out-vatp_gds-dtl.fact-qnty * varcons-qnty / varfact-qnty + ((out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-base-sale) * doc-line.vat-pc / (100 + doc-line.vat-pc) * out-vatp_gds-dtl.fact-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty)
       vardsc-base-factovp = vardsc-base-factovp + out-vatp_gds-dtl.discnt-base * out-vatp_gds-dtl.fact-qnty
       varsum-base-docovp  = varsum-base-docovp  + (out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base)                 * out-vatp_gds-dtl.doc-qnty
       varslt-base-docovp  = varslt-base-docovp  + (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc)                   * out-vatp_gds-dtl.doc-qnty
       varvat-base-docovp  = varvat-base-docovp  + (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-base-sale) * doc-line.vat-pc / (100 + doc-line.vat-pc)                   * out-vatp_gds-dtl.doc-qnty
       varvatcons-base-docovp  = varvatcons-base-docovp  + (((out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-base-sale - varprice-base-cons) * doc-line.cons-vat-pc / (100 + doc-line.cons-vat-pc) * out-vatp_gds-dtl.doc-qnty * varcons-qnty / varfact-qnty + ((out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-base-sale) * doc-line.vat-pc / (100 + doc-line.vat-pc) * out-vatp_gds-dtl.doc-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty)
       vardsc-base-docovp  = vardsc-base-docovp  + out-vatp_gds-dtl.discnt-base * out-vatp_gds-dtl.doc-qnty
      .
      assign
             varsum-rubl-factovp = varsum-rubl-factovp + (out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl)                 * out-vatp_gds-dtl.fact-qnty
       varslt-rubl-factovp = varslt-rubl-factovp + (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc)                   * out-vatp_gds-dtl.fact-qnty
       varvat-rubl-factovp = varvat-rubl-factovp + (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-rubl-sale) * doc-line.vat-pc / (100 + doc-line.vat-pc)                   * out-vatp_gds-dtl.fact-qnty
       varvatcons-rubl-factovp = varvatcons-rubl-factovp + (((out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-rubl-sale - varprice-rubl-cons) * doc-line.cons-vat-pc / (100 + doc-line.cons-vat-pc) * out-vatp_gds-dtl.fact-qnty * varcons-qnty / varfact-qnty + ((out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-rubl-sale) * doc-line.vat-pc / (100 + doc-line.vat-pc) * out-vatp_gds-dtl.fact-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty)
       vardsc-rubl-factovp = vardsc-rubl-factovp + out-vatp_gds-dtl.discnt-rubl * out-vatp_gds-dtl.fact-qnty
       varsum-rubl-docovp  = varsum-rubl-docovp  + (out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl)                 * out-vatp_gds-dtl.doc-qnty
       varslt-rubl-docovp  = varslt-rubl-docovp  + (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc)                   * out-vatp_gds-dtl.doc-qnty
       varvat-rubl-docovp  = varvat-rubl-docovp  + (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-rubl-sale) * doc-line.vat-pc / (100 + doc-line.vat-pc)                   * out-vatp_gds-dtl.doc-qnty
       varvatcons-rubl-docovp  = varvatcons-rubl-docovp  + (((out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-rubl-sale - varprice-rubl-cons) * doc-line.cons-vat-pc / (100 + doc-line.cons-vat-pc) * out-vatp_gds-dtl.doc-qnty * varcons-qnty / varfact-qnty + ((out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-rubl-sale) * doc-line.vat-pc / (100 + doc-line.vat-pc) * out-vatp_gds-dtl.doc-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty)
       vardsc-rubl-docovp  = vardsc-rubl-docovp  + out-vatp_gds-dtl.discnt-rubl * out-vatp_gds-dtl.doc-qnty   .
    end.
    if trn-doc.doc-type = 'инв':U then do:
      ASSIGN
                price-base-with-tax-sale    = varsum-base-docovp / varfact-qnty
        slt-base-sale               = varslt-base-docovp / varfact-qnty
        vat-base-buyer              = varvat-base-docovp / varfact-qnty
        discnt-base-sale            = vardsc-base-docovp / varfact-qnty
        vat-base-sale               = varvatcons-base-docovp / varfact-qnty
                price-rubl-with-tax-sale    = varsum-rubl-docovp / varfact-qnty
        slt-rubl-sale               = varslt-rubl-docovp / varfact-qnty
        vat-rubl-buyer              = varvat-rubl-docovp / varfact-qnty
        discnt-rubl-sale            = vardsc-rubl-docovp / varfact-qnty
        vat-rubl-sale               = varvatcons-rubl-docovp / varfact-qnty.
    end.
    else do:
      ASSIGN
                price-base-with-tax-sale    = varsum-base-factovp / varfact-qnty
        slt-base-sale               = varslt-base-factovp / varfact-qnty
        vat-base-buyer              = varvat-base-factovp / varfact-qnty
        discnt-base-sale            = vardsc-base-factovp / varfact-qnty
        vat-base-sale               = varvatcons-base-factovp / varfact-qnty
                price-rubl-with-tax-sale    = varsum-rubl-factovp / varfact-qnty
        slt-rubl-sale               = varslt-rubl-factovp / varfact-qnty
        vat-rubl-buyer              = varvat-rubl-factovp / varfact-qnty
        discnt-rubl-sale            = vardsc-rubl-factovp / varfact-qnty
        vat-rubl-sale               = varvatcons-rubl-factovp / varfact-qnty.
    end.
  end.
end.
assign
  price-base-without-tax-sale = price-base-with-tax-sale - vat-base-sale - slt-base-sale - road-tax-base-sale
  price-rubl-without-tax-sale = price-rubl-with-tax-sale - vat-rubl-sale - slt-rubl-sale - road-tax-rubl-sale.
assign
  price-rubl-with-tax-loc = doc-line.price-rubl
  price-base-with-tax-loc = doc-line.price-base
.
define variable vss-include-info47 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
   find first in-vatp_doc-attr no-lock
    where in-vatp_doc-attr.doc-code  = trn-doc.doc-code
      and in-vatp_doc-attr.attr-code = 'envd':U
    no-error .
    if available in-vatp_doc-attr
       then do:
       assign
         in-vatp-have-vat-slt = no.
   end.
   else do:
     assign
       in-vatp-have-vat-slt = yes.
   end.
   find first in-vatp-goods where in-vatp-goods.artic     = doc-line.artic     and
                                     in-vatp-goods.prod-type = doc-line.prod-type and
                                     in-vatp-goods.prod-code = doc-line.prod-code no-lock.
   if (not trn-doc.internal and
           trn-doc.doc-type = 'при':U) or
      in-vatp-goods.gds-type = 'у':U then do:
      if varinvprb = "base":u then do:
        assign
          road-tax-base-loc = doc-line.road-tax
          road-tax-rubl-loc = doc-line.road-tax * trn-doc.base-rate / trn-doc.base-scale.
      end.
      else do:
        ASSIGN
          road-tax-rubl-loc = doc-line.road-tax
          road-tax-base-loc = doc-line.road-tax / trn-doc.base-rate * trn-doc.base-scale.
      end.
      if road-tax-base-loc = ? then road-tax-base-loc = 0.
      if road-tax-rubl-loc = ? then road-tax-rubl-loc = 0.
      assign
        road-tax-cli-loc = ?.
      ASSIGN
        transport-base-loc = (if doc-line.transport-base = ? then 0 else doc-line.transport-base)
        transport-rubl-loc = (if doc-line.transport-rubl = ? then 0 else doc-line.transport-rubl)
        transport-cli-loc  = 0
        other-base-loc     = (if doc-line.other-base     = ? then 0 else doc-line.other-base)
        other-rubl-loc     = (if doc-line.other-rubl     = ? then 0 else doc-line.other-rubl)
        other-cli-loc      = 0
        vat-pc-loc         = (if doc-line.vat-pc         = ? then 0 else doc-line.vat-pc)
        slt-pc-loc         = (if doc-line.slt-pc         = ? then 0 else doc-line.slt-pc).
                              ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
            ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
      assign
        vat-cli-loc            = ?
        slt-cli-loc            = ?
        price-cli-with-tax-loc = ?.
   end.
   else do:
                                                for each in-vatp-parts where in-vatp-parts.out-code  = doc-line.doc-code  and
                                      in-vatp-parts.obj-type  = doc-line.obj-type  and
                                      in-vatp-parts.obj-code  = doc-line.obj-code  and
                                      in-vatp-parts.artic     = doc-line.artic     and
                                      in-vatp-parts.prod-type = doc-line.prod-type and
                                      in-vatp-parts.prod-code = doc-line.prod-code
                         use-index out-code no-lock:
          accumulate  in-vatp-parts.road-tax-base  * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.road-tax-rubl  * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.transport-base * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.transport-rubl * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.other-base     * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.other-rubl     * in-vatp-parts.fact-qnty (total)
                                                                                                              (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                      / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  / (100 + in-vatp-parts.vat-pc))  (total)
                                            (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                      / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  / (100 + in-vatp-parts.vat-pc))  (total)
                      .
      end.
      ASSIGN
        road-tax-base-loc   = if doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.road-tax-base  * in-vatp-parts.fact-qnty) / doc-line.fact-qnty  else 0
        road-tax-rubl-loc   = if doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.road-tax-rubl  * in-vatp-parts.fact-qnty) / doc-line.fact-qnty  else 0
        transport-base-loc  = if doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.transport-base * in-vatp-parts.fact-qnty) / doc-line.fact-qnty  else 0
        transport-rubl-loc  = if doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.transport-rubl * in-vatp-parts.fact-qnty) / doc-line.fact-qnty  else 0
        other-base-loc      = if doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.other-base     * in-vatp-parts.fact-qnty) / doc-line.fact-qnty  else 0
        other-rubl-loc      = if doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.other-rubl     * in-vatp-parts.fact-qnty) / doc-line.fact-qnty  else 0
                                        vat-base-loc        = if doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / doc-line.fact-qnty   else 0
        slt-base-loc        = if doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / doc-line.fact-qnty   else 0
                vat-rubl-loc        = if doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / doc-line.fact-qnty   else 0
        slt-rubl-loc        = if doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / doc-line.fact-qnty   else 0
        vat-pc-loc          = (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  / (100 + in-vatp-parts.vat-pc)))
        slt-pc-loc          = (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                      / (100 + in-vatp-parts.slt-pc))).
      if road-tax-base-loc  = ? then road-tax-base-loc  = 0.
      if road-tax-rubl-loc  = ? then road-tax-rubl-loc  = 0.
      if transport-base-loc = ? then transport-base-loc = 0.
      if transport-rubl-loc = ? then transport-rubl-loc = 0.
      if other-base-loc     = ? then other-base-loc     = 0.
      if other-rubl-loc     = ? then other-rubl-loc     = 0.
      assign
        transport-cli-loc      = 0
        other-cli-loc          = 0
        road-tax-cli-loc       = ?
        vat-cli-loc            = ?
        slt-cli-loc            = ?
        price-cli-with-tax-loc = ?.
   end.
ASSIGN
          price-base-without-tax-loc = price-base-with-tax-loc - vat-base-loc - slt-base-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))
    price-rubl-without-tax-loc = price-rubl-with-tax-loc - vat-rubl-loc - slt-rubl-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))
.
        if paytype = 2 then
        run r-cost in this-procedure ( input ub.doc-line.doc-code      ,input ub.doc-line.artic ,input ub.doc-line.prod-type
              ,input ub.doc-line.prod-code      ,output t-dec      ,output t-dec      ,output t-dec
              ,output cost-sum-base      ,output cost-sum-rubl      ,output t-dec      ,output t-dec      ,output t-dec
              ,output t-dec      ,output t-dec      ,output t-dec      ,output t-dec      ,output t-dec      ,output t-dec
              ,output t-dec      ,output t-dec      ,output t-dec ) no-error .
        CREATE gds-rep.
        assign
            gds-rep.doc-code  = ub.trn-doc.doc-code
            gds-rep.doc-num   = ub.trn-doc.doc-code
            gds-rep.doc-type  = ub.trn-doc.doc-type
            gds-rep.ext-doc-type = ub.trn-doc.ext-doc-type
            gds-rep.fact-num  = ub.trn-doc.fact-num
            gds-rep.fact-order= ub.trn-doc.fact-order
            gds-rep.fact-date = ub.trn-doc.doc-date
            gds-rep.fact-qnty = ( if can-do('рас,спи':U, ub.trn-doc.doc-type)
                                             then ( - ub.doc-line.fact-qnty )
                                             else ub.doc-line.fact-qnty ) .
            case ub.trn-doc.ext-doc-type :
             when 'pc':U then do:
                 gds-rep.clients   = "Смена типа приобретения" .
             end.
             when 'ap':U then do:
                 gds-rep.clients   = "Коррекция учетной цены"   .
             end.
             OTHERWISE do:
                gds-rep.clients   = ub.trn-doc.cli-name .
             end.
            end case.
       If PayType = 2 then
       Assign
          gds-rep.sale-base  =( if tPrintRubl then cost-sum-rubl else cost-sum-base ) / gds-rep.fact-qnty
          gds-rep.discnt-tot = 0 .
       Else do:
         if var-report-r-b  = "rubl" then
            Assign
                gds-rep.sale-base  = price-rubl-with-tax-sale + discnt-rubl-sale
                gds-rep.discnt-tot = discnt-rubl-sale  .
         else
            Assign
                gds-rep.sale-base  = price-base-with-tax-sale + discnt-base-sale
                gds-rep.discnt-tot = discnt-base-sale  .
        end.
        if gds-rep.sale-base = ? then
            gds-rep.sale-base = 0 .
        if gds-rep.discnt-tot = ? then
            gds-rep.discnt-tot = 0 .
        If PayType = 2 then
            gds-rep.tot-base = ( if tPrintRubl then cost-sum-rubl else cost-sum-base ).
           Else do:
           if var-report-r-b  = "rubl" then
                gds-rep.tot-base = gds-rep.fact-qnty * price-rubl-with-tax-sale.
                else
                gds-rep.tot-base = gds-rep.fact-qnty * price-base-with-tax-sale.
           end.
        if gds-rep.tot-base = ? then
           gds-rep.tot-base = 0 .
         assign
            gds-rep.rest-qnty = rest-qnty
            gds-rep.rest-base = rest-base
            gds-rep.netto = gds-rep.tot-base  .
         v-total-tot-ov = 0.
        if gds-rep.netto = ? then
            gds-rep.netto = 0 .
            v-ii = v-ii + 1 .
IF ( v-ii modulo v-account = 0 )  then DO:
 Assign
    v-kol-spice = (50 - LENGTH(reportname)) / 2
    RecordsString = fill(' ',v-kol-spice) + string(reportname)
    .
 Assign
    v-kol-spice = (50 - LENGTH('Открытые накладные')) / 2
    RecordsString2 = fill(' ',v-kol-spice) + string('Открытые накладные')
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
    END.
end.
End procedure.
procedure make-temp-table-befor :
define variable price-old like ub.price-list.price-sale no-undo.
define variable cur-dn as character no-undo .
define variable cur-pr as decimal no-undo .
define variable cur-rt as decimal no-undo .
define variable cur-ex as decimal no-undo .
define variable f-o as decimal no-undo .
define variable t-dec as decimal no-undo .
define variable cost-sum-base as decimal no-undo .
define variable cost-sum-rubl  as decimal no-undo .
define variable v1 as decimal no-undo .
define variable v2 as decimal no-undo .
define buffer buff_gds-obj for ub.gds-obj .
find first  buff_gds-obj no-lock where
      buff_gds-obj.artic     = v-x-artic         and
      buff_gds-obj.prod-type = v-x-prod-type     and
      buff_gds-obj.prod-code = v-x-prod-code     and
      buff_gds-obj.obj-code  = x-store-code      and
      buff_gds-obj.obj-type  = x-store-type no-error
      .
      if not available buff_gds-obj  then do:
      message "Товара" v-x-artic
              v-x-prod-type
              v-x-prod-code   skip
              "нет на объекте "
              x-store-code
              x-store-type
             view-as alert-box information .
      return.
      end.
assign
rest-qnty = buff_gds-obj.fact-qnty
.
if paytype = 2 then do:
   if var-report-r-b  = "rubl" then
            rest-base =  buff_gds-obj.fact-rubl .
      else  rest-base =  buff_gds-obj.fact-base .
   end.
else rest-base =  buff_gds-obj.fact-sale .
     FOR EACH ub.doc-line WHERE ub.doc-line.artic = b-goods.artic
                   AND ub.doc-line.prod-code  = b-goods.prod-code
                   AND ub.doc-line.prod-type  = b-goods.prod-type
                   AND ub.doc-line.obj-type   = x-store-type
                   AND ub.doc-line.obj-code   = x-store-code
                   NO-LOCK ,
        EACH ub.trn-doc WHERE ub.trn-doc.doc-code = ub.doc-line.doc-code
                      AND ub.trn-doc.fact-date >= start-date
                      AND ub.trn-doc.fact-num <> 0
                        NO-LOCK BY ub.trn-doc.fact-order DESCENDING :
if trn-doc.ext-doc-type = 'ot':U or
   trn-doc.ext-doc-type = ?                 then do:
  assign
   out-vatp-have-vat-slt = yes.
end.
else do:
  find first out-vatp_doc-attr no-lock
    where out-vatp_doc-attr.doc-code  = trn-doc.doc-code
      and out-vatp_doc-attr.attr-code = 'envd':U
      no-error .
  if not available out-vatp_doc-attr then do:
    assign
      out-vatp-have-vat-slt = yes.
  end.
  else do:
     out-vatp-have-vat-slt = no.
  end.
end.
find first out-vatp_goods where out-vatp_goods.artic     = doc-line.artic     and
                                   out-vatp_goods.prod-type = doc-line.prod-type and
                                   out-vatp_goods.prod-code = doc-line.prod-code no-lock.
define variable vss-include-info48 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  doc-line.artic
  ,input  doc-line.prod-type
  ,input  doc-line.prod-code
  ,output varroot-node
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении корневого признака товара" skip
    "Артикул" doc-line.artic doc-line.prod-type doc-line.prod-code skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtat in g#library
  (input  varroot-node
  ,input  'empty-scale=request'
  ,output varempty-scale
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении атрибута признака" skip
    "Артикул" doc-line.artic doc-line.prod-type doc-line.prod-code skip
    "Признак" varroot-node skip
    "Запрашивался атрибут" "empty-scale=request" skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
define variable vss-include-info49 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varoutvprb
  )  .
if varoutvprb = "base":u then do:
  assign
        road-tax-base-sale    =  (if doc-line.road-tax = ? then 0 else doc-line.road-tax * 1)
    excise-base-sale      =  (if doc-line.excise   = ? then 0 else doc-line.excise   * 1)
  .
end.
else do:
  assign
        road-tax-base-sale    =  (if doc-line.road-tax = ? then 0 else doc-line.road-tax / trn-doc.base-rate * trn-doc.base-scale)
    excise-base-sale      =  (if doc-line.excise   = ? then 0 else doc-line.excise   / trn-doc.base-rate * trn-doc.base-scale)
  .
end.
if varoutvprb = "rubl":u then do:
  assign
        road-tax-rubl-sale    = (if doc-line.road-tax = ? then 0 else doc-line.road-tax * 1)
    excise-rubl-sale      = (if doc-line.excise   = ? then 0 else doc-line.excise   * 1) .
end.
else do:
  assign
        road-tax-rubl-sale    = (if doc-line.road-tax = ? then 0 else doc-line.road-tax * trn-doc.base-rate / trn-doc.base-scale)
    excise-rubl-sale      = (if doc-line.excise   = ? then 0 else doc-line.excise   * trn-doc.base-rate / trn-doc.base-scale) .
end.
assign
  varis-cons-parts-have =  no.
assign
  varfact-qnty       = 0
  varcons-qnty       = 0
  varprice-base-cons = 0
  varprice-rubl-cons = 0.
find first out-vatp_doc-line where
           out-vatp_doc-line.doc-code   = trn-doc.doc-code
       and out-vatp_doc-line.artic      = doc-line.artic
       and out-vatp_doc-line.prod-type  = doc-line.prod-type
       and out-vatp_doc-line.prod-code  = doc-line.prod-code no-lock no-error.
if available out-vatp_doc-line           and
  (out-vatp_doc-line.status_ = 'запрос':U or out-vatp_goods.gds-type = 'у':U) then do:
  assign
    varfact-qnty = out-vatp_doc-line.fact-qnty.
end.
else do:
  for each out-vatp_parts where out-vatp_parts.out-code   = trn-doc.doc-code
                               and out-vatp_parts.obj-type   = trn-doc.obj-type
                               and out-vatp_parts.obj-code   = trn-doc.obj-code
                               and out-vatp_parts.artic      = doc-line.artic
                               and out-vatp_parts.prod-type  = doc-line.prod-type
                               and out-vatp_parts.prod-code  = doc-line.prod-code no-lock :
    if out-vatp_parts.purch-code = 2 then do:
assign
  price-rubl-with-tax-loco = out-vatp_parts.price-rubl
  price-base-with-tax-loco = out-vatp_parts.price-base
.
define variable vss-include-info50 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprbo
  )  .
  if out-vatp_parts.out-code = 'free-zone':U     or
     out-vatp_parts.out-code = 'out-zone':U   or
     out-vatp_parts.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-slto = yes.
  end.
  else do:
    find first in-vatp_doc-attro no-lock
      where in-vatp_doc-attro.doc-code  = out-vatp_parts.out-code
        and in-vatp_doc-attro.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attro then do:
      assign
        in-vatp-have-vat-slto = yes.
    end.
    else do:
         in-vatp-have-vat-slto = no.
    end.
  end.
  assign
   price-cli-with-tax-loco = out-vatp_parts.price-cli
   cli-base-rateo          = out-vatp_parts.cli-base-rate.
  ASSIGN   road-tax-base-loco  = (if out-vatp_parts.road-tax-base  = ? then 0 else out-vatp_parts.road-tax-base)
           road-tax-rubl-loco  = (if out-vatp_parts.road-tax-rubl  = ? then 0 else out-vatp_parts.road-tax-rubl).
  ASSIGN  transport-base-loco = (if out-vatp_parts.transport-base = ? then 0 else out-vatp_parts.transport-base)
          transport-rubl-loco = (if out-vatp_parts.transport-rubl = ? then 0 else out-vatp_parts.transport-rubl)
          other-base-loco     = (if out-vatp_parts.other-base     = ? then 0 else out-vatp_parts.other-base)
          other-rubl-loco     = (if out-vatp_parts.other-rubl     = ? then 0 else out-vatp_parts.other-rubl)
          vat-pc-loco         = (if out-vatp_parts.vat-pc         = ? then 0 else out-vatp_parts.vat-pc)
          slt-pc-loco         = (if out-vatp_parts.slt-pc         = ? then 0 else out-vatp_parts.slt-pc).
          ASSIGN   slt-base-loco    = (if in-vatp-have-vat-slto = no then 0 else (price-base-with-tax-loco - ((if road-tax-base-loco  = ? then 0 else road-tax-base-loco) + (if transport-base-loco = ? then 0 else transport-base-loco) + (if other-base-loco = ? then 0 else other-base-loco)))                           * slt-pc-loco / (100 + slt-pc-loco))                        vat-base-loco    = (if in-vatp-have-vat-slto = no then 0 else (price-base-with-tax-loco - ((if road-tax-base-loco  = ? then 0 else road-tax-base-loco) + (if transport-base-loco = ? then 0 else transport-base-loco) + (if other-base-loco = ? then 0 else other-base-loco))) * (1 - slt-pc-loco / (100 + slt-pc-loco)) * vat-pc-loco / (100 + vat-pc-loco)).
    ASSIGN   slt-rubl-loco    = (if in-vatp-have-vat-slto = no then 0 else (price-rubl-with-tax-loco - ((if road-tax-rubl-loco  = ? then 0 else road-tax-rubl-loco) + (if transport-rubl-loco = ? then 0 else transport-rubl-loco) + (if other-rubl-loco = ? then 0 else other-rubl-loco)))                           * slt-pc-loco / (100 + slt-pc-loco))                        vat-rubl-loco    = (if in-vatp-have-vat-slto = no then 0 else (price-rubl-with-tax-loco - ((if road-tax-rubl-loco  = ? then 0 else road-tax-rubl-loco) + (if transport-rubl-loco = ? then 0 else transport-rubl-loco) + (if other-rubl-loco = ? then 0 else other-rubl-loco))) * (1 - slt-pc-loco / (100 + slt-pc-loco)) * vat-pc-loco / (100 + vat-pc-loco)).
  assign
    exch-rate-cli-loco = (out-vatp_parts.price-rubl - transport-rubl-loco - other-rubl-loco - road-tax-rubl-loco - (if out-vatp_parts.vat-type <> 'в т. ч.':U then vat-rubl-loco else 0) - (if out-vatp_parts.slt-type <> 'в т. ч.':U then slt-rubl-loco else 0)) / out-vatp_parts.price-cli .
  assign
    slt-cli-loco        = slt-rubl-loco       / exch-rate-cli-loco
    vat-cli-loco        = vat-rubl-loco       / exch-rate-cli-loco
    road-tax-cli-loco   = road-tax-rubl-loco  / exch-rate-cli-loco
    transport-cli-loco  = 0
    other-cli-loco      = 0
  .
ASSIGN
          price-base-without-tax-loco = price-base-with-tax-loco - vat-base-loco - slt-base-loco - ((if road-tax-base-loco  = ? then 0 else road-tax-base-loco) + (if transport-base-loco = ? then 0 else transport-base-loco) + (if other-base-loco = ? then 0 else other-base-loco))
    price-rubl-without-tax-loco = price-rubl-with-tax-loco - vat-rubl-loco - slt-rubl-loco - ((if road-tax-rubl-loco  = ? then 0 else road-tax-rubl-loco) + (if transport-rubl-loco = ? then 0 else transport-rubl-loco) + (if other-rubl-loco = ? then 0 else other-rubl-loco))
.
      assign
        varprice-base-cons = varprice-base-cons + (price-base-with-tax-loco - (if road-tax-base-loco = ? then 0 else road-tax-base-loco))* out-vatp_parts.fact-qnty
        varprice-rubl-cons = varprice-rubl-cons + (price-rubl-with-tax-loco - (if road-tax-rubl-loco = ? then 0 else road-tax-rubl-loco))* out-vatp_parts.fact-qnty.
      assign
        varis-cons-parts-have = yes
        varcons-qnty          = varcons-qnty + out-vatp_parts.fact-qnty.
    end.
    assign
      varfact-qnty = varfact-qnty + out-vatp_parts.fact-qnty.
  end.
end.
assign
  varprice-base-cons = varprice-base-cons / varcons-qnty
  varprice-rubl-cons = varprice-rubl-cons / varcons-qnty.
if varprice-base-cons = ? then do:
  assign
    varprice-base-cons = 0.
end.
if varprice-rubl-cons = ? then do:
  assign
    varprice-rubl-cons = 0.
end.
assign
  varsum-base-factovp     = 0
  varslt-base-factovp     = 0
  varvat-base-factovp     = 0
  varvatcons-base-factovp = 0
  vardsc-base-factovp     = 0
  varsum-base-docovp      = 0
  varslt-base-docovp      = 0
  varvat-base-docovp      = 0
  varvatcons-base-docovp  = 0
  vardsc-base-docovp      = 0
  varsum-rubl-factovp     = 0
  varslt-rubl-factovp     = 0
  varvat-rubl-factovp     = 0
  varvatcons-rubl-factovp = 0
  vardsc-rubl-factovp     = 0
  varsum-rubl-docovp      = 0
  varslt-rubl-docovp      = 0
  varvat-rubl-docovp      = 0
  varvatcons-rubl-docovp  = 0
  vardsc-rubl-docovp      = 0.
assign
  varis-one-gds-dtl = no.
find first out-vatp_gds-dtl where out-vatp_gds-dtl.doc-code  = trn-doc.doc-code  and
                                     out-vatp_gds-dtl.artic     = doc-line.artic     and
                                     out-vatp_gds-dtl.prod-type = doc-line.prod-type and
                                     out-vatp_gds-dtl.prod-code = doc-line.prod-code no-lock no-error.
if available out-vatp_gds-dtl then do:
  find first buf_out-vatp_gds-dtl where buf_out-vatp_gds-dtl.doc-code  =  trn-doc.doc-code                and
                                           buf_out-vatp_gds-dtl.artic     =  doc-line.artic                   and
                                           buf_out-vatp_gds-dtl.prod-type =  doc-line.prod-type               and
                                           buf_out-vatp_gds-dtl.prod-code =  doc-line.prod-code               and
                                           recid(buf_out-vatp_gds-dtl)    <> recid(out-vatp_gds-dtl) no-lock no-error.
  if not available buf_out-vatp_gds-dtl then do:
    assign
      varis-one-gds-dtl = yes.
  end.
  if varoutvprb = "base":u then do:
    assign
      varcurprice-base = out-vatp_gds-dtl.cur-base
      varcurprice-rubl = out-vatp_gds-dtl.cur-base * ((out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl) / (out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base)).
  end.
  else do:
    assign
      varcurprice-base = out-vatp_gds-dtl.cur-base / ((out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl) / (out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base))
      varcurprice-rubl = out-vatp_gds-dtl.cur-base.
  end.
  if varempty-scale    = yes or
     varis-one-gds-dtl = yes   then do:
    assign
                price-base-with-tax-sale    = (out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base)
        slt-base-sale               = (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc)
        vat-base-buyer              = (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-base-sale) * doc-line.vat-pc / (100 + doc-line.vat-pc)
        discnt-base-sale            = out-vatp_gds-dtl.discnt-base
                price-rubl-with-tax-sale    = (out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl)
        slt-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc)
        vat-rubl-buyer              = (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-rubl-sale) * doc-line.vat-pc / (100 + doc-line.vat-pc)
        discnt-rubl-sale            = out-vatp_gds-dtl.discnt-rubl
        .
    if trn-doc.doc-type = 'инв':U then do:
      ASSIGN
                vat-base-sale               = (if out-vatp-have-vat-slt = no then 0 else (((out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-base-sale - varprice-base-cons) * doc-line.cons-vat-pc / (100 + doc-line.cons-vat-pc) * out-vatp_gds-dtl.doc-qnty * varcons-qnty / varfact-qnty + ((out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-base-sale) * doc-line.vat-pc / (100 + doc-line.vat-pc) * out-vatp_gds-dtl.doc-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
                vat-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else (((out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-rubl-sale - varprice-rubl-cons) * doc-line.cons-vat-pc / (100 + doc-line.cons-vat-pc) * out-vatp_gds-dtl.doc-qnty * varcons-qnty / varfact-qnty + ((out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-rubl-sale) * doc-line.vat-pc / (100 + doc-line.vat-pc) * out-vatp_gds-dtl.doc-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
        .
    end.
    else do:
      ASSIGN
                vat-base-sale               = (if out-vatp-have-vat-slt = no then 0 else (((out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-base-sale - varprice-base-cons) * doc-line.cons-vat-pc / (100 + doc-line.cons-vat-pc) * out-vatp_gds-dtl.fact-qnty * varcons-qnty / varfact-qnty + ((out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-base-sale ) * doc-line.vat-pc / (100 + doc-line.vat-pc) * out-vatp_gds-dtl.fact-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
                vat-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else (((out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-rubl-sale - varprice-rubl-cons) * doc-line.cons-vat-pc / (100 + doc-line.cons-vat-pc) * out-vatp_gds-dtl.fact-qnty * varcons-qnty / varfact-qnty + ((out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-rubl-sale) * doc-line.vat-pc / (100 + doc-line.vat-pc) * out-vatp_gds-dtl.fact-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
        .
    end.
  end.
  else do:
    for each out-vatp_gds-dtl where out-vatp_gds-dtl.doc-code  = trn-doc.doc-code  and
                                       out-vatp_gds-dtl.artic     = doc-line.artic     and
                                       out-vatp_gds-dtl.prod-type = doc-line.prod-type and
                                       out-vatp_gds-dtl.prod-code = doc-line.prod-code no-lock :
      if varoutvprb = "base":u then do:
        assign
          varcurprice-base = out-vatp_gds-dtl.cur-base
          varcurprice-rubl = out-vatp_gds-dtl.cur-base * ((out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl) / (out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base)).
      end.
      else do:
        assign
          varcurprice-base = out-vatp_gds-dtl.cur-base / ((out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl) / (out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base))
          varcurprice-rubl = out-vatp_gds-dtl.cur-base.
      end.
      assign
             varsum-base-factovp = varsum-base-factovp + (out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base)                 * out-vatp_gds-dtl.fact-qnty
       varslt-base-factovp = varslt-base-factovp + (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc)                   * out-vatp_gds-dtl.fact-qnty
       varvat-base-factovp = varvat-base-factovp + (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-base-sale) * doc-line.vat-pc / (100 + doc-line.vat-pc)                   * out-vatp_gds-dtl.fact-qnty
       varvatcons-base-factovp = varvatcons-base-factovp + (((out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-base-sale - varprice-base-cons) * doc-line.cons-vat-pc / (100 + doc-line.cons-vat-pc) * out-vatp_gds-dtl.fact-qnty * varcons-qnty / varfact-qnty + ((out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-base-sale) * doc-line.vat-pc / (100 + doc-line.vat-pc) * out-vatp_gds-dtl.fact-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty)
       vardsc-base-factovp = vardsc-base-factovp + out-vatp_gds-dtl.discnt-base * out-vatp_gds-dtl.fact-qnty
       varsum-base-docovp  = varsum-base-docovp  + (out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base)                 * out-vatp_gds-dtl.doc-qnty
       varslt-base-docovp  = varslt-base-docovp  + (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc)                   * out-vatp_gds-dtl.doc-qnty
       varvat-base-docovp  = varvat-base-docovp  + (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-base-sale) * doc-line.vat-pc / (100 + doc-line.vat-pc)                   * out-vatp_gds-dtl.doc-qnty
       varvatcons-base-docovp  = varvatcons-base-docovp  + (((out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-base-sale - varprice-base-cons) * doc-line.cons-vat-pc / (100 + doc-line.cons-vat-pc) * out-vatp_gds-dtl.doc-qnty * varcons-qnty / varfact-qnty + ((out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-base - out-vatp_gds-dtl.discnt-base                - road-tax-base-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-base-sale) * doc-line.vat-pc / (100 + doc-line.vat-pc) * out-vatp_gds-dtl.doc-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty)
       vardsc-base-docovp  = vardsc-base-docovp  + out-vatp_gds-dtl.discnt-base * out-vatp_gds-dtl.doc-qnty
      .
      assign
             varsum-rubl-factovp = varsum-rubl-factovp + (out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl)                 * out-vatp_gds-dtl.fact-qnty
       varslt-rubl-factovp = varslt-rubl-factovp + (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc)                   * out-vatp_gds-dtl.fact-qnty
       varvat-rubl-factovp = varvat-rubl-factovp + (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-rubl-sale) * doc-line.vat-pc / (100 + doc-line.vat-pc)                   * out-vatp_gds-dtl.fact-qnty
       varvatcons-rubl-factovp = varvatcons-rubl-factovp + (((out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-rubl-sale - varprice-rubl-cons) * doc-line.cons-vat-pc / (100 + doc-line.cons-vat-pc) * out-vatp_gds-dtl.fact-qnty * varcons-qnty / varfact-qnty + ((out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-rubl-sale) * doc-line.vat-pc / (100 + doc-line.vat-pc) * out-vatp_gds-dtl.fact-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty)
       vardsc-rubl-factovp = vardsc-rubl-factovp + out-vatp_gds-dtl.discnt-rubl * out-vatp_gds-dtl.fact-qnty
       varsum-rubl-docovp  = varsum-rubl-docovp  + (out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl)                 * out-vatp_gds-dtl.doc-qnty
       varslt-rubl-docovp  = varslt-rubl-docovp  + (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc)                   * out-vatp_gds-dtl.doc-qnty
       varvat-rubl-docovp  = varvat-rubl-docovp  + (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-rubl-sale) * doc-line.vat-pc / (100 + doc-line.vat-pc)                   * out-vatp_gds-dtl.doc-qnty
       varvatcons-rubl-docovp  = varvatcons-rubl-docovp  + (((out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-rubl-sale - varprice-rubl-cons) * doc-line.cons-vat-pc / (100 + doc-line.cons-vat-pc) * out-vatp_gds-dtl.doc-qnty * varcons-qnty / varfact-qnty + ((out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else out-vatp_gds-dtl.price-rubl - out-vatp_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * doc-line.SLT-pc / (100 + doc-line.SLT-pc) - road-tax-rubl-sale) * doc-line.vat-pc / (100 + doc-line.vat-pc) * out-vatp_gds-dtl.doc-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty)
       vardsc-rubl-docovp  = vardsc-rubl-docovp  + out-vatp_gds-dtl.discnt-rubl * out-vatp_gds-dtl.doc-qnty   .
    end.
    if trn-doc.doc-type = 'инв':U then do:
      ASSIGN
                price-base-with-tax-sale    = varsum-base-docovp / varfact-qnty
        slt-base-sale               = varslt-base-docovp / varfact-qnty
        vat-base-buyer              = varvat-base-docovp / varfact-qnty
        discnt-base-sale            = vardsc-base-docovp / varfact-qnty
        vat-base-sale               = varvatcons-base-docovp / varfact-qnty
                price-rubl-with-tax-sale    = varsum-rubl-docovp / varfact-qnty
        slt-rubl-sale               = varslt-rubl-docovp / varfact-qnty
        vat-rubl-buyer              = varvat-rubl-docovp / varfact-qnty
        discnt-rubl-sale            = vardsc-rubl-docovp / varfact-qnty
        vat-rubl-sale               = varvatcons-rubl-docovp / varfact-qnty.
    end.
    else do:
      ASSIGN
                price-base-with-tax-sale    = varsum-base-factovp / varfact-qnty
        slt-base-sale               = varslt-base-factovp / varfact-qnty
        vat-base-buyer              = varvat-base-factovp / varfact-qnty
        discnt-base-sale            = vardsc-base-factovp / varfact-qnty
        vat-base-sale               = varvatcons-base-factovp / varfact-qnty
                price-rubl-with-tax-sale    = varsum-rubl-factovp / varfact-qnty
        slt-rubl-sale               = varslt-rubl-factovp / varfact-qnty
        vat-rubl-buyer              = varvat-rubl-factovp / varfact-qnty
        discnt-rubl-sale            = vardsc-rubl-factovp / varfact-qnty
        vat-rubl-sale               = varvatcons-rubl-factovp / varfact-qnty.
    end.
  end.
end.
assign
  price-base-without-tax-sale = price-base-with-tax-sale - vat-base-sale - slt-base-sale - road-tax-base-sale
  price-rubl-without-tax-sale = price-rubl-with-tax-sale - vat-rubl-sale - slt-rubl-sale - road-tax-rubl-sale.
assign
  price-rubl-with-tax-loc = doc-line.price-rubl
  price-base-with-tax-loc = doc-line.price-base
.
define variable vss-include-info51 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
   find first in-vatp_doc-attr no-lock
    where in-vatp_doc-attr.doc-code  = trn-doc.doc-code
      and in-vatp_doc-attr.attr-code = 'envd':U
    no-error .
    if available in-vatp_doc-attr
       then do:
       assign
         in-vatp-have-vat-slt = no.
   end.
   else do:
     assign
       in-vatp-have-vat-slt = yes.
   end.
   find first in-vatp-goods where in-vatp-goods.artic     = doc-line.artic     and
                                     in-vatp-goods.prod-type = doc-line.prod-type and
                                     in-vatp-goods.prod-code = doc-line.prod-code no-lock.
   if (not trn-doc.internal and
           trn-doc.doc-type = 'при':U) or
      in-vatp-goods.gds-type = 'у':U then do:
      if varinvprb = "base":u then do:
        assign
          road-tax-base-loc = doc-line.road-tax
          road-tax-rubl-loc = doc-line.road-tax * trn-doc.base-rate / trn-doc.base-scale.
      end.
      else do:
        ASSIGN
          road-tax-rubl-loc = doc-line.road-tax
          road-tax-base-loc = doc-line.road-tax / trn-doc.base-rate * trn-doc.base-scale.
      end.
      if road-tax-base-loc = ? then road-tax-base-loc = 0.
      if road-tax-rubl-loc = ? then road-tax-rubl-loc = 0.
      assign
        road-tax-cli-loc = ?.
      ASSIGN
        transport-base-loc = (if doc-line.transport-base = ? then 0 else doc-line.transport-base)
        transport-rubl-loc = (if doc-line.transport-rubl = ? then 0 else doc-line.transport-rubl)
        transport-cli-loc  = 0
        other-base-loc     = (if doc-line.other-base     = ? then 0 else doc-line.other-base)
        other-rubl-loc     = (if doc-line.other-rubl     = ? then 0 else doc-line.other-rubl)
        other-cli-loc      = 0
        vat-pc-loc         = (if doc-line.vat-pc         = ? then 0 else doc-line.vat-pc)
        slt-pc-loc         = (if doc-line.slt-pc         = ? then 0 else doc-line.slt-pc).
                              ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
            ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
      assign
        vat-cli-loc            = ?
        slt-cli-loc            = ?
        price-cli-with-tax-loc = ?.
   end.
   else do:
                                                for each in-vatp-parts where in-vatp-parts.out-code  = doc-line.doc-code  and
                                      in-vatp-parts.obj-type  = doc-line.obj-type  and
                                      in-vatp-parts.obj-code  = doc-line.obj-code  and
                                      in-vatp-parts.artic     = doc-line.artic     and
                                      in-vatp-parts.prod-type = doc-line.prod-type and
                                      in-vatp-parts.prod-code = doc-line.prod-code
                         use-index out-code no-lock:
          accumulate  in-vatp-parts.road-tax-base  * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.road-tax-rubl  * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.transport-base * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.transport-rubl * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.other-base     * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.other-rubl     * in-vatp-parts.fact-qnty (total)
                                                                                                              (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                      / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  / (100 + in-vatp-parts.vat-pc))  (total)
                                            (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                      / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  / (100 + in-vatp-parts.vat-pc))  (total)
                      .
      end.
      ASSIGN
        road-tax-base-loc   = if doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.road-tax-base  * in-vatp-parts.fact-qnty) / doc-line.fact-qnty  else 0
        road-tax-rubl-loc   = if doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.road-tax-rubl  * in-vatp-parts.fact-qnty) / doc-line.fact-qnty  else 0
        transport-base-loc  = if doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.transport-base * in-vatp-parts.fact-qnty) / doc-line.fact-qnty  else 0
        transport-rubl-loc  = if doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.transport-rubl * in-vatp-parts.fact-qnty) / doc-line.fact-qnty  else 0
        other-base-loc      = if doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.other-base     * in-vatp-parts.fact-qnty) / doc-line.fact-qnty  else 0
        other-rubl-loc      = if doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.other-rubl     * in-vatp-parts.fact-qnty) / doc-line.fact-qnty  else 0
                                        vat-base-loc        = if doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / doc-line.fact-qnty   else 0
        slt-base-loc        = if doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / doc-line.fact-qnty   else 0
                vat-rubl-loc        = if doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / doc-line.fact-qnty   else 0
        slt-rubl-loc        = if doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / doc-line.fact-qnty   else 0
        vat-pc-loc          = (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  / (100 + in-vatp-parts.vat-pc)))
        slt-pc-loc          = (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                      / (100 + in-vatp-parts.slt-pc))).
      if road-tax-base-loc  = ? then road-tax-base-loc  = 0.
      if road-tax-rubl-loc  = ? then road-tax-rubl-loc  = 0.
      if transport-base-loc = ? then transport-base-loc = 0.
      if transport-rubl-loc = ? then transport-rubl-loc = 0.
      if other-base-loc     = ? then other-base-loc     = 0.
      if other-rubl-loc     = ? then other-rubl-loc     = 0.
      assign
        transport-cli-loc      = 0
        other-cli-loc          = 0
        road-tax-cli-loc       = ?
        vat-cli-loc            = ?
        slt-cli-loc            = ?
        price-cli-with-tax-loc = ?.
   end.
ASSIGN
          price-base-without-tax-loc = price-base-with-tax-loc - vat-base-loc - slt-base-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))
    price-rubl-without-tax-loc = price-rubl-with-tax-loc - vat-rubl-loc - slt-rubl-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))
.
        if paytype = 2 then
        run r-cost in this-procedure ( input ub.doc-line.doc-code      ,input ub.doc-line.artic ,input ub.doc-line.prod-type
              ,input ub.doc-line.prod-code      ,output t-dec      ,output t-dec      ,output t-dec
              ,output cost-sum-base      ,output cost-sum-rubl      ,output t-dec      ,output t-dec      ,output t-dec
              ,output t-dec      ,output t-dec      ,output t-dec      ,output t-dec      ,output t-dec      ,output t-dec
              ,output t-dec      ,output t-dec      ,output t-dec ) no-error .
        CREATE gds-rep-befor.
        assign
            gds-rep-befor.doc-code  = ub.trn-doc.doc-code
            gds-rep-befor.doc-num   = ub.trn-doc.doc-code
            gds-rep-befor.doc-type  = ub.trn-doc.doc-type
            gds-rep-befor.fact-num  = ub.trn-doc.fact-num
            gds-rep-befor.fact-order= ub.trn-doc.fact-order
            gds-rep-befor.fact-date = ub.trn-doc.fact-date
            gds-rep-befor.fact-qnty = ( if can-do('рас,спи':U, ub.trn-doc.doc-type)
                                             then ( - ub.doc-line.fact-qnty )
                                             else ub.doc-line.fact-qnty ) .
            case ub.trn-doc.ext-doc-type :
             when 'pc':U then do:
                 gds-rep-befor.clients   = "Смена типа приобретения" .
             end.
             when 'ap':U then do:
                 gds-rep-befor.clients   = "Коррекция учетной цены"   .
             end.
             OTHERWISE do:
                gds-rep-befor.clients   = ub.trn-doc.cli-name .
             end.
            end case.
       If PayType = 2 then
       Assign
          gds-rep-befor.sale-base  =( if tPrintRubl then cost-sum-rubl else cost-sum-base ) / gds-rep-befor.fact-qnty
          gds-rep-befor.discnt-tot = 0 .
       else do:
          if var-report-r-b  = "rubl" then
              assign
                  gds-rep-befor.sale-base = price-rubl-with-tax-sale + discnt-rubl-sale
                  gds-rep-befor.discnt-tot = discnt-rubl-sale  .
              else
              assign
                  gds-rep-befor.sale-base = price-base-with-tax-sale + discnt-base-sale
                  gds-rep-befor.discnt-tot = discnt-base-sale  .
        end.
        if gds-rep-befor.sale-base = ? then
            gds-rep-befor.sale-base = 0 .
        if gds-rep-befor.discnt-tot = ? then
           gds-rep-befor.discnt-tot = 0 .
        If PayType = 2 then
            gds-rep-befor.tot-base = ( if tPrintRubl then cost-sum-rubl else cost-sum-base ).
           Else do:
            if var-report-r-b  = "rubl" then
                 gds-rep-befor.tot-base = gds-rep-befor.fact-qnty * price-rubl-with-tax-sale.
            else
                 gds-rep-befor.tot-base = gds-rep-befor.fact-qnty * price-base-with-tax-sale.
            end.
        if gds-rep-befor.tot-base = ? then
           gds-rep-befor.tot-base = 0 .
        if  ub.trn-doc.doc-type = 'инв':U  Then
                assign
                    rest-qnty = rest-qnty - gds-rep-befor.fact-qnty
                    rest-base = rest-base - gds-rep-befor.tot-base.
            Else
                assign
                    rest-qnty = rest-qnty - gds-rep-befor.fact-qnty
                    rest-base = rest-base - (gds-rep-befor.fact-qnty * gds-rep-befor.sale-base ).
        assign
            gds-rep-befor.rest-qnty = rest-qnty
            gds-rep-befor.rest-base = rest-base
            gds-rep-befor.netto = gds-rep-befor.tot-base
            v-total-tot-ov = 0
            .
            for each gds-dtl-ch where gds-dtl-ch.doc-code  = ub.doc-line.doc-code  and
                                      gds-dtl-ch.artic     = ub.doc-line.artic     and
                                      gds-dtl-ch.prod-type = ub.doc-line.prod-type and
                                      gds-dtl-ch.prod-code = ub.doc-line.prod-code no-lock :
                assign
                      v-total-tot-ov  = v-total-tot-ov
                                      + (gds-dtl-ch.cur-base -
                                      ( if var-report-r-b  = "rubl" then
                                         gds-dtl-ch.price-rubl
                                         else gds-dtl-ch.price-base)
                                      ) * gds-dtl-ch.fact-qnty.
            end.
        if ( v-total-tot-ov  <> 0  and  PayType <> 2 ) then
            do:
                CREATE gds-rep-befor.
                assign
                    gds-rep-befor.doc-code = "------>"
                    gds-rep-befor.doc-type = 'а'
                    gds-rep-befor.fact-num = ub.trn-doc.fact-num
                    gds-rep-befor.fact-order = ub.trn-doc.fact-order
                    gds-rep-befor.clients  = "переоценка оборотов"
                    gds-rep-befor.fact-date = ub.trn-doc.fact-date
                    gds-rep-befor.fact-qnty = abs( ub.doc-line.fact-qnty ) .
               if can-do('рас,спи':U,trn-doc.doc-type) then
                    assign
                        gds-rep-befor.sale-base = ( v-total-tot-ov ) / ( - ub.doc-line.fact-qnty )
                        .
                else
                    assign
                        gds-rep-befor.sale-base = ( v-total-tot-ov ) / ub.doc-line.fact-qnty
                        .
                if gds-rep-befor.sale-base = ? then
                    gds-rep-befor.sale-base = 0 .
                rest-base = rest-base - ( ub.doc-line.fact-qnty * gds-rep-befor.sale-base ).
                assign
                    gds-rep-befor.discnt-tot = 0
                    gds-rep-befor.tot-base = gds-rep-befor.fact-qnty * gds-rep-befor.sale-base
                    gds-rep-befor.rest-qnty = rest-qnty
                    gds-rep-befor.rest-base = rest-base
                    gds-rep-befor.netto = ub.doc-line.fact-qnty * gds-rep-befor.sale-base
                .
            end.
            v-ii = v-ii  + 1 .
IF ( v-ii modulo v-account = 0 )  then DO:
 Assign
    v-kol-spice = (50 - LENGTH(reportname)) / 2
    RecordsString = fill(' ',v-kol-spice) + string(reportname)
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
    END.
if PayType <> 2 Then DO:
define variable v-price-sale as decimal no-undo .
  run price-prt in this-procedure ( input  integer(startdate) , output v1, output v-price-sale) .
  rest-base = v-price-sale .
end.
  rest-base1 = rest-base.
  rest-qnty1 = rest-qnty.
end procedure.
define variable vss-include-info52 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
def var vss-include-info53 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure r-cost :
  define input  parameter v-doc-code       like ub.doc-line.doc-code          no-undo .
  define input  parameter v-artic          like ub.doc-line.artic             no-undo .
  define input  parameter v-prod-type      like ub.doc-line.prod-type         no-undo .
  define input  parameter v-prod-code      like ub.doc-line.prod-code         no-undo .
  define output parameter v-fact-qnty      like ub.ot-line.fact-qnty       no-undo .
  define output parameter v-vat-pc         like ub.doc-line.vat-pc         no-undo .
  define output parameter v-slt-pc         like ub.doc-line.slt-pc         no-undo .
  define output parameter v-sum-base       like ub.ot-line.sum-base        no-undo .
  define output parameter v-sum-rubl       like ub.ot-line.sum-rubl        no-undo .
  define output parameter v-vat-base       like ub.ot-line.vat-base        no-undo .
  define output parameter v-vat-rubl       like ub.ot-line.vat-rubl        no-undo .
  define output parameter v-slt-base       like ub.ot-line.slt-base        no-undo .
  define output parameter v-slt-rubl       like ub.ot-line.slt-rubl        no-undo .
  define output parameter v-road-tax-base  like ub.ot-line.road-tax-base   no-undo .
  define output parameter v-road-tax-rubl  like ub.ot-line.road-tax-rubl   no-undo .
  define output parameter v-transport-base like ub.ot-line.transport-base  no-undo .
  define output parameter v-transport-rubl like ub.ot-line.transport-rubl  no-undo .
  define output parameter v-other-base     like ub.ot-line.other-base      no-undo .
  define output parameter v-other-rubl     like ub.ot-line.other-rubl      no-undo .
  define output parameter v-excise-base    like ub.ot-line.excise-base     no-undo .
  define output parameter v-excise-rubl    like ub.ot-line.excise-rubl     no-undo .
  do
  on error undo, return error
  :
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
    def var v-parts-fact-qnty as decimal   no-undo .
    define buffer buf_parts    for ub.parts    .
    define buffer buf_goods    for ub.goods    .
    define buffer buf_trn-doc  for ub.trn-doc  .
    define buffer buf_doc-line for ub.doc-line .
    find first buf_doc-line no-lock
      where buf_doc-line.doc-code  = v-doc-code
        and buf_doc-line.artic     = v-artic
        and buf_doc-line.prod-type = v-prod-type
        and buf_doc-line.prod-code = v-prod-code
      no-error .
    if not available buf_doc-line then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info53 skip
        "Ошибка задания входных параметров" skip
        "Не найдена строка документа"  skip
        "Документ" v-doc-code skip
        "Артикул" v-artic v-prod-type v-prod-code skip
        view-as alert-box error .
      return error .
    end.
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = v-doc-code
      no-error .
    if not available buf_trn-doc then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info53 skip
        "Ошибка задания входных параметров" skip
        "Не найден документ" skip
        "Документ" v-doc-code skip
        "Артикул" v-artic v-prod-type v-prod-code skip
        view-as alert-box error .
      undo, return error .
    end.
    find first buf_goods no-lock
      where buf_goods.artic     = buf_doc-line.artic
        and buf_goods.prod-type = buf_doc-line.prod-type
        and buf_goods.prod-code = buf_doc-line.prod-code
      no-error .
    if not available buf_goods then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info53 skip
        "Ошибка задания входных параметров" skip
        "Не найден товар" skip
        "Документ" v-doc-code skip
        "Артикул" v-artic v-prod-type v-prod-code skip
        view-as alert-box error .
      undo, return error .
    end.
    if buf_goods.gds-type = 'т':U then do:
          for each buf_parts no-lock
            where buf_parts.out-code  = buf_trn-doc.doc-code
              and buf_parts.obj-type  = buf_trn-doc.obj-type
              and buf_parts.obj-code  = buf_trn-doc.obj-code
              and buf_parts.artic     = buf_doc-line.artic
              and buf_parts.prod-type = buf_doc-line.prod-type
              and buf_parts.prod-code = buf_doc-line.prod-code
          on error undo, return error
          :
assign
  price-rubl-with-tax-loc = buf_parts.price-rubl
  price-base-with-tax-loc = buf_parts.price-base
.
define variable vss-include-info54 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
  if buf_parts.out-code = 'free-zone':U     or
     buf_parts.out-code = 'out-zone':U   or
     buf_parts.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-slt = yes.
  end.
  else do:
    find first in-vatp_doc-attr no-lock
      where in-vatp_doc-attr.doc-code  = buf_parts.out-code
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
   price-cli-with-tax-loc = buf_parts.price-cli
   cli-base-rate          = buf_parts.cli-base-rate.
  ASSIGN   road-tax-base-loc  = (if buf_parts.road-tax-base  = ? then 0 else buf_parts.road-tax-base)
           road-tax-rubl-loc  = (if buf_parts.road-tax-rubl  = ? then 0 else buf_parts.road-tax-rubl).
  ASSIGN  transport-base-loc = (if buf_parts.transport-base = ? then 0 else buf_parts.transport-base)
          transport-rubl-loc = (if buf_parts.transport-rubl = ? then 0 else buf_parts.transport-rubl)
          other-base-loc     = (if buf_parts.other-base     = ? then 0 else buf_parts.other-base)
          other-rubl-loc     = (if buf_parts.other-rubl     = ? then 0 else buf_parts.other-rubl)
          vat-pc-loc         = (if buf_parts.vat-pc         = ? then 0 else buf_parts.vat-pc)
          slt-pc-loc         = (if buf_parts.slt-pc         = ? then 0 else buf_parts.slt-pc).
          ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
    ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
  assign
    exch-rate-cli-loc = (buf_parts.price-rubl - transport-rubl-loc - other-rubl-loc - road-tax-rubl-loc - (if buf_parts.vat-type <> 'в т. ч.':U then vat-rubl-loc else 0) - (if buf_parts.slt-type <> 'в т. ч.':U then slt-rubl-loc else 0)) / buf_parts.price-cli .
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
              v-parts-fact-qnty  = (if buf_trn-doc.doc-type = 'при':U
                                    or buf_trn-doc.doc-type = 'возврат':U
                                    or buf_trn-doc.doc-type = 'инв':U
                                    then buf_parts.fact-qnty
                                    else - buf_parts.fact-qnty
                                   )
            .
            assign
              v-fact-qnty           = v-fact-qnty      + v-parts-fact-qnty
              v-sum-base            = v-sum-base       +  ( price-base-with-tax-loc * v-parts-fact-qnty )
              v-sum-rubl            = v-sum-rubl       +  ( price-rubl-with-tax-loc * v-parts-fact-qnty )
              v-vat-base            = v-vat-base       +  ( vat-base-loc            * v-parts-fact-qnty )
              v-vat-rubl            = v-vat-rubl       +  ( vat-rubl-loc            * v-parts-fact-qnty )
              v-slt-base            = v-slt-base       +  ( slt-base-loc            * v-parts-fact-qnty )
              v-slt-rubl            = v-slt-rubl       +  ( slt-rubl-loc            * v-parts-fact-qnty )
              v-road-tax-base       = v-road-tax-base  +  ( road-tax-base-loc       * v-parts-fact-qnty )
              v-road-tax-rubl       = v-road-tax-rubl  +  ( road-tax-rubl-loc       * v-parts-fact-qnty )
              v-excise-base         =   0
              v-excise-rubl         =   0
              v-transport-base      = v-transport-base +   (transport-base-loc      * v-parts-fact-qnty )
              v-transport-rubl      = v-transport-rubl +   (transport-rubl-loc      * v-parts-fact-qnty )
              v-other-base          = v-other-base     +   (other-base-loc          * v-parts-fact-qnty )
              v-other-rubl          = v-other-rubl     +   (other-rubl-loc          * v-parts-fact-qnty )
            .
        end.
assign
  price-rubl-with-tax-loc = buf_doc-line.price-rubl
  price-base-with-tax-loc = buf_doc-line.price-base
.
define variable vss-include-info55 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
   find first in-vatp_doc-attr no-lock
    where in-vatp_doc-attr.doc-code  = buf_trn-doc.doc-code
      and in-vatp_doc-attr.attr-code = 'envd':U
    no-error .
    if available in-vatp_doc-attr
       then do:
       assign
         in-vatp-have-vat-slt = no.
   end.
   else do:
     assign
       in-vatp-have-vat-slt = yes.
   end.
   find first in-vatp-goods where in-vatp-goods.artic     = buf_doc-line.artic     and
                                     in-vatp-goods.prod-type = buf_doc-line.prod-type and
                                     in-vatp-goods.prod-code = buf_doc-line.prod-code no-lock.
   if (not buf_trn-doc.internal and
           buf_trn-doc.doc-type = 'при':U) or
      in-vatp-goods.gds-type = 'у':U then do:
      if varinvprb = "base":u then do:
        assign
          road-tax-base-loc = buf_doc-line.road-tax
          road-tax-rubl-loc = buf_doc-line.road-tax * buf_trn-doc.base-rate / buf_trn-doc.base-scale.
      end.
      else do:
        ASSIGN
          road-tax-rubl-loc = buf_doc-line.road-tax
          road-tax-base-loc = buf_doc-line.road-tax / buf_trn-doc.base-rate * buf_trn-doc.base-scale.
      end.
      if road-tax-base-loc = ? then road-tax-base-loc = 0.
      if road-tax-rubl-loc = ? then road-tax-rubl-loc = 0.
      assign
        road-tax-cli-loc = ?.
      ASSIGN
        transport-base-loc = (if buf_doc-line.transport-base = ? then 0 else buf_doc-line.transport-base)
        transport-rubl-loc = (if buf_doc-line.transport-rubl = ? then 0 else buf_doc-line.transport-rubl)
        transport-cli-loc  = 0
        other-base-loc     = (if buf_doc-line.other-base     = ? then 0 else buf_doc-line.other-base)
        other-rubl-loc     = (if buf_doc-line.other-rubl     = ? then 0 else buf_doc-line.other-rubl)
        other-cli-loc      = 0
        vat-pc-loc         = (if buf_doc-line.vat-pc         = ? then 0 else buf_doc-line.vat-pc)
        slt-pc-loc         = (if buf_doc-line.slt-pc         = ? then 0 else buf_doc-line.slt-pc).
                              ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
            ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
      assign
        vat-cli-loc            = ?
        slt-cli-loc            = ?
        price-cli-with-tax-loc = ?.
   end.
   else do:
                                                for each in-vatp-parts where in-vatp-parts.out-code  = buf_doc-line.doc-code  and
                                      in-vatp-parts.obj-type  = buf_doc-line.obj-type  and
                                      in-vatp-parts.obj-code  = buf_doc-line.obj-code  and
                                      in-vatp-parts.artic     = buf_doc-line.artic     and
                                      in-vatp-parts.prod-type = buf_doc-line.prod-type and
                                      in-vatp-parts.prod-code = buf_doc-line.prod-code
                         use-index out-code no-lock:
          accumulate  in-vatp-parts.road-tax-base  * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.road-tax-rubl  * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.transport-base * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.transport-rubl * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.other-base     * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.other-rubl     * in-vatp-parts.fact-qnty (total)
                                                                                                              (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                      / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  / (100 + in-vatp-parts.vat-pc))  (total)
                                            (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                      / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  / (100 + in-vatp-parts.vat-pc))  (total)
                      .
      end.
      ASSIGN
        road-tax-base-loc   = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.road-tax-base  * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        road-tax-rubl-loc   = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.road-tax-rubl  * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        transport-base-loc  = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.transport-base * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        transport-rubl-loc  = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.transport-rubl * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        other-base-loc      = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.other-base     * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        other-rubl-loc      = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.other-rubl     * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
                                        vat-base-loc        = if buf_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / buf_doc-line.fact-qnty   else 0
        slt-base-loc        = if buf_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / buf_doc-line.fact-qnty   else 0
                vat-rubl-loc        = if buf_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / buf_doc-line.fact-qnty   else 0
        slt-rubl-loc        = if buf_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / buf_doc-line.fact-qnty   else 0
        vat-pc-loc          = (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  / (100 + in-vatp-parts.vat-pc)))
        slt-pc-loc          = (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                      / (100 + in-vatp-parts.slt-pc))).
      if road-tax-base-loc  = ? then road-tax-base-loc  = 0.
      if road-tax-rubl-loc  = ? then road-tax-rubl-loc  = 0.
      if transport-base-loc = ? then transport-base-loc = 0.
      if transport-rubl-loc = ? then transport-rubl-loc = 0.
      if other-base-loc     = ? then other-base-loc     = 0.
      if other-rubl-loc     = ? then other-rubl-loc     = 0.
      assign
        transport-cli-loc      = 0
        other-cli-loc          = 0
        road-tax-cli-loc       = ?
        vat-cli-loc            = ?
        slt-cli-loc            = ?
        price-cli-with-tax-loc = ?.
   end.
ASSIGN
          price-base-without-tax-loc = price-base-with-tax-loc - vat-base-loc - slt-base-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))
    price-rubl-without-tax-loc = price-rubl-with-tax-loc - vat-rubl-loc - slt-rubl-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))
.
        assign
            v-vat-pc              = vat-pc-loc
            v-slt-pc              = slt-pc-loc
        .
    end.
    else do:
          assign
            v-parts-fact-qnty           = (if buf_trn-doc.doc-type = 'при':U
                                      or buf_trn-doc.doc-type = 'возврат':U
                                      or buf_trn-doc.doc-type = 'инв':U
                                      then buf_doc-line.fact-qnty
                                      else - buf_doc-line.fact-qnty
                                    )
          .
assign
  price-rubl-with-tax-loc = buf_doc-line.price-rubl
  price-base-with-tax-loc = buf_doc-line.price-base
.
define variable vss-include-info56 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
   find first in-vatp_doc-attr no-lock
    where in-vatp_doc-attr.doc-code  = buf_trn-doc.doc-code
      and in-vatp_doc-attr.attr-code = 'envd':U
    no-error .
    if available in-vatp_doc-attr
       then do:
       assign
         in-vatp-have-vat-slt = no.
   end.
   else do:
     assign
       in-vatp-have-vat-slt = yes.
   end.
   find first in-vatp-goods where in-vatp-goods.artic     = buf_doc-line.artic     and
                                     in-vatp-goods.prod-type = buf_doc-line.prod-type and
                                     in-vatp-goods.prod-code = buf_doc-line.prod-code no-lock.
   if (not buf_trn-doc.internal and
           buf_trn-doc.doc-type = 'при':U) or
      in-vatp-goods.gds-type = 'у':U then do:
      if varinvprb = "base":u then do:
        assign
          road-tax-base-loc = buf_doc-line.road-tax
          road-tax-rubl-loc = buf_doc-line.road-tax * buf_trn-doc.base-rate / buf_trn-doc.base-scale.
      end.
      else do:
        ASSIGN
          road-tax-rubl-loc = buf_doc-line.road-tax
          road-tax-base-loc = buf_doc-line.road-tax / buf_trn-doc.base-rate * buf_trn-doc.base-scale.
      end.
      if road-tax-base-loc = ? then road-tax-base-loc = 0.
      if road-tax-rubl-loc = ? then road-tax-rubl-loc = 0.
      assign
        road-tax-cli-loc = ?.
      ASSIGN
        transport-base-loc = (if buf_doc-line.transport-base = ? then 0 else buf_doc-line.transport-base)
        transport-rubl-loc = (if buf_doc-line.transport-rubl = ? then 0 else buf_doc-line.transport-rubl)
        transport-cli-loc  = 0
        other-base-loc     = (if buf_doc-line.other-base     = ? then 0 else buf_doc-line.other-base)
        other-rubl-loc     = (if buf_doc-line.other-rubl     = ? then 0 else buf_doc-line.other-rubl)
        other-cli-loc      = 0
        vat-pc-loc         = (if buf_doc-line.vat-pc         = ? then 0 else buf_doc-line.vat-pc)
        slt-pc-loc         = (if buf_doc-line.slt-pc         = ? then 0 else buf_doc-line.slt-pc).
                              ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
            ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
      assign
        vat-cli-loc            = ?
        slt-cli-loc            = ?
        price-cli-with-tax-loc = ?.
   end.
   else do:
                                                for each in-vatp-parts where in-vatp-parts.out-code  = buf_doc-line.doc-code  and
                                      in-vatp-parts.obj-type  = buf_doc-line.obj-type  and
                                      in-vatp-parts.obj-code  = buf_doc-line.obj-code  and
                                      in-vatp-parts.artic     = buf_doc-line.artic     and
                                      in-vatp-parts.prod-type = buf_doc-line.prod-type and
                                      in-vatp-parts.prod-code = buf_doc-line.prod-code
                         use-index out-code no-lock:
          accumulate  in-vatp-parts.road-tax-base  * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.road-tax-rubl  * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.transport-base * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.transport-rubl * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.other-base     * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.other-rubl     * in-vatp-parts.fact-qnty (total)
                                                                                                              (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                      / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  / (100 + in-vatp-parts.vat-pc))  (total)
                                            (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                      / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  / (100 + in-vatp-parts.vat-pc))  (total)
                      .
      end.
      ASSIGN
        road-tax-base-loc   = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.road-tax-base  * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        road-tax-rubl-loc   = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.road-tax-rubl  * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        transport-base-loc  = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.transport-base * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        transport-rubl-loc  = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.transport-rubl * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        other-base-loc      = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.other-base     * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        other-rubl-loc      = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.other-rubl     * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
                                        vat-base-loc        = if buf_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / buf_doc-line.fact-qnty   else 0
        slt-base-loc        = if buf_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / buf_doc-line.fact-qnty   else 0
                vat-rubl-loc        = if buf_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / buf_doc-line.fact-qnty   else 0
        slt-rubl-loc        = if buf_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / buf_doc-line.fact-qnty   else 0
        vat-pc-loc          = (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  / (100 + in-vatp-parts.vat-pc)))
        slt-pc-loc          = (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                      / (100 + in-vatp-parts.slt-pc))).
      if road-tax-base-loc  = ? then road-tax-base-loc  = 0.
      if road-tax-rubl-loc  = ? then road-tax-rubl-loc  = 0.
      if transport-base-loc = ? then transport-base-loc = 0.
      if transport-rubl-loc = ? then transport-rubl-loc = 0.
      if other-base-loc     = ? then other-base-loc     = 0.
      if other-rubl-loc     = ? then other-rubl-loc     = 0.
      assign
        transport-cli-loc      = 0
        other-cli-loc          = 0
        road-tax-cli-loc       = ?
        vat-cli-loc            = ?
        slt-cli-loc            = ?
        price-cli-with-tax-loc = ?.
   end.
ASSIGN
          price-base-without-tax-loc = price-base-with-tax-loc - vat-base-loc - slt-base-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))
    price-rubl-without-tax-loc = price-rubl-with-tax-loc - vat-rubl-loc - slt-rubl-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))
.
          assign
            v-fact-qnty           = v-fact-qnty      + v-parts-fact-qnty
            v-vat-pc              = vat-pc-loc
            v-slt-pc              = slt-pc-loc
            v-sum-base            = v-sum-base       + (price-base-with-tax-loc * v-parts-fact-qnty)
            v-sum-rubl            = v-sum-rubl       + (price-rubl-with-tax-loc * v-parts-fact-qnty)
            v-vat-base            = v-vat-base       + (vat-base-loc            * v-parts-fact-qnty)
            v-vat-rubl            = v-vat-rubl       + (vat-rubl-loc            * v-parts-fact-qnty)
            v-slt-base            = v-slt-base       + (slt-base-loc            * v-parts-fact-qnty)
            v-slt-rubl            = v-slt-rubl       + (slt-rubl-loc            * v-parts-fact-qnty)
            v-road-tax-base       =  0
            v-road-tax-rubl       =  0
            v-excise-base         =  0
            v-excise-rubl         =  0
            v-transport-base      =  0
            v-transport-rubl      =  0
            v-other-base          =  0
            v-other-rubl          =  0
          .
    end.
  end.
end procedure.
procedure calc-price-sale-for-prt :
define input parameter fact-order-doc as decimal no-undo .
define input parameter v-bar-code     as character no-undo .
define output parameter v-cur-base as decimal no-undo .
define variable v-cli-base-rate like ub.bar-code.cli-base-rate no-undo .
define var parrecid-prl as recid no-undo .
    define  variable price-rubl-with-tax-sale-prl    like ub.doc-line.price-rubl no-undo.
    define  variable price-base-with-tax-sale-prl    like ub.doc-line.price-base no-undo.
    define  variable price-rubl-without-tax-sale-prl like ub.doc-line.price-rubl no-undo.
    define  variable price-base-without-tax-sale-prl like ub.doc-line.price-base no-undo.
    define  variable vat-base-sale-prl               like ub.doc-line.price-base no-undo.
    define  variable vat-rubl-sale-prl               like ub.doc-line.price-rubl no-undo.
    define  variable vat-base-buyer-prl              like ub.doc-line.price-base no-undo.
    define  variable vat-rubl-buyer-prl              like ub.doc-line.price-rubl no-undo.
    define  variable slt-base-sale-prl               like ub.doc-line.price-base no-undo.
    define  variable slt-rubl-sale-prl               like ub.doc-line.price-rubl no-undo.
    define  variable road-tax-base-sale-prl          like ub.doc-line.road-tax   no-undo.
    define  variable road-tax-rubl-sale-prl          like ub.doc-line.road-tax   no-undo.
    define  variable excise-base-sale-prl            like ub.doc-line.price-base no-undo.
    define  variable excise-rubl-sale-prl            like ub.doc-line.price-rubl no-undo.
    define  variable discnt-base-sale-prl            like ub.gds-dtl.discnt-base no-undo.
    define  variable discnt-rubl-sale-prl            like ub.gds-dtl.discnt-rubl no-undo.
    define buffer out-vatp_gds-dtl-prl     for ub.gds-dtl.
    define buffer buf_out-vatp_gds-dtl-prl for ub.gds-dtl.
    define buffer out-vatp_parts-prl       for ub.parts.
    define buffer out-vatp_sysconf-prl     for ub.sysconf.
    define buffer out-vatp_doc-line-prl    for ub.doc-line.
    define buffer out-vatp_goods-prl       for ub.goods.
    define buffer out-vatp_trn-doc-prl     for ub.trn-doc.
    define buffer out-vatp_doc-attr-prl    for ub.doc-attr.
    define variable varprice-base-cons-prl      like ub.doc-line.price-base initial 0.00 no-undo.
    define variable varprice-rubl-cons-prl      like ub.doc-line.price-rubl initial 0.00 no-undo.
    define variable varfrm-cnsv-type-prl         as   character                           no-undo.
    define variable varfrm-cnsv-prl              as   character                           no-undo.
    define variable varroot-node-prl             as   integer                             no-undo.
    define variable varempty-scale-prl           as   logical                             no-undo.
    define variable varis-cons-parts-have-prl    as   logical                             no-undo.
    define variable varsum-base-factovp-prl      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-factovp-prl      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-factovp-prl      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-factovp-prl  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-factovp-prl      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-base-docovp-prl       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-docovp-prl       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-docovp-prl       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-docovp-prl   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-docovp-prl       like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-factovp-prl      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-factovp-prl      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-factovp-prl      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-factovp-prl  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-factovp-prl      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-docovp-prl       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-docovp-prl       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-docovp-prl       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-docovp-prl   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-docovp-prl       like ub.gds-dtl.price-base               no-undo.
    define variable varfact-qnty-prl             like ub.parts.fact-qnty                  no-undo.
    define variable varcons-qnty-prl             like ub.parts.fact-qnty                  no-undo.
    define variable varis-one-gds-dtl-prl        as   logical                             no-undo.
    define variable varcur-prlprice-base         like ub.gds-dtl.cur-base                 no-undo.
    define variable varcur-prlprice-rubl         like ub.gds-dtl.price-base               no-undo.
    define variable varcur-prldiscnt-base        like ub.gds-dtl.cur-base                 no-undo.
    define variable varcur-prldiscnt-rubl        like ub.gds-dtl.price-base               no-undo.
    define variable varoutvprb-prl               as   character                           no-undo.
    define variable out-vatp-have-vat-slt-prl    as   logical initial yes                 no-undo.
    define buffer   in-vatp-trn-doco-prl  for ub.trn-doc .
    define buffer   in-vatp-partso-prl    for ub.parts   .
    define buffer   in-vatp-doco-prl      for ub.trn-doc .
    define buffer   in-vatp-goodso-prl    for ub.goods   .
    define buffer   in-vatp-sysconfo-prl  for ub.sysconf .
    define buffer   in-vatp_doc-attro-prl for ub.doc-attr.
    define variable in-vatp-have-vat-slto-prl       as   logical initial yes    no-undo.
    define variable vat-pc-loco-prl                 like ub.doc-line.vat-pc     no-undo.
    define variable varinvprbo-prl                  as   character              no-undo.
    define variable slt-pc-loco-prl                 like ub.doc-line.slt-pc     no-undo.
    define variable cli-base-rateo-prl              as   decimal                no-undo.
    define variable price-rubl-with-tax-loco-prl    like ub.doc-line.price-rubl no-undo.
    define variable price-base-with-tax-loco-prl    like ub.doc-line.price-base no-undo.
    define variable price-cli-with-tax-loco-prl     like ub.doc-line.price-cli  no-undo.
    define variable price-rubl-without-tax-loco-prl like ub.doc-line.price-rubl no-undo.
    define variable price-base-without-tax-loco-prl like ub.doc-line.price-base no-undo.
    define variable price-cli-without-tax-loco-prl  like ub.doc-line.price-base no-undo.
    define variable vat-base-loco-prl               like ub.doc-line.price-base no-undo.
    define variable vat-rubl-loco-prl               like ub.doc-line.price-rubl no-undo.
    define variable vat-cli-loco-prl                like ub.doc-line.price-rubl no-undo.
    define variable slt-base-loco-prl               like ub.doc-line.price-base no-undo.
    define variable slt-rubl-loco-prl               like ub.doc-line.price-rubl no-undo.
    define variable slt-cli-loco-prl                like ub.doc-line.price-rubl no-undo.
    define variable road-tax-base-loco-prl          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-rubl-loco-prl          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-cli-loco-prl           like ub.doc-line.road-tax   no-undo.
    define variable transport-base-loco-prl         like ub.doc-line.price-base no-undo.
    define variable transport-rubl-loco-prl         like ub.doc-line.price-rubl no-undo.
    define variable transport-cli-loco-prl          like ub.doc-line.price-rubl no-undo.
    define variable other-base-loco-prl             like ub.doc-line.price-base no-undo.
    define variable other-rubl-loco-prl             like ub.doc-line.price-rubl no-undo.
    define variable other-cli-loco-prl              like ub.doc-line.price-rubl no-undo.
    define variable exch-rate-cli-loco-prl          like ub.trn-doc.exch-rate   no-undo.
    define variable varinvatp-envdo-prl             as   character              no-undo.
    define variable varinvatp-typeo-prl             as   character              no-undo.
        run bcodepls-price in this-procedure (
            input  x-store-type,
            input  x-store-code,
            input  v-bar-code  ,
            input  0           ,
            input  fact-order-doc,
            output  parrecid-prl ,
            output  v-cli-base-rate )
        no-error .
              if error-status :error then do:
                message
                  vss-workfile vss-revision vss-description skip
                  "Ошибка при определении цены бар-кода" skip
                  "Объект" ub.gds-obj.obj-type ub.gds-obj.obj-code skip
                  "Бар-код" v-bar-code skip
                  "fact-order" fact-order-doc skip
                  error-status :get-message(1) skip
                  return-value skip
                  view-as alert-box error .
              end.
                 if parrecid-prl <> ? then do:
          run prl-vat in this-procedure
            (input  parrecid-prl
            ,output price-rubl-with-tax-sale-prl
            ,output price-base-with-tax-sale-prl
            ,output price-rubl-without-tax-sale-prl
            ,output price-base-without-tax-sale-prl
            ,output vat-base-sale-prl
            ,output vat-rubl-sale-prl
            ,output vat-base-buyer-prl
            ,output vat-rubl-buyer-prl
            ,output slt-base-sale-prl
            ,output slt-rubl-sale-prl
            ,output road-tax-base-sale-prl
            ,output road-tax-rubl-sale-prl
            ,output excise-base-sale-prl
            ,output excise-rubl-sale-prl
            ,output discnt-base-sale-prl
            ,output discnt-rubl-sale-prl
            ) no-error .
                if error-status :error then do:
                  message
                    vss-workfile vss-revision vss-description skip
                    "Ошибка при вызове процеды prl-vat" skip
                    "Документ" ub.doc-line.doc-code skip
                    "Артикул" ub.doc-line.artic ub.doc-line.prod-type ub.doc-line.prod-code skip
                    error-status :get-message(1) skip
                    return-value skip
                    view-as alert-box error .
                end.
        end.
        else do:
          assign
            price-rubl-with-tax-sale-prl    = 0
            price-base-with-tax-sale-prl    = 0
          .
        end.
  assign
    v-cur-base =  if var-report-r-b  = "rubl" then price-rubl-with-tax-sale-prl
                                              else  price-base-with-tax-sale-prl
  .
end procedure.
procedure price-prt :
define input parameter fact-order-doc    as decimal no-undo .
define output parameter p-qnty       as decimal no-undo .
define output parameter p-sale-sum   as decimal no-undo .
define variable v-price-sale as decimal no-undo .
  Assign
    p-qnty      = 0
    p-sale-sum  = 0   .
IF ub.goods.prt-root <> Prtroot or true = true  Then DO:
  run prdoclib-init-prt-obj-by-factord in this-procedure
( input x-store-type  ,
  input x-store-code  ,
  input ub.goods.artic     ,
  input ub.goods.prod-type ,
  input ub.goods.prod-code ,
  input fact-order-doc ,
  input false ) .
  for each ub.prt-obj where
      ub.prt-obj.artic     = ub.goods.artic     and
      ub.prt-obj.prod-type = ub.goods.prod-type and
      ub.prt-obj.prod-code = ub.goods.prod-code and
      ub.prt-obj.obj-code  = x-store-code and
      ub.prt-obj.obj-type  = x-store-type and
      ub.prt-obj.IS-term   =  true no-lock
            BREAK BY ub.prt-obj.prt-code  :
    IF last-of(ub.prt-obj.prt-code) THEN DO:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  ub.goods.gds-code
  ,input  ub.prt-obj.prt-code
  ,output v-bar-code
  )  .
                find first temp-prt-obj no-lock
                     where temp-prt-obj.prt-obj-recid   = recid (prt-obj) no-error .
                     if avail temp-prt-obj then do :
                       run calc-price-sale-for-prt in this-procedure  (input fact-order-doc , input v-bar-code ,output v-price-sale) .
                        Assign
                          p-qnty      = p-qnty     + temp-prt-obj.fact-qnty
                          p-sale-sum  = p-sale-sum + temp-prt-obj.fact-qnty * v-price-sale  .
                     End.
    End.
  End.
End.
end procedure.
procedure bcodepls-price :
  define input  parameter v-obj-type         like ub.price-list.obj-type    no-undo .
  define input  parameter v-obj-code         like ub.price-list.obj-code    no-undo .
  define input  parameter v-b-code           like ub.bar-code.b-code        no-undo .
  define input  parameter v-root-b-code      like ub.bar-code.b-code        no-undo .
  define input  parameter v-fact-order       like ub.price-doc.fact-order   no-undo .
  define output parameter v-recid-price-list as recid                       no-undo .
  define output parameter v-cli-base-rate    like ub.bar-code.cli-base-rate no-undo .
  define variable vss-description as character no-undo init "bcodepls-01: записи продажной цены признака".
  define buffer buf_root_bar-code   for ub.bar-code .
  define buffer buf_bar-code        for ub.bar-code .
  define buffer buf_root_price-list for ub.price-list .
  define buffer buf_price-list      for ub.price-list .
  define buffer buf_main_bar-code   for ub.bar-code .
  do
  on error undo, return error
  :
    find first buf_bar-code no-lock
      where buf_bar-code.b-code = v-b-code
      no-error .
    if not available buf_bar-code then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при задании входных параметров" skip
        "Не найден бар-код" v-b-code skip
        view-as alert-box error .
      undo, return error .
    end.
    assign
      v-cli-base-rate = buf_bar-code.cli-base-rate
    .
    if v-fact-order = ? then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при задании входных параметров" skip
        "Должен быть задан порядковый номер документа" skip
        "Для определения текущей цены он должен быть равен 0" skip
        "Порядковый номер документа" v-fact-order skip
        view-as alert-box error .
      undo, return error .
    end.
    if v-root-b-code = ? then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при задании входных параметров" skip
        "Должен быть задан бар-код корневого признака" skip
        "Или он должен быть равено 0" skip
        "Бар-код корневого признака" v-root-b-code skip
        view-as alert-box error .
      undo, return error .
    end.
    if v-root-b-code = 0 then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_bar-code.gds-code
  ,input  ?
  ,output v-root-b-code
  ) no-error .
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении корневого бар-кода для товара" skip
          "Код товара"  buf_bar-code.gds-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
    end.
    else do:
      define variable v-check-root-b-code like ub.bar-code.b-code no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_bar-code.gds-code
  ,input  ?
  ,output v-check-root-b-code
  ) no-error .
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении корневого бар-кода для товара" skip
          "Код товара"  buf_bar-code.gds-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
      if v-root-b-code <> v-check-root-b-code then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка задания входных параметров" skip
          "Код товара" buf_bar-code.gds-code skip
          "Основной бар-код товара" v-check-root-b-code skip
          "В качестве параметра передано" v-root-b-code skip
          view-as alert-box error .
        undo, return error .
      end.
    end.
    find first buf_root_bar-code no-lock
      where buf_root_bar-code.b-code = v-root-b-code
      no-error .
    if not available buf_root_bar-code then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найден бар-код корневого признака" skip
        "Код товара" buf_bar-code.gds-code skip
        "Бар-код" v-root-b-code skip
        view-as alert-box error .
      undo, return error .
    end.
    if buf_root_bar-code.gds-code <> buf_bar-code.gds-code
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "В качеcтве параметров указаны бар-коды разных товаров" skip
        "Бар-код" buf_bar-code.b-code skip
        "Код товара" buf_bar-code.gds-code skip
        "Бар-код корневого признака" buf_root_bar-code.b-code skip
        "Код товара в бар-коде корневого признака" buf_root_bar-code.gds-code skip
        view-as alert-box error .
      undo, return error .
    end.
    if v-fact-order = 0 then do:
      find last buf_root_price-list no-lock
        where buf_root_price-list.obj-type   = v-obj-type
          and buf_root_price-list.obj-code   = v-obj-code
          and buf_root_price-list.b-code     = v-root-b-code
          and buf_root_price-list.price-type = ""
        use-index fact-close
        no-error.
    end.
    else do:
      find last buf_root_price-list no-lock
        where buf_root_price-list.obj-type   = v-obj-type
          and buf_root_price-list.obj-code   = v-obj-code
          and buf_root_price-list.b-code     = v-root-b-code
          and buf_root_price-list.price-type = ""
          and buf_root_price-list.fact-order <= v-fact-order
        use-index fact-close
        no-error.
    end.
    if  available buf_root_price-list
    and buf_root_price-list.fact-order <> 0 then do:
      if v-b-code = v-root-b-code then do:
        assign
          v-recid-price-list = recid(buf_root_price-list)
          v-cli-base-rate    = 1
        .
        return .
      end.
      else do:
        find first buf_price-list no-lock
          where buf_price-list.doc-num    = buf_root_price-list.doc-num
            and buf_price-list.b-code     = v-b-code
            and buf_price-list.price-type = ""
          no-error.
        if available buf_price-list then do:
          assign
            v-recid-price-list = recid(buf_price-list)
            v-cli-base-rate    = 1
          .
          return .
        end.
        if buf_bar-code.unit-cli = buf_root_bar-code.unit-cli then do:
          assign
            v-recid-price-list = recid(buf_root_price-list)
            v-cli-base-rate    = 1
          .
          return .
        end.
        else do:
          define variable v-is-new as logical no-undo .
define variable vss-include-info57 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run barcodcr in g#library
  (input  buf_bar-code.gds-code
  ,input  buf_bar-code.node-code
  ,input  buf_bar-code.part-code
  ,input  buf_bar-code.in-code
  ,input  buf_root_bar-code.unit-cli
  ,input  1
  ,output v-is-new
  ,buffer buf_main_bar-code
  ) no-error .
          if error-status :error then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при поиске бар-кода" skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error .
          end.
          find first buf_price-list no-lock
            where buf_price-list.doc-num    = buf_root_price-list.doc-num
              and buf_price-list.b-code     = buf_main_bar-code.b-code
              and buf_price-list.price-type = ""
            no-error.
          if available buf_price-list then do:
            assign
              v-recid-price-list = recid(buf_price-list)
            .
            return .
          end.
          else do:
            assign
              v-recid-price-list = recid(buf_root_price-list)
            .
            return .
          end.
        end.
      end.
    end.
    else do:
      assign
        v-recid-price-list = ?
        v-cli-base-rate    = ?
      .
      return .
    end.
    message
      vss-workfile vss-revision vss-description skip
      "Внутренняя ошибка при определении цены бар-кода" skip
      "Бар-код"    buf_bar-code.b-code skip
      "Код товара" buf_bar-code.gds-code skip
      "recid(root_price-list)" recid(buf_root_price-list) skip
      "recid(price-list)"      recid(buf_price-list) skip
      view-as alert-box error .
    undo, return error .
  end.
end procedure.
procedure local-fchg-qnty :
define input  parameter parrec-line as   recid              no-undo.
define output parameter parqnty     like ub.parts.fact-qnty no-undo.
define buffer local-doc-line for ub.doc-line.
define buffer local-parts     for ub.parts.
find first local-doc-line where recid(local-doc-line) = parrec-line no-lock.
for each local-parts where
         local-parts.out-code  = local-doc-line.doc-code
     and local-parts.obj-type  = local-doc-line.obj-type
     and local-parts.obj-code  = local-doc-line.obj-code
     and local-parts.artic     = local-doc-line.artic
     and local-parts.prod-type = local-doc-line.prod-type
     and local-parts.prod-code = local-doc-line.prod-code
     and local-parts.in-code   = local-doc-line.doc-code   no-lock :
   assign
     parqnty = parqnty + local-parts.fact-qnty.
end.
end procedure.
