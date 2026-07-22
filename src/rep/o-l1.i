/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

С УРОВНЯ все или по списку

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Дата создания: 08/15/01
*/
&if '{7}' = 'tree' &then
  if x-selectobject = "currency":u  or  xtog-obj then do:
      for each tmp-gds no-lock :
                for  each gds-obj   where
                                    gds-obj.obj-type = x-store-type    and
                                    gds-obj.obj-code = x-store-code    and
                                    (trim(gds-obj.grp-name)   begins trim(tmp-gds.f-name) )
                                    {&ver-last-doc}
                                     no-lock ,
                first {4} where gds-obj.gds-code  = {4}.gds-code no-lock
                          break by {1} by {2} by ({6}) :
             str = n-lavel(input {4}.grp-name, input tmp-gds.lvl ) .
                assign
                    gds-zap-unit-base  = {4}.unit-base
                    gds-zap-prt-root   = {4}.prt-root
                    gds-zap-prod-type  = {4}.prod-type
                    gds-zap-prod-code  = {4}.prod-code
                    gds-zap-artic      = {4}.artic
                    gds-zap-type       = {4}.gds-type
                    gds-zap-grp-name   = {4}.grp-name
                    gds-zap-b-code     = {4}.gds-code
                    .
                  run foreach.
                  i = i + 1.
            end.
        if not
        (
          b1-oborot-{&bef-tdedt_pri_vnesh }                 [1]    = 0 and
          b1-oborot-{&bef-tdedt_ras_vnesh }                 [1]    = 0 and
          b1-oborot-{&bef-tdedt_ras_vnesh_vp }              [1]    = 0 and
          b1-oborot-{&bef-tdedt_ras_vnesh_kass }            [1]    = 0 and
          b1-oborot-{&bef-tdedt_vozvrat_vnesh }             [1]    = 0 and
          b1-oborot-{&bef-tdedt_vozvrat_vnesh_kass }        [1]    = 0 and
          b1-oborot-{&bef-tdedt_spi_vnesh }                 [1]    = 0 and
          b1-oborot-{&bef-tdedt_inv }                       [1]    = 0 and
          b1-oborot-{&bef-tdedt_pri_perem }                 [1]    = 0 and
          b1-oborot-{&bef-tdedt_ras_perem }                 [1]    = 0 and
          b1-oborot-{&bef-tdedt_vozvrat_perem }             [1]    = 0 and
          b1-oborot-{&bef-tdedt_ras_prvo }                  [1]    = 0 and
          b1-oborot-{&bef-tdedt_spi_prvo }                  [1]    = 0 and
          b1-oborot-{&bef-tdedt_pri_prvo }                  [1]    = 0 and
          b1-oborot-{&bef-tdedt_overturn }                  [1]    = 0 and
          b1-oborot-{&bef-disc }                            [1]    = 0 and
          b1-ostatok-end                                    [1]    = 0 and
          b1-ostatok-start                                  [1]    = 0 and
          b1-oborot-{&bef-tdedt_overturn }                  [2]    = 0
           )  then do:


         assign
          s-bar-code       = substring(tmp-gds.name,1,9)
          sf1:screen-value = substring(tmp-gds.name,10,1)
          gds-zap-artic    = substring(tmp-gds.name,11,16)
          sf2:screen-value = substring(tmp-gds.name,27,1)
          gds-zap-gds-name = substring(tmp-gds.name,28,40)
          no-error .
          run display-b1 .
          run clear-b1 .
          run clear-b2 .
          assign
            sf1:screen-value =""
            sf2:screen-value =""
            no-error .
      end.
    end.
  end.
  else do:  /*--------------------------------------------------------------------------------------------------*/
  /*по списку obj-list */
  for each obj-list no-lock :
                for  each gds-obj   where
                                    gds-obj.obj-type = obj-list.obj-type    and
                                    gds-obj.obj-code = obj-list.obj-code
                                    {&ver-last-doc}
                                     no-lock ,
                first {4} where gds-obj.gds-code  = {4}.gds-code
                                    no-lock :
                    if not can-find(first temp-gds-list where temp-gds-list.gds-code = gds-obj.gds-code) then do:
                        create temp-gds-list.
                        assign
                          temp-gds-list.prod-code = gds-obj.prod-code
                          temp-gds-list.grp-name  = gds-obj.grp-name
                          temp-gds-list.gds-code  = gds-obj.gds-code
                          temp-gds-list.artic     = gds-obj.artic
                          temp-gds-list.gds-name  = {4}.gds-name
                          .
                    end.

            end.
 end.
        for each tmp-gds no-lock   :
        for each temp-gds-list no-lock
           where (trim(temp-gds-list.grp-name)   begins trim(tmp-gds.f-name) )
          &if "{4}" = "goods":u  &then     , first goods  where goods.gds-code  = temp-gds-list.gds-code no-lock   &endif
          &if "{4}" = "gds-list":u  &then  , first gds-list  where gds-list.gds-code  = temp-gds-list.gds-code no-lock  &endif
            break
              &if "{1}" <> "1"  &then by {1}  &endif
              &if "{2}" <> "1"  &then by {2}  &endif
              by {6} :
             str = n-lavel(input {4}.grp-name, input tmp-gds.lvl ) .
                assign
                    gds-zap-unit-base  = {4}.unit-base
                    gds-zap-prt-root   = {4}.prt-root
                    gds-zap-prod-type  = {4}.prod-type
                    gds-zap-prod-code  = {4}.prod-code
                    gds-zap-artic      = {4}.artic
                    gds-zap-type       = {4}.gds-type
                    gds-zap-grp-name   = {4}.grp-name
                    gds-zap-b-code     = {4}.gds-code
                    .
                  run foreach.
                  i = i + 1.
        end.
            if not
            (
              b1-oborot-{&bef-tdedt_pri_vnesh }                 [1]    = 0 and
              b1-oborot-{&bef-tdedt_ras_vnesh }                 [1]    = 0 and
              b1-oborot-{&bef-tdedt_ras_vnesh_vp }              [1]    = 0 and
              b1-oborot-{&bef-tdedt_ras_vnesh_kass }            [1]    = 0 and
              b1-oborot-{&bef-tdedt_vozvrat_vnesh }             [1]    = 0 and
              b1-oborot-{&bef-tdedt_vozvrat_vnesh_kass }        [1]    = 0 and
              b1-oborot-{&bef-tdedt_spi_vnesh }                 [1]    = 0 and
              b1-oborot-{&bef-tdedt_inv }                       [1]    = 0 and
              b1-oborot-{&bef-tdedt_pri_perem }                 [1]    = 0 and
              b1-oborot-{&bef-tdedt_ras_perem }                 [1]    = 0 and
              b1-oborot-{&bef-tdedt_vozvrat_perem }             [1]    = 0 and
              b1-oborot-{&bef-tdedt_ras_prvo }                  [1]    = 0 and
              b1-oborot-{&bef-tdedt_spi_prvo }                  [1]    = 0 and
              b1-oborot-{&bef-tdedt_pri_prvo }                  [1]    = 0 and
              b1-oborot-{&bef-tdedt_overturn }                  [1]    = 0 and
              b1-oborot-{&bef-disc }                            [1]    = 0 and
              b1-ostatok-end                                    [1]    = 0 and
              b1-ostatok-start                                  [1]    = 0 and
              b1-oborot-{&bef-tdedt_overturn }                  [2]    = 0
              )  then do:
            assign
              s-bar-code       = substring(tmp-gds.name,1,9)
              sf1:screen-value = substring(tmp-gds.name,10,1)
              gds-zap-artic    = substring(tmp-gds.name,11,16)
              sf2:screen-value = substring(tmp-gds.name,27,1)
              gds-zap-gds-name = substring(tmp-gds.name,28,40)
              no-error .
              run display-b1 .
              run clear-b1 .
              run clear-b2 .
              assign
                sf1:screen-value =""
                sf2:screen-value =""
                no-error .
            end.
    end.
  end.
