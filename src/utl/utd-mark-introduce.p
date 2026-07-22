block-level on error undo, throw.

/*------------------------------------------------------------------------
    File        : utd-mark-introduce.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : SSlivenko
    Created     : Fri Apr 10 13:45:13 AST 2020
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
define variable vss-revision    as character no-undo init "$Revision: 21edbbf42a72, 2617, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: Пн окт 19 09:22:02 2020 +0300 $":U .
define variable vss-Workfile    as character no-undo init "$Workfile: utd-mark-introduce.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/utd-mark-introduce.p $":U .
define variable vss-description as character no-undo init "Ввод в оборот табачных марок (распределение по свободной зоне)" .
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/thbjattr.i }

{ str/utd-err.i }
{ gbl/key-rec.i}
{ gbl/objsrv.i }
define input parameter pDb-num as integer no-undo .
define input parameter pDoc-id as integer no-undo .

define buffer buf_utd for ub.utd .
define buffer buf2_utd for ub.utd .
define buffer buf_marking for ub.marking .
define buffer new_marking for ub.marking .
define buffer buf_marking-childs for ub.marking .
define buffer buf_marking-lines for ub.marking-lines .
define buffer buf_marking-lines-childs for ub.marking-lines .
define buffer buf_utd-marking-lines for ub.utd-marking-lines .
define buffer buf_goods for ub.goods .
define buffer buf_parts for ub.parts .
define buffer buf_cash-desk for ub.cash-desk .

define buffer buf_trn-doc for ub.trn-doc .
define buffer buf_doc-line for ub.doc-line .
define buffer buf_gds-dtl for ub.gds-dtl .
define buffer buf_chk-doc for ub.chk-doc .
define buffer buf_marking-chk for ub.marking-chk .

define temp-table tt-utd-marking-lines like ub.utd-marking-lines .
define buffer buf_utd-marking-lines-childs for tt-utd-marking-lines .

define buffer buf_utd-lines for ub.utd-lines .
define buffer buf_utd-lines-attr for ub.utd-lines-attr .

define temp-table tt-mark-qnty no-undo
  field gds-code  as integer
  field marq-qnty as integer
  field tech-qnty as integer
  index pi as primary unique
    gds-code
.

define temp-table tt-bad-gds no-undo
  field gds-code as integer
.
  
define variable v-ok          as logical no-undo .
define variable v-parts-qnty  as decimal no-undo .
define variable v-marks-qnty  as integer no-undo .
define variable v-delta-qnty  as integer no-undo .
define variable v-num-childs  as integer no-undo .
define variable ii            as integer no-undo .

define variable v-err-gds       as integer no-undo .
define variable v-err-units     as integer no-undo .
define variable v-ok-packs      as integer no-undo .
define variable v-ok-units      as integer no-undo .
define variable v-created-units as integer no-undo .
define variable v-curr-cnt      as integer no-undo .
define variable v-curr-created-units as integer no-undo .

define variable MSG as character no-undo .


define variable cmd as character no-undo .

define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-param-type as character no-undo .
define variable v-param-value as character no-undo .
define variable v-mark-type as character no-undo .

define variable v-tth     as handle no-undo .

define variable conf-par as character no-undo .
define variable par-type as character no-undo .
define variable v-1C     as logical   no-undo .

define temp-table tt-gds-list
  field gds-code as integer
.

/* ***************************  Main Block  *************************** */

  { gbl/conf-rd.i
       "'is-erpRN'"
       0
       "''"
       0
       "''"
       "''"
       "''"
       NO
       conf-par
       par-type
       no-error
  }
  IF not error-status:error and conf-par = "yes":U 
  then do: 
    v-1C = true .
  end .
  else do :
    v-1C = false .
  end .
  assign v-ok = true .
  find first buf_utd no-lock where buf_utd.db-num = pDb-num
                               and buf_utd.doc-id = pDoc-id
                               no-error .
  if not available buf_utd
  then do :
    MSG = "Не найден УПД в БД " + string(pDb-num) + " c doc-id " + string(pDoc-id) .
    return error MSG .
  end.       
  
  assign
    v-err-gds       = 0 
    v-err-units     = 0
    v-ok-packs      = 0
    v-ok-units      = 0
    v-created-units = 0
  .
  
  for each buf_utd-lines no-lock where buf_utd-lines.db-num = pDb-num
                                   and buf_utd-lines.doc-id = pDoc-id
                                   :
    find first buf_utd-marking-lines no-lock where buf_utd-marking-lines.db-num   = buf_utd-lines.db-num        
                                               and buf_utd-marking-lines.doc-id   = buf_utd-lines.doc-id
                                               and buf_utd-marking-lines.LineNum  = buf_utd-lines.LineNum
                                               and buf_utd-marking-lines.gds-code = buf_utd-lines.gds-code
                                               no-error .
    if not available buf_utd-marking-lines
    then do :
      find first buf_utd-lines-attr no-lock where buf_utd-lines-attr.db-num    = buf_utd-lines.db-num
                                              and buf_utd-lines-attr.doc-id    = buf_utd-lines.doc-id
                                              and buf_utd-lines-attr.LineNum   = buf_utd-lines.LineNum
                                              and buf_utd-lines-attr.attr-code = "NoMarking"
                                              no-error .
      if available buf_utd-lines-attr
      and buf_utd-lines-attr.attr-value > ""
      then do :
        find first tt-mark-qnty exclusive-lock where tt-mark-qnty.gds-code  = buf_utd-lines.gds-code no-error .
        if not available tt-mark-qnty
        then do :
          create tt-mark-qnty .
          assign
            tt-mark-qnty.gds-code  = buf_utd-lines.gds-code
            tt-mark-qnty.tech-qnty = integer(buf_utd-lines-attr.attr-value)
          no-error .
          if error-status:error
          then do :
            delete tt-mark-qnty .
            v-err-gds = v-err-gds + 1 .
          end .
        end.
      end .
      else do :
        v-err-gds = v-err-gds + 1 .
      end .                                        
    end .                                                                    
  end .
  
  empty temp-table tt-utd-marking-lines .
  for each buf_utd-marking-lines no-lock where  buf_utd-marking-lines.db-num = pDb-num
                                            and buf_utd-marking-lines.doc-id = pDoc-id :
    create tt-utd-marking-lines .  
    buffer-copy buf_utd-marking-lines to tt-utd-marking-lines . 
    find first tt-gds-list where tt-gds-list.gds-code = tt-utd-marking-lines.gds-code no-error.
    if not available tt-gds-list
    then do :
      create tt-gds-list .
      assign
        tt-gds-list.gds-code = tt-utd-marking-lines.gds-code
      .
    end .                                       
  end .
  
  for each buf2_utd no-lock where buf2_utd.obj-type = buf_utd.obj-type
                              and buf2_utd.obj-code = buf_utd.obj-code
                              and buf2_utd.EDocType = objSrv:Env:Utd:EDocType:UTD:KeyIntDB
                              and buf2_utd.sts = objSrv:Env:Utd:Sts:TH:Confirmed:KeyIntDB
                              and buf2_utd.LoadDate >= buf_utd.LoadDate
                              :
    if buf2_utd.LoadDate = buf_utd.LoadDate
    and buf2_utd.LoadTime <= buf_utd.LoadTime
    then next .
    for each buf_utd-marking-lines no-lock where  buf_utd-marking-lines.db-num = buf2_utd.db-num
                                              and buf_utd-marking-lines.doc-id = buf2_utd.doc-id :
      find first tt-gds-list where tt-gds-list.gds-code = buf_utd-marking-lines.gds-code no-error.
      if not available tt-gds-list then next .
      create tt-utd-marking-lines .  
      buffer-copy buf_utd-marking-lines to tt-utd-marking-lines .                                        
    end .                            
  end .
  
  check_ :                      
  for each tt-utd-marking-lines no-lock,
  first buf_marking no-lock where buf_marking.mark = tt-utd-marking-lines.mark :
    if buf_marking.sts = objSrv:Env:Marking:Sts:Mark:OutZone:KeyIntDB
    then do :
      delete tt-utd-marking-lines .
      
      next check_ .
    end .
    
    find first buf_marking-chk no-lock where buf_marking-chk.mark begins buf_marking.mark no-error .
    if available buf_marking-chk
    then do :
      find first buf_chk-doc no-lock where buf_chk-doc.doc-code = buf_marking-chk.doc-code
                                       and buf_chk-doc.chk-date >= buf_utd.LoadDate
                                       no-error .
      if available buf_chk-doc
      then do :
        if buf_chk-doc.chk-date = buf_utd.LoadDate
        and buf_chk-doc.chk-time <= buf_utd.LoadTime
        then .
        else do :
          find first buf_trn-doc no-lock where buf_trn-doc.doc-code = buf_chk-doc.out-code
                                           and buf_trn-doc.status_ = {&fact}
                                           no-error .
          if available buf_trn-doc
          then do :
            delete tt-utd-marking-lines .
            find first ub.marking exclusive-lock where rowid(ub.marking) = rowid(buf_marking) .
            ub.marking.sts = objSrv:Env:Marking:Sts:Mark:OutZone:KeyIntDB .
            release ub.marking .
            
            next check_ .
          end .
          else do :
            find first buf_goods no-lock where buf_goods.gds-code     = buf_marking.gds-code .
            for each buf_gds-dtl no-lock where buf_gds-dtl.doc-code   = buf_chk-doc.out-code
                                           and buf_gds-dtl.artic      = buf_goods.artic
                                           and buf_gds-dtl.prod-type  = buf_goods.prod-type
                                           and buf_gds-dtl.prod-code  = buf_goods.prod-code
                                           :
              if buf_gds-dtl.doc-qnty = buf_gds-dtl.fact-qnty
              then do :
                message "Закройте все зарезервированные продажи!" view-as alert-box .
                return error .
              end .                               
            end .          
          end .
        end . 
      end .  /* if available buf_chk-doc */
    end .  /* if available buf_marking-chk */
    
    if buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:Checked_:KeyIntDB
    and buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:MarkError:KeyIntDB
    and buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:GrayZone:KeyIntDB
    and buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:Ungrouped:KeyIntDB
    then do :
      assign v-ok = false .
      MSG = "Марка " + buf_marking.mark + " в статусе " + objSrv:Env:Marking:Sts:Mark:GetLabel(buf_marking.sts) .
      message MSG view-as alert-box .
      return error MSG . 
    end . 
    
    if buf_marking.loc-key <> ""
    then do :
      assign v-ok = false .
    end .  
    
    if buf_marking.unit-ext = "LEVEL1"
    then do :
      if buf_marking.sts = objSrv:Env:Marking:Sts:Mark:GrayZone:KeyIntDB
      then do : 
        assign v-ok = false .
        find first tt-bad-gds where tt-bad-gds.gds-code = buf_marking.gds-code no-error .
        if not available tt-bad-gds
        then do :
          create tt-bad-gds.
          assign tt-bad-gds.gds-code = buf_marking.gds-code .
        end .
        AddUtdErr(input buf_utd.db-num,
                  input buf_utd.doc-id,
                  input buffer buf_marking:handle,
                  input "FirstInput",
                  input "GrayZone",
                  input (buf_marking.mark + {&delim-par} + " блок в серой зоне (нет полной информации по его пачкам)")).
      end .
      else do :
        find first buf_marking-childs no-lock where buf_marking-childs.mark-parent = buf_marking.mark no-error .
        if not available buf_marking-childs
        then do :
          assign v-ok = false .
          find first tt-bad-gds where tt-bad-gds.gds-code = buf_marking.gds-code no-error .
          if not available tt-bad-gds
          then do :
            create tt-bad-gds.
            assign tt-bad-gds.gds-code = buf_marking.gds-code .
          end .
          AddUtdErr(input buf_utd.db-num,
                    input buf_utd.doc-id,
                    input buffer buf_marking:handle,
                    input "FirstInput",
                    input "Level1Empty",
                    input (buf_marking.mark + {&delim-par} + "для этого блока в базе нет марок пачек")).
        end .
      end .
      next .
    end .
    
    find first tt-mark-qnty exclusive-lock where tt-mark-qnty.gds-code  = buf_marking.gds-code no-error .
    if not available tt-mark-qnty
    then do :
      create tt-mark-qnty .
      assign
        tt-mark-qnty.gds-code  = buf_marking.gds-code
        tt-mark-qnty.tech-qnty = 0
      .
      for first buf_utd-lines no-lock where buf_utd-lines.db-num    = buf_utd.db-num
                                        and buf_utd-lines.doc-id    = buf_utd.doc-id
                                        and buf_utd-lines.gds-code  = tt-mark-qnty.gds-code,
      first buf_utd-lines-attr no-lock where buf_utd-lines-attr.db-num    = buf_utd-lines.db-num
                                         and buf_utd-lines-attr.doc-id    = buf_utd-lines.doc-id
                                         and buf_utd-lines-attr.LineNum   = buf_utd-lines.LineNum
                                         and buf_utd-lines-attr.attr-code = "NoMarking"                                  
                                         :
        assign
          tt-mark-qnty.tech-qnty = integer(buf_utd-lines-attr.attr-value)
        no-error .                                  
      end .
    end .
    if buf_marking.unit-ext = "UNIT"
    then
    assign tt-mark-qnty.marq-qnty = tt-mark-qnty.marq-qnty + 1 .                                  
  end . 
  
  for each tt-mark-qnty no-lock :
    find first tt-bad-gds where tt-bad-gds.gds-code = tt-mark-qnty.gds-code no-error .
    if available tt-bad-gds
    then do :
      v-err-gds = v-err-gds + 1 .
      next .
    end .
    assign
      v-parts-qnty = 0
      v-curr-created-units = 0
    .
    find first buf_goods no-lock where buf_goods.gds-code = tt-mark-qnty.gds-code .
    for each buf_parts no-lock where buf_parts.obj-type   = buf_utd.obj-type
                                 and buf_parts.obj-code   = buf_utd.obj-code
                                 and buf_parts.artic      = buf_goods.artic
                                 and buf_parts.prod-type  = buf_goods.prod-type
                                 and buf_parts.prod-code  = buf_goods.prod-code
                                 and buf_parts.out-code   = {&free-code}
                                 :
      assign v-parts-qnty = v-parts-qnty + buf_parts.qnty .
      for each buf_marking-lines no-lock where buf_marking-lines.obj-type   = buf_parts.obj-type
                                           and buf_marking-lines.obj-code   = buf_parts.obj-code
                                           and buf_marking-lines.gds-code   = buf_goods.gds-code
                                           and buf_marking-lines.in-code    = buf_parts.in-code
                                           and buf_marking-lines.out-code   = buf_parts.out-code
                                           and buf_marking-lines.part-code  = buf_parts.part-code,
      first buf_marking no-lock where buf_marking.mark = buf_marking-lines.mark
                                  and buf_marking.unit-ext = "UNIT"
                                  :
        assign v-parts-qnty = v-parts-qnty - 1 .
      end .
    end .
    
    assign v-marks-qnty = tt-mark-qnty.marq-qnty .
    assign v-delta-qnty = v-parts-qnty - v-marks-qnty .
    
    if v-delta-qnty <> tt-mark-qnty.tech-qnty
    then do :
      AddUtdErr(input buf_utd.db-num,
                input buf_utd.doc-id,
                input buffer buf_goods:handle,
                input "FirstInput",
                input "QntyErr",
                input string(buf_goods.gds-code) + {&delim-par} + 
                      string(v-marks-qnty) + {&delim-par} + 
                      string(tt-mark-qnty.tech-qnty) + {&delim-par} + 
                      string(v-parts-qnty) ) .
      v-err-gds = v-err-gds + 1 .
      next .
    end .
    
    if v-parts-qnty > v-marks-qnty
    then do :
      find last ub.marking no-lock where ub.marking.mark begins ({&tech-mark-prefix} + string(pDb-num)) no-error .
      if available ub.marking
      then assign v-curr-cnt = integer(entry(3, ub.marking.mark, "_")) + 1 .
      else assign v-curr-cnt = 1 .
      
      do ii = 1 to v-delta-qnty :
        create new_marking .
        assign
          new_marking.mark = {&tech-mark-prefix} + string(pDb-num) + "_" + string(v-curr-cnt, "999999")
          new_marking.sts  = objSrv:Env:Marking:Sts:Mark:Checked_:KeyIntDB
          new_marking.obj-type = buf_utd.obj-type
          new_marking.obj-code = buf_utd.obj-code
          new_marking.unit-ext = "UNIT"
          new_marking.gds-code = buf_goods.gds-code
          new_marking.box-qnty = 1
          v-curr-cnt = v-curr-cnt + 1
          v-created-units = v-created-units + 1
          v-curr-created-units = v-curr-created-units + 1
        .
