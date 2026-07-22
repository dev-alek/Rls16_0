block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-benet1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/r-benet1.p $":U .
define variable vss-description as character no-undo init "Движение товара по месту хранения ".
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
def var vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
FUNCTION n-lavel RETURNS char (INPUT grp-name as char, INPUT lavel# as int ).
define variable  str  as char format "X(60)"  no-undo.
define variable  str2 as char no-undo.
define variable v-r as character no-undo init "" .
define variable  i#i as int no-undo.
STR = "".
repeat i#i =1 to lavel#:
    if i#i =1 then str   = entry(1,grp-name, chr(47)) .
    else do:
        str2 = entry(i#i,grp-name, chr(47)) no-error.
        if not error-status:error  and str2 <> "":u then
               str = str +  chr(47) +  entry(i#i,grp-name, chr(47)) no-error .
        end.
end.
if str <> ? then do:
v-r = str + chr(47) .
end.
RETURN v-r .
END FUNCTION.
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
define input parameter xClassify    as char no-undo.
define input parameter xSortType    as char no-undo.
define input parameter xSumsOnly    as log  no-undo.
define input parameter xShowZero    as log  no-undo.
define input parameter xTog-obj     as log no-undo.
define input parameter xShowCost    as log no-undo.
define input parameter xShowSale    as log no-undo.
define input parameter xtog-lavel   as log no-undo.
define input parameter xvar-lavel   as int no-undo.
define input parameter fo0    like ub.ot-tot.fact-order no-undo.
define input parameter fo02   like ub.ot-tot.fact-order no-undo.
define input parameter fo1    like ub.ot-tot.fact-order no-undo.
define input parameter fo12   like ub.ot-tot.fact-order no-undo.
define input parameter fo2    like ub.ot-tot.fact-order no-undo.
define input parameter fo22   like ub.ot-tot.fact-order no-undo.
define input parameter fo3    like ub.ot-tot.fact-order no-undo.
define input parameter fo32   like ub.ot-tot.fact-order no-undo.
define input parameter fo4    like ub.ot-tot.fact-order no-undo.
define input parameter fo42   like ub.ot-tot.fact-order no-undo.
define input parameter fo5    like ub.ot-tot.fact-order no-undo.
define input parameter fo52   like ub.ot-tot.fact-order no-undo.
define input parameter Tog-Qnty  as log no-undo.
define input parameter xbsamount as int no-undo.
define input parameter Tog-voz  as log no-undo.
define input parameter ShowOrders  as log no-undo.
define buffer goods   for ub.goods  .
define buffer gds-obj for ub.gds-obj  .
define buffer clients for ub.clients  .
define  variable  tPrintRubl as log no-undo.
define stream  instream    .
define stream  outstream   .
define stream  outstream2  .
make-excel-com = false .
make-excel     = true  .
define stream  macr_excel .
define variable ObjName           as   char no-undo.
define variable Select-Good       as   integer no-undo.
define variable ChosedType        as   integer no-undo.
define variable PayType           as   integer no-undo.
define variable RetClassify       as   char  no-undo.
define variable RetSortType       as   char  no-undo.
define variable Show-Negativ      as   logical  no-undo.
define variable Sums-Only         as   logical  no-undo.
define variable ValType           as   integer no-undo.
define variable Line              as   char        no-undo.
define variable FirstLine         as   logical     no-undo.
define variable Number-Orders as character no-undo .
define variable QNTY-Orders as character no-undo .
define variable tot_tqnty as decimal  no-undo.
define variable break_group as logical no-undo init true.
define variable break_group1 as logical no-undo init true.
define variable stat      as log no-undo .
define variable InpError  as log no-undo .
define variable i         as integer init 0 no-undo .
define variable R         as integer init 0 no-undo .
define variable ii        as integer init 0 no-undo .
define variable rr        as integer init 0 no-undo .
define variable f-ii      as char no-undo .
define variable p         as integer no-undo init 0 .
define variable kk        as integer no-undo init 0 .
define variable rid-list  as character no-undo .
define variable gds-zap-unit-base     like ub.goods.unit-base     no-undo.
define variable gds-zap-prt-root      like ub.goods.prt-root     no-undo .
define variable gds-zap-gds-name      like ub.goods.gds-name     no-undo .
define variable gds-zap-prod-type     like ub.goods.prod-type    no-undo .
define variable gds-zap-prod-code     like ub.goods.prod-code    no-undo .
define variable gds-zap-artic         like ub.goods.artic        no-undo .
define variable gds-zap-b-code        like ub.bar-code.b-code    no-undo .
define variable gds-type              as char no-undo.
define variable gds-zap-type          like ub.goods.gds-type     no-undo .
define variable gds-zap-grp-name      like ub.goods.grp-name     no-undo .
define variable gds-zap-prod-name     like ub.clients.obj-name   no-undo .
define variable gds-zap-price-base    like ub.stk-tot.sum-base no-undo.
define variable gds-zap-stoim-base    like ub.stk-tot.sum-base no-undo.
define variable gds-zap-qnty          like ub.stk-tot.fact-qnty no-undo.
define variable gds-zap-Nds           like ub.stk-tot.sum-base no-undo.
define variable gds-zap-Np            like ub.stk-tot.sum-base no-undo.
define variable F-ostatok-start    as   char  no-undo.
define variable F-ostatok-End      as   char  no-undo.
define variable ostatok-start      as   decimal EXTENT 6 Format "->>>>>>>>>9.999" no-undo.
define variable ostatok-End        as   decimal EXTENT 6 Format "->>>>>>>>>9.999" no-undo.
define variable B1-ostatok-start   as   decimal EXTENT 6 Format "->>>>>>>>>9.999" no-undo.
define variable B1-ostatok-End     as   decimal EXTENT 6 Format "->>>>>>>>>9.999" no-undo.
define variable B2-ostatok-start   as   decimal EXTENT 6 Format "->>>>>>>>>9.999" no-undo.
define variable B2-ostatok-End     as   decimal EXTENT 6 Format "->>>>>>>>>9.999" no-undo.
define variable Bi-ostatok-start   as   decimal EXTENT 6 Format "->>>>>>>>>9.999" no-undo.
define variable Bi-ostatok-End     as   decimal EXTENT 6 Format "->>>>>>>>>9.999" no-undo.
define variable F-prih             as   char  no-undo.
define variable F-rash             as   char  no-undo.
define variable F-kassa1            as   char  no-undo.
define variable F-kassa2            as   char  no-undo.
define variable F-kassa3            as   char  no-undo.
define variable F-kassa4            as   char  no-undo.
define variable F-kassa5            as   char  no-undo.
define variable F-kassa6            as   char  no-undo.
define variable F-Inv              as   char  no-undo.
define variable F-Overturn         as   char  no-undo.
define variable f-zakaz            as   decimal  no-undo.
define variable F-Center-stock     as   decimal  no-undo.
define variable F-avr              as   decimal  no-undo.
define variable prih             as   decimal EXTENT 6 Format "->>>>>>>>>9.999" no-undo.
define variable rash             as   decimal EXTENT 6 Format "->>>>>>>>>9.999" no-undo.
define variable kassa            as   decimal EXTENT 6 Format "->>>>>>>>>9.999" no-undo.
define variable Inv              as   decimal EXTENT 6 Format "->>>>>>>>>9.999" no-undo.
define variable Overturn         as   decimal EXTENT 6 Format "->>>>>>>>>9.999" no-undo.
define variable B1-prih             as   decimal EXTENT 6 Format "->>>>>>>>>9.999" no-undo.
define variable B1-rash             as   decimal EXTENT 6 Format "->>>>>>>>>9.999" no-undo.
define variable B1-kassa            as   decimal EXTENT 6 Format "->>>>>>>>>9.999" no-undo.
define variable B1-Inv              as   decimal EXTENT 6 Format "->>>>>>>>>9.999" no-undo.
define variable B1-Overturn         as   decimal EXTENT 6 Format "->>>>>>>>>9.999" no-undo.
define variable b1-f-zakaz            as   decimal  no-undo.
define variable b1-F-Center-stock     as   decimal  no-undo.
define variable b1-F-avr              as   decimal  no-undo.
define variable B2-prih             as   decimal EXTENT 6 Format "->>>>>>>>>9.999" no-undo.
define variable B2-rash             as   decimal EXTENT 6 Format "->>>>>>>>>9.999" no-undo.
define variable B2-kassa            as   decimal EXTENT 6 Format "->>>>>>>>>9.999" no-undo.
define variable B2-Inv              as   decimal EXTENT 6 Format "->>>>>>>>>9.999" no-undo.
define variable B2-Overturn         as   decimal EXTENT 6 Format "->>>>>>>>>9.999" no-undo.
define variable b2-f-zakaz            as   decimal  no-undo.
define variable b2-F-Center-stock     as   decimal  no-undo.
define variable b2-F-avr              as   decimal  no-undo.
define variable Bi-prih             as   decimal EXTENT 6 Format "->>>>>>>>>9.999" no-undo.
define variable Bi-rash             as   decimal EXTENT 6 Format "->>>>>>>>>9.999" no-undo.
define variable Bi-kassa            as   decimal EXTENT 6 Format "->>>>>>>>>9.999" no-undo.
define variable Bi-Inv              as   decimal EXTENT 6 Format "->>>>>>>>>9.999" no-undo.
define variable Bi-Overturn         as   decimal EXTENT 6 Format "->>>>>>>>>9.999" no-undo.
define variable bi-f-zakaz            as   decimal  no-undo.
define variable bi-F-Center-stock     as   decimal  no-undo.
define variable bi-F-avr              as   decimal  no-undo.
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
define variable  temp-str as char no-undo.
define variable str as char format "X(60)" no-undo.
define variable i3#i as int no-undo.
define variable xLavel as int  no-undo.
define variable list-field as char no-undo.
define variable str10 as char no-undo.
define BUFFER stk-line2 FOR ub.stk-line  .
define work-table temp#sum-type no-undo
    field sum-type as char
    field xi as int
    .
define temp-table tmp#bs no-undo
    FIELD   b-code         LIKE gds-zap-b-code
    FIELD   artic          LIKE gds-zap-artic
    FIELD   prod-code      LIKE gds-zap-prod-code
    FIELD   prod-type      LIKE gds-zap-prod-type
    FIELD   prt-root       LIKE gds-zap-prt-root
    FIELD   grp-name       LIKE gds-zap-grp-name
    FIELD   F-zakaz        LIKE F-zakaz
    FIELD   F-center-stock LIKE F-center-stock
    FIELD   Prih           like ub.stk-tot.fact-qnty
    FIELD   ostatok-end    like ub.stk-tot.fact-qnty
    FIELD   f-avr          LIKE f-avr
    FIELD   kASSA1         like ub.stk-tot.fact-qnty
    FIELD   KAssa2         like ub.stk-tot.fact-qnty
    FIELD   KAssa3         like ub.stk-tot.fact-qnty
    FIELD   KAssa4         like ub.stk-tot.fact-qnty
    FIELD   KAssa5         like ub.stk-tot.fact-qnty
    FIELD   KAssa6         like ub.stk-tot.fact-qnty
    INDEX Byf-avr   f-avr ASCENDING
    .
define variable     v#b-code         LIKE gds-zap-b-code no-undo.
define variable     v#artic          LIKE gds-zap-artic  no-undo.
define variable     v#prod-code      LIKE gds-zap-prod-code  no-undo.
define variable     v#prod-type      LIKE gds-zap-prod-type  no-undo.
define variable     v#prt-root       LIKE gds-zap-prt-root   no-undo.
define variable     v#grp-name       LIKE gds-zap-grp-name   no-undo.
define variable     v#F-zakaz        LIKE F-zakaz            no-undo.
define variable     v#F-center-stock LIKE F-center-stock     no-undo.
define variable     v#Prih           like ub.stk-tot.fact-qnty  no-undo.
define variable     v#ostatok-end    like ub.stk-tot.fact-qnty  no-undo.
define variable     v#f-avr          LIKE f-avr              no-undo.
define variable     v#kASSA1         like ub.stk-tot.fact-qnty  no-undo.
define variable     v#KAssa2         like ub.stk-tot.fact-qnty  no-undo.
define variable     v#KAssa3         like ub.stk-tot.fact-qnty  no-undo.
define variable     v#KAssa4         like ub.stk-tot.fact-qnty  no-undo.
define variable     v#KAssa5         like ub.stk-tot.fact-qnty  no-undo.
define variable     v#KAssa6         like ub.stk-tot.fact-qnty  no-undo.
define variable v-file-name as character no-undo .
define variable p-file-name as character no-undo .
define variable v-ind       as integer   no-undo .
define variable c-c      as integer no-undo .
define variable c-str    as character no-undo .
define variable str--1   as character format "x (60)" no-undo.
define variable str--2   as integer no-undo .
define variable c-i      as integer no-undo .
define variable p-var    as integer no-undo .
define variable num#col# as integer no-undo .
define variable var-1    as integer no-undo .
define variable var-2    as integer no-undo .
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
     assign
        i=0
        xlavel = xvar-lavel
        Select-Good   = x-SelectGood
        PayType       = x-SET_PAY_TYPE
        RetClassify   = xClassify
        RetSortType   = xSortType
        Sums-Only     = xSumsOnly
        Show-Negativ  = xShowZero
        FirstLine     = FALSE.
        Line          = fill ("-", 232).
        ValType       = IF  (PayType = 1) Then 0  else x-SET_val_TYPE.
        run report-execute in this-procedure .
PROCEDURE report-execute :
define variable l as integer no-undo .
define variable lL as integer no-undo .
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
    p-file-name =  string ( session:temp-directory +
                                  "rpt" + string ( g#report-num ) + ".txt" ) .
     output stream outstream to value ( string ( session:temp-directory +
                                  "rpt" + string ( g#report-num ) ) )      .
    run maket in this-procedure .
    run gbl/_tmpfile.p  ( "wb", ".txt", output v-file-name) .
    output stream macr_excel to value (v-file-name)   .
                put stream  outstream  "1" format "x (100)" skip .
    v-ind = 1    .
    num#str# = 0 .
      num#str# = num#str# + 1 .
      num#col# =  1 .
      run macr_excel_char_with_format ( reportname , num#str# , num#col#  ).
      run macr_cell_format
           ( 12    ,
            true  ,
            false ,
            ?     ,
            num#str# ,
            num#col# ,
            ? ,
            ?         ) .
define variable l-ii  as integer no-undo .
define variable l-jj  as integer no-undo .
define variable l-len as integer no-undo .
define variable l-m   as integer no-undo .
define variable v-nn as integer   no-undo .
v-nn = num-entries ( str1 , "chr(10)"  ) .  do l-ii = 1 to v-nn   :        l-len = length  (entry ( l-ii , str1  , "chr(10)")) .                       l-m = integer ( l-len / 220 ) + 1 .                                                      do l-jj = 1 to  l-m  :                                                                      num#str# = num#str# + 1 .                                                               run macr_excel_char_with_format (                                                                        substring (entry ( l-ii , str1  , "chr(10)") ,  ( ( 220 * l-jj ) - 219 )  , 220 )  , num#str# , num#col# ) .      end.                                                                                                         end.
v-nn = num-entries ( str2 , "chr(10)"  ) .  do l-ii = 1 to v-nn   :        l-len = length  (entry ( l-ii , str2  , "chr(10)")) .                       l-m = integer ( l-len / 220 ) + 1 .                                                      do l-jj = 1 to  l-m  :                                                                      num#str# = num#str# + 1 .                                                               run macr_excel_char_with_format (                                                                        substring (entry ( l-ii , str2  , "chr(10)") ,  ( ( 220 * l-jj ) - 219 )  , 220 )  , num#str# , num#col# ) .      end.                                                                                                         end.
v-nn = num-entries ( str3 , "chr(10)"  ) .  do l-ii = 1 to v-nn   :        l-len = length  (entry ( l-ii , str3  , "chr(10)")) .                       l-m = integer ( l-len / 220 ) + 1 .                                                      do l-jj = 1 to  l-m  :                                                                      num#str# = num#str# + 1 .                                                               run macr_excel_char_with_format (                                                                        substring (entry ( l-ii , str3  , "chr(10)") ,  ( ( 220 * l-jj ) - 219 )  , 220 )  , num#str# , num#col# ) .      end.                                                                                                         end.
v-nn = num-entries ( str4 , "chr(10)"  ) .  do l-ii = 1 to v-nn   :        l-len = length  (entry ( l-ii , str4  , "chr(10)")) .                       l-m = integer ( l-len / 220 ) + 1 .                                                      do l-jj = 1 to  l-m  :                                                                      num#str# = num#str# + 1 .                                                               run macr_excel_char_with_format (                                                                        substring (entry ( l-ii , str4  , "chr(10)") ,  ( ( 220 * l-jj ) - 219 )  , 220 )  , num#str# , num#col# ) .      end.                                                                                                         end.
v-nn = num-entries ( reportheader , "chr(10)"  ) .  do l-ii = 1 to v-nn   :        l-len = length  (entry ( l-ii , reportheader  , "chr(10)")) .                       l-m = integer ( l-len / 220 ) + 1 .                                                      do l-jj = 1 to  l-m  :                                                                      num#str# = num#str# + 1 .                                                               run macr_excel_char_with_format (                                                                        substring (entry ( l-ii , reportheader  , "chr(10)") ,  ( ( 220 * l-jj ) - 219 )  , 220 )  , num#str# , num#col# ) .      end.                                                                                                         end.
  num#str# = num#str# + 1.
  num#col# = 1.
  run macr_excel_char_with_format (
        "Дата печати : " + string (today,"99.99.9999") +  " , "     +
      " Цены указаны в " +
       (if tprintrubl then "РУБ" else x-base-type )
      , num#str#
      , num#col#
        ) .
run make-col in this-procedure .
run proc-print-header in this-procedure .
   define variable gj as integer no-undo init 0.
   if xtog-obj  then do:
      for each obj-list no-lock:
          x-store-type = obj-list.obj-type.
          x-store-code = obj-list.obj-code.
          run report-exec1 in this-procedure .
          gj = gj + 1 .
      end.
      if gj > 1 then   run display-bo in this-procedure .
      end.
   else  run report-exec1 in this-procedure .
   output stream outstream close.
   output stream outstream2 close.
  output stream macr_excel  close .
if mFrameView
then do:
   HIDE FRAME InfoFrame.
end.
    run paramls-write in this-procedure
       (input "file"
      ,input string (v-ind)
      ,input v-file-name
      ) .
    run paramls-write in this-procedure
       (input "charcol"
      ,input ""
      ,input "2"
      ) .
  run end-proc in this-procedure .
if mFrameView
then do:
   HIDE FRAME InfoFrame.
end.
  run rep/runexcel.p  (p-file-name ).
end procedure.
PROCEDURE foreach :
 R = R + 1.
IF ( r modulo v-account = 0 )  then DO:
 Assign
    v-kol-spice = (50 - LENGTH(objname)) / 2
    RecordsString = fill(' ',v-kol-spice) + string(objname)
    .
          if  log-manager:logfile-name ne ?
          then DO:
              log-manager:write-message("DISP mFrameView=" + string(mFrameView), "frameRepError").
          end.
           if mFrameView
           then do:
            DISPLAY
              r @ RecordsDone
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
  run clear-item in this-procedure .
  run zakaz in this-procedure .
  IF NOT Show-Negativ  AND  f-zakaz  = 0 THEN RETURN.
run ost-line in this-procedure
               (input   x-store-code  ,
                input   x-store-type  ,
                input   gds-zap-artic     ,
                input   gds-zap-prod-code ,
                input   gds-zap-prod-type ,
                input   x-tog-shift       ,
                input   Fact-order-2               ,
                input   'crsa':U            ,
                input   '##,##':U    ,
                input   xtog-obj    ,
                output  quantity    ,
                output  coast_r     ,
                output  coast_v     ,
                output  vat_r       ,
                output  vat_v       ,
                output  slt_r       ,
                output  slt_v       ).
assign
  ostatok-end [1 + 0]   = quantity
 ostatok-end [2 + 0]   = if tprintrubl then coast_r else coast_v
 ostatok-end [3 + 0]   = if tprintrubl then vat_r   else vat_v
 b1-ostatok-end [1 + 0] =  b1-ostatok-end [1 + 0] + ostatok-end [1 + 0]
 b1-ostatok-end [2 + 0] =  b1-ostatok-end [2 + 0] + ostatok-end [2 + 0]
 b1-ostatok-end [3 + 0] =  b1-ostatok-end [3 + 0] + ostatok-end [3 + 0]
 b2-ostatok-end [1 + 0] =  b2-ostatok-end [1 + 0] + ostatok-end [1 + 0]
 b2-ostatok-end [2 + 0] =  b2-ostatok-end [2 + 0] + ostatok-end [2 + 0]
 b2-ostatok-end [3 + 0] =  b2-ostatok-end [3 + 0] + ostatok-end [3 + 0]
 .
 assign
  bi-ostatok-end [1 + 0] =  bi-ostatok-end [1 + 0] + ostatok-end [1 + 0]
  bi-ostatok-end [2 + 0] =  bi-ostatok-end [2 + 0] + ostatok-end [2 + 0]
  bi-ostatok-end [3 + 0] =  bi-ostatok-end [3 + 0] + ostatok-end [3 + 0]
 .
   run ob-line in this-procedure ( input   x-store-code   ,  input   x-store-type   ,  input   gds-zap-artic       ,  input   gds-zap-prod-code   ,
      input   gds-zap-prod-type   ,
      input   fact-order-1,
      input   fact-order-2,
      input   'crsa':U    ,  input   '##,##':U, input   "", input   xtog-obj ,
      input   1 ,
      output prih[1]   ).
f-center-stock = f-zakaz - prih[1].
   run ob-line-1 in this-procedure ( input   x-store-code   , input   x-store-type   , input   gds-zap-artic       ,  input   gds-zap-prod-code   ,      input   gds-zap-prod-type   ,
      input   fo0,
      input   fo02,
      input   'crsa':U    ,   input   '##,##':U,   input   ""      ,   input   xtog-obj ,
      input   2 ,
      output kassa[1]   ).
 If Showorders = false THEN DO:
   run ob-line-1 in this-procedure ( input   x-store-code   , input   x-store-type   , input   gds-zap-artic       ,  input   gds-zap-prod-code   ,      input   gds-zap-prod-type   ,
      input   fo1,
      input   fo12,
      input   'crsa':U    ,   input   '##,##':U,   input   ""      ,   input   xtog-obj ,
      input   2 ,
      output kassa[2]   ).
   run ob-line-1 in this-procedure   ( input   x-store-code   , input   x-store-type   , input   gds-zap-artic       ,  input   gds-zap-prod-code   ,      input   gds-zap-prod-type   ,
      input   fo2,
      input   fo22,
      input   'crsa':U    ,   input   '##,##':U,   input   ""      ,   input   xtog-obj ,
      input   2 ,
      output kassa[3]   ).
   run ob-line-1 in this-procedure   ( input   x-store-code   , input   x-store-type   , input   gds-zap-artic       ,  input   gds-zap-prod-code   ,      input   gds-zap-prod-type   ,
      input   fo3,
      input   fo32,
      input   'crsa':U    ,   input   '##,##':U,   input   ""      ,   input   xtog-obj ,
      input   2 ,
      output kassa[4]   ).
   run ob-line-1 in this-procedure   ( input   x-store-code   , input   x-store-type   , input   gds-zap-artic       ,  input   gds-zap-prod-code   ,      input   gds-zap-prod-type   ,
      input   fo4,
      input   fo42,
      input   'crsa':U    ,   input   '##,##':U,   input   ""      ,   input   xtog-obj ,
      input   2 ,
      output kassa[5]   ).
   run ob-line-1 in this-procedure   ( input   x-store-code   , input   x-store-type   , input   gds-zap-artic       ,  input   gds-zap-prod-code   ,      input   gds-zap-prod-type   ,
      input   fo5,
      input   fo52,
      input   'crsa':U    ,   input   '##,##':U,   input   ""      ,   input   xtog-obj ,
      input   2 ,
      output kassa[6]   ).
end.
   f-avr = round ( kassa[1] / if integer (fo02 - fo0) = 0 then 1 else integer (fo02 - fo0) , 3) .
   if not tog-qnty then  run calc-sub-itog in this-procedure   (0).
      else do :
           rr = rr + 1 .
           run maketemptable in this-procedure   .
            return error.
      end.
END PROCEDURE.
PROCEDURE display-line :
     IF  NOT  (NOT Show-Negativ  AND   f-zakaz  = 0  aND PRIH[1] = 0  AND kassa[1] = 0 ) then DO:
        IF NOT Sums-Only then DO:
           ii = ii + 1.
           run display-str1 in this-procedure .
          End.
     END.
  END PROCEDURE.
PROCEDURE print-header :
define variable l-name as character no-undo .
define variable mm as integer no-undo .
define variable RANGES as character no-undo .
if Showorders = false then
    if NOT FirstLine Then  run display-title in this-procedure .
    FirstLine = TRUE .
    if xTog-obj and   x-SelectObject <> "currency":U   Then  DO:
       l-name =  "ПО ОБЪЕКТУ : " + CAPS (ObjName).
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
Num#str# = Num#str# + 1.
run macr_excel_char ( string(l-name)  , num#str# , 1 ) .
 .
          End.
  if showOrders then do :
      Number-Orders = "" .
        run macr_excel_char_with_format ( string ("№/№"                    )  , num#str# , 1) .
        run macr_excel_char_with_format ( string ("Артикул"                )  , num#str# , 2) .
        run macr_excel_char_with_format ( string ("Суммарный Заказ"        )  , num#str# , 3) .
        run macr_excel_char_with_format ( string ("Центр. склад"           )  , num#str# , 4) .
        run macr_excel_char_with_format ( string ("Приход"                 )  , num#str# , 5) .
        run macr_excel_char_with_format ( string ("Остаток"                )  , num#str# , 6) .
        run macr_excel_char_with_format ( string ("Реализ. Среднесуточная" )  , num#str# , 7) .
        run macr_excel_char_with_format ( string ("Касса за месяц"         )  , num#str# , 8) .
        run macr_cell_format  (
                        10       ,
                        true     ,
                        false    ,
                        35       ,
                        num#str#,
                        1        ,
                        num#str# ,
                        8 )
                        .
          mm = 8  .
          For each ub.trn-doc where
                  ub.trn-doc.doc-date <= x-date-end
            AND   ub.trn-doc.doc-date >= x-date-start
            AND   ub.trn-doc.status_   = 'запрос':U
            AND   ub.trn-doc.internal  = false
            AND   ub.trn-doc.obj-code   = x-store-code
            AND   ub.trn-doc.obj-type   = x-store-type
            no-lock :
                  Number-Orders = Number-orders +  ub.trn-doc.doc-code  + CHR(9).
                  sheetf.Sizes = sheetf.sizes + "15," .
                  mm = mm + 1 .
                    run macr_excel_char_with_format in this-procedure  ( ub.trn-doc.doc-code  , num#str# , mm ) .
                    run macr_cell_format in this-procedure   (
                        10       ,
                        true     ,
                        false    ,
                        35       ,
                        num#str#,
                        mm        ,
                        num#str# ,
                        mm )
                        .
          End.
      End.
      run clear-b1 in this-procedure  .
      run clear-b2 in this-procedure .
      run clear-bi in this-procedure  .
      run clear-item in this-procedure .
      break_group = true.
      break_group1 = true.
      num#str#  = num#str#  + 1 .
   END PROCEDURE.
PROCEDURE Print-Footer :
      if retclassify = "no-classify":u  then run u-line in this-procedure .
       gds-zap-artic = "ИТОГО" .
       run display-bi in this-procedure .
       run u-line in this-procedure .
       END PROCEDURE.
PROCEDURE U-LINE :
        END PROCEDURE.
PROCEDURE P-LINE :
        END PROCEDURE.
function func-vat returns decimal (
    input p-gds-code as integer  ,
    input p-obj-type as character ,
    input p-obj-code as integer  ).
define variable i-vat-pc as decimal no-undo .
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
procedure run1 :
 run run1sort2.
end procedure.
procedure run1sort2 :
       case select-good :
        when 1  then do:
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
IF x-SelectObject = "currency":U  OR  xTog-obj THEN DO :
    for each gds-obj  where
          gds-obj.obj-type = x-store-type  and
          gds-obj.obj-code = x-store-code
          and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
                no-lock,
          First goods  where  gds-obj.gds-code   = goods.gds-code
no-lock
BREAK
    BY (goods.artic) :
      run item-goods ( "1" , "goods" ) .
      if return-value <> "" then NEXT.
    End.
  END.
  Else DO:
   For each obj-list no-lock :
                  FOR EACH gds-obj where
                gds-obj.obj-type = obj-list.obj-type    and
                gds-obj.obj-code = obj-list.obj-code
                and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
                no-lock :
                if NOT can-find(First temp-gds-list where temp-gds-list.gds-code = gds-obj.gds-code) Then do:
                    find first goods no-lock  where goods.gds-code  = gds-obj.gds-code .
                    Create temp-gds-list.
                    Assign
                      temp-gds-list.prod-code = gds-obj.prod-code
                      temp-gds-list.grp-name  = gds-obj.grp-name
                      temp-gds-list.gds-name  = goods.gds-name
                      temp-gds-list.gds-code  = gds-obj.gds-code
                      temp-gds-list.artic     = gds-obj.artic
                    .
                End.
            End.
  End.
  for each temp-gds-list no-lock
    , First goods     where goods.gds-code  = temp-gds-list.gds-code no-lock
      BREAK
    BY goods.artic :
    run item-goods ( "1" , "goods" ) .
      if return-value <> "" then NEXT.
  End.
End.
  end.
        when 2  then do:
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  if x-selectobject = "currency":u  or  xtog-obj then do:
      for  each gds-obj
                  where gds-obj.obj-code   = x-store-code
                   and  gds-obj.obj-type   = x-store-type
                        and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
                        no-lock ,
              first  tmp#grp  where gds-obj.grp-name   begins tmp#grp.grp-name   no-lock ,
              first goods       where gds-obj.gds-code   = goods.gds-code  no-lock
                  break
                  by goods.artic :
                  run item-goods ( input "1" , input "goods" ) .
                  if return-value <> "" then next.
      end.
  end.
  else do:
      for each obj-list no-lock :
            for  each gds-obj
              where  gds-obj.obj-code   = obj-list.obj-code
                and  gds-obj.obj-type   = obj-list.obj-type
                     and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
              no-lock ,
              first  tmp#grp  where gds-obj.grp-name   begins tmp#grp.grp-name   no-lock ,
              first goods       where gds-obj.gds-code   = goods.gds-code  no-lock :
                    if not can-find(first temp-gds-list where temp-gds-list.gds-code = gds-obj.gds-code) then do:
                        create temp-gds-list.
                        assign
                          temp-gds-list.prod-code = gds-obj.prod-code
                          temp-gds-list.grp-name  = gds-obj.grp-name
                          temp-gds-list.gds-name  = goods.grp-name
                          temp-gds-list.gds-code  = gds-obj.gds-code
                          temp-gds-list.artic     = gds-obj.artic
                        .
                    end.
            end.
    end.
  for each temp-gds-list no-lock
    , first goods  where goods.gds-code  = temp-gds-list.gds-code no-lock
      break
    by goods.artic :
    run item-goods ( "1" , "goods" ) .
      if return-value <> "" then next.
  end.
end.
  end.
        when 3 then do:
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if x-selectobject = "currency":u  or  xtog-obj then do:
  for  each gds-obj
      where  gds-obj.obj-code   = x-store-code
        and  gds-obj.obj-type   = x-store-type
              and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
              no-lock ,
  first g#cli
        where gds-obj.prod-code  = g#cli.obj-code
        and  gds-obj.prod-type   = g#cli.obj-type
        no-lock,
  first goods
        where gds-obj.gds-code = goods.gds-code no-lock
        break
        by goods.artic :
        run item-goods ( "1" , "goods" ) .
        if return-value <> "" then next.
      end.
  end.
  else do:
    for each obj-list no-lock :
          for  each gds-obj
            where  gds-obj.obj-code   = obj-list.obj-code
              and  gds-obj.obj-type   = obj-list.obj-type
                    and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
                    no-lock ,
          first g#cli
              where gds-obj.prod-code  = g#cli.obj-code
              and  gds-obj.prod-type   = g#cli.obj-type
              no-lock,
          first goods
              where gds-obj.gds-code = goods.gds-code no-lock :
                if not can-find (first temp-gds-list where temp-gds-list.gds-code = gds-obj.gds-code) then do:
                    create temp-gds-list.
                    assign
                      temp-gds-list.prod-code = gds-obj.prod-code
                      temp-gds-list.grp-name  = gds-obj.grp-name
                      temp-gds-list.gds-name  = goods.gds-name
                      temp-gds-list.gds-code  = gds-obj.gds-code
                      temp-gds-list.artic     = gds-obj.artic
                    .
                end.
          end.
    end.
      for each temp-gds-list no-lock
        , first goods  where goods.gds-code  = temp-gds-list.gds-code no-lock
          break
            by goods.artic :
        run item-goods ( "1" , "goods" ) .
          if return-value <> "" then next.
      end.
end.
  end.
        otherwise do:
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
IF x-SelectObject = "currency":U  OR  xTog-obj THEN DO :
    for each gds-obj  where
          gds-obj.obj-type = x-store-type  and
          gds-obj.obj-code = x-store-code
          and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
                no-lock,
          First goods  where  gds-obj.gds-code   = goods.gds-code
      no-lock,
First gds-list  where gds-obj.gds-code  = gds-list.gds-code
no-lock
BREAK
    BY (gds-list.artic) :
      run item-goods ( "1" , "gds-list" ) .
      if return-value <> "" then NEXT.
    End.
  END.
  Else DO:
   For each obj-list no-lock :
                  FOR EACH gds-obj where
                gds-obj.obj-type = obj-list.obj-type    and
                gds-obj.obj-code = obj-list.obj-code
                and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
                no-lock,
          First gds-list  where gds-obj.gds-code  = gds-list.gds-code
                no-lock :
                if NOT can-find(First temp-gds-list where temp-gds-list.gds-code = gds-obj.gds-code) Then do:
                    find first goods no-lock  where goods.gds-code  = gds-obj.gds-code .
                    Create temp-gds-list.
                    Assign
                      temp-gds-list.prod-code = gds-obj.prod-code
                      temp-gds-list.grp-name  = gds-obj.grp-name
                      temp-gds-list.gds-name  = goods.gds-name
                      temp-gds-list.gds-code  = gds-obj.gds-code
                      temp-gds-list.artic     = gds-obj.artic
                    .
                End.
            End.
  End.
  for each temp-gds-list no-lock
    , First gds-list  where gds-list.gds-code  = temp-gds-list.gds-code no-lock
      BREAK
    BY gds-list.artic :
    run item-goods ( "1" , "gds-list" ) .
      if return-value <> "" then NEXT.
  End.
End.
        end.
        end case.
end procedure.
procedure run2 :
     if not xtog-lavel then do:   run run2sort1.   end.
       else do:   run lavel1.    end.
   end procedure.
procedure run2sort1 :
    case select-good :
        when 1  then do:
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
IF x-SelectObject = "currency":U  OR  xTog-obj THEN DO :
    for each gds-obj  where
          gds-obj.obj-type = x-store-type  and
          gds-obj.obj-code = x-store-code
          and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
                no-lock,
          First goods  where  gds-obj.gds-code   = goods.gds-code
no-lock
BREAK
      BY (gds-obj.grp-name)
    BY (goods.artic) :
      run item-goods ( "3" , "goods" ) .
      if return-value <> "" then NEXT.
        If Last-of(gds-obj.grp-name) Then Do:
        If String(Entry(2,"gds-obj.grp-name",".")) = "Grp-name"
          Then  Assign
                  S-bar-code   = " Итого по "
                  Gds-zap-artic = Substring(
                                      B1-name
                                      ,1,16)
                  Gds-zap-gds-name = Substring(
                                      B1-name
                                      ,17,40)
                                .
          Else  Assign
                  S-bar-code   = ""
                  Gds-zap-artic = "        Итого по "
                  Gds-zap-gds-name =  B1-name
                                .
            Run Display-b1 In This-procedure .
            Run Clear-b1 In This-procedure .
            Assign Break_Group = True.
        End.
    End.
  END.
  Else DO:
   For each obj-list no-lock :
                  FOR EACH gds-obj where
                gds-obj.obj-type = obj-list.obj-type    and
                gds-obj.obj-code = obj-list.obj-code
                and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
                no-lock :
                if NOT can-find(First temp-gds-list where temp-gds-list.gds-code = gds-obj.gds-code) Then do:
                    find first goods no-lock  where goods.gds-code  = gds-obj.gds-code .
                    Create temp-gds-list.
                    Assign
                      temp-gds-list.prod-code = gds-obj.prod-code
                      temp-gds-list.grp-name  = gds-obj.grp-name
                      temp-gds-list.gds-name  = goods.gds-name
                      temp-gds-list.gds-code  = gds-obj.gds-code
                      temp-gds-list.artic     = gds-obj.artic
                    .
                End.
            End.
  End.
  for each temp-gds-list no-lock
    , First goods     where goods.gds-code  = temp-gds-list.gds-code no-lock
      BREAK
BY (gds-obj.grp-name)
    BY goods.artic :
    run item-goods ( "3" , "goods" ) .
      if return-value <> "" then NEXT.
        If Last-of(gds-obj.grp-name) Then Do:
        If String(Entry(2,"gds-obj.grp-name",".")) = "Grp-name"
          Then  Assign
                  S-bar-code   = " Итого по "
                  Gds-zap-artic = Substring(
                                      B1-name
                                      ,1,16)
                  Gds-zap-gds-name = Substring(
                                      B1-name
                                      ,17,40)
                                .
          Else  Assign
                  S-bar-code   = ""
                  Gds-zap-artic = "        Итого по "
                  Gds-zap-gds-name =  B1-name
                                .
            Run Display-b1 In This-procedure .
            Run Clear-b1 In This-procedure .
            Assign Break_Group = True.
        End.
  End.
End.
   end.
        when 2  then do:
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  if x-selectobject = "currency":u  or  xtog-obj then do:
      for  each gds-obj
                  where gds-obj.obj-code   = x-store-code
                   and  gds-obj.obj-type   = x-store-type
                        and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
                        no-lock ,
              first  tmp#grp  where gds-obj.grp-name   begins tmp#grp.grp-name   no-lock ,
              first goods       where gds-obj.gds-code   = goods.gds-code  no-lock
                  break
                  by gds-obj.grp-name
                  by goods.artic :
                  run item-goods ( input "3" , input "goods" ) .
                  if return-value <> "" then next.
        If Last-of(gds-obj.grp-name) Then Do:
        If String(Entry(2,"gds-obj.grp-name",".")) = "Grp-name"
          Then  Assign
                  S-bar-code   = " Итого по "
                  Gds-zap-artic = Substring(
                                      B1-name
                                      ,1,16)
                  Gds-zap-gds-name = Substring(
                                      B1-name
                                      ,17,40)
                                .
          Else  Assign
                  S-bar-code   = ""
                  Gds-zap-artic = "        Итого по "
                  Gds-zap-gds-name =  B1-name
                                .
            Run Display-b1 In This-procedure .
            Run Clear-b1 In This-procedure .
            Assign Break_Group = True.
        End.
      end.
  end.
  else do:
      for each obj-list no-lock :
            for  each gds-obj
              where  gds-obj.obj-code   = obj-list.obj-code
                and  gds-obj.obj-type   = obj-list.obj-type
                     and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
              no-lock ,
              first  tmp#grp  where gds-obj.grp-name   begins tmp#grp.grp-name   no-lock ,
              first goods       where gds-obj.gds-code   = goods.gds-code  no-lock :
                    if not can-find(first temp-gds-list where temp-gds-list.gds-code = gds-obj.gds-code) then do:
                        create temp-gds-list.
                        assign
                          temp-gds-list.prod-code = gds-obj.prod-code
                          temp-gds-list.grp-name  = gds-obj.grp-name
                          temp-gds-list.gds-name  = goods.grp-name
                          temp-gds-list.gds-code  = gds-obj.gds-code
                          temp-gds-list.artic     = gds-obj.artic
                        .
                    end.
            end.
    end.
  for each temp-gds-list no-lock
    , first goods  where goods.gds-code  = temp-gds-list.gds-code no-lock
      break
        by gds-obj.grp-name
    by goods.artic :
    run item-goods ( "3" , "goods" ) .
      if return-value <> "" then next.
        If Last-of(gds-obj.grp-name) Then Do:
        If String(Entry(2,"gds-obj.grp-name",".")) = "Grp-name"
          Then  Assign
                  S-bar-code   = " Итого по "
                  Gds-zap-artic = Substring(
                                      B1-name
                                      ,1,16)
                  Gds-zap-gds-name = Substring(
                                      B1-name
                                      ,17,40)
                                .
          Else  Assign
                  S-bar-code   = ""
                  Gds-zap-artic = "        Итого по "
                  Gds-zap-gds-name =  B1-name
                                .
            Run Display-b1 In This-procedure .
            Run Clear-b1 In This-procedure .
            Assign Break_Group = True.
        End.
  end.
end.
   end.
        when 3 then do:
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if x-selectobject = "currency":u  or  xtog-obj then do:
  for  each gds-obj
      where  gds-obj.obj-code   = x-store-code
        and  gds-obj.obj-type   = x-store-type
              and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
              no-lock ,
  first g#cli
        where gds-obj.prod-code  = g#cli.obj-code
        and  gds-obj.prod-type   = g#cli.obj-type
        no-lock,
  first goods
        where gds-obj.gds-code = goods.gds-code no-lock
        break
        by (gds-obj.grp-name)
        by goods.artic :
        run item-goods ( "3" , "goods" ) .
        if return-value <> "" then next.
        If Last-of(gds-obj.grp-name) Then Do:
        If String(Entry(2,"gds-obj.grp-name",".")) = "Grp-name"
          Then  Assign
                  S-bar-code   = " Итого по "
                  Gds-zap-artic = Substring(
                                      B1-name
                                      ,1,16)
                  Gds-zap-gds-name = Substring(
                                      B1-name
                                      ,17,40)
                                .
          Else  Assign
                  S-bar-code   = ""
                  Gds-zap-artic = "        Итого по "
                  Gds-zap-gds-name =  B1-name
                                .
            Run Display-b1 In This-procedure .
            Run Clear-b1 In This-procedure .
            Assign Break_Group = True.
        End.
      end.
  end.
  else do:
    for each obj-list no-lock :
          for  each gds-obj
            where  gds-obj.obj-code   = obj-list.obj-code
              and  gds-obj.obj-type   = obj-list.obj-type
                    and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
                    no-lock ,
          first g#cli
              where gds-obj.prod-code  = g#cli.obj-code
              and  gds-obj.prod-type   = g#cli.obj-type
              no-lock,
          first goods
              where gds-obj.gds-code = goods.gds-code no-lock :
                if not can-find (first temp-gds-list where temp-gds-list.gds-code = gds-obj.gds-code) then do:
                    create temp-gds-list.
                    assign
                      temp-gds-list.prod-code = gds-obj.prod-code
                      temp-gds-list.grp-name  = gds-obj.grp-name
                      temp-gds-list.gds-name  = goods.gds-name
                      temp-gds-list.gds-code  = gds-obj.gds-code
                      temp-gds-list.artic     = gds-obj.artic
                    .
                end.
          end.
    end.
      for each temp-gds-list no-lock
        , first goods  where goods.gds-code  = temp-gds-list.gds-code no-lock
          break
            by (gds-obj.grp-name)
            by goods.artic :
        run item-goods ( "3" , "goods" ) .
          if return-value <> "" then next.
        If Last-of(gds-obj.grp-name) Then Do:
        If String(Entry(2,"gds-obj.grp-name",".")) = "Grp-name"
          Then  Assign
                  S-bar-code   = " Итого по "
                  Gds-zap-artic = Substring(
                                      B1-name
                                      ,1,16)
                  Gds-zap-gds-name = Substring(
                                      B1-name
                                      ,17,40)
                                .
          Else  Assign
                  S-bar-code   = ""
                  Gds-zap-artic = "        Итого по "
                  Gds-zap-gds-name =  B1-name
                                .
            Run Display-b1 In This-procedure .
            Run Clear-b1 In This-procedure .
            Assign Break_Group = True.
        End.
      end.
end.
   end.
        otherwise do:
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
IF x-SelectObject = "currency":U  OR  xTog-obj THEN DO :
    for each gds-obj  where
          gds-obj.obj-type = x-store-type  and
          gds-obj.obj-code = x-store-code
          and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
                no-lock,
          First goods  where  gds-obj.gds-code   = goods.gds-code
      no-lock,
First gds-list  where gds-obj.gds-code  = gds-list.gds-code
no-lock
BREAK
      BY (gds-list.grp-name)
    BY (gds-list.artic) :
      run item-goods ( "3" , "gds-list" ) .
      if return-value <> "" then NEXT.
        If Last-of(gds-list.grp-name) Then Do:
        If String(Entry(2,"gds-list.grp-name",".")) = "Grp-name"
          Then  Assign
                  S-bar-code   = " Итого по "
                  Gds-zap-artic = Substring(
                                      B1-name
                                      ,1,16)
                  Gds-zap-gds-name = Substring(
                                      B1-name
                                      ,17,40)
                                .
          Else  Assign
                  S-bar-code   = ""
                  Gds-zap-artic = "        Итого по "
                  Gds-zap-gds-name =  B1-name
                                .
            Run Display-b1 In This-procedure .
            Run Clear-b1 In This-procedure .
            Assign Break_Group = True.
        End.
    End.
  END.
  Else DO:
   For each obj-list no-lock :
                  FOR EACH gds-obj where
                gds-obj.obj-type = obj-list.obj-type    and
                gds-obj.obj-code = obj-list.obj-code
                and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
                no-lock,
          First gds-list  where gds-obj.gds-code  = gds-list.gds-code
                no-lock :
                if NOT can-find(First temp-gds-list where temp-gds-list.gds-code = gds-obj.gds-code) Then do:
                    find first goods no-lock  where goods.gds-code  = gds-obj.gds-code .
                    Create temp-gds-list.
                    Assign
                      temp-gds-list.prod-code = gds-obj.prod-code
                      temp-gds-list.grp-name  = gds-obj.grp-name
                      temp-gds-list.gds-name  = goods.gds-name
                      temp-gds-list.gds-code  = gds-obj.gds-code
                      temp-gds-list.artic     = gds-obj.artic
                    .
                End.
            End.
  End.
  for each temp-gds-list no-lock
    , First gds-list  where gds-list.gds-code  = temp-gds-list.gds-code no-lock
      BREAK
BY (gds-list.grp-name)
    BY gds-list.artic :
    run item-goods ( "3" , "gds-list" ) .
      if return-value <> "" then NEXT.
        If Last-of(gds-list.grp-name) Then Do:
        If String(Entry(2,"gds-list.grp-name",".")) = "Grp-name"
          Then  Assign
                  S-bar-code   = " Итого по "
                  Gds-zap-artic = Substring(
                                      B1-name
                                      ,1,16)
                  Gds-zap-gds-name = Substring(
                                      B1-name
                                      ,17,40)
                                .
          Else  Assign
                  S-bar-code   = ""
                  Gds-zap-artic = "        Итого по "
                  Gds-zap-gds-name =  B1-name
                                .
            Run Display-b1 In This-procedure .
            Run Clear-b1 In This-procedure .
            Assign Break_Group = True.
        End.
  End.
End.
        end.
      end case.
end procedure.
procedure lavel1 :
              case select-good :
                  when 1  then do:
    define buffer buf_obj-list26 for obj-list.
  for each buf_obj-list26 no-lock :
      if xtog-obj and  not (buf_obj-list26.obj-type = x-store-type  and
                            buf_obj-list26.obj-code = x-store-code )
      then next.
        for  each gds-obj   where
                            gds-obj.obj-type = buf_obj-list26.obj-type    and
                            gds-obj.obj-code = buf_obj-list26.obj-code
                            and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
                            no-lock ,
        first goods where gds-obj.gds-code  = goods.gds-code
                            no-lock :
            if not can-find(first temp-gds-list where temp-gds-list.gds-code = gds-obj.gds-code) then do:
                create temp-gds-list.
                assign
                  temp-gds-list.prod-code = gds-obj.prod-code
                  temp-gds-list.grp-name  = ""
                  temp-gds-list.gds-code  = gds-obj.gds-code
                  temp-gds-list.artic     = gds-obj.artic
                  temp-gds-list.gds-name  = goods.gds-name
                  .
                  temp-gds-list.grp-name  = n-lavel(input gds-obj.grp-name, input xlavel )
                  .
            end.
        end.
 end.
  for each temp-gds-list no-lock
    , first goods  where goods.gds-code  = temp-gds-list.gds-code no-lock
      break
        by  temp-gds-list.grp-name
        by goods.artic :
        str = n-lavel(input goods.grp-name, input xlavel ) no-error .
find clients where clients.obj-type = goods.prod-type and
                   clients.obj-code = goods.prod-code no-lock .
  assign
      gds-zap-unit-base  = goods.unit-base
      gds-zap-prt-root   = goods.prt-root
      gds-zap-prod-type  = goods.prod-type
      gds-zap-prod-code  = goods.prod-code
      gds-zap-artic      = goods.artic
      gds-zap-type       = goods.gds-type
      gds-zap-grp-name   = goods.grp-name
      gds-zap-b-code     = goods.gds-code
      gds-zap-prod-name  = clients.obj-name .
  if g#gds-engl then
      assign gds-zap-gds-name = goods.engl-name.
  else
      assign gds-zap-gds-name = goods.gds-name.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  gds-zap-b-code
  ,input  ?
  ,output v-bar-code
  )  .
  s-bar-code = string (v-bar-code,"999999999").
  run foreach in this-procedure .
    if  first-of ( temp-gds-list.grp-name )  then do:
        fr = true .
        l-stroka = "ГРУППА : " + str .
        temp-str = l-stroka.
    end.
   run display-line in this-procedure .
   if last-of( temp-gds-list.grp-name ) then do:
      s-bar-code = "Итого по " .
      gds-zap-artic = substring(str,1,16) .
      gds-zap-gds-name = substring(str,17,250) .
      run display-b1 in this-procedure .
      run clear-b1 in this-procedure .
      run clear-b2 in this-procedure .
   end.
  end.
   end.
                  when 2  then do:
    define buffer buf_obj-list27 for obj-list.
  for each buf_obj-list27 no-lock :
      if xtog-obj and  not (buf_obj-list27.obj-type = x-store-type  and
                            buf_obj-list27.obj-code = x-store-code )
      then next.
        for  each gds-obj   where
                            gds-obj.obj-type = buf_obj-list27.obj-type    and
                            gds-obj.obj-code = buf_obj-list27.obj-code
                            and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
                              no-lock ,
        first  tmp#grp
              where  gds-obj.grp-name   begins tmp#grp.grp-name
                  no-lock ,
        first goods where gds-obj.gds-code  = goods.gds-code
                            no-lock :
            if not can-find(first temp-gds-list where temp-gds-list.gds-code = gds-obj.gds-code) then do:
                create temp-gds-list.
                assign
                  temp-gds-list.prod-code = gds-obj.prod-code
                  temp-gds-list.grp-name  = ""
                  temp-gds-list.gds-code  = gds-obj.gds-code
                  temp-gds-list.artic     = gds-obj.artic
                  temp-gds-list.gds-name  = goods.gds-name
                  .
                  temp-gds-list.grp-name  = n-lavel(input gds-obj.grp-name, input xlavel )
                  .
            end.
        end.
 end.
  for each temp-gds-list no-lock
    , first goods  where goods.gds-code  = temp-gds-list.gds-code no-lock
      break
        by  temp-gds-list.grp-name
        by goods.artic :
        str = n-lavel(input goods.grp-name, input xlavel ) no-error .
find clients where clients.obj-type = goods.prod-type and
                   clients.obj-code = goods.prod-code no-lock .
  assign
      gds-zap-unit-base  = goods.unit-base
      gds-zap-prt-root   = goods.prt-root
      gds-zap-prod-type  = goods.prod-type
      gds-zap-prod-code  = goods.prod-code
      gds-zap-artic      = goods.artic
      gds-zap-type       = goods.gds-type
      gds-zap-grp-name   = goods.grp-name
      gds-zap-b-code     = goods.gds-code
      gds-zap-prod-name  = clients.obj-name .
  if g#gds-engl then
      assign gds-zap-gds-name = goods.engl-name.
  else
      assign gds-zap-gds-name = goods.gds-name.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  gds-zap-b-code
  ,input  ?
  ,output v-bar-code
  )  .
  s-bar-code = string (v-bar-code,"999999999").
  run foreach in this-procedure .
    if  first-of ( temp-gds-list.grp-name )  then do:
        fr = true .
        l-stroka = "ГРУППА : " + str .
        temp-str = l-stroka.
    end.
   run display-line in this-procedure .
   if last-of( temp-gds-list.grp-name ) then do:
      s-bar-code = "Итого по " .
      gds-zap-artic = substring(str,1,16) .
      gds-zap-gds-name = substring(str,17,250) .
      run display-b1 in this-procedure .
      run clear-b1 in this-procedure .
      run clear-b2 in this-procedure .
   end.
  end.
   end.
                  when 3 then do:
    define buffer buf_obj-list28 for obj-list.
  for each buf_obj-list28 no-lock :
      if xtog-obj and  not (buf_obj-list28.obj-type = x-store-type  and
                            buf_obj-list28.obj-code = x-store-code )
      then next.
        for  each gds-obj   where
                  gds-obj.obj-type = buf_obj-list28.obj-type    and
                  gds-obj.obj-code = buf_obj-list28.obj-code
                  and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
                    no-lock ,
        first g#cli
              where    g#cli.obj-code = gds-obj.prod-code
              and      g#cli.obj-type = gds-obj.prod-type
                       no-lock ,
        first goods where goods.gds-code = gds-obj.gds-code
                            no-lock :
            if not can-find ( first temp-gds-list where temp-gds-list.gds-code = gds-obj.gds-code) then do:
                create temp-gds-list.
                assign
                  temp-gds-list.prod-code = gds-obj.prod-code
                  temp-gds-list.grp-name  = ""
                  temp-gds-list.gds-code  = gds-obj.gds-code
                  temp-gds-list.artic     = gds-obj.artic
                  temp-gds-list.gds-name  = goods.gds-name
                  .
                  temp-gds-list.grp-name  = n-lavel(input gds-obj.grp-name, input xlavel )
                  .
            end.
        end.
 end.
  for each temp-gds-list no-lock
    , first goods     where goods.gds-code     = temp-gds-list.gds-code no-lock
      break
        by  temp-gds-list.grp-name
        by goods.artic :
        str = n-lavel(input goods.grp-name, input xlavel ) no-error .
find clients where clients.obj-type = goods.prod-type and
                   clients.obj-code = goods.prod-code no-lock .
  assign
      gds-zap-unit-base  = goods.unit-base
      gds-zap-prt-root   = goods.prt-root
      gds-zap-prod-type  = goods.prod-type
      gds-zap-prod-code  = goods.prod-code
      gds-zap-artic      = goods.artic
      gds-zap-type       = goods.gds-type
      gds-zap-grp-name   = goods.grp-name
      gds-zap-b-code     = goods.gds-code
      gds-zap-prod-name  = clients.obj-name .
  if g#gds-engl then
      assign gds-zap-gds-name = goods.engl-name.
  else
      assign gds-zap-gds-name = goods.gds-name.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  gds-zap-b-code
  ,input  ?
  ,output v-bar-code
  )  .
  s-bar-code = string (v-bar-code,"999999999").
  run foreach in this-procedure .
    if  first-of ( temp-gds-list.grp-name )  then do:
        fr = true .
        l-stroka = "ГРУППА : " + str .
        temp-str = l-stroka.
    end.
   run display-line in this-procedure .
   if last-of( temp-gds-list.grp-name ) then do:
      s-bar-code = "Итого по " .
      gds-zap-artic = substring(str,1,16) .
      gds-zap-gds-name = substring(str,17,250) .
      run display-b1 in this-procedure .
      run clear-b1 in this-procedure .
      run clear-b2 in this-procedure .
   end.
  end.
   end.
                  otherwise do:
    define buffer buf_obj-list29 for obj-list.
  for each buf_obj-list29 no-lock :
      if xtog-obj and  not (buf_obj-list29.obj-type = x-store-type  and
                            buf_obj-list29.obj-code = x-store-code )
      then next.
        for  each gds-obj   where
                            gds-obj.obj-type = buf_obj-list29.obj-type    and
                            gds-obj.obj-code = buf_obj-list29.obj-code
                            and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
                            no-lock ,
        first gds-list where gds-obj.gds-code  = gds-list.gds-code
                            no-lock :
            if not can-find(first temp-gds-list where temp-gds-list.gds-code = gds-obj.gds-code) then do:
                create temp-gds-list.
                assign
                  temp-gds-list.prod-code = gds-obj.prod-code
                  temp-gds-list.grp-name  = ""
                  temp-gds-list.gds-code  = gds-obj.gds-code
                  temp-gds-list.artic     = gds-obj.artic
                  temp-gds-list.gds-name  = gds-list.gds-name
                  .
                  temp-gds-list.grp-name  = n-lavel(input gds-obj.grp-name, input xlavel )
                  .
            end.
        end.
 end.
  for each temp-gds-list no-lock
    , first gds-list  where gds-list.gds-code  = temp-gds-list.gds-code no-lock
      break
        by  temp-gds-list.grp-name
        by gds-list.artic :
        str = n-lavel(input gds-list.grp-name, input xlavel ) no-error .
find clients where clients.obj-type = gds-list.prod-type and
                   clients.obj-code = gds-list.prod-code no-lock .
  assign
      gds-zap-unit-base  = gds-list.unit-base
      gds-zap-prt-root   = gds-list.prt-root
      gds-zap-prod-type  = gds-list.prod-type
      gds-zap-prod-code  = gds-list.prod-code
      gds-zap-artic      = gds-list.artic
      gds-zap-type       = gds-list.gds-type
      gds-zap-grp-name   = gds-list.grp-name
      gds-zap-b-code     = gds-list.gds-code
      gds-zap-prod-name  = clients.obj-name .
  if g#gds-engl then
      assign gds-zap-gds-name = gds-list.engl-name.
  else
      assign gds-zap-gds-name = gds-list.gds-name.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  gds-zap-b-code
  ,input  ?
  ,output v-bar-code
  )  .
  s-bar-code = string (v-bar-code,"999999999").
  run foreach in this-procedure .
    if  first-of ( temp-gds-list.grp-name )  then do:
        fr = true .
        l-stroka = "ГРУППА : " + str .
        temp-str = l-stroka.
    end.
   run display-line in this-procedure .
   if last-of( temp-gds-list.grp-name ) then do:
      s-bar-code = "Итого по " .
      gds-zap-artic = substring(str,1,16) .
      gds-zap-gds-name = substring(str,17,250) .
      run display-b1 in this-procedure .
      run clear-b1 in this-procedure .
      run clear-b2 in this-procedure .
   end.
  end.
                  end.
              end case.
end procedure.
procedure run3 :
  run run3sort2.
end procedure.
procedure run3sort2 :
  case select-good :
    when 1  then do:
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
IF x-SelectObject = "currency":U  OR  xTog-obj THEN DO :
    for each gds-obj  where
          gds-obj.obj-type = x-store-type  and
          gds-obj.obj-code = x-store-code
          and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
      no-lock,
First clients  where  clients.obj-code = gds-obj.prod-code and
                      clients.obj-type = gds-obj.prod-type
                no-lock,
          First goods  where  gds-obj.gds-code   = goods.gds-code
no-lock
BREAK
      BY ((substring(clients.obj-name,1,10) + string(gds-obj.prod-code)))
    BY (goods.artic) :
      run item-goods ( "2" , "goods" ) .
      if return-value <> "" then NEXT.
        If Last-of((substring(clients.obj-name,1,10) + string(gds-obj.prod-code))) Then Do:
        If String(Entry(2,"(substring(clients.obj-name,1,10) + string(gds-obj.prod-code))",".")) = "Grp-name"
          Then  Assign
                  S-bar-code   = " Итого по "
                  Gds-zap-artic = Substring(
                                      B1-name
                                      ,1,16)
                  Gds-zap-gds-name = Substring(
                                      B1-name
                                      ,17,40)
                                .
          Else  Assign
                  S-bar-code   = ""
                  Gds-zap-artic = "        Итого по "
                  Gds-zap-gds-name =  B1-name
                                .
            Run Display-b1 In This-procedure .
            Run Clear-b1 In This-procedure .
            Assign Break_Group = True.
        End.
    End.
  END.
  Else DO:
   For each obj-list no-lock :
                  FOR EACH gds-obj where
                gds-obj.obj-type = obj-list.obj-type    and
                gds-obj.obj-code = obj-list.obj-code
                and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
                no-lock :
                if NOT can-find(First temp-gds-list where temp-gds-list.gds-code = gds-obj.gds-code) Then do:
                    find first goods no-lock  where goods.gds-code  = gds-obj.gds-code .
                    Create temp-gds-list.
                    Assign
                      temp-gds-list.prod-code = gds-obj.prod-code
                      temp-gds-list.grp-name  = gds-obj.grp-name
                      temp-gds-list.gds-name  = goods.gds-name
                      temp-gds-list.gds-code  = gds-obj.gds-code
                      temp-gds-list.artic     = gds-obj.artic
                    .
                End.
            End.
  End.
  for each temp-gds-list no-lock
    , First goods     where goods.gds-code  = temp-gds-list.gds-code no-lock
                                     , First clients   where  clients.obj-code = goods.prod-code and
                                                              clients.obj-type = goods.prod-type
      BREAK
BY ((substring(clients.obj-name,1,10) + string(gds-obj.prod-code)))
    BY goods.artic :
    run item-goods ( "2" , "goods" ) .
      if return-value <> "" then NEXT.
        If Last-of((substring(clients.obj-name,1,10) + string(gds-obj.prod-code))) Then Do:
        If String(Entry(2,"(substring(clients.obj-name,1,10) + string(gds-obj.prod-code))",".")) = "Grp-name"
          Then  Assign
                  S-bar-code   = " Итого по "
                  Gds-zap-artic = Substring(
                                      B1-name
                                      ,1,16)
                  Gds-zap-gds-name = Substring(
                                      B1-name
                                      ,17,40)
                                .
          Else  Assign
                  S-bar-code   = ""
                  Gds-zap-artic = "        Итого по "
                  Gds-zap-gds-name =  B1-name
                                .
            Run Display-b1 In This-procedure .
            Run Clear-b1 In This-procedure .
            Assign Break_Group = True.
        End.
  End.
End.
  end.
    when 2  then do:
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  if x-selectobject = "currency":u  or  xtog-obj then do:
      for  each gds-obj
                  where gds-obj.obj-code   = x-store-code
                   and  gds-obj.obj-type   = x-store-type
                        and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
                        no-lock ,
              first  tmp#grp  where gds-obj.grp-name   begins tmp#grp.grp-name   no-lock ,
              first goods       where gds-obj.gds-code   = goods.gds-code  no-lock
                  break
                  by (substring(clients.obj-name,1,10) + string(gds-obj.prod-code))
                  by goods.artic :
                  run item-goods ( input "2" , input "goods" ) .
                  if return-value <> "" then next.
        If Last-of((substring(clients.obj-name,1,10) + string(gds-obj.prod-code))) Then Do:
        If String(Entry(2,"(substring(clients.obj-name,1,10) + string(gds-obj.prod-code))",".")) = "Grp-name"
          Then  Assign
                  S-bar-code   = " Итого по "
                  Gds-zap-artic = Substring(
                                      B1-name
                                      ,1,16)
                  Gds-zap-gds-name = Substring(
                                      B1-name
                                      ,17,40)
                                .
          Else  Assign
                  S-bar-code   = ""
                  Gds-zap-artic = "        Итого по "
                  Gds-zap-gds-name =  B1-name
                                .
            Run Display-b1 In This-procedure .
            Run Clear-b1 In This-procedure .
            Assign Break_Group = True.
        End.
      end.
  end.
  else do:
      for each obj-list no-lock :
            for  each gds-obj
              where  gds-obj.obj-code   = obj-list.obj-code
                and  gds-obj.obj-type   = obj-list.obj-type
                     and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
              no-lock ,
              first  tmp#grp  where gds-obj.grp-name   begins tmp#grp.grp-name   no-lock ,
              first goods       where gds-obj.gds-code   = goods.gds-code  no-lock :
                    if not can-find(first temp-gds-list where temp-gds-list.gds-code = gds-obj.gds-code) then do:
                        create temp-gds-list.
                        assign
                          temp-gds-list.prod-code = gds-obj.prod-code
                          temp-gds-list.grp-name  = gds-obj.grp-name
                          temp-gds-list.gds-name  = goods.grp-name
                          temp-gds-list.gds-code  = gds-obj.gds-code
                          temp-gds-list.artic     = gds-obj.artic
                        .
                    end.
            end.
    end.
  for each temp-gds-list no-lock
    , first goods  where goods.gds-code  = temp-gds-list.gds-code no-lock
      break
        by (substring(clients.obj-name,1,10) + string(gds-obj.prod-code))
    by goods.artic :
    run item-goods ( "2" , "goods" ) .
      if return-value <> "" then next.
        If Last-of((substring(clients.obj-name,1,10) + string(gds-obj.prod-code))) Then Do:
        If String(Entry(2,"(substring(clients.obj-name,1,10) + string(gds-obj.prod-code))",".")) = "Grp-name"
          Then  Assign
                  S-bar-code   = " Итого по "
                  Gds-zap-artic = Substring(
                                      B1-name
                                      ,1,16)
                  Gds-zap-gds-name = Substring(
                                      B1-name
                                      ,17,40)
                                .
          Else  Assign
                  S-bar-code   = ""
                  Gds-zap-artic = "        Итого по "
                  Gds-zap-gds-name =  B1-name
                                .
            Run Display-b1 In This-procedure .
            Run Clear-b1 In This-procedure .
            Assign Break_Group = True.
        End.
  end.
end.
  end.
    when 3 then do:
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if x-selectobject = "currency":u  or  xtog-obj then do:
  for  each gds-obj
      where  gds-obj.obj-code   = x-store-code
        and  gds-obj.obj-type   = x-store-type
              and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
              no-lock ,
  first g#cli
        where gds-obj.prod-code  = g#cli.obj-code
        and  gds-obj.prod-type   = g#cli.obj-type
        no-lock,
  first goods
        where gds-obj.gds-code = goods.gds-code no-lock
        break
        by ((substring(clients.obj-name,1,10) + string(gds-obj.prod-code)))
        by goods.artic :
        run item-goods ( "2" , "goods" ) .
        if return-value <> "" then next.
        If Last-of((substring(clients.obj-name,1,10) + string(gds-obj.prod-code))) Then Do:
        If String(Entry(2,"(substring(clients.obj-name,1,10) + string(gds-obj.prod-code))",".")) = "Grp-name"
          Then  Assign
                  S-bar-code   = " Итого по "
                  Gds-zap-artic = Substring(
                                      B1-name
                                      ,1,16)
                  Gds-zap-gds-name = Substring(
                                      B1-name
                                      ,17,40)
                                .
          Else  Assign
                  S-bar-code   = ""
                  Gds-zap-artic = "        Итого по "
                  Gds-zap-gds-name =  B1-name
                                .
            Run Display-b1 In This-procedure .
            Run Clear-b1 In This-procedure .
            Assign Break_Group = True.
        End.
      end.
  end.
  else do:
    for each obj-list no-lock :
          for  each gds-obj
            where  gds-obj.obj-code   = obj-list.obj-code
              and  gds-obj.obj-type   = obj-list.obj-type
                    and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
                    no-lock ,
          first g#cli
              where gds-obj.prod-code  = g#cli.obj-code
              and  gds-obj.prod-type   = g#cli.obj-type
              no-lock,
          first goods
              where gds-obj.gds-code = goods.gds-code no-lock :
                if not can-find (first temp-gds-list where temp-gds-list.gds-code = gds-obj.gds-code) then do:
                    create temp-gds-list.
                    assign
                      temp-gds-list.prod-code = gds-obj.prod-code
                      temp-gds-list.grp-name  = gds-obj.grp-name
                      temp-gds-list.gds-name  = goods.gds-name
                      temp-gds-list.gds-code  = gds-obj.gds-code
                      temp-gds-list.artic     = gds-obj.artic
                    .
                end.
          end.
    end.
      for each temp-gds-list no-lock
        , first goods  where goods.gds-code  = temp-gds-list.gds-code no-lock
          break
            by ((substring(clients.obj-name,1,10) + string(gds-obj.prod-code)))
            by goods.artic :
        run item-goods ( "2" , "goods" ) .
          if return-value <> "" then next.
        If Last-of((substring(clients.obj-name,1,10) + string(gds-obj.prod-code))) Then Do:
        If String(Entry(2,"(substring(clients.obj-name,1,10) + string(gds-obj.prod-code))",".")) = "Grp-name"
          Then  Assign
                  S-bar-code   = " Итого по "
                  Gds-zap-artic = Substring(
                                      B1-name
                                      ,1,16)
                  Gds-zap-gds-name = Substring(
                                      B1-name
                                      ,17,40)
                                .
          Else  Assign
                  S-bar-code   = ""
                  Gds-zap-artic = "        Итого по "
                  Gds-zap-gds-name =  B1-name
                                .
            Run Display-b1 In This-procedure .
            Run Clear-b1 In This-procedure .
            Assign Break_Group = True.
        End.
      end.
end.
  end.
    otherwise do:
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
IF x-SelectObject = "currency":U  OR  xTog-obj THEN DO :
    for each gds-obj  where
          gds-obj.obj-type = x-store-type  and
          gds-obj.obj-code = x-store-code
          and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
      no-lock,
First clients  where  clients.obj-code = gds-obj.prod-code and
                      clients.obj-type = gds-obj.prod-type
                no-lock,
          First goods  where  gds-obj.gds-code   = goods.gds-code
      no-lock,
First gds-list  where gds-obj.gds-code  = gds-list.gds-code
no-lock
BREAK
      BY ((substring(clients.obj-name,1,10) + string(gds-list.prod-code)))
    BY (gds-list.artic) :
      run item-goods ( "2" , "gds-list" ) .
      if return-value <> "" then NEXT.
        If Last-of((substring(clients.obj-name,1,10) + string(gds-list.prod-code))) Then Do:
        If String(Entry(2,"(substring(clients.obj-name,1,10) + string(gds-list.prod-code))",".")) = "Grp-name"
          Then  Assign
                  S-bar-code   = " Итого по "
                  Gds-zap-artic = Substring(
                                      B1-name
                                      ,1,16)
                  Gds-zap-gds-name = Substring(
                                      B1-name
                                      ,17,40)
                                .
          Else  Assign
                  S-bar-code   = ""
                  Gds-zap-artic = "        Итого по "
                  Gds-zap-gds-name =  B1-name
                                .
            Run Display-b1 In This-procedure .
            Run Clear-b1 In This-procedure .
            Assign Break_Group = True.
        End.
    End.
  END.
  Else DO:
   For each obj-list no-lock :
                  FOR EACH gds-obj where
                gds-obj.obj-type = obj-list.obj-type    and
                gds-obj.obj-code = obj-list.obj-code
                and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
                no-lock,
          First gds-list  where gds-obj.gds-code  = gds-list.gds-code
                no-lock :
                if NOT can-find(First temp-gds-list where temp-gds-list.gds-code = gds-obj.gds-code) Then do:
                    find first goods no-lock  where goods.gds-code  = gds-obj.gds-code .
                    Create temp-gds-list.
                    Assign
                      temp-gds-list.prod-code = gds-obj.prod-code
                      temp-gds-list.grp-name  = gds-obj.grp-name
                      temp-gds-list.gds-name  = goods.gds-name
                      temp-gds-list.gds-code  = gds-obj.gds-code
                      temp-gds-list.artic     = gds-obj.artic
                    .
                End.
            End.
  End.
  for each temp-gds-list no-lock
    , First gds-list  where gds-list.gds-code  = temp-gds-list.gds-code no-lock
                                     , First clients   where  clients.obj-code = gds-list.prod-code and
                                                              clients.obj-type = gds-list.prod-type
      BREAK
BY ((substring(clients.obj-name,1,10) + string(gds-list.prod-code)))
    BY gds-list.artic :
    run item-goods ( "2" , "gds-list" ) .
      if return-value <> "" then NEXT.
        If Last-of((substring(clients.obj-name,1,10) + string(gds-list.prod-code))) Then Do:
        If String(Entry(2,"(substring(clients.obj-name,1,10) + string(gds-list.prod-code))",".")) = "Grp-name"
          Then  Assign
                  S-bar-code   = " Итого по "
                  Gds-zap-artic = Substring(
                                      B1-name
                                      ,1,16)
                  Gds-zap-gds-name = Substring(
                                      B1-name
                                      ,17,40)
                                .
          Else  Assign
                  S-bar-code   = ""
                  Gds-zap-artic = "        Итого по "
                  Gds-zap-gds-name =  B1-name
                                .
            Run Display-b1 In This-procedure .
            Run Clear-b1 In This-procedure .
            Assign Break_Group = True.
        End.
  End.
End.
    end.
  end case.
end procedure.
procedure run4 :
  run run4sort2 .
  end procedure .
procedure run4sort2 :
      case select-good :
         when 1  then do:
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
IF x-SelectObject = "currency":U  OR  xTog-obj THEN DO :
    for each gds-obj  where
          gds-obj.obj-type = x-store-type  and
          gds-obj.obj-code = x-store-code
          and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
      no-lock,
First clients  where  clients.obj-code = gds-obj.prod-code and
                      clients.obj-type = gds-obj.prod-type
                no-lock,
          First goods  where  gds-obj.gds-code   = goods.gds-code
no-lock
BREAK BY ((substring(clients.obj-name,1,10) + string(gds-obj.prod-code)))
      BY (gds-obj.grp-name)
    BY (goods.artic) :
      run item-goods ( "4" , "goods" ) .
      if return-value <> "" then NEXT.
        If Last-of(gds-obj.grp-name) Then Do:
        If String(Entry(2,"gds-obj.grp-name",".")) = "Grp-name"
          Then  Assign
                  S-bar-code   = " Итого по "
                  Gds-zap-artic = Substring(
                                       B2-name
                                      ,1,16)
                  Gds-zap-gds-name = Substring(
                                       B2-name
                                      ,17,40)
                                .
          Else  Assign
                  S-bar-code   = ""
                  Gds-zap-artic = "        Итого по "
                  Gds-zap-gds-name =   B2-name
                                .
            Run Display-b1 In This-procedure .
            Run Clear-b1 In This-procedure .
            Assign Break_Group = True.
        End.
        If Last-of((substring(clients.obj-name,1,10) + string(gds-obj.prod-code))) Then Do:
        If String(Entry(2,"(substring(clients.obj-name,1,10) + string(gds-obj.prod-code))",".")) = "Grp-name"
          Then  Assign
              S-bar-code   = "Итого по "
              Gds-zap-artic = Substring(
                                   B1-name
                                  ,1,16)
              Gds-zap-gds-name = Substring(
                                   B1-name
                                  ,17,40)
                            .
          Else Assign
              S-bar-code = ""
              Gds-zap-artic = If  ("4" = "4"  Or  "4" = "5") Then "Итого по "
                                                                 Else "  Итого по "
              Gds-zap-gds-name =   B1-name
              .
          Run Display-b2 In This-procedure .
          Run Clear-b2 In This-procedure .
          Run Clear-b1 In This-procedure .
          Assign  Break_Group1 = True.
        End.
    End.
  END.
  Else DO:
   For each obj-list no-lock :
                  FOR EACH gds-obj where
                gds-obj.obj-type = obj-list.obj-type    and
                gds-obj.obj-code = obj-list.obj-code
                and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
                no-lock :
                if NOT can-find(First temp-gds-list where temp-gds-list.gds-code = gds-obj.gds-code) Then do:
                    find first goods no-lock  where goods.gds-code  = gds-obj.gds-code .
                    Create temp-gds-list.
                    Assign
                      temp-gds-list.prod-code = gds-obj.prod-code
                      temp-gds-list.grp-name  = gds-obj.grp-name
                      temp-gds-list.gds-name  = goods.gds-name
                      temp-gds-list.gds-code  = gds-obj.gds-code
                      temp-gds-list.artic     = gds-obj.artic
                    .
                End.
            End.
  End.
  for each temp-gds-list no-lock
    , First goods     where goods.gds-code  = temp-gds-list.gds-code no-lock
                                     , First clients   where  clients.obj-code = goods.prod-code and
                                                              clients.obj-type = goods.prod-type
      BREAK
BY (substring(clients.obj-name,1,10) + string(gds-obj.prod-code))
BY (gds-obj.grp-name)
    BY goods.artic :
    run item-goods ( "4" , "goods" ) .
      if return-value <> "" then NEXT.
        If Last-of(gds-obj.grp-name) Then Do:
        If String(Entry(2,"gds-obj.grp-name",".")) = "Grp-name"
          Then  Assign
                  S-bar-code   = " Итого по "
                  Gds-zap-artic = Substring(
                                       B2-name
                                      ,1,16)
                  Gds-zap-gds-name = Substring(
                                       B2-name
                                      ,17,40)
                                .
          Else  Assign
                  S-bar-code   = ""
                  Gds-zap-artic = "        Итого по "
                  Gds-zap-gds-name =   B2-name
                                .
            Run Display-b1 In This-procedure .
            Run Clear-b1 In This-procedure .
            Assign Break_Group = True.
        End.
        If Last-of((substring(clients.obj-name,1,10) + string(gds-obj.prod-code))) Then Do:
        If String(Entry(2,"(substring(clients.obj-name,1,10) + string(gds-obj.prod-code))",".")) = "Grp-name"
          Then  Assign
              S-bar-code   = "Итого по "
              Gds-zap-artic = Substring(
                                   B1-name
                                  ,1,16)
              Gds-zap-gds-name = Substring(
                                   B1-name
                                  ,17,40)
                            .
          Else Assign
              S-bar-code = ""
              Gds-zap-artic = If  ("4" = "4"  Or  "4" = "5") Then "Итого по "
                                                                 Else "  Итого по "
              Gds-zap-gds-name =   B1-name
              .
          Run Display-b2 In This-procedure .
          Run Clear-b2 In This-procedure .
          Run Clear-b1 In This-procedure .
          Assign  Break_Group1 = True.
        End.
  End.
End.
  end.
         when 2  then do:
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  if x-selectobject = "currency":u  or  xtog-obj then do:
      for  each gds-obj
                  where gds-obj.obj-code   = x-store-code
                   and  gds-obj.obj-type   = x-store-type
                        and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
                        no-lock ,
              first  tmp#grp  where gds-obj.grp-name   begins tmp#grp.grp-name   no-lock ,
              first goods       where gds-obj.gds-code   = goods.gds-code  no-lock
                  break
                  by (substring(clients.obj-name,1,10) + string(gds-obj.prod-code))
                  by gds-obj.grp-name
                  by goods.artic :
                  run item-goods ( input "4" , input "goods" ) .
                  if return-value <> "" then next.
        If Last-of(gds-obj.grp-name) Then Do:
        If String(Entry(2,"gds-obj.grp-name",".")) = "Grp-name"
          Then  Assign
                  S-bar-code   = " Итого по "
                  Gds-zap-artic = Substring(
                                       B2-name
                                      ,1,16)
                  Gds-zap-gds-name = Substring(
                                       B2-name
                                      ,17,40)
                                .
          Else  Assign
                  S-bar-code   = ""
                  Gds-zap-artic = "        Итого по "
                  Gds-zap-gds-name =   B2-name
                                .
            Run Display-b1 In This-procedure .
            Run Clear-b1 In This-procedure .
            Assign Break_Group = True.
        End.
        If Last-of((substring(clients.obj-name,1,10) + string(gds-obj.prod-code))) Then Do:
        If String(Entry(2,"(substring(clients.obj-name,1,10) + string(gds-obj.prod-code))",".")) = "Grp-name"
          Then  Assign
              S-bar-code   = "Итого по "
              Gds-zap-artic = Substring(
                                   B1-name
                                  ,1,16)
              Gds-zap-gds-name = Substring(
                                   B1-name
                                  ,17,40)
                            .
          Else Assign
              S-bar-code = ""
              Gds-zap-artic = If  ("4" = "4"  Or  "4" = "5") Then "Итого по "
                                                                 Else "  Итого по "
              Gds-zap-gds-name =   B1-name
              .
          Run Display-b2 In This-procedure .
          Run Clear-b2 In This-procedure .
          Run Clear-b1 In This-procedure .
          Assign  Break_Group1 = True.
        End.
      end.
  end.
  else do:
      for each obj-list no-lock :
            for  each gds-obj
              where  gds-obj.obj-code   = obj-list.obj-code
                and  gds-obj.obj-type   = obj-list.obj-type
                     and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
              no-lock ,
              first  tmp#grp  where gds-obj.grp-name   begins tmp#grp.grp-name   no-lock ,
              first goods       where gds-obj.gds-code   = goods.gds-code  no-lock :
                    if not can-find(first temp-gds-list where temp-gds-list.gds-code = gds-obj.gds-code) then do:
                        create temp-gds-list.
                        assign
                          temp-gds-list.prod-code = gds-obj.prod-code
                          temp-gds-list.grp-name  = gds-obj.grp-name
                          temp-gds-list.gds-name  = goods.grp-name
                          temp-gds-list.gds-code  = gds-obj.gds-code
                          temp-gds-list.artic     = gds-obj.artic
                        .
                    end.
            end.
    end.
  for each temp-gds-list no-lock
    , first goods  where goods.gds-code  = temp-gds-list.gds-code no-lock
      break
        by (substring(clients.obj-name,1,10) + string(gds-obj.prod-code))
        by gds-obj.grp-name
    by goods.artic :
    run item-goods ( "4" , "goods" ) .
      if return-value <> "" then next.
        If Last-of(gds-obj.grp-name) Then Do:
        If String(Entry(2,"gds-obj.grp-name",".")) = "Grp-name"
          Then  Assign
                  S-bar-code   = " Итого по "
                  Gds-zap-artic = Substring(
                                       B2-name
                                      ,1,16)
                  Gds-zap-gds-name = Substring(
                                       B2-name
                                      ,17,40)
                                .
          Else  Assign
                  S-bar-code   = ""
                  Gds-zap-artic = "        Итого по "
                  Gds-zap-gds-name =   B2-name
                                .
            Run Display-b1 In This-procedure .
            Run Clear-b1 In This-procedure .
            Assign Break_Group = True.
        End.
        If Last-of((substring(clients.obj-name,1,10) + string(gds-obj.prod-code))) Then Do:
        If String(Entry(2,"(substring(clients.obj-name,1,10) + string(gds-obj.prod-code))",".")) = "Grp-name"
          Then  Assign
              S-bar-code   = "Итого по "
              Gds-zap-artic = Substring(
                                   B1-name
                                  ,1,16)
              Gds-zap-gds-name = Substring(
                                   B1-name
                                  ,17,40)
                            .
          Else Assign
              S-bar-code = ""
              Gds-zap-artic = If  ("4" = "4"  Or  "4" = "5") Then "Итого по "
                                                                 Else "  Итого по "
              Gds-zap-gds-name =   B1-name
              .
          Run Display-b2 In This-procedure .
          Run Clear-b2 In This-procedure .
          Run Clear-b1 In This-procedure .
          Assign  Break_Group1 = True.
        End.
  end.
end.
  end.
         when 3 then do:
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if x-selectobject = "currency":u  or  xtog-obj then do:
  for  each gds-obj
      where  gds-obj.obj-code   = x-store-code
        and  gds-obj.obj-type   = x-store-type
              and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
              no-lock ,
  first g#cli
        where gds-obj.prod-code  = g#cli.obj-code
        and  gds-obj.prod-type   = g#cli.obj-type
        no-lock,
  first goods
        where gds-obj.gds-code = goods.gds-code no-lock
        break
        by (substring(clients.obj-name,1,10) + string(gds-obj.prod-code))
        by (gds-obj.grp-name)
        by goods.artic :
        run item-goods ( "4" , "goods" ) .
        if return-value <> "" then next.
        If Last-of(gds-obj.grp-name) Then Do:
        If String(Entry(2,"gds-obj.grp-name",".")) = "Grp-name"
          Then  Assign
                  S-bar-code   = " Итого по "
                  Gds-zap-artic = Substring(
                                       B2-name
                                      ,1,16)
                  Gds-zap-gds-name = Substring(
                                       B2-name
                                      ,17,40)
                                .
          Else  Assign
                  S-bar-code   = ""
                  Gds-zap-artic = "        Итого по "
                  Gds-zap-gds-name =   B2-name
                                .
            Run Display-b1 In This-procedure .
            Run Clear-b1 In This-procedure .
            Assign Break_Group = True.
        End.
        If Last-of((substring(clients.obj-name,1,10) + string(gds-obj.prod-code))) Then Do:
        If String(Entry(2,"(substring(clients.obj-name,1,10) + string(gds-obj.prod-code))",".")) = "Grp-name"
          Then  Assign
              S-bar-code   = "Итого по "
              Gds-zap-artic = Substring(
                                   B1-name
                                  ,1,16)
              Gds-zap-gds-name = Substring(
                                   B1-name
                                  ,17,40)
                            .
          Else Assign
              S-bar-code = ""
              Gds-zap-artic = If  ("4" = "4"  Or  "4" = "5") Then "Итого по "
                                                                 Else "  Итого по "
              Gds-zap-gds-name =   B1-name
              .
          Run Display-b2 In This-procedure .
          Run Clear-b2 In This-procedure .
          Run Clear-b1 In This-procedure .
          Assign  Break_Group1 = True.
        End.
      end.
  end.
  else do:
    for each obj-list no-lock :
          for  each gds-obj
            where  gds-obj.obj-code   = obj-list.obj-code
              and  gds-obj.obj-type   = obj-list.obj-type
                    and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
                    no-lock ,
          first g#cli
              where gds-obj.prod-code  = g#cli.obj-code
              and  gds-obj.prod-type   = g#cli.obj-type
              no-lock,
          first goods
              where gds-obj.gds-code = goods.gds-code no-lock :
                if not can-find (first temp-gds-list where temp-gds-list.gds-code = gds-obj.gds-code) then do:
                    create temp-gds-list.
                    assign
                      temp-gds-list.prod-code = gds-obj.prod-code
                      temp-gds-list.grp-name  = gds-obj.grp-name
                      temp-gds-list.gds-name  = goods.gds-name
                      temp-gds-list.gds-code  = gds-obj.gds-code
                      temp-gds-list.artic     = gds-obj.artic
                    .
                end.
          end.
    end.
      for each temp-gds-list no-lock
        , first goods  where goods.gds-code  = temp-gds-list.gds-code no-lock
          break
            by (substring(clients.obj-name,1,10) + string(gds-obj.prod-code))
            by (gds-obj.grp-name)
            by goods.artic :
        run item-goods ( "4" , "goods" ) .
          if return-value <> "" then next.
        If Last-of(gds-obj.grp-name) Then Do:
        If String(Entry(2,"gds-obj.grp-name",".")) = "Grp-name"
          Then  Assign
                  S-bar-code   = " Итого по "
                  Gds-zap-artic = Substring(
                                       B2-name
                                      ,1,16)
                  Gds-zap-gds-name = Substring(
                                       B2-name
                                      ,17,40)
                                .
          Else  Assign
                  S-bar-code   = ""
                  Gds-zap-artic = "        Итого по "
                  Gds-zap-gds-name =   B2-name
                                .
            Run Display-b1 In This-procedure .
            Run Clear-b1 In This-procedure .
            Assign Break_Group = True.
        End.
        If Last-of((substring(clients.obj-name,1,10) + string(gds-obj.prod-code))) Then Do:
        If String(Entry(2,"(substring(clients.obj-name,1,10) + string(gds-obj.prod-code))",".")) = "Grp-name"
          Then  Assign
              S-bar-code   = "Итого по "
              Gds-zap-artic = Substring(
                                   B1-name
                                  ,1,16)
              Gds-zap-gds-name = Substring(
                                   B1-name
                                  ,17,40)
                            .
          Else Assign
              S-bar-code = ""
              Gds-zap-artic = If  ("4" = "4"  Or  "4" = "5") Then "Итого по "
                                                                 Else "  Итого по "
              Gds-zap-gds-name =   B1-name
              .
          Run Display-b2 In This-procedure .
          Run Clear-b2 In This-procedure .
          Run Clear-b1 In This-procedure .
          Assign  Break_Group1 = True.
        End.
      end.
end.
  end.
         otherwise do:
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
IF x-SelectObject = "currency":U  OR  xTog-obj THEN DO :
    for each gds-obj  where
          gds-obj.obj-type = x-store-type  and
          gds-obj.obj-code = x-store-code
          and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
      no-lock,
First clients  where  clients.obj-code = gds-obj.prod-code and
                      clients.obj-type = gds-obj.prod-type
                no-lock,
          First goods  where  gds-obj.gds-code   = goods.gds-code
      no-lock,
First gds-list  where gds-obj.gds-code  = gds-list.gds-code
no-lock
BREAK BY ((substring(clients.obj-name,1,10) + string(gds-list.prod-code)))
      BY (gds-list.grp-name)
    BY (gds-list.artic) :
      run item-goods ( "4" , "gds-list" ) .
      if return-value <> "" then NEXT.
        If Last-of(gds-list.grp-name) Then Do:
        If String(Entry(2,"gds-list.grp-name",".")) = "Grp-name"
          Then  Assign
                  S-bar-code   = " Итого по "
                  Gds-zap-artic = Substring(
                                       B2-name
                                      ,1,16)
                  Gds-zap-gds-name = Substring(
                                       B2-name
                                      ,17,40)
                                .
          Else  Assign
                  S-bar-code   = ""
                  Gds-zap-artic = "        Итого по "
                  Gds-zap-gds-name =   B2-name
                                .
            Run Display-b1 In This-procedure .
            Run Clear-b1 In This-procedure .
            Assign Break_Group = True.
        End.
        If Last-of((substring(clients.obj-name,1,10) + string(gds-list.prod-code))) Then Do:
        If String(Entry(2,"(substring(clients.obj-name,1,10) + string(gds-list.prod-code))",".")) = "Grp-name"
          Then  Assign
              S-bar-code   = "Итого по "
              Gds-zap-artic = Substring(
                                   B1-name
                                  ,1,16)
              Gds-zap-gds-name = Substring(
                                   B1-name
                                  ,17,40)
                            .
          Else Assign
              S-bar-code = ""
              Gds-zap-artic = If  ("4" = "4"  Or  "4" = "5") Then "Итого по "
                                                                 Else "  Итого по "
              Gds-zap-gds-name =   B1-name
              .
          Run Display-b2 In This-procedure .
          Run Clear-b2 In This-procedure .
          Run Clear-b1 In This-procedure .
          Assign  Break_Group1 = True.
        End.
    End.
  END.
  Else DO:
   For each obj-list no-lock :
                  FOR EACH gds-obj where
                gds-obj.obj-type = obj-list.obj-type    and
                gds-obj.obj-code = obj-list.obj-code
                and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
                no-lock,
          First gds-list  where gds-obj.gds-code  = gds-list.gds-code
                no-lock :
                if NOT can-find(First temp-gds-list where temp-gds-list.gds-code = gds-obj.gds-code) Then do:
                    find first goods no-lock  where goods.gds-code  = gds-obj.gds-code .
                    Create temp-gds-list.
                    Assign
                      temp-gds-list.prod-code = gds-obj.prod-code
                      temp-gds-list.grp-name  = gds-obj.grp-name
                      temp-gds-list.gds-name  = goods.gds-name
                      temp-gds-list.gds-code  = gds-obj.gds-code
                      temp-gds-list.artic     = gds-obj.artic
                    .
                End.
            End.
  End.
  for each temp-gds-list no-lock
    , First gds-list  where gds-list.gds-code  = temp-gds-list.gds-code no-lock
                                     , First clients   where  clients.obj-code = gds-list.prod-code and
                                                              clients.obj-type = gds-list.prod-type
      BREAK
BY (substring(clients.obj-name,1,10) + string(gds-list.prod-code))
BY (gds-list.grp-name)
    BY gds-list.artic :
    run item-goods ( "4" , "gds-list" ) .
      if return-value <> "" then NEXT.
        If Last-of(gds-list.grp-name) Then Do:
        If String(Entry(2,"gds-list.grp-name",".")) = "Grp-name"
          Then  Assign
                  S-bar-code   = " Итого по "
                  Gds-zap-artic = Substring(
                                       B2-name
                                      ,1,16)
                  Gds-zap-gds-name = Substring(
                                       B2-name
                                      ,17,40)
                                .
          Else  Assign
                  S-bar-code   = ""
                  Gds-zap-artic = "        Итого по "
                  Gds-zap-gds-name =   B2-name
                                .
            Run Display-b1 In This-procedure .
            Run Clear-b1 In This-procedure .
            Assign Break_Group = True.
        End.
        If Last-of((substring(clients.obj-name,1,10) + string(gds-list.prod-code))) Then Do:
        If String(Entry(2,"(substring(clients.obj-name,1,10) + string(gds-list.prod-code))",".")) = "Grp-name"
          Then  Assign
              S-bar-code   = "Итого по "
              Gds-zap-artic = Substring(
                                   B1-name
                                  ,1,16)
              Gds-zap-gds-name = Substring(
                                   B1-name
                                  ,17,40)
                            .
          Else Assign
              S-bar-code = ""
              Gds-zap-artic = If  ("4" = "4"  Or  "4" = "5") Then "Итого по "
                                                                 Else "  Итого по "
              Gds-zap-gds-name =   B1-name
              .
          Run Display-b2 In This-procedure .
          Run Clear-b2 In This-procedure .
          Run Clear-b1 In This-procedure .
          Assign  Break_Group1 = True.
        End.
  End.
End.
         end.
      end case.
end procedure.
procedure run5 :
  run run5sort2.
end procedure.
procedure run5sort2 :
       case select-good:
         when 1  then do:
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
IF x-SelectObject = "currency":U  OR  xTog-obj THEN DO :
    for each gds-obj  where
          gds-obj.obj-type = x-store-type  and
          gds-obj.obj-code = x-store-code
          and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
      no-lock,
First clients  where  clients.obj-code = gds-obj.prod-code and
                      clients.obj-type = gds-obj.prod-type
                no-lock,
          First goods  where  gds-obj.gds-code   = goods.gds-code
no-lock
BREAK BY (gds-obj.grp-name)
      BY ((substring(clients.obj-name,1,10) + string(gds-obj.prod-code)))
    BY (goods.artic) :
      run item-goods ( "5" , "goods" ) .
      if return-value <> "" then NEXT.
        If Last-of((substring(clients.obj-name,1,10) + string(gds-obj.prod-code))) Then Do:
        If String(Entry(2,"(substring(clients.obj-name,1,10) + string(gds-obj.prod-code))",".")) = "Grp-name"
          Then  Assign
                  S-bar-code   = " Итого по "
                  Gds-zap-artic = Substring(
                                       B2-name
                                      ,1,16)
                  Gds-zap-gds-name = Substring(
                                       B2-name
                                      ,17,40)
                                .
          Else  Assign
                  S-bar-code   = ""
                  Gds-zap-artic = "        Итого по "
                  Gds-zap-gds-name =   B2-name
                                .
            Run Display-b1 In This-procedure .
            Run Clear-b1 In This-procedure .
            Assign Break_Group = True.
        End.
        If Last-of(gds-obj.grp-name) Then Do:
        If String(Entry(2,"gds-obj.grp-name",".")) = "Grp-name"
          Then  Assign
              S-bar-code   = "Итого по "
              Gds-zap-artic = Substring(
                                   B1-name
                                  ,1,16)
              Gds-zap-gds-name = Substring(
                                   B1-name
                                  ,17,40)
                            .
          Else Assign
              S-bar-code = ""
              Gds-zap-artic = If  ("5" = "4"  Or  "5" = "5") Then "Итого по "
                                                                 Else "  Итого по "
              Gds-zap-gds-name =   B1-name
              .
          Run Display-b2 In This-procedure .
          Run Clear-b2 In This-procedure .
          Run Clear-b1 In This-procedure .
          Assign  Break_Group1 = True.
        End.
    End.
  END.
  Else DO:
   For each obj-list no-lock :
                  FOR EACH gds-obj where
                gds-obj.obj-type = obj-list.obj-type    and
                gds-obj.obj-code = obj-list.obj-code
                and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
                no-lock :
                if NOT can-find(First temp-gds-list where temp-gds-list.gds-code = gds-obj.gds-code) Then do:
                    find first goods no-lock  where goods.gds-code  = gds-obj.gds-code .
                    Create temp-gds-list.
                    Assign
                      temp-gds-list.prod-code = gds-obj.prod-code
                      temp-gds-list.grp-name  = gds-obj.grp-name
                      temp-gds-list.gds-name  = goods.gds-name
                      temp-gds-list.gds-code  = gds-obj.gds-code
                      temp-gds-list.artic     = gds-obj.artic
                    .
                End.
            End.
  End.
  for each temp-gds-list no-lock
    , First goods     where goods.gds-code  = temp-gds-list.gds-code no-lock
                                     , First clients   where  clients.obj-code = goods.prod-code and
                                                              clients.obj-type = goods.prod-type
      BREAK
BY gds-obj.grp-name
BY ((substring(clients.obj-name,1,10) + string(gds-obj.prod-code)))
    BY goods.artic :
    run item-goods ( "5" , "goods" ) .
      if return-value <> "" then NEXT.
        If Last-of((substring(clients.obj-name,1,10) + string(gds-obj.prod-code))) Then Do:
        If String(Entry(2,"(substring(clients.obj-name,1,10) + string(gds-obj.prod-code))",".")) = "Grp-name"
          Then  Assign
                  S-bar-code   = " Итого по "
                  Gds-zap-artic = Substring(
                                       B2-name
                                      ,1,16)
                  Gds-zap-gds-name = Substring(
                                       B2-name
                                      ,17,40)
                                .
          Else  Assign
                  S-bar-code   = ""
                  Gds-zap-artic = "        Итого по "
                  Gds-zap-gds-name =   B2-name
                                .
            Run Display-b1 In This-procedure .
            Run Clear-b1 In This-procedure .
            Assign Break_Group = True.
        End.
        If Last-of(gds-obj.grp-name) Then Do:
        If String(Entry(2,"gds-obj.grp-name",".")) = "Grp-name"
          Then  Assign
              S-bar-code   = "Итого по "
              Gds-zap-artic = Substring(
                                   B1-name
                                  ,1,16)
              Gds-zap-gds-name = Substring(
                                   B1-name
                                  ,17,40)
                            .
          Else Assign
              S-bar-code = ""
              Gds-zap-artic = If  ("5" = "4"  Or  "5" = "5") Then "Итого по "
                                                                 Else "  Итого по "
              Gds-zap-gds-name =   B1-name
              .
          Run Display-b2 In This-procedure .
          Run Clear-b2 In This-procedure .
          Run Clear-b1 In This-procedure .
          Assign  Break_Group1 = True.
        End.
  End.
End.
  end.
         when 2  then do:
define variable vss-include-info39 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  if x-selectobject = "currency":u  or  xtog-obj then do:
      for  each gds-obj
                  where gds-obj.obj-code   = x-store-code
                   and  gds-obj.obj-type   = x-store-type
                        and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
                        no-lock ,
              first  tmp#grp  where gds-obj.grp-name   begins tmp#grp.grp-name   no-lock ,
              first goods       where gds-obj.gds-code   = goods.gds-code  no-lock
                  break
                  by gds-obj.grp-name
                  by (substring(clients.obj-name,1,10) + string(gds-obj.prod-code))
                  by goods.artic :
                  run item-goods ( input "5" , input "goods" ) .
                  if return-value <> "" then next.
        If Last-of((substring(clients.obj-name,1,10) + string(gds-obj.prod-code))) Then Do:
        If String(Entry(2,"(substring(clients.obj-name,1,10) + string(gds-obj.prod-code))",".")) = "Grp-name"
          Then  Assign
                  S-bar-code   = " Итого по "
                  Gds-zap-artic = Substring(
                                       B2-name
                                      ,1,16)
                  Gds-zap-gds-name = Substring(
                                       B2-name
                                      ,17,40)
                                .
          Else  Assign
                  S-bar-code   = ""
                  Gds-zap-artic = "        Итого по "
                  Gds-zap-gds-name =   B2-name
                                .
            Run Display-b1 In This-procedure .
            Run Clear-b1 In This-procedure .
            Assign Break_Group = True.
        End.
        If Last-of(gds-obj.grp-name) Then Do:
        If String(Entry(2,"gds-obj.grp-name",".")) = "Grp-name"
          Then  Assign
              S-bar-code   = "Итого по "
              Gds-zap-artic = Substring(
                                   B1-name
                                  ,1,16)
              Gds-zap-gds-name = Substring(
                                   B1-name
                                  ,17,40)
                            .
          Else Assign
              S-bar-code = ""
              Gds-zap-artic = If  ("5" = "4"  Or  "5" = "5") Then "Итого по "
                                                                 Else "  Итого по "
              Gds-zap-gds-name =   B1-name
              .
          Run Display-b2 In This-procedure .
          Run Clear-b2 In This-procedure .
          Run Clear-b1 In This-procedure .
          Assign  Break_Group1 = True.
        End.
      end.
  end.
  else do:
      for each obj-list no-lock :
            for  each gds-obj
              where  gds-obj.obj-code   = obj-list.obj-code
                and  gds-obj.obj-type   = obj-list.obj-type
                     and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
              no-lock ,
              first  tmp#grp  where gds-obj.grp-name   begins tmp#grp.grp-name   no-lock ,
              first goods       where gds-obj.gds-code   = goods.gds-code  no-lock :
                    if not can-find(first temp-gds-list where temp-gds-list.gds-code = gds-obj.gds-code) then do:
                        create temp-gds-list.
                        assign
                          temp-gds-list.prod-code = gds-obj.prod-code
                          temp-gds-list.grp-name  = gds-obj.grp-name
                          temp-gds-list.gds-name  = goods.grp-name
                          temp-gds-list.gds-code  = gds-obj.gds-code
                          temp-gds-list.artic     = gds-obj.artic
                        .
                    end.
            end.
    end.
  for each temp-gds-list no-lock
    , first goods  where goods.gds-code  = temp-gds-list.gds-code no-lock
      break
        by gds-obj.grp-name
        by (substring(clients.obj-name,1,10) + string(gds-obj.prod-code))
    by goods.artic :
    run item-goods ( "5" , "goods" ) .
      if return-value <> "" then next.
        If Last-of((substring(clients.obj-name,1,10) + string(gds-obj.prod-code))) Then Do:
        If String(Entry(2,"(substring(clients.obj-name,1,10) + string(gds-obj.prod-code))",".")) = "Grp-name"
          Then  Assign
                  S-bar-code   = " Итого по "
                  Gds-zap-artic = Substring(
                                       B2-name
                                      ,1,16)
                  Gds-zap-gds-name = Substring(
                                       B2-name
                                      ,17,40)
                                .
          Else  Assign
                  S-bar-code   = ""
                  Gds-zap-artic = "        Итого по "
                  Gds-zap-gds-name =   B2-name
                                .
            Run Display-b1 In This-procedure .
            Run Clear-b1 In This-procedure .
            Assign Break_Group = True.
        End.
        If Last-of(gds-obj.grp-name) Then Do:
        If String(Entry(2,"gds-obj.grp-name",".")) = "Grp-name"
          Then  Assign
              S-bar-code   = "Итого по "
              Gds-zap-artic = Substring(
                                   B1-name
                                  ,1,16)
              Gds-zap-gds-name = Substring(
                                   B1-name
                                  ,17,40)
                            .
          Else Assign
              S-bar-code = ""
              Gds-zap-artic = If  ("5" = "4"  Or  "5" = "5") Then "Итого по "
                                                                 Else "  Итого по "
              Gds-zap-gds-name =   B1-name
              .
          Run Display-b2 In This-procedure .
          Run Clear-b2 In This-procedure .
          Run Clear-b1 In This-procedure .
          Assign  Break_Group1 = True.
        End.
  end.
end.
  end.
         when 3 then do:
define variable vss-include-info40 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if x-selectobject = "currency":u  or  xtog-obj then do:
  for  each gds-obj
      where  gds-obj.obj-code   = x-store-code
        and  gds-obj.obj-type   = x-store-type
              and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
              no-lock ,
  first g#cli
        where gds-obj.prod-code  = g#cli.obj-code
        and  gds-obj.prod-type   = g#cli.obj-type
        no-lock,
  first goods
        where gds-obj.gds-code = goods.gds-code no-lock
        break
        by gds-obj.grp-name
        by ((substring(clients.obj-name,1,10) + string(gds-obj.prod-code)))
        by goods.artic :
        run item-goods ( "5" , "goods" ) .
        if return-value <> "" then next.
        If Last-of((substring(clients.obj-name,1,10) + string(gds-obj.prod-code))) Then Do:
        If String(Entry(2,"(substring(clients.obj-name,1,10) + string(gds-obj.prod-code))",".")) = "Grp-name"
          Then  Assign
                  S-bar-code   = " Итого по "
                  Gds-zap-artic = Substring(
                                       B2-name
                                      ,1,16)
                  Gds-zap-gds-name = Substring(
                                       B2-name
                                      ,17,40)
                                .
          Else  Assign
                  S-bar-code   = ""
                  Gds-zap-artic = "        Итого по "
                  Gds-zap-gds-name =   B2-name
                                .
            Run Display-b1 In This-procedure .
            Run Clear-b1 In This-procedure .
            Assign Break_Group = True.
        End.
        If Last-of(gds-obj.grp-name) Then Do:
        If String(Entry(2,"gds-obj.grp-name",".")) = "Grp-name"
          Then  Assign
              S-bar-code   = "Итого по "
              Gds-zap-artic = Substring(
                                   B1-name
                                  ,1,16)
              Gds-zap-gds-name = Substring(
                                   B1-name
                                  ,17,40)
                            .
          Else Assign
              S-bar-code = ""
              Gds-zap-artic = If  ("5" = "4"  Or  "5" = "5") Then "Итого по "
                                                                 Else "  Итого по "
              Gds-zap-gds-name =   B1-name
              .
          Run Display-b2 In This-procedure .
          Run Clear-b2 In This-procedure .
          Run Clear-b1 In This-procedure .
          Assign  Break_Group1 = True.
        End.
      end.
  end.
  else do:
    for each obj-list no-lock :
          for  each gds-obj
            where  gds-obj.obj-code   = obj-list.obj-code
              and  gds-obj.obj-type   = obj-list.obj-type
                    and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
                    no-lock ,
          first g#cli
              where gds-obj.prod-code  = g#cli.obj-code
              and  gds-obj.prod-type   = g#cli.obj-type
              no-lock,
          first goods
              where gds-obj.gds-code = goods.gds-code no-lock :
                if not can-find (first temp-gds-list where temp-gds-list.gds-code = gds-obj.gds-code) then do:
                    create temp-gds-list.
                    assign
                      temp-gds-list.prod-code = gds-obj.prod-code
                      temp-gds-list.grp-name  = gds-obj.grp-name
                      temp-gds-list.gds-name  = goods.gds-name
                      temp-gds-list.gds-code  = gds-obj.gds-code
                      temp-gds-list.artic     = gds-obj.artic
                    .
                end.
          end.
    end.
      for each temp-gds-list no-lock
        , first goods  where goods.gds-code  = temp-gds-list.gds-code no-lock
          break
            by gds-obj.grp-name
            by ((substring(clients.obj-name,1,10) + string(gds-obj.prod-code)))
            by goods.artic :
        run item-goods ( "5" , "goods" ) .
          if return-value <> "" then next.
        If Last-of((substring(clients.obj-name,1,10) + string(gds-obj.prod-code))) Then Do:
        If String(Entry(2,"(substring(clients.obj-name,1,10) + string(gds-obj.prod-code))",".")) = "Grp-name"
          Then  Assign
                  S-bar-code   = " Итого по "
                  Gds-zap-artic = Substring(
                                       B2-name
                                      ,1,16)
                  Gds-zap-gds-name = Substring(
                                       B2-name
                                      ,17,40)
                                .
          Else  Assign
                  S-bar-code   = ""
                  Gds-zap-artic = "        Итого по "
                  Gds-zap-gds-name =   B2-name
                                .
            Run Display-b1 In This-procedure .
            Run Clear-b1 In This-procedure .
            Assign Break_Group = True.
        End.
        If Last-of(gds-obj.grp-name) Then Do:
        If String(Entry(2,"gds-obj.grp-name",".")) = "Grp-name"
          Then  Assign
              S-bar-code   = "Итого по "
              Gds-zap-artic = Substring(
                                   B1-name
                                  ,1,16)
              Gds-zap-gds-name = Substring(
                                   B1-name
                                  ,17,40)
                            .
          Else Assign
              S-bar-code = ""
              Gds-zap-artic = If  ("5" = "4"  Or  "5" = "5") Then "Итого по "
                                                                 Else "  Итого по "
              Gds-zap-gds-name =   B1-name
              .
          Run Display-b2 In This-procedure .
          Run Clear-b2 In This-procedure .
          Run Clear-b1 In This-procedure .
          Assign  Break_Group1 = True.
        End.
      end.
end.
  end.
         otherwise do:
define variable vss-include-info41 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
IF x-SelectObject = "currency":U  OR  xTog-obj THEN DO :
    for each gds-obj  where
          gds-obj.obj-type = x-store-type  and
          gds-obj.obj-code = x-store-code
          and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
      no-lock,
First clients  where  clients.obj-code = gds-obj.prod-code and
                      clients.obj-type = gds-obj.prod-type
                no-lock,
          First goods  where  gds-obj.gds-code   = goods.gds-code
      no-lock,
First gds-list  where gds-obj.gds-code  = gds-list.gds-code
no-lock
BREAK BY (gds-list.grp-name)
      BY ((substring(clients.obj-name,1,10) + string(gds-list.prod-code)))
    BY (gds-list.artic) :
      run item-goods ( "5" , "gds-list" ) .
      if return-value <> "" then NEXT.
        If Last-of((substring(clients.obj-name,1,10) + string(gds-list.prod-code))) Then Do:
        If String(Entry(2,"(substring(clients.obj-name,1,10) + string(gds-list.prod-code))",".")) = "Grp-name"
          Then  Assign
                  S-bar-code   = " Итого по "
                  Gds-zap-artic = Substring(
                                       B2-name
                                      ,1,16)
                  Gds-zap-gds-name = Substring(
                                       B2-name
                                      ,17,40)
                                .
          Else  Assign
                  S-bar-code   = ""
                  Gds-zap-artic = "        Итого по "
                  Gds-zap-gds-name =   B2-name
                                .
            Run Display-b1 In This-procedure .
            Run Clear-b1 In This-procedure .
            Assign Break_Group = True.
        End.
        If Last-of(gds-list.grp-name) Then Do:
        If String(Entry(2,"gds-list.grp-name",".")) = "Grp-name"
          Then  Assign
              S-bar-code   = "Итого по "
              Gds-zap-artic = Substring(
                                   B1-name
                                  ,1,16)
              Gds-zap-gds-name = Substring(
                                   B1-name
                                  ,17,40)
                            .
          Else Assign
              S-bar-code = ""
              Gds-zap-artic = If  ("5" = "4"  Or  "5" = "5") Then "Итого по "
                                                                 Else "  Итого по "
              Gds-zap-gds-name =   B1-name
              .
          Run Display-b2 In This-procedure .
          Run Clear-b2 In This-procedure .
          Run Clear-b1 In This-procedure .
          Assign  Break_Group1 = True.
        End.
    End.
  END.
  Else DO:
   For each obj-list no-lock :
                  FOR EACH gds-obj where
                gds-obj.obj-type = obj-list.obj-type    and
                gds-obj.obj-code = obj-list.obj-code
                and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
                no-lock,
          First gds-list  where gds-obj.gds-code  = gds-list.gds-code
                no-lock :
                if NOT can-find(First temp-gds-list where temp-gds-list.gds-code = gds-obj.gds-code) Then do:
                    find first goods no-lock  where goods.gds-code  = gds-obj.gds-code .
                    Create temp-gds-list.
                    Assign
                      temp-gds-list.prod-code = gds-obj.prod-code
                      temp-gds-list.grp-name  = gds-obj.grp-name
                      temp-gds-list.gds-name  = goods.gds-name
                      temp-gds-list.gds-code  = gds-obj.gds-code
                      temp-gds-list.artic     = gds-obj.artic
                    .
                End.
            End.
  End.
  for each temp-gds-list no-lock
    , First gds-list  where gds-list.gds-code  = temp-gds-list.gds-code no-lock
                                     , First clients   where  clients.obj-code = gds-list.prod-code and
                                                              clients.obj-type = gds-list.prod-type
      BREAK
BY gds-list.grp-name
BY ((substring(clients.obj-name,1,10) + string(gds-list.prod-code)))
    BY gds-list.artic :
    run item-goods ( "5" , "gds-list" ) .
      if return-value <> "" then NEXT.
        If Last-of((substring(clients.obj-name,1,10) + string(gds-list.prod-code))) Then Do:
        If String(Entry(2,"(substring(clients.obj-name,1,10) + string(gds-list.prod-code))",".")) = "Grp-name"
          Then  Assign
                  S-bar-code   = " Итого по "
                  Gds-zap-artic = Substring(
                                       B2-name
                                      ,1,16)
                  Gds-zap-gds-name = Substring(
                                       B2-name
                                      ,17,40)
                                .
          Else  Assign
                  S-bar-code   = ""
                  Gds-zap-artic = "        Итого по "
                  Gds-zap-gds-name =   B2-name
                                .
            Run Display-b1 In This-procedure .
            Run Clear-b1 In This-procedure .
            Assign Break_Group = True.
        End.
        If Last-of(gds-list.grp-name) Then Do:
        If String(Entry(2,"gds-list.grp-name",".")) = "Grp-name"
          Then  Assign
              S-bar-code   = "Итого по "
              Gds-zap-artic = Substring(
                                   B1-name
                                  ,1,16)
              Gds-zap-gds-name = Substring(
                                   B1-name
                                  ,17,40)
                            .
          Else Assign
              S-bar-code = ""
              Gds-zap-artic = If  ("5" = "4"  Or  "5" = "5") Then "Итого по "
                                                                 Else "  Итого по "
              Gds-zap-gds-name =   B1-name
              .
          Run Display-b2 In This-procedure .
          Run Clear-b2 In This-procedure .
          Run Clear-b1 In This-procedure .
          Assign  Break_Group1 = True.
        End.
  End.
End.
         end.
      end case.
end procedure.
procedure run7 :
      case select-good:
        when 1   then do:
define variable vss-include-info42 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
IF x-SelectObject = "currency":U  OR  xTog-obj then do :
define variable first-l42 as logical   no-undo .
  first-l42 = true .
  for each gds-obj
    where gds-obj.obj-type = x-store-type
      and gds-obj.obj-code = x-store-code
          and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
          no-lock,
      first goods  where  goods.gds-code = gds-obj.gds-code
      no-lock
      break by func-vat (input gds-obj.gds-code , input x-store-type, input x-store-code)
            by (goods.artic)
            :
      var-vat-pc = func-vat ( input gds-obj.gds-code, input x-store-type, input x-store-code) .
      if last-vat <> var-vat-pc then do:
          if not first-l42 then do:
            Assign
                s-bar-code    = ""
                gds-zap-artic = "        Итого по "
                gds-zap-gds-name = b1-name
                .
              run display-b1.
              run clear-b1  .
          end.
          Assign
            first-l42 = false
            break_group = true
            break_group1 = true
            .
          end.
      first-l42 = false .
      run item-goods ( "6" , "goods" ) .
      last-vat = func-vat (input gds-obj.gds-code , input x-store-type, input x-store-code) .
   end.
    Assign
        s-bar-code   = ""
        gds-zap-artic = "        Итого по "
        gds-zap-gds-name = b1-name
        .
      run display-b1.
      run clear-b1.
end.
else do:
   For each obj-list no-lock :
                  FOR EACH gds-obj where
                      gds-obj.obj-type = obj-list.obj-type    and
                      gds-obj.obj-code = obj-list.obj-code
                      and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
                      no-lock :
                      find first temp-gds-list where temp-gds-list.gds-code = gds-obj.gds-code no-error .
                      if not available temp-gds-list then do:
                          find first goods no-lock  where goods.gds-code  = gds-obj.gds-code .
                          Create temp-gds-list.
define variable vss-include-info43 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  gds-obj.gds-code
  ,input  '1':U
  ,input  ?
  ,input  v-cntxt-host-code-obj
  ,input  gds-obj.obj-type
  ,input  gds-obj.obj-code
  ,output var-vat-pc
  ) no-error .
                          Assign
                            temp-gds-list.prod-code = gds-obj.prod-code
                            temp-gds-list.grp-name  = gds-obj.grp-name
                            temp-gds-list.gds-name  = goods.gds-name
                            temp-gds-list.gds-code  = gds-obj.gds-code
                            temp-gds-list.artic     = gds-obj.artic
                            temp-gds-list.vat-pc    = var-vat-pc
                          .
                      End.
                      else do:
                      if temp-gds-list.vat-pc = 0 or temp-gds-list.vat-pc = ? then do:
define variable vss-include-info44 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  gds-obj.gds-code
  ,input  '1':U
  ,input  ?
  ,input  v-cntxt-host-code-obj
  ,input  gds-obj.obj-type
  ,input  gds-obj.obj-code
  ,output var-vat-pc
  ) no-error .
                            Assign
                              temp-gds-list.vat-pc    = var-vat-pc
                            .
                      end.
                      end.
            End.
  End.
  for each temp-gds-list no-lock
    , First goods     where goods.gds-code  = temp-gds-list.gds-code no-lock
      BREAK BY (func-vat(gds-obj.gds-code,gds-obj.obj-type,gds-obj.obj-code))  BY goods.artic :
    run item-goods ( "6" , "goods" ) .
      if return-value <> "" then NEXT.
        If Last-of((func-vat(gds-obj.gds-code,gds-obj.obj-type,gds-obj.obj-code))) Then Do:
        If String(Entry(2,"(func-vat(gds-obj.gds-code,gds-obj.obj-type,gds-obj.obj-code))",".")) = "Grp-name"
          Then  Assign
                  S-bar-code   = " Итого по "
                  Gds-zap-artic = Substring(
                                      B1-name
                                      ,1,16)
                  Gds-zap-gds-name = Substring(
                                      B1-name
                                      ,17,40)
                                .
          Else  Assign
                  S-bar-code   = ""
                  Gds-zap-artic = "        Итого по "
                  Gds-zap-gds-name =  B1-name
                                .
            Run Display-b1 In This-procedure .
            Run Clear-b1 In This-procedure .
            Assign Break_Group = True.
        End.
  End.
End.
  end.
        when 2   then do:
define variable vss-include-info45 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if x-selectobject = "currency":u  or  xtog-obj then do :
define variable first-l45 as logical   no-undo .
  first-l45 = true .
      for  each gds-obj where
                gds-obj.obj-code   = x-store-code and
                gds-obj.obj-type   = x-store-type
                and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
                no-lock ,
      first  tmp#grp  where gds-obj.grp-name   begins tmp#grp.grp-name   no-lock ,
      first goods       where gds-obj.gds-code   = goods.gds-code  no-lock
      break by func-vat (input gds-obj.gds-code , input x-store-type, input x-store-code)
            by (goods.artic)
            :
      var-vat-pc = func-vat ( input gds-obj.gds-code, input x-store-type, input x-store-code) .
      if last-vat <> var-vat-pc then do:
          if not first-l45 then do:
            Assign
                s-bar-code    = ""
                gds-zap-artic = "        Итого по "
                gds-zap-gds-name = b1-name
                .
              run display-b1.
              run clear-b1  .
          end.
          Assign
            first-l45 = false
            break_group = true
            break_group1 = true
            .
          end.
      first-l45 = false .
      run item-goods ( "6" , "goods" ) .
      last-vat = func-vat (input gds-obj.gds-code , input x-store-type, input x-store-code) .
   end.
    Assign
        s-bar-code   = ""
        gds-zap-artic = "        Итого по "
        gds-zap-gds-name = b1-name
        .
      run display-b1.
      run clear-b1.
end.
else do:
   for each obj-list no-lock :
            for each gds-obj where
                gds-obj.obj-type = obj-list.obj-type    and
                gds-obj.obj-code = obj-list.obj-code
                and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
                 no-lock ,
              first  tmp#grp  where gds-obj.grp-name   begins tmp#grp.grp-name   no-lock ,
              first goods       where gds-obj.gds-code   = goods.gds-code  no-lock :
                  if not can-find(first temp-gds-list where temp-gds-list.gds-code = gds-obj.gds-code) then do:
                              create temp-gds-list.
define variable vss-include-info46 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  gds-obj.gds-code
  ,input  '1':U
  ,input  ?
  ,input  v-cntxt-host-code-obj
  ,input  gds-obj.obj-type
  ,input  gds-obj.obj-code
  ,output var-vat-pc
  ) no-error .
                              assign
                                temp-gds-list.prod-code = gds-obj.prod-code
                                temp-gds-list.grp-name  = gds-obj.grp-name
                                temp-gds-list.gds-name  = goods.gds-name
                                temp-gds-list.gds-code  = gds-obj.gds-code
                                temp-gds-list.artic     = gds-obj.artic
                                temp-gds-list.vat-pc    = var-vat-pc
                              .
                  end.
            end.
  end.
  for each temp-gds-list no-lock
    , first goods     where goods.gds-code  = temp-gds-list.gds-code no-lock
      break by (func-vat(gds-obj.gds-code,gds-obj.obj-type,gds-obj.obj-code))  by goods.artic :
    run item-goods ( "6" , "goods" ) .
      if return-value <> "" then next.
        If Last-of((func-vat(gds-obj.gds-code,gds-obj.obj-type,gds-obj.obj-code))) Then Do:
        If String(Entry(2,"(func-vat(gds-obj.gds-code,gds-obj.obj-type,gds-obj.obj-code))",".")) = "Grp-name"
          Then  Assign
                  S-bar-code   = " Итого по "
                  Gds-zap-artic = Substring(
                                      B1-name
                                      ,1,16)
                  Gds-zap-gds-name = Substring(
                                      B1-name
                                      ,17,40)
                                .
          Else  Assign
                  S-bar-code   = ""
                  Gds-zap-artic = "        Итого по "
                  Gds-zap-gds-name =  B1-name
                                .
            Run Display-b1 In This-procedure .
            Run Clear-b1 In This-procedure .
            Assign Break_Group = True.
        End.
  end.
end.
  end.
        when 3  then do:
define variable vss-include-info47 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if x-selectobject = "currency":u or xtog-obj then do:
define variable first-l47 as logical   no-undo .
  first-l47 = true .
  for  each gds-obj
      where gds-obj.obj-code   = x-store-code
        and gds-obj.obj-type   = x-store-type
            and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
            no-lock ,
  first g#cli
        where gds-obj.prod-code  = g#cli.obj-code
        and  gds-obj.prod-type   = g#cli.obj-type
        no-lock,
  first goods
        where gds-obj.gds-code = goods.gds-code no-lock
      break by func-vat (input gds-obj.gds-code , input x-store-type, input x-store-code)
            by (goods.artic)
            :
      var-vat-pc = func-vat ( input gds-obj.gds-code, input x-store-type, input x-store-code) .
      if last-vat <> var-vat-pc then do:
          if not first-l47 then do:
            Assign
                s-bar-code    = ""
                gds-zap-artic = "        Итого по "
                gds-zap-gds-name = b1-name
                .
              run display-b1.
              run clear-b1  .
          end.
          Assign
            first-l47 = false
            break_group = true
            break_group1 = true
            .
          end.
      first-l47 = false .
      run item-goods ( "6" , "goods" ) .
      last-vat = func-vat (input gds-obj.gds-code , input x-store-type, input x-store-code) .
   end.
    Assign
        s-bar-code   = ""
        gds-zap-artic = "        Итого по "
        gds-zap-gds-name = b1-name
        .
      run display-b1.
      run clear-b1.
  end.
  else do:
    for each obj-list no-lock :
          for  each gds-obj
            where  gds-obj.obj-code   = obj-list.obj-code
              and  gds-obj.obj-type   = obj-list.obj-type
              and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
            no-lock ,
          first g#cli
              where gds-obj.prod-code = g#cli.obj-code
              and   gds-obj.prod-type = g#cli.obj-type
              no-lock,
          first goods
              where gds-obj.gds-code = goods.gds-code no-lock :
                if not can-find (first temp-gds-list where temp-gds-list.gds-code = gds-obj.gds-code) then do:
                    create temp-gds-list.
define variable vss-include-info48 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  gds-obj.gds-code
  ,input  '1':U
  ,input  ?
  ,input  v-cntxt-host-code-obj
  ,input  gds-obj.obj-type
  ,input  gds-obj.obj-code
  ,output var-vat-pc
  ) no-error .
                    assign
                      temp-gds-list.prod-code = gds-obj.prod-code
                      temp-gds-list.grp-name  = gds-obj.grp-name
                      temp-gds-list.gds-name  = goods.gds-name
                      temp-gds-list.gds-code  = gds-obj.gds-code
                      temp-gds-list.artic     = gds-obj.artic
                      temp-gds-list.vat-pc    = var-vat-pc
                    .
                end.
          end.
    end.
      for each temp-gds-list no-lock
        , first goods  where goods.gds-code  = temp-gds-list.gds-code no-lock
          break by (func-vat(gds-obj.gds-code,gds-obj.obj-type,gds-obj.obj-code))   by goods.artic :
        run item-goods ( "6" , "goods" ) .
          if return-value <> "" then next.
        If Last-of((func-vat(gds-obj.gds-code,gds-obj.obj-type,gds-obj.obj-code))) Then Do:
        If String(Entry(2,"(func-vat(gds-obj.gds-code,gds-obj.obj-type,gds-obj.obj-code))",".")) = "Grp-name"
          Then  Assign
                  S-bar-code   = " Итого по "
                  Gds-zap-artic = Substring(
                                      B1-name
                                      ,1,16)
                  Gds-zap-gds-name = Substring(
                                      B1-name
                                      ,17,40)
                                .
          Else  Assign
                  S-bar-code   = ""
                  Gds-zap-artic = "        Итого по "
                  Gds-zap-gds-name =  B1-name
                                .
            Run Display-b1 In This-procedure .
            Run Clear-b1 In This-procedure .
            Assign Break_Group = True.
        End.
      end.
end.
  end.
        otherwise do:
define variable vss-include-info49 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
IF x-SelectObject = "currency":U  OR  xTog-obj then do :
define variable first-l49 as logical   no-undo .
  first-l49 = true .
  for each gds-obj
    where gds-obj.obj-type = x-store-type
      and gds-obj.obj-code = x-store-code
          and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
          no-lock,
      first goods  where  goods.gds-code = gds-obj.gds-code
      no-lock,
      First gds-list  where gds-list.gds-code =  gds-obj.gds-code
      no-lock
      break by func-vat (input gds-obj.gds-code , input x-store-type, input x-store-code)
            by (gds-list.artic)
            :
      var-vat-pc = func-vat ( input gds-obj.gds-code, input x-store-type, input x-store-code) .
      if last-vat <> var-vat-pc then do:
          if not first-l49 then do:
            Assign
                s-bar-code    = ""
                gds-zap-artic = "        Итого по "
                gds-zap-gds-name = b1-name
                .
              run display-b1.
              run clear-b1  .
          end.
          Assign
            first-l49 = false
            break_group = true
            break_group1 = true
            .
          end.
      first-l49 = false .
      run item-goods ( "6" , "gds-list" ) .
      last-vat = func-vat (input gds-obj.gds-code , input x-store-type, input x-store-code) .
   end.
    Assign
        s-bar-code   = ""
        gds-zap-artic = "        Итого по "
        gds-zap-gds-name = b1-name
        .
      run display-b1.
      run clear-b1.
end.
else do:
   For each obj-list no-lock :
                  FOR EACH gds-obj where
                      gds-obj.obj-type = obj-list.obj-type    and
                      gds-obj.obj-code = obj-list.obj-code
                      and ( (v-show-all-goods = true ) or   ( gds-obj.last-doc = ? or gds-obj.last-doc >= x-date-start or gds-obj.fact-qnty <> 0 or gds-obj.avrg-qnty <> 0 or gds-obj.fact-sale <> 0 or gds-obj.fact-base <> 0 ) )
                      no-lock,
                First gds-list  where gds-obj.gds-code  = gds-list.gds-code
                      no-lock :
                      find first temp-gds-list where temp-gds-list.gds-code = gds-obj.gds-code no-error .
                      if not available temp-gds-list then do:
                          find first goods no-lock  where goods.gds-code  = gds-obj.gds-code .
                          Create temp-gds-list.
define variable vss-include-info50 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  gds-obj.gds-code
  ,input  '1':U
  ,input  ?
  ,input  v-cntxt-host-code-obj
  ,input  gds-obj.obj-type
  ,input  gds-obj.obj-code
  ,output var-vat-pc
  ) no-error .
                          Assign
                            temp-gds-list.prod-code = gds-obj.prod-code
                            temp-gds-list.grp-name  = gds-obj.grp-name
                            temp-gds-list.gds-name  = goods.gds-name
                            temp-gds-list.gds-code  = gds-obj.gds-code
                            temp-gds-list.artic     = gds-obj.artic
                            temp-gds-list.vat-pc    = var-vat-pc
                          .
                      End.
                      else do:
                      if temp-gds-list.vat-pc = 0 or temp-gds-list.vat-pc = ? then do:
define variable vss-include-info51 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  gds-obj.gds-code
  ,input  '1':U
  ,input  ?
  ,input  v-cntxt-host-code-obj
  ,input  gds-obj.obj-type
  ,input  gds-obj.obj-code
  ,output var-vat-pc
  ) no-error .
                            Assign
                              temp-gds-list.vat-pc    = var-vat-pc
                            .
                      end.
                      end.
            End.
  End.
  for each temp-gds-list no-lock
    , First gds-list  where gds-list.gds-code  = temp-gds-list.gds-code no-lock
      BREAK BY (func-vat(gds-obj.gds-code,gds-obj.obj-type,gds-obj.obj-code))  BY gds-list.artic :
    run item-goods ( "6" , "gds-list" ) .
      if return-value <> "" then NEXT.
        If Last-of((func-vat(gds-obj.gds-code,gds-obj.obj-type,gds-obj.obj-code))) Then Do:
        If String(Entry(2,"(func-vat(gds-obj.gds-code,gds-obj.obj-type,gds-obj.obj-code))",".")) = "Grp-name"
          Then  Assign
                  S-bar-code   = " Итого по "
                  Gds-zap-artic = Substring(
                                      B1-name
                                      ,1,16)
                  Gds-zap-gds-name = Substring(
                                      B1-name
                                      ,17,40)
                                .
          Else  Assign
                  S-bar-code   = ""
                  Gds-zap-artic = "        Итого по "
                  Gds-zap-gds-name =  B1-name
                                .
            Run Display-b1 In This-procedure .
            Run Clear-b1 In This-procedure .
            Assign Break_Group = True.
        End.
  End.
End.
        end.
      end case.
end procedure.
PROCEDURE CalcItog :
    run ostatok in this-procedure
    (   input x-store-code  ,
        input x-store-type  , x-TOG-Shift,
        input x-date-start - 1 ,
        input date ('')      , x-Shift-Start,x-Shift-End,
        input 'crsa':U   ,
        input '##,##':U,
        input xTog-obj ,
        output  Quantity1  ,
        output  Coast_R1   ,
        output  Coast_V1   ,
        output  VAT_R1     ,
        output  VAT_V1     ,
        output  Fact-order-1 ).
    run ostatok in this-procedure
    (
        input x-store-code  ,
        input x-store-type  ,x-TOG-Shift,
        input x-date-start  ,
        input x-date-end    , x-Shift-Start,x-Shift-End,
        input 'crsa':U   ,
        input '##,##':U,
        input xTog-obj ,
        output  Quantity1  ,
        output  Coast_R1   ,
        output  Coast_V1   ,
        output  VAT_R1     ,
        output  VAT_V1     ,
        output  Fact-order-2 ).
          Quantity1  = 0.
          Coast_R1   = 0.
          Coast_V1   = 0.
          VAT_R1     = 0.
          VAT_V1     = 0.
END PROCEDURE.
PROCEDURE display-str1  :
define variable i as integer no-undo .
define variable v-nn as integer   no-undo .
 qnty-orders = "" .
if showorders = true then DO:
    v-nn = num-entries (Number-Orders,CHR(9))  .
    repeat i = 1 to v-nn :
    If entry (i,Number-Orders,CHR(9)) <> ?
       and entry (i,Number-Orders,CHR(9)) <> ""
       and entry (i,Number-Orders,CHR(9)) <> "0" Then DO:
      Find first ub.doc-line where
            entry (i,Number-Orders,CHR(9)) =  ub.doc-line.doc-code
            AND   ub.doc-line.obj-code   = x-store-code
            AND   ub.doc-line.obj-type   = x-store-type
            AND   ub.doc-line.prod-code  = gds-zap-prod-code
            AND   ub.doc-line.prod-type  = gds-zap-prod-type
            AND   ub.doc-line.status_    = 'запрос':U
            AND   ub.doc-line.artic      = gds-zap-artic
            no-lock no-error .
            qnty-orders =  qnty-orders  +
                       (if avail ub.doc-line then
                      string (ub.doc-line.fact-qnty)  Else "0")  +  "," .
     End.
    End.
 End.
 Else qnty-orders = "".
 run di  ("кол-во", 1, gds-zap-b-code,gds-zap-artic,gds-zap-gds-name,gds-zap-unit-base,"").
END PROCEDURE.
PROCEDURE display-Bi  :
   qnty-orders = "".
   run di ("кол-во",1,  "", gds-zap-artic ,"" ,"", "BI":U).
       run macr_cell_format  (
          10       ,
          true     ,
          false    ,
          ?        ,
          num#str# ,
          1        ,
          num#str# ,
          14 )
          .
END PROCEDURE.
PROCEDURE display-B1  :
    qnty-orders = "".
    run di ("кол-во"  ,1,  ( s-bar-code + ' ' + CAPS (gds-zap-artic + gds-zap-gds-name)) , "" ,"","","B1":U).
       run macr_cell_format  (
          10       ,
          true     ,
          false    ,
          ?        ,
          num#str# ,
          1        ,
          num#str# ,
          14 )
          .
END PROCEDURE.
PROCEDURE display-Bo  :
END PROCEDURE.
PROCEDURE display-B2  :
    qnty-orders = "".
    run di  ( "кол-во", 1 , ( s-bar-code + ' ' + caps (gds-zap-artic + gds-zap-gds-name)), "" ,"", "","b2":u).
       run macr_cell_format  (
          10       ,
          true     ,
          false    ,
          36        ,
          num#str# ,
          1        ,
          num#str# ,
          14 )
          .
END PROCEDURE.
PROCEDURE Clear-B1  :
 REPEAT kk = 1 to 6 :
 Assign
    b1-Prih                                            [kk]    = 0
    b1-Rash                                            [kk]    = 0
    b1-KAssa                                           [kk]    = 0
    b1-Inv                                             [kk]    = 0
    b1-Overturn                                        [kk]    = 0
    b1-ostatok-end                                     [kk]    = 0
    b1-ostatok-start                                   [kk]    = 0
    b1-f-zakaz        = 0
    b1-F-Center-stock = 0
    b1-F-avr          = 0  .
   End.
 END PROCEDURE.
PROCEDURE Clear-B2  :
 REPEAT kk = 1 to 6 :
 Assign
    b2-Prih                                            [kk]    = 0
    b2-Rash                                            [kk]    = 0
    b2-KAssa                                           [kk]    = 0
    b2-Inv                                             [kk]    = 0
    b2-Overturn                                        [kk]    = 0
    b2-ostatok-end                                     [kk]    = 0
    b2-ostatok-start                                   [kk]    = 0
    b2-f-zakaz        = 0
    b2-F-Center-stock = 0
    b2-F-avr          = 0  .
   End.
END PROCEDURE.
PROCEDURE Clear-Bi  :
 REPEAT kk = 1 to 6 :
 Assign
    bi-Prih                                            [kk]    = 0
    bi-Rash                                            [kk]    = 0
    bi-KAssa                                           [kk]    = 0
    bi-ostatok-end                                     [kk]    = 0
    bi-ostatok-start                                   [kk]    = 0
    bi-f-zakaz                                                = 0
    bi-F-Center-stock                                         = 0
    bi-F-avr                                                  = 0  .
   End.
END PROCEDURE.
PROCEDURE Display-title :
    i=0.
END PROCEDURE.
PROCEDURE ob-line  :
define input  parameter x-store-code     like ub.clients.obj-code      no-undo.
define input  parameter x-store-type     like ub.clients.obj-type      no-undo.
define INPUT  parameter x-artic          like ub.stk-line.artic        no-undo.
define INPUT  parameter x-prod-code      like ub.stk-line.prod-code    no-undo.
define INPUT  parameter x-prod-type      like ub.stk-line.prod-type    no-undo.
define INPUT  parameter x-Fact-order-1   like ub.stk-line.Fact-order   no-undo.
define INPUT  parameter x-Fact-order-2   like ub.stk-line.Fact-order   no-undo.
define input  parameter x-sum-type       like ub.stk-line.sum-type     no-undo.
define input  parameter x-cat-id         like ub.stk-line.cat-id       no-undo.
define input  parameter x-ext-doc-type   like ub.ot-line.ext-doc-type no-undo.
define input  parameter xTog-obj         as log no-undo.
define input  parameter xi               as int no-undo.
define output  parameter Quntity         like ub.stk-line.fact-qnty   no-undo.
define variable  First-sum   like ub.stk-line.fact-qnty   no-undo.
define variable  Second-sum  like ub.stk-line.fact-qnty   no-undo.
if x-Fact-order-2 < x-Fact-order-1 Then x-Fact-order-2 = x-Fact-order-1.
  Assign First-sum = 0 Second-sum = 0 Quntity = 0 .
  For EAch obj-list  where  x-store-type = obj-list.obj-type  AND  x-store-code = obj-list.obj-code
   no-lock:
   FOR each temp#sum-type where temp#sum-type.xi = xi no-lock :
      FIND LAST ub.stk-line where
                              ub.stk-line.artic         = x-artic
                        AND   ub.stk-line.fact-order   <= x-fact-order-1
                        AND   ub.stk-line.obj-code     = obj-list.obj-code
                        AND   ub.stk-line.obj-type     = obj-list.obj-type
                        AND   ub.stk-line.prod-code    = x-prod-code
                        AND   ub.stk-line.prod-type    = x-prod-type
                        AND   ub.stk-line.sum-type     = temp#sum-type.sum-type
                        AND   ub.stk-line.cat-id       = '##,##':U
                              no-lock use-index pi no-error.
           if available ub.stk-line THEN First-sum = First-sum + ub.stk-line.fact-qnty.
      FIND LAST STK-line2 where
                              STK-line2.artic         = x-artic
                        AND   STK-line2.fact-order   <= x-fact-order-2
                        AND   STK-line2.obj-code     = obj-list.obj-code
                        AND   STK-line2.obj-type     = obj-list.obj-type
                        AND   STK-line2.prod-code    = x-prod-code
                        AND   STK-line2.prod-type    = x-prod-type
                        AND   STK-line2.sum-type     = temp#sum-type.sum-type
                        AND   STK-line2.cat-id       = '##,##':U
                              no-lock use-index pi  no-error.
           if available STK-LINE2 THEN Second-sum = Second-sum + Stk-line2.fact-qnty.
   End.
   End.
   Quntity = Second-sum - first-sum.
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
PROCEDURE report-exec1  :
for each TMP#bs share-lock: delete TMP#bs. end.
   FIND FIRST clients where x-store-type = clients.obj-type AND
                            x-store-code = clients.obj-code no-lock no-error.
           If available clients then  ObjName = clients.obj-name.
                                         else  ObjName = "объект не определен".
  run calcitog.
  run print-header.
   case retclassify :
      when "no-classify":u    then  run run1.
      when "grp-goods":u      then  run run2.
      when "prod":u           then  run run3.
      when "prod/grp-goods":u then  run run4.
      when "grp-goods/prod":u then  run run5.
      when "vat-ps":u         then  run run7.
   end case.
   if tog-qnty then
      run printtemptable in this-procedure .
      else run print-footer in this-procedure  .
  END PROCEDURE.
PROCEDURE Calc-Sub-itog :
define input parameter tt as int no-undo.
define variable b as int no-undo.
  Assign
  B1-Prih[1]    = B1-Prih[1]    +  Prih[1]
  B2-Prih[1]    = B2-Prih[1]    +  Prih[1]
  Bi-Prih[1]    = Bi-Prih[1]    +  Prih[1]
  B1-f-zakaz    = B1-f-zakaz   + f-zakaz
  B2-f-zakaz    = B2-f-zakaz   + f-zakaz
  Bi-f-zakaz    = Bi-f-zakaz   + f-zakaz
  B1-F-Center-stock = B1-F-Center-stock  +  F-Center-stock
  B2-F-Center-stock = B2-F-Center-stock  +  F-Center-stock
  Bi-F-Center-stock = Bi-F-Center-stock  +  F-Center-stock
  B1-F-avr = B1-F-avr  +  F-avr
  B2-F-avr = B2-F-avr  +  F-avr
  Bi-F-avr = Bi-F-avr  +  F-avr.
repeat b = 1 to 6:
  B1-KAssa[b + TT]    = B1-KAssa[b + TT]    +  KAssa[b + TT] .
  B2-kassa[b + TT]    = B2-kassa[b + TT]    +  kassa[b + TT] .
  Bi-Kassa[b + TT]    = Bi-Kassa[b + TT]    +  Kassa[b + TT] .
End.
END PROCEDURE.
PROCEDURE Clear-item :
define variable kk as int no-undo.
 REPEAT kk = 1 to 6:
 Assign
    prih                 [kk]    = 0
    rash                 [kk]    = 0
    kassa               [kk]    = 0
    ostatok-end      [kk] =   0
    ostatok-start    [kk] =   0   .
       End.
 END PROCEDURE.
PROCEDURE Item-Goods :
 define input parameter  par-3 as char no-undo.
 define input parameter  par-4 as char no-undo.
      if par-4 = "goods":U  Then DO:
          FIND FIRST clients WHERE clients.obj-type = Goods.prod-type AND
                              clients.obj-code = Goods.prod-code use-index pi NO-LOCK .
                                assign
                                    gds-zap-unit-base  = Goods.unit-base
                                    gds-zap-prt-root   = Goods.prt-root
                                    gds-zap-prod-type  = Goods.prod-type
                                    gds-zap-prod-code  = Goods.prod-code
                                    gds-zap-artic      = Goods.artic
                                    gds-zap-grp-name   = Goods.grp-name
                                    gds-zap-b-code     = Goods.gds-code
                                    gds-zap-prod-name  = clients.obj-name .
                                if g#gds-engl then
                                    assign gds-zap-gds-name = Goods.engl-name.
                                else
                                    assign gds-zap-gds-name = Goods.gds-name.
                            End.
     if par-4 = "gds-list":U  Then DO:
          FIND FIRST clients WHERE clients.obj-type = gds-list.prod-type AND
                              clients.obj-code = gds-list.prod-code use-index pi NO-LOCK .
                                assign
                                    gds-zap-unit-base  = gds-list.unit-base
                                    gds-zap-prt-root   = gds-list.prt-root
                                    gds-zap-prod-type  = gds-list.prod-type
                                    gds-zap-prod-code  = gds-list.prod-code
                                    gds-zap-artic      = gds-list.artic
                                    gds-zap-grp-name   = gds-list.grp-name
                                    gds-zap-b-code     = gds-list.gds-code
                                    gds-zap-prod-name  = clients.obj-name .
                                if g#gds-engl then
                                    assign gds-zap-gds-name = gds-list.engl-name.
                                else
                                    assign gds-zap-gds-name = gds-list.gds-name.
                            End.
   run foreach.
    if  break_group = true  and par-3 <> "1"  then do :
         find first clients where clients.obj-type = gds-zap-prod-type and clients.obj-code = gds-zap-prod-code use-index pi no-lock .
         gds-zap-prod-name  = clients.obj-name.
          If break_group1 = true  THEN  DO :
            if  (par-3 = "3"  OR  par-3 = "5" ) and  par-3 <> "6"
              then DO: Assign temp-str = string ("ГРУППА : " + gds-zap-grp-name )         b1-name = gds-zap-grp-name . end.
              else DO: Assign temp-str = string ("ПРОИЗВОДИТЕЛЬ : " + gds-zap-prod-name ) b1-name = gds-zap-prod-name. end.
              if par-3 = "6"  then  DO:
                        var-vat-pc = (func-vat(gds-obj.gds-code,gds-obj.obj-type,gds-obj.obj-code)) .
                        assign
                            temp-str = string ( "СТАВКА НДС : " + string (var-vat-pc) + "%" )
                            b1-name = temp-str.
              end.
               if NOT xSumsOnly or  (par-3 = "4" Or par-3 = "5" ) THEN DO :
                fr0 = true .
                tmp#stroka0 = temp-str.
define variable vss-include-info52 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
Num#str# = Num#str# + 1.
run macr_excel_char ( string(tmp#stroka0)  , num#str# , 1 ) .
                run macr_cell_format  (
                              10       ,
                              true     ,
                              true     ,
                              36       ,
                              num#str#,
                              1        ,
                              num#str# ,
                              14 )
                              .
               End.
          End.
          IF  (par-3 = "4"  OR  par-3 = "5")  THEN DO:
            if par-3 = "4"
              then Assign temp-str = string ("ГРУППА : " + gds-zap-grp-name )          b2-name = gds-zap-grp-name .
              else Assign temp-str = string ("ПРОИЗВОДИТЕЛЬ : " + gds-zap-prod-name )  b2-name = gds-zap-prod-name.
            if NOT xSumsOnly THEN DO:
                fr = true .
define variable vss-include-info53 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
Num#str# = Num#str# + 1.
run macr_excel_char ( string(temp-str)  , num#str# , 1 ) .
   .
                run macr_cell_format  (
                              10       ,
                              true     ,
                              true     ,
                              37       ,
                              num#str#,
                              1        ,
                              num#str# ,
                              14 )
                              .
            End.
            break_group1 = false.
          END.
       break_group = false.
    End.
    If NOT Tog-Qnty THEN run display-line.
 END PROCEDURE.
PROCEDURE Di :
define input parameter p1 as char no-undo.
define input parameter p2 as int no-undo.
define input parameter p3 as char no-undo.
define input parameter p4 as char no-undo.
define input parameter p5 as char no-undo.
define input parameter p6 as char no-undo.
define input parameter p7 as char no-undo.
 CASE CAPS (p7) :
   WHEN "B1":U  Then
            run display-str-ex  ( '',
                p3                  ,
                p4                  ,
                b1-F-zakaz          ,
                b1-F-center-stock   ,
                b1-Prih       [1]   ,
                b1-ostatok-end[1]   ,
                b1-F-avr            ,
                b1-KAssa      [1]   ,
                b1-KAssa      [2]   ,
                b1-KAssa      [3]   ,
                b1-KAssa      [4]   ,
                b1-KAssa      [5]   ,
                b1-KAssa      [6]   ).
   WHEN "B2":U  Then
             run display-str-ex  ( '',
                p3                  ,
                p4                  ,
                b2-F-zakaz          ,
                b2-F-center-stock   ,
                b2-Prih [1]         ,
                b2-ostatok-end[1]   ,
                b2-F-avr            ,
                b2-KAssa      [1]   ,
                b2-KAssa      [2]   ,
                b2-KAssa      [3]   ,
                b2-KAssa      [4]   ,
                b2-KAssa      [5]   ,
                b2-KAssa      [6]   ).
   WHEN "BI":U Then
             run display-str-ex  ( '',
                ''                   ,
                p4                   ,
                bi-f-zakaz           ,
                bi-f-center-stock    ,
                bi-prih          [1] ,
                bi-ostatok-end   [1] ,
                bi-f-avr             ,
                bi-kassa       [1]   ,
                bi-kassa         [2] ,
                bi-kassa         [3] ,
                bi-kassa         [4] ,
                bi-kassa         [5] ,
                bi-kassa         [6] ).
   when ""  then
             run display-str-ex  ( ':',
                ii                    ,
                p4                    ,
                f-zakaz               ,
                f-center-stock        ,
                prih          [1]     ,
                ostatok-end   [1]     ,
                f-avr                 ,
                kassa         [1]     ,
                kassa         [2]     ,
                kassa         [3]     ,
                kassa         [4]     ,
                kassa         [5]     ,
                kassa         [6]     ).
       end case.
 end procedure.
 procedure zakaz :
   f-zakaz = 0.
   for each ub.trn-doc where
          ub.trn-doc.doc-date <= x-date-end
    and   ub.trn-doc.doc-date >= x-date-start
    and   ub.trn-doc.status_   = 'запрос':U
    and   ub.trn-doc.internal  = false
    and   ub.trn-doc.obj-code   = x-store-code
    and   ub.trn-doc.obj-type   = x-store-type
     no-lock :
      for each ub.doc-line where
              ub.trn-doc.doc-code =  ub.doc-line.doc-code
        and   ub.doc-line.obj-code   = x-store-code
        and   ub.doc-line.obj-type   = x-store-type
        and   ub.doc-line.prod-code  = gds-zap-prod-code
        and   ub.doc-line.prod-type  = gds-zap-prod-type
        and   ub.doc-line.status_    = 'запрос':U
        and   ub.doc-line.artic      = gds-zap-artic    no-lock :
              f-zakaz = f-zakaz  +  ub.doc-line.doc-qnty   .
      end.
   end.
end procedure.
procedure maket :
  create temp#sum-type no-error.
  assign temp#sum-type.sum-type = 'cgdt':U + 'iv':U       temp#sum-type.xi = 1      .
  create temp#sum-type no-error.
  assign temp#sum-type.sum-type = 'cgdt':U +  'ev':U       temp#sum-type.xi = 1      .
  Create temp#sum-type no-error.
  Assign temp#sum-type.sum-type =  'es':U       temp#sum-type.xi = 2      .
  Create temp#sum-type no-error.
  Assign temp#sum-type.sum-type =  'rs':U   temp#sum-type.xi = 2      .
 If tog-voz then do:
    Create temp#sum-type no-error.
    Assign temp#sum-type.sum-type =  're':U        temp#sum-type.xi = 2      .
  End.
 End procedure.
Procedure Display-str-ex :
 define input parameter  p0  as char no-undo.
 define input parameter  p1  as char no-undo.
 define input parameter  p2  as char no-undo.
 define input parameter  p3  as decimal no-undo.
 define input parameter  p4  as decimal no-undo.
 define input parameter  p5  as decimal no-undo.
 define input parameter  p6  as decimal no-undo.
 define input parameter  p7  as decimal no-undo.
 define input parameter  p8  as decimal no-undo.
 define input parameter  p9  as decimal no-undo.
 define input parameter  p10 as decimal no-undo.
 define input parameter  p11 as decimal no-undo.
 define input parameter  p12 as decimal no-undo.
 define input parameter  p13 as decimal no-undo.
define variable l as integer no-undo .
define variable m as integer no-undo .
define variable v-nnn as integer   no-undo .
if Showorders = false THEN DO:
define variable vss-include-info54 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
Num#str# = Num#str# + 1.
run macr_excel_char ( string(p1)  , num#str# , 1 ) .
 .
define variable vss-include-info55 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run macr_excel_char ( string(p2)  , num#str# , 2 ) .
 .
define variable vss-include-info56 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run macr_excel_dec ( p3  , num#str# , 3 ) .
 .
define variable vss-include-info57 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run macr_excel_dec ( p4  , num#str# , 4 ) .
 .
define variable vss-include-info58 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run macr_excel_dec ( p5  , num#str# , 5 ) .
 .
define variable vss-include-info59 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run macr_excel_dec ( p6  , num#str# , 6 ) .
 .
define variable vss-include-info60 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run macr_excel_dec ( p7  , num#str# , 7 ) .
 .
define variable vss-include-info61 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run macr_excel_dec ( p8  , num#str# , 8 ) .
 .
define variable vss-include-info62 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run macr_excel_dec ( p9  , num#str# , 9 ) .
 .
define variable vss-include-info63 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run macr_excel_dec ( p10  , num#str# , 10 ) .
 .
define variable vss-include-info64 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run macr_excel_dec ( p11  , num#str# , 11 ) .
 .
define variable vss-include-info65 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run macr_excel_dec ( p12  , num#str# , 12 ) .
 .
define variable vss-include-info66 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run macr_excel_dec ( p13  , num#str# , 13 ) .
  .
End.
Else DO:
define variable vss-include-info67 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
Num#str# = Num#str# + 1.
run macr_excel_char ( string(p1)  , num#str# , 1 ) .
 .
define variable vss-include-info68 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run macr_excel_char ( string(p2)  , num#str# , 2 ) .
 .
define variable vss-include-info69 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run macr_excel_dec ( p3  , num#str# , 3 ) .
 .
define variable vss-include-info70 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run macr_excel_dec ( p4  , num#str# , 4 ) .
 .
define variable vss-include-info71 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run macr_excel_dec ( p5  , num#str# , 5 ) .
 .
define variable vss-include-info72 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run macr_excel_dec ( p6  , num#str# , 6 ) .
 .
define variable vss-include-info73 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run macr_excel_dec ( p7  , num#str# , 7 ) .
 .
define variable vss-include-info74 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run macr_excel_dec ( p8  , num#str# , 8 ) .
 .
               v-nnn = num-entries (qnty-orders).
               repeat l = 1 to v-nnn :
                   m = 8 + l .
define variable vss-include-info75 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run macr_excel_dec ( entry(l,qnty-orders)  , num#str# , m ) .
 .
               End.
End.
End procedure.
PROCEDURE MAketemptable :
   Assign
    v#b-code        = gds-zap-b-code
    v#artic         = gds-zap-artic
    v#prod-code     = gds-zap-prod-code
    v#prod-type     = gds-zap-prod-type
    v#prt-root      = gds-zap-prt-root
    v#grp-name      = gds-zap-grp-name
    v#F-zakaz       =  F-zakaz
    v#F-center-stock=  F-center-stock
    v#Prih          =  Prih          [1]
    v#ostatok-end   =  ostatok-end   [1]
    v#f-avr         =  f-avr
    v#kASSA1        =  kAssa         [1]
    v#KAssa2        =  KAssa         [2]
    v#KAssa3        =  KAssa         [3]
    v#KAssa4        =  KAssa         [4]
    v#KAssa5        =  KAssa         [5]
    v#KAssa6        =  KAssa         [6]      no-error.
   If RR <= xBSAmount Then DO:
   Create TMP#bs.
   run eqq.
   End.
 Else DO:
      Find Last TMP#bs  use-index Byf-avr.
      If available TMP#bs AND ABSOLUTE (v#f-avr ) > ABSOLUTE (TMP#bs.f-avr ) Then run eqq.
 End.
END PROCEDURE.
PROCEDURE Eqq :
   Assign
    TMP#bs.b-code        = v#b-code
    TMP#bs.artic         = v#artic
    TMP#bs.prod-code     = v#prod-code
    TMP#bs.prod-type     = v#prod-type
    TMP#bs.prt-root      = v#prt-root
    TMP#bs.grp-name      = v#grp-name
    TMP#bs.F-zakaz       = v#F-zakaz
    TMP#bs.F-center-stock= v#F-center-stock
    TMP#bs.Prih          = v#Prih
    TMP#bs.ostatok-end   = v#ostatok-end
    TMP#bs.f-avr         = v#f-avr
    TMP#bs.kASSA1        = v#kASSA1
    TMP#bs.KAssa2        = v#KAssa2
    TMP#bs.KAssa3        = v#KAssa3
    TMP#bs.KAssa4        = v#KAssa4
    TMP#bs.KAssa5        = v#KAssa5
    TMP#bs.KAssa6        = v#KAssa6
    .
END PROCEDURE.
PROCEDURE PrintTempTAble :
define variable i as int init 0  no-undo.
define variable l as integer no-undo .
define variable v-nn as integer   no-undo .
    For each TMP#bs  where TMP#bs.f-avr <> 0 by
     (if xSorttype = "sort-code":U  THEN string (TMP#bs.b-code)
       ELSE if xSorttype = "sort-artic":U  THEN TMP#bs.artic
            ELSE  string (TMP#bs.f-avr,"9999999999.999"))   :
                i = i + 1 .
 qnty-orders = "".
    v-nn = num-entries (Number-Orders,CHR(9)) .
if showorders = true then DO:
    repeat l = 1 to v-nn :
    If entry (l,Number-Orders,CHR(9)) <> ?
       and entry (l,Number-Orders,CHR(9)) <> ""
       and entry (l,Number-Orders,CHR(9)) <> "0" Then DO:
      Find first ub.doc-line where
            entry (l,Number-Orders,CHR(9)) =  ub.doc-line.doc-code
            AND   ub.doc-line.obj-code   = x-store-code
            AND   ub.doc-line.obj-type   = x-store-type
            AND   ub.doc-line.prod-code  = TMP#bs.prod-code
            AND   ub.doc-line.prod-type  = TMP#bs.prod-type
            AND   ub.doc-line.status_    = 'запрос':U
            AND   ub.doc-line.artic      = TMP#bs.artic
            no-lock no-error .
            qnty-orders =  qnty-orders  +
                       (if avail ub.doc-line then
                      string (ub.doc-line.fact-qnty)  Else "0")  +  "," .
     End.
    End.
 End.
 Else qnty-orders = "".
                run display-line-tmp (i).
    End.
    run u-line.
    qnty-orders = "".
end procedure.
procedure display-line-tmp :
define input parameter i as int no-undo.
             run display-str-ex  ( ':',
                i                    ,
                tmp#bs.artic            ,
                tmp#bs.f-zakaz             ,
                tmp#bs.f-center-stock      ,
                tmp#bs.prih                ,
                tmp#bs.ostatok-end         ,
                tmp#bs.f-avr               ,
                tmp#bs.kassa1              ,
                tmp#bs.kassa2              ,
                tmp#bs.kassa3              ,
                tmp#bs.kassa4              ,
                tmp#bs.kassa5              ,
                tmp#bs.kassa6              ).
end procedure.
procedure ob-line-1  :
define input  parameter x-store-code     like clients.obj-code      no-undo.
define input  parameter x-store-type     like clients.obj-type      no-undo.
define input  parameter x-artic          like ub.stk-line.artic        no-undo.
define input  parameter x-prod-code      like ub.stk-line.prod-code    no-undo.
define input  parameter x-prod-type      like ub.stk-line.prod-type    no-undo.
define input  parameter x-fact-order-1   like ub.stk-line.fact-order   no-undo.
define input  parameter x-fact-order-2   like ub.stk-line.fact-order   no-undo.
define input  parameter x-sum-type       like ub.stk-line.sum-type     no-undo.
define input  parameter x-cat-id         like ub.stk-line.cat-id       no-undo.
define input  parameter x-ext-doc-type   like ub.ot-line.ext-doc-type no-undo.
define input  parameter xtog-obj         as log no-undo.
define input  parameter xi               as int no-undo.
define output  parameter quntity         like ub.stk-line.fact-qnty   no-undo.
define variable  first-sum   like ub.stk-line.fact-qnty   no-undo.
  assign
    first-sum = 0
    quntity = 0
    .
    for each obj-list  where
             obj-list.obj-type = x-store-type  and
             obj-list.obj-code = x-store-code
             :
      for each temp#sum-type where
               temp#sum-type.xi = xi
               :
      for each  ub.ot-line no-lock where
                ub.ot-line.artic         = x-artic                and
                ub.ot-line.fact-order   <= x-fact-order-2         and
                ub.ot-line.fact-order   >= x-fact-order-1         and
                ub.ot-line.obj-code     = obj-list.obj-code       and
                ub.ot-line.obj-type     = obj-list.obj-type       and
                ub.ot-line.prod-code    = x-prod-code             and
                ub.ot-line.prod-type    = x-prod-type             and
                ub.ot-line.sum-type     = 'crsa':U             and
                ub.ot-line.ext-doc-type = temp#sum-type.sum-type
               :
            assign
              first-sum = first-sum + ub.ot-line.fact-qnty
              .
      end.
    end.
 end.
 Quntity = first-sum.
END PROCEDURE.
def var vss-include-info76 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure macr_excel_char :
 do
 on error undo, return error return-value
 :
 define input parameter  p-val as character no-undo .
 define input parameter  p-row as integer no-undo .
 define input parameter  p-col as integer no-undo .
 if p-val = ? then p-val = "" .
    put stream macr_excel unformatted
          substitute('formula(&3,"r&1c&2")', p-row , p-col , format-excel-text-macr ( p-val) ) + chr(10)  .
 end.
end procedure.
procedure macr_excel_char_with_format :
 do
 on error undo, return error return-value
 :
 define input parameter  p-val as character no-undo .
 define input parameter  p-row as integer no-undo .
 define input parameter  p-col as integer no-undo .
 if p-val = ? then p-val = "" .
    put stream macr_excel unformatted
          substitute('select("r&1c&2")', p-row , p-col ) + chr(10) .
    put stream macr_excel unformatted 'format.number("@")' + chr(10) .
    put stream macr_excel unformatted
          substitute('formula(&3,"r&1c&2")', p-row , p-col , format-excel-text-macr ( p-val) ) + chr(10)  .
 end.
end procedure.
procedure macr_excel_cell_format :
 do
 on error undo, return error return-value
 :
 define input parameter  p-val    as character no-undo .
 define input parameter  p-row    as integer   no-undo .
 define input parameter  p-col    as integer   no-undo .
 define input parameter  p-format as character no-undo .
 if p-val = ? then p-val = "" .
    put stream macr_excel unformatted
          substitute('select("r&1c&2")', p-row , p-col ) + chr(10) .
    put stream macr_excel unformatted substitute('format.number("&1")', p-format) + chr(10) .
    put stream macr_excel unformatted
          substitute('formula(&3,"r&1c&2")', p-row , p-col , format-excel-text-macr ( p-val) ) + chr(10)  .
 end.
end procedure.
procedure macr_excel_sum :
 do
 on error undo, return error return-value
 :
 define input parameter  p-row as integer no-undo .
 define input parameter  p-col as integer no-undo .
 define input parameter  p-row1 as integer no-undo .
 define input parameter  p-col1 as integer no-undo .
 define input parameter  p-row2 as integer no-undo .
 define input parameter  p-col2 as integer no-undo .
    put stream macr_excel unformatted
          substitute('formula("=sum(r&3c&4:r&5c&6)","r&1c&2")', p-row , p-col , p-row1 , p-col1 ,p-row2 , p-col2 ) + chr(10)  .
 end.
end procedure.
procedure macr_excel_dec :
 do
 on error undo, return error return-value
 :
 define input parameter  p-val as character no-undo .
 define input parameter  p-row as integer   no-undo .
 define input parameter  p-col as integer   no-undo .
  if p-val = ? then p-val =  "" .
   put  stream macr_excel unformatted
        substitute('formula(&3,"r&1c&2")', p-row , p-col ,  p-val )  + chr(10) .
 end.
end procedure.
procedure macr_cell_format :
 do
 on error undo, return error return-value
 :
 define input parameter  p-size   as integer   no-undo .
 define input parameter  p-bold   as logical   no-undo .
 define input parameter  p-italic as logical   no-undo .
 define input parameter  p-color  as integer   no-undo .
 define input parameter  p-row    as integer   no-undo .
 define input parameter  p-col    as integer   no-undo .
 define input parameter  p-row-2  as integer   no-undo .
 define input parameter  p-col-2  as integer   no-undo .
  if p-size = ? then p-size = 10 .
  if p-bold = ? then p-bold = false .
  if p-italic = ? then p-italic = false .
  if p-row-2 = ? then p-row-2 = p-row .
  if p-col-2 = ? then p-col-2 = p-col .
  put  stream macr_excel unformatted
   substitute('select("r&1c&2:r&3c&4 ")' , p-row , p-col , p-row-2 , p-col-2 ) + chr(10) .
  if p-color <> ? then do:
     put  stream macr_excel unformatted
       substitute('patterns(1,,&1,true)', p-color ) + chr(10)  .
  end.
  put  stream macr_excel unformatted
       substitute('format.font(,&1,&2,&3)' , p-size,
                                        string ( p-bold  , "true/false" ) ,
                                        string ( p-italic , "true/false" )
                                        ) + chr(10) .
 end.
end procedure.
procedure macr_cell_size :
 do
 on error undo, return error return-value
 :
 define input parameter  p-w   as integer   no-undo .
 define input parameter  p-l   as integer   no-undo .
 define input parameter  p-row    as integer   no-undo .
 define input parameter  p-col    as integer   no-undo .
 define input parameter  p-row-2  as integer   no-undo .
 define input parameter  p-col-2  as integer   no-undo .
  if p-row-2 = ? then p-row-2 = p-row .
  if p-col-2 = ? then p-col-2 = p-col .
  if p-w = ? then    p-w = 0 .
  if p-l = ? then    p-l = 0 .
 define variable s-w as character no-undo .
 define variable s-l as character no-undo .
 if p-w = 0 then s-w = "" .
            else s-w = string(p-w)  .
 if p-l = 0 then s-l = "" .
            else s-l = string(p-l)  .
put  stream macr_excel unformatted
     substitute('select("r&1c&2:r&3c&4 ")' , p-row , p-col , p-row-2 , p-col-2 )  skip .
put  stream macr_excel unformatted
     substitute('COLUMN.WIDTH(&1,,,,)' , s-w  )  skip.
put  stream macr_excel unformatted
     'FORMAT.TEXT(2,2,0,,,,,)'  skip.
 end.
end procedure.
procedure proc-print-header :
 do
 on error undo, return error return-value
 :
   find first sheetf .
     sheetf.excel-row-heder =  num-entries( c-str ,chr(10)) + 1.
     sheetf.excel-row-title =  num-entries( sheetf.excel-column-lable , chr(10) ).
     var-1 =  num#str# .
     repeat c-c = 1 to sheetf.excel-row-title :
     num#str# = num#str# + 1 .
     p-var = num-entries( entry (c-c, sheetf.excel-column-lable, chr(10)) , chr(44) ) .
     do c-i = 1 to p-var :
        str--1 = entry( c-i, entry (c-c,sheetf.excel-column-lable, chr(10)) , chr(44)) .
        str--2 = integer(entry( c-i, sheetf.sizes )) .
        num#col# = c-i .
        run macr_excel_char_with_format ( str--1  , num#str# , num#col#  ) .
        run macr_cell_size ( str--2 , ? , num#str# , num#col# , ?, ? ) .
     end.
    c-i = 0.
    end.
    run macr_cell_format (
        10       ,
        true     ,
        false    ,
        35       ,
        var-1 + 1,
        1        ,
        num#str# ,
        num#col# )
        .
  put  stream macr_excel unformatted
       substitute('select("r&1c&2:r&3c&4 ")' , var-1 + 1 , 1 , num#str# ,  num#col# ) + chr(10)  +
       'ALIGNMENT(3 , , 4 , 4 ,)'  + chr(10)
       .
 end.
end procedure.
procedure end-proc :
 do
 on error undo, return error return-value
 :
  v-file-name = ( string( session:temp-directory + "rpt" + string( g#report-num ) ) + ".t-t").
  OUTPUT to VALUE (v-file-name) .
  for each temp-param :
    export  temp-param  .
  end.
 end.
end procedure.
procedure new-tmp-page :
 do
 on error undo, return error return-value
 :
    if   num#str#  >=  63000  then do:
        output stream macr_excel  close .
        run paramls-write in this-procedure
           (input "file"
          ,input string (v-ind)
          ,input v-file-name
          ) .
        run gbl/_tmpfile.p ("wb", ".txt", output v-file-name) .
        output stream  macr_excel to value (v-file-name) .
        v-ind = v-ind + 1 .
        num#str# = 0 .
   run make-col .
   run proc-print-header .
  end.
 end.
end procedure.
procedure make-col :
do
on error undo, return error return-value
:
  num#str# = num#str# + 2.
end.
end procedure.
