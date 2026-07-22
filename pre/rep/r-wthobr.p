block-level on error undo, throw.
define input  parameter parparentproc         as handle    no-undo .
define input  parameter p-rs-supp             as integer   no-undo .
define input  parameter p-rs-wth-type         as integer   no-undo .
define input  parameter p-rs-wth              as integer   no-undo .
define input  parameter p-cb-wth-detail       as integer   no-undo .
define input  parameter p-clients-recid-list  as character no-undo .
define input  parameter p-wth-recid-list      as character no-undo .
define input  parameter p-dt-calc             as integer   no-undo .
define input  parameter p-dtFrom              as date      no-undo .
define input  parameter p-dtTo                as date      no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-wthobr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-wthobr.p $":U .
define variable vss-description as character no-undo init "Отчет оборотная ведомость серийных МЦ по контрагентам".
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
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure factord :
  define input  parameter p-fact-date            as date    no-undo .
  define input  parameter p-fact-time            as integer no-undo .
  define input  parameter p-fact-num             as integer no-undo .
  define input  parameter p-shift-date           as date    no-undo .
  define input  parameter p-shift-num            as integer no-undo .
  define input  parameter p-shift-on             as logical no-undo .
  define output parameter p-fact-order           as decimal no-undo .
  define output parameter p-shift-end-fact-order as decimal no-undo .
  define output parameter p-day-end-fact-order   as decimal no-undo .
  define variable vss-description as character no-undo init "factord: Определение порядкового номера документа".
  if p-fact-date = ?
  then do:
    return error "Не указана фактическая дата" .
  end.
  define variable v-fact-date-num as integer no-undo .
  assign
    v-fact-date-num = integer(p-fact-date)
  .
  if p-fact-num = ?
  or p-fact-num = 0
  then do:
    return error "Не задан p-fact-num " + string(p-fact-num) .
  end.
  if p-fact-num < 0
  then do:
    return error "Отрицательный fact-num " + string(p-fact-num) .
  end.
  if p-fact-num >= 100000000
  then do:
    return error "Недопустимо большой fact-num " + string(p-fact-num) .
  end.
  if p-shift-on = true
  then do:
    if p-shift-date = ?
    then do:
      return error "Не задана дата смены" .
    end.
    if p-shift-num = ?
    or p-shift-num = 0
    then do:
      return error "Не задан номер смены" .
    end.
  end.
  else do:
    assign
      p-shift-date = p-fact-date
      p-shift-num  = 24
    .
  end.
  define variable v-shift-offset as integer no-undo .
  if p-shift-date = p-fact-date
  then do:
    assign
      v-shift-offset = 1
    .
  end.
  if p-shift-date < p-fact-date
  then do:
    assign
      v-shift-offset = 0
    .
  end.
  if p-shift-date > p-fact-date
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильная дата закрытия смены" skip
      "Дата закрытия не смены не может быть раньше чем дата открытия смены" skip
      view-as alert-box error .
    undo, return error
      substitute("Дата закрытия не смены &1 не может быть раньше чем дата открытия смены &2"
        ,string(p-fact-date, '99/99/9999':U)
        ,string(p-shift-date, '99/99/9999':U)
        )
    .
  end.
  if p-shift-num < 1
  or p-shift-num > 24
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильный номер смены" skip
      "p-shift-num" p-shift-num skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  assign
    p-fact-order           = v-fact-date-num
                           + v-shift-offset * 0.5
                           + p-shift-num    * 0.02 - 0.01
                           + p-fact-num     * 0.0000000001
    p-shift-end-fact-order = v-fact-date-num
                           + v-shift-offset * 0.5
                           + p-shift-num    * 0.02
    p-day-end-fact-order   = v-fact-date-num
                           + 0.99
  .
  if p-fact-order           <= v-fact-date-num
  or p-shift-end-fact-order <= v-fact-date-num
  or p-fact-order           >= p-shift-end-fact-order - 0.0000000001
  or p-shift-end-fact-order >= p-day-end-fact-order
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Внутренняя ошибка при генерации фактического номера" skip
      "p-fact-date"            p-fact-date            skip
      "p-fact-time"            p-fact-time            skip
      "p-fact-num"             p-fact-num             skip
      "p-shift-date"           p-shift-date           skip
      "p-shift-num"            p-shift-num            skip
      "p-shift-on"             p-shift-on             skip
      "p-shift-end-fact-order" p-shift-end-fact-order skip
      "p-day-end-fact-order"   p-day-end-fact-order   skip
      "v-fact-date-num"        v-fact-date-num        skip
      view-as alert-box error .
    undo, return error return-value .
  end.
end procedure.
procedure day-begin-fact-order :
  define input  parameter p-fact-date            as date    no-undo .
  define output parameter p-day-begin-fact-order as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-date = ?
    then do:
      assign
        p-day-begin-fact-order = 0
      .
    end.
    else do:
      assign
        p-day-begin-fact-order = integer(p-fact-date)
      .
    end.
  end.
end procedure.
procedure factord-max-fact-order :
  define output parameter p-max-fact-order as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    run day-begin-fact-order in this-procedure
      (input  date(1, 1, 5000)
      ,output p-max-fact-order
      ) .
  end.
end procedure.
procedure factord-cut-archive :
  define input  parameter p-obj-type             as character no-undo .
  define input  parameter p-obj-code             as integer   no-undo .
  define input  parameter p-fact-date            as date      no-undo .
  define output parameter p-shift-on             as logical   no-undo .
  define output parameter p-shift-date           as date      no-undo .
  define output parameter p-shift-num            as integer   no-undo .
  define output parameter p-day-end-fact-order   as decimal   no-undo .
  define output parameter p-shift-end-fact-order as decimal   no-undo .
  define variable v-fact-order as decimal   no-undo .
  define buffer buf_shift-obj for ub.shift-obj .
  do
  on error undo, return error return-value
  :
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output p-shift-on
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута объекта" skip
        "Объект" p-obj-type p-obj-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-shift-on = false
    then do:
      assign
        p-shift-date               = ?
        p-shift-num                = 0
      .
    end.
    else do:
      find first buf_shift-obj share-lock
        where buf_shift-obj.obj-type   = p-obj-type
          and buf_shift-obj.obj-code   = p-obj-code
          and buf_shift-obj.shift-date > p-fact-date
        use-index pi
        no-error .
      if not available buf_shift-obj
      or buf_shift-obj.status_ <> 'зкр':U
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Невозможно вычислить последнюю смену" skip
          "Отсутствует закрытая смена с датой большей чем дата инициализации архива" skip
          "Объект" p-obj-type p-obj-code skip
          "Дата" p-fact-date skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      find last buf_shift-obj share-lock
        where buf_shift-obj.obj-type = p-obj-type
          and buf_shift-obj.obj-code = p-obj-code
          and buf_shift-obj.shift-date <= p-fact-date
        use-index pi
        no-error .
      if available buf_shift-obj
      then do:
        if  buf_shift-obj.status_ = 'зкр':U
        then do:
          assign
            p-shift-date = buf_shift-obj.shift-date
            p-shift-num  = buf_shift-obj.shift-num
          .
        end.
        else do:
          message
            vss-workfile vss-revision vss-description skip
            "Невозможно вычислить последнюю смену" skip
            "Статус смены отличен от статуса" 'зкр':U skip
            "Объект" p-obj-type p-obj-code skip
            "Дата" p-fact-date skip
            "Смена" buf_shift-obj.shift-date buf_shift-obj.shift-num skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end.
      else do:
        assign
          p-shift-date = p-fact-date - 1
          p-shift-num  = 1
        .
      end.
    end.
    run factord in this-procedure
      (input  p-fact-date
      ,input  1
      ,input  1
      ,input  p-shift-date
      ,input  p-shift-num
      ,input  p-shift-on
      ,output v-fact-order
      ,output p-shift-end-fact-order
      ,output p-day-end-fact-order
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры factord"
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure factord-lock-shift :
  define input  parameter p-obj-type  as character no-undo .
  define input  parameter p-obj-code  as integer   no-undo .
  define input  parameter p-fact-date as date      no-undo .
  define parameter buffer buf_shift-obj for ub.shift-obj .
  define variable v-shift-on      as logical   no-undo .
  define variable v-extra-message as character no-undo .
  define variable v-error as character no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output v-shift-on
  ) no-error .
    if error-status :error
    then do:
      v-error = substitute("Ошибка при определении атрибута объекта  &1 &2 &3 &4" ,p-obj-type , p-obj-code  , error-status :get-message(1) , return-value) .
      undo, return error v-error .
    end.
    if v-shift-on = true
    then do:
      find first buf_shift-obj share-lock
        where buf_shift-obj.obj-type   = p-obj-type
          and buf_shift-obj.obj-code   = p-obj-code
          and buf_shift-obj.shift-date > p-fact-date
        use-index pi
        no-error .
      if not available buf_shift-obj
      or buf_shift-obj.status_ <> 'зкр':U
      then do:
        find last buf_shift-obj
          where buf_shift-obj.obj-type = p-obj-type
            and buf_shift-obj.obj-code = p-obj-code
            and buf_shift-obj.status_  = 'зкр':U
          use-index stts
          no-error .
        if available buf_shift-obj
        then do:
          assign
            v-extra-message =
                  substitute("Дата начала последеней закрытой смены на объекте &1"
                            ,string(buf_shift-obj.shift-date, '99/99/9999':u)
                            )
          .
        end.
        v-error = substitute("Ошибка при блокировке смены объекта  &1 &2 Отсутствует закрытая смена с датой большей чем указанная дата  &5  &3 &4" ,p-obj-type , p-obj-code  , error-status :get-message(1) , return-value , p-fact-date) .
        undo, return error v-error .
      end.
    end.
  end.
end procedure.
procedure factord-end-day :
  define input  parameter p-fact-date            as date    no-undo .
  define output parameter p-day-end-fact-order   as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-date = ?
    then do:
      return error "Не указана фактическая дата" .
    end.
    assign
      p-day-end-fact-order = integer(p-fact-date) + 0.99
    .
  end.