/*        if v-1C                                                   */
/*        then do :                                                 */
/*          { gbl/rum-runa.i                                        */
/*            ?                                                     */
/*            this-procedure:handle                                 */
/*            ?                                                     */
/*            {&edoc-proc_event_mark}                               */
/*            " buffer new_marking:handle "                         */
/*            ?                                                     */
/*              ''                                                  */
/*            ''                                                    */
/*            no-error                                              */
/*          }                                                       */
/*        end .                                                     */
/*        else do :                                                 */
/*          run str/callnews.p (  input {&table_marking}            */
/*                               ,input (buffer new_marking:handle )*/
/*                              ) no-error .                        */
/*        end .                                                     */
        create tt-utd-marking-lines .
        assign
          tt-utd-marking-lines.mark = new_marking.mark
          tt-utd-marking-lines.gds-code = new_marking.gds-code
          tt-utd-marking-lines.doc-level = 1
        .
      end .
    end .
    
    assign v-marks-qnty = v-marks-qnty + v-curr-created-units .
    
    if v-parts-qnty <> v-marks-qnty
    then do :
      AddUtdErr(input buf_utd.db-num,
                input buf_utd.doc-id,
                input buffer buf_goods:handle,
                input "FirstInput",
                input "QntyErr",
                input string(buf_goods.gds-code) + {&delim-par} + 
                      string(v-marks-qnty) + {&delim-par} + 
                      string(tt-mark-qnty.tech-qnty) + {&delim-par} + 
                      string(v-parts-qnty) ) .
      v-err-gds = v-err-gds + 1 .
      next .
    end .
    else do :
      
      allocation_ :
      for each buf_parts no-lock where buf_parts.obj-type   = buf_utd.obj-type
                                   and buf_parts.obj-code   = buf_utd.obj-code
                                   and buf_parts.artic      = buf_goods.artic
                                   and buf_parts.prod-type  = buf_goods.prod-type
                                   and buf_parts.prod-code  = buf_goods.prod-code
                                   and buf_parts.out-code   = {&free-code}
                                   :
        assign 
          v-parts-qnty = buf_parts.qnty
        . 
        for each buf_marking-lines no-lock where buf_marking-lines.obj-type   = buf_parts.obj-type
                                             and buf_marking-lines.obj-code   = buf_parts.obj-code
                                             and buf_marking-lines.gds-code   = buf_goods.gds-code
                                             and buf_marking-lines.in-code    = buf_parts.in-code
                                             and buf_marking-lines.out-code   = buf_parts.out-code
                                             and buf_marking-lines.part-code  = buf_parts.part-code,
        first buf_marking no-lock where buf_marking.mark = buf_marking-lines.mark
                                    and buf_marking.unit-ext = "UNIT"
                                    :
          assign v-parts-qnty = v-parts-qnty - 1 .
        end . 
          
        for each tt-utd-marking-lines exclusive-lock where tt-utd-marking-lines.gds-code = buf_goods.gds-code
                                                       and tt-utd-marking-lines.doc-level = 1 ,
        first buf_marking exclusive-lock where buf_marking.mark = tt-utd-marking-lines.mark
                                           break by buf_marking.unit-ext
