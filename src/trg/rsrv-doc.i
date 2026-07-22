/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедура резервирования товара для документов

Автор: Чернова Светлана Александровна
Дата создания: 02/14/07
Author: Svetlana Chernova
Creation date: 02/14/07

create: Перваков Михаил Сергеевич
Дата создания: 10/19/05

*/


&scop f-l Base2Int64
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
{ gbl/std-func.i {&f-l} }
{ str/marks.i }
{ utl/gtin.i }
{ str/utd-typemark.i }

  define temp-table tt-alc-codes
    field alc-code      as character
    field qnty          as decimal
    index pi as primary unique
      alc-code
  .
  
  define temp-table tt-marks
    field mark as character
    field qnty as integer
    index pi as primary unique
      mark
  .
  
  define temp-table tt-tobacco-marks
    field mark as character case-sensitive
    field unit as character
    field qnty as integer
    field to-ungroup as logical
    field is-weight as logical
    field weight as decimal
    index pi as primary unique
      mark
    index un
      unit ascending
  .
  
  define buffer buf_tt-tobacco-marks for tt-tobacco-marks .
  
  define temp-table tt-tobacco-part-qnty
    field part-row as rowid
    field qnty as decimal
    index pi as primary unique
      part-row
  .

procedure rsrv-doc :
  define input  parameter parparentproc          AS WIDGET-HANDLE           NO-UNDO.
  define input  parameter p-db-num               as integer   no-undo .
  define input  parameter p-user-id              as character no-undo .
  define input  parameter p-trn-doc-recid        as recid     no-undo .
  define input  parameter p-doc-line-recid       as recid     no-undo .
  define input  parameter p-reserv-base          as decimal   no-undo .
  define input  parameter p-reserv-rubl          as decimal   no-undo .
  define input  parameter p-partscr-prompt-price as character no-undo .
  define input  parameter p-extended-doc-type    as character no-undo .
  define input  parameter p-reserv-single-part   as logical   no-undo .
  define input  parameter p-in-code              as character no-undo .
  define input  parameter p-part-code            as character no-undo .
  define input  parameter p-reserv-pl-code       as logical   no-undo .
  define input  parameter p-pl-code              as character no-undo .
  define input  parameter p-goods-serial         as logical   no-undo .
  define input  parameter p-goods-twounit        as logical   no-undo .
  define input  parameter p-purch-code-list      as character no-undo .
  define input  parameter p-chg-qnty             as decimal   no-undo .
  define input  parameter p-unreserv-other-sign  as logical   no-undo .
  define output parameter p-real-chg-qnty        as decimal   no-undo .

  define variable vss-description as character no-undo init "rsrv-doc: Процедура резервирования партий".

  define variable v-chg-qnty-sign   as integer         no-undo .
  define variable v-rsrv-code       as character       no-undo .
  define variable v-reason          as character       no-undo .
  define variable v-process-part    as logical         no-undo .
  define variable v-real-chg-qnty   like ub.parts.qnty no-undo .
  define variable v-parts-recid     as recid           no-undo .
  define variable v-check-part-qnty as decimal         no-undo .

  define buffer buf_parts    for ub.parts .
  define buffer buf2_parts   for ub.parts .
  define buffer buf_trn-doc  for ub.trn-doc .
  define buffer buf_doc-line for ub.doc-line .
  define buffer buf1_doc-line-attr for ub.doc-line-attr .
  define buffer buf1_goods    for ub.goods .
  define buffer buf_goods    for ub.goods .
  define buffer buf_gen-attr for ub.gen-attr .
  define buffer buf2_gen-attr for ub.gen-attr .
  
  define variable v-part-key        as character no-undo .
  define variable v-value-character as character no-undo .
  define variable v-value-date      as date no-undo .
  define variable v-value-decimal   as decimal no-undo .
  define variable v-value-integer   as integer no-undo .
  define variable v-izlcstpr        as logical no-undo .
  define variable v-mark-alchol     as logical no-undo .
  define variable v-tth             as handle no-undo .
  define variable v-type            as character no-undo .
  define variable v-attr-value      as character no-undo .
  
  define variable vCodeIdent        as character no-undo .
  
  define variable v-mark as character no-undo .
  define variable v-mark-list as character no-undo .
  define variable v-alc-code as character no-undo .
  define variable mark-ii as integer  no-undo .
  define variable jj as integer  no-undo .
  define variable v-alc-qnty as decimal no-undo .
  
  define variable v-tobacco-mark      as character  no-undo .
  define variable v-tobacco-mark-list as character  no-undo .
  define variable v-mark-tobacco      as logical    no-undo .
  define variable v-box-qnty          as integer    no-undo .
  define variable v-GTIN              as character  no-undo .
  define variable v-GTIN-qnty         as integer    no-undo .
  
  { gbl/objsrv.i }
   define buffer buf_marking         for ub.marking .
  define buffer buf_marking-childs  for ub.marking .
  define buffer buf_marking-lines   for ub.marking-lines .
  define buffer buf_marking-chk     for ub.marking-chk .
  define variable v-copy-doc-code     as character  no-undo .
  define buffer buf_copy-trn-doc    for ub.trn-doc .
  define buffer buf_utd-lines       for ub.utd-lines .
  define buffer buf_utd-marking-lines for ub.utd-marking-lines .
  
  define variable EDOParSec as class ibs.th.gbl.env.prmtrs.edo .
  
  define variable varb-code like ub.bar-code.b-code .
  define variable vardoc-num     like ub.price-list.doc-num    no-undo .
  define variable varprice-sale  like ub.price-list.price-sale no-undo .
  define variable varroad-tax    like ub.price-list.road-tax   no-undo .
  define variable varexcise      like ub.price-list.excise     no-undo .
  define variable varcur-vat-pc  like ub.price-list.vat-pc     no-undo .
  define variable varcur-slt-pc  like ub.price-list.slt-pc     no-undo .
  define variable varprice-rubl  as decimal no-undo .
  define variable varprice-base  as decimal no-undo .
  define variable vIsExemplarGoods as logical no-undo init false.
  define variable v-isweighed as logical no-undo init false.
  define variable varvalue as character no-undo .
  define variable vartype  as character no-undo .
  define variable v-mark-weight as decimal   no-undo .
    
  define variable v-exch-rate  like ub.curr-accnt.exch-rate no-undo .
  define variable v-exch-scale like ub.curr-accnt.exch-scale no-undo .

  do
  on error undo, return error return-value
  :
    find first buf_trn-doc no-lock
      where recid(buf_trn-doc) = p-trn-doc-recid
      no-error .
    if not available buf_trn-doc
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не найден документ" skip
        "Указатель" p-trn-doc-recid skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    find first buf_doc-line no-lock
      where recid(buf_doc-line) = p-doc-line-recid
      no-error .
    if not available buf_doc-line
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не найдена строка документа" skip
        "Указатель" p-doc-line-recid skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    find first buf_goods no-lock where 
               buf_goods.artic     = buf_doc-line.artic
           and buf_goods.prod-type = buf_doc-line.prod-type
           and buf_goods.prod-code = buf_doc-line.prod-code
         no-error.
    if avail buf_goods then
    do:  /* определим, что товар с поэкземплярным учетом  */
      run isExemplarGoods in this-procedure 
          (buf_trn-doc.obj-type, buf_trn-doc.obj-code, buf_goods.gds-code, output vIsExemplarGoods).
      EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(buf_trn-doc.obj-type, buf_trn-doc.obj-code).
      RUN gds-attr-value (
                          INPUT buf_goods.gds-code,
                          INPUT {&attr-mark-type},
                          OUTPUT varvalue,
                          OUTPUT vartype
                          ).
      v-isweighed = WeighedProd(buf_goods.gds-code)
                and varvalue > ""
                and (EDOParSec:GetIsEDOForType(varvalue)
                  or EDOParSec:GetIsArticForType(varvalue))
      .
    end.

/*    run gbl/inidebug.p .*/
    
/*    delete object v-tth no-error.                         */
/*    run adm/shattri.p (                                   */
/*       input "get":U                                      */
/*      ,input buf_trn-doc.obj-type                         */
/*      ,input buf_trn-doc.obj-code                         */
/*      ,input {&attr-nakl_par}                             */
/*      ,input  "mark-alchol"                               */
/*      ,output v-value-character                           */
/*      ,output v-value-date                                */
/*      ,output v-value-decimal                             */
/*      ,output v-value-integer                             */
/*      ,output v-mark-alchol                               */
/*      ,output v-type                                      */
/*      ,INPUT-OUTPUT table-handle v-tth                    */
/*      ) no-error .                                        */
/*      delete object v-tth no-error.                       */
/*    if error-status:error then do:                        */
/*      message "Ошибка при получение параметра mark-alchol"*/
/*      view-as alert-box.                                  */
/*      return error.                                       */
/*    end.                                                  */
    
    v-mark-alchol = true .
    
    if buf_trn-doc.ext-doc-type = {&TDEDT_Inv}
    then do :
        delete object v-tth no-error.
        run adm/shattri.p (
           input "get":U
          ,input buf_trn-doc.obj-type
          ,input buf_trn-doc.obj-code
          ,input {&attr-inv-obj}
          ,input  "izlcstpr"
          ,output v-value-character
          ,output v-value-date
          ,output v-value-decimal
          ,output v-value-integer
          ,output v-izlcstpr
          ,output v-type
          ,INPUT-OUTPUT table-handle v-tth
          ) no-error .
          delete object v-tth no-error.      
        if error-status:error then do:
          v-izlcstpr = false .
