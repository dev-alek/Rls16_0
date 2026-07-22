define private variable m-promo-trg as class ibs.th.ref.promo.promo_trg no-undo.
    
method Public VOID SetPromoTrg(input v-promo-trg as class ibs.th.ref.promo.promo_trg  ):

    m-promo-trg = v-promo-trg.
    &if defined (SetPromoTrg_bef) ne 0 
    &then
        SetPromoTrg_bef().
    &endif    
    &if defined (child_1) ne 0
    &then
       if valid-object ({&child_1}) then {&child_1} :SetPromoTrg     (m-promo-trg).
    &endif
    &if defined (child_2) ne 0
    &then
       if valid-object ({&child_2}) then {&child_2} :SetPromoTrg     (m-promo-trg).
    &endif
    &if defined (child_3) ne 0
    &then
       if valid-object ({&child_3}) then {&child_3} :SetPromoTrg     (m-promo-trg).
    &endif
    &if defined (child_4) ne 0
    &then
       if valid-object ({&child_4}) then {&child_4} :SetPromoTrg     (m-promo-trg).
    &endif
    &if defined (child_5) ne 0
    &then
       if valid-object ({&child_5}) then {&child_5} :SetPromoTrg     (m-promo-trg).
    &endif
    &if defined (child_6) ne 0
    &then
       if valid-object ({&child_6}) then {&child_6} :SetPromoTrg     (m-promo-trg).
       
    &endif
    &if defined (child_7) ne 0
    &then
       if valid-object ({&child_7}) then {&child_7} :SetPromoTrg     (m-promo-trg).
    &endif
    &if defined (child_8) ne 0
    &then
       if valid-object ({&child_8}) then {&child_8} :SetPromoTrg     (m-promo-trg).
    &endif
    &if defined (child_9) ne 0
    &then
       if valid-object ({&child_9}) then {&child_9} :SetPromoTrg     (m-promo-trg).
    &endif
    
    &if defined (NotSetBind) eq 0
    &then
        SetBind().
    &endif    
end.

method Public VOID PublicEvent (input iEvent as character, input iEventParam as character   ):
    
    &if defined (child_1) ne 0
    &then
       if valid-object ({&child_1}) then {&child_1} :PublicEvent     (iEvent, iEventParam).
    &endif
    &if defined (child_2) ne 0
    &then
       if valid-object ({&child_2}) then {&child_2} :PublicEvent     (iEvent, iEventParam).
    &endif
    &if defined (child_3) ne 0
    &then
       if valid-object ({&child_3}) then {&child_3} :PublicEvent     (iEvent, iEventParam).
    &endif
    &if defined (child_4) ne 0
    &then
       if valid-object ({&child_4}) then {&child_4} :PublicEvent     (iEvent, iEventParam).
    &endif
    &if defined (child_5) ne 0
    &then
       if valid-object ({&child_5}) then {&child_5} :PublicEvent     (iEvent, iEventParam).
    &endif
    &if defined (child_6) ne 0
    &then
       if valid-object ({&child_6}) then {&child_6} :PublicEvent     (iEvent, iEventParam).
       
    &endif
    &if defined (child_7) ne 0
    &then
       if valid-object ({&child_7}) then {&child_7} :PublicEvent     (iEvent, iEventParam).
    &endif
    &if defined (child_8) ne 0
    &then
       if valid-object ({&child_8}) then {&child_8} :PublicEvent     (iEvent, iEventParam).
    &endif
    &if defined (child_9) ne 0
    &then
       if valid-object ({&child_9}) then {&child_9} :PublicEvent     (iEvent, iEventParam).
    &endif
    &if defined (NotLocalEvent) eq 0
    &then
        LocalEvent(iEvent, iEventParam).
    &endif    
end.