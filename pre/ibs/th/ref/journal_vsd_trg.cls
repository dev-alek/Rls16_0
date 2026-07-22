USING Progress.Lang.*.
USING ibs.th.str.mercury.*.
USING ibs.th.gbl.storage.*.
BLOCK-LEVEL ON ERROR UNDO, THROW.
CLASS ibs.th.ref.journal_vsd_trg:
    DEFINE VARIABLE vss-revision       AS CHARACTER NO-UNDO INIT "$Revision$":U .
    DEFINE VARIABLE vss-author         AS CHARACTER NO-UNDO INIT "$Author$":U .
    DEFINE VARIABLE vss-date           AS CHARACTER NO-UNDO INIT "$Date$":U .
    DEFINE VARIABLE vss-workfile       AS CHARACTER NO-UNDO INIT "$Workfile$":U .
    DEFINE VARIABLE vss-archive        AS CHARACTER NO-UNDO INIT "$Archive$":U .
    DEFINE VARIABLE vss-description    AS CHARACTER NO-UNDO INIT "Журнал ВСД".
    DEFINE TEMP-TABLE t-obj-list NO-UNDO
    FIELD obj-type  AS CHARACTER
    FIELD obj-code  AS INTEGER
    FIELD host-code AS INTEGER
    INDEX pi IS UNIQUE PRIMARY obj-type  obj-code
    INDEX firm                 host-code.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  temp-table tt-gds-list no-undo like ub.goods
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define    temp-table tt-gds-list-hist no-undo
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
DEFINE TEMP-TABLE tt-vsd-filt NO-UNDO
FIELD date-end AS DATE
FIELD date-start AS DATE
FIELD fTime  AS INTEGER
FIELD FalExting AS LOGICAL
FIELD FalVerif  AS LOGICAL
FIELD Rep       AS LOGICAL
FIELD ReqVerif  AS LOGICAL
FIELD ToExtin   AS LOGICAL
FIELD Sent      AS LOGICAL
FIELD doc-code  AS CHARACTER
.
DEFINE DATASET ds-vsd-set
FOR tt-vsd-filt, t-obj-list,  tt-gds-list .
DEFINE TEMP-TABLE ttvsd NO-UNDO LIKE ub.vsd
        FIELD dateTTH     AS DATE
        FIELD NomTTH      AS CHAR
        FIELD NomTTHpost  AS CHAR
        FIELD NomAZS      AS CHAR
        FIELD Post        AS CHAR
        FIELD artic       AS CHAR
        FIELD gdsname     AS CHAR
        FIELD prod-code   AS CHAR
        FIELD COLobj      AS DEC
        FIELD unit-cli    AS CHAR
        FIELD unit-base   AS CHAR
        FIELD statusvsd   AS CHAR
        FIELD ojd         AS DEC
        FIELD gdsmercguid AS CHAR
        FIELD vsdtypelbl  AS CHAR
        FIELD vsdsubs     AS CLASS Progress.Lang.Object.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
    DEFINE VARIABLE parparentproc AS HANDLE NO-UNDO.
    CONSTRUCTOR PUBLIC journal_vsd_trg (INPUT  pparparentproc AS HANDLE ):
    parparentproc = pparparentproc.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    END CONSTRUCTOR.
    METHOD PUBLIC  VOID VSD_lock(INPUT pID AS INTEGER  , INPUT pdb-num AS INTEGER,input pvsdsubs AS Progress.Lang.Object   ):
        DEFINE VARIABLE vsdsubsObj AS CLASS vsdsubs NO-UNDO.
        DEFINE VARIABLE vSave AS LOGICAL NO-UNDO.
        DEFINE BUFFER vsd FOR ub.vsd.
        FIND FIRST vsd WHERE vsd.id EQ pID
            AND vsd.db-num EQ pdb-num
            NO-LOCK NO-ERROR.
        IF AVAIL vsd
            THEN
        DO:
            vsdsubsObj = CAST (pvsdsubs, vsdsubs).
            RUN str/vsd.w (INPUT parparentproc, INPUT 'ПРОСМОТР':U, INPUT vsdsubsObj, OUTPUT vSave).
        END.
        RETURN.
    END METHOD.
    METHOD PUBLIC  VOID VSD_edit(INPUT pID AS INTEGER  , INPUT pdb-num AS INTEGER,input pvsdsubs AS Progress.Lang.Object   ):
       DEFINE VARIABLE vsdsubsObj    AS CLASS vsdsubs      NO-UNDO.
       DEFINE VARIABLE vsdsubObj     AS CLASS vsdsub       NO-UNDO.
       DEFINE VARIABLE vsdStorageObj AS CLASS vsdtostorage NO-UNDO.
       DEFINE BUFFER vsd FOR ub.vsd.
       DEFINE VARIABLE vSave AS LOGICAL NO-UNDO.
       DEFINE VARIABLE vI AS INTEGER NO-UNDO.
       FIND FIRST vsd WHERE vsd.id     EQ pID
                        AND vsd.db-num EQ pdb-num
          NO-LOCK NO-ERROR.
       IF AVAIL vsd
       THEN DO:
          vsdsubsObj = CAST (pvsdsubs, vsdsubs).
          RUN str/vsd.w (INPUT parparentproc, INPUT 'ИЗМЕНЕНИЕ':U, INPUT vsdsubsObj, OUTPUT vSave).
          IF vSave
          THEN DO:
             DO vi = 1 TO vsdsubsObj:GetItem(vi):
                vsdsubObj = vsdsubsObj:VsdObjCurr.
                IF vsdsubObj:Changed
                THEN DO:
                   vsdStorageObj = NEW vsdtostorage ().
                   CASE TRUE:
                      WHEN vsdsubObj:ID > 0
                      THEN DO:
                         vsdStorageObj:updateDB(vsdsubObj).
                      END.
                      OTHERWISE DO:
                         vsdStorageObj:insertDB(vsdsubObj).
                      END.
                   END CASE.
                    DELETE  OBJECT vsdStorageObj NO-ERROR.
                END.
             END.
          END.
       END.
        RETURN.
    END METHOD.
    METHOD PUBLIC  VOID gds_lock(INPUT pgds-code AS INTEGER,input pobj-type AS CHARACTER ,input pobj-code AS INTEGER  ):
        DEFINE VARIABLE gds-rec  AS INT64 NO-UNDO.
        DEFINE BUFFER goods FOR ub.goods.
        FIND FIRST goods WHERE goods.gds-code EQ pgds-code NO-LOCK NO-ERROR.
        IF AVAIL goods
        THEN DO:
            gds-rec = recid(goods).
            run ref/gds-form.w (
                INPUT parparentproc
                , INPUT 'ПРОСМОТР':U
                , INPUT pobj-type
                , INPUT pobj-code
                , input ?
                , input-output gds-rec
                ) .
        END.
        RETURN.
    END METHOD.
    METHOD PUBLIC  VOID gds_merc_lock(INPUT pgds-code AS INTEGER  ):
        run ref/merq-gds.w (
            parparentproc
            ,INPUT-OUTPUT pgds-code
            ,INPUT 'ПРОСМОТР':U
            ) no-error .
        RETURN.
    END METHOD.
    METHOD PUBLIC  VOID trn_doc_lock(INPUT ppart-key AS CHARACTER,INPUT pgds-code AS INTEGER ):
        DEFINE BUFFER doc-line FOR ub.doc-line.
    DEFINE BUFFER trn-doc  FOR ub.trn-doc.
    DEFINE BUFFER goods FOR ub.goods.
    DEFINE VARIABLE vlog AS LOGICAL NO-UNDO.
    FIND FIRST trn-doc WHERE trn-doc.doc-code EQ ENTRY (8,ppart-key,chr(3)) NO-LOCK NO-ERROR.
    IF AVAIL trn-doc
    THEN DO :
        CASE trn-doc.doc-type:
            WHEN 'при':U
            THEN DO:
