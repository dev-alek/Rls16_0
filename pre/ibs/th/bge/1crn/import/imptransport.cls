using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.*.
block-level on error undo, throw.
class ibs.th.bge.1crn.import.imptransport implements ibs.th.bge.1crn.import.iimpsubject:
   define property Msg as character no-undo
      get.
      set.
   method public logical Excute( subjectObj as class ibs.th.bge.1crn.subjects.isubject ):
      define variable v-transport  as class   transport                           no-undo.
      define variable v-section    as class   transport_section                   no-undo.
      define variable v-ct-lvl     as class   transport_section_calibration-table no-undo.
      define variable v_sections   as class   subjects                            no-undo.
      define variable v_CalibTable as class   subjects                            no-undo.
      define variable ii           as integer no-undo .
      define variable jj           as integer no-undo .
      define variable kk           as integer no-undo .
      define variable is-create    as logical no-undo .
      define buffer buf_auto-tank          for ub.auto-tank .
      define buffer buf_auto-section       for ub.auto-section .
      define buffer buf_auto-tank-attr     for ub.auto-tank-attr .
      define buffer buf_auto-section-table for ub.auto-section-table .
      define buffer buf_clients            for ub.clients .
      v-transport = cast (subjectObj, transport).
      v_sections = v-transport:sections .
      v_CalibTable = v-transport:calibration-table .
      if v-transport:del-f = 1 then
      do:
         Msg = "Нет физического удаления автотранспорта".
      end.
      else
      do:
         find first buf_auto-tank EXCLUSIVE-LOCK where buf_auto-tank.auto-num = v-transport:reg-num no-error .
         if not AVAILABLE (buf_auto-tank) then
         do:
            create buf_auto-tank .
            buf_auto-tank.auto-num = v-transport:reg-num .
         end.
         assign
            buf_auto-tank.status_   = if v-transport:del-l = 1 then 'удал':U else 'тек':U
            buf_auto-tank.name      = v-transport:name_
            buf_auto-tank.firm-type = 'орг':U
            buf_auto-tank.firm-code = integer(v-transport:tr-owner)
            buf_auto-tank.type-AC   = v-transport:ac-type
            buf_auto-tank.type-neck = v-transport:neck-type
            .
         find first buf_auto-tank-attr EXCLUSIVE-LOCK where buf_auto-tank-attr.auto-num = buf_auto-tank.auto-num and buf_auto-tank-attr.attr-code = "auto-error" no-error .
         if not AVAILABLE (buf_auto-tank-attr) then
         do:
            create buf_auto-tank-attr.
            assign
               buf_auto-tank-attr.attr-code = "auto-error"
               buf_auto-tank-attr.auto-num  = buf_auto-tank.auto-num
               .
         end.
         buf_auto-tank-attr.attr-value = string(v-transport:me-vlm) .
         find first buf_auto-tank-attr EXCLUSIVE-LOCK where buf_auto-tank-attr.auto-num = buf_auto-tank.auto-num and buf_auto-tank-attr.attr-code = "auto-temp" no-error .
         if not AVAILABLE (buf_auto-tank-attr) then
         do:
            create buf_auto-tank-attr.
            assign
               buf_auto-tank-attr.attr-code = "auto-temp"
               buf_auto-tank-attr.auto-num  = buf_auto-tank.auto-num
               .
         end.
         buf_auto-tank-attr.attr-value = string(v-transport:ac-tk) .
         find first buf_auto-tank-attr EXCLUSIVE-LOCK where buf_auto-tank-attr.auto-num = buf_auto-tank.auto-num and buf_auto-tank-attr.attr-code = "auto-sep" no-error .
         if not AVAILABLE (buf_auto-tank-attr) then
         do:
            create buf_auto-tank-attr.
            assign
               buf_auto-tank-attr.attr-code = "auto-sep"
               buf_auto-tank-attr.auto-num  = buf_auto-tank.auto-num
               .
         end.
         if v-transport:ess <> 1 then buf_auto-tank-attr.attr-value = "no" .
         else buf_auto-tank-attr.attr-value = "yes" .
         find first buf_auto-tank-attr EXCLUSIVE-LOCK where buf_auto-tank-attr.auto-num = buf_auto-tank.auto-num and buf_auto-tank-attr.attr-code = "valve" no-error .
         if not AVAILABLE (buf_auto-tank-attr) then
         do:
            create buf_auto-tank-attr.
            assign
               buf_auto-tank-attr.attr-code = "valve"
               buf_auto-tank-attr.auto-num  = buf_auto-tank.auto-num
               .
         end.
         if v-transport:valve <> 1 then buf_auto-tank-attr.attr-value = "no" .
         else buf_auto-tank-attr.attr-value = "yes" .
         if v-transport:con-sleeve > 0
         then do :
           find first buf_auto-tank-attr EXCLUSIVE-LOCK where buf_auto-tank-attr.auto-num = buf_auto-tank.auto-num and buf_auto-tank-attr.attr-code = "con-sleeve" no-error .
           if not AVAILABLE (buf_auto-tank-attr) then
           do:
              create buf_auto-tank-attr.
              assign
                 buf_auto-tank-attr.attr-code = "con-sleeve"
                 buf_auto-tank-attr.auto-num  = buf_auto-tank.auto-num
                 .
           end.
           buf_auto-tank-attr.attr-value = string(v-transport:con-sleeve) .
         end .
         for each buf_auto-section where buf_auto-section.auto-num = v-transport:reg-num:
            delete buf_auto-section .
         end.
         for each buf_auto-section-table where buf_auto-section-table.auto-num = v-transport:reg-num:
            delete buf_auto-section-table .
         end.
         if VALID-OBJECT (v_sections) then
         do:
            buf_auto-tank.brutto-qnty = 0 .
            do ii = 1 to v_sections:Get(ii):
               v-section = cast(v_sections:SubjectObjCurr, transport_section) .
               find first buf_auto-section EXCLUSIVE-LOCK where buf_auto-section.auto-num = v-transport:reg-num and
                  buf_auto-section.section-num = v-section:sec-num no-error .
               if not AVAILABLE (buf_auto-section) then
               do:
                  create buf_auto-section.
                  buf_auto-section.auto-num = v-transport:reg-num .
                  buf_auto-section.section-num = v-section:sec-num .
               end.
               ASSIGN
                  buf_auto-section.brutto-qnty = v-section:capacity
                  buf_auto-section.add-volume  = v-section:pipe-vlm
                  buf_auto-tank.brutto-qnty    = buf_auto-tank.brutto-qnty + v-section:capacity.
               .
               case buf_auto-tank.type-neck:
                  when 1 then
                     do:
                        assign
                           buf_auto-section.length        = v-section:length_
                           buf_auto-section.width         = v-section:width_
                           buf_auto-section.section-depth = v-section:wall
                           .
                     end.
                  when 2 then
                     do:
                        assign
                           buf_auto-section.diameter-max  = v-section:length_
                           buf_auto-section.diameter-min  = v-section:width_
                           buf_auto-section.section-depth = v-section:wall
                           .
                     end.
                  when 3 then
                     do:
                        assign
                           buf_auto-section.diameter-min  = v-section:diameter
                           buf_auto-section.length  = v-section:circumference
                           buf_auto-section.section-depth = v-section:wall
                           .
                     end.
                  when 0 then
                     do:
                        if buf_auto-tank.type-AC = 1 then
                        do:
                           if VALID-OBJECT (v_CalibTable) then
                           do:
                              do jj = 1 to v_CalibTable:Get(jj):
                                 v-ct-lvl = cast(v_CalibTable:SubjectObjCurr, transport_section_calibration-table) .
                                 if v-ct-lvl:sec-num = v-section:sec-num then
                                 do:
                                    find first buf_auto-section-table EXCLUSIVE-LOCK where buf_auto-section-table.auto-num = v-transport:reg-num and
                                       buf_auto-section-table.section-num = v-ct-lvl:sec-num and
                                       buf_auto-section-table.error = v-ct-lvl:deviation no-error .
                                    IF NOT AVAILABLE (buf_auto-section-table) THEN
                                    DO:
                                       create buf_auto-section-table .
                                       assign
                                          buf_auto-section-table.auto-num    = v-transport:reg-num
                                          buf_auto-section-table.section-num = v-ct-lvl:sec-num
                                          buf_auto-section-table.error       = v-ct-lvl:deviation
                                          .
                                    end.
                                    assign
                                       buf_auto-section-table.volume-error = v-ct-lvl:amount
                                       buf_auto-section-table.volume-between = v-ct-lvl:deltaV * 100
                                    .
                                 end.
                              end.
                           end.
                           do kk = -10 to 10:
                              find first ub.auto-section-table exclusive-lock where ub.auto-section-table.auto-num = v-transport:reg-num
                                 and ub.auto-section-table.section-num = v-section:sec-num
                                 and ub.auto-section-table.error = kk no-error .
                              if not available (ub.auto-section-table) then
                              do:
                                 create ub.auto-section-table .
                                 assign
                                    ub.auto-section-table.auto-num     = v-transport:reg-num
                                    ub.auto-section-table.section-num  = v-section:sec-num
                                    ub.auto-section-table.error        = kk
                                    ub.auto-section-table.volume-error = 0
                                    .
                              end.
                           end.
                        end.
                     end.
               end case .
            end.
         end.
      end.
   end method.
end class.
