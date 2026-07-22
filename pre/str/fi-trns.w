define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Просмотр списка складских документов по фин.обязательству".
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
def var vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function func-get-name-from-ext-type   returns char
  ( p-ext-type as character   ,
    p-caps     as logical ).
define variable v-ext-name as character no-undo .
run get-name-from-ext-type in this-procedure (
    input p-ext-type  ,
    input p-caps  ,
    output v-ext-name )
    no-error .
    if error-status :error then do:
       assign
         v-ext-name = p-ext-type
       .
    end.
 return (v-ext-name) .
end.
procedure get-name-from-ext-type :
 do
 on error undo, return error return-value
 :
define input  parameter p-ext-type as character no-undo .
define input  parameter p-caps     as logical no-undo   .
define output parameter p-ext-name as character no-undo .
define variable v-num as integer no-undo .
  if lookup ( p-ext-type , 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U ) = 0 then do :
    message
      vss-include-info0 skip
      "Неправильно задано значение входящего параметра! "
      "Нет такого типа документов " p-ext-type
      view-as alert-box error .
      undo, return error .
  end.
  v-num      = lookup ( p-ext-type , 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U ) .
  p-ext-name = entry  ( v-num , 'приход внешний,расход внешний,возврат пост.,касса продажа,возврат внешний,касса возврат,списание,инвентаризация,пересортица,приход внутренний,расход внутренний,возврат внутренний,расход  произв.,списан. произв.,приход  произв.,переоценка,коррекция учетных цен,корректировка отрицательных партий,смена типа приобретения,приход внутриобъектный,расход внутриобъектный':U ) .
  if p-caps  = true then do :
     p-ext-name = caps(substring(p-ext-name,1,1) ) + substring(p-ext-name, 2 , length (p-ext-name) - 1 ) .
  end .
  end.
end procedure.
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
DEFINE INPUT PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input parameter par-host-code  like ub.clients.obj-code no-undo.
define input parameter p-fin-ob-doc-code like ub.fin-ob.doc-code no-undo.
define input parameter p-fin-ob-trn-doc  like ub.fin-ob.trn-doc-code no-undo.
define input parameter p-mode as character no-undo .
define new shared variable next-prev as logical no-undo .
define new shared variable br-handle as handle  no-undo .
define new shared buffer buf_fin-liab for ub.fin-ob .
define new shared buffer buf_fin-liab-before for ub.fin-ob-before .
define new shared buffer bufs_ord-doc-rcv for ub.ord-doc-rcv.
define new shared variable br-rcv-handle as handle no-undo   .
define variable v-U            AS char NO-UNDO.
define variable v-ext-doc-type AS CHAR NO-UNDO.
define variable v-doc-date  like ub.trn-doc.doc-date  NO-UNDO.
define variable v-fact-date like ub.trn-doc.fact-date NO-UNDO.
define variable v-cli-name  like ub.trn-doc.cli-name  NO-UNDO.
define variable v-fact-fo   like ub.fin-ob.sum-rubl   NO-UNDO.
define variable v-fact-qnty like ub.trn-doc.doc-qnty NO-UNDO.
define variable v-fact-rubl like ub.trn-doc.tot-fact NO-UNDO.
define variable v-creid     like ub.trn-doc.creid     NO-UNDO.
define variable v-fact-time as character no-undo .
FUNCTION sel-abbr RETURNS CHARACTER
 ( p-curr-code as int )  FORWARD.
DEFINE BUTTON B-exit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-lkp
     LABEL "&Документ"
     SIZE 10 BY 1 TOOLTIP "Просмотр складского документа".
DEFINE BUTTON B-lkp-2
     LABEL "&Фин.Обяз."
     SIZE 10 BY 1 TOOLTIP "Просмотр ФО или ПФО".
DEFINE BUTTON B-lkp-3
     LABEL "&Договор"
     SIZE 10 BY 1 TOOLTIP "Просмотр Договора".
DEFINE VARIABLE var-ps AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 56.5 BY 2.5 NO-UNDO.
DEFINE VARIABLE FILL-IN-1 AS CHARACTER FORMAT "X(256)":U INITIAL "Финансовое обязательство:"
      VIEW-AS TEXT
     SIZE 26 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE FILL-IN-2 AS CHARACTER FORMAT "X(256)":U INITIAL "Договор:"
      VIEW-AS TEXT
     SIZE 26 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE FILL-IN-sr-op AS CHARACTER FORMAT "X(256)":U INITIAL "Срок оплаты:"
      VIEW-AS TEXT
     SIZE 11.88 BY .67 NO-UNDO.
DEFINE VARIABLE FILL-IN_contract-prn-code AS CHARACTER FORMAT "X(16)"
     LABEL "№ договора"
      VIEW-AS TEXT
     SIZE 17 BY .67.
DEFINE VARIABLE FILL-IN_contract-type AS CHARACTER FORMAT "X(20)"
     LABEL "Тип"
      VIEW-AS TEXT
     SIZE 21.5 BY .67.
DEFINE VARIABLE FILL-IN_curr-code AS CHARACTER FORMAT "X(3)"
      VIEW-AS TEXT
     SIZE 5.38 BY .67
     FGCOLOR 4 .
