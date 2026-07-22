block-level on error undo, throw.
define input parameter parparentproc as   widget-handle       no-undo .
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
DEFINE INPUT PARAMETER p-obj-type         like ub.shift-obj.obj-type    no-undo.
DEFINE INPUT PARAMETER p-obj-code         like ub.shift-obj.obj-code    no-undo.
DEFINE INPUT PARAMETER p-shift-date-start like ub.shift-obj.shift-date  no-undo.
DEFINE INPUT PARAMETER p-shift-num-start  like ub.shift-obj.shift-num   no-undo.
DEFINE INPUT PARAMETER p-shift-date-end   like ub.shift-obj.shift-date  no-undo.
DEFINE INPUT PARAMETER p-shift-num-end    like ub.shift-obj.shift-num   no-undo.
define input parameter p-tog-1-out-pump-with-icnt as logical   no-undo .
define variable vss-revision    as character no-undo init "$Revision: 077e8f550cdc, 482, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Sun Feb 28 19:22:49 2016 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-shift9.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-shift9.p $":U .
define variable vss-description as character no-undo init "Сменный отчет лист 9 сбор данных".
define   shared stream  PrnLibStream.
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
define variable vss-include-info8 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define  temp-table t-9 no-undo
field gds-code       like ub.goods.gds-code
field gds-name       like ub.goods.gds-name
field pump-code      like ub.rvs-line-pump.pump-code
field nozzle-code    like ub.icnt-line.nozzle-code
field start-mh-qnty  like ub.rvs-line-pump.meas-mh-cnt
field end-mh-qnty    like ub.rvs-line-pump.meas-mh-cnt
field meas-qnty      like ub.rvs-line-pump.meas-mh-cnt
field prev-start-mh-qnty like ub.rvs-line-pump.meas-mh-cnt
field start-el-qnty  like ub.rvs-line-pump.meas-el-cnt
field end-el-qnty    like ub.rvs-line-pump.meas-el-cnt
field prev-start-el-qnty like ub.rvs-line-pump.meas-el-cnt
field doc-qnty       as decimal INITIAL 0
field delta          as decimal INITIAL 0
field cancell-qnty      as decimal INITIAL 0
field cancell-qnty-notot as decimal INITIAL 0
field overflow-qnty     as decimal INITIAL 0
field trans-qnty        as decimal INITIAL 0
field tech-refuell-qnty as decimal INITIAL 0
index pi is unique primary
  gds-code
  pump-code
  nozzle-code
