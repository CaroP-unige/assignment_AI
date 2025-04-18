(define (problem robot_mover_problem) 
(:domain example2)
    (:objects 
        robot1 robot2 - robot
        crate1 crate2 crate3 - crate
        base1 - base
        loader1 - loader
    )

    (:init
        (at_base robot1 base1)
        (free robot1)

        (free_loader loader1)
        (free_base base1)

        (at_base robot2 base1)
        (free robot2)

        (pickable_crate crate1)
        (pickable_crate crate2)
        (pickable_crate crate3)
        ;(pickable_crate crate4)

        (= (distance crate1 base1) 10)
        (= (distance crate2 base1) 20)
        (= (distance crate3 base1) 20)
        ;(= (distance crate4 base1) 30)

        (= (weight crate1) 70)
        (= (weight crate3) 20)
        (= (weight crate2) 20)
        ;(= (weight crate4) 60)

        (= (velocity) 10)

        ;todo: put the initial state's facts and numeric values here
    )

    (:goal (and
        (on_belt crate1)
        (on_belt crate2)
        (on_belt crate3)
        ;(on_belt crate4)
        ;todo: put the goal condition here
    ))

;un-comment the following line if metric is needed
;(:metric minimize (???))
)

