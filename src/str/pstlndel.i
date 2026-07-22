/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Инклюд - удаление линий пересортицы (не помещается в UIB)

Автор: Чернова Светлана Александровна
Дата создания: 03/24/06
Author: Svetlana Chernova
Creation date: 03/24/06

Автор1: Суслов Алексей Юрьевич
Дата создания: 05/18/06

*/
define output parameter parrep-rec as recid no-undo.
define variable vartemp-rec as recid no-undo.

define buffer bf-del_parts             for ub.parts.
define buffer bf-del_doc-line          for ub.doc-line.
define buffer bf-del_goods             for ub.goods.
define buffer bf-del_gds-prt           for ub.gds-prt.
define buffer bf-del_gds-dtl           for ub.gds-dtl.
define buffer bf-del_parts-root        for ub.parts-root.

define buffer bf-del-plus_parts        for ub.parts.
define buffer bf-del-plus_doc-line     for ub.doc-line.
define buffer bf-del-plus_goods        for ub.goods.
define buffer bf-del-plus_gds-prt      for ub.gds-prt.

define buffer bf-del-check_parts       for ub.parts.
define buffer bf-del-check-plus_parts  for ub.parts.

define buffer bf-del_doc-pl            for ub.doc-pl.
define buffer bf-del-plus_doc-pl       for ub.doc-pl.

define variable vardel-one-sheaf          as logical initial no no-undo.
define variable varrecdoc-line            as recid              no-undo.
define variable varrecdoc-line-plus       as recid              no-undo.
define variable vargoods-num              as integer            no-undo.
define variable varrsrv-qnty              as decimal            no-undo.
define variable varmem-qnty               as decimal            no-undo.
define variable varchg-qnty               as decimal            no-undo.
define variable vargoods-plus             as integer            no-undo.
define variable varnum                    as integer            no-undo.
define variable varlog                    as logical            no-undo.
define variable varrsrv-plus-parts-real   as decimal            no-undo.
define variable varrsrv-plus-parts        as decimal            no-undo.
define variable varrsrv-plus-qnty         as decimal            no-undo.
define variable varis-petrol              as logical            no-undo.
define variable varis-pieces              as logical            no-undo.
define variable varis-petrol-plus         as logical            no-undo.
define variable varis-pieces-plus         as logical            no-undo.
define variable vardensity-doc-pl         as decimal            no-undo.
define variable varone-line               as logical            no-undo.
do on error undo, return error return-value :
for each tt-recalc-line on error undo, return error return-value :
  delete tt-recalc-line.
