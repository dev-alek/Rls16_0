block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-doc-rec as recid no-undo .
define input parameter p-gds-rec as recid no-undo .
define input parameter parb-c  like ub.bar-code.b-code no-undo.
define input parameter parqnty as decimal           no-undo.
define variable vss-revision    as character no-undo init "$revision: 12 $":u .
define variable vss-author      as character no-undo init "$author: suslov $":u .
define variable vss-date        as character no-undo init "$date: 6.03.02 10:33 $":u .
define variable vss-workfile    as character no-undo init "$workfile: copy-tmp.p $":u .
define variable vss-archive     as character no-undo init "$archive: /ver12_0/str/copy-tmp.p $":u .
define variable vss-description as character no-undo init "Добавление в строку накладной количества по строке и признаку методом копирования.".
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
  define temp-table  tt-tax no-undo
field tax-code    like ub.tax.tax-code
FIELD individual  like ub.tax.individual
FIELD tax-name    like ub.tax.tax-name format "X(12)" column-label "Налог"
field rate-code   like ub.tax-rate.rate-code
FIELD rate-name   like ub.tax-rate.rate-name FORMAT "X(12)"
FIELD tax-type    like ub.tax.tax-type
field rate-value  like ub.tax-rate-value.rate-value
FIELD tax-rate-gds-rc  as recid
FIELD to-cashdesk like ub.tax.to-cashdesk
index tax-code is unique primary tax-code.
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define variable vss-include-info0 as character format "X(65)":U no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE VARIABLE v-S_CONTRACT               AS CHARACTER NO-UNDO INITIAL "".
DEFINE VARIABLE v-S_CODE_LAST_MASTER_NUM   AS CHARACTER NO-UNDO INITIAL "".
DEFINE VARIABLE v-DELIM_CHR_3              AS CHARACTER NO-UNDO INITIAL "".
ASSIGN
   v-S_CONTRACT                = "Contract":U
   v-S_CODE_LAST_MASTER_NUM    = "LastMasterNum":U
   v-DELIM_CHR_3               = ","
   .
DEFINE VARIABLE i-gl-Host-Code      AS INTEGER NO-UNDO INITIAL 0.
DEFINE VARIABLE i-gl-Contract-Code  AS INTEGER NO-UNDO INITIAL 0.
DEFINE VARIABLE i-gl-Extent3        AS INTEGER NO-UNDO INITIAL 0 EXTENT 3.
FUNCTION Can-Find-Spec RETURN LOGICAL (
   INPUT iHost-Code    AS INTEGER,
   INPUT iContract-Num AS INTEGER,
   INPUT iGds-Code     AS INTEGER ):
   DEFINE BUFFER buf_Spec FOR ub.Contract-Specif.
   DEFINE VARIABLE iTmp-Host-Code     AS INTEGER NO-UNDO INITIAL 0.
   DEFINE VARIABLE iTmp-Contract-Num  AS INTEGER NO-UNDO INITIAL 0.
   DEFINE VARIABLE iTmp-Extent3       AS INTEGER NO-UNDO INITIAL 0 EXTENT 3.
   DEFINE VARIABLE lRet               AS LOGICAL NO-UNDO INITIAL FALSE.
   RUN MS-Contract-EXTENT-3 IN THIS-PROCEDURE(
       INPUT  iHost-Code,
       INPUT  iContract-Num,
       OUTPUT iTmp-Extent3
       ).
   IF iTmp-Extent3[1] = 2 THEN DO:
      ASSIGN
         iTmp-Host-Code      = iTmp-Extent3[2]
         iTmp-Contract-Num   = iTmp-Extent3[3]
         .
   END. ELSE DO:
      ASSIGN
         iTmp-Host-Code      = iHost-Code
         iTmp-Contract-Num   = iContract-Num
         .
   END.
   IF iGds-Code = ? THEN DO:
      ASSIGN
         lRet = CAN-FIND(FIRST buf_Spec NO-LOCK WHERE
                               buf_Spec.Host-Code     = iTmp-Host-Code
                           AND buf_Spec.Contract-Num  = iTmp-Contract-Num
                        ).
   END. ELSE DO:
         lRet = CAN-FIND(FIRST buf_Spec NO-LOCK WHERE
                               buf_Spec.Host-Code     = iTmp-Host-Code
                           AND buf_Spec.Contract-Num  = iTmp-Contract-Num
                           AND buf_Spec.Gds-Code      = iGds-Code
                         ).
   END.
   RETURN (lRet).
