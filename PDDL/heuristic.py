    initial_conditidions = [
        distance_crate1 = [10]
        distance_crate2 = [20]

        weight_crate1 = [70]
        weight_crate2 = [20]

        not_fragile_crate1 = [True]
        not_fragile_crate2 = [True]

        pickable_crate1 = [True]
        pickable_crate2 = [True]

        group_A_crate1 = [False]
        group_A_crate2 = [True]

        battery_robot1 = [20]
        battery_robot2 = [20]

        at_base_robot1 = [True]
        at_base_robot2 = [True]

        free_robot1 = [True]
        free_robot2 = [True]

        free_base = [True]

        free_charger = [True]

        free_loader = [True]
    ]   

    goal = [
        on_belt_crate1 = [True]
        on_belt_crate2 = [True]
    ] 

    h = 0

    for each crate c not yet on belt:
        
        if battery(robot) is low:
            charge_cost = max_battery - battery(robot)

        if c belongs to group A:
            group_cost = -5

        else:
            group_cost = 0

        if c is (heavy OR fragile):
            
            move = (distance robot c) / velocity 
            pick = 1
            move_back = (distance robot c x weight c) / 100
            drop = 1
            cost_mover = move + pick + move_back + drop

            if c is fragile:
                cost_loader = 6
            else:
                cost_loader = 4
                
        else if c is light:
            
            move = (distance robot c) / velocity 
            pick = 1
            move_back = (distance robot c x weight c) / 100
            drop = 1
            time_one_robot = move + pick + move_back + drop

            move_two_robot = (distance robot c) / velocity 
            move_back_two_robot = (distance robot c x weight c) / 150
            time_two_robot = move + pick + move_back + drop

            cost_mover = min(time_one_robot, time_two_robot)
            cost_loader = 4

        h = h + cost_mover + cost_loader + charge_cost + group_cost

    return h          