/*          message "Ошибка при получение параметра izlcstpr"*/
/*          view-as alert-box.                               */
/*          return error.                                    */
        end.
    end.
    else do :
        v-izlcstpr = false .
    end.
    
    if p-pl-code <> ? and trim(p-pl-code) <> "" and p-pl-code <> "0"
    then
    v-izlcstpr = false .
    
    empty temp-table tt-alc-codes .
    output stream tobacco-rsrv to value ("tobacco-rsrv.log") .
    
    if buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_Kass}
    and buf_doc-line.unit-cli > ""
    then do :
      find first buf1_goods no-lock where buf1_goods.artic      = buf_doc-line.artic
                                     and buf1_goods.prod-type  = buf_doc-line.prod-type
                                     and buf1_goods.prod-code  = buf_doc-line.prod-code .
      find first bar-code no-lock where bar-code.gds-code = buf1_goods.gds-code
                                    and bar-code.unit-cli = buf_doc-line.unit-cli . 
      for each ub.chk-doc no-lock where ub.chk-doc.out-code = buf_doc-line.doc-code
        and not ub.chk-doc.chk-type = integer ({&rcpt-annu}):
        for each chk-gds no-lock where chk-gds.doc-code = ub.chk-doc.doc-code 
                                   and chk-gds.b-code = bar-code.b-code:
          for each chk-gds-attr no-lock where chk-gds-attr.doc-code = chk-gds.doc-code
                                          and chk-gds-attr.line-num = chk-gds.line-num
                                          and chk-gds-attr.attr-code = "mark-code":
            do mark-ii = 1 to num-entries(chk-gds-attr.attr-value) :
              v-mark = entry(mark-ii, chk-gds-attr.attr-value) .
              find first tt-marks exclusive-lock where tt-marks.mark = v-mark no-error .
              if not available tt-marks
              then do :
                create tt-marks.
                tt-marks.mark = v-mark.
                tt-marks.qnty = 0 .
              end .
              tt-marks.qnty = tt-marks.qnty + (chk-gds.doc-qnty / abs(chk-gds.doc-qnty)) .
            end .
          end .
        end .
      end . /* ub.chk-doc */
    end .
    if buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_Kass}
    and buf_doc-line.unit-cli > ""
    then do :
      find first buf1_goods no-lock where buf1_goods.artic      = buf_doc-line.artic
                                     and buf1_goods.prod-type  = buf_doc-line.prod-type
                                     and buf1_goods.prod-code  = buf_doc-line.prod-code .
      RUN gds-attr-value (
                          INPUT buf1_goods.gds-code,
                          INPUT {&attr-mark-type},
                          OUTPUT v-attr-value,
                          OUTPUT v-type
                          ).
      if v-attr-value > ""
      and ObjSrv:Env:ParametrsOfSection:GetSectionEDO(buf_doc-line.obj-type, buf_doc-line.obj-code):GetIsMarkingForType(v-attr-value)
      then do :                               
        find first bar-code no-lock where bar-code.gds-code = buf1_goods.gds-code
                                      and bar-code.unit-cli = buf_doc-line.unit-cli .
        for each ub.chk-doc no-lock where ub.chk-doc.out-code = buf_doc-line.doc-code
          and ub.chk-doc.chk-type = integer ({&rcpt-sale}):
          for each chk-gds no-lock where chk-gds.doc-code = ub.chk-doc.doc-code 
                                     and chk-gds.b-code = bar-code.b-code:
            for each buf_marking-chk no-lock where buf_marking-chk.doc-code = chk-gds.doc-code
                                               and buf_marking-chk.line-num = chk-gds.line-num
  /*                                             and buf_marking-chk.sts = 0*/
                                               :
              if chg-qnty > 0 and buf_marking-chk.sts = 1 then next .
              if chg-qnty < 0 and buf_marking-chk.sts = 0 then next .
              if buf_marking-chk.sts = 2 then next .
              assign vCodeIdent = GetCodeIdent(buf_marking-chk.mark) .
              find first tt-tobacco-marks exclusive-lock where tt-tobacco-marks.mark = vCodeIdent no-error .
              find first buf_marking no-lock where buf_marking.mark begins vCodeIdent no-error .
              if not available tt-tobacco-marks
              then do :
                create tt-tobacco-marks.
                tt-tobacco-marks.mark = vCodeIdent .
                tt-tobacco-marks.qnty = 0 .
              end .
              if available buf_marking then tt-tobacco-marks.unit = buf_marking.unit-ext .
              tt-tobacco-marks.qnty = tt-tobacco-marks.qnty + (chk-gds.doc-qnty / abs(chk-gds.doc-qnty)) .                                   
            end . 
          end .
        end . /* chk-doc */
      end .
    end . /* есть чеки (продажа) */
    if buf_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh_Kass}
    and buf_doc-line.unit-cli > ""
    then do :
      find first buf1_goods no-lock where buf1_goods.artic      = buf_doc-line.artic
                                     and buf1_goods.prod-type  = buf_doc-line.prod-type
                                     and buf1_goods.prod-code  = buf_doc-line.prod-code .
      find first buf1_goods no-lock where buf1_goods.artic      = buf_doc-line.artic
                                     and buf1_goods.prod-type  = buf_doc-line.prod-type
                                     and buf1_goods.prod-code  = buf_doc-line.prod-code .
      RUN gds-attr-value (
                          INPUT buf1_goods.gds-code,
                          INPUT {&attr-mark-type},
                          OUTPUT v-attr-value,
                          OUTPUT v-type
                          ).
      if v-attr-value > ""
      and ObjSrv:Env:ParametrsOfSection:GetSectionEDO(buf_doc-line.obj-type, buf_doc-line.obj-code):GetIsMarkingForType(v-attr-value)
      then do :
        find first bar-code no-lock where bar-code.gds-code = buf1_goods.gds-code
                                      and bar-code.unit-cli = buf_doc-line.unit-cli . 
        for each ub.chk-doc no-lock where ub.chk-doc.out-code = buf_trn-doc.out-code
          and (ub.chk-doc.chk-type = integer ({&rcpt-return}) or ub.chk-doc.chk-type = integer ({&rcpt-write-off}) ):
          for each chk-gds no-lock where chk-gds.doc-code = ub.chk-doc.doc-code 
                                     and chk-gds.b-code = bar-code.b-code:
            for each buf_marking-chk no-lock where buf_marking-chk.doc-code = chk-gds.doc-code
                                               and buf_marking-chk.line-num = chk-gds.line-num
  /*                                             and buf_marking-chk.sts = 1*/
                                               :
              if buf_marking-chk.sts = 2 then next .
              assign vCodeIdent = GetCodeIdent(buf_marking-chk.mark) .
              find first tt-tobacco-marks exclusive-lock where tt-tobacco-marks.mark = vCodeIdent no-error .
              find first buf_marking no-lock where buf_marking.mark = vCodeIdent no-error .
              if not available tt-tobacco-marks
              then do :
                create tt-tobacco-marks.
                tt-tobacco-marks.mark = vCodeIdent .
                tt-tobacco-marks.qnty = 0 .
              end .
              if available buf_marking then tt-tobacco-marks.unit = buf_marking.unit-ext .
              tt-tobacco-marks.qnty = tt-tobacco-marks.qnty + 1 .                                   
            end . 
          end .
        end .
      end .
    end .
        
    define variable v-keyrec   as character no-undo .
    for each ub.fbr-line no-lock where buf_trn-doc.ext-doc-type = {&TDEDT_Spi_Prvo}
      and ub.fbr-line.doc-code = buf_doc-line.doc-code
      and ub.fbr-line.artic = buf_doc-line.artic
      and ub.fbr-line.prod-type = buf_doc-line.prod-type
      and ub.fbr-line.prod-code = buf_doc-line.prod-code
      :
        run gen-key-rec(input "fbr-line",input buffer ub.fbr-line:handle ,output v-keyrec).
        for each buf_gen-attr no-lock where buf_gen-attr.table-name = {&excise-mark-fbr}
                                        and buf_gen-attr.p-key = v-keyrec
                                        :
          find first buf2_gen-attr no-lock where 
                buf2_gen-attr.table-name = {&excise-mark-fbr}
            and buf2_gen-attr.p-key = v-keyrec
            and buf2_gen-attr.attr-code = buf_gen-attr.attr-code no-error.
          find current buf2_gen-attr exclusive-lock.
          buf2_gen-attr.table-name = {&excise-mark}.
          buf2_gen-attr.p-key = buf2_gen-attr.attr-value.
          buf2_gen-attr.attr-value = "".
          create tt-marks.
          tt-marks.mark = buf2_gen-attr.attr-code.
          tt-marks.qnty = 1.
        end.
    end.  
    
    for each tt-marks exclusive-lock :
      if tt-marks.qnty = 0 then delete tt-marks .
      else
      if tt-marks.qnty <> 1
      then do :
        if not g#auto
        then do :
          message
          vss-workfile vss-revision vss-description skip
          "Ошибка задания входных параметров" skip
          "Не правильное количество по марке - " string(tt-marks.qnty) skip
          "Марка " tt-marks.mark skip
          view-as alert-box error .
        end .
        undo, return error return-value .
      end.
    end.      
    
    for each tt-marks no-lock :
      run ProcAlcCode (input tt-marks.mark, output v-alc-code) no-error.
      if v-alc-code = '' or v-alc-code = ?
      then do :
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка определения алкогольного кода" skip
          "Марка - " v-mark skip
          view-as alert-box error .
        undo, return error return-value .  
      end.
      if v-alc-code > ''
      then do :
        find first tt-alc-codes exclusive-lock where tt-alc-codes.alc-code = v-alc-code no-error.
        if not available tt-alc-codes
        then do :
            create tt-alc-codes.
            assign tt-alc-codes.alc-code = v-alc-code .
        end.
        tt-alc-codes.qnty = tt-alc-codes.qnty + 1 .
      end.
    end.   
    
    if p-mark = "tech-marks"
    then do :
      assign
        p-mark = ""
      .
      find first buf1_goods no-lock where buf1_goods.artic      = buf_doc-line.artic
                                      and buf1_goods.prod-type  = buf_doc-line.prod-type
                                      and buf1_goods.prod-code  = buf_doc-line.prod-code .
      for each buf_marking-lines no-lock where buf_marking-lines.gds-code = buf1_goods.gds-code
                                           and buf_marking-lines.obj-type = buf_doc-line.obj-type
                                           and buf_marking-lines.obj-code = buf_doc-line.obj-code
                                           and buf_marking-lines.out-code = {&free-code}
                                           and buf_marking-lines.mark begins {&tech-mark-prefix}
                                           :
        find first tt-tobacco-marks exclusive-lock where tt-tobacco-marks.mark = buf_marking-lines.mark no-error .
        find first buf_marking no-lock where buf_marking.mark = buf_marking-lines.mark no-error .
        if not available tt-tobacco-marks
        then do :
          create tt-tobacco-marks.
          tt-tobacco-marks.mark = buf_marking-lines.mark  .
          tt-tobacco-marks.qnty = 1 .
        end .
        if available buf_marking then tt-tobacco-marks.unit = buf_marking.unit-ext .                                     
      end .                                
    end .
    
    if p-mark <> ""
    and num-entries(p-mark, {&delim-par}) = 2
    and entry(1, p-mark, {&delim-par}) = "copy-ret"  
    then do : /* Копирование из поля Источник в складских документах */
      assign
        v-copy-doc-code = entry(2, p-mark, {&delim-par})
        p-mark = ""
      .
      find first buf_copy-trn-doc no-lock where buf_copy-trn-doc.doc-code = v-copy-doc-code no-error .
      if available buf_copy-trn-doc
      then do :
        find first buf1_goods no-lock where buf1_goods.artic      = buf_doc-line.artic
                                        and buf1_goods.prod-type  = buf_doc-line.prod-type
                                        and buf1_goods.prod-code  = buf_doc-line.prod-code .
        for each buf_marking-lines no-lock where buf_marking-lines.gds-code = buf1_goods.gds-code
                                             and buf_marking-lines.obj-type = buf_copy-trn-doc.obj-type
                                             and buf_marking-lines.obj-code = buf_copy-trn-doc.obj-code
                                             and buf_marking-lines.out-code = buf_copy-trn-doc.doc-code
                                             :
          find first tt-tobacco-marks exclusive-lock where tt-tobacco-marks.mark = buf_marking-lines.mark no-error .
          find first buf_marking no-lock where buf_marking.mark = buf_marking-lines.mark no-error .
          if not available tt-tobacco-marks
          then do :
            create tt-tobacco-marks.
            tt-tobacco-marks.mark = buf_marking-lines.mark  .
            tt-tobacco-marks.qnty = 1 .
          end .
          if available buf_marking then tt-tobacco-marks.unit = buf_marking.unit-ext .                                     
        end .
      end . /* if available buf_copy-trn-doc */
    end . /* Копирование из поля Источник в складских документах */
    
    if p-mark <> ""
    and num-entries(p-mark, {&delim-par}) = 2
    and entry(1, p-mark, {&delim-par}) = "copy-utd-line"  
    then do : /* Копирование из поля Источник в складских документах */
      assign
        v-copy-doc-code = entry(2, p-mark, {&delim-par})
        p-mark = ""
      .
      find first buf_utd-lines no-lock where recid(buf_utd-lines) = integer(v-copy-doc-code) no-error .
      if available buf_utd-lines
      then do :
        for each buf_utd-marking-lines no-lock where buf_utd-marking-lines.db-num   = buf_utd-lines.db-num
                                                 and buf_utd-marking-lines.doc-id   = buf_utd-lines.doc-id
                                                 and buf_utd-marking-lines.LineNum  = buf_utd-lines.LineNum
                                                 and doc-level = 1
                                                 :
          find first tt-tobacco-marks exclusive-lock where tt-tobacco-marks.mark = buf_utd-marking-lines.mark no-error .
          find first buf_marking no-lock where buf_marking.mark = buf_utd-marking-lines.mark no-error .
          if not available tt-tobacco-marks
          then do :
            create tt-tobacco-marks.
            tt-tobacco-marks.mark = buf_marking.mark  .
            tt-tobacco-marks.qnty = 1 .
          end .
          if available buf_marking then tt-tobacco-marks.unit = buf_marking.unit-ext .                                     
        end .
      end . /* if available buf_copy-trn-doc */
    end . /* Копирование из поля Источник в складских документах */
    
    for each tt-tobacco-marks no-lock where tt-tobacco-marks.qnty = -1
                                        and tt-tobacco-marks.unit = "UNIT",
    first buf_marking-childs no-lock where buf_marking-childs.mark = tt-tobacco-marks.mark,
    first buf_tt-tobacco-marks exclusive-lock where buf_tt-tobacco-marks.mark = buf_marking-childs.mark-parent :
      buf_tt-tobacco-marks.to-ungroup = true .                                           
    end .
    
    for each buf_tt-tobacco-marks exclusive-lock where buf_tt-tobacco-marks.to-ungroup :
      for each buf_marking-childs no-lock where buf_marking-childs.mark-parent = buf_tt-tobacco-marks.mark :
        find first tt-tobacco-marks exclusive-lock where tt-tobacco-marks.mark = buf_marking-childs.mark no-error .
        if not available tt-tobacco-marks
        then do :
          create tt-tobacco-marks.
          tt-tobacco-marks.mark = buf_marking-childs.mark .
          tt-tobacco-marks.unit = buf_marking-childs.unit-ext .
          tt-tobacco-marks.qnty = 0 .
        end .
        tt-tobacco-marks.qnty = tt-tobacco-marks.qnty + 1 .
      end .
      delete buf_tt-tobacco-marks .
    end .
   
    for each tt-tobacco-marks exclusive-lock :
      if tt-tobacco-marks.qnty = 0 then delete tt-tobacco-marks .
      else
      if tt-tobacco-marks.qnty <> 1
      then do :
