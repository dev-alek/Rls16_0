using Progress.Lang.*.
using Ibs.Th.Gbl.ReportXml.
using Ibs.Th.Gbl.rep-out.
block-level on error undo, throw.
define input parameter parparentproc  as        handle  no-undo.
define input parameter det-mode       as        integer no-undo.
define input parameter det-by-obj     as    logical no-undo.
define input parameter dcard-mode         as    integer no-undo.
define input parameter fill-days      as    integer no-undo.
define variable vss-revision    as character no-undo init "$Revision: 6a63bd75f17f, 234, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Tue Jul 28 13:39:50 2015 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-activ.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-activ.p $":U .
define variable vss-description as character no-undo init "Отчет Итоги по дисконтным картам" .
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
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared temp-table dc-list no-undo like ub.dis-card
  field to-del as logical
  field order-num as integer
  field fdec as decimal
  field fint as integer
  field flog as logical
  field fchar as character
  index pi  is primary unique d-card
  index cn      card-num
  index cli cli-type cli-code
  index host-dscnt  emitent-host-code status_ d-pcnt
  index host-type  emitent-host-code type d-pcnt
  index oi order-num
  .
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  new shared  temp-table dc-list-hist no-undo
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
define variable flag-pokupki    as logical  no-undo init no.
define variable chk-find        as integer  no-undo init 0.
define variable flag-sleep      as integer  no-undo init 0.
define variable acc-count       as decimal  no-undo init 0.
define variable acc-totsum      as decimal  no-undo init 0.
define variable acc-discnt      as decimal  no-undo init 0.
define variable acc-averg       as decimal  no-undo init 0.
define variable Report          as class ReportXml no-undo.
define variable rep-out-unit    as class rep-out no-undo.
define variable xml_tmp         as character no-undo.
define variable xslt-path       as character no-undo.
define variable tmp-kli         as integer  no-undo init 0.
define variable tmp-purch       as decimal  no-undo init 0.
define variable tmp-summ        as decimal  no-undo init 0.
define variable tmp-disc        as decimal  no-undo init 0.
define variable tmp-aver        as decimal  no-undo init 0.
define variable objcts          as character no-undo.
define variable rowcnt          as integer no-undo.
define new shared temp-table   t-report-tmp no-undo
            field   cli-status  as integer      format ">9":u
            field   dcard-num   like ub.dis-card.d-card
            field   cli-name    like ub.clients.obj-name
            field   purch-count as integer      format ">>>>>9":u
            field   total-sum   as decimal      format ">>>>>>>>>9":u
            field   discount    as decimal      format ">>>>>>>>9":u
            field   averg       as decimal      format ">>>>>>>>9":u
            field   obj-code    like ub.clients.obj-code
            field   obj-type    like ub.clients.obj-type
            index   ind-prim  IS WORD-INDEX  dcard-num
            index   ind-status  cli-status
            index   ind-obj-code obj-code
            index   ind-obj-type obj-type
            .
function get-status returns character (input p-snum as integer):
    case p-snum:
        when 1 then return "Новые".
        when 2 then return "Новые (активные)".
        when 3 then return "Постоянные (активные)".
        when 4 then return "Спящие".
        when 5 then return "Отток".
    end case.
    return "Остальные".
