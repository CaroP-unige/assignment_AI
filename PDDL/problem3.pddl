(define (problem problem3) 
(:domain definitivo)
    (:objects 
        robot1 robot2 - robot
        crate1 crate2 crate3 crate4 - crate
        base1 - base
        loader1 - loader
        loader_leggero1 - loader_leggero
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

        (= (distance crate1 base1) 20)
        (= (distance crate2 base1) 20)
        (= (distance crate3 base1) 30)
        (= (distance crate4 base1) 10) 

        (= (weight crate1) 70)
        (= (weight crate2) 80)
        (= (weight crate3) 60)
        (= (weight crate4) 30)

        (not_fragile crate1)
        (fragile crate2)
        (not_fragile crate3)
        (not_fragile crate4)

        (= (battery robot1) 20) ;carica iniziale robot1
        (= (battery robot2) 20) ;carica iniziale robot2
        (= (max_battery) 20)

        (groupA crate1)
        (groupA crate2)
        (groupA crate3)
        (no_group crate4)

        (=(velocity) 10)
        (=(priority)2)
        (=(max_priority )2)
    )

    (:goal (and
        (on_belt crate1)
        (on_belt crate2)
        (on_belt crate3)
        (on_belt crate4)


        ;todo: put the goal condition here
    ))
    
)
