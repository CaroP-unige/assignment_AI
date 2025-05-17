    initial_conditidions = [
        distance_crate1 = [10]
        distance_crate2 = [20]

        pickable_crate1 = [True]
        pickable_crate2 = [True]

        at_base_robot1 = [True]
        at_base_robot2 = [True]

        free_robot1 = [True]
        free_robot2 = [True]

        free_base = [True]

        free_loader = [True]
    ]   

    goal = [
        on_belt_crate1 = [True]
        on_belt_crate2 = [True]
    ] 

    h = 0

    for each crate c not yet on belt:

            move = (distance robot c) / 100 
            pick = 1
            move_back = (distance robot c ) / 100
            drop = 1
            cost_mover = move + pick + move_back + drop

            cost_loader = 4

        h = h + cost_mover + cost_loader

    return h          