/*                                             and buf_marking.sts = ObjSrv:Env:Marking:Sts:Mark:CheckContr:KeyIntDB*/
                                           :
          find first buf_marking-lines no-lock where buf_marking-lines.gds-code    = tt-utd-marking-lines.gds-code
                                                 and buf_marking-lines.mark        = tt-utd-marking-lines.mark
                                                 and buf_marking-lines.obj-type    = buf_utd.obj-type
                                                 and buf_marking-lines.obj-code    = buf_utd.obj-code
                                                 and buf_marking-lines.in-code     = buf_parts.in-code
                                                 and buf_marking-lines.out-code    = buf_parts.out-code
                                                 and buf_marking-lines.part-code   = buf_parts.part-code
                                                 no-error .
          if not available buf_marking-lines
          then do :      
            if v-parts-qnty < 10
            and buf_marking.unit-ext = "LEVEL1"
            then do :  
              assign
                buf_marking.sts = ObjSrv:Env:Marking:Sts:Mark:MarkError:KeyIntDB
              .
              AddUtdErr(input buf_utd.db-num,
                        input buf_utd.doc-id,
                        input buffer buf_marking:handle,
                        input "FirstInput",
                        input "Level1FreeErr",
                        input (buf_marking.mark + {&delim-par} + "пачки этого блока распределились в разные партии")).
            end .
            else do :       
              if buf_marking.sts <> ObjSrv:Env:Marking:Sts:Mark:MarkError:KeyIntDB
              or buf_marking.unit-ext = "UNIT"
              then do :  
                if not (buf_marking.sts = ObjSrv:Env:Marking:Sts:Mark:Ungrouped:KeyIntDB and buf_marking.unit-ext = "LEVEL1")   
                then do :                 
                  create buf_marking-lines .
                  assign
                    buf_marking-lines.gds-code    = tt-utd-marking-lines.gds-code
                    buf_marking-lines.mark        = tt-utd-marking-lines.mark
                    buf_marking-lines.obj-type    = buf_utd.obj-type
                    buf_marking-lines.obj-code    = buf_utd.obj-code
                    buf_marking-lines.in-code     = buf_parts.in-code
                    buf_marking-lines.out-code    = buf_parts.out-code
                    buf_marking-lines.part-code   = buf_parts.part-code
                    buf_marking-lines.doc-level   = tt-utd-marking-lines.doc-level
    /*                buf_marking-lines.sts         = ObjSrv:Env:Marking:Sts:Mark:FreeZone:KeyIntDB*/
                  .
                  if not v-1C
                  then do :
                    run str/callnews.p (  input {&table_marking-lines}
                                         ,input (buffer buf_marking-lines:handle )
                                        ) no-error .
                  end .
                end.                    
              end .
            end .
          end .
          if buf_marking.sts = ObjSrv:Env:Marking:Sts:Mark:Checked_:KeyIntDB
          then do :
            assign
              buf_marking.sts = ObjSrv:Env:Marking:Sts:Mark:FreeZone:KeyIntDB
              buf_marking.loc-key = ""
            .
          end .
          else do :
            assign
              buf_marking.sts = ObjSrv:Env:Marking:Sts:Mark:MarkError:KeyIntDB
