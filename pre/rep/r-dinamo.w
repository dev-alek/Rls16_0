define input parameter parparentproc as widget-handle no-undo .
define input parameter p-gds-code like ub.goods.gds-code no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Динамика движения товара-форма".
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
DEF VAR BLACK_COLOR        AS INTEGER NO-UNDO INIT  0.
DEF VAR DARK_BLUE_COLOR    AS INTEGER NO-UNDO INIT  1.
DEF VAR DARK_GREEN_COLOR   AS INTEGER NO-UNDO INIT  2.
DEF VAR CYAN_COLOR         AS INTEGER NO-UNDO INIT  3.
DEF VAR BROWN_COLOR        AS INTEGER NO-UNDO INIT  4.
DEF VAR DARK_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR DARK_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR GRAY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR GREY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR BLUE_COLOR         AS INTEGER NO-UNDO INIT  9.
DEF VAR GREEN_COLOR        AS INTEGER NO-UNDO INIT 10.
DEF VAR RED_COLOR          AS INTEGER NO-UNDO INIT 12.
DEF VAR LIGHT_RED_COLOR    AS INTEGER NO-UNDO INIT 13.
DEF VAR YELLOW_COLOR       AS INTEGER NO-UNDO INIT 14.
DEF VAR WHITE_COLOR        AS INTEGER NO-UNDO INIT 15.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define new shared variable RepPathName        as character no-undo .
define new shared variable PrintRubl          as logical   no-undo .
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define NEW SHARED temp-table t-month0 no-undo
field month_ as integer
field year_ as integer
field ym as integer
field obj-type like ub.clients.obj-type
field obj-code like ub.clients.obj-code
index pi is unique primary
ym
.
define NEW SHARED temp-table t-dinamo no-undo
field month_ as integer
field year_ as integer
field ym as integer
field idoc-type as integer
field sign_ as integer
field doc-type like ub.trn-doc.doc-type
field ext-doc-type like ub.ot-line.ext-doc-type
field doc-type-full as character format "X(18)"
field ext-doc-type-full as character format "X(18)"
field fact-qnty like ub.stk-line.fact-qnty
field sale-sum-rubl like ub.stk-line.sum-rubl
field sale-sum-base like ub.stk-line.sum-base
field cost-sum-rubl like ub.stk-line.sum-rubl
field cost-sum-base like ub.stk-line.sum-base
field doc-sum-rubl like ub.stk-line.sum-rubl
field doc-sum-base like ub.stk-line.sum-base
field is-zuka as logical
index pi is unique primary
ym
idoc-type
ext-doc-type
index iext-doc-type
ym
ext-doc-type
sign_
index izuka
ym
ext-doc-type
.
define NEW SHARED temp-table t-stk-obj no-undo
field month_ as integer
field year_ as integer
field ym as integer
field b-a as integer
field b-a-full as character
field fact-qnty like ub.stk-line.fact-qnty
field sale-sum-rubl like ub.stk-line.sum-rubl
field sale-sum-base like ub.stk-line.sum-base
field cost-sum-rubl like ub.stk-line.sum-rubl
field cost-sum-base like ub.stk-line.sum-base
field obj-type like ub.clients.obj-type
field obj-code like ub.clients.obj-code
index pi is unique primary
ym
b-a
obj-type
obj-code
index iobj
obj-type
obj-code
ym descending
b-a descending
.
define NEW SHARED temp-table t-stk no-undo
field month_ as integer
field year_ as integer
field ym as integer
field b-a as integer
field b-a-full as character
field fact-qnty like ub.stk-line.fact-qnty
field sale-sum-rubl like ub.stk-line.sum-rubl
field sale-sum-base like ub.stk-line.sum-base
field cost-sum-rubl like ub.stk-line.sum-rubl
field cost-sum-base like ub.stk-line.sum-base
index pi is unique primary
ym
b-a
.
define NEW SHARED temp-table t-fo0 no-undo
field obj-type like ub.clients.obj-type
field obj-code like ub.clients.obj-code
field fact-order like ub.stk-line.fact-order
field cfact-date as date
field ym as integer
index pi is unique primary
obj-type
obj-code
fact-order
.
FUNCTION get-doc-type RETURNS CHARACTER
  ( input p-ii as integer, input-output p-ext-doc-type as character, input-output p-sign as character, output p-ext-doc-type-full as character, output p-doc-type-full as character, output p-idoc-type as character ) :
DEFINE VARIABLE v-doc-type as character no-undo .
assign
p-ext-doc-type-full = entry(p-ii, 'приход внешний,расход внешний,возврат пост.,касса продажа,возврат внешний,касса возврат,списание,инвентаризация,пересортица,приход внутренний,расход внутренний,возврат внутренний,расход  произв.,списан. произв.,приход  произв.,переоценка,коррекция учетных цен,корректировка отрицательных партий,смена типа приобретения,приход внутриобъектный,расход внутриобъектный':U)
.
  CASE p-ext-doc-type:
    when 'ie':U
 or when 'iv':U
 or when 'im':U
 then do:
      assign
      v-doc-type = 'при':U
      p-doc-type-full = "Приход"
      p-idoc-type = string(1)
      p-sign = string(0)
      .
    end.
    when 'ee':U
 or when 'es':U
 or when 'we':U
 or when 'ep':U
 or when 'ev':U
 or when 'wm':U then do:
      assign
      v-doc-type = 'рас':U
      p-doc-type-full = "Расход"
      p-idoc-type  = string(2)
      p-sign = string(0)
      .
    end.
    when 're':U
 or when 'rs':U
 or when 'rv':U then do:
      assign
      v-doc-type = 'возврат':U
      p-doc-type-full = "Возврат"
      p-idoc-type = string(3)
      p-sign = string(0)
      .
    end.
    when 'ap':U then do:
      assign
      v-doc-type = 'ap':U
      p-doc-type-full = "Переоц.уч.цен"
      p-idoc-type = string(6)
      p-sign = string(0)
      .
    end.
    when 'pc':U then do:
      assign
      v-doc-type = 'pc':U
      p-doc-type-full = "Смена типа приобр."
      p-idoc-type = string( 5)
      p-sign = string(0)
      .
    end.
    when 'ot':U then do:
      assign
      v-doc-type = 'ot':U
      p-doc-type-full = "Переоценка"
      p-idoc-type = string(4)
      p-sign = string(0)
     .
    end.
    when 'vt':U      or
    when 'vp':U then do:
      CASE p-sign:
        when string(0) then do:
          assign
          p-ext-doc-type = p-ext-doc-type + chr(44) + p-ext-doc-type
          v-doc-type = 'рас':U + chr(44) + 'при':U
          p-doc-type-full = "Расход" + chr(44) + "Приход"
          p-ext-doc-type-full = p-ext-doc-type-full + "(-)":U + chr(44) + p-ext-doc-type-full + "(+)":U
          p-idoc-type = string(2) + chr(44) + string(1)
          p-sign = string(-1) + chr(44) + string( 1)
          .
        end.
        when string(- 1) then do:
          assign
          v-doc-type = 'рас':U
          p-doc-type-full = "Расход"
          p-ext-doc-type-full = p-ext-doc-type-full + "(-)":U
          p-idoc-type = string(2)
          p-sign = string( - 1)
          .
        end.
        when string(1) then do:
          assign
          v-doc-type = 'при':U
          p-doc-type-full = "Приход"
          p-ext-doc-type-full = p-ext-doc-type-full + "(+)":U
          p-idoc-type =  string(1)
          p-sign = string(1)
          .
        end.
      END CASE.
    end.
    when 'em':U then do:
      assign
      v-doc-type = "":U
      p-doc-type-full = ""
      p-idoc-type = string( 0)
      p-sign = string(0)
      .
    end.
  END CASE.
  RETURN v-doc-type.
END FUNCTION.
procedure proc-view-objects :
DEFINE VARIABLE v-attr-codes as character no-undo .
DEFINE VARIABLE v-attr-labels as character no-undo .
DEFINE VARIABLE v-output as character no-undo .
  do
  on error undo, return error
  :
    for each obj-list no-lock,
        first t-fo0 no-lock where
             t-fo0.obj-type = obj-list.obj-type
         AND t-fo0.obj-code = obj-list.obj-code
        :
      assign
      v-attr-codes = v-attr-codes + obj-list.obj-type + string(obj-list.obj-code) + chr(44)
      v-attr-labels = v-attr-labels + obj-list.obj-type + string(obj-list.obj-code) + fill( chr(32), 5) +
                      "Данные c" + chr(32) + string(t-fo0.cfact-date, "99/99/9999") + chr(44)
      .
    end.
    assign
    v-attr-codes = right-trim(v-attr-codes, chr(44))
    v-attr-labels = right-trim(v-attr-labels, chr(44))
    .
    run gbl/d-list.w (
                  input "":U
                 ,input "Объекты, выбранные для показа динамики товара"
                 ,input v-attr-codes
                 ,input v-attr-labels
                 ,input chr(44)
                 ,input "":U
                 ,output v-output).
  end.
end procedure.
procedure proc-print-oborot :
define input parameter p-artic like ub.goods.artic no-undo .
define input parameter p-prod-type like ub.goods.prod-type no-undo .
define input parameter p-prod-code like ub.goods.prod-code no-undo .
define input parameter p-date-start as date no-undo .
define input parameter p-date-end as date no-undo .
DEFINE VARIABLE v-attr-codes as character no-undo .
DEFINE VARIABLE v-attr-labels as character no-undo .
DEFINE VARIABLE v-output as character no-undo .
DEFINE VARIABLE v-obj-type like ub.clients.obj-type no-undo .
DEFINE VARIABLE v-obj-code like ub.clients.obj-code no-undo .
  do
  on error undo, return error
  :
    for each obj-list no-lock:
      assign
      v-attr-codes = v-attr-codes + obj-list.obj-type + string(obj-list.obj-code) + chr(44).
    end.
    assign
    v-attr-codes = right-trim(v-attr-codes, chr(44))
    .
    if num-entries(v-attr-codes) <> 1 then do:
      run gbl/d-list.w (
                    input "b-sel":U
                  ,input "Выберите объект для печати оборотной ведомости"
                  ,input v-attr-codes
                  ,input v-attr-codes
                  ,input chr(44)
                  ,input "":U
                  ,output v-output).
      if v-output = "":U then return.
      assign
      v-obj-type = substr(v-output, 1, 3)
      v-obj-code = integer(substr(v-output, 4))
      .
    end.
    else do:
      assign
      v-obj-type = substr(v-attr-codes, 1, 3)
      v-obj-code = integer(substr(v-attr-codes, 4))
      .
    end.
    run rep/e-good2.w (parParentProc,
                  p-artic,
                  p-prod-type,
                  p-prod-code,
                  p-date-start,
                  p-date-end,
                  v-obj-type,
                  v-obj-code
                    ) no-error.
  end.