define variable vss-include-info4 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  run chk-actg in ibs.th.gbl.gbl-hndllib:g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_income_lookup':U
    ,input  'object':U
    ,input  trn-doc.host-code
    ,input  trn-doc.obj-type
    ,input  trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output vlog
    )  .
end.
            END.
            WHEN 'рас':U
            THEN DO:
define variable vss-include-info5 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  run chk-actg in ibs.th.gbl.gbl-hndllib:g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_expense_lookup':U
    ,input  'object':U
    ,input  trn-doc.host-code
    ,input  trn-doc.obj-type
    ,input  trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output vlog
    )  .
end.
            END.
            WHEN 'спи':U
            THEN DO:
define variable vss-include-info6 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  run chk-actg in ibs.th.gbl.gbl-hndllib:g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_write-off_lookup':U
    ,input  'object':U
    ,input  trn-doc.host-code
    ,input  trn-doc.obj-type
    ,input  trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output vlog
    )  .
end.
            END .
            WHEN 'инв':U
            THEN DO:
define variable vss-include-info7 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  run chk-actg in ibs.th.gbl.gbl-hndllib:g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_inventory_lookup':U
    ,input  'object':U
    ,input  trn-doc.host-code
    ,input  trn-doc.obj-type
    ,input  trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output vlog
    )  .
