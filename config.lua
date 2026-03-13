Config = {}

-- Enable automatic deletion of all vehicles when enough players are online (EN/FR)
-- Activer la suppression auto des véhicules si assez de joueurs sont connectés
Config.EnableDeleteAllVehiclesOverPlayers = false
Config.DeleteAllVehiclesOverPlayers = 80

-- Valeurs de densité par défaut (default density values)
Config.DefaultDensity = {
    vehicle = 1.0,
    parked = 1.0,
    ped = 1.0,
    scene = 1.0,
    police = 1.0,
}

Config.Languages = {
    ['en'] = {
        title = "Density Management",
        vehicles = "Vehicles",
        parked = "Parked",
        peds = "Peds",
        scenario_peds = "Scenario Peds",
        police = "Police",
        reset = "Reset",
        save = "Apply",
        close = "Close",
        credits = "by atzcpp",
        only_founder = "You are not a founder!",
        language = "Language",
        menu_icon = "🛣️ Traffic Density",
        menu_credit = "by atzcpp - modern UI",
    },
    ['fr'] = {
        title = "Gestion de la densité",
        vehicles = "Véhicules",
        parked = "Garées",
        peds = "Piétons",
        scenario_peds = "Piétons scène",
        police = "Policiers",
        reset = "Réinitialiser",
        save = "Appliquer",
        close = "Fermer",
        credits = "par atzcpp",
        only_founder = "Vous n'êtes pas fondateur.",
        language = "Langue",
        menu_icon = "🛣️ Densité circulation",
        menu_credit = "par atzcpp - UI moderne",
    }
}
Config.DefaultLang = "fr"