DEFINE VARIABLE FILL-IN_doc-date AS DATE FORMAT "99/99/9999"
     LABEL "Дата ФО"
      VIEW-AS TEXT
     SIZE 11 BY .67.
DEFINE VARIABLE FILL-IN_doc-type AS CHARACTER FORMAT "X(4)"
     LABEL "Вид"
      VIEW-AS TEXT
     SIZE 5 BY .67.
DEFINE VARIABLE FILL-IN_fact-date AS DATE FORMAT "99/99/9999"
     LABEL "Факт"
      VIEW-AS TEXT
     SIZE 11 BY .67.
DEFINE VARIABLE FILL-IN_fin-doc-type AS CHARACTER FORMAT "X(14)"
     LABEL "Тип"
      VIEW-AS TEXT
     SIZE 37.38 BY .67.
DEFINE VARIABLE FILL-IN_pay-date AS DATE FORMAT "99/99/9999"
     LABEL "Платеж"
      VIEW-AS TEXT
     SIZE 11 BY .67.
DEFINE VARIABLE FILL-IN_prn-doc-code AS CHARACTER FORMAT "X(16)"
     LABEL "№"
      VIEW-AS TEXT
     SIZE 17 BY .67.
DEFINE VARIABLE FILL-IN_srok-opl AS INTEGER FORMAT "->,>>>" INITIAL 0
      VIEW-AS TEXT
     SIZE 3.75 BY .67.
DEFINE VARIABLE FILL-IN_status_ AS CHARACTER FORMAT "X(8)"
     LABEL "Статус ФО"
      VIEW-AS TEXT
     SIZE 9 BY .67.
DEFINE VARIABLE FILL-IN_sum-doc AS DECIMAL FORMAT "->,>>>,>>>,>>>,>>9.99" INITIAL 0
     LABEL "Сумма"
      VIEW-AS TEXT
     SIZE 22 BY .67 TOOLTIP "Сумма в ценах документа".
DEFINE VARIABLE FILL-IN_sum-rubl AS DECIMAL FORMAT "->>>,>>>,>>9.99" INITIAL 0
     LABEL "Сумма "
      VIEW-AS TEXT
     SIZE 22 BY .67.
DEFINE VARIABLE FILL-IN_user-name-doc AS CHARACTER FORMAT "X(8)"
     LABEL "Создал"
      VIEW-AS TEXT
     SIZE 9 BY .67.
DEFINE VARIABLE FILL-IN_user-name-fact AS CHARACTER FORMAT "X(8)"
     LABEL "Закрыл"
      VIEW-AS TEXT
     SIZE 9 BY .67.
DEFINE VARIABLE FILL-IN_usl-opl AS CHARACTER FORMAT "X(40)"
     LABEL "Условия"
      VIEW-AS TEXT
     SIZE 40.63 BY .67.
DEFINE VARIABLE v-U-full AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 48 BY .67
     FGCOLOR 12  NO-UNDO.
DEFINE QUERY BROWSE-1 FOR
    fin-ob-trn,
    trn-doc,
    c-trn-doc,
    ord-doc,
    add-doc,
    ord-doc-rcv
    SCROLLING.
DEFINE BROWSE BROWSE-1
  QUERY BROWSE-1 NO-LOCK DISPLAY
      v-U @ v-U COLUMN-LABEL "У" FORMAT "x(1)":U
      fin-ob-trn.trn-doc-code COLUMN-LABEL "№ документа" FORMAT "X(14)":U
      fin-ob-trn.doc-code FORMAT "X(16)":U
      fin-ob-trn.sum-rubl COLUMN-LABEL "Сумма ФО" FORMAT "->,>>>,>>>,>>>,>>9.99":U
      WIDTH 12
      v-ext-doc-type @ v-ext-doc-type COLUMN-LABEL "Тип!документа" FORMAT "x(15)":U
      v-doc-date @ v-doc-date COLUMN-LABEL "Дата!документа" FORMAT "99/99/99":U
      v-fact-date @ v-fact-date COLUMN-LABEL "Факт" FORMAT "99/99/99":U
      v-cli-name @ v-cli-name COLUMN-LABEL "Контрагент" FORMAT "X(40)":U
            WIDTH 30
      v-fact-rubl @ v-fact-rubl COLUMN-LABEL "Сумма докум." FORMAT "->,>>>,>>>,>>>,>>9.99":U
      v-creid @ v-creid COLUMN-LABEL "Создал!документ" FORMAT "X(8)":U
      v-fact-time @ v-fact-time COLUMN-LABEL "Время" FORMAT "x(5)":U
    WITH NO-ROW-MARKERS SEPARATORS SIZE 94.5 BY 12.5.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     B-lkp AT ROW 1 COL 11
     B-lkp-2 AT ROW 1 COL 21
     B-lkp-3 AT ROW 1 COL 31
     B-Help AT ROW 1.04 COL 85.75
     BROWSE-1 AT ROW 2.25 COL 1
     var-ps AT ROW 18.5 COL 38.5 NO-LABEL
     FILL-IN-1 AT ROW 14.96 COL 1.38 NO-LABEL
     v-U-full AT ROW 15 COL 45 COLON-ALIGNED NO-LABEL
     FILL-IN_prn-doc-code AT ROW 15.71 COL 13.25 COLON-ALIGNED
     FILL-IN_status_ AT ROW 15.71 COL 42 COLON-ALIGNED
     FILL-IN_user-name-doc AT ROW 15.71 COL 65.5 COLON-ALIGNED
     FILL-IN_fin-doc-type AT ROW 16.63 COL 13.5 COLON-ALIGNED
     FILL-IN_user-name-fact AT ROW 16.63 COL 65.5 COLON-ALIGNED
     FILL-IN_doc-date AT ROW 17.54 COL 13.25 COLON-ALIGNED
     FILL-IN_fact-date AT ROW 17.54 COL 32.63 COLON-ALIGNED
     FILL-IN_pay-date AT ROW 18.38 COL 13.25 COLON-ALIGNED
     FILL-IN_curr-code AT ROW 19.25 COL 2.25 NO-LABEL
     FILL-IN_sum-doc AT ROW 19.29 COL 13.13 COLON-ALIGNED
     FILL-IN_sum-rubl AT ROW 20.17 COL 13.13 COLON-ALIGNED
     FILL-IN-2 AT ROW 20.88 COL 1.25 NO-LABEL
     FILL-IN_contract-prn-code AT ROW 21.58 COL 12.25 COLON-ALIGNED
     FILL-IN_doc-type AT ROW 21.58 COL 35.25 COLON-ALIGNED
     FILL-IN_contract-type AT ROW 22.46 COL 5.38 COLON-ALIGNED
     FILL-IN_usl-opl AT ROW 22.46 COL 36 COLON-ALIGNED
     FILL-IN-sr-op AT ROW 22.46 COL 77 COLON-ALIGNED NO-LABEL
     FILL-IN_srok-opl AT ROW 22.46 COL 89.13 COLON-ALIGNED NO-LABEL
     SPACE(0.87) SKIP(0.15)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Накладные по фин.обязательству".
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       BROWSE-1:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame     = 3.
ASSIGN
       var-ps:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-lkp IN FRAME Dialog-Frame