end.
            END.
            WHEN 'возврат':U
            THEN DO:
define variable vss-include-info8 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  run chk-actg in ibs.th.gbl.gbl-hndllib:g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_return_lookup':U
    ,input  'object':U
    ,input  trn-doc.host-code
    ,input  trn-doc.obj-type
    ,input  trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output vlog
    )  .
end.
             END.
             OTHERWISE
             DO:
                MESSAGE
                    vss-workfile vss-revision vss-description skip
                    "Неизвестный тип документа" skip
                    "Тип документа" trn-doc.doc-type skip
                    "Код документа" trn-doc.doc-code skip
                    VIEW-AS ALERT-BOX ERROR .
            END.
        END CASE .
        IF NOT vlog THEN RETURN NO-APPLY.
        FIND FIRST goods WHERE goods.gds-code EQ pgds-code NO-LOCK NO-ERROR.
        IF AVAIL goods
        THEN DO:
            FIND doc-line WHERE doc-line.doc-code  = trn-doc.doc-code
                            AND doc-line.artic     = goods.artic
                            AND doc-line.prod-type = goods.prod-type
                            AND doc-line.prod-code = goods.prod-code
            NO-LOCK  NO-ERROR .
            IF AVAIL doc-line
            THEN
                RUN str/trn-lkp.p (parparentproc, recid(trn-doc), recid(doc-line)).
        END.
    END.
        RETURN.
    END METHOD.
    METHOD PUBLIC  VOID filt-clen ( output DATASET FOR ds-vsd-set   ):
    DEFINE VARIABLE v-object-available AS LOGICAL   NO-UNDO .
   ASSIGN
        tt-vsd-filt.date-end   = TODAY
        tt-vsd-filt.date-start = TODAY
        tt-vsd-filt.FalExting   = YES
        tt-vsd-filt.FalVerif    = YES
        tt-vsd-filt.Rep         = YES
        tt-vsd-filt.ReqVerif    = YES
        tt-vsd-filt.ToExtin     = YES
        tt-vsd-filt.fTime        = 0
        tt-vsd-filt.doc-code = ?
        .
      FOR EACH t-obj-list:
         delete t-obj-list.
      end.
      FOR EACH tt-gds-list:
         delete tt-gds-list.
      end.
      FOR EACH db NO-LOCK
        ON ERROR UNDO, RETURN NO-APPLY
        :
        FOR EACH clients NO-LOCK
            WHERE clients.db-num = db.db-num
            ON ERROR UNDO, RETURN NO-APPLY
            :