end.
procedure write-tmp :
    define input parameter p-type as integer no-undo.
    define input parameter p-card as character no-undo.
    define input parameter p-code like clients.obj-code no-undo.
    define input parameter p-count as decimal  no-undo.
    define input parameter p-tots  as decimal  no-undo.
    define input parameter p-discnt as decimal no-undo.
    define input parameter p-averg  as decimal no-undo.
    define input parameter p-o-type like ub.clients.obj-type.
    define input parameter p-o-code like ub.clients.obj-code.
    define variable go-write as logical no-undo init yes.
    define variable v-pcnt as decimal no-undo init 0.
    define variable v-tsum as decimal no-undo init 0.
    define variable v-dsct as decimal no-undo init 0.
    define variable v-avrg as decimal no-undo init 0.
    for first clients where clients.obj-code = p-code and clients.obj-type = 'чел':U no-lock:
        if not det-by-obj then do:
            for first t-report-tmp where t-report-tmp.dcard-num = p-card and t-report-tmp.obj-code = p-o-code and t-report-tmp.obj-type = p-o-type:
                case p-type:
                    when 1 then go-write = no.
                    when 2 then if t-report-tmp.cli-status = 1 then delete t-report-tmp.
                    when 3 then do:
                        if t-report-tmp.cli-status > 3 then delete t-report-tmp.
                        else if t-report-tmp.cli-status = 3 then do:
                            v-pcnt = purch-count + p-count.
                            v-tsum = total-sum + p-tots.
                            v-dsct = discount + p-discnt.
                            v-avrg = v-tsum / v-pcnt.
                            assign
                                t-report-tmp.purch-count = v-pcnt
                                t-report-tmp.total-sum   = v-tsum
                                t-report-tmp.discount    = v-dsct
                                t-report-tmp.averg       = v-avrg
                            .
                            go-write = no.
                        end.
                    end.
                    when 4 then if t-report-tmp.cli-status = 5 then delete t-report-tmp.
                    when 5 then go-write = no.
                end case.
            end.
        end.
        if go-write then do:
            create t-report-tmp.
            assign
                t-report-tmp.cli-status  = p-type
                t-report-tmp.dcard-num   = replace(p-card,"|","/")
                t-report-tmp.cli-name    = replace(clients.obj-name,"|","/")
                t-report-tmp.purch-count = p-count
                t-report-tmp.total-sum   = p-tots
                t-report-tmp.discount    = p-discnt
                t-report-tmp.averg       = p-averg
                t-report-tmp.obj-code    = p-o-code
                t-report-tmp.obj-type    = p-o-type
            .
        end.
    end.
end.
if dcard-mode = 0 then do:
    for each dc-list:
        delete dc-list.
    end.
    for each dis-card no-lock:
    create dc-list.
    assign
        dc-list.d-card = dis-card.d-card.
        dc-list.card-num = dis-card.card-num.
        dc-list.cli-type = dis-card.cli-type.
        dc-list.cli-code = dis-card.cli-code.
        dc-list.issue-date = dis-card.issue-date.
    end.