.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define buffer buf_chk-doc  for ub.chk-doc .
define buffer bf_t-9      for t-9 .
define buffer buf_goods    for ub.goods .
define variable v-counter    as integer      no-undo.
define variable pol1  as character no-undo .
define variable pol2  as character no-undo .
define variable pol3  as character no-undo .
define variable pol4  as decimal   no-undo .
define variable pol5  as decimal   no-undo .
define variable pol6  as decimal   no-undo .
define variable pol7  as decimal   no-undo .
define variable pol8  as decimal   no-undo.
define variable pol9  as decimal   no-undo.
define variable pol10 as decimal  no-undo .
define variable pol11 as decimal  no-undo .
define variable pol12 as decimal  no-undo .
define variable pol13 as decimal  no-undo .
do
on error undo, return error
:
   for each  bf_t-9:
      delete bf_t-9.
   end.
   run calc-rest  ( INPUT p-obj-type
                  , INPUT p-obj-code
                  , INPUT p-shift-date-start
                  , INPUT p-shift-num-start
                  , INPUT p-shift-date-end
                  , INPUT p-shift-num-end
                  ) .
   _shift-chk:
   FOR EACH buf_chk-doc
      WHERE buf_chk-doc.obj-type = p-obj-type
      AND   buf_chk-doc.obj-code = p-obj-code
      AND   buf_chk-doc.shift-date >= p-shift-date-start
      AND   buf_chk-doc.shift-date <= p-shift-date-end
      AND    ( buf_chk-doc.chk-type = integer('1':U)
            OR buf_chk-doc.chk-type = integer('6':U)
            OR buf_chk-doc.chk-type = integer('15':U)
            OR buf_chk-doc.chk-type = integer('14':U)
            OR buf_chk-doc.chk-type = integer('16':U)
            OR buf_chk-doc.chk-type = integer('17':U)
             )
      NO-LOCK
      :
      IF ( buf_chk-doc.shift-date = p-shift-date-start
      AND  buf_chk-doc.shift-num  < p-shift-num-start)
      OR ( buf_chk-doc.shift-date = p-shift-date-end
      AND  buf_chk-doc.shift-num  > p-shift-num-end)
      THEN dO:
         NEXT _shift-chk.
      END.
      v-counter = v-counter + 1.
      IF v-counter MODULO 10 = 0
      then DO:
         run waitfram-show in this-procedure (substitute("Ждите... Обработано &1 чеков по топливу", v-counter)).
      END.
      run add-chk in this-procedure ( input buf_chk-doc.obj-type
                                            , input buf_chk-doc.obj-code
                                            , input buf_chk-doc.doc-code
                                            , input buf_chk-doc.chk-type
                                            ) .
   END.
    run post-add-chks.
   DEFINE FRAME FRAME-9
      pol1  no-label format "x(28)" space(0)
      sym1  no-label format "x(1)"  space(0)
      pol2  no-label format "x(3)" space(0)
      sym2  no-label format "x(1)"  space(0)
      pol3  no-label format "x(5)" space(0)
      sym3  no-label format "x(1)"  space(0)
      pol4  no-label format "->>>,>>>,>>9.99" space(0)
      sym4  no-label format "x(1)"  space(0)
      pol5  no-label format "->>>,>>>,>>9.99" space(0)
      sym5  no-label format "x(1)"  space(0)
      pol6  no-label format "->>>,>>>,>>9.99" space(0)
      sym6  no-label format "x(1)"  space(0)
      pol7  no-label format "->>>,>>>,>>9.99" space(0)
      sym7  no-label format "x(1)"  space(0)
      pol8  no-label format "->>>,>>>,>>9.99" space(0)
      sym8  no-label format "x(1)"  space(0)
      pol9  no-label format "->>>,>>>,>>9.99" space(0)
      sym9  no-label format "x(1)"  space(0)
      pol10 no-label format "->>>,>>>,>>9.99" space(0)
      sym10 no-label format "x(1)"  space(0)
      pol11 no-label format "->>>,>>>,>>9.99" space(0)
      sym11 no-label format "x(1)"  space(0)
      pol12 no-label format "->>>,>>>,>>9.99" space(0)
      sym12 no-label format "x(1)"  space(0)
      pol13 no-label format "->>>,>>>,>>9.99" space(0)
   with width 232 down stream-io use-text NO-BOX.
   FORM HEADER
   '------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------'  skip '                            : № :  №  :  Счетчик на   :  Счетчик на   :               :               :               :               :     Сброс     :     Сброс     :               :    Перевод    '  skip '    НАИМЕНОВАНИЕ топлива    :ТРК:ПИСТ.:     начало    :    конец      :    Оборот     :      Касса    :   Техпролив   :    Разница    :  (Не пролито) :   (Пролито)   :    Перелив    :   транзакции  '  skip '------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------'  skip '              9.1           :9.2: 9.3 :      9.4      :      9.5      :      9.6      :      9.7      :      9.8      :      9.9      :      9.10     :      9.11     :      9.12     :      9.13     '  skip '------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------'
   with FRAME TopFrame width 232 PAGE-Top NO-LABELS NO-BOX .
   VIEW STREAM PrnLibStream FRAME TOpFrame .
   for each  bf_t-9
       break by bf_t-9.gds-code
       :
      run on-same-page in this-procedure (1 + 1) .
      IF first-of (bf_t-9.gds-code) THEN DO:
         assign
            pol1  = bf_t-9.gds-name
            pol2  = STRING(bf_t-9.pump-code, ">>9")
            pol3  = STRING(bf_t-9.nozzle-code, ">>9")
            pol4  = bf_t-9.start-mh-qnty
            pol5  = bf_t-9.end-mh-qnty
            pol6  = bf_t-9.meas-qnty
            pol7  = bf_t-9.doc-qnty
            pol8  = bf_t-9.tech-refuell-qnty
            pol9  = bf_t-9.delta
            pol10  = bf_t-9.cancell-qnty
            pol11  = bf_t-9.cancell-qnty-notot
            pol12 = bf_t-9.overflow-qnty
            pol13 = bf_t-9.trans-qnty
        .
      end.
      else do:
         assign
            pol1  = "":U
            pol2  = STRING(bf_t-9.pump-code, ">>9")
            pol3  = STRING(bf_t-9.nozzle-code, ">>9")
            pol4  = bf_t-9.start-mh-qnty
            pol5  = bf_t-9.end-mh-qnty
            pol6  = bf_t-9.meas-qnty
            pol7  = bf_t-9.doc-qnty
            pol8  = bf_t-9.tech-refuell-qnty
            pol9  = bf_t-9.delta
            pol10  = bf_t-9.cancell-qnty
            pol11  = bf_t-9.cancell-qnty-notot
            pol12 = bf_t-9.overflow-qnty
            pol13 = bf_t-9.trans-qnty
         .
      end.
      DISPLAY Stream PrnLibStream
          sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12
          pol1 pol2 pol3 pol4 pol5 pol6 pol7 pol8 pol9 pol10 pol11 pol12 pol13
      WITH FRAME Frame-9.
      down stream PrnLibStream with frame frame-9.
      if Make-Excel then  put   stream ForExcel unformatted
         pol1   CHR(9)
         pol2   CHR(9)
         pol3   CHR(9)
         pol4   CHR(9)
         pol5   CHR(9)
         pol6   CHR(9)
         pol7   CHR(9)
         pol8   CHR(9)
         pol9   CHR(9)
         pol10  CHR(9)
         pol11  CHR(9)
         pol12  CHR(9)
         pol13  CHR(9)
      SKIP.
      accumulate bf_t-9.start-mh-qnty       (Total by bf_t-9.gds-code).
      accumulate bf_t-9.end-mh-qnty         (Total by bf_t-9.gds-code).
      accumulate bf_t-9.meas-qnty           (Total by bf_t-9.gds-code).
      accumulate bf_t-9.doc-qnty            (Total by bf_t-9.gds-code).
      accumulate bf_t-9.delta               (Total by bf_t-9.gds-code).
      accumulate bf_t-9.tech-refuell-qnty   (Total by bf_t-9.gds-code).
      accumulate bf_t-9.cancell-qnty        (Total by bf_t-9.gds-code).
      accumulate bf_t-9.cancell-qnty-notot  (Total by bf_t-9.gds-code).
      accumulate bf_t-9.overflow-qnty       (Total by bf_t-9.gds-code).
      accumulate bf_t-9.trans-qnty          (Total by bf_t-9.gds-code).
      IF last-of (bf_t-9.gds-code) THEN DO:
         assign
            pol1  = SUBSTITUTE("Всего по &1", bf_t-9.gds-name)
            pol2  = ""
            pol3  = ""
            pol4  = accum Total by bf_t-9.gds-code bf_t-9.start-mh-qnty
            pol5  = accum Total by bf_t-9.gds-code bf_t-9.end-mh-qnty
            pol6  = accum Total by bf_t-9.gds-code bf_t-9.meas-qnty
            pol7  = accum Total by bf_t-9.gds-code bf_t-9.doc-qnty
            pol8  = accum Total by bf_t-9.gds-code bf_t-9.tech-refuell-qnty
            pol9  = accum Total by bf_t-9.gds-code bf_t-9.delta
            pol10 = accum Total by bf_t-9.gds-code bf_t-9.cancell-qnty
            pol11 = accum Total by bf_t-9.gds-code bf_t-9.cancell-qnty-notot
            pol12 = accum Total by bf_t-9.gds-code bf_t-9.overflow-qnty
            pol13 = accum Total by bf_t-9.gds-code bf_t-9.trans-qnty
         .
         underline stream PrnLibStream
            sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12
            pol1 pol2 pol3 pol4 pol5 pol6 pol7 pol8 pol9 pol10 pol11 pol12 pol13
         with frame frame-9.
         down stream PrnLibStream with frame frame-9.
         DISPLAY Stream PrnLibStream
            sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12
            pol1 pol2 pol3 pol4 pol5 pol6 pol7 pol8 pol9 pol10 pol11 pol12 pol13
         WITH FRAME Frame-9.
         down stream PrnLibStream with frame frame-9.
         underline stream PrnLibStream
            sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12
            pol1 pol2 pol3 pol4 pol5 pol6 pol7 pol8 pol9 pol10 pol11 pol12 pol13
         with frame frame-9.
         down stream PrnLibStream with frame frame-9.
         if Make-Excel then  put   stream ForExcel unformatted
            pol1   CHR(9)
            pol2   CHR(9)
            pol3   CHR(9)
            pol4   CHR(9)
            pol5   CHR(9)
            pol6   CHR(9)
            pol7   CHR(9)
            pol8   CHR(9)
            pol9   CHR(9)
            pol10  CHR(9)
            pol11  CHR(9)
            pol12  CHR(9)
            pol13  CHR(9)
         SKIP.
      END.
   end.