END FUNCTION.
PROCEDURE MS-Contract-EXTENT-3:
   DEFINE INPUT  PARAMETER i-Host-Code     AS INTEGER NO-UNDO.
   DEFINE INPUT  PARAMETER i-Contract-Code AS INTEGER NO-UNDO.
   DEFINE OUTPUT PARAMETER i-Ret           AS INTEGER NO-UNDO EXTENT 3 INITIAL 0.
   DEFINE BUFFER buf_Ext-Classif FOR ub.Ext-Classif.
   DEFINE BUFFER buf_Cont        FOR ub.Contract.
   DEFINE BUFFER buf_Cont-2      FOR ub.Contract.
   FIND FIRST buf_Cont-2 WHERE
              buf_Cont-2.Host-Code      = i-Host-Code
          AND buf_Cont-2.Contract-Code  = i-Contract-Code
        NO-LOCK NO-ERROR.
   IF NOT AVAILABLE buf_Cont-2 THEN DO:
      RETURN.
   END.
   FOR FIRST buf_Ext-Classif WHERE
             buf_Ext-Classif.Classif-name = v-S_CONTRACT
        AND  buf_Ext-Classif.CharKey_One  = STRING(i-Host-code) + v-DELIM_CHR_3 +
                                            STRING(i-Contract-code)
        AND  buf_Ext-classif.db-num       = buf_Cont-2.Db-num
       NO-LOCK,
       EACH buf_Cont WHERE
            buf_Cont.Host-code     = INTEGER(ENTRY(1, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3 ))
        AND buf_Cont.Contract-code = INTEGER(ENTRY(2, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3))
       NO-LOCK:
       ASSIGN
          i-Ret[1] = 1
          i-Ret[2] = buf_Cont.Host-code
          i-Ret[3] = buf_Cont.Contract-code
          .
       LEAVE.
   END.
   IF i-Ret[1] <> 1 THEN DO:
      FOR FIRST buf_Ext-Classif WHERE
                buf_Ext-Classif.Classif-name = v-S_CONTRACT
           AND  buf_Ext-Classif.CharKey_Two  = STRING(i-Host-code) + v-DELIM_CHR_3 +
                                               STRING(i-Contract-code)
           AND  buf_Ext-classif.db-num       = buf_Cont-2.Db-num
          NO-LOCK,
          EACH buf_Cont WHERE
               buf_Cont.Host-code     = INTEGER(ENTRY(1, buf_Ext-classif.charKey_One, v-DELIM_CHR_3))
           AND buf_Cont.Contract-code = INTEGER(ENTRY(2, buf_Ext-classif.charKey_One, v-DELIM_CHR_3))
          NO-LOCK:
          ASSIGN
             i-Ret[1] = 2
             i-Ret[2] = buf_Cont.Host-code
             i-Ret[3] = buf_Cont.Contract-code
             .
          LEAVE.
      END.
   END.
   RETURN.
