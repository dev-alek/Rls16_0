 
 /*------------------------------------------------------------------------
    File        : journal_vsd_trg
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : druban
    Created     : Thu Jun 14 09:21:16 MSK 2018
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.

USING ibs.th.str.mercury.*.
USING ibs.th.gbl.storage.*. 
 /*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$
 
Журнал ВСД

Автор: Рубан Дмитрий Андреевич
Дата создания: 30.05.2018
Author: Dmitriy Ruban
Creation date: 30/05/18

*/
BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS ibs.th.ref.journal_vsd_trg:
    DEFINE VARIABLE vss-revision       AS CHARACTER NO-UNDO INIT "$Revision$":U .
    DEFINE VARIABLE vss-author         AS CHARACTER NO-UNDO INIT "$Author$":U .
    DEFINE VARIABLE vss-date           AS CHARACTER NO-UNDO INIT "$Date$":U .
    DEFINE VARIABLE vss-workfile       AS CHARACTER NO-UNDO INIT "$Workfile$":U .
    DEFINE VARIABLE vss-archive        AS CHARACTER NO-UNDO INIT "$Archive$":U .
    DEFINE VARIABLE vss-description    AS CHARACTER NO-UNDO INIT "Журнал ВСД". 
    { cmp/library.i class} 
    { cmp/str-glbl.i class} 
    { bge/ds-vsd-set.i }
    { gbl/getcntxt.i def }
    DEFINE VARIABLE parparentproc AS HANDLE NO-UNDO.
    CONSTRUCTOR PUBLIC journal_vsd_trg (INPUT  pparparentproc AS HANDLE ):
    parparentproc = pparparentproc.
    { gbl/getcntxt.i get }
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
            RUN str/vsd.w (INPUT parparentproc, INPUT {&lookup}, INPUT vsdsubsObj, OUTPUT vSave).
        END.
        RETURN.

    END METHOD.
    METHOD PUBLIC  VOID VSD_edit(INPUT pID AS INTEGER  , INPUT pdb-num AS INTEGER,input pvsdsubs AS Progress.Lang.Object   ):
