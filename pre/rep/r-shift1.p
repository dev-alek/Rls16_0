block-level on error undo, throw.
define input parameter parparentproc              as handle    no-undo.
define input parameter p-parent-handle            as handle    no-undo .
define input parameter p-log-handle               as handle    no-undo .
define input parameter p-cont-handle              as handle    no-undo .
define input parameter p-rebh                     as handle    no-undo .
define input parameter p-report-id                as character no-undo .
define input parameter p-xsd-file                 as character no-undo .
define input parameter p-log-file-name            as character no-undo .
define input parameter p-batch                    as integer   no-undo .
define input parameter p-codex-id                 as integer   no-undo .
define input parameter p-ruleset-id               as integer   no-undo .
define input parameter p-weight                   as logical   no-undo.
define input parameter p-param-shft-qty           as character no-undo .
define input parameter p-obj-type                 as character no-undo .
define input parameter p-obj-code                 as integer   no-undo .
define input parameter p-z-number-list            as character no-undo.
define input parameter p-tog-1-pump-one           as logical   no-undo .
define input parameter p-tog-1-whole-gds          as logical   no-undo .
define input parameter p-tog-1-out-pump-with-icnt as logical   no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "$œÂ˜‡Ú¸ ÒÏÂÌÌÓ„Ó ÓÚ˜ÂÚ‡ - ÎËÒÚ 1 $":U.
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
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  temp-table report-headert no-undo
field datetimeStart as datetime
field datetimeEnd as datetime
field report-name as character
field report-label as character
field report-id as character
field report-db-num as integer
field task-num as integer
index pi is unique primary
report-id
.
define  temp-table report-parameterst no-undo
field report-id as character
field parameter-name as character
field parameter-label as character
field parameter-value-type as character
field parameter-value as character
field parameter-index as integer
field parameter-des as character
index pi is unique primary
report-id
parameter-name
parameter-index
.
define  temp-table report-errorst no-undo
field report-id as character
field ErrNum as integer
field ErrCode as integer
field ErrSeverity as integer
field ErrMessage as character
index pi is unique primary
report-id
ErrNum.
define  temp-table report-destinationt no-undo
field report-id as character
field destination-id as character
field destination as character
field destination-details as character
index pi is unique primary
report-id
destination-id.
define shared temp-table shiftt no-undo
field obj-type as character
field obj-code as integer
field obj-name as character
field obj-address as character
field obj-phone as character
field db-num as integer
field shift-date as date
field shift-num as integer
field shift-name as character
field base-code as integer
field curr-abbr as character
index pi is unique primary
obj-type
obj-code
shift-date
shift-num
.
define shared  temp-table shift-pgdst no-undo
field obj-type as character
field obj-code as integer
field shift-date as date
field shift-num as integer
field gds-code as integer
field gds-name as character
field start-state-qnty as decimal
field start-system-qnty as decimal
field start-state-qnty-2 as decimal
field start-system-qnty-2 as decimal
field end-state-qnty as decimal
field end-system-qnty as decimal
field end-state-qnty-2 as decimal
field end-system-qnty-2 as decimal
field in-qnty as decimal
field in-qnty-2 as decimal
field icnt-out-qnty as decimal
field end-price-sale as decimal
index pi is unique primary
obj-type
obj-code
shift-date
shift-num
gds-code
.
define shared  temp-table shift-pgds-int no-undo
field obj-type as character
field obj-code as integer
field shift-date as date
field shift-num as integer
field gds-code as integer
field doc-code as character
field cli-type-code as character
field cli-name as character
field fact-qnty as decimal
field fact-qnty-2 as decimal
index pi is unique primary
obj-type
obj-code
shift-date
shift-num
gds-code
doc-code
.
define shared  temp-table shift-pgds-outt no-undo
field obj-type as character
field obj-code as integer
field shift-date as date
field shift-num as integer
field gds-code as integer
field pay-code as integer
field curr-code as integer
field cp-type as integer
field out-name as character
field fact-qnty as decimal
field fact-qnty-2 as decimal
field fact-sum as decimal
index pi is unique primary
obj-type
obj-code
shift-date
shift-num
gds-code
pay-code
curr-code
.
define shared temp-table shift-grpt no-undo
field obj-type as character
field obj-code as integer
field shift-date as date
field shift-num as integer
field grp-code as integer
field full-grp-name as character
field start-qnty as decimal
field start-sum as decimal
field end-qnty as decimal
field end-sum as decimal
index pi is unique primary
obj-type
obj-code
shift-date
shift-num
grp-code
.
define shared temp-table shift-grp-int no-undo
field obj-type as character
field obj-code as integer
field shift-date as date
field shift-num as integer
field grp-code as integer
field doc-code as character
field cli-type-code as character
field cli-name as character
field fact-qnty as decimal
field fact-cost-sum as decimal
index pi is unique primary
obj-type
obj-code
shift-date
shift-num
grp-code
doc-code
.
define shared temp-table shift-grp-outt no-undo
field obj-type as character
field obj-code as integer
field shift-date as date
field shift-num as integer
field grp-code as integer
field pay-code as integer
field curr-code as integer
field cp-type as integer
field out-name as character
field fact-qnty as decimal
field fact-sum as decimal
index pi is unique primary
obj-type
obj-code
shift-date
shift-num
grp-code
pay-code
curr-code
.
define dataset shift-1t
for shiftt, shift-pgdst, shift-pgds-int, shift-pgds-outt, shift-grpt, shift-grp-int, shift-grp-outt,
report-headert, report-parameterst, report-errorst
data-relation r1 for shiftt, shift-pgdst
relation-fields (obj-type, obj-type, obj-code, obj-code, shift-date, shift-date, shift-num, shift-num) nested
data-relation r2 for shiftt, shift-grpt
relation-fields (obj-type, obj-type, obj-code, obj-code, shift-date, shift-date, shift-num, shift-num) nested
data-relation r11 for shift-pgdst, shift-pgds-outt
relation-fields (obj-type, obj-type, obj-code, obj-code, shift-date, shift-date, shift-num, shift-num, gds-code, gds-code) nested
data-relation r12 for shift-pgdst, shift-pgds-int
relation-fields (obj-type, obj-type, obj-code, obj-code, shift-date, shift-date, shift-num, shift-num, gds-code, gds-code) nested
data-relation r21 for shift-grpt, shift-grp-outt
relation-fields (obj-type, obj-type, obj-code, obj-code, shift-date, shift-date, shift-num, shift-num, grp-code, grp-code) nested
data-relation r22 for shift-grpt, shift-grp-int
relation-fields (obj-type, obj-type, obj-code, obj-code, shift-date, shift-date, shift-num, shift-num, grp-code, grp-code) nested
data-relation rh1 for report-headert, report-parameterst
relation-fields (report-id, report-id) nested
data-relation rh2 for report-headert, report-errorst
relation-fields (report-id, report-id) nested
.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure gds-attr-name :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-name in g#attr-lib
      (input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-value :
  define input  parameter p-gds-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define output parameter p-value    as character no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-write :
  define input parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define input parameter p-value    like ub.goods-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-write in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-exist :
  define input  parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input  parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define output parameter p-exist    as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-exist in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-delete :
  define input  parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input  parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-delete in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-copy-to :
  define input  parameter p-gds-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define input  parameter p-bh       as handle no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-copy-to in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-bh
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-copy :
  define input  parameter p-code as character no-undo .
  define output parameter p-copy as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-copy in g#attr-lib
      (input  p-code
      ,output p-copy
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-ptrl-divis :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-ptrl-divis in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-glob-sum-grps :
  define input  parameter p-mode        as character no-undo .
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code no-undo .
  define input-output parameter p-value as integer no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-glob-sum-grps in g#attr-lib
      (input p-mode
      ,input p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_gds-ptrl-densities :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input-output  parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_gds-ptrl-densities in g#attr-lib
      (input  p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_gds-CommodityCode :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input-output  parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_gds-CommodityCode in g#attr-lib
      (input  p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-office-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-office-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-mark-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-mark-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-emrc-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-emrc-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-group-np :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-group-np in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-item-matter-mark :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-item-matter-mark in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-type-method-calc :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-type-method-calc in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-is-loyalty-payment :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-is-loyalty-payment in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-15x80 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-15x80 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-8x50 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-8x50 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-6x50 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-6x50 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-manual-edit :
  define input  parameter p-code        as character no-undo .
  define output parameter p-section-num as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-batch-edit :
  define input  parameter p-code        as character no-undo .
  define output parameter p-section-num as integer   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-can-energy-value :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-can-energy-value in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-can-set-dt-seasons :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-can-set  as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-can-set-dt-seasons in g#attr-lib
      (input  p-gds-code
      ,output p-can-set
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure isExemplarGoods :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-gds-code as   integer                    no-undo .
  define output parameter o-result   as   logical                    no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run isExemplarGoods in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input p-gds-code
      ,output o-result
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure isVolumArticGoods :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-gds-code as   integer                    no-undo .
  define output parameter o-result   as   logical                    no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run isVolumArticGoods in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input p-gds-code
      ,output o-result
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
function is-gas returns logical
        (input p-gds-code as integer):
define variable result as logical no-undo.
define variable c-value as character no-undo.
define variable c-type as character no-undo.
do on error undo, return error:
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
      (input  p-gds-code
      ,input  'fuel-type':U
      ,output c-value
      ,output c-type) no-error.
end.
result = logical(c-value = 'metan':U) no-error.
return result.
end function.
procedure placelib_write-attr:
define input  parameter p-code     like ub.place-attr.attr-code .
define input  parameter p-obj-code like ub.place-attr.obj-code .
define input  parameter p-obj-type like ub.place-attr.obj-type .
define input  parameter p-pl-code  like ub.place-attr.pl-code .
define input  parameter p-value    like ub.place-attr.attr-value .
define output parameter p-ok       as logical.
define buffer buf_place-attr for ub.place-attr .
  do on error undo, return error return-value :
     p-ok = false.
     find first buf_place-attr exclusive-lock where buf_place-attr.attr-code   = p-code
                                                and buf_place-attr.obj-code    = p-obj-code
                                                and buf_place-attr.obj-type    = p-obj-type
                                                and buf_place-attr.pl-code     = p-pl-code no-error.
     if not available buf_place-attr then do :
        create buf_place-attr.
        assign
          buf_place-attr.attr-code   = p-code
          buf_place-attr.attr-value  = p-value
          buf_place-attr.obj-code    = p-obj-code
          buf_place-attr.obj-type    = p-obj-type
          buf_place-attr.pl-code     = p-pl-code
        .
        p-ok = true.
     end.
     else do:
        buf_place-attr.attr-value  = p-value .
        p-ok = true.
     end.
  end.
end.
procedure placelib_get-attr:
define input  parameter  p-code     like ub.place-attr.attr-code .
define input  parameter  p-obj-code like ub.place-attr.obj-code .
define input  parameter  p-obj-type like ub.place-attr.obj-type .
define input  parameter  p-pl-code  like ub.place-attr.pl-code .
define output parameter  p-value    like ub.place-attr.attr-value .
define output parameter  p-ok       as logical.
define buffer buf_place-attr for ub.place-attr .
  do on error undo, return error return-value :
     p-ok = false.
     find first buf_place-attr no-lock where buf_place-attr.attr-code   = p-code
                                                and buf_place-attr.obj-code    = p-obj-code
                                                and buf_place-attr.obj-type    = p-obj-type
                                                and buf_place-attr.pl-code     = p-pl-code no-error.
     if available buf_place-attr then do :
       p-value = buf_place-attr.attr-value.
       p-ok = true.
     end.
     else do :
       p-ok = false.
     end.
  end.
end.
procedure placelib_del-attr:
define input parameter  p-code     like ub.place-attr.attr-code .
define input parameter  p-obj-code like ub.place-attr.obj-code .
define input parameter  p-obj-type like ub.place-attr.obj-type .
define input parameter  p-pl-code  like ub.place-attr.pl-code .
define input parameter  p-value    like ub.place-attr.attr-value .
define output parameter p-ok       as logical.
define buffer buf_place-attr for ub.place-attr .
  do on error undo, return error return-value :
     p-ok = false.
     find first buf_place-attr exclusive-lock where buf_place-attr.attr-code   = p-code
                                                and buf_place-attr.obj-code    = p-obj-code
                                                and buf_place-attr.obj-type    = p-obj-type
                                                and buf_place-attr.pl-code     = p-pl-code no-error.
     if available buf_place-attr then do :
        delete buf_place-attr.
        p-ok = true.
     end.
  end.
end.
define shared stream Prnlibstream.
define variable pol1 as character no-undo .
define variable pol2 as decimal no-undo .
define variable pol2-l-state as decimal no-undo .
define variable pol2-kg-state as decimal no-undo .
define variable pol2-l-system as decimal no-undo .
define variable pol2-kg-system as decimal no-undo .
define variable pol3 as decimal no-undo .
define variable pol4 as decimal no-undo .
define variable pol5 as decimal no-undo .
define variable pol5-el as decimal no-undo .
define variable pol6 as decimal no-undo .
define variable pol6-el as decimal no-undo .
define variable pol7 as decimal no-undo .
define variable pol8 as character no-undo.
define variable pol9 as decimal no-undo .
define variable pol10 as decimal no-undo .
define variable pol11 as decimal no-undo .
define variable pol12 as decimal no-undo .
define variable pol13 as decimal no-undo .
define variable pol14 as decimal no-undo .
define variable pol15 as decimal no-undo .
define variable pol151 as decimal no-undo .
define variable pol152 as decimal no-undo .
define variable pol153 as decimal no-undo .
define variable pol16 as decimal no-undo .
define variable pol16-l as decimal no-undo .
define variable pol16-kg as decimal no-undo .
define variable pol17 as decimal no-undo .
define variable pol18 as decimal no-undo .
  procedure on-same-page :
    define input parameter p-line-number as integer no-undo .
    if p-line-number > page-size( PrnLibstream )
    then do:
      return .
    end.
    if line-counter( PrnLibstream ) + p-line-number > page-size( PrnLibstream )
    then do:
      page stream PrnLibstream .
    end.
  end procedure.
DEFINE FRAME FRAME-1
  pol1   column-label "1.1":C15   format "x(15)":U       space( 0 )
  sym1  column-label ":" format "x(1)":U space( 0 )
  pol2   column-label "1.2":C8    format  "->>>>9.99":U  space( 0 )
  sym2  column-label ":" format "x(1)":U space( 0 )
  pol3   column-label "1.3":C9    format ">>>>>9.99":U   space( 0 )
  sym3  column-label ":" format "x(1)":U space( 0 )
  pol4   column-label ".4"        format "99":U          space( 0 )
  sym4  column-label ":" format "x(1)":U space( 0 )
  pol5   column-label "1.5":C14   format ">>>>>>>>>>9.99":U space( 0 )
  sym5  column-label ":" format "x(1)":U space( 0 )
  pol6   column-label "1.6":C14   format ">>>>>>>>>>9.99":U space( 0 )
  sym6  column-label ":" format "x(1)":U space( 0 )
  pol7   column-label "1.7":C13   format "->>>>>>>>9.99":U   space( 0 )
  sym7  column-label ":" format "x(1)":U space( 0 )
  pol8   column-label ".8"        format "x(2)":U        space( 0 )
  sym8  column-label ":" format "x(1)":U space( 0 )
  pol9   column-label "1.9":C8   format ">>>>9.99":U   space( 0 )
  sym9  column-label ":" format "x(1)":U space( 0 )
  pol10  column-label "1.10":C8   format ">>>>9.99":U   space( 0 )
  sym10 column-label ":" format "x(1)":U space( 0 )
  pol11  column-label "1.11":C8   format ">>>>9.99":U   space( 0 )
  sym11 column-label ":" format "x(1)":U space( 0 )
  pol12  column-label "1.12":C6   format ">>9.99":U     space( 0 )
  sym12 column-label ":" format "x(1)":U space( 0 )
  pol13  column-label "1.13":C8   format ">>>>9.99":U   space( 0 )
  sym13 column-label ":" format "x(1)":U space( 0 )
  pol14  column-label "1.14":C8   format ">>>>9.99":U   space( 0 )
  sym14 column-label ":" format "x(1)":U space( 0 )
  pol15  column-label "1.15":C8   format ">>>>9.99":U   space( 0 )
  sym15 column-label ":" format "x(1)":U space( 0 )
  pol151 column-label "1.15.1":C8 format ">>>>9.99":U   space( 0 )
  sym16 column-label ":" format "x(1)":U space( 0 )
  pol152 column-label "1.15.2":C6 format "9.9999":U      space( 0 )
  sym17 column-label ":" format "x(1)":U space( 0 )
  pol153 column-label "1.15.3":C6 format "->9.99":U      space( 0 )
  sym18 column-label ":" format "x(1)":U space( 0 )
  pol16  column-label "1.16":C9   format "->>>>>9.99":U  space( 0 )
  sym19 column-label ":" format "x(1)":U space( 0 )
  pol17  column-label "1.17":C8   format ">>>>9.99":U   space( 0 )
  sym20 column-label ":" format "x(1)":U space( 0 )
  pol18  column-label "1.18":C8   format ">>>>9.99":U   space( 0 )
with width 232 down stream-io use-text NO-BOX.
define variable last-gds-code            as integer   no-undo initial 0.
define variable accum-by-pl-code-pol3-l  as decimal   no-undo.
define variable accum-by-pl-code-pol3-kg as decimal   no-undo.
define variable accum-pol3-l             as decimal   no-undo.
define variable accum-pol3-kg            as decimal   no-undo.
define variable accum-pol7               as decimal   no-undo.
define variable accum-by-pl-code-pol7 as decimal   no-undo.
define variable v-gds-print             as logical   no-undo.
define variable v-bc-print            as logical   no-undo .
define variable pobj-type    like  ub.stk-tot.obj-type   no-undo .
define variable pobj-code    like  ub.stk-tot.obj-code   no-undo .
define variable pshift-date  like  ub.stk-tot.shift-date no-undo .
define variable pshift-num   like  ub.stk-tot.shift-num  no-undo .
define variable pshift-date1 like  ub.stk-tot.shift-date no-undo .
define variable pshift-num1  like  ub.stk-tot.shift-num  no-undo .
define buffer previous-rvs-doc for ub.rvs-doc.
define buffer previous-rvs-line for ub.rvs-line.
define buffer previous-rvs-line-pump for ub.rvs-line-pump.
define buffer last-rvs-doc for ub.rvs-doc.
define buffer last-rvs-line for ub.rvs-line.
define buffer last-rvs-line-pump for ub.rvs-line-pump.
define buffer control-rvs-doc for ub.rvs-doc.
define buffer control-rvs-line-pump for ub.rvs-line-pump.
define buffer buf_shift-pgds for shift-pgdst.
define buffer buf_rvs-line-attr for ub.rvs-line-attr.
define buffer buf_prev-rvs-line-attr for ub.rvs-line-attr.
define buffer buf_control-rvs-doc for ub.rvs-doc.
define variable i-rvs-code as character no-undo.
define variable p-host-code       as integer   no-undo.
define variable v-sign            as decimal   no-undo .
define temp-table tt-pump-nozzle no-undo
  field gds-code    like ub.rvs-line.gds-code
  field pump-code   like ub.rvs-line-pump.pump-code
  field nozzle-code like ub.rvs-line-pump.nozzle-code
  index pi as unique primary
    gds-code
    pump-code
    nozzle-code
.
define temp-table temp-rvs-line no-undo like ub.rvs-line
  field gds-name   like ub.goods.gds-name
  field place_loc1 like ub.place.loc1         initial "??"
  field shift-date like ub.rvs-doc.shift-date
  field shift-num  like ub.rvs-doc.shift-num
  field v-bar-code like ub.bar-code.b-code
  field artic      like ub.goods.artic
  field prod-type  like ub.goods.prod-type
  field prod-code  like ub.goods.prod-code
.
define variable v-count    as integer   no-undo .
define variable v-count2   as integer   no-undo .
define variable v-tot-cnt  as integer   no-undo .
define buffer buf_rvs-line-pump for ub.rvs-line-pump .
define buffer buf_temp-rvs-line for temp-rvs-line .
assign
  pobj-type    = p-obj-type
  pobj-code    = p-obj-code
  pshift-date  = x-date-Start
  pshift-num   = x-shift-Start
  pshift-date1 = x-date-End
  pshift-num1  = x-shift-End
.
define buffer end_shift-obj      for ub.shift-obj .
define buffer previous-shift-obj for ub.shift-obj.
define variable fo      as decimal no-undo init 0.
define variable prev-fo as decimal no-undo init 0.
define variable moving  as logical no-undo init yes.
find first end_shift-obj share-lock
  where end_shift-obj.obj-type   = pobj-type
    and end_shift-obj.obj-code   = pobj-code
    and end_shift-obj.shift-date = pshift-date1
    and end_shift-obj.shift-num  = pshift-num1
    no-error.
if not available end_shift-obj then do:
  message
    vss-workfile vss-revision vss-description skip
    substitute("ÕÂ Ì‡È‰ÂÌ‡ ÒÏÂÌ‡ Ò ÔÓˇ‰ÍÓ‚˚Ï ÌÓÏÂÓÏ &1 ÓÚ &2 ‰Îˇ Ó·˙ÂÍÚ‡ &3 &4", pshift-num1, pshift-date1, pobj-type, pobj-code ) skip
    view-as alert-box error .
  return error.
end.
else do:
  assign
    fo = end_shift-obj.fact-order
  .
end.
find last previous-shift-obj share-lock
  where previous-shift-obj.obj-type = pobj-type
    and previous-shift-obj.obj-code = pobj-code
    and (( previous-shift-obj.shift-date = pshift-date
           and previous-shift-obj.shift-num < pshift-num
         )
         or previous-shift-obj.shift-date < pshift-date
        )
    use-index pi no-error.
if available previous-shift-obj then do:
    assign
      prev-fo = previous-shift-obj.fact-order
    .
end.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output p-host-code
  )  .
find first last-rvs-doc no-lock
  where last-rvs-doc.obj-type   = p-obj-type
    and last-rvs-doc.obj-code   = p-obj-code
    and last-rvs-doc.shift-date = x-date-end
    and last-rvs-doc.shift-num  = x-shift-end
    and last-rvs-doc.status_    = 'Ù‡ÍÚ':U
    and last-rvs-doc.rvs-type   = 'ÒÏÂÌ‡':U
  no-error.
if not available last-rvs-doc then do:
    if p-batch > 0 then do:      run write-log-and-file in p-log-handle (                 input 1                                          , input p-log-file-name                              , input 1                                          , input substitute("&1 &2 &3&4ÕÂ Ì‡È‰ÂÌ‡ ÒÏÂÌÌ‡ˇ Ò‚ÂÍ‡&4Ó·˙ÂÍÚ &5&6 ÒÏÂÌ‡ &7 &8"                                 ,vss-workfile                                 ,vss-revision                                 ,vss-description                                ,chr(10)                                ,p-obj-type                                 ,p-obj-code                                 ,string(x-date-End, "99/99/9999")                                ,x-shift-end )).    end.    else do:       run write-to-log in p-log-handle ( input substitute("&1 &2 &3&4ÕÂ Ì‡È‰ÂÌ‡ ÒÏÂÌÌ‡ˇ Ò‚ÂÍ‡&4Ó·˙ÂÍÚ &5&6 ÒÏÂÌ‡ &7 &8"                                 ,vss-workfile                                 ,vss-revision                                 ,vss-description                                ,chr(10)                                ,p-obj-type                                 ,p-obj-code                                 ,string(x-date-End, "99/99/9999")                                ,x-shift-end )).    end.
  if valid-handle(p-parent-handle)
  and lookup("cb_write-report-error", p-parent-handle:internal-entries) > 0
  and valid-handle(p-rebh) then do:
    run cb_write-report-error in p-parent-handle ( input p-rebh
                                                  ,input p-report-id
                                                  ,input ?
                                                  ,input '3':U
                                                  ,input substitute("&1 &2 &3&4ÕÂ Ì‡È‰ÂÌ‡ ÒÏÂÌÌ‡ˇ Ò‚ÂÍ‡&4Ó·˙ÂÍÚ &5&6 ÒÏÂÌ‡ &7 &8"                                 ,vss-workfile                                 ,vss-revision                                 ,vss-description                                ,chr(10)                                ,p-obj-type                                 ,p-obj-code                                 ,string(x-date-End, "99/99/9999")                                ,x-shift-end )).
  end.
  return error.
END.
if available previous-shift-obj then do:
  find first previous-rvs-doc no-lock
    where previous-rvs-doc.obj-type   = p-obj-type
      and previous-rvs-doc.obj-code   = p-obj-code
      and previous-rvs-doc.shift-date = previous-shift-obj.shift-date
      and previous-rvs-doc.shift-num  = previous-shift-obj.shift-num
      and previous-rvs-doc.status_    = 'Ù‡ÍÚ':U
      and previous-rvs-doc.rvs-type   = 'ÒÏÂÌ‡':U
    no-error.
end.
if p-weight = true then do:
  case p-param-shft-qty :
    when "system":U then do:
      form header
        string( p-z-number-list, "x(198)":U ) format "x(198)":U skip "-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------" skip "  Õ¿»Ã≈ÕŒ¬¿Õ»≈ :–¿—◊≈“ÕŒ-:œŒ—“”œ»À:         œŒ ¿«¿“≈À» —◊≈“Õ€’ Ã≈’¿Õ»«ÃŒ¬        :                          Œ—“¿“Œ  Õ¿  ŒÕ≈÷ —Ã≈Õ€                                                 :    –≈«”À‹“¿“€   " skip "   ÔÓ‰ÛÍÚ‡    :ÍÌËÊÌ˚È  :Á‡ ÒÏÂÌÛ:----------------------------------------------:-------------------------------------------------------------------------------------------------:-----------------" skip "               :Œ—“¿“Œ   :        :π :  Õ‡ ÍÓÌÂˆ    :  Õ‡ Ì‡˜‡ÎÓ   :   –¿—’Œƒ    :π : Œ¡Ÿ»…  :  ¬Œƒ€  : Œ¡Ÿ»…  : ¬Œƒ€ : ‘¿ “   : ‘¿ “   : ‘¿ “   : ‘¿ “   :‘¿ “  :‘¿ “  :–¿—◊≈“ÕŒ- :»«À»ÿ » :Õ≈ƒŒ—“¿◊" skip "               :Ì‡ Ì‡˜‡ÎÓ:        :“ :  ÒÏÂÌ˚       :  ÒÏÂÌ˚       :             :– :ÛÓ‚ÂÌ¸ :ÛÓ‚ÂÌ¸ : Ó·˙ÂÏ  : Ó·˙ÂÏ: Œ¡⁄≈Ã ‚: Œ¡⁄≈Ã ‚: Œ¡⁄≈Ã  : Œ¡⁄≈Ã  :œÀ-“‹ :“≈Ãœ. :ÍÌËÊÌ˚È   :        :        " skip "               :ÒÏÂÌ˚    :        :– :              :              :             :≈ :‚ÍÎ˛˜‡ˇ :        :‚ÍÎ˛˜‡ˇ :      : ÚÛ·Ó- : ÂÁÂ- : ‚ÒÂ„Ó  : ‚ÒÂ„Ó  :      :      :          :        :        " skip "               :         :        :  :              :              :             :« :  ‚Ó‰Û  :        :  ‚Ó‰Û  :      : ÔÓ‚Ó‰Â: ‚Û‡Â  :        :        :      :      :          :        :        " skip "               :    Í„   :   Í„   :  :      Î       :      Î       :      Î      :  :   ÒÏ   :   ÒÏ   :    Î   :   Î  :    Î   :    Î   :    Î   :   Í„   : Í„/Î :  C   :    Í„    :   Í„   :   Í„   " skip "-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
      with frame TopFrameKgSystem width 232 page-top no-labels no-box.
      put stream PrnLibStream unformatted
        string( p-z-number-list, "x(198)":U ) format "x(198)":U skip "-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------" skip "  Õ¿»Ã≈ÕŒ¬¿Õ»≈ :–¿—◊≈“ÕŒ-:œŒ—“”œ»À:         œŒ ¿«¿“≈À» —◊≈“Õ€’ Ã≈’¿Õ»«ÃŒ¬        :                          Œ—“¿“Œ  Õ¿  ŒÕ≈÷ —Ã≈Õ€                                                 :    –≈«”À‹“¿“€   " skip "   ÔÓ‰ÛÍÚ‡    :ÍÌËÊÌ˚È  :Á‡ ÒÏÂÌÛ:----------------------------------------------:-------------------------------------------------------------------------------------------------:-----------------" skip "               :Œ—“¿“Œ   :        :π :  Õ‡ ÍÓÌÂˆ    :  Õ‡ Ì‡˜‡ÎÓ   :   –¿—’Œƒ    :π : Œ¡Ÿ»…  :  ¬Œƒ€  : Œ¡Ÿ»…  : ¬Œƒ€ : ‘¿ “   : ‘¿ “   : ‘¿ “   : ‘¿ “   :‘¿ “  :‘¿ “  :–¿—◊≈“ÕŒ- :»«À»ÿ » :Õ≈ƒŒ—“¿◊" skip "               :Ì‡ Ì‡˜‡ÎÓ:        :“ :  ÒÏÂÌ˚       :  ÒÏÂÌ˚       :             :– :ÛÓ‚ÂÌ¸ :ÛÓ‚ÂÌ¸ : Ó·˙ÂÏ  : Ó·˙ÂÏ: Œ¡⁄≈Ã ‚: Œ¡⁄≈Ã ‚: Œ¡⁄≈Ã  : Œ¡⁄≈Ã  :œÀ-“‹ :“≈Ãœ. :ÍÌËÊÌ˚È   :        :        " skip "               :ÒÏÂÌ˚    :        :– :              :              :             :≈ :‚ÍÎ˛˜‡ˇ :        :‚ÍÎ˛˜‡ˇ :      : ÚÛ·Ó- : ÂÁÂ- : ‚ÒÂ„Ó  : ‚ÒÂ„Ó  :      :      :          :        :        " skip "               :         :        :  :              :              :             :« :  ‚Ó‰Û  :        :  ‚Ó‰Û  :      : ÔÓ‚Ó‰Â: ‚Û‡Â  :        :        :      :      :          :        :        " skip "               :    Í„   :   Í„   :  :      Î       :      Î       :      Î      :  :   ÒÏ   :   ÒÏ   :    Î   :   Î  :    Î   :    Î   :    Î   :   Í„   : Í„/Î :  C   :    Í„    :   Í„   :   Í„   " skip "-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
      .
      view stream Prnlibstream frame TopFrameKgSystem .
    end.
    when "state":U then do:
      form header
        string( p-z-number-list, "x(198)":U ) format "x(198)":U skip "-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------" skip "  Õ¿»Ã≈ÕŒ¬¿Õ»≈ :‘¿ “»◊≈—-:œŒ—“”œ»À:         œŒ ¿«¿“≈À» —◊≈“Õ€’ Ã≈’¿Õ»«ÃŒ¬        :                          Œ—“¿“Œ  Õ¿  ŒÕ≈÷ —Ã≈Õ€                                                 :    –≈«”À‹“¿“€   " skip "   ÔÓ‰ÛÍÚ‡    :    »…   :Á‡ ÒÏÂÌÛ:----------------------------------------------:-------------------------------------------------------------------------------------------------:-----------------" skip "               : Œ—“¿“Œ  :        :π :  Õ‡ ÍÓÌÂˆ    :  Õ‡ Ì‡˜‡ÎÓ   :   –¿—’Œƒ    :π : Œ¡Ÿ»…  :  ¬Œƒ€  : Œ¡Ÿ»…  : ¬Œƒ€ : ‘¿ “   : ‘¿ “   : ‘¿ “   : ‘¿ “   :‘¿ “  :‘¿ “  :–¿—◊≈“Õ€… :»«À»ÿ » :Õ≈ƒŒ—“¿◊" skip "               :Ì‡ Ì‡˜‡ÎÓ:        :“ :  ÒÏÂÌ˚       :  ÒÏÂÌ˚       :             :– :ÛÓ‚ÂÌ¸ :ÛÓ‚ÂÌ¸ : Ó·˙ÂÏ  : Ó·˙ÂÏ: Œ¡⁄≈Ã ‚: Œ¡⁄≈Ã ‚: Œ¡⁄≈Ã  : Œ¡⁄≈Ã  :œÀ-“‹ :“≈Ãœ. :          :        :        " skip "               :ÒÏÂÌ˚    :        :– :              :              :             :≈ :‚ÍÎ˛˜‡ˇ :        :‚ÍÎ˛˜‡ˇ :      : ÚÛ·Ó- : ÂÁÂ- : ‚ÒÂ„Ó  : ‚ÒÂ„Ó  :      :      :          :        :        " skip "               :         :        :  :              :              :             :« :  ‚Ó‰Û  :        :  ‚Ó‰Û  :      : ÔÓ‚Ó‰Â: ‚Û‡Â  :        :        :      :      :          :        :        " skip "               :    Í„   :   Í„   :  :      Î       :      Î       :      Î      :  :   ÒÏ   :   ÒÏ   :    Î   :   Î  :    Î   :    Î   :    Î   :   Í„   : Í„/Î :  C   :    Í„    :   Í„   :   Í„   " skip "-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
      with frame TopFrameKgState width 232 page-top no-labels no-box.
      put stream PrnLibStream unformatted
        string( p-z-number-list, "x(198)":U ) format "x(198)":U skip "-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------" skip "  Õ¿»Ã≈ÕŒ¬¿Õ»≈ :‘¿ “»◊≈—-:œŒ—“”œ»À:         œŒ ¿«¿“≈À» —◊≈“Õ€’ Ã≈’¿Õ»«ÃŒ¬        :                          Œ—“¿“Œ  Õ¿  ŒÕ≈÷ —Ã≈Õ€                                                 :    –≈«”À‹“¿“€   " skip "   ÔÓ‰ÛÍÚ‡    :    »…   :Á‡ ÒÏÂÌÛ:----------------------------------------------:-------------------------------------------------------------------------------------------------:-----------------" skip "               : Œ—“¿“Œ  :        :π :  Õ‡ ÍÓÌÂˆ    :  Õ‡ Ì‡˜‡ÎÓ   :   –¿—’Œƒ    :π : Œ¡Ÿ»…  :  ¬Œƒ€  : Œ¡Ÿ»…  : ¬Œƒ€ : ‘¿ “   : ‘¿ “   : ‘¿ “   : ‘¿ “   :‘¿ “  :‘¿ “  :–¿—◊≈“Õ€… :»«À»ÿ » :Õ≈ƒŒ—“¿◊" skip "               :Ì‡ Ì‡˜‡ÎÓ:        :“ :  ÒÏÂÌ˚       :  ÒÏÂÌ˚       :             :– :ÛÓ‚ÂÌ¸ :ÛÓ‚ÂÌ¸ : Ó·˙ÂÏ  : Ó·˙ÂÏ: Œ¡⁄≈Ã ‚: Œ¡⁄≈Ã ‚: Œ¡⁄≈Ã  : Œ¡⁄≈Ã  :œÀ-“‹ :“≈Ãœ. :          :        :        " skip "               :ÒÏÂÌ˚    :        :– :              :              :             :≈ :‚ÍÎ˛˜‡ˇ :        :‚ÍÎ˛˜‡ˇ :      : ÚÛ·Ó- : ÂÁÂ- : ‚ÒÂ„Ó  : ‚ÒÂ„Ó  :      :      :          :        :        " skip "               :         :        :  :              :              :             :« :  ‚Ó‰Û  :        :  ‚Ó‰Û  :      : ÔÓ‚Ó‰Â: ‚Û‡Â  :        :        :      :      :          :        :        " skip "               :    Í„   :   Í„   :  :      Î       :      Î       :      Î      :  :   ÒÏ   :   ÒÏ   :    Î   :   Î  :    Î   :    Î   :    Î   :   Í„   : Í„/Î :  C   :    Í„    :   Í„   :   Í„   " skip "-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
      .
      view stream Prnlibstream frame TopFrameKgState .
    end.
    when "state-all-per":U then do:
      form header
        string( p-z-number-list, "x(198)":U ) format "x(198)":U skip "-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------" skip "  Õ¿»Ã≈ÕŒ¬¿Õ»≈ :‘¿ “»◊≈—-:œŒ—“”œ»À:         œŒ ¿«¿“≈À» —◊≈“Õ€’ Ã≈’¿Õ»«ÃŒ¬        :                          Œ—“¿“Œ  Õ¿  ŒÕ≈÷ —Ã≈Õ€                                                 :    –≈«”À‹“¿“€   " skip "   ÔÓ‰ÛÍÚ‡    :    »…   :Á‡ ÒÏÂÌÛ:----------------------------------------------:-------------------------------------------------------------------------------------------------:-----------------" skip "               : Œ—“¿“Œ  :        :π :  Õ‡ ÍÓÌÂˆ    :  Õ‡ Ì‡˜‡ÎÓ   :   –¿—’Œƒ    :π : Œ¡Ÿ»…  :  ¬Œƒ€  : Œ¡Ÿ»…  : ¬Œƒ€ : ‘¿ “   : ‘¿ “   : ‘¿ “   : ‘¿ “   :‘¿ “  :‘¿ “  :–¿—◊≈“ÕŒ- :»«À»ÿ » :Õ≈ƒŒ—“¿◊" skip "               :Ì‡ Ì‡˜‡ÎÓ:        :“ :  ÒÏÂÌ˚       :  ÒÏÂÌ˚       :             :– :ÛÓ‚ÂÌ¸ :ÛÓ‚ÂÌ¸ : Ó·˙ÂÏ  : Ó·˙ÂÏ: Œ¡⁄≈Ã ‚: Œ¡⁄≈Ã ‚: Œ¡⁄≈Ã  : Œ¡⁄≈Ã  :œÀ-“‹ :“≈Ãœ. :ÍÌËÊÌ˚È   :        :        " skip "               :ÒÏÂÌ˚    :        :– :              :              :             :≈ :‚ÍÎ˛˜‡ˇ :        :‚ÍÎ˛˜‡ˇ :      : ÚÛ·Ó- : ÂÁÂ- : ‚ÒÂ„Ó  : ‚ÒÂ„Ó  :      :      :          :        :        " skip "               :         :        :  :              :              :             :« :  ‚Ó‰Û  :        :  ‚Ó‰Û  :      : ÔÓ‚Ó‰Â: ‚Û‡Â  :        :        :      :      :          :        :        " skip "               :    Í„   :   Í„   :  :      Î       :      Î       :      Î      :  :   ÒÏ   :   ÒÏ   :    Î   :   Î  :    Î   :    Î   :    Î   :   Í„   : Í„/Î :  C   :    Í„    :   Í„   :   Í„   " skip "-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
      with frame TopFrameKgState-all-per width 232 page-top no-labels no-box.
      put stream PrnLibStream unformatted
        string( p-z-number-list, "x(198)":U ) format "x(198)":U skip "-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------" skip "  Õ¿»Ã≈ÕŒ¬¿Õ»≈ :‘¿ “»◊≈—-:œŒ—“”œ»À:         œŒ ¿«¿“≈À» —◊≈“Õ€’ Ã≈’¿Õ»«ÃŒ¬        :                          Œ—“¿“Œ  Õ¿  ŒÕ≈÷ —Ã≈Õ€                                                 :    –≈«”À‹“¿“€   " skip "   ÔÓ‰ÛÍÚ‡    :    »…   :Á‡ ÒÏÂÌÛ:----------------------------------------------:-------------------------------------------------------------------------------------------------:-----------------" skip "               : Œ—“¿“Œ  :        :π :  Õ‡ ÍÓÌÂˆ    :  Õ‡ Ì‡˜‡ÎÓ   :   –¿—’Œƒ    :π : Œ¡Ÿ»…  :  ¬Œƒ€  : Œ¡Ÿ»…  : ¬Œƒ€ : ‘¿ “   : ‘¿ “   : ‘¿ “   : ‘¿ “   :‘¿ “  :‘¿ “  :–¿—◊≈“ÕŒ- :»«À»ÿ » :Õ≈ƒŒ—“¿◊" skip "               :Ì‡ Ì‡˜‡ÎÓ:        :“ :  ÒÏÂÌ˚       :  ÒÏÂÌ˚       :             :– :ÛÓ‚ÂÌ¸ :ÛÓ‚ÂÌ¸ : Ó·˙ÂÏ  : Ó·˙ÂÏ: Œ¡⁄≈Ã ‚: Œ¡⁄≈Ã ‚: Œ¡⁄≈Ã  : Œ¡⁄≈Ã  :œÀ-“‹ :“≈Ãœ. :ÍÌËÊÌ˚È   :        :        " skip "               :ÒÏÂÌ˚    :        :– :              :              :             :≈ :‚ÍÎ˛˜‡ˇ :        :‚ÍÎ˛˜‡ˇ :      : ÚÛ·Ó- : ÂÁÂ- : ‚ÒÂ„Ó  : ‚ÒÂ„Ó  :      :      :          :        :        " skip "               :         :        :  :              :              :             :« :  ‚Ó‰Û  :        :  ‚Ó‰Û  :      : ÔÓ‚Ó‰Â: ‚Û‡Â  :        :        :      :      :          :        :        " skip "               :    Í„   :   Í„   :  :      Î       :      Î       :      Î      :  :   ÒÏ   :   ÒÏ   :    Î   :   Î  :    Î   :    Î   :    Î   :   Í„   : Í„/Î :  C   :    Í„    :   Í„   :   Í„   " skip "-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
      .
      view stream Prnlibstream frame TopFrameKgState-all-per .
    end.
  end case.
end.
else do:
  case p-param-shft-qty :
    when "system":U then do:
      form header
        string( p-z-number-list, "x(198)":U ) format "x(198)":U skip "-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------" skip "  Õ¿»Ã≈ÕŒ¬¿Õ»≈ :–¿—◊≈“ÕŒ-:œŒ—“”œ»À:         œŒ ¿«¿“≈À» —◊≈“Õ€’ Ã≈’¿Õ»«ÃŒ¬        :                          Œ—“¿“Œ  Õ¿  ŒÕ≈÷ —Ã≈Õ€                                                 :    –≈«”À‹“¿“€   " skip "   ÔÓ‰ÛÍÚ‡    :ÍÌËÊÌ˚È  :Á‡ ÒÏÂÌÛ:----------------------------------------------:-------------------------------------------------------------------------------------------------:-----------------" skip "               :Œ—“¿“Œ   :        :π :  Õ‡ ÍÓÌÂˆ    :  Õ‡ Ì‡˜‡ÎÓ   :   –¿—’Œƒ    :π : Œ¡Ÿ»…  :  ¬Œƒ€  : Œ¡Ÿ»…  : ¬Œƒ€ : ‘¿ “   : ‘¿ “   : ‘¿ “   : ‘¿ “   :‘¿ “  :‘¿ “  :–¿—◊≈“ÕŒ- :»«À»ÿ » :Õ≈ƒŒ—“¿◊" skip "               :Ì‡ Ì‡˜‡ÎÓ:        :“ :  ÒÏÂÌ˚       :  ÒÏÂÌ˚       :             :– :ÛÓ‚ÂÌ¸ :ÛÓ‚ÂÌ¸ : Ó·˙ÂÏ  : Ó·˙ÂÏ: Œ¡⁄≈Ã ‚: Œ¡⁄≈Ã ‚: Œ¡⁄≈Ã  : Œ¡⁄≈Ã  :œÀ-“‹ :“≈Ãœ. :ÍÌËÊÌ˚È   :        :        " skip "               :ÒÏÂÌ˚    :        :– :              :              :             :≈ :‚ÍÎ˛˜‡ˇ :        :‚ÍÎ˛˜‡ˇ :      : ÚÛ·Ó- : ÂÁÂ- : ‚ÒÂ„Ó  : ‚ÒÂ„Ó  :      :      :          :        :        " skip "               :         :        :  :              :              :             :« :  ‚Ó‰Û  :        :  ‚Ó‰Û  :      : ÔÓ‚Ó‰Â: ‚Û‡Â  :        :        :      :      :          :        :        " skip "               :    Î    :    Î   :  :      Î       :      Î       :      Î      :  :   ÒÏ   :   ÒÏ   :    Î   :   Î  :    Î   :    Î   :    Î   :   Í„   : Í„/Î :  C   :     Î    :    Î   :    Î   " skip "-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
      with frame TopFrameSystem width 232 page-top no-labels no-box.
      put stream PrnLibStream unformatted
        string( p-z-number-list, "x(198)":U ) format "x(198)":U skip "-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------" skip "  Õ¿»Ã≈ÕŒ¬¿Õ»≈ :–¿—◊≈“ÕŒ-:œŒ—“”œ»À:         œŒ ¿«¿“≈À» —◊≈“Õ€’ Ã≈’¿Õ»«ÃŒ¬        :                          Œ—“¿“Œ  Õ¿  ŒÕ≈÷ —Ã≈Õ€                                                 :    –≈«”À‹“¿“€   " skip "   ÔÓ‰ÛÍÚ‡    :ÍÌËÊÌ˚È  :Á‡ ÒÏÂÌÛ:----------------------------------------------:-------------------------------------------------------------------------------------------------:-----------------" skip "               :Œ—“¿“Œ   :        :π :  Õ‡ ÍÓÌÂˆ    :  Õ‡ Ì‡˜‡ÎÓ   :   –¿—’Œƒ    :π : Œ¡Ÿ»…  :  ¬Œƒ€  : Œ¡Ÿ»…  : ¬Œƒ€ : ‘¿ “   : ‘¿ “   : ‘¿ “   : ‘¿ “   :‘¿ “  :‘¿ “  :–¿—◊≈“ÕŒ- :»«À»ÿ » :Õ≈ƒŒ—“¿◊" skip "               :Ì‡ Ì‡˜‡ÎÓ:        :“ :  ÒÏÂÌ˚       :  ÒÏÂÌ˚       :             :– :ÛÓ‚ÂÌ¸ :ÛÓ‚ÂÌ¸ : Ó·˙ÂÏ  : Ó·˙ÂÏ: Œ¡⁄≈Ã ‚: Œ¡⁄≈Ã ‚: Œ¡⁄≈Ã  : Œ¡⁄≈Ã  :œÀ-“‹ :“≈Ãœ. :ÍÌËÊÌ˚È   :        :        " skip "               :ÒÏÂÌ˚    :        :– :              :              :             :≈ :‚ÍÎ˛˜‡ˇ :        :‚ÍÎ˛˜‡ˇ :      : ÚÛ·Ó- : ÂÁÂ- : ‚ÒÂ„Ó  : ‚ÒÂ„Ó  :      :      :          :        :        " skip "               :         :        :  :              :              :             :« :  ‚Ó‰Û  :        :  ‚Ó‰Û  :      : ÔÓ‚Ó‰Â: ‚Û‡Â  :        :        :      :      :          :        :        " skip "               :    Î    :    Î   :  :      Î       :      Î       :      Î      :  :   ÒÏ   :   ÒÏ   :    Î   :   Î  :    Î   :    Î   :    Î   :   Í„   : Í„/Î :  C   :     Î    :    Î   :    Î   " skip "-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
      .
      view stream Prnlibstream frame TopFrameSystem.
    end.
    when "state":U then do:
      form header
        string( p-z-number-list, "x(198)":U ) format "x(198)":U skip "-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------" skip "  Õ¿»Ã≈ÕŒ¬¿Õ»≈ :‘¿ “»◊≈—-:œŒ—“”œ»À:         œŒ ¿«¿“≈À» —◊≈“Õ€’ Ã≈’¿Õ»«ÃŒ¬        :                          Œ—“¿“Œ  Õ¿  ŒÕ≈÷ —Ã≈Õ€                                                 :    –≈«”À‹“¿“€   " skip "   ÔÓ‰ÛÍÚ‡    :    »…   :Á‡ ÒÏÂÌÛ:----------------------------------------------:-------------------------------------------------------------------------------------------------:-----------------" skip "               : Œ—“¿“Œ  :        :π :  Õ‡ ÍÓÌÂˆ    :  Õ‡ Ì‡˜‡ÎÓ   :   –¿—’Œƒ    :π : Œ¡Ÿ»…  :  ¬Œƒ€  : Œ¡Ÿ»…  : ¬Œƒ€ : ‘¿ “   : ‘¿ “   : ‘¿ “   : ‘¿ “   :‘¿ “  :‘¿ “  :–¿—◊≈“Õ€… :»«À»ÿ » :Õ≈ƒŒ—“¿◊" skip "               :Ì‡ Ì‡˜‡ÎÓ:        :“ :  ÒÏÂÌ˚       :  ÒÏÂÌ˚       :             :– :ÛÓ‚ÂÌ¸ :ÛÓ‚ÂÌ¸ : Ó·˙ÂÏ  : Ó·˙ÂÏ: Œ¡⁄≈Ã ‚: Œ¡⁄≈Ã ‚: Œ¡⁄≈Ã  : Œ¡⁄≈Ã  :œÀ-“‹ :“≈Ãœ. :          :        :        " skip "               :ÒÏÂÌ˚    :        :– :              :              :             :≈ :‚ÍÎ˛˜‡ˇ :        :‚ÍÎ˛˜‡ˇ :      : ÚÛ·Ó- : ÂÁÂ- : ‚ÒÂ„Ó  : ‚ÒÂ„Ó  :      :      :          :        :        " skip "               :         :        :  :              :              :             :« :  ‚Ó‰Û  :        :  ‚Ó‰Û  :      : ÔÓ‚Ó‰Â: ‚Û‡Â  :        :        :      :      :          :        :        " skip "               :    Î    :    Î   :  :      Î       :      Î       :      Î      :  :   ÒÏ   :   ÒÏ   :    Î   :   Î  :    Î   :    Î   :    Î   :   Í„   : Í„/Î :  C   :    Î     :    Î   :    Î   " skip "-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
      with frame TopFrameState width 232 page-top no-labels no-box.
      put stream PrnLibStream unformatted
        string( p-z-number-list, "x(198)":U ) format "x(198)":U skip "-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------" skip "  Õ¿»Ã≈ÕŒ¬¿Õ»≈ :‘¿ “»◊≈—-:œŒ—“”œ»À:         œŒ ¿«¿“≈À» —◊≈“Õ€’ Ã≈’¿Õ»«ÃŒ¬        :                          Œ—“¿“Œ  Õ¿  ŒÕ≈÷ —Ã≈Õ€                                                 :    –≈«”À‹“¿“€   " skip "   ÔÓ‰ÛÍÚ‡    :    »…   :Á‡ ÒÏÂÌÛ:----------------------------------------------:-------------------------------------------------------------------------------------------------:-----------------" skip "               : Œ—“¿“Œ  :        :π :  Õ‡ ÍÓÌÂˆ    :  Õ‡ Ì‡˜‡ÎÓ   :   –¿—’Œƒ    :π : Œ¡Ÿ»…  :  ¬Œƒ€  : Œ¡Ÿ»…  : ¬Œƒ€ : ‘¿ “   : ‘¿ “   : ‘¿ “   : ‘¿ “   :‘¿ “  :‘¿ “  :–¿—◊≈“Õ€… :»«À»ÿ » :Õ≈ƒŒ—“¿◊" skip "               :Ì‡ Ì‡˜‡ÎÓ:        :“ :  ÒÏÂÌ˚       :  ÒÏÂÌ˚       :             :– :ÛÓ‚ÂÌ¸ :ÛÓ‚ÂÌ¸ : Ó·˙ÂÏ  : Ó·˙ÂÏ: Œ¡⁄≈Ã ‚: Œ¡⁄≈Ã ‚: Œ¡⁄≈Ã  : Œ¡⁄≈Ã  :œÀ-“‹ :“≈Ãœ. :          :        :        " skip "               :ÒÏÂÌ˚    :        :– :              :              :             :≈ :‚ÍÎ˛˜‡ˇ :        :‚ÍÎ˛˜‡ˇ :      : ÚÛ·Ó- : ÂÁÂ- : ‚ÒÂ„Ó  : ‚ÒÂ„Ó  :      :      :          :        :        " skip "               :         :        :  :              :              :             :« :  ‚Ó‰Û  :        :  ‚Ó‰Û  :      : ÔÓ‚Ó‰Â: ‚Û‡Â  :        :        :      :      :          :        :        " skip "               :    Î    :    Î   :  :      Î       :      Î       :      Î      :  :   ÒÏ   :   ÒÏ   :    Î   :   Î  :    Î   :    Î   :    Î   :   Í„   : Í„/Î :  C   :    Î     :    Î   :    Î   " skip "-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
      .
      view stream Prnlibstream frame TopFrameState.
    end.
    when "state-all-per":U then do:
      form header
        string( p-z-number-list, "x(198)":U ) format "x(198)":U skip "-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------" skip "  Õ¿»Ã≈ÕŒ¬¿Õ»≈ :‘¿ “»◊≈—-:œŒ—“”œ»À:         œŒ ¿«¿“≈À» —◊≈“Õ€’ Ã≈’¿Õ»«ÃŒ¬        :                          Œ—“¿“Œ  Õ¿  ŒÕ≈÷ —Ã≈Õ€                                                 :    –≈«”À‹“¿“€   " skip "   ÔÓ‰ÛÍÚ‡    :    »…   :Á‡ ÒÏÂÌÛ:----------------------------------------------:-------------------------------------------------------------------------------------------------:-----------------" skip "               : Œ—“¿“Œ  :        :π :  Õ‡ ÍÓÌÂˆ    :  Õ‡ Ì‡˜‡ÎÓ   :   –¿—’Œƒ    :π : Œ¡Ÿ»…  :  ¬Œƒ€  : Œ¡Ÿ»…  : ¬Œƒ€ : ‘¿ “   : ‘¿ “   : ‘¿ “   : ‘¿ “   :‘¿ “  :‘¿ “  :–¿—◊≈“ÕŒ- :»«À»ÿ » :Õ≈ƒŒ—“¿◊" skip "               :Ì‡ Ì‡˜‡ÎÓ:        :“ :  ÒÏÂÌ˚       :  ÒÏÂÌ˚       :             :– :ÛÓ‚ÂÌ¸ :ÛÓ‚ÂÌ¸ : Ó·˙ÂÏ  : Ó·˙ÂÏ: Œ¡⁄≈Ã ‚: Œ¡⁄≈Ã ‚: Œ¡⁄≈Ã  : Œ¡⁄≈Ã  :œÀ-“‹ :“≈Ãœ. :ÍÌËÊÌ˚È   :        :        " skip "               :ÒÏÂÌ˚    :        :– :              :              :             :≈ :‚ÍÎ˛˜‡ˇ :        :‚ÍÎ˛˜‡ˇ :      : ÚÛ·Ó- : ÂÁÂ- : ‚ÒÂ„Ó  : ‚ÒÂ„Ó  :      :      :          :        :        " skip "               :         :        :  :              :              :             :« :  ‚Ó‰Û  :        :  ‚Ó‰Û  :      : ÔÓ‚Ó‰Â: ‚Û‡Â  :        :        :      :      :          :        :        " skip "               :    Î    :    Î   :  :      Î       :      Î       :      Î      :  :   ÒÏ   :   ÒÏ   :    Î   :   Î  :    Î   :    Î   :    Î   :   Í„   : Í„/Î :  C   :    Î     :    Î   :    Î   " skip "-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
      with frame TopFrameState-all-per width 232 page-top no-labels no-box.
      put stream PrnLibStream unformatted
        string( p-z-number-list, "x(198)":U ) format "x(198)":U skip "-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------" skip "  Õ¿»Ã≈ÕŒ¬¿Õ»≈ :‘¿ “»◊≈—-:œŒ—“”œ»À:         œŒ ¿«¿“≈À» —◊≈“Õ€’ Ã≈’¿Õ»«ÃŒ¬        :                          Œ—“¿“Œ  Õ¿  ŒÕ≈÷ —Ã≈Õ€                                                 :    –≈«”À‹“¿“€   " skip "   ÔÓ‰ÛÍÚ‡    :    »…   :Á‡ ÒÏÂÌÛ:----------------------------------------------:-------------------------------------------------------------------------------------------------:-----------------" skip "               : Œ—“¿“Œ  :        :π :  Õ‡ ÍÓÌÂˆ    :  Õ‡ Ì‡˜‡ÎÓ   :   –¿—’Œƒ    :π : Œ¡Ÿ»…  :  ¬Œƒ€  : Œ¡Ÿ»…  : ¬Œƒ€ : ‘¿ “   : ‘¿ “   : ‘¿ “   : ‘¿ “   :‘¿ “  :‘¿ “  :–¿—◊≈“ÕŒ- :»«À»ÿ » :Õ≈ƒŒ—“¿◊" skip "               :Ì‡ Ì‡˜‡ÎÓ:        :“ :  ÒÏÂÌ˚       :  ÒÏÂÌ˚       :             :– :ÛÓ‚ÂÌ¸ :ÛÓ‚ÂÌ¸ : Ó·˙ÂÏ  : Ó·˙ÂÏ: Œ¡⁄≈Ã ‚: Œ¡⁄≈Ã ‚: Œ¡⁄≈Ã  : Œ¡⁄≈Ã  :œÀ-“‹ :“≈Ãœ. :ÍÌËÊÌ˚È   :        :        " skip "               :ÒÏÂÌ˚    :        :– :              :              :             :≈ :‚ÍÎ˛˜‡ˇ :        :‚ÍÎ˛˜‡ˇ :      : ÚÛ·Ó- : ÂÁÂ- : ‚ÒÂ„Ó  : ‚ÒÂ„Ó  :      :      :          :        :        " skip "               :         :        :  :              :              :             :« :  ‚Ó‰Û  :        :  ‚Ó‰Û  :      : ÔÓ‚Ó‰Â: ‚Û‡Â  :        :        :      :      :          :        :        " skip "               :    Î    :    Î   :  :      Î       :      Î       :      Î      :  :   ÒÏ   :   ÒÏ   :    Î   :   Î  :    Î   :    Î   :    Î   :   Í„   : Í„/Î :  C   :    Î     :    Î   :    Î   " skip "-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
      .
      view stream Prnlibstream frame TopFrameState-all-per .
    end.
  end case.
end.
for each ub.rvs-doc no-lock
  where ub.rvs-doc.obj-type   = p-obj-type
    and ub.rvs-doc.obj-code   = p-obj-code
    and ub.rvs-doc.shift-date >= x-date-Start
    and ub.rvs-doc.shift-date <= x-date-End
    and ub.rvs-doc.status_    = 'Ù‡ÍÚ':U
    and ub.rvs-doc.rvs-type   = 'ÒÏÂÌ‡':U
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
:
  if ub.rvs-doc.shift-date = x-date-Start and ub.rvs-doc.shift-num < x-Shift-Start then next .
  if ub.rvs-doc.shift-date = x-date-End   and ub.rvs-doc.shift-num > x-Shift-End then next .
  for each ub.rvs-line no-lock
    where ub.rvs-line.rvs-code = ub.rvs-doc.rvs-code
  on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  :
    find first temp-rvs-line
      where temp-rvs-line.pl-code  = ub.rvs-line.pl-code
        and temp-rvs-line.gds-code = ub.rvs-line.gds-code
      no-error .
    if not available temp-rvs-line then do:
      create temp-rvs-line .
      buffer-copy ub.rvs-line to temp-rvs-line .
      find first ub.goods no-lock
        where ub.goods.gds-code = ub.rvs-line.gds-code
        no-error.
      assign
        temp-rvs-line.gds-name   = ub.goods.gds-name
        temp-rvs-line.artic      = ub.goods.artic
        temp-rvs-line.prod-type  = ub.goods.prod-type
        temp-rvs-line.prod-code  = ub.goods.prod-code
        temp-rvs-line.shift-date = ub.rvs-doc.shift-date
        temp-rvs-line.shift-num  = ub.rvs-doc.shift-num
      .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  ub.goods.gds-code
  ,input  ?
  ,output temp-rvs-line.v-bar-code
  )  .
      find first ub.place no-lock
        where ub.place.obj-code = p-obj-code
          and ub.place.obj-type = p-obj-type
          and ub.place.pl-code  = ub.rvs-line.pl-code
        no-error.
      if available ub.place then do:
        assign
          temp-rvs-line.place_loc1 = ub.place.loc1
        .
      end.
    end.
    else do:
      if temp-rvs-line.shift-date < ub.rvs-doc.shift-date
        or ( temp-rvs-line.shift-date = ub.rvs-doc.shift-date
              and temp-rvs-line.shift-num  < ub.rvs-doc.shift-num
            )
      then do:
        buffer-copy ub.rvs-line to temp-rvs-line .
      end.
    end.
  end.
end.
if not p-report-id = "53/2040"
then do:
  display stream PrnLibstream
    with frame frame-1.
end.
for each temp-rvs-line
  break by temp-rvs-line.gds-code by temp-rvs-line.pl-code
on error undo, return error return-value
:
  if is-gas(temp-rvs-line.gds-code) then do:
      find first buf_rvs-line-attr where buf_rvs-line-attr.obj-code = temp-rvs-line.obj-code
                                   and buf_rvs-line-attr.obj-type = temp-rvs-line.obj-type
                                   and buf_rvs-line-attr.gds-code = temp-rvs-line.gds-code
                                   and buf_rvs-line-attr.pl-code = temp-rvs-line.pl-code
                                   and buf_rvs-line-attr.rvs-code = temp-rvs-line.rvs-code
                                   and buf_rvs-line-attr.attr-code = "mask" no-lock no-error.
      if not available previous-rvs-doc then do:
          find first buf_control-rvs-doc where buf_control-rvs-doc.obj-type = temp-rvs-line.obj-type
                                           and buf_control-rvs-doc.obj-code = temp-rvs-line.obj-code
                                           and buf_control-rvs-doc.shift-date = temp-rvs-line.shift-date
                                           and buf_control-rvs-doc.shift-num = temp-rvs-line.shift-num
                                           and buf_control-rvs-doc.status_ = 'Ù‡ÍÚ':U
                                           and buf_control-rvs-doc.rvs-type = 'ÍÓÌÚÓÎ¸':U no-lock no-error.
            i-rvs-code = buf_control-rvs-doc.rvs-code.
      end.
      else i-rvs-code = previous-rvs-doc.rvs-code.
      find first previous-rvs-line where previous-rvs-line.rvs-code = i-rvs-code
                                     and previous-rvs-line.gds-code = temp-rvs-line.gds-code
                                     and previous-rvs-line.obj-code = temp-rvs-line.obj-code
                                     and previous-rvs-line.obj-type = temp-rvs-line.obj-type
                                     and previous-rvs-line.pl-code = temp-rvs-line.pl-code no-lock no-error.
      find first buf_prev-rvs-line-attr where buf_prev-rvs-line-attr.obj-code = temp-rvs-line.obj-code
                                        and buf_prev-rvs-line-attr.obj-type = temp-rvs-line.obj-type
                                        and buf_prev-rvs-line-attr.gds-code = temp-rvs-line.gds-code
                                        and buf_prev-rvs-line-attr.pl-code = temp-rvs-line.pl-code
                                        and buf_prev-rvs-line-attr.rvs-code = i-rvs-code
                                        and buf_prev-rvs-line-attr.attr-code = "mask" no-lock no-error.
      if line-counter( PrnLibstream ) + 5 > page-size( PrnLibstream ) then do:
          page stream PrnLibstream .
      end.
      assign
      pol1 = "ÃÂÚ‡Ì ( œ√)"
      pol2 = previous-rvs-line.state-level-total  when avail previous-rvs-line
      pol5 = temp-rvs-line.state-level-petrol
      pol6 = previous-rvs-line.state-level-petrol when avail previous-rvs-line
      pol7 = pol5 - pol6
      pol9 = temp-rvs-line.state-level-total.
      display stream PrnLibstream
      sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12 sym13 sym14 sym15 sym16 sym17 sym18 sym19 sym20
      pol1
      pol2
      pol5
      pol6
      pol7
      pol9
      with frame frame-1.
      down stream PrnLibstream with frame frame-1.
      if Make-Excel then  put   stream ForExcel unformatted
          "ÃÂÚ‡Ì( œ√)Í„Ò/ÒÏ2" CHR(9)
          pol2 CHR(9)
          CHR(9)
          CHR(9)
          pol5 CHR(9)
          pol6 CHR(9)
          pol7 CHR(9)
          CHR(9)
          pol9 CHR(9)
          chr(10).
      assign
      pol1 = "CH4 Ï3"
      pol5 = 0
      pol6 = 0
      pol5 = integer(entry(1,buf_rvs-line-attr.attr-value, ";"))      when avail buf_rvs-line-attr
      pol6 = integer(entry(1,buf_prev-rvs-line-attr.attr-value, ";")) when avail buf_prev-rvs-line-attr
      pol7 = pol5 - pol6.
      display stream PrnLibstream
      sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12 sym13 sym14 sym15 sym16 sym17 sym18 sym19 sym20
      pol1
      pol5
      pol6
      pol7
      with frame frame-1.
      down stream PrnLibstream with frame frame-1.
      if Make-Excel then  put   stream ForExcel unformatted
          pol1 CHR(9)
          CHR(9)
          CHR(9)
          CHR(9)
          pol5 CHR(9)
          pol6 CHR(9)
          pol7 CHR(9)
          chr(10).
      assign
      pol1 = "P‚ı-CH4 Í„Ò/ÒÏ2"
      pol2 = 0
      pol15 = 0
      pol2 = integer(entry(2,buf_prev-rvs-line-attr.attr-value, ";")) when Avail buf_prev-rvs-line-attr
      pol15 = integer(entry(2,buf_rvs-line-attr.attr-value, ";"))     when Avail buf_rvs-line-attr .
      display stream PrnLibstream
      sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12 sym13 sym14 sym15 sym16 sym17 sym18 sym19 sym20
      pol1
      pol2
      pol15
      with frame frame-1.
      down stream PrnLibstream with frame frame-1.
      if Make-Excel then  put   stream ForExcel unformatted
          pol1 CHR(9)
          pol2 CHR(9)
          CHR(9)
          CHR(9)
          CHR(9)
          CHR(9)
          CHR(9)
          CHR(9)
          CHR(9)
          CHR(9)
          CHR(9)
          CHR(9)
          CHR(9)
          CHR(9)
          pol15 CHR(9)
          chr(10).
      assign
      pol1 = "T‚ı - CH4 ∞C"
      pol2 = 0
      pol15 = 0
      pol2 = integer(entry(3,buf_prev-rvs-line-attr.attr-value, ";")) when Avail buf_prev-rvs-line-attr
      pol15 = integer(entry(3,buf_rvs-line-attr.attr-value, ";"))     when Avail buf_rvs-line-attr.
      display stream PrnLibstream
      sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12 sym13 sym14 sym15 sym16 sym17 sym18 sym19 sym20
      pol1
      pol2
      pol15
      with frame frame-1.
      down stream PrnLibstream with frame frame-1.
      if Make-Excel then  put   stream ForExcel unformatted
          pol1 CHR(9)
          pol2 CHR(9)
          CHR(9)
          CHR(9)
          CHR(9)
          CHR(9)
          CHR(9)
          CHR(9)
          CHR(9)
          CHR(9)
          CHR(9)
          CHR(9)
          CHR(9)
          CHR(9)
          pol15 CHR(9)
          chr(10).
      underline stream PrnLibstream sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12 sym13 sym14 sym15 sym16 sym17 sym18 sym19 sym20 pol1 pol2 pol3 pol4 pol5 pol6 pol7 pol8 pol9 pol10 pol11 pol12 pol13 pol14 pol15 pol151 pol152 pol153 pol16 pol17 pol18 with frame frame-1.
      down stream PrnLibstream with frame frame-1.
      next.
  end.
  assign
    accum-by-pl-code-pol3-l = 0
    accum-by-pl-code-pol3-kg = 0
    accum-by-pl-code-pol7 = 0
  .
  if first-of(temp-rvs-line.gds-code) then do:
    assign
    accum-pol7    = 0
    accum-pol3-l  = 0
    accum-pol3-kg = 0
    v-bc-print    = false
    v-gds-print   = false
    last-gds-code = temp-rvs-line.v-bar-code
    .
    for each tt-pump-nozzle
    on error undo, return error return-value
    :
      delete tt-pump-nozzle.
    end.
    if p-tog-1-whole-gds = true then do:
      assign
        v-count   = 0
        v-tot-cnt = 0
      .
      for each buf_temp-rvs-line
        where buf_temp-rvs-line.gds-code = temp-rvs-line.gds-code
        break by buf_temp-rvs-line.pl-code
      on error undo, return error return-value
      :
        if first-of( buf_temp-rvs-line.pl-code ) then do:
          assign
            v-count2 = 2
          .
          for each buf_rvs-line-pump no-lock
            where buf_rvs-line-pump.rvs-code = buf_temp-rvs-line.rvs-code
              and buf_rvs-line-pump.obj-code = buf_temp-rvs-line.obj-code
              and buf_rvs-line-pump.obj-type = buf_temp-rvs-line.obj-type
              and buf_rvs-line-pump.pl-code  = buf_temp-rvs-line.pl-code
              and buf_rvs-line-pump.gds-code = buf_temp-rvs-line.gds-code
            break by buf_rvs-line-pump.pl-code
          on error undo, return error return-value
          :
            assign
              v-count2 = v-count2 + 1
            .
          end.
          if v-count = 0
            and v-count2 < 4
          then do:
            assign
              v-count2 = 4
            .
          end.
          assign
            v-count   = v-count + v-count2
            v-tot-cnt = v-tot-cnt + 1
          .
        end.
      end.
      if v-tot-cnt > 1 then do:
        assign
          v-count = v-count + 2
        .
      end.
      if line-counter( PrnLibstream ) - 1 + v-count > page-size( PrnLibstream ) then do:
        page stream PrnLibstream .
      end.
    end.
  end.
  if available previous-rvs-doc then do:
    find first previous-rvs-line  no-lock
      where previous-rvs-line.rvs-code = previous-rvs-doc.rvs-code
        and previous-rvs-line.gds-code = temp-rvs-line.gds-code
        and previous-rvs-line.obj-code = temp-rvs-line.obj-code
        and previous-rvs-line.obj-type = temp-rvs-line.obj-type
        and previous-rvs-line.pl-code  = temp-rvs-line.pl-code
      no-error .
  end.
  for each ub.rvs-line-pump no-lock
    where ub.rvs-line-pump.rvs-code = temp-rvs-line.rvs-code
      and ub.rvs-line-pump.gds-code = temp-rvs-line.gds-code
      and ub.rvs-line-pump.obj-code = temp-rvs-line.obj-code
      and ub.rvs-line-pump.obj-type = temp-rvs-line.obj-type
      and ub.rvs-line-pump.pl-code  = temp-rvs-line.pl-code
    break by ub.rvs-line-pump.pump-code
          by ub.rvs-line-pump.nozzle-code
  :
    if first-of(ub.rvs-line-pump.pump-code) then do:
      assign
        pol4    = 0
        pol5    = 0
        pol5-el = 0
        pol6    = 0
        pol6-el = 0
      .
    end.
    assign
      pol4    = ub.rvs-line-pump.pump-code
      pol5    = pol5    + ub.rvs-line-pump.state-mh-cnt
      pol5-el = pol5-el + ub.rvs-line-pump.state-el-cnt
    .
    if available previous-rvs-doc then do:
      Find FIRST previous-rvs-line-pump  No-LOCK WHERE
          previous-rvs-line-pump.rvs-code = previous-rvs-doc.rvs-code AND
          previous-rvs-line-pump.obj-code = temp-rvs-line.obj-code  and
          previous-rvs-line-pump.obj-type = temp-rvs-line.obj-type  and
          previous-rvs-line-pump.pl-code  = temp-rvs-line.pl-code AND
          previous-rvs-line-pump.pump-code = ub.rvs-line-pump.pump-code AND
          previous-rvs-line-pump.nozzle-code = ub.rvs-line-pump.nozzle-code No-ERROR.
      IF available previous-rvs-line-pump then do:
        assign
          pol6    = pol6    + previous-rvs-line-pump.state-mh-cnt
          pol6-el = pol6-el + previous-rvs-line-pump.state-el-cnt
        .
      end.
    end.
    if not available previous-rvs-doc
      or not available previous-rvs-line-pump
    then do:
      for each control-rvs-doc no-lock
        where control-rvs-doc.obj-type   = p-obj-type
          and control-rvs-doc.obj-code   = p-obj-code
          and control-rvs-doc.shift-date = x-date-start
          and control-rvs-doc.shift-num  = x-shift-alone
          and control-rvs-doc.status_    = 'Ù‡ÍÚ':U
          and control-rvs-doc.rvs-type   = 'ÍÓÌÚÓÎ¸':U
        ,first control-rvs-line-pump no-lock
        where control-rvs-line-pump.rvs-code = control-rvs-doc.rvs-code
          and control-rvs-line-pump.gds-code = temp-rvs-line.gds-code
          and control-rvs-line-pump.obj-code = temp-rvs-line.obj-code
          and control-rvs-line-pump.obj-type = temp-rvs-line.obj-type
          and control-rvs-line-pump.pl-code  = temp-rvs-line.pl-code
          and control-rvs-line-pump.pump-code = ub.rvs-line-pump.pump-code
          and control-rvs-line-pump.nozzle-code = ub.rvs-line-pump.nozzle-code
        by control-rvs-doc.fact-order
      :
        assign
          pol6    = pol6    + control-rvs-line-pump.state-mh-cnt
          pol6-el = pol6-el + control-rvs-line-pump.state-el-cnt
        .
        leave.
      end.
    end.
    if last-of(ub.rvs-line-pump.pump-code) then do:
      find first tt-pump-nozzle no-lock
        where tt-pump-nozzle.gds-code    = temp-rvs-line.gds-code
          and tt-pump-nozzle.pump-code   = ub.rvs-line-pump.pump-code
          and tt-pump-nozzle.nozzle-code = ub.rvs-line-pump.nozzle-code
        no-error .
      if available tt-pump-nozzle
        and p-tog-1-pump-one = true
      then do:
        assign
          pol5    = 0
          pol5-el = 0
          pol6    = 0
          pol6-el = 0
        .
      end.
      if v-gds-print = true then do:
        if v-bc-print = false then do:
          assign
            pol1       = substitute( "(ÍÓ‰ &1)", temp-rvs-line.v-bar-code )
            v-bc-print = true
          .
        end.
        else do:
          assign
            pol1 = ""
          .
        end.
      end.
      else do:
        assign
          pol1 = temp-rvs-line.gds-name
          v-gds-print = true
        .
      end.
      Assign
        pol2-l-state   =  0
        pol2-kg-state   =  0
        pol2-l-system   =  0
        pol2-kg-system   =  0
        pol3   =  0
        pol7   = ( if p-tog-1-out-pump-with-icnt = true then pol5-el - pol6-el else pol5 - pol6 )
        pol8   = temp-rvs-line.place_loc1
        pol9   = 0
        pol10  = 0
        pol11  = 0
        pol12  = 0
        pol13  = 0
        pol14  = 0
        pol15  = 0
        pol151 = 0
        pol152 = 0
        pol153 = 0
        pol16-l = 0
        pol16-kg = 0
        pol17  = 0
        pol18  = 0
      .
      if p-report-id  <> "53/2040" then do:
        if last(temp-rvs-line.gds-code) then do:
          run on-same-page in this-procedure (1 + 1) .
        end.
        display stream PrnLibstream
          sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12 sym13 sym14 sym15 sym16 sym17 sym18 sym19 sym20
          pol1
          pol4
          pol5 when pol5 >= 0
          pol6 when pol5 >= 0
          pol7 when pol5 >= 0
          pol8
          with frame frame-1
        .
        down stream PrnLibstream
          with frame frame-1.
        if pol5 >= 0 then do:
          if Make-Excel then  put   stream ForExcel unformatted
          pol1  CHR(9)
          CHR(9)
          CHR(9)
          pol4  CHR(9)
          pol5  CHR(9)
          pol6  CHR(9)
          pol7  CHR(9)
          pol8  chr(10)
          .
        end.
        else do:
          if Make-Excel then  put   stream ForExcel unformatted
          pol1  CHR(9)
          CHR(9)
          CHR(9)
          pol4  CHR(9)
          CHR(9)
          CHR(9)
          CHR(9)
          pol8  chr(10)
          .
        end.
      end.
      assign
        accum-by-pl-code-pol7 = accum-by-pl-code-pol7 + pol7
      .
      if not available tt-pump-nozzle then do:
        assign
        accum-pol7 = accum-pol7 + pol7
        .
        create tt-pump-nozzle.
        assign
          tt-pump-nozzle.gds-code    = temp-rvs-line.gds-code
          tt-pump-nozzle.pump-code   = ub.rvs-line-pump.pump-code
          tt-pump-nozzle.nozzle-code = ub.rvs-line-pump.nozzle-code
        .
      end.
    END.
  END.
  if v-gds-print = false then do:
    assign
      pol1        = temp-rvs-line.gds-name
      v-gds-print = true
    .
    if p-report-id  <> "53/2040" then do:
      if last(temp-rvs-line.gds-code) then do:
        run on-same-page in this-procedure (1 + 2) .
      end.
      display stream prnlibstream
        sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12 sym13 sym14 sym15 sym16 sym17 sym18 sym19 sym20
        pol1
        with frame frame-1 .
      down stream PrnLibstream  with frame frame-1.
      if Make-Excel then  put   stream ForExcel unformatted
      pol1
      CHR(9)
      CHR(9)
      CHR(9)
      CHR(9)
      CHR(9)
      CHR(9)
      CHR(9)
      chr(10)
      .
    end.
  end.
  if v-bc-print = false then do:
    assign
      pol1       = substitute( "(ÍÓ‰ &1)", temp-rvs-line.v-bar-code )
      v-bc-print = true
    .
    if p-report-id  <> "53/2040" then do:
      if v-gds-print = true then do:
        if last(temp-rvs-line.gds-code) then do:
          run on-same-page in this-procedure (1 + 1) .
        end.
      end.
      display stream PrnLibstream
        sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12 sym13 sym14 sym15 sym16 sym17 sym18 sym19 sym20
        pol1
        with frame frame-1 .
      down stream PrnLibstream  with frame frame-1.
      if Make-Excel then  put   stream ForExcel unformatted
      pol1
      CHR(9)
      CHR(9)
      CHR(9)
      CHR(9)
      CHR(9)
      CHR(9)
      CHR(9)
      chr(10)
      .
    end.
  end.
  if last-of(temp-rvs-line.pl-code ) then do:
    for each ub.trn-doc no-lock
      where ub.trn-doc.obj-type   = temp-rvs-line.obj-type
        and ub.trn-doc.obj-code   = temp-rvs-line.obj-code
        and ub.trn-doc.shift-date >= x-date-Start
        and ub.trn-doc.shift-date <= x-date-End
        and ub.trn-doc.status_    = 'Ù‡ÍÚ':U
        and ub.trn-doc.doc-type   = 'ÔË':U
    on error undo, return error return-value
    :
      if ub.trn-doc.shift-date = x-date-Start and ub.trn-doc.shift-num < x-Shift-Start then next .
      if ub.trn-doc.shift-date = x-date-End   and ub.trn-doc.shift-num > x-Shift-End then next .
      for each ub.doc-pl no-lock
        where ub.doc-pl.gds-code = temp-rvs-line.gds-code
          and ub.doc-pl.obj-code = temp-rvs-line.obj-code
          and ub.doc-pl.obj-type = temp-rvs-line.obj-type
          and ub.doc-pl.out-code = ub.trn-doc.doc-code
          and ub.doc-pl.pl-code  = temp-rvs-line.pl-code
      on error undo, return error return-value
      :
        assign
          accum-by-pl-code-pol3-l = accum-by-pl-code-pol3-l + ub.doc-pl.fact-qnty
          accum-by-pl-code-pol3-kg = accum-by-pl-code-pol3-kg + ub.doc-pl.cli-fact-qnty
        .
      end.
    end.
    assign
      pol2-l-state = 0
      pol2-kg-state = 0
      pol2-l-system = 0
      pol2-kg-system = 0
    .
    if available previous-rvs-line then do:
      assign
        pol2-l-state = previous-rvs-line.state-measure-qnty + previous-rvs-line.state-add-qnty
        pol2-kg-state = previous-rvs-line.state-measure-cli-qnty + previous-rvs-line.state-add-qnty * previous-rvs-line.state-density
        pol2-l-system = previous-rvs-line.system-qnty
        pol2-kg-system = previous-rvs-line.system-cli-qnty
      .
    end.
    Assign
      pol1   = "ÔÓ ÂÁÂ.":R15
      pol2   =  ( if p-weight = true
                  then (if p-param-shft-qty = "system":U then pol2-kg-system else pol2-kg-state)
                  else (if p-param-shft-qty = "system":U then pol2-l-system else pol2-l-state)
                )
      pol3   = (if p-weight = true then accum-by-pl-code-pol3-kg else accum-by-pl-code-pol3-l)
      pol4   = 0
      pol5   = 0
      pol6   = 0
      pol7   =  accum-by-pl-code-pol7
      pol8   =  temp-rvs-line.place_loc1
      pol9   =  temp-rvs-line.state-level-total
      pol10  =  temp-rvs-line.state-level-water
      pol11  =  temp-rvs-line.state-brutto-qnty
      pol12  =  temp-rvs-line.state-brutto-qnty - temp-rvs-line.state-measure-qnty
      pol13  =  temp-rvs-line.state-add-qnty
      pol14  =  temp-rvs-line.state-measure-qnty
      pol15  =  temp-rvs-line.state-measure-qnty + temp-rvs-line.state-add-qnty
      pol151 =  temp-rvs-line.state-measure-cli-qnty + temp-rvs-line.state-add-qnty * temp-rvs-line.state-density
      pol152 =  temp-rvs-line.state-density
      pol153 =  temp-rvs-line.state-temperature
      accum-pol3-l  = accum-pol3-l + accum-by-pl-code-pol3-l
      accum-pol3-kg = accum-pol3-kg + accum-by-pl-code-pol3-kg
    .
    find first last-rvs-line no-lock
      where last-rvs-line.rvs-code = last-rvs-doc.rvs-code
        and last-rvs-line.gds-code = temp-rvs-line.gds-code
        and last-rvs-line.obj-code = temp-rvs-line.obj-code
        and last-rvs-line.obj-type = temp-rvs-line.obj-type
        and last-rvs-line.pl-code  = temp-rvs-line.pl-code
      no-error .
    if available last-rvs-line
      and ( p-param-shft-qty = "system":U
            or p-param-shft-qty = "state-all-per":U
          )
    then do:
      assign
        pol16-l  = last-rvs-line.system-qnty
        pol16-kg = last-rvs-line.system-cli-qnty
      .
    end.
    else do:
      if p-param-shft-qty = "state":U then do:
        assign
          pol16-l  = pol2-l-state
          pol16-kg = pol2-kg-state
        .
      end.
      else do:
        assign
          pol16-l  = pol2-l-system
          pol16-kg = pol2-kg-system
        .
      end.
      for each ub.trn-doc no-lock
        where ub.trn-doc.obj-type   = temp-rvs-line.obj-type
          and ub.trn-doc.obj-code   = temp-rvs-line.obj-code
          and ub.trn-doc.shift-date >= x-date-Start
          and ub.trn-doc.shift-date <= x-date-End
          and ub.trn-doc.status_    = 'Ù‡ÍÚ':U
      on error undo, return error return-value
      :
        if ub.trn-doc.shift-date = x-date-Start and ub.trn-doc.shift-num < x-Shift-Start then next .
        if ub.trn-doc.shift-date = x-date-End   and ub.trn-doc.shift-num > x-Shift-End then next .
        for each ub.doc-pl no-lock
          where ub.doc-pl.gds-code = temp-rvs-line.gds-code
            and ub.doc-pl.obj-code = temp-rvs-line.obj-code
            and ub.doc-pl.obj-type = temp-rvs-line.obj-type
            and ub.doc-pl.out-code = ub.trn-doc.doc-code
            and ub.doc-pl.pl-code  = temp-rvs-line.pl-code
        on error undo, return error return-value
        :
          if lookup( ub.trn-doc.ext-doc-type, 'ee,ep,es,we,ev,em,wm,eo':U ) > 0 then do:
            assign
              v-sign = -1.0
            .
          end.
          else do:
            assign
              v-sign = 1.0
            .
            if lookup( ub.trn-doc.ext-doc-type, 'ie,re,rs,vt,vp,ap,mp,pc,iv,rv,im,io':U ) = 0 then do:
              undo, return error substitute( '&1. “ËÔ "&2" ÌÂ ‚ÌÂÒÂÌ ‚ ÒÔËÒÍË ‰ÓÍÛÏÂÌÚÓ‚ ÛÏÂÌ¸¯‡˛˘Ëı(Û‚ÂÎË˜Ë‚‡˛˘Ëı) ÓÒÚ‡ÚÍË!', vss-workfile, ub.trn-doc.ext-doc-type).
            end.
          end.
          if ( p-param-shft-qty = "state":U
              and ub.trn-doc.doc-type <> 'ËÌ‚':U
            )
            or p-param-shft-qty = "system":U
            or p-param-shft-qty = "state-all-per":U
          then do:
            assign
              pol16-l = pol16-l + ub.doc-pl.fact-qnty * v-sign
              pol16-kg = pol16-kg + ub.doc-pl.cli-fact-qnty * v-sign
            .
          end.
        end.
      end.
    end.
    define variable is-vir as logical no-undo.
    define variable v-value as character no-undo.
    define variable v-ok as logical no-undo.
    run placelib_get-attr(input "place-virtual"
                         ,input temp-rvs-line.obj-code
                         ,input temp-rvs-line.obj-type
                         ,input temp-rvs-line.pl-code
                         ,output v-value
                         ,output v-ok) no-error.
    is-vir = if (v-ok and logical(v-value)) then true else false.
    if is-vir then do:
        pol2 = if p-weight then pol2-kg-system else pol2-l-system.
        pol2-kg-state = pol2-kg-system.
        pol2-l-state = pol2-l-system.
        if available last-rvs-line then do:
            pol16-l = last-rvs-line.system-qnty.
            pol16-kg = last-rvs-line.system-cli-qnty.
        end.
    end.
    if p-weight = false then do:
      assign
        pol17 = ( if ( pol15 - pol16-l ) >  0 then ( pol15 - pol16-l ) else 0 )
        pol18 = ( if ( pol15 - pol16-l ) <= 0 then ( pol16-l - pol15 ) else 0 )
      .
    end.
    else do:
      assign
        pol17 = ( if ( pol151 - pol16-kg ) >  0 then ( pol151 - pol16-kg ) else 0 )
        pol18 = ( if ( pol151 - pol16-kg ) <= 0 then ( pol16-kg - pol151 ) else 0 )
      .
    end.
    if last(temp-rvs-line.gds-code) then do:
    run on-same-page in this-procedure
      ( input 1 + 1
      ).
    end.
    if p-report-id  <> "53/2040" then do:
      display stream PrnLibstream
        sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12 sym13 sym14 sym15 sym16 sym17 sym18 sym19 sym20
        pol1
        pol2
        pol3
        pol7
        pol8
        pol9
        pol10
        pol11
        pol12
        pol13
        pol14
        pol15
        pol151
        pol152
        pol153
        (if p-weight then pol16-kg else pol16-l) @ pol16
        pol17 when pol17 > 0
        pol18 when pol18 > 0
        with frame frame-1
      .
      down stream PrnLibstream with frame frame-1.
      underline stream PrnLibstream
        sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12 sym13 sym14 sym15 sym16 sym17 sym18 sym19 sym20
        pol1 pol2 pol3 pol4 pol5 pol6 pol7 pol8 pol9 pol10 pol11 pol12 pol13 pol14 pol15 pol151 pol152 pol153 pol16 pol17 pol18
        with frame frame-1
      .
      down stream PrnLibstream with frame frame-1.
      if Make-Excel then  put   stream ForExcel unformatted
        pol1  CHR(9)
        pol2  CHR(9)
        pol3  CHR(9)
              CHR(9)
              CHR(9)
              CHR(9)
        pol7  CHR(9)
        pol8  CHR(9)
        pol9  CHR(9)
        pol10 CHR(9)
        pol11 CHR(9)
        pol12 CHR(9)
        pol13 CHR(9)
        pol14 CHR(9)
        pol15 CHR(9)
        pol151 CHR(9)
        pol152 CHR(9)
        pol153 CHR(9)
        (if p-weight then pol16-kg else pol16-l) CHR(9)
        pol17 CHR(9)
        pol18 chr(10)
      .
    end.
    accumulate pol2-l-state  (Total by temp-rvs-line.gds-code).
    accumulate pol2-kg-state  (Total by temp-rvs-line.gds-code).
    accumulate pol2-l-system  (Total by temp-rvs-line.gds-code).
    accumulate pol2-kg-system  (Total by temp-rvs-line.gds-code).
    accumulate pol2  (count by temp-rvs-line.gds-code).
    accumulate pol3  (Total  by temp-rvs-line.gds-code).
    accumulate pol13 (Total  by temp-rvs-line.gds-code).
    accumulate pol14 (Total  by temp-rvs-line.gds-code).
    accumulate pol15 (Total  by temp-rvs-line.gds-code).
    accumulate pol151 (Total  by temp-rvs-line.gds-code).
    accumulate pol16-l (Total  by temp-rvs-line.gds-code).
    accumulate pol16-kg (Total  by temp-rvs-line.gds-code).
    accumulate pol17 (Total  by temp-rvs-line.gds-code).
    accumulate pol18 (Total  by temp-rvs-line.gds-code).
  End.
  if last-of(temp-rvs-line.gds-code) then do:
    for each tt-pump-nozzle
    on error undo, return error return-value
    :
      delete tt-pump-nozzle.
    end.
    if (ACCUM COUNT BY  temp-rvs-line.gds-code pol2) > 1 then DO:
      Assign
        pol1     = "¬—≈√Œ":R15
        pol2     = (if p-weight = true
                    then (if p-param-shft-qty = "system":U
                          then ACCUM TOTAL BY temp-rvs-line.gds-code pol2-kg-system
                          else ACCUM TOTAL BY temp-rvs-line.gds-code pol2-kg-state)
                    else (if p-param-shft-qty = "system":U
                          then ACCUM TOTAL BY temp-rvs-line.gds-code pol2-l-system
                          else ACCUM TOTAL BY temp-rvs-line.gds-code pol2-l-state)
                   )
        pol3     = ACCUM TOTAL BY  temp-rvs-line.gds-code pol3
        pol4     = 0
        pol5     = 0
        pol6     = 0
        pol7     = ACCUM-pol7
        pol8     = "":U
        pol9     = 0
        pol10    = 0
        pol11    = 0
        pol12    = 0
        pol13    = ACCUM TOTAL BY  temp-rvs-line.gds-code pol13
        pol14    = ACCUM TOTAL BY  temp-rvs-line.gds-code pol14
        pol15    = ACCUM TOTAL BY  temp-rvs-line.gds-code pol15
        pol151   = ACCUM TOTAL BY  temp-rvs-line.gds-code pol151
        pol16-l  = ACCUM TOTAL BY  temp-rvs-line.gds-code pol16-l
        pol16-kg = ACCUM TOTAL BY  temp-rvs-line.gds-code pol16-kg
        pol16    = (if p-weight then pol16-kg else pol16-l)
        pol17    = ACCUM TOTAL BY  temp-rvs-line.gds-code pol17
        pol18    = ACCUM TOTAL BY  temp-rvs-line.gds-code pol18
      .
      if last(temp-rvs-line.gds-code) then do:
        run on-same-page in this-procedure
          ( input 1 + 1
          ).
      end.
      if p-report-id  <> "53/2040" then do:
        display stream PrnLibstream
          sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12 sym13 sym14 sym15 sym16 sym17 sym18 sym19 sym20
          pol1
          pol2
          pol3
          pol7
          pol13
          pol14
          pol15
          pol151
          pol16
          pol17  when pol17 <> 0
          pol18 when pol18 <> 0
          with frame frame-1.
        down stream PrnLibstream with frame frame-1.
        underline stream PrnLibstream
          sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12 sym13 sym14 sym15 sym16 sym17 sym18 sym19 sym20
          pol1 pol2 pol3 pol4 pol5 pol6 pol7 pol8 pol9 pol10 pol11 pol12 pol13 pol14 pol15 pol151 pol152 pol153 pol16 pol17 pol18
          with frame frame-1.
        down stream PrnLibstream with frame frame-1.
        if Make-Excel then  put   stream ForExcel unformatted
        pol1  CHR(9)
        pol2  CHR(9)
        pol3  CHR(9)
        CHR(9)
        CHR(9)
        CHR(9)
        pol7  CHR(9)
        CHR(9)
        CHR(9)
        CHR(9)
        CHR(9)
        CHR(9)
        pol13  CHR(9)
        pol14  CHR(9)
        pol15  CHR(9)
        pol151 CHR(9)
        CHR(9)
        CHR(9)
        pol16  CHR(9)
        pol17  CHR(9)
        pol18  chr(10)
        .
      end.
    end.
    if p-batch > 0
    and p-report-id  = "53/2040"
    then do:
      find first buf_shift-pgds
        where buf_shift-pgds.obj-type = p-obj-type
          and buf_shift-pgds.obj-code = p-obj-code
          and buf_shift-pgds.shift-date = X-date-end
          and buf_shift-pgds.shift-num = X-shift-end
          and buf_shift-pgds.gds-code = temp-rvs-line.gds-code
        no-error.
      if not available buf_shift-pgds then do:
        create buf_shift-pgds.
        assign
          buf_shift-pgds.obj-type = p-obj-type
          buf_shift-pgds.obj-code = p-obj-code
          buf_shift-pgds.shift-date = X-date-end
          buf_shift-pgds.shift-num = X-shift-end
          buf_shift-pgds.gds-code = temp-rvs-line.gds-code
          buf_shift-pgds.gds-name = temp-rvs-line.gds-name
          buf_shift-pgds.start-state-qnty =  ACCUM TOTAL BY  temp-rvs-line.gds-code pol2-l-state
          buf_shift-pgds.start-system-qnty = ACCUM TOTAL BY  temp-rvs-line.gds-code pol2-l-system
          buf_shift-pgds.start-state-qnty-2 =  ACCUM TOTAL BY  temp-rvs-line.gds-code pol2-kg-state
          buf_shift-pgds.start-system-qnty-2 = ACCUM TOTAL BY  temp-rvs-line.gds-code pol2-kg-system
          buf_shift-pgds.end-state-qnty = ACCUM TOTAL BY  temp-rvs-line.gds-code pol15
          buf_shift-pgds.end-system-qnty =  ACCUM TOTAL BY  temp-rvs-line.gds-code pol16-l
          buf_shift-pgds.end-state-qnty-2 = ACCUM TOTAL BY  temp-rvs-line.gds-code pol151
          buf_shift-pgds.end-system-qnty-2 = ACCUM TOTAL BY  temp-rvs-line.gds-code pol16-kg
          buf_shift-pgds.in-qnty = accum-pol3-l
          buf_shift-pgds.in-qnty-2 = accum-pol3-kg
          buf_shift-pgds.icnt-out-qnty = ACCUM-pol7
          buf_shift-pgds.end-price-sale = ?
        .
        release buf_shift-pgds.
      end.
    end.
  end.
end.