/*                buf_marking.loc-key = ""*/
            .
          end .
          if v-1C
          then do :
/*            { gbl/rum-runa.i               */
/*              ?                            */
/*              this-procedure:handle        */
/*              ?                            */
/*              {&edoc-proc_event_mark}      */
/*              " buffer buf_marking:handle "*/
/*              ?                            */
/*                ''                         */
/*              ''                           */
/*              no-error                     */
/*            }                              */
          end .
          else do :
            run str/callnews.p (  input {&table_marking}
                                 ,input (buffer buf_marking:handle )
                                ) no-error .
          end .                    
          if buf_marking.unit-ext = "LEVEL1"
          then do :
            assign v-num-childs = 0 .
            for each buf_marking-childs no-lock where buf_marking-childs.mark-parent = buf_marking.mark,
            first buf_utd-marking-lines-childs no-lock where buf_utd-marking-lines-childs.gds-code = buf_goods.gds-code
                                                         and buf_utd-marking-lines-childs.mark = buf_marking-childs.mark
                                                         :
              assign v-num-childs = v-num-childs + 1 .                                          
            end .
            for each buf_marking-childs exclusive-lock where buf_marking-childs.mark-parent = buf_marking.mark,
            first buf_utd-marking-lines-childs exclusive-lock where buf_utd-marking-lines-childs.gds-code = buf_goods.gds-code
                                                                and buf_utd-marking-lines-childs.mark = buf_marking-childs.mark
                                                                :
              find first buf_marking-lines-childs no-lock where buf_marking-lines-childs.gds-code    = buf_utd-marking-lines-childs.gds-code
                                                            and buf_marking-lines-childs.mark        = buf_utd-marking-lines-childs.mark
                                                            and buf_marking-lines-childs.obj-type    = buf_utd.obj-type
                                                            and buf_marking-lines-childs.obj-code    = buf_utd.obj-code
                                                            and buf_marking-lines-childs.in-code     = buf_parts.in-code
                                                            and buf_marking-lines-childs.out-code    = buf_parts.out-code
                                                            and buf_marking-lines-childs.part-code   = buf_parts.part-code
                                                            and buf_marking-lines-childs.prt-code    = buf_parts.prt-code
                                                            no-error .
              if not available buf_marking-lines-childs
              then do :  
                create buf_marking-lines-childs .
                assign
                  buf_marking-lines-childs.gds-code    = buf_utd-marking-lines-childs.gds-code
                  buf_marking-lines-childs.mark        = buf_utd-marking-lines-childs.mark
                  buf_marking-lines-childs.obj-type    = buf_utd.obj-type
                  buf_marking-lines-childs.obj-code    = buf_utd.obj-code
                  buf_marking-lines-childs.in-code     = buf_parts.in-code
                  buf_marking-lines-childs.out-code    = buf_parts.out-code
                  buf_marking-lines-childs.part-code   = buf_parts.part-code
                  buf_marking-lines-childs.prt-code    = buf_parts.prt-code
                  buf_marking-lines-childs.doc-level   = buf_utd-marking-lines-childs.doc-level
    /*                buf_marking-lines.sts         = ObjSrv:Env:Marking:Sts:Mark:FreeZone:KeyIntDB*/
                .
                if not v-1C
                then do :
                  run str/callnews.p (  input {&table_marking-lines}
                                       ,input (buffer buf_marking-lines-childs:handle )
                                      ) no-error .
                end .                      
              end .    
              if buf_marking.sts = ObjSrv:Env:Marking:Sts:Mark:MarkError:KeyIntDB
              then do :
                assign buf_marking-lines-childs.doc-level   = 1 .
              end .
              if buf_marking-childs.sts = ObjSrv:Env:Marking:Sts:Mark:Checked_:KeyIntDB
              then do :
                assign
                  buf_marking-childs.sts = ObjSrv:Env:Marking:Sts:Mark:FreeZone:KeyIntDB
                  buf_marking-childs.loc-key = ""
                .
              end .
              else do :
                assign
                  buf_marking-childs.sts = ObjSrv:Env:Marking:Sts:Mark:MarkError:KeyIntDB
    /*                buf_marking.loc-key = ""*/
                .
                v-err-units = v-err-units + 1 .
              end .
              if v-1C
              then do :
