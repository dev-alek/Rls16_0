using Ibs.Th.Gbl.ProgressBar.
CREATE WIDGET-POOL.
DEFINE INPUT PARAMETER  parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input parameter  procname       as character no-undo .
define input parameter  namereport     as character no-undo .
define input parameter  param-date     as integer   no-undo .
define input parameter  param-goods    as character no-undo .
define input parameter  param-obj      as character no-undo .
define input parameter  param-pay      as character no-undo .
define input parameter  param-pay-hide as character no-undo .
define input parameter  param-universal as character no-undo .
define input parameter  param-alon     as logical   no-undo .
define variable G#rep-updflds as character no-undo .
define variable v-nn as integer   no-undo .
define variable v-nn2 as integer   no-undo .
define variable v-nn3 as integer   no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Окно для вызова отчетов (содержит 2 страницы)".
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
    assign
      p-vss-parameters = substitute('&1|&2|&3|&4|&5|&6|&7|&8|&9',procname,namereport,param-date,param-goods,param-obj,param-pay,param-pay-hide,param-universal,param-alon)
    .
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
define NEW shared variable gdsgrp_recids      as character no-undo.
define NEW shared variable fin-schet-recid    as character no-undo.
define NEW shared variable v-d-report-handle  as handle    no-undo .
define NEW shared temp-table g#customer no-undo
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    index pi is unique primary obj-type obj-code.
define NEW shared temp-table g#cli no-undo
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    index pi is unique primary obj-type obj-code.
define NEW shared temp-table tmp#grp no-undo
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
define NEW shared temp-table gds-list no-undo like ub.goods
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
define  NEW shared  temp-table gds-list-hist no-undo
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
NEW shared
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
define NEW shared temp-table X-init_obj-list no-undo
field obj-type like ub.clients.obj-type
field obj-code like ub.clients.obj-code
index pi is unique primary obj-type obj-code.
define variable p1 like ub.gds-obj.prod-type no-undo.
define variable p2 like ub.gds-obj.prod-code no-undo.
define variable p3 like ub.gds-obj.artic     no-undo.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable to-day       as date no-undo .
define NEW shared variable str1   as character  no-undo.
define NEW shared variable str2   as character  no-undo.
define NEW shared variable str3   as character  no-undo.
define NEW shared variable str4   as character  no-undo.
define NEW shared variable ReportNAme   as character  no-undo.
define NEW shared variable ReportProc   as character  no-undo.
define NEW shared variable ReportHeader as character  no-undo.
define NEW shared variable ReportPageWidth  as integer no-undo.
define NEW shared variable ReportPageHeight as integer no-undo.
define NEW shared variable ReportFontNum    as integer no-undo.
define NEW shared variable my-request as logical  init false no-undo.
define NEW shared variable v-delim as character no-undo .
define NEW shared variable v-sdate as character no-undo initial "/":U.
define NEW shared variable v-shortdate as character no-undo initial "dd/mm/yyyy":U .
define NEW shared variable my-handle  as handle no-undo .
define NEW shared variable parent-handle  as handle no-undo .
define NEW shared variable v-show-all-goods as logical  no-undo .
define NEW shared variable params-only      as logical   no-undo .
define NEW shared variable params-only-mode as character no-undo .
define NEW shared variable place-call       as character no-undo .
define NEW shared variable x-Goods-Editor   as character  no-undo .
define NEW shared variable x-Date-Alone     as date format "99/99/9999":u   no-undo .
define NEW shared variable x-Date-End       as date format "99/99/9999":u   no-undo .
define NEW shared variable x-Date-Start     as date format "99/99/9999":u   no-undo .
define NEW shared variable x-Shift-Alone    as integer format ">9":u         no-undo .
define NEW shared variable x-Shift-End      as integer format ">9":u         no-undo .
define NEW shared variable x-Shift-Start    as integer format ">9":u         no-undo .
define NEW shared variable x-SelectGood     as integer                      no-undo .
define NEW shared variable x-SelectObject   as character                          no-undo .
define NEW shared variable x-SET_PAY_TYPE   as integer  no-undo .
define NEW shared variable x-SET_val_TYPE   as integer  no-undo .
define NEW shared variable x-TOG-Shift      as logical  no-undo .
define NEW shared variable x-Radio-Task     as integer  no-undo .
define NEW shared variable x-TOG-Excel      as logical  no-undo .
define NEW shared variable x-TOG-list-hist  as logical  no-undo .
define NEW shared variable x-text-1 as character  no-undo .
define NEW shared variable x-text-2 as character  no-undo .
define NEW shared variable x-text-3 as character  no-undo .
define NEW shared variable x-text-4 as character  no-undo .
define NEW shared variable init-date-start  like x-date-start  no-undo .
define NEW shared variable init-date-end    like x-date-end    no-undo .
define NEW shared variable init-date-alone  like x-date-alone  no-undo .
define NEW shared variable init-shift-alone like x-shift-alone no-undo .
define NEW shared variable init-shift-start like x-shift-start no-undo .
define NEW shared variable init-shift-end   like x-shift-end   no-undo .
define NEW shared variable init-set_pay_type like x-set_pay_type   no-undo .
define NEW shared variable init-set_val_type like x-set_val_type   no-undo .
define NEW shared variable ref_date-start    as character   no-undo .
define NEW shared variable ref_date-end      as character   no-undo .
define NEW shared variable ref_date-alone    as character   no-undo .
define NEW shared work-table TDEDT  no-undo
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
define NEW shared variable str-obj-type as character  no-undo.
define NEW shared variable str-obj-code as character  no-undo.
define NEW shared variable str-obj-name as character  no-undo.
define NEW shared variable str-obj      as character  no-undo.
define NEW shared variable link#        as logical  no-undo init false.
define NEW shared variable  Verify-Arc-ot      as logical  no-undo init false.
define NEW shared variable  Verify-Arc-stk     as logical  no-undo init false.
define NEW shared variable  Verify-Arc-supp    as logical  no-undo init false.
define NEW shared variable  Verify-Arc-hold    as logical  no-undo init false.
define NEW shared variable  Verify-Arc-aht     as logical  no-undo init false.
define NEW shared variable  Verify-send-check  as logical  no-undo init false.
define NEW shared variable  Verify-Arc-fin     as logical  no-undo init false.
define NEW shared variable  Verify-Arc-strong  as logical  no-undo init false.
define NEW shared variable  Show-Crsa         as logical  no-undo init false.
define NEW shared variable  Show-Cost         as logical  no-undo init false.
define NEW shared variable  Show-Sale         as logical  no-undo init false.
define NEW shared variable  Name-Sale-price   as character no-undo .
define NEW shared variable  Format-Folder     as logical no-undo .
define NEW shared variable  Print-List-Hist   as logical no-undo init false.
define NEW shared variable Make-Excel     as logical  no-undo init false.
define NEW shared variable Make-Excel-com as logical  no-undo init false.
define NEW shared stream ForExcel.
define NEW shared variable Use-column   as logical extent 256 no-undo .
define NEW shared variable right-column as logical extent 256 no-undo .
define NEW shared temp-table Sheetf no-undo
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
  create Sheetf.
  assign
  sheetf.sheet-num = 1.
define variable l-stroka as character no-undo .
define NEW shared  variable ch#ExcelApplication as com-handle no-undo .
define NEW shared  variable ch#Workbook         as com-handle no-undo .
define NEW shared  variable ch#Worksheet        as com-handle no-undo .
define NEW shared  variable Num#Str#            as integer no-undo.
define NEW shared  variable Number-List         as integer no-undo init 1.
define NEW shared  variable v-excel-file        as character no-undo .
define variable Col-name as character  extent 256.
define variable Col-format as character  extent 256.
define variable Col-Post-format as character  extent 256.
run proc-page0-assign in this-procedure .
define variable v-del-1 as character no-undo .
if  v-delim = " " or v-delim = ? or v-delim = ""  then do:
    run gbl/getlocal.p ( output v-delim  , output v-del-1, output v-sdate, output v-shortdate ) no-error .
    if error-status :error then do:
      message error-status :error error-status :get-message(1)
              v-delim v-del-1.
        v-delim = ','  .
    end.