end procedure.
procedure proc-print-crd :
define input parameter p-artic like ub.goods.artic no-undo .
define input parameter p-prod-type like ub.goods.prod-type no-undo .
define input parameter p-prod-code like ub.goods.prod-code no-undo .
define input parameter p-date-start as date no-undo .
define input parameter p-date-end as date no-undo .
DEFINE VARIABLE v-attr-codes as character no-undo .
DEFINE VARIABLE v-attr-labels as character no-undo .
DEFINE VARIABLE v-output as character no-undo .
DEFINE VARIABLE v-obj-type like ub.clients.obj-type no-undo .
DEFINE VARIABLE v-obj-code like ub.clients.obj-code no-undo .
  do
  on error undo, return error
  :
    for each obj-list no-lock:
      assign
      v-attr-codes = v-attr-codes + obj-list.obj-type + string(obj-list.obj-code) + chr(44).
    end.
    assign
    v-attr-codes = right-trim(v-attr-codes, chr(44))
    .
    if num-entries(v-attr-codes) <> 1 then do:
      run gbl/d-list.w (
                   input "b-sel":U
                  ,input "Выберите объект для печати карточки товара"
                  ,input v-attr-codes
                  ,input v-attr-codes
                  ,input chr(44)
                  ,input "":U
                  ,output v-output).
      if v-output = "":U then return.
      assign
      v-obj-type = substr(v-output, 1, 3)
      v-obj-code = integer(substr(v-output, 4))
      .
    end.
    else do:
      assign
      v-obj-type = substr(v-attr-codes, 1, 3)
      v-obj-code = integer(substr(v-attr-codes, 4))
      .
    end.
    run rep/g-gdscrd.p (parParentProc,
                  p-artic,
                  p-prod-type,
                  p-prod-code,
                  p-date-start,
                  p-date-end,
                  v-obj-type,
                  v-obj-code
                    ) no-error.
  end.
