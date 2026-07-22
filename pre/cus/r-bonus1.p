block-level on error undo, throw.
define input parameter parparentproc      as   widget-handle         no-undo .
define input parameter tog-1              as   logical               no-undo .
define input parameter tog-2              as   logical               no-undo .
define input parameter tog-3              as   logical               no-undo .
define input parameter p-schema-code      as   integer               no-undo .
define input parameter p-cdpay-code         as   integer               no-undo .
define input parameter p-curr-code        as   integer               no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-bonus1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/r-bonus1.p $":U .
define variable vss-description as character no-undo init "Начисление и списание бонусов - расчетная часть".
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
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
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
define new shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define new shared variable RepPathName        as character no-undo .
define new shared variable PrintRubl          as logical   no-undo .
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared stream PrnLibStream.
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
DEFINE TEMP-TABLE treal-3 no-undo
FIELD gds-code like ub.goods.gds-code
field line-num as integer
FIELD cpay-code as integer
FIELD curr-code as integer
FIELD price-base as decimal
FIELD qnty1 as decimal
FIELD netto as decimal
FIELD ii as integer
FIELD d-card as character
field rec-type as integer
INDEX pi IS UNIQUE PRIMARY
gds-code
cpay-code
curr-code
d-card
INDEX vi
IS UNIQUE
gds-code
price-base
ii
.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define NEW SHARED temp-table temp-bon1 no-undo
field obj-type like ub.chk-doc.obj-type
field obj-code like ub.chk-doc.obj-code
field gds-code like ub.goods.gds-code
field chk-date like ub.chk-doc.chk-date
field chk-time like ub.chk-doc.chk-time
field doc-code like ub.chk-doc.doc-code
field line-num like ub.chk-discnt.line-num
field discnt-id like ub.chk-discnt.discnt-id
field object-line-num like ub.chk-discnt.object-line-num
field shift-date like ub.chk-doc.shift-date
field shift-num like ub.chk-doc.shift-num
field shift-name as character
field d-card like ub.chk-discnt.d-card
field op-code as integer
field src-qnty like ub.chk-discnt.object-qnty init 0
field src-price like ub.chk-gds.src-price
field src-sum  like ub.chk-discnt.object-sum
field pay-sum  like ub.chk-discnt.object-sum
field discnt-value-abs like ub.chk-discnt.discnt-value-abs
field cashier-psn-code like ub.chk-doc.cashier-psn-code
field item-type as integer
field item-name as character
field level as integer
index pi is unique primary
doc-code
line-num
discnt-id
object-line-num
index imain
obj-type
obj-code
item-type
item-name
op-code
chk-date
chk-time
index imain2
obj-type
obj-code
chk-date
chk-time
index ilevel
level
.
define temp-table temp-bon1-shft no-undo
field obj-type like ub.chk-doc.obj-type
field obj-code like ub.chk-doc.obj-code
field shift-date like ub.chk-doc.shift-date
field shift-num like ub.chk-doc.shift-num
field shift-name as character
index pi is unique primary
obj-type
obj-code
shift-date
shift-num
.
define temp-table temp-bon1-cashier no-undo
field cashier-psn-code like ub.person.psn-code
field obj-name like ub.clients.obj-name
index pi is unique primary
cashier-psn-code
.
define NEW SHARED temp-table temp-bon1-gds no-undo
field gds-code like ub.goods.gds-code
field gds-name like ub.goods.gds-name
index pi is unique primary
gds-code
.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-chk-gds no-undo
field doc-code like ub.chk-doc.doc-code
FIELD b-code like ub.chk-gds.b-code
FIELD src-code like ub.chk-gds.src-code
field sum as decimal
field sum-change as decimal
field qnty like ub.chk-gds.doc-qnty
field qnty2 like ub.chk-gds.doc-qnty
field price-base as decimal
field rec-type as integer
field gds-type as integer
field line-num as integer
field pump as integer
field nozzle-code as integer
field jj_ as integer
field jjp_ as integer
field jjo_ as integer
index pi iS unique primary
doc-code
rec-type
b-code
price-base
index ijj is unique
jj_
index ijjp
jjp_
index ijjo
jjo_
.
define temp-table temp-chk-pay no-undo like ub.chk-pay
field pet-good as integer
field obj-name like ub.cash-pay.obj-name
field is-cash  like ub.cash-pay.is-cash
field register like ub.cash-pay.register
index pi is primary unique line-num
index isort
pet-good  descending
line-num
.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable sheets  as integer no-undo.
define variable Line as character no-undo .
run prepare-table in this-procedure .
find first temp-bon1 no-error .
if not available temp-bon1 then do:
  message
  "За выбранный период времени НЕ БЫЛО НАЧИСЛЕНИЙ И СПИСАНИЙ БОНУСОВ," skip
  "либо чеки с бонусами не были включены в продажу за заданный период"
  view-as alert-box .
  return.
end.
run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input 43
                                            ,input yes
                                            ,input no
                                            ).
FORM HEADER
Line format "X(198)" AT 1 SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame width 232 PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW STREAM PrnLibStream FRAME BottomFrame .
FOR EACH sheetf where sheetf.sheet-num > 1:
  delete sheetf.
end.
FIND FIRST sheetf where
            sheetf.sheet-num = 1 No-ERROR.