END PROCEDURE.
procedure cpprclig :
  define input        parameter pardoc-code       as   character                  no-undo.
  define input        parameter parcli-code       like ub.trn-doc.cli-code        no-undo.
  define input        parameter parcli-type       like ub.trn-doc.cli-type        no-undo.
  define input        parameter parhost-code      like ub.trn-doc.host-code       no-undo.
  define input        parameter parbase-rate      like ub.trn-doc.base-rate       no-undo.
  define input        parameter parbase-scale     like ub.trn-doc.base-scale      no-undo.
  define input        parameter parexch-rate      like ub.trn-doc.exch-rate       no-undo.
  define input        parameter parexch-scale     like ub.trn-doc.exch-scale      no-undo.
  define input        parameter parvat-type       like ub.trn-doc.vat-type        no-undo.
  define input        parameter parslt-type       like ub.trn-doc.slt-type        no-undo.
  define input        parameter parartic          like ub.doc-line.artic          no-undo.
  define input        parameter parprod-type      like ub.doc-line.prod-type      no-undo.
  define input        parameter parprod-code      like ub.doc-line.prod-code      no-undo.
  define input        parameter paris-cli-tax     as   logical                    no-undo.
  define input        parameter parcli-base-rate  like ub.doc-line.cli-base-rate  no-undo.
  define input        parameter partransport-rubl like ub.doc-line.transport-rubl no-undo.
  define input        parameter parother-rubl     like ub.doc-line.other-rubl     no-undo.
  define output       parameter parprice-cli      like ub.doc-line.price-cli      no-undo.
  define output       parameter parprice-base     like ub.doc-line.price-base     no-undo.
  define output       parameter parprice-rubl     like ub.doc-line.price-rubl     no-undo.
  define input-output parameter parvat-pc         like ub.doc-line.vat-pc         no-undo.
  define input-output parameter parslt-pc         like ub.doc-line.slt-pc         no-undo.
  define input-output parameter parroad-tax       like ub.doc-line.road-tax       no-undo.
  define input-output parameter parexcise         like ub.doc-line.excise         no-undo.
  define variable varprice-cli                like ub.doc-line.price-rubl no-undo.
  define variable varprice-cli-unit-base      like ub.doc-line.price-rubl no-undo.
  define variable varprice-road-tax           like ub.doc-line.price-rubl no-undo.
  define variable varprice-other-exp          like ub.doc-line.price-rubl no-undo.
  define variable varprice-transport-exp      like ub.doc-line.price-rubl no-undo.
  define variable varprice-without-abs        like ub.doc-line.price-rubl no-undo.
  define variable varprice-slt                like ub.doc-line.price-rubl no-undo.
  define variable varprice-no-slt             like ub.doc-line.price-rubl no-undo.
  define variable varprice-vat                like ub.doc-line.price-rubl no-undo.
  define variable varprice-no-vat-slt         like ub.doc-line.price-rubl no-undo.
  define variable varprice-rubl               like ub.doc-line.price-rubl no-undo.
  define variable varprice-road-tax-rubl      like ub.doc-line.price-rubl no-undo.
  define variable varprice-other-exp-rubl     like ub.doc-line.price-rubl no-undo.
  define variable varprice-transport-exp-rubl like ub.doc-line.price-rubl no-undo.
  define variable varprice-without-abs-rubl   like ub.doc-line.price-rubl no-undo.
  define variable varprice-slt-rubl           like ub.doc-line.price-rubl no-undo.
  define variable varprice-no-slt-rubl        like ub.doc-line.price-rubl no-undo.
  define variable varprice-vat-rubl           like ub.doc-line.price-rubl no-undo.
  define variable varprice-no-vat-slt-rubl    like ub.doc-line.price-rubl no-undo.
  define variable varprice-base               like ub.doc-line.price-base no-undo.
  define variable varprice-road-tax-base      like ub.doc-line.price-base no-undo.
  define variable varprice-other-exp-base     like ub.doc-line.price-base no-undo.
  define variable varprice-transport-exp-base like ub.doc-line.price-base no-undo.
  define variable varprice-without-abs-base   like ub.doc-line.price-base no-undo.
  define variable varprice-slt-base           like ub.doc-line.price-base no-undo.
  define variable varprice-no-slt-base        like ub.doc-line.price-base no-undo.
  define variable varprice-vat-base           like ub.doc-line.price-base no-undo.
  define variable varprice-no-vat-slt-base    like ub.doc-line.price-base no-undo.
  define variable v-specif-found              as   logical                no-undo.
  define variable v-rcv-found                 as   logical                no-undo .
  define buffer bf_cli-gds         for ub.cli-gds .
  define buffer bf_doc-line        for ub.doc-line.
  define buffer bf_trn-doc         for ub.trn-doc.
  define buffer bf_goods           for ub.goods.
  define buffer bf_contract-specif for ub.contract-specif.
  define buffer buf_ord-chain      for ub.ord-chain .
  define buffer buf_ord-doc-rcv    for ub.ord-doc-rcv .
  define buffer buf_ord-line-rcv   for ub.ord-line-rcv .
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-include-info0, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1. stop", vss-include-info0 )
  on endkey undo, return error substitute( "&1. endkey", vss-include-info0 )
  :
    assign
      v-rcv-found    = false
      v-specif-found = false
    .
    find first buf_ord-chain no-lock
      where buf_ord-chain.rel-doc-code =  pardoc-code
        and buf_ord-chain.rel-doc-type = 'trn':u
      no-error .
    if available buf_ord-chain then do:
      find first buf_ord-doc-rcv no-lock
        where buf_ord-doc-rcv.rcv-code = buf_ord-chain.doc-code
      no-error .
      if available buf_ord-doc-rcv then do:
        find first buf_ord-line-rcv no-lock
          where buf_ord-line-rcv.doc-code  = buf_ord-doc-rcv.doc-code
            and buf_ord-line-rcv.artic     = parartic
            and buf_ord-line-rcv.prod-type = parprod-type
            and buf_ord-line-rcv.prod-code = parprod-code
          no-error .
        if available buf_ord-line-rcv then do:
          find first bf_trn-doc  no-lock
            where bf_trn-doc.doc-code = pardoc-code
          .
          assign
            parprice-cli = buf_ord-line-rcv.price-cli
            parroad-tax  = buf_ord-line-rcv.road-tax
            parexcise    = buf_ord-line-rcv.excise
            v-rcv-found  = true
            .
          if parslt-type <> 'без':U then do:
            if bf_trn-doc.slt-type <> 'без':U then do:
              assign
                parslt-pc = buf_ord-line-rcv.slt-pc
              .
            end.
          end.
          else do:
            assign
              parslt-pc = 0
            .
          end.
          if parvat-type <> 'без':U then do:
            if bf_trn-doc.vat-type <> 'без':U then do:
              assign
                parvat-pc = buf_ord-line-rcv.vat-pc
              .
            end.
          end.
          else do:
            assign
              parvat-pc = 0
            .
          end.
        end.
      end.
    end.
    if v-rcv-found = false then do:
      find first bf_trn-doc no-lock
        where bf_trn-doc.doc-code = pardoc-code
        no-error.
      if available bf_trn-doc
        and bf_trn-doc.contract-code <> 0
      then do:
        find first bf_goods no-lock
          where bf_goods.artic     = parartic
            and bf_goods.prod-code = parprod-code
            and bf_goods.prod-type = parprod-type
          no-error.
        if available bf_goods then do:
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ASSIGN
   i-gl-Host-Code      = 0
   i-gl-Contract-Code  = 0
   i-gl-Extent3        = 0
   .