end procedure.
def var vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure clntattr-code :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-code in g#attr-lib
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
procedure clntattr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-tooltip in g#attr-lib
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
procedure clntattr-value :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-value    like ub.clients-attr.attr-value no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-value in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
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
procedure clntattr-write :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define input  parameter p-value    like ub.clients-attr.attr-value no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-write in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,input  p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-exist :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-exist in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-delete :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-delete in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-copy-to :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define input  parameter p-bh       as handle no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-copy-to in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,input  p-bh
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-archive-attr :
  define output parameter p-archive-attr-list as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-archive-attr in g#attr-lib
      (output  p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-auto-author-attr :
  define output parameter p-archive-attr-list as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-auto-author-attr in g#attr-lib
      (output  p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-archive-by-type :
  define input  parameter p-archive-type      as character no-undo .
  define output parameter p-archive-attr-list as character no-undo .
  define variable vss-description as character no-undo initial "clntattr-get-archive-by-type-01: возвращает список атрибутов для складского архива".
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-archive-by-type in g#attr-lib
      (input  p-archive-type
      ,output p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-vat-register :
  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-vat-register in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-requisite-alc-decl :
  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-requisite-alc-decl in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-manual-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
FUNCTION Last-Day RETURNS INTEGER ( INPUT i-date AS DATE ) :
  DEFINE VARIABLE t_date AS DATE NO-UNDO.
  ASSIGN t_date = DATE( MONTH( i-date ), 28, YEAR( i-date ) ).
  RETURN ( DAY( t_date - DAY( t_date + 4 ) + 4 ) ).
END FUNCTION.
DEFINE NEW SHARED var br-handle as handle no-undo.
define buffer buf_goods for ub.goods.
define new shared buffer t-month  for t-month0.
define new shared buffer t-fo  for t-fo0.
DEFINE VARIABLE v-enable-cost as logical no-undo init yes.
DEFINE VARIABLE v-cost-obj as logical no-undo .
DEFINE VARIABLE v-cost-view as logical no-undo .
DEFINE VARIABLE v-cut-ym as integer no-undo .
define variable v-row as integer no-undo.
define variable v-MontYear_List as character no-undo.
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-objects
     LABEL "&Объекты?"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-print
     LABEL "Пе&чать"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-uchet
     LABEL "&Уч. карт"
     SIZE 10 BY 1.
DEFINE VARIABLE f-date-start AS DATE FORMAT "99/99/9999":U
     LABEL "Данные по совокупности объектов с"
      VIEW-AS TEXT
     SIZE 14 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE F-unit-base AS CHARACTER FORMAT "X(3)":U
      VIEW-AS TEXT
     SIZE 7.38 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE RS-curr AS CHARACTER INITIAL "rubl"
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Баз.вал.", "base",
"abbr_rubli_firstshift", "rubl"
     SIZE 10.75 BY 1.92 NO-UNDO.
DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 12.63 BY 3.5.
DEFINE VARIABLE T-cost AS LOGICAL INITIAL no
     LABEL "Учетные цены"
     VIEW-AS TOGGLE-BOX
     SIZE 23.75 BY .88 NO-UNDO.
DEFINE QUERY BR-dinamo FOR
      t-dinamo SCROLLING.
DEFINE QUERY BR-month FOR
      t-month SCROLLING.
DEFINE QUERY BR-stk FOR
      t-stk SCROLLING.
DEFINE BROWSE BR-dinamo
  QUERY BR-dinamo DISPLAY
      t-dinamo.doc-type-full
FORMAT "X(18)"
column-label "":U
(if t-dinamo.ext-doc-type <> "":U and not t-dinamo.is-zuka
 then string(t-dinamo.fact-qnty, "->>,>>>,>>9.999")
 else "":U)
 column-label "Кол-во" format "X(15)"
(if t-dinamo.ext-doc-type <> "":U
then string((if RS-curr = "rubl":U then t-dinamo.sale-sum-rubl else t-dinamo.sale-sum-base),
            (if t-dinamo.is-zuka
             then "->>,>>9.99%"
             else "->>,>>>,>>>,>>>,>>9.99")
            )
else "":U)
COLUMn-LABEL "Сумма продаж. цен" format "X(22)"
(if t-dinamo.ext-doc-type <> "":U and v-cost-view
then string((if RS-curr = "rubl":U then t-dinamo.cost-sum-rubl else t-dinamo.cost-sum-base), "->>,>>>,>>>,>>>,>>9.99")
else "":U)
COLUMn-LABEL "Сумма учетных цен" format "X(22)"
    WITH NO-ROW-MARKERS NO-COLUMN-SCROLLING SEPARATORS SIZE 82 BY 14.5
         TITLE "Обороты".
DEFINE BROWSE BR-month
  QUERY BR-month DISPLAY
      t-month.month_ column-label "М" format "99":U
t-month.year_ column-label "Г" format "9999":U
    WITH NO-ROW-MARKERS SEPARATORS SIZE 9.5 BY 12.
DEFINE BROWSE BR-stk
  QUERY BR-stk DISPLAY
      t-stk.b-a-full
column-label "":U
FORMAT "X(18)"
string(t-stk.fact-qnty, "->>,>>>,>>9.999")
column-label "Кол-во" format "X(15)"
string((if RS-curr = "rubl":U then t-stk.sale-sum-rubl else t-stk.sale-sum-base), "->>,>>>,>>>,>>>,>>9.99")
column-label "Сумма продаж. цен" format "X(22)"
(if v-cost-view then
string((if RS-curr = "rubl":U then t-stk.cost-sum-rubl else t-stk.cost-sum-base), "->>,>>>,>>>,>>>,>>9.99")
else "":U)
column-label "Сумма учетных цен" format "X(22)"
    WITH NO-ROW-MARKERS NO-COLUMN-SCROLLING SEPARATORS SIZE 82 BY 5.13
         TITLE "Остатки".
DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     T-cost AT ROW 1 COL 64.63
     B-Help AT ROW 1 COL 89
     BR-dinamo AT ROW 2 COL 17
     RS-curr AT ROW 3.96 COL 2.5 NO-LABEL
     BR-month AT ROW 6.5 COL 1
     BR-stk AT ROW 16.75 COL 17
     B-uchet AT ROW 18.5 COL 1
     B-objects AT ROW 19.5 COL 1
     B-print AT ROW 20.5 COL 1
     f-date-start AT ROW 1.08 COL 46.88 COLON-ALIGNED
     F-unit-base AT ROW 3 COL 3.25 NO-LABEL
     RECT-2 AT ROW 2.71 COL 1.5
     SPACE(85.12) SKIP(15.82)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Динамика движения товара"
         CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-objects IN FRAME Dialog-Frame
DO:
  run proc-view-objects in this-procedure.
END.
ON CHOOSE OF B-print IN FRAME Dialog-Frame
DO:
  run proc-b-print in this-procedure(t-month.year_, t-month.month_).
END.
ON CHOOSE OF B-uchet IN FRAME Dialog-Frame
DO:
  if not avail t-month then return no-apply.
  run proc-uchet-card in this-procedure no-error.
  if error-status:error then return no-apply.
END.
ON LEFT-MOUSE-DBLCLICK OF BR-dinamo IN FRAME Dialog-Frame
DO:
if not avail t-dinamo then return no-apply.
  run proc-c-dinamo in this-procedure no-error.
  if error-status:error then return no-apply.
END.
ON RETURN OF BR-dinamo IN FRAME Dialog-Frame
DO:
  if not avail t-dinamo then return no-apply.
  run proc-c-dinamo in this-procedure no-error.
  if error-status:error then return no-apply.
END.
ON VALUE-CHANGED OF BR-dinamo IN FRAME Dialog-Frame
DO:
  if available t-dinamo then do:
    assign
    v-row = br-dinamo:focused-row in frame Dialog-Frame.
end.
END.
ON LEFT-MOUSE-DBLCLICK OF BR-month IN FRAME Dialog-Frame
DO:
   if not avail t-month then return no-apply.
  run proc-uchet-card in this-procedure no-error.
  if error-status:error then return no-apply.
END.
ON RETURN OF BR-month IN FRAME Dialog-Frame
DO:
   if not avail t-month then return no-apply.
  run proc-uchet-card in this-procedure no-error.
  if error-status:error then return no-apply.
END.
ON VALUE-CHANGED OF BR-month IN FRAME Dialog-Frame
DO:
  run proc-value-change in this-procedure no-error.
END.
ON VALUE-CHANGED OF RS-curr IN FRAME Dialog-Frame
DO:
  assign
  Rs-curr.
  run proc-value-change in this-procedure no-error.
END.
ON VALUE-CHANGED OF T-cost IN FRAME Dialog-Frame
DO:
  assign
  T-cost.
  assign
  v-cost-view = T-cost AND v-enable-cost
  .
  run proc-value-change in this-procedure no-error.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame Dialog-Frame
do:
  run gbl/app_help.p
    (input this-procedure :file-name
    ,input ''
    ,input ?
    ) no-error.
  if error-status :error then do:
    message
      "Ошибка при вызове помощи"
      error-status :get-message(1)
      view-as alert-box .
  end.
end.
run minbtn-set in this-procedure .
on choose of b-help in frame Dialog-Frame
do:
  apply "help":u to frame Dialog-Frame .
end.
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame Dialog-Frame:width - 0.3
                fh            = frame Dialog-Frame:first-child
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
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
define variable v-diasize-need-maximize        as logical   no-undo init true  .
define variable v-diasize-orig-frame-height    as decimal   no-undo .
define variable v-diasize-orig-frame-width     as decimal   no-undo .
define variable v-diasize-current-frame-width  as decimal   no-undo .
define variable v-diasize-current-frame-height as decimal   no-undo .
define variable v-diasize-change-size          as logical   no-undo .
define variable v-diasize-resize-button        as handle    no-undo .
define variable v-diasize-wndmax               as logical   no-undo .
define variable v-diasize-wndstore             as logical   no-undo .
define variable v-diasize-proc-name            as character no-undo .
define variable v-diasize-browse-handle        as handle    no-undo .
define variable v-diasize-browse-number        as integer   no-undo .
define variable v-diasize-need-full-display    as logical   no-undo init false .
define temp-table temp-diasize-handle no-undo
  field handle-value  as handle
  field save-position as decimal
  index xpk is primary unique handle-value
  .
define temp-table temp-browse-handle no-undo
  field browse-type   as character
  field browse-number as integer
  field browse-handle as handle
  field original-size as decimal
  index xpk is primary unique browse-type browse-number
  index xie browse-type browse-handle
.
procedure diasize_change-height :
  define input  parameter p-change-value  as decimal   no-undo .
  define input  parameter p-move-resize   as logical   no-undo .
  define variable v-field-group-handle    as handle    no-undo .
  define variable v-object-handle         as handle    no-undo .
  define variable v-frame-height          as decimal   no-undo .
  define variable v-frame-virtual-height  as decimal   no-undo .
  define variable v-browse-height         as decimal   no-undo .
  define variable v-window-height         as decimal   no-undo .
  define variable v-window-virtual-height as decimal   no-undo .
  define variable v-change-sign           as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame Dialog-Frame :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame Dialog-Frame :height-chars)
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame Dialog-Frame :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame Dialog-Frame :height-chars)
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, retry move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
          .
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-height = frame Dialog-Frame :height
      v-frame-virtual-height = frame Dialog-Frame :virtual-height
      v-browse-height = v-diasize-browse-handle :height
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'height':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :height
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame Dialog-Frame :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :row > v-diasize-browse-handle :row )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'height':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :row
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
    end.
    if p-move-resize = true
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'height':u
          ,input  string(frame Dialog-Frame :height - v-diasize-orig-frame-height)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-height :
  define input  parameter p-new-height  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-height in this-procedure
      (input  (p-new-height - frame Dialog-Frame :height)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_change-width :
  define input  parameter p-change-value as decimal   no-undo .
  define input  parameter p-move-resize  as logical   no-undo .
  define variable v-field-group-handle   as handle    no-undo .
  define variable v-object-handle        as handle    no-undo .
  define variable v-frame-width          as decimal   no-undo .
  define variable v-frame-virtual-width  as decimal   no-undo .
  define variable v-browse-width         as decimal   no-undo .
  define variable v-window-width         as decimal   no-undo .
  define variable v-window-virtual-width as decimal   no-undo .
  define variable v-change-sign          as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame Dialog-Frame :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame Dialog-Frame :width
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame Dialog-Frame :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame Dialog-Frame :width
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, leave move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-width = frame Dialog-Frame :width
      v-frame-virtual-width = frame Dialog-Frame :virtual-width
      v-browse-width = v-diasize-browse-handle :width
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'width':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :width
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame Dialog-Frame :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and v-object-handle <> v-diasize-resize-button
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :col + v-object-handle :width
              > v-diasize-browse-handle :col + v-diasize-browse-handle :width
            )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'width':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :col
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame Dialog-Frame :width = v-frame-width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        v-diasize-browse-handle :width = v-browse-width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        v-diasize-browse-handle :width = v-diasize-browse-handle :width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        frame Dialog-Frame :width = frame Dialog-Frame :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
        no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
    end.
    if p-move-resize
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'width':u
          ,input  string(frame Dialog-Frame :width - v-diasize-orig-frame-width)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-width :
  define input  parameter p-new-width  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-width in this-procedure
      (input  (p-new-width - frame Dialog-Frame :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame Dialog-Frame
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame Dialog-Frame :height - v-diasize-resize-button :height
                  - 1
                  - (frame Dialog-Frame :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame Dialog-Frame :width - v-diasize-resize-button :width
                  - 1
                  - (frame Dialog-Frame :border-right-pixels / session :pixels-per-column)
    .
    view v-diasize-resize-button .
  end.
end procedure.
on alt-right anywhere
do:
  run diasize_change-width in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-left anywhere
do:
  run diasize_change-width in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-down anywhere
do:
  run diasize_change-height in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-up anywhere
do:
  run diasize_change-height in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-enter of frame Dialog-Frame
do:
  run diasize_maximize in this-procedure
    (input  ?
    ).
  return no-apply .
end.
procedure diasize_end-move :
  do
  on error undo, return error return-value
  :
    define variable v-row-delta as decimal   no-undo .
    define variable v-col-delta as decimal   no-undo .
    define variable v-new-row as decimal   no-undo .
    define variable v-new-col as decimal   no-undo .
    assign
      v-new-row = decimal(last-event :y) / (session :pixels-per-row)
      v-new-col = decimal(last-event :x) / (session :pixels-per-column)
    .
    assign
      v-row-delta = v-new-row - frame Dialog-Frame :height
      v-col-delta = v-new-col - frame Dialog-Frame :width
    .
    run diasize_change-height in this-procedure
      (input v-row-delta
      ,input true
      ) .
    run diasize_change-width in this-procedure
      (input v-col-delta
      ,input true
      ) .
  end.
end procedure.
procedure diasize_maximize :
  define input  parameter p-action as logical   no-undo .
  do
  on error undo, return error return-value
  :
    if p-action = ?
    then do:
      if v-diasize-need-maximize = true
      then do:
        assign
          p-action = true
        .
      end.
      else do:
        assign
          p-action = false
        .
      end.
    end.
    if p-action = true
    then do:
      run diasize_change-height in this-procedure
        (input decimal(session :work-area-height-pixels) / session :pixels-per-row
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = true
      .
    end.
  end.
end procedure.
procedure diasize_restore-orig-size :
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-current-frame-width  = frame Dialog-Frame :width
      v-diasize-current-frame-height = frame Dialog-Frame :height
    .
    run diasize_set-height in this-procedure
      (input  v-diasize-orig-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-orig-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_restore-current-size :
  do
  on error undo, return error return-value
  :
    run diasize_set-height in this-procedure
      (input  v-diasize-current-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-current-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_set-browse-handle :
  define input  parameter p-browse-handle as handle   no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-handle = p-browse-handle
    .
    for each buf_temp-browse-handle
    on error undo, return error return-value
    :
      delete buf_temp-browse-handle .
    end.
  end.
end procedure.
procedure diasize_add_browse :
  define input  parameter p-browse-type   as character no-undo .
  define input  parameter p-browse-handle as handle    no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-number = v-diasize-browse-number + 1
    .
    create buf_temp-browse-handle .
    assign
      buf_temp-browse-handle.browse-type   = p-browse-type
      buf_temp-browse-handle.browse-number = v-diasize-browse-number
      buf_temp-browse-handle.browse-handle = p-browse-handle
    .
  end.
end procedure.
procedure diasize_init :
  define variable v-default-value    as logical   no-undo .
  define variable v-restore-saved    as logical   no-undo .
  define variable v-resize-value-str as character no-undo .
  do
  on error undo, return error return-value
  :
    do with frame Dialog-Frame
    :
      assign
        v-diasize-orig-frame-height = frame Dialog-Frame :height
        v-diasize-orig-frame-width  = frame Dialog-Frame :width
        v-diasize-browse-handle     = browse BR-dinamo :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame Dialog-Frame :first-child
        label         = "s"
        height-pixels = 16
        width-pixels  = 16
        visible       = true
        sensitive     = true
        movable       = true
        triggers:
          on end-move persistent run diasize_end-move in this-procedure .
        end triggers.
      v-diasize-resize-button :load-mouse-pointer("SIZE") .
      v-diasize-resize-button :load-image("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-down("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-insensitive("exe/grip.bmp":U) .
      assign
        v-diasize-wndmax = false
      .
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndmax':U
          ,output v-diasize-wndmax
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-wndstore = false
      .
      if connected("ub") = true
      then do:
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndstore':U
          ,output v-diasize-wndstore
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-proc-name = entry(1, program-name(2), '.')
      .
      if v-diasize-wndstore = true
      then do:
        assign
          v-restore-saved = false
        .
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'height':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-height in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'width':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-width in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if v-restore-saved <> true
        then do:
          if v-diasize-wndmax = true
          then do:
            run diasize_maximize in this-procedure
              (input  true
              ) .
          end.
        end.
      end.
      else do:
        if v-diasize-wndmax = true
        then do:
          run diasize_maximize in this-procedure
            (input  true
            ) .
        end.
      end.
    end.
  end.
end procedure.
procedure diasize_need-full-display :
  define output parameter p-need-full-display as logical   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-need-full-display = v-diasize-need-full-display
    .
    assign
      v-diasize-need-full-display = false
    .
  end.
end procedure.
procedure get-context :
   define output parameter p-db-num as integer          no-undo.
   define output parameter p-user-id as character        no-undo.
   define variable v-login               as character    no-undo.
   define buffer buf_sys-ctrl    for ub.sys-ctrl .
   define buffer buf_user-login  for ub.user-login .
   do
   on error undo, return error
   :
         FIND FIRST buf_sys-ctrl no-lock.
         ASSIGN
            v-login = USERID("ub")
            p-db-num = buf_sys-ctrl.db-num
         .
         FIND FIRST buf_user-login
              WHERE buf_user-login.db-num = p-db-num
                AND buf_user-login.user-login = v-login
              no-lock
              no-error
              .
         IF AVAILABLE buf_user-login
         THEN DO:
            assign
               p-user-id = buf_user-login.user-id
            .
         END.
   end.
end procedure.
    run diasize_init in this-procedure .
ON ROW-DISPLAY OF br-dinamo IN frame Dialog-Frame
DO:
  IF AVAIL t-dinamo THEN DO:
    RUN set-row-color.
  END.
END.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
  find first buf_goods no-lock where buf_goods.gds-code = p-gds-code.
  assign
    RS-curr :radio-buttons in frame Dialog-Frame = "Баз.вал.,base,Рубли,rubl"
  .
  assign
    RS-curr = "rubl":U
  .
  for each obj-list no-lock
  :
    define variable v-chk-act-host-code as integer   no-undo .
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  obj-list.obj-type
  ,input  obj-list.obj-code
  ,output v-chk-act-host-code
  )  .
define variable vss-include-info24 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_archive_cost':U
    ,input  'object':U
    ,input  v-chk-act-host-code
    ,input  obj-list.obj-type
    ,input  obj-list.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output v-cost-obj
    )  .
end.
    assign
    v-enable-cost = v-enable-cost AND v-cost-obj
    .
  end.
  run fill-tables in this-procedure .
  RUN Myenable.
  APPLY "VALUE-CHANGED" to browse br-month.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE do-zuka :
define input parameter p-year as integer no-undo.
define input parameter p-month as integer no-undo.
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
DEFINE VARIABLE v-doc-ext-doc-type as character no-undo .
DEFINE VARIABLE jj as integer no-undo .
define buffer buf_t-dinamo for t-dinamo.
define buffer z_t-dinamo for t-dinamo.
do jj = 1 to num-entries ('ee':U + chr(44) +                               'es':U + chr(44) +                               're':U + chr(44) +                               'rs':U):
  assign
  v-doc-ext-doc-type = entry(jj, ('ee':U + chr(44) +                               'es':U + chr(44) +                               're':U + chr(44) +                               'rs':U))
  .
  find first buf_t-dinamo no-lock where
            buf_t-dinamo.ym = p-year * 100 + p-month
        AND buf_t-dinamo.ext-doc-type = v-doc-ext-doc-type .
  find first z_t-dinamo where
             z_t-dinamo.ym = buf_t-dinamo.ym
         AND z_t-dinamo.ext-doc-type =  (buf_t-dinamo.ext-doc-type + chr(44) + "discount":U)
         no-error .
  if not avail z_t-dinamo then do:
    create z_t-dinamo.
    buffer-copy buf_t-dinamo except doc-type-full to z_t-dinamo
    assign
    z_t-dinamo.ext-doc-type = buf_t-dinamo.ext-doc-type + chr(44) + "discount":U
    z_t-dinamo.doc-type-full = fill(chr(32), 5) +  "Скидка"
    z_t-dinamo.is-zuka = yes
    .
  end.
  assign
  z_t-dinamo.sale-sum-rubl =  if buf_t-dinamo.sale-sum-rubl = 0
                              then 0
                              else
                              (buf_t-dinamo.sale-sum-rubl - buf_t-dinamo.doc-sum-rubl) / buf_t-dinamo.sale-sum-rubl * 100
  z_t-dinamo.cost-sum-rubl = buf_t-dinamo.sale-sum-rubl - buf_t-dinamo.doc-sum-rubl
  z_t-dinamo.sale-sum-base = if buf_t-dinamo.sale-sum-base = 0
                            then 0
                            else
                            (buf_t-dinamo.sale-sum-base - buf_t-dinamo.doc-sum-base) / buf_t-dinamo.sale-sum-base * 100
  z_t-dinamo.cost-sum-base = buf_t-dinamo.sale-sum-base - buf_t-dinamo.doc-sum-base
  .
  find first z_t-dinamo where
             z_t-dinamo.ym = buf_t-dinamo.ym
         AND z_t-dinamo.ext-doc-type = (buf_t-dinamo.ext-doc-type + chr(44) + "benefit":U)
         no-error .
  if not avail z_t-dinamo then do:
    create z_t-dinamo.
    buffer-copy buf_t-dinamo except ext-doc-type to z_t-dinamo
    assign
    z_t-dinamo.ext-doc-type = buf_t-dinamo.ext-doc-type + chr(44) + "benefit":U
    z_t-dinamo.doc-type-full = fill(chr(32), 5) +  "Доход"
    z_t-dinamo.is-zuka = yes
    .
  end.
  assign
  z_t-dinamo.sale-sum-rubl = if buf_t-dinamo.cost-sum-rubl = 0
                            then 0
                            else
                            (buf_t-dinamo.doc-sum-rubl - buf_t-dinamo.cost-sum-rubl) / buf_t-dinamo.cost-sum-rubl * 100
  z_t-dinamo.cost-sum-rubl = buf_t-dinamo.doc-sum-rubl - buf_t-dinamo.cost-sum-rubl
  z_t-dinamo.sale-sum-base = if buf_t-dinamo.cost-sum-rubl = 0
                            then 0
                            else
                            (buf_t-dinamo.doc-sum-base - buf_t-dinamo.cost-sum-base) / buf_t-dinamo.cost-sum-base * 100
  z_t-dinamo.cost-sum-base = buf_t-dinamo.doc-sum-base - buf_t-dinamo.cost-sum-base
  .
end.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY T-cost RS-curr f-date-start F-unit-base
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-Help RECT-2 BR-dinamo RS-curr BR-month BR-stk B-uchet
         B-objects B-print
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY BR-dinamo FOR EACH t-dinamo no-lock where t-dinamo.ym = t-month.ym.    define variable v-last-ym as integer no-undo. if not can-find(first t-month no-lock where                         t-month.ym > v-cut-ym) and          can-find(first t-month no-lock where                         t-month.ym <= v-cut-ym) then do:     find last t-month no-lock where                 t-month.ym < v-cut-ym .     assign     v-last-ym = t-month.ym     .     OPEN QUERY BR-month FOR EACH t-month no-lock where t-month .ym = v-last-ym.  end.  else do: OPEN QUERY BR-month FOR EACH t-month no-lock where t-month.ym >= v-cut-ym. end.    OPEN QUERY BR-stk FOR EACH t-stk no-lock where t-stk.ym = t-month.ym.
END PROCEDURE.
PROCEDURE fill-dinamo :
define input parameter p-year as integer no-undo .
define input parameter p-month as integer no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
if lookup( string( p-year * 100 + p-month ), v-MontYear_List ) > 0 then
  return.
v-MontYear_List = v-MontYear_List + (if v-MontYear_List = '' then '' else ',' )
                + string( p-year * 100 + p-month ).
DEFINE VARIABLE ii as integer no-undo .
DEFINE VARIABLE jj as integer no-undo .
DEFINE VARIABLE v-ext-doc-type as character no-undo .
DEFINE VARIABLE v-ext-doc-type-full as character no-undo .
DEFINE VARIABLE v-doc-type as character no-undo .
DEFINE VARIABLE v-doc-type-full as character no-undo .
DEFINE VARIABLE v-idoc-type as character no-undo .
DEFINE VARIABLE v-sign as character no-undo .
DEFINE VARIABLE v-sign-int as integer no-undo .
DEFINE VARIABLE v-sale-sum-type as character no-undo .
DEFINE VARIABLE v-cost-sum-type as character no-undo .
DEFINE VARIABLE v-doc-sum-type as character no-undo .
DEFINE VARIABLE v-last-day as integer no-undo .
DEFINE VARIABLE bfact-order like ub.ot-line.fact-order no-undo .
DEFINE VARIABLE afact-order like ub.ot-line.fact-order no-undo .
define buffer m_t-dinamo  for t-dinamo.
define buffer sale_ot-line for ub.ot-line  .
define buffer cost_ot-line for ub.ot-line  .
define buffer doc_ot-line for ub.ot-line.
assign
v-sign = string(0)
.
_ii:
do ii = 1 to num-entries('ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U):
  assign
  v-ext-doc-type = entry(ii, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U)
  v-doc-type = get-doc-type(input ii, input-output v-ext-doc-type, input-output v-sign, output v-ext-doc-type-full, output v-doc-type-full, output v-idoc-type)
  .
  if v-idoc-type = "0" then next _ii.
  do jj = 1 to num-entries(v-ext-doc-type):
    find first t-dinamo where
              t-dinamo.ym = p-year * 100 + p-month
          AND t-dinamo.ext-doc-type = entry(jj, v-ext-doc-type)
          AND t-dinamo.idoc-type = integer(entry(jj, v-idoc-type))
          AND t-dinamo.sign_ = integer(entry(jj, v-sign)) no-error .
    if not available t-dinamo then do:
      create t-dinamo.
      assign
      t-dinamo.ym = p-year * 100 + p-month
      t-dinamo.year_ = p-year
      t-dinamo.month_ = p-month
      t-dinamo.ext-doc-type = entry(jj, v-ext-doc-type)
      t-dinamo.doc-type = entry(jj, v-doc-type)
      t-dinamo.ext-doc-type-full = entry(jj, v-ext-doc-type-full)
      t-dinamo.doc-type-full = t-dinamo.ext-doc-type-full
      t-dinamo.idoc-type = integer(entry(jj, v-idoc-type))
      t-dinamo.sign_ = integer(entry(jj, v-sign))
      .
      find first m_t-dinamo no-lock where
                 m_t-dinamo.ym = t-dinamo.ym
            AND m_t-dinamo.idoc-type = t-dinamo.idoc-type
            AND m_t-dinamo.ext-doc-type = "":U no-error .
      if not avail m_t-dinamo then do:
        create m_t-dinamo.
        assign
        m_t-dinamo.ym = p-year * 100 + p-month
        m_t-dinamo.year_ = p-year
        m_t-dinamo.month_ = p-month
        m_t-dinamo.ext-doc-type = "":U
        m_t-dinamo.doc-type = entry(jj, v-doc-type)
        m_t-dinamo.ext-doc-type-full = "":U
        m_t-dinamo.doc-type-full = v-doc-type-full
        m_t-dinamo.idoc-type = integer(entry(jj, v-idoc-type))
        m_t-dinamo.sign = 0
        .
      end.
    end.
  end.
end.
ASSIGN v-last-day = last-day( date( p-month, 1, p-year ) ).
run day-begin-fact-order in this-procedure (
                                             input date(p-month, 1, p-year)
                                             ,output bfact-order).
run factord-end-day  in this-procedure (
                                             input  date(p-month, v-last-day, p-year)
                                             ,output afact-order).
if buf_goods.gds-type = 'т':U then do:
  assign
  v-sale-sum-type = 'crsa':U
  v-cost-sum-type = 'cost':U
  v-doc-sum-type = 'sale':U
  .
end.
else do:
  assign
  v-sale-sum-type = 'cgsr':U
  v-cost-sum-type = 'cssr':U
  v-doc-sum-type = 'sasr':U
  .
end.
find first t-fo no-lock where
           t-fo.obj-type = p-obj-type
       AND t-fo.obj-code = p-obj-code no-error .
if avail t-fo and t-fo.fact-order <> 0 then do:
  assign
  bfact-order = min(bfact-order, t-fo.fact-order)
  afact-order = min(afact-order, t-fo.fact-order)
  .
end.
_sale:
for each sale_ot-line no-lock where
         sale_ot-line.artic = buf_goods.artic
     AND sale_ot-line.prod-type = buf_goods.prod-type
     AND sale_ot-line.prod-code = buf_goods.prod-code
     AND sale_ot-line.obj-type = p-obj-type
     AND sale_ot-line.obj-code = p-obj-code
     AND sale_ot-line.sum-type = v-sale-sum-type
     and sale_ot-line.fact-order >= bfact-order
     and sale_ot-line.fact-order <= afact-order
     :
  find first cost_ot-line no-lock where
         cost_ot-line.artic = buf_goods.artic
     AND cost_ot-line.prod-type = buf_goods.prod-type
     AND cost_ot-line.prod-code = buf_goods.prod-code
     AND cost_ot-line.obj-type = p-obj-type
     AND cost_ot-line.obj-code = p-obj-code
     AND cost_ot-line.cat-id = '##,##':U
     AND cost_ot-line.sum-type = v-cost-sum-type
     and cost_ot-line.doc-code = sale_ot-line.doc-code no-error .
  assign
  v-sign = string(if (sale_ot-line.fact-qnty >= 0) then 1 else -1)
  v-ext-doc-type = sale_ot-line.ext-doc-type
  ii = lookup(v-ext-doc-type, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U)
  v-doc-type = get-doc-type(input ii,
                            input-output v-ext-doc-type,
                            input-output v-sign,
                            output v-ext-doc-type-full,
                            output v-doc-type-full,
                            output v-idoc-type)
  v-sign-int = integer(v-sign)
  .
  if v-idoc-type = "0" then next _sale.
  find first t-dinamo where
             t-dinamo.ym = p-year * 100 + p-month
         AND t-dinamo.ext-doc-type = sale_ot-line.ext-doc-type
         AND t-dinamo.sign_ = v-sign-int no-error .
  if avail t-dinamo then do:
    assign
    t-dinamo.fact-qnty = t-dinamo.fact-qnty + sale_ot-line.fact-qnty
    t-dinamo.sale-sum-rubl = t-dinamo.sale-sum-rubl + sale_ot-line.sum-rubl
    t-dinamo.sale-sum-base = t-dinamo.sale-sum-base +  sale_ot-line.sum-base
    t-dinamo.cost-sum-rubl = t-dinamo.cost-sum-rubl +  (if avail cost_ot-line then cost_ot-line.sum-rubl else 0)
    t-dinamo.cost-sum-base = t-dinamo.cost-sum-base +  (if avail cost_ot-line then cost_ot-line.sum-base else 0)
    .
  end.
end.
do jj = 1 to num-entries(('ee':U + chr(44) +                               'es':U + chr(44) +                               're':U + chr(44) +                               'rs':U)):
  find first t-dinamo where
            t-dinamo.ym =p-year * 100 + p-month
        AND t-dinamo.ext-doc-type = entry(jj, ('ee':U + chr(44) +                               'es':U + chr(44) +                               're':U + chr(44) +                               'rs':U)) .
  for each doc_ot-line no-lock where
          doc_ot-line.artic = buf_goods.artic
      AND doc_ot-line.prod-type = buf_goods.prod-type
      AND doc_ot-line.prod-code = buf_goods.prod-code
      AND doc_ot-line.obj-type = p-obj-type
      AND doc_ot-line.obj-code = p-obj-code
      AND doc_ot-line.sum-type = v-doc-sum-type
      and doc_ot-line.ext-doc-type = entry(jj, ('ee':U + chr(44) +                               'es':U + chr(44) +                               're':U + chr(44) +                               'rs':U))
      and doc_ot-line.fact-order >= bfact-order
      and doc_ot-line.fact-order <= afact-order
      :
    assign
    t-dinamo.doc-sum-rubl = t-dinamo.doc-sum-rubl + doc_ot-line.sum-rubl
    t-dinamo.doc-sum-base = t-dinamo.doc-sum-base + doc_ot-line.sum-base
    .
  end.
end.
run do-zuka in this-procedure (p-year, p-month, p-obj-type, p-obj-code).
END PROCEDURE.
PROCEDURE fill-tables :
DEFINE VARIABLE v-before-fact-date      like ub.stk-line.fact-date no-undo .
DEFINE VARIABLE v-before-ym             as integer no-undo .
DEFINE VARIABLE v-before-fact-order     like ub.stk-line.fact-order no-undo .
DEFINE VARIABLE v-before-fact-qnty      like ub.stk-line.fact-qnty no-undo .
DEFINE VARIABLE v-before-sale-sum-rubl  like ub.stk-line.sum-rubl no-undo .
DEFINE VARIABLE v-before-sale-sum-base  like ub.stk-line.sum-base no-undo .
DEFINE VARIABLE v-before-cost-sum-rubl  like ub.stk-line.sum-rubl no-undo .
DEFINE VARIABLE v-before-cost-sum-base  like ub.stk-line.sum-base no-undo .
DEFINE VARIABLE v-after-fact-qnty      like ub.stk-line.fact-qnty no-undo .
DEFINE VARIABLE v-after-sale-sum-rubl  like ub.stk-line.sum-rubl no-undo .
DEFINE VARIABLE v-after-sale-sum-base  like ub.stk-line.sum-base no-undo .
DEFINE VARIABLE v-after-cost-sum-rubl  like ub.stk-line.sum-rubl no-undo .
DEFINE VARIABLE v-after-cost-sum-base  like ub.stk-line.sum-base no-undo .
DEFINE VARIABLE v-date-start           as date no-undo init 01/01/1990.
DEFINE VARIABLE v-date-end             as date no-undo  init 12/31/9999.
DEFINE VARIABLE v-ret                  as logical no-undo .
define variable p-comment              as character no-undo .
define variable v-can-print            as logical   no-undo .
define buffer sale_stk-line for ub.stk-line.
define buffer cost_stk-line for ub.stk-line.
define buffer before_t-stk-obj for t-stk-obj.
define buffer after_t-stk-obj for t-stk-obj.
define buffer skip_t-stk for t-stk .
run waitfram-show in this-procedure ( "Ждите" ).
for each t-month:
  delete t-month.
end.
for each t-stk:
  delete t-stk.
end.
for each t-stk-obj:
  delete t-stk-obj.
end.
for each t-dinamo:
  delete t-dinamo.
end.
for each t-fo:
  delete t-fo.
end.
assign
f-date-start = 01/01/1990
.
for each obj-list no-lock
:
  run rep/chk-ahz.p
    (input        obj-list.obj-type
    ,input        obj-list.obj-code
    ,input        false
    ,input        yes
    ,input        no
    ,input        no
    ,input        yes
    ,input        v-cntxt-db-num
    ,input        v-cntxt-userid
    ,input-output v-date-start
    ,input-output v-date-end
    ,output       v-ret
    ,output       p-comment
    ,output       v-can-print
    ) no-error .
  if error-status :error = yes then do:
    error-status :error = no.
  end.
  create t-fo.
  assign
  t-fo.obj-type = obj-list.obj-type
  t-fo.obj-code = obj-list.obj-code
  t-fo.cfact-date = v-date-start
  t-fo.ym = year(v-date-start) * 100 + month(v-date-start)
  v-cut-ym = maximum(v-cut-ym, t-fo.ym)
  f-date-start = maximum(f-date-start, v-date-start)
  .
end.
if buf_goods.gds-type = 'т':U then do:
  for each obj-list no-lock,
    each sale_stk-line no-lock
      where sale_stk-line.obj-type = obj-list.obj-type
        AND sale_stk-line.obj-code = obj-list.obj-code
        AND sale_stk-line.artic = buf_goods.artic
        AND sale_stk-line.prod-type = buf_goods.prod-type
        AND sale_stk-line.prod-code = buf_goods.prod-code
        AND sale_stk-line.cat-id = '##,##':U
        AND sale_stk-line.sum-type = 'crsa':U
  break
  by sale_stk-line.obj-type
  by sale_stk-line.obj-code
  by sale_stk-line.fact-order
  :
    if first-of(sale_stk-line.obj-code) then do:
      assign
      v-before-fact-date = ?
      v-before-ym  = 0
      v-before-fact-order = 0
      v-before-fact-qnty  = 0
      v-after-fact-qnty  = 0
      v-before-cost-sum-rubl = 0
      v-before-cost-sum-base = 0
      v-after-cost-sum-rubl = 0
      v-after-cost-sum-base = 0
      v-before-sale-sum-rubl = 0
      v-before-sale-sum-base = 0
      v-after-sale-sum-rubl = 0
      v-after-sale-sum-base = 0
      v-MontYear_List = ''
      .
    end.
    find first t-month where
              t-month.ym = year(sale_stk-line.fact-date) * 100 +  month(sale_stk-line.fact-date)
              no-error .
    if not avail t-month then do:
      find first cost_stk-line no-lock where
                cost_stk-line.artic = buf_goods.artic
            AND cost_stk-line.prod-type = buf_goods.prod-type
            AND cost_stk-line.prod-code = buf_goods.prod-code
            AND cost_stk-line.obj-type = obj-list.obj-type
            AND cost_stk-line.obj-code = obj-list.obj-code
            AND cost_stk-line.sum-type = 'cost':U
            AND cost_stk-line.fact-order = v-before-fact-order no-error .
      if avail cost_stk-line then do:
        assign
          v-before-cost-sum-rubl = cost_stk-line.sum-rubl
          v-before-cost-sum-base = cost_stk-line.sum-base
          v-after-cost-sum-rubl = cost_stk-line.sum-rubl
          v-after-cost-sum-base = cost_stk-line.sum-base
        .
      end.
      create t-month.
      assign
        t-month.month_ = month(sale_stk-line.fact-date)
        t-month.year_ = year(sale_stk-line.fact-date)
        t-month.ym = t-month.year_ * 100 + t-month.month_
        t-month.obj-type = obj-list.obj-type
        t-month.obj-code = obj-list.obj-code
      .
      create t-stk-obj.
      assign
        t-stk-obj.month_ = month(sale_stk-line.fact-date)
        t-stk-obj.year_ = year(sale_stk-line.fact-date)
        t-stk-obj.ym = t-stk-obj.year_ * 100 + t-stk-obj.month_
        t-stk-obj.b-a = 0
        t-stk-obj.b-a-full = "Начало месяца"
        t-stk-obj.fact-qnty  = v-before-fact-qnty
        t-stk-obj.sale-sum-rubl = v-before-sale-sum-rubl
        t-stk-obj.sale-sum-base  = v-before-sale-sum-base
        t-stk-obj.cost-sum-rubl = v-before-cost-sum-rubl
        t-stk-obj.cost-sum-base  = v-before-cost-sum-base
        t-stk-obj.obj-type = obj-list.obj-type
        t-stk-obj.obj-code = obj-list.obj-code
      .
      run fill-dinamo in this-procedure (t-stk-obj.year_, t-stk-obj.month_, obj-list.obj-type, obj-list.obj-code) .
      if v-before-ym > 0 then do:
        find first before_t-stk-obj
          where before_t-stk-obj.ym = v-before-ym
            AND before_t-stk-obj.b-a = 0
            AND before_t-stk-obj.obj-type = obj-list.obj-type
            AND before_t-stk-obj.obj-code = obj-list.obj-code
          no-error .
      end.
      else do:
        if avail before_t-stk-obj then do:
          release before_t-stk-obj.
        end.
      end.
      if not avail before_t-stk-obj then do:
      end.
      else do:
        find first after_t-stk-obj
          where after_t-stk-obj.ym = before_t-stk-obj.ym
            AND after_t-stk-obj.b-a = 1
            AND after_t-stk-obj.obj-type = obj-list.obj-type
            AND after_t-stk-obj.obj-code = obj-list.obj-code
          no-error .
        if not avail after_t-stk-obj then do:
          create after_t-stk-obj.
          assign
          after_t-stk-obj.ym = before_t-stk-obj.ym
          after_t-stk-obj.year_ = before_t-stk-obj.year_
          after_t-stk-obj.month_ = before_t-stk-obj.month_
          after_t-stk-obj.b-a = 1
          after_t-stk-obj.b-a-full = "Конец месяца"
          after_t-stk-obj.obj-type = obj-list.obj-type
          after_t-stk-obj.obj-code = obj-list.obj-code
          .
          run fill-dinamo in this-procedure (after_t-stk-obj.year_, after_t-stk-obj.month_, obj-list.obj-type, obj-list.obj-code) .
        end.
        assign
        after_t-stk-obj.fact-qnty     =  after_t-stk-obj.fact-qnty     +   v-after-fact-qnty
        after_t-stk-obj.sale-sum-rubl =  after_t-stk-obj.sale-sum-rubl +   v-after-sale-sum-rubl
        after_t-stk-obj.sale-sum-base =  after_t-stk-obj.sale-sum-base +   v-after-sale-sum-base
        after_t-stk-obj.cost-sum-rubl =  after_t-stk-obj.cost-sum-rubl +   v-after-cost-sum-rubl
        after_t-stk-obj.cost-sum-base =  after_t-stk-obj.cost-sum-base +   v-after-cost-sum-base
        .
      end.
    end.
    else do:
      if t-month.obj-type = obj-list.obj-type AND
        t-month.obj-code = obj-list.obj-code then do:
      end.
      else do:
        assign
          t-month.obj-type = obj-list.obj-type
          t-month.obj-code = obj-list.obj-code
        .
        find first t-stk-obj
          where t-stk-obj.ym = year(sale_stk-line.fact-date) * 100 +  month(sale_stk-line.fact-date)
            AND t-stk-obj.b-a = 0
            AND t-stk-obj.obj-type = obj-list.obj-type
            AND t-stk-obj.obj-code = obj-list.obj-code
          no-error.
        if not available t-stk-obj then do:
          create t-stk-obj.
          assign
          t-stk-obj.ym = year(sale_stk-line.fact-date) * 100 +  month(sale_stk-line.fact-date)
          t-stk-obj.year_ = year(sale_stk-line.fact-date)
          t-stk-obj.month_ = month(sale_stk-line.fact-date)
          t-stk-obj.b-a = 0
          t-stk-obj.b-a-full = "Начало месяца"
          t-stk-obj.obj-type = obj-list.obj-type
          t-stk-obj.obj-code = obj-list.obj-code
          .
          run fill-dinamo in this-procedure (t-stk-obj.year_, t-stk-obj.month_, obj-list.obj-type, obj-list.obj-code) .
        end.
        find first cost_stk-line no-lock where
                  cost_stk-line.artic = buf_goods.artic
              AND cost_stk-line.prod-type = buf_goods.prod-type
              AND cost_stk-line.prod-code = buf_goods.prod-code
              AND cost_stk-line.obj-type = obj-list.obj-type
              AND cost_stk-line.obj-code = obj-list.obj-code
              AND cost_stk-line.sum-type = 'cost':U
              AND cost_stk-line.fact-order = v-before-fact-order no-error .
        if avail cost_stk-line then do:
          assign
            v-before-cost-sum-rubl = cost_stk-line.sum-rubl
            v-before-cost-sum-base = cost_stk-line.sum-base
            v-after-cost-sum-rubl = cost_stk-line.sum-rubl
            v-after-cost-sum-base = cost_stk-line.sum-base
          .
        end.
        assign
          t-stk-obj.fact-qnty  = t-stk-obj.fact-qnty + v-before-fact-qnty
          t-stk-obj.sale-sum-rubl = t-stk-obj.sale-sum-rubl + v-before-sale-sum-rubl
          t-stk-obj.sale-sum-base  = t-stk-obj.sale-sum-base + v-before-sale-sum-base
          t-stk-obj.cost-sum-rubl = t-stk-obj.cost-sum-rubl + v-before-cost-sum-rubl
          t-stk-obj.cost-sum-base  = t-stk-obj.cost-sum-base + v-before-cost-sum-base
        .
        find first after_t-stk-obj
          where after_t-stk-obj.ym = v-before-ym
            AND after_t-stk-obj.b-a = 1
            AND after_t-stk-obj.obj-type = obj-list.obj-type
            AND after_t-stk-obj.obj-code = obj-list.obj-code
          no-error .
        if not avail after_t-stk-obj and v-before-ym <> 0 then do:
          create after_t-stk-obj.
          assign
            after_t-stk-obj.year_ = year(v-before-fact-date)
            after_t-stk-obj.month_ = month(v-before-fact-date)
            after_t-stk-obj.ym = v-before-ym
            after_t-stk-obj.b-a = 1
            after_t-stk-obj.b-a-full = "Конец месяца"
            after_t-stk-obj.obj-type = obj-list.obj-type
            after_t-stk-obj.obj-code = obj-list.obj-code
          .
          run fill-dinamo in this-procedure (after_t-stk-obj.year_, after_t-stk-obj.month_, obj-list.obj-type, obj-list.obj-code) .
        end.
        if avail after_t-stk-obj then do:
          assign
            after_t-stk-obj.fact-qnty  = after_t-stk-obj.fact-qnty + v-after-fact-qnty
            after_t-stk-obj.sale-sum-rubl = after_t-stk-obj.sale-sum-rubl + v-after-sale-sum-rubl
            after_t-stk-obj.sale-sum-base  = after_t-stk-obj.sale-sum-base + v-after-sale-sum-base
            after_t-stk-obj.cost-sum-rubl = after_t-stk-obj.cost-sum-rubl + v-after-cost-sum-rubl
            after_t-stk-obj.cost-sum-base  = after_t-stk-obj.cost-sum-base + v-after-cost-sum-base
          .
        end.
      end.
    end.
    assign
      v-before-fact-date      = sale_stk-line.fact-date
      v-before-ym             = year(sale_stk-line.fact-date) * 100 + month(sale_stk-line.fact-date)
      v-before-fact-order     = sale_stk-line.fact-order
      v-before-fact-qnty     = sale_stk-line.fact-qnty
      v-before-sale-sum-rubl = sale_stk-line.sum-rubl
      v-before-sale-sum-base = sale_stk-line.sum-base
      v-after-fact-qnty     =  sale_stk-line.fact-qnty
      v-after-sale-sum-rubl =  sale_stk-line.sum-rubl
      v-after-sale-sum-base =  sale_stk-line.sum-base
    .
    if last-of(sale_stk-line.obj-code) then do:
      find first cost_stk-line no-lock where
                cost_stk-line.artic = buf_goods.artic
            AND cost_stk-line.prod-type = buf_goods.prod-type
            AND cost_stk-line.prod-code = buf_goods.prod-code
            AND cost_stk-line.obj-type = obj-list.obj-type
            AND cost_stk-line.obj-code = obj-list.obj-code
            AND cost_stk-line.sum-type = 'cost':U
            AND cost_stk-line.fact-order = v-before-fact-order no-error .
      if avail cost_stk-line then do:
        assign
          v-after-cost-sum-rubl =  cost_stk-line.sum-rubl
          v-after-cost-sum-base =  cost_stk-line.sum-base
        .
      end.
      else do:
        assign
          v-after-cost-sum-rubl =  0
          v-after-cost-sum-base =  0
        .
      end.
      find first after_t-stk-obj
        where after_t-stk-obj.ym = year(sale_stk-line.fact-date) * 100 + month(sale_stk-line.fact-date)
          AND after_t-stk-obj.b-a = 1
          AND after_t-stk-obj.obj-type = obj-list.obj-type
          AND after_t-stk-obj.obj-code = obj-list.obj-code
        no-error .
      if not available after_t-stk-obj then do:
        create after_t-stk-obj.
        assign
          after_t-stk-obj.ym = year(sale_stk-line.fact-date) * 100 + month(sale_stk-line.fact-date)
          after_t-stk-obj.year_ = year(sale_stk-line.fact-date)
          after_t-stk-obj.month_ =  month(sale_stk-line.fact-date)
          after_t-stk-obj.b-a = 1
          after_t-stk-obj.b-a-full = "Конец месяца"
          after_t-stk-obj.obj-type = obj-list.obj-type
          after_t-stk-obj.obj-code = obj-list.obj-code
        .
      end.
      assign
        after_t-stk-obj.fact-qnty = after_t-stk-obj.fact-qnty + v-after-fact-qnty
        after_t-stk-obj.sale-sum-rubl = after_t-stk-obj.sale-sum-rubl + v-after-sale-sum-rubl
        after_t-stk-obj.sale-sum-base  = after_t-stk-obj.sale-sum-base + v-after-sale-sum-base
        after_t-stk-obj.cost-sum-rubl = after_t-stk-obj.cost-sum-rubl + v-after-cost-sum-rubl
        after_t-stk-obj.cost-sum-base  = after_t-stk-obj.cost-sum-base + v-after-cost-sum-base
      .
      find first t-fo where
                  t-fo.obj-type = obj-list.obj-type
              AND t-fo.obj-code = obj-list.obj-code no-error .
      if not avail t-fo then do:
        create t-fo.
        assign
        t-fo.obj-type = obj-list.obj-type
        t-fo.obj-code = obj-list.obj-code
        .
      end.
      assign
      t-fo.fact-order = sale_stk-line.fact-order
      .
    end.
  end.
    for each t-month no-lock,
      each obj-list no-lock,
      first t-stk-obj where
           t-stk-obj.obj-type = obj-list.obj-type
       AND t-stk-obj.obj-code = obj-list.obj-code
       AND (
            (t-stk-obj.ym = t-month.ym
        AND  t-stk-obj.b-a = 0 )
       OR   t-stk-obj.ym < t-month.ym
            )
           by t-stk-obj.ym descending
           by t-stk-obj.b-a descending
           :
    find first t-stk where
                t-stk.ym = t-month.ym
            AND t-stk.b-a = 0 no-error .
    if not avail t-stk then do:
      create t-stk.
      assign
      t-stk.ym = t-month.ym
      t-stk.year_ = t-month.year_
      t-stk.month_ = t-month.month_
      t-stk.b-a = 0
      t-stk.b-a-full = "Начало месяца"
      .
    end.
    assign
    t-stk.fact-qnty     = t-stk.fact-qnty     + t-stk-obj.fact-qnty
    t-stk.sale-sum-rubl = t-stk.sale-sum-rubl + t-stk-obj.sale-sum-rubl
    t-stk.sale-sum-base = t-stk.sale-sum-base + t-stk-obj.sale-sum-base
    t-stk.cost-sum-rubl = t-stk.cost-sum-rubl + t-stk-obj.cost-sum-rubl
    t-stk.cost-sum-base = t-stk.cost-sum-base + t-stk-obj.cost-sum-base
    .
  end.
  for each t-month no-lock,
      each obj-list no-lock,
      first t-stk-obj where
           t-stk-obj.obj-type = obj-list.obj-type
       AND t-stk-obj.obj-code = obj-list.obj-code
       AND
           (
           (t-stk-obj.ym = t-month.ym
       AND t-stk-obj.b-a = 1)
        OR t-stk-obj.ym < t-month.ym
           )
       by t-stk-obj.ym descending
       by t-stk-obj.b-a descending
           :
    find first t-stk where
                t-stk.ym = t-month.ym
            AND t-stk.b-a = 1 no-error .
    if not avail t-stk then do:
      create t-stk.
      assign
      t-stk.ym = t-month.ym
      t-stk.year_ = t-month.year_
      t-stk.month_ = t-month.month_
      t-stk.b-a = 1
      t-stk.b-a-full = "Конец месяца"
      .
    end.
    assign
    t-stk.fact-qnty     = t-stk.fact-qnty     + t-stk-obj.fact-qnty
    t-stk.sale-sum-rubl = t-stk.sale-sum-rubl + t-stk-obj.sale-sum-rubl
    t-stk.sale-sum-base = t-stk.sale-sum-base + t-stk-obj.sale-sum-base
    t-stk.cost-sum-rubl = t-stk.cost-sum-rubl + t-stk-obj.cost-sum-rubl
    t-stk.cost-sum-base = t-stk.cost-sum-base + t-stk-obj.cost-sum-base
    .
  end.
end.
else do:
  for each obj-list no-lock,
      each sale_stk-line no-lock where
          sale_stk-line.obj-type = obj-list.obj-type AND
          sale_stk-line.obj-code = obj-list.obj-code AND
          sale_stk-line.artic = buf_goods.artic AND
          sale_stk-line.prod-type = buf_goods.prod-type AND
          sale_stk-line.prod-code = buf_goods.prod-code AND
          sale_stk-line.cat-id = '##,##':U AND
          sale_stk-line.sum-type begins  'cgdt':U
  break
  by sale_stk-line.obj-type
  by sale_stk-line.obj-code
  by sale_stk-line.fact-order:
    find first t-month where
              t-month.ym = year(sale_stk-line.fact-date) * 100 +  month(sale_stk-line.fact-date)
              no-error .
    if not avail t-month then do:
      create t-month.
      assign
      t-month.month_ = month(sale_stk-line.fact-date)
      t-month.year_ = year(sale_stk-line.fact-date)
      t-month.ym = t-month.year_ * 100 + t-month.month_
      t-month.obj-type = obj-list.obj-type
      t-month.obj-code = obj-list.obj-code
      .
    end.
    if last-of (sale_stk-line.obj-code) then do:
      find first t-fo where
                  t-fo.obj-type = obj-list.obj-type
              AND t-fo.obj-code = obj-list.obj-code no-error .
      if not avail t-fo then do:
        create t-fo.
        assign
        t-fo.obj-type = obj-list.obj-type
        t-fo.obj-code = obj-list.obj-code
        .
      end.
      assign
      t-fo.fact-order = sale_stk-line.fact-order
      .
    end.
    run fill-dinamo in this-procedure (t-month.year_, t-month.month_, obj-list.obj-type, obj-list.obj-code) .
  end.
end.
run waitfram-hide in this-procedure .
END PROCEDURE.
PROCEDURE Myenable :
DISPLAY T-cost RS-curr
buf_goods.unit-base @ f-unit-base
f-date-start
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-Help BR-dinamo RS-curr BR-month BR-stk B-uchet B-objects
  T-cost when v-enable-cost
         B-print
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
 define variable v-last-ym as integer no-undo. if not can-find(first t-month no-lock where                         t-month.ym > v-cut-ym) and          can-find(first t-month no-lock where                         t-month.ym <= v-cut-ym) then do:     find last t-month no-lock where                 t-month.ym < v-cut-ym .     assign     v-last-ym = t-month.ym     .     OPEN QUERY BR-month FOR EACH t-month no-lock where t-month .ym = v-last-ym.  end.  else do: OPEN QUERY BR-month FOR EACH t-month no-lock where t-month.ym >= v-cut-ym. end.
 if avail t-month then do:
    OPEN QUERY BR-dinamo FOR EACH t-dinamo no-lock where t-dinamo.ym = t-month.ym.
      OPEN QUERY BR-stk FOR EACH t-stk no-lock where t-stk.ym = t-month.ym.
  end.
END PROCEDURE.
PROCEDURE proc-b-print :
define input parameter p-year as integer no-undo.
define input parameter p-month as integer no-undo.
DEFINE VARIABLE v-fact-qnty-s as character no-undo .
DEFINE VARIABLE v-sale-sum-s as character no-undo .
DEFINE VARIABLE v-cost-sum-s as character no-undo .
DEFINE VARIABLE Line as character no-undo .
DEFINE VARIABLE date_string as character no-undo .
DEFINE VARIABLE v-ym as integer no-undo .
define buffer buf_t-dinamo for t-dinamo.
define buffer buf_t-stk for t-stk.
define frame Fdinamo
buf_t-dinamo.doc-type-full FORMAT "X(18)" column-label "":U
v-fact-qnty-s column-label "Кол-во" format "X(15)"
v-sale-sum-s COLUMn-LABEL "Сумма продаж. цен" format "X(22)"
v-cost-sum-s COLUMn-LABEL "Сумма учетных цен" format "X(22)"
HEADER  date_string AT 5 format "X(35)"
string( "Страница " ) format "X(9)" AT 50 PAGE-NUMBER(PrnLibStream) AT 60 FORMAT ">>9" SKIP
Line format "X(80)" AT 1
with width 232 down stream-io use-text    .
Line = fill("-", 80).
date_string = cur-time-print() .
run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input 62
                                            ,input yes
                                            ,input no
                                            ).
PUT  STREAM PrnLibStream unformatted
frame Dialog-Frame:title format "x(90)" chr(10)
(fill(chr(32), 20) +
 "(":U +  (if RS-curr = "rubl":U then "Рубли" else "Баз.вал.") + ")":U) skip
 str4
 SKIP(1) .
FORM HEADER
Line format "X(80)" AT 1 SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame width 232 PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW  STREAM PrnLibStream FRAME BottomFrame .
FORM with FRAME FDinamo  .
run waitfram-show in this-procedure("Ждите...").
assign
v-ym = p-year * 100 + p-month
.
for each buf_t-dinamo no-lock where
         buf_t-dinamo.ym = v-ym
break
by buf_t-dinamo.idoc-type
by buf_t-dinamo.ext-doc-type:
  display stream PrnLibStream
  buf_t-dinamo.doc-type-full
  (if buf_t-dinamo.ext-doc-type <> "":U and not buf_t-dinamo.is-zuka
  then string(buf_t-dinamo.fact-qnty, "->>,>>>,>>9.999")
  else "":U)      @  v-fact-qnty-s
  (if buf_t-dinamo.ext-doc-type <> "":U
  then string((if RS-curr = "rubl":U then buf_t-dinamo.sale-sum-rubl else buf_t-dinamo.sale-sum-base),
              (if buf_t-dinamo.is-zuka
              then "->>,>>9.99%"
              else "->>,>>>,>>>,>>>,>>9.99")
              )
  else "":U) @ v-sale-sum-s
  (if v-cost-view then
  (if buf_t-dinamo.ext-doc-type <> "":U
  then string((if RS-curr = "rubl":U then buf_t-dinamo.cost-sum-rubl else buf_t-dinamo.cost-sum-base), "->>,>>>,>>>,>>>,>>9.99")
  else "":U)
  else "":U)
  @  v-cost-sum-s
  WITH FRAME Fdinamo.
  if last-of(buf_t-dinamo.idoc-type) then do:
    DOWN STREAM PrnLibStream 2 with FRAME FDinamo .
  end.
  else do:
    DOWN STREAM PrnLibStream 1 with FRAME FDinamo .
  end.
END.
UNDERLINE stream PrnLibStream
buf_t-dinamo.doc-type-full
v-fact-qnty-s
v-sale-sum-s
v-cost-sum-s
WITH FRAME Fdinamo.
DOWN STREAM PrnLibStream 1 with FRAME FDinamo .
DISPLAY stream PrnLibStream
"Остатки"  @ buf_t-dinamo.doc-type-full
WITH FRAME Fdinamo.
DOWN STREAM PrnLibStream 1 with FRAME FDinamo .
for each buf_t-stk no-lock where
         buf_t-stk.ym = v-ym:
  DISPLAY stream PrnLibStream
  buf_t-stk.b-a-full
    @ buf_t-dinamo.doc-type-full
  string(buf_t-stk.fact-qnty, "->>,>>>,>>9.999")
    @  v-fact-qnty-s
  string((if RS-curr = "rubl":U then buf_t-stk.sale-sum-rubl else buf_t-stk.sale-sum-base), "->>,>>>,>>>,>>>,>>9.99")
    @ v-sale-sum-s
 (if v-cost-view then
  string((if RS-curr = "rubl":U then buf_t-stk.cost-sum-rubl else buf_t-stk.cost-sum-base), "->>,>>>,>>>,>>>,>>9.99")
  else "":U)
    @  v-cost-sum-s
  WITH FRAME Fdinamo.
  DOWN STREAM PrnLibStream 1 with FRAME FDinamo .
end.
HIDE  STREAM PrnLibStream FRAME BottomFrame .
HIDE  STREAM PrnLibStream FRAME Fdinamo.
output STREAM PrnLibStream CLOSE.
run waitfram-hide in this-procedure.
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 0
                                          ).
END PROCEDURE.
PROCEDURE proc-c-dinamo :
DEFINE VARIABLE v-curr as character no-undo .
define variable v-doc-rec as recid no-undo .
define variable next-prev as logical no-undo .
if t-dinamo.ext-doc-type = "":U then return error.
if num-entries(t-dinamo.doc-type-full) > 1 then return error.
br-handle = br-month:handle in frame Dialog-Frame.
v-curr = RS-curr.
assign
v-doc-rec = ?
next-prev = yes
.
       run rep/c-dinamo.w
                      (
                       input parparentproc
                      ,input t-dinamo.ext-doc-type
                      ,input t-dinamo.sign_
                      ,input p-gds-code
                      ,input v-cost-view
                      ,input-output v-curr
                      ,input-output v-doc-rec
                      ,input-output br-handle
                      ,input-output next-prev
                                    ) no-error.
    if error-status:error then return error.
    rs-curr = v-curr.
    display RS-curr
    with frame Dialog-Frame .
    apply "VALUE-CHANGED" to Rs-curr.
END PROCEDURE.
PROCEDURE proc-uchet-card :
DEFINE VARIABLE v-curr as character no-undo .
define variable v-doc-rec as recid no-undo .
define variable next-prev as logical no-undo .
    assign
    next-prev = yes.
    br-handle = br-month:handle in frame Dialog-Frame.
    v-curr = RS-curr.
    DO WHILE next-prev <> ?:
        if NOT available t-month then do:
                message "Неправильно выбран месяц." view-as alert-box ERROR.
                return error.
        end.
        v-doc-rec = recid (t-month).
        .
       run rep/c-dinamo.w
                      (
                       input parparentproc
                      ,input 'все':U
                      ,input 0
                      ,input p-gds-code
                      ,input v-cost-view
                      ,input-output v-curr
                      ,input-output v-doc-rec
                      ,input-output br-handle
                      ,input-output next-prev
                                    ) no-error
        .
    END .
    if br-handle = ? then
    reposition br-month to recid v-doc-rec no-error.
    rs-curr = v-curr.
    display RS-curr
    with frame Dialog-Frame .
    apply "VALUE-CHANGED" to Rs-curr.
    apply "entry" to br-month in frame Dialog-Frame.
    apply "value-changed" to br-month in frame Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-value-change :
define variable v-month-name as character no-undo.
if available t-month then do:
    assign
    v-month-name = string(t-month.month_).
    run gbl/monthnam.p (input t-month.month_, output v-month-name) no-error.
end.
assign
frame Dialog-Frame:title = ("код товара:" + chr(32) +              string(buf_goods.gds-code) + chr(32) + "артикул:" + chr(32) +              buf_goods.artic + chr(32) +              buf_goods.prod-type + string(buf_goods.prod-code) + chr(32) +              string(buf_goods.gds-name, "X(20)") + chr(32) +              (if avail t-month then              ("Динамика за":U + chr(32) + v-month-name +              chr(32) + string(t-month.year_))              else "":U)).
if available t-month and t-month.ym >= v-cut-ym then do:
    OPEN QUERY br-dinamo FOR EACH t-dinamo no-lock where t-dinamo.ym = t-month.ym.
    OPEN QUERY br-stk FOR EACH t-stk no-lock where t-stk.ym = t-month.ym .
end.
else do:
  if not can-find(first t-month no-lock where
                        t-month.ym > v-cut-ym) and
         can-find(first t-month no-lock where
                        t-month.ym <= v-cut-ym) then do:
    OPEN QUERY br-dinamo FOR EACH t-dinamo no-lock where false.
    OPEN QUERY br-stk FOR EACH t-stk no-lock where
                               t-stk.ym = t-month.ym
                           AND t-stk.b-a = 1 .
  end.
  else do:
    OPEN QUERY br-dinamo FOR EACH t-dinamo no-lock where false.
    OPEN QUERY br-stk FOR EACH t-stk no-lock where false .
  end.
end.
REPOSITION br-dinamo to row v-row no-error.
br-dinamo :SET-REPOSITIONED-ROW(5, "CONDITIONAL").
END PROCEDURE.
PROCEDURE set-row-color :
DEF VAR iFGColor AS INTEGER NO-UNDO.
  DEF VAR iBGColor AS INTEGER NO-UNDO.
  IF t-dinamo.ext-doc-type = "":U THEN DO:
      ASSIGN
        iFGColor = WHITE_COLOR
        iBGColor = DARK_GREEN_COLOR
      .
    end.
    ELSE do:
      ASSIGN
        iFGColor = Black_COLOR
        iBGColor = White_COLOR
      .
    end.
    ASSIGN
      t-dinamo.doc-type-full:FGCOLOR IN BROWSE BR-dinamo = iFGColor
      t-dinamo.doc-type-full:BGCOLOR IN BROWSE BR-dinamo = iBGColor
    .
END PROCEDURE.
