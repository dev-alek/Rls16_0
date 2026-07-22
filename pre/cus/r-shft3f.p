block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-shft3f.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/r-shft3f.p $":U .
define variable vss-description as character no-undo init "Расшифровка реализации к сменному отчету".
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
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
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    undo, return error substitute( "&1. &2&3&4", vss-include-info12, return-value, chr(10), error-status :get-message (1)).
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
    undo, return error substitute( "&1. &2&3&4", vss-include-info12, return-value, chr(10), error-status :get-message (1)).
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
define variable parparentproc     as widget-handle no-undo.
assign parparentproc =  my-handle .
define variable g#report-num as integer no-undo .
run get-report-num  in parparentproc (output  g#report-num).
def var vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info15 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define stream excel-line.
define stream excel-cell.
define temp-table temp_cell-data no-undo
    field data-key as character
    field data-value as character
    index pi is primary unique data-key
.
define temp-table temp_sheet1_line-data no-undo
    field sheet-name    as character
    field xl-line-id    as integer
    field name   as character
    field DT_l   as character
    field DT_s   as character
    field AI80_l as character
    field AI80_s as character
    field AI92_l as character
    field AI92_s as character
    field AI95_l as character
    field AI95_s as character
    field AI98_l as character
    field AI98_s as character
    field SUG_l  as character
    field SUG_s  as character
    field all_l  as character
    field all_s  as character
    index pi is primary unique
        xl-line-id
.
define variable v-shift3xl-sheet1-cur-data-row     as integer      no-undo.
define variable v-shift3xl-cell-file-name       as character    no-undo.
define variable v-shift3xl-data-file-name       as character    no-undo.
procedure shift3xl-init :
do
on error undo, return error
:
    assign
        v-shift3xl-sheet1-cur-data-row = 0
    .
    run gbl/_tmpfile.p (
          input "xd"
        , input ".txt"
        , output v-shift3xl-data-file-name
    ).
    output stream excel-line to value( v-shift3xl-data-file-name ).
    run gbl/_tmpfile.p (
          input "xc"
        , input ".txt"
        , output v-shift3xl-cell-file-name
    ).
    output stream excel-cell to value( v-shift3xl-cell-file-name ).
    run shift3xl-write-cell-data in this-procedure (
          input "sheetList":U
        , input "Реализация":U
    ).
    run shift3xl-write-cell-data in this-procedure (
          input "Реализация_valutCode":U
        , input "0":U
    ).
    run shift3xl-write-cell-data in this-procedure (
          input "Реализация_columnList":U
        , input "name,DT_l,DT_s,AI80_l,AI80_s,AI92_l,AI92_s,AI95_l,AI95_s,AI98_l,AI98_s,SUG_l,SUG_s,all_l,all_s"
    ).
    run shift3xl-write-cell-data in this-procedure (
          input "Реализация_columnType":U
        , input "S,S,S,S,S,S,S,S,S,S,S,S,S,S,S":U
    ).
    run shift3xl-write-cell-data in this-procedure (
          input "Реализация_subtotalList":U
        , input "":U
    ).
    run shift3xl-write-cell-data in this-procedure (
          input "Реализация_subtotalType":U
        , input "":U
    ).
end.
end procedure.
procedure shift3xl-sheet1-write-line-data :
define input parameter p-name     as character        no-undo.
define input parameter p-DT_l     as character        no-undo.
define input parameter p-DT_s     as character        no-undo.
define input parameter p-AI80_l   as character        no-undo.
define input parameter p-AI80_s   as character        no-undo.
define input parameter p-AI92_l   as character        no-undo.
define input parameter p-AI92_s   as character        no-undo.
define input parameter p-AI95_l   as character        no-undo.
define input parameter p-AI95_s   as character        no-undo.
define input parameter p-AI98_l   as character        no-undo.
define input parameter p-AI98_s   as character        no-undo.
define input parameter p-SUG_l    as character        no-undo.
define input parameter p-SUG_s    as character        no-undo.
define input parameter p-all_l    as character        no-undo.
define input parameter p-all_s    as character        no-undo.
    define buffer buf_temp_sheet1_line-data        for temp_sheet1_line-data.
do
for buf_temp_sheet1_line-data
on error undo, return error
:
    for each buf_temp_sheet1_line-data
    :
        delete buf_temp_sheet1_line-data.
    end.
    create buf_temp_sheet1_line-data.
    assign
        v-shift3xl-sheet1-cur-data-row = v-shift3xl-sheet1-cur-data-row + 1
        buf_temp_sheet1_line-data.sheet-name    = "Реализация":U
        buf_temp_sheet1_line-data.xl-line-id    = v-shift3xl-sheet1-cur-data-row
        buf_temp_sheet1_line-data.name    = p-name
        buf_temp_sheet1_line-data.DT_l    = p-DT_l
        buf_temp_sheet1_line-data.DT_s    = p-DT_s
        buf_temp_sheet1_line-data.AI80_l  = p-AI80_l
        buf_temp_sheet1_line-data.AI80_s  = p-AI80_s
        buf_temp_sheet1_line-data.AI92_l  = p-AI92_l
        buf_temp_sheet1_line-data.AI92_s  = p-AI92_s
        buf_temp_sheet1_line-data.AI95_l  = p-AI95_l
        buf_temp_sheet1_line-data.AI95_s  = p-AI95_s
        buf_temp_sheet1_line-data.AI98_l  = p-AI98_l
        buf_temp_sheet1_line-data.AI98_s  = p-AI98_s
        buf_temp_sheet1_line-data.SUG_l   = p-SUG_l
        buf_temp_sheet1_line-data.SUG_s   = p-SUG_s
        buf_temp_sheet1_line-data.all_l   = p-all_l
        buf_temp_sheet1_line-data.all_s   = p-all_s
    .
    put stream excel-line unformatted
                        buf_temp_sheet1_line-data.sheet-name
        CHR(9)   "DTA":U
        CHR(9)   buf_temp_sheet1_line-data.name
        CHR(9)   buf_temp_sheet1_line-data.DT_l
        CHR(9)   buf_temp_sheet1_line-data.DT_s
        CHR(9)   buf_temp_sheet1_line-data.AI80_l
        CHR(9)   buf_temp_sheet1_line-data.AI80_s
        CHR(9)   buf_temp_sheet1_line-data.AI92_l
        CHR(9)   buf_temp_sheet1_line-data.AI92_s
        CHR(9)   buf_temp_sheet1_line-data.AI95_l
        CHR(9)   buf_temp_sheet1_line-data.AI95_s
        CHR(9)   buf_temp_sheet1_line-data.AI98_l
        CHR(9)   buf_temp_sheet1_line-data.AI98_s
        CHR(9)   buf_temp_sheet1_line-data.SUG_l
        CHR(9)   buf_temp_sheet1_line-data.SUG_s
        CHR(9)   buf_temp_sheet1_line-data.all_l
        CHR(9)   buf_temp_sheet1_line-data.all_s
        chr(10)
    .
end.
end procedure.
procedure shift3xl-write-cell-data :
define input parameter p-data-key   as character        no-undo.
define input parameter p-data-value as character        no-undo.
    define buffer buf_temp_cell-data     for temp_cell-data.
do
for buf_temp_cell-data
on error undo, return error
:
    find first buf_temp_cell-data
         where buf_temp_cell-data.data-key = p-data-key
    no-error.
    if not available buf_temp_cell-data
    then do:
        create buf_temp_cell-data.
        assign
            buf_temp_cell-data.data-key = p-data-key
        .
    end.
    assign
        buf_temp_cell-data.data-value = p-data-value
    .
    put stream excel-cell unformatted
                        buf_temp_cell-data.data-key
        CHR(9)   buf_temp_cell-data.data-value
        chr(10)
    .
end.
end procedure.
procedure shift3xl-run-excel :
define input parameter p-header-filename    as character        no-undo.
define input parameter p-data-filename      as character        no-undo.
    define variable v-template-file-name    as character    no-undo.
    define variable v-vb-file-name          as character    no-undo.
    define buffer buf_temp-param for temp-param .
do
for buf_temp-param
on error undo, return error
:
    create buf_temp-param.
    assign
        v-template-file-name    = search( "exe/shift3.xlt" )
        v-vb-file-name          = search( "exe/t_form.bas")
    .
    if v-template-file-name = ?
    or v-template-file-name = "":U
    then do:
        message
            "Ошибка имени файла шаблона."
        view-as alert-box error.
    end.
    if v-vb-file-name = ?
    or v-vb-file-name = "":U
    then do:
        message
            "Ошибка имени файла кода обработки."
        view-as alert-box error.
    end.
    run paramls-write in this-procedure (
          input "template":U
        , input "template-file-name":U
        , input v-template-file-name
    ).
    run paramls-write in this-procedure (
          input "template":U
        , input "vb-file-name":U
        , input v-vb-file-name
    ).
    run paramls-write in this-procedure (
          input "data":U
        , input "data-header-filename":U
        , input p-header-filename
    ).
    run paramls-write in this-procedure (
          input "data":U
        , input "data-filename":U
        , input p-data-filename
    ).
    run gbl/macroxlt.p (
        input-output table buf_temp-param
    ) no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip "Ошибка создания файла Excel."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
end.
end procedure.
procedure shift3xl-close :
do
on error undo, return error
:
    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append.
    export "exe/shift3.xlt":U.
    export "exe/t_form.bas":U.
    export v-shift3xl-cell-file-name.
    export v-shift3xl-data-file-name.
    output close.
end.
end procedure.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
procedure cp-attr-code :
  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo .
    define output parameter p-type           as character no-undo .
    define output parameter p-format         as character no-undo .
    define output parameter p-label          as character no-undo .
    define output parameter p-range          as integer   no-undo .
    define output parameter p-user-can-edit  as logical   no-undo .
    define output parameter p-output-display as logical   no-undo .
    define output parameter p-other          as character no-undo .
    case p-code :
            when 'paycard-export-prefix':U then do:     assign     p-label = "Префиксы платежных карт (для выгрузки в XML)"     p-type = 'C':U      p-format = "X(19)"     p-label = "Префиксы платежных карт (для выгрузки в XML)"     p-range = 0     p-user-can-edit  = true     p-output-display = true     p-other = 'spr=paycard-prefix':u      .   end.
            when 'grp-code':U then do:     assign     p-label = "Группа платежа"     p-type = 'C':U      p-format = "X(45)"     p-label = "Группа платежа"     p-range = 0     p-user-can-edit  = true     p-output-display = true     p-other = 'spr=grp-code':u      .   end.
            when 'is-use':U then do:     assign     p-label = "Используется"     p-type = 'C':U      p-format = "X(255)"     p-label = "Используется"     p-range = 4     p-user-can-edit  = true     p-output-display = true     p-other = 'spr=is-use':u      .   end.
            when 'dop-doc':U then do:     assign     p-label = "Дополнительный документ"     p-type = 'C':U      p-format = "X(255)"     p-label = "Дополнительный документ"     p-range = 0     p-user-can-edit  = true     p-output-display = true     p-other = 'spr=dop-doc':u      .   end.
            when 'paycard-all-prefix':U then do:     assign     p-label = "Префиксы платежных карт (для разбора чеков и т.д.)"     p-type = 'C':U      p-format = "X(19)"     p-label = "Префиксы платежных карт (для разбора чеков и т.д.)"     p-range = 0     p-user-can-edit  = true     p-output-display = true     p-other = 'spr=paycard-prefix':u      .   end.
            when 'paycard-edit-prefix':U then do:     assign     p-label = "Префиксы платежных карт, разрешенных для редактирования"     p-type = 'C':U      p-format = "X(19)"     p-label = "Префиксы платежных карт, разрешенных для редактирования"     p-range = 0     p-user-can-edit  = true     p-output-display = true     p-other = 'spr=paycard-prefix':u      .   end.
            when 'form_km3':U then do:     assign     p-label = "Формировать КМ-3 по чекам возврата"     p-type = 'L':U      p-format = "+/-"     p-label = "Формировать КМ-3 по чекам возврата"     p-range = 0     p-user-can-edit  = true     p-output-display = true     p-other = '':u      .   end.
            when 'bal_malina':U then do:     assign     p-label = "Оплата баллами Малина"     p-type = 'L':U      p-format = "+/-"     p-label = "Оплата баллами Малина"     p-range = 0     p-user-can-edit  = true     p-output-display = true     p-other = '':u      .   end.
            when 'max_proc_sum':U then do:     assign     p-label = "Максимальный % порог от суммы"     p-type = 'D':U      p-format = ">>9.99"     p-label = "Максимальный % порог от суммы"     p-range = 0     p-user-can-edit  = true     p-output-display = true     p-other = '':u      .   end.
            when 'mask_card_kup':U then do:     assign     p-label = "Маска карты\купона"     p-type = 'C':U      p-format = "x(129)"     p-label = "Маска карты\купона"     p-range = 0     p-user-can-edit  = true     p-output-display = true     p-other = '':u      .   end.
      otherwise do:
        undo, return error substitute("неизвестный атрибут типа кассового платежа &1", p-code ).
      end.
    end.
  end.
end procedure.
procedure cp-attr-tooltip :
  do
  on error undo, return error
  :
    define input  parameter p-code    as character no-undo .
    define output parameter p-tooltip as character no-undo .
    define output parameter p-label   as character no-undo .
    case p-code :
            when 'paycard-export-prefix':U then do:     assign     p-tooltip = "Префиксы платежных карт (для выгрузки в XML)"     p-label = "Префиксы платежных карт (для выгрузки в XML)" .   end.
            when 'grp-code':U then do:     assign     p-tooltip = "Группа платежа"     p-label = "Группа платежа" .   end.
            when 'is-use':U then do:     assign     p-tooltip = "Используется"     p-label = "Используется" .   end.
            when 'dop-doc':U then do:     assign     p-tooltip = "Дополнительный документ"     p-label = "Дополнительный документ" .   end.
            when 'paycard-all-prefix':U then do:     assign     p-tooltip = "Префиксы платежных карт (для разбора чеков и т.д.)"     p-label = "Префиксы платежных карт (для разбора чеков и т.д.)" .   end.
            when 'paycard-edit-prefix':U then do:     assign     p-tooltip = "Префиксы платежных карт, разрешенных для редактировани"     p-label = "Префиксы платежных карт, разрешенных для редактирования" .   end.
            when 'form_km3':U then do:     assign     p-tooltip = "Формировать КМ-3 по чекам возврата"     p-label = "Формировать КМ-3 по чекам возврата" .   end.
            when 'bal_malina':U then do:     assign     p-tooltip = "Оплата баллами Малина"     p-label = "Оплата баллами Малина" .   end.
            when 'max_proc_sum':U then do:     assign     p-tooltip = "Максимальный % порог от суммы"     p-label = "Максимальный % порог от суммы" .   end.
            when 'mask_card_kup':U then do:     assign     p-tooltip = "Маска карты\купона"     p-label = "Маска карты\купона" .   end.
      otherwise do:
        undo, return error substitute("неизвестный атрибут типа кассового платежа &1", p-code) .
      end.
    end.
  end.
end procedure.
procedure cp-attr-value :
  do
  on error undo, return error
  :
    define input parameter p-cdpay-code   like ub.cash-pay-attr.cdpay-code     no-undo .
    define input parameter p-curr-code    like ub.cash-pay-attr.curr-code      no-undo .
    define input parameter p-host-code    like ub.cash-pay-attr.host-code      no-undo .
    define input parameter p-obj-type     like ub.cash-pay-attr.obj-type       no-undo .
    define input parameter p-obj-code     like ub.cash-pay-attr.obj-code       no-undo .
    define input  parameter p-code        like ub.cash-pay-attr.attr-code      no-undo .
    define output parameter p-value       like ub.cash-pay-attr.attr-value    no-undo .
    define output parameter p-type        as character no-undo .
    define buffer buf_cash-pay-attr for ub.cash-pay-attr .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-range          as integer   no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run cp-attr-code in this-procedure
      (input  p-code
      ,output p-type
      ,output v-format
      ,output v-label
      ,output v-range
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_cash-pay-attr no-lock
      where buf_cash-pay-attr.cdpay-code = p-cdpay-code
        and buf_cash-pay-attr.curr-code  = p-curr-code
        and buf_cash-pay-attr.host-code  = p-host-code
        and buf_cash-pay-attr.obj-type   = p-obj-type
        and buf_cash-pay-attr.obj-code   = p-obj-code
        and buf_cash-pay-attr.attr-code  = p-code
      no-error .
    if avail buf_cash-pay-attr then do:
      assign
        p-value =  buf_cash-pay-attr.attr-value
      .
    end.
    else do:
      assign
        p-value = if p-type = 'L':U then "no":U else ""
      .
    end.
  end.
end procedure.
procedure cp-attr-write :
  do
  on error undo, return error
  :
    define input parameter p-cdpay-code   like ub.cash-pay-attr.cdpay-code     no-undo .
    define input parameter p-curr-code    like ub.cash-pay-attr.curr-code      no-undo .
    define input parameter p-host-code    like ub.cash-pay-attr.host-code      no-undo .
    define input parameter p-obj-type     like ub.cash-pay-attr.obj-type       no-undo .
    define input parameter p-obj-code     like ub.cash-pay-attr.obj-code       no-undo .
    define input parameter p-code     like ub.cash-pay-attr.attr-code  no-undo .
    define input parameter p-value    like ub.cash-pay-attr.attr-value no-undo .
    define buffer buf_cash-pay-attr for ub.cash-pay-attr .
    define buffer last_cash-pay-attr for ub.cash-pay-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-range          as integer   no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run cp-attr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-range
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_cash-pay-attr exclusive-lock
      where buf_cash-pay-attr.cdpay-code = p-cdpay-code
        and buf_cash-pay-attr.curr-code  = p-curr-code
        and buf_cash-pay-attr.host-code  = p-host-code
        and buf_cash-pay-attr.obj-type   = p-obj-type
        and buf_cash-pay-attr.obj-code   = p-obj-code
        and buf_cash-pay-attr.attr-code = p-code
      no-error .
    if not available buf_cash-pay-attr then do:
      create buf_cash-pay-attr .
      assign
      buf_cash-pay-attr.cdpay-code = p-cdpay-code
      buf_cash-pay-attr.curr-code  = p-curr-code
      buf_cash-pay-attr.host-code  = p-host-code
      buf_cash-pay-attr.obj-type   = p-obj-type
      buf_cash-pay-attr.obj-code   = p-obj-code
      buf_cash-pay-attr.attr-code = p-code
      .
    end.
    assign
      buf_cash-pay-attr.attr-value = p-value
    .
    release buf_cash-pay-attr no-error .
    if error-status:error then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cp-attr-exist :
  do
  on error undo, return error
  :
    define input parameter p-cdpay-code   like ub.cash-pay-attr.cdpay-code     no-undo .
    define input parameter p-curr-code    like ub.cash-pay-attr.curr-code      no-undo .
    define input parameter p-host-code    like ub.cash-pay-attr.host-code      no-undo .
    define input parameter p-obj-type     like ub.cash-pay-attr.obj-type       no-undo .
    define input parameter p-obj-code     like ub.cash-pay-attr.obj-code       no-undo .
    define input parameter p-code     like ub.cash-pay-attr.attr-code  no-undo .
    define output parameter p-exist   as logical  no-undo .
    define buffer buf_cash-pay-attr for ub.cash-pay-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-range          as integer   no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run cp-attr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-range
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_cash-pay-attr exclusive-lock
      where buf_cash-pay-attr.cdpay-code = p-cdpay-code
        and buf_cash-pay-attr.curr-code  = p-curr-code
        and buf_cash-pay-attr.host-code  = p-host-code
        and buf_cash-pay-attr.obj-type   = p-obj-type
        and buf_cash-pay-attr.obj-code   = p-obj-code
        and buf_cash-pay-attr.attr-code = p-code
      no-error .
    if  available buf_cash-pay-attr then do:
      p-exist = yes.
    end.
  end.
end procedure.
procedure cp-attr-delete :
  do
  on error undo, return error
  :
    define input parameter p-cdpay-code   like ub.cash-pay-attr.cdpay-code     no-undo .
    define input parameter p-curr-code    like ub.cash-pay-attr.curr-code      no-undo .
    define input parameter p-host-code    like ub.cash-pay-attr.host-code      no-undo .
    define input parameter p-obj-type     like ub.cash-pay-attr.obj-type       no-undo .
    define input parameter p-obj-code     like ub.cash-pay-attr.obj-code       no-undo .
    define input parameter p-code     like ub.cash-pay-attr.attr-code  no-undo .
    define output parameter p-deleted  as logical no-undo.
    define buffer buf_cash-pay-attr for ub.cash-pay-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-range          as integer   no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run cp-attr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-range
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_cash-pay-attr exclusive-lock
      where buf_cash-pay-attr.cdpay-code = p-cdpay-code
        and buf_cash-pay-attr.curr-code  = p-curr-code
        and buf_cash-pay-attr.host-code  = p-host-code
        and buf_cash-pay-attr.obj-type   = p-obj-type
        and buf_cash-pay-attr.obj-code   = p-obj-code
        and buf_cash-pay-attr.attr-code = p-code
      no-error NO-WAIT.
    if not available buf_cash-pay-attr then do:
      p-deleted = no.
    end.
    else do:
      delete buf_cash-pay-attr no-error .
      if error-status:error then do:
        undo, return error return-value .
      end.
      p-deleted = yes.
    end.
  end.
end procedure.
procedure cp-attr-news :
  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo .
    define output parameter p-news           as logical   no-undo .
    case p-code :
            when 'paycard-export-prefix':U then do:     assign     p-news = true.   end.
            when 'grp-code':U then do:     assign     p-news = true.   end.
            when 'is-use':U then do:     assign     p-news = true.   end.
            when 'dop-doc':U then do:     assign     p-news = true.   end.
            when 'paycard-all-prefix':U then do:     assign     p-news = true.   end.
            when 'paycard-edit-prefix':U then do:     assign     p-news = true.   end.
            when 'form_km3':U then do:     assign     p-news = false.   end.
            when 'bal_malina':U then do:     assign     p-news = false.   end.
            when 'max_proc_sum':U then do:     assign     p-news = true.   end.
            when 'mask_card_kup':U then do:     assign     p-news = true.   end.
      otherwise do:
        p-news = no.
      end.
    end.
  end.
end procedure.
procedure cp-attr-hist :
  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo .
    define output parameter p-hist           as logical   no-undo .
    case p-code :
            when 'paycard-export-prefix':U then do:     assign     p-hist = true.   end.
            when 'paycard-all-prefix':U then do:     assign     p-hist = true.   end.
            when 'paycard-edit-prefix':U then do:     assign     p-hist = true.   end.
            when 'form_km3':U then do:     assign     p-hist = true.   end.
            when 'bal_malina':U then do:     assign     p-hist = true.   end.
            when 'max_proc_sum':U then do:     assign     p-hist = true.   end.
            when 'mask_card_kup':U then do:     assign     p-hist = true.   end.
      otherwise do:
        p-hist = no.
      end.
    end.
  end.
end procedure.
procedure paycard-prefix :
define input parameter p-cdpay-code like ub.cash-pay-attr.cdpay-code no-undo .
define input parameter p-curr-code like ub.cash-pay-attr.curr-code no-undo .
define input parameter p-host-code like ub.cash-pay-attr.host-code no-undo .
define input parameter p-obj-type like ub.cash-pay-attr.obj-type no-undo .
define input parameter p-obj-code like ub.cash-pay-attr.obj-code no-undo .
define input-output parameter p-value as character no-undo .
define output parameter p-setted as logical no-undo .
DEFINE VARIABLE v-value as character no-undo .
define variable v-codes as character no-undo .
define variable v-labels as character no-undo .
define variable v-ok as logical no-undo .
  do
  on error undo, return error
  :
    assign
    v-value = p-value
    .
    run ref/cpa-pcep.w (
                   input parparentproc
                  ,input p-cdpay-code
                  ,input p-curr-code
                  ,input p-host-code
                  ,input p-obj-type
                  ,input p-obj-code
                  ,input-output v-value
                  ,output v-ok
                   ) no-error .
    if
    v-ok and
    p-value <> v-value and v-value <> ? and not error-status:error then do:
      assign
      p-setted = yes
      p-value = v-value
      .
    end.
  end.
end procedure.
procedure is-use :
define input parameter p-cdpay-code like ub.cash-pay-attr.cdpay-code no-undo .
define input parameter p-curr-code like ub.cash-pay-attr.curr-code no-undo .
define input parameter p-host-code like ub.cash-pay-attr.host-code no-undo .
define input parameter p-obj-type like ub.cash-pay-attr.obj-type no-undo .
define input parameter p-obj-code like ub.cash-pay-attr.obj-code no-undo .
define input-output parameter p-value as character no-undo .
define output parameter p-setted as logical no-undo .
DEFINE VARIABLE v-value as character no-undo .
define variable v-codes as character no-undo .
define variable v-labels as character no-undo .
define variable v-ok as logical no-undo .
  do
  on error undo, return error
  :
    assign
    v-value = p-value
    .
    if p-obj-type = 'скл':U then do:
      message
      substitute("Нельзя задать атрибут для объекта типа &1", p-obj-type)
      view-as alert-box error .
      return error.
    end.
    run ref/cpa-isus.w (
                   input parparentproc
                  ,input p-cdpay-code
                  ,input p-curr-code
                  ,input p-host-code
                  ,input p-obj-type
                  ,input p-obj-code
                  ,input-output v-value
                  ,output v-ok
                   ) no-error .
    if
    v-ok and
    p-value <> v-value and v-value <> ? and not error-status:error then do:
      assign
      p-setted = yes
      p-value = v-value
      .
    end.
  end.
end procedure.
procedure grp-code :
define input parameter p-cdpay-code like ub.cash-pay-attr.cdpay-code no-undo .
define input parameter p-curr-code like ub.cash-pay-attr.curr-code no-undo .
define input parameter p-host-code like ub.cash-pay-attr.host-code no-undo .
define input parameter p-obj-type like ub.cash-pay-attr.obj-type no-undo .
define input parameter p-obj-code like ub.cash-pay-attr.obj-code no-undo .
define input-output parameter p-value as character no-undo .
define output parameter p-setted as logical no-undo .
DEFINE VARIABLE v-value as character no-undo .
define variable v-codes as character no-undo .
define variable v-labels as character no-undo .
define variable v-ok as logical no-undo .
  do
  on error undo, return error
  :
    assign
    v-value = p-value
    .
    run ref/cpa-grp.w (
                   input parparentproc
                  ,input p-cdpay-code
                  ,input p-curr-code
                  ,input p-host-code
                  ,input p-obj-type
                  ,input p-obj-code
                  ,input-output v-value
                  ,output v-ok
                   ) no-error .
    if
    v-ok and
    p-value <> v-value and v-value <> ? and not error-status:error then do:
      assign
      p-setted = yes
      p-value = v-value
      .
    end.
  end.
end procedure.
procedure cp-attr-manual-edit :
do on error undo, return error return-value
  :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
    case p-code :
            when 'paycard-export-prefix':U then do:     assign     p-section-num = 1.   end.
            when 'grp-code':U then do:     assign     p-section-num = 1.   end.
            when 'is-use':U then do:     assign     p-section-num = 1.   end.
            when 'dop-doc':U then do:     assign     p-section-num = 1.   end.
            when 'paycard-all-prefix':U then do:     assign     p-section-num = 1.   end.
            when 'form_km3':U then do:     assign     p-section-num = 1.   end.
            when 'bal_malina':U then do:     assign     p-section-num = 1.   end.
            when 'max_proc_sum':U then do:     assign     p-section-num = 1.   end.
            when 'mask_card_kup':U then do:     assign     p-section-num = 1.   end.
      otherwise do:
        undo, return error substitute("неизвестный атрибут типа кассового платежа &1", p-code ).
      end.
    end.
  end.
end procedure.
procedure cp-attr-batch-edit :
do
  on error undo, return error
  :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
    case p-code :
            when 'paycard-export-prefix':U then do:     assign     p-section-num = 0.   end.
            when 'grp-code':U then do:     assign     p-section-num = 0.   end.
            when 'is-use':U then do:     assign     p-section-num = 0.   end.
            when 'dop-doc':U then do:     assign     p-section-num = 0.   end.
            when 'form_km3':U then do:     assign     p-section-num = 0.   end.
            when 'bal_malina':U then do:     assign     p-section-num = 0.   end.
            when 'max_proc_sum':U then do:     assign     p-section-num = 0.   end.
            when 'mask_card_kup':U then do:     assign     p-section-num = 0.   end.
      otherwise do:
        undo, return error substitute("неизвестный атрибут типа кассового платежа &1", p-code ).
      end.
    end.
  end.
end procedure.
procedure dop-doc :
define input parameter p-cdpay-code like ub.cash-pay-attr.cdpay-code no-undo .
define input parameter p-curr-code like ub.cash-pay-attr.curr-code no-undo .
define input parameter p-host-code like ub.cash-pay-attr.host-code no-undo .
define input parameter p-obj-type like ub.cash-pay-attr.obj-type no-undo .
define input parameter p-obj-code like ub.cash-pay-attr.obj-code no-undo .
define input-output parameter p-value as character no-undo .
define output parameter p-setted as logical no-undo .
DEFINE VARIABLE v-value as character no-undo .
define variable v-codes as character no-undo .
define variable v-labels as character no-undo .
define variable v-ok as logical no-undo .
  do on error undo, return error:
    assign
    v-value = p-value.
    run ref/cpa-dop-doc.w (
                   input parparentproc
                  ,input p-cdpay-code
                  ,input p-curr-code
                  ,input p-host-code
                  ,input p-obj-type
                  ,input p-obj-code
                  ,input-output v-value
                  ,output v-ok
                   ) no-error .
    if
    v-ok and
    p-value <> v-value and v-value <> ? and not error-status:error then do:
      assign
      p-setted = yes
      p-value = v-value
      .
    end.
  end.
end procedure.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE stream out-stream .
FUNCTION get-grp-name RETURNS integer
  ( INPUT p-cdpay-code AS integer, INPUT p-curr-code AS INTEGER ) :
   DEFINE VARIABLE v-dopi  as integer   no-undo .
   DEFINE VARIABLE v-value AS character NO-UNDO.
   DEFINE VARIABLE v-type  AS character NO-UNDO.
     RUN cp-attr-value  IN THIS-PROCEDURE(
       input p-cdpay-code
       ,input p-curr-code
       ,input 0
       ,input '':U
       ,input 0
       ,INPUT 'grp-code':U
       ,output v-value
       ,OUTPUT v-type) NO-ERROR.
  IF NOT ERROR-STATUS:ERROR THEN DO:
    ASSIGN
      v-dopi = INTEGER(entry(2, v-value, chr(4)))
    NO-ERROR.
  END.
  RETURN v-dopi.
END FUNCTION.
define temp-table temp-gds no-undo
  FIELD artic     as character
  FIELD prod-type as character
  FIELD prod-code as integer
  FIELD gds-code  as integer
  FIELD b-code    as integer
  FIELD num       as integer
  INDEX ii IS UNIQUE num
  INDEX ii1 IS UNIQUE  artic   prod-type  prod-code
  INDEX ii2 b-code
  INDEX ii3 gds-code
.
define temp-table temp-sale no-undo
  FIELD val1     as decimal
  FIELD sum1     as decimal
  FIELD val2     as decimal
  FIELD sum2     as decimal
  FIELD val3     as decimal
  FIELD sum3     as decimal
  FIELD val4     as decimal
  FIELD sum4     as decimal
  FIELD val5     as decimal
  FIELD sum5     as decimal
  FIELD val6     as decimal
  FIELD sum6     as decimal
  FIELD val-all  as decimal
  FIELD sum-all  as decimal
  FIELD name     as character
  FIELD code     as integer
  FIELD grp      as integer
  FIELD is-nal   as logical
  INDEX ii IS UNIQUE code
  INDEX ii1  grp
.
define temp-table temp-grp no-undo
  FIELD val1     as decimal
  FIELD sum1     as decimal
  FIELD val2     as decimal
  FIELD sum2     as decimal
  FIELD val3     as decimal
  FIELD sum3     as decimal
  FIELD val4     as decimal
  FIELD sum4     as decimal
  FIELD val5     as decimal
  FIELD sum5     as decimal
  FIELD val6     as decimal
  FIELD sum6     as decimal
  FIELD val-all  as decimal
  FIELD sum-all  as decimal
  FIELD name     as character
  FIELD code     as integer
  FIELD num      as integer
  INDEX ii IS UNIQUE num
  INDEX ii1  code
  INDEX ii2  name
.
define variable v-itog-bn   as decimal extent 14 no-undo .
define variable v-itog-sale as decimal extent 14 no-undo .
define variable v-teh       as decimal extent 14 no-undo .
define variable v-counter   as decimal extent 14 no-undo .
define variable v-b-code    as integer no-undo .
  define variable Counter1    as integer   no-undo .
  define variable v-ind      as integer   no-undo .
  define variable v-str      as character no-undo .
  define variable v-is-petrol as logical   no-undo .
  define variable v-is-pieces as logical   no-undo .
  define buffer buf_prod-bc  for ub.prod-bc .
  define buffer buf_bar-code for ub.bar-code .
  define buffer buf_goods    for ub.goods .
  define buffer buf1_shift-obj for ub.shift-obj .
  define buffer buf2_shift-obj for ub.shift-obj .
  assign  Counter1 = 0 .
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
  find first obj-list .
  find first buf1_shift-obj no-lock
    where buf1_shift-obj.obj-type    = obj-list.obj-type
      and buf1_shift-obj.obj-code    = obj-list.obj-code
      and buf1_shift-obj.shift-date  = x-Date-Start
      and buf1_shift-obj.shift-num   = x-Shift-Start
  no-error .
  if not available buf1_shift-obj then do:
    message "Не найдена смена начала отчета." skip "Дата:" string( x-Date-Start, "99/99/9999":U ) skip  "Порядок:" x-Shift-Start view-as alert-box error .
    return  .
  end.
  find first buf2_shift-obj no-lock
    where buf2_shift-obj.obj-type    = obj-list.obj-type
      and buf2_shift-obj.obj-code    = obj-list.obj-code
      and buf2_shift-obj.shift-date  = x-Date-End
      and buf2_shift-obj.shift-num   = x-Shift-End
  no-error .
  if not available buf2_shift-obj then do:
    message "Не найдена смена окончания отчета." skip "Дата:" string( x-Date-End, "99/99/9999":U ) skip  "Порядок:" x-Shift-End view-as alert-box error .
    return .
  end.
  define variable v-sort-list as character no-undo .
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input ''
  ,input 0
  ,input 'report-glob':U
  ,input  ""
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output v-value-logical
  ,output par-type
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .
  for each thbjattr_thbj-attr :
      if thbjattr_thbj-attr.prop-code = 'rep-sort'  then v-sort-list  = thbjattr_thbj-attr.property-value-character .
  end.
if error-status:error or v-sort-list = "":U then do:
  define variable v-tooltip as character no-undo .
  define variable v-label as character no-undo .
  define variable v-tooltip-code as character no-undo .
  run thbjattr_tooltip in this-procedure (
                                            input  'report-glob':U
                                           ,input  'rep-sort':U
                                           ,output v-tooltip
                                           ,output v-label
                                           ,output v-tooltip-code ) no-error.
  if error-status:error then do:
    assign
    v-tooltip-code = 'rep-sort':U
    v-tooltip = 'report-glob':U
    .
  end.
  message
  substitute("Не найден или незаполнен параметр <&1>&2Секция <&3>"
            , v-tooltip-code
            , chr(10)
            ,v-tooltip)
  view-as alert-box error .
  return .
end.
  _sort-cycle:
  do v-ind = 1 to NUM-ENTRIES(v-sort-list) :
    assign v-str = entry( v-ind, v-sort-list ) .
    _gds-cycle:
    for each buf_goods no-lock
    where buf_goods.gds-code = integer(v-str)
    :
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input buf_goods.artic
  ,  input buf_goods.prod-type
  ,  input buf_goods.prod-code
  , output v-is-petrol
  , output v-is-pieces
  ) .
      if v-is-petrol  = yes
      and v-is-pieces = no
      then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_goods.gds-code
  ,input  ?
  ,output v-b-code
  )  .
        find first temp-gds where temp-gds.gds-code = buf_goods.gds-code no-error .
        if not available temp-gds then do:
          create temp-gds .
          assign
            temp-gds.artic     = buf_goods.artic
            temp-gds.prod-type = buf_goods.prod-type
            temp-gds.prod-code = buf_goods.prod-code
            temp-gds.gds-code  = buf_goods.gds-code
          temp-gds.b-code    = v-b-code
            temp-gds.num       = v-ind
          .
          next _gds-cycle.
        end.
      end.
    end.
  end.
  find first temp-gds no-error .
  if not available temp-gds then do:
    message "Нет товаров для отчета." view-as alert-box error .
    return .
  end.