end.
find first tt-del-list no-error.
if not available tt-del-list then do:
  /* удаление 1 строки */
  if not available bf_doc-line then do:
    return error "Неправильный выбор строки списанного товара.".
  end.
  find first bf-del_doc-line where recid(bf-del_doc-line) = recid(bf_doc-line) exclusive-lock.
  find first bf-del_goods where bf-del_goods.artic     = bf-del_doc-line.artic     and
                                bf-del_goods.prod-type = bf-del_doc-line.prod-type and
                                bf-del_goods.prod-code = bf-del_doc-line.prod-code no-lock.

  assign
    vargoods-plus = 0.
  for each bf-del_parts-root where bf-del_parts-root.doc-code       = bf_trn-doc.doc-code   and
                                   bf-del_parts-root.orig-gds-code  = bf-del_goods.gds-code
                                   use-index pi break by bf-del_parts-root.gds-code on error undo, return error return-value :
    if first-of(bf-del_parts-root.gds-code) then do:
      assign
        vargoods-plus = vargoods-plus + 1.
    end.
  end.
  if vargoods-plus > 1 then do:
    if not available bf-plus_doc-line then do:
      return error "Неправильный выбор строки оприходованного товара.".
    end.
    find first bf-del-plus_doc-line where recid(bf-del-plus_doc-line) = recid(bf-plus_doc-line) exclusive-lock.
    find first bf-del-plus_goods where bf-del-plus_goods.artic     = bf-del-plus_doc-line.artic     and
                                       bf-del-plus_goods.prod-type = bf-del-plus_doc-line.prod-type and
                                       bf-del-plus_goods.prod-code = bf-del-plus_doc-line.prod-code no-lock.
    assign
      varone-line = yes.
    { str/is-petrl.i
      bf-del_goods.artic
      bf-del_goods.prod-type
      bf-del_goods.prod-code
      varis-petrol
      varis-pieces
    }
    { str/is-petrl.i
      bf-del-plus_goods.artic
      bf-del-plus_goods.prod-type
      bf-del-plus_goods.prod-code
      varis-petrol-plus
      varis-pieces-plus
    }
    if varis-petrol     and
       not varis-pieces then do:
      assign
        varone-line = no.
    end.
    if varis-petrol-plus and
       not varis-pieces-plus then do:
      assign
        varone-line = no.
    end.

    find first bf-del_gds-prt where bf-del_gds-prt.upper-code = bf-del_goods.prt-root no-lock.
    if bf-del_gds-prt.node-name <> {&empty-scale} then do:
      assign
        varone-line = no.
    end.
    find first bf-del-plus_gds-prt where bf-del-plus_gds-prt.upper-code = bf-del-plus_goods.prt-root no-lock.
    if bf-del-plus_gds-prt.node-name <> {&empty-scale} then do:
      assign
        varone-line = no.
    end.
    if varone-line = yes then do:
      run gbl/d-askw.w
        (input "Удаление в документе пересортицы"
        ,input "Товар для списания "                         +
               bf-del_goods.artic                            + " " +
               bf-del_goods.prod-type                        + " " +
               string(bf-del_goods.prod-code)                + " " +
               substring(bf-del_goods.gds-name, 1, 30)       +
               "Спозиционированный товар для оприходования " +
               bf-del-plus_goods.artic                       + " " +
               bf-del-plus_goods.prod-type                   + " " +
               string(bf-del-plus_goods.prod-code)           + " " +
               substring(bf-del-plus_goods.gds-name, 1, 30)
        ,input "|^" /* Символы разделители для кодирования двух следующих параметров */
        ,input "Все|Только спозиц.|Отменить" /* список названий кнопок  */
        ,input "Всем товарам для оприходования|" /* список описаний кнопок */
             + "Только спозиционированному товару|"
             + "Отменить удаление"
        ,input 1 /* значение возвращаемое при нажатии enter */
        ,input 3 /* значение возвращаемое при нажатии escape */
        ,output varnum /* выбор пользователя */
        ).
      case varnum:
        when 1 then do:
          assign
            vartemp-rec =  recid (bf-del_doc-line).
          create tt-del-list.
          assign
            tt-del-list.rec-id = recid (bf-del_doc-line).
        end.
        when 2 then do:
          assign
            vardel-one-sheaf    = yes
            varrecdoc-line      = recid (bf-del_doc-line)
            varrecdoc-line-plus = recid (bf-del-plus_doc-line)
          .
        end.
        when 3 then do:
          return error.
        end.
      end case.
    end.
    else do:
      assign
        varlog = no.
      message "Удалить строку из документа? Вы уверены?"
              view-as alert-box question buttons ok-cancel update varlog.
      if not varlog then return error.
      assign
        vartemp-rec =  recid (bf-del_doc-line).
      create tt-del-list.
      assign
        tt-del-list.rec-id = recid (bf-del_doc-line).
    end.
  end.
  else do:
    assign
      varlog = no.
    message "Удалить строку из документа? Вы уверены?"
            view-as alert-box question buttons ok-cancel update varlog.
    if not varlog then return error.
    assign
      vartemp-rec =  recid (bf-del_doc-line).
    create tt-del-list.
    assign
      tt-del-list.rec-id = recid (bf-del_doc-line).
  end.
  get next b-goods-.
  if available bf_doc-line then do:
    assign
      parrep-rec = recid (bf_doc-line).
  end.
  else do:
    reposition b-goods- to recid vartemp-rec no-error.
    get prev b-goods-.
    assign
      parrep-rec = recid (bf_doc-line).
  end.
end.
else do:
  /* удаление отмеченных строк */
  assign
    varlog = no.
  message "УДАЛИТЬ ВСЕ ОТМЕЧЕННЫЕ строки документа? Вы уверены ?"
  view-as alert-box question buttons ok-cancel update varlog.
  if not varlog then do:
    return error.
  end.
  assign
    parrep-rec = ?.
