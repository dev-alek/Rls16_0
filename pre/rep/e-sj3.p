block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define output parameter p-frame-width as integer no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":u .
define variable vss-author      as character no-undo init "$Author: expertek $":u .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":u .
define variable vss-workfile    as character no-undo init "$Workfile: e-sj3.p $":u .
define variable vss-archive     as character no-undo init "$Archive: rep/e-sj3.p $":u .
define variable vss-description as character no-undo init "Журнал продаж" .
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
define  shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define  shared variable RepPathName        as character no-undo .
define  shared variable PrintRubl          as logical   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output var-report-r-b
  )  .
function diff-list returns character (
  input parfirst-list  as character,
  input parsecond-list as character,
  input pardelim       as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem as character no-undo .
  def var v-result-list as character no-undo init "".
  def var v-num-parfirst-list as integer no-undo .
  assign
    v-num-parfirst-list = num-entries(parfirst-list, pardelim)
  .
  do ind = 1 to v-num-parfirst-list
  :
    assign
      v-elem = entry(ind, parfirst-list, pardelim)
    .
    if lookup(v-elem, parsecond-list, pardelim) = 0 then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  return v-result-list .
end function.
function add-list returns character (
 input parfirst-list  as character,
 input parsecond-list as character,
 input pardelim       as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem as character no-undo .
  def var v-result-list as character no-undo init "".
  def var v-num-parfirst-list as integer no-undo .
  assign
    v-num-parfirst-list = num-entries(parfirst-list, pardelim)
  .
  do ind = 1 to v-num-parfirst-list
  :
    assign
      v-elem = entry(ind, parfirst-list, pardelim)
    .
    if lookup(v-elem, v-result-list, pardelim) = 0 then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  def var v-num-parsecond-list as integer no-undo .
  assign
    v-num-parsecond-list = num-entries(parsecond-list, pardelim)
  .
  do ind = 1 to v-num-parsecond-list
  :
    assign
      v-elem = entry(ind, parsecond-list, pardelim)
    .
    if lookup(v-elem, v-result-list, pardelim) = 0 then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  return v-result-list .
end function.
function cross-list returns character (
 input parfirst-list  as character,
 input parsecond-list as character,
 input pardelim       as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem as character no-undo .
  def var v-result-list as character no-undo init "".
  def var v-num-parfirst-list as integer no-undo .
  assign
    v-num-parfirst-list = num-entries(parfirst-list, pardelim)
  .
  do ind = 1 to v-num-parfirst-list
  :
    assign
      v-elem = entry(ind, parfirst-list, pardelim)
    .
    if lookup(v-elem, v-result-list, pardelim) = 0
    and lookup(v-elem, parsecond-list, pardelim) > 0
    then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  return v-result-list .
end function.
function radio-label returns character (
 input par-rs-value  as character,
 input par-rs-radio-buttons as character)
 .
 DEFINE variable v-result-label as character no-undo.
 assign
 v-result-label =  ENTRY( (IF (LOOKUP(par-rs-value, par-rs-radio-buttons) MODULO 2 = 0)
                           then (LOOKUP(par-rs-value, par-rs-radio-buttons) - 1)
                           else LOOKUP(par-rs-value, par-rs-radio-buttons)
                          ), par-rs-radio-buttons
                        )
 v-result-label = REPLACE(v-result-label, "&":U, "":U)
 .
return v-result-label.
end function.
function m-radio-label returns character (
 input par-rs-value  as character,
 input par-rs-radio-buttons as character,
 input par-delim as character
 )
 .
 DEFINE variable v-result-label as character no-undo.
 assign
 v-result-label =  ENTRY( (IF (LOOKUP(par-rs-value, par-rs-radio-buttons, par-delim) MODULO 2 = 0)
                           then (LOOKUP(par-rs-value, par-rs-radio-buttons, par-delim) - 1)
                           else LOOKUP(par-rs-value, par-rs-radio-buttons, par-delim)
                          ), par-rs-radio-buttons, par-delim
                        )
 v-result-label = REPLACE(v-result-label, "&":U, "":U)
 .
return v-result-label.
end function.
FUNCTION mixlist returns character
(
 input parfirst-list  as character
 ,input parsecond-list as character
 ,input pardelim       as character
 ,input pardelim-result as character ) :
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem1 as character no-undo .
  def var v-elem2 as character no-undo .
  def var v-result-list as character no-undo init "".
  do ind = 1 to num-entries(parfirst-list, pardelim)
  :
    assign
      v-elem1 = entry(ind, parfirst-list, pardelim)
      v-elem2 = entry(ind, parsecond-list, pardelim)
    .
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim-result else "")
                      + v-elem1 + pardelim-result + v-elem2
      .
  end.
  return v-result-list .
END FUNCTION.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE  SHARED  variable    cashdesc-num    AS    INTEGER         no-undo.
DEFINE  SHARED  variable    saleman-num     AS    INTEGER         no-undo.
DEFINE  SHARED     variable prodtot_flag       AS    LOGICAL      no-undo.
DEFINE  SHARED     variable grouptot_flag     AS    LOGICAL       no-undo.
DEFINE  SHARED     variable OneLinePrinted  AS    LOGICAL     no-undo.
DEFINE  SHARED     variable my-Set_val_TYPE AS INTEGER No-undo.
DEFINE  SHARED     variable Rs-sort-str as character no-undo.
DEFINE  SHARED     variable Rs-by-str as character no-undo.
DEFINE  SHARED     variable Rs-cass-str as character no-undo.
DEFINE  SHARED     variable cas-num-str as character no-undo.
DEFINE  SHARED     variable rs-saleman-str as character no-undo.
DEFINE  SHARED     variable saleman-str as character no-undo.
DEFINE  SHARED     variable v-num-chk as integer no-undo.
define Shared variable cas-shft as logical no-undo init no.
define shared variable call-point as char no-undo.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  SHARED  stream PrnLibStream.
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
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define  SHARED  variable Line                as      char    no-undo.
define  SHARED  variable cash_string     as      char    no-undo.
define  SHARED  variable sale_string     as      char    no-undo.
define  SHARED  variable date_string     as      char    no-undo.
define  SHARED  variable NotInc as log no-undo.
define  SHARED  variable namebuf1     as      char    no-undo.
define  SHARED  variable namebuf2     as      char    no-undo.
define  SHARED  variable prodbuf1     as      char    no-undo.
define  SHARED  variable prodbuf2     as      char    no-undo.
define  SHARED  variable stat as logical no-undo.
define  SHARED  variable pcnt  as   decimal  no-undo .
define  SHARED  variable SHBySalers as logical no-undo.
define  SHARED  variable Shrs-seller-cashier as character no-undo .
define  SHARED  variable SHRS-BY as integer no-undo.
define  SHARED  variable SHt-twounit as logical no-undo.
define  SHARED  variable SHRS-SOrt as character no-undo.
define  SHARED  variable SHOnly_tot as logical no-undo.
define variable counter as integer no-undo .
define variable v-seller-cashier-1 as character no-undo .
assign
v-seller-cashier-1 = (if shrs-seller-cashier = "seller"
                      then "Итого прод-ц "
                      else "Итого кассир ").
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
procedure lhistprex-print-gds-list-hist-excel :
define input parameter p-text  as logical no-undo .
define input parameter p-excel as logical no-undo .
define input parameter p-sheet-num as integer no-undo .
define buffer buf_lh-sheetf for sheetf.
define buffer buf_gds-list-hist for gds-list-hist.
  do
  on error undo, return error
  :
    find first buf_gds-list-hist no-lock where buf_gds-list-hist.id = 0 no-error .
    if p-excel then do:
      if   Make-Excel Then  do:   Output stream ForExcel close.   assign   number-list = number-list + 1   .   os-delete value( v-excel-file + ".":U + string(number-list)).   Output Stream ForExcel to value( v-excel-file + ".":U + string(number-list ) ) . end.
      FInd first buf_lh-Sheetf where
                buf_lh-Sheetf.sheet-num = p-sheet-num No-ERROR.
      if not avail buf_lh-sheetf then
      create buf_lh-sheetf.
      assign
      buf_lh-Sheetf.Sheet-num = 2
      buf_lh-sheetf.Excel-Column-Lable =  "№ п/п,Действие,Записей,итого,Множество"
      buf_lh-sheetf.sizes = "9,9,9,12,155"
      .
      run rep/extitlee.p (input p-sheet-num
                    , input  substitute("История создания списка &1 &2"
                                ,
''
                                ,(if available buf_gds-list-hist
                                then buf_gds-list-hist.des
                                else "БЕЗЫМЯННЫЙ"))
                    ) .
    end.
    if p-text then do:
      Page stream PrnLibStream.
      PUT  STREAM PrnLibStream unformatted
      SPACE(25) substitute("История создания списка &1 &2"
                          , ''
                          ,(if available buf_gds-list-hist
                          then buf_gds-list-hist.des
                          else "БЕЗЫМЯННЫЙ")) skip(0)
      space(25) cur-time-print() skip(1)
      .
      put stream PrnLibStream unformatted
      string("№", "X(9)") chr(32)
      string("Действие", "X(9)") chr(32)
      string("записей", "X(9)") chr(32)
      string(" = итого", "X(12)") chr(32)
      (if page-size(PrnLibStream) > 43
      then string("Множество", "X(" + string(136 - 43) + ")")
      else string("Множество", "X(" + string(198 - 43) + ")")
      )
      skip(0)
      fill('-':U, 9) chr(32)
      fill('-':U, 9) chr(32)
      fill('-':U, 9) chr(32)
      fill('-':U, 12) chr(32)
      (if page-size(PrnLibStream) > 43
      then fill('-':U, 136 - 43)
      else fill('-':U, 198 - 43))
      skip(0)
      .
    end.
    for each buf_gds-list-hist where buf_gds-list-hist.id > 0
    by buf_gds-list-hist.id
    :
      if p-text then do:
        put stream PrnLibStream unformatted
        (if buf_gds-list-hist.line = 0
        then string(buf_gds-list-hist.id, ">>>>>>>>9")
        else fill(chr(32) , 9)
        )  chr(32)
        (if buf_gds-list-hist.item_ <> '':U
        then string(buf_gds-list-hist.hist-mode, "X(8)")
        else fill( chr(32), 8)) chr(32)
        string(buf_gds-list-hist.num-add, ">>>>>>>>9") chr(32) chr(32) chr(32) chr(32)
        string(buf_gds-list-hist.num-recs, ">>>>>>>>9")  chr(32)
        (if page-size(PrnLibStream) > 43
        then string(buf_gds-list-hist.des, "X(" + string(136 - 43) + ")")
        else string(buf_gds-list-hist.des, "X(" + string(198 - 43) + ")"))
        skip.
      end.
      if p-excel then do:
        if Make-Excel then  put   stream ForExcel unformatted
        (if buf_gds-list-hist.line = 0
        then string(buf_gds-list-hist.id, ">>>>>>>>9")
        else '':U)
        CHR(9)
        (if buf_gds-list-hist.item_ <> '':U
        then buf_gds-list-hist.hist-mode
        else '':U)  CHR(9)
        (if buf_gds-list-hist.item_ <> '':U
        then string(buf_gds-list-hist.num-add, "->>>>>>>>9")
        else '':U)  CHR(9)
        (if buf_gds-list-hist.item_ <> '':U
        then string(buf_gds-list-hist.num-recs, ">>>>>>>>9")
        else '':U)  CHR(9)
        buf_gds-list-hist.des
        skip.
      end.
    end.
  end.
end procedure.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define SHARED temp-table sj-goods no-undo
field obj-attr     as   char
field b-code like ub.bar-code.b-code format "9999999999999"
field saleman-chr as   character
field artic     like ub.goods.artic
field name   like ub.goods.gds-name format "x(30)"
field grp-code          like ub.goods.grp-code
field grp-name          like ub.goods.grp-code
field prod-name   like ub.clients.obj-name
field node-code like ub.gds-prt.node-code
field node-name like ub.gds-prt.node-name
field twounit as decimal
field two-type as logical
field alt-type as logical
INDEX p1 IS PRIMARY   obj-attr ASCENDING
INDEX p2              obj-attr artic ASCENDING
INDEX p3              obj-attr prod-name ASCENDING
INDEX p4              obj-attr b-code saleman-chr ASCENDING
INDEX p6              obj-attr grp-name prod-name
INDEX p7              grp-code
.
define SHARED temp-table sj-adv no-undo
field obj-attr     as   char
field b-code like ub.bar-code.b-code format "9999999999999"
field saleman-chr as    character
field price    like ub.chk-gds.price-base
field discnt  like ub.chk-gds.discnt
field qnty     like ub.chk-gds.doc-qnty
field qnty-2     like ub.chk-gds.doc-qnty
field qnty-3    like ub.chk-gds.doc-qnty
field dop-rowid as rowid
field brutto-sum   as   decimal
field discnt-sum  like ub.chk-gds.discnt
field netto-sum    as   decimal
field brutto-sum-r   as   decimal
field netto-sum-r    as   decimal
field num-lines as integer
field num-docs as integer
INDEX pi  IS PRIMARY   obj-attr b-code saleman-chr price discnt dop-rowid ASCENDING
.
define SHARED temp-table sj-tots no-undo
field obj-attr     as   char
field grp-code          like ub.goods.grp-code
field grp-name          like ub.goods.grp-code
field prod-name   like ub.clients.obj-name
field saleman-chr as    character
field qnty     like ub.chk-gds.doc-qnty
field qnty-2   like ub.chk-gds.doc-qnty
field qnty-3   like ub.chk-gds.doc-qnty
field brutto-sum   as   decimal
field discnt-sum  like ub.chk-gds.discnt
field netto-sum    as   decimal
field brutto-sum-r   as   decimal
field netto-sum-r    as   decimal
field num-lines as integer
field num-docs as integer
INDEX pi  IS PRIMARY   obj-attr ASCENDING
INDEX p1                        prod-name ASCENDING
INDEX p2                        grp-name  ASCENDING
INDEX p3                        grp-code
.
define SHARED temp-table sj-grp no-undo
field grp-code like ub.goods.grp-code
field grp-name like ub.goods.grp-name
field grp-code-alpha like ub.goods.grp-code
INDEX pi grp-code
INDEX iname  grp-name
INDEX grp-code-alpha grp-code-alpha
.
define SHARED temp-table sj-salesman no-undo
field seller like ub.person.seller
field psn-code like ub.person.psn-code
field sal-chr as character
index pi is unique primary seller psn-code
index ichr sal-chr
index ipsn psn-code
.
FUNCTION get-grp-name returns character( input p-grp-code-alpha as integer):
define buffer buf_sj-grp for sj-grp.
  find first buf_sj-grp no-lock where
            buf_sj-grp.grp-code-alpha = p-grp-code-alpha no-error.
  if available buf_sj-grp then do:
    return buf_sj-grp.grp-name .
  end.
  return "!!!Неизвестное имя группы!!!".
END FUNCTION.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE  VAR    ObjsQnty            AS    INTEGER        no-undo.
DEFINE  VAR    AllObjsTotalsBy     AS    logical        no-undo.
DEFINE  VAR    Strbuf1             AS    character      no-undo.
DEFINE  VAR    intbuf1             AS    integer        no-undo.
DEFINE  var    chk-gds-lines       as    integer        no-undo.
define variable v-header-sale-curr as character no-undo .
define variable v-curr-r-b as character no-undo .
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
if v-curr-r-b = 'base':U then do:
  assign
  v-header-sale-curr = string( "(валюта продажи - баз.вал. )" )
  .
end.
else do:
  assign
  v-header-sale-curr = string( "(валюта продажи - РУБЛИ)"  )
  .
end.
def buffer cli-obj for ub.clients .
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE FRAME SJ-base
        sj-goods.b-code column-label "Код ! " format ">>>>>>>>9"
        sj-goods.artic column-label "Артикул   ! " format "x(16)"
        sj-goods.name column-label "Наименование  ! " format "x(18)"
        sj-goods.prod-name column-label "Производитель! " format "X(15)"
        sj-adv.qnty column-label "Количество !" format "->>>>>>>9.<<<"
        sj-adv.price column-label  "Цена!(вал.продаж)"   format ">>>>>>>9.99"
        sj-adv.brutto-sum column-label  "Сумма!(вал.продаж)"  format "->>>>>>>>>9.99"
        sj-adv.discnt-sum column-label "Сумма скидки!(вал.продаж)" format "->>>>>>>9.99"
        pcnt column-label "%!скидки" format "->>9.9%"
        sj-adv.netto-sum column-label  "Выручка!(вал.продаж)"  format "->>>>>>>9.99" space(0)
    HEADER  date_string format "X(50)" AT 5
    v-header-sale-curr        format "X(30)"
  "Страница " AT 115 PAGE-NUMBER(PrnLibStream) AT 125 FORMAT ">>>9" SKIP
      Line format "X(136)"
      AT 1  with width  136 down stream-io use-text no-box.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE FRAME SJ-full
        sj-goods.b-code column-label "Код ! " format ">>>>>>>>9"
        sj-goods.artic column-label "Артикул   ! " format "x(16)"
        sj-goods.name column-label "Наименование  ! " format "x(18)"
        sj-goods.prod-name column-label "Производитель! " format "X(21)"
        sj-adv.qnty column-label "Количество !" format "->>>>>>>9.<<<"
        sj-adv.price column-label  "Цена!(вал.продаж)"   format ">>>>>>>9.99"
        sj-adv.brutto-sum column-label  "Сумма!(вал.продаж)"  format "->>>>>>>>>9.99"
        sj-adv.brutto-sum-r
            column-label "Сумма!(в рублях)" format "->>>,>>>,>>>,>>9.99"
        sj-adv.discnt-sum column-label "Сумма скидки!(вал.продаж)" format "->>>>>>>9.99"
        pcnt column-label "%!скидки" format "->>9.9%"
        sj-adv.netto-sum column-label  "Выручка!(вал.продаж)"  format "->>>>>>>9.99" space(0)
        sj-adv.netto-sum-r column-label "Выручка!(в рублях)"
                format "->>>,>>>,>>>,>>9.99" space(0)
    HEADER  date_string format "X(50)" AT 5
    v-header-sale-curr        format "X(30)"
                        string( "Страница " ) AT 165 PAGE-NUMBER(PrnLibStream) AT 175 FORMAT ">>>9" SKIP
      Line format "X(196)"
      AT 1 with width  198 down stream-io use-text no-box.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE FRAME SJ-base-t
        sj-goods.b-code column-label "Код ! " format ">>>>>>>>9"
        sj-goods.artic column-label "Артикул   ! " format "x(16)"
        sj-goods.name column-label "Наименование  ! " format "x(18)"
        sj-goods.prod-name column-label "Производитель! " format "X(15)"
        sj-adv.qnty column-label "Количество !учет.ед.изм" format "->>>>>>>9.<<<"
        sj-adv.qnty-2 column-label "Количество !штуки" format "->>>>>>>9.<<<"
        sj-adv.qnty-3 column-label "Количество !вес" format "->>>>>>>9.<<<"
        sj-adv.price column-label  "Цена!(вал.продаж)"   format ">>>>>>>9.99"
        sj-adv.brutto-sum column-label  "Сумма!(вал.продаж)"  format "->>>>>>>>>9.99"
        sj-adv.discnt-sum column-label "Сумма скидки!(вал.продаж)" format "->>>>>>>9.99"
        pcnt column-label "%!скидки" format "->>9.9%"
        sj-adv.netto-sum column-label  "Выручка!(вал.продаж)"  format "->>>>>>>9.99" space(0)
    HEADER  date_string format "X(50)" AT 5
    v-header-sale-curr        format "X(30)"
  "Страница " AT 115 PAGE-NUMBER(PrnLibStream) AT 125 FORMAT ">>>9" SKIP
      Line format "X(196)"
      AT 1  with width  198 down stream-io use-text no-box.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE FRAME SJ-full-t
        sj-goods.b-code column-label "Код ! " format ">>>>>>>>9"
        sj-goods.artic column-label "Артикул   ! " format "x(16)"
        sj-goods.name column-label "Наименование  ! " format "x(18)"
        sj-goods.prod-name column-label "Производитель! " format "X(21)"
        sj-adv.qnty column-label "Количество !учет.ед.изм" format "->>>>>>>9.<<<"
        sj-adv.qnty-2 column-label "Количество !штуки" format "->>>>>>>9.<<<"
        sj-adv.qnty-3 column-label "Количество !вес" format "->>>>>>>9.<<<"
        sj-adv.price column-label  "Цена!(вал.продаж)"   format ">>>>>>>9.99"
        sj-adv.brutto-sum column-label  "Сумма!(вал.продаж)"  format "->>>>>>>>>9.99"
        sj-adv.brutto-sum-r
            column-label "Сумма!(в рублях)" format "->>>,>>>,>>>,>>9.99"
        sj-adv.discnt-sum column-label "Сумма скидки!(вал.продаж)" format "->>>>>>>9.99"
        pcnt column-label "%!скидки" format "->>9.9%"
        sj-adv.netto-sum column-label  "Выручка!(вал.продаж)"  format "->>>>>>>9.99" space(0)
        sj-adv.netto-sum-r column-label "Выручка!(в рублях)"
                format "->>>,>>>,>>>,>>9.99" space(0)
    HEADER  date_string format "X(50)" AT 5
    v-header-sale-curr        format "X(30)"
                        string( "Страница " ) AT 165 PAGE-NUMBER(PrnLibStream) AT 175 FORMAT ">>>9" SKIP
      Line format "X(230)"
      AT 1 with width  232 down stream-io use-text no-box.
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE FRAME SJ-base-d
        sj-goods.b-code column-label "Код ! " format ">>>>>>>>9"
        sj-goods.artic column-label "Артикул   ! " format "x(16)"
        sj-goods.name column-label "Наименование  ! " format "x(18)"
        sj-goods.prod-name column-label "Производитель! " format "X(21)"
        sj-adv.qnty column-label "Количество !" format "->>>>>>>9.<<<"
        sj-adv.price column-label  "Цена!(вал.продаж)"   format ">>>>>>>9.99"
        sj-adv.brutto-sum column-label  "Сумма!(вал.продаж)"  format "->>>>>>>>>9.99"
        sj-adv.discnt column-label  "Скидка!(вал.продаж)"   format "->>>>>>>9.99"
        sj-adv.discnt-sum column-label "Сумма скидки!(вал.продаж)" format "->>>>>>>9.99"
        pcnt column-label "%!скидки" format "->>9.9%"
        sj-adv.netto-sum column-label  "Выручка!(вал.продаж)"  format "->>>>>>>9.99" space(0)
    HEADER  date_string format "X(50)" AT 5
    v-header-sale-curr        format "X(30)"
  "Страница " AT 115 PAGE-NUMBER(PrnLibStream) AT 125 FORMAT ">>>9" SKIP
      Line format "X(196)"
      AT 1  with width  198 down stream-io use-text no-box.
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE FRAME SJ-FULL-d
        sj-goods.b-code column-label "Код ! " format ">>>>>>>>9"
        sj-goods.artic column-label "Артикул   ! " format "x(16)"
        sj-goods.name column-label "Наименование  ! " format "x(18)"
        sj-goods.prod-name column-label "Производитель! " format "X(21)"
        sj-adv.qnty column-label "Количество !" format "->>>>>>>9.<<<"
        sj-adv.price column-label  "Цена!(вал.продаж)"   format ">>>>>>>9.99"
        sj-adv.brutto-sum column-label  "Сумма!(вал.продаж)"  format "->>>>>>>>>9.99"
        sj-adv.brutto-sum-r
            column-label "Сумма!(в рублях)" format "->>>,>>>,>>>,>>9.99"
        sj-adv.discnt column-label  "Скидка!(вал.продаж)"   format "->>>>>>>9.99"
        sj-adv.discnt-sum column-label "Сумма скидки!(вал.продаж)" format "->>>>>>>9.99"
        pcnt column-label "%!скидки" format "->>9.9%"
        sj-adv.netto-sum column-label  "Выручка!(вал.продаж)"  format "->>>>>>>9.99" space(0)
        sj-adv.netto-sum-r column-label "Выручка!(в рублях)"
                format "->>>,>>>,>>>,>>9.99" space(0)
    HEADER  date_string format "X(50)" AT 5
    v-header-sale-curr        format "X(30)"
                        string( "Страница " ) AT 165 PAGE-NUMBER(PrnLibStream) AT 175 FORMAT ">>>9" SKIP
      Line format "X(196)"
      AT 1 with width  232 down stream-io use-text  no-box.
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE FRAME SJ-base-d-t
        sj-goods.b-code column-label "Код ! " format ">>>>>>>>9"
        sj-goods.artic column-label "Артикул   ! " format "x(16)"
        sj-goods.name column-label "Наименование  ! " format "x(18)"
        sj-goods.prod-name column-label "Производитель! " format "X(21)"
        sj-adv.qnty column-label "Количество !учет.ед.изм" format "->>>>>>>9.<<<"
        sj-adv.qnty-2 column-label "Количество !штуки" format "->>>>>>>9.<<<"
        sj-adv.qnty-3 column-label "Количество !вес" format "->>>>>>>9.<<<"
        sj-adv.price column-label  "Цена!(вал.продаж)"   format ">>>>>>>9.99"
        sj-adv.brutto-sum column-label  "Сумма!(вал.продаж)"  format "->>>>>>>>>9.99"
        sj-adv.discnt column-label  "Скидка!(вал.продаж)"   format "->>>>>>>9.99"
        sj-adv.discnt-sum column-label "Сумма скидки!(вал.продаж)" format "->>>>>>>9.99"
        pcnt column-label "%!скидки" format "->>9.9%"
        sj-adv.netto-sum column-label  "Выручка!(вал.продаж)"  format "->>>>>>>9.99" space(0)
    HEADER  date_string format "X(50)" AT 5
    v-header-sale-curr        format "X(30)"
  "Страница " AT 115 PAGE-NUMBER(PrnLibStream) AT 125 FORMAT ">>>9" SKIP
      Line format "X(196)"
      AT 1  with width  198 down stream-io use-text  no-box.
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE FRAME SJ-FULL-d-t
        sj-goods.b-code column-label "Код ! " format ">>>>>>>>9"
        sj-goods.artic column-label "Артикул   ! " format "x(16)"
        sj-goods.name column-label "Наименование  ! " format "x(18)"
        sj-goods.prod-name column-label "Производитель! " format "X(21)"
        sj-adv.qnty column-label "Количество !учет.ед.изм" format "->>>>>>>9.<<<"
        sj-adv.qnty-2 column-label "Количество !штуки" format "->>>>>>>9.<<<"
        sj-adv.qnty-3 column-label "Количество !вес" format "->>>>>>>9.<<<"
        sj-adv.price column-label  "Цена!(вал.продаж)"   format ">>>>>>>9.99"
        sj-adv.brutto-sum column-label  "Сумма!(вал.продаж)"  format "->>>>>>>>>9.99"
        sj-adv.brutto-sum-r
            column-label "Сумма!(в рублях)" format "->>>,>>>,>>>,>>9.99"
        sj-adv.discnt column-label  "Скидка!(вал.продаж)"   format "->>>>>>>9.99"
        sj-adv.discnt-sum column-label "Сумма скидки!(вал.продаж)" format "->>>>>>>9.99"
        pcnt column-label "%!скидки" format "->>9.9%"
        sj-adv.netto-sum column-label  "Выручка!(вал.продаж)"  format "->>>>>>>9.99" space(0)
        sj-adv.netto-sum-r column-label "Выручка!(в рублях)"
                format "->>>,>>>,>>>,>>9.99" space(0)
    HEADER  date_string format "X(50)" AT 5
    v-header-sale-curr        format "X(30)"
                        string( "Страница " ) AT 165 PAGE-NUMBER(PrnLibStream) AT 175 FORMAT ">>>9" SKIP
      Line format "X(230)"
      AT 1 with width  232 down stream-io use-text  no-box.
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function breakstr returns character ( input        for-name    as character,
                                      input        line-length as integer,
                                      input-output line1       as character,
                                      input-output line2       as character ) :
  define variable ii as integer no-undo.
  if length( for-name ) > line-length then do:
    assign ii    = 1
           line1 = "":u
           line2 = "":u.
    if length( entry( ii, for-name , " ":u ) ) > line-length then do:
      assign line1 =       substring( for-name, 1, line-length     )
             line2 = trim( substring( for-name,    line-length + 1 ) ).
    end.                                                     else do:
      do while length( line1 + entry( ii, for-name, " ":u ) ) < ( line-length + 1 ) :
        assign line1 = line1 + entry( ii, for-name, " ":u ) + " ":u
               ii    = ii    + 1.
        if length( entry( ii, for-name, " ":u ) ) > line-length then do:
          assign line1 = line1 + substring( for-name, length( line1 ), line-length - length( line1 ) + 1 ).
        end.
      end.
      assign line2 = trim( substring( for-name, length( line1 ) ) ).
    end.
  end.                                else do:
    assign line1 = for-name
           line2 = "":u.
  end.
  return ( line1 ).
end function.
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION get-strokes
RETURNS CHARACTER
  ( buffer loc-sj-goods for sj-goods,
    input name-len as integer,
    input prod-len as integer,
    input-output loc-namebuf1 as char,
    input-output loc-namebuf2 as char,
    input-output loc-prodbuf1 as char,
    input-output loc-prodbuf2 as char) :
    def var for-name as char no-undo.
    if loc-sj-goods.node-name <> ""
    then for-name = loc-sj-goods.name + "\" + loc-sj-goods.node-name.
    else for-name = loc-sj-goods.name.
    loc-namebuf1 = breakstr(for-name,
                             name-len,
                             input-output loc-namebuf1,
                             input-output loc-namebuf2).
    if v-curr-r-b = 'base':U and my-Set_Val_Type = 3 then  do:
      loc-prodbuf1 = breakstr(loc-sj-goods.prod-name,
                               prod-len,
                               input-output loc-prodbuf1,
                               input-output loc-prodbuf2).
    end.
    else do:
      loc-prodbuf1 = breakstr(loc-sj-goods.prod-name,
                               prod-len,
                               input-output loc-prodbuf1,
                               input-output loc-prodbuf2).
    end.
  RETURN loc-namebuf1.
END FUNCTION.
run main no-error.
if error-status:error then return error.
return.
Procedure main.
define variable v-salesman-name as character no-undo .
define buffer buf_saleman for ub.clients.
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable ii-name as integer no-undo .
for each sj-grp
by sj-grp.grp-name:
  ii-name = ii-name + 1.
  assign
  sj-grp.grp-code-alpha  = ii-name
  .
end.
for each sj-goods
break
by sj-goods.grp-code:
  if first-of(sj-goods.grp-code) then do:
    find first sj-grp no-lock where
              sj-grp.grp-code = sj-goods.grp-code.
    assign
    ii-name = sj-grp.grp-code-alpha.
  end.
  assign
  sj-goods.grp-name = ii-name
  .
end.
for each sj-tots
break
by sj-tots.grp-code:
  if first-of(sj-tots.grp-code) then do:
    find first sj-grp no-lock where
              sj-grp.grp-code = sj-tots.grp-code.
    assign
    ii-name = sj-grp.grp-code-alpha.
  end.
  assign
  sj-tots.grp-name = ii-name
  .
end.
PUT STREAM PrnLibStream
SPACE(25) ( caps( ReportNAme ) + "  " + str1) format "x(110)" SKIP(1)
space(50) "(Без детализации по скидке)" format "x(30)" skip(0)
space(35) ( if NotInc
            then "( по ВСЕМ ЧЕКАМ, в т.ч. невошедшим в отчеты о продажах )"
            else " " ) format "x(80)" skip
SPACE(35) "По объектам : " format "x(15)" .
FOR EACH obj-list :
    FIND FIRST cli-obj WHERE
               cli-obj.obj-type = obj-list.obj-type AND
               cli-obj.obj-code = obj-list.obj-code NO-LOCK .
    PUT STREAM PrnLibStream cli-obj.obj-name format "x(80)" skip space(50) .
    ACCUMULATE ( obj-list.obj-type + string( obj-list.obj-code ) ) ( COUNT ) .
END.
ObjsQnty = ACCUM COUNT ( obj-list.obj-type + string( obj-list.obj-code ) ) .
if ObjsQnty > 1 AND (grouptot_flag OR prodtot_flag)
then AllObjsTotalsBy = yes.
if X-SelectGood = 3 then do:
    PUT STREAM PrnLibStream  "По производителям: " skip space(50) .
    FOR EACH g#cli :
        FIND FIRST cli-obj WHERE
                    cli-obj.obj-type = g#cli.obj-type AND
                    cli-obj.obj-code = g#cli.obj-code NO-LOCK .
        PUT STREAM PrnLibStream  cli-obj.obj-name format "x(80)" skip space(50) .
    END.
end.
PUT STREAM PrnLibStream
 " " skip
SPACE(5) cash_string format "x(115)" SKIP
SPACE(5) sale_string format "x(115)" SKIP
space(62) string( (if shrs-seller-cashier = "seller"
                   then "Итоги по продавцам      :  "
                   else "Итоги по кассирам       :  " )
                   +
                 ( if SHBySalers then "ДА." else "НЕТ." ) ) format "x(65)" skip
SPACE(5) string( string("Классификация: " + Rs-by-str , "x(57)" ) +
                            "Сортировка              :  " +   ( if SHRs-by = 2 OR SHRS-by = 0
                                                                            then "НЕТ."
                                                                            else rs-sort-str)
                            ) format "x(125)" skip(1) .
if v-curr-r-b = 'base':U then do:
  if my-Set_Val_Type = 3 then
  FORM HEADER
  line format "X(196)"
  AT 1 SKIP
  string( "Продолжение - на следующей странице" ) FORMAT "X(35)" AT 30 SKIP
  with FRAME BottomFramebasesj-base-d width  232 PAGE-BOTTOM NO-LABELS NO-BOX .
  VIEW STREAM PrnLibStream FRAME BottomFramebasesj-base-d .
end.
else do:
  FORM HEADER
  line format "X(196)"
  AT 1 SKIP
  string( "Продолжение - на следующей странице" ) FORMAT "X(35)" AT 30 SKIP
  with FRAME BottomFramerublsj-base-d width 232 PAGE-BOTTOM NO-LABELS NO-BOX .
    VIEW STREAM PrnLibStream FRAME BottomFramerublsj-base-d .
end.
CASE my-Set_Val_Type :
  when 2 then
      FORM with FRAME sj-base-d .
  when 3 then
      FORM with FRAME sj-full-d .
END CASE .
assign
p-frame-width = frame sj-base-d:width.
CASE SHRS-by :
    when 1 OR when 0 then do:
      RUN SimpleProc_d in this-procedure .
    end.
    when 3 then do:
      RUN ProdGrpProc_d in this-procedure .
    end.
    when 2 then do:
      if SHRs-Sort = "Article":U then do:
        FOR EACH sj-goods NO-LOCK ,
            EACH sj-adv No-LOCK WHERE
                  sj-adv.obj-attr = sj-goods.obj-attr AND
                  sj-adv.b-code = sj-goods.b-code AND
                  sj-adv.saleman-chr = sj-goods.saleman-chr
            BREAK
            BY sj-goods.obj-attr
            BY sj-goods.grp-name
            BY sj-goods.prod-name
            BY sj-goods.saleman-chr
            BY sj-goods.artic
            BY sj-goods.b-code
            BY sj-adv.price
            BY sj-adv.discnt
    :
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if first( sj-goods.obj-attr ) then do:
  if v-curr-r-b = 'base':U then do:
                        if my-set_val_type = 2  then
                            DOWN STREAM PrnLibStream 1 with FRAME sj-base-d .
                        else
                            DOWN STREAM PrnLibStream 1 with FRAME sj-full-d .
  end.
  else do:
                            DOWN STREAM PrnLibStream 1 with FRAME sj-base-d .
  end.
end.
                if first-of( sj-goods.obj-attr ) AND ( ObjsQnty > 1 ) then  do:
                        assign
                        strbuf1 = substr( sj-goods.obj-attr, 1, 3 )
                        intbuf1 = integer( substr( sj-goods.obj-attr, 4 ) ) .
                        FIND FIRST cli-obj WHERE
                                   cli-obj.obj-type = strbuf1 AND
                                   cli-obj.obj-code = intbuf1 NO-LOCK .
                        PUT STREAM PrnLibStream
                        cli-obj.obj-name format "x(120)" SKIP.
if v-curr-r-b = 'base':U then do:
                        if my-set_val_type = 2  then
                        UNDERLINE STREAM PrnLibStream
                        sj-goods.artic
                        sj-goods.name
                        with FRAME sj-base-d .
                        else
                        UNDERLINE STREAM PrnLibStream
                        sj-goods.artic
                        sj-goods.name
                        with FRAME sj-full-d .
end.
else do:
                        UNDERLINE STREAM PrnLibStream
                        sj-goods.artic
                        sj-goods.name
                        with FRAME sj-base-d .
end.
                    end.
      if first-of( sj-goods.grp-name  ) then do:
        if v-curr-r-b = 'base':U then do:
          if my-Set_Val_Type = 2 then do:
            if frame sj-base-d:line = 0 then do:
              down 1 stream PrnLibStream
              with frame sj-base-d.
            end.
          end.
          else do:
            if frame sj-full-d:line = 0 then do:
              down 1 stream PrnLibStream
              with frame sj-full-d.
            end.
          end.
          PUT STREAM PrnLibStream string( "   ГРУППА : " +  get-grp-name(sj-goods.grp-name) ) format "x(120)" SKIP.
          if my-Set_Val_Type = 2 then do:
            UNDERLINE STREAM PrnLibStream
            sj-goods.artic
            sj-goods.name
            with FRAME sj-base-d .
          end.
          else do:
            UNDERLINE STREAM PrnLibStream
            sj-goods.artic
            sj-goods.name
            with FRAME sj-full-d .
          end.
        end.
        else do:
          if frame sj-base-d:line = 0 then do:
            down 1 stream PrnLibStream
            with frame sj-base-d.
          end.
          PUT STREAM PrnLibStream string( "   ГРУППА : " +  get-grp-name(sj-goods.grp-name) ) format "x(120)" SKIP.
          UNDERLINE STREAM PrnLibStream
          sj-goods.artic
          sj-goods.name
          with FRAME sj-base-d .
        end.
      end.
      if first-of( sj-goods.prod-name ) then do:
        if prodtot_flag or NOT SHOnly_tot then do:
            if v-curr-r-b = 'base':U then do:
              if my-Set_Val_Type = 2 then do:
                if frame sj-base-d:line = 0 then do:
                  down 1 stream PrnLibStream
                  with frame sj-base-d.
                end.
              end.
              else do:
                if frame sj-full-d:line = 0 then do:
                  down 1 stream PrnLibStream
                  with frame sj-full-d.
                end.
              end.
              PUT STREAM PrnLibStream string( "   ПРОИЗВОДИТЕЛЬ : " + sj-goods.prod-name )
              format "x(120)" SKIP .
              if my-Set_Val_Type = 2 then do:
                UNDERLINE STREAM PrnLibStream
                sj-goods.artic
                sj-goods.name
                with FRAME sj-base-d .
              end.
              else do:
                UNDERLINE STREAM PrnLibStream
                sj-goods.artic
                sj-goods.name
                with FRAME sj-full-d .
              end.
            end.
            else do:
              if frame sj-base-d:line = 0 then do:
                down 1 stream PrnLibStream
                with frame sj-base-d.
              end.
              PUT STREAM PrnLibStream string( "   ПРОИЗВОДИТЕЛЬ : " + sj-goods.prod-name )
              format "x(120)" SKIP .
              UNDERLINE STREAM PrnLibStream
              sj-goods.artic
              sj-goods.name
              with FRAME sj-base-d .
            end.
          end.
        end.
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile: e-sjprod.i $ $Revision: aea5316774be, 0, rls $".
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
    ACCUMULATE
    sj-adv.qnty (TOTAL)
    sj-adv.qnty-2 (TOTAL)
    sj-adv.qnty-3 (TOTAL)
    sj-adv.brutto-sum (TOTAL)
    sj-adv.discnt-sum (TOTAL)
    sj-adv.netto-sum (TOTAL)
    sj-adv.brutto-sum-r (TOTAL)
    sj-adv.netto-sum-r (TOTAL)
    sj-adv.num-lines (TOTAL)
    sj-adv.num-docs (TOTAL)
    sj-adv.qnty ( SUB-TOTAL BY sj-goods.obj-attr )
    sj-adv.qnty-2 ( SUB-TOTAL BY sj-goods.obj-attr )
    sj-adv.qnty-3 ( SUB-TOTAL BY sj-goods.obj-attr )
    sj-adv.brutto-sum ( SUB-TOTAL BY sj-goods.obj-attr )
    sj-adv.discnt-sum ( SUB-TOTAL BY sj-goods.obj-attr )
    sj-adv.netto-sum ( SUB-TOTAL BY sj-goods.obj-attr )
    sj-adv.brutto-sum-r ( SUB-TOTAL BY sj-goods.obj-attr )
    sj-adv.netto-sum-r ( SUB-TOTAL BY sj-goods.obj-attr )
    sj-adv.qnty  (SUB-TOTAL BY ( sj-adv.discnt  ))
    sj-adv.qnty-2 (SUB-TOTAL BY ( sj-adv.discnt  ))
    sj-adv.qnty-3 (SUB-TOTAL BY ( sj-adv.discnt  ))
    sj-adv.brutto-sum  (SUB-TOTAL BY (  sj-adv.discnt  ))
    sj-adv.discnt-sum  (SUB-TOTAL BY ( sj-adv.discnt  ))
    sj-adv.netto-sum  (SUB-TOTAL BY (  sj-adv.discnt  ) )
    sj-adv.brutto-sum-r  (SUB-TOTAL BY (  sj-adv.discnt  ))
    sj-adv.netto-sum-r  (SUB-TOTAL BY (  sj-adv.discnt  ) )
    sj-adv.num-lines ( SUB-TOTAL BY (  sj-adv.discnt  ))
    sj-adv.num-docs (SUB-TOTAL BY (  sj-adv.discnt  ))
    sj-adv.qnty (SUB-TOTAL BY sj-goods.grp-name)
    sj-adv.qnty-2 (SUB-TOTAL BY sj-goods.grp-name)
    sj-adv.qnty-3 (SUB-TOTAL BY sj-goods.grp-name)
    sj-adv.brutto-sum (SUB-TOTAL BY sj-goods.grp-name)
    sj-adv.discnt-sum (SUB-TOTAL BY sj-goods.grp-name)
    sj-adv.netto-sum (SUB-TOTAL BY sj-goods.grp-name)
    sj-adv.brutto-sum-r (SUB-TOTAL BY sj-goods.grp-name)
    sj-adv.netto-sum-r (SUB-TOTAL BY sj-goods.grp-name)
    sj-adv.qnty (SUB-TOTAL BY sj-goods.prod-name)
    sj-adv.qnty-2 (SUB-TOTAL BY sj-goods.prod-name)
    sj-adv.qnty-3 (SUB-TOTAL BY sj-goods.prod-name)
    sj-adv.brutto-sum (SUB-TOTAL BY sj-goods.prod-name)
    sj-adv.discnt-sum (SUB-TOTAL BY sj-goods.prod-name)
    sj-adv.netto-sum (SUB-TOTAL BY sj-goods.prod-name)
    sj-adv.brutto-sum-r (SUB-TOTAL BY sj-goods.prod-name)
    sj-adv.netto-sum-r (SUB-TOTAL BY sj-goods.prod-name)
    sj-adv.qnty (SUB-TOTAL BY sj-goods.saleman-chr)
    sj-adv.qnty-2 (SUB-TOTAL BY sj-goods.saleman-chr)
    sj-adv.qnty-3 (SUB-TOTAL BY sj-goods.saleman-chr)
    sj-adv.brutto-sum (SUB-TOTAL BY sj-goods.saleman-chr)
    sj-adv.discnt-sum (SUB-TOTAL BY sj-goods.saleman-chr)
    sj-adv.netto-sum (SUB-TOTAL BY sj-goods.saleman-chr)
    sj-adv.brutto-sum-r (SUB-TOTAL BY sj-goods.saleman-chr)
    sj-adv.netto-sum-r (SUB-TOTAL BY sj-goods.saleman-chr)
    sj-adv.num-lines ( SUB-TOTAL BY sj-goods.saleman-chr )
    sj-adv.num-docs ( SUB-TOTAL BY sj-goods.saleman-chr )
    .
if sj-goods.twounit = 0 then do:
  if last-of (sj-adv.discnt) then  do:
    if not SHOnly_tot then do:
      namebuf1 = get-strokes(buffer sj-goods, 18, 21,
                             input-output namebuf1,
                             input-output namebuf2,
                             input-output prodbuf1,
                             input-output prodbuf2).
    end.
    CASE my-Set_Val_Type :
      when 2 then  do:
        if not SHOnly_tot then
        DISPLAY STREAM PrnLibStream
        sj-goods.b-code
        sj-goods.artic
        namebuf1 @ sj-goods.name
        prodbuf1 @ sj-goods.prod-name
        ACCUM SUB-TOTAL BY  ( sj-adv.discnt )  sj-adv.qnty @ sj-adv.qnty
        sj-adv.price
        ACCUM SUB-TOTAL BY  ( sj-adv.discnt )  sj-adv.brutto-sum @ sj-adv.brutto-sum
        ACCUM SUB-TOTAL BY  ( sj-adv.discnt )  sj-adv.discnt-sum @ sj-adv.discnt-sum
        (IF (ACCUM SUB-TOTAL BY  ( sj-adv.discnt )  sj-adv.qnty ) <> 0 THEN
        round( ( ACCUM SUB-TOTAL BY  ( sj-adv.discnt )  sj-adv.discnt-sum ) /
        ( ACCUM SUB-TOTAL BY  ( sj-adv.discnt )  sj-adv.brutto-sum ) *
          100 , 1 )   ELSE 0) @ pcnt
        ACCUM SUB-TOTAL BY  ( sj-adv.discnt )  sj-adv.netto-sum @ sj-adv.netto-sum
        with FRAME sj-base-d .
        if not SHOnly_tot then
        DOWN STREAM PrnLibStream 1 with FRAME sj-base-d .
      end.
      when 3 then do:
        if not SHOnly_tot then
        DISPLAY STREAM PrnLibStream
        sj-goods.b-code
        sj-goods.artic
        namebuf1 @ sj-goods.name
        prodbuf1 @ sj-goods.prod-name
        ACCUM SUB-TOTAL BY  ( sj-adv.discnt  )  sj-adv.qnty @ sj-adv.qnty
        sj-adv.price
        ACCUM SUB-TOTAL BY  ( sj-adv.discnt  )  sj-adv.brutto-sum @
        sj-adv.brutto-sum
        ACCUM SUB-TOTAL BY  ( sj-adv.discnt  )  sj-adv.brutto-sum-r @
        sj-adv.brutto-sum-r
        ACCUM SUB-TOTAL BY  ( sj-adv.discnt )  sj-adv.discnt-sum @
        sj-adv.discnt-sum
        (IF (ACCUM SUB-TOTAL BY  ( sj-adv.discnt  )  sj-adv.qnty) <> 0 THEN
        round( ( ACCUM SUB-TOTAL BY  ( sj-adv.discnt  )  sj-adv.discnt-sum ) /
              ( ACCUM SUB-TOTAL BY  ( sj-adv.discnt  )  sj-adv.brutto-sum ) *
                      100 , 1 )   ELSE 0) @ pcnt
        ACCUM SUB-TOTAL BY  ( sj-adv.discnt  )  sj-adv.netto-sum @ sj-adv.netto-sum
        ACCUM SUB-TOTAL BY  ( sj-adv.discnt  )  sj-adv.netto-sum-r @ sj-adv.netto-sum-r
        with FRAME sj-full-d .
        if not SHOnly_tot then
        DOWN STREAM PrnLibStream 1 with FRAME sj-full-d.
      end.
    END CASE .
    if ( namebuf2 <> "" ) OR ( prodbuf2 <> "" ) then
    CASE my-Set_Val_Type :
      when 2 then  do:
        if not SHOnly_tot then
          DISPLAY STREAM PrnLibStream
          namebuf2 @ sj-goods.name
          prodbuf2 @ sj-goods.prod-name
          with FRAME sj-base-d .
          if not SHOnly_tot then
          DOWN STREAM PrnLibStream 1 with FRAME sj-base-d .
        end.
      when 3 then do:
        if not SHOnly_tot then
        DISPLAY STREAM PrnLibStream
        namebuf2 @ sj-goods.name
        prodbuf2 @ sj-goods.prod-name
        with FRAME sj-full-d .
        if not SHOnly_tot then
        DOWN STREAM PrnLibStream 1 with FRAME sj-full-d .
      end.
    END CASE .
  end.
end.
if SHBySalers AND last-of( sj-goods.saleman-chr ) then do:
  if entry(2, sj-goods.saleman-chr, chr(4)) <> string(0) then do:
    find first buf_saleman where
              buf_saleman.obj-type = 'чел':U
          AND buf_saleman.obj-code = integer(entry(2, sj-goods.saleman-chr, chr(4))) no-error .
    if not available buf_saleman then do:
      v-salesman-name = '':U.
    end.
    else do:
      v-salesman-name = buf_saleman.obj-name.
    end.
  end.
  CASE my-Set_Val_Type :
    when 2 then  do:
      UNDERLINE STREAM PrnLibStream
      sj-goods.b-code
      sj-goods.artic
      sj-goods.name
      sj-adv.qnty
      sj-adv.brutto-sum
      sj-adv.discnt-sum
      pcnt sj-adv.netto-sum
      with FRAME sj-base-d .
      DISPLAY STREAM PrnLibStream
      (if Shrs-seller-cashier = 'Cashier'
      then  substitute("ч-&1", (ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.num-docs))
      else '':U)  @ sj-goods.b-code
      (if Shrs-seller-cashier = 'Cashier'
      then substitute("стр-&1", (ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.num-lines))
      else '':U)  @ sj-goods.artic
      string( v-seller-cashier-1 + entry(1, sj-goods.saleman-chr, chr(4) ) ) @ sj-goods.name
      v-salesman-name @ sj-goods.prod-name
      ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.qnty    @ sj-adv.qnty
      ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.brutto-sum      @ sj-adv.brutto-sum
      ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.discnt-sum      @ sj-adv.discnt-sum
      (IF (ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.qnty) <> 0
      THEN
      round( ( ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.discnt-sum ) /
                  ( ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.brutto-sum) * 100 , 1 )
      ELSE 0) @ pcnt
      ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.netto-sum   @ sj-adv.netto-sum
      with FRAME sj-base-d .
      DOWN STREAM PrnLibStream 1 with FRAME sj-base-d .
    end.
    when 3 then do:
      UNDERLINE STREAM PrnLibStream
      sj-goods.b-code
      sj-goods.artic
      sj-goods.name
      sj-adv.qnty
      sj-adv.brutto-sum
      sj-adv.brutto-sum-r
      sj-adv.discnt-sum
      pcnt
      sj-adv.netto-sum
      sj-adv.netto-sum-r
      with FRAME sj-full-d .
      DISPLAY STREAM PrnLibStream
      (if Shrs-seller-cashier = 'Cashier'
      then substitute("ч-&1", (ACCUM SUB-TOTAL BY (sj-goods.saleman-chr) sj-adv.num-docs))
      else '':U)  @ sj-goods.b-code
      (if Shrs-seller-cashier = 'Cashier'
      then substitute("стр-&1", (ACCUM SUB-TOTAL BY (sj-goods.saleman-chr) sj-adv.num-lines))
      else '':U) @ sj-goods.artic
      string( v-seller-cashier-1 + entry(1, sj-goods.saleman-chr, chr(4) ) ) @ sj-goods.name
      v-salesman-name @ sj-goods.prod-name
      ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.qnty    @ sj-adv.qnty
      ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.brutto-sum  @ sj-adv.brutto-sum
      ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.brutto-sum-r @ sj-adv.brutto-sum-r
      ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.discnt-sum      @ sj-adv.discnt-sum
      (IF (ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.qnty) <> 0 THEN
      round( ( ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.discnt-sum ) /
                  ( ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.brutto-sum) * 100 , 1 )
        ELSE 0) @ pcnt
      ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.netto-sum   @ sj-adv.netto-sum
      ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.netto-sum-r @ sj-adv.netto-sum-r
      with FRAME sj-full-d .
      DOWN STREAM PrnLibStream 1 with FRAME sj-full-d .
    end.
  END CASE .
  if not last(  sj-adv.discnt  ) then
  CASE my-set_Val_Type :
    when 2 then
      UNDERLINE STREAM PrnLibStream
      sj-goods.b-code
      sj-goods.artic
      sj-goods.name
      sj-adv.qnty
      sj-adv.brutto-sum
      sj-adv.discnt-sum
      pcnt
      sj-adv.netto-sum
      with FRAME sj-base-d .
    when 3 then
      UNDERLINE STREAM PrnLibStream
      sj-goods.b-code
      sj-goods.artic
      sj-goods.name
      sj-adv.qnty
      sj-adv.brutto-sum
      sj-adv.brutto-sum-r
      sj-adv.discnt-sum
      pcnt
      sj-adv.netto-sum
      sj-adv.netto-sum-r
      with FRAME sj-full-d .
    END CASE .
    OneLinePrinted = TRUE .
  end.
  if last-of( sj-goods.prod-name ) AND prodtot_flag then do:
    CASE my-Set_Val_Type :
      when 2 then do:
        UNDERLINE STREAM PrnLibStream
        sj-goods.b-code
        sj-goods.artic
        sj-goods.name
        sj-adv.qnty
        sj-adv.brutto-sum
        sj-adv.discnt-sum
        pcnt
        sj-adv.netto-sum
        with FRAME sj-base-d .
        DISPLAY STREAM PrnLibStream
        "Итого по произв-лю"
                                                                          @ sj-goods.name
        ACCUM SUB-TOTAL BY sj-goods.prod-name sj-adv.qnty    @ sj-adv.qnty
        ACCUM SUB-TOTAL BY sj-goods.prod-name sj-adv.brutto-sum      @ sj-adv.brutto-sum
        ACCUM SUB-TOTAL BY sj-goods.prod-name sj-adv.discnt-sum      @ sj-adv.discnt-sum
        (IF (ACCUM SUB-TOTAL BY sj-goods.prod-name sj-adv.qnty) <> 0 THEN
        round( ( ACCUM SUB-TOTAL BY sj-goods.prod-name sj-adv.discnt-sum ) /
                    ( ACCUM SUB-TOTAL BY sj-goods.prod-name sj-adv.brutto-sum) * 100 , 1 )
          ELSE 0) @ pcnt
        ACCUM SUB-TOTAL BY sj-goods.prod-name sj-adv.netto-sum   @ sj-adv.netto-sum
        with FRAME sj-base-d .
        DOWN STREAM PrnLibStream 1 with FRAME sj-base-d .
      end.
      when 3 then do:
        UNDERLINE STREAM PrnLibStream
        sj-goods.b-code
        sj-goods.artic
        sj-goods.name
        sj-adv.qnty
        sj-adv.brutto-sum
        sj-adv.brutto-sum-r
        sj-adv.discnt-sum
        pcnt
        sj-adv.netto-sum
        sj-adv.netto-sum-r
        with FRAME sj-full-d .
        DISPLAY STREAM PrnLibStream
        "Итого по произв-лю"
                                                                          @ sj-goods.name
        ACCUM SUB-TOTAL BY sj-goods.prod-name sj-adv.qnty    @ sj-adv.qnty
        ACCUM SUB-TOTAL BY sj-goods.prod-name sj-adv.brutto-sum  @ sj-adv.brutto-sum
        ACCUM SUB-TOTAL BY sj-goods.prod-name sj-adv.brutto-sum-r @ sj-adv.brutto-sum-r
        ACCUM SUB-TOTAL BY sj-goods.prod-name sj-adv.discnt-sum      @ sj-adv.discnt-sum
        (IF (ACCUM SUB-TOTAL BY sj-goods.prod-name sj-adv.qnty) <> 0 THEN
        round( ( ACCUM SUB-TOTAL BY sj-goods.prod-name sj-adv.discnt-sum ) /
                    ( ACCUM SUB-TOTAL BY sj-goods.prod-name sj-adv.brutto-sum) * 100 , 1 )
          ELSE 0) @ pcnt
        ACCUM SUB-TOTAL BY sj-goods.prod-name sj-adv.netto-sum   @ sj-adv.netto-sum
        ACCUM SUB-TOTAL BY sj-goods.prod-name sj-adv.netto-sum-r @ sj-adv.netto-sum-r
        with FRAME sj-full-d .
        DOWN STREAM PrnLibStream 1 with FRAME sj-full-d .
      end.
    END CASE .
    if not last( sj-adv.discnt ) then
    CASE my-Set_Val_Type :
      when 2 then
        UNDERLINE STREAM PrnLibStream
        sj-goods.b-code
        sj-goods.artic
        sj-goods.name
        sj-adv.qnty
        sj-adv.brutto-sum
        sj-adv.discnt-sum
        pcnt
        sj-adv.netto-sum
        with FRAME sj-base-d .
      when 3 then
        UNDERLINE STREAM PrnLibStream
        sj-goods.b-code
        sj-goods.artic
        sj-goods.name
        sj-adv.qnty
        sj-adv.brutto-sum
        sj-adv.brutto-sum-r
        sj-adv.discnt-sum
        pcnt
        sj-adv.netto-sum
        sj-adv.netto-sum-r
        with FRAME sj-full-d .
      END CASE .
      OneLinePrinted = TRUE .
    end.
  if last-of( sj-goods.grp-name ) AND grouptot_flag then do:
    IF AllObjsTotalsBy  then do:
      FIND FIRST sj-tots WHERE
                 sj-tots.obj-attr = sj-goods.obj-attr AND
                sj-tots.grp-name = sj-goods.grp-name AND
                sj-tots.prod-name = sj-goods.prod-name No-ERROR.
        IF NOT avail sj-tots then do:
          create sj-tots.
          assign
          sj-tots.obj-attr = sj-goods.obj-attr
          sj-tots.grp-name = sj-goods.grp-name
          sj-tots.qnty = ACCUM SUB-TOTAL BY sj-goods.grp-name sj-adv.qnty
          sj-tots.qnty-2 = ACCUM SUB-TOTAL BY sj-goods.grp-name sj-adv.qnty-2
          sj-tots.qnty-3 = ACCUM SUB-TOTAL BY sj-goods.grp-name sj-adv.qnty-3
          sj-tots.discnt-sum  = ACCUM SUB-TOTAL BY sj-goods.grp-name sj-adv.discnt-sum
          sj-tots.brutto-sum  = ACCUM SUB-TOTAL BY sj-goods.grp-name sj-adv.brutto-sum
          sj-tots.netto-sum  = ACCUM SUB-TOTAL BY sj-goods.grp-name sj-adv.netto-sum.
          IF my-Set_Val_Type = 3 then
          assign
          sj-tots.brutto-sum-r  = ACCUM SUB-TOTAL BY sj-goods.grp-name sj-adv.brutto-sum-r
          sj-tots.netto-sum-r  = ACCUM SUB-TOTAL BY sj-goods.grp-name sj-adv.netto-sum-r.
          ACCUMULATE
          sj-tots.discnt-sum ( TOTAL )
          sj-tots.brutto-sum  ( TOTAL )
          sj-tots.netto-sum  ( TOTAL ).
          IF my-set_val_type = 3 then
          ACCUMULATE
          sj-tots.brutto-sum-r  ( TOTAL )
          sj-tots.netto-sum-r  ( TOTAL ).
        end.
      end.
      CASE my-set_val_type :
        when 2 then do:
          UNDERLINE STREAM PrnLibStream
          sj-goods.b-code
          sj-goods.artic
          sj-goods.name
          sj-adv.qnty
          sj-adv.brutto-sum
          sj-adv.discnt-sum
          pcnt
          sj-adv.netto-sum
          with FRAME sj-base-d .
          DISPLAY STREAM PrnLibStream
          "Итого по группе"
                                                                            @ sj-goods.name
          ACCUM SUB-TOTAL BY sj-goods.grp-name sj-adv.qnty    @ sj-adv.qnty
          ACCUM SUB-TOTAL BY sj-goods.grp-name sj-adv.brutto-sum      @ sj-adv.brutto-sum
          ACCUM SUB-TOTAL BY sj-goods.grp-name sj-adv.discnt-sum      @ sj-adv.discnt-sum
          (IF (ACCUM SUB-TOTAL BY sj-goods.grp-name sj-adv.qnty) <> 0 THEN
          round( ( ACCUM SUB-TOTAL BY sj-goods.grp-name sj-adv.discnt-sum ) /
                      ( ACCUM SUB-TOTAL BY sj-goods.grp-name sj-adv.brutto-sum) * 100 , 1 )
            ELSE 0) @ pcnt
          ACCUM SUB-TOTAL BY sj-goods.grp-name sj-adv.netto-sum   @ sj-adv.netto-sum
          with FRAME sj-base-d .
          DOWN STREAM PrnLibStream 1 with FRAME sj-base-d .
        end.
        when 3 then do:
          UNDERLINE STREAM PrnLibStream
          sj-goods.b-code
          sj-goods.artic
          sj-goods.name
          sj-adv.qnty
          sj-adv.brutto-sum
          sj-adv.brutto-sum-r
          sj-adv.discnt-sum
          pcnt
          sj-adv.netto-sum
          sj-adv.netto-sum-r
          with FRAME sj-full-d .
          DISPLAY STREAM PrnLibStream
          "Итого по группе"
          @ sj-goods.name
          ACCUM SUB-TOTAL BY sj-goods.grp-name sj-adv.qnty    @ sj-adv.qnty
          ACCUM SUB-TOTAL BY sj-goods.grp-name sj-adv.brutto-sum  @ sj-adv.brutto-sum
          ACCUM SUB-TOTAL BY sj-goods.grp-name sj-adv.brutto-sum-r @ sj-adv.brutto-sum-r
          ACCUM SUB-TOTAL BY sj-goods.grp-name sj-adv.discnt-sum      @ sj-adv.discnt-sum
          (IF (ACCUM SUB-TOTAL BY sj-goods.grp-name sj-adv.qnty) <> 0 THEN
          round( ( ACCUM SUB-TOTAL BY sj-goods.grp-name sj-adv.discnt-sum ) /
                 ( ACCUM SUB-TOTAL BY sj-goods.grp-name sj-adv.brutto-sum) * 100 , 1 )
          ELSE 0) @ pcnt
          ACCUM SUB-TOTAL BY sj-goods.grp-name sj-adv.netto-sum   @ sj-adv.netto-sum
          ACCUM SUB-TOTAL BY sj-goods.grp-name sj-adv.netto-sum-r @ sj-adv.netto-sum-r
          with FRAME sj-full-d .
          DOWN STREAM PrnLibStream 1 with FRAME sj-full-d .
        end.
      END CASE .
      if not last(  sj-adv.discnt   ) then
      CASE my-set_val_type :
        when 2 then
          UNDERLINE STREAM PrnLibStream
          sj-goods.b-code
          sj-goods.artic
          sj-goods.name
          sj-adv.qnty
          sj-adv.brutto-sum
          sj-adv.discnt-sum
          pcnt
          sj-adv.netto-sum
          with FRAME sj-base-d .
        when 3 then
          UNDERLINE STREAM PrnLibStream
          sj-goods.b-code
          sj-goods.artic
          sj-goods.name
          sj-adv.qnty
          sj-adv.brutto-sum
          sj-adv.brutto-sum-r
          sj-adv.discnt-sum
          pcnt
          sj-adv.netto-sum
          sj-adv.netto-sum-r
          with FRAME sj-full-d .
      END CASE .
      OneLinePrinted = TRUE .
    end.
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
    if last-of( sj-goods.obj-attr ) AND ( ObjsQnty > 1 ) then do:
            CASE my-set_val_type :
                when 2 then do:
                        UNDERLINE STREAM PrnLibStream
                        sj-goods.name
                        sj-adv.qnty
                        sj-adv.brutto-sum
                        sj-adv.discnt-sum
                        pcnt
                        sj-adv.netto-sum
                        with FRAME sj-base .
                        DISPLAY STREAM PrnLibStream
                        string( "Итого " + sj-goods.obj-attr )
                            @ sj-goods.name
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.qnty    @ sj-adv.qnty
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.brutto-sum
                            @ sj-adv.brutto-sum
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.discnt-sum
                            @ sj-adv.discnt-sum
                        round( ( ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.discnt-sum ) /
                            ( ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.brutto-sum ) * 100 , 1 )
                            @ pcnt
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.netto-sum
                            @ sj-adv.netto-sum
                        with FRAME sj-base .
                        DOWN STREAM PrnLibStream 1 with FRAME sj-base .
                    end.
                when 3 then do:
                        UNDERLINE STREAM PrnLibStream
                        sj-goods.name
                        sj-adv.qnty
                        sj-adv.brutto-sum
                        sj-adv.brutto-sum-r
                        sj-adv.discnt-sum
                        pcnt
                        sj-adv.netto-sum
                        sj-adv.netto-sum-r
                        with FRAME sj-full .
                        DISPLAY STREAM PrnLibStream
                        string( "Итого " + sj-goods.obj-attr )
                            @ sj-goods.name
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.qnty    @ sj-adv.qnty
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.brutto-sum  @ sj-adv.brutto-sum
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.brutto-sum-r @ sj-adv.brutto-sum-r
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.discnt-sum      @ sj-adv.discnt-sum
                        round( ( ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.discnt-sum ) /
                                    ( ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.brutto-sum) * 100 , 1 )
                                        @ pcnt
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.netto-sum   @ sj-adv.netto-sum
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.netto-sum-r @ sj-adv.netto-sum-r
                        with FRAME sj-full .
                        DOWN STREAM PrnLibStream 1 with FRAME sj-full .
                    end.
            END CASE .
            if NOT last(  sj-adv.price ) then
                CASE my-set_val_type :
                    when 2 then
                        UNDERLINE STREAM PrnLibStream
                        sj-goods.name
                        sj-adv.qnty
                        sj-adv.brutto-sum
                        sj-adv.discnt-sum
                        pcnt
                        sj-adv.netto-sum
                        with FRAME sj-base .
                    when 3 then
                        UNDERLINE STREAM PrnLibStream
                        sj-goods.name
                        sj-adv.qnty
                        sj-adv.brutto-sum
                        sj-adv.brutto-sum-r
                        sj-adv.discnt-sum
                        pcnt
                        sj-adv.netto-sum
                        sj-adv.netto-sum-r
                        with FRAME sj-full .
                END CASE .
            OneLinePrinted = TRUE .
        end.
    if last( sj-adv.discnt    ) then do:
      IF AllObjsTotalsBy then do:
        PUT STREAM PrnLibStream string( "   ПО ВСЕМ ОБЪЕКТАМ " +
           "ПО ГРУППАМ:"
           )
        format "x(120)" SKIP .
        for each sj-tots NO-LOCK BREAK BY sj-tots.grp-name:
          ACCUMULATE
          sj-tots.qnty   (TOTAL BY sj-tots.grp-name)
          sj-tots.qnty-2   (TOTAL BY sj-tots.grp-name)
          sj-tots.qnty-3   (TOTAL BY sj-tots.grp-name)
          sj-tots.brutto-sum  (TOTAL BY sj-tots.grp-name)
          sj-tots.discnt-sum  (TOTAL BY sj-tots.grp-name)
          sj-tots.netto-sum   (TOTAL BY sj-tots.grp-name).
          if my-set_val_type = 3  then
          ACCUMULATE
          sj-tots.brutto-sum-r (TOTAL BY sj-tots.grp-name)
          sj-tots.netto-sum-r (TOTAL BY sj-tots.grp-name).
          IF LAST-OF(sj-tots.grp-name) then do:
          CASE my-set_val_type :
            when 2 then do:
              UNDERLINE STREAM PrnLibStream
              sj-goods.b-code
              sj-goods.artic
              sj-goods.name
              sj-adv.qnty
              sj-adv.brutto-sum
              sj-adv.discnt-sum
              pcnt
              sj-adv.netto-sum
              with FRAME sj-base-d .
              DISPLAY STREAM PrnLibStream
              get-grp-name(sj-tots.grp-name)  @ sj-goods.name
              ACCUM TOTAL BY sj-tots.grp-name sj-tots.qnty    @ sj-adv.qnty
              ACCUM TOTAL BY sj-tots.grp-name sj-tots.brutto-sum      @ sj-adv.brutto-sum
              ACCUM TOTAL BY sj-tots.grp-name sj-tots.discnt-sum      @ sj-adv.discnt-sum
              round( ( ACCUM TOTAL BY sj-tots.grp-name sj-tots.discnt-sum ) /
                     ( ACCUM TOTAL BY sj-tots.grp-name sj-tots.brutto-sum) * 100 , 1 )
                              @ pcnt
              ACCUM TOTAL BY sj-tots.grp-name sj-tots.netto-sum   @ sj-adv.netto-sum
              with FRAME sj-base-d .
              DOWN STREAM PrnLibStream 1 with FRAME sj-base-d .
            end.
            when 3 then do:
              UNDERLINE STREAM PrnLibStream
              sj-goods.b-code
              sj-goods.artic
              sj-goods.name
              sj-adv.qnty
              sj-adv.brutto-sum
              sj-adv.brutto-sum-r
              sj-adv.discnt-sum
              pcnt
              sj-adv.netto-sum
              sj-adv.netto-sum-r
              with FRAME sj-full-d .
              DISPLAY STREAM PrnLibStream
              get-grp-name(sj-tots.grp-name) @ sj-goods.name
              ACCUM TOTAL BY sj-tots.grp-name sj-tots.qnty    @ sj-adv.qnty
              ACCUM TOTAL BY sj-tots.grp-name sj-tots.brutto-sum  @ sj-adv.brutto-sum
              ACCUM TOTAL BY sj-tots.grp-name sj-tots.brutto-sum-r @ sj-adv.brutto-sum-r
              ACCUM TOTAL BY sj-tots.grp-name sj-tots.discnt-sum      @ sj-adv.discnt-sum
              round( ( ACCUM TOTAL BY sj-tots.grp-name sj-tots.discnt-sum ) /
                          ( ACCUM TOTAL BY sj-tots.grp-name sj-tots.brutto-sum) * 100 , 1 )
                              @ pcnt
              ACCUM TOTAL BY sj-tots.grp-name sj-tots.netto-sum   @ sj-adv.netto-sum
              ACCUM TOTAL BY sj-tots.grp-name sj-tots.netto-sum-r @ sj-adv.netto-sum-r
              with FRAME sj-full-d .
              DOWN STREAM PrnLibStream 1 with FRAME sj-full-d .
            end.
          END CASE .
        end.
      END.
    end.
    if ( line-counter(PrnLibStream) + 7 ) > page-size(PrnLibStream) then page stream PrnLibStream.
    CASE my-set_val_type :
      when 2 then do:
        if OneLinePrinted then
        PUT STREAM PrnLibStream  LINE format ("X(" + string(198) + ")") SKIP.
        DISPLAY STREAM PrnLibStream
        substitute("ИТОГО ч- &1", v-num-chk) @ sj-goods.name
        ACCUM TOTAL sj-adv.qnty @ sj-adv.qnty
        ACCUM TOTAL sj-adv.brutto-sum @ sj-adv.brutto-sum
        ACCUM TOTAL sj-adv.discnt-sum @ sj-adv.discnt-sum
        (IF (ACCUM TOTAL sj-adv.qnty) <> 0 THEN
        round( ( ACCUM TOTAL sj-adv.discnt-sum ) /
                    ( ACCUM TOTAL sj-adv.brutto-sum ) * 100 , 1 ) ELSE 0) @ pcnt
        ACCUM TOTAL sj-adv.netto-sum @ sj-adv.netto-sum
            with FRAME sj-base-d .
        DOWN STREAM PrnLibStream 1 with FRAME sj-base-d .
        DISPLAY STREAM PrnLibStream
        (string(round((ACCUM TOTAL sj-adv.qnty) / v-num-chk, 2)) + "/ч")  @ sj-adv.qnty
        with FRAME sj-base-d .
        DOWN STREAM PrnLibStream 1 with FRAME sj-base-d .
        UNDERLINE STREAM PrnLibStream
        sj-goods.b-code
        sj-goods.artic
        sj-goods.name
        sj-adv.qnty
        sj-adv.brutto-sum
        sj-adv.discnt-sum
        pcnt
        sj-adv.netto-sum
        with FRAME sj-base-d .
      end.
      when 3 then do:
        if OneLinePrinted then
        PUT STREAM PrnLibStream LINE  SKIP.
        DISPLAY STREAM PrnLibStream
        substitute("ИТОГО ч- &1", v-num-chk) @ sj-goods.name
        ACCUM TOTAL sj-adv.qnty @ sj-adv.qnty
        ACCUM TOTAL sj-adv.brutto-sum @ sj-adv.brutto-sum
        ACCUM TOTAL sj-adv.brutto-sum-r @ sj-adv.brutto-sum-r
        ACCUM TOTAL sj-adv.discnt-sum @ sj-adv.discnt-sum
        (IF (ACCUM TOTAL sj-adv.qnty) <> 0 THEN
        round( ( ACCUM TOTAL sj-adv.discnt-sum ) /
                    ( ACCUM TOTAL sj-adv.brutto-sum ) * 100 , 1 ) ELSE 0) @ pcnt
        ACCUM TOTAL sj-adv.netto-sum @ sj-adv.netto-sum
        ACCUM TOTAL sj-adv.netto-sum-r @ sj-adv.netto-sum-r
        with FRAME sj-full-d .
        DOWN STREAM PrnLibStream 1 with FRAME sj-full-d .
        DISPLAY STREAM PrnLibStream
        (string(round((ACCUM TOTAL sj-adv.qnty) / v-num-chk, 2)) + "/ч") @ sj-adv.qnty
        with FRAME sj-full-d .
        DOWN STREAM PrnLibStream 1 with FRAME sj-full-d .
        UNDERLINE STREAM PrnLibStream
        sj-goods.b-code
        sj-goods.artic
        sj-goods.name
        sj-adv.qnty
        sj-adv.brutto-sum
        sj-adv.brutto-sum-r
        sj-adv.discnt-sum pcnt
        sj-adv.netto-sum
        sj-adv.netto-sum-r
        with FRAME sj-full-d .
      end.
    END CASE .
    if ObjsQnty = 1 then
    PUT STREAM PrnLibStream
    " " SKIP(1) space(10)
    "Директор ______________" format "X(50)"
    "Кассир ___________________" format "X(50)" SKIP .
  end.
      END .
    end.
    else do:
      FOR EACH sj-goods NO-LOCK,
          EACH sj-adv NO-LOCK WHERE
                sj-adv.obj-attr = sj-goods.obj-attr AND
                sj-adv.b-code = sj-goods.b-code AND
                sj-adv.saleman-chr = sj-goods.saleman-chr
          BREAK
          BY sj-goods.obj-attr
          BY sj-goods.grp-name
          BY sj-goods.prod-name
          BY sj-goods.saleman-chr
          BY sj-goods.b-code
          BY sj-adv.price
          BY sj-adv.discnt
      :
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if first( sj-goods.obj-attr ) then do:
  if v-curr-r-b = 'base':U then do:
                        if my-set_val_type = 2  then
                            DOWN STREAM PrnLibStream 1 with FRAME sj-base-d .
                        else
                            DOWN STREAM PrnLibStream 1 with FRAME sj-full-d .
  end.
  else do:
                            DOWN STREAM PrnLibStream 1 with FRAME sj-base-d .
  end.
end.
                if first-of( sj-goods.obj-attr ) AND ( ObjsQnty > 1 ) then  do:
                        assign
                        strbuf1 = substr( sj-goods.obj-attr, 1, 3 )
                        intbuf1 = integer( substr( sj-goods.obj-attr, 4 ) ) .
                        FIND FIRST cli-obj WHERE
                                   cli-obj.obj-type = strbuf1 AND
                                   cli-obj.obj-code = intbuf1 NO-LOCK .
                        PUT STREAM PrnLibStream
                        cli-obj.obj-name format "x(120)" SKIP.
if v-curr-r-b = 'base':U then do:
                        if my-set_val_type = 2  then
                        UNDERLINE STREAM PrnLibStream
                        sj-goods.artic
                        sj-goods.name
                        with FRAME sj-base-d .
                        else
                        UNDERLINE STREAM PrnLibStream
                        sj-goods.artic
                        sj-goods.name
                        with FRAME sj-full-d .
end.
else do:
                        UNDERLINE STREAM PrnLibStream
                        sj-goods.artic
                        sj-goods.name
                        with FRAME sj-base-d .
end.
                    end.
        if first-of( sj-goods.grp-name  ) then do:
          if v-curr-r-b = 'base':U then do:
            if my-Set_Val_Type = 2 then do:
              if frame sj-base-d:line = 0 then do:
                down 1 stream PrnLibStream
                with frame sj-base-d.
              end.
            end.
            else do:
              if frame sj-full-d:line = 0 then do:
                down 1 stream PrnLibStream
                with frame sj-full-d.
              end.
            end.
            PUT STREAM PrnLibStream string( "   ГРУППА : " +  get-grp-name(sj-goods.grp-name) ) format "x(120)" SKIP.
            if my-Set_Val_Type = 2 then do:
              UNDERLINE STREAM PrnLibStream
              sj-goods.artic
              sj-goods.name
              with FRAME sj-base-d .
            end.
            else do:
              UNDERLINE STREAM PrnLibStream
              sj-goods.artic
              sj-goods.name
              with FRAME sj-full-d .
            end.
          end.
          else do:
            if frame sj-base-d:line = 0 then do:
              down 1 stream PrnLibStream
              with frame sj-base-d.
            end.
            PUT STREAM PrnLibStream string( "   ГРУППА : " +  get-grp-name(sj-goods.grp-name) ) format "x(120)" SKIP.
            UNDERLINE STREAM PrnLibStream
            sj-goods.artic
            sj-goods.name
            with FRAME sj-base-d .
          end.
        end.
        if first-of( sj-goods.prod-name ) then do:
          if prodtot_flag OR NOT SHOnly_tot then do:
            if v-curr-r-b = 'base':U then do:
              if my-Set_Val_Type = 2 then do:
                if frame sj-base-d:line = 0 then do:
                  down 1 stream PrnLibStream
                  with frame sj-base-d.
                end.
              end.
              else do:
                if frame sj-full-d:line = 0 then do:
                  down 1 stream PrnLibStream
                  with frame sj-full-d.
                end.
              end.
              PUT STREAM PrnLibStream string( "   ПРОИЗВОДИТЕЛЬ : " + sj-goods.prod-name )
              format "x(120)" SKIP .
              if my-Set_Val_Type = 2 then do:
                UNDERLINE STREAM PrnLibStream
                sj-goods.artic
                sj-goods.name
                with FRAME sj-base-d .
              end.
              else do:
                UNDERLINE STREAM PrnLibStream
                sj-goods.artic
                sj-goods.name
                with FRAME sj-full-d .
              end.
            end.
            else do:
              if frame sj-base-d:line = 0 then do:
                down 1 stream PrnLibStream
                with frame sj-base-d.
              end.
              PUT STREAM PrnLibStream string( "   ПРОИЗВОДИТЕЛЬ : " + sj-goods.prod-name )
              format "x(120)" SKIP .
              UNDERLINE STREAM PrnLibStream
              sj-goods.artic
              sj-goods.name
              with FRAME sj-base-d .
            end.
          end.
        end.
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile: e-sjprod.i $ $Revision: aea5316774be, 0, rls $".
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
    ACCUMULATE
    sj-adv.qnty (TOTAL)
    sj-adv.qnty-2 (TOTAL)
    sj-adv.qnty-3 (TOTAL)
    sj-adv.brutto-sum (TOTAL)
    sj-adv.discnt-sum (TOTAL)
    sj-adv.netto-sum (TOTAL)
    sj-adv.brutto-sum-r (TOTAL)
    sj-adv.netto-sum-r (TOTAL)
    sj-adv.num-lines (TOTAL)
    sj-adv.num-docs (TOTAL)
    sj-adv.qnty ( SUB-TOTAL BY sj-goods.obj-attr )
    sj-adv.qnty-2 ( SUB-TOTAL BY sj-goods.obj-attr )
    sj-adv.qnty-3 ( SUB-TOTAL BY sj-goods.obj-attr )
    sj-adv.brutto-sum ( SUB-TOTAL BY sj-goods.obj-attr )
    sj-adv.discnt-sum ( SUB-TOTAL BY sj-goods.obj-attr )
    sj-adv.netto-sum ( SUB-TOTAL BY sj-goods.obj-attr )
    sj-adv.brutto-sum-r ( SUB-TOTAL BY sj-goods.obj-attr )
    sj-adv.netto-sum-r ( SUB-TOTAL BY sj-goods.obj-attr )
    sj-adv.qnty  (SUB-TOTAL BY ( sj-adv.discnt  ))
    sj-adv.qnty-2 (SUB-TOTAL BY ( sj-adv.discnt  ))
    sj-adv.qnty-3 (SUB-TOTAL BY ( sj-adv.discnt  ))
    sj-adv.brutto-sum  (SUB-TOTAL BY (  sj-adv.discnt  ))
    sj-adv.discnt-sum  (SUB-TOTAL BY ( sj-adv.discnt  ))
    sj-adv.netto-sum  (SUB-TOTAL BY (  sj-adv.discnt  ) )
    sj-adv.brutto-sum-r  (SUB-TOTAL BY (  sj-adv.discnt  ))
    sj-adv.netto-sum-r  (SUB-TOTAL BY (  sj-adv.discnt  ) )
    sj-adv.num-lines ( SUB-TOTAL BY (  sj-adv.discnt  ))
    sj-adv.num-docs (SUB-TOTAL BY (  sj-adv.discnt  ))
    sj-adv.qnty (SUB-TOTAL BY sj-goods.grp-name)
    sj-adv.qnty-2 (SUB-TOTAL BY sj-goods.grp-name)
    sj-adv.qnty-3 (SUB-TOTAL BY sj-goods.grp-name)
    sj-adv.brutto-sum (SUB-TOTAL BY sj-goods.grp-name)
    sj-adv.discnt-sum (SUB-TOTAL BY sj-goods.grp-name)
    sj-adv.netto-sum (SUB-TOTAL BY sj-goods.grp-name)
    sj-adv.brutto-sum-r (SUB-TOTAL BY sj-goods.grp-name)
    sj-adv.netto-sum-r (SUB-TOTAL BY sj-goods.grp-name)
    sj-adv.qnty (SUB-TOTAL BY sj-goods.prod-name)
    sj-adv.qnty-2 (SUB-TOTAL BY sj-goods.prod-name)
    sj-adv.qnty-3 (SUB-TOTAL BY sj-goods.prod-name)
    sj-adv.brutto-sum (SUB-TOTAL BY sj-goods.prod-name)
    sj-adv.discnt-sum (SUB-TOTAL BY sj-goods.prod-name)
    sj-adv.netto-sum (SUB-TOTAL BY sj-goods.prod-name)
    sj-adv.brutto-sum-r (SUB-TOTAL BY sj-goods.prod-name)
    sj-adv.netto-sum-r (SUB-TOTAL BY sj-goods.prod-name)
    sj-adv.qnty (SUB-TOTAL BY sj-goods.saleman-chr)
    sj-adv.qnty-2 (SUB-TOTAL BY sj-goods.saleman-chr)
    sj-adv.qnty-3 (SUB-TOTAL BY sj-goods.saleman-chr)
    sj-adv.brutto-sum (SUB-TOTAL BY sj-goods.saleman-chr)
    sj-adv.discnt-sum (SUB-TOTAL BY sj-goods.saleman-chr)
    sj-adv.netto-sum (SUB-TOTAL BY sj-goods.saleman-chr)
    sj-adv.brutto-sum-r (SUB-TOTAL BY sj-goods.saleman-chr)
    sj-adv.netto-sum-r (SUB-TOTAL BY sj-goods.saleman-chr)
    sj-adv.num-lines ( SUB-TOTAL BY sj-goods.saleman-chr )
    sj-adv.num-docs ( SUB-TOTAL BY sj-goods.saleman-chr )
    .
if sj-goods.twounit = 0 then do:
  if last-of (sj-adv.discnt) then  do:
    if not SHOnly_tot then do:
      namebuf1 = get-strokes(buffer sj-goods, 18, 21,
                             input-output namebuf1,
                             input-output namebuf2,
                             input-output prodbuf1,
                             input-output prodbuf2).
    end.
    CASE my-Set_Val_Type :
      when 2 then  do:
        if not SHOnly_tot then
        DISPLAY STREAM PrnLibStream
        sj-goods.b-code
        sj-goods.artic
        namebuf1 @ sj-goods.name
        prodbuf1 @ sj-goods.prod-name
        ACCUM SUB-TOTAL BY  ( sj-adv.discnt )  sj-adv.qnty @ sj-adv.qnty
        sj-adv.price
        ACCUM SUB-TOTAL BY  ( sj-adv.discnt )  sj-adv.brutto-sum @ sj-adv.brutto-sum
        ACCUM SUB-TOTAL BY  ( sj-adv.discnt )  sj-adv.discnt-sum @ sj-adv.discnt-sum
        (IF (ACCUM SUB-TOTAL BY  ( sj-adv.discnt )  sj-adv.qnty ) <> 0 THEN
        round( ( ACCUM SUB-TOTAL BY  ( sj-adv.discnt )  sj-adv.discnt-sum ) /
        ( ACCUM SUB-TOTAL BY  ( sj-adv.discnt )  sj-adv.brutto-sum ) *
          100 , 1 )   ELSE 0) @ pcnt
        ACCUM SUB-TOTAL BY  ( sj-adv.discnt )  sj-adv.netto-sum @ sj-adv.netto-sum
        with FRAME sj-base-d .
        if not SHOnly_tot then
        DOWN STREAM PrnLibStream 1 with FRAME sj-base-d .
      end.
      when 3 then do:
        if not SHOnly_tot then
        DISPLAY STREAM PrnLibStream
        sj-goods.b-code
        sj-goods.artic
        namebuf1 @ sj-goods.name
        prodbuf1 @ sj-goods.prod-name
        ACCUM SUB-TOTAL BY  ( sj-adv.discnt  )  sj-adv.qnty @ sj-adv.qnty
        sj-adv.price
        ACCUM SUB-TOTAL BY  ( sj-adv.discnt  )  sj-adv.brutto-sum @
        sj-adv.brutto-sum
        ACCUM SUB-TOTAL BY  ( sj-adv.discnt  )  sj-adv.brutto-sum-r @
        sj-adv.brutto-sum-r
        ACCUM SUB-TOTAL BY  ( sj-adv.discnt )  sj-adv.discnt-sum @
        sj-adv.discnt-sum
        (IF (ACCUM SUB-TOTAL BY  ( sj-adv.discnt  )  sj-adv.qnty) <> 0 THEN
        round( ( ACCUM SUB-TOTAL BY  ( sj-adv.discnt  )  sj-adv.discnt-sum ) /
              ( ACCUM SUB-TOTAL BY  ( sj-adv.discnt  )  sj-adv.brutto-sum ) *
                      100 , 1 )   ELSE 0) @ pcnt
        ACCUM SUB-TOTAL BY  ( sj-adv.discnt  )  sj-adv.netto-sum @ sj-adv.netto-sum
        ACCUM SUB-TOTAL BY  ( sj-adv.discnt  )  sj-adv.netto-sum-r @ sj-adv.netto-sum-r
        with FRAME sj-full-d .
        if not SHOnly_tot then
        DOWN STREAM PrnLibStream 1 with FRAME sj-full-d.
      end.
    END CASE .
    if ( namebuf2 <> "" ) OR ( prodbuf2 <> "" ) then
    CASE my-Set_Val_Type :
      when 2 then  do:
        if not SHOnly_tot then
          DISPLAY STREAM PrnLibStream
          namebuf2 @ sj-goods.name
          prodbuf2 @ sj-goods.prod-name
          with FRAME sj-base-d .
          if not SHOnly_tot then
          DOWN STREAM PrnLibStream 1 with FRAME sj-base-d .
        end.
      when 3 then do:
        if not SHOnly_tot then
        DISPLAY STREAM PrnLibStream
        namebuf2 @ sj-goods.name
        prodbuf2 @ sj-goods.prod-name
        with FRAME sj-full-d .
        if not SHOnly_tot then
        DOWN STREAM PrnLibStream 1 with FRAME sj-full-d .
      end.
    END CASE .
  end.
end.
if SHBySalers AND last-of( sj-goods.saleman-chr ) then do:
  if entry(2, sj-goods.saleman-chr, chr(4)) <> string(0) then do:
    find first buf_saleman where
              buf_saleman.obj-type = 'чел':U
          AND buf_saleman.obj-code = integer(entry(2, sj-goods.saleman-chr, chr(4))) no-error .
    if not available buf_saleman then do:
      v-salesman-name = '':U.
    end.
    else do:
      v-salesman-name = buf_saleman.obj-name.
    end.
  end.
  CASE my-Set_Val_Type :
    when 2 then  do:
      UNDERLINE STREAM PrnLibStream
      sj-goods.b-code
      sj-goods.artic
      sj-goods.name
      sj-adv.qnty
      sj-adv.brutto-sum
      sj-adv.discnt-sum
      pcnt sj-adv.netto-sum
      with FRAME sj-base-d .
      DISPLAY STREAM PrnLibStream
      (if Shrs-seller-cashier = 'Cashier'
      then  substitute("ч-&1", (ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.num-docs))
      else '':U)  @ sj-goods.b-code
      (if Shrs-seller-cashier = 'Cashier'
      then substitute("стр-&1", (ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.num-lines))
      else '':U)  @ sj-goods.artic
      string( v-seller-cashier-1 + entry(1, sj-goods.saleman-chr, chr(4) ) ) @ sj-goods.name
      v-salesman-name @ sj-goods.prod-name
      ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.qnty    @ sj-adv.qnty
      ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.brutto-sum      @ sj-adv.brutto-sum
      ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.discnt-sum      @ sj-adv.discnt-sum
      (IF (ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.qnty) <> 0
      THEN
      round( ( ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.discnt-sum ) /
                  ( ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.brutto-sum) * 100 , 1 )
      ELSE 0) @ pcnt
      ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.netto-sum   @ sj-adv.netto-sum
      with FRAME sj-base-d .
      DOWN STREAM PrnLibStream 1 with FRAME sj-base-d .
    end.
    when 3 then do:
      UNDERLINE STREAM PrnLibStream
      sj-goods.b-code
      sj-goods.artic
      sj-goods.name
      sj-adv.qnty
      sj-adv.brutto-sum
      sj-adv.brutto-sum-r
      sj-adv.discnt-sum
      pcnt
      sj-adv.netto-sum
      sj-adv.netto-sum-r
      with FRAME sj-full-d .
      DISPLAY STREAM PrnLibStream
      (if Shrs-seller-cashier = 'Cashier'
      then substitute("ч-&1", (ACCUM SUB-TOTAL BY (sj-goods.saleman-chr) sj-adv.num-docs))
      else '':U)  @ sj-goods.b-code
      (if Shrs-seller-cashier = 'Cashier'
      then substitute("стр-&1", (ACCUM SUB-TOTAL BY (sj-goods.saleman-chr) sj-adv.num-lines))
      else '':U) @ sj-goods.artic
      string( v-seller-cashier-1 + entry(1, sj-goods.saleman-chr, chr(4) ) ) @ sj-goods.name
      v-salesman-name @ sj-goods.prod-name
      ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.qnty    @ sj-adv.qnty
      ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.brutto-sum  @ sj-adv.brutto-sum
      ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.brutto-sum-r @ sj-adv.brutto-sum-r
      ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.discnt-sum      @ sj-adv.discnt-sum
      (IF (ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.qnty) <> 0 THEN
      round( ( ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.discnt-sum ) /
                  ( ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.brutto-sum) * 100 , 1 )
        ELSE 0) @ pcnt
      ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.netto-sum   @ sj-adv.netto-sum
      ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.netto-sum-r @ sj-adv.netto-sum-r
      with FRAME sj-full-d .
      DOWN STREAM PrnLibStream 1 with FRAME sj-full-d .
    end.
  END CASE .
  if not last(  sj-adv.discnt  ) then
  CASE my-set_Val_Type :
    when 2 then
      UNDERLINE STREAM PrnLibStream
      sj-goods.b-code
      sj-goods.artic
      sj-goods.name
      sj-adv.qnty
      sj-adv.brutto-sum
      sj-adv.discnt-sum
      pcnt
      sj-adv.netto-sum
      with FRAME sj-base-d .
    when 3 then
      UNDERLINE STREAM PrnLibStream
      sj-goods.b-code
      sj-goods.artic
      sj-goods.name
      sj-adv.qnty
      sj-adv.brutto-sum
      sj-adv.brutto-sum-r
      sj-adv.discnt-sum
      pcnt
      sj-adv.netto-sum
      sj-adv.netto-sum-r
      with FRAME sj-full-d .
    END CASE .
    OneLinePrinted = TRUE .
  end.
  if last-of( sj-goods.prod-name ) AND prodtot_flag then do:
    CASE my-Set_Val_Type :
      when 2 then do:
        UNDERLINE STREAM PrnLibStream
        sj-goods.b-code
        sj-goods.artic
        sj-goods.name
        sj-adv.qnty
        sj-adv.brutto-sum
        sj-adv.discnt-sum
        pcnt
        sj-adv.netto-sum
        with FRAME sj-base-d .
        DISPLAY STREAM PrnLibStream
        "Итого по произв-лю"
                                                                          @ sj-goods.name
        ACCUM SUB-TOTAL BY sj-goods.prod-name sj-adv.qnty    @ sj-adv.qnty
        ACCUM SUB-TOTAL BY sj-goods.prod-name sj-adv.brutto-sum      @ sj-adv.brutto-sum
        ACCUM SUB-TOTAL BY sj-goods.prod-name sj-adv.discnt-sum      @ sj-adv.discnt-sum
        (IF (ACCUM SUB-TOTAL BY sj-goods.prod-name sj-adv.qnty) <> 0 THEN
        round( ( ACCUM SUB-TOTAL BY sj-goods.prod-name sj-adv.discnt-sum ) /
                    ( ACCUM SUB-TOTAL BY sj-goods.prod-name sj-adv.brutto-sum) * 100 , 1 )
          ELSE 0) @ pcnt
        ACCUM SUB-TOTAL BY sj-goods.prod-name sj-adv.netto-sum   @ sj-adv.netto-sum
        with FRAME sj-base-d .
        DOWN STREAM PrnLibStream 1 with FRAME sj-base-d .
      end.
      when 3 then do:
        UNDERLINE STREAM PrnLibStream
        sj-goods.b-code
        sj-goods.artic
        sj-goods.name
        sj-adv.qnty
        sj-adv.brutto-sum
        sj-adv.brutto-sum-r
        sj-adv.discnt-sum
        pcnt
        sj-adv.netto-sum
        sj-adv.netto-sum-r
        with FRAME sj-full-d .
        DISPLAY STREAM PrnLibStream
        "Итого по произв-лю"
                                                                          @ sj-goods.name
        ACCUM SUB-TOTAL BY sj-goods.prod-name sj-adv.qnty    @ sj-adv.qnty
        ACCUM SUB-TOTAL BY sj-goods.prod-name sj-adv.brutto-sum  @ sj-adv.brutto-sum
        ACCUM SUB-TOTAL BY sj-goods.prod-name sj-adv.brutto-sum-r @ sj-adv.brutto-sum-r
        ACCUM SUB-TOTAL BY sj-goods.prod-name sj-adv.discnt-sum      @ sj-adv.discnt-sum
        (IF (ACCUM SUB-TOTAL BY sj-goods.prod-name sj-adv.qnty) <> 0 THEN
        round( ( ACCUM SUB-TOTAL BY sj-goods.prod-name sj-adv.discnt-sum ) /
                    ( ACCUM SUB-TOTAL BY sj-goods.prod-name sj-adv.brutto-sum) * 100 , 1 )
          ELSE 0) @ pcnt
        ACCUM SUB-TOTAL BY sj-goods.prod-name sj-adv.netto-sum   @ sj-adv.netto-sum
        ACCUM SUB-TOTAL BY sj-goods.prod-name sj-adv.netto-sum-r @ sj-adv.netto-sum-r
        with FRAME sj-full-d .
        DOWN STREAM PrnLibStream 1 with FRAME sj-full-d .
      end.
    END CASE .
    if not last( sj-adv.discnt ) then
    CASE my-Set_Val_Type :
      when 2 then
        UNDERLINE STREAM PrnLibStream
        sj-goods.b-code
        sj-goods.artic
        sj-goods.name
        sj-adv.qnty
        sj-adv.brutto-sum
        sj-adv.discnt-sum
        pcnt
        sj-adv.netto-sum
        with FRAME sj-base-d .
      when 3 then
        UNDERLINE STREAM PrnLibStream
        sj-goods.b-code
        sj-goods.artic
        sj-goods.name
        sj-adv.qnty
        sj-adv.brutto-sum
        sj-adv.brutto-sum-r
        sj-adv.discnt-sum
        pcnt
        sj-adv.netto-sum
        sj-adv.netto-sum-r
        with FRAME sj-full-d .
      END CASE .
      OneLinePrinted = TRUE .
    end.
  if last-of( sj-goods.grp-name ) AND grouptot_flag then do:
    IF AllObjsTotalsBy  then do:
      FIND FIRST sj-tots WHERE
                 sj-tots.obj-attr = sj-goods.obj-attr AND
                sj-tots.grp-name = sj-goods.grp-name AND
                sj-tots.prod-name = sj-goods.prod-name No-ERROR.
        IF NOT avail sj-tots then do:
          create sj-tots.
          assign
          sj-tots.obj-attr = sj-goods.obj-attr
          sj-tots.grp-name = sj-goods.grp-name
          sj-tots.qnty = ACCUM SUB-TOTAL BY sj-goods.grp-name sj-adv.qnty
          sj-tots.qnty-2 = ACCUM SUB-TOTAL BY sj-goods.grp-name sj-adv.qnty-2
          sj-tots.qnty-3 = ACCUM SUB-TOTAL BY sj-goods.grp-name sj-adv.qnty-3
          sj-tots.discnt-sum  = ACCUM SUB-TOTAL BY sj-goods.grp-name sj-adv.discnt-sum
          sj-tots.brutto-sum  = ACCUM SUB-TOTAL BY sj-goods.grp-name sj-adv.brutto-sum
          sj-tots.netto-sum  = ACCUM SUB-TOTAL BY sj-goods.grp-name sj-adv.netto-sum.
          IF my-Set_Val_Type = 3 then
          assign
          sj-tots.brutto-sum-r  = ACCUM SUB-TOTAL BY sj-goods.grp-name sj-adv.brutto-sum-r
          sj-tots.netto-sum-r  = ACCUM SUB-TOTAL BY sj-goods.grp-name sj-adv.netto-sum-r.
          ACCUMULATE
          sj-tots.discnt-sum ( TOTAL )
          sj-tots.brutto-sum  ( TOTAL )
          sj-tots.netto-sum  ( TOTAL ).
          IF my-set_val_type = 3 then
          ACCUMULATE
          sj-tots.brutto-sum-r  ( TOTAL )
          sj-tots.netto-sum-r  ( TOTAL ).
        end.
      end.
      CASE my-set_val_type :
        when 2 then do:
          UNDERLINE STREAM PrnLibStream
          sj-goods.b-code
          sj-goods.artic
          sj-goods.name
          sj-adv.qnty
          sj-adv.brutto-sum
          sj-adv.discnt-sum
          pcnt
          sj-adv.netto-sum
          with FRAME sj-base-d .
          DISPLAY STREAM PrnLibStream
          "Итого по группе"
                                                                            @ sj-goods.name
          ACCUM SUB-TOTAL BY sj-goods.grp-name sj-adv.qnty    @ sj-adv.qnty
          ACCUM SUB-TOTAL BY sj-goods.grp-name sj-adv.brutto-sum      @ sj-adv.brutto-sum
          ACCUM SUB-TOTAL BY sj-goods.grp-name sj-adv.discnt-sum      @ sj-adv.discnt-sum
          (IF (ACCUM SUB-TOTAL BY sj-goods.grp-name sj-adv.qnty) <> 0 THEN
          round( ( ACCUM SUB-TOTAL BY sj-goods.grp-name sj-adv.discnt-sum ) /
                      ( ACCUM SUB-TOTAL BY sj-goods.grp-name sj-adv.brutto-sum) * 100 , 1 )
            ELSE 0) @ pcnt
          ACCUM SUB-TOTAL BY sj-goods.grp-name sj-adv.netto-sum   @ sj-adv.netto-sum
          with FRAME sj-base-d .
          DOWN STREAM PrnLibStream 1 with FRAME sj-base-d .
        end.
        when 3 then do:
          UNDERLINE STREAM PrnLibStream
          sj-goods.b-code
          sj-goods.artic
          sj-goods.name
          sj-adv.qnty
          sj-adv.brutto-sum
          sj-adv.brutto-sum-r
          sj-adv.discnt-sum
          pcnt
          sj-adv.netto-sum
          sj-adv.netto-sum-r
          with FRAME sj-full-d .
          DISPLAY STREAM PrnLibStream
          "Итого по группе"
          @ sj-goods.name
          ACCUM SUB-TOTAL BY sj-goods.grp-name sj-adv.qnty    @ sj-adv.qnty
          ACCUM SUB-TOTAL BY sj-goods.grp-name sj-adv.brutto-sum  @ sj-adv.brutto-sum
          ACCUM SUB-TOTAL BY sj-goods.grp-name sj-adv.brutto-sum-r @ sj-adv.brutto-sum-r
          ACCUM SUB-TOTAL BY sj-goods.grp-name sj-adv.discnt-sum      @ sj-adv.discnt-sum
          (IF (ACCUM SUB-TOTAL BY sj-goods.grp-name sj-adv.qnty) <> 0 THEN
          round( ( ACCUM SUB-TOTAL BY sj-goods.grp-name sj-adv.discnt-sum ) /
                 ( ACCUM SUB-TOTAL BY sj-goods.grp-name sj-adv.brutto-sum) * 100 , 1 )
          ELSE 0) @ pcnt
          ACCUM SUB-TOTAL BY sj-goods.grp-name sj-adv.netto-sum   @ sj-adv.netto-sum
          ACCUM SUB-TOTAL BY sj-goods.grp-name sj-adv.netto-sum-r @ sj-adv.netto-sum-r
          with FRAME sj-full-d .
          DOWN STREAM PrnLibStream 1 with FRAME sj-full-d .
        end.
      END CASE .
      if not last(  sj-adv.discnt   ) then
      CASE my-set_val_type :
        when 2 then
          UNDERLINE STREAM PrnLibStream
          sj-goods.b-code
          sj-goods.artic
          sj-goods.name
          sj-adv.qnty
          sj-adv.brutto-sum
          sj-adv.discnt-sum
          pcnt
          sj-adv.netto-sum
          with FRAME sj-base-d .
        when 3 then
          UNDERLINE STREAM PrnLibStream
          sj-goods.b-code
          sj-goods.artic
          sj-goods.name
          sj-adv.qnty
          sj-adv.brutto-sum
          sj-adv.brutto-sum-r
          sj-adv.discnt-sum
          pcnt
          sj-adv.netto-sum
          sj-adv.netto-sum-r
          with FRAME sj-full-d .
      END CASE .
      OneLinePrinted = TRUE .
    end.
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
    if last-of( sj-goods.obj-attr ) AND ( ObjsQnty > 1 ) then do:
            CASE my-set_val_type :
                when 2 then do:
                        UNDERLINE STREAM PrnLibStream
                        sj-goods.name
                        sj-adv.qnty
                        sj-adv.brutto-sum
                        sj-adv.discnt-sum
                        pcnt
                        sj-adv.netto-sum
                        with FRAME sj-base .
                        DISPLAY STREAM PrnLibStream
                        string( "Итого " + sj-goods.obj-attr )
                            @ sj-goods.name
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.qnty    @ sj-adv.qnty
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.brutto-sum
                            @ sj-adv.brutto-sum
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.discnt-sum
                            @ sj-adv.discnt-sum
                        round( ( ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.discnt-sum ) /
                            ( ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.brutto-sum ) * 100 , 1 )
                            @ pcnt
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.netto-sum
                            @ sj-adv.netto-sum
                        with FRAME sj-base .
                        DOWN STREAM PrnLibStream 1 with FRAME sj-base .
                    end.
                when 3 then do:
                        UNDERLINE STREAM PrnLibStream
                        sj-goods.name
                        sj-adv.qnty
                        sj-adv.brutto-sum
                        sj-adv.brutto-sum-r
                        sj-adv.discnt-sum
                        pcnt
                        sj-adv.netto-sum
                        sj-adv.netto-sum-r
                        with FRAME sj-full .
                        DISPLAY STREAM PrnLibStream
                        string( "Итого " + sj-goods.obj-attr )
                            @ sj-goods.name
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.qnty    @ sj-adv.qnty
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.brutto-sum  @ sj-adv.brutto-sum
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.brutto-sum-r @ sj-adv.brutto-sum-r
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.discnt-sum      @ sj-adv.discnt-sum
                        round( ( ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.discnt-sum ) /
                                    ( ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.brutto-sum) * 100 , 1 )
                                        @ pcnt
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.netto-sum   @ sj-adv.netto-sum
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.netto-sum-r @ sj-adv.netto-sum-r
                        with FRAME sj-full .
                        DOWN STREAM PrnLibStream 1 with FRAME sj-full .
                    end.
            END CASE .
            if NOT last(  sj-adv.price ) then
                CASE my-set_val_type :
                    when 2 then
                        UNDERLINE STREAM PrnLibStream
                        sj-goods.name
                        sj-adv.qnty
                        sj-adv.brutto-sum
                        sj-adv.discnt-sum
                        pcnt
                        sj-adv.netto-sum
                        with FRAME sj-base .
                    when 3 then
                        UNDERLINE STREAM PrnLibStream
                        sj-goods.name
                        sj-adv.qnty
                        sj-adv.brutto-sum
                        sj-adv.brutto-sum-r
                        sj-adv.discnt-sum
                        pcnt
                        sj-adv.netto-sum
                        sj-adv.netto-sum-r
                        with FRAME sj-full .
                END CASE .
            OneLinePrinted = TRUE .
        end.
    if last( sj-adv.discnt    ) then do:
      IF AllObjsTotalsBy then do:
        PUT STREAM PrnLibStream string( "   ПО ВСЕМ ОБЪЕКТАМ " +
           "ПО ГРУППАМ:"
           )
        format "x(120)" SKIP .
        for each sj-tots NO-LOCK BREAK BY sj-tots.grp-name:
          ACCUMULATE
          sj-tots.qnty   (TOTAL BY sj-tots.grp-name)
          sj-tots.qnty-2   (TOTAL BY sj-tots.grp-name)
          sj-tots.qnty-3   (TOTAL BY sj-tots.grp-name)
          sj-tots.brutto-sum  (TOTAL BY sj-tots.grp-name)
          sj-tots.discnt-sum  (TOTAL BY sj-tots.grp-name)
          sj-tots.netto-sum   (TOTAL BY sj-tots.grp-name).
          if my-set_val_type = 3  then
          ACCUMULATE
          sj-tots.brutto-sum-r (TOTAL BY sj-tots.grp-name)
          sj-tots.netto-sum-r (TOTAL BY sj-tots.grp-name).
          IF LAST-OF(sj-tots.grp-name) then do:
          CASE my-set_val_type :
            when 2 then do:
              UNDERLINE STREAM PrnLibStream
              sj-goods.b-code
              sj-goods.artic
              sj-goods.name
              sj-adv.qnty
              sj-adv.brutto-sum
              sj-adv.discnt-sum
              pcnt
              sj-adv.netto-sum
              with FRAME sj-base-d .
              DISPLAY STREAM PrnLibStream
              get-grp-name(sj-tots.grp-name)  @ sj-goods.name
              ACCUM TOTAL BY sj-tots.grp-name sj-tots.qnty    @ sj-adv.qnty
              ACCUM TOTAL BY sj-tots.grp-name sj-tots.brutto-sum      @ sj-adv.brutto-sum
              ACCUM TOTAL BY sj-tots.grp-name sj-tots.discnt-sum      @ sj-adv.discnt-sum
              round( ( ACCUM TOTAL BY sj-tots.grp-name sj-tots.discnt-sum ) /
                     ( ACCUM TOTAL BY sj-tots.grp-name sj-tots.brutto-sum) * 100 , 1 )
                              @ pcnt
              ACCUM TOTAL BY sj-tots.grp-name sj-tots.netto-sum   @ sj-adv.netto-sum
              with FRAME sj-base-d .
              DOWN STREAM PrnLibStream 1 with FRAME sj-base-d .
            end.
            when 3 then do:
              UNDERLINE STREAM PrnLibStream
              sj-goods.b-code
              sj-goods.artic
              sj-goods.name
              sj-adv.qnty
              sj-adv.brutto-sum
              sj-adv.brutto-sum-r
              sj-adv.discnt-sum
              pcnt
              sj-adv.netto-sum
              sj-adv.netto-sum-r
              with FRAME sj-full-d .
              DISPLAY STREAM PrnLibStream
              get-grp-name(sj-tots.grp-name) @ sj-goods.name
              ACCUM TOTAL BY sj-tots.grp-name sj-tots.qnty    @ sj-adv.qnty
              ACCUM TOTAL BY sj-tots.grp-name sj-tots.brutto-sum  @ sj-adv.brutto-sum
              ACCUM TOTAL BY sj-tots.grp-name sj-tots.brutto-sum-r @ sj-adv.brutto-sum-r
              ACCUM TOTAL BY sj-tots.grp-name sj-tots.discnt-sum      @ sj-adv.discnt-sum
              round( ( ACCUM TOTAL BY sj-tots.grp-name sj-tots.discnt-sum ) /
                          ( ACCUM TOTAL BY sj-tots.grp-name sj-tots.brutto-sum) * 100 , 1 )
                              @ pcnt
              ACCUM TOTAL BY sj-tots.grp-name sj-tots.netto-sum   @ sj-adv.netto-sum
              ACCUM TOTAL BY sj-tots.grp-name sj-tots.netto-sum-r @ sj-adv.netto-sum-r
              with FRAME sj-full-d .
              DOWN STREAM PrnLibStream 1 with FRAME sj-full-d .
            end.
          END CASE .
        end.
      END.
    end.
    if ( line-counter(PrnLibStream) + 7 ) > page-size(PrnLibStream) then page stream PrnLibStream.
    CASE my-set_val_type :
      when 2 then do:
        if OneLinePrinted then
        PUT STREAM PrnLibStream  LINE format ("X(" + string(198) + ")") SKIP.
        DISPLAY STREAM PrnLibStream
        substitute("ИТОГО ч- &1", v-num-chk) @ sj-goods.name
        ACCUM TOTAL sj-adv.qnty @ sj-adv.qnty
        ACCUM TOTAL sj-adv.brutto-sum @ sj-adv.brutto-sum
        ACCUM TOTAL sj-adv.discnt-sum @ sj-adv.discnt-sum
        (IF (ACCUM TOTAL sj-adv.qnty) <> 0 THEN
        round( ( ACCUM TOTAL sj-adv.discnt-sum ) /
                    ( ACCUM TOTAL sj-adv.brutto-sum ) * 100 , 1 ) ELSE 0) @ pcnt
        ACCUM TOTAL sj-adv.netto-sum @ sj-adv.netto-sum
            with FRAME sj-base-d .
        DOWN STREAM PrnLibStream 1 with FRAME sj-base-d .
        DISPLAY STREAM PrnLibStream
        (string(round((ACCUM TOTAL sj-adv.qnty) / v-num-chk, 2)) + "/ч")  @ sj-adv.qnty
        with FRAME sj-base-d .
        DOWN STREAM PrnLibStream 1 with FRAME sj-base-d .
        UNDERLINE STREAM PrnLibStream
        sj-goods.b-code
        sj-goods.artic
        sj-goods.name
        sj-adv.qnty
        sj-adv.brutto-sum
        sj-adv.discnt-sum
        pcnt
        sj-adv.netto-sum
        with FRAME sj-base-d .
      end.
      when 3 then do:
        if OneLinePrinted then
        PUT STREAM PrnLibStream LINE  SKIP.
        DISPLAY STREAM PrnLibStream
        substitute("ИТОГО ч- &1", v-num-chk) @ sj-goods.name
        ACCUM TOTAL sj-adv.qnty @ sj-adv.qnty
        ACCUM TOTAL sj-adv.brutto-sum @ sj-adv.brutto-sum
        ACCUM TOTAL sj-adv.brutto-sum-r @ sj-adv.brutto-sum-r
        ACCUM TOTAL sj-adv.discnt-sum @ sj-adv.discnt-sum
        (IF (ACCUM TOTAL sj-adv.qnty) <> 0 THEN
        round( ( ACCUM TOTAL sj-adv.discnt-sum ) /
                    ( ACCUM TOTAL sj-adv.brutto-sum ) * 100 , 1 ) ELSE 0) @ pcnt
        ACCUM TOTAL sj-adv.netto-sum @ sj-adv.netto-sum
        ACCUM TOTAL sj-adv.netto-sum-r @ sj-adv.netto-sum-r
        with FRAME sj-full-d .
        DOWN STREAM PrnLibStream 1 with FRAME sj-full-d .
        DISPLAY STREAM PrnLibStream
        (string(round((ACCUM TOTAL sj-adv.qnty) / v-num-chk, 2)) + "/ч") @ sj-adv.qnty
        with FRAME sj-full-d .
        DOWN STREAM PrnLibStream 1 with FRAME sj-full-d .
        UNDERLINE STREAM PrnLibStream
        sj-goods.b-code
        sj-goods.artic
        sj-goods.name
        sj-adv.qnty
        sj-adv.brutto-sum
        sj-adv.brutto-sum-r
        sj-adv.discnt-sum pcnt
        sj-adv.netto-sum
        sj-adv.netto-sum-r
        with FRAME sj-full-d .
      end.
    END CASE .
    if ObjsQnty = 1 then
    PUT STREAM PrnLibStream
    " " SKIP(1) space(10)
    "Директор ______________" format "X(50)"
    "Кассир ___________________" format "X(50)" SKIP .
  end.
      END .
    end.
  end.
END CASE .
HIDE STREAM PrnLibStream FRAME BottomFramesj-base-d .
if Print-List-hist
and x-SelectGood = 4 then do:
  run lhistprex-print-gds-list-hist-excel  in this-procedure (input yes, input no, 2).
end.
ENd procedure.
PROCEDURE ProdGrpProc_d.
define variable v-salesman-name as character no-undo .
define buffer buf_saleman for ub.clients.
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if SHRS-Sort = "Article":U then do:
  FOR EACH sj-goods NO-LOCK,
    EACH sj-adv NO-LOCK WHERE
         sj-adv.obj-attr = sj-goods.obj-attr AND
         sj-adv.b-code = sj-goods.b-code AND
         sj-adv.saleman-chr = sj-goods.saleman-chr
    BREAK BY sj-goods.obj-attr
          BY sj-goods.prod-name
          BY sj-goods.grp-name
          BY sj-goods.saleman-chr
          BY sj-goods.artic
          BY sj-goods.b-code
          BY sj-adv.price
          BY sj-adv.discnt
          :
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if first( sj-goods.obj-attr ) then do:
  if v-curr-r-b = 'base':U then do:
                        if my-set_val_type = 2  then
                            DOWN STREAM PrnLibStream 1 with FRAME sj-base-d .
                        else
                            DOWN STREAM PrnLibStream 1 with FRAME sj-full-d .
  end.
  else do:
                            DOWN STREAM PrnLibStream 1 with FRAME sj-base-d .
  end.
end.
                if first-of( sj-goods.obj-attr ) AND ( ObjsQnty > 1 ) then  do:
                        assign
                        strbuf1 = substr( sj-goods.obj-attr, 1, 3 )
                        intbuf1 = integer( substr( sj-goods.obj-attr, 4 ) ) .
                        FIND FIRST cli-obj WHERE
                                   cli-obj.obj-type = strbuf1 AND
                                   cli-obj.obj-code = intbuf1 NO-LOCK .
                        PUT STREAM PrnLibStream
                        cli-obj.obj-name format "x(120)" SKIP.
if v-curr-r-b = 'base':U then do:
                        if my-set_val_type = 2  then
                        UNDERLINE STREAM PrnLibStream
                        sj-goods.artic
                        sj-goods.name
                        with FRAME sj-base-d .
                        else
                        UNDERLINE STREAM PrnLibStream
                        sj-goods.artic
                        sj-goods.name
                        with FRAME sj-full-d .
end.
else do:
                        UNDERLINE STREAM PrnLibStream
                        sj-goods.artic
                        sj-goods.name
                        with FRAME sj-base-d .
end.
                    end.
  if first-of( sj-goods.prod-name ) then do:
    if v-curr-r-b = 'base':U then do:
      if my-set_Val_Type = 2 then do:
        if frame sj-base-d:line = 0 then do:
           down 1 stream PrnLibStream
           with frame sj-base-d .
        end.
      end.
      else do:
        if frame sj-full-d:line = 0 then do:
           down 1 stream PrnLibStream
           with frame sj-full-d .
        end.
      end.
      PUT STREAM PrnLibStream string( "   ПРОИЗВОДИТЕЛЬ : " + sj-goods.prod-name ) format "x(120)" SKIP.
      if my-set_Val_Type = 2 then do:
        UNDERLINE STREAM PrnLibStream
        sj-goods.artic
        sj-goods.name
        with FRAME sj-base-d .
      end.
      else do:
        UNDERLINE STREAM PrnLibStream
        sj-goods.artic
        sj-goods.name
        with FRAME sj-full-d .
       end.
     end.
     else do:
        if frame sj-base-d:line = 0 then do:
           down 1 stream PrnLibStream
           with frame sj-base-d .
        end.
        PUT STREAM PrnLibStream string( "   ПРОИЗВОДИТЕЛЬ : " + sj-goods.prod-name ) format "x(120)" SKIP.
        UNDERLINE STREAM PrnLibStream
        sj-goods.artic
        sj-goods.name
       with FRAME sj-base-d .
     end.
   end.
   if first-of( sj-goods.grp-name ) then do:
     if grouptot_flag OR NOT SHOnly_tot then do:
       if v-curr-r-b = 'base':U then do:
          if my-set_Val_Type = 2 then do:
            if frame sj-base-d:line = 0 then do:
              down 1 stream PrnLibStream
              with frame sj-base-d .
            end.
          end.
          else do:
            if frame sj-full-d:line = 0 then do:
              down 1 stream PrnLibStream
              with frame sj-full-d .
            end.
          end.
         PUT STREAM PrnLibStream string( "   ГРУППА : " + get-grp-name(sj-goods.grp-name) ) format "x(120)" SKIP.
         if my-Set_Val_Type = 2 then do:
            UNDERLINE STREAM PrnLibStream
            sj-goods.artic
            sj-goods.name
            with FRAME sj-base-d .
          end.
          else do:
            UNDERLINE STREAM PrnLibStream
            sj-goods.artic
            sj-goods.name
            with FRAME sj-full-d .
          end.
        end.
        else do:
          if frame sj-base-d:line = 0 then do:
            down 1 stream PrnLibStream
            with frame sj-base-d .
          end.
          PUT STREAM PrnLibStream string( "   ГРУППА : " + get-grp-name(sj-goods.grp-name) ) format "x(120)" SKIP.
          UNDERLINE STREAM PrnLibStream
          sj-goods.artic
          sj-goods.name
          with FRAME sj-base-d .
        end.
      end.
    end.
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile: e-sjprod.i $ $Revision: aea5316774be, 0, rls $".
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
    ACCUMULATE
    sj-adv.qnty (TOTAL)
    sj-adv.qnty-2 (TOTAL)
    sj-adv.qnty-3 (TOTAL)
    sj-adv.brutto-sum (TOTAL)
    sj-adv.discnt-sum (TOTAL)
    sj-adv.netto-sum (TOTAL)
    sj-adv.brutto-sum-r (TOTAL)
    sj-adv.netto-sum-r (TOTAL)
    sj-adv.num-lines (TOTAL)
    sj-adv.num-docs (TOTAL)
    sj-adv.qnty ( SUB-TOTAL BY sj-goods.obj-attr )
    sj-adv.qnty-2 ( SUB-TOTAL BY sj-goods.obj-attr )
    sj-adv.qnty-3 ( SUB-TOTAL BY sj-goods.obj-attr )
    sj-adv.brutto-sum ( SUB-TOTAL BY sj-goods.obj-attr )
    sj-adv.discnt-sum ( SUB-TOTAL BY sj-goods.obj-attr )
    sj-adv.netto-sum ( SUB-TOTAL BY sj-goods.obj-attr )
    sj-adv.brutto-sum-r ( SUB-TOTAL BY sj-goods.obj-attr )
    sj-adv.netto-sum-r ( SUB-TOTAL BY sj-goods.obj-attr )
    sj-adv.qnty  (SUB-TOTAL BY ( sj-adv.discnt  ))
    sj-adv.qnty-2 (SUB-TOTAL BY ( sj-adv.discnt  ))
    sj-adv.qnty-3 (SUB-TOTAL BY ( sj-adv.discnt  ))
    sj-adv.brutto-sum  (SUB-TOTAL BY (  sj-adv.discnt  ))
    sj-adv.discnt-sum  (SUB-TOTAL BY ( sj-adv.discnt  ))
    sj-adv.netto-sum  (SUB-TOTAL BY (  sj-adv.discnt  ) )
    sj-adv.brutto-sum-r  (SUB-TOTAL BY (  sj-adv.discnt  ))
    sj-adv.netto-sum-r  (SUB-TOTAL BY (  sj-adv.discnt  ) )
    sj-adv.num-lines ( SUB-TOTAL BY (  sj-adv.discnt  ))
    sj-adv.num-docs (SUB-TOTAL BY (  sj-adv.discnt  ))
    sj-adv.qnty (SUB-TOTAL BY sj-goods.grp-name)
    sj-adv.qnty-2 (SUB-TOTAL BY sj-goods.grp-name)
    sj-adv.qnty-3 (SUB-TOTAL BY sj-goods.grp-name)
    sj-adv.brutto-sum (SUB-TOTAL BY sj-goods.grp-name)
    sj-adv.discnt-sum (SUB-TOTAL BY sj-goods.grp-name)
    sj-adv.netto-sum (SUB-TOTAL BY sj-goods.grp-name)
    sj-adv.brutto-sum-r (SUB-TOTAL BY sj-goods.grp-name)
    sj-adv.netto-sum-r (SUB-TOTAL BY sj-goods.grp-name)
    sj-adv.qnty (SUB-TOTAL BY sj-goods.prod-name)
    sj-adv.qnty-2 (SUB-TOTAL BY sj-goods.prod-name)
    sj-adv.qnty-3 (SUB-TOTAL BY sj-goods.prod-name)
    sj-adv.brutto-sum (SUB-TOTAL BY sj-goods.prod-name)
    sj-adv.discnt-sum (SUB-TOTAL BY sj-goods.prod-name)
    sj-adv.netto-sum (SUB-TOTAL BY sj-goods.prod-name)
    sj-adv.brutto-sum-r (SUB-TOTAL BY sj-goods.prod-name)
    sj-adv.netto-sum-r (SUB-TOTAL BY sj-goods.prod-name)
    sj-adv.qnty (SUB-TOTAL BY sj-goods.saleman-chr)
    sj-adv.qnty-2 (SUB-TOTAL BY sj-goods.saleman-chr)
    sj-adv.qnty-3 (SUB-TOTAL BY sj-goods.saleman-chr)
    sj-adv.brutto-sum (SUB-TOTAL BY sj-goods.saleman-chr)
    sj-adv.discnt-sum (SUB-TOTAL BY sj-goods.saleman-chr)
    sj-adv.netto-sum (SUB-TOTAL BY sj-goods.saleman-chr)
    sj-adv.brutto-sum-r (SUB-TOTAL BY sj-goods.saleman-chr)
    sj-adv.netto-sum-r (SUB-TOTAL BY sj-goods.saleman-chr)
    sj-adv.num-lines ( SUB-TOTAL BY sj-goods.saleman-chr )
    sj-adv.num-docs ( SUB-TOTAL BY sj-goods.saleman-chr )
    .
if sj-goods.twounit = 0 then do:
  if last-of (sj-adv.discnt) then  do:
    if not SHOnly_tot then do:
      namebuf1 = get-strokes(buffer sj-goods, 18, 21,
                             input-output namebuf1,
                             input-output namebuf2,
                             input-output prodbuf1,
                             input-output prodbuf2).
    end.
    CASE my-Set_Val_Type :
      when 2 then  do:
        if not SHOnly_tot then
        DISPLAY STREAM PrnLibStream
        sj-goods.b-code
        sj-goods.artic
        namebuf1 @ sj-goods.name
        prodbuf1 @ sj-goods.prod-name
        ACCUM SUB-TOTAL BY  ( sj-adv.discnt )  sj-adv.qnty @ sj-adv.qnty
        sj-adv.price
        ACCUM SUB-TOTAL BY  ( sj-adv.discnt )  sj-adv.brutto-sum @ sj-adv.brutto-sum
        ACCUM SUB-TOTAL BY  ( sj-adv.discnt )  sj-adv.discnt-sum @ sj-adv.discnt-sum
        (IF (ACCUM SUB-TOTAL BY  ( sj-adv.discnt )  sj-adv.qnty ) <> 0 THEN
        round( ( ACCUM SUB-TOTAL BY  ( sj-adv.discnt )  sj-adv.discnt-sum ) /
        ( ACCUM SUB-TOTAL BY  ( sj-adv.discnt )  sj-adv.brutto-sum ) *
          100 , 1 )   ELSE 0) @ pcnt
        ACCUM SUB-TOTAL BY  ( sj-adv.discnt )  sj-adv.netto-sum @ sj-adv.netto-sum
        with FRAME sj-base-d .
        if not SHOnly_tot then
        DOWN STREAM PrnLibStream 1 with FRAME sj-base-d .
      end.
      when 3 then do:
        if not SHOnly_tot then
        DISPLAY STREAM PrnLibStream
        sj-goods.b-code
        sj-goods.artic
        namebuf1 @ sj-goods.name
        prodbuf1 @ sj-goods.prod-name
        ACCUM SUB-TOTAL BY  ( sj-adv.discnt  )  sj-adv.qnty @ sj-adv.qnty
        sj-adv.price
        ACCUM SUB-TOTAL BY  ( sj-adv.discnt  )  sj-adv.brutto-sum @
        sj-adv.brutto-sum
        ACCUM SUB-TOTAL BY  ( sj-adv.discnt  )  sj-adv.brutto-sum-r @
        sj-adv.brutto-sum-r
        ACCUM SUB-TOTAL BY  ( sj-adv.discnt )  sj-adv.discnt-sum @
        sj-adv.discnt-sum
        (IF (ACCUM SUB-TOTAL BY  ( sj-adv.discnt  )  sj-adv.qnty) <> 0 THEN
        round( ( ACCUM SUB-TOTAL BY  ( sj-adv.discnt  )  sj-adv.discnt-sum ) /
              ( ACCUM SUB-TOTAL BY  ( sj-adv.discnt  )  sj-adv.brutto-sum ) *
                      100 , 1 )   ELSE 0) @ pcnt
        ACCUM SUB-TOTAL BY  ( sj-adv.discnt  )  sj-adv.netto-sum @ sj-adv.netto-sum
        ACCUM SUB-TOTAL BY  ( sj-adv.discnt  )  sj-adv.netto-sum-r @ sj-adv.netto-sum-r
        with FRAME sj-full-d .
        if not SHOnly_tot then
        DOWN STREAM PrnLibStream 1 with FRAME sj-full-d.
      end.
    END CASE .
    if ( namebuf2 <> "" ) OR ( prodbuf2 <> "" ) then
    CASE my-Set_Val_Type :
      when 2 then  do:
        if not SHOnly_tot then
          DISPLAY STREAM PrnLibStream
          namebuf2 @ sj-goods.name
          prodbuf2 @ sj-goods.prod-name
          with FRAME sj-base-d .
          if not SHOnly_tot then
          DOWN STREAM PrnLibStream 1 with FRAME sj-base-d .
        end.
      when 3 then do:
        if not SHOnly_tot then
        DISPLAY STREAM PrnLibStream
        namebuf2 @ sj-goods.name
        prodbuf2 @ sj-goods.prod-name
        with FRAME sj-full-d .
        if not SHOnly_tot then
        DOWN STREAM PrnLibStream 1 with FRAME sj-full-d .
      end.
    END CASE .
  end.
end.
if SHBySalers AND last-of( sj-goods.saleman-chr ) then do:
  if entry(2, sj-goods.saleman-chr, chr(4)) <> string(0) then do:
    find first buf_saleman where
              buf_saleman.obj-type = 'чел':U
          AND buf_saleman.obj-code = integer(entry(2, sj-goods.saleman-chr, chr(4))) no-error .
    if not available buf_saleman then do:
      v-salesman-name = '':U.
    end.
    else do:
      v-salesman-name = buf_saleman.obj-name.
    end.
  end.
  CASE my-Set_Val_Type :
    when 2 then  do:
      UNDERLINE STREAM PrnLibStream
      sj-goods.b-code
      sj-goods.artic
      sj-goods.name
      sj-adv.qnty
      sj-adv.brutto-sum
      sj-adv.discnt-sum
      pcnt sj-adv.netto-sum
      with FRAME sj-base-d .
      DISPLAY STREAM PrnLibStream
      (if Shrs-seller-cashier = 'Cashier'
      then  substitute("ч-&1", (ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.num-docs))
      else '':U)  @ sj-goods.b-code
      (if Shrs-seller-cashier = 'Cashier'
      then substitute("стр-&1", (ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.num-lines))
      else '':U)  @ sj-goods.artic
      string( v-seller-cashier-1 + entry(1, sj-goods.saleman-chr, chr(4) ) ) @ sj-goods.name
      v-salesman-name @ sj-goods.prod-name
      ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.qnty    @ sj-adv.qnty
      ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.brutto-sum      @ sj-adv.brutto-sum
      ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.discnt-sum      @ sj-adv.discnt-sum
      (IF (ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.qnty) <> 0
      THEN
      round( ( ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.discnt-sum ) /
                  ( ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.brutto-sum) * 100 , 1 )
      ELSE 0) @ pcnt
      ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.netto-sum   @ sj-adv.netto-sum
      with FRAME sj-base-d .
      DOWN STREAM PrnLibStream 1 with FRAME sj-base-d .
    end.
    when 3 then do:
      UNDERLINE STREAM PrnLibStream
      sj-goods.b-code
      sj-goods.artic
      sj-goods.name
      sj-adv.qnty
      sj-adv.brutto-sum
      sj-adv.brutto-sum-r
      sj-adv.discnt-sum
      pcnt
      sj-adv.netto-sum
      sj-adv.netto-sum-r
      with FRAME sj-full-d .
      DISPLAY STREAM PrnLibStream
      (if Shrs-seller-cashier = 'Cashier'
      then substitute("ч-&1", (ACCUM SUB-TOTAL BY (sj-goods.saleman-chr) sj-adv.num-docs))
      else '':U)  @ sj-goods.b-code
      (if Shrs-seller-cashier = 'Cashier'
      then substitute("стр-&1", (ACCUM SUB-TOTAL BY (sj-goods.saleman-chr) sj-adv.num-lines))
      else '':U) @ sj-goods.artic
      string( v-seller-cashier-1 + entry(1, sj-goods.saleman-chr, chr(4) ) ) @ sj-goods.name
      v-salesman-name @ sj-goods.prod-name
      ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.qnty    @ sj-adv.qnty
      ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.brutto-sum  @ sj-adv.brutto-sum
      ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.brutto-sum-r @ sj-adv.brutto-sum-r
      ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.discnt-sum      @ sj-adv.discnt-sum
      (IF (ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.qnty) <> 0 THEN
      round( ( ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.discnt-sum ) /
                  ( ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.brutto-sum) * 100 , 1 )
        ELSE 0) @ pcnt
      ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.netto-sum   @ sj-adv.netto-sum
      ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.netto-sum-r @ sj-adv.netto-sum-r
      with FRAME sj-full-d .
      DOWN STREAM PrnLibStream 1 with FRAME sj-full-d .
    end.
  END CASE .
  if not last(  sj-adv.discnt  ) then
  CASE my-set_Val_Type :
    when 2 then
      UNDERLINE STREAM PrnLibStream
      sj-goods.b-code
      sj-goods.artic
      sj-goods.name
      sj-adv.qnty
      sj-adv.brutto-sum
      sj-adv.discnt-sum
      pcnt
      sj-adv.netto-sum
      with FRAME sj-base-d .
    when 3 then
      UNDERLINE STREAM PrnLibStream
      sj-goods.b-code
      sj-goods.artic
      sj-goods.name
      sj-adv.qnty
      sj-adv.brutto-sum
      sj-adv.brutto-sum-r
      sj-adv.discnt-sum
      pcnt
      sj-adv.netto-sum
      sj-adv.netto-sum-r
      with FRAME sj-full-d .
    END CASE .
    OneLinePrinted = TRUE .
  end.
  if last-of( sj-goods.grp-name ) AND grouptot_flag then do:
    CASE my-Set_Val_Type :
      when 2 then do:
        UNDERLINE STREAM PrnLibStream
        sj-goods.b-code
        sj-goods.artic
        sj-goods.name
        sj-adv.qnty
        sj-adv.brutto-sum
        sj-adv.discnt-sum
        pcnt
        sj-adv.netto-sum
        with FRAME sj-base-d .
        DISPLAY STREAM PrnLibStream
        "Итого по группе"
                                                                          @ sj-goods.name
        ACCUM SUB-TOTAL BY sj-goods.grp-name sj-adv.qnty    @ sj-adv.qnty
        ACCUM SUB-TOTAL BY sj-goods.grp-name sj-adv.brutto-sum      @ sj-adv.brutto-sum
        ACCUM SUB-TOTAL BY sj-goods.grp-name sj-adv.discnt-sum      @ sj-adv.discnt-sum
        (IF (ACCUM SUB-TOTAL BY sj-goods.grp-name sj-adv.qnty) <> 0 THEN
        round( ( ACCUM SUB-TOTAL BY sj-goods.grp-name sj-adv.discnt-sum ) /
                    ( ACCUM SUB-TOTAL BY sj-goods.grp-name sj-adv.brutto-sum) * 100 , 1 )
          ELSE 0) @ pcnt
        ACCUM SUB-TOTAL BY sj-goods.grp-name sj-adv.netto-sum   @ sj-adv.netto-sum
        with FRAME sj-base-d .
        DOWN STREAM PrnLibStream 1 with FRAME sj-base-d .
      end.
      when 3 then do:
        UNDERLINE STREAM PrnLibStream
        sj-goods.b-code
        sj-goods.artic
        sj-goods.name
        sj-adv.qnty
        sj-adv.brutto-sum
        sj-adv.brutto-sum-r
        sj-adv.discnt-sum
        pcnt
        sj-adv.netto-sum
        sj-adv.netto-sum-r
        with FRAME sj-full-d .
        DISPLAY STREAM PrnLibStream
        "Итого по группе"
                                                                          @ sj-goods.name
        ACCUM SUB-TOTAL BY sj-goods.grp-name sj-adv.qnty    @ sj-adv.qnty
        ACCUM SUB-TOTAL BY sj-goods.grp-name sj-adv.brutto-sum  @ sj-adv.brutto-sum
        ACCUM SUB-TOTAL BY sj-goods.grp-name sj-adv.brutto-sum-r @ sj-adv.brutto-sum-r
        ACCUM SUB-TOTAL BY sj-goods.grp-name sj-adv.discnt-sum      @ sj-adv.discnt-sum
        (IF (ACCUM SUB-TOTAL BY sj-goods.grp-name sj-adv.qnty) <> 0 THEN
        round( ( ACCUM SUB-TOTAL BY sj-goods.grp-name sj-adv.discnt-sum ) /
                    ( ACCUM SUB-TOTAL BY sj-goods.grp-name sj-adv.brutto-sum) * 100 , 1 )
          ELSE 0) @ pcnt
        ACCUM SUB-TOTAL BY sj-goods.grp-name sj-adv.netto-sum   @ sj-adv.netto-sum
        ACCUM SUB-TOTAL BY sj-goods.grp-name sj-adv.netto-sum-r @ sj-adv.netto-sum-r
        with FRAME sj-full-d .
        DOWN STREAM PrnLibStream 1 with FRAME sj-full-d .
      end.
    END CASE .
    if not last( sj-adv.discnt ) then
    CASE my-Set_Val_Type :
      when 2 then
        UNDERLINE STREAM PrnLibStream
        sj-goods.b-code
        sj-goods.artic
        sj-goods.name
        sj-adv.qnty
        sj-adv.brutto-sum
        sj-adv.discnt-sum
        pcnt
        sj-adv.netto-sum
        with FRAME sj-base-d .
      when 3 then
        UNDERLINE STREAM PrnLibStream
        sj-goods.b-code
        sj-goods.artic
        sj-goods.name
        sj-adv.qnty
        sj-adv.brutto-sum
        sj-adv.brutto-sum-r
        sj-adv.discnt-sum
        pcnt
        sj-adv.netto-sum
        sj-adv.netto-sum-r
        with FRAME sj-full-d .
      END CASE .
      OneLinePrinted = TRUE .
    end.
  if last-of( sj-goods.prod-name ) AND prodtot_flag then do:
    IF AllObjsTotalsBy  then do:
      FIND FIRST sj-tots WHERE
                 sj-tots.obj-attr = sj-goods.obj-attr AND
                sj-tots.grp-name = sj-goods.grp-name AND
                sj-tots.prod-name = sj-goods.prod-name No-ERROR.
        IF NOT avail sj-tots then do:
          create sj-tots.
          assign
          sj-tots.obj-attr = sj-goods.obj-attr
          sj-tots.prod-name = sj-goods.prod-name
          sj-tots.qnty = ACCUM SUB-TOTAL BY sj-goods.prod-name sj-adv.qnty
          sj-tots.qnty-2 = ACCUM SUB-TOTAL BY sj-goods.prod-name sj-adv.qnty-2
          sj-tots.qnty-3 = ACCUM SUB-TOTAL BY sj-goods.prod-name sj-adv.qnty-3
          sj-tots.discnt-sum  = ACCUM SUB-TOTAL BY sj-goods.prod-name sj-adv.discnt-sum
          sj-tots.brutto-sum  = ACCUM SUB-TOTAL BY sj-goods.prod-name sj-adv.brutto-sum
          sj-tots.netto-sum  = ACCUM SUB-TOTAL BY sj-goods.prod-name sj-adv.netto-sum.
          IF my-Set_Val_Type = 3 then
          assign
          sj-tots.brutto-sum-r  = ACCUM SUB-TOTAL BY sj-goods.prod-name sj-adv.brutto-sum-r
          sj-tots.netto-sum-r  = ACCUM SUB-TOTAL BY sj-goods.prod-name sj-adv.netto-sum-r.
          ACCUMULATE
          sj-tots.discnt-sum ( TOTAL )
          sj-tots.brutto-sum  ( TOTAL )
          sj-tots.netto-sum  ( TOTAL ).
          IF my-set_val_type = 3 then
          ACCUMULATE
          sj-tots.brutto-sum-r  ( TOTAL )
          sj-tots.netto-sum-r  ( TOTAL ).
        end.
      end.
      CASE my-set_val_type :
        when 2 then do:
          UNDERLINE STREAM PrnLibStream
          sj-goods.b-code
          sj-goods.artic
          sj-goods.name
          sj-adv.qnty
          sj-adv.brutto-sum
          sj-adv.discnt-sum
          pcnt
          sj-adv.netto-sum
          with FRAME sj-base-d .
          DISPLAY STREAM PrnLibStream
          "Итого по произв-лю"
                                                                            @ sj-goods.name
          ACCUM SUB-TOTAL BY sj-goods.prod-name sj-adv.qnty    @ sj-adv.qnty
          ACCUM SUB-TOTAL BY sj-goods.prod-name sj-adv.brutto-sum      @ sj-adv.brutto-sum
          ACCUM SUB-TOTAL BY sj-goods.prod-name sj-adv.discnt-sum      @ sj-adv.discnt-sum
          (IF (ACCUM SUB-TOTAL BY sj-goods.prod-name sj-adv.qnty) <> 0 THEN
          round( ( ACCUM SUB-TOTAL BY sj-goods.prod-name sj-adv.discnt-sum ) /
                      ( ACCUM SUB-TOTAL BY sj-goods.prod-name sj-adv.brutto-sum) * 100 , 1 )
            ELSE 0) @ pcnt
          ACCUM SUB-TOTAL BY sj-goods.prod-name sj-adv.netto-sum   @ sj-adv.netto-sum
          with FRAME sj-base-d .
          DOWN STREAM PrnLibStream 1 with FRAME sj-base-d .
        end.
        when 3 then do:
          UNDERLINE STREAM PrnLibStream
          sj-goods.b-code
          sj-goods.artic
          sj-goods.name
          sj-adv.qnty
          sj-adv.brutto-sum
          sj-adv.brutto-sum-r
          sj-adv.discnt-sum
          pcnt
          sj-adv.netto-sum
          sj-adv.netto-sum-r
          with FRAME sj-full-d .
          DISPLAY STREAM PrnLibStream
          "Итого по произв-лю"
          @ sj-goods.name
          ACCUM SUB-TOTAL BY sj-goods.prod-name sj-adv.qnty    @ sj-adv.qnty
          ACCUM SUB-TOTAL BY sj-goods.prod-name sj-adv.brutto-sum  @ sj-adv.brutto-sum
          ACCUM SUB-TOTAL BY sj-goods.prod-name sj-adv.brutto-sum-r @ sj-adv.brutto-sum-r
          ACCUM SUB-TOTAL BY sj-goods.prod-name sj-adv.discnt-sum      @ sj-adv.discnt-sum
          (IF (ACCUM SUB-TOTAL BY sj-goods.prod-name sj-adv.qnty) <> 0 THEN
          round( ( ACCUM SUB-TOTAL BY sj-goods.prod-name sj-adv.discnt-sum ) /
                 ( ACCUM SUB-TOTAL BY sj-goods.prod-name sj-adv.brutto-sum) * 100 , 1 )
          ELSE 0) @ pcnt
          ACCUM SUB-TOTAL BY sj-goods.prod-name sj-adv.netto-sum   @ sj-adv.netto-sum
          ACCUM SUB-TOTAL BY sj-goods.prod-name sj-adv.netto-sum-r @ sj-adv.netto-sum-r
          with FRAME sj-full-d .
          DOWN STREAM PrnLibStream 1 with FRAME sj-full-d .
        end.
      END CASE .
      if not last(  sj-adv.discnt   ) then
      CASE my-set_val_type :
        when 2 then
          UNDERLINE STREAM PrnLibStream
          sj-goods.b-code
          sj-goods.artic
          sj-goods.name
          sj-adv.qnty
          sj-adv.brutto-sum
          sj-adv.discnt-sum
          pcnt
          sj-adv.netto-sum
          with FRAME sj-base-d .
        when 3 then
          UNDERLINE STREAM PrnLibStream
          sj-goods.b-code
          sj-goods.artic
          sj-goods.name
          sj-adv.qnty
          sj-adv.brutto-sum
          sj-adv.brutto-sum-r
          sj-adv.discnt-sum
          pcnt
          sj-adv.netto-sum
          sj-adv.netto-sum-r
          with FRAME sj-full-d .
      END CASE .
      OneLinePrinted = TRUE .
    end.
define variable vss-include-info39 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
    if last-of( sj-goods.obj-attr ) AND ( ObjsQnty > 1 ) then do:
            CASE my-set_val_type :
                when 2 then do:
                        UNDERLINE STREAM PrnLibStream
                        sj-goods.name
                        sj-adv.qnty
                        sj-adv.brutto-sum
                        sj-adv.discnt-sum
                        pcnt
                        sj-adv.netto-sum
                        with FRAME sj-base .
                        DISPLAY STREAM PrnLibStream
                        string( "Итого " + sj-goods.obj-attr )
                            @ sj-goods.name
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.qnty    @ sj-adv.qnty
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.brutto-sum
                            @ sj-adv.brutto-sum
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.discnt-sum
                            @ sj-adv.discnt-sum
                        round( ( ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.discnt-sum ) /
                            ( ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.brutto-sum ) * 100 , 1 )
                            @ pcnt
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.netto-sum
                            @ sj-adv.netto-sum
                        with FRAME sj-base .
                        DOWN STREAM PrnLibStream 1 with FRAME sj-base .
                    end.
                when 3 then do:
                        UNDERLINE STREAM PrnLibStream
                        sj-goods.name
                        sj-adv.qnty
                        sj-adv.brutto-sum
                        sj-adv.brutto-sum-r
                        sj-adv.discnt-sum
                        pcnt
                        sj-adv.netto-sum
                        sj-adv.netto-sum-r
                        with FRAME sj-full .
                        DISPLAY STREAM PrnLibStream
                        string( "Итого " + sj-goods.obj-attr )
                            @ sj-goods.name
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.qnty    @ sj-adv.qnty
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.brutto-sum  @ sj-adv.brutto-sum
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.brutto-sum-r @ sj-adv.brutto-sum-r
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.discnt-sum      @ sj-adv.discnt-sum
                        round( ( ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.discnt-sum ) /
                                    ( ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.brutto-sum) * 100 , 1 )
                                        @ pcnt
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.netto-sum   @ sj-adv.netto-sum
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.netto-sum-r @ sj-adv.netto-sum-r
                        with FRAME sj-full .
                        DOWN STREAM PrnLibStream 1 with FRAME sj-full .
                    end.
            END CASE .
            if NOT last(  sj-adv.price ) then
                CASE my-set_val_type :
                    when 2 then
                        UNDERLINE STREAM PrnLibStream
                        sj-goods.name
                        sj-adv.qnty
                        sj-adv.brutto-sum
                        sj-adv.discnt-sum
                        pcnt
                        sj-adv.netto-sum
                        with FRAME sj-base .
                    when 3 then
                        UNDERLINE STREAM PrnLibStream
                        sj-goods.name
                        sj-adv.qnty
                        sj-adv.brutto-sum
                        sj-adv.brutto-sum-r
                        sj-adv.discnt-sum
                        pcnt
                        sj-adv.netto-sum
                        sj-adv.netto-sum-r
                        with FRAME sj-full .
                END CASE .
            OneLinePrinted = TRUE .
        end.
    if last( sj-adv.discnt    ) then do:
      IF AllObjsTotalsBy then do:
        PUT STREAM PrnLibStream string( "   ПО ВСЕМ ОБЪЕКТАМ " +
           "ПО ПРОИЗВОДИТЕЛЯМ:"
           )
        format "x(120)" SKIP .
        for each sj-tots NO-LOCK BREAK BY sj-tots.prod-name:
          ACCUMULATE
          sj-tots.qnty   (TOTAL BY sj-tots.prod-name)
          sj-tots.qnty-2   (TOTAL BY sj-tots.prod-name)
          sj-tots.qnty-3   (TOTAL BY sj-tots.prod-name)
          sj-tots.brutto-sum  (TOTAL BY sj-tots.prod-name)
          sj-tots.discnt-sum  (TOTAL BY sj-tots.prod-name)
          sj-tots.netto-sum   (TOTAL BY sj-tots.prod-name).
          if my-set_val_type = 3  then
          ACCUMULATE
          sj-tots.brutto-sum-r (TOTAL BY sj-tots.prod-name)
          sj-tots.netto-sum-r (TOTAL BY sj-tots.prod-name).
          IF LAST-OF(sj-tots.prod-name) then do:
            CASE my-set_val_type :
              when 2 then do:
                UNDERLINE STREAM PrnLibStream
                sj-goods.b-code
                sj-goods.artic
                sj-goods.name
                sj-adv.qnty
                sj-adv.brutto-sum
                sj-adv.discnt-sum
                pcnt
                sj-adv.netto-sum
                with FRAME sj-base-d .
                DISPLAY STREAM PrnLibStream
                sj-tots.prod-name  @ sj-goods.name
                ACCUM TOTAL BY sj-tots.prod-name sj-tots.qnty    @ sj-adv.qnty
                ACCUM TOTAL BY sj-tots.prod-name sj-tots.brutto-sum      @ sj-adv.brutto-sum
                ACCUM TOTAL BY sj-tots.prod-name sj-tots.discnt-sum      @ sj-adv.discnt-sum
                round( ( ACCUM TOTAL BY sj-tots.prod-name sj-tots.discnt-sum ) /
                       ( ACCUM TOTAL BY sj-tots.prod-name sj-tots.brutto-sum) * 100 , 1 )
                                @ pcnt
                ACCUM TOTAL BY sj-tots.prod-name sj-tots.netto-sum   @ sj-adv.netto-sum
                with FRAME sj-base-d .
                DOWN STREAM PrnLibStream 1 with FRAME sj-base-d .
              end.
              when 3 then do:
                UNDERLINE STREAM PrnLibStream
                sj-goods.b-code
                sj-goods.artic
                sj-goods.name
                sj-adv.qnty
                sj-adv.brutto-sum
                sj-adv.brutto-sum-r
                sj-adv.discnt-sum
                pcnt
                sj-adv.netto-sum
                sj-adv.netto-sum-r
                with FRAME sj-full-d .
                DISPLAY STREAM PrnLibStream
                sj-tots.prod-name @ sj-goods.name
                ACCUM TOTAL BY sj-tots.prod-name sj-tots.qnty    @ sj-adv.qnty
                ACCUM TOTAL BY sj-tots.prod-name sj-tots.brutto-sum  @ sj-adv.brutto-sum
                ACCUM TOTAL BY sj-tots.prod-name sj-tots.brutto-sum-r @ sj-adv.brutto-sum-r
                ACCUM TOTAL BY sj-tots.prod-name sj-tots.discnt-sum      @ sj-adv.discnt-sum
                round( ( ACCUM TOTAL BY sj-tots.prod-name sj-tots.discnt-sum ) /
                            ( ACCUM TOTAL BY sj-tots.prod-name sj-tots.brutto-sum) * 100 , 1 )
                                @ pcnt
                ACCUM TOTAL BY sj-tots.prod-name sj-tots.netto-sum   @ sj-adv.netto-sum
                ACCUM TOTAL BY sj-tots.prod-name sj-tots.netto-sum-r @ sj-adv.netto-sum-r
                with FRAME sj-full-d .
                DOWN STREAM PrnLibStream 1 with FRAME sj-full-d .
              end.
            END CASE .
          end.
        END.
    end.
    if ( line-counter(PrnLibStream) + 7 ) > page-size(PrnLibStream) then page stream PrnLibStream.
    CASE my-set_val_type :
      when 2 then do:
        if OneLinePrinted then
        PUT STREAM PrnLibStream  LINE format ("X(" + string(198) + ")") SKIP.
        DISPLAY STREAM PrnLibStream
        substitute("ИТОГО ч- &1", v-num-chk) @ sj-goods.name
        ACCUM TOTAL sj-adv.qnty @ sj-adv.qnty
        ACCUM TOTAL sj-adv.brutto-sum @ sj-adv.brutto-sum
        ACCUM TOTAL sj-adv.discnt-sum @ sj-adv.discnt-sum
        (IF (ACCUM TOTAL sj-adv.qnty) <> 0 THEN
        round( ( ACCUM TOTAL sj-adv.discnt-sum ) /
                    ( ACCUM TOTAL sj-adv.brutto-sum ) * 100 , 1 ) ELSE 0) @ pcnt
        ACCUM TOTAL sj-adv.netto-sum @ sj-adv.netto-sum
            with FRAME sj-base-d .
        DOWN STREAM PrnLibStream 1 with FRAME sj-base-d .
        DISPLAY STREAM PrnLibStream
        (string(round((ACCUM TOTAL sj-adv.qnty) / v-num-chk, 2)) + "/ч")  @ sj-adv.qnty
        with FRAME sj-base-d .
        DOWN STREAM PrnLibStream 1 with FRAME sj-base-d .
        UNDERLINE STREAM PrnLibStream
        sj-goods.b-code
        sj-goods.artic
        sj-goods.name
        sj-adv.qnty
        sj-adv.brutto-sum
        sj-adv.discnt-sum
        pcnt
        sj-adv.netto-sum
        with FRAME sj-base-d .
      end.
      when 3 then do:
        if OneLinePrinted then
        PUT STREAM PrnLibStream LINE  SKIP.
        DISPLAY STREAM PrnLibStream
        substitute("ИТОГО ч- &1", v-num-chk) @ sj-goods.name
        ACCUM TOTAL sj-adv.qnty @ sj-adv.qnty
        ACCUM TOTAL sj-adv.brutto-sum @ sj-adv.brutto-sum
        ACCUM TOTAL sj-adv.brutto-sum-r @ sj-adv.brutto-sum-r
        ACCUM TOTAL sj-adv.discnt-sum @ sj-adv.discnt-sum
        (IF (ACCUM TOTAL sj-adv.qnty) <> 0 THEN
        round( ( ACCUM TOTAL sj-adv.discnt-sum ) /
                    ( ACCUM TOTAL sj-adv.brutto-sum ) * 100 , 1 ) ELSE 0) @ pcnt
        ACCUM TOTAL sj-adv.netto-sum @ sj-adv.netto-sum
        ACCUM TOTAL sj-adv.netto-sum-r @ sj-adv.netto-sum-r
        with FRAME sj-full-d .
        DOWN STREAM PrnLibStream 1 with FRAME sj-full-d .
        DISPLAY STREAM PrnLibStream
        (string(round((ACCUM TOTAL sj-adv.qnty) / v-num-chk, 2)) + "/ч") @ sj-adv.qnty
        with FRAME sj-full-d .
        DOWN STREAM PrnLibStream 1 with FRAME sj-full-d .
        UNDERLINE STREAM PrnLibStream
        sj-goods.b-code
        sj-goods.artic
        sj-goods.name
        sj-adv.qnty
        sj-adv.brutto-sum
        sj-adv.brutto-sum-r
        sj-adv.discnt-sum pcnt
        sj-adv.netto-sum
        sj-adv.netto-sum-r
        with FRAME sj-full-d .
      end.
    END CASE .
    if ObjsQnty = 1 then
    PUT STREAM PrnLibStream
    " " SKIP(1) space(10)
    "Директор ______________" format "X(50)"
    "Кассир ___________________" format "X(50)" SKIP .
  end.
  END.
end.
else do:
  FOR EACH sj-goods NO-LOCK,
      EACH sj-adv NO-LOCK WHERE
            sj-adv.obj-attr = sj-goods.obj-attr AND
            sj-adv.b-code = sj-goods.b-code AND
            sj-adv.saleman-chr = sj-goods.saleman-chr
      BREAK
      BY sj-goods.obj-attr
      BY sj-goods.prod-name
      BY sj-goods.grp-name
      BY sj-goods.saleman-chr
      BY sj-goods.b-code
      BY sj-adv.price
      BY sj-adv.discnt
  :
define variable vss-include-info40 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if first( sj-goods.obj-attr ) then do:
  if v-curr-r-b = 'base':U then do:
                        if my-set_val_type = 2  then
                            DOWN STREAM PrnLibStream 1 with FRAME sj-base-d .
                        else
                            DOWN STREAM PrnLibStream 1 with FRAME sj-full-d .
  end.
  else do:
                            DOWN STREAM PrnLibStream 1 with FRAME sj-base-d .
  end.
end.
                if first-of( sj-goods.obj-attr ) AND ( ObjsQnty > 1 ) then  do:
                        assign
                        strbuf1 = substr( sj-goods.obj-attr, 1, 3 )
                        intbuf1 = integer( substr( sj-goods.obj-attr, 4 ) ) .
                        FIND FIRST cli-obj WHERE
                                   cli-obj.obj-type = strbuf1 AND
                                   cli-obj.obj-code = intbuf1 NO-LOCK .
                        PUT STREAM PrnLibStream
                        cli-obj.obj-name format "x(120)" SKIP.
if v-curr-r-b = 'base':U then do:
                        if my-set_val_type = 2  then
                        UNDERLINE STREAM PrnLibStream
                        sj-goods.artic
                        sj-goods.name
                        with FRAME sj-base-d .
                        else
                        UNDERLINE STREAM PrnLibStream
                        sj-goods.artic
                        sj-goods.name
                        with FRAME sj-full-d .
end.
else do:
                        UNDERLINE STREAM PrnLibStream
                        sj-goods.artic
                        sj-goods.name
                        with FRAME sj-base-d .
end.
                    end.
    if first-of( sj-goods.prod-name ) then do:
      format "x(120)" SKIP .
      if v-curr-r-b = 'base':U then do:
        if my-set_Val_Type = 2 then do:
          if frame sj-base-d:line = 0 then do:
            down 1 stream PrnLibStream
            with frame sj-base-d .
          end.
        end.
        else do:
          if frame sj-full-d:line = 0 then do:
            down 1 stream PrnLibStream
            with frame sj-full-d .
          end.
        end.
        PUT STREAM PrnLibStream string( "   ПРОИЗВОДИТЕЛЬ : " + sj-goods.prod-name ) format "x(120)" skip.
        if my-Set_Val_Type = 2 then do:
          UNDERLINE STREAM PrnLibStream
          sj-goods.artic
          sj-goods.name
          with FRAME sj-base-d .
        end.
        else do:
          UNDERLINE STREAM PrnLibStream
          sj-goods.artic
          sj-goods.name
          with FRAME sj-full-d .
        end.
      end.
      else do:
        if frame sj-base-d:line = 0 then do:
           down 1 stream PrnLibStream
           with frame sj-base-d .
        end.
        PUT STREAM PrnLibStream string( "   ПРОИЗВОДИТЕЛЬ : " + sj-goods.prod-name ) format "x(120)" skip.
        UNDERLINE STREAM PrnLibStream
        sj-goods.artic
        sj-goods.name
        with FRAME sj-base-d .
      end.
    end.
    if first-of( sj-goods.grp-name ) then do:
      if grouptot_flag OR NOT SHOnly_tot then do:
        if v-curr-r-b = 'base':U then do:
          if my-set_Val_Type = 2 then do:
            if frame sj-base-d:line = 0 then do:
              down 1 stream PrnLibStream
              with frame sj-base-d .
            end.
          end.
          else do:
            if frame sj-full-d:line = 0 then do:
              down 1 stream PrnLibStream
              with frame sj-full-d .
            end.
          end.
          PUT STREAM PrnLibStream
          string( "   ГРУППА : " + get-grp-name(sj-goods.grp-name) ) format "x(120)" SKIP.
          if my-Set_Val_Type = 2 then do:
            UNDERLINE STREAM PrnLibStream
            sj-goods.artic
            sj-goods.name
            with FRAME sj-base-d .
          end.
          else do:
            UNDERLINE STREAM PrnLibStream
            sj-goods.artic
            sj-goods.name
            with FRAME sj-full-d .
          end.
        end.
        else do:
          if frame sj-base-d:line = 0 then do:
            down 1 stream PrnLibStream
            with frame sj-base-d .
          end.
          PUT STREAM PrnLibStream
          string( "   ГРУППА : " + get-grp-name(sj-goods.grp-name) ) format "x(120)" SKIP.
          UNDERLINE STREAM PrnLibStream
          sj-goods.artic
          sj-goods.name
          with FRAME sj-base-d .
        end.
      end.
    end.
define variable vss-include-info41 as character format "x(65)" no-undo initial "@(#)$Workfile: e-sjprod.i $ $Revision: aea5316774be, 0, rls $".
define variable vss-include-info42 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
    ACCUMULATE
    sj-adv.qnty (TOTAL)
    sj-adv.qnty-2 (TOTAL)
    sj-adv.qnty-3 (TOTAL)
    sj-adv.brutto-sum (TOTAL)
    sj-adv.discnt-sum (TOTAL)
    sj-adv.netto-sum (TOTAL)
    sj-adv.brutto-sum-r (TOTAL)
    sj-adv.netto-sum-r (TOTAL)
    sj-adv.num-lines (TOTAL)
    sj-adv.num-docs (TOTAL)
    sj-adv.qnty ( SUB-TOTAL BY sj-goods.obj-attr )
    sj-adv.qnty-2 ( SUB-TOTAL BY sj-goods.obj-attr )
    sj-adv.qnty-3 ( SUB-TOTAL BY sj-goods.obj-attr )
    sj-adv.brutto-sum ( SUB-TOTAL BY sj-goods.obj-attr )
    sj-adv.discnt-sum ( SUB-TOTAL BY sj-goods.obj-attr )
    sj-adv.netto-sum ( SUB-TOTAL BY sj-goods.obj-attr )
    sj-adv.brutto-sum-r ( SUB-TOTAL BY sj-goods.obj-attr )
    sj-adv.netto-sum-r ( SUB-TOTAL BY sj-goods.obj-attr )
    sj-adv.qnty  (SUB-TOTAL BY ( sj-adv.discnt  ))
    sj-adv.qnty-2 (SUB-TOTAL BY ( sj-adv.discnt  ))
    sj-adv.qnty-3 (SUB-TOTAL BY ( sj-adv.discnt  ))
    sj-adv.brutto-sum  (SUB-TOTAL BY (  sj-adv.discnt  ))
    sj-adv.discnt-sum  (SUB-TOTAL BY ( sj-adv.discnt  ))
    sj-adv.netto-sum  (SUB-TOTAL BY (  sj-adv.discnt  ) )
    sj-adv.brutto-sum-r  (SUB-TOTAL BY (  sj-adv.discnt  ))
    sj-adv.netto-sum-r  (SUB-TOTAL BY (  sj-adv.discnt  ) )
    sj-adv.num-lines ( SUB-TOTAL BY (  sj-adv.discnt  ))
    sj-adv.num-docs (SUB-TOTAL BY (  sj-adv.discnt  ))
    sj-adv.qnty (SUB-TOTAL BY sj-goods.grp-name)
    sj-adv.qnty-2 (SUB-TOTAL BY sj-goods.grp-name)
    sj-adv.qnty-3 (SUB-TOTAL BY sj-goods.grp-name)
    sj-adv.brutto-sum (SUB-TOTAL BY sj-goods.grp-name)
    sj-adv.discnt-sum (SUB-TOTAL BY sj-goods.grp-name)
    sj-adv.netto-sum (SUB-TOTAL BY sj-goods.grp-name)
    sj-adv.brutto-sum-r (SUB-TOTAL BY sj-goods.grp-name)
    sj-adv.netto-sum-r (SUB-TOTAL BY sj-goods.grp-name)
    sj-adv.qnty (SUB-TOTAL BY sj-goods.prod-name)
    sj-adv.qnty-2 (SUB-TOTAL BY sj-goods.prod-name)
    sj-adv.qnty-3 (SUB-TOTAL BY sj-goods.prod-name)
    sj-adv.brutto-sum (SUB-TOTAL BY sj-goods.prod-name)
    sj-adv.discnt-sum (SUB-TOTAL BY sj-goods.prod-name)
    sj-adv.netto-sum (SUB-TOTAL BY sj-goods.prod-name)
    sj-adv.brutto-sum-r (SUB-TOTAL BY sj-goods.prod-name)
    sj-adv.netto-sum-r (SUB-TOTAL BY sj-goods.prod-name)
    sj-adv.qnty (SUB-TOTAL BY sj-goods.saleman-chr)
    sj-adv.qnty-2 (SUB-TOTAL BY sj-goods.saleman-chr)
    sj-adv.qnty-3 (SUB-TOTAL BY sj-goods.saleman-chr)
    sj-adv.brutto-sum (SUB-TOTAL BY sj-goods.saleman-chr)
    sj-adv.discnt-sum (SUB-TOTAL BY sj-goods.saleman-chr)
    sj-adv.netto-sum (SUB-TOTAL BY sj-goods.saleman-chr)
    sj-adv.brutto-sum-r (SUB-TOTAL BY sj-goods.saleman-chr)
    sj-adv.netto-sum-r (SUB-TOTAL BY sj-goods.saleman-chr)
    sj-adv.num-lines ( SUB-TOTAL BY sj-goods.saleman-chr )
    sj-adv.num-docs ( SUB-TOTAL BY sj-goods.saleman-chr )
    .
if sj-goods.twounit = 0 then do:
  if last-of (sj-adv.discnt) then  do:
    if not SHOnly_tot then do:
      namebuf1 = get-strokes(buffer sj-goods, 18, 21,
                             input-output namebuf1,
                             input-output namebuf2,
                             input-output prodbuf1,
                             input-output prodbuf2).
    end.
    CASE my-Set_Val_Type :
      when 2 then  do:
        if not SHOnly_tot then
        DISPLAY STREAM PrnLibStream
        sj-goods.b-code
        sj-goods.artic
        namebuf1 @ sj-goods.name
        prodbuf1 @ sj-goods.prod-name
        ACCUM SUB-TOTAL BY  ( sj-adv.discnt )  sj-adv.qnty @ sj-adv.qnty
        sj-adv.price
        ACCUM SUB-TOTAL BY  ( sj-adv.discnt )  sj-adv.brutto-sum @ sj-adv.brutto-sum
        ACCUM SUB-TOTAL BY  ( sj-adv.discnt )  sj-adv.discnt-sum @ sj-adv.discnt-sum
        (IF (ACCUM SUB-TOTAL BY  ( sj-adv.discnt )  sj-adv.qnty ) <> 0 THEN
        round( ( ACCUM SUB-TOTAL BY  ( sj-adv.discnt )  sj-adv.discnt-sum ) /
        ( ACCUM SUB-TOTAL BY  ( sj-adv.discnt )  sj-adv.brutto-sum ) *
          100 , 1 )   ELSE 0) @ pcnt
        ACCUM SUB-TOTAL BY  ( sj-adv.discnt )  sj-adv.netto-sum @ sj-adv.netto-sum
        with FRAME sj-base-d .
        if not SHOnly_tot then
        DOWN STREAM PrnLibStream 1 with FRAME sj-base-d .
      end.
      when 3 then do:
        if not SHOnly_tot then
        DISPLAY STREAM PrnLibStream
        sj-goods.b-code
        sj-goods.artic
        namebuf1 @ sj-goods.name
        prodbuf1 @ sj-goods.prod-name
        ACCUM SUB-TOTAL BY  ( sj-adv.discnt  )  sj-adv.qnty @ sj-adv.qnty
        sj-adv.price
        ACCUM SUB-TOTAL BY  ( sj-adv.discnt  )  sj-adv.brutto-sum @
        sj-adv.brutto-sum
        ACCUM SUB-TOTAL BY  ( sj-adv.discnt  )  sj-adv.brutto-sum-r @
        sj-adv.brutto-sum-r
        ACCUM SUB-TOTAL BY  ( sj-adv.discnt )  sj-adv.discnt-sum @
        sj-adv.discnt-sum
        (IF (ACCUM SUB-TOTAL BY  ( sj-adv.discnt  )  sj-adv.qnty) <> 0 THEN
        round( ( ACCUM SUB-TOTAL BY  ( sj-adv.discnt  )  sj-adv.discnt-sum ) /
              ( ACCUM SUB-TOTAL BY  ( sj-adv.discnt  )  sj-adv.brutto-sum ) *
                      100 , 1 )   ELSE 0) @ pcnt
        ACCUM SUB-TOTAL BY  ( sj-adv.discnt  )  sj-adv.netto-sum @ sj-adv.netto-sum
        ACCUM SUB-TOTAL BY  ( sj-adv.discnt  )  sj-adv.netto-sum-r @ sj-adv.netto-sum-r
        with FRAME sj-full-d .
        if not SHOnly_tot then
        DOWN STREAM PrnLibStream 1 with FRAME sj-full-d.
      end.
    END CASE .
    if ( namebuf2 <> "" ) OR ( prodbuf2 <> "" ) then
    CASE my-Set_Val_Type :
      when 2 then  do:
        if not SHOnly_tot then
          DISPLAY STREAM PrnLibStream
          namebuf2 @ sj-goods.name
          prodbuf2 @ sj-goods.prod-name
          with FRAME sj-base-d .
          if not SHOnly_tot then
          DOWN STREAM PrnLibStream 1 with FRAME sj-base-d .
        end.
      when 3 then do:
        if not SHOnly_tot then
        DISPLAY STREAM PrnLibStream
        namebuf2 @ sj-goods.name
        prodbuf2 @ sj-goods.prod-name
        with FRAME sj-full-d .
        if not SHOnly_tot then
        DOWN STREAM PrnLibStream 1 with FRAME sj-full-d .
      end.
    END CASE .
  end.
end.
if SHBySalers AND last-of( sj-goods.saleman-chr ) then do:
  if entry(2, sj-goods.saleman-chr, chr(4)) <> string(0) then do:
    find first buf_saleman where
              buf_saleman.obj-type = 'чел':U
          AND buf_saleman.obj-code = integer(entry(2, sj-goods.saleman-chr, chr(4))) no-error .
    if not available buf_saleman then do:
      v-salesman-name = '':U.
    end.
    else do:
      v-salesman-name = buf_saleman.obj-name.
    end.
  end.
  CASE my-Set_Val_Type :
    when 2 then  do:
      UNDERLINE STREAM PrnLibStream
      sj-goods.b-code
      sj-goods.artic
      sj-goods.name
      sj-adv.qnty
      sj-adv.brutto-sum
      sj-adv.discnt-sum
      pcnt sj-adv.netto-sum
      with FRAME sj-base-d .
      DISPLAY STREAM PrnLibStream
      (if Shrs-seller-cashier = 'Cashier'
      then  substitute("ч-&1", (ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.num-docs))
      else '':U)  @ sj-goods.b-code
      (if Shrs-seller-cashier = 'Cashier'
      then substitute("стр-&1", (ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.num-lines))
      else '':U)  @ sj-goods.artic
      string( v-seller-cashier-1 + entry(1, sj-goods.saleman-chr, chr(4) ) ) @ sj-goods.name
      v-salesman-name @ sj-goods.prod-name
      ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.qnty    @ sj-adv.qnty
      ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.brutto-sum      @ sj-adv.brutto-sum
      ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.discnt-sum      @ sj-adv.discnt-sum
      (IF (ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.qnty) <> 0
      THEN
      round( ( ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.discnt-sum ) /
                  ( ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.brutto-sum) * 100 , 1 )
      ELSE 0) @ pcnt
      ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.netto-sum   @ sj-adv.netto-sum
      with FRAME sj-base-d .
      DOWN STREAM PrnLibStream 1 with FRAME sj-base-d .
    end.
    when 3 then do:
      UNDERLINE STREAM PrnLibStream
      sj-goods.b-code
      sj-goods.artic
      sj-goods.name
      sj-adv.qnty
      sj-adv.brutto-sum
      sj-adv.brutto-sum-r
      sj-adv.discnt-sum
      pcnt
      sj-adv.netto-sum
      sj-adv.netto-sum-r
      with FRAME sj-full-d .
      DISPLAY STREAM PrnLibStream
      (if Shrs-seller-cashier = 'Cashier'
      then substitute("ч-&1", (ACCUM SUB-TOTAL BY (sj-goods.saleman-chr) sj-adv.num-docs))
      else '':U)  @ sj-goods.b-code
      (if Shrs-seller-cashier = 'Cashier'
      then substitute("стр-&1", (ACCUM SUB-TOTAL BY (sj-goods.saleman-chr) sj-adv.num-lines))
      else '':U) @ sj-goods.artic
      string( v-seller-cashier-1 + entry(1, sj-goods.saleman-chr, chr(4) ) ) @ sj-goods.name
      v-salesman-name @ sj-goods.prod-name
      ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.qnty    @ sj-adv.qnty
      ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.brutto-sum  @ sj-adv.brutto-sum
      ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.brutto-sum-r @ sj-adv.brutto-sum-r
      ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.discnt-sum      @ sj-adv.discnt-sum
      (IF (ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.qnty) <> 0 THEN
      round( ( ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.discnt-sum ) /
                  ( ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.brutto-sum) * 100 , 1 )
        ELSE 0) @ pcnt
      ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.netto-sum   @ sj-adv.netto-sum
      ACCUM SUB-TOTAL BY sj-goods.saleman-chr sj-adv.netto-sum-r @ sj-adv.netto-sum-r
      with FRAME sj-full-d .
      DOWN STREAM PrnLibStream 1 with FRAME sj-full-d .
    end.
  END CASE .
  if not last(  sj-adv.discnt  ) then
  CASE my-set_Val_Type :
    when 2 then
      UNDERLINE STREAM PrnLibStream
      sj-goods.b-code
      sj-goods.artic
      sj-goods.name
      sj-adv.qnty
      sj-adv.brutto-sum
      sj-adv.discnt-sum
      pcnt
      sj-adv.netto-sum
      with FRAME sj-base-d .
    when 3 then
      UNDERLINE STREAM PrnLibStream
      sj-goods.b-code
      sj-goods.artic
      sj-goods.name
      sj-adv.qnty
      sj-adv.brutto-sum
      sj-adv.brutto-sum-r
      sj-adv.discnt-sum
      pcnt
      sj-adv.netto-sum
      sj-adv.netto-sum-r
      with FRAME sj-full-d .
    END CASE .
    OneLinePrinted = TRUE .
  end.
  if last-of( sj-goods.grp-name ) AND grouptot_flag then do:
    CASE my-Set_Val_Type :
      when 2 then do:
        UNDERLINE STREAM PrnLibStream
        sj-goods.b-code
        sj-goods.artic
        sj-goods.name
        sj-adv.qnty
        sj-adv.brutto-sum
        sj-adv.discnt-sum
        pcnt
        sj-adv.netto-sum
        with FRAME sj-base-d .
        DISPLAY STREAM PrnLibStream
        "Итого по группе"
                                                                          @ sj-goods.name
        ACCUM SUB-TOTAL BY sj-goods.grp-name sj-adv.qnty    @ sj-adv.qnty
        ACCUM SUB-TOTAL BY sj-goods.grp-name sj-adv.brutto-sum      @ sj-adv.brutto-sum
        ACCUM SUB-TOTAL BY sj-goods.grp-name sj-adv.discnt-sum      @ sj-adv.discnt-sum
        (IF (ACCUM SUB-TOTAL BY sj-goods.grp-name sj-adv.qnty) <> 0 THEN
        round( ( ACCUM SUB-TOTAL BY sj-goods.grp-name sj-adv.discnt-sum ) /
                    ( ACCUM SUB-TOTAL BY sj-goods.grp-name sj-adv.brutto-sum) * 100 , 1 )
          ELSE 0) @ pcnt
        ACCUM SUB-TOTAL BY sj-goods.grp-name sj-adv.netto-sum   @ sj-adv.netto-sum
        with FRAME sj-base-d .
        DOWN STREAM PrnLibStream 1 with FRAME sj-base-d .
      end.
      when 3 then do:
        UNDERLINE STREAM PrnLibStream
        sj-goods.b-code
        sj-goods.artic
        sj-goods.name
        sj-adv.qnty
        sj-adv.brutto-sum
        sj-adv.brutto-sum-r
        sj-adv.discnt-sum
        pcnt
        sj-adv.netto-sum
        sj-adv.netto-sum-r
        with FRAME sj-full-d .
        DISPLAY STREAM PrnLibStream
        "Итого по группе"
                                                                          @ sj-goods.name
        ACCUM SUB-TOTAL BY sj-goods.grp-name sj-adv.qnty    @ sj-adv.qnty
        ACCUM SUB-TOTAL BY sj-goods.grp-name sj-adv.brutto-sum  @ sj-adv.brutto-sum
        ACCUM SUB-TOTAL BY sj-goods.grp-name sj-adv.brutto-sum-r @ sj-adv.brutto-sum-r
        ACCUM SUB-TOTAL BY sj-goods.grp-name sj-adv.discnt-sum      @ sj-adv.discnt-sum
        (IF (ACCUM SUB-TOTAL BY sj-goods.grp-name sj-adv.qnty) <> 0 THEN
        round( ( ACCUM SUB-TOTAL BY sj-goods.grp-name sj-adv.discnt-sum ) /
                    ( ACCUM SUB-TOTAL BY sj-goods.grp-name sj-adv.brutto-sum) * 100 , 1 )
          ELSE 0) @ pcnt
        ACCUM SUB-TOTAL BY sj-goods.grp-name sj-adv.netto-sum   @ sj-adv.netto-sum
        ACCUM SUB-TOTAL BY sj-goods.grp-name sj-adv.netto-sum-r @ sj-adv.netto-sum-r
        with FRAME sj-full-d .
        DOWN STREAM PrnLibStream 1 with FRAME sj-full-d .
      end.
    END CASE .
    if not last( sj-adv.discnt ) then
    CASE my-Set_Val_Type :
      when 2 then
        UNDERLINE STREAM PrnLibStream
        sj-goods.b-code
        sj-goods.artic
        sj-goods.name
        sj-adv.qnty
        sj-adv.brutto-sum
        sj-adv.discnt-sum
        pcnt
        sj-adv.netto-sum
        with FRAME sj-base-d .
      when 3 then
        UNDERLINE STREAM PrnLibStream
        sj-goods.b-code
        sj-goods.artic
        sj-goods.name
        sj-adv.qnty
        sj-adv.brutto-sum
        sj-adv.brutto-sum-r
        sj-adv.discnt-sum
        pcnt
        sj-adv.netto-sum
        sj-adv.netto-sum-r
        with FRAME sj-full-d .
      END CASE .
      OneLinePrinted = TRUE .
    end.
  if last-of( sj-goods.prod-name ) AND prodtot_flag then do:
    IF AllObjsTotalsBy  then do:
      FIND FIRST sj-tots WHERE
                 sj-tots.obj-attr = sj-goods.obj-attr AND
                sj-tots.grp-name = sj-goods.grp-name AND
                sj-tots.prod-name = sj-goods.prod-name No-ERROR.
        IF NOT avail sj-tots then do:
          create sj-tots.
          assign
          sj-tots.obj-attr = sj-goods.obj-attr
          sj-tots.prod-name = sj-goods.prod-name
          sj-tots.qnty = ACCUM SUB-TOTAL BY sj-goods.prod-name sj-adv.qnty
          sj-tots.qnty-2 = ACCUM SUB-TOTAL BY sj-goods.prod-name sj-adv.qnty-2
          sj-tots.qnty-3 = ACCUM SUB-TOTAL BY sj-goods.prod-name sj-adv.qnty-3
          sj-tots.discnt-sum  = ACCUM SUB-TOTAL BY sj-goods.prod-name sj-adv.discnt-sum
          sj-tots.brutto-sum  = ACCUM SUB-TOTAL BY sj-goods.prod-name sj-adv.brutto-sum
          sj-tots.netto-sum  = ACCUM SUB-TOTAL BY sj-goods.prod-name sj-adv.netto-sum.
          IF my-Set_Val_Type = 3 then
          assign
          sj-tots.brutto-sum-r  = ACCUM SUB-TOTAL BY sj-goods.prod-name sj-adv.brutto-sum-r
          sj-tots.netto-sum-r  = ACCUM SUB-TOTAL BY sj-goods.prod-name sj-adv.netto-sum-r.
          ACCUMULATE
          sj-tots.discnt-sum ( TOTAL )
          sj-tots.brutto-sum  ( TOTAL )
          sj-tots.netto-sum  ( TOTAL ).
          IF my-set_val_type = 3 then
          ACCUMULATE
          sj-tots.brutto-sum-r  ( TOTAL )
          sj-tots.netto-sum-r  ( TOTAL ).
        end.
      end.
      CASE my-set_val_type :
        when 2 then do:
          UNDERLINE STREAM PrnLibStream
          sj-goods.b-code
          sj-goods.artic
          sj-goods.name
          sj-adv.qnty
          sj-adv.brutto-sum
          sj-adv.discnt-sum
          pcnt
          sj-adv.netto-sum
          with FRAME sj-base-d .
          DISPLAY STREAM PrnLibStream
          "Итого по произв-лю"
                                                                            @ sj-goods.name
          ACCUM SUB-TOTAL BY sj-goods.prod-name sj-adv.qnty    @ sj-adv.qnty
          ACCUM SUB-TOTAL BY sj-goods.prod-name sj-adv.brutto-sum      @ sj-adv.brutto-sum
          ACCUM SUB-TOTAL BY sj-goods.prod-name sj-adv.discnt-sum      @ sj-adv.discnt-sum
          (IF (ACCUM SUB-TOTAL BY sj-goods.prod-name sj-adv.qnty) <> 0 THEN
          round( ( ACCUM SUB-TOTAL BY sj-goods.prod-name sj-adv.discnt-sum ) /
                      ( ACCUM SUB-TOTAL BY sj-goods.prod-name sj-adv.brutto-sum) * 100 , 1 )
            ELSE 0) @ pcnt
          ACCUM SUB-TOTAL BY sj-goods.prod-name sj-adv.netto-sum   @ sj-adv.netto-sum
          with FRAME sj-base-d .
          DOWN STREAM PrnLibStream 1 with FRAME sj-base-d .
        end.
        when 3 then do:
          UNDERLINE STREAM PrnLibStream
          sj-goods.b-code
          sj-goods.artic
          sj-goods.name
          sj-adv.qnty
          sj-adv.brutto-sum
          sj-adv.brutto-sum-r
          sj-adv.discnt-sum
          pcnt
          sj-adv.netto-sum
          sj-adv.netto-sum-r
          with FRAME sj-full-d .
          DISPLAY STREAM PrnLibStream
          "Итого по произв-лю"
          @ sj-goods.name
          ACCUM SUB-TOTAL BY sj-goods.prod-name sj-adv.qnty    @ sj-adv.qnty
          ACCUM SUB-TOTAL BY sj-goods.prod-name sj-adv.brutto-sum  @ sj-adv.brutto-sum
          ACCUM SUB-TOTAL BY sj-goods.prod-name sj-adv.brutto-sum-r @ sj-adv.brutto-sum-r
          ACCUM SUB-TOTAL BY sj-goods.prod-name sj-adv.discnt-sum      @ sj-adv.discnt-sum
          (IF (ACCUM SUB-TOTAL BY sj-goods.prod-name sj-adv.qnty) <> 0 THEN
          round( ( ACCUM SUB-TOTAL BY sj-goods.prod-name sj-adv.discnt-sum ) /
                 ( ACCUM SUB-TOTAL BY sj-goods.prod-name sj-adv.brutto-sum) * 100 , 1 )
          ELSE 0) @ pcnt
          ACCUM SUB-TOTAL BY sj-goods.prod-name sj-adv.netto-sum   @ sj-adv.netto-sum
          ACCUM SUB-TOTAL BY sj-goods.prod-name sj-adv.netto-sum-r @ sj-adv.netto-sum-r
          with FRAME sj-full-d .
          DOWN STREAM PrnLibStream 1 with FRAME sj-full-d .
        end.
      END CASE .
      if not last(  sj-adv.discnt   ) then
      CASE my-set_val_type :
        when 2 then
          UNDERLINE STREAM PrnLibStream
          sj-goods.b-code
          sj-goods.artic
          sj-goods.name
          sj-adv.qnty
          sj-adv.brutto-sum
          sj-adv.discnt-sum
          pcnt
          sj-adv.netto-sum
          with FRAME sj-base-d .
        when 3 then
          UNDERLINE STREAM PrnLibStream
          sj-goods.b-code
          sj-goods.artic
          sj-goods.name
          sj-adv.qnty
          sj-adv.brutto-sum
          sj-adv.brutto-sum-r
          sj-adv.discnt-sum
          pcnt
          sj-adv.netto-sum
          sj-adv.netto-sum-r
          with FRAME sj-full-d .
      END CASE .
      OneLinePrinted = TRUE .
    end.
define variable vss-include-info43 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
    if last-of( sj-goods.obj-attr ) AND ( ObjsQnty > 1 ) then do:
            CASE my-set_val_type :
                when 2 then do:
                        UNDERLINE STREAM PrnLibStream
                        sj-goods.name
                        sj-adv.qnty
                        sj-adv.brutto-sum
                        sj-adv.discnt-sum
                        pcnt
                        sj-adv.netto-sum
                        with FRAME sj-base .
                        DISPLAY STREAM PrnLibStream
                        string( "Итого " + sj-goods.obj-attr )
                            @ sj-goods.name
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.qnty    @ sj-adv.qnty
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.brutto-sum
                            @ sj-adv.brutto-sum
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.discnt-sum
                            @ sj-adv.discnt-sum
                        round( ( ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.discnt-sum ) /
                            ( ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.brutto-sum ) * 100 , 1 )
                            @ pcnt
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.netto-sum
                            @ sj-adv.netto-sum
                        with FRAME sj-base .
                        DOWN STREAM PrnLibStream 1 with FRAME sj-base .
                    end.
                when 3 then do:
                        UNDERLINE STREAM PrnLibStream
                        sj-goods.name
                        sj-adv.qnty
                        sj-adv.brutto-sum
                        sj-adv.brutto-sum-r
                        sj-adv.discnt-sum
                        pcnt
                        sj-adv.netto-sum
                        sj-adv.netto-sum-r
                        with FRAME sj-full .
                        DISPLAY STREAM PrnLibStream
                        string( "Итого " + sj-goods.obj-attr )
                            @ sj-goods.name
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.qnty    @ sj-adv.qnty
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.brutto-sum  @ sj-adv.brutto-sum
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.brutto-sum-r @ sj-adv.brutto-sum-r
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.discnt-sum      @ sj-adv.discnt-sum
                        round( ( ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.discnt-sum ) /
                                    ( ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.brutto-sum) * 100 , 1 )
                                        @ pcnt
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.netto-sum   @ sj-adv.netto-sum
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.netto-sum-r @ sj-adv.netto-sum-r
                        with FRAME sj-full .
                        DOWN STREAM PrnLibStream 1 with FRAME sj-full .
                    end.
            END CASE .
            if NOT last(  sj-adv.price ) then
                CASE my-set_val_type :
                    when 2 then
                        UNDERLINE STREAM PrnLibStream
                        sj-goods.name
                        sj-adv.qnty
                        sj-adv.brutto-sum
                        sj-adv.discnt-sum
                        pcnt
                        sj-adv.netto-sum
                        with FRAME sj-base .
                    when 3 then
                        UNDERLINE STREAM PrnLibStream
                        sj-goods.name
                        sj-adv.qnty
                        sj-adv.brutto-sum
                        sj-adv.brutto-sum-r
                        sj-adv.discnt-sum
                        pcnt
                        sj-adv.netto-sum
                        sj-adv.netto-sum-r
                        with FRAME sj-full .
                END CASE .
            OneLinePrinted = TRUE .
        end.
    if last( sj-adv.discnt    ) then do:
      IF AllObjsTotalsBy then do:
        PUT STREAM PrnLibStream string( "   ПО ВСЕМ ОБЪЕКТАМ " +
           "ПО ПРОИЗВОДИТЕЛЯМ:"
           )
        format "x(120)" SKIP .
        for each sj-tots NO-LOCK BREAK BY sj-tots.prod-name:
          ACCUMULATE
          sj-tots.qnty   (TOTAL BY sj-tots.prod-name)
          sj-tots.qnty-2   (TOTAL BY sj-tots.prod-name)
          sj-tots.qnty-3   (TOTAL BY sj-tots.prod-name)
          sj-tots.brutto-sum  (TOTAL BY sj-tots.prod-name)
          sj-tots.discnt-sum  (TOTAL BY sj-tots.prod-name)
          sj-tots.netto-sum   (TOTAL BY sj-tots.prod-name).
          if my-set_val_type = 3  then
          ACCUMULATE
          sj-tots.brutto-sum-r (TOTAL BY sj-tots.prod-name)
          sj-tots.netto-sum-r (TOTAL BY sj-tots.prod-name).
          IF LAST-OF(sj-tots.prod-name) then do:
            CASE my-set_val_type :
              when 2 then do:
                UNDERLINE STREAM PrnLibStream
                sj-goods.b-code
                sj-goods.artic
                sj-goods.name
                sj-adv.qnty
                sj-adv.brutto-sum
                sj-adv.discnt-sum
                pcnt
                sj-adv.netto-sum
                with FRAME sj-base-d .
                DISPLAY STREAM PrnLibStream
                sj-tots.prod-name  @ sj-goods.name
                ACCUM TOTAL BY sj-tots.prod-name sj-tots.qnty    @ sj-adv.qnty
                ACCUM TOTAL BY sj-tots.prod-name sj-tots.brutto-sum      @ sj-adv.brutto-sum
                ACCUM TOTAL BY sj-tots.prod-name sj-tots.discnt-sum      @ sj-adv.discnt-sum
                round( ( ACCUM TOTAL BY sj-tots.prod-name sj-tots.discnt-sum ) /
                       ( ACCUM TOTAL BY sj-tots.prod-name sj-tots.brutto-sum) * 100 , 1 )
                                @ pcnt
                ACCUM TOTAL BY sj-tots.prod-name sj-tots.netto-sum   @ sj-adv.netto-sum
                with FRAME sj-base-d .
                DOWN STREAM PrnLibStream 1 with FRAME sj-base-d .
              end.
              when 3 then do:
                UNDERLINE STREAM PrnLibStream
                sj-goods.b-code
                sj-goods.artic
                sj-goods.name
                sj-adv.qnty
                sj-adv.brutto-sum
                sj-adv.brutto-sum-r
                sj-adv.discnt-sum
                pcnt
                sj-adv.netto-sum
                sj-adv.netto-sum-r
                with FRAME sj-full-d .
                DISPLAY STREAM PrnLibStream
                sj-tots.prod-name @ sj-goods.name
                ACCUM TOTAL BY sj-tots.prod-name sj-tots.qnty    @ sj-adv.qnty
                ACCUM TOTAL BY sj-tots.prod-name sj-tots.brutto-sum  @ sj-adv.brutto-sum
                ACCUM TOTAL BY sj-tots.prod-name sj-tots.brutto-sum-r @ sj-adv.brutto-sum-r
                ACCUM TOTAL BY sj-tots.prod-name sj-tots.discnt-sum      @ sj-adv.discnt-sum
                round( ( ACCUM TOTAL BY sj-tots.prod-name sj-tots.discnt-sum ) /
                            ( ACCUM TOTAL BY sj-tots.prod-name sj-tots.brutto-sum) * 100 , 1 )
                                @ pcnt
                ACCUM TOTAL BY sj-tots.prod-name sj-tots.netto-sum   @ sj-adv.netto-sum
                ACCUM TOTAL BY sj-tots.prod-name sj-tots.netto-sum-r @ sj-adv.netto-sum-r
                with FRAME sj-full-d .
                DOWN STREAM PrnLibStream 1 with FRAME sj-full-d .
              end.
            END CASE .
          end.
        END.
    end.
    if ( line-counter(PrnLibStream) + 7 ) > page-size(PrnLibStream) then page stream PrnLibStream.
    CASE my-set_val_type :
      when 2 then do:
        if OneLinePrinted then
        PUT STREAM PrnLibStream  LINE format ("X(" + string(198) + ")") SKIP.
        DISPLAY STREAM PrnLibStream
        substitute("ИТОГО ч- &1", v-num-chk) @ sj-goods.name
        ACCUM TOTAL sj-adv.qnty @ sj-adv.qnty
        ACCUM TOTAL sj-adv.brutto-sum @ sj-adv.brutto-sum
        ACCUM TOTAL sj-adv.discnt-sum @ sj-adv.discnt-sum
        (IF (ACCUM TOTAL sj-adv.qnty) <> 0 THEN
        round( ( ACCUM TOTAL sj-adv.discnt-sum ) /
                    ( ACCUM TOTAL sj-adv.brutto-sum ) * 100 , 1 ) ELSE 0) @ pcnt
        ACCUM TOTAL sj-adv.netto-sum @ sj-adv.netto-sum
            with FRAME sj-base-d .
        DOWN STREAM PrnLibStream 1 with FRAME sj-base-d .
        DISPLAY STREAM PrnLibStream
        (string(round((ACCUM TOTAL sj-adv.qnty) / v-num-chk, 2)) + "/ч")  @ sj-adv.qnty
        with FRAME sj-base-d .
        DOWN STREAM PrnLibStream 1 with FRAME sj-base-d .
        UNDERLINE STREAM PrnLibStream
        sj-goods.b-code
        sj-goods.artic
        sj-goods.name
        sj-adv.qnty
        sj-adv.brutto-sum
        sj-adv.discnt-sum
        pcnt
        sj-adv.netto-sum
        with FRAME sj-base-d .
      end.
      when 3 then do:
        if OneLinePrinted then
        PUT STREAM PrnLibStream LINE  SKIP.
        DISPLAY STREAM PrnLibStream
        substitute("ИТОГО ч- &1", v-num-chk) @ sj-goods.name
        ACCUM TOTAL sj-adv.qnty @ sj-adv.qnty
        ACCUM TOTAL sj-adv.brutto-sum @ sj-adv.brutto-sum
        ACCUM TOTAL sj-adv.brutto-sum-r @ sj-adv.brutto-sum-r
        ACCUM TOTAL sj-adv.discnt-sum @ sj-adv.discnt-sum
        (IF (ACCUM TOTAL sj-adv.qnty) <> 0 THEN
        round( ( ACCUM TOTAL sj-adv.discnt-sum ) /
                    ( ACCUM TOTAL sj-adv.brutto-sum ) * 100 , 1 ) ELSE 0) @ pcnt
        ACCUM TOTAL sj-adv.netto-sum @ sj-adv.netto-sum
        ACCUM TOTAL sj-adv.netto-sum-r @ sj-adv.netto-sum-r
        with FRAME sj-full-d .
        DOWN STREAM PrnLibStream 1 with FRAME sj-full-d .
        DISPLAY STREAM PrnLibStream
        (string(round((ACCUM TOTAL sj-adv.qnty) / v-num-chk, 2)) + "/ч") @ sj-adv.qnty
        with FRAME sj-full-d .
        DOWN STREAM PrnLibStream 1 with FRAME sj-full-d .
        UNDERLINE STREAM PrnLibStream
        sj-goods.b-code
        sj-goods.artic
        sj-goods.name
        sj-adv.qnty
        sj-adv.brutto-sum
        sj-adv.brutto-sum-r
        sj-adv.discnt-sum pcnt
        sj-adv.netto-sum
        sj-adv.netto-sum-r
        with FRAME sj-full-d .
      end.
    END CASE .
    if ObjsQnty = 1 then
    PUT STREAM PrnLibStream
    " " SKIP(1) space(10)
    "Директор ______________" format "X(50)"
    "Кассир ___________________" format "X(50)" SKIP .
  end.
  END.
end.
END PROCEDURE.
PROCEDURE SimpleProc_d.
define variable v-salesman-name as character no-undo .
define buffer buf_saleman for ub.clients.
define variable vss-include-info44 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if SHRs-sort = "Article":U then do:
  if SHBySalers then do:
      FOR EACH sj-goods NO-LOCK,
          EACH sj-adv NO-LOCK WHERE
                sj-adv.obj-attr = sj-goods.obj-attr AND
                sj-adv.b-code = sj-goods.b-code AND
                sj-adv.saleman = sj-goods.saleman
          BREAK BY sj-goods.obj-attr
                BY sj-goods.saleman
                BY sj-goods.artic
                BY sj-goods.b-code
                BY sj-adv.price
                BY sj-adv.discnt
                :
define variable vss-include-info45 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if first( sj-goods.obj-attr ) then do:
  if v-curr-r-b = 'base':U then do:
                        if my-set_val_type = 2  then
                            DOWN STREAM PrnLibStream 1 with FRAME sj-base-d .
                        else
                            DOWN STREAM PrnLibStream 1 with FRAME sj-full-d .
  end.
  else do:
                            DOWN STREAM PrnLibStream 1 with FRAME sj-base-d .
  end.
end.
                if first-of( sj-goods.obj-attr ) AND ( ObjsQnty > 1 ) then  do:
                        assign
                        strbuf1 = substr( sj-goods.obj-attr, 1, 3 )
                        intbuf1 = integer( substr( sj-goods.obj-attr, 4 ) ) .
                        FIND FIRST cli-obj WHERE
                                   cli-obj.obj-type = strbuf1 AND
                                   cli-obj.obj-code = intbuf1 NO-LOCK .
                        PUT STREAM PrnLibStream
                        cli-obj.obj-name format "x(120)" SKIP.
if v-curr-r-b = 'base':U then do:
                        if my-set_val_type = 2  then
                        UNDERLINE STREAM PrnLibStream
                        sj-goods.artic
                        sj-goods.name
                        with FRAME sj-base-d .
                        else
                        UNDERLINE STREAM PrnLibStream
                        sj-goods.artic
                        sj-goods.name
                        with FRAME sj-full-d .
end.
else do:
                        UNDERLINE STREAM PrnLibStream
                        sj-goods.artic
                        sj-goods.name
                        with FRAME sj-base-d .
end.
                    end.
define variable vss-include-info46 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
    ACCUMULATE
    sj-adv.qnty (TOTAL)
    sj-adv.qnty-2 (TOTAL)
    sj-adv.qnty-3 (TOTAL)
    sj-adv.brutto-sum (TOTAL)
    sj-adv.discnt-sum (TOTAL)
    sj-adv.netto-sum (TOTAL)
    sj-adv.brutto-sum-r (TOTAL)
    sj-adv.netto-sum-r (TOTAL)
    sj-adv.num-docs (TOTAL)
    sj-adv.num-lines (TOTAL)
    sj-adv.qnty ( SUB-TOTAL BY sj-goods.obj-attr )
    sj-adv.qnty-2 ( SUB-TOTAL BY sj-goods.obj-attr )
    sj-adv.qnty-3 ( SUB-TOTAL BY sj-goods.obj-attr )
    sj-adv.brutto-sum ( SUB-TOTAL BY sj-goods.obj-attr )
    sj-adv.discnt-sum ( SUB-TOTAL BY sj-goods.obj-attr )
    sj-adv.netto-sum ( SUB-TOTAL BY sj-goods.obj-attr )
    sj-adv.brutto-sum-r ( SUB-TOTAL BY sj-goods.obj-attr )
    sj-adv.netto-sum-r ( SUB-TOTAL BY sj-goods.obj-attr )
    sj-adv.qnty ( SUB-TOTAL BY sj-adv.discnt )
    sj-adv.qnty-2 ( SUB-TOTAL BY sj-adv.discnt )
    sj-adv.qnty-3 ( SUB-TOTAL BY sj-adv.discnt )
    sj-adv.brutto-sum ( SUB-TOTAL BY sj-adv.discnt )
    sj-adv.discnt-sum ( SUB-TOTAL BY sj-adv.discnt )
    sj-adv.netto-sum ( SUB-TOTAL BY sj-adv.discnt )
    sj-adv.brutto-sum-r ( SUB-TOTAL BY sj-adv.discnt )
    sj-adv.netto-sum-r ( SUB-TOTAL BY sj-adv.discnt )
    sj-adv.qnty ( SUB-TOTAL BY sj-goods.saleman )
    sj-adv.qnty-2 ( SUB-TOTAL BY sj-goods.saleman )
    sj-adv.qnty-3 ( SUB-TOTAL BY sj-goods.saleman )
    sj-adv.brutto-sum ( SUB-TOTAL BY sj-goods.saleman )
    sj-adv.discnt-sum ( SUB-TOTAL BY sj-goods.saleman )
    sj-adv.netto-sum ( SUB-TOTAL BY sj-goods.saleman )
    sj-adv.brutto-sum-r ( SUB-TOTAL BY sj-goods.saleman )
    sj-adv.netto-sum-r ( SUB-TOTAL BY sj-goods.saleman )
    sj-adv.num-docs (SUB-TOTAL BY sj-goods.saleman )
    sj-adv.num-lines (SUB-TOTAL BY sj-goods.saleman )
    .
if sj-goods.twounit = 0 then do:
  if last-of ( sj-adv.discnt ) AND SHRs-by <> 0 then do:
    namebuf1 = get-strokes(buffer sj-goods, 18, 21,
                           input-output namebuf1,
                           input-output namebuf2,
                           input-output prodbuf1,
                           input-output prodbuf2).
    CASE my-Set_val_type :
    when 2 then  do:
      DISPLAY STREAM PrnLibStream
      sj-goods.b-code
      sj-goods.artic
      namebuf1 @ sj-goods.name
      prodbuf1 @ sj-goods.prod-name
      ACCUM SUB-TOTAL BY sj-adv.discnt sj-adv.qnty @ sj-adv.qnty
      sj-adv.price
      ACCUM SUB-TOTAL BY sj-adv.discnt sj-adv.brutto-sum @ sj-adv.brutto-sum
      sj-adv.discnt
      ACCUM SUB-TOTAL BY sj-adv.discnt sj-adv.discnt-sum @ sj-adv.discnt-sum
      (IF (ACCUM SUB-TOTAL BY sj-adv.discnt sj-adv.qnty) <> 0
      THEN
      round( ( ACCUM SUB-TOTAL BY sj-adv.discnt sj-adv.discnt-sum ) /
      ( ACCUM SUB-TOTAL BY sj-adv.discnt sj-adv.brutto-sum ) * 100 , 1 )
      else 0)  @ pcnt
      ACCUM SUB-TOTAL BY sj-adv.discnt sj-adv.netto-sum @ sj-adv.netto-sum
      with FRAME sj-base-d .
      DOWN STREAM PrnLibStream 1 with FRAME sj-base-d .
     end.
     when 3 then do:
      DISPLAY STREAM PrnLibStream
      sj-goods.b-code
      sj-goods.artic
      namebuf1 @ sj-goods.name
      prodbuf1 @ sj-goods.prod-name
      ACCUM SUB-TOTAL BY  sj-adv.discnt  sj-adv.qnty @ sj-adv.qnty
      sj-adv.price
      ACCUM SUB-TOTAL BY  sj-adv.discnt  sj-adv.brutto-sum @ sj-adv.brutto-sum
      ACCUM SUB-TOTAL BY  sj-adv.discnt  sj-adv.brutto-sum-r @ sj-adv.brutto-sum-r
      sj-adv.discnt
      ACCUM SUB-TOTAL BY  sj-adv.discnt  sj-adv.discnt-sum @ sj-adv.discnt-sum
      (IF (ACCUM SUB-TOTAL BY  sj-adv.discnt  sj-adv.qnty) <> 0
      THEN
      round( ( ACCUM SUB-TOTAL BY  sj-adv.discnt  sj-adv.discnt-sum ) /
      ( ACCUM SUB-TOTAL BY  sj-adv.discnt  sj-adv.brutto-sum ) * 100, 1 )
      ELSE 0 ) @ pcnt
      ACCUM SUB-TOTAL BY  sj-adv.discnt  sj-adv.netto-sum @ sj-adv.netto-sum
      ACCUM SUB-TOTAL BY  sj-adv.discnt  sj-adv.netto-sum-r @ sj-adv.netto-sum-r
      with FRAME sj-full-d .
      DOWN STREAM PrnLibStream 1 with FRAME sj-full-d .
     end.
     END CASE .
     if ( namebuf2 <> "" ) OR ( prodbuf2 <> "" ) then
     CASE my-Set_val_type :
       when 2 then  do:
        DISPLAY STREAM PrnLibStream
        namebuf2 @ sj-goods.name
        prodbuf2 @ sj-goods.prod-name
        with FRAME sj-base-d .
        DOWN STREAM PrnLibStream 1 with FRAME sj-base-d .
      end.
      when 3 then do:
        DISPLAY STREAM PrnLibStream
        namebuf2 @ sj-goods.name
        prodbuf2 @ sj-goods.prod-name
        with FRAME sj-full-d .
        DOWN STREAM PrnLibStream 1 with FRAME sj-full-d .
      end.
    END CASE .
    OneLinePrinted = TRUE .
  end .
end.
  if last-of( sj-goods.saleman ) AND SHBySalers then do:
    v-salesman-name = '':U.
    if entry(2, sj-goods.saleman, chr(4)) <> string(0) then do:
      find first buf_saleman where
                buf_saleman.obj-type = 'чел':U
            AND buf_saleman.obj-code = integer(entry(2, sj-goods.saleman, chr(4))) no-error .
      if not available buf_saleman then do:
        v-salesman-name = '':U.
      end.
      else do:
        v-salesman-name = buf_saleman.obj-name.
      end.
    end.
    CASE my-Set_val_type :
      when 2 then  do:
        UNDERLINE STREAM PrnLibStream
        sj-goods.b-code
        sj-goods.artic
        sj-goods.name
        sj-adv.qnty
        sj-adv.brutto-sum
        sj-adv.discnt-sum
        pcnt
        sj-adv.netto-sum
        with FRAME sj-base-d .
        DISPLAY STREAM PrnLibStream
        (if Shrs-seller-cashier = 'Cashier'
        then substitute("ч-&1", ( ACCUM SUB-TOTAL BY sj-goods.saleman sj-adv.num-docs))
        else '':U)  @ sj-goods.b-code
        (if Shrs-seller-cashier = 'Cashier'
        then substitute("стр-&1", (ACCUM SUB-TOTAL BY sj-goods.saleman sj-adv.num-lines))
        else '':U) @ sj-goods.artic
        string(  v-seller-cashier-1 + entry(1, sj-goods.saleman , chr(4)) )  @ sj-goods.name
        v-salesman-name @ sj-goods.prod-name
        ACCUM SUB-TOTAL BY sj-goods.saleman sj-adv.qnty    @ sj-adv.qnty
        ACCUM SUB-TOTAL BY sj-goods.saleman sj-adv.brutto-sum      @ sj-adv.brutto-sum
        ACCUM SUB-TOTAL BY sj-goods.saleman sj-adv.discnt-sum      @ sj-adv.discnt-sum
        (IF (ACCUM SUB-TOTAL BY sj-goods.saleman sj-adv.qnty) <> 0
        THEN
        round( ( ACCUM SUB-TOTAL BY sj-goods.saleman sj-adv.discnt-sum ) /
        ( ACCUM SUB-TOTAL BY sj-goods.saleman sj-adv.brutto-sum) * 100 , 1 )
        ELSE 0 ) @ pcnt
        ACCUM SUB-TOTAL BY sj-goods.saleman sj-adv.netto-sum   @ sj-adv.netto-sum
        with FRAME sj-base-d .
        DOWN STREAM PrnLibStream 1 with FRAME sj-base-d .
      end.
      when 3 then do:
        UNDERLINE STREAM PrnLibStream
        sj-goods.b-code
        sj-goods.artic
        sj-goods.name
        sj-adv.qnty
        sj-adv.brutto-sum
        sj-adv.brutto-sum-r
        sj-adv.discnt-sum
        pcnt
        sj-adv.netto-sum
        sj-adv.netto-sum-r
        with FRAME sj-full-d .
        DISPLAY STREAM PrnLibStream
        (if Shrs-seller-cashier = 'Cashier'
        then substitute("ч-&1", (ACCUM SUB-TOTAL BY (sj-goods.saleman) sj-adv.num-docs))
        else '':U) @ sj-goods.b-code
        (if Shrs-seller-cashier = 'Cashier'
        then substitute("стр-&1", (ACCUM SUB-TOTAL BY (sj-goods.saleman) sj-adv.num-lines))
        else '':U)  @ sj-goods.artic
        string(  v-seller-cashier-1 + entry(1, sj-goods.saleman , chr(4))) @ sj-goods.name
        v-salesman-name @ sj-goods.prod-name
        ACCUM SUB-TOTAL BY sj-goods.saleman sj-adv.qnty    @ sj-adv.qnty
        ACCUM SUB-TOTAL BY sj-goods.saleman sj-adv.brutto-sum  @ sj-adv.brutto-sum
        ACCUM SUB-TOTAL BY sj-goods.saleman sj-adv.brutto-sum-r @ sj-adv.brutto-sum-r
        ACCUM SUB-TOTAL BY sj-goods.saleman sj-adv.discnt-sum @ sj-adv.discnt-sum
        (IF (ACCUM SUB-TOTAL BY sj-goods.saleman sj-adv.qnty) <> 0
        THEN
        round( ( ACCUM SUB-TOTAL BY sj-goods.saleman sj-adv.discnt-sum ) /
                        ( ACCUM SUB-TOTAL BY sj-goods.saleman sj-adv.brutto-sum) * 100, 1 )
        ELSE 0 ) @ pcnt
        ACCUM SUB-TOTAL BY sj-goods.saleman sj-adv.netto-sum   @ sj-adv.netto-sum
        ACCUM SUB-TOTAL BY sj-goods.saleman sj-adv.netto-sum-r @ sj-adv.netto-sum-r
        with FRAME sj-full-d .
        DOWN STREAM PrnLibStream 1 with FRAME sj-full-d .
      end.
    END CASE .
    if not last(  sj-adv.discnt  ) then
      CASE my-Set_val_type :
        when 2 then
          UNDERLINE STREAM PrnLibStream
          sj-goods.b-code
          sj-goods.artic
          sj-goods.name
          sj-adv.qnty
          sj-adv.brutto-sum
          sj-adv.discnt-sum
          pcnt
          sj-adv.netto-sum
        with FRAME sj-base-d .
        when 3 then
          UNDERLINE STREAM PrnLibStream
          sj-goods.b-code
          sj-goods.artic
          sj-goods.name
          sj-adv.qnty
          sj-adv.brutto-sum
          sj-adv.brutto-sum-r
          sj-adv.discnt-sum
          pcnt
          sj-adv.netto-sum
          sj-adv.netto-sum-r
          with FRAME sj-full-d .
      END CASE .
      OneLinePrinted = TRUE .
    end.
define variable vss-include-info47 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
    if last-of( sj-goods.obj-attr ) AND ( ObjsQnty > 1 ) then do:
            CASE my-set_val_type :
                when 2 then do:
                        UNDERLINE STREAM PrnLibStream
                        sj-goods.name
                        sj-adv.qnty
                        sj-adv.brutto-sum
                        sj-adv.discnt-sum
                        pcnt
                        sj-adv.netto-sum
                        with FRAME sj-base .
                        DISPLAY STREAM PrnLibStream
                        string( "Итого " + sj-goods.obj-attr )
                            @ sj-goods.name
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.qnty    @ sj-adv.qnty
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.brutto-sum
                            @ sj-adv.brutto-sum
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.discnt-sum
                            @ sj-adv.discnt-sum
                        round( ( ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.discnt-sum ) /
                            ( ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.brutto-sum ) * 100 , 1 )
                            @ pcnt
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.netto-sum
                            @ sj-adv.netto-sum
                        with FRAME sj-base .
                        DOWN STREAM PrnLibStream 1 with FRAME sj-base .
                    end.
                when 3 then do:
                        UNDERLINE STREAM PrnLibStream
                        sj-goods.name
                        sj-adv.qnty
                        sj-adv.brutto-sum
                        sj-adv.brutto-sum-r
                        sj-adv.discnt-sum
                        pcnt
                        sj-adv.netto-sum
                        sj-adv.netto-sum-r
                        with FRAME sj-full .
                        DISPLAY STREAM PrnLibStream
                        string( "Итого " + sj-goods.obj-attr )
                            @ sj-goods.name
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.qnty    @ sj-adv.qnty
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.brutto-sum  @ sj-adv.brutto-sum
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.brutto-sum-r @ sj-adv.brutto-sum-r
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.discnt-sum      @ sj-adv.discnt-sum
                        round( ( ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.discnt-sum ) /
                                    ( ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.brutto-sum) * 100 , 1 )
                                        @ pcnt
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.netto-sum   @ sj-adv.netto-sum
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.netto-sum-r @ sj-adv.netto-sum-r
                        with FRAME sj-full .
                        DOWN STREAM PrnLibStream 1 with FRAME sj-full .
                    end.
            END CASE .
            if NOT last(  sj-adv.price ) then
                CASE my-set_val_type :
                    when 2 then
                        UNDERLINE STREAM PrnLibStream
                        sj-goods.name
                        sj-adv.qnty
                        sj-adv.brutto-sum
                        sj-adv.discnt-sum
                        pcnt
                        sj-adv.netto-sum
                        with FRAME sj-base .
                    when 3 then
                        UNDERLINE STREAM PrnLibStream
                        sj-goods.name
                        sj-adv.qnty
                        sj-adv.brutto-sum
                        sj-adv.brutto-sum-r
                        sj-adv.discnt-sum
                        pcnt
                        sj-adv.netto-sum
                        sj-adv.netto-sum-r
                        with FRAME sj-full .
                END CASE .
            OneLinePrinted = TRUE .
        end.
    if last(  sj-adv.discnt  ) then do:
      if v-curr-r-b = 'base':U and my-Set_val_type = 3 then  do:
        if OneLinePrinted then
        PUT STREAM PrnLibStream Line  SKIP.
      end.
      else do:
        if OneLinePrinted then
        PUT STREAM PrnLibStream Line format ("X(" + string(196) + ")")  SKIP.
      end.
      if ( line-counter(PrnLibStream) + 7 ) > page-size(PrnLibStream) then page stream PrnLibStream .
      CASE my-Set_val_type :
        when 2 then do:
          DISPLAY STREAM PrnLibStream
          substitute("ИТОГО ч- &1", v-num-chk) @ sj-goods.name
          ACCUM TOTAL sj-adv.qnty @ sj-adv.qnty
          ACCUM TOTAL sj-adv.brutto-sum @ sj-adv.brutto-sum
          ACCUM TOTAL sj-adv.discnt-sum @ sj-adv.discnt-sum
          (IF (ACCUM TOTAL sj-adv.qnty) <> 0
          THEN
          round( ( ACCUM TOTAL sj-adv.discnt-sum ) /
          ( ACCUM TOTAL sj-adv.brutto-sum ) * 100 , 1 )
          ELSE 0) @ pcnt
          ACCUM TOTAL sj-adv.netto-sum @ sj-adv.netto-sum
          with FRAME sj-base-d .
          DOWN STREAM PrnLibStream 1 with FRAME sj-base-d .
          DISPLAY STREAM PrnLibStream
          (string(round((ACCUM TOTAL sj-adv.qnty) / v-num-chk, 2)) + "/ч")  @ sj-adv.qnty
          with FRAME sj-base-d .
          DOWN STREAM PrnLibStream 1 with FRAME sj-base-d .
          UNDERLINE STREAM PrnLibStream
          sj-goods.b-code
          sj-goods.artic
          sj-goods.name
          sj-adv.qnty
          sj-adv.brutto-sum
          sj-adv.discnt-sum
          pcnt
          sj-adv.netto-sum
          with FRAME sj-base-d .
        end.
        when 3 then do:
        DISPLAY STREAM PrnLibStream
        substitute("ИТОГО ч- &1", v-num-chk) @ sj-goods.name
        ACCUM TOTAL sj-adv.qnty @ sj-adv.qnty
        ACCUM TOTAL sj-adv.brutto-sum @ sj-adv.brutto-sum
        ACCUM TOTAL sj-adv.brutto-sum-r @ sj-adv.brutto-sum-r
        ACCUM TOTAL sj-adv.discnt-sum @ sj-adv.discnt-sum
        (IF (ACCUM TOTAL sj-adv.qnty) <> 0
        THEN
        round( ( ACCUM TOTAL sj-adv.discnt-sum ) /
                      ( ACCUM TOTAL sj-adv.brutto-sum ) * 100 , 1 )
        ELSE 0) @ pcnt
        ACCUM TOTAL sj-adv.netto-sum @ sj-adv.netto-sum
        ACCUM TOTAL sj-adv.netto-sum-r @ sj-adv.netto-sum-r
        with FRAME sj-full-d .
        DOWN STREAM PrnLibStream 1 with FRAME sj-full-d .
        DISPLAY STREAM PrnLibStream
        (string(round((ACCUM TOTAL sj-adv.qnty) / v-num-chk, 2)) + "/ч")  @ sj-adv.qnty
        with FRAME sj-full-d .
        DOWN STREAM PrnLibStream 1 with FRAME sj-full-d .
        UNDERLINE STREAM PrnLibStream
        sj-goods.b-code
        sj-goods.artic
        sj-goods.name
        sj-adv.qnty
        sj-adv.brutto-sum
        sj-adv.brutto-sum-r
        sj-adv.discnt-sum
        pcnt
        sj-adv.netto-sum
        sj-adv.netto-sum-r
        with FRAME sj-full-d .
      end.
    END CASE .
    if ObjsQnty = 1 then
    PUT STREAM PrnLibStream
    " " SKIP(1) space(10)
    "Директор ______________" format "X(50)"
    "Кассир ___________________" format "X(50)" SKIP .
  end.
      END .
  end.
  else do:
      FOR EACH sj-goods NO-LOCK,
        EACH sj-adv NO-LOCK WHERE
              sj-adv.obj-attr = sj-goods.obj-attr AND
              sj-adv.b-code = sj-goods.b-code AND
              sj-adv.saleman = sj-goods.saleman
        BREAK BY sj-goods.obj-attr
              BY sj-goods.artic
              BY sj-goods.b-code
              BY sj-adv.price
              BY sj-adv.discnt
              BY sj-goods.saleman :
define variable vss-include-info48 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if first( sj-goods.obj-attr ) then do:
  if v-curr-r-b = 'base':U then do:
                        if my-set_val_type = 2  then
                            DOWN STREAM PrnLibStream 1 with FRAME sj-base-d .
                        else
                            DOWN STREAM PrnLibStream 1 with FRAME sj-full-d .
  end.
  else do:
                            DOWN STREAM PrnLibStream 1 with FRAME sj-base-d .
  end.
end.
                if first-of( sj-goods.obj-attr ) AND ( ObjsQnty > 1 ) then  do:
                        assign
                        strbuf1 = substr( sj-goods.obj-attr, 1, 3 )
                        intbuf1 = integer( substr( sj-goods.obj-attr, 4 ) ) .
                        FIND FIRST cli-obj WHERE
                                   cli-obj.obj-type = strbuf1 AND
                                   cli-obj.obj-code = intbuf1 NO-LOCK .
                        PUT STREAM PrnLibStream
                        cli-obj.obj-name format "x(120)" SKIP.
if v-curr-r-b = 'base':U then do:
                        if my-set_val_type = 2  then
                        UNDERLINE STREAM PrnLibStream
                        sj-goods.artic
                        sj-goods.name
                        with FRAME sj-base-d .
                        else
                        UNDERLINE STREAM PrnLibStream
                        sj-goods.artic
                        sj-goods.name
                        with FRAME sj-full-d .
end.
else do:
                        UNDERLINE STREAM PrnLibStream
                        sj-goods.artic
                        sj-goods.name
                        with FRAME sj-base-d .
end.
                    end.
define variable vss-include-info49 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
    ACCUMULATE
    sj-adv.qnty (TOTAL)
    sj-adv.qnty-2 (TOTAL)
    sj-adv.qnty-3 (TOTAL)
    sj-adv.brutto-sum (TOTAL)
    sj-adv.discnt-sum (TOTAL)
    sj-adv.netto-sum (TOTAL)
    sj-adv.brutto-sum-r (TOTAL)
    sj-adv.netto-sum-r (TOTAL)
    sj-adv.num-docs (TOTAL)
    sj-adv.num-lines (TOTAL)
    sj-adv.qnty ( SUB-TOTAL BY sj-goods.obj-attr )
    sj-adv.qnty-2 ( SUB-TOTAL BY sj-goods.obj-attr )
    sj-adv.qnty-3 ( SUB-TOTAL BY sj-goods.obj-attr )
    sj-adv.brutto-sum ( SUB-TOTAL BY sj-goods.obj-attr )
    sj-adv.discnt-sum ( SUB-TOTAL BY sj-goods.obj-attr )
    sj-adv.netto-sum ( SUB-TOTAL BY sj-goods.obj-attr )
    sj-adv.brutto-sum-r ( SUB-TOTAL BY sj-goods.obj-attr )
    sj-adv.netto-sum-r ( SUB-TOTAL BY sj-goods.obj-attr )
    sj-adv.qnty ( SUB-TOTAL BY sj-adv.discnt )
    sj-adv.qnty-2 ( SUB-TOTAL BY sj-adv.discnt )
    sj-adv.qnty-3 ( SUB-TOTAL BY sj-adv.discnt )
    sj-adv.brutto-sum ( SUB-TOTAL BY sj-adv.discnt )
    sj-adv.discnt-sum ( SUB-TOTAL BY sj-adv.discnt )
    sj-adv.netto-sum ( SUB-TOTAL BY sj-adv.discnt )
    sj-adv.brutto-sum-r ( SUB-TOTAL BY sj-adv.discnt )
    sj-adv.netto-sum-r ( SUB-TOTAL BY sj-adv.discnt )
    sj-adv.qnty ( SUB-TOTAL BY sj-goods.saleman )
    sj-adv.qnty-2 ( SUB-TOTAL BY sj-goods.saleman )
    sj-adv.qnty-3 ( SUB-TOTAL BY sj-goods.saleman )
    sj-adv.brutto-sum ( SUB-TOTAL BY sj-goods.saleman )
    sj-adv.discnt-sum ( SUB-TOTAL BY sj-goods.saleman )
    sj-adv.netto-sum ( SUB-TOTAL BY sj-goods.saleman )
    sj-adv.brutto-sum-r ( SUB-TOTAL BY sj-goods.saleman )
    sj-adv.netto-sum-r ( SUB-TOTAL BY sj-goods.saleman )
    sj-adv.num-docs (SUB-TOTAL BY sj-goods.saleman )
    sj-adv.num-lines (SUB-TOTAL BY sj-goods.saleman )
    .
if sj-goods.twounit = 0 then do:
  if last-of ( sj-adv.discnt ) AND SHRs-by <> 0 then do:
    namebuf1 = get-strokes(buffer sj-goods, 18, 21,
                           input-output namebuf1,
                           input-output namebuf2,
                           input-output prodbuf1,
                           input-output prodbuf2).
    CASE my-Set_val_type :
    when 2 then  do:
      DISPLAY STREAM PrnLibStream
      sj-goods.b-code
      sj-goods.artic
      namebuf1 @ sj-goods.name
      prodbuf1 @ sj-goods.prod-name
      ACCUM SUB-TOTAL BY sj-adv.discnt sj-adv.qnty @ sj-adv.qnty
      sj-adv.price
      ACCUM SUB-TOTAL BY sj-adv.discnt sj-adv.brutto-sum @ sj-adv.brutto-sum
      sj-adv.discnt
      ACCUM SUB-TOTAL BY sj-adv.discnt sj-adv.discnt-sum @ sj-adv.discnt-sum
      (IF (ACCUM SUB-TOTAL BY sj-adv.discnt sj-adv.qnty) <> 0
      THEN
      round( ( ACCUM SUB-TOTAL BY sj-adv.discnt sj-adv.discnt-sum ) /
      ( ACCUM SUB-TOTAL BY sj-adv.discnt sj-adv.brutto-sum ) * 100 , 1 )
      else 0)  @ pcnt
      ACCUM SUB-TOTAL BY sj-adv.discnt sj-adv.netto-sum @ sj-adv.netto-sum
      with FRAME sj-base-d .
      DOWN STREAM PrnLibStream 1 with FRAME sj-base-d .
     end.
     when 3 then do:
      DISPLAY STREAM PrnLibStream
      sj-goods.b-code
      sj-goods.artic
      namebuf1 @ sj-goods.name
      prodbuf1 @ sj-goods.prod-name
      ACCUM SUB-TOTAL BY  sj-adv.discnt  sj-adv.qnty @ sj-adv.qnty
      sj-adv.price
      ACCUM SUB-TOTAL BY  sj-adv.discnt  sj-adv.brutto-sum @ sj-adv.brutto-sum
      ACCUM SUB-TOTAL BY  sj-adv.discnt  sj-adv.brutto-sum-r @ sj-adv.brutto-sum-r
      sj-adv.discnt
      ACCUM SUB-TOTAL BY  sj-adv.discnt  sj-adv.discnt-sum @ sj-adv.discnt-sum
      (IF (ACCUM SUB-TOTAL BY  sj-adv.discnt  sj-adv.qnty) <> 0
      THEN
      round( ( ACCUM SUB-TOTAL BY  sj-adv.discnt  sj-adv.discnt-sum ) /
      ( ACCUM SUB-TOTAL BY  sj-adv.discnt  sj-adv.brutto-sum ) * 100, 1 )
      ELSE 0 ) @ pcnt
      ACCUM SUB-TOTAL BY  sj-adv.discnt  sj-adv.netto-sum @ sj-adv.netto-sum
      ACCUM SUB-TOTAL BY  sj-adv.discnt  sj-adv.netto-sum-r @ sj-adv.netto-sum-r
      with FRAME sj-full-d .
      DOWN STREAM PrnLibStream 1 with FRAME sj-full-d .
     end.
     END CASE .
     if ( namebuf2 <> "" ) OR ( prodbuf2 <> "" ) then
     CASE my-Set_val_type :
       when 2 then  do:
        DISPLAY STREAM PrnLibStream
        namebuf2 @ sj-goods.name
        prodbuf2 @ sj-goods.prod-name
        with FRAME sj-base-d .
        DOWN STREAM PrnLibStream 1 with FRAME sj-base-d .
      end.
      when 3 then do:
        DISPLAY STREAM PrnLibStream
        namebuf2 @ sj-goods.name
        prodbuf2 @ sj-goods.prod-name
        with FRAME sj-full-d .
        DOWN STREAM PrnLibStream 1 with FRAME sj-full-d .
      end.
    END CASE .
    OneLinePrinted = TRUE .
  end .
end.
  if last-of( sj-goods.saleman ) AND SHBySalers then do:
    v-salesman-name = '':U.
    if entry(2, sj-goods.saleman, chr(4)) <> string(0) then do:
      find first buf_saleman where
                buf_saleman.obj-type = 'чел':U
            AND buf_saleman.obj-code = integer(entry(2, sj-goods.saleman, chr(4))) no-error .
      if not available buf_saleman then do:
        v-salesman-name = '':U.
      end.
      else do:
        v-salesman-name = buf_saleman.obj-name.
      end.
    end.
    CASE my-Set_val_type :
      when 2 then  do:
        UNDERLINE STREAM PrnLibStream
        sj-goods.b-code
        sj-goods.artic
        sj-goods.name
        sj-adv.qnty
        sj-adv.brutto-sum
        sj-adv.discnt-sum
        pcnt
        sj-adv.netto-sum
        with FRAME sj-base-d .
        DISPLAY STREAM PrnLibStream
        (if Shrs-seller-cashier = 'Cashier'
        then substitute("ч-&1", ( ACCUM SUB-TOTAL BY sj-goods.saleman sj-adv.num-docs))
        else '':U)  @ sj-goods.b-code
        (if Shrs-seller-cashier = 'Cashier'
        then substitute("стр-&1", (ACCUM SUB-TOTAL BY sj-goods.saleman sj-adv.num-lines))
        else '':U) @ sj-goods.artic
        string(  v-seller-cashier-1 + entry(1, sj-goods.saleman , chr(4)) )  @ sj-goods.name
        v-salesman-name @ sj-goods.prod-name
        ACCUM SUB-TOTAL BY sj-goods.saleman sj-adv.qnty    @ sj-adv.qnty
        ACCUM SUB-TOTAL BY sj-goods.saleman sj-adv.brutto-sum      @ sj-adv.brutto-sum
        ACCUM SUB-TOTAL BY sj-goods.saleman sj-adv.discnt-sum      @ sj-adv.discnt-sum
        (IF (ACCUM SUB-TOTAL BY sj-goods.saleman sj-adv.qnty) <> 0
        THEN
        round( ( ACCUM SUB-TOTAL BY sj-goods.saleman sj-adv.discnt-sum ) /
        ( ACCUM SUB-TOTAL BY sj-goods.saleman sj-adv.brutto-sum) * 100 , 1 )
        ELSE 0 ) @ pcnt
        ACCUM SUB-TOTAL BY sj-goods.saleman sj-adv.netto-sum   @ sj-adv.netto-sum
        with FRAME sj-base-d .
        DOWN STREAM PrnLibStream 1 with FRAME sj-base-d .
      end.
      when 3 then do:
        UNDERLINE STREAM PrnLibStream
        sj-goods.b-code
        sj-goods.artic
        sj-goods.name
        sj-adv.qnty
        sj-adv.brutto-sum
        sj-adv.brutto-sum-r
        sj-adv.discnt-sum
        pcnt
        sj-adv.netto-sum
        sj-adv.netto-sum-r
        with FRAME sj-full-d .
        DISPLAY STREAM PrnLibStream
        (if Shrs-seller-cashier = 'Cashier'
        then substitute("ч-&1", (ACCUM SUB-TOTAL BY (sj-goods.saleman) sj-adv.num-docs))
        else '':U) @ sj-goods.b-code
        (if Shrs-seller-cashier = 'Cashier'
        then substitute("стр-&1", (ACCUM SUB-TOTAL BY (sj-goods.saleman) sj-adv.num-lines))
        else '':U)  @ sj-goods.artic
        string(  v-seller-cashier-1 + entry(1, sj-goods.saleman , chr(4))) @ sj-goods.name
        v-salesman-name @ sj-goods.prod-name
        ACCUM SUB-TOTAL BY sj-goods.saleman sj-adv.qnty    @ sj-adv.qnty
        ACCUM SUB-TOTAL BY sj-goods.saleman sj-adv.brutto-sum  @ sj-adv.brutto-sum
        ACCUM SUB-TOTAL BY sj-goods.saleman sj-adv.brutto-sum-r @ sj-adv.brutto-sum-r
        ACCUM SUB-TOTAL BY sj-goods.saleman sj-adv.discnt-sum @ sj-adv.discnt-sum
        (IF (ACCUM SUB-TOTAL BY sj-goods.saleman sj-adv.qnty) <> 0
        THEN
        round( ( ACCUM SUB-TOTAL BY sj-goods.saleman sj-adv.discnt-sum ) /
                        ( ACCUM SUB-TOTAL BY sj-goods.saleman sj-adv.brutto-sum) * 100, 1 )
        ELSE 0 ) @ pcnt
        ACCUM SUB-TOTAL BY sj-goods.saleman sj-adv.netto-sum   @ sj-adv.netto-sum
        ACCUM SUB-TOTAL BY sj-goods.saleman sj-adv.netto-sum-r @ sj-adv.netto-sum-r
        with FRAME sj-full-d .
        DOWN STREAM PrnLibStream 1 with FRAME sj-full-d .
      end.
    END CASE .
    if not last(  sj-adv.discnt  ) then
      CASE my-Set_val_type :
        when 2 then
          UNDERLINE STREAM PrnLibStream
          sj-goods.b-code
          sj-goods.artic
          sj-goods.name
          sj-adv.qnty
          sj-adv.brutto-sum
          sj-adv.discnt-sum
          pcnt
          sj-adv.netto-sum
        with FRAME sj-base-d .
        when 3 then
          UNDERLINE STREAM PrnLibStream
          sj-goods.b-code
          sj-goods.artic
          sj-goods.name
          sj-adv.qnty
          sj-adv.brutto-sum
          sj-adv.brutto-sum-r
          sj-adv.discnt-sum
          pcnt
          sj-adv.netto-sum
          sj-adv.netto-sum-r
          with FRAME sj-full-d .
      END CASE .
      OneLinePrinted = TRUE .
    end.
define variable vss-include-info50 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
    if last-of( sj-goods.obj-attr ) AND ( ObjsQnty > 1 ) then do:
            CASE my-set_val_type :
                when 2 then do:
                        UNDERLINE STREAM PrnLibStream
                        sj-goods.name
                        sj-adv.qnty
                        sj-adv.brutto-sum
                        sj-adv.discnt-sum
                        pcnt
                        sj-adv.netto-sum
                        with FRAME sj-base .
                        DISPLAY STREAM PrnLibStream
                        string( "Итого " + sj-goods.obj-attr )
                            @ sj-goods.name
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.qnty    @ sj-adv.qnty
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.brutto-sum
                            @ sj-adv.brutto-sum
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.discnt-sum
                            @ sj-adv.discnt-sum
                        round( ( ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.discnt-sum ) /
                            ( ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.brutto-sum ) * 100 , 1 )
                            @ pcnt
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.netto-sum
                            @ sj-adv.netto-sum
                        with FRAME sj-base .
                        DOWN STREAM PrnLibStream 1 with FRAME sj-base .
                    end.
                when 3 then do:
                        UNDERLINE STREAM PrnLibStream
                        sj-goods.name
                        sj-adv.qnty
                        sj-adv.brutto-sum
                        sj-adv.brutto-sum-r
                        sj-adv.discnt-sum
                        pcnt
                        sj-adv.netto-sum
                        sj-adv.netto-sum-r
                        with FRAME sj-full .
                        DISPLAY STREAM PrnLibStream
                        string( "Итого " + sj-goods.obj-attr )
                            @ sj-goods.name
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.qnty    @ sj-adv.qnty
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.brutto-sum  @ sj-adv.brutto-sum
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.brutto-sum-r @ sj-adv.brutto-sum-r
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.discnt-sum      @ sj-adv.discnt-sum
                        round( ( ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.discnt-sum ) /
                                    ( ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.brutto-sum) * 100 , 1 )
                                        @ pcnt
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.netto-sum   @ sj-adv.netto-sum
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.netto-sum-r @ sj-adv.netto-sum-r
                        with FRAME sj-full .
                        DOWN STREAM PrnLibStream 1 with FRAME sj-full .
                    end.
            END CASE .
            if NOT last(  sj-adv.price ) then
                CASE my-set_val_type :
                    when 2 then
                        UNDERLINE STREAM PrnLibStream
                        sj-goods.name
                        sj-adv.qnty
                        sj-adv.brutto-sum
                        sj-adv.discnt-sum
                        pcnt
                        sj-adv.netto-sum
                        with FRAME sj-base .
                    when 3 then
                        UNDERLINE STREAM PrnLibStream
                        sj-goods.name
                        sj-adv.qnty
                        sj-adv.brutto-sum
                        sj-adv.brutto-sum-r
                        sj-adv.discnt-sum
                        pcnt
                        sj-adv.netto-sum
                        sj-adv.netto-sum-r
                        with FRAME sj-full .
                END CASE .
            OneLinePrinted = TRUE .
        end.
    if last(  sj-adv.discnt  ) then do:
      if v-curr-r-b = 'base':U and my-Set_val_type = 3 then  do:
        if OneLinePrinted then
        PUT STREAM PrnLibStream Line  SKIP.
      end.
      else do:
        if OneLinePrinted then
        PUT STREAM PrnLibStream Line format ("X(" + string(196) + ")")  SKIP.
      end.
      if ( line-counter(PrnLibStream) + 7 ) > page-size(PrnLibStream) then page stream PrnLibStream .
      CASE my-Set_val_type :
        when 2 then do:
          DISPLAY STREAM PrnLibStream
          substitute("ИТОГО ч- &1", v-num-chk) @ sj-goods.name
          ACCUM TOTAL sj-adv.qnty @ sj-adv.qnty
          ACCUM TOTAL sj-adv.brutto-sum @ sj-adv.brutto-sum
          ACCUM TOTAL sj-adv.discnt-sum @ sj-adv.discnt-sum
          (IF (ACCUM TOTAL sj-adv.qnty) <> 0
          THEN
          round( ( ACCUM TOTAL sj-adv.discnt-sum ) /
          ( ACCUM TOTAL sj-adv.brutto-sum ) * 100 , 1 )
          ELSE 0) @ pcnt
          ACCUM TOTAL sj-adv.netto-sum @ sj-adv.netto-sum
          with FRAME sj-base-d .
          DOWN STREAM PrnLibStream 1 with FRAME sj-base-d .
          DISPLAY STREAM PrnLibStream
          (string(round((ACCUM TOTAL sj-adv.qnty) / v-num-chk, 2)) + "/ч")  @ sj-adv.qnty
          with FRAME sj-base-d .
          DOWN STREAM PrnLibStream 1 with FRAME sj-base-d .
          UNDERLINE STREAM PrnLibStream
          sj-goods.b-code
          sj-goods.artic
          sj-goods.name
          sj-adv.qnty
          sj-adv.brutto-sum
          sj-adv.discnt-sum
          pcnt
          sj-adv.netto-sum
          with FRAME sj-base-d .
        end.
        when 3 then do:
        DISPLAY STREAM PrnLibStream
        substitute("ИТОГО ч- &1", v-num-chk) @ sj-goods.name
        ACCUM TOTAL sj-adv.qnty @ sj-adv.qnty
        ACCUM TOTAL sj-adv.brutto-sum @ sj-adv.brutto-sum
        ACCUM TOTAL sj-adv.brutto-sum-r @ sj-adv.brutto-sum-r
        ACCUM TOTAL sj-adv.discnt-sum @ sj-adv.discnt-sum
        (IF (ACCUM TOTAL sj-adv.qnty) <> 0
        THEN
        round( ( ACCUM TOTAL sj-adv.discnt-sum ) /
                      ( ACCUM TOTAL sj-adv.brutto-sum ) * 100 , 1 )
        ELSE 0) @ pcnt
        ACCUM TOTAL sj-adv.netto-sum @ sj-adv.netto-sum
        ACCUM TOTAL sj-adv.netto-sum-r @ sj-adv.netto-sum-r
        with FRAME sj-full-d .
        DOWN STREAM PrnLibStream 1 with FRAME sj-full-d .
        DISPLAY STREAM PrnLibStream
        (string(round((ACCUM TOTAL sj-adv.qnty) / v-num-chk, 2)) + "/ч")  @ sj-adv.qnty
        with FRAME sj-full-d .
        DOWN STREAM PrnLibStream 1 with FRAME sj-full-d .
        UNDERLINE STREAM PrnLibStream
        sj-goods.b-code
        sj-goods.artic
        sj-goods.name
        sj-adv.qnty
        sj-adv.brutto-sum
        sj-adv.brutto-sum-r
        sj-adv.discnt-sum
        pcnt
        sj-adv.netto-sum
        sj-adv.netto-sum-r
        with FRAME sj-full-d .
      end.
    END CASE .
    if ObjsQnty = 1 then
    PUT STREAM PrnLibStream
    " " SKIP(1) space(10)
    "Директор ______________" format "X(50)"
    "Кассир ___________________" format "X(50)" SKIP .
  end.
    END .
  end.
end.
else do:
  if SHBySalers then do:
    FOR EACH sj-goods NO-LOCK,
        EACH sj-adv NO-LOCK WHERE
              sj-adv.obj-attr = sj-goods.obj-attr AND
              sj-adv.b-code = sj-goods.b-code AND
              sj-adv.saleman = sj-goods.saleman
        BREAK BY sj-goods.obj-attr
              BY sj-goods.saleman
              BY sj-goods.b-code
              BY sj-adv.price
              BY sj-adv.discnt
              :
define variable vss-include-info51 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if first( sj-goods.obj-attr ) then do:
  if v-curr-r-b = 'base':U then do:
                        if my-set_val_type = 2  then
                            DOWN STREAM PrnLibStream 1 with FRAME sj-base-d .
                        else
                            DOWN STREAM PrnLibStream 1 with FRAME sj-full-d .
  end.
  else do:
                            DOWN STREAM PrnLibStream 1 with FRAME sj-base-d .
  end.
end.
                if first-of( sj-goods.obj-attr ) AND ( ObjsQnty > 1 ) then  do:
                        assign
                        strbuf1 = substr( sj-goods.obj-attr, 1, 3 )
                        intbuf1 = integer( substr( sj-goods.obj-attr, 4 ) ) .
                        FIND FIRST cli-obj WHERE
                                   cli-obj.obj-type = strbuf1 AND
                                   cli-obj.obj-code = intbuf1 NO-LOCK .
                        PUT STREAM PrnLibStream
                        cli-obj.obj-name format "x(120)" SKIP.
if v-curr-r-b = 'base':U then do:
                        if my-set_val_type = 2  then
                        UNDERLINE STREAM PrnLibStream
                        sj-goods.artic
                        sj-goods.name
                        with FRAME sj-base-d .
                        else
                        UNDERLINE STREAM PrnLibStream
                        sj-goods.artic
                        sj-goods.name
                        with FRAME sj-full-d .
end.
else do:
                        UNDERLINE STREAM PrnLibStream
                        sj-goods.artic
                        sj-goods.name
                        with FRAME sj-base-d .
end.
                    end.
define variable vss-include-info52 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
    ACCUMULATE
    sj-adv.qnty (TOTAL)
    sj-adv.qnty-2 (TOTAL)
    sj-adv.qnty-3 (TOTAL)
    sj-adv.brutto-sum (TOTAL)
    sj-adv.discnt-sum (TOTAL)
    sj-adv.netto-sum (TOTAL)
    sj-adv.brutto-sum-r (TOTAL)
    sj-adv.netto-sum-r (TOTAL)
    sj-adv.num-docs (TOTAL)
    sj-adv.num-lines (TOTAL)
    sj-adv.qnty ( SUB-TOTAL BY sj-goods.obj-attr )
    sj-adv.qnty-2 ( SUB-TOTAL BY sj-goods.obj-attr )
    sj-adv.qnty-3 ( SUB-TOTAL BY sj-goods.obj-attr )
    sj-adv.brutto-sum ( SUB-TOTAL BY sj-goods.obj-attr )
    sj-adv.discnt-sum ( SUB-TOTAL BY sj-goods.obj-attr )
    sj-adv.netto-sum ( SUB-TOTAL BY sj-goods.obj-attr )
    sj-adv.brutto-sum-r ( SUB-TOTAL BY sj-goods.obj-attr )
    sj-adv.netto-sum-r ( SUB-TOTAL BY sj-goods.obj-attr )
    sj-adv.qnty ( SUB-TOTAL BY sj-adv.discnt )
    sj-adv.qnty-2 ( SUB-TOTAL BY sj-adv.discnt )
    sj-adv.qnty-3 ( SUB-TOTAL BY sj-adv.discnt )
    sj-adv.brutto-sum ( SUB-TOTAL BY sj-adv.discnt )
    sj-adv.discnt-sum ( SUB-TOTAL BY sj-adv.discnt )
    sj-adv.netto-sum ( SUB-TOTAL BY sj-adv.discnt )
    sj-adv.brutto-sum-r ( SUB-TOTAL BY sj-adv.discnt )
    sj-adv.netto-sum-r ( SUB-TOTAL BY sj-adv.discnt )
    sj-adv.qnty ( SUB-TOTAL BY sj-goods.saleman )
    sj-adv.qnty-2 ( SUB-TOTAL BY sj-goods.saleman )
    sj-adv.qnty-3 ( SUB-TOTAL BY sj-goods.saleman )
    sj-adv.brutto-sum ( SUB-TOTAL BY sj-goods.saleman )
    sj-adv.discnt-sum ( SUB-TOTAL BY sj-goods.saleman )
    sj-adv.netto-sum ( SUB-TOTAL BY sj-goods.saleman )
    sj-adv.brutto-sum-r ( SUB-TOTAL BY sj-goods.saleman )
    sj-adv.netto-sum-r ( SUB-TOTAL BY sj-goods.saleman )
    sj-adv.num-docs (SUB-TOTAL BY sj-goods.saleman )
    sj-adv.num-lines (SUB-TOTAL BY sj-goods.saleman )
    .
if sj-goods.twounit = 0 then do:
  if last-of ( sj-adv.discnt ) AND SHRs-by <> 0 then do:
    namebuf1 = get-strokes(buffer sj-goods, 18, 21,
                           input-output namebuf1,
                           input-output namebuf2,
                           input-output prodbuf1,
                           input-output prodbuf2).
    CASE my-Set_val_type :
    when 2 then  do:
      DISPLAY STREAM PrnLibStream
      sj-goods.b-code
      sj-goods.artic
      namebuf1 @ sj-goods.name
      prodbuf1 @ sj-goods.prod-name
      ACCUM SUB-TOTAL BY sj-adv.discnt sj-adv.qnty @ sj-adv.qnty
      sj-adv.price
      ACCUM SUB-TOTAL BY sj-adv.discnt sj-adv.brutto-sum @ sj-adv.brutto-sum
      sj-adv.discnt
      ACCUM SUB-TOTAL BY sj-adv.discnt sj-adv.discnt-sum @ sj-adv.discnt-sum
      (IF (ACCUM SUB-TOTAL BY sj-adv.discnt sj-adv.qnty) <> 0
      THEN
      round( ( ACCUM SUB-TOTAL BY sj-adv.discnt sj-adv.discnt-sum ) /
      ( ACCUM SUB-TOTAL BY sj-adv.discnt sj-adv.brutto-sum ) * 100 , 1 )
      else 0)  @ pcnt
      ACCUM SUB-TOTAL BY sj-adv.discnt sj-adv.netto-sum @ sj-adv.netto-sum
      with FRAME sj-base-d .
      DOWN STREAM PrnLibStream 1 with FRAME sj-base-d .
     end.
     when 3 then do:
      DISPLAY STREAM PrnLibStream
      sj-goods.b-code
      sj-goods.artic
      namebuf1 @ sj-goods.name
      prodbuf1 @ sj-goods.prod-name
      ACCUM SUB-TOTAL BY  sj-adv.discnt  sj-adv.qnty @ sj-adv.qnty
      sj-adv.price
      ACCUM SUB-TOTAL BY  sj-adv.discnt  sj-adv.brutto-sum @ sj-adv.brutto-sum
      ACCUM SUB-TOTAL BY  sj-adv.discnt  sj-adv.brutto-sum-r @ sj-adv.brutto-sum-r
      sj-adv.discnt
      ACCUM SUB-TOTAL BY  sj-adv.discnt  sj-adv.discnt-sum @ sj-adv.discnt-sum
      (IF (ACCUM SUB-TOTAL BY  sj-adv.discnt  sj-adv.qnty) <> 0
      THEN
      round( ( ACCUM SUB-TOTAL BY  sj-adv.discnt  sj-adv.discnt-sum ) /
      ( ACCUM SUB-TOTAL BY  sj-adv.discnt  sj-adv.brutto-sum ) * 100, 1 )
      ELSE 0 ) @ pcnt
      ACCUM SUB-TOTAL BY  sj-adv.discnt  sj-adv.netto-sum @ sj-adv.netto-sum
      ACCUM SUB-TOTAL BY  sj-adv.discnt  sj-adv.netto-sum-r @ sj-adv.netto-sum-r
      with FRAME sj-full-d .
      DOWN STREAM PrnLibStream 1 with FRAME sj-full-d .
     end.
     END CASE .
     if ( namebuf2 <> "" ) OR ( prodbuf2 <> "" ) then
     CASE my-Set_val_type :
       when 2 then  do:
        DISPLAY STREAM PrnLibStream
        namebuf2 @ sj-goods.name
        prodbuf2 @ sj-goods.prod-name
        with FRAME sj-base-d .
        DOWN STREAM PrnLibStream 1 with FRAME sj-base-d .
      end.
      when 3 then do:
        DISPLAY STREAM PrnLibStream
        namebuf2 @ sj-goods.name
        prodbuf2 @ sj-goods.prod-name
        with FRAME sj-full-d .
        DOWN STREAM PrnLibStream 1 with FRAME sj-full-d .
      end.
    END CASE .
    OneLinePrinted = TRUE .
  end .
end.
  if last-of( sj-goods.saleman ) AND SHBySalers then do:
    v-salesman-name = '':U.
    if entry(2, sj-goods.saleman, chr(4)) <> string(0) then do:
      find first buf_saleman where
                buf_saleman.obj-type = 'чел':U
            AND buf_saleman.obj-code = integer(entry(2, sj-goods.saleman, chr(4))) no-error .
      if not available buf_saleman then do:
        v-salesman-name = '':U.
      end.
      else do:
        v-salesman-name = buf_saleman.obj-name.
      end.
    end.
    CASE my-Set_val_type :
      when 2 then  do:
        UNDERLINE STREAM PrnLibStream
        sj-goods.b-code
        sj-goods.artic
        sj-goods.name
        sj-adv.qnty
        sj-adv.brutto-sum
        sj-adv.discnt-sum
        pcnt
        sj-adv.netto-sum
        with FRAME sj-base-d .
        DISPLAY STREAM PrnLibStream
        (if Shrs-seller-cashier = 'Cashier'
        then substitute("ч-&1", ( ACCUM SUB-TOTAL BY sj-goods.saleman sj-adv.num-docs))
        else '':U)  @ sj-goods.b-code
        (if Shrs-seller-cashier = 'Cashier'
        then substitute("стр-&1", (ACCUM SUB-TOTAL BY sj-goods.saleman sj-adv.num-lines))
        else '':U) @ sj-goods.artic
        string(  v-seller-cashier-1 + entry(1, sj-goods.saleman , chr(4)) )  @ sj-goods.name
        v-salesman-name @ sj-goods.prod-name
        ACCUM SUB-TOTAL BY sj-goods.saleman sj-adv.qnty    @ sj-adv.qnty
        ACCUM SUB-TOTAL BY sj-goods.saleman sj-adv.brutto-sum      @ sj-adv.brutto-sum
        ACCUM SUB-TOTAL BY sj-goods.saleman sj-adv.discnt-sum      @ sj-adv.discnt-sum
        (IF (ACCUM SUB-TOTAL BY sj-goods.saleman sj-adv.qnty) <> 0
        THEN
        round( ( ACCUM SUB-TOTAL BY sj-goods.saleman sj-adv.discnt-sum ) /
        ( ACCUM SUB-TOTAL BY sj-goods.saleman sj-adv.brutto-sum) * 100 , 1 )
        ELSE 0 ) @ pcnt
        ACCUM SUB-TOTAL BY sj-goods.saleman sj-adv.netto-sum   @ sj-adv.netto-sum
        with FRAME sj-base-d .
        DOWN STREAM PrnLibStream 1 with FRAME sj-base-d .
      end.
      when 3 then do:
        UNDERLINE STREAM PrnLibStream
        sj-goods.b-code
        sj-goods.artic
        sj-goods.name
        sj-adv.qnty
        sj-adv.brutto-sum
        sj-adv.brutto-sum-r
        sj-adv.discnt-sum
        pcnt
        sj-adv.netto-sum
        sj-adv.netto-sum-r
        with FRAME sj-full-d .
        DISPLAY STREAM PrnLibStream
        (if Shrs-seller-cashier = 'Cashier'
        then substitute("ч-&1", (ACCUM SUB-TOTAL BY (sj-goods.saleman) sj-adv.num-docs))
        else '':U) @ sj-goods.b-code
        (if Shrs-seller-cashier = 'Cashier'
        then substitute("стр-&1", (ACCUM SUB-TOTAL BY (sj-goods.saleman) sj-adv.num-lines))
        else '':U)  @ sj-goods.artic
        string(  v-seller-cashier-1 + entry(1, sj-goods.saleman , chr(4))) @ sj-goods.name
        v-salesman-name @ sj-goods.prod-name
        ACCUM SUB-TOTAL BY sj-goods.saleman sj-adv.qnty    @ sj-adv.qnty
        ACCUM SUB-TOTAL BY sj-goods.saleman sj-adv.brutto-sum  @ sj-adv.brutto-sum
        ACCUM SUB-TOTAL BY sj-goods.saleman sj-adv.brutto-sum-r @ sj-adv.brutto-sum-r
        ACCUM SUB-TOTAL BY sj-goods.saleman sj-adv.discnt-sum @ sj-adv.discnt-sum
        (IF (ACCUM SUB-TOTAL BY sj-goods.saleman sj-adv.qnty) <> 0
        THEN
        round( ( ACCUM SUB-TOTAL BY sj-goods.saleman sj-adv.discnt-sum ) /
                        ( ACCUM SUB-TOTAL BY sj-goods.saleman sj-adv.brutto-sum) * 100, 1 )
        ELSE 0 ) @ pcnt
        ACCUM SUB-TOTAL BY sj-goods.saleman sj-adv.netto-sum   @ sj-adv.netto-sum
        ACCUM SUB-TOTAL BY sj-goods.saleman sj-adv.netto-sum-r @ sj-adv.netto-sum-r
        with FRAME sj-full-d .
        DOWN STREAM PrnLibStream 1 with FRAME sj-full-d .
      end.
    END CASE .
    if not last(  sj-adv.discnt  ) then
      CASE my-Set_val_type :
        when 2 then
          UNDERLINE STREAM PrnLibStream
          sj-goods.b-code
          sj-goods.artic
          sj-goods.name
          sj-adv.qnty
          sj-adv.brutto-sum
          sj-adv.discnt-sum
          pcnt
          sj-adv.netto-sum
        with FRAME sj-base-d .
        when 3 then
          UNDERLINE STREAM PrnLibStream
          sj-goods.b-code
          sj-goods.artic
          sj-goods.name
          sj-adv.qnty
          sj-adv.brutto-sum
          sj-adv.brutto-sum-r
          sj-adv.discnt-sum
          pcnt
          sj-adv.netto-sum
          sj-adv.netto-sum-r
          with FRAME sj-full-d .
      END CASE .
      OneLinePrinted = TRUE .
    end.
define variable vss-include-info53 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
    if last-of( sj-goods.obj-attr ) AND ( ObjsQnty > 1 ) then do:
            CASE my-set_val_type :
                when 2 then do:
                        UNDERLINE STREAM PrnLibStream
                        sj-goods.name
                        sj-adv.qnty
                        sj-adv.brutto-sum
                        sj-adv.discnt-sum
                        pcnt
                        sj-adv.netto-sum
                        with FRAME sj-base .
                        DISPLAY STREAM PrnLibStream
                        string( "Итого " + sj-goods.obj-attr )
                            @ sj-goods.name
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.qnty    @ sj-adv.qnty
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.brutto-sum
                            @ sj-adv.brutto-sum
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.discnt-sum
                            @ sj-adv.discnt-sum
                        round( ( ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.discnt-sum ) /
                            ( ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.brutto-sum ) * 100 , 1 )
                            @ pcnt
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.netto-sum
                            @ sj-adv.netto-sum
                        with FRAME sj-base .
                        DOWN STREAM PrnLibStream 1 with FRAME sj-base .
                    end.
                when 3 then do:
                        UNDERLINE STREAM PrnLibStream
                        sj-goods.name
                        sj-adv.qnty
                        sj-adv.brutto-sum
                        sj-adv.brutto-sum-r
                        sj-adv.discnt-sum
                        pcnt
                        sj-adv.netto-sum
                        sj-adv.netto-sum-r
                        with FRAME sj-full .
                        DISPLAY STREAM PrnLibStream
                        string( "Итого " + sj-goods.obj-attr )
                            @ sj-goods.name
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.qnty    @ sj-adv.qnty
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.brutto-sum  @ sj-adv.brutto-sum
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.brutto-sum-r @ sj-adv.brutto-sum-r
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.discnt-sum      @ sj-adv.discnt-sum
                        round( ( ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.discnt-sum ) /
                                    ( ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.brutto-sum) * 100 , 1 )
                                        @ pcnt
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.netto-sum   @ sj-adv.netto-sum
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.netto-sum-r @ sj-adv.netto-sum-r
                        with FRAME sj-full .
                        DOWN STREAM PrnLibStream 1 with FRAME sj-full .
                    end.
            END CASE .
            if NOT last(  sj-adv.price ) then
                CASE my-set_val_type :
                    when 2 then
                        UNDERLINE STREAM PrnLibStream
                        sj-goods.name
                        sj-adv.qnty
                        sj-adv.brutto-sum
                        sj-adv.discnt-sum
                        pcnt
                        sj-adv.netto-sum
                        with FRAME sj-base .
                    when 3 then
                        UNDERLINE STREAM PrnLibStream
                        sj-goods.name
                        sj-adv.qnty
                        sj-adv.brutto-sum
                        sj-adv.brutto-sum-r
                        sj-adv.discnt-sum
                        pcnt
                        sj-adv.netto-sum
                        sj-adv.netto-sum-r
                        with FRAME sj-full .
                END CASE .
            OneLinePrinted = TRUE .
        end.
    if last(  sj-adv.discnt  ) then do:
      if v-curr-r-b = 'base':U and my-Set_val_type = 3 then  do:
        if OneLinePrinted then
        PUT STREAM PrnLibStream Line  SKIP.
      end.
      else do:
        if OneLinePrinted then
        PUT STREAM PrnLibStream Line format ("X(" + string(196) + ")")  SKIP.
      end.
      if ( line-counter(PrnLibStream) + 7 ) > page-size(PrnLibStream) then page stream PrnLibStream .
      CASE my-Set_val_type :
        when 2 then do:
          DISPLAY STREAM PrnLibStream
          substitute("ИТОГО ч- &1", v-num-chk) @ sj-goods.name
          ACCUM TOTAL sj-adv.qnty @ sj-adv.qnty
          ACCUM TOTAL sj-adv.brutto-sum @ sj-adv.brutto-sum
          ACCUM TOTAL sj-adv.discnt-sum @ sj-adv.discnt-sum
          (IF (ACCUM TOTAL sj-adv.qnty) <> 0
          THEN
          round( ( ACCUM TOTAL sj-adv.discnt-sum ) /
          ( ACCUM TOTAL sj-adv.brutto-sum ) * 100 , 1 )
          ELSE 0) @ pcnt
          ACCUM TOTAL sj-adv.netto-sum @ sj-adv.netto-sum
          with FRAME sj-base-d .
          DOWN STREAM PrnLibStream 1 with FRAME sj-base-d .
          DISPLAY STREAM PrnLibStream
          (string(round((ACCUM TOTAL sj-adv.qnty) / v-num-chk, 2)) + "/ч")  @ sj-adv.qnty
          with FRAME sj-base-d .
          DOWN STREAM PrnLibStream 1 with FRAME sj-base-d .
          UNDERLINE STREAM PrnLibStream
          sj-goods.b-code
          sj-goods.artic
          sj-goods.name
          sj-adv.qnty
          sj-adv.brutto-sum
          sj-adv.discnt-sum
          pcnt
          sj-adv.netto-sum
          with FRAME sj-base-d .
        end.
        when 3 then do:
        DISPLAY STREAM PrnLibStream
        substitute("ИТОГО ч- &1", v-num-chk) @ sj-goods.name
        ACCUM TOTAL sj-adv.qnty @ sj-adv.qnty
        ACCUM TOTAL sj-adv.brutto-sum @ sj-adv.brutto-sum
        ACCUM TOTAL sj-adv.brutto-sum-r @ sj-adv.brutto-sum-r
        ACCUM TOTAL sj-adv.discnt-sum @ sj-adv.discnt-sum
        (IF (ACCUM TOTAL sj-adv.qnty) <> 0
        THEN
        round( ( ACCUM TOTAL sj-adv.discnt-sum ) /
                      ( ACCUM TOTAL sj-adv.brutto-sum ) * 100 , 1 )
        ELSE 0) @ pcnt
        ACCUM TOTAL sj-adv.netto-sum @ sj-adv.netto-sum
        ACCUM TOTAL sj-adv.netto-sum-r @ sj-adv.netto-sum-r
        with FRAME sj-full-d .
        DOWN STREAM PrnLibStream 1 with FRAME sj-full-d .
        DISPLAY STREAM PrnLibStream
        (string(round((ACCUM TOTAL sj-adv.qnty) / v-num-chk, 2)) + "/ч")  @ sj-adv.qnty
        with FRAME sj-full-d .
        DOWN STREAM PrnLibStream 1 with FRAME sj-full-d .
        UNDERLINE STREAM PrnLibStream
        sj-goods.b-code
        sj-goods.artic
        sj-goods.name
        sj-adv.qnty
        sj-adv.brutto-sum
        sj-adv.brutto-sum-r
        sj-adv.discnt-sum
        pcnt
        sj-adv.netto-sum
        sj-adv.netto-sum-r
        with FRAME sj-full-d .
      end.
    END CASE .
    if ObjsQnty = 1 then
    PUT STREAM PrnLibStream
    " " SKIP(1) space(10)
    "Директор ______________" format "X(50)"
    "Кассир ___________________" format "X(50)" SKIP .
  end.
    END .
  end.
  else do:
    FOR EACH sj-goods NO-LOCK,
        EACH sj-adv NO-LOCK WHERE
             sj-adv.obj-attr = sj-goods.obj-attr AND
             sj-adv.b-code = sj-goods.b-code AND
             sj-adv.saleman = sj-goods.saleman
        BREAK BY sj-goods.obj-attr
              BY sj-goods.b-code
              BY sj-adv.price
              BY sj-adv.discnt
              BY sj-goods.saleman :
define variable vss-include-info54 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if first( sj-goods.obj-attr ) then do:
  if v-curr-r-b = 'base':U then do:
                        if my-set_val_type = 2  then
                            DOWN STREAM PrnLibStream 1 with FRAME sj-base-d .
                        else
                            DOWN STREAM PrnLibStream 1 with FRAME sj-full-d .
  end.
  else do:
                            DOWN STREAM PrnLibStream 1 with FRAME sj-base-d .
  end.
end.
                if first-of( sj-goods.obj-attr ) AND ( ObjsQnty > 1 ) then  do:
                        assign
                        strbuf1 = substr( sj-goods.obj-attr, 1, 3 )
                        intbuf1 = integer( substr( sj-goods.obj-attr, 4 ) ) .
                        FIND FIRST cli-obj WHERE
                                   cli-obj.obj-type = strbuf1 AND
                                   cli-obj.obj-code = intbuf1 NO-LOCK .
                        PUT STREAM PrnLibStream
                        cli-obj.obj-name format "x(120)" SKIP.
if v-curr-r-b = 'base':U then do:
                        if my-set_val_type = 2  then
                        UNDERLINE STREAM PrnLibStream
                        sj-goods.artic
                        sj-goods.name
                        with FRAME sj-base-d .
                        else
                        UNDERLINE STREAM PrnLibStream
                        sj-goods.artic
                        sj-goods.name
                        with FRAME sj-full-d .
end.
else do:
                        UNDERLINE STREAM PrnLibStream
                        sj-goods.artic
                        sj-goods.name
                        with FRAME sj-base-d .
end.
                    end.
define variable vss-include-info55 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
    ACCUMULATE
    sj-adv.qnty (TOTAL)
    sj-adv.qnty-2 (TOTAL)
    sj-adv.qnty-3 (TOTAL)
    sj-adv.brutto-sum (TOTAL)
    sj-adv.discnt-sum (TOTAL)
    sj-adv.netto-sum (TOTAL)
    sj-adv.brutto-sum-r (TOTAL)
    sj-adv.netto-sum-r (TOTAL)
    sj-adv.num-docs (TOTAL)
    sj-adv.num-lines (TOTAL)
    sj-adv.qnty ( SUB-TOTAL BY sj-goods.obj-attr )
    sj-adv.qnty-2 ( SUB-TOTAL BY sj-goods.obj-attr )
    sj-adv.qnty-3 ( SUB-TOTAL BY sj-goods.obj-attr )
    sj-adv.brutto-sum ( SUB-TOTAL BY sj-goods.obj-attr )
    sj-adv.discnt-sum ( SUB-TOTAL BY sj-goods.obj-attr )
    sj-adv.netto-sum ( SUB-TOTAL BY sj-goods.obj-attr )
    sj-adv.brutto-sum-r ( SUB-TOTAL BY sj-goods.obj-attr )
    sj-adv.netto-sum-r ( SUB-TOTAL BY sj-goods.obj-attr )
    sj-adv.qnty ( SUB-TOTAL BY sj-adv.discnt )
    sj-adv.qnty-2 ( SUB-TOTAL BY sj-adv.discnt )
    sj-adv.qnty-3 ( SUB-TOTAL BY sj-adv.discnt )
    sj-adv.brutto-sum ( SUB-TOTAL BY sj-adv.discnt )
    sj-adv.discnt-sum ( SUB-TOTAL BY sj-adv.discnt )
    sj-adv.netto-sum ( SUB-TOTAL BY sj-adv.discnt )
    sj-adv.brutto-sum-r ( SUB-TOTAL BY sj-adv.discnt )
    sj-adv.netto-sum-r ( SUB-TOTAL BY sj-adv.discnt )
    sj-adv.qnty ( SUB-TOTAL BY sj-goods.saleman )
    sj-adv.qnty-2 ( SUB-TOTAL BY sj-goods.saleman )
    sj-adv.qnty-3 ( SUB-TOTAL BY sj-goods.saleman )
    sj-adv.brutto-sum ( SUB-TOTAL BY sj-goods.saleman )
    sj-adv.discnt-sum ( SUB-TOTAL BY sj-goods.saleman )
    sj-adv.netto-sum ( SUB-TOTAL BY sj-goods.saleman )
    sj-adv.brutto-sum-r ( SUB-TOTAL BY sj-goods.saleman )
    sj-adv.netto-sum-r ( SUB-TOTAL BY sj-goods.saleman )
    sj-adv.num-docs (SUB-TOTAL BY sj-goods.saleman )
    sj-adv.num-lines (SUB-TOTAL BY sj-goods.saleman )
    .
if sj-goods.twounit = 0 then do:
  if last-of ( sj-adv.discnt ) AND SHRs-by <> 0 then do:
    namebuf1 = get-strokes(buffer sj-goods, 18, 21,
                           input-output namebuf1,
                           input-output namebuf2,
                           input-output prodbuf1,
                           input-output prodbuf2).
    CASE my-Set_val_type :
    when 2 then  do:
      DISPLAY STREAM PrnLibStream
      sj-goods.b-code
      sj-goods.artic
      namebuf1 @ sj-goods.name
      prodbuf1 @ sj-goods.prod-name
      ACCUM SUB-TOTAL BY sj-adv.discnt sj-adv.qnty @ sj-adv.qnty
      sj-adv.price
      ACCUM SUB-TOTAL BY sj-adv.discnt sj-adv.brutto-sum @ sj-adv.brutto-sum
      sj-adv.discnt
      ACCUM SUB-TOTAL BY sj-adv.discnt sj-adv.discnt-sum @ sj-adv.discnt-sum
      (IF (ACCUM SUB-TOTAL BY sj-adv.discnt sj-adv.qnty) <> 0
      THEN
      round( ( ACCUM SUB-TOTAL BY sj-adv.discnt sj-adv.discnt-sum ) /
      ( ACCUM SUB-TOTAL BY sj-adv.discnt sj-adv.brutto-sum ) * 100 , 1 )
      else 0)  @ pcnt
      ACCUM SUB-TOTAL BY sj-adv.discnt sj-adv.netto-sum @ sj-adv.netto-sum
      with FRAME sj-base-d .
      DOWN STREAM PrnLibStream 1 with FRAME sj-base-d .
     end.
     when 3 then do:
      DISPLAY STREAM PrnLibStream
      sj-goods.b-code
      sj-goods.artic
      namebuf1 @ sj-goods.name
      prodbuf1 @ sj-goods.prod-name
      ACCUM SUB-TOTAL BY  sj-adv.discnt  sj-adv.qnty @ sj-adv.qnty
      sj-adv.price
      ACCUM SUB-TOTAL BY  sj-adv.discnt  sj-adv.brutto-sum @ sj-adv.brutto-sum
      ACCUM SUB-TOTAL BY  sj-adv.discnt  sj-adv.brutto-sum-r @ sj-adv.brutto-sum-r
      sj-adv.discnt
      ACCUM SUB-TOTAL BY  sj-adv.discnt  sj-adv.discnt-sum @ sj-adv.discnt-sum
      (IF (ACCUM SUB-TOTAL BY  sj-adv.discnt  sj-adv.qnty) <> 0
      THEN
      round( ( ACCUM SUB-TOTAL BY  sj-adv.discnt  sj-adv.discnt-sum ) /
      ( ACCUM SUB-TOTAL BY  sj-adv.discnt  sj-adv.brutto-sum ) * 100, 1 )
      ELSE 0 ) @ pcnt
      ACCUM SUB-TOTAL BY  sj-adv.discnt  sj-adv.netto-sum @ sj-adv.netto-sum
      ACCUM SUB-TOTAL BY  sj-adv.discnt  sj-adv.netto-sum-r @ sj-adv.netto-sum-r
      with FRAME sj-full-d .
      DOWN STREAM PrnLibStream 1 with FRAME sj-full-d .
     end.
     END CASE .
     if ( namebuf2 <> "" ) OR ( prodbuf2 <> "" ) then
     CASE my-Set_val_type :
       when 2 then  do:
        DISPLAY STREAM PrnLibStream
        namebuf2 @ sj-goods.name
        prodbuf2 @ sj-goods.prod-name
        with FRAME sj-base-d .
        DOWN STREAM PrnLibStream 1 with FRAME sj-base-d .
      end.
      when 3 then do:
        DISPLAY STREAM PrnLibStream
        namebuf2 @ sj-goods.name
        prodbuf2 @ sj-goods.prod-name
        with FRAME sj-full-d .
        DOWN STREAM PrnLibStream 1 with FRAME sj-full-d .
      end.
    END CASE .
    OneLinePrinted = TRUE .
  end .
end.
  if last-of( sj-goods.saleman ) AND SHBySalers then do:
    v-salesman-name = '':U.
    if entry(2, sj-goods.saleman, chr(4)) <> string(0) then do:
      find first buf_saleman where
                buf_saleman.obj-type = 'чел':U
            AND buf_saleman.obj-code = integer(entry(2, sj-goods.saleman, chr(4))) no-error .
      if not available buf_saleman then do:
        v-salesman-name = '':U.
      end.
      else do:
        v-salesman-name = buf_saleman.obj-name.
      end.
    end.
    CASE my-Set_val_type :
      when 2 then  do:
        UNDERLINE STREAM PrnLibStream
        sj-goods.b-code
        sj-goods.artic
        sj-goods.name
        sj-adv.qnty
        sj-adv.brutto-sum
        sj-adv.discnt-sum
        pcnt
        sj-adv.netto-sum
        with FRAME sj-base-d .
        DISPLAY STREAM PrnLibStream
        (if Shrs-seller-cashier = 'Cashier'
        then substitute("ч-&1", ( ACCUM SUB-TOTAL BY sj-goods.saleman sj-adv.num-docs))
        else '':U)  @ sj-goods.b-code
        (if Shrs-seller-cashier = 'Cashier'
        then substitute("стр-&1", (ACCUM SUB-TOTAL BY sj-goods.saleman sj-adv.num-lines))
        else '':U) @ sj-goods.artic
        string(  v-seller-cashier-1 + entry(1, sj-goods.saleman , chr(4)) )  @ sj-goods.name
        v-salesman-name @ sj-goods.prod-name
        ACCUM SUB-TOTAL BY sj-goods.saleman sj-adv.qnty    @ sj-adv.qnty
        ACCUM SUB-TOTAL BY sj-goods.saleman sj-adv.brutto-sum      @ sj-adv.brutto-sum
        ACCUM SUB-TOTAL BY sj-goods.saleman sj-adv.discnt-sum      @ sj-adv.discnt-sum
        (IF (ACCUM SUB-TOTAL BY sj-goods.saleman sj-adv.qnty) <> 0
        THEN
        round( ( ACCUM SUB-TOTAL BY sj-goods.saleman sj-adv.discnt-sum ) /
        ( ACCUM SUB-TOTAL BY sj-goods.saleman sj-adv.brutto-sum) * 100 , 1 )
        ELSE 0 ) @ pcnt
        ACCUM SUB-TOTAL BY sj-goods.saleman sj-adv.netto-sum   @ sj-adv.netto-sum
        with FRAME sj-base-d .
        DOWN STREAM PrnLibStream 1 with FRAME sj-base-d .
      end.
      when 3 then do:
        UNDERLINE STREAM PrnLibStream
        sj-goods.b-code
        sj-goods.artic
        sj-goods.name
        sj-adv.qnty
        sj-adv.brutto-sum
        sj-adv.brutto-sum-r
        sj-adv.discnt-sum
        pcnt
        sj-adv.netto-sum
        sj-adv.netto-sum-r
        with FRAME sj-full-d .
        DISPLAY STREAM PrnLibStream
        (if Shrs-seller-cashier = 'Cashier'
        then substitute("ч-&1", (ACCUM SUB-TOTAL BY (sj-goods.saleman) sj-adv.num-docs))
        else '':U) @ sj-goods.b-code
        (if Shrs-seller-cashier = 'Cashier'
        then substitute("стр-&1", (ACCUM SUB-TOTAL BY (sj-goods.saleman) sj-adv.num-lines))
        else '':U)  @ sj-goods.artic
        string(  v-seller-cashier-1 + entry(1, sj-goods.saleman , chr(4))) @ sj-goods.name
        v-salesman-name @ sj-goods.prod-name
        ACCUM SUB-TOTAL BY sj-goods.saleman sj-adv.qnty    @ sj-adv.qnty
        ACCUM SUB-TOTAL BY sj-goods.saleman sj-adv.brutto-sum  @ sj-adv.brutto-sum
        ACCUM SUB-TOTAL BY sj-goods.saleman sj-adv.brutto-sum-r @ sj-adv.brutto-sum-r
        ACCUM SUB-TOTAL BY sj-goods.saleman sj-adv.discnt-sum @ sj-adv.discnt-sum
        (IF (ACCUM SUB-TOTAL BY sj-goods.saleman sj-adv.qnty) <> 0
        THEN
        round( ( ACCUM SUB-TOTAL BY sj-goods.saleman sj-adv.discnt-sum ) /
                        ( ACCUM SUB-TOTAL BY sj-goods.saleman sj-adv.brutto-sum) * 100, 1 )
        ELSE 0 ) @ pcnt
        ACCUM SUB-TOTAL BY sj-goods.saleman sj-adv.netto-sum   @ sj-adv.netto-sum
        ACCUM SUB-TOTAL BY sj-goods.saleman sj-adv.netto-sum-r @ sj-adv.netto-sum-r
        with FRAME sj-full-d .
        DOWN STREAM PrnLibStream 1 with FRAME sj-full-d .
      end.
    END CASE .
    if not last(  sj-adv.discnt  ) then
      CASE my-Set_val_type :
        when 2 then
          UNDERLINE STREAM PrnLibStream
          sj-goods.b-code
          sj-goods.artic
          sj-goods.name
          sj-adv.qnty
          sj-adv.brutto-sum
          sj-adv.discnt-sum
          pcnt
          sj-adv.netto-sum
        with FRAME sj-base-d .
        when 3 then
          UNDERLINE STREAM PrnLibStream
          sj-goods.b-code
          sj-goods.artic
          sj-goods.name
          sj-adv.qnty
          sj-adv.brutto-sum
          sj-adv.brutto-sum-r
          sj-adv.discnt-sum
          pcnt
          sj-adv.netto-sum
          sj-adv.netto-sum-r
          with FRAME sj-full-d .
      END CASE .
      OneLinePrinted = TRUE .
    end.
define variable vss-include-info56 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
    if last-of( sj-goods.obj-attr ) AND ( ObjsQnty > 1 ) then do:
            CASE my-set_val_type :
                when 2 then do:
                        UNDERLINE STREAM PrnLibStream
                        sj-goods.name
                        sj-adv.qnty
                        sj-adv.brutto-sum
                        sj-adv.discnt-sum
                        pcnt
                        sj-adv.netto-sum
                        with FRAME sj-base .
                        DISPLAY STREAM PrnLibStream
                        string( "Итого " + sj-goods.obj-attr )
                            @ sj-goods.name
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.qnty    @ sj-adv.qnty
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.brutto-sum
                            @ sj-adv.brutto-sum
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.discnt-sum
                            @ sj-adv.discnt-sum
                        round( ( ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.discnt-sum ) /
                            ( ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.brutto-sum ) * 100 , 1 )
                            @ pcnt
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.netto-sum
                            @ sj-adv.netto-sum
                        with FRAME sj-base .
                        DOWN STREAM PrnLibStream 1 with FRAME sj-base .
                    end.
                when 3 then do:
                        UNDERLINE STREAM PrnLibStream
                        sj-goods.name
                        sj-adv.qnty
                        sj-adv.brutto-sum
                        sj-adv.brutto-sum-r
                        sj-adv.discnt-sum
                        pcnt
                        sj-adv.netto-sum
                        sj-adv.netto-sum-r
                        with FRAME sj-full .
                        DISPLAY STREAM PrnLibStream
                        string( "Итого " + sj-goods.obj-attr )
                            @ sj-goods.name
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.qnty    @ sj-adv.qnty
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.brutto-sum  @ sj-adv.brutto-sum
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.brutto-sum-r @ sj-adv.brutto-sum-r
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.discnt-sum      @ sj-adv.discnt-sum
                        round( ( ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.discnt-sum ) /
                                    ( ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.brutto-sum) * 100 , 1 )
                                        @ pcnt
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.netto-sum   @ sj-adv.netto-sum
                        ACCUM SUB-TOTAL BY sj-goods.obj-attr sj-adv.netto-sum-r @ sj-adv.netto-sum-r
                        with FRAME sj-full .
                        DOWN STREAM PrnLibStream 1 with FRAME sj-full .
                    end.
            END CASE .
            if NOT last(  sj-adv.price ) then
                CASE my-set_val_type :
                    when 2 then
                        UNDERLINE STREAM PrnLibStream
                        sj-goods.name
                        sj-adv.qnty
                        sj-adv.brutto-sum
                        sj-adv.discnt-sum
                        pcnt
                        sj-adv.netto-sum
                        with FRAME sj-base .
                    when 3 then
                        UNDERLINE STREAM PrnLibStream
                        sj-goods.name
                        sj-adv.qnty
                        sj-adv.brutto-sum
                        sj-adv.brutto-sum-r
                        sj-adv.discnt-sum
                        pcnt
                        sj-adv.netto-sum
                        sj-adv.netto-sum-r
                        with FRAME sj-full .
                END CASE .
            OneLinePrinted = TRUE .
        end.
    if last(  sj-adv.discnt  ) then do:
      if v-curr-r-b = 'base':U and my-Set_val_type = 3 then  do:
        if OneLinePrinted then
        PUT STREAM PrnLibStream Line  SKIP.
      end.
      else do:
        if OneLinePrinted then
        PUT STREAM PrnLibStream Line format ("X(" + string(196) + ")")  SKIP.
      end.
      if ( line-counter(PrnLibStream) + 7 ) > page-size(PrnLibStream) then page stream PrnLibStream .
      CASE my-Set_val_type :
        when 2 then do:
          DISPLAY STREAM PrnLibStream
          substitute("ИТОГО ч- &1", v-num-chk) @ sj-goods.name
          ACCUM TOTAL sj-adv.qnty @ sj-adv.qnty
          ACCUM TOTAL sj-adv.brutto-sum @ sj-adv.brutto-sum
          ACCUM TOTAL sj-adv.discnt-sum @ sj-adv.discnt-sum
          (IF (ACCUM TOTAL sj-adv.qnty) <> 0
          THEN
          round( ( ACCUM TOTAL sj-adv.discnt-sum ) /
          ( ACCUM TOTAL sj-adv.brutto-sum ) * 100 , 1 )
          ELSE 0) @ pcnt
          ACCUM TOTAL sj-adv.netto-sum @ sj-adv.netto-sum
          with FRAME sj-base-d .
          DOWN STREAM PrnLibStream 1 with FRAME sj-base-d .
          DISPLAY STREAM PrnLibStream
          (string(round((ACCUM TOTAL sj-adv.qnty) / v-num-chk, 2)) + "/ч")  @ sj-adv.qnty
          with FRAME sj-base-d .
          DOWN STREAM PrnLibStream 1 with FRAME sj-base-d .
          UNDERLINE STREAM PrnLibStream
          sj-goods.b-code
          sj-goods.artic
          sj-goods.name
          sj-adv.qnty
          sj-adv.brutto-sum
          sj-adv.discnt-sum
          pcnt
          sj-adv.netto-sum
          with FRAME sj-base-d .
        end.
        when 3 then do:
        DISPLAY STREAM PrnLibStream
        substitute("ИТОГО ч- &1", v-num-chk) @ sj-goods.name
        ACCUM TOTAL sj-adv.qnty @ sj-adv.qnty
        ACCUM TOTAL sj-adv.brutto-sum @ sj-adv.brutto-sum
        ACCUM TOTAL sj-adv.brutto-sum-r @ sj-adv.brutto-sum-r
        ACCUM TOTAL sj-adv.discnt-sum @ sj-adv.discnt-sum
        (IF (ACCUM TOTAL sj-adv.qnty) <> 0
        THEN
        round( ( ACCUM TOTAL sj-adv.discnt-sum ) /
                      ( ACCUM TOTAL sj-adv.brutto-sum ) * 100 , 1 )
        ELSE 0) @ pcnt
        ACCUM TOTAL sj-adv.netto-sum @ sj-adv.netto-sum
        ACCUM TOTAL sj-adv.netto-sum-r @ sj-adv.netto-sum-r
        with FRAME sj-full-d .
        DOWN STREAM PrnLibStream 1 with FRAME sj-full-d .
        DISPLAY STREAM PrnLibStream
        (string(round((ACCUM TOTAL sj-adv.qnty) / v-num-chk, 2)) + "/ч")  @ sj-adv.qnty
        with FRAME sj-full-d .
        DOWN STREAM PrnLibStream 1 with FRAME sj-full-d .
        UNDERLINE STREAM PrnLibStream
        sj-goods.b-code
        sj-goods.artic
        sj-goods.name
        sj-adv.qnty
        sj-adv.brutto-sum
        sj-adv.brutto-sum-r
        sj-adv.discnt-sum
        pcnt
        sj-adv.netto-sum
        sj-adv.netto-sum-r
        with FRAME sj-full-d .
      end.
    END CASE .
    if ObjsQnty = 1 then
    PUT STREAM PrnLibStream
    " " SKIP(1) space(10)
    "Директор ______________" format "X(50)"
    "Кассир ___________________" format "X(50)" SKIP .
  end.
    END .
  end.
end.
END PROCEDURE.
