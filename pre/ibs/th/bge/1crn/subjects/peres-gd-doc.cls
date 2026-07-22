using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.*.
using ibs.th.str.*.
block-level on error undo, throw.
class ibs.th.bge.1crn.subjects.peres-gd-doc implements iexpsubject:
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define temp-table bf_trn-doc like ub.trn-doc.
  define buffer bf_doc-line        for ub.doc-line.
  define buffer bf_goods           for ub.goods.
  define buffer bf-plus_doc-line   for ub.doc-line.
  define buffer bf-plus_goods      for ub.goods.
  define buffer bf_parts           for ub.parts.
  define buffer bf-plus_parts      for ub.parts.
  define buffer bf_parts-root      for ub.parts-root.
  define temp-table tt-doc-line-cashe no-undo
  field doc-code  like ub.doc-line.doc-code
  field artic     like ub.doc-line.artic
  field prod-type like ub.doc-line.prod-type
  field prod-code like ub.doc-line.prod-code
  field qnty      as   decimal
  field sum-rubl  as   decimal
  field sum-base  as   decimal
  field vat-rubl  as   decimal
  field vat-base  as   decimal
  index pi is unique primary doc-code artic prod-type prod-code.
  define temp-table tt-doc-line-cashe-plus no-undo
  field doc-code     like ub.doc-line.doc-code
  field wf-artic     like ub.doc-line.artic
  field wf-prod-type like ub.doc-line.prod-type
  field wf-prod-code like ub.doc-line.prod-code
  field artic     like ub.doc-line.artic
  field prod-type like ub.doc-line.prod-type
  field prod-code like ub.doc-line.prod-code
  field qnty               as decimal
  field sum-rubl           as decimal
  field sum-base           as decimal
  field vat-rubl           as decimal
  field vat-base           as decimal
  field write-off-qnty     as decimal
  field write-off-sum-rubl as decimal
  field write-off-sum-base as decimal
  index pi is unique primary doc-code wf-artic wf-prod-type wf-prod-code artic prod-type prod-code.
  define temp-table tt-clcparts no-undo like ub.parts
  field part-cur-base like ub.gds-dtl.price-base
  field part-cur-road-tax like ub.gds-dtl.price-base
  field part-cur-excise like ub.gds-dtl.price-base
  .
