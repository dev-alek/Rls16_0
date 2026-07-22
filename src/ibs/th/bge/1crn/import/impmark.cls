/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Класс ипорта данных kass-book (типы кассовых книг) из 1С

Автор: Молотков Сергей
Дата создания: 13/02/19
Author: Molotkov Sergey
Creation date: 13/02/19

*/
&scoped-define impclass mark
using ibs.th.bge.1crn.subjects.subjects.
using ibs.th.bge.1crn.subjects.{&impclass}.

block-level on error undo, throw.

class ibs.th.bge.1crn.import.imp{&impclass} inherits ibs.th.gbl.sys.objth implements ibs.th.bge.1crn.import.iimpsubject : 
    define override public property vss-revision    as character no-undo init "$Revision:$":U get .
    define override public property vss-author      as character no-undo init "$Author:$":U get.
    define override public property vss-date        as character no-undo init "$Date:$":U get.
    define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
    define override public property vss-archive     as character no-undo init "$Archive:$":U get.
    define override public property vss-description as character no-undo init "Импорт {&impclass}" get.
   
  { cmp/str-glbl.i class } /* &add-def, &update, &deletion, &shop, &attr-cash-book-id, &attr-oper-serv-id */
  /* { gbl/attr-lib.i class } gds-attr-write() заинлайнена */
  {utl\gtin.i class}
  define temp-table tt-marking like ub.marking
    field mrc as integer
    field weight as decimal
    field existKM as logical init no  /* признак для агрегата, что внутри есть проданная или добавленная в док-т марка */  
  .
  define private temp-table tt-mark no-undo 
     field mark as character case-sensitive 
  .
/*  define private temp-table tt-operserv no-undo like ub.OperServ .*/
  
  define property Msg as character no-undo
    get. 
    set.

  define stream myProt.

  method public logical Excute( subjectObj as class ibs.th.bge.1crn.subjects.isubject ):
    define variable objImp    as class ibs.th.bge.1crn.subjects.mark no-undo.
    define variable v-retfl   as logical no-undo .
    define variable v-mode    as character no-undo. /* create/update */
   
    define variable v-i-counter as integer no-undo .
    define variable v-i-num     as integer no-undo .
    define variable v-stub      as integer no-undo .
    define variable vmark       as character no-undo.
    define variable vKM         as character no-undo.
    
    define variable v-host-code  as integer no-undo .
    define buffer buf_bar-code    for ub.bar-code .
    define buffer buf_goods      for ub.goods .
    define buffer marking for marking.
    define buffer marking-attr for ub.marking-attr .
    define buffer parentMarking for marking.


    objImp = cast (subjectObj, {&impclass}).

    if objImp:del-f > 0 then
      undo, throw new Progress.Lang.AppError("физичесткое удаление edi-doc не предусмотрено") .    
    
    /* если код не задан:
         - если пришла с признаком "основная" - то обновляем CashBook.id = 0 и не грузим секцию с товарами;
         - если пришла без признака "основная" - то режим создания с автоматическим присвоением кода;
       если код задан:
         - признак "основная" игнорируется;
         - если код присутствует в БД - режим обновления;
         - если код отсутствует в БД - режим создания;
       логическое удаление - только, если код задан, присутствует в БД, и CashBook.id <> 0.
       
       чтобы при изменении записи не затирать поля, которые не приходят из 1С, значениями по умолчанию -
       читаем их значения из исходной записи;
       чтобы при изменении записи не затирать поля из необязательных тегов, которые пришли из 1С, пустыми значениями -
       читаем их значения из исходной записи.
    */
   if objImp:obj-load ne "mark"
   then
      undo, throw new Progress.Lang.AppError(substitute("Загрузка &1 не предусмотрена",objImp:obj-load)) .
   vmark = repTegforDm(objImp:mark-code).
   if objImp:unit-ext <> "LEVEL2" then
   do:
     vKM = GetCodeIdent(vmark).
     if vKM = ""
     then
        undo, throw new Progress.Lang.AppError(substitute("Не удалось получить код маркировки по марке &1.", vmark)) .
   end.
   else 
     vKM = vmark.

   if objImp:gds-code = ? and objImp:unit-ext = "LEVEL2" then
   do:
      undo, throw new Progress.Lang.AppError("Код товара gds-code обязательный для unit-ext = LEVEL2") .
   end.
   if objImp:gds-code ne ?
   then do:
      find first buf_goods  where buf_goods.gds-code eq objImp:gds-code
      no-lock no-error.
      if not available buf_goods
      then
         undo, throw new Progress.Lang.AppError(substitute("Не известный товар &1",objImp:gds-code)) .
   end.
   if objImp:gtin ne ? and objImp:gds-code ne ? and objImp:unit-ext <> "LEVEL2" 
   then do:
      find first prod-bc  where prod-bc.b-str eq objImp:gtin
      no-lock no-error.
      if not available prod-bc
      then .