END.
procedure post-add-chks:
    def buffer buf_t-9 for t-9.
    for each buf_t-9:
        buf_t-9.delta = buf_t-9.delta + tech-refuell-qnty.
    end.
end.
procedure add-chk :
define input  parameter p-obj-type like ub.chk-doc.obj-type no-undo .
define input  parameter p-obj-code like ub.chk-doc.obj-code no-undo .
define input  parameter p-doc-code like ub.chk-doc.doc-code no-undo .
define input  parameter p-chk-type like ub.chk-doc.chk-type no-undo .
define buffer buf_chk-gds for ub.chk-gds.
define buffer buf_bar-code for ub.bar-code.
define buffer buf_t-9 for t-9.
define variable v-pump as integer   no-undo .
define variable v-nozzle-code    as integer      no-undo.
define variable v-qnty like ub.chk-gds.doc-qnty no-undo init 0.
do
on error undo, return error return-value
:
   for each buf_chk-gds
      where buf_chk-gds.doc-code = p-doc-code
      no-lock
      ,
      first buf_bar-code
      where buf_bar-code.b-code = buf_chk-gds.b-code
      no-lock
      :
      assign
         v-pump        = buf_chk-gds.pump
         v-nozzle-code = buf_chk-gds.nozzle-code
         v-qnty        = buf_chk-gds.doc-qnty
      .
      find first buf_t-9
            WHERE
            buf_t-9.gds-code    = buf_bar-code.gds-code
            AND buf_t-9.pump        = v-pump
            AND buf_t-9.nozzle-code = v-nozzle-code
      no-error
      .
      if not available buf_t-9 then do:
         find   buf_t-9
               WHERE
               buf_t-9.gds-code    = buf_bar-code.gds-code
               AND buf_t-9.pump        = v-pump
         no-error
         .
         if not available buf_t-9 then do:
            find first buf_t-9
                  WHERE
                      buf_t-9.gds-code    = buf_bar-code.gds-code
            no-error
            .
            if not available buf_t-9 then do:
            NEXT.
            end.
            else do:
            find first buf_goods
               where buf_goods.gds-code = buf_bar-code.gds-code
               no-lock
               .
            create buf_t-9.
            assign
               buf_t-9.gds-code    = buf_bar-code.gds-code
               buf_t-9.pump        = v-pump
               buf_t-9.nozzle-code = v-nozzle-code
               buf_t-9.gds-name    = buf_goods.gds-name
            .
            end.
         END.
         ELSE DO:
         END.
      end.
      case p-chk-type:
      WHEN integer('1':U)
      OR WHEN integer('6':U)
      then do:
         assign
            buf_t-9.doc-qnty      = buf_t-9.doc-qnty + v-qnty
            buf_t-9.delta         = buf_t-9.delta + v-qnty
         .
      end.
      WHEN integer('15':U) THEN DO:
         assign
            buf_t-9.overflow-qnty = buf_t-9.overflow-qnty + v-qnty
         .
      end.
      WHEN integer('14':U) THEN DO:
         if buf_chk-gds.write-off-code = 0 then
         assign
            buf_t-9.cancell-qnty  = buf_t-9.cancell-qnty  + v-qnty
         .
         if buf_chk-gds.write-off-code = 1 then
         assign
            buf_t-9.cancell-qnty-notot  = buf_t-9.cancell-qnty-notot + v-qnty
         .
      end.
      WHEN integer('16':U) THEN DO:
         assign
            buf_t-9.trans-qnty    = buf_t-9.trans-qnty    + v-qnty
         .
      end.
      WHEN integer('17':U) THEN DO:
          assign
            buf_t-9.tech-refuell-qnty = buf_t-9.tech-refuell-qnty + v-qnty
         .
      end.
      OTHERWISE DO:
      end.
      END case.
   end.