/*        message                                                                 */
/*        vss-workfile vss-revision vss-description skip                          */
/*        "Неправильное количество по марке - " string(tt-tobacco-marks.qnty) skip*/
/*        "Марка " tt-tobacco-marks.mark skip                                     */
/*        "Вероятно она была продана, возвращена, и снова продана." skip          */
/*        "В этом случае товар зарезервируется при закрытии продажи" skip         */
/*        view-as alert-box error .                                               */
        undo, return error return-value .
      end.
    end.
    
    if p-mark <> "" and not buf_trn-doc.ext-doc-type = {&TDEDT_Inv}
    then do :
      find first buf_marking no-lock where buf_marking.mark begins p-mark no-error .
      find first tt-tobacco-marks no-lock where tt-tobacco-marks.mark = p-mark no-error .
      if available buf_marking
      and not available tt-tobacco-marks
      then do :
        create tt-tobacco-marks .
        assign
          tt-tobacco-marks.mark = buf_marking.mark
          tt-tobacco-marks.qnty = 1
          tt-tobacco-marks.unit = buf_marking.unit-ext
          tt-tobacco-marks.qnty = buf_marking.box-qnty
          p-mark = ""
          v-mark-tobacco = true
        .
        if v-isweighed
        then do :
          v-mark-weight = MarkWeight(buf_marking.mark).
          assign
            tt-tobacco-marks.is-weight = yes
            tt-tobacco-marks.weight = v-mark-weight
          .
        end .
      end .
    end .
    
    
/*    ZI-701 Кол-во по коробу берем из марки, то что пришло из 1С     */
/*    for each buf_tt-tobacco-marks exclusive-lock where buf_tt-tobacco-marks.unit = "LEVEL2" :                      */
/*/*    first buf_marking no-lock where buf_marking.mark = tt-tobacco-marks.mark*/                                   */
/*/*                                and buf_marking.unit-ext = "LEVEL1" :       */                                   */
/*      assign v-box-qnty = 0 .                                                                                      */
/*      for each buf_marking-childs no-lock where buf_marking-childs.mark-parent = buf_tt-tobacco-marks.mark :       */
/*        find first tt-tobacco-marks exclusive-lock where tt-tobacco-marks.mark = buf_marking-childs.mark no-error .*/
/*        if not available tt-tobacco-marks                                                                          */
/*        then do :                                                                                                  */
/*          create tt-tobacco-marks .                                                                                */
/*          assign                                                                                                   */
/*            tt-tobacco-marks.mark = buf_marking-childs.mark                                                        */
/*            tt-tobacco-marks.unit = "LEVEL1"                                                                       */
/*            tt-tobacco-marks.qnty = 0                                                                              */
/*          .                                                                                                        */
/*        end.                                                                                                       */
/*        assign                                                                                                     */
/*          tt-tobacco-marks.qnty = tt-tobacco-marks.qnty + buf_marking-childs.box-qnty                              */
/*          v-box-qnty = v-box-qnty + buf_marking-childs.box-qnty                                                    */
/*        .                                                                                                          */
/*      end .                                                                                                        */
/*      if  v-box-qnty <> 50                                                                                         */
/*      then do :                                                                                                    */
/*        /* error */                                                                                                */
/*      end.                                                                                                         */
/*      buf_tt-tobacco-marks.qnty = v-box-qnty.                                                                      */
/*/*      delete buf_tt-tobacco-marks .*/                                                                            */
/*    end .                                                                                                          */
    
    /*p-mark = v-mark.*/ /* ?????? S.Slivenko: Я вообще не знаю и не понимаю, зачем сюда добавили p-mark (то есть одиночную марку). Логики не вижу. Вопросы к Шкляр/Морозову*/            
                                   
/*    find first buf1_doc-line-attr exclusive-lock where buf1_doc-line-attr.doc-code = buf_doc-line.doc-code   */
/*                                                  and buf1_doc-line-attr.gds-code = buf1_goods.gds-code      */
/*                                                  and buf1_doc-line-attr.attr-code = 'mark-code'             */
/*                                                  no-error.                                                  */
/*    if available buf1_doc-line-attr and buf1_doc-line-attr.attr-value <> ''                                  */
/*    then do :                                                                                                */
/*      do mark-ii = 1 to num-entries(buf1_doc-line-attr.attr-value) :                                         */
/*        entry(mark-ii, buf1_doc-line-attr.attr-value) = trim(entry(mark-ii, buf1_doc-line-attr.attr-value)) .*/
/*        v-mark = entry(mark-ii, buf1_doc-line-attr.attr-value) .                                             */
/*        if v-mark begins "-"                                                                                 */
/*        then do jj = 1 to num-entries(buf1_doc-line-attr.attr-value) :                                       */
/*            if entry(jj, buf1_doc-line-attr.attr-value) = left-trim(v-mark, "-")                             */
/*            then do :                                                                                        */
/*               entry(jj, buf1_doc-line-attr.attr-value) = "del=" + entry(jj, buf1_doc-line-attr.attr-value) .*/
/*               leave .                                                                                       */
/*            end.                                                                                             */
/*        end.                                                                                                 */
/*      end.                                                                                                   */
/*      do mark-ii = 1 to num-entries(buf1_doc-line-attr.attr-value) :                                         */
/*        v-mark = entry(mark-ii, buf1_doc-line-attr.attr-value) .                                             */
/*        if not (v-mark begins "-" or v-mark begins "del=")                                                   */
/*        then v-mark-list = v-mark-list + (if v-mark-list = '' then '' else ',') + v-mark .                   */
/*      end.                                                                                                   */
/*      buf1_doc-line-attr.attr-value = v-mark-list .                                                          */
/*      do mark-ii = 1 to min(num-entries(buf1_doc-line-attr.attr-value), buf_doc-line.fact-qnty) :            */
/*        v-mark = entry(mark-ii, buf1_doc-line-attr.attr-value) .                                             */
/*        run ProcAlcCode (input v-mark, output v-alc-code) no-error.                                          */
/*        if v-alc-code = ''                                                                                   */
/*        then do :                                                                                            */
/*          message                                                                                            */
/*            vss-workfile vss-revision vss-description skip                                                   */
/*            "Ошибка определения алкогольного кода" skip                                                      */
/*            "Марка - " v-mark skip                                                                           */
/*            view-as alert-box error .                                                                        */
/*          undo, return error return-value .                                                                  */
/*        end.                                                                                                 */
/*        if v-alc-code > ''                                                                                   */
/*        then do :                                                                                            */
/*          find first tt-alc-codes exclusive-lock where tt-alc-codes.alc-code = v-alc-code no-error.          */
/*          if not available tt-alc-codes                                                                      */
/*          then do :                                                                                          */
/*              create tt-alc-codes.                                                                           */
/*              assign tt-alc-codes.alc-code = v-alc-code .                                                    */
/*          end.                                                                                               */
/*          tt-alc-codes.qnty = tt-alc-codes.qnty + 1 .                                                        */
/*        end.                                                                                                 */
/*                                                                                                             */
/*        p-mark = v-mark .                                                                                    */
/*        create tt-marks.                                                                                     */
/*        assign tt-marks.mark = v-mark .                                                                      */
/*      end.                                                                                                   */
/*    end.                                                                                                     */
/*    release buf1_goods no-error .                                                                            */
/*    release buf1_doc-line-attr no-error .                                                                    */
/* run gbl/inidebug.p .
    if buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh}
    then do :
        for each buf_gen-attr no-lock where buf_gen-attr.table-name = {&excise-mark}
                                        and buf_gen-attr.attr-value = (buf_doc-line.artic + {&delim-key} + buf_doc-line.prod-type + {&delim-key} + string(buf_doc-line.prod-code)) 
                                        and buf_gen-attr.p-key      = ("trn-doc" + {&delim-key} + buf_trn-doc.doc-code) :
            create tt-marks.
            assign tt-marks.mark = buf_gen-attr.attr-code .                                
        end.
    end.
    */
    find first tt-marks no-error.                         
    if not available tt-marks then v-mark-alchol = false .
    
    v-alc-qnty = 0 .
    for each tt-alc-codes exclusive-lock :
        v-alc-qnty = v-alc-qnty + tt-alc-codes.qnty .
    end.
    
