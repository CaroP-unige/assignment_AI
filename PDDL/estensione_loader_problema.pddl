(define (problem loader_problema) 
(:domain loader)
    (:objects 
        robot1 robot2 - robot
        crate1 crate2 crate3 - crate
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

        (=(velocity) 10)

        (pickable_crate crate1)
        (pickable_crate crate2)
        (pickable_crate crate3)

        (= (distance crate1 base1) 10)
        (= (distance crate2 base1) 20)
        (= (distance crate3 base1) 30)

        (= (weight crate1) 20)
        (= (weight crate2) 30)
        (= (weight crate3) 70)

        (fragile crate1)
        (not_fragile crate2)
        (not_fragile crate3)

        (= (battery robot1) 20)
        (= (battery robot2) 20)
        (= (max_battery) 20)

        ;todo: put the initial state's facts and numeric values here
    )

    (:goal (and
        (on_belt crate1)
        (on_belt crate2)
        (on_belt crate3)
        ;todo: put the goal condition here
    ))

;un-comment the following line if metric is needed
;(:metric minimize (???))
)