end.
end procedure.
procedure calc-rest :
DEFINE INPUT PARAMETER p-obj-type         like ub.shift-obj.obj-type    no-undo.
DEFINE INPUT PARAMETER p-obj-code         like ub.shift-obj.obj-code    no-undo.
DEFINE INPUT PARAMETER p-shift-date-start like ub.shift-obj.shift-date  no-undo.
DEFINE INPUT PARAMETER p-shift-num-start  like ub.shift-obj.shift-num   no-undo.
DEFINE INPUT PARAMETER p-shift-date-end   like ub.shift-obj.shift-date  no-undo.
DEFINE INPUT PARAMETER p-shift-num-end    like ub.shift-obj.shift-num   no-undo.
define buffer buf_rvs-doc        for ub.rvs-doc .
define buffer buf_rvs-line-pump  for ub.rvs-line-pump .
define buffer buf_t-9            for t-9 .
define buffer buf2_t-9            for t-9 .
define buffer buf_shift-obj      for ub.shift-obj .
define variable v-gds-name  as character    no-undo.
define variable v-dop as decimal no-undo .
do
on error undo, return error
:
   FIND LAST  buf_shift-obj
        WHERE buf_shift-obj.obj-type = p-obj-type
          AND buf_shift-obj.obj-code = p-obj-code
          and (
              (buf_shift-obj.shift-date = p-shift-date-start
          AND     buf_shift-obj.shift-num < p-shift-num-start)
           OR
               buf_shift-obj.shift-date < p-shift-date-start)
        use-index pi
        NO-LOCK
        NO-ERROR
        .
   IF AVAILABLE buf_shift-obj THEN DO:
      find first buf_rvs-doc
         where  buf_rvs-doc.obj-type  = p-obj-type
         and   buf_rvs-doc.obj-code   = p-obj-code
         and   buf_rvs-doc.status_    = 'факт':U
         and   buf_rvs-doc.shift-date = buf_shift-obj.shift-date
         and   buf_rvs-doc.shift-num  = buf_shift-obj.shift-num
         and   buf_rvs-doc.rvs-type   = 'смена':U
         no-lock
         no-error
         .
      IF AVAILABLE buf_rvs-doc THEN DO:
         FOR EACH    buf_rvs-line-pump
               WHERE buf_rvs-line-pump.rvs-code = buf_rvs-doc.rvs-code
               NO-LOCK
               :
               find first buf_t-9
                     WHERE buf_t-9.gds-code    = buf_rvs-line-pump.gds-code
                       AND buf_t-9.pump        = buf_rvs-line-pump.pump-code
                       AND buf_t-9.nozzle-code = buf_rvs-line-pump.nozzle-code
               no-error
               .
               if not available buf_t-9 then do:
                    find first buf_goods
                         where buf_goods.gds-code = buf_rvs-line-pump.gds-code
                         no-lock
                         no-error
                         .
                    IF AVAILABLE buf_goods THEN DO:
                       assign
                          v-gds-name = buf_goods.gds-name
                       .
                    END.
                    else do:
                       assign
                          v-gds-name = SUBSTITUTE("Товар &1 не найден", buf_rvs-line-pump.gds-code)
                       .
                    end.
                    create buf_t-9.
                    assign
                       buf_t-9.gds-code    = buf_rvs-line-pump.gds-code
                       buf_t-9.pump        = buf_rvs-line-pump.pump-code
                       buf_t-9.nozzle-code = buf_rvs-line-pump.nozzle-code
                       buf_t-9.gds-name    = v-gds-name
                    .
               ASSIGN
          buf_t-9.start-mh-qnty = buf_rvs-line-pump.state-mh-cnt
          buf_t-9.end-mh-qnty = buf_rvs-line-pump.state-mh-cnt
          buf_t-9.prev-start-mh-qnty = buf_rvs-line-pump.state-mh-cnt
          buf_t-9.start-el-qnty = buf_rvs-line-pump.state-el-cnt
          buf_t-9.end-el-qnty = buf_rvs-line-pump.state-el-cnt
          buf_t-9.prev-start-el-qnty = buf_rvs-line-pump.state-el-cnt
          buf_t-9.delta         = - buf_t-9.meas-qnty
               .
        end.
      END.
         RELEASE buf_rvs-doc.
    END.
  END.
  for each buf_shift-obj no-lock where
          buf_shift-obj.obj-type = p-obj-type
      and buf_shift-obj.obj-code = p-obj-code
      and (buf_shift-obj.shift-date > p-shift-date-start
      or (buf_shift-obj.shift-date = p-shift-date-start
          and
          buf_shift-obj.shift-num >= p-shift-num-start))
      and
         (buf_shift-obj.shift-date < p-shift-date-end
      or (buf_shift-obj.shift-date = p-shift-date-end
          and
          buf_shift-obj.shift-num <= p-shift-num-end))
  by buf_shift-obj.shift-date
  by buf_shift-obj.shift-num:
   find first buf_rvs-doc
      where  buf_rvs-doc.obj-type  = p-obj-type
      and   buf_rvs-doc.obj-code   = p-obj-code
      and   buf_rvs-doc.status_    = 'факт':U
      and   buf_rvs-doc.shift-date = buf_shift-obj.shift-date
      and   buf_rvs-doc.shift-num  = buf_shift-obj.shift-num
      and   buf_rvs-doc.rvs-type   = 'смена':U
      no-lock
      no-error
      .
   IF AVAILABLE buf_rvs-doc THEN DO:
      FOR EACH    buf_rvs-line-pump
            WHERE buf_rvs-line-pump.rvs-code = buf_rvs-doc.rvs-code
            NO-LOCK
            :
            find first buf_t-9
                  WHERE  buf_t-9.gds-code    = buf_rvs-line-pump.gds-code
                  AND buf_t-9.pump        = buf_rvs-line-pump.pump-code
                  AND buf_t-9.nozzle-code = buf_rvs-line-pump.nozzle-code
            no-error
            .
            if not available buf_t-9 then do:
          find first buf2_t-9
                WHERE   buf2_t-9.pump        = buf_rvs-line-pump.pump-code
                AND buf2_t-9.nozzle-code = buf_rvs-line-pump.nozzle-code
          no-error
        .
               find first buf_goods
                  where buf_goods.gds-code = buf_rvs-line-pump.gds-code
                  no-lock
                  no-error
                  .
               IF AVAILABLE buf_goods THEN DO:
                  assign
                     v-gds-name = buf_goods.gds-name
                  .
               END.
               else do:
                  assign
                     v-gds-name = SUBSTITUTE("Товар &1 не найден", buf_rvs-line-pump.gds-code)
                  .
               end.
               create buf_t-9.
               assign
                  buf_t-9.gds-code    = buf_rvs-line-pump.gds-code
                  buf_t-9.pump        = buf_rvs-line-pump.pump-code
                  buf_t-9.nozzle-code = buf_rvs-line-pump.nozzle-code
                  buf_t-9.gds-name    = v-gds-name
               .
          if available buf2_t-9 then do:
            assign
            buf_t-9.start-mh-qnty = buf2_t-9.prev-start-mh-qnty
            buf_t-9.end-mh-qnty = buf2_t-9.prev-start-mh-qnty
            buf_t-9.prev-start-mh-qnty = buf2_t-9.prev-start-mh-qnty
            buf_t-9.start-el-qnty = buf2_t-9.prev-start-el-qnty
            buf_t-9.end-el-qnty = buf2_t-9.prev-start-el-qnty
            buf_t-9.prev-start-el-qnty = buf2_t-9.prev-start-el-qnty
            .
            end.
          else do:
          v-dop = ?.
          run get-state-mh-cnt-from-icnt-doc in this-procedure (
                                                                 input p-obj-type
                                                                ,input p-obj-code
                                                                ,input buf_shift-obj.shift-date
                                                                ,input buf_shift-obj.shift-num
                                                                ,input buf_rvs-doc.fact-order
                                                                ,input buf_t-9.gds-code
                                                                ,input buf_t-9.pump
                                                                ,input buf_t-9.nozzle-code
                                                                ,input-output buf_t-9.prev-start-mh-qnty
                                                                ,input-output buf_t-9.prev-start-el-qnty
                                                                ).
            ASSIGN
          buf_t-9.start-mh-qnty = buf_t-9.prev-start-mh-qnty
          buf_t-9.end-mh-qnty = buf_t-9.prev-start-mh-qnty
          buf_t-9.start-el-qnty = buf_t-9.prev-start-el-qnty
          buf_t-9.end-el-qnty = buf_t-9.prev-start-el-qnty
            .
          end.
        end.
        if buf_rvs-line-pump.state-mh-cnt <  buf_t-9.end-mh-qnty then do:
            v-dop = ?.
            run get-state-mh-cnt-from-icnt-doc in this-procedure (
                                                                   input p-obj-type
                                                                  ,input p-obj-code
                                                                  ,input buf_shift-obj.shift-date
                                                                  ,input buf_shift-obj.shift-num
                                                                  ,input buf_rvs-doc.fact-order
                                                                  ,input buf_t-9.gds-code
                                                                  ,input buf_t-9.pump
                                                                  ,input buf_t-9.nozzle-code
                                                                  ,input-output buf_t-9.prev-start-mh-qnty
                                                                  ,input-output buf_t-9.prev-start-el-qnty
                                                                  ).
        end.
        ASSIGN
        buf_t-9.end-mh-qnty = buf_rvs-line-pump.state-mh-cnt
        buf_t-9.end-el-qnty = buf_rvs-line-pump.state-el-cnt
        buf_t-9.meas-qnty   = (if p-tog-1-out-pump-with-icnt
                              then (buf_t-9.meas-qnty + buf_rvs-line-pump.state-el-cnt - buf_t-9.prev-start-el-qnty)
                              else (buf_t-9.meas-qnty + buf_rvs-line-pump.state-mh-cnt - buf_t-9.prev-start-mh-qnty)
                              )
        buf_t-9.delta       = - buf_t-9.meas-qnty
        buf_t-9.prev-start-mh-qnty  = buf_rvs-line-pump.state-mh-cnt
        buf_t-9.prev-start-el-qnty  = buf_rvs-line-pump.state-el-cnt
        .
      END.
    END.
  end.