&else
  &scoped-define seq {&sequence}
  define buffer buf_obj-list{&seq} for obj-list.
  for each buf_obj-list{&seq} no-lock :
      if xtog-obj and  not (buf_obj-list{&seq}.obj-type = x-store-type  and
                            buf_obj-list{&seq}.obj-code = x-store-code )
      then next.
        for  each gds-obj   where
                            gds-obj.obj-type = buf_obj-list{&seq}.obj-type    and
                            gds-obj.obj-code = buf_obj-list{&seq}.obj-code
                            {&ver-last-doc}
                            no-lock ,
        first {4} where gds-obj.gds-code  = {4}.gds-code
                            no-lock :
            if not can-find(first temp-gds-list where temp-gds-list.gds-code = gds-obj.gds-code) then do:
                create temp-gds-list.
                assign
                  temp-gds-list.prod-code = gds-obj.prod-code
                  temp-gds-list.grp-name  = ""
                  temp-gds-list.gds-code  = gds-obj.gds-code
                  temp-gds-list.artic     = gds-obj.artic
                  temp-gds-list.gds-name  = {4}.gds-name
                  .
                  temp-gds-list.grp-name  = n-lavel(input gds-obj.grp-name, input xlavel )
                  .
            end.


        end.
 end.

  for each temp-gds-list no-lock
    &if "{4}" = "goods":u  &then     , first goods  where goods.gds-code  = temp-gds-list.gds-code no-lock   &endif
    &if "{4}" = "gds-list":u  &then  , first gds-list  where gds-list.gds-code  = temp-gds-list.gds-code no-lock  &endif
      break
        &if "{2}" <> "1"  &then by  temp-gds-list.grp-name   &endif
        by {6} :
        str = n-lavel(input {4}.grp-name, input xlavel ) no-error .
        { rep/o-lavel.i "''" temp-gds-list.grp-name "''" {4} }
  end.


  &endif
  /* $workfile: o-l1.i $ e n d */