end.
if vardel-one-sheaf <> yes then do:
  for each tt-del-list on error undo, return error return-value :
    find first bf-del_doc-line where recid (bf-del_doc-line) = tt-del-list.rec-id exclusive-lock no-error.
    if not available bf-del_doc-line then do:
      undo, return error "Ошибка при удалении линии. Не найдена линия для удаления.".
    end.
    find first bf-del_goods where bf-del_goods.artic     = bf-del_doc-line.artic     and
                                  bf-del_goods.prod-type = bf-del_doc-line.prod-type and
                                  bf-del_goods.prod-code = bf-del_doc-line.prod-code no-lock.

    run local-recalc in this-procedure (input "old":u,
                                        input recid(bf-del_doc-line),
                                        input yes) no-error.
    if error-status:error then do:
      undo, return error substitute ("Ошибка при пересчете строки документа: &1.", return-value).
    end.
    /*сначала разрезервируем партии*/
    assign
      varrsrv-qnty = 0.00.
    for each bf-del_parts where bf-del_parts.out-code  = bf_trn-doc.doc-code       and
                                bf-del_parts.obj-type  = bf_trn-doc.obj-type       and
                                bf-del_parts.obj-code  = bf_trn-doc.obj-code       and
                                bf-del_parts.artic     = bf-del_doc-line.artic     and
                                bf-del_parts.prod-type = bf-del_doc-line.prod-type and
                                bf-del_parts.prod-code = bf-del_doc-line.prod-code and
                                bf-del_parts.fact-qnty < 0                         exclusive-lock on error undo, return error return-value :
      if varis-petrol     and
         not varis-pieces then do:
        find first bf-del_doc-pl where bf-del_doc-pl.obj-type  = bf-del_doc-line.obj-type and
                                       bf-del_doc-pl.obj-code  = bf-del_doc-line.obj-code and
                                       bf-del_doc-pl.pl-code   = bf-del_parts.pl-code     and
                                       bf-del_doc-pl.out-code  = bf-del_doc-line.doc-code and
                                       bf-del_doc-pl.gds-code  = bf-del_goods.gds-code    exclusive-lock.
        assign
          vardensity-doc-pl = bf-del_doc-pl.cli-fact-qnty / bf-del_doc-pl.fact-qnty.
      end.
      assign
        varmem-qnty = - bf-del_parts.fact-qnty
        varchg-qnty = varmem-qnty.
      find first bf-del_gds-dtl where bf-del_gds-dtl.doc-code  = bf_trn-doc.doc-code    and
                                      bf-del_gds-dtl.artic     = bf-del_parts.artic     and
                                      bf-del_gds-dtl.prod-type = bf-del_parts.prod-type and
                                      bf-del_gds-dtl.prod-code = bf-del_parts.prod-code .
      run trg/rsrv-dtl.p (input parparentproc,
                      {&rsrv-dtl_action_reserv} + ',' + {&rsrv-dtl_negative-check} + "=2"
                      + "," + {&rsrv-dtl_rsrv-single-part}
                      + "," + {&rsrv-dtl_rsrv-in-code}   + "=" + str-encode(bf-del_parts.in-code,   "":u, ",=":u)
                      + "," + {&rsrv-dtl_rsrv-part-code} + "=" + str-encode(bf-del_parts.part-code, "":u, ",=":u)
                      ,
                      buffer bf-del_gds-dtl,
                      input-output varchg-qnty,
                      input-output bf-del_doc-line.price-base,
                      input-output bf-del_doc-line.price-rubl,
                      -1, "") no-error.
      if error-status:error then do:
        undo, return error substitute ("Ошибка при снятии резервировов по списанному товару &1 &2 &3 &4: &5.", bf-del_goods.artic, bf-del_goods.prod-type, bf-del_goods.prod-code, bf-del_goods.gds-name, return-value).
      end.
      if varmem-qnty <> varchg-qnty then do:
        undo, return error substitute("Не все резервы были сняты по списанному товару: &1 &2 &3 &4. Количество для снятия резерва: &5. Снято резервов: &6.", bf-del_goods.artic, bf-del_goods.prod-type, bf-del_goods.prod-code, bf-del_goods.gds-name, varmem-qnty, varchg-qnty).
      end.
      assign
        varrsrv-qnty               = varrsrv-qnty              + varchg-qnty
        bf-del_doc-line.fact-qnty  = bf-del_doc-line.fact-qnty + varchg-qnty
      .
      if varis-petrol     and
         not varis-pieces then do:
        assign
          bf-del_doc-pl.doc-qnty      = bf-del_doc-pl.doc-qnty + varchg-qnty
          bf-del_doc-pl.fact-qnty     = bf-del_doc-pl.doc-qnty
          bf-del_doc-pl.cli-qnty      = bf-del_doc-pl.doc-qnty * vardensity-doc-pl
          bf-del_doc-pl.cli-doc-qnty  = bf-del_doc-pl.cli-qnty
          bf-del_doc-pl.cli-fact-qnty = bf-del_doc-pl.cli-doc-qnty
        .
        assign
          bf-del_doc-line.cli-qnty = bf-del_doc-line.cli-qnty + varchg-qnty * vardensity-doc-pl.
      end.
      find first tt-recalc-line where tt-recalc-line.doc-code  = bf-del_doc-line.doc-code  and
                                      tt-recalc-line.artic     = bf-del_doc-line.artic     and
                                      tt-recalc-line.prod-type = bf-del_doc-line.prod-type and
                                      tt-recalc-line.prod-code = bf-del_doc-line.prod-code no-error.
      if not available tt-recalc-line then do:
        create tt-recalc-line.
        buffer-copy bf-del_doc-line to tt-recalc-line.
      end.
    end.

    find first bf-del-check_parts where bf-del-check_parts.out-code  = bf-del_doc-line.doc-code  and
                                        bf-del-check_parts.obj-type  = bf-del_doc-line.obj-type  and
                                        bf-del-check_parts.obj-code  = bf-del_doc-line.obj-code  and
                                        bf-del-check_parts.artic     = bf-del_doc-line.artic     and
                                        bf-del-check_parts.prod-type = bf-del_doc-line.prod-type and
                                        bf-del-check_parts.prod-code = bf-del_doc-line.prod-code no-error.
    run rsrv-gds-dtl in this-procedure (input bf-del_doc-line.doc-code,
                                        input bf-del_doc-line.artic,
                                        input bf-del_doc-line.prod-type,
                                        input bf-del_doc-line.prod-code,
                                        input (if available bf-del-check_parts then yes else no),
                                        input varrsrv-qnty) no-error.
    if error-status:error then do:
      return error return-value.
    end.
    if bf-del_doc-line.fact-qnty = 0    and
       not available bf-del-check_parts then do:
      run local-recalc in this-procedure (input "delete":u,
                                          input recid(bf-del_doc-line),
                                          input yes) no-error.
      if error-status:error then do:
        undo, return error substitute ("Ошибка при пересчете строки документа. Списываемый товар: &1 &2 &3.", bf-del_doc-line.artic, bf-del_doc-line.prod-type, bf-del_doc-line.prod-code).
      end.
      run local-line-delete in this-procedure (input recid(bf-del_doc-line)) no-error.
      if error-status:error then do:
        undo, return error substitute ("Ошибка при удалении строки документа. Списываемый товар: &1 &2 &3.", bf-del_doc-line.artic, bf-del_doc-line.prod-type, bf-del_doc-line.prod-code).
      end.
    end.
    else do:
      run local-recalc in this-procedure (input "update":u,
                                          input recid(bf-del_doc-line),
                                          input yes) no-error.
      if error-status:error then do:
        undo, return error substitute ("Ошибка при пересчете строки документа по списанным товарам: &1", return-value).
      end.
     /*Зачистим нулевые признаки*/
     find first bf-del_gds-dtl where bf-del_gds-dtl.doc-code  = bf-del_doc-line.doc-code  and
                                     bf-del_gds-dtl.artic     = bf-del_doc-line.artic     and
                                     bf-del_gds-dtl.prod-type = bf-del_doc-line.prod-type and
                                     bf-del_gds-dtl.prod-code = bf-del_doc-line.prod-code and
                                     bf-del_gds-dtl.doc-qnty <> 0                              no-error.
     if available bf-del_gds-dtl then do:
       for each bf-del_gds-dtl where bf-del_gds-dtl.doc-code  = bf-del-plus_doc-line.doc-code  and
                                     bf-del_gds-dtl.artic     = bf-del-plus_doc-line.artic     and
                                     bf-del_gds-dtl.prod-type = bf-del-plus_doc-line.prod-type and
                                     bf-del_gds-dtl.prod-code = bf-del-plus_doc-line.prod-code and
                                     bf-del_gds-dtl.doc-qnty  = 0                              on error undo, return error return-value :
         delete bf-del_gds-dtl.
        end.
      end.
    end.

    assign
      varrsrv-plus-parts-real = 0.00
      varrsrv-plus-parts      = 0.00.

    /*Проведем разрезервирование по оприходованным товарам, связанных с данным списанным*/
    for each bf-del_parts-root where bf-del_parts-root.doc-code      = bf_trn-doc.doc-code   and
                                     bf-del_parts-root.orig-gds-code = bf-del_goods.gds-code use-index pi on error undo, return error return-value :
      find first bf-del-plus_goods where bf-del-plus_goods.gds-code = bf-del_parts-root.gds-code no-lock.
      find first bf-del-plus_doc-line where bf-del-plus_doc-line.doc-code  = bf_trn-doc.doc-code         and
                                            bf-del-plus_doc-line.artic     = bf-del-plus_goods.artic     and
                                            bf-del-plus_doc-line.prod-type = bf-del-plus_goods.prod-type and
                                            bf-del-plus_doc-line.prod-code = bf-del-plus_goods.prod-code exclusive-lock.
      run local-recalc in this-procedure (input "old":u,
                                          input recid(bf-del-plus_doc-line),
                                          input no) no-error.
      if error-status:error then do:
        undo, return error substitute ("Ошибка при пересчете строки документа по оприходованным товарам: &1", return-value).
      end.
      find first tt-recalc-line where tt-recalc-line.doc-code  = bf-del-plus_doc-line.doc-code  and
                                      tt-recalc-line.artic     = bf-del-plus_doc-line.artic     and
                                      tt-recalc-line.prod-type = bf-del-plus_doc-line.prod-type and
                                      tt-recalc-line.prod-code = bf-del-plus_doc-line.prod-code no-error.
      if not available tt-recalc-line then do:
        create tt-recalc-line.
        buffer-copy bf-del-plus_doc-line to tt-recalc-line.
      end.

      find first bf-del-plus_parts where bf-del-plus_parts.obj-type  = bf_trn-doc.obj-type         and
                                         bf-del-plus_parts.obj-code  = bf_trn-doc.obj-code         and
                                         bf-del-plus_parts.artic     = bf-del-plus_goods.artic     and
                                         bf-del-plus_parts.prod-type = bf-del-plus_goods.prod-type and
                                         bf-del-plus_parts.prod-code = bf-del-plus_goods.prod-code and
                                         bf-del-plus_parts.in-code   = bf-del_parts-root.in-code   and
                                         bf-del-plus_parts.out-code  = bf-del_parts-root.doc-code  and
                                         bf-del-plus_parts.part-code = bf-del_parts-root.part-code exclusive-lock.
      assign
        varrsrv-plus-parts-real = varrsrv-plus-parts-real + bf-del-plus_parts.real-qnty.
      assign
        varrsrv-plus-qnty = bf-del-plus_parts.fact-qnty.
      assign
        bf-del-plus_doc-line.fact-qnty  = bf-del-plus_doc-line.fact-qnty - bf-del-plus_parts.fact-qnty.
      if varis-petrol-plus and
         not varis-pieces  then do:
        find first bf-del-plus_doc-pl where bf-del-plus_doc-pl.obj-type  = bf-del-plus_doc-line.obj-type and
                                            bf-del-plus_doc-pl.obj-code  = bf-del-plus_doc-line.obj-code and
                                            bf-del-plus_doc-pl.pl-code   = bf-del-plus_parts.pl-code     and
                                            bf-del-plus_doc-pl.out-code  = bf-del-plus_doc-line.doc-code and
                                            bf-del-plus_doc-pl.gds-code  = bf-del-plus_goods.gds-code    exclusive-lock.
        assign
          vardensity-doc-pl = bf-del-plus_doc-pl.cli-fact-qnty / bf-del-plus_doc-pl.fact-qnty.
        assign
          bf-del-plus_doc-pl.doc-qnty      = bf-del-plus_doc-pl.doc-qnty - bf-del-plus_parts.fact-qnty
          bf-del-plus_doc-pl.fact-qnty     = bf-del-plus_doc-pl.doc-qnty
          bf-del-plus_doc-pl.cli-qnty      = bf-del-plus_doc-pl.doc-qnty * vardensity-doc-pl
          bf-del-plus_doc-pl.cli-doc-qnty  = bf-del-plus_doc-pl.cli-qnty
          bf-del-plus_doc-pl.cli-fact-qnty = bf-del-plus_doc-pl.cli-qnty
          bf-del-plus_doc-line.cli-qnty    = bf-del-plus_doc-line.cli-qnty - bf-del-plus_parts.fact-qnty * vardensity-doc-pl.
      end.
      delete bf-del-plus_parts.
      delete bf-del_parts-root.

     find first bf-del-check-plus_parts where bf-del-check-plus_parts.out-code  = bf-del-plus_doc-line.doc-code  and
                                              bf-del-check-plus_parts.obj-type  = bf-del-plus_doc-line.obj-type  and
                                              bf-del-check-plus_parts.obj-code  = bf-del-plus_doc-line.obj-code  and
                                              bf-del-check-plus_parts.artic     = bf-del-plus_doc-line.artic     and
                                              bf-del-check-plus_parts.prod-type = bf-del-plus_doc-line.prod-type and
                                              bf-del-check-plus_parts.prod-code = bf-del-plus_doc-line.prod-code no-error.
      run rsrv-gds-dtl-plus in this-procedure (input bf-del-plus_doc-line.doc-code,
                                               input bf-del-plus_doc-line.artic,
                                               input bf-del-plus_doc-line.prod-type,
                                               input bf-del-plus_doc-line.prod-code,
                                               input available bf-del-check-plus_parts,
                                               input varrsrv-plus-qnty) no-error.
      if error-status:error then do:
        return error return-value.
      end.
    end.
    if varrsrv-plus-parts-real <> varrsrv-qnty then do:
      undo, return error substitute ("Ошибка при резервировании. Списываемый товар &1 &2 &3. Количество &4. Количество по оприходованным товарам &5.", bf-del_goods.artic, bf-del_goods.prod-type, bf-del_goods.prod-code, varrsrv-qnty, varrsrv-plus-parts-real).
    end.
  end.