/*                { gbl/rum-runa.i                      */
/*                  ?                                   */
/*                  this-procedure:handle               */
/*                  ?                                   */
/*                  {&edoc-proc_event_mark}             */
/*                  " buffer buf_marking-childs:handle "*/
/*                  ?                                   */
/*                    ''                                */
/*                  ''                                  */
/*                  no-error                            */
/*                }                                     */
              end .
              else do :
                run str/callnews.p (  input {&table_marking}
                                     ,input (buffer buf_marking-childs:handle )
                                    ) no-error .
              end .
              assign
                v-parts-qnty = v-parts-qnty - 1
                v-marks-qnty = v-marks-qnty - 1
              .    
              assign v-ok-units = v-ok-units + 1 .
              delete buf_utd-marking-lines-childs no-error . 
              assign v-num-childs = v-num-childs - 1 .
              if v-num-childs = 0
              then do :
                delete tt-utd-marking-lines no-error .
              end .
              if v-marks-qnty = 0 then leave allocation_ .
              if v-parts-qnty < 1 then next allocation_ .                                  
            end .
            v-ok-packs = v-ok-packs + 1 .
          end .
          if buf_marking.unit-ext = "UNIT"
          then do :
            assign
              v-parts-qnty = v-parts-qnty - 1
              v-marks-qnty = v-marks-qnty - 1
            .
            v-ok-units = v-ok-units + 1 .
            if buf_marking.sts = ObjSrv:Env:Marking:Sts:Mark:MarkError:KeyIntDB
            then
              v-err-units = v-err-units + 1 .
          end .
          delete tt-utd-marking-lines no-error .
          if v-marks-qnty = 0 then leave allocation_ .
          if v-parts-qnty < 1 then next allocation_ .
        end .                           
      end . /* allocation_ */
                                 
    end . /* qnty compare */
  end . /* for each tt-mark-qnty */
  
  /* Выставление параметров и отсылка на кассу */
  
  assign
    v-tth      = buffer thbjattr_thbj-attr:table-handle
  .
  run adm/shattri.p (
      input "init":U
    , input buf_utd.obj-type
    , input buf_utd.obj-code
    , input {&attr-marking}
    , input "":U
    , output v-value-character
    , output v-value-date
    , output v-value-decimal
    , output v-value-integer
    , output v-value-logical
    , output v-param-type
    , input-output TABLE-HANDLE v-tth
    ) no-error .
  if error-status:error then do:
    message
    "Не удалось получить начальные значения настроек" skip
    error-status:get-message(1) return-value
    view-as alert-box error .
    undo, return error .
  end.
  
  for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = {&attr-marking_marking-type}
    then do :
      v-mark-type = thbjattr_thbj-attr.property-value-character.
      if v-mark-type = ? then v-mark-type = "" .
      if lookup (v-mark-type, "tabak") = 0
      then do :
        if v-mark-type = ""
        then
          thbjattr_thbj-attr.property-value-character = "tabak" .
        else
          thbjattr_thbj-attr.property-value-character = v-mark-type + ",tabak" .
      end .
    end .
  end .
  
  do transaction:
    RUN thbjattr_set-section IN THIS-PROCEDURE (
         input buf_utd.obj-type
        ,input buf_utd.obj-code
        ,input {&attr-marking}
        ,INPUT table thbjattr_thbj-attr
    ) NO-ERROR.
    if error-status:error then do:
        message "Не удалось сохранить настройки"
        view-as alert-box.
        undo, return error.
    end.
  end.
  
  if search ("exe/POSParMark.xml") > ""
  then
  for each buf_cash-desk no-lock where buf_cash-desk.db-num   = buf_utd.db-num
                                   and buf_cash-desk.obj-code = buf_utd.obj-code
                                   and buf_cash-desk.pos-type = {&cd-type-ibm-xml} 
                                   and buf_cash-desk.cash-on :
    assign
      cmd = substitute('&1 -X POST -H "Content-Type: text/xml" -d @&2 &3 >&4'
                      , search ("exe/curl.exe")
                      , search ("exe/POSParMark.xml")
                      , (entry(1, buf_cash-desk.addr-path, {&delim-par}) + '://' + entry(2, buf_cash-desk.addr-path, {&delim-par}))
                      , "cashParResp.txt")
    .          
    os-command silent value (cmd) .                       
  end .
  
  if v-err-gds > 0
  then do :
    message
      "Ввод в оборот завершен!" skip
      "Распределено " string(v-ok-units) " пачек." skip
      "Из них ошибочных - " string(v-err-units) skip
      "Создано " string(v-created-units) " технических марок." skip
      "НЕ распределено " string(v-err-gds) " товаров."
    view-as alert-box .
  end .
  else do :
    message
      "Ввод в оборот завершен!" skip
      "Распределено " string(v-ok-units) " пачек." skip
      "Из них ошибочных - " string(v-err-units) skip
      "Создано " string(v-created-units) " технических марок." skip
    view-as alert-box .
  end .