DO:
define variable v-r as recid no-undo .
if not available fin-ob-trn then return no-apply .
    case  fin-ob-trn.doc-type :
    when "" then do:
      find  first trn-doc  where trn-doc.doc-code = fin-ob-trn.trn-doc-code and fin-ob-trn.doc-type = ""  no-lock no-error .
      IF AVAILABLE trn-doc THEN
      run str/fishdoc.p (  parparentproc,
                    par-host-code ,
                    trn-doc.obj-type,
                    trn-doc.obj-code,
                    trn-doc.doc-code , ? ) .
      else do:
      find first c-trn-doc WHERE
                 c-trn-doc.is-del = yes and
                 c-trn-doc.doc-code = fin-ob-trn.trn-doc-code and fin-ob-trn.doc-type = "" no-lock no-error .
      if available c-trn-doc then do:
        run str/c-doc.w ( input parparentproc, input c-trn-doc.doc-code, input c-trn-doc.chip-num ).
      end.
                end.
    end.
    when "order" then do:
      find first ord-doc WHERE ord-doc.doc-code = fin-ob-trn.trn-doc-code and fin-ob-trn.doc-type = "order"    NO-LOCK no-error .
      if available ord-doc then do:
          run cus/show-ord.p ( input parParentProc, input recid(ord-doc) ).
      end.
    end.
    when "rcv" then do:
      find first ord-doc-rcv WHERE ord-doc-rcv.rcv-code = fin-ob-trn.trn-doc-code and fin-ob-trn.doc-type = "rcv" no-lock no-error .
      if available ord-doc-rcv then do:
          v-r = recid(ord-doc-rcv) .
          run cus/lkp-rcv.w (
              input parParentProc,
              input-output v-r
              ).
      end.
    end.
    when "add" then do:
        find first add-doc no-lock where add-doc.doc-code = fin-ob-trn.trn-doc-code and fin-ob-trn.doc-type = "add" no-error .
        if available add-doc then do:
          v-r = recid(add-doc) .
          run str/add-docu.w ( input parparentproc  ,
                               input-output v-r ,
                               input 'ПРОСМОТР':U  ,
                               input ?
                               ).
        end.
    end.
    end case.
END.
ON CHOOSE OF B-lkp-2 IN FRAME Dialog-Frame
DO:
   if not available  fin-ob-trn then return .
define variable p-doc-type   as character no-undo .
define variable  p-status_   as character no-undo .
define buffer buf_fin-ob   for fin-ob .
define buffer buf_fin-ob-before   for fin-ob-before  .
define variable g-log as logical no-undo .
define variable vss-include-info2 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_fin-liability_lookup':U
    ,input  'firm':U
    ,input  par-host-code
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g-log
    )  .
