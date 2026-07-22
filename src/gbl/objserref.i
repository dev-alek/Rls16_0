&if defined(checkupd) ne 0
&then
   find first sys-ctrl no-lock.
   if     available sys-ctrl
      and sys-ctrl.whole-send-news ne ObjSrv:upd
   then
      ObjSrv:RefrashObject(sys-ctrl.whole-send-news).
&else
   find first sys-ctrl exclusive-lock.
   if     available sys-ctrl
   then do:
      sys-ctrl.whole-send-news = sys-ctrl.whole-send-news + 1.
      if sys-ctrl.whole-send-news > 1000
      then
         sys-ctrl.whole-send-news = 1.
   end.
&endif
   release sys-ctrl. 