/*          undo, throw new Progress.Lang.AppError(substitute("Не известный GTIN &1",objImp:gtin)) .*/
      else do:
         find buf_bar-code where buf_bar-code.b-code = ub.prod-bc.b-code no-lock no-error .
         if    not available buf_bar-code
            or buf_bar-code.gds-code ne objImp:gds-code
         then
            undo, throw new Progress.Lang.AppError(substitute("GTIN &1 не принадлежит товару &2 ", objImp:gtin , objImp:gds-code)) . 
      end.
   end.

   find first tt-marking where tt-marking.mark begins vKM
   no-error.
   if not available tt-marking then
     create tt-marking.

      assign
          tt-marking.mark         = vmark
          tt-marking.gds-code     = objImp:gds-code
          tt-marking.gds-ext-id   = if objImp:unit-ext <> "LEVEL2" then objImp:GTIN else ""
          tt-marking.mark-parent  = repTegforDm(objImp:mark-parent) when objImp:mark-parent ne ? 
          tt-marking.box-qnty     = objImp:qnty-box
          tt-marking.unit-ext     = objImp:unit-ext
          tt-marking.sts          = ObjSrv:Env:marking:Sts:mark:GetKeyIntDB(objImp:stts)
          tt-marking.mrc          = objImp:mrc
          tt-marking.weight       = objImp:weight
          tt-marking.expDate      = objImp:expDate
          tt-marking.expDateOther = objImp:expDateOther
          .
   if tt-marking.gds-code eq 0
   then 
      tt-marking.gds-code = ?.
/*   if marking.mark-parent <> "" and                                                */
/*      can-do(objSrv:Env:Marking:Sts:Mark:Sale_Return_Wait,string(tt-marking.sts)) then*/
/*   do:   /* если марка продана или возвращена, то разгруппируем упаковку */        */
/*     for first parentMarking where                                                 */
/*               parentMarking.mark = marking.mark-parent                            */
/*         exclusive-lock:                                                           */
/*       parentMarking.sts = objSrv:Env:Marking:Sts:Mark:Ungrouped:KeyIntDB.         */
/*     end.                                                                          */
/*   end.                                                                            */
/*                                                                                   */
   if tt-marking.sts eq ? then
      undo, throw new Progress.Lang.AppError(substitute("Не известный статус марки &1",objImp:stts)) .
   
   if tt-marking.sts ne objSrv:Env:Marking:Sts:Mark:MarkError:KeyIntDB
   then do:
   if    tt-marking.box-qnty < 1
      or tt-marking.box-qnty eq ? 
   then
      undo, throw new Progress.Lang.AppError(substitute("Значение qnty-box должно быть больше 0")) .
   define variable vgtin as character no-undo.
   vgtin = getGtinByDM(tt-marking.mark).
   if vgtin eq ""
   then
      vgtin = ?.
   if vgtin ne ?
      and tt-marking.gds-ext-id ne vgtin
      and tt-marking.unit-ext <> "LEVEL2"  /* EXPSD-8372 */
   then
      undo, throw new Progress.Lang.AppError(substitute("Значение Gitn &1 марки не равен &2",getGtinByDM(tt-marking.mark),tt-marking.gds-ext-id)) .
   if tt-marking.gds-code ne getGdsCodeByGtin(tt-marking.gds-ext-id)
      and tt-marking.unit-ext <> "LEVEL2"  /* ZI-701 для LEVEL2 GTIN не проверяем */
   then
      undo, throw new Progress.Lang.AppError(substitute("Значение Gitn &1 марки относится к товару &2, в файле товар &3",tt-marking.gds-ext-id,getGdsCodeByGtin(tt-marking.gds-ext-id),tt-marking.gds-code)) .
   