end.
for each obj-list:
    objcts = objcts + obj-list.obj-type + string(obj-list.obj-code) + ", ".
    for each dc-list where dc-list.cli-type = 'чел':U:
            acc-count  = 0.
            acc-totsum = 0.
            acc-discnt = 0.
            acc-averg  = 0.
            flag-sleep = 0.
            for each chk-doc where chk-doc.obj-type = obj-list.obj-type
            and chk-doc.obj-code = obj-list.obj-code
            and chk-doc.d-card = dc-list.d-card
            and chk-doc.tot-doc >= 0
            no-lock:
                 if chk-doc.chk-date >= date(integer(x-date-start) - fill-days) and chk-doc.chk-date <= x-date-end then do:
                    if chk-doc.chk-date >= x-date-start then do:
                        if x-selectgood = 1 then do:
                            flag-sleep = 1.
                            acc-count  = acc-count  + 1.
                            acc-totsum = acc-totsum + chk-doc.tot-doc.
                            acc-discnt = acc-discnt + chk-doc.discnt.
                        end.
                        else do:
                            for each gds-list:
                                for each chk-gds where chk-gds.doc-code = chk-doc.doc-code
                                no-lock:
                                    for first bar-code where  bar-code.b-code = chk-gds.b-code
                                    no-lock:
                                        if bar-code.gds-code = gds-list.gds-code then do:
                                            acc-totsum = acc-totsum + chk-gds.price-base * chk-gds.doc-qnty.
                                            acc-discnt = acc-discnt + chk-gds.discnt.
                                            acc-count  = acc-count  + 1.
                                            flag-sleep = 1.
                                        end.
                                    end.
                                end.
                            end.
                        end.
                    end.
                    else do:
                        if x-selectgood = 1 then do:
                            flag-sleep = 2.
                        end.
                        else do:
                            for each gds-list:
                                for each chk-gds where chk-gds.doc-code = chk-doc.doc-code
                                no-lock:
                                    for first bar-code where  bar-code.b-code = chk-gds.b-code
                                    no-lock:
                                        if bar-code.gds-code = gds-list.gds-code then do:
                                            flag-sleep = 2.
                                        end.
                                    end.
                                end.
                            end.
                        end.
                    end.
                end.
            end.
            acc-averg  = acc-averg  + acc-totsum / acc-count.
            if dc-list.issue-date >= x-date-start and dc-list.issue-date <= x-date-end and flag-sleep = 1 then
                run write-tmp (input 2, dc-list.d-card, dc-list.cli-code, acc-count, acc-totsum, acc-discnt, acc-averg, obj-list.obj-type, obj-list.obj-code).
            else do:
                if flag-sleep = 1 then
                    run write-tmp (input 3, dc-list.d-card, dc-list.cli-code, acc-count, acc-totsum, acc-discnt, acc-averg, obj-list.obj-type, obj-list.obj-code).
                else if flag-sleep = 2 then
                    run write-tmp (input 4, dc-list.d-card, dc-list.cli-code, 0, 0, 0, 0, obj-list.obj-type, obj-list.obj-code).
            end.
            if flag-sleep = 0 then do:
                if dc-list.issue-date >= x-date-start and dc-list.issue-date <= x-date-end then do:
                    run write-tmp (input 1, dc-list.d-card, dc-list.cli-code, 0, 0, 0, 0, obj-list.obj-type, obj-list.obj-code).
                end.
                else if dc-list.issue-date <= x-date-start then do:
                    for first chk-doc where chk-doc.d-card = dc-list.d-card
                    and chk-doc.obj-type = obj-list.obj-type
                    and chk-doc.obj-code = obj-list.obj-code  no-lock:
                        run write-tmp (input 5, dc-list.d-card, dc-list.cli-code, 0, 0, 0, 0, obj-list.obj-type, obj-list.obj-code).
                    end.
                end.
            end.
    end.
end.
objcts = right-trim(objcts,", ").
for first t-report-tmp no-lock:
  chk-find = 1.
end.
if chk-find = 0 then do:
    message "По текущим дисконтным картам не найдено ни одной покупки." view-as alert-box.
    return.
end.
xml_tmp = string(session:temp-directory + "report-tmp.xml").
Report = new ReportXml(xml_tmp).
Report:add-element("detmode",string(det-mode)).
Report:worksheet("Лист 1").
for first t-report-tmp:
    if not available t-report-tmp then return.