RUN MS-Contract-EXTENT-3 IN THIS-PROCEDURE(
    INPUT  bf_trn-doc.host-code,
    INPUT  bf_trn-doc.contract-code,
    OUTPUT i-gl-Extent3
   ).
IF i-gl-Extent3[1] = 2 THEN DO:
   ASSIGN
      i-gl-Host-Code      = i-gl-Extent3[2]
      i-gl-Contract-Code  = i-gl-Extent3[3]
      .
END. ELSE DO:
   ASSIGN
      i-gl-Host-Code      = bf_trn-doc.host-code
      i-gl-Contract-Code  = bf_trn-doc.contract-code
      .
END.
    FIND FIRST bf_contract-specif
           NO-LOCK
           WHERE
               bf_contract-specif.Host-code    = i-gl-Host-Code
           AND bf_contract-specif.Contract-num = i-gl-Contract-Code
           AND bf_contract-specif.Gds-code     = bf_goods.gds-code
           NO-ERROR
           .
          if available bf_contract-specif then do:
            assign
              parprice-cli   = (bf_contract-specif.price-cli / bf_contract-specif.cli-base-rate)  * parcli-base-rate
              parvat-type    = bf_contract-specif.vat-type
              parvat-pc      = bf_contract-specif.vat-pc
              v-specif-found = yes
            .
          end.
        end.
      end.
      find first bf_cli-gds no-lock
        where bf_cli-gds.cli-code  = parcli-code
          and bf_cli-gds.cli-type  = parcli-type
          and bf_cli-gds.host-code = parhost-code
          and bf_cli-gds.artic     = parartic
          and bf_cli-gds.prod-code = parprod-code
          and bf_cli-gds.prod-type = parprod-type
        no-error.
      if available bf_cli-gds then do:
        if v-specif-found = false then do:
          assign
            parprice-cli = bf_cli-gds.price-cli
          .
        end.
        if paris-cli-tax then do:
          find first bf_doc-line no-lock
            where bf_doc-line.doc-code  = bf_cli-gds.in-code
              and bf_doc-line.artic     = bf_cli-gds.artic
              and bf_doc-line.prod-type = bf_cli-gds.prod-type
              and bf_doc-line.prod-code = bf_cli-gds.prod-code
            no-error.
          if available bf_doc-line then do:
            find first bf_trn-doc where bf_trn-doc.doc-code = bf_doc-line.doc-code no-lock.
            assign
              parroad-tax = bf_doc-line.road-tax
              parexcise   = bf_doc-line.excise
            .
            if parslt-type <> 'без':U then do:
              if bf_trn-doc.slt-type <> 'без':U then do:
                assign
                  parslt-pc = bf_doc-line.slt-pc
                .
              end.
            end.
            else do:
              assign
                parslt-pc = 0
              .
            end.
            if parvat-type <> 'без':U then do:
              if bf_trn-doc.vat-type <> 'без':U then do:
                if v-specif-found = false then do:
                  assign
                    parvat-pc = bf_doc-line.vat-pc
                  .
                end.
              end.
            end.
            else do:
              assign
                parvat-pc = 0
              .
            end.
          end.
        end.
      end.
    end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_in-vat in g#lib-trn
  (
   input   pardoc-code
  ,input   parbase-rate
  ,input   parbase-scale
  ,input   parexch-rate
  ,input   parexch-scale
  ,input   parvat-type
  ,input   parslt-type
  ,input   parartic
  ,input   parprod-type
  ,input   parprod-code
  ,input   parprice-cli
  ,input   parcli-base-rate
  ,input   parprice-rubl
  ,input   parvat-pc
  ,input   parslt-pc
  ,input   parroad-tax
  ,input   partransport-rubl
  ,input   parother-rubl
  ,output  varprice-cli
  ,output  varprice-cli-unit-base
  ,output  varprice-road-tax
  ,output  varprice-other-exp
  ,output  varprice-transport-exp
  ,output  varprice-without-abs
  ,output  varprice-slt
  ,output  varprice-no-slt
  ,output  varprice-vat
  ,output  varprice-no-vat-slt
  ,output  varprice-rubl
  ,output  varprice-road-tax-rubl
  ,output  varprice-other-exp-rubl
  ,output  varprice-transport-exp-rubl
  ,output  varprice-without-abs-rubl
  ,output  varprice-slt-rubl
  ,output  varprice-no-slt-rubl
  ,output  varprice-vat-rubl
  ,output  varprice-no-vat-slt-rubl
  ,output  varprice-base
  ,output  varprice-road-tax-base
  ,output  varprice-other-exp-base
  ,output  varprice-transport-exp-base
  ,output  varprice-without-abs-base
  ,output  varprice-slt-base
  ,output  varprice-no-slt-base
  ,output  varprice-vat-base
  ,output  varprice-no-vat-slt-base
  ) no-error.
    if error-status:error then do:
      return error "Ошибка при пересчете линии документа".
    end.
    assign
      parprice-cli  = varprice-cli
      parprice-rubl = varprice-rubl
      parprice-base = varprice-base
    .
  end.