define variable vss-include-info9 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run usobjava in ibs.th.gbl.gbl-hndllib:g#library2
  (input  v-cntxt-db-num
  ,input  0
  ,input  v-cntxt-userid
  ,input  clients.obj-type
  ,input  clients.obj-code
  ,output v-object-available
  ) no-error .
            IF ERROR-STATUS :ERROR
                THEN
            DO:
                MESSAGE
                    vss-workfile vss-revision vss-description SKIP
                    "Ошибка при вызове процедуры gbl/usobjava.i" SKIP
                    ERROR-STATUS :GET-MESSAGE(1) SKIP
                    RETURN-VALUE SKIP
                    VIEW-AS ALERT-BOX ERROR .
                UNDO, RETURN NO-APPLY .
            END.
            IF v-object-available = TRUE
                THEN
            DO:
                CREATE t-obj-list .
                ASSIGN
                    t-obj-list.obj-type = clients.obj-type
                    t-obj-list.obj-code = clients.obj-code
                    no-error.
            END.
        END.
    END.
    RETURN.
    END METHOD.
    METHOD PUBLIC  VOID CreateTT ( INPUT DATASET FOR ds-vsd-set ,output TABLE ttvsd  ):
    FOR EACH ttvsd :
       DELETE ttvsd.
    END.
    FIND FIRST tt-vsd-filt NO-ERROR.
        DEFINE BUFFER goods       FOR ub.goods.
        DEFINE BUFFER trn-doc     FOR ub.trn-doc.
        DEFINE BUFFER clients     FOR ub.clients.
        DEFINE BUFFER bclients    FOR ub.clients.
        DEFINE VARIABLE vStatus      AS CHARACTER NO-UNDO.
        DEFINE VARIABLE vGdsChek     AS LOGICAL   NO-UNDO.
        DEFINE VARIABLE v-attr-type  AS CHARACTER NO-UNDO.
        DEFINE VARIABLE vOjd         AS INTEGER   NO-UNDO.
        DEFINE VARIABLE vI           AS INTEGER   NO-UNDO.
        DEFINE VARIABLE vsdsTHObj    AS CLASS     vsdsubs.
        DEFINE VARIABLE vsdTHObj     AS CLASS     vsdsub.
        DEFINE VARIABLE vsdsOneTHObj AS CLASS     vsdsubs.
        DEFINE VARIABLE vsdStorage   AS CLASS     vsdtostorage.
        FIND FIRST tt-vsd-filt NO-ERROR.
        IF tt-vsd-filt.ReqVerif THEN
            vStatus = vStatus + ",0".
        IF tt-vsd-filt.FalVerif THEN
            vStatus = vStatus + ",1".
        IF tt-vsd-filt.ToExtin THEN
            vStatus = vStatus + ",2".
        IF tt-vsd-filt.FalExting THEN
            vStatus = vStatus + ",3".
        IF tt-vsd-filt.Rep THEN
            vStatus = vStatus + ",4".
        IF tt-vsd-filt.sent THEN
            vStatus = vStatus + ",5".
        vStatus = SUBSTRING(vStatus,2).
        .
        FIND FIRST tt-gds-list NO-LOCK NO-ERROR.
        vGdsChek = AVAIL tt-gds-list.
        IF    tt-vsd-filt.doc-code EQ "?"
            OR tt-vsd-filt.doc-code EQ ""
            THEN tt-vsd-filt.doc-code = ?.
        DEFINE VARIABLE ml AS LOGICAL   NO-UNDO.
        vsdStorage = NEW vsdtostorage ().
        FOR EACH t-obj-list:
            vsdsTHObj = vsdStorage:getVSDsubs(t-obj-list.obj-type,t-obj-list.obj-code,vstatus).
            vsdsTHObj:IsDelChildObj = NO .
            Block-vsd:
            DO vi = 1 TO vsdsTHObj:GetItem (vi):
                FIND FIRST ttvsd WHERE ttVSD.ID         = vsdsTHObj:VsdObjCurr:ID
                    AND ttvsd.db-num       = vsdsTHObj:VsdObjCurr:DBNum
                    NO-ERROR.
                IF AVAIL ttvsd
                    THEN
                    NEXT Block-vsd.
                FIND FIRST trn-doc WHERE trn-doc.doc-code EQ ENTRY (8,vsdsTHObj:VsdObjCurr:PartKey,chr(3)) NO-LOCK NO-ERROR.
                IF NOT AVAIL trn-doc
                    THEN
                    NEXT Block-vsd.
                IF    trn-doc.doc-date < tt-vsd-filt.date-start
                    OR trn-doc.doc-date > tt-vsd-filt.date-end
                    OR (tt-vsd-filt.doc-code NE ?
                    AND NOT CAN-DO(tt-vsd-filt.doc-code,trn-doc.doc-code))
                    THEN
                    NEXT Block-vsd.
                FIND FIRST goods WHERE goods.gds-code EQ vsdsTHObj:VsdObjCurr:GdsCode NO-LOCK NO-ERROR.
                IF NOT AVAIL goods THEN NEXT Block-vsd.
                CASE  vGdsChek:
                    WHEN YES THEN
                        DO:
                            FIND FIRST tt-gds-list
                                WHERE tt-gds-list.artic     = goods.artic
                                AND tt-gds-list.prod-type = goods.prod-type
                                AND tt-gds-list.prod-code = goods.prod-code NO-ERROR .
                            IF NOT AVAILABLE tt-gds-list THEN NEXT Block-vsd.
                        END.
                    OTHERWISE .
                END.
                FIND FIRST  clients WHERE clients.obj-type EQ goods.prod-type
                    AND clients.obj-code EQ goods.prod-code
                    NO-LOCK NO-ERROR.
                FIND FIRST  bclients WHERE bclients.obj-type EQ  trn-doc.cli-type
                    AND bclients.obj-code EQ trn-doc.cli-code
                    NO-LOCK NO-ERROR.
                vOjd =  IF vsdsTHObj:VsdObjCurr:PendingRepayment THEN 0 ELSE TRUNC ((NOW - vsdsTHObj:VsdObjCurr:FactDatetime)/ (1000 * 60 * 60),0).
                IF    vOjd >= tt-vsd-filt.fTime
                    OR vsdsTHObj:VsdObjCurr:PendingRepayment
                    THEN
                DO:
                    vsdsOneTHObj = NEW vsdsubs ().
                    vsdsOneTHObj:AddItem(vsdsTHObj:VsdObjCurr).
                    CREATE ttvsd.
                    ttvsd.gds-name-merc = vsdsTHObj:VsdObjCurr:GdsMercName.
                    ttvsd.gds-guid      = vsdsTHObj:VsdObjCurr:GdsGUID.
                    ttvsd.gdsmercguid   = vsdsTHObj:VsdObjCurr:GdsMercGUID.
                    ttvsd.msg-err       = vsdsTHObj:VsdObjCurr:MsgErr.
                    ttvsd.gds-code      = vsdsTHObj:VsdObjCurr:GdsCode.
                    ttVSD.UUID          = vsdsTHObj:VsdObjCurr:UUID.
                    ttvsd.date-out      = vsdsTHObj:VsdObjCurr:DateOut.
                    ttvsd.date-cr       = vsdsTHObj:VsdObjCurr:DateCr.
                    ttvsd.expiry-date   = vsdsTHObj:VsdObjCurr:ExpiryDate.
                    ttvsd.expiry-date-2 = vsdsTHObj:VsdObjCurr:ExpiryDate2.
                    ttVSD.statusvsd     = vsdsTHObj:VsdObjCurr:StatusLbl.
                    ttVSD.ID            = vsdsTHObj:VsdObjCurr:ID.
                    ttvsd.db-num        = vsdsTHObj:VsdObjCurr:DBNum.
                    ttvsd.part-key      = vsdsTHObj:VsdObjCurr:PartKey.
                    ttvsd.obj-type      = vsdsTHObj:VsdObjCurr:ObjType.
                    ttvsd.obj-code      = vsdsTHObj:VsdObjCurr:ObjCode.
                    ttvsd.vsdtypelbl    = vsdsTHObj:VsdObjCurr:VSDTypeLbl.
                    ttVSD.COLobj        = vsdsTHObj:VsdObjCurr:Qnty.
                    ttvsd.vsdsubs       = CAST (vsdsOneTHObj  , Progress.Lang.Object).
                    ASSIGN
                        ttVSD.dateTTH    = trn-doc.doc-date
                        ttVSD.NomTTH     = trn-doc.doc-code
                        ttVSD.NomTTHpost = trn-doc.rcv-code
                        ttVSD.NomAZS     = STRING(t-obj-list.obj-code)
                        ttVSD.Post       = IF AVAIL bclients
                                           THEN bclients.obj-name
                        ELSE ""
                        ttVSD.artic      = goods.artic
                        ttVSD.gdsname    = goods.gds-name
                        ttVSD.prod-code  = IF AVAIL clients
                                           THEN clients.obj-name
                        ELSE ""
                        ttVSD.ojd        = vojd
                        .
                    if vsdsTHObj:VsdObjCurr:UnitGuid <> "" and vsdsTHObj:VsdObjCurr:UnitGuid <> ?
                    then do :
                      for first units-attr no-lock where units-attr.attr-code = "MercGuid"
                                                     and units-attr.attr-value = vsdsTHObj:VsdObjCurr:UnitGuid :
                        ttVSD.unit-cli = units-attr.unit-name .
                      end.
                    end.
                    RUN gbl/trdcat-v.p
                        ( INPUT trn-doc.doc-code
                        ,INPUT 'nids':U
                        ,OUTPUT ttVSD.NomTTHpost
                        ,OUTPUT v-attr-type
                        ).
                END.
            END.
            FINALLY:
                DELETE OBJECT vsdsTHObj  NO-ERROR.
            END FINALLY.
        END.
          FINALLY :
            DELETE OBJECT vsdStorage NO-ERROR .
        END FINALLY.
    END METHOD.
END CLASS.