/*        message "Функционал находится в разработке." view-as alert-box. */
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
          RUN str/vsd.w (INPUT parparentproc, INPUT {&update}, INPUT vsdsubsObj, OUTPUT vSave).
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
                , INPUT {&lookup}
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
            ,INPUT {&lookup}
            ) no-error .
        RETURN.

    END METHOD.
    
    METHOD PUBLIC  VOID trn_doc_lock(INPUT ppart-key AS CHARACTER,INPUT pgds-code AS INTEGER ):
        DEFINE BUFFER doc-line FOR ub.doc-line.
    DEFINE BUFFER trn-doc  FOR ub.trn-doc.
    DEFINE BUFFER goods FOR ub.goods.
    DEFINE VARIABLE vlog AS LOGICAL NO-UNDO.
    FIND FIRST trn-doc WHERE trn-doc.doc-code EQ ENTRY (8,ppart-key,{&delim-key}) NO-LOCK NO-ERROR.
    
    IF AVAIL trn-doc
    THEN DO :
        CASE trn-doc.doc-type:
            WHEN {&income}
            THEN DO:
                { gbl/chk-actg.i
                    v-cntxt-db-num
                    v-cntxt-userid
                    {&action-head-code-main}
                    'actn_income_lookup':U
                    {&cntxt-object}
                    trn-doc.host-code
                    trn-doc.obj-type
                    trn-doc.obj-code
                    0
                    0
                    0
                    true
                    vlog
                  }
            END.
            WHEN {&expense}
            THEN DO:
                    { gbl/chk-actg.i
                        v-cntxt-db-num
                        v-cntxt-userid
                        {&action-head-code-main}
                        'actn_expense_lookup':U
                        {&cntxt-object}
                        trn-doc.host-code
                        trn-doc.obj-type
                        trn-doc.obj-code
                        0
                        0
                        0
                        true
                        vlog
                      }
            END.
            WHEN {&write-off}
            THEN DO:
                { gbl/chk-actg.i
                    v-cntxt-db-num
                    v-cntxt-userid
                    {&action-head-code-main}
                    'actn_write-off_lookup':U
                    {&cntxt-object}
                    trn-doc.host-code
                    trn-doc.obj-type
                    trn-doc.obj-code
                    0
                    0
                    0
                    true
                    vlog
                  }
            END .
            WHEN {&inventory}
            THEN DO:
                { gbl/chk-actg.i
                    v-cntxt-db-num
                    v-cntxt-userid
                    {&action-head-code-main}
                    'actn_inventory_lookup':U
                    {&cntxt-object}
                    trn-doc.host-code
                    trn-doc.obj-type
                    trn-doc.obj-code
                    0
                    0
                    0
                    true
                    vlog
                  }
            END.
            WHEN {&return}
            THEN DO:
                { gbl/chk-actg.i
                    v-cntxt-db-num
                    v-cntxt-userid
                    {&action-head-code-main}
                    'actn_return_lookup':U
                    {&cntxt-object}
                    trn-doc.host-code
                    trn-doc.obj-type
                    trn-doc.obj-code
                    0
                    0
                    0
                    true
                    vlog
                  }
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
            { gbl/usobjava.i
            v-cntxt-db-num
            {&action-head-code-main}
            v-cntxt-userid
            clients.obj-type
            clients.obj-code
            v-object-available
            no-error
          }
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
    /*------------------------------------------------------------------------------
              Purpose:
              Parameters:  <none>
              Notes:
            ------------------------------------------------------------------------------*/
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
                FIND FIRST trn-doc WHERE trn-doc.doc-code EQ ENTRY (8,vsdsTHObj:VsdObjCurr:PartKey,{&delim-key}) NO-LOCK NO-ERROR.
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
                    OTHERWISE . /* все товары */
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
                    ttVSD.UUID          = vsdsTHObj:VsdObjCurr:UUID.                    /*  "Номер ВСД"              "X(40)" */
                    ttvsd.date-out      = vsdsTHObj:VsdObjCurr:DateOut.
                    ttvsd.date-cr       = vsdsTHObj:VsdObjCurr:DateCr.
                    ttvsd.expiry-date   = vsdsTHObj:VsdObjCurr:ExpiryDate.
                    ttvsd.expiry-date-2 = vsdsTHObj:VsdObjCurr:ExpiryDate2.
                    ttVSD.statusvsd     = vsdsTHObj:VsdObjCurr:StatusLbl.          /*  "Статус ВСД"             "X(20)" */
                    ttVSD.ID            = vsdsTHObj:VsdObjCurr:ID.                
                    ttvsd.db-num        = vsdsTHObj:VsdObjCurr:DBNum.
                    ttvsd.part-key      = vsdsTHObj:VsdObjCurr:PartKey.
                    ttvsd.obj-type      = vsdsTHObj:VsdObjCurr:ObjType.
                    ttvsd.obj-code      = vsdsTHObj:VsdObjCurr:ObjCode.
                    ttvsd.vsdtypelbl    = vsdsTHObj:VsdObjCurr:VSDTypeLbl.
                    ttVSD.COLobj        = vsdsTHObj:VsdObjCurr:Qnty.            /*  "Кол-во ВСД"            "X(15)" */
                    
                    
                    ttvsd.vsdsubs       = CAST (vsdsOneTHObj /* :VsdObjCurr*/ , Progress.Lang.Object).
                    ASSIGN                          
                        ttVSD.dateTTH    = trn-doc.doc-date            /*  "Номер ТТН"              "X(20)" */
                        ttVSD.NomTTH     = trn-doc.doc-code            /*  "Номер ТТН"              "X(20)" */
                        ttVSD.NomTTHpost = trn-doc.rcv-code            /*  "Номер ТТН поставщика"   "X(20)" */
                        ttVSD.NomAZS     = STRING(t-obj-list.obj-code)   /*  "№ АЗС"                  ?  */
                        ttVSD.Post       = IF AVAIL bclients 
                                           THEN bclients.obj-name
                        ELSE ""                     /*  "Поставщик"              "X(20)" */
                        ttVSD.artic      = goods.artic                 /*  "Артикул товара"         "X(20)" */ 
                        ttVSD.gdsname    = goods.gds-name              /*  "Наименование товара"    "X(30)" */
                        ttVSD.prod-code  = IF AVAIL clients 
                                           THEN clients.obj-name
                        ELSE ""                     /*  "Производитель"          "X(20)" */
                        
/*                        ttVSD.unit-cli   = goods.unit-cli              /*  "Ед.изм."                "X(6)" */ */
/*                        ttVSD.unit-base  = goods.unit-base              /*  "Ед.изм."                "X(6)" */*/
                        ttVSD.ojd        = vojd                             /*  "Ожидает гашения"        "X(20)" */
                    
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
                        ,INPUT {&trdcattr-nids }
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