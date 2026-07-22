block-level on error undo, throw.
define input  parameter parparentproc     as widget-handle no-undo .
define input  parameter p-unique-doc-code as character no-undo .
define input  parameter p-obj-type        as character no-undo .
define input  parameter p-obj-code        as integer   no-undo .
define input  parameter p-host-code       as integer   no-undo .
define input  parameter p-bar-code        as character no-undo .
define output parameter p-status          as character no-undo .
define output parameter p-error-message   as character no-undo .
define output parameter p-b-code          as integer   no-undo .
define output parameter p-artic           as character no-undo .
define output parameter p-name            as character no-undo .
define output parameter p-prod-name       as character no-undo .
define output parameter p-unit-cli        as character no-undo .
define output parameter p-cli-base-rate   as character no-undo .
define output parameter p-price-cli       as character no-undo .
define output parameter p-vat-pc          as character no-undo .
define output parameter p-curr-abbr       as character no-undo .
define output parameter p-unit-base       as character no-undo .
define output parameter p-doc-qnty        as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rt-bcdoc.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/rt-bcdoc.p $":U .
define variable vss-description as character no-undo init "Радиотерминал. Поиск товара по штрих-коду в документе".
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
define variable v-doc-type    as character no-undo .
define variable v-doc-code    as character no-undo .
define variable v-artic       as character no-undo .
define variable v-prod-type   as character no-undo .
define variable v-prod-code   as integer   no-undo .
define variable v-price-cli   as decimal   no-undo .
define variable v-price-base  as decimal   no-undo .
define variable v-price-rubl  as decimal   no-undo .
define variable v-vat-pc      as decimal   no-undo .
define variable v-slt-pc      as decimal   no-undo .
define variable v-road-tax    as decimal   no-undo .
define variable v-excise      as decimal   no-undo .
define variable v-empty-scale as logical   no-undo .
define variable v-rbisbase    as logical   no-undo .
define buffer buf_currency         for ub.currency .
define buffer buf_bar-code         for ub.bar-code .
define buffer buf_goods            for ub.goods .
define buffer buf_trn-doc          for ub.trn-doc .
define buffer buf_doc-line         for ub.doc-line .
define buffer buf_gds-dtl          for ub.gds-dtl .
define buffer buf_clients          for ub.clients .
define buffer buf_ord-doc          for ub.ord-doc .
define buffer buf_ord-doc-rcv      for ub.ord-doc-rcv .
define buffer buf_ord-line-rcv     for ub.ord-line-rcv .
define buffer buf_cli-gds          for ub.cli-gds .
define buffer buf_cbr_doc-line     for ub.doc-line .
define buffer buf_previos_doc-line for ub.doc-line .
do
on error undo, return error return-value
:
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rbisbase in g#library
  (output v-rbisbase
  )  .
  run gbl/getbcode.p
    (input  parparentproc
    ,input  p-bar-code
    ,input  ""
    ,input  0
    ,input  false
    ,output p-b-code
    ) .
  if p-b-code = ?
  then do:
    assign
      p-status        = '1'
      p-error-message = substitute('Ошибка при поиске штрих-кода &1'
                                  ,p-bar-code
                                  )
      p-b-code        = ?
    .
    return .
  end.
  find first buf_bar-code no-lock
    where buf_bar-code.b-code = p-b-code
    no-error .
  if not available buf_bar-code
  then do:
    assign
      p-status        = '1'
      p-error-message = substitute('Ошибка поиска записи bar-code &1'
                                  ,p-b-code
                                  )
      p-b-code        = ?
    .
    return .
  end.
  define variable v-default-cli-base-rate as decimal   no-undo .
  assign
    v-default-cli-base-rate = buf_bar-code.cli-base-rate
  .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run arptpc in g#library
  (input  buf_bar-code.gds-code
  ,output v-artic
  ,output v-prod-type
  ,output v-prod-code
  ) no-error .
  if error-status :error
  then do:
    assign
      p-status        = '1'
      p-error-message = substitute('Ошибка выполнения процедуры arptpc.i &1 &2'
                                  ,error-status :get-message(1)
                                  ,return-value
                                  )
      p-b-code        = ?
    .
    return .
  end.
  find first buf_goods no-lock
    where buf_goods.artic     = v-artic
      and buf_goods.prod-type = v-prod-type
      and buf_goods.prod-code = v-prod-code
    no-error .
  if not available buf_goods
  then do:
    assign
      p-status        = '1'
      p-error-message = substitute('rt-bcdoc.p. Не найден товар &1 &2 &3'
                                  ,v-artic
                                  ,v-prod-type
                                  ,v-prod-code
                                  )
      p-b-code        = ?
    .
    return .
  end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdscdat in g#library
  (input  buf_bar-code.gds-code
  ,input  'empty-scale=request':u
  ,output v-empty-scale
  )  .
  if v-empty-scale <> true
  then do:
    assign
      p-status        = '1'
      p-error-message = substitute('Товар &1 &2 &3 нельзя добавить, потому что он имеет непустую шкалу.'
                                  ,v-artic
                                  ,v-prod-type
                                  ,v-prod-code
                                  )
      p-b-code        = ?
    .
    return .
  end.
  find first buf_clients no-lock
    where buf_clients.obj-type = buf_goods.prod-type
      and buf_clients.obj-code = buf_goods.prod-code
    no-error .
  if not available buf_clients
  then do:
    assign
      p-status        = '1'
      p-error-message = substitute('rt-bcdoc.p. Товар &1 &2 &3. Не найден производитель'
                                  ,v-artic
                                  ,v-prod-type
                                  ,v-prod-code
                                  )
      p-b-code        = ?
    .
    return .
  end.
  assign
    v-doc-type = entry(1, p-unique-doc-code, '|':u)
  .
  case v-doc-type
  :
    when 'ПТ':u
    then do:
      assign
        v-doc-code = entry(2, p-unique-doc-code, '|':u)
      .
      find first buf_ord-doc-rcv no-lock
        where buf_ord-doc-rcv.rcv-code = v-doc-code
        no-error .
      if not available buf_ord-doc-rcv
      then do:
        assign
          p-status        = '1'
          p-error-message = substitute('rt-bcdoc.p: Не найден документ поставки &1'
                                      ,p-unique-doc-code
                                      )
          p-b-code        = 0
        .
        return .
      end.
      find first buf_ord-doc no-lock
        where buf_ord-doc.doc-code = buf_ord-doc-rcv.doc-code
        no-error .
      if not available buf_ord-doc
      then do:
        assign
          p-status        = '1'
          p-error-message = substitute('rt-bcdoc.p: Не найден документ заказа &1 на основании документа поставки &2'
                                      ,buf_ord-doc-rcv.doc-code
                                      ,p-unique-doc-code
                                      )
          p-b-code        = 0
        .
        return .
      end.
      find first buf_currency no-lock
        where buf_currency.curr-code = buf_ord-doc-rcv.exch-code
        no-error .
      if not available buf_currency
      then do:
        assign
          p-status        = '1'
          p-error-message = substitute('rt-bcdoc.p: Не найдена валюта с кодом &1. Поставка &2'
                                      ,buf_ord-doc-rcv.exch-code
                                      ,buf_ord-doc-rcv.doc-code
                                      )
          p-b-code        = 0
        .
        return .
      end.
      assign
        p-curr-abbr = buf_currency.curr-abbr
      .
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  buf_bar-code.gds-code
  ,input  '1':U
  ,input  ?
  ,input  p-host-code
  ,input  p-obj-type
  ,input  p-obj-code
  ,output v-vat-pc
  )  .
      find first buf_cli-gds no-lock
        where buf_cli-gds.cli-code  = buf_ord-doc-rcv.cli-code
          and buf_cli-gds.cli-type  = buf_ord-doc-rcv.cli-type
          and buf_cli-gds.host-code = buf_ord-doc-rcv.host-code
          and buf_cli-gds.artic     = v-artic
          and buf_cli-gds.prod-code = v-prod-code
          and buf_cli-gds.prod-type = v-prod-type
        no-error .
      if available buf_cli-gds
      then do:
        find first buf_cbr_doc-line no-lock
          where buf_cbr_doc-line.doc-code  = buf_cli-gds.in-code
            and buf_cbr_doc-line.artic     = buf_cli-gds.artic
            and buf_cbr_doc-line.prod-type = buf_cli-gds.prod-type
            and buf_cbr_doc-line.prod-code = buf_cli-gds.prod-code
          no-error .
        if available buf_cbr_doc-line
        then do:
          assign
            v-default-cli-base-rate = buf_cbr_doc-line.cli-base-rate
          .
        end.
      end.
      run cpprclig in this-procedure
        (input  'zakaz':u
        ,input  buf_ord-doc-rcv.cli-code
        ,input  buf_ord-doc-rcv.cli-type
        ,input  buf_ord-doc-rcv.host-code
        ,input  buf_ord-doc-rcv.base-rate
        ,input  buf_ord-doc-rcv.base-scale
        ,input  buf_ord-doc-rcv.exch-rate
        ,input  buf_ord-doc-rcv.exch-scale
        ,input  buf_ord-doc.vat-type
        ,input  buf_ord-doc.slt-type
        ,input  buf_goods.artic
        ,input  buf_goods.prod-type
        ,input  buf_goods.prod-code
        ,input  false
        ,input  v-default-cli-base-rate
        ,input  0
        ,input  0
        ,output       v-price-cli
        ,output       v-price-base
        ,output       v-price-rubl
        ,input-output v-vat-pc
        ,input-output v-slt-pc
        ,input-output v-road-tax
        ,input-output v-excise
        ).
      assign
        p-artic         = buf_goods.artic
        p-name          = buf_goods.gds-name
        p-prod-name     = buf_clients.obj-name
        p-unit-base     = buf_goods.unit-base
        p-unit-cli      = buf_bar-code.unit-cli
        p-cli-base-rate = string(buf_bar-code.cli-base-rate)
        p-vat-pc        = string(v-vat-pc)
      .
      if v-rbisbase = true
      then do:
        assign
          p-price-cli = string(v-price-base * buf_bar-code.cli-base-rate)
        .
      end.
      else do:
        assign
          p-price-cli = string(v-price-rubl * buf_bar-code.cli-base-rate)
        .
      end.
      find first buf_ord-line-rcv no-lock
        where buf_ord-line-rcv.doc-code   = buf_ord-doc-rcv.doc-code
          and buf_ord-line-rcv.rcv-code   = buf_ord-doc-rcv.rcv-code
          and buf_ord-line-rcv.artic      = buf_goods.artic
          and buf_ord-line-rcv.prod-type  = buf_goods.prod-type
          and buf_ord-line-rcv.prod-code  = buf_goods.prod-code
      no-error .
      if available buf_ord-line-rcv
      then do:
        assign
          p-doc-qnty = string(buf_ord-line-rcv.qnty / buf_bar-code.cli-base-rate )
        .
      end.
      else do:
        assign
          p-doc-qnty = string(0)
        .
      end.
      assign
        p-status        = '0':u
        p-error-message = '':u
      .
      return .
    end.
    when 'ПН':u
    then do:
      assign
        v-doc-code = entry(2, p-unique-doc-code, '|':u)
      .
      find first buf_trn-doc no-lock
        where buf_trn-doc.doc-code = v-doc-code
        no-error .
      if not available buf_trn-doc
      then do:
        assign
          p-status        = '1'
          p-error-message = substitute('rt-bcdoc.p: Не найден складской документ &1'
                                      ,p-unique-doc-code
                                      )
          p-b-code        = 0
        .
        return .
      end.
      find first buf_currency no-lock
        where buf_currency.curr-code = buf_trn-doc.exch-code
        no-error .
      if not available buf_currency
      then do:
        assign
          p-status        = '1'
          p-error-message = substitute('rt-bcdoc.p: Не найдена валюта с кодом &1. Складской документ &2'
                                      ,buf_trn-doc.exch-code
                                      ,buf_trn-doc.doc-code
                                      )
          p-b-code        = 0
        .
        return .
      end.
      assign
        p-curr-abbr = buf_currency.curr-abbr
      .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  buf_bar-code.gds-code
  ,input  '1':U
  ,input  ?
  ,input  p-host-code
  ,input  p-obj-type
  ,input  p-obj-code
  ,output v-vat-pc
  )  .
      find first buf_previos_doc-line exclusive-lock
        where buf_previos_doc-line.doc-code = buf_trn-doc.doc-code
          and buf_previos_doc-line.artic     = v-artic
          and buf_previos_doc-line.prod-code = v-prod-code
          and buf_previos_doc-line.prod-type = v-prod-type
        no-error .
      if available buf_previos_doc-line
      then do:
        assign
          p-artic         = buf_goods.artic
          p-name          = buf_goods.gds-name
          p-prod-name     = buf_clients.obj-name
          p-unit-base     = buf_goods.unit-base
          p-unit-cli      = buf_previos_doc-line.unit-cli
          p-price-cli     = string(buf_previos_doc-line.price-cli)
          p-cli-base-rate = string(buf_previos_doc-line.cli-base-rate)
          p-vat-pc        = string(buf_previos_doc-line.vat-pc)
          p-doc-qnty      = string( buf_previos_doc-line.doc-qnty / buf_previos_doc-line.cli-base-rate )
        .
      end.
      else do:
        find first buf_cli-gds no-lock
          where buf_cli-gds.cli-code  = buf_trn-doc.cli-code
            and buf_cli-gds.cli-type  = buf_trn-doc.cli-type
            and buf_cli-gds.host-code = buf_trn-doc.host-code
            and buf_cli-gds.artic     = v-artic
            and buf_cli-gds.prod-code = v-prod-code
            and buf_cli-gds.prod-type = v-prod-type
          no-error .
        if available buf_cli-gds
        then do:
          find first buf_cbr_doc-line no-lock
            where buf_cbr_doc-line.doc-code  = buf_cli-gds.in-code
              and buf_cbr_doc-line.artic     = buf_cli-gds.artic
              and buf_cbr_doc-line.prod-type = buf_cli-gds.prod-type
              and buf_cbr_doc-line.prod-code = buf_cli-gds.prod-code
            no-error .
          if available buf_cbr_doc-line
          then do:
            assign
              v-default-cli-base-rate = buf_cbr_doc-line.cli-base-rate
            .
          end.
        end.
        run cpprclig in this-procedure
          (input  buf_trn-doc.doc-code
          ,input  buf_trn-doc.cli-code
          ,input  buf_trn-doc.cli-type
          ,input  buf_trn-doc.host-code
          ,input  buf_trn-doc.base-rate
          ,input  buf_trn-doc.base-scale
          ,input  buf_trn-doc.exch-rate
          ,input  buf_trn-doc.exch-scale
          ,input  buf_trn-doc.vat-type
          ,input  buf_trn-doc.slt-type
          ,input  buf_goods.artic
          ,input  buf_goods.prod-type
          ,input  buf_goods.prod-code
          ,input  false
          ,input  v-default-cli-base-rate
          ,input  0
          ,input  0
          ,output       v-price-cli
          ,output       v-price-base
          ,output       v-price-rubl
          ,input-output v-vat-pc
          ,input-output v-slt-pc
          ,input-output v-road-tax
          ,input-output v-excise
          ).
        assign
          p-artic         = buf_goods.artic
          p-name          = buf_goods.gds-name
          p-prod-name     = buf_clients.obj-name
          p-unit-base     = buf_goods.unit-base
          p-unit-cli      = buf_bar-code.unit-cli
          p-cli-base-rate = string(buf_bar-code.cli-base-rate)
          p-vat-pc        = string(v-vat-pc)
          p-doc-qnty      = string(0)
        .
        if v-rbisbase = true
        then do:
          assign
            p-price-cli = string(v-price-base * buf_bar-code.cli-base-rate)
          .
        end.
        else do:
          assign
            p-price-cli = string(v-price-rubl * buf_bar-code.cli-base-rate)
          .
        end.
      end.
      assign
        p-status        = '0':u
        p-error-message = '':u
      .
      return .
    end.
    otherwise do:
      assign
        p-status        = '1'
        p-error-message = substitute('rt-bcdoc.p: Неизвестный тип документа &1'
                                    ,v-doc-type
                                    )
        p-b-code        = 0
      .
      return .
    end.
  end.
end.