end.
if not g-log then  return .
define variable rr as recid no-undo .
find first buf_fin-ob no-lock where buf_fin-ob.doc-code = fin-ob-trn.doc-code no-error .
    if available buf_fin-ob then do:
        rr = recid( buf_fin-ob ).
        p-doc-type = buf_fin-ob.doc-type .
        p-status_  = buf_fin-ob.status_  .
        br-handle = ? .
        next-prev = ? .
        find first buf_fin-liab no-lock where recid(buf_fin-liab) = rr no-error .
        run str/fi-liabi.w ( parParentProc, 'ПРОСМОТР':U , input-output rr , input par-host-code  , input p-doc-type, input p-status_).
     end.
   else do:
      find first buf_fin-ob-before no-lock where buf_fin-ob-before.before-code = fin-ob-trn.doc-code no-error .
      if not available  buf_fin-ob-before  then return.
        rr = recid( buf_fin-ob-before ).
        p-doc-type = buf_fin-ob-before.doc-type .
        p-status_  = buf_fin-ob-before.status_  .
        br-handle = ? .
        next-prev = ? .
        find first buf_fin-liab-before no-lock where recid(buf_fin-liab-before) = rr no-error .
        run str/fi-liabb.w ( parParentProc, 'ПРОСМОТР':U , input-output rr , input par-host-code  , input p-doc-type, input p-status_).
        if br-handle = ? then reposition BROWSE-1 to recid rr no-error.
   end.
END.
ON CHOOSE OF B-lkp-3 IN FRAME Dialog-Frame
DO:
define buffer buf_fin-ob   for fin-ob .
define buffer buf_fin-ob-before   for fin-ob-before  .
define buffer b_contract for contract .
define variable loc_contract-code as integer no-undo .
if not available fin-ob-trn then return .
find first buf_fin-ob no-lock where buf_fin-ob.doc-code = fin-ob-trn.doc-code no-error .
if available buf_fin-ob then do:
      loc_contract-code = buf_fin-ob.contract-code .
end.
else do:
      find first buf_fin-ob-before no-lock where buf_fin-ob-before.before-code = fin-ob-trn.doc-code no-error .
      if not available  buf_fin-ob-before  then return.
      loc_contract-code = buf_fin-ob-before.contract-code .
end.
define variable ri as recid no-undo .
find first b_contract no-lock  where b_contract.contract-code = loc_contract-code and
                                     b_contract.host-code     = par-host-code
                                     no-error .
if error-status :error then return no-apply.
ri = recid (b_contract) .
run str/sh-contr.p (
  input   parParentProc ,
  input  ri      )
  .
END.
ON ROW-DISPLAY OF BROWSE-1 IN FRAME Dialog-Frame
DO:
define buffer buf1_fin-ob for ub.fin-ob  .
case  fin-ob-trn.doc-type :
when "" then do:
     find  first trn-doc  WHERE trn-doc.doc-code = fin-ob-trn.trn-doc-code and fin-ob-trn.doc-type = ""  no-lock no-error .
      IF AVAILABLE trn-doc THEN
          ASSIGN
          v-U = " "
          v-ext-doc-type = func-get-name-from-ext-type(trn-doc.ext-doc-type,no)
          v-doc-date  = trn-doc.doc-date
          v-fact-date = trn-doc.fact-date
          v-cli-name  = trn-doc.cli-name
          v-fact-qnty = trn-doc.doc-qnty
          v-fact-rubl = trn-doc.tot-fact
          v-creid     = trn-doc.creid
          v-fact-time =  string(trn-doc.fact-time,"hh:mm")
          .
  ELSE DO:
     find first c-trn-doc WHERE c-trn-doc.is-del = yes and c-trn-doc.doc-code = fin-ob-trn.trn-doc-code and fin-ob-trn.doc-type = "" no-lock no-error .
        IF AVAILABLE c-trn-doc THEN DO:
            ASSIGN
            v-U = "+"
            v-ext-doc-type = func-get-name-from-ext-type(c-trn-doc.ext-doc-type,no)
            v-doc-date  = c-trn-doc.doc-date
            v-fact-date = c-trn-doc.fact-date
            v-cli-name  = c-trn-doc.cli-name
            v-fact-qnty = c-trn-doc.doc-qnty
            v-fact-rubl = c-trn-doc.tot-fact
            v-creid     = c-trn-doc.creid
            v-fact-time =  string(c-trn-doc.fact-time,"hh:mm")
            .
        END.
    END.
end.
when "order" then do:
   find first ord-doc WHERE ord-doc.doc-code = fin-ob-trn.trn-doc-code and fin-ob-trn.doc-type = "order"    NO-LOCK no-error .
   if available ord-doc then
      ASSIGN
      v-U = " "
      v-ext-doc-type = 'заказ':U
      v-doc-date  = ord-doc.doc-date
      v-fact-date = ord-doc.fact-date
      v-cli-name  = ord-doc.cli-name
      v-fact-qnty = ord-doc.qnty
      v-fact-rubl = ord-doc.sum-rubl
      v-creid     = ord-doc.creid
      v-fact-time =  string(ord-doc.fact-time,"hh:mm")
      .