/*    А вот здесь начинаются танцы с бубном.                                                                               */
/*    Случай, когда дорезервируем товар с марками, но который изначально заразервировался или частично заразервировался    */
/*    по ФИФО, из-за того, что не была найдена партия/партии с алкокодом/алкокодами из марок.                              */
/*    Боюсь, что до конца всё привести в порядок удасться только когда реализуем помарочный учёт (марки в партиях).        */
    if p-chg-qnty < v-alc-qnty and p-chg-qnty > 0
    then
    for each  buf2_parts no-lock
        where buf2_parts.obj-type  = buf_doc-line.obj-type
          and buf2_parts.obj-code  = buf_doc-line.obj-code
          and buf2_parts.artic     = buf_doc-line.artic
          and buf2_parts.prod-type = buf_doc-line.prod-type
          and buf2_parts.prod-code = buf_doc-line.prod-code
          and buf2_parts.out-code  = buf_doc-line.doc-code
          and buf2_parts.status_   = no
          and buf2_parts.fact-qnty > 0
    use-index FIFO :
        if num-entries(buf2_parts.alc-ref-ab-path) = 4
        and entry(3, buf2_parts.alc-ref-ab-path) <> ""
        then do :
            find first tt-alc-codes exclusive-lock where tt-alc-codes.alc-code = entry(3, buf2_parts.alc-ref-ab-path) no-error.
            if not available tt-alc-codes
            then do :
              find first tt-alc-codes exclusive-lock where tt-alc-codes.alc-code <> "new-mark" no-error.
              if not available tt-alc-codes
              then do :
                find first tt-alc-codes exclusive-lock .
              end.
            end.
            tt-alc-codes.qnty = tt-alc-codes.qnty - min(buf2_parts.fact-qnty, tt-alc-codes.qnty) .
            v-alc-qnty = v-alc-qnty - min(buf2_parts.fact-qnty, tt-alc-codes.qnty) .
            if tt-alc-codes.qnty = 0
            then do :
                delete tt-alc-codes . 
                if p-chg-qnty < v-alc-qnty
                then do :
                    find next tt-alc-codes exclusive-lock no-error.
                    if not available tt-alc-codes then find first tt-alc-codes exclusive-lock .
                    tt-alc-codes.qnty = tt-alc-codes.qnty - (v-alc-qnty - p-chg-qnty) .
                    v-alc-qnty = p-chg-qnty .
                    leave .
                end.
            end.
        end.
        else do :
            find first tt-alc-codes exclusive-lock .
            tt-alc-codes.qnty = tt-alc-codes.qnty - min(buf2_parts.fact-qnty, tt-alc-codes.qnty) .
            v-alc-qnty = v-alc-qnty - min(buf2_parts.fact-qnty, tt-alc-codes.qnty) .
            if tt-alc-codes.qnty = 0
            then do :
                delete tt-alc-codes . 
                if p-chg-qnty < v-alc-qnty
                then do :
                    find next tt-alc-codes exclusive-lock no-error.
                    if not available tt-alc-codes then find first tt-alc-codes exclusive-lock .
                    tt-alc-codes.qnty = tt-alc-codes.qnty - (v-alc-qnty - p-chg-qnty) .
                    v-alc-qnty = p-chg-qnty .
                    leave .
                end.
            end.
        end.
    end.
    
    find first tt-tobacco-marks no-error.                         
    if not available tt-tobacco-marks
    then v-mark-tobacco = false .
    else v-mark-tobacco = true .

    /* определяем знак изменяемого количества */
    assign
      v-chg-qnty-sign = 0
    .
    if p-chg-qnty > 0
    then do:
      assign
        v-chg-qnty-sign = 1
      .
    end.
    if p-chg-qnty < 0
    then do:
      assign
        v-chg-qnty-sign = - 1
      .
    end.

    if  buf_trn-doc.ext-doc-type <> {&TDEDT_Peresort}
    and buf_trn-doc.ext-doc-type <> {&TDEDT_Corr_Acc_Price}
    and buf_trn-doc.ext-doc-type <> {&TDEDT_Corr_Minus_Parts}
    then do:
      run unrsrv-negative in this-procedure
        (buffer buf_doc-line
        ,input  p-chg-qnty
        ,output v-real-chg-qnty
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове процедуры unrsrv-negative" skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.

    assign
      p-chg-qnty      = p-chg-qnty      - abs(v-real-chg-qnty) * v-chg-qnty-sign
      p-real-chg-qnty = p-real-chg-qnty + abs(v-real-chg-qnty) * v-chg-qnty-sign
    .

    if p-chg-qnty = 0
    then do:
      return . /* --->>>--- */
    end.

    define variable v-fifo as logical   no-undo .
    define variable v-alc-rsrv  as logical   no-undo .

    if p-unreserv-other-sign
    then do:
      if buf_trn-doc.doc-type = {&expense}
      or buf_trn-doc.doc-type = {&write-off}
      then do:
        assign
          v-fifo = true
        .
      end.
      else do:
        assign
          v-fifo = false
        .
      end.

      if v-fifo
      then do:
        find first buf_parts
          where buf_parts.obj-type  = buf_doc-line.obj-type
            and buf_parts.obj-code  = buf_doc-line.obj-code
            and buf_parts.artic     = buf_doc-line.artic
            and buf_parts.prod-type = buf_doc-line.prod-type
            and buf_parts.prod-code = buf_doc-line.prod-code
            and buf_parts.out-code  = buf_doc-line.doc-code
            and buf_parts.in-code   <> buf_parts.out-code
            and buf_parts.qnty * p-chg-qnty < 0
          use-index FIFO
          no-error.
      end.
      else do:
        find last buf_parts
          where buf_parts.obj-type  = buf_doc-line.obj-type
            and buf_parts.obj-code  = buf_doc-line.obj-code
            and buf_parts.artic     = buf_doc-line.artic
            and buf_parts.prod-type = buf_doc-line.prod-type
            and buf_parts.prod-code = buf_doc-line.prod-code
            and buf_parts.out-code  = buf_doc-line.doc-code
            and buf_parts.in-code   <> buf_parts.out-code
            and buf_parts.qnty * p-chg-qnty < 0
          use-index FIFO
          no-error.
      end.
      
      if p-mark <> "" and buf_trn-doc.ext-doc-type = {&TDEDT_Inv}
      then do:
  
        find first buf_marking no-lock where buf_marking.mark begins p-mark no-error .
        if not available buf_marking
        then do :
          put stream tobacco-rsrv unformatted "Артикул " buf_doc-line.artic " " buf_doc-line.prod-type string(buf_doc-line.prod-code)
                  " . В БД не найдена запись для марки " p-mark  skip .
          undo, return error ("В БД не найдена запись для марки " + p-mark) .
        end .
        
        if buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:FreeZone:KeyIntDB
        and buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:Reserved:KeyIntDB   
        and buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:SaleLock:KeyIntDB
        and buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:ReturnLock:KeyIntDB
        and buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:SaleWaitLock:KeyIntDB
        and buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:ReturnWaitLock:KeyIntDB   
        and buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:OutZone:KeyIntDB
        and buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:Ungrouped:KeyIntDB           
        then do :
          put stream tobacco-rsrv unformatted "Артикул " buf_doc-line.artic " " buf_doc-line.prod-type string(buf_doc-line.prod-code)
                  " . Марка " p-mark " в статусе " objSrv:Env:Marking:Sts:Mark:GetLabel(buf_marking.sts) skip .
          undo, return error ("Марка " + p-mark + " в статусе " + objSrv:Env:Marking:Sts:Mark:GetLabel(buf_marking.sts) ) .    
        end .
        
        find first buf_marking-lines no-lock where buf_marking-lines.mark = buf_marking.mark
                                               and buf_marking-lines.obj-type = buf_doc-line.obj-type
                                               and buf_marking-lines.obj-code = buf_doc-line.obj-code
                                               and buf_marking-lines.in-code <> buf_marking-lines.out-code
                                               no-error .
        if not available buf_marking-lines
        then do :
          put stream tobacco-rsrv unformatted "Артикул " buf_doc-line.artic " " buf_doc-line.prod-type string(buf_doc-line.prod-code)
                  " . В БД не найдена запись для марки в линии документа " p-mark  skip .
          undo, return error ("В БД не найдена запись для марки в линии документа " + p-mark) .
        end.
        find first buf_goods no-lock where buf_goods.gds-code = buf_marking-lines.gds-code .
        find first buf_parts
          where buf_parts.obj-type  = buf_marking-lines.obj-type
            and buf_parts.obj-code  = buf_marking-lines.obj-code
            and buf_parts.artic     = buf_goods.artic
            and buf_parts.prod-type = buf_goods.prod-type
            and buf_parts.prod-code = buf_goods.prod-code
            and buf_parts.in-code   = buf_marking-lines.in-code
            and buf_parts.out-code  = buf_marking-lines.out-code
            and buf_parts.part-code = buf_marking-lines.part-code 
          use-index FIFO
          no-error.
        if available buf_parts
        then v-fifo = false .
        else v-fifo = true . 
                
      end. 

      do while p-chg-qnty <> 0
      and available buf_parts
      :
        assign
          v-check-part-qnty = p-chg-qnty
                            * ( if lookup(buf_trn-doc.doc-type, {&expense_write-off} ) > 0
                                then -1
                                else 1
                              )
        .

        /* определяем необходимость резервирования партии */
        { gbl/part-prc.i
          buf_parts
          buf_trn-doc
          p-reserv-single-part
          p-in-code
          p-part-code
          p-pl-code
          p-goods-twounit
          p-purch-code-list
          v-check-part-qnty
          "true"
          v-reason
          v-process-part
          no-error
        }
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при определении возможности резервирования партии" skip
            "Документ" buf_doc-line.doc-code skip
            "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error return-value .
        end.

        if v-process-part = true
        then do:
          /* Резервирование или снятие резервов */
          run partrsrv in this-procedure
            (input  p-chg-qnty      /* p-chg-qnty      */
                    * ( if lookup(buf_trn-doc.doc-type, {&expense_write-off} ) > 0
                        then -1
                        else 1
                      )
            ,input  p-goods-serial  /* p-goods-serial  */
            ,input  p-goods-twounit /* p-goods-twounit */
            ,input  true            /* p-unreserv-only */
            ,buffer buf_parts       /* buf_orig_parts  */
            ,buffer buf_trn-doc     /* buf_trn-doc     */
            ,output v-real-chg-qnty /* p-real-chg-qnty */
            ,output v-parts-recid   /* p-parts-recid   */
            ,input  p-mark
            ) no-error .
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при вызове partrsrv" skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            return return-value .
          end.

          assign
            p-chg-qnty      = p-chg-qnty      - abs(v-real-chg-qnty) * v-chg-qnty-sign
            p-real-chg-qnty = p-real-chg-qnty + abs(v-real-chg-qnty) * v-chg-qnty-sign
          .
        end.

        /* ищем следующую доступную партию */
        if v-fifo
        then do:
          find next buf_parts
            where buf_parts.obj-type  = buf_doc-line.obj-type
              and buf_parts.obj-code  = buf_doc-line.obj-code
              and buf_parts.artic     = buf_doc-line.artic
              and buf_parts.prod-type = buf_doc-line.prod-type
              and buf_parts.prod-code = buf_doc-line.prod-code
              and buf_parts.out-code  = buf_doc-line.doc-code
              and buf_parts.in-code   <> buf_parts.out-code
              and buf_parts.qnty * p-chg-qnty < 0
            use-index FIFO
            no-error.
        end.
        else do:
          find prev buf_parts
            where buf_parts.obj-type  = buf_doc-line.obj-type
              and buf_parts.obj-code  = buf_doc-line.obj-code
              and buf_parts.artic     = buf_doc-line.artic
              and buf_parts.prod-type = buf_doc-line.prod-type
              and buf_parts.prod-code = buf_doc-line.prod-code
              and buf_parts.out-code  = buf_doc-line.doc-code
              and buf_parts.in-code   <> buf_parts.out-code
              and buf_parts.qnty * p-chg-qnty < 0
            use-index FIFO
            no-error.
        end.
      end.
    end.

    if  buf_trn-doc.discnt-type = {&cash-desk}
    and p-goods-serial = true
    then do:
      /* Продажа через кассу серийных товаров  */
      /* бар-код должен быть задан обязательно */
      if p-reserv-single-part = false
      then do:
        return . /* --->>>--- */
      end.
    end.

    /* необходимо использовать список партий */
    define variable v-partlist-use    as logical   no-undo .

    /* порядок резервирования партий */
    define variable v-partlist-order  as character no-undo .

    run partlist_use-get in this-procedure
      (output v-partlist-use
      ) .
/*      
    find first tt-alc-codes no-error.
    if available tt-alc-codes
    then do :
      v-alc-rsrv = true .
    end.
    else do :
       v-alc-rsrv = false .  
       find first tt-marks no-error .
       if buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh} and available tt-marks
       then do :
           v-alc-rsrv = true .
           release tt-marks no-error .
       end.
    end.  
*/
    if p-chg-qnty < 0
    then do:
      if buf_trn-doc.doc-type = {&inventory}
      then do:
        assign
          v-rsrv-code = {&free-code}
        .
        assign
          v-fifo = true
        .
        if v-partlist-use = true
        then do:
          assign
            v-partlist-order  = 'partlist-increment,parts':u
          .
        end.
        else do:
          assign
            v-partlist-order  = 'parts':u
          .
        end.
      end.
      else do:
        assign
          v-rsrv-code = buf_doc-line.doc-code
        .
        if buf_trn-doc.doc-type = {&expense}
        or buf_trn-doc.doc-type = {&write-off}
        then do:
          find first tt-alc-codes no-error.
          if available tt-alc-codes
          then do :
            v-alc-rsrv = true .
          end.
          else do :
             v-alc-rsrv = false .  
          end. 
          assign
            v-fifo = false
          .
          if v-partlist-use = true
          then do:
            assign
              v-partlist-order  = 'parts,partlist-decrement':u
            .
          end.
          else do:
            assign
              v-partlist-order  = 'parts':u
            .
          end.
        end.
        else do:
          assign
            v-fifo = true
          .
          if v-partlist-use = true
          then do:
            assign
              v-partlist-order  = 'parts,partlist-decrement':u
            .
          end.
          else do:
            assign
              v-partlist-order  = 'parts':u
            .
          end.
        end.
      end.
    end.
    else do:
      /* p-chg-qnty > 0 */
      assign
        v-rsrv-code = { trg/partsprm.i "rsrv-code" "buf_trn-doc." "0" }
      .
      if v-rsrv-code = {&free-code}
      then do:
/*        find first tt-marks no-error.                         */
/*        if not available tt-marks then v-mark-alchol = false .*/
        
        find first tt-alc-codes no-error.
        if available tt-alc-codes
        then do :
          v-alc-rsrv = true .
        end.
        else do :
           v-alc-rsrv = false .  
        end.  
        assign
          v-fifo = true
        .
        if v-partlist-use = true
        then do:
          assign
            v-partlist-order = 'partlist-increment,parts':u
          .
        end.
        else do:
          assign
            v-partlist-order = 'parts':u
          .
        end.
      end.
      else do:
        assign
          v-fifo = false
        .
        if v-partlist-use = true
        then do:
          assign
            v-partlist-order = 'partlist-increment,parts':u
          .
        end.
        else do:
          assign
            v-partlist-order = 'parts':u
          .
        end.
      end.
    end.

    if  v-partlist-use = false
    and v-partlist-order <> 'parts':u
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Внутренняя ошибка резервирования" skip
        view-as alert-box error .
    end.

    define variable v-find-first         as logical   no-undo .
    define variable v-rsrv-index         as integer   no-undo .
    define variable v-rsrv-entry         as character no-undo .
    define variable v-iteration-chg-qnty as decimal   no-undo .
    define variable v-part-index         as integer   no-undo .
    define variable v-max-part-index     as integer   no-undo .
    define variable v-partlist-in-code   as character no-undo .
    define variable v-partlist-part-code as character no-undo .
    define variable v-partlist-rsrv-qnty as decimal   no-undo .
    define variable v-msg                as character no-undo .

    assign
      v-find-first = true
      v-rsrv-index = 1
      v-rsrv-entry = entry(v-rsrv-index, v-partlist-order, {&comma-char})
    .
    
    output stream alc-rsrv to value ("alc-rsrv.log") .
    
    rsrv_cycle:
    do while p-chg-qnty <> 0
    :
/*run gbl/inidebug.p .*/
      assign
        v-iteration-chg-qnty = 0
      .

      /* найти партию в соответствии с условиями */
      case v-rsrv-entry :
        when 'parts':u
        then do:
          assign
            v-iteration-chg-qnty = p-chg-qnty
          .
          if v-find-first = true
          then do:
            assign
              v-find-first = false
            .
            
            if p-mark <> ""
            or v-mark-alchol
            then do :
              find first tt-marks no-error .
              assign
                v-iteration-chg-qnty = v-chg-qnty-sign
              .
              find first buf_gen-attr no-lock where buf_gen-attr.table-name = {&excise-mark}
                                                and buf_gen-attr.attr-code = (if available tt-marks then tt-marks.mark else p-mark)
                                                and num-entries(buf_gen-attr.p-key, {&delim-key}) >= 8
                                                and entry(8, buf_gen-attr.p-key, {&delim-key}) = v-rsrv-code
                                                and entry(2, buf_gen-attr.p-key, {&delim-key}) = buf_doc-line.obj-type
                                                and integer(entry(3, buf_gen-attr.p-key, {&delim-key})) = buf_doc-line.obj-code
                                                no-error .
              
              
              
              if available buf_gen-attr
              then do :
                  if not 
                    (
                        entry(4, buf_gen-attr.p-key, {&delim-key}) = buf_doc-line.artic
                    and entry(5, buf_gen-attr.p-key, {&delim-key}) = buf_doc-line.prod-type  
                    and entry(6, buf_gen-attr.p-key, {&delim-key}) = string (buf_doc-line.prod-code)
                    )
                  then do:
                    v-msg = "Артикул товара в чеке " + buf_doc-line.artic + " " + buf_doc-line.prod-type + string(buf_doc-line.prod-code)
                      + substitute ("  не сооотвествует артиклу &1 &2&3 с маркой в свободной зоне " 
                      , entry(4, buf_gen-attr.p-key, {&delim-key})
                      , entry(5, buf_gen-attr.p-key, {&delim-key})
                      , entry(6, buf_gen-attr.p-key, {&delim-key})) + tt-marks.mark.

                    put stream alc-rsrv unformatted v-msg skip .
                    message
                      vss-workfile vss-revision vss-description skip
                      v-msg skip
                      error-status :get-message(1) skip
                      return-value skip
                      view-as alert-box error .
                    undo, return error return-value .

                  end.
                  find first  buf_parts
                        where buf_parts.obj-type  = entry(2, buf_gen-attr.p-key, {&delim-key})
                          and buf_parts.obj-code  = integer(entry(3, buf_gen-attr.p-key, {&delim-key}))
                          and buf_parts.artic     = entry(4, buf_gen-attr.p-key, {&delim-key})
                          and buf_parts.prod-type = entry(5, buf_gen-attr.p-key, {&delim-key})
                          and buf_parts.prod-code = integer(entry(6, buf_gen-attr.p-key, {&delim-key}))
                          and buf_parts.in-code   = entry(7, buf_gen-attr.p-key, {&delim-key})
                          and (
                           (buf_parts.out-code  = entry(8, buf_gen-attr.p-key, {&delim-key})and available tt-marks)
                            or p-mark <> ""
                               )
                          and buf_parts.part-code = entry(9, buf_gen-attr.p-key, {&delim-key})
                          and buf_parts.status_   = no
                          and buf_parts.fact-qnty > 0
                        use-index FIFO
                        no-error.
                  if available buf_parts
                  then v-fifo = false .
                  else v-fifo = true .
              end. 
              if not available buf_gen-attr 
              or (available buf_gen-attr and not available buf_parts)     
              then do :
                  if not available buf_gen-attr
                  then do :
                    if available tt-marks
                    then
                      put stream alc-rsrv unformatted "Артикул " buf_doc-line.artic " " buf_doc-line.prod-type string(buf_doc-line.prod-code)
                        "  марка " tt-marks.mark " не найдена в свободной зоне. Ищем партию по алкокоду..." skip .
                    else
                      put stream alc-rsrv unformatted "Артикул " buf_doc-line.artic " " buf_doc-line.prod-type string(buf_doc-line.prod-code)
                        "  марка " p-mark " не найдена в свободной зоне. Ищем партию по алкокоду..." skip .
                  end.
                  else do :
                    if available tt-marks
                    then
                      put stream alc-rsrv unformatted "Артикул " buf_doc-line.artic " " buf_doc-line.prod-type string(buf_doc-line.prod-code)
                        "  марка " tt-marks.mark ". Не найдена партия свободной зоны. Ищем партию по алкокоду..." skip .
                    else
                      put stream alc-rsrv unformatted "Артикул " buf_doc-line.artic " " buf_doc-line.prod-type string(buf_doc-line.prod-code)
                        "  марка " p-mark ". Не найдена партия свободной зоны. Ищем партию по алкокоду..." skip .
                  end.
                  if available tt-marks
                  then run ProcAlcCode (input tt-marks.mark, output v-alc-code) no-error.
                  else run ProcAlcCode (input p-mark, output v-alc-code) no-error.
                  if v-alc-code <> "" and v-alc-code <> ? 
                  then
                  find first buf_parts
                    where buf_parts.obj-type  = buf_doc-line.obj-type
                      and buf_parts.obj-code  = buf_doc-line.obj-code
                      and buf_parts.artic     = buf_doc-line.artic
                      and buf_parts.prod-type = buf_doc-line.prod-type
                      and buf_parts.prod-code = buf_doc-line.prod-code
                      and buf_parts.out-code  = v-rsrv-code
                      and buf_parts.status_   = no
                      and buf_parts.fact-qnty > 0
                      and num-entries(buf_parts.alc-ref-ab-path) = 4
                      and entry(3, buf_parts.alc-ref-ab-path) = v-alc-code
                    use-index FIFO
                    no-error.
                  if available buf_parts
                  then v-fifo = false .
                  else do :
                    v-fifo = true .
                    if available tt-marks
                    then
                      put stream alc-rsrv unformatted "Артикул " buf_doc-line.artic " " buf_doc-line.prod-type string(buf_doc-line.prod-code)
                        "  марка " tt-marks.mark ". Алкокод " v-alc-code ". Не найдена партия по алкокоду. Берём по ФИФО." skip .
                    else
                      put stream alc-rsrv unformatted "Артикул " buf_doc-line.artic " " buf_doc-line.prod-type string(buf_doc-line.prod-code)
                        "  марка " p-mark ". Алкокод " v-alc-code ". Не найдена партия по алкокоду. Берём по ФИФО." skip .
                  end.  
              end.                       
            end.
            else
            if v-alc-rsrv
            then do :
              find first tt-alc-codes .
              assign
                v-iteration-chg-qnty = tt-alc-codes.qnty
              .
              find first buf_parts
                where buf_parts.obj-type  = buf_doc-line.obj-type
                  and buf_parts.obj-code  = buf_doc-line.obj-code
                  and buf_parts.artic     = buf_doc-line.artic
                  and buf_parts.prod-type = buf_doc-line.prod-type
                  and buf_parts.prod-code = buf_doc-line.prod-code
                  and buf_parts.out-code  = v-rsrv-code
                  and buf_parts.status_   = no
                  and buf_parts.fact-qnty > 0
                  and num-entries(buf_parts.alc-ref-ab-path) = 4
                  and entry(3, buf_parts.alc-ref-ab-path) = tt-alc-codes.alc-code
                use-index FIFO
                no-error.
              if available buf_parts
              then v-fifo = false .
              else v-fifo = true .  
            end.

            if v-mark-tobacco
            then do :
              find first tt-tobacco-marks use-index un no-error .
              if tt-tobacco-marks.unit = "UNIT"
              then do :
                assign
                  v-iteration-chg-qnty = v-chg-qnty-sign
                .
              end .
              else
              if tt-tobacco-marks.unit = "LEVEL1"
              then do :
                assign
                  v-GTIN = getGtinByDM(tt-tobacco-marks.mark)
                  v-GTIN-qnty = getQntyCodeByGtin(v-GTIN)
                  v-iteration-chg-qnty = v-chg-qnty-sign * v-GTIN-qnty
                .
              end .
              if tt-tobacco-marks.is-weight
              then do :
                assign
                  v-iteration-chg-qnty = v-chg-qnty-sign * tt-tobacco-marks.weight
                .
              end .
              find first buf_marking no-lock where buf_marking.mark begins tt-tobacco-marks.mark no-error .
              if not available buf_marking
              then do :
                put stream tobacco-rsrv unformatted "Артикул " buf_doc-line.artic " " buf_doc-line.prod-type string(buf_doc-line.prod-code)
                        " . В БД не найдена запись для марки " tt-tobacco-marks.mark  skip .
                undo, return error ("В БД не найдена запись для марки " + tt-tobacco-marks.mark) .
              end .
              
              if buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:FreeZone:KeyIntDB
              and buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:Reserved:KeyIntDB   
              and buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:SaleLock:KeyIntDB
              and buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:ReturnLock:KeyIntDB
              and buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:SaleWaitLock:KeyIntDB
              and buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:ReturnWaitLock:KeyIntDB   
              and buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:OutZone:KeyIntDB
              and buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:Ungrouped:KeyIntDB           
              and buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:Moved:KeyIntDB           
              and buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:OutOfInventory:KeyIntDB           
              and buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:Checked_:KeyIntDB           
              then do :
                put stream tobacco-rsrv unformatted "Артикул " buf_doc-line.artic " " buf_doc-line.prod-type string(buf_doc-line.prod-code)
                        " . Марка " tt-tobacco-marks.mark " в статусе " objSrv:Env:Marking:Sts:Mark:GetLabel(buf_marking.sts) skip .
                undo, return error ("Марка " + tt-tobacco-marks.mark + " в статусе " + objSrv:Env:Marking:Sts:Mark:GetLabel(buf_marking.sts) ) .    
              end .
              
/*              find first buf_marking-lines no-lock where buf_marking-lines.mark = buf_marking.mark                                                                        */
/*                                                     and buf_marking-lines.obj-type = buf_doc-line.obj-type                                                               */
/*                                                     and buf_marking-lines.obj-code = buf_doc-line.obj-code                                                               */
/*                                                     and buf_marking-lines.out-code = v-rsrv-code                                                                         */
/*                                                     no-error .                                                                                                           */
/*              if not available buf_marking-lines                                                                                                                          */
/*              then do :                                                                                                                                                   */
/*/*                put stream tobacco-rsrv unformatted "Артикул " buf_doc-line.artic " " buf_doc-line.prod-type string(buf_doc-line.prod-code)*/                           */
/*/*                        " . В БД не найдена запись для марки в линии документа " tt-tobacco-marks.mark  skip .                             */                           */
/*/*                undo, return error ("В БД не найдена запись для марки в линии документа " + tt-tobacco-marks.mark) .                       */                           */
/*                 /* добавляем марку, которой нет в свободных (не было в БД) */                                                                                            */
/*                 v-fifo = true.                                                                                                                                           */
/*              end.                                                                                                                                                        */
/*              else                                                                                                                                                        */
/*              do:                                                                                                                                                         */
/*                  find first buf_goods no-lock where buf_goods.gds-code = buf_marking-lines.gds-code .                                                                    */
/*                  find first buf_parts                                                                                                                                    */
/*                    where buf_parts.obj-type  = buf_marking-lines.obj-type                                                                                                */
/*                      and buf_parts.obj-code  = buf_marking-lines.obj-code                                                                                                */
/*                      and buf_parts.artic     = buf_goods.artic                                                                                                           */
/*                      and buf_parts.prod-type = buf_goods.prod-type                                                                                                       */
/*                      and buf_parts.prod-code = buf_goods.prod-code                                                                                                       */
/*                      and buf_parts.in-code   = buf_marking-lines.in-code                                                                                                 */
/*                      and buf_parts.out-code  = buf_marking-lines.out-code                                                                                                */
/*                      and buf_parts.part-code = buf_marking-lines.part-code                                                                                               */
/*                      and buf_parts.prt-code  = buf_marking-lines.prt-code                                                                                                */
/*                      and buf_parts.status_   = no                                                                                                                        */
/*                      and (buf_parts.fact-qnty > if buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Perem} or buf_trn-doc.ext-doc-type = {&TDEDT_Spi_Vnesh} then p-chg-qnty else 0)*/
/*                    use-index FIFO                                                                                                                                        */
/*                    no-error.                                                                                                                                             */
/*                  if available buf_parts                                                                                                                                  */
/*                  then v-fifo = false .                                                                                                                                   */
/*                  else v-fifo = true .                                                                                                                                    */
/*              end.                                                                                                                                                        */
              /* ищем свободную партию с этой маркой */  
              { trg/fndpartfifo.i
                "first"
                "and can-find(first buf_marking-lines where
                                    buf_marking-lines.mark      = tt-tobacco-marks.mark
                                and buf_marking-lines.in-code   = buf_parts.in-code 
                                and buf_marking-lines.out-code  = buf_parts.out-code
                                and buf_marking-lines.prt-code  = buf_parts.prt-code 
                                and buf_marking-lines.part-code = buf_parts.part-code
                                and buf_marking-lines.obj-code  = buf_parts.obj-code
                                and buf_marking-lines.obj-type  = buf_parts.obj-type)"}
              if available buf_parts
                then v-fifo = false .
                else v-fifo = true .
            end .

            if v-fifo = true
            then do:
              release buf_parts.
              if vIsExemplarGoods or v-isweighed then
                { trg/fndpartfifo.i
                  "first"
                  "and not can-find(first buf_marking-lines where
                                          buf_marking-lines.in-code   = buf_parts.in-code 
                                      and buf_marking-lines.out-code  = buf_parts.out-code
                                      and buf_marking-lines.prt-code  = buf_parts.prt-code 
                                      and buf_marking-lines.part-code = buf_parts.part-code
                                      and buf_marking-lines.obj-code  = buf_parts.obj-code
                                      and buf_marking-lines.obj-type  = buf_parts.obj-type )"}
              if not avail buf_parts then
                 { trg/fndpartfifo.i "first" }
            end.
            else if not v-alc-rsrv and not v-mark-tobacco
            then do:
              if p-mark = "" and not (v-izlcstpr and buf_trn-doc.ext-doc-type = {&TDEDT_Inv}) or (v-izlcstpr and p-action = {&rsrv-dtl_action_reserv-sozdanie}) then
              do:
                release buf_parts.
                if vIsExemplarGoods or v-isweighed then
                  { trg/fndpartfifo.i
                    "last"
                    "and not can-find(first buf_marking-lines where
                                            buf_marking-lines.in-code   = buf_parts.in-code 
                                        and buf_marking-lines.out-code  = buf_parts.out-code
                                        and buf_marking-lines.prt-code  = buf_parts.prt-code 
                                        and buf_marking-lines.part-code = buf_parts.part-code
                                        and buf_marking-lines.obj-code  = buf_parts.obj-code
                                        and buf_marking-lines.obj-type  = buf_parts.obj-type)"}
                if not avail buf_parts then
                   { trg/fndpartfifo.i "last" }
              end.
            end.
          end.
          else do:
            /* ищем следующую доступную партию */
            if p-mark <> ""
            or v-mark-alchol
            then do :
                find next tt-marks no-error .
                if available tt-marks
                or p-mark <> ""
                then do :
                  assign
                    v-iteration-chg-qnty = v-chg-qnty-sign
                  .
                  find first buf_gen-attr no-lock where buf_gen-attr.table-name = {&excise-mark}
                                                    and buf_gen-attr.attr-code = (if available tt-marks then tt-marks.mark else p-mark)
                                                    and num-entries(buf_gen-attr.p-key, {&delim-key}) >= 8
                                                    and entry(8, buf_gen-attr.p-key, {&delim-key}) = v-rsrv-code
                                                    and entry(2, buf_gen-attr.p-key, {&delim-key}) = buf_doc-line.obj-type
                                                    and integer(entry(3, buf_gen-attr.p-key, {&delim-key})) = buf_doc-line.obj-code
                                                    no-error .
                  if available buf_gen-attr
                  then do :
                    
                      if not 
                        (
                            entry(4, buf_gen-attr.p-key, {&delim-key}) = buf_doc-line.artic
                        and entry(5, buf_gen-attr.p-key, {&delim-key}) = buf_doc-line.prod-type  
                        and entry(6, buf_gen-attr.p-key, {&delim-key}) = string (buf_doc-line.prod-code)
                        )
                      then do:
                        put stream alc-rsrv unformatted "Артикул " buf_doc-line.artic " " buf_doc-line.prod-type string(buf_doc-line.prod-code)
                          substitute ("  не сооотвествует артиклу &1 &2&3 с маркой в свободной зоне " 
                          , entry(4, buf_gen-attr.p-key, {&delim-key}) = buf_doc-line.artic
                          , entry(5, buf_gen-attr.p-key, {&delim-key}) = buf_doc-line.artic
                          , entry(6, buf_gen-attr.p-key, {&delim-key}) = buf_doc-line.artic) tt-marks.mark  skip .
                        next rsrv_cycle . /* --->>>--- */
                      end.
                      find first  buf_parts
                            where buf_parts.obj-type  = entry(2, buf_gen-attr.p-key, {&delim-key})
                              and buf_parts.obj-code  = integer(entry(3, buf_gen-attr.p-key, {&delim-key}))
                              and buf_parts.artic     = entry(4, buf_gen-attr.p-key, {&delim-key})
                              and buf_parts.prod-type = entry(5, buf_gen-attr.p-key, {&delim-key})
                              and buf_parts.prod-code = integer(entry(6, buf_gen-attr.p-key, {&delim-key}))
                              and buf_parts.in-code   = entry(7, buf_gen-attr.p-key, {&delim-key})
                              and buf_parts.out-code  = entry(8, buf_gen-attr.p-key, {&delim-key})
                              and buf_parts.part-code = entry(9, buf_gen-attr.p-key, {&delim-key})
                              and buf_parts.status_   = no
                              and buf_parts.fact-qnty > 0
                            use-index FIFO
                            no-error.
                      if available buf_parts
                      then v-fifo = false .
                      else v-fifo = true .
                  end. 
                  if not available buf_gen-attr 
                  or (available buf_gen-attr and not available buf_parts)     
                  then do :
                      if not available buf_gen-attr
	                  then do :
	                    if available tt-marks
	                    then
	                      put stream alc-rsrv unformatted "Артикул " buf_doc-line.artic " " buf_doc-line.prod-type string(buf_doc-line.prod-code)
	                        "  марка " tt-marks.mark " не найдена в свободной зоне. Ищем партию по алкокоду..." skip .
	                    else
	                      put stream alc-rsrv unformatted "Артикул " buf_doc-line.artic " " buf_doc-line.prod-type string(buf_doc-line.prod-code)
	                        "  марка " p-mark " не найдена в свободной зоне. Ищем партию по алкокоду..." skip .
	                  end.
	                  else do :
	                    if available tt-marks
	                    then
	                      put stream alc-rsrv unformatted "Артикул " buf_doc-line.artic " " buf_doc-line.prod-type string(buf_doc-line.prod-code)
	                        "  марка " tt-marks.mark ". Не найдена партия свободной зоны. Ищем партию по алкокоду..." skip .
	                    else
	                      put stream alc-rsrv unformatted "Артикул " buf_doc-line.artic " " buf_doc-line.prod-type string(buf_doc-line.prod-code)
	                        "  марка " p-mark ". Не найдена партия свободной зоны. Ищем партию по алкокоду..." skip .
	                  end.
	                  if available tt-marks
	                  then run ProcAlcCode (input tt-marks.mark, output v-alc-code) no-error.
	                  else run ProcAlcCode (input p-mark, output v-alc-code) no-error.
                      if v-alc-code <> "" and v-alc-code <> ? 
                      then
                      find first buf_parts
                        where buf_parts.obj-type  = buf_doc-line.obj-type
                          and buf_parts.obj-code  = buf_doc-line.obj-code
                          and buf_parts.artic     = buf_doc-line.artic
                          and buf_parts.prod-type = buf_doc-line.prod-type
                          and buf_parts.prod-code = buf_doc-line.prod-code
                          and buf_parts.out-code  = v-rsrv-code
                          and buf_parts.status_   = no
                          and buf_parts.fact-qnty > 0
                          and num-entries(buf_parts.alc-ref-ab-path) = 4
                          and entry(3, buf_parts.alc-ref-ab-path) = v-alc-code
                        use-index FIFO
                        no-error.
                      if available buf_parts
                      then v-fifo = false .
                      else do :
                        v-fifo = true .
                        if available tt-marks
	                    then
	                      put stream alc-rsrv unformatted "Артикул " buf_doc-line.artic " " buf_doc-line.prod-type string(buf_doc-line.prod-code)
	                        "  марка " tt-marks.mark ". Алкокод " v-alc-code ". Не найдена партия по алкокоду. Берём по ФИФО." skip .
	                    else
	                      put stream alc-rsrv unformatted "Артикул " buf_doc-line.artic " " buf_doc-line.prod-type string(buf_doc-line.prod-code)
	                        "  марка " p-mark ". Алкокод " v-alc-code ". Не найдена партия по алкокоду. Берём по ФИФО." skip .
                      end.
                  end.
                end.
                else do :
                    v-fifo = true .
                end.
            end.
            else
            if v-alc-rsrv
            then do :
              if p-real-chg-qnty = tt-alc-codes.qnty
              then do :
                  find next tt-alc-codes no-error.
                  if available tt-alc-codes
                  then do :
                    assign
                      v-iteration-chg-qnty = tt-alc-codes.qnty
                    .
                    find first buf_parts
                    where buf_parts.obj-type  = buf_doc-line.obj-type
                      and buf_parts.obj-code  = buf_doc-line.obj-code
                      and buf_parts.artic     = buf_doc-line.artic
                      and buf_parts.prod-type = buf_doc-line.prod-type
                      and buf_parts.prod-code = buf_doc-line.prod-code
                      and buf_parts.out-code  = v-rsrv-code
                      and buf_parts.status_   = no
                      and buf_parts.fact-qnty > 0
                      and num-entries(buf_parts.alc-ref-ab-path) = 4
                      and entry(3, buf_parts.alc-ref-ab-path) = tt-alc-codes.alc-code
                    use-index FIFO
                    no-error.
                    if available buf_parts
                    then v-fifo = false .
                    else v-fifo = true .  
                  end. 
                  else do :
                    v-fifo = true .  
                  end.
              end.    
              else do :
/*                  find first tt-alc-codes .*/
                  find first buf_parts
                    where buf_parts.obj-type  = buf_doc-line.obj-type
                      and buf_parts.obj-code  = buf_doc-line.obj-code
                      and buf_parts.artic     = buf_doc-line.artic
                      and buf_parts.prod-type = buf_doc-line.prod-type
                      and buf_parts.prod-code = buf_doc-line.prod-code
                      and buf_parts.out-code  = v-rsrv-code
                      and buf_parts.status_   = no
                      and buf_parts.fact-qnty > 0
                      and num-entries(buf_parts.alc-ref-ab-path) = 4
                      and entry(3, buf_parts.alc-ref-ab-path) = tt-alc-codes.alc-code
                    use-index FIFO
                    no-error.
                  if available buf_parts
                  then v-fifo = false .
                  else v-fifo = true . 
              end. 
            end.
            
            if v-mark-tobacco
            then do :
              find next tt-tobacco-marks use-index un no-error .
              if available tt-tobacco-marks
              then do :
                if tt-tobacco-marks.unit = "UNIT"
                then do :
                  assign
                    v-iteration-chg-qnty = v-chg-qnty-sign
                  .
                end .
                else
                if tt-tobacco-marks.unit = "LEVEL1"
                then do :
                  assign
                    v-iteration-chg-qnty = v-chg-qnty-sign * 10
                  .
                end .
                find first buf_marking no-lock where buf_marking.mark begins tt-tobacco-marks.mark no-error .
                if not available buf_marking
                then do :
                  put stream tobacco-rsrv unformatted "Артикул " buf_doc-line.artic " " buf_doc-line.prod-type string(buf_doc-line.prod-code)
                        " . В БД не найдена запись для марки " tt-tobacco-marks.mark  skip .
                  undo, return error ("В БД не найдена запись для марки " + tt-tobacco-marks.mark) .
                end .
                if buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:FreeZone:KeyIntDB
                and buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:Reserved:KeyIntDB   
                and buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:SaleLock:KeyIntDB
                and buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:ReturnLock:KeyIntDB
                and buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:SaleWaitLock:KeyIntDB
                and buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:ReturnWaitLock:KeyIntDB
                and buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:OutZone:KeyIntDB
                and buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:Ungrouped:KeyIntDB 
                then do :
                  put stream tobacco-rsrv unformatted "Артикул " buf_doc-line.artic " " buf_doc-line.prod-type string(buf_doc-line.prod-code)
                          " . Марка " tt-tobacco-marks.mark " в статусе " objSrv:Env:Marking:Sts:Mark:GetLabel(buf_marking.sts) skip .
                  undo, return error ("Марка " + tt-tobacco-marks.mark + " в статусе " + objSrv:Env:Marking:Sts:Mark:GetLabel(buf_marking.sts) ) .    
                end .
                
                find first buf_marking-lines no-lock where buf_marking-lines.mark = buf_marking.mark
                                                       and buf_marking-lines.obj-type = buf_doc-line.obj-type
                                                       and buf_marking-lines.obj-code = buf_doc-line.obj-code
                                                       and buf_marking-lines.out-code = v-rsrv-code
                                                       no-error .
                if not available buf_marking-lines
                then do :
                  put stream tobacco-rsrv unformatted "Артикул " buf_doc-line.artic " " buf_doc-line.prod-type string(buf_doc-line.prod-code)
                        " . В БД не найдена запись для марки в линии документа " tt-tobacco-marks.mark  skip .
                  undo, return error ("В БД не найдена запись для марки в линии документа " + tt-tobacco-marks.mark) .
                end.
                find first buf_goods no-lock where buf_goods.gds-code = buf_marking-lines.gds-code .
                find first buf_parts
                  where buf_parts.obj-type  = buf_marking-lines.obj-type
                    and buf_parts.obj-code  = buf_marking-lines.obj-code
                    and buf_parts.artic     = buf_goods.artic
                    and buf_parts.prod-type = buf_goods.prod-type
                    and buf_parts.prod-code = buf_goods.prod-code
                    and buf_parts.in-code   = buf_marking-lines.in-code
                    and buf_parts.out-code  = buf_marking-lines.out-code
                    and buf_parts.part-code = buf_marking-lines.part-code 
                    and buf_parts.prt-code  = buf_marking-lines.prt-code
                    and buf_parts.status_   = no
                    and buf_parts.fact-qnty > 0
                  use-index FIFO
                  no-error.
                if available buf_parts
                then v-fifo = false .
                else v-fifo = true .
              end .
              else do :
                v-fifo = true .
              end .
            end .
            
            if v-fifo = true
            then do:
              if v-alc-rsrv
              or v-mark-tobacco
              then
              do:  
                release buf_parts.
                if vIsExemplarGoods or v-isweighed then
                  { trg/fndpartfifo.i
                    "first"
                    "and not can-find(first buf_marking-lines where
                                            buf_marking-lines.in-code   = buf_parts.in-code 
                                        and buf_marking-lines.out-code  = buf_parts.out-code
                                        and buf_marking-lines.prt-code  = buf_parts.prt-code 
                                        and buf_marking-lines.part-code = buf_parts.part-code
                                        and buf_marking-lines.obj-code  = buf_parts.obj-code
                                        and buf_marking-lines.obj-type  = buf_parts.obj-type)"}
                if not avail buf_parts then
                   { trg/fndpartfifo.i "first" }
              end.
              else
              do:  
                if vIsExemplarGoods or v-isweighed then
                do:
                  release buf_parts.
                  { trg/fndpartfifo.i
                    "first"
                    "and not can-find(first buf_marking-lines where
                                            buf_marking-lines.in-code   = buf_parts.in-code 
                                        and buf_marking-lines.out-code  = buf_parts.out-code
                                        and buf_marking-lines.prt-code  = buf_parts.prt-code 
                                        and buf_marking-lines.part-code = buf_parts.part-code
                                        and buf_marking-lines.obj-code  = buf_parts.obj-code
                                        and buf_marking-lines.obj-type  = buf_parts.obj-type)"}
                  if not avail buf_parts then
                     { trg/fndpartfifo.i "first" }
                end.
                else
                do:
                  { trg/fndpartfifo.i "next" }
                end.
              end.
            end.
            else if not v-alc-rsrv and not v-mark-tobacco
            then do:
              if vIsExemplarGoods or v-isweighed then
              do:
                release buf_parts.
                { trg/fndpartfifo.i
                  "last"
                  "and not can-find(first buf_marking-lines where
                                          buf_marking-lines.in-code   = buf_parts.in-code 
                                      and buf_marking-lines.out-code  = buf_parts.out-code
                                      and buf_marking-lines.prt-code  = buf_parts.prt-code 
                                      and buf_marking-lines.part-code = buf_parts.part-code
                                      and buf_marking-lines.obj-code  = buf_parts.obj-code
                                      and buf_marking-lines.obj-type  = buf_parts.obj-type)"}
                if not avail buf_parts then
                  { trg/fndpartfifo.i "last" }
              end.
              else
              do:
                { trg/fndpartfifo.i "prev" }
              end.
            end.
          end.

          if not available buf_parts
          then do:
            if (vIsExemplarGoods or v-isweighed) and (buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Perem} or buf_trn-doc.ext-doc-type = {&TDEDT_Spi_Vnesh}) then
            do:  /* если помарочный учет и партия не найдена */
              message "Просканирована групповая упаковка, не найдено партий для списания.~nНеобходимо сканировать потребительские упаковки"
                view-as alert-box. 
              leave rsrv_cycle .  
            end.
            assign
              v-rsrv-index = v-rsrv-index + 1
            .
            if v-rsrv-index <= num-entries(v-partlist-order)
            then do:
              assign
                v-find-first = true
                v-rsrv-entry = entry(v-rsrv-index, v-partlist-order, {&comma-char})
              .
              next rsrv_cycle . /* --->>>--- */
            end.
            else do:
              /* если партия не найдена */
              /* и это последний элемент порядка резервирования */
              /* - прекратить резервирование */
              leave rsrv_cycle . /* --->>>--- */
            end.
          end.

          /* если эта партия входит в список партий */
          /* то необходимо задать количество на резервирование */
          /* равное разнице текущего зарезервированного количества */
          /* и количества заданного в списке партий */
          if v-partlist-use = true
          then do:
            define variable v-parts-rsrv-qnty  as decimal   no-undo .
            define variable v-parts-check-qnty as decimal   no-undo .

            run partlist_check-part-qnty in this-procedure
              (input  buf_parts.in-code
              ,input  buf_parts.part-code
              ,output v-parts-check-qnty
              ) .

            if v-parts-check-qnty > 0
            then do:
              assign
                v-parts-rsrv-qnty = 0
              .
              if buf_parts.out-code = buf_doc-line.doc-code
              then do:
                assign
                  v-parts-rsrv-qnty = buf_parts.qnty
                .
              end.
              else do:
                define buffer buf_rsrv_parts for ub.parts .
                find first buf_rsrv_parts
                  where buf_rsrv_parts.obj-type  = buf_doc-line.obj-type
                    and buf_rsrv_parts.obj-code  = buf_doc-line.obj-code
                    and buf_rsrv_parts.artic     = buf_doc-line.artic
                    and buf_rsrv_parts.prod-type = buf_doc-line.prod-type
                    and buf_rsrv_parts.prod-code = buf_doc-line.prod-code
                    and buf_rsrv_parts.in-code   = buf_parts.in-code
                    and buf_rsrv_parts.out-code  = buf_doc-line.doc-code
                    and buf_rsrv_parts.part-code = buf_parts.part-code
                  no-error .
                if available buf_rsrv_parts
                then do:
                  assign
                    v-parts-rsrv-qnty = buf_rsrv_parts.qnty
                  .
                end.
                if v-parts-rsrv-qnty > v-parts-check-qnty
                then do:
                  assign
                    v-iteration-chg-qnty = min(v-parts-rsrv-qnty - v-parts-check-qnty
                                              ,abs(v-iteration-chg-qnty)
                                              )
                                         * (if v-iteration-chg-qnty > 0
                                            then 1
                                            else -1
                                           )
                  .
                end.
                else do:
                  assign
                    v-iteration-chg-qnty = 0
                  .
                end.
              end.
            end.
          end.
        end.
        when 'partlist-increment':u
        then do:
          if v-find-first = true
          then do:
            assign
              v-find-first = false
            .
            run partlist_get-total-num in this-procedure
              (output v-max-part-index
              ) .
            assign
              v-part-index = 1
            .
          end.
          else do:
            assign
              v-part-index = v-part-index + 1
            .
          end.

          if v-part-index <= v-max-part-index
          then do:
            run partlist_get-part-qnty in this-procedure
              (input  v-part-index
              ,output v-partlist-in-code
              ,output v-partlist-part-code
              ,output v-partlist-rsrv-qnty
              ) no-error .
            if error-status :error
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Ошибка при получении необходимых количеств для резервирования" skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error return-value .
            end.

            find first buf_parts
              where buf_parts.obj-type  = buf_doc-line.obj-type
                and buf_parts.obj-code  = buf_doc-line.obj-code
                and buf_parts.artic     = buf_doc-line.artic
                and buf_parts.prod-type = buf_doc-line.prod-type
                and buf_parts.prod-code = buf_doc-line.prod-code
                and buf_parts.out-code  = v-rsrv-code
                and buf_parts.in-code   = v-partlist-in-code
                and buf_parts.part-code = v-partlist-part-code
                and buf_parts.status_   = no
                and buf_parts.fact-qnty > 0
              no-error .
            if not available buf_parts
            then do:
              next rsrv_cycle . /* --->>>--- */
            end.

            assign
              v-iteration-chg-qnty = min(abs(p-chg-qnty)
                                        ,abs(v-partlist-rsrv-qnty)
                                        )
                                   * (if p-chg-qnty > 0 then 1 else -1)
            .
          end.
          else do:
            assign
              v-rsrv-index = v-rsrv-index + 1
            .
            if v-rsrv-index <= num-entries(v-partlist-order)
            then do:
              assign
                v-find-first = true
                v-rsrv-entry = entry(v-rsrv-index, v-partlist-order, {&comma-char})
              .
              next rsrv_cycle . /* --->>>--- */
            end.
            else do:
              /* если партия не найдена */
              /* и это последний элемент порядка резервирования */
              /* - прекратить резервирование */
              leave rsrv_cycle . /* --->>>--- */
            end.
          end.
        end.
        when 'partlist-decrement':u
        then do:
          if v-find-first = true
          then do:
            assign
              v-find-first = false
            .
            run partlist_get-total-num in this-procedure
              (output v-max-part-index
              ) .
            assign
              v-part-index = v-max-part-index
            .
          end.
          else do:
            assign
              v-part-index = v-part-index - 1
            .
          end.

          if v-part-index >= 1
          then do:
            run partlist_get-part-qnty in this-procedure
              (input  v-part-index
              ,output v-partlist-in-code
              ,output v-partlist-part-code
              ,output v-partlist-rsrv-qnty
              ) no-error .
            if error-status :error
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Ошибка при получении необходимых количеств для резервирования" skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error return-value .
            end.

            find first buf_parts
              where buf_parts.obj-type  = buf_doc-line.obj-type
                and buf_parts.obj-code  = buf_doc-line.obj-code
                and buf_parts.artic     = buf_doc-line.artic
                and buf_parts.prod-type = buf_doc-line.prod-type
                and buf_parts.prod-code = buf_doc-line.prod-code
                and buf_parts.out-code  = v-rsrv-code
                and buf_parts.in-code   = v-partlist-in-code
                and buf_parts.part-code = v-partlist-part-code
                and buf_parts.status_   = no
                and buf_parts.fact-qnty > 0
              no-error .
            if not available buf_parts
            then do:
              next rsrv_cycle . /* --->>>--- */
            end.

            assign
              v-iteration-chg-qnty = min(abs(p-chg-qnty)
                                        ,abs(v-partlist-rsrv-qnty)
                                        )
                                   * (if p-chg-qnty > 0 then 1 else -1)
            .
          end.
          else do:
            assign
              v-rsrv-index = v-rsrv-index + 1
            .
            if v-rsrv-index <= num-entries(v-partlist-order)
            then do:
              assign
                v-find-first = true
                v-rsrv-entry = entry(v-rsrv-index, v-partlist-order, {&comma-char})
              .
              next rsrv_cycle . /* --->>>--- */
            end.
            else do:
              /* если партия не найдена */
              /* и это последний элемент порядка резервирования */
              /* - прекратить резервирование */
              leave rsrv_cycle . /* --->>>--- */
            end.
          end.
        end.
        otherwise do:
          message
            vss-workfile vss-revision vss-description skip
            "Внутренняя ошибка" skip
            "Неизвестное значение переменной" v-rsrv-entry skip
            view-as alert-box error .
        end.
      end.

      assign
        v-check-part-qnty = p-chg-qnty
                          * ( if lookup(buf_trn-doc.doc-type, {&expense_write-off} ) > 0
                              then -1
                              else 1
                            )
      .

      /* определяем необходимость резервирования партии */
      { gbl/part-prc.i
        buf_parts
        buf_trn-doc
        p-reserv-single-part
        p-in-code
        p-part-code
        p-pl-code
        p-goods-twounit
        p-purch-code-list
        v-check-part-qnty
        "true"
        v-reason
        v-process-part
        no-error
      }
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении возможности резервирования партии" skip
          "Документ" buf_doc-line.doc-code skip
          "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      if v-process-part = true
      then do:
        /*  
        if v-mark-alchol and available buf_gen-attr
        then do :
            find current buf_gen-attr exclusive-lock no-error.
            if available buf_gen-attr then buf_gen-attr.whole-send-news = (if v-rsrv-code = {&free-code} then 1 else 0) .
            if v-rsrv-code <> {&free-code} and available buf_gen-attr
            then do :
                v-part-key = buf_gen-attr.p-key .
                entry(8, v-part-key, {&delim-key}) = {&free-code} .
                find first buf2_gen-attr exclusive-lock where buf2_gen-attr.table-name = {&excise-mark}
                                                          and buf2_gen-attr.p-key = v-part-key
                                                          and buf2_gen-attr.attr-code = buf_gen-attr.attr-code
                                                          no-error .
                if available buf2_gen-attr
                then do :
                    buf2_gen-attr.whole-send-news = 0 .
                    release buf2_gen-attr .
                end.
            end.
        end.  
        */
        /* Резервирование или снятие резервов */
        run partrsrv in this-procedure
          (input  v-iteration-chg-qnty /* p-chg-qnty      */
                    * ( if lookup(buf_trn-doc.doc-type, {&expense_write-off} ) > 0
                        then -1
                        else 1
                      )
          ,input  p-goods-serial  /* p-goods-serial  */
          ,input  p-goods-twounit /* p-goods-twounit */
          ,input  false           /* p-unreserv-only */
          ,buffer buf_parts       /* buf_orig_parts  */
          ,buffer buf_trn-doc     /* buf_trn-doc     */
          ,output v-real-chg-qnty /* p-real-chg-qnty */
          ,output v-parts-recid   /* p-parts-recid   */
          ,input (if available tt-marks then tt-marks.mark else if available buf_marking then buf_marking.mark else if available tt-tobacco-marks then tt-tobacco-marks.mark else p-mark)
          ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при вызове partrsrv" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          return return-value .
        end.

        assign
          p-chg-qnty      = p-chg-qnty      - abs(v-real-chg-qnty) * v-chg-qnty-sign
          p-real-chg-qnty = p-real-chg-qnty + abs(v-real-chg-qnty) * v-chg-qnty-sign
        .
        
        
      end.
    end.
    
    output stream alc-rsrv close .
    output stream tobacco-rsrv close .

    if p-chg-qnty = 0
    then do:
      return . /* --->>>--- */
    end.

    if v-chg-qnty-sign < 0
    then do:
      /* это было уменьшение резервов */
      if p-chg-qnty <> 0
      then do:
  /*      message*/
  /*        vss-workfile vss-revision vss-description skip*/
  /*        "Документ" buf_doc-line.doc-code skip*/
  /*        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip*/
  /*        "Нельзя списать" p-chg-qnty skip*/
  /*        view-as alert-box.*/
  /*      undo, return error return-value .*/
      end.
    end.

    /* создание порожденной партии */
    if  p-chg-qnty <> 0
    and p-reserv-single-part = false
    and p-purch-code-list    = '':u
    then do:
      if v-izlcstpr and buf_trn-doc.ext-doc-type = {&TDEDT_Inv} and p-action <> {&rsrv-dtl_action_reserv-sozdanie}
      then do :
          p-partscr-prompt-price  = p-partscr-prompt-price + ",izlcstpr=enable" .
          find first buf_goods no-lock where buf_goods.artic      = buf_doc-line.artic
                                         and buf_goods.prod-type  = buf_doc-line.prod-type
                                         and buf_goods.prod-code  = buf_doc-line.prod-code .
          { gbl/gdsbcode.i buf_goods.gds-code ? varb-code }
          { gbl/bcprcex.i buf_doc-line.obj-type buf_doc-line.obj-code varb-code 0 0 vardoc-num varprice-sale varroad-tax varexcise varcur-vat-pc varcur-slt-pc }  
          if varprice-sale = ?
          then do:
              assign
                varprice-sale = 0
                varcur-vat-pc = 0
                varcur-slt-pc = 0
              .
          end.
          
          { gbl/pftxvalg.i
            buf_goods.gds-code
            {&vat-tax-code}
            buf_trn-doc.doc-date
            buf_trn-doc.host-code
            buf_trn-doc.obj-type
            buf_trn-doc.obj-code
            varcur-vat-pc
            no-error
          }
            
          varprice-rubl = varprice-sale / (1 + (varcur-vat-pc / 100)) .
          
          if varprice-rubl = 0
          then do :
            if varcur-vat-pc <> 0 and varcur-vat-pc <> ?
            then 
              varprice-rubl = buf_doc-line.price-rubl / (1 + (varcur-vat-pc / 100)) .
            else
              varprice-rubl = buf_doc-line.price-rubl / (1 + (buf_doc-line.vat-pc / 100)) .
          end.
    
              { gbl/baserate.i
                buf_trn-doc.host-code
                today
                v-exch-rate
                v-exch-scale
                no-error
              }
          varprice-base = varprice-rubl / v-exch-rate * v-exch-scale .
          
          if varprice-rubl <> 0 and varprice-rubl <> ? then p-reserv-rubl = varprice-rubl .
          if varprice-base <> 0 and varprice-base <> ? then p-reserv-base = varprice-base .
      end.
      run rsrv-negative in this-procedure
        (input  parparentproc
        ,input  p-db-num
        ,input  p-user-id
        ,buffer buf_doc-line            /* buf_doc-line           */
        ,buffer buf_trn-doc             /* buf_trn-doc            */
        ,input  p-chg-qnty              /* p-chg-qnty             */
        ,input  p-reserv-base           /* p-reserv-base          */
        ,input  p-reserv-rubl           /* p-reserv-rubl          */
        ,input  p-partscr-prompt-price  /* p-partscr-prompt-price */
        ,output v-real-chg-qnty         /* p-real-rsrv-qnty       */
        ) no-error .
      if error-status :error
      then do:
        if error-status :get-message(1) <> '':U
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при вызове процедуры rsrv-negative" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
        end.
        undo, return error return-value .
      end.
      assign
        p-chg-qnty      = p-chg-qnty      - abs(v-real-chg-qnty) * v-chg-qnty-sign
        p-real-chg-qnty = p-real-chg-qnty + abs(v-real-chg-qnty) * v-chg-qnty-sign
      .
      if  v-real-chg-qnty <> p-chg-qnty
      and return-value <> '':U
      then do:
        return return-value .
      end.
    end.
  end.
  
  return .

end procedure.



procedure rsrv-negative :
  define input parameter  parparentproc         AS WIDGET-HANDLE NO-UNDO.
  define input  parameter p-db-num               as integer   no-undo .
  define input  parameter p-user-id              as character no-undo .
  define parameter buffer buf_doc-line           for ub.doc-line .
  define parameter buffer buf_trn-doc            for ub.trn-doc  .
  define input parameter  p-chg-qnty             as decimal   no-undo .
  define input parameter  p-reserv-base          as decimal   no-undo .
  define input parameter  p-reserv-rubl          as decimal   no-undo .
  define input parameter  p-partscr-prompt-price as character no-undo .
  define output parameter p-real-rsrv-qnty       as decimal   no-undo .

  define buffer buf_parts for ub.parts .
  define buffer buf_goods for ub.goods .

  define variable v-vat-type  as character no-undo .
  define variable v-vat-pc    as decimal   no-undo .
  define variable v-slt-type  as character no-undo .
  define variable v-slt-pc    as decimal   no-undo .
  define variable v-is-hold-doc as logical no-undo .

  do
  on error undo, return error return-value
  :
    find first buf_goods no-lock where buf_goods.artic      = buf_doc-line.artic
                                   and buf_goods.prod-type  = buf_doc-line.prod-type
                                   and buf_goods.prod-code  = buf_doc-line.prod-code
                                   .
    if is-gas(buf_goods.gds-code) then return .
                                   
    run partscr_get-default-values in this-procedure
      (buffer buf_doc-line /* buf_doc-line */
      ,output v-vat-type   /* p-vat-type   */
      ,output v-vat-pc     /* p-vat-pc     */
      ,output v-slt-type   /* p-slt-type   */
      ,output v-slt-pc     /* p-slt-pc     */
      ) .
   
    if lookup('izlcstpr=enable':u, p-partscr-prompt-price) > 0 and p-action <> {&rsrv-dtl_action_reserv-sozdanie} 
    and buf_trn-doc.ext-doc-type = {&TDEDT_Inv}
    then do :
        v-vat-pc = 0 .
        v-vat-type = {&without-VAT} .
    end.

    run partscr in this-procedure
      (input  parparentproc
      ,input  p-db-num
      ,input  p-user-id
      ,input  { trg/partsprm.i "supp-type" "buf_trn-doc." } /* p-supp-type        */
      ,input  { trg/partsprm.i "supp-code" "buf_trn-doc." } /* p-supp-code        */
      ,input  '':U                   /* p-part-code        */
      ,input  '':U                   /* p-cst-code         */
      ,input  '':U                   /* p-ps               */
      ,input  '':U                   /* p-dop               */
      ,input  p-reserv-base          /* v-part-reserv-base */
      ,input  p-reserv-rubl          /* v-part-reserv-rubl */
      ,input  v-vat-type             /* p-vat-type         */
      ,input  v-vat-pc               /* p-vat-pc           */
      ,input  v-slt-type             /* p-slt-type         */
      ,input  v-slt-pc               /* p-slt-pc           */
      ,input  p-chg-qnty             /* chg-qnty           */
      ,input  p-partscr-prompt-price /* p-prompt-price     */
      ,input  0                      /* p-cli-qnty         */
      ,input  ?                      /* p-last-date        */
      ,input  ?                      /* p-hold-date        */
      ,input  0                      /* складское место    */
      ,buffer buf_doc-line           /* buf_doc-line       */
      ,buffer buf_parts              /* buf_parts          */
      ) no-error .
    if error-status :error
    then do:
      if error-status :get-message(1) <> '':U
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при создании партии" skip
          "Документ" buf_doc-line.doc-code skip
          "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
      end.
      undo, return error return-value .
    end.

    if not available buf_parts
    and return-value <> '':U
    then do:
      return return-value .
    end.

    { gbl/hold-doc.i buf_trn-doc.doc-code v-is-hold-doc }
    if v-is-hold-doc
    and buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh}
    then do:
      assign
        buf_parts.contract-code = 0
      .
    end.

    assign
      p-real-rsrv-qnty = p-chg-qnty
    .
  end.

