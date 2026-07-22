block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: 00061000.p $
$Archive: cut/00061000.p $

Файл пирога обрезания. Относится к категории 61.

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/23/06
Author: Bakhtadze Natalya
Creation date: 06/23/06

Обработка таблиц:
cash-desk
c-cash-desk
cash-desk-attr
c-cash-desk-attr
cash-pay
c-cash-pay
cash-pay-attr
c-cash-pay-attr
dis-cp-rule
c-dis-cp-rule
dis-cp-rule-attr
cshr-month
cshr-month-attr
shift-cash
shift-cash-attr
cd-clu
c-cd-clu
cd-clu-attr
cd-dlu
c-cd-dlu
cd-dlu-attr
cd-grp
c-cd-grp
cd-grp-attr
cd-doc
cd-doc-attr
c-cd-doc
cd-doc-line
cd-doc-line-attr
c-cd-doc-line
cd-plu
c-cd-plu
cd-plu-attr
cd-events
cd-events-attr
cd-event-log
cd-event-log-attr
cd-video-link
cd-video-link-attr

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00061000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00061000.p $":U .
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 61.".

{ cmp/str-glbl.i }
{ utl/tt-objs.i  }

define buffer new-db for dst.db .
define buffer new-clients for dst.clients .
define buffer new-goods for dst.goods .
define buffer old-cash-desk  for src.cash-desk.
define buffer new-cash-desk  for dst.cash-desk.
define buffer old-c-cash-desk  for src.c-cash-desk.
define buffer new-c-cash-desk  for dst.c-cash-desk.
define buffer old-cash-desk-attr  for src.cash-desk-attr.
define buffer new-cash-desk-attr  for dst.cash-desk-attr.
define buffer old-c-cash-desk-attr  for src.c-cash-desk-attr.
define buffer new-c-cash-desk-attr  for dst.c-cash-desk-attr.
define buffer old-cash-pay   for src.cash-pay.
define buffer new-cash-pay   for dst.cash-pay.
define buffer old-c-cash-pay   for src.c-cash-pay.
define buffer new-c-cash-pay   for dst.c-cash-pay.
define buffer old-cash-pay-attr   for src.cash-pay-attr.
define buffer new-cash-pay-attr   for dst.cash-pay-attr.
define buffer old-c-cash-pay-attr   for src.c-cash-pay-attr.
define buffer new-c-cash-pay-attr   for dst.c-cash-pay-attr.
define buffer old-dis-cp-rule  for src.dis-cp-rule.
define buffer new-dis-cp-rule  for dst.dis-cp-rule.
define buffer old-c-dis-cp-rule  for src.c-dis-cp-rule.
define buffer new-c-dis-cp-rule  for dst.c-dis-cp-rule.
define buffer old-dis-cp-rule-attr  for src.dis-cp-rule-attr.
define buffer new-dis-cp-rule-attr  for dst.dis-cp-rule-attr.
define buffer old-cshr-month for src.cshr-month.
define buffer new-cshr-month for dst.cshr-month.
define buffer old-cshr-month-attr for src.cshr-month-attr.
define buffer new-cshr-month-attr for dst.cshr-month-attr.
define buffer old-shift-cash for src.shift-cash.
define buffer new-shift-cash for dst.shift-cash.
define buffer old-shift-cash-attr for src.shift-cash-attr.
define buffer new-shift-cash-attr for dst.shift-cash-attr.
define buffer old-cd-clu  for src.cd-clu.
define buffer new-cd-clu  for dst.cd-clu.
define buffer old-c-cd-clu  for src.c-cd-clu.
define buffer new-c-cd-clu  for dst.c-cd-clu.
define buffer old-cd-clu-attr  for src.cd-clu-attr.
define buffer new-cd-clu-attr  for dst.cd-clu-attr.
define buffer old-cd-dlu  for src.cd-dlu.
define buffer new-cd-dlu  for dst.cd-dlu.
define buffer old-c-cd-dlu  for src.c-cd-dlu.
define buffer new-c-cd-dlu  for dst.c-cd-dlu.
define buffer old-cd-dlu-attr  for src.cd-dlu-attr.
define buffer new-cd-dlu-attr  for dst.cd-dlu-attr.
define buffer old-cd-grp  for src.cd-grp.
define buffer new-cd-grp  for dst.cd-grp.
define buffer old-c-cd-grp  for src.c-cd-grp.
define buffer new-c-cd-grp  for dst.c-cd-grp.
define buffer old-cd-grp-attr  for src.cd-grp-attr.
define buffer new-cd-grp-attr  for dst.cd-grp-attr.
define buffer old-cd-doc  for src.cd-doc.
define buffer new-cd-doc  for dst.cd-doc.
define buffer old-c-cd-doc  for src.c-cd-doc.
define buffer new-c-cd-doc  for dst.c-cd-doc.
define buffer old-cd-doc-attr  for src.cd-doc-attr.
define buffer new-cd-doc-attr  for dst.cd-doc-attr.
define buffer old-cd-doc-line  for src.cd-doc-line.
define buffer new-cd-doc-line  for dst.cd-doc-line.
define buffer old-c-cd-doc-line  for src.c-cd-doc-line.
define buffer new-c-cd-doc-line  for dst.c-cd-doc-line.
define buffer old-cd-doc-line-attr  for src.cd-doc-line-attr.
define buffer new-cd-doc-line-attr  for dst.cd-doc-line-attr.
define buffer old-cd-plu  for src.cd-plu.
define buffer new-cd-plu  for dst.cd-plu.
define buffer old-c-cd-plu  for src.c-cd-plu.
define buffer new-c-cd-plu  for dst.c-cd-plu.
define buffer old-cd-plu-attr  for src.cd-plu-attr.
define buffer new-cd-plu-attr  for dst.cd-plu-attr.
define buffer old-cd-events  for src.cd-events.
define buffer new-cd-events  for dst.cd-events.
define buffer old-cd-events-attr  for src.cd-events-attr.
define buffer new-cd-events-attr  for dst.cd-events-attr.
define buffer old-cd-event-log  for src.cd-event-log.
define buffer new-cd-event-log  for dst.cd-event-log.
define buffer old-cd-event-log-attr  for src.cd-event-log-attr.
define buffer new-cd-event-log-attr  for dst.cd-event-log-attr.
define buffer old-cd-video-link  for src.cd-video-link.
define buffer new-cd-video-link  for dst.cd-video-link.
define buffer old-cd-video-link-attr  for src.cd-video-link-attr.
define buffer new-cd-video-link-attr  for dst.cd-video-link-attr.