end procedure.
procedure factord-to-date :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-fact-date  as date    no-undo .
  define variable v-ref-date  as date      no-undo .
  define variable v-ref-delta as integer   no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
      v-ref-date  = date(1, 1, 2000)
    .
    assign
      v-ref-delta = integer(truncate(p-fact-order, 0)) - integer(v-ref-date)
    .
    assign
      p-fact-date = v-ref-date + v-ref-delta
    .
  end.
end procedure.
procedure factord-to-fact-num :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-fact-num   as integer no-undo .
  define variable v-fact-order-trunc as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
     v-fact-order-trunc = truncate(p-fact-order, 2)
    .
    assign
      p-fact-num = (p-fact-order - v-fact-order-trunc ) * 10000000000
    .
  end.
end procedure.
procedure factord-to-shift-num :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-shift-num   as integer no-undo .
  define variable  p-shift-numd  as decimal   no-undo .
  define variable v-fact-order-trunc as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
     v-fact-order-trunc = truncate(p-fact-order, 2)  - truncate(p-fact-order,0)
    .
    if v-fact-order-trunc < 0.5 then do:
      v-fact-order-trunc = v-fact-order-trunc + 0.5.
    end.
    assign
      p-shift-numd = (( v-fact-order-trunc  * 100 - 50 ) + 1 ) / 2
      .
     assign
      p-shift-num = truncate (p-shift-numd , 0)
    .
  end.
end procedure.
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
define variable g#report-num  as integer no-undo .
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
    field sheet-name          as character
    field xl-line-id          as integer
    field cli-name            as character
    field talon-name          as character
    field talon-nominal       as character
    field talon-series        as character
    field give-sum-units      as character
    field give-sum-money      as character
    field chg-give-sum-units  as character
    field chg-give-sum-money  as character
    field sell-sum-units      as character
    field sell-sum-money      as character
    field ret-sum-units       as character
    field ret-sum-money       as character
    field chg-ret-sum-units   as character
    field chg-ret-sum-money   as character
    field spi-sum-units       as character
    field spi-sum-money       as character
    field restFrom-units      as character
    field restFrom-money      as character
    field restEnd-units       as character
    field restEnd-money       as character
    index pi is primary unique
        xl-line-id
.
define variable v-wthobrxl-sheet1-cur-data-row  as integer      no-undo.
define variable v-wthobrxl-cell-file-name       as character    no-undo.
define variable v-wthobrxl-data-file-name       as character    no-undo.
procedure wthobrxl-init :
do
on error undo, return error
:
    assign
        v-wthobrxl-sheet1-cur-data-row = 0
    .
    run gbl/_tmpfile.p (
          input "xd"
        , input ".txt"
        , output v-wthobrxl-data-file-name
    ).
    output stream excel-line to value( v-wthobrxl-data-file-name ).
    run gbl/_tmpfile.p (
          input "xc"
        , input ".txt"
        , output v-wthobrxl-cell-file-name
    ).
    output stream excel-cell to value( v-wthobrxl-cell-file-name ).
    run wthobrxl-write-cell-data in this-procedure (
          input "sheetList":U
        , input "Лист1":U
    ).
    run wthobrxl-write-cell-data in this-procedure (
          input "Лист1_regularExpressions":U
        , input "1":U
    ).
    if printrubl
    then do:
        run wthobrxl-write-cell-data in this-procedure (
              input "Лист1_valutCode":U
            , input "0":U
        ).
    end.
    else do:
        run wthobrxl-write-cell-data in this-procedure (
              input "Лист1_valutCode":U
            , input "1":U
        ).
    end.
    run wthobrxl-write-cell-data in this-procedure (
          input "Лист1_columnList":U
        , input "cliname,talonname,talonnominal,talonser,givesumunits,givesummoney,chggivesumunits,chggivesummoney,sellsumunits,sellsummoney,retsumunits,retsummoney,chgretsumunits,chgretsummoney,spisumunits,spisummoney,restfromunits,restfrommoney,restendunits,restendmoney":U
    ).
    run wthobrxl-write-cell-data in this-procedure (
          input "Лист1_columnType":U
        , input "S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S":U
    ).
    run wthobrxl-write-cell-data in this-procedure (
          input "Лист1_subtotalList":U
        , input "":U
    ).
    run wthobrxl-write-cell-data in this-procedure (
          input "Лист1_subtotalType":U
        , input "":U
    ).
end.
end procedure.
procedure wthobrxl-write-line-data :
define input parameter p-cli-name            as character no-undo .
define input parameter p-talon-name          as character no-undo .
define input parameter p-talon-nominal       as character no-undo .
define input parameter p-talon-series        as character no-undo .
define input parameter p-give-sum-units      as character no-undo .
define input parameter p-give-sum-money      as character no-undo .
define input parameter p-chg-give-sum-units  as character no-undo .
define input parameter p-chg-give-sum-money  as character no-undo .
define input parameter p-sell-sum-units      as character no-undo .
define input parameter p-sell-sum-money      as character no-undo .
define input parameter p-ret-sum-units       as character no-undo .
define input parameter p-ret-sum-money       as character no-undo .
define input parameter p-chg-ret-sum-units   as character no-undo .
define input parameter p-chg-ret-sum-money   as character no-undo .
define input parameter p-spi-sum-units       as character no-undo .
define input parameter p-spi-sum-money       as character no-undo .
define input parameter p-RestFrom-units      as character no-undo .
define input parameter p-restFrom-money      as character no-undo .
define input parameter p-restEnd-units       as character no-undo .
define input parameter p-restEnd-money       as character no-undo .
define buffer buf_temp_sheet1_line-data      for temp_sheet1_line-data.
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
        v-wthobrxl-sheet1-cur-data-row = v-wthobrxl-sheet1-cur-data-row + 1
    .
    assign
        buf_temp_sheet1_line-data.sheet-name          = "Лист1":U
        buf_temp_sheet1_line-data.xl-line-id          = v-wthobrxl-sheet1-cur-data-row
        buf_temp_sheet1_line-data.cli-name            = p-cli-name
        buf_temp_sheet1_line-data.talon-name          = p-talon-name
        buf_temp_sheet1_line-data.talon-nominal       = p-talon-nominal
        buf_temp_sheet1_line-data.talon-series        = p-talon-series
        buf_temp_sheet1_line-data.give-sum-units      = p-give-sum-units
        buf_temp_sheet1_line-data.give-sum-money      = p-give-sum-money
        buf_temp_sheet1_line-data.chg-give-sum-units  = p-chg-give-sum-units
        buf_temp_sheet1_line-data.chg-give-sum-money  = p-chg-give-sum-money
        buf_temp_sheet1_line-data.sell-sum-units      = p-sell-sum-units
        buf_temp_sheet1_line-data.sell-sum-money      = p-sell-sum-money
        buf_temp_sheet1_line-data.ret-sum-units       = p-ret-sum-units
        buf_temp_sheet1_line-data.ret-sum-money       = p-ret-sum-money
        buf_temp_sheet1_line-data.chg-ret-sum-units   = p-chg-ret-sum-units
        buf_temp_sheet1_line-data.chg-ret-sum-money   = p-chg-ret-sum-money
        buf_temp_sheet1_line-data.spi-sum-units       = p-spi-sum-units
        buf_temp_sheet1_line-data.spi-sum-money       = p-spi-sum-money
        buf_temp_sheet1_line-data.RestFrom-units      = p-RestFrom-units
        buf_temp_sheet1_line-data.restFrom-money      = p-restFrom-money
        buf_temp_sheet1_line-data.restEnd-units       = p-restEnd-units
        buf_temp_sheet1_line-data.restEnd-money       = p-restEnd-money
    .
    put stream excel-line unformatted
                        buf_temp_sheet1_line-data.sheet-name
        CHR(9)   "DTA":U
        CHR(9)   buf_temp_sheet1_line-data.cli-name
        CHR(9)   buf_temp_sheet1_line-data.talon-name
        CHR(9)   buf_temp_sheet1_line-data.talon-nominal
        CHR(9)   buf_temp_sheet1_line-data.talon-series
        CHR(9)   buf_temp_sheet1_line-data.give-sum-units
        CHR(9)   buf_temp_sheet1_line-data.give-sum-money
        CHR(9)   buf_temp_sheet1_line-data.chg-give-sum-units
        CHR(9)   buf_temp_sheet1_line-data.chg-give-sum-money
        CHR(9)   buf_temp_sheet1_line-data.sell-sum-units
        CHR(9)   buf_temp_sheet1_line-data.sell-sum-money
        CHR(9)   buf_temp_sheet1_line-data.ret-sum-units
        CHR(9)   buf_temp_sheet1_line-data.ret-sum-money
        CHR(9)   buf_temp_sheet1_line-data.chg-ret-sum-units
        CHR(9)   buf_temp_sheet1_line-data.chg-ret-sum-money
        CHR(9)   buf_temp_sheet1_line-data.spi-sum-units
        CHR(9)   buf_temp_sheet1_line-data.spi-sum-money
        CHR(9)   buf_temp_sheet1_line-data.RestFrom-units
        CHR(9)   buf_temp_sheet1_line-data.restFrom-money
        CHR(9)   buf_temp_sheet1_line-data.restEnd-units
        CHR(9)   buf_temp_sheet1_line-data.restEnd-money
        chr(10)
    .
end.
end procedure.
procedure wthobrxl-write-cell-data :
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
procedure wthobrxl-sheet1-write-line-format :
define input parameter p-fmt-label       as character  no-undo.
    define buffer buf_temp_sheet1_line-data        for temp_sheet1_line-data.
do
for buf_temp_sheet1_line-data
on error undo, return error
:
    put stream excel-line unformatted
                        "Лист1":U
        CHR(9)   "FMT":U
        CHR(9)   p-fmt-label
        chr(10)
    .