end procedure.


procedure unrsrv-negative :

  define parameter buffer buf_doc-line for ub.doc-line .
  define input  parameter p-chg-qnty      as decimal no-undo .
  define output parameter p-real-chg-qnty as decimal no-undo .

  define variable v-part-chg-qnty as decimal no-undo .

  define buffer buf_parts for ub.parts .

  do
  on error undo, return error return-value
  :
    /* снимаем резерв по всем порожденным партиям */
    for each buf_parts
      where buf_parts.in-code   = buf_doc-line.doc-code
        and buf_parts.out-code  = buf_doc-line.doc-code
        and buf_parts.obj-code  = buf_doc-line.obj-code
        and buf_parts.obj-type  = buf_doc-line.obj-type
        and buf_parts.artic     = buf_doc-line.artic
        and buf_parts.prod-type = buf_doc-line.prod-type
        and buf_parts.prod-code = buf_doc-line.prod-code
    on error undo, return error return-value
    :

      assign
        v-part-chg-qnty = 0
      .
      if buf_parts.fact-qnty > 0
      and p-chg-qnty < 0
      then do:
        assign
          v-part-chg-qnty = - min(abs(buf_parts.qnty), abs(p-chg-qnty))
        .
      end.

      if buf_parts.fact-qnty < 0
      and p-chg-qnty > 0
      then do:
        assign
          v-part-chg-qnty = min(abs(buf_parts.qnty), abs(p-chg-qnty))
        .
      end.
      if v-part-chg-qnty = 0
      then do:
        next .
      end.

      if p-chg-qnty = 0
      then do:
        return .
      end.

      assign
        p-chg-qnty          = p-chg-qnty          - v-part-chg-qnty
        p-real-chg-qnty     = p-real-chg-qnty     + v-part-chg-qnty
        buf_parts.qnty      = buf_parts.qnty      + v-part-chg-qnty
        buf_parts.fact-qnty = buf_parts.fact-qnty + v-part-chg-qnty
      .
    end.
  end.

end procedure.

/*Процедура извличения алкокода из акцизной марки и перевод в 10 систему*/
PROCEDURE ProcAlcCode :
  define input  parameter p-mark-alc as character  no-undo .
  define output parameter p-alc-code as character  no-undo initial ''.
  define variable v-kol              as integer    no-undo .
  define variable alc-code as character no-undo .
  define variable v-result as character no-undo .
  define variable ii as integer no-undo .  

  if length(p-mark-alc) = 150 then 
  do:
    p-alc-code = "new-mark" .
    return .
  end.
  else 
  do:  
    alc-code = SUBSTRing (p-mark-alc, 8, 12) .
  end.
  
  p-alc-code = string (Base2Int64 (alc-code, 36) ) no-error.
  if (Base2Int64 (alc-code, 36) ) < 0 then 
  do:
    p-alc-code = ?.
  end.
  else 
  do:
    if length(p-alc-code) < 20 then 
    do:
      p-alc-code = fill('0', 19 - length(p-alc-code)) + p-alc-code.
    end.  
  end.
  
    
END PROCEDURE.

/* $Workfile$   E n d */