define temp-table tt-allsum no-undo
field sum-type           as   character
field fact-qnty             as decimal
field cli-qnty              as decimal
field sum-dsc-base-doc      as decimal
field sum-dsc-rubl-doc      as decimal
field dsc-base-doc          as decimal
field dsc-rubl-doc          as decimal
field vat-base-doc          as decimal
field vat-rubl-doc          as decimal
field vat-base-buyer-doc    as decimal
field vat-rubl-buyer-doc    as decimal
field slt-base-doc          as decimal
field slt-rubl-doc          as decimal
field road-tax-base-doc     as decimal
field road-tax-rubl-doc     as decimal
field excise-base-doc       as decimal
field excise-rubl-doc       as decimal
field sum-dsc-base-acc      as decimal
field sum-dsc-rubl-acc      as decimal
field sum-dsc-cli-acc       as decimal
field dsc-base-acc          as decimal
field dsc-rubl-acc          as decimal
field dsc-cli-acc           as decimal
field vat-base-acc          as decimal
field vat-rubl-acc          as decimal
field vat-cli-acc           as decimal
field slt-base-acc          as decimal
field slt-rubl-acc          as decimal
field slt-cli-acc           as decimal
field road-tax-base-acc     as decimal
field road-tax-rubl-acc     as decimal
field road-tax-cli-acc      as decimal
field excise-base-acc       as decimal
field excise-rubl-acc       as decimal
field excise-cli-acc        as decimal
field transport-base-acc    as decimal
field transport-rubl-acc    as decimal
field transport-cli-acc     as decimal
field other-base-acc        as decimal
field other-rubl-acc        as decimal
field other-cli-acc         as decimal
field sum-dsc-base-cur      as decimal
field sum-dsc-rubl-cur      as decimal
field dsc-base-cur          as decimal
field dsc-rubl-cur          as decimal
field vat-base-cur          as decimal
field vat-rubl-cur          as decimal
field vat-base-buyer-cur    as decimal
field vat-rubl-buyer-cur    as decimal
field slt-base-cur          as decimal
field slt-rubl-cur          as decimal
field road-tax-base-cur     as decimal
field road-tax-rubl-cur     as decimal
field excise-base-cur       as decimal
field excise-rubl-cur       as decimal
index sum-type is primary unique sum-type.
  define property Msg as character no-undo
    get:
      return trim (Msg, chr(10)).
    end.
    private set (inArg as char):
      Msg = Msg + chr(10) + inArg.
    end.
  define property InitSecTag as character no-undo init "peres-gd-docs"
    get.
  define property BufTableHndlNew as handle no-undo
    get.
    set.
  define property BufTableHndlOld as handle no-undo
    get.
    set.
  define public property sendTableName as character no-undo init "trn-doc"
    get.
  define public property sendOldRowid as rowid  no-undo
    get.
    set.
  define public property sendNewRowid as rowid  no-undo
    get.
    set.
  define variable sw               as handle    no-undo.
  define variable isDel            as logical   no-undo.
  define variable varinvclcwt      as logical   no-undo.
  define variable varinvclcas      as logical   no-undo.
  define variable varinvclcex      as logical   no-undo.
  define variable varinvclcms      as logical   no-undo.
  define variable varinvclcbef     as logical   no-undo.
  define variable prtvalue         as character no-undo.
  define variable varinvclcspvalue as character no-undo.
  define variable varr-b           as character no-undo.
  define variable is-cdinv         as character no-undo .
  define variable clcprtsl-hndl    as handle    no-undo .
  define variable v-bufhnd         as handle    no-undo.
  method public void CrContentToSW (insw as handle):
    sw = insw.
    create bf_trn-doc.
    v-bufhnd = buffer bf_trn-doc:handle.
    if valid-handle (BufTableHndlNew)
    then do:
      sendNewRowid  = BufTableHndlNew:rowid.
      v-bufhnd:buffer-copy (BufTableHndlNew) no-error.
      if error-status:error
      then do:
        Msg = "Ошибка выгрузки peres-gd-doc, неверный буфер BufTableHndlNew".
        undo, return error Msg.
      end.
      isDel = false.
    end.
    else do:
      if not valid-handle (BufTableHndlOld)
      then do:
        Msg = "Ошибка выгрузки peres-gd-doc, неопеределен ни старый ни новый буфер".
        undo, return error Msg.
      end.
      sendOldRowid  = BufTableHndlOld:rowid.
      v-bufhnd:buffer-copy (BufTableHndlOld) no-error.
      if error-status:error
      then do:
        Msg = "Ошибка выгрузки peres-gd-doc, неверный буфер BufTableHndlOld".
        undo, return error Msg.
      end.
      isDel = true.
    end.
    run str/clcprtsl.p persistent (output clcprtsl-hndl).
    StartDocInv().
    GdsLine().
    EndDocInv().
    delete procedure clcprtsl-hndl.
  end.
  method private void GdsLine ():
    sw:start-element ("gds").
    for each bf_doc-line
      where bf_doc-line.doc-code = bf_trn-doc.doc-code no-lock,
      first bf_goods where bf_goods.artic = bf_doc-line.artic
      and bf_goods.prod-type = bf_doc-line.prod-type
      and bf_goods.prod-code = bf_doc-line.prod-code no-lock,
      first bf_parts where bf_parts.out-code  = bf_doc-line.doc-code
      and bf_parts.obj-type  = bf_doc-line.obj-type
      and bf_parts.obj-code  = bf_doc-line.obj-code
      and bf_parts.artic = bf_doc-line.artic
      and bf_parts.prod-type = bf_doc-line.prod-type
      and bf_parts.prod-code = bf_doc-line.prod-code
      and bf_parts.fact-qnty < 0 no-lock:
      for each bf-plus_doc-line
        where bf-plus_doc-line.doc-code = bf_trn-doc.doc-code no-lock,
        first bf-plus_goods where bf-plus_goods.artic = bf-plus_doc-line.artic
        and bf-plus_goods.prod-type = bf-plus_doc-line.prod-type
        and bf-plus_goods.prod-code = bf-plus_doc-line.prod-code no-lock,
        first bf_parts-root where bf_parts-root.doc-code = bf-plus_doc-line.doc-code
        and bf_parts-root.gds-code = bf-plus_goods.gds-code
        and bf_parts-root.orig-gds-code = bf_goods.gds-code no-lock:
        sw:start-element ("gd").
          write-data-element ("gd-code-from", string-mth (bf_goods.gds-code)).
          write-data-element ("gd-code-to", string-mth (bf-plus_goods.gds-code)).
          write-data-element ("qnty", string-mth ( round (get-income-qnty(buffer bf_doc-line, buffer bf-plus_doc-line), 3) )).
          write-data-element ("sum-from", string-mth (round (get-write-off-sum-rubl (buffer bf_doc-line), 3))).
          write-data-element ("sum-to", string-mth (round (get-income-sum-rbl (buffer bf_doc-line, buffer bf-plus_doc-line ), 3))).
          write-data-element ("sum-from-s", string-mth (round (absolut (bf_parts.fact-qnty * bf_parts.price-base / (1 + (bf_parts.VAT-pc / 100))), 3))).
        sw:end-element ("gd").
      end.
    end.
    sw:end-element ("gds").
  end.
  method private void StartDocInv ():
        find first c-trn-doc where c-trn-doc.doc-code = bf_trn-doc.doc-code NO-LOCK NO-ERROR.
        sw:start-element ("peres-gd-doc") .
        write-data-element ("doc-code", bf_trn-doc.doc-code).
        write-data-element ("doc-num", bf_trn-doc.doc-code).
        write-data-element ("del-f", string (isDel, "1/0") ).
                write-data-element ("doc-date", if bf_trn-doc.doc-date = ? then "" else substitute("&1T&2", iso-date(date(c-trn-doc.doc-date)),string(c-trn-doc.sys-time) ) ).
        write-data-element ("fact-date", if bf_trn-doc.fact-date = ? then "" else iso-date (date (bf_trn-doc.fact-date))).
        write-data-element ("shift-date", if bf_trn-doc.shift-date = ? then "" else iso-date (date (bf_trn-doc.shift-date))).
        write-data-element ("shift-num", if bf_trn-doc.shift-num = ? then "0" else string-mth (bf_trn-doc.shift-num)).
  end.
  method private void EndDocInv ():
    sw:end-element ("peres-gd-doc") .
  end.
  method private void write-data-element (inTag as char, inValue as char):
    if inValue = ?
    then do:
      Msg = substitute ('Предупреждение отладки: тег &1 иммет неопределнное значение. Работа будет продолжена...', inTag).
    end.
    if inTag = ?
    then do:
      Msg = substitute ('Предупреждение отладки: Имя тега не может быть пустым...').
      return.
    end.
    inTag = lc (InTag).
    if inValue = ?
      then sw:write-empty-element (inTag).
      else sw:write-data-element (inTag, inValue).
  end.
  method private character string-mth (inValue as integer):
    def var v-str as character no-undo.
    if inValue = ?
      then v-str = "0".
      else v-str = string (inValue).
    return v-str.
  end.
  method private character string-mth (inValue as decimal):
    def var v-str as character no-undo.
    if inValue = ?
      then v-str = "0".
    if string (inValue) begins "."
      then v-str = "0" + string (inValue).
      else v-str = string (inValue).
    return v-str.
  end.
  method private decimal get-write-off-sum-rubl ( buffer local-doc-line for ub.doc-line ) :
      find first tt-doc-line-cashe where tt-doc-line-cashe.doc-code  = local-doc-line.doc-code  and
                                         tt-doc-line-cashe.artic     = local-doc-line.artic     and
                                         tt-doc-line-cashe.prod-type = local-doc-line.prod-type and
                                         tt-doc-line-cashe.prod-code = local-doc-line.prod-code no-error.
      if not available tt-doc-line-cashe then do:
        proc-get-write-off (BUFFER local-doc-line).
        find first tt-doc-line-cashe where tt-doc-line-cashe.doc-code  = local-doc-line.doc-code  and
                                           tt-doc-line-cashe.artic     = local-doc-line.artic     and
                                           tt-doc-line-cashe.prod-type = local-doc-line.prod-type and
                                           tt-doc-line-cashe.prod-code = local-doc-line.prod-code .
      end.
      return tt-doc-line-cashe.sum-rubl.
  end.
  method private decimal get-income-sum-rbl ( BUFFER local-doc-line for ub.doc-line, BUFFER local-doc-line-plus for ub.doc-line  ) :
     find first tt-doc-line-cashe-plus where tt-doc-line-cashe-plus.doc-code     = local-doc-line.doc-code       and
                                             tt-doc-line-cashe-plus.wf-artic     = local-doc-line.artic          and
                                             tt-doc-line-cashe-plus.wf-prod-type = local-doc-line.prod-type      and
                                             tt-doc-line-cashe-plus.wf-prod-code = local-doc-line.prod-code      and
                                             tt-doc-line-cashe-plus.artic        = local-doc-line-plus.artic     and
                                             tt-doc-line-cashe-plus.prod-type    = local-doc-line-plus.prod-type and
                                             tt-doc-line-cashe-plus.prod-code    = local-doc-line-plus.prod-code no-error.
     if not available tt-doc-line-cashe-plus then do:
       proc-get-write-off (BUFFER local-doc-line).
       find first tt-doc-line-cashe-plus where tt-doc-line-cashe-plus.doc-code     = local-doc-line.doc-code       and
                                               tt-doc-line-cashe-plus.wf-artic     = local-doc-line.artic          and
                                               tt-doc-line-cashe-plus.wf-prod-type = local-doc-line.prod-type      and
                                               tt-doc-line-cashe-plus.wf-prod-code = local-doc-line.prod-code      and
                                               tt-doc-line-cashe-plus.artic        = local-doc-line-plus.artic     and
                                               tt-doc-line-cashe-plus.prod-type    = local-doc-line-plus.prod-type and
                                               tt-doc-line-cashe-plus.prod-code    = local-doc-line-plus.prod-code .
     end.
     return tt-doc-line-cashe-plus.sum-rubl.
  end.
  method private void proc-get-write-off ( buffer bf-loc_doc-line for ub.doc-line ) :
    define buffer bf-loc-plus_doc-line for ub.doc-line.
    define buffer bf-loc_parts         for ub.parts.
    define buffer bf-loc_parts-root    for ub.parts-root.
    define buffer bf-loc-plus_parts    for ub.parts.
    define buffer bf-loc_goods         for ub.goods.
    define buffer bf-loc-plus_goods    for ub.goods.
    define variable varprice-rubl-parts as decimal no-undo.
    define variable varprice-base-parts as decimal no-undo.
    find first bf-loc_goods where bf-loc_goods.artic     = bf-loc_doc-line.artic     and
                                  bf-loc_goods.prod-type = bf-loc_doc-line.prod-type and
                                  bf-loc_goods.prod-code = bf-loc_doc-line.prod-code no-lock.
    find first tt-doc-line-cashe where tt-doc-line-cashe.doc-code  = bf-loc_doc-line.doc-code  and
                                       tt-doc-line-cashe.artic     = bf-loc_doc-line.artic     and
                                       tt-doc-line-cashe.prod-type = bf-loc_doc-line.prod-type and
                                       tt-doc-line-cashe.prod-code = bf-loc_doc-line.prod-code no-error.
    if not available tt-doc-line-cashe then do:
      create tt-doc-line-cashe.
      assign
        tt-doc-line-cashe.doc-code  = bf-loc_doc-line.doc-code
        tt-doc-line-cashe.artic     = bf-loc_doc-line.artic
        tt-doc-line-cashe.prod-type = bf-loc_doc-line.prod-type
        tt-doc-line-cashe.prod-code = bf-loc_doc-line.prod-code .
    end.
    else do:
      assign
        tt-doc-line-cashe.qnty     = 0.00
        tt-doc-line-cashe.sum-rubl = 0.00
        tt-doc-line-cashe.sum-base = 0.00
        tt-doc-line-cashe.vat-rubl = 0.00
        tt-doc-line-cashe.vat-base = 0.00.
      for each tt-doc-line-cashe-plus where tt-doc-line-cashe-plus.doc-code     = tt-doc-line-cashe.doc-code  and
                                            tt-doc-line-cashe-plus.wf-artic     = tt-doc-line-cashe.artic     and
                                            tt-doc-line-cashe-plus.wf-prod-type = tt-doc-line-cashe.prod-type and
                                            tt-doc-line-cashe-plus.wf-prod-code = tt-doc-line-cashe.prod-code :
        delete tt-doc-line-cashe-plus.
      end.
    end.
    for each bf-loc_parts where bf-loc_parts.out-code  = bf-loc_doc-line.doc-code  and
                                bf-loc_parts.obj-type  = bf-loc_doc-line.obj-type  and
                                bf-loc_parts.obj-code  = bf-loc_doc-line.obj-code  and
                                bf-loc_parts.artic     = bf-loc_doc-line.artic     and
                                bf-loc_parts.prod-type = bf-loc_doc-line.prod-type and
                                bf-loc_parts.prod-code = bf-loc_doc-line.prod-code and
                                bf-loc_parts.fact-qnty < 0 no-lock :
      for each tt-clcparts :
        delete tt-clcparts.
      end.
      create tt-clcparts.
      buffer-copy bf-loc_parts to tt-clcparts.
      run clcprtsl_calc-parts-inkaps in clcprtsl-hndl (
                                      input-output table tt-clcparts
                                    , input-output table tt-allsum
                                    , input yes
                                    , input no
                                    , input bf-loc_doc-line.road-tax
                                    , input bf-loc_doc-line.excise
                                    , input bf-loc_doc-line.VAT-pc
                                    , input bf-loc_doc-line.cons-vat-pc
                                    , input bf-loc_doc-line.SLT-pc
                                    , input bf_trn-doc.base-rate
                                    , input bf_trn-doc.base-scale
                                    , input "":U
                                    , input 0.0
                                    , input 0.0
                                    , input 0.0
                                    , input 0.0
                                    , input 0.0
                                    , input 0.0
                                ).
      find first tt-allsum where tt-allsum.sum-type = 'основная_сумма':U no-error.
      if available tt-allsum then do:
        assign
          tt-doc-line-cashe.qnty     = tt-doc-line-cashe.qnty     - tt-allsum.fact-qnty
          tt-doc-line-cashe.sum-rubl = tt-doc-line-cashe.sum-rubl - tt-allsum.sum-dsc-rubl-doc
          tt-doc-line-cashe.sum-base = tt-doc-line-cashe.sum-base - tt-allsum.sum-dsc-base-doc
          tt-doc-line-cashe.vat-rubl = tt-doc-line-cashe.vat-rubl - tt-allsum.vat-rubl-doc
          tt-doc-line-cashe.vat-base = tt-doc-line-cashe.vat-base - tt-allsum.vat-base-doc.
        assign
          varprice-rubl-parts = tt-allsum.sum-dsc-rubl-doc / tt-allsum.fact-qnty
          varprice-base-parts = tt-allsum.sum-dsc-base-doc / tt-allsum.fact-qnty.
        for each bf-loc_parts-root where bf-loc_parts-root.doc-code       = bf-loc_parts.out-code   and
                                         bf-loc_parts-root.orig-in-code   = bf-loc_parts.in-code    and
                                         bf-loc_parts-root.orig-gds-code  = bf-loc_goods.gds-code   and
                                         bf-loc_parts-root.orig-part-code = bf-loc_parts.part-code  no-lock :
          find first bf-loc-plus_goods where bf-loc-plus_goods.gds-code  = bf-loc_parts-root.gds-code no-lock.
          find first bf-loc-plus_parts where bf-loc-plus_parts.obj-type  = bf-loc_doc-line.obj-type    and
                                             bf-loc-plus_parts.obj-code  = bf-loc_doc-line.obj-code    and
                                             bf-loc-plus_parts.artic     = bf-loc-plus_goods.artic     and
                                             bf-loc-plus_parts.prod-type = bf-loc-plus_goods.prod-type and
                                             bf-loc-plus_parts.prod-code = bf-loc-plus_goods.prod-code and
                                             bf-loc-plus_parts.in-code   = bf-loc_parts-root.in-code   and
                                             bf-loc-plus_parts.out-code  = bf-loc_doc-line.doc-code    and
                                             bf-loc-plus_parts.part-code = bf-loc_parts-root.part-code no-lock.
          find first bf-loc-plus_doc-line where bf-loc-plus_doc-line.doc-code  = bf-loc-plus_parts.out-code  and
                                                bf-loc-plus_doc-line.artic     = bf-loc-plus_parts.artic     and
                                                bf-loc-plus_doc-line.prod-type = bf-loc-plus_parts.prod-type and
                                                bf-loc-plus_doc-line.prod-code = bf-loc-plus_parts.prod-code .
          find first tt-doc-line-cashe-plus where tt-doc-line-cashe-plus.doc-code     = tt-doc-line-cashe.doc-code  and
                                                  tt-doc-line-cashe-plus.wf-artic     = tt-doc-line-cashe.artic     and
                                                  tt-doc-line-cashe-plus.wf-prod-type = tt-doc-line-cashe.prod-type and
                                                  tt-doc-line-cashe-plus.wf-prod-code = tt-doc-line-cashe.prod-code and
                                                  tt-doc-line-cashe-plus.artic        = bf-loc-plus_goods.artic      and
                                                  tt-doc-line-cashe-plus.prod-type    = bf-loc-plus_goods.prod-type  and
                                                  tt-doc-line-cashe-plus.prod-code    = bf-loc-plus_goods.prod-code  no-error.
          if not available tt-doc-line-cashe-plus then do:
            create tt-doc-line-cashe-plus.
            assign
              tt-doc-line-cashe-plus.doc-code     = tt-doc-line-cashe.doc-code
              tt-doc-line-cashe-plus.wf-artic     = tt-doc-line-cashe.artic
              tt-doc-line-cashe-plus.wf-prod-type = tt-doc-line-cashe.prod-type
              tt-doc-line-cashe-plus.wf-prod-code = tt-doc-line-cashe.prod-code
              tt-doc-line-cashe-plus.artic        = bf-loc-plus_goods.artic
              tt-doc-line-cashe-plus.prod-type    = bf-loc-plus_goods.prod-type
              tt-doc-line-cashe-plus.prod-code    = bf-loc-plus_goods.prod-code .
          end.
          for each tt-clcparts :
            delete tt-clcparts.
          end.
          create tt-clcparts.
          buffer-copy bf-loc-plus_parts to tt-clcparts.
          run clcprtsl_calc-parts-inkaps in clcprtsl-hndl (
                                          input-output table tt-clcparts
                                        , input-output table tt-allsum
                                        , input yes
                                        , input no
                                        , input bf-loc-plus_doc-line.road-tax
                                        , input bf-loc-plus_doc-line.excise
                                        , input bf-loc-plus_doc-line.VAT-pc
                                        , input bf-loc-plus_doc-line.cons-vat-pc
                                        , input bf-loc-plus_doc-line.SLT-pc
                                        , input bf_trn-doc.base-rate
                                        , input bf_trn-doc.base-scale
                                        , input "":U
                                        , input 0.0
                                        , input 0.0
                                        , input 0.0
                                        , input 0.0
                                        , input 0.0
                                        , input 0.0
                                    ).
          find first tt-allsum where tt-allsum.sum-type = 'основная_сумма':U no-error.
          find first tt-clcparts.
          if available tt-allsum then do:
            assign
              tt-doc-line-cashe-plus.qnty               = tt-doc-line-cashe-plus.qnty               + tt-allsum.fact-qnty
              tt-doc-line-cashe-plus.sum-rubl           = tt-doc-line-cashe-plus.sum-rubl           + tt-allsum.sum-dsc-rubl-doc
              tt-doc-line-cashe-plus.sum-base           = tt-doc-line-cashe-plus.sum-base           + tt-allsum.sum-dsc-base-doc
              tt-doc-line-cashe-plus.vat-rubl           = tt-doc-line-cashe-plus.vat-rubl           + tt-allsum.vat-rubl-doc
              tt-doc-line-cashe-plus.vat-base           = tt-doc-line-cashe-plus.vat-base           + tt-allsum.vat-base-doc
              tt-doc-line-cashe-plus.write-off-qnty     = tt-doc-line-cashe-plus.write-off-qnty     + tt-clcparts.real-qnty
              tt-doc-line-cashe-plus.write-off-sum-rubl = tt-doc-line-cashe-plus.write-off-sum-rubl + varprice-rubl-parts * tt-clcparts.real-qnty
              tt-doc-line-cashe-plus.write-off-sum-base = tt-doc-line-cashe-plus.write-off-sum-base + varprice-base-parts * tt-clcparts.real-qnty
            .
          end.
        end.
      end.
    end.
  end.
  method private decimal get-income-qnty
  ( buffer local-doc-line for ub.doc-line, buffer local-doc-line-plus for ub.doc-line ) :
   find first tt-doc-line-cashe-plus where tt-doc-line-cashe-plus.doc-code     = local-doc-line.doc-code       and
                                           tt-doc-line-cashe-plus.wf-artic     = local-doc-line.artic          and
                                           tt-doc-line-cashe-plus.wf-prod-type = local-doc-line.prod-type      and
                                           tt-doc-line-cashe-plus.wf-prod-code = local-doc-line.prod-code      and
                                           tt-doc-line-cashe-plus.artic        = local-doc-line-plus.artic     and
                                           tt-doc-line-cashe-plus.prod-type    = local-doc-line-plus.prod-type and
                                           tt-doc-line-cashe-plus.prod-code    = local-doc-line-plus.prod-code no-error.
   if not available tt-doc-line-cashe-plus then do:
     proc-get-write-off (buffer local-doc-line).
     find first tt-doc-line-cashe-plus where tt-doc-line-cashe-plus.doc-code     = local-doc-line.doc-code       and
                                             tt-doc-line-cashe-plus.wf-artic     = local-doc-line.artic          and
                                             tt-doc-line-cashe-plus.wf-prod-type = local-doc-line.prod-type      and
                                             tt-doc-line-cashe-plus.wf-prod-code = local-doc-line.prod-code      and
                                             tt-doc-line-cashe-plus.artic        = local-doc-line-plus.artic     and
                                             tt-doc-line-cashe-plus.prod-type    = local-doc-line-plus.prod-type and
                                             tt-doc-line-cashe-plus.prod-code    = local-doc-line-plus.prod-code .
   end.
   return tt-doc-line-cashe-plus.qnty.
  end method.
end class.
