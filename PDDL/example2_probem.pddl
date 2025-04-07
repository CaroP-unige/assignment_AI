(define (problem robot_mover_problem) 
(:domain example2)
    (:objects 
        robot1 robot2 - robot
        crate1 crate2 crate3 - crate
        base1 - base
    )

    (:init
        (at_base robot1 base1)
        (free robot1)


        (at_base robot2 base1)
        (free robot2)

        (pickable_crate crate1)
        (pickable_crate crate2)
        (pickable_crate crate3)

        ;(not(carry robot1 crate1))
        ;(not(at_crate robot1 crate1))
        ;(not(at crate1 base1))
        ;(not(carry robot1 crate2))
        ;(not(at_crate robot1 crate2))
        ;(not(at crate2 base1))
        
        (= (distance crate1 base1) 10)
        (= (distance crate2 base1) 20)
        (= (distance crate3 base1) 20)

        (= (weight crate1) 70)
        (= (weight crate3) 20)
        (= (weight crate2) 20)

        (= (velocity) 10)

        ;todo: put the initial state's facts and numeric values here
    )

    (:goal (and
        (at crate1 base1)
        (at crate2 base1)
        (at crate3 base1)
        ;todo: put the goal condition here
    ))

;un-comment the following line if metric is needed
;(:metric minimize (???))
)