define variable cpgrpnam as character no-undo .
define variable v-dops as character no-undo.
define variable v-dopi as integer no-undo.
define variable ii as integer no-undo.
define variable nn as integer   no-undo .
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input ''
  ,input 0
  ,input 'cashpays':U
  ,input  ""
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output v-value-logical
  ,output par-type
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .
  for each thbjattr_thbj-attr :
      if thbjattr_thbj-attr.prop-code = 'cpgrpnam':U  then cpgrpnam  = thbjattr_thbj-attr.property-value-character .
  end.
  assign  nn = 1 .
  DO ii = 1 TO NUM-ENTRIES(cpgrpnam) by 2:
    ASSIGN
      v-dops = ENTRY(ii, cpgrpnam)
      v-dopi = integer(ENTRY(ii + 1, cpgrpnam))
    NO-ERROR.
    IF ERROR-STATUS:ERROR or v-dopi = 0 or v-dopi >= 10000 THEN DO:
      run thbjattr_tooltip in this-procedure (
                                               input 'cashpays':U
                                              ,input  'cpgrpnam':U
                                              ,output v-tooltip
                                              ,output v-label
                                              ,output v-tooltip-code ) no-error.
      if error-status:error then do:
        assign
        v-tooltip-code = 'cpgrpnam':U
        v-tooltip = 'cashpays':U
        .
      end.
      MESSAGE
      substitute("Неверное значение параметра <&1>&2Секция <&3>&2" +
                 "четные элементы списка должны быть положительными целыми числами < 10000"
                , v-tooltip-code
                , chr(10)
                ,v-tooltip)
      VIEW-AS ALERT-BOX ERROR.
      RETURN .
    END.
    create temp-grp .
    ASSIGN
      temp-grp.name = v-dops
      temp-grp.code = v-dopi
      temp-grp.num  = nn
      nn            = nn + 1
    .
  END.
  define buffer buf_chk-gds-pay for ub.chk-gds-pay .
  define buffer buf_cash-pay for ub.cash-pay .
  run rep/rpychk0.p ( input "r-shft3f"
                     ,input obj-list.obj-type
                     ,input obj-list.obj-code
                     ,input ?
                     ,input ?
                     ,input X-date-start
                     ,input X-date-end
                     ,input X-shift-start
                     ,input X-shift-end
                     ,input ?
                     ).
  for each temp-gds :
    for each buf_chk-gds-pay no-lock
      where buf_chk-gds-pay.b-code      = temp-gds.b-code
        and buf_chk-gds-pay.obj-type    = obj-list.obj-type
        and buf_chk-gds-pay.obj-code    = obj-list.obj-code
        and buf_chk-gds-pay.shift-date >= X-date-start
        and buf_chk-gds-pay.shift-date <= X-date-end
    :
      if buf_chk-gds-pay.algo-num <> "1.8" then next.
      if buf_chk-gds-pay.shift-date = X-date-start  and buf_chk-gds-pay.shift-num < X-Shift-Start  then next .
      if buf_chk-gds-pay.shift-date = X-date-end and buf_chk-gds-pay.shift-num > X-Shift-end then next .
      find first temp-sale where temp-sale.code = buf_chk-gds-pay.pay-code no-error .
      if not available temp-sale then do:
        find first buf_cash-pay no-lock where buf_cash-pay.cdpay-code = buf_chk-gds-pay.pay-code and buf_cash-pay.curr-code = buf_chk-gds-pay.curr-code .
        create temp-sale .
        assign
          temp-sale.name   = buf_cash-pay.obj-name
          temp-sale.code   = buf_cash-pay.cdpay-code
          temp-sale.is-nal = buf_cash-pay.is-cash
        .
        temp-sale.grp  = get-grp-name(input buf_cash-pay.cdpay-code, buf_cash-pay.curr-code) .
      end.
      case temp-gds.num :
        when 1 then do:
          assign
            temp-sale.val1 = temp-sale.val1 + buf_chk-gds-pay.eff-doc-qnty
            temp-sale.sum1 = temp-sale.sum1 + buf_chk-gds-pay.tot-r-b
          .
        end.
        when 2 then do:
          assign
            temp-sale.val2 = temp-sale.val2 + buf_chk-gds-pay.eff-doc-qnty
            temp-sale.sum2 = temp-sale.sum2 + buf_chk-gds-pay.tot-r-b
          .
        end.
        when 3 then do:
          assign
            temp-sale.val3 = temp-sale.val3 + buf_chk-gds-pay.eff-doc-qnty
            temp-sale.sum3 = temp-sale.sum3 + buf_chk-gds-pay.tot-r-b
          .
        end.
        when 4 then do:
          assign
            temp-sale.val4 = temp-sale.val4 + buf_chk-gds-pay.eff-doc-qnty
            temp-sale.sum4 = temp-sale.sum4 + buf_chk-gds-pay.tot-r-b
          .
        end.
        when 5 then do:
          assign
            temp-sale.val5 = temp-sale.val5 + buf_chk-gds-pay.eff-doc-qnty
            temp-sale.sum5 = temp-sale.sum5 + buf_chk-gds-pay.tot-r-b
          .
        end.
        when 6 then do:
          assign
            temp-sale.val6 = temp-sale.val6 + buf_chk-gds-pay.eff-doc-qnty
            temp-sale.sum6 = temp-sale.sum6 + buf_chk-gds-pay.tot-r-b
          .
        end.
      end.
      assign
        temp-sale.val-all = temp-sale.val5 + buf_chk-gds-pay.eff-doc-qnty
        temp-sale.sum-all = temp-sale.sum5 + buf_chk-gds-pay.tot-r-b
      .
    end.
  end.