end procedure.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define buffer buf_goods for ub.goods  .
define buffer buf_doc-line for ub.doc-line  .
define shared buffer t-doc for ub.trn-doc.
define temp-table tt-trn-doc  no-undo like ub.trn-doc.
define temp-table tt-doc-line no-undo like ub.doc-line
field cst-code like ub.trn-doc.cst-code
field part-code   like ub.parts.part-code
.
define temp-table tt-doc-line-attr no-undo like ub.doc-line-attr.
define temp-table tt-gds-dtl  no-undo like ub.gds-dtl.
define temp-table tt-parts no-undo like ub.parts.
define buffer d-l-b for ub.doc-line.
define buffer bf-trn-doc for ub.trn-doc.
define variable v-vat-pc        like ub.doc-line.vat-pc    no-undo.
define variable v-slt-pc        like ub.doc-line.slt-pc    no-undo.
define variable v-host-code     like ub.sysconf.host-code  no-undo.
define variable varprice-cli                like ub.doc-line.price-rubl no-undo.
define variable varprice-cli-unit-base      like ub.doc-line.price-rubl no-undo.
define variable varprice-road-tax           like ub.doc-line.price-rubl no-undo.
define variable varprice-other-exp          like ub.doc-line.price-rubl no-undo.
define variable varprice-transport-exp      like ub.doc-line.price-rubl no-undo.
define variable varprice-without-abs        like ub.doc-line.price-rubl no-undo.
define variable varprice-slt                like ub.doc-line.price-rubl no-undo.
define variable varprice-no-slt             like ub.doc-line.price-rubl no-undo.
define variable varprice-vat                like ub.doc-line.price-rubl no-undo.
define variable varprice-no-vat-slt         like ub.doc-line.price-rubl no-undo.
define variable varprice-rubl               like ub.doc-line.price-rubl no-undo.
define variable varprice-road-tax-rubl      like ub.doc-line.price-rubl no-undo.
define variable varprice-other-exp-rubl     like ub.doc-line.price-rubl no-undo.
define variable varprice-transport-exp-rubl like ub.doc-line.price-rubl no-undo.
define variable varprice-without-abs-rubl   like ub.doc-line.price-rubl no-undo.
define variable varprice-slt-rubl           like ub.doc-line.price-rubl no-undo.
define variable varprice-no-slt-rubl        like ub.doc-line.price-rubl no-undo.
define variable varprice-vat-rubl           like ub.doc-line.price-rubl no-undo.
define variable varprice-no-vat-slt-rubl    like ub.doc-line.price-rubl no-undo.
define variable varprice-base               like ub.doc-line.price-base no-undo.
define variable varprice-road-tax-base      like ub.doc-line.price-base no-undo.
define variable varprice-other-exp-base     like ub.doc-line.price-base no-undo.
define variable varprice-transport-exp-base like ub.doc-line.price-base no-undo.
define variable varprice-without-abs-base   like ub.doc-line.price-base no-undo.
define variable varprice-slt-base           like ub.doc-line.price-base no-undo.
define variable varprice-no-slt-base        like ub.doc-line.price-base no-undo.
define variable varprice-vat-base           like ub.doc-line.price-base no-undo.
define variable varprice-no-vat-slt-base    like ub.doc-line.price-base no-undo.
define variable v-cash-pay                  like ub.sysconf.cash-pay    no-undo.
find t-doc where recid(t-doc) = p-doc-rec.
create tt-trn-doc.
buffer-copy t-doc except status_ flag_ to tt-trn-doc.
assign tt-trn-doc.status_ = "temp":u.
find buf_goods where recid(buf_goods) = p-gds-rec.
find buf_doc-line where buf_doc-line.doc-code  = t-doc.doc-code  and
                   buf_doc-line.artic     = buf_goods.artic     and
                   buf_doc-line.prod-type = buf_goods.prod-type and
                   buf_doc-line.prod-code = buf_goods.prod-code no-error.
