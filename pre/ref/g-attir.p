block-level on error undo, throw.
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
define variable v-update-attr as logical no-undo .
define temp-table tt0-goods-attr no-undo like ub.goods-attr
field grp as logical
field fdisable as logical
index attr-code-activ fdisable gds-code attr-code
index attr-code                gds-code attr-code.
procedure addGdsGrpAttr:
   define input  parameter i-gds-code as integer no-undo.
   define input  parameter i-grp-code as integer no-undo.
   define variable vi as integer no-undo.
   define buffer buf_gds-grp-obj-attr for gds-grp-obj-attr.
   define buffer tt0-goods-attr for tt0-goods-attr.
   define buffer buf-goods-attr for tt0-goods-attr.
   for each tt0-goods-attr where tt0-goods-attr.grp:
      delete tt0-goods-attr.
   end.
   do vi = 1 to num-entries('alcohol-prod,egais-name,is-gas,ptrl-without-rvs,office-type,mark-type,emrc-type,IS18Plus,loyalty-gift,item-matter-mark,type-method-calc,group-np,fuel-type,is-loyalty-payment,ban-bonus,null-price,fasovka,time-coock,mark,sum-grp-gl,min-zapas,mercur_FGIS,perishable,production-only,15x80,8x50,6x50,calories,protein,fat,carbohydrate,calc-cal-rec,cash-parts,ptrl-as-good,dflt-insalepr,gds-ptrl-densities,gds-CommodityCode,gds-code-AIS,length-of,width-of,height-of,qnty-in-box,weight-box,qnty-on-pallet,weight-of-pallet,image-list,MercUnits,weighed-gds':U):
      find first buf_gds-grp-obj-attr no-lock
         where buf_gds-grp-obj-attr.node-code   = i-grp-code
           and buf_gds-grp-obj-attr.host-code   = 0
           and buf_gds-grp-obj-attr.obj-type    = ""
           and buf_gds-grp-obj-attr.obj-code    = 0
           and buf_gds-grp-obj-attr.attr-code   = entry(vi,'alcohol-prod,egais-name,is-gas,ptrl-without-rvs,office-type,mark-type,emrc-type,IS18Plus,loyalty-gift,item-matter-mark,type-method-calc,group-np,fuel-type,is-loyalty-payment,ban-bonus,null-price,fasovka,time-coock,mark,sum-grp-gl,min-zapas,mercur_FGIS,perishable,production-only,15x80,8x50,6x50,calories,protein,fat,carbohydrate,calc-cal-rec,cash-parts,ptrl-as-good,dflt-insalepr,gds-ptrl-densities,gds-CommodityCode,gds-code-AIS,length-of,width-of,height-of,qnty-in-box,weight-box,qnty-on-pallet,weight-of-pallet,image-list,MercUnits,weighed-gds':U)
      no-error .
      if available buf_gds-grp-obj-attr
      then do:
         find first tt0-goods-attr where tt0-goods-attr.gds-code   = i-gds-code
                                     and tt0-goods-attr.attr-code  = buf_gds-grp-obj-attr.attr-code
                                     and tt0-goods-attr.grp
         no-error.
            create tt0-goods-attr.
         assign
            tt0-goods-attr.gds-code   = i-gds-code
            tt0-goods-attr.attr-code  = buf_gds-grp-obj-attr.attr-code
            tt0-goods-attr.attr-value = buf_gds-grp-obj-attr.attr-value
            tt0-goods-attr.grp        = yes
         .
         tt0-goods-attr.fdisable = can-find (buf-goods-attr where buf-goods-attr.gds-code   eq tt0-goods-attr.gds-code
                                                              and buf-goods-attr.attr-code  eq tt0-goods-attr.attr-code
                                                              and buf-goods-attr.grp        ne yes).
         .
         end.
   end.
end.
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
    when 'ИЗМЕНЕНИЕ':U then do:
      do on error undo, return error :
        Find first locked_goods-attr exclusive-lock  where
                locked_goods-attr.gds-code = p-gds-code
            and locked_goods-attr.attr-code = 'lock':U
            no-error no-wait.
        if not available locked_goods-attr
        and not locked locked_goods-attr then do:
          create locked_goods-attr.
          assign
          locked_goods-attr.gds-code =  p-gds-code
          locked_goods-attr.attr-code = 'lock':U
          .
        end.
        if locked locked_goods-attr then do:
          Find first locked_goods-attr exclusive-lock  where
                locked_goods-attr.gds-code = p-gds-code
            and locked_goods-attr.attr-code = 'lock':U
            no-error .
        end.
      end.
      for each buf_goods-attr no-lock where
                 buf_goods-attr.gds-code = p-gds-code:
             if buf_goods-attr.attr-code = 'lock':U then next.
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
                    , input p-update-on-exit
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
    end.
    when 'ПРОСМОТР':U then do:
      for each buf_goods-attr no-lock where
              buf_goods-attr.gds-code = p-gds-code:
          if buf_goods-attr.attr-code = 'lock':U then next.
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
                    , input p-update-on-exit
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
    end.
  end case.
end.