end.
when "rcv" then do:
   find    first ord-doc-rcv WHERE ord-doc-rcv.rcv-code = fin-ob-trn.trn-doc-code and fin-ob-trn.doc-type = "rcv" no-lock no-error .
      if available ord-doc-rcv then
      ASSIGN
      v-U = " "
      v-ext-doc-type = 'поставка':U
      v-doc-date  = ord-doc-rcv.doc-date
      v-fact-date = ord-doc-rcv.fact-date
      v-creid     = ord-doc-rcv.creid
      v-fact-time =  string(ord-doc-rcv.fact-time,"hh:mm")      .
      define buffer buf_clients for ub.clients  .
      define buffer buf_ord-line-rcv for ub.ord-line-rcv  .
      find first buf_clients no-lock where buf_clients.obj-code =   ord-doc-rcv.cli-code and
                                           buf_clients.obj-type =   ord-doc-rcv.cli-type no-error .
      if available buf_clients then v-cli-name = buf_clients.obj-name .
                               else v-cli-name = "".
      v-fact-qnty = 0 .
      v-fact-rubl = 0 .
       for each buf_ord-line-rcv no-lock where buf_ord-line-rcv.rcv-code = ord-doc-rcv.rcv-code and
                                               buf_ord-line-rcv.doc-code = ord-doc-rcv.doc-code :
              v-fact-qnty = v-fact-qnty +  buf_ord-line-rcv.qnty .
              v-fact-rubl = v-fact-rubl +  buf_ord-line-rcv.sum-rubl .
       end.
end.
when "add" then do:
   find first add-doc no-lock where
              add-doc.doc-code    =  fin-ob-trn.trn-doc-code and
              fin-ob-trn.doc-type =  "add"
              no-error .
   find first buf1_fin-ob no-lock where
              buf1_fin-ob.doc-code    =  fin-ob-trn.doc-code and
              fin-ob-trn.doc-type =  "add"
              no-error .
   if not available buf1_fin-ob then do:
      message
        error-status :get-message(1) skip
        return-value skip
        "Не найдено ФО"
        view-as alert-box error
      .
   end.
   if available add-doc then do:
      assign
        v-u = " "
        v-ext-doc-type = 'ДопРасход'
        v-doc-date  = add-doc.doc-date
        v-fact-date = add-doc.fact-date
        v-cli-name  = buf1_fin-ob.receiver-name
        v-fact-qnty = ?
        v-fact-rubl = add-doc.sum-rubl
        v-creid     = add-doc.creid
        v-fact-time =  string(add-doc.fact-time,"hh:mm")
        .
    end.
    else do:
      find first c-add-doc WHERE c-add-doc.doc-code = fin-ob-trn.trn-doc-code and fin-ob-trn.doc-type = "add" and c-add-doc.is-del = true    NO-LOCK no-error .
      if available c-add-doc then do:
      assign
        v-doc-date  = c-add-doc.doc-date
        v-fact-date = c-add-doc.fact-date
        v-fact-rubl = c-add-doc.sum-rubl
        v-creid     = c-add-doc.creid
        v-fact-time =  string(c-add-doc.fact-time,"hh:mm")
        .
       end.
       Assign
        v-U = " "
        v-ext-doc-type = 'ДопРасх-УДАЛЕН'
        v-cli-name  = '---'
        v-fact-qnty = 0
        .
    end.
end.
end case.
END.
ON VALUE-CHANGED OF BROWSE-1 IN FRAME Dialog-Frame
DO:
if not available fin-ob-trn  then return.
define buffer buf_fin-ob   for fin-ob .
define buffer buf_fin-ob-before   for fin-ob-before  .
define buffer buf_contract for contract .
define variable v-contract as integer no-undo .
find first buf_fin-ob no-lock where buf_fin-ob.doc-code = fin-ob-trn.doc-code no-error .
if available buf_fin-ob then do:
      v-contract = buf_fin-ob.contract-code .
      assign
        FILL-IN_curr-code      = sel-abbr(buf_fin-ob.curr-code)
        FILL-IN_doc-date       = buf_fin-ob.doc-date
        FILL-IN_fact-date      = buf_fin-ob.fact-date
        FILL-IN_fin-doc-type   = if buf_fin-ob.doc-type = 'при':U then "с покупателем" else "с поставщиком"
        FILL-IN_pay-date       = buf_fin-ob.pay-date
        FILL-IN_prn-doc-code   = buf_fin-ob.prn-doc-code
        FILL-IN_status_        = buf_fin-ob.status_
        FILL-IN_sum-rubl       = buf_fin-ob.sum-rubl
        FILL-IN_user-name-doc  = buf_fin-ob.user-name-doc
        FILL-IN_user-name-fact = buf_fin-ob.user-name-fact
        FILL-IN_sum-doc        = buf_fin-ob.sum-doc
        var-ps =                 buf_fin-ob.PS
      .
   end.
   else do:
      find first buf_fin-ob-before no-lock where buf_fin-ob-before.before-code = fin-ob-trn.doc-code no-error .
      if not available  buf_fin-ob-before  then return.
      v-contract = buf_fin-ob-before.contract-code .
      assign
        FILL-IN_curr-code      = sel-abbr(buf_fin-ob-before.curr-code)
        FILL-IN_doc-date       = buf_fin-ob-before.doc-date
        FILL-IN_fact-date      = buf_fin-ob-before.fact-date
        FILL-IN_fin-doc-type   = "ПФО"
        FILL-IN_pay-date       = buf_fin-ob-before.pay-date
        FILL-IN_prn-doc-code   = buf_fin-ob-before.prn-doc-code
        FILL-IN_status_        = buf_fin-ob-before.status_
        FILL-IN_sum-rubl       = buf_fin-ob-before.sum-rubl
        FILL-IN_user-name-doc  = buf_fin-ob-before.user-name-doc
        FILL-IN_user-name-fact = buf_fin-ob-before.user-name-fact
        FILL-IN_sum-doc        = buf_fin-ob-before.sum-doc
        var-ps =                 buf_fin-ob-before.PS
      .
   end.