do
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
{ utl/00000001.i }
on WRITE of dst.cash-desk         override do: end.
on WRITE of dst.c-cash-desk       override do: end.
on WRITE of dst.cash-desk-attr    override do: end.
on WRITE of dst.c-cash-desk-attr  override do: end.
on WRITE of dst.cash-pay          override do: end.
on WRITE of dst.c-cash-pay        override do: end.
on WRITE of dst.cash-pay-attr     override do: end.
on WRITE of dst.c-cash-pay-attr   override do: end.
on WRITE of dst.dis-cp-rule       override do: end.
on WRITE of dst.c-dis-cp-rule     override do: end.
on WRITE of dst.dis-cp-rule-attr  override do: end.
on WRITE of dst.cshr-month        override do: end.
on WRITE of dst.cshr-month-attr   override do: end.
on WRITE of dst.shift-cash        override do: end.
on WRITE of dst.shift-cash-attr   override do: end.
on WRITE of dst.cd-clu            override do: end.
on WRITE of dst.c-cd-clu          override do: end.
on WRITE of dst.cd-clu-attr       override do: end.
on WRITE of dst.cd-dlu            override do: end.
on WRITE of dst.c-cd-dlu          override do: end.
on WRITE of dst.cd-dlu-attr       override do: end.
on WRITE of dst.cd-grp            override do: end.
on WRITE of dst.c-cd-grp          override do: end.
on WRITE of dst.cd-grp-attr       override do: end.
on WRITE of dst.cd-doc            override do: end.
on WRITE of dst.c-cd-doc          override do: end.
on WRITE of dst.cd-doc-attr       override do: end.
on WRITE of dst.cd-doc-line       override do: end.
on WRITE of dst.c-cd-doc-line     override do: end.
on WRITE of dst.cd-doc-line-attr  override do: end.
on WRITE of dst.cd-plu            override do: end.
on WRITE of dst.c-cd-plu          override do: end.
on WRITE of dst.cd-plu-attr       override do: end.
on WRITE of dst.cd-events         override do: end.
on WRITE of dst.cd-events-attr    override do: end.
on WRITE of dst.cd-event-log         override do: end.
on WRITE of dst.cd-event-log-attr    override do: end.
on WRITE of dst.cd-video-link        override do: end.
on WRITE of dst.cd-video-link-attr   override do: end.







{ utl/00000002.i cash-desk  }
{ utl/00000002.i cash-desk-attr  }
if varstay-history then do:
  for each old-c-cash-desk no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
    if old-c-cash-desk.subject = {&table_cd-plu}
    or old-c-cash-desk.subject = {&table_cd-plu-attr} then next. /*это с проверкой по товарам!!*/
    create new-c-cash-desk.
    buffer-copy old-c-cash-desk to new-c-cash-desk.
  end.
  { utl/00000002.i c-cash-desk-attr  }