end.
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
  my-handle = parParentProc .
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
define NEW shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define NEW shared variable RepPathName        as character no-undo .
define NEW shared variable PrintRubl          as logical   no-undo .
procedure OpenForExcel :
   define variable v-ch#ExcelApplication as com-handle no-undo .
   define variable v-ch#Workbook         as com-handle no-undo .
   define variable v-ch#Worksheet        as com-handle no-undo .
   os-delete value( string( session:temp-directory ) +
                              "rpt" + string( g#report-num ) + ".txt":U ) .
   os-delete value( string( session:temp-directory ) +
                              "rpt" + string( g#report-num ) + ".frm":U ) .
   os-delete value( string( session:temp-directory ) +
                              "rpt" + string( g#report-num ) + ".txl":U ) .
   if Make-Excel
   then do:
      output stream ForExcel to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) + ".txt":U ) ) .
      assign
         v-excel-file = string( session:temp-directory + "rpt" + string( g#report-num ) )
         number-list = 1
      .
      if make-excel-com
      then do:
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#WorkSheet) then
RELEASE OBJECT ch#WorkSheet no-error.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#Workbook) then
RELEASE OBJECT ch#Workbook no-error.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#ExcelApplication) then
RELEASE OBJECT ch#ExcelApplication no-error.
         create "Excel.Application" ch#excelApplication connect no-error.
         if error-status:error
         then do :
        create "Excel.Application" ch#excelApplication no-error.
    if error-status :error then do:
        message
        "Ошибка при запуске Excel" skip
        error-status :get-message(1) skip
        view-as alert-box error .
        undo, return error .
    end.
         end.
         assign
            num#str#  = 0.
            v-ch#excelApplication  = ch#excelApplication.
            v-ch#excelApplication:Interactive = false.
            v-ch#excelApplication:ScreenUpdating = false.
            v-ch#excelApplication:Visible = false.
            ch#Workbook  = v-ch#excelApplication:Workbooks:add ().
            ch#WorkSheet = v-ch#excelApplication:Sheets:Item (1).
            v-ch#Worksheet = ch#WorkSheet.
            v-ch#Worksheet:Range ("A1"):Font:Bold = true.
            v-ch#Worksheet:Range ("A1"):Font:Size = 14.
            v-ch#Worksheet:Range ("A1"):HorizontalAlignment = -4131.
            v-ch#Worksheet:Range ("A1"):VerticalAlignment   = -4160
         no-error .
         if error-status:error
         then do:
            Make-Excel-com = false .
            Make-Excel = false .
            output Stream  ForExcel close.
            os-delete value( string( session:temp-directory ) +
                           "rpt" + string( g#report-num ) + ".txt":U ) .
            os-delete value( string( session:temp-directory ) +
                           "rpt" + string( g#report-num ) + ".frm":U ) .
            return.
         end.
      end.
   end.
end.
procedure CloseForExcel :
   define variable ii as integer no-undo .
   define variable vsheet-num as integer no-undo.
   if Make-Excel
   then  do:
      output Stream  ForExcel close.
      os-delete value( string( session:temp-directory ) +
                             "rpt" + string( g#report-num ) + ".txt":U ) .
      os-delete value( string( session:temp-directory ) +
                             "rpt" + string( g#report-num ) + ".frm":U ) .
      define buffer buf_sheetf for sheetf.
      find last buf_sheetf no-error .
      if available buf_sheetf
      then
         vsheet-num = buf_sheetf.sheet-num.
      if vsheet-num > 1
      then do:
         do ii = 2 to vsheet-num:
            os-delete value( string( session:temp-directory ) +
                                  "rpt" + string( g#report-num ) + ".":U  + string(ii)) .
         end.
      end.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#WorkSheet) then
RELEASE OBJECT ch#WorkSheet no-error.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#Workbook) then
RELEASE OBJECT ch#Workbook no-error.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#ExcelApplication) then
RELEASE OBJECT ch#ExcelApplication no-error.
   end.
end.
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define temp-table param-to-export no-undo
field param-code     as character
field param-sub-code as character
field param-type     as character
field param-value    as character
field param-comment  as character
index pi is unique primary  param-code     param-sub-code
.
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-prg-bar_progress-bar  as class ProgressBar  no-undo .
  procedure prg-bar_new-progress-bar :
    define input  parameter p-min as int64   no-undo .
    define input  parameter p-max as int64   no-undo .
  do
  on error undo, return error return-value
  :
    if v-prg-bar_progress-bar <> ?
    then do:
      run prg-bar_delete-progress-bar in this-procedure .
    end.
    v-prg-bar_progress-bar = new progressbar( p-min , p-max ).
  end.
  end procedure.
  procedure prg-bar_delete-progress-bar :
  do
  on error undo, return error return-value
  :
    if v-prg-bar_progress-bar <> ?
    then do:
      delete object v-prg-bar_progress-bar.
      assign
        v-prg-bar_progress-bar = ?
      .
    end.
  end.
  end procedure.
  procedure prg-bar_show-progress-bar :
  do
  on error undo, return error return-value
  :
    if v-prg-bar_progress-bar <> ?
    then do:
      v-prg-bar_progress-bar :show-bar() .
    end.
  end.
  end procedure.
  procedure prg-bar_increment-progress-bar :
  do
  on error undo, return error return-value
  :
    if v-prg-bar_progress-bar <> ?
    then do:
      v-prg-bar_progress-bar :increment() .
    end.
  end.
  end procedure.
  procedure prg-bar_title-progress-bar :
    define input  parameter p-str as character no-undo .
  do
  on error undo, return error return-value
  :
    if v-prg-bar_progress-bar <> ?
    then do:
      assign
        v-prg-bar_progress-bar :frame-title = p-str
      .
    end.
  end.
  end procedure.
  procedure prg-bar_stepto-progress-bar :
    define input  parameter p-val as integer   no-undo .
  do
  on error undo, return error return-value
  :
    if v-prg-bar_progress-bar <> ?
    then do:
        v-prg-bar_progress-bar :stepto( p-val ) .
    end.
  end.
  end procedure.
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
define variable v-type-folder-list  as character no-undo .
define variable b_ach as handle no-undo .
define variable g#log as logical no-undo .
define new shared variable lns-cnt as integer no-undo .
define new shared variable s-notes as character no-undo .
define variable v-progress-bar as class ProgressBar no-undo .
define stream str-export .
DEFINE VARIABLE h_folder AS HANDLE NO-UNDO.
DEFINE VARIABLE h_format AS HANDLE NO-UNDO.
DEFINE VARIABLE h_list AS HANDLE NO-UNDO.
DEFINE VARIABLE h_main AS HANDLE NO-UNDO.
DEFINE VARIABLE h_special AS HANDLE NO-UNDO.
DEFINE BUTTON b-exit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON Btn_OK AUTO-GO
     LABEL "_ В&ыполнить"
     SIZE 12 BY 1
     BGCOLOR 8 .
DEFINE BUTTON i-exit
     IMAGE-UP FILE "cmp/i-run.bmp":U
     IMAGE-DOWN FILE "cmp/i-run.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/i-rund.bmp":U
     LABEL ""
     SIZE 2.5 BY .75.
DEFINE FRAME D-Dialog
     b-exit AT ROW 1 COL 1
     Btn_OK AT ROW 1 COL 11
     i-exit AT ROW 1.08 COL 11.13 NO-TAB-STOP
     B-lkp  AT ROW 1 COL 61
     B-Help AT ROW 1 COL 71
     SPACE(14.24) SKIP(20.66)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "<insert SmartDialog title>"
         DEFAULT-BUTTON Btn_OK CANCEL-BUTTON b-exit.
DEFINE VAR adm-object-hdl       AS HANDLE NO-UNDO.
DEFINE VAR adm-query-opened        AS LOGICAL NO-UNDO INIT NO.
DEFINE VAR adm-row-avail-state     AS LOGICAL NO-UNDO INIT ?.
DEFINE VAR adm-initial-lock        AS CHARACTER NO-UNDO INIT "NO-LOCK":U.
DEFINE VAR adm-new-record          AS LOGICAL NO-UNDO INIT no.
DEFINE VAR adm-updating-record     AS LOGICAL NO-UNDO INIT no.
DEFINE VAR adm-check-modified-all  AS LOGICAL NO-UNDO INIT no.
DEFINE NEW GLOBAL SHARED VAR adm-broker-hdl    AS HANDLE  NO-UNDO.
    ASSIGN adm-object-hdl = FRAME D-Dialog:HANDLE.
RUN ensure-broker.
THIS-PROCEDURE:ADM-DATA =
     'ADM1.1~`':U +
     'SmartDialog~`':U +
     'DIALOG-BOX~`':U +
     'NO ~`':U +
     '~`':U +
     '~`':U +
     '~`':U +
     (IF adm-object-hdl = ? THEN "":U ELSE STRING(adm-object-hdl))
        + "~`":U +
     'Layout,Hide-on-Init~`':U +
     'Record-Target~`':U +
     '~`':U +
     '~`~`~`~`~`~`~`~`~`~`~`':U +
     IF THIS-PROCEDURE:ADM-DATA = "":U OR THIS-PROCEDURE:ADM-DATA = ?
         THEN "^^":U
     ELSE "^":U + ENTRY(2, THIS-PROCEDURE:ADM-DATA, "^":U) +
          "^":U + ENTRY(3, THIS-PROCEDURE:ADM-DATA, "^":U).
PROCEDURE adm-apply-entry :
  RUN broker-apply-entry IN adm-broker-hdl (THIS-PROCEDURE) NO-ERROR.
END PROCEDURE.
PROCEDURE adm-destroy :
 RUN broker-destroy IN adm-broker-hdl (THIS-PROCEDURE) NO-ERROR.
END PROCEDURE.
PROCEDURE adm-disable :
    DISABLE b-exit Btn_OK B-lkp B-Help i-exit WITH FRAME D-Dialog.
    RUN dispatch ('disable-fields':U).
    RUN set-attribute-list ('ENABLED=no':U).
    RETURN.
END PROCEDURE.
PROCEDURE adm-edit-attribute-list :
      RUN adm/support/contnrd.w (INPUT THIS-PROCEDURE).
      RETURN.
END PROCEDURE.
PROCEDURE adm-enable :
    ENABLE UNLESS-HIDDEN b-exit Btn_OK B-lkp B-Help i-exit WITH FRAME D-Dialog.
    RUN enable_UI IN THIS-PROCEDURE NO-ERROR.
    RUN set-attribute-list ('ENABLED=yes':U).
    RETURN.
END PROCEDURE.
PROCEDURE adm-exit :
     RUN notify ('exit':U).
  RETURN.
END PROCEDURE.
PROCEDURE adm-hide :
  RUN broker-hide IN adm-broker-hdl (THIS-PROCEDURE) NO-ERROR.
END PROCEDURE.
PROCEDURE adm-initialize :
  RUN broker-initialize IN adm-broker-hdl (THIS-PROCEDURE) NO-ERROR.
END PROCEDURE.
PROCEDURE adm-show-errors :
    DEFINE VARIABLE        cntr                  AS INTEGER   NO-UNDO.
    DO cntr = 1 TO ERROR-STATUS:NUM-MESSAGES:
        MESSAGE ERROR-STATUS:GET-MESSAGE(cntr).
    END.
    RETURN.
END PROCEDURE.
PROCEDURE adm-UIB-mode :
  RUN broker-UIB-mode IN adm-broker-hdl (THIS-PROCEDURE) NO-ERROR.
END PROCEDURE.
PROCEDURE adm-view :
  RUN broker-view IN adm-broker-hdl (THIS-PROCEDURE) NO-ERROR.
END PROCEDURE.
PROCEDURE dispatch :
    DEFINE INPUT PARAMETER p-method-name    AS CHARACTER NO-UNDO.
    RUN broker-dispatch IN adm-broker-hdl
        (THIS-PROCEDURE, p-method-name) NO-ERROR.
    IF RETURN-VALUE = "ADM-ERROR":U THEN RETURN "ADM-ERROR":U.
END PROCEDURE.
PROCEDURE ensure-broker :
RUN get-attribute IN adm-broker-hdl ('TYPE':U) NO-ERROR.
IF RETURN-VALUE NE "ADM-Broker":U THEN
DO:
    RUN adm/objects/broker.p PERSISTENT set adm-broker-hdl.
    RUN set-broker-owner IN adm-broker-hdl (THIS-PROCEDURE).
END.
END PROCEDURE.
PROCEDURE get-attribute :
  DEFINE INPUT PARAMETER p-attr-name    AS CHARACTER NO-UNDO.
  RUN broker-get-attribute IN adm-broker-hdl
      (INPUT THIS-PROCEDURE, INPUT p-attr-name) NO-ERROR.
  RETURN RETURN-VALUE.
END PROCEDURE.
PROCEDURE get-attribute-list :
  DEFINE OUTPUT PARAMETER p-attr-list AS CHARACTER NO-UNDO.
  RUN broker-get-attribute-list IN adm-broker-hdl
      (INPUT THIS-PROCEDURE,
       INPUT ?,
       OUTPUT p-attr-list) NO-ERROR.
  RETURN.
END PROCEDURE.
PROCEDURE new-state :
  DEFINE INPUT PARAMETER p-state AS CHARACTER NO-UNDO.
  RUN broker-new-state IN adm-broker-hdl (THIS-PROCEDURE, p-state) NO-ERROR.
  RETURN.
END PROCEDURE.
PROCEDURE notify :
  DEFINE INPUT PARAMETER p-method AS CHARACTER NO-UNDO.
  RUN broker-notify IN adm-broker-hdl (THIS-PROCEDURE, p-method) NO-ERROR.
  IF RETURN-VALUE = "ADM-ERROR":U THEN
      RETURN "ADM-ERROR":U.
  RETURN.
END PROCEDURE.
PROCEDURE set-attribute-list :
  DEFINE INPUT PARAMETER p-attr-list    AS CHARACTER NO-UNDO.
  RUN ensure-broker.
  RUN broker-set-attribute-list IN adm-broker-hdl
      (INPUT THIS-PROCEDURE, INPUT p-attr-list) NO-ERROR.
  RETURN.
END PROCEDURE.
PROCEDURE set-position :
    DEFINE INPUT PARAMETER p-row    AS DECIMAL NO-UNDO.
    DEFINE INPUT PARAMETER p-col    AS DECIMAL NO-UNDO.
    IF VALID-HANDLE(adm-object-hdl) THEN
    DO:
        DEFINE VARIABLE parent-hdl AS HANDLE NO-UNDO.
        IF adm-object-hdl:TYPE = "WINDOW":U THEN
        DO:
          IF p-row = 0 THEN p-row =
            (SESSION:HEIGHT-CHARS - adm-object-hdl:HEIGHT-CHARS) / 2.
          IF p-col = 0 THEN p-col =
            (SESSION:WIDTH-CHARS - adm-object-hdl:WIDTH-CHARS) / 2.
        END.
        ELSE IF adm-object-hdl:TYPE = "DIALOG-BOX":U THEN
        DO:
          parent-hdl = adm-object-hdl:PARENT.
          IF p-row = 0 THEN p-row =
            ((SESSION:HEIGHT-CHARS - adm-object-hdl:HEIGHT-CHARS) / 2) -
              parent-hdl:ROW.
          IF p-col = 0 THEN p-col =
            ((SESSION:WIDTH-CHARS - adm-object-hdl:WIDTH-CHARS) / 2) -
              parent-hdl:COL.
        END.
        IF p-row GE 0 AND p-row < 1 THEN p-row = 1.
        IF p-col GE 0 AND p-col < 1 THEN p-col = 1.
      ASSIGN adm-object-hdl:ROW    =   p-row
             adm-object-hdl:COLUMN =   p-col.
    END.
    RETURN.
END PROCEDURE.
RUN set-attribute-list ("CURRENT-PAGE=0,ADM-OBJECT-HANDLE=":U +
    STRING(adm-object-hdl)).
PAUSE 0 BEFORE-HIDE.
PROCEDURE adm-change-page :
  RUN broker-change-page IN adm-broker-hdl (INPUT THIS-PROCEDURE) NO-ERROR.
  END PROCEDURE.
PROCEDURE delete-page :
  DEFINE INPUT PARAMETER p-page# AS INTEGER NO-UNDO.
  RUN broker-delete-page IN adm-broker-hdl
      (INPUT THIS-PROCEDURE, INPUT p-page#).
  END PROCEDURE.
PROCEDURE init-object :
  DEFINE INPUT PARAMETER  p-proc-name   AS CHARACTER NO-UNDO.
  DEFINE INPUT PARAMETER  p-parent-hdl  AS HANDLE    NO-UNDO.
  DEFINE INPUT PARAMETER  p-attr-list   AS CHARACTER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-proc-hdl    AS HANDLE    NO-UNDO.
  RUN broker-init-object IN adm-broker-hdl
      (INPUT THIS-PROCEDURE, INPUT p-proc-name, INPUT p-parent-hdl,
       INPUT p-attr-list, OUTPUT p-proc-hdl) NO-ERROR.
  RETURN.
END PROCEDURE.
PROCEDURE init-pages :
  DEFINE INPUT PARAMETER p-page-list      AS CHARACTER NO-UNDO.
  RUN broker-init-pages IN adm-broker-hdl (INPUT THIS-PROCEDURE,
      INPUT p-page-list) NO-ERROR.
  END PROCEDURE.
PROCEDURE select-page :
  DEFINE INPUT PARAMETER p-page#     AS INTEGER   NO-UNDO.
  RUN broker-select-page IN adm-broker-hdl (INPUT THIS-PROCEDURE,
      INPUT p-page#) NO-ERROR.
  END PROCEDURE.
PROCEDURE view-page :
  DEFINE INPUT PARAMETER p-page#      AS INTEGER   NO-UNDO.
  RUN broker-view-page IN adm-broker-hdl (INPUT THIS-PROCEDURE,
      INPUT p-page#).
  END PROCEDURE.
ASSIGN
       FRAME D-Dialog:SCROLLABLE       = FALSE
       FRAME D-Dialog:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME D-Dialog
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-lkp IN FRAME D-Dialog
DO:
  run verify-obj in h_main.
  run assign-frame in  h_main.
  if not param-alon
  then do:
        if format-folder
        then do:
           run get-var-2 in h_format no-error.
    IF ERROR-STATUS:ERROR then
     DO:
     message "Необходимо сходить на закладку <Формат...> !" view-as alert-box information .
     RUN select-page IN THIS-PROCEDURE ( 3 ).
     return no-apply.
     END.
        end.
     run my-var in h_special no-error.
    IF ERROR-STATUS:ERROR then
     DO:
        run CloseForExcel in this-procedure  .
        CASE RETURN-VALUE:
        When 'First-page':U THEN  DO:
                return no-apply.
                                  END.
        When 'Second-page':U THEN  DO:
                    message "Проверьте правильность заполнения формы!".
                    RUN select-page IN THIS-PROCEDURE ( 2 ).
                    return  no-apply .
                                   END.
        when 'format-page' then DO:
                    message "На закладке <Формат...> необходимо выбрать поля для печати !".
                    RUN select-page IN THIS-PROCEDURE ( 3 ).
                    return no-apply.
                    END.
        OTHERWISE  DO:
                    message "Необходимо сходить на закладку <Продолжение...> !".
                    RUN select-page IN THIS-PROCEDURE ( 2 ).
                    return no-apply.
                    END.
        End case.
     End.
     ELSE
        CASE RETURN-VALUE:
        When 'First-page':U THEN  DO:
                RUN select-page IN THIS-PROCEDURE ( 1 ).
                return no-apply.
                                    END.
        When 'Second-page':U THEN  DO:
                    message "Проверьте правильность заполнения формы!".
                    RUN select-page IN THIS-PROCEDURE ( 2 ).
                    return  no-apply .
                                    END.
        When 'format-page':U THEN  DO:
                    message "Проверьте правильность заполнения формы!".
                    RUN select-page IN THIS-PROCEDURE ( 3 ).
                    return  no-apply .
                                    END.
        End case.
  end.
  run rep/r-prev.w .
  return no-apply.
END.
ON CHOOSE OF Btn_OK IN FRAME D-Dialog
DO:
  define buffer buf_sys-ctrl for ub.sys-ctrl.
  find first buf_sys-ctrl no-lock no-error.
  if (X-Date-Alone <> ? and
     X-date-alone < buf_sys-ctrl.sys-date)
  or (X-Date-Start <> ? and
     X-Date-Start < buf_sys-ctrl.sys-date)
  or (X-Date-End <> ? and
     X-Date-End < buf_sys-ctrl.sys-date) then
  do:
    message "Нельзя сформировать отчет на дату меньше," skip
            "чем дата чистки БД " string(buf_sys-ctrl.sys-date, "99/99/9999") "."
    view-as alert-box.
    return no-apply.
  end.
  if params-only then do:
     run proc-save-param-RUM in this-procedure no-error .
     if error-status :error then do:
        return no-apply .
     end.
  end.
  else do:
    run trg/userlog.p (
          input "report":U
        , input namereport + chr(3) + procname
        , input ?
        , input ?
        , input ""
    ) no-error.
    if error-status :error
    then do:
        message return-value + error-status:get-message(1) view-as alert-box title "Ошибка записи истории действий пользователя".
    end.
    run print-report in this-procedure no-error .
    if error-status :error
    then do:
      return no-apply .
    end.
    return no-apply .
  end.
END.
ON CHOOSE OF i-exit IN FRAME D-Dialog
DO:
  APPLY "choose" TO btn_ok.
END.
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure minbtn-set :
    do
        on error undo, return error return-value
        :
        define variable ii              as integer       no-undo .
        define variable fh              as widget-handle no-undo .
        define variable hh              as widget-handle no-undo .
        define variable v-h             as handle        extent 4 no-undo .
        define variable v-name-button   as character     no-undo .
        define variable v-help-old-x    as decimal       no-undo .
        define variable v-help-old-y    as decimal       no-undo .
        define variable v-help-old-size as decimal       no-undo .
        define variable v-frame-width   as decimal       no-undo .
        define variable jj              as integer       no-undo .
        do
            on error undo, return error
            :
            assign
                v-frame-width = frame D-Dialog:width - 0.3
                fh            = frame D-Dialog:first-child
                hh            = fh:first-child
                ii            = 1
                .
            do while valid-handle(hh):
                if LOOKUP(lc(hh:name), "b-help,b-print,b-history,b-hist,b-hist-user,b-sch") > 0  then
                do:
                    case lc(hh:name) :
                        when "b-help" then
                            do:
                                hh:load-image-up("cmp/b-help.bmp":u) .
                                hh:load-image-down("cmp/b-help.bmp":u) .
                                hh:load-image-insensitive("cmp/b-help.bmp":u) .
                                hh:TOOLTIP = "Помощь" .
                                v-help-old-x = hh:column .
                                v-help-old-y = hh:row    .
                                v-help-old-size = hh:width .
                                hh:width-chars = 2.5 .
                            end.
                        when "b-print" then
                            do:
                                hh:load-image("cmp/b-print.bmp":u) .
                                hh:TOOLTIP = "Печать" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-history" or
                        when "b-hist" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-sch" then
                            do:
                                hh:load-image("cmp/b-sch.bmp":u) .
                                hh:TOOLTIP = "Установка Фильтра" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-hist-user" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История пользователя" .
                                ii = ii + 1 .
                            end.
                    end case.
                end.
                hh = hh:next-sibling.
            end.
            b-help:column = v-frame-width - b-help:width-chars.
            jj = 0.
            repeat ii = 4 to 1 by -1 :
                if valid-handle (v-h[ii] ) then
                do:
                    jj  = jj + 1 .
                    v-h[ii]:column = v-frame-width - b-help:width-chars - ( 3 * jj ).
                    v-h[ii]:row    = v-help-old-y .
                end.
            end.
        end.
    end.
end procedure.
run minbtn-set in this-procedure .
on help of frame D-Dialog
do:
  run gbl/app_help.p
    (input procname
    ,input ''
    ,input ?
    ) no-error.
  if error-status :error
  then do:
    message
      "Ошибка при вызове помощи" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box .
  end.
end.
on choose of b-help in frame D-Dialog
do:
  apply "help":u to frame D-Dialog .
end.
IF THIS-PROCEDURE:PERSISTENT THEN DO:
    MESSAGE "A SmartDialog is not intended ":U SKIP
            "to be run Persistent or to be placed ":U SKIP
            "in another SmartObject at UIB design time.":U
            VIEW-AS ALERT-BOX ERROR.
    RUN disable_UI.
    DELETE PROCEDURE THIS-PROCEDURE.
    RETURN.
END.
RUN dispatch ('create-objects':U).
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME D-Dialog:PARENT eq ?
THEN FRAME D-Dialog:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN dispatch IN THIS-PROCEDURE ('initialize':U).
  WAIT-FOR GO OF FRAME D-Dialog.
END.
RUN dispatch IN THIS-PROCEDURE ('destroy':U).
PROCEDURE adm-create-objects :
  DEFINE VARIABLE adm-current-page  AS INTEGER NO-UNDO.
  RUN get-attribute IN THIS-PROCEDURE ('Current-Page':U).
  ASSIGN adm-current-page = INTEGER(RETURN-VALUE).
  CASE adm-current-page:
    WHEN 0 THEN DO:
       RUN init-object IN THIS-PROCEDURE (
             INPUT  'adm/objects/folder.w':U ,
             INPUT  FRAME D-Dialog:HANDLE ,
             INPUT  'FOLDER-LABELS = ':U + 'Параметры|Продолжение|Формат' + ',
                     FOLDER-TAB-TYPE = 1':U ,
             OUTPUT h_folder ).
       RUN set-position IN h_folder ( 2.04 , 1.00 ) NO-ERROR.
       RUN set-size IN h_folder ( 20.38 , 93.63 ) NO-ERROR.
       RUN init-object IN THIS-PROCEDURE (
             INPUT  'rep/b-listf.w':U ,
             INPUT  FRAME D-Dialog:HANDLE ,
             INPUT  '':U ,
             OUTPUT h_list ).
       RUN init-object IN THIS-PROCEDURE (
             INPUT PROCNAME ,
             INPUT  FRAME D-Dialog:HANDLE ,
             INPUT  '':U ,
             OUTPUT h_special ).
       RUN init-object IN THIS-PROCEDURE (
             INPUT  'rep/s-format.w':U ,
             INPUT  FRAME D-Dialog:HANDLE ,
             INPUT  '':U ,
             OUTPUT h_format ).
       RUN init-object IN THIS-PROCEDURE (
             INPUT  'rep/s-object.w':U ,
             INPUT  FRAME D-Dialog:HANDLE ,
             INPUT  '':U ,
             OUTPUT h_main ).
       RUN add-link IN adm-broker-hdl ( h_folder , 'Page':U , THIS-PROCEDURE ).
       RUN add-link IN adm-broker-hdl ( THIS-PROCEDURE , 'Record':U , h_list ).
       RUN add-link IN adm-broker-hdl ( h_main , 'State':U , h_special ).
       RUN add-link IN adm-broker-hdl ( THIS-PROCEDURE , 'Record':U , h_special ).
       RUN add-link IN adm-broker-hdl ( THIS-PROCEDURE , 'Record':U , h_format ).
       RUN add-link IN adm-broker-hdl ( THIS-PROCEDURE , 'Record':U , h_main ).
       RUN adjust-tab-order IN adm-broker-hdl ( h_folder ,
             B-Help:HANDLE , 'AFTER':U ).
    END.
  END CASE.
  IF adm-current-page eq 0
  THEN RUN select-page IN THIS-PROCEDURE ( 1 ).
END PROCEDURE.
PROCEDURE adm-row-available :
  DEFINE VARIABLE tbl-list           AS CHARACTER INIT "":U NO-UNDO.
  DEFINE VARIABLE rowid-list         AS CHARACTER NO-UNDO.
  DEFINE VARIABLE row-avail-cntr     AS INTEGER INIT 0 NO-UNDO.
  DEFINE VARIABLE row-avail-rowid    AS ROWID NO-UNDO.
  DEFINE VARIABLE row-avail-enabled  AS LOGICAL NO-UNDO.
  DEFINE VARIABLE link-handle        AS CHARACTER NO-UNDO.
  DEFINE VARIABLE record-source-hdl  AS HANDLE NO-UNDO.
  DEFINE VARIABLE different-row      AS LOGICAL NO-UNDO INIT no.
  DEFINE VARIABLE key-name           AS CHARACTER INIT ? NO-UNDO.
  DEFINE VARIABLE key-value          AS CHARACTER INIT ? NO-UNDO.
  RUN check-modified IN THIS-PROCEDURE ('check':U) NO-ERROR.
  IF adm-updating-record THEN RETURN.
  RUN get-attribute ('FIELDS-ENABLED':U).
  row-avail-enabled = IF RETURN-VALUE = "YES":U THEN yes ELSE no.
  RUN get-link-handle IN adm-broker-hdl (THIS-PROCEDURE, 'RECORD-SOURCE':U,
      OUTPUT link-handle) NO-ERROR.
  IF link-handle = "":U THEN
      RETURN.
  ASSIGN record-source-hdl = WIDGET-HANDLE(ENTRY(1,link-handle)).
  IF NUM-ENTRIES(link-handle) > 1 THEN
      MESSAGE "row-available in ":U THIS-PROCEDURE:FILE-NAME
          "encountered more than one RECORD-SOURCE.":U SKIP
          "The first - ":U record-source-hdl:file-name " - will be used.":U
             VIEW-AS ALERT-BOX ERROR.
  RUN get-attribute ('Key-Name':U).
  key-name = RETURN-VALUE.
  IF key-name = "":U THEN key-name = ?.
  IF key-name NE ? THEN DO:
    RUN send-key IN record-source-hdl (INPUT key-name, OUTPUT key-value)
      NO-ERROR.
    IF key-value NE ? THEN
      RUN set-attribute-list (SUBSTITUTE ('Key-Value="&1"':U, key-value)).
  END.
IF VALID-HANDLE (adm-object-hdl) THEN
    RUN dispatch IN THIS-PROCEDURE ('display-fields':U).
RUN notify IN THIS-PROCEDURE ('row-available':U).
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME D-Dialog.
END PROCEDURE.
PROCEDURE enable_UI :
  ENABLE b-exit Btn_OK B-lkp B-Help i-exit
      WITH FRAME D-Dialog.
  VIEW FRAME D-Dialog.
END PROCEDURE.
PROCEDURE Get-Var :
define output parameter  temp-str as char no-undo.
define output parameter  temp-param-date as int no-undo.
define output parameter  temp-param-date-type-period as character no-undo.
DEFINE output PARAMETER  temp-param-goods as char.
DEFINE output PARAMETER  temp-param-obj as char.
DEFINE output PARAMETER  temp-param-Pay as char.
DEFINE output PARAMETER  temp-param-Pay-hide as char.
DEFINE output PARAMETER  temp-param-obj-type as char.
DEFINE output PARAMETER  temp-param-alon as log.
DEFINE output PARAMETER  temp-param-customer as character no-undo .
DEFINE output PARAMETER  temp-param-customer-type as character no-undo .
DEFINE output PARAMETER  temp-param-schet        as character no-undo .
DEFINE output PARAMETER  temp-param-schet-hide   as character no-undo .
DEFINE output PARAMETER  temp-param-schet-init   as character no-undo .
DEFINE output PARAMETER  temp-param-schet-mode   as character no-undo .
define output parameter  all-object            as logical   no-undo .
define variable customer-yes as logical init false no-undo .
define variable customer-name as character INIT "" no-undo .
define variable customer-type as character INIT "" no-undo .
define variable schet-yes  as logical init false no-undo .
define variable schet-name as character INIT "" no-undo .
define variable schet-hide as character INIT "" no-undo .
define variable schet-init as character INIT "" no-undo .
define variable ed_date-ref as character no-undo .
define variable Jv as integer no-undo.
define variable v-ii as integer no-undo .
define variable plase-cost as integer no-undo .
define variable plase-crsa as integer no-undo .
define variable plase-sale as integer no-undo .
define variable radio-period as character   no-undo .
param-universal = param-universal + ",".
temp-param-obj-type  = "".
all-object = false .
assign temp-param-schet-mode = 'фирма':U .
v-nn3 = NUM-ENTRIES(param-universal).
REPEAT Jv = 1 to v-nn3:
    CASE Entry(Jv,param-universal ) :
        WHEN  "all":U OR
        WHEN  "shop":U OR
        WHEN  "stok":U Then temp-param-obj-type    =  Entry(Jv,param-universal ).
        WHEN  String(1)             Then Make-Excel       = TRUE.
        WHEN  String(9)         Then Make-Excel-com   = TRUE.
        WHEN  String(12)           Then Verify-Arc-aht   = TRUE.
        WHEN  String(2)            Then Verify-Arc-ot    = TRUE.
        WHEN  String(3)           Then Verify-Arc-stk   = TRUE.
        WHEN  String(8)          Then Verify-Arc-supp  = TRUE.
        WHEN  String(11)          Then Verify-Arc-hold  = TRUE.
        WHEN  String(24)        Then Verify-Arc-strong  = TRUE.
        WHEN  String(4)            Then Verify-send-check = TRUE.
        WHEN  String(5)             Then Show-Crsa = TRUE.
        WHEN  String(6)             Then show-cost = TRUE.
        WHEN  String(7)             Then show-sale = TRUE.
        WHEN  String(10)         Then format-folder = TRUE.
        WHEN  String(13)          Then customer-yes = TRUE.
        WHEN  String(14)             Then schet-yes = TRUE.
        WHEN  String(15)   Then schet-hide = schet-hide + string( 1   ) + "," .
        WHEN  String(16)       Then schet-hide = schet-hide + string( 2       ) + "," .
        WHEN  String(17)     Then schet-hide = schet-hide + string( 3     ) + "," .
        WHEN  String(18)        Then schet-hide = schet-hide + string( 4        ) + "," .
        WHEN  String(19)       Then schet-hide = schet-hide + string( 5       ) + "," .
        WHEN  String(20)    Then schet-hide = schet-hide + string( 6    ) + "," .
        WHEN  String(21) Then schet-hide = schet-hide + string( 7 ) + "," .
        WHEN  "X-OWN-CMP":U Then temp-param-schet-mode = "company-host":U .
        WHEN  String(22)    Then Print-List-Hist   = TRUE.
        WHEN  String(23)            Then verify-arc-fin    = TRUE.
    END Case.
   if trim(Entry(Jv,param-universal)) begins "name-sale" then  name-sale-price = Entry(2,Entry(Jv,param-universal ),"=") .
   if CAPS(trim(Entry(Jv,param-universal))) begins "X-DATE-START"      then  init-DATE-START  = date(Entry(2,Entry(Jv,param-universal ),"="))  .
   if CAPS(trim(Entry(Jv,param-universal))) begins "X-DATE-END"        then  init-DATE-END    = date(Entry(2,Entry(Jv,param-universal ),"=")) .
   if CAPS(trim(Entry(Jv,param-universal))) begins "X-DATE-ALONE"      then  init-DATE-ALONE  = date(Entry(2,Entry(Jv,param-universal ),"=")) .
   if CAPS(trim(Entry(Jv,param-universal))) begins "X-SHIFT-ALONE"     then  init-Shift-ALONE = int(Entry(2,Entry(Jv,param-universal ),"=")) .
   if CAPS(trim(Entry(Jv,param-universal))) begins "X-SHIFT-START"     then  init-Shift-Start = int(Entry(2,Entry(Jv,param-universal ),"=")) .
   if CAPS(trim(Entry(Jv,param-universal))) begins "X-SHIFT-END"       then  init-Shift-End   = int(Entry(2,Entry(Jv,param-universal ),"=")) .
   if CAPS(trim(Entry(Jv,param-universal))) begins "X-CUSTOMER-NAME"   then  customer-name    = Entry(2,Entry(Jv,param-universal ),"=") .
   if CAPS(trim(Entry(Jv,param-universal))) begins "X-CUSTOMER-TYPE"   then  customer-type    = Entry(2,Entry(Jv,param-universal ),"=") .
   if CAPS(trim(Entry(Jv,param-universal))) begins "X-SCHET-NAME"      then  schet-name       = Entry(2,Entry(Jv,param-universal ),"=") .
   if CAPS(trim(Entry(Jv,param-universal))) begins "X-SCHET-INIT"      then  schet-init       = Entry(2,Entry(Jv,param-universal ),"=") .
   if CAPS(trim(Entry(Jv,param-universal))) begins "X-SET_PAY_TYPE"    then  init-SET_PAY_TYPE = int(Entry(2,Entry(Jv,param-universal ),"=")) .
   if CAPS(trim(Entry(Jv,param-universal))) begins "X-SET_VAL_TYPE"    then  init-SET_VAL_TYPE = int(Entry(2,Entry(Jv,param-universal ),"=")) .
   if CAPS(trim(Entry(Jv,param-universal))) begins "ED_DATE-REF="      then  ed_date-ref       = Entry(2,Entry(Jv,param-universal ),"=") .
   if CAPS(trim(Entry(Jv,param-universal))) begins "parent-handle="    then  parent-handle     = widget-handle(Entry(2,Entry(Jv,param-universal ),"=")) .
   if CAPS(trim(Entry(Jv,param-universal))) begins "all-object"        then  all-object        = true  .
   if CAPS(trim(Entry(Jv,param-universal))) begins "params-only="      then  params-only       = logical(Entry(2,Entry(Jv,param-universal ),"=")) .
   if CAPS(trim(Entry(Jv,param-universal))) begins "params-only-mode=" then  params-only-mode  = Entry(2,Entry(Jv,param-universal ),"=") .
   if CAPS(trim(Entry(Jv,param-universal))) begins "call="             then  place-call        = Entry(2,Entry(Jv,param-universal ),"=") .
   if CAPS(trim(Entry(Jv,param-universal))) begins "radio-period="     then  radio-period      = Entry(2,Entry(Jv,param-universal ),"=") .
 End.
  run local-pre-initialize in this-procedure no-error .
  if params-only then do:
     Btn_OK:label in frame D-Dialog = '&Ввод' .
     b-exit:label in frame D-Dialog = '&Отмена' .
     if params-only-mode  = "'ПРОСМОТР':U" or  params-only-mode  = 'ПРОСМОТР':U then do:
        params-only-mode  = 'ПРОСМОТР':U.
        b-exit:label in frame D-Dialog = '&Выход' .
        hide Btn_OK i-exit in frame D-Dialog .
     end.
  end.
  if customer-yes = TRUE then do:
      if trim(customer-name) = "" then temp-param-customer =  "Выбор контрагента" .
                                  else temp-param-customer =  customer-name .
      temp-param-customer-type =  customer-type .
  end.
  else
    assign
      temp-param-customer =  ""
      temp-param-customer-type =  ""
    .
  if schet-yes = TRUE then do:
      if trim(schet-name) = "" then temp-param-schet =  "Выбор счета" .
                               else temp-param-schet =  schet-name .
      temp-param-schet-hide =  schet-hide .
      temp-param-schet-init =  schet-init .
  end.
  else do:
    assign
      temp-param-schet =  ""
      temp-param-schet-hide = ""
      temp-param-schet-init = ""
    .
  end.
  if ed_date-ref <> '':U then do:
    do v-ii = 1 to num-entries(ed_date-ref, ';'):
      if entry(1, entry(v-ii, ed_date-ref, ';'), chr(3)) = 'X-DATE-START':U then do:
        assign
        ref_date-start = entry(2, entry(v-ii, ed_date-ref, ';'), chr(3)).
      end.
      if entry(v-ii, ed_date-ref, ';') begins 'X-DATE-END':U then do:
        assign
        ref_date-end = entry(2, entry(v-ii, ed_date-ref, ';'), chr(3)).
      end.
      if entry(v-ii, ed_date-ref, ';') begins 'X-DATE-ALONE':U then do:
        assign
        ref_date-alone = entry(2, entry(v-ii, ed_date-ref, ';'), chr(3)).
      end.
    end.
  end.
temp-param-date     = param-date .
temp-param-goods    = param-goods.
temp-param-obj      = param-obj.
temp-param-pay      = param-pay.
temp-param-pay-hide = param-pay-hide.
temp-param-alon     = param-alon.
temp-str =  ReportHeader.
g#log = true .
if show-cost = true
or lookup( "2" , temp-param-pay ) > 0
then do:
define variable vss-include-info25 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_reports_lookup-cost':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g#log
    )  .
end.
  if not g#log
  then do:
      Assign
        show-cost  = false
        plase-cost = INDEX (temp-param-Pay , "2" )
        substring(temp-param-Pay,plase-cost) = "0"
        no-error .
  end.
end.
if  show-crsa = true
or lookup( "1" , temp-param-pay ) > 0
then do:
define variable vss-include-info26 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_reports_lookup-crsa':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  no
    ,output g#log
    )  .
end.
  if not g#log
  then do:
    assign
      show-crsa  = false
      plase-crsa = index (temp-param-pay , "1" )
      substring(temp-param-pay,plase-crsa) = "0"
      no-error
      .
  end.
end.
if  show-sale = true
or lookup( "3" , temp-param-pay ) > 0
then do:
define variable vss-include-info27 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_reports_lookup-sale':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  no
    ,output g#log
    )  .
end.
  if not g#log
  then do:
      assign
        show-sale  = false
        plase-sale = index (temp-param-pay , "3" )
        substring(temp-param-pay,plase-sale) = "0"
        no-error .
  end.
End.
run initilize-page-3 in this-procedure .
END PROCEDURE .
procedure initilize-page-3:
define variable temp-str- as character no-undo .
define variable temp-i as integer no-undo .
define variable  l-ind as integer no-undo .
 find first ubflt.usr-flt no-lock where
         ubflt.usr-flt.user-name  = v-cntxt-userid and
         ubflt.usr-flt.call-point = ReportProc  no-error .
     if available ubflt.usr-flt then  DO:
          v-nn = num-entries( ubflt.usr-flt.list_) .
          repeat l-ind = 1 to v-nn :
                    if entry(1,entry(l-ind, ubflt.usr-flt.list_),"=")  = "ReportPageHeight":U then
                       ReportPageHeight = integer(entry(2,entry(l-ind, ubflt.usr-flt.list_),"=")) no-error .
                       if error-status :error  then message "qq1" .
                    if entry(1,entry(l-ind,ubflt.usr-flt.list_),"=")  = "ReportPageWidth":U then
                       ReportPageWidth = integer(entry(2,entry(l-ind, ubflt.usr-flt.list_),"=")) no-error .
                       if error-status :error  then message "qq2" .
                    if entry(1,entry(l-ind, ubflt.usr-flt.list_ ),"=")  = "Use-Column":U then
                    do :
                        temp-str- = entry( 2 , entry(l-ind, ubflt.usr-flt.list_)  ,"=" ) no-error .
                        v-nn2 = num-entries ( temp-str- , ";") .
                        repeat temp-i = 1 to v-nn2:
                            if temp-i <= 50 then
                            use-column[temp-i] = ( if trim(entry(temp-i,temp-str-,";")) = "true" then true else false) .
                        end.
                    end.
                    if error-status :error  then message "qq3" .
               End.
          End.
      Else assign ReportPageHeight = 0 ReportPageWidth  = 0.
    run op-br in h_list no-error .
END PROCEDURE.
PROCEDURE local-create-objects :
  DEFINE VARIABLE adm-current-page  AS INTEGER NO-UNDO.
  RUN get-attribute IN THIS-PROCEDURE ('Current-Page':U).
  ASSIGN adm-current-page = INTEGER(RETURN-VALUE).
  If Lookup("10",param-universal) <> 0 then format-folder = true .
                                                         else format-folder = false .
  If format-folder then
  Assign  v-type-folder-list =
  (if param-alon THEN 'FOLDER-LABELS = ':U + 'Параметры||Формат' + ', FOLDER-TAB-TYPE = 1':U
                 ELSE 'FOLDER-LABELS = ':U + 'Параметры|Продолжение|Формат' + ', FOLDER-TAB-TYPE = 1':U  )
                .
  Else
  Assign  v-type-folder-list =
  (if param-alon THEN 'FOLDER-LABELS = ':U + 'Параметры' + ', FOLDER-TAB-TYPE = 1':U
                 ELSE 'FOLDER-LABELS = ':U + 'Параметры|Продолжение' + ', FOLDER-TAB-TYPE = 1':U  )
                .
  CASE adm-current-page:
    WHEN 0
    THEN DO:
       RUN init-object IN THIS-PROCEDURE (
             INPUT  'adm/objects/folder.w':U ,
             INPUT  FRAME D-Dialog:HANDLE ,
             INPUT  v-type-folder-list ,
             OUTPUT h_folder ).
       RUN set-position IN h_folder ( 2.04 , 1.00 ) NO-ERROR.
       RUN set-size IN h_folder ( 20.38 , 93.63 ) NO-ERROR.
       RUN add-link IN adm-broker-hdl ( h_folder , 'Page':U , THIS-PROCEDURE ).
    END.
    WHEN 1
    THEN DO:
       RUN init-object IN THIS-PROCEDURE (
             INPUT  'rep/s-object.w':U ,
             INPUT  FRAME D-Dialog:HANDLE ,
             INPUT  'Layout = ':U ,
             OUTPUT h_main ).
       RUN set-position IN h_main ( 3.67 , 1.50 ) NO-ERROR.
       RUN add-link IN adm-broker-hdl ( THIS-PROCEDURE , 'Record':U , h_main ).
    END.
    WHEN 2
    THEN DO:
       RUN init-object IN THIS-PROCEDURE (
             INPUT PROCNAME ,
             INPUT  FRAME D-Dialog:HANDLE ,
             INPUT  'Layout = ':U ,
             OUTPUT h_special ).
       RUN set-position IN h_special ( 3.54 , 2.00 ) NO-ERROR.
       RUN init-pages IN THIS-PROCEDURE ('1') NO-ERROR.
       RUN add-link IN adm-broker-hdl ( h_main , 'State':U , h_special ).
       RUN add-link IN adm-broker-hdl ( THIS-PROCEDURE , 'Record':U , h_special ).
    END.
    WHEN 3
    THEN DO:
        Run my-var in h_special no-error.
    IF ERROR-STATUS:ERROR then
     DO:
        run CloseForExcel in this-procedure  .
        CASE RETURN-VALUE:
        When 'First-page':U THEN  DO:
                return no-apply.
                                  END.
        When 'Second-page':U THEN  DO:
                    message "Проверьте правильность заполнения формы!".
                    RUN select-page IN THIS-PROCEDURE ( 2 ).
                    return  no-apply .
                                   END.
        when 'format-page' then DO:
                    message "На закладке <Формат...> необходимо выбрать поля для печати !".
                    RUN select-page IN THIS-PROCEDURE ( 3 ).
                    return no-apply.
                    END.
        OTHERWISE  DO:
                    message "Необходимо сходить на закладку <Продолжение...> !".
                    RUN select-page IN THIS-PROCEDURE ( 2 ).
                    return no-apply.
                    END.
        End case.
     End.
     ELSE
        CASE RETURN-VALUE:
        When 'First-page':U THEN  DO:
                RUN select-page IN THIS-PROCEDURE ( 1 ).
                return no-apply.
                                    END.
        When 'Second-page':U THEN  DO:
                    message "Проверьте правильность заполнения формы!".
                    RUN select-page IN THIS-PROCEDURE ( 2 ).
                    return  no-apply .
                                    END.
        When 'format-page':U THEN  DO:
                    message "Проверьте правильность заполнения формы!".
                    RUN select-page IN THIS-PROCEDURE ( 3 ).
                    return  no-apply .
                                    END.
        End case.
        RUN init-object IN THIS-PROCEDURE (
              INPUT  'rep/b-listf.w':U ,
              INPUT  FRAME D-Dialog:HANDLE ,
              INPUT  'Layout = ':U ,
              OUTPUT h_list ).
        RUN set-position IN h_list ( 3.50 , 19.63 ) NO-ERROR.
       RUN init-object IN THIS-PROCEDURE (
             INPUT  'rep/s-format.w':U ,
             INPUT  FRAME D-Dialog:HANDLE ,
             INPUT  'Layout = ':U ,
             OUTPUT h_format ).
       RUN set-position IN h_format ( 3.63 , 2.13 ) NO-ERROR.
       RUN add-link IN adm-broker-hdl ( THIS-PROCEDURE , 'Record':U , h_list ).
       RUN add-link IN adm-broker-hdl ( THIS-PROCEDURE , 'Record':U , h_format ).
       RUN add-link IN adm-broker-hdl ( h_format , 'State':U , h_list ).
    END.
  END CASE.
  IF adm-current-page eq 0
  THEN RUN select-page IN THIS-PROCEDURE ( 1 ).
END PROCEDURE.
PROCEDURE local-initialize :
define variable par-type  as character no-undo .
define variable p-actuate as logical   no-undo .
run get-report-num   in parParentProc(output g#report-num).
my-handle = parParentProc .
RUN dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ) .
Assign
  ReportName = namereport
  ReportProc = procname
.
Frame D-Dialog:Title  = Trim(namereport).
if params-only then do:
    if params-only-mode  = 'ПРОСМОТР':U then do:
      Frame D-Dialog:Title  = substitute("Просмотр ПАРАМЕТРОВ отчета:  &1" ,  Trim( namereport ) ) .
    end.
    else do:
      Frame D-Dialog:Title  = substitute("Задание ПАРАМЕТРОВ отчета:  &1" ,  Trim( namereport ) ) .
    end.
end.
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
      if thbjattr_thbj-attr.prop-code = 'actuate'  then p-actuate   = thbjattr_thbj-attr.property-value-logical .
  end.
   if p-actuate
   then do:
   if param-Alon = false
   then do:
      run select-page in this-procedure ( 2 ) no-error.
      run select-page in this-procedure ( 1 ) no-error.
      run make-btn    in this-procedure  no-error.
    end.
   end.
   else do:
     run select-page in this-procedure
       (input 1
       ) no-error .
   end.
   if params-only  then do:
      if param-Alon = false
      then do:
          run select-page in this-procedure ( 2 ) no-error.
      end.
      run select-page in this-procedure ( 1 ) no-error .
      run my-params in h_special ( input "get" ) no-error .
      run local-apply-layout in h_main no-error .
  end.
END PROCEDURE.
PROCEDURE local-pre-initialize :
  define variable v-today as date      no-undo .
  define variable v-time  as integer   no-undo .
  define variable v-ok    as logical   no-undo .
  run cur-time in this-procedure
    (output v-today
    ,output v-time
    ).
   if init-date-start = date("") or init-date-start = ? then init-date-start  = v-today .
   if init-date-end = date("") or init-date-end = ? then  init-date-end    = v-today .
   if init-date-alone = date("") or init-date-alone = ? then  init-date-alone  = v-today.
   if init-shift-alone = ? then init-shift-alone = 0 .
   if init-shift-start = ? then init-shift-start = 0 .
   if init-shift-end   = ? then init-shift-end   = 0 .
END PROCEDURE.
PROCEDURE make-btn :
 do
 on error undo, return error return-value
 :
   run report-to-ach in h_special
     (input-output table param-to-export ) no-error.
   if not error-status :error
   then do:
        create button b_ach
        assign row = 1
        column = 23
        height-chars = 1
        width-chars  = 15
        label = "Actuate"
        tooltip = "выполнение отчета при помощи внешней программы"
        frame = frame D-Dialog:handle
        sensitive = true
        visible = true
        triggers:
              on choose persistent run make-ach.
        end triggers.
   end.
  end.
END PROCEDURE.
PROCEDURE print-report :
define variable choice             as logical   no-undo .
define variable v-total-archive-ok as logical   no-undo .
define variable v-archive-ok       as logical init true  no-undo .
define variable v-comment          as character no-undo .
define variable v-can-print        as logical   no-undo .
define variable temp-date      as date no-undo.
define variable temp-shift     as integer no-undo .
define variable v-date-start as date      no-undo .
define variable v-date-end   as date      no-undo .
define variable spis-obj     as character no-undo .
  run verify-date in h_main no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
  run verify-obj in h_main no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
  run assign-frame in h_main .
  run make-6-gds-list in h_main .
  assign
    v-total-archive-ok = true
  .
  if verify-arc-fin = true then do:
    define variable p-status       as integer   no-undo .
    define variable p-cut-date     as date      no-undo .
    define variable p-cut-fin-date as date      no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cutd-db in g#library
  (input  v-cntxt-db-num
  ,output p-status
  ,output p-cut-date
  ,output p-cut-fin-date
  ) no-error .
      if param-date = 1
      then do:
        assign
          v-date-start = x-date-alone
          v-date-end   = x-date-alone
        .
      end.
      else do:
        assign
          v-date-start = x-date-start
          v-date-end   = x-date-end
        .
      end.
    if p-cut-date <> ? and ( v-date-start < p-cut-date  or v-date-end < p-cut-date) then do:
      message
        "ВНИМАНИЕ!" skip
        "БД была обрезана на " string(p-cut-fin-date, "99/99/9999")  skip
        "Данные в отчете будут не корректны." skip
        "Продолжить формирование отчета?" skip
        view-as alert-box question
            buttons yes-no
            title "Финансовые архивы"
            update choice .
      if choice = false
      then do:
        assign
          v-total-archive-ok = false
        .
        undo, return error return-value .
      end.
      else do:
          if param-date = 1 then do:
          v-date-end = p-cut-fin-date .
          end .
          else do:
            v-date-start = p-cut-fin-date .
            v-date-end   = p-cut-fin-date .
          end.
        assign
          v-total-archive-ok = true
        .
      end.
    end.
  end.
  if verify-arc-hold = true
  then do:
    iF param-date = 1
    then do:
      assign
        temp-date = x-date-alone
      .
    end.
    else do:
      assign
        TEMP-DATE = x-Date-End
      .
    end.
     run trg/bt_hold.p
      (input  temp-date
      ,input  true
      ,input  v-cntxt-db-num
      ,input  v-cntxt-userid
      ) no-error .
    if error-status :error
    then do:
      message
        "ВНИМАНИЕ!" skip
        "Межфирменные архивы" skip
        return-value skip
        "Данные по выбранному периоду могут быть неполными или некорректными."
        "Продолжить формирование отчета?" skip
        view-as alert-box question buttons yes-no update choice .
      if choice = false
      then do:
        assign
          v-total-archive-ok = false
        .
      end.
      else do:
        assign
          v-total-archive-ok = true
        .
      end.
    end.
  end.
  if verify-arc-ot   = true
      or verify-arc-stk  = true
      or verify-arc-aht  = true
      or verify-arc-supp = true
      then do:
        if  verify-arc-ot = true
        and verify-arc-stk <> true
        then do:
          assign
            verify-arc-stk = true
          .
        end.
    spis-obj = "" .
    v-total-archive-ok  = true .
    for each obj-list no-lock :
      if param-date = 1
      then do:
        assign
          v-date-start = x-date-alone
          v-date-end   = x-date-alone
        .
      end.
      else do:
        assign
          v-date-start = x-date-start
          v-date-end   = x-date-end
        .
      end.
      run rep/chk-ahz.p
        (input        obj-list.obj-type
        ,input        obj-list.obj-code
        ,input        verify-arc-ot
        ,input        verify-arc-stk
        ,input        verify-arc-supp
        ,input        verify-arc-aht
        ,input        true
        ,input        v-cntxt-db-num
        ,input        v-cntxt-userid
        ,input-output v-date-start
        ,input-output v-date-end
        ,output       v-archive-ok
        ,output       v-comment
        ,output       v-can-print
        ) .
      if v-archive-ok = false
      then do:
        if v-can-print = false or verify-arc-strong  = true
        then do:
          message
            "ВНИМАНИЕ !!!" skip
            "Отчет не может быть сформирован!" skip
            "На запрошенную дату нет архивов или они сжаты" skip
            v-comment skip
            view-as alert-box information .
          run select-page in this-procedure
            (input 0
            ).
          run select-page in this-procedure
            (input 1
            ).
          undo, return error return-value .
        end.
        else do:
          assign
            v-total-archive-ok = false
            spis-obj =  spis-obj + substitute("&1&2," , obj-list.obj-type , obj-list.obj-code)
          .
        end.
      end.
    end.
    spis-obj = trim(spis-obj, ',') .
    if v-total-archive-ok = false
    then do:
      define variable v-period-description as character no-undo .
      if param-date = 1
      then do:
        assign
          v-period-description = substitute("на конец дня &1"
                                           ,string(x-date-end, '99/99/9999':u)
                                           )
        .
      end.
      else do:
        assign
          v-period-description = substitute("с начала дня &1 по конец дня &2"
                                           ,string(x-date-start, '99/99/9999':u)
                                           ,string(x-date-end,   '99/99/9999':u)
                                           )
        .
      end.
      message
        "ВНИМАНИЕ!" skip
        v-comment skip
        spis-obj skip
        "" skip
        "Данные по выбранному периоду" v-period-description "могут быть неполными или некорректными." skip
        "Продолжить формирование отчета?" skip
        view-as alert-box question buttons yes-no update choice .
      if choice = false
      then do:
        assign
          v-archive-ok = false
        .
        return.
      end.
      else do:
        assign
          v-total-archive-ok = true
        .
      end.
    end.
  end.
  if v-total-archive-ok = true
  then do:
    if param-alon = false
    then do:
      run initilize-page-3 in this-procedure .
      run return-var in this-procedure .
      if  (reportpageheight = 0  or reportpagewidth = 0)
      and format-folder
      then do:
        run get-var-2 in h_format no-error.
        if (reportpageheight = 0  or reportpagewidth = 0)
        then do:
          run select-page in this-procedure
            (input 3
            ) no-error .
          undo, return error return-value .
        end.
      end.
      run my-var in h_special no-error.
    IF ERROR-STATUS:ERROR then
     DO:
        run CloseForExcel in this-procedure  .
        CASE RETURN-VALUE:
        When 'First-page':U THEN  DO:
                return no-apply.
                                  END.
        When 'Second-page':U THEN  DO:
                    message "Проверьте правильность заполнения формы!".
                    RUN select-page IN THIS-PROCEDURE ( 2 ).
                    return  no-apply .
                                   END.
        when 'format-page' then DO:
                    message "На закладке <Формат...> необходимо выбрать поля для печати !".
                    RUN select-page IN THIS-PROCEDURE ( 3 ).
                    return no-apply.
                    END.
        OTHERWISE  DO:
                    message "Необходимо сходить на закладку <Продолжение...> !".
                    RUN select-page IN THIS-PROCEDURE ( 2 ).
                    return no-apply.
                    END.
        End case.
     End.
     ELSE
        CASE RETURN-VALUE:
        When 'First-page':U THEN  DO:
                RUN select-page IN THIS-PROCEDURE ( 1 ).
                return no-apply.
                                    END.
        When 'Second-page':U THEN  DO:
                    message "Проверьте правильность заполнения формы!".
                    RUN select-page IN THIS-PROCEDURE ( 2 ).
                    return  no-apply .
                                    END.
        When 'format-page':U THEN  DO:
                    message "Проверьте правильность заполнения формы!".
                    RUN select-page IN THIS-PROCEDURE ( 3 ).
                    return  no-apply .
                                    END.
        End case.
    end.
    if v-archive-ok = false and
        (  verify-arc-ot   = true
        or verify-arc-stk  = true
        or verify-arc-aht  = true
        or verify-arc-supp = true )
    then do:
      assign
        reportheader = reportheader + chr(10)
                     + "Архивы рассчитаны не полностью. Информация в отчете может быть неполной или некорректной."
                     + chr(10) +
                     (if spis-obj <> "" then substitute("Не корректная информация об архивах на объектах: &1" ,spis-obj ) else "")
      .
    end.
    assign
      G#rep-updflds = ReportName + " " + str1
    .
    assign
      v-d-report-handle = this-procedure
    .
    RUN set-cursor IN adm-broker-hdl ("WAIT").
    If param-Alon
    then do:
      run openforexcel in this-procedure .
      if num-entries (trim(procname), " " ) > 1  then do:
          define variable p-proc-par1 as character no-undo .
          define variable p-proc-par2 as character no-undo .
          assign
            p-proc-par1 = entry(1, procname, " ")
            p-proc-par2 = entry(2, procname, " ")
          .
          run value ( p-proc-par1 )
            (input p-proc-par2
            ).
      end.
      else do:
          run value ( procname ) .
      end.
      run CloseForExcel in this-procedure .
    End.
    else do:
      run OpenForExcel in this-procedure  .
      run my-report in h_special no-error .
    IF ERROR-STATUS:ERROR then
     DO:
        run CloseForExcel in this-procedure  .
        CASE RETURN-VALUE:
        When 'First-page':U THEN  DO:
                return no-apply.
                                  END.
        When 'Second-page':U THEN  DO:
                    message "Проверьте правильность заполнения формы!".
                    RUN select-page IN THIS-PROCEDURE ( 2 ).
                    return  no-apply .
                                   END.
        when 'format-page' then DO:
                    message "На закладке <Формат...> необходимо выбрать поля для печати !".
                    RUN select-page IN THIS-PROCEDURE ( 3 ).
                    return no-apply.
                    END.
        OTHERWISE  DO:
                    message "Необходимо сходить на закладку <Продолжение...> !".
                    RUN select-page IN THIS-PROCEDURE ( 2 ).
                    return no-apply.
                    END.
        End case.
     End.
     ELSE
        CASE RETURN-VALUE:
        When 'First-page':U THEN  DO:
                RUN select-page IN THIS-PROCEDURE ( 1 ).
                return no-apply.
                                    END.
        When 'Second-page':U THEN  DO:
                    message "Проверьте правильность заполнения формы!".
                    RUN select-page IN THIS-PROCEDURE ( 2 ).
                    return  no-apply .
                                    END.
        When 'format-page':U THEN  DO:
                    message "Проверьте правильность заполнения формы!".
                    RUN select-page IN THIS-PROCEDURE ( 3 ).
                    return  no-apply .
                                    END.
        End case.
      run CloseForExcel in this-procedure  .
    end.
    run set-cursor in adm-broker-hdl ("").
  End.
  assign
    v-d-report-handle = ?
  .
  run prg-bar_delete-progress-bar in this-procedure .
END PROCEDURE.
PROCEDURE return-var :
  run read-table IN h_list no-error.
  run get-var-2 IN h_format no-error.
  run my-var IN h_special no-error.
END PROCEDURE.
PROCEDURE send-records :
END PROCEDURE.
PROCEDURE state-changed :
  DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE NO-UNDO.
  DEFINE INPUT PARAMETER p-state AS CHARACTER NO-UNDO.
END PROCEDURE.
PROCEDURE make-ach :
 do
 on error undo, return error return-value
 :
  run my-var in h_special  no-error.
  run assign-frame in h_main no-error .
  run report-to-ach  in h_special (input-output table param-to-export ) no-error.
  if error-status :error = true then return error .
  define variable exp-name as character no-undo .
  run gbl/_tmpfile.p ( "t", ".par", output exp-name) .
  OUTPUT STREAM str-export TO  VALUE(exp-name).
      for each param-to-export :
        EXPORT STREAM str-export param-to-export .
      end.
  OUTPUT STREAM str-export CLOSE.
define variable res as integer no-undo .
define variable name-exe as character no-undo .
  assign
    file-info:file-name = "exe/run-act.bat".
    name-exe = file-info:full-pathname
  no-error .
  if error-status :error then return error .
run gbl/syn.p ( input name-exe , input  exp-name , input  "Запуск " + name-exe , output res ).
if  res > 0
then do:
  message  "Ошибка  при выполнении команды в ОС "  res .
end.
  end.
END PROCEDURE.
PROCEDURE proc-save-param-RUM :
  run verify-date in h_main no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
  run verify-obj in h_main no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
  run assign-frame in h_main .
  run make-6-gds-list in h_main .
  if param-alon = false   then do:
    run initilize-page-3 in this-procedure .
    run return-var in this-procedure .
    if  (reportpageheight = 0  or reportpagewidth = 0)
    and format-folder
    then do:
      run get-var-2 in h_format no-error.
      if (reportpageheight = 0  or reportpagewidth = 0)
      then do:
        run select-page in this-procedure
          (input 3
          ) no-error .
        undo, return error return-value .
      end.
    end.
    run my-var in h_special no-error.
    if error-status:error then
     do:
        case return-value:
            When 'First-page':U then  do:
                return error.
            end.
            When 'Second-page':U then  do:
                  message "Проверьте правильность заполнения формы!".
                  run select-page in this-procedure ( 2 ).
                  return  error .
            end.
            when 'format-page' then DO:
                  message "Необходимо сходить на закладку <Формат...> !".
                  run select-page in this-procedure ( 3 ).
                  return error.
            end.
            otherwise  do:
                message "Необходимо сходить на закладку <Продолжение...> !".
                run select-page in this-procedure ( 2 ).
                return error.
            end.
        end case.
     end.
  end.
  run my-params in h_special ( input "set" ) no-error .
    IF ERROR-STATUS:ERROR then
     DO:
        run CloseForExcel in this-procedure  .
        CASE RETURN-VALUE:
        When 'First-page':U THEN  DO:
                return no-apply.
                                  END.
        When 'Second-page':U THEN  DO:
                    message "Проверьте правильность заполнения формы!".
                    RUN select-page IN THIS-PROCEDURE ( 2 ).
                    return  no-apply .
                                   END.
        when 'format-page' then DO:
                    message "На закладке <Формат...> необходимо выбрать поля для печати !".
                    RUN select-page IN THIS-PROCEDURE ( 3 ).
                    return no-apply.
                    END.
        OTHERWISE  DO:
                    message "Необходимо сходить на закладку <Продолжение...> !".
                    RUN select-page IN THIS-PROCEDURE ( 2 ).
                    return no-apply.
                    END.
        End case.
     End.
     ELSE
        CASE RETURN-VALUE:
        When 'First-page':U THEN  DO:
                RUN select-page IN THIS-PROCEDURE ( 1 ).
                return no-apply.
                                    END.
        When 'Second-page':U THEN  DO:
                    message "Проверьте правильность заполнения формы!".
                    RUN select-page IN THIS-PROCEDURE ( 2 ).
                    return  no-apply .
                                    END.
        When 'format-page':U THEN  DO:
                    message "Проверьте правильность заполнения формы!".
                    RUN select-page IN THIS-PROCEDURE ( 3 ).
                    return  no-apply .
                                    END.
        End case.
END PROCEDURE.
