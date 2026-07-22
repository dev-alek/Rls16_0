block-level on error undo, throw.
/*

$Revision: cb632b432cdb, 3204, rls $
$Author: Ostroukhov $
$Date: 2022/12/27 12:54:28 $
$Workfile: g-attir.p $
$Archive: ref/g-attir.p $

Запуск интерфейса редактирования глобальных атрибутов товара

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/22/05
Author: Bakhtadze Natalya
Creation date: 11/22/05

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-mode      as character no-undo .
define input parameter p-gds-code  like ub.goods.gds-code no-undo .
define input parameter p-update-on-exit as logical no-undo .
define output parameter p-modified as logical no-undo .
define output parameter p-is-error as logical no-undo .

define variable vss-revision    as character no-undo init "$Revision: cb632b432cdb, 3204, rls $":U .
define variable vss-author      as character no-undo init "$Author: Ostroukhov $":U .
define variable vss-date        as character no-undo init "$Date: 2022/12/27 12:54:28 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: g-attir.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/g-attir.p $":U .
define variable vss-description as character no-undo init "Запуск интерфейса редактирования глобальных атрибутов товара".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
define variable v-update-attr as logical no-undo .

{ ref/g-attr-tt.i}
define buffer buf_goods-attr for ub.goods-attr.
define buffer locked_goods-attr for ub.goods-attr.
define buffer goods          for ub.goods.
      
do transaction 
on error undo, return error return-value
on stop undo, return error return-value
:

  for each tt0-goods-attr:
    delete tt0-goods-attr.
  end.
  case p-mode:
    when {&update} then do:
      do on error undo, return error :
        Find first locked_goods-attr exclusive-lock  where
                locked_goods-attr.gds-code = p-gds-code
            and locked_goods-attr.attr-code = {&attr-gds-attr-lock}
            no-error no-wait.
        if not available locked_goods-attr
        and not locked locked_goods-attr then do:
          create locked_goods-attr.
          assign
          locked_goods-attr.gds-code =  p-gds-code
          locked_goods-attr.attr-code = {&attr-gds-attr-lock}
          .
        end.
        if locked locked_goods-attr then do:
          Find first locked_goods-attr exclusive-lock  where
                locked_goods-attr.gds-code = p-gds-code
            and locked_goods-attr.attr-code = {&attr-gds-attr-lock}
            no-error .
        end.
      end.
      for each buf_goods-attr no-lock where
                 buf_goods-attr.gds-code = p-gds-code:
             if buf_goods-attr.attr-code = {&attr-gds-attr-lock} then next.
             create tt0-goods-attr.
             buffer-copy buf_goods-attr to tt0-goods-attr.
      end.
      find first goods where goods.gds-code eq p-gds-code no-lock no-error.
      if available goods 
      then
         run addGdsGrpAttr (goods.gds-code, goods.grp-code).
      run ref/gds-atti.w (
                      input parparentproc
                    , input p-mode
                    , input p-gds-code
                    , input p-update-on-exit /*update on exit from form*/
                    , output p-modified
                    , input-output table tt0-goods-attr
                          ) no-error.
      if error-status:error then do:
        assign
        p-is-error = yes
        .
      end.
      for each tt0-goods-attr:
        delete tt0-goods-attr.
      end.
      if p-is-error then do:
        return error substitute("&1 &2", error-status:get-message(1) , return-value ).
      end.
    end. /*update*/
    when {&lookup} then do:
      for each buf_goods-attr no-lock where
              buf_goods-attr.gds-code = p-gds-code:
          if buf_goods-attr.attr-code = {&attr-gds-attr-lock} then next.
          create tt0-goods-attr.
          buffer-copy buf_goods-attr to tt0-goods-attr.
      end.
      find first goods where goods.gds-code eq p-gds-code no-lock no-error.
      if available goods 
      then
         run addGdsGrpAttr (goods.gds-code, goods.grp-code).
      run ref/gds-atti.w (
                      input parparentproc
                    , input p-mode
                    , input p-gds-code
                    , input p-update-on-exit /*update on exit from form*/
                    , output p-modified
                    , input-output table tt0-goods-attr
                          ) no-error.
      if error-status:error then do:
        assign
        p-is-error = yes.

      end.
      for each tt0-goods-attr:
        delete tt0-goods-attr.
      end.
      if p-is-error then do:
        return error substitute("&1 &2", error-status:get-message(1) , return-value ).
      end.
    end. /*lookup*/
  end case.
end. /*doe*/