/*   if     objImp:mrc ne 0                                                 */
/*      and objImp:mrc ne ?                                                 */
/*   then do:                                                               */
/*      find first marking-attr where marking-attr.mark      eq marking.mark*/
/*                                and marking-attr.attr-code eq "MRC"       */
/*         exclusive-lock no-error.                                         */
/*      if not avail marking-attr                                           */
/*      then do:                                                            */
/*         create marking-attr.                                             */
/*         assign                                                           */
/*            marking-attr.mark =  marking.mark                             */
/*            marking-attr.attr-code = "MRC"                                */
/*                                                                          */
/*                                 no-error.                                */
/*      end.                                                                */
/*      marking-attr.attr-value = string(objImp:mrc).                       */
/*      release marking-attr no-error.                                      */
/*   end.                                                                   */
   end.  
  v-retfl = true .
    define variable i as integer no-undo .
    catch exAppErrors as class Progress.Lang.AppError :
      Msg = exAppErrors:ReturnValue .
      if Msg > "" then . else do :
        do i = 1 to exAppErrors:NumMessages :
          Msg = Msg + {&new-line} + exAppErrors:GetMessage(i) .
        end .
        if Msg > "" then . else Msg = "AppError в mark" .
      end .
      v-retfl = false .
      undo, throw exAppErrors .
    end catch .
    catch exProErrors as class Progress.Lang.ProError :
      do i = 1 to exProErrors:NumMessages :
        Msg = Msg + {&new-line} + exProErrors:GetMessage(i) .
      end .
      if Msg > "" then . else Msg = "ProError в mark" .
      v-retfl = false.
      undo, throw exProErrors .
    end catch .
    catch exAnyErrors as class Progress.Lang.Error:
      Msg = "Unexpected error в mark" .
      v-retfl = false .
      undo, throw exAnyErrors .
    end catch .
    finally :
      
      return v-retfl .
    end finally .
  end method. /* end_of Excute */

  method public logical WriteDB ():
    
    define variable vKM       as character no-undo.
    define variable vGtin     as character no-undo.
    define variable vGtinQnty as integer no-undo.
    define buffer buf_marking    for ub.marking.  
    define buffer buf_tt-marking for tt-marking.  

    for each tt-marking where
             tt-marking.unit-ext = "UNIT"
          or tt-marking.box-qnty = 1
        : /* сначала копируем в БД потребительские упаковки */
      copyMark2DB(buffer tt-marking, ?).

      /* Если КМ ранее была реализована или добавлена в документ,     */
      /* то разгруппируем упаковки с этой КМ на всех уровнях до верху */
        if can-do(objSrv:Env:Marking:Sts:Mark:Sale_Return_Wait,string(tt-marking.sts)) or
           can-do(objSrv:Env:Marking:Sts:Mark:Doc_Status,string(tt-marking.sts)) then
        do:
          ungroupTT(tt-marking.mark-parent).
        end.
    end.

    for each tt-marking where
             tt-marking.unit-ext <> "UNIT"
          or tt-marking.box-qnty > 1
        by tt-marking.box-qnty
        : /* потом копируем групповые упаковки и транспортные */

      vGtin     = getGtinByDM(tt-marking.mark) .
      vGtinQnty = getQntyCodeByGtin(vGtin).
      if tt-marking.mark-parent <> "" then
      do: 
          for each buf_marking no-lock where
                   buf_marking.mark-parent = tt-marking.mark
              break by buf_marking.mark
              :
            if buf_marking.sts = objSrv:Env:Marking:Sts:Mark:MarkError:KeyIntDB then
            do: 
              /* если в упаковке есть КМ в "Ошибке"            */
              /* и есть агрегат того же уровня с проданной КМ, */
              /* то разгруппируем упаковку */
              for first buf_tt-marking no-lock where
                         buf_tt-marking.mark-parent =  tt-marking.mark-parent
                     and buf_tt-marking.mark        <> tt-marking.mark
                     and buf_tt-marking.existKM
              :
                tt-marking.sts = objSrv:Env:Marking:Sts:Mark:Ungrouped:KeyIntDB.
              end.  
            end.
          end.
          if tt-marking.sts = objSrv:Env:Marking:Sts:Mark:MarkError:KeyIntDB then
          do:
            /* если  упаковка в "Ошибке"            */
            /* но на ее агрегате стоит признак проданной КМ, */
            /* то разгруппируем эту упаковку, чтобы не продали упаковкой, */
            /* т.к. на ней была Ошибка */
            for first buf_tt-marking no-lock where
                      buf_tt-marking.mark =  tt-marking.mark-parent
                  and buf_tt-marking.existKM
            :
              tt-marking.sts = objSrv:Env:Marking:Sts:Mark:Ungrouped:KeyIntDB.
            end.  
          end.
      end.

      /* перенесено из trndocmv-1c.p (ТЗ 7700183344 помарочное движение п.3.1.5.) */
      vKM = if tt-marking.unit-ext <> "LEVEL2" then GetCodeIdent(tt-marking.mark) else tt-marking.mark.
      find first buf_marking exclusive-lock where
               buf_marking.mark begins vKM no-error.
      if tt-marking.sts <> objSrv:Env:Marking:Sts:Mark:MarkError:KeyIntDB and 
         tt-marking.unit-ext <> "LEVEL2" and
         avail buf_marking and
         (buf_marking.sts = objSrv:Env:Marking:Sts:Mark:Ungrouped:KeyIntDB or 
          buf_marking.sts = objSrv:Env:Marking:Sts:Mark:GrayZone:KeyIntDB) then
      do:  /* если эта упаковка разгруппирована или Серая зона, то анализируем статус марок внутри упаковки */
        for each buf_marking no-lock where 
                 buf_marking.mark-parent = tt-marking.mark
             and buf_marking.sts = objSrv:Env:Marking:Sts:Mark:DeliveryControl:KeyIntDB
        :  /* считаем марки в Ожидает приемку */
            accum buf_marking.mark (count).
        end.
        if (accum count buf_marking.mark) >= vGtinQnty then
        do:  /* если все марки внутри упаковки Ожидает приемку, значит пришел полный состав и меняем статус упаковки */
          tt-marking.sts = objSrv:Env:Marking:Sts:Mark:DeliveryControl:KeyIntDB.  
        end.
        else
        do: /* иначе идем по маркам упаковки, если марка добавлена в чек или расходый док-т ее статус оставляем, а остальные меняем на Проверен*/
          for each buf_marking exclusive-lock where 
                   buf_marking.mark-parent = tt-marking.mark
               and can-do(objSrv:Env:Marking:Sts:Mark:FreeStatuses,string(buf_marking.sts))
          :
            buf_marking.sts = objSrv:Env:Marking:Sts:Mark:Checked_:KeyIntDB.
          end.
          if tt-marking.sts = objSrv:Env:Marking:Sts:Mark:GrayZone:KeyIntDB then
          do:  /* меняем статус с Серая зона на Разгруппирован */
            tt-marking.sts = objSrv:Env:Marking:Sts:Mark:Ungrouped:KeyIntDB.
          end.  
        end.
      end.
      copyMark2DB(buffer tt-marking, ?).
      if can-do(objSrv:Env:Marking:Sts:Mark:Sale_Return_Wait,string(tt-marking.sts)) or
         can-do(objSrv:Env:Marking:Sts:Mark:Doc_Status,string(tt-marking.sts)) then
      do:
        ungroupTT(tt-marking.mark-parent).
      end.
      setStatusChildMarks(tt-marking.mark, tt-marking.sts).
    end.