sheetf.sizes = "".
if tog-1 then DO:
  str2 = 'Оборот карты "Бонус клуб" (Товар)'.
  Put stream PrnLibStream unformatted
  reportNAme skip
  str2 skip
  str1 skip
  str3 SKIP
  Str4 SKIP
  ReportHeader SKIP.
  RUN first-line in this-procedure ( input 1) no-error.
  assign
  sheetf.Excel-Column-Lable =
  "____________" + chr(44) +
  "Дата"  + chr(44) +
  "Смена"  + chr(44) +
  "Чек"  + chr(44) +
  "№ карты"  + chr(44) +
  "Тип операции"  + chr(44) +
  "Товар/ услуга"  + chr(44) +
  "Кол-во (шт/л)"  + chr(44) +
  "Цена"  + chr(44) +
  "Стоимость на ТО"  + chr(44) +
  "Оплачено"  + chr(44) +
  "Начислено бонусов" + chr(44) +
   "Оператор"
   sheetf.sizes =
  "12"  + chr(44) +
  "17"  + chr(44) +
  "11"  + chr(44) +
  "20"  + chr(44) +
  "9"  + chr(44) +
  "14"  + chr(44) +
  "20"  + chr(44) +
  "10"  + chr(44) +
  "11"  + chr(44) +
  "15"  + chr(44) +
  "15"  + chr(44) +
  "15"  + chr(44) +
  "18"
  str2 = " "
  Sheetf.colformat = "2=@;5=@" + chr(4) + '':U + chr(4) + 'Оборот по товару'
  .
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
 PUT STREAM PrnLibStream UNFORMATTED
 "------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------" skip "            :      Дата       :   Смена   :        Чек         :№ карты : Тип операции :   Товар/ услуга    :  Кол-во  :   Цена    :Стоимость на ТО:   Оплачено    :  Начислено    :    Оператор      " skip "            :                 :           :                    :        :              :                    :          :           :               :               :   бонусов     :                  " skip "------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------".
  run rep/extitle.p ( input 1) no-error.
  run cus/r-bon1-1.p ( input parparentproc
                    ,input p-schema-code
                    ,input p-cdpay-code
                    ,input p-curr-code
                     ) no-error.
end.
if   Make-Excel Then  do:   Output stream ForExcel close.   assign   number-list = number-list + 1   .   os-delete value( v-excel-file + ".":U + string(number-list)).   Output Stream ForExcel to value( v-excel-file + ".":U + string(number-list ) ) . end.
if tog-2 then DO:
  page stream PrnLibStream .
  str2 = 'Оборот по обслуживанию (карты "Бонус клуб")'.
  Put stream PrnLibStream unformatted
  reportNAme skip
  str2 skip
  str1 skip
  str3 SKIP
  Str4 SKIP
  ReportHeader SKIP.
  run first-line in this-procedure ( input 2) no-error.
  FInd first Sheetf where
              Sheetf.sheet-num = 2 No-ERROR.
  if not avail sheetf then
  create sheetf.
  assign
  Sheetf.Sheet-num = 2.
   assign
  sheetf.Excel-Column-Lable =
  "Дата"  + chr(44) +
  "Смена"  + chr(44) +
  "Чек"  + chr(44) +
  "№ карты"  + chr(44) +
  "Товар/ услуга"  + chr(44) +
  "Кол-во (шт/л)"  + chr(44) +
  "Цена"  + chr(44) +
  "Стоимость на ТО"  + chr(44) +
  "Оплачено наличными"  + chr(44) +
  "Оплачено бонусами"  + chr(44) +
  "Начислено бонусов" + chr(44) +
   "Оператор"
   sheetf.sizes =
  "17"  + chr(44) +
  "11"  + chr(44) +
  "20"  + chr(44) +
  "9"  + chr(44) +
  "20"  + chr(44) +
  "10"  + chr(44) +
  "11"  + chr(44) +
  "15"  + chr(44) +
  "15"  + chr(44) +
  "15"  + chr(44) +
  "15"  + chr(44) +
  "18"
  str2 = " "
  Sheetf.colformat = "1=@;4=@" + chr(4) + '':U + chr(4) + 'Оборот по обслуживанию'
  .
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
 PUT STREAM PrnLibStream UNFORMATTED
"------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------" skip  "      Дата       :   Смена   :        Чек         :№ карты :   Товар/ услуга    :  Кол-во  :   Цена    :Стоимость на ТО:   Оплачено    :   Оплачено    :  Начислено    :    Оператор      " skip  "                 :           :                    :        :                    :          :           :               :  наличными    :   бонусами    :   бонусов     :                  " skip  "------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------".
  run rep/extitle.p ( input 2) .
  run cus/r-bon1-2.p ( input parparentproc
                 , input p-schema-code
                 , input p-cdpay-code
                 , input p-curr-code
                 , input 2
                 ) no-error.
end.
if   Make-Excel Then  do:   Output stream ForExcel close.   assign   number-list = number-list + 1   .   os-delete value( v-excel-file + ".":U + string(number-list)).   Output Stream ForExcel to value( v-excel-file + ".":U + string(number-list ) ) . end.
if tog-3 then DO:
    page stream PrnLibStream .
    str2 = 'Оборот по обслуживанию (карты "Бонус клуб")'.
    Put stream PrnLibStream unformatted
    reportNAme skip
    str2 skip
    str1 skip
    str3 SKIP
    Str4 SKIP
    ReportHeader SKIP.
    run first-line in this-procedure ( input 3) no-error.
    FInd first Sheetf where
               Sheetf.sheet-num = 3 No-ERROR.
    if not avail sheetf then
    create sheetf.
    assign
    Sheetf.Sheet-num = 3.
   assign
  sheetf.Excel-Column-Lable =
  "Дата"  + chr(44) +
  "Смена"  + chr(44) +
  "Чек"  + chr(44) +
  "№ карты"  + chr(44) +
  "Товар/ услуга"  + chr(44) +
  "Кол-во (шт/л)"  + chr(44) +
  "Цена"  + chr(44) +
  "Стоимость на ТО"  + chr(44) +
  "Оплачено наличными"  + chr(44) +
  "Оплачено бонусами"  + chr(44) +
  "Начислено бонусов" + chr(44) +
   "Оператор"
   sheetf.sizes =
  "17"  + chr(44) +
  "11"  + chr(44) +
  "20"  + chr(44) +
  "9"  + chr(44) +
  "20"  + chr(44) +
  "10"  + chr(44) +
  "11"  + chr(44) +
  "15"  + chr(44) +
  "15"  + chr(44) +
  "15"  + chr(44) +
  "15"  + chr(44) +
  "18"
  str2 = " "
  Sheetf.colformat = "1=@;4=@" + chr(4) + '':U + chr(4) + 'Оборот по обслуживанию по датам'
  .
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
 PUT STREAM PrnLibStream UNFORMATTED
