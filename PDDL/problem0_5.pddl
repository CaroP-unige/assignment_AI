(define (problem robot_mover_problem) 
(:domain main_domain)
    (:objects 
        robot1 robot2 - robot
        crate1 crate2 - crate
        base1 - base
        loader1 - loader
        loader2 - loader ; cheap
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
        
        (= (distance crate1 base1) 10) ; A
        (= (distance crate2 base1) 20) ; A
        
        (= (weight crate1) 70)
        (= (weight crate2) 20)

        (free_charge base1) 

        (not_fragile crate1)
        (not_fragile crate2)

        (= (battery robot1) 20) ;carica iniziale robot1
        (= (battery robot2) 20) ;carica iniziale robot2
        (= (max_battery) 20)

        (no_group crate1)
        (groupA crate2)

        (=(velocity) 10)
        (=(priority)2)
        (=(max_priority )2)
    )

    (:goal (and
        (on_belt crate1)
        (on_belt crate2)

        ;todo: put the goal condition here
    ))
    
)