end.
end procedure.
procedure wthobrxl-run-excel :
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
        v-template-file-name    = search( "exe/wth-obr.xlt" )
        v-vb-file-name          = search( "exe/t_form.bas" )
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
procedure wthobrxl-close :
do
on error undo, return error
:
    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append.
        export "exe/wth-obr.xlt":U.
        export "exe/t_form.bas":U.
        export v-wthobrxl-cell-file-name.
        export v-wthobrxl-data-file-name.
    output close.
end.
end procedure.
define temp-table tt-clients  no-undo like ub.clients.
define temp-table tt-wealth   no-undo like ub.wealth.
define temp-table tt-wth-par  no-undo like ub.wth-par.
define temp-table tt-wth-ser  no-undo like ub.wth-ser.
define temp-table tt-wth-parts  no-undo like ub.wth-parts
index idx-cli-dt cli-type
              cli-code
              beg-dt
              ext-doc-type
              out-code
index idx-cli-fact cli-type
                   cli-code
                   fact-date
                   ext-doc-type
                   out-code
.
define temp-table tt-rest  no-undo like ub.wth-parts
index idx-cli-fact cli-type
                   cli-code
                   fact-date
                   ext-doc-type
                   out-code
.
define temp-table tt-report no-undo
  field cli-type            like ub.clients.obj-type
  field cli-code            like ub.clients.obj-code
  field wth-code            like ub.wealth.wth-code
  field par-code            like ub.wth-par.par-code
  field par-val             like ub.wth-par.par-val
  field ser-code            like ub.wth-ser.ser-code
  field db-num              like ub.wth-ser.db-num
  field cli-name            as character
  field talon-name          as character
  field talon-nominal       as character
  field talon-series        as character
  field give-sum-units      as decimal
  field give-sum-money      as decimal
  field chg-give-sum-units  as decimal
  field chg-give-sum-money  as decimal
  field sell-sum-units      as decimal
  field sell-sum-money      as decimal
  field ret-sum-units       as decimal
  field ret-sum-money       as decimal
  field chg-ret-sum-units   as decimal
  field chg-ret-sum-money   as decimal
  field spi-sum-units       as decimal
  field spi-sum-money       as decimal
  field restFrom-units      as decimal
  field restFrom-money      as decimal
  field restEnd-units      as decimal
  field restEnd-money      as decimal
index pi is primary unique
  cli-type
  cli-code
  wth-code
  par-code
  ser-code
  db-num
.
define temp-table tt-report-cli no-undo
  field cli-type            like ub.clients.obj-type
  field cli-code            like ub.clients.obj-code
  field give-sum-units      as decimal
  field give-sum-money      as decimal
  field chg-give-sum-units  as decimal
  field chg-give-sum-money  as decimal
  field sell-sum-units      as decimal
  field sell-sum-money      as decimal
  field ret-sum-units       as decimal
  field ret-sum-money       as decimal
  field chg-ret-sum-units   as decimal
  field chg-ret-sum-money   as decimal
  field spi-sum-units       as decimal
  field spi-sum-money       as decimal
  field restFrom-units      as decimal
  field restFrom-money      as decimal
  field restEnd-units       as decimal
  field restEnd-money       as decimal
index pi is primary unique
  cli-type
  cli-code
.
define stream out-stream.
define buffer buf_wealth      for ub.wealth.
define buffer buf_wth-gds     for ub.wth-gds.
define buffer buf_wth-par     for ub.wth-par.
define buffer buf_goods       for ub.goods.
define buffer buf_objects     for ub.clients.
define variable v-is-wth-restrict   as logical   no-undo .
define variable v-is-par-restrict   as logical   no-undo .
define variable v-is-ser-restrict   as logical   no-undo .
define variable v-print-rubl        as logical   no-undo .
define variable v-fact-order-start  as decimal   no-undo .
define variable v-fact-order-end    as decimal   no-undo .
define variable v-line              as character no-undo .
do on error undo, return error return-value
:
  assign
    v-line = fill( "-" , 300 )
  .
   if lookup( string(p-cb-wth-detail) , "1,2,3,4":U ) = 0
   then do:
    message
      "Неверно указан уровень детализации!"
    view-as alert-box error.
    return error .
   end.