"------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------" skip "      Дата       :   Смена   :        Чек         :№ карты :   Товар/ услуга    :  Кол-во  :   Цена    :Стоимость на ТО:   Оплачено    :   Оплачено    :  Начислено    :    Оператор      " skip "                 :           :                    :        :                    :          :           :               :  наличными    :   бонусами    :   бонусов     :                  " skip "------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------".
  run rep/extitle.p ( input 3) .
  run cus/r-bon1-2.p ( input parparentproc
                 , input p-schema-code
                 , input p-cdpay-code
                 , input p-curr-code
                 , input 3
                 ) no-error.
end.
if Make-Excel then output stream ForExcel close.
HIDE STREAM PrnLibStream FRAME BottomFrame .
Output stream PrnLibStream close.
run waitfram-hide in this-procedure .
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 8
                                          ).
procedure first-line :
define input parameter  vartog as integer no-undo .
PUT STREAM PrnLibStream UNFORMATTED skip.
End procedure.
procedure prepare-table :
define variable kk as integer no-undo .
DEFINE VARIABLE JJ as integer No-UNDO.
DEFINE VARIABLE JJP as integer No-UNDO.
DEFINE VARIABLE JJO as integer No-UNDO.
DEFINE VARIABLE pay-sum as decimal No-UNDO.
DEFINE VARIABLE dop-sump as decimal No-UNDO.
DEFINE VARIABLE dop-sumg as decimal No-UNDO.
DEFINE VARIABLE dop-sumk as decimal No-UNDO.
DEFINE VARIABLE v-line-num as integer no-undo .
define variable v-curr-r-b as character no-undo .
define variable v-base-code like ub.sysconf.base-code no-undo .
define variable v-curr-code like ub.currency.curr-code no-undo init ?.
define variable v-one-curr-code as logical no-undo .
define variable v-host-code as integer no-undo .
define buffer buf_temp-bon1 for temp-bon1.
define buffer buf_inkas for ub.inkas.
define buffer buf_chk-doc for ub.chk-doc.
define buffer buf_chk-gds for ub.chk-gds.
define buffer buf_chk-discnt for ub.chk-discnt .
define buffer buf_bar-code for ub.bar-code.
define buffer buf_goods for ub.goods.
define buffer buf_temp-bon1-gds for temp-bon1-gds.
define buffer obj-grp-op_temp-bon1 for temp-bon1.
define buffer obj-grp_temp-bon1 for temp-bon1.
define buffer obj-op_temp-bon1 for temp-bon1.
define buffer obj_temp-bon1 for temp-bon1.
define buffer buf0_chk-pay for ub.chk-pay.
define buffer buf_chk-pay for ub.chk-pay.
define buffer buf_cash-pay for ub.cash-pay.
DEFINE BUFFER buf_treal-3 for treal-3.
define buffer b3-treal-3 for treal-3.
  do
  on error undo, return error return-value
  :
    for each treal-3:
      delete treal-3.
    end.
    for each temp-bon1:
      delete temp-bon1.
    end.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
    for each obj-list no-lock,
       each buf_inkas no-lock where
          buf_inkas.obj-type = obj-list.obj-type
      and buf_inkas.obj-code = obj-list.obj-code
      and buf_inkas.shift-date >= X-date-start
      and buf_inkas.shift-date <= X-date-end:
       _discnt:
      for each buf_chk-discnt no-lock where
            buf_chk-discnt.obj-type = obj-list.obj-type
        and buf_chk-discnt.obj-code = obj-list.obj-code
        and buf_chk-discnt.out-code = buf_inkas.inkas-code
        and buf_chk-discnt.record-type = 5,
        first buf_chk-doc no-lock where
              buf_chk-doc.doc-code = buf_chk-discnt.doc-code:
        if p-schema-code > 0
        and buf_chk-discnt.discnt-type <> p-schema-code then next _discnt.
        create buf_temp-bon1.
        assign
        buf_temp-bon1.obj-type = obj-list.obj-type
        buf_temp-bon1.obj-code = obj-list.obj-code
        buf_temp-bon1.chk-date = buf_chk-doc.chk-date
        buf_temp-bon1.chk-time = buf_chk-doc.chk-time
        buf_temp-bon1.doc-code = buf_chk-doc.doc-code
        buf_temp-bon1.line-num = buf_chk-discnt.line-num
        buf_temp-bon1.discnt-id = buf_chk-discnt.discnt-id
        buf_temp-bon1.object-line-num = buf_chk-discnt.object-line-num
        buf_temp-bon1.shift-date = buf_chk-doc.shift-date
        buf_temp-bon1.shift-num = buf_chk-doc.shift-num
        buf_temp-bon1.d-card = buf_chk-discnt.d-card
        buf_temp-bon1.op-code = 2
        buf_temp-bon1.discnt-value-abs = buf_chk-discnt.discnt-value-abs
        buf_temp-bon1.cashier-psn-code = buf_chk-doc.cashier-psn-code
        buf_temp-bon1.level = 0
        .
        find first buf_chk-gds no-lock where
                  buf_chk-gds.doc-code = buf_chk-discnt.doc-code
              and buf_chk-gds.line-num = buf_chk-discnt.object-line-num no-error.
        if available buf_chk-gds then do:
          assign
          buf_temp-bon1.item-type =(if buf_chk-gds.pump > 0 then 1 else 2)
          buf_temp-bon1.src-qnty = buf_chk-gds.src-qnty
          buf_temp-bon1.src-price = buf_chk-gds.src-price
          buf_temp-bon1.src-sum  = buf_chk-gds.src-price * buf_chk-gds.src-qnty
          buf_temp-bon1.pay-sum  = (buf_chk-gds.price-base - buf_chk-gds.discnt) * buf_chk-gds.doc-qnty
          .
        end.
        else do:
          assign
          buf_temp-bon1.src-qnty = buf_chk-discnt.object-qnty
          buf_temp-bon1.pay-sum = buf_chk-discnt.object-sum
          buf_temp-bon1.src-sum = buf_chk-discnt.object-sum
          buf_temp-bon1.src-price = buf_chk-discnt.object-sum / buf_chk-gds.src-qnty
          .
        end.
        find first buf_bar-code no-lock where
                  buf_bar-code.b-code = buf_chk-gds.b-code no-error.
        if available buf_bar-code then do:
          assign
          buf_temp-bon1.gds-code = buf_bar-code.gds-code.
          if buf_temp-bon1.item-type = 1 then do:
            find first buf_temp-bon1-gds no-lock where
                    buf_temp-bon1-gds.gds-code = buf_temp-bon1.gds-code no-error.
            if not available buf_temp-bon1-gds then do:
              find first buf_goods no-lock where
                        buf_goods.gds-code = buf_temp-bon1.gds-code no-error.
              create buf_temp-bon1-gds.
              assign
              buf_temp-bon1-gds.gds-code = buf_temp-bon1.gds-code
              buf_temp-bon1-gds.gds-name = (if available buf_goods
                                             then buf_goods.gds-name
                                             else substitute("Неизвестное топливо &1", buf_temp-bon1.gds-code))
              buf_temp-bon1.item-name = buf_temp-bon1-gds.gds-name
              .
            end.
            else do:
              assign
              buf_temp-bon1.item-name = buf_temp-bon1-gds.gds-name
              .
            end.
          end .
        end.
        if buf_temp-bon1.item-type = 2 then do:
          assign
          buf_temp-bon1.item-name = "Соп. товары"
          .
        end.
        find first obj-grp-op_temp-bon1 where
                  obj-grp-op_temp-bon1.obj-type = buf_temp-bon1.obj-type
              and obj-grp-op_temp-bon1.obj-code = buf_temp-bon1.obj-code
              and obj-grp-op_temp-bon1.item-name = buf_temp-bon1.item-name
              and obj-grp-op_temp-bon1.item-type = buf_temp-bon1.item-type
              and obj-grp-op_temp-bon1.gds-code = -1
              and obj-grp-op_temp-bon1.op-code = buf_temp-bon1.op-code no-error.
        if not available obj-grp-op_temp-bon1  then do:
          create obj-grp-op_temp-bon1 .
          assign
          obj-grp-op_temp-bon1.obj-type = buf_temp-bon1.obj-type
          obj-grp-op_temp-bon1.obj-code = buf_temp-bon1.obj-code
          obj-grp-op_temp-bon1.item-name = buf_temp-bon1.item-name
          obj-grp-op_temp-bon1.item-type = buf_temp-bon1.item-type
          obj-grp-op_temp-bon1.gds-code = -1
          obj-grp-op_temp-bon1.op-code = buf_temp-bon1.op-code
          obj-grp-op_temp-bon1.level = 2
          .
        end.
        assign
        obj-grp-op_temp-bon1.src-qnty = obj-grp-op_temp-bon1.src-qnty + buf_chk-discnt.object-qnty
        obj-grp-op_temp-bon1.pay-sum = obj-grp-op_temp-bon1.pay-sum + buf_chk-discnt.object-sum
        obj-grp-op_temp-bon1.src-sum = obj-grp-op_temp-bon1.src-sum + buf_chk-discnt.object-sum
        obj-grp-op_temp-bon1.discnt-value-abs = obj-grp-op_temp-bon1.discnt-value-abs + buf_chk-discnt.discnt-value-abs
        .
        find first obj-grp_temp-bon1 where
                  obj-grp_temp-bon1.obj-type = buf_temp-bon1.obj-type
              and obj-grp_temp-bon1.obj-code = buf_temp-bon1.obj-code
              and obj-grp_temp-bon1.item-name = buf_temp-bon1.item-name
              and obj-grp_temp-bon1.item-type = buf_temp-bon1.item-type
              and obj-grp_temp-bon1.gds-code = -1
              and obj-grp_temp-bon1.op-code = 0 no-error.
        if not available obj-grp_temp-bon1  then do:
          create obj-grp_temp-bon1 .
          assign
          obj-grp_temp-bon1.obj-type = buf_temp-bon1.obj-type
          obj-grp_temp-bon1.obj-code = buf_temp-bon1.obj-code
          obj-grp_temp-bon1.item-name = buf_temp-bon1.item-name
          obj-grp_temp-bon1.item-type = buf_temp-bon1.item-type
          obj-grp_temp-bon1.gds-code = -1
          obj-grp_temp-bon1.op-code = 0
          obj-grp_temp-bon1.level = 3
          .
        end.
        assign
        obj-grp_temp-bon1.src-qnty = obj-grp_temp-bon1.src-qnty + buf_chk-discnt.object-qnty
        obj-grp_temp-bon1.pay-sum = obj-grp_temp-bon1.pay-sum + buf_chk-discnt.object-sum
        obj-grp_temp-bon1.src-sum = obj-grp_temp-bon1.src-sum + buf_chk-discnt.object-sum
        obj-grp_temp-bon1.discnt-value-abs = obj-grp_temp-bon1.discnt-value-abs + buf_chk-discnt.discnt-value-abs
        .
        find first obj-op_temp-bon1 where
                  obj-op_temp-bon1.obj-type = buf_temp-bon1.obj-type
              and obj-op_temp-bon1.obj-code = buf_temp-bon1.obj-code
              and obj-op_temp-bon1.item-type = 0
              and obj-op_temp-bon1.item-name = '':U
              and obj-op_temp-bon1.gds-code = -1
              and obj-op_temp-bon1.op-code = buf_temp-bon1.op-code no-error.
        if not available obj-op_temp-bon1  then do:
          create obj-op_temp-bon1 .
          assign
          obj-op_temp-bon1.obj-type = buf_temp-bon1.obj-type
          obj-op_temp-bon1.obj-code = buf_temp-bon1.obj-code
          obj-op_temp-bon1.item-name = '':U
          obj-op_temp-bon1.item-type = 0
          obj-op_temp-bon1.gds-code = -1
          obj-op_temp-bon1.op-code = buf_temp-bon1.op-code
          obj-op_temp-bon1.level = 4
          .
        end.
        assign
        obj-op_temp-bon1.src-qnty = obj-op_temp-bon1.src-qnty + buf_chk-discnt.object-qnty
        obj-op_temp-bon1.pay-sum = obj-op_temp-bon1.pay-sum + buf_chk-discnt.object-sum
        obj-op_temp-bon1.src-sum = obj-op_temp-bon1.src-sum + buf_chk-discnt.discnt-value-abs
        .
        find first obj_temp-bon1 where
                  obj_temp-bon1.obj-type = buf_temp-bon1.obj-type
              and obj_temp-bon1.obj-code = buf_temp-bon1.obj-code
              and obj_temp-bon1.item-name = '':U
              and obj_temp-bon1.item-type = 0
              and obj_temp-bon1.gds-code = -1
              and obj_temp-bon1.op-code = 0 no-error.
        if not available obj_temp-bon1  then do:
          create obj_temp-bon1 .
          assign
          obj_temp-bon1.obj-type = buf_temp-bon1.obj-type
          obj_temp-bon1.obj-code = buf_temp-bon1.obj-code
          obj_temp-bon1.item-name = '':U
          obj_temp-bon1.item-type = 0
          obj_temp-bon1.gds-code = -1
          obj_temp-bon1.op-code = 0
          obj_temp-bon1.level = 5
          .
        end.
        assign
        obj_temp-bon1.src-qnty = obj_temp-bon1.src-qnty + buf_chk-discnt.object-qnty
        obj_temp-bon1.pay-sum = obj_temp-bon1.pay-sum + buf_chk-discnt.object-sum
        obj_temp-bon1.src-sum = obj_temp-bon1.src-sum + buf_chk-discnt.object-sum
        obj_temp-bon1.discnt-value-abs = obj_temp-bon1.discnt-value-abs + buf_chk-discnt.discnt-value-abs
        .
      end.
    end.
    for each obj-list no-lock:
      for each buf_inkas no-lock where
          buf_inkas.obj-type = obj-list.obj-type
      and buf_inkas.obj-code = obj-list.obj-code
      and buf_inkas.shift-date >= X-date-start
      and buf_inkas.shift-date <= X-date-end:
        _chk-doc:
        for each buf0_chk-pay no-lock where
                buf0_chk-pay.out-code = buf_inkas.inkas-code
            and buf0_chk-pay.pay-code = p-cdpay-code
            and buf0_chk-pay.curr-code = p-curr-code,
          first buf_chk-doc no-lock where
              buf_chk-doc.doc-code = buf0_chk-pay.doc-code:
          for EACH buf_chk-pay NO-LOCK WHERE
                 buf_chk-pay.doc-code = buf_chk-doc.doc-code
          BREAK
          BY buf_CHK-pay.DOC-CODE
          BY buf_CHK-pay.LINE-NUM:
            if lookup(string(buf_chk-doc.chk-type), '14,15,16,36,17,8,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) > 0 then next _chk-doc.
                                                                                                                        define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if first-of(buf_CHK-pay.DOC-CODE) THEN Do:
  assign
  kk = 0
  jj = 1
  jjp = 0
  jjo = 0
  pay-sum = buf_chk-doc.netto
  dop-sumg = 0
  .
  for each buf_treal-3:
    delete buf_treal-3.
  end.
  for each temp-chk-gds:
    delete temp-chk-gds.
  end.
  for each temp-chk-pay:
    delete temp-chk-pay.
  end.
  FOR EACH buf_chk-gds No-LOCK WHERE
           buf_chk-gds.doc-code = buf_chk-pay.doc-code
  BY buf_chk-gds.line-num:
  if buf_chk-gds.write-off-code <> ?
  and buf_chk-gds.write-off-code > 0 then NEXT.
    find first temp-chk-gds where
              temp-chk-gds.b-code = buf_chk-gds.b-code
          AND  temp-chk-gds.doc-code = buf_chk-gds.doc-code
          and temp-chk-gds.price-base = buf_chk-gds.price-base no-error.
    IF AVAILABLE TEMP-CHK-GDS THEN DO:
      assign
      temp-chk-gds.qnty = temp-chk-gds.qnty  + buf_chk-gds.DOC-qnty
      temp-chk-gds.sum  = temp-chk-gds.sum  + buf_chk-gds.doc-qnty * (buf_chk-gds.price-base - buf_chk-gds.discnt + buf_chk-gds.price-service)
      temp-chk-gds.sum-change = temp-chk-gds.sum
      .
    end.
    else do:
      find first temp-chk-gds where temp-chk-gds.jj_ = jj use-index ijj no-error.
      if not available temp-chk-gds then do:
        create temp-chk-gds.
        assign
        temp-chk-gds.jj_ = jj
        temp-chk-gds.qnty = 0
        temp-chk-gds.sum = 0
        temp-chk-gds.sum-change = temp-chk-gds.sum
        jj = jj + 1
        .
      end.
      else do:
        assign
        jj = jj + 1
        temp-chk-gds.qnty = 0
        temp-chk-gds.sum = 0
        temp-chk-gds.sum-change = temp-chk-gds.sum
        .
      end.
      ASSIGN
      temp-chk-gds.doc-code = buf_chk-gds.doc-code
      temp-chk-gds.b-code = buf_chk-gds.b-code
      temp-chk-gds.price-base = buf_chk-gds.price-base
      temp-chk-gds.qnty = temp-chk-gds.qnty  + buf_chk-gds.DOC-qnty
      temp-chk-gds.sum  = temp-chk-gds.sum  + buf_chk-gds.doc-qnty * (buf_chk-gds.price-base - buf_chk-gds.discnt + buf_chk-gds.price-service)
      temp-chk-gds.sum-change = temp-chk-gds.sum
      temp-chk-gds.gds-type =  (if buf_chk-gds.pump > 0
                                then 1
                                else 2)
      jjo = jjo + (if buf_chk-gds.pump > 0
                   then 0
                   else 1)
      jjp = jjp + (if buf_chk-gds.pump > 0
                   then 1
                   else 0)
      temp-chk-gds.jjp_  = (if buf_chk-gds.pump > 0
                           then jjp
                           else 0)
      temp-chk-gds.jjo_  = (if buf_chk-gds.pump > 0
                            then 0
                            else jjo)
      .
    end.
  END.
end.
FIND FIRST buf_cash-pay No-LOCK WHERE
          buf_cash-pay.cdpay-code = buf_chk-pay.pay-code AND
          buf_cash-pay.curr-code = buf_chk-pay.curr-code No-ERROR.
if available buf_cash-pay then do:
  find first temp-chk-pay use-index pi where
          temp-chk-pay.line-num = buf_chk-pay.line-num no-error.
  if not available temp-chk-pay then do:
    create temp-chk-pay.
  end.
  buffer-copy buf_chk-pay to temp-chk-pay
  assign
  temp-chk-pay.pet-good = integer(buf_cash-pay.atr64) * 2 + integer( buf_cash-pay.is-cash)
  temp-chk-pay.obj-name = buf_cash-pay.obj-name
  temp-chk-pay.is-cash  = buf_cash-pay.is-cash
  .
end.
if last-of(buf_chk-pay.doc-code) then do:
  for each temp-chk-pay where
          temp-chk-pay.doc-code = buf_chk-pay.doc-code
  by temp-chk-pay.pet-good descending
  by temp-chk-pay.line-num:
    assign
    dop-sump = (if v-curr-r-b = 'rubl':U then temp-chk-pay.tot-rubl else temp-chk-pay.tot-base)
    .
    _repeat:
    REPEAT WHILE  abs(dop-sump) > 0 :
      if dop-sumg = 0 then do:
        assign
        kk = kk + 1
        .
        if kk >= jj then LEAVE _repeat.
        if kk <= jjp then
        find first temp-chk-gds where
                  temp-chk-gds.doc-code = buf_chk-doc.doc-code
            AND  temp-chk-gds.jjp_ = kk no-error .
        else
        find first temp-chk-gds where
                  temp-chk-gds.doc-code = buf_chk-doc.doc-code
            AND  temp-chk-gds.jjo_ = kk - jjp no-error .
        if not available temp-chk-gds or temp-chk-gds.sum = 0 then do:
          NEXT _repeat.
        end.
        assign
        dop-sumg = temp-chk-gds.sum
        .
      end.
      assign
      dop-sumk = min(abs(dop-sumg), abs(dop-sump))  * (if dop-sump > 0 then 1 else -1 )
      pay-sum = pay-sum - dop-sumk
      dop-sump = dop-sump - dop-sumk
      dop-sumg = dop-sumg - dop-sumk
      .
      FIND FIRST buf_bar-code No-LOCK WHERE
               buf_bar-code.b-code =  temp-chk-gds.b-code No-ERROR.
      IF NOT AVAIL buf_bar-code then NEXT _repeat.
      FIND FIRST buf_treal-3 No-LOCK WHERE
                buf_treal-3.gds-code = buf_bar-code.gds-code
            AND buf_treal-3.cpay-code = temp-chk-pay.pay-code
            AND buf_treal-3.curr-code = temp-chk-pay.curr-code
            AND buf_treal-3.d-card = temp-chk-pay.pay-card No-ERROR.
      IF NOT AVAIL  buf_treal-3 then do:
        FIND last b3-treal-3 No-LOCK WHERE
                  b3-treal-3.gds-code = buf_bar-code.gds-code use-index vi No-ERROR.
        create buf_treal-3.
        assign
        buf_treal-3.gds-code = buf_bar-code.gds-code
        buf_treal-3.cpay-code = temp-chk-pay.pay-code
        buf_treal-3.curr-code = temp-chk-pay.curr-code
        buf_treal-3.price-base = temp-chk-gds.price-base
        buf_treal-3.rec-type = temp-chk-gds.GDS-type
        buf_treal-3.d-card  = temp-chk-pay.pay-card
        buf_treal-3.line-num = temp-chk-pay.line-num
        buf_treal-3.ii  = (if avail b3-treal-3
                          then b3-treal-3.ii + 1
                          else 1)
        .
      END.
      assign
      buf_treal-3.netto = buf_treal-3.netto + dop-sumk
      buf_treal-3.qnty1 = buf_treal-3.qnty1 + temp-chk-gds.qnty * (dop-sumk / temp-chk-gds.sum)
      .
      if dop-sumg <= 0 then do:
        assign
        kk = kk + 1.
        if kk >= jj then LEAVE _repeat.
        if kk <= jjp then do:
          find first temp-chk-gds where
                    temp-chk-gds.doc-code = buf_chk-doc.doc-code
              AND  temp-chk-gds.jjp_ = kk no-error .
        end.
        else do:
          find first temp-chk-gds where
                    temp-chk-gds.doc-code = buf_chk-doc.doc-code
              AND  temp-chk-gds.jjo_ = kk - jjp no-error .
          if not available temp-chk-gds then do:
            LEAVE _repeat.
          end.
        end.
        dop-sumg = temp-chk-gds.sum.
        dop-sumg = temp-chk-gds.sum.
      end.
    END.
  end.
end.
            if last-of(buf_chk-pay.doc-code) then do:
               define variable v-gds-ii as integer no-undo .
               v-gds-ii = 0.
                for each buf_treal-3:
                if (buf_treal-3.cpay-code = p-cdpay-code
                and buf_treal-3.curr-code = p-curr-code) then do:
                  create buf_temp-bon1.
                  assign
                  buf_temp-bon1.obj-type = obj-list.obj-type
                  buf_temp-bon1.obj-code = obj-list.obj-code
                  buf_temp-bon1.chk-date = buf_chk-doc.chk-date
                  buf_temp-bon1.chk-time = buf_chk-doc.chk-time
                  buf_temp-bon1.doc-code = buf_chk-doc.doc-code
                  buf_temp-bon1.line-num = buf_treal-3.line-num
                  buf_temp-bon1.discnt-id = v-gds-ii
                  v-gds-ii = v-gds-ii + 1
                  buf_temp-bon1.object-line-num = buf_treal-3.ii
                  buf_temp-bon1.shift-date = buf_chk-doc.shift-date
                  buf_temp-bon1.shift-num = buf_chk-doc.shift-num
                  buf_temp-bon1.d-card = buf_treal-3.d-card
                  buf_temp-bon1.op-code = 1
                  buf_temp-bon1.discnt-value-abs = 0
                  buf_temp-bon1.cashier-psn-code = buf_chk-doc.cashier-psn-code
                  buf_temp-bon1.level = 0
                  buf_temp-bon1.item-type = buf_treal-3.rec-type
                  buf_temp-bon1.src-qnty = buf_treal-3.qnty1
                  buf_temp-bon1.src-price = buf_treal-3.price-base
                  buf_temp-bon1.pay-sum  = buf_treal-3.netto
                  buf_temp-bon1.gds-code = buf_treal-3.gds-code
                  buf_temp-bon1.src-sum  = buf_temp-bon1.src-qnty * buf_temp-bon1.src-price
                  .
                  if buf_temp-bon1.item-type = 1 then do:
                    find first buf_temp-bon1-gds no-lock where
                            buf_temp-bon1-gds.gds-code = buf_temp-bon1.gds-code no-error.
                    if not available buf_temp-bon1-gds then do:
                      find first buf_goods no-lock where
                                buf_goods.gds-code = buf_temp-bon1.gds-code no-error.
                      create buf_temp-bon1-gds.
                      assign
                      buf_temp-bon1-gds.gds-code = buf_temp-bon1.gds-code
                      buf_temp-bon1-gds.gds-name = (if available buf_goods
                                                    then buf_goods.gds-name
                                                    else substitute("Неизвестное топливо &1", buf_temp-bon1.gds-code))
                      buf_temp-bon1.item-name = buf_temp-bon1-gds.gds-name
                      .
                    end.
                    else do:
                      assign
                      buf_temp-bon1.item-name = buf_temp-bon1-gds.gds-name
                      .
                    end.
                  end .
                  if buf_temp-bon1.item-type = 2 then do:
                    assign
                    buf_temp-bon1.item-name = "Соп. товары"
                    .
                  end.
                  find first obj-grp-op_temp-bon1 where
                            obj-grp-op_temp-bon1.obj-type = buf_temp-bon1.obj-type
                        and obj-grp-op_temp-bon1.obj-code = buf_temp-bon1.obj-code
                        and obj-grp-op_temp-bon1.item-name = buf_temp-bon1.item-name
                        and obj-grp-op_temp-bon1.item-type = buf_temp-bon1.item-type
                        and obj-grp-op_temp-bon1.gds-code = -1
                        and obj-grp-op_temp-bon1.op-code = buf_temp-bon1.op-code no-error.
                  if not available obj-grp-op_temp-bon1  then do:
                    create obj-grp-op_temp-bon1 .
                    assign
                    obj-grp-op_temp-bon1.obj-type = buf_temp-bon1.obj-type
                    obj-grp-op_temp-bon1.obj-code = buf_temp-bon1.obj-code
                    obj-grp-op_temp-bon1.item-name = buf_temp-bon1.item-name
                    obj-grp-op_temp-bon1.item-type = buf_temp-bon1.item-type
                    obj-grp-op_temp-bon1.gds-code = -1
                    obj-grp-op_temp-bon1.op-code = buf_temp-bon1.op-code
                    obj-grp-op_temp-bon1.level = 2
                  .
                end.
                  assign
                  obj-grp-op_temp-bon1.src-qnty = obj-grp-op_temp-bon1.src-qnty + buf_temp-bon1.src-qnty
                  obj-grp-op_temp-bon1.pay-sum = obj-grp-op_temp-bon1.pay-sum + buf_temp-bon1.pay-sum
                  obj-grp-op_temp-bon1.src-sum = obj-grp-op_temp-bon1.src-sum + buf_temp-bon1.src-sum
                  .
                  find first obj-grp_temp-bon1 where
                            obj-grp_temp-bon1.obj-type = buf_temp-bon1.obj-type
                        and obj-grp_temp-bon1.obj-code = buf_temp-bon1.obj-code
                        and obj-grp_temp-bon1.item-name = buf_temp-bon1.item-name
                        and obj-grp_temp-bon1.item-type = buf_temp-bon1.item-type
                        and obj-grp_temp-bon1.gds-code = -1
                        and obj-grp_temp-bon1.op-code = 0 no-error.
                  if not available obj-grp_temp-bon1  then do:
                    create obj-grp_temp-bon1 .
                    assign
                    obj-grp_temp-bon1.obj-type = buf_temp-bon1.obj-type
                    obj-grp_temp-bon1.obj-code = buf_temp-bon1.obj-code
                    obj-grp_temp-bon1.item-name = buf_temp-bon1.item-name
                    obj-grp_temp-bon1.item-type = buf_temp-bon1.item-type
                    obj-grp_temp-bon1.gds-code = -1
                    obj-grp_temp-bon1.op-code = 0
                    obj-grp_temp-bon1.level = 3
                    .
                  end.
                  assign
                  obj-grp_temp-bon1.src-qnty = obj-grp_temp-bon1.src-qnty + buf_temp-bon1.src-qnty
                  obj-grp_temp-bon1.pay-sum = obj-grp_temp-bon1.pay-sum + buf_temp-bon1.pay-sum
                  obj-grp_temp-bon1.src-sum = obj-grp_temp-bon1.src-sum + buf_temp-bon1.src-sum
                  .
                  find first obj-op_temp-bon1 where
                            obj-op_temp-bon1.obj-type = buf_temp-bon1.obj-type
                        and obj-op_temp-bon1.obj-code = buf_temp-bon1.obj-code
                        and obj-op_temp-bon1.item-type = 0
                        and obj-op_temp-bon1.item-name = '':U
                        and obj-op_temp-bon1.gds-code = -1
                        and obj-op_temp-bon1.op-code = buf_temp-bon1.op-code no-error.
                  if not available obj-op_temp-bon1  then do:
                    create obj-op_temp-bon1 .
                    assign
                    obj-op_temp-bon1.obj-type = buf_temp-bon1.obj-type
                    obj-op_temp-bon1.obj-code = buf_temp-bon1.obj-code
                    obj-op_temp-bon1.item-name = '':U
                    obj-op_temp-bon1.item-type = 0
                    obj-op_temp-bon1.gds-code = -1
                    obj-op_temp-bon1.op-code = buf_temp-bon1.op-code
                    obj-op_temp-bon1.level = 4
                    .
                  end.
                  assign
                  obj-op_temp-bon1.src-qnty = obj-op_temp-bon1.src-qnty + buf_temp-bon1.src-qnty
                  obj-op_temp-bon1.pay-sum = obj-op_temp-bon1.pay-sum + buf_temp-bon1.pay-sum
                  obj-op_temp-bon1.src-sum = obj-op_temp-bon1.src-sum + buf_temp-bon1.src-sum
                  .
                  find first obj_temp-bon1 where
                            obj_temp-bon1.obj-type = buf_temp-bon1.obj-type
                        and obj_temp-bon1.obj-code = buf_temp-bon1.obj-code
                        and obj_temp-bon1.item-name = '':U
                        and obj_temp-bon1.item-type = 0
                        and obj_temp-bon1.gds-code = -1
                        and obj_temp-bon1.op-code = 0 no-error.
                  if not available obj_temp-bon1  then do:
                    create obj_temp-bon1 .
                    assign
                    obj_temp-bon1.obj-type = buf_temp-bon1.obj-type
                    obj_temp-bon1.obj-code = buf_temp-bon1.obj-code
                    obj_temp-bon1.item-name = '':U
                    obj_temp-bon1.item-type = 0
                    obj_temp-bon1.gds-code = -1
                    obj_temp-bon1.op-code = 0
                    obj_temp-bon1.level = 5
                    .
                  end.
                  assign
                  obj_temp-bon1.src-qnty = obj_temp-bon1.src-qnty + buf_temp-bon1.src-qnty
                  obj_temp-bon1.pay-sum = obj_temp-bon1.pay-sum + buf_temp-bon1.pay-sum
                  obj_temp-bon1.src-sum = obj_temp-bon1.src-sum + buf_temp-bon1.src-sum
                  .
                end.
                end.
            end.
          end.
        end.
      end.
    end.
  end.
end procedure.