end.
{ utl/00000002.i cash-pay   }
if varstay-history then do:
  { utl/00000002.i c-cash-pay   }
end.
{ utl/00000002.i cash-pay-attr   }
if varstay-history then do:
  { utl/00000002.i c-cash-pay-attr   }
end.
{ utl/00000002.i cshr-month }
{ utl/00000002.i cshr-month-attr }
{ utl/00000002.i shift-cash }
{ utl/00000002.i shift-cash-attr }
{ utl/00000002.i cd-clu  }
if varstay-history then do:
  { utl/00000002.i c-cd-clu  }
end.
{ utl/00000002.i cd-clu-attr  }
{ utl/00000002.i cd-dlu  }
if varstay-history then do:
  { utl/00000002.i c-cd-dlu  }
end.
{ utl/00000002.i cd-dlu-attr  }
{ utl/00000002.i cd-grp  }
if varstay-history then do:
  { utl/00000002.i c-cd-grp  }
end.
{ utl/00000002.i cd-grp-attr  }
{ utl/00000002.i dis-cp-rule  }
if varstay-history then do:
  { utl/00000002.i c-dis-cp-rule  }
end.
{ utl/00000002.i dis-cp-rule-attr  }
for each old-cd-plu no-lock on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
  find first new-goods where new-goods.gds-code  = old-cd-plu.gds-code no-lock no-error.
  if available new-goods then do:
    create new-cd-plu.
    buffer-copy old-cd-plu to new-cd-plu.
    if varstay-history then do:
      for each old-c-cd-plu no-lock where
              old-c-cd-plu.gds-code = new-cd-plu.gds-code
      on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
        create new-c-cd-plu.
        buffer-copy old-c-cd-plu to new-c-cd-plu.
        find first old-c-cash-desk no-lock where
                  (old-c-cash-desk.subject = {&table_cd-plu}
                  and old-c-cash-desk.corr-user-db-num = old-c-cd-plu.corr-user-db-num
                  and old-c-cash-desk.chip-num = old-c-cd-plu.chip-num
                  )
                  or  (old-c-cash-desk.subject = {&table_cd-plu-attr}
                  and old-c-cash-desk.corr-user-db-num = old-c-cd-plu.corr-user-db-num
                  and old-c-cash-desk.chip-num = old-c-cd-plu.chip-num
                  ) no-error.
        if available old-c-cash-desk then do:
          create new-c-cash-desk.
          buffer-copy old-c-cash-desk to new-c-cash-desk.
        end.
      end.
    end. /*if varstay-history then do:*/
    for each old-cd-plu-attr no-lock where
            old-cd-plu-attr.obj-type = new-cd-plu.obj-type
        and old-cd-plu-attr.obj-code = new-cd-plu.obj-code
        and old-cd-plu-attr.pos-type = new-cd-plu.pos-type
        and old-cd-plu-attr.plu-type = new-cd-plu.plu-type
        and old-cd-plu-attr.plu-code = new-cd-plu.plu-code
    on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
      create new-cd-plu-attr.
      buffer-copy old-cd-plu-attr to new-cd-plu-attr.
    end.

  end.
end.

for each new-db no-lock
,each new-clients no-lock
  where new-clients.db-num = new-db.db-num
:
  if vardate-actual-docs <> ? then do:
    if vartype-cut = 1 then do:
      find first tt-objs where tt-objs.obj-type = new-clients.obj-type and
                                tt-objs.obj-code = new-clients.obj-code no-error.
    end.
    if vartype-cut = 0      or
        (vartype-cut = 1 and available tt-objs) then do:
      for each old-cd-doc where old-cd-doc.obj-type   = new-clients.obj-type  and
                                  old-cd-doc.obj-code   = new-clients.obj-code and
                                  old-cd-doc.datekey_one >= vardate-actual-docs  no-lock
      on error undo, return error
      :
        run copy-cd-doc-body in this-procedure.
      end.
      for each old-cd-event-log where old-cd-event-log.obj-type   = new-clients.obj-type  and
                                  old-cd-event-log.obj-code   = new-clients.obj-code and
                                  old-cd-event-log.event-date >= vardate-actual-docs  no-lock
      on error undo, return error
      :
        create new-cd-event-log.
        buffer-copy old-cd-event-log to new-cd-event-log.
      end.
    end.
    else do:
      for each old-cd-doc where old-cd-doc.obj-type   = new-clients.obj-type  and
                                  old-cd-doc.obj-code   = new-clients.obj-code
      on error undo, return error
      :
        run copy-cd-doc-body in this-procedure.
      end.
      for each old-cd-event-log where old-cd-event-log.obj-type   = new-clients.obj-type  and
                                  old-cd-event-log.obj-code   = new-clients.obj-code
      on error undo, return error
      :
        create new-cd-event-log.
        buffer-copy old-cd-event-log to new-cd-event-log.
      end.

    end.
  end. /*if vardate-actual-docs <> ? then do:*/