end.
else do:
  /*Удаляем одну связку списания-прихода*/
  find first bf-del_doc-line      where recid(bf-del_doc-line)      = varrecdoc-line      exclusive-lock.
  find first bf-del_goods         where bf-del_goods.artic          = bf-del_doc-line.artic     and
                                        bf-del_goods.prod-type      = bf-del_doc-line.prod-type and
                                        bf-del_goods.prod-code      = bf-del_doc-line.prod-code no-lock.
  find first bf-del-plus_doc-line where recid(bf-del-plus_doc-line) = varrecdoc-line-plus exclusive-lock.
  find first bf-del-plus_goods    where bf-del-plus_goods.artic     = bf-del-plus_doc-line.artic     and
                                        bf-del-plus_goods.prod-type = bf-del-plus_doc-line.prod-type and
                                        bf-del-plus_goods.prod-code = bf-del-plus_doc-line.prod-code no-lock.
  { str/is-petrl.i
    bf-del_goods.artic
    bf-del_goods.prod-type
    bf-del_goods.prod-code
    varis-petrol
    varis-pieces
    no-error
  }
  if error-status:error then do:
    undo, return error substitute ("Ошибка при определении топлива: &1.", return-value).
  end.
  { str/is-petrl.i
    bf-del-plus_goods.artic
    bf-del-plus_goods.prod-type
    bf-del-plus_goods.prod-code
    varis-petrol-plus
    varis-pieces-plus
    no-error
  }
  if error-status:error then do:
    undo, return error substitute ("Ошибка при определении топлива: &1.", return-value).
  end.

  for each bf-del_parts-root where bf-del_parts-root.doc-code      = bf_trn-doc.doc-code        and
                                   bf-del_parts-root.orig-gds-code = bf-del_goods.gds-code      and
                                   bf-del_parts-root.gds-code      = bf-del-plus_goods.gds-code use-index pi exclusive-lock on error undo, return error return-value :
    run local-recalc in this-procedure (input "old":u,
                                        input recid(bf-del_doc-line),
                                        input yes) no-error.
    if error-status:error then do:
      undo, return error substitute ("Ошибка при пересчете строки документа: &1.", return-value).
    end.
    find first tt-recalc-line where tt-recalc-line.doc-code  = bf-del_doc-line.doc-code  and
                                    tt-recalc-line.artic     = bf-del_doc-line.artic     and
                                    tt-recalc-line.prod-type = bf-del_doc-line.prod-type and
                                    tt-recalc-line.prod-code = bf-del_doc-line.prod-code no-error.
    if not available tt-recalc-line then do:
      create tt-recalc-line.
      buffer-copy bf-del_doc-line to tt-recalc-line.
    end.
    find first tt-recalc-line where tt-recalc-line.doc-code  = bf-del-plus_doc-line.doc-code  and
                                    tt-recalc-line.artic     = bf-del-plus_doc-line.artic     and
                                    tt-recalc-line.prod-type = bf-del-plus_doc-line.prod-type and
                                    tt-recalc-line.prod-code = bf-del-plus_doc-line.prod-code no-error.
    if not available tt-recalc-line then do:
      create tt-recalc-line.
      buffer-copy bf-del-plus_doc-line to tt-recalc-line.
    end.

    find first bf-del_parts where bf-del_parts.obj-type  = bf_trn-doc.obj-type              and
                                  bf-del_parts.obj-code  = bf_trn-doc.obj-code              and
                                  bf-del_parts.artic     = bf-del_goods.artic               and
                                  bf-del_parts.prod-type = bf-del_goods.prod-type           and
                                  bf-del_parts.prod-code = bf-del_goods.prod-code           and
                                  bf-del_parts.in-code   = bf-del_parts-root.orig-in-code   and
                                  bf-del_parts.out-code  = bf_trn-doc.doc-code              and
                                  bf-del_parts.part-code = bf-del_parts-root.orig-part-code exclusive-lock.
    find first bf-del_gds-dtl where bf-del_gds-dtl.doc-code  = bf-del_doc-line.doc-code  and
                                    bf-del_gds-dtl.artic     = bf-del_doc-line.artic     and
                                    bf-del_gds-dtl.prod-type = bf-del_doc-line.prod-type and
                                    bf-del_gds-dtl.prod-code = bf-del_doc-line.prod-code.
    find first bf-del-plus_parts where bf-del-plus_parts.obj-type  = bf_trn-doc.obj-type         and
                                       bf-del-plus_parts.obj-code  = bf_trn-doc.obj-code         and
                                       bf-del-plus_parts.artic     = bf-del-plus_goods.artic     and
                                       bf-del-plus_parts.prod-type = bf-del-plus_goods.prod-type and
                                       bf-del-plus_parts.prod-code = bf-del-plus_goods.prod-code and
                                       bf-del-plus_parts.in-code   = bf-del_parts-root.in-code   and
                                       bf-del-plus_parts.out-code  = bf_trn-doc.doc-code         and
                                       bf-del-plus_parts.part-code = bf-del_parts-root.part-code exclusive-lock.
    assign
      varmem-qnty = bf-del-plus_parts.real-qnty
      varchg-qnty = varmem-qnty.
     if varis-petrol     and
        not varis-pieces then do:
       find first bf-del_doc-pl where bf-del_doc-pl.obj-type  = bf-del_doc-line.obj-type and
                                      bf-del_doc-pl.obj-code  = bf-del_doc-line.obj-code and
                                      bf-del_doc-pl.pl-code   = bf-del_parts.pl-code     and
                                      bf-del_doc-pl.out-code  = bf-del_doc-line.doc-code and
                                      bf-del_doc-pl.gds-code  = bf-del_goods.gds-code    exclusive-lock.
        assign
          vardensity-doc-pl = bf-del_doc-pl.cli-fact-qnty / bf-del_doc-pl.fact-qnty.
     end.
     run trg/rsrv-dtl.p (input parparentproc,
                     {&rsrv-dtl_action_reserv}
                     + ',' + {&rsrv-dtl_negative-check} + "=2"
                     + "," + {&rsrv-dtl_rsrv-single-part}
                     + "," + {&rsrv-dtl_rsrv-in-code}   + "=" + str-encode(bf-del_parts.in-code,   "":u, ",=":u)
                     + "," + {&rsrv-dtl_rsrv-part-code} + "=" + str-encode(bf-del_parts.part-code, "":u, ",=":u)
                     ,
                     buffer bf-del_gds-dtl,
                     input-output varchg-qnty,
                     input-output bf-del_doc-line.price-base,
                     input-output bf-del_doc-line.price-rubl,
                     -1, "") no-error.
     if error-status:error then do:
       undo, return error substitute ("Ошибка при снятии резервировов по списанному товару &1 &2 &3 &4: &5.", bf-del_goods.artic, bf-del_goods.prod-type, bf-del_goods.prod-code, bf-del_goods.gds-name, return-value).
     end.
     if varmem-qnty <> varchg-qnty then do:
       undo, return error substitute("Не все резервы были сняты по списанному товару: &1 &2 &3 &4. Количество для снятия резерва: &5. Снято резервов: &6.", bf-del_goods.artic, bf-del_goods.prod-type, bf-del_goods.prod-code, bf-del_goods.gds-name, varmem-qnty, varchg-qnty).
     end.
     assign
       bf-del_doc-line.fact-qnty  = bf-del_doc-line.fact-qnty + varchg-qnty
     .
     if varis-petrol     and
       not varis-pieces then do:
       assign
         bf-del_doc-pl.doc-qnty      = bf-del_doc-pl.doc-qnty + varchg-qnty
         bf-del_doc-pl.fact-qnty     = bf-del_doc-pl.doc-qnty
         bf-del_doc-pl.cli-qnty      = bf-del_doc-pl.doc-qnty * vardensity-doc-pl
         bf-del_doc-pl.cli-doc-qnty  = bf-del_doc-pl.cli-qnty
         bf-del_doc-pl.cli-fact-qnty = bf-del_doc-pl.cli-doc-qnty
       .
       assign
         bf-del_doc-line.cli-qnty = bf-del_doc-line.cli-qnty + varchg-qnty * vardensity-doc-pl.
     end.
     find first bf-del-check_parts where bf-del-check_parts.out-code  = bf-del_doc-line.doc-code  and
                                         bf-del-check_parts.obj-type  = bf-del_doc-line.obj-type  and
                                         bf-del-check_parts.obj-code  = bf-del_doc-line.obj-code  and
                                         bf-del-check_parts.artic     = bf-del_doc-line.artic     and
                                         bf-del-check_parts.prod-type = bf-del_doc-line.prod-type and
                                         bf-del-check_parts.prod-code = bf-del_doc-line.prod-code no-error.
     run rsrv-gds-dtl in this-procedure (input bf-del_doc-line.doc-code,
                                         input bf-del_doc-line.artic,
                                         input bf-del_doc-line.prod-type,
                                         input bf-del_doc-line.prod-code,
                                         input available bf-del-check_parts,
                                         input varchg-qnty) no-error.
     if error-status:error then do:
       return error return-value.
     end.
     if bf-del_doc-line.fact-qnty = 0    and
        not available bf-del-check_parts then do:
       run local-recalc in this-procedure (input "delete":u,
                                           input recid(bf-del_doc-line),
                                           input yes) no-error.
       if error-status:error then do:
         undo, return error substitute ("Ошибка при пересчете строки документа. Списываемый товар: &1 &2 &3.", bf-del_doc-line.artic, bf-del_doc-line.prod-type, bf-del_doc-line.prod-code).
       end.
       run local-line-delete in this-procedure (input recid(bf-del_doc-line)) no-error.
       if error-status:error then do:
         undo, return error substitute ("Ошибка при удалении строки документа. Списываемый товар: &1 &2 &3.", bf-del_doc-line.artic, bf-del_doc-line.prod-type, bf-del_doc-line.prod-code).
       end.
     end.
     else do:
       run local-recalc in this-procedure (input "update":u,
                                           input recid(bf-del_doc-line),
                                           input yes) no-error.
       if error-status:error then do:
         undo, return error substitute ("Ошибка при пересчете строки документа по списанным товарам: &1", return-value).
       end.
       run proc-get-write-off (buffer bf-del_doc-line).
      /*Зачистим нулевые признаки*/
      find first bf-del_gds-dtl where bf-del_gds-dtl.doc-code  = bf-del_doc-line.doc-code  and
                                      bf-del_gds-dtl.artic     = bf-del_doc-line.artic     and
                                      bf-del_gds-dtl.prod-type = bf-del_doc-line.prod-type and
                                      bf-del_gds-dtl.prod-code = bf-del_doc-line.prod-code and
                                      bf-del_gds-dtl.doc-qnty <> 0                              no-error.
      if available bf-del_gds-dtl then do:
        for each bf-del_gds-dtl where bf-del_gds-dtl.doc-code  = bf-del-plus_doc-line.doc-code  and
                                      bf-del_gds-dtl.artic     = bf-del-plus_doc-line.artic     and
                                      bf-del_gds-dtl.prod-type = bf-del-plus_doc-line.prod-type and
                                      bf-del_gds-dtl.prod-code = bf-del-plus_doc-line.prod-code and
                                      bf-del_gds-dtl.doc-qnty  = 0                              on error undo, return error return-value :
          delete bf-del_gds-dtl.
        end.
      end.
    end.
    if varis-petrol-plus and
      not varis-pieces  then do:
      find first bf-del-plus_doc-pl where bf-del-plus_doc-pl.obj-type  = bf-del-plus_doc-line.obj-type and
                                          bf-del-plus_doc-pl.obj-code  = bf-del-plus_doc-line.obj-code and
                                          bf-del-plus_doc-pl.pl-code   = bf-del-plus_parts.pl-code     and
                                          bf-del-plus_doc-pl.out-code  = bf-del-plus_doc-line.doc-code and
                                          bf-del-plus_doc-pl.gds-code  = bf-del-plus_goods.gds-code    exclusive-lock.
      assign
        vardensity-doc-pl = bf-del-plus_doc-pl.cli-fact-qnty / bf-del-plus_doc-pl.fact-qnty.
      assign
        bf-del-plus_doc-pl.doc-qnty      = bf-del-plus_doc-pl.doc-qnty - bf-del-plus_parts.fact-qnty
        bf-del-plus_doc-pl.fact-qnty     = bf-del-plus_doc-pl.doc-qnty
        bf-del-plus_doc-pl.cli-qnty      = bf-del-plus_doc-pl.doc-qnty * vardensity-doc-pl
        bf-del-plus_doc-pl.cli-doc-qnty  = bf-del-plus_doc-pl.cli-qnty
        bf-del-plus_doc-pl.cli-fact-qnty = bf-del-plus_doc-pl.cli-qnty
        bf-del-plus_doc-line.cli-qnty    = bf-del-plus_doc-line.cli-qnty - bf-del-plus_parts.fact-qnty * vardensity-doc-pl.
    end.
    assign
      bf-del-plus_doc-line.fact-qnty  = bf-del-plus_doc-line.fact-qnty - bf-del-plus_parts.fact-qnty
    .
    assign
      varrsrv-plus-qnty = bf-del-plus_parts.fact-qnty.
    delete bf-del-plus_parts.
    delete bf-del_parts-root.
    find first bf-del-check-plus_parts where bf-del-check-plus_parts.out-code  = bf-del-plus_doc-line.doc-code  and
                                             bf-del-check-plus_parts.obj-type  = bf-del-plus_doc-line.obj-type  and
                                             bf-del-check-plus_parts.obj-code  = bf-del-plus_doc-line.obj-code  and
                                             bf-del-check-plus_parts.artic     = bf-del-plus_doc-line.artic     and
                                             bf-del-check-plus_parts.prod-type = bf-del-plus_doc-line.prod-type and
                                             bf-del-check-plus_parts.prod-code = bf-del-plus_doc-line.prod-code no-error.
    run rsrv-gds-dtl-plus in this-procedure (input bf-del-plus_doc-line.doc-code,
                                             input bf-del-plus_doc-line.artic,
                                             input bf-del-plus_doc-line.prod-type,
                                             input bf-del-plus_doc-line.prod-code,
                                             input available bf-del-check-plus_parts,
                                             input varrsrv-plus-qnty) no-error.
    if error-status:error then do:
      return error return-value.
    end.
  end.
end.
run recalc-line in this-procedure no-error.
if error-status:error then do:
  undo, return error substitute ("Ошибка при пересчете строк документа: ", return-value).
end.
end.