/*out2log("", 1).    */
/*run gbl/inidebug.p.*/
  end method.

  method private void ungroupTT
    (iMark as character)
  :
  /* разгруппировка упаковок верхних уровней в tt-marking, */
    define buffer buf_tt-marking for tt-marking.

    for first buf_tt-marking exclusive-lock where
              buf_tt-marking.mark = iMark
    :
      assign
        buf_tt-marking.sts = objSrv:Env:Marking:Sts:Mark:Ungrouped:KeyIntDB
        buf_tt-marking.existKM = yes
      .
      ungroupTT(buf_tt-marking.mark-parent). 
    end.
  end method.


  /* метод смены статуса дочерних КМ в зависимости от статуса родителя*/
  method private void setStatusChildMarks 
    (input iMark   as character,
     input iStatus as integer):
    
    define buffer buf_marking for ub.marking.
    
    if (can-do(objSrv:Env:Marking:Sts:Mark:Sale_Return_Wait,string(iStatus)) or
        can-do(objSrv:Env:Marking:Sts:Mark:Doc_Status,string(iStatus)) or
        iStatus = objSrv:Env:Marking:Sts:Mark:MarkError:KeyIntDB) then
    do: /* если упаковка добавлена в чек или расходый док-т, то меняем статус всех дочерних марок на статус родителя */
        for each buf_marking exclusive-lock where
                 buf_marking.mark-parent = iMark
        : /* идем по маркам упаковки меняем статус марки на статус групп. упаковки, если марка НЕ БЫЛА добавлена в чек или расходый док-т ее статус оставляем */
          buf_marking.sts = iStatus.
          setStatusChildMarks(buf_marking.mark, iStatus).
        end.
    end.
    if iStatus = objSrv:Env:Marking:Sts:Mark:Ungrouped:KeyIntDB then
    do:
        /* если статус родительской упаковки РАЗГРУППИРОВАН и, если дочерняя КМ не добавлена в чек или расходый док-т, */
        /* то меняем статус потреб.упаковок на Проверен */
        for each buf_marking exclusive-lock where
                 buf_marking.mark-parent = iMark
        :
          if not (can-do(objSrv:Env:Marking:Sts:Mark:Sale_Return_Wait,string(buf_marking.sts)) or
                  can-do(objSrv:Env:Marking:Sts:Mark:Doc_Status,string(buf_marking.sts)) or
                  buf_marking.sts = objSrv:Env:Marking:Sts:Mark:Ungrouped:KeyIntDB or
                  buf_marking.sts = objSrv:Env:Marking:Sts:Mark:MarkError:KeyIntDB) then
          do:  
            buf_marking.sts = objSrv:Env:Marking:Sts:Mark:Checked_:KeyIntDB.
          end.
          if buf_marking.sts = objSrv:Env:Marking:Sts:Mark:Ungrouped:KeyIntDB or
             buf_marking.sts = objSrv:Env:Marking:Sts:Mark:Checked_:KeyIntDB
          then do:
            setStatusChildMarks(buf_marking.mark, iStatus).
          end.
        end.
    end.
  end method.    

  method private void copyMark2DB 
    (buffer buf_tt-marking for tt-marking,
     input iSts as integer /* статус марки, который надо установить */
    ):
    define variable vKM       as character no-undo.
    define buffer buf_marking      for ub.marking.
    define buffer buf_marking-attr for ub.marking-attr.
    
    vKM = if buf_tt-marking.unit-ext <> "LEVEL2" 
          then GetCodeIdent(buf_tt-marking.mark) else buf_tt-marking.mark.
    find first buf_marking exclusive-lock where
               buf_marking.mark begins vKM no-error.
    if not avail buf_marking then 
    do:
      create buf_marking.
      buf_marking.sts = buf_tt-marking.sts. 
    end.
    buffer-copy buf_tt-marking except sts to buf_marking no-error.
    if error-status:error then
    do:
      undo, throw new Progress.Lang.AppError(substitute("Ошибка создания марки &1 товар &2",buf_tt-marking.mark,buf_tt-marking.gds-code)) .
    end.
    if iSts <> ? then /* если пришел определенный статус на вход, то ставим его */
      buf_marking.sts = iSts.
    else /* если пришел ?, то проверим, что марка НЕ добавлена в чек или расходый док-т, и тогда ставим статус поступивший от ИС «УРТ».  */
      if not (can-do(objSrv:Env:Marking:Sts:Mark:Sale_Return_Wait,string(buf_marking.sts)) or
              can-do(objSrv:Env:Marking:Sts:Mark:Doc_Status,string(buf_marking.sts)))
      then buf_marking.sts = buf_tt-marking.sts.
    validate buf_marking no-error.
    if error-status:error then
    do:
      undo, throw new Progress.Lang.AppError(substitute("Ошибка создания марки &1 товар &2",buf_tt-marking.mark,buf_tt-marking.gds-code)) .
    end.
    /* установим статус КМ во врем. таблице, как статус в БД, чтобы не путаться */
    tt-marking.sts = buf_marking.sts.
 
    if tt-marking.mrc ne 0 and 
       tt-marking.mrc ne ? then
    do:
      find first buf_marking-attr where buf_marking-attr.mark      eq buf_marking.mark
                                    and buf_marking-attr.attr-code eq "MRC"
           exclusive-lock no-error.
      if not avail buf_marking-attr
      then do:
        create buf_marking-attr.
        assign
          buf_marking-attr.mark =  buf_marking.mark
          buf_marking-attr.attr-code = "MRC"
        no-error.
      end.
      buf_marking-attr.attr-value = string(tt-marking.mrc).
      release buf_marking-attr no-error.
      if error-status:error then
      do:
        undo, throw new Progress.Lang.AppError(substitute("Ошибка создания марки &1 товар &2",buf_tt-marking.mark,buf_tt-marking.gds-code)) .
      end.
    end.
    if tt-marking.weight ne 0 and 
       tt-marking.weight ne ? then
    do:
      find first buf_marking-attr where buf_marking-attr.mark      eq buf_marking.mark
                                    and buf_marking-attr.attr-code eq "weight"
           exclusive-lock no-error.
      if not avail buf_marking-attr
      then do:
        create buf_marking-attr.
        assign
          buf_marking-attr.mark =  buf_marking.mark
          buf_marking-attr.attr-code = "weight"
        no-error.
      end.
      buf_marking-attr.attr-value = if tt-marking.weight < 1 and tt-marking.weight > 0 
                                      then string(tt-marking.weight,"9.999") 
                                      else string(tt-marking.weight). 
      release buf_marking-attr no-error.
      if error-status:error then
      do:
        undo, throw new Progress.Lang.AppError(substitute("Ошибка создания марки &1 товар &2",buf_tt-marking.mark,buf_tt-marking.gds-code)) .
      end.
    end.
        
  end method.    

  method private void out2log (iMark as character, iLevel as int):
    /* Для отладки: пишет в файл статусы марок после обработки */
    define variable vKM as character no-undo.
    define buffer buf_marking for ub.marking.

    if iLevel = 1 then
    do:
      output stream myProt to c:\wrk\impmark.log.
      output stream myProt close.
    end.
    for each tt-marking no-lock where
        tt-marking.mark-parent = iMark
    :
        vKM = if tt-marking.unit-ext <> "LEVEL2" then GetCodeIdent(tt-marking.mark) else tt-marking.mark. 
        find first buf_marking no-lock where
                   buf_marking.mark begins vKM no-error.
        output stream myProt to c:\wrk\impmark.log append.
        put stream myProt unformatted
          fill("  ", (iLevel - 1))
          tt-marking.gds-code " "
          buf_marking.mark " " 
          objSrv:Env:Marking:Sts:Mark:GetLabel(buf_marking.sts) skip
        .
        output stream myProt close.
        out2log(tt-marking.mark, iLevel + 1).
    end.
  end method.
end class.