end.
if det-mode > 0 then do:
    Report:worksheet-header("start").
    Report:worksheet-header("Активность клиентов (детализированная)").
    Report:worksheet-header("За период с " + string(x-date-start,"99/99/9999") + " по " + string(x-date-end,"99/99/9999")).
    Report:worksheet-header("Выбор объектов: " + objcts).
    Report:worksheet-header("Дата печати: " + string(cur-time-date())).
    Report:worksheet-header("end").
    Report:table-columns("150,100,140,110,110,110,110").
    Report:table-types = "String,String,String,Number,Number,Number,Number".
    Report:table-header("Статус клиента$|№ ДК$|ФИО$|Количество покупок$|Сумма покупок$|Скидка по ДК$|Средняя покупка","40","4").
    if not det-by-obj then do:
        report:start-element("obj-code").
        report:add-attr("value","").
        for each t-report-tmp break by t-report-tmp.cli-status:
            if first-of (t-report-tmp.cli-status) then do:
                report:start-element("status").
                report:add-attr("value",get-status(t-report-tmp.cli-status)).
                rowcnt = 0.
            end.
            report:table-row(""
              + "|" +        t-report-tmp.dcard-num
              + "|" +        t-report-tmp.cli-name
              + "|" +        string(t-report-tmp.purch-count)
              + "|" +        string(t-report-tmp.total-sum)
              + "|" +        string(t-report-tmp.discount)
              + "|" +        string(t-report-tmp.averg)
            ).
            accumulate t-report-tmp.dcard-num (count).
            accumulate t-report-tmp.purch-count (total).
            accumulate t-report-tmp.total-sum (total).
            accumulate t-report-tmp.discount (total).
            accumulate t-report-tmp.averg (total).
            accumulate t-report-tmp.dcard-num (count by t-report-tmp.cli-status).
            accumulate t-report-tmp.purch-count (total by t-report-tmp.cli-status).
            accumulate t-report-tmp.total-sum (total by t-report-tmp.cli-status).
            accumulate t-report-tmp.discount (total by t-report-tmp.cli-status).
            accumulate t-report-tmp.averg (total by t-report-tmp.cli-status).
            rowcnt = rowcnt + 1.
            if last-of (t-report-tmp.cli-status) then do:
                report:start-element("subt").
                report:add-attr("merg",string(rowcnt)).
                report:table-subtotal(""
                  + "|" +  string(accum count by t-report-tmp.cli-status t-report-tmp.dcard-num )
                  + "|" +  ""
                  + "|" +  string(accum total by t-report-tmp.cli-status t-report-tmp.purch-count )
                  + "|" +  string(accum total by t-report-tmp.cli-status t-report-tmp.total-sum )
                  + "|" +  string(accum total by t-report-tmp.cli-status t-report-tmp.discount )
                  + "|" +  string(accum total by t-report-tmp.cli-status t-report-tmp.averg )
                    ).
                    report:end-element("subt").
                report:end-element("status").
            end.
        end.
        report:end-element("obj-code").
        report:table-total("Итоги"
                          + "|" +  string(accum count t-report-tmp.dcard-num )
                          + "|" +  ""
                          + "|" +  string(accum total t-report-tmp.purch-count )
                          + "|" +  string(accum total t-report-tmp.total-sum )
                          + "|" +  string(accum total t-report-tmp.discount )
                          + "|" +  string(accum total t-report-tmp.averg )
                            ).
    end.
    else do:
        for each t-report-tmp break by t-report-tmp.obj-type by t-report-tmp.obj-code by t-report-tmp.cli-status:
            if first-of (t-report-tmp.obj-code) then do:
                report:start-element("obj-code").
                Report:add-attr("value", "Выбор объекта: " + t-report-tmp.obj-type + string(t-report-tmp.obj-code)).
            end.
            if first-of (t-report-tmp.cli-status) then do:
                report:start-element("status").
                report:add-attr("value",get-status(t-report-tmp.cli-status)).
                rowcnt = 0.
            end.
            report:table-row(""
              + "|" +        t-report-tmp.dcard-num
              + "|" +        t-report-tmp.cli-name
              + "|" +        string(t-report-tmp.purch-count)
              + "|" +        string(t-report-tmp.total-sum)
              + "|" +        string(t-report-tmp.discount)
              + "|" +        string(t-report-tmp.averg)
            ).
            accumulate t-report-tmp.dcard-num (count by t-report-tmp.obj-code ).
            accumulate t-report-tmp.purch-count (total by t-report-tmp.obj-code ).
            accumulate t-report-tmp.total-sum (total by t-report-tmp.obj-code ).
            accumulate t-report-tmp.discount (total by t-report-tmp.obj-code ).
            accumulate t-report-tmp.averg (total by t-report-tmp.obj-code ).
            accumulate t-report-tmp.dcard-num (count).
            accumulate t-report-tmp.purch-count (total).
            accumulate t-report-tmp.total-sum (total).
            accumulate t-report-tmp.discount (total).
            accumulate t-report-tmp.averg (total).
            accumulate t-report-tmp.dcard-num (count by t-report-tmp.cli-status).
            accumulate t-report-tmp.purch-count (total by t-report-tmp.cli-status).
            accumulate t-report-tmp.total-sum (total by t-report-tmp.cli-status).
            accumulate t-report-tmp.discount (total by t-report-tmp.cli-status).
            accumulate t-report-tmp.averg (total by t-report-tmp.cli-status).
            rowcnt = rowcnt + 1.
            if last-of (t-report-tmp.cli-status) then do:
                report:start-element("subt").
                report:add-attr("merg",string(rowcnt)).
                report:table-subtotal(""
                                      + "|" +  string(accum count by t-report-tmp.cli-status t-report-tmp.dcard-num )
                                      + "|" +  ""
                                      + "|" +  string(accum total by t-report-tmp.cli-status t-report-tmp.purch-count )
                                      + "|" +  string(accum total by t-report-tmp.cli-status t-report-tmp.total-sum )
                                      + "|" +  string(accum total by t-report-tmp.cli-status t-report-tmp.discount )
                                      + "|" +  string(accum total by t-report-tmp.cli-status t-report-tmp.averg )
                                        ).
                report:end-element("subt").
                report:end-element("status").
            end.
            if last-of (t-report-tmp.obj-code) then do:
                report:table-subtotal(""
                                      + "|" +  string(accum count by t-report-tmp.obj-code t-report-tmp.dcard-num )
                                      + "|" +  ""
                                      + "|" +  string(accum total by t-report-tmp.obj-code t-report-tmp.purch-count )
                                      + "|" +  string(accum total by t-report-tmp.obj-code t-report-tmp.total-sum )
                                      + "|" +  string(accum total by t-report-tmp.obj-code t-report-tmp.discount )
                                      + "|" +  string(accum total by t-report-tmp.obj-code t-report-tmp.averg )
                                        ).
                report:end-element("obj-code").
            end.
        end.
        report:table-total("Итоги"
                           + "|" +  string(accum count t-report-tmp.dcard-num )
                           + "|" +  ""
                           + "|" +  string(accum total t-report-tmp.purch-count )
                           + "|" +  string(accum total t-report-tmp.total-sum )
                           + "|" +  string(accum total t-report-tmp.discount )
                           + "|" +  string(accum total t-report-tmp.averg )).
    end.
