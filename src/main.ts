import * as rm from "https://deno.land/x/remapper@4.2.0/src/mod.ts"
import * as bundleInfo from '../bundleinfo.json' with { type: 'json' }

const pipeline = await rm.createPipeline({ bundleInfo })

const bundle = rm.loadBundle(bundleInfo)
const materials = bundle.materials
const prefabs = bundle.prefabs

// ----------- { SCRIPT } -----------

async function doMap(file: rm.DIFFICULTY_NAME) {
    const map = await rm.readDifficultyV3(pipeline, file)


    rm.environmentRemoval(map, ['Environment', 'GameCore'])
    map.difficultyInfo.requirements = [
        'Chroma',
        'Noodle Extensions',
        'Vivify',
    ]

    map.difficultyInfo.settingsSetter = {
        graphics: {
            screenDisplacementEffectsEnabled: true,
        },
        chroma: {
            disableEnvironmentEnhancements: false,
        },
        playerOptions: {
            noteJumpDurationTypeSettings: 'Dynamic',
        },
        colors: {},
        environments: {},
    }

    rm.setRenderingSettings(map, {
        qualitySettings: {
            realtimeReflectionProbes: rm.BOOLEAN.True,
            shadows: rm.SHADOWS.HardOnly,
            shadowDistance: 8,
            shadowResolution: rm.SHADOW_RESOLUTION.Low,
            
        },
        renderSettings: {
            fog: rm.BOOLEAN.True,
            fogEndDistance: 64,
        },
    })

    const scene = prefabs.scene.instantiate(map, 0)
/*
    rm.assignObjectPrefab(map, {
        colorNotes: {
            track: 'Notes',
            asset: prefabs.customnote.path,
            debrisAsset: prefabs.customnotedebris.path,
            anyDirectionAsset: prefabs.customnotedot.path,
        },
    })
*/
     rm.assignPathAnimation(map, {
        track: 'Notes',
        animation: {
            offsetPosition: [
                [0, -1, 0, 0],
                [0, 0, 0, 0.2, "easeOutSine"],
            ]
        },
    })

     map.colorNotes.forEach(note => {
        note.unsafeCustomData._disableSpawnEffect = rm.BOOLEAN.False
        note.unsafeCustomData.disableNoteGravity= rm.BOOLEAN.False
        note.track.add('Notes')
     })

    // Example: Run code on every note!

    // map.allNotes.forEach(note => {
    //     console.log(note.beat)
    // })

    // For more help, read: https://github.com/Swifter1243/ReMapper/wiki
}

await Promise.all([
    doMap('ExpertPlusStandard')
])

// ----------- { OUTPUT } -----------

pipeline.export({
    outputDirectory: '../Hunt'
})