create tt-doc-line.
if not available buf_doc-line then do:
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  t-doc.obj-type
  ,input  t-doc.obj-code
  ,output v-host-code
  )  .
    find ub.sysconf where ub.sysconf.host-code = v-host-code no-lock.
    v-cash-pay = ub.sysconf.cash-pay.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  buf_goods.gds-code
  ,input  '1':U
  ,input  ?
  ,input  v-host-code
  ,input  t-doc.obj-type
  ,input  t-doc.obj-code
  ,output v-vat-pc
  ) no-error .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_st-sltpc in g#lib-trn
(
 input  recid(buf_goods)
,input  recid(t-doc)
,input  v-cash-pay
,output v-slt-pc
)
no-error.
    if error-status:error then return error return-value.
    assign
      tt-doc-line.doc-code        =    t-doc.doc-code
      tt-doc-line.status_         =    t-doc.status_
      tt-doc-line.artic           =    buf_goods.artic
      tt-doc-line.prod-code       =    buf_goods.prod-code
      tt-doc-line.prod-type       =    buf_goods.prod-type
      tt-doc-line.obj-code        =    t-doc.obj-code
      tt-doc-line.obj-type        =    t-doc.obj-type
      tt-doc-line.prt-root        =    buf_goods.prt-root
      tt-doc-line.line-num        =    next-value(s-line-num, ub)
      tt-doc-line.unit-cli        =    buf_goods.unit-cli
      tt-doc-line.cli-base-rate   =    buf_goods.cli-base-rate.
    run cpprclig in this-procedure   (
      input        t-doc.doc-code             ,
      input        t-doc.cli-code             ,
      input        t-doc.cli-type             ,
      input        t-doc.host-code            ,
      input        t-doc.base-rate            ,
      input        t-doc.base-scale           ,
      input        t-doc.exch-rate            ,
      input        t-doc.exch-scale           ,
      input        t-doc.vat-type             ,
      input        t-doc.slt-type             ,
      input        buf_goods.artic                ,
      input        buf_goods.prod-type            ,
      input        buf_goods.prod-code            ,
      input        yes                        ,
      input        buf_goods.cli-base-rate        ,
      input        tt-doc-line.transport-rubl ,
      input        tt-doc-line.other-rubl     ,
      output       tt-doc-line.price-cli               ,
      output       tt-doc-line.price-base              ,
      output       tt-doc-line.price-rubl              ,
      input-output tt-doc-line.vat-pc                  ,
      input-output tt-doc-line.slt-pc                  ,
      input-output tt-doc-line.road-tax                ,
      input-output tt-doc-line.excise                  ) no-error.
    if tt-doc-line.vat-pc = ? then do:
      assign
        tt-doc-line.vat-pc = v-vat-pc.
    end.
    if tt-doc-line.slt-pc = ? then do:
      assign
        tt-doc-line.slt-pc = v-slt-pc.
    end.
    if can-do( 'запрос':U, t-doc.status_ ) and ( not t-doc.flag_ ) then do:
       find first ub.goods no-lock where recid(ub.goods)  = recid(buf_goods) .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