end.
else do:
    Report:worksheet-header("start").
    Report:worksheet-header("Активность клиентов").
    Report:worksheet-header("За период с " + string(x-date-start,"99/99/9999") + " по " + string(x-date-end,"99/99/9999")).
    Report:worksheet-header("Выбор объектов: " + objcts).
    Report:worksheet-header("Дата печати: " + string(cur-time-date())).
    Report:worksheet-header("end").
    Report:table-columns("150,100,110,110,110,110").
    Report:table-types = "String,String,Number,Number,Number,Number".
    Report:table-header("Статус клиента|Количество клиентов|Количество покупок|Сумма покупок|Скидка по ДК|Средняя покупка","40","4").
    if not det-by-obj then do:
        report:start-element("obj-code").
        report:add-attr("value","").
        for each t-report-tmp break by t-report-tmp.cli-status:
            accumulate t-report-tmp.dcard-num (count).
            accumulate t-report-tmp.purch-count (total).
            accumulate t-report-tmp.total-sum (total).
            accumulate t-report-tmp.discount (total).
            accumulate t-report-tmp.averg (total).
            tmp-kli = tmp-kli + 1.
            tmp-purch = tmp-purch + t-report-tmp.purch-count.
            tmp-summ = tmp-summ + t-report-tmp.total-sum.
            tmp-disc = tmp-disc + t-report-tmp.discount.
            tmp-aver = tmp-aver + t-report-tmp.averg.
            if last-of (t-report-tmp.cli-status) then do:
                report:start-element("status").
                report:table-row(get-status(t-report-tmp.cli-status)
                + "|" +        string(tmp-kli)
                + "|" +        string(tmp-purch)
                + "|" +        string(tmp-summ)
                + "|" +        string(tmp-disc)
                + "|" +        string(tmp-aver)
                ).
                tmp-kli   = 0.
                tmp-purch = 0.
                tmp-summ  = 0.
                tmp-disc  = 0.
                tmp-aver  = 0.
                report:end-element("status").
            end.
        end.
        report:end-element("obj-code").
        report:table-total("Итоги|" + string(accum count t-report-tmp.dcard-num ) + "|" + string(accum total t-report-tmp.purch-count ) + "|" +  string(accum total t-report-tmp.total-sum )
 + "|" +  string(accum total t-report-tmp.discount )
 + "|" +  string(accum total t-report-tmp.averg )
                            ).
    end.
    else do:
        for each t-report-tmp break by t-report-tmp.obj-type by t-report-tmp.obj-code by t-report-tmp.cli-status:
            if first-of (t-report-tmp.obj-code) then do:
                report:start-element("obj-code").
                Report:add-attr("value", "Выбор объекта: " + t-report-tmp.obj-type + string(t-report-tmp.obj-code)).
            end.
            tmp-kli = tmp-kli + 1.
            tmp-purch = tmp-purch + t-report-tmp.purch-count.
            tmp-summ = tmp-summ + t-report-tmp.total-sum.
            tmp-disc = tmp-disc + t-report-tmp.discount.
            tmp-aver = tmp-aver + t-report-tmp.averg.
            accumulate t-report-tmp.dcard-num (count by t-report-tmp.obj-code ).
            accumulate t-report-tmp.purch-count (total by t-report-tmp.obj-code ).
            accumulate t-report-tmp.total-sum (total by t-report-tmp.obj-code ).
            accumulate t-report-tmp.discount (total by t-report-tmp.obj-code ).
            accumulate t-report-tmp.averg (total by t-report-tmp.obj-code ).
            accumulate t-report-tmp.dcard-num (count).
            accumulate t-report-tmp.purch-count (total).
            accumulate t-report-tmp.total-sum (total).
            accumulate t-report-tmp.discount (total).
            accumulate t-report-tmp.averg (total).
            if last-of (t-report-tmp.cli-status) then do:
                report:start-element("status").
                report:table-row(get-status(t-report-tmp.cli-status)
                + "|" +        string(tmp-kli)
                + "|" +        string(tmp-purch)
                + "|" +        string(tmp-summ)
                + "|" +        string(tmp-disc)
                + "|" +        string(tmp-aver)
                ).
                tmp-kli   = 0.
                tmp-purch = 0.
                tmp-summ  = 0.
                tmp-disc  = 0.
                tmp-aver  = 0.
                report:end-element("status").
            end.
            if last-of (t-report-tmp.obj-code) then do:
                report:table-subtotal("Итоги по объекту"
                                   + "|" +  string(accum count by t-report-tmp.obj-code  t-report-tmp.dcard-num )
                                   + "|" +  string(accum total by t-report-tmp.obj-code  t-report-tmp.purch-count )
                                   + "|" +  string(accum total by t-report-tmp.obj-code  t-report-tmp.total-sum )
                                   + "|" +  string(accum total by t-report-tmp.obj-code  t-report-tmp.discount )
                                   + "|" +  string(accum total by t-report-tmp.obj-code  t-report-tmp.averg )
                                  ).
                report:end-element("obj-code").
            end.
        end.
        report:table-total("Итоги"
                   + "|" +  string(accum count t-report-tmp.dcard-num )
                   + "|" +  string(accum total t-report-tmp.purch-count )
                   + "|" +  string(accum total t-report-tmp.total-sum )
                   + "|" +  string(accum total t-report-tmp.discount )
                   + "|" +  string(accum total t-report-tmp.averg )).
    end.
end.
report:worksheet("end").
delete object Report.
xslt-path = search("exe\activ.xsl").
rep-out-unit = new rep-out ().
rep-out-unit:office(xml_tmp, xslt-path).
