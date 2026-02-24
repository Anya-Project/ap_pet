Config = {}

-- LOCALE / LANGUAGE SETTINGS
Config.Locale = 'en' -- options: 'en', 'id'

-- FRAMEWORK SETTINGS
Config.Framework = 'qb' -- 'esx', 'qb', or 'autodetect'
Config.TargetSystem = 'qb' -- 'ox', 'qb', or 'autodetect'

-- UI SETTINGS
Config.UI = {
    Menu = 'lation_ui', -- 'ox_lib', 'qb-menu', 'lation_ui'
    Input = 'lation_ui', -- 'ox_lib', 'qb-input', 'lation_ui'
    Notify = 'qbcore', -- 'ox_lib', 'qbcore', 'esx'
    ProgressBar = 'lation_ui' -- 'ox_lib', 'qbcore', 'esx', 'lation_ui'
}

-- PET SETTINGS
Config.Command = 'pet'
Config.PetNeeds = {
    MaxHealth = 100,
    MaxHunger = 100,
    MaxThirst = 100,
    LossRate = {
        Hunger = 2, -- Amount lost per tick
        Thirst = 3,
        TickRate = 60000 -- Time in ms for status loss (e.g. 60000 = 1 minute)
    },
    Items = {
        Food = {'pet_food', 'tosti', 'kurkak', 'burger', 'sandwich'},
        Water = {'pet_water', 'water_bottle', 'kurkak_water', 'cola'}
    }
}

-- PET SHOP SETTINGS
Config.PetShop = {
    CommandAccess = false, -- If true, players can open shop from /pet. If false, they must go to a location.
    Locations = {
        {
            coords = vector4(559.162659, 2741.076172, 42.204220, 182.683075),
            pedModel = 'a_m_y_business_03',
            blip = {
                enable = true,
                sprite = 273,
                color = 48,
                scale = 0.8,
                name = 'Pet Shop'
            }
        }
    }
}

-- K9 & POLICE SETTINGS
Config.PoliceJobName = {'police', 'sapd', 'sahp'}

Config.AvailablePets = {
    ['retriever'] = { model = 'a_c_retriever', name = 'Retriever', price = 5000, type = 'civilian', canSit = true },
    ['pug'] = { model = 'a_c_pug', name = 'Pug', price = 3000, type = 'civilian', canSit = false },
    ['cat'] = { model = 'a_c_cat_01', name = 'Cat', price = 2000, type = 'civilian', canSit = false },
    ['husky'] = { model = 'a_c_husky', name = 'Husky', price = 0, type = 'civilian', canSit = true },
    ['rottweiler'] = { model = 'a_c_rottweiler', name = 'Rottweiler', price = 0, type = 'civilian', canSit = true },
    ['shepherd'] = { model = 'a_c_shepherd', name = 'German Shepherd', price = 0, type = 'k9', canSit = true },
}

Config.ContrabandItems = {
    'weed', 'weed_pooch', 'coke', 'coke_pooch', 'meth', 'meth_pooch',
    'kq_meth_low', 'kq_meth_mid', 'kq_meth_high',
    'kq_weed_joint_og_kush', 'kq_weed_joint_purple_haze', 'kq_weed_joint_white_widow', 'kq_weed_joint_blue_dream'
}