for each ub.gds-obj where ub.gds-obj.prod-type = ub.goods.prod-type
                   and ub.gds-obj.prod-code = ub.goods.prod-code
                   and ub.gds-obj.artic     = ub.goods.artic
                   and ub.gds-obj.host-code = t-doc.host-code
                   and ub.gds-obj.obj-type  = t-doc.obj-type
                   and ub.gds-obj.obj-code  = t-doc.obj-code no-lock,
  first bf-trn-doc where bf-trn-doc.doc-code = ub.gds-obj.in-code no-lock,
  first d-l-b where d-l-b.doc-code  = ub.gds-obj.in-code
                and d-l-b.artic     = ub.goods.artic
                and d-l-b.prod-type = ub.goods.prod-type
                and d-l-b.prod-code = ub.goods.prod-code no-lock
  by bf-trn-doc.fact-order descending:
     ASSIGN tt-doc-line.price-cli  = d-l-b.price-cli
            tt-doc-line.price-rubl = d-l-b.price-rubl
            tt-doc-line.price-base = d-l-b.price-base.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_in-vat in g#lib-trn
  (
   input   t-doc.doc-code
  ,input   t-doc.base-rate
  ,input   t-doc.base-scale
  ,input   t-doc.exch-rate
  ,input   t-doc.exch-scale
  ,input   t-doc.vat-type
  ,input   t-doc.slt-type
  ,input   tt-doc-line.artic
  ,input   tt-doc-line.prod-type
  ,input   tt-doc-line.prod-code
  ,input   tt-doc-line.price-cli
  ,input   tt-doc-line.cli-base-rate
  ,input   tt-doc-line.price-rubl
  ,input   tt-doc-line.vat-pc
  ,input   tt-doc-line.slt-pc
  ,input   tt-doc-line.road-tax
  ,input   tt-doc-line.transport-rubl
  ,input   tt-doc-line.other-rubl
  ,output  varprice-cli
  ,output  varprice-cli-unit-base
  ,output  varprice-road-tax
  ,output  varprice-other-exp
  ,output  varprice-transport-exp
  ,output  varprice-without-abs
  ,output  varprice-slt
  ,output  varprice-no-slt
  ,output  varprice-vat
  ,output  varprice-no-vat-slt
  ,output  varprice-rubl
  ,output  varprice-road-tax-rubl
  ,output  varprice-other-exp-rubl
  ,output  varprice-transport-exp-rubl
  ,output  varprice-without-abs-rubl
  ,output  varprice-slt-rubl
  ,output  varprice-no-slt-rubl
  ,output  varprice-vat-rubl
  ,output  varprice-no-vat-slt-rubl
  ,output  varprice-base
  ,output  varprice-road-tax-base
  ,output  varprice-other-exp-base
  ,output  varprice-transport-exp-base
  ,output  varprice-without-abs-base
  ,output  varprice-slt-base
  ,output  varprice-no-slt-base
  ,output  varprice-vat-base
  ,output  varprice-no-vat-slt-base
  ) no-error.
       if error-status:error then do:
         return error "Ошибка при пересчете линии документа".
       end.
       ASSIGN tt-doc-line.price-cli  = varprice-cli
              tt-doc-line.price-rubl = varprice-rubl
              tt-doc-line.price-base = varprice-base.
     leave.
