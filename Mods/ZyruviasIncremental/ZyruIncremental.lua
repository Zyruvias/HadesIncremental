ModUtil.Mod.Register("ZyruIncremental")

local config = {}
ZyruIncremental.Config = config
ZyruIncremental.CurrentVersion = 6
ZyruIncremental.CurrentVersionString = "1.1.0"
ZyruIncremental.TransientState = {}

ZyruIncremental.Constants = {
  SaveFile = {
    -- starting point
    EPILOGUE = "Epilogue",
    FRESH_FILE = "Fresh File",
    -- difficulty
    EASY = "Easy",
    STANDARD = "Standard",
    HARD = "Hard",
    HELL = "Hell",
    FREEPLAY = "Freeplay"
  },
  Difficulty = {
    Keys = {
      HEALTH_SCALIING = "HealthScaling",
      COST_SCALING = "CostScaling",
      INCOMING_DAMAGE_SCALING = "IncomingDamageScaling"
    },
    HealthScaling = {
      Easy = 1.02,
      Standard = 1.04,
      Hard = 1.06,
      Hell = 1.10
    },
    CostScaling = {
      Easy = 1.00,
      Standard = 1.01,
      Hard = 1.02,
      Hell = 1.05
    },
    IncomingDamageScaling = {
      Easy = 1.02,
      Standard = 1.04,
      Hard = 1.06,
      Hell = 1.10
    }
  },
  Components = {
    RECTANGLE_01_HEIGHT = 270,
    RECTANGLE_01_WIDTH = 480,
    PROGRESS_BAR_SCALE_PROPORTION_X = 1,
    PROGRESS_BAR_SCALE_PROPORTION_Y = 0.05
  },
  Gods = {
    ZEUS = "Zeus",
    POSEIDON = "Poseidon",
    ATHENA = "Athena",
    ARES = "Ares",
    APHRODITE = "Aphrodite",
    ARTEMIS = "Artemis",
    DIONYSUS = "Dionysus",
    DEMETER = "Demeter",
    HERMES = "Hermes",
    CHAOS = "Chaos"
  },
  Upgrades = {
    Types = {
      PURCHASE_BOON = "Purchase Boon",
      AUGMENT_RARITY = "Augment Rarity Bonus"
    }
  },
  Settings = {
    EXP_ON_HIT = "On hit",
    EXP_ON_DEATH_BY_BOON = "On kill, aggregated by Boon",
    EXP_ON_DEATH_BY_GOD = "On kill, aggregated by God",
    LEVEL_POPUP = "Overhead notification only",
    LEVEL_VOICELINE = "Voiceline only",
    LEVEL_POPUP_VOICELINE = "Overhead and Voiceline",
    LEVEL_PORTRAIT = "Portrait and Voiceline",
    LEVEL_ALL = "All settings simultaneously"
  },
  Persistence = {
    NONE = "NONE",
    PRESTIGE = "PRESTIGE"
  }
}

ModUtil.Path.Wrap(
  "SetRichPresence",
  function(base, args)
    base {Key = "steam_display", Value = "#Playing Zyruvias's Incremental Mod"}
    base {Key = "status", Value = "#Playing Zyruvias's Incremental Mod"}
  end,
  ZyruIncremental
)

ModUtil.LoadOnce(
  function()
    ApplyTransientPatches({})
  end
)