output stream out-stream to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size  value(62) .
  run shift3xl-init in this-procedure.
  run shift3xl-write-cell-data in this-procedure ( input "h_Obj":U, input "Объект: " + obj-list.obj-name ).
  define variable p-str as character no-undo .
  if x-Date-Start = x-Date-End and x-Shift-Start = x-Shift-End then do:
    assign
      p-str =   "Смена:" + string (buf1_shift-obj.shift-name) + " от "
              + string( buf1_shift-obj.open-date , "99/99/9999" ) + ' '
              + string( buf1_shift-obj.open-time , "hh:mm" ) + ' '
              + "смена закрыта: " + string( buf1_shift-obj.close-date , "99/99/9999" )
              + " " +  string( buf1_shift-obj.close-time , "hh:mm" )
    .
  end.
  else do:
    assign
      p-str =   "Смены с: " + string(buf1_shift-obj.shift-name)
              + " от " + string( buf1_shift-obj.open-date , "99/99/9999" ) + ' '
              + string ( buf1_shift-obj.open-time , "hh:mm" )
    .
    assign
      p-str =   p-str + ' '
              + "по: " + string(buf2_shift-obj.shift-name)
              + " от " + string( buf2_shift-obj.open-date , "99/99/9999" ) + ' '
              + string( buf2_shift-obj.open-time , "hh:mm" )
              + " закрыта " + string( buf2_shift-obj.close-date,"99/99/9999") + " "
              + string(buf2_shift-obj.close-time,"hh:mm")
    .
  end.
  run shift3xl-write-cell-data in this-procedure ( input "h_Date":U, input p-str ).
  for each temp-grp :
    run shift3xl-sheet1-write-line-data ( temp-grp.name,
                                          "",    "",
                                          "",    "",
                                          "",    "",
                                          "",    "",
                                          "",    "",
                                          "",    "",
                                          "",    "").
    for each temp-sale where temp-sale.grp = temp-grp.code :
      run shift3xl-sheet1-write-line-data ( "Итого " + temp-grp.name,
                                            string(temp-sale.val1),    string(temp-sale.sum1),
                                            string(temp-sale.val2),    string(temp-sale.sum2),
                                            string(temp-sale.val3),    string(temp-sale.sum3),
                                            string(temp-sale.val4),    string(temp-sale.sum4),
                                            string(temp-sale.val5),    string(temp-sale.sum5),
                                            string(temp-sale.val6),    string(temp-sale.sum6),
                                            string(temp-sale.val-all), string(temp-sale.sum-all)).
      assign
        temp-grp.val1    = temp-grp.val1    + temp-sale.val1
        temp-grp.val2    = temp-grp.val2    + temp-sale.val2
        temp-grp.val3    = temp-grp.val3    + temp-sale.val3
        temp-grp.val4    = temp-grp.val4    + temp-sale.val4
        temp-grp.val5    = temp-grp.val5    + temp-sale.val5
        temp-grp.val6    = temp-grp.val6    + temp-sale.val6
        temp-grp.val-all = temp-grp.val-all + temp-sale.val-all
        temp-grp.sum1    = temp-grp.sum1    + temp-sale.sum1
        temp-grp.sum2    = temp-grp.sum2    + temp-sale.sum2
        temp-grp.sum3    = temp-grp.sum3    + temp-sale.sum3
        temp-grp.sum4    = temp-grp.sum4    + temp-sale.sum4
        temp-grp.sum5    = temp-grp.sum5    + temp-sale.sum5
        temp-grp.sum6    = temp-grp.sum6    + temp-sale.sum6
        temp-grp.sum-all = temp-grp.sum-all + temp-sale.sum-all
      .
      if temp-sale.is-nal = no then do:
        assign
          v-itog-bn [1]  = v-itog-bn [1]  + temp-sale.val1
          v-itog-bn [2]  = v-itog-bn [2]  + temp-sale.sum1
          v-itog-bn [3]  = v-itog-bn [3]  + temp-sale.val2
          v-itog-bn [4]  = v-itog-bn [4]  + temp-sale.sum2
          v-itog-bn [5]  = v-itog-bn [5]  + temp-sale.val3
          v-itog-bn [6]  = v-itog-bn [6]  + temp-sale.sum3
          v-itog-bn [7]  = v-itog-bn [7]  + temp-sale.val4
          v-itog-bn [8]  = v-itog-bn [8]  + temp-sale.sum4
          v-itog-bn [9]  = v-itog-bn [9]  + temp-sale.val5
          v-itog-bn [10] = v-itog-bn [10] + temp-sale.sum5
          v-itog-bn [11] = v-itog-bn [11] + temp-sale.val6
          v-itog-bn [12] = v-itog-bn [12] + temp-sale.sum6
          v-itog-bn [13] = v-itog-bn [13] + temp-sale.val-all
          v-itog-bn [14] = v-itog-bn [14] + temp-sale.sum-all
        .
      end.
    end.
    run shift3xl-sheet1-write-line-data ( "Итого " + temp-grp.name,
                                          string(temp-grp.val1),    string(temp-grp.sum1),
                                          string(temp-grp.val2),    string(temp-grp.sum2),
                                          string(temp-grp.val3),    string(temp-grp.sum3),
                                          string(temp-grp.val4),    string(temp-grp.sum4),
                                          string(temp-grp.val5),    string(temp-grp.sum5),
                                          string(temp-grp.val6),    string(temp-grp.sum6),
                                          string(temp-grp.val-all), string(temp-grp.sum-all)).
    assign
      v-itog-sale [1]  = v-itog-sale [1]  + temp-grp.val1
      v-itog-sale [2]  = v-itog-sale [2]  + temp-grp.sum1
      v-itog-sale [3]  = v-itog-sale [3]  + temp-grp.val2
      v-itog-sale [4]  = v-itog-sale [4]  + temp-grp.sum2
      v-itog-sale [5]  = v-itog-sale [5]  + temp-grp.val3
      v-itog-sale [6]  = v-itog-sale [6]  + temp-grp.sum3
      v-itog-sale [7]  = v-itog-sale [7]  + temp-grp.val4
      v-itog-sale [8]  = v-itog-sale [8]  + temp-grp.sum4
      v-itog-sale [9]  = v-itog-sale [9]  + temp-grp.val5
      v-itog-sale [10] = v-itog-sale [10] + temp-grp.sum5
      v-itog-sale [11] = v-itog-sale [11] + temp-grp.val6
      v-itog-sale [12] = v-itog-sale [12] + temp-grp.sum6
      v-itog-sale [13] = v-itog-sale [13] + temp-grp.val-all
      v-itog-sale [14] = v-itog-sale [14] + temp-grp.sum-all
    .
  end.
  run shift3xl-sheet1-write-line-data ( "Итого безнал:" ,
                                          string(v-itog-bn [1] ),
                                          string(v-itog-bn [2] ),
                                          string(v-itog-bn [3] ),
                                          string(v-itog-bn [4] ),
                                          string(v-itog-bn [5] ),
                                          string(v-itog-bn [6] ),
                                          string(v-itog-bn [7] ),
                                          string(v-itog-bn [8] ),
                                          string(v-itog-bn [9] ),
                                          string(v-itog-bn [10]),
                                          string(v-itog-bn [11]),
                                          string(v-itog-bn [12]),
                                          string(v-itog-bn [13]),
                                          string(v-itog-bn [14])
                                          ).
  run shift3xl-sheet1-write-line-data ( "Итого реализация:" ,
                                          string(v-itog-sale [1] ),
                                          string(v-itog-sale [2] ),
                                          string(v-itog-sale [3] ),
                                          string(v-itog-sale [4] ),
                                          string(v-itog-sale [5] ),
                                          string(v-itog-sale [6] ),
                                          string(v-itog-sale [7] ),
                                          string(v-itog-sale [8] ),
                                          string(v-itog-sale [9] ),
                                          string(v-itog-sale [10]),
                                          string(v-itog-sale [11]),
                                          string(v-itog-sale [12]),
                                          string(v-itog-sale [13]),
                                          string(v-itog-sale [14])
                                          ).
  run Calc-Itog-Teh in this-procedure .
  run shift3xl-write-cell-data in this-procedure ( input "f_teh1":U, input string( v-teh [ 1 ] ) ).
  run shift3xl-write-cell-data in this-procedure ( input "f_teh2":U, input string( v-teh [ 2 ] ) ).
  run shift3xl-write-cell-data in this-procedure ( input "f_teh3":U, input string( v-teh [ 3 ] ) ).
  run shift3xl-write-cell-data in this-procedure ( input "f_teh4":U, input string( v-teh [ 4 ] ) ).
  run shift3xl-write-cell-data in this-procedure ( input "f_teh5":U, input string( v-teh [ 5 ] ) ).
  run shift3xl-write-cell-data in this-procedure ( input "f_teh6":U, input string( v-teh [ 6 ] ) ).
  run shift3xl-write-cell-data in this-procedure ( input "f_teh7":U, input string( v-teh [ 1 ] +  v-teh [ 2 ] + v-teh [ 3 ] + v-teh [ 4 ] + v-teh [ 5 ] + v-teh [ 6 ]) ).
  run shift3xl-write-cell-data in this-procedure ( input "f_fteh1":U, input string( v-itog-sale [1] + v-teh [ 1 ] ) ).
  run shift3xl-write-cell-data in this-procedure ( input "f_fteh2":U, input string( v-itog-sale [3] + v-teh [ 2 ] ) ).
  run shift3xl-write-cell-data in this-procedure ( input "f_fteh3":U, input string( v-itog-sale [5] + v-teh [ 3 ] ) ).
  run shift3xl-write-cell-data in this-procedure ( input "f_fteh4":U, input string( v-itog-sale [7] + v-teh [ 4 ] ) ).
  run shift3xl-write-cell-data in this-procedure ( input "f_fteh5":U, input string( v-itog-sale [9] + v-teh [ 5 ] ) ).
  run shift3xl-write-cell-data in this-procedure ( input "f_fteh6":U, input string( v-itog-sale [11] + v-teh [ 6 ] ) ).
  run shift3xl-write-cell-data in this-procedure ( input "f_fteh7":U, input string( v-itog-sale [13] + v-teh [ 1 ] +  v-teh [ 2 ] + v-teh [ 3 ] + v-teh [ 4 ] + v-teh [ 5 ] + v-teh [ 6 ]) ).
  run Calc-Itog-Counter in this-procedure .
  run shift3xl-write-cell-data in this-procedure ( input "f_count1":U, input string( v-counter [ 1 ] ) ).
  run shift3xl-write-cell-data in this-procedure ( input "f_count2":U, input string( v-counter [ 2 ] ) ).
  run shift3xl-write-cell-data in this-procedure ( input "f_count3":U, input string( v-counter [ 3 ] ) ).
  run shift3xl-write-cell-data in this-procedure ( input "f_count4":U, input string( v-counter [ 4 ] ) ).
  run shift3xl-write-cell-data in this-procedure ( input "f_count5":U, input string( v-counter [ 5 ] ) ).
  run shift3xl-write-cell-data in this-procedure ( input "f_count6":U, input string( v-counter [ 6 ] ) ).
  run shift3xl-write-cell-data in this-procedure ( input "f_count7":U, input string( v-counter [ 1 ] +  v-counter [ 2 ] + v-counter [ 3 ] + v-counter [ 4 ] + v-counter [ 5 ] + v-counter [ 6 ]) ).
  run shift3xl-write-cell-data in this-procedure ( input "f_itog1":U, input string( v-itog-sale [1] ) ).
  run shift3xl-write-cell-data in this-procedure ( input "f_itog2":U, input string( v-itog-sale [3] ) ).
  run shift3xl-write-cell-data in this-procedure ( input "f_itog3":U, input string( v-itog-sale [5] ) ).
  run shift3xl-write-cell-data in this-procedure ( input "f_itog4":U, input string( v-itog-sale [7] ) ).
  run shift3xl-write-cell-data in this-procedure ( input "f_itog5":U, input string( v-itog-sale [9] ) ).
  run shift3xl-write-cell-data in this-procedure ( input "f_itog6":U, input string( v-itog-sale [11] ) ).
  run shift3xl-write-cell-data in this-procedure ( input "f_itog7":U, input string( v-itog-sale [13] ) ).
  run shift3xl-write-cell-data in this-procedure ( input "f_delta1":U, input string( v-counter [ 1 ] - v-itog-sale [1] ) ).
  run shift3xl-write-cell-data in this-procedure ( input "f_delta2":U, input string( v-counter [ 2 ] - v-itog-sale [3] ) ).
  run shift3xl-write-cell-data in this-procedure ( input "f_delta3":U, input string( v-counter [ 3 ] - v-itog-sale [5] ) ).
  run shift3xl-write-cell-data in this-procedure ( input "f_delta4":U, input string( v-counter [ 4 ] - v-itog-sale [7] ) ).
  run shift3xl-write-cell-data in this-procedure ( input "f_delta5":U, input string( v-counter [ 5 ] - v-itog-sale [9] ) ).
  run shift3xl-write-cell-data in this-procedure ( input "f_delta6":U, input string( v-counter [ 6 ] - v-itog-sale [11] ) ).
  run shift3xl-write-cell-data in this-procedure ( input "f_delta7":U, input string( v-counter [ 1 ]  +  v-counter [ 2 ] + v-counter [ 3 ] + v-counter [ 4 ] + v-counter [ 5 ] + v-counter [ 6 ] - v-itog-sale [13] ) ).
  put STREAM out-stream   "ИТОГО" .
  output stream out-stream close.
  run shift3xl-close in this-procedure .
  os-delete value( string( session:temp-directory ) + "rpt" + string( g#report-num ) + ".txl" )  .
  os-rename
    value( string( session:temp-directory ) + "$" + string( g#report-num ) + ".txl" )
    value( string( session:temp-directory ) + "rpt" + string( g#report-num ) + ".txl" )
  .
  define variable v-user-action   as character no-undo .
  define variable v-printed       as logical   no-undo .
  run gbl/prnfilen.w
      (input  ""
      ,input  20
      ,input  string(session :temp-directory) + "rpt" + string( g#report-num )
      ,input  ReportFontNum
      ,output v-user-action
      ,output v-printed
      ) .
  os-delete value( string( session:temp-directory ) + "rpt" + string( g#report-num ) + ".txl" )  .
define temp-table temp-rvs-line no-undo like ub.rvs-line
  FIELD gds-name as character
  FIELD place_loc1 as character
  FIELD shift-date like ub.rvs-doc.shift-date
  FIELD shift-num  like ub.rvs-doc.shift-num
  FIELD v-bar-code like ub.bar-code.b-code
  FIELD artic      like ub.goods.artic
  FIELD prod-type  like ub.goods.prod-type
  FIELD prod-code  like ub.goods.prod-code
.
procedure Calc-Itog-Counter :
  do on error undo, return error return-value :
  define buffer buf_rvs-line-pump for ub.rvs-line-pump .
  define buffer buf_temp-rvs-line for temp-rvs-line .
define buffer previous-rvs-doc for ub.rvs-doc.
define buffer previous-rvs-line for ub.rvs-line.
define buffer previous-rvs-line-pump for ub.rvs-line-pump.
define buffer last-rvs-doc for ub.rvs-doc.
define buffer last-rvs-line for ub.rvs-line.
define buffer last-rvs-line-pump for ub.rvs-line-pump.
define buffer previous-shift-obj for ub.shift-obj.
define buffer control-rvs-doc for ub.rvs-doc.
define buffer control-rvs-line-pump for ub.rvs-line-pump.
define variable pol5 as decimal   no-undo .
define variable pol6 as decimal   no-undo .
FIND FIRST last-rvs-doc No-LOCK WHERE
           last-rvs-doc.obj-type   = obj-list.obj-type AND
           last-rvs-doc.obj-code   = obj-list.obj-code AND
           last-rvs-doc.shift-date = x-date-End AND
           last-rvs-doc.shift-num  = x-shift-end AND
           last-rvs-doc.status_    = 'факт':U AND
           last-rvs-doc.rvs-type   = 'смена':U NO-ERROR.
if not avail last-rvs-doc then do:
  message vss-workfile vss-revision vss-description skip
          "Не найдена сверка типа СМН "
          "объект" obj-list.obj-type obj-list.obj-code
          "смена" x-date-End x-shift-end
  view-as alert-box ERROR.
  return error.
END.
find last previous-shift-obj no-lock where
          previous-shift-obj.obj-type   = obj-list.obj-type  and
          previous-shift-obj.obj-code   = obj-list.obj-code  and
      ( ( previous-shift-obj.shift-date = x-date-Start   and
          previous-shift-obj.shift-num  < x-shift-Start  ) or
          previous-shift-obj.shift-date < x-date-Start ) use-index pi no-error .
if available previous-shift-obj then do:
  FIND FIRST previous-rvs-doc No-LOCK WHERE
            previous-rvs-doc.obj-type   = obj-list.obj-type AND
            previous-rvs-doc.obj-code   = obj-list.obj-code AND
            previous-rvs-doc.shift-date = previous-shift-obj.shift-date AND
            previous-rvs-doc.shift-num  = previous-shift-obj.shift-num AND
            previous-rvs-doc.status_    = 'факт':U AND
            previous-rvs-doc.rvs-type   = 'смена':U NO-ERROR.
end.
  for each ub.rvs-doc No-LOCK WHERE
           ub.rvs-doc.obj-type   = obj-list.obj-type AND
           ub.rvs-doc.obj-code   = obj-list.obj-code AND
           ub.rvs-doc.shift-date >= x-date-Start AND
           ub.rvs-doc.shift-date <= x-date-End AND
           ub.rvs-doc.status_    = 'факт':U AND
           ub.rvs-doc.rvs-type   = 'смена':U :
    if ub.rvs-doc.shift-date = x-date-Start and ub.rvs-doc.shift-num < x-Shift-Start then next .
    if ub.rvs-doc.shift-date = x-date-End   and ub.rvs-doc.shift-num > x-Shift-End then next .
    for each ub.rvs-line No-LOCK WHERE ub.rvs-line.rvs-code = ub.rvs-doc.rvs-code :
      find first temp-gds where temp-gds.gds-code = ub.rvs-line.gds-code no-error .
      if not available temp-gds then next .
      find first temp-rvs-line where temp-rvs-line.pl-code  = ub.rvs-line.pl-code and temp-rvs-line.gds-code = ub.rvs-line.gds-code no-error .
      if not available temp-rvs-line then do:
        create temp-rvs-line .
        BUFFER-COPY ub.rvs-line to temp-rvs-line .
        assign
          temp-rvs-line.artic      = temp-gds.artic
          temp-rvs-line.prod-type  = temp-gds.prod-type
          temp-rvs-line.prod-code  = temp-gds.prod-code
          temp-rvs-line.shift-date = ub.rvs-doc.shift-date
          temp-rvs-line.shift-num  = ub.rvs-doc.shift-num
          temp-rvs-line.v-bar-code = temp-gds.b-code
        .
      end.
      else do:
        if temp-rvs-line.shift-date < ub.rvs-doc.shift-date or temp-rvs-line.shift-date = ub.rvs-doc.shift-date and temp-rvs-line.shift-num  < ub.rvs-doc.shift-num then
          BUFFER-COPY ub.rvs-line to temp-rvs-line .
      end.
    end.
  end.
  for each temp-rvs-line  break by temp-rvs-line.gds-code by temp-rvs-line.pl-code on error undo, return error return-value :
    if first-of(temp-rvs-line.gds-code) then do:
      assign
        pol5 = 0
        pol6 = 0
      .
    end.
    if avail previous-rvs-doc then
      Find first previous-rvs-line  No-LOCK WHERE
              previous-rvs-line.rvs-code = previous-rvs-doc.rvs-code and
              previous-rvs-line.gds-code = temp-rvs-line.gds-code  and
              previous-rvs-line.obj-code = temp-rvs-line.obj-code  and
              previous-rvs-line.obj-type = temp-rvs-line.obj-type  and
              previous-rvs-line.pl-code  = temp-rvs-line.pl-code
              no-error .
    FOR EACH buf_rvs-line-pump No-LOCK WHERE
       buf_rvs-line-pump.rvs-code = temp-rvs-line.rvs-code  and
       buf_rvs-line-pump.gds-code = temp-rvs-line.gds-code  and
       buf_rvs-line-pump.obj-code = temp-rvs-line.obj-code  and
       buf_rvs-line-pump.obj-type = temp-rvs-line.obj-type  and
       buf_rvs-line-pump.pl-code  = temp-rvs-line.pl-code
      BREAK BY buf_rvs-line-pump.pump-code BY buf_rvs-line-pump.nozzle-code:
      assign
        pol5 = pol5 + buf_rvs-line-pump.state-mh-cnt
      .
      if avail previous-rvs-doc then do:
        Find FIRST previous-rvs-line-pump  No-LOCK WHERE
            previous-rvs-line-pump.rvs-code = previous-rvs-doc.rvs-code AND
            previous-rvs-line-pump.gds-code = temp-rvs-line.gds-code  and
            previous-rvs-line-pump.obj-code = temp-rvs-line.obj-code  and
            previous-rvs-line-pump.obj-type = temp-rvs-line.obj-type  and
            previous-rvs-line-pump.pl-code  = temp-rvs-line.pl-code AND
            previous-rvs-line-pump.pump-code = buf_rvs-line-pump.pump-code AND
            previous-rvs-line-pump.nozzle-code = buf_rvs-line-pump.nozzle-code No-ERROR.
        IF AVAIL previous-rvs-line-pump then do:
          assign pol6 = pol6 + previous-rvs-line-pump.state-mh-cnt .
        end.
      end.
      if not avail previous-rvs-doc or not avail previous-rvs-line-pump then do:
        FOR EACH control-rvs-doc NO-LOCK WHERE
            control-rvs-doc.obj-type   = obj-list.obj-type AND
            control-rvs-doc.obj-code   = obj-list.obj-code AND
            control-rvs-doc.shift-date = x-date-Start AND
            control-rvs-doc.shift-num  = x-shift-Start AND
            control-rvs-doc.status_    = 'факт':U AND
            control-rvs-doc.rvs-type   = 'контроль':U,
        FIRST control-rvs-line-pump No-LOCK WHERE
          control-rvs-line-pump.rvs-code = control-rvs-doc.rvs-code AND
          control-rvs-line-pump.gds-code = temp-rvs-line.gds-code  and
          control-rvs-line-pump.obj-code = temp-rvs-line.obj-code  and
          control-rvs-line-pump.obj-type = temp-rvs-line.obj-type  and
          control-rvs-line-pump.pl-code  = temp-rvs-line.pl-code AND
          control-rvs-line-pump.pump-code = buf_rvs-line-pump.pump-code AND
          control-rvs-line-pump.nozzle-code = buf_rvs-line-pump.nozzle-code
        BY control-rvs-doc.fact-order:
          assign pol6 = pol6 + control-rvs-line-pump.state-mh-cnt .
          LEAVE.
        END.
      end.
    END.
    if last-of( temp-rvs-line.gds-code ) then do:
      find first temp-gds where temp-gds.gds-code = temp-rvs-line.gds-code no-error .
      if available temp-gds then assign v-counter [ temp-gds.num ] = pol5 - pol6 .
    End.
  End.
  end.
end procedure.
procedure Calc-Itog-Teh :
  do on error undo, return error return-value :
    define buffer buf_clients      for ub.clients .
    define buffer buf_clients-attr for ub.clients-attr .
    define buffer buf_trn-doc      for ub.trn-doc .
    define buffer buf_doc-line     for ub.doc-line .
    FOR EACH buf_clients-attr WHERE buf_clients-attr.attr-code  = 'shftrep2':U AND buf_clients-attr.attr-value = "yes":U :
      FIND FIRST buf_clients NO-LOCK WHERE buf_clients.obj-type = buf_clients-attr.obj-type AND buf_clients.obj-code = buf_clients-attr.obj-code NO-ERROR.
      IF not AVAILABLE buf_clients THEN next .
      for each buf_trn-doc no-lock
        where buf_trn-doc.obj-type   = obj-list.obj-type
          and buf_trn-doc.obj-code   = obj-list.obj-code
          and buf_trn-doc.status_    = 'факт':U
          and buf_trn-doc.cli-type   = buf_clients.obj-type
          and buf_trn-doc.cli-code   = buf_clients.obj-code
          and buf_trn-doc.shift-date >= x-Date-Start
          and buf_trn-doc.shift-date <= x-Date-End
      :
        if buf_trn-doc.shift-date = x-Date-Start and buf_trn-doc.shift-num < x-Shift-Start then next .
        if buf_trn-doc.shift-date = x-Date-End   and buf_trn-doc.shift-num > x-Shift-End   then next .
        IF buf_trn-doc.ext-doc-type = 'ie':U then next .
        for each buf_doc-line no-lock where buf_doc-line.doc-code  = buf_trn-doc.doc-code :
          find first temp-gds
            where temp-gds.artic     = buf_doc-line.artic
              and temp-gds.prod-type = buf_doc-line.prod-type
              and temp-gds.prod-code = buf_doc-line.prod-code
          no-error .
          if not available temp-gds then next .
          IF buf_doc-line.ext-doc-type = 'vt':U or buf_doc-line.ext-doc-type = 'vp':U THEN DO:
            assign v-teh [ temp-gds.num ] = v-teh  [ temp-gds.num ] + ( IF buf_doc-line.cli-qnty = ? THEN 0 ELSE buf_doc-line.cli-qnty ).
          end.
          else do:
            assign v-teh [ temp-gds.num ] = v-teh  [ temp-gds.num ] + buf_doc-line.fact-qnty .
          end.
        END.
      END.
    END.
  end.
end procedure.