define variable vss-include-info3 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usrfulnm in g#library
  (input  FILL-IN_user-name-doc
  ,output FILL-IN_user-name-doc
  )  .
define variable vss-include-info4 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usrfulnm in g#library
  (input  FILL-IN_user-name-fact
  ,output FILL-IN_user-name-fact
  )  .
  find first buf_contract no-lock where  buf_contract.contract-code  =  v-contract  no-error .
    if not available buf_contract then return .
  assign
    FILL-IN_contract-prn-code  = buf_contract.contract-prn-code
    FILL-IN_contract-type      = buf_contract.contract-type
    FILL-IN_usl-opl            = buf_contract.usl-opl
    FILL-IN_srok-opl           = buf_contract.srok-opl
    FILL-IN_doc-type           = buf_contract.doc-type
  .
 if  buf_contract.usl-opl  = 'По реализации части приход. накладной':U or
     buf_contract.usl-opl  = 'Предоплата(%)':U
     then do:
     FILL-IN-sr-op = "        % :".
 end.
 else do:
    FILL-IN-sr-op = "Срок оплаты:".
 end.
 display
  FILL-IN_contract-prn-code FILL-IN_contract-type FILL-IN_curr-code FILL-IN_doc-date FILL-IN_doc-type FILL-IN_fact-date FILL-IN_fin-doc-type FILL-IN_pay-date FILL-IN_prn-doc-code FILL-IN_srok-opl FILL-IN_status_ FILL-IN_sum-rubl FILL-IN_user-name-doc FILL-IN_user-name-fact FILL-IN_usl-opl
  FILL-IN_sum-doc  FILL-IN-sr-op var-ps
  with frame Dialog-Frame.
 if fin-ob-trn.doc-type = "" then do:
    IF AVAILABLE c-trn-doc THEN DO:
        ASSIGN
          v-U-full = "Накладная УДАЛЕНА !!!"
        .
    END.
    ELSE DO:
        ASSIGN
          v-U-full = ""
        .
    END.
    DISPLAY v-U-full WITH FRAME Dialog-Frame.
  end.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
        v-diasize-browse-handle     = browse BROWSE-1 :handle
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
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  FILL-IN_sum-rubl:label = "Сумма (руб)" .
  case p-mode :
    when "all":U then do:
      message "НЕ РЕАЛИЗОВАНО".
      return .
    end.
    when "fin-ob":U then do:
       RUN enable_UI.
    end.
    when "trn-doc":U then do:
       RUN enable-my.
    end.
    when "order":U then do:
       RUN enable-my-order.
    end.
    when "rcv":U then do:
       RUN enable-my-rcv.
    end.
    when "add":U then do:
       RUN enable-my-add.
    end.
  end case.
  apply "VALUE-CHANGED" TO BROWSE-1 IN FRAME  Dialog-Frame.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable-my :
 do
 on error undo, return error return-value
 :
  DISPLAY FILL-IN-1 FILL-IN_prn-doc-code FILL-IN_status_ FILL-IN_user-name-doc
          FILL-IN_fin-doc-type FILL-IN_user-name-fact FILL-IN_doc-date
          FILL-IN_fact-date FILL-IN_pay-date FILL-IN_curr-code FILL-IN_sum-doc
          FILL-IN_sum-rubl FILL-IN-2 FILL-IN_contract-prn-code FILL-IN_doc-type
          FILL-IN_contract-type FILL-IN_usl-opl FILL-IN_srok-opl FILL-IN-sr-op
      WITH FRAME Dialog-Frame.
  ENABLE B-exit B-lkp B-lkp-2 B-lkp-3 B-Help BROWSE-1 FILL-IN-1
         FILL-IN_prn-doc-code FILL-IN_status_ FILL-IN_user-name-doc
         FILL-IN_fin-doc-type FILL-IN_user-name-fact FILL-IN_doc-date
         FILL-IN_fact-date FILL-IN_pay-date FILL-IN_curr-code FILL-IN_sum-doc
         FILL-IN_sum-rubl FILL-IN-2 FILL-IN_contract-prn-code FILL-IN_doc-type
         FILL-IN_contract-type FILL-IN_usl-opl FILL-IN_srok-opl FILL-IN-sr-op
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
 ASSIGN
 frame Dialog-Frame:TITLE = "Фин. обязательства по накладной: " +  p-fin-ob-trn-doc
 .
 OPEN QUERY BROWSE-1 FOR EACH fin-ob-trn
      WHERE fin-ob-trn.trn-doc-code = p-fin-ob-trn-doc   AND ub.fin-ob-trn.doc-type  = ""  NO-LOCK,
      EACH trn-doc WHERE trn-doc.doc-code = fin-ob-trn.trn-doc-code   OUTER-JOIN NO-LOCK,
      EACH c-trn-doc WHERE c-trn-doc.is-del = yes and  c-trn-doc.doc-code = fin-ob-trn.trn-doc-code  OUTER-JOIN NO-LOCK,
      first ord-doc OUTER-JOIN no-lock ,
      first add-doc OUTER-JOIN no-lock ,
      first ord-doc-rcv OUTER-JOIN no-lock .
  end.
