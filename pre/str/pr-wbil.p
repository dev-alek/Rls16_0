block-level on error undo, throw.
def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: pr-wbil.p $":U .
def var vss-archive     as character no-undo init "$Archive: str/pr-wbil.p $":U .
def var vss-description as character no-undo init "Методы расчета переоценки".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define input parameter  p-type          as character no-undo .
define input parameter  p-met           as character no-undo .
define input parameter  rec-id-trn-doc  as recid no-undo .
define input parameter  rec-id-doc-line as recid no-undo .
define input parameter  rec-id-gds-dtl  as recid no-undo .
define input parameter  doc-code     as character no-undo .
define input parameter  v-gds-name   as character no-undo .
define input parameter  v-gds-code   as integer no-undo .
define input parameter  v-artic      as character no-undo .
define input parameter  v-prod-type  as character no-undo .
define input parameter  v-prod-code  as integer no-undo .
define input parameter  v-node-code  as integer no-undo .
define input parameter  p-pc         as decimal no-undo .
define input  parameter p-doc-price-rubl as decimal   no-undo .
define input  parameter p-doc-price-base as decimal   no-undo .
define output parameter v-price-calc as decimal no-undo .
define output parameter v-price-sale as decimal no-undo .
define variable var-pr-r-b as character no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output var-pr-r-b
  )  .
define variable g#log as logical   no-undo .
find first trn-doc no-lock where recid(trn-doc) = rec-id-trn-doc no-error .
if p-met = 'НсП+накл':U then do:
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  v-gds-code
  ,input  '2':U
  ,input  ?
  ,input  trn-doc.host-code
  ,input  trn-doc.obj-type
  ,input  trn-doc.obj-code
  ,output p-pc
  ) no-error .
end.
 if p-type = "pr-doc" then do:
      if available trn-doc then do:
        if trn-doc.doc-type = 'при':U and
         ( trn-doc.ext-doc-type = 'ie':U  ) then do:
          find doc-line where doc-line.doc-code = doc-code
                          and doc-line.artic     = v-artic
                          and doc-line.prod-type = v-prod-type
                          and doc-line.prod-code = v-prod-code no-lock no-error.
                if available doc-line then
                  assign
                    v-price-calc =  if var-pr-r-b = "rubl"  then doc-line.price-rubl else doc-line.price-base
                    v-price-sale =  v-price-calc * (1 + p-pc / 100)
                    .
                else
                  message "Нет строки в накладной :" doc-code "для товара :" v-artic  v-gds-name
                          "- расчет невозможен."
                          view-as alert-box question buttons OK-Cancel update g#log.
        end.
        else do:
          find gds-dtl where gds-dtl.doc-code  = doc-code
                         and gds-dtl.artic     =  v-artic
                         and gds-dtl.prod-type =  v-prod-type
                         and gds-dtl.prod-code =  v-prod-code
                         and gds-dtl.prt-code  =  v-node-code no-lock no-error.
          if not available gds-dtl then
            find first gds-dtl where gds-dtl.doc-code = doc-code
                                 and gds-dtl.artic =  v-artic
                                 and gds-dtl.prod-type =  v-prod-type
                                 and gds-dtl.prod-code =  v-prod-code no-lock no-error.
          if available gds-dtl then
            assign
               v-price-calc = if var-pr-r-b = "rubl"  then gds-dtl.price-rubl else gds-dtl.price-base
               v-price-sale = v-price-calc * (1 + p-pc / 100)
              .
          else
            message "Нет строки в накладной :" doc-code "для товара :" v-artic v-gds-name
                    "- расчет невозможен."
                    view-as alert-box question buttons OK-Cancel update g#log.
        end.
      end.
      else
        message "Не прочитана накладная с номером" doc-code
                "- расчет невозможен."
                view-as alert-box question buttons OK-Cancel update g#log.
 end.
 else do:
 define variable v-bonus as decimal   no-undo .
 v-bonus = 0.0 .
 define buffer buf_contract-specif-attr for ub.contract-specif-attr  .
 define buffer buf_goods for ub.goods  .
find first buf_goods no-lock where
           buf_goods.artic  =  v-artic and
           buf_goods.prod-type =  v-prod-type and
           buf_goods.prod-code =  v-prod-code no-error .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ASSIGN
   i-gl-Host-Code      = 0
   i-gl-Contract-Code  = 0
   i-gl-Extent3        = 0
   .
RUN MS-Contract-EXTENT-3 IN THIS-PROCEDURE(
    INPUT  trn-doc.host-code,
    INPUT  trn-doc.contract-code,
    OUTPUT i-gl-Extent3
   ).
IF i-gl-Extent3[1] = 2 THEN DO:
   ASSIGN
      i-gl-Host-Code      = i-gl-Extent3[2]
      i-gl-Contract-Code  = i-gl-Extent3[3]
      .
END. ELSE DO:
   ASSIGN
      i-gl-Host-Code      = trn-doc.host-code
      i-gl-Contract-Code  = trn-doc.contract-code
      .
END.
    FIND FIRST buf_contract-specif-attr
           NO-LOCK
           WHERE
               buf_contract-specif-attr.Host-code    = i-gl-Host-Code
           AND buf_contract-specif-attr.Contract-num = i-gl-Contract-Code
           AND buf_contract-specif-attr.Gds-code     = buf_goods.gds-code
           AND buf_contract-specif-attr.Attr-code    = 'bonus':U
           NO-ERROR
           .
    if available buf_contract-specif-attr
       then v-bonus = decimal (buf_contract-specif-attr.attr-value) .
       else v-bonus = 0.0 .
      if trn-doc.doc-type = 'при':U and
         ( trn-doc.ext-doc-type = 'ie':U   ) then do:
        find first doc-line no-lock where recid(doc-line) = rec-id-doc-line no-error .
        if available doc-line    then
            assign
              v-price-calc =  if var-pr-r-b = "rubl"  then doc-line.price-rubl else doc-line.price-base
              v-price-sale = v-price-calc * (1 + v-bonus / 100) * (1 + p-pc / 100)
              .
            else
            assign
              v-price-calc =  if var-pr-r-b = "rubl"  then p-doc-price-rubl else p-doc-price-base
              v-price-sale = v-price-calc * (1 + v-bonus / 100) * (1 + p-pc / 100)
              .
      end.
      else do:
          find first gds-dtl no-lock where recid(gds-dtl) = rec-id-gds-dtl no-error .
          if available gds-dtl then
            assign
              v-price-calc =  if var-pr-r-b = "rubl"  then gds-dtl.price-rubl else gds-dtl.price-base
              v-price-sale = v-price-calc * (1 + v-bonus / 100) * (1 + p-pc / 100)
              .
            else
            assign
              v-price-calc =  if var-pr-r-b = "rubl"  then p-doc-price-rubl else p-doc-price-base
              v-price-sale = v-price-calc * (1 + v-bonus / 100) * (1 + p-pc / 100)
              .
     end.
 end.
