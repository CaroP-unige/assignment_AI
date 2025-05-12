(define (problem problem4) 
(:domain definitivo)
    (:objects 
        robot1 robot2 - robot
        crate1 crate2 crate3 crate4 crate5 crate6 - crate
        base1 - base
        loader1 - loader
        loader_leggero1 - loader_leggero ; cheap
    )

    (:init
        (free_charger base1)

        (at_base robot1 base1)
        (free robot1)

        ;(free_base base1)
        (=(free_base) 0)
        (free_loader loader1)
        (free_loader_leggero loader_leggero1)

        (at_base robot2 base1)
        (free robot2)

        (pickable_crate crate1)
        (pickable_crate crate2)
        (pickable_crate crate3)
        (pickable_crate crate4)
        (pickable_crate crate5)
        (pickable_crate crate6)

        (= (distance crate1 base1) 20) ; A
        (= (distance crate2 base1) 20) ; A - fragile
        (= (distance crate3 base1) 10) ; B - fragile
        (= (distance crate4 base1) 20) ; B - fragile
        (= (distance crate5 base1) 30) ; B - fragile
        (= (distance crate6 base1) 10) 

        (= (weight crate1) 30)
        (= (weight crate2) 20)
        (= (weight crate3) 30)
        (= (weight crate4) 20)
        (= (weight crate5) 30)
        (= (weight crate6) 20)

        (not_fragile crate1)
        (fragile crate2)
        (fragile crate3)
        (fragile crate4)
        (fragile crate5)
        (not_fragile crate6)
        
        

        (= (battery robot1) 20) ;carica iniziale robot1
        (= (battery robot2) 20) ;carica iniziale robot2
        (= (max_battery) 20)

        (groupA crate1)
        (groupA crate2)
        (groupB crate3)
        (groupB crate4)
        (groupB crate5)
        (no_group crate6)

        (=(velocity) 10)
        (=(priority)3)
        (=(max_priority )3)
        ;todo: put the initial state's facts and numeric values here
    )

    (:goal (and
        (on_belt crate1)
        (on_belt crate2)
        (on_belt crate3)
        (on_belt crate4)
        (on_belt crate5)
        (on_belt crate6)

        ;todo: put the goal condition here
    ))
    
)