END PROCEDURE.
PROCEDURE enable-my-order :
 do
 on error undo, return error return-value
 :
  DISPLAY FILL-IN-1 FILL-IN_prn-doc-code FILL-IN_status_ FILL-IN_user-name-doc
          FILL-IN_fin-doc-type FILL-IN_user-name-fact FILL-IN_doc-date
          FILL-IN_fact-date FILL-IN_pay-date FILL-IN_curr-code FILL-IN_sum-doc
          FILL-IN_sum-rubl FILL-IN-2 FILL-IN_contract-prn-code FILL-IN_doc-type
          FILL-IN_contract-type FILL-IN_usl-opl FILL-IN_srok-opl FILL-IN-sr-op
      WITH FRAME Dialog-Frame.
  ENABLE B-exit B-lkp B-lkp-2 B-lkp-3 B-Help BROWSE-1 FILL-IN-1
         FILL-IN_prn-doc-code FILL-IN_status_ FILL-IN_user-name-doc
         FILL-IN_fin-doc-type FILL-IN_user-name-fact FILL-IN_doc-date
         FILL-IN_fact-date FILL-IN_pay-date FILL-IN_curr-code FILL-IN_sum-doc
         FILL-IN_sum-rubl FILL-IN-2 FILL-IN_contract-prn-code FILL-IN_doc-type
         FILL-IN_contract-type FILL-IN_usl-opl FILL-IN_srok-opl FILL-IN-sr-op
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
 ASSIGN
 frame Dialog-Frame:TITLE = "Фин. обязательства по заказу: " +  p-fin-ob-trn-doc
 v-fact-rubl:label in browse BROWSE-1  = "По заказу (рубл)"
 ub.fin-ob-trn.trn-doc-code:label = "№ заказа"
 B-lkp:label = "&Заказ"
 B-lkp:tooltip = "Просмотр Заказа"
 .
 OPEN QUERY BROWSE-1 FOR EACH fin-ob-trn
      WHERE fin-ob-trn.trn-doc-code = p-fin-ob-trn-doc  and fin-ob-trn.doc-type = "order"
      NO-LOCK,
      first trn-doc no-lock OUTER-JOIN,
      first c-trn-doc no-lock OUTER-JOIN,
      EACH ord-doc WHERE ord-doc.doc-code = fin-ob-trn.trn-doc-code OUTER-JOIN NO-LOCK,
      first add-doc  OUTER-JOIN NO-LOCK,
      first ord-doc-rcv no-lock OUTER-JOIN
      .
  end.
END PROCEDURE.
PROCEDURE enable-my-rcv :
 do
 on error undo, return error return-value
 :
  DISPLAY FILL-IN-1 FILL-IN_prn-doc-code FILL-IN_status_ FILL-IN_user-name-doc
          FILL-IN_fin-doc-type FILL-IN_user-name-fact FILL-IN_doc-date
          FILL-IN_fact-date FILL-IN_pay-date FILL-IN_curr-code FILL-IN_sum-doc
          FILL-IN_sum-rubl FILL-IN-2 FILL-IN_contract-prn-code FILL-IN_doc-type
          FILL-IN_contract-type FILL-IN_usl-opl FILL-IN_srok-opl FILL-IN-sr-op
      WITH FRAME Dialog-Frame.
  ENABLE B-exit B-lkp B-lkp-2 B-lkp-3 B-Help BROWSE-1 FILL-IN-1
         FILL-IN_prn-doc-code FILL-IN_status_ FILL-IN_user-name-doc
         FILL-IN_fin-doc-type FILL-IN_user-name-fact FILL-IN_doc-date
         FILL-IN_fact-date FILL-IN_pay-date FILL-IN_curr-code FILL-IN_sum-doc
         FILL-IN_sum-rubl FILL-IN-2 FILL-IN_contract-prn-code FILL-IN_doc-type
         FILL-IN_contract-type FILL-IN_usl-opl FILL-IN_srok-opl FILL-IN-sr-op
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
 ASSIGN
 frame Dialog-Frame:TITLE = "Фин. обязательства по поставке: " +  p-fin-ob-trn-doc
 v-fact-rubl:label in browse BROWSE-1  = "По поставке (рубл)"
 ub.fin-ob-trn.trn-doc-code:label = "№ поставки"
 B-lkp:label = "&Поставка"
 B-lkp:tooltip = "Просмотр Поставки по заказу"
 .
 OPEN QUERY BROWSE-1 FOR EACH fin-ob-trn
      WHERE fin-ob-trn.trn-doc-code = p-fin-ob-trn-doc  and fin-ob-trn.doc-type = "rcv"
      NO-LOCK,
      first trn-doc no-lock OUTER-JOIN,
      first c-trn-doc no-lock OUTER-JOIN,
      first ord-doc no-lock OUTER-JOIN,
      first add-doc no-lock OUTER-JOIN,
      EACH ord-doc-rcv WHERE ord-doc-rcv.rcv-code = fin-ob-trn.trn-doc-code OUTER-JOIN NO-LOCK
      .
  end.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY var-ps FILL-IN-1 v-U-full FILL-IN_prn-doc-code FILL-IN_status_
          FILL-IN_user-name-doc FILL-IN_fin-doc-type FILL-IN_user-name-fact
          FILL-IN_doc-date FILL-IN_fact-date FILL-IN_pay-date FILL-IN_curr-code
          FILL-IN_sum-doc FILL-IN_sum-rubl FILL-IN-2 FILL-IN_contract-prn-code
          FILL-IN_doc-type FILL-IN_contract-type FILL-IN_usl-opl FILL-IN-sr-op
          FILL-IN_srok-opl
      WITH FRAME Dialog-Frame.
  ENABLE B-exit B-lkp B-lkp-2 B-lkp-3 B-Help BROWSE-1 var-ps FILL-IN-1 v-U-full
         FILL-IN_prn-doc-code FILL-IN_status_ FILL-IN_user-name-doc
         FILL-IN_fin-doc-type FILL-IN_user-name-fact FILL-IN_doc-date
         FILL-IN_fact-date FILL-IN_pay-date FILL-IN_curr-code FILL-IN_sum-doc
         FILL-IN_sum-rubl FILL-IN-2 FILL-IN_contract-prn-code FILL-IN_doc-type
         FILL-IN_contract-type FILL-IN_usl-opl FILL-IN-sr-op FILL-IN_srok-opl
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY BROWSE-1 FOR EACH fin-ob-trn WHERE                                  fin-ob-trn.doc-code = p-fin-ob-doc-code  NO-LOCK,              EACH trn-doc WHERE            trn-doc.doc-code = fin-ob-trn.trn-doc-code AND            fin-ob-trn.doc-type  = ""  OUTER-JOIN NO-LOCK,              EACH c-trn-doc WHERE            c-trn-doc.doc-code = fin-ob-trn.trn-doc-code and            c-trn-doc.is-del = yes AND            fin-ob-trn.doc-type  = "" OUTER-JOIN NO-LOCK,              FIRST ord-doc WHERE             ord-doc.doc-code = fin-ob-trn.trn-doc-code AND             fin-ob-trn.doc-type  = "order" OUTER-JOIN NO-LOCK,              FIRST add-doc WHERE             add-doc.doc-code = fin-ob-trn.trn-doc-code AND             fin-ob-trn.doc-type  = "add" OUTER-JOIN NO-LOCK,               FIRST ord-doc-rcv WHERE             ord-doc-rcv.rcv-code = fin-ob-trn.trn-doc-code AND             fin-ob-trn.doc-type  = "rcv" OUTER-JOIN NO-LOCK.
END PROCEDURE.
FUNCTION sel-abbr RETURNS CHARACTER
 ( p-curr-code as int ) :
  define variable rr as character no-undo .
  find first currency no-lock where  currency.curr-code  = p-curr-code no-error.
  rr = currency.curr-abbr .
  RETURN rr.