end.
end procedure.
procedure get-state-mh-cnt-from-icnt-doc :
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define input parameter p-from-shift-date as date no-undo.
define input parameter p-from-shift-num as integer no-undo.
define input parameter p-fact-order as decimal no-undo.
define input parameter p-gds-code as integer no-undo .
define input parameter p-pump-code as integer no-undo .
define input parameter p-nozzle-code as integer no-undo .
define input-output parameter p-state-mh-cnt as decimal no-undo .
define input-output parameter p-state-el-cnt as decimal no-undo .
define buffer buf_icnt-doc for ub.icnt-doc.
define buffer buf_icnt-line for ub.icnt-line.
for each buf_icnt-doc no-lock
  where buf_icnt-doc.obj-type = p-obj-type
    and buf_icnt-doc.obj-code = p-obj-code
    and buf_icnt-doc.status_ = 'факт':U
    and buf_icnt-doc.fact-order < p-fact-order
    by buf_icnt-doc.fact-order
    descending
on error undo, return error return-value
:
      find first buf_icnt-line no-lock where
            buf_icnt-line.doc-code = buf_icnt-doc.doc-code
        and buf_icnt-line.obj-code = buf_icnt-doc.obj-code
        and buf_icnt-line.obj-type = buf_icnt-doc.obj-type
        and buf_icnt-line.gds-code = p-gds-code
        and buf_icnt-line.pump-code = p-pump-code
        and buf_icnt-line.nozzle-code = p-nozzle-code no-error.
    if available buf_icnt-line then do:
      assign
      p-state-mh-cnt = buf_icnt-line.state-mh-cnt.
      p-state-el-cnt = buf_icnt-line.state-el-cnt.
      leave.
    end.
end.
end procedure.