end.
{ utl/00000002.i cd-events  }
{ utl/00000002.i cd-events-attr  }
{ utl/00000002.i cd-event-log-attr  " , first new-cd-event-log where ~
                                         new-cd-event-log.db-num = old-cd-event-log-attr.db-num ~
                                     and new-cd-event-log.trans-id = old-cd-event-log-attr.trans-id "

}
{ utl/00000002.i cd-video-link  }
{ utl/00000002.i cd-video-link-attr  }



output stream str-gen close.
return "Произведен экспорт таблиц: cash-desk cash-desk-attr c-cash-desk c-cash-desk-attr cash-pay c-cash-pay cash-pay-attr c-cash-pay-attr dis-cp-rule dis-cp-rule-attr c-dis-cp-rule ~
cshr-month csht-month-attr shift-cash shift-cash-attr ~
cd-clu c-cd-clu cd-clu-attr cd-dlu c-cd-dlu cd-dlu-attr cd-grp c-cd-grp cd-grp-attr cd-plu cd-plu-attr c-cd-plu ~
cd-doc c-cd-doc cd-doc-attr cd-doc-line cd-doc-line-attr c-cd-doc-line ~
cd-events cd-events-attr cd-event-log cd-event-log-attr cd-video-link cd-video-link-attr ~
.".
end.

procedure copy-cd-doc-body :
create new-cd-doc.
buffer-copy old-cd-doc to new-cd-doc.

for each old-cd-doc-attr no-lock  where
        old-cd-doc-attr.obj-type = new-cd-doc.obj-type
    and old-cd-doc-attr.obj-code = new-cd-doc.obj-code
    and old-cd-doc-attr.pos-type = new-cd-doc.pos-type
    and old-cd-doc-attr.doc-type = new-cd-doc.doc-type
    and old-cd-doc-attr.doc-code = new-cd-doc.doc-code
on error undo, return error
:
    create new-cd-doc-attr.
    buffer-copy old-cd-doc-attr to new-cd-doc-attr.
end.
for each old-cd-doc-line no-lock  where
        old-cd-doc-line.obj-type = new-cd-doc.obj-type
    and old-cd-doc-line.obj-code = new-cd-doc.obj-code
    and old-cd-doc-line.pos-type = new-cd-doc.pos-type
    and old-cd-doc-line.doc-type = new-cd-doc.doc-type
    and old-cd-doc-line.doc-code = new-cd-doc.doc-code
on error undo, return error
:
    create new-cd-doc-line.
    buffer-copy old-cd-doc-line to new-cd-doc-line.
end.
for each old-cd-doc-line-attr no-lock  where
        old-cd-doc-line-attr.obj-type = new-cd-doc.obj-type
    and old-cd-doc-line-attr.obj-code = new-cd-doc.obj-code
    and old-cd-doc-line-attr.pos-type = new-cd-doc.pos-type
    and old-cd-doc-line-attr.doc-type = new-cd-doc.doc-type
    and old-cd-doc-line-attr.doc-code = new-cd-doc.doc-code
on error undo, return error
:
    create new-cd-doc-line-attr.
    buffer-copy old-cd-doc-line-attr to new-cd-doc-line-attr.
end.
for each old-c-cd-doc no-lock  where
        old-c-cd-doc.obj-type = new-cd-doc.obj-type
    and old-c-cd-doc.obj-code = new-cd-doc.obj-code
    and old-c-cd-doc.pos-type = new-cd-doc.pos-type
    and old-c-cd-doc.doc-type = new-cd-doc.doc-type
    and old-c-cd-doc.doc-code = new-cd-doc.doc-code
on error undo, return error
:
    create new-c-cd-doc.
    buffer-copy old-c-cd-doc to new-c-cd-doc.
end.
for each old-c-cd-doc-line no-lock  where
        old-c-cd-doc-line.obj-type = new-cd-doc.obj-type
    and old-c-cd-doc-line.obj-code = new-cd-doc.obj-code
    and old-c-cd-doc-line.pos-type = new-cd-doc.pos-type
    and old-c-cd-doc-line.doc-type = new-cd-doc.doc-type
    and old-c-cd-doc-line.doc-code = new-cd-doc.doc-code
on error undo, return error
:
    create new-c-cd-doc-line.
    buffer-copy old-c-cd-doc-line to new-c-cd-doc-line.
end.



end procedure. /* copy-cd-doc-body */