if session :set-wait-state( "compiler" ) then.
  run get-report-num in my-handle (output g#report-num).
output stream out-stream to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size 62 .
  run wthobrxl-init in this-procedure .
  run fill-tt in this-procedure .
  run waitfram-show in this-procedure ("Печать отчета...") .
  run print-header in this-procedure .
  run print-report in this-procedure .
  run waitfram-hide in this-procedure .
  put stream out-stream unformatted " "  skip.
  run clear-tt in this-procedure .
  run wthobrxl-close in this-procedure .
  output stream out-stream close.
  if Make-Excel then output stream ForExcel close.
if session :set-wait-state( "" ) then.
  os-delete value( string( session:temp-directory ) + "rpt" + string( g#report-num ) + ".txl" )  .
  os-rename
    value( string( session:temp-directory ) + "$" + string( g#report-num ) + ".txl" )
    value( string( session:temp-directory ) + "rpt" + string( g#report-num ) + ".txl" )
  .
  define variable v-user-action   as character no-undo .
  define variable v-printed       as logical   no-undo .
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
      ,input  20
      ,input  string(session :temp-directory) + "rpt" + string( g#report-num )
      ,input  ReportFontNum
      ,output v-user-action
      ,output v-printed
      ) .
  os-delete value( string( session:temp-directory ) + "rpt" + string( g#report-num ) ) .
  os-delete value( string( session:temp-directory ) + "rpt" + string( g#report-num ) + ".txl" ) .
end.
procedure clear-tt :
do
on error undo, return error return-value
:
 empty temp-table tt-clients.
 empty temp-table tt-wealth .
 empty temp-table tt-wth-par.
 empty temp-table tt-wth-ser.
 empty temp-table tt-report .
 empty temp-table tt-report-cli .
 empty temp-table tt-wth-parts .
end.
end procedure.
procedure fill-tt :
do
on error undo, return error return-value
:
  define buffer buf_wealth        for ub.wealth .
  define buffer buf_wth-par       for ub.wth-par.
  define buffer buf_wth-ser       for ub.wth-ser.
  define buffer buf_clients       for ub.clients.
  define buffer buf_wth-parts     for tt-wth-parts.
  define buffer b_wth-parts       for ub.wth-parts.
  define buffer buf_tt-clients    for tt-clients.
  define buffer buf_tt-wealth     for tt-wealth .
  define buffer buf_tt-wth-par    for tt-wth-par.
  define buffer buf_tt-wth-ser    for tt-wth-ser.
  define buffer buf_tt-report     for tt-report .
  define buffer buf_tt-report-cli for tt-report-cli.
  define variable v-give-sum-units      as decimal   no-undo .
  define variable v-give-sum-money      as decimal   no-undo .
  define variable v-chg-give-sum-units  as decimal   no-undo .
  define variable v-chg-give-sum-money  as decimal   no-undo .
  define variable v-sell-sum-units      as decimal   no-undo .
  define variable v-sell-sum-money      as decimal   no-undo .
  define variable v-ret-sum-units       as decimal   no-undo .
  define variable v-ret-sum-money       as decimal   no-undo .
  define variable v-chg-ret-sum-units   as decimal   no-undo .
  define variable v-chg-ret-sum-money   as decimal   no-undo .
  define variable v-spi-sum-units       as decimal   no-undo .
  define variable v-spi-sum-money       as decimal   no-undo .
  define variable v-restFrom-units      as decimal   no-undo .
  define variable v-restFrom-money      as decimal   no-undo .
  define variable v-restEnd-units       as decimal   no-undo .
  define variable v-restEnd-money       as decimal   no-undo .
  define variable v-i                   as integer   no-undo .
  define variable v-total               as integer   no-undo .
  define variable v-counter             as integer   no-undo .
  define variable v-repfrm-str          as character no-undo .
  run clear-tt in this-procedure .
  run waitfram-show in this-procedure ("Обработка данных...") .
  if p-clients-recid-list <> ''
  then do:
    assign
      v-total = num-entries(p-clients-recid-list)
    .
    do v-i = 1 to v-total:
      find first buf_clients no-lock
        where recid(buf_clients) = integer(entry(v-i,p-clients-recid-list))
      no-error .
      if available buf_clients
      then do:
        find first buf_tt-clients
          where buf_tt-clients.obj-type = buf_clients.obj-type
            and buf_tt-clients.obj-code = buf_clients.obj-code
        no-error .
        if not available buf_tt-clients
        then do:
          create buf_tt-clients.
          buffer-copy buf_clients to buf_tt-clients.
        end.
      end.
    end.
  end.
  else do:
    for each buf_clients no-lock
    :
      find first buf_tt-clients
        where buf_tt-clients.obj-type = buf_clients.obj-type
          and buf_tt-clients.obj-code = buf_clients.obj-code
      no-error .
      if not available buf_tt-clients
      then do:
        create buf_tt-clients.
        buffer-copy buf_clients to buf_tt-clients.
      end.
    end.
  end.
  if p-wth-recid-list <> ''
  then do:
    assign
      v-total = num-entries(p-wth-recid-list)
    .
    case p-rs-wth-type:
      when 1 then do:
        assign
          v-is-wth-restrict = yes
        .
        do v-i = 1 to v-total
        :
          find first buf_wealth no-lock
            where recid(buf_wealth) = integer( entry( v-i , p-wth-recid-list ) )
          no-error .
          if available buf_wealth then do:
            find first buf_tt-wealth no-lock
              where buf_tt-wealth.wth-code = buf_wealth.wth-code
            no-error .
            if not available buf_tt-wealth then do:
              create buf_tt-wealth.
              buffer-copy buf_wealth to buf_tt-wealth.
            end.
          end.
        end.
      end.
      when 2 then do:
        assign
          v-is-par-restrict = yes
        .
        do v-i = 1 to v-total
        :
          find first buf_wth-par no-lock
            where recid(buf_wth-par) = integer( entry( v-i , p-wth-recid-list ) )
          no-error .
          if available buf_wth-par then do:
            find first buf_tt-wth-par no-lock
              where buf_tt-wth-par.wth-code = buf_wth-par.wth-code
                and buf_tt-wth-par.par-code = buf_wth-par.par-code
            no-error .
            if not available buf_tt-wth-par then do:
              create buf_tt-wth-par.
              buffer-copy buf_wth-par to buf_tt-wth-par.
            end.
          end.
        end.
      end.
      when 3 then do:
        assign
          v-is-ser-restrict = yes
        .
        do v-i = 1 to v-total
        :
          find first buf_wth-ser no-lock
            where recid(buf_wth-ser) = integer( entry( v-i , p-wth-recid-list ) )
          no-error .
          if available buf_wth-ser then do :
            find first buf_tt-wth-ser no-lock
              where buf_tt-wth-ser.ser-code = buf_wth-ser.ser-code
                and buf_tt-wth-ser.db-num   = buf_wth-ser.db-num
            no-error .
            if not available buf_tt-wth-ser then do:
              create buf_tt-wth-ser.
              buffer-copy buf_wth-ser to buf_tt-wth-ser.
            end.
          end.
        end.
      end.
    end case .
  end.
  run waitfram-hide in this-procedure .
  assign
    v-repfrm-str = "Расчет партий МЦ..."
  .
  etime(yes).
if p-dt-calc = 1 then do:
    if p-wth-recid-list <> '' and p-rs-wth-type = 1  then   do:
        for each buf_tt-wealth no-lock,
        each b_wth-parts no-lock where b_wth-parts.fact-date >= x-date-start
                                        and b_wth-parts.fact-date <= x-date-end
                                        and b_wth-parts.wth-code = buf_tt-wealth.wth-code
                                        and lookup(b_wth-parts.out-code,'free-zone,out-zone,cli-zone,фальшивый,put-zone':u) = 0
                                        and (b_wth-parts.ext-doc-type = 'ee':U or
                                              b_wth-parts.ext-doc-type = 'xc':U    or
                                              b_wth-parts.ext-doc-type = 'pz':U or
                                              b_wth-parts.ext-doc-type = 'dc':U or
                                              b_wth-parts.ext-doc-type = 'pc':U or
                                              b_wth-parts.ext-doc-type = 'ps':U)
                                        and b_wth-parts.fact-num <> 0    :
            create tt-wth-parts.
            buffer-copy b_wth-parts to tt-wth-parts.
        end.
        for each buf_tt-wealth no-lock,
        each b_wth-parts no-lock where ((b_wth-parts.fact-date > x-date-end and lookup(b_wth-parts.out-code,'free-zone,out-zone,cli-zone,фальшивый,put-zone':u) = 0 and b_wth-parts.fact-num <> 0 ) or b_wth-parts.out-code = 'cli-zone':U )
                                        and b_wth-parts.wth-code = buf_tt-wealth.wth-code
                                        and (b_wth-parts.ext-doc-type = 'ee':U or
                                              b_wth-parts.ext-doc-type = 'xc':U    or
                                              b_wth-parts.ext-doc-type = 'pz':U or
                                              b_wth-parts.ext-doc-type = 'dc':U or
                                              b_wth-parts.ext-doc-type = 'pc':U or
                                              b_wth-parts.ext-doc-type = 'ps':U)
                                       :
            create tt-rest.
            buffer-copy b_wth-parts to tt-rest.
        end.
    end.
    else if p-wth-recid-list <> '' and p-rs-wth-type = 2 then do:
        for each buf_tt-wth-par no-lock ,
            each b_wth-parts no-lock where b_wth-parts.fact-date >= x-date-start
                                        and b_wth-parts.fact-date <= x-date-end
                                        and b_wth-parts.wth-code = buf_tt-wth-par.wth-code
                                        and b_wth-parts.par-code = buf_tt-wth-par.par-code
                                        and lookup(b_wth-parts.out-code,'free-zone,out-zone,cli-zone,фальшивый,put-zone':u) = 0
                                        and (b_wth-parts.ext-doc-type = 'ee':U or
                                              b_wth-parts.ext-doc-type = 'xc':U    or
                                              b_wth-parts.ext-doc-type = 'pz':U or
                                              b_wth-parts.ext-doc-type = 'dc':U or
                                              b_wth-parts.ext-doc-type = 'pc':U or
                                              b_wth-parts.ext-doc-type = 'ps':U)
                                        and b_wth-parts.fact-num <> 0 :
            create tt-wth-parts.
            buffer-copy b_wth-parts to tt-wth-parts.
        end.
        for each buf_tt-wth-par no-lock ,
            each b_wth-parts no-lock where ((b_wth-parts.fact-date > x-date-end and lookup(b_wth-parts.out-code,'free-zone,out-zone,cli-zone,фальшивый,put-zone':u) = 0 and b_wth-parts.fact-num <> 0 ) or b_wth-parts.out-code = 'cli-zone':U )
                                        and b_wth-parts.wth-code = buf_tt-wth-par.wth-code
                                        and b_wth-parts.par-code = buf_tt-wth-par.par-code
                                        and (b_wth-parts.ext-doc-type = 'ee':U or
                                              b_wth-parts.ext-doc-type = 'xc':U    or
                                              b_wth-parts.ext-doc-type = 'pz':U or
                                              b_wth-parts.ext-doc-type = 'dc':U or
                                              b_wth-parts.ext-doc-type = 'pc':U or
                                              b_wth-parts.ext-doc-type = 'ps':U):
            create tt-rest.
            buffer-copy b_wth-parts to tt-rest.
        end.
    end.
    else do:
        for each b_wth-parts no-lock where b_wth-parts.fact-date >= x-date-start
                                        and b_wth-parts.fact-date <= x-date-end
                                        and lookup(b_wth-parts.out-code,'free-zone,out-zone,cli-zone,фальшивый,put-zone':u) = 0
                                        and (b_wth-parts.ext-doc-type = 'ee':U or
                                              b_wth-parts.ext-doc-type = 'xc':U    or
                                              b_wth-parts.ext-doc-type = 'pz':U or
                                              b_wth-parts.ext-doc-type = 'dc':U or
                                              b_wth-parts.ext-doc-type = 'pc':U or
                                              b_wth-parts.ext-doc-type = 'ps':U)
                                       and b_wth-parts.fact-num <> 0 :
            create tt-wth-parts.
            buffer-copy b_wth-parts to tt-wth-parts.
        end.
        for each b_wth-parts no-lock where ((b_wth-parts.fact-date > x-date-end and lookup(b_wth-parts.out-code,'free-zone,out-zone,cli-zone,фальшивый,put-zone':u) = 0 and b_wth-parts.fact-num <> 0 ) or b_wth-parts.out-code = 'cli-zone':U )
                                         and (b_wth-parts.ext-doc-type = 'ee':U or      b_wth-parts.ext-doc-type = 'xc':U    or      b_wth-parts.ext-doc-type = 'pz':U or      b_wth-parts.ext-doc-type = 'dc':U or       b_wth-parts.ext-doc-type = 'pc':U or       b_wth-parts.ext-doc-type = 'ps':U) :
            create tt-rest.
            buffer-copy b_wth-parts to tt-rest.
        end.
    end.
end.
if p-dt-calc = 2 then do:
 for each b_wth-parts no-lock where b_wth-parts.beg-dt >= x-date-start
                                and b_wth-parts.beg-dt <= x-date-end
                                and (b_wth-parts.ext-doc-type = 'ee':U or      b_wth-parts.ext-doc-type = 'xc':U    or      b_wth-parts.ext-doc-type = 'pz':U or      b_wth-parts.ext-doc-type = 'dc':U or       b_wth-parts.ext-doc-type = 'pc':U or       b_wth-parts.ext-doc-type = 'ps':U):
    create tt-wth-parts.
    buffer-copy b_wth-parts to tt-wth-parts.
 end.
 if p-wth-recid-list <> '' and p-rs-wth-type = 1  then
    for each buf_tt-wealth no-lock,
    each b_wth-parts no-lock where b_wth-parts.beg-dt >= x-date-start
                                and b_wth-parts.beg-dt <= x-date-end
                                    and b_wth-parts.wth-code = buf_tt-wealth.wth-code
                                    and (b_wth-parts.ext-doc-type = 'ee':U or      b_wth-parts.ext-doc-type = 'xc':U    or      b_wth-parts.ext-doc-type = 'pz':U or      b_wth-parts.ext-doc-type = 'dc':U or       b_wth-parts.ext-doc-type = 'pc':U or       b_wth-parts.ext-doc-type = 'ps':U):
        create tt-wth-parts.
        buffer-copy b_wth-parts to tt-wth-parts.
    end.
    else if p-wth-recid-list <> '' and p-rs-wth-type = 2 then
    for each buf_tt-wth-par no-lock ,
        each b_wth-parts no-lock where b_wth-parts.beg-dt >= x-date-start
                                and b_wth-parts.beg-dt <= x-date-end
                                    and b_wth-parts.wth-code = buf_tt-wth-par.wth-code
                                    and b_wth-parts.par-code = buf_tt-wth-par.par-code
                                    and (b_wth-parts.ext-doc-type = 'ee':U or      b_wth-parts.ext-doc-type = 'xc':U    or      b_wth-parts.ext-doc-type = 'pz':U or      b_wth-parts.ext-doc-type = 'dc':U or       b_wth-parts.ext-doc-type = 'pc':U or       b_wth-parts.ext-doc-type = 'ps':U):
        create tt-wth-parts.
        buffer-copy b_wth-parts to tt-wth-parts.
    end.
    else
    for each b_wth-parts no-lock where b_wth-parts.beg-dt >= x-date-start
                                and b_wth-parts.beg-dt <= x-date-end
                                and (b_wth-parts.ext-doc-type = 'ee':U or      b_wth-parts.ext-doc-type = 'xc':U    or      b_wth-parts.ext-doc-type = 'pz':U or      b_wth-parts.ext-doc-type = 'dc':U or       b_wth-parts.ext-doc-type = 'pc':U or       b_wth-parts.ext-doc-type = 'ps':U):
        create tt-wth-parts.
        buffer-copy b_wth-parts to tt-wth-parts.
    end.
end.
if p-dt-calc = 3 then do:
    if p-wth-recid-list <> '' and p-rs-wth-type = 1  then
    for each buf_tt-wealth no-lock,
    each b_wth-parts no-lock where b_wth-parts.fact-date >= x-date-start
                                    and b_wth-parts.fact-date <= x-date-end
                                    and b_wth-parts.wth-code = buf_tt-wealth.wth-code
                                    and b_wth-parts.beg-dt >= p-dtFrom
                                    and b_wth-parts.beg-dt <= p-dtTo
                                    and (b_wth-parts.ext-doc-type = 'ee':U or      b_wth-parts.ext-doc-type = 'xc':U    or      b_wth-parts.ext-doc-type = 'pz':U or      b_wth-parts.ext-doc-type = 'dc':U or       b_wth-parts.ext-doc-type = 'pc':U or       b_wth-parts.ext-doc-type = 'ps':U):
        create tt-wth-parts.
        buffer-copy b_wth-parts to tt-wth-parts.
    end.
    else if p-wth-recid-list <> '' and p-rs-wth-type = 2 then
    for each buf_tt-wth-par no-lock ,
        each b_wth-parts no-lock where b_wth-parts.fact-date >= x-date-start
                                    and b_wth-parts.fact-date <= x-date-end
                                    and b_wth-parts.wth-code = buf_tt-wth-par.wth-code
                                    and b_wth-parts.wth-code = buf_tt-wth-par.par-code
                                    and b_wth-parts.beg-dt >= p-dtFrom
                                    and b_wth-parts.beg-dt <= p-dtTo
                                    and (b_wth-parts.ext-doc-type = 'ee':U or      b_wth-parts.ext-doc-type = 'xc':U    or      b_wth-parts.ext-doc-type = 'pz':U or      b_wth-parts.ext-doc-type = 'dc':U or       b_wth-parts.ext-doc-type = 'pc':U or       b_wth-parts.ext-doc-type = 'ps':U):
        create tt-wth-parts.
        buffer-copy b_wth-parts to tt-wth-parts.
    end.
    else do:
      for each b_wth-parts no-lock where b_wth-parts.fact-date >= x-date-start
                                    and b_wth-parts.fact-date <= x-date-end
                                    and b_wth-parts.beg-dt >= p-dtFrom
                                    and b_wth-parts.beg-dt <= p-dtTo
                                    and (b_wth-parts.ext-doc-type = 'ee':U or      b_wth-parts.ext-doc-type = 'xc':U    or      b_wth-parts.ext-doc-type = 'pz':U or      b_wth-parts.ext-doc-type = 'dc':U or       b_wth-parts.ext-doc-type = 'pc':U or       b_wth-parts.ext-doc-type = 'ps':U):
        create tt-wth-parts.
        buffer-copy b_wth-parts to tt-wth-parts.
      end.
      for each b_wth-parts no-lock where ((b_wth-parts.fact-date > x-date-end and lookup(b_wth-parts.out-code,'free-zone,out-zone,cli-zone,фальшивый,put-zone':u) = 0 and b_wth-parts.fact-num <> 0 ) or b_wth-parts.out-code = 'cli-zone':U )
                                         and (b_wth-parts.ext-doc-type = 'ee':U or      b_wth-parts.ext-doc-type = 'xc':U    or      b_wth-parts.ext-doc-type = 'pz':U or      b_wth-parts.ext-doc-type = 'dc':U or       b_wth-parts.ext-doc-type = 'pc':U or       b_wth-parts.ext-doc-type = 'ps':U)
                                         and b_wth-parts.beg-dt >= p-dtFrom
                                         and b_wth-parts.beg-dt <= p-dtTo
                                    :
            create tt-rest.
            buffer-copy b_wth-parts to tt-rest.
      end.
    end.
end.
 release tt-wth-parts.
assign v-account = ( if integer( 10 ) = 0 then 100 else integer( 10 ) ).
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
  for each buf_tt-clients
  :
    _wth-parts1:
    for each buf_wth-parts no-lock
      where buf_wth-parts.cli-type       = buf_tt-clients.obj-type
        and buf_wth-parts.cli-code       = buf_tt-clients.obj-code
        and lookup(buf_wth-parts.out-code,'free-zone,out-zone,cli-zone,фальшивый,put-zone':u) = 0 ,
        first buf_wealth no-lock
            where buf_wealth.wth-code = buf_wth-parts.wth-code ,
        first buf_wth-par no-lock
          where buf_wth-par.wth-code = buf_wth-parts.wth-code
            and buf_wth-par.par-code = buf_wth-parts.par-code
    :
      assign
        v-counter = v-counter + 1
      .
IF ( v-counter modulo v-account = 0 )  then DO:
 Assign
    v-kol-spice = (50 - LENGTH(v-repfrm-str)) / 2
    RecordsString = fill(' ',v-kol-spice) + string(v-repfrm-str)
    .
          if  log-manager:logfile-name ne ?
          then DO:
              log-manager:write-message("DISP mFrameView=" + string(mFrameView), "frameRepError").
          end.
           if mFrameView
           then do:
            DISPLAY
              v-counter @ RecordsDone
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
      if      buf_wth-parts.fact-qnty   = 0
         and  buf_wth-parts.price-rubl  = 0
      then do:
        next _wth-parts1.
      end.
      if buf_wth-parts.ext-doc-type = 'ee':U or
         buf_wth-parts.ext-doc-type = 'xc':U    or
         buf_wth-parts.ext-doc-type = 'pz':U or
         buf_wth-parts.ext-doc-type = 'dc':U or
         buf_wth-parts.ext-doc-type = 'pc':U or
         buf_wth-parts.ext-doc-type = 'ps':U
      then do:
        find first buf_tt-report
          where buf_tt-report.cli-type = buf_wth-parts.cli-type
            and buf_tt-report.cli-code = buf_wth-parts.cli-code
            and buf_tt-report.wth-code = buf_wth-parts.wth-code
            and buf_tt-report.par-code = buf_wth-parts.par-code
            and buf_tt-report.ser-code = buf_wth-parts.ser-code
            and buf_tt-report.db-num   = buf_wth-parts.db-num
        no-error .
        if not available buf_tt-report
        then do:
          if v-is-wth-restrict = yes
          then do:
            find first buf_tt-wealth
              where buf_tt-wealth.wth-code = buf_wth-parts.wth-code
            no-error .
            if not available buf_tt-wealth
            then do:
              next _wth-parts1.
            end.
          end.
          if v-is-par-restrict = yes
          then do:
            find first buf_tt-wth-par
              where buf_tt-wth-par.wth-code = buf_wth-parts.wth-code
                and buf_tt-wth-par.par-code = buf_wth-parts.par-code
            no-error .
            if not available buf_tt-wth-par
            then do:
              next _wth-parts1.
            end.
          end.
          if v-is-ser-restrict = yes
          then do:
            find first buf_tt-wth-ser
              where buf_wth-ser.ser-code = buf_wth-parts.ser-code
                and buf_wth-ser.db-num   = buf_wth-parts.db-num
            no-error .
            if not available buf_tt-wth-ser
            then do:
              next _wth-parts1.
            end.
          end.
          find first buf_wth-ser no-lock
            where buf_wth-ser.ser-code = buf_wth-parts.ser-code
              and buf_wth-ser.db-num   = buf_wth-parts.db-num
          no-error .
          if not available buf_wth-ser
          then do:
            next _wth-parts1.
          end.
          create buf_tt-report.
          assign
            buf_tt-report.cli-type      = buf_wth-parts.cli-type
            buf_tt-report.cli-code      = buf_wth-parts.cli-code
            buf_tt-report.wth-code      = buf_wth-parts.wth-code
            buf_tt-report.par-code      = buf_wth-parts.par-code
            buf_tt-report.ser-code      = buf_wth-parts.ser-code
            buf_tt-report.db-num        = buf_wth-parts.db-num
            buf_tt-report.cli-name      = buf_tt-clients.obj-name
            buf_tt-report.talon-name    = buf_wealth.wth-name
            buf_tt-report.talon-nominal = substitute("&1 &2",  buf_wth-par.par-val, buf_wth-par.par-unit )
            buf_tt-report.talon-series  = buf_wth-ser.series
          .
        end.
      end.
      case buf_wth-parts.ext-doc-type
      :
        when 'ee':U
        then do:
          assign
            buf_tt-report.give-sum-units = buf_tt-report.give-sum-units + buf_wth-parts.fact-qnty * buf_wth-par.par-val
            buf_tt-report.give-sum-money = buf_tt-report.give-sum-money + buf_wth-parts.price-rubl * buf_wth-parts.fact-qnty
          .
        end.
        when 'xc':U
        then do:
          if buf_wth-parts.type = 'рас':U
          then do:
            assign
              buf_tt-report.chg-give-sum-units = buf_tt-report.chg-give-sum-units + buf_wth-parts.fact-qnty * buf_wth-par.par-val
              buf_tt-report.chg-give-sum-money = buf_tt-report.chg-give-sum-money + buf_wth-parts.price-rubl * buf_wth-parts.fact-qnty
            .
          end.
          if buf_wth-parts.type = 'при':U
          then do:
            assign
              buf_tt-report.chg-ret-sum-units = buf_tt-report.chg-ret-sum-units + buf_wth-parts.fact-qnty * buf_wth-par.par-val
              buf_tt-report.chg-ret-sum-money = buf_tt-report.chg-ret-sum-money + buf_wth-parts.price-rubl * buf_wth-parts.fact-qnty
            .
          end.
        end.
        when 'pz':U
        then do:
            assign  buf_tt-report.ret-sum-units = buf_tt-report.ret-sum-units + buf_wth-parts.fact-qnty * buf_wth-par.par-val
            buf_tt-report.ret-sum-money = buf_tt-report.ret-sum-money + buf_wth-parts.price-rubl * buf_wth-parts.fact-qnty
          .
        end.
        when 'dc':U
        then do:
          assign
            buf_tt-report.spi-sum-units = buf_tt-report.spi-sum-units + buf_wth-parts.fact-qnty * buf_wth-par.par-val
            buf_tt-report.spi-sum-money = buf_tt-report.spi-sum-money + buf_wth-parts.price-rubl * buf_wth-parts.fact-qnty
          .
        end.
        when 'pc':U or
        when 'ps':U
        then do:
          assign
            buf_tt-report.sell-sum-units = buf_tt-report.sell-sum-units + buf_wth-parts.fact-qnty * buf_wth-par.par-val
            buf_tt-report.sell-sum-money = buf_tt-report.sell-sum-money + buf_wth-parts.price-rubl * buf_wth-parts.fact-qnty
          .
        end.
      end case.
    end.
    def buffer buf-rest for tt-rest.
    if p-dt-calc = 1 or p-dt-calc = 3 then do:
      _wth-rest:
      for each  buf-rest no-lock where buf-rest.cli-type       = buf_tt-clients.obj-type
                           and buf-rest.cli-code       = buf_tt-clients.obj-code
        ,first buf_wealth no-lock
            where buf_wealth.wth-code = buf-rest.wth-code
        ,first buf_wth-par no-lock
          where buf_wth-par.wth-code = buf-rest.wth-code
            and buf_wth-par.par-code = buf-rest.par-code
           :
        find first buf_tt-report
          where buf_tt-report.cli-type = buf-rest.cli-type
            and buf_tt-report.cli-code = buf-rest.cli-code
            and buf_tt-report.wth-code = buf-rest.wth-code
            and buf_tt-report.par-code = buf-rest.par-code
            and buf_tt-report.ser-code = buf-rest.ser-code
            and buf_tt-report.db-num   = buf-rest.db-num
        no-error .
        if not available buf_tt-report
        then do:
          if v-is-wth-restrict = yes
          then do:
            find first buf_tt-wealth
              where buf_tt-wealth.wth-code = buf-rest.wth-code
            no-error .
            if not available buf_tt-wealth
            then do:
              next _wth-rest.
            end.
          end.
          if v-is-par-restrict = yes
          then do:
            find first buf_tt-wth-par
              where buf_tt-wth-par.wth-code = buf-rest.wth-code
                and buf_tt-wth-par.par-code = buf-rest.par-code
            no-error .
            if not available buf_tt-wth-par
            then do:
              next _wth-rest.
            end.
          end.
          if v-is-ser-restrict = yes
          then do:
            find first buf_tt-wth-ser
              where buf_wth-ser.ser-code = buf-rest.ser-code
                and buf_wth-ser.db-num   = buf-rest.db-num
            no-error .
            if not available buf_tt-wth-ser
            then do:
              next _wth-rest.
            end.
          end.
          find first buf_wth-ser no-lock
            where buf_wth-ser.ser-code = buf-rest.ser-code
              and buf_wth-ser.db-num   = buf-rest.db-num
          no-error .
          if not available buf_wth-ser
          then do:
            next _wth-rest.
          end.
          create buf_tt-report.
          assign
            buf_tt-report.cli-type      = buf-rest.cli-type
            buf_tt-report.cli-code      = buf-rest.cli-code
            buf_tt-report.wth-code      = buf-rest.wth-code
            buf_tt-report.par-code      = buf-rest.par-code
            buf_tt-report.ser-code      = buf-rest.ser-code
            buf_tt-report.db-num        = buf-rest.db-num
            buf_tt-report.cli-name      = buf_tt-clients.obj-name
            buf_tt-report.talon-name    = buf_wealth.wth-name
            buf_tt-report.talon-nominal = substitute("&1 &2",  buf_wth-par.par-val, buf_wth-par.par-unit )
            buf_tt-report.talon-series  = buf_wth-ser.series
          .
        end.
             if buf-rest.out-code <> 'cli-zone':U and (buf-rest.ext-doc-type = 'ee':U or (buf-rest.ext-doc-type = 'xc':U and buf-rest.type  = 'рас':U)) then
                          assign  buf_tt-report.restEnd-units = buf_tt-report.restEnd-units - buf-rest.fact-qnty * buf_wth-par.par-val
                                  buf_tt-report.restEnd-money = buf_tt-report.restEnd-money - buf-rest.price-rubl * buf-rest.fact-qnty
                          .
                          else    assign  buf_tt-report.restEnd-units = buf_tt-report.restEnd-units + buf-rest.fact-qnty * buf_wth-par.par-val
                                  buf_tt-report.restEnd-money = buf_tt-report.restEnd-money + buf-rest.price-rubl * buf-rest.fact-qnty
                          .
      end.
      for each buf_tt-report where buf_tt-report.cli-type = buf_tt-clients.obj-type
                               and buf_tt-report.cli-code = buf_tt-clients.obj-code :
            assign  buf_tt-report.restFrom-units = buf_tt-report.restEnd-units - buf_tt-report.give-sum-units - buf_tt-report.chg-give-sum-units
                                                  + buf_tt-report.chg-ret-sum-units + buf_tt-report.ret-sum-units + buf_tt-report.spi-sum-units  + buf_tt-report.sell-sum-units
                    buf_tt-report.restFrom-money = buf_tt-report.restEnd-money - buf_tt-report.give-sum-money - buf_tt-report.chg-give-sum-money
                                                  + buf_tt-report.chg-ret-sum-money + buf_tt-report.ret-sum-money + buf_tt-report.spi-sum-money + buf_tt-report.sell-sum-money
            .
      end.
    end.
    if p-dt-calc = 2 then do:
      for each buf_tt-report where buf_tt-report.cli-type = buf_tt-clients.obj-type
                               and buf_tt-report.cli-code = buf_tt-clients.obj-code :
            assign  buf_tt-report.restEnd-units = buf_tt-report.give-sum-units + buf_tt-report.chg-give-sum-units
                                                  - buf_tt-report.chg-ret-sum-units - buf_tt-report.ret-sum-units - buf_tt-report.spi-sum-units  - buf_tt-report.sell-sum-units
                    buf_tt-report.restEnd-money = buf_tt-report.give-sum-money + buf_tt-report.chg-give-sum-money
                                                  - buf_tt-report.chg-ret-sum-money - buf_tt-report.ret-sum-money - buf_tt-report.spi-sum-money - buf_tt-report.sell-sum-money
            .
      end.
    end.
    if p-dt-calc = 3 then do:
    end.
  end.
if mFrameView
then do:
   HIDE FRAME InfoFrame.
end.
  assign
    v-give-sum-units     = 0
    v-give-sum-money     = 0
    v-chg-give-sum-units = 0
    v-chg-give-sum-money = 0
    v-sell-sum-units     = 0
    v-sell-sum-money     = 0
    v-ret-sum-units      = 0
    v-ret-sum-money      = 0
    v-chg-ret-sum-units  = 0
    v-chg-ret-sum-money  = 0
    v-spi-sum-units      = 0
    v-spi-sum-money      = 0
    v-restFrom-units     = 0
    v-restFrom-money     = 0
    v-restEnd-units      = 0
    v-restEnd-money      = 0
  .
  run waitfram-show in this-procedure ("Расчет подитогов по клиентам...") .
  for each buf_tt-report
    break by buf_tt-report.cli-type
          by buf_tt-report.cli-code
  :
    assign
      v-give-sum-units      = v-give-sum-units     + buf_tt-report.give-sum-units
      v-give-sum-money      = v-give-sum-money     + buf_tt-report.give-sum-money
      v-chg-give-sum-units  = v-chg-give-sum-units + buf_tt-report.chg-give-sum-units
      v-chg-give-sum-money  = v-chg-give-sum-money + buf_tt-report.chg-give-sum-money
      v-sell-sum-units      = v-sell-sum-units     + buf_tt-report.sell-sum-units
      v-sell-sum-money      = v-sell-sum-money     + buf_tt-report.sell-sum-money
      v-ret-sum-units       = v-ret-sum-units      + buf_tt-report.ret-sum-units
      v-ret-sum-money       = v-ret-sum-money      + buf_tt-report.ret-sum-money
      v-chg-ret-sum-units   = v-chg-ret-sum-units  + buf_tt-report.chg-ret-sum-units
      v-chg-ret-sum-money   = v-chg-ret-sum-money  + buf_tt-report.chg-ret-sum-money
      v-spi-sum-units       = v-spi-sum-units      + buf_tt-report.spi-sum-units
      v-spi-sum-money       = v-spi-sum-money      + buf_tt-report.spi-sum-money
      v-restFrom-units      = v-restFrom-units     + buf_tt-report.restFrom-units
      v-restFrom-money      = v-restFrom-money     + buf_tt-report.restFrom-money
      v-restEnd-units       = v-restEnd-units      + buf_tt-report.restEnd-units
      v-restEnd-money       = v-restEnd-money      + buf_tt-report.restEnd-money
    .
    if last-of(buf_tt-report.cli-type)
      or last-of(buf_tt-report.cli-code)
    then do:
      create buf_tt-report-cli.
      assign
        buf_tt-report-cli.cli-type            = buf_tt-report.cli-type
        buf_tt-report-cli.cli-code            = buf_tt-report.cli-code
        buf_tt-report-cli.give-sum-units      = v-give-sum-units
        buf_tt-report-cli.give-sum-money      = v-give-sum-money
        buf_tt-report-cli.chg-give-sum-units  = v-chg-give-sum-units
        buf_tt-report-cli.chg-give-sum-money  = v-chg-give-sum-money
        buf_tt-report-cli.sell-sum-units      = v-sell-sum-units
        buf_tt-report-cli.sell-sum-money      = v-sell-sum-money
        buf_tt-report-cli.ret-sum-units       = v-ret-sum-units
        buf_tt-report-cli.ret-sum-money       = v-ret-sum-money
        buf_tt-report-cli.chg-ret-sum-units   = v-chg-ret-sum-units
        buf_tt-report-cli.chg-ret-sum-money   = v-chg-ret-sum-money
        buf_tt-report-cli.spi-sum-units       = v-spi-sum-units
        buf_tt-report-cli.spi-sum-money       = v-spi-sum-money
        buf_tt-report-cli.restFrom-units      = v-restFrom-units
        buf_tt-report-cli.restFrom-money      = v-restFrom-money
        buf_tt-report-cli.restEnd-units       = v-restEnd-units
        buf_tt-report-cli.restEnd-money       = v-restEnd-money
        v-give-sum-units                      = 0
        v-give-sum-money                      = 0
        v-chg-give-sum-units                  = 0
        v-chg-give-sum-money                  = 0
        v-sell-sum-units                      = 0
        v-sell-sum-money                      = 0
        v-ret-sum-units                       = 0
        v-ret-sum-money                       = 0
        v-chg-ret-sum-units                   = 0
        v-chg-ret-sum-money                   = 0
        v-spi-sum-units                       = 0
        v-spi-sum-money                       = 0
        v-restFrom-units                      = 0
        v-restFrom-money                      = 0
        v-restEnd-units                       = 0
        v-restEnd-money                       = 0
      .
    end.
  end.
  run waitfram-hide in this-procedure .
end.
end procedure.
procedure print-header :
do
on error undo, return error return-value
:
define buffer buf_clients for ub.clients.
define buffer buf_wealth  for ub.wealth.
define buffer buf_wth-par for ub.wth-par.
define buffer buf_wth-ser for ub.wth-ser.
define variable v-date-range    as character no-undo .
define variable v-clients-list  as character no-undo .
define variable v-wth-list      as character no-undo .
if  p-dt-calc = 1 then v-date-range = 'За период '.
else  if  p-dt-calc = 2 then v-date-range = ' Даты начала срока годности '.
  assign
    v-date-range = v-date-range + substitute( "с &1 по &2"
                             , string( x-Date-Start , "99/99/9999" )
                             , string( x-Date-End  , "99/99/9999" )
                             )
  .
if  p-dt-calc = 3 then  v-date-range = v-date-range + substitute(" (Дата начала срока годности с &1 по &2) "
                                                      ,p-dtFrom
                                                      ,p-dtTo).
  if p-rs-supp <> 1 then do:
    for each tt-clients no-lock :
      find first buf_clients no-lock
        where buf_clients.obj-type = tt-clients.obj-type
          and buf_clients.obj-code = tt-clients.obj-code
      no-error .
      if available buf_clients then do:
        assign
          v-clients-list = v-clients-list + buf_clients.obj-name + "\n":U
        .
      end.
    end.
  end.
  else do:
    assign
      v-clients-list = "Все":U
    .
  end.
  if v-is-wth-restrict then do:
    assign
      v-wth-list = "МЦ:":U + " ":U
    .
    for each tt-wealth :
      assign
        v-wth-list = v-wth-list + tt-wealth.wth-name + ",":U
      .
    end.
  end.
  if v-is-par-restrict then do:
    assign
      v-wth-list = "Номиналы:":U + " ":U
    .
    for each tt-wth-par :
      find first buf_wth-par no-lock
        where buf_wth-par.wth-code = tt-wth-par.wth-code
          and buf_wth-par.par-code = tt-wth-par.par-code
      no-error .
      find first buf_wealth no-lock
        where buf_wealth.wth-code = tt-wth-par.wth-code
      no-error .
      if available buf_wth-par and available buf_wealth then do:
        assign
          v-wth-list = v-wth-list + substitute( "&1 - &2 &3&4"
                                              , buf_wealth.wth-name
                                              , buf_wth-par.par-val
                                              , buf_wth-par.par-unit
                                              , ",":U
                                              )
        .
      end.
    end.
  end.
  if v-is-ser-restrict then do:
    assign
      v-wth-list = "Серии:":U + " ":U
    .
    for each tt-wth-ser :
      find first buf_wth-par no-lock
        where buf_wth-par.wth-code = tt-wth-ser.wth-code
          and buf_wth-par.par-code = tt-wth-ser.par-code
      no-error .
      find first buf_wealth no-lock
        where buf_wealth.wth-code = tt-wth-par.wth-code
      no-error .
      if available buf_wth-par and available buf_wealth then do:
        assign
          v-wth-list = v-wth-list + substitute( "&1 : &2 - &3 &4&5"
                                              , tt-wth-ser.series
                                              , buf_wealth.wth-name
                                              , buf_wth-par.par-val
                                              , buf_wth-par.par-unit
                                              , ",":U
                                              )
        .
      end.
    end.
  end.
  v-wth-list = substring(v-wth-list,1,length(v-wth-list) - 1) no-error.
  if  v-is-wth-restrict = no and
      v-is-par-restrict = no and
      v-is-ser-restrict = no
  then do:
    assign
      v-wth-list = "Все":U
    .
  end.
  run wthobrxl-write-cell-data in this-procedure ( input "h_daterange":U
                                                 , input v-date-range
                                                 ) .
  run wthobrxl-write-cell-data in this-procedure ( input "h_clients":U
                                                 , input v-clients-list
                                                 ) .
  run wthobrxl-write-cell-data in this-procedure ( input "h_wth":U
                                                 , input v-wth-list
                                                 ) .
end.
end procedure.
procedure print-report :
  define buffer buf_tt-report     for tt-report .
  define buffer buf_tt-report-cli for tt-report-cli.
  define variable v-give-sum-units            as decimal   no-undo .
  define variable v-give-sum-money            as decimal   no-undo .
  define variable v-chg-give-sum-units        as decimal   no-undo .
  define variable v-chg-give-sum-money        as decimal   no-undo .
  define variable v-sell-sum-units            as decimal   no-undo .
  define variable v-sell-sum-money            as decimal   no-undo .
  define variable v-ret-sum-units             as decimal   no-undo .
  define variable v-ret-sum-money             as decimal   no-undo .
  define variable v-chg-ret-sum-units         as decimal   no-undo .
  define variable v-chg-ret-sum-money         as decimal   no-undo .
  define variable v-spi-sum-units             as decimal   no-undo .
  define variable v-spi-sum-money             as decimal   no-undo .
  define variable v-RestFrom-units            as decimal   no-undo .
  define variable v-restFrom-money            as decimal   no-undo .
  define variable v-restEnd-units             as decimal   no-undo .
  define variable v-restEnd-money             as decimal   no-undo .
  define variable v-total-give-sum-units      as decimal   no-undo .
  define variable v-total-give-sum-money      as decimal   no-undo .
  define variable v-total-chg-give-sum-units  as decimal   no-undo .
  define variable v-total-chg-give-sum-money  as decimal   no-undo .
  define variable v-total-sell-sum-units      as decimal   no-undo .
  define variable v-total-sell-sum-money      as decimal   no-undo .
  define variable v-total-ret-sum-units       as decimal   no-undo .
  define variable v-total-ret-sum-money       as decimal   no-undo .
  define variable v-total-chg-ret-sum-units   as decimal   no-undo .
  define variable v-total-chg-ret-sum-money   as decimal   no-undo .
  define variable v-total-spi-sum-units       as decimal   no-undo .
  define variable v-total-spi-sum-money       as decimal   no-undo .
  define variable v-total-RestFrom-units      as decimal   no-undo .
  define variable v-total-restFrom-money      as decimal   no-undo .
  define variable v-total-restEnd-units       as decimal   no-undo .
  define variable v-total-restEnd-money       as decimal   no-undo .
do
on error undo, return error return-value
:
  _rep-line:
  for each buf_tt-report
  break by buf_tt-report.cli-type
        by buf_tt-report.cli-code
        by buf_tt-report.wth-code
        by buf_tt-report.par-code
        by buf_tt-report.ser-code
        by buf_tt-report.db-num
  :
    if first-of(buf_tt-report.cli-type) or first-of(buf_tt-report.cli-code)
    then do:
      find first buf_tt-report-cli
        where buf_tt-report-cli.cli-type  = buf_tt-report.cli-type
          and buf_tt-report-cli.cli-code  = buf_tt-report.cli-code
      no-error .
      if not available buf_tt-report-cli
      then do:
        message
          substitute( "Не найдены итоги по клиенту &1 &2 - &3"
                    , buf_tt-report.cli-code
                    , buf_tt-report.cli-type
                    , buf_tt-report.cli-name
                    )
        view-as alert-box error.
        next _rep-line.
      end.
      run wthobrxl-write-line-data in this-procedure ( input buf_tt-report.cli-name
                                                     , input " ":u
                                                     , input " ":u
                                                     , input " ":u
                                                     , input string( buf_tt-report-cli.give-sum-units     )
                                                     , input string( buf_tt-report-cli.give-sum-money     )
                                                     , input string( buf_tt-report-cli.chg-give-sum-units )
                                                     , input string( buf_tt-report-cli.chg-give-sum-money )
                                                     , input string( buf_tt-report-cli.sell-sum-units     )
                                                     , input string( buf_tt-report-cli.sell-sum-money     )
                                                     , input string( buf_tt-report-cli.ret-sum-units      )
                                                     , input string( buf_tt-report-cli.ret-sum-money      )
                                                     , input string( buf_tt-report-cli.chg-ret-sum-units  )
                                                     , input string( buf_tt-report-cli.chg-ret-sum-money  )
                                                     , input string( buf_tt-report-cli.spi-sum-units      )
                                                     , input string( buf_tt-report-cli.spi-sum-money      )
                                                     , input string( buf_tt-report-cli.RestFrom-units )
                                                     , input string( buf_tt-report-cli.restFrom-money )
                                                     , input string( buf_tt-report-cli.restEnd-units  )
                                                     , input string( buf_tt-report-cli.restEnd-money  )
                                                     ) .
      if p-cb-wth-detail <> 1
      then do:
        run wthobrxl-sheet1-write-line-format in this-procedure ( "St" ).
      end.
    end.
    assign
      v-total-give-sum-units      = v-total-give-sum-units     + buf_tt-report.give-sum-units
      v-total-give-sum-money      = v-total-give-sum-money     + buf_tt-report.give-sum-money
      v-total-chg-give-sum-units  = v-total-chg-give-sum-units + buf_tt-report.chg-give-sum-units
      v-total-chg-give-sum-money  = v-total-chg-give-sum-money + buf_tt-report.chg-give-sum-money
      v-total-sell-sum-units      = v-total-sell-sum-units     + buf_tt-report.sell-sum-units
      v-total-sell-sum-money      = v-total-sell-sum-money     + buf_tt-report.sell-sum-money
      v-total-ret-sum-units       = v-total-ret-sum-units      + buf_tt-report.ret-sum-units
      v-total-ret-sum-money       = v-total-ret-sum-money      + buf_tt-report.ret-sum-money
      v-total-chg-ret-sum-units   = v-total-chg-ret-sum-units  + buf_tt-report.chg-ret-sum-units
      v-total-chg-ret-sum-money   = v-total-chg-ret-sum-money  + buf_tt-report.chg-ret-sum-money
      v-total-spi-sum-units       = v-total-spi-sum-units      + buf_tt-report.spi-sum-units
      v-total-spi-sum-money       = v-total-spi-sum-money      + buf_tt-report.spi-sum-money
      v-total-RestFrom-units  = v-total-RestFrom-units  + buf_tt-report.RestFrom-units
      v-total-restFrom-money  = v-total-restFrom-money  + buf_tt-report.restFrom-money
      v-total-restEnd-units   = v-total-restEnd-units   + buf_tt-report.restEnd-units
      v-total-restEnd-money   = v-total-restEnd-money   + buf_tt-report.restEnd-money
    .
    if p-cb-wth-detail <> 1
    then do:
      assign
        v-give-sum-units      = v-give-sum-units     + buf_tt-report.give-sum-units
        v-give-sum-money      = v-give-sum-money     + buf_tt-report.give-sum-money
        v-chg-give-sum-units  = v-chg-give-sum-units + buf_tt-report.chg-give-sum-units
        v-chg-give-sum-money  = v-chg-give-sum-money + buf_tt-report.chg-give-sum-money
        v-sell-sum-units      = v-sell-sum-units     + buf_tt-report.sell-sum-units
        v-sell-sum-money      = v-sell-sum-money     + buf_tt-report.sell-sum-money
        v-ret-sum-units       = v-ret-sum-units      + buf_tt-report.ret-sum-units
        v-ret-sum-money       = v-ret-sum-money      + buf_tt-report.ret-sum-money
        v-chg-ret-sum-units   = v-chg-ret-sum-units  + buf_tt-report.chg-ret-sum-units
        v-chg-ret-sum-money   = v-chg-ret-sum-money  + buf_tt-report.chg-ret-sum-money
        v-spi-sum-units       = v-spi-sum-units      + buf_tt-report.spi-sum-units
        v-spi-sum-money       = v-spi-sum-money      + buf_tt-report.spi-sum-money
        v-RestFrom-units   = v-RestFrom-units  + buf_tt-report.RestFrom-units
        v-restFrom-money   = v-restFrom-money  + buf_tt-report.restFrom-money
        v-restEnd-units    = v-restEnd-units   + buf_tt-report.restEnd-units
        v-restEnd-money    = v-restEnd-money   + buf_tt-report.restEnd-money
      .
    end.
    if    p-cb-wth-detail = 2
      and last-of(buf_tt-report.wth-code)
    then do:
      run wthobrxl-write-line-data in this-procedure ( input ' ':U
                                                     , input buf_tt-report.talon-name
                                                     , input ' ':U
                                                     , input ' ':U
                                                     , input string( v-give-sum-units     )
                                                     , input string( v-give-sum-money     )
                                                     , input string( v-chg-give-sum-units )
                                                     , input string( v-chg-give-sum-money )
                                                     , input string( v-sell-sum-units     )
                                                     , input string( v-sell-sum-money     )
                                                     , input string( v-ret-sum-units      )
                                                     , input string( v-ret-sum-money      )
                                                     , input string( v-chg-ret-sum-units  )
                                                     , input string( v-chg-ret-sum-money  )
                                                     , input string( v-spi-sum-units      )
                                                     , input string( v-spi-sum-money      )
                                                     , input string( v-RestFrom-units  )
                                                     , input string( v-restFrom-money  )
                                                     , input string( v-restEnd-units   )
                                                     , input string( v-restEnd-money   )
                                                      ) .
      assign
        v-give-sum-units      = 0
        v-give-sum-money      = 0
        v-chg-give-sum-units  = 0
        v-chg-give-sum-money  = 0
        v-sell-sum-units      = 0
        v-sell-sum-money      = 0
        v-ret-sum-units       = 0
        v-ret-sum-money       = 0
        v-chg-ret-sum-units   = 0
        v-chg-ret-sum-money   = 0
        v-spi-sum-units       = 0
        v-spi-sum-money       = 0
        v-RestFrom-units      = 0
        v-restFrom-money      = 0
        v-restEnd-units       = 0
        v-restEnd-money       = 0
      .
    end.
    if    p-cb-wth-detail = 3
      and ( last-of(buf_tt-report.wth-code) or last-of(buf_tt-report.par-code) )
    then do:
      run wthobrxl-write-line-data in this-procedure ( input ' ':U
                                                     , input buf_tt-report.talon-name
                                                     , input buf_tt-report.talon-nominal
                                                     , input ' ':U
                                                     , input string( v-give-sum-units     )
                                                     , input string( v-give-sum-money     )
                                                     , input string( v-chg-give-sum-units )
                                                     , input string( v-chg-give-sum-money )
                                                     , input string( v-sell-sum-units     )
                                                     , input string( v-sell-sum-money     )
                                                     , input string( v-ret-sum-units      )
                                                     , input string( v-ret-sum-money      )
                                                     , input string( v-chg-ret-sum-units  )
                                                     , input string( v-chg-ret-sum-money  )
                                                     , input string( v-spi-sum-units      )
                                                     , input string( v-spi-sum-money      )
                                                     , input string( v-RestFrom-units  )
                                                     , input string( v-restFrom-money  )
                                                     , input string( v-restEnd-units   )
                                                     , input string( v-restEnd-money   )
                                                     ) .
      assign
        v-give-sum-units      = 0
        v-give-sum-money      = 0
        v-chg-give-sum-units  = 0
        v-chg-give-sum-money  = 0
        v-sell-sum-units      = 0
        v-sell-sum-money      = 0
        v-ret-sum-units       = 0
        v-ret-sum-money       = 0
        v-chg-ret-sum-units   = 0
        v-chg-ret-sum-money   = 0
        v-spi-sum-units       = 0
        v-spi-sum-money       = 0
        v-RestFrom-units      = 0
        v-restFrom-money      = 0
        v-restEnd-units       = 0
        v-restEnd-money       = 0
      .
    end.
    if    p-cb-wth-detail = 4
      and ( last-of(buf_tt-report.ser-code) or last-of(buf_tt-report.db-num) )
    then do:
      run wthobrxl-write-line-data in this-procedure ( input ' ':U
                                                     , input buf_tt-report.talon-name
                                                     , input buf_tt-report.talon-nominal
                                                     , input buf_tt-report.talon-series
                                                     , input string( v-give-sum-units     )
                                                     , input string( v-give-sum-money     )
                                                     , input string( v-chg-give-sum-units )
                                                     , input string( v-chg-give-sum-money )
                                                     , input string( v-sell-sum-units     )
                                                     , input string( v-sell-sum-money     )
                                                     , input string( v-ret-sum-units      )
                                                     , input string( v-ret-sum-money      )
                                                     , input string( v-chg-ret-sum-units  )
                                                     , input string( v-chg-ret-sum-money  )
                                                     , input string( v-spi-sum-units      )
                                                     , input string( v-spi-sum-money      )
                                                     , input string( v-RestFrom-units  )
                                                     , input string( v-restFrom-money  )
                                                     , input string( v-restEnd-units   )
                                                     , input string( v-restEnd-money   )
                                                     ) .
      assign
        v-give-sum-units      = 0
        v-give-sum-money      = 0
        v-chg-give-sum-units  = 0
        v-chg-give-sum-money  = 0
        v-sell-sum-units      = 0
        v-sell-sum-money      = 0
        v-ret-sum-units       = 0
        v-ret-sum-money       = 0
        v-chg-ret-sum-units   = 0
        v-chg-ret-sum-money   = 0
        v-spi-sum-units       = 0
        v-spi-sum-money       = 0
        v-RestFrom-units      = 0
        v-restFrom-money      = 0
        v-restEnd-units       = 0
        v-restEnd-money       = 0
      .
    end.
  end.
  run wthobrxl-write-line-data in this-procedure (  input "ИТОГО:":U
                                                  , input ' ':U
                                                  , input ' ':U
                                                  , input ' ':U
                                                  , input string( v-total-give-sum-units     )
                                                  , input string( v-total-give-sum-money     )
                                                  , input string( v-total-chg-give-sum-units )
                                                  , input string( v-total-chg-give-sum-money )
                                                  , input string( v-total-sell-sum-units     )
                                                  , input string( v-total-sell-sum-money     )
                                                  , input string( v-total-ret-sum-units      )
                                                  , input string( v-total-ret-sum-money      )
                                                  , input string( v-total-chg-ret-sum-units  )
                                                  , input string( v-total-chg-ret-sum-money  )
                                                  , input string( v-total-spi-sum-units      )
                                                  , input string( v-total-spi-sum-money      )
                                                  , input string( v-total-RestFrom-units  )
                                                  , input string( v-total-restFrom-money  )
                                                  , input string( v-total-restEnd-units   )
                                                  , input string( v-total-restEnd-money   )
                                                  ) .
  run wthobrxl-sheet1-write-line-format in this-procedure ( "St" ).
end.
end procedure.
