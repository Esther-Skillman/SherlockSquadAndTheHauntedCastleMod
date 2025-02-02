---
--- Generated by Luanalysis
--- Created by msalt.
--- DateTime: 2/6/2024 4:16 PM
---
function cure(positionOfCurer)
    print('Cured')
    -- Set patient state to 'Cured', triggering the cure animation, then destroy
    owner.bus.send({['state.patient'] = 'Cured', curerPos = positionOfCurer})
    owner.destroyObject()

    -- Notify any interested listener (GameManager.lua) that a patient was cured so it can check whether the level has been won.
    game.bus.send({ 'patient.cured' })
end