END FUNCTION.
PROCEDURE enable-my-add :
 do
 on error undo, return error return-value
 :
  DISPLAY FILL-IN-1 FILL-IN_prn-doc-code FILL-IN_status_ FILL-IN_user-name-doc
          FILL-IN_fin-doc-type FILL-IN_user-name-fact FILL-IN_doc-date
          FILL-IN_fact-date FILL-IN_pay-date FILL-IN_curr-code FILL-IN_sum-doc
          FILL-IN_sum-rubl FILL-IN-2 FILL-IN_contract-prn-code FILL-IN_doc-type
          FILL-IN_contract-type FILL-IN_usl-opl FILL-IN_srok-opl FILL-IN-sr-op
      WITH FRAME Dialog-Frame.
  ENABLE B-exit B-lkp B-lkp-2 B-lkp-3 B-Help BROWSE-1 FILL-IN-1
         FILL-IN_prn-doc-code FILL-IN_status_ FILL-IN_user-name-doc
         FILL-IN_fin-doc-type FILL-IN_user-name-fact FILL-IN_doc-date
         FILL-IN_fact-date FILL-IN_pay-date FILL-IN_curr-code FILL-IN_sum-doc
         FILL-IN_sum-rubl FILL-IN-2 FILL-IN_contract-prn-code FILL-IN_doc-type
         FILL-IN_contract-type FILL-IN_usl-opl FILL-IN_srok-opl FILL-IN-sr-op
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
 ASSIGN
 frame Dialog-Frame:TITLE = "Фин. обязательства по ДопРасходу: " +  p-fin-ob-trn-doc
 v-fact-rubl:label in browse BROWSE-1  = "по ДопРасходу (рубл)"
 ub.fin-ob-trn.trn-doc-code:label = "№ ДопРасхода"
 B-lkp:label = "&ДопРасход"
 B-lkp:tooltip = "Просмотр ДопРасхода"
 .
 OPEN QUERY BROWSE-1 FOR EACH fin-ob-trn
      WHERE fin-ob-trn.trn-doc-code = p-fin-ob-trn-doc  and fin-ob-trn.doc-type = "add" NO-LOCK,
      first trn-doc no-lock OUTER-JOIN,
      first c-trn-doc no-lock OUTER-JOIN,
      first ord-doc no-lock OUTER-JOIN,
      EACH add-doc WHERE add-doc.doc-code = fin-ob-trn.trn-doc-code OUTER-JOIN NO-LOCK,
      first ord-doc-rcv no-lock OUTER-JOIN
      .
  end.
END PROCEDURE.
