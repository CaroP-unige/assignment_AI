;Header and description

(define (domain example2)

;remove requirements that are not needed
    (:requirements :strips :fluents :durative-actions :timed-initial-literals :typing :conditional-effects :negative-preconditions :duration-inequalities :equality)

    (:types 
        robot
        crate
        base
    ;todo: enumerate types and their hierarchy here, e.g. car truck bus - vehicle
    )

    ; un-comment following line if constants are needed
    ;(:constants )

    (:predicates 
        (at_base ?r - robot ?b - base)
        (pickable_crate ?c - crate)
        (at_crate ?r - robot ?c - crate)
        (free ?r - robot)
        (carry ?r - robot ?c - crate)
        (at ?c - crate ?b - base)
    ;todo: define predicates here
    )


    (:functions 
        (distance ?c - crate ?b - base)
        (weight ?c - crate)
        (velocity)
    ;todo: define numeric functions here
    )

    (:durative-action move_to_crate
        :parameters (?c - crate ?r - robot ?b - base)
        :duration (= ?duration (/(distance ?c ?b)(velocity)))
        :condition (and 
            (at start (and 
                (at_base ?r ?b)
                (free ?r)
            ))
            (over all (and
                (pickable_crate ?c) 
            ))
        )
        :effect (and 
            (at start (and
                (not (free ?r))
            )
            )
            (at end (and 
                (at_crate ?r ?c)
                (not (at_base ?r ?b))
            ))
        )
    )

    (:action pick_up
        :parameters (?c - crate ?r - robot)
        :precondition (and 
            (at_crate ?r ?c)
            (pickable_crate ?c)
        )
        :effect (and 
            (carry ?r ?c)
            (not (pickable_crate ?c))
        )
    )

    (:durative-action move_back
        :parameters (?c - crate ?b - base ?r - robot)
        :duration (= ?duration (/ (* (distance ?c ?b)(weight ?c)) 100))
        :condition (and 
            (at start (and 
                (at_crate ?r ?c)
                
            ))
            (over all (and 
                (carry ?r ?c)
            ))
        )
        :effect (and 
            (at end (and 
                (at_base ?r ?b)
                (not (at_crate ?r ?c))
            ))
        )
    )

    (:action drop_one_robot
        :parameters (?b - base ?c - crate ?r - robot)
        :precondition (and 
            (carry ?r ?c)
            (at_base ?r ?b)
        )
        :effect (and 
            (at ?c ?b)
            (not (carry ?r ?c))
            (free ?r)
        )
    )
    
    
    
    
;define actions here

)