end.
    end.
end.
else do:
   buffer-copy buf_doc-line except cli-qnty doc-qnty fact-qnty to tt-doc-line.
end.
find first ub.units where ub.units.unit-name = buf_goods.unit-base no-lock.
assign
  tt-doc-line.cli-qnty        =    if not t-doc.flag_ then parqnty / tt-doc-line.cli-base-rate else 0
  tt-doc-line.doc-qnty        =    if not t-doc.flag_ then parqnty else 0
  tt-doc-line.fact-qnty       =    parqnty.
find ub.bar-code where ub.bar-code.b-code  = parb-c no-lock.
create tt-gds-dtl.
assign
        tt-gds-dtl.doc-code      = t-doc.doc-code
        tt-gds-dtl.artic         = buf_goods.artic
        tt-gds-dtl.prod-code     = buf_goods.prod-code
        tt-gds-dtl.prod-type     = buf_goods.prod-type
        tt-gds-dtl.prt-code      = ub.bar-code.node-code
        tt-gds-dtl.obj-code      = t-doc.obj-code
        tt-gds-dtl.obj-type      = t-doc.obj-type
        tt-gds-dtl.doc-qnty      = if not t-doc.flag_ then parqnty else 0
        tt-gds-dtl.fact-qnty     = parqnty.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn4) <> true) then do:   run str/lib-trn4.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn4) <> true) then do:     message       "Error starting lib-trn4.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn4 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn4 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn4 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn4_copy-in in g#lib-trn4
( input parparentproc
 ,input recid(t-doc)
 ,input table tt-trn-doc
 ,input table tt-doc-line
 ,input table tt-doc-line-attr
 ,input table tt-gds-dtl
 ,input table tt-parts
 ,input yes
 ,input yes
 ,input no
 ,input yes
 ,input this-procedure
  ) no-error .
if error-status:error then do:
   message
     vss-workfile vss-revision vss-description skip
     "Не удалось добавить товар" skip
     return-value skip
     trim(error-status :get-message(1))
     trim(error-status :get-message(2))
     trim(error-status :get-message(3))
     trim(error-status :get-message(4))
     trim(error-status :get-message(5)) skip
     view-as alert-box error.
   undo, return error .
end.
