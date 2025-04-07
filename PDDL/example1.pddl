;Header and description

(define (domain durative_mover)

;remove requirements that are not needed
    (:requirements :strips :fluents :durative-actions :timed-initial-literals :typing :conditional-effects :negative-preconditions :duration-inequalities :equality)

    (:types 
        robot
        base
        crate
        loader
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
        (free_base ?b - base)
        (free_loader ?l - loader)
        (picked ?c - crate ?l - loader)
        (on_belt ?c - crate)
        ;to do se serve: non toccare la crate già processata
        ;todo: define predicates here
    )


    (:functions 
        (weight ?c - crate)
        (distance ?c - crate ?b - base)
    ;todo: define numeric functions here
    )

;define actions here
    (:durative-action move_one_robot
        :parameters (?r - robot ?c - crate ?b - base)
        :duration (= ?duration (/ (distance ?c ?b) 10))
        :condition (and 
            (at start (and 
                (at_base ?r ?b)
                (free ?r)
                (< (weight ?c) 50)
            ))
            (over all (and
                (pickable_crate ?c)
            ))
        )
        :effect (and 
            (at start (and
                (not (free ?r))
            ))
            (at end (and 
                (at_crate ?r ?c)
                (not (at_base ?r ?b))
            ))
        )
    )

    (:action pick_one_robot
        :parameters (?r - robot ?c - crate)
        :precondition (and
            (at_crate ?r ?c)
            (pickable_crate ?c)
            (< (weight ?c) 50)
         )
        :effect (and 
            (not (free ?r))
            (carry ?r ?c)
            (not (pickable_crate ?c))
        )
    )
    
    (:durative-action move_back_one_robot
        :parameters (?c - crate ?r - robot ?b - base)
        :duration (= ?duration (/ (* (distance ?c ?b) (weight ?c)) 100))
        :condition (and 
            (at start (and
                (at_crate ?r ?c)
                (< (weight ?c) 50)
            ))
            (over all (and(carry ?r ?c)))
            
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
            (free_base ?b)
            (carry ?r ?c)
            (at_base ?r ?b)
            (< (weight ?c) 50)
        )
        :effect (and 
            (at ?c ?b)
            (not (carry ?r ?c))
            (free ?r)
            (not (free_base ?b))
        )
    )
    
    (:durative-action move_two_robot
        :parameters (?r1 - robot ?r2 - robot ?c - crate ?b - base)
        :duration (= ?duration (/ (distance ?c ?b) 10))
        :condition (and 
            (at start (and 
                (at_base ?r1 ?b)
                (at_base ?r2 ?b)
                (free ?r2)
                (free ?r1)
                (> (weight ?c) 50)
            ))
            (over all (and
                (pickable_crate ?c)
            ))
        )
        :effect (and 
            (at start (and
                (not (free ?r1))
                (not (free ?r2))
            ))
            (at end (and 
                (at_crate ?r1 ?c)
                (at_crate ?r2 ?c)
                (not (at_base ?r2 ?b))
                (not (at_base ?r1 ?b))
            ))
        )
    )

    (:action pick_two_robot
        :parameters (?r1 - robot ?r2 - robot ?c - crate)
        :precondition (and
            (at_crate ?r1 ?c)
            (at_crate ?r2 ?c)
            (pickable_crate ?c)
            (> (weight ?c) 50)
         )
        :effect (and 
            (not (free ?r1))
            (not (free ?r2))
            (carry ?r1 ?c)
            (carry ?r2 ?c)
            (not (pickable_crate ?c))
        )
    )
    
    (:durative-action move_back_two_robot
        :parameters (?c - crate ?r1 - robot ?r2 - robot ?b - base)
        :duration (= ?duration (/ (* (distance ?c ?b) (weight ?c)) 100))
        :condition (and 
            (at start (and
                (at_crate ?r1 ?c)
                (at_crate ?r2 ?c)
                (> (weight ?c) 50)
            ))
            (over all (and
            (carry ?r1 ?c)
            (carry ?r2 ?c)
            ))
            
        )
        :effect (and 
            (at end (and 
                (at_base ?r1 ?b)
                (at_base ?r2 ?b)
                (not (at_crate ?r1 ?c))
                (not (at_crate ?r2 ?c))
            ))
        )
    )
    
    (:action drop_two_robot
        :parameters (?b - base ?c - crate ?r1 - robot ?r2 - robot)
        :precondition (and 
            (free_base ?b)
            (carry ?r1 ?c)
            (carry ?r2 ?c)
            (at_base ?r1 ?b)
            (at_base ?r2 ?b)
            (> (weight ?c) 4)
        )
        :effect (and 
            (at ?c ?b)
            (not (carry ?r1 ?c))
            (not (carry ?r2 ?c))
            (free ?r1)
            (free ?r2)
            (not (free_base ?b))
        )
    )

    (:action pick_loader
        :parameters (?b - base ?c - crate ?l - loader)
        :precondition (and 
            (free_loader ?l)
            (at ?c ?b)
        )
        :effect (and 
            (picked ?c ?l)
            (not (free_loader ?l))
            (not(at ?c ?b))
        )
    )
    
    (:durative-action loading
        :parameters (?c - crate ?b - base ?l - loader)
        :duration (= ?duration 4)
        :condition (and 
            (at start  (and
                (picked ?c ?l) 
            ))
        )
        :effect (and 
            (at end (and 
                (free_base ?b)
                (on_belt ?c)
                (free_loader ?l)
                (not (picked ?c ?l))
            ))
        )
    )
    

)